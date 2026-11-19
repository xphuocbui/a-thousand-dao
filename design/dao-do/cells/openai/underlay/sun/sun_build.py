"""Traces the Sun underlay (inout-3.png) into pieces (measurement and assembly; the rules applied are listed in
design/dao-do/cells/sun_trace.py). usage: python -I sun_build.py <skel.json> <out.json>
Steps: skeleton strokes -> graph (junction clusters merged, bead spurs pruned, degree-2 joints merged); right half only
(x > 0.3, mirrored later); each component's ends: within 1.3 of a road node -> linked to it, else a tip (notable),
trimmed back clear of the roads; components with no road join the nearest node of an attached component (twin flames,
small suns on branches); nodes re-spaced evenly (about 1.15) along every stroke, arcs through the stroke's midpoints."""
import json, math, sys
from collections import defaultdict
strokes = json.load(open(sys.argv[1]))
B = json.load(open('../../../base-map.json', encoding='utf-8'))
Nn = {n['id']: n for n in B['nodes']}
C0 = (0.0, 112.0)
roads = {n['id']: (n['x'], n['y']) for n in B['nodes'] if n['kind'] == 'travel' and math.dist((n['x'], n['y']), C0) < 22}
rsegs = []
for e in B['edges']:
    if e['a'] in roads or e['b'] in roads:
        a, b = (Nn[e['a']]['x'], Nn[e['a']]['y']), (Nn[e['b']]['x'], Nn[e['b']]['y']); c = e.get('arc')
        if c:
            r = math.dist(a, c); t1 = math.atan2(a[1]-c[1], a[0]-c[0]); t2 = math.atan2(b[1]-c[1], b[0]-c[0])
            dt = (t2 - t1 + math.pi) % (2*math.pi) - math.pi
            pl = [(c[0]+r*math.cos(t1+dt*i/40), c[1]+r*math.sin(t1+dt*i/40)) for i in range(41)]
        else:
            pl = [a, b]
        rsegs += list(zip(pl, pl[1:]))
fixedn = [(n['x'], n['y']) for n in B['nodes'] if n['kind'] != 'travel' and math.dist((n['x'], n['y']), C0) < 22] + [(2.7, 94.0), (-2.7, 94.0)]


def segd(p, a, b):
    vx, vy = b[0]-a[0], b[1]-a[1]; L = vx*vx+vy*vy
    t = max(0, min(1, ((p[0]-a[0])*vx+(p[1]-a[1])*vy)/L)) if L else 0
    return math.dist(p, (a[0]+t*vx, a[1]+t*vy))


def road_clear(p):
    return min(min(segd(p, a, b) for a, b in rsegs), min(math.dist(p, f) for f in fixedn) - 0.3)


plen = lambda s: sum(math.dist(a, b) for a, b in zip(s, s[1:]))
# --- graph: vertices = stroke ends snapped together (0.09 units = 2 px) ---
V, VG = [], defaultdict(list)
def vid(p):
    gx, gy = int(p[0] // 0.1), int(p[1] // 0.1)
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            for i in VG[(gx + dx, gy + dy)]:
                if math.dist(p, V[i]) < 0.09:
                    return i
    V.append(p); VG[(gx, gy)].append(len(V) - 1); return len(V) - 1
E = []
for s in strokes:
    if len(s) < 2: continue
    a, b = vid(tuple(s[0])), vid(tuple(s[-1]))
    if a != b or plen(s) > 0.5:
        E.append([a, b, [tuple(p) for p in s]])
def adj():
    A = defaultdict(list)
    for i, (a, b, _) in enumerate(E):
        A[a].append(i); A[b].append(i)
    return A
# prune spurs and merge degree-2 joints, repeatedly
for _ in range(30):
    A = adj(); changed = False
    for v, es in list(A.items()):
        if len(es) == 1:
            i = es[0]; a, b, pl = E[i]
            other = b if a == v else a
            if plen(pl) < 0.45 and len(A[other]) >= 3:
                E[i] = None; changed = True
    E = [e for e in E if e]
    A = adj()
    for v, es in list(A.items()):
        if len(es) == 2 and es[0] != es[1] and E[es[0]] and E[es[1]]:
            e1, e2 = E[es[0]], E[es[1]]
            p1 = e1[2] if e1[1] == v else e1[2][::-1]
            p2 = e2[2] if e2[0] == v else e2[2][::-1]
            u = e1[0] if e1[1] == v else e1[1]; w = e2[1] if e2[0] == v else e2[0]
            E[es[0]] = [u, w, p1 + p2[1:]]; E[es[1]] = None; changed = True
            break
    E = [e for e in E if e]
    if not changed: break
E = [e for e in E if plen(e[2]) > 0.3]
# bridge the gaps beads leave: join two line ends closer than 0.55 whose lines continue each other
def end_dir(v):
    A = adj()
    if len(A[v]) != 1: return None
    a, b, pl = E[A[v][0]]
    pl = pl if a == v else pl[::-1]
    q = pl[min(len(pl) - 1, 6)]
    d = (pl[0][0] - q[0], pl[0][1] - q[1]); L = math.hypot(*d) or 1
    return (d[0] / L, d[1] / L)
for _ in range(3):
    A = adj()
    ends = [v for v in A if len(A[v]) == 1]
    used = set()
    pairs = []
    for i, u in enumerate(ends):
        for w in ends[i + 1:]:
            d = math.dist(V[u], V[w])
            if d < 0.55:
                du, dw = end_dir(u), end_dir(w)
                g = ((V[w][0] - V[u][0]) / (d or 1), (V[w][1] - V[u][1]) / (d or 1))
                score = (du[0] * g[0] + du[1] * g[1]) - (dw[0] * g[0] + dw[1] * g[1]) if du and dw else 0
                if score > 0.6:
                    pairs.append((d, u, w))
    for d, u, w in sorted(pairs):
        if u in used or w in used: continue
        used |= {u, w}
        E.append([u, w, [V[u], V[w]]])
    # merge the new degree-2 joints
    for _ in range(400):
        A = adj(); done = True
        for v, es in A.items():
            if len(es) == 2 and es[0] != es[1]:
                e1, e2 = E[es[0]], E[es[1]]
                p1 = e1[2] if e1[1] == v else e1[2][::-1]
                p2 = e2[2] if e2[0] == v else e2[2][::-1]
                u2 = e1[0] if e1[1] == v else e1[1]; w2 = e2[1] if e2[0] == v else e2[0]
                E[es[0]] = [u2, w2, p1 + p2[1:]]; E[es[1]] = None
                E[:] = [e for e in E if e]; done = False
                break
        if done: break
# keep the right half (x > 0.3) and the strokes on the axis
E = [e for e in E if sum(p[0] for p in e[2]) / len(e[2]) > 0.3]
# components
A = adj(); comp = {}
for v in A:
    if v in comp: continue
    st = [v]; comp[v] = v
    while st:
        u = st.pop()
        for i in A[u]:
            for w in E[i][:2]:
                if w not in comp: comp[w] = v; st.append(w)
groups = defaultdict(list)
for i, e in enumerate(E):
    groups[comp[e[0]]].append(i)
print(len(E), 'strokes in', len(groups), 'shapes')
json.dump({'V': V, 'E': E, 'groups': list(groups.values())}, open(sys.argv[2], 'w'))
