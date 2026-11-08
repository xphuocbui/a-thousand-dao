"""Audit every cluster shape in PoE 1 and PoE 2 (study only).

Usage: python -I audit.py <poe1 data.json> <poe2 tree.json> <out_dir>
Writes <out_dir>/audit.json (counts, examples) and <out_dir>/gallery.html (SVG thumbnails per shape), prints a summary.
A cluster is one PoE group's allocatable nodes (no masteries, no starts, no attribute-only travel groups).
"""
import collections
import html
import json
import math
import sys

src = open(__file__.replace("audit.py", "analyse.py"), encoding="utf-8").read().split("\nout = {}\n")[0]
P1, P2, OUT = sys.argv[1], sys.argv[2], sys.argv[3]
sys.argv = ["x", P1, P2, "."]
ns = {}
exec(compile(src, "analyse.py", "exec"), ns)


def turn(a, b, c):
    v1 = (b[0] - a[0], b[1] - a[1]); v2 = (c[0] - b[0], c[1] - b[1])
    return math.degrees(math.atan2(v1[0] * v2[1] - v1[1] * v2[0], v1[0] * v2[0] + v1[1] * v2[1]))


def classify(mem, inner, adj_all, nodes):
    V = len(mem)
    adj = collections.defaultdict(set)
    for a, b in inner:
        adj[a].add(b); adj[b].add(a)
    seen, comps = set(), 0
    for m in mem:
        if m in seen:
            continue
        comps += 1
        st = [m]
        while st:
            u = st.pop()
            if u in seen:
                continue
            seen.add(u)
            st += [w for w in adj[u] if w not in seen]
    E = len(inner)
    cyc = E - V + comps
    deg = {m: len(adj[m]) for m in mem}
    mx = max(deg.values())
    leaves = sum(1 for d in deg.values() if d == 1)
    arcs = sum(1 for a, b in inner if nodes[a]["o"] == nodes[b]["o"] and nodes[a]["o"] > 0)
    arc_share = arcs / max(1, E)
    P = lambda i: (nodes[i]["x"], nodes[i]["y"])
    if comps > 1:
        return "split (pieces joined outside)"
    if cyc == 0:
        if mx <= 2:
            if V <= 2:
                return "pair"
            ends = [m for m in mem if deg[m] == 1]
            path, prev, cur = [ends[0]], None, ends[0]
            while True:
                nxt = [w for w in adj[cur] if w != prev]
                if not nxt:
                    break
                prev, cur = cur, nxt[0]
                path.append(cur)
            ts = [turn(P(path[i]), P(path[i + 1]), P(path[i + 2])) for i in range(len(path) - 2)]
            if arc_share >= 0.6:
                return "arc (crescent)"
            if len(ts) >= 2 and sum(1 for i in range(len(ts) - 1) if ts[i] * ts[i + 1] < 0 and abs(ts[i]) > 25 and abs(ts[i + 1]) > 25) >= max(1, len(ts) // 2):
                return "zigzag"
            if all(abs(t) < 20 for t in ts):
                return "straight line (spoke)"
            return "bent line"
        d3 = [m for m in mem if deg[m] >= 3]
        if mx >= 4:
            return "star / fan (one hub, 4+ arms)"
        if len(d3) == 1:
            arms = sorted(len_arm(d3[0], w, adj) for w in adj[d3[0]])
            if leaves == 3 and arms[0] == arms[1] == arms[2]:
                return "tri-star (Y, equal arms)"
            return "fork (Y)"
        return "branching tree (2+ forks)"
    if cyc == 1:
        on = cycle_nodes(mem, adj)
        tails = V - len(on)
        if tails == 0:
            if len(on) == 4 and arc_share < 0.5:
                return "diamond / square (4)"
            if len(on) <= 6 and arc_share < 0.5:
                return "polygon (5-6, straight)"
            return "ring / wheel"
        hubs_on = sum(1 for m in on if deg[m] >= 3)
        if hubs_on == 1:
            return "lollipop (ring + tail)"
        return "ring with spokes"
    if cyc == 2:
        on = cycle_nodes(mem, adj)
        d3 = [m for m in mem if deg[m] >= 3]
        if len(d3) == 2 and V - len(on) == 0:
            return "lens / theta (two hubs, three lanes)"
        if any(deg[m] >= 4 for m in mem):
            return "figure-8 (two loops share a node)"
        return "double loop (ladder, two cells)"
    return "lattice (3+ loops)"


def len_arm(c, w, adj):
    n, prev, cur = 1, c, w
    while len(adj[cur]) == 2:
        nxt = [x for x in adj[cur] if x != prev][0]
        prev, cur, n = cur, nxt, n + 1
    return n


def cycle_nodes(mem, adj):
    # strip leaves repeatedly; what remains is on cycles
    deg = {m: len(adj[m]) for m in mem}
    alive = set(mem)
    changed = True
    while changed:
        changed = False
        for m in list(alive):
            if sum(1 for w in adj[m] if w in alive) <= 1:
                alive.discard(m); changed = True
    return alive


report, gallery = {}, []
for game, path in ((1, P1), (2, P2)):
    d, nodes, edges = ns["load"](path, game)
    adj_all = collections.defaultdict(set)
    for a, b in edges:
        adj_all[a].add(b); adj_all[b].add(a)
    grp = collections.defaultdict(list)
    for k, v in nodes.items():
        if v["t"] not in ("mastery", "start"):
            grp[v["g"]].append(k)
    counts, sizes, examples = collections.Counter(), collections.defaultdict(list), collections.defaultdict(list)
    by_size = collections.Counter()
    for g, mem in grp.items():
        if sum(1 for m in mem if nodes[m]["t"] == "attribute") > len(mem) / 2:
            continue
        if any(nodes[m]["t"] == "keystone" for m in mem):
            cls = "keystone group"
        else:
            ms = set(mem)
            inner = [(a, b) for a, b in edges if a in ms and b in ms]
            if len(mem) < 2:
                continue
            cls = classify(mem, inner, adj_all, nodes)
        nts = sum(1 for m in mem if nodes[m]["t"] == "notable")
        if nts == 0 and cls != "keystone group":
            continue
        counts[cls] += 1
        sizes[cls].append(len(mem))
        by_size[min(len(mem), 12)] += 1
        examples[cls].append((g, mem, nts))
    tot = sum(counts.values())
    print(f"\n===== PoE {game}: {tot} clusters with a notable or keystone =====")
    for cls, n in counts.most_common():
        sz = sorted(sizes[cls])
        print(f"  {n:4d} {100 * n / tot:5.1f}%  {cls:42s} size median {sz[len(sz) // 2]}, range {sz[0]}-{sz[-1]}")
    print("  cluster size distribution:", dict(sorted(by_size.items())))
    report[f"poe{game}"] = {"counts": dict(counts.most_common()), "size_median": {c: sorted(s)[len(s) // 2] for c, s in sizes.items()},
                            "sizes": dict(sorted(by_size.items()))}
    # gallery: up to 12 examples per class, preferring varied sizes
    for cls, n in counts.most_common():
        ex = sorted(examples[cls], key=lambda t: (-t[2], -len(t[1])))
        pick = ex[::max(1, len(ex) // 12)][:12]
        cards = []
        for g, mem, nts in pick:
            ms = set(mem)
            xs = [nodes[m]["x"] for m in mem]; ys = [nodes[m]["y"] for m in mem]
            cx, cy = (min(xs) + max(xs)) / 2, (min(ys) + max(ys)) / 2
            span = max(max(xs) - min(xs), max(ys) - min(ys), 300) * 1.35
            s = 120 / span
            T = lambda x, y: ((x - cx) * s + 70, (y - cy) * s + 70)
            parts = ['<svg viewBox="0 0 140 140" width="140" height="140">']
            for a, b in edges:
                if a in ms and b in ms:
                    pa, pb = T(nodes[a]["x"], nodes[a]["y"]), T(nodes[b]["x"], nodes[b]["y"])
                    if nodes[a]["o"] == nodes[b]["o"] and nodes[a]["o"] > 0:
                        gg = d["groups"].get(str(nodes[a]["g"])) if isinstance(d["groups"], dict) else d["groups"][nodes[a]["g"] - 1]
                        r = math.hypot(nodes[a]["x"] - gg["x"], nodes[a]["y"] - gg["y"]) * s
                        t1 = math.atan2(nodes[a]["y"] - gg["y"], nodes[a]["x"] - gg["x"]); t2 = math.atan2(nodes[b]["y"] - gg["y"], nodes[b]["x"] - gg["x"])
                        dd = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
                        parts.append(f'<path d="M{pa[0]:.1f},{pa[1]:.1f} A{r:.1f},{r:.1f} 0 0 {1 if dd > 0 else 0} {pb[0]:.1f},{pb[1]:.1f}" fill="none" stroke="#8a8f96" stroke-width="2"/>')
                    else:
                        parts.append(f'<line x1="{pa[0]:.1f}" y1="{pa[1]:.1f}" x2="{pb[0]:.1f}" y2="{pb[1]:.1f}" stroke="#8a8f96" stroke-width="2"/>')
                elif (a in ms) != (b in ms):
                    i, o = (a, b) if a in ms else (b, a)
                    pa, po = T(nodes[i]["x"], nodes[i]["y"]), T(nodes[o]["x"], nodes[o]["y"])
                    L = math.hypot(po[0] - pa[0], po[1] - pa[1]) or 1
                    q = (pa[0] + (po[0] - pa[0]) / L * 14, pa[1] + (po[1] - pa[1]) / L * 14)
                    parts.append(f'<line x1="{pa[0]:.1f}" y1="{pa[1]:.1f}" x2="{q[0]:.1f}" y2="{q[1]:.1f}" stroke="#d4501e" stroke-width="2"/>')
            for m in mem:
                p = T(nodes[m]["x"], nodes[m]["y"])
                r = {"notable": 6, "keystone": 8, "jewel": 5}.get(nodes[m]["t"], 3.5)
                col = {"notable": "#d9a520", "keystone": "#e04e6a", "jewel": "#2fa38f", "attribute": "#5b8bd6"}.get(nodes[m]["t"], "#9aa3ab")
                parts.append(f'<circle cx="{p[0]:.1f}" cy="{p[1]:.1f}" r="{r}" fill="{col}" stroke="#333" stroke-width=".6"/>')
            parts.append("</svg>")
            names = ", ".join(nodes[m]["name"] for m in mem if nodes[m]["t"] in ("notable", "keystone"))[:60]
            cards.append(f'<figure>{"".join(parts)}<figcaption>{html.escape(names)} · {len(mem)}</figcaption></figure>')
        gallery.append(f'<section><h2>PoE {game} · {html.escape(cls)} · {n} ({100 * n / tot:.0f} %)</h2><div class="row">{"".join(cards)}</div></section>')
json.dump(report, open(OUT + "/audit.json", "w", encoding="utf-8"), indent=1)
open(OUT + "/gallery.html", "w", encoding="utf-8").write(
    "<html><head><meta charset=utf-8><style>body{font:12px sans-serif;background:#f6f5f0;margin:8px}h2{font-size:14px;margin:10px 0 4px}"
    ".row{display:flex;flex-wrap:wrap;gap:4px}figure{margin:0;width:140px;background:#fff;border:1px solid #ddd}"
    "figcaption{padding:2px 4px;font-size:10px;color:#444;height:26px;overflow:hidden}</style></head><body>" + "".join(gallery) + "</body></html>")
print("ok")
