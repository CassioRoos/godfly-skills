---
name: ui-proof
description: Drive a real browser through a UI change and prove it works with captured evidence — screenshots, console output, and network activity — then publish that evidence (attached to the PR via `gh image`, or as a local markdown proof doc when there's no PR). Uses the Chrome DevTools MCP against a persistent, already-logged-in profile rather than a throwaway browser. Targets a flow the user names, a PR's changes, the current uncommitted changes, or a named commit. Use when asked to "test this flow in the browser", "prove the UI change works", "screenshot the PR", "verify the frontend", "capture UI evidence", or to run the understand → drive → capture → document loop for any front-end change.
---

# UI Proof

Prove a UI change works by driving a real browser through it and capturing evidence a reviewer can trust — screenshots, console messages, and network activity. This is operational verification of the front-end, not unit testing. Everything you claim must trace to something you observed in the browser — a rendered screen, a clean console, a 200 response — not memory or inference.

This skill is the front-end sibling of `pr-proof`. Same discipline, different boundary: pr-proof exercises a deployed service through a port-forwarded API; ui-proof exercises the UI through a real browser.

## Core principles

- **Evidence or it didn't happen.** Every claim maps to a captured artifact: a screenshot, a console dump, a network entry. A clean-looking screenshot over a console full of errors and a failed XHR is a lie with a nice render. Capture console + network, not just pixels — see [cookbook/evidence.md](./cookbook/evidence.md).
- **A screenshot proves it *rendered*, not that it *works*.** Prove the interaction (clicked X → got Y), the before/after delta the change intended, and that nothing broke underneath (console clean, network clean).
- **Drive what's actually under test.** A screenshot of the wrong build or the wrong branch silently proves nothing. Phase 0 resolves *what* you're testing and *which running URL* serves that code, and confirms the browser is pointed at it. See [cookbook/environment.md](./cookbook/environment.md).
- **Persistent profile, not a fresh browser.** This skill assumes the Chrome MCP drives a persistent, already-logged-in profile (configured at the MCP-server level, not here — see Phase 0). The skill's job is to *verify* the expected logged-in state before testing and stop/ask if it's wrong — never to silently test a logged-out or wrong-account session.
- **Discover, don't assume.** The dev URL, the changed surfaces, the auth state, and how the app is served all vary by repo. Find them (Phase 0/1). A guessed URL or stale build tests the wrong thing.
- **Ask before fixing.** Verifying and fixing are different mandates. Document the bug with evidence first; don't push a fix unless the user opted in (Phase 6).
- **Doc hygiene.** State the final content only — no revision markers, "NEW:", or changelog sections in PR descriptions or proof docs. Git and the PR timeline track history.

## Phase 0: Establish what you're testing and where it runs (do this first)

You cannot prove a UI change you can't point a browser at. Resolve, in this order of preference: (a) a per-repo convention the project documents, (b) discovery, (c) ask the user.

Resolve and write down:
- **Target** — exactly one of:
  - **A flow the user named** ("test checkout with a declined card") — no diff needed; the flow is the spec.
  - **A PR** — `gh pr view <n>` + `gh pr diff <n>`. The diff is the change surface.
  - **The current uncommitted changes** — `git status` + `git diff` (and staged: `git diff --cached`).
  - **A named commit / range** — `git show <sha>` / `git diff <range>`.
- **Running URL under test** — the URL serving the code under test, and proof it's *that* code:
  - local dev server (e.g. `npm run dev` on the checked-out branch) — most common for current changes / a commit;
  - a preview deploy (e.g. Vercel PR preview) — common for a PR;
  - staging.
  Confirm the branch/build actually running matches the target (right branch checked out, dev server up, preview URL is for this PR). If nothing is running, start it or ask — see [cookbook/environment.md](./cookbook/environment.md).
- **Browser / profile state** — confirm the Chrome MCP is driving the persistent profile and is logged in as the expected user. If logged out or wrong account, **stop and ask** — don't test a session that isn't representative. (If the MCP isn't configured for a persistent profile, that's a one-time MCP-config fix, documented in [cookbook/environment.md](./cookbook/environment.md) — it's not something this skill can change at runtime.)
- **Output destination** — PR present → attach evidence to the PR. No PR → local proof doc. (Decided by the Target above.)

If a fact can't be discovered and isn't configured, **ask** rather than guess.

## The phases

Complete each before the next; capture evidence as you go.

### Phase 1: Understand the change surface
From the Target (Phase 0), identify which UI surfaces changed and what "working" means for THIS change. For a PR/commit/current-changes: read the **actual diff**, not a summary — which components, routes, states, copy, validation, or styling moved. For a named flow: the flow itself is the spec. Decide the concrete screens and interactions whose screenshots prove the change, and note what you *can't* prove from the browser (e.g. a backend side effect — that's residual risk, or hand it to `pr-proof`).

### Phase 2: Get the code under test running and confirm the browser is on it
Make the running URL from Phase 0 actually serve the target code (start the dev server / check out the branch / open the preview URL). Navigate the persistent-profile browser there and confirm — version marker, a changed string from the diff, or visible new UI — that you're looking at the new code, not a cached or stale build. See [cookbook/environment.md](./cookbook/environment.md).

### Phase 3: Drive the flow and capture as you go
Exercise the change through the real browser. The reliable loop: **snapshot → act → wait → capture**. Take a `take_snapshot` to get element uids, `click`/`fill`/`fill_form`/`type_text` by uid, `wait_for` the expected text/state, then `take_screenshot`. Cover the **happy path AND adversarial cases**: validation errors, empty states, loading states, error/failure states, the not-found/forbidden case. Capture `list_console_messages` and `list_network_requests` across the run, not just at the end. See [cookbook/driving.md](./cookbook/driving.md) and [cookbook/evidence.md](./cookbook/evidence.md).

### Phase 4: Verify — don't just photograph
A pile of screenshots is not a verdict. For each captured screen, confirm: the rendered state matches the intended change (before/after where it helps); the **console is clean** (no errors/warnings the change introduced); the **network is clean** (no failed requests, no unexpected 4xx/5xx behind a happy-looking screen). Cross-check what the screenshot *claims* against the console/network truth. A discrepancy is a finding, not a footnote.

### Phase 5: Publish the evidence
Assemble the evidence into the right destination — see [cookbook/publish.md](./cookbook/publish.md). **Always present the evidence as a table** — one row per case (happy path, each empty/loading/validation/error state, before/after), with a Result (✅/❌) column and an Evidence column holding the inline image ref. Never dump screenshots as a loose list of images; the table is the verdict, and each row ties a claim to its artifact. Follow the table with the console status, network status, and residual risk.
- **PR present** → upload screenshots with `gh image <path>...` (prints markdown image refs), and write a **UI verification** section (the table + console/network/residual-risk) into the PR description. State the final content only.
- **No PR** → save screenshots **and** the doc in a per-run directory inside `.proof/`: `.proof/<YYYY-MM-DD>-<HHMM>-<short-target-slug>/`, with `PROOF.md` inside it and the images beside it as relative refs. Never write files into `.proof/` itself.

**Then hand the browser back.** Clear any viewport emulation with `emulate {viewport: ""}`. The override is sticky — left in place it pins the user's own window to your screenshot width and they cannot resize it. Do this even if the run ended early or failed. See [cookbook/driving.md](./cookbook/driving.md#viewport).

### Phase 6: Fix bugs and repeat — ONLY IF OPTED IN
If verification surfaces a UI bug:
1. **Ask first.** "Found <bug> (here's the evidence). Fix it, or just document it?" Don't push a fix unless the user said to (now, or as a standing instruction).
2. If fixing: scope to the broken surface, follow the repo's conventions, reload/rebuild.
3. Re-drive the affected flow (Phases 2–4) and refresh the evidence. Loop until clean.
4. Refresh the PR description / proof doc to the final state.

## Red flags — stop and correct
- Calling a flow "working" off a screenshot while the console shows errors or a request 500'd — verify the layers beneath the pixels.
- Testing a logged-out or wrong-account session because you didn't confirm the profile state in Phase 0.
- Screenshotting a stale/cached build or the wrong branch — confirm the running code is the target code (Phase 2).
- Only capturing the happy path — empty/error/loading/validation states are where UI regressions live.
- Guessing the dev URL or how the app is served instead of discovering/confirming it.
- Pushing a UI fix the user didn't ask for.
- `gh image` failing with an auth error — it needs a **browser session token**, not your `gh` PAT (see [cookbook/publish.md](./cookbook/publish.md)).
- Leaving a dev server you started running with no note, or burying residual risk to look cleaner.
- Finishing with the viewport still emulated, so the user's browser stays pinned to your screenshot size — clear it with `emulate {viewport: ""}`.

## Cookbook
- [cookbook/environment.md](./cookbook/environment.md) — resolving the target, the running URL, and the persistent-profile / login state (incl. the one-time MCP config).
- [cookbook/driving.md](./cookbook/driving.md) — driving the Chrome MCP reliably: snapshot-first, acting by uid, waiting, isolated contexts.
- [cookbook/evidence.md](./cookbook/evidence.md) — what counts as evidence: screenshots + console + network, before/after, capture discipline.
- [cookbook/publish.md](./cookbook/publish.md) — attaching evidence to a PR with `gh image`, or writing the local markdown proof doc.
