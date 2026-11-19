"""Draws the roomiest distinct keystone spots of one land on a render (report only).
usage: python -I ks_show.py <map.json> <cands.json> <land> <out.png> [n]"""
import json, math, sys
from PIL import Image, ImageDraw
mp, cj, land, outp = sys.argv[1:5]; n = int(sys.argv[5]) if len(sys.argv) > 5 else 14
C = json.load(open(cj))
C = [c for c in C if c.get('land') == land and c['th'] >= 0] if land in ('fire', 'earth', 'metal', 'water', 'wood') else [c for c in C if c['region'] == land]
C.sort(key=lambda c: -c['clear'])
pick = []
for c in C:
    if all(math.dist(c['k'], p['k']) > 4 for p in pick):
        pick.append(c)
    if len(pick) >= n: break
json.dump(pick, open(outp[:-4] + '.json', 'w'), indent=0)
import subprocess
AX = {'fire': 0, 'earth': 72, 'metal': 144, 'water': 216, 'wood': 288}
if land in AX:
    subprocess.run(['python', '-I', 'design/dao-do/cells/openai/rotmap.py', mp, outp + '.rot.json', str(AX[land])], check=True)
    cx, cy, half = 0, 58, 44
    rot = lambda p: (p[0] * math.cos(math.radians(AX[land])) - p[1] * math.sin(math.radians(AX[land])), p[0] * math.sin(math.radians(AX[land])) + p[1] * math.cos(math.radians(AX[land])))
    src = outp + '.rot.json'
else:
    c0 = {'light': (0, 112, 20), 'thunder': (-103.7, -33.7, 22), 'darkness': (0, -105, 25)}[land]
    cx, cy, half = c0; rot = lambda p: p; src = mp
subprocess.run(['python', '-I', 'tools/design/dao_do_rework/cells/render_box.py', src, outp, str(cx), str(cy), str(half), '1400'], check=True, capture_output=True)
im = Image.open(outp).convert('RGB'); W = im.size[0]; dr = ImageDraw.Draw(im)
tp = lambda p: ((p[0] - cx + half) / (2 * half) * W, (p[1] - cy + half) / (2 * half) * W)
for i, c in enumerate(pick):
    for key in ('k', 'mk'):
        if key in c:
            x, y = tp(rot(c[key])); dr.ellipse((x - 11, y - 11, x + 11, y + 11), outline=(255, 60, 60), width=3)
            dr.text((x + 12, y - 8), str(i), fill=(255, 255, 255))
im.save(outp)
print(outp, len(pick), [(i, c['anchor'], c.get('r'), c.get('th'), c['clear']) for i, c in enumerate(pick)])
