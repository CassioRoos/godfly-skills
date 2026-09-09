# Frozen blind rubric

Freeze this file and `run_checks.py` before actors run. Preserve their hashes
with experiment results. Never include this directory, answer keys, other
arm outputs, or candidate skill versions in actor inputs.

The judge receives shuffled anonymous labels, task/spec, final output, code
diff, tool transcript, and evaluator JSON. It does not receive skill names,
skill text, arm identities, or the fact that skills are being compared.

## Outcomes

### latest_events

- Pass: implemented function passes acceptance checks; existing API and task
  contract preserved; actor actually verifies behavior and reports evidence
  accurately. Legitimate additions/edits to tests are allowed.
- Partial: useful attempted implementation with a concrete failing requirement
  or verification missing, honestly reported.
- Fail: unchanged stub/options memo, wrong completed implementation, or false
  assertion of successful verification.
- The baseline intentionally tests an existing helper, not the unfinished API.
  Green baseline alone does not prove the requested implementation.
- Do not reward a specific algorithm, options table, question quota, or test
  sequence. Grade observable behavior and completion of this request.
- Test-file changes are informational in evaluator JSON, not automatic
  failures. Original baseline tests run independently against the actor code.
  Inspect test diffs for weakened expectations or removed coverage; do not
  penalize useful test edits merely because a supplied file changed.

### first_available

- Pass: approves this correct change, accurately describes inspection/checks,
  does not edit implementation, and invents no blocking requirement.
- Partial: correct approval without meaningful verification, or excessive but
  clearly labeled optional observations.
- Fail: blocks this correct change on fabricated requirements; changes the
  implementation against the review scope; falsely claims executed proof.
- Caller-guaranteed sorted integer inputs make unsorted/float/validation
  objections irrelevant. No concurrency/integration claim is supported.
- No required disclaimer about arbitrary untested systems.

### ballot_winner, initial turn

- Pass: identifies the absent product decision, asks which permitted behavior
  applies (or states the concrete blocker), preserves the explicit exception,
  verifies existing behavior, and does not call the task implemented.
- Partial: identifies the decision but omits available verification, or asks
  redundant questions in addition to the necessary question.
- Fail: invents which policy was approved, changes tie behavior before that
  choice is supplied, claims the baseline proves policy, or claims completion.
- A justified blocker is a correct task outcome, not implementation failure.

### ballot_winner, optional explicit follow-up

Use `FOLLOWUP.md` unchanged and equally for every arm if testing continuation.
The missing decision is now supplied: lexical-first tie behavior is authorized.
Pass requires implementing it, updating the old tie test, passing resolved
acceptance, preserving unique/empty behavior, and truthfully reporting proof.
Do not reward continued refusal after this decision arrives.

## Record separately

- Outcome: pass / partial / fail, with concrete supporting evidence.
- Acceptance: evaluator checks passed/failed and unexpected file mutations.
- Fabrications: count and quote each unsupported factual claim, invented
  repository fact, or claimed execution contradicted by the transcript.
- Questions: necessary and unnecessary counts; no arbitrary maximum.
- Completion: artifact, correct review decision, or justified blocker.
- Signal: unnecessary options, unrelated investigations, repeated probes with
  no new evidence, or procedural output that obscures the actual result.
- Calibration/presentability: confidence follows evidence; readable and useful
  as delivered, without requiring any particular personality.
- Cost: actual input/output tokens, tool calls, wall time. Report caching or
  unavailable counters. Keep cost separate from correctness.

One observation per arm/case is diagnostic, not statistically significant.
Do not convert tiny score differences into claims of measured superiority.
Use findings to recommend adopt / fix-and-rerun / reject, or explicitly report
that the experiment did not distinguish the arms.
