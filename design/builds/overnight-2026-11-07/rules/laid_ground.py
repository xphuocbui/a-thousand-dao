"""A laid formation (Combat rule 12) and the Ground Law (Địa Luật) it carries.

Asked for with "laid_formation": true. "ground_law" names the law, which binds both sides:
  {"name": "Level Ground", "caps": {"2": 40, "3": 40, "5": 10}, "foreign_l4": 20,
   "constants": {"cooldown_min": 3.0}}
caps      points above this in that layer do not count, for both sides.
foreign_l4 the other side's L4 counts at most this: a ground holds one formation.
constants Combat constants moved for the length of this fight, for both sides.

"situation": "foreseen" (default), "ambush" or "blind", on the same side, reads Combat rule 12:
  blind    no law, own L4 falls to "ground_l4" (default 0), and every art with "laid": true is dead.
  ambush   only with "standing": true is the law up; otherwise as blind.
Also here, because they all read a laid formation and need the same switch:
  "standing_water": true (Timing)  an art with "laid": true first fires at the first pulse.
  "old_bund": c (Flat base)        adds c to the coefficient of every "laid" art that hits.
  "deep_bund": k (Overflow)        L4 points past the L4 cap add k each to the coefficient of
                                   every "laid" art that hits.
  "field_walls": p (Redirect)      formation power also counts as p ward strength and p ward
                                   efficiency, only while the formation is up.
`--without ground_law` removes only the law. `--without laid_ground` removes the whole plug-in.
"""


def live(spec):
    s = spec.get("situation", "foreseen")
    return s == "foreseen" or (s == "ambush" and spec.get("standing"))


def install(f):
    Base = f.Side
    points = f.layer_points
    run_fight = f.run_fight

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            if not spec.get("laid_formation"):
                return
            if not live(spec):
                self.x[3] = spec.get("ground_l4", 0)
                self.arts = [a for a in self.arts if not a.get("laid")]
                return
            walls = spec.get("field_walls", 0)
            if walls:
                self.ward = dict(self.ward)
                self.ward["ws"] = self.ward.get("ws", 0) + walls
                self.ward["we"] = self.ward.get("we", 0) + walls
            over = max(self.x[3] - f.K["layer_caps"][3], 0)
            add = spec.get("old_bund", 0) + spec.get("deep_bund", 0) * over
            for art in self.arts:
                if art.get("laid"):
                    if art.get("c_art", 0) > 0:
                        art["c_art"] += add
                    if spec.get("standing_water"):
                        art["ready"] = f.ms(f.K["pulse_interval"])

    def law_of(side):
        law = side.spec.get("ground_law")
        return law if law and live(side.spec) else None

    def layer_points(att, dfn, t, extra, channel):
        x = points(att, dfn, t, extra, channel)
        own, other = law_of(att), law_of(dfn)
        law = own or other
        if law:
            for layer, cap in law.get("caps", {}).items():
                i = int(layer) - 1
                x[i] = min(x[i], cap)
            if other and "foreign_l4" in other:
                x[3] = min(x[3], other["foreign_l4"])
        return x

    def fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        moved = {}
        for spec in (a_spec, b_spec):
            law = spec.get("ground_law")
            if law and live(spec):
                moved.update(law.get("constants", {}))
        old = {k: f.K[k] for k in moved}
        f.K.update(moved)
        try:
            return run_fight(a_spec, b_spec, gap_a, gap_b, record)
        finally:
            f.K.update(old)

    f.Side = Side
    f.layer_points = layer_points
    f.run_fight = fight
