#!/bin/sh
curl -sS -w '\nHTTP %{http_code} in %{time_total}s\n' \
  'http://127.0.0.1:8414/api/accounts/ACC-NOT-REAL' \
  ;
