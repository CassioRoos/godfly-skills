# Assumptions Matrix

## Building the Matrix

| # | Assumption | Category | Confidence | Impact if Wrong | Evidence | Proposed Test |
|---|-----------|----------|------------|-----------------|----------|---------------|
| 1 | [stated assumption] | Technical | Verified | [impact] | [evidence] | N/A |
| 2 | [hidden assumption] | Business | Untested | [impact] | [none] | [cheap test] |
| 3 | [implicit assumption] | Team | Fragile | [impact] | [counter-evidence] | [validation] |

## Confidence Rating Guide

| Rating | Criteria | Example |
|--------|----------|---------|
| **Verified** | Measured, tested, or observed with data | "Load test shows 5000 req/s" |
| **Confident** | Strong reasoning, team experience, but not tested | "We've built similar systems before" |
| **Uncertain** | Could go either way, opinions differ | "We think users will prefer modal over page" |
| **Untested** | Never examined, inherited or defaulted | "The queue can handle our volume" (never measured) |
| **Fragile** | Evidence suggests it might be wrong | "Latency is fine" (while p99 dashboards already show timeout spikes) |

## Impact Assessment

Ask: "If this assumption is wrong, what breaks?"

| Impact | Description | Example |
|--------|-------------|---------|
| **Catastrophic** | Data loss, security breach, complete outage | Auth assumption wrong -> unauthorized access |
| **Severe** | Major feature broken, significant user impact | Scale assumption wrong -> cascading timeouts |
| **Moderate** | Degraded experience, workaround exists | UX assumption wrong -> user confusion, support tickets |
| **Minor** | Cosmetic, no functional impact | Naming assumption wrong -> slightly confusing API |
| **None** | Assumption is irrelevant to outcome | Style preference has no functional impact |

## Priority Matrix

Focus on: HIGH impact + LOW confidence

|  | Low confidence (fragile/untested/uncertain) | High confidence (verified/confident) |
|---|---|---|
| **High impact** | **CRITICAL** — test fragile/untested now; **INVESTIGATE** uncertain | **ACCEPT** — document the evidence |
| **Low impact** | **NOTE** — watch for change | **ACCEPT** |

## Inversion Technique for Assumptions

For each assumption rated Uncertain or worse:

1. **State the assumption:** "We assume the database can handle 10k writes/sec"
2. **Invert it:** "What if the database can only handle 1k writes/sec?"
3. **Consequences:** "Batch imports would timeout, queue would back up, users would see errors"
4. **Evidence search:** Look for load test results, production metrics, vendor documentation
5. **Cheap test:** "Run a 5-minute load test against staging with realistic data"

## Common Hidden Assumption Patterns

### The "Happy Path" Assumption
Code that only handles the success case implicitly assumes failure never happens.
- Look for: missing error returns, unchecked errors, no retry logic
- Test: What happens when [dependency] returns an error?

### The "Single User" Assumption
Code designed for one user at a time implicitly assumes no concurrency.
- Look for: shared mutable state, missing locks, race conditions
- Test: What happens when two requests hit this simultaneously?

### The "Stable Input" Assumption
Code that trusts input data implicitly assumes it's always well-formed.
- Look for: missing validation, no sanitization, assumed field presence
- Test: What happens with null, empty, or malformed input?

### The "Infinite Resources" Assumption
Architecture that doesn't consider resource limits assumes they don't exist.
- Look for: unbounded queues, no connection limits, no rate limiting
- Test: What happens at 10x current load?

### The "Network is Reliable" Assumption
Distributed systems that don't handle network failures assume the network never fails.
- Look for: no timeouts, no circuit breakers, synchronous cross-service calls
- Test: What happens when [service] is unreachable for 30 seconds?
