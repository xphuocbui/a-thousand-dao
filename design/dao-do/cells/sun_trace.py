"""The Sun (931), traced 2026-11-19 from the underlay the user picked: the Fusang 2 sun tree inside the outer ring and
Corona 1's flames outside it (design/dao-do/cells/openai/underlay/sun/inout-3.png; user: "go with recommended").

Flames (outside the outer ring): their centre lines are measured from the picture (openai/underlay/sun/flames.py); the
ring has a road node every 18 degrees and the picture a flame every 9 or so, so each road node carries a twin flame: the
flame nearest it, as drawn, its root joined to the node, and the in-between flame forking from its first node and
joining its own drawn line about 2 out (on the node it leans towards). Nodes re-spaced evenly along each flame, its tip a
notable; arcs through the line's midpoints. Right half traced, mirrored (x -> -x) so the Sun is exactly symmetric.
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
UD = os.path.join(HERE, 'openai', 'underlay', 'sun')
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
from celllib import road, roads  # noqa: E402

THEME = 'island'
C0 = (0.0, 112.0)
S, N = 'small', 'notable'


def circum(a, b, c):
    ax, ay = a; bx, by = b; cx, cy = c
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    if abs(d) < 1e-9:
        return None
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return (ux, uy)


def ang(p):
    return math.degrees(math.atan2(p[0] - C0[0], p[1] - C0[1]))


def rot(p, d):
    t = math.radians(d)
    x, y = p[0] - C0[0], p[1] - C0[1]
    return (C0[0] + x * math.cos(t) + y * math.sin(t), C0[1] - x * math.sin(t) + y * math.cos(t))


def along(pl, step=1.15, first=0.95):
    """Even stations along polyline pl (map points) from its start: the first `first` out, the last at the end."""
    cum = [0.0]
    for p, q in zip(pl, pl[1:]):
        cum.append(cum[-1] + math.dist(p, q))
    L = cum[-1]
    n = max(1, round((L - first) / step) + 1)
    ts = [first + (L - first) * j / (n - 1) for j in range(n)] if n > 1 else [L]
    def at(t):
        i = max(1, min(len(pl) - 1, next((i for i in range(1, len(cum)) if cum[i] >= t), len(cum) - 1)))
        f = (t - cum[i - 1]) / ((cum[i] - cum[i - 1]) or 1)
        return (pl[i - 1][0] + (pl[i][0] - pl[i - 1][0]) * f, pl[i - 1][1] + (pl[i][1] - pl[i - 1][1]) * f)
    return [at(t) for t in ts], ts, at


def chain_piece(start, pl, pre, nodes, links, tip=N, first=0.95):
    """Nodes evenly along pl from road (or node) `start` whose position is pl[0]; the last one `tip`."""
    pts, ts, at = along(pl, first=first)
    keys = [start]
    for i, p in enumerate(pts):
        k = f'{pre}{i}'
        nodes[k] = (p, tip if i == len(pts) - 1 else S)
        keys.append(k)
    tt = [0.0] + ts
    for i in range(len(keys) - 1):
        A = pl[0] if i == 0 else pts[i - 1]
        c = circum(A, at((tt[i] + tt[i + 1]) / 2), pts[i])
        if c is not None and math.dist(c, A) > 60:
            c = None
        links.append((keys[i], keys[i + 1], c))


OUTER = {round(ang(road(i))) % 360: i for i in range(529, 549)}
flames = json.load(open(os.path.join(UD, 'flames-inout3.json')))
right = {}
by_node = {}
NODES = sorted(x for x in OUTER if x <= 162)                     # the right half's ring nodes (0 = the bottom, on the axis)
main_of = {}
for f in flames:                                               # each node's main flame: the one nearest it
    near = min(NODES, key=lambda x: abs(f['ang'] - x))
    if abs(f['ang'] - near) <= 6.5 and (near not in main_of or abs(f['ang'] - near) < abs(main_of[near]['ang'] - near)):
        main_of[near] = f
for f in flames:
    a = f['ang']
    tip = math.degrees(math.atan2(f['line'][-1][0] - C0[0], f['line'][-1][1] - C0[1]))
    lean = 1 if ((tip - a + 180) % 360 - 180) > 0 else -1
    near = min(NODES, key=lambda x: abs(a - x))
    if main_of.get(near) is f:
        by_node.setdefault(near, []).append((0, f))             # a main flame: turned onto its node
    else:                                                      # a twin: rooted at the node it leans towards
        ahead = min((x for x in NODES if (x - a) * lean > 0), key=lambda x: abs(x - a), default=near)
        by_node.setdefault(ahead, []).append((1, f))
for n_ang, fs in sorted(by_node.items()):
    rid = OUTER[n_ang]
    fs = sorted(fs, key=lambda t: t[0])
    nodes, links = {}, []
    if fs[0][0] == 0:
        # the main flame as drawn, its root joined to the node a little out from the ring
        line = [tuple(p) for p in fs[0][1]['line']]
        chain_piece(rid, [road(rid)] + [p for p in line if math.dist(p, C0) > 14.6], 'f', nodes, links)
        root = 'f0'
    else:
        root = rid
    for j, (twin, f) in enumerate(fs[1:] if fs[0][0] == 0 else fs, 1):
        # a twin forks from the main flame's first node, joining its own drawn line about 2 out
        line = [tuple(p) for p in f['line']]
        start = nodes[root][0] if isinstance(root, str) else road(root)
        chain_piece(root, [start] + [p for p in line if math.dist(p, C0) > 15.0], f't{j}_', nodes, links, first=1.35)
    right[f'flames_{n_ang:03d}'] = (nodes, links)

# --- the tree (inside the outer ring): hand-traced, see sun_hand.py
sys.path.insert(0, HERE)
from sun_hand import build as build_tree  # noqa: E402   (hand-traced; sun_tree.py was the automatic attempt)
right.update(build_tree(road))

# mirror: road ids by position
RD = roads()
def mid(i):
    x, y = RD[i]
    j = min(RD, key=lambda k: math.dist(RD[k], (-x, y)))
    assert math.dist(RD[j], (-x, y)) < 0.02, i
    return j
def mirror(pc):
    nodes, links = pc
    mx = lambda p: (-p[0], p[1])
    return ({k: (mx(p), kd) for k, (p, kd) in nodes.items()},
            [(mid(a) if isinstance(a, int) else a, mid(b) if isinstance(b, int) else b, mx(c) if c else None) for a, b, c in links])


sun = {}
for name, pc in right.items():
    if name == 'flames_000':                                   # the bottom node's flame lies on the axis: drawn once
        sun[name] = pc
        continue
    sun[name + '_r'] = pc
    sun[name + '_l'] = mirror(pc)

CELLS = {931: sun}
