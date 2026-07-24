# Data Evidence

Use data evidence when a flow creates, updates, deletes, archives, restores, links, de-duplicates, cleans up, or claims persisted state.

## Rules

- Prefer read-only MCP/database tools.
- Any PROD-related database tool execution, including read-only inspection, requires explicit PROD confirmation (see SKILL.md Environment Boundary) before execution unless it is covered by a current bounded read-only PROD evidence envelope.
- PROD-related writes, DDL/DML, migrations, cleanup, or data repair are blocked unless the user explicitly confirms the exact operation, environment, target, and expected effect.
- ST/local data operations may execute when repo/user rules allow it and fake/safe scope is proven. Do not over-block ST/local as if it were production.
- If repo-local policy makes ST databases read-only or forbids local DDL/DML, obey the repo-local rule.
- Do not store raw credentials, private URLs, raw dumps, tenant IDs, customer IDs, or PII in artifacts unless the repo explicitly defines a sanitized-safe format.

## Before Mutation

Prove the target is safe/fake before mutating:

- fixture ID from repo docs,
- fake email/domain policy,
- seeded test account,
- read-only query showing fixture scope,
- explicit user-provided target plus repo-approved fake scope.

If fake scope is ambiguous, classify the flow `blocked-ambiguous-target` and continue to other flows.

## After Mutation

Capture read-only proof:

- created records: table/source, sanitized key, expected fields, creation timestamp/status,
- changed records: table/source, sanitized key, field-level before/after summary,
- deleted/archived records: table/source, sanitized key, deletion/archival marker, absence from active reads,
- visible UI state matches persisted state,
- no unexpected orphan rows,
- cleanup status,
- timestamps or IDs sufficient to correlate with the flow window,
- outbox/event rows when the mutation is expected to publish.

## Data Evidence Matrix

For flows that touch persistence, include a compact matrix in the evidence pack:

| Operation | Expected data effect | Proof source | Before | After | Verdict |
|---|---|---|---|---|---|

Examples:

- `create`: row absent before, row present after with expected fields.
- `update`: old values recorded, new values persisted, unchanged fields stay sane.
- `delete/archive`: active read no longer returns the entity, deleted/archive table or marker matches repo contract.
- `cleanup`: fake test rows/events removed or intentionally retained with a documented reason.

## Classification

- State mismatch after successful UI/network: `failed-backend`.
- Tool unavailable but layer required: `unproven` or layer `unverified`.
- Cleanup blocked after creating test data: record the orphan risk as a finding/blocker.
