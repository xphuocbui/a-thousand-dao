"""A basic attack in parts, the shape arts already have (Hollow Palm, Không Chưởng).

Asked for with "basic_parts": [{"share": 0.5, "kind": "body"}, {"share": 0.5, "kind": "qi"}].
Each part is struck in order with the basic attack's own points. "Keeping its body tags":
the points do not change with the part's kind.
"""


def install(f):
    original = f.strike

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        parts = att.spec.get("basic_parts") if channel == "basic" else None
        if not parts:
            return original(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        return sum(original(att, dfn, t, gap, c * p["share"], p["kind"], extra, channel, crit, direct)
                   for p in parts)

    f.strike = strike
