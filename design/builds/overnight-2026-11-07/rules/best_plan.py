"""The Best Plan: a ledger you walk away from. List after slow_wound and escape.

Art keys
  "sets_slow_wound": 1.0   Promissory Paper. When this art fires, Slow Wound applies to this side at that
                           share for the rest of the fight. Before it fires, hits land as usual.
  "lift": true             Goat in Passing. Each firing lifts one carried thing. Kept on a Fled result,
                           dropped otherwise. Printed as "lifted".
Side keys, each read only for the side that has it
  "cold_feet": true        Cold Feet. Escape arts first fire at cooldown_min.
  "beneath_notice": 0.05   Beneath Notice. Against a pursuer above you the realm term is +this per realm,
                           not -escape_realm_step. Below or level, unchanged.
  "terror": 0.15           Terror. Adds to the escape bonus while the ledger exceeds your health.
  "full_sleeve": {"per_doubling": 0.02, "base": 4, "carried": 40}
                           Full Sleeve. Adds per_doubling to the escape bonus for each doubling of talismans
                           carried above base. "carried" counts paper in the bag, not only in slots.
  "folded_corner": true    Folded Corner. The first failed roll of a fight puts its talisman back in stock.
  "skipped_bill": true     Skipped Bill. On a Fled result the ledger is not paid in years. It goes in the
                           book against the enemy. Without it, Years Owed is charged, and if that reaches
                           "years_left" the side dies on the road: health is shown as 0.
  "book_owed": 1400        A rematch. This much (% of maximum health) stands in the ledger at t = 0. With no
                           Slow Wound running at a pulse, the whole of it lands at that pulse.
Printed: book, life_after, lifted. --without best_plan skips all of it.
"""
import math


def install(f):
    side_init, resolve_art = f.Side.__init__, f.resolve_art
    terms, on_roll, run_fight = f.escape_terms, f.escape_on_roll, f.run_fight
    pulse, report_result = f.pulse, f.report_result

    def init(self, spec, name):
        side_init(self, spec, name)
        self.lifted = 0
        self.corner_used = False
        if spec.get("cold_feet"):
            for a in self.arts:
                if a.get("escape"):
                    a["ready"] = min(a["ready"], f.ms(f.K["cooldown_min"]))
        if spec.get("book_owed"):
            self.ledger = spec["book_owed"] / 100.0 * self.health_max

    def resolve(att, dfn, art, t, gap):
        resolve_art(att, dfn, art, t, gap)
        if art.get("sets_slow_wound"):
            att.spec = dict(att.spec, slow_wound_share=art["sets_slow_wound"])
        if art.get("lift"):
            att.lifted += 1

    def escape_terms(esc, pursuer, art, t):
        v = terms(esc, pursuer, art, t)
        d = esc.spec
        if d.get("beneath_notice") and pursuer.r > esc.r:
            v["realm"] = d["beneath_notice"] * (pursuer.r - esc.r)
        if d.get("terror") and getattr(esc, "ledger", 0.0) > esc.health:
            v["bonus"] += d["terror"]
        s = d.get("full_sleeve")
        if s and s["carried"] > s["base"]:
            v["bonus"] += s["per_doubling"] * math.log(s["carried"] / float(s["base"]), 2)
        return v

    def roll(side, art, p, ok, t):
        on_roll(side, art, p, ok, t)
        if not ok and side.spec.get("folded_corner") and not side.corner_used \
                and art.get("stock_left") is not None:
            side.corner_used = True
            art["stock_left"] += 1

    def tick(side, enemy, gap_of_enemy, t):
        pulse(side, enemy, gap_of_enemy, t)
        if side.spec.get("book_owed") and not side.spec.get("slow_wound_share"):
            owed = getattr(side, "ledger", 0.0)
            side.health -= owed
            side.dmg_taken_instant += owed
            side.ledger = 0.0

    def fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        res = run_fight(a_spec, b_spec, gap_a, gap_b, record)
        a = res["a"]
        if a.spec.get("lifespan_base") and a.health > 0:
            owed = getattr(a, "ledger", 0.0) / a.health_max
            years = owed * 0.01 * a.spec["lifespan_base"]
            if res["end"] == "flight" and a.spec.get("skipped_bill"):
                res["book"] = owed
            elif a.spec.get("years_left") and years >= a.spec["years_left"]:
                a.health = 0.0
                res["life_after"] = "dead on the road: %.1f years owed, %.1f left" % (
                    years, a.spec["years_left"])
            elif years > 0:
                res["life_after"] = "alive: %.1f years owed" % years
        return res

    def report(res, build):
        report_result(res, build)
        a = res["a"]
        if "book" in res:
            print("book\t%.0f%% of maximum health written against %s, no years paid"
                  % (100 * res["book"], res["b"].name))
        if res.get("life_after"):
            print("life_after\t%s" % res["life_after"])
        if any(x.get("lift") for x in a.arts):
            kept = res["end"] == "flight" and a.health > 0
            print("lifted\t%d\t%s" % (a.lifted, "kept" if kept else "dropped"))

    f.Side.__init__ = init
    f.resolve_art, f.escape_terms = resolve, escape_terms
    f.escape_on_roll, f.pulse, f.run_fight, f.report_result = roll, tick, fight, report
