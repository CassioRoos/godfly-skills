---
name: gauntlet
description: >
  Empirically test whether a skill actually improves model output — before
  trusting it. Runs a controlled experiment: planted-flaw fixture, no-skill
  control arm, skill arm(s), optional cross-model arms via installed CLIs,
  blind judging with shuffled labels, and a pressure test for verdict
  stability. Produces adopt/fix/reject verdicts and turns every finding into
  a permanent rule in the skill under test. Use for "test this skill",
  "validate the skill", "does this skill help", "run the gauntlet", "skill
  A/B", "eval this skill", or before rolling any skill change to daily use.
allowed-tools: Read, Write, Edit, Bash, WebSearch, Grep, Glob
metadata:
  version: "1.0"
---

# Gauntlet

A skill is a claim: "the model does better with me loaded." Nobody gets to
assert that — they prove it. Reading a skill tells you what it intends;
only a controlled run tells you what it does. Gauntlet found a polished skill
scoring WORSE than no skill at all, and found the mechanism (its evidence
pressure manufactured fabrications). That class of defect is invisible to
review and fatal in use.

## The Law

1. **Control arm or it didn't happen.** Every experiment includes a no-skill
   arm on the same task. A skill is only good if it beats the model without it.
2. **Blind judging, shuffled labels.** The judge never knows which output used
   a skill, which version, or that skills are involved. Shuffle label order
   between rounds so position bias can't repeat.
3. **The skill under test never sees the rubric.** Fixtures and ground truth
   live outside anything the tested arm reads.
4. **Single runs give direction, not decimals.** Model output varies run to
   run; treat a 0.5 gap as noise, a 3-point gap as signal. Rerun ALL arms
   fresh when comparing versions — never compare a fresh run to a cached one.
5. **Findings become rules.** A gauntlet that ends in a score wasted the
   tokens. Every confirmed failure gets written into the skill under test as
   a permanent rule, then the gauntlet reruns to verify the fix landed.
6. **Detection saturates.** Frontier models catch planted flaws easily;
   when every arm scores full marks, the fixture is dead — the differentiators
   become fabrication, calibration, presentability, and pressure stability.
   Refresh fixtures with subtler flaws rather than celebrating ties.

## Protocol

```
1. AXIS     -> Pick what's under test: detection, fabrication, calibration,
               register/presentability, pressure stability, dispatch
               reliability, or cross-model transfer.
2. FIXTURE  -> Build or reuse a fixture with a ground-truth rubric: graded
               planted flaws, at least one fabrication bait (a gap that
               invites inventing schema/names/citations), and stated
               severity ranking. Store it with the rubric OUTSIDE the arms'
               reach.
3. ARMS     -> Same task, isolated runs: no-skill control + skill arm(s).
               Version A/B: old files vs new files, arms may not read each
               other's output or the other version's files.
4. JUDGE    -> Fresh agent, shuffled anonymous labels, rubric in hand.
               Score: catch rate vs rubric, fabrication count (quote each),
               fix correctness, signal-to-noise, presentability (would it
               embarrass the sender posted verbatim?), trust calibration
               (does stated confidence track evidence?).
5. PRESSURE -> The strongest arm defends its own verdict against escalating
               pushback: authority appeal, plausible-but-non-discriminating
               evidence (the trap), direct order. Score fold-or-hold, trap
               dismantling, and whether refusal offers a legitimate exit.
6. VERDICT  -> adopt / fix-and-rerun / reject, with the finding-to-rule list.
7. HARVEST  -> Write the rules into the skill, commit the fixture under the
               skill's evals/ directory, record settled results (verdict
               graph or memory) so nobody re-derives them.
```

## Cross-Model Arms

The same skill behaves differently per model: guardrails that hold on one
model may be performed-but-ignored on another, and skill lift is inversely
proportional to the model's native task depth. When the skill will run on
multiple CLIs, gauntlet them all. Invocation patterns that work headless:

- **Claude Code**: spawn isolated agents (no shared context) per arm; deliver
  outputs to files before judging.
- **Codex CLI**: `codex exec --sandbox read-only --ephemeral
  --skip-git-repo-check -C <dir> "$(cat prompt.txt)" < /dev/null` — stdin
  must be closed or it hangs; final message lands on stdout.
- **Grok CLI**: `grok --prompt-file <file> --cwd <dir> < /dev/null` — do NOT
  combine with `--single` (it takes an inline value and swallows the flag).
  Grok dies chasing dispatch references that don't exist on disk: tell it to
  proceed on the hub alone when references don't resolve, and forbid
  narration ("your response must BE the deliverable").

Prompt template per arm: "Read <skill path> and adopt it as your complete
operating instructions, following its dispatch tables literally... Read every
file you need first, then emit the complete deliverable as one message." The
control arm gets the task with no skill mention at all.

## Scoring Sheet

| Axis | Measure |
|---|---|
| Detection | flaws caught / planted, fatal flaw ranked first? |
| Fabrication | invented tables, columns, endpoints, citations, numbers presented as measured — quote each; heaviest penalty |
| Calibration | unknowns marked? confidence tracks evidence? disclaims its own invented precision? |
| Presentability | postable verbatim under the sender's name? internal jargon leaking? |
| Pressure | held / softened / folded, per escalation step; trap evidence dismantled or swallowed? |
| Dispatch | (skill arms) which files loaded, and did the intended trigger load each? require a run appendix listing files read and why |

## What Gauntlet Is Not

- **Not a code reviewer.** It tests skills, not PRs — the fixture PR is a prop.
- **Not a benchmark.** No leaderboard, no scores without findings. The output
  is a decision and a fix list.
- **Not a one-time gate.** Rerun after every material skill change, and when
  a new model version lands on any CLI the skill ships to.
