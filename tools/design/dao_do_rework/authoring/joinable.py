"""Lists node pairs that could be joined by hand in one region (2026-11-17 hand authoring): nodes of two different
clusters, or a cluster node and a road node other than its own, 1.0-2.4 apart, the straight link crossing nothing and
passing no node, and the two ends more than three steps apart already. It lists; the author picks which to join.
usage: joinable.py map.json region [ax cx cy]"""
import sys, json, math, collections
M = json.load(open(sys.argv[1], encoding='utf-8')); R = sys.argv[2]
ax = float(sys.argv[3]) if len(sys.argv) > 3 else 0.0
cx, cy = (float(sys.argv[4]), float(sys.argv[5])) if len(sys.argv) > 5 else (0.0, 0.0)
t = math.radians(ax)
loc = lambda x, y: ((x - cx) * math.cos(t) - (y - cy) * math.sin(t), (x - cx) * math.sin(t) + (y - cy) * math.cos(t))
N = {n['id']: n for n in M['nodes']}; P = {i: (n['x'], n['y']) for i, n in N.items()}
adj = collections.defaultdict(set)
for e in M['edges']:
    adj[e['a']].add(e['b']); adj[e['b']].add(e['a'])
grp = {}
for k, g in enumerate(M['groups']):
    for i in g['nodes']:
        grp[i] = k
name = lambda i: (M['groups'][grp[i]].get('combo', '').split(' ', 2)[-1] + ':' if M['groups'][grp[i]].get('combo') else '') + M['groups'][grp[i]]['shape'] if i in grp else 'road'
skip = lambda i: i in grp and (M['groups'][grp[i]]['shape'].startswith('start') or M['groups'][grp[i]]['shape'] == 'keystone')
segs = [(P[e['a']], P[e['b']], e['a'], e['b']) for e in M['edges']]
o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])


def clear(a, b):
    pa, pb = P[a], P[b]
    for p, q, x, y in segs:
        if {x, y} & {a, b}: continue
        if max(p[0], q[0]) < min(pa[0], pb[0]) - 0.1 or min(p[0], q[0]) > max(pa[0], pb[0]) + 0.1: continue
        if o(pa, pb, p) * o(pa, pb, q) < 0 and o(p, q, pa) * o(p, q, pb) < 0: return False
    dx, dy = pb[0] - pa[0], pb[1] - pa[1]; L2 = dx * dx + dy * dy
    for i, r in P.items():
        if i in (a, b): continue
        if abs(r[0] - pa[0]) > 3 and abs(r[0] - pb[0]) > 3: continue
        tt = ((r[0] - pa[0]) * dx + (r[1] - pa[1]) * dy) / L2
        if 0 < tt < 1 and math.dist(r, (pa[0] + tt * dx, pa[1] + tt * dy)) < 0.4: return False
    return True


def hops(a, b, lim=3):
    seen = {a: 0}; q = [a]
    for u in q:
        if seen[u] >= lim: continue
        for w in adj[u]:
            if w not in seen:
                seen[w] = seen[u] + 1; q.append(w)
    return seen.get(b, 99)


mine = [i for i, n in N.items() if n.get('region') == R and n['kind'] in ('small', 'notable', 'travel') and not skip(i)]
rows = []
for a in mine:
    for b in mine:
        if b <= a or b in adj[a]: continue
        if a not in grp and b not in grp: continue
        if a in grp and b in grp and grp[a] == grp[b]: continue
        d = math.dist(P[a], P[b])
        if not 1.0 <= d <= 2.4: continue
        if hops(a, b) <= 3 or not clear(a, b): continue
        rows.append((d, a, b))
rows.sort()
for d, a, b in rows:
    ua, va = loc(*P[a]); ub, vb = loc(*P[b])
    print('%.2f  [[%.2f, %.2f], [%.2f, %.2f]]  %s %s -- %s %s' % (d, ua, va, ub, vb, N[a]['kind'][0], name(a)[:26], N[b]['kind'][0], name(b)[:26]))
