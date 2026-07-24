# Safety Protocol

The core safety framework for all system operations. Load this before any operation.

## The Three Gates

Every operation must pass through applicable gates before execution:

```
Operation Request
       |
       v
  ┌──────────┐
  │ CLASSIFY  │  Determine risk level (L1-L4)
  └──────────┘
       |
       v
  ┌──────────┐
  │ PREVIEW   │  Dry-run or show what will happen (L2+)
  └──────────┘
       |
       v
  ┌──────────┐
  │ CONFIRM   │  Get user approval (L3+)
  └──────────┘
       |
       v
  ┌──────────┐
  │ EXECUTE   │  Run the operation
  └──────────┘
       |
       v
  ┌──────────┐
  │ AUDIT     │  Log action + rollback info (L2+)
  └──────────┘
```

## Gate 1: Risk Classification

Classify EVERY operation before executing:

### L1 — Read-Only (No gate needed)
- `git status`, `git log`, `git diff`
- `docker ps`, `docker images`, `docker logs`
- `kubectl get`, `kubectl describe`
- `ls`, `cat`, `find`, `grep`, `ps`, `df`, `top`
- `SELECT` queries (no writes)
- API GET requests (no side effects)

### L2 — Local Reversible (Preview required)
- `git add`, `git commit`, `git branch`, `git stash`
- File creation, editing, moving (with backup)
- `docker build`, `docker-compose up` (local)
- `npm install`, `go mod tidy`
- Environment variable changes (local)
- Cache invalidation (local)

### L3 — Remote / Hard-to-Reverse (Dry-run + Confirm)
- `git push`, `git merge` (to shared branches)
- `docker push`, container deployments
- `kubectl apply`, `kubectl scale`
- Database INSERT/UPDATE (production or shared)
- API POST/PUT/PATCH to external services
- CI/CD pipeline triggers
- PR creation, issue comments
- Cloud resource provisioning

### L4 — Destructive / Irreversible (Dry-run + Explicit Confirm + Rollback Plan)
- `git push --force`, `git reset --hard`
- `rm -rf`, recursive deletes
- `DROP TABLE`, `DELETE FROM` without backup
- `kubectl delete`, pod/deployment removal
- Cloud resource deletion
- Production database migrations (schema changes)
- Service teardown
- Branch deletion (remote)

## Gate 2: Preview / Dry-Run

For L2+ operations, ALWAYS preview before executing:

### Preview Techniques by Domain

**Git operations:**
```bash
# Before push: show what will be pushed
git log origin/main..HEAD --oneline
git diff origin/main..HEAD --stat

# Before merge: show what will change
git merge --no-commit --no-ff <branch> && git diff --cached && git merge --abort

# Before reset: show what will be lost
git diff HEAD..<target>
```

**Docker operations:**
```bash
# Before build: review the Dockerfile and build context (docker build has no dry-run flag)
cat Dockerfile && docker buildx du 2>/dev/null || du -sh .

# Before push: show image details
docker inspect <image> | jq '.[0].Config'
```

**Kubernetes operations:**
```bash
# Before apply: diff against current state
kubectl diff -f <manifest>

# Before delete: show what will be affected
kubectl get <resource> -o wide

# Before scale: show current state
kubectl get deployment <name> -o jsonpath='{.spec.replicas}'
```

**Database operations:**
```sql
-- Before UPDATE/DELETE: SELECT first to show affected rows
SELECT * FROM <table> WHERE <conditions>;
-- Show count
SELECT COUNT(*) FROM <table> WHERE <conditions>;

-- Before migration: show the SQL that will run
-- (framework-specific: goose status, flyway info, etc.)
```

**File operations:**
```bash
# Before bulk delete: list what will be removed
find <path> -name "<pattern>" -type f
# Show count
find <path> -name "<pattern>" -type f | wc -l

# Before overwrite: show diff
diff <old> <new>
```

**Cloud / Infrastructure:**
```bash
# Before provisioning: show plan
terraform plan
pulumi preview

# Before teardown: list affected resources
terraform state list | grep <resource>
```

## Gate 3: Confirmation

### L2 — No confirmation stop
Show the preview and proceed. The preview is the user's chance to object.

### L3 — Explicit named confirmation
Show the preview AND ask a confirmation that names all four items — exact action, environment and target, read-only vs mutating, expected effect and scope:
> "About to run [exact command] against [environment/target]. This is a mutating operation that will [effect and scope]. Proceed?"

The user's original request does not count as this confirmation; it must follow the preview. A reply that does not address the named action is not confirmation.

### L4 — Explicit named confirmation with rollback plan
Everything in L3, plus a rollback plan, plus the DESTRUCTIVE marker:
> "**DESTRUCTIVE**: About to run [exact command] against [environment/target]. This will [effect and scope] and is [irreversible / reversible via ...]. To undo: [rollback steps]. Proceed?"

## Gate 4: Audit Trail

After every L2+ operation, output the audit block:

```
--- OPS AUDIT ---
Action: {concise description of what was executed}
Risk: L{level}
Scope: {files, services, resources affected}
Reversible: {yes | no | partial}
Rollback: {specific command or steps to undo}
Output: {key output or "see above"}
-----------------
```

### Audit Examples

```
--- OPS AUDIT ---
Action: Pushed branch feature/auth to origin
Risk: L3
Scope: remote origin, branch feature/auth (3 commits)
Reversible: yes
Rollback: git push origin +HEAD~3:feature/auth
-----------------
```

```
--- OPS AUDIT ---
Action: Dropped index idx_users_email on users table
Risk: L4
Scope: production database, users table index
Reversible: yes (with rebuild time)
Rollback: CREATE INDEX idx_users_email ON users(email);
-----------------
```

## Scope Boundaries

### What This Agent Will NOT Do Without Escalation
- Execute commands as root/sudo without explicit user request
- Modify production databases without a backup confirmation
- Push to main/master without branch protection check
- Delete remote branches without listing dependents
- Run commands on remote hosts without confirming the target

### Environment Awareness
Before operating, confirm the environment:
- Is this local, staging, or production?
- **If you cannot tell, it is production.** Unclassifiable environments get production ceremony: treat the operation one risk level higher until the environment is proven otherwise.
- Are there other users/services that could be affected?
- Is there a maintenance window or freeze in effect?

When another active skill defines a stricter boundary for the same operation (e.g. a QA or deployment skill with its own environment boundary), the stricter rule wins.

## Composing Operations

For multi-step operations:
1. Classify the HIGHEST risk step — that's the overall risk level
2. Preview ALL steps as a plan before executing any
3. Execute step-by-step, auditing each L2+ step
4. If any step fails, stop and present options (retry, skip, rollback)

## Error Recovery

If an operation fails:
1. Capture the error output
2. Assess the state (partial execution?)
3. Present options:
   - **Retry**: If transient (network, timeout)
   - **Rollback**: If partial execution left bad state
   - **Investigate**: If error is unclear
4. Never silently retry destructive operations
