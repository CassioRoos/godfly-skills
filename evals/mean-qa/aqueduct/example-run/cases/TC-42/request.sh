#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' \
  '-X' \
  'POST' \
  '-H' \
  'Content-Type: application/json' \
  '-d' \
  '{"account_id":"ACC-NOPE-2","meter_m3":500}' \
  'http://127.0.0.1:8414/api/readings' \
  ;
