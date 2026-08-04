# Artifacts And Ledger

MeanQA evidence must be resumable, auditable, and sanitized.

## Artifact Plan

Artifacts are addressed **by case ID** -- `cases/<TC-ID>/` -- so any finding,
ledger row, or later re-run can demand the exact evidence for one case. The
per-case retention table and the sanitise-on-write rule live in
[test-cases.md](test-cases.md); this file covers run-level packaging.

Before execution, identify where the repo expects run artifacts. If no convention exists, propose a run directory under a QA/artifacts area and ask before writing repo files.

Capture:

- run summary,
- evidence table,
- per-test or per-flow ledger rows when the repo has a ledger,
- before/after screenshots for every screen-checked flow,
- screenshots/traces/network captures or sanitized extracts,
- sanitized endpoint inputs and outputs,
- create/update/delete data-effect summaries when persistence is touched,
- event/broker summaries when events are touched,
- test commands and decisive output,
- API/gRPC/broker payload shapes,
- read-only DB results,
- logs/traces/metrics query summaries,
- bug index and one bug artifact per distinct product defect,
- findings for broader analysis and non-bug observations,
- blockers and skipped flows.

## Generated Evidence Pack

Prefer a small, navigable documentation pack over scattered artifacts. Follow repo conventions when present; otherwise use this shape:

```text
<run-id>/
├── run-summary.md
├── evidence-table.md
├── test-evidence.md
├── bugs/
│   └── bug-index.md
├── findings/
│   └── <finding-id>.md
└── <flow-id>/
    ├── before.png
    ├── after.png
    ├── network.md
    ├── console.md
    ├── data.md
    ├── runtime.md
    └── hardening-<case>.md
```

Canonical bug artifacts do not live inside the run directory. They live in the durable bug area (`qa/bugs/` or the repo equivalent) so they survive run cleanup; the run-local `bugs/bug-index.md` links to them and records this run's recurrence/status entries. See the Immutability And Location rules in [bug-artifact-process.md](bug-artifact-process.md).

If the repo uses a different artifact shape, obey it. The invariant is reviewability: another engineer should understand what was tested, what evidence exists, what failed, what is countable as a bug, and what remains unproven without re-running the whole sweep.

## Bug Artifacts

Create a bug artifact for every distinct product defect found by the run. Do not collapse multiple defects into one artifact just because they came from the same failed flow; that is how metrics turn into soup. Do not use product bug artifacts for local runner breakage, missing credentials, ambiguous product questions, or skipped/unproven layers unless they expose a real product defect.

For the full lifecycle, execution process, required fields, index columns, and revalidation rules, read [bug-artifact-process.md](bug-artifact-process.md).

Bug artifacts are permanent, append-only records: once created, only status and the other mutable fields defined in [bug-artifact-process.md](bug-artifact-process.md) change, and the document is never deleted. Use a stable ID that can survive re-runs, such as `BUG-CUSTOMER-UI-001`, and keep the canonical artifacts plus index in the durable bug area:

```text
qa/bugs/
├── bug-index.md
└── BUG-CUSTOMER-UI-001-v2-read-after-create.md
```

[bug-artifact-process.md](bug-artifact-process.md) is the single source of truth for the required bug fields, status lifecycle, and classification labels. Do not maintain a second field or status list anywhere else; fill every field from that canonical list, including `title` and `evidence status`.

Before assigning a new ID, search existing bug indexes and recent run artifacts for the same symptom following the dedup search order in [bug-artifact-process.md](bug-artifact-process.md). If it is the same bug, reuse the ID and add the new run as recurrence evidence. If it is a different symptom, cause, or affected surface, create a new ID.

Link bug artifacts from `bug-index.md`, the evidence-table row, run summary, and ledger artifact list. Findings may still hold broader analysis, root-cause notes, or non-bug observations, but metricable defects belong in `bugs/`.

## Run Summary

The run summary should include:

- run ID,
- environment and base URL/API target,
- actor/role labels without secrets,
- UTC window,
- commit/deployed version when relevant,
- selected flows and why,
- evidence layers required and skipped as not applicable,
- high-level verdict,
- cleanup status,
- links to the evidence table, screenshots, test output, and findings,
- bug index and bug artifact links when defects were found.

## Test Evidence

When tests are part of the run, create `test-evidence.md` or the repo equivalent:

- command,
- working directory,
- environment variables by name only when sensitive,
- result,
- decisive output excerpt,
- full output artifact path if stored,
- regression/spec file path when created or refreshed,
- unresolved blockers if tests could not run.

## Evidence Table

Use one row per executed test or flow. If one flow contains multiple meaningful operations, either add sub-rows or link an operation matrix.

| Test/Flow | Status | Actor/role | Inputs | Outputs | Entity IDs | Operations | Data effect | Event effect | Backend surface | Bug artifacts | Evidence links | Notes |
|---|---|---|---|---|---|---|---|---|---|---|---|---|

Entity IDs must be sanitized according to repo policy. If IDs are private, store stable labels or hashed/redacted forms.

## Endpoint Input/Output

For endpoint/API/gRPC/GraphQL checks, record:

- endpoint, operation, or method name,
- sanitized request input shape,
- status code/status result,
- sanitized response output shape,
- response error body or code when failed,
- correlation/request ID,
- whether the endpoint result was corroborated by UI, DB, runtime, or event evidence.

Do not store raw secrets, auth headers, cookies, tokens, OTPs, private identifiers, or PII.

## Ledger Discipline

When a repo has a ledger:

1. Read it first.
2. Resume failed/unproven/blocked flows before retesting green flows unless the repo says otherwise.
3. Add or update a row for every executed test/flow, not only the happy-path winners.
4. Append or update only in the repo-approved format.
5. Record what passed, failed, stayed unproven, was skipped, and what remains blocked.
6. Name exact blockers: credential, fake fixture, route, tool, backend layer, cleanup path.

For large ledgers, start with the current state table, latest run summary, and matching flow IDs. Use targeted searches before reading the whole file. The goal is resumability, not token bonfire.

## End Of Run

When the repo contract defines end-of-run rules, follow them exactly. Otherwise use this default:

1. Retry each failed flow at most once when a flake is plausible, then classify honestly.
2. Emit/update one bug artifact per distinct product defect, including `bugs/bug-index.md`.
3. Emit the evidence table with bug links for failed product flows.
4. Diff against prior ledger state: `NEW`, `REGRESSION`, `FIXED`, `BLOCKED`, `UNCHANGED`.
5. Update the ledger/run summary with executed flows, skipped flows, blockers, cleanup status, and regression candidates.
6. Mark required but unavailable evidence layers as `unverified` or `unproven`, not passed.

If a run hard-stops, write the current state before ending when safe to do so.

## Sanitization

Never write:

- credentials,
- tokens,
- OTPs,
- cookies,
- raw session data,
- private endpoint URLs,
- DB URLs,
- raw SQL exports containing private data,
- private dashboard URLs,
- customer/user PII,
- raw tenant/customer identifiers unless repo policy says they are safe.

When in doubt, store the query shape, aggregate result, sanitized row count, or redacted identifier mapping.
