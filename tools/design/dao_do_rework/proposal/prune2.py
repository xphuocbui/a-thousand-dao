"""Take the rings off the axis shapes' side nodes (compile only; the user's decision, 2026-11-18).

usage: python -I prune2.py <map.json> <out.json>

User: the rings should touch an axis shape only at its top or bottom node, so the shape sits on its axis like a
bead on the spine. This removes, for the kept shapes (land emblems 11 13 15 17 19, blend circles 22 24 26 29, the
Ice start 5, the Wind start 7):
- every ring link between a ring node and one of those shapes' nodes;
- the ring nodes in the stretch that hugged the shape: ring 1 (41.7) within 12.5 degrees of a land axis, the
  middle ring (53.9) within 10.5 degrees of a land axis or 6 of a blend axis, ring 2 (64.3) within 4.5 degrees of a
  blend axis. The curved ends that replace them are drawn by hand in curves.json.
"""
import json, math, sys

M = json.load(open(sys.argv[1], encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
R = lambda n: math.hypot(n['x'], n['y'])
TH = lambda n: math.degrees(math.atan2(n['x'], n['y'])) % 360
SHAPES = {5, 7, 11, 13, 15, 17, 19, 22, 24, 26, 29}
def d_land(n):
    return min(abs((TH(n) - a + 180) % 360 - 180) for a in (0, 72, 144, 216, 288))
def d_blend(n):
    return min(abs((TH(n) - a + 180) % 360 - 180) for a in (36, 108, 180, 252, 324))
def ring_node(n, r):
    return n['kind'] == 'travel' and n.get('proposal') and abs(R(n) - r) < 0.25
drop = set()
for i, n in N.items():
    if ring_node(n, 41.7) and d_land(n) < 12.5:
        drop.add(i)
    if ring_node(n, 53.9) and (d_land(n) < 10.5 or d_blend(n) < 6.0):
        drop.add(i)
    if ring_node(n, 64.3) and d_blend(n) < 4.5:
        drop.add(i)
keep = []
cut = 0
for e in M['edges']:
    a, b = N[e['a']], N[e['b']]
    if e['a'] in drop or e['b'] in drop:
        cut += 1; continue
    shape_end = [x for x in (a, b) if x['kind'] in ('small', 'notable', 'start') and x.get('cluster') in SHAPES]
    ring_end = [x for x in (a, b) if x['kind'] == 'travel' and any(abs(R(x) - r) < 0.25 for r in (41.7, 53.9, 64.3)) and x.get('proposal')]
    if shape_end and ring_end:
        cut += 1; continue
    keep.append(e)
used = {i for e in keep for i in (e['a'], e['b'])}
M['nodes'] = [n for n in M['nodes'] if n['id'] in used]
M['edges'] = keep
M.pop('adds', None)
json.dump(M, open(sys.argv[2], 'w', encoding='utf-8'))
print('dropped %d ring nodes, cut %d links; %d nodes, %d links left' % (len(drop), cut, len(M['nodes']), len(keep)))
