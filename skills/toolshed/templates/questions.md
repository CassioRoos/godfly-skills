# {{SLUG}} — questions

Upsert-only: append with the next free ID; update only by adding answers,
status changes, History lines; supersede, never delete. Questions that change
a contract get **promoted** immediately and marked so here.

Statuses: `open` · `answered` · `promoted` (lives in a permanent home now —
link it) · `parked` · `superseded`.

**`parked` needs two things, not one:** its wake-up trigger **and** a permanent
**Home** (ADR open-questions section, runbook, or ticket). This folder is
deleted at close, so a parked question with no home is a question being
dropped quietly — `assert-close.sh` fails on it.

**Answered-by-decision:** an open P0 may be unblocked by deciding around it
when the owner explicitly instructs you to proceed. The decision record then
carries a **flip condition** and the question gets a loud History line
pointing at it. The question stays `open` (it is still unanswered, and it will
hold the close gate until it is answered or parked with a home).

<!-- Record skeleton:

### Q-001 — <one-line question>
- **Status:** open · **Priority:** P0/P1/P2 · **Owner:** <who answers, if known> · **Opened:** YYYY-MM-DD
- **Origin:** <what raised it, with evidence ref>
- **Question:** <the precise decision needed>
- **Answer:** <when it exists, with grade — MEASURED/CONFIRMED/REPORTED/UNRESOLVED>
- **Home:** <required for `parked`: where this question lives after close>
- **History (YYYY-MM-DD):** <appended>
-->

_(no questions yet)_
