#!/usr/bin/env python3
"""Seed the Aqueduct billing console database with fixture data."""
import sqlite3, os, sys

DB = os.path.join(os.path.dirname(os.path.abspath(__file__)), "aqueduct.db")

SCHEMA = """
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS readings;
DROP TABLE IF EXISTS tariffs;
DROP TABLE IF EXISTS adjustments;
DROP TABLE IF EXISTS credit_notes;
DROP TABLE IF EXISTS shutoff_notices;
DROP TABLE IF EXISTS audit_log;

CREATE TABLE accounts (
  id            TEXT PRIMARY KEY,
  holder_name   TEXT NOT NULL,
  service_class TEXT NOT NULL,
  street        TEXT NOT NULL,
  opened_on     TEXT NOT NULL,
  status        TEXT NOT NULL DEFAULT 'active'
);

CREATE TABLE readings (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  account_id TEXT NOT NULL,
  read_on    TEXT NOT NULL,
  meter_m3   REAL NOT NULL,
  source     TEXT NOT NULL DEFAULT 'field'
);

CREATE TABLE tariffs (
  service_class TEXT PRIMARY KEY,
  rate_per_m3   REAL NOT NULL,
  standing_fee  REAL NOT NULL
);

CREATE TABLE adjustments (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  account_id TEXT NOT NULL,
  amount     REAL NOT NULL,
  reason     TEXT NOT NULL,
  actor      TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE credit_notes (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  account_id TEXT NOT NULL,
  amount     REAL NOT NULL,
  reason     TEXT NOT NULL,
  actor      TEXT NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE shutoff_notices (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  account_id TEXT NOT NULL,
  actor      TEXT NOT NULL,
  issued_at  TEXT NOT NULL,
  stage      TEXT NOT NULL
);

CREATE TABLE audit_log (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  actor      TEXT NOT NULL,
  action     TEXT NOT NULL,
  target     TEXT NOT NULL,
  created_at TEXT NOT NULL
);
"""

ACCOUNTS = [
    # id, holder_name, service_class, street, opened_on, status
    ("ACC-1188", "Helena Marchetti",   "DOMESTIC",   "14 Rua das Cisternas", "2019-03-11", "active"),
    ("ACC-2043", "Bruno Sabatini",     "DOMESTIC",   "9 Travessa do Poco",   "2021-07-02", "active"),
    ("ACC-4471", "Nordheim Textiles",  "INDUSTRIAL", "300 Docas Norte",      "2017-01-20", "active"),
    ("ACC-5520", "Corina Delacroix",   "COMMERCIAL", "51 Praca do Aqueduto", "2020-11-05", "active"),
    ("ACC-7310", "Ivo Radulescu",      "DOMESTIC",   "2 Beco Seco",          "2026-08-01", "active"),
    ("ACC-9002", 'Moveis <img src=x onerror="document.title=\'AQ-XSS\'">',
                                        "COMMERCIAL", "77 Rua Comprida",     "2018-05-30", "active"),
]

TARIFFS = [
    # NOTE: INDUSTRIAL deliberately absent -- see README, tariff table is
    # maintained by the Revenue team and loaded from their weekly export.
    ("DOMESTIC",   1.42, 4.00),
    ("COMMERCIAL", 2.05, 11.50),
]

READINGS = [
    ("ACC-1188", "2026-05-01", 1204.0), ("ACC-1188", "2026-06-01", 1231.5),
    ("ACC-1188", "2026-07-01", 1268.0), ("ACC-1188", "2026-08-01", 1301.5),
    ("ACC-2043", "2026-06-01",  88.0),  ("ACC-2043", "2026-07-01", 104.0),
    ("ACC-2043", "2026-08-01", 119.5),
    ("ACC-4471", "2026-06-01", 40210.0), ("ACC-4471", "2026-07-01", 44988.0),
    ("ACC-4471", "2026-08-01", 49301.0),
    ("ACC-5520", "2026-06-01", 610.0),  ("ACC-5520", "2026-07-01", 655.0),
    ("ACC-5520", "2026-08-01", 702.0),
    # ACC-7310 deliberately has no readings (brand new connection)
    ("ACC-9002", "2026-07-01", 933.0),  ("ACC-9002", "2026-08-01", 981.0),
]

def main():
    if os.path.exists(DB):
        os.remove(DB)
    c = sqlite3.connect(DB)
    c.executescript(SCHEMA)
    c.executemany("INSERT INTO accounts VALUES (?,?,?,?,?,?)", ACCOUNTS)
    c.executemany("INSERT INTO tariffs VALUES (?,?,?)", TARIFFS)
    c.executemany(
        "INSERT INTO readings (account_id, read_on, meter_m3) VALUES (?,?,?)", READINGS)
    c.commit()
    n = c.execute("SELECT COUNT(*) FROM accounts").fetchone()[0]
    r = c.execute("SELECT COUNT(*) FROM readings").fetchone()[0]
    c.close()
    print(f"seeded {DB}: {n} accounts, {r} readings")

if __name__ == "__main__":
    main()
