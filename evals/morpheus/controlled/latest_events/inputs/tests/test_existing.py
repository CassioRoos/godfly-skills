import unittest

from events import distinct_keys


class ExistingHelperTests(unittest.TestCase):
    def test_empty(self):
        self.assertEqual(distinct_keys([]), [])

    def test_first_appearance_order(self):
        self.assertEqual(
            distinct_keys([{"key": "b"}, {"key": "a"}, {"key": "b"}]),
            ["b", "a"],
        )

    def test_generator(self):
        self.assertEqual(distinct_keys({"key": key} for key in ["x", "x", "y"]),
                         ["x", "y"])


if __name__ == "__main__":
    unittest.main()
