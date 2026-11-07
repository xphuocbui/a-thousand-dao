"""Withheld Hand. Your basic attack does not fire. Each time it would, its coefficient
is added to your longest-cooldown art until that art fires.

Asked for with "withheld_hand": true. Skipping this plug-in gives the basic attack back.
In hit order an art comes before the basic attack, so a cut at t = 40 holds 39.
"""


def install(f):
    strike, resolve_art, report_result = f.strike, f.resolve_art, f.report_result

    def hit(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        if channel == "basic" and att.spec.get("withheld_hand"):
            att.withheld = getattr(att, "withheld", 0.0) + c
            return 0.0
        return strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)

    def resolve(att, dfn, art, t, gap):
        if att.spec.get("withheld_hand") and art is max(att.arts, key=lambda a: a["cd_ms"]):
            held = getattr(att, "withheld", 0.0)
            att.withheld = 0.0
            att.cut_held = held
            art = dict(art, c_art=art.get("c_art", 0) + held)
        return resolve_art(att, dfn, art, t, gap)

    def report(res, build):
        report_result(res, build)
        if res["a"].spec.get("withheld_hand"):
            print("withheld_in_last_cut\t%.1f\tenemy maximum health %.0f" % (
                getattr(res["a"], "cut_held", 0.0), res["b"].health_max))

    f.strike, f.resolve_art, f.report_result = hit, resolve, report
