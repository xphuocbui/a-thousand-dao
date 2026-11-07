"""STUDY ONLY, not a proposal and not in the game (kit-options.md). Option A: a lint term below 1 s.

Asked for with "study_short_tax": {"k": 1.0}, on BOTH sides, because a lint is a rule of the game.
New ceiling: c_art <= 1 + 12 x cost + 0.25 x (cooldown - 1) - k x (1 - cooldown), for an authored
cooldown under 1 s. Nothing changes at 1 s or above. An art over the new ceiling is cut to it at
compile time. Cost reads as Formulas C does: cost_share + 2 x body_cost_share. Soul arts have no lint.
"""


def install(f):
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            s = spec.get("study_short_tax")
            if not s:
                return
            n = 0
            for art in self.arts:
                cd = art["cooldown"]
                if art.get("soul_pct") or art.get("c_art", 0) <= 0 or cd >= 1:
                    continue
                cost = art.get("cost_share", 0) + 2 * art.get("body_cost_share", 0)
                ceiling = f.art_lint_max(cost, cd) - s.get("k", 1.0) * (1 - cd)
                if art["c_art"] > ceiling:
                    art["c_art"] = ceiling
                    n += 1
            print("study_short_tax\t%s\tk %.2f\tarts cut %d" % (self.name, s.get("k", 1.0), n))

    f.Side = Side
