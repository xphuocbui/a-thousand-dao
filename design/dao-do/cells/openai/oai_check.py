"""Region-filtered report on a merged map (report only): crossings, spacing, two-entry R3, arc centres for the pieces of
the given cells. usage: python -I oai_check.py <map.json> <cell id> [...]"""
import collections, contextlib, io, json, math, runpy, sys
mp, cells = sys.argv[1], [int(c) for c in sys.argv[2:]]
with contextlib.redirect_stdout(io.StringIO()):
    sys.argv = ['audit', mp]
    G = runpy.run_path('tools/design/dao_do_rework/authoring/audit.py')
M, N, P, adj = G['M'], G['N'], G['P'], G['adj']
nm = lambda i: N[i].get('name') or (f"road {i}" if N[i]['kind'] == 'travel' else f"{N[i]['kind']} {i}")
mine = {i for i in N if any((N[i].get('name') or '').startswith(f'c{c} ') for c in cells)}
xy = lambda i: f"({P[i][0]:.2f}, {P[i][1]:.2f})"
ed = lambda k: f"link {nm(M['edges'][k]['a'])} -- {nm(M['edges'][k]['b'])}"
out = []
for k1, k2 in G['cross']:
    e1, e2 = M['edges'][k1], M['edges'][k2]
    if {e1['a'], e1['b'], e2['a'], e2['b']} & mine:
        out.append(f"CROSSING: {ed(k1)}  x  {ed(k2)}")
for lab, lst, lim in (('node too close to another piece/road node', G['close_other'], 0.9), ('own nodes too close', G['close_own'], 0.7)):
    for i, j, d in lst:
        if i in mine or j in mine:
            out.append(f"SPACING ({lab}, {d} < {lim}): {nm(i)} {xy(i)} and {nm(j)} {xy(j)}")
for lab, st, lim in (('node too close to another link', G['link_other'], 0.6), ('node too close to own link', G['link_own'], 0.45)):
    for (i, k), d in st.items():
        e = M['edges'][k]
        if i in mine or {e['a'], e['b']} & mine:
            out.append(f"SPACING ({lab}, {d} < {lim}): {nm(i)} {xy(i)} to {ed(k)}")
pcs = collections.defaultdict(set)
for i in mine: pcs[N[i]['name'].rsplit(' ', 1)[0]].add(i)
for p, S in pcs.items():
    doors = [(u, v) for v in S for u in adj[v] if u not in S]
    roads = {u for u, _ in doors}
    if any(N[u]['kind'] != 'travel' for u in roads):
        out.append(f"RULE: {p} links to a non-road node outside itself")
    if len(roads) > 2: out.append(f"RULE: {p} hangs from {len(roads)} road nodes (max 2)")
    if not any(N[i]['kind'] == 'notable' for i in S): out.append(f"RULE R4: {p} has no notable")
    for i in S:
        if N[i]['kind'] == 'small' and len(adj[i]) == 1: out.append(f"RULE R2: dead-end small {nm(i)}")
    for u, v in doors:
        seen, fr, d, hit = {v}, [v], 0, None
        while fr and hit is None:
            if any(N[x]['kind'] in ('notable', 'keystone') for x in fr): hit = d; break
            nx = [y for x in fr for y in adj[x] if y in S and y not in seen]; seen.update(nx); fr = nx; d += 1
        if hit is not None and hit < 2: out.append(f"RULE R3: {p}: a notable only {hit} step(s) in from road {u}")
    comp = {}
    for s0 in S:
        if s0 in comp: continue
        comp[s0] = s0; q = [s0]
        for a in q:
            for b in adj[a]:
                if b in S and b not in comp: comp[b] = s0; q.append(b)
    if len(set(comp.values())) > 1: out.append(f"RULE: {p} is not connected (in {len(set(comp.values()))} parts)")
for e in M['edges']:
    c = e.get('arc')
    if c and (e['a'] in mine or e['b'] in mine):
        d = abs(math.dist(c, P[e['a']]) - math.dist(c, P[e['b']]))
        if d > 0.005: out.append(f"ARC: centre not equidistant by {d:.3f}: link {nm(e['a'])} -- {nm(e['b'])}")
print(f"{len(mine)} nodes in {len(pcs)} pieces; {len(out)} issues")
print('\n'.join(out[:80]))
if len(out) > 80: print(f"... and {len(out) - 80} more")
