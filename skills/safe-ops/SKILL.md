---
name: safe-ops
description: Safe system operations with risk classification, dry-run previews, confirmation gates,
  and audit trails. Use when performing mutating, destructive, or remote operations - infrastructure
  ops (Docker, K8s, cloud), dev workflow ops (git push/merge, CI/CD, PRs), data/service ops
  (databases, APIs, caches), or risky local ops (bulk deletes, process kills). Triggers on "deploy",
  "restart", "migrate", "scale", "delete", "drop", "kill", "push", "reset", "force", "prune",
  "cleanup", "teardown". Not needed for read-only commands.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# Safe Ops

Execute system operations safely with risk classification, dry-run previews, confirmation gates, and audit trails.

## Quick Start

Before ANY system operation:

1. **Classify risk** (L1-L4)
2. **Dry-run / preview** the operation (L2+)
3. **Confirm** with user (L3+)
4. **Execute** and capture output
5. **Log** what was done with rollback info (L2+)

## Environment and Precedence Rules

- An environment you cannot classify is **production** until proven otherwise. Production targets are treated one risk level higher (a production L3 gets L4 ceremony).
- L3+ confirmation must name all of: (1) the exact command/action, (2) the environment and target, (3) whether it is read-only or mutating, and (4) the expected effect and scope. A bare "Proceed? (yes/no)" without those items is not confirmation, and the user's original request does not count as confirmation for L3+.
- When another active skill defines a stricter boundary for the same operation (e.g. a QA or deployment skill with its own environment boundary), the stricter rule wins.

## Safety Protocol

Read [cookbook/safety-protocol.md](./cookbook/safety-protocol.md) - **ALWAYS load this first**

## Operation Domains

### Infrastructure (Docker, K8s, Cloud)
Read [cookbook/infrastructure.md](./cookbook/infrastructure.md)

### Dev Workflow (Git, CI/CD, PRs)
Read [cookbook/dev-workflow.md](./cookbook/dev-workflow.md)

### Data & Services (DB, APIs, Caches)
Read [cookbook/data-services.md](./cookbook/data-services.md)

### Local System (Files, Processes, Env)
Read [cookbook/local-system.md](./cookbook/local-system.md)

## Risk Levels

| Level | Impact | Requires | Examples |
|-------|--------|----------|----------|
| **L1** | Read-only, no side effects | Nothing | `git status`, `docker ps`, `ls` |
| **L2** | Local, reversible changes | Preview | `git commit`, file edits, `docker build` |
| **L3** | Remote or hard-to-reverse | Dry-run + Confirm | `git push`, `docker push`, deploy, DB write |
| **L4** | Destructive or irreversible | Dry-run + Explicit Confirm + Rollback plan | `drop table`, `rm -rf`, force push, scale down |

## Audit Trail Format

After every L2+ operation, output:

```
--- OPS AUDIT ---
Action: {what was done}
Risk: L{n}
Scope: {what was affected}
Reversible: {yes/no}
Rollback: {how to undo, or "N/A"}
-----------------
```
