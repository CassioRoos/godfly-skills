#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' \
  '-X' \
  'POST' \
  '-H' \
  'Content-Type: application/json' \
  '-d' \
  '{"account_id":"ACC-5520","amount":"1e400","reason":"field retry","actor":"clerk"}' \
  'http://127.0.0.1:8414/api/credit-notes' \
  ;
