#!/bin/sh
# assert-started.sh — Understanding gate is law (fail fast).
# Usage: assert-started.sh <slug>
set -eu

usage() { echo "usage: assert-started.sh <slug>" >&2; exit 2; }
[ $# -ge 1 ] || usage

SLUG=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\{1,\}/-/g; s/^-\{1,\}//; s/-\{1,\}$//')
ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "assert-started: not inside a git repo" >&2; exit 1; }
STATE="$ROOT/docs/work/$SLUG/STATE.md"

if [ ! -f "$STATE" ]; then
  echo "assert-started: FAIL — missing $STATE (seed first: toolshed seed.sh)" >&2
  exit 1
fi

if grep -qE '_\(not yet written\)_|Replace this placeholder during orient' "$STATE"; then
  echo "assert-started: FAIL — Understanding still template in $STATE" >&2
  echo "  orient before proposing. Fill exists (file:line), assumptions (rated), unverified." >&2
  exit 1
fi

if ! awk '
  /^## Understanding/ { in_u=1; next }
  /^## / && in_u { exit }
  in_u && NF && $0 !~ /^>/ && $0 !~ /^[[:space:]]*$/ { found=1 }
  END { exit found ? 0 : 1 }
' "$STATE"; then
  echo "assert-started: FAIL — Understanding section empty in $STATE" >&2
  exit 1
fi

echo "assert-started: OK — $SLUG"
