"""Build the clean base the user asked for (2026-11-18): keep only the axis shapes and the rings, scrap the rest.

usage: python -I base2.py <rings2-map.json> <out.json> [--no-rings]   (--no-rings: also drop the old rings and start road)

Kept (user's answers): the axis shapes (starts and emblems, with their exit links); the two new rings; the rim ring at
84; the start road (level-0 ring: each blend circle at 37.5 to the neighbouring land start figures); the Chaos hub
(everything inside r 16.5); the axis spines (road links lying along one of the ten axes); the islands outside the rim
and their links to it. Keystones are taken off the map and listed under "keystones" so they can be re-hung later.
Selection is by geometry and graph paths only; nothing is placed.
"""
import collections, heapq, json, math, sys

M = json.load(open(sys.argv[1], encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
R = lambda n: math.hypot(n['x'], n['y'])
TH = lambda n: math.degrees(math.atan2(n['x'], n['y'])) % 360
ROAD = lambda n: n['kind'] in ('travel', 'start')
adj = collections.defaultdict(set)
for e in M['edges']:
    adj[e['a']].add(e['b']); adj[e['b']].add(e['a'])
key = lambda e: frozenset((e['a'], e['b']))
keep = set()
keys = [n for n in M['nodes'] if n['kind'] == 'keystone']
keyset = {n['id'] for n in keys}

NO_RINGS = '--no-rings' in sys.argv          # base3: the rings are redrawn round, so drop the old ones and the start road
# 1. the two new rings (every proposal link)
for e in M['edges']:
    if e.get('proposal') and not NO_RINGS:
        keep.add(key(e))
# 2. the rim ring
for e in M['edges']:
    a, b = N[e['a']], N[e['b']]
    if ROAD(a) and ROAD(b) and abs(R(a) - 84) < 0.6 and abs(R(b) - 84) < 0.6:
        keep.add(key(e))
# 3. the Chaos hub
for e in M['edges']:
    if R(N[e['a']]) < 16.5 and R(N[e['b']]) < 16.5:
        keep.add(key(e))
# 4. the axis spines: road links along an axis (both ends within 0.6 units of the axis line, same side)
def on_axis(n, ax):
    t = math.radians(ax); ux, uy = math.sin(t), math.cos(t)
    along = n['x'] * ux + n['y'] * uy
    return along > -0.5 and abs(-n['x'] * uy + n['y'] * ux) < 0.6
for e in M['edges']:
    a, b = N[e['a']], N[e['b']]
    if {e['a'], e['b']} & keyset:
        continue
    # road-road links along an axis, and the links along it between a road node and a shape (between two emblems)
    if (ROAD(a) or ROAD(b)) and any(on_axis(a, ax) and on_axis(b, ax) for ax in range(0, 360, 36)):
        keep.add(key(e))
# 5. the islands: anything beyond the rim, and its links onto the rim
for e in M['edges']:
    a, b = N[e['a']], N[e['b']]
    if (R(a) > 84.6 or R(b) > 84.6) and not ({e['a'], e['b']} & keyset):
        keep.add(key(e))
# 6. the start road: shortest road path from each blend circle at 37.5 to each neighbouring land's start figure
clus = collections.defaultdict(list)
for n in M['nodes']:
    if n['kind'] in ('small', 'notable') and n.get('cluster') is not None:
        clus[n['cluster']].append(n)
def exits(c):
    return {v for n in clus[c] for v in adj[n['id']] if ROAD(N[v])}
groups = {g['shape'] + '@%.0f,%.0f' % (sum(N[i]['x'] for i in g['nodes']) / len(g['nodes']), sum(N[i]['y'] for i in g['nodes']) / len(g['nodes'])): g for g in M.get('groups', []) if g.get('shape')}
start_cl = {}   # land axis -> cluster of its start figure (r about 28)
circle_cl = {}  # blend axis -> cluster of its circle at 37.5
for g in M.get('groups', []):
    ns = [N[i] for i in g['nodes'] if i in N]
    if not ns:
        continue
    cx = sum(n['x'] for n in ns) / len(ns); cy = sum(n['y'] for n in ns) / len(ns)
    r = math.hypot(cx, cy); t = math.degrees(math.atan2(cx, cy)) % 360
    c = ns[0].get('cluster')
    if g['shape'].startswith('start:') and 25 < r < 31:
        start_cl[round(t / 72) * 72 % 360] = c
    if g['shape'] == 'emblem:circle' and 35 < r < 40:
        circle_cl[round((t - 36) / 72) * 72 % 360 + 36] = c
def road_path(src, dst):
    dist = {s: 0.0 for s in src}; prev = {}; pq = [(0.0, s) for s in src]
    while pq:
        d, u = heapq.heappop(pq)
        if u in dst:
            path = [u]
            while path[-1] in prev:
                path.append(prev[path[-1]])
            return path
        if d > dist.get(u, 1e9):
            continue
        for v in adj[u]:
            if not ROAD(N[v]) or R(N[v]) > 45:
                continue
            nd = d + math.dist((N[u]['x'], N[u]['y']), (N[v]['x'], N[v]['y']))
            if nd < dist.get(v, 1e9):
                dist[v] = nd; prev[v] = u; heapq.heappush(pq, (nd, v))
    return None
startroad = 0
for b, cc in ({} if NO_RINGS else circle_cl).items():
    for land in ((b - 36) % 360, (b + 36) % 360):
        p = road_path(exits(cc), exits(start_cl[land]))
        if p:
            for u, v in zip(p, p[1:]):
                keep.add(frozenset((u, v))); startroad += 1
# 7. the shapes: their own links, and their exit links onto kept roads
kept_road = {i for k in keep for i in k if ROAD(N[i])}
for e in M['edges']:
    a, b = N[e['a']], N[e['b']]
    if {e['a'], e['b']} & keyset:
        continue
    # a start node belongs to its own start figure
    ca = a.get('cluster') if (not ROAD(a) or a['kind'] == 'start') else None
    cb = b.get('cluster') if (not ROAD(b) or b['kind'] == 'start') else None
    if (a['kind'] == 'start' and b['kind'] in ('small', 'notable')) or (b['kind'] == 'start' and a['kind'] in ('small', 'notable')):
        keep.add(key(e))      # a start node and its own figure
    elif ca is not None and cb is not None and ca == cb:
        keep.add(key(e))
    elif (ca is not None and ROAD(b) and e['b'] in kept_road) or (cb is not None and ROAD(a) and e['a'] in kept_road):
        keep.add(key(e))
edges = [e for e in M['edges'] if key(e) in keep]
used = {i for e in edges for i in (e['a'], e['b'])}
nodes = [n for n in M['nodes'] if n['id'] in used]
out = dict(nodes=nodes, edges=edges, groups=[g for g in M.get('groups', []) if g.get('shape') != 'keystone'],
           keystones=[dict(x=n['x'], y=n['y'], region=n.get('region')) for n in keys])
json.dump(out, open(sys.argv[2], 'w', encoding='utf-8'))
k = collections.Counter(n['kind'] for n in nodes)
print('kept %d of %d nodes (%s), %d of %d links; start-road links %d; keystones listed %d; starts found %d, circles found %d' % (
    len(nodes), len(M['nodes']), dict(k), len(edges), len(M['edges']), startroad, len(keys), len(start_cl), len(circle_cl)))
dropped_shapes = {n.get('cluster') for n in M['nodes'] if n['kind'] in ('small', 'notable')} - {n.get('cluster') for n in nodes if n['kind'] in ('small', 'notable')}
print('shapes lost:', dropped_shapes or 'none')
