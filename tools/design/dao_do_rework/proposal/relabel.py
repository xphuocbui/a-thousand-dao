"""Relabel regions for lands that meet at borders (user, 2026-11-18: no blend zones in the main disc).

usage: python -I relabel.py <map.json> <out.json>

Inside r 84: a node within 0.6 units of an old blend axis line, or in a cluster centred on one (the border clusters at
59, the Wind start), is on the border between its two lands and gets 'border_<a><b>'; every other node gets the land
whose axis is nearest. The hub (r < 16.5) and the islands keep their labels. Labels only; nothing moves.
"""
import collections, json, math, sys
M = json.load(open(sys.argv[1], encoding='utf-8'))
LAND = {0: 'fire', 72: 'earth', 144: 'metal', 216: 'water', 288: 'wood'}
BORDER = {36: 'border_fe', 108: 'border_em', 180: 'border_mw', 252: 'border_ww', 324: 'border_wf'}
R = lambda n: math.hypot(n['x'], n['y'])
TH = lambda n: math.degrees(math.atan2(n['x'], n['y'])) % 360
def lateral(n, ax):
    t = math.radians(ax); return abs(n['x'] * math.cos(t) - n['y'] * math.sin(t)) if (n['x'] * math.sin(t) + n['y'] * math.cos(t)) > 0 else 9e9
clus = collections.defaultdict(list)
for n in M['nodes']:
    if n.get('cluster') is not None and n['kind'] in ('small', 'notable', 'start'):
        clus[n['cluster']].append(n)
on_border = {}
for c, ns in clus.items():
    cx = sum(n['x'] for n in ns) / len(ns); cy = sum(n['y'] for n in ns) / len(ns)
    probe = dict(x=cx, y=cy)
    for ax, lab in BORDER.items():
        if lateral(probe, ax) < 0.6 and 16.5 < math.hypot(cx, cy) < 84:
            for n in ns: on_border[n['id']] = lab
counts = collections.Counter()
for n in M['nodes']:
    r = R(n)
    if r < 16.5 or r > 84.6 or n.get('region') in ('light', 'thunder', 'darkness', 'shrine'):
        continue
    lab = on_border.get(n['id']) or next((l for ax, l in BORDER.items() if lateral(n, ax) < 0.6), None)
    if not lab:
        t = TH(n); lab = LAND[min(LAND, key=lambda a: abs((t - a + 180) % 360 - 180))]
    n['region'] = lab; counts[lab] += 1
json.dump(M, open(sys.argv[2], 'w', encoding='utf-8'))
print(dict(sorted(counts.items())))
