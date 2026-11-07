"""The Cicada Root (Thiền Căn): a wait paid in buried seasons.

Asked for with "buried": {"purity": p, "seasons": n} on a side, and "buried": true on one art.
Optional key, shown with its default:
  "seconds_per_season_purity": 0.5   seconds of authored cooldown one buried season pays, per purity point

paid = seconds_per_season_purity x purity x seasons. The marked art starts the fight with its
timer already run down by paid, but never below cooldown_min, so it fires at 0.5 s if paid covers
its authored cooldown, and otherwise later by the difference. The wait is paid, never deleted: the art's record
keeps its full cooldown, the lint reads that cooldown, and a "buried" line prints the seconds paid.
An art that has fired stays on that whole cooldown, so it fires once.

"spent": true under "buried" says this is a later fight of the same waking year: nothing is paid.
--without buried_years removes the payment, so the art waits its whole cooldown.
"""


def install(f):
    Base = f.Side
    original_report = f.report_result

    def paid_seconds(b):
        if b.get("spent"):
            return 0.0
        return b.get("seconds_per_season_purity", 0.5) * b["purity"] * b["seasons"]

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            b = spec.get("buried")
            if b:
                for art in self.arts:
                    if art.get("buried"):
                        art["ready"] = max(f.ms(f.K["cooldown_min"]), art["cd_ms"] - f.ms(paid_seconds(b)))

    def report_result(res, build):
        original_report(res, build)
        b = build.get("buried")
        if b:
            for art in build.get("arts", []):
                if art.get("buried"):
                    print("buried\t%s\tauthored %g s\tpaid %g s\towed %g s" % (
                        art["id"], art["cooldown"], paid_seconds(b),
                        max(0, art["cooldown"] - paid_seconds(b))))

    f.Side = Side
    f.report_result = report_result
