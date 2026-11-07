"""Exact Change. Overkill on a winning hit refunds that share of the art's price, up to
"exact_change_max" of it. Asked for with "exact_change_max": 0.5. Needs stone_payment,
which pays the refund only if this side won.
"""


def install(f):
    strike = f.strike

    def hit(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        before = dfn.health
        dealt = strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        limit = att.spec.get("exact_change_max", 0)
        if limit and channel.startswith("art:") and before > 0 >= dfn.health and dealt > 0:
            over = (dealt - before) / dealt
            att.refund = min(over, limit) * att.prices.get(channel[4:], 0.0)
        return dealt

    f.strike = hit
