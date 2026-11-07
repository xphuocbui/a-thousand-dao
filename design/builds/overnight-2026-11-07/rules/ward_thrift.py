"""Thrift (Tiet Dung), a Redirect: a share of your ward efficiency also lowers art cost.

Asked for with "ward_thrift": share in a fight file. cost_red rises by
share * we / 100, inside the same 0.5 ceiling as art_cost_pct (Combat Formulas E).
Read once at compile, so it never changes in a fight.
"""


def install(f):
    original = f.Side.__init__

    def init(self, spec, name):
        original(self, spec, name)
        share = spec.get("ward_thrift", 0)
        if share and self.ward.get("model", "drain") != "off":
            we = max(0, min(self.ward.get("we", 0), f.K["ward_cap"]))
            self.cost_red = min(self.cost_red + share * we / 100.0, 0.5)

    f.Side.__init__ = init
