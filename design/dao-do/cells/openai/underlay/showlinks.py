"""Draws detected joins (red) and dot numbers over an underlay. usage: python -I showlinks.py <img> <keep.json> <links.json> <cx> <cy> <half> <out.png>"""
import json, sys
from PIL import Image, ImageDraw
img, kj, lj, cx, cy, half, outp = sys.argv[1], sys.argv[2], sys.argv[3], *map(float, sys.argv[4:7]), sys.argv[7]
im = Image.open(img).convert('RGB'); W = im.size[0]; k = 2 * half / W
B = json.load(open('../../base-map.json', encoding='utf-8'))
P = {('d%d' % d['i']): tuple(d['px']) for d in json.load(open(kj))}
P.update({n['id']: ((n['x'] - cx + half) / k, (n['y'] - cy + half) / k) for n in B['nodes'] if n['kind'] == 'travel'})
sc = 2
im = im.resize((W * sc, W * sc)); dr = ImageDraw.Draw(im)
for a, b, _ in json.load(open(lj)):
    pa, pb = P[a], P[b]
    dr.line([(pa[0] * sc, pa[1] * sc), (pb[0] * sc, pb[1] * sc)], fill=(255, 40, 40), width=3)
for key, p in P.items():
    if isinstance(key, str) and 0 <= p[0] < W:
        dr.text((p[0] * sc + 7, p[1] * sc - 16), key[1:], fill=(80, 255, 120))
im.save(outp)
