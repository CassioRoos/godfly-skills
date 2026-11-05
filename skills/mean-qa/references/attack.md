# Attack — design cases that find defects

The job is not to confirm the feature works. It is to find the input, order or failure that makes it lose money, corrupt state, harm someone or lie.

## 1. Name the harm

1. What is the unit of harm here? Money moved wrongly, a record disclosed, a message that cannot be recalled. Name it in one sentence.
2. What must never happen, even once?
3. Who must never see this, and who must always be able to? Wrongful denial is harm too.
4. Which deadline or timing carries consequence?
5. What record must exist afterwards to defend the decision?

In a regulated domain the correct behaviour often lives outside the code (a statute, a standard). Name the rule and ask. Never state a regulatory requirement from general knowledge.

## 2. Make each dependency fail

For each service, cache, lookup, flag or config value the operation reads:

1. Make it unavailable, slow, or ignorant (empty answer).
2. Assert the operation refuses, rather than proceeds on a zero value.

Testers feed a dependency wrong data far more often than no data. The second is where the silent no-op gates live.

## 3. The axes

| Axis | Question | Typical defect |
|---|---|---|
| Concurrency | Two at once? | Check-then-act race, lost update, spend past a limit |
| Duplication | Same request twice? | No idempotency, retry after timeout, replayed event |
| Partial failure | Dies between step N and N+1? Every external call has success, failure and unknown. | Value moved with no record, event published before commit |
| Boundary | Zero, negative, empty, max, one past, exactly at? | Off-by-one, sign error, inclusive/exclusive mix-up |
| Identity | Someone else, or nobody? | Missing ownership check, cross-tenant read |
| Time | Clock moves, differs, or sits on the boundary? | Timezone, DST, expiry window, skew between services |

## 4. Find the cut corner

Read the implementation for the shortcut: a read then a conditional write with no transaction; an early error return that leaves earlier writes behind; validation on happy-path fields only; a publish before the commit it describes; a status field nobody reads; a filter that excludes one state and silently includes the rest. Each one is a case.

## 5. The cheap probes

Each probe costs one request. Run them on every input-accepting surface, in blast-radius order, until the budget runs out. Every surface you did not reach is a `➖ not run` row that names the missing probes.

| Probe | Catches |
|---|---|
| Bytes that are not valid input | A parser that leaks a 5xx and an internal message |
| Wrong type per field: string for number, `null`, array for object | Unguarded casts, silent coercion |
| Missing required field; unexpected extra field | Happy-path-only validation, mass assignment |
| Client-supplied timestamp, id, total, status, actor | Values stored without validation. Read the record back. |
| Zero, negative, empty string, one past max, exactly at limit | Sign and boundary errors |
| The same request twice, then N at once | Missing idempotency, races |
| No credential; another actor's id; an id that does not exist | Missing authorization, enumeration, error-shape leaks |
| Oversized field, unicode, control characters | Truncation, encoding corruption, injection |

Read the error contract, not only the status. A 500 where a 400 belongs is a defect, and its body often names an internal detail.

**Bypass the UI.** Every constraint the UI enforces is also a case at the API. Send the value the form would block, the foreign id the list would hide, the action behind the hidden button.

## 6. Rank and predict

Rank by what the defect costs: silent money or data loss → wrong value shown later → authority violation → stuck or corrupt state → wrong error contract → cosmetic. A run cut short must still have run the expensive part.

Before each case, write the expected result and the `Fails if` condition. A case whose outcome you cannot predict is an exploration. Label it. An exploration that "passes" proves nothing.

## 7. Write cases, not topics

```markdown
### TC-04 — A paid expense can be approved again

**Attacks:** legal transitions · **Oracle:** spec §3 "paid is terminal" · **Fixture:** `EXP-PAID` (status paid, amount 240.00)
**Input:** `POST /expenses/exp-7f21/approve` as `mgr-002`
**Expected:** 409, row unchanged
**Fails if:** any 2xx, or the stored status changes
**Graduates to:** a unit test on the transition table
```

- **Stable ID.** Assigned once, never reused, so a re-run reports "TC-04 still fails".
- **Title names the failure**, not the component.
- **Literal inputs.** Never "various invalid inputs".
- **Fixtures** are named once, before the cases, with the properties that matter.
- **One case per distinct cause.** Two cases that fail for the same reason are one case with two input rows.
- **Graduates to** names the permanent test the case should become. Omit it when none is worth writing.

## 8. Re-runs

The case list lives in the PR body. A re-run on a new head SHA:

1. reads the previous case list from the PR,
2. reports each ID as `✅ pass`, `❌ fail`, `➖ not run` or retired (with the reason),
3. adds new cases only when they attack something new.

Never drop a case silently.

## 9. Graduation

A case becomes a permanent test when it caught something real, or guards an expensive invariant.

1. Show the test failing on the broken code first.
2. One defect per test.
3. Assert the specific value, never non-null or a bare 200.
4. Write it into the project's own suite, in its own conventions.
