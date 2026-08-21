# Attack Design

The job is not to confirm the feature works. It is to find the input, ordering,
or failure that makes it lose money, corrupt state, harm someone, or lie.

## 1. Derive the harm model — do not reach for a checklist

Checklists encode someone else's domain and go stale. Six questions produce the
right one for any domain:

1. **What is the unit of harm here?** Money moved wrongly. A wrong dose. A
   sealed record disclosed. A shipment that cannot be recalled. Name it in a
   sentence.
2. **What must never happen, no matter what?** The ones worth writing down are
   where a single occurrence is an incident, not a degradation.
3. **What is irreversible?** No recovery path means the harshest testing.
4. **Who must never see this, and who must always be able to?** Both directions
   are harm. Wrongful disclosure and wrongful denial are each real, and the
   second is the one campaigns forget.
5. **What deadline or timing carries consequence?** Time-derived harm is
   invisible until the boundary, then total.
6. **What must be reconstructable afterwards?** If someone must defend this
   decision in an audit or an investigation, what record must exist?

If the domain is unfamiliar, ask the user what a bad day looks like for the
people this system serves, and test that.

**In regulated domains the correct behaviour is often defined outside the
codebase** — a statute, a standard, a protocol. Neither the spec nor the code is
the oracle there. Name the rule and ask; never infer a regulatory requirement
from general knowledge and report it as fact.

## 2. The dependency question — work this first

For every external thing the operation consults — service, cache, lookup table,
dictionary, feature flag, config — ask what the code **receives** when it is
unavailable, degraded, or simply does not know, and then what the code **does**
with that value.

The dangerous shape is a call with **no error return**. It cannot fail, so it
returns a zero value instead. Check which way that falls:

- A classifier returning `""` matches nothing — a check looking for a match
  finds none and **lets everything through**. The gate is now a no-op for every
  request at once, silently, with no error and no metric.
- A predicate returning `false` skips the branch it guards — a special
  calculation is bypassed and raw input is used as if it were computed. Intent
  reinterpreted, not rejected.
- An empty list reads as "nothing to worry about" rather than "I could not look."

Test it by making the dependency unavailable or ignorant and asserting the
operation **refuses** rather than proceeds.

This class is systematically under-tested: testers exercise a dependency
returning *wrong* data far more readily than one returning *nothing*, because
the first is a bug you can imagine and the second looks like it cannot happen.

## 3. The axes

| Axis | The question | Classic yield |
|---|---|---|
| **Concurrency** | Two at once? | Check-then-act races, lost updates, spend past a ceiling |
| **Duplication** | Same request twice? | Missing idempotency, retry-after-timeout, replayed event |
| **Partial failure** | Every external call has three outcomes — success, failure, **unknown**. Dies between N and N+1? | Value moved with no record, event published before commit, orphans |
| **Boundary** | Zero, negative, empty, max, one-past, exactly-at? | Off-by-one, sign errors, inclusive/exclusive confusion |
| **Identity** | Caller is someone else, or nobody? | Missing ownership check, "internal" endpoint, cross-tenant read |
| **Time** | Clock moves, differs, or the boundary is exact? | Timezone/DST, expiry windows, skew between services |

## 4. Find the cut corner

Read the implementation hunting the shortcut taken at 6pm: a read followed by a
conditional write with no transaction between them; an error path returning
early leaving earlier writes behind; validation covering only the fields the
happy path uses; a publish before the commit it describes; a status field that
exists and is never read; a filter excluding one state and silently including
the rest.

Each tell is a scenario. Write the one that makes the shortcut visible.

## 4a. The cheap probes, in full

The axes above find defects that require thought. This list finds the ones that
require only a request — and a campaign hunting the first kind reliably walks
past the second. Run all of it against every input-accepting surface.

| Probe | What it catches |
|---|---|
| Bytes that are not valid input at all | parser leaking a 5xx and an internal message instead of a 4xx |
| Wrong type per field — string for number, `null`, array for object | unguarded casts, 500s, silent coercion |
| Missing required field · unexpected extra field | validation that only covers the happy path; mass-assignment |
| Every client-supplied value the server should not trust — timestamp, id, total, status, actor | fields the server accepts and stores unvalidated; read the record back to see |
| Zero · negative · empty string · one past max · exactly at the limit | sign errors, off-by-one, inclusive/exclusive confusion |
| The same request twice, then N at once | missing idempotency, check-then-act races |
| No credential · another actor's id · an id that does not exist | missing authz, enumeration, error-shape leaks |
| Oversized field, unicode, control characters | truncation, encoding corruption, injection surface |

**Read the error contract, not just the status.** A 500 where a 400 belongs is a
defect even when the request was nonsense — it means an unhandled path, and the
body usually names an internal detail an attacker would like.

**An endpoint called only with well-formed input has not been tested.** If you
deliberately skip this list, say so in the report and say why.

## 5. Bypass the interface

**Every constraint the interface enforces is a case at the API.** Take the
request the UI would send, change the value the UI would not let you enter, and
send it directly — a negative where the input blocks negatives, a foreign ID
where the list only shows yours, the mutation behind the hidden button. A rule
that lives only in the component is not a rule.

## 6. Rank by blast radius, and predict

Order by what the defect costs if real, never by how easy the test is to write.
Per scenario, state the expected result and the invariant it attacks *before*
running, and say what would make you call the feature broken. If nothing would,
the scenario is theatre.

## Disqualifiers

Testing only what the spec describes — the spec is the happy path, and defects
live in what it forgot · every scenario a single request, when real defects need
sequences · topic areas instead of executable scenarios with inputs and
predicted outcomes · ranking by convenience.
