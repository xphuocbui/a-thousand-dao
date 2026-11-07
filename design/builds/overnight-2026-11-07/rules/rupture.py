"""Rupture (Lancing). An art with "rupture_share" takes that share of the target's maximum
health per 100 % of Surfeit, at most "rupture_cap", plus Deep Abscess ("deep_share" per
100 % of clipped Surfeit, at most deep_share), past ward, guard, evade and suppression,
divided by boss_pool_mult. The target's pool and Surfeit go to 0. "rupture_heal" is
Self-Cure, a share of the caster's maximum health.

Adds the guard {"who": "enemy", "surfeit_above": 0.6}. Keep "pool": "qi", "above": 2 in that
guard so that it stays false when this plug-in is skipped.
"""


def install(f):
    guard_true, resolve_art, report_result = f.guard_true, f.resolve_art, f.report_result

    def guard(g, own, enemy, t):
        if g and "surfeit_above" in g:
            side = own if g.get("who", "own") == "own" else enemy
            return getattr(side, "surfeit", 0.0) / side.qi_max >= g["surfeit_above"] - 1e-12
        return guard_true(g, own, enemy, t)

    def resolve(att, dfn, art, t, gap):
        share = art.get("rupture_share")
        if share:
            surfeit = getattr(dfn, "surfeit", 0.0)
            clip = getattr(dfn, "surfeit_clip", 0.0)
            deep = art.get("deep_share", 0)
            deep = min(deep, deep * clip / dfn.qi_max)
            loss = min(share * surfeit / dfn.qi_max, art.get("rupture_cap", 0.25)) + deep
            hl = loss * dfn.health_max / dfn.boss
            dfn.health -= hl
            dfn.dmg_taken_instant += hl
            f.add_dmg(att, "rupture", hl)
            att.direct += hl
            dfn.ruptures = getattr(dfn, "ruptures", []) + [(t, hl / dfn.health_max)]
            dfn.qi = dfn.surfeit = dfn.surfeit_clip = 0.0
            att.health = min(att.health_max, att.health + art.get("rupture_heal", 0) * att.health_max)
        return resolve_art(att, dfn, art, t, gap)

    def report(res, build):
        report_result(res, build)
        rows = getattr(res["b"], "ruptures", [])
        print("ruptures\t%d\t%s" % (len(rows), ", ".join(
            "t=%.2f %.0f%% of health" % (x[0] / 1000.0, 100 * x[1]) for x in rows)))

    f.guard_true, f.resolve_art, f.report_result = guard, resolve, report
