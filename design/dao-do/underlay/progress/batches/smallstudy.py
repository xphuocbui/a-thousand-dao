"""Report-only study of PoE 2's small clusters (1-5 nodes): which drawings repeat, how often, where and how they are
placed, and what varies between copies. usage: python -I smallstudy.py <poe2 data.json>"""
import sys, os, json, math, collections
sys.path.insert(0, r'C:\Users\xphuo\IdeaProjects\my-game\tools\design\dao_do_rework\tree_view')
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import trees
from shapestats import comps

RAW = json.load(open(sys.argv[1], encoding='utf-8'))
t, a = trees.load_poe2(sys.argv[1])
sc = a['scale']
pos2raw = {}
for sid, n in RAW['nodes'].items():
    if 'x' in n:
        pos2raw[(round(n['x'] * sc, 3), round(n['y'] * sc, 3))] = n
NN = t['nodes']
raw = [pos2raw.get((round(n[0], 3), round(n[1], 3))) for n in NN]
pk = {'small': 's', 'notable': 'N', 'jewel': 'N'}
kind = lambda i: pk.get(NN[i][2], 'r')
E = [tuple(e[:2]) for e in t['edges']]
ARC = {tuple(sorted(e[:2])): len(e) > 2 for e in t['edges']}
cs, adj = comps(range(len(NN)), E, lambda i: kind(i) in ('s', 'N'))
xy = lambda i: (NN[i][0], NN[i][1])
small = [c for c in cs if len(c) <= 5]
allsizes = sum(len(c) for c in cs)

def sig(c):
    pts = [xy(i) for i in c]; k = len(c)
    return (tuple(sorted(kind(i) for i in c)), tuple(sorted(round(math.dist(pts[i], pts[j]) / 0.5) for i in range(k) for j in range(i + 1, k))))

S = {id(c): sig(c) for c in cs}
cnt = collections.Counter(S[id(c)] for c in cs)
def cen(c):
    return (sum(xy(i)[0] for i in c) / len(c), sum(xy(i)[1] for i in c) / len(c))
C = {id(c): cen(c) for c in cs}

print('PoE 2: %d clusters, %d of them small (1-5 nodes) = %.0f%% of clusters, %.0f%% of cluster nodes' % (
    len(cs), len(small), 100 * len(small) / len(cs), 100 * sum(len(c) for c in small) / allsizes))
top = collections.Counter(S[id(c)] for c in small).most_common(12)
names = {}
print('\nThe 12 commonest small drawings:')
for r, (s, k) in enumerate(top):
    ex = next(c for c in small if S[id(c)] == s)
    nots = sum(1 for i in ex if kind(i) == 'N')
    e_in = sum(1 for i in ex for j in adj[i] if j in ex) // 2
    shape = 'loop' if e_in >= len(ex) else ('chain' if max(sum(1 for j in adj[i] if j in ex) for i in ex) <= 2 else 'fork')
    names[s] = 'D%d' % (r + 1)
    print('  D%-2d %2d copies  %d nodes (%d notable), %s' % (r + 1, k, len(ex), nots, shape))
print('  the 12 cover %d of %d small clusters' % (sum(k for _, k in top), len(small)))

# --- placement ---
def door_info(c):
    out = [(i, j) for i in c for j in adj[i] if j not in c]
    return out
ext_kinds = collections.Counter(); n_ext = collections.Counter(); elen = []; ent_off = []; radial = []; groupshare = collections.Counter()
hand = collections.defaultdict(collections.Counter); arcpat = collections.defaultdict(set); orbitpat = collections.defaultdict(set)
for c in small:
    out = door_info(c); n_ext[min(len(out), 3)] += 1
    for i, j in out:
        ext_kinds[NN[j][2]] += 1; elen.append(math.dist(xy(i), xy(j)))
    if not out:
        continue
    i, j = out[0]; cc = C[id(c)]
    if len(c) >= 2:
        a1 = math.atan2(xy(i)[1] - xy(j)[1], xy(i)[0] - xy(j)[0]); a2 = math.atan2(cc[1] - xy(i)[1], cc[0] - xy(i)[0])
        ent_off.append(abs((math.degrees(a2 - a1) + 180) % 360 - 180))
        # cluster axis (door -> centre) against the outward radial direction from the tree centre
        ar = math.atan2(xy(i)[1], xy(i)[0])
        radial.append(abs((math.degrees(a2 - ar) + 180) % 360 - 180))
    # drawn on the road node's own orbit group?
    gs = {raw[k]['group'] for k in c if raw[k]}
    gr = raw[j]['group'] if raw[j] else None
    groupshare['same PoE group as the road node it hangs from' if gr in gs else 'own group'] += 1
    # mirror hand: sign of the turn door -> centre -> farthest notable/node
    far = max(c, key=lambda k: math.dist(xy(k), xy(i)))
    cr = (cc[0] - xy(i)[0]) * (xy(far)[1] - xy(i)[1]) - (cc[1] - xy(i)[1]) * (xy(far)[0] - xy(i)[0])
    hand[S[id(c)]]['L' if cr > 0.05 else 'R' if cr < -0.05 else 'sym'] += 1
    arcpat[S[id(c)]].add(tuple(sorted(ARC[tuple(sorted((p, q)))] for p in c for q in adj[p] if q in c and p < q)))
    orbitpat[S[id(c)]].add(tuple(sorted({raw[k]['orbit'] for k in c if raw[k]})))
pc = lambda x, T: '%.0f%%' % (100 * x / T)
T = len(small)
elen.sort(); ent_off.sort(); radial.sort()
print('\nPlacement of small clusters:')
print('  links out: 1 = %s, 2 = %s, 3+ = %s' % (pc(n_ext[1], T), pc(n_ext[2], T), pc(n_ext[3], T)))
print('  what they hang from: %s' % dict(ext_kinds.most_common()))
print('  road link length: p10 %.2f, median %.2f, p90 %.2f units' % (elen[len(elen) // 10], elen[len(elen) // 2], elen[9 * len(elen) // 10]))
q = lambda L, a_, b_: pc(sum(a_ <= x < b_ for x in L), len(L))
print('  entry turn (road link vs door->centre): 0-15 %s, 15-45 %s, 45-90 %s, 90+ %s' % (q(ent_off, 0, 15), q(ent_off, 15, 45), q(ent_off, 45, 90), q(ent_off, 90, 181)))
print('  facing vs outward from tree centre: 0-45 %s, 45-90 %s, 90-135 %s, 135-180 %s' % (q(radial, 0, 45), q(radial, 45, 90), q(radial, 90, 135), q(radial, 135, 181)))
print('  %s' % dict(groupshare))

print('\nWhat varies between copies of one drawing (top 12):')
for s, k in top:
    h = hand[s]
    print('  %-4s %2d copies: hand L/R/sym %d/%d/%d; link styles (arc/straight mixes) %d; PoE orbit sets %d' % (
        names[s], k, h['L'], h['R'], h['sym'], len(arcpat[s]), len(orbitpat[s])))

# --- spacing and neighbourhood ---
print('\nSpacing and neighbours (small clusters):')
twin = []; same_nb = 0; distinct = []; hubsame = collections.Counter()
for c in small:
    s = S[id(c)]; cc = C[id(c)]
    d = [math.dist(cc, C[id(o)]) for o in cs if o is not c and S[id(o)] == s]
    if d: twin.append(min(d))
    nb = sorted((math.dist(cc, C[id(o)]), id(o)) for o in cs if o is not c)
    if S[nb[0][1]] == s: same_nb += 1
    distinct.append(len({S[x] for dd, x in nb if dd < 6} | {s}))
twin.sort()
print('  nearest copy of the same drawing: p10 %.1f, p25 %.1f, median %.1f units' % (twin[len(twin) // 10], twin[len(twin) // 4], twin[len(twin) // 2]))
print('  nearest neighbour cluster is the same drawing: %s' % pc(same_nb, T))
distinct.sort()
print('  distinct drawings among clusters within 6 units (incl. itself): median %d, p10 %d' % (distinct[len(distinct) // 2], distinct[len(distinct) // 10]))
# siblings on one road node
hub = collections.defaultdict(list)
for c in cs:
    for i in c:
        for j in adj[i]:
            if j not in c and kind(j) == 'r':
                hub[j].append(id(c))
multi = [v for v in hub.values() if len(set(v)) >= 2]
same = sum(1 for v in multi if len({S[x] for x in set(v)}) < len(set(v)))
print('  road nodes carrying 2+ clusters: %d; of those, carrying two copies of one drawing: %s' % (len(multi), pc(same, len(multi))))

# --- content: do copies carry the same passives? ---
print('\nContent of copies (node names):')
for s, k in top[:6]:
    groups = [tuple(sorted(NN[i][3] or '' for i in c)) for c in small if S[id(c)] == s]
    nm = collections.Counter(n for g in groups for n in g if n)
    print('  %-4s %2d copies, %d distinct name sets; commonest names: %s' % (names[s], k, len(set(groups)), ', '.join('%s x%d' % x for x in nm.most_common(4))))

# --- frequency across the tree ---
print('\nWhere they sit (radius from the centre, units):')
R = [math.hypot(*C[id(c)]) for c in cs]; Rmax = max(R)
for lo, hi in ((0, .25), (.25, .5), (.5, .75), (.75, 1.01)):
    band = [c for c in cs if lo * Rmax <= math.hypot(*C[id(c)]) < hi * Rmax]
    sm = [c for c in band if len(c) <= 5]
    print('  %3.0f-%3.0f%% of radius: %3d clusters, small %s' % (lo * 100, hi * 100, len(band), pc(len(sm), max(len(band), 1))))
json.dump({'sig': {str(i): names.get(S[id(c)]) for i, c in enumerate(cs)}}, open(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'smallstudy-names.json'), 'w'))
