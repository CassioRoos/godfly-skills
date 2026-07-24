---
name: root-cause
description: "Causal-chain analysis after something already happened: trace a symptom to its systemic cause using evidence-backed Five Whys and first-principles constraint challenges. Use for root cause, why did this really happen, underlying or systemic cause, and incident causal analysis once the immediate failure is understood. For a system failing right now use troubleshooting-investigator; for understanding a working system use deep-dive; for writing the postmortem document use premortem-postmortem, which uses this skill for its causal-analysis step."
allowed-tools: Read, Grep, Glob
---

# Root Cause - Post-Hoc Causal-Chain Analysis

Something already happened. The fire is out, the immediate failure is understood. Now trace the symptom back through an evidence-backed causal chain to the systemic cause the team can actually change.

## Quick Start

1. State the symptom in specific, observable terms (with timestamp/scope)
2. Build the why-chain — every link cites evidence, branches allowed
3. Stop at a changeable systemic cause, then challenge the constraint that produced it
4. Emit the output contract: causal chain table, contributing factors, fix targets

## Not This Skill

| Situation | Use instead |
|-----------|-------------|
| System is failing right now | troubleshooting-investigator |
| Understanding a working system | deep-dive |
| Writing the postmortem document | premortem-postmortem (which calls this skill for causal analysis) |

## Techniques

### Evidence-Backed Five Whys
Chain backward from symptom to systemic cause. Every "why" answer must cite evidence — a log line, code path, config value, data record, or timeline fact. Narrative answers without evidence are rejected and recorded as assumptions, not links.

Read [cookbook/five-whys.md](./cookbook/five-whys.md)

### Constraint Challenge (First Principles)
Once the chain reaches a systemic cause, identify the inherited assumption or constraint that produced it and test whether it still holds. This is where "fix the bug" becomes "fix the system that made the bug inevitable".

Read [cookbook/first-principles.md](./cookbook/first-principles.md)

### Wrong-Problem Check
Sometimes the chain terminates not in a broken mechanism but in "the system was solving the wrong problem". When that happens, ask what job the system was actually hired to do — the failure is a mismatch between the job and the design, and the fix target is the design premise, not the code.

## Output Contract

Every analysis produces:

1. **Causal chain table**: symptom → why-1..n → systemic cause, with evidence cited per link (assumptions explicitly flagged)
2. **Contributing factors list**: branch causes that enabled or amplified the failure
3. **Recommended fix targets**: the changeable process, design, or constraint per root — never "person X should be more careful"

## Core Principles

1. **Symptoms lie** - Surface problems hide deeper causes
2. **Evidence or assumption** - Every causal link is one or the other; label which
3. **Never stop at human error** - Ask why the system let the error matter
4. **Multiple roots** - Chains branch; follow each branch to its own root
5. **Stop at changeable** - The root is the deepest cause the team can actually change

## Warning Signs You Need This

- "We've fixed that already" (but it came back)
- The fix was a patch on the symptom, not the cause
- The incident report says "human error" and stops
- The same class of failure recurs across unrelated components
- Nobody can say why a design decision that caused the failure was made

---

Evidence standards: follow the [evidence-grounding](../evidence-grounding/SKILL.md) skill — the canonical source for evidence tiers, quality gates, and the counter-evidence obligation.
