# The Report — what a reader must be able to reconstruct

Write for one person: an engineer who was not in the room, deciding whether to
ship. When they finish, they must be able to answer five questions without
asking you anything.

1. **What was tested**, and what "working" meant for it.
2. **How it was tested** — the actual flows driven, in the order they happened.
3. **What happened**, with the proof attached, case by case.
4. **Why each failure happens** — the mechanism, not just the symptom.
5. **What to do next**, and what nobody has checked yet.

A report that answers four of five has failed. The most commonly missing one is
the fourth.

## Never cut

Evidence, flows, test cases, scenarios, and the explanations that connect them.
These are the document. If it is long because it contains eleven captured
request/response pairs and an explanation of each failure, it is the right
length. Cut methodology narration and taxonomy instead — never proof.

Screens are evidence, so they are embedded and not merely cited: `![what it
shows](01-name.png)`, at the point the capture is used. A filename dropped into a
sentence makes the reader go hunting, and the reader will not go hunting — they
will take the sentence on trust, which is the opposite of what a captured screen
is for. This holds for the screens that behaved as well as the ones that did
not.

## Structure

Organise **by flow or surface**, not by evidence type. A reader thinks in terms
of "the approval path", "the search screen" — not "here are all my screenshots,
here are all my queries". Each flow gets: what it is, a results table, the
captured evidence, and prose explaining anything a table cannot carry.

````markdown
# <Feature or change> — QA report

<One or two plain-language paragraphs: what this does, and what "working" means
for it. Written from the diff or the spec, not from the ticket title. A reader
who knows nothing about this feature starts here and is oriented.>

**Verdict:** SHIP / HOLD / CONDITIONAL — <one sentence, the single blocking reason>
**Environment:** <env, base URL, how reached>
**Build under test:** <image/tag/commit, or the marker that proved it>
**Run:** <date, window> · <n> cases executed, <n> failed · fixtures <names>

## Worst first

1. **<Plain-language failure title>** — <what happens, to whom, and what it
   costs>. <link to the case>
2. ...

## How this was tested

<A short narrative of the campaign: what was seeded, which flows were driven in
what order, what each phase was trying to break, and anything that changed
course mid-run. Three or four paragraphs. This is the section that makes the
rest legible — without it a reader has a pile of results and no story.>

---

## Flow 1 — <the approval path>

<What this flow is and why it matters. What "working" means here specifically.>

| # | Case | Expected | Result | Time | Evidence |
|---|------|----------|--------|------|----------|
| 1 | Approve a submitted expense | 200, status → approved | ✅ | 0.04s | [details](#c1) |
| 2 | Approve an already-paid expense | 409, state unchanged | ❌ | 0.03s | [details](#c2) · [BUG-004] |
| 3 | Approve above the approver's limit | 403 | ✅ | 0.03s | [details](#c3) |

<Prose for what the table cannot hold: the nuance, the surprise, the thing you
had to check twice. "Case 3 passes, but only because the limit is compared with
`>=`; a limit of exactly the threshold is rejected, which matches the policy
doc — worth confirming with Finance that this is the intended boundary.">

### <a id="c2"></a>Case 2 — approving a paid expense succeeds

**What should happen.** A paid expense is terminal. Approving it again is not a
legal transition and the API should refuse.

**What happened.** It returned 200 and moved the record back to `approved`.

```bash
curl -sS -X POST -w '\nHTTP %{http_code} in %{time_total}s\n' \
  -H 'X-Actor: mgr-002' \
  http://localhost:8081/expenses/exp-7f21/approve
```

```json
{ "id": "exp-7f21", "status": "approved", "amount": 240.00, "paid_at": "2026-08-07T09:14:02Z" }
```
```
HTTP 200 in 0.031s
```

**Why it happens.** `approve()` loads the record and writes `status =
"approved"` with no guard on the current status. The state machine exists in the
documentation and nowhere in the code, so every transition is legal.

**What it costs.** A paid expense returns to the approval queue with `paid_at`
still set. The next pay run has no way to tell it was already settled — this is
a double-payment path, not a cosmetic state bug.

**Direct read** — confirming the API's answer matches the stored row, since an
echo is not proof of persistence:

```
$ sqlite3 fixture.db "SELECT id,status,paid_at FROM expenses WHERE id='exp-7f21';"
exp-7f21|approved|2026-08-07T09:14:02Z
```

**Fails if:** the second approve returns anything other than a 4xx with the row
unchanged. **Reproduced:** 2/2 from clean state.

---

## Flow 2 — <the next surface>

...

## Durable state

<The direct reads, verbatim — query and literal output — for anything the run
claims was persisted, changed, or not written. Include the negatives: the query
that came back empty, with its window.>

## Screens driven

<Browser runs only, and not optional. Every screen and state you drove, in
capture order, each one embedded — `![pre-fix: the readings table showing
undefined](02-detail-empty-before.png)` — with a line saying what the reader is
looking at. The states that worked included: this section is what was tested,
and a reader cannot take your word for a surface they cannot see. Before/after
pairs adjacent, so the change is visible in one glance.>

## Console and network

<Browser runs only, and not optional. What console showed, what the network
showed, which calls were observed and their statuses. A clean screen over a
dirty console is a finding. Note also what you asserted from the DOM rather than
from a rendered capture — an element read out of `document` proves the string
existed, not that the user could see it.>

## Checks outside the run

<Typecheck, unit suite, lint, builds — the command and its result, where they
formed part of the evidence.>

## Coverage — what this run reached

| Interesting state | Reached? | Evidence |
|---|---|---|
| Two approvers acting concurrently | **no** | no harness for parallel calls |

<The "no" rows are the most valuable lines in the document: they turn "we tested
this" into "we tested these paths and not those.">

## Residual risk

- <What remains unsettled, written as consequences rather than tasks. "A full
  payment run was not exercised — the sandbox provider rejects the fixture's
  card, so the settle path stops at authorisation" tells a reader what they are
  accepting. "TODO: test payments" does not.>

## Next steps

1. <The single most valuable next action, and who it belongs to.>
2. <Then the rest, ordered.>
````

## The failure explanation is the part that gets skipped

A ❌ in a table is a symptom. On its own it produces a ticket that says "approve
endpoint broken", and an engineer who has to redo your investigation.

Every failure carries four things: **what should happen**, **what happened**
(with the captured evidence), **why it happens** (the mechanism in the code, or
an explicit statement that you could not determine it), and **what it costs**
(who is harmed, how badly). If you could not determine the mechanism, write that
— an honest "I could not tell from the outside whether this is the handler or
the store" is useful; an invented cause is not.

## Every executed case gets its evidence block — inline AND on disk

Eleven cases means eleven request/response pairs. Not a table asserting they
passed, not three representative samples. Collapse them behind `<details>` if the
page needs to stay scannable — never summarise them away.

Inline `<details>` makes each case *reviewable*. When there is a run directory,
**also write each case's raw evidence to `cases/<case-id>/` as files** — the
runnable request, the literal response, the direct read — so the run is
browseable one-file-per-test and replayable by a machine, not only re-typable by
a person. A reviewer should be able to run `cases/TC-01/request.sh` and get the
recorded response without you present. Layout and the minimum-per-case in
[evidence.md](evidence.md). The report's evidence column links each row to its
`cases/<id>/` directory.

## Designed-but-not-run reports

When nothing was executed, the same structure holds minus the evidence: the
orientation paragraphs, the flows, the cases with their literal inputs and
falsification conditions, the coverage paragraph, the next steps. Say once, near
the top, that nothing was run, and mark every case accordingly. Never let a
designed campaign read like a completed one.
