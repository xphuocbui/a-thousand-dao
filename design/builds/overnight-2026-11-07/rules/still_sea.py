"""Still Sea. The Slow Wound cap falls by "still_sea" times your linh luc share.
Asked for with "still_sea": 0.55. List it after slow_wound.
"""


def install(f):
    factor = getattr(f, "ledger_cap_factor", lambda side: 1.0)
    f.ledger_cap_factor = lambda side: factor(side) * (
        1 - side.spec.get("still_sea", 0) * side.qi / side.qi_max)
