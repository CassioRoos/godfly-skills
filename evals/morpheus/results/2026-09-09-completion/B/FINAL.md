Implemented `latest_events` in `events.py`; preserved `distinct_keys` unchanged.

Added `tests/test_latest_events.py` covering revision selection, last-record ties, first-appearance order, generators, empty input, complete records, and non-mutation.

Verification: `python3 -m unittest discover -s tests -v` — all 6 tests pass. The 3 new tests failed against the original stub before implementation.

No commits or publishing.