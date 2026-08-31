# Evals

Fixtures, rubrics, and published example runs for the skills in `skills/`.

**This directory is deliberately not inside any skill.** `skills/` is what gets
installed into `~/.claude/skills/`, and eval material must not travel with it:

- **Rubrics are answer keys.** `mean-qa/aqueduct/GROUND-TRUTH.md`,
  `mean-qa/clinical-rubric.md` and `godfly/pr-review-rubric.md` are judge-only. A
  gauntlet arm runs *with the skill installed*, so a rubric inside the skill
  directory is a rubric the arm under test can read. That invalidates the round
  silently, which is the worst way for it to happen.
- **Published runs are large and are not instructions.**
  `mean-qa/aqueduct/example-run/` is 4.6 MB — most of this repository — and nothing
  in any SKILL.md points at it. Bundled files cost no context until read, but an
  unsignposted 1,400-line report sitting in a skill directory is one stray read away
  from costing more than the whole skill.

Eval material belongs here. Skills belong in `skills/`.
