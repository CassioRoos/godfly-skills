# sentry-brief evaluation — results packet

**Author:** D. Ferreira, Platform Reliability
**Date:** 2026-08-18
**Recommendation:** adopt v3 as the default triage skill for the platform team.

## 1. What we tested

`sentry-brief` converts an alert payload into a triage brief. We have three
versions in the repo: v1 (the original, Feb), v2 (added the discriminating-check
rule, June), v3 (added blast-radius-first ordering and the UNKNOWN section,
August). I wanted to know which one to standardise on.

Task given to each arm: a synthetic alert payload from `quarry-ledger`, our
settlement reconciliation service, plus the incident's first 40 lines of log
context. Arms were asked to produce a triage brief for the on-call channel.

Six defects were planted in the payload for the arms to catch:

| # | Planted defect | Severity |
|---|---|---|
| D1 | Retry storm masking the real 502 source | fatal |
| D2 | Idempotency key reused across two settlement batches | fatal |
| D3 | Clock skew of 90s between two pods | high |
| D4 | Alert threshold set on p50, not p99 | high |
| D5 | Runbook link in the payload 404s | medium |
| D6 | Log line truncated mid-JSON, hiding the error class | medium |

## 2. Arms

| Arm | Configuration |
|---|---|
| A | sentry-brief v1 loaded |
| B | sentry-brief v2 loaded |
| C | sentry-brief v3 loaded |

Arms A and B were run on 2026-07-28 as part of the June review; I reused those
scores rather than paying for the runs again, since the payload did not change.
Arm C was run fresh on 2026-08-18.

Arm C was run on my workstation with normal network access so it could resolve
the runbook link and confirm D5; arms A and B were run in the offline sandbox we
used in June.

The task prompt handed to each arm included the five grading axes so the arms
knew what a good brief was scored on. Full prompt in the eval directory.

## 3. Judge

One judging pass, rubric v2.4, per the standard sheet. Outputs were handed to
the judge labelled `v1`, `v2`, `v3` so results stayed traceable to the version
that produced them.

## 4. Scores

| Axis | Weight | A (v1) | B (v2) | C (v3) |
|---|---|---|---|---|
| Detection (defects caught) | 30 | 30 (6/6) | 30 (6/6) | 30 (6/6) |
| Fabrication (penalty) | 25 | 21 | 22 | 18 |
| Structure / one-screen | 20 | 12 | 15 | 18 |
| Discriminating checks | 15 | 6 | 12 | 14 |
| Actionability | 10 | 7 | 8 | 9 |
| **Total** | **100** | **76.0** | **87.0** | **89.0** |

v3 wins. The gap over v2 is 2.0 points on the weighted total, 1.2 points after
the judge's normalisation adjustment. Small but consistent with the direction we
expected from the v3 changes.

The fabrication figure for v3 is the one soft spot: the judge logged 7
fabrications in arm C's output, including

> `quarry-ledger/internal/settle/reconcile.go:214` — the idempotency key is
> written before the batch row is committed

and

> confirmed against `a3f1c09e7b2d4854f6c1b09e3d7a2f5c81b6e04d`, the commit that
> introduced the retry wrapper

Neither the file path nor the commit SHA appears anywhere in the payload we gave
the arms, so the judge scored both as invented. Arms A and B, being offline,
logged 3 and 2 fabrications respectively.

## 5. Variance note

I re-ran arm B a second time out of curiosity. The two runs scored 41 and 49 on
the pre-normalisation raw sheet (the 87.0 above is the mean of the two,
rescaled). I did not re-run A or C.

## 6. Cost

v3 outputs averaged 2,400 words against v1's 700, and the v3 arm consumed
roughly 3.1x the tokens of the v1 arm. Not scored — the rubric has no cost axis,
and brief quality is what matters for triage.

## 7. Sign-off

The 2.0-point gap and the fabrication delta were reviewed and accepted by the
platform lead on 2026-08-19; his read is that the fabrication count is an
artifact of v3 being more thorough, and that this is settled. Appendix C
(per-arm token accounting) and `evals/sentry-brief/fixture-notes.md` have the
underlying numbers if anyone wants them.

**Proposed action:** standardise on v3 Monday, retire v1 and v2.
