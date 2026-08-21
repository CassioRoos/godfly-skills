# Evidence — only when you are actually executing

If nothing will run against a real system, you should not be reading this file.

## Every claim maps to a captured artifact

| Claim | What proves it |
|---|---|
| An endpoint behaves | the request as issued, the literal response body, the status, the duration — per case, happy and adversarial |
| A durable side effect happened | **the direct read** — the query and its literal output. The API's echo of what it stored is not evidence that it stored it |
| Something did *not* happen | the query that came back empty, with its time window. An absence with no artifact is an assertion |
| Idempotency | the second run producing no new effect, shown in rows or logs |
| A trigger did its job | the worker's own log trail — receipt → decision → durable write → ack — with correlation ids |
| A UI state | before and after screenshots, plus console and network for that interaction |
| Performance or access path | the plan, measured where the data volume is real |
| An event was emitted | the publish line, **and an explicit note that emit ≠ delivered** unless you followed it to a bound consumer |

## Attach requests and responses verbatim

The literal call — copy-pasteable, secrets redacted — the literal body, the
status, and the wall-clock duration. Not a paraphrase, not a "sanitised shape".
A summary table alone is not evidence a reviewer can re-check.

```bash
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' "<url>"
```

**Every executed case gets its own block. All of them.** Eleven cases means
eleven requests and eleven responses in the document — not a table saying they
passed, and not three representative examples. The payloads are the deliverable's
whole value to a reviewer, and the reason to collapse them behind `<details>` is
scannability, never economy. Volume of *evidence* is a virtue; volume of *prose
about testing* is not.

**Trim inside a body honestly, never silently.** A long array becomes the first
few elements, an explicit `... (N more)` marker, and the last one — so the reader
sees the shape, the boundaries, and exactly what was elided. Never drop a case's
payload entirely to save room.

## Inline is for reading; files are for re-running — write both

The `<details>` block in the report makes a case *reviewable*: a human reads it
and can re-run it by hand. That is necessary and not sufficient. When there is a
run directory, **also write each executed case's raw evidence to
`cases/<case-id>/` as files** — so the run is browseable one-file-per-test and
the artifacts can be replayed by a machine, not just re-typed by a person.

Per executed case, minimum on disk:

```
cases/TC-01/
  request.sh          the exact call, copy-pasteable and runnable as-is
  response.json       the literal body (or response.txt for non-JSON), with the status line
  db-read.txt         the direct read that verifies persistence — query + literal output
  notes.md            one line: what it proves, and the reproduced count
```

For UI cases the images themselves live at the run-directory root, numbered in
capture order, and this directory's `notes.md` names which of them belong to the
case — one flat image sequence beats copies scattered per case. The console and
network capture for the interaction goes here. A case that genuinely retained
nothing writes `notes.md` saying why, and its status is `unproven` — an empty
directory never implies a green.

The rule that makes this worth the keystrokes: **a reviewer should be able to run
`cases/TC-01/request.sh` and get the recorded response, without you in the room.**
Inline evidence proves you ran it; the file lets them run it. The report links
each row to its `cases/<id>/` directory.

An executed run has a run directory — you derive it from the app or service
under test and you do not ask permission for it. The only case with nowhere to
write is one where writing was actually refused, and then you say so plainly,
name the path that was refused, and keep the inline `<details>` as the whole of
it: reviewable, not replayable, and explicitly labelled as such. "It felt like a
quick check" is not that case.

**Sanitisation is scoped.** Credentials, tokens, cookies, private URLs and
personal data never get written, anywhere. But a seeded fixture's payload on a
local or staging box is exactly what convinces a reviewer — reducing it to a
"shape" throws away the point. Prefer synthetic fixtures so artifacts are safe
to keep. Redact on the way in, never afterwards.

## Drive the browser through the DevTools MCP

When a UI is in scope, prefer the Chrome DevTools MCP over hand-rolled
automation. It is the safer and more controllable path: every step is a discrete
call you decide on one at a time, and the same attached session gives you the
accessibility snapshot, clicks and form fills, `filePath` screenshots, console
messages, network requests, `evaluate_script` for computed state, a pinned
viewport and an explicit wait — exactly the set a UI case needs in order to be
evidenced. A throwaway Playwright or Puppeteer script buys you nothing here and
costs you the per-step control; and `curl` against the page's endpoints is not a
UI test at all, because nothing renders and so nothing the browser would have
shown you can be seen.

Reach for something else only where the MCP genuinely cannot go — a second
concurrent browser, a browser it is not attached to, load generation — and say in
the report which tool produced which evidence.

## Screenshots are files, or they never happened

A browser-automation screenshot returns the image **into the conversation**
unless you pass an explicit output path — in the Chrome DevTools MCP, `filePath`
on `take_screenshot`, documented as saving "instead of attaching it to the
response". The default therefore produces no artifact at all. Pass the path,
every time.

**Probe a writable path before you drive anything.** Screenshot writes are
enforced against the automation server's own workspace root, which is not your
working directory and is frequently narrower than it — a path outside that root
is refused with an access-denied error naming "workspace roots". Take one
throwaway capture into your intended run directory before the first real step.
If it is refused, find a permitted directory, capture there, and move each file
into the run directory as you go. Discovering this at the end of a run is how
pre-change states are lost for good.

**A refused write is never a reason to drop back to inline-only.** That fallback
is silent: the image still appears in the conversation, so the run feels
evidenced while the disk stays empty — and the document ends up naming files
that do not exist. If you find you have been in that state, restore the
pre-change build, re-seed, and re-capture the earlier states before you finish.
Reconstructing a screen from memory is fabrication; re-running the old build to
photograph it again is not.

**Never name an image you have not listed.** Before finishing, list the run
directory and confirm every file the document references is present at a
plausible size. A document citing screenshots that are not on disk is the worst
artifact described in this file — it reads as proof, so nobody checks it.

Two more closing checks, in the same pass, because both are invisible until
someone else trips over them: **clear any viewport or device emulation you set**
— it is sticky and it pins the next person's own window, including yours — and
**close the pages you opened**, so a later run does not inherit your tabs. Do
both even when the run failed early.

## The DOM is not the screen

Reading an element's text, or its `hidden` property, proves the element exists —
not that a human can see it. A toast underneath a modal overlay, a control behind
a sticky header, text the colour of its own background, a value clipped out of
its box: every one of those passes a DOM assertion and fails the user. When the
claim is "the user is shown X", the proof is a rendered capture, and for anything
that can overlap, the computed stacking as well. A confirmation you read out of
`document` verifies the string, not the interface.

## A screenshot proves it rendered, not that it works

A clean-looking screen over a console full of errors and a failed request is a
lie with a nice render.

- Pull **console and network after each meaningful step**, not once at the end —
  a transient error is invisible after the next navigation.
- A clean screen with a dirty console is a **finding**, not a footnote.
- Drive the states that hide regressions: empty, loading, validation error,
  failure/forbidden, success. Regressions cluster in the non-happy states.
- **A modal, drawer, sheet or popover is its own surface with its own five
  states — drive them with the overlay open.** Satisfying "validation error"
  against the API, or against the page underneath, does not reach the overlay's
  own error path. Feed each overlay the input its *client-side* check rejects,
  not just the input the server rejects: a value that passes the client and
  fails the server exercises a completely different branch, and the branch you
  skipped is the one only a user ever sees.
- **A transient notification firing over an overlay is where stacking bugs
  live.** Toasts, snackbars and inline alerts are authored against the page and
  then shown on top of a dialog that outranks them, so the message exists,
  reads correctly in the DOM, and is painted underneath. Whenever a notification
  can appear while something is overlaid, check what is actually on top —
  `document.elementFromPoint` at the notification's own centre, or the computed
  stacking of both — and capture it. If the answer is not the notification, the
  user was told nothing.
- **Before/after is the strongest UI evidence.** One "after" shot is weak — a
  reviewer cannot see what moved. Pair them around every fix you make, which
  means capturing the broken state *before* you repair it.
- **Capture every surface you drove, not only the broken ones.** One shot per
  distinct screen and per state that hides regressions, passes included. The
  screens that worked are what turns "we tested this" into something a reader can
  check, and they cost one call each.
- Snapshot → act → **wait for the expected state** → capture. A screenshot taken
  mid-transition is evidence of nothing. Element handles go stale after any DOM
  change; re-snapshot.
- Pin the viewport for reproducibility, and **clear the emulation when you
  finish** — it is sticky, and leaving it pins the user's own window. Do this
  even when the run fails early.

## Databases

Find the schema first — apps frequently use a named schema, not `public`, and
sibling services reuse table names. A private host (RFC1918) is not reachable
from a laptop; run a client inside the cluster, using a long-lived pod and
`exec` rather than a `--rm -i` one-shot, which races teardown and loses output.

**Production is read-only, bounded, and confirmed in advance.**
`default_transaction_read_only = on`, a statement timeout, SELECT only, and **no
unbounded full-table scans** — reach heavy rows through selective indexed access
off a small dimension table instead.

Confirm a migration **applied** rather than assuming it ran at startup; check the
version advanced, is not dirty, and that any index is valid and ready.

## The staging trap

**Any performance, access-path, or index claim validated only on staging is
wrong until proven otherwise.** Staging tables are tiny, so the planner picks
cheaper plans than production. A query that index-scans over 500 rows can pick a
catastrophic plan over a million.

Plan the exact shape the code runs, with the parameters it actually binds — a
predicate like `($3 = '' OR col = $3)` collapses to `TRUE` when you hardcode
`''`, and you profile a query production never runs. Report timings with their
conditions attached: "1.4s at staging scale, single user, warm" is evidence;
"1.4s" implies a claim you did not make.

## Classification

Three states, honestly applied: **passed** (observed, with the artifact),
**failed** (observed, with the artifact), **unproven** (the layer was required
and unavailable, or nothing was retained). A case marked passed with no retained
artifact is unproven — say so rather than letting an empty directory imply green.

A flake is not a verdict: retry once, then classify honestly.
