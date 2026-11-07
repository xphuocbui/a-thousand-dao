"""The Mortal: Mortal Body (Phàm Thân), Plain Blow (Phàm Kích) and Callus Returns (Kiển Hoàn).

Asked for with "mortal": {"power": 10, "plain_blow": 8}.
  A side below Qi Refining. Its fight unit reads power instead of its realm's power base. The calculator
  has no realm under Qi Refining, so the file says luyen_khi and this replaces the size. It has no linh
  luc at all: pool and cap are 0, so it has no ward, pays for nothing, and regenerates nothing.
  Plain Blow: a single hit on this side removes at most plain_blow before body guard, a fixed number
  of health points whatever its size. Ticks and soul arts do not pass through strike, so they are not
  limited.
"callus": {"after": 80, "a_b": 1.0}
  Callus Returns. Once that many seasons have left the wick (lit_wick.py), the side's body guard base
  rises by a_b for the rest of the fight. --without callus removes the key.
Printed: mortal. --without mortal_body skips all of it.
The self-hit is not here. It is the merged Turned Hand, run by pratfall.py with "clip".
"""


def install(f):
    side_init, strike, report_result = f.Side.__init__, f.strike, f.report_result

    def init(self, spec, name):
        side_init(self, spec, name)
        m = spec.get("mortal")
        if m:
            u = m["power"] ** f.K["fight_unit_exponent"]
            ratio = u / self.u
            self.u = u
            self.health_max *= ratio
            self.health = self.health_max * spec.get("start_health", 1.0)
            self.health_at_instant = self.health
            self.qi_max, self.qi_cap, self.qi = 1.0, 0.0, 0.0
            self.ward = {"model": "off"}

    def hit(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        cal = dfn.spec.get("callus")
        if cal and not dfn.__dict__.get("calloused") and dfn.spec.get("wick"):
            gone = dfn.spec["wick"]["seasons"] - dfn.__dict__.get("seasons_left", dfn.spec["wick"]["seasons"])
            if gone >= cal["after"]:
                dfn.calloused = True
                dfn.a_b += cal["a_b"]
        before = dfn.health
        dealt = strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        m = dfn.spec.get("mortal")
        if m:
            most = m["plain_blow"] * dfn.guard_factor(kind)
            if dealt > most:
                back = dealt - most
                dfn.health = before - most
                dfn.dmg_taken_instant -= back
                att.dmg[channel] = att.dmg.get(channel, 0.0) - back
                dealt = most
        return dealt

    def report(res, build):
        report_result(res, build)
        a = res["a"]
        m = a.spec.get("mortal")
        if m:
            print("mortal\tfight unit %.2f\thealth %.1f\tplain blow %.1f after guard" % (
                a.u, a.health_max, m["plain_blow"] * a.guard_factor("body")))
        if a.__dict__.get("stood"):
            print("stood\t%d" % a.stood)

    f.Side.__init__, f.strike, f.report_result = init, hit, report
