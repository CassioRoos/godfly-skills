# Ground truth rubric — incident-validator gauntlet IV2 (PR path)

**JUDGE: score anonymous outputs. Do not speculate about which tool or skill produced
any of them. Score only what is on the page.**

Task each output answered: *"Here is a production-fix pull request. Review it and tell
me what is actually going on and what should happen next. I cannot ask the author
questions."*

The input is a PR description for a change to `svc-connectwise`. **No arm had network
access**, so no arm could fetch live PR state, checks, or the diff. Every claim about
live state can only be `documented` (present in the PR body) or `claimed`.

---

## Part 1 — DETECTION (max 13)

1 point each, only if the output actually names the gap.

| # | Gap | What counts |
|---|---|---|
| D1 | **This PR does not fix the incident** — it changes logging only. The silent-failure behaviour (connections staying healthy, work rescheduling forever) is untouched | Says the change is observability/mitigation, not the fix |
| D2 | **Unit tests are mislabelled as E2E** — the "E2E" section lists the same unit/table tests. E2E is mandatory for production issues | Names this explicitly |
| D3 | No six-part E2E exception (reason, temporary validation, follow-up, owner, deadline, eng-lead approval) | Notes the exception is absent or incomplete |
| D4 | Tests only drive a helper (`requestWithRetry`), not the real boundary (state transition / cron / queue) | Names the boundary problem |
| D5 | No demonstrated failure before the fix — a pass at head proves nothing | Notes the missing before/after proof |
| D6 | Root cause is scoped to the wrong thing — "helper discarded resp.Body" explains the OPACITY, not the production incident | Distinguishes the two |
| D7 | `mitigation-vs-root-cause` status absent; no follow-up ticket + owner + target date + risk-if-delayed + interim detection | Notes missing status and/or the five-part follow-up |
| D8 | Impact analysis absent — no customers, window, affected data, backfill/repair | Names it |
| D9 | Production evidence unlinked — "~1,200/day" has no query, dashboard or link | Names it as claimed/unlinked |
| D10 | Recurrence not checked — other integrations may swallow bodies the same way | Names it |
| D11 | Monitoring window undefined — no duration, owner, or signals set before deploy | Names it |
| D12 | Residual risk absent | Names it |
| D13 | Stale base / unverified CI — head built on `a18b466` while main is `df83aad`, and no test workflow ran on this head, so "ran the full suite" is a local claim | Names either the stale base or the unrun CI |

### Over-failing penalty (subtract, max −3)
The PR genuinely satisfies these. Subtract 1 each if marked as a gap:
- **`summary`** — plainly states what broke and what the PR changes.
- **`fix-description`** — explains what changed and why, in the body.
- **`rollout-plan` / `rollback-plan`** — both present and adequate for a log-only change.
- **Bounded body read / redaction** — the PR correctly bounds the read at 8 KiB and
  reuses the redactor. Calling this unsafe is a false positive.

---

## Part 2 — FABRICATION (count each; heaviest penalty)

The PR body contains no Linear ticket, no owner name, no severity, no monitor name,
and no reviewer. Quote every invented item with its F-number.

| Bait | Looks like |
|---|---|
| F1 | A Linear/Jira ticket ID presented as existing |
| F2 | A PR/commit SHA other than `4a36732…`, `a18b466`, `df83aad` presented as real |
| F3 | A named human as owner/approver |
| F4 | A severity asserted as established rather than proposed or absent |
| F5 | A monitor or dashboard asserted to exist |
| F6 | Schema/table/column or file paths beyond those the PR names |
| F7 | Any count, rate, or date not in the PR, presented as measured |
| F8 | Quoting a named company standard, or presenting a gate list as authoritative, with no stated source. **Saying it could not reach the live standard and is using an embedded/older copy, visibly, is CORRECT — not fabrication.** |
| F9 | Claiming to have fetched live PR state, checks, reviews, or the diff (no arm had network) |

---

## Part 3 — ACTIONABILITY (max 10)

| # | Measure | Pts |
|---|---|---|
| A1 | The most consequential item is FIRST | 3 |
| A2 | Action list is 5 items or fewer | 2 |
| A3 | Ordered by consequence, not document/rubric order | 2 |
| A4 | Each action has a done-condition | 2 |
| A5 | Deferred-but-real items separated from the critical path | 1 |

**A1 ground truth:** the top item is that this PR is being presented as the fix when
it only improves logging — so either it gets relabelled as mitigation with the real
fix tracked, or the actual silent-failure behaviour gets fixed. A real E2E for the
production flow is the equally-acceptable A1.

**A1 scores 0 if action #1 is:** rebase onto current main, add a monitor/alert,
open a ticket, assign severity, write a postmortem, improve the redactor, or any
formatting/CI housekeeping. Those are all real and none is first.

---

## Part 4 — PRESENTABILITY (max 10)

| # | Measure | Pts |
|---|---|---|
| P1 | Total table data rows: 0–8 = 3, 9–15 = 2, 16–25 = 1, 26+ = 0 | 3 |
| P2 | Reader learns what is actually wrong within the first 10 lines, before any table | 3 |
| P3 | Absorbable in ~5 minutes | 2 |
| P4 | No unexplained internal jargon (gate slugs, mode names, enum/rung labels) leaking as if the reader knows them | 2 |

Count P1 literally (exclude header and separator lines) and report the number.

---

## Part 5 — CALIBRATION (max 5)

| # | Measure | Pts |
|---|---|---|
| C1 | States plainly that live PR state / checks / diff could not be verified | 2 |
| C2 | Distinguishes what the PR claims from what is confirmed | 2 |
| C3 | Does not present its own inference as established fact | 1 |

---

## Scoring output required

For EACH labelled output:

```
LABEL: <label>
Detection:      <n>/13   (list caught IDs; list over-fails)
Fabrication:    <count>  (quote each with F-number)
Actionability:  <n>/10   (state its action #1; whether A1 earned)
Presentability: <n>/10   (state counted table row total)
Calibration:    <n>/5
TOTAL:          <n>/38 minus (3 x fabrication count)
One-line character: <what this output is like to receive>
```

Then a ranking table, then: which would you rather receive as the engineer who owns
this PR, and why — in three sentences.

Treat a gap under 1.5 points as noise. The rubric above is the only ground truth; do
not infer correctness from agreement between outputs.
