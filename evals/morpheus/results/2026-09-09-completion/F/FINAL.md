**Verdict: accept — no material objection.** Your change correctly includes exact matches and returns the first duplicate’s index.

- **Read:** `README.md` and `search.py`: `bisect_left` finds the first value ≥ target; the length check correctly returns `None` when none exists.
- **Ran:** `python3 -m unittest discover -s tests -v` — all 5 tests passed. An independent linear-scan oracle also matched all **30,888 cases**, covering empty lists, duplicates, negative integers, and boundary targets.
- **Challenged:** `[1, 3, 3, 5]`, target `3`: the old behavior returns `3`; your version correctly returns `1`.

Untested: inputs outside the documented contract. Implementation unchanged.