"""Cell division of a passive tree, one rule for every tree (report only).

usage: python -I cells2.py <tree_view dir> <out.json> ours:<map.json> poe2:<data.json> poe1:<data.json>

Walls = road nodes (PoE attribute / our travel nodes, plus starts) and every cluster that links to 2+ nodes outside
itself. A cell = a face of the wall graph whose boundary touches 2+ wall pieces (each road node is one piece, each
walling cluster one piece), so the loops inside one cluster are not cells. Clusters with one outside link hang inside
cells and are counted as the cell's contents. Coordinates: PoE as in the game (y down); ours flipped so Fire is at the
bottom, as in the editor.
"""
import collections
import json
import math
import sys

sys.path.insert(0, sys.argv[1])
import trees  # noqa: E402

OUR_STRIDE = 1.2


def load_poe1(path):
    d = json.load(open(path, encoding='utf-8'))
    c = d['constants']; radii = c['orbitRadii']
    A16 = [0, 30, 45, 60, 90, 120, 135, 150, 180, 210, 225, 240, 270, 300, 315, 330]
    A40 = [0, 10, 20, 30, 40, 45, 50, 60, 70, 80, 90, 100, 110, 120, 130, 135, 140, 150, 160, 170, 180, 190, 200,
           210, 220, 225, 230, 240, 250, 260, 270, 280, 290, 300, 310, 315, 320, 330, 340, 350]
    ang = [[math.radians(a) for a in A16] if n == 16 else [math.radians(a) for a in A40] if n == 40
           else [2 * math.pi * i / n for i in range(n)] for n in c['skillsPerOrbit']]
    groups = d['groups']
    nodes, edges = {}, set()
    for sid, n in d['nodes'].items():
        if not isinstance(n, dict) or 'group' not in n:
            continue
        if n.get('ascendancyName') or n.get('isProxy') or n.get('isBloodline') or n.get('isBlighted') \
                or n.get('isOnlyImage') or n.get('isMastery') or (n.get('expansionJewel') and not n.get('isJewelSocket')):
            continue
        g = groups.get(str(n['group']))
        if not g or g.get('isProxy'):
            continue
        o, i = n['orbit'], n['orbitIndex']
        a = ang[o][i]; r = radii[o]
        x, y = g['x'] + r * math.sin(a), g['y'] - r * math.cos(a)
        if 'classStartIndex' in n:
            t = 'start'
        elif n.get('isKeystone'):
            t = 'keystone'
        elif n.get('isJewelSocket'):
            t = 'jewel'
        elif n.get('isNotable'):
            t = 'notable'
        elif n.get('name') in ('Strength', 'Dexterity', 'Intelligence'):
            t = 'travel'
        else:
            t = 'small'
        nid = int(n.get('skill', sid))
        nodes[nid] = dict(x=x, y=y, t=t, g=int(n['group']), o=o)
        for m in n.get('out', []):
            edges.add(tuple(sorted((nid, int(m)))))
    edges = {e for e in edges if e[0] in nodes and e[1] in nodes and e[0] != e[1]}
    ids = sorted({k for e in edges for k in e})
    ix = {k: j for j, k in enumerate(ids)}
    same = [math.dist((nodes[a]['x'], nodes[a]['y']), (nodes[b]['x'], nodes[b]['y'])) for a, b in edges
            if nodes[a]['g'] == nodes[b]['g'] and nodes[a]['t'] == nodes[b]['t'] == 'small']
    same.sort(); s = OUR_STRIDE / same[len(same) // 2]
    out_n = [[nodes[k]['x'] * s, nodes[k]['y'] * s, nodes[k]['t'], ''] for k in ids]
    out_e = []
    for a, b in sorted(edges):
        na, nb = nodes[a], nodes[b]
        if na['g'] == nb['g'] and na['o'] == nb['o'] and na['o'] > 0:
            g = groups[str(na['g'])]
            out_e.append([ix[a], ix[b], g['x'] * s, g['y'] * s])
        else:
            out_e.append([ix[a], ix[b]])
    return dict(nodes=out_n, edges=out_e)


def analyse(T, flip=False, regions=None):
    P = [(n[0], -n[1] if flip else n[1]) for n in T['nodes']]
    K = [n[2] for n in T['nodes']]
    adj = collections.defaultdict(set); arc = {}
    for e in T['edges']:
        adj[e[0]].add(e[1]); adj[e[1]].add(e[0])
        if len(e) > 2:
            c = (e[2], -e[3] if flip else e[3]); arc[(e[0], e[1])] = arc[(e[1], e[0])] = c
    CL = {'small', 'notable'}   # jewel sockets act as road nodes (user, 2026-11-18)
    comp = {}
    for s0 in range(len(P)):
        if s0 in comp or K[s0] not in CL:
            continue
        comp[s0] = s0; q = [s0]
        for u in q:
            for v in adj[u]:
                if v not in comp and K[v] in CL:
                    comp[v] = s0; q.append(v)
    clusters = collections.defaultdict(list)
    for i, c in comp.items():
        clusters[c].append(i)
    ROAD = {i for i in range(len(P)) if K[i] in ('travel', 'start', 'jewel')}
    exits = {c: {v for i in mem for v in adj[i] if comp.get(v) != c} for c, mem in clusters.items()}
    wallcl = {c for c in clusters if len(exits[c]) >= 2}
    piece = {}
    for i in ROAD:
        piece[i] = ('r', i)
    for c in wallcl:
        for i in clusters[c]:
            piece[i] = ('c', c)
    W = set(piece)
    wadj = {i: [v for v in adj[i] if v in W] for i in W}

    def pts(u, v, step=0.3):
        a, b = P[u], P[v]; c = arc.get((u, v))
        if not c:
            return [a, b]
        r = math.dist(a, c); t1 = math.atan2(a[1] - c[1], a[0] - c[0]); t2 = math.atan2(b[1] - c[1], b[0] - c[0])
        dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi; n = max(2, int(abs(dt) * r / step))
        return [(c[0] + r * math.cos(t1 + dt * k / n), c[1] + r * math.sin(t1 + dt * k / n)) for k in range(n + 1)]

    def ang(u, v):
        # leaving direction at u, read about 1 unit along the link: GGG lets some arcs graze a straight road inside the
        # node icon, so the side a curve is on is the side it is on once it clears the node
        a, b = P[u], P[v]; c = arc.get((u, v))
        if not c:
            return math.atan2(b[1] - a[1], b[0] - a[0])
        r = math.dist(a, c); t1 = math.atan2(a[1] - c[1], a[0] - c[0]); t2 = math.atan2(b[1] - c[1], b[0] - c[0])
        dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        h = math.copysign(min(abs(dt) * 0.5, 1.0 / max(r, 1e-6)), dt)   # 1 unit out: past the node icon, where the eye reads it
        q = (c[0] + r * math.cos(t1 + h), c[1] + r * math.sin(t1 + h))
        return math.atan2(q[1] - a[1], q[0] - a[0])
    order = {u: sorted(wadj[u], key=lambda v: ang(u, v)) for u in wadj}
    used, faces = set(), []
    for u in wadj:
        for v in wadj[u]:
            if (u, v) in used:
                continue
            f = []; a, b = u, v
            while (a, b) not in used:
                used.add((a, b)); f.append((a, b))
                o = order[b]; k = o.index(a); a, b = b, o[(k - 1) % len(o)]
            faces.append(f)

    def area(pl):
        return sum(pl[i][0] * pl[i - 1][1] - pl[i - 1][0] * pl[i][1] for i in range(len(pl))) / 2
    F = []
    for f in faces:
        pl = []
        for a, b in f:
            pl += pts(a, b)[:-1]
        F.append((f, pl, area(pl)))
    outer = max(F, key=lambda t: abs(t[2]))
    sgn = 1 if outer[2] > 0 else -1
    inner = [k for k, (f, pl, A) in enumerate(F) if A * sgn < 0]
    isin = set(inner)
    hf = {}
    for k, (f, pl, A) in enumerate(F):
        for e in f:
            hf[e] = k

    def pe(a, b):   # which wall piece owns a link
        if comp.get(a) in wallcl:
            return ('c', comp[a])
        if comp.get(b) in wallcl:
            return ('c', comp[b])
        return ('r',)
    npieces = {k: {piece[a] for a, b in F[k][0]} for k in inner}
    ln = lambda a, b: sum(math.dist(p, q) for p, q in zip(pts(a, b), pts(a, b)[1:]))
    par = {k: k for k in inner}

    def find(x):
        while par[x] != x:
            par[x] = par[par[x]]; x = par[x]
        return x

    def union(x, y):
        par[find(x)] = find(y)
    def closed_without(c):
        # a cluster with 3+ exits is a hub (content, not a wall) when no road ends at it: every exit is a start, has
        # 2+ other wall neighbours, or begins a road stub that loops back to another exit of the same cluster
        mem = set(clusters[c])

        def ok(v):
            if K[v] == 'start':
                return True
            if v not in W:
                return False
            nb = [w for w in wadj[v] if w not in mem]
            if len(nb) >= 2:
                return True
            prev, cur, seen = v, (nb[0] if nb else None), 0
            while cur is not None and seen < 50:
                if cur in exits[c]:
                    return True
                nxt = [w for w in wadj[cur] if w != prev and w not in mem]
                if len(nxt) != 1:
                    return False
                prev, cur, seen = cur, nxt[0], seen + 1
            return False
        return all(ok(v) for v in exits[c])
    hubs = set() if regions else {c for c in wallcl if len(exits[c]) >= 3 and closed_without(c)}   # ours: the axis shapes are junctions by design, never hubs
    # 1. a hub (3+ exits) never splits a cell: join the faces on both sides of each of its links
    for k in inner:
        for a, b in F[k][0]:
            p = pe(a, b)
            j = hf.get((b, a))
            only = lambda f: {x for x in npieces[f] if x[0] == 'c'} <= {p}
            if p[0] == 'c' and p[1] in hubs and j in isin and len(npieces[k]) >= 2 and len(npieces[j]) >= 2 and 'start' not in (K[a], K[b]) and only(k) and only(j):
                union(k, j)
    # 2. a pocket (a face walled only by one 2-exit cluster and at most 2 road nodes) joins the face across that cluster
    for k in inner:
        cl = {x for x in npieces[k] if x[0] == 'c'}
        rn = [x for x in npieces[k] if x[0] == 'r']
        if len(cl) == 1 and len(rn) <= 2 and rn and abs(F[k][2]) < 25 and all(K[x[1]] != 'start' for x in rn):
            X = next(iter(cl))[1]
            across = collections.Counter()
            for a, b in F[k][0]:
                if pe(a, b) == ('c', X) and hf.get((b, a)) in isin and hf[(b, a)] != k:
                    across[hf[(b, a)]] += ln(a, b)
            if across:
                union(k, max(across, key=lambda j: abs(F[j][2])))
    # 3. a cluster's own loops (faces touching only that cluster) join the cell next to them
    # A start in the wall does not count here: a cluster's loop that touches a start is still that cluster's loop.
    # Repeated until nothing changes, so the order the loops are visited in does not matter.
    epieces = lambda mem: {x for k in mem for x in npieces[k] if not (x[0] == 'r' and K[x[1]] == 'start')}
    changed = True
    while changed:
        changed = False
        groups = collections.defaultdict(list)
        for k in inner:
            groups[find(k)].append(k)
        for g, mem in groups.items():
            if len(epieces(mem)) >= 2:
                continue
            ms = set(mem); across = collections.Counter(); mine = epieces(mem)
            for k in mem:
                for a, b in F[k][0]:
                    j = hf.get((b, a))
                    if j in isin and j not in ms:
                        tgt = groups[find(j)]
                        if len(epieces(tgt)) >= 2:
                            own = {x for x in epieces(tgt) if x[0] == 'c'} <= mine
                            across[find(j)] += ln(a, b) * (10 if own else 1)
            if across:
                union(g, max(across, key=across.get)); changed = True
                break
    groups = collections.defaultdict(list)
    for k in inner:
        groups[find(k)].append(k)
    cells = []
    for g, mem in groups.items():
        pcs = set().union(*(npieces[k] for k in mem))
        A = sum(abs(F[k][2]) for k in mem)
        if len(pcs) < 2 or A < 0.5:
            continue
        ms = set(mem)
        bound = [e for k in mem for e in F[k][0] if hf.get((e[1], e[0])) not in ms]
        L = [ln(a, b) for a, b in bound]
        per = sum(L) or 1e-9
        rl = sum(l for (a, b), l in zip(bound, L) if a in ROAD and b in ROAD)
        cx = cy = 0
        for k in mem:
            pl = F[k][1]; cA = 0; x_ = y_ = 0
            for i in range(len(pl)):
                (x0, y0), (x1, y1) = pl[i - 1], pl[i]; cr = x0 * y1 - x1 * y0; cA += cr; x_ += (x0 + x1) * cr; y_ += (y0 + y1) * cr
            if abs(cA) > 1e-9:
                w = abs(F[k][2]) / A; cx += x_ / (3 * cA) * w; cy += y_ / (3 * cA) * w
        big = max(mem, key=lambda k: abs(F[k][2]))
        cells.append(dict(f=bound, pls=[F[k][1] for k in mem], pl=F[big][1], a=A, per=per, c=(cx, cy),
                          roads=len({a for a, b in bound if a in ROAD}), rs=rl / per, att=[], faces=len(mem),
                          walls=len({piece[a] for a, b in bound if piece[a][0] == 'c' and piece[a][1] not in hubs}), cl=[]))
    cells.sort(key=lambda d: d['a'])

    def inside(p, pl):
        x, y = p; c = False
        for i in range(len(pl)):
            (x1, y1), (x2, y2) = pl[i - 1], pl[i]
            if (y1 > y) != (y2 > y) and x < x1 + (y - y1) * (x2 - x1) / (y2 - y1):
                c = not c
        return c
    loose = 0
    for c, mem in clusters.items():
        if c in wallcl and c not in hubs:
            continue
        m = (sum(P[i][0] for i in mem) / len(mem), sum(P[i][1] for i in mem) / len(mem))
        home = next((d for d in cells if any(inside(m, pl) for pl in d['pls'])), None)
        if home is None and c in hubs:
            home = next((d for d in cells if any(inside(P[i], pl) for i in mem for pl in d['pls'])), None)
        if home:
            home['cl'].append(len(mem))
            home['att'].append(sorted({('road' if v in ROAD else K[v] if K[v] in ('start', 'keystone') else 'wallcluster') for i in mem for v in adj[i] if comp.get(v) != c}))
        else:
            loose += 1
    # centre of the tree = mean of the starts (PoE) or 0,0 (ours)
    starts = [P[i] for i in range(len(P)) if K[i] == 'start']
    ctr = (0.0, 0.0) if regions else (sum(p[0] for p in starts) / len(starts), sum(p[1] for p in starts) / len(starts))
    R = max(math.dist(ctr, P[i]) for i in range(len(P)) if K[i] in ('travel', 'small', 'notable'))

    def simp(pl, tol=0.15):
        out = [pl[0]]
        for p in pl[1:]:
            if math.dist(p, out[-1]) >= tol:
                out.append(p)
        return out
    owner = {}
    for k, d in enumerate(cells):
        for a, b in d['f']:
            owner[(a, b)] = k
    for k, d in enumerate(cells):
        d['nb'] = sorted({owner.get((b, a)) for a, b in d['f'] if owner.get((b, a)) not in (None, k)})
    rnd = lambda v: round(v, 2)
    out_cells = []
    for k, d in enumerate(sorted(cells, key=lambda d: -d['a'])):
        land = ''
        if regions:
            rc = collections.Counter(regions[a] for a, b in d['f'] if regions[a])
            land = rc.most_common(1)[0][0] if rc else ''
        out_cells.append(dict(id=k + 1, a=round(d['a'], 1), roads=d['roads'], walls=d['walls'],
                              rnd=rnd(4 * math.pi * d['a'] / d['per'] ** 2), land=land,
                              r=round(math.dist(ctr, d['c']) / R, 3), dist=round(math.dist(ctr, d['c']), 1),
                              ncl=len(d['cl']), nn=sum(d['cl']), big=max(d['cl'], default=0), rs=round(d['rs'], 2), att=d['att'], cl=d['cl'], nbk=d['nb'], key=cells.index(d),
                              c=[rnd(d['c'][0]), rnd(d['c'][1])], p=[[rnd(x), rnd(y)] for x, y in simp(d['pl'])], ps=[[[rnd(x), rnd(y)] for x, y in simp(pl)] for pl in d['pls']], faces=d['faces']))
    lines = []
    for e in T['edges']:
        a, b = e[0], e[1]
        wc = comp.get(a) if comp.get(a) in wallcl else comp.get(b)
        kind = 'r' if a in ROAD and b in ROAD else ('w' if wc in wallcl and wc not in hubs else 'c')
        lines.append(dict(k=kind, p=[[rnd(x), rnd(y)] for x, y in pts(a, b, 0.45)]))
    return dict(cells=out_cells, lines=lines, nodes=[[rnd(P[i][0]), rnd(P[i][1]), K[i]] for i in range(len(P))],
                stats=dict(clusters=len(clusters), wall_clusters=len(wallcl - hubs), hubs=len(hubs), hanging_outside=loose, road_nodes=len(ROAD),
                           nodes=len(P), radius=round(R, 1)))


out = {}
for arg in sys.argv[3:]:
    name, path = arg.split(':', 1)
    if name == 'ours':
        T = trees.load_ours(path)[0]          # already flipped to screen; flip back so Fire sits at the bottom
        M = json.load(open(path, encoding='utf-8'))
        regs = [n.get('region') or '' for n in M['nodes']]
        D = analyse(T, flip=True, regions=regs)
        lands = collections.defaultdict(list)
        for n, r in zip(D['nodes'], regs):
            if r:
                lands[r].append(n)
        D['lands'] = {k: [round(sum(p[0] for p in v) / len(v), 1), round(sum(p[1] for p in v) / len(v), 1)] for k, v in lands.items()}
        big = [c for c in D['cells'] if c['a'] > 2000]
        D['outer'] = big; D['cells'] = [c for c in D['cells'] if c['a'] <= 2000]
        for k, c in enumerate(D['cells']):
            c['id'] = k + 1
    elif name == 'poe2':
        D = analyse(trees.load_poe2(path)[0]); D['lands'] = {}; D['outer'] = []
    else:
        D = analyse(load_poe1(path)); D['lands'] = {}; D['outer'] = []
    A = sorted(c['a'] for c in D['cells'])
    q = lambda f: A[min(len(A) - 1, int(f * len(A)))]
    cs = D['cells']
    print('%-5s cells %3d  area p10/50/90 %5.1f/%5.1f/%5.1f  empty %2d%%  clusters/cell p50/p90 %d/%d  nodes/cell p50/p90 %d/%d  %s' % (
        name, len(cs), q(.1), q(.5), q(.9), 100 * sum(c['ncl'] == 0 for c in cs) // max(1, len(cs)),
        sorted(c['ncl'] for c in cs)[len(cs) // 2], sorted(c['ncl'] for c in cs)[9 * len(cs) // 10],
        sorted(c['nn'] for c in cs)[len(cs) // 2], sorted(c['nn'] for c in cs)[9 * len(cs) // 10], D['stats']))
    out[name] = D
json.dump(out, open(sys.argv[2], 'w'), separators=(',', ':'))
