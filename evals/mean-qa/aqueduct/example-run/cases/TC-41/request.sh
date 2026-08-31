#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' \
  '-X' \
  'POST' \
  '-H' \
  'Content-Type: application/json' \
  '-d' \
  '{"account_id":"ACC-2043","meter_m3":200,"read_on":"tomorrow-ish"}' \
  'http://127.0.0.1:8414/api/readings' \
  ;
