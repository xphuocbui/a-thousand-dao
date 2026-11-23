"""Does the written lore fit the land (user, 2026-11-23 night: "please make sure that the place fits the province,
place, sects, country, lore")? Keyword observations, never a verdict: each line is a place or province whose words
seem to contradict its own tile or province, for a person (or a writer) to look at.

- water work (fishing, boats, nets, harbours, tides) at a place with no coast, river or lake shore;
- snow and ice words in jungle, desert, badlands or mangrove below 1.5 km;
- jungle and palm words on tundra or glacier;
- a wilderness province whose lore has people living there; a settlement province whose lore says no one lives there.

usage: python -I tools/design/map/places_v2_fit.py   -> prints the lines and a count by kind
"""
import glob
import json
import os
import re
from collections import Counter

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
BASE = os.path.join(ROOT, "design/world/provinces-v2")
WATER = r"\b(fish(?:ing|ers?|es)?|boats?|nets?|harbou?r|ferr(?:y|ies|ymen)|tides?|oars?|nets|sails?|quay|wharf)\b"
COLD = r"\b(snow|ice|icy|frozen|frost|glacier|sleet)\b"
HOT_BIOMES = {"jungle", "desert", "badlands", "mangrove"}
JUNGLE = r"\b(jungle|palms?|monsoon|mangroves?|parrots?)\b"
COLD_BIOMES = {"tundra", "glacier"}
PEOPLE = r"\b(villagers|its people|the people here|farmers? (?:here|live)|families live|houses stand|people live)\b"
NOBODY = r"\b(no one lives|nobody lives|uninhabited|no village|empty of people)\b"


def main():
    slots = {s["slot"]: s for s in json.load(open(os.path.join(BASE, "slots.json"), encoding="utf-8"))["slots"]}
    prov_kind = {}
    for f in glob.glob(os.path.join(BASE, "briefs", "region_*.json")):
        for p in json.load(open(f, encoding="utf-8"))["provinces"]:
            prov_kind[p["key"]] = p["kind"]
    out = []
    kinds = Counter()
    for f in sorted(glob.glob(os.path.join(BASE, "lore", "region_*.json"))):
        d = json.load(open(f, encoding="utf-8"))
        for k, e in d.get("places", {}).items():
            s = slots.get(k)
            if not s:
                continue
            txt = (str(e.get("look", "")) + " " + str(e.get("lore", ""))).lower()
            wet = s.get("coast") or s.get("river") or s.get("lake_shore")
            if s["kind"] in ("village", "town") and not wet and re.search(WATER, txt):
                out.append("water work away from water: %s %s (%s)" % (k, e.get("name"), re.search(WATER, txt).group(0)))
                kinds["water"] += 1
            if s["biome"] in HOT_BIOMES and float(s.get("elevation_km", 0)) < 1.5 and re.search(COLD, txt):
                out.append("cold in a hot land: %s %s on %s (%s)" % (k, e.get("name"), s["biome"], re.search(COLD, txt).group(0)))
                kinds["cold"] += 1
            if s["biome"] in COLD_BIOMES and re.search(JUNGLE, txt):
                out.append("jungle on %s: %s %s (%s)" % (s["biome"], k, e.get("name"), re.search(JUNGLE, txt).group(0)))
                kinds["jungle"] += 1
        for k, e in d.get("provinces", {}).items():
            txt = str(e.get("lore", "")).lower()
            if prov_kind.get(k) == "wilderness" and re.search(PEOPLE, txt):
                out.append("people in a wilderness province: %s %s (%s)" % (k, e.get("name"), re.search(PEOPLE, txt).group(0)))
                kinds["people"] += 1
            if prov_kind.get(k) == "settlement" and re.search(NOBODY, txt):
                out.append("nobody in a settlement province: %s %s (%s)" % (k, e.get("name"), re.search(NOBODY, txt).group(0)))
                kinds["nobody"] += 1
    print("\n".join(out))
    print("observations: %s" % (", ".join("%s %d" % kv for kv in kinds.most_common()) or "none"))


if __name__ == "__main__":
    main()
