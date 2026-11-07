"""The Worst Root (Độn Căn): hits too dull for a ward to catch.

Asked for with "turbid": {"purity": p} on a side. Optional keys, shown with their defaults:
  "parts": 5                  elements held: every art hit and basic attack splits into this many
                              equal parts, each struck and warded alone (Combat rule 6 allows 2)
  "line_per_purity": 0.0005   the line, as a share of the target's maximum health, per purity point
  "dull_per_purity": 0.5      L1 points the holder loses per purity point

A part whose size, before the ward, is under the line skips the ward: nothing is blocked and the
target's linh lực is not touched. A part at or over the line meets the ward as usual. Evade and
body guard still apply to every part. Nothing else in the fight changes.

"birth_odds": n on the turbid record prints a "birth" block: n Fated births drawn with seed 1 from
Spiritual Roots Formulas A, the share that qualify, and the share at or above given purities. It is
arithmetic on the rule, printed so the sheet's odds can be reproduced. It does not touch the fight.

--without turbid_root removes both halves, the line and the L1 loss, because they are one root.
The sheet's plain-root variant is the fair swap: it also rescales the tree to the plain sectors.
"""


import random


def install(f):
    original_ward = f.apply_ward
    original_strike = f.strike
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            t = spec.get("turbid")
            if t:
                self.x[0] -= t.get("dull_per_purity", 0.5) * t["purity"]

    def apply_ward(dfn, att, d, kind):
        t = att.spec.get("turbid")
        if t:
            line = t["purity"] * t.get("line_per_purity", 0.0005) * dfn.health_max
            if d < line:
                att.note("turbid_under_line")
                return d
            att.note("turbid_over_line")
        return original_ward(dfn, att, d, kind)

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        tb = att.spec.get("turbid")
        n = tb.get("parts", 5) if tb else 1
        if n <= 1 or not (channel.startswith("art:") or channel == "basic"):
            return original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        return sum(original_strike(att, dfn, t, gap, c / float(n), kind, extra, channel, crit, direct)
                   for _ in range(n))

    original_report = f.report_result

    def report_result(res, build):
        original_report(res, build)
        t = build.get("turbid")
        if t and t.get("birth_odds"):
            birth(t["birth_odds"])

    def birth(n):
        rng = random.Random(1)
        weights = [45, 32, 15, 6.5, 1.5]
        held = {3: 0, 4: 0, 5: 0}
        at_least = {30: 0, 45: 0, 60: 0}
        for _ in range(n):
            count = rng.choices([1, 2, 3, 4, 5], weights)[0]
            if count < 3:
                continue
            ps = [min(100, max(10, round(rng.gauss(50, 20)))) for _ in range(count)]
            if max(ps) >= 50:
                continue
            held[count] += 1
            purity = 100 - 2 * sum(ps) / float(count)
            for floor in at_least:
                at_least[floor] += purity >= floor
        print("birth	%d Fated births	qualify %.3f %%	by elements 3: %d, 4: %d, 5: %d" % (
            n, 100.0 * sum(held.values()) / n, held[3], held[4], held[5]))
        for floor in sorted(at_least):
            print("birth	purity %d or more	%d lives	%.4f %%" % (floor, at_least[floor], 100.0 * at_least[floor] / n))

    f.Side = Side
    f.apply_ward = apply_ward
    f.strike = strike
    f.report_result = report_result
