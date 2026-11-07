"""STUDY ONLY, not a proposal and not in the game (kit-options.md). Option B: a cost floor.

Asked for with "study_cost_floor": {"p": 0.12, "buys_c": false}, on BOTH sides.
Floor: cost >= max(0.04, p / cooldown), on the authored cooldown, stopping at Formulas E's 0.25.
An art under the floor is raised to it at compile time. A body-paid art raises body_cost_share by
half as much, since the lint counts it double.

"buys_c" false is a surcharge: the raised cost buys no coefficient, so the art keeps its c_art.
"buys_c" true leaves the lint as it stands: the art also gains 12 x the added cost, which is what
an author would take if only the floor changed.
"""


def install(f):
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            s = spec.get("study_cost_floor")
            if not s:
                return
            n = 0
            for art in self.arts:
                if art.get("soul_pct") or art.get("c_art", 0) <= 0:
                    continue
                paid = art.get("cost_share", 0) + 2 * art.get("body_cost_share", 0)
                floor = min(0.25, max(0.04, s.get("p", 0.12) / art["cooldown"]))
                if paid >= floor - 1e-9:
                    continue
                add = floor - paid
                if art.get("body_cost_share") and not art.get("cost_share"):
                    art["body_cost_share"] += add / 2.0
                else:
                    art["cost_share"] = art.get("cost_share", 0) + add
                if s.get("buys_c"):
                    art["c_art"] += f.K["art_coef_per_cost"] * add
                n += 1
            print("study_cost_floor\t%s\tp %.3f\tbuys_c %s\tarts raised %d" % (
                self.name, s.get("p", 0.12), bool(s.get("buys_c")), n))

    f.Side = Side
