#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST -H 'Content-Type: application/json' -d '{"account_id":"ACC-2043","amount":NaN,"reason":"nan probe","actor":"clerk-a"}' http://localhost:8413/api/adjustments
