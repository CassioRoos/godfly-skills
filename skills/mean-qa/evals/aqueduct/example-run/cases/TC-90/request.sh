#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' \
  '-X' \
  'POST' \
  '-H' \
  'Content-Type: application/json' \
  '-d' \
  '{"account_id":"ACC-1188","meter_m3":12.0,"read_on":"2026-09-01"}' \
  'http://127.0.0.1:8414/api/readings' \
  ;
