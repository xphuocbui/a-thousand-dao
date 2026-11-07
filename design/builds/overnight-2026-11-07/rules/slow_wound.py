"""Slow Wound. "slow_wound_share" of a hit's dealt damage enters a ledger, not your health.
Each pulse, after ticks, the ledger pays at most dot_pool_cap of maximum health, times
f.ledger_cap_factor(side), which still_sea wraps. Ticks and soul arts never enter it.

Prints the ledger left as a share of maximum health. With "lifespan_base" it prints the
years that comes to: each 100 % costs 1 % of the realm's base lifespan.
"""


def install(f):
    strike, pulse, report_result = f.strike, f.pulse, f.report_result
    f.ledger_cap_factor = lambda side: 1.0

    def hit(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        dealt = strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        share = dfn.spec.get("slow_wound_share", 0)
        if share:
            held = dealt * share
            dfn.health += held
            dfn.dmg_taken_instant -= held
            dfn.ledger = getattr(dfn, "ledger", 0.0) + held
        return dealt

    def tick(side, enemy, gap_of_enemy, t):
        pulse(side, enemy, gap_of_enemy, t)
        if side.spec.get("slow_wound_share"):
            cap = f.K["dot_pool_cap"] * f.ledger_cap_factor(side) * side.health_max
            paid = min(getattr(side, "ledger", 0.0), cap)
            side.ledger = getattr(side, "ledger", 0.0) - paid
            side.health -= paid
            side.dmg_taken_instant += paid

    def report(res, build):
        report_result(res, build)
        a = res["a"]
        if a.spec.get("slow_wound_share"):
            owed = getattr(a, "ledger", 0.0) / a.health_max
            line = "ledger_left\t%.0f%% of maximum health" % (100 * owed)
            if a.spec.get("lifespan_base"):
                line += "\tyears_owed %.1f" % (owed * 0.01 * a.spec["lifespan_base"])
            print(line)

    f.strike, f.pulse, f.report_result = hit, tick, report
