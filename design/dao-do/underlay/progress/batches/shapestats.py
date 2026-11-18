"""Report-only: how clusters are built, PoE 2 vs ours, measured the same way.
Cluster = connected component of small+notable(+jewel) nodes once road (travel/attribute), start and keystone nodes
are removed. usage: python -I shapestats.py <poe2 data.json> <our map.json>"""
import sys, json, math, collections
sys.path.insert(0, r'C:\Users\xphuo\IdeaProjects\my-game\tools\design\dao_do_rework\tree_view')
import trees

def comps(nodes, edges, inside):
    adj = collections.defaultdict(set)
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    seen, out = set(), []
    for i in range(len(nodes)):
        if i in seen or not inside(i):
            continue
        st, c = [i], set()
        seen.add(i)
        while st:
            u = st.pop(); c.add(u)
            for v in adj[u]:
                if v not in seen and inside(v):
                    seen.add(v); st.append(v)
        out.append(c)
    return out, adj

def wl(c, adj, kind, ext):
    lab = {i: kind(i) + ('E%d' % ext[i] if ext[i] else '') for i in c}
    for _ in range(3):
        lab = {i: lab[i] + '(' + ','.join(sorted(lab[j] for j in adj[i] if j in c)) + ')' for i in c}
        lab = {i: str(hash(l) & 0xffffff) for i, l in lab.items()}
    return hash(tuple(sorted(lab.values()))) & 0xffffffff

def study(name, xy, kind, edges, n):
    inside = lambda i: kind(i) in ('s', 'N')
    cs, adj = comps(range(n), edges, inside)
    R = collections.Counter(); sizes = []; forms = collections.Counter(); span = []
    leaf_minor = 0; minors = 0; r3 = collections.Counter(); ents = collections.Counter(); straight = 0
    for c in cs:
        k = len(c); sizes.append(k)
        e_in = sum(1 for i in c for j in adj[i] if j in c) // 2
        cyc = e_in - k + 1
        ext = {i: sum(1 for j in adj[i] if j not in c) for i in c}
        ne = sum(ext.values()); ents[min(ne, 4)] += 1
        maxdeg = max(sum(1 for j in adj[i] if j in c) for i in c)
        if k == 1: cls = 'single'
        elif cyc == 0 and maxdeg <= 2: cls = 'chain'
        elif cyc == 0: cls = 'branch'
        elif cyc == 1: cls = 'one loop'
        else: cls = 'multi-loop'
        R[cls] += 1
        nots = sum(1 for i in c if kind(i) == 'N')
        forms[wl(c, adj, kind, ext)] += 1
        pts = [xy(i) for i in c]
        sp = max((math.dist(a, b) for a in pts for b in pts), default=0); span.append(sp)
        for i in c:
            if kind(i) == 's':
                minors += 1
                if len(adj[i]) == 1: leaf_minor += 1
        # R3: steps from any entry node to the nearest notable
        doors = [i for i in c if ext[i]]
        if doors and nots:
            best = 99
            for d0 in doors:
                dist = {d0: 0}; q = collections.deque([d0])
                while q:
                    u = q.popleft()
                    for v in adj[u]:
                        if v in c and v not in dist:
                            dist[v] = dist[u] + 1; q.append(v)
                best = min(best, min(dist.get(i, 99) for i in c if kind(i) == 'N'))
            r3[min(best, 4)] += 1
        if k >= 3 and cyc == 0 and maxdeg <= 2:
            # how straight is a chain: end-to-end over path length
            pass
    T = len(cs)
    pc = lambda x: '%4.1f%%' % (100.0 * x / T)
    sizes.sort(); span.sort()
    print('==', name, ':', T, 'clusters')
    print('  size  median %d, p10 %d, p90 %d, max %d; share 1-2: %s, 3-5: %s, 6-9: %s, 10+: %s' % (
        sizes[T // 2], sizes[T // 10], sizes[9 * T // 10], sizes[-1], pc(sum(s <= 2 for s in sizes)),
        pc(sum(3 <= s <= 5 for s in sizes)), pc(sum(6 <= s <= 9 for s in sizes)), pc(sum(s >= 10 for s in sizes))))
    print('  span (units) p10 %.1f median %.1f p90 %.1f max %.1f' % (span[T // 10], span[T // 2], span[9 * T // 10], span[-1]))
    print('  topology  ' + ', '.join('%s %s' % (k, pc(v)) for k, v in R.most_common()))
    print('  links out 0/1/2/3/4+  ' + ' '.join(pc(ents[i]) for i in range(5)))
    print('  minor nodes that are dead ends (leaf): %d of %d (%.1f%%)' % (leaf_minor, minors, 100.0 * leaf_minor / max(minors, 1)))
    print('  steps door->nearest notable 0/1/2/3/4+  ' + ' '.join(pc(r3[i]) for i in range(5)))
    top = forms.most_common(8)
    print('  distinct structures %d; clusters in the 8 commonest: %s; each: %s' % (
        len(forms), pc(sum(v for _, v in top)), ' '.join(str(v) for _, v in top)))
    print('  structures used once: %s of clusters' % pc(sum(1 for v in forms.values() if v == 1)))

if __name__=='__main__':
  t, a = trees.load_poe2(sys.argv[1])
  pk = {'small': 's', 'notable': 'N', 'jewel': 'N'}
  study('PoE 2', lambda i: tuple(t['nodes'][i][:2]), lambda i: pk.get(t['nodes'][i][2], 'r'),
        [tuple(e[:2]) for e in t['edges']], len(t['nodes']))
  M = json.load(open(sys.argv[2], encoding='utf-8'))
  ok = {'small': 's', 'notable': 'N'}
  idx = {n['id']: j for j, n in enumerate(M['nodes'])}
  study('Ours', lambda i: (M['nodes'][i]['x'], M['nodes'][i]['y']), lambda i: ok.get(M['nodes'][i]['kind'], 'r'),
        [(idx[e['a']], idx[e['b']]) for e in M['edges']], len(M['nodes']))
  