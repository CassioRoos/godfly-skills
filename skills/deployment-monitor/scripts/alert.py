#!/usr/bin/env python3
"""Local deployment monitor alert helper for macOS and terminal sessions."""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys


DEFAULT_SOUND = "/System/Library/Sounds/Sosumi.aiff"


def run(cmd: list[str], dry_run: bool) -> tuple[bool, str]:
    if dry_run:
        return True, "dry-run: " + " ".join(cmd)
    try:
        completed = subprocess.run(cmd, check=False, text=True, capture_output=True)
    except OSError as exc:
        return False, str(exc)
    output = (completed.stdout + completed.stderr).strip()
    return completed.returncode == 0, output


def notify(title: str, message: str, dry_run: bool) -> tuple[bool, str]:
    if not shutil.which("osascript"):
        return False, "osascript not found"
    script = (
        f"display notification {json.dumps(message)} "
        f"with title {json.dumps(title)} sound name \"Sosumi\""
    )
    return run(["osascript", "-e", script], dry_run)


def speak(message: str, dry_run: bool) -> tuple[bool, str]:
    if not shutil.which("say"):
        return False, "say not found"
    return run(["say", message], dry_run)


def play_sound(sound: str, dry_run: bool) -> tuple[bool, str]:
    if not shutil.which("afplay"):
        return False, "afplay not found"
    return run(["afplay", sound], dry_run)


def main() -> int:
    parser = argparse.ArgumentParser(description="Send a local deployment monitor alert.")
    parser.add_argument("--level", default="BAD", choices=["WATCH", "BAD", "STOP-THE-LINE"])
    parser.add_argument("--title", default="Deployment monitor alert")
    parser.add_argument("--message")
    parser.add_argument("--service-name", "--service", dest="service_name")
    parser.add_argument("--voice-message")
    parser.add_argument("--sound", default=DEFAULT_SOUND)
    parser.add_argument("--no-voice", action="store_true")
    parser.add_argument("--no-sound", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    if args.message:
        message = args.message
    elif args.service_name:
        message = f"Deployment issue detected on {args.service_name}"
    else:
        parser.error("provide --message or --service-name")

    title = f"{args.level}: {args.title}"
    spoken = args.voice_message or message
    results: list[tuple[str, bool, str]] = []

    results.append(("notification", *notify(title, message, args.dry_run)))
    if not args.no_sound:
        results.append(("sound", *play_sound(args.sound, args.dry_run)))
    if not args.no_voice:
        results.append(("voice", *speak(spoken, args.dry_run)))

    delivered = any(ok for _, ok, _ in results)
    for name, ok, output in results:
        status = "ok" if ok else "failed"
        detail = f": {output}" if output else ""
        print(f"{name}: {status}{detail}")

    if delivered:
        return 0

    print("\a", end="")
    print("No rich alert channel succeeded; emitted terminal bell fallback.", file=sys.stderr)
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
