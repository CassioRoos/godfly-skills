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
`severity-classified` FAIL with the dispute recorded, and validate at that depth.
A graded run with a disputed classification beats no run.

## Grouped Questions, Not Interrogation Theater

Group by decision branch. Interactive session: ask one group at a time, highest
consequence first. Batch or no author: emit the work list in the SAME consequence
order (below), top three branches in full, the remainder as one line each under
"Also open". The order is not decoration -- an unordered work list is the same failure
as no work list, because the reader cannot tell what to do first.

Never list "open a ticket", "write the postmortem", or any paperwork gate above a gate
describing production still being broken. Documentation obligations are real and they
are never the first action.

Each group states why the branch matters and what the recommended answer is when you
have one:

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

The single ordering used BOTH for interrogating an author and for emitting a batch
work list -- highest-consequence first. When many gates are red:

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
- Wherever a matrix is being emitted at all (coach and gate mode), re-emit it with
  the delta visible (which gates flipped). This governs matrices that exist; it never
  orders one into existence. Passenger and no-author runs re-emit their terminal line
  and changed gates, not a matrix.
- Keep the "If closure were requested today" line current on every iteration.
- When the author disputes a gate, the standard text decides -- quote it. If the
  standard is genuinely ambiguous, say so, validate conservatively, and tell the
  author to fix the standard at its source rather than argue with the validator.

## No Author Present

Batch runs, CI, or validating someone else's artifact without them: skip the question
loop entirely. Never refuse to produce a VERDICT because nobody can answer -- but
"nobody to interview" is not a licence to dump the rubric on the reader. What replaces
the interview is the ordered work list, not a bigger table.

The deliverable is: the terminal line, the failed and unknown gates that produced it in
the consequence order above, and the work list. Passing gates are graded and summarised
in one line, not enumerated. Emit the full matrix only when the reader asked the
closure question or asks for it.

A reader who cannot answer questions has even less use for thirty rows than the author
does. The person picking this up needs to know what to do first.

## What the Interviewer Never Does

- Never writes fluff into the artifact to turn a gate green.
- Never softens a FAIL into "consider adding...".
- Never accepts "that won't be a problem" without evidence -- the gate stays red
  with the author's dismissal recorded against the gate.
- Never closes an `unknown` by assuming the happy case.
- Never changes a severity, a gate verdict, or a CLOSEABLE/BLOCKED verdict because
  the user asserts authority, repeats the demand, or is under deadline pressure.
  "I'm the eng lead, mark it green" is not evidence; the linked approval artifact
  is. An authority claim resolves to a link or it is `claimed` -- and claimed does
  not pass approval-bearing gates.
- Never flips a gate green off its own investigation. Validator-discovered evidence
  (a grep result, a query answer) is reported for the author to incorporate; the
  gate verdicts the artifact.
