"""Water Table (Thủy Mạch), Pour (Khuynh), Scraping the Well, Dry Neighbour and Rich Seam.

Water Table, asked for with "water_table": {"share": 0.4}. Of the linh lực a target's
ward pays for this side's hit, this side gains that share, up to its own maximum.
What a full pool cannot hold is lost.

Pour, an art with "pour": {"keep": 0.35} and cost_share 0. It pays everything above that
share of maximum linh lực at the moment it resolves, and its coefficient is the art lint's
maximum for what was paid and its authored cooldown: 1 + 12 x paid + 0.25 x (cooldown - 1).

Scraping the Well, asked for with "scrape_share": 1.0. When a target's pool cannot pay all
the drain a drain ward asks for this side's hit, that share of the unpaid linh lực lands on
its health instead, past body guard. The ward stays what it is: pass and drain are read as usual.

Rush Order (Cản Đơn, from The Full Price), an art with "rush": true. Its first firing comes
at half its effective cooldown. The price is written into its cost_share in the fight file.

A guard {"pool_lead": true} is true while this side's linh lực share is at or above the
other side's. A conditional_mods "per": "enemy_pool_excess_pct" reads how much larger the
other side's maximum linh lực is than this side's, in percent, and never below 0.
"""


def install(f):
    original_ward = f.apply_ward
    original_resolve = f.resolve_art
    original_guard = f.guard_true
    original_scale = f.scale_value

    def apply_ward(dfn, att, d, kind):
        before = dfn.qi
        leak = original_ward(dfn, att, d, kind)
        scrape = att.spec.get("scrape_share", 0)
        terms = dfn.ward_terms(kind) if scrape else None
        if terms and terms[0] in ("drain", "default"):
            unpaid = max(d * (1 - terms[1]) * terms[2] - (before - dfn.qi), 0.0) * scrape
            if unpaid > 0:
                dfn.health -= unpaid
                dfn.dmg_taken_instant += unpaid
                f.add_dmg(att, "scraped", unpaid)
        wt = att.spec.get("water_table")
        if wt:
            got = (before - dfn.qi) * wt["share"]
            take = min(got, max(att.qi_cap - att.qi, 0.0))
            att.qi += take
            f.add_dmg(att, "drawn(linh luc)", take)
            if got > take:
                att.note("water_table_clipped_by_full_pool")
        return leak

    def resolve_art(att, dfn, art, t, gap):
        pour = art.get("pour")
        if not pour:
            return original_resolve(att, dfn, art, t, gap)
        paid = max(att.qi - pour["keep"] * att.qi_max, 0.0)
        att.qi -= paid
        share = paid / att.qi_max
        f.add_dmg(att, "poured(linh luc)", paid)
        fired = dict(art)
        fired["c_art"] = f.art_lint_max(share, art["cooldown"])
        return original_resolve(att, dfn, fired, t, gap)

    def guard_true(g, own, enemy, t):
        if g and g.get("pool_lead"):
            return own.qi / own.qi_max >= enemy.qi / enemy.qi_max - 1e-12
        return original_guard(g, own, enemy, t)

    def scale_value(c, att, dfn, t):
        if c.get("per") == "enemy_pool_excess_pct":
            return c.get("points_per", 0) * max(100.0 * (dfn.qi_max / att.qi_max - 1), 0.0)
        return original_scale(c, att, dfn, t)

    class Side(f.Side):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            for art in self.arts:
                if art.get("rush"):
                    art["ready"] = art["cd_ms"] // 2

    f.Side = Side
    f.apply_ward = apply_ward
    f.resolve_art = resolve_art
    f.guard_true = guard_true
    f.scale_value = scale_value
