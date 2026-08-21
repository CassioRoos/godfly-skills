# Cases — the unit someone else can run

A charter says what you set out to learn. A **case** is what another person can
execute without asking you a question. Campaigns die as prose; they survive as
cases. This is the main thing a good ad-hoc review lacks.

## The shape

```markdown
### TC-104 — Paediatric dose rounding destroys sub-milligram precision `[S1]`

**Attacks:** dose conservation · **Oracle:** the stored dose differs from
dose_per_kg × weight
**Fixture:** `P-PAED` (3.2 kg)

| Sub | Input | Expected | If defective |
|---|---|---|---|
| a | `dose_mg_per_kg=0.1` | 0.32 mg stored | `0` |
| b | `dose_mg_per_kg=0.5` | 1.6 mg stored | `2` (+25%) |

**Steps.** 1. POST the order. 2. Read the persisted dose directly, not the API echo.
**Fails if:** stored dose ≠ computed dose to the precision the domain requires.
**Graduates to:** a unit test over the dose function with these rows.
```

Every element earns its place:

- **Stable ID**, assigned once, never reused — so a later run reports "TC-104
  still fails" instead of a fresh opinion. Without stable IDs there is no such
  thing as a regression check.
- **A plain-language title naming the failure**, not the component. "A
  discontinued order can still be administered" beats "Order status validation
  in Administer()". A reader who reads only titles must still understand the risk.
- **Severity inline** so triage happens while scanning.
- **The invariant it attacks**, in three words — makes an orphaned case obvious.
- **The oracle** — how you will know it is wrong. Without it, a future reader
  sees the assertion but not why that value was expected, and cannot tell a real
  regression from a changed intention.
- **Literal inputs**, never "various invalid inputs". This is what makes it
  runnable by someone else.
- **`Fails if`** — the falsification condition, stated before running.
- **`Graduates to`** — the permanent test this becomes once the behaviour is
  understood. Omit when it would not earn one.

**Never emit a case as a heading with nothing under it.** An empty stub is worse
than an absent case: it claims coverage that does not exist.

## Fixtures

Name every fixture once, before the cases, with the properties that matter
(`P-PAED` — 3.2 kg, no allergies; `P-NOWEIGHT` — weight null). Cases reference
them by name. This removes setup noise from every case and makes the data
requirements a single reviewable list.

## Ordering

Group into phases by **blast radius** and say what each phase gates. A campaign
truncated after one phase must still have run the phase that matters.

## Volume

Cases are cheap to generate and expensive to run. Prefer twelve that each attack
a distinct invariant over forty permuting the same input. If two cases would fail
for the same reason, they are one case with two rows. Generating more tests does
not improve defect detection; precision does.

## Re-running later

The case list is the durable artifact. On a later run, produce a status line per
ID — `pass` / `fail` / `not run` / `retired` — before adding anything new.

- **A case retires when the behaviour it attacks no longer exists.** Say so; do
  not silently drop it.
- **Only add** when it earns its place. A suite that only grows becomes
  unrunnable, and then nobody runs any of it.

## Graduation

A case earns a permanent automated test when the behaviour is stable and it has
caught something real, or guards an invariant whose violation would be expensive.

- **Demonstrate the failing state first.** A test that passes against the broken
  code proves nothing, whatever it asserts.
- **One defect per test**, or the failure is ambiguous.
- **No weak assertions** — non-null, "no exception thrown", bare 200. Assert the
  specific value.
- **Write it into the project's own suite**, to its conventions. A quarantine
  folder of agent-written tests is a folder nobody runs.
