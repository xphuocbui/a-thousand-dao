"""The Moon (933), hand-placed by Claude 2026-11-19 after the underlay idea "moon 2" (design/dao-do/underlays/moon-2.png, the sketch 3 style the user liked), with more figures inside and outside the crescent (user: "moon
we could go with 2 ... please manually add more both inside and outside the figures").

Every figure is a scroll: a chain of arcs drawn by a turtle that turns a little more at each step, so the curve tightens
into a spiral and ends on a notable eye. Each arc link is a true circle arc (its centre equidistant from both ends by
construction). The right half is placed by hand and mirrored across the axis (x -> -x); the full moon in its cup is
built whole.
Angles: a = degrees from +y towards +x (Fire, +y, is down on screen).
"""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', 'tools', 'design',
                                'dao_do_rework', 'cells'))
from celllib import road  # noqa: E402

THEME = 'island'


def D(a):
    t = math.radians(a)
    return (math.sin(t), math.cos(t))


def Q(C, r, a):
    d = D(a)
    return (C[0] + r * d[0], C[1] + r * d[1])


def ang(C, p):
    return math.degrees(math.atan2(p[0] - C[0], p[1] - C[1]))


class Fig:
    """One piece. turtle() lays a scroll from a start (a road id or a node key of this piece)."""

    def __init__(self):
        self.nodes, self.links = {}, []

    def xy(self, k):
        return road(k) if isinstance(k, int) else self.nodes[k][0]

    def turtle(self, start, heading, side, steps, kinds, pre):
        """steps: [(chord length, turn in degrees)]; side +1 turns towards larger a, -1 the other way."""
        p, h, prev = self.xy(start), heading, start
        for i, ((L, th), kind) in enumerate(zip(steps, kinds)):
            q = Q(p, L, h + side * th / 2)
            c = None
            if th > 0.5:
                R = L / (2 * math.sin(math.radians(th) / 2))
                c = Q(p, R, h + side * 90)
            key = f'{pre}{i}'
            self.nodes[key] = (q, kind)
            self.links.append((prev, key, c))
            p, h, prev = q, h + side * th, key
        return prev

    def ring(self, C, r, angs, kinds, pre):
        keys = []
        for i, (a, k) in enumerate(zip(angs, kinds)):
            self.nodes[f'{pre}{i}'] = (Q(C, r, a), k)
            keys.append(f'{pre}{i}')
        return keys

    def arc_chain(self, keys, C):
        self.links += [(keys[i], keys[i + 1], C) for i in range(len(keys) - 1)]

    def bow(self, u, v, sag, toward, kinds, pre):
        """len(kinds) nodes on the circle arc from u to v (pass-through), sagitta sag x chord, bulging towards `toward`."""
        A, B = self.xy(u), self.xy(v)
        h = math.dist(A, B) / 2
        m = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
        nx, ny = -(B[1] - A[1]) / (2 * h), (B[0] - A[0]) / (2 * h)
        if nx * (toward[0] - m[0]) + ny * (toward[1] - m[1]) < 0:
            nx, ny = -nx, -ny
        s = sag * 2 * h
        R = (h * h + s * s) / (2 * s)
        c = (m[0] - nx * (R - s), m[1] - ny * (R - s))
        t1, t2 = ang(c, A), ang(c, B)
        dt = (t2 - t1 + 180) % 360 - 180
        n = len(kinds)
        keys = [u]
        for i, k in enumerate(kinds):
            key = f'{pre}{i}'
            self.nodes[key] = (Q(c, R, t1 + dt * (i + 1) / (n + 1)), k)
            keys.append(key)
        keys.append(v)
        self.arc_chain(keys, c)
        return keys

    def out(self):
        return (self.nodes, self.links)


S, N = 'small', 'notable'
MIR = {590: 591, 601: 601, 617: 617}
MIR.update({592 + i: 602 + i for i in range(9)})
MIR.update({611 + i: 618 + i for i in range(6)})
MIR.update({v: k for k, v in list(MIR.items())})


def mirror(piece):
    nodes, links = piece
    mx = lambda p: (-p[0], p[1])
    return ({k: (mx(xy), kd) for k, (xy, kd) in nodes.items()},
            [(MIR.get(a, a) if isinstance(a, int) else a, MIR.get(b, b) if isinstance(b, int) else b,
              mx(c) if c else None) for a, b, c in links])


right = {}

# --- inside the crescent ---------------------------------------------------------------------------------------------
# the great scroll (moon 2's big C): bows out from inner road 612 to outer road 594; from its shoulder a spiral curls
# back in towards the start.
f = Fig()
f.bow(612, 594, 0.2, (14, -99), (S, S, N, S, S, S), 'g')
right['great_scroll'] = f.out()

# the inner spiral (moon 2): rises from outer road 593 inside the great scroll and curls in towards the start
f = Fig()
f.turtle(593, 172, 1, [(1.4, 0), (1.4, 10), (1.3, 25), (1.2, 45), (1.05, 60), (0.95, 75), (0.85, 85)], (S, S, S, S, S, S, N), 'l')
right['inner_spiral'] = f.out()

# the horn scroll: from inner road 616 down the horn, then curling inwards
f = Fig()
f.turtle(616, 30, -1, [(1.2, 0), (1.1, 4), (1.0, 50), (0.85, 75)], (S, S, S, N), 'h')
right['horn_scroll'] = f.out()

# --- the hollow ------------------------------------------------------------------------------------------------------
# a phase arc across the crescent, outer road 597 to inner road 614, bulging towards the start
f = Fig()
f.bow(597, 614, 0.1, (0, -95), (S, S, N, S, S), 'p')
right['phase_arc'] = f.out()

# a second, higher curl from 615
f = Fig()
f.turtle(615, 235, 1, [(1.4, 12), (1.3, 35), (1.1, 60)], (S, S, N), 'q')
right['high_curl'] = f.out()

# --- outside the crescent --------------------------------------------------------------------------------------------
# moonbeam scrolls hung outwards from the outer arc, curling back up along it
f = Fig()
f.turtle(595, 51.4, -1, [(1.3, 0), (1.2, 20), (1.1, 45), (1.0, 65), (0.9, 80), (0.8, 85)], (S, S, S, S, S, N), 'o')
right['outer_scroll_low'] = f.out()

f = Fig()
f.turtle(597, 77, 1, [(1.4, 10), (1.3, 35), (1.1, 60)], (S, S, N), 'o')
right['outer_scroll_mid'] = f.out()

f = Fig()
f.turtle(600, 114.6, 1, [(1.3, 0), (1.2, 20), (1.1, 45), (1.0, 65), (0.9, 80)], (S, S, S, S, N), 'o')
right['outer_scroll_high'] = f.out()

# a curl rising off the tip
f = Fig()
f.turtle(590, 170, -1, [(1.4, 10), (1.3, 35), (1.1, 60)], (S, S, N), 't')
right['tip_curl'] = f.out()

moon = {}
for name, pc in right.items():
    moon[name + '_r'] = pc
    moon[name + '_l'] = mirror(pc)

# --- the full moon and its two halos (whole) ---------------------------------------------------------------------
# the full moon, a ring of 8 hung from inner road 617, inside two halo arcs round the same centre: the first from 611
# over the top to 618, the second from 612 to 619 (the ring-inside-arcs of cell 14, here as a moon and its halos)
H = (0.0, -104.0)
f = Fig()
ring = f.ring(H, 1.9, [i * 45 for i in range(8)], (S, S, S, S, N, S, S, S), 'm')
f.arc_chain(ring + [ring[0]], H)
f.links.append((617, ring[0], None))
moon['full_moon'] = f.out()
for name, u, v, kinds in (('halo_inner', 611, 618, (S, S, N, S, S, N, S, S, N, S, S)),
                          ('halo_outer', 612, 619, (S, S, S, N, S, S, S, N, S, S, S, N, S, S, S))):
    f = Fig()
    r, a0 = math.dist(H, road(u)), ang(H, road(u)) % 360
    a1 = ang(H, road(v)) % 360
    keys = f.ring(H, r, [a0 + (a1 - a0) * (i + 1) / (len(kinds) + 1) for i in range(len(kinds))], kinds, 'k')
    f.arc_chain([u] + keys + [v], H)
    moon[name] = f.out()

# --- the side circle (road ring 625-636): a waxing moon, a lune of two arcs between opposite road nodes 627 and 633,
# and a curl rising from 630 on the dark side --------------------------------------------------------------------------
E = (sum(road(i)[0] for i in range(625, 637)) / 12, sum(road(i)[1] for i in range(625, 637)) / 12)
for name, sag, kinds in (('waxing_outer', 0.30, (S, S, N, S, S, S, N, S, S)), ('waxing_inner', 0.11, (S, S, S, N, S, S, S))):
    f = Fig()
    f.bow(627, 633, sag, (E[0] + 10, E[1]), kinds, 'w')
    moon[name] = f.out()
f = Fig()
f.turtle(630, ang(road(630), E) - 5, -1, [(1.3, 0), (1.2, 25), (1.1, 50), (1.0, 70), (0.9, 80)], (S, S, S, S, N), 'e')
moon['dark_curl'] = f.out()

CELLS = {933: moon}
