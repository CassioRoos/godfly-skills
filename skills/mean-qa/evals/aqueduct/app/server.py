#!/usr/bin/env python3
"""
Aqueduct — internal water-utility billing console.

Run:  python3 server.py [port]      (default 8410)
"""
import json, os, sqlite3, sys, traceback, datetime
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from urllib.parse import urlparse

HERE = os.path.dirname(os.path.abspath(__file__))
DB = os.path.join(HERE, "aqueduct.db")
PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8410


def db():
    conn = sqlite3.connect(DB, timeout=10)
    conn.row_factory = sqlite3.Row
    return conn


def now():
    return datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")


# ---------------------------------------------------------------- billing core

def lookup_tariff(conn, service_class):
    """Rate for a service class.

    The tariffs table is populated from the Revenue team's weekly export, so a
    class can be missing between exports. This helper has no error return.
    """
    row = conn.execute(
        "SELECT rate_per_m3, standing_fee FROM tariffs WHERE service_class = ?",
        (service_class,)).fetchone()
    if not row:
        return 0.0, 0.0
    return row["rate_per_m3"], row["standing_fee"]


def consumption(conn, account_id):
    """m3 consumed = latest reading minus the previous one.

    Negative consumption is allowed on purpose: when a meter is swapped the new
    unit starts from zero, and Billing sign-off (2026-06) was that the negative
    period is carried rather than clamped, so the customer is not charged twice
    for the same water. Do not clamp this to zero.
    """
    rows = conn.execute(
        "SELECT meter_m3 FROM readings WHERE account_id = ? "
        "ORDER BY read_on DESC, id DESC LIMIT 2", (account_id,)).fetchall()
    if len(rows) < 2:
        return None
    return rows[0]["meter_m3"] - rows[1]["meter_m3"]


def balance(conn, account_id):
    """Amount the account currently owes."""
    acct = conn.execute("SELECT * FROM accounts WHERE id = ?",
                        (account_id,)).fetchone()
    if not acct:
        return None
    rate, fee = lookup_tariff(conn, acct["service_class"])
    used = consumption(conn, account_id)
    charges = fee + (rate * used) if used is not None else fee

    adj = conn.execute(
        "SELECT COALESCE(SUM(amount),0) s FROM adjustments WHERE account_id = ?",
        (account_id,)).fetchone()["s"]
    cred = conn.execute(
        "SELECT COALESCE(SUM(amount),0) s FROM credit_notes WHERE account_id = ?",
        (account_id,)).fetchone()["s"]

    return {
        "account_id": account_id,
        "rate_per_m3": rate,
        "standing_fee": fee,
        "consumption_m3": used,
        "charges": round(charges, 2),
        "adjustments": round(adj, 2),
        "credits": round(cred, 2),
        "balance_due": round(charges + adj - cred, 2),
    }


# ---------------------------------------------------------------- api handlers

def api_accounts(conn, _body):
    out = []
    for a in conn.execute("SELECT * FROM accounts ORDER BY id").fetchall():
        b = balance(conn, a["id"])
        out.append({
            "id": a["id"], "holder_name": a["holder_name"],
            "service_class": a["service_class"], "street": a["street"],
            "status": a["status"], "balance_due": b["balance_due"],
            "consumption_m3": b["consumption_m3"],
        })
    return 200, {"accounts": out}


def api_account(conn, account_id):
    a = conn.execute("SELECT * FROM accounts WHERE id = ?",
                     (account_id,)).fetchone()
    if not a:
        return 404, {"error": "no such account"}
    reads = [dict(r) for r in conn.execute(
        "SELECT * FROM readings WHERE account_id = ? ORDER BY read_on DESC",
        (account_id,)).fetchall()]
    adjs = [dict(r) for r in conn.execute(
        "SELECT * FROM adjustments WHERE account_id = ? ORDER BY id DESC",
        (account_id,)).fetchall()]
    creds = [dict(r) for r in conn.execute(
        "SELECT * FROM credit_notes WHERE account_id = ? ORDER BY id DESC",
        (account_id,)).fetchall()]
    notices = [dict(r) for r in conn.execute(
        "SELECT * FROM shutoff_notices WHERE account_id = ? ORDER BY id DESC",
        (account_id,)).fetchall()]
    return 200, {
        "account": dict(a), "readings": reads, "adjustments": adjs,
        "credit_notes": creds, "shutoff_notices": notices,
        "billing": balance(conn, account_id),
    }


def api_add_reading(conn, body):
    account_id = body["account_id"]
    meter_m3 = float(body["meter_m3"])
    read_on = body.get("read_on") or now()[:10]
    conn.execute(
        "INSERT INTO readings (account_id, read_on, meter_m3, source) "
        "VALUES (?,?,?,?)", (account_id, read_on, meter_m3,
                            body.get("source", "console")))
    conn.commit()
    return 201, {"ok": True, "billing": balance(conn, account_id)}


def api_adjustment(conn, body):
    """Apply a billing adjustment. Amount comes from the console form."""
    account_id = body["account_id"]
    amount = float(body["amount"])
    conn.execute(
        "INSERT INTO adjustments (account_id, amount, reason, actor, created_at) "
        "VALUES (?,?,?,?,?)",
        (account_id, amount, body.get("reason", ""),
         body.get("actor", "console"), now()))
    conn.commit()
    return 201, {"ok": True, "billing": balance(conn, account_id)}


def api_credit_note(conn, body):
    """Issue a credit note against an account.

    Credit notes are irreversible once issued -- Finance reconciles them
    nightly and there is no console path to void one.
    """
    account_id = body["account_id"]
    amount = float(body["amount"])
    conn.execute(
        "INSERT INTO credit_notes (account_id, amount, reason, actor, created_at) "
        "VALUES (?,?,?,?,?)",
        (account_id, amount, body.get("reason", ""),
         body.get("actor", "console"), now()))
    conn.commit()
    return 201, {"ok": True, "billing": balance(conn, account_id)}


def api_shutoff(conn, body):
    """Issue a disconnection notice. Requires a supervisor."""
    account_id = body["account_id"]
    actor = body.get("actor", "console")
    conn.execute(
        "INSERT INTO shutoff_notices (account_id, actor, issued_at, stage) "
        "VALUES (?,?,?,?)", (account_id, actor, now(),
                             body.get("stage", "final")))
    conn.execute("UPDATE accounts SET status = 'shutoff_pending' WHERE id = ?",
                 (account_id,))
    conn.commit()
    return 201, {"ok": True, "account_id": account_id, "actor": actor}


# ---------------------------------------------------------------- http plumbing

class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.1"

    def log_message(self, fmt, *args):
        sys.stderr.write("%s - %s\n" % (self.address_string(), fmt % args))

    def _send(self, code, payload, ctype="application/json"):
        body = (json.dumps(payload, indent=2).encode()
                if ctype == "application/json" else payload.encode())
        self.send_response(code)
        self.send_header("Content-Type", ctype + "; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _static(self, name, ctype):
        p = os.path.join(HERE, "static", name)
        if not os.path.exists(p):
            return self._send(404, {"error": "not found"})
        with open(p) as f:
            self._send(200, f.read(), ctype)

    def do_GET(self):
        path = urlparse(self.path).path
        try:
            if path == "/" or path.startswith("/account/"):
                return self._static("index.html", "text/html")
            if path == "/static/app.js":
                return self._static("app.js", "application/javascript")
            if path == "/static/style.css":
                return self._static("style.css", "text/css")
            conn = db()
            try:
                if path == "/api/accounts":
                    code, out = api_accounts(conn, None)
                    return self._send(code, out)
                if path.startswith("/api/accounts/"):
                    code, out = api_account(conn, path.rsplit("/", 1)[1])
                    return self._send(code, out)
            finally:
                conn.close()
            self._send(404, {"error": "no route", "path": path})
        except Exception:
            self._send(500, {"error": "server error",
                             "trace": traceback.format_exc()})

    def do_POST(self):
        path = urlparse(self.path).path
        routes = {
            "/api/readings": api_add_reading,
            "/api/adjustments": api_adjustment,
            "/api/credit-notes": api_credit_note,
            "/api/shutoff": api_shutoff,
        }
        try:
            n = int(self.headers.get("Content-Length") or 0)
            raw = self.rfile.read(n).decode() if n else "{}"
            body = json.loads(raw)
            fn = routes.get(path)
            if not fn:
                return self._send(404, {"error": "no route", "path": path})
            conn = db()
            try:
                code, out = fn(conn, body)
                return self._send(code, out)
            finally:
                conn.close()
        except Exception:
            self._send(500, {"error": "server error",
                             "trace": traceback.format_exc()})


if __name__ == "__main__":
    if not os.path.exists(DB):
        sys.exit("no aqueduct.db -- run: python3 seed.py")
    print(f"Aqueduct console on http://localhost:{PORT}")
    ThreadingHTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
