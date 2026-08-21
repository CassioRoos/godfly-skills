# Environment — only when a real system is in play

Resolve each fact in order: **repo config → discovery → ask.** Never hardcode
what you can discover; never guess silently. A stale value does not fail loudly
— it tests the wrong thing and returns a confident green.

## What you must be able to name

Target (a named flow, a PR, the current diff, or a commit — and for anything but
a flow, **read the actual diff, not a summary**) · environment class (`prod`,
`staging`, `local`, or `unknown` → treat as prod) · base URL or API target ·
cluster, namespace, service, port, auth · database host, reachability, and schema
· credentials, as the engineer's own identity · for a browser, the logged-in user.

If a fact is neither configured nor discoverable, **ask one specific question**.
One good question beats a wrong assumption that tests the wrong environment.

## Finding the URL, rather than assuming it

**Never assume a port.** `localhost:3000` is one convention among many — Vite
serves 5173, plenty of stacks use 8080. Read it out of the repo: the `dev` and
`start` scripts in `package.json`, the README, `vite.config` / `next.config`, the
`.env`. Check the right branch is out before you start anything.

For a PR the code is usually already deployed to a preview, built from the PR
head — find it in the checks or a bot comment (`gh pr view <n> --json
statusCheckRollup`, or `--comments`) and confirm the deploy is for *this* PR's
latest commit rather than an earlier push. Staging is only the target when that
is where the change actually landed, and staging often lags the branch.

If nothing is running and it is a local server, start it in the background and
wait until it is ready before navigating. If you cannot work out how the app is
served, ask — a guessed URL tests nothing, or worse, tests something else
convincingly.

## Prove the running code is the code under test

This is the step everyone skips and it invalidates everything downstream.

- **A green deploy job means "artifact built", not "pods running the new code."**
  Controllers reconcile on their own cycle, minutes later. Testing the moment the
  job goes green tests the old pods and produces a perfect, worthless report.
  Wait for the running image or revision to change, then for pods to be ready on
  it.
- **A live dev server does not guarantee the new code rendered** — a cached
  bundle, the wrong branch, or hot-reload that did not apply all look identical.
  Confirm with a marker tied to the diff: a changed string, a new element, a
  version stamp.
- **Write the proof down.** "Build under test: `svc:v0.3.13-feat-x` (commit
  `2e195b2`), boot log reports `law_version 2026-08-v2`" is auditable. "Tested on
  staging" is not.

MeanQA verifies a build; it does not ship one. If the running build is not the
target, stop and say so.

## Unreachable? Diagnose before retrying

Private clusters and databases are usually VPN-gated, and the symptoms are
identical to a stale context — `no such host`, or timeouts. Do not thrash.

- The cloud control-plane API answers but the cluster endpoint does not → it is
  network-gated. **Stop and ask the user to connect**, then re-check.
- Both fail → credentials, not network. Fix auth.
- Both work but the named context fails → genuinely stale; refresh it from the
  provider.

Retrying a failing call without this triage burns ten minutes and learns nothing.

## Browser session

Test a representative authenticated session, not a cold anonymous one. After
navigating, confirm the expected user is logged in. If it is the wrong account or
logged out, **stop and ask** — re-authenticating silently can land you on the
wrong tenant and invalidate the whole run.

**Whether the session persists at all is server configuration, not something you
can fix mid-run.** The browser automation wants a persistent profile pinned to a
known logged-in user — for the Chrome DevTools MCP that means launching it with
`--user-data-dir <a dedicated dir>`, logging in there once, after which it
survives across runs. `--isolated` does the exact opposite, a throwaway profile
each time, so it must not be set; `--browser-url` is the alternative, attaching
to a Chrome that is already running. If the profile is not persistent or not
logged in, say so and point at the config — then re-run. Do not burn the run
trying to authenticate your way out of it.

## Clean up, including on failure

Port-forwards, probe pods, seeded rows meant to be temporary, viewport emulation,
pages you opened, and any dev server you started — if you leave one running, say
so and give the command to stop it, rather than leaving a port occupied and
nobody knowing why. A run that ends early is exactly when cleanup is forgotten
and the mess is worst.

## Persist what you learned

If you resolved the environment by discovery and asking because no config
existed, **offer to write it back into the repo** so the next run starts from
data instead of rediscovery. This is the difference between a skill that works
once and one that compounds.
