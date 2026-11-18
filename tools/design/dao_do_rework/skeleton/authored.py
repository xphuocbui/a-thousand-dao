"""Hand-authored cluster shapes (user 2026-11-15: "Please take a moment first to hand author some creative and nice
looking node shapes"; the outer ring should carry the biggest and strongest clusters, as PoE's does).

Each shape is drawn freely in its own frame: the entry (node 0) at the bottom on the axis, the figure opening upward,
symmetric about the axis. Arcs carry their own centre. Every shape must keep the cluster rules (mirrored, no dead-end
minor node, the first notable at least two steps in, 2-4 notables), keep nodes 0.72 apart and not cross itself.

Usage: python -I tools/design/dao_do_rework/skeleton/authored.py <gallery.html>
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))


class Shape:
    def __init__(self, name):
        self.name, self.nodes, self.links = name, [], []

    def n(self, u, v, role="s"):
        """A node (and its mirror when u != 0). Returns the index, or (right, left) for a mirrored pair."""
        u, v = round(u, 4), round(v, 4)
        idx = []
        for x in ((u, -u) if abs(u) > 1e-6 else (u,)):
            for k, (a, b, _) in enumerate(self.nodes):
                if abs(a - x) < 1e-3 and abs(b - v) < 1e-3:
                    idx.append(k); break
            else:
                self.nodes.append((x, v, role)); idx.append(len(self.nodes) - 1)
        return idx[0] if len(idx) == 1 else tuple(idx)

    def l(self, a, b, c=None, mirror=True):
        """A link a-b (indices or mirrored pairs), straight or an arc round c (u, v); mirrored when given pairs."""
        A = a if isinstance(a, tuple) else (a, a)
        Bb = b if isinstance(b, tuple) else (b, b)
        for k in range(2 if mirror else 1):
            x, y = A[k], Bb[k]
            cc = None if c is None else ((c[0] if k == 0 else -c[0]), c[1])
            if x != y and not any({x, y} == {p, q} for p, q, _ in self.links):
                self.links.append((x, y, cc))

    def chain(self, *pts, c=None):
        for a, b in zip(pts, pts[1:]):
            self.l(a, b, c)


def pol(r, a, c=(0.0, 0.0)):
    return (c[0] + r * math.sin(math.radians(a)), c[1] + r * math.cos(math.radians(a)))


def peacock():
    S = Shape("Peacock fan")
    e = S.n(0, -3.0); a = S.n(0, -1.8); h = S.n(0, -0.6)
    S.chain(e, a, h)
    tips = []
    for ang, role in ((0, "N"), (32, "s"), (64, "N")):
        m = S.n(*pol(1.5, ang, (0, -0.6)))
        t = S.n(*pol(3.0, ang, (0, -0.6)), role)
        S.l(h, m); S.l(m, t); tips.append(t)
    order = [tips[2][1], tips[1][1], tips[0], tips[1][0], tips[2][0]]
    for x, y in zip(order, order[1:]):
        S.l(x, y, (0, -0.6), mirror=False)
    return S


def crown():
    S = Shape("Crown")
    e = S.n(0, -2.6); a = S.n(0, -1.4)
    c = (0, 2.4)
    b0 = S.n(*pol(2.6, 180, c)); b1 = S.n(*pol(2.6, 140, c)); b2 = S.n(*pol(2.6, 100, c))
    S.chain(e, a, b0)
    S.l(b0, b1, c); S.l(b1, b2, c)
    s0 = S.n(0, 1.0); t0 = S.n(0, 2.1, "N"); S.chain(b0, s0, t0)
    s2 = S.n(pol(2.6, 100, c)[0] + 0.3, pol(2.6, 100, c)[1] + 1.2); t2 = S.n(pol(2.6, 100, c)[0] + 0.6, pol(2.6, 100, c)[1] + 2.3, "N")
    S.chain(b2, s2, t2)
    v1 = S.n(pol(2.6, 140, c)[0] - 0.1, pol(2.6, 140, c)[1] + 1.25)
    S.l(b1, v1); S.l(v1, s2)
    return S


def twin_moons():
    S = Shape("Twin moons")
    e = S.n(0, -1.0); a = S.n(0, 0.3); j = S.n(0, 1.7)
    S.chain(e, a, j)
    c = (2.1, 1.7)
    ring = [S.n(*pol(1.2, 270 + 60 * k, c), "N" if k == 3 else "s") for k in range(6)]
    for k in range(6):
        S.l(ring[k], ring[(k + 1) % 6], c)
    S.l(j, ring[0])
    return S


def lantern():
    S = Shape("Lantern")
    e = S.n(0, -3.4); bot = S.n(0, -2.2); top = S.n(0, 3.2, "N")
    S.l(e, bot)
    h = 1.294; c = (h, 0.5); r = math.hypot(h, 2.7)
    side = [S.n(*pol(r, a, c)) for a in (-120.5, -90.0, -59.5)]
    pts = [bot] + side + [top]
    for x, y in zip(pts, pts[1:]):
        S.l(x, y, (-h, 0.5) if False else None)
    mid = S.n(0, 0.5, "N"); hi = S.n(0, 2.0)
    S.l(side[1], mid); S.l(side[2], hi); S.chain(mid, hi, top)
    return S


def phoenix():
    S = Shape("Phoenix")
    e = S.n(0, -2.6); a = S.n(0, -1.4); h = S.n(0, -0.2); n1 = S.n(0, 1.1); crest = S.n(0, 2.3, "N")
    S.chain(e, a, h, n1, crest)
    w1 = S.n(1.2, 0.5); w2 = S.n(2.3, 1.3); tip = S.n(3.3, 2.4, "N"); under = S.n(3.2, 0.7)
    S.chain(h, w1, w2, tip); S.l(w2, under); S.l(under, tip)
    return S


def diamond_net():
    S = Shape("Diamond net")
    rows = [(-2.4, [0]), (-1.4, [1]), (-0.4, [0, 2]), (0.6, [1, 3]), (1.6, [0, 2]), (2.6, [1]), (3.6, [0])]
    S.n(0, -2.4)        # the entry first
    ids = {}
    for v, us in rows:
        for u in us:
            role = "N" if (abs(u) == 3 or (u == 0 and v == 3.6)) else "s"
            ids[(u, v)] = S.n(u * 1.0, v, role)
    for (u, v), i in ids.items():
        for du in (-1, 1):
            j = ids.get((u + du, round(v + 1.0, 1)))
            if j is not None:
                S.l(i, j)
    return S


def sun_wheel():
    S = Shape("Sun wheel")
    c = (0, 0)
    S.n(0, -3.1)
    ring = [S.n(*pol(1.94, 180 - 45 * k)) for k in range(5)]
    for x, y in zip(ring, ring[1:]):
        S.l(x, y, c)
    e = S.n(0, -3.1); S.l(e, ring[0])
    for k, role in ((2, "N"), (4, "N")):
        t = S.n(*pol(3.3, 180 - 45 * k), role); S.l(ring[k], t)
    hub = S.n(0, 0); S.l(ring[0], hub); S.l(hub, ring[4])
    return S


def comet():
    S = Shape("Comet")
    c = (0, 1.2)
    S.n(0, -2.6)
    ring = [S.n(*pol(1.45, 180 - 60 * k, c), "N" if k in (2, 3) else "s") for k in range(4)]
    for x, y in zip(ring, ring[1:]):
        S.l(x, y, c)
    e = S.n(0, -2.6); t1 = S.n(0, -1.4); S.chain(e, t1, ring[0])
    tl = S.n(0.95, -1.75); S.l(e, tl); S.l(tl, ring[1])
    return S


def rose():
    S = Shape("Rose")
    e = S.n(0, -2.5); a = S.n(0, -1.25); h = S.n(0, 0)
    S.chain(e, a, h)
    for ang, role in ((0, "N"), (78, "N")):
        d = (math.sin(math.radians(ang)), math.cos(math.radians(ang)))
        nrm = (d[1], -d[0])
        mid = (d[0] * 1.35, d[1] * 1.35)
        tip = S.n(d[0] * 2.7, d[1] * 2.7, role)
        p = S.n(mid[0] + 0.5 * nrm[0], mid[1] + 0.5 * nrm[1])
        q = S.n(mid[0] - 0.5 * nrm[0], mid[1] - 0.5 * nrm[1])
        pp = p if isinstance(p, tuple) else (p, p)
        qq = q if isinstance(q, tuple) else (q, q)
        S.l(h, pp); S.l(h, qq); S.l(pp, tip); S.l(qq, tip)
    return S


def pagoda():
    S = Shape("Pagoda")
    e = S.n(0, -3.2); ax = [S.n(0, v) for v in (-2.0, -0.6, 0.8)]; top = S.n(0, 2.2, "N")
    S.chain(e, *ax, top)
    t1 = S.n(1.7, -2.0); t2 = S.n(1.3, -0.6); t3 = S.n(0.9, 0.8)
    S.l(ax[0], t1); S.l(ax[1], t2); S.l(ax[2], t3)
    S.chain(t1, t2, t3, top)
    eave = S.n(2.6, -1.5, "N"); S.l(t1, eave)
    return S


def great_wheel():
    S = Shape("Great wheel")
    c = (0, 0)
    S.n(0, -5.0)
    outer = [S.n(*pol(3.83, 180 - 30 * k), "N" if k == 6 else "s") for k in range(7)]
    for x, y in zip(outer, outer[1:]):
        S.l(x, y, c)
    inner = [S.n(*pol(1.94, 180 - 60 * k)) for k in range(4)]
    for x, y in zip(inner, inner[1:]):
        S.l(x, y, c)
    e = S.n(0, -5.0); S.l(e, outer[0]); S.l(outer[0], inner[0])
    S.l(inner[1], outer[2]); S.l(inner[3], outer[6])
    hub = S.n(0, 0, "N"); S.l(inner[0], hub)
    S.l(inner[2], S.n(*pol(2.9, 60), "N")); S.l(S.n(*pol(2.9, 60), "N"), outer[4])
    return S


def moon_arch():
    S = Shape("Moon arch")
    e = S.n(0, -2.4); a = S.n(0, -1.2)
    S.l(e, a)
    p0 = S.n(1.6, -1.2); p1 = S.n(1.6, 0.0); p2 = S.n(1.6, 1.2)
    S.l(a, p0); S.chain(p0, p1, p2)
    c = (0, 1.2)
    arch = [S.n(*pol(1.6, 90 - 45 * k, c), "N" if k == 2 else "s") for k in range(3)]
    S.l(p2, arch[0][0] if isinstance(arch[0], tuple) else arch[0])
    S.l(arch[0], arch[1], c); S.l(arch[1], arch[2], c)
    inner = S.n(0, 0.4, "N")
    S.l(p1, S.n(0.8, 0.4)); S.l(S.n(0.8, 0.4), inner)
    return S


def lotus_throne():
    S = Shape("Lotus throne")
    e = S.n(0, -2.4); c = (0, -1.0); hub = S.n(*c)
    S.l(e, hub)
    arcs = []
    for r, angs in ((1.45, (0, 45, 90)), (2.85, (0, 30, 60, 90)), (4.2, (0, 22.5, 45, 67.5, 90))):
        ids = [S.n(*pol(r, a, c), "N" if (r == 4.2 and a == 0) or (r == 2.85 and a == 60) else "s") for a in angs]
        for x, y in zip(ids, ids[1:]):
            S.l(x, y, c)
        arcs.append(ids)
    S.chain(hub, arcs[0][0], arcs[1][0], arcs[2][0])
    S.chain(arcs[0][-1], arcs[1][-1], arcs[2][-1])
    S.l(hub, arcs[0][-1])
    return S


def star_wheel():
    S = Shape("Star wheel")
    e = S.n(0, -4.2)
    hub = S.n(0, 0)
    inner, outer = {}, {}
    for a in range(0, 360, 45):
        if a > 180:
            continue
        inner[a] = S.n(*pol(1.45, a)); outer[a] = S.n(*pol(2.85, a), "N" if a in (0, 90) else "s")
    S.l(e, outer[180]); 
    for a in inner:
        S.l(hub, inner[a]); S.l(inner[a], outer[a])
    order = [180, 135, 90, 45, 0]
    for x, y in zip(order, order[1:]):
        S.l(outer[x], outer[y], (0, 0))
    return S


def great_gate():
    S = Shape("Great gate")
    e = S.n(0, -3.6); base = S.n(0, -2.4)
    S.l(e, base)
    p = [S.n(2.0, v) for v in (-2.4, -1.0, 0.4, 1.6, 2.8)]
    S.l(base, p[0]); S.chain(*p)
    b1 = S.n(1.0, 1.6); bm = S.n(0, 1.6, "N"); S.chain(p[3], b1, bm)
    t1 = S.n(1.0, 2.8); tm = S.n(0, 2.8); S.chain(p[4], t1, tm)
    end = S.n(3.0, 3.2, "N"); S.l(p[4], end)
    S.l(bm, tm)
    return S


def hourglass():
    S = Shape("Hourglass")
    e = S.n(0, -3.2); b = S.n(0, -2.0)
    S.l(e, b)
    lo = S.n(1.3, -0.8); w = S.n(0, 0.2, "N"); hi = S.n(1.3, 1.2, "N"); t = S.n(0, 2.4)
    S.l(b, lo); S.l(lo, w); S.l(w, hi); S.l(hi, t)
    return S


def bow():
    S = Shape("Drawn bow")
    e = S.n(0, -2.6); a = S.n(0, -1.4); g = S.n(0, -0.2)
    S.chain(e, a, g)
    c = (0, -3.4)
    b1 = S.n(*pol(3.2, 40, c)); tip = S.n(*pol(3.2, 75, c), "N")
    S.l(g, b1, c); S.l(b1, tip, c)
    s1 = S.n(0, 1.0); s2 = S.n(0, 2.2, "N")
    S.chain(g, s1, s2)
    return S


def butterfly():
    S = Shape("Butterfly")
    e = S.n(0, -2.6); b0 = S.n(0, -1.4); b1 = S.n(0, -0.2); b2 = S.n(0, 1.0); head = S.n(0, 2.2, "N")
    S.chain(e, b0, b1, b2, head)
    u1 = S.n(1.3, 0.9); u2 = S.n(2.5, 1.6, "N"); u3 = S.n(2.4, 0.3)
    S.chain(b1, u1, u2); S.chain(u2, u3); S.l(u3, b1)
    l1 = S.n(1.5, -1.0)
    S.chain(b0, l1, u3)
    return S


def candelabra():
    S = Shape("Candelabra")
    e = S.n(0, -2.7); h = S.n(0, -1.5)
    S.l(e, h)
    a1 = S.n(1.2, -1.0); a2 = S.n(1.7, 0.2); a3 = S.n(1.7, 1.4, "N")
    S.chain(h, a1, a2, a3)
    c1 = S.n(0, -0.3); c2 = S.n(0, 0.9); c3 = S.n(0, 2.1, "N")
    S.chain(h, c1, c2, c3)
    return S


def shield():
    S = Shape("Shield")
    e = S.n(0, -3.0); tip = S.n(0, -1.8)
    S.l(e, tip)
    lo = S.n(1.6, -0.6); hi = S.n(1.6, 1.0, "N"); top = S.n(0, 1.8)
    S.chain(tip, lo, hi, top)
    mid = S.n(0, 0.2, "N")
    S.l(lo, mid)
    return S


def halo():
    S = Shape("Halo")
    e = S.n(0, -2.6)
    c = (0, 0)
    ring = [S.n(*pol(1.45, 180 - 60 * k), "N" if k == 2 else "s") for k in range(4)]
    for x, y in zip(ring, ring[1:]):
        S.l(x, y, c)
    S.l(e, ring[0])
    arc = [S.n(*pol(2.7, a), "N" if a == 0 else "s") for a in (70, 35, 0)]
    S.l(ring[2], arc[0])
    S.l(arc[0], arc[1], c); S.l(arc[1], arc[2], c)
    return S


def key():
    S = Shape("Key")
    e = S.n(0, -3.0); s1 = S.n(0, -1.8); s2 = S.n(0, -0.6)
    S.chain(e, s1, s2)
    ta = S.n(0.95, -1.9); tb = S.n(1.75, -1.3, "N"); S.chain(s1, ta, tb)
    c = (0, 0.85)
    ring = [S.n(*pol(1.45, 180 - 60 * k, c), "N" if k == 3 else "s") for k in range(4)]
    for x, y in zip(ring, ring[1:]):
        S.l(x, y, c)
    S.l(s2, ring[0])
    return S


def ladder():
    S = Shape("Ladder")
    e = S.n(0, -2.6); r0 = S.n(0, -1.4)
    S.l(e, r0)
    rails = [S.n(0.95, v) for v in (-1.4, -0.2, 1.0)]
    S.l(r0, rails[0]); S.chain(*rails)
    mid = S.n(0, -0.2, "N"); S.l(rails[1], mid)
    c = (0, 1.0)
    top = S.n(0, 1.95, "N")
    S.l(rails[2], top, c)
    return S


SHAPES2 = [hourglass, bow, butterfly, candelabra, shield, halo, key, ladder]


# --- small shapes (user 2026-11-16, after the size survey: PoE's groups are mostly 1-6 nodes with one notable) ---
def lone():
    S = Shape("Lone notable")
    S.n(0, 0, "N")
    return S


def spur():
    S = Shape("Spur")
    S.chain(S.n(0, -1.2), S.n(0, 0), S.n(0, 1.2, "N"))
    return S


def long_spur():
    S = Shape("Long spur")
    S.chain(S.n(0, -1.8), S.n(0, -0.6), S.n(0, 0.6), S.n(0, 1.8, "N"))
    return S


def diamond():
    S = Shape("Diamond")
    e = S.n(0, -1.0); sd = S.n(0.85, 0.0); t = S.n(0, 1.0, "N")
    S.l(e, sd); S.l(sd, t)
    return S


def lens():
    S = Shape("Lens")
    e = S.n(0, -1.2); sd = S.n(0.75, 0.0); t = S.n(0, 1.2, "N")
    c = (-0.585, 0.0)       # equidistant from the entry, the side and the tip
    S.l(e, sd, c); S.l(sd, t, c)
    return S


def kite():
    S = Shape("Kite")
    e = S.n(0, -1.8); st = S.n(0, -0.6); sd = S.n(0.9, 0.4); t = S.n(0, 1.4, "N")
    S.l(e, st); S.l(st, sd); S.l(sd, t)
    return S


def fork():
    S = Shape("Fork")
    e = S.n(0, -1.2); h = S.n(0, 0); t = S.n(0.95, 0.95, "N")
    S.l(e, h); S.l(h, t)
    return S


def ring6():
    S = Shape("Little ring")
    c = (0, 0)
    ring = [S.n(*pol(1.0, 180 - 60 * k), "N" if k == 3 else "s") for k in range(4)]
    for x, y in zip(ring, ring[1:]):
        S.l(x, y, c)
    return S


def cup():
    S = Shape("Cup")
    e = S.n(0, -1.4); b = S.n(0, -0.3)
    S.l(e, b)
    c = (0, 0.9)
    r1 = S.n(*pol(1.2, 120, c)); r2 = S.n(*pol(1.2, 60, c), "N")
    S.l(b, r1, c); S.l(r1, r2, c)
    return S


def rails():
    S = Shape("Rails")
    e = S.n(0, -1.6); a = S.n(0.6, -0.6); b = S.n(0.6, 0.6); t = S.n(0, 1.5, "N")
    S.l(e, a); S.l(a, b); S.l(b, t)
    return S


def small_fan():
    S = Shape("Small fan")
    e = S.n(0, -1.4); h = S.n(0, -0.3)
    S.l(e, h)
    c = (0, -0.3)
    m = S.n(0, 0.95, "N"); sd = S.n(*pol(1.25, 50, c))
    S.l(h, m); S.l(h, sd); S.l(sd, m, c)
    return S


def arrow():
    S = Shape("Arrowhead")
    e = S.n(0, -1.6); s1 = S.n(0, -0.5); t = S.n(0, 0.8, "N"); w = S.n(0.9, -0.1)
    S.chain(e, s1, t); S.l(w, t); S.l(s1, w)
    return S


def chalice():
    S = Shape("Chalice")
    e = S.n(0, -1.8); s1 = S.n(0, -0.7); l = S.n(0.9, 0.2); r = S.n(0.9, 1.3, "N")
    S.l(e, s1); S.l(s1, l); S.l(l, r)
    m = S.n(0, 0.5); S.l(s1, m)
    S.l(m, l)
    return S


# --- webs and lattices (user 2026-11-16: "this lacks so much creativity, take a look again at poe's trees"; PoE 2's
# X lattice, spoked hexagon, triangle lattice) ---
def cross_web():
    S = Shape("Cross web")
    e = S.n(0, -2.3)
    b = S.n(1.6, -1.6); bi = S.n(0.8, -0.8); c = S.n(0, 0); ti = S.n(0.8, 0.8); t = S.n(1.6, 1.6, "N")
    ct = S.n(0, 1.15); top = S.n(0, 2.3, "N")
    S.l(e, b); S.l(b, bi); S.l(bi, c); S.l(c, ti); S.l(ti, t); S.l(c, ct); S.l(ct, top)
    return S


def hex_web():
    S = Shape("Spoked hexagon")
    e = S.n(0, -2.8)
    ring = [S.n(*pol(1.6, 180 - 60 * k), "N" if k == 2 else "s") for k in range(4)]
    for x, y in zip(ring, ring[1:]):
        S.l(x, y)
    S.l(e, ring[0])
    hub = S.n(0, 0, "N")
    for r in ring:
        S.l(hub, r)
    return S


def tri_lattice():
    S = Shape("Triangle lattice")
    e = S.n(0, -2.0)
    r1 = S.n(0.6, -1.0); m = S.n(0, 0); sd = S.n(1.2, 0, "N"); r3 = S.n(0.6, 1.0); top = S.n(0, 2.0, "N")
    S.l(e, r1); S.l(r1, m); S.l(r1, sd); S.l(m, r3); S.l(sd, r3); S.l(r3, top)
    return S


def twin_ring():
    S = Shape("Twin rings")
    e = S.n(0, -2.0); j = S.n(0, -0.8)
    S.l(e, j)
    c = (1.55, 0.2)
    ring = [S.n(*pol(1.0, a, c), "N" if a == 90 else "s") for a in (210, 270, 330, 30, 90, 150)]
    for x, y in zip(ring, ring[1:] + ring[:1]):
        S.l(x, y, c)
    S.l(j, ring[1])
    return S


WEBS = [cross_web, hex_web, tri_lattice, twin_ring]


# --- satellites (PoE 2: 18 % of visible clusters are a main group with 1-2 single nodes linked straight to it) ---
def diamond_sats():
    S = Shape("Diamond and satellites")
    e = S.n(0, -1.0); sd = S.n(0.85, 0.0); t = S.n(0, 1.0, "N")
    S.l(e, sd); S.l(sd, t)
    sat = S.n(2.0, 0.3, "N"); S.l(sd, sat)
    return S


def lens_sat():
    S = Shape("Lens and satellite")
    e = S.n(0, -1.2); sd = S.n(0.75, 0.0); t = S.n(0, 1.2)
    c = (-0.585, 0.0)
    S.l(e, sd, c); S.l(sd, t, c)
    sat = S.n(0, 2.3, "N"); S.l(t, sat)
    return S


def kite_sats():
    S = Shape("Kite and satellites")
    e = S.n(0, -1.8); st = S.n(0, -0.6); sd = S.n(0.9, 0.4); t = S.n(0, 1.4, "N")
    S.l(e, st); S.l(st, sd); S.l(sd, t)
    sat = S.n(2.0, 0.9, "N"); S.l(sd, sat)
    return S


SATS = [diamond_sats, lens_sat, kite_sats]



# --- forty more (user 2026-11-16: "some shape usage frequency are too high ... be creative, first think of 40 more
# patterns of cluster ... combos of 2 clusters, and combos of 3, and 4 if possible") ---
def trident():
    S = Shape("Trident")
    e = S.n(0, -2.4); s = S.n(0, -1.2); h = S.n(0, 0)
    S.chain(e, s, h)
    p1 = S.n(1.1, 0.4); p2 = S.n(1.1, 1.6, "N"); m1 = S.n(0, 1.2); m2 = S.n(0, 2.4, "N")
    S.chain(h, p1, p2); S.chain(h, m1, m2)
    return S


def horseshoe():
    S = Shape("Horseshoe")
    e = S.n(0, -2.5)
    c = (0, 0.2)
    pts = [S.n(*pol(1.5, a, c), "N" if a == 25 else "s") for a in (180, 125, 70, 25)]
    S.l(e, pts[0])
    for x, y in zip(pts, pts[1:]):
        S.l(x, y, c)
    return S


def eye():
    S = Shape("Eye")
    e = S.n(0, -2.7); b = S.n(0, -1.5); sd = S.n(1.1, 0); t = S.n(0, 1.5, "N"); p = S.n(0, 0, "N")
    S.l(e, b)
    c = (-0.473, 0)
    S.l(b, sd, c); S.l(sd, t, c)
    S.l(p, sd)
    return S


def twin_curls():
    S = Shape("Twin curls")
    e = S.n(0, -2.4); s = S.n(0, -1.2)
    S.l(e, s)
    c = (1.0, 0.3)
    pts = [S.n(*pol(0.9, a, c), "N" if a == -40 else "s") for a in (200, 110, 20, -40)]
    S.l(s, pts[0])
    for x, y in zip(pts, pts[1:]):
        S.l(x, y, c)
    return S


def lyre():
    S = Shape("Lyre")
    e = S.n(0, -2.6); s = S.n(0, -1.4); h = S.n(0, -0.3)
    S.chain(e, s, h)
    a1 = S.n(1.0, 0.3); a2 = S.n(1.4, 1.4); a3 = S.n(1.0, 2.4, "N")
    S.chain(h, a1, a2, a3)
    m = S.n(0, 0.9); t = S.n(0, 2.1, "N")
    S.chain(h, m, t); S.l(t, a3)
    return S


def bell():
    S = Shape("Bell")
    e = S.n(0, -2.2); s = S.n(0, -1.0); lip = S.n(1.3, -1.0); sh = S.n(1.2, 0.3, "N"); top = S.n(0, 1.2, "N")
    S.l(e, s); S.l(s, lip); S.chain(lip, sh, top)
    cl = S.n(0, 0.1); S.chain(s, cl, top)
    return S


def antlers():
    S = Shape("Antlers")
    e = S.n(0, -2.6); s = S.n(0, -1.4)
    S.l(e, s)
    f = S.n(0.9, -0.6); k = S.n(1.3, 0.5); t1 = S.n(2.3, 0.9, "N"); b = S.n(1.0, 1.6); t2 = S.n(1.6, 2.5, "N")
    S.chain(s, f, k, t1); S.chain(k, b, t2)
    return S


def tuning_fork():
    S = Shape("Tuning fork")
    e = S.n(0, -2.4); s = S.n(0, -1.2)
    S.l(e, s)
    a = S.n(0.9, -0.5); b = S.n(0.9, 0.7); c = S.n(0.9, 1.9, "N")
    S.chain(s, a, b, c)
    return S


def torii():
    S = Shape("Torii")
    e = S.n(0, -2.4); base = S.n(0, -1.2)
    S.l(e, base)
    p0 = S.n(1.0, -0.7); p1 = S.n(1.0, 0.5); j = S.n(1.0, 1.7); tip = S.n(1.95, 1.9, "N"); mid = S.n(0, 1.8, "N")
    S.chain(base, p0, p1, j, tip); S.l(j, mid)
    return S


def delta():
    S = Shape("Delta")
    e = S.n(0, -2.2); b = S.n(0, -1.0); cn = S.n(1.2, -1.0); md = S.n(0.6, 0.3, "N"); ap = S.n(0, 1.6, "N")
    S.l(e, b); S.l(b, cn); S.chain(cn, md, ap)
    return S


def double_chevron():
    S = Shape("Double chevron")
    e = S.n(0, -2.2); v = S.n(0, -1.0)
    S.l(e, v)
    a1 = S.n(0.9, -0.2); a2 = S.n(1.8, 0.6, "N"); m = S.n(0, 0.4); b1 = S.n(0.9, 1.2); b2 = S.n(1.7, 2.0, "N")
    S.chain(v, a1, a2); S.chain(v, m, b1, b2)
    return S


def cross():
    S = Shape("Cross")
    e = S.n(0, -2.4); c0 = S.n(0, -1.2); c = S.n(0, 0)
    S.chain(e, c0, c)
    a = S.n(1.2, 0); at = S.n(2.3, 0, "N"); t = S.n(0, 1.2); tt = S.n(0, 2.3, "N")
    S.chain(c, a, at); S.chain(c, t, tt)
    return S


def compass():
    S = Shape("Compass")
    e = S.n(0, -2.4); bt = S.n(0, -1.2); c = S.n(0, 0)
    S.l(e, bt)
    o = (0, 0)
    lo = S.n(*pol(1.2, 135)); sd = S.n(1.2, 0); hi = S.n(*pol(1.2, 45)); top = S.n(0, 1.2)
    S.l(bt, lo, o); S.l(lo, sd, o); S.l(sd, hi, o); S.l(hi, top, o)
    for x in (bt, sd, top):
        S.l(c, x)
    S.l(sd, S.n(2.3, 0, "N")); S.l(top, S.n(0, 2.3, "N"))
    return S


def anchor():
    S = Shape("Anchor")
    e = S.n(0, -2.4); cr = S.n(0, -1.2)
    S.l(e, cr)
    o = (0, 0)
    f1 = S.n(*pol(1.2, 120)); f2 = S.n(*pol(1.2, 70), "N")
    S.l(cr, f1, o); S.l(f1, f2, o)
    sh = S.n(0, 0); s2 = S.n(0, 1.2); st = S.n(0.95, 1.4); top = S.n(0, 2.3, "N")
    S.chain(cr, sh, s2); S.l(s2, st); S.l(st, top)
    return S


def koi():
    S = Shape("Koi")
    e = S.n(0, -2.6); tl = S.n(0.8, -1.6); b = S.n(0, -0.8); sd = S.n(0.9, 0.4); hd = S.n(0, 1.6, "N"); ey = S.n(0, 0.4, "N")
    S.l(e, tl); S.l(tl, b)
    c = (-0.35, 0.4)
    S.l(b, sd, c); S.l(sd, hd, c); S.l(ey, sd)
    return S


def tiara():
    S = Shape("Tiara")
    e = S.n(0, -2.2); b = S.n(0, -1.0); m = S.n(1.2, -0.7); o = S.n(2.1, 0.0); sp = S.n(2.2, 1.2, "N"); cs = S.n(0, 0.2)
    S.l(e, b); S.chain(b, m, o, sp); S.chain(b, cs, S.n(0, 1.4, "N"))
    return S


def eclipse():
    S = Shape("Eclipse")
    e = S.n(0, -3.2)
    c = (0, 0)
    arc = [S.n(*pol(2.0, a), "N" if a == 35 else "s") for a in (180, 130, 80, 35)]
    S.l(e, arc[0])
    for x, y in zip(arc, arc[1:]):
        S.l(x, y, c)
    i1 = S.n(0, -0.9); i2 = S.n(0, 0.2, "N")
    S.chain(arc[0], i1, i2)
    return S


def twin_bolts():
    S = Shape("Twin bolts")
    e = S.n(0, -2.4); s = S.n(0, -1.2)
    S.l(e, s)
    z = [S.n(0.9, -0.5), S.n(0.5, 0.6), S.n(1.4, 1.3), S.n(1.0, 2.4, "N")]
    S.chain(s, *z)
    return S


def flame():
    S = Shape("Flame")
    e = S.n(0, -2.4); b = S.n(0, -1.2)
    S.l(e, b)
    o1 = S.n(1.1, -0.5); o2 = S.n(1.3, 0.7, "N"); o3 = S.n(0.7, 1.7); tip = S.n(0, 2.6, "N")
    S.chain(b, o1, o2, o3, tip)
    core = S.n(0, 0.1); S.l(b, core); S.l(core, o2)
    return S


def beads():
    S = Shape("Prayer beads")
    e = S.n(0, -2.6); b = S.n(0, -1.5); s1 = S.n(0.75, -0.75); m = S.n(0, 0, "N"); s2 = S.n(0.75, 0.75); t = S.n(0, 1.5, "N")
    S.l(e, b); S.chain(b, s1, m); S.chain(m, s2, t)
    return S


def four_star():
    S = Shape("Four-point star")
    e = S.n(0, -3.0); bt = S.n(0, -1.8); lo = S.n(0.6, -0.6); tip = S.n(1.8, 0, "N"); hi = S.n(0.6, 0.6); top = S.n(0, 1.8, "N")
    S.l(e, bt); S.chain(bt, lo, tip, hi, top)
    return S


def dragonfly():
    S = Shape("Dragonfly")
    e = S.n(0, -2.8); b1 = S.n(0, -1.6); b2 = S.n(0, -0.4); b3 = S.n(0, 0.8); hd = S.n(0, 2.0, "N")
    S.chain(e, b1, b2, b3, hd)
    w1 = S.n(1.2, -0.7); w2 = S.n(2.1, -0.1); w3 = S.n(2.2, 1.0, "N"); w4 = S.n(1.2, 1.4)
    S.chain(b2, w1, w2, w3); S.chain(b3, w4, w3)
    return S


def trellis():
    S = Shape("Trellis")
    e = S.n(0, -2.2); b = S.n(0, -1.0); p1 = S.n(0.8, -0.2); m = S.n(0, 0.6); o = S.n(1.6, 0.6, "N"); p2 = S.n(0.8, 1.4); t = S.n(0, 2.2, "N")
    S.l(e, b); S.chain(b, p1, m); S.chain(p1, o, p2); S.chain(m, p2, t)
    return S


def rising_sun():
    S = Shape("Rising sun")
    e = S.n(0, -2.2); c = S.n(0, -1.0)
    S.l(e, c)
    o = (0, -1.0)
    a0 = S.n(1.6, -1.0); a1 = S.n(*pol(1.6, 45, o)); top = S.n(0, 0.6)
    S.l(c, a0); S.l(a0, a1, o); S.l(a1, top, o)
    S.l(top, S.n(0, 1.8, "N")); S.l(a1, S.n(2.0, 1.0, "N"))
    return S


def braid():
    S = Shape("Braid")
    e = S.n(0, -2.8); sp = [S.n(0, v) for v in (-1.6, -0.4, 0.8)]; top = S.n(0, 2.0, "N")
    S.chain(e, *sp, top)
    for k, v in enumerate((-1.0, 0.2, 1.4)):
        r = S.n(1.0, v, "N" if k == 2 else "s")
        S.l(sp[k], r); S.l(r, sp[k + 1] if k < 2 else top)
    return S


def heart():
    S = Shape("Heart")
    e = S.n(0, -2.4); tp = S.n(0, -1.2); sd = S.n(1.2, 0); lb = S.n(1.0, 1.2, "N"); dp = S.n(0, 0.6)
    S.l(e, tp); S.chain(tp, sd, lb, dp)
    return S


def seal():
    S = Shape("Seal")
    e = S.n(0, -2.7)
    h = [S.n(*pol(1.5, a), "N" if a in (0, 120) else "s") for a in (180, 120, 60, 0)]
    S.l(e, h[0])
    for x, y in zip(h, h[1:]):
        S.l(x, y)
    S.l(h[0], h[2]); S.l(h[2][0], h[2][1], mirror=False)
    return S


def bonsai():
    S = Shape("Bonsai")
    e = S.n(0, -2.8); t1 = S.n(0, -1.6); t2 = S.n(0, -0.4)
    S.chain(e, t1, t2)
    br = S.n(1.0, 0.2); bt = S.n(1.9, 0.0, "N"); S.chain(t2, br, bt)
    c0 = S.n(0, 0.8); cs = S.n(0.8, 1.6); ct = S.n(0, 2.3, "N")
    S.chain(t2, c0, cs, ct)
    return S


def claw():
    S = Shape("Claw")
    e = S.n(0, -2.4); s = S.n(0, -1.2)
    S.l(e, s)
    a = S.n(1.0, -0.6); b = S.n(1.5, 0.5); t = S.n(1.0, 1.5, "N")
    S.chain(s, a, b, t)
    return S


def lattice_window():
    S = Shape("Lattice window")
    e = S.n(0, -2.4); bm = S.n(0, -1.2); lc = S.n(1.2, -1.2); sd = S.n(1.2, 0); tc = S.n(1.2, 1.2, "N"); tm = S.n(0, 1.2, "N"); c = S.n(0, 0)
    S.l(e, bm); S.chain(bm, lc, sd, tc, tm)
    S.l(bm, c); S.l(c, sd); S.l(c, tm)
    return S


def twin_towers():
    S = Shape("Twin towers")
    e = S.n(0, -2.4); s = S.n(0, -1.2)
    S.l(e, s)
    a = S.n(0.9, -0.5); b = S.n(0.9, 0.6); c = S.n(0.9, 1.7, "N")
    S.chain(s, a, b, c)
    S.l(b, S.n(0, 0.6))
    return S


def rainbow():
    S = Shape("Rainbow")
    e = S.n(0, -2.0); h = S.n(0, -0.8)
    S.l(e, h)
    o = (0, -0.8)
    ft = S.n(1.5, -0.8); md = S.n(*pol(1.5, 45, o)); top = S.n(0, 0.7)
    S.l(h, ft); S.l(ft, md, o); S.l(md, top, o)
    S.l(top, S.n(0, 1.9, "N"))
    return S


def necklace():
    S = Shape("Necklace")
    e = S.n(0, -2.4); db = S.n(0, -1.3); ds = S.n(0.6, -0.6); dt = S.n(0, 0.1, "N")
    S.l(e, db); S.chain(db, ds, dt)
    c1 = S.n(1.4, -0.2); c2 = S.n(2.0, 0.8, "N")
    S.chain(ds, c1, c2)
    return S


def three_peaks():
    S = Shape("Three peaks")
    e = S.n(0, -2.3); h = S.n(0, -1.1); b = S.n(1.3, -1.1); o = S.n(2.4, -0.8); pk = S.n(1.9, 0.4, "N"); vl = S.n(1.2, 0.0); top = S.n(0, 1.0, "N")
    S.l(e, h); S.chain(h, b, o, pk, vl, top); S.l(b, vl)
    return S


def scallop():
    S = Shape("Scallop")
    e = S.n(0, -2.4); h = S.n(0, -1.2)
    S.l(e, h)
    o = (0, -1.2)
    arc = [S.n(*pol(2.0, a, o), "N" if a in (0, 60) else "s") for a in (60, 30, 0)]
    for x, y in zip(arc, arc[1:]):
        S.l(x, y, o)
    S.l(h, arc[0]); S.l(h, arc[2])
    return S


def moth():
    S = Shape("Moth")
    e = S.n(0, -2.4); b0 = S.n(0, -1.2); b1 = S.n(0, 0); hd = S.n(0, 1.2, "N")
    S.chain(e, b0, b1, hd)
    up = S.n(1.3, 0.6); lo = S.n(1.6, -0.6, "N")
    S.chain(b1, up, lo, b0)
    return S


def infinity():
    S = Shape("Infinity")
    e = S.n(0, -2.4); s = S.n(0, -1.2); c = S.n(0, 0, "N")
    S.chain(e, s, c)
    a = S.n(0.9, 0.75); t = S.n(2.0, 0, "N"); b = S.n(0.9, -0.75)
    S.chain(c, a, t, b, c)
    return S


def wreath():
    S = Shape("Wreath")
    e = S.n(0, -3.0)
    o = (0, 0)
    ring = [S.n(*pol(1.8, a), "N" if a in (0, 90) else "s") for a in (180, 135, 90, 45, 0)]
    S.l(e, ring[0])
    for x, y in zip(ring, ring[1:]):
        S.l(x, y, o)
    return S


def halberd():
    S = Shape("Halberd")
    e = S.n(0, -2.8); s1 = S.n(0, -1.6); s2 = S.n(0, -0.4); s3 = S.n(0, 0.8); tip = S.n(0, 2.0, "N")
    S.chain(e, s1, s2, s3, tip)
    bl = S.n(0.9, 0.4); bt = S.n(1.3, 1.4, "N")
    S.chain(s2, bl, s3); S.l(bl, bt)
    return S


def crescent_moon():
    S = Shape("Crescent moon")
    e = S.n(0, -2.8); bt = S.n(0, -1.6)
    S.l(e, bt)
    o1 = S.n(1.1, -1.2); o2 = S.n(1.65, -0.2); hn = S.n(1.5, 0.9, "N")
    S.chain(bt, o1, o2, hn)
    i0 = S.n(0, -0.4); i1 = S.n(0.85, 0.05)
    S.l(bt, i0); S.chain(i0, i1, hn)
    return S


MORE = [trident, horseshoe, eye, twin_curls, lyre, bell, antlers, tuning_fork, torii, delta, double_chevron, cross,
        compass, anchor, koi, tiara, eclipse, twin_bolts, flame, beads, four_star, dragonfly, trellis, rising_sun,
        braid, heart, seal, bonsai, claw, lattice_window, twin_towers, rainbow, necklace, three_peaks, scallop, moth,
        infinity, wreath, halberd, crescent_moon]

# combos of the new shapes round one road hub (name, [(shape, angle off the pattern's facing)]): PoE 2 pairs one big
# cluster with a small one more often than two alike, so most mix shapes and sizes; angles tuned so neighbouring
# clusters sit about 1.3 apart (PoE 2's median gap) with no crossings and clear of the incoming road
COMBOS_MORE = [
    # pairs
    ("Koi pond", [("Koi", 30), ("Koi", -30)]),
    ("Bell and chevrons", [("Bell", 10), ("Double chevron", 70)]),
    ("Anchor and horseshoe", [("Anchor", -10), ("Horseshoe", -70)]),
    ("Twin dragonflies", [("Dragonfly", 35), ("Dragonfly", -35)]),
    ("Torii and delta", [("Torii", 5), ("Delta", 70)]),
    ("Sun and peaks", [("Rising sun", -10), ("Three peaks", -95)]),
    # threes
    ("Three flames", [("Flame", 0), ("Flame", 55), ("Flame", -55)]),
    ("Moon phases", [("Crescent moon", 0), ("Eclipse", 65), ("Horseshoe", -65)]),
    ("Bonsai garden", [("Bonsai", 0), ("Heart", 55), ("Prayer beads", -55)]),
    ("Mountain gate", [("Three peaks", 0), ("Torii", 75), ("Tuning fork", -75)]),
    ("Trident and claws", [("Trident", 0), ("Claw", 55), ("Claw", -55)]),
    ("Lantern night", [("Moth", 0), ("Bell", 70), ("Twin curls", -70)]),
    # fours
    ("Four winds", [("Twin bolts", 25), ("Twin bolts", -25), ("Koi", 105), ("Koi", -105)]),
    ("Shrine yard", [("Torii", 35), ("Lattice window", -35), ("Bell", 110), ("Rainbow", -110)]),
    ("Moth circle", [("Moth", 35), ("Moth", -35), ("Lyre", 110), ("Lyre", -110)]),
    ("Star chart", [("Compass", 0), ("Four-point star", 80), ("Seal", -80), ("Wreath", 140)]),
]


SMALL = [lone, spur, long_spur, diamond, lens, kite, fork, ring6, cup, rails, small_fan, arrow, chalice]

# small combos: 2-3 small clusters (or lone notables) round one road hub
COMPOUNDS_SMALL = [
    ("Horns", [("Lone notable", 45), ("Lone notable", -45)]),
    ("Three stars", [("Lone notable", 0), ("Lone notable", 70), ("Lone notable", -70)]),
    ("Twin diamonds", [("Diamond", 45), ("Diamond", -45)]),
    ("Twin lenses", [("Lens", 40), ("Lens", -40)]),
    ("Spur and horns", [("Long spur", 0), ("Lone notable", 75), ("Lone notable", -75)]),
    ("Ring and spurs", [("Little ring", 0), ("Spur", 90), ("Spur", -90)]),
    ("Fork trio", [("Fork", 0), ("Fork", 115), ("Fork", -115)]),
    ("Kite and cups", [("Kite", 0), ("Cup", 80), ("Cup", -80)]),
    ("Rail pair", [("Rails", 35), ("Rails", -35)]),
    ("Fan and stars", [("Small fan", 0), ("Lone notable", 95), ("Lone notable", -95)]),
    ("Arrow volley", [("Arrowhead", 0), ("Arrowhead", 60), ("Arrowhead", -60)]),
    ("Chalice pair", [("Chalice", 50), ("Chalice", -50)]),
]

# patterns of 2 or 3 clusters that read as one figure (user 2026-11-16): a small road hub with the clusters round it,
# each its own group entered from the hub. (name, [(shape, angle off the pattern's facing)])
COMPOUNDS = [
    ("Twin roses", [("Rose", 60), ("Rose", -60)]),
    ("Twin lanterns", [("Lantern", 40), ("Lantern", -40)]),
    ("Paired wings", [("Phoenix", 55), ("Phoenix", -55)]),
    ("Trefoil of comets", [("Comet", 0), ("Comet", 115), ("Comet", -115)]),
    ("Candle and keys", [("Candelabra", 0), ("Key", 80), ("Key", -80)]),
    ("Shield wall", [("Shield", 0), ("Shield", 70), ("Shield", -70)]),
    ("Crowned pair", [("Crown", 0), ("Halo", 95), ("Halo", -95)]),
    ("Butterflies", [("Butterfly", 72), ("Butterfly", -72)]),
]


SHAPES = [peacock, crown, twin_moons, lantern, phoenix, diamond_net, sun_wheel, comet, rose, pagoda, moon_arch,
          great_wheel, lotus_throne, star_wheel, great_gate] + SHAPES2 + SMALL + WEBS + SATS + MORE
BIG = {"Great wheel", "Lotus throne", "Star wheel", "Great gate"}       # the outer band's set pieces


def check(S):
    """Problems of one authored shape (empty when it is fine)."""
    import cluster_rules as cr
    out = []
    P = [(u, v) for u, v, _ in S.nodes]
    gold = sum(1 for _, _, r in S.nodes if r == "N")
    if not (1 if len(P) < 9 else 2) <= gold <= 4:
        out.append("notables %d" % gold)
    if len(P) > 1 and (P[0][0] != 0 or P[0][1] != min(p[1] for p in P)):
        out.append("entry not at the bottom of the axis")
    for i in range(len(P)):
        for j in range(i + 1, len(P)):
            if math.dist(P[i], P[j]) < 0.72:
                out.append("close %d %d %.2f" % (i, j, math.dist(P[i], P[j])))
    adj = {i: set() for i in range(len(P))}
    for a, b, _ in S.links:
        adj[a].add(b); adj[b].add(a)
    seen, st = {0}, [0]
    while st:
        u = st.pop()
        for v in adj[u] - seen:
            seen.add(v); st.append(v)
    if len(seen) != len(P):
        out.append("not joined")

    def poly(a, b, c):
        if c is None:
            return [P[a], P[b]]
        r = math.dist(P[a], c)
        t1 = math.atan2(P[a][1] - c[1], P[a][0] - c[0]); t2 = math.atan2(P[b][1] - c[1], P[b][0] - c[0])
        dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        n = max(2, int(abs(dt) * r / 0.15))
        return [(c[0] + r * math.cos(t1 + dt * k / n), c[1] + r * math.sin(t1 + dt * k / n)) for k in range(n + 1)]
    o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    PL = [(a, b, poly(a, b, c)) for a, b, c in S.links]
    for x in range(len(PL)):
        for y in range(x + 1, len(PL)):
            if {PL[x][0], PL[x][1]} & {PL[y][0], PL[y][1]}:
                continue
            if any(o(p1, p2, p3) * o(p1, p2, p4) < -1e-12 and o(p3, p4, p1) * o(p3, p4, p2) < -1e-12
                   for p1, p2 in zip(PL[x][2], PL[x][2][1:]) for p3, p4 in zip(PL[y][2], PL[y][2][1:])):
                out.append("cross %d-%d %d-%d" % (PL[x][0], PL[x][1], PL[y][0], PL[y][1]))
    e = P[0]
    Q = [(x - e[0], y - e[1]) for x, y in P]
    edges = [(a, b) for a, b, _ in S.links]
    res = cr.check_cluster(cr.Graph(cr.template_graph(Q, "".join(r for _, _, r in S.nodes), edges)), 0)
    for k in ("R1", "R2", "R3", "R4"):
        if res[k] is False:
            out.append(k + (" waste %s" % res["waste"] if k == "R2" else ""))
    return out


def gallery(path):
    tiles = []
    for f in SHAPES:
        S = f()
        probs = check(S)
        P = [(u, v) for u, v, _ in S.nodes]
        R = max(max(abs(u) for u, v in P), max(abs(v) for u, v in P)) + 1.0
        s = 300 / (2 * R)
        X = lambda p: (p[0] + R) * s
        Y = lambda p: (R - p[1]) * s
        svg = ['<svg viewBox="0 0 300 300">']
        e = P[0]
        svg.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#3a6fd8" stroke-width="2.5" stroke-dasharray="4 3"/>' % (X(e), Y(e), X(e), Y((e[0], e[1] - 1.0))))
        for a, b, c in S.links:
            pa, pb = P[a], P[b]
            if c is not None:
                r = math.dist(pa, c) * s
                t1 = math.atan2(pa[1] - c[1], pa[0] - c[0]); t2 = math.atan2(pb[1] - c[1], pb[0] - c[0])
                dd = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
                svg.append('<path d="M%.1f,%.1f A%.1f,%.1f 0 0 %d %.1f,%.1f" fill="none" stroke="#8d8676" stroke-width="2"/>' % (X(pa), Y(pa), r, r, 0 if dd > 0 else 1, X(pb), Y(pb)))
            else:
                svg.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#8d8676" stroke-width="2"/>' % (X(pa), Y(pa), X(pb), Y(pb)))
        for (u, v, r) in S.nodes:
            if r == "N":
                svg.append('<circle cx="%.1f" cy="%.1f" r="8" fill="#0e1319" stroke="#d8b25a" stroke-width="3"/>' % (X((u, v)), Y((u, v))))
            else:
                svg.append('<circle cx="%.1f" cy="%.1f" r="4.5" fill="#c8c2b4"/>' % (X((u, v)), Y((u, v))))
        svg.append("</svg>")
        gold = sum(1 for _, _, r in S.nodes if r == "N")
        cap = "%s: %d nodes, %d notables%s" % (S.name, len(S.nodes), gold, "" if not probs else " | " + "; ".join(probs[:3]))
        print(cap)
        tiles.append("<figure>%s<figcaption>%s</figcaption></figure>" % ("".join(svg), cap))
    by = {f().name: f() for f in SHAPES}
    for cname, comps in COMPOUNDS + COMPOUNDS_SMALL + COMBOS_MORE:
        hub = (0.0, 0.0)
        allP, allL, roles, owner = [], [], [], []
        for k_, (nm, rel) in enumerate(comps):
            S = by[nm]
            e = -S.nodes[0][1]
            t = math.radians(rel)
            cc = (hub[0] + (e + 1.6) * math.sin(t), hub[1] + (e + 1.6) * math.cos(t))
            W = lambda u, v: (cc[0] + u * math.cos(t) + v * math.sin(t), cc[1] - u * math.sin(t) + v * math.cos(t))
            base = len(allP)
            allP += [W(u, v) for u, v, _ in S.nodes]
            roles += [r for _, _, r in S.nodes]
            owner += [k_] * len(S.nodes)
            allL += [(base + a, base + b, None if c is None else W(*c)) for a, b, c in S.links]
            allL.append(("hub", base, None))
        R = max(max(abs(x), abs(y)) for x, y in allP) + 1.0
        s = 300 / (2 * R)
        X = lambda p: (p[0] + R) * s
        Y = lambda p: (R - p[1]) * s
        svg = ['<svg viewBox="0 0 300 300">']
        svg.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#3a6fd8" stroke-width="2.5" stroke-dasharray="4 3"/>' % (X(hub), Y(hub), X(hub), Y((0, -1.6))))
        for a, b, c in allL:
            pa = hub if a == "hub" else allP[a]; pb = allP[b]
            if c is not None:
                r = math.dist(pa, c) * s
                t1 = math.atan2(pa[1] - c[1], pa[0] - c[0]); t2 = math.atan2(pb[1] - c[1], pb[0] - c[0])
                dd = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
                svg.append('<path d="M%.1f,%.1f A%.1f,%.1f 0 0 %d %.1f,%.1f" fill="none" stroke="#8d8676" stroke-width="2"/>' % (X(pa), Y(pa), r, r, 0 if dd > 0 else 1, X(pb), Y(pb)))
            else:
                svg.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="%s" stroke-width="2"/>' % (X(pa), Y(pa), X(pb), Y(pb), "#3a6fd8" if a == "hub" else "#8d8676"))
        svg.append('<rect x="%.1f" y="%.1f" width="9" height="9" fill="#5b8bd6"/>' % (X(hub) - 4.5, Y(hub) - 4.5))
        for p, r in zip(allP, roles):
            if r == "N":
                svg.append('<circle cx="%.1f" cy="%.1f" r="7" fill="#0e1319" stroke="#d8b25a" stroke-width="3"/>' % (X(p), Y(p)))
            else:
                svg.append('<circle cx="%.1f" cy="%.1f" r="4" fill="#c8c2b4"/>' % (X(p), Y(p)))
        svg.append("</svg>")
        close = min((math.dist(allP[i], allP[j]) for i in range(len(allP)) for j in range(i + 1, len(allP)) if owner[i] != owner[j]), default=9)   # between clusters only
        cap = "%s (pattern of %d): gap between clusters %.2f%s" % (cname, len(comps), close, "" if close >= 0.95 else " | TOO CLOSE")
        print(cap)
        tiles.append("<figure>%s<figcaption>%s</figcaption></figure>" % ("".join(svg), cap))
    html = ('<title>Authored Shapes</title><style>body{margin:0;background:#0b0f15;color:#ccc;font:13px sans-serif}main{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;padding:8px}'
            'figure{margin:0}svg{width:100%;aspect-ratio:1;background:#0e1319}figcaption{padding:3px 0}</style><main>' + "".join(tiles) + "</main>")
    open(path, "w", encoding="utf-8").write(html)


if __name__ == "__main__":
    gallery(sys.argv[1])
