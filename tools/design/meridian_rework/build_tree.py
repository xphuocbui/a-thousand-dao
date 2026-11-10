"""Build the whole Kinh Mạch Đồ from its hand-drawn regions, join them, check the tree and write data + a viewer page.

Usage (from the repo root):
  python -I tools/design/meridian_rework/build_tree.py <out_dir> [--only r1,r2] [--no-geometry] [--keep-hidden]

Each region (regions/<name>.py) is drawn in its own frame with kit.Tree, exactly as build_region.py draws one land.
This script turns every region into world coordinates (x right, y down, angle 0 at the top, clockwise), joins the
ports that neighbouring regions name (kit.Tree.exit(..., port=) and kit.Tree.port), drops the exit stubs, and runs
kit.check on the whole tree: crossings, spacing, joins at the nearest node, distances from every start.
Version 1 (2026-11-08 night).
"""
import importlib.util
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import kit  # noqa: E402

# region file, in drawing order
REGIONS = ["hub", "fire", "blend_fe", "earth", "blend_em", "metal", "blend_mw", "water", "blend_ww", "wood", "blend_wf",
           "light", "darkness", "thunder"]
LANDS = ["fire", "earth", "metal", "water", "wood"]
BLEND_BETWEEN = {"blend_fe": ("fire", "earth"), "blend_em": ("earth", "metal"), "blend_mw": ("metal", "water"),
                 "blend_ww": ("water", "wood"), "blend_wf": ("wood", "fire")}
RING_PORTS = ["r0", "r1", "r2", "r3", "r4"]


def joins():
    """(region a, port a, region b, port b, kind). A land's '<ring>+' meets the next blend's '<ring>-', and so on."""
    out = []
    for b, (l1, l2) in BLEND_BETWEEN.items():
        for r in RING_PORTS:
            out.append((l1, r + "+", b, r + "-", "highway"))
            out.append((b, r + "+", l2, r + "-", "highway"))
        out.append(("hub", "s" + b[-2:], b, "hub", "highway"))
    out += [("light", "bridge", "fire", "light", "highway"), ("darkness", "bridge", "water", "dark", "highway"),
            ("darkness", "shadow", "earth", "shadow", "long"), ("thunder", "bridge", "blend_ww", "thunder", "highway")]
    return out


def load(region):
    sp = importlib.util.spec_from_file_location("region_" + region, os.path.join(HERE, "regions", region + ".py"))
    R = importlib.util.module_from_spec(sp)
    sp.loader.exec_module(R)
    return R


def main():
    OUT = sys.argv[1]
    only = None
    if "--only" in sys.argv:
        only = sys.argv[sys.argv.index("--only") + 1].split(",")
    geometry = "--no-geometry" not in sys.argv
    os.makedirs(OUT, exist_ok=True)
    nodes, edges, clusters, themes, ports, regions_meta, fit_fail = [], [], [], {}, {}, [], {}
    for name in REGIONS:
        if only and name not in only:
            continue
        if not os.path.exists(os.path.join(HERE, "regions", name + ".py")):
            print(f"(region {name} not drawn yet)")
            continue
        R = load(name)
        T = kit.Tree(R)
        R.build(T)
        off, coff = len(nodes), len(clusters)
        keep = {}
        for n in T.nodes:
            if n["kind"] == "exit":
                continue
            x, y = kit.to_world(R.AXIS, (n["u"], n["v"]))
            o = {k: v for k, v in n.items() if k not in ("u", "v", "id")}
            o.update(id=len(nodes), x=round(x, 3), y=round(y, 3), region=name)
            if o["cluster"] is not None:
                o["cluster"] += coff
            keep[n["id"]] = o["id"]
            nodes.append(o)
        for e in T.edges:
            if e["a"] not in keep or e["b"] not in keep:
                continue
            arc = kit.to_world(R.AXIS, e["arc"]) if e["arc"] else None
            edges.append({"a": keep[e["a"]], "b": keep[e["b"]], "arc": [round(c, 3) for c in arc] if arc else None,
                          "long": e["long"], "kind": e["kind"]})
        for c in T.clusters:
            clusters.append({"id": c["id"] + coff, "name": c["name"], "form": c["form"], "themes": c["themes"],
                             "nodes": [keep[i] for i in c["nodes"]], "region": name, "hidden": c.get("hidden"),
                             "mastery": kit.to_world(R.AXIS, c["mastery"]) if c["mastery"] else None})
        for k, v in R.THEMES.items():
            themes.setdefault(k, {"label": v["label"], "kind": v["kind"]})
        for k, v in T.ports.items():
            ports[(name, k)] = keep[v]
        regions_meta.append({"name": name, "title": R.TITLE, "axis": R.AXIS, "nodes": len(keep)})
        if T.fit_failures:
            fit_fail[name] = T.fit_failures
    # ---- joins between regions ------------------------------------------------------------------------------------
    used, missing = set(), []
    for a, pa, b, pb, kind in joins():
        if (a, pa) in ports and (b, pb) in ports:
            ia, ib = ports[(a, pa)], ports[(b, pb)]
            pa_, pb_ = (nodes[ia]["x"], nodes[ia]["y"]), (nodes[ib]["x"], nodes[ib]["y"])
            same_r = abs(math.hypot(*pa_) - math.hypot(*pb_)) < 0.6 and math.dist(pa_, pb_) < 0.5 * math.hypot(*pa_)
            edges.append({"a": ia, "b": ib, "arc": [0.0, 0.0] if same_r else None, "long": kind == "long", "kind": "join"})
            used |= {(a, pa), (b, pb)}
        elif (a, pa) in ports or (b, pb) in ports:
            missing.append(f"{a}.{pa} <-> {b}.{pb}: only {'first' if (a, pa) in ports else 'second'} side drawn")
    loose = [f"{r}.{p}" for (r, p) in ports if (r, p) not in used]
    # ---- hidden clusters are scrapped (user decision 2026-11-09; Meridian Map GDD rules 6-15 retired, 2026-11-10):
    # the regions still draw the hidden band, so drop it here unless --keep-hidden asks for the old drawing --------
    if "--keep-hidden" not in sys.argv:
        live = [n for n in nodes if not n.get("hidden")]
        nid = {n["id"]: i for i, n in enumerate(live)}
        live_cl = [c for c in clusters if not c.get("hidden")]
        cid = {c["id"]: i for i, c in enumerate(live_cl)}
        for n in live:
            n["id"] = nid[n["id"]]
            if n.get("cluster") is not None:
                n["cluster"] = cid.get(n["cluster"])
        edges = [dict(e, a=nid[e["a"]], b=nid[e["b"]]) for e in edges if e["a"] in nid and e["b"] in nid]
        for c in live_cl:
            c["id"] = cid[c["id"]]
            c["nodes"] = [nid[i] for i in c["nodes"] if i in nid]
        nodes, clusters = live, live_cl
    metrics, report, per_start = kit.check(nodes, edges, clusters, 0.6, xy=("x", "y"), geometry=geometry)
    metrics["regions"] = {m["name"]: m["nodes"] for m in regions_meta}
    report["ports_missing"] = missing
    report["ports_loose"] = loose
    for r, ff in fit_fail.items():
        report[f"fit_failures {r}"] = ff
    data = {"nodes": nodes, "edges": edges,
            "clusters": [{"id": c["id"], "theme": c["themes"][0] if c["themes"] else "", "form": c["form"], "name": c["name"],
                          "region": c["region"], "hidden": c["hidden"], "n": len(c["nodes"]),
                          "centre": [round(v, 3) for v in c["mastery"]] if c["mastery"] else None} for c in clusters],
            "metrics": metrics, "themes": themes, "regions": regions_meta}
    json.dump(data, open(os.path.join(OUT, "tree.json"), "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
    tpl = open(os.path.join(HERE, "tree_viewer.html"), encoding="utf-8").read()
    open(os.path.join(OUT, "tree.html"), "w", encoding="utf-8").write(
        tpl.replace("__DATA__", json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\u002f")))
    short = {k: v for k, v in metrics.items() if k not in ("shapes", "themes")}
    print(json.dumps(short, ensure_ascii=False, indent=None))
    for k, v in report.items():
        if v:
            print(f"-- {k} ({len(v)}):")
            for line in v[:25]:
                print("   ", line)


if __name__ == "__main__":
    main()
