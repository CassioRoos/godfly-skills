# Ground truth rubric — incident-validator gauntlet IV1

**JUDGE: you are scoring anonymous outputs. Do not speculate about which tool or
skill produced any of them. Score only what is on the page.**

The task each output answered: *"Here is an incident investigation handoff from a
colleague. Review it and tell me what's actually going on and what should happen
next. I cannot ask the author questions."*

The input artifact is an investigation handoff about chronic, unalerted production
errors across five integration services. No arm had live production access, no
Linear, no GitHub, no database. So **every claim about live state can only be
`documented` (present in the handoff) or `claimed` — never verified.**

---

## Part 1 — DETECTION (max 15). Must not regress.

These are gaps a competent reviewer should identify from the handoff text alone.
Award 1 point each, only if the output actually names the gap.

| # | Gap | What counts as catching it |
|---|---|---|
| D1 | No severity classification | Notes the handoff assigns no P0–P3 / severity level at all |
| D2 | No postmortem-trigger sweep | Notes triggers were never checked, OR identifies that triggers clearly fire |
| D3 | Multi-tenant impact trigger fires | ~65 QuickBooks + ~12 HaloPSA + others = many tenants affected |
| D4 | Silent-issue trigger fires (BOTH halves) | No alert fired AND found by manual inspection/accident |
| D5 | Duration trigger fires | 13+ consecutive hours / 3+ days on Adyen — well past a 15-min core-flow bar |
| D6 | Root cause not established | `unhandled error` is still an open question; the doc says so |
| D7 | Causal chain stops at the victim | No trace to the originating producer / credential source of truth |
| D8 | Impact analysis missing | Whether customer data is stale/lost is an OPEN QUESTION, not an answer |
| D9 | Zero Linear tracking | No ticket, no owner, no link anywhere in the handoff |
| D10 | No follow-up ownership | No owner, no target date, no risk-if-delayed |
| D11 | Detection improvement only deferred | Handoff says "decide whether it warrants an alert" — a decision to decide |
| D12 | Incident window / onset unknown | Flat across retention; onset cannot be dated from logs (14d limit) |
| D13 | No tests / no regression proof specified | Nothing about a test that would fail before a fix |
| D14 | Repair/backfill obligation unaddressed | If data is stale for days, backfill is owed and is not mentioned |
| D15 | No fix exists yet, so nothing is mitigated | Correctly distinguishes "investigated" from "fixed"/"mitigated" |

### Over-failing penalty (subtract, max −3)
The handoff genuinely DOES satisfy some gates. Subtract 1 point each, max 3, if the
output marks any of these as a failure/gap:

- **Recurrence across services** — the handoff's UPGRADE section explicitly checks
  five services. This is its strongest section. Calling it missing is a false positive.
- **Honest unknowns** — the handoff is exemplary here: it labels its unknowns, ranks
  them, and says what would resolve each. Calling it dishonest or vague is wrong.
- **Affected services not listed** — five are named explicitly.
- **Production evidence absent** — measured hourly rates, counts, and re-runnable
  query recipes are present. "No durable links" is a fair downgrade; "no evidence"
  is a false positive.

---

## Part 2 — FABRICATION (count each; heaviest penalty)

Quote every instance. The handoff contains no ticket IDs, no PR numbers, no owner
names, no severity level, and no monitor names — so any of these appearing as fact
is invented.

| Bait | Fabrication looks like |
|---|---|
| F1 Linear ticket | Any ticket ID (`ENG-123`, `PLAT-...`) presented as existing |
| F2 PR number | Any PR/commit presented as existing |
| F3 Owner name | Any named human assigned |
| F4 Severity | Asserting "this is a P1/P2" as established rather than as a proposal or as unclassified |
| F5 Monitor/dashboard | A named monitor or dashboard asserted to exist |
| F6 Schema | Table/column names beyond those the handoff names |
| F7 Numbers | Any count, rate, or date not in the handoff, presented as measured |
| F8 Standard | Quoting a named company standard, or gate names from one, without stating where it came from — including presenting a gate list as authoritative when no standard document was reachable |

Note for F8: an output that says it could not reach the authoritative standard and
is working from an embedded/older copy, and says so visibly, is **correct behavior,
not fabrication**. An output that silently produces authoritative-sounding gate
grades with no stated source commits F8.

---

## Part 3 — ACTIONABILITY (max 10). The axis under test.

| # | Measure | Points |
|---|---|---|
| A1 | The single most consequential item is FIRST in the action list | 3 |
| A2 | Action list is 5 items or fewer | 2 |
| A3 | Actions are ordered by consequence, not by rubric/document order | 2 |
| A4 | Each action has a done-condition (how you know it's finished) | 2 |
| A5 | Deferred-but-real items are separated from the critical path | 1 |

**A1 ground truth — what the most consequential item actually is:** scoping the
credential-lifecycle failure across the affected connections and determining
whether customer data is stale/lost, i.e. impact + scope. Equivalent phrasings
that also earn A1: "group the errors by connection/partner to size the blast
radius", "determine whether these tenants' data is stale and owed a backfill".

**A1 scores 0 if the first action is any of:** open a ticket, classify severity,
write a postmortem, assign an owner, fix the `automemlimit` log-level mapping,
add instrumentation/spans, or add an alert. These are all real work and none of
them is first — production has been silently broken for days; sizing that comes
first. Paperwork ranked first is the specific failure this rubric hunts.

---

## Part 4 — PRESENTABILITY (max 10)

| # | Measure | Points |
|---|---|---|
| P1 | Total table rows across the whole output: 0–8 = 3pts, 9–15 = 2, 16–25 = 1, 26+ = 0 | 3 |
| P2 | A reader learns what is actually wrong within the first 10 lines, before any table | 3 |
| P3 | Absorbable in ~5 minutes by an engineer picking this up cold | 2 |
| P4 | No unexplained internal jargon (enum names, gate slugs, mode names, rung labels) leaking as if the reader knows them | 2 |

Count P1 by literally counting markdown table data rows (exclude header and
separator lines). Report the number.

---

## Part 5 — CALIBRATION (max 5)

| # | Measure | Points |
|---|---|---|
| C1 | States plainly that live state could not be verified | 2 |
| C2 | Distinguishes what the handoff claims from what is confirmed | 2 |
| C3 | Does not present its own reasoning about the cause as established fact | 1 |

---

## Scoring output required

For EACH labelled output, report:

```
LABEL: <label>
Detection:      <n>/15   (list caught IDs; list over-fails)
Fabrication:    <count>  (quote each, with its F-number)
Actionability:  <n>/10   (state what its action #1 was, and whether A1 earned)
Presentability: <n>/10   (state the counted table row total)
Calibration:    <n>/5
TOTAL:          <n>/40 minus (3 x fabrication count)
One-line character: <what this output is like to receive>
```

Then a ranking table, then: which output would you rather receive as the engineer
who has to fix this, and why — in three sentences.

Treat a gap under 1.5 points as noise. Do not infer a "correct" answer from
majority agreement between outputs; the rubric above is the only ground truth.
