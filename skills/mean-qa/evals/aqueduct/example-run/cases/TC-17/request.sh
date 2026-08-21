#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST -H 'Content-Type: application/json' -d '{"account_id":"ACC-5520","meter_m3":10,"read_on":"whenever"}' http://localhost:8413/api/readings
