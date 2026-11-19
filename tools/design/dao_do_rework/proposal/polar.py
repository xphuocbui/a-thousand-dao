"""Polar listing of a land's band (report only): nodes as (offset from the land axis in degrees, radius, kind, degree).
usage: polar.py <map.json> <land axis deg> <r_lo> <r_hi> [half-width deg]"""
import json, sys, math, collections
M = json.load(open(sys.argv[1], encoding='utf-8'))
A, lo, hi = float(sys.argv[2]), float(sys.argv[3]), float(sys.argv[4]); W = float(sys.argv[5]) if len(sys.argv) > 5 else 40
N = {n['id']: n for n in M['nodes']}
adj = collections.defaultdict(set)
for e in M['edges']: adj[e['a']].add(e['b']); adj[e['b']].add(e['a'])
off = lambda n: (math.degrees(math.atan2(n['x'], n['y'])) - A + 180) % 360 - 180
rad = lambda n: math.hypot(n['x'], n['y'])
rows = [n for n in M['nodes'] if lo <= rad(n) <= hi and abs(off(n)) <= W]
K = {'travel': 'r', 'small': 's', 'notable': 'N', 'start': 'S', 'keystone': 'K'}
for side, f in (('left (negative offsets, toward the left blend)', lambda o: o <= 0.5), ('right (positive offsets)', lambda o: o >= -0.5)):
    rs = sorted((n for n in rows if f(off(n)) and n['kind'] in ('travel', 'start', 'keystone')), key=lambda n: (round(off(n) / 4), rad(n)))
    print(side + ': road nodes (offset, r, degree)')
    print('   ' + '  '.join('(%+.1f,%.1f)%s%d' % (off(n), rad(n), '' if n['kind'] == 'travel' else K[n['kind']], len(adj[n['id']])) for n in rs))
cl = collections.defaultdict(list)
for n in rows:
    if n['kind'] in ('small', 'notable'): cl[n.get('cluster')].append(n)
print('figures in the band (offset span, radius span, nodes):')
for c, ns in sorted(cl.items(), key=lambda t: min(off(n) for n in t[1])):
    print('   cl%s offset %+.1f..%+.1f  r %.1f..%.1f  %d nodes' % (c, min(off(n) for n in ns), max(off(n) for n in ns), min(rad(n) for n in ns), max(rad(n) for n in ns), len(ns)))
