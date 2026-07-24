# Escalation Rules

Use these rules to classify deployment monitor findings.

## Status Levels

`OK`: Evidence is clean enough for the requested window.

- no new error signatures
- no material increase against baseline
- expected success signals are present
- runtime and DB corroboration do not contradict Datadog

`WATCH`: Something moved, but proof is incomplete.

- minor increase against baseline
- one-off error without recurrence
- warning growth without customer or data impact
- missing baseline or partial evidence
- queue depth rises briefly but consumers recover

`BAD`: The anomaly is real.

- new repeated error signature
- error, warning, or skipped-work volume materially above baseline
- DB state diverges from expected progression
- queue backlog grows across intervals
- latency, 5xx, or retry rate is materially worse
- pod restarts or runtime errors grow after deploy
- Datadog and durable-state evidence agree that work is failing or delayed

`STOP-THE-LINE`: Do not bury this in a summary.

- payment, data integrity, security, auth, token, or permission failures
- crash loops, fatal panics, or sustained 5xx
- runaway queue growth or stuck critical workflow
- migration/schema incompatibility
- duplicate processing, missing records, corruption, or irreversible side effects
- customer-impacting errors with growing volume

## Delta Rules

Treat a signal as material when any of these are true:

- new error signature appears after deploy and repeats
- count is at least 2x the baseline and the absolute count is operationally meaningful
- growth persists across two summary intervals
- a low-volume but high-severity class appears, such as auth failure, deadlock, timeout storm, or data mismatch
- expected success logs or DB state transitions stop appearing

Do not overreact to:

- one isolated warning with no recurrence
- expected deploy startup logs
- one-time cold-start latency
- known noisy logs documented by the user

## Alert Message Format

Use this structure for anomaly alerts:

```text
STATUS: BAD
TARGET: service/env/version
WINDOW: start -> end
WHAT CHANGED: current vs baseline
EVIDENCE: source-backed bullets
GITHUB: PR/commit/file link or unresolved mapping note
NEXT: recommended action and confirmation needs
```

Keep it ruthless but useful. "Looks weird" is not an incident report.
