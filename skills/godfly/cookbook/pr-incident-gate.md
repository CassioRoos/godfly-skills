# PR And Incident Review Gate

Use this gate whenever reviewing a PR, branch, incident fix, production
reliability change, payment/data-integrity path, or any change whose title/body
claims to fix a concrete failure. Green tests and an approved PR don't exempt you.

## The Gate

Before giving a verdict:

1. **Fetch live PR state**: current head, base, files, commits, PR body, review
   state, checks (`gh pr view/diff/checks`). Stale UI/review summaries are
   routing hints, not truth. If live state can't be fetched, mark this gate
   `unknown`, label the whole output **unverified-state**, and anchor every
   finding to the diff text in hand -- diffs don't go stale the way summaries do.
2. **Map symptom to culprit path**: the production symptom in plain language,
   the exact query/function/queue/state machine that caused it, and the call
   chain that reaches it.
3. **Compare old offender vs changed code**: does the PR modify the offender
   itself, only gate entry to it, or only fix a neighboring path?
4. **List surviving paths**: unmodified full scans, unbounded loops, ungated
   REST/admin/shadow paths, retry/fanout paths, integration-specific variants
   that can still reach the offender.
5. **Verify every new guard's data source**: a check, flag, or dedup gate is
   only real if its data is populated by a **production write path** -- not by
   tests, backfills, or scripts. A guard reading state nothing writes is a
   no-op wearing a diff.
6. **Check non-target blast radius**: for shared publishers/workers/registries,
   verify behavior for every registered caller class, especially when a new
   interface/type-assertion/fallback changes behavior outside the incident target.
7. **Separate mitigation from fix**: label it `fix`, `mitigation`, `containment`,
   `partial`, or `no-op`. If the original failure can still recur under a
   credible input, it is not a fix; if the change cannot alter production
   behavior at all (gate 5 failed), it is a `no-op` -- and a merged no-op is
   worse than nothing, because it closes the incident while the bug lives.
8. **Demand workflow proof**: tests that only prove a helper are not enough.
   I want a regression that drives the real boundary: published message, DB
   query shape, queue fanout, state transition, or runtime log. The proof
   must be **capable of failing**: a replay or test whose result is the same
   whether the fix works or is inert has no positive control and proves
   nothing, whatever environment it ran in. A test-only
   helper that fabricates state (seeding the row the handler never writes) is
   not just weak proof -- it is **positive evidence of a missing production
   write path**. Treat it as a finding, not a gap.
9. **Check observability**: can operators see the decisive branch in
   logs/metrics -- what was skipped, what was published, what fallback fired,
   which correlation IDs identify the flow?

If a gate can't be answered from local code/PR state, mark it `unknown` and name
the fastest evidence to close it. Unknown is acceptable; pretending is bullshit.

## Incident PR Verdict Matrix

For incident PRs, the verdict includes this matrix:

```markdown
| Claim | Evidence | Verdict |
|---|---|---|
| Original offender changed? | file/function/query/log | yes/no/partial |
| All entry paths gated? | searched paths | yes/no/unknown |
| Full/unbounded path remains? | file/function/query | yes/no |
| Cross-integration behavior safe? | callers/registrations checked | yes/no/unknown |
| Guard data source populated in production? | writer path | yes/no/n-a |
| Regression reaches real boundary? | test/log/metric | yes/no/partial |
| Mitigation or fix? | reason | fix/mitigation/containment/partial/no-op |
```

Settled matrix rows with Tier S/A evidence are verdict-graph material: the
node's `claim` is the row's Claim restated as an assertion, its `verdict` is
`held` when the row confirmed it. Write them so the next incident review
starts from proof, not from scratch (read `verdict-graph.md`).
