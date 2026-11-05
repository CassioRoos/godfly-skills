# Capture — pin the build, run the case, keep the proof

## 1. Pin the target and the build

Resolve each fact in this order: repo config, then discovery, then one specific question. A guessed value tests the wrong thing and returns a confident green.

1. **Target.** A PR, a commit, the current diff, or a flow the user named. For anything but a flow, read the actual diff.
2. **Head SHA.** Every case is pinned to it. A push after the run makes the report stale: re-run, or mark the report `stale — ran on <old sha>`.
3. **Environment class.** `local`, `preview`, `staging`, `production`, or `unknown` (treated as production).
4. **URL.** Read it from the repo: dev scripts, framework config, `.env`, README. Never assume a port. For a PR, find the preview deploy in the checks or bot comments.
5. **Prove the running build is the head SHA.**
   - A preview: compare the deploy's commit or build id with the head SHA.
   - A cluster: a green deploy job means "image built", not "pods running it". Wait for the running revision to change and the pods to be ready.
   - A local dev server: confirm a marker from the diff (a changed string, a new element, a version stamp). A cached bundle looks identical to new code.
6. **Write the build line** into PROOF.md: `Build under test: api:v0.3.13 (commit 2e195b2), boot log "config v2"`. "Tested on staging" is not a build line.

If the running build is not the head SHA, stop and say so.

## 2. Check the harness before the first case

1. **The port is yours.** Before a port-forward, check nothing else listens there (`lsof -iTCP:<port> -sTCP:LISTEN`). After it starts, confirm it bound.
2. **The identity is right.** In the browser, confirm the logged-in user. Wrong account or logged out: stop and ask.
3. **Files can be written.** Save one throwaway screenshot and one response into the run directory, then list them. A refused path is found now, not after twenty captures.
4. **CI on the head SHA ran what it claims.** Read the step logs, not only the check status. A step that prints "no files matched" or "skipped" passed without testing.

Unreachable host? Triage before retrying. Control plane answers but the cluster does not: network gate, ask the user to connect. Both fail: credentials. Both answer but the named context fails: stale context, refresh it.

## 3. The case folder

Every executed case gets one folder. Only create files that apply.

```text
cases/TC-04/
  request.sh      exact sanitized command, runnable as-is with auth from env vars ($TOKEN)
  steps.md        browser steps, instead of request.sh, for a UI case
  response.txt    literal response body, then status line and wall-clock time
  db.txt          direct read: the query and its literal output
  console.txt     browser console for this case
  network.txt     browser requests for this case, with statuses
  notes.md        expected, observed, result word, head SHA, UTC time, screenshot names
```

Screenshots live at the run-directory root, numbered in capture order (`03-approve-dialog-390.png`). `notes.md` names the screenshots that belong to the case.

`request.sh` never contains a secret. It reads auth from an environment variable the reviewer sets. It never repeats a harmful mutation by itself.

## 4. What proves what

| Claim | Evidence to capture |
|---|---|
| An endpoint behaves | The exact request, the literal response body, the status, the wall-clock time. Happy and adversarial cases alike. |
| A handler behaves, with no service running | An in-process probe: the probe source, the command that ran it, and its literal output. |
| A gRPC method behaves | The `grpcurl` call with its JSON payload, the literal reply, the status code and the time. |
| A durable effect happened | The direct read of the store: query and literal output. The API echo is not proof. |
| Something did not happen | The bounded query that came back empty, with its filter and time window. |
| Idempotency | The repeated request, plus a count showing one effect. |
| A worker or consumer did its job | Its own log lines, receipt → decision → write → ack, with correlation ids and UTC timestamps. A publish alone is not delivery. |
| A UI state | Screenshots before and after, plus console and network for that step. |
| A layout change | Before and after at every width the change targets, at least one phone width and one desktop width, with the width in the filename. |
| Unit, integration, lint, build | The command, the pass count, the exit code, and the CI run link for the head SHA. |
| A negative case | The planted bad input and the exact refusal message. |
| A bug fix | Fail-to-pass: the same case on the old code (defect reproduced) and on the head SHA (refused). |
| Old versus new | One table with both results per case. |
| A staging run | Raw script output, pod log lines with timestamps, and the cleanup done. |
| Performance | The real query with its real parameters, the data volume, the build. Staging volume is not production proof. |

**Save the whole output before you read it.** Run every command into its case file first: `go test ./pkg/... 2>&1 | tee cases/TC-08/response.txt`. Never pipe through `tail`, `head` or `grep` before saving; a failure cut off that way is lost, and a flaky first run cannot be reproduced. The evidence block may show a filtered excerpt above the `<details>`, but the `<details>` holds the full file.

Curl with timing:

```bash
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -H "Authorization: Bearer $TOKEN" "$BASE/expenses/exp-7f21"
```

**No running service is not a reason to skip a case.** When the code can run in-process, drive it there: an HTTP handler through the language's test server (`httptest` in Go, `supertest` in Node, the framework's test client in Python), a service function through its fakes. Do this before you mark a case `➖ not run`.

1. Write the probe as a temporary test file next to the code.
2. Run only that test, and capture the command and the literal output.
3. Copy the probe source to `cases/<id>/probe.<ext>`.
4. Delete the probe from the source tree, and confirm `git status` is clean.

Mark a case `➖ not run` only when it needs something an in-process run cannot give: real network, a deployed image, another service, production-scale data.

**Databases.** Find the schema first; apps often use a named schema, and sibling services reuse table names. Production reads use a read-only transaction, a statement timeout and selective indexed access. Never run an unbounded scan.

**False starts are evidence too.** A case that ran against the wrong build, port or identity stays in the report, labelled, with its cause.

## 5. Drive the browser

1. **Pick a provider that saves files.** Use the browser the user named, else one whose screenshot call writes to a path (for example the Chrome DevTools MCP `take_screenshot` with `filePath`). A provider that only returns images into the conversation leaves no artifact. If no provider can save, record the gap.
2. **Hosts that block headless browsers** (a WAF in front of production) need a real, headed browser session.
3. **Loop:** observe the page → act → wait for the expected state → capture. A capture mid-transition proves nothing. Re-read element handles after every DOM change.
4. **Drive every state that hides regressions:** empty, loading, validation error, forbidden or failure, success. Capture the healthy screens too; they prove what was covered.
5. **Overlays are their own surface.** Open each modal, drawer and sheet, and drive its own error path with input the client-side check rejects.
6. **The DOM is not the screen.** A toast under a modal reads correctly in the DOM and is invisible. When a message can appear over an overlay, check what is on top (`document.elementFromPoint` at the message centre) and capture it.
7. **Widths.** Pin each width the change targets. Read `window.innerWidth` to confirm it applied. At every narrow width, open each dialog and capture it with its buttons in frame; a dialog wider than the phone hides its own Confirm.
8. **Console and network after each meaningful step,** not once at the end. A clean screen over a failed request is a finding.
9. **Other identities and logged-out states** run in an isolated browser context. Never log the user out.
10. **Hand the browser back.** Clear viewport emulation, close the tabs you opened, restore any flag you changed. Do it even when the run failed.

## 6. Regression gates

Run the project's own gates on the head SHA: typecheck, lint, unit tests, build, and the tests of the modules that import the changed code. When the host supports subagents, give this to a cheaper-model agent in a separate checkout at the head SHA, never in the working tree another agent edits. Record each gate as a case: command, pass count, exit code, and the log excerpt of any failure. Name pre-existing failures as pre-existing, with the main-branch run that shows them.

## 7. After the merge

When the user's process tests after merge (a deploy, a flag flip), add an `After merge` section pinned to the merge SHA and the deployed version. Re-run the must-run cases there, and watch what the merge triggered (deploy, sync, migrations) until it settles.

## 8. Parallel agents

Split cases across agents by ID range, each with its own `cases/` folders. Brief each agent with the safety rules and the one secret key it may read. Merge their rows into one PROOF.md in ID order.
