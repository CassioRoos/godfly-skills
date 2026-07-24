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
```bash
# Create directories
mkdir -p <path>

# Copy with backup
cp <source> <dest>

# Move (preview path first)
ls -la <source>
mv <source> <dest>
```

### Bulk Operations (L3-L4)

**Bulk rename (L3):**
```bash
# Preview: show what will be renamed
for f in <pattern>; do echo "$f -> ${f/old/new}"; done

# Confirm, then execute
for f in <pattern>; do mv "$f" "${f/old/new}"; done
```

**Bulk delete (L4):**
```bash
# Preview: list files and count
find <path> -name "<pattern>" -type f
find <path> -name "<pattern>" -type f | wc -l

# Safety: move to trash instead of rm when possible
mkdir -p /tmp/trash-$(date +%Y%m%d)
find <path> -name "<pattern>" -type f -exec mv {} /tmp/trash-$(date +%Y%m%d)/ \;

# Rollback: "Files are in /tmp/trash-<date>/, move them back"
```

**Recursive delete (L4):**
```bash
# Preview: show tree
find <path> -maxdepth 2 | head -50

# Show total size
du -sh <path>

# NEVER rm -rf without explicit path confirmation
# Prefer: move to trash, then delete trash later
mv <path> /tmp/trash-$(date +%Y%m%d)/

# Rollback: "mv /tmp/trash-<date>/<name> <original-path>"
```

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
kill $(lsof -i :<port> -t)
```

## Environment Management

### View (L1)
```bash
env | grep <pattern>
echo $<VAR>
cat .env              # Check for secrets before displaying!
```

### Modify (L2 local, L3 shared)
```bash
# Local .env changes (L2)
# Preview: show current value
grep <VAR> .env

# Edit with backup
cp .env .env.backup.$(date +%Y%m%d)
# Then modify

# Shell environment (L2 — session only)
export <VAR>=<value>
```

### Secrets Handling
- NEVER echo or log secret values
- NEVER commit .env files
- When showing env vars, redact sensitive values:
  ```
  DATABASE_URL=postgres://user:****@host:5432/db
  API_KEY=sk-****...last4
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
find /tmp -maxdepth 1 -mtime +7 -exec ls -la {} \;

# rm -rf is L4 by definition: explicit confirm + rollback plan required.
# Prefer the reversible path: move to a dated trash dir, delete later.
mkdir -p /tmp/trash-$(date +%Y%m%d)
find /tmp -maxdepth 1 -mtime +7 -not -name 'trash-*' -exec mv {} /tmp/trash-$(date +%Y%m%d)/ \;

# Rollback: "mv /tmp/trash-<date>/<name> <original-path>"
```
