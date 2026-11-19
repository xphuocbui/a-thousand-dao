"""Splits the ornament of an underlay into connected drawn shapes (roads, start, keystones masked out) and reports,
for each, its size, radius span round the island centre, and which road nodes or ring lines it touches.
Measurement only. usage: python -I comps.py <img> <cx> <cy> <half> <out.json>"""
import json, math, sys
from collections import deque
from PIL import Image
img, cx, cy, half, outp = sys.argv[1], *map(float, sys.argv[2:5]), sys.argv[5]
im = Image.open(img).convert('RGB'); W, H = im.size; px = im.load(); k = 2 * half / W
B = json.load(open('../../../base-map.json', encoding='utf-8'))
Nn = {n['id']: n for n in B['nodes']}
to_px = lambda q: ((q[0] - cx + half) / k, (q[1] - cy + half) / k)
to_map = lambda p: (cx - half + p[0] * k, cy - half + p[1] * k)
near_box = lambda n: abs(n['x'] - cx) < half + 2 and abs(n['y'] - cy) < half + 2
mask_road = set()
for e in B['edges']:
    A, Bb = Nn[e['a']], Nn[e['b']]
    if not (near_box(A) or near_box(Bb)): continue
    a, b = (A['x'], A['y']), (Bb['x'], Bb['y']); c = e.get('arc')
    if c:
        r = math.dist(a, c); t1 = math.atan2(a[1]-c[1], a[0]-c[0]); t2 = math.atan2(b[1]-c[1], b[0]-c[0])
        dt = (t2 - t1 + math.pi) % (2*math.pi) - math.pi
        pts = [(c[0]+r*math.cos(t1+dt*i/300), c[1]+r*math.sin(t1+dt*i/300)) for i in range(301)]
    else:
        pts = [(a[0]+(b[0]-a[0])*i/300, a[1]+(b[1]-a[1])*i/300) for i in range(301)]
    for q in pts:
        x, y = to_px(q)
        for dx in range(-3, 4):
            for dy in range(-3, 4): mask_road.add((int(x)+dx, int(y)+dy))
fixed = [to_px((n['x'], n['y'])) for n in B['nodes'] if near_box(n) and n['kind'] != 'travel']
KS = [(2.7, 94.0), (-2.7, 94.0)]
fixed += [to_px(q) for q in KS]
for fx, fy in fixed:
    for dx in range(-14, 15):
        for dy in range(-14, 15):
            if dx*dx + dy*dy <= 196: mask_road.add((int(fx)+dx, int(fy)+dy))
ink = lambda x, y: max(px[x, y]) > 85 and (x, y) not in mask_road
seen = set(); comps = []
for y in range(H):
    for x in range(W):
        if (x, y) in seen or not ink(x, y): continue
        q = deque([(x, y)]); seen.add((x, y)); pts = []
        while q:
            u = q.popleft(); pts.append(u)
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    v = (u[0]+dx, u[1]+dy)
                    if 0 <= v[0] < W and 0 <= v[1] < H and v not in seen and ink(*v):
                        seen.add(v); q.append(v)
        if len(pts) < 40: continue
        mp = [to_map(p) for p in pts]
        rs = [math.dist(m, (cx, cy)) for m in mp]
        comps.append({'n': len(pts), 'rmin': round(min(rs), 2), 'rmax': round(max(rs), 2),
                      'base': [round(v, 3) for v in mp[rs.index(min(rs))]],
                      'ang': round(math.degrees(math.atan2(mp[rs.index(min(rs))][0]-cx, mp[rs.index(min(rs))][1]-cy)), 1),
                      'px': pts})
json.dump(comps, open(outp, 'w'))
for i, c in enumerate(sorted(comps, key=lambda c: c['ang'])):
    print(i, c['n'], c['rmin'], c['rmax'], c['ang'])
