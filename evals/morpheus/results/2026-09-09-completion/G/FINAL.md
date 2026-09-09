Implemented `latest_events` per README; preserved `distinct_keys` unchanged.

Auxiliary verdict: no material objection. Focused tests cover revision winners, last-record ties, key order, generators, empty input, complete records, and non-mutation.

Ran `python3 -m unittest discover -s tests -v`: **5 tests passed**. New tests failed before implementation and pass afterward. Nothing committed or published.