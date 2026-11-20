"""Grow crowded pieces of the Đạo Đồ just enough that their own nodes stop overlapping (user 2026-11-20). Uniform
scale about the piece's road entry, so the shape and its join to the road are kept; a piece grows only if the grown
version clashes with nothing around it. Works on the viewer copy (islands/scaled-map.json), never the repo files.

Args: repo root, scratch dir. Updates <scratch>/islands/scaled-map.json and writes <scratch>/islands/piece-growth.json
(grown pieces with factor and anchor; pieces left for hand work with their clashes).
"""
import collections
import json
import math
import os
import sys

ROOT, S = sys.argv[1], sys.argv[2]
mp = os.path.join(S, "islands", "scaled-map.json")
M = json.load(open(mp, encoding="utf-8"))
G = {n["id"]: n for n in json.load(open(os.path.join(ROOT, "assets/data/dao_do_map.json"), encoding="utf-8"))["nodes"]}
NODE = {n["id"]: n for n in M["nodes"]}
D = {"road": 0.53, "travel": 0.53, "small": 0.68, "notable": 1.02, "keystone": 1.62, "start": 1.79}
need = lambda a, b: (D[G[a]["kind"]] + D[G[b]["kind"]]) / 2
adj = collections.defaultdict(set)
for e in M["edges"]:
    adj[e["a"]].add(e["b"]); adj[e["b"]].add(e["a"])
clu = collections.defaultdict(list)
for i in NODE:
    c = G[i].get("cluster")
    if c is not None:
        clu[c].append(i)
grid = collections.defaultdict(set)
key = lambda x, y: (int(x // 3), int(y // 3))
for i, n in NODE.items():
    grid[key(n["x"], n["y"])].add(i)


def ratio(ids):
    r = 0
    for x, a in enumerate(ids):
        for b in ids[x + 1:]:
            r = max(r, need(a, b) / max(1e-9, math.dist((NODE[a]["x"], NODE[a]["y"]), (NODE[b]["x"], NODE[b]["y"]))))
    return r


grown, hand = {}, {}
for c, ids in sorted(clu.items(), key=lambda t: -ratio(t[1])):
    r = ratio(ids)
    if r <= 1:
        continue
    s = r * 1.05
    ent = [i for i in ids if any(G[j]["kind"] in ("road", "travel") or G[j].get("cluster") != c for j in adj[i])]
    src = ent or ids
    ax = sum(NODE[i]["x"] for i in src) / len(src); ay = sum(NODE[i]["y"] for i in src) / len(src)
    Q = {i: (ax + (NODE[i]["x"] - ax) * s, ay + (NODE[i]["y"] - ay) * s) for i in ids}
    sid = set(ids); clashes = []
    for i, q in Q.items():
        gx, gy = key(*q)
        for di in (-1, 0, 1):
            for dj in (-1, 0, 1):
                for j in grid.get((gx + di, gy + dj), ()):
                    if j not in sid and math.dist(q, (NODE[j]["x"], NODE[j]["y"])) < need(i, j):
                        clashes.append((i, j))
    piece = "%s" % G[ids[0]].get("cluster")
    if clashes:
        hand[c] = {"needs": round(s, 3), "anchor": [ax, ay], "clashes": clashes[:12], "nodes": len(ids)}
        continue
    for i, (x, y) in Q.items():
        grid[key(NODE[i]["x"], NODE[i]["y"])].discard(i)
        NODE[i]["x"], NODE[i]["y"] = x, y
        if "u" in NODE[i]:
            NODE[i]["u"], NODE[i]["v"] = x, y
        grid[key(x, y)].add(i)
    for e in M["edges"]:
        if e["a"] in sid and e["b"] in sid and e.get("arc"):
            e["arc"] = [ax + (e["arc"][0] - ax) * s, ay + (e["arc"][1] - ay) * s]
        elif (e["a"] in sid) != (e["b"] in sid) and e.get("arc"):
            e["arc"] = None
    grown[c] = {"scale": round(s, 3), "anchor": [ax, ay], "nodes": len(ids)}
json.dump(M, open(mp, "w", encoding="utf-8"))
json.dump({"grown": grown, "hand": hand}, open(os.path.join(S, "islands", "piece-growth.json"), "w", encoding="utf-8"), indent=0)
print("grown", len(grown), "left for hand work", len(hand))
