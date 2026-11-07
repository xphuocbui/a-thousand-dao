"""Gorged (Bão Lôi). A conditional_mods "per": "health_restored_pct" reads the share of your maximum
health you have restored in this fight, in percent, up to the entry's "cap". Each wave of a
tribulation is a new fight, so it starts at 0.

Counts only health really restored: Still Water's clipped regeneration and the health a Fed hit's
clipped refund gives (element_tags). List it after still_water and element_tags. Only a side with an
entry that names the scale reads it, and nothing here changes a pool.
"""


def install(f):
    original_scale = f.scale_value
    original_ward = f.apply_ward

    def apply_ward(dfn, att, d, kind):
        before = dfn.health
        leak = original_ward(dfn, att, d, kind)
        if dfn.health > before:
            dfn.fed_healed = getattr(dfn, "fed_healed", 0.0) + dfn.health - before
        return leak

    def scale_value(c, att, dfn, t):
        if c.get("per") == "health_restored_pct":
            got = getattr(att, "still_water_healed", 0.0) + getattr(att, "fed_healed", 0.0)
            return min(c.get("points_per", 0) * 100.0 * got / att.health_max, c.get("cap", 1e9))
        return original_scale(c, att, dfn, t)

    f.apply_ward = apply_ward
    f.scale_value = scale_value
