"""The five elements round the hub, 2026-11-19: each land's first cell (Fire 3, Earth 2, Metal 4, Water 5, Wood 1) takes
its element's motif, woven round the figures already there, traced by Claude from the picture the user picked ("add
beside 1 outside part with the elements is good": design/dao-do/underlays/chaos/beside-1.png; the swirl inside the hub is
chaos_swirl.py). Flames, mountain ridges, blades, wave scrolls, vines and leaves.

The drawn lines are the picture's centre-line network with today's roads and figures masked out
(tools/design/dao_do_rework/underlay/skel2.py -> elem-graph.json). Each junction is a fork, each free end a notable; nodes about 1.7
apart along each stroke. Wood's leaf veins and Metal's blade notches (inner lines ending within 0.35 of another line)
go, so a leaf or blade is its outline. Each separate part of a motif is a piece hanging from the nearest free travel
node of its cell or its walls (within 2.6, by a link crossing nothing; never a land start or a node a swirl arm or another piece
holds); a part with no door near joins its nearest held neighbour, else another loose part, across a gap under 1.8;
a part with none of these is left out.
Normal spacing (rules 3.2): each piece settles against the roads, today's figures (frozen in design/dao-do/underlays/chaos/keepout.json) and
the pieces before it.
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'underlay'))
from celllib import road  # noqa: E402
from trace_lib import circum  # noqa: E402
from trace_fine import Fig, Fine, settle, thin_at, _segs, _cross  # noqa: E402

THEME = 'chaos'
S, N = 'small', 'notable'
UD = os.path.join(HERE, '..', 'underlays', 'chaos')
U = Fine(os.path.join(UD, 'beside-1.png'), 0.0, 0.0, 33.0, road, node_min=0.95, link_min=0.65)   # a margin over the settling's 0.92 / 0.62
U.path((0, 0), (0.1, 0))
GRAPH = json.load(open(os.path.join(UD, 'elem-graph.json'), encoding='utf-8'))
KEEP = json.load(open(os.path.join(UD, 'keepout.json'), encoding='utf-8'))
BASE = json.load(open(os.path.join(HERE, 'base-map.json'), encoding='utf-8'))
# nodes are placed clear of today's figures as of the roads (a motif line drawn hard beside a figure moves off it a
# little instead of being settled away)
U.rnodes += [(None, tuple(p)) for p in KEEP['pts']]
U.rsegs += [(tuple(a2), tuple(b2)) for a2, b2 in KEEP['segs']]
STEP, SPLIT = 1.7, 0.7                 # node spacing along the strokes (user 2026-11-19: "a bit too high", 0.8 -> 1.2; then 30% sparser)
CELLS_AT = {3: 0, 2: 72, 4: 144, 5: 216, 1: 288}       # first cell: its land's axis
DOOR_REACH, GAP = {2: 3.6, 3: 3.6}, {2: 2.8, 3: 2.8}    # Earth's ridges and a flame right of Fire's start lie further out (wider reach)
INNER = (1, 4)                                          # Wood and Metal: veins and notches go
SWIRL_DOORS = {12, 14, 16, 18, 20, 22, 24, 26, 28, 30} | set(range(1, 11))      # ring nodes the swirl holds


def ang(p):
    return math.degrees(math.atan2(p[0], p[1])) % 360


def off(a, b):
    return abs((a - b + 180) % 360 - 180)


def length(pl):
    return sum(math.dist(p, q) for p, q in zip(pl, pl[1:]))


def at(pl, t):
    s = 0.0
    for p, q in zip(pl, pl[1:]):
        d = math.dist(p, q)
        if s + d >= t:
            u = (t - s) / d if d else 0.0
            return (p[0] + (q[0] - p[0]) * u, p[1] + (q[1] - p[1]) * u)
        s += d
    return pl[-1]


def in_cell(p, axis):
    r = math.hypot(*p)
    return 14.9 < r < 31.6 and off(ang(p), axis) < 35.5


TRAVEL = [n['id'] for n in BASE['nodes'] if n['kind'] == 'travel']
used_doors = set(SWIRL_DOORS)


def motif(cell):
    axis = CELLS_AT[cell]
    V = [tuple(v) for v in GRAPH['v']]
    strokes = []
    for s in GRAPH['s']:
        pl = [tuple(p) for p in s['pts']]
        if len(pl) > 2 and in_cell(at(pl, length(pl) / 2), axis):
            strokes.append([s['a'], s['b'], pl])
    deg = lambda v: sum((s[0] == v) + (s[1] == v) for s in strokes)
    for _ in range(10):                                 # junction pairs closer than the split distance are one
        short = [s for s in strokes if length(s[2]) < SPLIT and s[0] != s[1] and deg(s[0]) >= 2 and deg(s[1]) >= 2]
        if not short:
            break
        a, b, _ = short[0]
        V[a] = ((V[a][0] + V[b][0]) / 2, (V[a][1] + V[b][1]) / 2)
        strokes.remove(short[0])
        for s in strokes:
            s[0] = a if s[0] == b else s[0]
            s[1] = a if s[1] == b else s[1]
    strokes = [s for s in strokes if not (length(s[2]) < 0.5 and (deg(s[0]) == 1 or deg(s[1]) == 1))]
    if cell in INNER:
        for _ in range(2):
            drop = set()
            for i, st in enumerate(strokes):
                for end, p in ((st[0], st[2][0]), (st[1], st[2][-1])):
                    if deg(end) != 1 or length(st[2]) > 2.0:
                        continue
                    near = min((math.dist(p, q) for j, t in enumerate(strokes) if j != i and end not in (t[0], t[1])
                                for q in t[2][::2]), default=9)
                    if near < 0.35:
                        drop.add(i)
            if not drop:
                break
            strokes = [st for i, st in enumerate(strokes) if i not in drop]
    F = Fig()

    def vnode(v):
        k = f'v{v}'
        if k not in F.nodes:
            F.nodes[k] = (U.clear(V[v]), S)
        return k
    for a, b, pl in strokes:
        if a == b and length(pl) < 1.0:
            continue
        A, B = vnode(a), vnode(b)
        L = length(pl)
        n = max(0, round(L / STEP) - 1)
        prev, tp = A, 0.0
        for j in range(n):
            t = L * (j + 1) / (n + 1)
            k = f'n_{len(F.nodes)}'
            F.nodes[k] = (U.clear(at(pl, t)), S)
            c = circum(F.nodes[prev][0], at(pl, (tp + t) / 2), F.nodes[k][0])
            F.links.append((prev, k, c if c is not None and math.dist(c, F.nodes[k][0]) < 60 else None))
            prev, tp = k, t
        c = circum(F.nodes[prev][0], at(pl, (tp + L) / 2), F.nodes[B][0])
        F.links.append((prev, B, c if c is not None and math.dist(c, F.nodes[B][0]) < 60 else None))
    # nodes closer than 0.45 that no stroke joins (two junctions the thinning set side by side) are one
    while True:
        ks = list(F.nodes)
        pair = next(((a2, b2) for i, a2 in enumerate(ks) for b2 in ks[i + 1:]
                     if math.dist(F.nodes[a2][0], F.nodes[b2][0]) < 0.45), None)
        if not pair:
            break
        a2, b2 = pair
        F.links = [(a2 if x == b2 else x, a2 if y == b2 else y, c) for x, y, c in F.links]
        F.links = [l for l in F.links if l[0] != l[1]]
        seen_l, keep = set(), []
        for l in F.links:
            key = frozenset(l[:2])
            if key not in seen_l:
                seen_l.add(key); keep.append(l)
        F.links = keep
        del F.nodes[b2]
    return F


def parts(F):
    adj = {}
    for a, b, _ in F.links:
        adj.setdefault(a, set()).add(b); adj.setdefault(b, set()).add(a)
    seen, out = set(), []
    for k in F.nodes:
        if k in seen:
            continue
        comp, stack = {k}, [k]
        while stack:
            u = stack.pop()
            for v in adj.get(u, ()):
                if v not in comp:
                    comp.add(v); stack.append(v)
        seen |= comp
        out.append(comp)
    return out


built = [([p for _, p in U.rnodes], U.rsegs), ([tuple(p) for p in KEEP['pts']], [(tuple(a), tuple(b)) for a, b in KEEP['segs']])]
CELLS = {}
for cell in CELLS_AT:
    F = motif(cell)
    fxy = lambda k: road(k) if isinstance(k, int) else F.nodes[k][0]
    segs_all = lambda: [sg for a, b, c in F.links for sg in _segs(fxy(a), fxy(b), c)]
    obst = [sg for _, ss in built for sg in ss]
    pieces = {}
    axis = CELLS_AT[cell]
    doors = [d for d in TRAVEL if d not in used_doors and 14.3 < math.hypot(*road(d)) < 31.8
             and off(ang(road(d)), axis) < 40]

    def clear_link(P, Q):
        return not any(_cross(P, Q, A, B) for A, B in segs_all() + obst
                       if min(math.dist(A, P), math.dist(B, P), math.dist(A, Q), math.dist(B, Q)) > 1e-6)
    opts = [p for pts, _ in built for p in pts]

    def spaced_door(P, Q):
        """The door's first node keeps 0.92 from other pieces' and roads' nodes (the door itself aside), and the door
        link 0.62 from them: the first node off a door is never settled away, so it must fit as it is."""
        for q in opts:
            if math.dist(q, Q) < 1e-6:
                continue
            if math.dist(P, q) < 0.92:
                return False
            vx, vy = Q[0] - P[0], Q[1] - P[1]; L2 = vx * vx + vy * vy or 1e-9
            t = max(0.0, min(1.0, ((q[0] - P[0]) * vx + (q[1] - P[1]) * vy) / L2))
            if math.dist(q, (P[0] + t * vx, P[1] + t * vy)) < 0.62:
                return False
        return True
    while True:
        comps = [{k for k in c if isinstance(k, str)} for c in parts(F)]
        dooring = {x for a, b, _ in F.links for x in (a, b) if isinstance(a, int) or isinstance(b, int)}
        held = [c for c in comps if c & dooring]
        free = sorted((c for c in comps if not c & dooring), key=lambda c: -len(c))
        if not free:
            break
        done = False
        for comp in free:                              # a door: nearest free road node within 2.6, crossing nothing
            cand = sorted((math.dist(F.nodes[k][0], road(d)), k, d) for k in comp for d in doors if d not in used_doors)
            for dist, k, d in cand:
                if dist > DOOR_REACH.get(cell, 2.6):
                    break
                if clear_link(F.nodes[k][0], road(d)) and spaced_door(F.nodes[k][0], road(d)):
                    F.links.append((d, k, None)); used_doors.add(d); done = True
                    break
            if done:
                break
        if done:
            continue
        for pool in ([x for c in held for x in c], None):   # join a loose part to a held one, else to another loose one
            best = None
            for comp in free:
                others = pool if pool is not None else [x for c in free if c is not comp for x in c]
                for g, a2, b2 in sorted((math.dist(F.nodes[a2][0], F.nodes[b2][0]), a2, b2) for a2 in comp for b2 in others):
                    if g > GAP.get(cell, 1.8):
                        break
                    if clear_link(F.nodes[a2][0], F.nodes[b2][0]):
                        if best is None or g < best[0]:
                            best = (g, a2, b2)
                        break
            if best:
                F.links.append((best[1], best[2], None)); done = True
                break
        if done:
            continue
        for comp in free:
            print(f'elements {cell}: part of {len(comp)} nodes left out (no door or neighbour near)', file=sys.stderr)
            for k in comp:
                del F.nodes[k]
            F.links = [l for l in F.links if l[0] not in comp and l[1] not in comp]
        break
    # each held part is its own piece
    for comp in sorted(parts(F), key=lambda c: -len(c)):
        P = Fig()
        P.nodes = {k: v for k, v in F.nodes.items() if k in comp}       # in the trace's own order (a set's order varies by run)
        P.links = [l for l in F.links if l[0] in comp or l[1] in comp]
        if not P.nodes:
            continue
        adj = {}
        for a, b, _ in P.links:
            adj.setdefault(a, set()).add(b); adj.setdefault(b, set()).add(a)
        for k, (p, _) in P.nodes.items():
            P.nodes[k] = (p, N if len(adj.get(k, ())) == 1 else S)
        thin_at(P, road, SPLIT, 0.45)
        protect = {k for a, b, _ in P.links for k in (a, b) if isinstance(k, str) and (isinstance(a, int) or isinstance(b, int))}
        n0 = len(P.nodes)
        dr = settle(P, road, SPLIT + 0.02, 0.47, 0.92, 0.62, others=built, protect=protect, cap=n0 // 2, max_chord=2.7)   # a hair over 3.2's minima
        # a last fine check (arcs sampled finely): a node on a line still within 0.47 of one of its piece's links goes
        fxy2 = lambda k: road(k) if isinstance(k, int) else P.nodes[k][0]
        def fine_segs(a2, b2, c2):
            A, B = fxy2(a2), fxy2(b2)
            if not c2:
                return [(A, B)]
            r = math.dist(A, c2); t1 = math.atan2(A[1] - c2[1], A[0] - c2[0]); t2 = math.atan2(B[1] - c2[1], B[0] - c2[0])
            dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
            pl = [(c2[0] + r * math.cos(t1 + dt * i / 64), c2[1] + r * math.sin(t1 + dt * i / 64)) for i in range(65)]
            return list(zip(pl, pl[1:]))
        def dseg(q, A, B):
            vx, vy = B[0] - A[0], B[1] - A[1]; L2 = vx * vx + vy * vy or 1e-9
            t = max(0.0, min(1.0, ((q[0] - A[0]) * vx + (q[1] - A[1]) * vy) / L2))
            return math.dist(q, (A[0] + t * vx, A[1] + t * vy))
        for _ in range(20):
            adj = {}
            for a2, b2, _c in P.links:
                adj.setdefault(a2, set()).add(b2); adj.setdefault(b2, set()).add(a2)
            hit = next((k for k, (q, kd) in P.nodes.items() if len(adj.get(k, ())) == 2 and k not in protect
                        and all(isinstance(x, str) for x in adj[k])
                        and any(k not in (a2, b2) and min(dseg(q, A, B) for A, B in fine_segs(a2, b2, c2)) < 0.47
                                for a2, b2, c2 in P.links)), None)
            if not hit:
                # a fork too near one of its piece's links: pushed straight off it, to 0.48
                for k, (q, kd) in list(P.nodes.items()):
                    if len(adj.get(k, ())) < 3 or k in protect:
                        continue
                    for a2, b2, c2 in P.links:
                        if k in (a2, b2):
                            continue
                        for A, B in fine_segs(a2, b2, c2):
                            d0 = dseg(q, A, B)
                            if d0 < 0.47:
                                vx, vy = B[0] - A[0], B[1] - A[1]; L2 = vx * vx + vy * vy or 1e-9
                                t = max(0.0, min(1.0, ((q[0] - A[0]) * vx + (q[1] - A[1]) * vy) / L2))
                                F0 = (A[0] + t * vx, A[1] + t * vy)
                                f = (0.48 - d0) / max(d0, 1e-6)
                                q = (q[0] + (q[0] - F0[0]) * f, q[1] + (q[1] - F0[1]) * f)
                                P.nodes[k] = (q, kd)
                break
            u, v = sorted(adj[hit], key=str)
            del P.nodes[hit]
            P.links = [l for l in P.links if hit not in l[:2]] + [(u, v, None)]
        adj = {}
        for a, b, _ in P.links:
            adj.setdefault(a, set()).add(b); adj.setdefault(b, set()).add(a)
        for k, (p, _) in P.nodes.items():
            P.nodes[k] = (p, N if len(adj.get(k, ())) == 1 else S)
        # a loop hung at one point (a leaf, a blade) lies on no route unless it carries a notable (rule R2): each loop
        # without one gets one, at its node furthest from the door
        door = next((x for a2, b2, _ in P.links for x in (a2, b2) if isinstance(x, int)), None)
        depth, par, order = {door: 0}, {door: None}, [door]
        for u in order:
            for v in sorted(adj.get(u, ()), key=str):
                if v not in depth:
                    depth[v] = depth[u] + 1; par[v] = u; order.append(v)
        for a2, b2, _ in P.links:
            if par.get(a2) == b2 or par.get(b2) == a2:
                continue
            pa, pb = [a2], [b2]
            while pa[-1] is not None:
                pa.append(par.get(pa[-1]))
            while pb[-1] is not None:
                pb.append(par.get(pb[-1]))
            common = next((x for x in pa if x in set(pb)), None)
            loop = pa[:pa.index(common) + 1] + pb[:pb.index(common)]
            loop = [x for x in loop if isinstance(x, str)]
            if loop and not any(P.nodes[x][1] == N for x in loop):
                k = max(loop, key=lambda x: depth.get(x, 0))
                P.nodes[k] = (P.nodes[k][0], N)
        # rule R3: two smalls between the door and the first notable; where the door link is long enough, a small
        # node in it makes room
        for _ in range(3):
            adj = {}
            for a2, b2, _c in P.links:
                adj.setdefault(a2, set()).add(b2); adj.setdefault(b2, set()).add(a2)
            door_l = next((l for l in P.links if isinstance(l[0], int) or isinstance(l[1], int)), None)
            if not door_l:
                break
            dr_, first = (door_l[0], door_l[1]) if isinstance(door_l[0], int) else (door_l[1], door_l[0])
            depth, order = {dr_: 0}, [dr_]
            for u in order:
                for v in adj.get(u, ()):
                    if v not in depth:
                        depth[v] = depth[u] + 1; order.append(v)
            if min((depth[k] for k, (_, kd) in P.nodes.items() if kd == N and k in depth), default=9) >= 3:
                break
            A, B2 = road(dr_), P.nodes[first][0]
            M2 = ((A[0] + B2[0]) / 2, (A[1] + B2[1]) / 2)
            if math.dist(A, B2) < 1.4 or any(math.dist(M2, q) < 0.92 for q in opts if math.dist(q, A) > 1e-6) or                     any(math.dist(M2, q) < 0.7 for k2, (q, _) in P.nodes.items()):
                break
            k = f'd_{len(P.nodes)}'
            P.nodes[k] = (((A[0] + B2[0]) / 2, (A[1] + B2[1]) / 2), S)
            P.links = [l for l in P.links if l is not door_l] + [(dr_, k, None), (k, first, None)]
        # rule R3 as the checker reads it: from the first fork past the door, two steps to the nearest notable; a
        # one-node spur ending in a notable beside that fork goes
        for _ in range(6):
            adj = {}
            for a2, b2, _c in P.links:
                adj.setdefault(a2, set()).add(b2); adj.setdefault(b2, set()).add(a2)
            ports = [x for x in P.nodes if any(isinstance(y, int) for y in adj.get(x, ()))]
            if len(ports) != 1:
                break
            prev, cur = None, ports[0]
            while P.nodes[cur][1] != N:
                nxt = [v for v in adj[cur] if isinstance(v, str) and v != prev]
                if len(nxt) != 1:
                    break
                prev, cur = cur, nxt[0]
            if P.nodes[cur][1] == N:
                break
            spurs = [v for v in adj[cur] if isinstance(v, str) and v != prev and P.nodes[v][1] == N and len(adj[v]) == 1]
            if not spurs:
                break
            for v in spurs:
                del P.nodes[v]
                P.links = [l for l in P.links if v not in l[:2]]
        if len(P.nodes) < 5:                            # a remnant the settling left: not worth a piece
            print(f'elements {cell}: remnant of {len(P.nodes)} nodes left out', file=sys.stderr)
            continue
        if not any(kd == N for _, kd in P.nodes.values()):
            k = max(P.nodes, key=lambda k: math.dist(P.nodes[k][0], (0, 0)))
            P.nodes[k] = (P.nodes[k][0], N)
        xy = lambda k: road(k) if isinstance(k, int) else P.nodes[k][0]
        built.append(([p for p, _ in P.nodes.values()], [sg for a, b, c in P.links for sg in _segs(xy(a), xy(b), c)]))
        name = {3: 'flames', 2: 'ridges', 4: 'blades', 5: 'waves', 1: 'vines'}[cell]
        pieces[f'{name}_{len(pieces) + 1}'] = (P.nodes, P.links)
        print(f'elements {cell}: {name}_{len(pieces)} {n0} nodes, settling dropped {dr}', file=sys.stderr)
    CELLS[cell] = pieces
