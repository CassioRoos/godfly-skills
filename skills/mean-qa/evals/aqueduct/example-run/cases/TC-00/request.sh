#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' http://localhost:8413/api/accounts
