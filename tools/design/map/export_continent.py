"""Export the authored continent to the game's data (design/gdd/travel-map.md; design/research/fixed-world-decisions.md).

Reads the approved design data of a continent (design/map/continent-11: regions, great and minor sects, places,
sacred places, sea lanes, teleport arrays, origins and roads.png) and writes one game data file,
assets/data/world_continent.json, that the game loads with ContinentData (src/gameplay/world/continent_data.gd).

Routes are derived here, because places.py saves its roads only as an index image (1 road, 2 trunk road, 3 sea lane):
- road routes: the road network split among the places by nearest place along the road (a Voronoi split by Dijkstra);
  two places are neighbours where their road areas meet, the length is the road distance between them through that
  meeting point, and the kind is "trunk" when both halves run on trunk road;
- a sea lane joins the two ports places.py named, measured along lane tiles from water next to one port to water
  next to the other;
- teleport arrays are listed, not routed (Travel & Map rule 11 sets who may use them and the fee).
Distances are in tiles and km (25 km a tile). Travel time is not computed here: Travel & Map Formula D owns it.

The output is data, not a decision: every name, holder and place was approved by the user (README of the continent).
The ground grid (biome mix, elevation, temperature, rain, features) stays in the index images and is not exported.

Usage:
    python tools/design/map/export_continent.py [--map design/map/continent-11] [--out assets/data/world_continent.json]
"""
import argparse
import heapq
import json
import math
import os
import sys

from PIL import Image

N8 = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
SETTLED = ("great_seat", "minor_seat", "city", "market", "town", "village", "mine")


def load(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def road_routes(roads, w, h, places):
    """Road links between neighbouring places: a Dijkstra over road tiles (8 neighbours; a diagonal step counts sqrt 2
    tiles) from every place at once gives each road tile to its nearest place, and two places are joined where their
    road areas meet, with length = distance to the meeting tiles from each side plus the step between them. A place
    whose tile is off the road starts from its nearest road tile within 4 tiles, that far along. A link is "trunk" when
    both sides' paths to the meeting point run on trunk road. Returns {(a_id, b_id): (tiles, all_trunk)}, a_id < b_id."""
    def is_road(i):
        return roads[i] in (1, 2)
    best = {}
    owner = {}
    trunk = {}
    pq = []
    for p in places:
        x0, y0 = p["tile"]
        i0 = y0 * w + x0
        seeds = []
        if is_road(i0):
            seeds = [(0.0, i0)]
        else:
            for y in range(y0 - 4, y0 + 5):
                for x in range(x0 - 4, x0 + 5):
                    if 0 <= x < w and 0 <= y < h and is_road(y * w + x):
                        seeds.append((math.dist((x, y), (x0, y0)), y * w + x))
            seeds = sorted(seeds)[:1]
        for c, i in seeds:
            if c < best.get(i, float("inf")):
                best[i] = c
                owner[i] = p["id"]
                trunk[i] = roads[i] == 2
                heapq.heappush(pq, (c, i))
    while pq:
        c, i = heapq.heappop(pq)
        if c > best[i]:
            continue
        x, y = i % w, i // w
        for ox, oy in N8:
            nx, ny = x + ox, y + oy
            if 0 <= nx < w and 0 <= ny < h:
                j = ny * w + nx
                if not is_road(j):
                    continue
                nc = c + (math.sqrt(2.0) if ox and oy else 1.0)
                if nc < best.get(j, float("inf")):
                    best[j] = nc
                    owner[j] = owner[i]
                    trunk[j] = trunk[i] and roads[j] == 2
                    heapq.heappush(pq, (nc, j))
    out = {}
    for i, a in owner.items():
        x, y = i % w, i // w
        for ox, oy in N8:
            nx, ny = x + ox, y + oy
            if 0 <= nx < w and 0 <= ny < h:
                j = ny * w + nx
                b = owner.get(j)
                if b is None or b == a:
                    continue
                length = best[i] + best[j] + (math.sqrt(2.0) if ox and oy else 1.0)
                key = (min(a, b), max(a, b))
                t = trunk[i] and trunk[j]
                if key not in out or length < out[key][0]:
                    out[key] = (length, t)
    return out


def lane_length(roads, w, h, a, b):
    """Tiles along sea-lane tiles (3) from water next to port a to water next to port b (None if not joined)."""
    def docks(p):
        x0, y0 = p["tile"]
        return {(y * w + x) for x in range(x0 - 2, x0 + 3) for y in range(y0 - 2, y0 + 3)
                if 0 <= x < w and 0 <= y < h and roads[y * w + x] == 3}
    starts, goals = docks(a), docks(b)
    if not starts or not goals:
        return None
    best = {s: 0.0 for s in starts}
    pq = [(0.0, s) for s in starts]
    heapq.heapify(pq)
    while pq:
        c, i = heapq.heappop(pq)
        if c > best[i]:
            continue
        if i in goals:
            return c
        x, y = i % w, i // w
        for ox, oy in N8:
            nx, ny = x + ox, y + oy
            if 0 <= nx < w and 0 <= ny < h:
                j = ny * w + nx
                if roads[j] != 3:
                    continue
                nc = c + (math.sqrt(2.0) if ox and oy else 1.0)
                if nc < best.get(j, float("inf")):
                    best[j] = nc
                    heapq.heappush(pq, (nc, j))
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", default="design/map/continent-11")
    ap.add_argument("--out", default="assets/data/world_continent.json")
    a = ap.parse_args()
    m = a.map
    places_doc = load(os.path.join(m, "places.json"))
    regions_doc = load(os.path.join(m, "regions.json"))
    politics = load(os.path.join(m, "politics_proposal.json"))
    minor = load(os.path.join(m, "minor_sects.json"))["minor_sects"]
    sacred = load(os.path.join(m, "sacred.json"))
    origins = load(os.path.join(m, "origins_proposal.json"))
    km_per_tile = float(places_doc["check"]["params"]["km_per_tile"])
    img = Image.open(os.path.join(m, "roads.png"))
    w, h = img.size
    roads = list(img.getdata()) if not hasattr(img, "get_flattened_data") else list(img.get_flattened_data())

    great = politics["great_sects"]
    great_by_name = {g["name_hv"]: g for g in great}
    minor_by_name = {s["name_hv"]: s for s in minor}

    def sect_key(name):
        """The great or minor sect key for a holder or territory name ("" for none)."""
        if not name:
            return ""
        return (great_by_name.get(name) or minor_by_name.get(name) or {}).get("key", "")
    places = []
    for p in places_doc["places"]:
        q = {k: p[k] for k in ("id", "kind", "tile", "region", "biome", "elevation_km", "port", "river", "coast",
                               "livability") if k in p}
        q["name"] = p.get("name_hv", "")
        for k in ("name_han", "gloss", "key", "note"):
            if p.get(k):
                q[k] = p[k]
        q["holder"] = sect_key(p.get("holder"))
        q["territory"] = sect_key(p.get("territory"))
        q["on_road"] = bool(p.get("on_road", False))
        q["array"] = bool(p.get("array", False))
        places.append(q)
    next_id = max(p["id"] for p in places) + 1
    for s in sacred["places"]:
        q = {"id": next_id, "kind": s["kind"], "tile": s["tile"], "region": s["region"], "biome": s.get("biome", ""),
             "elevation_km": s.get("elevation_km", 0.0), "port": False, "river": False, "coast": False,
             "livability": 0.0, "name": s.get("name_hv", ""), "on_road": False, "array": False}
        for k in ("name_han", "gloss", "note"):
            if s.get(k):
                q[k] = s[k]
        q["holder"] = sect_key(s.get("holder"))
        q["territory"] = sect_key(s.get("territory"))
        places.append(q)
        next_id += 1
    by_key = {p["key"]: p for p in places if p.get("key")}
    by_name = {p["name"]: p for p in places}

    regions = []
    for r in regions_doc["regions"]:
        g = great_by_name.get(r.get("sect", ""), {})
        regions.append({"id": r["id"], "name": r.get("name_hv", ""), "name_han": r.get("name_han", ""),
                        "gloss": r.get("gloss", ""), "holder": g.get("key", ""), "centre_tile": r["centre_tile"],
                        "tiles": r["tiles"], "landmass": r.get("landmass", ""), "neighbours": r.get("neighbours", []),
                        "biomes": r.get("biomes", []), "mean_temp_c": r.get("mean_temp_c"),
                        "mean_rain_mm": r.get("mean_rain_mm")})
    great_out = []
    for g in great:
        seat = by_key.get(g["key"])
        great_out.append({"key": g["key"], "name": g["name_hv"], "name_han": g.get("name_han", ""),
                          "gloss": g.get("gloss", ""), "tier": g["tier"], "leans": g.get("leans", []),
                          "regions": g.get("regions", []), "seat_region": g.get("seat_region"),
                          "seat": seat["id"] if seat else None})
    minor_out = []
    for s in minor:
        seat = by_key.get(s["key"])
        minor_out.append({"key": s["key"], "name": s["name_hv"], "name_han": s.get("name_han", ""),
                          "gloss": s.get("gloss", ""), "alignment": s.get("alignment", ""), "leans": s.get("leans", []),
                          "craft": s.get("craft", ""), "lord": s.get("lord", ""), "region": s.get("region"),
                          "seat": seat["id"] if seat else None})

    routes = []
    for (x, y), (tiles, trunk) in sorted(road_routes(roads, w, h, places).items()):
        routes.append({"a": x, "b": y, "kind": "trunk" if trunk else "road", "tiles": round(tiles, 2),
                       "km": round(tiles * km_per_tile, 1)})
    missing_lanes = []
    for na, nb in places_doc.get("sea_lanes", []):
        pa, pb = by_name.get(na), by_name.get(nb)
        if pa is None or pb is None:
            missing_lanes.append([na, nb])
            continue
        tl = lane_length(roads, w, h, pa, pb)
        if tl is None:
            tl = math.dist(pa["tile"], pb["tile"])
            missing_lanes.append([na, nb])
        x, y = sorted((pa["id"], pb["id"]))
        routes.append({"a": x, "b": y, "kind": "lane", "tiles": round(tl, 2), "km": round(tl * km_per_tile, 1)})

    out = {
        "schema_version": 1,
        "_doc": ("The authored continent (design/map/continent-11, approved by the user 2026-11-13/14), exported by "
                 "tools/design/map/export_continent.py; do not edit by hand, edit the design data and re-export. "
                 "regions: id, name, holder (great sect key), centre tile, size, neighbours, biome shares. "
                 "great_sects / minor_sects: key, names, tier or lord, leans, seat (place id). places: id, kind, tile "
                 "[x, y] on the 540 x 360 grid (25 km tiles), region, holder and territory (great sect keys), land "
                 "flags, names (holder: the great or minor sect key holding the place, "" for an unheld wild site); sacred places follow the 204 settled and wild ones. routes: a, b (place ids, a < b), "
                 "kind road | trunk | lane, length in tiles and km (Travel & Map Formula D turns them into travel "
                 "time). arrays: the teleport-array cities. origins: the origin home choices (approved)."),
        "source": m.replace("\\", "/"),
        "grid": [w, h],
        "km_per_tile": km_per_tile,
        "regions": regions,
        "great_sects": great_out,
        "minor_sects": minor_out,
        "places": places,
        "routes": routes,
        "arrays": [p["id"] for p in places if p.get("array")],
        "origins": origins.get("origins", {}),
    }
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    with open(a.out, "w", encoding="utf-8") as fh:
        json.dump(out, fh, ensure_ascii=False, indent=1)
    kinds = {}
    for r in routes:
        kinds[r["kind"]] = kinds.get(r["kind"], 0) + 1
    print(json.dumps({"regions": len(regions), "great_sects": len(great_out), "minor_sects": len(minor_out),
                      "places": len(places), "routes": kinds, "arrays": len(out["arrays"]),
                      "lanes_not_traced": missing_lanes, "out": a.out}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
