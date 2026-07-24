---
name: spec-adr-builder
description: >
  Generate or review technical specs and Architecture Decision Records. Use when the user
  asks for specs, ADRs, RFCs, design docs, decision records, technical requirements,
  non-goals, alternatives, rollout, or rollback documents.
metadata:
  version: "1.0"
---

# Spec / ADR Builder

Write decision docs that survive contact with implementation. A spec that only describes the happy path is half a spec.

## Spec Workflow

1. Define the problem and why now.
2. Define goals and non-goals.
3. Identify users, systems, and constraints.
4. Map current behavior and target behavior.
5. Compare alternatives, including doing nothing and using existing tools.
6. Define acceptance criteria and test strategy.
7. Identify risks, failure modes, observability, rollout, and rollback.
8. List open questions and decision deadlines.

Spec output:

```markdown
# Spec: Title

## Problem

## Goals

## Non-goals

## Current State

## Proposed Solution

## Alternatives Considered

## API / Data / Behavior Changes

## Failure Modes And Mitigations

## Observability

## Test Plan

## Rollout Plan

## Rollback Plan

## Open Questions
```

## ADR Workflow

Use ADRs when a decision has lasting consequences or tradeoffs.

ADR output:

```markdown
# ADR: Title

## Status
Proposed | Accepted | Superseded

## Context

## Decision

## Alternatives Considered

## Consequences

## Validation

## Rollout / Migration
```

## Review Rules

- If there are no non-goals, the scope is not controlled.
- If there are no alternatives, the decision is under-argued.
- If there is no rollback, the rollout is not finished.
- If there is no validation, it is opinion dressed up as a plan.
