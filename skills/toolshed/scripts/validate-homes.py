#!/usr/bin/env python3
"""Validate explicit homes of parked questions; no network or repository writes."""
import argparse
from pathlib import Path
import re
import sys
from urllib.parse import urlsplit


def uncommented(path):
    body = path.read_text()
    parts = re.split(r"(<!--|-->)", body)
    inside = False
    result = []
    for part in parts:
        if part == "<!--":
            if inside:
                raise ValueError("nested HTML comments")
            inside = True
        elif part == "-->":
            if not inside:
                raise ValueError("closing HTML comment without opening marker")
            inside = False
        elif not inside:
            result.append(part)
    if inside:
        raise ValueError("unclosed HTML comment")
    return "".join(result)


def check_home(value, root, remote_confirmed):
    value = value.strip()
    link = re.fullmatch(r"\[.*?\]\(([^)]+)\)(?:\s+\([^)]*\))?", value)
    if link:
        value = link.group(1).strip()
    else:
        # Permit the existing plain-path convention with a parenthetical note.
        value = re.sub(r"\s+\([^)]*\)$", "", value).strip().strip("`")
    if not value or value.lower() in {"todo", "tbd", "none", "n/a"} or "<" in value:
        return "empty or placeholder home"
    url = urlsplit(value)
    if url.scheme:
        if url.scheme not in {"http", "https"} or not url.hostname or url.username or url.password or re.search(r"\s", value):
            return "invalid remote home"
        if not remote_confirmed:
            return "remote home unverified; read back final question and wake-up trigger before --remote-homes-confirmed"
        return None
    candidate = Path(value.split("#", 1)[0])
    if candidate.is_absolute():
        return "home must be repo-relative or an explicitly verified URL"
    target = (root / candidate).resolve()
    if not target.is_relative_to(root):
        return "home escapes repository"
    if target.is_relative_to((root / "docs/work").resolve()):
        return "home is inside mortal docs/work"
    if not target.is_file():
        return "home file does not exist"
    return None


def main():
    if len(sys.argv) == 3 and sys.argv[1] == "--strip-comments":
        print(uncommented(Path(sys.argv[2])), end="")
        return
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", type=Path)
    parser.add_argument("questions", type=Path)
    parser.add_argument("--remote-homes-confirmed", action="store_true")
    args = parser.parse_args()
    if not args.questions.exists():
        return
    body = uncommented(args.questions)
    errors = []
    for record in re.split(r"(?m)(?=^### Q-)", body)[1:]:
        ident = record.splitlines()[0]
        if not re.search(r"(?m)^- \*\*Status:\*\*\s*parked\b", record):
            continue
        homes = re.findall(r"(?m)^- \*\*(?:Home|Promoted):\*\*([^\n]*)", record)
        if len(homes) != 1:
            errors.append(f"{ident}: expected one explicit Home or Promoted field")
            continue
        problem = check_home(homes[0], args.root.resolve(), args.remote_homes_confirmed)
        if problem:
            errors.append(f"{ident}: {problem}")
    if errors:
        raise ValueError("; ".join(errors))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as exc:
        print(f"validate-homes: {exc}", file=sys.stderr)
        sys.exit(1)
