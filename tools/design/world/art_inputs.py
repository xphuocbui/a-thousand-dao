"""Inputs for the authored art prompts (design/world/depth/art/README.md; user 2026-11-25: every portrait and
place prompt is authored). Compiles facts only; the writers author every prompt.

Writes design/world/depth/art/_inputs/:
  places.json   one entry per place to paint: the 254 painted places, every place the depth pages name, every seat
                (old and new). Each has the continent record, the nearest places with distances, the catalogue look and
                lore, the depth pages' lines that name it, the seat it is (sect key, great or minor, size line), and the
                map crop path (crops/in_<id>.png, made here when missing).
  batches.json  the place batches (by region) and the portrait batches (by cast file).

Run: python -I tools/design/world/art_inputs.py
"""
import glob
import json
import math
import os
import re
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
D = os.path.join(ROOT, "design", "world", "depth")
OUT = os.path.join(D, "art", "_inputs")
KM_PER_TILE = 25


def load(p):
    return json.load(open(p, encoding="utf-8"))


def main():
    sys.path.insert(0, os.path.join(ROOT, "tools", "asset-pipeline", "portraits"))
    import importlib.util
    spec = importlib.util.spec_from_file_location("pa", os.path.join(ROOT, "tools/asset-pipeline/portraits/paint_authored.py"))
    pa = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(pa)
    os.makedirs(os.path.join(OUT, "crops"), exist_ok=True)
    w = load(os.path.join(ROOT, "assets/data/world_continent.json"))
    pl = {p["id"]: p for p in w["places"]}
    cat = {e["id"]: e for e in load(os.path.join(ROOT, "design/world/place_catalogue.json"))["places"]}
    painted = {int(m.group(1)) for f in glob.glob(os.path.join(ROOT, "design/map/continent-11/art/places/paint_*.png"))
               for m in [re.search(r"paint_(\d+)\.png$", f)] if m}
    pages = {os.path.basename(f)[:-3]: open(f, encoding="utf-8").read()
             for f in glob.glob(os.path.join(D, "sects", "*.md")) + glob.glob(os.path.join(D, "people", "*.md"))}
    mentions, seats = {}, {}
    for key, text in pages.items():
        for line in text.splitlines():
            for m in re.finditer(r"place (\d+)", line):
                mentions.setdefault(int(m.group(1)), []).append("%s: %s" % (key, line.strip()[:400]))
        m = re.search(r"^\| Seat \|([^\n]*)", text, re.M)
        if m:
            ids = [int(x) for x in re.findall(r"place (\d+)", m.group(1))]
            size = re.search(r"^\| Size \|([^\n]*)", text, re.M)
            kind = re.search(r"^\| Kind \|([^\n]*)", text, re.M)
            moves = "moves" in m.group(1)
            for i, pid in enumerate(ids):
                role = "seat" if (not moves or i == len(ids) - 1) else "old seat (the sect moved away)"
                seats.setdefault(pid, []).append({"sect": key, "role": role, "seat_row": m.group(1).strip()[:300],
                                                  "size": size.group(1).strip() if size else "",
                                                  "kind": kind.group(1).strip()[:200] if kind else ""})
    want = (painted | set(mentions) | set(seats)) & set(pl)
    rows = []
    for pid in sorted(want):
        p = pl[pid]
        tx, ty = p["tile"]
        near = sorted(((math.hypot(q["tile"][0] - tx, q["tile"][1] - ty), q) for q in w["places"] if q["id"] != pid), key=lambda t: t[0])[:8]
        e = cat.get(pid, {})
        crop = os.path.join(OUT, "crops", "in_%d.png" % pid)
        pa.place_crop(pid, crop)
        rows.append({
            "id": pid, "name": p.get("name"), "name_han": p.get("name_han"), "gloss": p.get("gloss"),
            "kind": p.get("kind"), "region": p.get("region"), "biome": p.get("biome"),
            "elevation_km": p.get("elevation_km"), "coast": p.get("coast"), "river": p.get("river"), "port": p.get("port"),
            "holder": p.get("holder"), "territory": p.get("territory"), "province": p.get("province"),
            "note": p.get("note"), "former": p.get("former"), "resource": p.get("resource"),
            "qi": (p.get("qi") or {}).get("shares"), "variants": (p.get("qi") or {}).get("variants"),
            "density": p.get("density"),
            "nearest": [{"id": q["id"], "name": q["name"], "kind": q["kind"], "km": int(round(d * KM_PER_TILE))} for d, q in near],
            "catalogue": {k: e.get(k) for k in ("look", "art_brief", "lore", "history", "levels") if e.get(k)},
            "seat_of": seats.get(pid, []),
            "depth_mentions": mentions.get(pid, [])[:12],
            "painted_before": pid in painted,
            "crop": os.path.relpath(crop, ROOT).replace(os.sep, "/"),
        })
    json.dump({"_doc": "Facts for the place prompt writers (tools/design/world/art_inputs.py). km = straight-line distance; "
                       "a tile is 25 km. crop = the map around the place (40 x 22.5 tiles, so about 1,000 x 560 km).",
               "places": rows}, open(os.path.join(OUT, "places.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    # place batches by region, about a third each
    by_region = {}
    for r in rows:
        by_region.setdefault(r["region"], []).append(r["id"])
    regions = sorted(by_region, key=lambda k: (k is None, k))
    third = len(rows) / 3.0
    pb, cur, n = [], [], 0
    for reg in regions:
        cur += by_region[reg]
        n += len(by_region[reg])
        if n >= third * (len(pb) + 1) and len(pb) < 2:
            pb.append(cur)
            cur = []
    pb.append(cur)
    # portrait batches by cast file, about 190 people each, a sect's files together
    groups = {}
    for f in sorted(glob.glob(os.path.join(D, "**", "*.cast.json"), recursive=True)):
        g = os.path.basename(f).split(".")[0]
        groups.setdefault(g, []).append((os.path.relpath(f, ROOT).replace(os.sep, "/"), len(load(f)["people"])))
    order = sorted(groups, key=lambda g: -sum(n for _, n in groups[g]))
    nb = 10
    bins = [[] for _ in range(nb)]
    load_ = [0] * nb
    for g in order:
        i = load_.index(min(load_))
        bins[i].append(g)
        load_[i] += sum(n for _, n in groups[g])
    portraits = [{"batch": "p%02d" % (i + 1), "groups": b, "people": load_[i],
                  "files": [f for g in b for f, _ in groups[g]]} for i, b in enumerate(bins)]
    json.dump({"places": [{"batch": "l%d" % (i + 1), "ids": b} for i, b in enumerate(pb)], "portraits": portraits},
              open(os.path.join(OUT, "batches.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print("places %d (batches %s); portraits %d people in %d batches (%s)" % (
        len(rows), [len(b) for b in pb], sum(load_), nb, load_))


if __name__ == "__main__":
    main()
