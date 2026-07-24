# Dev Workflow Operations

Safe patterns for Git, CI/CD, and PR management.

## Git Operations

### Read State (L1)
```bash
git status
git log --oneline -20
git diff
git diff --cached
git branch -a
git remote -v
git stash list
```

### Local Changes (L2)
```bash
# Staging & commits
git add <specific-files>           # Prefer specific files over -A
git commit -m "<message>"

# Branching
git checkout -b <branch>
git stash push -m "<description>"
git stash pop

# Preview: always show what's being committed
git diff --cached --stat
```

### Remote Operations (L3)
```bash
# Preview: show what will be pushed
git log origin/<branch>..HEAD --oneline
git diff origin/<branch>..HEAD --stat

# Confirm, then push
git push origin <branch>

# PR creation
gh pr create --title "<title>" --body "<body>" --draft

# Merge (show what changes first)
gh pr diff <number>
gh pr merge <number> --squash
```

### Destructive Git (L4)
```bash
# Force push — ALWAYS confirm target branch
# Preview: show what will be overwritten
git log HEAD..origin/<branch> --oneline  # Commits that will be LOST

# Present rollback: "git push origin +<current-sha>:<branch>"
# Confirm with explicit branch name

# Hard reset — show what will be lost
git diff HEAD..<target> --stat
git stash push -m "backup before reset"  # Safety backup
```

### Branch Protection Rules
- NEVER force push to main/master without explicit user override
- ALWAYS check if branch has open PRs before deleting
- ALWAYS check if branch is ahead of remote before resetting

## CI/CD Operations

### View Pipeline Status (L1)
```bash
gh run list --limit 10
gh run view <run-id>
gh run view <run-id> --log-failed
```

### Trigger Pipelines (L3)
```bash
# Preview: show what will be triggered
gh workflow list
gh workflow view <workflow>

# Confirm workflow + branch, then trigger
gh workflow run <workflow> --ref <branch>

# Re-run failed
gh run rerun <run-id> --failed
```

### Cancel Pipelines (L3 — remote operation)
```bash
# Preview: show running workflows
gh run list --status in_progress

# Cancel specific run
gh run cancel <run-id>
```

## PR Management

### Review (L1)
```bash
gh pr list
gh pr view <number>
gh pr diff <number>
gh pr checks <number>
```

### Create & Update (L3)
```bash
# Preview: show what will be in the PR
git log origin/main..HEAD --oneline
git diff origin/main..HEAD --stat

# Create
gh pr create --title "<title>" --body "<body>"

# Comment
gh pr comment <number> --body "<comment>"

# Request review
gh pr edit <number> --add-reviewer <user>
```

### Close & Delete (L3-L4)
```bash
# Close PR (L3) — reversible
gh pr close <number>

# Delete branch after merge (L3) — check first
gh pr view <number> --json mergedAt,headRefName

# Delete remote branch (L4) — confirm, show rollback
git ls-remote --heads origin <branch>
# Rollback: git push origin <sha>:<branch>
```

## Release Operations

### View (L1)
```bash
gh release list
gh release view <tag>
```

### Create (L3)
```bash
# Preview: show what will be in the release
git log <previous-tag>..HEAD --oneline

# Confirm tag + target, then create
gh release create <tag> --title "<title>" --notes "<notes>"
```

### Delete (L4)
```bash
# Preview: show release details
gh release view <tag>

# Backup release notes before deleting
gh release view <tag> --json body -q '.body' > /tmp/release-<tag>-backup.md

# Confirm, then delete
gh release delete <tag>
```
