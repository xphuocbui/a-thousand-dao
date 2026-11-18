"""Independent geometry audit of a generated map: crossings (arcs sampled), close pairs, nodes on links, degree 0,
reachability from the Chaos start. usage: audit.py map.json [--list]"""
import sys, json, math, collections
M = json.load(open(sys.argv[1], encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
P = {i: (n['x'], n['y']) for i, n in N.items()}
adj = collections.defaultdict(set)
for e in M['edges']:
    adj[e['a']].add(e['b']); adj[e['b']].add(e['a'])


def poly(e):
    a, b = P[e['a']], P[e['b']]
    c = e.get('arc')
    if not c or (abs(c[0]) < 1e-9 and abs(c[1]) < 1e-9 and False):
        return [a, b]
    if not c:
        return [a, b]
    r = math.dist(a, c)
    t1 = math.atan2(a[1] - c[1], a[0] - c[0]); t2 = math.atan2(b[1] - c[1], b[0] - c[0])
    dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    n = max(2, int(abs(dt) * r / 0.3))
    return [(c[0] + r * math.cos(t1 + dt * k / n), c[1] + r * math.sin(t1 + dt * k / n)) for k in range(n + 1)]


segs = []      # (p, q, edge index)
for k, e in enumerate(M['edges']):
    pl = poly(e)
    for p, q in zip(pl, pl[1:]):
        segs.append((p, q, k))
grid = collections.defaultdict(list)
for s_i, (p, q, k) in enumerate(segs):
    x0, x1 = sorted((p[0], q[0])); y0, y1 = sorted((p[1], q[1]))
    for gx in range(int(math.floor(x0)), int(math.floor(x1)) + 1):
        for gy in range(int(math.floor(y0)), int(math.floor(y1)) + 1):
            grid[(gx, gy)].append(s_i)
o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
cross = set()
for cell, ids in grid.items():
    for i in range(len(ids)):
        p1, p2, k1 = segs[ids[i]]
        e1 = M['edges'][k1]
        for j in range(i + 1, len(ids)):
            p3, p4, k2 = segs[ids[j]]
            if k1 == k2:
                continue
            e2 = M['edges'][k2]
            if {e1['a'], e1['b']} & {e2['a'], e2['b']}:
                continue
            if o(p1, p2, p3) * o(p1, p2, p4) < -1e-12 and o(p3, p4, p1) * o(p3, p4, p2) < -1e-12:
                cross.add(tuple(sorted((k1, k2))))
ngrid = collections.defaultdict(list)
for i, p in P.items():
    ngrid[(int(math.floor(p[0])), int(math.floor(p[1])))].append(i)
close = []
for i, p in P.items():
    gx, gy = int(math.floor(p[0])), int(math.floor(p[1]))
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            for j in ngrid.get((gx + dx, gy + dy), ()):
                if j > i and math.dist(p, P[j]) < 0.72:
                    close.append((i, j, round(math.dist(p, P[j]), 2)))
onlink = []
for i, p in P.items():
    gx, gy = int(math.floor(p[0])), int(math.floor(p[1]))
    seen = set()
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            for s_i in grid.get((gx + dx, gy + dy), ()):
                if s_i in seen:
                    continue
                seen.add(s_i)
                a, b, k = segs[s_i]
                e = M['edges'][k]
                if i in (e['a'], e['b']):
                    continue
                vx, vy = b[0] - a[0], b[1] - a[1]; L = vx * vx + vy * vy
                t = max(0.0, min(1.0, ((p[0] - a[0]) * vx + (p[1] - a[1]) * vy) / L)) if L else 0.0
                if math.dist(p, (a[0] + t * vx, a[1] + t * vy)) < 0.3:
                    onlink.append((i, k))
deg0 = [i for i in P if not adj[i]]
s = next(n['id'] for n in M['nodes'] if n['kind'] == 'start' and n.get('region') == 'hub')
seen = {s}; q = [s]
for u in q:
    for v in adj[u]:
        if v not in seen:
            seen.add(v); q.append(v)
print(f"crossings {len(cross)}  close pairs {len(close)}  node on a link {len(set(i for i, _ in onlink))}  degree 0 {len(deg0)}  reachable {len(seen)}/{len(P)}")
if '--list' in sys.argv:
    ph = lambda k: M['edges'][k].get('ph')
    print('crossings by phase', collections.Counter(tuple(sorted((str(ph(a)), str(ph(b))))) for a, b in cross).most_common(12))
    print('close by kinds', collections.Counter(tuple(sorted((N[a]['kind'], N[b]['kind']))) for a, b, _ in close).most_common(8))
    print('on-link by phase', collections.Counter(str(ph(k)) for _, k in onlink).most_common(8))
    for a, b in list(cross)[:8]:
        ea, eb = M['edges'][a], M['edges'][b]
        print('  x', ph(a), ph(b), [round(c, 1) for c in P[ea['a']]], [round(c, 1) for c in P[eb['a']]])
    for a, b, d in close[:8]:
        print('  close', N[a]['kind'], N[b]['kind'], d, [round(c, 1) for c in P[a]])
if '--onlink' in sys.argv:
    import random
    rng = random.Random(1)
    for i, k in rng.sample(onlink, 12):
        e = M['edges'][k]
        print('  node', N[i]['kind'], N[i].get('cluster'), [round(c, 2) for c in P[i]], '| edge', e.get('ph'), N[e['a']]['kind'], N[e['b']]['kind'], 'arc' if e.get('arc') else 'line',
              [round(c, 2) for c in P[e['a']]], [round(c, 2) for c in P[e['b']]], 'nbrs of node:', sorted(adj[i])[:4], 'edge ends', e['a'], e['b'])
