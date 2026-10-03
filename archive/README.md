# Archived skills

These skills are parked for reference and possible restoration. They are outside
`skills/`, so the README installation commands do not copy them.

## 2026-10 consolidation

Archived on 2026-10-03: `assumptions-check`, `competing-hypotheses`, `deep-dive`,
`devils-advocate`, `failure-analysis`, `gauntlet`, `handoff`, `incident-validator`,
`premortem-postmortem`, `red-blue-review`, and `spec-adr-builder`.

- The adversarial lenses (assumptions, alternatives, failure modes, devil's
  advocate, red/blue, premortem) now live inside
  [adversarial-review](../skills/adversarial-review/SKILL.md) as reference files.
  Each lens kept its measured lessons; the standalone skills and their
  cross-links are gone.
- `assumptions-check` was benchmarked against a no-skill baseline (two rounds,
  Haiku executors, pre-registered assertions) and did not beat it; its template
  also led the model to file unverified plan claims as verified. That guard is
  now a rule in adversarial-review.
- `gauntlet` worked, but its LLM-judge step was too noisy to trust single
  verdicts (two judges scored identical text 25/100 apart). Skill testing moved
  to baseline-arm benchmarks with deterministic assertions.
- `deep-dive`, `handoff`, `spec-adr-builder`, and `incident-validator` saw no
  use and are retired to keep the set small.

Links inside these folders were adjusted so archived skills still resolve to
each other. Restore one by moving it back to `skills/` and reviewing its links.

## Godfly

[Godfly](godfly/SKILL.md) is archived as of 2026-09-08. Its review role overlaps
with Morpheus; keeping one active reviewer supports a simpler workflow.
The original instructions and all four cookbook references are retained, with
sibling-skill links adjusted for this location. Morpheus gains no new instructions
as part of this archive.

To restore it, move `archive/godfly/` back to `skills/godfly/`, change its
`../../skills/` sibling links back to `./../`, and update the README inventory,
diagram, and installation count. Review the instructions before installing.

Existing installed copies are independent of this repository. Archiving here
does not disable them; move those copies outside the host's skill discovery
directories separately.
