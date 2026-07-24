---
name: red-blue-review
description: >
  Red-team/blue-team review for designs, plans, code, security, reliability, and launch
  readiness. Use when the user asks for red team, blue team, adversarial review, attack
  paths, defense plan, risk review, or catching issues before shipping.
metadata:
  version: "1.0"
allowed-tools: Read, Grep, Glob
---

# Red/Blue Review

Use opposing lenses to find what breaks and what defends it. Do not list generic risks. Produce concrete attack paths, failure paths, and mitigations.

## Inputs To Gather

- The artifact: code, diff, design, ADR, spec, migration, runbook, or launch plan.
- The asset at risk: money, data integrity, availability, privacy, developer time, customer trust.
- The threat or failure model: malicious actor, operator error, dependency failure, scale, bad data, ambiguous requirements.
- The deployment context: environments, permissions, observability, rollback path.

## Red Team

Act like the system will be misused, overloaded, misconfigured, or attacked.

Check:

- Trust boundaries and privilege escalation.
- Input validation and malformed data.
- Authentication, authorization, and tenant isolation.
- Secrets handling and accidental leakage.
- Retry storms, duplicate effects, race conditions, and idempotency gaps.
- Silent data corruption and partial writes.
- Missing timeouts, circuit breakers, and backpressure.
- Operational mistakes: bad deploy, bad config, bad rollback, stale docs.

## Blue Team

Defend with practical controls, not wishful thinking.

For each credible issue:

- Prevention: code/design change that stops it.
- Detection: logs, metrics, traces, alerts, invariants, tests.
- Containment: rate limits, circuit breakers, feature flags, kill switches.
- Recovery: rollback, replay, reconciliation, data repair.
- Ownership: who notices and who acts.

## Output

```markdown
## Red Team Findings

### Critical
- Attack/failure path:
  Evidence:
  Impact:
  Why current controls fail:

### High
- Attack/failure path:
  Evidence:
  Impact:
  Why current controls fail:

## Blue Team Plan

- Control:
  Covers:
  Implementation:
  Validation:

## Launch Gate

- Ship:
- Block:
- Spike:
```

## Rule

If there is no evidence for a control, say "control not demonstrated." A design promise is not a control.

---

Evidence standards: follow the [evidence-grounding](../evidence-grounding/SKILL.md) skill — the canonical source for evidence tiers, quality gates, and the counter-evidence obligation.
