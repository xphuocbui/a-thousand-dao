"""Weave the Đạo Đồ (2026-11-17, user: the tree "feels disconnected somehow"; measured, every v1 cluster had
exactly one link out and no cluster touched another, where 75 % of PoE 1's clusters have two links out and about a
third of PoE 2's groups have a road running through).

Two passes over the compiled layouts, both keeping rule R1: a second outside link must lie on the figure's mirror
line, so every join runs straight on from a cluster's tip along its own axis.
  A  join as drawn: a cluster whose axis already runs on to a road node, or to a facing cluster whose axis runs back
     through this tip (the "facing" combos), is joined tip to node.
  B  re-aim fill: a fill piece (an entry after the "Fill after the combos" note) is turned on its own road node so its
     axis runs through another road node, its tip joined to it. Same piece, same road node; only the facing and the
     spoke change. Pieces nearest their old facing go first; nothing turns that does not fit.
Stops in each region once SHARE of its clusters have two links (PoE 1 75 %, PoE 2 about 20-33 %).

Writes `join` entries (layout.py runs them after every region) and the new facings into the layout files with --write;
otherwise only reports. Like the other helpers it reports observations; the author decides what stays.
usage: weave.py <layout dir> [--write] [--share 0.30] [--only fire,earth]"""
import sys, json, math, glob, os, collections
sys.path.insert(0, 'C:/Users/xphuo/IdeaProjects/my-game/tools/design/dao_do_rework/skeleton')
import layout as L
B, G = L.B, L.G

D = sys.argv[1]
WRITE = '--write' in sys.argv
SHARE = float(sys.argv[sys.argv.index('--share') + 1]) if '--share' in sys.argv else 0.30
ONLY = set(sys.argv[sys.argv.index('--only') + 1].split(',')) if '--only' in sys.argv else None
# --free (experiment 2026-11-17, user: "please just try all"; check with cluster_rules.py --free-exits): a second link
# may leave ANY node of a cluster; the nearest pairs between neighbouring clusters (or a cluster and a road node not its
# own) are joined, shortest first, until FREE_SHARE of the region's clusters have two links. Skips passes A and B.
FREE = '--free' in sys.argv
FREE_SHARE = float(sys.argv[sys.argv.index('--free-share') + 1]) if '--free-share' in sys.argv else 0.45
FREE_GAP = (0.85, 1.8)
L.ORBIT = '--orbit' in sys.argv
L.TILT_COMBOS = 0.0 if '--no-tilt' in sys.argv else 20.0      # default since 2026-11-17
ORDER = ["fire", "earth", "metal", "water", "wood", "blend_fe", "blend_em", "blend_mw", "blend_ww", "blend_wf",
         "hub", "light", "thunder", "darkness", "shrine"]
FILL_NOTE = "Fill after the combos (fill.py)"
LAT = 0.13          # R1 mirrors outside points within 0.3: a point this far off the axis lands 0.26 from its twin
GAP = (0.85, 2.2)   # tip to the joined node

paths = {}
for p in sorted(glob.glob(os.path.join(D, '*.json'))):
    for k in json.load(open(p, encoding='utf-8')):
        paths[k] = p
lay = {k: json.load(open(paths[k], encoding='utf-8'))[k] for k in ORDER if k in paths}
B.DENSITY_CAP = 0
M, frames = L.base()
log = []
L.compile_layout(lay, M, frames, log)
for g in log:
    print('layout:', g)

SK = ('small', 'notable')
fill_from = {}
for reg, ents in lay.items():
    fill_from[reg] = next((k for k, e in enumerate(ents) if e.get('note', '').startswith(FILL_NOTE)), len(ents))


def frame_of(reg, p):
    cx, cy, ax, _ = frames[reg]
    t = math.radians(ax)
    x, y = p[0] - cx, p[1] - cy
    return [round(x * math.cos(t) - y * math.sin(t), 2), round(x * math.sin(t) + y * math.cos(t), 2)]


def members(k):
    return [i for i in M.groups[k]['nodes'] if not M.nodes[i].get('dead') and M.nodes[i]['kind'] in SK]


def outside(ids):
    s = set(ids)
    return {j for i in ids for j in M.adj[i] if j not in s}


def eligible(k):
    g = M.groups[k]
    if g.get('dead') or g['shape'].startswith(('start', 'emblem')) or g['shape'] == 'keystone' or not g.get('region'):
        return False
    ids = members(k)
    return len(ids) >= 2 and len(outside(ids)) == 1


def axis(k):
    ids = members(k)
    c = (sum(M.pt(i)[0] for i in ids) / len(ids), sum(M.pt(i)[1] for i in ids) / len(ids))
    o = next(iter(outside(ids)))
    po = M.pt(o)
    L_ = math.dist(c, po) or 1.0
    return ids, c, ((c[0] - po[0]) / L_, (c[1] - po[1]) / L_), o


def lat_proj(p, c, u):
    dx, dy = p[0] - c[0], p[1] - c[1]
    return abs(dx * u[1] - dy * u[0]), dx * u[0] + dy * u[1]


def tip_of(ids, c, u):
    on = [i for i in ids if lat_proj(M.pt(i), c, u)[0] < LAT]
    return max(on, key=lambda i: lat_proj(M.pt(i), c, u)[1]) if on else None


gid = {}
for k, g in enumerate(M.groups):
    for i in g['nodes']:
        gid[i] = k
woven = set()
joins = collections.defaultdict(list)          # region -> [[tip uv], [node uv]]
turns = {}                                     # (region, entry index) -> (facing, spoke)
count = collections.Counter()


def region_share(reg):
    ks = [k for k, g in enumerate(M.groups) if g.get('region') == reg and not g.get('dead')
          and not g['shape'].startswith(('start', 'emblem')) and g['shape'] != 'keystone' and len(members(k)) >= 2]
    two = sum(1 for k in ks if len(outside(members(k))) >= 2)
    return two, len(ks)


# --- A: join as drawn ---
for k in (range(0) if FREE else range(len(M.groups))):
    if k in woven or not eligible(k) or (ONLY and M.groups[k]['region'] not in ONLY):
        continue
    reg = M.groups[k]['region']
    two, n = region_share(reg)
    if n and two / n >= SHARE:
        continue
    ids, c, u, o = axis(k)
    t = tip_of(ids, c, u)
    if t is None:
        continue
    tp = M.pt(t); tproj = lat_proj(tp, c, u)[1]
    best = None
    for j in M.near(tp, GAP[1]):
        if j in ids or j == o or j in M.adj[t] or M.nodes[j]['kind'] not in ('travel',) + SK:
            continue
        d = math.dist(tp, M.pt(j))
        la, pr = lat_proj(M.pt(j), c, u)
        if d < GAP[0] or la > LAT or pr <= tproj:
            continue
        h = gid.get(j)
        if M.nodes[j]['kind'] != 'travel':
            if h is None or h in woven or not eligible(h):
                continue
            ids2, c2, u2, _ = axis(h)
            if j != tip_of(ids2, c2, u2) or lat_proj(tp, c2, u2)[0] > LAT:
                continue
        if best is None or d < best[0]:
            best = (d, j, h)
    if best and M.fits([], [(tp, M.pt(best[1]))], [t, best[1]]):
        d, j, h = best
        M.link(t, j); M.edges[-1]['ph'] = 'join'
        woven.add(k)
        if M.nodes[j]['kind'] != 'travel':
            woven.add(h)
        joins[reg].append({"join": [frame_of(reg, tp), frame_of(reg, M.pt(j))]})
        count[(reg, 'A')] += 1

# --- B: re-aim fill pieces through the next road node ---
for k in (range(0) if FREE else range(len(M.groups))):
    g = M.groups[k]
    src = g.get('src')
    if k in woven or not src or not eligible(k) or (ONLY and g['region'] not in ONLY):
        continue
    reg, idx, sg = src
    ent = lay[reg][idx]
    if idx < fill_from[reg] or sg != 1 or not set(ent) <= {'piece', 'at', 'facing', 'spoke'}:
        continue
    two, n = region_share(reg)
    if n and two / n >= SHARE:
        continue
    name = ent['piece']; Sh = G.AUTH[name]
    ev = Sh.nodes[0][1]
    ax_nodes = [q for q, (uu, vv, _) in enumerate(Sh.nodes) if abs(uu) < 1e-6 and q != 0]
    if not ax_nodes:
        continue
    ti = max(ax_nodes, key=lambda q: Sh.nodes[q][1])
    lax = Sh.nodes[ti][1] - ev
    ids, c, u, a = axis(k)
    pa = M.pt(a)
    f0 = g['facing']; c0 = g['centre']
    R_ = frames[reg][3]
    theme = (lambda p: R_.theme(p)) if R_ else (lambda p: reg)
    ids_k = set(M.groups[k]['nodes'])
    was = [e_ for e_, ed in enumerate(M.edges) if not ed.get('dead') and (ed['a'] in ids_k or ed['b'] in ids_k)]
    M.kill_group(k)
    lo, hi = B.LINK_MIN + lax + GAP[0], B.LINK_MAX + lax + GAP[1]
    cands = []
    for j in M.near(pa, hi):
        if M.nodes[j]['kind'] != 'travel' or j == a or j in M.adj[a] or M.nodes[j].get('region') is None:
            continue
        d = math.dist(pa, M.pt(j))
        if d < lo:
            continue
        f = math.degrees(math.atan2(M.pt(j)[0] - pa[0], M.pt(j)[1] - pa[1]))
        cands.append((abs((f - f0 + 180) % 360 - 180), f, d, j))
    done = False
    for df, f, d, j in sorted(cands):
        if df > 100:
            break
        for sp in (1.4, 1.2, 1.6, 1.0, 1.7, 0.9):
            gap = d - sp - lax
            if not GAP[0] <= gap <= GAP[1]:
                continue
            cc = (pa[0] + (-ev + sp) * math.sin(math.radians(f)), pa[1] + (-ev + sp) * math.cos(math.radians(f)))
            new = B.place_xy(M, name, Sh.nodes, Sh.links, cc, f, [(a, 0)], theme(cc), lambda x, y: True, reg)
            if not new:
                continue
            tid = new[ti]
            if M.fits([], [(M.pt(tid), M.pt(j))], [tid, j]):
                M.link(tid, j); M.edges[-1]['ph'] = 'join'
                woven.add(len(M.groups) - 1)
                cx, cy, ax, _ = frames[reg]
                turns[(reg, idx)] = (round((f - ax + 180) % 360 - 180, 1), sp)
                joins[reg].append({"join": [frame_of(reg, M.pt(tid)), frame_of(reg, M.pt(j))]})
                count[(reg, 'B')] += 1
                done = True
                break
            M.kill_group(len(M.groups) - 1)
        if done:
            break
    if not done:            # put the piece back exactly as it was: its nodes and links revived
        for i in ids_k:
            M.nodes[i]['dead'] = False
        for e_ in was:
            ed = M.edges[e_]
            ed['dead'] = False
            M.deg[ed['a']] += 1; M.deg[ed['b']] += 1
            M.adj[ed['a']].add(ed['b']); M.adj[ed['b']].add(ed['a'])
        M.groups[k]['dead'] = False

# --- F (--free): join the nearest pairs, from any node ---
if FREE:
    cand = []
    for k in range(len(M.groups)):
        if not eligible(k) or (ONLY and M.groups[k]['region'] not in ONLY):
            continue
        ids = members(k)
        own = outside(ids)
        for i in ids:
            for j in M.near(M.pt(i), FREE_GAP[1]):
                if j in ids or j in own or M.nodes[j].get('dead') or M.nodes[j]['kind'] not in ('travel',) + SK:
                    continue
                h = gid.get(j)
                if M.nodes[j]['kind'] != 'travel' and (h is None or h == k):
                    continue
                d = math.dist(M.pt(i), M.pt(j))
                if d < FREE_GAP[0]:
                    continue
                pen = (0.3 if M.nodes[j]['kind'] == 'travel' else 0) + 0.2 * ((M.nodes[i]['kind'] == 'notable') + (M.nodes[j]['kind'] == 'notable'))
                cand.append((d + pen, i, j, k, h if M.nodes[j]['kind'] != 'travel' else None))
    cand.sort()
    for _, i, j, k, h in cand:
        reg = M.groups[k]['region']
        two, n = region_share(reg)
        if n and two / n >= FREE_SHARE:
            continue
        if not eligible(k) or (h is not None and not eligible(h)) or j in M.adj[i]:
            continue
        if M.hops(i, j, 3) <= 3:
            continue            # no tight loops: the two ends are already three steps apart or less
        if not M.fits([], [(M.pt(i), M.pt(j))], [i, j]):
            continue
        M.link(i, j); M.edges[-1]['ph'] = 'join'
        joins[reg].append({"join": [frame_of(reg, M.pt(i)), frame_of(reg, M.pt(j))]})
        count[(reg, 'F')] += 1

for reg in lay:
    two, n = region_share(reg)
    print('%-9s clusters %4d  with two links %4d (%2d %%)  joined as drawn %3d  re-aimed %3d  free joins %3d' % (
        reg, n, two, round(100 * two / max(1, n)), count[(reg, 'A')], count[(reg, 'B')], count[(reg, 'F')]))
tw = sum(region_share(r)[0] for r in lay); tn = sum(region_share(r)[1] for r in lay)
print('all       clusters %4d  with two links %4d (%2d %%)' % (tn, tw, round(100 * tw / max(1, tn))))

if WRITE:
    for reg, ents in lay.items():
        if not joins[reg] and not any(r == reg for r, _ in turns):
            continue
        out = []
        for k, e in enumerate(ents):
            if (reg, k) in turns:
                e = dict(e); e['facing'], e['spoke'] = turns[(reg, k)]
                if e['spoke'] == 1.6:
                    e.pop('spoke')
            out.append(e)
        out.append({"note": "Weave, free exits (experiment 2026-11-17, weave.py --free; needs cluster_rules.py --free-exits): the nearest pairs between neighbouring clusters, from any node."} if FREE else
                   {"note": "Weave (2026-11-17, authoring/weave.py; user: the tree felt disconnected, every cluster a one-link dead end): joins run straight on from a cluster's tip along its axis to the next road node or a facing cluster's tip; some fill pieces above were turned on their own road node so their axis runs through the next one."})
        out += joins[reg]
        lines = ['{', ' "%s": [' % reg] + ['  ' + json.dumps(e, ensure_ascii=False) + (',' if i < len(out) - 1 else '') for i, e in enumerate(out)] + [' ]', '}']
        open(paths[reg], 'w', encoding='utf-8').write('\n'.join(lines) + '\n')
    print('written')
