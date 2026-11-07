"""Unyielding Breath. Once per fight, a killing blow leaves you at 1 health.
Asked for with "unyielding_breath": true. Reads hits and pulses, so the ledger's payment
counts as a blow. List it after slow_wound.
"""


def install(f):
    strike, pulse = f.strike, f.pulse

    def hold(side):
        if side.health <= 0 and side.spec.get("unyielding_breath") and not getattr(side, "breath_used", False):
            side.breath_used = True
            side.dmg_taken_instant -= 1.0 - side.health
            side.health = 1.0

    def hit(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        dealt = strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        hold(dfn)
        return dealt

    def tick(side, enemy, gap_of_enemy, t):
        pulse(side, enemy, gap_of_enemy, t)
        hold(side)

    f.strike, f.pulse = hit, tick
