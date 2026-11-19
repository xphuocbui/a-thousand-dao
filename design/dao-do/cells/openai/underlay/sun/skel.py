"""Centre lines of an underlay's drawn shapes (measurement only): the ornament mask (roads, start and keystones masked out,
as in comps.py) is thinned to one-pixel lines (Zhang-Suen), split into strokes between ends and junctions, and each
stroke written as a polyline in map coordinates. usage: python -I skel.py <img> <cx> <cy> <half> <out.json>"""
import json, math, sys
from PIL import Image
img, cx, cy, half, outp = sys.argv[1], *map(float, sys.argv[2:5]), sys.argv[5]
im = Image.open(img).convert('RGB'); W, H = im.size; px = im.load(); k = 2 * half / W
B = json.load(open('../../../base-map.json', encoding='utf-8'))
Nn = {n['id']: n for n in B['nodes']}
to_px = lambda q: ((q[0] - cx + half) / k, (q[1] - cy + half) / k)
to_map = lambda p: (round(cx - half + p[0] * k, 4), round(cy - half + p[1] * k, 4))
near_box = lambda n: abs(n['x'] - cx) < half + 2 and abs(n['y'] - cy) < half + 2
mask = set()
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
            for dy in range(-3, 4): mask.add((int(x)+dx, int(y)+dy))
fixed = [to_px((n['x'], n['y'])) for n in B['nodes'] if near_box(n) and n['kind'] != 'travel'] + [to_px(q) for q in ((2.7, 94.0), (-2.7, 94.0))]
for fx, fy in fixed:
    for dx in range(-14, 15):
        for dy in range(-14, 15):
            if dx*dx + dy*dy <= 196: mask.add((int(fx)+dx, int(fy)+dy))
S = {(x, y) for y in range(1, H-1) for x in range(1, W-1) if max(px[x, y]) > 85 and (x, y) not in mask}
# fill bead holes a little so beads thin to a point on the line
def nb(p):
    x, y = p
    return [(x, y-1), (x+1, y-1), (x+1, y), (x+1, y+1), (x, y+1), (x-1, y+1), (x-1, y), (x-1, y-1)]
changed = True
while changed:
    changed = False
    for step in (0, 1):
        rem = []
        for p in S:
            n = [q in S for q in nb(p)]
            b = sum(n)
            if b < 2 or b > 6: continue
            a = sum(1 for i in range(8) if not n[i] and n[(i+1) % 8])
            if a != 1: continue
            if step == 0 and (n[0] and n[2] and n[4] or n[2] and n[4] and n[6]): continue
            if step == 1 and (n[0] and n[2] and n[6] or n[0] and n[4] and n[6]): continue
            rem.append(p)
        if rem:
            changed = True
            S.difference_update(rem)
def branches(p):                     # crossing number: separate line branches leaving p
    n = [q in S for q in nb(p)]
    return sum(1 for i in range(8) if n[i] and not n[(i + 1) % 8])
nodes = {p for p in S if branches(p) != 2}
strokes, used = [], set()
for s in nodes:
    for q in nb(s):
        if q not in S or (s, q) in used: continue
        path = [s, q]; used.add((s, q)); used.add((q, s)); prev, cur = s, q
        while cur not in nodes:
            nxt = [r for r in nb(cur) if r in S and r != prev and (cur, r) not in used and r not in path]
            if not nxt: break
            r = nxt[0]; used.add((cur, r)); used.add((r, cur)); prev, cur = cur, r; path.append(cur)
        strokes.append([to_map(p) for p in path])
json.dump(strokes, open(outp, 'w'))
print(len(S), 'skeleton px;', len(strokes), 'strokes; lengths (units):', sorted(round(sum(math.dist(a, b) for a, b in zip(s, s[1:])), 1) for s in strokes)[-10:])
