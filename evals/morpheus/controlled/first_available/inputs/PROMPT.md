Review `first_at_or_after` before I accept this change. I replaced `bisect_right`
with `bisect_left` to fix exact matches. The complete contract is in README.md.
Challenge the change, check it, and give a decision. This is a review request;
do not edit the implementation. Existing checks:
`python3 -m unittest discover -s tests -v`.
