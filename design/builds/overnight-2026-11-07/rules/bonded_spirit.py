"""Bonded Spirit (Linh Khế), the catalogue keystone: the companion carries your art speed.

Asked for with "bonded_spirit": true. The companion's timer is basic_cooldown divided by
(1 + art speed), stopping at cooldown_min, the same rule as an art's (Formulas A2). Its first
hit comes one timer in. The status half of the keystone is not used here.
"""


def install(f):
    original_init = f.Side.__init__
    original_strike = f.strike

    def interval(side):
        cd = max(f.K["cooldown_min"], f.K["basic_cooldown"] / (1 + side.art_speed / 100.0))
        return f.ms(cd)

    def init(self, spec, name):
        original_init(self, spec, name)
        if spec.get("bonded_spirit") and self.companion:
            self.comp_next = interval(self)

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        out = original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        if channel == "companion" and att.spec.get("bonded_spirit"):
            # run_fight adds basic_cooldown after this call
            att.comp_next = t + interval(att) - f.ms(f.K["basic_cooldown"])
        return out

    f.Side.__init__ = init
    f.strike = strike
