# FMEA Deep Dive

## Failure Mode and Effects Analysis for Software

FMEA was developed for hardware engineering but applies directly to software systems. The core idea: systematically identify how each component can fail, rate the risk, and prioritize mitigation.

## Rating Scales

### Severity (Impact when failure occurs)

| Score | Level | Software Example |
|-------|-------|-----------------|
| 10 | Catastrophic | Data loss, security breach, financial loss |
| 8-9 | Critical | Full service outage, data corruption |
| 6-7 | Major | Major feature unavailable, significant data delay |
| 4-5 | Moderate | Degraded performance, partial feature loss |
| 2-3 | Minor | Cosmetic issue, minor inconvenience |
| 1 | None | No user-visible impact |

### Probability (How likely is this failure)

**Only rate this when you have a source. Otherwise write `UNDETERMINED`.**

Severity and Detectability are readable off the artifact. Probability is not --
it needs incident history, traffic volume, or error-rate data. A repository
alone almost never contains it.

| Score | Level | Criteria | Valid source required |
|-------|-------|----------|------------------------|
| 10 | Certain | Has happened repeatedly, no fix in place | Incident IDs or recurring error series |
| 8-9 | Very likely | Has happened before | A specific incident or log window |
| 6-7 | Likely | Conditions demonstrably exist and are exercised | Volume/traffic data showing the path is hot |
| 4-5 | Moderate | Possible under specific conditions | Data showing those conditions occur |
| 2-3 | Unlikely | Requires unusual circumstances | Data showing they are rare |
| 1 | Remote | No known occurrence | Coverage good enough that absence is meaningful |
| — | **UNDETERMINED** | **No history, volume, or error data in scope** | **This is the correct answer on most code reviews** |

Note what is missing from this table: there is no row for "similar systems have
this failure" or "this feels likely". Neither is a source. Analogy to other
systems is a reason to *investigate* a failure mode, never a Probability rating.

Do not infer Probability from Severity. "This would be catastrophic" says
nothing about frequency, and the two get conflated precisely when the data is
absent.

### Detectability (How hard is it to notice)

This is the most underrated factor. Silent failures cause the most damage.

| Score | Level | Criteria |
|-------|-------|----------|
| 10 | Undetectable | No monitoring, no alerts, no user-visible symptom |
| 8-9 | Very hard | Only discoverable through manual investigation |
| 6-7 | Hard | Might show up in logs, but no one watches them |
| 4-5 | Moderate | Alert exists but may be delayed or noisy |
| 2-3 | Easy | Clear alert, user reports immediately |
| 1 | Obvious | System stops, impossible to miss |

## Example FMEA Table

This example is from a code review with **no telemetry and no traffic data** --
the common case. Rank is Severity x Detectability. Probability is cited where a
source exists and `UNDET.` everywhere else. Copy this shape, including the empty
cells.

| # | Component | Failure Mode | S | D | Rank | P | Mitigation |
|---|-----------|-------------|---|---|------|---|------------|
| 1 | Database write | Partial write, no transaction; ledger and side effect can diverge | 9 | 9 | 81 | UNDET. | Wrap in transaction, add reconciliation |
| 2 | Queue consumer | Poison pill crashes the consumer loop | 8 | 7 | 56 | 8 — INC-311, fired twice in March | Dead-letter queue + message validation |
| 3 | Auth middleware | Token expiry not checked | 10 | 8 | 80 | UNDET. | Add expiry validation and auth tests |
| 4 | API handler | Unbounded query returns the full table | 6 | 3 | 18 | UNDET. | Add pagination, set max limit |

Three of four rows carry no Probability, and the table is still fully
actionable: rows 1 and 3 outrank row 2 on evidence that is actually present.
That is the intended output, not a degraded one.

## Focus Areas by Rank

Rank (Severity x Detectability) orders the work. It does not decide it -- you do,
by naming the decision for each finding.

### Blocks release
High severity **and** high detectability score -- catastrophic *and* silent.
Nothing downstream would catch it. Common patterns: silent data corruption,
missing auth checks, money moving with no reconciliation.

### Ship only with detection added
Severe but currently invisible, where the fix is larger than the release.
Add the log, metric, or reconciliation that converts a silent failure into a
loud one, then ship.

### Accept, with the risk stated
Low severity, or high severity with genuinely good detection already in place.
Name who is accepting it. "Accept" is a decision with an owner, not a shrug.

**Do not gate on a numeric threshold.** A cutoff like "fix everything above 200"
launders invented inputs into a release decision -- and if Probability was
guessed, the threshold is guessed too.

## The Silent Failure Audit

For any system, specifically hunt for failures where Detectability >= 7:

1. **No error logging:** Function swallows errors or logs at DEBUG level
2. **No metrics:** Operation has no success/failure counters
3. **No health check:** Component can be broken without affecting health endpoint
4. **No data validation:** Corrupt data flows through without validation
5. **No reconciliation:** Two systems can disagree without anyone noticing
6. **No timeout monitoring:** Slow operations aren't tracked

These are the most dangerous failures because they accumulate damage over time before anyone notices.
