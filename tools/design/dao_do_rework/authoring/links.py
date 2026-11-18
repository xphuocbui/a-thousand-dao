"""Report-only: how tied together a window of the map is, measured the same way on PoE 1 and on ours.

usage: links.py poe <data.json> cx cy half          (centre and half-size in our units; PoE 173 units = our 1.2)
       links.py ours <map.json> u0 u1 v0 v1          (axis-0 frame, like styled_render.py's Fire window)

A group is PoE's data group; on ours a figure (cluster) is a group and each road node is a group of its own.
A figure is a group with at least one notable. Reported, for links with both ends inside the window:
  nodes, links between groups (count and median length), figures, the share of figures with 2+ links out
  (to distinct other groups), mean links out per figure, links figure-to-figure, the empty share (points farther
  than 2.2 from any node, on a 0.25 grid). Observations only."""
import sys, json, math
from collections import defaultdict

SC = 1.2 / 173.0


def poe(path, cx, cy, half):
    d = json.load(open(path, encoding='utf-8'))
    c = d["constants"]; radii = c["orbitRadii"]
    A16 = [0, 30, 45, 60, 90, 120, 135, 150, 180, 210, 225, 240, 270, 300, 315, 330]
    A40 = [0, 10, 20, 30, 40, 45, 50, 60, 70, 80, 90, 100, 110, 120, 130, 135, 140, 150, 160, 170, 180, 190, 200,
           210, 220, 225, 230, 240, 250, 260, 270, 280, 290, 300, 310, 315, 320, 330, 340, 350]
    ang = [[math.radians(a) for a in (A16 if n == 16 else A40 if n == 40 else [360 * i / n for i in range(n)])]
           for n in c["skillsPerOrbit"]]
    G = d["groups"]; N = {}
    for sid, n in d["nodes"].items():
        if not isinstance(n, dict) or "group" not in n or n.get("ascendancyName") or n.get("isProxy") or n.get("isMastery") or n.get("isBlighted"):
            continue
        g = G.get(str(n["group"]))
        if not g or g.get("isProxy"):
            continue
        a = ang[n["orbit"]][n["orbitIndex"]]; r = radii[n["orbit"]]
        p = ((g["x"] + r * math.sin(a)) * SC - cx, -(g["y"] - r * math.cos(a)) * SC + cy)
        road = n.get("name") in ("Strength", "Dexterity", "Intelligence") or bool(n.get("isJewelSocket")) or bool(n.get("classStartIndex") is not None)
        k = "key" if n.get("isKeystone") else "N" if n.get("isNotable") else "road" if road else "s"
        N[int(n.get("skill", sid))] = dict(p=p, g=n["group"], notable=bool(n.get("isNotable")), k=k,
                                           out=[int(m) for m in n.get("out", [])])
    edges = {tuple(sorted((i, j))) for i, n in N.items() for j in n["out"] if j in N}
    return N, edges, (-half, half, -half, half)


def ours(path, u0, u1, v0, v1):
    M = json.load(open(path, encoding='utf-8'))
    N = {}
    for n in M["nodes"]:
        N[n["id"]] = dict(p=(n["u"], n["v"]), g=n["cluster"] if n["cluster"] is not None else ("road", n["id"]),
                          notable=n["kind"] == "notable",
                          k="N" if n["kind"] == "notable" else "s" if n["kind"] == "small" else "key" if n["kind"] == "keystone" else "road")
    edges = {tuple(sorted((e["a"], e["b"]))) for e in M["edges"]}
    return N, edges, (u0, u1, v0, v1)


def report(N, edges, box):
    u0, u1, v0, v1 = box
    ins = lambda p: u0 <= p[0] <= u1 and v0 <= p[1] <= v1
    I = {i for i, n in N.items() if ins(n["p"])}
    E = [(a, b) for a, b in edges if a in I and b in I]
    members = defaultdict(list)
    for i in I:
        members[N[i]["g"]].append(i)
    figs = {g for g, m in members.items() if any(N[i]["notable"] for i in m)}
    between = [(a, b) for a, b in E if N[a]["g"] != N[b]["g"]]
    L = sorted(math.dist(N[a]["p"], N[b]["p"]) for a, b in between)
    nbr = defaultdict(set)
    for a, b in between:
        nbr[N[a]["g"]].add(N[b]["g"]); nbr[N[b]["g"]].add(N[a]["g"])
    two = sum(1 for g in figs if len(nbr[g]) >= 2)
    ff = sum(1 for a, b in between if N[a]["g"] in figs and N[b]["g"] in figs)
    pts = [N[i]["p"] for i in I]
    step = 0.25; empty = tot = 0
    cells = defaultdict(list)
    for p in pts:
        cells[(int(p[0] // 2.2), int(p[1] // 2.2))].append(p)
    u = u0
    while u <= u1:
        v = v0
        while v <= v1:
            tot += 1
            cx, cy = int(u // 2.2), int(v // 2.2)
            near = any(math.dist((u, v), q) <= 2.2 for dx in (-1, 0, 1) for dy in (-1, 0, 1) for q in cells.get((cx + dx, cy + dy), ()))
            empty += not near
            v += step
        u += step
    print(f"nodes {len(I)}  links {len(E)}  between groups {len(between)}  median length {L[len(L) // 2]:.2f}  "
          f"figures {len(figs)}  2+ out {two / max(1, len(figs)):.0%}  mean out {sum(len(nbr[g]) for g in figs) / max(1, len(figs)):.2f}  "
          f"figure-figure {ff}  empty {empty / tot:.0%}")
    # group-free shape of the web: link lengths, long bare links, hubs, and how much hangs off a single link (bridges)
    AL = sorted(math.dist(N[a]["p"], N[b]["p"]) for a, b in E)
    adj = defaultdict(set)
    for a, b in E:
        adj[a].add(b); adj[b].add(a)
    deg = [len(adj[i]) for i in I]
    br = bridges(I, adj)
    hang = set()                              # nodes on the small side of a bridge (pendants)
    for a, b in br:
        side = reach(b, adj, (a, b))
        other = len(I) - len(side)
        hang |= side if len(side) <= other else reach(a, adj, (a, b))
    print(f"  all links median {AL[len(AL) // 2]:.2f}  longer than 3.5: {sum(x > 3.5 for x in AL) / len(AL):.0%}  "
          f"degree 3+: {sum(x >= 3 for x in deg) / len(deg):.0%}  degree 4+: {sum(x >= 4 for x in deg) / len(deg):.0%}  "
          f"bridges {len(br)}  nodes hanging off a bridge {len(hang) / len(I):.0%}")
    # figures by structure: connected pieces left once road nodes (PoE: attribute travel nodes, sockets, starts) go
    comp = {}; cs = []
    for s0 in (i for i in I if N[i]["k"] in ("N", "s")):
        if s0 in comp:
            continue
        comp[s0] = len(cs); mem = [s0]; st = [s0]
        while st:
            x = st.pop()
            for y in adj[x]:
                if y not in comp and N[y]["k"] in ("N", "s"):
                    comp[y] = len(cs); mem.append(y); st.append(y)
        cs.append(mem)
    outs = [len({y for x in m for y in adj[x] if N[y]["k"] not in ("N", "s")}) for m in cs]
    sz = sorted(len(m) for m in cs)
    road = [i for i in I if N[i]["k"] == "road"]
    RL = sorted(math.dist(N[a]["p"], N[b]["p"]) for a in road for b in adj[a] if a < b and N[b]["k"] == "road")
    load = [sum(1 for y in adj[r] if N[y]["k"] in ("N", "s")) for r in road]
    print(f"  by structure: figures {len(cs)}  size median {sz[len(sz) // 2]}  size 1/2-3/4-6/7-9/10+: "
          f"{sum(x == 1 for x in sz)}/{sum(2 <= x <= 3 for x in sz)}/{sum(4 <= x <= 6 for x in sz)}/{sum(7 <= x <= 9 for x in sz)}/{sum(x >= 10 for x in sz)}  "
          f"tied to 2+ road nodes {sum(o >= 2 for o in outs) / len(outs):.0%}  road nodes {len(road)}  "
          f"road-road median {RL[len(RL) // 2] if RL else 0:.2f}  road nodes carrying 0/1/2/3/4+ figure links: "
          + "/".join(f"{sum(min(x, 4) == k for x in load) / max(1, len(load)):.0%}" for k in range(5)))


def reach(s, adj, cut):
    seen = {s}; st = [s]
    while st:
        x = st.pop()
        for y in adj[x]:
            if {x, y} == set(cut) or y in seen:
                continue
            seen.add(y); st.append(y)
    return seen


def bridges(I, adj):
    sys.setrecursionlimit(100000)
    disc, low, out = {}, {}, []; t = [0]

    def dfs(u, p):
        disc[u] = low[u] = t[0]; t[0] += 1
        for w in adj[u]:
            if w not in disc:
                dfs(w, u); low[u] = min(low[u], low[w])
                if low[w] > disc[u]:
                    out.append((u, w))
            elif w != p:
                low[u] = min(low[u], disc[w])
    for i in I:
        if i not in disc:
            dfs(i, None)
    return out


if __name__ == "__main__":
    if sys.argv[1] == "poe":
        report(*poe(sys.argv[2], *map(float, sys.argv[3:6])))
    else:
        report(*ours(sys.argv[2], *map(float, sys.argv[3:7])))
