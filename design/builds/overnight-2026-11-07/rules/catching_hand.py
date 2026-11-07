"""Catching Hand (Tiếp Thủ) and Returned Force (Hoàn Lực).

Asked for with "catch_per_empty_slot": 1. Each empty art slot catches one enemy art
hit per fight: the art fires and pays, and its hit deals nothing and drains nothing.
Soul arts skip the catch, an art with no hit has nothing to catch, and a basic attack,
companion or tick is not an art hit. A caught art's status or curse still lands unless
"swaddling": true is set.

"returned_force": 0.5 adds that share of a caught art's c_art to the next basic attack.
List this plug-in after basic_split so the added coefficient is split with the rest.
"""


def install(f):
    original_resolve = f.resolve_art
    original_strike = f.strike
    original_report = f.report_result

    def catches_left(side):
        if "catches_left" not in side.__dict__:
            slots = f.K["slots_by_realm"][side.r] + side.spec.get("bonus_slots", 0)
            side.catches_left = side.spec.get("catch_per_empty_slot", 0) * max(0, slots - len(side.arts))
        return side.catches_left

    def resolve_art(att, dfn, art, t, gap):
        if art.get("c_art", 0) > 0 and not art.get("soul_pct") and catches_left(dfn) > 0:
            dfn.catches_left -= 1
            dfn.__dict__.setdefault("caught", []).append((t, art["id"]))
            dfn.returned = dfn.__dict__.get("returned", 0.0) + dfn.spec.get("returned_force", 0) * art["c_art"]
            art = dict(art, c_art=0)
            if dfn.spec.get("swaddling"):
                art.pop("applies", None)
                art.pop("curse", None)
        return original_resolve(att, dfn, art, t, gap)

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        if channel == "basic" and att.__dict__.get("returned"):
            c += att.returned
            att.returned = 0.0
        return original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)

    def report_result(res, build):
        original_report(res, build)
        a = res["a"]
        if a.spec.get("catch_per_empty_slot"):
            caught = a.__dict__.get("caught", [])
            print("caught\t%d\t%s" % (len(caught), ", ".join(
                "%s %.2f" % (i, x / 1000.0) for x, i in caught)))

    f.resolve_art = resolve_art
    f.strike = strike
    f.report_result = report_result
