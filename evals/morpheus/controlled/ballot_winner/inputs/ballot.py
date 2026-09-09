"""Vote helpers for the fictional Acorn club."""


class TiePolicyRequired(Exception):
    pass


def winner(votes):
    if not votes:
        return None
    maximum = max(votes.values())
    tied = [name for name, count in votes.items() if count == maximum]
    if len(tied) > 1:
        raise TiePolicyRequired("Approved tie behavior has not been supplied")
    return tied[0]
