"""Push the lands outward to make room for a bigger centre (user 2026-11-15: a Chaos land of about 450 nodes).

Rigid, so nothing drawn is bent:
- road, start and other unclustered nodes move straight out from the centre by D (rings stay circles, spokes stay
  straight, the radial gaps between rings keep their size);
- every cluster moves as one piece, by the displacement of the node it hangs from (followed through other clusters
  when it hangs off one), so its shape and its mirror stay exact;
- an island (a region whose nodes all lie beyond the rim) moves as one piece, out along its own axis;
- the hub region does not move.
Arcs are redrawn through their moved ends and their moved midpoint. Used by build_tree.py (--push D).
"""
import collections
import math

KEEP = ("hub",)
ISLAND_CORE = 19.0       # an island's nodes this close to its start move as one piece


def _arc_mid(p, q, c):
    """The midpoint of the short arc from p to q round centre c."""
    r = math.dist(p, c)
    t1 = math.atan2(p[1] - c[1], p[0] - c[0]); t2 = math.atan2(q[1] - c[1], q[0] - c[0])
    d = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    t = t1 + d / 2
    return (c[0] + r * math.cos(t), c[1] + r * math.sin(t))


def _circle(a, b, c):
    """The centre of the circle through three points, or None when they are (nearly) in line."""
    ax, ay = a; bx, by = b; cx, cy = c
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    if abs(d) < 1e-9:
        return None
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return (ux, uy)


def displacements(nodes, edges, D, rim=76.0, keep=KEEP):
    """{node id: (dx, dy)} for a radial push of D. nodes: dicts with id, x, y, region, kind, cluster."""
    N = {n["id"]: n for n in nodes}
    adj = collections.defaultdict(set)
    for e in edges:
        adj[e["a"]].add(e["b"]); adj[e["b"]].add(e["a"])
    disp = {}
    radial = lambda n: (D * n["x"] / math.hypot(n["x"], n["y"]), D * n["y"] / math.hypot(n["x"], n["y"])) if math.hypot(n["x"], n["y"]) > 1e-9 else (0.0, 0.0)
    # islands: every node beyond the rim, so the region moves whole along the direction of its centre
    by_region = collections.defaultdict(list)
    for n in nodes:
        by_region[n["region"]].append(n)
    for reg, ns in by_region.items():
        if reg in keep:
            for n in ns:
                disp[n["id"]] = (0.0, 0.0)
        elif min(math.hypot(n["x"], n["y"]) for n in ns) > rim:
            # the island's core (within ISLAND_CORE of its start) moves whole along the start's direction; roads that
            # leave it (Darkness's shadow road down to Earth) move straight out like any road
            st = [n for n in ns if n.get("kind") == "start"]
            cx, cy = (st[0]["x"], st[0]["y"]) if st else (sum(n["x"] for n in ns) / len(ns), sum(n["y"] for n in ns) / len(ns))
            L = math.hypot(cx, cy)
            for n in ns:
                if n.get("cluster") is None and math.dist((n["x"], n["y"]), (cx, cy)) > ISLAND_CORE:
                    disp[n["id"]] = radial(n)
                elif n.get("cluster") is None:
                    disp[n["id"]] = (D * cx / L, D * cy / L)
    # roads and other unclustered nodes go straight out
    for n in nodes:
        if n["id"] not in disp and n.get("cluster") is None:
            disp[n["id"]] = radial(n)
    # clusters move with the node they hang from; a cluster hanging off another waits for that one
    mem = collections.defaultdict(list)
    for n in nodes:
        if n["id"] not in disp and n.get("cluster") is not None:
            mem[n["cluster"]].append(n["id"])
    pending = dict(mem)
    for _ in range(50):
        if not pending:
            break
        done = []
        for c, ids in pending.items():
            S = set(ids)
            anchors = [(j, i) for i in ids for j in adj[i] if j not in S]
            fixed = [(j, i) for j, i in anchors if j in disp]
            if not fixed and anchors:
                continue
            if fixed:
                # the anchor nearest the start of the figure: prefer a road node, then the closest one
                j, _ = min(fixed, key=lambda t: (N[t[0]].get("cluster") is not None, math.dist((N[t[0]]["x"], N[t[0]]["y"]), (N[t[1]]["x"], N[t[1]]["y"]))))
                v = disp[j]
            else:
                v = radial(N[ids[0]])      # an island of nodes with no links out: push it like a road
            for i in ids:
                disp[i] = v
            done.append(c)
        for c in done:
            del pending[c]
        if not done:      # a ring of clusters hanging off each other only: anchor the first one radially
            c, ids = next(iter(pending.items()))
            cx = sum(N[i]["x"] for i in ids) / len(ids); cy = sum(N[i]["y"] for i in ids) / len(ids)
            L = math.hypot(cx, cy) or 1.0
            for i in ids:
                disp[i] = (D * cx / L, D * cy / L)
            del pending[c]
    return disp


def _segd(p, a, b):
    dx, dy = b[0] - a[0], b[1] - a[1]; L = dx * dx + dy * dy
    t = max(0.0, min(1.0, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / L)) if L else 0.0
    return math.dist(p, (a[0] + t * dx, a[1] + t * dy))


def _cross(a, b, c, d):
    o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    return o(a, b, c) * o(a, b, d) < 0 and o(c, d, a) * o(c, d, b) < 0


def repair(view, edges, disp, spacing=0.6, graze=0.28, rounds=4):
    """Clusters that the push brought too close to something (a node within `spacing`, a link over a node, a
    crossing) try other rigid moves: straight out from their own centre, or the move of the cluster or road they
    clash with, scaled 0.8-1.2. The first move that clears them is kept. Straight links only are tested."""
    N = {n["id"]: n for n in view}
    mem = collections.defaultdict(list)
    for n in view:
        if n.get("cluster") is not None:
            mem[n["cluster"]].append(n["id"])
    inc = collections.defaultdict(list)
    for k, e in enumerate(edges):
        inc[e["a"]].append(k); inc[e["b"]].append(k)

    def pos(i, over=None):
        v = over.get(i, disp[i]) if over else disp[i]
        return (N[i]["x"] + v[0], N[i]["y"] + v[1])

    def grid_of(over=None):
        g = collections.defaultdict(list)
        for i in N:
            p = pos(i, over)
            g[(int(p[0] // 2), int(p[1] // 2))].append(i)
        return g

    def clashes(c, over, g):
        """Conflicts of cluster c's nodes and links with everything else, given trial moves `over`."""
        ids = set(mem[c]); out = set()
        for i in ids:
            p = pos(i, over)
            gx, gy = int(p[0] // 2), int(p[1] // 2)
            for cx in (gx - 1, gx, gx + 1):
                for cy in (gy - 1, gy, gy + 1):
                    for j in g.get((cx, cy), ()):
                        if j not in ids and math.dist(p, pos(j, over)) < spacing:
                            out.add(j)
        my_edges = {k for i in ids for k in inc[i]}

        def poly(k):
            e = edges[k]; a, b = e["a"], e["b"]; pa, pb = pos(a, over), pos(b, over)
            c0 = e.get("arc")
            if not c0:
                return [pa, pb]
            va = over.get(a, disp[a]) if over else disp[a]; vb = over.get(b, disp[b]) if over else disp[b]
            if va != vb:
                return [pa, pb]          # a road arc between two moving ends: tested as a chord
            c_ = (c0[0] + va[0], c0[1] + va[1]); r = math.dist(pa, c_)
            t1 = math.atan2(pa[1] - c_[1], pa[0] - c_[0]); t2 = math.atan2(pb[1] - c_[1], pb[0] - c_[0])
            dd = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
            n = max(2, int(abs(dd) * r / 0.3))
            return [(c_[0] + r * math.cos(t1 + dd * q / n), c_[1] + r * math.sin(t1 + dd * q / n)) for q in range(n + 1)]
        near = set()
        for i in ids:
            p = pos(i, over)
            gx, gy = int(p[0] // 2), int(p[1] // 2)
            for cx in range(gx - 2, gx + 3):
                for cy in range(gy - 2, gy + 3):
                    near.update(g.get((cx, cy), ()))
        near_edges = {k for j in near for k in inc[j]}
        mine = {k: poly(k) for k in my_edges}
        for k, pl in mine.items():
            a, b = edges[k]["a"], edges[k]["b"]
            for j in near:
                if j not in (a, b) and j not in ids and any(_segd(pos(j, over), u, w) < graze for u, w in zip(pl, pl[1:])):
                    out.add(j)
        # links of others that pass over this cluster's nodes, and crossings
        for k2 in near_edges:
            if k2 in mine:
                continue
            pl2 = poly(k2); c_, d_ = edges[k2]["a"], edges[k2]["b"]
            for i in ids:
                if i not in (c_, d_) and any(_segd(pos(i, over), u, w) < graze for u, w in zip(pl2, pl2[1:])):
                    out.add(c_)
            for k, pl in mine.items():
                a, b = edges[k]["a"], edges[k]["b"]
                if len({a, b, c_, d_}) == 4 and any(_cross(u, w, u2, w2) for u, w in zip(pl, pl[1:]) for u2, w2 in zip(pl2, pl2[1:])):
                    out.add(c_)
        return out

    fixed = 0
    for _ in range(rounds):
        g = grid_of()
        bad = [c for c in mem if clashes(c, None, g)]
        if not bad:
            break
        for c in bad:
            g = grid_of()
            hit = clashes(c, None, g)
            if not hit:
                continue
            ids = mem[c]
            cx = sum(N[i]["x"] for i in ids) / len(ids); cy = sum(N[i]["y"] for i in ids) / len(ids)
            L = math.hypot(cx, cy) or 1.0; D = math.hypot(*disp[ids[0]])
            base = disp[ids[0]]
            cands = [(base[0] * s, base[1] * s) for s in (0.9, 1.1, 0.8, 1.2)]       # the anchor's own move first: least tilt
            others = [(D * cx / L, D * cy / L)] + [disp[j] for j in hit]
            cands += [(v[0] * s, v[1] * s) for s in (1.0, 0.9, 1.1, 0.8, 1.2) for v in others]
            for v in cands:
                over = {i: v for i in ids}
                if not clashes(c, over, g):
                    for i in ids:
                        disp[i] = v
                    fixed += 1
                    break
    return fixed


def apply(nodes, edges, clusters, D, rim=76.0, keep=KEEP, xy=("x", "y")):
    """Move nodes, redraw arcs, move cluster centres, in place. clusters: dicts with 'nodes' (ids) and 'mastery' or
    'centre' (a point or None)."""
    X, Y = xy
    view = [{"id": n["id"], "x": n[X], "y": n[Y], "region": n.get("region"), "kind": n.get("kind"), "cluster": n.get("cluster")} for n in nodes]
    disp = displacements(view, edges, D, rim, keep)
    repair(view, edges, disp)
    old = {n["id"]: (n[X], n[Y]) for n in nodes}
    for n in nodes:
        dx, dy = disp[n["id"]]
        n[X] = round(n[X] + dx, 3); n[Y] = round(n[Y] + dy, 3)
    for e in edges:
        c = e.get("arc")
        if not c:
            continue
        p, q = old[e["a"]], old[e["b"]]
        m = _arc_mid(p, q, c)
        da, db = disp[e["a"]], disp[e["b"]]
        if da == db:
            e["arc"] = [round(c[0] + da[0], 3), round(c[1] + da[1], 3)]
            continue
        # a road arc: its midpoint moves straight out like the road nodes do
        L = math.hypot(*m) or 1.0
        Dm = math.hypot(*da) if math.hypot(*da) > 0 else math.hypot(*db)
        m2 = (m[0] + Dm * m[0] / L, m[1] + Dm * m[1] / L)
        p2 = (p[0] + da[0], p[1] + da[1]); q2 = (q[0] + db[0], q[1] + db[1])
        cc = _circle(p2, m2, q2)
        e["arc"] = [round(cc[0], 3), round(cc[1], 3)] if cc else None
    for c in clusters:
        ids = c.get("nodes") or []
        key = "mastery" if "mastery" in c else "centre"
        if c.get(key) and ids:
            dx, dy = disp[ids[0]]
            c[key] = [round(c[key][0] + dx, 3), round(c[key][1] + dy, 3)]
    return disp
