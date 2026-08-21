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

## Clean up, including on failure

Port-forwards, probe pods, seeded rows meant to be temporary, viewport emulation.
A run that ends early is exactly when cleanup is forgotten and the mess is worst.

## Persist what you learned

If you resolved the environment by discovery and asking because no config
existed, **offer to write it back into the repo** so the next run starts from
data instead of rediscovery. This is the difference between a skill that works
once and one that compounds.
