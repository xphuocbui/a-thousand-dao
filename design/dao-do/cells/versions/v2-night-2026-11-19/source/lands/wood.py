"""Wood land (axis 288), filled cell by cell by hand (Wood fork, 2026-11-18). Character: branches, leaves, vines.
Every number below is chosen by hand; the helpers only turn those choices into points and arc centres.
Land-local coordinates: L(r, th) with th degrees from the Wood axis; ang 0 = towards the tree centre, + = towards +th.

Multi-cell combos:
  A "four-leaf clover": four leaf lenses from junction 1505 (axis x ring 64.3), one in each of cells 94, 88, 12, 13.
  B "split seed": two half-rings facing each other round road node 1902 (ring 53.9), upper half in 35, lower in 94.
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from celllib import L as _L, road, direction, fill_rows, mirror_pieces, bow_centre

THEME = 'wood'
W = 'wood'


def Lp(r, th):
    return _L(r, th, W)


def at(p, ang, u, v=0.0):
    """The point u units along direction `ang` from p and v units to its +90 side (frame taken at p)."""
    U = direction(p, ang); V = direction(p, ang + 90)
    return (p[0] + u * U[0] + v * V[0], p[1] + u * U[1] + v * V[1])


def circ(a, b, c):
    """Centre of the circle through three points (for arc links)."""
    ax, ay = a; bx, by = b; cx, cy = c
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return (ux, uy)


def ring_pt(O, rho, ang, base):
    """A point on a circle round O, angle measured in the frame of point `base` (so a figure keeps one frame)."""
    U = direction(base, ang)
    return (O[0] + rho * U[0], O[1] + rho * U[1])


def leaf(rid, ang, stem, length, width):
    """A leaf lens: stem node S, one node each side, a notable tip; both sides are arcs."""
    p = road(rid)
    S = at(p, ang, stem); A = at(p, ang, stem + 0.48 * length, width / 2); B = at(p, ang, stem + 0.48 * length, -width / 2)
    T = at(p, ang, stem + length)
    ca, cb = circ(S, A, T), circ(S, B, T)
    return ({'s': (S, 'small'), 'a': (A, 'small'), 'b': (B, 'small'), 't': (T, 'notable')},
            [(rid, 's', None), ('s', 'a', ca), ('a', 't', ca), ('s', 'b', cb), ('b', 't', cb)])


def tree(rid, ang, k=1.0, R2=2.45, up=(95,)):
    """Trunk of two nodes, a round canopy ring sitting on it (notable on top) and, round the same centre, a bough on an
    outer orbit each side: a spoke out from the canopy's side node, then an arc rising round the crown to a notable.
    (Window-1 pass 2026-11-19: the boughs replace two straight notable twigs.)"""
    p = road(rid)
    t1 = at(p, ang, 1.3 * k)
    Cc = at(p, ang, 4.2 * k); rho = 1.5 * k
    ring = {b: ring_pt(Cc, rho, ang + b, p) for b in (180, 240, 300, 0, 60, 120)}     # 180 = bottom (trunk top)
    nodes = {'t1': (t1, 'small'), 'c180': (ring[180], 'small'), 'c240': (ring[240], 'small'), 'c300': (ring[300], 'small'),
             'c0': (ring[0], 'notable'), 'c60': (ring[60], 'small'), 'c120': (ring[120], 'small')}
    links = [(rid, 't1', None), ('t1', 'c180', None)]
    order = (180, 240, 300, 0, 60, 120, 180)
    links += [(f'c{order[i]}', f'c{order[i + 1]}', Cc) for i in range(6)]
    for sg, base in ((1, 120), (-1, 240)):
        keys = [f'o{base}'] + [f'o{base}_{i}' for i in range(len(up))]
        angs = [base] + [sg * a % 360 for a in up]
        for i, (kk, a) in enumerate(zip(keys, angs)):
            nodes[kk] = (ring_pt(Cc, R2 * k, ang + a, p), 'notable' if i == len(up) else 'small')
        links += [(f'c{base}', keys[0], None)] + arcs(keys, Cc)
    return nodes, links


def half_ring(rid, ang, rho, angs, notable_ends=True):
    """Part of a circle centred ON road node rid: entry node at `ang` (stem = rho), arc nodes at ang + each offset."""
    p = road(rid)
    pts = {o: ring_pt(p, rho, ang + o, p) for o in angs}
    lo, hi = min(angs), max(angs)
    nodes = {f'h{o}': (xy, 'notable' if notable_ends and o in (lo, hi) else 'small') for o, xy in pts.items()}
    srt = sorted(angs)
    links = [(rid, 'h0', None)] + [(f'h{srt[i]}', f'h{srt[i + 1]}', p) for i in range(len(srt) - 1)]
    return nodes, links


def spiral(rid, ang, O_u, O_v, r0, r1, a0, steps, step):
    """A fiddlehead: entry from road node rid onto a spiral round O (given in rid's frame by u, v), radius shrinking
    from r0 to r1 over `steps` nodes `step` degrees apart, starting at angle a0; the last node is a notable."""
    p = road(rid)
    O = at(p, ang, O_u, O_v)
    nodes, keys = {}, []
    for i in range(steps):
        rr = r0 + (r1 - r0) * i / (steps - 1)
        xy = ring_pt(O, rr, a0 + step * i, p)
        k = f'f{i}'; keys.append(k)
        nodes[k] = (xy, 'notable' if i == steps - 1 else 'small')
    links = [(rid, keys[0], None)]
    for i in range(steps - 1):
        a, b = nodes[keys[i]][0], nodes[keys[i + 1]][0]
        mid = ring_pt(O, (r0 + (r1 - r0) * (i + 0.5) / (steps - 1)), a0 + step * (i + 0.5), p)
        links.append((keys[i], keys[i + 1], circ(a, mid, b)))
    return nodes, links


def shoots(rid, ang, n, step, bend, sides, shoot_len=1.0, shoot_ang=70, curl=None):
    """A vine: a stem of n nodes leaving road node rid along `ang`, turning `bend` degrees per step (`step` apart), the
    last a notable; at the stem nodes listed in `sides` ({index: +1 or -1}) a two-node shoot (small, then a notable).
    With `curl` (degrees) each shoot is one arc through its stem node, curling that much back towards the stem's line
    (window-1 pass 2026-11-19: curled tendrils instead of bent sticks)."""
    if curl is not None:
        nodes, links = shoots(rid, ang, n, step, bend, {}, shoot_len, shoot_ang)
        p = road(rid); a, cur = ang, p
        for i in range(n):
            cur = at(cur, a, step) if i else at(p, ang, step)
            if i in sides:
                sg = sides[i]
                u = at(cur, a + sg * shoot_ang, shoot_len); v = at(cur, a + sg * (shoot_ang - curl), 2 * shoot_len)
                cc = circ(cur, u, v)
                nodes[f'b{i}'] = (u, 'small'); nodes[f'l{i}'] = (v, 'notable')
                links += [(f's{i}', f'b{i}', cc), (f'b{i}', f'l{i}', cc)]
            a += bend
        return nodes, links
    p = road(rid)
    pts, a, cur = [], ang, p
    for i in range(n):
        cur = at(cur, a, step) if i else at(p, ang, step)
        pts.append((cur, a)); a += bend
    nodes = {f's{i}': (xy, 'notable' if i == n - 1 else 'small') for i, (xy, _) in enumerate(pts)}
    links = [(rid, 's0', None)] + [(f's{i}', f's{i + 1}', None) for i in range(n - 1)]
    for i, sg in sides.items():
        xy, a = pts[i]
        u = at(xy, a + sg * shoot_ang, shoot_len); v = at(xy, a + sg * (shoot_ang - 15), 2 * shoot_len)
        nodes[f'b{i}'] = (u, 'small'); nodes[f'l{i}'] = (v, 'notable')
        links += [(f's{i}', f'b{i}', None), (f'b{i}', f'l{i}', None)]
    return nodes, links


def smoothed(piece, rid):
    """A shoots() stem drawn as one bending curve (window-1 pass 2026-11-19): each stem link becomes the arc through it and
    the stem node before it (the first through the road node and the next two), so a bent stem reads as a branch."""
    nodes, links = piece
    pts = [road(rid)] + [nodes[f's{i}'][0] for i in range(sum(1 for k in nodes if k[0] == 's' and k[1:].isdigit()))]
    keys = [rid] + [f's{i}' for i in range(len(pts) - 1)]
    out = []
    for a, b, c in links:
        if a in keys and b in keys and c is None and keys.index(b) == keys.index(a) + 1:
            i = keys.index(a)
            c = circ(pts[0], pts[1], pts[2]) if i == 0 else circ(pts[i - 1], pts[i], pts[i + 1])
        out.append((a, b, c))
    return nodes, out


def branching(rid, ang, trunk, l1, l2, spread1, spread2, bow=0.0):
    """A binary tree: `trunk` nodes, a fork into two boughs (l1 long, +-spread1 degrees), each forking again into two
    twigs (l2 long, +-spread2) ending in notables. With `bow` the boughs and twigs are arcs bulging away from the trunk
    below the fork (window-1 pass 2026-11-19: was straight sticks), so it grows rather than ticks."""
    p = road(rid)
    nodes, links, cur = {}, [], p
    prev = rid
    for i in range(trunk):
        cur = at(p, ang, 1.3 * (i + 1)); nodes[f't{i}'] = (cur, 'small'); links.append((prev, f't{i}', None)); prev = f't{i}'
    ref = at(cur, ang, -2.0)
    bw = lambda q, r: bow_centre(q, r, bow, ref) if bow else None
    for sg in (-1, 1):
        b = at(cur, ang + sg * spread1, l1); kb = f'b{sg:+d}'
        nodes[kb] = (b, 'small'); links.append((prev, kb, bw(cur, b)))
        for sg2 in (-1, 1):
            tw = at(b, ang + sg * spread1 + sg2 * spread2, l2); kt = f'w{sg:+d}{sg2:+d}'
            nodes[kt] = (tw, 'notable'); links.append((kb, kt, bw(b, tw)))
    return nodes, links


def big_leaf(rid, ang, stem, length, width):
    """A big leaf with a midrib: stem node S, two nodes on each curved side, a notable tip, and a midrib of two nodes
    from S to the tip inside the outline (one cluster, three routes from S to the tip)."""
    p = road(rid)
    S = at(p, ang, stem); T = at(p, ang, stem + length)
    A1 = at(p, ang, stem + 0.3 * length, 0.42 * width); A2 = at(p, ang, stem + 0.68 * length, 0.4 * width)
    B1 = at(p, ang, stem + 0.3 * length, -0.42 * width); B2 = at(p, ang, stem + 0.68 * length, -0.4 * width)
    M1 = at(p, ang, stem + 0.36 * length); M2 = at(p, ang, stem + 0.7 * length)
    nodes = {'s': (S, 'small'), 'a1': (A1, 'small'), 'a2': (A2, 'notable'), 'b1': (B1, 'small'), 'b2': (B2, 'notable'),
             'm1': (M1, 'small'), 'm2': (M2, 'small'), 't': (T, 'notable')}
    ca = circ(S, A1, A2); cb = circ(S, B1, B2)
    links = [(rid, 's', None), ('s', 'a1', ca), ('a1', 'a2', ca), ('a2', 't', circ(A1, A2, T)),
             ('s', 'b1', cb), ('b1', 'b2', cb), ('b2', 't', circ(B1, B2, T)), ('s', 'm1', None), ('m1', 'm2', None), ('m2', 't', None)]
    return nodes, links


def seedling(rid, ang, k=1.0):
    """A seedling: a two-node stem and two cotyledon leaves (lenses) opening from its top node, notables at the tips."""
    p = road(rid)
    s1 = at(p, ang, 1.1 * k); s2 = at(p, ang, 2.2 * k)
    nodes = {'s1': (s1, 'small'), 's2': (s2, 'small')}
    links = [(rid, 's1', None), ('s1', 's2', None)]
    for sg, tag in ((1, 'L'), (-1, 'R')):
        a = ang + sg * 48
        T = at(s2, a, 2.2 * k); A = at(s2, a, 1.05 * k, 0.55 * k); B = at(s2, a, 1.05 * k, -0.55 * k)
        nodes.update({f'{tag}a': (A, 'small'), f'{tag}b': (B, 'small'), f'{tag}t': (T, 'notable')})
        ca, cb = circ(s2, A, T), circ(s2, B, T)
        links += [('s2', f'{tag}a', ca), (f'{tag}a', f'{tag}t', ca), ('s2', f'{tag}b', cb), (f'{tag}b', f'{tag}t', cb)]
    return nodes, links


def cloud(rid, ang, stem, rho, steps=4, sweep=62):
    """A cloud scroll (the xianxia cloud motif, for Wind): one entry node, two arms curling apart from it round two
    centres set either side of the stem line, each arm shrinking as it curls, a notable at each arm's end."""
    p = road(rid)
    E = at(p, ang, stem)
    nodes = {'e': (E, 'small')}
    links = [(rid, 'e', None)]
    for sg, tag in ((1, 'a'), (-1, 'b')):
        O = at(E, ang + sg * 90, rho)                       # arm centre beside the entry node
        start = ang - sg * 90                               # E seen from O
        prev, prev_xy = 'e', E
        for k in range(1, steps + 1):
            rr = rho * (1 - 0.13 * k)
            xy = ring_pt(O, rr, start + sg * sweep * k, E)
            key = f'{tag}{k}'
            nodes[key] = (xy, 'notable' if k == steps else 'small')
            mid = ring_pt(O, rho * (1 - 0.13 * (k - 0.5)), start + sg * sweep * (k - 0.5), E)
            links.append((prev, key, circ(prev_xy, mid, xy)))
            prev, prev_xy = key, xy
    return nodes, links


def pol(O, rho, ang):
    """A point rho from centre O at angle `ang` in O's own frame (0 = towards the tree centre, + = towards +theta)."""
    return ring_pt(O, rho, ang, O)


def arc_between(S, T, C, n):
    """n points evenly spaced on the circle round C between S and T (the shorter way)."""
    a0 = math.atan2(S[1] - C[1], S[0] - C[0]); a1 = math.atan2(T[1] - C[1], T[0] - C[0])
    d = (a1 - a0 + math.pi) % (2 * math.pi) - math.pi; R = math.dist(S, C)
    return [(C[0] + R * math.cos(a0 + d * k / (n + 1)), C[1] + R * math.sin(a0 + d * k / (n + 1))) for k in range(1, n + 1)]


def arcs(keys, O):
    """Arc links round centre O joining consecutive node keys (each under 180 degrees)."""
    return [(keys[i], keys[i + 1], O) for i in range(len(keys) - 1)]


CELLS = {}

# ======================= cell 13: outer band, theta 0..17 =============================================================
# Centre: a tree rising from bottom-ring node 1860 (theta 8) - trunk, round canopy, a twig each side.
# Combo A: the leaf of the four-leaf clover in this quadrant (from 1505, outward and +theta).
# Big figure "maple leaf" (consolidation: replaces a Zigzag at 1928, a Crescent at 1927 and a Hook at 1926): from top
# node 1927 a stem to a hub; five veins fan out to an outline arc round the hub, the three main veins jointed, notables
# at the three main lobes.
H13 = at(road(1927), 180, 2.0)
_m13 = {'s1': (at(road(1927), 180, 1.0), 'small'), 'h': (H13, 'small')}
_m13.update({f'a{a}': (pol(H13, 2.2, 180 + a), 'notable' if a in (-80, 0, 80) else 'small') for a in (-80, -40, 0, 40, 80)})
_m13.update({f'v{a}': (pol(H13, 1.1, 180 + a), 'small') for a in (-80, 0, 80)})
_ml = [(1927, 's1', None), ('s1', 'h', None), ('h', 'a-40', None), ('h', 'a40', None)]
_ml += [x for a in (-80, 0, 80) for x in (('h', f'v{a}', None), (f'v{a}', f'a{a}', None))]
_ml += arcs(['a-80', 'a-40', 'a0', 'a40', 'a80'], H13)
# Medium figure "acorn" (consolidation: replaces a Fork at 1858 and a Hook at 1859): from bottom node 1858 a stem to a
# cap (an arc of five round O, bowed towards the stem, its ends notables) and a pointed nut closing on a notable tip.
O13 = at(road(1858), 0, 3.0)
_a13 = {'s1': (at(road(1858), 0, 0.9), 'small'), 'T': (pol(O13, 1.45, 0), 'notable')}
_a13.update({f'c{a}': (pol(O13, 1.2, a), 'notable' if a in (90, 270) else 'small') for a in (90, 135, 180, 225, 270)})
_al = [(1858, 's1', None), ('s1', 'c180', None)] + arcs(['c90', 'c135', 'c180', 'c225', 'c270'], O13)
for a, m in ((90, 45), (270, 315)):
    cc = circ(_a13[f'c{a}'][0], pol(O13, 1.12, m), _a13['T'][0]); _al.append((f'c{a}', 'T', cc))
c13 = {'tree': tree(1860, 0, 1.3), 'cloverA13': leaf(1505, 135, 1.0, 3.0, 1.5), 'maple': (_m13, _ml), 'acorn': (_a13, _al)}
fill_rows(c13, [
    ('13 crook',   1862, 'Crook', 'swept', 1.2, 20, 0, True),
    ('13 ring',    1506, 'Ring', 'round', 1.3, 100, 0, False),
    ('13 seed',    1930, 'Tadpole', 'round', 1.0, 150, 0, False),
    ('13 diamond', 1861, 'Diamond', 'round', 1.0, -20, 0, False),
])
CELLS[13] = c13

# ======================= cell 12: mirror of 13 (PoE 2 mirrors about half), one piece changed =========================
c12 = mirror_pieces({k: v for k, v in c13.items() if k != '13_seed'}, W)
fill_rows(c12, [('12 crescent', 1920, 'Crescent', 'bow in', 1.0, -158, 0, False)])
CELLS[12] = c12

# ======================= cell 94: middle band, theta -11..0 ===========================================================
# Combo A leaf (from 1505, inward and -theta); combo B lower half: a half-ring centred on 1902, outward side.
c94 = {'cloverA94': leaf(1505, -45, 1.0, 3.0, 1.5), 'seedB_low': half_ring(1902, 180, 2.0, (-60, -30, 0, 30, 60))}
fill_rows(c94, [
])
CELLS[94] = c94

# ======================= cell 88: middle band, theta 0..11 ============================================================
# Centre: a fiddlehead (fern curl) from top node 1909, curling round towards the axis. Combo A leaf from 1505.
# Big figure "tulip" (consolidation: replaces a Crescent at 1930, a Diamond at 1929 and a Hairpin at 2002): from bottom
# node 1929 a stem rises to a cup (an arc of five round O, its rims notables) holding a pistil notable; a leaf blade
# rises off the stem towards +theta on the stem node's own orbit round O (window-1 pass: was a leaf lens).
O88 = Lp(60.4, 6.0)
_s1 = Lp(63.4, 6.0)
_t88 = {'s1': (_s1, 'small'), 'p': (Lp(61.65, 6.0), 'small'), 'P': (Lp(60.9, 6.0), 'notable')}
T88_BLADE = (152, 128)                                          # w1: a leaf blade on the stem node's own orbit round O
_t88.update({f'l{a}': (pol(O88, 3.0, a), 'notable' if a == T88_BLADE[-1] else 'small') for a in T88_BLADE})
_t88.update({f'c{a}': (pol(O88, 2.0, a), 'notable' if a in (100, 260) else 'small') for a in (100, 140, 180, 220, 260)})
_tl = [(1929, 's1', None), ('s1', 'c180', None), ('c180', 'p', None), ('p', 'P', None)]
_tl += arcs(['c100', 'c140', 'c180', 'c220', 'c260'], O88)
_tl += arcs(['s1'] + [f'l{a}' for a in T88_BLADE], O88)
# Medium figure "bud" (consolidation: grown from the Crook at 1910; its mirror twin in 94 replaces a Fork at 1903 and a
# Crook at 1504): from top node 1910 a stem to a round bud (a ring of four) and a shoot from the bud's far side.
C88 = Lp(56.4, 2.5)
_bd = {'s1': (Lp(54.8, 3.05), 'small'), 'u': (pol(C88, 1.7, 180), 'small'), 'n': (pol(C88, 2.6, 180), 'notable')}
_bd.update({f'r{a}': (pol(C88, 0.8, a), 'small') for a in (0, 90, 180, 270)})
c88 = {'tulip': (_t88, _tl),
       'bud': (_bd, [(1910, 's1', None), ('s1', 'r0', None), ('r180', 'u', None), ('u', 'n', None)] +
               [(f'r{a}', f'r{(a + 90) % 360}', C88) for a in (0, 90, 180, 270)]),
       'cloverA88': leaf(1505, 45, 1.0, 3.0, 1.5), 'fiddlehead': spiral(1909, 180, 3.2, 0.0, 2.2, 0.9, 0, 6, -62)}
fill_rows(c88, [
])                                   # w3: the crook at 1908 became the "hanging leaf" (drawn below, after lens_pts)
CELLS[88] = c88
# Cell 94 gets the tulip's mirrored twin from 1919 (consolidation: replaces a Hook at 1919, a Wheel at 1918 and a
# Tadpole at 2001) and the bud's twin from 1903.
c94.update(mirror_pieces({'tulip': c88['tulip'], 'bud': c88['bud']}, W))
# Medium figure "samara" (consolidation: grown from the Crescent at 1901, moved to the free wall node 2001): a maple seed
# pair - a stem to a seed, two wings (lenses with one flat and one full side) turning the same way, notable wing tips.
H94 = at(road(2001), 90, 1.95)
_sm = {'s1': (at(road(2001), 90, 1.0), 'small'), 'h': (H94, 'small')}
_sml = [(2001, 's1', None), ('s1', 'h', None)]
for t, a in (('i', 12), ('o', 192)):
    T = at(H94, a, 2.05); A = at(H94, a, 1.05, 0.62); B = at(H94, a, 1.0, -0.32)
    _sm.update({f'{t}a': (A, 'small'), f'{t}b': (B, 'small'), f'{t}t': (T, 'notable')})
    for x, X in (('a', A), ('b', B)):
        cc = circ(H94, X, T); _sml += [('h', f'{t}{x}', cc), (f'{t}{x}', f'{t}t', cc)]
c94['samara'] = (_sm, _sml)

# ======================= cell 72: middle band, theta -23..-11 =========================================================
# Centre: a vine of alternating shoots hanging from top node 1900 (theta -18), bending gently towards +theta.
# Medium figure "cut stem" (consolidation: replaces a Ring at 2001 and a Hairpin at 1917): from wall node 2001 a stem
# enters a ring of six from the +theta side; two spokes join the far ring nodes to a pith notable at the centre, and the
# far side of the ring is a notable.
O72 = Lp(59.4, -13.9)
_c72 = {'s1': (Lp(59.25, -11.8), 'small'), 'H': (O72, 'notable')}
_c72.update({f'r{a}': (pol(O72, 1.35, a), 'notable' if a == 270 else 'small') for a in (30, 90, 150, 210, 270, 330)})
c72 = {'vine': shoots(1900, 180, 5, 1.5, 4, {1: 1, 2: -1, 3: 1}, 0.85, 75, curl=-60),
       'cutstem': (_c72, [(2001, 's1', None), ('s1', 'r90', None), ('r210', 'H', None), ('r330', 'H', None)] +
                   arcs(['r90', 'r150', 'r210', 'r270', 'r330', 'r30', 'r90'], O72))}
fill_rows(c72, [
    ('72 tadpole', 1899, 'Tadpole', 'round', 1.0, 140, 0, False),
    ('72 crook',   1901, 'Crook', 'swept', 1.0, -130, 0, False),
    ('72 diamond', 1915, 'Diamond', 'cusped', 1.0, -20, 0, False),
    ('72 crook2',  1918, 'Crook', 'bow in', 1.0, -40, 0, True),
])
CELLS[72] = c72

# ======================= cell 71: mirror of 72, its Tadpole swapped for a Spur pair ===================================
c71 = mirror_pieces({k: v for k, v in c72.items() if k != '72_tadpole'}, W)
fill_rows(c71, [('71 spur', 1906, 'Spur pair', 'bow out', 1.4, -150, 0, False)])
CELLS[71] = c71

# ======================= cell 52: outer band, theta 17..28 ============================================================
# Centre: a vine tendril, a big spiral rising from bottom node 1855 (theta 24) and curling towards -theta.
# Medium figure "round leaf" (consolidation: replaces a Hook at 1926 and a Hairpin at 1924): from top node 1925 a stem
# to a round leaf, a ring of six round O with a midrib through O to its tip; notables at its two outer shoulders.
O52 = Lp(67.45, 20.0)
_rl = {'s1': (Lp(65.3, 20.0), 'small'), 'm': (O52, 'small')}
_rl.update({f'r{a}': (pol(O52, 1.3, a), 'notable' if a in (120, 240) else 'small') for a in range(0, 360, 60)})
# Medium figure "blossom" (consolidation: replaces a Crook at 1856 and a Diamond at 1857): from bottom node 1856 a stem to
# a ring of five, a petal notable off each side.
O52b = Lp(71.4, 20.0)
BL_A, BL_B = -40, 0.2                # w2: petals on curved stalks sweeping up round the bloom (were straight spikes at 108 / 252)
_bl = {'s1': (Lp(73.3, 20.0), 'small'), 'p108': (pol(O52b, 1.85, 108 + BL_A), 'notable'), 'p252': (pol(O52b, 1.85, 252 - BL_A), 'notable')}
_bl.update({f'r{a}': (pol(O52b, 1.0, a), 'small') for a in (180, 252, 324, 36, 108)})
c52 = {'tendril': spiral(1855, 0, 4.1, -0.3, 2.7, 0.9, 180, 8, -52),   # w2: 8 turn nodes (was 7), keeping 52's node count after the split leaf
       'roundleaf': (_rl, [(1925, 's1', None), ('s1', 'r0', None), ('r0', 'm', None), ('m', 'r180', None)] +
                     [(f'r{a}', f'r{(a + 60) % 360}', O52) for a in range(0, 360, 60)]),
       'blossom': (_bl, [(1856, 's1', None), ('s1', 'r180', None), ('r108', 'p108', bow_centre(_bl['r108'][0], _bl['p108'][0], BL_B, O52b) if BL_B else None),
                                    ('r252', 'p252', bow_centre(_bl['r252'][0], _bl['p252'][0], BL_B, O52b) if BL_B else None)] +
                   arcs(['r180', 'r252', 'r324', 'r36', 'r108', 'r180'], O52b))}
fill_rows(c52, [
    ('52 hook2',   1854, 'Hook', 'bow in', 1.0, -40, 0, False),
])
CELLS[52] = c52

# ======================= cell 60: outer band, theta -28..-17 ==========================================================
# Centre: two big leaves in a V from one bottom node, 1845 (theta -24).
# Big figure "growth rings" (consolidation: replaces a Ring at 1914 and a Hook at 1916): from top node 1915, a log seen
# end on - an outer arc of five round the pith O (its ends notables) and an inner arc of five on the same angles, the two
# joined at their ends by spokes (a ring segment), two spokes from the inner arc to the pith notable (window-1 pass
# 2026-11-19: was an inner arc of three tied to the pith, a cramped wedge).
O60 = at(road(1915), 180, 4.5)
GR_A = (-66, -33, 0, 33, 66)
_gr = {'s1': (at(road(1915), 180, 0.95), 'small'), 'O': (O60, 'notable')}
_gr.update({f'o{a}': (pol(O60, 2.6, a), 'notable' if abs(a) == GR_A[-1] else 'small') for a in GR_A})
_gr.update({f'i{a}': (pol(O60, 1.5, a), 'small') for a in GR_A})
# Medium figure "fern crozier" (consolidation: grown from the Crescent at 1847): from the corner node 1847 a stem rises
# along the wall to a curled fern head (a shrinking orbit, notable at its heart); a leaflet arc off the stem (window-1
# pass: the head larger by one turn node, the leaflet an arc instead of a stick).
K60 = Lp(70.2, -18.4)
_fc = {'s': (Lp(72.45, -17.75), 'small'), 'u': (Lp(72.25, -18.85), 'small'), 'n': (Lp(71.8, -19.85), 'notable')}
_fc.update({f'f{i}': (pol(K60, 1.15 * (1 - 0.12 * i), 160 + 80 * i), 'notable' if i == 5 - 1 else 'small') for i in range(5)})
_fcl = [(1847, 's', None), ('s', 'f0', None)] + arcs(['s', 'u', 'n'], circ(_fc['s'][0], _fc['u'][0], _fc['n'][0]))
_fcl += [(f'f{i}', f'f{i + 1}', circ(_fc[f'f{i}'][0], pol(K60, 1.15 * (1 - 0.12 * (i + 0.5)), 200 + 80 * i), _fc[f'f{i + 1}'][0])) for i in range(5 - 1)]
c60 = {'crozier': (_fc, _fcl),
       'leafL': leaf(1845, -28, 1.0, 3.7, 1.9), 'leafR': leaf(1845, 28, 1.0, 3.7, 1.9),
       'rings': (_gr, [(1915, 's1', None), ('s1', 'o0', None), (f'i{GR_A[1]}', 'O', None), (f'i{GR_A[3]}', 'O', None), (f'o{GR_A[0]}', f'i{GR_A[0]}', None),
                       (f'o{GR_A[-1]}', f'i{GR_A[-1]}', None)] +
                 arcs([f'o{a}' for a in GR_A], O60) + arcs([f'i{a}' for a in GR_A], O60))}

fill_rows(c60, [
    ('60 tadpole', 1913, 'Tadpole', 'round', 1.4, 150, 0, False),
    ('60 crook2',  1844, 'Crook', 'bow out', 1.0, 40, 0, True),
])
CELLS[60] = c60

# ======================= cell 109: outer band, theta -36..-28 =========================================================
# Centre: a fern frond hanging from top node 1912 (theta -31), curling gently, leaflets on alternate sides.
c109 = {'frond': shoots(1912, 180, 5, 1.45, 9, {1: -1, 2: 1, 3: -1}, 0.9, 80, curl=40)}
fill_rows(c109, [
    ('109 crook',   1911, 'Crook', 'bow out', 1.0, 150, 0, False),
    ('109 crescent', 1844, 'Crescent', 'bow in', 1.0, -40, 0, False),
    ('109 crook2',  514, 'Crook', 'bow out', 1.0, 110, 0, False),
])
CELLS[109] = c109

# ======================= cell 107: mirror of 109, its Crescent swapped ================================================
c107 = mirror_pieces({k: v for k, v in c109.items() if k != '109_crescent'}, W)
fill_rows(c107, [('107 crook', 1854, 'Crook', 'swept', 1.0, 40, 0, True)])
CELLS[107] = c107

# ======================= cell 35: band 41.7-53.9, theta -18..0 (axis hex at theta -3..0 is a wall) ====================
# Combo B upper half: the half-ring round 1902 on the inward side. Centre: a lyre, two fiddleheads facing each other
# from top nodes 1833 (theta -13) and 1834 (theta -8.5).
# Big figure "laurel wreath" (consolidation: replaces a Diamond at 1901 and a Tadpole at 1903): from bottom node 1901
# a stem rises into the empty middle to a wreath, an open ring of nine (window-3 pass 2026-11-19: was seven and a leaf
# on a stalk at each flank; the flank leaves sat beside the ring's ends, two pairs of notables under the lyre), open
# towards the tree centre; notables at its two ends and at its foot, the knot where the stem ties on.
O35 = Lp(48.3, -11.0)
WR_A = (40, 75, 110, 145, 180, 215, 250, 285, 320)
_w35 = {'s1': (Lp(52.85, -11.0), 'small'), 's2': (Lp(51.55, -11.0), 'small')}
_w35.update({f'w{a}': (pol(O35, 2.0, a), 'notable' if a in (WR_A[0], 180, WR_A[-1]) else 'small') for a in WR_A})
# Medium figure "acorn" on a long stem (third use of cell 13's cap and nut, its stem longer; consolidation: grown from
# the Ring at 1835): hanging from top node 1835 into the free strip beside the axis hex.
O35a = Lp(46.1, -5.0)
_ac35 = {'s1': (Lp(42.7, -4.6), 'small'), 's2': (Lp(43.85, -4.85), 'small'), 'T': (pol(O35a, 1.45, 180), 'notable')}
_ac35.update({f'c{a}': (pol(O35a, 1.2, a), 'notable' if a in (90, 270) else 'small') for a in (270, 315, 0, 45, 90)})
_ac35l = [(1835, 's1', None), ('s1', 's2', None), ('s2', 'c0', None)] + arcs(['c270', 'c315', 'c0', 'c45', 'c90'], O35a)
for a, m in ((90, 135), (270, 225)):
    _ac35l.append((f'c{a}', 'T', circ(_ac35[f'c{a}'][0], pol(O35a, 1.12, m), _ac35['T'][0])))
c35 = {'acorn': (_ac35, _ac35l),
       'wreath': (_w35, [(1901, 's1', None), ('s1', 's2', None), ('s2', 'w180', None)] + arcs([f'w{a}' for a in WR_A], O35)),
       'seedB_up': half_ring(1902, 0, 2.0, (-60, -30, 0, 30, 60)),
       'lyreL': spiral(1833, 180, 2.7, 0.3, 1.7, 0.7, 0, 5, 62),
       'lyreR': spiral(1834, 180, 2.7, -0.3, 1.7, 0.7, 0, 5, -62)}
fill_rows(c35, [
    ('35 vine',    1832, 'Zigzag', 'wave', 1.4, 150, 0, False),
])
CELLS[35] = c35

# ======================= cell 21: band 41.7-53.9, theta 0..18 (axis hex at theta 0..2.5 is a wall) ====================
# Centre: a willow - three weeping branches hanging from top nodes 1841, 1840, 1839, bending towards -theta; the
# middle one carries a shoot.
# Big figure "sprouting seed" (consolidation: replaces a Wheel at 1910 and a Spur pair at 1908): from bottom node 1909
# a stem enters a ring of eight in the empty middle (notables at its sides) and a shoot rises from the ring's top.
O21 = Lp(50.3, 7.3)
SH21 = (-4, -13)                      # w2: the shoot bends (angles round O of its two nodes; was a straight spike at 0, 0)
_r21 = {'s1': (Lp(52.9, 7.3), 'small'), 'u': (pol(O21, 2.6, SH21[0]), 'small'), 'n': (pol(O21, 3.55, SH21[1]), 'notable')}
_r21.update({f'r{a}': (pol(O21, 1.6, a), 'notable' if a in (90, 270) else 'small') for a in range(0, 360, 45)})
# Medium figure "willow leaf" (consolidation: grown from the Crescent at 1907): from the corner node 1907 a stem to a
# long leaf leaning into the cell, each side an arc of two nodes on one circle through base and tip, a notable tip.
_p = road(1907); _S = at(_p, -50, 2.3); _T = at(_p, -50, 5.7)
_wl = {'s1': (at(_p, -50, 1.2), 'small'), 'S': (_S, 'small'), 'T': (_T, 'notable')}
_wll = [(1907, 's1', None), ('s1', 'S', None)]
for x, sg in (('a', 1), ('b', -1)):
    cc = bow_centre(_S, _T, 0.24, at(_p, -50, 4.0, -sg * 2.0))
    for k, xy in enumerate(arc_between(_S, _T, cc, 2), 1):
        _wl[f'{x}{k}'] = (xy, 'small')
    _wll += arcs(['S', x + '1', x + '2', 'T'], cc)
c21 = {'willowleaf': (_wl, _wll),
       'seed': (_r21, [(1909, 's1', None), ('s1', 'r180', None), ('r0', 'u', circ(_r21['r0'][0], _r21['u'][0], _r21['n'][0])),
                        ('u', 'n', circ(_r21['r0'][0], _r21['u'][0], _r21['n'][0]))] +
                [(f'r{a}', f'r{(a + 45) % 360}', O21) for a in range(0, 360, 45)]),
       'weep1': smoothed(shoots(1841, 180, 4, 1.4, -13, {}), 1841),
       'weep2': smoothed(shoots(1840, 180, 5, 1.4, -12, {2: 1}, 0.9, 70, curl=40), 1840)}
fill_rows(c21, [
    ('21 arch',    1842, 'Arch', 'bow out', 1.0, 170, 0, False),
    ('21 hairpin', 1839, 'Hairpin', 'bow out', 1.0, -140, 0, False),
])
CELLS[21] = c21

# ======================= cell 31: band 41.7-53.9, theta -36..-18 (border road on the left) ============================
# Centre: a bamboo grove - three straight stalks rising from bottom nodes 1897, 1898, 1899, a leaf shoot at one joint each
# (window-1 pass 2026-11-19: each shoot one drooping arc, was a bent stick).
# Medium figure "fir" (consolidation: replaces a Diamond at 1830 and a Hook at 1831): a fir hanging from top node
# 1831 into the empty corner, drawn as a sector round its own tip A - two tiers (arcs round A) between two straight sides and a trunk.
A31 = at(road(1831), 180, 4.2)
_fir = {'A': (A31, 'notable')}
for k, rr in ((1, 1.9), (2, 3.3)):
    _fir.update({f'M{k}': (pol(A31, rr, 0), 'small'), f'L{k}': (pol(A31, rr, 36), 'notable' if k == 1 else 'small'),
                 f'R{k}': (pol(A31, rr, -36), 'notable' if k == 1 else 'small')})
_fl = [(1831, 'M2', None), ('M2', 'M1', None), ('M1', 'A', None), ('A', 'L1', None), ('L1', 'L2', None), ('A', 'R1', None),
       ('R1', 'R2', None)] + [(f'{x}{k}', f'M{k}', A31) for k in (1, 2) for x in 'LR']
c31 = {'fir': (_fir, _fl),
       'bamboo1': shoots(1897, 0, 5, 1.35, 0, {1: 1, 3: -1}, 0.8, 62, curl=-35),   # w3: one joint taller, a leaf towards the border (was 4, {1: 1})
       'bamboo2': shoots(1898, 0, 5, 1.35, 0, {2: -1}, 0.8, 62, curl=-35),
       'bamboo3': shoots(1899, 0, 4, 1.35, 0, {1: -1}, 0.8, 62, curl=-35)}
fill_rows(c31, [
    ('31 tadpole', 291, 'Tadpole', 'round', 1.0, 70, 0, False),
    ('31 fork',    1900, 'Fork', 'closed', 1.4, -30, 0, False),     # w3: was listed under 35 as '35 fork'; its nodes lie in 31
])
CELLS[31] = c31

# ======================= cell 25: band 41.7-53.9, theta 18..36 ========================================================
# Centre: a binary tree hanging from top node 1837 (theta 28): trunk, two boughs, four twig notables.
# Medium figure "fern fan" (consolidation: grown from the Tadpole at 1906): from bottom node 1906 a stem rises into the
# empty middle to a hub; three spokes cross an arc round the hub and end in three leaflets.
H25 = at(road(1906), 10, 2.3)
_f25 = {'s1': (at(road(1906), 10, 1.05), 'small'), 'h': (H25, 'small')}
_f25.update({f'a{i}': (pol(H25, 1.6, 10 + 45 * i), 'small') for i in (-1, 0, 1)})
_f25.update({f't{i}': (pol(H25, 2.8, 10 + 45 * i), 'notable') for i in (-1, 0, 1)})
# Medium figure "ginkgo leaf" (consolidation: replaces a Hook at 311, a Diamond at 312 and a Crook at 1904): from wall
# node 312 a stem to the leaf's base; a fan of five on an arc round the base, closed by its two edges, notables on the
# fan either side of its notch.
H25g = at(road(312), -108, 1.9)
_gk = {'s1': (at(road(312), -108, 0.9), 'small'), 'h': (H25g, 'small')}
_gk.update({f'a{i}': (pol(H25g, 2.5, -108 + 30 * i), 'notable' if abs(i) == 1 else 'small') for i in (-2, -1, 0, 1, 2)})
c25 = {'ginkgo': (_gk, [(312, 's1', None), ('s1', 'h', None), ('h', 'a-2', None), ('h', 'a2', None)] +
                  arcs(['a-2', 'a-1', 'a0', 'a1', 'a2'], H25g)),
       'tree2': branching(1837, 180, 2, 2.3, 1.8, 34, 28, 0.12),
       'fan': (_f25, [(1906, 's1', None), ('s1', 'h', None)] + [('h', f'a{i}', None) for i in (-1, 0, 1)] +
               arcs(['a-1', 'a0', 'a1'], H25) + [(f'a{i}', f't{i}', None) for i in (-1, 0, 1)])}
fill_rows(c25, [
    ('25 hook',    1838, 'Hook', 'bow out', 1.0, 170, 0, True),    # w3: was a Fork, a second Y beside the binary tree's twig fork
    ('25 ring',    1836, 'Ring', 'round', 1.0, 150, 0, False),
])
CELLS[25] = c25

# ======================= cell 39: middle band, theta 23..36 (border hex at theta 34-38 is a wall) ======================
# Centre: a big leaf with its midrib, from top node 1905 (theta 29), pointing outward.
# Big figure "sprouting bough" (consolidation: replaces a Wheel at 1923, a Diamond at 1922, a Crescent at 1921): a
# bough arching between bottom nodes 1923 and 1921 on one orbit; from its crown a leaf lens points inward beside the
# big leaf's tip, and a twig leaves the next node towards the border hex.
O39 = Lp(66.0, 30.75)
_b39 = {f'v{a}': (pol(O39, 3.55, a), 'small') for a in (-45, -22, 0, 22, 45)}
_b39.update({'la': (at(pol(O39, 4.5, 0), 0, 0, 0.75), 'small'), 'lb': (at(pol(O39, 4.5, 0), 0, 0, -0.75), 'small'),
             'lt': (pol(O39, 5.45, 0), 'notable'), 'u22': (pol(O39, 4.45, 20), 'small'), 'n22': (pol(O39, 5.35, 16), 'notable')})
# Medium figure "young fir" (consolidation: grown from the Hook at 1904): a slimmer fir than cell 31's, hanging from top
# node 1904 between the big leaf and the border hex - a sector round its tip (the one notable), three tiers (window-1
# pass 2026-11-19: was two tiers squeezed short and wide; now taller and narrower).
YF_T, YF_D, YF_R, YF_S = 0, 5.1, (1.75, 2.8, 3.85), 24   # w1: lean, tip distance, tier radii, half spread (was 0, 3.75, 1.45/2.55, 34)
A39 = at(road(1904), 180 + YF_T, YF_D)
_yf = {'A': (A39, 'notable')}
for k, rr in enumerate(YF_R, 1):
    _yf.update({f'M{k}': (pol(A39, rr, YF_T), 'small'), f'L{k}': (pol(A39, rr, YF_T + YF_S), 'small'),
                f'R{k}': (pol(A39, rr, YF_T - YF_S), 'small')})
_n = len(YF_R)
_yfl = [(1904, f'M{_n}', None)] + [(f'M{k + 1}', f'M{k}', None) for k in range(1, _n)] + [('M1', 'A', None), ('A', 'L1', None), ('A', 'R1', None)]
_yfl += [(f'{x}{k}', f'{x}{k + 1}', None) for k in range(1, _n) for x in 'LR'] + [(f'{x}{k}', f'M{k}', A39) for k in range(1, _n + 1) for x in 'LR']
c39 = {'youngfir': (_yf, _yfl),
       'bigleaf': big_leaf(1905, 180, 1.1, 6.2, 3.4),
       'bough': (_b39, [(1923, 'v-45', None), ('v45', 1921, None)] + arcs(['v-45', 'v-22', 'v0', 'v22', 'v45'], O39) +
                 [('v0', 'la', circ(_b39['v0'][0], _b39['la'][0], _b39['lt'][0])),
                  ('la', 'lt', circ(_b39['v0'][0], _b39['la'][0], _b39['lt'][0])),
                  ('v0', 'lb', circ(_b39['v0'][0], _b39['lb'][0], _b39['lt'][0])),
                  ('lb', 'lt', circ(_b39['v0'][0], _b39['lb'][0], _b39['lt'][0])),
                  ('v22', 'u22', None), ('u22', 'n22', None)])}
fill_rows(c39, [
    ('39 tadpole', 1512, 'Tadpole', 'cusped', 1.0, -40, 0, False),
    ('39 crescent2', 1924, 'Crescent', 'bow in', 1.4, 30, 0, False),
])
CELLS[39] = c39

# ======================= cell 67: inner band, theta -23..0 ============================================================
# Centre: a seedling rising outward from inner-ring node 1821 (theta -14), two cotyledon leaves.
# Big figure "tendril fork" (consolidation: replaces a Hook at 1832 and a Diamond at 1834): from bottom node 1833 a stem
# rises to a fork; two bowed boughs spread wide and each curls up into a tendril ending in a notable.
_f = at(road(1833), 0, 2.0)
_lf = {'s1': (at(road(1833), 0, 1.0), 'small'), 'f': (_f, 'small')}
_ll = [(1833, 's1', None), ('s1', 'f', None)]
for sg, t in ((1, 'R'), (-1, 'L')):
    b = at(_f, sg * 62, 1.2); K = at(b, sg * 95, 1.0); a0 = sg * 95 + 180
    _lf[f'b{t}'] = (b, 'small'); _ll.append(('f', f'b{t}', bow_centre(_f, b, 0.12, at(_f, 0, 1.0))))
    prev, pxy = f'b{t}', b
    for k in (1, 2, 3):
        xy = ring_pt(K, 1.0 - 0.14 * k, a0 + sg * 72 * k, K); key = f'c{t}{k}'
        _lf[key] = (xy, 'notable' if k == 3 else 'small')
        _ll.append((prev, key, circ(pxy, ring_pt(K, 1.0 - 0.14 * (k - 0.5), a0 + sg * 72 * (k - 0.5), K), xy)))
        prev, pxy = key, xy
# Medium figure "parted seed" (window-3 pass 2026-11-19: was a round Tadpole at 218, whose mirror twin in 64 made, with
# 67's ring and 64's wheel, four loops in a row): from 218 a stem to an arc of four on an orbit round a centre on the axis
# below 218, its open end a notable; with its twin in 64 the axis runs through one seed coat parted in two.
PS_Q, PS_R, PS_A = 38.9, 2.2, (50, 80, 105, 130)       # centre (r, on the axis), orbit radius, node angles off the axis
_Q = Lp(PS_Q, 0.0); _p = road(218)
_par = {f'p{a}': (pol(_Q, PS_R, -a), 'notable' if a == PS_A[-1] else 'small') for a in PS_A}
_par['s1'] = (((_p[0] + _par[f'p{PS_A[0]}'][0][0]) / 2, (_p[1] + _par[f'p{PS_A[0]}'][0][1]) / 2), 'small')
c67 = {'seedling': seedling(1821, 180, 1.0), 'tendrils': (_lf, _ll),
       'parted': (_par, [(218, 's1', None), ('s1', f'p{PS_A[0]}', None)] + arcs([f'p{a}' for a in PS_A], _Q))}
fill_rows(c67, [
    ('67 ring',    1822, 'Ring', 'round', 1.0, 170, 0, False),
])
CELLS[67] = c67

# ======================= cell 64: mirror of 67, its Ring swapped for a Wheel =========================================
c64 = mirror_pieces({k: v for k, v in c67.items() if k != '67_ring'}, W)
fill_rows(c64, [('64 wheel', 1828, 'Wheel', 'spoke', 1.0, 190, 0, False)])
CELLS[64] = c64

# ======================= cell 112: inner band, theta -36..-23 (small) =================================================
# Medium figure "berry sprig" (consolidation: replaces a Crook at 1830 and a Crescent at 1529): from bottom node 1830 a
# stem rises to a hub; three short stalks fan out from it, each ending in a berry notable (window-1 pass 2026-11-19:
# the stalks are arcs, were straight sticks).
BS_T, BS_A, BS_C = -25, (-45, 0, 45), (-38, 16, 38)   # w1: lean of the sprig, its stalk angles, each stalk's bend (an arc)
H112 = at(road(1830), BS_T, 2.3)
_bs = {'s1': (at(road(1830), BS_T, 1.15), 'small'), 'h': (H112, 'small')}
_bs.update({f'u{i}': (pol(H112, 1.0, BS_T + a), 'small') for i, a in enumerate(BS_A)})
_bs.update({f'n{i}': (pol(H112, 2.0, BS_T + a + c), 'notable') for i, (a, c) in enumerate(zip(BS_A, BS_C))})
_bsl = [(1830, 's1', None), ('s1', 'h', None)]
for i in range(len(BS_A)):
    cc = circ(H112, _bs[f'u{i}'][0], _bs[f'n{i}'][0]); _bsl += [('h', f'u{i}', cc), (f'u{i}', f'n{i}', cc)]
c112 = {'berries': (_bs, _bsl)}
fill_rows(c112, [
    ('112 arch',   1817, 'Arch', 'bow out', 1.0, 160, 0, False),
])
CELLS[112] = c112

# ======================= cell 111: inner band, theta 23..36 (small) ===================================================
# Centre: a small curl hanging inward from outer-ring node 1837 (theta 28).
# Medium figure "crescent leaf" (consolidation: replaces a Diamond at 1824 and a Hairpin at 1836): from top node 1823 a
# stem to a moon-shaped leaf curving towards +theta - a full outer arc of four and a thin inner arc of one, both on
# circles through the leaf's base and tip; notables at the tip and the outer arc's middle.
S111, T111 = Lp(35.2, 30.6), Lp(38.5, 33.3)
Co111 = bow_centre(S111, T111, 0.3, Lp(39.6, 27.4)); Ci111 = bow_centre(S111, T111, 0.1, Lp(39.6, 27.4))
_cl = {'s1': (Lp(34.2, 30.85), 'small'), 'S': (S111, 'small'), 'T': (T111, 'notable')}
for k, xy in enumerate(arc_between(S111, T111, Co111, 4), 1):
    _cl[f'o{k}'] = (xy, 'notable' if k == 2 else 'small')
_cl['i1'] = (arc_between(S111, T111, Ci111, 1)[0], 'small')
_cll = [(1823, 's1', None), ('s1', 'S', None)] + arcs(['S', 'o1', 'o2', 'o3', 'o4', 'T'], Co111) + arcs(['S', 'i1', 'T'], Ci111)
c111 = {'curl': spiral(1837, 0, 2.3, 0.0, 1.5, 0.7, 180, 5, 64), 'crescentleaf': (_cl, _cll)}
fill_rows(c111, [
])
CELLS[111] = c111

# ======================= cell 1: the Wood start cell (big and sparse, B4) =============================================
# Two root tendrils curling in from the inner ring towards the start (window-1 pass: drawn as smooth curves), and a small
# piece on each side spoke.
c1 = {'rootL': smoothed(shoots(1820, 0, 4, 1.35, 11, {}), 1820), 'rootR': smoothed(shoots(1826, 0, 4, 1.35, -11, {}), 1826)}
fill_rows(c1, [
    ('1 fork',     294, 'Fork', 'closed', 1.0, 70, 0, False),
    ('1 spur',     314, 'Spur pair', 'bow out', 1.0, -110, 0, False),
])
CELLS[1] = c1

# ======================= cell 79: the hub cell facing Wood (inside the Taiji ring) ====================================
c79 = {}
fill_rows(c79, [
    ('79 crook',   24, 'Crook', 'bow out', 1.0, -10, 0, False),
    ('79 crook2',  26, 'Crook', 'swept', 1.0, -10, 0, True),
    ('79 diamond', 9, 'Diamond', 'round', 1.0, 170, 0, False),
])
CELLS[79] = c79

# ======================= cell 43: Wind start cell beside the Water-Wood border (theta -36..-23; start figure at -36..-33)
# Wind flavour. Centre: gust streamlines - two long chains blowing outward from top nodes 1897 and 1898, next to the
# Wind start, and bending away from it towards +theta. The eddy (a small curl from bottom node 1913) that completed it
# was folded into the wind streaks below. Big figure "wind streaks" (consolidation: replaces that eddy and a Hook at 1912): from bottom node 1912 a stem
# reaches a hub; three streamlines (arcs) blow from it towards +theta under the gusts, of staggered lengths.
_g = {'s1': ((63.3, -30.5), 'small'), 'h': ((62.2, -29.9), 'small'), 'm1': ((62.1, -28.3), 'small'), 'mN': ((62.25, -26.9), 'notable'),
      'i0': ((61.35, -29.6), 'small'), 'i1': ((61.15, -28.0), 'small'), 'iN': ((61.3, -26.4), 'notable'),
      'o0': ((63.1, -29.5), 'small'), 'o1': ((63.0, -28.45), 'small'), 'oN': ((63.1, -27.4), 'notable')}
_g = {k: (Lp(*rt), kd) for k, (rt, kd) in _g.items()}
_gl = [(1912, 's1', None), ('s1', 'h', None), ('h', 'i0', None), ('h', 'o0', None)]
for a, b, c in (('h', 'm1', 'mN'), ('i0', 'i1', 'iN'), ('o0', 'o1', 'oN')):
    cc = circ(_g[a][0], _g[b][0], _g[c][0]); _gl += [(a, b, cc), (b, c, cc)]
c43 = {'gust1': smoothed(shoots(1897, 175, 5, 1.4, -10, {}), 1897),     # w1: drawn as smooth streamlines
       'gust2': smoothed(shoots(1898, 178, 5, 1.4, -12, {}), 1898),
       'streaks': (_g, _gl)}
fill_rows(c43, [
    ('43 wave',    1899, 'Zigzag', 'wave', 1.0, -140, 0, False),
    ('43 hairpin', 1914, 'Hairpin', 'bow out', 1.0, -40, 0, False),
])
CELLS[43] = c43

# ======================= cell 44: Wind cell on the Water side of the border (theta -49..-36; start figure at -39..-36) =
# Centre: a cloud scroll hanging from top node 1871 (theta -43).
# Big figure "pinwheel gust" (consolidation: replaces a Wheel at 1889 and a Hairpin at 1888): a vortex ring of six
# in the empty middle, two tails swirling off it in one turning sense (notables at their ends); the stem from 1889
# comes in as the third tail.
# (Window-3 pass 2026-11-19, from Water's pass: the closed vortex ring sat with 44's cloud and Water 69's / 54's round
# figures round 1890, four loops at one seam; the ring is now an open vortex, a shrinking orbit from the stem's entry to a
# notable eye, the two tails leaving it as before.)
O44 = Lp(60.5, -43.2)
VX_R0, VX_R1, VX_O = 1.3, 0.6, (180, 240, 300, 0, 60, 120)     # vortex radius at its entry and at its eye, node angles in order
_v = {f'r{a}': (pol(O44, VX_R0 + (VX_R1 - VX_R0) * i / 5, a), 'notable' if i == 5 else 'small') for i, a in enumerate(VX_O)}
_v.update({'s1': (pol(O44, 1.85, 210), 'small'), 'p60': (pol(O44, 1.85, 90), 'small'), 'q60': (pol(O44, 2.5, 115), 'notable'),
           'p300': (pol(O44, 1.85, 330), 'small'), 'q300': (pol(O44, 2.5, 355), 'notable')})
_vl = [(1889, 's1', None), ('s1', 'r180', circ(_v['r180'][0], pol(O44, 1.55, 195), _v['s1'][0]))]
_vl += [(f'r{VX_O[i]}', f'r{VX_O[i + 1]}', circ(_v[f'r{VX_O[i]}'][0], pol(O44, VX_R0 + (VX_R1 - VX_R0) * (i + 0.5) / 5, VX_O[i] + 30),
                                                _v[f'r{VX_O[i + 1]}'][0])) for i in range(5)]
for a in (60, 300):
    cc = circ(_v[f'r{a}'][0], _v[f'p{a}'][0], _v[f'q{a}'][0]); _vl += [(f'r{a}', f'p{a}', cc), (f'p{a}', f'q{a}', cc)]
c44 = {'cloud': cloud(1871, 180, 1.4, 1.6, 4, 62), 'pinwheel': (_v, _vl)}
fill_rows(c44, [
    ('44 wave',    1872, 'Zigzag', 'wave', 1.4, 150, 0, False),
    ('44 crescent', 1870, 'Crescent', 'bow in', 1.0, 170, 0, False),
    ('44 hook',    1890, 'Hook', 's-curve', 1.4, 30, 0, False),
    ('44 hook2',   1887, 'Hook', 'bow in', 1.0, -30, 0, False),
])
CELLS[44] = c44

# ======================= cell 905: Wood's rim (beyond the outer ring, theta -33..33) + keystones ======================
# Combo C "gourd vine": the axis road past the outer ring becomes the vine of a gourd - leaves alternate from axis nodes
# 504 (r 80, +theta), 476 (r 84, -theta) and 1371 (r 89, +theta), and the big hồ lô gourd (rim figures block, at the
# end of this file) hangs from the road's open end 1372 (r 94). Keystones past the hooks 2009 / 2010 (theta -12 / +12).
# Rim pass 2026-11-19 (design/dao-do/cells/rim-brief.md): lingzhi, gourd mediums (and twins), peach, big leaf and
# branching tree removed; the rim's large figures are drawn in the RIM FIGURES block.
c905 = {'stalk_leaf1': leaf(504, 90, 1.0, 3.0, 1.5), 'stalk_leaf2': leaf(476, -90, 1.0, 3.0, 1.5),
        'stalk_leaf3': leaf(1371, 90, 1.0, 2.8, 1.4),
        'keystone_w': ({'k': (Lp(81.8, -12.3), 'keystone')}, [(2009, 'k', None)]),
        'keystone_e': ({'k': (Lp(81.8, 12.3), 'keystone')}, [(2010, 'k', None)])}
CELLS[905] = c905


# ======================= density pass v2 (2026-11-18, design/dao-do/cells/density-brief.md) ===========================
# Every addition below is placed by hand. Wall pairs: a half drawn on one side of a wall road, its exact mirror across
# the wall (celllib.wall_pair) in the cell across, so the road runs through one symmetric figure.
from celllib import wall_pair  # noqa: E402


def onc(O, rho, angs, kinds, tag='n'):
    """Nodes on a circle round O at the given angles (O's frame: 0 = towards the tree centre, + = towards +theta)."""
    return {f'{tag}{i}': (pol(O, rho, a), k) for i, (a, k) in enumerate(zip(angs, kinds))}


def put(pair, a, b, na, nb=None):
    """File a wall pair: half into cell a, mirror into cell b, under piece name na (nb for the mirror)."""
    h, o = pair
    CELLS[a].update({na: v for v in h.values()})
    CELLS[b].update({nb or na: v for v in o.values()})


# --- pair 1, spoke -23 (112 | 67) from free node 1819: "split leaf" - a leaf outline cut by the spoke, each half an arc
# of five round a centre ON the spoke, notables at its widest point and its open end.
C1 = Lp(35.6, -23.0)
_h = onc(C1, 1.5, (-28, -68, -108, -148), ('small', 'small', 'small', 'notable'))
put(wall_pair({'x': (_h, [(1819, 'n0', None)] + arcs(['n0', 'n1', 'n2', 'n3'], C1))}, 1819, 1831),
    112, 67, 'splitleaf')
# its axis twin across spoke +23 (111 | 64) from free node 1825.
CELLS[111]['splitleaf'] = mirror_pieces({'x': CELLS[112]['splitleaf']}, W)['x']
CELLS[64]['splitleaf'] = mirror_pieces({'x': CELLS[67]['splitleaf']}, W)['x']

# --- cell 31, new big figure "pine cone" from the free side of 1830, beside the fir: an egg outline (top, two shoulders,
# two widest points, a tip) with two rows of scales across it, each row an arc sagging towards the tip.
O31 = Lp(45.75, -27.2)
_pc31 = {'s1': (Lp(42.65, -27.8), 'small'), 'T': (pol(O31, 2.15, 0), 'small'), 'B': (pol(O31, 2.5, 180), 'notable'),
         'L1': (pol(O31, 1.25, -40), 'small'), 'R1': (pol(O31, 1.25, 40), 'small'),
         'L2': (pol(O31, 1.15, -95), 'notable'), 'R2': (pol(O31, 1.15, 95), 'notable'),
         'M1': (pol(O31, 0.35, 0), 'small'), 'M2': (pol(O31, 1.1, 180), 'small')}
_x = lambda k: _pc31[k][0]
_pcl31 = [(1830, 's1', None), ('s1', 'T', None)]
for a, b in (('T', 'L1'), ('L1', 'L2'), ('L2', 'B'), ('T', 'R1'), ('R1', 'R2'), ('R2', 'B')):
    _pcl31.append((a, b, bow_centre(_x(a), _x(b), 0.1, O31)))
for l, m, r in (('L1', 'M1', 'R1'), ('L2', 'M2', 'R2')):
    cc = circ(_x(l), _x(m), _x(r)); _pcl31 += [(l, m, cc), (m, r, cc)]
CELLS[31]['pinecone'] = (_pc31, _pcl31)


def add_lens(piece, base, ang, length, width, tag):
    """Grow a leaf lens on an existing piece: from its node `base` along `ang`, two side nodes and a notable tip."""
    nodes, links = piece
    P = nodes[base][0]
    T = at(P, ang, length); A = at(P, ang, 0.5 * length, width / 2); B = at(P, ang, 0.5 * length, -width / 2)
    nodes.update({tag + 'a': (A, 'small'), tag + 'b': (B, 'small'), tag + 't': (T, 'notable')})
    ca, cb = circ(P, A, T), circ(P, B, T)
    links += [(base, tag + 'a', ca), (tag + 'a', tag + 't', ca), (base, tag + 'b', cb), (tag + 'b', tag + 't', cb)]


# --- cell 31, the bamboo grows: a leaf lens off the middle stalk into the gap by the ring, one off the right stalk
# towards the empty corner under the fir.
add_lens(CELLS[31]['bamboo2'], 's1', 72, 2.0, 0.95, 'g')
add_lens(CELLS[31]['bamboo3'], 's2', 58, 2.0, 0.95, 'g')


def lens_pts(S, ang, length, half, k=0.5):
    """Side points of a lens from S along `ang` (frame at S): its widest point k of the way along, `half` either side."""
    return at(S, ang, k * length, half), at(S, ang, k * length, -half), at(S, ang, length)


# --- cell 25, new big figure "morning glory": a vine climbing from the free side of corner 1907 up the spoke, its flower
# open at the top (a ring of six, two notables on its far side). (Window-1 pass 2026-11-19: the leaf lens off its middle,
# 1.22 from the fern fan's leaflet, became a tendril curl, grown below with grow_curl.)
_vp = [road(1907)]
for ang, step in ((40, 1.0), (15, 1.3), (5, 1.3), (5, 1.3), (15, 1.3)):
    _vp.append(at(_vp[-1], ang, step))
_mg = {f's{i}': (xy, 'small') for i, xy in enumerate(_vp[1:], 1)}
_mgl = [(1907, 's1', None)] + [(f's{i}', f's{i + 1}', None) for i in range(1, 5)]
_F = at(_vp[5], 12, 1.85)                                   # the open flower: a ring of six round F, seen face on
_mg.update({f'f{k}': (pol(_F, 0.9, 192 + 60 * k), 'notable' if k in (2, 4) else 'small') for k in range(6)})
_mgl += [('s5', 'f0', None)] + arcs(['f0', 'f1', 'f2', 'f3', 'f4', 'f5', 'f0'], _F)
CELLS[25]['morningglory'] = (_mg, _mgl)

# --- cell 25, a small fern curl rising from the free side of 1905 into the corner between the fan and the ginkgo.
CELLS[25]['curl'] = spiral(1905, -10, 2.3, -0.2, 1.4, 0.7, 180, 5, 66)


def arc3(a, m, b, n):
    """n points evenly spaced on the circle through a, m, b, going from a to b the way that passes m; and its centre."""
    C = circ(a, m, b)
    ang = lambda p: math.atan2(p[1] - C[1], p[0] - C[0])
    t0, tm, t1 = ang(a), ang(m), ang(b)
    d1 = (t1 - t0) % (2 * math.pi)
    if (tm - t0) % (2 * math.pi) > d1:
        d1 -= 2 * math.pi
    R = math.dist(a, C)
    return [(C[0] + R * math.cos(t0 + d1 * k / (n + 1)), C[1] + R * math.sin(t0 + d1 * k / (n + 1))) for k in range(1, n + 1)], C



# --- wall pair across the axis below the axis hex (35 | 21), round the free axis node 1503: "pointed pods" - each half
# a pointed pod (two arcs meeting at a notable tip) from 1503 to the free side of its ring neighbour (1903; the mirror
# ends on 1910). Pointed, so it does not echo combo B's round half-rings at 1902 next door.
_pd = {'a0': (Lp(52.75, -0.85), 'small'), 'a1': (Lp(51.75, -1.25), 'small'), 'T': (Lp(51.05, -2.05), 'notable'),
       'a2': (Lp(51.75, -2.85), 'small'), 'a3': (Lp(52.75, -3.25), 'small')}
_x = lambda k: _pd[k][0]
_c1 = circ(_x('a0'), _x('a1'), _x('T')); _c2 = circ(_x('T'), _x('a2'), _x('a3'))
_pdl = [(1503, 'a0', None), ('a3', 1903, None), ('a0', 'a1', _c1), ('a1', 'T', _c1), ('T', 'a2', _c2), ('a2', 'a3', _c2)]
put(wall_pair({'x': (_pd, _pdl)}, 1503, 1502), 35, 21, 'pod')

# --- cell 35, new medium figure "leaf whorl" from the free side of corner 1900: a stem to a hub, three crescent leaves
# turning one way round it (each an outer arc through one node and an inner straight edge to its notable tip).
_p = road(1900); H35 = Lp(51.2, -15.2); _s1 = ((_p[0] + H35[0]) / 2, (_p[1] + H35[1]) / 2)
_wh = {'s1': (_s1, 'small'), 'h': (H35, 'small')}
_whl = [(1900, 's1', None), ('s1', 'h', None)]
for i, phi in enumerate((160, -80, 40)):
    T = pol(H35, 1.9, phi); A = at(H35, phi, 0.98, 0.74)
    _wh.update({f'a{i}': (A, 'small'), f't{i}': (T, 'notable')})
    cc = circ(H35, A, T); _whl += [('h', f'a{i}', cc), (f'a{i}', f't{i}', cc), ('h', f't{i}', None)]
CELLS[35]['whorl'] = (_wh, _whl)

# --- cell 21, the small arch at 1842 grows into a medium "bleeding heart": a drop lens hangs from its fork node n0
# outward, between the two arms (8 nodes).
add_lens(CELLS[21]['21_arch'], 'n0', 180, 2.6, 1.3, 'd')

# --- cell 12, medium figure "sprout" from the free inner side of 1849 (window-1 pass 2026-11-19: its leaf lens and the
# tendril crowding the acorn replaced by one fiddlehead rising from 1849 and curling towards the tree, on a shrinking orbit).
CELLS[12]['sprout'] = spiral(1849, 10, 2.4, 0.3, 1.4, 0.55, 180, 6, 62)



def wall_frame(wa, wb, inward=True):
    """Point maker along wall road wa -> wb: P(a, o) is a units along the wall from wa and o units off it, towards the
    tree centre if inward (else away from it)."""
    A, B = road(wa), road(wb)
    L_ = math.dist(A, B); u = ((B[0] - A[0]) / L_, (B[1] - A[1]) / L_); v = (-u[1], u[0])
    mid = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
    if (v[0] * mid[0] + v[1] * mid[1] > 0) == inward:
        v = (-v[0], -v[1])
    return lambda a, o: (A[0] + a * u[0] + o * v[0], A[1] + a * u[1] + o * v[1])


# --- wall pair across the ring chord 1918-1919 (94 | 12), from free node 1918: "almond" - each half an arc of three
# leaving 1918 along the road and bowing away from it, a notable at its open end; with its mirror the road
# runs through the middle of one almond open at its far end.
F18 = wall_frame(1918, 1919)
K18 = F18(1.6, -0.6); R18 = math.dist(K18, road(1918))
_al = {f'n{i}': (F18(1.6 + R18 * math.cos(math.radians(f)), -0.6 + R18 * math.sin(math.radians(f))),
                 'notable' if i == 2 else 'small') for i, f in enumerate((118, 88, 58))}
put(wall_pair({'x': (_al, [(1918, 'n0', None)] + arcs(['n0', 'n1', 'n2'], K18))}, 1918, 1919), 94, 12, 'almond')
# axis twins in cell 13: the sprout from free node 1859, the almond across chord 1928-1929 (88 | 13).
CELLS[13]['sprout'] = mirror_pieces({'x': CELLS[12]['sprout']}, W)['x']
CELLS[13]['almond'] = mirror_pieces({'x': CELLS[12]['almond']}, W)['x']
CELLS[88]['almond'] = mirror_pieces({'x': CELLS[94]['almond']}, W)['x']

# --- wall pair across spoke -28 (60 | 109) from free node 2007, next to the Wind cell 43, Wind flavour: "twin eddies" -
# each half a small curl spun off the spoke, its notable at the eye; mirrored, two eddies turn against each other.
_ed = spiral(2007, 105, 1.25, 0.0, 0.95, 0.6, 0, 4, 80)
put(wall_pair({'x': _ed}, 2007, 1913), 60, 109, 'eddy')

# --- window-2 pass 2026-11-19 (52 | 107): the spoke 1923-2008-1854 carried four plain chains (52's crooks at 1923 and 2008,
# 52's hook and 107's crook at 1854), so the crooks at 2008 and 1923 became one wall pair across the spoke: "split leaf" -
# each half an arc round a centre ON the spoke, from 2008 opening towards 1923, so the spoke runs through it as its midrib (the axis
# answer to the twin eddies at 2007 on the mirror spoke; a leaf, not a curl, beside 52's big tendril).
SL8_T, SL8_R, SL8_F = 1.75, 1.7, (150, 120, 90, 60, 30)      # centre along the spoke from 2008, radius, node angles off the spoke
_A, _B = road(2008), road(1923); _u = ((_B[0] - _A[0]) / math.dist(_A, _B), (_B[1] - _A[1]) / math.dist(_A, _B))
_w = (-_u[1], _u[0]); _c52 = Lp(69.3, 22.5)
if (_c52[0] - _A[0]) * _w[0] + (_c52[1] - _A[1]) * _w[1] < 0:
    _w = (-_w[0], -_w[1])
C8 = (_A[0] + SL8_T * _u[0], _A[1] + SL8_T * _u[1])
_h = {f'n{i}': ((C8[0] + SL8_R * (math.cos(math.radians(f)) * _u[0] + math.sin(math.radians(f)) * _w[0]),
                 C8[1] + SL8_R * (math.cos(math.radians(f)) * _u[1] + math.sin(math.radians(f)) * _w[1])),
                'notable' if i == len(SL8_F) - 1 else 'small') for i, f in enumerate(SL8_F)}
put(wall_pair({'x': (_h, [(2008, 'n0', None)] + arcs([f'n{i}' for i in range(len(SL8_F))], C8))}, 2008, 1923),
    52, 107, 'splitleaf')

# --- cell 60, new medium figure "dandelion clock" from the free outer side of 1914 into the empty middle: a two-node
# stem and a round seed head (a ring of six), notables at its two shoulders.
_p = road(1914); _s1 = at(_p, 195, 1.0); _s2 = at(_s1, 190, 1.0); D60 = at(_s2, 190, 1.95)
_dc = {'s1': (_s1, 'small'), 's2': (_s2, 'small')}
_dc.update({f'r{k}': (at(D60, 10 + 60 * k, 0.98), 'notable' if k in (2, 4) else 'small') for k in range(6)})
CELLS[60]['dandelion'] = (_dc, [(1914, 's1', None), ('s1', 's2', None), ('s2', 'r0', None)] +
                          arcs(['r0', 'r1', 'r2', 'r3', 'r4', 'r5', 'r0'], D60))

# --- cell 52, new medium figure "cherry pair" from the free outer side of 1924: a stalk forks into two stems, each to a
# small round cherry (a ring of three entered at its top, a notable at its bottom). (Not a twin of 60's dandelion.)
_p = road(1924); _s1 = at(_p, 180, 1.0); _f = at(_s1, 180, 0.9)
_ch = {'s1': (_s1, 'small'), 'f': (_f, 'small')}
_chl = [(1924, 's1', None), ('s1', 'f', None)]
for t, a in (('a', 150), ('b', 222)):
    Cc = at(_f, a, 1.25); back = a + 180
    sg = 1 if t == 'a' else -1                          # mirror-handed, so both notables hang at the bottom
    _ch.update({f'{t}0': (pol(Cc, 0.6, back), 'small'), f'{t}1': (pol(Cc, 0.6, back - sg * 120), 'small'),
                f'{t}2': (pol(Cc, 0.6, back - sg * 240), 'notable')})
    _chl += [('f', f'{t}0', None)] + arcs([f'{t}0', f'{t}1', f'{t}2', f'{t}0'], Cc)
CELLS[52]['cherries'] = (_ch, _chl)

S72, S71, S21 = 10, -10, 4
# --- small catalogue pieces (rules 3.10 C3) on free road-node sides, each facing open space; families differ from
# their neighbours' (C8). A piece at spoke node 2002 (88) found no family that clears the fiddlehead and tulip; left out.
SMALLS = [  # (name, road, family, style, stem, ang, turn, hand)
    ('72 crescent', 1916, 'Crescent', 'bow in', 1.0, S72, 0, False),
    ('71 hook', 1926, 'Hook', 'bow in', 1.0, S71, 0, False),
    ('21 crescent', 1908, 'Crescent', 'bow out', 1.0, S21, 0, False),
]
for row in SMALLS:
    fill_rows(CELLS[int(row[0].split()[0])], [row])

# --- cell 39, new medium figure "ivy leaf" from the free side of corner 1906, along the spoke: a stem to the leaf's
# base, its outline a ring of six (two side lobes, two notches and the tip; notables at the tip and notches), arcs bowing out.
_p = road(1906); AX39 = 141
_s1 = at(_p, AX39, 1.0); O39i = at(_p, AX39, 2.0 + 1.5)
_ivk = (('B', 0, 1.5, 'small'), ('R', 75, 1.75, 'small'), ('r', 128, 1.25, 'notable'), ('T', 180, 1.95, 'notable'),
        ('l', -128, 1.25, 'notable'), ('L', -75, 1.75, 'small'))
_iv = {'s1': (_s1, 'small')}
_iv.update({k: (pol(O39i, rho, AX39 + 180 + phi), kd) for k, phi, rho, kd in _ivk})
_ivl = [(1906, 's1', None), ('s1', 'B', None)]
_ord = ['B', 'R', 'r', 'T', 'l', 'L', 'B']
_ivl += [(_ord[i], _ord[i + 1], bow_centre(_iv[_ord[i]][0], _iv[_ord[i + 1]][0], 0.12, O39i)) for i in range(6)]
CELLS[39]['ivy'] = (_iv, _ivl)

# --- wall pairs across the outer ring into the rim, from free nodes 1853 and 1843 (not twins of each other):
#   107 | rim, chord 1853-1854: "mirrored leaf" - a stalk and a leaf lens leaning towards +theta, reflected outside.
#   109 | rim, chord 1843-1844 (next to the Wind cell 43, Wind flavour): "gust curl" - a curl spun towards -theta, its
#   notable at the eye, reflected outside.
_p = road(1853); _s = at(_p, 50, 1.0)
_la, _lb, _lt = lens_pts(_s, 45, 1.9, 0.5)
_ml = {'s1': (_s, 'small'), 'a': (_la, 'small'), 'b': (_lb, 'small'), 't': (_lt, 'notable')}
_mll = [(1853, 's1', None)]
for x in ('a', 'b'):
    cc = circ(_s, _ml[x][0], _lt); _mll += [('s1', x, cc), (x, 't', cc)]
put(wall_pair({'x': (_ml, _mll)}, 1853, 1854), 107, 905, 'leaf', 'leaf_rim')
put(wall_pair({'x': spiral(1843, -35, 1.9, 0.0, 1.0, 0.55, 205, 4, -80)}, 1843, 1844), 109, 905, 'gust', 'gust_rim')


def aim(P, Q):
    """The frame angle at P (0 = towards the tree centre, + = towards +theta) that points at Q."""
    r = math.hypot(*P); i = (-P[0] / r, -P[1] / r); t = (-i[1], i[0]); d = (Q[0] - P[0], Q[1] - P[1])
    return math.degrees(math.atan2(d[0] * t[0] + d[1] * t[1], d[0] * i[0] + d[1] * i[1]))


def grow_lens(cell, piece, base, target, length, width, tag='g'):
    """Grow a leaf lens on an existing piece from its node `base` towards the land-local point `target` (r, th)."""
    nodes = CELLS[cell][piece][0]
    add_lens(CELLS[cell][piece], base, aim(nodes[base][0], Lp(*target)), length, width, tag)


def grow_curl(cell, piece, base, target, rho, turn=1, steps=3, step=72, shrink=0.16, tag='q'):
    """Grow a tendril curl on an existing piece (window-1 pass 2026-11-19, to vary the grown leaf lenses): from its node
    `base`, setting off towards the land-local point `target` (r, th) or along the frame angle `target`, `steps` nodes on a shrinking orbit round a centre
    `rho` to the side (turn +1 = curling to the left of the heading, -1 = to the right), the last a notable."""
    nodes, links = CELLS[cell][piece]
    P = nodes[base][0]
    d = direction(P, target if isinstance(target, (int, float)) else aim(P, Lp(*target)))
    n = (-d[1] * turn, d[0] * turn)                       # the side the curl turns to
    K = (P[0] + rho * n[0], P[1] + rho * n[1])
    a0 = math.atan2(P[1] - K[1], P[0] - K[0]); s = math.radians(step) * turn
    pt = lambda t, rr: (K[0] + rr * math.cos(a0 + s * t), K[1] + rr * math.sin(a0 + s * t))
    prev, pxy = base, P
    for k in range(1, steps + 1):
        xy = pt(k, rho * (1 - shrink * k)); key = f'{tag}{k}'
        nodes[key] = (xy, 'notable' if k == steps else 'small')
        links.append((prev, key, circ(pxy, pt(k - 0.5, rho * (1 - shrink * (k - 0.5))), xy)))
        prev, pxy = key, xy


# --- small pieces grown into mediums, each by a leaf lens into the free space beside it (varied sizes, so no two
# grown copies are one drawing): the fern curl in 111 gets a leaf, the arch in 112 a drop (smaller than 21's), the
# wheel in 64 a leaf towards the axis, the tadpole at 1899 (72) a leaf, the crooks at 1911 (109) and 1921 (107) a leaf
# each, the ring in 25 a leaf along the border. Window-1 pass 2026-11-19, to vary the one move: the ring in 67 grows a
# tendril curl instead (grow_curl), as do the willow's first branch in 21, the morning glory in 25 and the crook at
# 1901 (72).
grow_lens(111, 'curl', 'f2', (36.0, 26.3), 1.9, 0.95)
grow_lens(112, '112_arch', 'n0', (36.6, -30.4), 2.2, 0.8)
grow_curl(67, '67_ring', 'n1', (37.8, -6.0), 1.0, -1)
grow_lens(64, '64_wheel', 'n3', (34.8, 3.0), 2.0, 0.95)
grow_lens(72, '72_tadpole', 'n2', (58.9, -21.6), 1.9, 0.9)
grow_lens(109, '109_crook', 'n0', (67.2, -34.5), 1.8, 0.85)
grow_lens(107, '109_crook', 'n0', (67.3, 34.4), 2.1, 1.0)
grow_lens(25, '25_ring', 'n3', (46.2, 33.6), 1.8, 0.85)
# second round of grown smalls (each into the free space beside it): 39's crescent at 1924 a leaf (the crook at 1908 (71)
# too, until the window-2 pass made it a curl, the mirror of 72's); the willow's first weeping branch in 21 and the crook at 1901 (72) a curl (window-1 pass).
grow_lens(39, '39_crescent2', 'n2', (62.4, 27.0), 1.9, 0.9)
grow_curl(21, 'weep1', 's3', (48.5, 12.5), 0.9, 1)
grow_curl(25, 'morningglory', 's3', 40, 1.0, 1)          # the morning glory's tendril (was a leaf lens)
grow_curl(72, '72_crook', 'n2', (56.9, -15.9), 1.0, -1)
grow_curl(71, '72_crook', 'n2', (56.9, 15.9), 1.0, 1)           # w2 (21 | 71): was a leaf lens facing 21's willow leaf across 1907-1908

# --- window-3 pass 2026-11-19 (88 | 71 | 21): the strip of 88 beside wall node 2002 was empty through three passes (no catalogue
# family at 2002 clears the fiddlehead and tulip), so the small crook at 1908 above it became a medium "hanging leaf": a
# stalk of two bending off 1908 and a long leaf lens hanging down the strip towards the tulip, its tip a notable.
HL_T, HL_L, HL_W = (60.4, 9.55), 3.6, 1.15              # where the leaf points (r, th), its length, its width
_s0, _s1 = Lp(55.05, 10.35), Lp(56.3, 9.95)
_hc = circ(road(1908), _s0, _s1)
_la, _lb, _lt = lens_pts(_s1, aim(_s1, Lp(*HL_T)), HL_L, HL_W / 2)
_hl = {'s0': (_s0, 'small'), 's1': (_s1, 'small'), 'a': (_la, 'small'), 'b': (_lb, 'small'), 't': (_lt, 'notable')}
_hll = [(1908, 's0', _hc), ('s0', 's1', _hc)]
for x in ('a', 'b'):
    cc = circ(_s1, _hl[x][0], _lt); _hll += [('s1', x, cc), (x, 't', cc)]
CELLS[88]['hangleaf'] = (_hl, _hll)

# --- wall pair across spoke -23 (112 | 67) from 1831, under the split leaf: "rising leaves" - a stalk node and a leaf
# lens leaning away from the spoke; mirrored, a V of two leaves opening towards the split leaf.
RL_A, RL_AX, RL_L = -40, -45, 1.65
RL2_A, RL2_AX, RL2_L = 42, 28, 1.7
_p = road(1831); _s = at(_p, RL_A, 1.0)
_la, _lb, _lt = lens_pts(_s, RL_AX, RL_L, 0.5)
_rl = {'s1': (_s, 'small'), 'a': (_la, 'small'), 'b': (_lb, 'small'), 't': (_lt, 'notable')}
_rll = [(1831, 's1', None)]
for x in ('a', 'b'):
    cc = circ(_s, _rl[x][0], _lt); _rll += [('s1', x, cc), (x, 't', cc)]
put(wall_pair({'x': (_rl, _rll)}, 1831, 1819), 112, 67, 'risingleaf')
# its twin across spoke +23 (111 | 64) from 1838, shorter and steeper so it clears the fern curl in 111.
_p = road(1838); _s = at(_p, RL2_A, 1.0)
_la, _lb, _lt = lens_pts(_s, RL2_AX, RL2_L, 0.5)
_rl = {'s1': (_s, 'small'), 'a': (_la, 'small'), 'b': (_lb, 'small'), 't': (_lt, 'notable')}
_rll = [(1838, 's1', None)]
for x in ('a', 'b'):
    cc = circ(_s, _rl[x][0], _lt); _rll += [('s1', x, cc), (x, 't', cc)]
put(wall_pair({'x': (_rl, _rll)}, 1838, 1825), 111, 64, 'risingleaf')

# the fir in 31 grows on its own orbits: both tiers reach further on the open +theta side (round its tip A31), towards
# the empty corner by the spoke - a fir leaning to the light (7 -> 9 nodes).
_fn, _fl = CELLS[31]['fir']
_fn['L1']= (_fn['L1'][0], 'small'); _fn['L1b'] = (pol(A31, 1.9, 74), 'notable'); _fn['L2b'] = (pol(A31, 3.3, 60), 'notable')
_fl += [('L1', 'L1b', A31), ('L2', 'L2b', A31)]


# ======================= RIM FIGURES (cell 905, rim pass 2026-11-19, design/dao-do/cells/rim-brief.md) ================
# The rim's large figures, every position chosen by hand. All on orbits round their own centres (pol: 0 = towards the
# tree centre, + = towards +theta).
R905 = CELLS[905]

# --- "hồ lô" (the gourd flask) on the axis, hanging from the vine's open end 1372 (r 94): a stopper (a lid arc of five
# on an orbit round the neck, notables at its ends), a neck ring of six, a waist knot (notable), a body ring of ten with a
# highlight inside it on the -theta side (an arc from ring node 216 to 324, a crescent against the ring), and one cord
# from the knot round the body on an outer orbit to a tassel notable on the +theta side. The two rings stay apart.
# 28 nodes, 7 notables.
G_NR, G_BR, G_LID, G_HI = 1.45, 2.9, 2.25, 1.95             # neck, body radius; lid orbit round the neck; highlight orbit
G_ST = 96.1                                                # lid centre (r)
GN = Lp(G_ST + G_LID, 0)                                   # neck centre
G_W = G_ST + G_LID + G_NR + 0.85                           # waist knot (r)
GB = Lp(G_W + 0.85 + G_BR, 0)                              # body centre
_g = {'st': (pol(GN, G_LID, 0), 'small'),
      'la': (pol(GN, G_LID, -22), 'small'), 'lidL': (pol(GN, G_LID, -44), 'notable'),
      'lb': (pol(GN, G_LID, 22), 'small'), 'lidR': (pol(GN, G_LID, 44), 'notable')}
_g.update({f'n{a}': (pol(GN, G_NR, a), 'small') for a in range(0, 360, 60)})
_g['w'] = (Lp(G_W, 0), 'notable')
_g.update({f'b{a}': (pol(GB, G_BR, a), 'notable' if a in (108, 180) else 'small') for a in range(0, 360, 36)})
G_HC = circ(_g['b216'][0], pol(GB, G_HI, 270), _g['b324'][0])      # the highlight: an arc inside the body, b216 to b324
_g.update({k: (xy, 'notable' if k == 'h2' else 'small')
           for k, xy in zip(('h1', 'h2', 'h3'), arc_between(_g['b216'][0], _g['b324'][0], G_HC, 3))})
_k1 = at(Lp(G_W, 0), 90, 1.6)                              # the knot's cord node, beside the waist
G_CR = math.dist(_k1, GB); G_CA = math.degrees(math.asin(1.6 / G_CR))
_g.update({'k1': (_k1, 'small'), 'k2': (pol(GB, G_CR, G_CA + 30), 'small'),
           'tas': (pol(GB, G_CR, G_CA + 60), 'notable')})
_gl = [(1372, 'st', None), ('st', 'la', GN), ('la', 'lidL', GN), ('st', 'lb', GN), ('lb', 'lidR', GN), ('st', 'n0', None)]
_gl += [(f'n{a}', f'n{(a + 60) % 360}', GN) for a in range(0, 360, 60)]
_gl += [('n180', 'w', None), ('w', 'b0', None), ('w', 'k1', None), ('k1', 'k2', GB), ('k2', 'tas', GB)]
_gl += [(f'b{a}', f'b{(a + 36) % 360}', GB) for a in range(0, 360, 36)]
_gl += [('b216', 'h1', G_HC), ('h1', 'h2', G_HC), ('h2', 'h3', G_HC), ('h3', 'b324', G_HC)]
R905['holo'] = (_g, _gl)


# --- "lanterns" (đèn lồng), a mirrored pair flanking the vine, hanging from outer-ring nodes 1861 / 1851 (theta +-5.5): a
# hanger node, a top and a bottom cap (bars of three), two side ribs bowing out (arcs of five, cap to cap, notables at the
# widest point), a centre rib through the light (notable) to the bottom cap's knot (notable) and a jade bead (a ring of
# four, notable at its foot) below. 20 nodes, 5 notables each.
def lantern(rid, rc):
    """A lantern hanging outward from road node rid, its centre at land radius rc on rid's ray."""
    p = road(rid); O = at(p, 180, rc - math.hypot(*p))
    def X(u, w):                                           # u towards +theta, w outward, in O's frame
        return at(O, 180, w, -u)
    H, CW, BW = 2.2, 1.0, 2.0                              # half height, cap half width, rib bulge
    cu = (BW * BW - CW * CW - H * H) / (2 * (BW - CW))     # right rib's circle centre (u; negative = beyond the axis)
    R = BW - cu; ft = math.atan2(-H, CW - cu)              # its radius; the top cap end seen from it (u, w angles)
    n = {'h1': (X(0, -H - 1.1), 'small'), 'Tc': (X(0, -H), 'small'), 'c1': (X(0, -H / 2), 'small'),
         'Lc': (X(0, 0), 'notable'), 'c2': (X(0, H / 2), 'small'), 'Bm': (X(0, H), 'notable'),
         'd0': (X(0, H + 1.0), 'small'), 'd90': (X(0.6, H + 1.6), 'small'), 'd180': (X(0, H + 2.2), 'notable'),
         'd270': (X(-0.6, H + 1.6), 'small')}
    D = X(0, H + 1.6)                                      # the bead under the bottom cap
    l = [(rid, 'h1', None), ('h1', 'Tc', None), ('Tc', 'c1', None), ('c1', 'Lc', None), ('Lc', 'c2', None), ('c2', 'Bm', None),
         ('Bm', 'd0', None), ('d0', 'd90', D), ('d90', 'd180', D), ('d180', 'd270', D), ('d270', 'd0', D)]
    for sg, s in ((-1, 'L'), (1, 'R')):
        C = X(sg * cu, 0)
        def rib(t):                                        # t 0 = top cap end, 0.5 = widest, 1 = bottom cap end
            f = ft * (1 - 2 * t)
            return X(sg * (cu + R * math.cos(f)), R * math.sin(f))
        n[f'T{s}'] = (X(sg * CW, -H), 'small'); n[f'B{s}'] = (X(sg * CW, H), 'small')
        n[f'{s}1'] = (rib(0.25), 'small'); n[f'{s}m'] = (rib(0.5), 'notable'); n[f'{s}2'] = (rib(0.75), 'small')
        l += [('Tc', f'T{s}', None), ('Bm', f'B{s}', None), (f'T{s}', f'{s}1', C), (f'{s}1', f'{s}m', C), (f'{s}m', f'{s}2', C),
              (f'{s}2', f'B{s}', C)]
    return n, l


R905['lantern_e'] = lantern(1861, 78.6)
R905['lantern_w'] = mirror_pieces({'x': R905['lantern_e']}, W)['x']


# --- "four-point star", an abstract mirrored pair from outer-ring nodes 1856 / 1846 (theta +-20): a four-point star whose
# sides are arcs bowing in (tip, mid node, inner corner), an inner ring of eight through the inner corners, and a cross
# of four spokes from the ring's nodes between the corners to a centre notable. Entered by a stem node at the tip facing
# the tree centre; notables at the other three tips, the centre and the two far inner corners. 22 nodes, 6 notables each.
def star4(rid, stem, RT=5.0, RI=2.5, bow=0.1):
    p = road(rid); O = at(p, 180, 2 * stem + RT)
    n = {'o': (O, 'notable'), 's1': (at(p, 180, stem), 'small')}
    l = [(rid, 's1', None), ('s1', 't0', None)]
    for a in (0, 90, 180, 270):
        n[f't{a}'] = (pol(O, RT, a), 'small' if a == 0 else 'notable')
        n[f'r{a}'] = (pol(O, RI, a), 'small')
        l.append((f'r{a}', 'o', None))
    for a in (45, 135, 225, 315):
        n[f'i{a}'] = (pol(O, RI, a), 'notable' if a in (135, 225) else 'small')
        l += [(f'r{a - 45}', f'i{a}', O), (f'i{a}', f'r{(a + 45) % 360}', O)]
    for a in (45, 135, 225, 315):
        for t in (a - 45, (a + 45) % 360):
            T, I = n[f't{t}'][0], n[f'i{a}'][0]
            mx, my = (T[0] + I[0]) / 2, (T[1] + I[1]) / 2
            k = bow * math.dist(T, I) / math.dist((mx, my), O)
            M = (mx + (O[0] - mx) * k, my + (O[1] - my) * k)   # the chord's midpoint pulled towards the centre
            cc = circ(T, M, I); key = f'm{t}_{a}'
            n[key] = (M, 'small'); l += [(f't{t}', key, cc), (key, f'i{a}', cc)]
    return n, l


R905['star_e'] = star4(1856, 1.2)
R905['star_w'] = mirror_pieces({'x': R905['star_e']}, W)['x']


# Hub cell 79 belongs to Chaos (swirls into the centre, user 2026-11-18): drawn in design/dao-do/cells/chaos.py.
CELLS[79] = {}
