# godfly-skills

**16 skills for evidence-backed engineering review, analysis, QA, incident
validation, and task continuity.** Morpheus provides focused investigation and
engineering judgment; Godfly provides an alternative review protocol with commands
and a durable verdict graph. The remaining skills handle specific tasks when needed.

## Choose a skill

| Situation | Skill |
|---|---|
| Focused review, decisions, troubleshooting, research, or a requested deploy watch | [morpheus](skills/morpheus/SKILL.md) |
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

Morpheus asks when an answer could materially change the result, groups independent
questions, and follows up as needed. Exhaustive interviewing is explicit-only.
Its instructions keep each probe tied to an unresolved question, stop investigation
once the answer is supported and required checks pass, and report blockers when
further probes add no evidence. They do not impose a fixed question or hypothesis
quota or automatically chain other skills.

For active failures, its [troubleshooting reference](skills/morpheus/references/troubleshooting.md)
covers containment, reproduction, discriminating tests, and evidence-backed fixes.
Its [research reference](skills/morpheus/references/research.md) preserves the requested
question and recommends an option when a choice was requested.

Deployment watching runs only when requested: pin the deployed version, baseline,
success signal, and end time; compare read-only signals on cadence; corroborate
delivery with durable outcomes; report anomalies and coverage gaps. Use the project's
runbook for operational procedures. Incident-validator separately assesses incident
artifacts against its resolved production-issue standard; it includes a dated
fallback snapshot when the live standard cannot be reached.

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

The commands below are for a fresh installation. For an existing installation,
review the upgrade notes below before copying over skill folders.

Clone the repository:

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

Both copy commands install the same 16 skill folders. Individual skills can also
be symlinked. Install the sibling skills referenced by the workflows you use;
optional skills named in references are not necessarily bundled here. Host-specific
paths and tool instructions may need adaptation. Tool access and permissions come
from the host runtime, not from a skill file.

### Updating an existing installation

Review and back up the installed folders you intend to replace. Copying over an
older installation does not remove obsolete files inside retained skills.
Replace the selected folders with the corresponding repository folders.

The standalone `root-cause`, `evidence-grounding`, `deployment-monitor`, and
`troubleshooting-investigator` skills are no longer included. Remove their installed
folders deliberately if you want the repository's current selection. Useful evidence,
troubleshooting, causal-analysis, and watch guidance now lives in retained skills;
this is a consolidation, not a feature-for-feature replacement of every old workflow.
Updating this clone alone does not change copied installations.

## Validation and evals

Run these helper checks from the cloned `godfly-skills` directory, with Git,
Python 3, and a POSIX shell available. They use temporary fixtures:

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
do not validate later instruction changes. Morpheus's clarification and investigation
revision has structural validation but no behavioral A/B result yet. Smaller
instructions alone do not establish better task completion.

## License

[MIT](LICENSE)
