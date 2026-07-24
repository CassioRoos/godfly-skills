# Bug Artifact Process

Use this reference whenever a MeanQA run finds product defects, the user asks for bug
metrics, or a prior bug needs revalidation.

Bug artifacts are executable QA work items. They are not Jira tickets and not loose
findings. A useful bug artifact tells the next operator what broke, why it matters, how
to reproduce it, what evidence is required, and what closes it.

This file is the canonical source for bug statuses, required fields, and classification
labels. Other skill files and run artifacts must reference these lists, not restate them.

## Lifecycle

Use repo equivalents when they exist; otherwise use these statuses:

- `open`: observed once and not yet triaged.
- `known-open`: same bug recurred and remains unfixed.
- `regression`: previously fixed or green behavior failed again.
- `fix-in-progress`: fix exists or is being validated, but QA has not proved it.
- `fixed-unverified`: code/PR claims a fix, but MeanQA has not rerun the bug flow.
- `fixed-verified`: MeanQA reran the bug flow and the required evidence passed.
- `duplicate`: same defect is tracked by another bug artifact; point at the canonical ID.
- `invalid`: the report turned out not to be a defect (wrong evidence, misread behavior,
  test-harness artifact). Record the disproving run and reasoning.
- `wontfix`: accepted product behavior, with owner/sign-off recorded.

Do not mark `fixed-verified` from code inspection, unit tests alone, a PR description, or
"it should be fixed now." That is vibes in a lab coat. Rerun the bug's validation plan
and attach evidence.

## Immutability And Location

Bug artifacts are permanent, append-only records. Statuses transition; documents never
disappear.

- The canonical artifact for each stable bug ID lives in the durable bug area: the
  repo's bug convention when one exists, otherwise `qa/bugs/` (or the repo's QA area)
  outside any run directory. Run directories link to it and append recurrence entries;
  they are never the only copy.
- Never delete a bug artifact. A report that was wrong becomes `invalid`; a redundant
  report becomes `duplicate` pointing at the canonical ID. Both keep their documents.
- Mutable fields: status, priority, severity, confidence, owner, latest-seen run,
  execution state, next execution step, and the append-only histories.
- Frozen after creation: bug ID, title, first-seen run, original symptom, original
  evidence links, and reproduction steps as originally observed. Corrections are
  appended as dated entries with a run ID, never edited in place.
- Every status change appends one history line: UTC date, run ID, old status, new
  status, evidence link, and reason. The artifact is its own audit log.

## Required Bug Fields

Every product bug artifact must include:

- stable bug ID,
- title,
- status,
- priority and severity or `untriaged`,
- confidence (`high`, `medium`, or `low`),
- classification,
- owner or `unassigned`,
- first-seen and latest-seen run IDs,
- environment and target surface,
- affected operations/endpoints/events,
- source flow/test ID,
- source finding when one exists,
- metric labels,
- symptom,
- impact/risk,
- expected behavior,
- actual behavior,
- reproduction steps,
- evidence links,
- required evidence layers to revalidate,
- suspected cause when known,
- validation plan,
- regression target,
- execution state and next execution step,
- recurrence history (append-only),
- status-change history (append-only).

## Execution Process

1. **Extract bugs from failures**: after each failed flow, split distinct product defects by
   symptom, affected surface, likely cause, and validation path. One failed flow can
   produce multiple bugs.
2. **Deduplicate first**: search existing bug indexes and recent artifacts by operation,
   class label, error text, symptom, and surface. Search in this order: the durable bug
   area and its index, then prior run directories under the repo's QA artifacts area,
   then the current run's `bugs/` links. If no prior index is reachable, state
   `no prior index found` in the artifact so the new ID is auditable. Reuse the stable
   ID when the same bug recurs.
3. **Classify**: decide whether it is product, backend, frontend, data, observability, or
   test-harness. Do not file product bugs for missing credentials, ambiguous fake scope,
   local runner failures, or skipped layers unless they reveal product breakage.
4. **Create/update the artifact**: fill every required field. If some field is unknown,
   write `unknown` and add it to the next execution step.
5. **Link it everywhere**: run-local `bugs/bug-index.md`, repo/global bug index when
   present, evidence table row, run summary, ledger artifact list, and source finding.
6. **Make it executable**: add a validation plan with exact flow, required evidence layers,
   expected pass condition, cleanup proof, and regression target.
7. **Execute open bugs first**: future QA runs should prioritize `regression`,
   `fixed-unverified`, and `open` bugs before broad exploratory sweeps.
8. **Close only with evidence**: update status to `fixed-verified` only after the bug's
   validation plan passes with linked UI/API/data/runtime evidence as required.
9. **Graduate regressions**: once fixed behavior is stable, add or update the repo's real
   regression test harness and link the spec/test path from the bug artifact.

## Bug Index Columns

Use these columns when the repo has no stronger index shape:

| Bug ID | Status | Priority | Severity | Confidence | Classification | Owner | Latest run | Next execution step | Artifact |
|---|---|---|---|---|---|---|---|---|---|

The index is the execution queue. If the next execution step is vague, the artifact is
not done.

## Revalidation Rules

Before rerunning a bug:

- read the bug artifact and source evidence,
- confirm the target environment and fake/safe scope,
- rerun the minimal flow that proves or disproves the bug,
- collect the same evidence layers that originally made the bug real,
- update latest-seen, recurrence history, status, and next execution step,
- update the ledger with `FIXED`, `REGRESSION`, `UNCHANGED`, or `BLOCKED`.

If a claimed fix changes the expected behavior, record the new expected behavior and the
source of that product decision. Do not silently rewrite the bug to make the fix look
better.
