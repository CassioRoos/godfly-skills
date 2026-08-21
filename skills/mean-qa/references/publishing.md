# Publishing — where a run's evidence goes

Evidence nobody finds is evidence nobody used. **If you executed anything, this
file applies**: a run that touched a real system leaves a run directory, so there
is no version of an executed campaign that skips this. Skip it only for a
designed-but-not-run campaign, which by definition captured nothing.

## A repo convention beats this file — on repo facts

A repo-local QA contract wins on everything repo-specific: artifact locations,
ledger, status vocabulary, safety boundary. This skill wins on methodology. Where
the two **materially conflict** — a format this skill requires that the contract
forbids, a status list that disagrees, an artifact class the contract demands
that this skill would skip — do not silently pick one. **Ask once, then offer to
write the resolution into the repo contract** so no future run asks again. A
conflict resolved in chat and recorded nowhere is a conflict scheduled to recur.

## The run directory

It lives **at the root of the project under test** — the directory the work is
in, beside its `package.json`, `go.mod`, `pyproject.toml` or `.git`. Not a temp
directory, not a scratchpad, not your home. Evidence belongs where the person who
asked for it will look for it, and it must survive the session that made it.

```
<project-root>/
  .proof/                                 # gitignored
    2026-08-05-1430-romanian-locale/      # date-TIME-slug, so same-day runs order
      PROOF.md
      01-home-ro.png  02-…                # numbered in capture order
      cases/TC-104/{request-a.json,response-a.json,db-read-a.txt,notes.md}
  qa/bugs/                                # durable, survives run cleanup
```

- **Never write into `.proof/` itself.** A flat directory means every run's
  `PROOF.md` silently overwrites the last one, destroying evidence for work that
  already shipped.
- **The time in the directory name is not optional.** Dropping it is the same
  overwrite by a slower route: the second run today lands on the first one and
  the earlier evidence is gone.
- Slug from the target, not the date. Reuse the run's directory while iterating;
  new directory for a new target or a later day.
- **Images live at the run-directory root, numbered in capture order** — one flat
  sequence, so the reader can page through the run in the order it happened. A
  UI case's `cases/<id>/notes.md` names the images that belong to it rather than
  holding copies of them.
- **If the write is refused, do not abandon the capture.** Save to whatever path
  the tooling permits and move the files in afterwards. A run that finishes with
  its evidence only in the transcript has lost it.

## The document

Verdict first, then the flow in the order it happened, then payloads behind
`<details>`. Written for the engineer deciding whether to merge, not an auditor.

**Embed the screens; do not merely name them.** Every capture appears in the
document as `![what it shows](01-home-ro.png)` at the point it is used as
evidence — not as a filename mentioned in a sentence. A reader who has to go
open a directory to see what you saw has been handed a chore instead of proof,
and the whole reason the run directory is self-contained is that the document
*displays* the screens when someone reads it. Keep a short index table of every
image as well, but the index is the contents page, never the delivery.

**The screens that worked go in too.** Show the flow as it was driven — the
healthy states, the empty state, the validation error, the forbidden case, the
success — so a reader sees the surface that was covered and not only the places
it broke. Before-and-after pairs sit next to each other, so what changed is
visible without a second window.

````markdown
# <change> — QA proof
**Verdict:** SHIP / HOLD / CONDITIONAL — <the single blocking reason>
**Environment:** <env> · **Build under test:** <image/commit/marker>
**Run:** <date, window> · <n> cases

## Worst first
1. **<plain-language failure title>** — <what happens, to whom>

| # | Case | Expected | Result | Time | Evidence |
|---|------|----------|--------|------|----------|
| 1 | … | … | ✅ | 1.02s | [details](#1) |
| 5 | … | … | ❌ | 0.28s | [BUG-…-004] |

### 1 — <case>: HTTP 200 in 1.022992s
<details><summary>request / response</summary>

```bash
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' "…"
```
```json
{ … }
```
</details>

## Residual risk
- <what this run could not settle, as consequences rather than tasks>
````

Use ❌ rather than a silent omission for a case that failed — a missing row reads
as a case that passed.

**Residual risk is what earns trust.** Write items as consequences: "a full
checkout was not exercised — the seed product has no EUR price, so the flow stops
at the unavailable state" tells a reader what they are accepting. "TODO: test
checkout" does not. Never omit one to look cleaner; a reader who later finds an
omitted risk discounts everything else, permanently.

## Onto a PR

Upload images with the repo's image tooling, then write the verification section
into the PR body. Keep the run directory too — the PR section is a **view** of
it, never a separate account. If they disagree, the run directory is right.

- **State the final content only.** No revision markers, no "NEW:", no changelog
  inside a description. Git already tracks history.
- **Never hard-wrap the markdown source.** GitHub turns a single newline inside a
  paragraph into a line break, so column-wrapped source renders as a ragged
  narrow column. One source line per paragraph.
- Every sentence in the PR maps to an artifact in the run directory. If the
  directory cannot back it, delete it.

## Defects worth counting

When a repo tracks bugs, one artifact per **distinct** defect — not one per
failed flow, or the metrics turn to soup. Stable IDs that survive re-runs,
living in the durable area rather than inside a run directory that gets cleaned
up. Reuse an ID when the same defect recurs; a new ID only for a distinct
symptom, cause, or surface.
