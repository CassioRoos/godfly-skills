#!/bin/sh
for i in 1 2 3 4 5 6 7 8 9 10; do
  curl -sS -o /dev/null -w "%{http_code} " -X POST -H "Content-Type: application/json" \
    -d '{"account_id":"ACC-1188","actor":"clerk","stage":"final"}' \
    http://127.0.0.1:8414/api/shutoff &
done
wait; echo
