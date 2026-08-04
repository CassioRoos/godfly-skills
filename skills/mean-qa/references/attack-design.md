# Attack Design — How To Be Mean On Purpose

Evidence discipline proves what you tested. It does not choose what to test.
This does. Read it during **Design the attack**, before touching the system —
attacks improvised after the happy path only find happy-path-adjacent bugs.

The job is not to confirm the feature works. It is to find the input, ordering,
or failure that makes it lose money, corrupt state, or lie to a user.

## 1. Name the invariants

Write what must be true no matter what. You attack invariants; features are
just how they're exposed. For anything touching money or records, at least:
**conservation** (value out never exceeds value in), **uniqueness of effect**
(one intent, one effect, however many deliveries), **legal state only**,
**authority** (actors touch only what they own), **durability of truth**
(anything announced to another system actually, durably happened).

Per invariant, one question: *what sequence breaks this?* That's your test.

## 2. Walk the six axes

| Axis | The question | Classic yield |
|---|---|---|
| **Concurrency** | Two at once? | Check-then-act races, lost updates, spend past a ceiling |
| **Duplication** | Same request twice? | Missing idempotency, retry-after-timeout, replayed event |
| **Partial failure** | Every external call has three outcomes — success, failure, **unknown**. Dies between N and N+1? | Money moved with no record, event published before commit, orphaned rows |
| **Boundary** | Zero, negative, empty, max, one-past, exactly-at? | Off-by-one, sign errors, inclusive/exclusive confusion |
| **Identity** | Caller is someone else, or nobody? | IDOR, missing ownership check, "internal" endpoint |
| **Time** | Clock moves, differs, or the boundary is exact? | Timezone/DST, expiry windows, skew between services |
| **Dependency** | Every service, cache, lookup, or table this operation consults — what does the code do when it is down, slow, empty, or returns a zero value? | Safety gates that fail **open**, lookups whose empty answer reads as "no problem found", defaults that silently reinterpret intent |

## 3. Find the cut corner

Read the implementation hunting the shortcut a tired engineer took at 6pm:
a read followed by a conditional write with no transaction between them; an
error path that returns early leaving earlier writes behind; validation that
covers only the fields the happy path uses; a publish before the commit it
describes; a status field that exists and is never read; a context value
middleware populates and nobody consults; a query filter excluding one state
and silently including the rest.

Each tell is a scenario. Write the one that makes the shortcut visible.

**Enumerate every dependency and remove it, one at a time.** List every external
thing the operation consults — service, cache, lookup table, dictionary,
feature flag, config. For each, ask what the code receives when it is
unavailable, degraded, or simply does not know the answer, and then ask what the
code *does* with that value.

The dangerous pattern is a call with **no error return**. It cannot fail, so it
returns a zero value instead: `""`, `false`, `0`, an empty list. Then check
which way that zero value falls:

- A classifier returning `""` matches nothing — so a check that looks for a
  match **finds none and lets everything through**. The gate is now a no-op for
  every request simultaneously, silently, with no error and no metric.
- A predicate returning `false` skips the branch it guards — so a special
  calculation is quietly bypassed and the raw input is used as if it were the
  computed result. The user's intent has been reinterpreted, not rejected.
- An empty list reads as "nothing to worry about" rather than "I could not look."

**"No problem found" and "I could not check" must never be the same value.** Where
they are, the failure is invisible, unlogged, and affects everyone at once — the
worst combination there is. Test it by making the dependency unavailable and
asserting the operation *refuses* rather than proceeds.

This class is systematically under-tested. Testers exercise the dependency
returning *wrong* data far more readily than the dependency returning *nothing*,
because the first is a bug you can imagine and the second looks like it cannot
happen.

## 4. Rank by blast radius

Order by what the defect costs if real, never by how easy the test is to write:
silent money/data loss → wrong money/data visible later → authority violation →
corrupt or stuck state → wrong error contract, UX, cosmetics.

A campaign cut short after three scenarios must still have run the important
ones. That is the whole reason ordering is a rule and not a preference.

## 5. Predict before testing

Per scenario, state the expected result and which invariant it attacks *before*
running. A scenario whose outcome you cannot predict is an exploration — fine,
but label it, because an exploration that "passes" proves nothing. Say what
would make you call the feature broken. If nothing would, the scenario is theatre.

## Deriving the domain's harm model

Do not reach for a checklist. Checklists encode someone else's domain and go
stale. Derive the invariants from what this system can do to a person:

1. **What is the unit of harm here?** Money moved wrongly. A patient given the
   wrong dose. A sealed record disclosed. A deadline missed that forfeits a
   right. An account locked out of something they need. Name it in one sentence.
2. **What must never happen, no matter what?** These are your hard invariants.
   The ones worth writing down are the ones where a single occurrence is a
   serious event — not a degradation, an incident.
3. **What is irreversible?** A sent notification, an administered dose, a filed
   document, a deleted record, a disclosed secret, a settled transfer. Anything
   that cannot be undone deserves the harshest testing, because there is no
   recovery path to fall back on.
4. **Who must never see this, and who must always be able to?** Both directions
   are harm. Wrongful disclosure and wrongful denial of access are each real.
5. **What deadline or timing carries consequence?** A statute of limitations, a
   medication schedule, an authorization expiry, a regulatory reporting window.
   Time-derived harm is invisible until the boundary, then total.
6. **What must be reconstructable afterwards?** If someone has to defend this
   decision in a review, an audit, a court, or a post-incident investigation,
   what record must exist and be provably unaltered?

Then run the six axes against each answer. That produces the domain's reflex
list, correctly, for a domain nobody wrote a checklist for.

**Same method, three domains** — note that only the nouns change:

| | Payments | Clinical | Justice / casework |
|---|---|---|---|
| Unit of harm | Money moved wrongly | Wrong care to a patient | A right forfeited or wrongly denied |
| Never-happen | Value created or destroyed; a charge without authority | A dose past a contraindication; results attached to the wrong patient | A sealed record disclosed; a deadline silently missed |
| Irreversible | Settled transfer, sent statement | Administered medication, released report | Filed document, served notice, expunged data |
| Access, both directions | Tenant reads another's records | Clinician blocked in an emergency; unrelated staff browsing a chart | Sealed material exposed; a party denied their own file |
| Timing | Authorization expiry, settlement window | Medication schedule, critical-result callback | Limitation periods, notice periods, hearing dates |
| Reconstructable | Who moved what, when, on whose authority | Who ordered, who administered, on what indication | Who accessed, who decided, on what basis |

The generic version, for any domain: **whatever the system's unit of value or
harm is, prove it is conserved, attributable, reversible where it must be,
irreversible where it must be, visible only to those entitled, and provable
after the fact.** If the domain is unfamiliar, ask the user what a bad day looks
like for the people this system serves, and test that.

A caution worth stating plainly: in regulated domains the correct behaviour is
frequently defined outside the codebase — in a statute, a standard, a clinical
protocol, a court rule. The spec is not the oracle there, and neither is the
code. If a rule of that kind is load-bearing for a finding, name it and ask;
never infer a regulatory requirement and report it as fact.

## Disqualifiers

Testing only what the spec describes (the spec is the happy path; bugs live in
what it forgot) · every scenario a single request, when real defects need
sequences · topic areas instead of executable scenarios with inputs and predicted
outcomes · ranking by convenience instead of blast radius.
