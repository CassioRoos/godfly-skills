"""Search helpers for the fictional Pebble scheduler."""

from bisect import bisect_left


def first_at_or_after(values, target):
    index = bisect_left(values, target)
    return index if index < len(values) else None
