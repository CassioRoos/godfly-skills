# Dependency Chain Analysis

## Mapping the Chain

For any operation, trace the complete path from trigger to completion:

```
[Trigger] -> [Component A] -> [Component B] -> [Component C] -> [Result]
                  |                 |                 |
              [Dep A1]          [Dep B1]          [Dep C1]
              [Dep A2]          [Dep B2]
```

### What to Map

For each link in the chain:
- **Input:** What does this component receive?
- **Processing:** What does it do?
- **Output:** What does it produce?
- **Dependencies:** What external resources does it need? (DB, cache, queue, API)
- **Failure behavior:** What happens when it fails?
- **Timeout:** How long before the caller gives up?

## Questions at Each Link

### The Failure Question
"What happens if this component returns an error?"
- Is the error handled by the caller?
- Is the error propagated up the chain?
- Does the error trigger cleanup/rollback?

### The Slowness Question
"What happens if this component takes 10x longer than usual?"
- Does the caller have a timeout?
- Is the timeout shorter than the downstream timeout? (It should be)
- What happens when the timeout fires?

### The Duplication Question
"What happens if this operation runs twice?"
- Is the operation idempotent?
- Can retries cause duplicate side effects (double-charge, double-send)?
- Is there deduplication logic?

### The Recovery Question
"What happens when this component comes back after being down?"
- Do queued messages get processed?
- Is there a thundering herd of reconnections?
- Does the system reach a consistent state?

### The Partial Failure Question
"What happens if step 2 of 3 fails?"
- Are steps 1 and 3 still consistent?
- Is there compensation logic (saga pattern)?
- Can the system detect and recover from partial completion?

## Cascading Failure Patterns

### Pattern: Timeout Cascade

```
API Gateway (timeout: 30s)
  -> Service A (timeout: 30s)
    -> Service B (timeout: 30s)
      -> Database (timeout: 30s)
```

**Problem:** If the database is slow, all services block for 30s. Gateway timeout fires, but Service A, B, and DB connections remain open. Connection pools exhaust.

**Fix:** Timeouts must decrease down the chain. Gateway: 10s, Service A: 5s, Service B: 2s.

### Pattern: Retry Amplification

```
Client retries 3x
  -> Gateway retries 3x
    -> Service retries 3x
```

**Problem:** One failure at the service level becomes 3 x 3 x 3 = 27 requests. At scale, this turns a blip into an outage.

**Fix:** Retry at only one level (usually the outermost). Inner layers should fail fast.

### Pattern: Shared Resource Contention

```
Service A (reads from DB, uses connection pool: 10)
Service B (writes to DB, uses connection pool: 10)
Batch Job (bulk write to DB, uses connection pool: 10)
```

**Problem:** Batch job grabs all connections. Service A and B can't connect. Users see errors.

**Fix:** Separate connection pools, rate-limit batch jobs, or schedule batch off-peak.

## Output Format

```
## Dependency Chain: [Operation Name]

### Chain Map
[Trigger] -> [A] -> [B] -> [C] -> [Result]

### Link Analysis
| Link | Timeout | Retry | Failure Handling | Risk |
|------|---------|-------|-----------------|------|
| A -> B | 5s | 3x with jitter | Returns error | Low |
| B -> C | None! | None | Panics | HIGH |
| C -> DB | 30s | None | Swallows error | CRITICAL |

### Cascade Risks
- [Description of potential cascade]
- [Which pattern applies]
- [Specific fix]
```
