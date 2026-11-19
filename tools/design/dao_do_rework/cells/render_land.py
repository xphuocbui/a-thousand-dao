"""Render one land of a map, turned so its axis points down (as Fire), with cell ids written in the empty cells.
usage: python -I render_land.py <map.json> <land> <out.png> [px per unit, default 14] [--ids]"""
import json, math, os, sys
from PIL import Image, ImageDraw, ImageFont
mp, land, out = sys.argv[1:4]
k = float(sys.argv[4]) if len(sys.argv) > 4 and not sys.argv[4].startswith('--') else 14.0
AXIS = {'fire': 0, 'earth': 72, 'metal': 144, 'water': 216, 'wood': 288}
M = json.load(open(mp, encoding='utf-8')); N = {n['id']: n for n in M['nodes']}
a = math.radians(-AXIS[land]); ca, sa = math.cos(a), math.sin(a)
def rot(x, y):                       # turn by -axis (in the frame where theta is measured from +y towards +x)
    th = math.atan2(x, y) + a; r = math.hypot(x, y); return (r * math.sin(th), r * math.cos(th))
X0, X1, Y0, Y1 = -56.0, 56.0, -6.0, 88.0; SS = 2
W, H = int((X1 - X0) * k), int((Y1 - Y0) * k)
X = lambda x: (x - X0) * k * SS; Y = lambda y: (y - Y0) * k * SS
def geom(e):
    A, B = N[e['a']], N[e['b']]
    if not e.get('arc'): return [(A['x'], A['y']), (B['x'], B['y'])]
    c = e['arc']; r = math.dist((A['x'], A['y']), c)
    t1 = math.atan2(A['y'] - c[1], A['x'] - c[0]); t2 = math.atan2(B['y'] - c[1], B['x'] - c[0]); dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    n = max(2, int(abs(dt) * r / 0.15)); return [(c[0] + r * math.cos(t1 + dt * j / n), c[1] + r * math.sin(t1 + dt * j / n)) for j in range(n + 1)]
im = Image.new('RGB', (W * SS, H * SS), (8, 9, 12)); d = ImageDraw.Draw(im)
for e in M['edges']:
    pts = [rot(x, y) for x, y in geom(e)]
    road = N[e['a']]['kind'] in ('travel', 'start') and N[e['b']]['kind'] in ('travel', 'start')
    d.line([(X(x), Y(y)) for x, y in pts], fill=(190, 150, 80) if road else (154, 128, 76), width=max(1, int(0.09 * k * SS)), joint='curve')
for n in M['nodes']:
    x, y = rot(n['x'], n['y']); x, y = X(x), Y(y)
    if n['kind'] in ('notable', 'keystone', 'start'):
        r = (0.42 if n['kind'] == 'notable' else 0.6) * k * SS
        col = (222, 178, 92) if n['kind'] == 'notable' else ((225, 95, 80) if n['kind'] == 'keystone' else (240, 240, 240))
        d.ellipse([x - r, y - r, x + r, y + r], fill=col); r2 = r * .72
        if n['kind'] == 'notable': d.ellipse([x - r2, y - r2, x + r2, y + r2], fill=(150, 104, 64))
    else:
        r = 0.22 * k * SS; d.ellipse([x - r, y - r, x + r, y + r], fill=(120, 106, 80)); r2 = r * .7; d.ellipse([x - r2, y - r2, x + r2, y + r2], fill=(82, 84, 90))
if '--ids' in sys.argv:
    inv = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'design', 'dao-do', 'cells', 'inventory.json')))
    try: f = ImageFont.truetype('arial.ttf', int(1.1 * k * SS))
    except Exception: f = None
    for c in inv[land]:
        x, y = c['r'] * math.sin(math.radians(c['th'])), c['r'] * math.cos(math.radians(c['th']))
        d.text((X(x), Y(y)), str(c['cell']), fill=(90, 200, 255), font=f, anchor='mm')
im.resize((W, H), Image.LANCZOS).save(out); print(out, W, H)
