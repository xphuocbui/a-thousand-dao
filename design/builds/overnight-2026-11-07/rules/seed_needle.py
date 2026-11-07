"""Seed Needle, a cut piece kept so the sheet's claim can be re-run. An art with
"feed_share" forces that share of the target's maximum into its pool; what passes the
pool's maximum is Surfeit. List it after rupture.
"""


def install(f):
    resolve_art = f.resolve_art

    def resolve(att, dfn, art, t, gap):
        share = art.get("feed_share")
        if share:
            add = share * dfn.qi_max
            fed = min(add, dfn.qi_cap - dfn.qi)
            dfn.qi += fed
            cap = att.spec.get("surfeit_cap", 1.0) * dfn.qi_max
            dfn.surfeit = min(cap, getattr(dfn, "surfeit", 0.0) + add - fed)
        return resolve_art(att, dfn, art, t, gap)

    f.resolve_art = resolve
