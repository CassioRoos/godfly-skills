# Data & Service Operations

Safe patterns for databases, APIs, and caches.

## Database Operations

### Read Queries (L1)
```sql
-- Always safe
SELECT * FROM <table> LIMIT 100;
SELECT COUNT(*) FROM <table>;
-- Postgres: \dt / \d <table>, or information_schema.tables / information_schema.columns
-- MySQL: SHOW TABLES; DESCRIBE <table>; SHOW CREATE TABLE <table>;
```

### Write Queries (L3)

**ALWAYS preview affected rows before writing:**

```sql
-- Step 1: Preview (L1)
SELECT * FROM <table> WHERE <conditions>;
SELECT COUNT(*) FROM <table> WHERE <conditions>;

-- Step 2: Confirm count and rows with user

-- Step 3: Execute (L3)
UPDATE <table> SET <columns> WHERE <conditions>;
INSERT INTO <table> (<columns>) VALUES (<values>);
```

**Bulk updates — batch by key inside a transaction (Postgres has no `UPDATE ... LIMIT`):**
```sql
-- Preview
SELECT COUNT(*) FROM <table> WHERE <conditions>;

-- Execute in batches; check the reported row count before COMMIT
BEGIN;
UPDATE <table> SET <column> = <value>
WHERE <key> IN (
  SELECT <key> FROM <table> WHERE <conditions> LIMIT 1000
);
-- row count sane vs preview? COMMIT; otherwise ROLLBACK;
COMMIT;
```

### Delete Queries (L4)

```sql
-- Step 1: Preview exactly what will be deleted
SELECT * FROM <table> WHERE <conditions>;
SELECT COUNT(*) FROM <table> WHERE <conditions>;

-- Step 2: Backup affected rows
CREATE TABLE <table>_backup_<date> AS
  SELECT * FROM <table> WHERE <conditions>;

-- Step 3: Present rollback plan:
-- "INSERT INTO <table> SELECT * FROM <table>_backup_<date>"

-- Step 4: Confirm, then delete
DELETE FROM <table> WHERE <conditions>;
```

### Schema Changes (L4)

```sql
-- Preview: show current schema
SHOW CREATE TABLE <table>;

-- For migrations, show the SQL that will run:
-- goose: goose -dir ./migrations status
-- flyway: flyway info
-- atlas: atlas schema diff

-- Backup before migration
-- pg_dump / mysqldump the affected tables

-- Present rollback: the down migration SQL
-- Confirm, then apply
```

### Database Connection Safety
- Always confirm which database/environment before executing
- Use read replicas for SELECT queries when available
- Use transactions for multi-statement writes
- Set statement timeout for long-running queries

```sql
-- Wrap writes in transaction
BEGIN;
UPDATE <table> SET <column> = <value> WHERE <conditions>;
-- Review results
SELECT * FROM <table> WHERE <conditions>;
-- Commit only if correct
COMMIT;
-- Or ROLLBACK if wrong
```

## API Operations

### GET Requests (L1)
```bash
# Safe reads
curl -s <url> | jq .
gh api <endpoint>
```

### POST/PUT/PATCH Requests (L3)
```bash
# Preview: show the payload
echo '<payload>' | jq .

# Confirm endpoint + payload, then execute
curl -X POST <url> -H "Content-Type: application/json" -d '<payload>'
```

### DELETE Requests (L4)
```bash
# Preview: GET the resource first to confirm identity
curl -s <url>/<id> | jq .

# Present rollback plan (if recreatable)
# Confirm, then delete
curl -X DELETE <url>/<id>
```

### API Safety Rules
- Always confirm the base URL (production vs staging vs local)
- Never hardcode secrets in commands — use environment variables
- For webhooks: test with a dry-run endpoint first if available
- Rate limiting: add delays between bulk API calls

## Cache Operations

### View State (L1)
```bash
# Redis
redis-cli INFO keyspace
redis-cli DBSIZE
redis-cli SCAN 0 MATCH "<pattern>" COUNT 100

# Memcached
echo "stats" | nc <host> <port>
```

### Invalidate Keys (L3)
```bash
# Preview: show what will be invalidated
redis-cli SCAN 0 MATCH "<pattern>" COUNT 100

# Show count
redis-cli EVAL "return #redis.call('keys', '<pattern>')" 0

# Confirm, then invalidate
redis-cli DEL <key>
# Or for pattern: redis-cli EVAL "local keys = redis.call('keys', '<pattern>') for i=1,#keys do redis.call('del', keys[i]) end return #keys" 0
```

### Flush Cache (L4)
```bash
# Preview: show database size
redis-cli DBSIZE

# Present impact: "This will clear ALL cached data. Services will experience cache misses."
# Rollback: "Cache will repopulate on next access — no data loss, but temporary performance impact"

# Confirm, then flush
redis-cli FLUSHDB
```

## Queue Operations

### View (L1)
```bash
# Show queue depth
# (varies by queue system — RabbitMQ, SQS, Redis, etc.)
```

### Purge (L4)
```bash
# Preview: show queue depth and sample messages
# Backup: dead-letter or dump messages first
# Confirm, then purge
```

## Environment Awareness

Before ANY data operation, confirm:
1. **Which environment?** (local / staging / production)
2. **Which database/service?** (show connection string, redacting passwords)
3. **Who else is affected?** (shared database? other services reading this data?)
