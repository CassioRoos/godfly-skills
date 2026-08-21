# Eval kit

Fixtures for running this skill through [gauntlet](../../gauntlet/SKILL.md).

| File | What it is |
|---|---|
| `clinical-fixture.md` | Inpatient medication ordering, **Go**. Eleven planted defects, an oracle bait, and fabrication baits. |
| `clinical-fixture-ts.md` | The **same eleven defects in TypeScript/Node**. Use it to check that a change to the skill did not quietly overfit to one language. |
| `clinical-rubric.md` | Ground truth for both. **Judge eyes only** — never show it to an arm under test. |

## The language is incidental

A code-defect fixture has to be written in some language; that says nothing
about the skill's scope. The skill bodies contain no language-specific content,
and the two fixtures carry an identical defect set in Go and TypeScript
precisely so that claim is checkable rather than asserted.

The same applies to the domain. This fixture is clinical, and the previous
generation was financial, because the skill derives a harm model rather than
recalling a checklist — swapping the domain is the test of whether that works.

## Reproducing the published numbers

Scores quoted in the PR history were produced against `clinical-fixture.md`
(the Go variant), blind-judged with shuffled labels and a no-skill control arm
in every batch. The TypeScript variant has not been run through a full batch;
treat it as a fixture, not as a second result.

**Fixture health, honestly:** Tiers 1 and 2 are saturated — every arm, with and
without the skill, catches 8/8. They no longer discriminate. What still does is
the Tier 4 dependency defect, the oracle bait, fabrication, and epistemic
honesty. Replace or deepen the early tiers before drawing conclusions from them.
