#!/usr/bin/env python3
"""Build a PR body and numbered overflow comments from a MeanQA PROOF.md.

The report goes between <!-- mean-qa:begin --> and <!-- mean-qa:end --> in the
PR body; the rest of the body is kept. Every #### block (evidence, then raw
output) is a unit. All other report text stays in the body. Units fill the body
in document order; from the first unit that does not fit, the rest go to
comment-02.md, comment-03.md, ... in order, and each run of units gets a pointer
line naming the comments. A unit too large for one comment is split with its
code fences and <details> re-opened. --links maps comment numbers to URLs so
the pointers link them. The script exits non-zero if any report line is missing
from the output, if any output is over the limit, or if a local image has no
uploaded URL.

Usage:
  pr-body.py --proof PROOF.md --out DIR [--pr-body CURRENT.md] [--images MAP.tsv]
             [--links LINKS.tsv] [--root REPO_ROOT] [--sha HEAD_SHA] [--limit 65536]
"""
import argparse
import glob
import os
import re
import sys

BEGIN = "<!-- mean-qa:begin -->"
END = "<!-- mean-qa:end -->"
MARGIN = 512          # headroom under GitHub's limit
WRAP = 8000           # longest line kept intact; longer lines are wrapped, characters kept
IMG = re.compile(r"(!\[[^\]]*\]\()([^)\s]+)(\))")
FENCE = re.compile(r"^\s*(`{3,}|~{3,})")


def glen(text):
    """Length as GitHub counts it (UTF-16 code units)."""
    return len(text.encode("utf-16-le")) // 2


def size(lines):
    return sum(glen(line) + 1 for line in lines)


def fail(code, message):
    print("pr-body.py: " + message, file=sys.stderr)
    sys.exit(code)


def load_images(path):
    images = {}
    if not path:
        return images
    with open(path, encoding="utf-8") as handle:
        for number, raw in enumerate(handle, 1):
            line = raw.rstrip("\n")
            if not line.strip():
                continue
            parts = line.split("\t")
            if len(parts) != 2 or not parts[1].startswith("http"):
                fail(2, "%s:%d: expected '<file>\\t<url>'" % (path, number))
            images[parts[0].strip()] = parts[1].strip()
    return images


def rewrite_images(text, images):
    missing = []

    def swap(match):
        target = match.group(2)
        if re.match(r"^[a-zA-Z][a-zA-Z0-9+.-]*:", target):
            return match.group(0)
        url = images.get(target) or images.get(os.path.basename(target))
        if url:
            return match.group(1) + url + match.group(3)
        missing.append(target)
        return match.group(0)

    return IMG.sub(swap, text), missing


def wrap(lines):
    out = []
    for line in lines:
        while glen(line) > WRAP:
            out.append(line[:WRAP // 2])
            line = line[WRAP // 2:]
        out.append(line)
    return out


def segments(lines):
    """Split the report into ("text", lines) and ("run", [unit, ...]) segments.
    A unit starts at a '#### ' heading and ends at the next heading of level 1-4
    or the end marker. Lines inside code fences are never headings."""
    heading = []
    fence, depth = None, 0
    for line in lines:
        heading.append(fence is None and (re.match(r"^#{1,4} ", line) is not None or line == END))
        fence, depth = fence_state(line, fence, depth)
    out, i = [], 0
    while i < len(lines):
        if heading[i] and lines[i].startswith("#### "):
            run = []
            while i < len(lines) and heading[i] and lines[i].startswith("#### "):
                j = i + 1
                while j < len(lines) and not heading[j]:
                    j += 1
                run.append(lines[i:j])
                i = j
            out.append(("run", run))
        else:
            j = i + 1
            while j < len(lines) and not (heading[j] and lines[j].startswith("#### ")):
                j += 1
            out.append(("text", lines[i:j]))
            i = j
    return out


def unit_name(unit):
    return unit[0][5:].split(" — ")[0].strip()


def load_links(path):
    links = {}
    if not path:
        return links
    with open(path, encoding="utf-8") as handle:
        for number, raw in enumerate(handle, 1):
            line = raw.rstrip("\n")
            if not line.strip():
                continue
            parts = line.split("\t")
            if len(parts) != 2 or not parts[0].strip().isdigit() or not parts[1].startswith("http"):
                fail(2, "%s:%d: expected '<comment number>\\t<url>'" % (path, number))
            links[int(parts[0])] = parts[1].strip()
    return links


def pointer(names, first, last, total, links):
    def label(n):
        text = "QA evidence %d/%d" % (n, total)
        return "[%s](%s)" % (text, links[n]) if n in links else "**%s**" % text
    what = names[0] if len(names) == 1 else "%s to %s" % (names[0], names[-1])
    where = "PR comment " + label(first) if first == last else "PR comments %s to %s" % (label(first), label(last))
    return "_%s continues in %s._" % (what, where)


def fence_state(line, fence, depth):
    match = FENCE.match(line)
    if fence is None:
        if match:
            return match.group(1), depth
        depth += line.count("<details") - line.count("</details>")
        return None, max(depth, 0)
    stripped = line.strip()
    if stripped and set(stripped) == {fence[0]} and len(stripped) >= len(fence):
        return None, depth
    return fence, depth


def chunk(unit, cap):
    """Split one evidence unit into pieces under cap, re-opening fences and details."""
    pieces, current, fence, opener, depth = [], [], None, "", 0
    for line in unit:
        closers = ([fence] if fence else []) + ["</details>"] * depth
        if current and size(current) + glen(line) + 1 + size(closers) > cap:
            pieces.append(current + closers)
            current = ["_(continued)_", ""]
            current += ["<details><summary>(continued)</summary>", ""] * depth
            if fence:
                current.append(opener)
        if glen(line) + 1 + size(current) > cap:
            fail(4, "a single line does not fit in one comment; lower WRAP")
        current.append(line)
        before = fence
        fence, depth = fence_state(line, fence, depth)
        if before is None and fence is not None:
            opener = line
    if current:
        pieces.append(current)
    return pieces


def is_subsequence(needle, haystack):
    position = 0
    for line in needle:
        try:
            position = haystack.index(line, position) + 1
        except ValueError:
            return False, line
    return True, None


def main():
    parser = argparse.ArgumentParser(description=__doc__.split("\n\n")[0])
    parser.add_argument("--proof", required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--pr-body")
    parser.add_argument("--images")
    parser.add_argument("--links")
    parser.add_argument("--root")
    parser.add_argument("--sha", default="unknown")
    parser.add_argument("--limit", type=int, default=65536)
    args = parser.parse_args()

    with open(args.proof, encoding="utf-8") as handle:
        report = handle.read().replace("\r\n", "\n").strip("\n")
    if BEGIN not in report:
        report = BEGIN + "\n" + report + "\n" + END
    report = report[report.index(BEGIN):report.index(END) + len(END)]
    if args.root:
        report = report.replace(args.root.rstrip("/"), "<repo root>")
    report, missing = rewrite_images(report, load_images(args.images))
    if missing:
        fail(3, "local images without an uploaded URL: " + ", ".join(sorted(set(missing))))

    before, after = "", ""
    if args.pr_body:
        with open(args.pr_body, encoding="utf-8") as handle:
            current = handle.read().replace("\r\n", "\n")
        if BEGIN in current and END in current:
            before = current[:current.index(BEGIN)]
            after = current[current.index(END) + len(END):]
        else:
            before = current.rstrip("\n") + "\n\n" if current.strip() else ""

    source = wrap(report.split("\n"))
    parts = segments(source)
    runs = sum(1 for kind, _ in parts if kind == "run")
    limit = args.limit - MARGIN
    pointer_reserve = 600
    text_size = sum(size(lines) for kind, lines in parts if kind == "text")
    room = limit - glen(before) - glen(after) - text_size - pointer_reserve * runs
    if room < 0:
        fail(5, "the PR text outside the evidence blocks is over the limit; shorten the narrative")

    used, full = 0, False
    kept, overflow = set(), []
    for kind, run in parts:
        if kind != "run":
            continue
        for unit in run:
            if not full and used + size(unit) <= room:
                kept.add(id(unit))
                used += size(unit)
            else:
                full = True
                overflow.append(unit)

    header_reserve = 120
    comments, current, home = [], [], {}
    for unit in overflow:
        for piece in chunk(unit, limit - header_reserve):
            if current and size(current) + size(piece) > limit - header_reserve:
                comments.append(current)
                current = []
            current += piece
            home.setdefault(id(unit), []).append(len(comments) + 2)
    if current:
        comments.append(current)

    total = len(comments) + 1
    links = load_links(args.links)
    body_lines, expected = [], []
    for kind, lines in parts:
        if kind == "text":
            body_lines += lines
            expected += lines
            continue
        moved = [u for u in lines if id(u) not in kept]
        for unit in lines:
            if id(unit) in kept:
                body_lines += unit
                expected += unit
        if moved:
            numbers = [n for u in moved for n in home[id(u)]]
            body_lines += ["", pointer([unit_name(u) for u in moved], min(numbers), max(numbers), total, links), ""]
    body = before + "\n".join(body_lines) + after
    if not body.endswith("\n"):
        body += "\n"

    rendered = []
    for number, lines in enumerate(comments, 2):
        text = "<!-- mean-qa:evidence %d/%d sha=%s -->\n## QA evidence %d/%d\n\n" % (number, total, args.sha, number, total)
        rendered.append(text + "\n".join(lines) + "\n")

    ok, line = is_subsequence(expected, body.split("\n"))
    if ok:
        ok, line = is_subsequence([l for u in overflow for l in u], "\n".join(rendered).split("\n"))
    if not ok:
        fail(6, "report line missing from the output: %r" % line[:120])
    for name, text in [("body", body)] + [("comment %d" % n, t) for n, t in enumerate(rendered, 2)]:
        if glen(text) > args.limit:
            fail(7, "%s is %d characters, over the %d limit" % (name, glen(text), args.limit))

    os.makedirs(args.out, exist_ok=True)
    for stale in glob.glob(os.path.join(args.out, "comment-[0-9][0-9].md")):
        os.remove(stale)
    with open(os.path.join(args.out, "body.md"), "w", encoding="utf-8") as handle:
        handle.write(body)
    print("body.md\t%d chars\t%d blocks" % (glen(body), len(kept)))
    for number, text in enumerate(rendered, 2):
        name = "comment-%02d.md" % number
        with open(os.path.join(args.out, name), "w", encoding="utf-8") as handle:
            handle.write(text)
        print("%s\t%d chars" % (name, glen(text)))


if __name__ == "__main__":
    main()
