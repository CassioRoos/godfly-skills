# Incident fix boundary checks

Use with Morpheus when the artifact claims an incident fix. Pin current PR head,
base, checks and reviews. If unavailable, label remote state unverified.

- Trace symptom to the actual offending query/function/queue/state machine.
- Compare the changed code with that offender; list surviving entry, retry,
  admin, shadow and integration-specific paths that still reach it.
- Trace production sources of guard/dedup state, including external writers,
  imports and initialization. A test fixture that seeds state proves only the
  fixture setup; it does not prove a production writer is missing. A negative
  claim needs a scoped writer/caller/config search and its remaining limits.
- Check registered caller classes and shared publisher/worker blast radius.
- Demand a regression at the relevant durable/runtime boundary that changes
  outcome if the fix is absent. Helper-only tests may leave end-to-end gaps.
- Label fix, mitigation, containment or partial honestly; separate runtime
  parity and rollout evidence from local test results.
- Check that operators can see the decisive branch and correlate its effect.

Report claim, evidence and yes/no/partial/unknown for relevant gates. Unknown
needs the fastest clearing proof, not a fabricated finding. Do not create a
verdict ledger or publish a PR comment unless the task authorizes it.
