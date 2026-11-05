# Publish — the report, on the PR and on disk

The PR is the record. When the change has a PR, the full report goes in the PR body: every command, request, response, payload, query and screenshot. Overflow goes to numbered PR comments. Nothing is dropped, sampled or summarised away.

The run directory `.proof/<date-time-slug>/` is the working copy. It holds the complete files and makes each case replayable. It is local, so it is never the only copy of a result. A run in a disposable worktree dies with the worktree; the PR keeps it.

With no PR, PROOF.md in the run directory is the report. A user who asks for local-only QA gets local-only QA.

## 1. The run directory

- `scripts/start-proof.sh` creates it, writes PROOF.md, and adds `.proof/` to the repository's `.git/info/exclude`. It never edits `.gitignore`, so the PR diff stays clean. Never commit `.proof/`.
- One directory per run: `<project-root>/.proof/2026-11-05-1430Z-approve-guard/`. The script refuses to reuse a name. Reuse the same directory only while iterating on the same target the same day.
- Write each case into PROOF.md as it finishes, before the next case starts. A run cut short still leaves a readable report; its verdict reads `INCOMPLETE — stopped after TC-07`.
- Read the run window from the clock and the file times. Never estimate it afterwards.

## 2. The report

PROOF.md and the PR section are the same text. Keep the markers; the publish script uses them.

````markdown
<!-- mean-qa:begin -->
## Verification (QA report)

**Verdict:** HOLD — a paid expense can be approved again (TC-04)
**Target:** PR #128 · **Head SHA:** 2e195b2 · **Environment:** staging
**Build under test:** api:v0.3.13 (commit 2e195b2), boot log "config v2"
**Run:** 2026-11-05 14:30–15:10 UTC · 12 cases: 9 ✅ pass, 2 ❌ fail, 1 ⛔ blocked

### Worst first
1. **A paid expense can be approved again.** Finance pays it twice in the next pay run. [TC-04](#tc-04)

### Gaps in the change
- **GAP-1 — …** (shape in gaps.md)

### Requirements trace
| AC | Criterion (quoted) | Cases | Status |
|---|---|---|---|

### How this was tested
<What was seeded, which flows ran in which order, what each phase tried to break, and what changed course. Three or four short paragraphs.>

### Results
| ID | Case | Expected | Result | Time | Evidence |
|---|---|---|---|---|---|
| TC-04 | Approve a paid expense | 409, row unchanged | ❌ fail | 0.03s | [TC-04](#tc-04) |

### Evidence

#### TC-04 — A paid expense can be approved again
**Expected:** 409, row unchanged. **Observed:** 200, status back to `approved`. **Oracle:** spec §3 "paid is terminal". **Why:** `approve()` writes the status with no guard on the current one. **Cost:** a double payment. **Head SHA:** 2e195b2.

<details><summary>TC-04 · ❌ fail · HTTP 200 in 0.031s</summary>

```bash
curl -sS -X POST -w '\nHTTP %{http_code} in %{time_total}s\n' -H "Authorization: Bearer $TOKEN" "$BASE/expenses/exp-7f21/approve"
```
```json
{"id":"exp-7f21","status":"approved","paid_at":"2026-08-07T09:14:02Z"}
```
```text
HTTP 200 in 0.031s
```
```text
$ psql -c "select id,status,paid_at from expenses where id='exp-7f21'"
exp-7f21 | approved | 2026-08-07 09:14:02+00
```
</details>

![TC-04: approve dialog at 390px, Confirm in frame](03-approve-dialog-390.png)

### Regression
| Gate | Command | Result |
|---|---|---|

### Coverage — not reached
| State or surface | Why not | What it leaves open |
|---|---|---|

### Residual risk
- <What a reader accepts, written as a consequence: "A full pay run was not exercised: the sandbox rejects the fixture card, so the settle path stops at authorisation.">

### Questions
- <Things the run could not settle, each with who can answer.>

### Assumptions
- <Subagent runs only: assumptions that could change the verdict.>
<!-- mean-qa:end -->
````

Rules for the report:

1. **Every case gets an evidence block**, passes included. Twelve rows means twelve `####` blocks. Count them.
2. **Every block carries the literal capture**: the exact command, the full response body, the status and the time; the direct read; console and network for UI steps. Collapse long captures in `<details>`; never shorten them.
3. **Embed every screenshot** at the point it is evidence, healthy screens included. Before and after sit next to each other.
4. **A failed case is a ❌ row,** never a missing row.
5. **Omit a section only when it has nothing in it.** Coverage, residual risk and the regression gates are never empty on an executed run.
6. **Final content only.** No revision markers, no "updated", no changelog.
7. **One source line per paragraph.** GitHub renders a newline inside a paragraph as a line break.
8. **The deliverable never names this skill or its internal terms.** The reader wants the risk.

## 3. Put it on the PR

GitHub rejects a PR body or comment over 65,536 characters. `scripts/pr-body.py` handles the split and proves nothing was lost.

1. **Upload the screenshots.** Use the repo's uploader, or the `gh image` extension with its default sign-in. Never print, extract or paste a session token. Map each file to its URL:

   ```bash
   cd <run-dir>; mkdir -p pr
   for f in [0-9]*.png; do printf '%s\t%s\n' "$f" "$(gh image "$f" | sed -n 's/.*(\(http[^)]*\)).*/\1/p')"; done > pr/images.tsv
   ```

   If upload is not possible, mark the images `⛔ blocked` in the report and tell the user. Never publish a PR body that links local files.
2. **Fetch the current body:** `gh pr view <n> --json body -q .body > pr/current.md`
3. **Build the body and the overflow comments:**

   ```bash
   python3 <skill-dir>/scripts/pr-body.py --proof PROOF.md --pr-body pr/current.md \
     --images pr/images.tsv --root <absolute repo path> --sha <head-sha> --out pr/
   ```

   Leave out `--images` when the run has no screenshots. The script replaces the text between the markers and keeps the rest of the body. It fills the body with the report and as many evidence blocks as fit, in order. The rest go to `pr/comment-02.md`, `pr/comment-03.md`, …, each under the limit; a capture too big for one comment is split across several with its code fences and `<details>` re-opened. It replaces local image names with URLs, and the repo path with `<repo root>`. It exits non-zero if any line of the report is missing from the output, or if a local image has no URL.
4. **Write the body:** `gh pr edit <n> --body-file pr/body.md`
5. **Write the comments.** Update the existing evidence comments in place; create only the missing ones:

   ```bash
   gh api "repos/{owner}/{repo}/issues/<n>/comments" --paginate \
     -q '.[] | select(.body | startswith("<!-- mean-qa:evidence")) | [.id, (.body | split("\n")[0])] | @tsv'
   gh api -X PATCH "repos/{owner}/{repo}/issues/comments/<id>" -F body=@pr/comment-02.md   # exists
   gh pr comment <n> --body-file pr/comment-03.md                                      # new
   ```

   An old evidence comment the new run no longer needs gets its body replaced with `<!-- mean-qa:evidence superseded -->` and one line saying the current report is in the PR body. Never delete comments.
6. **Read it back.** Fetch the body and each comment. Check the verdict line, the case count and that every image URL loads. Report the PR link and the comment links in chat.

A new push to the PR makes the report stale. Re-run the cases on the new head SHA and publish again.

## 4. A repo's own QA contract wins on repo facts

A repo-local QA contract decides artifact locations, status words and safety limits for that repo. This skill decides method. When the two conflict, ask once, then offer to write the answer into the repo contract.

## 5. Defects worth tracking

When a repo tracks bugs, file one issue per distinct defect, not one per failed case. Reuse the ID when the same defect recurs.
