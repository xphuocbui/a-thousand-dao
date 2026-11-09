"""Render PoE 1 / PoE 2 graphs (study data, untrusted JSON) in our tree viewer, for a same-style comparison.
usage: python -I poe_view.py <trees.json> <tree_viewer.html> <out_dir>"""
import json
import math
import sys
import collections

D = json.load(open(sys.argv[1]))
tpl = open(sys.argv[2], encoding="utf-8").read()
OUT = sys.argv[3]
KIND = {0: "small", 1: "travel", 2: "notable", 3: "keystone", 4: "small", 6: "start"}
for key in ("poe1", "poe2"):
    t = D[key]
    keep = [i for i, n in enumerate(t["n"]) if n[2] in KIND]
    idx = {i: j for j, i in enumerate(keep)}
    L = sorted(math.dist(t["n"][a][:2], t["n"][b][:2]) for a, b, *_ in t["e"] if a in idx and b in idx)
    s = 1.1 / L[len(L) // 2]
    gc = [(x * s, y * s) for x, y in t["gc"]]
    grid = collections.defaultdict(list)
    for c in gc:
        grid[(int(c[0] // 4), int(c[1] // 4))].append(c)
    nodes = []
    for i in keep:
        x, y, k = t["n"][i]
        nm = t["names"].get(str(i), [""])[0]
        nodes.append({"id": idx[i], "x": round(x * s, 3), "y": round(y * s, 3), "kind": KIND[k], "theme": "", "name": nm or KIND[k],
                      "mods": t["names"].get(str(i), ["", []])[1] if str(i) in t["names"] else [], "cluster": None,
                      "start_of": "uni" if k == 6 else None})
    edges = []
    for e in t["e"]:
        a, b = e[0], e[1]
        if a not in idx or b not in idx:
            continue
        pa, pb = (nodes[idx[a]]["x"], nodes[idx[a]]["y"]), (nodes[idx[b]]["x"], nodes[idx[b]]["y"])
        arc = None
        if len(e) > 2 and e[2]:
            best, bd = None, 1e9
            mx, my = (pa[0] + pb[0]) / 2, (pa[1] + pb[1]) / 2
            for gx in range(int(mx // 4) - 2, int(mx // 4) + 3):
                for gy in range(int(my // 4) - 2, int(my // 4) + 3):
                    for c in grid.get((gx, gy), ()):
                        ra, rb = math.dist(pa, c), math.dist(pb, c)
                        if ra < 0.3 or rb < 0.3:
                            continue
                        d = abs(ra - rb)
                        if d < bd:
                            best, bd = c, d
            if best and bd < 0.05:
                arc = [round(best[0], 3), round(best[1], 3)]
        edges.append({"a": idx[a], "b": idx[b], "arc": arc, "long": False, "kind": "link"})
    starts = [n for n in nodes if n["kind"] == "start"]
    data = {"nodes": nodes, "edges": edges, "clusters": [], "themes": {}, "regions": [],
            "metrics": {"nodes": len(nodes), "hidden_nodes": 0, "clusters": 0, "hidden_clusters": 0, "loops": 0,
                        "travel_with_cluster_share": 0, "travel_multi_share": 0, "entry_nearest_share": 0, "small_with_big_share": 0,
                        "crossings": 0, "too_close_count": 0, "grazing": 0, "unreached": 0,
                        "starts": {n["name"]: {"web_9": "", "first_notable": "", "nearest_keystone": "", "farthest": ""} for n in starts}}}
    html = tpl.replace("__DATA__", json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\u002f"))
    html = html.replace("<title>Kinh Mạch Đồ</title>", f"<title>{key}</title>")
    open(f"{OUT}/{key}.html", "w", encoding="utf-8").write(html)
    xs = [n["x"] for n in nodes]; ys = [n["y"] for n in nodes]
    print(key, len(nodes), len(edges), "arcs", sum(1 for e in edges if e["arc"]), "extent", round(min(xs)), round(max(xs)), round(min(ys)), round(max(ys)))
