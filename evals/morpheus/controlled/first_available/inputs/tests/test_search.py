import unittest

from search import first_at_or_after


class SearchTests(unittest.TestCase):
    def test_empty(self):
        self.assertIsNone(first_at_or_after([], 0))

    def test_first_index_is_valid(self):
        self.assertEqual(first_at_or_after([2, 4], 2), 0)

    def test_duplicates(self):
        self.assertEqual(first_at_or_after([1, 3, 3, 5], 3), 1)

    def test_between_values(self):
        self.assertEqual(first_at_or_after([1, 4], 2), 1)

    def test_above_maximum(self):
        self.assertIsNone(first_at_or_after([1, 4], 5))


if __name__ == "__main__":
    unittest.main()
