"""Round-two behavioral helper regressions; all mutations use isolated fixtures."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SKILLS = Path(__file__).resolve().parents[2]
ENV = dict(os.environ, GIT_CONFIG_COUNT="2", GIT_CONFIG_KEY_0="core.hooksPath",
           GIT_CONFIG_VALUE_0="/dev/null", GIT_CONFIG_KEY_1="commit.gpgSign",
           GIT_CONFIG_VALUE_1="false", TOOLSHED_PR_BODY_CONFIRMED="0")


class Regressions(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix="round2-regression-")
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name).resolve()

    def run_cmd(self, *args, cwd=None):
        return subprocess.run([str(x) for x in args], cwd=cwd, env=ENV,
                              capture_output=True, text=True, timeout=30)

    def trash(self, *files, apply=False):
        parent = self.root / "backups"
        parent.mkdir(exist_ok=True)
        args = [sys.executable, SKILLS / "safe-ops/scripts/safe-trash.py", parent, *files]
        if apply:
            args.append("--apply")
        return self.run_cmd(*args)

    def file(self, rel, content="fixture"):
        path = self.root / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content)
        return path

    def test_trash_dry_run_is_read_only(self):
        source = self.file("a/notes.txt")
        r = self.trash(source)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue(source.exists())
        self.assertEqual(list((self.root / "backups").iterdir()), [])

    def test_trash_duplicate_basenames_restore_map_and_hashes(self):
        sources = [self.file("a/notes.txt", "first"), self.file("b/notes.txt", "second")]
        r = self.trash(*sources, apply=True)
        self.assertEqual(r.returncode, 0, r.stderr)
        archive, = (self.root / "backups").iterdir()
        self.assertEqual(archive.stat().st_mode & 0o777, 0o700)
        records = json.loads((archive / "restore-map.json").read_text())["files"]
        self.assertEqual(len(records), 2)
        recovered = []
        for record in records:
            payload = archive / record["slot"] / "payload"
            self.assertEqual(hashlib.sha256(payload.read_bytes()).hexdigest(), record["sha256"])
            recovered.append((record["original"], payload.read_text()))
        self.assertEqual(recovered, [(str(sources[0]), "first"), (str(sources[1]), "second")])
        self.assertFalse(any(p.exists() for p in sources))

    def test_trash_second_run_never_overwrites_prior_archive(self):
        source = self.file("notes.txt", "first")
        self.assertEqual(self.trash(source, apply=True).returncode, 0)
        source.write_text("second")
        self.assertEqual(self.trash(source, apply=True).returncode, 0)
        archives = list((self.root / "backups").iterdir())
        self.assertEqual(len(archives), 2)
        self.assertEqual({(p / "item-000000/payload").read_text() for p in archives},
                         {"first", "second"})

    def test_trash_invalid_source_preflight_preserves_all(self):
        source = self.file("ok")
        for invalid in [self.root / "absent", self.root]:
            r = self.trash(source, invalid, apply=True)
            self.assertNotEqual(r.returncode, 0)
            self.assertTrue(source.exists())
            self.assertEqual(list((self.root / "backups").iterdir()), [])

    def test_trash_refuses_symlink_and_duplicate_target(self):
        source = self.file("ok")
        link = self.root / "link"
        link.symlink_to(source)
        for files in [(link,), (source, source)]:
            self.assertNotEqual(self.trash(*files, apply=True).returncode, 0)
        self.assertTrue(source.exists())
        self.assertEqual(list((self.root / "backups").iterdir()), [])



if __name__ == "__main__":
    unittest.main(verbosity=2)
