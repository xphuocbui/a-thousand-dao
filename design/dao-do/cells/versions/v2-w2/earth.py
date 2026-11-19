"""Earth (axis 72): mountains, terraces, a gate or castle. Every cell placed by hand, cell by cell (BRIEF.md).

Land-local polar points: E(r, th) = L(r, th, 'earth'); th + is towards +theta (right in the axis-down render).
Angles for orbit()/place(): 0 = towards the tree centre (up in the render), 90 = +theta (right), 180 = outward (down).
Pieces never link to each other; each hangs from road nodes only (ints).
"""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
from celllib import L, orbit, road, fill_rows, mirror_pieces, bow_centre  # noqa: E402

THEME = 'earth'


def E(r, th):
    return L(r, th, 'earth')


def chain(entry, pts, arc=None):
    """A chain hung from road node `entry`: pts [(xy, kind)], consecutive links (arc centre `arc` or straight)."""
    nodes = {f'n{i}': p for i, p in enumerate(pts)}
    links = [(entry, 'n0', None)] + [(f'n{i}', f'n{i + 1}', arc) for i in range(len(pts) - 1)]
    return nodes, links


def graph(entries, pts, edges):
    """A figure: pts {key: (xy, kind)}, entries [(road id, key)], edges [(k1, k2, arc centre or None)]."""
    return pts, [(r, k, None) for r, k in entries] + list(edges)


def piece_set(**pieces):
    return dict(pieces)


# ---- orbit helpers for the consolidated figures (2026-11-18 consolidation pass) ------------------------------------
def on(O, rho, angs, kinds, pre):
    """Nodes on a circle of radius rho round O at the angles `angs` (orbit frame: 0 = up, 90 = +theta)."""
    return {f'{pre}{i}': (orbit(O, rho, a), k) for i, (a, k) in enumerate(zip(angs, kinds))}


def run(keys, arc=None):
    """Consecutive links along `keys`, as arcs round `arc` (the nodes' common centre) or straight."""
    return [(keys[i], keys[i + 1], arc) for i in range(len(keys) - 1)]


def ks(pre, n, start=0):
    return [f'{pre}{i}' for i in range(start, start + n)]


def spiral(O, rho0, rho1, ang0, sweep, n, notables, pre='p'):
    """A spiral path round O: n nodes from (rho0, ang0) to (rho1, ang0 + sweep), radius and angle linear in the
    step; nodes listed in `notables` (indices) are notables. Straight links (a spiral has no common centre)."""
    pts = {f'{pre}{i}': (orbit(O, rho0 + (rho1 - rho0) * i / (n - 1), ang0 + sweep * i / (n - 1)),
                         'notable' if i in notables else 'small') for i in range(n)}
    return pts, run(ks(pre, n))


def mountain_road(O, entry):
    pts, links = spiral(O, 3.0, 1.15, -28, -290, 9, (4,))
    pts['top'] = (O, 'notable')
    return pts, [(entry, 'p0', None)] + links + [('p8', 'top', None)]


def castle(O, entry, ang_in, rho_t=1.75, rho_w=1.0, notable_towers=(2, 3)):
    """A castle seen from above: eight nodes round O at 45-degree steps, the gate (w0, a wall node facing `ang_in`)
    and walls (even) on rho_w, towers (odd) on rho_t, straight links; notables on the towers `notable_towers`
    (1-based round from the gate)."""
    angs = [ang_in + 45 * i for i in range(8)]
    pts = {f'w{i}': (orbit(O, rho_t if i % 2 else rho_w, a),
                     'notable' if i % 2 and (i + 1) // 2 in notable_towers else 'small') for i, a in enumerate(angs)}
    return pts, [(entry, 'w0', None)] + run(ks('w', 8) + ['w0'])


def mountain_gate(O, ang_top, entry, rho_o=2.0, rho_i=1.0):
    """A double arch (the gate of a mountain pass): an outer arc of five and an inner arc of three round O, both
    over 180 degrees centred on `ang_top`, joined at their feet; the entry at the outer crest, notables on the inner
    arc's feet (the gateposts)."""
    po = on(O, rho_o, [ang_top + a for a in (-90, -45, 0, 45, 90)], ['small'] * 5, 'o')
    pi = on(O, rho_i, [ang_top + a for a in (-90, 0, 90)], ['notable', 'small', 'notable'], 'i')
    pts = dict(po); pts.update(pi)
    return pts, ([(entry, 'o2', None)] + run(ks('o', 5), O) + run(ks('i', 3), O) +
                 [('o0', 'i0', None), ('o4', 'i2', None)])


def lens(A, B, h, n, entry, at, pre=''):
    """A standing stone: two arcs through tips A and B bulging h either side (a vesica), n inner nodes per arc at even
    angular steps round each arc's own centre; notables at both tips; the entry joins inner node `at` of the arc
    nearer the entry road node."""
    mx, my = (A[0] + B[0]) / 2, (A[1] + B[1]) / 2
    dx, dy = B[0] - A[0], B[1] - A[1]
    c = math.hypot(dx, dy) / 2
    ux, uy = dx / (2 * c), dy / (2 * c)
    R = (c * c + h * h) / (2 * h)
    pts = {pre + 'tA': (A, 'notable'), pre + 'tB': (B, 'notable')}
    links = []
    for sd, sg in (('l', 1), ('r', -1)):
        nx, ny = -uy * sg, ux * sg                           # the side the arc bulges to
        O = (mx - nx * (R - h), my - ny * (R - h))
        a0 = math.atan2(A[1] - O[1], A[0] - O[0]); a1 = math.atan2(B[1] - O[1], B[0] - O[0])
        da = (a1 - a0 + math.pi) % (2 * math.pi) - math.pi
        keys = [pre + 'tA'] + [f'{pre}{sd}{i}' for i in range(1, n + 1)] + [pre + 'tB']
        for i in range(1, n + 1):
            a = a0 + da * i / (n + 1)
            pts[f'{pre}{sd}{i}'] = ((O[0] + R * math.cos(a), O[1] + R * math.sin(a)), 'small')
        links += run(keys, O)
    side = min('lr', key=lambda sd: math.dist(pts[f'{pre}{sd}{at}'][0], road(entry)))
    return pts, [(entry, f'{pre}{side}{at}', None)] + links


def caldera(O, entry, ang_in, rho=1.3, notables=(3,)):
    """A crater seen from above: a rim of six round O (step 60, the entry at the rim node facing `ang_in`) and a vent
    notable at O joined to the two rim nodes either side of the far one; rim notables at the indices `notables`."""
    pts = on(O, rho, [ang_in + 60 * i for i in range(6)], ['notable' if i in notables else 'small' for i in range(6)], 'c')
    pts['vent'] = (O, 'notable')
    return pts, [(entry, 'c0', None)] + run(ks('c', 6) + ['c0'], O) + [('c2', 'vent', None), ('c4', 'vent', None)]


def band(O, rho_o, angs_o, rho_i, angs_i, entry, entry_key, notables):
    """A terrace band: an outer arc (nodes 'o') and an inner arc (nodes 'i') round O, closed at both ends, arc links
    round O; the entry joins `entry_key`; `notables` lists the notable keys."""
    pts = on(O, rho_o, angs_o, ['small'] * len(angs_o), 'o')
    pts.update(on(O, rho_i, angs_i, ['small'] * len(angs_i), 'i'))
    for k in notables:
        pts[k] = (pts[k][0], 'notable')
    no, ni = len(angs_o), len(angs_i)
    return pts, ([(entry, entry_key, None), ('o0', 'i0', None), (f'o{no - 1}', f'i{ni - 1}', None)] +
                 run(ks('o', no), O) + run(ks('i', ni), O))


def henge(O, entry, ang_in, rho=1.75, n=7, notables=(2, 5)):
    """A stone circle: n standing stones round O (even steps, stone 0 facing `ang_in` takes the entry) and an altar
    notable at O joined to the two stones opposite the entry; stone notables at the indices `notables`."""
    st = 360 / n
    pts = on(O, rho, [ang_in + st * i for i in range(n)], ['notable' if i in notables else 'small' for i in range(n)], 's')
    pts['altar'] = (O, 'notable')
    far = (n // 2, (n + 1) // 2) if n % 2 else (n // 2,)
    return pts, ([(entry, 's0', None)] + run(ks('s', n) + ['s0'], O) + [(f's{k}', 'altar', None) for k in far])


def ladder(O, rho_o, rho_i, angs, entry, notables):
    """Terrace steps bent on an orbit: rungs at the angles `angs`, each joining an outer node ('o', rho_o) and an
    inner node ('i', rho_i) round O; both rails arc round O; the entry joins o0; `notables` lists notable keys."""
    n = len(angs)
    pts = on(O, rho_o, angs, ['small'] * n, 'o')
    pts.update(on(O, rho_i, angs, ['small'] * n, 'i'))
    for k in notables:
        pts[k] = (pts[k][0], 'notable')
    return pts, ([(entry, 'o0', None)] + run(ks('o', n), O) + run(ks('i', n), O) +
                 [(f'o{k}', f'i{k}', None) for k in range(n)])


def peak_fan(H, rho, ang_c, entry, stem_ang, stem=1.1, mid='notable'):
    """A peak seen from above: a summit hub at H on a one-node stem from `entry`, a base arc of five round H (30-degree
    steps centred on `ang_c`) and two ridges from the hub to the second and fourth base nodes; notables at the base
    ends (and middle, unless `mid` is 'small')."""
    pts = on(H, rho, [ang_c + a for a in (-60, -30, 0, 30, 60)], ['notable', 'small', mid, 'small', 'notable'], 'b')
    pts['hub'] = (H, 'small'); pts['stem'] = (orbit(H, stem, stem_ang), 'small')
    return pts, ([(entry, 'stem', None), ('stem', 'hub', None), ('hub', 'b1', None), ('hub', 'b3', None)] +
                 run(ks('b', 5), H))


def switchback(O, rho_o, angs_o, rho_i, angs_i, entry):
    """A mountain trail winding up to a summit: from `entry` along an outer arc ('o', angles `angs_o`), up a rung to
    the inner arc ('i', angles `angs_i`, walked back the other way) and on to a summit notable at O; arcs round O;
    notables at the turn (the last outer node) and the summit."""
    no, ni = len(angs_o), len(angs_i)
    pts = on(O, rho_o, angs_o, ['small'] * (no - 1) + ['notable'], 'o')
    pts.update(on(O, rho_i, angs_i, ['small'] * ni, 'i'))
    pts['top'] = (O, 'notable')
    return pts, ([(entry, 'o0', None), (f'o{no - 1}', 'i0', None), (f'i{ni - 1}', 'top', None)] +
                 run(ks('o', no), O) + run(ks('i', ni), O))


def cirque(O, entry, ang_in, rho=1.15, rho_p=2.0, peaks=(2, 3)):
    """A cirque (a ring of peaks round a high basin): five ring nodes round O (step 72, ring node 0 facing `ang_in`
    takes the entry) and peak notables on rho_p between ring nodes k and k + 1 for k in `peaks`, each joined to both
    (2026-11-19: the peaks were single straight spikes off one ring node)."""
    angs = [ang_in + 72 * i for i in range(5)]
    pts = on(O, rho, angs, ['small'] * 5, 'r')
    links = [(entry, 'r0', None)] + run(ks('r', 5) + ['r0'], O)
    for k in peaks:
        pts[f'p{k}'] = (orbit(O, rho_p, angs[k] + 36), 'notable')
        links += [(f'r{k}', f'p{k}', None), (f'r{(k + 1) % 5}', f'p{k}', None)]
    return pts, links


def ridges(H, entry, ang_c, spread=45, rho=1.2):
    """A mountain spur seen from above: a hub at H and three ridges of two nodes each at `ang_c` and `ang_c` +-
    `spread` (rho and 2 rho from H, straight links), the ridge ends notables; the entry joins the hub."""
    pts, links = {'hub': (H, 'small')}, [(entry, 'hub', None)]
    for j, a in enumerate((ang_c - spread, ang_c, ang_c + spread)):
        pts[f'r{j}a'] = (orbit(H, rho, a), 'small'); pts[f'r{j}b'] = (orbit(H, 2 * rho, a), 'notable')
        links += [('hub', f'r{j}a', None), (f'r{j}a', f'r{j}b', None)]
    return pts, links


def bailey(O, rho, angs, entry, notables):
    """An outer bailey wall on one orbit round O (a pyramid's or keep's own centre): nodes at the angles `angs`, arc
    links round O, hung by its first node from `entry`; notables at the indices `notables` (review pass 2026-11-19:
    replaces the square-wave rampart)."""
    pts = on(O, rho, angs, ['notable' if i in notables else 'small' for i in range(len(angs))], 'm')
    return pts, [(entry, 'm0', None)] + run(ks('m', len(angs)), O)


def terrace_fan(entry, O, ang_c, rho_i=1.3, rho_o=2.5, notables=('o0', 'o3')):
    """Hillside terraces off one hub: a hub node at O, an inner arc of three (step 50) and an outer arc of four (step
    32) round O, centred on `ang_c`, closed at both ends into one terrace band; the hub joins the inner middle."""
    pts = on(O, rho_i, [ang_c - 50, ang_c, ang_c + 50], ['small'] * 3, 'i')
    pts.update(on(O, rho_o, [ang_c - 48, ang_c - 16, ang_c + 16, ang_c + 48], ['small'] * 4, 'o'))
    for k in notables:
        pts[k] = (pts[k][0], 'notable')
    pts['hub'] = (O, 'small')
    return pts, ([(entry, 'hub', None), ('hub', 'i1', None), ('i0', 'o0', None), ('i2', 'o3', None)] +
                 run(ks('i', 3), O) + run(ks('o', 4), O))


CELLS = {}

# =====================================================================================================================
# Combo A, "the mountain gate" (split figure across the axis, cells 87 and 89): two castle towers stand on the
# 64.3 ring either side of the axis road, which runs between them as the gateway. Each tower is a ladder loop with a
# pointed roof whose apex is a notable; the towers mirror each other. The cells round them differ.
# =====================================================================================================================
def tower_left():
    """A two-floor tower: base of three, two rungs, top pair, pointed roof (apex notable) and a notable window."""
    pts = {'b0': (E(63.0, -3.2), 'small'), 'bl': (E(62.9, -4.8), 'small'), 'br': (E(62.9, -1.6), 'small'),
           'ml': (E(61.0, -4.8), 'small'), 'mr': (E(61.0, -1.6), 'small'),
           'ul': (E(59.1, -4.8), 'small'), 'ur': (E(59.1, -1.6), 'small'),
           'tl': (E(57.4, -4.8), 'small'), 'tr': (E(57.4, -1.6), 'small'), 'apex': (E(55.8, -3.2), 'notable'),
           'win': (E(60.05, -3.2), 'notable')}
    edges = [('b0', 'bl', None), ('b0', 'br', None), ('bl', 'ml', None), ('br', 'mr', None), ('ml', 'ul', None),
             ('mr', 'ur', None), ('ul', 'tl', None), ('ur', 'tr', None), ('tl', 'apex', None), ('tr', 'apex', None),
             ('ml', 'win', None), ('mr', 'win', None)]
    return graph([(1680, 'b0')], pts, edges)


# ---- cell 87 (middle band, th -11..0): the left tower; beside it a standing stone off the spoke node -------------
# consolidated 2026-11-18: the Zigzag stair (1662) and the Tadpole (1953) became one big standing stone, a lens of
# ten along the band beside the tower, notables at both tips, hung from the spoke node 1953
c87 = {'tower': tower_left(), 'stone': lens(E(55.4, -8.4), E(61.7, -8.4), 0.95, 4, 1953, 2)}
fill_rows(c87, [
    ('foot',       1679, 'Diamond', 'round', 1.2, -10, 0, False),
])
CELLS[87] = c87

# ---- cell 89 (th 0..11): the right tower, the mirror of cell 87 (combo A), with its side pieces changed so the two
# cells are not stamps: 2026-11-18 the Hook (1669) and the Crescent (1954) became hillside terraces off 1954 --------
c89 = mirror_pieces({'tower': c87['tower'], 'foot': c87['foot']}, 'earth')
c89['terraces'] = terrace_fan(1954, orbit(road(1954), 1.1, -90), -90)
CELLS[89] = c89

# =====================================================================================================================
# Combo B, "the terraced peak" (junction figure on road node 1659, where the 53.9 ring meets the -23 spoke): one
# set of circles round 1659. In cell 24 above, two terraces: an inner arc hung from 1659 by a short spoke with
# notables at both ends, and an outer arc bridging the ring road nodes 1658 and 1660 with a notable at its crest.
# In cells 40 and 78 below, one petal arc each, hung from 1659, notables at both tips.
# =====================================================================================================================
PEAK = road(1659)


def arc_nodes(O, rho, angs, kinds):
    return {f'a{i}': (orbit(O, rho, a), k) for i, (a, k) in enumerate(zip(angs, kinds))}


def peak_inner():
    angs = (-60, -30, 0, 30, 60); kinds = ('notable', 'small', 'small', 'small', 'notable')
    pts = arc_nodes(PEAK, 1.9, angs, kinds)
    return pts, [(1659, 'a2', None)] + [(f'a{i}', f'a{i + 1}', PEAK) for i in range(4)]


def peak_outer():
    angs = (-76, -57, -38, -19, 0, 19, 38, 57, 76)
    kinds = ['small'] * 9; kinds[4] = 'notable'
    pts = arc_nodes(PEAK, 3.5, angs, kinds)
    return pts, [(1658, 'a0', None), ('a8', 1660, None)] + [(f'a{i}', f'a{i + 1}', PEAK) for i in range(8)]


def peak_petal(side):                # side -1: cell 40 (towards -theta), +1: cell 78
    angs = [side * a for a in (112, 135, 158)]
    pts = arc_nodes(PEAK, 2.6, angs, ('notable', 'small', 'notable'))
    return pts, [(1659, 'a1', None), ('a1', 'a0', PEAK), ('a1', 'a2', PEAK)]


CELLS[24] = {'peak_inner': peak_inner(), 'peak_outer': peak_outer()}
CELLS[40] = {'peak_petal': peak_petal(-1)}
CELLS[78] = {'peak_petal': peak_petal(+1)}

# ---- cell 24 (41.7-53.9, th -36..-18): round the peak's terraces, a hillside: the mountain road spirals down from
# the inner ring, a castle stands off the border road, small pieces fill the corners -------------------------------
# consolidated 2026-11-18: the Ring (1625) and the Zigzag stair (1624) became one big figure, the mountain road, a
# path spiralling in round a summit notable; the kite Tadpole (235) grew into a castle, a ring of eight on two
# orbits (towers out, curtain walls in) with notables on the two far towers.
CELLS[24]['road'] = mountain_road(E(46.3, -25.6), 1624)
# w3 2026-11-19 (window 24, with Fire 28 across the border): the castle off 235 (a crumpled octagon of straight links)
# made one more round loop in a row of them (Fire's wisp and spiral, 24's spiral, 65's hill, 117's cirque); it is now
# the mirror of cell 23's mountain gate, a double arch open into the cell (the castle shape lives on in 19's fort)
CELLS[24]['gate'] = mountain_gate(orbit(road(235), 3.3, 95), -85, 235)
fill_rows(CELLS[24], [
    ('crook2',   1657, 'Crook', 'bow out', 1.2, 40, 0, False),
    ('crook',    234, 'Crook', 'bow in', 1.2, 45, 0, True),
    ('hook',     1626, 'Hook', 'bow out', 1.2, 215, 0, True),
])

# ---- cell 78 (53.9-64.3, th -23..-11): the peak's right petal in the top-left corner; centre figure a stepped
# pyramid standing on the outer ring: an outline loop climbing in steps to an apex notable, notables at the two
# middle steps. Round it on its own orbit, the bailey wall hung from the top corner (2026-11-18) ------------------
def pyramid(cx, entry):
    """A stepped-pyramid loop centred on land-local theta cx, base on r 62.7, apex at r 58.0."""
    pts = {'bm': (E(62.7, cx), 'small'), 'bl': (E(62.7, cx - 3.0), 'small'), 'br': (E(62.7, cx + 3.0), 'small'),
           'l1': (E(61.1, cx - 3.0), 'small'), 'l2': (E(61.1, cx - 1.6), 'notable'), 'l3': (E(59.5, cx - 1.6), 'small'),
           'apex': (E(58.0, cx), 'notable'),
           'r3': (E(59.5, cx + 1.6), 'small'), 'r2': (E(61.1, cx + 1.6), 'notable'), 'r1': (E(61.1, cx + 3.0), 'small')}
    order = ['bm', 'bl', 'l1', 'l2', 'l3', 'apex', 'r3', 'r2', 'r1', 'br', 'bm']
    return graph([(entry, 'bm')], pts, [(order[i], order[i + 1], None) for i in range(len(order) - 1)])


# consolidated 2026-11-18: the Hook off 1661 and the Crescent off 1678 became the pyramid's outer bailey, a wall of
# seven on an orbit round the pyramid (merlons on two radii until 2026-11-19, now one smooth arc), hung from 1660,
# notables at its far end and middle
CELLS[78]['pyramid'] = pyramid(-17.0, 1676)
CELLS[78]['bailey'] = bailey(E(60.4, -17.0), 4.5, [-12 + 18 * i for i in range(7)], 1660, (3, 6))


# ---- cell 40 (53.9-64.3, th -36..-23, the border cluster on its left wall): the peak's left petal in the top-right
# corner; centre figure a castle keep: a square courtyard loop (corners and wall middles), tower notables at the two
# inner corners and a keep notable in the courtyard hung from the inner wall. Fill: a Crook and a Tadpole ----------
def keep(cr, cth, half_r, half_th, entry):
    c = {'bl': (cr + half_r, cth - half_th), 'bm': (cr + half_r, cth), 'br': (cr + half_r, cth + half_th),
         'mr': (cr, cth + half_th), 'tr': (cr - half_r, cth + half_th), 'tm': (cr - half_r, cth),
         'tl': (cr - half_r, cth - half_th), 'ml': (cr, cth - half_th)}
    kinds = {'tr': 'notable', 'tl': 'notable'}
    pts = {k: (E(r, th), kinds.get(k, 'small')) for k, (r, th) in c.items()}
    # w3 2026-11-19: the keep notable stood on one straight link from tm (a spike into the courtyard); it now stands
    # at the centre of a cross wall between the two wall middles, splitting the courtyard into an inner and outer ward
    pts['keep'] = (E(cr, cth), 'notable')
    order = ['bm', 'br', 'mr', 'tr', 'tm', 'tl', 'ml', 'bl', 'bm']
    edges = [(order[i], order[i + 1], None) for i in range(len(order) - 1)] + [('ml', 'keep', None), ('keep', 'mr', None)]
    return graph([(entry, 'bm')], pts, edges)


CELLS[40]['keep'] = keep(59.4, -29.4, 2.0, 1.7, 1673)
fill_rows(CELLS[40], [
    ('crook',    1671, 'Crook', 'bow in', 1.6, 30, 0, True),    # 10 -> 30 2026-11-19: clumped with the border hex (1.12)
    ('crook2',   1657, 'Crook', 'swept', 1.3, 125, 0, True),   # 150 -> 125 2026-11-19: clumped with the keep (1.02)
])

# =====================================================================================================================
# Combo B', the mirror of the terraced peak on road node 1666 (th +23): cells 23, 75 and 48 are the mirrors of 24,
# 78 and 40 (PoE 2 mirrors about half of a class area). In each copy one small piece is changed.
# =====================================================================================================================
c23 = mirror_pieces({k: v for k, v in CELLS[24].items() if k != 'gate'}, 'earth')
# cell 23's border piece (a Wheel before 2026-11-18) is a mountain gate; 24 carries its mirror since w3 2026-11-19
c23['gate'] = mountain_gate(orbit(road(254), 3.3, -95), 85, 254)
CELLS[23] = c23
c75 = mirror_pieces({k: v for k, v in CELLS[78].items() if k != 'bailey'}, 'earth')
c75.update(mirror_pieces({'bailey': bailey(E(60.4, -17.0), 4.5, [-12 + 18 * i for i in range(6)], 1660, (3, 5))},
                         'earth'))                       # one merlon shorter than 78's, leaving room for the fork
fill_rows(c75, [  # in the corner where 78 had a Crescent
    ('fork', 1688, 'Crook', 'swept', 1.4, 50, 0, True),
])
CELLS[75] = c75
c48 = mirror_pieces({k: v for k, v in CELLS[40].items() if k not in ('crook', 'keep', 'crook2')}, 'earth')
c48['keep'] = keep(59.4, 28.6, 2.0, 1.7, 1683)                                  # the hex sits closer here
c48['keep'][0]['tr'] = (c48['keep'][0]['tr'][0], 'small'); c48['keep'][0]['mr'] = (c48['keep'][0]['mr'][0], 'notable')   # 2026-11-19: tr clumped with top48/dz48a
fill_rows(c48, [  # was a Crook by the border cluster
    ('top48', 1664, 'Hook', 'bow in', 1.2, 190, 0, False),
])
# w2 2026-11-19 (48|106): the Hook off 1681 with the Ring off 1682 in its curl (a busy corner, three notables) became
# one terrace fan rising from 1682 into the corner, its notables on the outer arc's second and third nodes
c48['terraces'] = terrace_fan(1682, orbit(road(1682), 1.5, 35), 35, notables=('o1', 'o2'))
CELLS[48] = c48

# ---- cell 36 (41.7-53.9, th -18..0, the axis hex on its right wall): rice terraces. Three staggered chains run
# along constant radius like contour steps on a hillside, each hung from one road node, notables at both ends ------
def terrace(r, th0, th1, n, entry, entry_idx):
    ths = [th0 + (th1 - th0) * k / (n - 1) for k in range(n)]
    pts = {f't{k}': (E(r, t), 'notable' if k in (0, n - 1) or (n >= 7 and k == entry_idx - 2) else 'small') for k, t in enumerate(ths)}
    O = (0.0, 0.0)                                          # arcs round the tree centre: parallel to the rings
    return pts, [(entry, f't{entry_idx}', None)] + [(f't{k}', f't{k + 1}', O) for k in range(n - 1)]


def terrace_l(entry):
    """The middle terrace, stepping down from the inner ring beside the hex, then running out along r 47.6."""
    pts = [(43.7, -5.4, 's'), (45.7, -5.8, 's')] + [(47.6, t, 'N' if k == 5 else 's') for k, t in
                                                     enumerate((-6.1, -7.6, -9.1, -10.6, -12.1, -13.6))]
    nodes = {f'm{i}': (E(r, t), 'notable' if k == 'N' else 'small') for i, (r, t, k) in enumerate(pts)}
    links = [(entry, 'm0', None), ('m0', 'm1', None), ('m1', 'm2', None)] +             [(f'm{i}', f'm{i + 1}', (0.0, 0.0)) for i in range(2, len(pts) - 1)]
    return nodes, links


CELLS[36] = {
    'terrace1': terrace(44.0, -17.0, -10.2, 7, 1627, 4),
    'terrace2': terrace_l(1629),
    'terrace3': terrace(51.3, -15.8, -8.6, 7, 1661, 4),   # 0.6 degrees west 2026-11-19: t0 clumped with the split stone (1.45)
}
fill_rows(CELLS[36], [
    ('foot36',   1663, 'Crook', 'bow in', 1.2, -20, 0, True),
])


# ---- cell 19 (41.7-53.9, th 0..18, the axis hex on its left wall): a mountain range. A ridge of three hills crosses
# the cell between outer-ring road nodes 1670 and 1667, a notable at each summit, the middle peak the tallest ------
def ridge(V=((52.2, 4.4), (48.6, 8.3), (48.6, 13.3), (52.2, 16.6)), peaks=(0.4, 0.64, 0.4), flank=0.08):
    """Three peaks end to end between valley nodes V (land polar); the feet hang from 1670 and 1667. Review pass w1
    2026-11-19: the zigzag of straight links became three round hills; w2 2026-11-19: the round hills read as clouds,
    so each hill is now a pointed peak: its crest notable stands peaks x chord straight above the middle of its valley
    line (towards the tree centre), and each flank is an arc from the valley node up to the crest, bowing out by flank x its chord, one node
    at the middle of each flank; arcs round each flank's own centre. The middle peak is the tallest."""
    P = [E(r, t) for r, t in V]
    pts = {f'v{k}': (p, 'small') for k, p in enumerate(P)}
    links = [(1670, 'v0', None), (f'v{len(P) - 1}', 1667, None)]
    for k in range(len(P) - 1):
        A, B = P[k], P[k + 1]
        m = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2); Lc = math.dist(A, B)
        nx, ny = -(B[1] - A[1]) / Lc, (B[0] - A[0]) / Lc
        if nx * m[0] + ny * m[1] > 0:                      # peaks point towards the tree centre
            nx, ny = -nx, -ny
        mr = math.hypot(*m); T = (m[0] - m[0] / mr * peaks[k] * Lc, m[1] - m[1] / mr * peaks[k] * Lc)   # crest straight up
        pts[f'h{k}1'] = (T, 'notable')
        for key, (p, q) in ((f'h{k}0', (A, T)), (f'h{k}2', (T, B))):
            lf = math.dist(p, q); ux, uy = -(q[1] - p[1]) / lf, (q[0] - p[0]) / lf
            fm = ((p[0] + q[0]) / 2, (p[1] + q[1]) / 2)
            if (fm[0] - m[0]) * ux + (fm[1] - m[1]) * uy < 0:   # the flank bows away from the hill's base midpoint
                ux, uy = -ux, -uy
            pts[key] = ((fm[0] + ux * flank * lf, fm[1] + uy * flank * lf), 'small')
        cl = bow_centre(A, T, flank, m); cr = bow_centre(T, B, flank, m)
        links += [(f'v{k}', f'h{k}0', cl), (f'h{k}0', f'h{k}1', cl), (f'h{k}1', f'h{k}2', cr), (f'h{k}2', f'v{k + 1}', cr)]
    return pts, links


# consolidated 2026-11-18: the Ring off 1634 and the Hook off 1633 became a small hill fort (castle of eight, towers
# and walls on two orbits) above the ridge's east peak, its gate on 1634
CELLS[19] = {'ridge': ridge(), 'fort': castle(E(44.3, 13.9), 1634, -10, rho_t=1.55, rho_w=0.95)}
fill_rows(CELLS[19], [
    ('top19a', 1635, 'Crescent', 'bow in', 1.2, 195, 0, False),   # 180 -> 195 2026-11-19: clear of the middle hill's crest
    ('foot19', 1668, 'Diamond', 'round', 1.0, 0, 0, False),
    ('mid19b', 1669, 'Crescent', 'bow in', 1.0, 15, 0, False),   # 0 -> 15 w2: clear of the west peak's crest (1.36)
])

# ---- cell 65 (inner band 33.2-41.7, th -23..0): a hill seen from above (review pass 2026-11-19: replaces the
# flat-bar pagoda frame, which read as bars and clashed with the rim pagoda). Two contour rings round one summit
# centre between inner-ring node 1615 and outer-ring node 1627, an inner ring of four turned 45 degrees tied to the
# outer one by two rungs on the diagonal. w2 2026-11-19: the outer contour is opened into a C at its top (a closed
# ring of eight bridging the band through its diameter echoed Fire cell 14); 1615 drops into the inner ring through
# the gap ------------------------------------------------------------------------------------------------------
def hill(top, foot, rho_o=2.5, rho_i=1.15, notables=('r6', 'i0', 'peak'), gap=None):
    """Contour rings bridging road nodes `top` (inner) and `foot` (outer): ring r0..r7 round their midpoint C (r0
    facing `top`, r4 facing `foot`, 45-degree steps, arc links round C), inner ring i0..i3 at 45 + 90 k, rungs r1-i0
    and r5-i2 on one diagonal, the summit `peak` at C joined to i1 and i3 on the other; `notables` lists the notable
    keys. gap 0 (or 4): the outer ring is cut either side of that node, which then joins the road node and the two
    nearest inner-ring nodes; the C's horns become notables."""
    A, B = road(top), road(foot)
    C = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
    Lc = math.dist(A, B); d = ((B[0] - A[0]) / Lc, (B[1] - A[1]) / Lc); e = (d[1], -d[0])
    P = lambda rr, phi: (C[0] - rr * d[0] * math.cos(math.radians(phi)) + rr * e[0] * math.sin(math.radians(phi)),
                         C[1] - rr * d[1] * math.cos(math.radians(phi)) + rr * e[1] * math.sin(math.radians(phi)))
    pts = {f'r{k}': (P(rho_o, 45 * k), 'small') for k in range(8)}
    pts.update({f'i{k}': (P(rho_i, 45 + 90 * k), 'small') for k in range(4)})
    pts['peak'] = (C, 'small')
    for k in notables:
        pts[k] = (pts[k][0], 'notable')
    links = [(top, 'r0', None), ('r4', foot, None), ('r1', 'i0', None), ('r5', 'i2', None), ('i1', 'peak', None),
             ('i3', 'peak', None)]
    links += run(ks('r', 8) + ['r0'], C) + run(ks('i', 4) + ['i0'], C)
    if gap is not None:                 # w2 2026-11-19: the outer contour opened into a C at ring node `gap` (0 or 4)
        g, other = (f'r{gap}', top if gap == 0 else foot), None
        nb = (f'r{(gap - 1) % 8}', f'r{(gap + 1) % 8}')
        links = [l for l in links if not (g[0] in l[:2] and (l[0] in nb or l[1] in nb))]
        inner = ('i0', 'i3') if gap == 0 else ('i1', 'i2')
        links += [(g[0], inner[0], None), (g[0], inner[1], None)]
        for k in nb:
            pts[k] = (pts[k][0], 'notable')
    return pts, links


# consolidated 2026-11-18: the Crook off 1616 and the Diamond off the axis node 102 became a trail winding up a knoll
# between the hill and the axis (an outer arc of four, an inner arc of three walked back, a summit notable);
# cell 66 carries its mirror
TRAIL65 = switchback(E(37.8, -5.2), 2.3, [85, 50, 15, -20, -55], 1.15, [-55, 5], 102)
CELLS[65] = {'hill': hill(1615, 1627, 2.35, 1.1, notables=('peak',), gap=0), 'trail': TRAIL65}
fill_rows(CELLS[65], [('c65', 1614, 'Diamond', 'round', 1.0, 175, 0, False)])


# ---- cell 66 (inner band, th 0..23): a stairway climbing from outer road node 1634 to inner road node 1620. Review
# pass 2026-11-19: the right-angled stair (a square wave) is redrawn as a stair bent on an orbit round a centre by the
# 1632 corner: two rails (arcs round it) and five treads on its rays, the outer rail hung from both road nodes,
# notables on two treads' inner ends ----------------------------------------------------------------------------
def stairway(O=E(41.0, 26.0), rho_o=8.7, rho_i=7.5, angs=(-80, -67.75, -55.5, -43.25, -31)):
    pts, links = ladder(O, rho_o, rho_i, list(angs), 1634, ('i1', 'i3'))
    return pts, links + [(f'o{len(angs) - 1}', 1620, None)]


# consolidated 2026-11-18: the Ring off 1622 and the Crescent off 102 gave way to the mirror of cell 65's trail
CELLS[66] = {'stairway': stairway(), 'trail': mirror_pieces({'t': TRAIL65}, 'earth')['t']}
fill_rows(CELLS[66], [
    ('b66', 1636, 'Diamond', 'round', 1.0, 40, 0, False),   # was a Ring, turned clear of the trail
])

# ---- cell 117 (small inner corner, th -36..-23): a cirque off the inner ring (below), two pieces under it ----------
CELLS[117] = fill_rows({}, [
    ('b117', 1514, 'Hairpin', 'bow out', 1.0, 120, 0, False),
    ('c117', 1624, 'Diamond', 'straight', 1.0, -10, 0, False),
])

# ---- cell 114 (small inner corner, th 23..36): its own cirque (below), a Hook off the border road and a Tadpole ---
CELLS[114] = fill_rows({}, [
    ('b114', 1631, 'Tadpole', 'cusped', 1.0, -15, 0, False),
])

# ---- cell 8 (outer band 64.3-74.3, th -17..0): the great wall. A long wall runs along the band from outer-ring
# node 1642 to the axis node 1489 (a merlon square wave until w1, then half circles; since w2 2026-11-19 one gentle
# arc with four square watchtowers), notables on two towers; above it a mesa hung from the inner ring, small pieces
# round them ----------------------------------------------------------------
def great_wall(A=E(72.3, -13.9), B=E(69.7, -1.2), bow=0.055, n=18, towers=(2, 7, 12, 17), t=0.8, crests=(7, 17)):
    """Review pass w2 2026-11-19 (the half circles bulging in and out in turn read as Water's wave train): the wall
    runs on ONE gentle arc from A (off 1642) to B (on to the axis node 1489), bowing towards the tree centre by bow x
    chord, n nodes between them at even steps round the arc's centre; at the indices `towers` a watchtower: the wall
    node gives way to a square tower standing across the wall (corners on the arc's orbits rho -+ t at that step,
    joined to the wall nodes either side); notables on the outer corners of the towers at `crests`."""
    mx, my = (A[0] + B[0]) / 2, (A[1] + B[1]) / 2
    Lc = math.dist(A, B); nx, ny = -(B[1] - A[1]) / Lc, (B[0] - A[0]) / Lc
    if nx * mx + ny * my > 0:                              # bulge towards the tree centre
        nx, ny = -nx, -ny
    h = bow * Lc; R = (Lc * Lc / 4 + h * h) / (2 * h); C = (mx + nx * (h - R), my + ny * (h - R))
    a0 = math.atan2(A[1] - C[1], A[0] - C[0]); a1 = math.atan2(B[1] - C[1], B[0] - C[0])
    da = (a1 - a0 + math.pi) % (2 * math.pi) - math.pi
    at = lambda rr, i: (C[0] + rr * math.cos(a0 + da * i / (n + 1)), C[1] + rr * math.sin(a0 + da * i / (n + 1)))
    pts = {'w0': (A, 'small'), f'w{n + 1}': (B, 'small')}
    links = [(1642, 'w0', None), (f'w{n + 1}', 1489, None)]
    for i in range(1, n + 1):
        if i in towers:
            q1, q2 = at(R - t, i), at(R + t, i)
            o, k = (q1, q2) if math.hypot(*q1) > math.hypot(*q2) else (q2, q1)
            pts[f'o{i}'] = (o, 'notable' if i in crests else 'small'); pts[f'k{i}'] = (k, 'small')
        else:
            pts[f'w{i}'] = (at(R, i), 'small')
    for i in range(n + 1):
        if i + 1 in towers:
            links += [(f'w{i}', f'o{i + 1}', None), (f'w{i}', f'k{i + 1}', None)]
        elif i in towers:
            links += [(f'o{i}', f'w{i + 1}', None), (f'k{i}', f'w{i + 1}', None)]
        else:
            links.append((f'w{i}', f'w{i + 1}', C))
    return pts, links


# consolidated 2026-11-18: the Crescent (1677) and the Fork (1679) became one mesa hung from 1678 between them, a
# terrace band of two flat arcs round a centre below the wall (a hill's contours), notables at the inner corners;
# its lower arc drawn deeper 2026-11-19 (rho 4.5, was 4.9: the mesa read thin)
MESA8 = E(72.3, -9.0)
CELLS[8] = {'wall': great_wall(),
            'mesa': band(MESA8, 6.4, [-26, -13, 0, 13, 26], 4.5, [-16, 0, 16], 1678, 'o1', ('i0', 'i2'))}
fill_rows(CELLS[8], [('a8', 1677, 'Crescent', 'bow in', 1.0, 200, 0, False)])   # the old Crescent back, clear of the mesa
fill_rows(CELLS[8], [
    ('c8', 1488, 'Crook', 'bow out', 1.2, 230, 0, True),
    ('d8', 1645, 'Hairpin', 'bow out', 1.0, -45, 0, False),
    ('f8', 1646, 'Crescent', 'bow in', 1.0, -35, 0, False),   # w3 2026-11-19: the empty strip under the wall's east half
])


# ---- cell 16 (outer band, th 0..17): a canyon. Two jagged cliff walls run down the cell from the inner ring to the
# outer ring, facing each other across a narrow gorge; notables on the outer crags. A stone circle west of them,
# terrace steps east (2026-11-18) ----------------------------------------------------------------------------------
def cliff(entry, exit_, pts):
    nodes = {f'c{i}': (E(r, t), 'notable' if k == 'N' else 'small') for i, (r, t, k) in enumerate(pts)}
    links = [(entry, 'c0', None), (f'c{len(pts) - 1}', exit_, None)] + [(f'c{i}', f'c{i + 1}', None) for i in range(len(pts) - 1)]
    return nodes, links


CELLS[16] = {
    'cliff_w': cliff(1689, 1654, [(65.8, 6.6, 's'), (67.2, 6.0, 'N'), (68.4, 7.0, 's'), (69.6, 6.3, 'N'), (70.9, 7.3, 's'),
                                  (72.0, 6.8, 'N'), (73.0, 7.8, 's')]),
    'cliff_e': cliff(1688, 1653, [(65.9, 10.6, 's'), (67.1, 11.7, 'N'), (68.4, 10.6, 's'), (69.7, 11.8, 'N'),
                                  (71.0, 10.9, 's'), (72.2, 12.1, 'N'), (73.1, 11.6, 's')]),
}
# consolidated 2026-11-18: the Tadpole off the axis node 1489 and the Arch off 1690 became one stone circle (seven
# stones round an altar notable) hung from 1489 in the strip beside the west cliff
CELLS[16]['henge'] = henge(E(69.0, 3.0), 1489, -90)
fill_rows(CELLS[16], [('e16', 1690, 'Crook', 'swept', 1.2, 150, 0, True)])   # density top-up on the free node 1690
# and the Crook off 1686 and the Hook off 1652 became terrace steps (a ladder of four rungs bent on an orbit; its centre moved
# out 2026-11-19 so the rungs no longer fan and the ladder stands straight beside the spoke) climbing
# the east side from 1652, notables on the top rung
CELLS[16]['steps'] = ladder(E(69.5, 24.5), 12.0, 10.8, [-99.5, -91.5, -83.5, -75.5], 1652, ('o3', 'i3'))
fill_rows(CELLS[16], [
])

# ---- cell 51 (outer band, th -28..-17): a cave. A horseshoe arc (open towards the outer ring) hangs from inner-ring
# node 1675 round a hollow, a treasure notable hanging inside from its roof ---------------------
def cave(O, rho, entry):
    angs = (-150, -115, -80, -45, 0, 45, 80, 115, 150)       # round from lower left over the top to lower right
    kinds = ['notable' if a in (-150, 150) else 'small' for a in angs]; kinds[4] = 'small'
    pts = {f'v{i}': (orbit(O, rho, a), k) for i, (a, k) in enumerate(zip(angs, kinds))}
    pts['gem'] = (orbit(O, 0.9, 0), 'notable')               # the treasure, hung inside the hollow from the roof
    # the gem hangs from both roof nodes beside the entry (2026-11-19: on one link from v3 it read as a spike)
    return pts, [(entry, 'v4', None), ('v3', 'gem', None), ('v5', 'gem', None)] + [(f'v{i}', f'v{i + 1}', O) for i in range(len(angs) - 1)]


CAVE = E(69.9, -21.6)
CELLS[51] = {'cave': cave(CAVE, 2.7, 1675)}
fill_rows(CELLS[51], [
])


# ---- cell 55 (outer band, th 17..28): a quarry. Two nested square pits, each a loop: the outer hung from inner-ring
# node 1685, the inner from outer-ring node 1650, a notable at one corner of each ---------------------------------
def square(cr, cth, hr, hth, entry, entry_key, notable_keys):
    c = {'a': (cr - hr, cth - hth), 'b': (cr - hr, cth), 'c': (cr - hr, cth + hth), 'd': (cr, cth + hth),
         'e': (cr + hr, cth + hth), 'f': (cr + hr, cth), 'g': (cr + hr, cth - hth), 'h': (cr, cth - hth)}
    pts = {k: (E(r, t), 'notable' if k in notable_keys else 'small') for k, (r, t) in c.items()}
    order = 'abcdefgha'
    return graph([(entry, entry_key)], pts, [(order[i], order[i + 1], None) for i in range(8)])


def quarry(cr, cth, entry):
    """A quarry pit as ONE cluster: an outer square rim and an inner square pit joined at the four corners."""
    po = square(cr, cth, 3.0, 3.2, entry, 'b', ('e',))
    pi = square(cr + 0.1, cth, 1.2, 1.25, entry, 'b', ('e', 'g'))
    pts = dict(po[0]); pts.update({'i' + k: v for k, v in pi[0].items()})
    edges = [e for e in po[1] if not isinstance(e[0], int)] + [('i' + a, 'i' + b, c) for a, b, c in pi[1] if not isinstance(a, int)]
    edges += [('a', 'ia', None), ('c', 'ic', None), ('e', 'ie', None), ('g', 'ig', None)]
    return pts, [(entry, 'b', None)] + edges


CELLS[55] = {'quarry': quarry(69.3, 22.4, 1685)}
fill_rows(CELLS[55], [
    ('a55', 1651, 'Crook', 'bow out', 1.0, 40, 0, True),
])

# ---- cell 104 (outer band corner, th -36..-28): a cairn, two stone loops stacked on each other with a capstone
# notable, rising from outer-ring node 1637; a Crook in from the border road and a Crescent from the inner ring -----
def cairn(cth, entry):
    p = {'b': (72.9, cth, 's'), 'l1': (71.7, cth - 1.3, 's'), 'r1': (71.7, cth + 1.3, 's'), 'm1': (70.5, cth, 's'),
         'l2': (69.5, cth - 1.0, 'N'), 'r2': (69.5, cth + 1.0, 's'), 'm2': (68.5, cth, 's'), 'cap': (67.3, cth, 'N')}
    pts = {k: (E(r, t), 'notable' if kd == 'N' else 'small') for k, (r, t, kd) in p.items()}
    edges = [('b', 'l1', None), ('b', 'r1', None), ('l1', 'm1', None), ('r1', 'm1', None), ('m1', 'l2', None),
             ('m1', 'r2', None), ('l2', 'm2', None), ('r2', 'm2', None), ('m2', 'cap', None)]
    return graph([(entry, 'b')], pts, edges)


# 104 and 106 kept as they were (2026-11-18): a terrace fan was tried in both free corners and does not fit beside the cairn
CELLS[104] = {'cairn': cairn(-31.8, 1637)}
fill_rows(CELLS[104], [
    ('a104', 505, 'Zigzag', 'wave', 1.0, 140, 0, False),
])
# ---- cell 106, the mirror of 104 with the border Crook turned into a Hook ------------------------------------------
c106 = mirror_pieces({k: v for k, v in CELLS[104].items() if k != 'a104'}, 'earth')
fill_rows(c106, [
    ('a106', 508, 'Hook', 'bow in', 1.0, -55, 0, False),   # -70 -> -55 2026-11-19: clumped with the cairn cap (1.47)
])
CELLS[106] = c106

# ---- cell 2 (the Earth start cell, 558 units², the start figure on the axis): big and sparse (B4). Four pieces: two
# standing stones (Diamonds) rising from the 33.2 ring either side of the start road, two Crescents hanging out
# from the hub ring like the start's outer guard -------------------------------------------------------------------
CELLS[2] = fill_rows({}, [
    ('a2', 1614, 'Diamond', 'round', 1.4, 0, 0, False),
    ('b2', 1620, 'Diamond', 'straight', 1.4, 0, 0, False),
    ('c2', 12, 'Crescent', 'bow out', 1.4, 180, 0, False),
    ('d2', 14, 'Crescent', 'bow out', 1.4, 180, 0, True),
])

# ---- cell 80 (hub cell facing Earth, inside the Taiji ring): three small pieces off the hub ring and the Taiji spoke
CELLS[80] = fill_rows({}, [
    ('a80', 12, 'Tadpole', 'round', 1.0, 0, 0, False),
    ('b80', 14, 'Crook', 'bow in', 1.0, 0, 0, True),
    ('c80', 2, 'Diamond', 'cusped', 1.3, 140, 0, False),
])

# =====================================================================================================================
# Rim (cell 902): Earth's slice of the open band outside the 74.3 ring, kept within th -33..+28 (the Darkness
# connector runs out at +30..+33). Rebuilt 2026-11-18 night (rim-brief.md): the two keystones on their hook roads
# 1961/1962 stay here; the large figures (pagoda, eight-pointed stars, cong jades, ruyi, bell) are built under
# RIM FIGURES at the end of the file. The earlier stair, valley, terraces, spur, gate, caldera, peak, stones, boulder,
# Ring and Diamond pieces were removed then (copy in design/dao-do/cells/out/earth-rim-bak.py).
# =====================================================================================================================
CELLS[902] = {
    'keystone_w': ({'k': (E(81.8, -12.3), 'keystone')}, [(1961, 'k', None)]),
    'keystone_e': ({'k': (E(81.8, 12.3), 'keystone')}, [(1962, 'k', None)]),
}
# RIM_FIGURES (2026-11-18 night, rim-brief.md) are added after the density pass, at the end of the file.

# consolidated 2026-11-18: the Tadpole off 1674 grew into a caldera (a rim of six round a vent notable)
CELLS[40]['caldera'] = caldera(orbit(road(1674), 3.2, -38), 1674, 142, notables=())
fill_rows(CELLS[48], [('dz48a', 1665, 'Ring', 'round', 1.0, 150, 0, False)])
fill_rows(CELLS[48], [('dz48b', 1684, 'Crook', 'swept', 1.4, 60, 0, False)])
fill_rows(CELLS[51], [('dz51a', 1674, 'Diamond', 'round', 1.0, 180, 0, False)])
CELLS[51]['peak'] = peak_fan(orbit(road(1959), 2.1, 50), 1.8, 40, 1959, -130, mid='small')
fill_rows(CELLS[51], [('dz51b', 1641, 'Hairpin', 'bow out', 1.0, -40, 0, False)])
# consolidated 2026-11-18: the Fork off 1612 and the Crescent off 1611 became a cirque (a ring of five with two peaks)
CELLS[117]['cirque'] = cirque(E(36.0, -28.4), 1612, 45, peaks=(1, 3))
CELLS[114]['cirque'] = cirque(E(36.0, 28.4), 1618, -45, peaks=(1, 4))   # 114's own: peaks on the diagonal (east side until 2026-11-19, clear of the Hook); its Hairpin is now a Hook
fill_rows(CELLS[114], [('a114', 1519, 'Hook', 'bow in', 1.2, -100, 0, True)])   # the Crook off 1617 gave way to the cirque
fill_rows(CELLS[66], [('dz66', 1633, 'Diamond', 'round', 1.0, 0, 0, False)])
fill_rows(CELLS[104], [('dz104', 1672, 'Hairpin', 'bow out', 1.0, 155, 0, True)])   # curl flipped 2026-11-19: clumped with the cairn cap (1.31)
fill_rows(CELLS[106], [('dz106', 1682, 'Hook', 'bow out', 1.0, 190, 0, False)])


# =====================================================================================================================
# Density pass 2026-11-18 (design/dao-do/cells/density-brief.md): figures mirrored across cell walls ("the symmetry
# mirror thing by the cell wall"), grown figures and new pieces. Appended here, after every mirror_pieces copy above,
# so nothing below is mirrored by accident. New piece names start with d_.
# =====================================================================================================================
from celllib import wall_pair  # noqa: E402


class Wall:
    """A wall frame on the straight line through road nodes wa and wb: x along the wall (from the midpoint towards wb),
    y away from the wall into the side holding the point `toward`. pt(x, y) and polar(O, rho, a) give file-frame
    points; polar angle a is measured round O (a wall-frame point) from +x towards +y."""

    def __init__(self, wa, wb, toward):
        A, B = road(wa), road(wb)
        self.wa, self.wb = wa, wb
        self.L = math.dist(A, B)
        self.C = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
        self.u = ((B[0] - A[0]) / self.L, (B[1] - A[1]) / self.L)
        n = (-self.u[1], self.u[0])
        if (toward[0] - self.C[0]) * n[0] + (toward[1] - self.C[1]) * n[1] < 0:
            n = (-n[0], -n[1])
        self.n = n

    def pt(self, x, y):
        return (self.C[0] + x * self.u[0] + y * self.n[0], self.C[1] + x * self.u[1] + y * self.n[1])

    def polar(self, O, rho, a):
        t = math.radians(a)
        return self.pt(O[0] + rho * math.cos(t), O[1] + rho * math.sin(t))

    def ring(self, O, rho, angs, kinds, pre):
        return {f'{pre}{i}': (self.polar(O, rho, a), k) for i, (a, k) in enumerate(zip(angs, kinds))}

    def pair(self, half):
        return wall_pair(half, self.wa, self.wb)


def put(cell_a, cell_b, pair):
    """Add a wall pair: pair[0] to cell_a (the half's side), pair[1] to cell_b (across the wall)."""
    CELLS[cell_a].update(pair[0]); CELLS[cell_b].update(pair[1])


# ---- 66 | 2 on the 33.2 ring, 1622-1621 (th 8..14): the city gate. An arch of five round the wall's midpoint, a
# pass-through from 1622 to 1621, crowned by an outer arc of three tied to the arch's shoulders, a notable at its
# keystone; the ring road runs through the middle of the gate, the far half in the start cell ---------------------
W = Wall(1622, 1621, E(36.0, 11.0))
g = W.ring((0, 0), 1.75, (150, 120, 90, 60, 30), ['small'] * 5, 'a')
g.update(W.ring((0, 0), 2.6, (115, 90, 65), ('small', 'notable', 'small'), 'c'))
put(66, 2, W.pair({'d_gate': (g, [(1622, 'a0', W.C)] + run(ks('a', 5), W.C) + [('a4', 1621, W.C),
                              ('a1', 'c0', None), ('a3', 'c2', None)] + run(ks('c', 3), W.C))}))

# ---- 24 (grown): the mountain road gets an outer ring road; from the spiral's first bend an arc of six runs on round
# the summit on the spiral's outer orbit (rho 3.0) into the empty +theta side, a notable lookout at its end ----------
O24 = E(46.3, -25.6)
CELLS[24]['road'][0].update(on(O24, 3.0, [2, 32, 62, 92, 122, 152], ['small'] * 5 + ['notable'], 'q'))
CELLS[24]['road'][1].extend([('p0', 'q0', O24)] + run(ks('q', 6), O24))
# ---- 23 (grown, not the mirror): its outer arc is one node shorter and turned the other way ---------------------------
O23 = E(46.3, 25.6)
CELLS[23]['road'][0].update(on(O23, 3.0, [-5, -36, -67, -98, -129], ['small'] * 4 + ['notable'], 'q'))
CELLS[23]['road'][1].extend([('p0', 'q0', O23)] + run(ks('q', 5), O23))


# ---- 36 (grown): rice terraces with a second row. The outer and inner terraces each get a parallel row of five on the
# side facing the middle terrace (arcs round the tree centre, like the rings), tied at both ends: each a terrace band --
def terrace_row(piece, r, th_keys, pre, notable):
    pts, links = piece
    for i, k in enumerate(th_keys):
        r0, th = math.hypot(*pts[k][0]), math.degrees(math.atan2(*pts[k][0])) - 72
        pts[f'{pre}{i}'] = (E(r, th), 'notable' if i == notable else 'small')
    links += [(th_keys[0], f'{pre}0', None), (th_keys[-1], f'{pre}{len(th_keys) - 1}', None)] + run(ks(pre, len(th_keys)), (0.0, 0.0))


terrace_row(CELLS[36]['terrace1'], 45.7, ['t1', 't2', 't3', 't4', 't5'], 'o', 2)
terrace_row(CELLS[36]['terrace3'], 49.6, ['t1', 't2', 't3', 't4', 't5'], 'i', 2)


def arch(W, n, kinds, sag, pre='a'):
    """A pass-through arch from W.wa to W.wb on W's side: n nodes on one circle through both road nodes, sagitta
    `sag` (the arch's depth from the wall line), even angular steps, arc links round the circle's centre. Returns
    (nodes, links, centre K)."""
    c = W.L / 2
    R = (c * c + sag * sag) / (2 * sag)
    K = (0.0, sag - R)
    a0 = math.degrees(math.atan2(-K[1], -c)); a1 = math.degrees(math.atan2(-K[1], c))
    angs = [a0 + (a1 - a0) * (i + 1) / (n + 1) for i in range(n)]
    pts = W.ring(K, R, angs, kinds, pre)
    Kxy = W.pt(*K)
    keys = ks(pre, n)
    return pts, [(W.wa, keys[0], Kxy)] + run(keys, Kxy) + [(keys[-1], W.wb, Kxy)], Kxy


def arch_grow(piece, W, n, sag, span, d, kinds, pre='c'):
    """Grow an arch made by arch(W, n, ., sag) in place: a second arc on the arch's own circle centre, d further out
    (d < 0: inside, towards the wall), with one node at each arch angle from arch node span[0] to span[1], tied to
    those two arch nodes by radial links; kinds for the new nodes."""
    c = W.L / 2
    R = (c * c + sag * sag) / (2 * sag)
    K = (0.0, sag - R)
    a0 = math.degrees(math.atan2(-K[1], -c)); a1 = math.degrees(math.atan2(-K[1], c))
    angs = [a0 + (a1 - a0) * (i + 1) / (n + 1) for i in range(n)][span[0]:span[1] + 1]
    pts, links = piece
    pts.update(W.ring(K, R + d, angs, kinds, pre))
    keys = ks(pre, len(angs)); Kxy = W.pt(*K)
    links += [(f'a{span[0]}', keys[0], None), (f'a{span[1]}', keys[-1], None)] + run(keys, Kxy)


# ---- 36 | 78 on the 53.9 ring, 1660-1661 (th -18..-11): the split stone. A lens of ten lying across the ring road,
# one arc of five each side (sagitta 1.2), a notable at each crest -------------------------------------------------
W = Wall(1660, 1661, E(50.0, -14.0))
put(36, 78, W.pair({'d_lens': arch(W, 5, ['small', 'small', 'notable', 'small', 'small'], 1.2)[:2]}))


# ---- 51 | 104 on the -28 spoke, 1638-1959 (r 69.3..74.3): a cairn stone split by the spoke, stepped by 1959 -------
W = Wall(1638, 1959, E(71.0, -26.0))
h = arch(W, 4, ['small'] * 4, 1.0)[:2]                  # 2026-11-19: the mirror of 55|106's stepped stone (was a lens of
arch_grow(h, W, 4, 1.0, (2, 3), 0.8, ['notable', 'small'])  # 5+5, the same drawing as 36|78's)
put(51, 104, W.pair({'d_step': h}))
# ---- 55 | 106 on the +28 spoke, 1648-1960: not the lens of 51|104 but a stepped stone: a shallower arch of four a
# side with a terrace step of two on its upper shoulder (by 1960), the notable at the step's inner end --------------
W = Wall(1648, 1960, E(71.0, 26.0))
h = arch(W, 4, ['small'] * 4, 1.0)[:2]
arch_grow(h, W, 4, 1.0, (2, 3), 0.8, ['notable', 'small'])
put(55, 106, W.pair({'d_step': h}))

# ---- one-sided pass-through arches (gates and bridges hung between two road nodes of one ring segment); each a small
# piece in one cell, depth (sagitta), length and notable varied so no two read the same --------------------------
CELLS[65]['d_arch'] = arch(Wall(1628, 1629, E(40.2, -6.4)), 5, ['small'] * 5, 1.3)[:2]     # under the knoll trail (horned below)
CELLS[87]['d_arch'] = arch(Wall(1662, 1663, E(55.4, -5.4)), 5, ['small', 'small', 'notable', 'small', 'small'], 1.3)[:2]     # beside the left tower's foot
CELLS[89]['d_arch'] = arch(Wall(1669, 1670, E(55.4, 5.4)), 5, ['small', 'small', 'notable', 'small', 'small'], 1.3)[:2]     # its mirror (2026-11-19, was four stones, sag 1.0)
CELLS[75]['d_arch'] = arch(Wall(1667, 1668, E(55.4, 14.5)), 5, ['small', 'small', 'notable', 'small', 'small'], 1.3)[:2]
CELLS[8]['d_arch'] = arch(Wall(1679, 1680, E(65.8, -4.5)), 5, ['small', 'small', 'notable', 'small', 'small'], 1.3)[:2]

# w2 2026-11-19 (16|89): the plain four-stone arch glued under 89's side of the ring at 1688-1689 is now a split
# stone, mirrored across the ring into the head of 16's canyon between the two cliffs (a gate at the gorge's mouth)
W = Wall(1688, 1689, E(62.8, 8.5))
put(89, 16, W.pair({'d_split': arch(W, 4, ['small', 'notable', 'small', 'small'], 1.07)[:2]}))
CELLS[8]['d_arch2'] = arch(Wall(1677, 1678, E(65.8, -12.5)), 3, ['small', 'notable', 'small'], 1.0)[:2]     # three stones (four until 2026-11-19)

# ---- small catalogue pieces in the pockets of the sparser cells: the pocket and road node picked by hand from the
# free-space map; the angle, stem and hand taken from a scratch sweep of named catalogue placements (best spacing
# margin, out/earth_sweep.py), then checked whole ----------------------------------------------------------------
for cell, row in ((19, ('d_s19', 1636, 'Tadpole', 'round', 1.25, 180, 0, True)),     # beside the axis hex
                  (16, ('d_s16', 1656, 'Hook', 'bow in', 1.25, 320, 0, False)),     # between the henge and the axis
                  (40, ('d_s40', 1658, 'Zigzag', 'wave', 1.25, 140, 0, False)),     # under the peak's left petal
                  (78, ('d_s78', 1674, 'Hook', 'bow in', 1.25, 40, 0, True)),
                  (75, ('d_s75', 1685, 'Crescent', 'bow out', 1.25, 40, 0, False)),
                  (55, ('d_s55', 1960, 'Diamond', 'round', 1.25, 320, 0, True)),
                  (65, ('d_s65', 1626, 'Crook', 'bow out', 1.2, 350, 0, True)),    # left of the hill (a Tadpole ring until 2026-11-19)
                  (51, ('d_s51', 1639, 'Hook', 'bow in', 1.25, 340, 0, False))):   # curl flipped 2026-11-19 (clear of the stepped stone)
    fill_rows(CELLS[cell], [row])
# ---- 80 (the hub cell): a stone circle of seven round an altar notable hung from the axis node 13 on the hub ring,
# and a Crescent rising from the Taiji ring node 3 below it -----------------------------------------------------------
CELLS[80]['d_henge'] = henge(E(11.2, 0.0), 13, 180, rho=1.5, n=7, notables=())
fill_rows(CELLS[80], [('d_s80', 3, 'Crescent', 'bow out', 1.25, 180, 0, True)])


# ---- arches grown into medium figures (so the one-sided arches are not one drawing repeated) ----------------------
arch_grow(CELLS[65]['d_arch'], Wall(1628, 1629, E(40.2, -6.4)), 5, 1.3, (1, 3), 0.85, ['notable', 'small', 'notable'])  # horns
arch_grow(CELLS[8]['d_arch'], Wall(1679, 1680, E(65.8, -4.5)), 5, 1.3, (0, 2), 0.9, ['notable', 'small', 'small'])   # a step
# ---- 16: a switchback climbing the gorge between the two cliffs from 1654 (the arch off 1688 was dropped: four
# figures met on that node) -------------------------------------------------------------------------------------
fill_rows(CELLS[16], [('d_g16', 1654, 'Hairpin', 'tight turn', 1.25, 30, 0, True)])

# ---- the terraced peaks (combo B on 1659, B' on 1666) grow: their petals in 78 and 75 get a second, outer terrace
# arc round the peak node, tied to the petal's tips, so the figures interlock further round the shared road node -----
def petal_grow(cell, peak, rho, angs, kinds):
    P = CELLS[cell]['peak_petal']; O = road(peak)
    P[0]['a0'] = (P[0]['a0'][0], 'small'); P[0]['a2'] = (P[0]['a2'][0], 'small')
    P[0].update(on(O, rho, angs, kinds, 'b'))
    P[1].extend([('a0', 'b0', None), ('a2', f'b{len(angs) - 1}', None)] + run(ks('b', len(angs)), O))


petal_grow(78, 1659, 3.8, [112, 128, 144, 160], ['small', 'notable', 'small', 'notable'])
petal_grow(75, 1666, 3.9, [-112, -135, -158], ['notable', 'small', 'notable'])
petal_grow(48, 1666, 3.7, [115, 140], ['small', 'notable'])
# ---- arches on the inner side of the outer ring (74.3), into the outer band: single-sided pieces, not wall pairs --
CELLS[16]['d_arch'] = arch(Wall(1656, 1655, E(72.5, 4.1)), 5, ['small'] * 5, 1.3)[:2]     # the outer gate, crowned:
arch_grow(CELLS[16]['d_arch'], Wall(1656, 1655, E(72.5, 4.1)), 5, 1.3, (1, 3), 0.85, ['small', 'notable', 'small'])
# (16's plain four-stone arch at 1653-1652 removed w2 2026-11-19: it tied the east cliff's foot to the steps' foot)
CELLS[55]['d_arch'] = arch(Wall(1650, 1649, E(72.5, 22.0)), 4, ['small', 'small', 'notable', 'small'], 1.0)[:2]
CELLS[51]['d_arch'] = arch(Wall(1639, 1640, E(72.5, -22.0)), 4, ['small', 'small', 'notable', 'small'], 1.0)[:2]
P = CELLS[36]['terrace2']; P[0]['m7'] = (P[0]['m7'][0], 'small')            # 36: the middle terrace runs on two steps
P[0]['m8'] = (E(47.6, -15.1), 'small'); P[0]['m9'] = (E(47.6, -16.6), 'notable')
P[1].extend([('m7', 'm8', (0.0, 0.0)), ('m8', 'm9', (0.0, 0.0))])



# =====================================================================================================================
# RIM FIGURES (2026-11-18 night, design/dao-do/cells/rim-brief.md): the rim's large figures, cell 902 only.
# =====================================================================================================================
PO = E(100.0, 0.0)                     # the pagoda's orbit centre, on the axis beyond the rim


def rim_pagoda_half(aw=9.0, step=5.0, roofs=(22.4, 19.4, 16.4, 13.4), thick=1.6):
    """The pagoda's right half (+theta side); the axis road is its mast. Orbit frame round PO: the wall on the ray aw
    degrees off the mast (it tapers as the orbits shrink), each roof on an orbit: the underside W-M-E at even steps
    `step` out from the wall to the eave tip E (notable), the upper surface back from E through U to the wall node X
    `thick` higher, a closed wedge. The top roof's upper surface runs up to the mast at axis node 1227. Hangs from ring
    node 1656 (the plinth, a ground storey of two links) and 1227."""
    pts, links = {}, []
    def at(k, rho, a, kind='small'):
        pts[k] = (orbit(PO, rho, a), kind)
    at('b', (rho_of(1656) + roofs[0]) / 2, (ang_of(1656) + aw) / 2)
    prev = 'b'; links.append((1656, 'b', None))
    for k, R in enumerate(roofs, 1):
        at(f'W{k}', R, aw); at(f'M{k}', R, aw + step); at(f'E{k}', R, aw + 2 * step, 'notable')
        at(f'U{k}', R - 0.62 * thick, aw + 1.15 * step)
        links += [(prev, f'W{k}', None), (f'W{k}', f'M{k}', PO), (f'M{k}', f'E{k}', PO), (f'E{k}', f'U{k}', None)]
        if k < len(roofs):
            at(f'X{k}', R - thick, aw)
            links += [(f'U{k}', f'X{k}', None), (f'W{k}', f'X{k}', None)]
            prev = f'X{k}'
        else:                          # the top roof's hip runs on through T to the mast
            u = pts[f'U{k}'][0]; m = road(1227)
            pts['T'] = (((u[0] + m[0]) / 2, (u[1] + m[1]) / 2), 'small')
            links += [(f'U{k}', 'T', None), ('T', 1227, None)]
    return pts, links


def rho_of(i):
    return math.dist(road(i), PO)


def ang_of(i):                         # orbit angle of road node i round PO (0 = towards the tree centre)
    x, y = road(i)
    for a10 in range(0, 900):
        if math.dist(orbit(PO, rho_of(i), a10 / 10), (x, y)) < 0.02:
            return a10 / 10
    raise ValueError(i)


def rim_finial():
    """The spire's pearl: a ring of six round a point beyond the mast's end 1228, hung from it; three notables on the
    far half."""
    C = E(96.4, 0.0)
    pts = on(C, 1.3, [60 * i for i in range(6)], ['small', 'small', 'notable', 'notable', 'notable', 'small'], 'f')
    return pts, [(1228, 'f0', None)] + run(ks('f', 6) + ['f0'], C)


_pr = rim_pagoda_half()
CELLS[902]['pagoda_R'] = _pr
CELLS[902]['pagoda_L'] = mirror_pieces({'p': _pr}, 'earth')['p']
CELLS[902]['finial'] = rim_finial()



VAL = 0.6


def rim_octagram(entry, T=4.2, stem=1.3, inner=1.25, tips_n=(2, 4, 6), corners_n=(1, 2)):
    """The eight-pointed star (ba jiao xing, two squares laid across each other) drawn as its outline: tips on an orbit
    T round O at 45-degree steps (tip 0 points at the road node `entry`), valleys between them on the orbit where the
    two squares' sides meet, straight links; inside, a square turned to the valleys, its corners on rays to four of
    them. Notables at the tips `tips_n` and the square corners `corners_n` (indices)."""
    O = orbit(road(entry), stem + T, 180)
    V = T * VAL
    pts = {}
    for k in range(8):
        pts[f't{k}'] = (orbit(O, T, 45 * k), 'notable' if k in tips_n else 'small')
        pts[f'v{k}'] = (orbit(O, V, 45 * k + 22.5), 'small')
    for k in range(4):
        pts[f'q{k}'] = (orbit(O, inner, 90 * k + 22.5 + 45), 'notable' if k in corners_n else 'small')
    links = [(entry, 't0', None)]
    for k in range(8):
        links += [(f't{k}', f'v{k}', None), (f'v{k}', f't{(k + 1) % 8}', None)]
    for k in range(4):
        links += [(f'q{k}', f'q{(k + 1) % 4}', None), (f'q{k}', f'v{2 * k + 1}', None)]
    return pts, links


CELLS[902]['star_R'] = rim_octagram(1649)
CELLS[902]['star_L'] = mirror_pieces({'p': CELLS[902]['star_R']}, 'earth')['p']



def arc_through(A, B, bow, n, side):
    """n inner points at even angular steps on the circular arc from A to B whose sagitta is bow x chord, bulging
    towards the point `side`; returns (points, the arc's centre)."""
    mx, my = (A[0] + B[0]) / 2, (A[1] + B[1]) / 2
    dx, dy = B[0] - A[0], B[1] - A[1]
    Lc = math.hypot(dx, dy); nx, ny = -dy / Lc, dx / Lc
    if (side[0] - mx) * nx + (side[1] - my) * ny < 0:
        nx, ny = -nx, -ny
    h = bow * Lc; R = (Lc * Lc / 4 + h * h) / (2 * h)
    C = (mx + nx * (h - R), my + ny * (h - R))
    a0 = math.atan2(A[1] - C[1], A[0] - C[0]); a1 = math.atan2(B[1] - C[1], B[0] - C[0])
    da = (a1 - a0 + math.pi) % (2 * math.pi) - math.pi
    return [(C[0] + R * math.cos(a0 + da * i / (n + 1)), C[1] + R * math.sin(a0 + da * i / (n + 1))) for i in range(1, n + 1)], C


def rim_ruyi(entry, Hc, rho=1.55, bow=0.12, lean=None, n_handle=3, lobe=0.45, flank=-0.1, plaque=0.7):
    """A ruyi sceptre: a handle on an arc from the ring node `entry` out to a heart-shaped lingzhi head round Hc. The
    handle (h0..h2 on one arc) opens at h1 into a small lozenge plaque (pL, pR either side, arcs bowing out) that
    closes again at h2. The head: six nodes on an orbit round Hc, the notch k0 (where the handle joins) between two
    deep lobes (arcs bowing out, `lobe` x chord) out to the shoulders k1/k5, the flanks in shallow inward bows to the
    point k3; each arc round its own centre. Notables on the shoulders and the point."""
    A = road(entry)
    d = (A[0] - Hc[0], A[1] - Hc[1])
    a_j = math.degrees(math.atan2(d[0] * frame_t(Hc)[0] + d[1] * frame_t(Hc)[1], d[0] * frame_i(Hc)[0] + d[1] * frame_i(Hc)[1]))
    angs = [a_j, a_j + 90, a_j + 140, a_j + 180, a_j + 220, a_j + 270]
    kinds = ['small', 'notable', 'small', 'notable', 'small', 'notable']
    head = {f'k{i}': (orbit(Hc, rho, a), kd) for i, (a, kd) in enumerate(zip(angs, kinds))}
    J = head['k0'][0]
    hp, hC = arc_through(A, J, bow, n_handle, lean or Hc)
    pts = {f'h{i}': (q, 'small') for i, q in enumerate(hp)}
    h1, h2 = hp[1], hp[2]
    mx, my = (h1[0] + h2[0]) / 2, (h1[1] + h2[1]) / 2
    L = math.dist(h1, h2); nx, ny = -(h2[1] - h1[1]) / L, (h2[0] - h1[0]) / L
    pts['pL'] = ((mx + nx * plaque, my + ny * plaque), 'small'); pts['pR'] = ((mx - nx * plaque, my - ny * plaque), 'small')
    pts.update(head)
    pc = (mx, my)
    links = [(entry, 'h0', hC), ('h0', 'h1', hC), ('h2', 'k0', hC)]
    for q in ('pL', 'pR'):
        links += [('h1', q, bow_centre(h1, pts[q][0], 0.15, pc)), (q, 'h2', bow_centre(pts[q][0], h2, 0.15, pc))]
    bows = [lobe, flank, flank, flank, flank, lobe]
    for i in range(6):
        p, q = head[f'k{i}'][0], head[f'k{(i + 1) % 6}'][0]
        links.append((f'k{i}', f'k{(i + 1) % 6}', bow_centre(p, q, bows[i], Hc)))
    return pts, links


def frame_i(at):
    r = math.hypot(*at); return (-at[0] / r, -at[1] / r)


def frame_t(at):
    i = frame_i(at); return (-i[1], i[0])


CELLS[902]['ruyi_R'] = rim_ruyi(1654, E(80.4, 9.6), lean=E(76.0, 5.0))
CELLS[902]['ruyi_L'] = mirror_pieces({'p': CELLS[902]['ruyi_R']}, 'earth')['p']



def rim_cong(entry, S=2.9, ri=1.25, stem=1.3, notables=('c1', 'c2', 'c3', 'r4')):
    """A cong, Earth's ritual jade, seen end on: a square outside (corners on an orbit S round O, corner c0 pointing
    at the road node `entry`, mid-side nodes between them, straight links) round a circle inside (eight nodes on an
    orbit ri, arcs round O), the circle bridged to the four mid-sides on rays. Square without, round within."""
    O = orbit(road(entry), stem + S, 180)
    pts = {f'c{k}': (orbit(O, S, 90 * k), 'small') for k in range(4)}
    pts.update({f'm{k}': (orbit(O, S * math.cos(math.radians(45)), 45 + 90 * k), 'small') for k in range(4)})
    pts.update({f'r{k}': (orbit(O, ri, 45 * k), 'small') for k in range(8)})
    for k in notables:
        pts[k] = (pts[k][0], 'notable')
    links = [(entry, 'c0', None)]
    for k in range(4):
        links += [(f'c{k}', f'm{k}', None), (f'm{k}', f'c{(k + 1) % 4}', None), (f'm{k}', f'r{2 * k + 1}', None)]
    links += [(f'r{k}', f'r{(k + 1) % 8}', O) for k in range(8)]
    return pts, links


CELLS[902]['cong_R'] = rim_cong(1651)
CELLS[902]['cong_L'] = mirror_pieces({'p': CELLS[902]['cong_R']}, 'earth')['p']



def rim_bell(entry, ang, stem=1.2, half=(0.95, 1.25, 1.5, 2.0), depth=(0.6, 1.8, 3.0, 4.3), mouth=3.85):
    """A bronze bell (zhong) hung mouth outwards from the ring node `entry`, its axis `ang` degrees in the orbit frame
    of the road node: the crown t, then down each side on arcs bowing out the shoulder s, two bands b and d and the
    flared mouth corner k (notable); the mouth arches in between the corners; a bar across each band with a boss at
    its middle (c on the upper band, e on the lower, both notables). Local frame: x across the axis, y down it from the
    crown; half/depth give |x| and y of shoulder, bands and corner."""
    A = road(entry)
    T = orbit(A, stem, ang)
    D = ((T[0] - A[0]) / stem, (T[1] - A[1]) / stem); X = (-D[1], D[0])
    P = lambda x, y: (T[0] + x * X[0] + y * D[0], T[1] + x * X[1] + y * D[1])
    pts = {'t': (T, 'small'), 'm': (P(0, mouth), 'small'), 'c': (P(0, depth[1]), 'notable'), 'e': (P(0, depth[2]), 'notable')}
    for sd, sg in (('L', -1), ('R', 1)):
        for key, j in (('s', 0), ('b', 1), ('d', 2)):
            pts[key + sd] = (P(sg * half[j], depth[j]), 'small')
        pts['k' + sd] = (P(sg * half[3], depth[3]), 'notable')
    cen = P(0, depth[1])
    bc = lambda a, b, bow: bow_centre(pts[a][0], pts[b][0], bow, cen)
    links = [(entry, 't', None)]
    for sd in 'LR':
        links += [('t', 's' + sd, bc('t', 's' + sd, 0.12)), ('s' + sd, 'b' + sd, bc('s' + sd, 'b' + sd, 0.08)),
                  ('b' + sd, 'd' + sd, None), ('d' + sd, 'k' + sd, bc('d' + sd, 'k' + sd, -0.1)),
                  ('k' + sd, 'm', bc('k' + sd, 'm', -0.12)), ('b' + sd, 'c', None), ('d' + sd, 'e', None)]
    return pts, links


CELLS[902]['bell'] = rim_bell(1637, 160)



# small pieces left in the gaps: a crook under each lowest eave of the pagoda (curling away from the eave tip), a hook
# at the right end (1648) curling away from the star
fill_rows(CELLS[902], [('eave_R', 1655, 'Crook', 'bow out', 1.0, 185, 0, True),
                       ('end_R', 1648, 'Hook', 'bow out', 1.0, 200, 0, True)])
CELLS[902]['eave_L'] = mirror_pieces({'p': CELLS[902]['eave_R']}, 'earth')['p']


# Hub cell 80 belongs to Chaos (swirls into the centre, user 2026-11-18): drawn in design/dao-do/cells/chaos.py.
CELLS[80] = {}
