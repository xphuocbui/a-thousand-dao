"""Report-only: test each rule of rules-2026-11-18.md against PoE 2's graph. usage: python -I rulecheck.py <data.json>"""
import sys, os, json, math, collections
sys.path.insert(0, r'C:\Users\xphuo\IdeaProjects\my-game\tools\design\dao_do_rework\tree_view'); sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import trees
from shapestats import comps
from repeat3 import hull, inside
t, a = trees.load_poe2(sys.argv[1]); NN = t['nodes']; n = len(NN)
xy = lambda i: (NN[i][0], NN[i][1]); K = lambda i: NN[i][2]
pk = {'small': 's', 'notable': 'N', 'jewel': 'N'}; kind = lambda i: pk.get(K(i), 'r')
adj = collections.defaultdict(set)
for e in t['edges']: adj[e[0]].add(e[1]); adj[e[1]].add(e[0])
cs, _ = comps(range(n), [tuple(e[:2]) for e in t['edges']], lambda i: kind(i) in ('s', 'N'))
cl_of = {i: k for k, c in enumerate(cs) for i in c}
pc = lambda x, T: '%.1f%%' % (100.0 * x / max(T, 1))
def arcpts(pa, pb, cc, m=8):
    r = math.dist(pa, cc); t1 = math.atan2(pa[1] - cc[1], pa[0] - cc[0]); t2 = math.atan2(pb[1] - cc[1], pb[0] - cc[0]); dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    return [(cc[0] + r * math.cos(t1 + dt * k / m), cc[1] + r * math.sin(t1 + dt * k / m)) for k in range(m + 1)]
G = 2.0
grid = collections.defaultdict(list)
for i in range(n): grid[(int(xy(i)[0] // G), int(xy(i)[1] // G))].append(i)
def near(p, r):
    for gx in range(int((p[0] - r) // G), int((p[0] + r) // G) + 1):
        for gy in range(int((p[1] - r) // G), int((p[1] + r) // G) + 1):
            for i in grid.get((gx, gy), ()):
                d = math.dist(p, xy(i))
                if d < r: yield i, d
print('PoE 2 graph: %d nodes, %d links, %d clusters, kinds %s' % (n, len(t['edges']), len(cs), dict(collections.Counter(K(i) for i in range(n)))))

print('\n[R2 R3 R4] cluster rules')
dead = [i for i in range(n) if kind(i) == 's' and len(adj[i]) == 1]
print('  R2 dead-end minor nodes: %d of %d minors; clusters with one: %d of %d' % (dead.__len__(), sum(kind(i) == 's' for i in range(n)), len({cl_of[i] for i in dead}), len(cs)))
nonot = [c for c in cs if not any(kind(i) == 'N' for i in c)]
print('  R4 clusters with no notable: %d (sizes %s)' % (len(nonot), [len(c) for c in nonot][:10]))
r3 = collections.Counter()
for c in cs:
    doors = [i for i in c if any(j not in c for j in adj[i])]
    if not doors or not any(kind(i) == 'N' for i in c) or len(c) < 3: continue
    best = 99
    for d0 in doors:
        dist = {d0: 0}; q = collections.deque([d0])
        while q:
            u = q.popleft()
            for v in adj[u]:
                if v in c and v not in dist: dist[v] = dist[u] + 1; q.append(v)
        best = min(best, min(dist.get(i, 99) for i in c if kind(i) == 'N'))
    r3[best] += 1
T3 = sum(r3.values())
print('  R3 (clusters of 3+) steps from door to nearest notable: 0 %s, 1 %s, 2+ %s' % (pc(r3[0], T3), pc(r3[1], T3), pc(sum(v for k, v in r3.items() if k >= 2), T3)))

print('\n[spacing] nodes 0.95 apart, node 0.3 from links, no crossings')
nn = []
for i in range(n):
    ds = [d for j, d in near(xy(i), 3.0) if j != i]
    nn.append(min(ds) if ds else 9)
srt = sorted(nn)
print('  nearest other node: min %.2f, p1 %.2f, p5 %.2f, median %.2f; nodes closer than 0.95: %s' % (srt[0], srt[n // 100], srt[n // 20], srt[n // 2], pc(sum(d < 0.95 for d in nn), n)))
segs = []
for e in t['edges']:
    pl = arcpts(xy(e[0]), xy(e[1]), (e[2], e[3])) if len(e) > 2 else [xy(e[0]), xy(e[1])]
    for p, q in zip(pl, pl[1:]): segs.append((p, q, e[0], e[1]))
sg = collections.defaultdict(list)
for k, (p, q, _, _) in enumerate(segs):
    for gx in range(int(min(p[0], q[0]) // G), int(max(p[0], q[0]) // G) + 1):
        for gy in range(int(min(p[1], q[1]) // G), int(max(p[1], q[1]) // G) + 1): sg[(gx, gy)].append(k)
def segd(p, a_, b_):
    vx, vy = b_[0] - a_[0], b_[1] - a_[1]; L = vx * vx + vy * vy
    tt = max(0.0, min(1.0, ((p[0] - a_[0]) * vx + (p[1] - a_[1]) * vy) / L)) if L else 0.0
    return math.dist(p, (a_[0] + tt * vx, a_[1] + tt * vy))
close = 0; mind = []
for i in range(n):
    p = xy(i); best = 9
    for k in set(k for gx in (int(p[0] // G) - 1, int(p[0] // G), int(p[0] // G) + 1) for gy in (int(p[1] // G) - 1, int(p[1] // G), int(p[1] // G) + 1) for k in sg.get((gx, gy), ())):
        s = segs[k]
        if i in (s[2], s[3]): continue
        best = min(best, segd(p, s[0], s[1]))
    mind.append(best)
    if best < 0.3: close += 1
print('  nodes within 0.3 of a link they are not on: %d (%s)' % (close, pc(close, n)))
def cross(p1, p2, p3, p4):
    o = lambda a_, b_, c_: (b_[0] - a_[0]) * (c_[1] - a_[1]) - (b_[1] - a_[1]) * (c_[0] - a_[0])
    return o(p1, p2, p3) * o(p1, p2, p4) < 0 and o(p3, p4, p1) * o(p3, p4, p2) < 0
X = set()
for cell, ks in sg.items():
    for x in range(len(ks)):
        for y in range(x + 1, len(ks)):
            A, B = segs[ks[x]], segs[ks[y]]
            if {A[2], A[3]} & {B[2], B[3]}: continue
            if cross(A[0], A[1], B[0], B[1]): X.add(tuple(sorted(((A[2], A[3]), (B[2], B[3])))))
print('  link crossings: %d' % len(X))

print('\n[keystones] alone, one 2.2 link, 1.8 clear, 8 apart, outer half, not near starts')
ks = [i for i in range(n) if K(i) == 'keystone']; st = [i for i in range(n) if K(i) == 'start']
R = max(math.hypot(*xy(i)) for i in range(n))
deg = collections.Counter(len(adj[i]) for i in ks)
ll = sorted(math.dist(xy(i), xy(j)) for i in ks for j in adj[i])
clear = sorted(min(d for j, d in near(xy(i), 6) if j != i and j not in adj[i]) if any(j != i and j not in adj[i] for j, d in near(xy(i), 6)) else 6 for i in ks)
apart = sorted(min(math.dist(xy(i), xy(j)) for j in ks if j != i) for i in ks)
rad = sorted(math.hypot(*xy(i)) / R for i in ks)
sd = sorted(min(math.dist(xy(i), xy(j)) for j in st) for i in ks)
print('  %d keystones (%.1f%% of nodes); links each: %s' % (len(ks), 100.0 * len(ks) / n, dict(deg)))
print('  keystone link length: min %.2f median %.2f max %.2f' % (ll[0], ll[len(ll) // 2], ll[-1]))
print('  nearest node not linked to it: min %.2f median %.2f; under 1.8: %d' % (clear[0], clear[len(clear) // 2], sum(c < 1.8 for c in clear)))
print('  nearest other keystone: min %.1f median %.1f; under 8: %d' % (apart[0], apart[len(apart) // 2], sum(x < 8 for x in apart)))
print('  radius as share of tree radius: min %.2f median %.2f; inner half: %d' % (rad[0], rad[len(rad) // 2], sum(r < 0.5 for r in rad)))
print('  distance to nearest start: min %.1f median %.1f' % (sd[0], sd[len(sd) // 2]))
what = collections.Counter(K(j) for i in ks for j in adj[i])
print('  keystones link to: %s' % dict(what))

print('\n[tiers] size mix, reuse by tier, nesting')
def sig(c):
    p = [xy(i) for i in c]; k = len(c)
    return (tuple(sorted(kind(i) for i in c)), tuple(sorted(round(math.dist(p[i], p[j]) / 0.5) for i in range(k) for j in range(i + 1, k))))
S = [sig(c) for c in cs]; cnt = collections.Counter(S)
T = len(cs)
for lo, hi in ((1, 2), (3, 5), (6, 8), (9, 999)):
    print('  size %d-%s: %s' % (lo, hi if hi < 999 else '', pc(sum(lo <= len(c) <= hi for c in cs), T)))
med = [k for k, c in enumerate(cs) if 6 <= len(c) <= 8]
mc = collections.Counter(cnt[S[k]] for k in med)
print('  6-8 node clusters by number of copies of their drawing: %s' % dict(sorted(mc.items())))
big = [c for c in cs if len(c) >= 9]
print('  9+ clusters: %d; drawing repeated: %d' % (len(big), sum(cnt[sig(c)] > 1 for c in big)))
inn = 0
for c in big:
    H = hull([xy(i) for i in c]); hs = set(H)
    if sum(1 for i in c if xy(i) not in hs and inside(xy(i), H)) >= 2: inn += 1
print('  9+ clusters with 2+ of their own nodes inside their outline: %d of %d' % (inn, len(big)))
C = [(sum(xy(i)[0] for i in c) / len(c), sum(xy(i)[1] for i in c) / len(c)) for c in cs]
Rr = max(math.hypot(*p) for p in C)
for lo, hi in ((0, .5), (.5, .75), (.75, 1.01)):
    b = [k for k in range(T) if lo <= math.hypot(*C[k]) / Rr < hi]
    print('  radius %.0f-%.0f%%: small (1-5) %s, big (9+) %s' % (lo * 100, hi * 100, pc(sum(len(cs[k]) <= 5 for k in b), len(b)), pc(sum(len(cs[k]) >= 9 for k in b), len(b))))

print('\n[small copies] twins 6+ apart unless a deliberate pair; neighbourhoods; hubs')
small = [k for k in range(T) if len(cs[k]) <= 5 and S[k][0] != ('N',)]
hubs = lambda k: {j for i in cs[k] for j in adj[i] if j not in cs[k]}
tw = []; close_same_hub = 0; close_adj = 0; close = 0
for k in small:
    d = sorted((math.dist(C[k], C[m]), m) for m in range(T) if m != k and S[m] == S[k])
    if not d: continue
    tw.append(d[0][0])
    if d[0][0] < 6:
        close += 1; m = d[0][1]; hk, hm = hubs(k), hubs(m)
        if hk & hm: close_same_hub += 1
        elif any(j in adj[h] for h in hk for j in hm): close_adj += 1
tw.sort()
print('  small clusters with a copy elsewhere: %d; nearest copy under 6 units: %s' % (len(tw), pc(close, len(tw))))
print('  of those close twins: same road node %s, neighbouring road nodes %s, unrelated %s' % (pc(close_same_hub, close), pc(close_adj, close), pc(close - close_same_hub - close_adj, close)))
same6 = tot6 = 0
for k in range(T):
    for m in range(T):
        if m != k and math.dist(C[k], C[m]) < 6:
            tot6 += 1; same6 += S[m] == S[k]
print('  pairs of clusters within 6 units that are the same drawing: %s' % pc(same6, tot6))

print('\n[roads] beads: road (attribute) nodes along links')
r = [i for i in range(n) if K(i) == 'travel']
d2 = sum(1 for i in r if len(adj[i]) == 2 and all(K(j) == 'travel' for j in adj[i]))
print('  %d road nodes; with exactly two links, both to road nodes (a bead on a road): %s' % (len(r), pc(d2, len(r))))
rl = sorted(math.dist(xy(i), xy(j)) for i in r for j in adj[i] if K(j) == 'travel' and i < j)
print('  road-to-road link length: p10 %.2f median %.2f p90 %.2f' % (rl[len(rl) // 10], rl[len(rl) // 2], rl[9 * len(rl) // 10]))
