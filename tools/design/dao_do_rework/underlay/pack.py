"""Builds the geometry pack sent to the OpenAI model (2026-11-19): per region its road nodes, fixed nodes, links, and
the v2 land / border pieces near it (to keep clear of). usage: python -I pack.py <out.json>"""
import json, math, sys
D = 'design/dao-do/cells/'
B = json.load(open(D + 'base-map.json', encoding='utf-8'))
V = json.load(open(D + 'out/v2night-map.json', encoding='utf-8'))
C = json.load(open(D + 'cells.json', encoding='utf-8'))['ours']['cells']
r3 = lambda v: round(v, 3)
VN = {n['id']: n for n in V['nodes']}
BOX = {'light': [(-17, 17, 94, 130)], 'thunder': [(-125, -80, -55, -14)],
       'darkness': [(-24, 24, -126, -82), (99, 117, -34, -15)], 'hub': [(-16.5, 16.5, -16.5, 16.5)]}
inbox = lambda n, reg: any(a <= n['x'] <= b and c <= n['y'] <= d for a, b, c, d in BOX[reg])
out = {}
for reg in BOX:
    ids = {n['id'] for n in B['nodes'] if n['region'] == reg and inbox(n, reg)}
    edges = [e for e in B['edges'] if e['a'] in ids or e['b'] in ids]
    ends = {x for e in edges for x in (e['a'], e['b'])}
    road = [[i, r3(VN[i]['x']), r3(VN[i]['y'])] for i in sorted(ends | ids) if VN[i]['kind'] == 'travel']
    fixed = [[i, r3(VN[i]['x']), r3(VN[i]['y']), VN[i]['kind']] for i in sorted(ends | ids) if VN[i]['kind'] != 'travel']
    lk = [[e['a'], e['b'], [r3(e['arc'][0]), r3(e['arc'][1])] if e.get('arc') else None] for e in edges]
    nb = {n['id'] for n in V['nodes'] if n.get('theme') not in (None, 'island', 'chaos') and inbox(n, reg)}
    nbl = [[e['a'], e['b'], [r3(e['arc'][0]), r3(e['arc'][1])] if e.get('arc') else None] for e in V['edges']
           if (e['a'] in nb or e['b'] in nb)]
    nbn = {x for e in nbl for x in e[:2]} | nb
    out[reg] = {'road_nodes [id,x,y]': road,
                'fixed_nodes_never_link [id,x,y,kind]': fixed,
                'road_links [a,b,arc_centre_or_null]': lk,
                'neighbour_pieces_keep_clear nodes [id,x,y,kind]': [[i, r3(VN[i]['x']), r3(VN[i]['y']), VN[i]['kind']] for i in sorted(nbn)],
                'neighbour_pieces_keep_clear links [a,b,arc_centre_or_null]': nbl}
    print(reg, len(road), len(fixed), len(lk), 'neighbours', len(nbn), len(nbl))
hub = {c['id']: c for c in C if c['id'] in (79, 80, 81, 82, 83)}
out['hub']['hub_cells {id: {land, polygon}}'] = {i: {'land': c['land'], 'polygon': [[r3(x), r3(y)] for x, y in c['p'][::3]]} for i, c in hub.items()}
json.dump(out, open(sys.argv[1], 'w'), separators=(',', ':'))
