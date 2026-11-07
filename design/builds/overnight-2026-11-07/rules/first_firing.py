"""First firing comes sooner (catalogue row, Speed): the opening timer only.

Asked for with "first_firing_pct": 50, the sum of the rows taken. Every art's first firing
comes that share sooner, never before cooldown_min (0.5 s): the row shortens a wait and does
not pass the rule that stops every other timer. Later firings run on the normal cooldown.
An art with "rush" keeps Rush Order's timer. List it after anything that sets a timer.
"""


def install(f):
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            pct = spec.get("first_firing_pct", 0)
            if pct:
                floor = f.ms(f.K["cooldown_min"])
                for art in self.arts:
                    if not art.get("rush"):
                        art["ready"] = max(floor, int(art["ready"] * (1 - pct / 100.0)))

    f.Side = Side
