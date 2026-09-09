# Safety protocol

Authorization lives in ../SKILL.md; this file adds execution mechanics.
Do not reinterpret a domain recipe's "confirm" as a second approval requirement.

1. Resolve exact targets, ownership, environment and the highest-risk step.
   Read operations can still expose secrets or overload production: bound them.
2. Preview the whole authorized operation once. Include irreversible effects,
   affected people/services and any meaningful automated side effects.
3. Check whether existing authorization covers that preview. Ask only for
   missing authority or changed scope/risk; destructive steps require an
   explicitly approved exact preview.
4. Execute incrementally; capture sanitized output and check partial state
   after any error. Never silently retry destructive or non-idempotent writes.
5. Read back authoritative state. A successful command is not proof that the
   intended deployment reconciled or the expected remote ref changed.
6. Summarize outcome once. Recovery is a separate mutation and needs authority.

## Nonmutating previews

- Git changes: pinned refs and `git diff --stat <old> <new>`.
  This shows a diff, not mergeability. For actual conflict diagnostics use
  `git merge-tree --write-tree <base-sha> <topic-sha>` when supported.
  It writes Git objects but does not change HEAD, index or worktree.
  Exit 1 means conflicts; other errors require investigation.
  Never use a real `git merge --no-commit` as a "dry run".
- Deletions: list exact resolved targets and preserve recoverable backups.
  A broad root, unresolved glob or variable is not a safe target.
- Data mutations: use bounded, selective counts and sanitized shapes, then
  review SQL/transaction/backup implications. Do not print sensitive rows.
- Infrastructure: use supported planning/diff commands; inspect their own
  side effects. Never invent a dry-run flag.

## Recovery

Capture the old remote SHA before a push. Prefer a normal revert for published
history. If an explicitly approved rollback rewrites a ref, use the exact
old SHA and an exact lease on the expected current SHA, as in dev-workflow.md.
A lease failure means the world changed: inspect, do not widen the lease.
Never use moving HEAD~N expressions or unleased +refspec rollback.

A backup must be readable and sufficient to restore the affected data; naming
a backup is not testing recovery. Preserve unique paths and original locations.
