"""List the Đạo Đồ v5 pieces of one area for content authoring (observations only, never chooses content).

Usage: python -I pieces.py <dao-do-map.json> <area> [--json out.json]
Areas: fire earth metal water wood light thunder darkness hub chaos-fire chaos-earth chaos-metal chaos-water
chaos-wood border (border pieces of all lines).

For every piece (cluster of small and notable nodes): its key "c<cell> <piece>", tier (S/M/B), node ids in walk
order from the entry (BFS from the piece's nodes that touch a node outside the piece), kinds (s/n), the crown (the
notable farthest from the entry along the walk), radius, angle offset from the area's axis (start node), and the
mirror twin (same picture, same size, reflected across the axis) if any. Pair rule as in audit_clusters.py.
"""
import collections
import json
import math
import re
import sys

ISL = {'931': 'light', '932': 'thunder', '933': 'darkness'}
CH = {'1': 'wood', '2': 'earth', '3': 'fire', '4': 'metal', '5': 'water'}
START = {'fire': 'Fire start', 'earth': 'Earth start', 'metal': 'Metal start', 'water': 'Water start',
         'wood': 'Wood start', 'light': 'Light start (Quang)', 'thunder': 'Thunder start (Lôi)',
         'darkness': 'Darkness start (Ám)', 'hub': 'Chaos start (Hỗn Độn)'}


def area_of(region, name):
    cell = name.split(' ')[0][1:] if name.startswith('c') else ''
    if region == 'island':
        return ISL.get(cell, 'island?')
    if region == 'chaos':
        return 'hub' if cell == '79' else 'chaos-' + CH.get(cell, '?')
    if region.startswith('border'):
        return 'border'
    return region


def load(path):
    m = json.load(open(path, encoding='utf-8'))
    nodes = {n['id']: n for n in m['nodes']}
    adj = collections.defaultdict(set)
    for e in m['edges']:
        adj[e['a']].add(e['b']); adj[e['b']].add(e['a'])
    return m, nodes, adj


def pieces(m, nodes, adj, area):
    by = collections.defaultdict(list)
    for n in m['nodes']:
        if n['kind'] in ('small', 'notable') and n.get('cluster') is not None:
            by[n['cluster']].append(n)
    out = []
    for cid, v in by.items():
        nm = next((x['name'] for x in v if x.get('name')), '')
        if area_of(v[0]['region'], nm) != area:
            continue
        ids = {x['id'] for x in v}
        # a keystone hung off a piece is a dead end, not a way in (keystones added 2026-11-19 keep the walk unchanged)
        entry = [i for i in ids if any(j not in ids and nodes[j]['kind'] != 'keystone' for j in adj[i])]
        dist = {}
        q = collections.deque()
        for i in sorted(entry):
            dist[i] = 0; q.append(i)
        while q:
            i = q.popleft()
            for j in sorted(adj[i]):
                if j in ids and j not in dist:
                    dist[j] = dist[i] + 1; q.append(j)
        for i in ids:
            dist.setdefault(i, 99)
        order = sorted(ids, key=lambda i: (dist[i], i))
        nts = [i for i in order if nodes[i]['kind'] == 'notable']
        crown = max(nts, key=lambda i: (dist[i], i)) if nts else None
        cx = sum(x['x'] for x in v) / len(v); cy = sum(x['y'] for x in v) / len(v)
        key = nm.rsplit(' ', 1)[0] if nm else f'base{cid}'
        out.append(dict(cluster=cid, key=key, n=len(v), tier='S' if len(v) <= 5 else ('M' if len(v) <= 8 else 'B'),
                        order=order, kinds=''.join(nodes[i]['kind'][0] for i in order), entry=sorted(entry),
                        dist={i: dist[i] for i in order}, crown=crown, cx=cx, cy=cy, r=math.hypot(cx, cy),
                        named=bool(nm)))
    st = next((n for n in m['nodes'] if n['kind'] == 'start' and n.get('name') == START.get(area)), None)
    ax = math.atan2(st['y'], st['x']) if st else math.atan2(sum(p['cy'] for p in out), sum(p['cx'] for p in out))
    for p in out:
        p['off'] = (math.degrees(math.atan2(p['cy'], p['cx']) - ax) + 180) % 360 - 180
    # mirror pairs (same as audit_clusters.py): same size, reflected centroid within 3 units, same base name or cell
    c2, s2 = math.cos(2 * ax), math.sin(2 * ax)
    base = lambda p: re.sub(r'([ _]?(L|R|l|r|east|west|e|w))$', '', p['key'].split(' ', 1)[-1])
    used = set()
    if area != 'hub' and not area.startswith('chaos'):
        for p in sorted(out, key=lambda p: p['key']):
            if p['cluster'] in used or not p['named']:
                continue
            rx, ry = p['cx'] * c2 + p['cy'] * s2, p['cx'] * s2 - p['cy'] * c2
            if math.hypot(p['cx'] - rx, p['cy'] - ry) <= 1.0:
                continue
            best = None
            for q in out:
                if q is p or q['cluster'] in used or q['n'] != p['n'] or not q['named']:
                    continue
                if not (base(q) == base(p) or q['key'].split(' ')[0] == p['key'].split(' ')[0]):
                    continue
                d = math.hypot(q['cx'] - rx, q['cy'] - ry)
                if d < 3.0 and (best is None or d < best[0]):
                    best = (d, q)
            if best:
                q = best[1]; used |= {p['cluster'], q['cluster']}
                p['twin'] = q['key']; q['twin'] = p['key']
    return sorted(out, key=lambda p: (p['r'], p['key']))


def main():
    m, nodes, adj = load(sys.argv[1])
    area = sys.argv[2]
    ps = pieces(m, nodes, adj, area)
    if '--json' in sys.argv:
        json.dump(ps, open(sys.argv[sys.argv.index('--json') + 1], 'w', encoding='utf-8'), ensure_ascii=False)
    if '--big' in sys.argv:   # one line per big picture, a pair once
        seen = set()
        for p in ps:
            if p['tier'] != 'B' or p['key'] in seen:
                continue
            seen |= {p['key'], p.get('twin')}
            print(f"{p['key']} | {p['n']}/{p['kinds'].count('n')} | r{p['r']:.0f} | {p['off']:+.0f}"
                  + (f" | pair {p['twin'].split(' ')[0]}" if p.get('twin') else ''))
        return
    for p in ps:
        tw = f" twin={p['twin']}" if p.get('twin') else ''
        print(f"{p['tier']} {p['key']:<34} n={p['n']:>3} r={p['r']:5.1f} off={p['off']:+6.1f} crown={p['crown']} "
              f"{p['kinds']} ids={p['order'][0]}..{max(p['order'])}{tw}")


if __name__ == '__main__':
    main()
