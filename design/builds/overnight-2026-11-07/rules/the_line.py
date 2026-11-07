"""The Heir: an estate passed down a family line. List after slow_wound, best_plan, not_yet_full, lit_wick.

"estate": {"generation": 2, "tally": 301, "power": 16000, "keep": 0.5, "book": [{"creditor": "...", "share": 4838}]}
    What was handed down. Eaten Power reads "power" and "tally", as not_yet_full's "eaten". Removing this
    one key (--without estate) leaves a plain disciple: no power, no book, no lien, no dread, no masks.
"meets": 0
    This enemy is entry 0 of the book. Its share stands in the ledger at t = 0, as best_plan's "book_owed".
"lien": {"per": 0.05, "cap": 0.30}
    Lien. Each living entry reserves that share of maximum linh luc, by the calculator's reserve_share.
"dread": {"tally_by_realm": [5, 20, 50, 200, 1000], "exit": {"e_art": 0.7, "cost_share": 0.05, "cooldown": 1}}
    The Name Arrives First. An enemy of a realm whose number the tally has reached, and who knows the
    name, carries one more art: an exit, priced in linh luc, that stays shut until a blow of theirs falls
    on a mask. Then they know what they have struck, and the art is ready at once. Its roll is
    Formulas I, run by escape.py. An enemy with "knows_the_name": false, through enemy_overrides,
    carries nothing. List escape before this plug-in.
"masks": {"count": 1, "mark": 0.08}
    Family Face. Each mask stops one body or qi hit whose size, before ward and guard, is at least mark x
    maximum health: it deals nothing and drains nothing. Each fight, all are worn again.
Guard {"owing": true}: true while this side has a ledger standing. Promissory Paper waits on it, so a
    sheet is not spent on a stranger. Put it with "time_above": 0, which the calculator reads as true.
"last_fight": true
    Prints estate_out: what the next generation starts with. power is keep x (power + this fight's bite),
    the tally gains a knockout, masks gain the head who has died, and a met creditor who fell leaves
    the book.
--without the_line skips all of it; --without dread, lien or masks removes one key.
"""


SHUT = 10 ** 9


def install(f):
    side_init, strike, run_fight, report_result = f.Side.__init__, f.strike, f.run_fight, f.report_result
    original_guard = f.guard_true

    def fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        est = a_spec.get("estate")
        if est:
            a_spec = dict(a_spec, eaten={"tally": est["tally"], "power": est["power"]})
            lien = a_spec.get("lien")
            if lien:
                a_spec["reserve_share"] = min(lien["cap"], lien["per"] * len(est.get("book", [])))
            if a_spec.get("meets") is not None:
                a_spec["book_owed"] = est["book"][a_spec["meets"]]["share"]
            dread = a_spec.get("dread")
            if dread and b_spec.get("knows_the_name", True):
                r = b_spec["realm"] if isinstance(b_spec["realm"], int) else f.REALMS.index(b_spec["realm"])
                if est["tally"] >= dread["tally_by_realm"][r]:
                    e = dread["exit"]
                    b_spec = dict(b_spec, arts=list(b_spec.get("arts", [])) + [
                        {"id": "dread_exit", "dread_exit": True, "cost_share": e["cost_share"],
                         "cooldown": e["cooldown"], "escape": {"e_art": e["e_art"]}}])
        return run_fight(a_spec, b_spec, gap_a, gap_b, record)

    def init(self, spec, name):
        side_init(self, spec, name)
        for art in self.arts:
            if art.get("dread_exit"):
                art["ready"] = SHUT
        if spec.get("book_owed"):  # after Eaten Power has set the size, so a share reads the real maximum
            self.ledger = spec["book_owed"] / 100.0 * self.health_max
        m = spec.get("masks")
        self.masks_left = m["count"] if m and spec.get("estate") else 0
        self.masks_fallen = 0

    def hit(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        if dfn.__dict__.get("masks_left", 0) > 0:
            x = f.layer_points(att, dfn, t, extra, channel)
            size = att.u * att.stage * c * f.multiplier(x, skip_l5=(channel == "trigger")) \
                * (att.crit_ev if crit else 1.0) * f.supp(gap, att.pierce)
            if size >= dfn.spec["masks"]["mark"] * dfn.health_max - 1e-9:
                dfn.masks_left -= 1
                dfn.masks_fallen += 1
                for art in att.arts:
                    if art.get("dread_exit") and art["ready"] == SHUT:
                        art["ready"] = t + 1
                return 0.0
        return strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)

    def guard_true(g, own, enemy, t):
        ok = original_guard(g, own, enemy, t)
        if ok and g and g.get("owing"):
            return own.__dict__.get("ledger", 0.0) > 0
        return ok

    def report(res, build):
        report_result(res, build)
        a, b = res["a"], res["b"]
        est = a.spec.get("estate")
        if not est:
            return
        print("estate_in\tgeneration %d\ttally %d\tpower %.0f\tbook %d\tlien %.0f%%\tdread %s\tmasks %d, %d fell" % (
            est["generation"], est["tally"], est["power"], len(est.get("book", [])),
            100 * a.spec.get("reserve_share", 0), b.spec.get("dread_curse", {}).get("pass_raise", 0),
            a.spec.get("masks", {}).get("count", 0), a.masks_fallen))
        if not a.spec.get("last_fight"):
            return
        won = res["end"] == "knockout" and res["winner"] == a.name
        bite = 0.0
        if won and a.spec.get("bite"):
            last = min(1.0, max(b.health_at_instant, 0.0) / b.health_max)
            s = a.spec["bite"]
            bite = s["share"] * f.K["power_base"][b.r] * (s["floor"] + (1 - s["floor"]) * last)
        book = list(est.get("book", []))
        if won and a.spec.get("meets") is not None:
            book.pop(a.spec["meets"])
        print("estate_out\tgeneration %d\ttally %d\tpower %.0f\tbook %d: %s\tmasks %d" % (
            est["generation"] + 1, est["tally"] + (1 if won else 0), est.get("keep", 0.5) * (est["power"] + bite),
            len(book), ", ".join("%s %d%%" % (e["creditor"], e["share"]) for e in book),
            a.spec.get("masks", {}).get("count", 0) + 1))

    f.run_fight, f.Side.__init__, f.strike, f.report_result = fight, init, hit, report
    f.guard_true = guard_true
