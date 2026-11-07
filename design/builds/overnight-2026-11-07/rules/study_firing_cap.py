"""STUDY ONLY, not a proposal and not in the game (kit-options.md). Option D: a shared firing limit.

Asked for with "study_firing_cap": {"n": 3}, on BOTH sides. List it last.
A side fires at most n arts between one pulse and the next, whatever kind, counted like trig_cap and
reset at the pulse. An art refused by the limit stays ready and fires in slot order when the next pulse
opens the count, exactly as an art whose guard is false. The basic attack and the companion do not count.
Built as a compile-time guard on every art, so it needs no timeline change.
"""


def install(f):
    original = f.guard_true
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            s = spec.get("study_firing_cap")
            if not s:
                return
            self.study_cap = s.get("n", 3)
            for art in self.arts:
                g = dict(art.get("guard") or {})
                g["study_cap"] = True
                art["guard"] = g
            print("study_firing_cap\t%s\tn %d\tarts gated %d" % (self.name, self.study_cap, len(self.arts)))

    def guard_true(g, own, enemy, t):
        if g and g.get("study_cap"):
            beat = f.ms(f.K["pulse_interval"])
            start = (t // beat) * beat
            used = sum(1 for a in own.arts for x in a["fired"] if x >= start)
            if used >= own.study_cap:
                return False
            g = {k: v for k, v in g.items() if k != "study_cap"} or None
        return original(g, own, enemy, t)

    f.Side = Side
    f.guard_true = guard_true
