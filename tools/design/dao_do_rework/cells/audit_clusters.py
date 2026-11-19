"""Count Đạo Đồ clusters per land (observations only, no verdicts).

Usage: python -I audit_clusters.py <dao-do-map.json> [--list]
Tiers (rules-2026-11-18 3.3): small 1-5 nodes, medium 6-8, big 9+. A mirrored pair (same picture, same size,
reflected across the land's axis through its start node, or the two halves of one cell's figure) counts once.
Bands by centroid radius: inner < 50, middle 50-69, rim >= 69. Unnamed pieces are start/base figures.
"""
import json, collections, math, sys, re
m = json.load(open(sys.argv[1], encoding='utf-8'))
ns = m['nodes']
starts = {n['region']: n for n in ns if n['kind'] == 'start'}
by = collections.defaultdict(list)
for n in ns:
    if n['kind'] in ('small', 'notable') and n.get('cluster') is not None:
        by[n['cluster']].append(n)
ISL = {'931': 'light', '932': 'thunder', '933': 'darkness'}
CH = {'1': 'wood', '2': 'earth', '3': 'fire', '4': 'metal', '5': 'water'}
def land(v):
    r = v[0]['region']; nm = next((x['name'] for x in v if x.get('name')), '')
    cell = nm.split(' ')[0][1:] if nm.startswith('c') else ''
    if r == 'island': return ISL.get(cell, 'island?')
    if r == 'chaos': return 'hub' if cell == '79' else 'chaos-' + CH.get(cell, '?')
    return r
pieces = []
for k, v in by.items():
    cx = sum(x['x'] for x in v) / len(v); cy = sum(x['y'] for x in v) / len(v)
    nm = next((x['name'] for x in v if x.get('name')), '')
    base = re.sub(r'([ _]?(L|R|l|r|east|west|e|w))$', '', ' '.join(nm.split(' ')[1:-1])) if nm else ''
    pieces.append(dict(id=k, land=land(v), n=len(v), nt=sum(x['kind'] == 'notable' for x in v), base=base, nm=nm,
                       cx=cx, cy=cy, r=math.hypot(cx, cy)))
# mirror pairs: same land, same size, centroid reflected across the land's axis (start angle or land centroid)
axis = {}
for L in set(p['land'] for p in pieces):
    ps = [p for p in pieces if p['land'] == L]
    sname = {'fire': 'Fire start', 'earth': 'Earth start', 'metal': 'Metal start', 'water': 'Water start',
             'wood': 'Wood start', 'light': 'Light start (Quang)', 'thunder': 'Thunder start (Lôi)',
             'darkness': 'Darkness start (Ám)'}.get(L)
    st = next((n for n in ns if n['kind'] == 'start' and n.get('name') == sname), None)
    if st: axis[L] = math.atan2(st['y'], st['x'])
    else:
        sx = sum(p['cx'] * p['n'] for p in ps); sy = sum(p['cy'] * p['n'] for p in ps)
        axis[L] = math.atan2(sy, sx)
def refl(x, y, a):
    c, s = math.cos(2 * a), math.sin(2 * a); return x * c + y * s, x * s - y * c
used = set(); pairs = 0
for p in pieces:
    if p['id'] in used or p['land'] == 'hub' or p['land'].startswith('chaos'): continue  # swirl arms and start motifs are not mirror pairs
    rx, ry = refl(p['cx'], p['cy'], axis[p['land']])
    best = None
    for q in pieces:
        if q['id'] == p['id'] or q['id'] in used or q['land'] != p['land'] or q['n'] != p['n'] or not p['base'] or not (q['base'] == p['base'] or q['nm'].split(' ')[0] == p['nm'].split(' ')[0]): continue
        d = math.hypot(q['cx'] - rx, q['cy'] - ry)
        if d < 3.0 and (best is None or d < best[0]): best = (d, q)
    if best and math.hypot(p['cx'] - rx, p['cy'] - ry) > 1.0:
        used |= {p['id'], best[1]['id']}; p['pair'] = best[1]['id']; best[1]['twin'] = True; pairs += 1
def tier(n): return 'S' if n <= 5 else ('M' if n <= 8 else 'B')
def band(p):
    if p['land'] in ('light', 'thunder', 'darkness') or p['land'].startswith('chaos') or p['land'] == 'hub': return '-'
    return 'inner' if p['r'] < 50 else ('middle' if p['r'] < 69 else 'rim')
out = collections.OrderedDict()
order = ['fire', 'earth', 'metal', 'water', 'wood', 'hub', 'light', 'thunder', 'darkness',
         'chaos-fire', 'chaos-earth', 'chaos-metal', 'chaos-water', 'chaos-wood']
print('land | pieces | S/M/B | distinct (pairs once) S/M/B | big distinct by band inner/middle/rim | notables (all) | notables in big')
for L in order + sorted(set(p['land'] for p in pieces) - set(order)):
    ps = [p for p in pieces if p['land'] == L]
    if not ps: continue
    t = collections.Counter(tier(p['n']) for p in ps)
    d = [p for p in ps if not p.get('twin')]
    td = collections.Counter(tier(p['n']) for p in d)
    bb = collections.Counter(band(p) for p in d if tier(p['n']) == 'B')
    print(f"{L} | {len(ps)} | {t['S']}/{t['M']}/{t['B']} | {td['S']}/{td['M']}/{td['B']} | "
          f"{bb['inner']}/{bb['middle']}/{bb['rim']}{' ('+str(bb['-'])+')' if bb['-'] else ''} | "
          f"{sum(p['nt'] for p in ps)} | {sum(p['nt'] for p in ps if tier(p['n'])=='B')}")
print('pairs found', pairs)
print('unnamed (start/base figures):', collections.Counter(p['land'] for p in pieces if not p['base']))
print('big pieces over 30 nodes:', [(p['land'], p['nm'].rsplit(' ',1)[0], p['n']) for p in pieces if p['n'] > 30])
ks = collections.Counter()
for n in ns:
    if n['kind'] == 'keystone':
        nm = n.get('name', ''); c = nm.split(' ')[0][1:] if nm.startswith('c') else ''
        ks[ISL.get(c, n['region'])] += 1
print('keystones', dict(ks))
if len(sys.argv) > 2 and sys.argv[2] == '--list':
    for L in order:
        ps = sorted([p for p in pieces if p['land'] == L and not p.get('twin') and tier(p['n']) == 'B' and p['base']],
                    key=lambda p: (p['r'], p['nm']))
        if not ps: continue
        print(f"\n### {L} ({len(ps)})\n\n| Cell | Picture | Nodes | Notables | Radius | Band | Pair |\n|---|---|---|---|---|---|---|")
        for p in ps:
            cell = p['nm'].split(' ')[0]
            pic = p['nm'].rsplit(' ', 1)[0].split(' ', 1)[1] if ' ' in p['nm'].rsplit(' ', 1)[0] else p['nm']
            print(f"| {cell} | {pic} | {p['n']} | {p['nt']} | {p['r']:.1f} | {band(p)} | {'yes' if p.get('pair') else ''} |")
