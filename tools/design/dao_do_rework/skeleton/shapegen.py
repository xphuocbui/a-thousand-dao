"""A catalogue of cluster shapes composed from PoE's parts (user 2026-11-15: PoE has far more creative cluster shapes).

Measured on the survey data: PoE 2 has 628 groups of 2+ nodes in 512 distinct shapes (453 used once); PoE 1 has 109
shapes for 409 groups. Its groups are mostly arcs of its fixed circles (half rings, three-quarter rings, C shapes,
rings round a hub, rings inside rings), drawn as curves. So instead of a library, shapes are composed:
- an outer arc on one circle, symmetric about the group's line, from the entry (at 180, next to what it joins) round
  both ways by k steps, open (a horseshoe with gold tips) or closed (a ring with gold at the top);
- optionally an inner arc on a smaller circle, joined on the axis by a spoke;
- optionally a hub at the centre, joined by a spoke on the axis.
Every candidate keeps the cluster rules (mirrored about its line incl. notables, no dead ends, no notable at the door,
at least one notable, no unrewarded loop more than 2 steps longer than the short way) and keeps nodes 0.72 apart. The
rules keep the groups symmetric, where most of PoE's are not: that is the user's rule 1.

Usage: python -I tools/design/dao_do_rework/skeleton/shapegen.py   (prints the catalogue size)
"""
import itertools
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import cluster_rules as cr  # noqa: E402
import mesh as B  # noqa: E402

MIN_GAP = 0.72


def _xy(circle, ang):
    r = B.R[circle]
    return (r * math.sin(math.radians(ang)), r * math.cos(math.radians(ang)))


def arc_nodes(circle, step, k):
    """Angles of an arc from the entry at 180 round both ways by k steps of `step` degrees (closed if it meets at 0)."""
    angs = [180.0]
    for j in range(1, k + 1):
        for s in (1, -1):
            a = (180.0 + s * step * j) % 360
            if all(abs(((a - b) + 180) % 360 - 180) > 1e-6 for b in angs):
                angs.append(a)
    return angs


def compose(outer, step, k, inner=None, hub=False, gold="tips"):
    """One candidate. outer: circle index; step: degrees between nodes; k: steps each way from the entry. inner:
    (circle, step, k2, joined at 'top' or 'bottom') or None. hub: a centre node joined on the axis. gold: 'tips' (the
    outer arc's two far ends), 'top' (the outer arc's node at 0, when closed), 'hub', 'inner' (the inner arc's tips)."""
    nodes, links = [], []

    def add(c, a, role="s"):
        nodes.append([c, round(a % 360, 4), role])
        return len(nodes) - 1
    oa = arc_nodes(outer, step, k)
    # order: walk round from the right tip to the left tip through the entry, so arcs link neighbours
    def rel(a):
        return ((a - 180 + 180) % 360) - 180
    oa_sorted = sorted(oa, key=rel)
    ids = [add(outer, a) for a in oa_sorted]
    closed = len(oa) * step >= 360 - 1e-6
    for x, y in zip(ids, ids[1:]):
        links.append((x, y, 1))
    if closed and len(ids) > 2:
        links.append((ids[-1], ids[0], 1))
    entry = next(i for i in ids if abs(nodes[i][1] - 180) < 1e-6)
    tips = [ids[0], ids[-1]] if not closed else []
    top = next((i for i in ids if abs(nodes[i][1]) < 1e-6 or abs(nodes[i][1] - 360) < 1e-6), None)
    hub_id = None
    if hub:
        hub_id = add(0, 0.0)
        links.append((entry, hub_id, 0))
        if top is not None:
            links.append((hub_id, top, 0))
    inner_ids = []
    if inner:
        ic, istep, ik, where = inner
        ia = arc_nodes(ic, istep, ik)
        ia = [((a + 180) % 360) if where == "top" else a for a in ia]      # an arc opening down hangs from the top
        ia_sorted = sorted(ia, key=lambda a: ((a + 180) % 360) - 180)
        inner_ids = [add(ic, a) for a in ia_sorted]
        for x, y in zip(inner_ids, inner_ids[1:]):
            links.append((x, y, 1))
        if len(ia) * istep >= 360 - 1e-6 and len(inner_ids) > 2:
            links.append((inner_ids[-1], inner_ids[0], 1))
        # the spoke on the axis: from the outer arc's node there (or the hub) to the inner arc's node there
        anchor_ang = 0.0 if where == "top" else 180.0
        ia_on = next((i for i in inner_ids if abs(((nodes[i][1] - anchor_ang) + 180) % 360 - 180) < 1e-6), None)
        oa_on = top if where == "top" else entry
        if ia_on is None or oa_on is None:
            return None
        links.append((oa_on, ia_on, 0))
    # gold: any combination of the outer tips, the top, the hub and the inner arc's tips (or its far node when closed)
    golds = (gold,) if isinstance(gold, str) else tuple(gold)
    for gd in golds:
        if gd == "tips" and tips:
            for i in tips:
                nodes[i][2] = "N"
        elif gd == "top" and top is not None:
            nodes[top][2] = "N"
        elif gd == "hub" and hub_id is not None:
            nodes[hub_id][2] = "N"
        elif gd == "inner" and inner_ids:
            closed_in = len(inner_ids) * inner[1] >= 360 - 1e-6
            if len(inner_ids) >= 2 and not closed_in:
                nodes[inner_ids[0]][2] = "N"; nodes[inner_ids[-1]][2] = "N"
            else:
                far = max(inner_ids, key=lambda i: abs(((nodes[i][1] - (180.0 if inner[3] == "top" else 0.0)) + 180) % 360 - 180))
                nodes[far][2] = "N"
        else:
            return None
    # the entry must come first
    order = [entry] + [i for i in range(len(nodes)) if i != entry]
    remap = {o: n for n, o in enumerate(order)}
    nodes = [nodes[o] for o in order]
    links = [(remap[a], remap[b], f) for a, b, f in links]
    return [tuple(n) for n in nodes], links


def _self_cross(pts, links):
    """True when two links of a shape cross (arcs sampled round the shape's centre)."""
    P = [_xy(c, a) for c, a, _ in pts]

    def poly(i, j, f):
        if not f:
            return [P[i], P[j]]
        r = math.hypot(*P[i]); t1 = math.atan2(P[i][1], P[i][0]); t2 = math.atan2(P[j][1], P[j][0])
        dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        n = max(2, int(abs(dt) * r / 0.15))
        return [(r * math.cos(t1 + dt * k / n), r * math.sin(t1 + dt * k / n)) for k in range(n + 1)]
    o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    L = [(a, b, poly(a, b, f)) for a, b, f in links]
    for x in range(len(L)):
        for y in range(x + 1, len(L)):
            if {L[x][0], L[x][1]} & {L[y][0], L[y][1]}:
                continue
            for p1, p2 in zip(L[x][2], L[x][2][1:]):
                for p3, p4 in zip(L[y][2], L[y][2][1:]):
                    if o(p1, p2, p3) * o(p1, p2, p4) < -1e-12 and o(p3, p4, p1) * o(p3, p4, p2) < -1e-12:
                        return True
    return False


def valid(shape):
    pts, links = shape
    if _self_cross(pts, links):
        return False
    P = [_xy(c, a) for c, a, _ in pts]
    if len(pts) < 3 or len(pts) > 13:
        return False
    # connected, and gold kept to about a third of the nodes (PoE: mostly one or two notables a group)
    adj = {i: set() for i in range(len(pts))}
    for a, b, _ in links:
        adj[a].add(b); adj[b].add(a)
    seen, st = {0}, [0]
    while st:
        u = st.pop()
        for v in adj[u]:
            if v not in seen:
                seen.add(v); st.append(v)
    if len(seen) != len(pts):
        return False
    if sum(1 for _, _, r in pts if r == "N") > max(2, len(pts) // 3):
        return False
    for i in range(len(P)):
        for j in range(i + 1, len(P)):
            if math.dist(P[i], P[j]) < MIN_GAP:
                return False
    # the template checker wants the entry at (0, 0) and +y away from what it joins
    e = P[0]
    Q = [(x - e[0], y - e[1]) for x, y in P]
    edges = [(i, j, (0.0 - e[0], 0.0 - e[1])) if f else (i, j) for i, j, f in links]
    res = cr.check_cluster(cr.Graph(cr.template_graph(Q, "".join(r for _, _, r in pts), edges)), 0)
    return all(res[k] in (True, None) for k in ("R1", "R2", "R3", "R4")) and res["max_slack"] <= 2


def catalogue():
    out, seen = {}, set()
    steps = {2: (45, 60), 3: (30, 45, 60), 4: (30, 45), 5: (20, 30)}
    for outer, sts in steps.items():
        for step in sts:
            for k in range(1, int(180 // step) + 1):
                for hub in (False, True):
                    inners = [None]
                    for ic in range(2, outer):
                        if B.R[outer] - B.R[ic] < 0.75:
                            continue
                        for ist in steps.get(ic, ()):
                            for ik in range(1, int(180 // ist) + 1):
                                for where in ("top", "bottom"):
                                    inners.append((ic, ist, ik, where))
                    for inner in inners:
                        feats = ["tips", "top"] + (["hub"] if hub else []) + (["inner"] if inner else [])
                        for gold in [c for n_ in range(1, 4) for c in itertools.combinations(feats, n_)]:
                            sh = compose(outer, step, k, inner, hub, gold)
                            if not sh or not valid(sh):
                                continue
                            key = (tuple(sorted(sh[0])), tuple(sorted((min(a, b), max(a, b), f) for a, b, f in sh[1])))
                            if key in seen:
                                continue
                            seen.add(key)
                            name = f"o{outer}s{step}k{k}" + (f"-i{inner[0]}s{inner[1]}k{inner[2]}{inner[3][0]}" if inner else "") + ("-h" if hub else "") + "-" + "+".join(gold)
                            out[name] = sh
    return out


STEPS = {2: (45, 60, 90), 3: (30, 45, 60), 4: (30, 45), 5: (20, 30)}


def random_shape(rng):
    """A freely composed symmetric shape: up to three circles, each with a symmetric slot set (an arc round the entry,
    an arc round the top, a full ring, or mirrored pairs), neighbours along a circle linked as arcs, spokes between
    circles where two nodes share an angle, an optional hub; every dead end gold, plus optional gold on the axis."""
    orbits = sorted(rng.sample([2, 3, 4, 5], rng.choice((1, 2, 2, 3))), reverse=True)
    nodes = {}

    def add(c, a):
        a = round(a % 360, 4)
        nodes.setdefault((c, a), len(nodes))
        return nodes[(c, a)]
    arcs = []
    for n_, c in enumerate(orbits):
        step = rng.choice(STEPS[c])
        kind = rng.choice(("bottom", "bottom", "ring", "ring")) if n_ == 0 else rng.choice(("bottom", "top", "ring", "ring", "pairs"))
        if kind == "ring":
            angs = [180 + step * j for j in range(int(360 // step))] if 360 % step == 0 else None
        elif kind == "pairs":
            a = rng.choice([x for x in range(step, 180, step)])
            angs = [a, -a]
        else:
            kmax = max(1, int(180 // step))
            k = rng.choice([kmax, kmax, max(1, kmax - 1), max(1, kmax - 1), rng.randint(1, kmax)])     # deep C shapes, as PoE's
            base = 180 if kind == "bottom" else 0
            angs = sorted({(base + s * step * j) % 360 for j in range(k + 1) for s in (1, -1)}, key=lambda x: ((x - base + 180) % 360) - 180)
        if not angs:
            return None
        ids = [add(c, a) for a in angs]
        arcs.append((c, step, kind, sorted(set(ids), key=lambda i: ((list(nodes)[i][1] - (0 if kind == "top" else 180) + 180) % 360) - 180)))
    links = set()
    keys = list(nodes)
    for c, step, kind, ids in arcs:
        if kind == "pairs":
            continue
        for x, y in zip(ids, ids[1:]):
            links.add((min(x, y), max(x, y), 1))
        if kind == "ring" and len(ids) > 2:
            links.add((min(ids[0], ids[-1]), max(ids[0], ids[-1]), 1))
    # spokes between circles at shared angles (adjacent used circles only)
    for c1, c2 in zip(orbits, orbits[1:]):
        for (c, a), i in list(nodes.items()):
            if c != c1:
                continue
            j = nodes.get((c2, a))
            if j is not None:
                links.add((min(i, j), max(i, j), 0))
    hub = None
    if rng.random() < 0.35:
        hub = add(0, 0.0)
        keys = list(nodes)
        for ang in (180.0, 0.0):
            inn = [nodes[(c, ang)] for c in sorted(orbits) if (c, ang) in nodes]
            if inn:
                links.add((min(hub, inn[0]), max(hub, inn[0]), 0))
    keys = list(nodes)
    if (orbits[0], 180.0) not in nodes:
        return None
    entry = nodes[(orbits[0], 180.0)]
    deg = {i: 0 for i in range(len(keys))}
    for a, b, _ in links:
        deg[a] += 1; deg[b] += 1
    roles = ["s"] * len(keys)
    for i, dg in deg.items():
        if dg <= 1 and i != entry:
            roles[i] = "N"
    if rng.random() < 0.5:
        axis = [i for i, (c, a) in enumerate(keys) if a in (0.0,) and i != entry]
        if axis:
            roles[max(axis, key=lambda i: B.R[keys[i][0]])] = "N"
    if hub is not None and rng.random() < 0.4:
        roles[hub] = "N"
    order = [entry] + [i for i in range(len(keys)) if i != entry]
    remap = {o: n for n, o in enumerate(order)}
    pts = [(keys[o][0], keys[o][1], roles[o]) for o in order]
    lk = [(remap[a], remap[b], f) for a, b, f in sorted(links)]
    return pts, lk


def random_straight(rng):
    """PoE 2's straight compositions (2026-11-15: 57 % of its links inside groups are straight, ours 15 %): a hub with
    radial spokes (a starburst), radial chains out across two or three circles, a trident, a straight diamond, with an
    optional arc capping the ray tips. Nodes stay on PoE's circles and slots; every link is straight unless capped."""
    kind = rng.choice(("burst", "burst", "chains", "trident", "diamond", "diamond2"))
    nodes = {}

    def add(c, a):
        a = round(a % 360, 4)
        nodes.setdefault((c, a), len(nodes))
        return nodes[(c, a)]
    links = set()
    L = lambda i, j, f=0: links.add((min(i, j), max(i, j), f))
    if kind in ("burst", "chains", "trident"):
        step = rng.choice((30, 45, 60)) if kind != "trident" else rng.choice((30, 45))
        n_side = rng.randint(1, max(1, int(150 // step))) if kind != "trident" else 1
        angs = [0.0] * (rng.random() < 0.7 or kind == "trident") + [s * step * j for j in range(1, n_side + 1) for s in (1, -1)]
        angs = [a for a in angs if abs(((a - 180) + 180) % 360 - 180) > 25] or [0.0]
        circles = sorted(rng.sample((2, 3, 4, 5), 2 if kind == "burst" else 3)) if kind != "trident" else [2, 4]
        entry_c = rng.choice((2, 3))
        entry = add(entry_c, 180.0)
        hub = add(0, 0.0)
        L(entry, hub)
        for a in angs:
            prev = hub
            for c in circles:
                if kind == "burst" and c == circles[0] and rng.random() < 0.3:
                    continue
                cur = add(c, a)
                L(prev, cur)
                prev = cur
        if rng.random() < 0.3 and len(angs) >= 3:      # an arc capping the ray tips
            tips = sorted((nodes[(circles[-1], round(a % 360, 4))] for a in angs if (circles[-1], round(a % 360, 4)) in nodes),
                          key=lambda i: ((list(nodes)[i][1] + 180) % 360))
            for x, y in zip(tips, tips[1:]):
                kx, ky = list(nodes)[x][1], list(nodes)[y][1]
                if abs(((kx - ky) + 180) % 360 - 180) <= 60:
                    L(x, y, 1)
    else:
        c = rng.choice((2, 3, 4))
        side = rng.choice((60, 90, 120)) if c >= 3 else 90
        entry = add(c, 180.0)
        top = add(c, 0.0)
        for sg in (1, -1):
            sd = add(c, sg * side)
            L(entry, sd); L(sd, top)
        if kind == "diamond2":      # a second, smaller diamond on top: the old top becomes its bottom
            c2 = c + 1 if c < 5 else c
            if c2 != c:
                t2 = add(c2 + 0, 0.0)
                for sg in (1, -1):
                    s2 = add(c2, sg * 30.0)
                    L(top, s2); L(s2, t2)
        if rng.random() < 0.5:
            hub = add(0, 0.0)
            L(entry, hub); L(hub, top)
    keys = list(nodes)
    deg = {i: 0 for i in range(len(keys))}
    for a, b, _ in links:
        deg[a] += 1; deg[b] += 1
    entry_i = [i for i, (c, a) in enumerate(keys) if a == 180.0][0]
    roles = ["N" if deg[i] <= 1 and i != entry_i else "s" for i in range(len(keys))]
    far_axis = [i for i, (c, a) in enumerate(keys) if a == 0.0 and i != entry_i]
    if far_axis and rng.random() < 0.6:
        roles[max(far_axis, key=lambda i: B.R[keys[i][0]])] = "N"
    if (0, 0.0) in nodes and rng.random() < 0.35:
        roles[nodes[(0, 0.0)]] = "N"
    order = [entry_i] + [i for i in range(len(keys)) if i != entry_i]
    remap = {o: n for n, o in enumerate(order)}
    pts = [(keys[o][0], keys[o][1], roles[o]) for o in order]
    lk = [(remap[a], remap[b], f) for a, b, f in sorted(links)]
    return pts, lk


def chains():
    """Straight chains on the axis, PoE's commonest small group (2-3 small nodes before one notable): the entry on one
    circle at 180, the centre, then one or two nodes at 0 on growing circles, the last gold."""
    out = {}
    for ce in (2, 3):
        for tail in ((2,), (3,), (4,), (2, 4), (3, 5), (2, 5)):
            pts = [(ce, 180.0, "s"), (0, 0.0, "s")] + [(c, 0.0, "s") for c in tail]
            pts[-1] = (pts[-1][0], 0.0, "N")
            links = [(i, i + 1, 0) for i in range(len(pts) - 1)]
            sh = (pts, links)
            if valid(sh):
                out["c%d-%s" % (ce, "".join(map(str, tail)))] = sh
    return out


def straight_all(tries=30000, seed=11):
    import random
    out, seen = dict(chains()), set()
    rng = random.Random(seed)
    for t in range(tries):
        sh = random_straight(rng)
        if not sh or not valid(sh):
            continue
        key = (tuple(sorted(sh[0])), tuple(sorted((min(a, b), max(a, b), f) for a, b, f in sh[1])))
        if key in seen:
            continue
        seen.add(key)
        out[f"t{t}"] = sh
    return out


def valid_through(shape, k):
    """A through shape (a road runs in at the entry, node 0, and out at node k on the far end of the axis): both ports
    minor, nodes 0.72 apart, at least one notable, the cluster rules with the two outside links."""
    pts, links = shape
    if _self_cross(pts, links):
        return False
    if pts[0][2] == "N" or pts[k][2] == "N" or not any(r == "N" for _, _, r in pts) or not (3 <= len(pts) <= 13):
        return False
    if sum(1 for _, _, r in pts if r == "N") > max(2, len(pts) // 3):
        return False
    adj = {i: set() for i in range(len(pts))}
    for a, b, _ in links:
        adj[a].add(b); adj[b].add(a)
    seen, st = {0}, [0]
    while st:
        u = st.pop()
        for v in adj[u]:
            if v not in seen:
                seen.add(v); st.append(v)
    if len(seen) != len(pts):
        return False
    P = [_xy(c, a) for c, a, _ in pts]
    for i in range(len(P)):
        for j in range(i + 1, len(P)):
            if math.dist(P[i], P[j]) < MIN_GAP:
                return False
    kinds = {"s": "small", "N": "notable"}
    e0 = P[0]
    nodes = [{"id": 0, "kind": "travel", "x": e0[0], "y": e0[1] - 1.0, "cluster": None},
             {"id": 1, "kind": "travel", "x": P[k][0], "y": P[k][1] + 1.0, "cluster": None}]
    for j, ((x, y), (_, _, ro)) in enumerate(zip(P, pts)):
        nodes.append({"id": j + 2, "kind": kinds[ro], "x": x, "y": y, "cluster": 0})
    es = [{"a": 0, "b": 2}, {"a": 1, "b": k + 2}] + [{"a": a + 2, "b": b + 2} for a, b, _ in links]
    G = cr.Graph({"nodes": nodes, "edges": es, "clusters": [{"id": 0, "form": "through"}]})
    res = cr.check_cluster(G, 0)
    return all(res[x] in (True, None) for x in ("R1", "R2", "R3", "R4")) and res["max_slack"] <= 2


def through_all(seed=13, tries=60000):
    """Through shapes: composed shapes (arcs and straight) whose far node on the axis is made the minor exit, kept when
    they pass as two-port groups. Returns {name: (shape, exit index)}."""
    import random
    rng = random.Random(seed)
    out, seen = {}, set()
    for ce in (2, 3):      # beads: in, a notable at the centre, out
        for cx in (2, 3):
            sh = ([(ce, 180.0, "s"), (0, 0.0, "N"), (cx, 0.0, "s")], [(0, 1, 0), (1, 2, 0)])
            if valid_through(sh, 2):
                out["bead%d%d" % (ce, cx)] = (sh, 2)
    for t in range(tries):
        sh = random_shape(rng) if t % 2 else random_straight(rng)
        if not sh:
            continue
        pts, links = sh
        proj = [B.R[c] * math.cos(math.radians(a)) for c, a, _ in pts]
        top = max(proj)
        far = [i for i, (c, a, _) in enumerate(pts) if i and abs(a % 360) < 1e-6 and abs(proj[i] - top) < 1e-6]
        if len(far) != 1 or sum(1 for p_ in proj if abs(p_ - top) < 1e-6) != 1:
            continue
        k = far[0]
        pts = [list(p_) for p_ in pts]
        pts[k][2] = "s"
        sh = ([tuple(p_) for p_ in pts], links)
        if not valid_through(sh, k):
            continue
        key = (tuple(sorted(sh[0])), tuple(sorted((min(a, b), max(a, b), f) for a, b, f in links)))
        if key in seen:
            continue
        seen.add(key)
        out["x%d" % t] = (sh, k)
    return out


def catalogue_all(tries=40000, seed=7):
    import random
    out = catalogue()
    seen = {(tuple(sorted(p)), tuple(sorted((min(a, b), max(a, b), f) for a, b, f in l))) for p, l in out.values()}
    rng = random.Random(seed)
    for t in range(tries):
        sh = random_shape(rng)
        if not sh or not valid(sh):
            continue
        key = (tuple(sorted(sh[0])), tuple(sorted((min(a, b), max(a, b), f) for a, b, f in sh[1])))
        if key in seen:
            continue
        seen.add(key)
        out[f"r{t}"] = sh
    return out


if __name__ == "__main__":
    th = through_all()
    sz = {}
    for n, ((pts, _), k) in th.items():
        sz[len(pts)] = sz.get(len(pts), 0) + 1
    print("through shapes", len(th), "by size", dict(sorted(sz.items())))
    st = straight_all()
    sz = {}
    for n, (pts, _) in st.items():
        sz[len(pts)] = sz.get(len(pts), 0) + 1
    print("straight shapes", len(st), "by size", dict(sorted(sz.items())))
    cat = catalogue_all()
    sizes = {}
    for n, (pts, _) in cat.items():
        sizes[len(pts)] = sizes.get(len(pts), 0) + 1
    print("shapes", len(cat), "by size", dict(sorted(sizes.items())))
    raise SystemExit
    cat = catalogue()
    sizes = {}
    for n, (pts, _) in cat.items():
        sizes[len(pts)] = sizes.get(len(pts), 0) + 1
    print("shapes", len(cat), "by size", dict(sorted(sizes.items())))
