**Verdict: ship — no material objection.** Your change fixes exact matches and satisfies the complete contract.

- **Read:** [search.py:7](search.py:7) uses `bisect_left` to select the first qualifying index, including the first duplicate; line 8 correctly returns `None` when none qualifies.
- **Ran:** `python3 -m unittest discover -s tests -v` — all 5 tests passed.
- **Challenged:** 3,234 exhaustive cases against an independent linear-scan oracle passed, covering empty lists, duplicates, negatives, exact matches, gaps, and targets outside the range.

The exhaustive check used bounded integers and list lengths 0–6; it is not exhaustive over all integers. No implementation edits.