---
name: evidence-grounding
description: >
  Ground every challenge, claim, and alternative in real evidence. Search codebases
  for existing patterns, find real-world precedents and post-mortems, and validate
  claims against data. Use when making or evaluating technical claims, proposing
  alternatives, or challenging decisions. Triggers on "show me evidence", "prove it",
  "is this actually true", "back this up", "is this grounded", "evidence check",
  or whenever a challenge needs substantiation. Also the canonical evidence-standards
  reference that the analysis-spine skills link to instead of restating.
metadata:
  version: "1.0"
allowed-tools: Read, Grep, Glob, WebSearch
---

# Evidence Grounding

No challenge without evidence. No alternative without proof it works. No claim without data.

## Canonical Library

This skill is the single source of truth for evidence standards. Other skills
(the whole analysis spine: godfly, assumptions-check, competing-hypotheses,
failure-analysis, devils-advocate, red-blue-review, premortem-postmortem,
root-cause, troubleshooting-investigator, deep-dive) that need
evidence tiers, quality gates, or the counter-evidence obligation must link here
instead of restating these rules. If another skill's evidence language conflicts
with this one, the tiers and gates defined here win. It also works standalone --
invoke it directly for "prove it", "back this up", "is this grounded", or
"evidence check" requests.

## Core Principle

The difference between a useful challenge and noise is EVIDENCE. "This won't scale" is noise. "Your current query does a full table scan on a 10M row table with no index on the filter column -- here's the query plan" is evidence. This skill ensures every challenge is grounded in reality.

## Evidence Hierarchy

Not all evidence is equal. Rate what you find:

| Tier | Type | Example | Weight |
|------|------|---------|--------|
| **S** | Measured data from this system | "Your p99 latency is 2.3s, here's the trace" | Definitive |
| **A** | Code/config in this codebase | "Line 47 of the request handler does not roll back on failure" | Strong |
| **B** | Production post-mortem from similar system | "Segment reversed their microservices -- same pattern" | Strong |
| **C** | Documented best practice with rationale | "Go team recommends X because Y" | Moderate |
| **D** | General industry pattern | "Most teams at this scale use X" | Weak |
| **F** | Opinion or convention | "Everyone does it this way" | Reject |

**Rule: Never present a challenge backed only by Tier D or F evidence.**

## Evidence Gathering Process

### 1. Codebase Evidence (Tier A)

Search the actual codebase for relevant patterns:
- Use `Grep` to find existing implementations of the pattern in question
- Use `Glob` to find related files and modules
- Use `Read` to understand context around specific code
- Trace dependency chains and call graphs
- Check test coverage for the area in question

Questions to answer:
- Does the codebase already solve this problem elsewhere?
- Are there existing patterns that contradict the proposed approach?
- What does the test coverage look like for this area?
- Are there related TODO/FIXME/HACK comments?

### 2. Precedent Search (Tier B-C)

Search for real-world experiences:
- Use `WebSearch` for post-mortems, case studies, tech blog posts, and primary docs
- Search for "[technology] failure", "[pattern] post-mortem", "[approach] lessons learned"
- Look for Architecture Decision Records from similar projects
- Find conference talks where teams share what went wrong

Effective search patterns:
- `"{technology} post-mortem"` -- find real failures
- `"{pattern} at scale lessons"` -- find scaling challenges
- `"{library} vs {library} production"` -- find real comparisons
- `"{approach} migration regret"` -- find teams that reversed course

### 3. Documentation Evidence (Tier C)

Check official sources:
- Language/framework official documentation
- Style guides with rationale (Go wiki, Uber Go guide, etc.)
- RFC documents for standards
- Security advisories for vulnerability claims

### 4. Quality Validation

Before presenting evidence, check:

| Check | Question |
|-------|----------|
| **Relevance** | Does this evidence actually apply to this specific situation? |
| **Recency** | Is this still current? Technologies change. |
| **Scale match** | Does the evidence come from a similar scale/context? |
| **Completeness** | Am I cherry-picking? Is there counter-evidence? |
| **Reproducibility** | Can the user verify this themselves? |

**Embarrassment check**: before finalizing a negative claim, ask what one query, log
search, file read, or artifact check would immediately disprove it. Run that
check when available.

## Output Format

Every evidence-backed claim should follow:

```
CLAIM: [What you're asserting]
EVIDENCE: [Specific data/code/precedent] (Tier X)
SOURCE: [Where this comes from -- file:line, URL, or measurement]
COUNTER-EVIDENCE: [Anything that contradicts this, if it exists]
CONFIDENCE: [High/Medium/Low based on evidence quality]
```

## Anti-Patterns

| Anti-pattern | Why it fails |
|-------------|-------------|
| "This is a well-known problem" | Name it. Cite it. Or it's not evidence. |
| "Best practices say..." | Whose? Published where? With what rationale? |
| "In my experience..." | Experience is a starting point for investigation, not evidence. |
| "Everyone uses X" | Popularity is not proof of fitness for YOUR context. |
| "This is obviously wrong" | If it's obvious, the evidence should be easy to find. Find it. |

## Detailed Techniques

- [cookbook/codebase-evidence.md](./cookbook/codebase-evidence.md) -- Patterns for searching codebases effectively
- [cookbook/precedent-search.md](./cookbook/precedent-search.md) -- Finding real-world failures and successes
- [cookbook/quality-check.md](./cookbook/quality-check.md) -- Validating evidence before presenting
