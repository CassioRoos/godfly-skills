UI -- the irreversible action had no confirmation. Images: 08 (before),
15 (after).
Before: the "Issue shutoff notice" button posted stage "final" on a single
click, with no dialog. ACC-7310 went active -> shutoff_pending immediately.
The asymmetry is the oracle: the credit-note button opened a modal carrying the
warning "Credit notes cannot be voided from the console", while dispatching a
crew to cut off a household's water -- irreversible per the README -- asked
nothing.
After: a stage selector defaulting to "reminder", and for "final" a
window.confirm naming the account and the consequence. Dismissing it wrote
nothing (verified: 0 notices, status still active). Accepting it still hit the
server's ordering rule and surfaced "cannot issue final for ACC-7310: no
reminder or warning notice on file yet". Status: FAILED -> fixed.
