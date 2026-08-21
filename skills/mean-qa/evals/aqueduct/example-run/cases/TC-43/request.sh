#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' \
  '-X' \
  'POST' \
  '-H' \
  'Content-Type: application/json' \
  '-d' \
  '{"account_id":"ACC-2043","meter_m3":131.0,"read_on":"01-09-2026"}' \
  'http://127.0.0.1:8414/api/readings' \
  ;
