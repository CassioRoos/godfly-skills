#!/bin/sh
# seed.sh — seed a toolshed (task state) in the current git repo.
#
# Usage:  seed.sh <slug|TICKET-123> ["one-line goal"]
#
# Idempotent and add-only: never overwrites an existing file. Creates
#   docs/work/TOOLSHED.md             (once per repo — the convention)
#   docs/work/<slug>/{STATE,decisions,questions,evidence}.md
# and appends a marker-guarded pointer block to CLAUDE.md and AGENTS.md —
# announced, never staged: root rules files are the user's to review and commit.
# Only the docs/work/ files this script created are staged.
# Migrates a legacy docs/work/WORKBENCH.md convention file to TOOLSHED.md.
# Model-agnostic: no Claude/Codex dependency — plain POSIX sh + git.
set -eu

VERSION="2.1"
MARK="<!-- toolshed-convention -->"
LEGACY_MARK="<!-- workbench-convention -->"
usage() { echo "usage: seed.sh <slug|TICKET-123> [\"one-line goal\"]" >&2; exit 1; }
[ $# -ge 1 ] || usage

RAW="$1"
GOAL="${2:-"(fill in: one-line goal)"}"

TICKET=""
if printf '%s' "$RAW" | grep -Eq '^[A-Za-z]+-[0-9]+$'; then
  TICKET=$(printf '%s' "$RAW" | tr '[:lower:]' '[:upper:]')
fi
SLUG=$(printf '%s' "$RAW" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\{1,\}/-/g; s/^-\{1,\}//; s/-\{1,\}$//')
[ -n "$SLUG" ] || usage

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "seed.sh: not inside a git repo" >&2; exit 1; }
REPO=$(basename "$ROOT")
DATE=$(date +%Y-%m-%d)
TPL=$(CDPATH= cd -- "$(dirname -- "$0")/../templates" && pwd)
DEST="$ROOT/docs/work/$SLUG"
CREATED=""
STATE_CREATED=0

render() {
  [ -e "$2" ] && { echo "  keep   ${2#"$ROOT"/} (exists)"; return 0; }
  mkdir -p "$(dirname "$2")"
  sed -e "s|{{SLUG}}|$SLUG|g" -e "s|{{DATE}}|$DATE|g" -e "s|{{REPO}}|$REPO|g" \
      -e "s|{{VERSION}}|$VERSION|g" -e "s|{{GOAL}}|$(printf '%s' "$GOAL" | sed 's/[|&\\]/\\&/g')|g" \
      "$1" > "$2"
  CREATED="${CREATED}${2#"$ROOT"/}
"
  [ "$2" != "$DEST/STATE.md" ] || STATE_CREATED=1
  echo "  seed   ${2#"$ROOT"/}"
}

echo "toolshed: seeding '$SLUG' in $REPO (convention v$VERSION)"

# Migrate legacy convention filename (workbench-era) before rendering.
LEGACY_CONV="$ROOT/docs/work/WORKBENCH.md"
CONV="$ROOT/docs/work/TOOLSHED.md"
if [ -e "$LEGACY_CONV" ] && [ ! -e "$CONV" ]; then
  # A rename can carry pre-existing edits. Leave both sides unstaged.
  mv "$LEGACY_CONV" "$CONV"
  echo "  review legacy rename separately; existing index entries are unchanged"
  echo "  move   docs/work/WORKBENCH.md -> docs/work/TOOLSHED.md (legacy rename)"
elif [ -e "$LEGACY_CONV" ] && [ -e "$CONV" ]; then
  echo "  WARN   both docs/work/WORKBENCH.md and docs/work/TOOLSHED.md exist —" >&2
  echo "         two conventions in one repo. Merge into TOOLSHED.md and delete" >&2
  echo "         WORKBENCH.md before anyone reads the wrong one." >&2
fi

# The rename moves the file; it does NOT upgrade its text. A migrated (or
# hand-written) convention file can still be stamped with an older version.
if [ -e "$CONV" ]; then
  FOUND_V=$(sed -n '1,5s/.*(v\([0-9][0-9.]*\)).*/\1/p' "$CONV" | sed -n 1p)
  if [ "$FOUND_V" != "$VERSION" ]; then
    echo "  WARN   docs/work/TOOLSHED.md is convention v${FOUND_V:-unknown}, not v$VERSION:" >&2
    echo "         v$VERSION laws not applied — re-seed or diff against templates/TOOLSHED.md" >&2
  fi
fi

for F in CLAUDE.md AGENTS.md; do
  P="$ROOT/$F"
  [ -e "$P" ] || continue
  # Drop any workbench-era pointer block: a migrated repo carrying both blocks
  # states two contradictory conventions. The block spans its marker, its own
  # heading, and its prose — up to the next marker/heading or EOF.
  if grep -qF "$LEGACY_MARK" "$P"; then
    TMP=$(mktemp)
    awk -v mark="$LEGACY_MARK" '
      index($0, mark) == 1 { del = 1; own = 0; next }
      del && /^<!--/ { del = 0 }
      del && /^#+ / { if (own) { del = 0 } else { own = 1; next } }
      del { next }
      /^[[:space:]]*$/ { pending++; next }
      { while (pending > 0) { print ""; pending-- } print }
    ' "$P" > "$TMP" && cat "$TMP" > "$P"
    rm -f "$TMP"
    echo "  prune  $F (removed legacy workbench-convention block)"
  fi
  if grep -q 'docs/work/WORKBENCH\.md' "$P"; then
    TMP=$(mktemp)
    sed 's|docs/work/WORKBENCH\.md|docs/work/TOOLSHED.md|g' "$P" > "$TMP" && cat "$TMP" > "$P"
    rm -f "$TMP"
    echo "  fix    $F (pointer -> TOOLSHED.md)"
  fi
done

render "$TPL/TOOLSHED.md" "$ROOT/docs/work/TOOLSHED.md"
render "$TPL/STATE.md"     "$DEST/STATE.md"
render "$TPL/decisions.md" "$DEST/decisions.md"
render "$TPL/questions.md" "$DEST/questions.md"
render "$TPL/evidence.md"  "$DEST/evidence.md"

if [ -n "$TICKET" ] && [ "$STATE_CREATED" -eq 1 ]; then
  TMP=$(mktemp)
  sed "s|_none yet — attach here if/when one exists_|$TICKET|" "$DEST/STATE.md" > "$TMP" \
    && cat "$TMP" > "$DEST/STATE.md"
  rm -f "$TMP"
fi

for F in CLAUDE.md AGENTS.md; do
  P="$ROOT/$F"
  if [ -e "$P" ] && grep -qF "$MARK" "$P"; then
    echo "  keep   $F (pointer present)"
    continue
  fi
  # Test existence BEFORE the append: `>>` creates the file, so testing inside
  # the group put a leading blank line at the top of every new rules file.
  EXISTED=0
  [ -e "$P" ] && EXISTED=1
  {
    if [ "$EXISTED" -eq 1 ]; then printf '\n'; fi
    printf '%s\n' "$MARK" \
      "## Task toolsheds" \
      "" \
      "Active task state lives in \`docs/work/<slug>/\` — **read its STATE.md" \
      "first**, then work the records (decisions/questions/evidence). Skill:" \
      "**toolshed** (\`/toolshed\`). Conventions: \`docs/work/TOOLSHED.md\`." \
      "Laws: mortal (deleted at close); deliverables = ADRs/specs/RFCs;" \
      "contracts promote immediately; upsert-only records; evidence grades +" \
      "reproduction commands (or PR/CI pointers); no PII; Understanding before" \
      "proposal (\`assert-started.sh\`); thin session-end (not full packet by default)." \
      "" \
      "**Not the Workbench product/MCP** (Slack/highlights app)."
  } >> "$P"
  if [ "$EXISTED" -eq 1 ]; then
    echo "  point  $F — updated (pointer block appended); review and stage yourself"
  else
    echo "  NEW    $F CREATED at the repo root — this is the rules file agents read" >&2
    echo "         on every session. It is NOT staged: review it and stage yourself." >&2
  fi
done

# Stage only what this script created inside docs/work/. CLAUDE.md / AGENTS.md
# are the user's repo-root rules files: seeding a toolshed does not get to put
# them in someone's commit.
printf '%s' "$CREATED" | while IFS= read -r created; do
  [ -n "$created" ] || continue
  if ! git -C "$ROOT" add -- "$created"; then
    echo "  warn   could not stage $created — review and stage manually" >&2
  fi
done

if git -C "$ROOT" check-ignore -q "docs/work/$SLUG/STATE.md" 2>/dev/null; then
  echo "  WARN   docs/work/ is gitignored — toolshed is machine-local only." >&2
  echo "         Prefer PR/permanent docs for durable evidence while ignored." >&2
fi

echo "toolshed: ready — fill docs/work/$SLUG/STATE.md Understanding, then:"
echo "  sh $(dirname "$0")/assert-started.sh $SLUG"
