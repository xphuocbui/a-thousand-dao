"""One Drop (Nhất Tích), and what stacks on it. A share of the target's sea takes your colour.

Asked for with "one_drop": {...} on the side that carries the keystone:
  "purity": 100          the element's purity
  "stains": 0            each one takes "stain" (default 4) off purity: the Clear Line
  "enemy_purity": 50     the target's highest purity, unless its own spec says "purity"
  "scale": 50            colour x (1 + (clean purity - theirs) / scale x (1 + spread_pct / 100)) each
  "spread_pct": 0        pulse, never below x1. Steeped and its acupoints add to spread_pct
  "start": 0.01          the share an art with "drop": true leaves when it lands, times (1 - evade)
  "clean_hands": 0.005   Clean Hands: added to start per empty art slot
  "turn_cap": 0.25       Phan Thu Luat's cap on one turned hit, as a share of their maximum health
  "bluer": true          Bluer Than the Plant: at 100 %, their basic attack turns too
  "mordant": 0.5         Mordant: a cleanse leaves this share of the colour, not 0

While a side holds colour c:
  c of each of its art hits resolves on itself, at its own M, no suppression, no evade, through its
  own ward and guard, and only 1 - c reaches the carrier. Ticks and companions never turn.
  c of any hit from the carrier, or from itself, passes its ward as if the ward were not there.
An art guarded {"undyed": true, "who": "enemy", "pool": "qi", "above": 2} fires only while the target
holds no colour. The last three keys keep the guard false if this plug-in is skipped.
A target's art with "cleanse": n removes the colour, or leaves the Mordant share.
"""


def install(f):
    strike0, ward0, pulse0, resolve0, guard0 = f.strike, f.apply_ward, f.pulse, f.resolve_art, f.guard_true

    def colour(side):
        return side.__dict__.get("colour", 0.0)

    def rate(src, target):
        o = src.spec["one_drop"]
        clean = o.get("purity", 100) - o.get("stains", 0) * o.get("stain", 4)
        theirs = target.spec.get("purity", o.get("enemy_purity", 50))
        return max(1.0, 1 + (clean - theirs) / o.get("scale", 50) * (1 + o.get("spread_pct", 0) / 100.0))

    def apply_ward(dfn, att, d, kind):
        c = colour(dfn)
        if c and (att is dfn or att is dfn.__dict__.get("colour_src")):
            return ward0(dfn, att, d * (1 - c), kind) + d * c
        return ward0(dfn, att, d, kind)

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        share = colour(att)
        src = att.__dict__.get("colour_src")
        turns = channel.startswith("art:") or (
            channel == "basic" and share >= 1 and src.spec["one_drop"].get("bluer"))
        if not share or not turns:
            return strike0(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        out = 0.0
        if share < 1:
            out = strike0(att, dfn, t, gap, c * (1 - share), kind, extra, channel, crit, direct)
        evade, att.evade = att.evade, 0.0
        before = att.health
        dealt = strike0(att, att, t, 0, c * share, kind, extra, "turned", crit, False)
        att.evade = evade
        limit = src.spec["one_drop"].get("turn_cap", 0.25) * att.health_max
        if dealt > limit:
            att.health = before - limit
            att.dmg_taken_instant -= dealt - limit
            dealt = limit
            src.note("turned_hit_capped")
        f.add_dmg(src, "turned(their own hands)", dealt)
        return out

    def pulse(side, enemy, gap, t):
        pulse0(side, enemy, gap, t)
        if colour(side) and side.__dict__.get("colour_src") is enemy:
            side.colour = min(1.0, side.colour * rate(enemy, side))

    def resolve_art(att, dfn, art, t, gap):
        resolve0(att, dfn, art, t, gap)
        if art.get("drop") and "one_drop" in att.spec and not colour(dfn):
            o = att.spec["one_drop"]
            empty = max(0, f.K["slots_by_realm"][att.r] - len(att.arts))
            land = 1 - max(0.0, min(dfn.evade - att.accuracy, f.K["evade_cap"]))
            dfn.colour = (o.get("start", 0.01) + empty * o.get("clean_hands", 0)) * land
            dfn.colour_src = att
        if art.get("cleanse") and colour(att):
            keep = att.colour_src.spec["one_drop"].get("mordant", 0)
            att.colour = att.colour * keep

    def guard_true(g, own, enemy, t):
        if g and g.get("undyed"):
            return not colour(enemy)
        return guard0(g, own, enemy, t)

    f.strike, f.apply_ward, f.pulse, f.resolve_art, f.guard_true = strike, apply_ward, pulse, resolve_art, guard_true
