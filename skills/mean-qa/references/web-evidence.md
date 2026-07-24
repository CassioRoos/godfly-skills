# Web Evidence

Use web/browser validation for user-facing behavior. Prefer the repo's existing e2e harness when the runbook already encodes the flow or when creating a regression; otherwise use the available browser tooling for exploration and artifact capture.

## Required Capture

Before the first meaningful action, capture:

- UTC or local time window with timezone,
- target URL and environment,
- authenticated user/role label without secrets,
- network listener for GraphQL/REST/gRPC-web calls where possible,
- console/error listener,
- screenshot or DOM snapshot for starting state when visual state matters.

For each flow, capture:

- visible expected end state,
- operation names and HTTP statuses,
- sanitized request inputs and response outputs for decisive GraphQL/REST/gRPC-web operations,
- response error bodies or sanitized error shape,
- request/correlation IDs,
- console errors during the flow,
- before and after screenshots for every mutation or screen-checked visual state,
- focused crop or DOM excerpt only as an addition to the full-page/state screenshot, never as the only proof when layout matters,
- screenshot or trace on failure.

## Screenshot Discipline

For screen-checked flows, produce named screenshots that make the claim reviewable without rerunning the browser:

- `<flow-id>/before.png` or equivalent starting state,
- `<flow-id>/after.png` or equivalent expected end state,
- `<flow-id>/failure.png` when assertion fails,
- `<flow-id>/hardening-<case>.png` for relevant edge cases,
- viewport/device label when responsive behavior matters,
- short notes explaining what the screenshot proves and what it does not prove.

If the page changes because of a mutation, capture before click, immediately after visible completion, and after reload/refetch when persistence is part of the claim.

Do not use cropped screenshots to hide missing context. That is how QA evidence becomes marketing material with a timestamp.

## Pass Conditions

Web evidence can prove only the user/caller layer and network boundary. It never proves persistence, routing ownership, event delivery, or downstream handling. Web evidence alone can constitute a full pass only when the repo explicitly defines those layers as out of scope for the tested claim.

UI green with no network evidence is a finding, not a pass.

Endpoint success without visible product-state proof is only endpoint evidence. It is not a user-flow pass unless the tested behavior is explicitly API-only.

## Hardening Probes

After the scripted path:

- empty required fields,
- invalid type or malformed value,
- max length and unicode,
- double submit,
- back-button or refresh resubmit,
- stale-tab repeat after mutation,
- pagination/filter/sort edges,
- permission-negative checks.

Record hardening separately from the scripted pass/fail unless repo rules say otherwise.

Hardening probes follow the same PROD boundary as any other mutation. A read-only PROD evidence envelope does not cover them.

## Safety

Do not submit forms that create external side effects unless the target is proven safe/fake and the user/repo has authorized that class of action.

Never store cookies, tokens, OTPs, passwords, session storage dumps, or private URLs in artifacts.
