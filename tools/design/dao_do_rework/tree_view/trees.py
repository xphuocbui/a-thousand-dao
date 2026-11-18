"""Load PoE 2's main passive tree and our compiled Đạo Đồ into one drawing form, and audit what was kept.

Started 2026-11-17 from poe_study/analyse.py. PoE 2 comes from GGG's own export (user 2026-11-17: use
grindinggear/poe2-skilltree-export): node positions and every arc centre are in the data, nothing is reconstructed.

Drawing form (screen frame, y grows downward, units = OUR map units):
  nodes: [x, y, type, name]           type: small | travel | notable | keystone | jewel | start
  edges: [a, b] straight, or [a, b, cx, cy] an arc round (cx, cy), the short way (never more than 180 degrees)

PoE 2 is scaled so its small-node stride matches ours (see scale_note()).

Usage: python -I trees.py poe2 <data.json>      prints the PoE 2 audit
       python -I trees.py ours <map.json>       prints the Đạo Đồ audit
"""
import collections
import json
import math
import re
import statistics
import sys

OUR_STRIDE = 1.2   # median small-small link inside one of our clusters (measured on the 2026-11-17 map: 1.20)


def _small_spacing(nodes, edges, same_group):
    """Median length of links between two small nodes of the same group (the tree's basic stride)."""
    L = [math.dist(nodes[a][:2], nodes[b][:2]) for a, b, *_ in edges
         if nodes[a][2] == 'small' and nodes[b][2] == 'small' and same_group(a, b)]
    return (statistics.median(L) if L else float('nan')), len(L)


def _clean(s):
    """GGG's text markup: [Tag|Shown] -> Shown, [Shown] -> Shown."""
    return re.sub(r'\[(?:[^\]|]*\|)?([^\]]*)\]', r'\1', s or '')


def load_poe2(path, scale=None):
    """GGG's export (data.json): every node carries x, y; every curved link carries its arc centre (orbitX, orbitY).
    Return (tree, audit); scale None = match our stride."""
    d = json.load(open(path, encoding='utf-8'))
    excluded = collections.Counter()
    # rules that find nothing in this export are still listed, so a zero reads as checked, not skipped
    for why in ('no group', 'cluster-jewel proxy / jewel internals (the export has no such fields)'):
        excluded[why] = 0
    kept = {}
    for sid, n in d['nodes'].items():
        if 'group' not in n:
            excluded['no group'] += 1
            continue
        if 'x' not in n or 'y' not in n:
            excluded['no position (%s)' % sid] += 1
            continue
        if n.get('ascendancyId'):
            excluded['ascendancy node (drawn in the ascendancy panel, not the main tree)'] += 1
            continue
        if n.get('isMastery'):
            excluded['mastery (background art in PoE 2, not an allocatable node)'] += 1
            continue
        if (n.get('unlockConstraint') or {}).get('ascendancy'):
            excluded['hidden until an ascendancy unlocks it (Oracle "Paths Not Taken")'] += 1
            continue
        if n.get('isBlighted'):
            excluded['isBlighted: jewel/anoint-only notable or socket, has no links'] += 1
            continue
        if n.get('isProxy') or n.get('expansionJewel') and not n.get('isJewelSocket'):
            excluded['cluster-jewel proxy / jewel internals'] += 1
            continue
        if n.get('classStartIndex') is not None:
            t = 'start'
        elif n.get('isKeystone'):
            t = 'keystone'
        elif n.get('isJewelSocket'):
            t = 'jewel'
        elif n.get('isNotable'):
            t = 'notable'
        elif n.get('isGenericAttribute'):
            t = 'travel'
        else:
            t = 'small'
        kept[int(sid)] = dict(x=n['x'], y=n['y'], t=t, g=n.get('group'), o=n.get('orbit', 0),
                              name=_clean(n.get('name')))
    links, dropped, arcs_bad = {}, collections.Counter(), 0
    for e in d['edges']:
        a, b = e['from'], e['to']
        if a == 'root' or b == 'root':
            dropped['link to the hidden root node'] += 1
            continue
        a, b = int(a), int(b)
        if a not in kept or b not in kept:
            dropped['other end excluded'] += 1
            continue
        if a == b:
            dropped['self link'] += 1
            continue
        k = (min(a, b), max(a, b))
        if k in links:
            dropped['listed twice'] += 1
            continue
        na, nb = kept[a], kept[b]
        if 'orbitX' in e:
            ctr, why = (e['orbitX'], e['orbitY']), 'arc (centre given by GGG)'
        elif 'orbit' not in e and na['g'] == nb['g'] and na['o'] == nb['o'] and na['o'] > 0:
            # same orbit of one group, no orbit field: the arc round the group centre (PoE 1 convention, as PoB draws)
            g = d['groups'][str(na['g'])]
            ctr, why = (g['x'], g['y']), 'arc on its group orbit (no field; implied)'
        else:
            ctr, why = None, 'straight' if 'orbit' not in e else 'straight (GGG marks "orbit": 0)'
        if ctr and abs(math.dist((kept[a]['x'], kept[a]['y']), ctr) - math.dist((kept[b]['x'], kept[b]['y']), ctr)) > 2:
            arcs_bad += 1
        links[k] = (ctr, why)
    deg = collections.Counter()
    for a, b in links:
        deg[a] += 1; deg[b] += 1
    for k in [k for k in kept if deg[k] == 0]:
        excluded['passed the filters but has no link: %s' % kept[k]['name']] += 1
    ids = sorted(k for k in kept if deg[k] > 0)
    ix = {k: j for j, k in enumerate(ids)}
    stride = None
    if scale is None:
        pre = [[kept[k]['x'], kept[k]['y'], kept[k]['t']] for k in ids]
        med, cnt = _small_spacing(pre, [[ix[a], ix[b]] for a, b in links],
                                  lambda a, b: kept[ids[a]]['g'] == kept[ids[b]]['g'])
        scale, stride = OUR_STRIDE / med, (med, cnt)
    nodes = [[kept[k]['x'] * scale, kept[k]['y'] * scale, kept[k]['t'], kept[k]['name']] for k in ids]
    edges, kinds = [], collections.Counter()
    for (a, b), (ctr, why) in sorted(links.items()):
        kinds[why] += 1
        edges.append([ix[a], ix[b], ctr[0] * scale, ctr[1] * scale] if ctr else [ix[a], ix[b]])
    used = {i for e in edges for i in e[:2]}
    audit = dict(source='GGG poe2-skilltree-export', tree=d.get('tree'), nodes=len(nodes), edges=len(edges),
                 types=dict(collections.Counter(n[2] for n in nodes)), edge_kinds=dict(kinds),
                 excluded=dict(excluded), links_dropped=dict(dropped), arc_endpoints_off_circle=arcs_bad,
                 nodes_without_edge=len(nodes) - len(used), scale=scale, stride=stride)
    return dict(nodes=nodes, edges=edges), audit


def load_ours(path):
    """Our compiled map: y up in the file, flipped here to the screen frame."""
    M = json.load(open(path, encoding='utf-8'))
    K = {'small': 'small', 'notable': 'notable', 'keystone': 'keystone', 'travel': 'travel', 'start': 'start',
         'jewel': 'jewel', 'socket': 'jewel'}
    ix = {n['id']: j for j, n in enumerate(M['nodes'])}
    other = collections.Counter()
    nodes = []
    for n in M['nodes']:
        t = K.get(n['kind'])
        if t is None:
            other[n['kind']] += 1; t = 'small'
        nodes.append([n['x'], -n['y'], t, n.get('name') or ''])
    edges, kinds, bad = [], collections.Counter(), 0
    for e in M['edges']:
        if e.get('dead'):
            kinds['dead (skipped)'] += 1
            continue
        a, b = ix[e['a']], ix[e['b']]
        if e.get('arc') is not None:
            c = (e['arc'][0], -e['arc'][1])
            if abs(math.dist(nodes[a][:2], c) - math.dist(nodes[b][:2], c)) > 0.05:
                bad += 1
            edges.append([a, b, c[0], c[1]]); kinds['arc'] += 1
        else:
            edges.append([a, b]); kinds['straight'] += 1
    used = {i for e in edges for i in e[:2]}
    grp_of = {}
    for gi, g in enumerate(M.get('groups', [])):
        for k in g['nodes']:
            grp_of[ix[k]] = gi
    med, cnt = _small_spacing(nodes, edges, lambda a, b: a in grp_of and grp_of.get(a) == grp_of.get(b))
    audit = dict(nodes=len(nodes), edges=len(edges), types=dict(collections.Counter(n[2] for n in nodes)),
                 edge_kinds=dict(kinds), unknown_kinds=dict(other), arc_endpoints_off_circle=bad,
                 nodes_without_edge=len(nodes) - len(used), stride=(med, cnt))
    return dict(nodes=nodes, edges=edges), audit


def scale_note(a2, ao):
    med, cnt = a2['stride']
    return ('PoE 2 small-to-small link inside a group: median %.1f PoE units (%d links). Ours: median %.2f map units '
            '(%d links). Scale = %.2f / %.1f = %.5f, so one PoE 2 stride draws exactly as long as one of ours.'
            % (med, cnt, ao['stride'][0], ao['stride'][1], OUR_STRIDE, med, a2['scale']))


if __name__ == '__main__':
    kind, path = sys.argv[1], sys.argv[2]
    tree, audit = (load_poe2 if kind == 'poe2' else load_ours)(path)
    print(json.dumps(audit, indent=1, ensure_ascii=False))
