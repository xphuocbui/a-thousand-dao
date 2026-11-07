"""Spare Mind (Dư Thần): art speed from thần thức left free.

Asked for with "thought": {"held": 1400, "used": 680} and "spare_mind": 3, the speed
in % per 1 % of thần thức free. Added to any art_speed_pct on the side.
"""


def install(f):
    original = f.Side.__init__

    def init(self, spec, name):
        if spec.get("spare_mind"):
            th = spec["thought"]
            free = 100.0 * (th["held"] - th["used"]) / th["held"]
            spec = dict(spec, art_speed_pct=spec.get("art_speed_pct", 0) + spec["spare_mind"] * free)
        original(self, spec, name)

    f.Side.__init__ = init
