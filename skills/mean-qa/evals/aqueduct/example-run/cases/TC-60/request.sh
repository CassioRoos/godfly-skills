#!/bin/sh
# sent twice, identical body
for i in 1 2; do
  curl -sS -w "\nHTTP %{http_code}\n" -X POST -H "Content-Type: application/json" \
    -d '{"account_id":"ACC-1188","amount":40,"reason":"goodwill CN-77","actor":"clerk"}' http://127.0.0.1:8414/api/credit-notes
done
