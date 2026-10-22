# Archived skills

These skills are parked for reference and possible restoration. They are outside
`skills/`, so the README installation commands do not copy them.

## 2026-10 consolidation

Archived on 2026-10-03: `assumptions-check`, `competing-hypotheses`, `deep-dive`,
`devils-advocate`, `failure-analysis`, `gauntlet`, `handoff`,
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
- `deep-dive`, `handoff`, and `spec-adr-builder` saw no use and are retired to
  keep the set small.

Links inside these folders were adjusted so archived skills still resolve to
each other. Restore one by moving it back to `skills/` and reviewing its links.

## Godfly

[Godfly](godfly/SKILL.md) was archived on 2026-09-08. Morpheus is the active
reviewer. One reviewer keeps the workflow simple.

The archived copy keeps the original instructions and all four cookbook
references. Its eval fixtures and rubric are in [evals/godfly/](../evals/godfly/).
Its sibling links point at skills that are also archived, so they resolve
inside this folder.

To restore it:

1. Move `archive/godfly/` to `skills/godfly/`.
2. Restore each sibling it links to, or remove that link. Every sibling it
   links to is archived.
3. Add it to the README skill table and the installation count.
4. Review the instructions before you install it.

Installed copies do not depend on this repository. Archiving here does not
disable them. Move those copies outside the host's skill discovery directories.
