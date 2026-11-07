"""Paid in Advance (Tiên Phó). A talisman's linh luc went into the paper at the desk.

Asked for with "paid_in_advance": true. An art with "talisman": true keeps its authored
cost_share for the art lint and pays none of it when it fires. Its stock is its only price.
"""


def install(f):
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            if spec.get("paid_in_advance"):
                for art in self.arts:
                    if art.get("talisman"):
                        art["ink_share"] = art.get("cost_share", 0)
                        art["cost_share"] = 0

    f.Side = Side
