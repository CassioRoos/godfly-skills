# Test Cases — The Unit A Human Can Run And Re-Run

A charter says what you set out to learn. A **case** is what someone else can
execute without asking you a question. Campaigns die as prose; they survive as
cases.

This format is not decoration. It is simultaneously the thing that makes a
report scannable, the thing that makes it executable, and the thing that lets a
future run say "TC-104 still fails" instead of re-deriving the whole
investigation.

## The shape

```markdown
### TC-104 — Paediatric dose rounding destroys sub-milligram precision `[S1]`

**Attacks:** dose conservation · **Oracle:** internal inconsistency — the stored
dose differs from dose_per_kg × weight
**Fixture:** `P-PAED` (3.2 kg)

**Hypothesis.** `int(x + 0.5)` rounds to whole milligrams, so anything under
0.5 mg becomes zero and small doses carry double-digit percentage error.

| Sub | Input | Expected | If defective |
|---|---|---|---|
| a | `dose_mg_per_kg=0.1` | 0.32 mg stored | `0` |
| b | `dose_mg_per_kg=0.5` | 1.6 mg stored | `2` (+25%) |

**Steps.** 1. POST the order. 2. Read the persisted dose directly, not the API echo.
**Fails if:** stored dose ≠ computed dose to the precision the formulary requires.
**Evidence:** `TC-104/request-a.json`, `TC-104/response-a.json`, `TC-104/db-dose-a.txt`
**Graduates to:** a unit test over the dose function with these four rows.
```

Every element earns its place:

- **Stable ID** — `TC-<area><n>`, assigned once and never reused. A later run
  reports `TC-104: still fails` / `now passes` / `not run`. Without stable IDs
  there is no such thing as a regression check, only a fresh opinion.
- **Plain-language title stating the failure**, not the component. "A
  discontinued order can still be administered" beats "Order status validation
  in Administer()". A reader who reads only titles must still understand the risk.
- **Severity inline** `[S1]`–`[S3]`, so triage happens while scanning.
- **What it attacks** — the invariant, in three words. Ties the case back to the
  harm model and makes an orphaned case obvious.
- **Oracle** — how you will know it is wrong. Without it the case cannot be
  re-judged later: a future reader sees the assertion but not why that value was
  expected, and cannot distinguish a real regression from a changed intention.
- **Fixture by name** — seeded once, referenced by ID, reusable across cases.
- **Concrete inputs in a table** when a case has variants. Literal values, not
  "various invalid inputs". The table is what makes it runnable by someone else.
- **Fails if** — the falsification condition, stated before running.
- **Graduates to** — the permanent test this becomes once the behaviour is
  understood.

## Evidence, addressable by case

Artifacts in a pile are not evidence; artifacts you can ask for **by case ID**
are. Every executed case writes its artifacts to a directory named for its ID:

```
<run-dir>/
  cases/
    TC-104/
      request-a.json          request payloads, one per sub-case
      response-a.json         responses, headers and status included
      db-dose-a.txt           the direct read that bypasses the API's opinion
      notes.md                what happened, one paragraph
    TC-301/
      search-response.json
      before.png / after.png  screen-checked flows: both, always
      network.har
  fixtures/                   seed definitions, reusable next run
  session.md                  the session sheet
```

What each case retains, by kind of surface:

| Surface | Minimum retained |
|---|---|
| API / gRPC | Request payload, response body, status, correlation/request ID, timestamp |
| UI | Before and after screenshots, console output, network capture |
| Persisted state | The direct read — the query and its literal result, before and after |
| Messaging | Published payload, queue/binding state, consumer effect or DLQ entry |
| Runtime | The log lines or trace with their identifiers, and the time window |

**The rule that makes this real: a case status is only as credible as its
artifact.** A case marked `pass` with no retained evidence is `unproven` — say
so, rather than letting an empty directory imply a green result. When a case
genuinely produces nothing retainable, write why in `notes.md`.

Two artifacts do disproportionate work and are the ones most often skipped:

- **The direct read.** The API's own echo of what it stored is not evidence that
  it stored it. Query the state directly and keep the literal output.
- **The negative.** When a case proves something did *not* happen — no page
  fired, no audit row written, no event published — retain the query that came
  back empty, with its time window. An absence with no artifact is an assertion.

**Sanitise on the way in, never afterwards.** Payloads and screenshots from
real systems carry credentials, tokens, personal data, and — in clinical, legal,
and financial domains — data that must not leave its system at all. Redact
before writing to disk, never write raw exports, and prefer synthetic fixtures
precisely so the artifacts are safe to keep and share. A screenshot is the
easiest way to leak an entire record by accident.

## Fixtures up front

Seed and name every fixture in one section before the cases, with the properties
that matter (`P-PAED` — 3.2 kg, no allergies; `P-NOWEIGHT` — weight null;
`P-RESTRICTED` — confidentiality=restricted). Cases then reference them by name.
This removes setup noise from every case, makes the data requirements a single
reviewable list, and lets a later run reproduce the environment exactly.

## Ordering

Group cases into phases ordered by **blast radius**, and say what each phase
gates. "PHASE 1 — Stop-ship: does the record mean what the clinician typed?"
tells a reader who stops early exactly what they got. Within a phase, worst first.

A campaign truncated after one phase must still have run the phase that matters.

## Case count is not a virtue

Cases are cheap to generate and expensive to run. Precision beats volume:
generating more tests has been shown not to improve defect detection. Prefer
twelve cases that each attack a distinct invariant over forty that permute the
same input. If two cases would fail for the same reason, they are one case with
two rows.

## Re-running later

The case list is the durable artifact. On a later run, produce a status line per
ID — `pass` / `fail` / `not run` / `retired` — before adding anything new. Three
rules keep it from rotting:

- **A case retires when the behaviour it attacks no longer exists.** Say so
  explicitly; do not silently drop it.
- **A case that has passed on ten consecutive runs and guards a stable invariant
  is a graduation candidate**, not a permanent manual chore.
- **Only add.** A suite that only ever grows becomes unrunnable, and then
  nobody runs any of it. Maintenance is the majority cost of a test suite over
  its life; an agent that never retires anything is manufacturing that cost.

## Graduation

A case earns a permanent automated test when the behaviour is stable and the
case has caught something real, or guards an invariant whose violation would be
expensive.

- **Demonstrate the failing state first.** A test that passes against the broken
  code proves nothing, whatever it asserts. Watch it fail, fix, watch it pass.
- **One defect per test.** Bug-reproducing tests overwhelmingly target exactly
  one bug; bundling makes the failure ambiguous.
- **No weak assertions.** Non-null, "no exception thrown", bare 200 — these are
  the characteristic defect of this category of test. Assert the specific value.
- **Write it to the project's own conventions**, in the project's normal suite.
  A quarantine folder of agent-written tests is a folder nobody runs.
