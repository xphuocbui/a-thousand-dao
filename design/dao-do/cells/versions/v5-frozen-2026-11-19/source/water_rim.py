"""Water's rim (cell 904), more big clusters, drawn by hand by Claude 2026-11-19 (user: "the outer ring at the water
lands need a few more big clusters (ice flakes + ice cones + waves + water drops + more creative shapes)").

The rim beyond Water's outer ring (r 74.3) held only the armillaries, the bagua and the lotus (lands/water.py), with
the wide wedge between the 216-degree road and Thunder empty. Four big clusters fill it, each hung from a free road
node (the ring nodes beside them hold the land's own figures on their inner side):
  - ice flake (hexagonal snow crystal): six arms, each with a crystal twig and a notable tip, on a stalk from ring
    node 1815;
  - plate flake (second pass, replacing the icicles; user: "The icicle looks weird man, remove it, maybe just do more
    snowflakes pattern, but a different snowflake"): a hexagonal plate with six fern-like arms, on a stalk from ring
    node 1806, between the 206- and 216-degree roads;
  - great wave (second pass; user: "the wave looks weird too, please redesign it, make it have like an asian painting
    wave vibe"): from road node 1321 a body sweeping into a great crest that curls back into an eye, clawed fingers
    of foam from its lip and a smaller wave curling behind;
  - water drops: a teardrop on a stem from road node 677 (on the 206-degree road), a smaller drop falling from it
    and a last droplet, near the rim's outer arc.
Positions are polar (r, degrees from the Fire axis, the map's convention); arcs pass through a point on the drawn line.
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'underlay'))
from celllib import road  # noqa: E402
from trace_lib import circum  # noqa: E402

THEME = 'water'
S, N = 'small', 'notable'


def P(r, a):
    t = math.radians(a)
    return (r * math.sin(t), r * math.cos(t))


def ice_flake():
    """Six arms round a centre at (83, 225); the arm pointing at ring node 1815 is the stalk's end."""
    C = P(83.0, 225.0)
    door = road(1815)
    a0 = math.degrees(math.atan2(door[0] - C[0], door[1] - C[1]))
    nodes, links = {'c': (C, N)}, []
    loc = lambda ang, f, s: (C[0] + f * math.sin(math.radians(ang)) + s * math.cos(math.radians(ang)),
                             C[1] + f * math.cos(math.radians(ang)) - s * math.sin(math.radians(ang)))
    for k in range(6):
        ang = a0 + 60 * k
        a1, a2, tl, tr, T = f'a1_{k}', f'a2_{k}', f'tl_{k}', f'tr_{k}', f'T_{k}'
        nodes[a1] = (loc(ang, 1.05, 0.0), S)
        nodes[a2] = (loc(ang, 2.05, 0.0), S)
        nodes[tl] = (loc(ang, 2.75, 0.8), S)
        nodes[tr] = (loc(ang, 2.75, -0.8), S)
        nodes[T] = (loc(ang, 3.25, 0.0), N if k else S)
        links += [('c', a1, None), (a1, a2, None), (a2, tl, None), (a2, tr, None), (tl, T, None), (tr, T, None)]
    # the stalk: from the stalk arm's tip to the ring node, evenly
    T0 = nodes['T_0'][0]
    L = math.dist(T0, door)
    n = max(2, round(L / 1.4) - 1)
    prev = 'T_0'
    for j in range(n):
        u = 1 - (j + 1) / (n + 1)
        nodes[f'st{j}'] = ((door[0] + (T0[0] - door[0]) * u, door[1] + (T0[1] - door[1]) * u), S)
        links.append((prev, f'st{j}', None))
        prev = f'st{j}'
    links.append((prev, 1815, None))
    return nodes, links


def spline(pts, n=24):
    """A smooth curve through points (Catmull-Rom), n samples per span."""
    out = []
    ext = [pts[0]] + pts + [pts[-1]]
    for i in range(1, len(ext) - 2):
        p0, p1, p2, p3 = ext[i - 1], ext[i], ext[i + 1], ext[i + 2]
        for k in range(n):
            t = k / n
            out.append(tuple(0.5 * (2 * p1[j] + (-p0[j] + p2[j]) * t + (2 * p0[j] - 5 * p1[j] + 4 * p2[j] - p3[j]) * t * t +
                                    (-p0[j] + 3 * p1[j] - 3 * p2[j] + p3[j]) * t * t * t) for j in (0, 1)))
    out.append(pts[-1])
    return out


def smooth_chain(nodes, links, start, way, step, pre, end_kind=N, keep=()):
    """Nodes about `step` apart along a smooth curve from `start` (a node key or road id) through the polar
    waypoints `way`; waypoint indices in `keep` become fixed nodes (forks), named pre + 'k<i>'. Links are arcs
    through the curve. Returns {waypoint index: key} of the kept ones and the key of the end."""
    xy0 = road(start) if isinstance(start, int) else nodes[start][0]
    wpts = [P(r, a) for r, a in way]
    curve = spline([xy0] + wpts)
    # where each waypoint falls on the curve (curve samples: 24 per span)
    marks = {i: 24 * (i + 1) for i in range(len(way))}
    cum = [0.0]
    for p, q in zip(curve, curve[1:]):
        cum.append(cum[-1] + math.dist(p, q))
    fixed = [0] + [marks[i] for i in sorted(keep)] + [len(curve) - 1]
    keys = {0: start}
    kept = {}
    for i in sorted(keep):
        keys[marks[i]] = f'{pre}k{i}'
        nodes[keys[marks[i]]] = (curve[marks[i]], S)
        kept[i] = keys[marks[i]]
    keys[len(curve) - 1] = f'{pre}end'
    nodes[f'{pre}end'] = (curve[-1], end_kind)
    seq = []
    for fa, fb in zip(fixed, fixed[1:]):
        L = cum[fb] - cum[fa]
        n = max(0, round(L / step) - 1)
        idx = [fa] + [min(range(fa, fb + 1), key=lambda j: abs(cum[j] - (cum[fa] + L * (m + 1) / (n + 1)))) for m in range(n)] + [fb]
        for m in range(1, len(idx) - 1):
            keys[idx[m]] = f'{pre}{idx[m]}'
            nodes[keys[idx[m]]] = (curve[idx[m]], S)
        seq += idx if not seq else idx[1:]
    for u, v in zip(seq, seq[1:]):
        A, B = curve[u], curve[v]
        c = circum(A, curve[(u + v) // 2], B) if v - u > 1 else None
        links.append((keys[u], keys[v], c if c is not None and math.dist(c, A) < 60 else None))
    return kept, f'{pre}end'


def plate_flake(r=84.0, a=210.5, door_id=1806):
    """A different snowflake (user: "maybe just do more snowflakes pattern, but a different snowflake"): a hexagonal
    plate round a notable centre at (84, 210.5), six arms, each with a fern-like diamond of side spurs and a notable
    tip; on a stalk from ring node 1806. In the icicles' place, between the 206- and 216-degree roads."""
    C = P(r, a)
    door = road(door_id)
    a0 = math.degrees(math.atan2(door[0] - C[0], door[1] - C[1]))
    loc = lambda ang, f, s: (C[0] + f * math.sin(math.radians(ang)) + s * math.cos(math.radians(ang)),
                             C[1] + f * math.cos(math.radians(ang)) - s * math.sin(math.radians(ang)))
    nodes, links = {'c': (C, N)}, []
    for k in range(6):
        ang = a0 + 60 * k
        nodes[f'h{k}'] = (loc(ang, 0.95, 0.0), S)
        nodes[f'a1_{k}'] = (loc(ang, 1.9, 0.0), S)
        nodes[f'sl_{k}'] = (loc(ang, 2.5, 0.75), S)
        nodes[f'sr_{k}'] = (loc(ang, 2.5, -0.75), S)
        nodes[f'a2_{k}'] = (loc(ang, 3.0, 0.0), S)
        nodes[f'T_{k}'] = (loc(ang, 3.75, 0.0), N if k else S)
        links += [('c', f'h{k}', None), (f'h{k}', f'a1_{k}', None), (f'a1_{k}', f'sl_{k}', None), (f'a1_{k}', f'sr_{k}', None),
                  (f'sl_{k}', f'a2_{k}', None), (f'sr_{k}', f'a2_{k}', None), (f'a2_{k}', f'T_{k}', None)]
    for k in range(6):
        links.append((f'h{k}', f'h{(k + 1) % 6}', C))
    T0 = nodes['T_0'][0]
    L = math.dist(T0, door)
    n = max(2, round(L / 1.4) - 1)
    prev = 'T_0'
    for j in range(n):
        u = 1 - (j + 1) / (n + 1)
        nodes[f'st{j}'] = ((door[0] + (T0[0] - door[0]) * u, door[1] + (T0[1] - door[1]) * u), S)
        links.append((prev, f'st{j}', None))
        prev = f'st{j}'
    links.append((prev, door_id, None))
    return nodes, links


def great_wave():
    """A wave in the manner of an Asian painted wave (user: "make it have like an asian painting wave vibe"): from
    road node 1321 the body sweeps along the rim and rises into a great crest that curls back over into an eye;
    clawed fingers of foam reach from the crest's lip; a smaller wave curls up behind it. Smooth curves, nodes about
    1.6 apart."""
    nodes, links = {}, []
    body = [(91.0, 218.2), (92.6, 220.8), (93.7, 223.6), (95.0, 226.4), (96.9, 229.0), (99.5, 231.0), (102.4, 232.0),
            (104.6, 231.0), (105.6, 228.7), (105.0, 226.2), (103.2, 224.8), (101.3, 225.1), (100.4, 226.9)]
    kept, eye = smooth_chain(nodes, links, 1321, body, 1.6, 'w', keep=(1, 6, 7, 8, 9))
    # claws of foam from the lip (each a short hooked finger)
    claws = {6: [(103.9, 233.9), (104.9, 233.4)], 7: [(106.7, 232.6), (107.4, 231.5)],
             8: [(107.9, 229.4), (108.4, 228.0)], 9: [(107.3, 225.6), (107.2, 224.1)]}
    for i, pts in claws.items():
        smooth_chain(nodes, links, kept[i], pts, 1.3, f'c{i}')
    # a smaller wave curling up behind
    smooth_chain(nodes, links, kept[1], [(94.9, 220.4), (96.4, 221.9), (95.9, 223.5), (94.9, 222.9)], 1.4, 's')
    return nodes, links


def drops():
    """A teardrop on a stem from road node 677, a smaller drop falling from it, a last droplet."""
    nodes, links = {}, []

    def tear(pre, top, r_c, a_c, rad):
        """A teardrop: its point at `top`, its round body a circle of radius `rad` round (r_c, a_c)."""
        Cc = P(r_c, a_c)
        T = P(*top)
        vx, vy = Cc[0] - T[0], Cc[1] - T[1]
        L = math.hypot(vx, vy)
        ux, uy = vx / L, vy / L
        px, py = -uy, ux
        left = (Cc[0] + px * rad, Cc[1] + py * rad)
        right = (Cc[0] - px * rad, Cc[1] - py * rad)
        bottom = (Cc[0] + ux * rad, Cc[1] + uy * rad)
        nodes[f'{pre}t'] = (T, S)
        nodes[f'{pre}l'] = (left, S)
        nodes[f'{pre}r'] = (right, S)
        nodes[f'{pre}b'] = (bottom, N)
        mid = lambda A, B: circum(A, (Cc[0] + (A[0] + B[0] - 2 * Cc[0]) / math.hypot(A[0] + B[0] - 2 * Cc[0], A[1] + B[1] - 2 * Cc[1]) * rad,
                                      Cc[1] + (A[1] + B[1] - 2 * Cc[1]) / math.hypot(A[0] + B[0] - 2 * Cc[0], A[1] + B[1] - 2 * Cc[1]) * rad), B)
        links.extend([(f'{pre}t', f'{pre}l', None), (f'{pre}t', f'{pre}r', None),
                      (f'{pre}l', f'{pre}b', mid(left, bottom)), (f'{pre}r', f'{pre}b', mid(right, bottom))])
    nodes['s1'] = (P(98.4, 207.4), S)
    links += [(677, 's1', None), ('s1', 'Dt', None)]
    tear('D', (99.6, 208.4), 101.7, 209.0, 1.15)
    tear('E', (103.9, 209.8), 105.0, 210.4, 0.8)
    links.append(('Db', 'Et', None))
    nodes['F'] = (P(107.3, 211.2), N)
    links.append(('Eb', 'F', None))
    return nodes, links


CELLS = {904: {
    # 2026-11-19: the user cleared cell 904's new clusters ("cell 904 is really bad please remove it"), then asked for
    # the snowflakes back: the ice flake and the plate flake here, OpenAI's barbed star in oai_water.py
    'ice_flake': ice_flake(),
    'plate_flake': plate_flake(94.0, 222.0, 1321),  # moved: OpenAI's barbed star took its old spot
}}
