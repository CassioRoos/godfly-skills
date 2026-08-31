#!/usr/bin/env python3
import json, urllib.request
reason = "A"*20000 + " " + chr(0x202E) + " \U0001F4A7"   # 20k chars + RTL-override + emoji
body = json.dumps({"account_id":"ACC-1188","amount":1,"reason":reason,"actor":"x"}).encode()
req = urllib.request.Request("http://127.0.0.1:8414/api/adjustments", body,
                             {"Content-Type":"application/json"})
r = urllib.request.urlopen(req)
print("HTTP", r.status)
