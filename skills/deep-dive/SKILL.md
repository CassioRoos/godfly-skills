---
name: deep-dive
description: >
  Deep technical investigation for complex systems, unfamiliar codebases, architecture,
  data flows, and dependencies - when the system works but is not understood. Use when
  the user asks for a deep dive, investigate deeply, map the system, understand how it
  works, break down complexity, or produce an evidence-backed technical brief. If
  something is failing right now use troubleshooting-investigator; if tracing why a past
  failure happened use root-cause.
metadata:
  version: "1.0"
allowed-tools: Read, Grep, Glob, Bash
---

# Deep Dive

Go deep enough to be useful, not deep enough to drown. The output should clarify the system and expose decision points.

## Workflow

1. Define the investigation question.
2. Find entry points: commands, routes, handlers, jobs, schemas, configs, docs.
3. Map the flow: caller -> boundary -> core logic -> persistence -> side effects -> observability.
4. Identify invariants: what must always be true.
   For data-flow investigations, start at the destination: verify that the data actually arriving at the end of the flow (table rows, published messages, emitted files) satisfies the expected invariant, using the broadest valid query or artifact check. Then walk backwards: source payload -> runtime processing -> destination. Judge correctness by the payload content itself, never by who sent it — a trusted sender can still deliver a wrong payload.
5. Identify coupling: shared state, dependencies, lifecycle, retries, ownership.
6. Find sharp edges: ambiguity, hidden assumptions, failure modes, missing tests.
7. Compare with prior art or established patterns when relevant.
8. Produce a concise technical brief with evidence.

## Evidence Standards

Follow the `evidence-grounding` skill — it is the canonical source for evidence tiers and quality gates. In short: prefer file references, tests, logs, docs, metrics, and commit history over guesses; separate confirmed facts from inferences; search current docs before concluding. If the system has multiple plausible explanations, apply the `competing-hypotheses` skill to rank them.

## Output

```markdown
## Question

## Executive Summary

## System Map

## Key Flows

## Invariants

## Dependencies

## Failure Modes

## Evidence

## Open Questions

## Recommendations
```

## Rule

Do not produce a wall of notes. Synthesize. The user needs the shape of the system, the risks, and the next useful action.
