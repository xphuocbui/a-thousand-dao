"""Panel enemy only: every body or qi hit that lands costs the attacker a fixed amount.

Fight field on the side that has thorns: "thorns_c": 0.25, a coefficient of that side's
own fight unit, so it scales with the realm and not with the hit. A hit of any size pays
the same, which is what makes many small hits dangerous. Based on the catalogue's Thorned
Skin (Kinh Bì), whose note says it punishes fast hitters. It is a test enemy, not a
proposal: the catalogue's version returns a share of what body guard stops.
"""


def install(f):
    original = f.strike

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        dealt = original(att, dfn, t, gap, c, kind, extra, channel, crit=crit, direct=direct)
        thorns = dfn.spec.get("thorns_c", 0)  # only a side that asks for it
        if thorns:
            back = dfn.u * dfn.stage * thorns
            att.health -= back
            att.dmg_taken_instant += back
            f.add_dmg(dfn, "thorns", back)
        return dealt

    f.strike = strike
