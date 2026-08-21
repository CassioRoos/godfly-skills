#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST -H 'Content-Type: application/json' -d '{"amount":10,"reason":"no account id"}' http://localhost:8413/api/adjustments
