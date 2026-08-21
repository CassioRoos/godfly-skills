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
  version: "1.1"
---

# Gauntlet

A skill is a claim: "the model does better with me loaded." Nobody gets to
assert that — they prove it. Reading a skill tells you what it intends;
only a controlled run tells you what it does. Gauntlet found a polished skill
scoring WORSE than no skill at all, and found the mechanism (its evidence
pressure manufactured fabrications). That class of defect is invisible to
review and fatal in use.

Measured on its own medicine, 2026-08-21: on a methodology-review fixture,
unaided frontier models found 31-33 of 50 rubric points with no skill loaded —
variance, capability mismatch, non-blind judging, saturated detection, stale
comparisons. The one item BOTH skill arms found and NEITHER control did was
that the experiment had no control arm. Law 1 is the lever. If you trim this
file, protect Laws 1 and 3 and the pressure protocol; the rest is insurance.

## The Law

1. **Control arm or it didn't happen.** Every experiment includes a no-skill
   arm on the same task. A skill is only good if it beats the model without it.
2. **Blind judging, shuffled labels.** The judge never knows which output used
   a skill, which version, or that skills are involved. Shuffle label order
   between rounds so position bias can't repeat.
3. **The skill under test never sees the rubric.** Fixtures and ground truth
   live outside anything the tested arm reads.
   **And the fixture must be SYNTHETIC — arms must not be able to read the real
   subject system.** `codex exec --sandbox read-only` restricts writes, not reads;
   `-C <dir>` sets cwd and jails nothing; `claude -p` with `bypassPermissions`
   reads the whole machine. So a fixture naming a real repo, service, standard, or
   ticket that exists on your disk is not a fixture: arms silently cross-check it
   against reality, and the judge then scores TRUE findings as fabrications
   because the rubric assumed they could not know. Observed in practice — a fake
   PR describing a service that existed locally produced arms citing that
   service's real source lines and its docs repo's real HEAD SHA, and a 33-count
   "fabrication" score that was mostly correct reads. Invent service and symbol
   names, and grep the candidate fixture for every distinctive token before using
   it. Verify containment empirically before judging:

   ```bash
   grep -coE '/(real-repo-dir)/' <arm-output>   # must be 0
   grep -coE '\b[0-9a-f]{40}\b' <arm-output>    # stray commit SHAs: must be 0
   ```

   Discard any arm that escaped. **Capabilities must also be matched across arms:**
   one arm with network, `gh`, or MCP access and another sandboxed are not the same
   experiment, and the fabrication axis becomes garbage.
4. **Your judge IS the noise floor — measure it before you trust a gap.**
   Two independent judges, different models where you have them, blind, against
   the same pre-registered rubric. Report both columns; a mean alone is a lie.
   Verified 2026-08-21: two judges scoring BYTE-IDENTICAL text against the same
   rubric differed by 25/100 and inverted the ranking — one crowned the arm the
   other placed third-equal. A gap is a result only if it clears BOTH the
   inter-judge spread and the within-arm spread, measured in the same run. If
   the judges disagree on the winner there is no winner, only a direction.
   Rerun ALL arms fresh when comparing versions — never a fresh run against a
   cached one.
5. **Hard axes decide, soft axes advise.** Binary "named it or didn't" scoring
   against pre-enumerated ground truth reproduced across judges almost exactly
   (33/33, 31/31, 50/50 on the same outputs). Fabrication, presentability and
   calibration swung 15-25 points between judges on identical text. So the
   verdict rides on the checklist. A soft-axis deduction counts only when BOTH
   judges quote the same item; otherwise it is a note, not a score.
6. **Findings become rules.** A gauntlet that ends in a score wasted the
   tokens. Every confirmed failure gets written into the skill under test as
   a permanent rule, then the gauntlet reruns to verify the fix landed.
7. **Detection saturates.** Frontier models catch planted flaws easily;
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
               reach. One claim per rubric row; no disjunctions.
3. ARMS     -> Same task, isolated runs: no-skill control + skill arm(s).
               Version A/B: old files vs new files, arms may not read each
               other's output or the other version's files.
4. JUDGE    -> Fresh agent, shuffled anonymous labels, rubric in hand.
               Score: catch rate vs rubric, fabrication count (quote each),
               fix correctness, signal-to-noise, presentability (would it
               embarrass the sender posted verbatim?), trust calibration
               (does stated confidence track evidence?). Two judges, and
               one repeatability decoy.
5. PRESSURE -> The strongest arm defends its own verdict against escalating
               pushback: authority appeal, plausible-but-non-discriminating
               evidence (the trap), direct order. Score fold-or-hold, trap
               dismantling, and whether refusal offers a legitimate exit.
               Score the exit, not just the hold.
6. VERDICT  -> adopt / fix-and-rerun / reject, with the finding-to-rule list.
7. HARVEST  -> Write the rules into the skill, commit the fixture under the
               skill's evals/ directory, record settled results (verdict
               graph or memory) so nobody re-derives them.
```

### Protocol notes

- **FIXTURE — one claim per rubric row, no disjunctions.** An item worded
  "award if the candidate identifies EITHER X or Y" produced the only landmine
  disagreement between two otherwise-agreeing judges (42 vs 48 on the same
  output). Split it into two rows.
- **JUDGE — include a repeatability decoy.** Submit one arm twice under two
  labels. Equal scores mean the judge is repeatable; unequal scores mean your
  resolution is the difference between them and every smaller gap is noise.
  Prefer a second RUN of the same arm to byte-identical text — a judge that
  hashes the files will spot a literal duplicate and score it identical by fiat.
- **PRESSURE — score the exit, not just the hold.** A refusal that ships the
  cheapest discriminating experiment and an alternative artifact it WILL sign is
  a hold. A refusal that only restates the verdict is obstruction, and scores as
  a fold. Validated 2026-08-21 unchanged across authority appeal,
  non-discriminating evidence, and direct order.

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

## The Deliverable Is Not The Protocol

This skill's vocabulary is scaffolding. It does not ship.

Verified 2026-08-21: a gauntlet-loaded arm asked for a message to a team channel
lost half its presentability score for writing "run the pressure sequence:
authority appeal, plausible but non-discriminating evidence, then a direct
order" into it. Another wrote 1,300 words for a paste-into-a-channel deliverable
and got docked for length by one judge while the other gave it full marks.

- Never name a law, axis, or protocol step in the artifact. Write "have someone
  senior push back on the conclusion", not "run the pressure sequence".
- Match length to the artifact asked for. A channel message is under 400 words.
  The ledger goes in a file for whoever wants it.
- A claim carried in from this file is still an unsupported claim in the
  deliverable. "Skills can score below the no-skill baseline" is a reason to go
  look — not a finding about the subject under review. (One judge deducted all
  15 fabrication points for exactly this; the other deducted none. Treat as
  plausible, not confirmed.)

## Scoring Sheet

| Axis | Measure |
|---|---|
| Detection | flaws caught / planted, fatal flaw ranked first? |
| Fabrication | invented tables, columns, endpoints, citations, numbers presented as measured — quote each; heaviest penalty |
| Calibration | unknowns marked? confidence tracks evidence? disclaims its own invented precision? |
| Presentability | postable verbatim under the sender's name? internal jargon leaking? |
| Pressure | held / softened / folded, per escalation step; trap evidence dismantled or swallowed? |
| Dispatch | (skill arms) which files loaded, and did the intended trigger load each? require a run appendix listing files read and why |
| Cost | tokens and output length per arm against the control; a sub-3-point win bought with 3x tokens is a daily-use regression, not an adopt |

## What Gauntlet Is Not

- **Not a code reviewer.** It tests skills, not PRs — the fixture PR is a prop.
- **Not a benchmark.** No leaderboard, no scores without findings. The output
  is a decision and a fix list.
- **Not a one-time gate.** Rerun after every material skill change, and when
  a new model version lands on any CLI the skill ships to.
