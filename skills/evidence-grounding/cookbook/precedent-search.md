# Precedent Search

## Finding Real-World Evidence

When challenging a decision or proposing an alternative, find teams that have actually tried both approaches. Their experience is Tier B evidence -- stronger than best practices, weaker than local measurements.

## Search Patterns

### Finding Failures

Search for teams that tried the proposed approach and hit problems:

```
"[technology/pattern] post-mortem"
"[technology/pattern] lessons learned"
"[technology/pattern] migration regret"
"why we stopped using [technology]"
"[technology] at scale problems"
"[technology] production issues"
```

### Finding Successes

Search for teams that successfully use the proposed approach:

```
"[technology/pattern] in production"
"how we use [technology] at [scale]"
"[technology] case study"
"[technology] architecture [industry]"
```

### Finding Comparisons

Search for teams that evaluated the same options:

```
"[option A] vs [option B] production"
"why we chose [option A] over [option B]"
"migrating from [option A] to [option B]"
"[option A] vs [option B] at scale"
```

## Evaluating Precedent Quality

Not all precedents are equally relevant:

| Factor | Strong Precedent | Weak Precedent |
|--------|-----------------|----------------|
| **Scale** | Similar to your system | Netflix-scale when you have 100 users |
| **Domain** | Same problem domain | Different domain, same technology |
| **Recency** | Last 2-3 years | 5+ years ago (technology changes) |
| **Detail** | Specific metrics and outcomes | Vague conclusions |
| **Source** | Engineering blog with data | HN comment or tweet |
| **Outcome** | Measured results | Opinions about results |

## Context Matching

A precedent from a team at a different scale, domain, or stage can be misleading. Always check:

1. **Scale match:** Are they operating at similar volume?
2. **Team match:** Do they have similar team size and expertise?
3. **Stage match:** Are they at a similar product maturity?
4. **Constraint match:** Do they have similar constraints (compliance, latency, budget)?

## Presenting Precedent Evidence

Format:
```
PRECEDENT (Tier B): [Company/Team] [did X] and experienced [outcome].
CONTEXT: [Scale, domain, timeframe]
RELEVANCE: [Why this applies to our situation]
CAVEAT: [How our context differs]
SOURCE: [URL]
```

Example:
```
PRECEDENT (Tier B): Segment reversed their microservices architecture back to a monolith
after 2 years, citing operational complexity that exceeded their team's capacity.
CONTEXT: ~100 engineers, data infrastructure, 2018-2020
RELEVANCE: Similar team size, similar data pipeline architecture, similar scaling challenges.
CAVEAT: Their traffic patterns differ (event streaming vs. our batch sync).
SOURCE: [Segment engineering blog]
```
