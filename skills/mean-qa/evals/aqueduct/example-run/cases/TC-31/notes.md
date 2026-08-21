Resilience of the fix to data the old build already wrote. Image: 17.
A non-finite amount was inserted straight into `adjustments` with sqlite3, as a
legacy row. First result: the list endpoint stayed valid JSON and isolated the
one account as blocked (containment works), but GET /api/accounts/ACC-2043
returned 500, because the raw ledger rows still carried inf -- so the clerk
could not open the one account needing manual correction. Fixed with safe_row().
Final state: the offending row is visible with amount "—", the balance reads
"cannot bill", and the message says the account needs manual correction.
Status: FAILED on the first fix attempt -> fixed.
