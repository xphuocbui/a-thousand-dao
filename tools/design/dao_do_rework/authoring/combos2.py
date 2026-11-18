"""Which clusters read together (user 2026-11-16: combos come from the same travel node, adjacent, nearby or opposite
travel nodes). For every pair of visible clusters (2+ skill nodes) closer than CLOSE spacings: how their road nodes
relate, whether they sit on opposite sides of the road, whether they are the same figure; and the size of groups of
mutually close clusters.  usage: combos2.py <poe1 data.json> <poe2 tree.json> [ours.json]"""
import sys, math, collections
src = open('C:/Users/xphuo/IdeaProjects/my-game/tools/design/dao_do_rework/poe_study/analyse.py', encoding='utf-8').read().split("\nout = {}\n")[0]
ARGS = sys.argv[1:]
SKILL = ('small', 'notable', 'keystone', 'jewel')
CLOSE = 1.6


def load(P, G):
    sys.argv = ['x', P, P, '.']; ns = {}
    exec(compile(src, 'a', 'exec'), ns)
    return ns['load'](P, G)


def study(name, nodes, edges, unit=1 / 173.0):
    pt = {k: (v['x'] * unit, v['y'] * unit) for k, v in nodes.items()}
    kind = {k: v['t'] for k, v in nodes.items()}
    adj = collections.defaultdict(set)
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    comp, comps = {}, []
    for k in nodes:
        if kind[k] not in SKILL or k in comp:
            continue
        st, c = [k], []
        comp[k] = len(comps)
        while st:
            u = st.pop(); c.append(u)
            for v in adj[u]:
                if kind[v] in SKILL and v not in comp:
                    comp[v] = len(comps); st.append(v)
        comps.append(c)
    big = [i for i, c in enumerate(comps) if len(c) >= 2]
    road = lambda k: kind[k] == 'attribute'
    anchors = {i: {j for k in comps[i] for j in adj[k] if road(j)} for i in big}
    sig = {i: (len(comps[i]), sum(kind[k] == 'notable' for k in comps[i]),
               tuple(sorted(sum(1 for j in adj[k] if comp.get(j) == i) for k in comps[i]))) for i in big}
    cen = {i: (sum(pt[k][0] for k in comps[i]) / len(comps[i]), sum(pt[k][1] for k in comps[i]) / len(comps[i])) for i in big}
    # close pairs
    grid = collections.defaultdict(list)
    for i in big:
        for k in comps[i]:
            grid[(int(pt[k][0] // 2), int(pt[k][1] // 2))].append((k, i))
    close = set()
    for i in big:
        for k in comps[i]:
            gx, gy = int(pt[k][0] // 2), int(pt[k][1] // 2)
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    for k2, i2 in grid.get((gx + dx, gy + dy), ()):
                        if i2 > i and math.dist(pt[k], pt[k2]) < CLOSE:
                            close.add((i, i2))

    def hops(A, Bs, lim=4):
        seen = {a: 0 for a in A}; fr = list(A)
        for d in range(1, lim + 1):
            nx = []
            for u in fr:
                for v in adj[u]:
                    if road(v) and v not in seen:
                        seen[v] = d; nx.append(v)
            fr = nx
        return min((seen[b] for b in Bs if b in seen), default=99)

    def side(r, c):
        # which side of the road through r the cluster centre lies on (road direction: r's road neighbours)
        nb = [v for v in adj[r] if road(v)]
        if not nb:
            return 0
        if len(nb) >= 2:
            a, b = pt[nb[0]], pt[nb[1]]
        else:
            a, b = pt[r], pt[nb[0]]
        cr = (b[0] - a[0]) * (c[1] - pt[r][1]) - (b[1] - a[1]) * (c[0] - pt[r][0])
        return 1 if cr > 0 else -1

    rel = collections.Counter(); opp = collections.Counter(); same = collections.Counter(); face = collections.Counter()
    for i, j in close:
        A, Bs = anchors[i], anchors[j]
        if not A or not Bs:
            kind_ = 'joined by no road'
        elif A & Bs:
            kind_ = 'same road node'
        else:
            h = hops(A, Bs)
            kind_ = 'adjacent road nodes' if h == 1 else 'nearby (2-3 hops)' if h <= 3 else 'farther (4+ hops or none)'
        rel[kind_] += 1
        if kind_ in ('same road node', 'adjacent road nodes'):
            r = next(iter(A & Bs)) if A & Bs else next(iter(A))
            opp[kind_ + (', opposite sides' if side(r, cen[i]) != side(r, cen[j]) else ', same side')] += 1
        same[kind_] += sig[i] == sig[j]
        # which way each cluster grows out of its road: anchor -> centre; facing each other when the two directions
        # are 120+ degrees apart and the centres lie between the anchors
        if A and Bs:
            ai = min(A, key=lambda r: math.dist(pt[r], cen[i])); aj = min(Bs, key=lambda r: math.dist(pt[r], cen[j]))
            vi = (cen[i][0] - pt[ai][0], cen[i][1] - pt[ai][1]); vj = (cen[j][0] - pt[aj][0], cen[j][1] - pt[aj][1])
            ang = math.degrees(math.acos(max(-1, min(1, (vi[0] * vj[0] + vi[1] * vj[1]) / (math.hypot(*vi) * math.hypot(*vj) + 1e-9)))))
            between = math.dist(pt[ai], pt[aj]) > max(math.dist(pt[ai], cen[i]), math.dist(pt[aj], cen[j]))
            how = 'facing each other' if ang >= 120 and between and ai != aj else 'back to back' if ang >= 120 else 'splayed (60-120)' if ang >= 60 else 'side by side (<60)'
            face[(kind_, how)] += 1
    t = len(close)
    print(f"\n===== {name}: {len(big)} clusters, {t} close pairs (under {CLOSE} spacings) =====")
    for k, v in rel.most_common():
        print(f"  {k:28s} {v / t:5.0%}   same figure {same[k] / v:4.0%}")
    for k, v in sorted(opp.items()):
        print(f"    {k:42s} {v / t:5.0%}")
    tf = collections.Counter()
    for (k_, how), v in face.items():
        tf[how] += v
    print("  direction out of the road:", ', '.join(f"{h} {v / t:.0%}" for h, v in tf.most_common()))
    for (k_, how), v in sorted(face.items()):
        if how == 'facing each other':
            print(f"    facing each other, {k_}: {v / t:.0%}")
    # groups of mutually close clusters
    par = {i: i for i in big}
    def f(x):
        while par[x] != x:
            par[x] = par[par[x]]; x = par[x]
        return x
    for i, j in close:
        par[f(i)] = f(j)
    sizes = collections.Counter(collections.Counter(f(i) for i in big).values())
    tot = len(big)
    print("  clusters by size of their close group: " + ' '.join(f"{k}: {k * v / tot:.0%}" for k, v in sorted(sizes.items()) if k <= 6)
          + f" 7+: {sum(k * v for k, v in sizes.items() if k > 6) / tot:.0%}")
    pc = lambda x: '%d %%' % round(100 * x)
    return {'same': pc(rel['same road node'] / t), 'adj': pc(rel['adjacent road nodes'] / t),
            'near': pc(rel['nearby (2-3 hops)'] / t), 'far': pc((rel['farther (4+ hops or none)'] + rel['joined by no road']) / t),
            'side': pc(tf['side by side (<60)'] / t), 'splay': pc(tf['splayed (60-120)'] / t), 'facing': pc(tf['facing each other'] / t),
            'samefig': pc(sum(same.values()) / t), 'per': '%.2f' % (t / len(big)),
            'chain7': pc(sum(k * v for k, v in sizes.items() if k > 6) / tot)}


for name, P, G in (('PoE 1', ARGS[0], 1), ('PoE 2', ARGS[1], 2)):
    d, nodes, edges = load(P, G)
    study(name, nodes, edges)
if len(ARGS) > 2:
    import json
    M = json.load(open(ARGS[2], encoding='utf-8'))
    K = {'travel': 'attribute', 'start': 'start'}
    fire = lambda n: n.get('region') == 'fire' and n['y'] > 20
    nodes = {n['id']: {'x': n['x'] * 173, 'y': n['y'] * 173, 't': K.get(n['kind'], n['kind'])} for n in M['nodes'] if fire(n)}
    edges = [(e['a'], e['b']) for e in M['edges'] if e['a'] in nodes and e['b'] in nodes]
    study('Ours, Fire now', nodes, edges)
