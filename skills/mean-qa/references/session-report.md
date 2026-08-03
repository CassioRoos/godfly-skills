# The Session Report — What A Run Leaves Behind

A run that cannot be reviewed did not happen. This is the output contract.

Structure adapted from Session-Based Test Management (Jonathan & James Bach,
2000) and the three-part testing story (Michael Bolton).

## The hard rule

**Page one is one page.** Everything else is linked, not inlined. A reader gets
the verdict, the worst findings, and what to do in under five minutes; a
reviewer who wants proof follows a link. People read roughly a quarter of a
page — write for that quarter and stop defending the rest.

**The whole report has a budget too, not just page one.** If the full artifact
runs past roughly two thousand words for a single feature, you are writing a
document about testing rather than a report of testing. Cut taxonomy first,
then process narration, then redundant restatement — never cut the coverage
manifest or the findings.

If the summary and the detail disagree, the summary is wrong. Never write a
summary that a reader of the detail would call generous.

## Page one

```markdown
# <charter, one line> — <VERDICT>

**Verdict:** SHIP / HOLD / CONDITIONAL — <one sentence, the single blocking reason>
**Ran:** <what was exercised, one line> · **Env:** <env> · **Duration/steps:** <n>

## Worst first
1. **<plain-language title>** — <one sentence: what happens, to whom>. <link>
2. ...
   (cap at the number that fits; drop the tail, do not append it)

## What I could not verify
- <area> — <why> — <what would close it>

## Next
- <the single most valuable next action>
```

Finding titles are **plain language describing the failure**, not component
names. "Discontinued medications can still be administered" beats "Order status
validation gap in Administer()". A reader who reads only the titles should
understand the risk.

## The case list

The campaign and its results are a numbered case list in
[test-cases.md](references/test-cases.md) format, grouped into phases ordered by
blast radius, with a status per stable ID. This is the layer that makes the
report both scannable and executable: a reader triages on titles and severities,
an executor runs the input tables, and a later run diffs statuses by ID.

Prose is for the verdict and the findings. Everything testable is a case.

## Behind the link, per finding

Everything the finding gate produced: reproduction steps verbatim, the oracle
invoked, evidence, the minimised case, worst consequence attempted, sibling
surfaces checked, stakeholder impact, confidence, and what would falsify it.

## Coverage manifest — the part that makes the report honest

For each interesting state the feature can reach, record whether this run
**actually reached it**. Not whether you meant to; whether you did.

```markdown
| Interesting state | Reached? | Evidence |
|---|---|---|
| Order placed against an allergy with override | yes | run step 14 |
| Weight-based dose for a patient with no recorded weight | yes | step 22 |
| Critical result arriving after its deadline | **no** | never constructed |
| Concurrent administration of one order | **no** | no harness |
```

A "no" row is not a failure of the run; it is the most valuable line in the
report. It converts "we tested the feature" into "we tested these paths and not
those." Absence of evidence is stated as absence of evidence.

Borrowed from Antithesis's *sometimes assertions* — assert a condition was true
at least once, as a coverage signal rather than a correctness one. Without this
table, "no bugs found" is indistinguishable from "nothing was exercised."

## Bugs and Issues, separately

Two lists, never merged. Bugs are product concerns that passed the gate. Issues
are questions and obstacles — what you could not determine, what was ambiguous,
what blocked you. A run with many Issues and few Bugs is a normal, honest run in
an unfamiliar system.

## The three-part story

Any narrative section answers three questions in this order:

1. **The product story** — how it can work, how it fails, how it might fail in
   ways that matter.
2. **The testing story** — what you configured, operated, observed, and
   evaluated. What you actually did, not what the process says you do.
3. **The quality-of-this-testing story** — *why this testing was good enough*:
   coverage obtained, oracles used, what remains untested and why, what got in
   the way.

Story three is the one everyone drops and the one that makes a report
trustworthy. An agent that must justify sufficiency has to enumerate its own
gaps, which is precisely the discipline being bought.

## Session sheet — the durable record

Emitted per run, machine-scannable, one file:

```
CHARTER      <explore X with Y to discover Z>
AREAS        <coverage keywords, one per line>
ENV          <environment, build/SHA, seed if the workload was generated>
STARTED      <timestamp>  DURATION <wall clock or steps>
EFFORT       design/execution: <n>  investigation: <n>  setup: <n>
             on-charter vs opportunistic: <n>/<n>
DATA         <files, fixtures, identifiers created>
NOTES        <what was done and seen, in order — the raw trail>
BUGS         <id + one line each>
ISSUES       <id + one line each>
COVERAGE     <the manifest above>
```

**Effort numbers are descriptive, never a target.** SBTM's own authors warn the
metrics are gameable by "a silver-tongued tester"; an agent optimising a
session-count or coverage-percentage objective is exactly that with infinite
stamina. Report them; never optimise them.

## Close with calibrated confidence

End every session with:

- **Past** — what happened.
- **Results** — what was achieved.
- **Obstacles** — what got in the way of good testing.
- **Outlook** — what still needs doing.
- **Confidence** — how much would you bet this area is clean, and what would
  change your mind?

(The original PROOF debrief asks how the tester *feels*. That invites an agent to
fabricate affect. Calibrated confidence preserves the function — surfacing unease
the notes did not capture — without the theatre.)

## Do not self-certify

Unsupervised session reports rot. SBTM's authors dropped debriefs once and found
sheets degraded into "rambling ransom notes or vaguely technical haiku." The
equivalent safeguard here: a run's report is a **submission**, and a reviewer —
another agent or a human — accepts or rejects it against this contract. State
plainly in the report that it has not been independently reviewed, when it
hasn't.
