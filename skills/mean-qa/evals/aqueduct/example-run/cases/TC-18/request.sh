#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST -H 'Content-Type: application/json' -d '{"account_id":"ACC-1188","amount":1,"reason":"extra","actor":"clerk-a","id":9999,"created_at":"1970-01-01T00:00:00Z","is_supervisor":true}' http://localhost:8413/api/adjustments
