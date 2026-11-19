"""The three islands, hand-placed by Claude 2026-11-18 night (user: "Light should be simple, just do light rays going out,
the moon should have these celeste mystical curves you know, and lightning im not so sure how").

  931 Light (Quang), centre (0, 112): straight rays out from the outer ring, long and short in turn, and four diagonal
      rays between the rings. Simple on purpose.
  932 Thunder (Loi), centre (-103.7, -33.7): in each of the five web cells a zigzag bolt striking from a point of the
      star ring out to the ring outside it, most of them forked; in the two outer cells a scalloped storm cloud hung
      between outer-arc road nodes with drops or a bolt under it; two bolts out from the open side.
  933 Darkness / the Moon (Am), centre (0, -95.7): six terminator curves across the crescent's body, outer arc to
      inner arc, bowing more towards the tips like the phases of the moon (bulging towards the start, so they clear the outer arc); in the hollow a full moon (a ring of 8 on a
      stem) inside two arcs and a halo, all on circles round the full moon's centre; an eclipse ring in the side circle.

Angles here are local: a = degrees from +y towards +x round the given centre (Fire at the bottom is +y).
"""
import math
import os
import sys

sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', 'tools', 'design',
                                'dao_do_rework', 'cells'))
from celllib import road  # noqa: E402

THEME = 'island'
CELLS = {}


def Q(C, r, a):                      # point at radius r, local angle a round C
    t = math.radians(a)
    return (C[0] + r * math.sin(t), C[1] + r * math.cos(t))


def ang(C, p):
    return math.degrees(math.atan2(p[0] - C[0], p[1] - C[1]))


def chain(keys):
    return [(keys[i], keys[i + 1], None) for i in range(len(keys) - 1)]


def bowed(u, v, bow, toward, n, kinds):
    """n nodes on one circular arc from road node u to road node v (pass-through), sagitta = bow x chord, bulging
    towards the point `toward`. Returns (nodes, links) with arc links round the circle's centre."""
    A, B = road(u), road(v)
    m = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
    h = math.dist(A, B) / 2
    nx, ny = -(B[1] - A[1]) / (2 * h), (B[0] - A[0]) / (2 * h)
    if nx * (toward[0] - m[0]) + ny * (toward[1] - m[1]) < 0:
        nx, ny = -nx, -ny
    s = bow * 2 * h
    R = (h * h + s * s) / (2 * s)
    c = (m[0] - nx * (R - s), m[1] - ny * (R - s))
    t1 = math.atan2(A[1] - c[1], A[0] - c[0])
    t2 = math.atan2(B[1] - c[1], B[0] - c[0])
    dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    nodes = {f'b{i}': ((c[0] + R * math.cos(t1 + dt * (i + 1) / (n + 1)), c[1] + R * math.sin(t1 + dt * (i + 1) / (n + 1))),
                       kinds[i]) for i in range(n)}
    keys = [u] + [f'b{i}' for i in range(n)] + [v]
    return nodes, [(keys[i], keys[i + 1], c) for i in range(len(keys) - 1)]


# ---------------------------------------------------------------- 931 Light ------------------------------------------
LC = (0.0, 112.0)
light = {}
ring_ids = {round(ang(LC, road(i))) % 360: i for i in range(529, 549)}
for a, rid in sorted(ring_ids.items()):
    if a in (0, 90, 180, 270):
        continue                                     # the four spokes
    long_ = a % 36 == 0
    rs = (14.3, 15.6, 16.9, 18.2) if long_ else (14.3, 15.6, 16.9)
    nodes = {f'r{i}': (Q(LC, r, a), 'notable' if i == len(rs) - 1 else 'small') for i, r in enumerate(rs)}
    light[f'ray{a}'] = (nodes, chain([rid] + list(nodes)))
for a, rid in ((45, 522), (135, 524), (225, 526), (315, 528)):
    rs = (7.7, 8.9, 10.1, 11.3)
    nodes = {f'r{i}': (Q(LC, r, a), 'notable' if i == 3 else 'small') for i, r in enumerate(rs)}
    light[f'inray{a}'] = (nodes, chain([rid] + list(nodes)))
CELLS[931] = light

# ---------------------------------------------------------------- 932 Thunder ----------------------------------------
TC = (-103.665, -33.683)


def bolt(u, v, w, flip, fork=None):
    """A zigzag bolt from road node u to road node v: 5 nodes at even steps along the line, offset sideways by +-w in
    turn (flip sets which side first), the middle one a notable. fork = (at, side, length, w2): a 2-node branch from
    node `at` (0-4) going off at the given side, ending in a notable."""
    A, B = road(u), road(v)
    dx, dy = B[0] - A[0], B[1] - A[1]
    Lh = math.hypot(dx, dy)
    ex, ey = dx / Lh, dy / Lh
    px, py = -ey, ex
    nodes = {}
    for i in range(5):
        t = (i + 1) / 6
        o = w * (1 if (i % 2 == 0) == flip else -1)
        nodes[f'z{i}'] = ((A[0] + dx * t + px * o, A[1] + dy * t + py * o), 'notable' if i == 2 else 'small')
    links = chain([u] + [f'z{i}' for i in range(5)] + [v])
    if fork:
        at, _, ln, w2 = fork
        side = 1 if (at % 2 == 0) == flip else -1     # branch off the outer corner of that zag, away from the line
        base = nodes[f'z{at}'][0]
        f0 = (base[0] + (ex * 0.7 + px * side) * ln / 1.22, base[1] + (ey * 0.7 + py * side) * ln / 1.22)
        f1 = (f0[0] + (ex * 0.8 + px * side * w2) * ln * 0.8, f0[1] + (ey * 0.8 + py * side * w2) * ln * 0.8)
        nodes['f0'], nodes['f1'] = (f0, 'small'), (f1, 'notable')
        links += [(f'z{at}', 'f0', None), ('f0', 'f1', None)]
    return nodes, links


def out_bolt(u, a, fork_side):
    """A bolt from a road node outwards along local angle a round the island centre: zigzag, ends in a notable, with a
    one-node notable spark off its second node."""
    P = road(u)
    r0 = math.dist(TC, P)
    nodes = {}
    for i, (dr, da) in enumerate(((1.25, 3.5), (2.5, -3.0), (3.75, 3.0), (5.0, -2.0))):
        nodes[f'o{i}'] = (Q(TC, r0 + dr, a + da), 'notable' if i == 3 else 'small')
    nodes['sp'] = (Q(TC, r0 + 3.3, a + fork_side * 8.5), 'notable')
    return nodes, chain([u, 'o0', 'o1', 'o2', 'o3']) + [('o1', 'sp', None)]


def cloud(u, v, angs, drops, rr=15.4, bulge=0.28):
    """A storm cloud: nodes on the circle r=rr round the island centre at the given local angles, hung from outer-arc
    road nodes u and v; links between cloud nodes are scallops bulging outwards; the middle node is a notable; drops:
    {index: (dr, da)} one notable drop hung under that node."""
    pts = [Q(TC, rr, a) for a in angs]
    kinds = ['small'] * len(angs)
    kinds[len(angs) // 2] = 'notable'
    nodes = {f'c{i}': (p, k) for i, (p, k) in enumerate(zip(pts, kinds))}
    links = [(u, 'c0', None), (f'c{len(angs) - 1}', v, None)]
    for i in range(len(angs) - 1):
        p, q = pts[i], pts[i + 1]
        m = ((p[0] + q[0]) / 2, (p[1] + q[1]) / 2)
        h = math.dist(p, q) / 2
        s = bulge * 2 * h
        R = (h * h + s * s) / (2 * s)
        nx, ny = m[0] - TC[0], m[1] - TC[1]
        k = math.hypot(nx, ny)
        nx, ny = nx / k, ny / k
        c = (m[0] - nx * (R - s), m[1] - ny * (R - s))
        links.append((f'c{i}', f'c{i + 1}', c))
    for i, (dr, da) in drops.items():
        nodes[f'd{i}'] = (Q(TC, rr - dr, angs[i] + da), 'notable')
        links.append((f'c{i}', f'd{i}', None))
    return nodes, links


thunder = {
    # five web cells: star point (r 4.3) -> outer ring; forks vary
    'bolt0': bolt(555, 567, 0.75, True, (1, -1, 1.6, 0.4)),
    'bolt72': bolt(557, 570, 0.7, False, (1, 1, 1.5, 0.5)),
    'bolt144': bolt(559, 573, 0.8, True, None),
    'bolt216': bolt(561, 576, 0.7, False, (1, -1, 1.4, 0.3)),
    'bolt288': bolt(553, 564, 0.75, True, (1, 1, 1.6, 0.4)),
    # two outer cells
    'cloudS': cloud(579, 581, (201, 209.5, 218, 226.5, 235), {1: (1.5, 0), 3: (1.5, 0)}),
    'cloudW': cloud(583, 585, (271, 280, 289, 298, 307), {3: (1.55, 1)}),
    # open side
    'outbolt5': out_bolt(567, 5, 1),
    'outbolt140': out_bolt(573, 140, -1),
}
CELLS[932] = thunder

# ---------------------------------------------------------------- 933 Darkness, the Moon -----------------------------
TIPR, TIPL = road(590), road(591)
moon = {}
# terminator curves, right flank outer -> inner, bowing towards the right tip more and more; left flank mirrored
for k, (u, v, bow) in enumerate(((592, 611, 0.05), (594, 613, 0.08), (597, 615, 0.085))):
    kinds = ('small', 'small', 'notable', 'small', 'small')
    moon[f'phaseR{k}'] = bowed(u, v, bow, (0.0, -95.7), 5, kinds)
for k, (u, v, bow) in enumerate(((602, 618, 0.05), (604, 620, 0.08), (607, 622, 0.085))):
    kinds = ('small', 'small', 'notable', 'small', 'small')
    moon[f'phaseL{k}'] = bowed(u, v, bow, (0.0, -95.7), 5, kinds)

# the full moon in the hollow: ring of 8 round H on a stem from 617, two arcs from 611/618 round H, a halo 613 -> 620
H = (0.0, -106.9)
full = {f'm{i}': (Q(H, 2.5, a), 'notable' if a in (90, 270) else 'small') for i, a in enumerate(range(0, 360, 45))}
full['stem'] = ((0.0, -102.8), 'small')
fl = [(617, 'stem', None), ('stem', 'm0', None)] + [(f'm{i}', f'm{(i + 1) % 8}', H) for i in range(8)]
moon['fullmoon'] = (full, fl)
for side, rid in ((1, 611), (-1, 618)):
    r0 = math.dist(H, road(rid))
    a0 = ang(H, road(rid))
    angs = [a0 + side * d for d in (22, 44, 66, 88, 108)]
    nodes = {f'a{i}': (Q(H, r0, a), 'notable' if i in (2, 4) else 'small') for i, a in enumerate(angs)}
    keys = [rid] + list(nodes)
    moon['arcR' if side == 1 else 'arcL'] = (nodes, [(keys[i], keys[i + 1], H) for i in range(len(keys) - 1)])
rh = math.dist(H, road(613))
a1, a2 = ang(H, road(613)), ang(H, road(620)) % 360
steps = 8
halo_angs = [a1 + (a2 - a1) * (i + 1) / (steps + 1) for i in range(steps)]
halo_kinds = ['small', 'small', 'notable', 'small', 'small', 'notable', 'small', 'small']
halo = {f'h{i}': (Q(H, rh, a), k) for i, (a, k) in enumerate(zip(halo_angs, halo_kinds))}
hk = [613] + list(halo) + [620]
moon['halo'] = (halo, [(hk[i], hk[i + 1], H) for i in range(len(hk) - 1)])

# the side circle (road ring 625-636): an eclipse, a ring of 6 held by two stems from opposite road nodes
ids = list(range(625, 637))
E = (sum(road(i)[0] for i in ids) / 12, sum(road(i)[1] for i in ids) / 12)
re = sum(math.dist(E, road(i)) for i in ids) / 12
ua, ub = 627, 633
au, ab = ang(E, road(ua)), ang(E, road(ub))
ecl = {f'e{i}': (Q(E, 2.6, au + 60 * i), 'notable' if i in (1, 4) else 'small') for i in range(6)}
ecl['s0'] = (Q(E, (re + 2.6) / 2, au), 'small')
ecl['s1'] = (Q(E, (re + 2.6) / 2, ab), 'small')
el = [(ua, 's0', None), ('s0', 'e0', None), (ub, 's1', None), ('s1', 'e3', None)] + \
     [(f'e{i}', f'e{(i + 1) % 6}', E) for i in range(6)]
moon['eclipse'] = (ecl, el)
CELLS[933] = moon
