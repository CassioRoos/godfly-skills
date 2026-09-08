# Evidence capture

Create/read back the initial proof under SKILL.md before any probes. Persist
sanitized evidence as it is produced; collect enough to support the claim, not
unbounded traffic unrelated to the case. Never retain secrets or personal data.

## Case-to-artifact contract

Every executed case has a stable ID and a report block linking to its files:

```text
cases/TC-01/
  request.sh or steps.md     exact sanitized command or browser steps
  response.json or stdout.txt
  stderr.txt                when applicable, including failed commands
  db-read.txt               when persistence is part of the claim and access is available
  console.txt / network.txt when supported for a UI interaction
  notes.md                  expected/observed, status, timing, exit code, build, gaps
```

Only create applicable files; never fill empty placeholders to simulate coverage.
Include passing and failed cases. A blocked case records the prerequisite and
coverage not reached. A row without retained proof is unproven, not passed.

Capture complete relevant sanitized requests/responses and output on disk;
the report carries decisive excerpts, observations and links, not duplicate
copies of every large body. Explicitly label redaction and any collection
limit/truncation. Replay scripts reference user-provided auth safely; they must
not embed secrets, auto-load arbitrary environments or auto-repeat a dangerous
mutation. Replay always remains subject to current authorization.

| Claim | Required evidence |
|---|---|
| Endpoint behavior | Actual request, response, status and wall-clock duration |
| Persistence | Direct durable-state query and result, not only the API echo |
| Absence of effect | Bounded query with filters and time window; note retention/sampling limits |
| Idempotency | Repeated request plus durable count/effect, including ambiguous outcomes |
| Worker completion | Correlated receipt → decision → write → ack; publishing alone is not delivery |
| UI behavior | Browser-driven steps, rendered before/after states and available console/network |
| Performance | Actual query/parameters, volume/load, build and environment; staging is not production-scale proof |

## Browser provider: discover, do not assume

Use the user's named browser and the currently exposed browser tools. In a CUA
session, follow the required first-call entry point and read the returned API
documentation. Only call methods actually documented there. If Chrome DevTools
MCP is genuinely installed, its own documented API is an alternative, not a
prerequisite. Never invent `take_screenshot`, `resize_page`, isolated-context
options or console/network methods on a different provider.

Before driving the flow, establish which channels can be captured and persisted:
rendered screenshots, accessibility/DOM state, console, network, viewport,
isolated identities. Record unsupported channels as unavailable. A screenshot
does not establish a clean console; an API call does not establish rendered UI.

Test one screenshot save/export to the proof directory using supported APIs,
and verify the resulting file is readable. If a provider returns only an inline
image, use its documented export/save mechanism; if unavailable, declare the
persistence gap and retain supported evidence. Do not invent an image path or
claim a transcript-only image is on disk. Route a refused write only to a
permitted persistent location, then verify the copy.

Never bypass provider restrictions with hidden browser state, cookie extraction,
undocumented APIs or ad-hoc automation. Do not edit browser configuration or
switch profiles/accounts without authorization.

## UI evidence that matters

- Observe current state → act → wait for expected state → capture. Use fresh
  locators after state changes; don't count a transition frame as final proof.
- Capture before/after for changes and every distinct tested state: empty,
  loading, validation error, forbidden/failure, success. Include healthy screens.
- Console/network errors must be correlated with the step and investigated;
  unrelated historical errors are not automatically product defects.
- The DOM is not the screen. Check visible rendering for clipping, overlap,
  toast-behind-modal, text contrast and reachable buttons.
- For responsive changes, test the named widths and verify the actual viewport
  through supported inspection. Capture overlays with action buttons in frame.
  If viewport controls are unavailable, do not label desktop shots "mobile".
- Test logged-out/other-identity states only through a supported, authorized
  isolated context. Never destroy the user's session by logging out.
- Collect console/network after meaningful steps when supported; note any
  redaction, sampling or missing channel.
- Keep screenshots numbered at the run root and embed them in PROOF.md beside
  the case that uses them. Validate every linked file exists and is readable.
- Restore only settings you changed and close only tabs/resources you created.
  If the provider cannot restore something, disclose the residual state.

## Data and environment

Discover schema/host/build first. Do not assume public schema, a reachable
private host or that a migration ran. Do not automatically create cluster pods
or run remote commands just because a database is unreachable.

Production reads remain bounded, selective and authorized under applicable
rules; use read-only transactions and timeouts where supported. Avoid unbounded
scans. Record actual query parameters and data volume for performance claims;
staging-only measurements do not establish production behavior.

## Completeness check

For every case, reconcile result → report block → existing artifacts.
Preserve the full captured files even when only excerpts enter context.
Record capture start/end times and bounds; never infer absent events from
incomplete logs. Interrupted/failed runs retain their proof and honest verdict.
A refused capture is a gap to disclose, never permission to manufacture proof.
