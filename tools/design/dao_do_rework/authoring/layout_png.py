"""Render a graph version in the editor's orientation (y down), coloured by region, labelled. Report/render only."""
import json
import sys
from collections import defaultdict

from PIL import Image, ImageDraw, ImageFont

src, out = sys.argv[1], sys.argv[2]
labels = len(sys.argv) < 4 or sys.argv[3] != 'nolabels'
d = json.load(open(src, encoding='utf-8'))
ns = d['nodes'] if isinstance(d['nodes'], list) else list(d['nodes'].values())
N = {n['id']: n for n in ns}
es = d['edges'] if isinstance(d['edges'], list) else list(d['edges'].values())
COL = {'fire': (232, 93, 58), 'earth': (214, 168, 60), 'metal': (200, 205, 214), 'water': (70, 140, 230), 'wood': (80, 180, 100),
       'hub': (170, 120, 230), 'light': (240, 220, 120), 'darkness': (120, 100, 170), 'thunder': (150, 120, 255), 'shrine': (235, 90, 160),
       'blend_fe': (225, 130, 60), 'blend_em': (205, 185, 140), 'blend_mw': (140, 170, 220), 'blend_ww': (70, 165, 160), 'blend_wf': (170, 170, 70)}
NAME = {'fire': 'Fire', 'earth': 'Earth', 'metal': 'Metal', 'water': 'Water', 'wood': 'Wood', 'hub': 'Chaos (centre)', 'light': 'Light',
        'darkness': 'Darkness', 'thunder': 'Thunder', 'shrine': 'Shrine', 'blend_fe': 'Fire|Earth', 'blend_em': 'Earth|Metal',
        'blend_mw': 'Metal|Water', 'blend_ww': 'Water|Wood', 'blend_wf': 'Wood|Fire'}
xs = [n['x'] for n in ns]; ys = [n['y'] for n in ns]
cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
half = max(max(xs) - min(xs), max(ys) - min(ys)) / 2 * 1.04
SS = 2; W = 2048
s = W * SS / (2 * half)
P = lambda x, y: ((x - cx + half) * s, (y - cy + half) * s)
im = Image.new('RGB', (W * SS, W * SS), (10, 13, 18)); dr = ImageDraw.Draw(im)
for e in es:
    a, b = N.get(e['a'] if 'a' in e else e['from']), N.get(e['b'] if 'b' in e else e['to'])
    if not a or not b: continue
    c = COL.get(a['region'], (120, 120, 120))
    dr.line([P(a['x'], a['y']), P(b['x'], b['y'])], fill=tuple(int(v * .55) for v in c), width=2 * SS)
for n in ns:
    c = COL.get(n['region'], (150, 150, 150)); x, y = P(n['x'], n['y'])
    r = {'keystone': 9, 'start': 8, 'notable': 3.6}.get(n['kind'], 2.4) * SS
    if n['kind'] in ('keystone', 'start'):
        dr.ellipse([x - r, y - r, x + r, y + r], fill=(10, 13, 18), outline=(255, 255, 255) if n['kind'] == 'keystone' else c, width=3 * SS)
    else:
        dr.ellipse([x - r, y - r, x + r, y + r], fill=c)
if labels:
    R = defaultdict(list)
    for n in ns: R[n['region']].append(n)
    try: f = ImageFont.truetype('arialbd.ttf', 30 * SS)
    except OSError: f = ImageFont.load_default()
    for r, L in R.items():
        x, y = P(sum(n['x'] for n in L) / len(L), sum(n['y'] for n in L) / len(L))
        t = NAME.get(r, r); w = dr.textlength(t, font=f)
        dr.text((x - w / 2, y - 18 * SS), t, font=f, fill=(255, 255, 255), stroke_width=4 * SS, stroke_fill=(0, 0, 0))
im.resize((W, W), Image.LANCZOS).save(out)
print(out, f'map units per image width: {2 * half:.2f}, centre ({cx:.3f}, {cy:.3f})')
