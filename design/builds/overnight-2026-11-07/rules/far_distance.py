"""Far Distance (Viễn Cảnh) and the Blank (Lưu Bạch): a fight inside a painted scroll.

Asked for with "scroll": {...} on the painter's side, and "stroke": true on an art:
  "blank": 100        the paper left unpainted at the start
  "seals": [{"name": n, "takes": 12, "layer": 2, "points": 40}]  each owner's seal covers paper, and
                      adds its points to that layer (1 to 5) for every hit made inside
  "shrink": 0.012     each Blank point spent makes the target smaller: size x (1 - shrink x points)
                      for that stroke, times min(1, own divine_sense / theirs)
  "floor": 0.2        the target is never smaller than this
  "signed": {"art": id, "per": 1.0}  Signed and Dated: L2 points on that art per point of Blank painted

A stroke is paid in Blank at 100 points per full share of cost, and no linh lực. It can only fire with
the Blank to pay for it. Size scales the target's fight unit, maximum and current health and
maximum and current linh lực together, so its bars keep their shares and its costs stay shares.
An art guarded {"blank_out": 5, "who": "enemy", "pool": "qi", "above": 2} fires only at or below that much
Blank; the last three keys keep the guard false if this plug-in is skipped.
An enemy spec with "burns_blank": n takes n Blank from the painter with each art hit that lands.
Blank never returns inside a fight. A side with no "scroll" is untouched, except as a target.
"""


def install(f):
    Base = f.Side
    resolve0, guard0, strike0, points0 = f.resolve_art, f.guard_true, f.strike, f.layer_points

    class Side(Base):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            o = spec.get("scroll")
            if not o:
                return
            self.blank = o.get("blank", 100) - sum(s.get("takes", 0) for s in o.get("seals", []))
            for s in o.get("seals", []):
                self.x[s["layer"] - 1] += s.get("points", 0)
            for a in self.arts:
                if a.get("stroke"):
                    a["blank_cost"] = a.get("cost_share", 0) * 100 * (1 - self.cost_red)
                    a["cost_share"] = 0
                    a["guard"] = {"blank": a["blank_cost"], "who": "enemy", "pool": "qi", "above": 2}

    def guard_true(g, own, enemy, t):
        if g and "blank" in g:  # read only for a ready art, in slot order, so it pays here as a cost would
            if own.__dict__.get("blank", 0) + 1e-9 < g["blank"]:
                return False
            own.blank -= g["blank"]
            own.painted = own.__dict__.get("painted", 0.0) + g["blank"]
            return True
        if g and "blank_out" in g:
            return own.__dict__.get("blank", 100) <= g["blank_out"] + 1e-9
        return guard0(g, own, enemy, t)

    def resolve_art(att, dfn, art, t, gap):
        resolve0(att, dfn, art, t, gap)
        o = att.spec.get("scroll")
        if not (o and art.get("stroke")):
            return
        paid = art["blank_cost"]
        sight = min(1.0, att.sense / dfn.sense)
        k = 1 - o.get("shrink", 0.012) * paid * sight
        size = dfn.__dict__.get("size", 1.0)
        k = max(k, o.get("floor", 0.2) / size)
        dfn.size = size * k
        dfn.u *= k
        dfn.health *= k
        dfn.health_max *= k
        dfn.qi *= k
        dfn.qi_max *= k
        dfn.qi_cap *= k
        att.note("size_now_%d_pct" % round(100 * dfn.size))

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        out = strike0(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        burn = att.spec.get("burns_blank", 0)
        if burn and channel.startswith("art:") and "blank" in dfn.__dict__:
            dfn.blank = max(0.0, dfn.blank - burn)
        return out

    def layer_points(att, dfn, t, extra, channel):
        x = points0(att, dfn, t, extra, channel)
        signed = att.spec.get("scroll", {}).get("signed")
        if signed and channel == "art:%s" % signed["art"]:
            x[1] += signed.get("per", 1.0) * att.__dict__.get("painted", 0.0)
        return x

    f.Side, f.guard_true, f.resolve_art, f.strike, f.layer_points = Side, guard_true, resolve_art, strike, layer_points
