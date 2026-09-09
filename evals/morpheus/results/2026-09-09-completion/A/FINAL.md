Implemented `latest_events` per README: greatest revision wins, last record wins ties, and first-appearance key order is preserved. Supports generators without mutating inputs. `distinct_keys` is unchanged.

Added focused regression tests. All 5 tests pass with `python3 -m unittest discover -s tests -v`.

Nothing committed or published.