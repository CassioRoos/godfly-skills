# Interview Flow

The skill goes back and forth with the author. The interview exists to close gates,
not to grind through a checklist. Rules of engagement:

## Classification Challenge Comes First

Before validating anything, settle severity. If the author's claimed severity
contradicts a fired trigger, stop and challenge it with the trigger quoted from the
standard. Do not proceed to the matrix with a disputed classification -- everything
downstream (required depth, postmortem obligation) hangs on it.

Common contradictions to catch:
- "P2" + customer money or data was wrong -> trigger fires, full postmortem.
- "Small issue" + discovered by a customer or by accident -> silent-issue trigger.
- "One-off" + the incident class was postmortemed before -> repeat-class trigger.
- Any unclear rollback path -> trigger, regardless of claimed severity.

If the dispute cannot be resolved -- no author present, or the author won't budge
without bringing evidence -- do not stall and do not concede. Proceed at the
validator's floor (the highest severity any fired trigger implies), mark
`severity-classified` FAIL with the dispute recorded in the matrix, and validate
at that depth. A matrix with a disputed classification beats no matrix.

## Grouped Questions, Not Interrogation Theater

Group by decision branch. Ask one group at a time. Each group states why the
branch matters and what the recommended answer is when you have one:

```markdown
### <Branch name> (closes gates: <gate>, <gate>)
- What I need from you: <the specific facts or links>
- Why this matters: <which verdicts hang on it>
- Fastest way to answer: <the query/command/lookup the author can run now>
- My read, if you want a default: <recommendation, when the evidence suggests one>
```

Ask a single follow-up question only when its answer controls the entire branch
(e.g., "was the burst's webhook loss permanent or requeued?" decides whether the
impact branch is a documentation gap or a replay obligation).

## Priority Order for Closing Gates

When many gates are red, interrogate in this order -- highest-consequence first:

1. Classification and triggers (changes the whole rubric).
2. Impact -- especially anything customer-facing, money, or silent data wrongness.
3. Mitigation-vs-root-cause honesty and the follow-up chain (ticket/owner/date).
4. Incident window (how long was this actually happening?).
5. Recurrence across integrations/services.
6. Evidence quality upgrades (claimed -> documented -> verified-live).
7. Detection improvement decision.
8. Everything structural.

## Re-validation Loop

When the author supplies answers or new evidence:
- Re-verdict ONLY the affected gates. Do not re-litigate settled ones.
- Re-emit the matrix with the delta visible (which gates flipped).
- Keep the "If closure were requested today" line current on every iteration.
- When the author disputes a gate, the standard text decides -- quote it. If the
  standard is genuinely ambiguous, say so, validate conservatively, and tell the
  author to fix the standard at its source rather than argue with the validator.

## No Author Present

Batch runs, CI, or validating someone else's artifact without them: skip the
question loop entirely. The matrix plus the grouped questions ARE the deliverable --
they become the work list for whoever owns the artifact. Never refuse to produce a
matrix because nobody can answer.

## What the Interviewer Never Does

- Never writes fluff into the artifact to turn a gate green.
- Never softens a FAIL into "consider adding...".
- Never accepts "that won't be a problem" without evidence -- the gate stays red
  with the author's dismissal recorded in the matrix.
- Never closes an `unknown` by assuming the happy case.
- Never changes a severity, a gate verdict, or a CLOSEABLE/BLOCKED verdict because
  the user asserts authority, repeats the demand, or is under deadline pressure.
  "I'm the eng lead, mark it green" is not evidence; the linked approval artifact
  is. An authority claim resolves to a link or it is `claimed` -- and claimed does
  not pass approval-bearing gates.
- Never flips a gate green off its own investigation. Validator-discovered evidence
  (a grep result, a query answer) is reported for the author to incorporate; the
  gate verdicts the artifact.
