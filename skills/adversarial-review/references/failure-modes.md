# Failure Analysis

Don't ask "what could go wrong?" -- that's too vague. Ask "what SPECIFICALLY fails, how bad is it, and would you even notice?"

## Core Principle

Shallow failure analysis produces a list of scary-sounding risks. Structured failure analysis produces a prioritized list of specific failure modes with severity, detectability, and mitigation. The difference is actionable vs. anxiety-inducing.

**The invented-number rule.** This lens was measured producing eighteen
fabricated Probability figures on a codebase with no telemetry, then reasoning
from the totals it had invented -- scoring far worse than no guidance at all on the
same task. The template did that, not the model: a table with a slot for every
factor gets every slot filled. So: never emit a number you could not source, and
never let a ranking depend on one. An analysis that says `UNDETERMINED` in nine
rows out of nine is a good analysis if nine rows had no data. Confident
precision on absent evidence is the failure this lens exists to prevent, and
the one it is most likely to commit.

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

Two of the three FMEA factors are derivable from the artifact in front of you.
One is not. Treat them differently.

| Factor | Scale | Derivable from code/config? | Question |
|--------|-------|------------------------------|----------|
| **Severity** | 1-10 | **Yes** -- from blast radius | How bad is the impact when this fails? |
| **Detectability** | 1-10 | **Yes** -- from whether a log, metric, alert, or reconciliation exists | How hard is it to NOTICE? (10 = silent) |
| **Probability** | 1-10 | **No** -- needs history or volume data | How likely is this to happen? |

**Rule: Probability requires a cited source.** Incident history, traffic volume,
error-rate data, or a documented prior occurrence -- named, with where you read
it. If you do not have one, write `UNDETERMINED` and move on. Never infer
Probability from "similar systems usually", from how plausible the failure feels,
or from the severity of its consequences.

**Rank by Severity x Detectability.** That product is computable from the
artifact and is what actually orders the work. Do not multiply in a Probability
you had to invent -- a fabricated factor does not become evidence by being
multiplied by two real ones.

When Probability *is* sourced, say so inline and let it raise a finding's rank.
It never lowers one: "unlikely" is not a reason to skip a silent, catastrophic
failure.

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

Group by the decision the reader has to make, not by a score. A number that
changes no decision does not belong in the output.

```
## Failure Analysis

### Blocks release
- **[Failure mode]**: [What specifically happens]
  Severity: X (why) | Detectability: Y (what would or would not catch it)
  Probability: UNDETERMINED -- no volume or incident data in scope
  Mitigation: [Specific action]

### Ship only with detection added
- **[Failure mode]**: [What specifically happens]
  Severity: X (why) | Detectability: Y (what would or would not catch it)
  Probability: 8 -- INC-482 timeline, this fired twice in the 14:02-14:26 window
  Mitigation: [Specific action]

### Accept, with the risk stated
- **[Failure mode]**: [Why it is tolerable and who is accepting it]

### Dependency Chain Risks
- [Link A -> Link B]: [What breaks and why]
  Current protection: [What exists] | Gap: [What's missing]

### Patterns Detected
- [Pattern name]: [Where it exists in the code] -> [Specific fix]

### What I could not determine
- [Each unreadable input, and the one artifact that would settle it]
```

Note the two Probability lines above: one cites a source, the other says
`UNDETERMINED`. Both are correct outputs. A table where every row carries a
confident number is the failure state, not the goal -- on a codebase with no
telemetry, `UNDETERMINED` in every Probability cell is the honest and expected
result.

## Deeper References

- [failure-fmea.md](failure-fmea.md) -- FMEA deep dive with engineering examples
- [failure-dependency-chain.md](failure-dependency-chain.md) -- tracing and analyzing dependency chains
- [failure-known-patterns.md](failure-known-patterns.md) -- known failure patterns by domain
