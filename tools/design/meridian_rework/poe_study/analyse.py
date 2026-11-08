"""Normalise the PoE 1 and PoE 2 passive trees into one graph form, measure them, export compact data.

Usage: python -I analyse.py <poe1 data.json> <poe2 tree.json> <out_dir>
Writes <out_dir>/trees.json (for the mock page) and <out_dir>/metrics.json, and prints a summary.
"""
import collections
import json
import math
import sys

P1, P2, OUT = sys.argv[1], sys.argv[2], sys.argv[3]

# PoE 1's 16- and 40-slot orbits are not evenly spaced (same table Path of Building uses).
A16 = [0, 30, 45, 60, 90, 120, 135, 150, 180, 210, 225, 240, 270, 300, 315, 330]
A40 = [0, 10, 20, 30, 40, 45, 50, 60, 70, 80, 90, 100, 110, 120, 130, 135, 140, 150, 160, 170, 180, 190, 200,
       210, 220, 225, 230, 240, 250, 260, 270, 280, 290, 300, 310, 315, 320, 330, 340, 350]


def angles_poe1(c):
    out = []
    for n in c["skillsPerOrbit"]:
        if n == 16:
            out.append([math.radians(a) for a in A16])
        elif n == 40:
            out.append([math.radians(a) for a in A40])
        else:
            out.append([2 * math.pi * i / n for i in range(n)])
    return out


def load(path, game):
    d = json.load(open(path, encoding="utf-8"))
    c = d["constants"]
    radii = c["orbitRadii"]
    ang = angles_poe1(c) if game == 1 else c["orbitAnglesByOrbit"]
    groups = d["groups"]
    gget = (lambda g: groups.get(str(g))) if isinstance(groups, dict) else (lambda g: groups[int(g) - 1] if 0 < int(g) <= len(groups) else None)
    nodes, edges = {}, set()
    for sid, n in d["nodes"].items():
        if not isinstance(n, dict) or "group" not in n:
            continue
        if n.get("ascendancyName") or n.get("isProxy") or n.get("isBloodline") or n.get("isBlighted") \
                or n.get("isOnlyImage") or n.get("expansionJewel") and not n.get("isJewelSocket"):
            continue
        g = gget(n["group"])
        if not g or g.get("isProxy"):
            continue
        o, i = n["orbit"], n["orbitIndex"]
        a = ang[o][i] if o < len(ang) and i < len(ang[o]) else 0
        r = radii[o] if o < len(radii) else 0
        x, y = g["x"] + r * math.sin(a), g["y"] - r * math.cos(a)
        start = ("classStartIndex" in n) or bool(n.get("classesStart"))
        if start:
            t = "start"
        elif n.get("isKeystone"):
            t = "keystone"
        elif n.get("isMastery"):
            t = "mastery"
        elif n.get("isJewelSocket"):
            t = "jewel"
        elif n.get("isNotable"):
            t = "notable"
        elif n.get("isAttribute") or n.get("name") in ("Strength", "Dexterity", "Intelligence"):
            t = "attribute"
        else:
            t = "small"
        nid = int(n.get("skill", sid))
        label = n.get("name", "")
        if start:
            label = "/".join(n.get("classesStart") or []) or label
        nodes[nid] = {"x": x, "y": y, "t": t, "g": int(n["group"]), "o": o, "name": label,
                      "stats": n.get("stats", []) if t in ("notable", "keystone", "jewel") else []}
        if game == 1:
            for m in n.get("out", []):
                edges.add(tuple(sorted((nid, int(m)))))
        else:
            for cn in n.get("connections", []):
                edges.add(tuple(sorted((nid, int(cn["id"])))))
    if game == 1:  # class starts in PoE 1 store the class index; name them
        names = [cl["name"] for cl in d["classes"]]
        for sid, n in d["nodes"].items():
            if isinstance(n, dict) and "classStartIndex" in n and int(n.get("skill", sid)) in nodes:
                nodes[int(n.get("skill", sid))]["name"] = names[n["classStartIndex"]]
    edges = {e for e in edges if e[0] in nodes and e[1] in nodes and e[0] != e[1]}
    # masteries (PoE 1) have no edges; keep them as markers only
    return d, nodes, edges


def load_ours(html_path):
    import re
    h = open(html_path, encoding="utf-8").read()
    m = re.search(r'<script id="data" type="application/json">(.*?)</script>', h, re.S)
    d = json.loads(m.group(1))
    K = {"root": "start", "keystone": "keystone", "apex": "keystone", "notable": "notable", "bridge_notable": "notable",
         "small": "small", "road": "attribute", "junction": "attribute", "gate": "attribute", "bridge": "attribute",
         "variant_road": "attribute"}
    nodes, edges, curves = {}, set(), {}
    for n in d["nodes"]:
        t = K.get(n["k"], "small")
        nodes[n["i"]] = {"x": n["x"] * 7, "y": n["y"] * 7, "t": t, "g": n["c"] if n["c"] is not None else -1, "o": 0,
                         "name": n["n"], "stats": [n.get("e") or ""] if t in ("notable", "keystone") and n.get("e") else []}
    for e in d["edges"]:
        k = tuple(sorted((e[0], e[1])))
        edges.add(k)
        if len(e) == 4:
            curves[k] = (e[2] * 7, e[3] * 7)
    return d, nodes, edges, curves


def bfs(adj, src, allowed):
    dist = {src: 0}
    q = collections.deque([src])
    while q:
        u = q.popleft()
        for v in adj[u]:
            if v not in dist and v in allowed:
                dist[v] = dist[u] + 1
                q.append(v)
    return dist


def bridges(adj, verts):
    """Tarjan bridges, iterative."""
    disc, low, out, timer = {}, {}, 0, [0]
    for s in verts:
        if s in disc:
            continue
        stack = [(s, None, iter(adj[s]))]
        disc[s] = low[s] = timer[0]; timer[0] += 1
        while stack:
            u, parent, it = stack[-1]
            nxt = next(it, None)
            if nxt is None:
                stack.pop()
                if parent is not None:
                    low[parent] = min(low[parent], low[u])
                    if low[u] > disc[parent]:
                        out += 1
                continue
            if nxt == parent:
                continue
            if nxt in disc:
                low[u] = min(low[u], disc[nxt])
            else:
                disc[nxt] = low[nxt] = timer[0]; timer[0] += 1
                stack.append((nxt, u, iter(adj[nxt])))
    return out


def measure(game, nodes, edges):
    adj = collections.defaultdict(set)
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    alloc = {k for k, v in nodes.items() if v["t"] != "mastery"}
    types = collections.Counter(v["t"] for v in nodes.values())
    deg = collections.Counter(len(adj[k]) for k in alloc)
    # connected components
    seen, comps = set(), 0
    for k in alloc:
        if k not in seen:
            comps += 1
            seen |= set(bfs(adj, k, alloc))
    E = len([e for e in edges if e[0] in alloc and e[1] in alloc])
    V = len(alloc)
    cyclomatic = E - V + comps
    br = bridges(adj, alloc)
    starts = [k for k, v in nodes.items() if v["t"] == "start"]
    keys = [k for k, v in nodes.items() if v["t"] == "keystone"]
    notables = [k for k, v in nodes.items() if v["t"] == "notable"]
    # each start: distances
    per_start = {}
    dists = {}
    for s in starts:
        dd = bfs(adj, s, alloc)
        dists[s] = dd
        kd = sorted(dd[k] for k in keys if k in dd)
        nd = [dd[k] for k in notables if k in dd]
        per_start[nodes[s]["name"]] = {
            "nearest_keystones": kd[:5],
            "notables_within": {str(r): sum(1 for x in nd if x <= r) for r in (10, 20, 30, 40, 60, 80, 123)},
            "keystones_within": {str(r): sum(1 for x in kd if x <= r) for r in (20, 40, 60, 80, 123)},
            "farthest": max(dd.values()),
        }
    # start-to-start distances
    ss = {}
    for i, a in enumerate(starts):
        for b in starts[i + 1:]:
            ss[f"{nodes[a]['name']}-{nodes[b]['name']}"] = dists[a].get(b)
    # territory: which start is closest to each node; share of contested nodes (within 3 of two starts)
    contested = 0
    owner = collections.Counter()
    for k in alloc:
        ds = sorted((dists[s].get(k, 999), nodes[s]["name"]) for s in starts)
        owner[ds[0][1]] += 1
        if len(ds) > 1 and ds[1][0] - ds[0][0] <= 3:
            contested += 1
    # groups (clusters)
    gnodes = collections.defaultdict(list)
    for k, v in nodes.items():
        if k in alloc:
            gnodes[v["g"]].append(k)
    gsize = collections.Counter()
    notable_groups = 0
    entry_counts = collections.Counter()
    small_between = []
    for g, ks in gnodes.items():
        if g == -1:
            continue
        ts = collections.Counter(nodes[k]["t"] for k in ks)
        gsize[min(len(ks), 20)] += 1
        if ts["notable"] or ts["keystone"]:
            notable_groups += 1
            # entries: edges leaving the group
            ext = sum(1 for k in ks for m in adj[k] if m in alloc and nodes[m]["g"] != g)
            entry_counts[min(ext, 6)] += 1
            small_between.append(ts["small"] + ts["attribute"])
    # keystone placement: degree and radius
    cx = sum(nodes[k]["x"] for k in alloc) / V
    cy = sum(nodes[k]["y"] for k in alloc) / V
    rad = lambda k: math.hypot(nodes[k]["x"] - cx, nodes[k]["y"] - cy)
    rmax = max(rad(k) for k in alloc)
    key_deg = collections.Counter(len(adj[k]) for k in keys)
    key_rad = [round(rad(k) / rmax, 2) for k in keys]
    # the travel share: small/attribute nodes with degree 2 (pure path)
    path_nodes = sum(1 for k in alloc if nodes[k]["t"] in ("small", "attribute") and len(adj[k]) == 2)
    # notable "payoff spacing": for each notable, distance to nearest other notable
    nn = []
    for k in notables[:]:
        dd = bfs(adj, k, alloc)
        others = [dd[m] for m in notables if m != k and m in dd]
        if others:
            nn.append(min(others))
    nn_hist = collections.Counter(min(x, 8) for x in nn)
    # ---- shape ----
    xs = [nodes[k]["x"] for k in alloc]; ys = [nodes[k]["y"] for k in alloc]
    w, h = max(xs) - min(xs), max(ys) - min(ys)
    rbins = collections.Counter(min(9, int(10 * rad(k) / rmax)) for k in alloc)
    rbins_not = collections.Counter(min(9, int(10 * rad(k) / rmax)) for k in notables)
    rbins_key = collections.Counter(min(9, int(10 * rad(k) / rmax)) for k in keys)
    sect = lambda k: int(((math.degrees(math.atan2(nodes[k]["x"] - cx, -(nodes[k]["y"] - cy))) + 360) % 360) // 30)
    abins = collections.Counter(sect(k) for k in alloc)
    start_ang = sorted(round((math.degrees(math.atan2(nodes[s]["x"] - cx, -(nodes[s]["y"] - cy))) + 360) % 360) for s in starts)
    start_rad = sorted(round(rad(s) / rmax, 2) for s in starts)
    # mirror symmetry: share of nodes with a node near their mirror image (left-right, x -> 2cx - x)
    grid = collections.defaultdict(list)
    for k in alloc:
        grid[(round(nodes[k]["x"] / 120), round(nodes[k]["y"] / 120))].append(k)
    def near(x, y, tol=120):
        gx, gy = round(x / 120), round(y / 120)
        for dx in (-1, 0, 1):
            for dy in (-1, 0, 1):
                for m in grid.get((gx + dx, gy + dy), []):
                    if math.hypot(nodes[m]["x"] - x, nodes[m]["y"] - y) <= tol:
                        return True
        return False
    sym_lr = sum(1 for k in alloc if near(2 * cx - nodes[k]["x"], nodes[k]["y"])) / V
    rot = {}
    for rdeg in (60, 120, 180):
        a = math.radians(rdeg)
        cnt = 0
        for k in alloc:
            x0, y0 = nodes[k]["x"] - cx, nodes[k]["y"] - cy
            cnt += near(cx + x0 * math.cos(a) - y0 * math.sin(a), cy + x0 * math.sin(a) + y0 * math.cos(a))
        rot[str(rdeg)] = round(cnt / V, 2)
    # edges: length and arc share
    lens = []
    arcs = 0
    for a, b in edges:
        if a in alloc and b in alloc:
            na, nb = nodes[a], nodes[b]
            if na["g"] == nb["g"] and na["o"] == nb["o"] and na["o"] > 0:
                arcs += 1
            lens.append(math.hypot(na["x"] - nb["x"], na["y"] - nb["y"]))
    lens.sort()
    q = lambda p: round(lens[int(p * (len(lens) - 1))])
    long_edges = sum(1 for L in lens if L > 600)
    # cluster form: by orbit usage of groups with >= 4 nodes
    forms = collections.Counter()
    for g, ks in gnodes.items():
        if len(ks) < 4 or g == -1:
            continue
        orbs = collections.Counter(nodes[k]["o"] for k in ks)
        main_o, main_n = orbs.most_common(1)[0]
        intra = sum(1 for k in ks for m in adj[k] if m in ks) // 2
        cyc = intra - len(ks) + 1
        forms["loop" if cyc >= 1 else ("star" if any(len([m for m in adj[k] if m in ks]) >= 3 for k in ks) else "line/arc")] += 1
    # empty space: share of a 40x40 grid over the bounding box holding no node
    cells = set((int(40 * (nodes[k]["x"] - min(xs)) / (w + 1)), int(40 * (nodes[k]["y"] - min(ys)) / (h + 1))) for k in alloc)
    fill = len(cells) / 1600
    shape = {
        "bbox_w_h": [round(w), round(h)], "aspect": round(w / h, 2),
        "radial_density_all": [rbins[i] for i in range(10)],
        "radial_density_notables": [rbins_not[i] for i in range(10)],
        "radial_density_keystones": [rbins_key[i] for i in range(10)],
        "sector_density_30deg": [abins[i] for i in range(12)],
        "start_angles_deg": start_ang, "start_radius_share": start_rad,
        "mirror_lr_share": round(sym_lr, 2), "rotational_match": rot,
        "edge_len_q10_50_90_max": [q(0.1), q(0.5), q(0.9), round(lens[-1])],
        "long_edges_over_600": long_edges, "arc_edge_share": round(arcs / max(1, len(lens)), 2),
        "cluster_forms_ge4": dict(forms), "grid_fill_40x40": round(fill, 2),
    }
    return {
        "game": game, "shape": shape,
        "nodes_total": V, "types": dict(types), "edges": E, "components": comps,
        "degree_hist": {str(k): v for k, v in sorted(deg.items())},
        "cyclomatic": cyclomatic, "bridges": br,
        "path_nodes_deg2_small": path_nodes,
        "starts": len(starts), "per_start": per_start, "start_to_start": ss,
        "territory": dict(owner), "contested_share": round(contested / V, 3),
        "groups_with_notables": notable_groups,
        "group_size_hist": {str(k): v for k, v in sorted(gsize.items())},
        "notable_group_exits_hist": {str(k): v for k, v in sorted(entry_counts.items())},
        "small_per_notable_group_mean": round(sum(small_between) / max(1, len(small_between)), 2),
        "keystone_degree_hist": {str(k): v for k, v in sorted(key_deg.items())},
        "keystone_radius_share_mean": round(sum(key_rad) / max(1, len(key_rad)), 2),
        "notable_nearest_notable_hist": {str(k): v for k, v in sorted(nn_hist.items())},
    }


def export(nodes, edges, curves=None):
    ids = sorted(nodes)
    ix = {k: i for i, k in enumerate(ids)}
    T = {"small": 0, "attribute": 1, "notable": 2, "keystone": 3, "jewel": 4, "mastery": 5, "start": 6}
    N = [[round(nodes[k]["x"]), round(nodes[k]["y"]), T[nodes[k]["t"]]] for k in ids]
    names = {ix[k]: [nodes[k]["name"], nodes[k]["stats"][:4]] for k in ids if nodes[k]["t"] in ("notable", "keystone", "jewel", "start")}
    E = []
    for a, b in sorted(edges):
        na, nb = nodes[a], nodes[b]
        if curves and (a, b) in curves:
            cx_, cy_ = curves[(a, b)]
            E.append([ix[a], ix[b], 2, round(cx_), round(cy_)])  # quadratic curve
        elif na["g"] == nb["g"] and na["o"] == nb["o"] and na["o"] > 0:
            E.append([ix[a], ix[b], 1])  # arc on the shared orbit
        else:
            E.append([ix[a], ix[b], 0])
    return {"n": N, "e": E, "names": names}


out = {}
metrics = {}
for game, path in ((1, P1), (2, P2)):
    d, nodes, edges = load(path, game)
    m = measure(game, nodes, edges)
    metrics[f"poe{game}"] = m
    ex = export(nodes, edges)
    # group centres for arcs
    gc = {}
    groups = d["groups"]
    for k, v in nodes.items():
        g = groups.get(str(v["g"])) if isinstance(groups, dict) else groups[v["g"] - 1]
        gc[v["g"]] = (round(g["x"]), round(g["y"]))
    ids = sorted(nodes)
    ex["gc"] = [list(gc[nodes[k]["g"]]) for k in ids]
    out[f"poe{game}"] = ex
if len(sys.argv) > 4:
    d, nodes, edges, curves = load_ours(sys.argv[4])
    m = measure(3, nodes, edges)
    metrics["ours"] = m
    ex = export(nodes, edges, curves)
    ex["gc"] = [[0, 0] for _ in sorted(nodes)]
    out["ours"] = ex
json.dump(out, open(f"{OUT}/trees.json", "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
json.dump(metrics, open(f"{OUT}/metrics.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
for k, m in metrics.items():
    print(k, json.dumps({x: m[x] for x in m if x not in ("per_start", "start_to_start", "territory")}, ensure_ascii=False))
    for s, v in m["per_start"].items():
        print("  ", s, v)
    print("  starts:", m["start_to_start"])
    print("  territory:", m["territory"])
