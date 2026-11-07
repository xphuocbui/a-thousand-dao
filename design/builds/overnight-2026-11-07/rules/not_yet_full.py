"""The Not-Yet-Full: what you have eaten counts as cultivation in a fight. List after escape.

"eaten": {"tally": 300, "power": 32000}
    Eaten Power. The side's fight unit reads power_base[realm] + power, so health, linh lực and every hit
    scale by it, with no cap (fight_unit_exponent bounds it). Realm, suppression and slots do not move.
"bite": {"share": 0.10, "floor": 0.25}
    Clean Kill. Printed after a knockout win over the enemy: share x the victim's power_base x
    (floor + (1 - floor) x the health share the victim still had when the last instant began). A flight,
    a draw or a stalemate gives nothing, as for capability #9.
"held_at_table": 0.2
    Held at Table. A single hit of yours that deals at least this share of the target's maximum health
    breaks an open escape channel. The art's cost, cooldown and stock stay spent, and no roll is made.
    Slow Wound does not hide the blow: the size is read before the ledger takes it.

Printed: eaten, bite, meal, channels_broken. --without not_yet_full skips all of it.
--without eaten removes only the power, and --without held_at_table only the channel break.
"""


def install(f):
    side_init, strike, report_result = f.Side.__init__, f.strike, f.report_result

    def init(self, spec, name):
        side_init(self, spec, name)
        self.broken = 0
        e = spec.get("eaten")
        if e:
            u = (f.K["power_base"][self.r] + e["power"]) ** f.K["fight_unit_exponent"]
            ratio = u / self.u
            self.u = u
            for key in ("health_max", "qi_max", "health", "qi_cap", "qi"):
                setattr(self, key, getattr(self, key) * ratio)
            self.health_at_instant = self.health

    def hit(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        dealt = strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        share = att.spec.get("held_at_table")
        if share and getattr(dfn, "esc_end", None) is not None and dealt >= share * dfn.health_max:
            dfn.esc_end = None
            att.broken += 1
        return dealt

    def report(res, build):
        report_result(res, build)
        a, b = res["a"], res["b"]
        e = a.spec.get("eaten")
        if e:
            print("eaten\ttally %d\tpower %.0f\tfight unit %.1f, realm alone %.1f" % (
                e["tally"], e["power"], a.u, f.fight_unit(a.r)))
        if a.broken:
            print("channels_broken\t%d" % a.broken)
        bite = a.spec.get("bite")
        if bite:
            if res["winner"] == a.name and res["end"] == "knockout":
                last = min(1.0, max(b.health_at_instant, 0.0) / b.health_max)
                fresh = bite["floor"] + (1 - bite["floor"]) * last
                print("bite\t%.0f power\tfreshness %.2f\tvictim had %.0f%% health at the last instant" % (
                    bite["share"] * f.K["power_base"][b.r] * fresh, fresh, 100 * last))
                print("meal\teaten")
            else:
                print("meal\tnothing: %s" % res["end"])

    f.Side.__init__ = init
    f.strike, f.report_result = hit, report
