"""Take every emblem off the clean base and the rim ring with it (compile only; the user's decision, 2026-11-18).

usage: python -I prune3.py <base3.json> <out.json>

User: the big emblems and the ring bends round them looked ugly; shrink the emblems to a literal small cluster per
land. Removes the land emblems (clusters 11-20) and the blend circles (21-29), keeping every start (land starts,
Ice, Wind, the islands' starts), and the rim ring at 84 except the two short pieces Darkness hangs on. Then drops
road nodes left with no links.
"""
import json, math, sys
M = json.load(open(sys.argv[1], encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
R = lambda n: math.hypot(n['x'], n['y'])
TH = lambda n: math.degrees(math.atan2(n['x'], n['y'])) % 360
gone = {i for i, n in N.items() if n['kind'] in ('small', 'notable') and n.get('cluster') in set(range(11, 30))}
def dk(n):
    return abs(R(n) - 84) < 0.6 and (101.5 <= TH(n) <= 105.5 or 203.5 <= TH(n) <= 207.5)
keep = []
for e in M['edges']:
    a, b = N[e['a']], N[e['b']]
    if e['a'] in gone or e['b'] in gone:
        continue
    if abs(R(a) - 84) < 0.6 and abs(R(b) - 84) < 0.6 and not (dk(a) and dk(b)):
        continue
    keep.append(e)
used = {i for e in keep for i in (e['a'], e['b'])}
M['nodes'] = [n for n in M['nodes'] if n['id'] in used]
M['edges'] = keep
M['groups'] = [g for g in M.get('groups', []) if not (set(g.get('nodes', [])) & gone)]
json.dump(M, open(sys.argv[2], 'w', encoding='utf-8'))
print('removed %d emblem nodes; %d nodes, %d links left' % (len(gone), len(M['nodes']), len(keep)))
