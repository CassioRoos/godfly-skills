#!/bin/sh
# A single adjustment whose amount overflows float -> inf. json.dumps then emits
# the bare token Infinity, which is not valid JSON.
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST \
  -H 'Content-Type: application/json' \
  -d '{"account_id":"ACC-2043","amount":"1e400","reason":"fat finger","actor":"clerk-a"}' \
  http://localhost:8413/api/adjustments
