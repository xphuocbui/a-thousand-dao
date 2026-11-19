"""Render one cell of a map at a known scale plus a mask that frees only the cell's inside.
usage: python -I render_cell.py <map.json> <cells.json> <cell id> <out prefix> [margin units] [inset units]"""
import json, sys, math
from PIL import Image, ImageDraw, ImageFilter
mp, cp, cid, pre = sys.argv[1:5]
margin = float(sys.argv[5]) if len(sys.argv) > 5 else 5.0
inset = float(sys.argv[6]) if len(sys.argv) > 6 else 0.8
M = json.load(open(mp)); N = {n['id']: n for n in M['nodes']}
C = [c for c in json.load(open(cp))['ours']['cells'] if c['id'] == int(cid)][0]
poly = C['ps'][0] if 'ps' in C else C['p']
xs = [p[0] for p in poly]; ys = [p[1] for p in poly]
cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
half = max(max(xs) - min(xs), max(ys) - min(ys)) / 2 + margin
W = 1024; k = W / (2 * half); X0, Y0 = cx - half, cy - half; SS = 3
X = lambda x: (x - X0) * k; Y = lambda y: (y - Y0) * k
def geom(e):
    a, b = N[e['a']], N[e['b']]
    if not e.get('arc'): return [(a['x'], a['y']), (b['x'], b['y'])]
    c = e['arc']; r = math.dist((a['x'], a['y']), c)
    t1 = math.atan2(a['y'] - c[1], a['x'] - c[0]); t2 = math.atan2(b['y'] - c[1], b['x'] - c[0]); dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    n = max(2, int(abs(dt) * r / 0.1)); return [(c[0] + r * math.cos(t1 + dt * j / n), c[1] + r * math.sin(t1 + dt * j / n)) for j in range(n + 1)]
road = lambda n: n['kind'] in ('travel', 'start')
im = Image.new('RGB', (W * SS, W * SS), (8, 9, 12)); d = ImageDraw.Draw(im)
LINE = (154, 128, 76)
for e in M['edges']:
    a, b = N[e['a']], N[e['b']]
    d.line([(X(x) * SS, Y(y) * SS) for x, y in geom(e)], fill=LINE, width=int(0.09 * k * SS), joint='curve')
for n in M['nodes']:
    x, y = X(n['x']) * SS, Y(n['y']) * SS
    if n['kind'] == 'notable':
        r = 0.42 * k * SS; d.ellipse([x - r, y - r, x + r, y + r], fill=(222, 178, 92)); r2 = r * 0.72; d.ellipse([x - r2, y - r2, x + r2, y + r2], fill=(150, 104, 64))
    else:
        r = 0.22 * k * SS; d.ellipse([x - r, y - r, x + r, y + r], fill=(120, 106, 80)); r2 = r * 0.7; d.ellipse([x - r2, y - r2, x + r2, y + r2], fill=(82, 84, 90))
im.resize((W, W), Image.LANCZOS).save(pre + '-ref.png')
# mask: opaque, except the cell's inside shrunk by `inset` units (so the wall roads and their nodes stay)
inside = Image.new('L', (W, W), 0); ImageDraw.Draw(inside).polygon([(X(x), Y(y)) for x, y in poly], fill=255)
er = max(3, int(inset * k) | 1)
inside = inside.filter(ImageFilter.MinFilter(er if er % 2 else er + 1))
mk = Image.new('RGBA', (W, W), (0, 0, 0, 255)); mk.putalpha(inside.point(lambda v: 0 if v > 128 else 255))
mk.save(pre + '-mask.png')
# preview: mask outline on the reference
pv = Image.open(pre + '-ref.png').convert('RGB'); pd = ImageDraw.Draw(pv)
pd.polygon([(X(x), Y(y)) for x, y in poly], outline=(80, 200, 255))
pv.save(pre + '-preview.png')
json.dump({'cell': int(cid), 'area': C['a'], 'crop': [X0, Y0, X0 + 2 * half, Y0 + 2 * half], 'px_per_unit': k}, open(pre + '-frame.json', 'w'))
print('cell %s area %.1f  %.1f px/unit  crop %.1f units' % (cid, C['a'], k, 2 * half))
