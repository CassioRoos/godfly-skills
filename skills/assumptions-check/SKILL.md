---
name: assumptions-check
description: >
  Surface and test hidden assumptions in plans, code, architecture, and strategy.
  Based on the CIA's Key Assumptions Check technique. Use when reviewing decisions,
  designs, or proposals to find what's being taken for granted. Triggers on "what am
  I missing", "assumption check", "what are we assuming", or when evaluating any
  non-trivial decision. For general adversarial review use godfly.
metadata:
  version: "1.0"
allowed-tools: Read, Grep, Glob
---

# Key Assumptions Check

Surface what's being taken for granted. Test it. Break what's fragile before it breaks you.

## Core Principle

Every plan, design, and decision rests on assumptions -- most of them invisible. This skill makes them visible, rates their strength, and identifies which ones need evidence or testing before you proceed.

## When to Use

- Before committing to an architecture or technology bet
- When a plan feels "obviously right" (that's when assumptions hide best)
- When reviewing code that makes implicit guarantees
- When someone says "that won't be a problem" without evidence
- When inherited designs carry forward without re-examination

## The Process

### Step 1: Extract Assumptions

Read the plan/code/design and list every assumption -- stated or implied.

Look for assumptions in these categories:

| Category | What to look for |
|----------|-----------------|
| **Technical** | "This library handles X", "The database can handle Y load", "This API is reliable" |
| **User** | "Users will do X", "Users understand Y", "Users won't do Z" |
| **Business** | "We have time for X", "The market wants Y", "Competitors won't Z" |
| **Team** | "We have expertise in X", "We can hire for Y", "This won't need maintenance" |
| **Environment** | "Infrastructure supports X", "Latency will be under Y", "Data volume won't exceed Z" |

### Step 2: Rate Each Assumption

| Rating | Meaning | Action |
|--------|---------|--------|
| **Verified** | Tested, measured, or proven with data | Document the evidence |
| **Confident** | Strong reasons to believe, but not tested | Note the reasoning |
| **Uncertain** | Could go either way, no strong evidence | Needs investigation |
| **Untested** | Never examined, just accepted | Needs immediate testing |
| **Fragile** | Evidence suggests it might be wrong | Challenge now |

### Step 3: Challenge the Weak Ones

For each Uncertain, Untested, or Fragile assumption:
1. **Invert it** -- "What if the opposite is true?"
2. **Find evidence** -- Search codebase, docs, web for data that confirms or contradicts
3. **Propose a test** -- How would you validate this assumption cheaply?
4. **Assess impact** -- If this assumption is wrong, how bad is the damage?

### Step 4: Produce the Assumptions Brief

```
## Assumptions Brief

### Critical (Untested/Fragile, High Impact)
- [Assumption]: [Why it matters] -> [Proposed test]

### Worth Investigating (Uncertain, Medium Impact)
- [Assumption]: [Current evidence] -> [What would change your mind]

### Solid Ground (Verified/Confident)
- [Assumption]: [Evidence/reasoning]
```

## Finding Hidden Assumptions

### In Code
- Default values -> "We assume this is always X"
- Missing error handling -> "We assume this never fails"
- Hardcoded limits -> "We assume volume stays under X"
- Missing validation -> "We assume input is always valid"
- No timeout -> "We assume this responds quickly"
- Single-instance patterns -> "We assume one server is enough"

### In Architecture
- Synchronous calls -> "We assume latency is low"
- Shared database -> "We assume no schema conflicts between services"
- No circuit breaker -> "We assume downstream services are reliable"
- No idempotency -> "We assume messages arrive exactly once"
- Coupled deployment -> "We assume services deploy together"

### In Plans
- Linear timeline -> "We assume no blockers or dependencies"
- Fixed scope -> "We assume requirements won't change"
- Available expertise -> "We assume someone on the team knows X"

## Detailed Technique

Read [cookbook/assumptions-matrix.md](./cookbook/assumptions-matrix.md)

---

Evidence standards: follow the [evidence-grounding](../evidence-grounding/SKILL.md) skill — the canonical source for evidence tiers, quality gates, and the counter-evidence obligation.
