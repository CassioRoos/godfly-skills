UI -- unknown account. Images: 10 (before), 16 (after).
Before: /account/ACC-DOES-NOT-EXIST rendered no title and no billing, but the
full Actions panel -- including the danger-styled "Issue shutoff notice"
button -- was present and clickable, over an account that does not exist.
Combined with TC-11 (shutoff on a nonexistent account returned 201), a clerk
who mistyped an account id had a working shutoff button.
After: "Unknown account" / "no such account" and the action panel is hidden.
Status: FAILED -> fixed.
