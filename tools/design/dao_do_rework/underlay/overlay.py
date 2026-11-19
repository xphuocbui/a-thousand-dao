"""Draws a compiled map's pieces of one cell (red links, red rings at nodes) over its underlay picture, to compare.
usage: python -I overlay.py <map.json> <cell> <img> <cx> <cy> <half> <out.png> [scale]"""
import json, math, sys
from PIL import Image, ImageDraw
mp, cell, img, cx, cy, half, outp = sys.argv[1], int(sys.argv[2]), sys.argv[3], *map(float, sys.argv[4:7]), sys.argv[7]
sc = float(sys.argv[8]) if len(sys.argv) > 8 else 2
M = json.load(open(mp, encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
im = Image.open(img).convert('RGB')
W = im.size[0]
im = im.resize((int(W * sc), int(W * sc)))
dr = ImageDraw.Draw(im)
k = 2 * half / W
P = lambda q: ((q[0] - cx + half) / k * sc, (q[1] - cy + half) / k * sc)
mine = {i for i, n in N.items() if (n.get('name') or '').startswith(f'c{cell} ')}
for e in M['edges']:
    if e['a'] in mine or e['b'] in mine:
        A, B = (N[e['a']]['x'], N[e['a']]['y']), (N[e['b']]['x'], N[e['b']]['y'])
        c = e.get('arc')
        if c:
            r = math.dist(A, c); t1 = math.atan2(A[1] - c[1], A[0] - c[0]); t2 = math.atan2(B[1] - c[1], B[0] - c[0])
            dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
            pl = [P((c[0] + r * math.cos(t1 + dt * i / 20), c[1] + r * math.sin(t1 + dt * i / 20))) for i in range(21)]
        else:
            pl = [P(A), P(B)]
        dr.line(pl, fill=(255, 50, 50), width=2)
for i in mine:
    x, y = P((N[i]['x'], N[i]['y']))
    r = 9 if N[i]['kind'] == 'notable' else 6
    dr.ellipse((x - r, y - r, x + r, y + r), outline=(255, 50, 50), width=2)
im.save(outp)
