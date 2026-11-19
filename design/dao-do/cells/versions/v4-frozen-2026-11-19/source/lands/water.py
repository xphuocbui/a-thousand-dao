"""Water (axis 216): waves, ripples, a lotus, whirlpools. Placed by hand, cell by cell (BRIEF.md, rules 3.10 C).

Every number below is chosen by hand; the helpers only turn a hand-chosen description (centre, radius, angles,
kinds) into nodes and links. Angles: ang 0 = towards the tree centre, + = towards +theta (land-local th grows to the
right in render_land's view). Combos across cells:
  LOTUS  - centred on road node 1499 (axis x ring 64.3): one petal in each of cells 91, 86, 11, 17.
  WAVE   - an S-curve flowing out of road node 1985 (spoke -11): crest curling in cell 76, trough curling in 91;
           mirrored with 76 -> 69 and 91 -> 86 (road node 1986).
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from celllib import L, road, orbit, direction, bow_centre, fill_rows, mirror_pieces  # noqa: E402

THEME = 'water'
LAND = 'water'


# --- figure helpers (geometry only) -------------------------------------------------------------------------------
def curve(O, pts, kinds, entry, entry_arc=False, bow=None):
    """A chain of nodes at (radius, ang) round centre O, entered from road node `entry`. Consecutive nodes on the same
    radius are joined by an arc round O, others by a straight link (or, with `bow`, by an arc bulging away from O with
    sagitta bow x chord, so a spiral winds round instead of stepping in straight lines; review pass 2026-11-18)."""
    nodes, links = {}, []
    for k, ((rho, a), kind) in enumerate(zip(pts, kinds)):
        nodes[f'n{k}'] = (orbit(O, rho, a), kind)
    links.append((entry, 'n0', O if entry_arc else None))
    for k in range(1, len(pts)):
        same = abs(pts[k][0] - pts[k - 1][0]) < 1e-9 and abs(pts[k][1] - pts[k - 1][1]) < 179
        radial = abs(pts[k][1] - pts[k - 1][1]) < 1e-9
        if same:
            how = O
        elif bow and not radial:
            how = bow_centre(nodes[f'n{k - 1}'][0], nodes[f'n{k}'][0], bow, O)
        else:
            how = None
        links.append((f'n{k - 1}', f'n{k}', how))
    return nodes, links


def circumcentre(p, q, s):
    """The centre of the circle through three points."""
    ax, ay = p; bx, by = q; cx, cy = s
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return (ux, uy)


def braid(O, R, angs, w, entry, kinds, delta=None):
    """A BRAIDED CURRENT: junction nodes X0..Xk on the circle of radius R round O at angles `angs`, each pair of
    junctions joined by a lens (two side nodes at radii R +- w half-way between, each side one circular arc through
    the two junctions); entered at X0 from road node `entry`. `delta` = (ang, w2): the braid opens past the last
    junction into two arms ending at radii R +- w2 at that angle (bowed arcs). kinds {key: kind}, default small."""
    nodes = {f'X{k}': orbit(O, R, a) for k, a in enumerate(angs)}
    links = [(entry, 'X0', None)]
    for k in range(len(angs) - 1):
        m = (angs[k] + angs[k + 1]) / 2
        for side, rr in (('a', R + w), ('b', R - w)):
            p = orbit(O, rr, m)
            nodes[f'{side}{k}'] = p
            c = circumcentre(nodes[f'X{k}'], p, nodes[f'X{k + 1}'])
            links += [(f'X{k}', f'{side}{k}', c), (f'{side}{k}', f'X{k + 1}', c)]
    if delta:
        da, w2 = delta
        last = f'X{len(angs) - 1}'
        for side, rr in (('da', R + w2), ('db', R - w2)):
            nodes[side] = orbit(O, rr, da)
            links.append((last, side, bow_centre(nodes[last], nodes[side], 0.15, O if side == 'da' else
                                                 orbit(O, 2 * R, da))))
    return {k: (p, kinds.get(k, 'small')) for k, p in nodes.items()}, links


def petal(entry, ang, stem, length, width, bow=0.18, kinds=('small', 'small', 'small', 'notable')):
    """A lens-shaped petal hung from road node `entry` along direction `ang`: entry node, two side nodes, notable tip."""
    R = road(entry)
    D = direction(R, ang)
    Nv = (-D[1], D[0])
    e = (R[0] + stem * D[0], R[1] + stem * D[1])
    m = (e[0] + 0.48 * length * D[0], e[1] + 0.48 * length * D[1])
    s1 = (m[0] + width * Nv[0], m[1] + width * Nv[1])
    s2 = (m[0] - width * Nv[0], m[1] - width * Nv[1])
    tip = (e[0] + length * D[0], e[1] + length * D[1])
    cen = ((e[0] + tip[0]) / 2, (e[1] + tip[1]) / 2)
    nodes = {'e': (e, kinds[0]), 's1': (s1, kinds[1]), 's2': (s2, kinds[2]), 'tip': (tip, kinds[3])}
    links = [(entry, 'e', None)]
    for a, b in (('e', 's1'), ('s1', 'tip'), ('e', 's2'), ('s2', 'tip')):
        links.append((a, b, bow_centre(nodes[a][0], nodes[b][0], bow, cen)))
    return nodes, links


def fig(O, pts, links):
    """A hand-drawn figure round centre O: pts {key: (rho, ang, kind)} (orbit positions), links [(a, b, how)] with
    how 'o' = an arc round O (both ends on one radius), None = straight, a number = a bowed arc (sagitta = that x the
    chord, + bulging away from O), or an explicit arc centre; road nodes as ints."""
    nodes = {k: (orbit(O, rho, a), kind) for k, (rho, a, kind) in pts.items()}
    out = []
    for a, b, how in links:
        if how == 'o':
            assert abs(pts[a][0] - pts[b][0]) < 1e-9, (a, b)
            out.append((a, b, O))
        elif isinstance(how, (int, float)):
            out.append((a, b, bow_centre(nodes[a][0], nodes[b][0], how, O)))
        elif isinstance(how, tuple) and how[0] in ('L', 'R'):     # bulge to the left / right of a -> b (render view)
            p = nodes[a][0] if a in nodes else road(a)
            q = nodes[b][0] if b in nodes else road(b)
            m = ((p[0] + q[0]) / 2, (p[1] + q[1]) / 2)
            nx, ny = -(q[1] - p[1]), q[0] - p[0]
            sg = 1 if how[0] == 'L' else -1
            out.append((a, b, bow_centre(p, q, how[1], (m[0] - sg * nx, m[1] - sg * ny))))
        else:
            out.append((a, b, how))
    return nodes, out


def uv_fig(O, ang, pts, links):
    """A hand-drawn figure in a local frame at O: u along orbit angle `ang`, v along `ang` + 90. pts {key: ((u, v),
    kind)}, links [(a, b, how)] with how None = straight or (u, v) = the arc centre in the same frame (checked to be
    equidistant from both ends); road nodes as ints."""
    U, V = direction(O, ang), direction(O, ang + 90)
    def W(u, v): return (O[0] + u * U[0] + v * V[0], O[1] + u * U[1] + v * V[1])
    nodes = {k: (W(*uv), kind) for k, (uv, kind) in pts.items()}
    out = []
    for a, b, how in links:
        if how is not None:
            ra, rb = math.dist(pts[a][0], how), math.dist(pts[b][0], how)
            assert abs(ra - rb) < 0.03, (a, b, ra, rb)
            how = W(*how)
        out.append((a, b, how))
    return nodes, out


CELLS = {}

# ================================================================================================================
# Cell 91 (middle band r 53.9-64.3, th -11..0). Holds the WAVE trough (curling out of 1985) and the LOTUS petal
# reaching up-left from 1499; round them the meniscus, the lotus halo and a Diamond off the axis node.
# ================================================================================================================
C1 = orbit(road(1985), 2.2, -90)          # crest circle, on the -theta side of 1985 (cell 76)
C2 = orbit(road(1985), 2.2, 90)           # trough circle, on the +theta side (cell 91)
# Consolidated 2026-11-18: the trough curls one node further in than the crest (so the two halves differ); a
# MENISCUS (a swag bridging 1868-1869 with a shorter concentric arc hung inside it) replaces the Ring and Hairpin off
# the top road; a SPLASH CROWN off 1885 (w1: a filled cup; w2: the lotus halo below) replaced the Crook off 1885 and
# the Spur pair off 1884.
O91m = L(53.9, -5.45, LAND)
c91 = {
    'wave_trough': curve(C2, [(2.2, -140), (2.2, 180), (2.2, 140), (2.0, 95), (1.5, 50), (1.0, 5), (0.6, -60)],
                         ['small'] * 6 + ['notable'], 1985, bow=0.1),
    'lotus_petal': petal(1499, -45, 1.0, 3.0, 0.8),
    'meniscus': fig(O91m, {'s0': (2.6, -120, 'small'), 's1': (2.6, -150, 'small'), 's2': (2.6, 180, 'small'),
                           's3': (2.6, 150, 'small'), 's4': (2.6, 120, 'small'), 'm': (1.4, 180, 'small'),
                           'i0': (1.4, -135, 'notable'), 'i1': (1.4, 135, 'notable')},
                    [(1868, 's0', None), ('s0', 's1', 'o'), ('s1', 's2', 'o'), ('s2', 's3', 'o'), ('s3', 's4', 'o'),
                     ('s4', 1869, None), ('s2', 'm', None), ('m', 'i0', 'o'), ('m', 'i1', 'o')]),
}
# Review pass 2026-11-18 (w2): the filled cup (a closed bucket on a long straight stem from 1885, a second U under the
# meniscus) gives way to the LOTUS HALO: an arc of 7 on an outer orbit round the lotus centre 1499 (radius 6.3, angles
# -78 to -30), rising from 1885 over the petals; with its mirror in 86 the flower sits inside two arcs (cell 14's
# grammar at the combo's scale). Notables at its middle and top end (7 nodes, -1; 8 at 7-degree steps read as beads).
c91['halo'] = fig(road(1499), {f'h{k}': (6.3, a, 'notable' if k in (3, 6) else 'small')
                               for k, a in enumerate((-78, -70, -62, -54, -46, -38, -30))},
                  [(1885, 'h0', None)] + [(f'h{k}', f'h{k + 1}', 'o') for k in range(6)])
fill_rows(c91, [
    ('D drop',     1498, 'Diamond', 'round', 1.0, -45, 0, False),
])
CELLS[91] = c91

# Cell 76 (middle band, th -23..-11). Holds the WAVE crest curling over into the cell. Consolidated 2026-11-18: an
# EDDY (a spiral of 8 winding in from 1866, notables half-way and at the eye) replaces the Tadpole off 1866 and the
# Crescent off 1865; a scallop (now the braid below) replaced the Fork off 1881 and the Diamond off 1882.
O76e = L(56.6, -19.6, LAND)
EDDY = [(1.9, 30), (1.85, -15), (1.75, -60), (1.6, -105), (1.4, -150), (1.2, 165), (1.0, 120), (0.75, 75)]
c76 = {
    'wave_crest': curve(C1, [(2.2, 40), (2.2, 0), (2.2, -40), (2.0, -85), (1.5, -130), (1.0, -175)],
                        ['small', 'small', 'small', 'small', 'small', 'notable'], 1985, bow=0.1),
    'eddy': curve(O76e, EDDY, ['small'] * 3 + ['notable'] + ['small'] * 3 + ['notable'], 1866, bow=0.1),
}
# Review pass 2026-11-18 (w1): the scallop (a shell of straight rays) gives way to a BRAIDED CURRENT rising from 1882,
# three lens beads (junctions on an arc of radius 6.5 round a point on the +theta side, each side one circular arc),
# notables at the second junction, the top lens's outer side and the top junction.
c76['braid'] = braid(L(61.12, -11.56, LAND), 6.5, (-106, -87, -68, -49), 0.55, 1882,
                     {'X1': 'notable', 'a2': 'notable', 'X3': 'notable'})
CELLS[76] = c76

# Cell 86 = cell 91 mirrored across the axis (WAVE trough from 1986, LOTUS petal up-right, meniscus, lotus halo),
# one change: the Diamond off the axis node is cusped. (The Wheel off 1876 went with the consolidation.)
c86 = mirror_pieces({k: v for k, v in c91.items() if k not in ('D_drop',)}, LAND)
fill_rows(c86, [('D drop', 1498, 'Diamond', 'cusped', 1.0, 45, 0, True)])
CELLS[86] = c86

# Cell 69 = cell 76 mirrored (WAVE crest from 1986, the eddy from 1873), with its own big figure instead of the braid.
# (A leaping carp, now the pearl below, replaced the Spur pair off 1891 and the Hairpin off 1892.)
c69 = mirror_pieces({k: v for k, v in c76.items() if k != 'braid'}, LAND)
# Review pass 2026-11-18 (w1): the leaping carp (a picture with straight fins) gives way to a PEARL IN THE CURRENT, cell
# 14's grammar in one piece: a ring of 4 round the centre inside two arcs on an outer orbit, tied to it radially at
# its sides, entered from 1892 at the ring's foot through the gap between the arcs; the four arc ends notables.
c69['pearl'] = fig(L(61.2, 17.4, LAND),
                   {**{f'q{a}': (0.9, a, 'small') for a in (0, 90, 180, 270)},
                    **{f'l{a}': (2.3, a, 'small' if a == 270 else 'notable') for a in (225, 270, 315)},
                    **{f'r{a}': (2.3, a, 'small' if a == 90 else 'notable') for a in (45, 90, 135)}},
                   [(1892, 'q180', None), ('l225', 'l270', 'o'), ('l270', 'l315', 'o'), ('l270', 'q270', None)] +
                   [(f'q{a}', f'q{(a + 90) % 360}', 'o') for a in (0, 90, 180, 270)] +
                   [('q90', 'r90', None), ('r90', 'r45', 'o'), ('r90', 'r135', 'o')])
CELLS[69] = c69


def ripple(centre_road, side, inner, outer_entry, outer_angs, r_in=1.9, r_out=3.24):
    """RIPPLE halves round road node `centre_road`: an inner arc hung from the centre node itself and an outer arc hung
    from `outer_entry` (a ring neighbour); `side` +1 = +theta side of the spoke, -1 = -theta side."""
    O = road(centre_road)
    a_in = [side * a for a in inner]
    a_out = [side * a for a in outer_angs]
    p_in = curve(O, [(r_in, a) for a in a_in], ['small'] * (len(a_in) - 1) + ['notable'], centre_road)
    on_circle = abs(math.dist(road(outer_entry), O) - r_out) < 0.05
    p_out = curve(O, [(r_out, a) for a in a_out], ['small'] * (len(a_out) - 1) + ['notable'], outer_entry, entry_arc=on_circle)
    return p_in, p_out


# ================================================================================================================
# Cell 11 (outer band r 64.3-74.3, th -17..0). Centre figure: a WHIRLPOOL, a spiral winding clockwise in from the
# bottom road (1804) to a notable eye, a notable half-way round. With the LOTUS petal down-left from 1499 and the
# fill: a Crescent in the bottom-left corner and the figures below. (A corner RIPPLE round 1801 was
# tried and dropped: between spoke and ring it only had about 70 degrees of arc and read as a tangle.)
# ================================================================================================================
O11 = L(69.3, -8.6, LAND)
SPIRAL = [(3.4, 180), (3.35, 205), (3.25, 230), (3.1, 255), (2.95, 280), (2.8, 305), (2.6, 330), (2.4, 355),
          (2.15, 22), (1.9, 52), (1.6, 87), (1.3, 128), (1.0, 178)]
# Consolidated 2026-11-18: a POND (a ring of 8 off 1883 with a ring of 4 inside it, one radial link between them)
# replaces the Ring off 1883 and the Ring off 1803; a CURRENT (an arc of 7 on an outer orbit round the whirlpool's own
# centre, entered from 1805) replaces the Fork off 1806 and the Ring off 1805.
O11p = L(67.5, -14.2, LAND)
CUR = (145, 125, 105, 85, 65, 45, 25)
# (review pass 2026-11-18, w1: the whirlpool's links are arcs, bow 0.1, no longer straight steps)
c11 = {
    'whirlpool': curve(O11, SPIRAL, ['small'] * 6 + ['notable'] + ['small'] * 5 + ['notable'], 1804, bow=0.1),
    'lotus_petal': petal(1499, -135, 1.0, 3.2, 0.85),
    'pond': fig(O11p, {**{f'o{a}': (1.85, a, 'notable' if a in (135, 270) else 'small') for a in range(0, 360, 45)},
                       **{f'i{a}': (0.8, a, 'notable' if a == 180 else 'small') for a in range(0, 360, 90)}},
                [(1883, 'o0', None)] + [(f'o{a}', f'o{(a + 45) % 360}', 'o') for a in range(0, 360, 45)] +
                [(f'i{a}', f'i{(a + 90) % 360}', 'o') for a in range(0, 360, 90)] + [('o90', 'i90', None)]),
    'current': curve(O11, [(4.5, a) for a in CUR], ['small'] * 3 + ['notable'] + ['small'] * 2 + ['notable'], 1805),
}
fill_rows(c11, [
    ('C crescent', 1802, 'Crescent', 'bow in', 1.1, 0, 0, False),
])
CELLS[11] = c11

# ================================================================================================================
# Cell 17 (outer band, th 0..17), cell 11's mirror partner with its own composition. Centre figure: a KOI PAIR, two
# arcs chasing round one circle (one entered from the top road, one from the bottom), each with an eye on an inner swag
# and a notable head. With the LOTUS petal down-right from 1499 (cell 11's petal mirrored, so the flower is even).
# ================================================================================================================
O17 = L(69.3, 8.6, LAND)
RK = 2.6


def koi(entry, angs, eye_at, eye_ang, head='notable'):
    # Review pass 2026-11-18 (w1): the eye no longer sits on a straight stick from the back; it is the middle of an
    # inner swag (one circle through the back nodes either side of it and the eye), so each koi is a crescent; the
    # notable moves from the eye to the node before the head.
    pts = [(RK, a) for a in angs]
    nodes, links = curve(O17, pts, ['small'] * (len(pts) - 2) + ['notable', head], entry)
    nodes['eye'] = (orbit(O17, 1.45, angs[eye_at]), 'small')
    a, b = f'n{eye_at - 1}', f'n{eye_at + 1}'
    c = circumcentre(nodes[a][0], nodes['eye'][0], nodes[b][0])
    links += [(a, 'eye', c), ('eye', b, c)]
    return nodes, links


c17 = {
    'koi_a': koi(1894, (25, 60, 95, 130, 160), 2, 80),
    'koi_b': koi(1814, (205, 240, 275, 310, 340), 2, 260),
    'lotus_petal': mirror_pieces({'p': petal(1499, -135, 1.0, 3.2, 0.85)}, LAND)['p'],
}
# Consolidated 2026-11-18: a seahorse (now the meander below) replaced the Tadpole off 1816 and the Ring off 1815; a
# WATER GOURD (ho lo: a ring of 4 hung from 1893 above a ring of 7, one neck link) replaces the Diamond off
# 1893, the Diamond off 1892 and the Arch off 1812.
# Review pass 2026-11-18 (w1): the seahorse (a creature, a straight snout and fin) gives way to a MEANDER, a stream
# rising from 1816 in three half-circle bends (radius 1.0) swinging alternately towards the koi and the axis, each
# bend three links on its own circle; notables at the first two bends' outer points and at the stream's head.
_MD = {}
_ml = [(1816, 'n0', None)]
for _b in range(3):
    _cu, _sg = -2.0 + 2.0 * _b, (1 if _b % 2 == 0 else -1)
    for _q, _t in enumerate((0, 60, 120)):
        _MD[f'n{3 * _b + _q}'] = ((_cu - math.cos(math.radians(_t)), _sg * math.sin(math.radians(_t))), 'small')
    _ml += [(f'n{3 * _b + _q}', f'n{3 * _b + _q + 1}', (_cu, 0.0)) for _q in range(3)]
_MD['n9'] = ((3.0, 0.0), 'notable')
for _k in ('n2', 'n5'):
    _MD[_k] = (_MD[_k][0], 'notable')
c17['meander'] = uv_fig(L(70.5, 3.8, LAND), 0, _MD, _ml)
# Review pass 2026-11-18 (w3): the gourd (two plain rings stacked, beside 69's pearl and 54's meeting ripples, a triangle
# of ring figures round the 1892 corner) gives way to a TURNING WAVE: an outer arc of 7 (radius 2.5) from 1893 sweeping
# round the spoke side and the foot of the cell, stepping in at its end to an inner arc of 5 (radius 1.35) running back
# round the same centre: two ripples joined at one end, open on the koi side (12 nodes, +1).
O17g = L(68.1, 13.9, LAND)
_tw = {f'o{a}': (2.5, a, 'notable' if a in (72, 216) else 'small') for a in (0, 36, 72, 108, 144, 180, 216)}
_tw.update({f'i{a}': (1.35, a, 'notable' if a == 72 else 'small') for a in (216, 180, 144, 108, 72)})
c17['turning_wave'] = fig(O17g, _tw, [(1893, 'o0', None)] + [(f'o{a}', f'o{a + 36}', 'o') for a in (0, 36, 72, 108, 144, 180)] +
                   [('o216', 'i216', None)] + [(f'i{a}', f'i{a - 36}', 'o') for a in (216, 180, 144, 108)])

CELLS[17] = c17

# ================================================================================================================
# Cell 59 (outer band, th -28..-17). Centre figure: a RIPPLE, two concentric arches rising from the bottom ring node
# 1799 - the inner one hung from 1799 itself, the outer from its neighbour 1800 - with a notable at the top of the
# outer arch and at each end. Fill: a Hairpin off the left spoke node 1991 (a Tadpole until w2), the endless current below.
# ================================================================================================================
O59 = road(1799)
# Consolidated 2026-11-18: the outer arch grows to 7 (ends lower, notables at the top and the left end); a starfish
# (five arms at even 72-degree steps round a hub off 1880, four ending in notables) replaces the Hook off 1880, the
# Crook off 1881 and the Crescent off 1879.
c59 = {
    'ripple_inner': curve(O59, [(1.8, -62), (1.8, -21), (1.8, 21), (1.8, 62)], ['small', 'small', 'small', 'notable'], 1799),
    'ripple_outer': curve(O59, [(3.4, 76), (3.4, 51), (3.4, 25), (3.4, 0), (3.4, -25), (3.4, -51), (3.4, -76)],
                          ['small', 'small', 'small', 'notable', 'small', 'small', 'notable'], 1800),
}
fill_rows(c59, [
    ('T crescent', 1991, 'Hairpin', 'bow in', 1.1, 95, 0, True),    # (w2) was a Tadpole (third loop in a row); a Hairpin, not a Crescent: 103's C_crescent
])
# Review pass 2026-11-18 (w1): the starfish (a creature, a hub of five arms) gives way to an ENDLESS CURRENT, a figure
# eight of two loops touching at one notable node: a loop of 5 (radius 1.0) entered from 1880 and a loop of 6
# (radius 1.2), lying slantwise down the cell; notables at the crossing and on the big loop's far side.
_A = L(67.0, -22.8, LAND); _B = orbit(_A, 2.2, 140)
_e8 = {f'a{a}': (orbit(_A, 1.0, a), 'small') for a in (212, 284, 356, 68)}
_e8.update({f'b{a}': (orbit(_B, 1.2, a), 'notable' if a in (80, 200) else 'small') for a in (20, 80, 140, 200, 260)})
_e8['X'] = (orbit(_A, 1.0, 140), 'notable')
c59['endless'] = (_e8, [(1880, 'a356', None), ('a356', 'a68', _A), ('a68', 'X', _A), ('X', 'a212', _A),
                         ('a212', 'a284', _A), ('a284', 'a356', _A), ('X', 'b20', _B), ('b20', 'b80', _B),
                         ('b80', 'b140', _B), ('b140', 'b200', _B), ('b200', 'b260', _B), ('b260', 'X', _B)])
CELLS[59] = c59

# Cell 54 = cell 59's ripple and Hairpin mirrored (ripple from 1809/1810), with its own big figure.
# Review pass 2026-11-18 (w1): its big figure was the Black Tortoise (a creature, four flipper spikes and a head on a
# neck); now MEETING RIPPLES, the varied echo of 59's figure eight across the axis: two equal circles (radius 1.35,
# centres 1.6 apart, stacked down the cell) that overlap, sharing their two crossing points (notables); each circle
# one node inside the lens and four outside; entered from 1891 on the upper circle, notables also at the lower
# circle's foot.
c54 = mirror_pieces({k: v for k, v in c59.items() if k in ('ripple_inner', 'ripple_outer', 'T_crescent')}, LAND)
_RR, _DD = 1.35, 1.6
_PH = math.degrees(math.acos(_DD / 2 / _RR))
_CA = L(66.4, 20.5, LAND); _CB = orbit(_CA, _DD, 180)
_mr = {'P': (orbit(_CA, _RR, 180 + _PH), 'notable'), 'Q': (orbit(_CA, _RR, 180 - _PH), 'notable'),
       'ai': (orbit(_CA, _RR, 180), 'small'), 'bi': (orbit(_CB, _RR, 0), 'small')}
_st = (360 - 2 * _PH) / 5
for k in range(1, 5):
    _mr[f'a{k}'] = (orbit(_CA, _RR, 180 + _PH + _st * k), 'small')
    _mr[f'b{k}'] = (orbit(_CB, _RR, _PH + _st * k), 'notable' if k in (2, 3) else 'small')
for _k, _c in (('P', _CB), ('Q', _CB)):
    assert abs(math.dist(_mr[_k][0], _c) - _RR) < 1e-6
_ml = [(1891, 'a2', None), ('P', 'a1', _CA), ('a1', 'a2', _CA), ('a2', 'a3', _CA), ('a3', 'a4', _CA), ('a4', 'Q', _CA),
       ('Q', 'ai', _CA), ('ai', 'P', _CA), ('Q', 'b1', _CB), ('b1', 'b2', _CB), ('b2', 'b3', _CB), ('b3', 'b4', _CB),
       ('b4', 'P', _CB), ('P', 'bi', _CB), ('bi', 'Q', _CB)]
c54['meeting_ripples'] = (_mr, _ml)
CELLS[54] = c54


def ang_to(O, rid):                 # the orbit angle at O pointing at road node rid
    from celllib import frame
    i, t = frame(O); R = road(rid); v = (R[0] - O[0], R[1] - O[1])
    return math.degrees(math.atan2(v[0] * t[0] + v[1] * t[1], v[0] * i[0] + v[1] * i[1]))


def bubble(O, rho, n, entry, notables, turn=0.0):
    """A closed ring of n nodes round O, its first node facing road node `entry`, nodes `notables` notable."""
    a0 = ang_to(O, entry) + turn
    nodes = {f'b{k}': (orbit(O, rho, a0 + 360.0 * k / n), 'notable' if k in notables else 'small') for k in range(n)}
    links = [(entry, 'b0', None)] + [(f'b{k}', f'b{(k + 1) % n}', O) for k in range(n)]
    return nodes, links


# ================================================================================================================
# Cell 103 (outer band, th -36..-28). Centre figure: a TEARDROP, a small loop round its centre with a pointed notable
# tip towards the tree centre, entered from the bottom road. Fill: a Crescent off the border road, the moon below.
# ================================================================================================================
O103 = L(69.9, -32.1, LAND)
TD = [(1.05, 180), (1.05, 240), (1.05, 295), (1.85, 0), (1.05, 65), (1.05, 120)]
td_nodes = {f't{k}': (orbit(O103, r, a), 'notable' if k == 3 else 'small') for k, (r, a) in enumerate(TD)}
td_links = [(1797, 't0', None), ('t0', 't1', O103), ('t1', 't2', O103), ('t2', 't3', None), ('t3', 't4', None),
            ('t4', 't5', O103), ('t5', 't0', O103)]
c103 = {'teardrop': (td_nodes, td_links)}
fill_rows(c103, [
    ('C crescent', 511, 'Crescent', 'bow out', 1.1, 60, 0, False),
])
# Consolidated 2026-11-18: a CRESCENT MOON (a closed crescent: an outer arc of 5 round its centre with notable horns and
# an inner arc of 3 on a second circle through the horns, its back hung from 1991) replaces the Tadpole off 1798 and
# the Ring off 1991.
_CI = (0.0, -1.266)                  # the inner arc's circle: through the horns (+-1.39, -0.8) and (0, 0.2)
c103['crescent_moon'] = uv_fig(L(71.0, -29.9, LAND), 0,
                               {**{f'o{f}': ((1.6 * math.cos(math.radians(f)), 1.6 * math.sin(math.radians(f))),
                                             'notable' if f in (-30, 210) else 'small') for f in (-30, 30, 90, 150, 210)},
                                'i0': ((0.75, -0.006), 'small'), 'i1': ((0.0, 0.2), 'small'), 'i2': ((-0.75, -0.006), 'small')},
                               [(1991, 'o90', None), ('o90', 'o30', (0.0, 0.0)), ('o30', 'o-30', (0.0, 0.0)),
                                ('o90', 'o150', (0.0, 0.0)), ('o150', 'o210', (0.0, 0.0)), ('o-30', 'i0', _CI),
                                ('i0', 'i1', _CI), ('i1', 'i2', _CI), ('i2', 'o210', _CI)])
CELLS[103] = c103

# Cell 108 (outer band, th 28..36, by the Wind start's road). Centre figure: KELP, two wavy chains rising side by side
# from the bottom road, ending in notables at different heights. Fill: the vortex and drip hook below.
c108 = {}
fill_rows(c108, [
    ('K kelp1',    1808, 'Zigzag', 'wave', 1.4, 35, 0, False),
    ('K kelp2',    1807, 'Zigzag', 'wave', 1.0, 16, 0, True),
])
# Consolidated 2026-11-18: a TAIJI VORTEX (an S of two spiral arms through a notable eye, entered at the top arm's end
# from 1888) replaces the Ring off 1888, the Crook off 1889 and the Crescent off 1992; a DRIP HOOK (an arc of 6 hung
# from 1887 down the cell's open right side, curling in to a notable) fills the empty side.
VS = 1.1
c108['vortex'] = fig(L(66.6, 30.4, LAND),
                     {'a2': (1.5 * VS, 0, 'small'), 'a1': (1.1 * VS, -50, 'small'), 'a0': (0.7 * VS, -100, 'small'),
                      'eye': (0.0, 0, 'notable'), 'b0': (0.7 * VS, 80, 'small'), 'b1': (1.1 * VS, 130, 'small'),
                      'b2': (1.5 * VS, 180, 'notable')},
                     [(1888, 'a2', None), ('a2', 'a1', ('R', 0.12)), ('a1', 'a0', ('R', 0.12)), ('a0', 'eye', None),
                      ('eye', 'b0', None), ('b0', 'b1', ('R', 0.12)), ('b1', 'b2', ('R', 0.12))])
c108['drip_hook'] = curve(L(67.4, 33.0, LAND), [(2.0, -25), (2.0, 15), (2.0, 55), (2.0, 95), (2.0, 135), (1.25, 200)],
                          ['small', 'small', 'small', 'notable', 'small', 'notable'], 1887, bow=0.15)
CELLS[108] = c108

# ================================================================================================================
# Cell 42 (middle band, th -36..-23, the border hex on its left wall). Centre figure: BUBBLES, three rings of growing
# size rising on a slant, from the bottom road to the top. Fill: the seaweed below.
# ================================================================================================================
c42 = {
    'bubble_s': bubble(L(62.3, -30.6, LAND), 0.75, 4, 1878, (2,)),
    'bubble_m': bubble(L(60.0, -28.6, LAND), 1.15, 6, 1879, (2, 4)),
    'bubble_l': bubble(L(56.6, -31.0, LAND), 1.35, 6, 1864, (3,)),
}
# Consolidated 2026-11-18: the middle bubble grows to 6; a SEAWEED strand (a wavy chain of 6 rising from 1880 along the
# right spoke to a notable tip, one two-node side frond) replaces the Crook off 1865 and the Tadpole off 1880.
SW = [(63.0, -24.6), (61.8, -25.6), (60.6, -24.6), (59.4, -25.6), (58.2, -24.7), (57.0, -25.5)]
_sw = {f'w{k}': (L(r, t, LAND), 'notable' if k == 5 else 'small') for k, (r, t) in enumerate(SW)}
_sw['l1'] = (L(58.6, -26.6, LAND), 'small')       # (w1) the frond curls up into the open patch on one circle, +1
_sw['l2'] = (L(57.4, -27.5, LAND), 'small')
_sw['l3'] = (L(56.1, -27.4, LAND), 'notable')
_fa = circumcentre(_sw['w3'][0], _sw['l1'][0], _sw['l2'][0])
_fb = circumcentre(_sw['l1'][0], _sw['l2'][0], _sw['l3'][0])
_swc = L(60.6, -25.1, LAND)
c42['seaweed'] = (_sw, [(1880, 'w0', None)] +
                  [(f'w{k}', f'w{k + 1}', bow_centre(_sw[f'w{k}'][0], _sw[f'w{k + 1}'][0], 0.18 * (1 if k % 2 else -1), _swc))
                   for k in range(5)] + [('w3', 'l1', _fa), ('l1', 'l2', _fa), ('l2', 'l3', _fb)])
CELLS[42] = c42

# ================================================================================================================
# Cell 38 (41.7-53.9, th -18..0, the axis hex and the Ice start on its right). Centre figure: a LILY PAD, an open ring
# of 9 with its notch towards the tree centre, the notch ends notables, a bud notable inside. Fill: a Tadpole + below.
# ================================================================================================================
O38 = L(48.2, -10.2, LAND)
PAD = [30 + 37.5 * k for k in range(9)]
pad_nodes = {f'p{k}': (orbit(O38, 2.3, a), 'notable' if k in (0, 8) else 'small') for k, a in enumerate(PAD)}
# (w1) the bud no longer sits on a straight stick from p2: it is the middle of an inner swag from p1 to p3 (one circle
# through the three), a leaf vein inside the pad.
pad_nodes['bud'] = (orbit(O38, 1.25, PAD[2]), 'notable')
_bc = circumcentre(pad_nodes['p1'][0], pad_nodes['bud'][0], pad_nodes['p3'][0])
pad_links = [(1868, 'p4', None)] + [(f'p{k}', f'p{k + 1}', O38) for k in range(8)] + [('p1', 'bud', _bc), ('bud', 'p3', _bc)]
c38 = {'lily_pad': (pad_nodes, pad_links)}
fill_rows(c38, [
    ('T tadpole',  1869, 'Tadpole', 'round', 1.1, -10, 0, False),    # (w1) was ang 5: 0.95 from the axis hex's notable
])
# Consolidated 2026-11-18: a DEWDROP LENS (two arcs meeting at a notable end, a notable pearl inside, on a short stem
# from 1788) floats above the pad's notch, replacing the Crook off 1787 and the Ring off 1788; a FALLING DROP (a ring
# of 6 on a curved tail of two from 1866) replaces the Hook off 1866 and the Ring off 1867.
_LC = 1.3117                          # the lens arcs: circles through (0, +-1.7) and (+-0.75, +-0.6), centres (-+_LC, 0)
c38['dewdrop'] = uv_fig(L(44.3, -10.4, LAND), 0,
                        {'s': ((1.45, 0.75), 'small'), 'ua': ((0.75, -0.6), 'small'), 'ub': ((0.75, 0.6), 'small'),
                         'e0': ((0.0, -1.7), 'notable'), 'e1': ((0.0, 1.7), 'small'), 'da': ((-0.75, -0.6), 'small'),
                         'db': ((-0.75, 0.6), 'small'), 'pearl': ((0.0, 0.0), 'notable')},
                        [(1788, 's', None), ('s', 'ub', None), ('ub', 'ua', (-_LC, 0.0)), ('ua', 'e0', (-_LC, 0.0)),
                         ('ub', 'e1', (-_LC, 0.0)), ('e0', 'da', (_LC, 0.0)), ('da', 'db', (_LC, 0.0)),
                         ('db', 'e1', (_LC, 0.0)), ('da', 'pearl', None)])
O38d = L(49.6, -15.3, LAND)
# Review pass 2026-11-19 (w4): the drop is opened (its node r240 removed): the tail rises and curls back over itself
# (r180 -> r120 -> r60 -> r0 -> r300, notables r60 and the end), a breaking crest instead of a fifth closed loop in 38.
_DS = (180, 120, 60, 0, 300)
c38['falling_drop'] = fig(O38d, {**{f'r{a}': (1.0, a, 'notable' if a in (60, 300) else 'small') for a in _DS},
                                 't1': (2.1, 195, 'small'), 't2': (3.2, 208, 'small')},
                          [(1866, 't2', None), ('t2', 't1', ('L', 0.12)), ('t1', 'r180', ('L', 0.12))] +
                          [(f'r{a}', f'r{b}', 'o') for a, b in zip(_DS, _DS[1:])])
CELLS[38] = c38

# ================================================================================================================
# Cell 22 (41.7-53.9, th 0..18). Centre figure: a FOUNTAIN, a jet rising from the bottom road (1875) to a notable, two
# side jets falling away left and right to notables. Fill: a Crescent and the figures below.
# ================================================================================================================
R1875 = road(1875)
from celllib import direction as _dir  # noqa: E402
up = _dir(R1875, 0); side = _dir(R1875, 90)
def _p(a, b): return (R1875[0] + a * up[0] + b * side[0], R1875[1] + a * up[1] + b * side[1])
fountain_nodes = {'j1': (_p(1.2, 0), 'small'), 'j2': (_p(2.4, 0), 'small'), 'j3': (_p(2.4 + math.hypot(0.5, 1.1), 0), 'notable'),
                  'l1': (_p(2.9, -1.1), 'small'), 'l2': (_p(2.2, -2.2), 'notable'),
                  'r1': (_p(2.9, 1.1), 'small'), 'r2': (_p(2.2, 2.2), 'notable')}
cf = ((_p(2.4, 0)[0]), _p(2.4, 0)[1])
# Review pass 2026-11-18 (w1): the top jet no longer stands on a straight stick from j2: j3 sits on the circle round
# j2 through the two side jets, joined to them by arcs, so the jet opens into a dome before falling to the side drops.
fountain_links = [(1875, 'j1', None), ('j1', 'j2', None), ('l1', 'j3', _p(2.4, 0)), ('j3', 'r1', _p(2.4, 0)),
                  ('j2', 'l1', bow_centre(_p(2.4, 0), _p(2.9, -1.1), 0.2, _p(1.0, 0))), ('l1', 'l2', bow_centre(_p(2.9, -1.1), _p(2.2, -2.2), 0.2, _p(1.0, 0))),
                  ('j2', 'r1', bow_centre(_p(2.4, 0), _p(2.9, 1.1), 0.2, _p(1.0, 0))), ('r1', 'r2', bow_centre(_p(2.9, 1.1), _p(2.2, 2.2), 0.2, _p(1.0, 0)))]
c22 = {'fountain': (fountain_nodes, fountain_links)}
fill_rows(c22, [
    ('C crescent', 1793, 'Crescent', 'bow in', 1.1, 215, 0, True),
])
# Consolidated 2026-11-18. A WAVE TRAIN across the empty middle: four humps (arcs round their own centres on the ring
# r 46.3, alternately up and down), hung from 1794 by a stem into the third hump's crest, the two ends notables; it
# replaces the Hairpin off 1794 and the Crescent off 1796. A LOTUS BUD hangs from 1795 into the pocket above the second
# hump (a lens bud with a notable tip and a leaf), replacing the Ring off 1795. A shrimp (now the curl below; a C of 5 round its centre,
# entered at the back from 1874, a tail fan of two and one feeler) replaces the Hook off 1874 and the Hairpin off 1873.
WR, WH, WT0 = 46.3, 1.05, 5.4
_dw = math.degrees(WH / WR)
_wn = {f'x{k}': (L(WR, WT0 + 2 * k * _dw, LAND), 'notable' if k in (0, 4) else 'small') for k in range(5)}
_wl = []
for k in range(4):
    Hk = L(WR, WT0 + (2 * k + 1) * _dw, LAND)
    _wn[f'a{k}'] = (orbit(Hk, WH, 0 if k % 2 == 0 else 180), 'small')
    _wl += [(f'x{k}', f'a{k}', Hk), (f'a{k}', f'x{k + 1}', Hk)]
_wn['st'] = (L(43.6, 11.9, LAND), 'small')
c22['wave_train'] = (_wn, [(1794, 'st', None), ('st', 'a2', None)] + _wl)
bud = petal(1795, 180, 1.0, 2.4, 0.75, kinds=('small', 'small', 'small', 'notable'))
bud[0]['leaf'] = (orbit(bud[0]['s1'][0], 1.0, -100), 'notable')
bud[1].append(('s1', 'leaf', None))
c22['lotus_bud'] = bud
O22s = L(51.4, 13.6, LAND)
# Review pass 2026-11-18 (w1): the shrimp (a creature: tail fan and feeler, three straight spikes) gives way to a WAVE
# CURL: the C round its centre grown to 6, entered at the back from 1874, its end winding in on two arcs to a notable
# eye (radii 0.95, 0.45); notables at the open end, at the C's top and the eye.
c22['curl'] = fig(O22s, {**{f'b{a}': (1.5, a, 'notable' if a in (135, 315) else 'small') for a in (90, 135, 180, 225, 270, 315)},
                         'i0': (0.95, 35, 'small'), 'i1': (0.45, -45, 'notable')},
                  [(1874, 'b225', None)] + [(f'b{a}', f'b{a + 45}', 'o') for a in (90, 135, 180, 225, 270)] +
                  [('b90', 'i0', -0.12), ('i0', 'i1', -0.12)])
CELLS[22] = c22

# ================================================================================================================
# Cell 26 (41.7-53.9, th -36..-18). Centre figure: a CLAM with a PEARL, a half-ring shell opening towards the tree
# centre, its rims notables (the pearl went in the w1 pass). Fill: the Hook off 1866 (w2), waterwheel and below.
# ================================================================================================================
O26 = L(48.4, -27.2, LAND)
SHELL = [90, 120, 150, 180, 210, 240, 270]
shell_nodes = {f's{k}': (orbit(O26, 2.4, a), 'notable' if k in (0, 6) else 'small') for k, a in enumerate(SHELL)}
shell_nodes['pearl'] = (O26, 'notable')
# Review pass 2026-11-18 (w1): the pearl (a notable on a straight stick from s2) is gone; closing the shell over it
# made one more ring in a cell full of rings, so the clam stays an open shell, its rims the notables (-1 node).
del shell_nodes['pearl']
shell_links = [(1864, 's3', None)] + [(f's{k}', f's{k + 1}', O26) for k in range(6)]
c26 = {'clam': (shell_nodes, shell_links)}
fill_rows(c26, [
    ('T tadpole',  272, 'Tadpole', 'round', 1.1, 90, 0, False),
    ('D hook',     1866, 'Hook', 'bow in', 1.1, -40, 0, False),     # (w2) was a round Diamond beside 38's falling drop
])
# Consolidated 2026-11-18: a WATERWHEEL (a ring of 8 hung from 1785, two spokes to a notable hub, two paddles hanging
# from its lower rim) replaces the Crook off 1784, the Tadpole off 1785 and the Hairpin off 1786.
O26w = L(45.4, -23.0, LAND)
c26['waterwheel'] = fig(O26w, {**{f'r{a}': (2.0, a, 'small') for a in range(0, 360, 45)}, 'hub': (0.0, 0, 'notable'),
                               'p0': (2.8, 117, 'notable'), 'p1': (2.8, 63, 'notable')},
                        [(1785, 'r0', None)] + [(f'r{a}', f'r{(a + 45) % 360}', 'o') for a in range(0, 360, 45)] +
                        [('r90', 'hub', None), ('r270', 'hub', None), ('r45', 'p1', None), ('p1', 'p0', 'o'),
                         ('p0', 'r135', None)])
# Review pass 2026-11-18 (w1): the two paddles no longer hang as straight spikes off the rim: they are a FLUME, an arc
# of two on an outer orbit round the wheel's centre bridging rim nodes r45 and r135 on the open +theta side.
CELLS[26] = c26

# ================================================================================================================
# Cell 32 (41.7-53.9, th 18..36). Centre figure: the MOON and its REFLECTION, facing each other: a ring of 6 (two
# notables) hung from the top road, and below it a broken arc hung from the bottom road. Fill: Crook, Tadpole, lotus.
# ================================================================================================================
O32 = L(52.1, 27.0, LAND)
# Consolidated 2026-11-18: the reflection widens to 7 (radius 2.5); a LOTUS in side view (a stem from 1870, a lens
# centre petal and two outward petals, three notable tips) replaces the Hook off 291, the Crescent off 292 (both seam
# nodes) and the Ring off 1870.
REFL = (-72, -48, -24, 0, 24, 48, 72)
# Review pass 2026-11-18 (w1): the reflection hung from 1871 on a straight stem of 4.3 across the cell; it turns over
# into a bowl (round a centre 2.5 nearer the moon), its lowest node 1.8 from 1871, cupping up towards the moon.
O32r = L(49.6, 26.8, LAND)
refl_nodes = {f'w{k}': (orbit(O32r, 2.5, 180 + a), 'notable' if k in (0, 6) else 'small') for k, a in enumerate(REFL)}
refl_links = [(1871, 'w3', None)] + [(f'w{k}', f'w{k + 1}', O32r) for k in range(6)]
c32 = {'moon': bubble(L(45.9, 27.0, LAND), 1.3, 6, 1791, (2, 4)), 'reflection': (refl_nodes, refl_links)}
fill_rows(c32, [
    ('C crook',    1793, 'Crook', 'swept', 1.1, 128, 0, False),
    ('T tadpole',  1873, 'Tadpole', 'cusped', 1.1, 45, 0, False),
])
_LP = {'s1': ((-1.8, 0.25), 'small'), 'base': ((0.0, 0.0), 'small'), 'cs1': ((1.4, -0.8), 'small'),
       'cs2': ((1.4, 0.8), 'small'), 'ctip': ((3.0, 0.0), 'notable'), 'lm': ((0.7, -1.5), 'small'),
       'ltip': ((1.9, -2.5), 'notable'), 'rm': ((0.7, 1.5), 'small'), 'rtip': ((1.9, 2.5), 'notable')}
_PC = (1.5, 0.0)
def _bw(a, b, bow=0.15): return bow_centre(_LP[a][0], _LP[b][0], bow, _PC)
c32['lotus'] = uv_fig(L(50.3, 31.8, LAND), 0, _LP,
                      [(1870, 's1', None), ('s1', 'base', None)] +
                      [(a, b, _bw(a, b)) for a, b in (('base', 'cs1'), ('cs1', 'ctip'), ('base', 'cs2'), ('cs2', 'ctip'),
                                                      ('base', 'lm'), ('lm', 'ltip'), ('base', 'rm'), ('rm', 'rtip'))])
CELLS[32] = c32

# ================================================================================================================
# Cell 46 (inner band, th -23..0, beside the Ice start). Centre figure: a FROST STAR, a hub with three arms ending in
# notables, hung from the top road. Sparse: plus the ice crystal below.
# ================================================================================================================
R1775 = road(1775)
hub = orbit(R1775, 1.5, 180)
star_nodes = {'h': (hub, 'small')}
star_links = [(1775, 'h', None)]
for k, a in enumerate((120, 180, 240)):
    # review pass 2026-11-18 (w1): each arm bends on one circle through the hub, its middle node turned 22 degrees
    # ahead, so the three straight spikes become a turning frost whirl.
    star_nodes[f'a{k}'] = (orbit(hub, 1.05, a + (17 if k == 0 else 12 if k == 2 else 0) + (22)), 'small')
    star_nodes[f'n{k}'] = (orbit(hub, 2.1, a + (17 if k == 0 else 12 if k == 2 else 0)), 'notable')
    _c = circumcentre(hub, star_nodes[f'a{k}'][0], star_nodes[f'n{k}'][0])
    star_links += [('h', f'a{k}', _c), (f'a{k}', f'n{k}', _c)]
c46 = {'frost_star': (star_nodes, star_links)}
# Consolidated 2026-11-18 (beside the Ice start, light touch; the start figure itself is not touched): an ICE CRYSTAL (a
# hexagonal ring of 6 hung from 1776, an icicle of two hanging from its far side) replaces the Tadpole off 1776 and the
# Crook off 1788.
# Review pass 2026-11-19 (w4): the icicle (r3 - d1 - d2) dropped and the ring moved up beside 1776 (was L(35.75, -7.8),
# notables r2, r4), answering 45's ring off 1782; the icicle's slot takes the mirrored frost ripple (after cell 45).
O46c = L(35.0, -9.2, LAND)
c46['ice_crystal'] = fig(O46c, {f'r{k}': (1.0, 60 * k, 'notable' if k in (2, 3) else 'small') for k in range(6)},
                         [(1776, 'r0', None)] + [(f'r{k}', f'r{(k + 1) % 6}', 'o') for k in range(6)])
CELLS[46] = c46

# Cell 45 (inner band, th 0..23, beside the Ice start), its own composition: ICICLES, two Hairpins hanging from the top
# road at different lengths, and the winged crystal rising from the bottom road between them.
c45 = {}
fill_rows(c45, [
    ('I icicle1',  1781, 'Hairpin', 'tight turn', 1.0, 180, 0, False),
    ('I icicle2',  1780, 'Hairpin', 'bow in', 1.3, 180, 0, True),
])
# Consolidated 2026-11-18 (beside the Ice start, light touch): a WINGED CRYSTAL (a hexagonal ring of 6 rising from 1793,
# a notable spike off each side; cell 46's crystal varied) replaces the closed Fork off 1793 and the Diamond off 1792.
O45c = L(39.0, 18.5, LAND)
c45['winged_crystal'] = fig(O45c, {**{f'r{k}': (1.0, 180 + 60 * k, 'small') for k in range(6)},
                                   'w0': (1.75, 90, 'notable'), 'w1': (1.75, 270, 'notable')},
                            [(1793, 'r0', None)] + [(f'r{k}', f'r{(k + 1) % 6}', 'o') for k in range(6)] +
                            [('r4', 'w0', None), ('w0', 'r5', None), ('r1', 'w1', None), ('w1', 'r2', None)])
# Review pass 2026-11-18 (w1): the two wing spikes are now pointed caps, each bridging two rim nodes (r4 - w0 - r5,
# r1 - w1 - r2), so the ring reads as one long crystal with no loose spikes.
# Review pass 2026-11-18 (w2): the empty patch between the Ice start and the crescent off 1794 takes a FROST RIPPLE, an
# arc of 5 round the Ice start's own centre (radius 5.0, angles 100 to 48), rising from 1795; with the crescent beside
# it, two ripples spreading from the start (the start figure itself untouched). Notables at its middle and top end.
c45['frost_ripple'] = fig(L(39.6, 0.0, LAND), {f'f{k}': (5.0, a, 'notable' if k in (2, 4) else 'small')
                                               for k, a in enumerate((100, 87, 74, 61, 48))},
                          [(1795, 'f0', None)] + [(f'f{k}', f'f{k + 1}', 'o') for k in range(4)])
CELLS[45] = c45
# Review pass 2026-11-19 (w4): 45's ripple alone read as a one-sided halo of the Ice start; mirrored across the axis
# into 46 (rising from 1788), the start sits between two arcs on its own circle (cell 14's grammar), the crystal and
# 45's ring off 1782 answering each other above.
CELLS[46]['frost_ripple_m'] = mirror_pieces({'p': c45['frost_ripple']}, LAND)['p']

# Cell 115 (inner band, th -36..-23).
# Consolidated 2026-11-18 (light touch): a WATER CHANNEL (an S of two half-circles bridging the cell from 1771 at the top
# to 1784 at the bottom, a notable in each bend) replaces the Ring off 1784 and the Crook off 1771.
_cA = fig(L(35.85, -29.5, LAND), {'a0': (1.65, 0, 'small'), 'a1': (1.65, -60, 'small'), 'a2': (1.65, -120, 'notable'),
                                 'J': (1.65, 180, 'small')},
          [(1771, 'a0', None), ('a0', 'a1', 'o'), ('a1', 'a2', 'o'), ('a2', 'J', 'o')])
_cBc = L(39.15, -29.5, LAND)
_cB = fig(_cBc, {'b1': (1.65, 45, 'small'), 'b2': (1.65, 90, 'notable'), 'b3': (1.65, 135, 'small'),
                 'b4': (1.65, 180, 'small')},
          [('J', 'b1', _cBc), ('b1', 'b2', 'o'), ('b2', 'b3', 'o'), ('b3', 'b4', 'o'), ('b4', 1784, None)])
c115 = {'channel': ({**_cA[0], **_cB[0]}, _cA[1] + _cB[1])}
CELLS[115] = c115
# Cell 118 = cell 115 mirrored (the channel from 1777 to 1791); the Crescent off 1777 went with the consolidation.
c118 = mirror_pieces(c115, LAND)
CELLS[118] = c118

# ================================================================================================================
# Cell 5 (the Water start cell, 558 units², the start figure on the axis). Big and sparse: two Crescents curling out
# from the hub ring either side, two ripple hooks rising from the start ring.
# ================================================================================================================
c5 = {}
fill_rows(c5, [
    ('C crescent1', 20, 'Crescent', 'bow out', 1.3, 175, 0, False),
    ('C crescent2', 22, 'Crescent', 'bow out', 1.3, 185, 0, True),
])
# Consolidated 2026-11-18 (start cell, light touch): a DOUBLE RIPPLE HOOK (an outer arc of 4 from 1774 stepping in to an
# inner arc of 4 going back, two radii round one centre) replaces the Ring off 1772 and the Hook off 1775; its mirror
# twin from 1780 replaces the Tadpole off 1778 and the Hook off 1781.
c5['ripple_hook'] = curve(L(29.5, -18.0, LAND), [(2.0, -160), (2.0, -115), (2.0, -70), (2.0, -25), (1.1, -25),
                                                  (1.1, -75), (1.1, -125), (1.1, -175)],
                          ['small', 'small', 'notable', 'small', 'small', 'small', 'small', 'notable'], 1774)
c5.update({'ripple_hook_m': mirror_pieces({'p': c5['ripple_hook']}, LAND)['p']})
CELLS[5] = c5

# Cell 82 (the hub cell facing Water, inside the Taiji ring): two Crooks and the seed drop on the axis.
c82 = {}
fill_rows(c82, [
    ('K crook1',   20, 'Crook', 'bow in', 1.1, 0, 0, False),
    ('K crook2',   22, 'Crook', 'bow in', 1.1, 0, 0, True),
])
# Consolidated 2026-11-18 (hub cell, light touch): a SEED DROP (a lens on the axis bridging 7 and 21, three nodes a
# side, notables at its widest) replaces the Diamond off 7 and the Crescent off 21.
_SC = 3.731                          # the lens arcs: circles through the tips (+-3.3, 0) and (0, +-1.25)
_sd = {'top': ((3.3, 0.0), 'small'), 'bot': ((-3.3, 0.0), 'small')}
for _sg, _nm in ((1, 'r'), (-1, 'l')):
    for _k, _u in enumerate((1.65, 0.0, -1.65)):
        _sd[f'{_nm}{_k}'] = ((_u, _sg * (-_SC + math.sqrt(3.3 ** 2 + _SC ** 2 - _u ** 2))), 'notable' if _k == 1 else 'small')
c82['seed_drop'] = uv_fig(L(9.3, 0.0, LAND), 0, _sd,
                          [(7, 'top', None), ('bot', 21, None)] +
                          [(a, b, (0.0, -_SC) if a[0] == 'r' or b[0] == 'r' else (0.0, _SC))
                           for a, b in (('top', 'r0'), ('r0', 'r1'), ('r1', 'r2'), ('r2', 'bot'),
                                        ('top', 'l0'), ('l0', 'l1'), ('l1', 'l2'), ('l2', 'bot'))])
CELLS[82] = c82

# ================================================================================================================
# Rim slice (cell id 904): beyond the outer ring, land-local th -33..33. The Darkness connector leaves the -12 hook
# (1993 -> 448 -> 674, open end 449 at th -9) and its road runs out at th -10; Thunder's road sits near +36.
# Keystones: one past the +12 hook end (1994), one past the connector's open end (449). Each keystone alone on one link.
# Rim rework 2026-11-18 (rim-brief.md): the jellyfish, the great wave and the dragon are gone (two creatures and a
# picture); the rim now carries the land's largest figures, drawn as graphs in orbit grammar: the LOTUS on the axis,
# the ARMILLARY pair either side and the BAGUA in the connector's box. The three small catalogue pieces that hung outward
# from the ring (a Crook off 1806, a Ring off 1804, a Diamond off 1814) went with them.
# ================================================================================================================
c904 = {
    'keystone_hook': ({'k': ((-58.8571, -52.9951), 'keystone')}, [(1813, 'k', None)]),
    'keystone_dark': ({'k': ((-38.135, -74.845), 'keystone')}, [(674, 'k', (0.0, 0.0))]),
}

# LOTUS (lien hoa) at the end of the axis road (1322, r 94), which reads as its stalk; the flower seen from above:
# a seed head (a ring of 6 round the centre), six inner petals (tips on an orbit, each petal outlined by two arcs back
# to the seed ring) and six outer petals turned 30 degrees against them (tips on a wider orbit, outlined back to the
# inner tips), so the two petal rings are nested star outlines, never self-crossing. Entered at the outer petal tip
# facing the tree; the other five outer tips are notables, and a centre notable on three spokes to the seed ring.
# Symmetric across the axis.
LO_S, LO_I, LO_O, LO_BI, LO_BO = 1.6, 3.7, 6.0, 0.12, 0.12
OLO = L(94.0 + 1.3 + LO_O, 0.0, LAND)
_lp = {'seed': (0.0, 0, 'notable')}
for _a in range(0, 360, 60):
    _lp[f's{_a}'] = (LO_S, _a, 'small')
    _lp[f'i{_a + 30}'] = (LO_I, _a + 30, 'small')
    _lp[f'o{_a}'] = (LO_O, _a, 'small' if _a == 0 else 'notable')
_ll = [(1322, 'o0', None), ('seed', 's60', None), ('seed', 's180', None), ('seed', 's300', None)]
for _a in range(0, 360, 60):
    _ll += [(f's{_a}', f's{(_a + 60) % 360}', 'o'),
            (f's{_a}', f'i{_a + 30}', LO_BI), (f'i{_a + 30}', f's{(_a + 60) % 360}', LO_BI),
            (f'i{(_a + 330) % 360}', f'o{_a}', LO_BO), (f'o{_a}', f'i{_a + 30}', LO_BO)]
c904['lotus'] = fig(OLO, _lp, _ll)

# ARMILLARY (abstract, after the hun tian yi rings), a mirrored pair off 1800 (th -20) and 1810 (th +20): three
# orbits round one centre, each open where the one inside it is closed. A core ring of 4 entered on a stem through the
# open side; two side arcs on the middle orbit hung radially from the ring's flanks; one half-circle on the outer orbit
# wrapping the far side, tied radially to the side arcs at +-120. Every arc end is a notable. Turned 20 degrees so
# the stem enters at a slant and the pair splays outward round the lotus.
AR_D, AR_TURN = 4.3, 20.0
_R = road(1800)
_D = direction(_R, 180 + AR_TURN)
OAR = (_R[0] + AR_D * _D[0], _R[1] + AR_D * _D[1])
_ap = {f'r{_a}': (1.5, _a + AR_TURN, 'small') for _a in (0, 90, 180, 270)}
_al = [(1800, 'r0', None)] + [(f'r{_a}', f'r{(_a + 90) % 360}', 'o') for _a in (0, 90, 180, 270)]
for _s in (1, -1):
    for _a in (30, 60, 90, 120, 150):
        _ap[f'm{_s * _a}'] = (3.2, _s * _a + AR_TURN, 'notable' if _a in (30, 150) else 'small')
    _al += [(f'r{_s * 90 % 360}', f'm{_s * 90}', None)]
    _al += [(f'm{_s * _a}', f'm{_s * (_a + 30)}', 'o') for _a in (30, 60, 90, 120)]
    _al += [(f'm{_s * 120}', f'o{_s * 120}', None)]
    for _a in (90, 120, 150):
        _ap[f'o{_s * _a}'] = (4.9, _s * _a + AR_TURN, 'notable' if _a == 90 else 'small')
    _al += [(f'o{_s * 90}', f'o{_s * 120}', 'o'), (f'o{_s * 120}', f'o{_s * 150}', 'o'), (f'o{_s * 150}', 'o180', 'o')]
_ap['o180'] = (4.9, 180 + AR_TURN, 'small')
c904['armillary_L'] = fig(OAR, _ap, _al)
c904['armillary_R'] = mirror_pieces({'p': c904['armillary_L']}, LAND)['p']

# BAGUA with a TAIJI inside, in the box the Darkness connector road closes (th -10 to the moon), hung sideways from 678
# (th -10, r 92.9): an octagon of 8 (the eight trigrams, straight sides) round a taiji circle of 4, tied to it by two
# spokes across the entry line; the taiji's S runs through the centre as two arcs (each a little under a half circle),
# a notable at the centre. Notables at the octagon's two S-side corners and its far corner.
BG_D, BG_O, BG_T = 6.0, 4.7, 2.5
_R = road(678)
_D = direction(_R, -90)
OBG = (_R[0] + BG_D * _D[0], _R[1] + BG_D * _D[1])
_bp = {f'g{_a}': (BG_O, _a, 'notable' if _a in (0, 180, 270) else 'small') for _a in range(0, 360, 45)}
_bp.update({f't{_a}': (BG_T, _a, 'small') for _a in (0, 90, 180, 270)})
_h, _y = BG_T / 2, 0.5                  # the S arcs' centres sit 0.5 off the diameter, so each half is under a
_rs = math.hypot(_h, _y)                # semicircle and meets the taiji circle at an angle, not tangent to it
_sv = _rs - _y
_bp.update({'s1': (math.hypot(_h, _sv), math.degrees(math.atan2(_sv, _h)), 'small'), 'c': (0.0, 0, 'notable'),
            's2': (math.hypot(_h, _sv), 180 + math.degrees(math.atan2(_sv, _h)), 'small'),
            'e1': (_rs, -math.degrees(math.atan2(_y, _h)), 'small'),
            'e2': (_rs, 180 - math.degrees(math.atan2(_y, _h)), 'small')})
_bl = [(678, 'g90', None), ('g90', 't90', None), ('g270', 't270', None)]
_bl += [(f'g{_a}', f'g{(_a + 45) % 360}', None) for _a in range(0, 360, 45)]
_bl += [(f't{_a}', f't{(_a + 90) % 360}', 'o') for _a in (0, 90, 180, 270)]
_bn = fig(OBG, _bp, [])[0]
_bl += [('t0', 's1', _bn['e1'][0]), ('s1', 'c', _bn['e1'][0]), ('c', 's2', _bn['e2'][0]), ('s2', 't180', _bn['e2'][0])]
for _k in ('e1', 'e2'):
    del _bp[_k]
c904['bagua'] = fig(OBG, _bp, _bl)
CELLS[904] = c904

# ================================================================================================================
# Density pass: for each free road node I listed families in my order of preference; a test (out/water_dense.py)
# kept the first of my options that passed, near the direction into the cell. Reviewed by eye after; edits below.
# ================================================================================================================
fill_rows(CELLS[76], [('Z76_1880', 1880, 'Crescent', 'bow out', 1.6, 35, 0, True)])   # (w2) was a Diamond: a ring at the ring-heavy 1880 joint
fill_rows(CELLS[76], [('Z76_1867', 1867, 'Crook', 'swept', 1.5, -120, 0, True)])   # (w2) was a round Diamond (rings in a row on r 53.9)
fill_rows(CELLS[69], [('Z69_1890', 1890, 'Crescent', 'bow out', 1.3, -30, 0, False)])   # (w2) as Z76_1880, shorter (the pearl)
fill_rows(CELLS[69], [('Z69_1874', 1874, 'Crook', 'swept', 1.5, 120, 0, False)])   # (w2) Z76_1867 mirrored
fill_rows(CELLS[91], [('Z91_1867', 1867, 'Crook', 'swept', 1.5, 135, 0, True)])    # (w2) with Z76_1867, a pair curling off spoke -11
fill_rows(CELLS[86], [('Z86_1874', 1874, 'Crook', 'swept', 1.5, -135, 0, False)])  # (w2) Z91_1867 mirrored
fill_rows(CELLS[86], [('Z86_1894', 1894, 'Crescent', 'bow in', 1.4, -62, 0, False)])
fill_rows(CELLS[11], [('Z11_1884', 1884, 'Crook', 'swept', 1.4, 118, 0, True)])
fill_rows(CELLS[11], [('Z11_1500', 1500, 'Crescent', 'bow in', 1.1, -85, 0, False)])
fill_rows(CELLS[11], [('Z11_1801', 1801, 'Diamond', 'round', 1.1, 45, 0, True)])
fill_rows(CELLS[17], [('Z17_1895', 1895, 'Crook', 'bow in', 1.4, 118, 0, True)])
fill_rows(CELLS[59], [('Z59_1801', 1801, 'Hook', 'bow in', 1.1, -51, 0, False)])
fill_rows(CELLS[54], [('Z54_1811', 1811, 'Crescent', 'bow in', 1.1, 38, 0, False)])
fill_rows(CELLS[103], [('Z103_512', 512, 'Hairpin', 'bow out', 1.2, 55, 0, True)])   # (w3) was a cusped Tadpole (a kite on a stick, one of the loops along Metal)
fill_rows(CELLS[108], [('Z108_515', 515, 'Hairpin', 'bow out', 1.2, -45, 0, False)])   # (w2) 108's empty border corner: a wave curling up
fill_rows(CELLS[42], [('Z42_1877', 1877, 'Crescent', 'bow out', 1.1, 21, 0, False)])   # (w1) was a Diamond: four rings in a row
fill_rows(CELLS[38], [('Z38_1789', 1789, 'Ring', 'horseshoe (open)', 1.4, -174, 0, False)])   # (w2) opened: dewdrop, ring, crystal in a row
fill_rows(CELLS[38], [('Z38_1786', 1786, 'Hook', 'bow out', 1.1, 144, 0, False)])
fill_rows(CELLS[22], [('Z22_1876', 1876, 'Hook', 'bow in', 1.1, 0, 0, False)])   # (w2) was a cusped Tadpole 1.40 from the axis hex's 1447
fill_rows(CELLS[26], [('Z26_1863', 1863, 'Hook', 'bow in', 1.1, 36, 0, True)])
fill_rows(CELLS[32], [('Z32_1790', 1790, 'Diamond', 'cusped', 1.1, -145, 0, False)])
fill_rows(CELLS[46], [('Z46_1786', 1786, 'Hook', 's-curve', 1.1, 30, 0, True)])   # (w2) was a Ring beside the bloom and crystal
fill_rows(CELLS[45], [('Z45_1794', 1794, 'Crescent', 'bow out', 1.1, -16, 0, False)])
fill_rows(CELLS[45], [('Z45_1782', 1782, 'Ring', 'round', 1.1, 154, 0, False)])
_n, _l = CELLS[45]['Z45_1782']             # (w1) its notable n2 sat 1.26 from icicle1's tip: made small
CELLS[45]['Z45_1782'] = ({**_n, 'n2': (_n['n2'][0], 'small')}, _l)
fill_rows(CELLS[118], [('Z118_1790', 1790, 'Hairpin', 'bow in', 1.0, 15, 0, False)])   # (w2) Y115_1783 mirrored (was a Ring)


# ================================================================================================================
# Density v2 (2026-11-18, density-brief.md): wall pairs (a half figure and its mirror across a wall road, one in each
# of the two cells the wall separates), figures grown, new pieces. Each half is its own piece. Every position chosen by
# hand; the helpers below only turn a hand-chosen description into nodes and links.
# ================================================================================================================
from celllib import wall_pair  # noqa: E402


def add(cell, pieces):
    """Add new pieces to a cell; names must be new (never overwrite)."""
    for k in pieces:
        assert k not in CELLS[cell], (cell, k)
    CELLS[cell].update(pieces)


def wall_half(wa, wb, t0, toward, pts, links):
    """A half figure in the frame of the wall through road nodes wa -> wb: origin at wa + t0 (wb - wa), u along the
    wall towards wb, v across it towards the point `toward` (a point inside the half's cell). pts {key: ((u, v),
    kind)} or {key: ('p', rho, phi, kind)} (polar round the origin, phi degrees from +u towards +v); links [(a, b,
    how)]: how None = straight, 'o' = an arc round the origin, (u, v) = an arc centre (checked equidistant), or
    ('b', bow) = a bowed arc (sagitta bow x chord, + bulging away from the origin). Road nodes as ints."""
    A, B = road(wa), road(wb)
    Lw = math.dist(A, B)
    U = ((B[0] - A[0]) / Lw, (B[1] - A[1]) / Lw)
    V = (-U[1], U[0])
    O = (A[0] + t0 * (B[0] - A[0]), A[1] + t0 * (B[1] - A[1]))
    if (toward[0] - O[0]) * V[0] + (toward[1] - O[1]) * V[1] < 0:
        V = (-V[0], -V[1])

    def W(u, v): return (O[0] + u * U[0] + v * V[0], O[1] + u * U[1] + v * V[1])
    uv = {}
    for k, p in pts.items():
        if p[0] == 'p':
            _, rho, phi, kind = p
            uv[k] = ((rho * math.cos(math.radians(phi)), rho * math.sin(math.radians(phi))), kind)
        else:
            uv[k] = p
    nodes = {k: (W(*q), kind) for k, (q, kind) in uv.items()}

    def at(x):
        if x in uv:
            return uv[x][0]
        R = road(x); d = (R[0] - O[0], R[1] - O[1])
        return (d[0] * U[0] + d[1] * U[1], d[0] * V[0] + d[1] * V[1])
    out = []
    for a, b, how in links:
        if how == 'o':
            how = (0.0, 0.0)
        if isinstance(how, tuple) and how and how[0] == 'b':
            p, q = at(a), at(b)
            c = bow_centre(p, q, how[1], (0.0, 0.0))
            out.append((a, b, W(*c)))
        elif how is not None:
            ra, rb = math.dist(at(a), how), math.dist(at(b), how)
            assert abs(ra - rb) < 0.03, (a, b, ra, rb)
            out.append((a, b, W(*how)))
        else:
            out.append((a, b, None))
    return nodes, out


def pair(cell_a, cell_b, name, wa, wb, half):
    """Mirror `half` (a (nodes, links) piece drawn on cell_a's side) across the wall wa-wb; the half goes in cell_a as
    name_a, its mirror in cell_b as name_b."""
    h, m = wall_pair({name: half}, wa, wb)
    add(cell_a, {name + '_a': h[name]})
    add(cell_b, {name + '_b': m[name]})
    return h[name], m[name]


def arch(n, sag, kinds, wa_u, wb_u, key='a'):
    """n nodes evenly on the arc through the wall points (wa_u, 0) and (wb_u, 0) bulging sag towards +v: returns
    pts {key0..: ((u, v), kind)} ordered from the wa end, and the arc centre (u, v)."""
    h = (wb_u - wa_u) / 2; m = (wa_u + wb_u) / 2
    R = (h * h + sag * sag) / (2 * sag); C = (m, sag - R)
    a0 = math.degrees(math.asin(h / R)); step = 2 * a0 / (n + 1)
    pts = {}
    for k in range(n):
        a = math.radians(-a0 + step * (k + 1))
        pts[f'{key}{k}'] = ((C[0] + R * math.sin(a), C[1] + R * math.cos(a)), kinds[k])
    return pts, C


# --- Spoke -23 (115 | 46, road nodes 1773 r 33.2 and 1785 r 41.7): EYE OF THE CURRENT, a lens of two shallow arches
# round the spoke's midpoint node 1979, each a pass-through of 5 from 1773 to 1785 with two notables.
_p, _c = arch(5, 1.9, ['small', 'notable', 'small', 'notable', 'small'], -4.25, 4.25)
pair(115, 46, 'eye_lens', 1773, 1785,
     wall_half(1773, 1785, 0.5, L(37.5, -26.0, LAND), _p,
               [(1773, 'a0', None), ('a0', 'a1', _c), ('a1', 'a2', _c), ('a2', 'a3', _c), ('a3', 'a4', _c), ('a4', 1785, None)]))
_n, _l = CELLS[115]['eye_lens_a']          # the 115 half: its second notable sat 1.1 from the channel's, made small
CELLS[115]['eye_lens_a'] = ({**_n, 'a3': (_n['a3'][0], 'small')}, _l)


def ring_pts(K, rho, angs, kinds, key):
    """Nodes on the circle of radius rho round K (wall-frame u, v), at angles in degrees (0 = +u, 90 = +v)."""
    return {f'{key}{i}': ((K[0] + rho * math.cos(math.radians(a)), K[1] + rho * math.sin(math.radians(a))), k)
            for i, (a, k) in enumerate(zip(angs, kinds))}


# --- Spoke -28 (59 | 103, 1879 r 64.3 -> 1991 r 69.3): WAVE SCROLLS, two breakers curling away from each other over
# the spoke: from 1879 an outer arc of 4 round the curl's centre over a crest notable, stepping in to an inner arc of 2
# that ends in the notable eye.
_K = (-0.4, 2.4)
_p = ring_pts(_K, 1.4, (230, 175, 120, 65), ['small', 'small', 'notable', 'small'], 'c')
_p.update(ring_pts(_K, 0.78, (10, -80), ['small', 'notable'], 'e'))
pair(59, 103, 'wave_scroll', 1879, 1991,
     wall_half(1879, 1991, 0.5, L(66.8, -25.5, LAND), _p,
               [(1879, 'c0', None), ('c0', 'c1', _K), ('c1', 'c2', _K), ('c2', 'c3', _K), ('c3', 'e0', None),
                ('e0', 'e1', _K)]))

# --- Cell 32: MOON HALO, two concentric arcs of moonlight on the moon's open side (round the moon's own centre, radii
# 4.3 and 3.0), the outer one hung from 1792, one radial link between them, notables at the free ends.
_O = L(45.9, 27.0, LAND)
add(32, {'moon_halo': fig(_O, {'h0': (4.3, -50, 'small'), 'h1': (4.3, -70, 'small'), 'h2': (4.3, -90, 'small'),
                               'h3': (4.3, -110, 'small'), 'h4': (4.3, -130, 'notable'),
                               'g0': (3.0, -65, 'notable'), 'g1': (3.0, -90, 'small'), 'g2': (3.0, -115, 'notable')},
                          [(1792, 'h0', None), ('h0', 'h1', 'o'), ('h1', 'h2', 'o'), ('h2', 'h3', 'o'), ('h3', 'h4', 'o'),
                           ('h2', 'g1', None), ('g1', 'g0', 'o'), ('g1', 'g2', 'o')])})

# --- Cell 46 (beside the Ice start; its pieces untouched): LOTUS BLOOM seen from above, a seed pod of 4 and four
# lens petals round one centre, turned 30 degrees, the petal facing 1787 entered from it, the other three tips notables.
_O = L(39.4, -11.0, LAND)
_lb = {f'i{a}': (0.7, a, 'small') for a in (75, 165, 255, 345)}
_lb.update({f't{a}': (1.5, a, 'small' if a == 210 else 'notable') for a in (30, 120, 210, 300)})
add(46, {'lotus_bloom': fig(_O, _lb, [(1787, 't210', None)] +
                            [(f'i{a}', f'i{(a + 90) % 360}', 'o') for a in (75, 165, 255, 345)] +
                            [(f'i{(t + 45) % 360}', f't{t}', 0.13) for t in (30, 120, 210, 300)] +
                            [(f'i{(t - 45) % 360}', f't{t}', 0.13) for t in (30, 120, 210, 300)])})

# --- Cell 54: the 59-side WAVE SCROLL mirrored across the land axis, hung from 1889 (no room for its partner in 108).
add(54, {'wave_scroll_m': mirror_pieces({'p': CELLS[59]['wave_scroll_a']}, LAND)['p']})

# --- Cell 17: a CURRENT round the koi pair's circle (radius 3.9 round the koi centre, on its outer +theta side), from
# 1814 up to a notable; cell 11's current round the whirlpool, varied (other side, other length).
# (w1) its first notable moved n2 -> n3: n2 sat 1.34 from koi_a's new notable.
add(17, {'koi_current': curve(O17, [(3.9, a) for a in (180, 158, 136, 114, 92, 70)],
                              ['small', 'small', 'small', 'notable', 'small', 'notable'], 1814)})

# --- Axis road 1500-1501 (11 | 17, outer band): AXIS RIPPLE, a ring of 8 the axis road runs through, each half an arc
# of 4 round the road's midpoint, hung from 1501, a notable at its end beside the road.
_K = (0.0, 0.0)
_p = ring_pts(_K, 1.9, (40, 77, 114, 151), ['small', 'small', 'small', 'notable'], 'a')
pair(11, 17, 'axis_ripple', 1500, 1501,
     wall_half(1500, 1501, 0.5, L(72.0, -2.0, LAND), _p,
               [(1501, 'a0', None), ('a0', 'a1', _K), ('a1', 'a2', _K), ('a2', 'a3', _K)]))

# --- Cell 26: a small WHIRLPOOL in the empty strip by the border road, winding in from 273 (seven nodes, the radius
# stepping down 1.85 -> 0.45 round one centre since w3), a notable half-way and at the eye.
# (w3) the radius now steps 1.85 -> 0.45 over a little less than a turn, so the whirlpool reads as a spiral with its
# eye inside, not as a third ring beside the raindrop and the waterwheel.
_S = [(1.85, 220), (1.65, 165), (1.45, 110), (1.2, 55), (0.95, 0), (0.7, -55), (0.45, -115)]
_p = {f'w{i}': ((0.6 + r * math.cos(math.radians(a)), 2.4 + r * math.sin(math.radians(a))),
                'notable' if i in (3, 6) else 'small') for i, (r, a) in enumerate(_S)}
add(26, {'whirlpool': wall_half(273, 1526, 0.0, L(50.0, -33.0, LAND), _p,
                                [(273, 'w0', None)] + [(f'w{i}', f'w{i + 1}', bow_centre(_p[f'w{i}'][0], _p[f'w{i + 1}'][0], 0.16,
                                                                                        (0.6, 2.4))) for i in range(6)])})
# (review pass 2026-11-18, w1: the whirlpool's links bowed round its centre, no longer straight steps)

# --- Cell 26: a REFLECTION (cell 32's reflection, varied: shorter, deeper, beside the clam), an arc of 5 hung at its
# middle from 1865, notable ends.
_O = L(50.6, -23.6, LAND)
add(26, {'reflection': fig(_O, {f'r{a}': (1.9, a, 'notable' if a in (125, 235) else 'small') for a in (125, 152, 180, 208, 235)},
                           [(1865, 'r180', None), ('r180', 'r152', 'o'), ('r152', 'r125', 'o'), ('r180', 'r208', 'o'),
                            ('r208', 'r235', 'o')])})

# --- Cell 26: RAINDROP RIPPLE between the whirlpool and the waterwheel: the drop, a ring of 6 hung from 1784, and one
# radial link below it an arc of 5 on an outer circle round the same centre, stepping out at its -theta end to a third
# circle, an arc of 4 rising towards 1783. It replaces the Tadpole off 272 (two small rings side by side read alike).
del CELLS[26]['T_tadpole']
_O = L(44.4, -28.6, LAND)
_rr = {f'q{a}': (1.05, a, 'small') for a in range(0, 360, 60)}
_rr.update({f'o{a}': (2.0, a, 'notable' if a == 130 else 'small') for a in (130, 155, 180, 205, 230)})
_rr.update({f'x{a}': (3.0, a, 'notable' if a in (255, 305) else 'small') for a in (230, 255, 280, 305)})
add(26, {'raindrop': fig(_O, _rr, [(1784, 'q0', None)] + [(f'q{a}', f'q{(a + 60) % 360}', 'o') for a in range(0, 360, 60)] +
                         [('q180', 'o180', None), ('o180', 'o155', 'o'), ('o155', 'o130', 'o'), ('o180', 'o205', 'o'),
                          ('o205', 'o230', 'o'), ('o230', 'x230', None), ('x230', 'x255', 'o'), ('x255', 'x280', 'o'),
                          ('x280', 'x305', 'o')])})

# --- Cell 22: the WAVE TRAIN grows a SWELL, a second row below it: an arc of 5 on the ring r 48.5 (round the same
# centre as the train's own ring), hung from the train's second trough by one link, notable ends.
_sw = {f'y{k}': (L(48.5, 5.3 + 1.3333 * k, LAND), 'notable' if k in (0, 4) else 'small') for k in range(5)}
_wn, _wl = CELLS[22]['wave_train']
CELLS[22]['wave_train'] = ({**_wn, **_sw}, _wl + [('a1', 'y3', None)] +
                           [(f'y{k}', f'y{k + 1}', bow_centre(_sw[f'y{k}'][0], _sw[f'y{k + 1}'][0], 0.22 * (-1) ** k,
                                                               (0.0, 0.0))) for k in range(4)])
# Review pass 2026-11-18 (w1): the swell's links bow alternately up and down (a small wave under the train) instead of
# lying along the ring r 48.5, where they read as one straight bar.

# --- Cell 118: the -23 eye lens's 115 half echoed across the land axis, varied: one shallow arch (pass-through of 5
# from 1779 to 1792, a notable at its crown) on the 118 side of spoke 23 (the 45 side holds the icicles).
_p, _c = arch(5, 1.7, ['small', 'small', 'notable', 'small', 'small'], -4.25, 4.25)
add(118, {'spoke_arch': wall_half(1779, 1792, 0.5, L(37.5, 26.0, LAND), _p,
                                  [(1779, 'a0', None), ('a0', 'a1', _c), ('a1', 'a2', _c), ('a2', 'a3', _c), ('a3', 'a4', _c),
                                   ('a4', 1792, None)])})

# --- Small fill in the crumbs left between figures (catalogue families, each named by hand and tested alone, then
# checked together): one per cell, kept small so the size mix stays near 54 / 31 / 15.
for _c, _row in ((17, ('Y17_1812', 1812, 'Crescent', 'bow in', 1.1, 40, 0, False)),   # (w2) was a round Diamond under the gourd (w3: the turning wave)
                 (38, ('Y38_1868', 1868, 'Crook', 'swept', 1.0, 10, 0, True)),   # (w2) was a round Diamond beside the Tadpole's ring
                 (54, ('Y54_1890', 1890, 'Crescent', 'bow out', 1.1, 170, 0, True))):
    add(_c, fill_rows({}, [_row]))

# (2026-11-19: the hub cell 82 diamonds hung from spokes 33 and 34 are gone with the hub's spokes; the hub is Chaos's)

# --- Cell 32: the MOON HALO's inner arc grows from 3 to 5 (notable ends at -40 and -140), the halo now big.
_hn, _hl = CELLS[32]['moon_halo']
_O = L(45.9, 27.0, LAND)
_hn = dict(_hn); _hn['g0'] = (_hn['g0'][0], 'small'); _hn['g2'] = (_hn['g2'][0], 'small')
_hn['gA'] = (orbit(_O, 3.0, -40), 'notable'); _hn['gB'] = (orbit(_O, 3.0, -140), 'notable')
CELLS[32]['moon_halo'] = (_hn, _hl + [('g0', 'gA', _O), ('g2', 'gB', _O)])
add(115, fill_rows({}, [('Y115_1783', 1783, 'Hairpin', 'bow in', 1.0, -15, 0, True)]))   # (w2) was a Ring over 26's raindrop ring


# --- Cell 38: a LOTUS BUD beside the lily pad, a lens bud on a short stem from 1867 (notable tip).
add(38, {'lotus_bud': petal(1867, -42, 1.0, 2.3, 0.7)})


# Hub cell 82 belongs to Chaos (swirls into the centre, user 2026-11-18): drawn in design/dao-do/cells/chaos.py.
CELLS[82] = {}

# 2026-11-19 (user: "Keystones should connect directly to the travel nodes like in PoE"): the keystones here were
# folded onto their roads: each now sits where its dead-end spur node was (1994, 449, removed from base-map.json)
# and links straight to the road node the spur hung from.
# 2026-11-19 (user: "add more" keystones, straight off the travel nodes like in PoE): a second pair on the rim at theta
# +-27.9, each linked straight to its ring node (1808 and its mirror 1798), clear of everything round it (1.6+).
CELLS[904]['keystone_rim_R'] = ({'k': ((-69.119, -33.921), 'keystone')}, [(1808, 'k', None)])
CELLS[904]['keystone_rim_L'] = ({'k': ((-10.902, -76.218), 'keystone')}, [(1798, 'k', None)])
