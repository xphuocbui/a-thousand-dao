"""Lists free spots for a keystone hung straight off a road node (report only; the choice is made by eye).
usage: python -I ks_find.py <map.json> <out.json>"""
import collections, json, math, sys
M = json.load(open(sys.argv[1], encoding='utf-8'))
N = {n['id']: n for n in M['nodes']}
P = {i: (n['x'], n['y']) for i, n in N.items()}
deg = collections.Counter()
for e in M['edges']:
    deg[e['a']] += 1; deg[e['b']] += 1
def poly(e):
    a, b = P[e['a']], P[e['b']]; c = e.get('arc')
    if not c: return [a, b]
    r = math.dist(a, c); t1 = math.atan2(a[1]-c[1], a[0]-c[0]); t2 = math.atan2(b[1]-c[1], b[0]-c[0])
    dt = (t2 - t1 + math.pi) % (2*math.pi) - math.pi; n = max(2, int(abs(dt)*r/0.3))
    return [(c[0]+r*math.cos(t1+dt*k/n), c[1]+r*math.sin(t1+dt*k/n)) for k in range(n+1)]
segs = [(p, q, e) for e in M['edges'] for p, q in zip(poly(e), poly(e)[1:])]
grid = collections.defaultdict(list)
for i, p in P.items(): grid[(int(p[0]//3), int(p[1]//3))].append(i)
sg = collections.defaultdict(list)
for s in segs:
    for x in (s[0], s[1]): sg[(int(x[0]//3), int(x[1]//3))].append(s)
def segd(p, a, b):
    vx, vy = b[0]-a[0], b[1]-a[1]; L = vx*vx+vy*vy
    t = max(0, min(1, ((p[0]-a[0])*vx+(p[1]-a[1])*vy)/L)) if L else 0
    return math.dist(p, (a[0]+t*vx, a[1]+t*vy))
def near(p, rad):
    gx, gy = int(p[0]//3), int(p[1]//3); out = []
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1): out += grid.get((gx+dx, gy+dy), [])
    return out
def nearseg(p):
    gx, gy = int(p[0]//3), int(p[1]//3); out = []
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1): out += sg.get((gx+dx, gy+dy), [])
    return out
o = lambda p, q, r: (q[0]-p[0])*(r[1]-p[1]) - (q[1]-p[1])*(r[0]-p[0])
def ok(anchor, K):
    A = P[anchor]
    if math.hypot(*K) > 127: return None
    cl = 9
    for j in near(K, 2):
        if j == anchor: continue
        d = math.dist(K, P[j]); cl = min(cl, d)
        if d < 1.6: return None
    for a, b, e in nearseg(K):
        d = segd(K, a, b)
        if anchor in (e['a'], e['b']) and d < 1.1 and min(math.dist(K, a), math.dist(K, b)) > 0: pass
        if d < 1.1 and not (anchor in (e['a'], e['b']) and segd(K, a, b) >= 0.6): return None
        cl = min(cl, d + 0.5)
    for j in near(((A[0]+K[0])/2, (A[1]+K[1])/2), 3):    # the new link: clear of nodes, no crossing
        if j != anchor and segd(P[j], A, K) < 0.75: return None
    for a, b, e in nearseg(((A[0]+K[0])/2, (A[1]+K[1])/2)):
        if anchor in (e['a'], e['b']): continue
        if o(A, K, a)*o(A, K, b) < 0 and o(a, b, A)*o(a, b, K) < 0: return None
    return cl
AX = {'fire': 0, 'earth': 72, 'metal': 144, 'water': 216, 'wood': 288}
def land_of(p):
    th = math.degrees(math.atan2(p[0], p[1])) % 360
    r = math.hypot(*p)
    if r < 15 or r > 127: return None
    return min(AX, key=lambda k: abs((th - AX[k] + 180) % 360 - 180))
def mirror(p, land):
    a = math.radians(AX[land]); u = (math.sin(a), math.cos(a)); k = 2*(p[0]*u[0]+p[1]*u[1]); return (k*u[0]-p[0], k*u[1]-p[1])
roads = [i for i, n in N.items() if n['kind'] == 'travel']
out = []
for i in roads:
    A = P[i]
    for d in (1.9, 2.3, 2.7):
        for ad in range(0, 360, 15):
            t = math.radians(ad); K = (A[0]+d*math.sin(t), A[1]+d*math.cos(t))
            c = ok(i, K)
            if c is None: continue
            reg = N[i].get('region')
            rec = {'anchor': i, 'k': [round(K[0], 3), round(K[1], 3)], 'clear': round(c, 2), 'region': reg}
            if reg in ('light', 'thunder', 'darkness'):
                out.append(rec); continue
            land = land_of(K)
            if not land: continue
            mk = mirror(K, land)
            mi = min(roads, key=lambda j: math.dist(P[j], mirror(A, land)))
            if math.dist(P[mi], mirror(A, land)) > 0.05: continue
            c2 = ok(mi, mk)
            if c2 is None: continue
            rec.update(land=land, mirror_anchor=mi, mk=[round(mk[0], 3), round(mk[1], 3)], clear=round(min(c, c2), 2),
                       th=round((math.degrees(math.atan2(K[0], K[1])) - AX[land] + 180) % 360 - 180, 1), r=round(math.hypot(*K), 1))
            out.append(rec)
json.dump(out, open(sys.argv[2], 'w'))
by = collections.Counter(r.get('land') or r['region'] for r in out)
print(len(out), dict(by))
