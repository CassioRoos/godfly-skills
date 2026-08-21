#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' -X POST -H 'Content-Type: application/json' -d '{"account_id":"GHOST-1","meter_m3":999}' http://localhost:8413/api/readings
