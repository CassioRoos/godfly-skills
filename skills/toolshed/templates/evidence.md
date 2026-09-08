# {{SLUG}} — evidence

Every measurement that lands **here** needs its **reproduction command** —
a number without its query is trivia. Evidence may also live in **PRs, CI,
mean-qa ledgers, monitors** — if so, record a short pointer (link/SHA) rather
than pasting novels into STATE.md.

Grades — one line each, this is the definition of record:

- **MEASURED** — I ran it here and read the output; the reproduce command is below.
- **CONFIRMED** — not measured by me, but two independent sources agree (code +
  dashboard, two operators, docs + observed behavior).
- **REPORTED** — one source said so and nothing checked it. Still useful, still
  unverified; say who reported it.
- **UNRESOLVED** — we tried and still do not know. Record the attempt so the
  next session does not pay for it twice.

Lineage: adapted from
intelligence-community analytic-confidence standards (ICD 203) and SRE
postmortem "verifiable data" norms — our adaptation, not an industry standard.

**Prefer executable evidence.** When the repo can carry the check, pin the
finding as a **regression test** and let the E-record point at it
(`path/to/test.go::TestName`) — a test fails when the finding stops being true;
prose does not. Prose is the fallback, not the default.

**Never overclaim.** Do not describe sources, scripts, or harnesses as if they
were here unless they are in-tree and runnable: link what exists, name what
does not. When the repo does not build and the finding needed a throwaway
harness, write the **recipe that actually worked** into the record (setup steps
+ commands, marked as a throwaway) — never emit commands that look compliant
and cannot run.

**Hygiene (hard rule):** aggregates, presence counts, type shapes, masked
patterns only. No production payload values, no customer identifiers, no PII.

<!-- Record skeleton:

### E-001 — <one-line finding>
- **Date:** YYYY-MM-DD · **Grade:** MEASURED · **Source:** <DB/Datadog/S3/code file:line / PR>
- **Pinned as test:** <path::TestName, or "no — repo cannot carry this check because …">
- **Reproduce:**
  ```
  <the exact query/command or PR check name — must run as written>
  ```
- **Result:** <masked/aggregate summary>
- **Caveats:** <scope limits, sampling, timing>
-->

_(no evidence yet)_
