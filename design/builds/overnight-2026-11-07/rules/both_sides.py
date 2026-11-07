"""Both Sides (Song Phương), a healing art effect, and the oath that pays for it.

An art with "heal_share": s restores s of maximum health when it resolves, multiplied by
(1 + "heal_pct" / 100) from the caster's file. With "both_sides": true on that side, the same share of
maximum also goes to the other side: a share, not an amount. Nothing passes maximum. A side under a
block_regen curse is restored nothing, and the other side is still restored. A heal is not a hit: it
meets no ward, guard or evade and fires no triggers.

What a side restores to itself is added to still_water_healed, the attribute rules/gorged.py reads.
"joy_weight": w (Joy of the Work, Lạc Nghiệp) adds w times the share given to the other side as well,
so Gorged reads it as health restored. Each wave of a tribulation is a new fight and starts at 0.

Prints "mended self n% enemy n%". Only a side with an art carrying heal_share is touched.
"""


def install(f):
    original_resolve = f.resolve_art
    original_report = f.report_result

    def restore(side, share):
        if any(c.get("block_regen") for c in side.curses) or side.health <= 0:
            return 0.0
        got = min(share * side.health_max, side.health_max - side.health)
        side.health += got
        return got / side.health_max

    def resolve_art(att, dfn, art, t, gap):
        original_resolve(att, dfn, art, t, gap)
        share = art.get("heal_share", 0)
        if not share:
            return None
        share *= 1 + att.spec.get("heal_pct", 0) / 100.0
        own = restore(att, share)
        other = restore(dfn, share) if att.spec.get("both_sides") else 0.0
        att.mended_self = getattr(att, "mended_self", 0.0) + own
        att.mended_enemy = getattr(att, "mended_enemy", 0.0) + other
        counted = own + att.spec.get("joy_weight", 0) * other
        att.still_water_healed = getattr(att, "still_water_healed", 0.0) + counted * att.health_max
        return None

    def report_result(res, build):
        original_report(res, build)
        a = res["a"]
        if hasattr(a, "mended_self"):
            print("mended\tself %.0f%%\tenemy %.0f%%" % (100 * a.mended_self, 100 * a.mended_enemy))

    f.resolve_art = resolve_art
    f.report_result = report_result
