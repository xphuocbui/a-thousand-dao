"""Input slices for the world-depth pass (design/world/depth/README.md).

Writes design/world/depth/_inputs/<sect>.json (one per sect: the sect's record and start state, its lord and vassals,
its ground's places with land qi, the history events that name it or happen on its ground, territory history lines,
its existing cast with builds and traits, the legendary items it made or holds, its seat-audit lines) and
_inputs/world.json (eras, every sect in one line, wars, grudges, vassal changes, the loose cast). Slices only: no
judgement, no edits to the sources.

Run: python -I tools/design/world/depth_inputs.py
"""
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parents[3]
OUT = ROOT / "design/world/depth/_inputs"


def load(p):
    return json.loads((ROOT / p).read_text(encoding="utf-8"))


def mentions(obj, key, name):
    s = json.dumps(obj, ensure_ascii=False)
    return ('"%s"' % key) in s or (name and name in s)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    w = load("assets/data/world_continent.json")
    h = load("assets/data/world_history.json")
    audit = (ROOT / "design/world/depth/seat-audit.md").read_text(encoding="utf-8")
    places = {p["id"]: p for p in w["places"]}
    hist_sects = {s["key"]: s for s in h["sects"]}
    builds = h.get("cast_builds", {})
    all_sects = w["great_sects"] + w["minor_sects"]
    terr = h["territory"]

    def place_line(p):
        q = p["qi"]
        return {"id": p["id"], "name": p["name"], "gloss": p.get("gloss", ""), "kind": p["kind"], "region": p["region"],
                "biome": p["biome"], "elev_km": p["elevation_km"],
                "qi": {k: round(v) for k, v in q["shares"].items()},
                "variants": {k: round(v, 1) for k, v in q.get("variants", {}).items() if v >= 1},
                "density": round(p["density"], 2), "note": p.get("note", "")}

    def person(p):
        r = dict(p)
        if p["key"] in builds:
            r["build"] = builds[p["key"]]
        return r

    world = {
        "_doc": "World context for every depth writer. start_year = the game's first year.",
        "start_year": h["start_year"],
        "eras": terr["eras"],
        "sects": [{"key": s["key"], "name": s["name"], "name_han": s.get("name_han", ""), "gloss": s.get("gloss", ""),
                   "kind": "great" if s in w["great_sects"] else "minor", "lord": s.get("lord", ""),
                   "leans": s["leans"], "seat": places[s["seat"]]["name"],
                   "alignment": hist_sects.get(s["key"], {}).get("alignment", ""),
                   "specialty": hist_sects.get(s["key"], {}).get("specialty", ""),
                   "founded": hist_sects.get(s["key"], {}).get("founded", "")} for s in all_sects],
        "fallen_sects": h["fallen_sects"],
        "wars": terr["wars"], "grudges": terr["grudges"], "vassal_lord_changes": terr["vassal_lord_changes"],
        "loose_cast": [{k: v for k, v in person(p).items() if k != "build"} for p in h["people"] if not p.get("sect")],
        "regions": [{"id": r["id"], "name": r["name"], "gloss": r.get("gloss", ""), "holder": r.get("holder", ""),
                     "biomes": [(b["biome"], b.get("share")) for b in r["biomes"][:4]]} for r in w["regions"]],
    }
    (OUT / "world.json").write_text(json.dumps(world, ensure_ascii=False, indent=0), encoding="utf-8")

    for s in all_sects:
        key, great = s["key"], s in w["great_sects"]
        seat = places[s["seat"]]
        if great:
            ground = [p for p in w["places"] if p.get("territory") == key]
        else:
            ground = [p for p in w["places"] if p.get("territory") == s.get("lord") and p["region"] == seat["region"]]
        ground_ids = {p["id"] for p in ground}
        events = [{k: v for k, v in e.items() if k != "text_vi"} for e in h["events"] if key in e.get("sects", []) or e.get("place") in ground_ids
                  or mentions(e.get("text_en", ""), key, s["name"])]
        tlines = {k: [x for x in terr[k] if mentions(x, key, s["name"])] for k in
                  ["land_changes", "wars", "vassal_lord_changes", "grudges", "other_events"]}
        cast = [person(p) for p in h["people"] if p.get("sect") == key]
        items = [i for i in h["legendary_items"] if i.get("made_by") == key or
                 any(i.get("holder") == p["key"] for p in cast)]
        sec = audit.split("\n## ")
        aud = next(("## " + x for x in sec if "(%s;" % key in x.split("\n")[0]), "")
        vassals = [v["key"] for v in w["minor_sects"] if v.get("lord") == key]
        rec = {
            "_doc": "Input slice for the depth writer of %s (tools/design/world/depth_inputs.py). Read world.json too." % key,
            "sect": dict(s, kind="great" if great else "minor"),
            "start_state": hist_sects.get(key, {}),
            "lord": s.get("lord", ""), "vassals": vassals,
            "seat": place_line(seat),
            "seat_audit": aud,
            "ground": [place_line(p) for p in sorted(ground, key=lambda p: (-p["density"]))][:50],
            "ground_place_count": len(ground),
            "events": events, "territory": tlines,
            "cast": cast, "legendary_items": items,
        }
        (OUT / ("%s.json" % key)).write_text(json.dumps(rec, ensure_ascii=False, indent=0), encoding="utf-8")
    print("wrote %d sect slices + world.json" % len(all_sects))


if __name__ == "__main__":
    main()
