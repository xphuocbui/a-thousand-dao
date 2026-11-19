"""Drops dots that sit on road/start nodes or are specks, numbers the rest and draws the numbers on the image.
usage: python -I label.py <img> <dots.json> <out.png> <kept.json> [crop x0 y0 x1 y1 scale]"""
import json, math, sys
from PIL import Image, ImageDraw
img, dj, outp, kj = sys.argv[1:5]
B = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', '..', '..', 'design', 'dao-do', 'cells', 'base-map.json'), encoding='utf-8'))
fixed = [(n['x'], n['y']) for n in B['nodes']]
D = json.load(open(dj))
import os
MINA = int(os.environ.get('MINA', 8))
keep = [d for d in D if d['area'] >= MINA and min(math.dist(d['xy'], f) for f in fixed) > 0.6]
for i, d in enumerate(keep):
    d['i'] = i
json.dump(keep, open(kj, 'w'), indent=0)
im = Image.open(img).convert('RGB')
crop = list(map(float, sys.argv[5:10])) if len(sys.argv) > 5 else [0, 0, im.size[0], im.size[1], 1]
x0, y0, x1, y1, sc = crop
im = im.crop((int(x0), int(y0), int(x1), int(y1))).resize((int((x1 - x0) * sc), int((y1 - y0) * sc)), Image.LANCZOS)
dr = ImageDraw.Draw(im)
for d in keep:
    x, y = (d['px'][0] - x0) * sc, (d['px'][1] - y0) * sc
    if 0 <= x < im.size[0] and 0 <= y < im.size[1]:
        dr.text((x + 6, y - 14), str(d['i']), fill=(255, 80, 80))
im.save(outp)
print(len(keep), 'kept')
