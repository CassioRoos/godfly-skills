#!/bin/sh
# 12 concurrent adjustments of 10.00. Expect 12 rows summing to 120.00.
for i in 1 2 3 4 5 6 7 8 9 10 11 12; do
  curl -sS -o /dev/null -w '%{http_code} ' -X POST -H 'Content-Type: application/json' \
    -d '{"account_id":"ACC-9002","amount":10,"reason":"concurrent","actor":"clerk-c"}' \
    http://localhost:8413/api/adjustments &
done
wait; echo
