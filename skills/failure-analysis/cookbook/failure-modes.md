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

| Score | Level | Criteria |
|-------|-------|----------|
| 10 | Certain | Has happened repeatedly, no fix in place |
| 8-9 | Very likely | Has happened before, or obvious vulnerability |
| 6-7 | Likely | Similar systems have this failure, conditions exist |
| 4-5 | Moderate | Possible under specific conditions |
| 2-3 | Unlikely | Requires unusual circumstances |
| 1 | Remote | Theoretically possible but no known occurrence |

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

| # | Component | Failure Mode | S | P | D | RPN | Mitigation |
|---|-----------|-------------|---|---|---|-----|------------|
| 1 | Queue consumer | Poison pill message crashes consumer loop | 8 | 6 | 7 | 336 | Add dead-letter queue + message validation |
| 2 | Database write | Partial write (no transaction) | 9 | 4 | 9 | 324 | Wrap in transaction, add consistency check |
| 3 | API handler | Unbounded query returns 100k rows | 6 | 5 | 3 | 90 | Add pagination, set max limit |
| 4 | Auth middleware | Token expiry not checked | 10 | 3 | 8 | 240 | Add expiry validation, add auth tests |

## Focus Areas by RPN

### RPN 200+ (Critical)
Stop and fix these. They represent high-impact, likely, hard-to-detect failures.
Common patterns: silent data corruption, missing auth checks, unhandled error paths.

### RPN 100-199 (High)
Address before shipping or add comprehensive monitoring.
Common patterns: missing timeouts, no retry limits, unbounded resource consumption.

### RPN 50-99 (Medium)
Document and add monitoring. Fix when convenient.

### RPN <50 (Low)
Accept and move on. Not everything needs mitigation.

## The Silent Failure Audit

For any system, specifically hunt for failures where Detectability >= 7:

1. **No error logging:** Function swallows errors or logs at DEBUG level
2. **No metrics:** Operation has no success/failure counters
3. **No health check:** Component can be broken without affecting health endpoint
4. **No data validation:** Corrupt data flows through without validation
5. **No reconciliation:** Two systems can disagree without anyone noticing
6. **No timeout monitoring:** Slow operations aren't tracked

These are the most dangerous failures because they accumulate damage over time before anyone notices.
