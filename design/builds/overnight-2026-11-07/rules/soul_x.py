"""Conditional and Per rows on x_soul.

Soul arts read no layers, so a row in conditional_mods with "channels": ["soul"] never reaches
layer_points. This reads those rows when a soul art resolves: each one whose guard is true adds its
points, plus its "per" scale, to x_soul for that art alone. Guards and "per" scales are the
calculator's own, so `--without "[id]"` removes a row as usual. A side with no "soul" row is untouched.
"""


def install(f):
    original = f.resolve_art

    def resolve_art(att, dfn, art, t, gap):
        rows = [c for c in att.conditionals if "soul" in c.get("channels", [])]
        if not art.get("soul_pct") or not rows:
            return original(att, dfn, art, t, gap)
        saved = att.x_soul
        for c in rows:
            if "guard" in c and not f.guard_true(c["guard"], att, dfn, t):
                continue
            att.x_soul += c.get("points", 0) + f.scale_value(c, att, dfn, t)
        try:
            return original(att, dfn, art, t, gap)
        finally:
            att.x_soul = saved

    f.resolve_art = resolve_art
