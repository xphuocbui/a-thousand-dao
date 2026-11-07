"""Companion attack speed, the catalogue's plain row (+1.5 small, +10 notable). Not a keystone.

Asked for with "companion_speed_pct": points. The companion's timer is basic_cooldown divided by
(1 + points / 100), stopping at cooldown_min, the same rule as an art's (Formulas A2). Its first
hit comes one timer in. Bonded Spirit is a different piece: it lends art speed to the companion.
This key is the companion's own, and the file exists only because the calculator has no field for it.
"""


def install(f):
    original_init = f.Side.__init__
    original_strike = f.strike

    def interval(side):
        speed = side.spec.get("companion_speed_pct", 0)
        return f.ms(max(f.K["cooldown_min"], f.K["basic_cooldown"] / (1 + speed / 100.0)))

    def init(self, spec, name):
        original_init(self, spec, name)
        if spec.get("companion_speed_pct") and self.companion:
            self.comp_next = interval(self)

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        out = original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        if channel == "companion" and att.spec.get("companion_speed_pct"):
            # run_fight adds basic_cooldown after this call
            att.comp_next = t + interval(att) - f.ms(f.K["basic_cooldown"])
        return out

    f.Side.__init__ = init
    f.strike = strike
