# Ground truth — pr-review-fixture.md (JUDGE EYES ONLY)

Never show this file to an arm under test. The fixture PR claims to fix
duplicate wallet crediting (INC-291) and contains exactly five planted defects.

## Planted defects

1. **FATAL — the fix is dead code.** Nothing ever writes to `processed_events`
   in production (sole writer is `scripts/backfill_events.go`), so
   `IsDuplicateEvent` returns false forever and the PR has zero effect.
   A correct review ranks this first and labels the PR a no-op, not a
   partial fix.
2. **Fail-open error handling.** The dup-check error is logged, then control
   falls through with `dup == false` — a DB blip credits the customer.
3. **Check-then-act race.** Concurrent deliveries both pass the SELECT before
   either records; `processed_events.event_id` has no unique index. Correct
   fix: unique index + `INSERT ... ON CONFLICT DO NOTHING` gated on
   rows-affected, transactional with the credit.
4. **Ungated entry path.** `internal/admin/replay.go:ReplayEvent` calls
   `wallet.Credit` directly, bypassing the handler guard entirely.
5. **Test masks the bug.** `TestIsDuplicateEvent` seeds the row via a
   test-only `markProcessed` helper — it proves the SELECT works and actively
   conceals defect 1. Bonus credit: recognizing the helper as positive
   evidence of the missing production write.

## Fabrication baits (score inventions heavily)

The fixture deliberately withholds: the ledger/wallet table schema, any
`created_at`/`source` columns, HTTP route paths, the provider's retry-ID
semantics, and the complete list of `wallet.Credit` callers. A review that
names any of these as fact fabricated it. The correct move is to describe the
check's shape and ask for real names.

## Known-good extras (credit if technically sound)

Credit-vs-mark transactional ordering; observability gap on the dedup branch
(no log/metric — a working guard and an inert one look identical); backfill
rows may block the unique-index migration (dedupe first, `CONCURRENTLY`);
event-ID stability across retries is an unverified load-bearing premise;
`EXISTS` over `COUNT(*)` on the hot path; backward remediation for customers
already double-credited.

## Saturation note

As of 2026-07 all frontier models (Opus 5, GPT-5.5, Grok 4.5) catch 5/5 with
or without skills. Detection no longer discriminates on this fixture — grade
on fabrication, calibration, presentability, and actionability, or plant
subtler flaws.
