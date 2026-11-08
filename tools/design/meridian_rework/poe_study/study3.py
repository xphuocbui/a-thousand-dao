"""Third study pass: cluster entry points, start webs, notables per cluster (study only).

Usage: python -I study3.py <poe1 data.json> <poe2 tree.json>
"""
import collections
import math
import statistics as st
import sys

src = open(__file__.replace("study3.py", "analyse.py"), encoding="utf-8").read().split("\nout = {}\n")[0]
P1, P2 = sys.argv[1], sys.argv[2]
sys.argv = ["x", P1, P2, "."]
ns = {}
exec(compile(src, "analyse.py", "exec"), ns)


def pct(xs, f):
    return f"{100 * sum(1 for x in xs if f(x)) / max(1, len(xs)):.0f}%"


for game, path in ((1, P1), (2, P2)):
    d, nodes, edges = ns["load"](path, game)
    adj = collections.defaultdict(set)
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    D = lambda a, b: math.hypot(nodes[a]["x"] - nodes[b]["x"], nodes[a]["y"] - nodes[b]["y"])
    grp = collections.defaultdict(list)
    for k, v in nodes.items():
        if v["t"] not in ("mastery",):
            grp[v["g"]].append(k)
    print(f"\n===== PoE {game} =====")
    # 1. entry choice: for each link from an outside node X into group G (G has >=3 nodes, no travel/attribute),
    # rank of the entry node among G's nodes by distance to X.
    ranks, ratio = [], []
    for g, mem in grp.items():
        if len(mem) < 3 or any(nodes[k]["t"] in ("start", "keystone") for k in mem):
            continue
        ms = set(mem)
        for e in mem:
            for x in adj[e]:
                if x in ms:
                    continue
                order = sorted(mem, key=lambda m: D(m, x))
                ranks.append(order.index(e) + 1)
                ratio.append(D(e, x) / max(1e-6, D(order[0], x)))
    print("entry links:", len(ranks), "entry is nearest:", pct(ranks, lambda r: r == 1), "nearest-2:", pct(ranks, lambda r: r <= 2),
          "entry within 1.15x of nearest:", pct(ratio, lambda r: r <= 1.15))
    # 2. notables per group and smalls before each notable (path length from group entry inside group)
    multi, before, between = collections.Counter(), [], []
    for g, mem in grp.items():
        ms = set(mem)
        nts = [k for k in mem if nodes[k]["t"] == "notable"]
        if not nts:
            continue
        multi[min(len(nts), 4)] += 1
        entries = [k for k in mem if any(x not in ms for x in adj[k])]
        if not entries:
            continue
        # BFS inside group from all entries
        dist = {e: 0 for e in entries}
        q = collections.deque(entries)
        while q:
            u = q.popleft()
            for v in adj[u]:
                if v in ms and v not in dist:
                    dist[v] = dist[u] + 1; q.append(v)
        for n in nts:
            if n in dist:
                before.append(dist[n])
        if len(nts) >= 2:
            for i, a in enumerate(nts):
                da = {a: 0}; q = collections.deque([a])
                while q:
                    u = q.popleft()
                    for v in adj[u]:
                        if v in ms and v not in da:
                            da[v] = da[u] + 1; q.append(v)
                for b in nts[i + 1:]:
                    if b in da:
                        between.append(da[b] - 1)
    print("groups with notables by count (1/2/3/4+):", dict(sorted(multi.items())))
    print("nodes taken inside the cluster before a notable (0 = notable is the entry):", dict(sorted(collections.Counter(before).items())))
    print("smalls between two notables of one cluster:", dict(sorted(collections.Counter(between).items())))
    # 3. start webs: within R points of each start (not counting other starts), size, notables, cycles, hubs
    starts = [k for k, v in nodes.items() if v["t"] == "start"]
    for R in (6, 9, 12):
        rows = []
        for s in starts:
            dist = {s: 0}; q = collections.deque([s])
            while q:
                u = q.popleft()
                if dist[u] >= R:
                    continue
                for v in adj[u]:
                    if v not in dist and nodes[v]["t"] != "start":
                        dist[v] = dist[u] + 1; q.append(v)
            S = set(dist)
            E = sum(1 for a, b in edges if a in S and b in S)
            nts = sum(1 for k in S if nodes[k]["t"] == "notable")
            att = sum(1 for k in S if nodes[k]["t"] == "attribute")
            groups = len({nodes[k]["g"] for k in S})
            hubs = sum(1 for k in S if len(adj[k]) >= 4)
            rows.append((nodes[s]["name"][:16], len(S), nts, att, groups, E - len(S) + 1, hubs))
        print(f"start web within {R} pts (name, nodes, notables, travel, groups, loops, deg>=4):")
        for r in rows:
            print("   ", r)
    # 4. where the first travel (attribute) node sits from each start
    fa = []
    for s in starts:
        dist = {s: 0}; q = collections.deque([s])
        while q:
            u = q.popleft()
            for v in adj[u]:
                if v not in dist:
                    dist[v] = dist[u] + 1; q.append(v)
        att = sorted(dist[k] for k in dist if nodes[k]["t"] == "attribute")
        nt = sorted(dist[k] for k in dist if nodes[k]["t"] == "notable")
        fa.append((nodes[s]["name"][:16], att[:4], nt[:8]))
    print("first travel nodes / first notables (points):")
    for r in fa:
        print("   ", r)
    # 5. hubs in the start web: notables that are junctions (deg>=3)
    nt_deg = collections.Counter(min(len(adj[k]), 6) for k, v in nodes.items() if v["t"] == "notable")
    print("notable degree:", dict(sorted(nt_deg.items())))
