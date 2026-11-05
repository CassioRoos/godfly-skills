#!/bin/sh
# Deterministic acceptance proof for start-proof.sh and pr-body.py.
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
START=$SCRIPT_DIR/start-proof.sh
TMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/mean-qa-proof.XXXXXX")
trap 'rm -rf -- "$TMP_ROOT"' EXIT HUP INT TERM

PROJECT=$TMP_ROOT/project
mkdir "$PROJECT"

grep -Fq 'scripts/start-proof.sh' "$SCRIPT_DIR/../SKILL.md"
grep -Fq 'scripts/start-proof.sh' "$SCRIPT_DIR/../references/publish.md"
grep -Fq 'scripts/pr-body.py' "$SCRIPT_DIR/../references/publish.md"

first=$(sh "$START" "$PROJECT" "Checkout Regression" "staging" "commit-abc123")
[ -s "$first" ]
[ -d "$(dirname -- "$first")/cases" ]
grep -Fq '**Verdict:** IN PROGRESS' "$first"
grep -Fq '**Head SHA:** commit-abc123 · **Environment:** staging' "$first"
grep -Fq '<!-- mean-qa:begin -->' "$first"
grep -Fq '<!-- mean-qa:end -->' "$first"
grep -Fq '| ID | Case | Expected | Result | Time | Evidence |' "$first"

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

# .proof/ is excluded through .git/info/exclude, never .gitignore, and only once.
REPO=$TMP_ROOT/repo
mkdir "$REPO"
git -C "$REPO" init -q
sh "$START" "$REPO" "excluded" "local" "sha1" >/dev/null 2>&1
grep -qxF '.proof/' "$REPO/.git/info/exclude"
[ ! -e "$REPO/.gitignore" ]
[ -z "$(git -C "$REPO" status --porcelain)" ]
sh "$START" "$REPO" "excluded-again" "local" "sha1" >/dev/null 2>&1
[ "$(grep -cxF '.proof/' "$REPO/.git/info/exclude")" -eq 1 ]

# pr-body.py: nothing lost, every part under the limit, the rest of the body kept.
BODY=$SCRIPT_DIR/pr-body.py
PB=$TMP_ROOT/prbody
mkdir "$PB"
python3 - "$PB" <<'PY'
import json, sys
d = sys.argv[1]
lines = ["<!-- mean-qa:begin -->", "## Verification (QA report)", "", "**Verdict:** SHIP", "",
         "Run dir /work/repo/.proof/x", "", "### Results", "| ID | Case | Expected | Result | Time | Evidence |", "|---|---|---|---|---|---|"]
lines += ["| TC-%02d | case %d | 200 | ✅ pass | 0.1s | [TC-%02d](#tc-%02d) |" % (i, i, i, i) for i in range(1, 42)]
lines += ["", "### Evidence", ""]
for i in range(1, 41):
    lines += ["#### TC-%02d — case %d" % (i, i), "", "<details><summary>TC-%02d</summary>" % i, "", "```bash",
              "# not a heading inside a fence", "curl -sS https://api.example.test/items/%d" % i, "```", "```json"]
    lines += json.dumps({"id": i, "rows": [{"n": n, "v": "x" * 40} for n in range(40)]}, indent=1).split("\n")
    lines += ["```", "</details>", "", "![TC-%02d screen](01-a.png)" % i, ""]
lines += ["#### TC-41 — huge payload", "", "<details><summary>TC-41</summary>", "", "```json"]
lines += json.dumps({"rows": [{"n": n, "v": "y" * 60} for n in range(2500)]}, indent=1).split("\n")
lines += ["Z" * 20000, "```", "</details>", ""]
lines += ["### Residual risk", "- tail stays in the body", "<!-- mean-qa:end -->"]
open(d + "/PROOF.md", "w").write("\n".join(lines) + "\n")
open(d + "/current.md", "w").write("## Summary\nKeep me\n\n<!-- mean-qa:begin -->\nold report\n<!-- mean-qa:end -->\n\n## Risk\nKeep me too\n")
PY
printf '01-a.png\thttps://example.test/a.png\n' > "$PB/images.tsv"
python3 "$BODY" --proof "$PB/PROOF.md" --pr-body "$PB/current.md" --images "$PB/images.tsv" \
  --root /work/repo --sha abc123 --out "$PB/out" >/dev/null
python3 - "$PB" <<'PY'
import glob, sys
d = sys.argv[1]
glen = lambda t: len(t.encode("utf-16-le")) // 2
body = open(d + "/out/body.md").read()
comments = [open(f).read() for f in sorted(glob.glob(d + "/out/comment-*.md"))]
assert len(comments) >= 2, "expected overflow comments"
for text in [body] + comments:
    assert glen(text) <= 65536, glen(text)
assert body.startswith("## Summary\nKeep me\n") and body.rstrip().endswith("## Risk\nKeep me too")
assert "old report" not in body and "/work/repo" not in body and "<repo root>" in body
assert "- tail stays in the body" in body
for text in [body] + comments:
    assert text.count("```") % 2 == 0, "unbalanced code fence"
    assert text.count("<details") == text.count("</details>"), "unbalanced details"
for n, text in enumerate(comments, 2):
    assert text.startswith("<!-- mean-qa:evidence %d/%d sha=abc123 -->" % (n, len(comments) + 1)), text[:80]
out = [l for t in [body] + comments for l in t.split("\n")]
src = open(d + "/PROOF.md").read().replace("/work/repo", "<repo root>").replace("](01-a.png)", "](https://example.test/a.png)")
for line in src.split("\n"):
    if line and len(line) <= 4000:
        assert out.count(line) >= src.split("\n").count(line) or line in out, "missing: " + line[:80]
assert "Z" * 20000 in "".join(out), "wrapped long line lost characters"
for i in range(1, 42):
    assert any("#### TC-%02d" % i in t for t in [body] + comments), i
PY
python3 "$BODY" --proof "$PB/PROOF.md" --pr-body "$PB/out/body.md" --images "$PB/images.tsv" \
  --root /work/repo --sha abc123 --out "$PB/again" >/dev/null
cmp -s "$PB/out/body.md" "$PB/again/body.md"
if python3 "$BODY" --proof "$PB/PROOF.md" --out "$PB/noimages" >/dev/null 2>&1; then
  echo "acceptance: unmapped local image unexpectedly succeeded" >&2
  exit 1
fi

echo "mean-qa acceptance: PASS"
