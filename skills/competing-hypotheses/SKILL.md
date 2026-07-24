---
name: competing-hypotheses
description: >
  Map the full solution space and evaluate approaches against evidence. Based on the
  CIA's Analysis of Competing Hypotheses (ACH). Use for DECISIONS - choosing between
  technologies, architectures, or strategies - or when the user needs counterpoints
  and alternatives. Triggers on "what are the alternatives", "compare approaches",
  "which is better", "counterpoint", "other options", or any decision between multiple
  options. For ranking bug hypotheses during active debugging, use
  troubleshooting-investigator's hypothesis table instead.
metadata:
  version: "1.0"
allowed-tools: Read, Grep, Glob, WebSearch
---

# Analysis of Competing Hypotheses

Don't pick the first plausible approach. Map the full solution space. Evaluate each against evidence. Find the one that best explains all the constraints.

## Core Principle

The CIA developed ACH because analysts kept falling for confirmation bias -- finding evidence that supported their first hypothesis and ignoring the rest. The same happens in engineering. You think of an approach, find reasons it works, and stop looking. ACH forces you to consider ALL plausible approaches and evaluate them against ALL evidence.

## When to Use

- Choosing between architectures, frameworks, or libraries
- When "the obvious choice" hasn't been compared to alternatives
- When team members disagree on approach
- When the user needs counterpoints to their proposed solution
- When a technology bet has limited reversibility

## The Process

### Step 1: List All Plausible Hypotheses

Generate 3-5 genuinely different approaches. Not strawmen -- real alternatives that a competent engineer might choose.

Rules:
- Each must be a REAL approach (used in production somewhere)
- Include the user's proposed approach
- Include at least one approach the user probably hasn't considered
- Include the "do nothing" or "simplest possible" option

### Step 2: List All Evidence

Gather evidence from all available sources:
- Requirements and constraints
- Codebase patterns and existing architecture
- Team capabilities and timeline
- Performance requirements and scale targets
- Real-world usage data from similar systems
- Known failure modes of each approach

### Step 3: Build the Diagnostic Matrix

| Evidence | Approach A | Approach B | Approach C |
|----------|-----------|-----------|-----------|
| [constraint 1] | ++ | - | + |
| [constraint 2] | - | ++ | + |
| [constraint 3] | + | + | -- |

Ratings: `++` strongly supports, `+` supports, `o` neutral, `-` contradicts, `--` strongly contradicts

### Step 4: Analyze

- Which approach has the fewest contradictions? (More diagnostic than counting supports)
- Which evidence is most diagnostic? (Differentiates between approaches)
- What evidence is MISSING that would be decisive?

### Step 5: Present Findings

```
## Competing Hypotheses Analysis

### Approaches Considered
1. [Approach]: [1-line description] -- used by [real example]
2. [Approach]: [1-line description] -- used by [real example]
3. [Approach]: [1-line description] -- used by [real example]

### Diagnostic Matrix
[The evidence table]

### Most Diagnostic Evidence
- [Evidence that most differentiates the approaches]

### Recommendation
[Approach X] best fits the evidence because [specific reasons].
[Approach Y] would be better IF [specific condition changes].

### What Would Change This
- If [condition], switch to [Approach Y]
- Missing evidence: [what we'd need to be more confident]
```

## Key Insight: Disconfirming Evidence

The most diagnostic evidence is DISCONFIRMING evidence -- evidence that rules OUT an approach. Finding one strong contradiction is more valuable than finding five weak supports.

When building the matrix, pay special attention to:
- Hard constraints that eliminate approaches entirely
- Evidence that contradicts the "favorite" approach
- Evidence that supports the "least popular" approach

## Avoiding Common Traps

| Trap | How to avoid |
|------|-------------|
| **Anchoring** on the first approach | Always generate the full list BEFORE evaluating |
| **Strawman** alternatives | Each alternative must be one a competent engineer would actually choose |
| **Confirmation bias** | Count contradictions, not supports |
| **Missing the simple option** | Always include "do nothing" or "simplest possible" |
| **Ignoring context** | Team skill, timeline, and existing code are valid evidence |

## Detailed Technique

Read [cookbook/diagnostic-matrix.md](./cookbook/diagnostic-matrix.md)

---

Evidence standards: follow the [evidence-grounding](../evidence-grounding/SKILL.md) skill — the canonical source for evidence tiers, quality gates, and the counter-evidence obligation.
