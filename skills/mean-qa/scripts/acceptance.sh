#!/bin/sh
# Deterministic acceptance proof for start-proof.sh.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
START=$SCRIPT_DIR/start-proof.sh
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/mean-qa-proof.XXXXXX")
trap 'rm -rf -- "$TMP_ROOT"' EXIT HUP INT TERM

PROJECT=$TMP_ROOT/project
mkdir "$PROJECT"

grep -Fq 'scripts/start-proof.sh' "$SCRIPT_DIR/../SKILL.md"
grep -Fq 'scripts/start-proof.sh' "$SCRIPT_DIR/../references/publishing.md"

first=$(sh "$START" "$PROJECT" "Checkout Regression" "staging" "commit-abc123")
[ -s "$first" ]
[ -d "$(dirname -- "$first")/cases" ]
grep -Fq '**Verdict:** IN PROGRESS' "$first"
grep -Fq '**Environment:** staging · **Build under test:** commit-abc123' "$first"
grep -Fq '| # | Case | Expected | Result | Time | Evidence |' "$first"

second=$(sh "$START" "$PROJECT" "Checkout Regression" "staging" "commit-def456")
[ -s "$second" ]
[ "$first" != "$second" ]

sh "$START" "$PROJECT" "Concurrent Run" "staging" "commit-concurrent-a" > "$TMP_ROOT/concurrent-a.out" &
pid_a=$!
sh "$START" "$PROJECT" "Concurrent Run" "staging" "commit-concurrent-b" > "$TMP_ROOT/concurrent-b.out" &
pid_b=$!
wait "$pid_a"
wait "$pid_b"
concurrent_a=$(sed -n '1p' "$TMP_ROOT/concurrent-a.out")
concurrent_b=$(sed -n '1p' "$TMP_ROOT/concurrent-b.out")
[ -s "$concurrent_a" ]
[ -s "$concurrent_b" ]
[ "$concurrent_a" != "$concurrent_b" ]

unsafe='$(touch should-not-exist)'
third=$(sh "$START" "$PROJECT" "Special / Run" "$unsafe" "$unsafe")
[ -s "$third" ]
[ ! -e "$PROJECT/should-not-exist" ]
grep -Fq "$unsafe" "$third"

if sh "$START" "$TMP_ROOT/missing" "must-fail" "local" "none" >/dev/null 2>&1; then
  echo "acceptance: nonexistent project root unexpectedly succeeded" >&2
  exit 1
fi

BLOCKED=$TMP_ROOT/blocked
mkdir "$BLOCKED"
: > "$BLOCKED/.proof"
if sh "$START" "$BLOCKED" "must-fail" "local" "none" >/dev/null 2>&1; then
  echo "acceptance: blocked proof root unexpectedly succeeded" >&2
  exit 1
fi

if find "$PROJECT/.proof" -maxdepth 1 -type d \( -name '.creating-*' -o -name '.reserve-*' \) | grep -q .; then
  echo "acceptance: bootstrap leaked staging or reservation directories" >&2
  exit 1
fi

count=$(find "$PROJECT/.proof" -mindepth 2 -maxdepth 2 -name PROOF.md -type f | wc -l | tr -d ' ')
[ "$count" -eq 5 ]

LINKED=$TMP_ROOT/linked
mkdir "$LINKED" "$TMP_ROOT/outside"
ln -s "$TMP_ROOT/outside" "$LINKED/.proof"
if sh "$START" "$LINKED" "must-fail" "local" "none" >/dev/null 2>&1; then
  echo "acceptance: symlinked proof root unexpectedly succeeded" >&2
  exit 1
fi
[ -z "$(ls -A "$TMP_ROOT/outside")" ]

# Metadata can be unknown before connectivity/auth is established.
blocked=$(sh "$START" "$PROJECT" "blocked-run" "unknown" "unknown")
[ -s "$blocked" ]
grep -Fq '**Verdict:** IN PROGRESS' "$blocked"
grep -Fq 'unknown' "$blocked"

echo "mean-qa proof bootstrap acceptance: PASS"
