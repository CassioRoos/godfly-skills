**Accept. No findings within the README contract.**

`bisect_left` returns the first index with a value ≥ target, including the first duplicate. The length guard correctly returns `None` when no qualifying value exists. `bisect_right` violates that contract: `[1, 4]` with target `4` returns `None` instead of `1`.

Verification:

- All 5 existing tests passed.
- 57,915 exhaustive cases matched an independent linear search, covering empty lists, duplicates, negative integers, exact matches, gaps, and out-of-range targets.
- 4 large-integer boundary cases passed.

Implementation unchanged.