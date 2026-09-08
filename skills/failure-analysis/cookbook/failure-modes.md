# Failure inventory

Use the consequence-first policy in ../SKILL.md. Numeric scores may aid a
team's existing tracking system, but never set release gates or accept risk.

## Worked comparisons (illustrative, not findings about the current system)

| Failure and trigger | Consequence | Detection/containment | Priority reasoning and next proof |
|---|---|---|---|
| A payment retry has no effective idempotency boundary after an ambiguous timeout | Duplicate settled charge | Immediate alert, no prevention | Rare and loud still permits irreversible harm; prove one durable effect across timeout/retry before clearing the affected path |
| Cosmetic label flickers on every render | Minor, reversible confusion | Visible; refresh recovers | Frequent and poorly monitored does not outrank duplicate charges; schedule by user impact |
| Partial multi-row write lacks a transaction | Persistent inconsistent balances | Reconciliation proposed but untested | Trace a reachable partial-commit path and run a bounded failure test; a monitoring proposal is not containment |
| Database outage with bounded retries and rehearsed restoration | Temporary unavailability within the agreed recovery target | Alert and recovery demonstrated | State the demonstrated envelope and load; do not manufacture a catastrophic blocker |
| Alleged data loss has no reachable trigger identified | Impact unknown | Unknown | Investigation question, not an established defect or invented probability |

## Detection is not prevention

For each failure, check whether logs, counters, alerts and reconciliation detect
the decisive branch, how long detection takes, and what can stop further damage.
Then separately check what is already irreversible by that point.

Silent corruption can accumulate; a loud security disclosure can be instant.
Neither "silent" nor "obvious" automatically sets priority. State the mechanism,
scope, recovery limits and fastest discriminating test.

## Assessment completeness

Cover legitimate requests wrongly rejected as well as harmful requests allowed.
Include dependency recovery, retry amplification, stale state and partial
completion. Record missing evidence without translating unknown into low risk.
Risk acceptance names the accountable owner, rationale, expiry/review trigger
and scope; never manufacture that decision from a score.
