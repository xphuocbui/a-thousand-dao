"""Purse Weight. +"purse_weight" L3 points per full doubling of carried stones above R,
read at the start of a fight, on every channel. List it after stone_payment.
"""
import math


def install(f):
    Base = f.Side

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            points = spec.get("purse_weight", 0)
            if points and self.purse_start > spec["stone_payment"]["R"]:
                self.x[2] += points * math.floor(math.log2(self.purse_start / spec["stone_payment"]["R"]))

    f.Side = Side
