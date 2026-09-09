#!/bin/sh
# Create a MeanQA run directory and its initial proof document as one publish.
#
# Usage:
#   sh start-proof.sh <project-root> <run-slug> <environment> <build>
set -eu
umask 077

usage() {
  echo "usage: start-proof.sh <project-root> <run-slug> <environment> <build>" >&2
  exit 2
}

[ "$#" -eq 4 ] || usage

PROJECT_ROOT=$(CDPATH= cd -- "$1" 2>/dev/null && pwd -P) || {
  echo "start-proof.sh: project root does not exist or is not accessible: $1" >&2
  exit 1
}

RAW_SLUG=$2
TITLE=$(printf '%s' "$RAW_SLUG" | tr '\r\n' '  ')
ENVIRONMENT=$(printf '%s' "$3" | tr '\r\n' '  ')
BUILD=$(printf '%s' "$4" | tr '\r\n' '  ')
SLUG=$(printf '%s' "$RAW_SLUG" |
  tr '[:upper:]' '[:lower:]' |
  sed 's/[^a-z0-9]\{1,\}/-/g; s/^-\{1,\}//; s/-\{1,\}$//')
[ -n "$SLUG" ] || usage

PROOF_ROOT=$PROJECT_ROOT/.proof
[ ! -L "$PROOF_ROOT" ] || { echo "start-proof.sh: .proof must not be a symlink" >&2; exit 1; }
mkdir -p "$PROOF_ROOT" || {
  echo "start-proof.sh: cannot create proof root: $PROOF_ROOT" >&2
  exit 1
}

STAMP=$(date '+%Y-%m-%d-%H%M')
NAME=$STAMP-$SLUG
SUFFIX=1
while [ -e "$PROOF_ROOT/$NAME" ] || ! mkdir "$PROOF_ROOT/.reserve-$NAME" 2>/dev/null; do
  [ "$SUFFIX" -lt 100 ] || {
    echo "start-proof.sh: cannot reserve a writable run directory after 100 attempts" >&2
    exit 1
  }
  SUFFIX=$((SUFFIX + 1))
  NAME=$STAMP-$SLUG-$SUFFIX
done

RESERVATION=$PROOF_ROOT/.reserve-$NAME
STAGING=$(mktemp -d "$PROOF_ROOT/.creating-$NAME.XXXXXX") || {
  rmdir "$RESERVATION" 2>/dev/null || true
  echo "start-proof.sh: cannot create staging directory under $PROOF_ROOT" >&2
  exit 1
}
FINAL=$PROOF_ROOT/$NAME

cleanup() {
  if [ -n "${STAGING:-}" ] && [ -d "$STAGING" ]; then
    rm -rf -- "$STAGING"
  fi
  if [ -n "${RESERVATION:-}" ] && [ -d "$RESERVATION" ]; then
    rmdir "$RESERVATION" 2>/dev/null || true
  fi
}
trap cleanup EXIT HUP INT TERM

STARTED=$(date '+%Y-%m-%dT%H:%M:%S%z')
mkdir "$STAGING/cases"
cat > "$STAGING/PROOF.md" <<EOF
# $TITLE — QA proof

**Verdict:** IN PROGRESS — coverage is incomplete
**Environment:** $ENVIRONMENT · **Build under test:** $BUILD
**Run started:** $STARTED · 0 cases

| # | Case | Expected | Result | Time | Evidence |
|---|---|---|---|---|---|

## Residual risk

- The run is still in progress and has no completed coverage yet.
EOF

if [ ! -s "$STAGING/PROOF.md" ]; then
  echo "start-proof.sh: initial PROOF.md is empty" >&2
  exit 1
fi

# STAGING and FINAL are on the same filesystem. The rename publishes the run
# directory and its non-empty PROOF.md together; no half-created run is visible.
mv "$STAGING" "$FINAL"
STAGING=
rmdir "$RESERVATION"
RESERVATION=
trap - EXIT HUP INT TERM

if [ ! -s "$FINAL/PROOF.md" ]; then
  echo "start-proof.sh: published PROOF.md failed read-back: $FINAL/PROOF.md" >&2
  exit 1
fi

printf '%s\n' "$FINAL/PROOF.md"
