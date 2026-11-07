"""Rush Order. +50 % price: an art's first firing comes at half its effective cooldown.
Asked for per art with "rush": true. List it after stone_payment. Later firings run on
the normal timer at the normal price.
"""


def install(f):
    Base = f.Side
    fee = getattr(f, "stone_fee", lambda art: 1.0)

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            for art in self.arts:
                if art.get("rush"):
                    art["ready"] = art["cd_ms"] // 2

    f.Side = Side
    f.stone_fee = lambda art: fee(art) * (1.5 if art.get("rush") and not art["fired"] else 1.0)
