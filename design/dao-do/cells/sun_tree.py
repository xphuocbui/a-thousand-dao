"""The Sun's tree (inside its outer ring), traced 2026-11-19 from the picked underlay (openai/underlay/sun/inout-3.png),
for sun_trace.py. The drawn lines were thinned to centre lines and joined into strokes (openai/underlay/sun/skel.py,
sun_build.py -> graph2-inout3.json); here:
  - each branch system hangs from the road node it springs from (an end within 1.3 of a road node links to it; at most
    two roads);
  - nodes re-spaced evenly (about 1.1) along every stroke; each pushed straight out to the spacing minimum (the Sun's looser rules, 3.2) from the
    roads and the axis if the drawing runs closer, and no further;
  - the small suns on the branch tips (bead rings too small to space nodes on) become rings of five round a notable
    centre, joined to the branch end beside them;
  - settling: where two branch systems (or a branch and its own mirror across the axis, or a flame) come closer than the
    spacing rules allow, the smaller system's leaf stroke there is dropped, never a trunk; the picture's root bundle is
    denser than the rules allow and thins to what fits;
  - leaf ends are notables; arcs run through the drawn line's midpoints.
"""
import json
import math
import os

HERE = os.path.dirname(os.path.abspath(__file__))
UD = os.path.join(HERE, 'openai', 'underlay', 'sun')
C0 = (0.0, 112.0)
S, N = 'small', 'notable'
SUNS = [(4.901, 101.397), (8.189, 103.975), (11.374, 110.491), (7.99, 119.058)]


def circum(a, b, c):
    ax, ay = a; bx, by = b; cx, cy = c
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    if abs(d) < 1e-9:
        return None
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return (ux, uy)


def segdist(p, a, b):
    vx, vy = b[0] - a[0], b[1] - a[1]; L2 = vx * vx + vy * vy
    t = max(0.0, min(1.0, ((p[0] - a[0]) * vx + (p[1] - a[1]) * vy) / L2)) if L2 else 0.0
    P = (a[0] + t * vx, a[1] + t * vy)
    return math.dist(p, P), P


def adjacency(links):
    A = {}
    for a, b, _ in links:
        A.setdefault(a, set()).add(b); A.setdefault(b, set()).add(a)
    return A


import sys as _sys
def _dbg(label, d):
    if os.environ.get('SUN_DEBUG'):
        print(label, sum(len(v[0]) for v in d.values()), 'nodes in', len(d), 'pieces', file=_sys.stderr)


def build_tree(roads, along, flames):
    """roads: {id: (x, y)} of the base map; along: the even-station helper of sun_trace; flames: the flame pieces
    (obstacles). Returns {piece name: (nodes, links)} for the right half."""
    G = json.load(open(os.path.join(UD, 'graph2-inout3.json')))
    dj = os.path.join(UD, 'sun_drops.json')
    DROPS = json.load(open(dj)) if os.path.exists(dj) else {'strokes': [], 'suns': []}
    GV = [tuple(v) for v in G['V']]
    RDS = {i: q for i, q in roads.items() if math.dist(q, C0) < 13.5}
    FIXED = [q for q in roads.values() if math.dist(q, C0) < 22]
    road_links = []
    for e in json.load(open(os.path.join(HERE, 'base-map.json'), encoding='utf-8'))['edges']:
        if e['a'] in roads and e['b'] in roads and math.dist(roads[e['a']], C0) < 22:
            A, B = roads[e['a']], roads[e['b']]; c = e.get('arc')
            if c:
                r = math.dist(A, c); t1 = math.atan2(A[1] - c[1], A[0] - c[0]); t2 = math.atan2(B[1] - c[1], B[0] - c[0])
                dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
                pl = [(c[0] + r * math.cos(t1 + dt * i / 30), c[1] + r * math.sin(t1 + dt * i / 30)) for i in range(31)]
            else:
                pl = [A, B]
            road_links += list(zip(pl, pl[1:]))

    def push(q, linked=()):
        for _ in range(40):
            moved = False
            for r in FIXED:
                if any(math.dist(r, x) < 1e-6 for x in linked):
                    continue
                d = math.dist(q, r)
                if d < 0.62:
                    f = (0.62 - d) / max(d, 1e-6); q = (q[0] + (q[0] - r[0]) * f, q[1] + (q[1] - r[1]) * f); moved = True
            for a, b in road_links:
                d, P = segdist(q, a, b)
                if d < 0.37:
                    f = (0.37 - d) / max(d, 1e-6); q = (q[0] + (q[0] - P[0]) * f, q[1] + (q[1] - P[1]) * f); moved = True
            if q[0] < 0.31:
                q = (0.31, q[1]); moved = True
            if not moved:
                break
        return q

    groups = []
    for g in G['groups']:
        pts = [tuple(q) for i in g for q in G['E'][i][2]]
        if sum(math.dist(q, C0) for q in pts) / len(pts) <= 13.0:
            groups.append({'edges': [list(G['E'][i]) + [i] for i in g]})   # each stroke keeps its own number
    def verts(gr):
        return {v for e in gr['edges'] for v in e[:2]}
    def attached(gr):
        return any(min(math.dist(RDS[j], GV[v]) for j in RDS) < 1.3 for v in verts(gr))
    # the masks round the rings cut trunks off from their roots: rejoin a floating system to the nearest end of an
    # attached one within 1.2 (a bridge on the drawn line's gap), else let it reach a road node within 2.6
    for _ in range(30):
        changed = False
        for gr in groups:
            if gr.get('gone') or attached(gr):
                continue
            best = None
            for g2 in groups:
                if g2 is gr or g2.get('gone') or not attached(g2):
                    continue
                for v in verts(gr):
                    for w in verts(g2):
                        d = math.dist(GV[v], GV[w])
                        if d < 1.2 and (best is None or d < best[0]):
                            best = (d, g2, v, w)
            if best:
                d, g2, v, w = best
                g2['edges'] += gr['edges'] + [[v, w, [GV[v], GV[w]], 100000 + v]]
                gr['gone'] = True; changed = True
        if not changed:
            break
    for gr in groups:
        if gr.get('gone') or attached(gr):
            continue
        d, v, j = min((math.dist(RDS[j], GV[v]), v, j) for v in verts(gr) for j in RDS)
        if d < 2.6:
            GV.append(RDS[j]); nv = len(GV) - 1
            gr['edges'].append([nv, v, [RDS[j], GV[v]], 200000 + v])
    tree = {}
    for gi, gr in enumerate(groups):
        if gr.get('gone'):
            continue
        edges = [e for e in gr['edges'] if min(math.dist(tuple(q), c) for q in e[2] for c in SUNS) > 0.95]
        _dg = {}
        for e in edges:
            _dg[e[0]] = _dg.get(e[0], 0) + 1; _dg[e[1]] = _dg.get(e[1], 0) + 1
        _onroad = lambda v: min(math.dist(RDS[j], GV[v]) for j in RDS) < 1.3
        _leaf = lambda e: (_dg[e[0]] == 1 and not _onroad(e[0])) or (_dg[e[1]] == 1 and not _onroad(e[1]))
        dropped = {d[1] for d in DROPS['strokes']}
        forced = set(DROPS.get('force', []))
        edges = [(e[3], e[:3]) for e in edges if not ((e[3] in dropped and _leaf(e)) or e[3] in forced)]
        if not edges:
            continue
        deg = {}
        for _, (a, b, _) in edges:
            deg[a] = deg.get(a, 0) + 1; deg[b] = deg.get(b, 0) + 1
        att = {}
        for v in deg:
            j = min(RDS, key=lambda k: math.dist(RDS[k], GV[v]))
            if math.dist(RDS[j], GV[v]) < 1.3 and deg[v] == 1:
                att[v] = j
        if not att:
            continue
        if len(set(att.values())) > 2:
            keep = sorted(att, key=lambda v: math.dist(RDS[att[v]], GV[v]))[:2]
            att = {v: att[v] for v in keep}
        nodes, links = {}, []                                  # links carry the drawn line's midpoint for now
        vkey = {v: att[v] if v in att else f'v{v}' for v in deg}
        for v in deg:
            if v not in att:
                nodes[vkey[v]] = (push(GV[v]), N if deg[v] == 1 else S)
        for ei, (a, b, pl) in edges:
            pl = [tuple(q) for q in pl]
            A = RDS[att[a]] if a in att else GV[a]
            Bp = RDS[att[b]] if b in att else GV[b]
            pl = [A] + pl[1:-1] + [Bp]
            L = sum(math.dist(x, y) for x, y in zip(pl, pl[1:]))
            if L < 0.55:
                links.append((vkey[a], vkey[b], None)); continue
            pts, ts, at = along(pl, step=0.75, first=(0.65 if a in att else 0.7))
            pts, ts = pts[:-1], ts[:-1]
            keys = [vkey[a]]
            for i, q in enumerate(pts):
                k = f'e{ei}_{i}'
                lk = (RDS[att[a]],) if (i == 0 and a in att) else ()
                lk += (RDS[att[b]],) if (i == len(pts) - 1 and b in att) else ()
                nodes[k] = (push(q, lk), S); keys.append(k)
            keys.append(vkey[b])
            tt = [0.0] + ts + [L]
            for i in range(len(keys) - 1):
                links.append((keys[i], keys[i + 1], at((tt[i] + tt[i + 1]) / 2)))
        tree[f'branch_{gi}'] = (nodes, links)

    _dbg('build', tree if 'build' != 'split' else out)
    for si, Cs in enumerate(SUNS):                             # the small suns
        if si in DROPS['suns']:
            continue
        found = [(math.dist(q, Cs), nm, kk) for nm, (nd, lk) in tree.items() for kk, (q, kd) in nd.items()]
        if not found:
            continue
        d, name, k = min(found)
        nodes, links = tree[name]
        a0 = math.degrees(math.atan2(nodes[k][0][0] - Cs[0], nodes[k][0][1] - Cs[1]))
        ring = []
        for i in range(5):
            t = math.radians(a0 + 72 * i); rk = f'sun{si}_{i}'
            nodes[rk] = ((Cs[0] + 0.65 * math.sin(t), Cs[1] + 0.65 * math.cos(t)), S); ring.append(rk)
        links += [(ring[i], ring[(i + 1) % 5], ('C', Cs)) for i in range(5)]
        nodes[f'sun{si}_c'] = (Cs, N)
        links.append((ring[2], f'sun{si}_c', None))
        if nodes[k][1] == N:
            nodes[k] = (nodes[k][0], S)
        links.append((k, ring[0], None))

    _dbg('suns', tree if 'suns' != 'split' else out)
    flame_pts = [q for nm, (nd, lk) in flames.items() for k, (q, kd) in nd.items()]
    flame_pts += [(-q[0], q[1]) for q in flame_pts]

    def leaf_stroke(nodes, links, k):
        A = adjacency(links)
        if k.startswith('sun'):
            return None
        if k.startswith('v'):
            if len(A.get(k, ())) == 1:
                return {k} | {y for y in A[k] if isinstance(y, str) and y.startswith('e')
                              and set(z for z in nodes if z.startswith(y.split('_')[0] + '_'))}
            return None
        st = k.split('_')[0]
        ks = {x for x in nodes if x.startswith(st + '_')}
        ends = {y for x in ks for y in A.get(x, ()) if y not in ks}
        leaves = [y for y in ends if isinstance(y, str) and len(A.get(y, ())) == 1]
        return ks | set(leaves) if leaves else None

    for _ in range(400):
        items = [(nm, k, q) for nm, (nd, lk) in tree.items() for k, (q, kd) in nd.items()]
        bad = None
        for nm, k, q in items:
            if any(math.dist(q, o) < 0.62 for o in flame_pts):
                bad = (nm, k); break
            for nm2, k2, q2 in items:
                if (nm2 != nm and math.dist(q, q2) < 0.62) or math.dist(q, (-q2[0], q2[1])) < 0.62:
                    bad = (nm, k) if len(tree[nm][0]) <= len(tree[nm2][0]) else (nm2, k2); break
            if bad:
                break
        if not bad:
            break
        nm, k = bad
        nodes, links = tree[nm]
        drop = leaf_stroke(nodes, links, k)
        if drop is None:                                       # a trunk: nudge it apart instead
            q = nodes[k][0]
            others = [o for o in flame_pts] + [q2 for n2, k2, q2 in items if (n2 != nm)] + [(-q2[0], q2[1]) for n2, k2, q2 in items]
            o = min((x for x in others if math.dist(x, q) > 1e-6), key=lambda x: math.dist(x, q))
            d = math.dist(q, o); f = (0.65 - d) / max(d, 1e-6)
            nodes[k] = (push((q[0] + (q[0] - o[0]) * f, q[1] + (q[1] - o[1]) * f)), nodes[k][1])
            continue
        nodes = {x: v for x, v in nodes.items() if x not in drop}
        links = [l for l in links if not any(isinstance(y, str) and y in drop for y in l[:2])]
        A = adjacency(links); seen = set(); fr = [x for x in A if isinstance(x, int)]
        while fr:
            u = fr.pop()
            for w in A.get(u, ()):
                if w not in seen:
                    seen.add(w); fr.append(w)
        nodes = {x: v for x, v in nodes.items() if x in seen}
        links = [l for l in links if all(isinstance(y, int) or y in nodes for y in l[:2])]
        if nodes:
            tree[nm] = (nodes, links)
        else:
            del tree[nm]

    _dbg('settle', tree if 'settle' != 'split' else out)
    for nm, (nodes, links) in list(tree.items()):              # repair: links over own nodes, links grazing roads
        for _ in range(50):
            pos = lambda x: roads[x] if isinstance(x, int) else nodes[x][0]
            changed = False
            for li, (a, b, m) in enumerate(links):
                path = [pos(a)] + ([m] if isinstance(m, tuple) and len(m) == 2 and not isinstance(m[0], str) else []) + [pos(b)]
                segs = list(zip(path, path[1:]))
                for x, (q, kd) in nodes.items():
                    if x in (a, b):
                        continue
                    d, P = min(segdist(q, u, v) for u, v in segs)
                    if d < 0.15 and 0.2 < math.dist(P, pos(a)) and 0.2 < math.dist(P, pos(b)):
                        links[li:li + 1] = [(a, x, None), (x, b, None)]; changed = True; break
                if changed:
                    break
                for r in FIXED:
                    if any(math.dist(r, pos(y)) < 1e-6 for y in (a, b)):
                        continue
                    d, P = min(segdist(r, u, v) for u, v in segs)
                    if d < 0.38:
                        for y in (a, b):
                            if isinstance(y, str):
                                q = nodes[y][0]; dd = math.dist(q, r) or 1e-6
                                f = (0.42 - d) / dd
                                nodes[y] = ((q[0] + (q[0] - r[0]) * f, q[1] + (q[1] - r[1]) * f), nodes[y][1])
                        if len(path) == 3:                     # the drawn midpoint too
                            dd = math.dist(m, r) or 1e-6; f = (0.45 - d) / dd
                            links[li] = (a, b, (m[0] + (m[0] - r[0]) * f, m[1] + (m[1] - r[1]) * f))
                        changed = True; break
                if changed:
                    break
            if not changed:
                break
        tree[nm] = (nodes, links)
    for nm, (nodes, links) in list(tree.items()):              # thin re-spaced nodes crowding their own figure
        for _ in range(200):
            A = adjacency(links)
            pos = lambda x: roads[x] if isinstance(x, int) else nodes[x][0]
            bad = None
            for x, (q, kd) in nodes.items():
                if not x.startswith('e') or len(A.get(x, ())) != 2 or x in locals().get('_skip', ()):
                    continue
                if any(y != x and y not in A[x] and math.dist(q, pos(y)) < 0.52 for y in nodes):
                    bad = x; break
                if any(x not in (a, b) and segdist(q, pos(a), pos(b))[0] < 0.32 for a, b, _ in links):
                    bad = x; break
            if not bad:
                break
            u, w = sorted(A[bad], key=str)
            if any(y not in (u, w, bad) and segdist(nodes[y][0], pos(u), pos(w))[0] < 0.35 for y in nodes):
                nodes[bad] = (nodes[bad][0], nodes[bad][1]); skip = locals().setdefault('_skip', set()); skip.add(bad)
                if len(skip) > 400:
                    break
                # leave it, and stop considering it
                links = links
                A = adjacency(links)
                continue
            mid = nodes.pop(bad)[0]
            links = [l for l in links if bad not in l[:2]] + [(u, w, mid)]
        tree[nm] = (nodes, links)
    for nm, (nodes, links) in list(tree.items()):
        A = adjacency(links)
        for x in nodes:
            if len(A.get(x, ())) == 1:
                nodes[x] = (nodes[x][0], N)
        out = []
        for a, b, m in links:
            P0 = roads[a] if isinstance(a, int) else nodes[a][0]
            P1 = roads[b] if isinstance(b, int) else nodes[b][0]
            if isinstance(m, tuple) and len(m) == 2 and m[0] == 'C':
                out.append((a, b, m[1])); continue
            c = circum(P0, m, P1) if m else None
            out.append((a, b, c if c is not None and math.dist(c, P0) < 40 else None))
        tree[nm] = (nodes, out)
    # split a system that broke into parts meeting only at a road; then the two-smalls rule from each road
    out = {}
    for nm, (nodes, links) in tree.items():
        A = adjacency([l for l in links if not isinstance(l[0], int) and not isinstance(l[1], int)])
        comp = {}
        for x in nodes:
            if x in comp:
                continue
            comp[x] = x; st = [x]
            while st:
                u = st.pop()
                for w in A.get(u, ()):
                    if w not in comp:
                        comp[w] = x; st.append(w)
        parts = sorted(set(comp.values()))
        for pi, root in enumerate(parts):
            nd = {x: v for x, v in nodes.items() if comp[x] == root}
            lk = [l for l in links if any(isinstance(y, str) and y in nd for y in l[:2])]
            if any(isinstance(y, int) for l in lk for y in l[:2]):
                out[nm if len(parts) == 1 else f'{nm}p{pi}'] = (nd, lk)
    _dbg('split', out)
    # the two-smalls rule from each road: a too-near notable that is not a leaf becomes a small; a too-near leaf
    # loses its stroke (only that stroke)
    for nm in list(out):
        for _ in range(20):
            nodes, links = out[nm]
            A = adjacency(links)
            near = []
            for door in {y for l in links for y in l[:2] if isinstance(y, int)}:
                seen = {door}; fr = [door]
                for d in (1, 2):
                    nxt = []
                    for u in fr:
                        for w in A.get(u, ()):
                            if w in seen or isinstance(w, int):
                                continue
                            seen.add(w); nxt.append(w)
                            if nodes[w][1] == N:
                                near.append(w)
                    fr = nxt
            if not near:
                break
            for w in near:
                if len(A.get(w, ())) > 1:
                    nodes[w] = (nodes[w][0], S)
            leaves = [w for w in near if len(A.get(w, ())) == 1]
            if not leaves:
                continue
            drop = set()
            for w in leaves:
                st = leaf_stroke(nodes, links, w)
                drop |= st if st else {w}
            nodes = {x: v for x, v in nodes.items() if x not in drop}
            links = [l for l in links if not any(isinstance(y, str) and y in drop for y in l[:2])]
            A = adjacency(links); seen = set(); fr = [x for x in A if isinstance(x, int)]
            while fr:
                u = fr.pop()
                for w in A.get(u, ()):
                    if w not in seen:
                        seen.add(w); fr.append(w)
            nodes = {x: v for x, v in nodes.items() if x in seen}
            links = [l for l in links if all(isinstance(y, int) or y in nodes for y in l[:2])]
            A = adjacency(links)
            for x in nodes:
                if len(A.get(x, ())) == 1:
                    nodes[x] = (nodes[x][0], N)
            if nodes:
                out[nm] = (nodes, links)
            else:
                del out[nm]; break
    _dbg('twosmalls', out)
    for nm, (nodes, links) in out.items():                     # every piece a notable: its farthest node
        if not any(kd == N for _, kd in nodes.values()):
            A = adjacency(links); dist = {}
            fr = [y for l in links for y in l[:2] if isinstance(y, int)]
            for d0 in fr:
                dist[d0] = 0
            while fr:
                u = fr.pop(0)
                for w in A.get(u, ()):
                    if w not in dist:
                        dist[w] = dist[u] + 1; fr.append(w)
            far = max((x for x in nodes), key=lambda x: dist.get(x, 0))
            if dist.get(far, 0) >= 3:
                nodes[far] = (nodes[far][0], N)
    return {nm: pc for nm, pc in out.items() if any(kd == N for _, kd in pc[0].values())}
