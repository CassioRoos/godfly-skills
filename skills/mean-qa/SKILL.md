---
name: mean-qa
description: Adversarial QA campaigns with persistent .proof evidence and re-runnable cases. Use to QA a feature, test a browser flow, verify a change or staging build, design a test campaign, or prepare a PR verification section. Local evidence is mandatory; publishing is a separate authorized action.
---

# MeanQA

Find defects a happy-path pass misses. Preserve what was actually tested,
including passing, failed, blocked, and interrupted work. Never confuse a test
plan with a run or a screenshot with working behavior.

## First action: create the proof

Every campaign gets `<project-root>/.proof/<timestamp-slug>/PROOF.md`,
including planning-only and blocked campaigns. Before HTTP/browser/database
probes or test execution, run:

```sh
sh <skill-dir>/scripts/start-proof.sh <project-root> <run-slug> <environment> <build>
```

Derive the project root from the app/service under test; honor a user-specified
artifact location. Use `unknown` for metadata not yet established. Read back
the returned document before any probe. The helper never overwrites an earlier
run and publishes a nonempty initial document. If you are only designing,
immediately mark it `DESIGNED — NOT RUN`; if blocked, record `BLOCKED`,
the failed prerequisite and next action. No empty "successful" report.

If creation fails, stop probes, report the refused path and use another
user-permitted persistent location if available. Never pretend the file exists.
This is deterministic **when invoked**, not a runtime hook: skill instructions
cannot guarantee capture if the agent bypasses them or is killed. An abandoned
`IN PROGRESS` report means incomplete, never pass.

Update the report and case artifacts after each meaningful case, before the next
one. Save the pre-change state before changing it. On normal completion record
the actual end time, verdict, coverage and remaining gaps; on interruption,
record `INCOMPLETE` if execution still permits a write. Do not overwrite earlier
runs or silently remove evidence. Keep .proof local/private; check ignore rules
before staging and never automatically commit its contents.

## Load only what the task needs

- Always read [findings.md](references/findings.md): oracle, false-positive
  control and honest verdicts.
- Planning: read [attack.md](references/attack.md) and
  [cases.md](references/cases.md). Mark every proposed case not run.
- Execution: read [environment.md](references/environment.md) and
  [evidence.md](references/evidence.md) before probing. Add attack/cases when
  designing new cases, not when simply re-running existing ones.
- Report formatting: read [report.md](references/report.md) when writing the
  completed report.
- External publishing only: read [publishing.md](references/publishing.md)
  once publishing is requested or already authorized. A PR existing, or a
  request to verify a PR, does not authorize uploads, comments or body edits.

## Four questions before the happy path

1. When a dependency cannot answer, what value does it return and how does
   the caller distinguish failure from "nothing found"? Trace error channels;
   do not assume the absence of an error return means success.
2. What is the harm in both directions — wrongful action and wrongful denial?
3. What invariant must always hold, and what sequence breaks it? Check
   conserved value, one intent/one effect, legal transitions and ownership.
4. What is irreversible — charges, disclosures, notifications, deletion?
   Prioritize by consequence and recoverability, not convenient tests.

Then run applicable cheap probes against in-scope, authorized test targets:
malformed input, wrong types, missing/extra fields, untrusted client values,
boundaries, duplicate/concurrent requests and unauthorized identities.
Record skipped or unavailable probes with the coverage consequence.
A mandate to test never authorizes a production mutation or another tenant.

Predict the oracle and fails-if condition before each case. Use stable case
IDs, exact sanitized inputs, observed outcome and a repeatable reproduction.
A surprising intentional policy is a policy question, not automatically a bug.
Rank findings by demonstrated consequence; name unknown causes as unknown.
Run the relevant baseline before an authorized fix and the same proof plus
focused regressions afterward. QA alone does not authorize fixing.

## Evidence volume without token waste

Capture as much **relevant, safe, nonduplicative evidence** as available:
commands and exit codes, requests/responses with timings, direct persistence
reads, logs/traces, browser steps, before/after screenshots, console/network,
head/build identity and environment scope. Mark unavailable channels explicitly;
missing telemetry is not a clean result. Synthetic fixtures first.

Keep complete sanitized captures in `cases/<id>/`; give every results row a
matching evidence block with observation, decisive excerpt and links to complete
files. Embed screenshots in the report. Do not paste large bodies repeatedly
into the report or conversation. Preserve every executed case, not merely a
sample. Cap oversized/continuous captures with an explicit bound and truncation
notice; never claim an uncaptured remainder was preserved.

Keep tool output bounded: inspect indexed files and targeted excerpts; don't
re-read all logs or full reports after each append. Chat gets findings, coverage,
gaps and a proof link. More evidence on disk need not mean more model tokens.
Report measured usage only if exposed by the runtime; otherwise label token
estimates and do not invent a dollar cost.

## Safety and finish

Never print, extract, paste or persist credentials, session cookies, auth
headers or personal data. Redact before writing or displaying artifacts;
screenshots and network bodies can leak secrets too. If safe capture is
impossible, retain sanitized observations and mark the resulting proof gap.

An unknown environment is production. Production stays bounded/read-only under
the user's applicable confirmation rules. Prove a mutation target is synthetic
and the action authorized before using it. Do not switch accounts, log the user
out, change global browser configuration, or publish evidence just to finish QA.

Before finishing, check each row has real, readable evidence files, all image
links resolve, and the report matches what ran. Leave user tabs/sessions intact;
clean up only resources created for this run. State what was not tested.
A stakeholder's risk acceptance is separate from the evidence-based verdict.
