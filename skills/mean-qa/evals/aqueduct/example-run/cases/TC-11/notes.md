Shutoff for "ACC-DOES-NOT-EXIST" returned 201 {"ok": true} and wrote a notice
row, while the UPDATE matched zero rows. The API announced a crew dispatch that
no account backs -- the "anything announced actually happened" invariant.
Status: FAILED -> fixed (404).
