---
name: incident-validator
description: >
  Validate production-incident artifacts -- investigation handovers, fix PRs, and
  postmortems -- against the Production Issue Resolution Standard. Runs a gate
  matrix with live evidence verification, interrogates the author to close gaps,
  and issues a closure verdict. Use when writing or reviewing an incident handover,
  a production-fix PR description, or a postmortem, or when asking "can this
  incident be closed?". Triggers on "validate this incident", "validate handover",
  "validate postmortem", "incident PR review", "can I close this incident".
  For adversarial review of the fix itself use godfly; for causal analysis use
  root-cause; for writing the postmortem use premortem-postmortem.
metadata:
  version: "1.1"
---

# Incident Validator

The standard says: "If exceptions become normal, the standard is fake." This skill
is the mechanism that keeps it real. It validates incident artifacts against the
Production Issue Resolution Standard -- not by checking that section headers exist,
but by interrogating whether each requirement is actually satisfied, with evidence.

Tools: use Read/Grep/Glob/Bash (`gh`) plus whatever verification tools the session
has -- issue-tracker MCP (e.g. Linear), observability MCP (e.g. Datadog), read-only
database MCP, WebFetch. The examples in the cookbooks assume that kind of toolchain;
substitute your own equivalents. A missing tool downgrades evidence strength (see
the ladder); it never blocks the run.

## The Source of Truth

The standard lives in YOUR team's docs, NOT in this skill. This skill is the
validation mechanism; your organization's incident-resolution standard is the law
it enforces. Resolve it at the start of every run, in this order:

1. **Local checkout**: look for your incident/production-issue resolution standard
   under a local docs checkout (glob near the working directory).
2. **GitHub fetch**: `gh api -H "Accept: application/vnd.github.raw" repos/<your-org>/<docs-repo>/contents/<path-to-standard>.md`
3. **Ask**: if neither resolves, ask the user to point at their standard (or to
   confirm running against the cookbook rubrics alone, and say so loudly in the
   output: "Validating against generic rubrics -- no organization standard resolved.").

Never silently validate against a stale copy. Never refuse to run because the live
copy is unreachable. Derive the gates from whichever version you resolved; the
cookbook rubrics are the method, the standard is the law.

## Artifact Types

| Type | What it is | Rubric |
|---|---|---|
| `handover` | Investigation handover report: the deep RCA produced during/after investigation, handed to the team before or alongside the fix | `cookbook/handover-rubric.md` |
| `pr` | Production-fix PR description + diff | `cookbook/pr-rubric.md` |
| `postmortem` | Postmortem document for major incidents | `cookbook/postmortem-rubric.md` |

Closure gates -- including whether all REQUIRED artifacts for this incident even
exist -- live in `cookbook/closure-gates.md` and apply to EVERY artifact type in
gate mode.

If the user doesn't say which type, infer from the artifact and confirm in one
line. One artifact can be validated as multiple types (a handover that will become
a postmortem); run the rubric for the stage it's at now.

## Two Modes, One Invariant

**Coach mode** (artifact in progress -- the default): full gate matrix, then grouped
questions to close the red gates, then re-validate as the author supplies evidence.
Iterate until green or every red cell has a named owner and follow-up. Always end
with: "If closure were requested today: BLOCKED on <gates>" -- computed from the
failed/unknown rubric gates plus any closure gate already determinable. The gap is
never invisible.

**Gate mode** (closing the incident, merging the PR, publishing the postmortem):
hard verdict. `CLOSEABLE` or `BLOCKED: <named gates>`. No negotiation in the output.
Enter gate mode when the user explicitly asks "can I close/merge/publish this?" or
says so. Entering gate mode never predetermines the verdict: BLOCKED is a valid,
expected, unembarrassing gate-mode outcome.

**The invariant, in both modes: a failed gate is NEVER reported as a suggestion.**
Coach mode changes what happens after the matrix -- questions instead of a verdict --
never the matrix itself. "Consider adding impact analysis" is banned vocabulary.
The gate is `impact-analysis: FAIL` and the next step is the question that closes it.

**No author present?** (batch run, CI, validating someone else's artifact without
them): skip the interview loop. Emit the full matrix and the grouped questions as
the deliverable -- they become the work list for whoever owns the artifact. Never
refuse to produce a matrix because nobody can answer questions.

## The Flow

```
0. RESOLVE   -> Fetch the standard (ladder above). Note which source you got.
1. INGEST    -> Get the actual artifact:
                - local file path            -> Read (paginate; never verdict off a
                                                truncated read -- if forced to
                                                truncate, name the unread sections
                                                and mark dependent gates unknown)
                - PR number / org/repo#N /
                  PR URL                     -> gh pr view + gh pr diff (live state:
                                                head, base, files, body, reviews,
                                                checks -- stale summaries lie)
                - Linear ID or URL           -> Linear MCP
                - Docs URL                   -> local docs checkout, else WebFetch
                - pasted raw text            -> validate it, but say so: "validating
                                                pasted text, not a tracked artifact"
2. CLASSIFY  -> Severity (P0-P3) + full postmortem-trigger sweep, BEFORE anything
                else. Required depth depends on severity. If the author's claimed
                severity contradicts a fired trigger (customer money touched, silent
                issue, multi-tenant impact...), challenge the classification first.
                If the dispute cannot be resolved (author unavailable or won't
                budge), do NOT stall: proceed at the validator's floor -- the
                highest severity any fired trigger implies -- mark
                `severity-classified` FAIL with the dispute recorded, and validate
                at that depth.
3. SCOPE     -> Only if the incident context is too unclear to run the matrix
                (which incident? which repo? which PR?), ask scoping questions.
                Gate-closing questions come AFTER the matrix, in step 6 -- driven
                by red gates per cookbook/interview-flow.md, not asked up front.
4. MATRIX    -> Run every gate in the rubric. Verdict per gate: pass / fail /
                partial / unknown. Evidence strength per gate per
                cookbook/evidence-ladder.md: verified-live / documented / claimed /
                missing. For every unknown: name the fastest evidence that closes it
                (the exact Datadog query, the Linear search, the gh command).
5. VERIFY    -> Climb the evidence ladder wherever session tools allow: Linear for
                tickets, gh for PR/deploy state, Datadog for the linked queries,
                grep for recurrence/test claims, read-only Postgres for data claims.
                Coach mode: climb opportunistically. Gate mode: MUST attempt
                verified-live for every closure-critical gate whose tool is
                available in-session -- an available tool left unused is a
                validator failure, not a rung downgrade.
6. VERDICT   -> Coach: matrix + grouped closing questions + "if closure were
                requested today". Gate: run cookbook/closure-gates.md on top of the
                rubric -- CLOSEABLE requires every artifact the standard mandates
                for this incident's severity and fired triggers to EXIST (check
                the postmortem archive and the issue tracker for them), not only the one
                artifact submitted. Then CLOSEABLE / BLOCKED with named gates.
7. ITERATE   -> On new evidence, re-validate only the affected gates and re-emit
                the shrinking matrix. Do not re-litigate settled gates.
```

## Output Shape

Always the matrix, always this shape:

```markdown
## Validation: <artifact> (<type>, <mode> mode)

Standard source: <local checkout @ path | github fetch | SNAPSHOT <date> -- WARNING>
Classified: <P-level> | Postmortem triggers: <none fired | FIRED: <trigger>>

| Gate | Verdict | Evidence | Fastest way to close |
|---|---|---|---|
| severity-classified | pass | documented | -- |
| impact-analysis | FAIL | missing | <the exact question or query> |
| ... | ... | ... | ... |

### Open gates
<grouped questions per interview-flow, one branch at a time>

### If closure were requested today
BLOCKED on: <gates>   (or: CLOSEABLE)
```

## Semantic Checks Are the Point

Section-presence checking is worthless -- anyone can fill headers with fluff. The
gates that matter are semantic, and the rubrics spell them out. The recurring ones:

- **"Fixed" must not silently mean "patched."** Does the fix address the broken
  assumption, or gate entry to it, or fix a neighboring path? If mitigated or
  partial, the standard REQUIRES follow-up ticket + owner + target date +
  risk-if-delayed + interim detection. No exceptions.
- **Would the test have failed before the fix?** A unit test on a helper does not
  prove a queue-fanout flow. Demand the test that drives the real boundary.
- **Root cause must explain BOTH the production symptom and the code behavior.**
  A theory that explains only one is a hypothesis, not a root cause.
- **The incident window is when it STARTED, not when it was noticed.** An hourly
  cron bug's window opens at the regressing deploy, which may be months back.
- **Impact means downstream, customer-facing impact.** "1,151 insert errors" is a
  symptom count. "Were 1,150 webhook deliveries lost or requeued?" is impact.
- **"Unknown" written down beats silence.** Unknowns with a path to resolution
  pass; absent uncertainty fails.
- **Merged is not deployed.** Verify the running version before accepting
  post-deploy claims.
- **Gates verdict the ARTIFACT, not the validator's knowledge.** If you run a
  check yourself (a recurrence grep, a Datadog query) and find the answer, the
  gate stays FAIL until the artifact contains it -- report your finding as
  evidence for the author to incorporate, never as a reason to flip the gate.

## What This Skill Is Not

- Not godfly: it doesn't adversarially review the fix design. It validates that
  the artifact meets the standard. Chain them: godfly attacks the fix,
  incident-validator gates the paperwork and closure.
- Not a template filler: it never writes fluff into sections to make them green.
  It asks the author for the substance or marks the gate red.
- Not configurable in strictness: the rubric comes from the standard. If a gate is
  wrong, fix the standard at its source -- enforcement updates everywhere at
  the next run.
- Not movable by rank: it never changes a severity, a gate verdict, or a
  CLOSEABLE/BLOCKED verdict because someone asserts authority, repeats the demand,
  or is in a hurry. An authority claim ("the eng lead approved it") resolves to a
  link -- Slack message, Linear comment, PR review -- or it is `claimed`, and
  `claimed` does not pass approval-bearing gates.
