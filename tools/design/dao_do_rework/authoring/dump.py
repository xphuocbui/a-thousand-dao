"""Road nodes of a region in its frame (u, v), for authoring. usage: dump.py map.json region axis [cx cy] [extra regions]"""
import sys, json, math
M = json.load(open(sys.argv[1], encoding='utf-8'))
reg = sys.argv[2].split(','); ax = float(sys.argv[3])
cx, cy = (float(sys.argv[4]), float(sys.argv[5])) if len(sys.argv) > 5 else (0.0, 0.0)
t = math.radians(ax)
loc = lambda x, y: ((x - cx) * math.cos(t) - (y - cy) * math.sin(t), (x - cx) * math.sin(t) + (y - cy) * math.cos(t))
adj = {}
for e in M['edges']:
    adj.setdefault(e['a'], set()).add(e['b']); adj.setdefault(e['b'], set()).add(e['a'])
rows = []
for n in M['nodes']:
    if n['kind'] in ('travel', 'start') and n.get('region') in reg:
        u, v = loc(n['x'], n['y'])
        nb = sorted('%.1f,%.1f' % loc(M['nodes'][j]['x'], M['nodes'][j]['y']) for j in adj.get(n['id'], ()) if M['nodes'][j]['kind'] in ('travel', 'start'))
        rows.append((round(v, 1), round(u, 1), n['kind'], nb))
for v, u, k, nb in sorted(rows):
    print('(%5.1f, %5.1f) %s -> %s' % (u, v, k[0], ' '.join(nb)))
