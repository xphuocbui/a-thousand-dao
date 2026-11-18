"""Report-only: geometric repetition and roundness. Per figure (ours: the cluster field, i.e. before joins merge
figures; PoE 2: structural). A geometric signature = node kinds + sorted pairwise distances rounded to 0.3, so the
same drawn shape at any rotation or mirror counts as one."""
import sys, json, math, collections
sys.path.insert(0, r'C:\Users\xphuo\IdeaProjects\my-game\tools\design\dao_do_rework\tree_view')
import trees
sys.path.insert(0, __import__('os').path.dirname(__import__('os').path.abspath(__file__)))
from shapestats import comps

def report(name, clusters, xy, kind, adj):
    sig = collections.Counter(); T = len(clusters); cls = collections.Counter(); sizes = []
    round_ = 0; straightish = 0
    for c in clusters:
        pts = [xy(i) for i in c]; k = len(c); sizes.append(k)
        d = sorted(round(math.dist(a, b) / 0.3) for a, b in [(pts[i], pts[j]) for i in range(k) for j in range(i + 1, k)])
        sig[(tuple(sorted(kind(i) for i in c)), tuple(d))] += 1
        e_in = sum(1 for i in c for j in adj[i] if j in c) // 2
        cyc = e_in - k + 1; maxdeg = max(sum(1 for j in adj[i] if j in c) for i in c)
        cls['single' if k == 1 else 'chain' if cyc == 0 and maxdeg <= 2 else 'branch' if cyc == 0 else 'one loop' if cyc == 1 else 'multi-loop'] += 1
        if k >= 4:
            cx = sum(p[0] for p in pts) / k; cy = sum(p[1] for p in pts) / k
            r = [math.dist(p, (cx, cy)) for p in pts]; m = sum(r) / k
            if m and (max(r) - min(r)) / m < 0.35: round_ += 1
            # elongation: principal axes ratio
            sxx = sum((p[0] - cx) ** 2 for p in pts); syy = sum((p[1] - cy) ** 2 for p in pts); sxy = sum((p[0] - cx) * (p[1] - cy) for p in pts)
            tr = sxx + syy; det = sxx * syy - sxy * sxy; l1 = tr / 2 + math.sqrt(max(tr * tr / 4 - det, 0)); l2 = tr - l1
            if l2 <= 0 or l1 / l2 > 6: straightish += 1
    pc = lambda x: '%4.1f%%' % (100.0 * x / T)
    sizes.sort(); top = sig.most_common(10)
    print('==', name, T, 'figures; size median', sizes[T // 2], 'p90', sizes[9 * T // 10])
    print('  topology', ', '.join('%s %s' % (k, pc(v)) for k, v in cls.most_common()))
    print('  near-round (all nodes ~same distance from centre, 4+ nodes): %s;  long and thin (axis ratio >6): %s' % (pc(round_), pc(straightish)))
    print('  distinct drawn shapes %d; 10 commonest cover %s (%s); drawn once: %s' % (len(sig), pc(sum(v for _, v in top)), ' '.join(str(v) for _, v in top), pc(sum(1 for v in sig.values() if v == 1))))

t, a = trees.load_poe2(sys.argv[1])
pk = {'small': 's', 'notable': 'N', 'jewel': 'N'}
E = [tuple(e[:2]) for e in t['edges']]
kind = lambda i: pk.get(t['nodes'][i][2], 'r')
cs, adj = comps(range(len(t['nodes'])), E, lambda i: kind(i) in ('s', 'N'))
report('PoE 2', cs, lambda i: tuple(t['nodes'][i][:2]), kind, adj)
M = json.load(open(sys.argv[2], encoding='utf-8'))
idx = {n['id']: j for j, n in enumerate(M['nodes'])}
adj2 = collections.defaultdict(set)
for e in M['edges']:
    adj2[idx[e['a']]].add(idx[e['b']]); adj2[idx[e['b']]].add(idx[e['a']])
by = collections.defaultdict(set)
for j, n in enumerate(M['nodes']):
    if n.get('cluster') is not None and n['kind'] in ('small', 'notable'):
        by[n['cluster']].add(j)
ok = {'small': 's', 'notable': 'N'}
report('Ours', list(by.values()), lambda i: (M['nodes'][i]['x'], M['nodes'][i]['y']), lambda i: ok.get(M['nodes'][i]['kind'], 'r'), adj2)
