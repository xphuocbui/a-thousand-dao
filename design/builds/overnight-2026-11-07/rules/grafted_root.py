"""The Transplant (Di Căn): a root cut from a corpse, paid from its own purity.

Asked for with "graft": {"element": "moc", "purity": p} on a side. Optional keys, with defaults:
  "purity_per_cost": 1.0   purity spent per full share of cost (an art of cost 0.25 spends 0.25)
  "more_per_purity": 0.5   L2 points on arts naming the element, per purity point
  "sector_l1": 0           unscaled L1 points those arts hold in the element's sector
  "fever_below": 40        under this purity each such art also costs health
  "fever_per_point": 0.001 share of maximum health per firing, per point under fever_below
  "floor": 10              below this the root is dead: such arts cannot fire
  "donor": 60              purity of the cultivator fought. On a knockout win the root is fed; a flight,
                           stalemate or loss feeds nothing. Printed on a "donor" line
  "take_share": 0.25       purity gained = round(take_share x donor)
  "clock": {"donor": 50, "hold": 45, "world": 1875, "decades": 90}
                           prints the decades table: rejection each decade is 6 + donors eaten so
                           far (keys "rejection", "per_donor"); donors are taken whenever purity
                           would fall under "hold", until "world" holders are gone

An art with "element" equal to the graft's pays only (1 - purity / 100) of its cost in linh lực. The
root pays the rest out of its own purity, and the fight keeps a running total. The sector scale is
0.5 + purity / 100. Both are read once at compile, so purity spent in a fight weakens the next
fight, not this one (compile runs once, Combat rule 2). A "graft" line prints purity at the start
and end. A "clock" table is arithmetic on the rule, printed here so the sheet's numbers can be
reproduced from a saved file. It does not touch the fight.

--without grafted_root removes the rule, so those arts pay linh lực and lose the purity bonus.
"""


def install(f):
    Base = f.Side
    original_resolve = f.resolve_art
    original_report = f.report_result
    state = {}

    def scale(p):
        return 0.5 + p / 100.0

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            g = spec.get("graft")
            self.graft_left = None
            if not g:
                return
            self.graft_left = float(g["purity"])
            state["left"] = self.graft_left
            p = g["purity"]
            bonus = [g.get("sector_l1", 0) * scale(p), g.get("more_per_purity", 0.5) * p, 0, 0, 0]
            for art in self.arts:
                if art.get("element") != g["element"]:
                    continue
                art["x"] = [a + b for a, b in zip(art.get("x", [0] * 5), bonus)]
                art["graft_cost"] = art.get("cost_share", 0) * p / 100.0
                art["cost_share"] = art.get("cost_share", 0) * (1 - p / 100.0)
                under = max(0.0, g.get("fever_below", 40) - p)
                if under:
                    art["body_cost_share"] = under * g.get("fever_per_point", 0.001)
                if p < g.get("floor", 10):
                    art["stock_left"] = 0

    def resolve_art(att, dfn, art, t, gap):
        if art.get("graft_cost"):
            g = att.spec["graft"]
            att.graft_left -= art["graft_cost"] * g.get("purity_per_cost", 1.0)
            state["left"] = att.graft_left
        return original_resolve(att, dfn, art, t, gap)

    def report_result(res, build):
        original_report(res, build)
        g = build.get("graft")
        if g:
            print("graft\t%s\tpurity %g at the start\t%.2f at the end\tspent %.2f" % (
                g["element"], g["purity"], res["a"].graft_left, g["purity"] - res["a"].graft_left))
            spent = g["purity"] - res["a"].graft_left
            if "donor" in g:
                if res["end"] == "knockout" and res["winner"] == res["a"].name:
                    gain = round(g.get("take_share", 0.25) * g["donor"])
                    print("donor\ttaken: purity %g, +%d\tnet of this fight %+.2f" % (g["donor"], gain, gain - spent))
                else:
                    print("donor\tnone: %s\tnet of this fight %+.2f" % (res["end"], -spent))
            if "clock" in g:
                clock(g)

    def clock(g):
        c = g["clock"]
        p, eaten, gain = float(g["purity"]), 0, round(g.get("take_share", 0.25) * c["donor"])
        print("clock	decade	rejection	donors this decade	donors in all	purity")
        for d in range(1, c["decades"] + 1):
            p -= c.get("rejection", 6) + eaten * c.get("per_donor", 1)
            took = 0
            while p < c["hold"] and eaten < c["world"]:
                p = min(100.0, p + gain)
                eaten += 1
                took += 1
            if d % 10 == 0 or d <= 3 or eaten >= c["world"]:
                print("clock	%d	%d	%d	%d	%.0f" % (
                    d, c.get("rejection", 6) + (eaten - took) * c.get("per_donor", 1), took, eaten, p))
            if eaten >= c["world"]:
                print("clock	world out of donors at decade %d" % d)
                return

    f.Side = Side
    f.resolve_art = resolve_art
    f.report_result = report_result
