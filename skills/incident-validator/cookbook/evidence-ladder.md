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

## Protected Gates

`claimed` and `missing` can NEVER support a `pass` on these gates, wherever they
appear in the active rubric (skip names the rubric doesn't have):

`production-evidence`, `impact-analysis`, `deploy-verified`,
`monitoring-window-result`, `action-items`, `e2e-exception`, `recurrence-check`,
`follow-up-if-not-fixed`, `linear-tracking`, and every approval-bearing gate.

Two of these deserve emphasis, because they are the ones a rushed engineer games
with prose alone:

- `e2e-exception`: the six-part exception is only as real as its approval. "Our
  eng lead approved it" with no link is `claimed` and FAILS the gate. The approval
  must be a linked artifact -- Slack message, Linear comment, PR review. The
  standard's own words: "If exceptions become normal, the standard is fake."
- `recurrence-check` needs a sharper line, because over-failing it is the more common
  error. A bare assertion -- "checked every sibling integration -- not present", no
  counts, no signatures, no trail -- is `claimed` and cannot pass. But **per-service
  RESULTS are `documented` and DO pass**: named services each carrying their own
  signature, count, rate, or explicit negative finding is the check itself, reported.
  "billing-sync: `token refresh failed`, exactly 65/hour; crm-sync: `failed to pull
  customers`, 12/hour" is a completed cross-service check, not a claim about one. Do
  not demand a grep trail from an artifact that already shows the per-service findings,
  and do not downgrade it to `claimed` merely because you could not re-run it yourself
  -- that confuses `documented` with `unverified`, which the `unknown` rule in SKILL.md
  forbids. When sibling repos are locally available, grep them to ADD evidence -- but
  the gate verdicts the ARTIFACT: your finding is evidence for the author to
  incorporate, not a reason to flip the gate.

Rung-to-verdict rule everywhere else: `documented` supports `pass` in coach mode
without mandatory re-verification. Gate mode MUST attempt `verified-live` for
every closure-critical gate whose tool is available in-session -- an available
tool left unused is a validator failure, not a rung downgrade.

## Climbing: What to Verify Where

Probe what is available in the session; use what responds. A missing tool downgrades
the rung, it never blocks the run.

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
  `deploy-verified` on its own.

**Linear (MCP)** -- cheap, high signal, always try:
- The investigation ticket exists and its state matches the artifact's claims.
- The ticket's priority/severity field matches the artifact's claimed severity --
  a mismatch is a classification dispute, surface it.
- Follow-up tickets for mitigated/partial fixes exist, with owner and due date.
- Action items exist under the tracker's incident follow-ups project.
- Repeat-incident-class trigger: search the issue tracker and the postmortem archive for
  prior incidents of the same class (same pattern, queue, cron, provider). A hit
  fires the trigger.

**Datadog (MCP)** -- run when links are present or claims are quantitative:
- Re-run the artifact's linked log queries: do the counts match the claims?
- Before/after: does the error signature stop after the claimed fix deploy time?
- Monitors/dashboards named as detection improvements actually exist.

**Postgres read-only (MCP, pg-prod)** -- for data-impact claims:
- Row counts backing "N records affected" or "no data lost" claims.
- Verify repair/backfill completion claims.
- Read-only always. Any mutation is out of scope for a validator, full stop.

## Cost Discipline

Climb proportionally: grep and gh on every run; Linear on every run when available;
Datadog when the artifact makes quantitative claims or in gate mode; Postgres only
for data-integrity claims. Cite every live verification next to the gate it closes,
wherever those gates are being reported (query,
command, or ticket ID) so the next reader can re-run it.

## Unknowns Must Name Their Price

Every `unknown` verdict and every `claimed`/`missing` rung comes with the fastest
evidence that would close it -- the exact Datadog query, the Linear search, the gh
command, the SQL. "Unknown" is acceptable; unknown without a path to known is not.
