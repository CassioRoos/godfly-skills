#!/bin/sh
# assert-close.sh — gate the close ritual (mortality without evidence loss).
#
# Usage: assert-close.sh <slug> [--pr-body-confirmed] [--remote-homes-confirmed]
#
# A toolshed may only be deleted when:
#   1. Understanding gate passes (assert-started.sh), and the STATE shape gate
#      (assert-state.sh --soft) runs — its warnings are forwarded here, because
#      the skill documents close as running both.
#   2. At least one commit containing the folder is REACHABLE FROM THE DEFAULT
#      BRANCH. Local commits are not enough: under squash-merge, commits that
#      only ever existed on the feature branch vanish, so a folder added and
#      deleted across one PR leaves ZERO trace on the default branch. Escape
#      hatch for the pre-merge close (the normal case): --pr-body-confirmed,
#      or TOOLSHED_PR_BODY_CONFIRMED=1 — assert it only after reading the PR
#      body and confirming it inlines the final records.
#   3. No open questions (answer, park with a wake-up trigger, or promote), and
#      no `parked` question without a permanent home — the folder dies, so a
#      parked question with nowhere to live is a question being dropped.
#   4. No undecided (proposed) decisions — decide or supersede before close.
#   5. No template placeholders ({{...}}) anywhere in the folder.
#   6. Working tree for the folder is clean (record the final state before
#      you delete it).
#   7. questions.md / decisions.md have balanced <!-- --> markers — record
#      scans skip commented regions, so an unterminated comment would hide
#      real records instead of failing.
set -eu

usage() { echo "usage: assert-close.sh <slug> [--pr-body-confirmed] [--remote-homes-confirmed]" >&2; exit 2; }

PR_BODY_CONFIRMED=${TOOLSHED_PR_BODY_CONFIRMED:-0}
REMOTE_HOMES_CONFIRMED=0
ARG=""
for a in "$@"; do
  case "$a" in
    --pr-body-confirmed) PR_BODY_CONFIRMED=1 ;;
    --remote-homes-confirmed) REMOTE_HOMES_CONFIRMED=1 ;;
    -*) usage ;;
    *) ARG=$a ;;
  esac
done
[ -n "$ARG" ] || usage

SLUG=$(printf '%s' "$ARG" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\{1,\}/-/g; s/^-\{1,\}//; s/-\{1,\}$//')
[ -n "$SLUG" ] || usage
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "assert-close: not inside a git repo" >&2; exit 1; }
DIR="$ROOT/docs/work/$SLUG"
FAILED=0
fail() { echo "assert-close: FAIL — $*" >&2; FAILED=1; }
warn() { echo "assert-close: WARN — $*" >&2; }

[ -d "$DIR" ] || { echo "assert-close: FAIL — missing $DIR" >&2; exit 1; }

# The templates ship `- **Status:** open` / `proposed` inside <!-- --> record
# skeletons, so every record scan must read the file with comment regions
# removed or a pristine seed could never close.
SCRIPT_DIR=$(dirname -- "$0")
command -v python3 >/dev/null 2>&1 || { echo "assert-close: Python 3.9+ required" >&2; exit 1; }
uncommented() { python3 "$SCRIPT_DIR/validate-homes.py" --strip-comments "$1"; }

# An unterminated `<!--` blanks everything after it, which would hide real
# records from the scans below — refuse rather than pass by accident.
check_comments() {
  [ -f "$1" ] || return 0
  COMMENT_ERROR=$(uncommented "$1" 2>&1 >/dev/null) || fail "unbalanced or invalid HTML comments in ${1##*/}: $COMMENT_ERROR"
}
check_comments "$DIR/questions.md"
check_comments "$DIR/decisions.md"

SCRIPT_DIR=$(dirname -- "$0")

# 1. Understanding gate.
if ! sh "$SCRIPT_DIR/assert-started.sh" "$SLUG" >/dev/null 2>&1; then
  fail "assert-started gate does not pass — a toolshed that never oriented cannot close"
fi

# 1b. STATE shape gate, soft (legacy bloat must not block a close, but it must
# not close silently either). Forward whatever assert-state says.
if STATE_OUT=$(sh "$SCRIPT_DIR/assert-state.sh" "$SLUG" --soft 2>&1); then
  STATE_WARN=$(printf '%s\n' "$STATE_OUT" | sed -n 's/^assert-state: WARN — //p')
  [ -z "$STATE_WARN" ] || warn "STATE shape (assert-state --soft): $STATE_WARN"
else
  fail "assert-state gate does not pass: $(printf '%s\n' "$STATE_OUT" | sed -n 's/^assert-state: FAIL — //p')"
fi

# 2. Committed at least once (the survival precondition).
COMMITTED=0
if git -C "$ROOT" check-ignore -q "docs/work/$SLUG/STATE.md" 2>/dev/null; then
  if [ "$PR_BODY_CONFIRMED" = "1" ]; then
    warn "local-only toolshed: passing ONLY on read-back attestation that the PR body preserves the final local records; Git is not an archive"
  else
    fail "docs/work/ is gitignored — preserve the final records in the PR body and read them back before --pr-body-confirmed; local-only state has no Git archive"
  fi
elif [ -z "$(git -C "$ROOT" log --oneline -1 -- "docs/work/$SLUG" 2>/dev/null)" ]; then
  fail "docs/work/$SLUG has ZERO commits — deleting now destroys it everywhere. Commit it once before the closing PR"
else
  COMMITTED=1
fi

# An otherwise tracked folder may still contain ignored final artifacts.
# Ordinary git status/diff omits them, so Git cannot attest their preservation.
IGNORED_FILES=$(git -C "$ROOT" ls-files --others --ignored --exclude-standard -- "docs/work/$SLUG")
if [ -n "$IGNORED_FILES" ] && [ "$PR_BODY_CONFIRMED" != "1" ]; then
  fail "ignored files exist inside docs/work/$SLUG — Git does not preserve them; read back the final safe records/artifacts in the external archive before --pr-body-confirmed"
fi

# 2b. Reachable from the DEFAULT BRANCH. `git log -- path` on local history
# cannot tell merged from unmerged, which is exactly the squash-merge case law 1
# names by name: feature-branch-only commits are not an archive.
if [ "$COMMITTED" -eq 1 ]; then
  DEFAULT_REF=""
  ORIGIN_HEAD=$(git -C "$ROOT" symbolic-ref -q --short refs/remotes/origin/HEAD 2>/dev/null || true)
  for r in $ORIGIN_HEAD origin/main origin/master main master; do
    if git -C "$ROOT" rev-parse --verify -q "$r^{commit}" >/dev/null 2>&1; then
      DEFAULT_REF=$r
      break
    fi
  done
  if [ -z "$DEFAULT_REF" ]; then
    if [ "$PR_BODY_CONFIRMED" = "1" ]; then
      warn "default branch unknown — passing ONLY on explicit PR-body attestation of final records"
    else
      fail "cannot resolve a default branch — archive preservation is UNVERIFIED; read back the closing PR body before --pr-body-confirmed"
    fi
  elif [ -z "$(git -C "$ROOT" log --oneline -1 "$DEFAULT_REF" -- "docs/work/$SLUG" 2>/dev/null)" ]; then
    if [ "$PR_BODY_CONFIRMED" = "1" ]; then
      warn "docs/work/$SLUG never reached $DEFAULT_REF — passing on --pr-body-confirmed. The PR body is now the ONLY archive; if it does not inline the final records, they are gone after squash-merge"
    else
      fail "docs/work/$SLUG never reached $DEFAULT_REF; under squash-merge these commits vanish — the PR body is your only archive; confirm it inlines the final records (then pass with --pr-body-confirmed, or TOOLSHED_PR_BODY_CONFIRMED=1)"
    fi
  elif [ "$PR_BODY_CONFIRMED" != "1" ] && ! git -C "$ROOT" diff --quiet "$DEFAULT_REF" HEAD -- "docs/work/$SLUG"; then
    fail "final records differ from $DEFAULT_REF — an older archived version is insufficient; preserve the final records and read them back before --pr-body-confirmed"
  fi
fi

# 3. Open questions.
if [ -f "$DIR/questions.md" ] && uncommented "$DIR/questions.md" | grep -qE '^\- \*\*Status:\*\* *open'; then
  fail "open questions remain in questions.md — answer, park (with wake-up trigger), or promote"
fi

# 3b. Parked questions must name a permanent home. Parking is deferral, and the
# folder does not survive to be woken up in — the home is the wake-up surface.
if [ -f "$DIR/questions.md" ]; then
  if ! command -v python3 >/dev/null 2>&1; then
    fail "Python 3.9+ is required to validate permanent question homes"
  else
    if [ "$REMOTE_HOMES_CONFIRMED" = "1" ]; then
      HOME_RESULT=$(python3 "$SCRIPT_DIR/validate-homes.py" "$ROOT" "$DIR/questions.md" --remote-homes-confirmed 2>&1) || fail "$HOME_RESULT"
    else
      HOME_RESULT=$(python3 "$SCRIPT_DIR/validate-homes.py" "$ROOT" "$DIR/questions.md" 2>&1) || fail "$HOME_RESULT"
    fi
  fi
fi

# 4. Undecided decisions.
if [ -f "$DIR/decisions.md" ] && uncommented "$DIR/decisions.md" | grep -qE '^\- \*\*Status:\*\* *proposed'; then
  fail "proposed (undecided) decisions remain in decisions.md — decide or supersede before close"
fi

# 5. Unrendered placeholders.
if grep -rn '{{' "$DIR" >/dev/null 2>&1; then
  fail "template placeholders ({{...}}) remain in docs/work/$SLUG"
fi

# 6. Dirty working tree for the folder.
if [ -n "$(git -C "$ROOT" status --porcelain "docs/work/$SLUG" 2>/dev/null)" ]; then
  fail "uncommitted changes in docs/work/$SLUG — commit the final state before deleting"
fi

# Reminders that cannot be mechanically proven. Scoped to the record bodies
# (first `### D-` onward): the file's own prose mentions ADRs, which used to
# suppress this warning for every repo.
HAS_DECIDED=0
if [ -f "$DIR/decisions.md" ]; then
  RECORDS=$(uncommented "$DIR/decisions.md" | sed -n '/^### D-/,$p')
  if printf '%s\n' "$RECORDS" | grep -qE '^\- \*\*Status:\*\* *decided'; then
    HAS_DECIDED=1
    if ! printf '%s\n' "$RECORDS" | grep -qE 'ADR-[0-9]|docs/adr/|Status:.*promoted'; then
      warn "decided records exist but no promotion/ADR link found — sweep contract decisions before close"
    fi
  fi
fi
# Only worth saying when there is something to inline: an always-on reminder on
# a toolshed with zero decided records is the alarm everyone learns to ignore.
if [ "$HAS_DECIDED" -eq 1 ]; then
  warn "closing PR description must inline the final decided records + key evidence — it is the squash-proof archive of record"
fi

if [ "$FAILED" -ne 0 ]; then
  exit 1
fi
echo "assert-close: OK — $SLUG may be genre-mapped and deleted"
