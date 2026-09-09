#!/bin/sh
# acceptance.sh — end-to-end proof that the toolshed gates fire and only fire
# when they should. Builds a throwaway git repo, seeds it, and walks the full
# lifecycle: orient gate → state shape → close gate → hostile input.
#
# Usage: acceptance.sh            (uses this script's own sibling scripts)
#
# Prints one PASS/FAIL line per step and exits non-zero if any step failed.
# Two behaviours are pinned deliberately, because both were broken once:
#   - a PRISTINE seed must be able to close: the templates carry
#     `- **Status:** open/proposed` inside <!-- --> record skeletons, and the
#     close gate must not read commented-out examples as real records.
#   - a correctly filled Understanding must pass the orient gate: the
#     template's instructional blockquote is not a placeholder.
set -eu

SCRIPTS=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SLUG=acceptance-probe
VERSION_EXPECTED=2.1
FAILED=0

pass() { echo "PASS - $1"; }
bad()  { echo "FAIL - $1"; FAILED=1; }
expect_ok()   { d="$1"; shift; if "$@" >/dev/null 2>&1; then pass "$d"; else bad "$d"; fi; }
expect_fail() { d="$1"; shift; if "$@" >/dev/null 2>&1; then bad "$d"; else pass "$d"; fi; }

WORK=$(mktemp -d)
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT HUP INT TERM

commit_all() { git add -A . && git commit -qm "$1"; }
rewrite() { t=$(mktemp); sed "$1" "$2" > "$t" && cat "$t" > "$2"; rm -f "$t"; }
# The default branch name must be deterministic: the close gate resolves it to
# decide whether the folder ever merged.
init_repo() {
  mkdir -p "$1"
  cd "$1"
  git init -q .
  git symbolic-ref HEAD refs/heads/main
  git config user.email acceptance@example.invalid
  git config user.name "toolshed acceptance"
  git config core.hooksPath /dev/null
  git config commit.gpgSign false
  printf '# %s\n' "${1##*/}" > README.md
  git add README.md
  git commit -qm "init"
}

REPO="$WORK/repo"
init_repo "$REPO"

echo "toolshed acceptance: $REPO"

# 1. Seed.
SEED_OUT=$(sh "$SCRIPTS/seed.sh" "$SLUG" "probe the gates" 2>&1 || true)
if [ -f "docs/work/$SLUG/STATE.md" ] && [ -f docs/work/TOOLSHED.md ]; then
  pass "seed creates docs/work/$SLUG + TOOLSHED.md convention"
else
  bad "seed creates docs/work/$SLUG + TOOLSHED.md convention"
fi

# 1a. Seed stages only what it created under docs/work/ — the repo-root rules
#     files are the user's to review, and it says so loudly when it makes one.
STAGED=$(git diff --cached --name-only)
if printf '%s\n' "$STAGED" | grep -q "docs/work/$SLUG/STATE.md" \
  && ! printf '%s\n' "$STAGED" | grep -qE '^(CLAUDE|AGENTS)\.md$'; then
  pass "seed stages its own files and never stages CLAUDE.md / AGENTS.md"
else
  bad "seed stages its own files and never stages CLAUDE.md / AGENTS.md"
fi
if printf '%s\n' "$SEED_OUT" | grep -q 'AGENTS.md CREATED at the repo root'; then
  pass "seed announces a newly created root rules file"
else
  bad "seed announces a newly created root rules file"
fi

# 1b. A brand-new rules file must not start with a blank line.
if [ -f CLAUDE.md ] && [ -n "$(sed -n 1p CLAUDE.md)" ]; then
  pass "seeded CLAUDE.md has no stray leading blank line"
else
  bad "seeded CLAUDE.md has no stray leading blank line"
fi

# 2. Orient gate refuses a pristine seed.
expect_fail "assert-started FAILS on a pristine seed" \
  sh "$SCRIPTS/assert-started.sh" "$SLUG"

# 3. Fill Understanding — the instructional blockquote stays put on purpose.
rewrite 's|^_(not yet written)_$|Today: gates live in scripts/ (assert-close.sh:44). Assumption: templates\nship commented skeletons (verified). Unverified: nothing.|' \
  "docs/work/$SLUG/STATE.md"
expect_ok "assert-started PASSES once Understanding is written" \
  sh "$SCRIPTS/assert-started.sh" "$SLUG"

# 4. Shape gate on a thin tree.
expect_ok "assert-state PASSES on a freshly seeded STATE.md" \
  sh "$SCRIPTS/assert-state.sh" "$SLUG"

# 5. Close gate refuses an uncommitted toolshed (mortality precondition).
expect_fail "assert-close FAILS while the folder has zero commits" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

commit_all "seed $SLUG"

# 6. The pin: pristine templates must not block close.
expect_ok "assert-close PASSES on pristine templates (commented skeletons ignored)" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

# 6b. Alarm fatigue: with zero decided records there is nothing to inline, so the
#     PR-body reminder must stay quiet (it used to fire on every close).
if sh "$SCRIPTS/assert-close.sh" "$SLUG" 2>&1 | grep -q 'squash-proof archive'; then
  bad "PR-body reminder stays quiet when there are zero decided records"
else
  pass "PR-body reminder stays quiet when there are zero decided records"
fi

# 7. A real open question must block close.
cat >> "docs/work/$SLUG/questions.md" <<'EOF'

### Q-001 — does the close gate see a real open question
- **Status:** open · **Priority:** P1 · **Opened:** 2026-01-01
- **Origin:** acceptance.sh
- **Question:** does assert-close fail on this record?
EOF
commit_all "add open question"
expect_fail "assert-close FAILS on a real open question" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

rewrite 's|^\- \*\*Status:\*\* open · \*\*Priority|- **Status:** answered · **Priority|' \
  "docs/work/$SLUG/questions.md"
commit_all "answer Q-001"
expect_ok "assert-close PASSES once the question is answered" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

# 8. A real proposed decision must block close.
cat >> "docs/work/$SLUG/decisions.md" <<'EOF'

### D-001 — strip comment regions before record scans
- **Status:** proposed · **Date:** 2026-01-01
- **Context:** the close gate read template examples as live records.
- **Options:**
  1. strip comments — for: pristine seeds close / against: none found
  2. drop the skeletons — for: simpler / against: loses the record shape
- **Encouraged option:** 1 — wins on compatibility.
- **Consequences:** record scans read uncommented text only.
EOF
commit_all "add proposed decision"
expect_fail "assert-close FAILS on a real proposed decision" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

rewrite 's|^\- \*\*Status:\*\* proposed · \*\*Date|- **Status:** decided · **Date|' \
  "docs/work/$SLUG/decisions.md"
commit_all "decide D-001"
expect_ok "assert-close PASSES once the decision is decided" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

# 9. The promotion-link reminder must fire for a decided record with no link,
#    and go quiet once one exists (it used to be permanently suppressed by the
#    template's own prose).
if sh "$SCRIPTS/assert-close.sh" "$SLUG" 2>&1 | grep -q 'no promotion/ADR link found'; then
  pass "assert-close WARNS when a decided record carries no promotion link"
else
  bad "assert-close WARNS when a decided record carries no promotion link"
fi
printf -- '- **Promoted:** docs/adr/0001-strip-comment-regions.md\n' >> "docs/work/$SLUG/decisions.md"
commit_all "link D-001 to its ADR"
if sh "$SCRIPTS/assert-close.sh" "$SLUG" 2>&1 | grep -q 'no promotion/ADR link found'; then
  bad "promotion warning goes quiet once an ADR link exists"
else
  pass "promotion warning goes quiet once an ADR link exists"
fi
if sh "$SCRIPTS/assert-close.sh" "$SLUG" 2>&1 | grep -q 'squash-proof archive'; then
  pass "PR-body reminder fires once a decided record exists"
else
  bad "PR-body reminder fires once a decided record exists"
fi

# 10. Unrendered placeholders block close.
printf 'leftover {{SLUG}}\n' >> "docs/work/$SLUG/evidence.md"
commit_all "leave a placeholder"
expect_fail "assert-close FAILS on unrendered {{...}} placeholders" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"
rewrite '/^leftover {{SLUG}}$/d' "docs/work/$SLUG/evidence.md"
commit_all "remove placeholder"

# 10b. An unterminated comment must not silently hide the records that follow.
cat >> "docs/work/$SLUG/questions.md" <<'EOF'

<!-- forgot to close this
### Q-002 — hidden by a broken comment
- **Status:** open · **Priority:** P0 · **Opened:** 2026-01-01
EOF
commit_all "leave an unterminated comment"
expect_fail "assert-close FAILS on an unterminated <!-- (cannot trust the scan)" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"
printf -- '-->\n' >> "docs/work/$SLUG/questions.md"
commit_all "close the comment"
expect_ok "assert-close PASSES once the comment is closed" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

# 11. A dirty tree blocks close (the final state must be recorded).
printf '\n- 2026-01-01 — uncommitted edit.\n' >> "docs/work/$SLUG/STATE.md"
expect_fail "assert-close FAILS on an uncommitted change in the folder" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"
commit_all "final state"
expect_ok "assert-close PASSES again once the tree is clean" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

# 11b. The skill documents close as running the STATE shape gate, so it must:
#      a bloated STATE warns loudly through assert-close without blocking close.
cp "docs/work/$SLUG/STATE.md" "$WORK/state.bak"
i=0
while [ "$i" -lt 100 ]; do
  printf -- '- filler line pushing STATE past the soft cap.\n' >> "docs/work/$SLUG/STATE.md"
  i=$((i + 1))
done
commit_all "bloat STATE past the soft cap"
if sh "$SCRIPTS/assert-close.sh" "$SLUG" 2>&1 | grep -q 'STATE shape'; then
  pass "assert-close forwards the assert-state soft-cap warning (200-line STATE)"
else
  bad "assert-close forwards the assert-state soft-cap warning (200-line STATE)"
fi
expect_ok "a bloated STATE warns but does not block close (soft, per law 10)" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"
cat "$WORK/state.bak" > "docs/work/$SLUG/STATE.md"
commit_all "restore thin STATE"

# 11c. A parked question must name a permanent home: parking defers the question,
#      and the folder it was parked in is deleted at close.
cat >> "docs/work/$SLUG/questions.md" <<'EOF'

### Q-003 — parked with nowhere to live
- **Status:** parked · **Priority:** P2 · **Opened:** 2026-01-01
- **Origin:** acceptance.sh
- **Question:** where does this question live after the folder is deleted?
- **Wake-up trigger:** the next time anyone touches the close gate.
EOF
commit_all "park a question with no home"
expect_fail "assert-close FAILS on a parked question with no permanent home" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"
printf -- '- **Home:** docs/adr/0001-strip-comment-regions.md (open questions)\n' \
  >> "docs/work/$SLUG/questions.md"
mkdir -p docs/adr
printf '# Permanent open questions\n\nQ-003: revisit close gate on next change.\n' > docs/adr/0001-strip-comment-regions.md
commit_all "give Q-003 a home"
expect_ok "assert-close PASSES once the parked question names its home" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

# 12. Hostile input: a slug that sanitises to nothing is refused, and nothing
#     is written outside docs/work/.
expect_fail "seed rejects a traversal-only slug ('../..')" \
  sh "$SCRIPTS/seed.sh" "../.."
if [ ! -e "$WORK/docs" ] && [ ! -e "$REPO/../docs" ]; then
  pass "hostile slug wrote nothing outside the repo"
else
  bad "hostile slug wrote nothing outside the repo"
fi
expect_fail "assert-started rejects a traversal-only slug" \
  sh "$SCRIPTS/assert-started.sh" "/../.."

# 13. stale-check argument validation.
expect_fail "stale-check rejects a non-numeric --days" \
  sh "$SCRIPTS/stale-check.sh" --days seven
expect_ok "stale-check runs with a numeric --days" \
  sh "$SCRIPTS/stale-check.sh" --days 21

# 14. Migration from a workbench-era repo: one convention survives, unrelated
#     rules are untouched, and a stale convention version is called out.
MIGRATED="$WORK/migrated"
init_repo "$MIGRATED"
mkdir -p docs/work
printf '# Task workbenches — the convention (v1.0)\n\nold laws\n' > docs/work/WORKBENCH.md
cat > CLAUDE.md <<'EOF'
# Repo rules

A pre-existing project rule.

<!-- workbench-convention -->
## Task workbenches

Active task state lives in `docs/work/<slug>/`. Conventions:
`docs/work/WORKBENCH.md` (workbenches are deleted at close).

## Unrelated trailing section

Keep me.
EOF
git add -A .
git commit -qm "workbench-era repo"
MIG_OUT=$(sh "$SCRIPTS/seed.sh" migrated-task "migration probe" 2>&1)

if [ -f docs/work/TOOLSHED.md ] && [ ! -e docs/work/WORKBENCH.md ]; then
  pass "seed renames docs/work/WORKBENCH.md to TOOLSHED.md"
else
  bad "seed renames docs/work/WORKBENCH.md to TOOLSHED.md"
fi
if printf '%s\n' "$MIG_OUT" | grep -q "v$VERSION_EXPECTED laws not applied"; then
  pass "seed warns that a migrated convention file predates v$VERSION_EXPECTED"
else
  bad "seed warns that a migrated convention file predates v$VERSION_EXPECTED"
fi
if ! grep -q 'workbench-convention' CLAUDE.md; then
  pass "seed prunes the legacy workbench-convention block from CLAUDE.md"
else
  bad "seed prunes the legacy workbench-convention block from CLAUDE.md"
fi
if [ "$(grep -c 'toolshed-convention' CLAUDE.md)" = "1" ] \
  && grep -q 'A pre-existing project rule' CLAUDE.md \
  && grep -q 'Keep me' CLAUDE.md; then
  pass "exactly one convention block remains and unrelated rules survive"
else
  bad "exactly one convention block remains and unrelated rules survive"
fi

# 15. The merged-commit gate (law 1). `git log -- path` on local history cannot
#     tell merged from unmerged: commits that only ever lived on the feature
#     branch are erased by squash-merge, which is the case law 1 names by name.
MERGE="$WORK/merge-gate"
init_repo "$MERGE"
git checkout -q -b feat/probe
sh "$SCRIPTS/seed.sh" "$SLUG" "merged-gate probe" >/dev/null 2>&1
rewrite 's|^_(not yet written)_$|Today: main carries no docs/work yet. Assumption: none. Unverified: nothing.|' \
  "docs/work/$SLUG/STATE.md"
commit_all "seed $SLUG on the feature branch only"

expect_fail "assert-close FAILS while the folder exists only on the feature branch" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"
if sh "$SCRIPTS/assert-close.sh" "$SLUG" 2>&1 | grep -q 'never reached main'; then
  pass "the failure names the squash-merge trap (never reached main)"
else
  bad "the failure names the squash-merge trap (never reached main)"
fi
expect_ok "--pr-body-confirmed waives the merged-commit gate" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG" --pr-body-confirmed
expect_ok "TOOLSHED_PR_BODY_CONFIRMED=1 waives it too" \
  env TOOLSHED_PR_BODY_CONFIRMED=1 sh "$SCRIPTS/assert-close.sh" "$SLUG"

git checkout -q main
git merge --squash feat/probe >/dev/null 2>&1
git commit -qm "squash-merge feat/probe (#1)"
git checkout -q feat/probe
expect_ok "assert-close PASSES once the folder reached main (squash-merged)" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG"

# 16. Reseed must preserve every existing index entry and unstaged user edit.
RESEED="$WORK/reseed"
init_repo "$RESEED"
sh "$SCRIPTS/seed.sh" "$SLUG" "original goal" >/dev/null 2>&1
commit_all "seed"
printf '\nuser evidence\n' >> "docs/work/$SLUG/evidence.md"
printf 'unrelated note\n' > "docs/work/$SLUG/unrelated.txt"
printf 'staged user change\n' >> README.md
git add README.md
INDEX_BEFORE=$(git diff --cached --binary)
sh "$SCRIPTS/seed.sh" "$SLUG" "different goal" >/dev/null 2>&1
if [ "$INDEX_BEFORE" = "$(git diff --cached --binary)" ] \
  && grep -q 'user evidence' "docs/work/$SLUG/evidence.md" \
  && grep -q 'unrelated note' "docs/work/$SLUG/unrelated.txt"; then
  pass "reseed preserves existing index and unrelated work"
else
  bad "reseed preserves existing index and unrelated work"
fi

# 17. Unknown default branch must fail unless the final PR body was attested.
UNKNOWN="$WORK/unknown-default"
init_repo "$UNKNOWN"
sh "$SCRIPTS/seed.sh" "$SLUG" "archive probe" >/dev/null 2>&1
rewrite 's|^_(not yet written)_$|Read: isolated fixture. Assumption: none. Unverified: none.|' \
  "docs/work/$SLUG/STATE.md"
commit_all "seed"
git branch -m experiment
expect_fail "unknown default branch fails closed" \
  env TOOLSHED_PR_BODY_CONFIRMED=0 sh "$SCRIPTS/assert-close.sh" "$SLUG"
expect_ok "explicit PR-body attestation can clear unknown default" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG" --pr-body-confirmed

# 18. A historical copy must not stand in for the final records.
git branch main
printf '\nfinal evidence\n' >> "docs/work/$SLUG/evidence.md"
commit_all "final evidence"
expect_fail "old default-branch snapshot cannot preserve final records" \
  env TOOLSHED_PR_BODY_CONFIRMED=0 sh "$SCRIPTS/assert-close.sh" "$SLUG"
expect_ok "read-back final PR-body attestation clears changed records" \
  sh "$SCRIPTS/assert-close.sh" "$SLUG" --pr-body-confirmed

if [ "$FAILED" -ne 0 ]; then
  echo "toolshed acceptance: FAILED"
  exit 1
fi
echo "toolshed acceptance: all steps passed"
