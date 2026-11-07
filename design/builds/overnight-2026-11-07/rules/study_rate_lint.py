"""STUDY ONLY, not a proposal and not in the game (kit-options.md). Option E: a curved lint.

Asked for with "study_rate_lint": {"p": 0.75}, on BOTH sides.
New ceiling: c_art <= min(12, (1 + 12 x cost) x cooldown ^ p), replacing the linear 0.25 x (cooldown - 1).
1 s arts are unchanged. Faster arts fall and slower arts rise, so slow arts are paid for being slow, not
only fast arts charged. p 1 gives every cooldown the same coefficient a second.
Every art keeps its place under the ceiling: c_art x new ceiling / old ceiling, at compile time.
"""


def install(f):
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            s = spec.get("study_rate_lint")
            if not s:
                return
            p = s.get("p", 0.75)
            n = 0
            for art in self.arts:
                if art.get("soul_pct") or art.get("c_art", 0) <= 0:
                    continue
                cost = art.get("cost_share", 0) + 2 * art.get("body_cost_share", 0)
                cd = art["cooldown"]
                old = f.art_lint_max(cost, cd)
                new = min(12.0, (f.K["basic_coef"] + f.K["art_coef_per_cost"] * cost) * cd ** p)
                art["c_art"] = art["c_art"] * new / old
                n += 1
            print("study_rate_lint\t%s\tp %.2f\tarts repriced %d" % (self.name, p, n))

    f.Side = Side
