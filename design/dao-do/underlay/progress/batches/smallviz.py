"""Render-only: PoE 2 small-cluster copies in context, and a crop with repeated drawings coloured."""
import sys, os, json, math, collections
sys.path.insert(0, r'C:\Users\xphuo\IdeaProjects\my-game\tools\design\dao_do_rework\tree_view'); sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import trees
from shapestats import comps
from PIL import Image, ImageDraw
t, a = trees.load_poe2(sys.argv[1]); NN = t['nodes']
pk = {'small': 's', 'notable': 'N', 'jewel': 'N'}; kind = lambda i: pk.get(NN[i][2], 'r')
E = [tuple(e[:2]) for e in t['edges']]
cs, adj = comps(range(len(NN)), E, lambda i: kind(i) in ('s', 'N'))
xy = lambda i: (NN[i][0], NN[i][1])
def sig(c):
    p = [xy(i) for i in c]; k = len(c)
    return (tuple(sorted(kind(i) for i in c)), tuple(sorted(round(math.dist(p[i], p[j]) / 0.5) for i in range(k) for j in range(i + 1, k))))
S = [sig(c) for c in cs]; cl_of = {i: n for n, c in enumerate(cs) for i in c}
cnt = collections.Counter(S[n] for n, c in enumerate(cs) if len(c) <= 5)
top = [s for s, _ in cnt.most_common(12) if s[0] != ('N',)][:8]   # skip lone jewel sockets
COL = [(240, 90, 90), (90, 200, 240), (120, 230, 120), (240, 200, 70), (220, 120, 240), (255, 150, 60), (80, 240, 200), (240, 240, 240)]
def arcpts(pa, pb, cc, n=12):
    r = math.dist(pa, cc); t1 = math.atan2(pa[1] - cc[1], pa[0] - cc[0]); t2 = math.atan2(pb[1] - cc[1], pb[0] - cc[0]); dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    return [(cc[0] + r * math.cos(t1 + dt * k / n), cc[1] + r * math.sin(t1 + dt * k / n)) for k in range(n + 1)]
def draw(d, T, hl, box):
    x0, y0, x1, y1 = box
    vis = lambda p: x0 - 2 <= p[0] <= x1 + 2 and y0 - 2 <= p[1] <= y1 + 2
    for e in t['edges']:
        pa, pb = xy(e[0]), xy(e[1])
        if not (vis(pa) or vis(pb)): continue
        pl = arcpts(pa, pb, (e[2], e[3])) if len(e) > 2 else [pa, pb]
        c = hl.get(cl_of.get(e[0]), None) if cl_of.get(e[0]) == cl_of.get(e[1]) else None
        d.line([T(p) for p in pl], fill=c or (95, 80, 55), width=3 if c else 2)
    for i, n in enumerate(NN):
        p = xy(i)
        if not vis(p): continue
        c = hl.get(cl_of.get(i))
        r = {'notable': 7, 'keystone': 10, 'jewel': 7, 'start': 10}.get(n[2], 4)
        x, y = T(p); d.ellipse([x - r, y - r, x + r, y + r], fill=c or ((150, 120, 70) if n[2] in ('notable', 'jewel') else (85, 88, 100)))
# 1) copies in context: 4 drawings x 6 copies, 7x7 unit windows
cell, W = 260, 7.0; S_ = cell / W
img = Image.new('RGB', (6 * cell, 4 * cell + 30), (11, 12, 16)); d = ImageDraw.Draw(img)
d.text((8, 8), 'PoE 2: six copies each of its four commonest small drawings (one per row, coloured), each in its own spot (7 x 7 units)', fill=(220, 190, 120))
for r, s in enumerate(top[:4]):
    copies = [n for n, c in enumerate(cs) if S[n] == s][:6]
    for k, n in enumerate(copies):
        c = cs[n]; cx = sum(xy(i)[0] for i in c) / len(c); cy = sum(xy(i)[1] for i in c) / len(c)
        ox, oy = k * cell, r * cell + 30
        T = lambda p, ox=ox, oy=oy, cx=cx, cy=cy: (ox + cell / 2 + (p[0] - cx) * S_, oy + cell / 2 + (p[1] - cy) * S_)
        sub = Image.new('RGB', (6 * cell, 4 * cell + 30)); 
        draw(d, T, {n: COL[r]}, (cx - W / 2, cy - W / 2, cx + W / 2, cy + W / 2))
        d.rectangle([ox, oy, ox + cell - 1, oy + cell - 1], outline=(11, 12, 16), width=6)
        d.rectangle([ox + 3, oy + 3, ox + cell - 4, oy + cell - 4], outline=(45, 45, 55))
out1 = r'C:\Users\xphuo\IdeaProjects\my-game\design\dao-do\underlay\progress\poe2-small-copies-2026-11-18.png'
img.save(out1); print(out1)
# 2) a 40-unit crop with the 8 commonest small drawings coloured
cx, cy, W2 = float(sys.argv[2]), float(sys.argv[3]), 40.0; px = 1600; S2 = px / W2
img = Image.new('RGB', (px, px + 30), (11, 12, 16)); d = ImageDraw.Draw(img)
d.text((8, 8), 'PoE 2, 40 x 40 units at (%.0f, %.0f): the 8 commonest small drawings, one colour each; everything else plain' % (cx, cy), fill=(220, 190, 120))
hl = {n: COL[top.index(S[n])] for n in range(len(cs)) if S[n] in top}
T = lambda p: ((p[0] - cx + W2 / 2) * S2, (p[1] - cy + W2 / 2) * S2 + 30)
draw(d, T, hl, (cx - W2 / 2, cy - W2 / 2, cx + W2 / 2, cy + W2 / 2))
out2 = r'C:\Users\xphuo\IdeaProjects\my-game\design\dao-do\underlay\progress\poe2-small-repeats-crop-2026-11-18.png'
img.save(out2); print(out2)
