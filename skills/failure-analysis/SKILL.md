---
name: failure-analysis
description: >
  Structured failure mode analysis for code, architecture, and systems. Uses FMEA
  (Failure Mode and Effects Analysis), dependency chain analysis, and real-world
  failure pattern matching. Use when evaluating system reliability, reviewing
  architecture, or assessing risk. Triggers on "how could this fail", "what breaks",
  "risk assessment", "failure mode", "reliability", "single point of failure", or
  when reviewing any system that must not fail silently.
allowed-tools: Read, Grep, Glob
metadata:
  version: "1.0"
---

# Failure Analysis

Don't ask "what could go wrong?" -- that's too vague. Ask "what SPECIFICALLY fails, how bad is it, and would you even notice?"

## Core Principle

Shallow failure analysis produces a list of scary-sounding risks. Structured failure analysis produces a prioritized list of specific failure modes with severity, probability, detectability, and mitigation. The difference is actionable vs. anxiety-inducing.

## When to Use

- Reviewing architecture before implementation
- Evaluating error handling in critical paths
- Assessing infrastructure and deployment changes
- Before irreversible decisions (data migrations, public API contracts)
- When someone says "that won't happen" without analysis

## Technique 1: FMEA (Failure Mode and Effects Analysis)

For each component or decision point:

### Step 1: Identify Failure Modes

What can go wrong? Be specific -- not "the database fails" but "write timeout on the invoices table during peak load when batch processing overlaps with API traffic."

### Step 2: Rate Each Failure Mode

| Factor | Scale | Question |
|--------|-------|----------|
| **Severity** | 1-10 | How bad is the impact when this fails? |
| **Probability** | 1-10 | How likely is this to happen? |
| **Detectability** | 1-10 | How hard is it to NOTICE this failure? (10 = silent failure) |

**Risk Priority Number (RPN)** = Severity x Probability x Detectability

| RPN Range | Priority | Action |
|-----------|----------|--------|
| 200+ | Critical | Must address before shipping |
| 100-199 | High | Should address, or add monitoring |
| 50-99 | Medium | Document and monitor |
| <50 | Low | Accept the risk |

### Step 3: Focus on Silent Failures

The most dangerous failures are the ones with HIGH Detectability scores -- failures you won't notice until the damage is done. Prioritize these over dramatic but obvious failures.

A database going down is loud. Data being silently corrupted for weeks is catastrophic.

## Technique 2: Dependency Chain Analysis

### Step 1: Map the Chain

For a given operation, trace every dependency:

```
User Request -> API Gateway -> Auth -> Handler -> Database -> Queue -> Consumer -> External API
```

### Step 2: Ask at Each Link

- What happens if this link fails completely?
- What happens if this link is slow (not failed, just 10x slower)?
- Is there a timeout? What happens when it fires?
- Is there retry logic? Can retries cause duplication?
- Is there a fallback? Is the fallback tested?
- What happens when this link comes BACK after being down?

### Step 3: Find Cascading Failures

Where does a failure in component A cause component B to fail, which causes C to fail? These cascade chains are where outages come from.

Look for:
- Missing circuit breakers between services
- Shared resource contention (connection pools, thread pools)
- Retry storms that amplify failures
- Health checks that don't catch degraded states

## Technique 3: Known Failure Patterns

Common failure patterns to check for:

| Pattern | Description | Check |
|---------|-------------|-------|
| **Thundering herd** | All retries/reconnects fire simultaneously after an outage | Do retries have jitter? |
| **Cascading timeout** | Upstream timeout < downstream timeout | Are timeouts configured end-to-end? |
| **Poison pill** | One bad message kills the consumer repeatedly | Is there dead-letter handling? |
| **Split brain** | Two components disagree on state | Is there a single source of truth? |
| **Data inconsistency** | Write succeeds but side-effect fails | Are operations transactional? |
| **Silent corruption** | Data is wrong but no error is raised | Is there validation on read AND write? |
| **Unbounded growth** | Queue/table/log grows without limit | Are there retention policies? |
| **Zombie process** | Process appears alive but isn't doing work | Do health checks verify actual work? |
| **Clock skew** | Timestamps disagree across services | Are you using server-side timestamps? |
| **Connection leak** | Connections opened but never closed | Are connections managed with defer/finally? |

## Output Format

```
## Failure Analysis

### Critical (RPN 200+)
- **[Failure mode]**: [What specifically happens]
  Severity: X | Probability: Y | Detectability: Z | RPN: XYZ
  Mitigation: [Specific action]

### High (RPN 100-199)
- **[Failure mode]**: [What specifically happens]
  Severity: X | Probability: Y | Detectability: Z | RPN: XYZ
  Mitigation: [Specific action]

### Dependency Chain Risks
- [Link A -> Link B]: [What breaks and why]
  Current protection: [What exists] | Gap: [What's missing]

### Patterns Detected
- [Pattern name]: [Where it exists in the code] -> [Specific fix]
```

## Detailed Techniques

- [cookbook/failure-modes.md](./cookbook/failure-modes.md) -- FMEA deep dive with engineering examples
- [cookbook/dependency-chain.md](./cookbook/dependency-chain.md) -- Tracing and analyzing dependency chains
- [cookbook/real-failures.md](./cookbook/real-failures.md) -- Known failure patterns by domain

---

Evidence standards: follow the [evidence-grounding](../evidence-grounding/SKILL.md) skill — the canonical source for evidence tiers, quality gates, and the counter-evidence obligation.
