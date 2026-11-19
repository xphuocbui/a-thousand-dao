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


def sun18(rays=((90, 1), (270, -1), (180, 1))):
    """"hearth sun": a ring of eight hung from inner-ring node 1555, three flame rays with notable tips (sideways
    both ways and down towards the flames)."""
    O = F(44.5, 9.4)
    spec = {f'r{a}': (1.3, a, 'small') for a in range(0, 360, 45)}
    links = [(f'r{a}', f'r{(a + 45) % 360}', 'O') for a in range(0, 360, 45)]
    for a, lean in rays:                                # w1: each ray a two-node flame (was one straight spike)
        spec[f'u{a}'] = (2.0, a + 9 * lean, 'small'); spec[f't{a}'] = (2.75, a + 3 * lean, 'notable')
        links += [(f'r{a}', f'u{a}', 0.15 * lean), (f'u{a}', f't{a}', -0.15 * lean)]
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
# w1: 37's sun turns its drop-side ray down towards the flames (it touched the drop), so the two suns differ.
P37['sun'] = mirror_pieces({'sun': sun18(((135, 1), (270, -1), (180, 1)))}, LAND)['sun']


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


def wisp28(rc=(46.8, 49.4), th=33.5, rho=1.3, outer=(60, 120, 180, 240, 300)):
    """"flame wisp" (w1 2026-11-18: rebuilt on circles, was freehand): an S of two equal circles touching at a waist
    node J up the strip by the spoke, nodes every 60 degrees round each circle's own centre, the two ends notables;
    entered from spoke node 235 on the outer circle's spoke side."""
    C1, C2 = F(rc[0], th), F(rc[1], th)
    spec = {'J': (orbit(C1, rho, 180), 'small')}
    spec.update({f'i{a}': (orbit(C1, rho, a), 'notable' if a == 60 else 'small') for a in (-120, -60, 0, 60)})
    spec.update({f'o{a}': (orbit(C2, rho, a), 'notable' if a == outer[-1] else 'small') for a in outer})
    links = [('J', 'i-120', C1), ('i-120', 'i-60', C1), ('i-60', 'i0', C1), ('i0', 'i60', C1), ('J', f'o{outer[0]}', C2)]
    links += [(f'o{a}', f'o{b}', C2) for a, b in zip(outer, outer[1:])]
    return figure(C2, spec, links, [(235, 'o120')])


def pinwheel28():
    """"spark pinwheel": a hub on a short stem from 1552, three arms curling the same way, notable tips."""
    H = F(44.5, 21.9)
    spec = {'s0': (F(43.1, 22.5), 'small'), 'h': (H, 'small')}
    links = [('s0', 'h')]
    for j, a in enumerate((75, 165, 255)):
        spec[f'a{j}'] = (orbit(H, 1.1, a), 'small'); spec[f'b{j}'] = (orbit(H, 2.0, a + 35), 'notable')
        links += [('h', f'a{j}', 0.12), (f'a{j}', f'b{j}', 0.2)]
    return figure(H, spec, links, [(1552, 's0')])


def halfsun28(flame='drop'):
    """"sunrise": a half sun on the bottom ring round road node 1586, its two horns notables; from its middle a flame
    rises towards the spiral as a teardrop (w1 2026-11-18, was two bent stalks): a circle on the sun's own axis, its
    point a notable aimed at the tree centre."""
    O = road(1586)
    spec = {f'a{a}': (1.8, a, 'notable' if abs(a) == 56 else 'small') for a in (-56, -28, 0, 28, 56)}
    links = [('a-56', 'a-28', 'O'), ('a-28', 'a0', 'O'), ('a0', 'a28', 'O'), ('a28', 'a56', 'O')]
    if flame == 'drop':
        D = orbit(O, 3.65, 0)
        spec.update({f'd{a}': (orbit(D, 0.9, a), 'small') for a in (180, 120, 60, -60, -120)})
        spec['tip'] = (orbit(D, 1.55, 0), 'notable')
        links += [('a0', 'd180'), ('d180', 'd120', D), ('d120', 'd60', D), ('d60', 'tip'), ('tip', 'd-60'),
                  ('d-60', 'd-120', D), ('d-120', 'd180', D)]
        return figure(O, spec, links, [(1586, 'a0')])
    nodes, ll = figure(O, spec, links, [(1586, 'a0')])      # 'lens': a slimmer flame, two arcs to a notable tip
    ln, lk = lens(orbit(O, 2.9, 0), orbit(O, 5.0, 0), (0.2, 0.2), 2, {'B': 'notable'}, [])
    nodes.update({'f' + k: v for k, v in ln.items()})
    return nodes, ll + [('a0', 'fA', None)] + [('f' + a, 'f' + b, c) for a, b, c in lk]


P28 = {'spiral': spiral(F(47.9, 27.3), 3.6, 0.27, -10, 45, 10, (5, 9), 1551),
       'wisp': wisp28(), 'pinwheel': pinwheel28(), 'sunrise': halfsun28()}
fill_rows(P28, [
    ('lily R',     1587, 'Diamond', 'cusped', 1.4, 45, 0, True),
])
CELLS[28] = P28

# cell 29: 28 mirrored (the spiral now turns the other way); the pinwheel becomes a closed flame crescent.
P29 = mirror_pieces({k: v for k, v in P28.items() if k not in ('lily_R', 'pinwheel')}, LAND)
# w1: the big figures differ by a little from 28's (rule 3.3, a big drawing once): the wisp's lower curl one node
# shorter, the sunrise flame a lens instead of a teardrop.
P29.update(mirror_pieces({'wisp': wisp28(outer=(60, 120, 180, 240)), 'sunrise': halfsun28('lens')}, LAND))


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
# cell 70 (53.9-64.3, th 11..23): "flame heart", two lobes on circles (w1 2026-11-18; were freehand curls, before that
# Hairpins) rising from the bottom ring and curling towards each other round a Tadpole, the flame lily's lower petal
# (from 1587) hanging into the gap above them; twin embers on the spoke. cell 74: its mirror, one piece different.
# ======================================================================================================================


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
def lobe(base, stem, C, rho, angs, name):
    """A heart lobe (w1 2026-11-18, was a freehand curl): a stem node from road node `base`, then nodes on the circle
    rho round C at the given orbit angles, every link an arc round C; the last node a notable."""
    spec = {'s0': (F(*stem), 'small')}
    keys = [f'k{i}' for i in range(len(angs))]
    spec.update({k: (orbit(C, rho, a), 'notable' if i == len(angs) - 1 else 'small') for i, (k, a) in enumerate(zip(keys, angs))})
    links = [('s0', keys[0])] + [(keys[i], keys[i + 1], 'O') for i in range(len(keys) - 1)]
    return {name: figure(C, spec, links, [(base, 's0')])}


# "flame heart": two lobes on equal circles mirrored about th 17, rising from 1607 and 1605 up the outer sides, over the
# top and down towards the core Tadpole between them.
P70.update(lobe(1607, (63.25, 14.1), F(60.9, 14.4), 1.3, [180, -120, -60, 0, 60], 'heart_L'))
P70.update(lobe(1605, (63.3, 19.9), F(60.75, 19.7), 1.45, [180, 120, 60, 0, -60], 'heart_R'))   # a little fuller
P70['embers'] = embers70()
fill_rows(P70, [
    ('lily D',     1587, 'Diamond', 'cusped', 1.2, 180, 0, False),
    ('core',       1606, 'Tadpole', 'round', 1.0, 0, 0, False),
    ('B lantern',  1586, 'Tadpole', 'curled stalk', 2.0, -160, 0, False),   # w2: was a Diamond on a 1.2 stem (below)
])  # w2 (18|28, 28|70): the B Diamond off 1586 sat in the crowded corner of four cells (the sunrise, three lily petals
    # and it on 1586/1587); a curled-stalk Tadpole on a long stem now hangs from 1586 into 70's empty upper right
    # instead, clear of the junction (74 mirrors it at 1579).
    # w3: replaced by a flame lens, see the w3 block at the end.
CELLS[70] = P70

# cell 74: 70 mirrored; the corner piece differs (w2: 70 a curled-stalk Tadpole, 74 a Hook, both on long stems).
P74 = mirror_pieces({k: v for k, v in P70.items() if k != 'B_lantern'}, LAND)
# w2 (29|74): 74's B Tadpole off 1579 (stem 1.1, in the same crowded corner) replaced by a Hook on a long stem hanging
# clear of the junction (70's lantern mirrored here stood ring head to ring head with 49's torch across the spoke).
fill_rows(P74, [('B hook', 1579, 'Hook', 'bow in', 2.0, 160, 0, True)])
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
    barbs = [('s1', [F(56.3, -7.6), F(56.0, -9.1)]), ('s2', [F(57.75, -4.25), F(57.4, -3.0)]),    # w1: every barb two
             ('s3', [F(59.6, -6.3), F(59.3, -7.5)]), ('s4', [F(60.7, -4.4), F(60.4, -3.2)])]            # nodes (no spikes)
    for j, (at, pts) in enumerate(barbs):
        prev = at
        for q, pt in enumerate(pts):
            key = f'b{j}_{q}'
            nodes[key] = (pt, 'notable' if q == len(pts) - 1 else 'small')
            a, b = nodes[prev][0], pt
            links.append((prev, key, bow_centre(a, b, 0.16, F(64.0, -5.5)))); prev = key
    return piece(nodes, links, [(1582, 's0')])


P92 = {'feather': feather()}


def twinflame92(C=(61.0, -9.5), rho=1.1, left=(-120, -60, -10), right=(120, 60)):
    """"twin flame" (w1 2026-11-18: rebuilt on one circle, was two freehand tongues): two tongues of unequal length
    rising from the bottom node B of a circle round C, up its two sides (60-degree steps, the long tongue's last one 50
    to keep clear of the spoke) to notable tips that leave the top open (the flame's outline); on a stem from 1598."""
    Cp = F(*C)
    spec = {'s0': (F(63.1, -10.2), 'small'), 'B': (orbit(Cp, rho, 180), 'small')}
    links = [('s0', 'B')]
    for side, angs in (('l', left), ('r', right)):
        prev = 'B'
        for i, a in enumerate(angs):
            k = f'{side}{i}'
            spec[k] = (orbit(Cp, rho, a), 'notable' if i == len(angs) - 1 else 'small')
            links.append((prev, k, 'O')); prev = k
    return figure(Cp, spec, links, [(1598, 's0')])


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
    for j, i in enumerate(tip_at):          # w1: each tip a two-node flame leaning away from the arc's middle (was one spike)
        sg = 1 if angs[i] > sum(angs) / len(angs) else -1
        u = orbit(O, (rho + tip_rho) / 2, angs[i] + 3.5 * sg); t = orbit(O, tip_rho, angs[i] + 1.0 * sg)
        nodes[f'u{j}'] = (u, 'small'); nodes[f't{j}'] = (t, 'notable')
        links += [(f'k{i}', f'u{j}', bow_centre(nodes[f'k{i}'][0], u, 0.15 * sg, O)), (f'u{j}', f't{j}', bow_centre(u, t, -0.15 * sg, O))]
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
# flicker (was a closed Fork and a Crook). w4: the comet's tails splay, see the w4 block at the end.
# ======================================================================================================================
def comet120():
    """"comet": a ring head of four flying down towards -theta, two tail streaks behind it, one hung from spoke node
    1514, the other ending in a notable; the head's leading node a notable. w1 2026-11-18: the streaks run on circles
    round the tree centre (parallel to the ring roads), each leaving the head on its own radius (were straight)."""
    O = F(39.0, 28.0)
    spec = {'rb': (0.85, 60, 'small'), 'rl': (0.85, -30, 'small'), 'rf': (0.85, -120, 'notable'), 'rr': (0.85, 150, 'small')}
    rad = lambda p: math.hypot(*p)
    pb, pr = orbit(O, 0.85, 60), orbit(O, 0.85, 150)
    spec.update({'t1b': (F(rad(pb), 31.0), 'small'), 't1c': (F(rad(pb), 32.9), 'small'), 't1a': (F(rad(pb), 34.6), 'small'),
                 't2b': (F(rad(pr), 30.5), 'small'), 't2c': (F(rad(pr), 32.3), 'small'), 't2a': (F(rad(pr), 34.0), 'notable')})
    Z = (0.0, 0.0)
    links = [('rb', 'rl', 'O'), ('rl', 'rf', 'O'), ('rf', 'rr', 'O'), ('rr', 'rb', 'O'), ('t1a', 't1c', Z), ('t1c', 't1b', Z),
             ('t1b', 'rb', Z), ('rr', 't2b', Z), ('t2b', 't2c', Z), ('t2c', 't2a', Z)]
    return figure(O, spec, links, [(1514, 't1a')])


def flicker119():
    """"flicker": a zigzag flame edge on two circles round one centre (valleys on the inner, peaks on the outer), rising
    from inner-ring node 1544 and arching over; three of its peaks notables."""
    O = F(41.5, -29.5)
    angs = [45, 30, 15, 0, -15, -30, -45, -60, -75]          # w1: one more valley, the edge running on to a notable
    spec = {f'k{i}': (3.5 if i % 2 else 2.6, a, 'notable' if i in (3, 5, 8) else 'small') for i, a in enumerate(angs)}
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
# road node 1560, plus the split ring's right half and a flame fleur (consolidation 2026-11-18; w1: fleur on circles;
# w4: the 1560 ring a Zigzag wave, see the w4 block at the end).
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


def fleur53(B=(71.9, -24.0), T=(67.9, -24.0), rho=0.9, ends=(0, -60, -120)):
    """"flame fleur" (w1 2026-11-18: rebuilt on circles, was a straight stick with two freehand petals): on a stem from
    1559, a tall lens tongue from base node B to a notable tip T, and two petals, each on its own small circle beside
    B (B on the circle at +-90), curling up and over outwards, their ends notables."""
    Bp, Tp = F(*B), F(*T)
    nodes, links = lens(Bp, Tp, (0.12, 0.12), 1, {'B': 'notable'}, [])
    nodes = {('b' if k == 'A' else 't' if k == 'B' else k): v for k, v in nodes.items()}
    nodes['b'] = (Bp, 'small')
    ren = {'A': 'b', 'B': 't'}
    links = [(ren.get(x, x), ren.get(y, y), c) for x, y, c in links]
    for side, sg in (('L', -1), ('R', 1)):
        C = orbit(Bp, rho, 90 * sg)
        prev = 'b'
        for i, a in enumerate(ends):
            k = f'{side}{i}'
            nodes[k] = (orbit(C, rho, a if sg < 0 else -a), 'notable' if i == len(ends) - 1 else 'small')
            links.append((prev, k, C)); prev = k
    nodes['s0'] = (F(73.15, -24.0), 'small')
    links.append(('s0', 'b', None))
    return nodes, [(1559, 's0', None)] + links


SPLIT = [20 + 140 * i / 6 for i in range(7)]
P53 = {
    'split_ring_R': half_ring(1943, 2.2, SPLIT, 3),
    'fireball': fireball(1560, [(72.9, -21.0), (71.6, -21.7), (70.3, -21.4)], F(67.7, -20.4), 1.3),
    'fleur': fleur53(),
}
CELLS[53] = P53

# cell 101 (th -36..-28, its own design): the split ring's left half and a "spark star" off the border road (w2: turned
# 12 deg; a Hairpin off 1557 arches over the bottom).
def star101():
    """"spark star": a five-pointed star outline (tips and waists on two circles round one centre), one tip hung from
    border-road node 517; three of the other tips notables."""
    O = F(69.3, -33.0)
    a0 = -104                     # w2: turned 12 deg (was -92) so its tip clears the 518 fork (1.39)
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
# crown from spoke node 1944 and two Crooks (consolidation 2026-11-18); w2: an outer orbit arc on taiji_b's open spoke side
# (w3: removed again, see the w3 block at the end; orbit56 stays as the record; w4: the 1568 Diamonds a petal V, the
# 1570 Crook a Hairpin, see the w4 block).
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


def orbit56(C=(70.0, 24.6), rho=2.6, angs=(100, 118, 137, 155)):
    """w2 (56|105, the empty strip by the spoke and 1568): an outer orbit arc round taiji_b's own centre on its open
    spoke side (the spiral's outer turn runs only on the far side), hung from spoke node 1944 by a stem; nodes at even
    steps round the spiral's centre, the end a notable."""
    O = F(*C)
    spec = {'st': (F(69.9, 27.35), 'small')}
    spec.update({f'a{a}': (rho, a, 'notable' if a == angs[-1] else 'small') for a in angs})
    links = [('st', f'a{angs[0]}')] + [(f'a{a}', f'a{b}', 'O') for a, b in zip(angs, angs[1:])]
    return figure(O, spec, links, [(1944, 'st')])


P56['orbit'] = orbit56()
fill_rows(P56, [
    ('C crook',    1571, 'Crook', 'bow out', 1.0, 40, 0, True),
    ('D crook',    1570, 'Crook', 'bow in', 1.0, 35, 0, False),   # w2: turned towards the fork's old place
])
CELLS[56] = P56


# ======================================================================================================================
# cell 105 (outer band, th 28..36, its own design): "flame trident", a psi on a circle from road node 1567 (w1
# 2026-11-18; was a trunk with three straight prongs); round it a small piece in each corner (w2: hooks off 1602 and 1601
# either side of the tine, the 1567 hook, the 506 Crook; w3: the 1602 and 1567 hooks replaced by an outer orbit arc and a
# corner Diamond, see the w3 block at the end; w4: that Diamond pair a petal V across the 1568 wall, see the w4 block).
# ======================================================================================================================


def psi105(th=33.0, trunk=((73.0, 32.4), (71.7, 32.8)), U=68.9, rho=1.5, arms=(125, 80, 35), tine=2.5):
    """"flame trident" (w1 2026-11-18: rebuilt on a circle, was a trunk with three straight prongs): a trunk from 1567
    up to the bottom node S of a circle rho round U; the two side prongs run up the circle's sides in 45-degree steps to
    notable tips, the middle tine rises from S through the circle's centre out of its open top to a notable."""
    O = F(U, th)
    spec = {f'c{i}': (F(*p), 'small') for i, p in enumerate(trunk)}
    spec['S'] = (orbit(O, rho, 180), 'small'); spec['m'] = (O, 'small'); spec['t'] = (orbit(O, tine, 0), 'notable')
    spec['n'] = (orbit(O, tine / 2, 0), 'small')
    links = [('c0', 'c1'), ('c1', 'S'), ('S', 'm'), ('m', 'n'), ('n', 't')]
    for side, sg in (('l', -1), ('r', 1)):
        prev = 'S'
        for i, a in enumerate(arms):
            k = f'{side}{i}'
            spec[k] = (orbit(O, rho, sg * a), 'notable' if i == len(arms) - 1 else 'small')
            links.append((prev, k, 'O')); prev = k
    return figure(O, spec, links, [(1567, 'c0')])


P105 = {'trident': psi105()}
fill_rows(P105, [            # w2 (56|105): the C Crook off 1944 removed (a second stick on the crown's node, 1.46 from
    ('D crook',    506, 'Crook', 'bow in', 1.0, -45, 0, False),    # the 1567 hook); the trident keeps four corner pieces
])
CELLS[105] = P105


# ======================================================================================================================
# cell 47 (middle band, th 23..36, its own design): "phoenix wing", a spine sweeping down from road node 1584 towards
# the bottom-left with parallel feathers ending in notables (the first feather two long, for R3).
# cell 49 (th -36..-23, its own design): "firework", a five-armed catherine wheel on a stem from 1592 (w1 2026-11-18;
# was a star of four straight rays), and a torch. w4: 47's eye opened into a half ring, 49's wheel a three-armed whorl
# (see the w4 block at the end).
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
                    [(2, [(58.6, 31.2), (59.6, 32.4)]), (3, [(60.0, 30.0), (61.0, 31.2)]), (4, [(61.5, 29.1), (62.5, 30.3)])])}
# w2: every feather two nodes, parallel to the first (f1, f2 were notables on one link, spikes)


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


def wheel49(base, stem, H, rho, a0, arm, n=4):
    """"catherine wheel" (w1 2026-11-18, was a star of four straight rays): a hub on a stem from road node `base`, n
    spokes out to a circle rho round the hub at even steps from orbit angle a0, each spoke's node running on round the
    circle by `arm` degrees (an arc round the hub) to a notable: a spinning firework of n arms on one circle."""
    spec = {'s0': (F(*stem), 'small'), 'h': (F(*H), 'small')}
    links = [('s0', 'h')]
    for j in range(n):
        a = a0 + 360 / n * j
        spec[f'a{j}'] = (rho, a, 'small'); spec[f'b{j}'] = (rho, a + arm, 'notable')
        links += [('h', f'a{j}'), (f'a{j}', f'b{j}', 'O')]
    return figure(F(*H), spec, links, [(base, 's0')])


P49 = {'firework': wheel49(1592, (62.9, -30.6), (60.2, -29.6), 1.7, 4, 36, n=5)}   # five arms: no four-armed hooked cross


def torch49():
    """"torch": a handle rising from 1594 along the spoke into a small ring head, two flames curling up and out from
    the head's sides, both notables."""
    O = F(58.4, -24.9)                                   # w1: handle shortened (was four nodes, head at 57.2)
    spec = {'n0': (F(63.0, -24.1), 'small'), 'n1': (F(61.7, -24.6), 'small'), 'n3': (F(60.4, -24.8), 'small'),
            'h0': (0.85, 180, 'small'), 'h1': (0.85, 90, 'small'), 'h2': (0.85, 0, 'small'), 'h3': (0.85, -90, 'small'),
            'fl': (1.9, -32, 'notable'), 'fr': (1.9, 30, 'notable')}
    links = [('n0', 'n1', 0.1), ('n1', 'n3', -0.1), ('n3', 'h0'), ('h0', 'h1', 'O'), ('h1', 'h2', 'O'),
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
# cell 3 (the Fire start cell, 558 units²): big and sparse (3.10 B4). Two flame wings (w1 2026-11-18: each a double arc
# on circles round the start's road node 42, a pair of parentheses round the start; were freehand chains, before that
# Hairpins) from the hub ring, two Spur pairs hanging down the border spokes; mirrored.
# ======================================================================================================================
def wing3(base, sign, rho=8.5, angs=(30, 42, 54, 66, 78, 90, 102, 114, 126, 138), notables=(90, 138),
          inner=(54, 7.0, (54, 69, 84, 99, 114))):
    """A wing of flame (w1 2026-11-18: rebuilt on a circle, was a freehand chain): an arc on the circle rho round the
    start's road node 42, nodes every 12 degrees from beside hub-ring node `base` down the start's side, notables
    mid-way and at the tip; the two wings bracket the start like a pair of parentheses (sign -1 left of the axis,
    +1 right)."""
    O = road(42)
    keys = [f'c{i}' for i in range(len(angs))]
    nodes = {k: (orbit(O, rho, sign * a), 'notable' if a in notables else 'small') for k, a in zip(keys, angs)}
    links = [(keys[i], keys[i + 1], O) for i in range(len(keys) - 1)]
    if inner:                                 # a second, shorter feather row on a smaller circle, one radial link
        at, irho, iangs = inner
        ik = [f'i{i}' for i in range(len(iangs))]
        nodes.update({k: (orbit(O, irho, sign * a), 'notable' if i == len(iangs) - 1 else 'small') for i, (k, a) in enumerate(zip(ik, iangs))})
        links += [(keys[angs.index(at)], ik[0], None)] + [(ik[i], ik[i + 1], O) for i in range(len(ik) - 1)]
    return piece(nodes, links, [(base, keys[0])])


CELLS[3] = {'A_wing': wing3(28, -1), 'B_wing': wing3(30, 1)}   # w1: mirror twins on the axis (a big drawn twice, like the
# rim's đỉnh and trefoils: symmetry on the axis matters more here)
fill_rows(CELLS[3], [
    ('C spur',     314, 'Spur pair', 'bow out', 1.2, 140, 0, False),     # w1: turned down the spoke, clear of the wing
    ('D spur',     237, 'Spur pair', 'bow out', 1.2, -140, 0, True),
])


# ======================================================================================================================
# cell 901 (Fire's rim, beyond r 74.3, th -33..33), rim pass 2026-11-18 night (design/dao-do/cells/rim-brief.md): the
# rim's large figures, replacing the plumes, fire wheel, flame tree and tadpole. On the axis a đỉnh (the alchemy
# cauldron, 2 x 14 nodes) split by the axis road it hangs from (500 <-> 380, the road on to Light is its front leg);
# either side, mid-way between the keystones and the border combos, a "trefoil" of three interlocking rings (28 nodes,
# hung from 1569, the left one its exact mirror off 1559). The two keystones stay as they were.
# ======================================================================================================================
def angof(C, p):
    """Orbit angle of point p round C (the inverse of orbit: 0 = towards the tree centre, + = towards +theta)."""
    i = (-C[0] / math.hypot(*C), -C[1] / math.hypot(*C)); t = (-i[1], i[0])
    dx, dy = p[0] - C[0], p[1] - C[1]
    return math.degrees(math.atan2(dx * t[0] + dy * t[1], dx * i[0] + dy * i[1]))


def on_circle(C, p, q, tol=1e-6):    # an arc link's centre must be equidistant from both ends
    assert abs(math.dist(C, p) - math.dist(C, q)) < tol, (C, p, q)
    return C


def perp_centre(A, B, h, toward):
    """The point h off the midpoint of A-B on its perpendicular, on the side of point `toward` (h < 0: the far side)."""
    m = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2); L_ = math.dist(A, B)
    nx, ny = -(B[1] - A[1]) / L_, (B[0] - A[0]) / L_
    if nx * (toward[0] - m[0]) + ny * (toward[1] - m[1]) < 0:
        nx, ny = -nx, -ny
    return (m[0] + h * nx, m[1] + h * ny)


BAND = [(120, 'small'), (150, 'notable')]          # đỉnh band nodes (orbit angle round 500 at 3.3, kind)
FOOT, LEGBOW, LEGN = (8.6, 152), 0.12, 1           # đỉnh foot (rho, angle round 500), leg lens bow, nodes per side


def ding901():
    """"đỉnh", the alchemy cauldron, right half (the left half is its mirror across the axis road). The belly is a
    semicircle round axis node 500 down to axis node 380 (its bottom; a pass-through 500 <-> 380); the lip runs from
    500 out along the belly's diameter; an ear stands on the lip as a ring round its own centre; a leg drops from the
    belly as a narrow lens to a notable foot. The axis road 380 -> 550 reads as the third (front) leg."""
    O = road(500); R = math.dist(O, road(380))
    n = {}
    n['l1'] = (orbit(O, 1.65, 90), 'small'); n['l2'] = (orbit(O, 3.3, 90), 'small'); n['c'] = (orbit(O, R, 90), 'notable')
    for a in (112.5, 135, 157.5):
        n[f'b{int(a)}'] = (orbit(O, R, a), 'small')
    links = [(500, 'l1', None), ('l1', 'l2', None), ('l2', 'c', None),
             ('c', 'b112', O), ('b112', 'b135', O), ('b135', 'b157', O), ('b157', 380, on_circle(O, n['b157'][0], road(380), 1e-3))]
    # ear: a ring of radius 1.3 standing on the lip segment l2-c
    A, B = n['l2'][0], n['c'][0]; re = 1.3
    h = math.sqrt(re * re - (math.dist(A, B) / 2) ** 2)
    E = perp_centre(A, B, h, (0.0, 0.0))
    a0, a1 = angof(E, A), angof(E, B)
    for k, f, kd in (('e1', 0.25, 'small'), ('e2', 0.5, 'notable'), ('e3', 0.75, 'small')):
        n[k] = (orbit(E, re, a0 + (a1 - a0) * f), kd)
    links += [('l2', 'e1', on_circle(E, A, n['e1'][0])), ('e1', 'e2', E), ('e2', 'e3', E), ('e3', 'c', on_circle(E, n['e3'][0], B))]
    # band: an inner arc round O from l2 under the lip (the cauldron's decorated band), its end a notable
    for a, kd in BAND:
        n[f'i{int(a)}'] = (orbit(O, 3.3, a), kd)
    keys = ['l2'] + [f'i{int(a)}' for a, _ in BAND]
    links += [(keys[j], keys[j + 1], O) for j in range(len(keys) - 1)]
    # leg: a narrow lens from b135 to the foot
    P0 = n['b135'][0]; foot = orbit(O, FOOT[0], FOOT[1])
    n['f'] = (foot, 'notable')
    for tag, bow in (('p', LEGBOW), ('q', -LEGBOW)):
        cc = bow_centre(P0, foot, bow, O)
        fr = [j / (LEGN + 1) for j in range(1, LEGN + 1)]
        ks = ['b135'] + [f'{tag}{j}' for j in range(1, LEGN + 1)] + ['f']
        for j, q in enumerate(along(P0, foot, cc, fr)):
            n[f'{tag}{j + 1}'] = (q, 'small')
        links += [(ks[j], ks[j + 1], cc) for j in range(len(ks) - 1)]
    return n, links


def circles_meet(C1, C2, r):
    """The two crossing points of two circles of radius r round C1 and C2."""
    D = math.dist(C1, C2); h = math.sqrt(r * r - D * D / 4); m = ((C1[0] + C2[0]) / 2, (C1[1] + C2[1]) / 2)
    ux, uy = (C2[0] - C1[0]) / D, (C2[1] - C1[1]) / D
    return (m[0] - h * uy, m[1] + h * ux), (m[0] + h * uy, m[1] - h * ux)


def trefoil901(O, lobes, r, d, lobe_angs, kinds, entry, side_mids=False):
    """"trefoil": three rings of radius r round centres d out from O at orbit angles `lobes`, each pair crossing at two
    shared nodes (an inner one near O, an outer one between the lobes), every link an arc round its own ring's centre;
    a centre node on O with spokes to the three inner crossings. lobe_angs: angles (round each ring's centre, relative
    to its lobe direction) of the nodes on the lobe's outer arc; kinds {key: kind} overrides 'small'. Keys: o (centre),
    in_ij / out_ij (crossings of rings i and j), L<i>_<a> (lobe nodes). entry: [(road id, key)]."""
    Cs = [orbit(O, d, a) for a in lobes]
    nodes = {'o': (O, kinds.get('o', 'small'))}
    on = {i: [] for i in range(3)}                     # (angle round ring i, key) of the nodes on ring i
    for i, j in ((0, 1), (1, 2), (0, 2)):
        P, Q = circles_meet(Cs[i], Cs[j], r)
        pin, pout = (P, Q) if math.dist(P, O) < math.dist(Q, O) else (Q, P)
        for key, pt in ((f'in{i}{j}', pin), (f'out{i}{j}', pout)):
            nodes[key] = (pt, kinds.get(key, 'small'))
            on[i].append((angof(Cs[i], pt), key)); on[j].append((angof(Cs[j], pt), key))
    for i in range(3):
        for a in lobe_angs:
            key = f'L{i}_{a}'
            nodes[key] = (orbit(Cs[i], r, lobes[i] + a), kinds.get(key, 'small'))
            on[i].append((angof(Cs[i], nodes[key][0]), key))
    if side_mids:
        for i in range(3):
            ring = sorted(on[i])
            for (a, ka), (b, kb) in zip(ring, ring[1:] + ring[:1]):
                if {ka[:2], kb[:2]} == {'in', 'ou'}:
                    m = a + ((b - a) % 360) / 2
                    key = f'm{i}_{ka}_{kb}'
                    nodes[key] = (orbit(Cs[i], r, m), kinds.get(key, 'small'))
                    on[i].append((angof(Cs[i], nodes[key][0]), key))
    links = []
    for i in range(3):
        ring = sorted(on[i])
        for (_, a), (_, b) in zip(ring, ring[1:] + ring[:1]):
            links.append((a, b, on_circle(Cs[i], nodes[a][0], nodes[b][0], 1e-6)))
    links += [('o', k, None) for k in ('in01', 'in12', 'in02')]
    return piece(nodes, links, entry)


P901 = {
    'keystone_L': ({'k': ((-16.4666, 77.4693), 'keystone')}, [(1563, 'k', None)]),
    'keystone_R': ({'k': ((16.4666, 77.4693), 'keystone')}, [(1573, 'k', None)]),
    'ding_R': ding901(),
}
P901['ding_L'] = mirror_pieces({'d': P901['ding_R']}, LAND)['d']
TRE = dict(r=3.3, d=2.4, lobe_angs=[-66.4, -33.2, 0, 33.2, 66.4], side_mids=True)
_tO = F(81.6, 22.0); _td = angof(_tO, road(1569))            # the top lobe points at its hang node 1569
P901['trefoil_R'] = trefoil901(_tO, [_td, _td + 120, _td + 240], **TRE,
                               kinds={'o': 'notable', 'L1_0': 'notable', 'L2_0': 'notable', 'out12': 'notable',
                                      'L0_-66.4': 'notable', 'L0_66.4': 'notable', 'L1_-66.4': 'notable', 'L2_66.4': 'notable'},
                               entry=[(1569, 'L0_0')])
P901['trefoil_L'] = mirror_pieces({'t': P901['trefoil_R']}, LAND)['t']
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
          ('d fork', 518, 'Fork', 'bow out', 1.0, 50, 0, True),
          ('d hairpin', 1557, 'Hairpin', 'tight turn', 1.1, 30, 0, False)],   # w2: arches over 101's empty bottom
    105: [('d hook', 1567, 'Hook', 'bow in', 1.0, -50, 0, True)],
    53:  [('d ring', 1560, 'Ring', 'cusped', 1.2, 25, 0, False),     # w3 (hood 53): was a Hairpin, the same arch as
                                                                    # 101's off 1557 and 15's E (three in one hood)
          ('d hook',    1595, 'Hook', 'bow in', 1.0, 140, 0, False)],          # w1: the empty column by the spoke
    # 56 (w1: hook 1568 and crook 1604 removed, clumps): its Diamond off 1606 is set below (w2) as 14's H Diamond mirrored
    63:  [('d fork', 1552, 'Fork', 'bow out', 1.0, -40, 0, False)],      # w2 (18|63): ring 1555 removed (1.38 from the
                                                                       # halo tip; a ring back to back with 18's sun on 1555)
    62:  [('d tadpole', 1547, 'Tadpole', 'round', 1.1, -26, 0, False),
          ('d diamond', 1549, 'Diamond', 'round', 1.0, -40, 0, False)],    # w1: was a Zigzag 1.06 from the corona tip
    92:  [('d ring',    1600, 'Ring', 'cusped', 1.1, 32, 0, False),
          ('d crook',   1583, 'Crook', 'bow out', 1.0, -150, 0, True)],
    47:  [('d fork', 1584, 'Fork', 'bow out', 1.1, 140, 0, False)],
    49:  [('d hook', 1577, 'Hook', 'bow in', 1.0, -160, 0, True)],
    29:  [('d arch',    1543, 'Arch', 'bow out', 1.2, -165, 0, False),
          ('d diamond', 1511, 'Diamond', 'cusped', 1.0, 45, 0, False)],
    18:  [('d hook',    1556, 'Hook', 's-curve', 1.1, -160, 0, False),
          ('d diamond', 1590, 'Diamond', 'cusped', 1.0, -45, 0, False)],     # w1: was a Crook hugging flame_a's base
    37:  [('d diamond', 1583, 'Diamond', 'lop-sided', 1.1, 45, 0, False)],
    70:  [('d crook',   1588, 'Crook', 'bow in', 1.0, 135, -15, True)],
}
for _c, _rows in DENSE_SMALL.items():                    # piece names carry the road node: d_<family>_<road>
    assert not {f'{r[0]} {r[1]}'.replace(' ', '_') for r in _rows} & set(CELLS[_c]), _c
    fill_rows(CELLS[_c], [(f'{r[0]} {r[1]}',) + tuple(r[1:]) for r in _rows])
CELLS[37].update(mirror_pieces({'d_hook_1549': CELLS[18]['d_hook_1556']}, LAND))          # land twins
CELLS[74].update(mirror_pieces({'d_crook_1581': CELLS[70]['d_crook_1588']}, LAND))
CELLS[28].update(mirror_pieces({'d_diamond_1516': CELLS[29]['d_diamond_1511']}, LAND))   # w1: under the wisps
# w2 (14|56, 56|70): 56's Diamond on 1606 was a near twin of 14's H Diamond beside it on the same node (stem 1.1 ang 140 vs
# 1.3 ang 228): now its exact mirror across the 14|56 wall spoke (1606-1571), a split figure on the wall.
CELLS[56]['d_diamond_1606'] = wall_pair({'d': _c14.PIECES['H_diamond']}, 1606, 1571)[1]['d']


# --- pair "ember petals" across the ring r 64.3 at 1593 (cells 49 | 53): a small petal leaning towards 1594, tip
# notable; mirrored, a V of two petals opening along the ring road. -------------------------------------------------------
def petal_pair():
    O, T, S = road(1593), road(1594), F(61.0, -27.0)
    A, B = wpoint(O, T, S, 1.0, 50), wpoint(O, T, S, 2.6, 42)
    nodes, links = lens(A, B, (0.3, 0.3), 2, {'B': 'notable'}, [])
    return nodes, [(1593, 'A', None)] + links


pair('ember_petals', 49, 53, 1593, 1594, petal_pair())


# --- "spark hooks" at 1602 (built as a pair across the ring r 64.3, cells 47 | 105; w2: only 105's half kept, see below):
# a three-node hook curling towards 1603, tip notable. -----------------------------------------------------------------
def hook_pair():
    O, T, S = road(1602), road(1603), F(60.0, 31.0)
    spec = {'a': (1.0, 62, 'small'), 'b': (1.85, 70, 'small'), 'c': (2.6, 86, 'notable')}
    return half(O, T, S, spec, [('a', 'b', 0.12), ('b', 'c', 0.2)], [(1602, 'a')])


pair('spark_hooks', 47, 105, 1602, 1603, hook_pair())
# w2 (47|105): the 47 half removed (it was wedged between the wing's feathers and the eye, 1.33 from a feather, and
# kept the feathers single spikes); 105 keeps its half as a plain hook off 1602.
del CELLS[47]['spark_hooks']
# w2: its answer on the trident's other side, a hook off 1601 curling out towards the spoke (105's empty upper right).
CELLS[105]['w_hook_1601'] = half(road(1601), road(1517), F(67.0, 35.0),
                                 {'a': (1.0, 82, 'small'), 'b': (1.95, 72, 'small'), 'c': (2.75, 56, 'notable')},
                                 [('a', 'b', 0.12), ('b', 'c', 0.2)], [(1601, 'a')])

# --- second round of small pieces -------------------------------------------------------------------------------------
DENSE_SMALL_2 = {
    # w2 (56|rim): 56's d fork off 1569 removed (1569 carried taiji_b, the fork and the rim trefoil; three sticks in a row
    # along the bottom wall with the two Crooks)
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
# w1: the second 1541 spark pair (b, 63 | 3) removed: 1541 was busy and its tip sat 1.27 from the corona's end.
_m = mirror_pieces({'wall_spark_a1535': CELLS[63]['wall_spark_a1541']}, LAND)
pair('wall_spark_a1535', 62, 3, 1535, 1536, _m['wall_spark_a1535'])
# w1: the second 1535 spark pair (c, 62 | 3) removed: 1535 carried the corona, two spark pairs and three roads.

DENSE_SMALL_3 = {
    47:  [],
}
for _c, _rows in DENSE_SMALL_3.items():
    assert not {f'{r[0]} {r[1]}'.replace(' ', '_') for r in _rows} & set(CELLS[_c]), _c
    fill_rows(CELLS[_c], [(f'{r[0]} {r[1]}',) + tuple(r[1:]) for r in _rows])

# --- w1 (2026-11-18): a flame lens in 62's empty corner by 1545 (where a crowding hook was), on a short stem -------------
def lens62():
    nodes, links = lens(F(40.0, -21.4), F(38.2, -21.1), (0.3, 0.3), 1, {'B': 'notable'}, [])
    nodes['s0'] = (F(40.85, -22.0), 'small')
    return nodes, [(1545, 's0', None), ('s0', 'A', None)] + links


CELLS[62]['w_lens_1545'] = lens62()


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

# (w1 2026-11-18: the pupils the density pass gave the 1555 and 1600 rings were dropped: each touched its ring's notable.)

# hearth flame_a (18, mirrored in 37) runs on two nodes down beside the axis hex.
_fa = CELLS[18]['flame_a']
CELLS[18]['flame_a'] = ({**_fa[0], 'c2': (_fa[0]['c2'][0], 'small'), 'c3': (F(48.9, 5.0), 'small'), 'c4': (F(47.6, 4.6), 'notable')},
                        _fa[1] + [('c2', 'c3', bow_centre(_fa[0]['c2'][0], F(48.9, 5.0), 0.18, F(50.0, 6.0))),
                                  ('c3', 'c4', bow_centre(F(48.9, 5.0), F(47.6, 4.6), -0.18, F(50.0, 6.0)))])
CELLS[37].update(mirror_pieces({'flame_a': CELLS[18]['flame_a']}, LAND))

# ember corona (63, mirrored in 62): the arc doubles its nodes (one every 11 degrees round its centre).
CELLS[63]['corona'] = corona(1541, F(31.4, 14.0), 5.2, [136 + 11 * i for i in range(9)], 7.4, [2, 6])
CELLS[62]['corona'] = mirror_pieces({'corona': CELLS[63]['corona']}, LAND)['corona']


# ======================================================================================================================
# w3 (2026-11-19): neighbourhood windows (a cell and all its wall neighbours judged as one picture)
# ======================================================================================================================
# hood 105 (47 56 105, Earth 40 104, the rim and the 911 crater): the trident was ringed by four three-node sticks
# (hooks 1602, 1601, 1567, Crook 506) with its left middle open. The 1602 and 1567 hooks go; the trident grows an outer
# orbit arc round its own centre on that open side, hung from 1602 at its top end (cell 14's language, one side only).
def orbit105(U=(68.9, 33.0), rho=3.7, angs=(-40, -62, -84, -106, -128, -150), notables=(-84, -150)):
    spec = {f'a{i}': (rho, a, 'notable' if a in notables else 'small') for i, a in enumerate(angs)}
    links = [(f'a{i}', f'a{i + 1}', 'O') for i in range(len(angs) - 1)]
    return figure(F(*U), spec, links, [(1602, 'a0')])


del CELLS[105]['spark_hooks'], CELLS[105]['d_hook_1567']
CELLS[105]['w_orbit'] = orbit105()
fill_rows(CELLS[105], [('w diamond', 1568, 'Diamond', 'round', 1.1, 45, 0, False)])   # the emptied bottom-left corner: a small ember
# hood 56 (14 47 70 105, the rim): 56's w2 orbit arc off 1944 read as a stick glued along the 1944-1568 wall (the spiral's
# inner turns are 1.4 inside it), and it now stood beside 105's new orbit arc: removed. The 1568 ember is mirrored into
# 56 across that wall, a split figure on the wall foot (as 56's 1606 Diamond is with 14's across the other wall).
del CELLS[56]['orbit']
CELLS[56]['w_diamond_1568'] = wall_pair({'d': CELLS[105]['w_diamond']}, 1944, 1568)[1]['d']
# hood 63 (3 18 28 37 62 120): 63's open patch under the halo tip (w2: the 1555 ring removed, every small piece tried at
# 1554/1555 crammed the corona tip or the ember) is where 62 holds its round Diamond off 1549: that Diamond mirrored
# into 63 (on 1556), so the halo pair stands between two land twins again.
CELLS[63].update(mirror_pieces({'d_diamond_1556': CELLS[62]['d_diamond_1549']}, LAND))
# hood 70 (14 18 28 47 56 93): 70's w2 lantern (a curled-stalk Tadpole on a 2.0 stem from 1586) stood its ring head 3
# units from 47's loop flame ring across the 1586-1604 spoke (two ring-on-a-stalk figures side by side) and was 70's
# second Tadpole. Now a flame lens on a stem from 1586 (two arcs to a notable tip, as 62's lens by 1545), hanging point
# down into 70's upper right: it answers 28's sunrise lens standing on 1586 above the ring. (Catalogue pieces tried
# first: a Spur pair and two Crescents passed but read as sticks; Arch, Fork closed, Zigzag failed.)
def lens70():
    nodes, links = lens(F(56.1, 21.9), F(58.2, 20.9), (0.3, 0.3), 1, {'B': 'notable'}, [])
    nodes['s0'] = (F(54.9, 22.2), 'small')
    return nodes, [(1586, 's0', None), ('s0', 'A', None)] + links


del CELLS[70]['B_lantern']
CELLS[70]['w_lens_1586'] = lens70()


# ======================================================================================================================
# w4 (2026-11-19): region windows (a cell, its neighbours and theirs; six regions), judged for composition
# ======================================================================================================================
# region E/C (47 by the Earth border): 47's phoenix eye (a closed ring of six) stood in a row with the border's wall
# hexagon (base map) and Earth 40's square keep: three polygon loops side by side. The eye opens into a half ring on
# the same circle (rho 1.3, 36-degree steps from its 1602 entry round the wing side to the inner node), its mouth towards
# the hexagon and the keep, the pupil (the only notable, as before) hanging inside from the inner node. (First tried
# ending the arc at 45 deg in a notable: 1.20 from the hexagon's notable 1463.)
def eye47_w4(rho=1.3, angs=(180, 216, 252, 288, 324, 0)):
    O = F(62.2, 33.1)
    spec = {f'r{a}': (rho, a, 'small') for a in angs}
    spec['p'] = (0.0, 0, 'notable')
    links = [(f'r{a}', f'r{b}', 'O') for a, b in zip(angs, angs[1:])] + [('r0', 'p')]
    return figure(O, spec, links, [(1602, 'r180')])


CELLS[47]['eye'] = eye47_w4()
# region E/F (56 | 105 at the 1568 wall foot): the outer band ran six closed loops in a row (14's H Diamond, 56's two
# Diamonds round the two taiji spirals, 105's Diamond). The 1568 Diamond pair becomes a V of two flame petals opening up
# the 1944-1568 wall (the ember petals' language, as at 1593 between 49 | 53), 105's half drawn, 56's its wall mirror.
def petals1568():
    O, T, S = road(1568), road(1944), F(73.0, 30.0)
    A, B = wpoint(O, T, S, 1.0, 48), wpoint(O, T, S, 2.5, 38)       # shorter and slimmer than 1593's (one node a side)
    nodes, links = lens(A, B, (0.32, 0.32), 1, {'B': 'notable'}, [])
    return nodes, [(1568, 'A', None)] + links


del CELLS[105]['w_diamond'], CELLS[56]['w_diamond_1568']
pair('w_petals_1568', 105, 56, 1568, 1944, petals1568())
# region E (56's bottom wall): the two Crooks (1571 bow out, 1570 bow in) looked alike, beside 14's J Crook on 1571; 56's
# C Crook stays as the wall answer to 14's, the 1570 one changes family.
del CELLS[56]['D_crook']
fill_rows(CELLS[56], [('w hairpin', 1570, 'Hairpin', 'tight turn', 1.0, 50, 0, False)])   # a lick curling over towards
# taiji_b (named at 1570: Hairpin tight turn/bow out, Hook s-curve x3, Hook bow out, Arch bow out, Crescent x2, Zigzag
# wave; the Hook s-curve ang 40 and Hook bow out passed too but read as a second stick beside the C Crook)
# region D (49 101 53 74 15): 49's catherine wheel (five spokes) and 101's spark star (five points) stood about 6 apart,
# two five-fold radial figures in one corner. The wheel turns into a three-armed whorl on the same hub and circle: three
# spokes at 120-degree steps, each running on round the circle through a middle node to a notable 80 degrees on.
def whorl49(base=1592, stem=(62.9, -30.6), H=(60.2, -29.6), rho=1.7, a0=-18, arm=(40, 80), n=3):
    spec = {'s0': (F(*stem), 'small'), 'h': (F(*H), 'small')}
    links = [('s0', 'h')]
    for j in range(n):
        a = a0 + 360 / n * j
        spec[f'a{j}'] = (rho, a, 'small'); spec[f'm{j}'] = (rho, a + arm[0], 'small'); spec[f'b{j}'] = (rho, a + arm[1], 'notable')
        links += [('h', f'a{j}'), (f'a{j}', f'm{j}', 'O'), (f'm{j}', f'b{j}', 'O')]
    return figure(F(*H), spec, links, [(base, 's0')])


CELLS[49]['firework'] = whorl49()
# region D/F: 53's cusped ring off 1560 was a second closed loop on the fireball's node, in an outer band that runs ring
# after ring (split ring, fireball head, 15's rings): now a flame lick (a Zigzag wave) flying off beside the fireball's
# tail (named at 1560: Crescent bow out/in, Hook s-curve, Zigzag wave, Arch bow out, Fork bow out, all passed; the
# Crescents echoed the tail's curve, the Hook would be 53's second, the Arch and Fork read as sticks).
del CELLS[53]['d_ring_1560']
fill_rows(CELLS[53], [('w zigzag', 1560, 'Zigzag', 'wave', 1.2, 25, 0, False)])
# region A/C (120 with 119, 3, 63, 28, Earth 2 24 117): 120's comet tails were two concentric arcs 1.16 apart and of
# equal length (two long parallel lines). Each tail now runs on its own circle (bulging outward a little, as before),
# the inner one dipping in to its 1514 hang, the outer one lifting out and ending shorter: the tail splays from 1.2 at
# the head to about 2.5 at the ends.
def comet120_w4(t1_end=(38.0, 34.6), t2_end=(40.5, 33.9), bow=0.04):
    nodes, links = comet120()
    links = [ln for ln in links if not (str(ln[0]).startswith('t') or str(ln[1]).startswith('t'))]
    for tag, start, end, kd in (('t1', 'rb', t1_end, 'small'), ('t2', 'rr', t2_end, 'notable')):
        A, B = nodes[start][0], F(*end)
        c = bow_centre(A, B, bow, (0.0, 0.0))
        p1, p2 = along(A, B, c, [1 / 3, 2 / 3])
        nodes[f'{tag}b'] = (p1, 'small'); nodes[f'{tag}c'] = (p2, 'small'); nodes[f'{tag}a'] = (B, kd)
        links += [(start, f'{tag}b', c), (f'{tag}b', f'{tag}c', c), (f'{tag}c', f'{tag}a', c)]
    links.append((1514, 't1a', None))
    return nodes, links


CELLS[120]['comet'] = comet120_w4()

# --- w5 (2026-11-19, the whole land as one picture): the small fill Diamond was stamped over the land (eight of them
# beside the flame lily's six Diamond petals and locked 14/15's H Diamonds), tiny rhombi sprinkled evenly, the 28/29 pair
# on the Earth/Wood seams beside Earth's polygons. Mirrored fill pairs swapped for other families (one family per pair),
# so the lily keeps the Diamond motif. Rows: (cell, old piece, twin cell or None, old twin piece, new row).
# 62/63: the round Diamonds beside the halo/corona -> a Hairpin 'tight turn' curling up and away from the corona, a flame
# lick that runs on through the road node into 37's/18's hook below it (named at 1549: Hairpin tight turn ang -40 hand
# False / True, Hook s-curve, Tadpole curled stalk, Zigzag wave; only the hand-True Hairpin passed, notable 1.94 from the
# corona).
# 28/29: 28's cusped Diamond on 1516 stood right under Earth 24's cusped four-point star across the 36-deg spoke (a
# look-alike on the seam). No other family fits the pocket by the border spokes (36 named rows, 24 as twins and 12 for
# 28 alone: Zigzag wave, Hairpin tight turn / bow out, Hook s-curve / bow in, Spur pair, Tadpole curled stalk / kite,
# several angles, stems 0.8-1.0), so the twins keep the Diamond on the same stem and angle in its 'round' style: a small
# round ember bead, no longer a second cusped star (named: round, lop-sided; both passed, round chosen by eye).
# Tried and left: 18/37 (a Hairpin passed but its notable 1.38 from the axis hex; the passing Tadpole is a loop again),
# 101 (1592, five rows, none pass).
W5_SWAPS = [(62, 'd_diamond_1549', 63, 'd_diamond_1556',
             ('w5 hairpin 1549', 1549, 'Hairpin', 'tight turn', 1.0, -40, 0, True)),
            (29, 'd_diamond_1511', 28, 'd_diamond_1516',
             ('w5 diamond 1511', 1511, 'Diamond', 'round', 1.0, 45, 0, False))]
for _c, _old, _tc, _told, _row in W5_SWAPS:
    del CELLS[_c][_old]
    fill_rows(CELLS[_c], [tuple(_row)])
    if _tc is None:                                       # a single piece, no land twin
        continue
    del CELLS[_tc][_told]
    _nm = _row[0].replace(' ', '_')
    _tw = mirror_pieces({_nm: CELLS[_c][_nm]}, LAND)[_nm]
    CELLS[_tc]['_'.join(_nm.split('_')[:-1] + [str(next(x for ln in _tw[1] for x in ln[:2] if isinstance(x, int)))])] = _tw

# ======================================================================================================================
# trial rows for the sweep (never part of the design)
# ======================================================================================================================
_extra = json.loads(os.environ.get('FIRE_EXTRA') or '{}')
if _extra:
    CELLS.setdefault(_extra['cell'], {})
    fill_rows(CELLS[_extra['cell']], [tuple(r) for r in _extra['rows']])


# Hub cell 83 belongs to Chaos (swirls into the centre, user 2026-11-18): drawn in design/dao-do/cells/chaos.py.
CELLS[83] = {}

# 2026-11-19 (user: "Keystones should connect directly to the travel nodes like in PoE"): the keystones here were
# folded onto their roads: each now sits where its dead-end spur node was (1945, 1946, removed from base-map.json)
# and links straight to the road node the spur hung from.
# 2026-11-19 (user: "add more" keystones, straight off the travel nodes like in PoE): a second pair on the rim at theta
# +-28.1, each linked straight to its ring node (1568 and its mirror 1558), clear of everything round it (1.6+).
CELLS[901]['keystone_rim_R'] = ({'k': ((36.232, 67.941), 'keystone')}, [(1568, 'k', None)])
CELLS[901]['keystone_rim_L'] = ({'k': ((-36.232, 67.941), 'keystone')}, [(1558, 'k', None)])
