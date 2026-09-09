import unittest

from ballot import TiePolicyRequired, winner


class BallotTests(unittest.TestCase):
    def test_empty(self):
        self.assertIsNone(winner({}))

    def test_unique_winner(self):
        self.assertEqual(winner({"Birch": 2, "Ash": 4}), "Ash")

    def test_zero_is_a_valid_unique_count(self):
        self.assertEqual(winner({"Ash": 0}), "Ash")

    def test_tie_requires_missing_policy(self):
        with self.assertRaises(TiePolicyRequired):
            winner({"Birch": 4, "Ash": 4})


if __name__ == "__main__":
    unittest.main()
