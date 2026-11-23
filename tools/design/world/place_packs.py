"""Input packs for the place catalogue (production/plans/overnight-2026-11-22.md, step 2): one JSON per group of regions
with every place's recorded facts (kind, land, name and its allusion, the events that mention it, the sect that holds
or is seated there, the people whose home it is), so the writers author looks and lore from the record only.

usage: python -I tools/design/world/place_packs.py <out dir> [regions per pack, default 4]
Reads assets/data/world_continent.json, assets/data/world_history.json, design/map/continent-11/*.json.
"""
import collections
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))


def load(rel):
    with open(os.path.join(ROOT, rel), encoding="utf-8") as f:
        return json.load(f)


def main():
    out = sys.argv[1]
    per = int(sys.argv[2]) if len(sys.argv) > 2 else 4
    os.makedirs(out, exist_ok=True)
    c = load("assets/data/world_continent.json")
    h = load("assets/data/world_history.json")
    rn = load("design/map/continent-11/region_names.json")["regions"]
    minor = {m["key"]: m for m in load("design/map/continent-11/minor_sects_proposal.json")["minor_sects"]}
    sects = {s["key"]: s for s in h["sects"]}
    great = {s["key"]: s for s in c["great_sects"]}
    names = {**{k: v for k, v in great.items()}, **{s["key"]: s for s in c.get("minor_sects", [])}}
    by_place = collections.defaultdict(list)
    for e in h["events"]:
        if e.get("place") is not None:
            by_place[e["place"]].append({"year": e.get("year"), "kind": e.get("kind"), "tier": e.get("tier"),
                                         "text": e.get("text_en", ""), "secret": bool(e.get("secret", False))})
    homes = collections.defaultdict(list)
    for p in h["people"]:
        if p.get("home") is not None:
            homes[p["home"]].append({"name": p.get("name"), "role": p.get("role", ""), "alive": p.get("alive", True),
                                     "realm": p.get("realm", p.get("peak_realm", "")), "sect": p.get("sect", "")})
    seat_of = {s["seat"]: s for s in h["sects"] if s.get("seat") is not None}
    famous = collections.defaultdict(list)
    for fs in h["famous_sites"]:
        famous[int(fs.get("region", -1))].append({k: fs.get(k) for k in ("name", "name_han", "gloss", "kind", "tile", "note")})
    fallen = collections.defaultdict(list)
    for fsct in h["fallen_sects"]:
        for r in fsct.get("land", []) or []:
            fallen[int(r)].append({k: fsct.get(k) for k in ("name", "name_han", "gloss", "founded", "fell", "cause", "ruin")})

    def sect_line(key):
        s = sects.get(key, {})
        g = names.get(key, {})
        if not s and not g:
            return None
        line = {"key": key, "name": s.get("name", g.get("name")), "gloss": s.get("gloss", g.get("gloss")),
                "kind": s.get("kind"), "alignment": s.get("alignment"), "leans": s.get("leans", g.get("leans")),
                "specialty": s.get("specialty"), "founded": s.get("founded"), "lord": s.get("lord")}
        if key in minor:
            line.update({"craft": minor[key].get("craft"), "note": minor[key].get("note")})
        return line

    regions = sorted(c["regions"], key=lambda r: r["id"])
    places = collections.defaultdict(list)
    for p in c["places"]:
        qi = p.get("qi", {}).get("shares", {})
        top = sorted(qi.items(), key=lambda kv: -kv[1])[:2]
        rec = {k: p.get(k) for k in ("id", "name", "name_han", "gloss", "note", "kind", "biome", "elevation_km", "coast",
                                      "river", "port", "holder", "founded", "on_road", "array", "danger")}
        rec["qi_top"] = [k for k, _ in top]
        rec["events"] = sorted(by_place.get(p["id"], []), key=lambda e: (e["year"] or 0))
        rec["residents"] = homes.get(p["id"], [])
        if p["id"] in seat_of:
            rec["seat_of"] = sect_line(seat_of[p["id"]]["key"])
            lead = seat_of[p["id"]].get("leader")
            rec["seat_of"]["leader"] = next((x.get("name") for x in h["people"] if x.get("key") == lead), lead)
        places[p["region"]].append(rec)
    packs = [regions[i:i + per] for i in range(0, len(regions), per)]
    index = []
    for n, group in enumerate(packs, 1):
        pack = {"regions": []}
        for r in group:
            meta = rn.get(str(r["id"]), {})
            pack["regions"].append({
                "id": r["id"], "name": r["name"], "name_han": r.get("name_han"), "gloss": r.get("gloss"),
                "image": meta.get("note"), "holder": sect_line(r.get("holder")) if r.get("holder") else None,
                "biomes": r.get("biomes", [])[:4], "landmass": r.get("landmass"),
                "neighbours": [next((x["name"] for x in regions if x["id"] == nb["region"]), nb["region"])
                               for nb in r.get("neighbours", [])],
                "famous_sites": famous.get(r["id"], []), "fallen_sects": fallen.get(r["id"], []),
                "places": sorted(places.get(r["id"], []), key=lambda p: p["id"])})
        path = os.path.join(out, "pack_%02d.json" % n)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(pack, f, ensure_ascii=False, indent=1)
        count = sum(len(r["places"]) for r in pack["regions"])
        index.append({"pack": n, "regions": [r["id"] for r in group], "places": count, "file": path})
        print("pack %02d regions %s places %d" % (n, [r["id"] for r in group], count))
    world = {"start_year": h["start_year"], "calendar": "Thiên Nguyên lịch (years since the first recorded opening of Phù Tang Cảnh)",
             "great_sects": [sect_line(k) for k in great], "territory_eras": h["territory"].get("eras", []),
             "landmarks": [{"year": e["year"], "text": e.get("text_en", "")} for e in h["events"] if e.get("tier") == "landmark"]}
    with open(os.path.join(out, "world_brief.json"), "w", encoding="utf-8") as f:
        json.dump(world, f, ensure_ascii=False, indent=1)
    with open(os.path.join(out, "index.json"), "w", encoding="utf-8") as f:
        json.dump(index, f, indent=1)


if __name__ == "__main__":
    main()
