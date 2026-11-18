"""Which pieces fit at given road nodes of a region (frame coords), on the full compiled tree.
usage: fitat.py <layout dir> <region> <ax> <cx> <cy> <pieces,comma> u,v [u,v ...]"""
import sys, json, math, glob
sys.path.insert(0, 'C:/Users/xphuo/IdeaProjects/my-game/tools/design/dao_do_rework/skeleton')
import layout as L
B, G = L.B, L.G
Dd, reg, ax, cx, cy, pcs = sys.argv[1], sys.argv[2], float(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5]), sys.argv[6].split(',')
pts = [tuple(map(float, a.split(','))) for a in sys.argv[7:]]
lay = {}
for p in sorted(glob.glob(Dd + '/*.json')):
    for k, v in json.load(open(p, encoding='utf-8')).items():
        lay.setdefault(k, []).extend(v)
ORDER = ["fire", "earth", "metal", "water", "wood", "blend_fe", "blend_em", "blend_mw", "blend_ww", "blend_wf", "hub", "light", "thunder", "darkness", "shrine"]
lay = {k: lay[k] for k in sorted(lay, key=lambda k: ORDER.index(k))}
B.DENSITY_CAP = 0
M, frames = L.base()
L.compile_layout(lay, M, frames, [])
t = math.radians(ax)
W = lambda u, v: (cx + u * math.cos(t) + v * math.sin(t), cy - u * math.sin(t) + v * math.cos(t))
for u, v in pts:
    p = W(u, v)
    a = min((j for j in M.near(p, 0.9) if M.nodes[j]['kind'] == 'travel'), key=lambda j: math.dist(M.pt(j), p), default=None)
    if a is None:
        print((u, v), 'no road node'); continue
    out = []
    for nm in pcs:
        Sh = G.AUTH[nm]; ok = []
        for fl in range(-180, 180, 15):
            f = ax + fl
            for sp in (1.2, 1.6, 2.0):
                c0 = -Sh.nodes[0][1] + sp
                pa = M.pt(a)
                c = (pa[0] + c0 * math.sin(math.radians(f)), pa[1] + c0 * math.cos(math.radians(f)))
                P = [B.xy_world(c, f, x, y) for x, y, _ in Sh.nodes]
                segs = []
                for i, j, cc in Sh.links:
                    if cc is None: segs.append((P[i], P[j]))
                    else:
                        pl = B.Mesh._poly_of(P[i], P[j], B.xy_world(c, f, *cc)); segs += list(zip(pl, pl[1:]))
                segs.append((pa, P[0]))
                if M.fits(P, segs, [a]):
                    ok.append(fl); break
        if ok: out.append('%s[%d]: %s' % (nm, len(Sh.nodes), ','.join(map(str, ok))))
    print((u, v), ' ; '.join(out) or '-')
