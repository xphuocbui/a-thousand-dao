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
import struct
import sys
import zlib

from PIL import Image

N8 = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
SETTLED = ("great_seat", "minor_seat", "city", "market", "town", "village", "mine")


GRID_MAGIC = b"DAOGRID1"


def write_grid(m, roads, w, h, out_path):
    """The tile grid as a binary file the game reads exactly (Godot would import a PNG as a texture, and 16-bit values
    would not survive): "DAOGRID1", u16 width, u16 height, u16 layer count, then per layer a 4-byte tag, u8 bytes a
    value, u8 signed, u32 raw length, u32 compressed length and the zlib-compressed values in row order, little-endian.
    Layers: BIO1-3 the tile's biome ids largest first (255 none), SHR1-3 their shares in %, MAIN the main biome (sea when
    sea is half the tile or more), ELEV metres (signed), TEMP (annual mean C + 50) x 2, RAIN annual mm, FEAT feature
    bits, ROAD 0 none / 1 road / 2 trunk / 3 sea lane, REGN region id (0 sea)."""
    base = os.path.join(m, "base")
    mix_b = Image.open(os.path.join(base, "mix_biome.png")).convert("RGB")
    mix_s = Image.open(os.path.join(base, "mix_share.png")).convert("RGB")
    flat = lambda im: list(im.getdata()) if not hasattr(im, "get_flattened_data") else list(im.get_flattened_data())
    mb, ms = flat(mix_b), flat(mix_s)
    layers = []
    for k in range(3):
        layers.append((b"BIO%d" % (k + 1), 1, 0, [v[k] for v in mb]))
    for k in range(3):
        layers.append((b"SHR%d" % (k + 1), 1, 0, [v[k] for v in ms]))
    layers.append((b"MAIN", 1, 0, flat(Image.open(os.path.join(base, "biome.png")))))
    layers.append((b"ELEV", 2, 1, [v - 10000 for v in flat(Image.open(os.path.join(base, "elevation.png")))]))
    layers.append((b"TEMP", 1, 0, flat(Image.open(os.path.join(base, "temperature.png")))))
    layers.append((b"RAIN", 2, 0, flat(Image.open(os.path.join(base, "rainfall.png")))))
    layers.append((b"FEAT", 2, 0, flat(Image.open(os.path.join(base, "features.png")))))
    layers.append((b"ROAD", 1, 0, roads))
    layers.append((b"REGN", 1, 0, flat(Image.open(os.path.join(m, "regions.png")))))
    blob = bytearray(GRID_MAGIC + struct.pack("<HHH", w, h, len(layers)))
    for tag, nb, signed, vals in layers:
        assert len(vals) == w * h, tag
        fmt = {(1, 0): "B", (2, 0): "H", (2, 1): "h"}[(nb, signed)]
        raw = struct.pack("<%d%s" % (len(vals), fmt), *vals)
        comp = zlib.compress(raw, 9)
        blob += tag + struct.pack("<BBII", nb, signed, len(raw), len(comp)) + comp
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, "wb") as fh:
        fh.write(blob)
    return len(blob)


def load(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def track_routes(places, routes, m, travel, w, h):
    """Tracks (user decisions 2026-11-24, provinces-v2): a new settlement or mine with no route walks to the nearest
    place already on the network, along the cheapest land path walked at the wilderness speed over the full terrain
    cost (Formula D's c_wild x speed.road / speed.wilderness on the route scale), so it is reachable before wilderness travel exists. Each joins the network once tracked, so a later one may
    walk to it. Sea and lakes are walked around; a place on a landmass with no network stays without a route.
    Returns [(a_id, b_id, tiles, cost)]."""
    scale = float(travel["speed"]["road"]) / float(travel["speed"]["wilderness"])   # a track is walked, not ridden
    cw = [c * scale for c in road_tile_costs(m, dict(travel, road_terrain_share=1.0), w, h)]
    land, _ = PL_pixels(os.path.join(m, "regions.png"))
    lake_id = int(next(k for k, v in load(os.path.join(m, "base", "meta.json"))["legend"]["biome_ids"].items() if v == "lake"))
    main_b = list(Image.open(os.path.join(m, "base", "biome.png")).getdata())
    ok = [land[i] > 0 and main_b[i] != lake_id for i in range(w * h)]
    on_net = set()
    for r in routes:
        on_net.add(r["a"])
        on_net.add(r["b"])
    at = {}
    for p in places:
        if p["id"] in on_net:
            at.setdefault(p["tile"][1] * w + p["tile"][0], p["id"])
    out = []
    todo = [p for p in places if p.get("v2_slot") and p["kind"] in SETTLED and p["id"] not in on_net]
    for p in sorted(todo, key=lambda q: q["id"]):
        x0, y0 = p["tile"]
        i0 = y0 * w + x0
        best = {i0: 0.0}
        tl = {i0: 0.0}
        pq = [(0.0, i0)]
        hit = None
        while pq:
            c, i = heapq.heappop(pq)
            if c > best.get(i, float("inf")) or c > 1200:
                continue
            if i in at and at[i] != p["id"]:
                hit = (at[i], tl[i], c)
                break
            x, y = i % w, i // w
            for dx, dy in N8:
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h:
                    j = ny * w + nx
                    if not ok[j]:
                        continue
                    d = 1.4142 if dx and dy else 1.0
                    nc = c + d * cw[j]
                    if nc < best.get(j, float("inf")):
                        best[j] = nc
                        tl[j] = tl[i] + d
                        heapq.heappush(pq, (nc, j))
        if hit:
            out.append((min(p["id"], hit[0]), max(p["id"], hit[0]), hit[1], hit[2]))
            at.setdefault(i0, p["id"])
    return out


def PL_pixels(path):
    im = Image.open(path)
    return list(im.getdata()), im.size


def road_tile_costs(m, travel, w, h):
    """Travel & Map Formula D's road c_t per tile: 1 + r_share x (c_wild - 1), with c_wild the share-weighted biome
    cost of the tile's land parts (lake and sea parts are walked around and left out of the weights)."""
    legend = load(os.path.join(m, "base", "meta.json"))["legend"]["biome_ids"]
    cost = travel["biome_cost"]
    r_share = float(travel["road_terrain_share"])
    ids = Image.open(os.path.join(m, "base", "mix_biome.png")).convert("RGB").load()
    shares = Image.open(os.path.join(m, "base", "mix_share.png")).convert("RGB").load()
    out = [1.0] * (w * h)
    for y in range(h):
        for x in range(w):
            num = den = 0.0
            for b, sh in zip(ids[x, y], shares[x, y]):
                if b == 255 or sh == 0:
                    continue
                name = legend.get(str(b), "")
                if name in cost:
                    num += sh * float(cost[name])
                    den += sh
            c_wild = num / den if den > 0 else 1.0
            out[y * w + x] = 1.0 + r_share * (c_wild - 1.0)
    return out


def road_routes(roads, w, h, places, ct=None, cw=None):
    """Road links between neighbouring places: a Dijkstra over road tiles (8 neighbours; a diagonal step counts sqrt 2
    tiles) from every place at once gives each road tile to its nearest place, and two places are joined where their
    road areas meet, with length = distance to the meeting tiles from each side plus the step between them. A place
    whose tile is off the road starts from its nearest road tile within 4 tiles, that far along. A link is "trunk" when
    both sides' paths to the meeting point run on trunk road. With [ct] (road c_t per tile) the split and the lengths are
    by travel cost (each step costs its length times the entered tile's c_t), and the tile length is tracked beside it.
    Returns {(a_id, b_id): (tiles, all_trunk, cost)}, a_id < b_id."""
    def is_road(i):
        return roads[i] in (1, 2)
    best = {}
    tl = {}
    owner = {}
    trunk = {}
    pq = []
    step_c = (lambda j, d: d * ct[j]) if ct is not None else (lambda j, d: d)
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
        for d0, i in seeds:
            # a provinces-v2 place walks its off-road start at the full terrain cost (cw), so its route is never
            # quicker than the tile path; the authored places keep their old reading (cost = distance)
            c = d0 * cw[i0] if (cw is not None and p.get("v2_slot")) else d0
            if c < best.get(i, float("inf")):
                best[i] = c
                tl[i] = d0
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
                d = math.sqrt(2.0) if ox and oy else 1.0
                nc = c + step_c(j, d)
                if nc < best.get(j, float("inf")):
                    best[j] = nc
                    tl[j] = tl[i] + d
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
                d = math.sqrt(2.0) if ox and oy else 1.0
                cost = best[i] + best[j] + step_c(j, d)
                key = (min(a, b), max(a, b))
                t = trunk[i] and trunk[j]
                if key not in out or cost < out[key][2]:
                    out[key] = (tl[i] + tl[j] + d, t, cost)
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
    ap.add_argument("--travel", default="assets/data/travel_rules.json")
    ap.add_argument("--grid", default="assets/map/continent_11_grid.bin")
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
    travel = load(a.travel)
    ct = road_tile_costs(m, travel, w, h)

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
    # the territory history's layer (history_places.py): promoted cities, city founding years, fixed ruins
    hp_path = os.path.join(m, "history_places.json")
    if os.path.exists(hp_path):
        hp = load(hp_path)
        by_id = {p["id"]: p for p in places}
        for pr in hp.get("promotions", []):
            q = by_id[pr["place_id"]]
            q["kind"] = "city"
            q["former_name"] = q["name"]   # sea lanes and origin choices in the earlier layers name the town
            q["name"] = pr["name_hv"]
            for k in ("name_han", "gloss"):
                if pr.get(k):
                    q[k] = pr[k]
            q["founded"] = pr["founded"]
        for cy in hp.get("city_years", []):
            by_id[cy["place_id"]]["founded"] = cy["founded"]
        for r in hp.get("ruins", []):
            q = {"id": next_id, "kind": "ruin", "tile": r["tile"], "region": r["region"], "biome": r.get("biome", ""),
                 "elevation_km": r.get("elevation_km", 0.0), "port": False, "river": r.get("river", False),
                 "coast": r.get("coast", False), "livability": r.get("livability", 0.0), "name": r["name_hv"],
                 "on_road": False, "array": False, "former": r["former"], "lived": r["lived"]}
            for k in ("name_han", "gloss", "note"):
                if r.get(k):
                    q[k] = r[k]
            q["holder"] = sect_key(r.get("holder"))
            q["territory"] = sect_key(r.get("territory"))
            places.append(q)
            next_id += 1
        for s in hp.get("minor_seats", []):
            q = {"id": next_id, "kind": "minor_seat", "tile": s["tile"], "region": s["region"], "biome": s.get("biome", ""),
                 "elevation_km": s.get("elevation_km", 0.0), "port": False, "river": s.get("river", False),
                 "coast": s.get("coast", False), "livability": s.get("livability", 0.0), "name": s["name_hv"],
                 "key": s["key"], "on_road": False, "array": False}
            for k in ("name_han", "gloss", "note"):
                if s.get(k):
                    q[k] = s[k]
            q["holder"] = s["key"]
            q["territory"] = sect_key(s.get("territory"))
            places.append(q)
            next_id += 1
            minor.append({k: s[k] for k in ("key", "name_hv", "name_han", "gloss", "alignment", "leans", "craft", "lord",
                                           "region") if k in s})
    # beast lairs and special sites (sites.py; approved by the user 2026-11-20): places of their authored good
    st_path = os.path.join(m, "sites.json")
    if os.path.exists(st_path):
        for s in load(st_path)["places"]:
            q = {"id": next_id, "kind": s["kind"], "tile": s["tile"], "region": s["region"], "biome": s.get("biome", ""),
                 "elevation_km": s.get("elevation_km", 0.0), "port": False, "river": False, "coast": False,
                 "livability": 0.0, "name": s.get("name_hv", ""), "on_road": False, "array": False,
                 "resource": s["good"]}
            for k in ("name_han", "gloss", "note"):
                if s.get(k):
                    q[k] = s[k]
            q["holder"] = sect_key(s.get("holder"))
            q["territory"] = sect_key(s.get("territory"))
            places.append(q)
            next_id += 1
    # the provinces-v2 places (tools/design/map/places_v2_merge.py; user decisions 2026-11-24): appended last, so no
    # earlier id moves; only their settlements join the roads (v2_road); kept sites carry site_grade, the others no_site
    v2_path = os.path.join(m, "provinces_v2_places.json")
    if os.path.exists(v2_path):
        v2 = load(v2_path)
        for s in v2["places"]:
            q = {"id": next_id, "kind": s["kind"], "tile": s["tile"], "region": s["region"], "biome": s.get("biome", ""),
                 "elevation_km": s.get("elevation_km", 0.0), "port": False, "river": bool(s.get("river", False)),
                 "coast": bool(s.get("coast", False)), "livability": s.get("livability", 0.0), "name": s["name_hv"],
                 "on_road": bool(s.get("v2_road", False)), "array": False, "province": s["province"],
                 "v2_slot": s["v2_slot"], "v2_road": bool(s.get("v2_road", False))}
            for k in ("name_han", "gloss", "key", "former", "lived", "site_grade", "no_site"):
                if s.get(k) not in (None, ""):
                    q[k] = s[k]
            q["holder"] = s.get("holder", "")
            q["territory"] = s.get("territory", "")
            places.append(q)
            next_id += 1
        for s in v2.get("minor_sects", []):
            minor.append({k: s[k] for k in ("key", "name_hv", "name_han", "gloss", "alignment", "leans", "craft", "lord",
                                           "region", "founded") if k in s})
    by_key = {p["key"]: p for p in places if p.get("key")}
    by_name = {p["name"]: p for p in places}
    for p in places:
        if p.get("former_name"):
            by_name.setdefault(p["former_name"], p)

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
        if s.get("founded") is not None:   # the provinces-v2 sects carry their founding year
            minor_out[-1]["founded"] = s["founded"]

    # origins: each approved home choice resolved to the place it starts at (fixed-world decisions: a sect disciple at
    # its sect's seat, a loose cultivator at a cultivator market, a clan heir in its clan's town)
    seat_by_name = {}
    for g in great_out + minor_out:
        if g["seat"] is not None:
            seat_by_name[g["name"]] = g["seat"]
    origin_homes = {}
    unresolved = []
    for oid, od in origins.get("origins", {}).items():
        homes = []
        for ch in od.get("choices", []):
            names = []
            if "sect" in ch:
                pid = seat_by_name.get(ch["sect"])
                homes.append(pid) if pid is not None else unresolved.append([oid, ch["sect"]])
                continue
            names = ch.get("market", []) if "market" in ch else [ch.get("town", "")]
            for nm in names:
                pl = by_name.get(nm)
                homes.append(pl["id"]) if pl is not None else unresolved.append([oid, nm])
        origin_homes[oid] = homes

    routes = []
    # off the road a traveller walks at the wilderness speed over the full terrain cost (Formula D): on the route's
    # road-speed scale that is c_wild x speed.road / speed.wilderness per tile
    wild_scale = float(travel["speed"]["road"]) / float(travel["speed"]["wilderness"])
    wild_costs = [c * wild_scale for c in road_tile_costs(m, dict(travel, road_terrain_share=1.0), w, h)]
    for p in places:   # "on road" means on a road tile (as the authored flag); v2_road only says the place is routed
        if p.get("v2_slot"):
            x0, y0 = p["tile"]
            p["on_road"] = bool(p.get("v2_road")) and roads[y0 * w + x0] in (1, 2)
    routed = [p for p in places if "v2_road" not in p or p["v2_road"]]   # new wild places stay off the roads
    for p in places:
        p.pop("v2_road", None)
    for (x, y), (tiles, trunk, cost) in sorted(road_routes(roads, w, h, routed, ct, wild_costs).items()):
        routes.append({"a": x, "b": y, "kind": "trunk" if trunk else "road", "tiles": round(tiles, 3),
                       "km": round(tiles * km_per_tile, 1), "cost": round(cost, 3)})
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
        routes.append({"a": x, "b": y, "kind": "lane", "tiles": round(tl, 3), "km": round(tl * km_per_tile, 1),
                       "cost": round(tl, 3)})   # Formula D: c_t = 1 at sea
    for a_id, b_id, tiles, cost in track_routes(places, routes, m, travel, w, h):
        routes.append({"a": a_id, "b": b_id, "kind": "track", "tiles": round(tiles, 3),
                       "km": round(tiles * km_per_tile, 1), "cost": round(cost, 3)})

    # each mine's authored resource (user decision 2026-11-20: by its name; mine_resources.json)
    mr_path = os.path.join(m, "mine_resources.json")
    if os.path.exists(mr_path):
        by_pid = {p["id"]: p for p in places}
        for row in load(mr_path)["mines"]:
            q = by_pid.get(row["place"])
            if q is None or q["name"] != row["name"]:
                raise SystemExit("mine_resources.json: place %s is not %s" % (row["place"], row["name"]))
            q["resource"] = row["resource"]
    # Travel & Map Formula C (tools/design/map/land_qi.py, run after a first export): each place's qi, and the qi layer
    qi_file, mu = "", {}
    lq_path = os.path.join(m, "land_qi.json")
    if os.path.exists(lq_path):
        lq = load(lq_path)
        qi_by_id = {q["id"]: q for q in lq["places"] if isinstance(q["id"], int)}
        for p in places:
            q = qi_by_id.get(p["id"])
            if q is None or q["name"] != p["name"]:
                continue
            p["qi"] = {"part": q["part"], "part_biome": q["biome"], "shares": q["shares"], "variants": q["variants"],
                       "land_density": q["land_density"], "land_danger": q["land_danger"]}
            p["density"] = q["density"]
            p["danger"] = q["danger"]
        mu = lq["mu"]
        qi_file = "res://assets/map/continent_11_qi.bin"
    missing_qi = [p["name"] for p in places if "density" not in p]
    out = {
        "schema_version": 1,
        "_doc": ("The authored continent (design/map/continent-11, approved by the user 2026-11-13/14), exported by "
                 "tools/design/map/export_continent.py; do not edit by hand, edit the design data and re-export. "
                 "regions: id, name, holder (great sect key), centre tile, size, neighbours, biome shares. "
                 "great_sects / minor_sects: key, names, tier or lord, leans, seat (place id). places: id, kind, tile "
                 "[x, y] on the 540 x 360 grid (25 km tiles), region, holder and territory (great sect keys), land "
                 "flags, names (holder: the great or minor sect key holding the place, "" for an unheld wild site); sacred places follow the 204 settled and wild ones. routes: a, b (place ids, a < b), "
                 "kind road | trunk | lane, length in tiles and km, and cost: Travel & Map Formula D's sum of c_t "
                 "along the route (road tiles 1 + r_share x (c_wild - 1) from the tile's biome mix, sea 1; "
                 "ContinentData.trip_seasons divides it by the mode's speed). grid_file: the tile grid (ContinentGrid; "
                 "the layers are listed in the exporter); legend: biome ids and feature bits as the grid stores them. arrays: the teleport-array cities. origins: the origin home choices (approved); origin_homes: per origin id, the place ids a character of that origin may start at. "
                 "Each place also carries density, danger and qi (Travel & Map Formula C, tools/design/map/land_qi.py: the tile part it reads, its "
                 "biome, the five base shares summing to 100, variants outside the 100, land density and land danger before the kind's offset and "
                 "settlement cut); qi_file: the per-tile-part qi layer (S<k><el>, V<k><el> shares x 100, DEN<k> density x 1000, DAN<k> danger, k = 1..3 "
                 "the tile's parts); mu: Formula A's world mean shares over places."),
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
        "origin_homes": origin_homes,
        "grid_file": "res://" + a.grid.replace("\\", "/"),
        "qi_file": qi_file,
        "mu": mu,
        "legend": {"biome_ids": load(os.path.join(m, "base", "meta.json"))["legend"]["biome_ids"],
                   "feature_bits": load(os.path.join(m, "base", "meta.json"))["legend"]["feature_bits"]},
    }
    grid_bytes = write_grid(m, roads, w, h, a.grid)
    # the terrain's version (World Generation Core Rule 13): a save records it, and one made on another is refused
    import hashlib
    hh = hashlib.sha256()
    for f in (a.grid, os.path.join(os.path.dirname(a.grid), "continent_11_qi.bin")):
        if os.path.exists(f):
            with open(f, "rb") as fh:
                hh.update(fh.read())
    out["map_version"] = hh.hexdigest()[:16]
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    with open(a.out, "w", encoding="utf-8") as fh:
        json.dump(out, fh, ensure_ascii=False, indent=1)
    kinds = {}
    for r in routes:
        kinds[r["kind"]] = kinds.get(r["kind"], 0) + 1
    print(json.dumps({"regions": len(regions), "great_sects": len(great_out), "minor_sects": len(minor_out),
                      "places": len(places), "routes": kinds, "arrays": len(out["arrays"]),
                      "lanes_not_traced": missing_lanes, "places_without_qi": missing_qi, "origins_unresolved": unresolved, "out": a.out, "grid": a.grid, "grid_bytes": grid_bytes},
                     ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
