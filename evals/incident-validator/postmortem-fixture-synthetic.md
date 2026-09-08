# Postmortem: ledger-reconciler duplicate settlement postings

**Severity:** P2
**Service:** ledger-reconciler
**Incident window:** 2026-07-28 09:14 UTC → 2026-07-28 11:02 UTC
**Owner:** platform team

## What happened

The nightly settlement reconciler posted a subset of settlement lines to the ledger
twice. Merchants saw duplicated credits on their statements for about two hours until
we disabled the job.

## Timeline

- 09:14 — reconciler run begins
- 10:38 — support escalates two merchant reports of doubled credits
- 10:51 — job disabled
- 11:02 — duplicate postings reversed
- Detected by: merchant reports via support

## Five Ws

- **Who:** merchants on the nightly settlement path.
- **What:** duplicate ledger postings.
- **When:** 2026-07-28, roughly two hours.
- **Where:** ledger-reconciler, settlement posting path.
- **Why:** the idempotency key omitted the settlement batch revision, so a retried
  batch was treated as new work.

## Production evidence

Error rate and duplicate-posting counts were reviewed in our dashboards during the
incident. The team confirmed the duplicates were limited to the affected window.

## Impact

Approximately 400 duplicate postings. All were reversed the same morning. No net
financial loss to merchants after reversal.

## Root cause

`deriveSettlementDedupeToken` hashed `(merchant_id, payout_cycle_date)` but not
`batch_revision`. When the upstream settlement service re-emitted a corrected batch,
the reconciler saw a key it had already processed as a distinct unit of work and
posted the lines again.

## Resolution

Added `batch_revision` to the idempotency key. Fully fixed.

## Tests

Added a unit test for `deriveSettlementDedupeToken` asserting that two batches differing only
by revision produce different keys. Passes.

## Deployment validation

Deployed the fix and confirmed the service came up healthy. The next nightly run
completed without errors.

## Monitoring

We watched the service for the rest of the day and saw no recurrence.

## Detection improvement

We should add an alert for duplicate ledger postings.

## Action items

| Item | Owner | Due |
|---|---|---|
| Add duplicate-posting alert | platform | TBD |
| Review other idempotency keys | platform | TBD |

## Contributing factors

The reconciler was written before batch revisions existed and was never revisited.
