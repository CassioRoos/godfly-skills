# Known Failure Patterns

## Catalog of Common Software Failure Patterns

When reviewing a system, check for these patterns. Each has been responsible for real production incidents.

## Data Integrity Failures

### Write-Then-Publish (No Transaction)
**Pattern:** Write to database, then publish to queue. If publish fails, database has a record the rest of the system doesn't know about.
**Check:** Are database writes and message publishes in the same transaction boundary?
**Fix:** Outbox pattern, or transactional outbox, or publish-then-write with idempotent consumer.

### Read-Modify-Write Race
**Pattern:** Read a value, modify it in code, write it back. Two concurrent requests read the same value, both modify, last write wins.
**Check:** Are there SELECT-then-UPDATE patterns without locking?
**Fix:** Optimistic locking (version column), SELECT FOR UPDATE, or atomic UPDATE.

### Orphaned References
**Pattern:** Delete a parent record but child records still reference it. Or create a child before the parent is committed.
**Check:** Are foreign key constraints enforced? Are deletes cascaded or checked?
**Fix:** Foreign keys with ON DELETE CASCADE/RESTRICT, or soft deletes.

## Concurrency Failures

### Connection Pool Exhaustion
**Pattern:** Under load, all connections in the pool are in use. New requests queue up, timeouts cascade.
**Check:** Is the connection pool sized appropriately? Are connections returned promptly? Any long-running queries?
**Fix:** Right-size pool, add connection timeout, fix slow queries, add circuit breaker.

### Goroutine/Thread Leak
**Pattern:** Goroutines/threads created but never cleaned up. Memory grows over time until OOM.
**Check:** Are goroutines bounded? Is there a shutdown mechanism? Do goroutines have exit conditions?
**Fix:** Use context cancellation, WaitGroups, or bounded worker pools.

### Lock Contention
**Pattern:** Multiple operations compete for the same lock. Throughput drops as concurrency increases.
**Check:** Are there global mutexes in hot paths? Database row-level locks held during external calls?
**Fix:** Reduce lock scope, use read-write locks, shard the locked resource.

## Distributed System Failures

### Split Brain
**Pattern:** Two instances think they're the leader. Both process the same work, causing duplicates.
**Check:** Is leader election reliable? What happens during network partition?
**Fix:** Fencing tokens, distributed locks with TTL, single-writer principle.

### Thundering Herd
**Pattern:** After an outage, all clients reconnect or retry simultaneously. The surge overwhelms the recovering service.
**Check:** Do retries have jitter? Do reconnections have backoff? Are cache stampedes possible?
**Fix:** Exponential backoff with jitter, circuit breakers, cache warming.

### Poison Pill Message
**Pattern:** A malformed message causes the consumer to crash. It restarts, reads the same message, crashes again. Infinite loop.
**Check:** Is there dead-letter queue handling? Does the consumer validate messages before processing?
**Fix:** Message validation, max retry count, dead-letter queue, alerting on repeated failures.

## API and Integration Failures

### Unbounded Response
**Pattern:** API returns all results without pagination. With enough data, response is too large to process.
**Check:** Are all list/query endpoints paginated? Is there a max limit?
**Fix:** Default pagination, max page size, cursor-based pagination for large datasets.

### Missing Idempotency
**Pattern:** Retrying a failed request causes duplicate side effects (double charge, double email).
**Check:** Do mutation endpoints accept idempotency keys? Are operations naturally idempotent?
**Fix:** Idempotency keys, deduplication tables, natural idempotency (upsert vs insert).

### Webhook Reliability
**Pattern:** Webhook delivery fails and the event is lost. No retry, no record.
**Check:** Is there webhook retry logic? Is there a way to replay missed webhooks? Is delivery tracked?
**Fix:** Retry with backoff, event log for replay, signature verification, delivery receipts.

## Operational Failures

### Missing Observability
**Pattern:** Something is wrong but no one knows because there are no metrics, logs, or alerts.
**Check:** Are critical operations metered? Are errors logged with context? Are alerts configured?
**Fix:** Add structured logging, metrics for success/failure/latency, alerts on anomalies.

### Configuration Drift
**Pattern:** Environment variables or configs differ between staging and production. Works in staging, breaks in production.
**Check:** Are configs version-controlled? Is there parity between environments?
**Fix:** Config-as-code, environment parity checks, config validation on startup.

### Deployment Rollback Gap
**Pattern:** New version breaks something, but rollback isn't possible because of database migrations or API contract changes.
**Check:** Are migrations backward-compatible? Can the old version run against the new schema?
**Fix:** Expand-contract migrations, API versioning, feature flags.
