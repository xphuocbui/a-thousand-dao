"""Independent geometry audit of a generated map: crossings (arcs sampled), the per-node spacing of
rules-2026-11-18.md 3.2 (other clusters' and roads' nodes 0.9 and links 0.6; own cluster's nodes 0.7 and links 0.45),
degree 0, reachability from the Chaos start. Reports counts only. usage: audit.py map.json [--list] [--onlink]"""
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
# Spacing per node (rules-2026-11-18.md 3.2, user 2026-11-18): gaps from a node to the nodes and links of OTHER
# clusters and roads, and to those of its OWN cluster. A cluster = a connected component of small/notable/jewel nodes
# once roads, starts and keystones are removed (rules section 4); every other node is a cluster of its own. A node
# linked directly to this one, and the links touching it, never count.
OTHER_NODE, OTHER_LINK, OWN_NODE, OWN_LINK = 0.9, 0.6, 0.7, 0.45
# The Sun (cell 931) is traced from a picture drawn finer than that; the user chose looser spacing for it only
# (2026-11-19, rules-2026-11-18.md 3.2): used whenever a Sun node is one of the two ends measured.
SUN_OTHER_NODE, SUN_OTHER_LINK, SUN_OWN_NODE, SUN_OWN_LINK = 0.6, 0.35, 0.5, 0.3
sun = lambda i: (N[i].get('name') or '').startswith(('c931 ', 'c933 shrine_', 'c933 moon_lotus'))   # the Sun, the Shrine and its lotus (user 2026-11-19)
CL_KINDS = {'small', 'notable', 'jewel'}
comp = {}
for s0 in P:
    if s0 in comp:
        continue
    comp[s0] = s0
    if N[s0]['kind'] not in CL_KINDS:
        continue
    q = [s0]
    for u in q:
        for v in adj[u]:
            if v not in comp and N[v]['kind'] in CL_KINDS:
                comp[v] = s0; q.append(v)
ngrid = collections.defaultdict(list)
for i, p in P.items():
    ngrid[(int(math.floor(p[0])), int(math.floor(p[1])))].append(i)
close_other, close_own = [], []     # (i, j, gap)
for i, p in P.items():
    gx, gy = int(math.floor(p[0])), int(math.floor(p[1]))
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            for j in ngrid.get((gx + dx, gy + dy), ()):
                if j <= i or j in adj[i]:
                    continue
                d = math.dist(p, P[j])
                sn = sun(i) or sun(j)
                if comp[i] == comp[j] and d < (SUN_OWN_NODE if sn else OWN_NODE):
                    close_own.append((i, j, round(d, 2)))
                elif comp[i] != comp[j] and d < (SUN_OTHER_NODE if sn else OTHER_NODE):
                    close_other.append((i, j, round(d, 2)))
link_other, link_own = {}, {}       # (i, edge index) -> smallest gap
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
                d = math.dist(p, (a[0] + t * vx, a[1] + t * vy))
                own = comp[i] in (comp[e['a']], comp[e['b']])
                sn = sun(i) or sun(e['a']) or sun(e['b'])
                lim, store = ((SUN_OWN_LINK if sn else OWN_LINK), link_own) if own else ((SUN_OTHER_LINK if sn else OTHER_LINK), link_other)
                if d < lim and d < store.get((i, k), 9):
                    store[(i, k)] = round(d, 2)
deg0 = [i for i in P if not adj[i]]
s = next(n['id'] for n in M['nodes'] if n['kind'] == 'start' and n.get('region') == 'hub')
seen = {s}; q = [s]
for u in q:
    for v in adj[u]:
        if v not in seen:
            seen.add(v); q.append(v)
print(f"crossings {len(cross)}  degree 0 {len(deg0)}  reachable {len(seen)}/{len(P)}")
print(f"spacing (3.2): other node <{OTHER_NODE} {len(close_other)} pairs  other link <{OTHER_LINK} "
      f"{len(set(i for i, _ in link_other))} nodes  own node <{OWN_NODE} {len(close_own)} pairs  own link <{OWN_LINK} "
      f"{len(set(i for i, _ in link_own))} nodes")
if '--list' in sys.argv:
    ph = lambda k: M['edges'][k].get('ph')
    print('crossings by phase', collections.Counter(tuple(sorted((str(ph(a)), str(ph(b))))) for a, b in cross).most_common(12))
    for a, b in list(cross)[:8]:
        ea, eb = M['edges'][a], M['edges'][b]
        print('  x', ph(a), ph(b), [round(c, 1) for c in P[ea['a']]], [round(c, 1) for c in P[eb['a']]])
    for label, pairs in (('other node', close_other), ('own node', close_own)):
        print(label, 'by kinds', collections.Counter(tuple(sorted((N[a]['kind'], N[b]['kind']))) for a, b, _ in pairs).most_common(8))
        for a, b, d in sorted(pairs, key=lambda t: t[2])[:8]:
            print('  ', label, N[a]['kind'], N[b]['kind'], d, [round(c, 1) for c in P[a]])
    for label, store in (('other link', link_other), ('own link', link_own)):
        print(label, 'by phase', collections.Counter(str(ph(k)) for _, k in store).most_common(8))
        for (i, k), d in sorted(store.items(), key=lambda t: t[1])[:8]:
            e = M['edges'][k]
            print('  ', label, N[i]['kind'], d, [round(c, 1) for c in P[i]], '| link', N[e['a']]['kind'], N[e['b']]['kind'])
if '--onlink' in sys.argv:
    import random
    rng = random.Random(1)
    onlink = sorted(set(link_other) | set(link_own))
    for i, k in rng.sample(onlink, min(12, len(onlink))):
        e = M['edges'][k]
        print('  node', N[i]['kind'], N[i].get('cluster'), [round(c, 2) for c in P[i]], '| edge', e.get('ph'), N[e['a']]['kind'], N[e['b']]['kind'], 'arc' if e.get('arc') else 'line',
              [round(c, 2) for c in P[e['a']]], [round(c, 2) for c in P[e['b']]], 'nbrs of node:', sorted(adj[i])[:4], 'edge ends', e['a'], e['b'])
