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
def curve(O, pts, kinds, entry, entry_arc=False):
    """A chain of nodes at (radius, ang) round centre O, entered from road node `entry`. Consecutive nodes on the same
    radius are joined by an arc round O, others by a straight link."""
    nodes, links = {}, []
    for k, ((rho, a), kind) in enumerate(zip(pts, kinds)):
        nodes[f'n{k}'] = (orbit(O, rho, a), kind)
    links.append((entry, 'n0', O if entry_arc else None))
    for k in range(1, len(pts)):
        same = abs(pts[k][0] - pts[k - 1][0]) < 1e-9 and abs(pts[k][1] - pts[k - 1][1]) < 179
        links.append((f'n{k - 1}', f'n{k}', O if same else None))
    return nodes, links


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
# reaching up-left from 1499; round them the meniscus, the splash cup and a Diamond off the axis node.
# ================================================================================================================
C1 = orbit(road(1985), 2.2, -90)          # crest circle, on the -theta side of 1985 (cell 76)
C2 = orbit(road(1985), 2.2, 90)           # trough circle, on the +theta side (cell 91)
# Consolidated 2026-11-18: the trough curls one node further in than the crest (so the two halves differ); a
# MENISCUS (a swag bridging 1868-1869 with a shorter concentric arc hung inside it) replaces the Ring and Hairpin off
# the top road; a SPLASH CROWN (a bowl entered from 1885, two rim spikes and a drop notable in its middle) replaces
# the Crook off 1885 and the Spur pair off 1884.
O91m = L(53.9, -5.45, LAND)
O91s = L(59.7, -4.6, LAND)
c91 = {
    'wave_trough': curve(C2, [(2.2, -140), (2.2, 180), (2.2, 140), (2.0, 95), (1.5, 50), (1.0, 5), (0.6, -60)],
                         ['small'] * 6 + ['notable'], 1985),
    'lotus_petal': petal(1499, -45, 1.0, 3.0, 0.8),
    'meniscus': fig(O91m, {'s0': (2.6, -120, 'small'), 's1': (2.6, -150, 'small'), 's2': (2.6, 180, 'small'),
                           's3': (2.6, 150, 'small'), 's4': (2.6, 120, 'small'), 'm': (1.4, 180, 'small'),
                           'i0': (1.4, -135, 'notable'), 'i1': (1.4, 135, 'notable')},
                    [(1868, 's0', None), ('s0', 's1', 'o'), ('s1', 's2', 'o'), ('s2', 's3', 'o'), ('s3', 's4', 'o'),
                     ('s4', 1869, None), ('s2', 'm', None), ('m', 'i0', 'o'), ('m', 'i1', 'o')]),
    'splash': fig(O91s, {'b0': (1.8, -120, 'small'), 'b1': (1.8, -150, 'small'), 'b2': (1.8, 180, 'small'),
                         'b3': (1.8, 150, 'small'), 'b4': (1.8, 120, 'small'), 'drop': (0.0, 0, 'notable'),
                         'k0': (2.3, -36, 'notable'), 'k1': (2.3, 36, 'notable')},
                  [(1885, 'b1', None), ('b1', 'b0', 'o'), ('b1', 'b2', 'o'), ('b2', 'b3', 'o'), ('b3', 'b4', 'o'),
                   ('b2', 'drop', None), ('b0', 'k0', 0.1), ('b4', 'k1', 0.1)]),
}
fill_rows(c91, [
    ('D drop',     1498, 'Diamond', 'round', 1.0, -50, 0, False),
])
CELLS[91] = c91

# Cell 76 (middle band, th -23..-11). Holds the WAVE crest curling over into the cell. Consolidated 2026-11-18: an
# EDDY (a spiral of 8 winding in from 1866, notables half-way and at the eye) replaces the Tadpole off 1866 and the
# Crescent off 1865; a SCALLOP (a hinge off 1882, three rays fanning up to a bumped outer edge of 5) replaces the Fork
# off 1881 and the Diamond off 1882.
O76e = L(56.6, -19.6, LAND)
O76s = L(62.3, -17.6, LAND)
EDDY = [(1.9, 30), (1.85, -15), (1.75, -60), (1.6, -105), (1.4, -150), (1.2, 165), (1.0, 120), (0.75, 75)]
SC = (-50, -25, 0, 25, 50)
c76 = {
    'wave_crest': curve(C1, [(2.2, 40), (2.2, 0), (2.2, -40), (2.0, -85), (1.5, -130), (1.0, -175)],
                        ['small', 'small', 'small', 'small', 'small', 'notable'], 1985),
    'eddy': curve(O76e, EDDY, ['small'] * 3 + ['notable'] + ['small'] * 3 + ['notable'], 1866),
    'scallop': fig(O76s, {'h': (0.0, 0, 'small'), **{f'r{k}': (1.5, SC[2 * k], 'small') for k in range(3)},
                          **{f'o{k}': (3.4, a, 'notable' if k in (1, 3) else 'small') for k, a in enumerate(SC)}},
                   [(1882, 'h', None)] + [('h', f'r{k}', None) for k in range(3)] +
                   [(f'r{k}', f'o{2 * k}', None) for k in range(3)] + [(f'o{k}', f'o{k + 1}', 0.18) for k in range(4)]),
}
CELLS[76] = c76

# Cell 86 = cell 91 mirrored across the axis (WAVE trough from 1986, LOTUS petal up-right, meniscus, splash cup),
# one change: the Diamond off the axis node is cusped. (The Wheel off 1876 went with the consolidation.)
c86 = mirror_pieces({k: v for k, v in c91.items() if k not in ('D_drop',)}, LAND)
fill_rows(c86, [('D drop', 1498, 'Diamond', 'cusped', 1.0, 50, 0, True)])
CELLS[86] = c86

# Cell 69 = cell 76 mirrored (WAVE crest from 1986, the eddy from 1873), with its own big figure instead of the scallop.
# A LEAPING CARP replaces the Spur pair off 1891 and the Hairpin off 1892: a lens body (two arcs between the head and
# the tail root), a forked tail, a dorsal and a pectoral fin, entered at the belly from 1892; head up-left.
def _lens(u, R=(0.45, 1.48)):         # the body arcs: circles through the head (2.4, 0) and the tail root (-1.5, 0)
    c = R[1]; rr = math.hypot(1.95, c)
    return (u, (rr * rr - (u - R[0]) ** 2) ** 0.5 - c)


CARP = {'head': ((2.4, 0.0), 'notable'), 'u1': (_lens(1.2), 'small'), 'u2': (_lens(-0.2), 'small'),
        'l1': ((1.2, -_lens(1.2)[1]), 'small'), 'l2': ((-0.2, -_lens(-0.2)[1]), 'small'), 'tail': ((-1.5, 0.0), 'small'),
        'f1': ((-2.6, 0.95), 'notable'), 'f2': ((-2.6, -0.95), 'notable'), 'dorsal': ((-0.1, 1.95), 'notable'),
        'pect': ((1.3, -1.95), 'notable')}
c69 = mirror_pieces({k: v for k, v in c76.items() if k != 'scallop'}, LAND)
c69['carp'] = uv_fig(L(61.0, 17.6, LAND), -50, CARP,
                     [(1892, 'l2', None), ('head', 'u1', (0.45, -1.48)), ('u1', 'u2', (0.45, -1.48)),
                      ('u2', 'tail', (0.45, -1.48)), ('head', 'l1', (0.45, 1.48)), ('l1', 'l2', (0.45, 1.48)),
                      ('l2', 'tail', (0.45, 1.48)), ('tail', 'f1', None), ('tail', 'f2', None), ('u2', 'dorsal', None),
                      ('l1', 'pect', None)])
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
c11 = {
    'whirlpool': curve(O11, SPIRAL, ['small'] * 6 + ['notable'] + ['small'] * 5 + ['notable'], 1804),
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
# arcs chasing round one circle (one entered from the top road, one from the bottom), each with an eye notable inside
# and a notable head. With the LOTUS petal down-right from 1499 (cell 11's petal mirrored, so the flower is even).
# ================================================================================================================
O17 = L(69.3, 8.6, LAND)
RK = 2.6


def koi(entry, angs, eye_at, eye_ang, head='notable'):
    pts = [(RK, a) for a in angs]
    nodes, links = curve(O17, pts, ['small'] * (len(pts) - 1) + [head], entry)
    nodes['eye'] = (orbit(O17, 1.1, eye_ang), 'notable')
    links.append((f'n{eye_at}', 'eye', None))
    return nodes, links


c17 = {
    'koi_a': koi(1894, (25, 60, 95, 130, 160), 2, 80),
    'koi_b': koi(1814, (205, 240, 275, 310, 340), 2, 260),
    'lotus_petal': mirror_pieces({'p': petal(1499, -135, 1.0, 3.2, 0.85)}, LAND)['p'],
}
# Consolidated 2026-11-18: a SEAHORSE (gripping the bottom road at 1816 by its tail: the tail curls round its own small
# circle, the body arcs up round a second, a snout and a dorsal fin) replaces the Tadpole off 1816 and the Ring off
# 1815; a WATER GOURD (ho lo: a ring of 4 hung from 1893 above a ring of 7, one neck link) replaces the Diamond off
# 1893, the Diamond off 1892 and the Arch off 1812.
SK = 0.85                            # the seahorse's scale
TC = (-2.9 * SK, 0.0)                # its tail circle (u up, v right); the body circle is round (0, 0), radius 2.2 SK


def _on(c, rho, deg):
    return (c[0] + rho * math.cos(math.radians(deg)), c[1] + rho * math.sin(math.radians(deg)))


def _body(deg):
    return _on((0.0, 0.0), 2.2 * SK, deg)


SEAHORSE = {'t1': (_on(TC, 1.1 * SK, 200), 'small'), 't2': (_on(TC, 1.1 * SK, 120), 'small'),
            't3': (_on(TC, 1.1 * SK, 60), 'notable'), 'b4': (_body(-145), 'small'), 'b3': (_body(-105), 'small'),
            'b2': (_body(-65), 'small'), 'b1': (_body(-25), 'small'), 'h0': (_body(15), 'small'),
            'snout': ((2.0 * SK, 1.75 * SK), 'notable'), 'fin': ((1.1 * SK, -3.0 * SK), 'notable')}
c17['seahorse'] = uv_fig(L(70.0, 3.8, LAND), 0, SEAHORSE,
                         [(1816, 't1', None), ('t1', 't2', TC), ('t2', 't3', TC), ('t1', 'b4', None),
                          ('b4', 'b3', (0.0, 0.0)), ('b3', 'b2', (0.0, 0.0)), ('b2', 'b1', (0.0, 0.0)),
                          ('b1', 'h0', (0.0, 0.0)), ('h0', 'snout', None), ('b2', 'fin', None)])
O17g1, O17g2 = L(66.3, 14.1, LAND), L(69.5, 14.1, LAND)
g_top = fig(O17g1, {f'g{k}': (0.8, 90 * k, 'small') for k in range(4)},
            [(1893, 'g0', None)] + [(f'g{k}', f'g{(k + 1) % 4}', 'o') for k in range(4)])
g_bot = fig(O17g2, {f'h{k}': (1.45, 360 * k / 7, 'notable' if k in (2, 5) else 'small') for k in range(7)},
            [(f'h{k}', f'h{(k + 1) % 7}', 'o') for k in range(7)])
c17['gourd'] = ({**g_top[0], **g_bot[0]}, g_top[1] + g_bot[1] + [('g2', 'h0', None)])

CELLS[17] = c17

# ================================================================================================================
# Cell 59 (outer band, th -28..-17). Centre figure: a RIPPLE, two concentric arches rising from the bottom ring node
# 1799 - the inner one hung from 1799 itself, the outer from its neighbour 1800 - with a notable at the top of the
# outer arch and at each end. Fill: a Tadpole off the left spoke node 1991, the starfish below.
# ================================================================================================================
O59 = road(1799)
# Consolidated 2026-11-18: the outer arch grows to 7 (ends lower, notables at the top and the left end); a STARFISH
# (five arms at even 72-degree steps round a hub off 1880, four ending in notables) replaces the Hook off 1880, the
# Crook off 1881 and the Crescent off 1879.
O59s = L(67.3, -21.5, LAND)
STAR = [-28 + 72 * k for k in range(5)]
c59 = {
    'ripple_inner': curve(O59, [(1.8, -62), (1.8, -21), (1.8, 21), (1.8, 62)], ['small', 'small', 'small', 'notable'], 1799),
    'ripple_outer': curve(O59, [(3.4, 76), (3.4, 51), (3.4, 25), (3.4, 0), (3.4, -25), (3.4, -51), (3.4, -76)],
                          ['small', 'small', 'small', 'notable', 'small', 'small', 'notable'], 1800),
    'starfish': fig(O59s, {'hub': (0.0, 0, 'small'), 'a0': (1.0, STAR[0], 'small'),
                           **{f'i{k}': (1.0, STAR[k], 'small') for k in range(1, 5)},
                           **{f't{k}': (2.3, STAR[k] + 22, 'notable') for k in range(1, 5)}},
                    [(1880, 'a0', None), ('a0', 'hub', None)] + [('hub', f'i{k}', None) for k in range(1, 5)] +
                    [(f'i{k}', f't{k}', ('L', 0.2)) for k in range(1, 5)]),
}
fill_rows(c59, [
    ('T tadpole',  1991, 'Tadpole', 'round', 1.1, 90, 0, False),
])
CELLS[59] = c59

# Cell 54 = cell 59's ripple and Tadpole mirrored (ripple from 1809/1810), with its own big figure.
# Its big figure is the BLACK TORTOISE (Huyen Vu, Water's guardian beast): a shell ring of 6 hung from 1891,
# head on a neck and four flippers (the notables) out from the ring, swimming outward. It replaces the Diamond off 1891 and the
# Hairpin off 1889.
O54t = L(67.3, 20.5, LAND)
c54 = mirror_pieces({k: v for k, v in c59.items() if k in ('ripple_inner', 'ripple_outer', 'T_tadpole')}, LAND)
c54['tortoise'] = fig(O54t, {**{f's{k}': (1.3, 60 * k, 'small') for k in range(6)}, 'neck': (2.1, 180, 'small'),
                             'head': (2.9, 180, 'notable'), 'ff0': (2.5, 135, 'notable'), 'ff1': (2.5, -135, 'notable'),
                             'bf0': (2.2, 40, 'notable'), 'bf1': (2.2, -40, 'notable')},
                      [(1891, 's0', None)] + [(f's{k}', f's{(k + 1) % 6}', 'o') for k in range(6)] +
                      [('s3', 'neck', None), ('neck', 'head', None), ('s2', 'ff0', None), ('s4', 'ff1', None),
                       ('s1', 'bf0', None), ('s5', 'bf1', None)])
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
    ('K kelp2',    1807, 'Zigzag', 'wave', 1.0, 6, 0, True),
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
c108['drip_hook'] = curve(L(67.4, 33.0, LAND), [(2.0, -25), (2.0, 15), (2.0, 55), (2.0, 95), (2.0, 135), (1.1, 235)],
                          ['small', 'small', 'small', 'notable', 'small', 'notable'], 1887)
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
_sw['l1'] = (L(58.4, -26.5, LAND), 'small')
_sw['l2'] = (L(57.4, -27.2, LAND), 'notable')
_swc = L(60.6, -25.1, LAND)
c42['seaweed'] = (_sw, [(1880, 'w0', None)] +
                  [(f'w{k}', f'w{k + 1}', bow_centre(_sw[f'w{k}'][0], _sw[f'w{k + 1}'][0], 0.18 * (1 if k % 2 else -1), _swc))
                   for k in range(5)] + [('w3', 'l1', None), ('l1', 'l2', None)])
CELLS[42] = c42

# ================================================================================================================
# Cell 38 (41.7-53.9, th -18..0, the axis hex and the Ice start on its right). Centre figure: a LILY PAD, an open ring
# of 9 with its notch towards the tree centre, the notch ends notables, a bud notable inside. Fill: a Tadpole + below.
# ================================================================================================================
O38 = L(48.2, -10.2, LAND)
PAD = [30 + 37.5 * k for k in range(9)]
pad_nodes = {f'p{k}': (orbit(O38, 2.3, a), 'notable' if k in (0, 8) else 'small') for k, a in enumerate(PAD)}
pad_nodes['bud'] = (orbit(O38, 0.9, 60), 'notable')
pad_links = [(1868, 'p4', None)] + [(f'p{k}', f'p{k + 1}', O38) for k in range(8)] + [('p2', 'bud', None)]
c38 = {'lily_pad': (pad_nodes, pad_links)}
fill_rows(c38, [
    ('T tadpole',  1869, 'Tadpole', 'round', 1.1, 5, 0, False),
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
c38['falling_drop'] = fig(O38d, {**{f'r{a}': (1.0, a, 'notable' if a in (60, 300) else 'small') for a in range(0, 360, 60)},
                                 't1': (2.1, 195, 'small'), 't2': (3.2, 208, 'small')},
                          [(1866, 't2', None), ('t2', 't1', ('L', 0.12)), ('t1', 'r180', ('L', 0.12))] +
                          [(f'r{a}', f'r{(a + 60) % 360}', 'o') for a in range(0, 360, 60)])
CELLS[38] = c38

# ================================================================================================================
# Cell 22 (41.7-53.9, th 0..18). Centre figure: a FOUNTAIN, a jet rising from the bottom road (1875) to a notable, two
# side jets falling away left and right to notables. Fill: a Crescent and the figures below.
# ================================================================================================================
R1875 = road(1875)
from celllib import direction as _dir  # noqa: E402
up = _dir(R1875, 0); side = _dir(R1875, 90)
def _p(a, b): return (R1875[0] + a * up[0] + b * side[0], R1875[1] + a * up[1] + b * side[1])
fountain_nodes = {'j1': (_p(1.2, 0), 'small'), 'j2': (_p(2.4, 0), 'small'), 'j3': (_p(3.7, 0), 'notable'),
                  'l1': (_p(2.9, -1.1), 'small'), 'l2': (_p(2.2, -2.2), 'notable'),
                  'r1': (_p(2.9, 1.1), 'small'), 'r2': (_p(2.2, 2.2), 'notable')}
cf = ((_p(2.4, 0)[0]), _p(2.4, 0)[1])
fountain_links = [(1875, 'j1', None), ('j1', 'j2', None), ('j2', 'j3', None),
                  ('j2', 'l1', bow_centre(_p(2.4, 0), _p(2.9, -1.1), 0.2, _p(1.0, 0))), ('l1', 'l2', bow_centre(_p(2.9, -1.1), _p(2.2, -2.2), 0.2, _p(1.0, 0))),
                  ('j2', 'r1', bow_centre(_p(2.4, 0), _p(2.9, 1.1), 0.2, _p(1.0, 0))), ('r1', 'r2', bow_centre(_p(2.9, 1.1), _p(2.2, 2.2), 0.2, _p(1.0, 0)))]
c22 = {'fountain': (fountain_nodes, fountain_links)}
fill_rows(c22, [
    ('C crescent', 1793, 'Crescent', 'bow in', 1.1, 215, 0, True),
])
# Consolidated 2026-11-18. A WAVE TRAIN across the empty middle: four humps (arcs round their own centres on the ring
# r 46.3, alternately up and down), hung from 1794 by a stem into the third hump's crest, the two ends notables; it
# replaces the Hairpin off 1794 and the Crescent off 1796. A LOTUS BUD hangs from 1795 into the pocket above the second
# hump (a lens bud with a notable tip and a leaf), replacing the Ring off 1795. A SHRIMP (a C of 5 round its centre,
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
c22['shrimp'] = fig(O22s, {**{f'b{a}': (1.5, a, 'small') for a in (135, 180, 225, 270, 315)},
                           'f0': (2.3, 110, 'notable'), 'f1': (2.3, 75, 'notable'), 'ant': (2.5, 340, 'notable')},
                    [(1874, 'b225', None)] + [(f'b{a}', f'b{a + 45}', 'o') for a in (135, 180, 225, 270)] +
                    [('b135', 'f0', None), ('b135', 'f1', None), ('b315', 'ant', None)])
CELLS[22] = c22

# ================================================================================================================
# Cell 26 (41.7-53.9, th -36..-18). Centre figure: a CLAM with a PEARL, a half-ring shell opening towards the tree
# centre, its rims notables, a pearl notable in the middle. Fill: Tadpole off the border road, Diamond, waterwheel.
# ================================================================================================================
O26 = L(48.4, -27.2, LAND)
SHELL = [90, 120, 150, 180, 210, 240, 270]
shell_nodes = {f's{k}': (orbit(O26, 2.4, a), 'notable' if k in (0, 6) else 'small') for k, a in enumerate(SHELL)}
shell_nodes['pearl'] = (O26, 'notable')
shell_links = [(1864, 's3', None)] + [(f's{k}', f's{k + 1}', O26) for k in range(6)] + [('s2', 'pearl', None)]
c26 = {'clam': (shell_nodes, shell_links)}
fill_rows(c26, [
    ('T tadpole',  272, 'Tadpole', 'round', 1.1, 90, 0, False),
    ('D diamond',  1866, 'Diamond', 'round', 1.1, -42, 0, False),
])
# Consolidated 2026-11-18: a WATERWHEEL (a ring of 8 hung from 1785, two spokes to a notable hub, two paddles hanging
# from its lower rim) replaces the Crook off 1784, the Tadpole off 1785 and the Hairpin off 1786.
O26w = L(45.4, -23.0, LAND)
c26['waterwheel'] = fig(O26w, {**{f'r{a}': (2.0, a, 'small') for a in range(0, 360, 45)}, 'hub': (0.0, 0, 'notable'),
                               'p0': (2.9, 130, 'notable'), 'p1': (2.9, -130, 'notable')},
                        [(1785, 'r0', None)] + [(f'r{a}', f'r{(a + 45) % 360}', 'o') for a in range(0, 360, 45)] +
                        [('r90', 'hub', None), ('r270', 'hub', None), ('r135', 'p0', None), ('r225', 'p1', None)])
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
refl_nodes = {f'w{k}': (orbit(O32, 2.5, a), 'notable' if k in (0, 6) else 'small') for k, a in enumerate(REFL)}
refl_links = [(1871, 'w3', None)] + [(f'w{k}', f'w{k + 1}', O32) for k in range(6)]
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
    star_nodes[f'a{k}'] = (orbit(hub, 1.05, a), 'small')
    star_nodes[f'n{k}'] = (orbit(hub, 2.1, a + (12 if k != 1 else 0)), 'notable')
    star_links += [('h', f'a{k}', None), (f'a{k}', f'n{k}', None)]
c46 = {'frost_star': (star_nodes, star_links)}
# Consolidated 2026-11-18 (beside the Ice start, light touch; the start figure itself is not touched): an ICE CRYSTAL (a
# hexagonal ring of 6 hung from 1776, an icicle of two hanging from its far side) replaces the Tadpole off 1776 and the
# Crook off 1788.
O46c = L(35.75, -7.8, LAND)
c46['ice_crystal'] = fig(O46c, {**{f'r{k}': (1.0, 60 * k, 'notable' if k in (2, 4) else 'small') for k in range(6)},
                                'd1': (2.0, 180, 'small'), 'd2': (3.0, 180, 'notable')},
                         [(1776, 'r0', None)] + [(f'r{k}', f'r{(k + 1) % 6}', 'o') for k in range(6)] +
                         [('r3', 'd1', None), ('d1', 'd2', None)])
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
                                   'w0': (2.0, 90, 'notable'), 'w1': (2.0, 270, 'notable')},
                            [(1793, 'r0', None)] + [(f'r{k}', f'r{(k + 1) % 6}', 'o') for k in range(6)] +
                            [('r4', 'w0', None), ('r2', 'w1', None)])
CELLS[45] = c45

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
# Big figure: a JELLYFISH beside the axis road, its dome entered from axis node 452 (r 84) and two tentacles trailing
# outward. Three catalogue pieces, the great wave and the dragon hang outward from the outer ring. Keystones: one past the +12 hook end (1994), one
# past the connector's open end (449). Each keystone alone on one link.
# ================================================================================================================
OJ = L(83.6, 2.6, LAND)
jelly_nodes = {f'b{k}': (orbit(OJ, 1.8, a), 'notable' if k == 4 else 'small') for k, a in enumerate((-80, -40, 0, 40, 80))}
jelly_nodes['t1'] = (orbit(OJ, 1.9, -150), 'small')
jelly_nodes['t2'] = (orbit(OJ, 3.0, -165), 'notable')
jelly_nodes['u1'] = (orbit(OJ, 1.9, 150), 'small')
jelly_nodes['u2'] = (orbit(OJ, 3.0, 165), 'notable')
jelly_links = [(452, 'b0', None), ('b0', 'b1', OJ), ('b1', 'b2', OJ), ('b2', 'b3', OJ), ('b3', 'b4', OJ),
               ('b1', 't1', None), ('t1', 't2', None), ('b3', 'u1', None), ('u1', 'u2', None)]
c904 = {
    'jellyfish': (jelly_nodes, jelly_links),
    'keystone_hook': ({'k': (L(81.9, 12.3, LAND), 'keystone')}, [(1994, 'k', None)]),
    'keystone_dark': ({'k': (L(86.7, -8.3, LAND), 'keystone')}, [(449, 'k', None)]),
}
fill_rows(c904, [
    ('O crook',    1806, 'Crook', 'bow out', 1.2, 200, 0, True),
    ('O ring',     1804, 'Ring', 'round', 1.2, 180, 0, False),
    ('O diamond',  1814, 'Diamond', 'cusped', 1.2, 180, 0, False),
])
# Consolidated 2026-11-18. A GREAT WAVE (a breaker: a spiral curl of 8 hung outward from 1800, winding round its own
# centre to a notable eye, two foam claws off its outer crest) replaces the Hairpin off 1800 and the Tadpole off 1798.
# A WATER DRAGON (an S of two half-circles winding outward from 1810, a notable head with two horns) replaces the Fork
# off 1810 and the Crescent off 1808.
O904w = L(80.2, -22.5, LAND)
GW = [(3.8, 30), (3.8, 70), (3.6, 110), (3.3, 150), (2.8, 185), (2.2, 215), (1.6, 240), (1.0, 265)]
gw = curve(O904w, GW, ['small'] * 7 + ['notable'], 1800)
gw[0]['c2a'] = (orbit(O904w, 4.7, 108), 'small')
gw[0]['c2b'] = (orbit(O904w, 5.6, 104), 'notable')
gw[0]['c3'] = (orbit(O904w, 4.4, 152), 'notable')
gw[1].extend([('n2', 'c2a', None), ('c2a', 'c2b', None), ('n3', 'c3', None)])
c904['great_wave'] = gw
CA, CB = L(77.5, 21.0, LAND), L(81.1, 21.0, LAND)
_dA = fig(CA, {'a0': (1.8, 0, 'small'), 'a1': (1.8, 60, 'small'), 'a2': (1.8, 120, 'small'), 'J': (1.8, 180, 'small')},
          [(1810, 'a0', None), ('a0', 'a1', 'o'), ('a1', 'a2', 'o'), ('a2', 'J', 'o')])
_dB = fig(CB, {'b1': (1.8, -60, 'small'), 'b2': (1.8, -120, 'small'), 'b3': (1.8, 180, 'small'),
               'head': (2.9, 180, 'notable'), 'h1': (3.9, 172, 'notable'), 'h2': (3.9, 188, 'notable')},
          [('J', 'b1', CB), ('b1', 'b2', 'o'), ('b2', 'b3', 'o'), ('b3', 'head', None), ('head', 'h1', None),
           ('head', 'h2', None)])
c904['dragon'] = ({**_dA[0], **_dB[0]}, _dA[1] + _dB[1])
CELLS[904] = c904

# ================================================================================================================
# Density pass: for each free road node I listed families in my order of preference; a test (out/water_dense.py)
# kept the first of my options that passed, near the direction into the cell. Reviewed by eye after; edits below.
# ================================================================================================================
fill_rows(CELLS[76], [('Z76_1880', 1880, 'Diamond', 'round', 1.1, 48, 0, True)])
fill_rows(CELLS[76], [('Z76_1867', 1867, 'Diamond', 'round', 1.4, -128, 0, False)])
fill_rows(CELLS[69], [('Z69_1890', 1890, 'Diamond', 'round', 1.1, -48, 0, True)])
fill_rows(CELLS[69], [('Z69_1874', 1874, 'Diamond', 'round', 1.4, 128, 0, False)])
fill_rows(CELLS[91], [('Z91_1867', 1867, 'Diamond', 'round', 1.1, 132, 0, True)])
fill_rows(CELLS[86], [('Z86_1874', 1874, 'Diamond', 'round', 1.1, -132, 0, True)])
fill_rows(CELLS[86], [('Z86_1894', 1894, 'Crescent', 'bow in', 1.4, -62, 0, False)])
fill_rows(CELLS[11], [('Z11_1884', 1884, 'Crook', 'swept', 1.4, 118, 0, True)])
fill_rows(CELLS[11], [('Z11_1500', 1500, 'Crescent', 'bow in', 1.1, -85, 0, False)])
fill_rows(CELLS[11], [('Z11_1801', 1801, 'Diamond', 'round', 1.1, 45, 0, True)])
fill_rows(CELLS[17], [('Z17_1895', 1895, 'Crook', 'bow in', 1.4, 118, 0, True)])
fill_rows(CELLS[59], [('Z59_1801', 1801, 'Hook', 'bow in', 1.1, -51, 0, False)])
fill_rows(CELLS[54], [('Z54_1811', 1811, 'Crescent', 'bow in', 1.1, 38, 0, False)])
fill_rows(CELLS[103], [('Z103_512', 512, 'Tadpole', 'cusped', 1.1, 44, 0, False)])
fill_rows(CELLS[42], [('Z42_1877', 1877, 'Diamond', 'round', 1.1, 21, 0, False)])
fill_rows(CELLS[38], [('Z38_1789', 1789, 'Ring', 'round', 1.4, -174, 0, False)])
fill_rows(CELLS[38], [('Z38_1786', 1786, 'Hook', 'bow out', 1.1, 144, 0, False)])
fill_rows(CELLS[22], [('Z22_1876', 1876, 'Tadpole', 'cusped', 1.4, 5, 0, False)])
fill_rows(CELLS[26], [('Z26_1863', 1863, 'Hook', 'bow in', 1.1, 36, 0, True)])
fill_rows(CELLS[32], [('Z32_1790', 1790, 'Diamond', 'cusped', 1.1, -145, 0, False)])
fill_rows(CELLS[46], [('Z46_1786', 1786, 'Ring', 'round', 1.1, 30, 0, False)])
fill_rows(CELLS[45], [('Z45_1794', 1794, 'Crescent', 'bow out', 1.1, -16, 0, False)])
fill_rows(CELLS[45], [('Z45_1782', 1782, 'Ring', 'round', 1.1, 154, 0, False)])
fill_rows(CELLS[118], [('Z118_1790', 1790, 'Ring', 'round', 1.4, 9, 0, False)])

