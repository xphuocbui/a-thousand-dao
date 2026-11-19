"""The drawn line network of a picture (measurement only; the trace file chooses what becomes nodes). Generalised
2026-11-19 from chaos/skel.py for the Chaos redesign (chaos2/).

A pixel is line when it is bright, not a grey road disc, inside the ring rmin..rmax round the picture's centre (map
units), off every link and node of MASK (a compiled map: its roads and pieces, so a picture that keeps today's figures
gives only what it adds), and of the colour MODE asks: 'purple' (violet, purple, magenta) or 'any'. The line pixels
are thinned to centre lines (Zhang-Suen) and split into strokes between ends and junctions; spurs under SPUR px off a
junction go; a junction left with two strokes joins them. Writes {'v': [...], 's': [{'a','b','pts'}]} in map units.

usage: python -I skel2.py <img> <cx> <cy> <half> <rmin> <rmax> <purple|any> <mask map.json> <out.json>
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '..', '..', '..', '..', '..', 'tools', 'design', 'dao_do_rework', 'cells'))
sys.path.insert(0, os.path.join(HERE, '..'))
from celllib import road  # noqa: E402
from trace_fine import Fine  # noqa: E402

IMG, CX, CY, HALF, RMIN, RMAX, MODE, MASK, OUT = sys.argv[1], *map(float, sys.argv[2:7]), sys.argv[7], sys.argv[8], sys.argv[9]
SPUR = 9
U = Fine(IMG, CX, CY, HALF, road)
M = json.load(open(MASK, encoding='utf-8'))
Nn = {n['id']: n for n in M['nodes']}
masked = set()
for e in M['edges']:
    A, B = (Nn[e['a']]['x'], Nn[e['a']]['y']), (Nn[e['b']]['x'], Nn[e['b']]['y'])
    if max(abs(A[0] - CX), abs(A[1] - CY)) > HALF + 2:
        continue
    c = e.get('arc')
    if c:
        r = math.dist(A, c); t1 = math.atan2(A[1] - c[1], A[0] - c[0]); t2 = math.atan2(B[1] - c[1], B[0] - c[0])
        dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        pts = [(c[0] + r * math.cos(t1 + dt * i / 60), c[1] + r * math.sin(t1 + dt * i / 60)) for i in range(61)]
    else:
        pts = [(A[0] + (B[0] - A[0]) * i / 60, A[1] + (B[1] - A[1]) * i / 60) for i in range(61)]
    for q in pts:
        x, y = U.to_px(q)
        for dx in range(-3, 4):
            for dy in range(-3, 4):
                masked.add((int(x) + dx, int(y) + dy))
for n in M['nodes']:
    if max(abs(n['x'] - CX), abs(n['y'] - CY)) > HALF + 2:
        continue
    x, y = U.to_px((n['x'], n['y']))
    rr = int(0.55 / U.k) + 3
    for dx in range(-rr, rr + 1):
        for dy in range(-rr, rr + 1):
            if dx * dx + dy * dy <= rr * rr:
                masked.add((int(x) + dx, int(y) + dy))


def is_line(x, y):
    r, g, b = U.px[x, y]
    m = max(r, g, b)
    if m <= 90 or (x, y) in masked or (m - min(r, g, b) < 40 and m < 150):
        return False
    if MODE == 'purple':
        return b > 110 and r > 90 and g < 0.75 * min(r, b)
    return True


def inside(p):
    x, y = U.to_map(p)
    return RMIN < math.hypot(x - CX, y - CY) < RMAX


S = {(x, y) for y in range(1, U.H - 1) for x in range(1, U.W - 1) if inside((x, y)) and is_line(x, y)}


def nb(p):
    x, y = p
    return [(x, y - 1), (x + 1, y - 1), (x + 1, y), (x + 1, y + 1), (x, y + 1), (x - 1, y + 1), (x - 1, y), (x - 1, y - 1)]


changed = True
while changed:
    changed = False
    for step in (0, 1):
        rem = []
        for p in S:
            n = [q in S for q in nb(p)]
            b = sum(n)
            if b < 2 or b > 6:
                continue
            if sum(1 for i in range(8) if not n[i] and n[(i + 1) % 8]) != 1:
                continue
            if step == 0 and (n[0] and n[2] and n[4] or n[2] and n[4] and n[6]):
                continue
            if step == 1 and (n[0] and n[2] and n[6] or n[0] and n[4] and n[6]):
                continue
            rem.append(p)
        if rem:
            changed = True
            S.difference_update(rem)


def crossings(p):
    n = [q in S for q in nb(p)]
    return sum(1 for i in range(8) if n[i] and not n[(i + 1) % 8])


vpx = {p for p in S if crossings(p) != 2}
# junction clusters: touching vertex pixels are one vertex
vid, V = {}, []
for p in vpx:
    if p in vid:
        continue
    stack, comp = [p], []
    vid[p] = len(V)
    while stack:
        q = stack.pop()
        comp.append(q)
        for r in nb(q):
            if r in vpx and r not in vid:
                vid[r] = len(V)
                stack.append(r)
    V.append(comp)
strokes, used = [], set()
for s in vpx:
    for q in nb(s):
        if q not in S or q in vpx or (s, q) in used:
            continue
        path = [s, q]
        used.add((s, q)); used.add((q, s))
        prev, cur = s, q
        while cur not in vpx:
            nxt = [r for r in nb(cur) if r in S and r != prev and (cur, r) not in used and r not in path]
            home = [r for r in nb(cur) if r in vpx and r != prev and (len(path) > 3 or r != s)]
            if home:                                    # a junction beside us (the start's, for a loop): end there
                nxt = home
            if not nxt:
                break
            r = min(nxt, key=lambda t: (t[0] - cur[0]) ** 2 + (t[1] - cur[1]) ** 2)
            used.add((cur, r)); used.add((r, cur))
            prev, cur = cur, r
            path.append(cur)
        if cur in vpx and vid[cur] != vid[s] or len(path) > 6:
            strokes.append([vid[s], vid.get(cur, -1), path])
# drop the stroke duplicates (each is found from both ends)
seen, uniq = set(), []
for a, b, path in strokes:
    key = (min(path[0], path[-1]), max(path[0], path[-1]), len(path))
    if key in seen:
        continue
    seen.add(key)
    uniq.append([a, b, path])
strokes = uniq


def degree(v):
    return sum((a == v) + (b == v) for a, b, _ in strokes)


# clean: drop short spurs off junctions; join the two strokes of a junction left with two
for _ in range(6):
    drop = [i for i, (a, b, path) in enumerate(strokes)
            if len(path) < SPUR and ((degree(a) == 1 and degree(b) >= 3) or (degree(b) == 1 and degree(a) >= 3))]
    strokes = [s for i, s in enumerate(strokes) if i not in set(drop)]
    for v in range(len(V)):
        ss = [s for s in strokes if v in (s[0], s[1])]
        if len(ss) == 2 and ss[0] is not ss[1] and not (ss[0][0] == ss[0][1] or ss[1][0] == ss[1][1]):
            s1, s2 = ss
            p1 = s1[2] if s1[1] == v else s1[2][::-1]
            p2 = s2[2] if s2[0] == v else s2[2][::-1]
            a = s1[0] if s1[1] == v else s1[1]
            b = s2[1] if s2[0] == v else s2[0]
            strokes = [s for s in strokes if s is not s1 and s is not s2] + [[a, b, p1 + p2[1:]]]
# a stroke left without a vertex at one end (it ran into its own path) ends there freely: keep it, with a new vertex
for st in strokes:
    for end, idx in ((0, 0), (1, -1)):
        if st[end] < 0:
            V.append([st[2][idx]]); st[end] = len(V) - 1
live = sorted({v for a, b, _ in strokes for v in (a, b) if v >= 0})
ren = {v: i for i, v in enumerate(live)}
centre = lambda comp: U.to_map((sum(p[0] for p in comp) / len(comp), sum(p[1] for p in comp) / len(comp)))
out = {'v': [[round(c, 4) for c in centre(V[v])] for v in live],
       's': [{'a': ren[a], 'b': ren[b], 'pts': [[round(c, 4) for c in U.to_map(p)] for p in path]}
             for a, b, path in strokes if a >= 0 and b >= 0]}
json.dump(out, open(OUT, 'w'))
L = sorted(sum(math.dist(p, q) for p, q in zip(s['pts'], s['pts'][1:])) for s in out['s'])
print(len(S), 'skeleton px;', len(out['v']), 'vertices;', len(out['s']), 'strokes; total length', round(sum(L), 1),
      'units; longest', [round(x, 1) for x in L[-5:]])
