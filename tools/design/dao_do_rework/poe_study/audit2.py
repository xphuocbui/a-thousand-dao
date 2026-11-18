"""Clusters per travel node, cluster size by distance from the centre, small clusters next to big ones (study only)."""
import collections
import math
import sys

src = open(__file__.replace("audit2.py", "analyse.py"), encoding="utf-8").read().split("\nout = {}\n")[0]
P1, P2 = sys.argv[1], sys.argv[2]
sys.argv = ["x", P1, P2, "."]
ns = {}
exec(compile(src, "analyse.py", "exec"), ns)
for game, path in ((1, P1), (2, P2)):
    d, nodes, edges = ns["load"](path, game)
    adj = collections.defaultdict(set)
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    grp = collections.defaultdict(list)
    for k, v in nodes.items():
        if v["t"] not in ("mastery", "start"):
            grp[v["g"]].append(k)
    clus = {g: m for g, m in grp.items() if any(nodes[i]["t"] == "notable" for i in m)
            and sum(1 for i in m if nodes[i]["t"] == "attribute") <= len(m) / 2}
    owner = {i: g for g, m in clus.items() for i in m}
    R = max(math.hypot(v["x"], v["y"]) for v in nodes.values())
    travel = [k for k, v in nodes.items() if v["t"] == "attribute"]
    per = collections.Counter()
    hubs = {}
    for t in travel:
        gs = {owner[w] for w in adj[t] if w in owner}
        per[min(len(gs), 4)] += 1
        hubs[t] = gs
    print(f"\n== PoE {game}: clusters hanging off one travel node: {dict(sorted(per.items()))}")
    with1 = sum(v for k, v in per.items() if k >= 1)
    print(f"   of travel nodes with any cluster, share with 2+: {sum(v for k, v in per.items() if k >= 2) / max(1, with1):.0%}")
    bins = collections.defaultdict(list)
    for g, m in clus.items():
        cx = sum(nodes[i]["x"] for i in m) / len(m); cy = sum(nodes[i]["y"] for i in m) / len(m)
        f = math.hypot(cx, cy) / R
        bins["inner third" if f < 0.45 else "middle" if f < 0.72 else "outer third"].append(len(m))
    for b in ("inner third", "middle", "outer third"):
        s = sorted(bins[b])
        if s:
            print(f"   {b:12s}: {len(s)} clusters, median size {s[len(s) // 2]}, mean {sum(s) / len(s):.1f}, share <=4 nodes {sum(1 for x in s if x <= 4) / len(s):.0%}, share >=7 {sum(1 for x in s if x >= 7) / len(s):.0%}")
    # small clusters: does their travel node also carry a bigger one?
    small, buddy = 0, 0
    for g, m in clus.items():
        if len(m) > 4:
            continue
        ts = {w for i in m for w in adj[i] if nodes[w]["t"] == "attribute"}
        if not ts:
            continue
        small += 1
        if any(len(clus[h]) >= 6 for t in ts for h in hubs[t] if h != g):
            buddy += 1
    print(f"   small clusters (<=4) on a travel node: {small}; of those sharing that node with a 6+ cluster: {buddy / max(1, small):.0%}")
