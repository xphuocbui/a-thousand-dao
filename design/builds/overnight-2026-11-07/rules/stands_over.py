"""Stands Over You (Hộ Chủ): when the owner goes Down, the companion stays and fights.

Asked for with "stand": {"n_body": 1.0, "guard": {...}, "share": 1.0} on a side that has a
companion. At the defeat check, a side at 0 health that has not yet stood
changes shape: its health becomes the companion's (health_units x the companion's fight unit
x n_body x share, less any wounds from Broad Back), arts and the basic attack stop, and only
the companion acts. It has no ward and no regeneration. A second 0 is a real Down.

An enemy striking a standing beast uses the gap to the beast's realm. Also adds the guard
{"standing": true}, true for a side in this state.

run_fight has no hook at the defeat check. Same device as turned_away.py: dry_at is read just
before it. It chains to any dry_at hook already installed, so it may share a fight with turned_away
or lit_wick: the plug-in listed last acts first at the defeat check.
"""


def install(f):
    original_strike = f.strike
    original_report = f.report_result
    original_guard = f.guard_true
    original_next = f.next_event
    earlier = f.Side.__dict__.get("dry_at")  # another plug-in's hook, which this one chains to

    def next_event(sides, pulse_next, t):
        now = original_next(sides, pulse_next, t)
        for s in sides:
            s.now = now
        return now

    def stand_up(s):
        st = s.spec["stand"]
        comp = s.companion
        r = f.REALMS.index(comp["realm"]) if "realm" in comp else s.r
        s.stood_at = s.__dict__.get("now", 0)
        s.standing = True
        s.stand_r = r
        s.health_max = f.K["health_units"] * f.fight_unit(r) * st.get("n_body", 1.0)
        s.health = s.health_max * st.get("share", 1.0) - s.__dict__.get("beast_wound", 0.0)
        s.n_body = st.get("n_body", 1.0)
        g = st.get("guard", {})
        s.a_b, s.t_b, s.bg_pct = g.get("a_b", 0), g.get("t_b", 0), g.get("body_guard_pct", 0)
        s.arts = []
        s.basic = {"c": 0}
        s.regen = 0
        s.curses = []
        s.statuses = []
        s.ward = {"model": "off"}

    def get_dry(self):
        if self.spec.get("stand") and self.health <= 0 and not self.__dict__.get("standing") \
                and self.companion:
            stand_up(self)
        if earlier is not None:
            return earlier.fget(self)
        return self.__dict__.get("_dry_at")

    def set_dry(self, value):
        self.__dict__["_dry_at"] = value

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        if dfn.__dict__.get("standing"):
            gap = max(0, dfn.stand_r - att.r)
        return original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)

    def guard_true(g, own, enemy, t):
        if g and g.get("standing"):
            return bool(own.__dict__.get("standing"))
        return original_guard(g, own, enemy, t)

    def report_result(res, build):
        original_report(res, build)
        a = res["a"]
        if a.__dict__.get("standing"):
            print("stood_at	%.3f s	beast health left %.0f%%" % (
                a.stood_at / 1000.0, 100 * max(a.health, 0) / a.health_max))

    f.next_event = next_event
    f.Side.dry_at = property(get_dry, set_dry)
    f.strike = strike
    f.guard_true = guard_true
    f.report_result = report_result
