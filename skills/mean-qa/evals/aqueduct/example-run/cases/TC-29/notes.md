UI -- money-form validation asymmetry. Image: 05.
"12,50" -- a comma decimal, plausible in a deployment whose fixture addresses
are Portuguese -- was sent raw to the server, which did float("12,50") and
returned 500 with a traceback. The clerk got a generic "Could not apply
adjustment". The credit-note modal DID validate (isNaN check) and said "Amount
must be a number", so the same app validated one money form and not the other.
After: both forms validate identically before sending, and a server refusal is
shown to the clerk verbatim instead of a generic string. Nothing was written on
the failed attempt on either build (verified by direct read).
Status: FAILED -> fixed.
