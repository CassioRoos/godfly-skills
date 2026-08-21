#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST -H 'Content-Type: application/json' -d '{"account_id":"ACC-DOES-NOT-EXIST","actor":"clerk-a","stage":"final"}' http://localhost:8413/api/shutoff
