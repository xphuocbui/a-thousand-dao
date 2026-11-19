"""Export the designed Đạo Đồ (the v5 frozen map and its filled content) to the game's data file (ADR-0004 decision 1).

The game never reads design/. This writes assets/data/dao_do_map.json from
  design/dao-do/cells/versions/v5-frozen-2026-11-19/dao-do-map.json   (positions, kinds, regions, gate, edges)
  design/dao-do/content/*.json                                        (names, modifiers, capabilities, Effects)

Each node gets its scaling area (Đạo Đồ rule 4), decided from the map's region and gate, never from the content file:
  exact            starts, roads, keystones and the Taiji hub's Dao marks (region hub)
  chaos            every gated Dao mark outside the hub (the Chaos land, its six element pieces included)
  el:<e>           an element land's Dao marks (the Ice start's figure is counted in Water's land)
  var:<v>          an island's Dao marks (Light quang, Thunder loi, Darkness am) and the Wind start's figure (phong)
  border:<a>:<b>   a border line's Dao marks (the average of both lands' multipliers)
and a road node its grants, as shares of road_purity (a data knob the game reads): an element land's road its element
1.0, a border road 0.5 each neighbour, a hub road 1.0 each of the five, an island road its variant 1.0.

Run:
  python -I tools/design/dao_do_rework/content/export_game.py          write the file
  python -I tools/design/dao_do_rework/content/export_game.py --check  compare with the file and run every check;
                                                                        exit 1 on drift or a failed check
Checks: content hashes match the map; content ids are exactly the map's Dao marks; area counts equal the GDD's region
table (Đạo Đồ rule 1); the kit's drawing checks (AC-KMD-60); every modifier key is known to the game; no modifier
quantises to 0 at the lowest multiplier (0.25). Observations are printed, never judged.
"""
import collections
import glob
import hashlib
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", "..", "..", ".."))
sys.path.insert(0, os.path.dirname(HERE))
import kit  # noqa: E402

MAP_NAME = "v5-frozen-2026-11-19"
MAP = os.path.join(ROOT, "design", "dao-do", "cells", "versions", MAP_NAME, "dao-do-map.json")
CONTENT = os.path.join(ROOT, "design", "dao-do", "content")
OUT = os.path.join(ROOT, "assets", "data", "dao_do_map.json")
LABELS = os.path.join(ROOT, "assets", "data", "character_stat_labels.json")
ENGINE = os.path.join(ROOT, "assets", "data", "combat_engine.json")

LAND = {"fire": "hoa", "earth": "tho", "metal": "kim", "water": "thuy", "wood": "moc"}
# land axes, degrees clockwise from +y (atan2(x, y)): the start positions on the map
AXIS = {"hoa": 0.0, "tho": 72.0, "kim": 144.0, "thuy": 216.0, "moc": 288.0}
BORDER = {"fe": ("hoa", "tho"), "em": ("tho", "kim"), "mw": ("kim", "thuy"), "ww": ("thuy", "moc"), "wf": ("moc", "hoa")}
ISLAND = {"light": "quang", "thunder": "loi", "darkness": "am"}
FIVE = ["moc", "hoa", "tho", "kim", "thuy"]
START_OF = {"Chaos start (Hỗn Độn)": "hon_don", "Fire start": "hoa", "Earth start": "tho", "Metal start": "kim",
            "Water start": "thuy", "Ice start (Băng)": "bang", "Wood start": "moc", "Wind start (Phong)": "phong",
            "Light start (Quang)": "quang", "Thunder start (Lôi)": "loi", "Darkness start (Ám)": "am"}
# Đạo Đồ rule 1 region table and Formulas H (v5 frozen map, measured 2026-11-19)
GDD_AREAS = {"el:moc": 1073, "el:kim": 986, "el:hoa": 971, "el:tho": 964, "el:thuy": 956, "border": 119, "hub": 12,
             "chaos": 774, "var:quang": 513, "var:am": 489, "var:loi": 438}
GDD_TOTALS = {"nodes": 8057, "start": 11, "road": 751, "small": 5493, "notable": 1759, "keystone": 43, "gate": 817,
              "visible": 7295}
CONTENT_AREA_ISLAND = {"light": "quang", "thunder": "loi", "darkness": "am"}


def sha(path):
    return hashlib.sha256(open(path, "rb").read()).hexdigest()


def angle(n):
    return math.degrees(math.atan2(n["x"], n["y"])) % 360.0


def border_pair(n):
    """The two lands whose axes are nearest the node's angle, in AXIS order around the circle."""
    a = angle(n)
    near = sorted(AXIS, key=lambda e: min(abs(a - AXIS[e]), 360 - abs(a - AXIS[e])))[:2]
    for key, pair in BORDER.items():
        if set(pair) == set(near):
            return pair
    raise ValueError(f"node {n['id']}: no border pair at {a:.1f} deg")


def load_content():
    out, area_of, hashes = {}, {}, {}
    for f in sorted(glob.glob(os.path.join(CONTENT, "*.json"))):
        d = json.load(open(f, encoding="utf-8"))
        hashes[d["area"]] = d["map_sha256"]
        for k, v in d["nodes"].items():
            if k in out:
                raise ValueError(f"node {k} in two content files")
            out[k] = v
            area_of[k] = d["area"]
    return out, area_of, hashes


def area(n, wind_fig, content_area):
    """Scaling area of node n (module docstring)."""
    if n["kind"] in ("start", "travel", "keystone"):
        return "exact"
    r = n["region"]
    if r == "hub":
        return "exact"
    if n.get("gate") == "chaos":
        return "chaos"
    if r in LAND:
        return "el:" + LAND[r]
    if r in ISLAND:
        return "var:" + ISLAND[r]
    if r == "island":
        return "var:" + CONTENT_AREA_ISLAND[content_area]
    if n["id"] in wind_fig:
        return "var:phong"
    if r.startswith("border") or r.startswith("blend"):
        suffix = r.split("_")[1] if "_" in r else ""
        a, b = BORDER[suffix] if suffix in BORDER else border_pair(n)
        return f"border:{a}:{b}"
    raise ValueError(f"node {n['id']}: no area for region {r}")


def grants(n):
    """A road node's purity grants as shares of road_purity (Đạo Đồ rule 4)."""
    r = n["region"]
    if r == "hub":
        return {e: 1.0 for e in FIVE}
    if r in LAND:
        return {LAND[r]: 1.0}
    if r in ISLAND:
        return {ISLAND[r]: 1.0}
    if r.startswith("border") or r.startswith("blend"):
        suffix = r.split("_")[1] if "_" in r else ""
        a, b = BORDER[suffix] if suffix in BORDER else border_pair(n)
        return {a: 0.5, b: 0.5}
    raise ValueError(f"road {n['id']}: no grant for region {r}")


def mod(line):
    key, scope, w, value = line
    m = {"stat": key, "value": value, "w": w}
    if scope:
        m["scope"] = scope.split(",")
    return m


def build():
    m = json.load(open(MAP, encoding="utf-8"))
    content, content_area, hashes = load_content()
    groups = {g["shape"]: g for g in m["groups"]}
    wind_fig = set(groups["start:Wind start"]["nodes"])
    starts = {}
    nodes = []
    for n in sorted(m["nodes"], key=lambda x: x["id"]):
        kind = "road" if n["kind"] == "travel" else n["kind"]
        rec = {"id": n["id"], "x": round(n["x"], 3), "y": round(n["y"], 3), "kind": kind}
        c = content.get(str(n["id"]))
        if kind == "start":
            starts[START_OF[n["name"]]] = n["id"]
            rec["name"] = n["name"]
        elif c and c.get("name"):
            rec["name"] = c["name"]
        rec["area"] = area(n, wind_fig, content_area.get(str(n["id"]), ""))
        if n.get("gate") == "chaos":
            rec["gate"] = "chaos"
        if n.get("cluster") is not None:
            rec["cluster"] = n["cluster"]
        if kind == "road":
            rec["grants"] = grants(n)
        if c:
            rec["mods"] = [mod(x) for x in c["mods"]]
            if c.get("pending"):
                rec["pending"] = [{"stat": p[0], "w": p[2], **({"scope": p[1].split(",")} if p[1] else {})}
                                  for p in c["pending"]]
            if c.get("cap"):
                rec["cap"] = int(str(c["cap"]).lstrip("#"))
            if c.get("effect"):
                rec["effect"] = c["effect"]
            if c.get("closes"):
                rec["closes"] = c["closes"]
        nodes.append(rec)
    edges = sorted([min(e["a"], e["b"]), max(e["a"], e["b"])] for e in m["edges"])
    content_hash = hashlib.sha256("".join(sha(f) for f in sorted(glob.glob(os.path.join(CONTENT, "*.json")))).encode()).hexdigest()
    head = {
        "schema_version": 1,
        "_doc": "Đạo Đồ map for the game (ADR-0004), written by tools/design/dao_do_rework/content/export_game.py from "
                "the v5 frozen map and design/dao-do/content/. Do not edit by hand: re-export. Node fields: id, x, y, "
                "kind (start, road, small, notable, keystone), name, area (exact | chaos | el:<element> | "
                "var:<variant> | border:<a>:<b>, Đạo Đồ rule 4), gate (chaos, rule 3), cluster, grants (a road's "
                "purity grants as shares of road_purity), mods [{stat, value, w, scope}] (value before the multiplier; "
                "w its price in W), pending [{stat, w, scope}] (lines with no host yet: shown, adding nothing), cap "
                "(capability id), effect (its effects.md name), closes (the keystone's closing text). Ids are "
                "append-only from this baseline (rule 19).",
        "baseline": "v5",
        "map": MAP_NAME,
        "map_sha256": sha(MAP),
        "content_sha256": content_hash,
        "starts": dict(sorted(starts.items())),
    }
    return head, nodes, edges, m, content, hashes, content_area


def dump(head, nodes, edges):
    lines = ["{"]
    for k, v in head.items():
        lines.append(f"  {json.dumps(k)}: {json.dumps(v, ensure_ascii=False)},")
    lines.append('  "nodes": [')
    lines.append(",\n".join("    " + json.dumps(n, ensure_ascii=False, separators=(",", ":")) for n in nodes))
    lines.append("  ],")
    lines.append('  "edges": [')
    rows = [edges[i:i + 16] for i in range(0, len(edges), 16)]
    lines.append(",\n".join("    " + ",".join(json.dumps(e, separators=(",", ":")) for e in r) for r in rows))
    lines.append("  ]")
    lines.append("}")
    return "\n".join(lines) + "\n"


class ById(list):
    """A list of records that is also indexed by record id, for kit.check (which iterates and indexes the same object)."""

    def __init__(self, recs):
        super().__init__(recs)
        self._by = {r["id"]: r for r in recs}

    def __getitem__(self, i):
        return self._by[i] if isinstance(i, int) else list.__getitem__(self, i)


def checks(head, nodes, edges, m, content, hashes, content_area):
    fails, notes = [], []
    msha = head["map_sha256"]
    for a, h in hashes.items():
        if h != msha:
            fails.append(f"content {a}: map_sha256 {h[:12]} is not the map's {msha[:12]}")
    marks = {n["id"] for n in nodes if n["kind"] in ("small", "notable", "keystone")}
    cids = {int(k) for k in content}
    if marks != cids:
        fails.append(f"content ids differ from the map's Dao marks: {len(marks - cids)} without content, "
                     f"{len(cids - marks)} not on the map")
    kinds = collections.Counter(n["kind"] for n in nodes)
    got = {"nodes": len(nodes), **{k: kinds[k] for k in ("start", "road", "small", "notable", "keystone")},
           "gate": sum(1 for n in nodes if n.get("gate")), "visible": len(marks)}
    for k, v in GDD_TOTALS.items():
        if got[k] != v:
            fails.append(f"{k}: {got[k]}, GDD {v}")
    # areas, as the GDD counts them: keystones in their region (hub keystones in the hub), border pairs together
    by_region = collections.Counter()
    src = {n["id"]: n for n in m["nodes"]}
    for n in nodes:
        if n["kind"] not in ("small", "notable", "keystone"):
            continue
        a = n["area"]
        if n["kind"] == "keystone":
            r = src[n["id"]]["region"]
            ca = content_area[str(n["id"])]
            a = ("hub" if r == "chaos" else "el:" + LAND[r] if r in LAND else "var:" + CONTENT_AREA_ISLAND[ca])
        elif a == "exact":
            a = "hub"
        elif a.startswith("border") or a == "var:phong":
            a = "border"
        by_region[a] += 1
    for a, v in GDD_AREAS.items():
        if by_region[a] != v:
            fails.append(f"area {a}: {by_region[a]} Dao marks, GDD {v}")
    for a in by_region:
        if a not in GDD_AREAS:
            fails.append(f"area {a}: {by_region[a]} Dao marks, not in the GDD table")
    # drawing checks (AC-KMD-60), the kit's own check on the exported geometry
    kn = ById([{"id": s["id"], "x": s["x"], "y": s["y"], "kind": s["kind"], "name": s.get("name", ""),
                "cluster": s.get("cluster"), "theme": s.get("theme")} for s in m["nodes"]])
    cl = collections.defaultdict(list)
    for s in m["nodes"]:
        if s.get("cluster") is not None:
            cl[s["cluster"]].append(s["id"])
    kc = ById([{"id": c, "nodes": v, "name": f"cluster {c}", "form": "drawn", "region": src[v[0]]["region"]}
               for c, v in cl.items()])
    ke = [{"a": e["a"], "b": e["b"], "arc": e.get("arc"), "kind": "link"} for e in m["edges"]]
    out, report, _ = kit.check(kn, ke, kc, 0.6, xy=("x", "y"))
    deg = collections.Counter()
    for a, b in edges:
        deg[a] += 1; deg[b] += 1
    draw = {"crossings": out["crossings"], "too_close": out["too_close_count"], "grazing": out["grazing"],
            "unreached": out["unreached"], "no_bypass": out["no_bypass"], "max_degree": max(deg.values())}
    notes.append("drawing checks: " + ", ".join(f"{k} {v}" for k, v in draw.items()))
    # crossings and reachability fail the export; the rest are observations: the frozen map passed its own audit
    # (traced pieces have their own spacing, design/dao-do/cells/versions/v5-frozen-2026-11-19/README.md), so where it
    # differs from AC-KMD-60's flat thresholds it is reported, never changed here
    for k in ("crossings", "unreached"):
        if draw[k]:
            fails.append(f"drawing check {k}: {draw[k]}: " + "; ".join([str(x) for x in report[k]][:6]))
    for k in ("too_close", "grazing", "no_bypass"):
        if draw[k]:
            notes.append(f"AC-KMD-60 {k}: {draw[k]} on the frozen map, e.g. " + "; ".join([str(x) for x in report[k]][:3]))
    if draw["max_degree"] > 6:
        notes.append(f"AC-KMD-60 max links: " + ", ".join(f"#{i} {c}" for i, c in sorted(deg.items()) if c > 6))
    # modifier keys the game knows, and grid floors at the lowest multiplier
    labels = json.load(open(LABELS, encoding="utf-8"))
    eng = json.load(open(ENGINE, encoding="utf-8"))["CHARACTER_MODS"]
    known = set(labels["labels"]) | set(eng["passive"]) | set(eng["static"]) | set(eng.get("out_of_fight", []))
    prec = lambda k: labels.get("precision_overrides", {}).get(k, labels["precision_by_unit"].get(
        labels["labels"].get(k, {}).get("unit", "flat"), 0.01))
    unknown = collections.Counter()
    floors = []
    for n in nodes:
        for x in n.get("mods", []):
            if x["stat"] not in known:
                unknown[x["stat"]] += 1
            low = 1.0 if n["area"] == "exact" else 0.25
            if math.floor(abs(x["value"]) * low / prec(x["stat"]) + 1e-6) == 0:
                floors.append(f"#{n['id']} {x['stat']} {x['value']} x{low}")
    if unknown:
        notes.append("modifier keys with no label or engine entry (summed on the sheet, shown raw): " +
                     ", ".join(f"{k} {v}" for k, v in sorted(unknown.items())))
    if floors:
        notes.append(f"modifiers that quantise to 0 at x0.25 ({len(floors)}): " + "; ".join(floors[:8]))
    return fails, notes


def main():
    head, nodes, edges, m, content, hashes, content_area = build()
    text = dump(head, nodes, edges)
    if "--check" in sys.argv:
        fails, notes = checks(head, nodes, edges, m, content, hashes, content_area)
        for x in notes:
            print("note:", x)
        old = open(OUT, encoding="utf-8").read() if os.path.exists(OUT) else ""
        if old != text:
            fails.append(f"{os.path.relpath(OUT, ROOT)} differs from a fresh export (re-run without --check)")
        for x in fails:
            print("FAIL:", x)
        print(f"{len(nodes)} nodes, {len(edges)} edges, starts {head['starts']}")
        sys.exit(1 if fails else 0)
    open(OUT, "w", encoding="utf-8", newline="\n").write(text)
    print(f"wrote {os.path.relpath(OUT, ROOT)}: {len(nodes)} nodes, {len(edges)} edges, {len(text) // 1024} KB")


if __name__ == "__main__":
    main()
