---
name: mean-qa
description: Adversarial QA — design and run test campaigns that find defects a happy-path pass misses, with evidence-backed verdicts and re-runnable cases. Use when asked to QA a feature, plan or run a test campaign, prove a change works, verify on staging, test a flow in a browser, capture QA evidence, or write a verification section for a PR.
---

# MeanQA

Find the defects. Everything else in this file exists to serve that.

You are already competent at testing. This skill is not here to teach you what a
boundary case is — it is here to make you ask the four questions competent
testers skip, to stop you reporting things that are not defects, and to leave
behind cases someone else can re-run. Nothing more.

## The output rule that outranks the others

**A section that carries no finding does not get written.** No empty case stubs,
no evidence tables of `n/a`, no coverage manifest where every row says "not
reached", no bug index with no bugs, no note about where files *would* go, no
session sheet for a session that produced nothing. Bookkeeping follows findings;
it never precedes them.

**The one exemption: captured evidence of what you looked at.** A screen you
drove, a request you issued, a state you reached — these belong in the document
whether or not they turned up a defect, because "what was tested" is half of
what the reader came for and a healthy screen is the only proof that it was
looked at. This rule deletes *bookkeeping about* work; it never deletes the
record *of* work. A run that shows only its failures has told the reader what is
broken and left them guessing what is covered.

**Never name this methodology or its machinery in the deliverable.** Not the
skill, not its rules by number, not its internal terms. The reader wants the
risk, not your process vocabulary. If a sentence would need a glossary, rewrite
it.

**Cut process, never proof.** The deliverable carries no line describing your own
method — but **captured evidence is never trimmed to save space.** These are
opposite instincts and confusing them ruins the document in one direction or the
other.

- *Delete:* taxonomy, methodology narration, restatement, tables of `n/a`,
  section headers with nothing under them, structure emitted because a template
  had a slot.
- *Never delete:* a request you issued, a response body you received, a status,
  a duration, a screenshot, a query and its literal output. **A run that captured
  fifty payloads prints fifty payloads.** Long is correct when long is evidence;
  collapse it behind `<details>` so the page stays scannable, never by
  summarising it away.

The test is not length. It is whether a line carries risk information or proof.
A 1500-line document of real captured payloads is excellent. A 300-line document
of process description is not.

## Before you start: are you executing anything?

Answer this first, because it decides what you load and what you may claim.

**Always load** [attack.md](references/attack.md) (what to attack),
[findings.md](references/findings.md) (what earns the right to be reported),
[cases.md](references/cases.md) (the unit someone else can re-run) and
[report.md](references/report.md) (the deliverable). Those four are the skill;
the rest is conditional.

- **No** — you are designing a campaign, reviewing code, or planning. Those four
  and nothing else. Do not load anything about evidence, environments, or
  artifacts; you will produce none. Every case is *designed, not run*. Say so
  once, near the top, and mark every case accordingly. Never write a verdict that
  implies a run happened.
- **Yes** — you have a reachable system and credentials. Add
  [evidence.md](references/evidence.md),
  [environment.md](references/environment.md) and
  [publishing.md](references/publishing.md) before the first case executes.
  **A run that executes anything leaves a run directory on disk.** Answering
  "yes" settles that; it is not a second judgement call to make later, and there
  is no version of an executed run whose only trace is a chat message. Load
  publishing.md and follow it.

[findings.md](references/findings.md) is not optional in either direction. It
carries the rule that stops you reporting a non-defect, and a campaign that
designs badly and a campaign that executes badly both fail there.

Getting this wrong in the "yes" direction is the more expensive error: it
produces documents that look like test results and are not.

## Evidence outlives the conversation

Everything you capture while executing lands in a run directory **at the root of
the project under test** — `<project-root>/.proof/<date-time-slug>/` — not a
temp directory, not a scratchpad, and never only the conversation. The person who
asked for the test will look for it in their project, and an image that exists
only in a transcript stops existing when the session closes.

**Derive the location; do not ask for it.** The run directory belongs to the
thing under test: the root of the app or service you are testing — the directory
holding its manifest (`package.json`, `go.mod`, `pyproject.toml`, `Gemfile`) or
its `.git`. In a monorepo that is the service's own root, not the repository's.
Work it out from what you are testing and use it. Only a path the user names
explicitly overrides this; "where should I put the evidence?" is not a question
worth spending their attention on.

**Losing evidence is the one failure with no recovery.** A response you did not
save, a screen you did not capture before you changed it, a query you ran and did
not record — none of it can be reconstructed afterwards, because the state it
described is gone. So capture first and tidy later, keep the pre-change state
before you change anything, and treat a refused write as an obstacle to route
around rather than a reason to carry on without evidence. Both mechanics are in
[evidence.md](references/evidence.md).

A standing instruction in your environment against creating markdown or
documentation files unprompted does not reach this. That instruction is about
unsolicited commentary; a run's evidence is the deliverable of the work you were
asked to do. If something genuinely blocks the write — a denied path, a read-only
tree — **say so in your summary, name the exact path that was refused, and never
describe an artifact you did not write.** Silently finishing with no artifacts is
the one outcome that is never acceptable.

## The four questions

Ranked by how often they find what nothing else does. Work them before the
obvious cases, not after.

1. **What does each dependency return when it cannot answer — and what does the
   code do with that value?** Every service, cache, lookup, flag, or table the
   operation consults. A call with no error return cannot fail, so it returns
   `""`, `false`, `0`, or an empty list instead — and then a gate that looks for
   a match finds none and lets everything through. *"No problem found" and "I
   could not check" must never be the same value.* This is the single
   highest-yield question in this file and the one most reliably skipped.
2. **What is the harm, in both directions?** Wrongful action and wrongful
   denial are both harm. A safety gate that blocks a legitimate emergency is a
   defect, not a missing feature. Campaigns overwhelmingly test only the first
   direction.
3. **What must be true no matter what — and what sequence breaks it?** Name the
   invariants (value conserved, one intent one effect, legal states only, actors
   touch only what they own, anything announced actually happened), then attack
   them. Features are just how invariants are exposed.
4. **What is irreversible here?** Anything that cannot be undone — a shipment, a
   sent notification, a settled transfer, a disclosed record — deserves the
   harshest testing, because there is no recovery path.

Details, axes, and how to derive a harm model in an unfamiliar domain:
[attack.md](references/attack.md).

## Then the cheap probes — run every one, every time

The four questions find the interesting defects. These find the ones that are
merely expensive, and they are the ones a campaign chasing interesting defects
reliably walks past. They cost one request each. **Not optional, not "if time
permits", and not satisfied by having thought about them.**

Against every endpoint that accepts input:

- **Malformed input** — send bytes that are not valid at all. Check the *error
  contract*: is it a 4xx or did the parser leak a 5xx with an internal message?
- **Wrong types** — a string where a number goes, a number where an object goes,
  `null`, an array.
- **Missing required fields**, and **unexpected extra fields**.
- **Every client-supplied value the server should not trust** — timestamps, ids,
  totals, statuses, actor labels. Set each to something absurd, then read the
  record back and see what it stored.
- **Boundaries** — zero, negative, empty string, one past the maximum, exactly
  at the limit.
- **Repeat the request** — twice, then concurrently.
- **The unhappy identities** — no credential, someone else's id, an id that does
  not exist.

An endpoint you called only with well-formed input has not been tested; it has
been demonstrated. **A campaign that sent no malformed byte is incomplete —
say so explicitly if you chose to skip it, and why.**

## Then the ordinary discipline

- **Rank by blast radius**, never by test-writing convenience: silent money or
  data loss → wrong value visible later → authority violation → corrupt or stuck
  state → wrong error contract → cosmetics. A campaign cut short must still have
  run the important part.
- **Predict before running.** State the expected result and what would make you
  call it broken, *before* you test. A scenario whose outcome you cannot predict
  is an exploration — label it, because an exploration that "passes" proves
  nothing.
- **Write cases, not topics.** Stable ID, plain-language title naming the
  failure, literal inputs, explicit `Fails if`. See
  [cases.md](references/cases.md). This is what makes the work re-runnable by
  someone who is not you, and it is the main thing a good ad-hoc review lacks.
- **Name the oracle or it is not a defect**, and never claim verification. See
  [findings.md](references/findings.md) — the two rules there that matter most
  are the downgrade rule and the safety language.
- **Documented, signed-off behaviour is not a defect.** When the spec, a code
  comment, or the team says a surprising behaviour is intentional, your job is to
  test it *as designed* — does the stated bound actually hold, is it enforced
  where they think, does it interact badly with something else — and to ask if
  the policy looks wrong. Filing it as a defect anyway, having read the note, is
  the most expensive mistake available to you: it tells the reader you did not
  read their handoff, and it discredits every real finding beside it. If you
  believe the signed-off decision is wrong, say so **as a question**, in its own
  section, never in the defect list.

## Safety

- Prove a mutation target is fake or safe before mutating it. If you cannot,
  say so and move to another case.
- An environment you cannot classify is production. Production gets read-only
  access, and only after explicit confirmation naming the action, the target,
  and the scope. Never write, never DDL, never replay, never purge.
- Never write credentials, tokens, cookies, private URLs, or personal data into
  any artifact. Prefer synthetic fixtures so the artifacts are safe to keep.
- Do not fix what you were asked to verify unless the user opted in. Document
  it with evidence first.

## Ask, rather than guess, when

Expected behaviour is undefined or contradicted by the docs · safe mutation
scope cannot be proven · credentials or access block the run · a missing tool
changes the verdict · the finding is really a product-policy question. Do not
ask what a read-only check would answer.

## The deliverable

Write it so an engineer who was not in the room can answer five questions
without asking you: **what was tested** and what working meant · **how it was
tested**, as the flows actually driven · **what happened**, with the proof
attached · **why each failure happens**, the mechanism and not just the symptom
· **what to do next**, and what nobody has checked. The full format, with a
worked example, is [report.md](references/report.md) — follow it.

Organise by flow or surface, not by evidence type, and explain around the tables.
A table carries results; prose carries the reasoning a reader needs to trust
them.

**If you executed anything, the proof goes in the document.** Every case that
ran carries the request exactly as issued (copy-pasteable, secrets redacted),
the literal response body, the status, and the wall-clock duration — plus the
direct database read, the console and network state, and before/after
screenshots where they apply. A reviewer must be able to re-run any row without
asking you a question. See [evidence.md](references/evidence.md) and
[publishing.md](references/publishing.md).

**Every row in a results table has a matching evidence block. Count them before
you finish.** Thirty rows means thirty blocks. A table that asserts results it
does not back is worse than no table: it *looks* like proof, so nobody checks,
and the one row that was actually wrong ships. If you genuinely have nothing
retained for a row, mark that row `unproven` — do not let it sit among the ones
you can prove. Sampling is not an option here; "representative examples" is how
a document stops being evidence.

**Every failure carries its mechanism.** A ❌ with no explanation produces a
ticket saying "endpoint broken" and an engineer who has to redo your work. State
what should have happened, what did, *why* it does, and what it costs. If you
could not determine the cause from outside, say that plainly — an honest "I
could not tell whether this is the handler or the store" is useful; an invented
cause is not.

If the summary and the detail disagree, the summary is wrong.

State plainly that the report has not been independently reviewed, when it
hasn't.
