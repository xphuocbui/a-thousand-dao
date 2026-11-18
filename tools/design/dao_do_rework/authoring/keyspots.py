"""Where a keystone could hang in one region (v2 review 2026-11-17: v1 had 10 keystones, 0.12 % of nodes, none off the
lands; PoE's are about 0.8 %). Lists road nodes of the region with the facings at which a keystone 2.2 out keeps PoE's
spacing: nothing within 1.8, at least 8 from any other keystone, 12 from any start, inside the region's limits, link
crossing nothing. Run it on a map compiled from roads and combos before fill. It lists; the author picks.
usage: keyspots.py map.json <spec json> [vmin] [--taken u,v ...]   (vmin: lands, the least v; discs, the least radius)"""
import sys, json, math
M = json.load(open(sys.argv[1], encoding='utf-8'))
spec = json.load(open(sys.argv[2], encoding='utf-8'))
args = [a for a in sys.argv[3:] if not a.startswith('--')]
VMIN = float(args[0]) if args else (spec.get('rmax', 20) * 0.45 if spec['kind'] == 'disc' else 55.0)
CX, CY, AX = spec.get('cx', 0.0), spec.get('cy', 0.0), spec['ax']
t = math.radians(AX)
loc = lambda x, y: ((x - CX) * math.cos(t) - (y - CY) * math.sin(t), (x - CX) * math.sin(t) + (y - CY) * math.cos(t))
reg = spec.get('region') or sys.argv[2].split('spec_')[-1].rsplit('.', 1)[0]
P = {n['id']: (n['x'], n['y']) for n in M['nodes']}
KIND = {n['id']: n['kind'] for n in M['nodes']}
keys = [P[i] for i, k in KIND.items() if k == 'keystone']
starts = [P[i] for i, k in KIND.items() if k == 'start']
segs = [(P[e['a']], P[e['b']]) for e in M['edges']]
o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])


def crosses(a, b):
    for p, q in segs:
        if p in (a, b) or q in (a, b):
            continue
        if o(a, b, p) * o(a, b, q) < 0 and o(p, q, a) * o(p, q, b) < 0:
            return True
    return False


def inside(u, v):
    if spec['kind'] == 'disc':
        return VMIN <= math.hypot(u, v) <= spec['rmax'] + 2
    return abs(math.degrees(math.atan2(u, v))) <= spec['lim'] and v >= VMIN and math.hypot(u, v) <= spec['rmax']


rows = []
for n in M['nodes']:
    if n['kind'] != 'travel' or n.get('region') != reg:
        continue
    p = P[n['id']]
    for f in range(0, 360, 15):
        q = (p[0] + 2.2 * math.sin(math.radians(f)), p[1] + 2.2 * math.cos(math.radians(f)))
        u, v = loc(*q)
        if not inside(u, v):
            continue
        clear = min(math.dist(q, r) for i, r in P.items() if i != n['id'])
        if clear < 1.8 or any(math.dist(q, k) < 8 for k in keys) or any(math.dist(q, s) < 12 for s in starts):
            continue
        if crosses(p, q):
            continue
        rows.append((round(clear, 2), loc(*p), (f - AX + 180) % 360 - 180, (u, v)))
best = {}
for r in rows:
    k = (round(r[1][0], 1), round(r[1][1], 1))
    if k not in best or r[0] > best[k][0]:
        best[k] = r
for r in sorted(best.values(), key=lambda r: -r[0])[:40]:
    print('road (%6.1f, %6.1f) facing %4d -> keystone (%6.1f, %6.1f) clear %.2f' % (r[1][0], r[1][1], r[2], r[3][0], r[3][1], r[0]))
