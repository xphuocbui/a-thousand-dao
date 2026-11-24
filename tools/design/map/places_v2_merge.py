"""Merge the provinces-v2 places into the authored continent (user decisions 2026-11-24, production/plans/
provinces-v2-proposal.md decisions 1, 3, 4 and follow-ups).

Reads the slots (design/world/provinces-v2/slots.json), the briefs (province keys and regions), the written lore
(design/world/provinces-v2/lore/region_<r>.json), the current world (assets/data/world_continent.json) and the map's
livability (places.py's Map), and writes one layer for export_continent.py:
design/map/continent-11/provinces_v2_places.json.

- **Kept sites (decision 1):** one province in four keeps one economic site (a place of map_resources.json's site
  kinds), chosen deterministically (a hash of the province key), spread over the regions (each region keeps about a
  quarter of its provinces that have a site), and inside a province the site of the kind its region has kept least.
  A kept site carries site_grade "minor" (a tenth of small); every other new site carries no_site true: a place with
  lore and no production. The list is written to design/world/provinces-v2/kept_sites.json.
- **Holders:** new settlements, mines and special sites take the holder of the nearest existing held settlement in
  their region (the local lord), and the region's great sect as territory; peaks, forests, lakes, gorges and beast
  lairs are unheld, as the existing ones are; a proposed minor sect holds its own seat.
- **Roads (follow-up):** only new settlements are marked v2_road true; export_continent.py routes only them among the
  new places.
- **Sects (decision 4):** each proposed minor sect's block becomes a minor sect record (seat = its new place).
- Ruins keep former and lived; every place keeps its slot key (v2_slot) and province key (province).

Ids are not given here: the exporter numbers the layer after every earlier place, in this file's order (sorted by
slot key), so the 254 existing ids never move.

usage: python -I tools/design/map/places_v2_merge.py
"""
import glob
import hashlib
import json
import math
import os
import re
import sys
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import places as PL  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
BASE = os.path.join(ROOT, "design/world/provinces-v2")
MAP = os.path.join(ROOT, "design/map/continent-11")
OUT = os.path.join(MAP, "provinces_v2_places.json")
KEPT = os.path.join(BASE, "kept_sites.json")
KEEP_SHARE = 0.25              # decision 1: one province in four keeps a site
SITE_GRADE = "minor"           # decision 1: a tenth of small (map_resources.json site_grade_value.minor)
SETTLEMENTS = ("village", "town")
UNHELD = ("peak", "forest", "lake", "gorge", "beast_lair", "volcano")
# lore words that have a site worked (miners, bathers, traders...): such sites are kept first; places_v2_fit.py lists
# the unkept ones that still use them, for the writers to re-fit
WORKED = (r"\b(miners?|mining|dig(s|ging)?|dug|worked|works?|tapped|taps?|smelt\w*|quarr\w+|harvest\w*|hunters? "
          r"(take|sell)|sold|sells?|trade[sd]?|carts?|carry|carried|shafts?|bathers?|bathhouse|pilgrims)\b")
HELD_SETTLED = ("great_seat", "minor_seat", "city", "market", "town", "village")


def h(s):
    return int(hashlib.sha1(s.encode("utf-8")).hexdigest()[:12], 16)


def main():
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    site_kinds = set(json.load(open(os.path.join(ROOT, "assets/data/map_resources.json"), encoding="utf-8"))["site_kinds"])
    slots = sorted(json.load(open(os.path.join(BASE, "slots.json"), encoding="utf-8"))["slots"], key=lambda s: s["slot"])
    prov_region = {}
    for f in glob.glob(os.path.join(BASE, "briefs", "region_*.json")):
        b = json.load(open(f, encoding="utf-8"))
        for p in b["provinces"]:
            prov_region[p["key"]] = int(b["region"])
    lore = {}
    for f in glob.glob(os.path.join(BASE, "lore", "region_*.json")):
        lore.update(json.load(open(f, encoding="utf-8")).get("places", {}))
    region_holder = {r["id"]: r["holder"] for r in cont["regions"]}
    great_of_region = {r: g["key"] for g in cont["great_sects"] for r in g["regions"]}
    held = [p for p in cont["places"] if p["kind"] in HELD_SETTLED and p.get("holder")]
    M = PL.Map(MAP)

    def worked(s):
        e = lore.get(s["slot"], {})
        return re.search(WORKED, (e.get("look", "") + " " + e.get("lore", "")).lower()) is not None

    # decision 1: the kept sites
    by_prov = defaultdict(list)
    for s in slots:
        if s["kind"] in site_kinds:
            by_prov[s["province"]].append(s)
    provs_by_region = defaultdict(list)
    for pk in prov_region:
        provs_by_region[prov_region[pk]].append(pk)
    kept = {}
    for r in sorted(provs_by_region):
        want = int(round(len(provs_by_region[r]) * KEEP_SHARE))
        # provinces whose site lore already has it worked go first, so the lore and the output agree
        cands = sorted((pk for pk in provs_by_region[r] if by_prov.get(pk)),
                       key=lambda pk: (not any(worked(s) for s in by_prov[pk]), h("keep:" + pk)))
        kinds_kept = Counter()
        for pk in cands[:want]:
            pick = sorted(by_prov[pk], key=lambda s: (not worked(s), kinds_kept[s["kind"]], h("site:" + s["slot"])))[0]
            kinds_kept[pick["kind"]] += 1
            kept[pick["slot"]] = {"province": pk, "region": r, "kind": pick["kind"]}

    out, sects, missing = [], [], []
    for s in slots:
        e = lore.get(s["slot"])
        if not e:
            missing.append(s["slot"])
            continue
        x, y = s["tile"]
        i = M.idx(x, y)
        r = int(M.rid[i]) or prov_region[s["province"]]   # the tile's own region (a province edge may cross a region line)
        q = {"v2_slot": s["slot"], "province": s["province"], "kind": s["kind"], "tile": [x, y], "region": r,
             "biome": s["biome"].replace("_", " "), "elevation_km": s["elevation_km"],
             "river": bool(s.get("river")), "coast": bool(s.get("coast")),
             "livability": round(M.live[i], 2) if s["kind"] in SETTLEMENTS + ("minor_seat",) else 0.0,
             "name_hv": e["name"], "name_han": e.get("name_han", ""), "gloss": e.get("gloss", ""),
             "territory": great_of_region.get(r, region_holder.get(r, "")),
             "v2_road": s["kind"] in SETTLEMENTS + ("minor_seat",)}
        if s["kind"] in UNHELD:
            q["holder"] = ""
        elif s["kind"] == "minor_seat":
            sb = e["sect"]
            q["holder"] = sb["key"]
            q["key"] = sb["key"]
            sects.append({k: sb[k] for k in ("key", "alignment", "leans", "craft", "lord", "founded") if k in sb}
                         | {"name_hv": sb.get("name", e["name"]), "name_han": sb.get("name_han", e.get("name_han", "")),
                            "gloss": sb.get("gloss", e.get("gloss", "")), "region": r, "v2_slot": s["slot"]})
        else:
            near = [p for p in held if p["region"] == r]
            near = min(near, key=lambda p: math.dist(p["tile"], (x, y))) if near else None
            q["holder"] = near["holder"] if near else region_holder.get(r, "")
        if s["kind"] == "ruin":
            q["former"], q["lived"] = e["former"], list(e["lived"])
        if s["kind"] in site_kinds:
            if s["slot"] in kept:
                q["site_grade"] = SITE_GRADE
            else:
                q["no_site"] = True   # no resource site and no herb site (decision 1: produces nothing yet)
        elif s["kind"] not in SETTLEMENTS + ("minor_seat",):
            q["site_grade"] = SITE_GRADE   # a peak, forest, lake, gorge or ruin: its herb site (if any) starts minor too
        out.append(q)
    if missing:
        raise SystemExit("slots with no lore: %s" % missing[:10])
    doc = {"_doc": "The provinces-v2 places (tools/design/map/places_v2_merge.py; user decisions 2026-11-24). "
                   "export_continent.py appends them after every earlier layer, in this order.",
           "places": out, "minor_sects": sects}
    with open(OUT, "w", encoding="utf-8") as fh:
        json.dump(doc, fh, ensure_ascii=False, indent=1)
    with open(KEPT, "w", encoding="utf-8") as fh:
        json.dump({"_doc": "Decision 1 (user 2026-11-24): the new economic sites kept, one province in four, at site "
                           "grade minor; every other new site has no production (places_v2_merge.py).",
                   "kept": kept}, fh, ensure_ascii=False, indent=1)
    n_sites = sum(1 for q in out if q["kind"] in site_kinds)
    print("places %d, sects %d; sites %d, kept %d (%s)" % (len(out), len(sects), n_sites, len(kept),
          dict(Counter(v["kind"] for v in kept.values()))))
    print("kept per region:", dict(sorted(Counter(v["region"] for v in kept.values()).items())))


if __name__ == "__main__":
    main()
