# Evidence Ladder

Every gate gets an evidence-strength rating alongside its verdict. The ladder makes
the difference between "the PR body contains a Datadog link" and "the Datadog link
actually shows the error rate dropping" visible in the gate report.

## The Four Rungs

| Rung | Meaning |
|---|---|
| `verified-live` | The skill confirmed it against the source system this run. |
| `documented` | The artifact links evidence, but it was not (or could not be) verified live. |
| `claimed` | Asserted in prose with no link or artifact attached. |
| `missing` | Not addressed at all. |

Wherever gates are reported these render in the canonical uppercase enum -- `VERIFIED_LIVE |
DOCUMENTED | CLAIMED | MISSING` -- and this cookbook's prose uses the same four
names in lowercase. Same four rungs, one vocabulary.

## Protected Gates

Protection is by REQUIREMENT, not by name. **Any gate whose passing condition
involves a link, an approval, a ticket, a verification, a measurement, or a
monitoring result can never pass on `claimed` or `missing`** -- in any rubric, under
any name, including gates the standard grows after this cookbook was written.

Across the current rubrics that requirement rule names: `production-evidence`,
`impact-analysis`, `deploy-verified`, `mitigation-vs-root-cause` (pr + postmortem),
`follow-up-if-not-fixed`, `monitoring-window` (pr), `monitoring-window-result`
(postmortem), `monitoring-result-recorded` (closure), `deployment-validation`
(postmortem), `post-deploy-validation` (closure), `repair-complete`,
`recurrence-check`, `tests-and-e2e`, `test-reaches-boundary`, `e2e-exception`,
`e2e-exists` (closure), `action-items` (postmortem), `action-items-filed` (closure),
`linear-tracking`, and every approval-bearing gate. A gate missing from that list is
not thereby unprotected -- apply the requirement rule and decide. There is no
"the rubric doesn't have that name" escape hatch.

Two get gamed with prose alone. `e2e-exception`: "our eng lead approved it" with no
linked artifact is `claimed` and FAILS -- "if exceptions become normal, the standard
is fake."

`recurrence-check` needs a sharper line, because over-failing it is the more common
error. A bare assertion -- "checked QBO, Xero, HaloPSA -- not present", no counts, no
signatures, no trail -- is `claimed` and cannot pass. But **per-service RESULTS are
`documented` and DO pass**: named services each carrying their own signature, count,
rate, or explicit negative finding is the check itself, reported. "svc-quickbooks:
`token refresh failed`, exactly 65/hour; svc-halopsa: `failed to pull customers`,
12/hour" is a completed cross-service check, not a claim about one. Do not demand a
grep trail from an artifact that already shows the per-service findings, and do not
downgrade it to `claimed` merely because you could not re-run it yourself -- that
confuses `documented` with `unverified`, which the UNKNOWN rule in SKILL.md forbids.
Grep the sibling repos when they are local to ADD evidence for the author, never as a
reason to flip a gate that verdicts the ARTIFACT.

Rung-to-verdict rule everywhere else: `documented` supports `pass` in coach mode
without mandatory re-verification. Gate mode MUST attempt `verified-live` for
every gate that is closure-critical for the decision target and whose tool is
available in-session -- an available tool left unused is a validator failure, not a
rung downgrade.

## Evidence Must Be Capable of Failing

A rung is not about how official the evidence looks. It is about whether the check
could have come back bad. `verified-live` requires BOTH: a failing outcome was
available (the result would look different if the fix did not work), and the
exercised path is confirmed to have RUN in the observed window -- the cron fired, the
retry path executed, the affected partner sent traffic.

A green signal that would look identical either way is `claimed`. The four that get
waved through: a generic CI pass, a health check or deploy success, an empty replay,
and "zero errors" from a query with no positive control proving that query shape
returns rows at all.

Resolution failures are two different things. **Attempted, did not resolve** (dead
link, 404, no access): the gate is `unknown`, never `pass`, on any protected gate;
record the attempt and the error. **Not attempted** (tool absent): `documented`,
which supports `pass` in coach mode only.

**Regression tests.** A pass at HEAD proves nothing alone -- it may have passed before
the fix too. `verified-live` on `tests-and-e2e` or `test-reaches-boundary` requires
the test body read, its business-outcome assertion identified, a pass at head, AND a
failure at base / reverted / with the offender mutated -- and that failure must be the
incident's failure mode, not setup breakage. Where controlled reproduction is
genuinely impossible, write down why and cap the rung at `documented`.

**Replay, backfill, repair.** "Replay completed, no errors" is what an empty replay
prints too. Require the expected affected set and how it was derived, attempted /
succeeded / failed / skipped counts, reconciliation against the expected set, and one
known positive-control record verified repaired.

## Climbing: What to Verify Where

Probe what is available in the session; use what responds.

**Filesystem/Grep (local repos)** -- free, no external call, ALWAYS use when repos
are locally available:
- Named tests exist and assert what the artifact says they assert.
- Recurrence check: grep sibling integrations/services for the same pattern.
- Claimed code locations (root-cause lines, offending functions) actually exist.

**GitHub (`gh` CLI)** -- cheap, high signal, always try:
- PR state, merge status, checks, review state (`gh pr view --json ...`).
- Diff paths against the claimed root-cause location (`gh pr diff`).
- Date the regression: when did the offending change merge? That dates the real
  incident window.
- Deploy verification: release tags, deploy workflow runs, image tags where
  reachable. Merged is not deployed -- do not let a merged PR satisfy
  `deploy-verified` on its own. Deployment identity is half the gate; the other half
  is evidence the affected path received traffic or work after the deploy.

**Linear (MCP)** -- cheap, high signal, always try:
- The investigation ticket exists and its state matches the artifact's claims.
- The ticket's priority/severity field matches the artifact's claimed severity --
  a mismatch is a classification dispute, surface it.
- Follow-up tickets for mitigated/partial fixes exist, with owner and due date.
- Action items exist under project `Incident Follow-ups`.
- Repeat-incident-class trigger: search Linear and `engineering/post-mortem/` for
  prior incidents of the same class (same pattern, queue, cron, provider). A hit
  fires the trigger.

**Datadog (MCP)** -- run when links are present or claims are quantitative. Load the
`datadog-mcp-gotchas` and `altpay-datadog-apm-spans` skills FIRST; the query dialect
and span attributes have traps that return confident emptiness:
- Re-run the artifact's linked log queries: do the counts match the claims?
- Before/after: query the exact error signature over the declared pre and post
  windows, and state the expected denominator next to the observed count.
- A zero-result query is `unknown`, not proof of absence, until a positive control
  shows that query shape returning data (widen the window, drop the fix-sensitive
  predicate, find the pre-fix occurrences).
- Monitors/dashboards named as detection improvements actually exist.

**Postgres read-only (MCP, pg-prod)** -- for data-impact claims:
- Row counts backing "N records affected" or "no data lost" claims.
- Verify repair/backfill completion claims.
- Read-only always. Any mutation is out of scope for a validator, full stop.

## Cost Discipline

Climb proportionally: grep and gh on every run; Linear on every run when available;
Datadog when the artifact makes quantitative claims or in gate mode; Postgres only
for data-integrity claims. Cite every live verification next to the gate it closes,
wherever those gates are being reported (query, command, or ticket ID) so the next
reader can re-run it. A verification with no matrix to live in still gets cited --
inline, on the gate it settles.

## Unknowns Must Name Their Price

Every `unknown` verdict and every `claimed`/`missing` rung comes with the fastest
evidence that would close it -- the Datadog query, the Linear search, the gh command,
the SQL. "Unknown" is acceptable; unknown without a path to known is not.

Exact only when derived from something you inspected this run. Never invent a table,
column, tag, monitor name, ticket ID, or URL to make the path look runnable: emit a
query specification with the placeholders marked and the missing prerequisites named
(see SKILL.md, "Never Fabricate").
