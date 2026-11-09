"""Build one hand-drawn Kinh Mạch Đồ region from its spec, check it, and write data + a viewer page.

Usage (from the repo root):
  python -I tools/design/meridian_rework/build_region.py <region> <out_dir> [--labels]

Version 7 (2026-11-08): the drawing kit moved to kit.py so build_tree.py can draw every region into one tree. This
script draws a single region in its own frame, as v6 did. See kit.py for the coordinates and the spec contract.
"""
import importlib.util
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import kit  # noqa: E402


def load(region):
    sp = importlib.util.spec_from_file_location("region_" + region, os.path.join(HERE, "regions", region + ".py"))
    R = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(R)
    return R


def main():
    REGION, OUT = sys.argv[1], sys.argv[2]
    LABELS = "--labels" in sys.argv
    os.makedirs(OUT, exist_ok=True)
    R = load(REGION)
    T = kit.Tree(R)
    R.build(T)
    nodes, edges, clusters = T.nodes, T.edges, T.clusters
    # the exit stubs are display arrows to the neighbouring regions; the whole tree drops them, so the check does too
    metrics, report, per_start = kit.check(nodes, [e for e in edges if e["kind"] != "exit"], clusters, getattr(R, "MIN_SPACING", 0.6))
    metrics["region"] = REGION
    first = next((n["id"] for n in nodes if n["kind"] == "start"), None)
    dist, par = per_start.get(first, ({}, {}))
    nots = [n for n in nodes if n["kind"] == "notable" and not n.get("hidden")]
    web9 = [i for i in dist if dist[i] <= 9]
    metrics.update(keystone_points={n["name"]: dist.get(n["id"]) for n in nodes if n["kind"] == "keystone"},
                   first_notable=min((dist.get(n["id"], 999) for n in nots), default=None),
                   start_web_9={"nodes": len(web9), "notables": sum(1 for i in web9 if nodes[i]["kind"] == "notable")},
                   notables_within={str(r): sum(1 for n in nots if dist.get(n["id"], 999) <= r) for r in (5, 10, 15, 20, 30)},
                   farthest=max(dist.values(), default=None))
    out_nodes = []
    for n in nodes:
        x, y = kit.to_world(R.AXIS, (n["u"], n["v"]))
        o = {k: v for k, v in n.items() if k not in ("u", "v")}
        o.update(x=round(x, 3), y=round(y, 3), u=round(n["u"], 3), v=round(n["v"], 3))
        if LABELS:
            o["label"] = str(n["id"])
        out_nodes.append(o)
    data = {"nodes": out_nodes,
            "edges": [{"a": e["a"], "b": e["b"], "arc": [round(c, 3) for c in kit.to_world(R.AXIS, e["arc"])] if e["arc"] else None,
                       "ctrl": None, "long": e["long"], "kind": e["kind"]} for e in edges],
            "clusters": [{"id": c["id"], "theme": c["themes"][0] if c["themes"] else "", "form": c["form"], "name": c["name"],
                          "centre": [round(v, 3) for v in kit.to_world(R.AXIS, c["mastery"])] if c["mastery"] else None,
                          "hidden": c.get("hidden")} for c in clusters],
            "dist": {str(k): v for k, v in dist.items()}, "par": {str(k): v for k, v in par.items()},
            "metrics": metrics, "themes": {k: {"label": v["label"], "kind": v["kind"]} for k, v in R.THEMES.items()},
            "start_deg": R.AXIS, "title": R.TITLE, "rim": getattr(R, "RIM", 76), "half_angle": getattr(R, "HALF_ANGLE", None),
            "labels": LABELS}
    json.dump(data, open(os.path.join(OUT, f"{REGION}.json"), "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
    tpl = open(os.path.join(HERE, "region_viewer.html"), encoding="utf-8").read()
    open(os.path.join(OUT, f"{REGION}-pilot.html"), "w", encoding="utf-8").write(
        tpl.replace("__DATA__", json.dumps(data, ensure_ascii=False).replace("</", "<\\u002f")).replace("__TITLE__", R.TITLE))
    print(json.dumps(metrics, ensure_ascii=False))
    report["fit_failures"] = T.fit_failures
    for k, v in report.items():
        if v:
            print(f"-- {k} ({len(v)}):")
            for line in v[:40]:
                print("   ", line)


if __name__ == "__main__":
    main()
