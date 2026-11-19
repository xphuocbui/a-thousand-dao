"""Render a square window of a compiled map, Fire at the bottom (same frame and colours as render_tree.py). Report only.

usage: python -I tools/design/dao_do_rework/cells/render_box.py <map.json> <out.png> <cx> <cy> <half> [px] [--ids]
  --ids writes road node ids (travel/start) next to their nodes, for picking hang points.
"""
import json
import math
import sys

from PIL import Image, ImageDraw

a = [x for x in sys.argv[1:] if not x.startswith('--')]
mp, out = a[0], a[1]
cx, cy, half = float(a[2]), float(a[3]), float(a[4])
W = int(a[5]) if len(a) > 5 else 1400
IDS = '--ids' in sys.argv
M = json.load(open(mp, encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
SS = 2
k = W / (2 * half)
X = lambda x: (x - cx + half) * k * SS
Y = lambda y: (y - cy + half) * k * SS


def geom(e):
    A, B = N[e['a']], N[e['b']]
    if not e.get('arc'):
        return [(A['x'], A['y']), (B['x'], B['y'])]
    c = e['arc']
    r = math.dist((A['x'], A['y']), c)
    t1 = math.atan2(A['y'] - c[1], A['x'] - c[0])
    t2 = math.atan2(B['y'] - c[1], B['x'] - c[0])
    dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    n = max(2, int(abs(dt) * r / 0.1))
    return [(c[0] + r * math.cos(t1 + dt * j / n), c[1] + r * math.sin(t1 + dt * j / n)) for j in range(n + 1)]


im = Image.new('RGB', (W * SS, W * SS), (8, 9, 12))
d = ImageDraw.Draw(im)
for e in M['edges']:
    road = N[e['a']]['kind'] in ('travel', 'start') and N[e['b']]['kind'] in ('travel', 'start')
    d.line([(X(x), Y(y)) for x, y in geom(e)], fill=(190, 150, 80) if road else (154, 128, 76),
           width=max(1, int(0.1 * k * SS)), joint='curve')
for n in M['nodes']:
    x, y = X(n['x']), Y(n['y'])
    if not (-20 <= x <= W * SS + 20 and -20 <= y <= W * SS + 20):
        continue
    big = {'notable': 0.42, 'keystone': 0.65, 'start': 0.6}.get(n['kind'])
    r = (big or 0.22) * k * SS
    col = {'notable': (222, 178, 92), 'keystone': (225, 95, 80), 'start': (240, 240, 240)}.get(n['kind'], (110, 100, 82))
    d.ellipse([x - r, y - r, x + r, y + r], fill=col)
    if IDS and n['kind'] in ('travel', 'start'):
        d.text((x + r + 2, y - r - 2), str(n['id']), fill=(120, 170, 220))
im = im.resize((W, W), Image.LANCZOS)
im.save(out)
print(out)
