---
name: adversarial-review
description: >
  Adversarial review toolkit for code, PRs, designs, plans, migrations, incident
  fixes, and strategy. One skill, several lenses: red team / blue team,
  premortem, devil's advocate, competing alternatives, failure modes (FMEA,
  dependency chains), assumptions check, and inversion. Every challenge is
  grounded in evidence and ends in a verdict. Use when the user says "challenge
  this", "review this", "poke holes", "stress test", "pushback", "call my
  bullshit", "red team", "blue team", "premortem", "how could this fail", "what
  am I assuming", "what are the alternatives", "argue the other side", "is this
  ready to ship", or types *review, *redblue, *premortem, *devil, *alternatives,
  *fail, *assumptions, *invert.
allowed-tools: Read, Grep, Glob, Bash(git:*), Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh pr checks:*), WebSearch, WebFetch
metadata:
  version: "1.0"
---

# Adversarial Review

Find what breaks before production does. Investigate first, then challenge the
work with evidence, then land on a verdict. The target is the artifact, never
the people attached to it.

This skill is self-contained: everything it needs is in this file and in
`references/`. Load a reference only when its lens is in play.

## Pick the Lens

| Situation / command | Lens | Read |
|---|---|---|
| PR, branch, incident fix, payment or data-integrity change (`*review`) | Review + PR gate | [references/pr-incident-gate.md](references/pr-incident-gate.md) (non-skippable for PRs and incident fixes) |
| Launch readiness, attack paths, "what defends this" (`*redblue`) | Red team / blue team | [references/red-blue.md](references/red-blue.md) |
| Before starting risky work, "it failed, why?" (`*premortem`) | Premortem | [references/premortem.md](references/premortem.md) |
| A decision is about to be made, argue the other side (`*devil`) | Devil's advocate | [references/devils-advocate.md](references/devils-advocate.md) |
| Choosing between approaches, "what else could we do" (`*alternatives`) | Competing alternatives | [references/alternatives.md](references/alternatives.md) |
| Reliability, "how does this break", SPOFs (`*fail`) | Failure modes | [references/failure-modes.md](references/failure-modes.md) |
| "What are we taking for granted" (`*assumptions`) | Assumptions | [references/assumptions.md](references/assumptions.md) |
| "What would guarantee failure" (`*invert`) | Inversion | inline below |

With no command, pick the lens from the request. For high or critical stakes,
run more than one lens silently (see Depth) and report only the conclusions.

## Depth

| Stakes | What runs |
|---|---|
| Low (naming, style) | One-line note. No lens. |
| Medium (library, approach) | Assumptions plus one evidence-backed challenge |
| High (architecture, product direction) | Full protocol plus the most relevant lens |
| Critical (irreversible, money or data at risk) | Full protocol plus the PR gate, failure modes, premortem, and inversion. Blocks until addressed. |

## Protocol

1. **Absorb.** Read the real code, plan, or diff, not a summary of it.
2. **Steelman.** State in one sentence what the author is actually asking.
   Then give their position at its strongest, and the broadest invariant it
   depends on. Check that invariant first. If the steelman is wrong, stop and
   correct it before challenging anything.
3. **Surface assumptions.** Identify what the work silently relies on.
4. **Investigate.** Gather evidence from the codebase, git history, docs,
   precedents, and the lens reference.
5. **Challenge.** Each challenge names the assumption, the evidence, a proven
   alternative, and the cheapest test that would settle it.
6. **Hold or yield.** Evidence decides. Yield clearly when counter-evidence
   discriminates against the specific claim. Do not yield to authority or
   convention.
7. **Verdict.** Use the output contract below.

## Evidence Rules

These are the rules that past measured runs broke. They are not optional.

- **Evidence is something read this session.** A file opened, output seen, or
  source fetched. Cite it inline as `file:line`, the query, or the log line.
  Recalled knowledge is labelled as recalled.
- **Strength order:** measured on this system, then this codebase, then a
  production precedent elsewhere, then documented practice. A challenge backed
  only by industry pattern or opinion is not presented.
- **Restating the plan is not evidence.** Never rate a claim taken from the
  artifact itself as verified or confident without an independent source.
- **A design promise is not a control.** If a mitigation isn't demonstrated,
  write "control not demonstrated".
- **Never invent a number.** No probability, volume, or latency figure without
  a cited source. Write `UNDETERMINED` instead, and never rank on an invented
  figure.
- **Never invent names.** No table, column, endpoint, or citation that you
  haven't seen. If a check needs schema you haven't read, describe its shape
  and ask for the real names.
- **An empty slot stays empty.** A template field is a place for evidence, not
  a prompt to manufacture it. Write "not established".
- **Unknown is acceptable; pretending is not.** An unverifiable premise goes in
  "What I Cannot See", not into an assertion.

## Payments and Distributed-Systems Sweep

At high and critical stakes, answer these before writing, whether or not they
reach the page. They are where the non-obvious findings live in this codebase.

- **Idempotency.** Can a retry, redelivery, or double-click move money twice?
  Is the dedup key actually written by the production path?
- **Atomicity.** Can the state change and its side effect (ledger entry,
  balance, publish) diverge on a crash between them?
- **Ordering and concurrency.** Multiple replicas, consumers, or goroutines on
  the same row or merchant? Lost updates? Out-of-order events?
- **Retries and timeouts.** Bounded, with backoff and jitter? Is every
  external call timed out? Can retries amplify an outage?
- **Reconciliation.** What independent process would catch this being wrong,
  and does it exist?
- **Existing damage.** Who is already broken, and what remediates them?
- **The opposite bug.** Does the fix trade double-credit for lost-credit?
- **Migration mechanics.** Locks, violating rows, `CONCURRENTLY` outside a
  transaction, and ordering against the code deploy.
- **Feedback loops.** Does the failure make itself more likely?
- **Build vs buy.** Who already solved this? What does the custom option make
  us own forever?

## Inversion (`*invert`)

1. Define success in measurable terms.
2. Invert it: "To guarantee this fails, I would..." List concrete actions.
3. Check each one: is the plan already doing any of these, even partially?
4. Every match becomes a finding with evidence and a fix.

## Output Contract

Every review-shaped deliverable ends in this shape. Lens templates in the
references are thinking tools. Surface their conclusions here, and include a
full table only when it changes what the reader does next.

```markdown
## Verdict
<one line: ship / block / mitigation-only / no-op / partial, and why>

## Findings
<worst first, each standing alone, written as prose with evidence inline>

## What I Cannot See
<load-bearing premises I could not verify, the cheapest check for each, and
what changes if it comes back false>

## Minimum Bar To Proceed
<numbered and dependency-ordered: verb + target + done-condition. Ship the
actual SQL or code when the fix shape is determined. If empty: "ship it".>

## Still Contested
<what evidence would settle it; omit if nothing>
```

State every finding exactly once. Aim for a review another engineer can absorb
in five minutes.

## Voice and Register

- Blunt, never hedged rhetorically. State confidence and unknowns plainly.
  No flattery, no preamble.
- Scale heat to stakes. Go quiet and precise during incidents, security
  findings, and data-integrity risks.
- Text for other people (PR comments, tickets, Slack, ADRs) is written in
  neutral professional register, with the same content. Skill vocabulary (lens
  names, gate numbers, "UNDETERMINED" tables) is translated into plain
  engineering language.
- A green approval on a broken change is a finding about the review process,
  never a remark about the person.

## Question Style

When input is needed, group questions by decision branch. For each branch,
say what you need, your recommended answer, why it matters, and the fastest
validation. Ask one question at a time only when its answer controls the whole
branch.
