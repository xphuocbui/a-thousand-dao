"""Where each province's new places go (user, 2026-11-23 night: "for each province, we should add cities, sects, mines,
ruin, some sort of special location ... please make sure that the place fits the province"). The slots are decided
from the land alone, deterministically; their names and lore are written afterwards (design/world/provinces-v2/,
one file per region), and checked by places_v2_check.py.

Per province (v2, tools/design/map/provinces_v2.py):
- special: exactly one natural or storied place, unless the province already has one; the kind follows the land
  (mountains -> peak, volcanic -> volcano / lava vent, forest -> forest / beast lair, swamp -> beast lair, highland ->
  hot spring / spirit vein, a lake shore -> lake, plains -> spirit vein, karst -> gorge), on the tile that suits it
  (the highest for a peak, a lake-side tile for a lake, the steepest for a gorge ...);
- mine: where rock (high mountain, highland, badlands, karst, volcano) is at least ROCK_MINE of the land and the
  province has no mine, on its steepest tile, for SHARE_MINE of such provinces;
- ruin: SHARE_RUIN of provinces, its former kind by the land (a fort in the mountains, a sect, a town or a city);
- settlement: a wilderness province whose land is mostly livable gets a village (a town on a river or coast for
  SHARE_TOWN of them), on its most livable tile near the middle; it becomes a settlement province;
- minor sect (proposal only): in each region, the settlement province with the best land and qi and no seat gets a
  proposed minor sect seat (not merged into the world: Sects and world generation count sects).
A slot never sits within MIN_GAP tiles of another place.

Run: python -I tools/design/map/places_v2.py  ->  design/world/provinces-v2/slots.json and briefs/region_<r>.json
"""
import hashlib
import json
import os
import sys
from collections import Counter, defaultdict

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import provinces as P  # noqa: E402

ROOT = P.ROOT
OUT = os.path.join(ROOT, "design/world/provinces-v2")
ROCK = {"high_mountain", "highland", "badlands", "karst", "volcano"}
LIVABLE = {"temperate_forest", "bamboo_forest", "jungle", "grassland", "steppe", "highland"}
NATURAL = {"peak", "spirit_vein", "hot_spring", "lake", "island", "lava_vent", "forest", "volcano", "gorge",
           "lightning_wood", "beast_lair"}
SETTLED = {"village", "town", "city", "market", "great_seat", "minor_seat"}
ROCK_MINE = 0.35
SHARE_MINE = 0.55
SHARE_RUIN = 0.22
SHARE_TOWN = 0.15
LIVABLE_MIN = 0.6
MIN_GAP = 3


def chance(key, salt):
    return int(hashlib.sha1((key + "|" + salt).encode()).hexdigest()[:8], 16) / 0xFFFFFFFF


def _landmass(fw, tile):
    """The fine cells of the landmass holding [tile] (4-connected land of fine_water)."""
    from collections import deque
    land = (fw & 3) == 0
    y, x = tile[1] * 4 + 2, tile[0] * 4 + 2
    if not land[y, x]:
        return set()
    seen = {(y, x)}
    q = deque([(y, x)])
    while q and len(seen) < 20000:   # an isle, not the mainland
        cy, cx = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (cy + dy, cx + dx)
            if 0 <= n[0] < land.shape[0] and 0 <= n[1] < land.shape[1] and land[n] and n not in seen:
                seen.add(n)
                q.append(n)
    return seen


def main():
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    meta = json.load(open(os.path.join(ROOT, "design/map/continent-11/base/meta.json"), encoding="utf-8"))
    names = {int(k): str(v) for k, v in meta["legend"]["biome_ids"].items()}
    W, H, L = P.read_grid(os.path.join(ROOT, cont["grid_file"].replace("res://", "")))
    main_b = L["MAIN"].astype(np.int32)
    elev = L["ELEV"].astype(np.float32)
    road = L["ROAD"].astype(np.int32) > 0
    qi = None
    v2 = os.path.join(ROOT, "design/map/continent-11/provinces-v2")
    provs = json.load(open(os.path.join(v2, "provinces.json"), encoding="utf-8"))["provinces"]
    pid = np.asarray(Image.open(os.path.join(v2, "province_ids.png"))).astype(np.int32)
    river = np.fromfile(os.path.join(ROOT, "assets/map/terrain/river.bin"), np.uint8).reshape(2880, 4320).reshape(360, 8, 540, 8).max(axis=(1, 3)) > 90
    water = pid == 0
    lake = main_b == P.LAKE_ID
    sea = main_b == P.SEA_ID
    near_lake = np.zeros_like(lake)
    near_sea = np.zeros_like(sea)
    for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        near_lake |= np.roll(np.roll(lake, dy, 0), dx, 1)
        near_sea |= np.roll(np.roll(sea, dy, 0), dx, 1)
    slope = np.zeros_like(elev)
    for dy, dx in ((1, 0), (0, 1)):
        slope = np.maximum(slope, np.abs(elev - np.roll(np.roll(elev, dy, 0), dx, 1)))
    taken = [tuple(p["tile"]) for p in cont["places"]]
    places_by = {p["id"]: p for p in cont["places"]}
    region_name = {r.get("id", i + 1): r.get("name", "") for i, r in enumerate(cont["regions"])}

    def free(x, y):
        return all(max(abs(x - a), abs(y - b)) >= MIN_GAP for a, b in taken)

    def pick(mask, score):
        """The best free tile of [mask] by [score] (higher first), or None."""
        ys, xs = np.nonzero(mask)
        if len(xs) == 0:
            return None
        order = np.argsort(-score[ys, xs])
        for k in order[:400]:
            x, y = int(xs[k]), int(ys[k])
            if free(x, y):
                return x, y
        return None

    slots = []
    by_region = defaultdict(list)
    for p in provs:
        i, key = p["id"], p["key"]
        m = pid == i
        ys, xs = np.nonzero(m)
        bio = Counter(names[int(b)] for b in main_b[ys, xs].tolist())
        n = len(xs)
        share = {k: v / n for k, v in bio.items()}
        rock = sum(share.get(k, 0) for k in ROCK)
        liv = sum(share.get(k, 0) for k in LIVABLE)
        have = Counter(places_by[q]["kind"] for q in p["places"])
        cx, cy = p["centre"]
        centre_d = -((np.arange(W)[None, :] - cx) ** 2 + (np.arange(H)[:, None] - cy) ** 2).astype(np.float32)
        new = []

        def add(kind, tile, **extra):
            if tile is None:
                return
            taken.append(tile)
            x, y = tile
            rec = {"slot": "%s_%s_%d" % (key, kind, len(new) + 1), "province": key, "kind": kind, "tile": [x, y],
                   "biome": names[int(main_b[y, x])], "elevation_km": round(float(elev[y, x]) / 1000.0, 2),
                   "river": bool(river[y, x]), "coast": bool(near_sea[y, x]), "lake_shore": bool(near_lake[y, x])}
            rec.update(extra)
            new.append(rec)

        dom = max(share, key=share.get)
        # settlement first, so the special place keeps its distance from it
        if p["seed_kind"] == "wilderness" and liv >= LIVABLE_MIN:
            good = m & np.isin(main_b, [k for k, v in names.items() if v in LIVABLE]) & (elev < 1600)
            score = centre_d * 0.02 + river * 6.0 + road * 4.0 + near_sea * 3.0 - elev / 400.0
            t = pick(good, score)
            if t is not None:
                town = (river[t[1], t[0]] or near_sea[t[1], t[0]]) and chance(key, "town") < SHARE_TOWN
                add("town" if town else "village", t)
        if not any(k in NATURAL for k in have):
            special = None
            if share.get("volcano", 0) >= 0.15:
                special = ("volcano" if chance(key, "v") < 0.4 else "lava_vent", m & (main_b == 13), elev)
            elif share.get("high_mountain", 0) + share.get("glacier", 0) >= 0.3:
                special = ("peak", m, elev)
            elif m[near_lake].any() and chance(key, "lake") < 0.7:
                special = ("lake", m & near_lake, centre_d)
            elif share.get("karst", 0) >= 0.25:
                special = ("gorge", m & (main_b == 12), slope)
            elif share.get("swamp", 0) + share.get("miasma", 0) + share.get("mangrove", 0) >= 0.3:
                special = ("beast_lair", m, centre_d)
            elif share.get("temperate_forest", 0) + share.get("jungle", 0) + share.get("bamboo_forest", 0) >= 0.5:
                special = ("forest" if chance(key, "f") < 0.45 else ("beast_lair" if chance(key, "f2") < 0.6 else "lightning_wood" if share.get("bamboo_forest", 0) > 0.3 else "spirit_vein"), m, centre_d)
            elif share.get("highland", 0) + share.get("high_mountain", 0) >= 0.3:
                special = ("hot_spring" if chance(key, "h") < 0.5 else "spirit_vein", m, slope)
            elif share.get("glacier", 0) + share.get("tundra", 0) >= 0.4:
                special = ("beast_lair" if chance(key, "t") < 0.5 else "spirit_vein", m, centre_d)
            else:
                special = ("spirit_vein" if chance(key, "s") < 0.5 else ("beast_lair" if chance(key, "b") < 0.5 else "hot_spring"), m, centre_d)
            kind, mask, score = special
            add(kind, pick(mask, score))
        if rock >= ROCK_MINE and have.get("mine", 0) == 0 and chance(key, "mine") < SHARE_MINE:
            add("mine", pick(m & np.isin(main_b, [k for k, v in names.items() if v in ROCK]), slope))
        if chance(key, "ruin") < SHARE_RUIN and have.get("ruin", 0) == 0:
            former = "fort" if rock > 0.5 else ("sect" if chance(key, "rf") < 0.4 else ("town" if liv > 0.5 else "city"))
            add("ruin", pick(m, -centre_d * 0.0 + slope * 0.2 + centre_d * 0.01), former=former)
        for s in new:
            slots.append(s)
        p2 = {"key": key, "id": i, "kind": "settlement" if (p["seed_kind"] != "wilderness" or any(s["kind"] in SETTLED for s in new)) else "wilderness",
              "seat": places_by[p["seed_place"]]["name"] if p["seed_place"] else None,
              "tiles": n, "centre": p["centre"], "land": {k: round(v, 2) for k, v in bio.most_common(4) for v in [v / n]},
              "elevation_m": [round(float(elev[ys, xs].min())), round(float(elev[ys, xs].max()))],
              "river": p["river_tiles"] > 0, "coast": p["coast"],
              "existing_places": [{"id": q, "name": places_by[q]["name"], "kind": places_by[q]["kind"]} for q in p["places"]],
              "new_slots": [s["slot"] for s in new]}
        by_region[p["region"]].append(p2)
    # one proposed minor sect per region: the settlement province with the most livable land and no seat
    for r, plist in by_region.items():
        best = None
        for p2 in plist:
            if p2["kind"] != "settlement" or any(e["kind"] in ("minor_seat", "great_seat") for e in p2["existing_places"]):
                continue
            liv = sum(v for k, v in p2["land"].items() if k in LIVABLE)
            score = liv + (0.3 if p2["river"] else 0) + 0.002 * p2["tiles"]
            if best is None or score > best[0]:
                best = (score, p2)
        if best:
            p2 = best[1]
            m = pid == p2["id"]
            t = pick(m & np.isin(main_b, [k for k, v in names.items() if v in LIVABLE]), np.where(m, slope * 0.5, 0) + 0.01 * np.where(m, 1, 0))
            if t:
                taken.append(t)
                x, y = t
                s = {"slot": "%s_minor_seat_p" % p2["key"], "province": p2["key"], "kind": "minor_seat", "proposal": True,
                     "tile": [x, y], "biome": names[int(main_b[y, x])], "elevation_km": round(float(elev[y, x]) / 1000.0, 2),
                     "river": bool(river[y, x]), "coast": bool(near_sea[y, x]), "lake_shore": bool(near_lake[y, x])}
                slots.append(s)
                p2["new_slots"].append(s["slot"])
    # the authored isles stay unsettled (their lore says so: "no settlement ever stood on the isle"): a new village or
    # town on the landmass of an existing island place is dropped. Applied after the picks, so no other slot moves.
    fw = np.asarray(Image.open(os.path.join(ROOT, "design/map/continent-11/base/fine_water.png")))
    island_px = set()
    for q in cont["places"]:
        if q["kind"] == "island":
            island_px |= _landmass(fw, q["tile"])
    on_isle = [s for s in slots if s["kind"] in SETTLED and (s["tile"][1] * 4 + 2, s["tile"][0] * 4 + 2) in island_px]
    dropped = set()
    others = [tuple(s["tile"]) for s in slots if s not in on_isle] + [tuple(q["tile"]) for q in cont["places"]]
    key_to_id = {p["key"]: p["id"] for p in provs}
    for s in on_isle:   # move it to the province's own land off the isle, if it has livable land there; else drop it
        m = pid == key_to_id[s["province"]]
        ys, xs = np.nonzero(m & np.isin(main_b, [k for k, v in names.items() if v in LIVABLE]))
        best = None
        for x, y in zip(xs.tolist(), ys.tolist()):
            if (y * 4 + 2, x * 4 + 2) in island_px or not all(max(abs(x - a), abs(y - b)) >= MIN_GAP for a, b in others):
                continue
            sc = near_sea[y, x] * 3.0 + river[y, x] * 2.0 - abs(x - s["tile"][0]) * 0.05 - abs(y - s["tile"][1]) * 0.05
            if best is None or sc > best[0]:
                best = (sc, x, y)
        if best is None:
            dropped.add(s["slot"])
        else:
            s["tile"] = [best[1], best[2]]
            s["biome"] = names[int(main_b[best[2], best[1]])]
            s["elevation_km"] = round(float(elev[best[2], best[1]]) / 1000.0, 2)
            s["coast"] = bool(near_sea[best[2], best[1]])
            s["river"] = bool(river[best[2], best[1]])
            others.append((best[1], best[2]))
            print("moved off an authored isle:", s["slot"], s["tile"])
    slots = [s for s in slots if s["slot"] not in dropped]
    for plist in by_region.values():
        for p2 in plist:
            p2["new_slots"] = [k for k in p2["new_slots"] if k not in dropped]
            if p2["kind"] == "settlement" and p2["seat"] is None and not any(
                    k for k in p2["new_slots"] if k.split("_")[-2] in ("village", "town")):
                p2["kind"] = "wilderness"
    if dropped:
        print("dropped (on an authored isle):", ", ".join(sorted(dropped)))
    os.makedirs(os.path.join(OUT, "briefs"), exist_ok=True)
    json.dump({"_doc": "New place slots per province (tools/design/map/places_v2.py); names and lore in region_<r>.json.",
               "slots": slots}, open(os.path.join(OUT, "slots.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    slot_by = {s["slot"]: s for s in slots}
    for r, plist in by_region.items():
        json.dump({"region": r, "region_name": region_name.get(r, ""), "provinces": plist,
                   "slots": [slot_by[k] for p2 in plist for k in p2["new_slots"]]},
                  open(os.path.join(OUT, "briefs", "region_%d.json" % r), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    c = Counter(s["kind"] for s in slots)
    print("slots %d: %s" % (len(slots), ", ".join("%s %d" % kv for kv in c.most_common())))
    print("provinces %d, settlement %d after the new villages" % (len(provs), sum(1 for pl in by_region.values() for p2 in pl if p2["kind"] == "settlement")))


if __name__ == "__main__":
    main()
