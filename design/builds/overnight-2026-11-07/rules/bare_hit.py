"""Bare hit (vô danh kích), Struck Name's rule.

Asked for with "bare_hit": true. The side's art hits have no kind: any ward reads them
on default_ward_pass and default_ward_drain, whatever spell it wears, with ws and we
still applied, and body guard reads them at the qi share. Arts are written as qi in the
file, so --without bare_hit runs the same arts with a kind.
"""


def install(f):
    original_strike = f.strike
    original_terms = f.Side.ward_terms

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        if att.spec.get("bare_hit") and channel.startswith("art"):
            kind = "none"
        return original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)

    def ward_terms(self, kind):
        if kind != "none":
            return original_terms(self, kind)
        worn = self.ward
        if worn.get("model", "drain") != "default":
            self.ward = dict(worn, **{"pass": f.K["default_ward_pass"], "drain": f.K["default_ward_drain"]})
        try:
            return original_terms(self, kind)
        finally:
            self.ward = worn

    f.strike = strike
    f.Side.ward_terms = ward_terms
