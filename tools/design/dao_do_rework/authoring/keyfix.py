"""Move crowded keystones (nearest node under 1.8, PoE's clearance) to a clear road node in their land's outer half.
Compiles every layout, drops the crowded keystones, then for each tries road nodes of the same region at v >= 55,
facings every 15 deg, 2.2 out (PoE: a lone node on one link), keeping 1.8 clear, 8 from other keystones, no crossing.
Prints the replacement entries in the land's frame.  usage: keyfix.py <layout dir>"""
import sys, json, math, glob
sys.path.insert(0, 'C:/Users/xphuo/IdeaProjects/my-game/tools/design/dao_do_rework/skeleton')
import layout as L
B = L.B
D = sys.argv[1]
lay = {}
for p in sorted(glob.glob(D + '/*.json')):
    for k, v in json.load(open(p, encoding='utf-8')).items():
        lay.setdefault(k, []).extend(v)
ORDER = ["fire", "earth", "metal", "water", "wood", "blend_fe", "blend_em", "blend_mw", "blend_ww", "blend_wf", "hub", "light", "thunder", "darkness", "shrine"]
lay = {k: lay[k] for k in sorted(lay, key=lambda k: ORDER.index(k) if k in ORDER else 99)}
B.DENSITY_CAP = 0
M, frames = L.base()
L.compile_layout(lay, M, frames, [])
live = lambda i: not M.nodes[i].get('dead')
keys = [i for i, n in enumerate(M.nodes) if n['kind'] == 'keystone' and live(i)]


def nearest(i):
    return min(math.dist(M.pt(i), M.pt(j)) for j in M.near(M.pt(i), 3.0) if j != i and live(j)) if any(j != i for j in M.near(M.pt(i), 3.0)) else 9


crowded = [i for i in keys if nearest(i) < 1.8]
for i in crowded:            # drop them and their link
    M.nodes[i]['dead'] = True
    for e in M.edges:
        if not e.get('dead') and i in (e['a'], e['b']):
            e['dead'] = True; M.deg[e['a']] -= 1; M.deg[e['b']] -= 1
            M.adj[e['a']].discard(e['b']); M.adj[e['b']].discard(e['a'])
placed = [M.pt(i) for i in keys if i not in crowded]
for i in crowded:
    reg = M.nodes[i].get('region')
    cx, cy, ax, _ = frames[reg]
    t = math.radians(ax)
    loc = lambda p: ((p[0] - cx) * math.cos(t) - (p[1] - cy) * math.sin(t), (p[0] - cx) * math.sin(t) + (p[1] - cy) * math.cos(t))
    old = loc(M.pt(i))
    best = None
    for a in range(len(M.nodes)):
        n = M.nodes[a]
        if not live(a) or n['kind'] != 'travel' or n.get('region') != reg:
            continue
        u, v = loc(M.pt(a))
        if v < 55 or abs(math.degrees(math.atan2(u, v))) > 27 or (old[0] > 0) != (u > 0):
            continue        # outer half, inside the land, same side as before
        for f in range(0, 360, 15):
            p = M.pt(a)
            q = (p[0] + 2.2 * math.sin(math.radians(f)), p[1] + 2.2 * math.cos(math.radians(f)))
            if any(math.dist(q, M.pt(j)) < 1.8 for j in M.near(q, 2.0) if live(j)):
                continue
            if any(math.dist(q, k) < 8 for k in placed):
                continue
            if not M.fits([q], [(p, q)], [a]):
                continue
            score = math.dist((u, v), old)
            if best is None or score < best[0]:
                best = (score, a, f, (u, v))
            break
    if best is None:
        print('no place for', reg, old); continue
    _, a, f, (u, v) = best
    p = M.pt(a)
    q = (p[0] + 2.2 * math.sin(math.radians(f)), p[1] + 2.2 * math.cos(math.radians(f)))
    placed.append(q)
    k = M.node(q, 'keystone', 'keystone', len(M.groups), region=reg)
    M.link(a, k)
    fl = (f - ax + 180) % 360 - 180
    print(json.dumps({"region": reg, "old": [round(old[0], 2), round(old[1], 2)], "new": {"keystone": [round(u, 2), round(v, 2)], "facing": fl}}))
