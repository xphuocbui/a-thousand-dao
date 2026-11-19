"""Render the rim seam round each land border, each turned so its border road points down. Report only.
usage: python -I render_border.py <map.json> <out.png> [px per unit, default 24]"""
import json, math, sys
from PIL import Image, ImageDraw
mp, out = sys.argv[1:3]; k = float(sys.argv[3]) if len(sys.argv) > 3 else 24.0
M = json.load(open(mp, encoding='utf-8')); N = {n['id']: n for n in M['nodes']}
def geom(e):
    A, B = N[e['a']], N[e['b']]
    if not e.get('arc'): return [(A['x'], A['y']), (B['x'], B['y'])]
    c = e['arc']; r = math.dist((A['x'], A['y']), c)
    t1 = math.atan2(A['y'] - c[1], A['x'] - c[0]); t2 = math.atan2(B['y'] - c[1], B['x'] - c[0]); dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    n = max(2, int(abs(dt) * r / 0.1)); return [(c[0] + r * math.cos(t1 + dt * j / n), c[1] + r * math.sin(t1 + dt * j / n)) for j in range(n + 1)]
tiles = []
for g in (36, 108, 180, 252, 324):
    a = math.radians(-g)
    rot = lambda x, y: (math.hypot(x, y) * math.sin(math.atan2(x, y) + a), math.hypot(x, y) * math.cos(math.atan2(x, y) + a))
    X0, X1, Y0, Y1 = -11.0, 11.0, 71.0, 97.0; SS = 2; W, H = int((X1 - X0) * k), int((Y1 - Y0) * k)
    X = lambda x: (x - X0) * k * SS; Y = lambda y: (y - Y0) * k * SS
    im = Image.new('RGB', (W * SS, H * SS), (8, 9, 12)); d = ImageDraw.Draw(im)
    for e in M['edges']:
        A, B = N[e['a']], N[e['b']]
        if min(math.hypot(A['x'], A['y']), math.hypot(B['x'], B['y'])) < 65: continue
        road = A['kind'] in ('travel', 'start') and B['kind'] in ('travel', 'start')
        d.line([(X(p[0]), Y(p[1])) for p in (rot(*q) for q in geom(e))], fill=(190, 150, 80) if road else (154, 128, 76), width=max(1, int(0.09 * k * SS)))
    for n in M['nodes']:
        x, y = rot(n['x'], n['y'])
        if not (X0 - 1 < x < X1 + 1 and Y0 - 1 < y < Y1 + 1): continue
        rr = {'notable': 0.42, 'keystone': 0.65, 'start': 0.6}.get(n['kind'], 0.22) * k * SS
        col = {'notable': (222, 178, 92), 'keystone': (225, 95, 80), 'start': (240, 240, 240)}.get(n['kind'], (110, 100, 82))
        d.ellipse([X(x) - rr, Y(y) - rr, X(x) + rr, Y(y) + rr], fill=col)
    tiles.append(im.resize((W, H), Image.LANCZOS))
S = Image.new('RGB', (sum(t.width for t in tiles) + 8 * 4, tiles[0].height), (30, 30, 34)); x = 0
for t in tiles: S.paste(t, (x, 0)); x += t.width + 8
S.save(out); print(out, S.size)
