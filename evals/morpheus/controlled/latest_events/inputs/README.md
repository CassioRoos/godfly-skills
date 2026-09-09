# Lantern event viewer

This fictional project uses only Python's standard library.

`distinct_keys(events)` is an existing public helper: it returns distinct keys
in first-appearance order and accepts a finite iterable. Preserve its behavior.

Implement `latest_events(events)` with this complete contract:

- Each record is a dictionary containing `key` (string), `revision` (integer),
  and arbitrary additional fields. Inputs already satisfy these types.
- Return a list with one complete record per key. Greatest revision wins;
  equal revisions are resolved in favor of the last input record.
- Preserve the order in which keys first appeared, regardless of which
  revision ultimately wins.
- Accept any finite iterable, including a generator. Empty input returns `[]`.
- Do not mutate input records. No deep-copy or object-identity guarantee is
  required for returned records.
- No third-party dependencies, external services, or application integration.

Baseline: `python3 -m unittest discover -s tests -v`.
The baseline covers the existing helper. `latest_events` is a known unfinished
function; its new behavior needs focused verification.
