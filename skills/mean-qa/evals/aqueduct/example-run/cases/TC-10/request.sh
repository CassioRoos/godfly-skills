#!/bin/sh
for i in 1 2 3; do curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST -H 'Content-Type: application/json' -d '{"account_id":"ACC-2043","actor":"temp-intern","stage":"final"}' http://localhost:8413/api/shutoff; done
