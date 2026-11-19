"""Render one cell from a cells JSON (lines + nodes) at a given px/unit. usage: <cells.json> <tree> <cell id> <out.png> [px/unit]"""
import json, sys
from PIL import Image, ImageDraw
cp, tree, cid, out = sys.argv[1:5]; k = float(sys.argv[5]) if len(sys.argv) > 5 else 32.3
D = json.load(open(cp))[tree]; C = [c for c in D['cells'] if c['id'] == int(cid)][0]
poly = C['ps'][0] if 'ps' in C else C['p']
xs = [p[0] for p in poly]; ys = [p[1] for p in poly]
W = 1024; half = W / k / 2; cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2; X0, Y0 = cx - half, cy - half; SS = 3
X = lambda x: (x - X0) * k * SS; Y = lambda y: (y - Y0) * k * SS
im = Image.new('RGB', (W * SS, W * SS), (8, 9, 12)); d = ImageDraw.Draw(im)
for L in D['lines']:
    col = (190, 150, 80) if L['k'] == 'r' else (154, 128, 76)
    d.line([(X(x), Y(y)) for x, y in L['p']], fill=col, width=int(0.09 * k * SS), joint='curve')
kinds = set()
for x, y, kd in D['nodes']:
    kinds.add(kd); cx_, cy_ = X(x), Y(y)
    if kd in ('notable', 'n', 'keystone', 'k'):
        r = 0.42 * k * SS; d.ellipse([cx_ - r, cy_ - r, cx_ + r, cy_ + r], fill=(222, 178, 92)); r2 = r * .72; d.ellipse([cx_ - r2, cy_ - r2, cx_ + r2, cy_ + r2], fill=(150, 104, 64))
    else:
        r = 0.22 * k * SS; d.ellipse([cx_ - r, cy_ - r, cx_ + r, cy_ + r], fill=(120, 106, 80)); r2 = r * .7; d.ellipse([cx_ - r2, cy_ - r2, cx_ + r2, cy_ + r2], fill=(82, 84, 90))
d.polygon([(X(x), Y(y)) for x, y in poly], outline=(60, 170, 230), width=SS)
im.resize((W, W), Image.LANCZOS).save(out); print('kinds', kinds, 'area', C['a'], 'nn', C['nn'])
