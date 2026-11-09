"""Whole-tree figures (2026-11-08 night): a pictogram vocabulary for each land, added to pens.PICT.

pens.py runs this file at its end, so every region that loads the pens gets these figures. Each figure is built with
Fig: nodes in the local frame (entry first, at (0, 0); +y away from the node it hangs off), links straight or bent
(bend > 0 bulges to the left of i -> j). Each one means something for its theme, as PoE 2's figures do (a heart for
Tâm Cảnh, a snowflake for cold): a cauldron for alchemy, 山 for Earth, a paw for beasts, a talisman slip for Phù Đạo.
"""
import math


def _rad(a):
    return math.radians(a)


def _bend_centre(p, q, bend):
    mx, my = (p[0] + q[0]) / 2, (p[1] + q[1]) / 2
    du, dv = q[0] - p[0], q[1] - p[1]
    c = math.hypot(du, dv)
    lu, lv = -dv / c, du / c
    s = abs(bend)
    rr = (c * c / 4 + s * s) / (2 * s)
    k = math.copysign(rr - s, bend)
    return (mx - k * lu, my - k * lv)


class Fig:
    def __init__(self):
        self.p, self.r, self.e = [], [], []

    def n(self, x, y, role="s"):
        self.p.append((round(x, 3), round(y, 3)))
        self.r.append(role)
        return len(self.p) - 1

    def l(self, i, j, bend=0.0, centre=None):
        if centre is not None:
            self.e.append((i, j, centre))
        elif abs(bend) > 1e-6:
            self.e.append((i, j, _bend_centre(self.p[i], self.p[j], bend)))
        else:
            self.e.append((i, j))

    def path(self, ids, bend=0.0):
        for a, b in zip(ids, ids[1:]):
            self.l(a, b, bend)

    def ringl(self, ids, centre, closed=True):
        seq = ids + ([ids[0]] if closed else [])
        for a, b in zip(seq, seq[1:]):
            self.l(a, b, centre=centre)

    def out(self):
        return (self.p, "".join(self.r), self.e)


def _pol(cx, cy, r, a):
    return (cx + r * math.sin(_rad(a)), cy + r * math.cos(_rad(a)))


def cauldron():
    """Đan lô, the pill cauldron: legs, a round belly, a rim with two ears and a lid knob (alchemy)."""
    f = Fig(); C = (0, 2.1)
    e = f.n(0, 0); b = f.n(*_pol(*C, 1.3, 180))
    l2, r2 = f.n(*_pol(*C, 1.3, 228)), f.n(*_pol(*C, 1.3, 132))
    lr, rr = f.n(*_pol(*C, 1.3, 270), "N"), f.n(*_pol(*C, 1.3, 90))
    mid = f.n(0, 2.1); knob = f.n(0, 3.15, "N")
    fl, fr = f.n(-1.85, 0.5), f.n(1.85, 0.5)
    el, er = f.n(-2.15, 2.85), f.n(2.15, 2.85, "N")
    f.l(e, b); f.l(b, l2, centre=C); f.l(b, r2, centre=C); f.l(l2, lr, centre=C); f.l(r2, rr, centre=C)
    f.l(lr, mid); f.l(mid, rr); f.l(mid, knob); f.l(l2, fl); f.l(r2, fr); f.l(lr, el); f.l(rr, er)
    return f.out()


def sun():
    """A sun wheel: a ring of eight with rays (Fire's centre, the Light island)."""
    f = Fig(); C = (0, 2.35)
    e = f.n(0, 0)
    ring = [f.n(*_pol(*C, 1.3, 180 + 45 * k), "N" if k in (2, 6) else "s") for k in range(8)]
    f.l(e, ring[0]); f.ringl(ring, C)
    for k in (1, 3, 4, 5, 7):
        f.l(ring[k], f.n(*_pol(*C, 2.45, 180 + 45 * k), "N" if k == 4 else "s"))
    return f.out()


def flame():
    """Three flame tongues from one base, the tall one in the middle (burning)."""
    f = Fig()
    e = f.n(0, 0); l1, l2 = f.n(-0.6, 1.15), f.n(-0.5, 2.35); r1, r2 = f.n(0.6, 1.15), f.n(0.5, 2.35); tip = f.n(0, 3.45, "N")
    sl, slt = f.n(-1.5, 1.7), f.n(-2.05, 2.75, "N"); sr, srt = f.n(1.5, 1.7), f.n(2.05, 2.75)
    f.l(e, l1, -0.12); f.l(l1, l2, -0.1); f.l(l2, tip, -0.15); f.l(e, r1, 0.12); f.l(r1, r2, 0.1); f.l(r2, tip, 0.15)
    f.l(l1, sl, 0.1); f.l(sl, slt, 0.15); f.l(r1, sr, -0.1); f.l(sr, srt, -0.15)
    return f.out()


def lotus():
    """A lotus seen from above: six petal tips round a ring of six (Fire Lotus, Heart)."""
    f = Fig(); C = (0, 2.3)
    tips = [f.n(*_pol(*C, 2.3, 180 + 60 * k), "N" if k in (2, 3, 4) else "s") for k in range(6)]
    ring = [f.n(*_pol(*C, 1.15, 210 + 60 * k)) for k in range(6)]
    f.ringl(ring, C)
    for k in range(6):
        f.l(tips[k], ring[k]); f.l(tips[k], ring[k - 1])
    return f.out()


def phoenix():
    """The vermilion bird with spread wings, head up (Fire's apex, rebirth)."""
    f = Fig()
    e = f.n(0, 0); b1 = f.n(0, 1.1); b2 = f.n(0, 2.2); hd = f.n(0, 3.25, "N")
    f.path([e, b1, b2, hd])
    for s in (-1, 1):
        a1 = f.n(s * 1.0, 2.75); a2 = f.n(s * 2.0, 3.1); tip = f.n(s * 2.95, 2.65, "N")
        d1 = f.n(s * 2.15, 1.85); d2 = f.n(s * 1.05, 1.5)
        f.l(b2, a1, s * -0.1); f.l(a1, a2, s * -0.1); f.l(a2, tip, s * -0.1); f.l(tip, d1, s * -0.1); f.l(d1, d2, s * -0.1); f.l(d2, b1)
    return f.out()


def bagua():
    """An eight-sided formation disc with trigram spurs (formations)."""
    f = Fig(); C = (0, 2.6)
    e = f.n(0, 0)
    ring = [f.n(*_pol(*C, 1.6, 180 + 45 * k), "N" if k in (2, 6) else "s") for k in range(8)]
    f.l(e, ring[0])
    for a, b in zip(ring, ring[1:] + ring[:1]):
        f.l(a, b)
    for k in (1, 3, 4, 5, 7):
        f.l(ring[k], f.n(*_pol(*C, 2.7, 180 + 45 * k), "N" if k == 4 else "s"))
    return f.out()


def shan():
    """山, the character for mountain: a base with three strokes, the middle one tallest (Earth)."""
    f = Fig()
    e = f.n(0, 0)
    base = [f.n(x, 0.95) for x in (-2.0, -1.0, 0.0, 1.0, 2.0)]
    f.l(e, base[2]); f.path(base)
    m1 = f.n(0, 2.05); m2 = f.n(0, 3.1, "N"); f.path([base[2], m1, m2])
    lt = f.n(-2.0, 2.05, "N"); rt = f.n(2.0, 2.05, "N"); f.l(base[0], lt); f.l(base[4], rt)
    return f.out()


def turtle():
    """The black-earth turtle: a hexagonal shell, four legs and a head (Earth's body, defence)."""
    f = Fig(); C = (0, 2.0)
    e = f.n(0, 0)   # the tail
    shell = [f.n(*_pol(*C, 1.25, 180 + 60 * k), "N" if k == 3 else "s") for k in range(6)]
    f.l(e, shell[0])
    for a, b in zip(shell, shell[1:] + shell[:1]):
        f.l(a, b)
    neck = f.n(0, 4.3); hd = f.n(0, 5.35, "N")
    f.l(shell[3], neck); f.l(neck, hd)
    for k, s in ((1, -1), (5, 1), (2, -1), (4, 1)):
        x, y = f.p[shell[k]]
        f.l(shell[k], f.n(x + s * 0.95, y + (0.55 if k in (2, 4) else -0.45), "N" if k == 2 else "s"))
    return f.out()


def paw():
    """A beast's paw print: a round pad and four toes (beasts)."""
    f = Fig(); C = (0, 2.05)
    e = f.n(0, 0)
    pad = [f.n(*_pol(*C, 1.0, 180 + 72 * k)) for k in range(5)]
    f.l(e, pad[0]); f.ringl(pad, C)
    for k, a in ((1, 300), (2, 342), (3, 18), (4, 60)):
        f.l(pad[k], f.n(*_pol(*C, 2.25, a), "N" if a in (342, 18) else "s"))
    return f.out()


def tree():
    """A branching tree: trunk, two boughs and two low branches (Wood)."""
    f = Fig()
    e = f.n(0, 0); t1 = f.n(0, 1.1); t2 = f.n(0, 2.2)
    f.path([e, t1, t2])
    f.l(t2, f.n(0, 3.35, "N"))
    for s in (-1, 1):
        # judge rounds 15-20: branches that stopped on a plain node read as unfinished. Both boughs end in gold, and
        # the low branches curl into a leaf (a closed loop)
        b1 = f.n(s * 1.0, 2.75); b2 = f.n(s * 1.95, 3.3, "N"); lo = f.n(s * 1.05, 1.55)
        la = f.n(s * 1.95, 1.45); lb = f.n(s * 1.75, 2.15)
        f.l(t2, b1, s * 0.1); f.l(b1, b2, s * 0.1); f.l(t1, lo, s * 0.1); f.l(lo, la, s * 0.1); f.l(la, lb, s * 0.15); f.l(lb, lo, s * 0.1)
    return f.out()


def vine():
    """Twin vines: a chain of three lens loops (Wood's growth)."""
    f = Fig()
    prev = f.n(0, 0)
    for k in range(3):
        y0 = 2.3 * k
        a = f.n(-0.62, y0 + 1.15); b = f.n(0.62, y0 + 1.15, "N" if k == 1 else "s"); nxt = f.n(0, y0 + 2.3, "N" if k == 2 else "s")
        f.l(prev, a, -0.25); f.l(a, nxt, -0.25); f.l(prev, b, 0.25); f.l(b, nxt, 0.25)
        prev = nxt
    return f.out()


def wave():
    """A breaking wave: a rising crest that curls over, with a small swell beside it (Water)."""
    f = Fig()
    e = f.n(0, 0)
    pts = [(-0.9, 0.8), (-1.6, 1.75), (-1.5, 2.85), (-0.6, 3.45), (0.35, 3.15), (0.55, 2.15), (-0.3, 1.85)]
    ids = [f.n(x, y, "N" if (x, y) in ((-0.6, 3.45), (-0.3, 1.85)) else "s") for x, y in pts]
    f.l(e, ids[0], 0.12)
    f.path(ids, 0.18)
    r1 = f.n(0.95, 0.8); r2 = f.n(1.8, 1.45); f.l(e, r1, -0.12); f.l(r1, r2, -0.12)
    return f.out()


def spiral():
    """A whirlpool: one arm winding in to a notable at its eye (Water's tide)."""
    f = Fig(); C = (0, 3.4)
    e = f.n(0, 0)
    ids = [f.n(*_pol(*C, 2.3 - 0.21 * k, 180 + 52 * k), "N" if k in (3, 7) else "s") for k in range(8)]
    f.l(e, ids[0])
    f.path(ids, -0.16)
    return f.out()


def flake():
    """A great snowflake: six arms from a hub, three of them with a twig (Ice)."""
    f = Fig(); C = (0, 2.3)
    hub = None
    e = f.n(0, 0)
    hub = f.n(*C, "N")
    for k in range(6):
        a = 180 + 60 * k
        p1 = f.n(*_pol(*C, 1.15, a)) if k else None
        p2 = f.n(*_pol(*C, 2.3, a), "N" if k == 3 else "s") if k else e
        if k:
            f.l(hub, p1); f.l(p1, p2)
        else:
            mid = f.n(*_pol(*C, 1.15, a)); f.l(e, mid); f.l(mid, hub); p1 = mid
        if k in (1, 3, 5):
            f.l(p1, f.n(*_pol(*C, 1.95, a + 28)))
    return f.out()


def bolt():
    """A lightning bolt: a hard zigzag with a forked end (Thunder)."""
    f = Fig()
    pts = [(0, 0), (0.85, 0.8), (0.0, 1.55), (1.0, 2.4), (0.15, 3.15), (1.05, 4.0)]
    ids = [f.n(x, y, "N" if k == 5 else "s") for k, (x, y) in enumerate(pts)]
    f.path(ids)
    f.l(ids[4], f.n(-0.65, 3.95, "N"))
    return f.out()


def eclipse():
    """Two rings sharing a lens, one dark over one bright (Darkness, Light)."""
    f = Fig()
    C1, C2 = (-0.75, 2.0), (0.75, 2.0)
    e = f.n(0, 0)
    bot = f.n(*_pol(*C1, 1.35, 146.3)); top = f.n(*_pol(*C1, 1.35, 33.7))
    L = [f.n(*_pol(*C1, 1.35, a), "N" if a == 270 else "s") for a in (210, 270, 330)]
    Rr = [f.n(*_pol(*C2, 1.35, a), "N" if a == 90 else "s") for a in (150, 90, 30)]
    f.l(e, bot)
    f.l(bot, L[0], centre=C1); f.l(L[0], L[1], centre=C1); f.l(L[1], L[2], centre=C1); f.l(L[2], top, centre=C1)
    f.l(bot, Rr[0], centre=C2); f.l(Rr[0], Rr[1], centre=C2); f.l(Rr[1], Rr[2], centre=C2); f.l(Rr[2], top, centre=C2)
    return f.out()


def drum():
    """The thunder god's drum ring: a ring with small drums hung round it (Thunder)."""
    f = Fig(); C = (0, 2.4)
    e = f.n(0, 0)
    ring = [f.n(*_pol(*C, 1.4, 180 + 60 * k), "N" if k == 3 else "s") for k in range(6)]
    f.l(e, ring[0]); f.ringl(ring, C)
    for k in (1, 2, 4, 5):
        a = 180 + 60 * k
        d1 = f.n(*_pol(*C, 2.45, a - 14)); d2 = f.n(*_pol(*C, 2.45, a + 14), "N" if k == 2 else "s")
        f.l(ring[k], d1); f.l(ring[k], d2); f.l(d1, d2, centre=C)
    return f.out()


def fan():
    """A folding fan: ribs from a pivot to a curved edge (Wind)."""
    f = Fig()
    e = f.n(0, 0); piv = f.n(0, 0.95)
    f.l(e, piv)
    edge = [f.n(*_pol(0, 0.95, 2.5, a), "N" if a in (-50, 50) else "s") for a in (-50, -25, 0, 25, 50)]
    for k in (0, 2, 4):
        f.l(piv, edge[k])
    f.ringl(edge, (0, 0.95), closed=False)
    return f.out()


def cloud():
    """An auspicious cloud (tường vân): three curls on a base (Wind, rain)."""
    f = Fig()
    e = f.n(0, 0)
    base = [f.n(x, 0.85) for x in (-1.7, -0.6, 0.6, 1.7)]
    f.l(e, base[1]); f.l(e, base[2]); f.path(base)
    c1 = f.n(-2.0, 1.95); c2 = f.n(-1.1, 2.6, "N"); c3 = f.n(0, 2.05); c4 = f.n(1.1, 2.6, "N"); c5 = f.n(2.0, 1.95)
    f.l(base[0], c1, -0.3); f.l(c1, c2, -0.3); f.l(c2, c3, -0.3); f.l(c3, c4, -0.3); f.l(c4, c5, -0.3); f.l(c5, base[3], -0.3)
    return f.out()


def fish():
    """A koi: a lens-shaped body, a forked tail and an eye (Water)."""
    f = Fig()
    e = f.n(0, 0)   # the tail joint
    tl, tr = f.n(-0.85, -0.1), f.n(0.85, -0.1)
    l1, l2 = f.n(-0.85, 1.2), f.n(-0.7, 2.45); r1, r2 = f.n(0.85, 1.2), f.n(0.7, 2.45); hd = f.n(0, 3.45, "N")
    eye = f.n(0, 2.0, "N")
    f.l(e, tl); f.l(e, tr); f.l(e, l1, -0.2); f.l(l1, l2, -0.1); f.l(l2, hd, -0.2); f.l(e, r1, 0.2); f.l(r1, r2, 0.1); f.l(r2, hd, 0.2)
    f.l(l2, eye)
    return f.out()


def seal():
    """A talisman slip (phù): a tall frame with a stroke of seal script across it (talismans)."""
    f = Fig()
    e = f.n(0, 0)
    L = [f.n(-0.9, y) for y in (0.55, 1.65, 2.75, 3.85)]
    Rr = [f.n(0.9, y) for y in (0.55, 1.65, 2.75, 3.85)]
    f.l(e, L[0]); f.l(e, Rr[0]); f.path(L); f.path(Rr)
    top = f.n(0, 4.4, "N"); f.l(L[3], top); f.l(Rr[3], top)
    z = f.n(0, 2.2, "N"); f.l(L[1], z); f.l(z, Rr[2])
    return f.out()


def antler():
    """A deer's antler: a curving beam with tines (beasts)."""
    f = Fig()
    beam = [(0, 0), (0.3, 1.1), (0.25, 2.2), (-0.15, 3.25), (-0.75, 4.15)]
    ids = [f.n(x, y, "N" if k == 4 else "s") for k, (x, y) in enumerate(beam)]
    f.path(ids, -0.1)
    for k, dx, dy, ro in ((1, 1.05, 0.45, "s"), (2, 1.1, 0.55, "N"), (3, 0.95, 0.6, "s")):
        x, y = beam[k]
        f.l(ids[k], f.n(x + dx, y + dy, ro))
    return f.out()


def rosette():
    """A small flower: a hub ringed by five petals (herbs, fields)."""
    f = Fig(); C = (0, 1.9)
    e = f.n(0, 0)
    pts = [f.n(*_pol(*C, 1.15, 180 + 72 * k), "N" if k == 3 else "s") for k in range(5)]
    hub = f.n(*C, "N")
    f.l(e, pts[0])
    for k in range(5):
        f.l(hub, pts[k])
        f.l(pts[k], pts[(k + 1) % 5], centre=C)
    return f.out()


def gourd2():
    """A wine gourd (hồ lô): a big ring under a small one (lifespan, alchemy)."""
    f = Fig(); C1, C2 = (0, 1.6), (0, 4.15)
    lo = [f.n(*_pol(*C1, 1.6, 180 + 45 * k), "N" if k == 2 else "s") for k in range(8)]
    f.p[0] = (0.0, 0.0)
    f.ringl(lo, C1)
    hi = [lo[4]] + [f.n(*_pol(*C2, 0.95, 180 + 72 * k), "N" if k == 3 else "s") for k in range(1, 5)]
    f.ringl(hi, C2)
    return f.out()


def taiji():
    """Taiji: a ring split by an S of two half-circles, with the two eyes (Chaos, the centre)."""
    f = Fig(); C = (0, 3.1); Rr = 2.0
    e = f.n(0, 0)
    ring = [f.n(*_pol(*C, Rr, 180 + 30 * k), "N" if k in (3, 9) else "s") for k in range(12)]
    f.l(e, ring[0]); f.ringl(ring, C)
    mid = f.n(*C)
    cu, cd = (0, C[1] + Rr / 2), (0, C[1] - Rr / 2)
    su = f.n(*_pol(*cu, Rr / 2, 90)); sd = f.n(*_pol(*cd, Rr / 2, 270))
    f.l(ring[6], su, centre=cu); f.l(su, mid, centre=cu); f.l(mid, sd, centre=cd); f.l(sd, ring[0], centre=cd)
    return f.out()


def shield():
    """A guardian's shield: pointed base, flat top, a boss in the middle (ward)."""
    f = Fig()
    e = f.n(0, 0)
    l1, l2, l3 = f.n(-0.95, 0.75), f.n(-1.45, 1.85), f.n(-1.3, 3.0)
    r1, r2, r3 = f.n(0.95, 0.75), f.n(1.45, 1.85), f.n(1.3, 3.0)
    t = f.n(0, 3.15, "N"); boss = f.n(0, 1.75, "N")
    f.path([e, l1, l2, l3, t], 0.08); f.path([e, r1, r2, r3, t], -0.08); f.l(e, boss)
    return f.out()


def pagoda():
    """A three-roof pagoda: a mast with three widening roofs (insight, the hidden realms)."""
    f = Fig()
    m = [f.n(0, y) for y in (0, 1.05, 2.1, 3.15)]
    f.path(m)
    for k, (y, w) in enumerate(((0.75, 1.55), (1.8, 1.25), (2.85, 0.95))):
        a, b = f.n(-w, y), f.n(w, y)
        f.l(m[k + 1], a); f.l(m[k + 1], b)
    f.l(m[3], f.n(0, 4.2, "N"))
    f.r[m[2]] = "N"
    return f.out()


def whirl():
    """A whirlwind: a small eye ringed by six, with three arms curling out of it (Wind's start web)."""
    f = Fig(); C = (0, 2.5)
    e = f.n(0, 0)
    ring = [f.n(*_pol(*C, 1.35, 180 + 60 * k)) for k in range(6)]
    f.l(e, ring[0]); f.ringl(ring, C)
    for k in (0, 2, 4):
        a = 180 + 60 * k
        p1 = f.n(*_pol(*C, 2.45, a + 28)); p2 = f.n(*_pol(*C, 3.3, a + 62), "N")
        f.l(ring[k], p1, 0.25); f.l(p1, p2, 0.3)
    return f.out()


def terrace():
    """Rice terraces on a hillside: three stacked arcs on a spine, widening as they climb (spirit fields)."""
    f = Fig()
    spine = [f.n(0, 0)]
    ends = {}
    for k, (y, w, n) in enumerate(((1.15, 1.25, 3), (2.4, 1.8, 3), (3.65, 2.35, 5))):
        mid = f.n(0, y, "N" if k == 2 else "s")
        f.l(spine[-1], mid)
        spine.append(mid)
        for s in (-1, 1):
            prev = mid
            for j in range(1, n // 2 + 1):
                x = s * w * j / (n // 2)
                p = f.n(x, y - 0.32 * (j / (n // 2)) ** 2 * w, "N" if (k == 2 and j == n // 2) else "s")
                f.l(prev, p, s * -0.08)
                prev = p
            ends[(k, s)] = prev
    # judge rounds 15-20: the terrace ends dangled; each plot's edge now climbs to the one above (stacked fields)
    for k in (0, 1):
        for s in (-1, 1):
            f.l(ends[(k, s)], ends[(k + 1, s)])
    return f.out()


FIGS = {"terrace": terrace, "whirl": whirl, "cauldron": cauldron, "sun": sun, "flame": flame, "lotus": lotus, "phoenix": phoenix, "bagua": bagua, "shan": shan,
        "turtle": turtle, "paw": paw, "tree": tree, "vine": vine, "wave": wave, "spiral": spiral, "flake": flake, "bolt": bolt,
        "eclipse": eclipse, "drum": drum, "fan": fan, "cloud": cloud, "fish": fish, "seal": seal, "antler": antler,
        "rosette": rosette, "gourd2": gourd2, "taiji": taiji, "shield": shield, "pagoda": pagoda}
ASYM = {"wave", "spiral", "bolt", "antler"}
DENSE = {"sun": 0.85, "lotus": 0.85, "bagua": 0.85, "phoenix": 0.85, "cauldron": 0.85, "flake": 0.9, "drum": 0.85,
         "taiji": 0.9, "gourd2": 0.85, "turtle": 0.8, "paw": 0.8, "rosette": 0.8, "vine": 0.85, "spiral": 0.85}


def install(pens):
    for k, fn in FIGS.items():
        pens.PICT[k] = fn()
    pens.ASYM |= ASYM
    pens.DENSE.update(DENSE)
    pens.MASTERY_KINDS |= set(FIGS) - {"bolt", "antler", "flame", "tree", "wave", "fan", "pagoda", "shan"}
