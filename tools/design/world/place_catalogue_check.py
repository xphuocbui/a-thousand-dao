"""Merge and check the place catalogue (design/world/place_catalogue/README.md): reads pack_NN.json, prints
observations (a helper emits observations, never verdicts) and writes the merged design/world/place_catalogue.json.

usage: python -I tools/design/world/place_catalogue_check.py
Observations: packs that do not parse; place ids missing, duplicated or unknown; names that differ from the record;
special places without a history and specials the README's rule would expect; settlements and seats without levels;
four-digit years in the text that the place's record does not hold; empty fields; very short or long entries.
"""
import glob
import json
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))))
CAT = os.path.join(ROOT, "design/world/place_catalogue")
SPECIAL_KINDS = {"great_seat", "minor_seat", "city", "ruin", "spirit_vein", "peak", "volcano", "lake", "island", "gorge",
                 "forest", "lightning_wood"}
LEVEL_KINDS = {"village", "town", "city", "market", "great_seat", "minor_seat"}


def main():
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    hist = json.load(open(os.path.join(ROOT, "assets/data/world_history.json"), encoding="utf-8"))
    places = {p["id"]: p for p in cont["places"]}
    # a place's recorded years: its own events, its seated sect's events and founding, its residents' events and
    # births and deaths, and the region's fallen sects' founding and fall
    seat_of = {s["seat"]: s for s in hist["sects"] if s.get("seat") is not None}
    # a sect hall (an old seat after a world-depth move, 2026-11-26) shares its sect's record
    by_key = {s["key"]: s for s in hist["sects"]}
    for pl in cont["places"]:
        if pl.get("hall_of") in by_key:
            seat_of.setdefault(pl["id"], by_key[pl["hall_of"]])
    home = {}
    for person in hist["people"]:
        if person.get("home") is not None:
            home.setdefault(person["home"], set()).add(person.get("key"))
    years = {}
    for pid, pl in places.items():
        ys = set()
        sect = seat_of.get(pid, {}).get("key")
        if sect:
            ys.add(int(seat_of[pid].get("founded") or 0))
        folk = home.get(pid, set())
        for e in hist["events"]:
            if e.get("place") == pid or (sect and sect in (e.get("sects") or [])) or folk & set(e.get("people") or []):
                ys.add(int(e.get("year") or 0))
        for person in hist["people"]:
            if person.get("key") in folk:
                for k in ("born", "died"):
                    if person.get(k) is not None:
                        ys.add(int(person[k]))
        for fs in hist["fallen_sects"]:
            if pl.get("region") in (fs.get("land") or []):
                ys.update(int(fs.get(k) or 0) for k in ("founded", "fell"))
        years[pid] = ys
    famous_tiles = {tuple(f["tile"]) for f in hist["famous_sites"] if f.get("tile")}
    entries, notes = {}, []
    for path in sorted(glob.glob(os.path.join(CAT, "pack_*.json"))):
        try:
            data = json.load(open(path, encoding="utf-8"))
        except Exception as ex:   # noqa: BLE001 - report any parse failure by file
            notes.append("%s: does not parse (%s)" % (os.path.basename(path), ex))
            continue
        for e in data.get("places", []):
            pid = e.get("id")
            if pid in entries:
                notes.append("id %s: duplicated (%s)" % (pid, os.path.basename(path)))
            entries[pid] = e
    missing = sorted(set(places) - set(entries))
    unknown = sorted(set(entries) - set(places))
    if missing:
        notes.append("missing ids (%d): %s" % (len(missing), missing))
    if unknown:
        notes.append("unknown ids: %s" % unknown)
    for pid, e in sorted(entries.items(), key=lambda kv: kv[0]):
        p = places.get(pid)
        if p is None:
            continue
        if e.get("name") != p.get("name"):
            notes.append("id %d: name %r, record %r" % (pid, e.get("name"), p.get("name")))
        for field in ("look", "lore", "art_brief"):
            if not str(e.get(field, "")).strip():
                notes.append("id %d %s: empty %s" % (pid, p["name"], field))
        expect_special = (p["kind"] in SPECIAL_KINDS or tuple(p.get("tile", [])) in famous_tiles
                          or len(years.get(pid, ())) >= 3)
        if e.get("special") and not str(e.get("history", "")).strip():
            notes.append("id %d %s: special without a history" % (pid, p["name"]))
        if expect_special and not e.get("special"):
            notes.append("id %d %s (%s): the rule expects special" % (pid, p["name"], p["kind"]))
        if p["kind"] in LEVEL_KINDS and len(e.get("levels", []) or []) < 2:
            notes.append("id %d %s (%s): fewer than 2 levels" % (pid, p["name"], p["kind"]))
        text = " ".join(str(e.get(k, "")) for k in ("look", "lore", "history"))
        allowed = years.get(pid, set()) | {int(p.get("founded") or -1), hist.get("start_year", 1200)}
        for y in re.findall(r"\b(1?\d{3})\b", text):
            yv = int(y)
            if 100 <= yv <= 1300 and yv not in allowed:
                notes.append("id %d %s: year %d is not in its record" % (pid, p["name"], yv))
        words = len(text.split())
        if words < 40 or words > 420:
            notes.append("id %d %s: %d words" % (pid, p["name"], words))
    merged = {"status": "proposal (2026-11-22 overnight); for the user's review",
              "note": "Merged from design/world/place_catalogue/pack_*.json by tools/design/world/place_catalogue_check.py",
              "places": [entries[k] for k in sorted(entries)]}
    with open(os.path.join(ROOT, "design/world/place_catalogue.json"), "w", encoding="utf-8") as f:
        json.dump(merged, f, ensure_ascii=False, indent=1)
    specials = sum(1 for e in entries.values() if e.get("special"))
    print("entries %d of %d places; special %d; observations %d" % (len(entries), len(places), specials, len(notes)))
    for n in notes:
        print(" -", n)


if __name__ == "__main__":
    main()
