# Assumptions Check

Every plan rests on assumptions, and most of them are invisible. The dangerous
ones hide in design details ("3 replicas", "returns 200", "same payload
format"), not in stated claims.

## Steps

1. **Extract assumptions**, stated or implied, across these categories:
   technical, user, business, team, and environment. Read the design details
   for implied guarantees:
   - Defaults assume a value.
   - Missing error handling assumes the call never fails.
   - No timeout assumes a fast response.
   - Replicas assume no concurrency hazard.
   - Retries assume idempotency.
2. **Rate each one:** verified, confident, uncertain, untested, or fragile.
3. **Apply the rating rule.** An assumption is `verified` or `confident` only
   when a source independent of the artifact backs it: a test, measurement,
   doc, or log you read. A claim the plan makes about itself ("sandbox
   matches production", "the bank retries for 72h") stays `untested` however
   confident it sounds. This rule exists because a measured run filed exactly
   those claims under "verified".
4. **For every uncertain, untested, or fragile assumption:**
   - Invert it: what if the opposite is true?
   - Look for evidence that confirms or contradicts it.
   - Propose the cheapest test that would settle it.
   - State the impact if it's wrong.

## Brief

```markdown
### Critical (untested or fragile, high impact)
- [Assumption]: [why it matters] -> [cheapest test]

### Worth Investigating (uncertain, medium impact)
- [Assumption]: [current evidence] -> [what would change your mind]

### Backed by Evidence
- [Assumption]: [the independent source, cited]
```

Leave "Backed by Evidence" empty rather than filling it with restated plan
claims.
