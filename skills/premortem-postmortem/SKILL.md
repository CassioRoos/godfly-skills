---
name: premortem-postmortem
description: >
  Run premortems before risky work and postmortems after incidents or failures. Use when
  the user asks for premortem, postmortem, incident review, retrospective, launch risk,
  "how will this fail", or "what killed this". For the causal-chain analysis itself
  (evidence-backed five whys from symptom to systemic cause) use the root-cause skill;
  this skill produces the premortem/postmortem document around it.
metadata:
  version: "1.0"
allowed-tools: Read
---

# Premortem / Postmortem

Use premortems to prevent predictable failure. Use postmortems to learn without rewriting history.

## Premortem

Frame it as: "It is six months after launch. This failed badly. What killed it?"

Steps:

1. Define success in measurable terms.
2. List failure causes independently before filtering.
3. Classify causes:
   - **Real threats**: plausible, damaging, actionable.
   - **Noise**: scary but unlikely or unactionable.
   - **Avoided truths**: politically or emotionally uncomfortable risks.
4. Score real threats by impact, likelihood, and detectability.
5. Turn the top threats into controls, owners, and validation tests.
6. Define launch gates and rollback triggers.

Premortem output:

```markdown
## Success Definition

## Failure Story

## Top Failure Causes
- Cause:
  Class:
  Evidence:
  Impact:
  Likelihood:
  Detectability:
  Prevention:
  Detection:
  Owner:

## Launch Gates

## Rollback Triggers
```

## Postmortem

Do not hunt for a single root cause when the evidence shows a chain. Most failures are systems failures.

Steps:

1. Build a timeline from evidence: logs, metrics, deploys, alerts, commits, tickets, user reports.
2. Separate facts from interpretations.
3. Identify contributing factors across code, process, config, monitoring, docs, and decision-making.
4. Ask why detection failed or succeeded.
5. Define corrective actions with owners and deadlines.
6. Add regression tests, monitors, runbooks, or guardrails.

Postmortem output:

```markdown
## Impact

## Timeline

## What Happened

## Contributing Factors

## Detection And Response

## What Worked

## What Failed

## Corrective Actions
- Action:
  Owner:
  Due:
  Verification:

## Follow-up Risks
```

## Rule

Do not accept "human error" as a root cause. Human error is where the investigation starts.

---

Evidence standards: follow the [evidence-grounding](../evidence-grounding/SKILL.md) skill — the canonical source for evidence tiers, quality gates, and the counter-evidence obligation.
