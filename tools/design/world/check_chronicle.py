"""Check the authored history against itself and the map (World Generation & History Core Rules 3, 4, 5, 15).

Reads design/world (chronicle, annals, cast, records, territory history, legendary items) and design/map/continent-11
(places, sacred features, history sites, the history's places layer). It reports what it finds and never edits a file.

What it checks:
- **Events** (both tiers): unique ids; years 0-1199; every person known (cast or records) and alive at the event;
  every sect known and acting between its founding and its fall (five years of grace for a fall's aftermath); every
  place, famous site, region and hidden slot resolving; a place, region or slot on every event; both text lines
  present; the tier sizes against AC-WG-04 (150-250 landmarks, 300-500 annals).
- **Territory** (AC-WG-37): the land changes replayed per tile from year 0 give exactly the approved year-1,200 map;
  every great and minor seat sits on its own or its lord's land in its founding year; each land change names the
  landmark event that carries it.
- **Hidden spots** (Core Rule 4): no hidden-slot candidate lies within 2 tiles of a named place, deep cave or sacred
  summit, since a codex entry for that place would point at the hidden spot in a game that rolls it.
- **Items**: every held item's holder is a living cast member of Kết Đan or higher (Item Database rule 20d).

Run:  python -I tools/design/world/check_chronicle.py
Exit code 1 when anything is reported.
"""

import json
import math
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "design", "map"))
import places as PL  # noqa: E402

WORLD = os.path.join(ROOT, "design", "world")
MAP = os.path.join(ROOT, "design", "map", "continent-11")


def load(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def main():
    chron = load(os.path.join(WORLD, "chronicle_proposal.json"))["events"]
    annals = load(os.path.join(WORLD, "annals_proposal.json"))["events"]
    cast = load(os.path.join(WORLD, "cast_proposal.json"))
    records = load(os.path.join(WORLD, "records_proposal.json"))["records"]
    terr = load(os.path.join(WORLD, "territory_history_proposal.json"))
    items = load(os.path.join(WORLD, "legendary_items_proposal.json"))["items"]
    places = load(os.path.join(MAP, "places.json"))["places"]
    sac = load(os.path.join(MAP, "sacred.json"))
    hist = load(os.path.join(MAP, "history.json"))
    hp = load(os.path.join(MAP, "history_places.json"))
    regions = load(os.path.join(MAP, "regions.json"))["regions"]
    found = []

    # ---- events
    people = {p["key"]: (p["born"], p.get("died")) for p in cast["people"]}
    for r in records:
        people[r["key"]] = (r["born"], r.get("died"))
    sects = {k: (y, None) for k, y in cast["great_sect_founding_years"].items()}
    sects.update({k: (y, None) for k, y in cast["minor_sect_founding_years"].items()})
    for v in cast["vanished_sects"]:
        sects[v["key"]] = (v["founded"], v["fell"])
    for f in terr["fallen_sects"]:
        sects[f["key"]] = (f["founded"], f["fell"])
    names = {q.get("name_hv") for q in places} | {q.get("name_hv") for q in sac["places"]}
    names |= {sac["miasma_wasteland"]["name_hv"], sac["miasma_source"]["name_hv"]}
    names |= {c.get("name_hv") for c in sac.get("deep_caves", [])}
    names |= {c.get("name_hv") or c.get("peak") for c in sac.get("sacred_summits", [])}
    for arr in hist["famous"].values():
        names |= {f["name_hv"] for f in arr}
    names |= {p["name_hv"] for p in hp["promotions"]} | {r["name_hv"] for r in hp["ruins"]}
    region_names = {r["name_hv"] for r in regions}
    slots = {s["slot"] for s in hist["hidden"]}
    ids = [e["id"] for e in chron + annals]
    if len(ids) != len(set(ids)):
        found.append("duplicate event ids")
    if not 150 <= len(chron) <= 250:
        found.append("landmark chronicle holds %d events (AC-WG-04: 150-250)" % len(chron))
    if not 300 <= len(annals) <= 500:
        found.append("annals hold %d events (AC-WG-04: 300-500)" % len(annals))
    for e in chron + annals:
        y = e["year"]
        if not 0 <= y <= 1199:
            found.append("%s: year %d is outside 0-1199" % (e["id"], y))
        for p in e.get("people", []):
            if p not in people:
                found.append("%s: unknown person %s" % (e["id"], p))
            elif y < people[p][0] or (people[p][1] is not None and y > people[p][1]):
                found.append("%s: %s is not alive in %d" % (e["id"], p, y))
        for k in e.get("sects", []):
            if k not in sects:
                found.append("%s: unknown sect %s" % (e["id"], k))
            elif y < sects[k][0] or (sects[k][1] is not None and y > sects[k][1] + 5):
                found.append("%s: sect %s acts in %d, outside %s-%s" % (e["id"], k, y, sects[k][0], sects[k][1]))
        for key in ("place", "famous_site"):
            if e.get(key) and e[key] not in names:
                found.append("%s: unknown %s %s" % (e["id"], key, e[key]))
        if e.get("region") and e["region"] not in region_names:
            found.append("%s: unknown region %s" % (e["id"], e["region"]))
        if e.get("slot") and e["slot"] not in slots:
            found.append("%s: unknown slot %s" % (e["id"], e["slot"]))
        if not (e.get("place") or e.get("region") or e.get("slot") or e.get("famous_site")):
            found.append("%s: no place, region or slot" % e["id"])
        if not e.get("text") or not e.get("text_vi"):
            found.append("%s: a text line is missing" % e["id"])

    # ---- territory replay (AC-WG-37)
    M = PL.Map(MAP)
    W = M.W
    parts = {}
    for pt in hp["parts"]:
        parts[pt["key"]] = [tuple(t) for t in pt["tile_list"]]
        for k, v in pt.get("pieces", {}).items():
            parts[k] = [tuple(t) for t in v["tile_list"]]
    region_tiles = {}
    for i, r in enumerate(M.rid):
        if r and M.dry[i]:
            region_tiles.setdefault(r, []).append((i % W, i // W))
    changes = sorted(terr["land_changes"], key=lambda c: c["year"])

    def holders_at(year):
        h = {}
        for c in changes:
            if c["year"] > year:
                break
            land = c["land"]
            for t in (parts[land[5:]] if isinstance(land, str) else region_tiles[land]):
                if h.get(t) == c["from"]:
                    h[t] = c["to"]
        return h

    final = holders_at(1200)
    off = sum(1 for i, r in enumerate(M.rid) if r and M.dry[i] and M.terr[i] >= 0
              and final.get((i % W, i // W)) != M.greats[M.terr[i]]["key"])
    if off:
        found.append("the replayed land changes leave %d tiles off the approved year-1,200 map" % off)
    for c in changes:
        if not c.get("chronicle_event"):
            found.append("land change %s in %d names no landmark event" % (c["land"], c["year"]))
    founded = dict(cast["great_sect_founding_years"])
    founded.update(cast["minor_sect_founding_years"])
    lords = {m["key"]: m.get("lord") for m in load(os.path.join(MAP, "minor_sects.json"))["minor_sects"]}
    cache = {}
    for q in places:
        if q["kind"] not in ("great_seat", "minor_seat"):
            continue
        y = founded[q["key"]]
        cache.setdefault(y, holders_at(y))
        want = q["key"] if q["kind"] == "great_seat" else lords.get(q["key"])
        got = cache[y].get(tuple(q["tile"]))
        if got != want:
            found.append("seat %s, founded %d, is on land of %s (wants %s)" % (q["name_hv"], y, got, want))

    # ---- hidden spots near named sites (Core Rule 4)
    named = [(q.get("name_hv"), q["tile"]) for q in places] + [(q.get("name_hv"), q["tile"]) for q in sac["places"]]
    named += [(c.get("name_hv"), c["tile"]) for c in sac.get("deep_caves", [])]
    named += [(c.get("name_hv") or c.get("peak"), c["tile"]) for c in sac.get("sacred_summits", [])]
    named += [(r["name_hv"], r["tile"]) for r in hp["ruins"]]
    for s in hist["hidden"]:
        for c in s["candidates"]:
            t = c.get("tile") or c["centre"]
            for n, nt in named:
                d = math.dist(t, nt)
                if d < 2:
                    found.append("hidden slot %s candidate %s is %.1f tiles from %s" % (s["slot"], t, d, n))

    # ---- items (Item Database rule 20d)
    alive = {p["key"]: p for p in cast["people"] if p["alive"]}
    for it in items:
        if it["status"] == "held":
            p = alive.get(it.get("holder"))
            if not p or p.get("realm") not in ("ket_dan", "nguyen_anh", "hoa_than"):
                found.append("item %s: holder %s is not a living Kết Đan or higher" % (it["key"], it.get("holder")))

    print("%d landmark events, %d annals, %d records, %d land changes, %d items" %
          (len(chron), len(annals), len(records), len(changes), len(items)))
    if found:
        print("Found %d:" % len(found))
        for f in found:
            print("  " + f)
        return 1
    print("Nothing found.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
