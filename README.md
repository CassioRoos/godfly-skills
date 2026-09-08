# godfly-skills

**16 skills for evidence-backed engineering review, analysis, QA, incident
validation, and task continuity.** The collection includes the existing Godfly
reviewer and Morpheus, synced from the local Codex skills alongside the retained
analysis and operations skills.

The standalone `root-cause`, `evidence-grounding`, `deployment-monitor`, and
`troubleshooting-investigator` skills are no longer included. Retained skills
carry their evidence rules directly, use Morpheus's troubleshooting reference,
or point to project runbooks for operational procedures.

## Choose a skill

| Situation | Skill |
|---|---|
| A concise second opinion, engineering verdict, or choice between options | [morpheus](skills/morpheus/SKILL.md) |
| Godfly's adversarial review protocol, commands, and durable verdict graph | [godfly](skills/godfly/SKILL.md) |
| Surface and test hidden assumptions | [assumptions-check](skills/assumptions-check/SKILL.md) |
| Compare architecture, technology, or strategy options | [competing-hypotheses](skills/competing-hypotheses/SKILL.md) |
| Map a working but unfamiliar system | [deep-dive](skills/deep-dive/SKILL.md) |
| Prioritize component and dependency failure modes | [failure-analysis](skills/failure-analysis/SKILL.md) |
| Make the strongest case for the opposing position | [devils-advocate](skills/devils-advocate/SKILL.md) |
| Examine attack paths and prevention, detection, containment, and recovery | [red-blue-review](skills/red-blue-review/SKILL.md) |
| Anticipate a failure or write an evidence-backed postmortem | [premortem-postmortem](skills/premortem-postmortem/SKILL.md) |
| Run a QA campaign with persistent, re-runnable proof | [mean-qa](skills/mean-qa/SKILL.md) |
| Validate incident handovers, fix PRs, and closure claims | [incident-validator](skills/incident-validator/SKILL.md) |
| Execute an authorized remote, destructive, or security-relevant operation | [safe-ops](skills/safe-ops/SKILL.md) |
| Keep durable working state for one task | [toolshed](skills/toolshed/SKILL.md) |
| Hand work to another session without reconstructing the thread | [handoff](skills/handoff/SKILL.md) |
| Write a technical spec, ADR, or RFC | [spec-adr-builder](skills/spec-adr-builder/SKILL.md) |
| Test whether a skill improves results against a no-skill control | [gauntlet](skills/gauntlet/SKILL.md) |

Godfly and Morpheus overlap on review requests. Select one explicitly when the
choice matters: Godfly retains its command-driven review and verdict graph;
Morpheus emphasizes a concise verdict with cited findings, tradeoffs, and proof.
Neither is proof that a change is safe merely because its instructions were read.

For active failures, Morpheus includes a
[troubleshooting reference](skills/morpheus/references/troubleshooting.md) with
containment, reproduction, ranked hypotheses, discriminating tests, and regression
proof. Post-deploy monitoring follows the project's runbook and live read-only
evidence; incident-validator assesses the resulting closure evidence.

## Working principles

- **Investigate before judging.** Read the real code, configuration, tests, or
  runtime evidence. Separate observations from inferences and guesses.
- **Steelman before challenging.** Preserve the user's actual position and
  constraints. Evidence-backed approval is a valid result.
- **Test the verdict.** Name what would overturn it and run the cheapest useful
  check when it is available. Report untested boundaries.
- **Keep authorization explicit.** Safe-ops previews material effects, executes
  the authorized scope, and reads back the result. A review does not authorize
  publication; a PR does not authorize a merge or deployment.
- **Keep proof durable.** MeanQA records cases and artifacts under `.proof/`;
  Toolshed holds task state under `docs/work/<slug>/`, with surviving decisions
  and evidence promoted before close.
- **Challenge the work, never the person.** Intensity follows the stakes.

## Install

Clone once:

```bash
git clone https://github.com/CassioRoos/godfly-skills.git
```

For Claude Code:

```bash
mkdir -p ~/.claude/skills
cp -R godfly-skills/skills/* ~/.claude/skills/
```

For Codex CLI:

```bash
mkdir -p ~/.codex/skills
cp -R godfly-skills/skills/* ~/.codex/skills/
```

Review and back up existing skill folders before updating an installation.
Copying over an older installation does not remove retired skill directories or
obsolete files inside retained skills. To match this repository, replace the
selected installed folders with the corresponding repository folders and remove
the four retired skills from that installation deliberately.

Individual skills can also be symlinked. Install the sibling skills referenced
by the workflows you use. Optional skills named in references are not necessarily
bundled here; check availability before invoking them. Tool access and permissions
come from the host runtime, not from a skill file.

## Validation and evals

Helper checks run against temporary fixtures:

```bash
sh skills/toolshed/scripts/acceptance.sh
python3 skills/toolshed/scripts/close-regressions.py
sh skills/mean-qa/scripts/acceptance.sh
python3 skills/safe-ops/scripts/acceptance.py
```

These checks validate helper behavior, not model review quality. Behavioral eval
fixtures, judge rubrics, and historical example runs live in [evals/](evals/README.md),
outside the installable skill directories. Keep judge answer keys out of the arm
being evaluated. Paths in `evals/morpheus/evals.json` are relative to this repository
root. Existing published runs describe the versions exercised at the time; they
do not validate the current imported skills.

## License

[MIT](LICENSE)
