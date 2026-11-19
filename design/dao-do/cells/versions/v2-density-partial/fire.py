"""Fire land (axis 0), filled by hand cell by cell (fire fork, 2026-11-18). Cells 14 and 93 live in cell14.py and
cell93.py and are compiled before this file. Every position and choice below is hand-chosen; the helpers only turn
(r, theta) and orbit angles into map coordinates.

Angles: L(r, th) is land-local polar (th from the Fire axis, + towards +theta); orbit(O, rho, ang) and place(..., ang)
use ang 0 = towards the tree centre, + = towards +theta, 180 = outward.
FIRE_EXTRA (environment, JSON {"cell": id, "rows": [...]}) adds trial FILL rows for the fire sweep only.
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from celllib import L, road, orbit, fill_rows, mirror_pieces, mirror_road, load, bow_centre, wall_pair, place  # noqa: E402

THEME = 'fire'
LAND = 'fire'
CELLS = {}


def F(r, th):
    return L(r, th, LAND)


def arc(O, rho, angs, kinds, closed=False):
    """Nodes on a circle round O at the given orbit angles; consecutive links are arcs round O."""
    keys = [f'a{i}' for i in range(len(angs))]
    nodes = {k: (orbit(O, rho, a), kd) for k, a, kd in zip(keys, angs, kinds)}
    links = [(keys[i], keys[i + 1], O) for i in range(len(keys) - 1)]
    if closed:
        links.append((keys[-1], keys[0], O))
    return keys, nodes, links


def chain(pts, kinds, bows=None):
    """Nodes at the given points; consecutive links straight or bowed (bow = sagitta share, + away from the centroid)."""
    keys = [f'c{i}' for i in range(len(pts))]
    nodes = {k: (p, kd) for k, p, kd in zip(keys, pts, kinds)}
    cen = (sum(p[0] for p in pts) / len(pts), sum(p[1] for p in pts) / len(pts))
    links = []
    for i in range(len(pts) - 1):
        b = (bows or [0] * len(pts))[i]
        links.append((keys[i], keys[i + 1], bow_centre(pts[i], pts[i + 1], b, cen) if b else None))
    return keys, nodes, links


def piece(nodes, links, entries):
    """entries: [(road id, node key)]: the road links into the piece."""
    return nodes, [(r, k, None) for r, k in entries] + links


def figure(O, spec, links, entries):
    """A hand-drawn medium or big figure round its own centre O (consolidation pass, 2026-11-18).
    spec {key: (rho, ang, kind)} places a node on the circle rho round O at orbit angle ang (0 = towards the tree
    centre, + = towards +theta), or {key: ((x, y), kind)} at a point. links (a, b[, how]): how None = straight,
    'O' = an arc round O (both ends must sit on one circle round O), a number = bow share (+ away from the figure's
    centroid), a point = an arc round that point. entries [(road id, node key)]."""
    nodes = {}
    for k, v in spec.items():
        if len(v) == 3:
            nodes[k] = (orbit(O, v[0], v[1]), v[2])
        else:
            nodes[k] = v
    cen = (sum(p[0] for p, _ in nodes.values()) / len(nodes), sum(p[1] for p, _ in nodes.values()) / len(nodes))
    out = []
    for ln in links:
        a, b = ln[0], ln[1]
        how = ln[2] if len(ln) > 2 else None
        if how == 'O':
            c = O
        elif isinstance(how, (int, float)):
            c = bow_centre(nodes[a][0], nodes[b][0], how, cen) if how else None
        else:
            c = how
        out.append((a, b, c))
    return piece(nodes, out, entries)


def along(A, B, c, fracs):
    """Points on the arc round c from A to B (the short way) at the given fractions of the turn."""
    r = math.dist(A, c)
    t1 = math.atan2(A[1] - c[1], A[0] - c[0]); t2 = math.atan2(B[1] - c[1], B[0] - c[0])
    dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    return [(c[0] + r * math.cos(t1 + dt * f), c[1] + r * math.sin(t1 + dt * f)) for f in fracs]


def lens(A, B, bows, n, kinds, entries):
    """Two arcs from A to B bowing to either side (bows = (left share, right share)), n interior nodes on each.
    kinds {key: kind} overrides 'small'; keys: A, B, l1..ln, r1..rn."""
    mid = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
    dx, dy = B[0] - A[0], B[1] - A[1]
    side = (mid[0] - dy, mid[1] + dx)
    nodes = {'A': (A, kinds.get('A', 'small')), 'B': (B, kinds.get('B', 'small'))}
    links = []
    for tag, bow, ref in (('l', bows[0], side), ('r', bows[1], (2 * mid[0] - side[0], 2 * mid[1] - side[1]))):
        c = bow_centre(A, B, -bow, ref)
        pts = along(A, B, c, [i / (n + 1) for i in range(1, n + 1)])
        keys = ['A'] + [f'{tag}{i}' for i in range(1, n + 1)] + ['B']
        for i, q in enumerate(pts):
            nodes[f'{tag}{i + 1}'] = (q, kinds.get(f'{tag}{i + 1}', 'small'))
        links += [(keys[i], keys[i + 1], c) for i in range(n + 1)]
    return piece(nodes, links, entries)


# ======================================================================================================================
# cell 15 (outer band, -17..0): a varied mirror of cell 14 (PoE 2 mirrors about half). The heart-flame combo and most
# pieces are reflected; two small pieces differ so it does not read as a stamp.
# ======================================================================================================================
_c14 = load(os.path.join(os.path.dirname(HERE), 'cell14.py'))
P15 = mirror_pieces(_c14.PIECES, LAND)
for k in ('K_crescent', 'E_crescent'):
    del P15[k]
fill_rows(P15, [
    ('K spur',     1597, 'Spur pair', 'bow in', 1.2, -178, 0, True),
    ('E hairpin',  1565, 'Hairpin', 'bow out', 1.2, 0, 0, False),
])
CELLS[15] = P15


# ======================================================================================================================
# COMBO "hearth" (cells 18 + 37, split across the axis): three S-curved flame tongues rise from the r 53.9 ring on each
# side of the axis hex, so the hex reads as the core of one fire. 37 is the mirror of 18's flames.
# COMBO "flame lily" (junction at road node 1587, r 53.9 th 18; mirrored at 1580): three cusped petals, one each into
# cells 18 (up-left), 28 (up-right) and 70 (down).
# ======================================================================================================================
def flame(base, pts, name, tongue=None, tbow=-0.18):
    """An S-curved flame tongue from road node `base`; `tongue` (at index, [(r, th), ...]) adds a side lick ending in a
    notable (consolidation 2026-11-18: the bigger flames of the hearth are medium figures)."""
    keys, nodes, links = chain([F(r, t) for r, t in pts], ['small'] * (len(pts) - 1) + ['notable'],
                               [0.18, -0.18, 0.18, -0.18, 0.18][:len(pts) - 1])
    if tongue:
        at, tp = tongue
        prev = keys[at]
        for q, (r, t) in enumerate(tp):
            k = f't{q}'
            nodes[k] = (F(r, t), 'notable' if q == len(tp) - 1 else 'small')
            links.append((prev, k, bow_centre(nodes[prev][0], nodes[k][0], tbow, F(53.9, t + 4))))
            prev = k
    return {name: piece(nodes, links, [(base, keys[0])])}


def sun18():
    """"hearth sun": a ring of eight hung from inner-ring node 1555, three straight rays with notable tips (sideways
    both ways and down towards the flames)."""
    O = F(44.5, 9.4)
    spec = {f'r{a}': (1.3, a, 'small') for a in range(0, 360, 45)}
    spec.update({'t90': (2.6, 90, 'notable'), 't270': (2.6, 270, 'notable'), 't180': (2.6, 180, 'notable')})
    links = [(f'r{a}', f'r{(a + 45) % 360}', 'O') for a in range(0, 360, 45)]
    links += [('r90', 't90'), ('r270', 't270'), ('r180', 't180')]
    return figure(O, spec, links, [(1555, 'r0')])


def spark18():
    """"falling ember": a lens hung from corner node 1553, tilted down towards the sun, notables at its lower tip and
    on its inner side."""
    return lens(F(43.4, 16.3), F(47.0, 14.9), (0.22, 0.22), 2, {'l2': 'notable'}, [(1553, 'A')])


P18 = {}
P18.update(flame(1590, [(52.5, 3.9), (51.3, 4.8), (50.1, 4.4)], 'flame_a'))
P18.update(flame(1589, [(52.5, 7.1), (51.1, 8.0), (49.7, 7.3), (48.3, 6.4), (46.9, 7.0)], 'flame_b',
                 (1, [(50.2, 9.5), (48.9, 9.8)])))
P18.update(flame(1588, [(52.5, 11.4), (51.2, 12.3), (49.9, 11.6), (48.7, 12.4)], 'flame_c'))
P18['sun'] = sun18()
P18['spark'] = spark18()
fill_rows(P18, [
    ('lily L',     1587, 'Diamond', 'cusped', 1.4, -45, 0, False),
])
CELLS[18] = P18

# cell 37: the hearth's other half, mirrored from 18 (the flames and the sun); the spark differs.
P37 = mirror_pieces({k: v for k, v in P18.items() if k != 'spark'}, LAND)


def drop37():
    """"flame drop": a teardrop pointing up at the inner ring (a flame seen whole), entered at its point from 1546,
    notables at its foot and on its outer flank."""
    O = F(45.3, -15.4)
    A = F(43.2, -15.7)
    spec = {'A': (A, 'small')}
    spec.update({f'n{a}': (1.2, a, 'notable' if a in (180, -115) else 'small') for a in (55, 115, 180, -115, -55)})
    links = [('A', 'n55'), ('n55', 'n115', 'O'), ('n115', 'n180', 'O'), ('n180', 'n-115', 'O'), ('n-115', 'n-55', 'O'),
             ('n-55', 'A')]
    return figure(O, spec, links, [(1546, 'A')])


P37['drop'] = drop37()
CELLS[37] = P37


# ======================================================================================================================
# cell 28 (41.7-53.9, th 18..36): "ember spiral", ten nodes curling inward from road node 1551 to a notable core, a
# second notable half way round. Round it (consolidation 2026-11-18): the flame lily's right petal (from 1587), a flame
# wisp, a spark pinwheel and a sunrise.
# cell 29: its mirror, one piece different.
# ======================================================================================================================
def spiral(O, rho0, drho, ang0, step, n, notables, entry):
    keys, nodes, links = [], {}, []
    for k in range(n):
        key = f'p{k}'; keys.append(key)
        nodes[key] = (orbit(O, rho0 - drho * k, ang0 + step * k), 'notable' if k in notables else 'small')
    for k in range(n - 1):
        a, b = nodes[keys[k]][0], nodes[keys[k + 1]][0]
        links.append((keys[k], keys[k + 1], bow_centre(a, b, 0.12, O)))
    return piece(nodes, links, [(entry, keys[0])])


def wisp28():
    """"flame wisp": a tall S-curve up the strip by the spoke, entered at its waist from spoke node 235, notables at
    both ends."""
    pts = {'t3': (46.7, 33.3), 't2': (47.6, 32.5), 't1': (48.6, 32.4), 'm': (49.7, 33.1), 'u1': (50.7, 33.8),
           'u2': (51.7, 33.7), 'u3': (52.5, 33.0)}
    spec = {k: (F(*v), 'notable' if k in ('t3', 'u3') else 'small') for k, v in pts.items()}
    links = [('m', 't1', 0.15), ('t1', 't2', 0.15), ('t2', 't3', 0.15), ('m', 'u1', -0.15), ('u1', 'u2', -0.15),
             ('u2', 'u3', -0.15)]
    return figure(F(49.7, 33.1), spec, links, [(235, 'm')])


def pinwheel28():
    """"spark pinwheel": a hub on a short stem from 1552, three arms curling the same way, notable tips."""
    H = F(44.5, 21.9)
    spec = {'s0': (F(43.1, 22.5), 'small'), 'h': (H, 'small')}
    links = [('s0', 'h')]
    for j, a in enumerate((75, 165, 255)):
        spec[f'a{j}'] = (orbit(H, 1.1, a), 'small'); spec[f'b{j}'] = (orbit(H, 2.0, a + 35), 'notable')
        links += [('h', f'a{j}', 0.12), (f'a{j}', f'b{j}', 0.2)]
    return figure(H, spec, links, [(1552, 's0')])


def halfsun28():
    """"sunrise": a half sun on the bottom ring round road node 1586, its two horns notables, one flame rising
    from its middle towards the spiral."""
    O = road(1586)
    spec = {f'a{a}': (1.8, a, 'notable' if abs(a) == 56 else 'small') for a in (-56, -28, 0, 28, 56)}
    spec.update({'c1': (2.9, 0, 'small'), 'c2': (3.9, 4, 'notable')})
    links = [('a-56', 'a-28', 'O'), ('a-28', 'a0', 'O'), ('a0', 'a28', 'O'), ('a28', 'a56', 'O'), ('a0', 'c1'),
             ('c1', 'c2', 0.15)]
    return figure(O, spec, links, [(1586, 'a0')])


P28 = {'spiral': spiral(F(47.9, 27.3), 3.6, 0.27, -10, 45, 10, (5, 9), 1551),
       'wisp': wisp28(), 'pinwheel': pinwheel28(), 'sunrise': halfsun28()}
fill_rows(P28, [
    ('lily R',     1587, 'Diamond', 'cusped', 1.4, 45, 0, True),
])
CELLS[28] = P28

# cell 29: 28 mirrored (the spiral now turns the other way); the pinwheel becomes a closed flame crescent.
P29 = mirror_pieces({k: v for k, v in P28.items() if k not in ('lily_R', 'pinwheel')}, LAND)


def crescent29():
    """"flame crescent": a closed crescent bulging towards the spoke, horns towards the spiral, entered at its upper
    horn from 1545; notables at the lower horn and the crescent's belly."""
    O = F(44.7, -21.5)
    C2 = orbit(O, 2.108, 270)
    spec = {'t0': (1.7, 0, 'small'), 'o45': (1.7, 45, 'small'), 'o90': (1.7, 90, 'notable'), 'o135': (1.7, 135, 'small'),
            't180': (1.7, 180, 'notable'), 'i90': (0.6, 90, 'small')}
    links = [('t0', 'o45', 'O'), ('o45', 'o90', 'O'), ('o90', 'o135', 'O'), ('o135', 't180', 'O'), ('t0', 'i90', C2),
             ('i90', 't180', C2)]
    return figure(O, spec, links, [(1545, 't0')])


P29['crescent'] = crescent29()
fill_rows(P29, [
    ('lily R',     1580, 'Diamond', 'cusped', 1.4, -45, 0, False),
])
CELLS[29] = P29


# ======================================================================================================================
# cell 70 (53.9-64.3, th 11..23): "flame heart", two flame curls (6 and 7 nodes; were Hairpins) rising from the bottom
# ring curl towards each other round a Tadpole, the flame lily's lower petal (from 1587) hanging into the gap above them;
# twin embers on the spoke. cell 74: its mirror, one piece different.
# ======================================================================================================================
def curl(base, pts, name):
    """A hand-drawn flame curl from road node `base` through the land-local points, the last a notable."""
    keys, nodes, links = chain([F(r, t) for r, t in pts], ['small'] * (len(pts) - 1) + ['notable'],
                               [0.12] * (len(pts) - 1))
    return {name: piece(nodes, links, [(base, keys[0])])}


def embers70():
    """"twin embers": two small rings joined at one node, hung from spoke node 1938; the far ring carries the
    notables."""
    O1 = F(58.5, 12.6)
    O2 = orbit(O1, 1.9, 65)
    spec = {'e': (orbit(O1, 0.95, -115), 'small'), 'a': (orbit(O1, 0.95, -25), 'small'),
            'b': (orbit(O1, 0.95, 155), 'small'), 's': (orbit(O1, 0.95, 65), 'small'),
            'c': (orbit(O2, 0.95, -25), 'notable'), 'd': (orbit(O2, 0.95, 65), 'small'),
            'f': (orbit(O2, 0.95, 155), 'notable')}
    links = [('e', 'a', O1), ('a', 's', O1), ('e', 'b', O1), ('b', 's', O1), ('s', 'c', O2), ('c', 'd', O2), ('d', 'f', O2),
             ('f', 's', O2)]
    return figure(O1, spec, links, [(1938, 'e')])


P70 = {}
P70.update(curl(1607, [(63.2, 13.9), (62.2, 13.1), (61.0, 12.95), (60.1, 13.7), (60.0, 14.8), (60.9, 15.4)], 'heart_L'))
P70.update(curl(1605, [(63.2, 20.1), (62.3, 21.2), (61.1, 21.6), (60.0, 21.1), (59.4, 20.1), (59.6, 19.0),
                       (60.5, 18.6)], 'heart_R'))
P70['embers'] = embers70()
fill_rows(P70, [
    ('lily D',     1587, 'Diamond', 'cusped', 1.2, 180, 0, False),
    ('core',       1606, 'Tadpole', 'round', 1.0, 0, 0, False),
    ('B diamond',  1586, 'Diamond', 'round', 1.2, -135, 0, False),
])
CELLS[70] = P70

# cell 74: 70 mirrored; the corner Diamond becomes a Crescent.
P74 = mirror_pieces({k: v for k, v in P70.items() if k != 'B_diamond'}, LAND)
fill_rows(P74, [('B crescent', 1579, 'Crescent', 'bow out', 1.2, 140, 0, True)])
CELLS[74] = P74


# ======================================================================================================================
# cell 92 (53.9-64.3, th -11..0; its own design, not 93's mirror): "phoenix feather", a gently curved quill from road
# node 1582 down the cell with alternating barbs ending in notables (the first barb two long, for R3); a twin flame
# from the corner and a candle by the axis (consolidation 2026-11-18).
# ======================================================================================================================
def feather():
    sp = [F(55.2, -6.8), F(56.6, -6.0), F(58.0, -5.4), F(59.4, -5.2), F(60.8, -5.5), F(62.1, -6.2)]
    nodes = {f's{i}': (p, 'small') for i, p in enumerate(sp)}
    nodes['s5'] = (sp[5], 'notable')
    links = [(f's{i}', f's{i + 1}', bow_centre(sp[i], sp[i + 1], 0.1, F(59.0, -12.0))) for i in range(5)]
    barbs = [('s1', [F(56.3, -7.6), F(56.0, -9.1)]), ('s2', [F(57.4, -3.4)]), ('s3', [F(59.6, -7.4)]),
             ('s4', [F(60.5, -3.4)])]
    for j, (at, pts) in enumerate(barbs):
        prev = at
        for q, pt in enumerate(pts):
            key = f'b{j}_{q}'
            nodes[key] = (pt, 'notable' if q == len(pts) - 1 else 'small')
            a, b = nodes[prev][0], pt
            links.append((prev, key, bow_centre(a, b, 0.16, F(64.0, -5.5)))); prev = key
    return piece(nodes, links, [(1582, 's0')])


P92 = {'feather': feather()}


def twinflame92():
    """"twin flame": two tongues of unequal length from one stem on corner node 1598, the long one curling up the
    spoke side, the short one leaning towards the feather's tip."""
    spec = {'s0': (F(63.1, -10.2), 'small'), 's1': (F(62.0, -9.6), 'small'),
            'l1': (F(60.9, -10.1), 'small'), 'l2': (F(59.8, -9.9), 'small'), 'l3': (F(59.0, -9.1), 'notable'),
            'r1': (F(62.3, -8.4), 'small'), 'r2': (F(61.6, -7.5), 'notable')}
    links = [('s0', 's1', 0.1), ('s1', 'l1', 0.15), ('l1', 'l2', 0.15), ('l2', 'l3', 0.2), ('s1', 'r1', -0.15),
             ('r1', 'r2', -0.2)]
    return figure(F(61.5, -9.2), spec, links, [(1598, 's0')])


def candle92():
    """"candle": a short stem from axis node 1481 and a lens-shaped flame standing up towards the tree centre, its
    tip the notable."""
    nodes, links = lens(F(58.6, -1.6), F(55.9, -1.6), (0.2, 0.2), 2, {'B': 'notable'}, [])
    nodes['s0'] = (F(59.6, -1.1), 'small')
    return nodes, [(1481, 's0', None), ('s0', 'A', None)] + links


P92['twin'] = twinflame92()
P92['candle'] = candle92()
CELLS[92] = P92


# ======================================================================================================================
# cell 63 (inner band 33.2-41.7, th 0..23): "ember corona", an arc concentric with the rings hung from road node 1541;
# its two ends and two flame tips (pointing outward) are notables. cell 62: its mirror, one piece different.
# ======================================================================================================================
def corona(entry, O, rho, angs, tip_rho, tip_at):
    """An arc on a small circle round O (angles as orbit(): 180 = outward), its two ends notables, flame tips hanging
    outward from the nodes listed in tip_at; entered from `entry` at the node nearest to it."""
    nodes = {f'k{i}': (orbit(O, rho, a), 'notable' if i in (0, len(angs) - 1) else 'small') for i, a in enumerate(angs)}
    links = [(f'k{i}', f'k{i + 1}', O) for i in range(len(angs) - 1)]
    for j, i in enumerate(tip_at):
        nodes[f't{j}'] = (orbit(O, tip_rho, angs[i]), 'notable'); links.append((f'k{i}', f't{j}', None))
    door = min(range(len(angs)), key=lambda i: math.dist(nodes[f'k{i}'][0], road(entry)))
    return piece(nodes, links, [(entry, f'k{door}')])


def halo63():
    """"sun halo" (half of a combo round axis node 67; cell 62 holds the mirror half): two nested arcs round 67,
    joined at their ends, a flame tongue reaching out from the outer arc's middle."""
    O = road(67)
    spec = {'i35': (1.5, 35, 'small'), 'i90': (1.5, 90, 'small'), 'i145': (1.5, 145, 'small'),
            'o15': (2.9, 15, 'small'), 'o50': (2.9, 50, 'notable'), 'o90': (2.9, 90, 'small'), 'o130': (2.9, 130, 'notable'),
            'o165': (2.9, 165, 'small'), 'tip': (4.1, 92, 'notable')}
    links = [('i90', 'i35', 'O'), ('i90', 'i145', 'O'), ('i35', 'o15'), ('i145', 'o165'), ('o15', 'o50', 'O'),
             ('o50', 'o90', 'O'), ('o90', 'o130', 'O'), ('o130', 'o165', 'O'), ('o90', 'tip')]
    return figure(O, spec, links, [(67, 'i90')])


def reuleaux(entry, O, R, a0, notables):
    """A rounded triangle (each side an arc round the opposite corner), entered at the corner at orbit angle a0."""
    cs = [a0, a0 + 120, a0 + 240]
    spec = {f'c{i}': (R, a, 'notable' if f'c{i}' in notables else 'small') for i, a in enumerate(cs)}
    s = R * math.sqrt(3)
    spec.update({f'm{i}': (s - R, cs[i] + 180, 'notable' if f'm{i}' in notables else 'small') for i in range(3)})
    pt = {k: orbit(O, v[0], v[1]) for k, v in spec.items()}
    links = []
    for i in range(3):
        a, b = f'c{(i + 1) % 3}', f'c{(i + 2) % 3}'
        links += [(a, f'm{i}', pt[f'c{i}']), (f'm{i}', b, pt[f'c{i}'])]
    return figure(O, spec, links, [(entry, 'c0')])


P63 = {'corona': corona(1541, F(31.4, 14.0), 5.2, [136, 158, 180, 202, 224], 7.4, [1, 3]),
       'halo': halo63(),
       'ember': reuleaux(1553, F(39.3, 15.0), 1.25, 141, ('c1', 'c2'))}
CELLS[63] = P63

# cell 62: 63 mirrored (the halo's other half closes the sun round 67); a Crook where 63 has its ember.
P62 = mirror_pieces({k: v for k, v in P63.items() if k != 'ember'}, LAND)
fill_rows(P62, [
    ('E crook',    1548, 'Crook', 'bow out', 1.0, -40, 0, True),
])
CELLS[62] = P62


# ======================================================================================================================
# cells 119 / 120 (inner band corners by the border, 72 units²): small and sparse, each its own: 120 a Wheel (a spark
# disc) off the inner ring and a comet (consolidation 2026-11-18: was a Hook and a Crook); 119 a Tadpole and a
# flicker (was a closed Fork and a Crook).
# ======================================================================================================================
def comet120():
    """"comet": a ring head of four flying down towards -theta, two tail streaks behind it, one hung from spoke node
    1514, the other ending in a notable; the head's leading node a notable."""
    O = F(39.0, 28.0)
    spec = {'rb': (0.85, 60, 'small'), 'rl': (0.85, -30, 'small'), 'rf': (0.85, -120, 'notable'), 'rr': (0.85, 150, 'small'),
            't1b': (2.1, 66, 'small'), 't1a': (3.6, 72, 'small'), 't2b': (1.9, 97, 'small'), 't2a': (3.0, 110, 'notable')}
    links = [('rb', 'rl', 'O'), ('rl', 'rf', 'O'), ('rf', 'rr', 'O'), ('rr', 'rb', 'O'), ('t1a', 't1b', 0.08), ('t1b', 'rb'),
             ('rb', 't2b'), ('t2b', 't2a', 0.08)]
    return figure(O, spec, links, [(1514, 't1a')])


def flicker119():
    """"flicker": a zigzag flame edge on two circles round one centre (valleys on the inner, peaks on the outer), rising
    from inner-ring node 1544 and arching over; three of its peaks notables."""
    O = F(41.5, -29.5)
    angs = [45, 30, 15, 0, -15, -30, -45, -60]
    spec = {f'k{i}': (3.5 if i % 2 else 2.6, a, 'notable' if i in (3, 5, 7) else 'small') for i, a in enumerate(angs)}
    links = [(f'k{i}', f'k{i + 1}') for i in range(len(angs) - 1)]
    return figure(O, spec, links, [(1544, 'k0')])


CELLS[120] = fill_rows({'comet': comet120()}, [
    ('A wheel',    1538, 'Wheel', 'spoke', 1.0, 180, 0, False),
])
CELLS[119] = fill_rows({'flicker': flicker119()}, [
    ('A tadpole',  1532, 'Tadpole', 'round', 1.0, 180, 0, False),
])


# ======================================================================================================================
# COMBO "split ring" (cells 53 + 101): a ring round road node 1943 (on the spoke th -28) cut by the spoke, one half in
# each cell, each half hung from 1943 at its middle, notables at the four ends (consolidation: seven nodes a half).
# cell 53 (outer band, th -28..-17), its own design: "fireball", a small ring head with a curved tail rising from
# road node 1560, plus the split ring's right half and a flame fleur (consolidation 2026-11-18).
# ======================================================================================================================
def half_ring(hub, rho, angs, door_i):
    nodes = {f'h{i}': (orbit(road(hub), rho, a), 'notable' if i in (0, len(angs) - 1) else 'small') for i, a in enumerate(angs)}
    links = [(f'h{i}', f'h{i + 1}', road(hub)) for i in range(len(angs) - 1)]
    return piece(nodes, links, [(hub, f'h{door_i}')])


def fireball(base, tail, H, rho):
    keys, nodes, links = chain([F(r, t) for r, t in tail], ['small'] * len(tail), [0.15, 0.15, 0.15][:len(tail) - 1])
    angs = (180, 108, 36, -36, -108)
    for i, a in enumerate(angs):
        nodes[f'r{i}'] = (orbit(H, rho, a), 'notable' if a in (36, -36) else 'small')
    links += [(f'r{i}', f'r{(i + 1) % 5}', H) for i in range(5)]
    links.append((keys[-1], 'r0', None))
    return piece(nodes, links, [(base, keys[0])])


def fleur53():
    """"flame fleur": a fleur-de-lis of fire on a short stem from 1559, a straight middle tongue and two petals curling
    outward, all three tips notables."""
    spec = {'s0': (F(73.1, -23.8), 'small'), 's1': (F(71.8, -23.7), 'small'),
            'c1': (F(70.4, -23.6), 'small'), 'c2': (F(69.0, -23.5), 'notable'),
            'l1': (F(71.2, -24.9), 'small'), 'l2': (F(70.0, -25.3), 'notable'),
            'r1': (F(71.3, -22.6), 'small'), 'r2': (F(70.1, -22.4), 'notable')}
    links = [('s0', 's1'), ('s1', 'c1'), ('c1', 'c2'), ('s1', 'l1', 0.2), ('l1', 'l2', 0.3), ('s1', 'r1', 0.2),
             ('r1', 'r2', 0.3)]
    return figure(F(71.5, -23.7), spec, links, [(1559, 's0')])


SPLIT = [20 + 140 * i / 6 for i in range(7)]
P53 = {
    'split_ring_R': half_ring(1943, 2.2, SPLIT, 3),
    'fireball': fireball(1560, [(72.9, -21.0), (71.6, -21.7), (70.3, -21.4)], F(67.7, -20.4), 1.3),
    'fleur': fleur53(),
}
CELLS[53] = P53

# cell 101 (th -36..-28, its own design): the split ring's left half and a "spark star" off the border road.
def star101():
    """"spark star": a five-pointed star outline (tips and waists on two circles round one centre), one tip hung from
    border-road node 517; three of the other tips notables."""
    O = F(69.3, -33.0)
    a0 = -92
    spec = {}
    for k in range(5):
        spec[f't{k}'] = (2.3, a0 + 72 * k, 'notable' if k in (1, 3, 4) else 'small')
        spec[f'w{k}'] = (1.05, a0 + 36 + 72 * k, 'small')
    links = []
    for k in range(5):
        links += [(f't{k}', f'w{k}'), (f'w{k}', f't{(k + 1) % 5}')]
    return figure(O, spec, links, [(517, 't0')])


P101 = {'split_ring_L': half_ring(1943, 2.2, [-a for a in SPLIT], 3), 'star': star101()}
CELLS[101] = P101


# ======================================================================================================================
# cell 56 (outer band, th 17..28, its own design): "flame taiji", two small spirals side by side turning the same way,
# one entered from the top ring (1605), one from the bottom ring (1569): each is the other turned half round; a flame
# crown from spoke node 1944 and two Crooks (consolidation 2026-11-18).
# ======================================================================================================================
P56 = {
    'taiji_a': spiral(F(68.6, 20.4), 2.3, 0.19, 0, 50, 8, (3, 7), 1605),
    'taiji_b': spiral(F(70.0, 24.6), 2.3, 0.19, 180, 50, 8, (3, 7), 1569),
}


def crown56():
    """"flame crown": three flame peaks (notables) on a circle round a base node, joined to it through two valleys, on
    a stem from spoke node 1944; it points up at the ring like a fire's silhouette."""
    O = F(67.9, 25.9)
    spec = {'s0': (F(69.0, 26.9), 'small'), 'b': (0.0, 0, 'small'), 'v-28': (1.1, -28, 'small'), 'v28': (1.1, 28, 'small'),
            'p-55': (2.0, -55, 'notable'), 'p0': (2.2, 0, 'notable'), 'p55': (2.0, 55, 'notable')}
    links = [('s0', 'b', 0.1), ('b', 'v-28'), ('b', 'v28'), ('v-28', 'p-55', 0.12), ('v-28', 'p0', -0.12), ('v28', 'p0', 0.12),
             ('v28', 'p55', -0.12)]
    return figure(O, spec, links, [(1944, 's0')])


P56['crown'] = crown56()
fill_rows(P56, [
    ('C crook',    1571, 'Crook', 'bow out', 1.0, 40, 0, True),
    ('D crook',    1570, 'Crook', 'bow in', 1.0, 10, 0, False),
])
CELLS[56] = P56


# ======================================================================================================================
# cell 105 (outer band, th 28..36, its own design): "flame trident", a trunk rising from road node 1567 that splits
# into three prongs with notable tips; round it two Crooks (no room for a medium, left as it was).
# ======================================================================================================================
def trident(base, th, r_trunk, r_split, prongs):
    pts = [F(r, th) for r in r_trunk]
    keys, nodes, links = chain(pts + [F(r_split, th)], ['small'] * (len(pts) + 1), [0.1] * len(pts))
    split = keys[-1]
    for j, ((r1, t1), (r2, t2)) in enumerate(prongs):
        nodes[f'q{j}a'] = (F(r1, t1), 'small'); nodes[f'q{j}b'] = (F(r2, t2), 'notable')
        links += [(split, f'q{j}a', None), (f'q{j}a', f'q{j}b', bow_centre(F(r1, t1), F(r2, t2), 0.15, F(r_split, th)))]
    return piece(nodes, links, [(base, keys[0])])


P105 = {'trident': trident(1567, 32.0, [73.0, 71.6], 70.3,
                           [((69.0, 30.4), (67.9, 29.7)), ((68.9, 32.0), (67.5, 32.0)), ((69.0, 33.6), (67.9, 34.3))])}
fill_rows(P105, [
    ('C crook',    1944, 'Crook', 'bow in', 1.0, 120, 0, False),
    ('D crook',    506, 'Crook', 'bow in', 1.0, -45, 0, False),
])
CELLS[105] = P105


# ======================================================================================================================
# cell 47 (middle band, th 23..36, its own design): "phoenix wing", a spine sweeping down from road node 1584 towards
# the bottom-left with parallel feathers ending in notables (the first feather two long, for R3).
# cell 49 (th -36..-23, its own design): "firework", a star of four rays round a small hub, on a stem from 1592.
# ======================================================================================================================
def wing(base, spine, feathers):
    keys, nodes, links = chain([F(r, t) for r, t in spine], ['small'] * (len(spine) - 1) + ['notable'],
                               [0.08] * (len(spine) - 1))
    for j, (at, pts) in enumerate(feathers):
        prev = keys[at]
        for q, (r, t) in enumerate(pts):
            k = f'f{j}_{q}'; nodes[k] = (F(r, t), 'notable' if q == len(pts) - 1 else 'small')
            links.append((prev, k, bow_centre(nodes[prev][0], F(r, t), 0.12, F(50.0, 36.0)))); prev = k
    return piece(nodes, links, [(base, keys[0])])


P47 = {'wing': wing(1584, [(55.3, 32.4), (56.6, 31.0), (57.9, 29.7), (59.3, 28.5), (60.8, 27.6), (62.4, 27.2)],
                    [(2, [(58.6, 31.2), (59.6, 32.4)]), (3, [(60.6, 30.2)]), (4, [(62.0, 29.3)])])}


def loopflame47():
    """"looping flame": a tongue rising from 1604 that loops once round a small ring and flicks on up to a notable."""
    O = F(60.0, 25.4)
    spec = {'s0': (F(63.0, 24.3), 'small'), 's1': (F(61.7, 25.0), 'small'),
            'r0': (0.95, 180, 'small'), 'r1': (0.95, 90, 'small'), 'r2': (0.95, 0, 'small'), 'r3': (0.95, -90, 'small'),
            't0': (F(57.8, 25.1), 'small'), 't1': (F(56.6, 25.9), 'notable')}
    links = [('s0', 's1', 0.12), ('s1', 'r0'), ('r0', 'r1', 'O'), ('r1', 'r2', 'O'), ('r2', 'r3', 'O'), ('r3', 'r0', 'O'),
             ('r2', 't0', -0.12), ('t0', 't1', 0.15)]
    return figure(O, spec, links, [(1604, 's0')])


def eye47():
    """"phoenix eye": a ring of six beside the wing tip, entered from 1602 below, a pupil node hanging inside from
    the ring's far side, the pupil the notable."""
    O = F(62.2, 33.1)
    spec = {f'r{a}': (1.2, a, 'small') for a in (-60, 0, 60, 120, 180, 240)}
    spec['p'] = (0.0, 0, 'notable')
    links = [(f'r{a}', f'r{a + 60}', 'O') for a in (-60, 0, 60, 120, 180)] + [('r240', 'r-60', 'O'), ('r0', 'p')]
    return figure(O, spec, links, [(1602, 'r180')])


P47['loop'] = loopflame47()
P47['eye'] = eye47()
CELLS[47] = P47


def star(base, stem_pts, hub_r, hub_t, rays):
    keys, nodes, links = chain([F(r, t) for r, t in stem_pts] + [F(hub_r, hub_t)], ['small'] * (len(stem_pts) + 1))
    hub = keys[-1]
    for j, pts in enumerate(rays):
        prev = hub
        for q, (r, t) in enumerate(pts):
            k = f'y{j}_{q}'; nodes[k] = (F(r, t), 'notable' if q == len(pts) - 1 else 'small')
            links.append((prev, k, None)); prev = k
    return piece(nodes, links, [(base, keys[0])])


P49 = {'firework': star(1592, [(62.9, -30.6)], 60.2, -29.6,
                        [[(58.9, -30.5), (57.7, -31.4)], [(59.4, -28.1), (58.4, -26.8)],
                         [(60.6, -27.7), (60.8, -26.0)], [(61.4, -31.0), (61.8, -32.6)]])}


def torch49():
    """"torch": a handle rising from 1594 along the spoke into a small ring head, two flames curling up and out from
    the head's sides, both notables."""
    O = F(57.2, -24.9)
    spec = {'n0': (F(63.0, -24.1), 'small'), 'n1': (F(61.6, -24.7), 'small'), 'n2': (F(60.2, -24.9), 'small'),
            'n3': (F(58.9, -24.7), 'small'),
            'h0': (0.85, 180, 'small'), 'h1': (0.85, 90, 'small'), 'h2': (0.85, 0, 'small'), 'h3': (0.85, -90, 'small'),
            'fl': (1.9, -32, 'notable'), 'fr': (1.9, 30, 'notable')}
    links = [('n0', 'n1', 0.1), ('n1', 'n2', 0.1), ('n2', 'n3', -0.1), ('n3', 'h0'), ('h0', 'h1', 'O'), ('h1', 'h2', 'O'),
             ('h2', 'h3', 'O'), ('h3', 'h0', 'O'), ('h3', 'fl', 0.25), ('h1', 'fr', 0.25)]
    return figure(O, spec, links, [(1594, 'n0')])


P49['torch'] = torch49()
fill_rows(P49, [
    ('D crook',    1512, 'Crook', 'bow in', 1.0, 50, 0, False),
])
CELLS[49] = P49


# ======================================================================================================================
# cell 83 (hub cell inside the Taiji ring, facing Fire): a rising phoenix (big, consolidation 2026-11-18: was a Wheel and
# two Hooks) hanging in from the hub ring at the axis, a Diamond reaching out from the inner hub road.
# ======================================================================================================================
def phoenix83():
    """"rising phoenix": a body up from hub-ring node 29 to a notable head, two wings arched out to both sides and
    drooping at their notable tips (points in the file frame: x across the axis, y out from the tree centre)."""
    spec = {'b0': ((0.0, 13.0), 'small'), 'b1': ((0.0, 11.7), 'small'), 'neck': ((0.0, 10.4), 'small'),
            'head': ((0.0, 9.1), 'notable')}
    wing = [(1.25, 10.95), (2.55, 10.45), (3.8, 10.7), (4.6, 11.7)]
    for side, sx in (('l', -1), ('r', 1)):
        for i, (x, y) in enumerate(wing):
            spec[f'{side}{i}'] = ((sx * x, y), 'notable' if i == 3 else 'small')
    links = [('b0', 'b1'), ('b1', 'neck'), ('neck', 'head')]
    for side in 'lr':
        links += [('b1', f'{side}0', 0.12), (f'{side}0', f'{side}1', 0.12), (f'{side}1', f'{side}2', 0.12),
                  (f'{side}2', f'{side}3', 0.15)]
    return figure((0.0, 11.0), spec, links, [(29, 'b0')])


CELLS[83] = {'phoenix': phoenix83()}
fill_rows(CELLS[83], [
    ('D diamond',  1, 'Diamond', 'round', 1.0, 180, 0, False),
])


# ======================================================================================================================
# cell 3 (the Fire start cell, 558 units²): big and sparse (3.10 B4). Two flame wings (medium, consolidation 2026-11-18,
# were Hairpins) arc out from the hub ring round the start, two Spur pairs reach in from the border roads; mirrored.
# ======================================================================================================================
def wing3(base, sign):
    """A wing of flame from hub-ring node `base`: out, then an arc round the tree centre towards the axis, its tip
    turning out towards the start (sign -1 left of the axis, +1 right)."""
    pts = [(16.0, 18.4), (17.3, 16.4), (17.9, 13.4), (18.2, 10.4), (18.8, 7.6), (20.1, 5.8)]
    keys, nodes, links = chain([F(r, sign * t) for r, t in pts], ['small'] * 5 + ['notable'], [0.1, 0.06, 0.06, 0.1, 0.15])
    return piece(nodes, links, [(base, keys[0])])


CELLS[3] = {'A_wing': wing3(28, -1), 'B_wing': wing3(30, 1)}
fill_rows(CELLS[3], [
    ('C spur',     314, 'Spur pair', 'bow out', 1.2, 90, 0, False),
    ('D spur',     237, 'Spur pair', 'bow out', 1.2, -90, 0, True),
])


# ======================================================================================================================
# cell 901 (Fire's rim, beyond r 74.3, th -33..33): "phoenix tail", two S-curved plumes sweeping out from axis road
# node 500 to either side of the road to the Light island (a split figure across the axis road), the two keystones
# just past the plume ends; consolidation 2026-11-18: each plume grows a barb, a fire wheel and a flame tree hang
# outward from the outer ring, one Tadpole stays.
# ======================================================================================================================
def plume(base, pts, barb=None):
    keys, nodes, links = chain([F(r, t) for r, t in pts], ['small'] * (len(pts) - 1) + ['notable'],
                               [0.16, -0.16, 0.16, -0.16, 0.16][:len(pts) - 1])
    if barb:                         # (at index, [(r, th), ...]): a side barb ending in a notable
        at, bp = barb
        prev = keys[at]
        for q, (r, t) in enumerate(bp):
            k = f'b{q}'
            nodes[k] = (F(r, t), 'notable' if q == len(bp) - 1 else 'small')
            links.append((prev, k, bow_centre(nodes[prev][0], nodes[k][0], 0.15, F(79.0, 0.0)))); prev = k
    return piece(nodes, links, [(base, keys[0])])


def firewheel901():
    """"fire wheel": a ring of six hung from rim node 1561, three tongues swirling off its lower half (two of two nodes,
    one of one), all three tips notables."""
    O = F(77.7, -16.6)
    spec = {f'r{a}': (1.5, a, 'small') for a in range(0, 360, 60)}
    spec.update({'a1': (2.6, 145, 'small'), 'a2': (3.6, 170, 'notable'), 'b1': (2.6, 265, 'small'), 'b2': (3.6, 290, 'notable'),
                 'c': (2.7, 207, 'notable')})
    links = [(f'r{a}', f'r{(a + 60) % 360}', 'O') for a in range(0, 360, 60)]
    links += [('r120', 'a1', 0.15), ('a1', 'a2', 0.15), ('r240', 'b1', 0.15), ('b1', 'b2', 0.15), ('r180', 'c', 0.15)]
    return figure(O, spec, links, [(1561, 'r0')])


def flametree901():
    """"flame tree": a curved trunk out from rim node 1569 that branches into curling flames at two heights, its top and
    three branch tips notables."""
    spec = {'t0': (F(75.7, 24.0), 'small'), 't1': (F(77.2, 24.1), 'small'), 't2': (F(79.0, 23.8), 'small'),
            't3': (F(80.7, 23.0), 'notable'),
            'a1': (F(78.1, 25.6), 'small'), 'a2': (F(79.6, 26.8), 'notable'),
            'b1': (F(78.0, 22.5), 'small'), 'b2': (F(79.4, 21.4), 'notable'),
            'c1': (F(80.2, 25.2), 'small'), 'c2': (F(81.8, 25.6), 'notable')}
    links = [('t0', 't1', 0.08), ('t1', 't2', 0.08), ('t2', 't3', 0.08), ('t1', 'a1', 0.2), ('a1', 'a2', 0.25),
             ('t1', 'b1', -0.2), ('b1', 'b2', -0.25), ('t2', 'c1', 0.2), ('c1', 'c2', 0.25)]
    return figure(F(78.0, 24.0), spec, links, [(1569, 't0')])


P901 = {
    'plume_L': plume(500, [(79.7, -1.6), (80.8, -2.9), (82.1, -3.7), (83.5, -4.0), (84.9, -3.6)],
                     (2, [(82.4, -5.3), (83.3, -6.5)])),
    'plume_R': plume(500, [(79.7, 1.6), (80.8, 2.9), (82.1, 3.7), (83.5, 4.0), (84.9, 3.6)],
                     (2, [(82.4, 5.3), (83.3, 6.5)])),
    'keystone_L': ({'k': (F(81.8, -12.3), 'keystone')}, [(1945, 'k', None)]),
    'keystone_R': ({'k': (F(81.8, 12.3), 'keystone')}, [(1946, 'k', None)]),
    'wheel': firewheel901(),
    'tree': flametree901(),
}
fill_rows(P901, [
    ('A tadpole',  1558, 'Tadpole', 'round', 1.2, 180, 0, False),
])
CELLS[901] = P901


# ======================================================================================================================
# DENSITY PASS (v2, 2026-11-18, design/dao-do/cells/density-brief.md): figures mirrored across cell walls (each half its
# own cluster, the second half wall_pair's exact mirror), grown figures and new pieces in the gaps. Cells 14, 15 and 93
# are untouched. Wall frame: half(O, toward, side, ...) places a node at (rho, phi) round O with phi 0 = along the wall
# towards point `toward`, 90 = straight across the wall into the side holding point `side`.
# ======================================================================================================================
def wframe(O, toward, side):
    L_ = math.dist(O, toward)
    u = ((toward[0] - O[0]) / L_, (toward[1] - O[1]) / L_)
    n = (-u[1], u[0])
    if (side[0] - O[0]) * n[0] + (side[1] - O[1]) * n[1] < 0:
        n = (-n[0], -n[1])
    return u, n


def half(O, toward, side, spec, links, entries):
    """A half figure in the wall frame round O. spec {key: (rho, phi, kind)} or {key: ((x, y), kind)}; links as
    figure() ('O' = arc round O, a number = bow share, a point = arc round it)."""
    u, n = wframe(O, toward, side)
    pts = {}
    for k, v in spec.items():
        if len(v) == 3:
            rho, phi, kd = v; p = math.radians(phi)
            pts[k] = ((O[0] + rho * (math.cos(p) * u[0] + math.sin(p) * n[0]),
                       O[1] + rho * (math.cos(p) * u[1] + math.sin(p) * n[1])), kd)
        else:
            pts[k] = v
    return figure(O, pts, links, entries)


def wpoint(O, toward, side, rho, phi):
    u, n = wframe(O, toward, side); p = math.radians(phi)
    return (O[0] + rho * (math.cos(p) * u[0] + math.sin(p) * n[0]), O[1] + rho * (math.cos(p) * u[1] + math.sin(p) * n[1]))


def pair(name, cell_a, cell_b, wa, wb, built):
    """Put a half (drawn in cell_a) in cell_a and its mirror across the wall wa-wb in cell_b."""
    h, o = wall_pair({name: built}, wa, wb)
    assert name not in CELLS[cell_a] and name not in CELLS[cell_b], (name, cell_a, cell_b)
    CELLS[cell_a].update(h); CELLS[cell_b].update(o)


# --- pair "horizon sun" across the ring r 53.9 at road node 1585 (cells 28 | 47): a sun half above the ring road, a flame
# tongue rising from its crown, and its reflection below; the road is the horizon. ----------------------------------------
def horizon_sun():
    O = road(1585)
    spec = {'s': (1.0, 90, 'small'), 'a35': (1.9, 35, 'notable'), 'a62': (1.9, 62.5, 'small'), 'a90': (1.9, 90, 'small'),
            'a118': (1.9, 117.5, 'small'), 'a145': (1.9, 145, 'notable')}
    links = [('s', 'a90'), ('a90', 'a62', 'O'), ('a62', 'a35', 'O'), ('a90', 'a118', 'O'), ('a118', 'a145', 'O')]
    return half(O, road(1584), F(48.0, 27.0), spec, links, [(1585, 's')])


pair('horizon_sun', 28, 47, 1585, 1584, horizon_sun())


# --- pair "flame crown" across the ring r 53.9 at 1578 (cells 29 | 49; the varied twin of the horizon sun): a stem to a
# zigzag of peaks and valleys on two circles round 1578, its end peaks notables; mirrored it reads as a burst. -----------
def flame_crown():
    O = road(1578)
    spec = {'s': (1.0, 90, 'small'), 'v90': (1.75, 90, 'small'),
            'p65': (2.5, 64, 'small'), 'v40': (1.8, 41, 'small'), 'p22': (2.5, 22, 'notable'),
            'p115': (2.5, 116, 'small'), 'v140': (1.8, 139, 'small'), 'p158': (2.3, 150, 'notable')}
    links = [('s', 'v90'), ('v90', 'p65', 0.16), ('p65', 'v40', -0.16), ('v40', 'p22', 0.16), ('v90', 'p115', -0.16),
             ('p115', 'v140', 0.16), ('v140', 'p158', -0.16)]
    return half(O, road(1577), F(48.0, -29.0), spec, links, [(1578, 's')])


pair('flame_crown', 29, 49, 1578, 1577, flame_crown())


# --- pair "flame eye" across the ring r 33.2 at 1537 (cells 120 | 3, the start cell's outer wall): a lens standing on
# the road node, its far tip a notable; mirrored, one spindle the ring road pierces at its waist. ----------------------
def flame_eye(O, toward, side, phi, r0, r1, bow, kinds):
    A, B = wpoint(O, toward, side, r0, phi), wpoint(O, toward, side, r1, phi)
    return lens(A, B, (bow, bow), 2, kinds, [])


def eye_pair():
    nodes, links = flame_eye(road(1537), road(1538), F(37.0, 32.0), 98, 1.0, 3.5, 0.24, {'B': 'notable'})
    return nodes, [(1537, 'A', None)] + links


pair('flame_eye', 120, 3, 1537, 1538, eye_pair())


# --- pair "flame scroll" across the ring r 33.2 at 1531 (cells 119 | 3; the eye's varied twin): a curl spiralling in
# from the road node to a notable heart; mirrored, two scrolls back to back on the ring road. -------------------------
def scroll(O, toward, side, cphi, crho, radii, a0, step, hand, notables):
    C = wpoint(O, toward, side, crho, cphi)
    e1 = ((O[0] - C[0]) / crho, (O[1] - C[1]) / crho)
    u, n = wframe(O, toward, side)
    s = 1 if (e1[0] * n[1] - e1[1] * n[0]) * hand > 0 else -1          # turn sense
    e2 = (-e1[1] * s, e1[0] * s)
    pts = []
    for k, rr in enumerate(radii):
        a = math.radians(a0 + step * k)
        pts.append((C[0] + rr * (math.cos(a) * e1[0] + math.sin(a) * e2[0]), C[1] + rr * (math.cos(a) * e1[1] + math.sin(a) * e2[1])))
    keys = [f'p{k}' for k in range(len(pts))]
    nodes = {k: (p, 'notable' if i in notables else 'small') for i, (k, p) in enumerate(zip(keys, pts))}
    links = [(keys[k], keys[k + 1], bow_centre(pts[k], pts[k + 1], 0.12, C)) for k in range(len(pts) - 1)]
    return nodes, links


def scroll_pair():
    nodes, links = scroll(road(1531), road(1532), F(37.0, -32.0), 100, 2.3, [1.35, 1.35, 1.25, 1.1, 0.9, 0.7], 35, 62, 1,
                          (5,))
    return nodes, [(1531, 'p0', None)] + links


pair('flame_scroll', 119, 3, 1531, 1532, scroll_pair())


# --- small pieces in the gaps (texture; rows as FILL: name, road, family, style, stem, ang, turn, hand) ----------------
DENSE_SMALL = {
    101: [('d diamond', 1592, 'Diamond', 'cusped', 1.0, 160, 0, False),
          ('d crescent', 1557, 'Crescent', 'bow out', 1.0, 35, 0, False),
          ('d fork', 518, 'Fork', 'bow out', 1.0, 50, 0, True)],
    105: [('d hook', 1567, 'Hook', 'bow in', 1.0, -50, 0, True)],
    53:  [('d hairpin', 1560, 'Hairpin', 'tight turn', 1.2, 25, 0, False),
          ('d spur',    1594, 'Spur pair', 'bow out', 1.2, -150, 0, False),
          ('d hook', 1558, 'Hook', 'bow in', 1.0, 50, 0, False)],
    56:  [('d hook',    1568, 'Hook', 'bow out', 1.1, -45, 0, True),
          ('d diamond', 1606, 'Diamond', 'round', 1.1, 140, 0, False),
          ('d crook',   1604, 'Crook', 'bow out', 1.0, 180, 0, True)],
    63:  [('d ring',    1555, 'Ring', 'round', 1.1, -28, 0, False),
          ('d fork', 1552, 'Fork', 'bow out', 1.0, -40, 0, False)],
    62:  [('d tadpole', 1547, 'Tadpole', 'round', 1.1, -26, 0, False),
          ('d hook',    1545, 'Hook', 'bow out', 1.0, 45, 0, False),
          ('d zigzag', 1549, 'Zigzag', 'wave', 1.0, -40, 0, True)],
    92:  [('d ring',    1600, 'Ring', 'cusped', 1.1, 32, 0, False),
          ('d crook',   1583, 'Crook', 'bow out', 1.0, -150, 0, True)],
    47:  [('d fork', 1584, 'Fork', 'bow out', 1.1, 140, 0, False)],
    49:  [('d hook', 1577, 'Hook', 'bow in', 1.0, -160, 0, True),
          ('d crook',   1593, 'Crook', 'bow in', 1.0, -20, 0, True)],
    29:  [('d arch',    1543, 'Arch', 'bow out', 1.2, -165, 0, False),
          ('d crescent', 1545, 'Crescent', 'bow in', 1.0, -170, 0, False)],
    28:  [('d tadpole', 1550, 'Tadpole', 'cusped', 1.1, 175, 0, False)],
    18:  [('d hook',    1556, 'Hook', 's-curve', 1.1, -160, 0, False),
          ('d crook',   1590, 'Crook', 'bow out', 1.0, -31, 0, True)],
    37:  [('d diamond', 1583, 'Diamond', 'lop-sided', 1.1, 45, 0, False)],
    70:  [('d crook',   1588, 'Crook', 'bow in', 1.0, 132, 0, True)],
}
for _c, _rows in DENSE_SMALL.items():                    # piece names carry the road node: d_<family>_<road>
    assert not {f'{r[0]} {r[1]}'.replace(' ', '_') for r in _rows} & set(CELLS[_c]), _c
    fill_rows(CELLS[_c], [(f'{r[0]} {r[1]}',) + tuple(r[1:]) for r in _rows])
CELLS[37].update(mirror_pieces({'d_hook_1549': CELLS[18]['d_hook_1556']}, LAND))          # land twins
CELLS[74].update(mirror_pieces({'d_crook_1581': CELLS[70]['d_crook_1588']}, LAND))


# --- pair "ember petals" across the ring r 64.3 at 1593 (cells 49 | 53): a small petal leaning towards 1594, tip
# notable; mirrored, a V of two petals opening along the ring road. -------------------------------------------------------
def petal_pair():
    O, T, S = road(1593), road(1594), F(61.0, -27.0)
    A, B = wpoint(O, T, S, 1.0, 50), wpoint(O, T, S, 2.6, 42)
    nodes, links = lens(A, B, (0.3, 0.3), 2, {'B': 'notable'}, [])
    return nodes, [(1593, 'A', None)] + links


pair('ember_petals', 49, 53, 1593, 1594, petal_pair())


# --- pair "spark hooks" across the ring r 64.3 at 1602 (cells 47 | 105): a three-node hook curling towards 1603, tip
# notable; mirrored, a pair of horns on the ring road. -------------------------------------------------------------------
def hook_pair():
    O, T, S = road(1602), road(1603), F(60.0, 31.0)
    spec = {'a': (1.0, 62, 'small'), 'b': (1.85, 70, 'small'), 'c': (2.6, 86, 'notable')}
    return half(O, T, S, spec, [('a', 'b', 0.12), ('b', 'c', 0.2)], [(1602, 'a')])


pair('spark_hooks', 47, 105, 1602, 1603, hook_pair())

# --- second round of small pieces -------------------------------------------------------------------------------------
DENSE_SMALL_2 = {
    56:  [('d fork', 1569, 'Fork', 'bow out', 1.0, -50, 0, False)],
    29:  [('d diamond', 311, 'Diamond', 'cusped', 1.0, 62, 0, False)],
    28:  [('d crook', 1551, 'Crook', 'swept', 1.0, 140, 0, True)],
}
for _c, _rows in DENSE_SMALL_2.items():
    assert not {f'{r[0]} {r[1]}'.replace(' ', '_') for r in _rows} & set(CELLS[_c]), _c
    fill_rows(CELLS[_c], [(f'{r[0]} {r[1]}',) + tuple(r[1:]) for r in _rows])

# --- pairs "wall sparks" across the ring r 33.2 at 1541 (cells 63 | 3) and 1535 (62 | 3): small curls either side of the
# corona's entry, each mirrored into the start cell's outer rim. 1535 mirrors 1541's first spark; its second differs. ----
def spark(O, T, S, spec, bows, entry):
    keys = list(spec)
    return half(O, T, S, spec, [(keys[i], keys[i + 1], bows[i]) for i in range(len(keys) - 1)], [(entry, keys[0])])


_S63 = F(37.0, 14.0)
pair('wall_spark_a1541', 63, 3, 1541, 1542, spark(road(1541), road(1542), _S63,
     {'a': (1.0, 47, 'small'), 'b': (1.8, 56, 'small'), 'c': (2.45, 38, 'notable')}, (0.15, 0.2), 1541))
pair('wall_spark_b1541', 63, 3, 1541, 1542, spark(road(1541), road(1542), _S63,
     {'a': (1.0, 132, 'small'), 'b': (1.75, 122, 'small'), 'c': (2.5, 132, 'small'), 'd': (2.9, 148, 'notable')},
     (-0.12, -0.15, -0.2), 1541))
_m = mirror_pieces({'wall_spark_a1535': CELLS[63]['wall_spark_a1541']}, LAND)
pair('wall_spark_a1535', 62, 3, 1535, 1536, _m['wall_spark_a1535'])
pair('wall_spark_c1535', 62, 3, 1535, 1536, spark(road(1535), road(1536), F(37.0, -14.0),
     {'a': (1.0, 133, 'small'), 'b': (1.8, 126, 'small'), 'c': (2.35, 145, 'notable')}, (0.2, 0.2), 1535))

DENSE_SMALL_3 = {
    105: [('d crook', 1601, 'Crook', 'bow in', 1.0, -170, 0, True)],
    101: [('d crook b', 1592, 'Crook', 'bow out', 1.0, -140, 0, True)],
    47:  [('d crook', 1586, 'Crook', 'bow out', 1.0, 128, 0, True)],
}
for _c, _rows in DENSE_SMALL_3.items():
    assert not {f'{r[0]} {r[1]}'.replace(' ', '_') for r in _rows} & set(CELLS[_c]), _c
    fill_rows(CELLS[_c], [(f'{r[0]} {r[1]}',) + tuple(r[1:]) for r in _rows])

# --- grown figures ---------------------------------------------------------------------------------------------------
def grow(piece, nodes, links):
    """A copy of piece (nodes, links) with extra nodes {key: ((x, y), kind)} and links (a, b, bow share or None)."""
    nn, ll = dict(piece[0]), list(piece[1])
    nn.update(nodes)
    cen = (sum(p[0] for p, _ in nn.values()) / len(nn), sum(p[1] for p, _ in nn.values()) / len(nn))
    for a, b, bow in links:                  # bow share + = away from the grown piece's centroid
        ll.append((a, b, bow_centre(nn[a][0], nn[b][0], bow, cen) if bow else None))
    return nn, ll


# hearth flame_c (18, and its mirror in 37) grows a side lick into the gap by the spoke.
_fc = CELLS[18]['flame_c']
_t0, _t1 = F(50.6, 13.9), F(49.6, 15.1)
CELLS[18]['flame_c'] = ({**_fc[0], 't0': (_t0, 'small'), 't1': (_t1, 'notable')},
                        _fc[1] + [('c1', 't0', bow_centre(_fc[0]['c1'][0], _t0, -0.18, F(53.9, 18.0))),
                                  ('t0', 't1', bow_centre(_t0, _t1, 0.18, F(53.9, 18.0)))])
CELLS[37].update(mirror_pieces({'flame_c': CELLS[18]['flame_c']}, LAND))

# two small rings (63 from 1555, 92 from 1600) take a pupil, a notable at the centre hung from the ring's second node.
for _c, _k in ((63, 'd_ring_1555'), (92, 'd_ring_1600')):
    _nn = CELLS[_c][_k][0]
    _ctr = (sum(p[0] for p, _ in _nn.values()) / 5, sum(p[1] for p, _ in _nn.values()) / 5)
    CELLS[_c][_k] = (dict(_nn, p=(_ctr, 'notable')), CELLS[_c][_k][1] + [('n1', 'p', None)])

# hearth flame_a (18, mirrored in 37) runs on two nodes down beside the axis hex.
_fa = CELLS[18]['flame_a']
CELLS[18]['flame_a'] = ({**_fa[0], 'c2': (_fa[0]['c2'][0], 'small'), 'c3': (F(48.9, 5.0), 'small'), 'c4': (F(47.6, 4.6), 'notable')},
                        _fa[1] + [('c2', 'c3', bow_centre(_fa[0]['c2'][0], F(48.9, 5.0), 0.18, F(50.0, 6.0))),
                                  ('c3', 'c4', bow_centre(F(48.9, 5.0), F(47.6, 4.6), -0.18, F(50.0, 6.0)))])
CELLS[37].update(mirror_pieces({'flame_a': CELLS[18]['flame_a']}, LAND))

# sunrise (28) grows a second flame from its stem towards the spoke; the 29 twin grows a shorter, steeper one.
CELLS[28]['sunrise'] = grow(CELLS[28]['sunrise'], {'d1': (F(50.2, 21.7), 'small'), 'd2': (F(49.0, 20.8), 'notable')},
                            [('c1', 'd1', 0.15), ('d1', 'd2', -0.15)])
CELLS[29]['sunrise'] = grow(CELLS[29]['sunrise'], {'d1': (F(49.9, -21.9), 'small'), 'd2': (F(48.9, -21.1), 'notable')},
                            [('c1', 'd1', -0.2), ('d1', 'd2', 0.1)])

# ember corona (63, mirrored in 62): the arc doubles its nodes (one every 11 degrees round its centre).
CELLS[63]['corona'] = corona(1541, F(31.4, 14.0), 5.2, [136 + 11 * i for i in range(9)], 7.4, [2, 6])
CELLS[62]['corona'] = mirror_pieces({'corona': CELLS[63]['corona']}, LAND)['corona']


# ======================================================================================================================
# trial rows for the sweep (never part of the design)
# ======================================================================================================================
_extra = json.loads(os.environ.get('FIRE_EXTRA') or '{}')
if _extra:
    CELLS.setdefault(_extra['cell'], {})
    fill_rows(CELLS[_extra['cell']], [tuple(r) for r in _extra['rows']])
