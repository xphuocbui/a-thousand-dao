"""(general version: any region) Fill a combos-first layout with single pieces (user 2026-11-16: "prioritize combo first, then maybe filling in").
Greedy: at road nodes carrying fewer than MAXC clusters, try pieces of the side's style at every 15 deg and spokes
1.2-2.4; score favours sitting 1.0-1.6 from an existing cluster (PoE 2's median gap 1.3) and PoE 2's size mix;
each shape at most CAP times in the land (combos counted); nothing past LIM deg off the axis or beyond radius RMAX.
Writes the chosen pieces into the region's layout as ordinary entries.
usage: fill2.py <region> <region layout.json> <out.json> <spec json> [other layouts ...]
spec: {"cx":0,"cy":0,"ax":72,"kind":"wedge"|"disc","lim":30,"rmin":26.5,"rmax":97,"right":[...],"left":[...],
       "avoid":[[u,v,r],...], "cap":3, "v2":true, "maxc_hub":3}  (u, v in the region's frame)
v2 specs (authoring/specs-v2/) add the small one-notable figures, aim pieces along the flow and let road hubs take a
third cluster; see the V2 block below."""
import sys, json, math, collections
sys.path.insert(0, 'C:/Users/xphuo/IdeaProjects/my-game/tools/design/dao_do_rework/skeleton')
import layout as L
B, G = L.B, L.G
REGION, LAY, OUT, SPEC = sys.argv[1:5]
_VALUED = ('--dense-hole', '--dense-target')       # flags that take a value
OTHERS = [a for k, a in enumerate(sys.argv[5:], 5) if not a.startswith('--') and sys.argv[k - 1] not in _VALUED]
# weave (2026-11-17, user: the tree "feels disconnected"; every v1 cluster was a one-link dead end): with --weave, a
# piece whose axis runs on through another road node, its tip 0.85-2.0 short of it, is joined tip to node (a road runs
# through the cluster, as through about a third of PoE 2's groups) and scores WEAVE_BONUS until WEAVE_SHARE of the
# region's clusters have two links. The join lies on the piece's mirror line, so rule R1 holds.
WEAVE = '--weave' in sys.argv[5:]
# --orbit (experiment 2026-11-17): the region is compiled with layout.py's orbit snap, and fill uses the snapped figures
# (orbit.py) at facings 30 degrees apart from the region's axis only; a through piece must line up within LAT_ORBIT
ORBIT = '--orbit' in sys.argv[5:]
L.ORBIT = ORBIT
LAT_ORBIT = 0.13
# --tilt (experiment 2026-11-17, user: in PoE "the first node of the cluster that connects with the travel nodes, they
# dont always form a straight line with the cluster itself"; measured PoE 1: 30 % of road links within 10 degrees of
# the cluster's centre line, 32 % 10-30, 26 % 30-60, 12 % more, median 20; link length median 2.5 of ours; ours were
# all 0 degrees and 1.6). The entry direction and the figure's facing are chosen apart; the entry node must stay the
# figure's nearest node to its road node (PoE 1: 85 %). Checked with cluster_rules.py --free-links.
TILT = '--no-tilt' not in sys.argv[5:]        # default since 2026-11-17 (user: "the tilt works well")
L.TILT_COMBOS = 20.0 if TILT else 0.0      # the combos are drawn tilted too (layout.py --tilt-combos)
TILTS = (0, 20, -20, 40, -40) if TILT else (0,)
TILT_BONUS = {0: 0.0, 20: 0.35, 40: 0.3}
# --dense (2026-11-17, user: "certain regions feels a bit sparse, please amend"): a pass that only fills holes. Pieces
# may also hang off a node of a cluster near the hole (R1 now lets links come from any direction); a placement must
# sit at least DENSE_HOLE from every node drawn already; stops once the region's empty share (points inside it more
# than 2.2 from any node) is down to DENSE_TARGET, Fire and Earth's level when the user judged them fine.
DENSE = '--dense' in sys.argv[5:]
DENSE_TARGET = float(sys.argv[sys.argv.index('--dense-target') + 1]) if '--dense-target' in sys.argv else 0.10
DENSE_HOLE = float(sys.argv[sys.argv.index("--dense-hole") + 1]) if "--dense-hole" in sys.argv else 2.0
WEAVE_SHARE, WEAVE_BONUS, WEAVE_GAP = 0.35, 2.5, (0.85, 2.0)
spec = json.load(open(SPEC, encoding='utf-8'))
CAP, MAXC = spec.get('cap', 3), spec.get('maxc', 2)
CX, CY, AX = spec.get('cx', 0.0), spec.get('cy', 0.0), spec['ax']
_t = math.radians(AX)
loc = lambda p: ((p[0] - CX) * math.cos(_t) - (p[1] - CY) * math.sin(_t), (p[0] - CX) * math.sin(_t) + (p[1] - CY) * math.cos(_t))
RIGHT, LEFT = spec['right'], spec['left']
SIZE_PREF = {4: 0.6, 5: 1.0, 6: 1.0, 7: 1.0, 8: 0.9, 9: 0.8, 10: 0.6, 11: 0.5, 12: 0.4, 13: 0.3}
# v2 (review 2026-11-17, spec "v2": true): v1's fill read as generated (pieces at any angle, median 8 nodes, most with
# 2+ notables, never a third cluster on a road node). v2 favours PoE 2's small one-notable figures (median 5), aims
# pieces along the region's flow (out from the map's centre, or from a disc's centre), and lets road hubs (3+ roads)
# carry a third cluster, as 42 % of PoE 2's road nodes carry 3 or more. One- and two-notable figures score alike: a
# +0.4 bonus for one notable overshot PoE 2's mix (79 % single against 60 %, first v2 fill 2026-11-17).
V2 = spec.get('v2', False)
if V2:
    SIZE_PREF = {4: 1.0, 5: 1.0, 6: 0.9, 7: 0.7, 8: 0.5, 9: 0.4, 10: 0.3, 11: 0.2, 12: 0.15, 13: 0.1}
    ROUND = ["Petal", "Pod", "Drop", "Vase", "Pendant", "Lens", "Little ring", "Lens and satellite"]
    SHARP = ["Gem", "Shard", "Bud", "Diamond", "Kite", "Rails", "Arrowhead", "Small fan"]
    MAXC_HUB = spec.get('maxc_hub', 3)


def plan(M, Sh, c, f, a):
    P = [B.xy_world(c, f, u, v) for u, v, _ in Sh.nodes]
    segs = []
    for i, j, cc in Sh.links:
        if cc is None:
            segs.append((P[i], P[j]))
        else:
            pl = B.Mesh._poly_of(P[i], P[j], B.xy_world(c, f, *cc))
            segs += list(zip(pl, pl[1:]))
    if not (B.LINK_MIN <= math.dist(M.pt(a), P[0]) <= B.LINK_MAX):
        return None
    segs.append((M.pt(a), P[0]))
    return P if M.fits(P, segs, [a]) else None


lay = json.load(open(LAY, encoding='utf-8'))
allay = {}
for pth in OTHERS:
    for k, v in json.load(open(pth, encoding='utf-8')).items():
        allay.setdefault(k, []).extend(v)
for k, v in lay.items():
    allay.setdefault(k, []).extend(v)
B.DENSITY_CAP = 0
M, frames = L.base()
log = []
L.compile_layout(allay, M, frames, log)
for g in log:
    print('layout:', g)
def ok(p):
    u, v = loc(p)
    if any(math.dist((u, v), (a_, b_)) < r_ for a_, b_, r_ in spec.get('avoid', [])):
        return False
    if spec['kind'] == 'disc':
        return math.hypot(u, v) <= spec['rmax']
    return abs(math.degrees(math.atan2(u, v))) <= spec['lim'] and spec['rmin'] <= v and math.hypot(u, v) <= spec['rmax']


KEYS = [i for i, n in enumerate(M.nodes) if n['kind'] == 'keystone' and not n.get('dead')]
if TILT:
    B.LINK_MAX = 2.5        # after the compile, so the regions drawn already keep their placements
if ORBIT:
    import orbit as _orbit
    _SNAP = _orbit.library(G.AUTH)
    RIGHT = [n for n in RIGHT if n in _SNAP]
    LEFT = [n for n in LEFT if n in _SNAP]
    FACINGS = [(AX + 30 * k) % 360 for k in range(12)]
else:
    _SNAP = None
    FACINGS = list(range(0, 360, 30 if TILT else 15))
if V2:
    # each side's small figures follow its style: the side whose pool draws more arcs takes the round ones
    def _curvy(pool):
        return sum(sum(c is not None for _, _, c in G.AUTH[n].links) / max(1, len(G.AUTH[n].links)) for n in pool if n in G.AUTH)
    rr, ll = (ROUND, SHARP) if _curvy(RIGHT) >= _curvy(LEFT) else (SHARP, ROUND)
    RIGHT = RIGHT + [n for n in rr if n not in RIGHT]
    LEFT = LEFT + [n for n in ll if n not in LEFT]
    NOT = {n: sum(r == 'N' for _, _, r in G.AUTH[n].nodes) for n in G.AUTH}


def flow_bonus(x, y, f):
    """v2: favour pieces aimed along the region's flow: straight out (radially) best, across it next, inward least."""
    ox, oy = (CX, CY) if spec['kind'] == 'disc' else (0.0, 0.0)
    out = math.degrees(math.atan2(x - ox, y - oy))
    dev = abs((f - out + 180) % 360 - 180)
    return 0.6 if dev <= 20 else 0.35 if abs(dev - 90) <= 20 else 0.15 if dev >= 160 else 0.0
used = collections.Counter(gp['shape'] for gp in M.groups if gp.get('region') == REGION)
gid = {}
for k, gp in enumerate(M.groups):
    for i in gp['nodes']:
        gid[i] = k
added = []
joins_out = []
TIP = {}
for _n, _S in (_SNAP or G.AUTH).items():
    _ax = [q for q, (uu, vv, _) in enumerate(_S.nodes) if abs(uu) < 1e-6 and q != 0]
    if _ax:
        _tip = max(_ax, key=lambda q: _S.nodes[q][1])
        TIP[_n] = (_tip, _S.nodes[_tip][1] - _S.nodes[0][1])


def two_link_share():
    ks = [k for k, gp in enumerate(M.groups) if gp.get('region') == REGION and not gp.get('dead')
          and not gp['shape'].startswith(('start', 'emblem')) and gp['shape'] != 'keystone']
    two = 0
    for k in ks:
        ids = set(M.groups[k]['nodes'])
        if len({j for i in ids for j in M.adj[i] if j not in ids}) >= 2:
            two += 1
    return two / max(1, len(ks))


def empty_share():
    """Share of sample points inside the region (lands inside the rim and 27 degrees, discs inside 85 % of their
    radius) farther than 2.2 from any node."""
    pts = []
    if spec['kind'] == 'disc':
        R = spec['rmax'] * 0.85
        for i in range(int(-R), int(R) + 1):
            for j in range(int(-R), int(R) + 1):
                if math.hypot(i, j) <= R:
                    pts.append((i, j))
    else:
        for v in range(int(spec['rmin']), 84):
            lim = v * math.tan(math.radians(min(spec['lim'], 27)))
            for u in range(int(-lim), int(lim) + 1):
                pts.append((u, v))
    pts = [q for q in pts if not any(math.dist(q, (a_, b_)) < r_ for a_, b_, r_ in spec.get('avoid', []))]
    t_ = math.radians(AX)
    W_ = lambda u, v: (CX + u * math.cos(t_) + v * math.sin(t_), CY - u * math.sin(t_) + v * math.cos(t_))
    far = sum(1 for u, v in pts if not any(True for _ in M.near(W_(u, v), 2.2)))
    return far / max(1, len(pts))


if DENSE:
    MAXC = max(MAXC, 3)
    print('empty before %.0f %%' % (100 * empty_share()), flush=True)
while True:
    if DENSE and empty_share() <= DENSE_TARGET:
        break
    weave_on = WEAVE and two_link_share() < WEAVE_SHARE
    best = None
    roads = [i for i, n in enumerate(M.nodes) if not n.get('dead') and n['kind'] == 'travel' and ok(M.pt(i))
             and n.get('region') == REGION]
    hosts = set()
    if DENSE:       # cluster nodes next to a hole: minor first, at most three links, their cluster at most two links out
        for i, n in enumerate(M.nodes):
            if n.get('dead') or n['kind'] not in ('small', 'notable') or n.get('region') != REGION or i not in gid:
                continue
            g_ = M.groups[gid[i]]
            if g_['shape'].startswith(('start', 'emblem')) or len(M.adj[i]) > 3 or not ok(M.pt(i)):
                continue
            ids_ = set(g_['nodes'])
            if len({j for k_ in ids_ for j in M.adj[k_] if j not in ids_}) >= 3:
                continue
            hosts.add(i)
    for a in roads + sorted(hosts):
        if a in hosts:
            ncl = 0
        else:
            ncl = len({gid[j] for j in M.adj[a] if j in gid})
        hub = V2 and sum(M.nodes[j]['kind'] in ('travel', 'start') for j in M.adj[a]) >= 3
        if ncl >= (MAXC_HUB if hub else MAXC):
            continue
        x, y = M.pt(a)
        ul = loc((x, y))[0]
        pool = RIGHT if ul > 0.3 else LEFT if ul < -0.3 else RIGHT + LEFT
        for nm in pool:
            if nm not in G.AUTH or used[nm] >= CAP:
                continue
            Sh = _SNAP[nm] if ORBIT else G.AUTH[nm]
            pref = SIZE_PREF.get(len(Sh.nodes), 0.2)
            for f, dt in ((f_, d_) for f_ in FACINGS for d_ in TILTS):
                g = f + dt
                for sp in ((1.6, 1.2, 2.0, 2.4) if not TILT else (2.0, 1.6, 2.4, 1.2)):
                    ex = (x + sp * math.sin(math.radians(f)), y + sp * math.cos(math.radians(f)))
                    c = (ex[0] - Sh.nodes[0][1] * math.sin(math.radians(g)), ex[1] - Sh.nodes[0][1] * math.cos(math.radians(g)))
                    P = plan(M, Sh, c, g, a)
                    if P is None or not all(ok(p) for p in P):
                        continue
                    if dt and min(range(len(P)), key=lambda q: math.dist(P[q], (x, y))) != 0:
                        continue        # the road joins the figure's nearest node
                    if DENSE:
                        hole = min((math.dist(p, M.pt(j)) for p in P for j in M.near(p, DENSE_HOLE) if j != a), default=9)
                        if hole < 1.0:
                            continue
                        cen = (sum(p[0] for p in P) / len(P), sum(p[1] for p in P) / len(P))
                        d0 = min((math.dist(cen, M.pt(j)) for j in M.near(cen, 4.0)), default=4.0)
                        if d0 < DENSE_HOLE:
                            continue        # only into holes
                    if any(math.dist(p, M.pt(k)) < 1.8 for p in P for k in KEYS):     # PoE keystone clearance
                        continue
                    gap = min((math.dist(p, M.pt(j)) for p in P for j in M.near(p, 3.0) if j in gid), default=9)
                    close = 1.0 if 1.0 <= gap <= 1.6 else 0.5 if gap <= 2.2 else 0.0
                    score = close * 2 + pref + 0.15 * len(Sh.nodes) / 8 - used[nm] * 0.3 + (0.3 if ncl == 0 else 0) - (0.2 if sp != (2.0 if TILT else 1.6) else 0)
                    score += TILT_BONUS.get(abs(dt), 0.0)
                    if DENSE:
                        score += 0.6 * min(d0, 4.0) - (0.4 if M.nodes[a]['kind'] == 'notable' else 0)
                    if V2:
                        score += flow_bonus(x, y, f) + {1: 0.15, 2: 0.15}.get(NOT[nm], -0.2) + (0.2 if hub and ncl == 2 else 0)
                    if best is None or score > best[0]:
                        best = (score, a, nm, f, sp, c, None, dt)
                    break
            if weave_on and nm in TIP and not DENSE:
                ti, lax = TIP[nm]
                for T in M.near((x, y), B.LINK_MAX + lax + WEAVE_GAP[1]):
                    if M.nodes[T]['kind'] != 'travel' or T == a or T in M.adj[a] or M.nodes[T].get('dead'):
                        continue
                    pT = M.pt(T); d = math.dist((x, y), pT)
                    f = math.degrees(math.atan2(pT[0] - x, pT[1] - y))
                    if ORBIT:
                        fq = AX + round((f - AX) / 30) * 30
                        if abs(d * math.sin(math.radians(f - fq))) > LAT_ORBIT:
                            continue
                        f = fq
                    for sp in (1.4, 1.2, 1.6, 1.0, 1.7):
                        if not WEAVE_GAP[0] <= d - sp - lax <= WEAVE_GAP[1]:
                            continue
                        c0 = -Sh.nodes[0][1] + sp
                        c = (x + c0 * math.sin(math.radians(f)), y + c0 * math.cos(math.radians(f)))
                        P = plan(M, Sh, c, f, a)
                        if P is None or not all(ok(p) for p in P):
                            continue
                        if any(math.dist(p, M.pt(k)) < 1.8 for p in P for k in KEYS):
                            continue
                        if not M.fits([], [(P[ti], pT)], [T]):
                            continue
                        gap = min((math.dist(p, M.pt(j)) for p in P for j in M.near(p, 3.0) if j in gid), default=9)
                        close = 1.0 if 1.0 <= gap <= 1.6 else 0.5 if gap <= 2.2 else 0.0
                        score = close * 2 + pref + 0.15 * len(Sh.nodes) / 8 - used[nm] * 0.3 + (0.3 if ncl == 0 else 0) + WEAVE_BONUS
                        if best is None or score > best[0]:
                            best = (score, a, nm, f, sp, c, (ti, T), 0)
                        break
    if best is None:
        break
    _, a, nm, f, sp, c, through, dt = best
    Sh = _SNAP[nm] if ORBIT else G.AUTH[nm]
    ids = B.place_xy(M, nm, Sh.nodes, Sh.links, c, f + dt, [(a, 0)], REGION, lambda *_: True, REGION)
    if through:
        ti, T = through
        M.link(ids[ti], T)
        joins_out.append({"join": [[round(q, 2) for q in loc(M.pt(ids[ti]))], [round(q, 2) for q in loc(M.pt(T))]]})
    for i in ids:
        gid[i] = len(M.groups) - 1
    used[nm] += 1
    ul, vl = loc(M.pt(a))
    fl = (f - AX + 180) % 360 - 180
    e = {"piece": nm, "at": [round(ul, 2), round(vl, 2)], "facing": round(fl, 2)}
    if M.nodes[a]['kind'] != 'travel':
        e["host"] = True        # hangs off a cluster node, not a road node (--dense)
    if dt:
        e["tilt"] = dt
    if sp != 1.6:
        e["spoke"] = sp
    added.append(e)
    print('fill', json.dumps(e), flush=True)
F = lay[REGION] + [{"note": "Fill after the combos (fill.py): single pieces where they fit, 1.0-1.6 from a neighbour where possible."}] + added
if joins_out:
    F += [{"note": "Weave (fill.py --weave, 2026-11-17): the pieces above whose axis runs on through another road node are joined tip to node."}] + joins_out
lines = ['{', ' "%s": [' % REGION] + ['  ' + json.dumps(e, ensure_ascii=False) + (',' if k < len(F) - 1 else '') for k, e in enumerate(F)] + [' ]', '}']
open(OUT, 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
if DENSE:
    print('empty after %.0f %%' % (100 * empty_share()))
print('added', len(added), 'woven', len(joins_out), 'two-link share %.0f %%' % (100 * two_link_share()))
