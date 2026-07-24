#!/bin/sh
# assert-state.sh — keep STATE.md a resume surface (soft for legacy bloat).
# Usage: assert-state.sh <slug> [--soft]
set -eu

SOFT=0
SLUG=""
for a in "$@"; do
  case "$a" in
    --soft) SOFT=1 ;;
    -*) echo "usage: assert-state.sh <slug> [--soft]" >&2; exit 2 ;;
    *) SLUG=$a ;;
  esac
done
[ -n "$SLUG" ] || { echo "usage: assert-state.sh <slug> [--soft]" >&2; exit 2; }

SLUG=$(printf '%s' "$SLUG" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\{1,\}/-/g; s/^-\{1,\}//; s/-\{1,\}$//')
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "assert-state: not inside a git repo" >&2; exit 1; }
STATE="$ROOT/docs/work/$SLUG/STATE.md"
MAX_LINES=120
fail() { echo "assert-state: FAIL — $*" >&2; exit 1; }
warn() { echo "assert-state: WARN — $*" >&2; }

[ -f "$STATE" ] || fail "missing $STATE"

LINES=$(wc -l < "$STATE" | tr -d ' ')
if [ "$LINES" -gt "$MAX_LINES" ]; then
  msg="STATE.md is ${LINES} lines (soft cap ${MAX_LINES}). Move ledgers to D/Q/E or packet.md — not STATE. Legacy trees: use --soft."
  if [ "$SOFT" -eq 1 ]; then warn "$msg"; else fail "$msg"; fi
fi

if grep -qE '^## Canonical closeout|^### [0-9]+\. Executive verdict|^## Structured work items|^### W-[0-9]+' "$STATE"; then
  msg="STATE.md contains full-packet / W-item dump. Move to packet.md or short Now/Next pointers."
  if [ "$SOFT" -eq 1 ]; then warn "$msg"; else fail "$msg"; fi
fi

if grep -qE '^#### E-[0-9]+|^## Complete evidence appendix' "$STATE"; then
  msg="STATE.md contains evidence appendix content. Evidence belongs in evidence.md or PR/CI."
  if [ "$SOFT" -eq 1 ]; then warn "$msg"; else fail "$msg"; fi
fi

echo "assert-state: OK — $SLUG (${LINES} lines)"
