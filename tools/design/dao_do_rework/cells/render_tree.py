"""Render the whole map, Fire at the bottom (editor view). usage: python -I render_tree.py <map.json> <out.png> [size px]"""
import json, math, sys
from PIL import Image, ImageDraw
mp, out = sys.argv[1:3]; W = int(sys.argv[3]) if len(sys.argv) > 3 else 2400
M = json.load(open(mp, encoding='utf-8')); N = {n['id']: n for n in M['nodes']}
R = 136.0; k = W / (2 * R); SS = 2
X = lambda x: (W / 2 + x * k) * SS; Y = lambda y: (W / 2 + y * k) * SS
def geom(e):
    A, B = N[e['a']], N[e['b']]
    if not e.get('arc'): return [(A['x'], A['y']), (B['x'], B['y'])]
    c = e['arc']; r = math.dist((A['x'], A['y']), c)
    t1 = math.atan2(A['y'] - c[1], A['x'] - c[0]); t2 = math.atan2(B['y'] - c[1], B['x'] - c[0]); dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    n = max(2, int(abs(dt) * r / 0.3)); return [(c[0] + r * math.cos(t1 + dt * j / n), c[1] + r * math.sin(t1 + dt * j / n)) for j in range(n + 1)]
im = Image.new('RGB', (W * SS, W * SS), (8, 9, 12)); d = ImageDraw.Draw(im)
for e in M['edges']:
    road = N[e['a']]['kind'] in ('travel', 'start') and N[e['b']]['kind'] in ('travel', 'start')
    d.line([(X(x), Y(y)) for x, y in geom(e)], fill=(190, 150, 80) if road else (154, 128, 76), width=max(1, int(0.1 * k * SS)), joint='curve')
for n in M['nodes']:
    x, y = X(n['x']), Y(n['y'])
    big = {'notable': 0.42, 'keystone': 0.65, 'start': 0.6}.get(n['kind'])
    if big:
        r = big * k * SS; col = {'notable': (222, 178, 92), 'keystone': (225, 95, 80), 'start': (240, 240, 240)}[n['kind']]
        d.ellipse([x - r, y - r, x + r, y + r], fill=col)
    else:
        r = 0.22 * k * SS; d.ellipse([x - r, y - r, x + r, y + r], fill=(110, 100, 82))
im.resize((W, W), Image.LANCZOS).save(out); print(out)
