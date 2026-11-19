"""Earth (axis 72): mountains, terraces, a gate or castle. Every cell placed by hand, cell by cell (BRIEF.md).

Land-local polar points: E(r, th) = L(r, th, 'earth'); th + is towards +theta (right in the axis-down render).
Angles for orbit()/place(): 0 = towards the tree centre (up in the render), 90 = +theta (right), 180 = outward (down).
Pieces never link to each other; each hangs from road nodes only (ints).
"""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
from celllib import L, orbit, road, fill_rows, mirror_pieces  # noqa: E402

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


def cirque(O, entry, ang_in, rho=1.15, rho_p=2.3, peaks=(2, 3)):
    """A cirque (a ring of peaks round a high basin): five ring nodes round O (step 72, ring node 0 facing `ang_in`
    takes the entry) and peak notables rising straight out from the ring nodes `peaks` to rho_p."""
    angs = [ang_in + 72 * i for i in range(5)]
    pts = on(O, rho, angs, ['small'] * 5, 'r')
    for k in peaks:
        pts[f'p{k}'] = (orbit(O, rho_p, angs[k]), 'notable')
    return pts, ([(entry, 'r0', None)] + run(ks('r', 5) + ['r0'], O) + [(f'r{k}', f'p{k}', None) for k in peaks])


def ridges(H, entry, ang_c, spread=45, rho=1.2):
    """A mountain spur seen from above: a hub at H and three ridges of two nodes each at `ang_c` and `ang_c` +-
    `spread` (rho and 2 rho from H, straight links), the ridge ends notables; the entry joins the hub."""
    pts, links = {'hub': (H, 'small')}, [(entry, 'hub', None)]
    for j, a in enumerate((ang_c - spread, ang_c, ang_c + spread)):
        pts[f'r{j}a'] = (orbit(H, rho, a), 'small'); pts[f'r{j}b'] = (orbit(H, 2 * rho, a), 'notable')
        links += [('hub', f'r{j}a', None), (f'r{j}a', f'r{j}b', None)]
    return pts, links


def rampart(O, rho_m, rho_w, angs, entry, notables):
    """A curtain wall on an orbit round O: nodes at the angles `angs`, merlons (even) on rho_m and the wall walk (odd)
    on rho_w, straight links; hung by its first node from `entry`; notables at the indices `notables`."""
    pts = {f'm{i}': (orbit(O, rho_m if i % 2 == 0 else rho_w, a), 'notable' if i in notables else 'small')
           for i, a in enumerate(angs)}
    return pts, [(entry, 'm0', None)] + run(ks('m', len(angs)))


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
CELLS[24]['castle'] = castle(E(49.0, -32.6), 235, -95)
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


# consolidated 2026-11-18: the Hook off 1661 and the Crescent off 1678 became the pyramid's outer bailey, a
# crenellated wall of seven on an orbit round the pyramid, hung from 1660, notables at its far end and middle merlon
CELLS[78]['pyramid'] = pyramid(-17.0, 1676)
CELLS[78]['bailey'] = rampart(E(60.4, -17.0), 4.9, 4.0, [-12 + 18 * i for i in range(7)], 1660, (3, 6))


# ---- cell 40 (53.9-64.3, th -36..-23, the border cluster on its left wall): the peak's left petal in the top-right
# corner; centre figure a castle keep: a square courtyard loop (corners and wall middles), tower notables at the two
# inner corners and a keep notable in the courtyard hung from the inner wall. Fill: a Crook and a Tadpole ----------
def keep(cr, cth, half_r, half_th, entry):
    c = {'bl': (cr + half_r, cth - half_th), 'bm': (cr + half_r, cth), 'br': (cr + half_r, cth + half_th),
         'mr': (cr, cth + half_th), 'tr': (cr - half_r, cth + half_th), 'tm': (cr - half_r, cth),
         'tl': (cr - half_r, cth - half_th), 'ml': (cr, cth - half_th)}
    kinds = {'tr': 'notable', 'tl': 'notable'}
    pts = {k: (E(r, th), kinds.get(k, 'small')) for k, (r, th) in c.items()}
    pts['keep'] = (E(cr + 0.2, cth), 'notable')
    order = ['bm', 'br', 'mr', 'tr', 'tm', 'tl', 'ml', 'bl', 'bm']
    edges = [(order[i], order[i + 1], None) for i in range(len(order) - 1)] + [('tm', 'keep', None)]
    return graph([(entry, 'bm')], pts, edges)


CELLS[40]['keep'] = keep(59.4, -29.4, 2.0, 1.7, 1673)
fill_rows(CELLS[40], [
    ('crook',    1671, 'Crook', 'bow in', 1.6, 10, 0, True),
    ('crook2',   1657, 'Crook', 'swept', 1.3, 150, 0, True),
])

# =====================================================================================================================
# Combo B', the mirror of the terraced peak on road node 1666 (th +23): cells 23, 75 and 48 are the mirrors of 24,
# 78 and 40 (PoE 2 mirrors about half of a class area). In each copy one small piece is changed.
# =====================================================================================================================
c23 = mirror_pieces({k: v for k, v in CELLS[24].items() if k != 'castle'}, 'earth')
# the castle of 24 is not mirrored: cell 23's border piece (a Wheel before 2026-11-18) is a mountain gate instead
c23['gate'] = mountain_gate(orbit(road(254), 3.3, -95), 85, 254)
CELLS[23] = c23
c75 = mirror_pieces({k: v for k, v in CELLS[78].items() if k != 'bailey'}, 'earth')
c75.update(mirror_pieces({'bailey': rampart(E(60.4, -17.0), 4.9, 4.0, [-12 + 18 * i for i in range(6)], 1660, (3, 5))},
                         'earth'))                       # one merlon shorter than 78's, leaving room for the fork
fill_rows(c75, [  # in the corner where 78 had a Crescent
    ('fork', 1688, 'Crook', 'swept', 1.4, 50, 0, True),
])
CELLS[75] = c75
c48 = mirror_pieces({k: v for k, v in CELLS[40].items() if k not in ('crook', 'keep', 'crook2')}, 'earth')
c48['keep'] = keep(59.4, 28.6, 2.0, 1.7, 1683)                                  # the hex sits closer here
fill_rows(c48, [  # was a Crook by the border cluster
    ('top48', 1664, 'Hook', 'bow in', 1.2, 190, 0, False),
    ('foot48', 1681, 'Hook', 'bow out', 1.0, -10, 0, True),
])
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
    'terrace3': terrace(51.3, -15.2, -8.0, 7, 1661, 4),
}
fill_rows(CELLS[36], [
    ('foot36',   1663, 'Crook', 'bow in', 1.2, -20, 0, True),
])


# ---- cell 19 (41.7-53.9, th 0..18, the axis hex on its left wall): a mountain range. A ridge of three peaks crosses
# the cell between outer-ring road nodes 1670 and 1667, a notable at each summit, the middle peak the tallest ------
def ridge():
    pts = [(52.0, 4.6, 's'), (49.4, 5.6, 's'), (46.8, 6.6, 'N'), (48.4, 7.7, 's'), (50.0, 8.7, 's'), (47.5, 9.7, 's'),
           (45.0, 10.8, 'N'), (47.3, 11.9, 's'), (49.6, 13.0, 's'), (48.4, 14.0, 's'), (47.2, 15.0, 'N'),
           (49.5, 15.7, 's'), (51.8, 16.3, 's')]
    nodes = {f'k{i}': (E(r, t), 'notable' if k == 'N' else 'small') for i, (r, t, k) in enumerate(pts)}
    links = [(1670, 'k0', None), (f'k{len(pts) - 1}', 1667, None)] + [(f'k{i}', f'k{i + 1}', None) for i in range(len(pts) - 1)]
    return nodes, links


# consolidated 2026-11-18: the Ring off 1634 and the Hook off 1633 became a small hill fort (castle of eight, towers
# and walls on two orbits) above the ridge's east peak, its gate on 1634
CELLS[19] = {'ridge': ridge(), 'fort': castle(E(44.3, 13.9), 1634, -10, rho_t=1.55, rho_w=0.95)}
fill_rows(CELLS[19], [
    ('top19a', 1635, 'Crescent', 'bow in', 1.2, 180, 0, False),
    ('foot19', 1668, 'Diamond', 'round', 1.0, 0, 0, False),
    ('mid19b', 1669, 'Crescent', 'bow in', 1.0, 0, 0, False),
])

# ---- cell 65 (inner band 33.2-41.7, th -23..0): a pagoda. A spine rises from the outer road node 1627 with three
# tiers of flat eaves (each tier a closed triangle back to the spine) and a spire notable at the top -----------------
def pagoda(cth, entry):
    """A tapered pagoda frame: a spine with three level bars, the bar ends joined up each side to a spire."""
    bars = [(40.2, 3.4), (38.3, 2.6), (36.4, 1.8)]           # (r, half-width in degrees)
    pts, edges = {}, []
    for k, (r, hw) in enumerate(bars):
        kind = 'notable' if k == 1 else 'small'
        pts[f's{k}'] = (E(r, cth), 'small'); pts[f'l{k}'] = (E(r, cth - hw), kind); pts[f'r{k}'] = (E(r, cth + hw), kind)
        edges += [(f'l{k}', f's{k}', None), (f's{k}', f'r{k}', None)]
        if k:
            edges += [(f's{k - 1}', f's{k}', None), (f'l{k - 1}', f'l{k}', None), (f'r{k - 1}', f'r{k}', None)]
    pts['spire'] = (E(34.6, cth), 'notable')
    edges += [('s2', 'spire', None), ('l2', 'spire', None), ('r2', 'spire', None)]
    return graph([(entry, 's0')], pts, edges)


# consolidated 2026-11-18: the Crook off 1616 and the Diamond off the axis node 102 became a trail winding up a knoll
# between the pagoda and the axis (an outer arc of four, an inner arc of three walked back, a summit notable);
# cell 66 carries its mirror
TRAIL65 = switchback(E(37.8, -5.2), 2.3, [85, 50, 15, -20, -55], 1.15, [-55, 5], 102)
CELLS[65] = {'pagoda': pagoda(-13.0, 1627), 'trail': TRAIL65}
fill_rows(CELLS[65], [
    ('c65', 1614, 'Hook', 'bow in', 1.2, 170, 0, True),
])


# ---- cell 66 (inner band, th 0..23): a stairway. A right-angled stair climbs from outer road node 1634 to inner road
# node 1620, alternating along-ring treads and radial risers, notables on two landings -----------------------------
def stairway():
    pts = [(40.2, 12.6, 's'), (40.2, 14.4, 's'), (38.7, 14.4, 'N'), (38.7, 16.2, 's'), (37.2, 16.2, 's'),
           (37.2, 18.0, 's'), (35.7, 18.0, 'N'), (35.7, 19.6, 's'), (34.6, 19.8, 's')]
    nodes = {f'q{i}': (E(r, t), 'notable' if k == 'N' else 'small') for i, (r, t, k) in enumerate(pts)}
    links = [(1634, 'q0', None), ('q8', 1620, None)] + [(f'q{i}', f'q{i + 1}', None) for i in range(len(pts) - 1)]
    return nodes, links


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

# ---- cell 8 (outer band 64.3-74.3, th -17..0): the great wall. A long battlement wall with square merlons runs
# along the band from outer-ring node 1642 to the axis node 1489, notables on three merlon tops; above it a mesa
# hung from the inner ring, small pieces round them ----------------------------------------------------------------
def battlement():
    low, high = 70.6, 69.0                                    # wall walk and merlon tops (inward = smaller r)
    seq = [(71.9, -14.0, 's')]                                # foot by 1642
    th, k = -13.6, 0
    while th < -2.0:
        top = 'N' if k in (1, 3) else 's'
        seq += [(low, th, 's'), (high, th, 's'), (high, th + 1.25, top), (low, th + 1.25, 's')]
        th += 2.5; k += 1
    seq.append((70.2, -1.3, 's'))                             # last step to the axis node 1489
    nodes = {f'w{i}': (E(r, t), 'notable' if k == 'N' else 'small') for i, (r, t, k) in enumerate(seq)}
    links = [(1642, 'w0', None), (f'w{len(seq) - 1}', 1489, None)] + [(f'w{i}', f'w{i + 1}', None) for i in range(len(seq) - 1)]
    return nodes, links


# consolidated 2026-11-18: the Crescent (1677) and the Fork (1679) became one mesa hung from 1678 between them, a
# terrace band of two flat arcs round a centre below the wall (a hill's contours), notables at the inner corners
MESA8 = E(72.3, -9.0)
CELLS[8] = {'wall': battlement(),
            'mesa': band(MESA8, 6.4, [-26, -13, 0, 13, 26], 4.9, [-17, 0, 17], 1678, 'o1', ('i0', 'i2'))}
fill_rows(CELLS[8], [('a8', 1677, 'Crescent', 'bow in', 1.0, 200, 0, False)])   # the old Crescent back, clear of the mesa
fill_rows(CELLS[8], [
    ('c8', 1488, 'Crook', 'bow out', 1.2, 230, 0, True),
    ('d8', 1645, 'Hairpin', 'bow out', 1.0, -45, 0, False),
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
# and the Crook off 1686 and the Hook off 1652 became terrace steps (a ladder of four rungs bent on an orbit) climbing
# the east side from 1652, notables on the top rung
CELLS[16]['steps'] = ladder(E(69.2, 20.0), 6.9, 5.7, [-111, -97, -83, -69], 1652, ('o3', 'i3'))
fill_rows(CELLS[16], [
])

# ---- cell 51 (outer band, th -28..-17): a cave. A horseshoe arc (open towards the outer ring) hangs from inner-ring
# node 1675 round a hollow, a treasure notable hanging inside from its roof ---------------------
def cave(O, rho, entry):
    angs = (-150, -115, -80, -45, 0, 45, 80, 115, 150)       # round from lower left over the top to lower right
    kinds = ['notable' if a in (-150, 150) else 'small' for a in angs]; kinds[4] = 'small'
    pts = {f'v{i}': (orbit(O, rho, a), k) for i, (a, k) in enumerate(zip(angs, kinds))}
    pts['gem'] = (orbit(O, 0.5, 180), 'notable')            # the treasure, hung inside the hollow from the roof
    return pts, [(entry, 'v4', None), ('v3', 'gem', None)] + [(f'v{i}', f'v{i + 1}', O) for i in range(len(angs) - 1)]


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
    ('a106', 508, 'Hook', 'bow in', 1.0, -70, 0, False),
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
# connector runs out at +30..+33). Two figures: a cliff stair stepping outward from ring node 1645 towards the axis,
# and a valley, an inverted arch dipping between ring nodes 1655 and 1654. Two keystones just past the hook ends.
# Round them (2026-11-18) medium figures hang outward from the ring and beside the axis road; a few catalogue pieces.
# =====================================================================================================================
def rim_stair():
    pts = [(76.0, -5.5, 's'), (76.0, -4.1, 's'), (77.6, -4.1, 'N'), (77.6, -2.7, 's'), (79.2, -2.7, 's'), (80.8, -2.3, 'N')]
    nodes = {f'z{i}': (E(r, t), 'notable' if k == 'N' else 'small') for i, (r, t, k) in enumerate(pts)}
    return nodes, [(1645, 'z0', None)] + [(f'z{i}', f'z{i + 1}', None) for i in range(len(pts) - 1)]


def rim_valley():
    pts = [(75.7, 5.3, 's'), (76.7, 5.9, 's'), (77.1, 6.75, 'N'), (76.7, 7.6, 's'), (75.7, 8.2, 's')]
    nodes = {f'y{i}': (E(r, t), 'notable' if k == 'N' else 'small') for i, (r, t, k) in enumerate(pts)}
    return nodes, [(1655, 'y0', None), ('y4', 1654, None)] + [(f'y{i}', f'y{i + 1}', None) for i in range(len(pts) - 1)]


CELLS[902] = {
    'stair': rim_stair(),
    'valley': rim_valley(),
    'keystone_w': ({'k': (E(81.8, -12.3), 'keystone')}, [(1961, 'k', None)]),
    'keystone_e': ({'k': (E(81.8, 12.3), 'keystone')}, [(1962, 'k', None)]),
}
# consolidated 2026-11-18, four rim figures hanging outward into the open band:
#   terraces (hub + two nested arcs) from 1639, replacing the Hook there and the Spur pair off 1638;
#   a spur of three ridges from 1641, grown from the Fork there;
#   a mountain gate (double arch) from 1649, replacing the Crescent off 1650 and the Hook off 1648;
#   a caldera beside the axis road from 501, replacing the Tadpole there and the Crook off 404.
CELLS[902]['terraces'] = terrace_fan(1639, orbit(road(1639), 1.2, 180), 180, rho_i=1.4, rho_o=2.7)
CELLS[902]['spur'] = ridges(orbit(road(1641), 1.3, 180), 1641, 180)
CELLS[902]['gate'] = mountain_gate(orbit(road(1649), 3.2, 180), 0, 1649, rho_o=2.2, rho_i=1.15)
CELLS[902]['caldera'] = caldera(orbit(road(501), 2.5, 90), 501, -90, rho=1.45, notables=())
CELLS[902]['peak'] = peak_fan(orbit(road(1652), 2.4, 180), 1.8, 180, 1652, 0, stem=1.2, mid='small')   # grown from the Hook off 1652
# and two new rim figures (Earth's density is the lowest of the five lands): a ring of six stones round an altar off
# the corner node 1637 and a fallen stone (a lens of eight lying along the ring) off 1651
CELLS[902]['stones'] = henge(orbit(road(1637), 2.6, 180), 1637, 0, rho=1.5, n=6, notables=(2, 4))
CELLS[902]['boulder'] = lens(E(77.6, 16.8), E(77.6, 21.6), 0.9, 3, 1651, 2)
fill_rows(CELLS[902], [
    ('r7', 1227, 'Ring', 'round', 1.2, 90, 0, False),
])

# consolidated 2026-11-18: the Tadpole off 1674 grew into a caldera (a rim of six round a vent notable)
CELLS[40]['caldera'] = caldera(orbit(road(1674), 3.2, -38), 1674, 142, notables=())
fill_rows(CELLS[48], [('dz48a', 1665, 'Ring', 'round', 1.0, 150, 0, False)])
fill_rows(CELLS[48], [('dz48b', 1684, 'Crook', 'swept', 1.4, 60, 0, False)])
fill_rows(CELLS[51], [('dz51a', 1674, 'Diamond', 'round', 1.0, 180, 0, False)])
CELLS[51]['peak'] = peak_fan(orbit(road(1959), 2.1, 50), 1.8, 40, 1959, -130, mid='small')
fill_rows(CELLS[51], [('dz51b', 1641, 'Hairpin', 'bow out', 1.0, -40, 0, False)])
# consolidated 2026-11-18: the Fork off 1612 and the Crescent off 1611 became a cirque (a ring of five with two peaks)
CELLS[117]['cirque'] = cirque(E(36.0, -28.4), 1612, 45, peaks=(1, 3))
CELLS[114]['cirque'] = cirque(E(36.0, 28.4), 1618, -45, peaks=(1, 2))   # 114's own: both peaks on the east side; its Hairpin is now a Hook
fill_rows(CELLS[114], [('a114', 1519, 'Hook', 'bow in', 1.2, -100, 0, True)])   # the Crook off 1617 gave way to the cirque
fill_rows(CELLS[66], [('dz66', 1633, 'Diamond', 'round', 1.0, 0, 0, False)])
fill_rows(CELLS[104], [('dz104', 1672, 'Hairpin', 'bow out', 1.0, 155, 0, False)])
fill_rows(CELLS[106], [('dz106', 1682, 'Hook', 'bow out', 1.0, 190, 0, False)])
fill_rows(CELLS[902], [('dz902a', 1644, 'Diamond', 'round', 1.0, 180, 0, False)])
