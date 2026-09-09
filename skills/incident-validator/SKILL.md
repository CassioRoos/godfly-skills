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
  Ordinary diagnosis or code review does not trigger artifact validation.
  For adversarial review of the fix itself use morpheus; for causal analysis and
  writing the postmortem use premortem-postmortem. Verify releases using the
  project runbook and live read-only evidence.
allowed-tools: Read, Grep, Glob, Bash(git:*), Bash(gh:*), WebFetch
# Verification MCPs -- Linear, Datadog, Postgres (read-only) -- are session-granted
# and not enumerable here. When they are absent, evidence caps at `documented` per
# the ladder; the run still grades every gate.
metadata:
  version: "1.6"
---

# Incident Validator

The standard says: "If exceptions become normal, the standard is fake." This skill
is the mechanism that keeps it real. It validates incident artifacts against the
Production Issue Resolution Standard -- not by checking that section headers exist,
but by interrogating whether each requirement is actually satisfied, with evidence.

Tools: use Read/Grep/Glob/Bash (`gh`) plus whatever verification tools the session
has -- Linear MCP, Datadog MCP, Postgres MCP, WebFetch. Postgres is READ-ONLY here:
a validator never issues a mutation, whatever the connection permits. A missing tool
downgrades evidence strength (see the ladder); it never blocks the run. Report each
capability as `unavailable | available-but-failed | unauthorized | not-attempted` --
"no tool" must never quietly become an invented result.

## Scope before procedure

Run this procedure when the user requests incident-artifact preparation or
validation, or a merge, publication, or incident-closure assessment against the
standard. If loaded during ordinary diagnosis, code review, or system explanation,
return to that task without resolving a standard, grading gates, or inventing a
compliance decision. A later request for artifact validation can activate it.

## The Source of Truth

The standard lives in the docs repo, NOT in this skill. Resolve it at the start of
every run, in this order:

1. **Local checkout**: look for `engineering/foundations/guides/production-issue-resolution-standard.md`
   under a local `docs` repo checkout (glob for it near the working directory and in
   `~/Documents/projects/*/docs`).
2. **GitHub fetch**: `gh api -H "Accept: application/vnd.github.raw" repos/getalternative/docs/contents/engineering/foundations/guides/production-issue-resolution-standard.md`
3. **Embedded snapshot**: `reference/standard-snapshot.md` in this skill -- use it
   ONLY as last resort, and open your output with a loud warning naming the snapshot
   date: "Validating against standard snapshot from <date> -- could not reach the
   live version."

Never silently validate against a stale copy. Never refuse to run because the live
copy is unreachable. Derive the gates from whichever version you resolved; the
cookbook rubrics are the method, the standard is the law. Record what you resolved:
absolute path or fetched ref, plus commit SHA when `gh` supplied one.

**All three rungs failed?** Then there is no law to enforce, and that is terminal:

```text
standard-resolution: FAIL
No compliance grades issued because no authoritative standard was readable.
BLOCKED: standard-unresolved
```

List each failed attempt and why (never with credentials). Inventory the artifact's
sections if asked. NEVER emit pass/fail compliance grades from memory or from
cookbook prose -- the cookbook is a method for reading a standard, not a substitute
for one.

### Does the resolved standard contain what the rubrics enforce?

Check both directions; one line in the output, whichever applies:

- **In the snapshot, absent from the resolved standard** (today: `Investigation
  Handover Standard`, `Contributing Factors`): "snapshot carries unmerged draft text;
  these gates run as ADVISORY until the docs change lands." Advisory gates are still
  graded and shown, tagged `(advisory)`, listed separately, and NEVER in a `BLOCKED:`
  line -- you cannot block a decision on a requirement the standard does not make.
- **In the resolved standard, absent from the snapshot**: "snapshot stale -- refresh
  in the next harness release." Compare content, not just headings; a requirement can
  change under an unchanged heading.

## Artifact Types

| Type | What it is | Rubric |
|---|---|---|
| `handover` | Investigation handover report: the deep RCA produced during/after investigation, handed to the team before or alongside the fix | `cookbook/handover-rubric.md` |
| `pr` | Production-fix PR description + diff | `cookbook/pr-rubric.md` |
| `postmortem` | GitBook postmortem for major incidents | `cookbook/postmortem-rubric.md` |

Closure gates -- including whether all REQUIRED artifacts for this incident even
exist -- live in `cookbook/closure-gates.md`. They are mandatory for the
`incident-close` decision target and informational for the others; see below.

If the user doesn't say which type, infer from the artifact and confirm in one
line. One artifact can be validated as multiple types (a handover that will become
a postmortem); run the rubric for the stage it's at now.

## Decision Target

Three different decisions hide behind "validate this". Every run has exactly ONE
decision target. Infer it from the artifact and the ask; state it in the output;
accept an explicit override.

| Target | Typical artifact | Mandatory gates | Terminal verdict |
|---|---|---|---|
| `pr-merge` | production-fix PR | `pr-rubric` | `MERGEABLE` or `BLOCKED: <gates>` |
| `postmortem-publish` | postmortem | `postmortem-rubric` | `PUBLISHABLE` or `BLOCKED: <gates>` |
| `incident-close` | any artifact, plus the incident's other required artifacts | the artifact rubric AND every closure gate | `CLOSEABLE` or `BLOCKED: <gates>` |

For `pr-merge` and `postmortem-publish`, closure gates are still graded but reported
as ONE summary line -- `NOT_APPLICABLE`, reason `informational dependency for
incident-close` -- never as ten separate rows; enumerate them only for
`incident-close` or on request. They show what is coming; they never block the
decision in front of you. Blocking an unmerged
PR on post-deploy monitoring is a validator bug, not rigor: the deploy cannot precede
the merge. The reverse error is worse -- a `PUBLISHABLE` postmortem is not a closeable
incident and must never be presented as one.

**E2E precedence, stated once so nothing downstream has to guess:** an
engineering-lead-approved six-part E2E exception CAN make a PR `MERGEABLE`.
`incident-close` stays `BLOCKED` until the E2E follow-up exists AND passes -- "the
production issue cannot be closed until the E2E follow-up is completed."

## Two Modes, One Invariant

**Coach mode** (artifact in progress -- the default): full gate matrix, then grouped
questions to close the red gates, then re-validate as the author supplies evidence.
Iterate until green or every red cell has a named owner and follow-up. Always end
with the terminal line for the decision target, prefixed "If <target> were requested
today:" -- computed from the failed/unknown gates in scope for that target. The gap
is never invisible.

**Gate mode** (merging the PR, publishing the postmortem, closing the incident):
hard verdict -- the target's terminal verdict or `BLOCKED: <named gates>`. No
negotiation in the output. Enter gate mode when the user explicitly asks "can I
close/merge/publish this?" or says so. Entering gate mode never predetermines the
verdict: BLOCKED is a valid, expected, unembarrassing gate-mode outcome.

**The invariant, in both modes: a failed gate is NEVER reported as a suggestion.**
Coach mode changes what happens after the matrix -- questions instead of a verdict --
never the matrix itself. "Consider adding impact analysis" is banned vocabulary.
The gate is `impact-analysis: FAIL` and the next step is the question that closes it.

**No author present?** (batch run, CI, someone else's artifact): skip the interview
loop; the ordered work list replaces it. No author is a reason to drop the questions,
never a reason to grow the table. Details in `cookbook/interview-flow.md`.

## The Flow

```
0. RESOLVE   -> Fetch the standard (ladder above). Note which source you got.
1. INGEST    -> Get the actual artifact:
                - local file path            -> Read (paginate; never verdict off a
                                                truncated read -- if forced to
                                                truncate, name the unread sections
                                                and mark dependent gates UNKNOWN)
                - PR number / org/repo#N /
                  PR URL                     -> gh pr view + gh pr diff (live state:
                                                head, base, files, body, reviews,
                                                checks -- stale summaries lie)
                - Linear ID or URL           -> Linear MCP
                - GitBook/docs URL           -> local docs checkout, else WebFetch
                - pasted raw text            -> validate it, but say so: "validating
                                                pasted text, not a tracked artifact",
                                                and mark every live-state and diff
                                                gate UNKNOWN (see pr-rubric's
                                                `pr-body-only` ingestion)
2. CLASSIFY  -> Two fields, independent, neither derived from the other:
                  severity:        P0 | P1 | P2 | P3 | disputed | unknown
                  full_postmortem: required | waived-with-link | not-required |
                                   unknown
                Sweep every full-postmortem trigger as its own row (true / false /
                unknown, with evidence and source). A fired trigger sets
                full_postmortem: required; it does NOT imply a P-level. Triggers
                govern documentation depth, not severity -- never infer one from the
                other unless the resolved standard maps them explicitly. A trigger
                left `unknown` forbids concluding full_postmortem: not-required.
                Challenge a contradicted severity ONCE. Unresolved: record
                severity: disputed, mark `severity-classified` FAIL with the dispute,
                validate at the deepest obligation the fired triggers require. If
                the artifact doesn't identify the incident well enough to classify,
                do step 3 first, then return here.
3. SCOPE     -> Only if the incident context is too unclear to run the matrix
                (which incident? which repo? which PR?), ask scoping questions.
                Gate-closing questions come AFTER the matrix, in step 6 -- driven
                by red gates per cookbook/interview-flow.md, not asked up front.
4. MATRIX    -> GRADE every gate in the rubric, using the canonical enums below.
                Grading every gate and printing every gate are different acts:
                grade all of them always, print them per the mode.
                Evidence strength per cookbook/evidence-ladder.md. For every
                UNKNOWN: name the fastest evidence that closes it -- an exact query
                when you have the pieces, a marked query SPECIFICATION when you do
                not (see "Never Fabricate").
5. VERIFY    -> Climb the evidence ladder wherever session tools allow: Linear for
                tickets, gh for PR/deploy state, Datadog for the linked queries,
                grep for recurrence/test claims, read-only Postgres for data claims.
                Use current provider schemas and bounded probes. If separately
                installed and relevant, consult `datadog-mcp-gotchas` for query
                failures or `altpay-datadog-apm-spans` for AltPay span discovery.
                Their absence does not block available evidence gathering.
                Coach mode: climb opportunistically. Gate mode: MUST attempt
                VERIFIED_LIVE for every gate closure-critical to this decision
                target whose tool is available in-session -- an available tool left
                unused is a validator failure, not a rung downgrade.
6. VERDICT   -> Coach: matrix + grouped questions + the "if <target> were requested
                today" line. Gate: the target's terminal verdict. No
                author: terminal line + the failing gates that drove it (<=5,
                consequence order) + the ordered work list, no matrix. For
                `incident-close` only, run cookbook/closure-gates.md on top of the
                rubric -- CLOSEABLE requires every artifact the standard mandates for
                this incident's severity and fired triggers to EXIST (check
                engineering/post-mortem/ and Linear), not only the one submitted.
7. ITERATE   -> On new evidence, re-verdict only the affected gates. Wherever a
                matrix is being shown, re-emit it COMPLETE every time, plus a
                "Changed since last run" section listing only the flipped rows:
                settled gates are never dropped from a matrix, just not
                re-litigated. No-author runs iterate on the terminal
                line and the changed gates -- iteration never grows a matrix into
                a run that had none.
```

## Output Shape

One vocabulary. In matrix cells and terminal lines it is always the uppercase enum;
cookbook prose names the same values in lowercase, and they are the same values:

- `verdict`: `PASS | FAIL | PARTIAL | UNKNOWN | NOT_APPLICABLE`
- `evidence`: `VERIFIED_LIVE | DOCUMENTED | CLAIMED | MISSING`
- every `NOT_APPLICABLE` states its applicability reason; every graded row carries a
  source locator (path, URL, ticket, query) or the literal word `none`
- terminal line: exactly one grammar per decision target -- `MERGEABLE`,
  `PUBLISHABLE`, `CLOSEABLE`, or `BLOCKED: <gate>, <gate>`. Not "blocked on", not
  "mostly closeable", no other spellings.

With an author present, coach and gate mode use the complete matrix -- every gate
in the rubric, every run, including those that already passed. No-author runs use
the compact shape below. Coach and gate mode use this shape:

```markdown
<snapshot warning block FIRST, before the heading, when the snapshot was the source>

## Validation: <artifact> (<type>, target: <decision target>, <mode> mode)

Standard source: <local checkout @ path @ SHA | gh fetch @ ref | SNAPSHOT <date> -- WARNING>
Capabilities: <gh: ok | Linear: unauthorized | Datadog: not-attempted | ...>
severity: <P0-P3 | disputed | unknown> | full_postmortem: <required | waived-with-link | not-required | unknown>
Triggers: <trigger>: true/false/unknown (one row each, with source)

| Gate | Verdict | Evidence | Source locator | Fastest way to close |
|---|---|---|---|---|
| severity-classified | PASS | DOCUMENTED | handover.md L12 | -- |
| impact-analysis | FAIL | MISSING | none | <the exact question or query spec> |
| ... | ... | ... | ... | ... |

### Advisory (non-blocking: not in the resolved standard)
<gate rows, graded, excluded from the terminal line>

### Changed since last run
<only the flipped rows; omit the section on a first run>

### Open gates
<grouped questions per interview-flow>

### If <decision target> were requested today
BLOCKED: <gates>   (or: MERGEABLE / PUBLISHABLE / CLOSEABLE)
```

No-author runs use this shape instead -- same vocabulary, same
terminal grammar, no matrix:

```markdown
## <artifact>: <terminal line>

<one paragraph: the incident in plain language -- what breaks, who is affected,
since when. This is what the reader came for; it goes first.>

**Blocking:** <the failing gates, consequence order, at most five, each one line:
gate name -- what is missing -- the fastest thing that closes it.>
**Also open:** <remaining failed/unknown gates, names only, one line total.>
**Passing:** <count> gates PASS.

### Do these first
<numbered, consequence order per interview-flow's priority order, three maximum,
each verb + target + done-condition. Production still being broken outranks every
paperwork gate.>

### Not on the critical path
<the real-but-deferrable items, one line total, so nobody mistakes deferral for
having missed them.>

Full gate matrix on request.
```

**Register without an author present.** Gate slugs, mode names, and enum labels are this
skill's internal vocabulary, not the reader's. In a no-author run the reader never
sees `severity-classified`, `mitigation-vs-root-cause`, `trigger-sweep`, internal
mode names, or a rung name. They see "nobody has assigned this a severity",
"it is not established whether this is fixed or merely patched", "the postmortem
triggers were never checked". Keep the terminal line's enum -- BLOCKED / MERGEABLE /
PUBLISHABLE / CLOSEABLE is a decision, not jargon -- and name the gates in plain
language after it. Coach and gate mode keep the slugs: those readers are working
the matrix and need its vocabulary.

**Cookbook files grade; they never dictate shape.** The rubrics define what passes,
the ladder defines how strong the evidence is, `closure-gates` defines what closure
requires. None of them decides what appears on the page -- that is this file's job,
by mode, and it is the same decision for a handover, a PR, and a postmortem. If a
cookbook line reads as an instruction to print something ("appears in the matrix",
"never blocks producing the matrix"), read it as an instruction to GRADE something,
and print per the mode. A rubric that could quietly reintroduce a thirty-row table
is a bug in the rubric.

## Never Fabricate

Never invent a URL, ticket ID, monitor or dashboard name, table or column name,
commit SHA, owner, date, or grade -- not even as an illustration; a plausible-looking
placeholder gets copied into the artifact as fact.

"The exact Datadog query / Linear search / gh command" is only exact when derived
from evidence you inspected this run. Otherwise emit a query SPECIFICATION with
placeholders marked and prerequisites named:

```text
Query intent: count records left in a bad state during the incident window.
Missing to make executable: <TABLE>, <TIMESTAMP_COLUMN>, <BAD_STATE_PREDICATE>.
```

A specification the author can complete in thirty seconds beats a runnable-looking
query that silently points at nothing.

## Semantic Checks Are the Point

Section-presence checking is worthless -- anyone can fill headers with fluff. The
gates that matter are semantic, and the rubrics spell them out. The recurring ones:

- **"Fixed" must not silently mean "patched."** Does the fix address the broken
  assumption, or gate entry to it, or fix a neighboring path? If mitigated or
  partial, the standard REQUIRES follow-up ticket + owner + target date +
  risk-if-delayed + interim detection. No exceptions.
- **Would the test have failed before the fix?** A unit test on a helper does not
  prove a queue-fanout flow. Demand the test that drives the real boundary -- and the
  demonstrated failure without the fix, per the ladder.
- **Root cause must explain BOTH the production symptom and the code or system
  behavior.** A theory that explains only one is a hypothesis, not a root cause. The
  standard locates causes in code, config, infrastructure, data, dependencies, or
  process -- demand a typed locator for whichever it is, not code lines for a config
  regression.
- **The incident window is when it STARTED, not when it was noticed.** An hourly
  cron bug's window opens at the regressing deploy, which may be months back.
- **Impact means downstream, customer-facing impact.** "1,151 insert errors" is a
  symptom count. "Were 1,150 webhook deliveries lost or requeued?" is impact.
- **"Unknown" written down beats silence -- but only for the meta-gate.** An honest,
  path-carrying unknown passes `unknowns-honest` and nothing else. The underlying
  gate (`impact-analysis`, `repair-complete`, `recurrence-check`, a trigger row)
  stays `UNKNOWN`, and `UNKNOWN` blocks `incident-close` wherever closure depends on
  it. Absent uncertainty fails both gates.
- **Never list a gate as open that the artifact satisfies.** "Also open" is a list
  of graded failures, not a dumping ground for every gate you did not discuss.
  Before a gate goes in it, confirm the artifact does not already answer it: a
  handoff that names every affected service satisfies `affected-services`, and one
  that checks the same pattern across five integrations satisfies
  `recurrence-check`, however much else it is missing. Crediting nothing is as
  wrong as crediting everything, and it destroys the reader's trust in the gates
  that genuinely ARE failing.
- **`UNKNOWN` means absent evidence, never merely unverified evidence.** A trigger
  the artifact documents with specific counts, durations, or timestamps is `TRUE`
  at `documented` strength: "~65 QuickBooks and ~12 HaloPSA connections" IS
  multi-tenant impact, and "13+ consecutive hours" IS core-flow degradation past
  any fifteen-minute bar. Reserve `UNKNOWN` for what the artifact does not speak
  to. Downgrading documented facts to `UNKNOWN` because no tool was available to
  re-verify them inflates the unknown count and hides which triggers have fired --
  the strength drops to `documented`, the verdict does not drop to `UNKNOWN`.
- **Merged is not deployed.** Verify the running version before accepting
  post-deploy claims.
- **Gates verdict the ARTIFACT, not the validator's knowledge.** If you run a
  check yourself (a recurrence grep, a Datadog query) and find the answer, the
  gate stays FAIL until the artifact contains it -- report your finding as
  evidence for the author to incorporate, never as a reason to flip the gate.

## What This Skill Is Not

- Not morpheus: it doesn't adversarially review the fix design, and it does not
  re-derive diff semantics -- use Morpheus and cookbook/fix-boundary-review.md
  for surviving paths and blast radius; consume their evidence. This skill validates that the
  ARTIFACT meets the standard. Chain them: morpheus attacks the fix,
  incident-validator gates the paperwork and closure.
- Not a template filler: it never writes fluff into sections to make them green.
  It asks the author for the substance or marks the gate red.
- Not configurable in strictness: the rubric comes from the standard. If a gate is
  wrong, fix the standard in the docs repo -- enforcement updates everywhere at
  the next run.
- Not movable by rank: it never changes a severity, a gate verdict, or a terminal
  verdict because someone asserts authority, repeats the demand, or is in a hurry.
  An authority claim ("the eng lead approved it") resolves to a link or it is
  `claimed` -- and `claimed` does not pass approval-bearing gates.
