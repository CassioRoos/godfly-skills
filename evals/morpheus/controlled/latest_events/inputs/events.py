"""Pure in-memory helpers for the fictional Lantern event viewer."""


def distinct_keys(events):
    """Return keys in the order in which they first appeared."""
    return list(dict.fromkeys(event["key"] for event in events))


def latest_events(events):
    """Return the latest complete record for each key; see README.md."""
    raise NotImplementedError("latest_events has not been implemented")
