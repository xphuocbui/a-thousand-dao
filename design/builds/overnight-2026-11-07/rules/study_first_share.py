"""STUDY ONLY, not a proposal and not in the game (kit-options.md). Option C: an earlier first firing.

Asked for with "study_first_share": {"s": 0.25}, on BOTH sides. List it after anything that sets a timer.
An art with an effective cooldown above 1 s first fires at 1 s + s x (cd_eff - 1), not at cd_eff.
s 1 is today's rule. Arts at 1 s or less are untouched, so a 1 s art still fires first at 1 s.
Later firings run on the normal cooldown. An art whose timer another rule already set is left alone.
"""


def install(f):
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            s = spec.get("study_first_share")
            if not s:
                return
            share = s.get("s", 0.25)
            one = f.ms(1)
            n = 0
            for art in self.arts:
                if art["cd_ms"] <= one or art["ready"] != art["cd_ms"]:
                    continue
                art["ready"] = one + int(round(share * (art["cd_ms"] - one)))
                n += 1
            print("study_first_share\t%s\ts %.2f\tarts moved %d" % (self.name, share, n))

    f.Side = Side
