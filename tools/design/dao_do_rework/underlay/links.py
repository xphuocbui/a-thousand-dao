"""Finds which dots of an underlay are joined by a drawn ornament line (measurement only).
usage: python -I links.py <img> <keep.json> <cx> <cy> <half> <out.json>
A pair of dots (and a dot and a road node) is joined if silver line pixels connect them inside the ellipse spanning
the pair, without passing through a third dot. Roads are gold lines, so they are not followed."""
import os
import json, math, sys
from collections import deque
from PIL import Image

img, kj, cx, cy, half, outp = sys.argv[1], sys.argv[2], *map(float, sys.argv[3:6]), sys.argv[6]
im = Image.open(img).convert('RGB')
W, H = im.size
px = im.load()
k = 2 * half / W
K = json.load(open(kj))
B = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'design', 'dao-do', 'cells', 'base-map.json'), encoding='utf-8'))
to_px = lambda q: ((q[0] - cx + half) / k, (q[1] - cy + half) / k)
roads = [(n['id'], to_px((n['x'], n['y']))) for n in B['nodes'] if n['kind'] == 'travel']
roads = [(i, p) for i, p in roads if -20 < p[0] < W + 20 and -20 < p[1] < H + 20]
fixed = [to_px((n['x'], n['y'])) for n in B['nodes'] if n['kind'] != 'travel']
N = {n['id']: (n['x'], n['y']) for n in B['nodes']}
roadpx = set()
for e in B['edges']:
    A0, B0 = N[e['a']], N[e['b']]
    pa, pb = to_px(A0), to_px(B0)
    if not (any(-50 < c < W + 50 for c in (pa[0], pb[0])) and any(-50 < c < H + 50 for c in (pa[1], pb[1]))):
        continue
    c = e.get('arc')
    if c:
        r = math.dist(A0, c)
        t1 = math.atan2(A0[1] - c[1], A0[0] - c[0]); t2 = math.atan2(B0[1] - c[1], B0[0] - c[0])
        dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        seq = [to_px((c[0] + r * math.cos(t1 + dt * t), c[1] + r * math.sin(t1 + dt * t))) for t in [i / 400 for i in range(401)]]
    else:
        seq = [(pa[0] + (pb[0] - pa[0]) * t, pa[1] + (pb[1] - pa[1]) * t) for t in [i / 400 for i in range(401)]]
    for x, y in seq:
        for dx in range(-3, 4):
            for dy in range(-3, 4):
                roadpx.add((int(x) + dx, int(y) + dy))
pts = [('d%d' % d['i'], tuple(d['px']), max(3.0, math.sqrt(d['area'] / math.pi) + 2.5)) for d in K]
pts += [(i, p, 6.0) for i, p in roads]


def silver(x, y):
    r, g, b = px[x, y]
    return b > 120 and r > 100 and b >= r - 10 and max(r, g, b) > 120


def gold(x, y):
    r, g, b = px[x, y]
    return r > 170 and g > 120 and b < 150


def joined(A, B, others):
    (ax, ay), ra = A[1], A[2]
    (bx, by), rb = B[1], B[2]
    L = math.dist((ax, ay), (bx, by))
    a = L / 2 + 6
    bmin = L * 0.55 + 6
    mx, my = (ax + bx) / 2, (ay + by) / 2
    ux, uy = (bx - ax) / L, (by - ay) / L

    def inside(x, y):
        dx, dy = x - mx, y - my
        p = dx * ux + dy * uy
        q = -dx * uy + dy * ux
        return (p / a) ** 2 + (q / bmin) ** 2 <= 1

    def blocked(x, y):
        return any(math.dist((x, y), o[1]) < o[2] for o in others)

    start = [(int(ax + dx), int(ay + dy)) for dx in range(-int(ra) - 2, int(ra) + 3) for dy in range(-int(ra) - 2, int(ra) + 3)
             if ra <= math.hypot(dx, dy) <= ra + 2.5]
    q = deque(s for s in start if 0 <= s[0] < W and 0 <= s[1] < H and (silver(*s) or (gold(*s) and s not in roadpx)))
    seen = set(q)
    while q:
        x, y = q.popleft()
        if math.dist((x, y), (bx, by)) <= rb + 2.5:
            return True
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                n = (x + dx, y + dy)
                if n in seen or not (0 <= n[0] < W and 0 <= n[1] < H):
                    continue
                seen.add(n)
                if (silver(*n) or (gold(*n) and (n not in roadpx or math.dist(n, (bx, by)) <= rb + 4))) and inside(*n) and not blocked(*n) \
                        and math.dist(n, (ax, ay)) > ra - 1:
                    q.append(n)
    return False


unit = 1 / k
pairs = []
for i, A in enumerate(pts):
    for j in range(i + 1, len(pts)):
        Bp = pts[j]
        if isinstance(A[0], int) and isinstance(Bp[0], int):
            continue
        L = math.dist(A[1], Bp[1])
        if L > 3.6 * unit or L < 0.3 * unit:
            continue
        others = [o for o in pts if o is not A and o is not Bp and math.dist(o[1], A[1]) < L + 10]
        if joined(A, Bp, others):
            pairs.append([A[0], Bp[0], round(L * k, 2)])
json.dump(pairs, open(outp, 'w'))
print(len(pairs), 'joins among', len(K), 'dots')
