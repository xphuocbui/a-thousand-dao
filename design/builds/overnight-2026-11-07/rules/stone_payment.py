"""Seal of Full Payment. Arts and an Indemnity Ward are paid in spirit stones, not linh luc.

Asked for with "stone_payment": {"purse": 80000, "R": 5000, "rate": 2, "premium_share": 0.02}.
An art's "cost_share" is then its stone share, priced at
rate * R * share^2 * fee * (1 - art_cost). No stones, no art. A share above 1 cannot be
bought without the priced_above_sea rule. A per_pulse ward pays premium_share * R *
(1 - art_cost) in stones at t = 0 and each pulse, and fails when the purse cannot pay.
Prints the bill. fee comes from f.stone_fee, which rush_order wraps. A refund is whatever
exact_change left in side.refund, paid only if this side won.
"""


def install(f):
    Base, guard_true, pulse, report_result = f.Side, f.guard_true, f.pulse, f.report_result
    f.stone_fee = lambda art: 1.0

    def price(side, art):
        st = side.spec["stone_payment"]
        return (st["rate"] * st["R"] * art["stone_share"] ** 2 * f.stone_fee(art)
                * (1 - side.cost_red))

    def premium(side):
        st = side.spec["stone_payment"]
        return st.get("premium_share", 0) * st["R"] * (1 - side.cost_red)

    def pay_premium(side):
        due = premium(side)
        if side.ward.get("model") != "per_pulse" or due <= 0:
            return True
        if side.purse < due:
            return False
        side.purse -= due
        side.stones_premium += due
        return True

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            st = spec.get("stone_payment")
            if not st:
                return
            self.purse = self.purse_start = float(st["purse"])
            self.stones_arts = self.stones_premium = 0.0
            self.prices = {}
            for art in self.arts:
                art["stone_share"], art["cost_share"] = art.get("cost_share", 0), 0
                art["guard"] = {"stone_art": art, "inner": art.get("guard")}
                if art["stone_share"] > getattr(f, "stone_share_cap", 1.0):
                    art["stock_left"] = 0
            if not pay_premium(self):
                self.ward = {"model": "off"}

    def guard(g, own, enemy, t):
        if not (g and "stone_art" in g):
            return guard_true(g, own, enemy, t)
        art = g["stone_art"]
        if art.get("stock_left") == 0 or not f.guard_true(g["inner"], own, enemy, t):
            return False
        due = price(own, art)
        if own.purse < due:
            return False
        own.purse -= due
        own.stones_arts += due
        own.prices[art["id"]] = due
        return True

    def tick(side, enemy, gap_of_enemy, t):
        pulse(side, enemy, gap_of_enemy, t)
        if side.spec.get("stone_payment"):
            side.ward_paid = pay_premium(side)

    def report(res, build):
        report_result(res, build)
        a = res["a"]
        if a.spec.get("stone_payment"):
            refund = getattr(a, "refund", 0.0) if res["winner"] == a.name else 0.0
            print("stones\tarts %.0f\tpremium %.0f\tgross %.0f\trefund %.0f\tnet %.0f\tpurse_left %.0f" % (
                a.stones_arts, a.stones_premium, a.stones_arts + a.stones_premium, refund,
                a.stones_arts + a.stones_premium - refund, a.purse + refund))

    f.Side, f.guard_true, f.pulse, f.report_result = Side, guard, tick, report
