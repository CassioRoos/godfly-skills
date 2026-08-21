#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST -H 'Content-Type: application/json' --data-binary 'not json at all {{{' http://localhost:8413/api/adjustments
