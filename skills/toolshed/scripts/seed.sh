#!/bin/sh
# seed.sh — seed a toolshed (task state) in the current git repo.
#
# Usage:  seed.sh <slug|TICKET-123> ["one-line goal"]
#
# Idempotent and add-only: never overwrites an existing file. Creates
#   docs/work/WORKBENCH.md            (once per repo — the convention)
#   docs/work/<slug>/{STATE,decisions,questions,evidence}.md
# and appends a marker-guarded pointer block to CLAUDE.md and AGENTS.md.
# Model-agnostic: no Claude/Codex dependency — plain POSIX sh + git.
set -eu

VERSION="2.0"
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

render() {
  [ -e "$2" ] && { echo "  keep   ${2#"$ROOT"/} (exists)"; return 0; }
  mkdir -p "$(dirname "$2")"
  sed -e "s|{{SLUG}}|$SLUG|g" -e "s|{{DATE}}|$DATE|g" -e "s|{{REPO}}|$REPO|g" \
      -e "s|{{VERSION}}|$VERSION|g" -e "s|{{GOAL}}|$(printf '%s' "$GOAL" | sed 's/[|&\\]/\\&/g')|g" \
      "$1" > "$2"
  echo "  seed   ${2#"$ROOT"/}"
}

echo "toolshed: seeding '$SLUG' in $REPO (convention v$VERSION)"
render "$TPL/WORKBENCH.md" "$ROOT/docs/work/WORKBENCH.md"
render "$TPL/STATE.md"     "$DEST/STATE.md"
render "$TPL/decisions.md" "$DEST/decisions.md"
render "$TPL/questions.md" "$DEST/questions.md"
render "$TPL/evidence.md"  "$DEST/evidence.md"

if [ -n "$TICKET" ]; then
  sed "s|_none yet — attach here if/when one exists_|$TICKET|" "$DEST/STATE.md" > "$DEST/STATE.md.tmp" \
    && mv "$DEST/STATE.md.tmp" "$DEST/STATE.md"
fi

MARK="<!-- toolshed-convention -->"
# Migrate old workbench marker if present alone — still add toolshed marker once.
for F in CLAUDE.md AGENTS.md; do
  P="$ROOT/$F"
  if [ -e "$P" ] && grep -qF "$MARK" "$P"; then
    echo "  keep   $F (pointer present)"
    continue
  fi
  {
    [ -e "$P" ] && printf '\n'
    printf '%s\n' "$MARK" \
      "## Task toolsheds" \
      "" \
      "Active task state lives in \`docs/work/<slug>/\` — **read its STATE.md" \
      "first**, then work the records (decisions/questions/evidence). Skill:" \
      "**toolshed** (\`/toolshed\`). Conventions: \`docs/work/WORKBENCH.md\`." \
      "Laws: mortal (deleted at close); deliverables = ADRs/specs/RFCs;" \
      "contracts promote immediately; upsert-only records; evidence grades +" \
      "reproduction commands (or PR/CI pointers); no PII; Understanding before" \
      "proposal (\`assert-started.sh\`); thin session-end (not full packet by default)." \
      "" \
      "**Not the Workbench product/MCP** (Slack/highlights app)."
  } >> "$P"
  echo "  point  $F"
done

if ! ( cd "$ROOT" && git add docs/work/WORKBENCH.md "docs/work/$SLUG" CLAUDE.md AGENTS.md 2>/dev/null ); then
  echo "  warn   git add failed or paths ignored — stage manually if tracked" >&2
fi

if git -C "$ROOT" check-ignore -q "docs/work/$SLUG/STATE.md" 2>/dev/null; then
  echo "  WARN   docs/work/ is gitignored — toolshed is machine-local only." >&2
  echo "         Prefer PR/permanent docs for durable evidence while ignored." >&2
fi

echo "toolshed: ready — fill docs/work/$SLUG/STATE.md Understanding, then:"
echo "  sh $(dirname "$0")/assert-started.sh $SLUG"
