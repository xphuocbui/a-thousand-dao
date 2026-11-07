"""What It Brings Home (Tha Mồi): each companion hit that lands refunds linh lực.

Asked for with "comp_refund_share": a share of maximum linh lực per companion hit.
"""


def install(f):
    original = f.strike

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        out = original(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        share = att.spec.get("comp_refund_share", 0)
        if channel == "companion" and share:
            att.qi = min(att.qi_cap, att.qi + share * att.qi_max)
        return out

    f.strike = strike
