"""Each v2 province's start record (user, 2026-11-23 night: "make sure each province has production, development, works,
population stats"), computed with the Provinces GDD's formulas (design/gdd/provinces.md F1-F6), not new numbers, and
merged with the written lore into the game's assets/data/world_provinces.json (read by the province panel).

- production: each place's own output by good class from the real world (prototypes/province-economy/places_seed7.json,
  MapProduction's per-place parts for seed 7); a new place (design/world/provinces-v2/slots.json) takes the median
  output of the existing places of its kind (a proposal: it has no game data yet). Wilderness output goes to the
  settlement provinces by border length, hop by hop up to WILD_HOPS (F2, F4).
- potential and goods (F1): potential = production at the start here (no buildings output); main good the largest class
  by value, up to two secondary goods at SECONDARY_SHARE of it.
- population (F3): P0 = sum of settlements' w_size x livability (map_resources.json settlement_output.w_size; a new
  settlement takes the median livability of existing settlements on its biome); capacity C = P0 (1 + CAP0 + sum cap_b).
- works (rule 10, F5): the starting buildings by seat kind (START_BUILDINGS, a proposal: the GDD says "authored with
  the map"), plus the production building of the main good; slots = base_slots[seat] + floor(P / SLOT_POP_STEP).
- infrastructure and access (F6): infra0[seat] + I_ROAD x road tiles + I_RIVER x min(river tiles, RIVER_CAP) + the
  buildings' infra; usage = the production value (D_loc 0 at the start); access = min(1, infra / usage); infra_old
  tops a province up to START_ACCESS_MIN.
- development: a display index (not in the GDD; a decision for the user): built levels + population units, rounded.

Run: python -I tools/design/map/province_stats_v2.py   (after places_v2.py; lore files are optional)
"""
import glob
import json
import math
import os
import statistics
import sys
from collections import Counter, defaultdict

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import provinces as P  # noqa: E402

ROOT = P.ROOT
V2 = os.path.join(ROOT, "design/map/continent-11/provinces-v2")
WV2 = os.path.join(ROOT, "design/world/provinces-v2")
# the GDD's values (design/gdd/provinces.md, all marked guesses there)
SECONDARY_SHARE = 0.35
WILD_HOPS = 6
CAP0 = 0.2
CAP_B = {"granary": 0.05, "spirit_fields": 0.03}
SLOT_POP_STEP = 8.0
BASE_SLOTS = {"village": 2, "market": 3, "town": 3, "minor_seat": 4, "city": 5, "great_seat": 6}
WILD_SLOTS = 1
INFRA0 = {"village": 100, "market": 200, "town": 200, "minor_seat": 300, "city": 400, "great_seat": 600}
I_ROAD, I_RIVER, RIVER_CAP = 40.0, 25.0, 20
INFRA_B = {"road": 200, "caravan_post": 400, "landing": 500}
START_ACCESS_MIN = 0.5
STAFF_LVL = 1.0
# the starting buildings by seat kind (rule 10: "a great seat starts with the most, a village with a field and a road")
START_BUILDINGS = {
    "village": [("road", 1)],
    "market": [("road", 1), ("market_hall", 1)],
    "town": [("road", 1), ("market_hall", 1), ("granary", 1)],
    "minor_seat": [("road", 1), ("gathering_array", 1), ("warding_wall", 1)],
    "city": [("road", 2), ("market_hall", 2), ("granary", 1), ("caravan_post", 1)],
    "great_seat": [("road", 3), ("market_hall", 2), ("granary", 2), ("caravan_post", 2), ("gathering_array", 2), ("warding_wall", 1)],
}
GOOD_BUILDING = {"herb": "spirit_fields", "ore": "mine_works", "beast": "hunting_lodge"}
SEAT_RANK = ["great_seat", "city", "minor_seat", "town", "market", "village"]
BUILDING_NAMES = {"road": "Road", "market_hall": "Market hall", "granary": "Granary", "caravan_post": "Caravan post",
                  "gathering_array": "Gathering array", "warding_wall": "Warding wall", "spirit_fields": "Spirit fields",
                  "mine_works": "Mine works", "hunting_lodge": "Hunting lodge", "landing": "Landing"}


def label_point(pid, i, centre):
    """Where a province's name sits: the tile of the province farthest inside it (most steps from its edge), near the
    middle, so the name never hangs over a neighbour."""
    m = pid == i
    d = m.astype(np.int32)
    cur = m.copy()
    k = 0
    while cur.any() and k < 30:
        k += 1
        nxt = cur & np.roll(cur, 1, 0) & np.roll(cur, -1, 0) & np.roll(cur, 1, 1) & np.roll(cur, -1, 1)
        d += nxt
        cur = nxt
    ys, xs = np.nonzero(d == d.max())
    j = int(np.argmin((xs - centre[0]) ** 2 + (ys - centre[1]) ** 2))
    return [int(xs[j]), int(ys[j])]


def main():
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    res = json.load(open(os.path.join(ROOT, "assets/data/map_resources.json"), encoding="utf-8"))
    w_size = res["settlement_output"]["w_size"]
    dump = json.load(open(os.path.join(ROOT, "prototypes/province-economy/places_seed7.json"), encoding="utf-8"))["places"]
    provs = json.load(open(os.path.join(V2, "provinces.json"), encoding="utf-8"))["provinces"]
    pid = np.asarray(Image.open(os.path.join(V2, "province_ids.png"))).astype(np.int32)
    slots = json.load(open(os.path.join(WV2, "slots.json"), encoding="utf-8"))["slots"]
    W, H, L = P.read_grid(os.path.join(ROOT, cont["grid_file"].replace("res://", "")))
    road = L["ROAD"].astype(np.int32) > 0
    places = {p["id"]: p for p in cont["places"]}
    prod_of = {}
    for d in dump:
        cid = d.get("continent_id")
        if cid:
            prod_of[int(cid)] = d["production"]
    by_kind = defaultdict(list)
    for d in dump:
        by_kind[d["kind"]].append(d["production"])

    def median_prod(kind):
        rows = by_kind.get(kind, [])
        if not rows:
            return {}
        tot = sorted(rows, key=lambda r: sum(r.values()))
        return dict(tot[len(tot) // 2])

    liv_by_biome = defaultdict(list)
    for p in cont["places"]:
        if p["kind"] in w_size:
            liv_by_biome[p["biome"]].append(float(p.get("livability", 1.0)))
    liv_all = [v for vs in liv_by_biome.values() for v in vs]
    place_lore = json.load(open(os.path.join(ROOT, "assets/data/world_place_lore.json"), encoding="utf-8")).get("places", {})
    lore = {"provinces": {}, "places": {}}
    for f in glob.glob(os.path.join(WV2, "lore", "region_*.json")):
        try:
            d = json.load(open(f, encoding="utf-8"))
        except Exception:
            continue
        lore["provinces"].update(d.get("provinces", {}))
        lore["places"].update(d.get("places", {}))
    slots_by = defaultdict(list)
    for s in slots:
        slots_by[s["province"]].append(s)
    road_n = np.bincount(pid[road & (pid > 0)], minlength=len(provs) + 1)
    by_id = {p["id"]: p for p in provs}
    rec = {}
    for p in provs:
        key = p["key"]
        own = defaultdict(float)
        settle = []   # (kind, livability)
        plist = []
        for q in p["places"]:
            pl = places[q]
            for c, v in prod_of.get(q, {}).items():
                own[c] += v
            if pl["kind"] in w_size:
                settle.append((pl["kind"], float(pl.get("livability", 1.0))))
            pe = place_lore.get(str(q), {})
            plist.append({"id": q, "name": pl["name"], "name_han": pl.get("name_han", ""), "kind": pl["kind"], "tile": pl["tile"], "new": False,
                          "gloss": pl.get("gloss", ""), "look": pe.get("look", "")})
        for s in slots_by[key]:
            if s.get("proposal"):
                continue   # a proposed minor sect is listed but adds nothing until accepted
            for c, v in median_prod(s["kind"]).items():
                own[c] += v
            if s["kind"] in w_size:
                lv = liv_by_biome.get(s["biome"]) or liv_all
                settle.append((s["kind"], statistics.median(lv)))
        for s in slots_by[key]:
            e = lore["places"].get(s["slot"], {})
            plist.append({"slot": s["slot"], "name": e.get("name", ""), "name_han": e.get("name_han", ""), "kind": s["kind"],
                          "tile": s["tile"], "new": True, "proposal": bool(s.get("proposal", False)),
                          "gloss": e.get("gloss", ""), "look": e.get("look", ""), "lore": e.get("lore", "")})
        seat = None
        for kind in SEAT_RANK:
            if any(k == kind for k, _ in settle):
                seat = kind
                break
        P0 = sum(float(w_size[k]) * lv for k, lv in settle)
        rec[p["id"]] = {"p": p, "own": dict(own), "seat": seat, "P0": P0, "places": plist}
    settle_ids = {i for i, r in rec.items() if r["seat"]}
    # F2: wilderness to settlements by border, hop by hop
    dist = {i: 0 for i in settle_ids}
    frontier = list(settle_ids)
    while frontier:
        nxt = []
        for i in frontier:
            for n in by_id[i]["neighbours"]:
                j = n["province"]
                if j not in dist and by_id[j]["region"] == by_id[i]["region"]:
                    dist[j] = dist[i] + 1
                    nxt.append(j)
        frontier = nxt
    gathered = defaultdict(lambda: defaultdict(float))
    passed = {}
    wild = sorted([i for i in rec if i not in settle_ids and dist.get(i, 99) <= WILD_HOPS], key=lambda i: -dist[i])
    carry = {i: defaultdict(float, rec[i]["own"]) for i in wild}
    for i in wild:
        nb = [(n["province"], n["border_tiles"]) for n in by_id[i]["neighbours"] if dist.get(n["province"], 99) == dist[i] - 1]
        tot = sum(w for _, w in nb) or 1
        passed[i] = {"to": [{"province": by_id[j]["key"], "share": round(w / tot, 3)} for j, w in nb]}
        for j, w in nb:
            for c, v in carry[i].items():
                if j in settle_ids:
                    gathered[j][c] += v * w / tot
                else:
                    carry[j][c] += v * w / tot
    out = []
    for i, r in sorted(rec.items()):
        p = r["p"]
        is_set = i in settle_ids
        prod = defaultdict(float, r["own"]) if is_set else defaultdict(float)
        if is_set:
            for c, v in gathered[i].items():
                prod[c] += v
        # F1 goods (equal value per unit: the dump's classes are already in comparable units)
        kinds = defaultdict(float)
        for c, v in (prod if is_set else r["own"]).items():
            kinds[c] += v
        goods = sorted(kinds.items(), key=lambda kv: -kv[1])
        main_good = goods[0][0] if goods and goods[0][1] > 0 else None
        secondary = [c for c, v in goods[1:3] if main_good and v >= SECONDARY_SHARE * goods[0][1]]
        # works
        b = []
        if is_set:
            b = [list(x) for x in START_BUILDINGS[r["seat"]]]
            if main_good:
                gb = GOOD_BUILDING.get(next((k for k in GOOD_BUILDING if main_good.startswith(k)), ""), None)
                if gb:
                    b.append([gb, 1])
            if p.get("coast") or p.get("river_tiles", 0) >= 6:
                if r["seat"] in ("city", "great_seat", "town", "market"):
                    b.append(["landing", 1])
        elif any(pl["kind"] == "mine" for pl in r["places"]):
            b = [["mine_works", 1]]   # a wilderness outpost (wild_slots 1)
        cap = CAP0 + sum(CAP_B.get(k, 0) * lv for k, lv in b)
        P0 = r["P0"]
        C = P0 * (1 + cap)
        slots_n = (BASE_SLOTS[r["seat"]] + int(math.floor(P0 / SLOT_POP_STEP))) if is_set else WILD_SLOTS
        slots_n = max(slots_n, len(b))
        infra = None
        acc = None
        usage = sum(prod.values()) if is_set else 0.0
        infra_old = 0.0
        if is_set:
            land_infra = INFRA0[r["seat"]] + I_ROAD * int(road_n[i]) + I_RIVER * min(int(p.get("river_tiles", 0)), RIVER_CAP) + sum(INFRA_B.get(k, 0) * lv for k, lv in b)
            infra_old = max(0.0, START_ACCESS_MIN * usage - land_infra)
            infra = land_infra + infra_old
            acc = 1.0 if usage <= infra else infra / usage
        levels = sum(lv for _, lv in b)
        dev = int(round(levels + P0))
        e = lore["provinces"].get(p["key"], {})
        out.append({"id": i, "key": p["key"], "region": p["region"], "kind": "settlement" if is_set else "wilderness",
                    "seat_kind": r["seat"], "seat_place": p.get("seed_place"),
                    "name": e.get("name") or p.get("name") or "", "name_han": e.get("name_han", ""), "gloss": e.get("gloss", ""),
                    "lore": e.get("lore", ""), "tiles": p["tiles"], "centre": p["centre"], "land": p["land"],
                    "river_tiles": p.get("river_tiles", 0), "road_tiles": int(road_n[i]), "coast": p.get("coast", False),
                    "elev_mean": p.get("elev_mean"), "elev_max": p.get("elev_max"),
                    "places": r["places"],
                    "stats": {"population": round(P0, 2), "capacity": round(C, 2),
                              "production": {c: round(v, 1) for c, v in sorted(prod.items()) if v > 0.05},
                              "own_output": {c: round(v, 1) for c, v in sorted(r["own"].items()) if v > 0.05},
                              "main_good": main_good, "secondary_goods": secondary,
                              "buildings": [{"kind": k, "name": BUILDING_NAMES.get(k, k), "level": lv} for k, lv in b],
                              "slots": slots_n, "infrastructure": None if infra is None else round(infra),
                              "infra_old": round(infra_old), "usage": round(usage), "access": None if acc is None else round(acc, 3),
                              "development": dev},
                    "passes_to": passed.get(i, {}).get("to", []),
                    "neighbours": [{"province": by_id[n["province"]]["key"], "border_tiles": n["border_tiles"]} for n in p["neighbours"]]})
    name_of = {o["key"]: o["name"] for o in out}
    for o in out:   # the gatherers and neighbours by name too, for the panel
        for t in o["passes_to"]:
            t["name"] = name_of.get(t["province"], "")
        for n in o["neighbours"]:
            n["name"] = name_of.get(n["province"], "")
    doc = {"_doc": "Provinces v2 (branch provinces-v2, 2026-11-23 night; proposal): each province's land, places (existing "
                   "and new, design/world/provinces-v2/), lore and start record, from tools/design/map/province_stats_v2.py "
                   "with the Provinces GDD formulas F1-F6. Production in the dump's per-class units for seed 7; population in "
                   "settlement-weight units (w_size x livability); development = built levels + population units (a display "
                   "index, not in the GDD).",
           "schema_version": 1, "provinces": out}
    json.dump(doc, open(os.path.join(ROOT, "assets/data/world_provinces.json"), "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
    # the map's drawing file gets each province's name too, for the names drawn at mid zoom
    gp = os.path.join(ROOT, "assets/map/continent_11_provinces.json")
    g = json.load(open(gp, encoding="utf-8"))
    by_key = {o["key"]: o for o in out}
    for gpv in g["provinces"]:
        o = by_key.get(gpv.get("key", ""))
        if o:
            gpv["name"] = o["name"]
            gpv["label_at"] = label_point(pid, o["id"], o["centre"])
    json.dump(g, open(gp, "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
    n_set = sum(1 for o in out if o["kind"] == "settlement")
    pops = [o["stats"]["population"] for o in out if o["kind"] == "settlement"]
    accs = [o["stats"]["access"] for o in out if o["stats"]["access"] is not None]
    named = sum(1 for o in out if o["name"])
    print("provinces %d (settlement %d); named %d; population median %.1f; access median %.2f, below 1: %d; with a main good %d" % (
        len(out), n_set, named, statistics.median(pops), statistics.median(accs), sum(1 for a in accs if a < 1), sum(1 for o in out if o["stats"]["main_good"])))


if __name__ == "__main__":
    main()
