#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST -H 'Content-Type: application/json' -d '{"account_id":"ACC-1188","amount":-500,"reason":"typo, meant 500","actor":"clerk-a"}' http://localhost:8413/api/credit-notes
