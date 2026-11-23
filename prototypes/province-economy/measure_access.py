# PROTOTYPE - NOT FOR PRODUCTION
"""Measures what the access formula (design/gdd/provinces.md Formulas) works with, per settlement province: road, river
and coast tiles, production value and its own demand, so infrastructure points can be scaled from real numbers.
Run: python -I prototypes/province-economy/measure_access.py (prints observations)."""
import json
import os
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools/design/map"))
import provinces as PV  # noqa: E402

cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
W, H, L = PV.read_grid(os.path.join(ROOT, cont["grid_file"].replace("res://", "")))
pid = np.asarray(Image.open(os.path.join(ROOT, "design/map/continent-11/provinces/province_ids.png"))).astype(np.int32)
provs = {p["id"]: p for p in json.load(open(os.path.join(ROOT, "design/map/continent-11/provinces/provinces.json"), encoding="utf-8"))["provinces"]}
dump = json.load(open(os.path.join(HERE, "places_seed7.json"), encoding="utf-8"))
road = L["ROAD"] > 0
river = (L["FEAT"].astype(np.int32) & 8) > 0
sea = L["REGN"] == 0
coast = np.zeros_like(road)
for sh in ((0, 1), (0, -1), (1, 0), (-1, 0)):
    coast |= np.roll(sea, sh, axis=(0, 1))
coast &= ~sea
prod = {}
heads = {}
for pl in dump["places"]:
    x, y = int(pl["tile"][0]), int(pl["tile"][1])
    v = int(pid[y, x])
    if v:
        prod[v] = prod.get(v, 0.0) + sum(pl["production"].values())
        heads[v] = heads.get(v, 0) + sum(pl["heads"])
rows = []
for i, p in provs.items():
    if p["seed_kind"] == "wilderness":
        continue
    m = pid == i
    rows.append((i, int((m & road).sum()), int((m & river).sum()), int((m & coast).sum()), p["tiles"], prod.get(i, 0.0), heads.get(i, 0)))
a = np.array([r[1:] for r in rows], float)
names = ["road tiles", "river tiles", "coast tiles", "tiles", "production value", "people"]
for k, n in enumerate(names):
    col = a[:, k]
    print("%-17s min %7.0f  p25 %7.0f  median %7.0f  p75 %7.0f  max %7.0f  zero in %d" % (
        n, col.min(), np.percentile(col, 25), np.median(col), np.percentile(col, 75), col.max(), int((col == 0).sum())))
print("settlement provinces %d; road tiles per production value: median %.4f" % (len(rows), float(np.median(a[:, 0] / np.maximum(a[:, 4], 1)))))
top = sorted(rows, key=lambda r: -r[5])[:8]
print("largest producers (id: road, river, coast, production):", ", ".join("%d: %d/%d/%d %.0f" % (r[0], r[1], r[2], r[3], r[5]) for r in top))

# Can every province reach start_access_min with F6's numbers? (advisor check 2026-11-23)
INFRA0 = {"village": 100, "market": 200, "town": 200, "minor_seat": 300, "city": 400, "great_seat": 600}
ROAD_MAX = 5 * 200          # road building, levels 1-5
POST_MAX = 5 * 400          # caravan post, if per level
LANDING = 500
print("\nF6 at start (usage ~ production value; own demand ignored, so this is the worst case):")
short = []
for (i, rd, rv, co, tiles, pv, hd) in rows:
    kind = provs[i]["seed_kind"]
    nat = INFRA0[kind] + 40 * rd + 25 * min(rv, 20)
    mx = nat + ROAD_MAX + POST_MAX + (LANDING if (rv or co) else 0)
    need = 0.5 * pv
    if mx < need:
        short.append((i, kind, pv, nat, mx, need))
print("natural access 1: %d of %d; natural >= 0.5: %d" % (
    sum(1 for r in rows if INFRA0[provs[r[0]]["seed_kind"]] + 40 * r[1] + 25 * min(r[2], 20) >= r[5]), len(rows),
    sum(1 for r in rows if INFRA0[provs[r[0]]["seed_kind"]] + 40 * r[1] + 25 * min(r[2], 20) >= 0.5 * r[5])))
print("cannot reach 0.5 even with road 5 + post 5 + landing: %d" % len(short))
for s_ in sorted(short, key=lambda t: -t[2]):
    print("  id %d %-10s output %6.0f  natural %5.0f  max %5.0f  needs %6.0f  -> best access %.2f" % (s_[0], s_[1], s_[2], s_[3], s_[4], s_[5], s_[4] / s_[2]))
