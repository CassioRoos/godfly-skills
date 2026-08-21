#!/bin/sh
# README: final "may only be issued by a supervisor and only after the two
# earlier notices exist for that account". This account has zero notices and
# the actor is a plain clerk. Expect a 4xx refusal.
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST \
  -H 'Content-Type: application/json' \
  -d '{"account_id":"ACC-2043","actor":"temp-intern","stage":"final"}' \
  http://localhost:8413/api/shutoff
