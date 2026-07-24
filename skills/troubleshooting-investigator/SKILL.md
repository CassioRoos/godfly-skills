---
name: troubleshooting-investigator
description: >
  Structured troubleshooting and bug investigation workflow for something failing NOW.
  Use when debugging failing tests, production issues, regressions, flaky behavior,
  errors, logs, broken builds, performance problems, or unclear symptoms. For tracing
  why a past failure really happened use root-cause; for understanding a working system
  use deep-dive; for anticipating future failures use failure-analysis.
metadata:
  version: "1.0"
allowed-tools: Read, Grep, Glob, Bash
---

# Troubleshooting Investigator

Debug like an investigator, not a gambler. Do not patch symptoms until the failure is reproduced or the causal chain is clear.

## Workflow

1. **State the symptom** precisely.
2. **Establish expected behavior** from tests, docs, code, or product requirements.
3. **Find the boundary**: when it started, what changed, who is affected, where it reproduces.
4. **Collect evidence**: logs, stack traces, metrics, traces, failing tests, recent commits, config, environment.
5. **Generate hypotheses** and rank by evidence.
6. **Run the smallest diagnostic test** that can eliminate or confirm the top hypothesis.
7. **Fix the cause**, not the visible symptom.
8. **Add a regression guard**: test, monitor, assertion, validation, or runbook.

## Hypothesis Table

```markdown
| Hypothesis | Evidence For | Evidence Against | Test | Result |
|------------|--------------|------------------|------|--------|
```

## Checks

- Recent changes: commits, dependency updates, config, migrations, deploys.
- Environment drift: local vs CI vs staging vs prod.
- Data shape: nulls, duplicates, invalid states, unexpected volume.
- Concurrency: races, timeouts, retries, locks, idempotency.
- External systems: API changes, auth, rate limits, partial outages.
- Observability: missing logs, misleading errors, swallowed exceptions.

## Output

```markdown
## Symptom

## Expected Behavior

## Evidence

## Hypotheses

## Diagnostic Steps

## Root Cause

## Fix

## Regression Guard

## Remaining Risk
```

## Rule

If you cannot reproduce it, prove why the evidence is still strong enough to change code. Otherwise, keep investigating.

---

Evidence standards: follow the [evidence-grounding](../evidence-grounding/SKILL.md) skill — the canonical source for evidence tiers, quality gates, and the counter-evidence obligation.
