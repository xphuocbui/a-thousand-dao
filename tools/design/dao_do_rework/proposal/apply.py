"""Apply hand-placed cell proposals to a copy of a compiled map (compile only: it never chooses a position).

usage: python -I apply.py <map.json> <out.json> <proposal.json> [<proposal.json> ...]

Each add: {"kind": "road"|"wall", "pts": [[x, y], ...]} in the file frame, or "polar": [[offset_deg, r], ...] with
"land": <axis deg> (offset from that land's axis, 0 = Fire, 72 = Earth ...; x = r sin θ, y = r cos θ).
- The first and last points must sit within 0.45 of an existing node.
- Middle points become new nodes where written, or reuse an existing node within "snap" (default 0.45).
- "mirror": <land axis> also places the add reflected across that land's own axis (rules 3.10 B14); the reflection's
  middle points snap the same way, so it lands on that side's own nodes where there are any.
- Consecutive points at the same radius (within 0.05) are linked by an arc round the map centre; others straight.
- A link that already exists is not added twice.
- kind "cluster": a small figure placed by hand, with "node_kinds" (s or N per point) and "links" (index pairs).
- "curve": true with three points draws one smooth bend: both links lie on the circle through the three points.
- Where a new link crosses an existing road link, both are split at a junction node there (a computed crossing).
  Crossing a figure's link is reported and the add is refused.
road -> travel nodes, wall -> small nodes (a placeholder for a future cluster). Writes "adds" for the viewer.
"""
import json, math, sys

M = json.load(open(sys.argv[1], encoding='utf-8'))
nodes, edges = M['nodes'], M['edges']
byid = {n['id']: n for n in nodes}
nid = max(n['id'] for n in nodes) + 1
drawn, log, failed = [], [], []


def near(p, tol, roads_only=False):
    pool = [n for n in nodes if n['kind'] in ('travel', 'start')] if roads_only else nodes
    best = min(pool, key=lambda n: math.dist(p, (n['x'], n['y'])))
    return best if math.dist(p, (best['x'], best['y'])) <= tol else None


def polar(o, r, land):
    t = math.radians(land + o)
    return [r * math.sin(t), r * math.cos(t)]


def mirrored(a, land_deg):
    phi = math.radians(90 - land_deg); ux, uy = math.cos(phi), math.sin(phi)
    f = lambda p: [2 * (p[0] * ux + p[1] * uy) * ux - p[0], 2 * (p[0] * ux + p[1] * uy) * uy - p[1]]
    b = dict(a); b['pts'] = [f(p) for p in a['pts']]; b['mirror_of'] = True; b.pop('mirror', None)
    return b


def geom(e):
    a, b = byid[e['a']], byid[e['b']]
    if not e.get('arc'):
        return [(a['x'], a['y']), (b['x'], b['y'])]
    c = e['arc']; r = math.dist((a['x'], a['y']), c)
    t1 = math.atan2(a['y'] - c[1], a['x'] - c[0]); t2 = math.atan2(b['y'] - c[1], b['x'] - c[0])
    dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    n = max(2, int(abs(dt) * r / 0.15))
    return [(c[0] + r * math.cos(t1 + dt * k / n), c[1] + r * math.sin(t1 + dt * k / n)) for k in range(n + 1)]


def inter(p1, p2, p3, p4):
    d = (p2[0] - p1[0]) * (p4[1] - p3[1]) - (p2[1] - p1[1]) * (p4[0] - p3[0])
    if abs(d) < 1e-12:
        return None
    t = ((p3[0] - p1[0]) * (p4[1] - p3[1]) - (p3[1] - p1[1]) * (p4[0] - p3[0])) / d
    u = ((p3[0] - p1[0]) * (p2[1] - p1[1]) - (p3[1] - p1[1]) * (p2[0] - p1[0])) / d
    return (p1[0] + t * (p2[0] - p1[0]), p1[1] + t * (p2[1] - p1[1])) if 1e-6 < t < 1 - 1e-6 and 1e-6 < u < 1 - 1e-6 else None


def on_road_link(p, tol=0.6):   # within the 0.6 other-link gap of rule 3.2: join the road instead
    """the road link (and the nearest point on it) that p sits on, if any"""
    best = None
    for f in edges:
        fa, fb = byid[f['a']], byid[f['b']]
        if not (fa['kind'] in ('travel', 'start') and fb['kind'] in ('travel', 'start')):
            continue
        g = geom(f)
        for r, s_ in zip(g, g[1:]):
            vx, vy = s_[0] - r[0], s_[1] - r[1]; L = vx * vx + vy * vy
            t = max(0.0, min(1.0, ((p[0] - r[0]) * vx + (p[1] - r[1]) * vy) / L)) if L else 0.0
            q = (r[0] + t * vx, r[1] + t * vy); d = math.dist(p, q)
            if d <= tol and (best is None or d < best[0]) and math.dist(q, (fa['x'], fa['y'])) > 0.5 and math.dist(q, (fb['x'], fb['y'])) > 0.5:
                best = (d, f, q)
    return (best[1], best[2]) if best else None


def has(u, v):
    return any({e['a'], e['b']} == {u, v} for e in edges)


def link(u, v, kind):
    if u == v:
        return
    if has(u, v):     # an existing link the new road runs along: it now belongs to this add too
        for e in edges:
            if {e['a'], e['b']} == {u, v} and not e.get('proposal'):
                e['proposal'] = kind; e['reused'] = True
        return
    a, b = byid[u], byid[v]
    e = dict(a=u, b=v, proposal=kind)
    if abs(math.hypot(a['x'], a['y']) - math.hypot(b['x'], b['y'])) < 0.05:
        e['arc'] = [0.0, 0.0]
    edges.append(e)


def split_crossings(new_edges):
    """split every new link where it crosses an existing (older) link; road links only"""
    global nid
    changed = True
    while changed:
        changed = False
        for e in [e for e in edges if e in new_edges]:
            ge = geom(e)
            for f in edges:
                if f is e or f in new_edges or {e['a'], e['b']} & {f['a'], f['b']}:
                    continue
                gf = geom(f)
                hit = None
                for p, q in zip(ge, ge[1:]):
                    for r, s in zip(gf, gf[1:]):
                        hit = inter(p, q, r, s)
                        if hit: break
                    if hit: break
                if not hit:
                    continue
                fa, fb = byid[f['a']], byid[f['b']]
                if not (fa['kind'] in ('travel', 'start') and fb['kind'] in ('travel', 'start')):
                    sys.exit('refused: a new link crosses a figure link near (%.1f, %.1f)' % hit)
                # tidy 1: the crossing is within 1.0 of the crossed road's own node -> pass the new road through that node
                endp = min((fa, fb), key=lambda q: math.dist(hit, (q['x'], q['y'])))
                if math.dist(hit, (endp['x'], endp['y'])) < 1.0:
                    edges.remove(e); new_edges.remove(e)
                    for u, v in ((e['a'], endp['id']), (endp['id'], e['b'])):
                        if not has(u, v):
                            ne = dict(a=u, b=v, proposal=e['proposal']); edges.append(ne); new_edges.append(ne)
                    log.append('routed through the road node at (%.1f, %.1f) instead of crossing beside it' % (endp['x'], endp['y']))
                    changed = True
                    break
                # tidy 2: one of my own new waypoints is within 1.0 of the crossing -> move it onto the crossing
                mine = [byid[w] for w in (e['a'], e['b']) if byid[w].get('proposal') and math.dist(hit, (byid[w]['x'], byid[w]['y'])) < 1.0]
                if mine:
                    w = mine[0]; w['x'], w['y'] = hit
                    edges.remove(f)
                    for u, v in ((f['a'], w['id']), (w['id'], f['b'])):
                        ne = dict(a=u, b=v)
                        if f.get('proposal'): ne['proposal'] = f['proposal']
                        if f.get('arc'): ne['arc'] = f['arc']
                        edges.append(ne)
                    log.append('moved a waypoint onto the road it nearly touched at (%.1f, %.1f)' % hit)
                    changed = True
                    break
                j = dict(id=nid, x=hit[0], y=hit[1], kind='travel', region=fa.get('region'), proposal=True)
                nodes.append(j); byid[nid] = j; nid += 1
                log.append('junction at (%.1f, %.1f) on the road %s-%s' % (hit[0], hit[1], f['a'], f['b']))
                for old, kind in ((e, e['proposal']), (f, f.get('proposal'))):
                    edges.remove(old)
                    for u, v in ((old['a'], j['id']), (j['id'], old['b'])):
                        ne = dict(a=u, b=v)
                        if kind: ne['proposal'] = kind
                        if old.get('arc'): ne['arc'] = old['arc']
                        edges.append(ne)
                        if old is e: new_edges.append(ne)
                new_edges.remove(e)
                changed = True
                break
            if changed:
                break


for path in sys.argv[3:]:
    P = json.load(open(path, encoding='utf-8'))
    adds = []
    for a in P['adds']:
        if 'polar' in a:
            a = dict(a); a['pts'] = [polar(o, r, a['land']) for o, r in a['polar']]
        adds.append(a)
        if a.get('mirror') is not None:
            adds.append(mirrored(a, a['mirror']))
    for k, a in enumerate(adds):
        before = len(edges)
        if a['kind'] == 'cluster':
            # a small cluster placed by hand: its nodes ("node_kinds": s / N) and its own links ("links": index pairs)
            global_cl = max([n.get('cluster') or 0 for n in nodes if isinstance(n.get('cluster'), int)] + [0]) + 1
            ids = []
            for p, kd in zip(a['pts'], a['node_kinds']):
                n = dict(id=nid, x=float(p[0]), y=float(p[1]), kind='notable' if kd == 'N' else 'small', cluster=global_cl, proposal=True,
                         region=min(nodes, key=lambda m: math.dist(p, (m['x'], m['y']))).get('region'))
                nodes.append(n); byid[nid] = n; ids.append(nid); nid += 1
            for i, j in a['links']:
                edges.append(dict(a=ids[i], b=ids[j], proposal='cluster'))
            drawn.append(dict(k='pw', cell=None, twin=True, p=[[round(byid[i]['x'], 2), round(byid[i]['y'], 2)] for i in ids + ids[:1]]))
            continue
        ids = []
        for i, p in enumerate(a['pts']):
            end = i == 0 or (i == len(a['pts']) - 1 and not a.get('open'))   # an 'open' add may end on a new node (a hook)
            n = near(p, 1.2 if a.get('mirror_of') else 0.45) if end else near(p, a.get('snap', 0.45), roads_only=True)   # middle points never snap onto a figure; a mirrored end may land up to 1.2 off
            if end and n is None:
                failed.append('%s add %d (%s%s): end point (%.2f, %.2f) is not on a node' % (path, k, a.get('why', ''), ', mirrored' if a.get('mirror_of') else '', p[0], p[1]))
                ids = None
                break
            if end and math.dist(p, (n['x'], n['y'])) > 0.45:
                log.append('add %d: mirrored end snapped %.2f to (%.1f, %.1f)' % (k, math.dist(p, (n['x'], n['y'])), n['x'], n['y']))
            if n is None:
                ref = min(nodes, key=lambda m: math.dist(p, (m['x'], m['y'])))
                n = dict(id=nid, x=float(p[0]), y=float(p[1]), kind='travel' if a['kind'] == 'road' else 'small',
                         region=ref.get('region'), proposal=True)
                nodes.append(n); byid[nid] = n; nid += 1
                on = on_road_link(p)
                if on and a['kind'] == 'road':          # a point written on a road: it becomes that road's junction
                    f, q = on
                    n['x'], n['y'] = q
                    edges.remove(f)
                    for u, v in ((f['a'], n['id']), (n['id'], f['b'])):
                        ne = dict(a=u, b=v)
                        if f.get('proposal'): ne['proposal'] = f['proposal']
                        if f.get('arc'): ne['arc'] = f['arc']
                        edges.append(ne)
                    log.append('add %d: (%.1f, %.1f) sits on a road, made a junction there' % (k, q[0], q[1]))
            elif not end and math.dist(p, (n['x'], n['y'])) > 0.05:
                log.append('add %d: snapped (%.1f, %.1f) to the node at (%.1f, %.1f)' % (k, p[0], p[1], n['x'], n['y']))
            ids.append(n['id'])
        if ids is None:
            continue
        if a.get('curve') and len(ids) == 3:
            # one smooth bend: both links lie on the circle through the three points (PoE-style arc)
            (x1, y1), (x2, y2), (x3, y3) = [(byid[i]['x'], byid[i]['y']) for i in ids]
            d = 2 * (x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2))
            if abs(d) > 1e-9:
                cx = ((x1*x1 + y1*y1) * (y2 - y3) + (x2*x2 + y2*y2) * (y3 - y1) + (x3*x3 + y3*y3) * (y1 - y2)) / d
                cy = ((x1*x1 + y1*y1) * (x3 - x2) + (x2*x2 + y2*y2) * (x1 - x3) + (x3*x3 + y3*y3) * (x2 - x1)) / d
                for u, v in zip(ids, ids[1:]):
                    if u != v and not has(u, v):
                        edges.append(dict(a=u, b=v, proposal=a['kind'], arc=[cx, cy]))
            split_crossings(edges[before:])
            g = []
            for e in edges[before:]:
                g += geom(e)
            drawn.append(dict(k='p' if a['kind'] == 'road' else 'pw', cell=a.get('cell'), twin=bool(a.get('mirror') is not None or a.get('mirror_of')),
                              p=[[round(x, 2), round(y, 2)] for x, y in g]))
            continue
        for u, v in zip(ids, ids[1:]):
            link(u, v, a['kind'])
        split_crossings(edges[before:])
        drawn.append(dict(k='p' if a['kind'] == 'road' else 'pw', cell=a.get('cell'), twin=bool(a.get('mirror') is not None or a.get('mirror_of')),
                          p=[[round(byid[i]['x'], 2), round(byid[i]['y'], 2)] for i in ids]))
M['adds'] = drawn
json.dump(M, open(sys.argv[2], 'w', encoding='utf-8'))
for l in log:
    print('  ' + l)
for f in failed:
    print('FAILED ' + f)
print('adds', len(drawn), 'nodes now', len(nodes), 'links now', len(edges))
