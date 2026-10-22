# godfly-skills

**7 skills for Claude Code and Codex CLI: two reviewers that demand evidence,
a BDD method guide, and an ops toolkit that keeps the receipts. Plus the
operating guide that ties them into a working style.**

Read the code. Challenge the assumption. Run the test. Reach a verdict.
The point is to leave with a better decision and something you can verify.

## Why yet another skills repo? 🙃

Fair question. Another folder of prompts promising to turn your agent into a
principal engineer deserves a raised eyebrow. Here is the actual pitch.

**A strong opinion has to earn its place.**
Morpheus and adversarial-review ask for code, tests, logs, or documented evidence
before judging. They steelman your actual position, name what would change the
verdict, and yield when the evidence goes the other way. A challenge against an
argument you never made is just noise with confidence.

**Fewer skills, no overlap, no chains.**
This repository used to ship fifteen skills that pointed at each other. In measured
runs, some of them did no better than the model alone, and overlapping skills
make the model choose between near-duplicates. The set is now seven, each
self-contained: no skill needs another skill's file to do its job. A description
states what the skill is *not* for in plain words instead of routing to a sibling.

**Proof has receipts.**
MeanQA keeps cases and evidence under `.proof/`. UI-proof drives a real browser
and attaches screenshots, console, and network evidence. Safe-ops checks
authorization and reads back what changed. Toolshed preserves working state so
the next session can pick up the task without archaeological fieldwork.

## Choose a skill

| Situation | Skill |
|---|---|
| Focused second opinion, decisions, troubleshooting, research, idea evaluation, or a requested deploy watch | [morpheus](skills/morpheus/SKILL.md) |
| Structured adversarial review: red/blue team, premortem, devil's advocate, alternatives, failure modes (FMEA), assumptions, inversion, PR/incident gate | [adversarial-review](skills/adversarial-review/SKILL.md) |
| Run a QA campaign with persistent, re-runnable proof | [mean-qa](skills/mean-qa/SKILL.md) |
| Prove a UI change works in a real browser, with captured evidence | [ui-proof](skills/ui-proof/SKILL.md) |
| Execute an authorized remote, destructive, or security-relevant operation | [safe-ops](skills/safe-ops/SKILL.md) |
| Keep durable working state for one task | [toolshed](skills/toolshed/SKILL.md) |
| Discover, write, review, or evolve acceptance scenarios (Given / When / Then) | [bdd](skills/bdd/SKILL.md) |

Morpheus and adversarial-review overlap on purpose for now: both are installed
while they are compared. Expect one of them to be archived once the comparison
has evidence behind it.

Retired skills live in [archive/](archive/README.md), outside the installation set.

## Adversarial-review in one paragraph

One skill, several lenses, each in its own reference file and loaded only when
in play: red team / blue team, premortem, devil's advocate, competing alternatives,
failure modes (FMEA, dependency chains, known patterns), assumptions, inversion,
and a PR / incident-fix gate. Shared rules sit in `SKILL.md`: evidence is something
read this session; restating the plan is not evidence; a design promise is not a
control; never invent a number or a name. Every review ends in the same shape:
verdict, findings, what I cannot see, minimum bar to proceed, still contested.
It replaces the former standalone lens skills, which are archived.

## How Morpheus keeps its focus

Morpheus asks when an answer could materially change the result, groups independent
questions, and follows up as needed. Exhaustive interviewing is explicit-only.
Its instructions keep each probe tied to an unresolved question, stop investigation
once the answer is supported and required checks pass, and report blockers when
further probes add no evidence.

For active failures, its [troubleshooting reference](skills/morpheus/references/troubleshooting.md)
covers containment, reproduction, discriminating tests, and evidence-backed fixes.
Its [research reference](skills/morpheus/references/research.md) preserves the requested
question and recommends an option when a choice was requested.

For an idea or an experiment, its [evaluate reference](skills/morpheus/references/evaluate.md)
evaluates and does not build. The steps are:

1. Restate the idea as a falsifiable claim.
2. Give each assumption one deterministic check.
3. Measure the payoff ceiling first.
4. Run the cheapest kill test.
5. Fix the go/no-go thresholds before any data arrives.

Building waits for an explicit go. Example: a Redis cache for a query that takes
4 ms of an 820 ms p99 can win less than 1%. The verdict is to kill the idea or
redirect it, not to start a branch.

## BDD in one paragraph

BDD here is the method, not the tool. The skill orders the work: discover rules
and examples, then write scenarios, then automate. Gherkin is the output of the
writing step, not the method. It stops and asks when an example has no agreed
outcome. It keeps scenarios declarative and in domain language, with real
values and at least one failure path. For a failing scenario it decides between
three outcomes: fix the code, move the scenario, or delete it. The whole skill
is about 500 words, with no commands or scripts.

## Operating guide

[guides/AGENTS.md](guides/AGENTS.md) is the global instruction file these skills
are written to work with. It sets a principal-engineer lens, an evaluator stance
(challenge claims with evidence, evaluate ideas before building, ask decisions as
numbered questions with a recommendation and the strongest case against it),
pinned-evidence invariants, a technical writing style, and the rule to route
risky operations through safe-ops.

It is a guide, not a skill. Read it and keep the parts you agree with:

- Codex CLI reads `~/.codex/AGENTS.md`.
- Claude Code reads `~/.claude/CLAUDE.md`.

Merge the parts you want into your existing file. Do not overwrite the file.

## Working principles

- **Investigate before judging.** Read the real code, configuration, tests, or
  runtime evidence. Separate observations from inferences and guesses.
- **Steelman before challenging.** Preserve the user's actual position and
  constraints. Evidence-backed approval is a valid result.
- **Try to break your own verdict.** Name what would overturn it and run the
  cheapest useful check. Say what you could not test.
- **Keep authorization explicit.** Safe-ops previews material effects, executes
  the authorized scope, and reads back the result. A review does not authorize
  publication; a PR does not authorize a merge or deployment.
- **State is mortal; useful evidence survives.** MeanQA keeps `.proof/` artifacts.
  Toolshed keeps `docs/work/<slug>/` until close, when surviving decisions and
  evidence move to permanent homes.
- **Aim at the code, never the person.** During incidents, drop the wit:
  blocker, impact, containment, next action.

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

Both copy commands install the same 7 skill folders. Individual skills can also
be symlinked. Host-specific paths and tool instructions may need adaptation. Tool access and permissions come
from the host runtime, not from a skill file.

### Updating an existing installation

Review and back up the installed folders you intend to replace. Copying over an
older installation does not remove obsolete files inside retained skills, and it
does not remove skills this repository no longer ships. Replace each retained
folder wholesale (delete it, then copy), rather than copying over it.

These skills are no longer in the installation set and are now in
[archive/](archive/README.md): `assumptions-check`, `competing-hypotheses`,
`deep-dive`, `devils-advocate`, `failure-analysis`, `gauntlet`, `handoff`,
`premortem-postmortem`, `red-blue-review`, `spec-adr-builder` (and, earlier,
`godfly`). Earlier releases also dropped `root-cause`, `evidence-grounding`,
`deployment-monitor`, `troubleshooting-investigator`, and `incident-validator`.
Move any installed copies outside your host's skill discovery directories if you
want the current selection. Updating this clone alone does not change copied
installations.

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
do not validate later instruction changes.

The [completion diagnostic](evals/morpheus/results/2026-09-09-completion/README.md)
compared no skill, current-main Morpheus, and the completion revision on three
synthetic tasks. All nine runs passed, including the control; the revision used
more input tokens without demonstrating better correctness. This is a small
diagnostic, not evidence of superiority. [Re-runnable fixtures and independent
checks](evals/morpheus/controlled/README.md) cover implementation, approval of correct
work, and a justified missing-policy blocker. Smaller instructions alone do not
establish better task completion.

Two parts are not measured yet. Morpheus evaluate mode has a fixture (eval 11,
[`evals/morpheus/files/idea/`](evals/morpheus/files/idea/METRICS.md)), but no
published run. BDD has no eval. Treat both as unproven until a run compares
them with the no-skill control.

## License

[MIT](LICENSE)
