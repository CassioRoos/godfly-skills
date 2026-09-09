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

    def repo(self, ignored=False):
        repo = self.root / "repo"
        repo.mkdir()
        def git(*args):
            result = self.run_cmd("git", *args, cwd=repo)
            self.assertEqual(result.returncode, 0, result.stderr)
        git("init", "-q", "-b", "main")
        git("config", "user.name", "Regression fixture")
        git("config", "user.email", "fixture@example.invalid")
        (repo / "README.md").write_text("fixture\n")
        if ignored:
            (repo / ".gitignore").write_text("docs/work/\n")
        git("add", ".")
        git("commit", "-qm", "init")
        r = self.run_cmd("sh", SKILLS / "toolshed/scripts/seed.sh", "probe", "fixture", cwd=repo)
        self.assertEqual(r.returncode, 0, r.stderr)
        state = repo / "docs/work/probe/STATE.md"
        state.write_text(state.read_text().replace("_(not yet written)_", "Read README. Synthetic isolated fixture."))
        return repo, git

    def close_case(self, home=None, ignored=False, flags=(), prepare=None):
        repo, git = self.repo(ignored)
        if prepare:
            prepare(repo)
        q = repo / "docs/work/probe/questions.md"
        if home is not None:
            q.write_text(q.read_text() + "\n### Q-001 — deferred\n- **Status:** parked\n"
                         "- **Question:** revisit boundary\n- **Wake-up trigger:** next release\n" + home + "\n")
        git("add", ".")
        git("commit", "-qm", "final fixture")
        return self.run_cmd("sh", SKILLS / "toolshed/scripts/assert-close.sh", "probe", *flags, cwd=repo)

    def test_empty_home_rejected(self):
        self.assertNotEqual(self.close_case("- **Home:**").returncode, 0)

    def test_mortal_home_rejected(self):
        self.assertNotEqual(self.close_case("- **Home:** docs/work/probe/STATE.md").returncode, 0)

    def test_unrelated_url_does_not_count(self):
        self.assertNotEqual(self.close_case("- **Evidence:** https://example.invalid/evidence").returncode, 0)

    def test_missing_file_rejected(self):
        self.assertNotEqual(self.close_case("- **Home:** docs/adr/missing.md").returncode, 0)

    def test_valid_permanent_file_accepted(self):
        def prepare(repo):
            (repo / "docs/adr").mkdir()
            (repo / "docs/adr/a.md").write_text("# Deferred\nQ-001 boundary: next release\n")
        r = self.close_case("- **Home:** [question](docs/adr/a.md#deferred)", prepare=prepare)
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_symlink_into_mortal_tree_rejected(self):
        def prepare(repo):
            (repo / "durable.md").symlink_to(repo / "docs/work/probe/STATE.md")
        self.assertNotEqual(self.close_case("- **Home:** durable.md", prepare=prepare).returncode, 0)

    def test_remote_requires_explicit_readback_attestation(self):
        self.assertNotEqual(self.close_case("- **Home:** https://example.invalid/ticket/1").returncode, 0)

    def test_remote_readback_flag_clears_only_home_gate(self):
        r = self.close_case("- **Home:** https://example.invalid/ticket/1",
                            flags=("--remote-homes-confirmed",))
        self.assertEqual(r.returncode, 0, r.stderr)

    def test_local_ignored_without_archive_attestation_fails(self):
        self.assertNotEqual(self.close_case(ignored=True).returncode, 0)

    def test_local_ignored_with_final_pr_attestation_passes(self):
        r = self.close_case(ignored=True, flags=("--pr-body-confirmed",))
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("local-only", r.stderr)

    def test_archive_attestation_does_not_waive_invalid_home(self):
        r = self.close_case("- **Home:**", ignored=True, flags=("--pr-body-confirmed",))
        self.assertNotEqual(r.returncode, 0)

    def test_tracked_folder_with_ignored_evidence_fails(self):
        def prepare(repo):
            (repo / ".gitignore").write_text("*.private-evidence\n")
            (repo / "docs/work/probe/result.private-evidence").write_text("final synthetic evidence")
        r = self.close_case(prepare=prepare)
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("ignored files exist", r.stderr)

    def test_inline_comments_cannot_hide_proposed_decision(self):
        def prepare(repo):
            (repo / "docs/work/probe/decisions.md").write_text(
                "### D-001\n- **Status:** <!-- origin -->proposed<!-- note -->\n")
        r = self.close_case(prepare=prepare)
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("proposed", r.stderr)

    def test_inline_comments_cannot_hide_open_question(self):
        def prepare(repo):
            (repo / "docs/work/probe/questions.md").write_text(
                "### Q-001\n- **Status:** <!-- origin -->open<!-- note -->\n")
        r = self.close_case(prepare=prepare)
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("open questions remain", r.stderr)

    def test_reversed_comment_markers_fail_closed(self):
        def prepare(repo):
            (repo / "docs/work/probe/questions.md").write_text(
                "-->\n### Q-001\n- **Status:** open\n<!--\n")
        self.assertNotEqual(self.close_case(prepare=prepare).returncode, 0)

    def test_home_parser_boundaries(self):
        path = SKILLS / "toolshed/scripts/validate-homes.py"
        spec = importlib.util.spec_from_file_location("homes", path)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        for value in ["TBD", "../escape.md", "file:///etc/passwd", "https://user:pass@example.invalid/t",
                      "https://", "https://example.invalid/has space", "<ticket>", "docs/work/sibling/q.md"]:
            with self.subTest(value=value):
                self.assertIsNotNone(mod.check_home(value, self.root, True))


if __name__ == "__main__":
    unittest.main(verbosity=2)
