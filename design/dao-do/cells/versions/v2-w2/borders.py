"""Combos across the five land borders (rules-2026-11-18.md 3.10 C; user 2026-11-18: "some combos that require
multiple cells to make"). Placed by hand by Claude after the five land fills.

Each border road runs on past the outer ring (r 74.3) to r 84-94, and the rim seam round it was left empty by the land
fills (they kept to +-33 degrees). Each combo is a split figure there: two halves mirrored across the border road, each
half its own cluster hung from border road nodes, reading as one figure the road runs through. Each figure shows the
generating cycle of the Five Elements across that border:
  911 Fire -> Earth   (global 36):  crater, nested arcs round road node 392
  912 Earth -> Metal  (global 108): crystal, a faceted half-hexagon each side between 510 and 416
  913 Metal -> Water  (global 180): dew, a teardrop each side off 513 and a falling drop off 440
  914 Water -> Wood   (global 252): reeds, two stems each side off 516 and 464 with seed heads
  915 Wood -> Fire    (global 324): torch, S-curved flames rising each side off 488 and 1423
"""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
from celllib import P, orbit, road  # noqa: E402

THEME = 'border'


def reflect_g(p, g):                # mirror across the line through the centre at global angle g
    a = math.radians(g)
    u = (math.sin(a), math.cos(a))
    k = 2 * (p[0] * u[0] + p[1] * u[1])
    return (k * u[0] - p[0], k * u[1] - p[1])


def both(half, g):
    """A half figure (side +theta) and its mirror across the border road at global angle g."""
    out = {}
    for name, (nodes, links) in half.items():
        out[name + '_a'] = (nodes, links)
        out[name + '_b'] = ({k: (reflect_g(xy, g), kd) for k, (xy, kd) in nodes.items()},
                            [(a, b, reflect_g(c, g) if c else None) for a, b, c in links])
    return out


def arc(C, rho, angs, kinds):
    return {f'n{i}': (orbit(C, rho, a), k) for i, (a, k) in enumerate(zip(angs, kinds))}


def chain(keys):
    return [(keys[i], keys[i + 1], None) for i in range(len(keys) - 1)]


CELLS = {}

# --- 911 Fire -> Earth: crater. Inner arc round road node 392 (r 84), entered from 392 at its middle, notable tips;
# outer arc a pass-through from 507 (r 79.1) to 1404 (r 89) with a notable at its shoulder. --------------------------
C = road(392)
inner = arc(C, 2.2, (25, 58, 90, 122, 155), ('notable', 'small', 'small', 'small', 'notable'))
outer = arc(C, 3.9, (24, 60, 96, 130, 162), ('small', 'small', 'notable', 'small', 'small'))
CELLS[911] = both({
    'crater_in': (inner, [(392, 'n2', None), ('n2', 'n1', C), ('n1', 'n0', C), ('n2', 'n3', C), ('n3', 'n4', C)]),
    'crater_out': (outer, [(507, 'n0', None), ('n0', 'n1', C), ('n1', 'n2', C), ('n2', 'n3', C), ('n3', 'n4', C),
                           ('n4', 1404, None)]),
}, 36)

# --- 912 Earth -> Metal: crystal. A half-hexagon with straight facets between 510 (r 79.1) and 416 (r 84), a notable
# at its point. -----------------------------------------------------
A, B = road(510), road(416)
Cc = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
hexa = arc(Cc, 3.0, (30, 90, 150), ('small', 'notable', 'small'))
CELLS[912] = both({
    'crystal': ({**hexa, 'p0': (orbit(Cc, 2.3, 22), 'small'), 'p2': (orbit(Cc, 2.3, 158), 'small')},
                [(510, 'p0', None), ('p0', 'n0', None), ('n0', 'n1', None), ('n1', 'n2', None), ('n2', 'p2', None),
                 ('p2', 416, None)]),
}, 108)

# --- 913 Metal -> Water: dew. A teardrop each side off 513 (r 79.2): stem, then a round loop with the drop's notable at
# its far end; and a falling drop off the open end 440 (r 84): a short curved stem to a notable. -----------------------
D = road(513)
Dc = orbit(D, 2.6, 110)                                   # the drop's loop centre, out and to the side
drop = {'s0': (orbit(D, 1.2, 100), 'small'),
        'l0': (orbit(Dc, 0.95, -60), 'small'), 'l1': (orbit(Dc, 0.95, 40), 'small'),
        'l2': (orbit(Dc, 0.95, 160), 'small'), 'tip': (orbit(Dc, 1.45, 110), 'notable')}
E = road(440)
fall = {'f0': (orbit(E, 1.1, 120), 'small'), 'f1': (orbit(E, 2.0, 140), 'small'), 'f2': (orbit(E, 2.9, 150), 'notable')}
CELLS[913] = both({
    'dew': (drop, [(513, 's0', None), ('s0', 'l0', None), ('l0', 'l1', Dc), ('l1', 'tip', None), ('l0', 'l2', Dc),
                   ('l2', 'tip', None)]),
    'falling': (fall, [(440, 'f0', None), ('f0', 'f1', None), ('f1', 'f2', None)]),
}, 180)

# --- 914 Water -> Wood: reeds. Two stems each side, a short one off 516 (r 79.1) and a tall one off 464 (r 84), leaning
# out and up the border, each ending in a seed-head notable with one leaf on the tall stem. -----------------------------
R1, R2 = road(516), road(464)
short = {'a0': (orbit(R1, 1.2, 75), 'small'), 'a1': (orbit(R1, 2.3, 95), 'small'), 'a2': (orbit(R1, 3.3, 112), 'notable')}
tall = {'b0': (orbit(R2, 1.2, 70), 'small'), 'b1': (orbit(R2, 2.4, 92), 'small'), 'b2': (orbit(R2, 3.6, 110), 'small'),
        'b3': (orbit(R2, 4.8, 124), 'notable'), 'leaf': (orbit(R2, 3.3, 72), 'notable')}
CELLS[914] = both({
    'reed_short': (short, chain([516, 'a0', 'a1', 'a2'])),
    'reed_tall': (tall, chain([464, 'b0', 'b1', 'b2', 'b3']) + [('b1', 'leaf', None)]),
}, 252)

# --- 915 Wood -> Fire: torch. The border road is the handle; S-curved flames rise each side off 488 (r 84) and a
# shorter flicker off 1423 (r 89). ---------------------------------------------------------------------------------------
F1, F2 = road(488), road(1423)
flame = {'a0': (orbit(F1, 1.2, 60), 'small'), 'a1': (orbit(F1, 2.2, 95), 'small'), 'a2': (orbit(F1, 3.0, 130), 'small'),
         'a3': (orbit(F1, 4.2, 140), 'small'), 'tip': (orbit(F1, 5.4, 132), 'notable')}
flick = {'b0': (orbit(F2, 1.1, 75), 'small'), 'b1': (orbit(F2, 2.0, 110), 'small'), 'b2': (orbit(F2, 2.9, 135), 'notable')}
CELLS[915] = both({
    'flame': (flame, chain([488, 'a0', 'a1', 'a2', 'a3', 'tip'])),
    'flicker': (flick, chain([1423, 'b0', 'b1', 'b2'])),
}, 324)
