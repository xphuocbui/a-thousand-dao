"""Washing (Tẩy): a cleanse aimed at someone else. Combat rule 8's cleanse takes statuses off the caster;
this one takes layers off the target, and the attendant keeps what fits.

Asked for with "washing": {...} on a side, and "wash": true on an art:
  "keep": 0.5            share of the washed points added to the same layer of the washer
  "strippable": [1,2,3,4] layer indexes that can wash, L2 to L5 by default. L1 never washes.
  "both_hands": true     Both Hands: the first firing of a fight takes two layers
  "skin": 40             Down to the Skin: with no layer left to wash, a firing takes this much ward
                         strength and efficiency off the target instead, and the washer keeps "keep" of it

Each firing of a wash art zeroes the target's largest strippable layer, counting the "layers" and the
largest "x" of any of its arts, times (1 - evade) in expected value, for the rest of the fight.
Conditional points are not washed. Only a side that asks for it washes anyone.
"""


def install(f):
    resolve0 = f.resolve_art

    def wash(att, dfn, o):
        layers = o.get("strippable", [1, 2, 3, 4])

        def worn(n):
            return dfn.x[n] + max([(a.get("x") or [0] * 5)[n] for a in dfn.arts] or [0])

        i = max(layers, key=lambda n: (worn(n), -n))
        land = 1 - max(0.0, min(dfn.evade - att.accuracy, f.K["evade_cap"]))
        took = worn(i) * land
        if took <= 0:
            step = o.get("skin", 0) * land
            w = dfn.ward
            if step and w.get("ws", 0) > 0:
                dfn.ward = dict(w, ws=max(0, w.get("ws", 0) - step), we=max(0, w.get("we", 0) - step))
                mine = att.ward
                keep = step * o.get("keep", 0.5)
                att.ward = dict(mine, ws=mine.get("ws", 0) + keep, we=mine.get("we", 0) + keep)
                att.note("washed_ward")
            return
        dfn.x[i] *= 1 - land
        for a in dfn.arts:
            if a.get("x"):
                a["x"] = list(a["x"])
                a["x"][i] *= 1 - land
        att.x[i] += took * o.get("keep", 0.5)
        att.note("washed_L%d" % (i + 1))

    def resolve_art(att, dfn, art, t, gap):
        resolve0(att, dfn, art, t, gap)
        o = att.spec.get("washing")
        if not (o and art.get("wash")):
            return
        wash(att, dfn, o)
        if o.get("both_hands") and not att.__dict__.get("hands_used"):
            att.hands_used = True
            wash(att, dfn, o)

    f.resolve_art = resolve_art
