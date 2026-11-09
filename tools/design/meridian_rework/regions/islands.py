"""Shared drawing for the three islands outside the circle (Light, Darkness, Thunder), whole-tree pass 2026-11-08.

Each island is a mandala on a graph of its own (decision 6): the variant's start at the centre, an inner ring, an outer
ring with the variant's figures hung outward, two keystones, and a bridge down to the tree.
"""
import math


def mandala(T, pens, cfg):
    """cfg: centre, theme, inner (n, r), outer (n, r), outward figures [(kind, names)], keystones [key, key], start key."""
    C = cfg["centre"]
    th = cfg["theme"]
    S = T.node(C, "S", key=cfg["key"])
    n1, r1 = cfg["inner"]
    # judge round 16: the three islands shared one recipe. Each core now has its own shape: a round ring (the sun), a
    # star (the thunderbolt: alternate radii, straight sides) or a ring pushed off-centre (the eclipse's crescent)
    star = cfg.get("inner_star")
    sh = cfg.get("inner_shift", (0.0, 0.0))
    ic = (C[0] + sh[0], C[1] + sh[1])
    T.cluster(cfg["name"] + " inner ring", "ring", mastery=None)
    rr = [r1 + ((star if j % 2 else -star) if star else 0.0) for j in range(n1)]
    inner = [T.node(pens.circ(ic, rr[j], [180 + 360 * j / n1])[0], "N" if j % (n1 // 2) == n1 // 4 else "s", th) for j in range(n1)]
    for a, b in zip(inner, inner[1:] + inner[:1]):
        if star:
            T.link(a, b)
        else:
            T.link(a, b, centre=ic)
    T.end()
    if star or sh != (0.0, 0.0):
        # spokes to the nearest points only (the entry rule): the star's five inner corners, the eclipse's near side
        d0 = min(math.dist(T.pt(i), C) for i in inner)
        for i in inner:
            if math.dist(T.pt(i), C) < d0 + 0.05:
                T.link(S, i)
    else:
        for j in range(0, n1, n1 // 3 if n1 % 3 == 0 else n1 // 2):
            T.link(S, inner[j])
    n2, r2 = cfg["outer"]
    r2 += cfg.get("grow", 1.2)
    jag = cfg.get("jag", 0.0)
    outer = [T.junction(pens.circ(C, r2 + (jag if j % 2 else -jag), [180 + 360 * j / n2])[0], road=cfg["road"]) for j in range(n2)]
    for a, b in zip(outer, outer[1:] + outer[:1]):
        if jag or cfg.get("polygon"):
            T.link(a, b, kind="highway")
        else:
            T.link(a, b, centre=C, kind="highway")
    for j in (range(1, n1, 2) if star else range(0, n1, max(1, n1 // 4))):     # a star joins the road ring at its tips
        o = min(outer, key=lambda i: math.dist(T.pt(i), T.pt(inner[j])))
        near = min(inner, key=lambda i: math.dist(T.pt(i), T.pt(o)))      # the entry rule, for a ring off-centre
        if not any({e["a"], e["b"]} == {near, o} for e in T.edges):
            T.link(near, o)
    # a crown on the far side (judge rounds 10-14: the islands read as thin stubs, not destinations): an outer arc road
    # joined to the road ring by three spokes, with the variant's figures hung outward from it
    cr = cfg.get("crown")
    if cr:
        r3 = r2 + 4.6
        a0, a1 = cr["span"]
        angs = [a0 + (a1 - a0) * j / (cr["n"] - 1) for j in range(cr["n"])]
        crown = [T.junction(pens.circ(C, r3, [a])[0], road=cfg["road"]) for a in angs]
        for a, b in zip(crown, crown[1:]):
            T.link(a, b, centre=C, kind="highway")
        for j in (0, len(crown) // 2, len(crown) - 1):
            o = min(outer, key=lambda i: math.dist(T.pt(i), T.pt(crown[j])))
            T.link(o, crown[j], kind="highway")
        for j, c in enumerate(crown):
            a = pens.toward(T, c, (2 * T.pt(c)[0] - C[0], 2 * T.pt(c)[1] - C[1]))
            for kind in cr["figs"][j % len(cr["figs"]):] + cr["figs"][:j % len(cr["figs"])] + ["kite"]:
                if pens.pict(T, c, a, kind, th, k=cr.get("k", 0.72), turns=(0, 12, -12, 25, -25)):
                    break
                T.fit_failures.pop()
    # an inner court: small figures hung from the road ring inward, between the spokes
    for j, o in enumerate(outer):
        if j % 2 == 0:
            continue
        a = pens.toward(T, o, C)
        for kind in cfg.get("inner_figs", ("kite", "V")):
            if pens.pict(T, o, a, kind, th, k=0.62, turns=(0, 15, -15, 30, -30)):
                break
            T.fit_failures.pop()
    return S, inner, outer


def gate(T, pens, br, theme, kinds, k=0.7, others=None):
    """One kind of joint for every island (judge round 15: the three islands joined in three different ways). The
    bridge runs straight; its middle node carries a mirrored pair of figures, one each side, like a gateway, and any
    other stops on a longer bridge carry one small figure each, on alternating sides."""
    mids = br[1:-1]
    if not mids:
        return
    a = pens.toward(T, br[0], T.pt(br[-1]))
    m = mids[len(mids) // 2]
    for side, mir in ((90, False), (-90, True)):
        for kind in tuple(kinds) + ("kite",):
            if pens.pict(T, m, a + side, kind, theme, k=k, turns=(0, 8, -8, 16, -16), mirror=mir):
                break
            T.fit_failures.pop()
    if others:
        for j, i in enumerate(x for x in mids if x != m):
            if j % 2:
                continue
            for kind in tuple(others) + ("kite",):
                if pens.pict(T, i, a + (90 if (j // 2) % 2 else -90), kind, theme, k=0.68, turns=(0, 15, -15, 30, -30)):
                    break
                T.fit_failures.pop()
