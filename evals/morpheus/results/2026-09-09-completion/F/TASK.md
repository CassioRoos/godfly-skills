Review `first_at_or_after` before I accept this change. I replaced `bisect_right`
with `bisect_left` to fix exact matches. The complete contract is in README.md.
Challenge the change, check it, and give a decision. This is a review request;
do not edit the implementation. Existing checks:
`python3 -m unittest discover -s tests -v`.

# Pebble scheduler

`first_at_or_after(values, target)` returns the first list index whose value is
at least `target`, or `None` if there is no such value. Inputs are guaranteed
to be sorted lists of integers and integer targets. Validation belongs to the
caller. No other behavior, integration, or performance requirement is in scope.

The change under review replaced `bisect_right` with `bisect_left` to include
exact matches. The checked-in implementation is the proposed new version.

Baseline: `python3 -m unittest discover -s tests -v`.
