#!/usr/bin/env python3
"""Preview, or archive and remove exact regular files without basename collisions.

Requires quiescent files: not a concurrency-safe or crash-consistent snapshot.
Only --apply mutates. Each run has a private, unique directory and restore map.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import stat
import sys
import tempfile


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def identity(path):
    s = path.lstat()
    if not stat.S_ISREG(s.st_mode):
        raise ValueError(f"not a regular file (symlinks refused): {path}")
    return (s.st_dev, s.st_ino, s.st_size, s.st_mtime_ns, s.st_ctime_ns)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("backup_parent", type=Path)
    parser.add_argument("files", type=Path, nargs="+")
    parser.add_argument("--apply", action="store_true")
    args = parser.parse_args()
    parent = args.backup_parent
    if not parent.is_absolute() or not parent.is_dir() or parent.is_symlink():
        raise ValueError("backup parent must be an explicit existing absolute directory")
    records = []
    seen = set()
    for source in args.files:
        if not source.is_absolute():
            raise ValueError(f"source must be absolute: {source}")
        original = source.absolute()
        snapshot = identity(original)
        canonical = original.resolve()
        if canonical in seen:
            raise ValueError(f"duplicate source: {source}")
        seen.add(canonical)
        records.append({"original": str(canonical), "slot": f"item-{len(records):06d}",
                        "identity": snapshot, "sha256": digest(canonical)})
    if not args.apply:
        print(json.dumps({"mode": "preview", "files": records}, indent=2))
        return
    archive = Path(tempfile.mkdtemp(prefix="safe-trash-", dir=parent))
    print(f"Recovery directory: {archive}", flush=True)
    # The map is written and flushed before any source removal. It is deliberately not
    # a completion claim: recover only slots whose payload and digest verify.
    with (archive / "restore-map.json").open("x") as stream:
        json.dump({"files": records}, stream, indent=2)
        stream.flush()
        os.fsync(stream.fileno())
    for record in records:
        source = Path(record["original"])
        if identity(source) != record["identity"] or digest(source) != record["sha256"]:
            raise ValueError(f"source changed; stop and inspect archive: {source}")
        slot = archive / record["slot"]
        slot.mkdir(mode=0o700)
        payload = slot / "payload"
        # Copy before removal: an I/O error leaves the original in place.
        with source.open("rb") as reader, payload.open("xb") as writer:
            shutil.copyfileobj(reader, writer)
            writer.flush()
            os.fsync(writer.fileno())
        shutil.copystat(source, payload)
        if digest(payload) != record["sha256"]:
            raise ValueError(f"archive verification failed; original retained: {source}")
        if identity(source) != record["identity"] or digest(source) != record["sha256"]:
            raise ValueError(f"source changed during copy; original retained: {source}")
        source.unlink()
    print(f"Archived {len(records)} files. Restore only into absent original paths; "
          "verify each payload against restore-map.json first.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError) as exc:
        print(f"safe-trash: FAILED: {exc}; preserve any recovery directory and "
              "inspect completed slots and remaining sources before retrying.", file=sys.stderr)
        sys.exit(1)
