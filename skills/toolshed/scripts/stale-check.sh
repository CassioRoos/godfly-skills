#!/bin/sh
# stale-check.sh — report toolsheds that look abandoned (freshness law).
#
# Usage: stale-check.sh [--days N] [--strict]
#
#   --days N    staleness threshold in days (default 21)
#   --strict    exit 1 when any toolshed is stale or uncommitted (CI mode)
#
# A toolshed is flagged when:
#   - its STATE.md has no commit newer than the threshold (falls back to file
#     mtime when the folder was never committed), or
#   - the folder has uncommitted/untracked changes (state living only on one
#     machine — the durability promise is broken until committed).
#
# Staleness is a smell, not a crime: resume it or close it.
# CI example (scheduled):
#   sh stale-check.sh --days 21 --strict
set -eu

DAYS=21
STRICT=0
usage() { echo "usage: stale-check.sh [--days N] [--strict]" >&2; exit 2; }
while [ $# -gt 0 ]; do
  case "$1" in
    --days)
      shift
      DAYS=${1:?--days needs a value}
      case "$DAYS" in
        ''|*[!0-9]*) echo "stale-check: --days must be a whole number of days (got '$DAYS')" >&2; usage ;;
      esac
      ;;
    --strict) STRICT=1 ;;
    *) usage ;;
  esac
  shift
done

ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "stale-check: not inside a git repo" >&2; exit 1; }
NOW=$(date +%s)
LIMIT=$((DAYS * 86400))
FLAGGED=0
FOUND=0

for STATE in "$ROOT"/docs/work/*/STATE.md; do
  [ -f "$STATE" ] || continue
  FOUND=1
  DIR=$(dirname "$STATE")
  SLUG=$(basename "$DIR")
  REL="docs/work/$SLUG"

  TS=$(git -C "$ROOT" log -1 --format=%ct -- "$REL" 2>/dev/null || true)
  SRC="last commit"
  DIRTY=0
  if [ -z "$TS" ]; then
    # Never committed — judge by mtime, and flag the durability gap loudly.
    if stat -f %m "$STATE" >/dev/null 2>&1; then TS=$(stat -f %m "$STATE"); else TS=$(stat -c %Y "$STATE"); fi
    SRC="mtime"
    echo "stale-check: WARN — $REL has ZERO commits (machine-local only); it dies with this machine" >&2
    FLAGGED=1; DIRTY=1
  elif [ -n "$(git -C "$ROOT" status --porcelain "$REL" 2>/dev/null)" ]; then
    echo "stale-check: WARN — $REL has uncommitted changes" >&2
    FLAGGED=1; DIRTY=1
  fi

  AGE=$(( (NOW - TS) / 86400 ))
  if [ $((NOW - TS)) -gt "$LIMIT" ]; then
    echo "stale-check: STALE — $REL untouched for ${AGE}d ($SRC, threshold ${DAYS}d) — resume it or close it" >&2
    FLAGGED=1
  elif [ "$DIRTY" -eq 0 ]; then
    echo "stale-check: ok — $REL (${AGE}d old, $SRC)"
  fi
done

[ "$FOUND" -eq 1 ] || { echo "stale-check: no toolsheds under docs/work/"; exit 0; }
if [ "$FLAGGED" -ne 0 ] && [ "$STRICT" -eq 1 ]; then
  exit 1
fi
exit 0
