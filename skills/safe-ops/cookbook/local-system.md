# Local System Operations

Safe patterns for file management, processes, and environment setup.

## File Operations

### Read / Search (L1)
```bash
ls -la <path>
find <path> -name "<pattern>" -type f
du -sh <path>
file <path>
stat <path>
```

### Create / Edit (L2)

Use scoped repository edits normally. Before copy, move or rename, inspect the
exact source and destination. A destination that exists is not a backup slot:
stop or choose a new unique slot; never silently overwrite it.

### Bulk cleanup (L3-L4)

Resolve and show exact task-owned targets first. Never flatten a set of files
into one dated directory: duplicate basenames overwrite each other.

For **quiescent regular files**, use the bundled Python 3 helper:

```bash
python3 <skill-dir>/scripts/safe-trash.py /absolute/backup-parent /absolute/a/notes.txt /absolute/b/notes.txt
# After approval of those exact targets and recovery location:
python3 <skill-dir>/scripts/safe-trash.py /absolute/backup-parent /absolute/a/notes.txt /absolute/b/notes.txt --apply
```

Preview is read-only. Apply creates a unique private run directory, saves original
paths and SHA-256 digests, copies each file to its own slot, verifies it and only
then removes the source. Missing/nonregular/duplicate sources fail preflight.
Requires enough backup space. After helper changes, run
`python3 <skill-dir>/scripts/acceptance.py` (isolated fixtures). This is not an atomic snapshot of files with active
writers; stop writers or use the platform's supported snapshot/backup facility.

On failure, preserve the reported recovery directory, inspect its map and
payloads plus remaining originals, and stop. Never delete a backup on error.
To restore, verify each payload digest and original path from `restore-map.json`;
copy it back only if the original is absent. Resolve conflicts explicitly.
Backups containing secrets stay private and out of Git and shared logs.

For directories, inspect the exact tree and archive requirements separately.
Use a unique private destination outside the source tree and retain an original
path map. Verify preservation before removal. Do not pass a broad root, home,
workspace root, unresolved variable or glob to a recursive delete.

## Process Management

### View (L1)
```bash
ps aux | grep <process>
lsof -i :<port>
top -l 1 | head -20       # macOS
```

### Start (L2)
```bash
# Start a service
<command> &
# Or with process manager
brew services start <service>
```

### Stop (L3)
```bash
# Preview: show process details
ps aux | grep <process>
lsof -p <pid>

# Graceful stop first
kill <pid>          # SIGTERM

# Only escalate if needed (L4)
kill -9 <pid>       # SIGKILL — last resort
```

### Port Management
```bash
# Find what's using a port (L1)
lsof -i :<port>

# Kill process on port (L3)
# Preview first
lsof -i :<port> -t  # Show PIDs
lsof -i :<port>     # Show full details

# Confirm, then kill
kill <verified-pid>
# Recheck identity/owner immediately before stopping; do not reselect every PID
# on the port after approving a different preview.
```

## Environment Management

### View (L1)
```bash
# Inspect variable names/presence through a parser without displaying values.
# Never dump env, .env, credentials or browser-token stores.
```

### Modify (L2 local, L3 shared)
```bash
# Local .env changes (L2)
# Preview: name the key and intended non-secret effect; never print its value.

# Edit with backup
# Copy into a fresh private backup directory, verify it, then modify.
# Do not use a same-day filename that can overwrite the previous backup.

# Shell environment (L2 — session only)
export <VAR>=<value>
```

### Secrets Handling
- NEVER echo or log secret values
- NEVER commit .env files
- When showing env vars, redact sensitive values:
  ```
  DATABASE_URL=postgres://user:****@host:5432/db
  API_KEY=[REDACTED]
  ```

## Dependency Management

### View (L1)
```bash
# Go
go list -m all
go mod graph

# Node
npm ls --depth=0
npm outdated

# Python
pip list
pip check
```

### Install (L2)
```bash
# Go
go get <package>
go mod tidy

# Node
npm install <package>

# Python
pip install <package>
```

### Update (L3)
```bash
# Preview: show what will change
go list -m -u all              # Go: show available updates
npm outdated                    # Node: show outdated
pip list --outdated             # Python: show outdated

# Confirm scope (all vs specific), then update
go get -u <package>
npm update <package>
pip install --upgrade <package>
```

### Remove (L3)
```bash
# Preview: show dependents
go mod graph | grep <package>
npm ls <package>

# Confirm no breaking dependents, then remove
go get <package>@none
npm uninstall <package>
```

## Cleanup Operations

### Disk Space (L1 -> L4)
```bash
# View (L1)
df -h
du -sh * | sort -rh | head -20

# Clean caches (L3)
# Preview sizes first
du -sh ~/Library/Caches/
du -sh ~/.cache/
du -sh /tmp/

# Clean build artifacts (L3)
# Go
go clean -cache -testcache
# Node
rm -rf node_modules/.cache
# Docker
docker system df
```

### Temp Files (L4 — recursive delete)
```bash
# Preview: show age and size
find /tmp -mindepth 1 -maxdepth 1 -mtime +7 -exec ls -ld {} \;

# rm -rf is L4 by definition: explicit confirm + rollback plan required.
# Prefer a unique recoverable archive; do not flatten paths.
# Resolve exact task-owned directories from the preview; obtain approval.
# Move only those named paths to a unique backup, preserving their locations.
# Do not execute a broad age-based move over /tmp.

# Recovery: verify the original-path map and payload before restoring.
```
