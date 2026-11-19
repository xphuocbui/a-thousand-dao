"""Remove shapes and roads from a compiled map (compile only; what to remove is the user's decision, listed here).

usage: python -I prune.py <map.json> <out.json>

2026-11-18, user: drop the rim ring ("the circle is too big") and keep one emblem per axis (land emblem at 48,
blend circle at 59). Removes:
- the second land emblems at 69.5 (clusters 12, 14, 16, 18, 20) and the inner blend circles at 37.5 (21, 23, 25, 27, 28);
- the rim ring at 84, except the two short pieces Darkness hangs on (102-105 and 204-207 degrees);
- the outer spokes between the outer ring (74.3) and the rim: the one at offset 24 entirely, the one at offset 12
  beyond its first link (kept as a short hook into the open band).
Then drops road nodes left with no links.
"""
import json, math, sys

M = json.load(open(sys.argv[1], encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
R = lambda n: math.hypot(n['x'], n['y'])
TH = lambda n: math.degrees(math.atan2(n['x'], n['y'])) % 360
GONE_CL = {12, 14, 16, 18, 20, 21, 23, 25, 27, 28}
gone = {i for i, n in N.items() if n.get('cluster') in GONE_CL and n['kind'] in ('small', 'notable')}
def off(n):
    t = TH(n)
    A = min((0, 72, 144, 216, 288), key=lambda a: abs((t - a + 180) % 360 - 180))
    return (t - A + 180) % 360 - 180
def darkness_rim(n):
    t = TH(n)
    return abs(R(n) - 84) < 0.6 and (101.5 <= t <= 105.5 or 203.5 <= t <= 207.5)
keep = []
for e in M['edges']:
    a, b = N[e['a']], N[e['b']]
    if e['a'] in gone or e['b'] in gone:
        continue
    ra, rb = R(a), R(b)
    on_rim = abs(ra - 84) < 0.6 and abs(rb - 84) < 0.6
    if on_rim and not (darkness_rim(a) and darkness_rim(b)):
        continue
    # outer spokes past the outer ring (proposal links running outward between 74.3 and 84)
    if e.get('proposal') and min(ra, rb) > 74.0 and max(ra, rb) > 74.6 and max(ra, rb) < 84.6:
        o = abs(off(a))
        if abs(o - 24) < 0.6:
            continue                       # the offset-24 spoke goes
        if abs(o - 12) < 0.6 and min(ra, rb) > 78.5:
            continue                       # the offset-12 spoke keeps only its first link (a hook)
    keep.append(e)
used = {i for e in keep for i in (e['a'], e['b'])}
nodes = [n for n in M['nodes'] if n['id'] in used]
M['nodes'] = nodes; M['edges'] = keep
M['groups'] = [g for g in M.get('groups', []) if not (set(g.get('nodes', [])) & gone)]
M.pop('adds', None)
json.dump(M, open(sys.argv[2], 'w', encoding='utf-8'))
print('removed %d shape nodes; kept %d nodes and %d links' % (len(gone), len(nodes), len(keep)))
