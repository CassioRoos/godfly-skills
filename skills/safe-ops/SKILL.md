---
name: safe-ops
description: Safely perform authorized remote, destructive or security-relevant operations, including Git push/merge, releases, infrastructure and data mutations, credential changes and bulk cleanup. Not required for routine read-only inspection or ordinary scoped repository edits.
---

# Safe Ops

Make the safe path easy. Check authority, preview material effects, execute the
named operation, and read back the result. No ritual approval loops.

## One authorization policy

- A clear request naming an operation and a resolvable target authorizes that
  scope. "Commit and push this branch" and "open the PR" do not need another
  generic "proceed?". Show a compact preview and continue.
- A review, diagnosis or QA request does not authorize publishing or fixing.
  "Ship it" does not silently authorize merge, tag, deploy or database changes.
- Ask when the action/target is ambiguous, blast radius exceeds the request,
  or new evidence materially changes the risk. Do not turn an inferred goal
  into authority for a remote mutation.
- Destructive/history-rewriting actions require approval of the **exact
  preview**: targets, old/new state, losses, recovery and its limits.
  An earlier explicit approval of that unchanged preview remains valid.
- Higher-priority and environment-specific gates still apply, including
  production restrictions and the user's exact-diff approval for global
  Codex instructions/configuration/skills. Unknown environment = production.
  Never infer ST/PROD write authorization from local-development permission.

## Risk, proportional ceremony

| Level | Typical action | Handling |
|---|---|---|
| L1 | Status, diff, bounded read-only query | Proceed within read-access rules |
| L2 | Authorized local commit, topic-branch fast-forward push | Short preview, execute, read back |
| L3 | Shared branch push/merge, PR publication, infrastructure/API writes | Verify named target, effects and existing authorization; ask only if missing |
| L4 | Force push, hard reset, destructive deletion, schema/data loss | Exact reviewed preview, explicit approval and recovery plan |

A topic push can trigger CI or preview deployment; discover meaningful side
effects before treating it as L2. "Reversible" does not mean cost-free.

## References

The policy above is canonical. Read only the relevant domain; "confirm" in a
recipe means establish authorization under this policy, not automatically ask
again. Examples are not authority.

- Git, CI and PRs: [dev-workflow.md](cookbook/dev-workflow.md).
- Infrastructure: [infrastructure.md](cookbook/infrastructure.md).
- Databases/APIs: [data-services.md](cookbook/data-services.md).
- Files/processes/secrets: [local-system.md](cookbook/local-system.md).
- Multi-step or uncertain operations: [safety-protocol.md](cookbook/safety-protocol.md).

Report one compact outcome per coherent operation: changed scope, observed
result, important residual effects and recovery when material. No audit block
for every file or command. Stop on unexpected state and inspect before retrying.
