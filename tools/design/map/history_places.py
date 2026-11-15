"""Lay the territory history's places on the map: promoted cities, city founding years, the fixed ruins of fallen sects
and ruined cities, and the named parts of regions that changed hands (World Generation & History Core Rule 15; Travel
& Map rule 6, 200-300 places).

Reads places.json, sacred.json, history.json, the hand-edited history_places_proposal.json and the territory history
(design/world/territory_history_proposal.json, for the land check). Runs after places.py, sacred.py and history.py and
never edits their files: like sacred.json, its output is a layer that export_continent.py merges. So re-running an
earlier tool never moves these places, and these places never move the earlier tools' picks.

What it writes, to <map>/history_places.json:
- **promotions**: each listed town becomes a city with its approved name (Thành for Trấn, 城 for 鎮) and a founding year;
- **city_years**: the founding year of every other city;
- **ruins**: each fixed ruin as a full place record of kind `ruin`, with `former` (sect, city, town or fort), `lived`
  [from, to] and the history key that ruined it; its region, territory and terrain are read from its tile;
- **minor_seats**: vassal seats the history adds (Thu Phần Các, 2026-11-15) as full place records of kind
  `minor_seat`, spaced and checked like the ruins;
- **parts**: each named part grown from its anchor place over the listed regions, nearest tiles first, until it holds
  every candidate of `must_include_slot` and reaches its size; `split_by_region` names the pieces across a border.

The check reports problems (a ruin on water, within 5 tiles of a place or 4 of a hidden-slot candidate; a vanished
sect whose ruin-slot candidates lie off the land it or its lord held while it lived, AC-WG-37), the place counts
against rule 6, and the map targets before and after the layer: the share of places at tile density 1.4 or more
(15-21 %) and the mean place density (1.05-1.20), both from sacred.py's tile estimate.

Run:  python -I tools/design/map/history_places.py --map design/map/continent-11
"""

import argparse
import heapq
import json
import math
import os
import sys
from collections import Counter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import places as PL  # noqa: E402
import sacred as SA  # noqa: E402

BIOME_NAME = {v: k.replace("_", " ") for k, v in PL.B.items()}


def load(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def grow(M, anchor, regions, size, must=()):
    """Tiles of `regions` nearest the anchor over dry land, until every `must` tile is in and `size` is reached."""
    W = M.W
    start = anchor[1] * W + anchor[0]
    need = {m[1] * W + m[0] for m in must}
    seen, out, pq = {start}, [], [(0.0, start)]
    while pq and (len(out) < size or need):
        _, i = heapq.heappop(pq)
        if M.rid[i] in regions and M.dry[i]:
            out.append([i % W, i // W])
            need.discard(i)
        for j in M.nb(i):
            if j not in seen and M.dry[j] and M.rid[j] in regions:
                seen.add(j)
                heapq.heappush(pq, (math.dist((j % W, j // W), anchor), j))
    return out, sorted(need)


def tile_density(M, d):
    """sacred.py's per-tile land density estimate, built the way history.py builds it."""
    sprop = load(os.path.join(d, "sacred_proposal.json"))
    places = load(os.path.join(d, "places.json"))["places"]
    roads, _ = PL.pixels(os.path.join(d, "roads.png"))
    roads = [v if v in (1, 2) else 0 for v in roads]
    S = SA.Sacred(M, sprop, places)
    S.lay_veins()
    S.lay_summits()
    S.lay_wasteland(roads)
    S.lay_caves()
    S.derived()
    D, _ = S.check()
    return D


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", default="design/map/continent-11")
    ap.add_argument("--territory", default="design/world/territory_history_proposal.json")
    ap.add_argument("--cast", default="design/world/cast_proposal.json")
    a = ap.parse_args()
    d = a.map
    prop = load(os.path.join(d, "history_places_proposal.json"))
    places = load(os.path.join(d, "places.json"))["places"]
    sac = load(os.path.join(d, "sacred.json"))
    hist = load(os.path.join(d, "history.json"))
    terr_hist = load(a.territory)
    cast = load(a.cast)
    M = PL.Map(d)
    W = M.W
    by_name = {p.get("name_hv"): p for p in places}
    problems = []
    terr_name = lambda i: M.greats[M.terr[i]]["name_hv"] if M.terr[i] >= 0 else None

    promotions = []
    for pr in prop["promote"]:
        p = by_name.get(pr["town"])
        if p is None or p["kind"] != "town":
            problems.append("no town named " + pr["town"])
            continue
        promotions.append({"place_id": p["id"], "from_name": p["name_hv"], "kind": "city", "kind_hv": "thành",
                           "name_hv": p["name_hv"].replace(" Trấn", " Thành"),
                           "name_han": (p.get("name_han") or "").replace("鎮", "城"),
                           "gloss": (p.get("gloss") or "").replace(" Town", " City"),
                           "founded": pr["founded"], "founded_why": pr["why"], "holder": p.get("holder")})
        if p.get("holder") and p.get("holder") != p.get("territory"):
            problems.append(pr["town"] + " is held by the vassal " + p["holder"])
    city_years = []
    for name, cy in prop["city_years"].items():
        p = by_name.get(name)
        if p is None or p["kind"] != "city":
            problems.append("no city named " + name)
            continue
        city_years.append({"place_id": p["id"], "name_hv": name, "founded": cy["founded"], "founded_why": cy["why"]})
    undated = [p["name_hv"] for p in places if p["kind"] == "city" and p["name_hv"] not in prop["city_years"]]
    if undated:
        problems.append("cities with no founding year: " + ", ".join(undated))

    taken = [tuple(p["tile"]) for p in places] + [tuple(p["tile"]) for p in sac["places"]]
    for arr in hist["famous"].values():
        for f in arr:
            taken.append(tuple(f.get("tile") or f["centre"]))
    cands = [tuple(c.get("tile") or c["centre"]) for s in hist["hidden"] for c in s["candidates"]]
    ruins = []
    for r in prop["ruins"]:
        x, y = r["tile"]
        i = y * W + x
        if not M.dry[i]:
            problems.append(r["name_hv"] + " is not on dry land")
        if any(math.dist((x, y), t) < 5 for t in taken):
            problems.append(r["name_hv"] + " is within 5 tiles of another place")
        if any(math.dist((x, y), t) < 4 for t in cands):
            problems.append(r["name_hv"] + " is within 4 tiles of a hidden-slot candidate")
        taken.append((x, y))
        ruins.append({
            "kind": "ruin", "kind_hv": "di tích", "tile": [x, y], "region": M.rid[i],
            "region_name": M.regs[M.rid[i]]["name_hv"], "biome": BIOME_NAME.get(M.b[i], ""),
            "elevation_km": round(M.h[i], 2), "port": False, "river": bool(M.river[i]), "coast": bool(M.coast[i]),
            "livability": round(M.live[i], 2), "territory": terr_name(i), "holder": terr_name(i),
            "name_hv": r["name_hv"], "name_han": r["name_han"], "gloss": r["gloss"], "note": r["note"],
            "former": r["former"], "lived": r["lived"], "history_key": r["key"], "history": r["history"],
            "on_road": False})

    minor_seats = []
    for m in prop.get("minor_seats", []):
        x, y = m["tile"]
        i = y * W + x
        if not M.dry[i]:
            problems.append(m["name_hv"] + " is not on dry land")
        if any(math.dist((x, y), t) < 5 for t in taken):
            problems.append(m["name_hv"] + " is within 5 tiles of another place")
        if any(math.dist((x, y), t) < 4 for t in cands):
            problems.append(m["name_hv"] + " is within 4 tiles of a hidden-slot candidate")
        if terr_name(i) is None or M.greats[M.terr[i]]["key"] != m["lord"]:
            problems.append(m["name_hv"] + " is not on its lord's land")
        taken.append((x, y))
        minor_seats.append({
            "kind": "minor_seat", "kind_hv": "tông môn", "tile": [x, y], "region": M.rid[i],
            "region_name": M.regs[M.rid[i]]["name_hv"], "biome": BIOME_NAME.get(M.b[i], ""),
            "elevation_km": round(M.h[i], 2), "port": False, "river": bool(M.river[i]), "coast": bool(M.coast[i]),
            "livability": round(M.live[i], 2), "territory": terr_name(i), "holder": terr_name(i),
            "key": m["key"], "name_hv": m["name_hv"], "name_han": m["name_han"], "gloss": m["gloss"], "note": m["note"],
            "lord": m["lord"], "alignment": m["alignment"], "leans": m["leans"], "craft": m["craft"],
            "founded": m["founded"], "on_road": False})

    slot_cands = {s["slot"]: [c.get("tile") or c["centre"] for c in s["candidates"]] for s in hist["hidden"]}
    parts = []
    for pt in prop["parts"]:
        anchor = by_name.get(pt["anchor_place"]) or next((r for r in ruins if r["name_hv"] == pt["anchor_place"]), None)
        if anchor is None:
            problems.append("no anchor place " + pt["anchor_place"])
            continue
        must = slot_cands.get(pt.get("must_include_slot"), [])
        tiles, missed = grow(M, anchor["tile"], set(pt["regions"]), pt["tiles"], must)
        if missed:
            problems.append(pt["key"] + " cannot reach %d of its slot candidates" % len(missed))
        rec = {"key": pt["key"], "anchor": pt["anchor_place"], "tiles": len(tiles), "tile_list": tiles}
        if pt.get("split_by_region"):
            rec["pieces"] = {}
            for reg, key in pt["split_by_region"].items():
                sub = [t for t in tiles if M.rid[t[1] * W + t[0]] == int(reg)]
                rec["pieces"][key] = {"region": int(reg), "tiles": len(sub), "tile_list": sub}
        parts.append(rec)
    part_tiles = {pt["key"]: {tuple(t) for t in pt["tile_list"]} for pt in parts}
    for pt in parts:
        for k, v in pt.get("pieces", {}).items():
            part_tiles[k] = {tuple(t) for t in v["tile_list"]}

    # AC-WG-37: a vanished sect's ruin-slot candidates lie on land it, or its lord while it was a vassal, held
    lords = {c["sect"]: (c["to"], c["year"]) for c in terr_hist.get("vassal_lord_changes", []) if c.get("to")}
    held = {}
    for c in terr_hist["land_changes"]:
        if c.get("to"):
            held.setdefault(c["to"], []).append((c["year"], c["land"]))
    for v in cast["vanished_sects"]:
        lands = [ld for y, ld in held.get(v["key"], []) if y <= v["fell"]]
        if v["key"] in lords:
            lord, since = lords[v["key"]]
            lands += [ld for y, ld in held.get(lord, []) if y <= v["fell"]]
        for t in slot_cands.get(v["ruin_slot"], []):
            r = M.rid[t[1] * W + t[0]]
            ok = any((isinstance(ld, int) and ld == r) or
                     (isinstance(ld, str) and tuple(t) in part_tiles.get(ld.replace("part:", ""), set())) for ld in lands)
            if not ok:
                problems.append("%s: ruin-slot candidate %s lies off its land" % (v["name_hv"], t))

    # map targets before and after this layer
    D = tile_density(M, d)
    dens = lambda t: D[t[1] * W + t[0]]
    base = [p["tile"] for p in places] + [p["tile"] for p in sac["places"]]
    after = base + [r["tile"] for r in ruins] + [m["tile"] for m in minor_seats]
    share = lambda ts: round(sum(1 for t in ts if dens(t) >= 1.4) / len(ts), 3)
    mean = lambda ts: round(sum(dens(t) for t in ts) / len(ts), 3)
    kinds = Counter(p["kind"] for p in places)
    for pr in promotions:
        kinds["town"] -= 1
        kinds["city"] += 1
    kinds["ruin"] += len(ruins)
    kinds["minor_seat"] += len(minor_seats)
    check = {
        "kinds_after": dict(sorted(kinds.items())),
        "places_after": len(after), "with_one_spot_per_hidden_slot": len(after) + len(hist["hidden"]),
        "rule_6_range": [200, 300],
        "share_at_1_4": {"before": share(base), "after": share(after), "target": [0.15, 0.21]},
        "mean_density": {"before": mean(base), "after": mean(after), "target": [1.05, 1.20]},
        "ruin_density": sorted(round(dens(r["tile"]), 2) for r in ruins),
        "problems": problems,
    }
    out = {"source": "tools/design/map/history_places.py", "check": check, "promotions": promotions,
           "city_years": city_years, "ruins": ruins, "minor_seats": minor_seats, "parts": parts}
    with open(os.path.join(d, "history_places.json"), "w", encoding="utf-8", newline="\n") as fh:
        json.dump(out, fh, ensure_ascii=False, indent=1)
    print(json.dumps(check, ensure_ascii=False, indent=1))
    for pt in parts:
        print(pt["key"], pt["tiles"], {k: v["tiles"] for k, v in pt.get("pieces", {}).items()})


if __name__ == "__main__":
    main()
