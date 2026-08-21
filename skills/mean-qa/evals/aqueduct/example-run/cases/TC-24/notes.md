UI -- stored XSS via the clerk-supplied `reason` field. Images: 04 (before),
15 (after). This is the serious variant: no seeded fixture needed, any clerk
can plant it, and it runs for every clerk who later opens the account.

Typed into the Reason input on ACC-7310 and submitted through the form:
  goodwill <img src=y onerror="document.title='AQ-XSS-VIA-REASON';window.__aqPwned=true">
Before: document.title == "AQ-XSS-VIA-REASON", window.__aqPwned === true,
imgTagsInLedger 1, and the payload persisted to the DB (direct read in the
report).
After: pwnedFlagSet false, xssExecuted false, imgTagsInLedger 0, ledger cell
shows the payload as escaped text; the adjustment itself still applied
correctly (balance 9.00). Status: FAILED -> fixed.
