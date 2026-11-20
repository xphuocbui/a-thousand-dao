"""Lay the beast lairs and the special-goods sites on the map (Travel & Map rules 19-20; Trade Goods' catalogue;
user decision 2026-11-20: authored on the map before the economy prices them).

Reads the saved map (base/ index images, regions, politics, roads.png, sacred.json) and the game's place list
(assets/data/world_continent.json, so every place laid so far is avoided), and a hand-edited sites_proposal.json
(counts, gaps, the land each kind looks for, and names by kind and tile). Runs in seconds.

What it lays:
- **Beast lairs** (yêu thú sào huyệt): in wild forest, swamp, jungle and mountain ground, far from settlements and off
  the roads, one a region at most, spread apart; the most remote, rugged and richest ground first. A lair is wild (no
  holder): beasts are not worked like a mine.
- **Special sites** at the terrain that makes their good (Trade Goods' catalogue): hot springs (Linh Tuyền Thủy, from
  base/features.png's hot-spring bit), lava vents (Địa Hỏa Tinh, the lava bit) and lightning-struck woods (Lôi Kích
  Mộc, storm peaks next to forest, sacred.json's derived storm peaks). A special site is held by the territory's
  great sect.

It writes <map>/sites.json (the new places and the check) and <map>/sites.jpg. It reports; it does not judge.

Run:  python -I tools/design/map/sites.py --map design/map/continent-11
"""

import argparse
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import places as PL  # noqa: E402
import sacred as SA  # noqa: E402

from PIL import Image, ImageDraw, ImageFont  # noqa: E402

SETTLED = {"village", "town", "market", "city", "great_seat", "minor_seat"}
FOREST = {"temperate_forest", "bamboo_forest", "jungle", "swamp", "mangrove"}
KIND_HV = {"beast_lair": "yêu sào", "hot_spring": "ôn tuyền", "lava_vent": "địa hỏa khẩu", "lightning_wood": "lôi kích lâm"}


def dist(a, b):
    return ((a[0] - b[0]) ** 2 + (a[1] - b[1]) ** 2) ** 0.5


def near(xy, pts, r):
    return any(abs(px - xy[0]) <= r and abs(py - xy[1]) <= r and dist(xy, (px, py)) <= r for px, py in pts)


def lay_lairs(M, P, places, roads, waste):
    W = M.W
    settled = [tuple(p["tile"]) for p in places if p["kind"] in SETTLED]
    allp = [tuple(p["tile"]) for p in places]
    road_pts = [(i % W, i // W) for i, v in enumerate(roads) if v]
    road_set = set(road_pts)
    bio_ok = set(P["biomes"])
    cand = []
    for i in range(W * M.H):
        if not M.dry[i] or M.rid[i] <= 0 or PL.BNAME[M.b[i]] not in bio_ok:
            continue
        xy = (i % W, i // W)
        if xy in waste or near(xy, allp, P["place_gap"]):
            continue
        if any((xy[0] + ox, xy[1] + oy) in road_set for ox in range(-P["road_gap"], P["road_gap"] + 1)
               for oy in range(-P["road_gap"], P["road_gap"] + 1)):
            continue
        ds = min(dist(xy, s) for s in settled)
        if ds < P["settlement_gap"]:
            continue
        score = min(ds, 25) + 6 * M.relief[i] + 4 * (SA.BASE_D.get(M.b[i], 0.5) - 0.7)
        cand.append((round(score, 3), xy, i))
    cand.sort(key=lambda c: (-c[0], c[1]))
    chosen, regions = [], set()
    for score, xy, i in cand:
        if len(chosen) >= P["count"]:
            break
        if P.get("one_per_region") and M.rid[i] in regions:
            continue
        if any(dist(xy, c["tile"]) < P["gap"] for c in chosen):
            continue
        regions.add(M.rid[i])
        chosen.append({"kind": "beast_lair", "tile": list(xy), "score": score, "good": "yeu_cot",
                       "settlement_tiles": round(min(dist(xy, s) for s in settled), 1)})
    return chosen


def lay_specials(M, S, places, waste, storm):
    W = M.W
    allp = [tuple(p["tile"]) for p in places]
    out = []
    srcs = {
        "hot_spring": [i for i in range(W * M.H) if M.f[i] & SA.GEN["hot_spring"]],
        "lava_vent": [i for i in range(W * M.H) if M.f[i] & SA.GEN["lava"]],
        "lightning_wood": [],
    }
    fr = S["lightning_wood"]["forest_reach"]
    for x, y in storm:
        for ox in range(-fr, fr + 1):
            for oy in range(-fr, fr + 1):
                j = (y + oy) * W + (x + ox)
                if 0 <= x + ox < W and 0 <= y + oy < M.H and M.dry[j] and PL.BNAME[M.b[j]] in FOREST:
                    srcs["lightning_wood"].append(j)
    for kind in ("hot_spring", "lava_vent", "lightning_wood"):
        P = S[kind]
        cand = []
        for i in sorted(set(srcs[kind])):
            xy = (i % W, i // W)
            if not M.dry[i] or xy in waste or near(xy, allp + [tuple(o["tile"]) for o in out], P["place_gap"]):
                continue
            cand.append((round(SA.BASE_D.get(M.b[i], 0.5) + M.relief[i], 3), xy, i))
        cand.sort(key=lambda c: (-c[0], c[1]))
        chosen = []
        for score, xy, i in cand:
            if len(chosen) >= P["count"]:
                break
            if any(dist(xy, c["tile"]) < P["gap"] for c in chosen):
                continue
            chosen.append({"kind": kind, "tile": list(xy), "good": P["good"], "candidates": len(cand)})
        out += chosen
    return out


def render(M, places, new, out):
    W, H, sc = M.W, M.H, 3
    base = Image.open(os.path.join(M.d, "base", "detail.jpg")).convert("RGB").resize((W * sc, H * sc), Image.LANCZOS)
    base = Image.blend(base, Image.new("RGB", base.size, (20, 22, 30)), 0.4).convert("RGBA")
    ov = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    roads, _ = PL.pixels(os.path.join(M.d, "roads.png"))
    for i, v in enumerate(roads):
        if v in (1, 2) and M.land[i]:
            x, y = i % W, i // W
            d.rectangle((x * sc + 1, y * sc + 1, x * sc + 1, y * sc + 1), fill=(200, 170, 120, 130))
    for y in range(H):
        for x in range(W):
            a = M.terr[y * W + x]
            if a < 0:
                continue
            for nx, ny, sg in ((x + 1, y, ((x + 1) * sc, y * sc, (x + 1) * sc, (y + 1) * sc)),
                               (x, y + 1, (x * sc, (y + 1) * sc, (x + 1) * sc, (y + 1) * sc))):
                if nx < W and ny < H:
                    b = M.terr[ny * W + nx]
                    if b >= 0 and b != a:
                        d.line(sg, fill=(240, 230, 220, 110), width=1)
    try:
        font = ImageFont.truetype("arial.ttf", 15)
    except OSError:
        font = ImageFont.load_default()
    for p in places:
        x, y = p["tile"]
        big = p["kind"] in ("great_seat", "city")
        r = 3.5 if big else 1.5
        c = (255, 255, 255, 220) if big else (200, 200, 200, 150)
        d.ellipse((x * sc + 1.5 - r, y * sc + 1.5 - r, x * sc + 1.5 + r, y * sc + 1.5 + r), fill=c)
    col = {"beast_lair": (255, 120, 60), "hot_spring": (90, 200, 255), "lava_vent": (255, 60, 40),
           "lightning_wood": (190, 140, 255)}
    boxes = []
    for q in new:
        x, y = q["tile"]
        cx, cy = x * sc + 1.5, y * sc + 1.5
        c = col[q["kind"]]
        if q["kind"] == "beast_lair":
            d.regular_polygon((cx, cy, 9), 3, fill=c + (255,), outline=(0, 0, 0, 255))
        else:
            d.ellipse((cx - 7, cy - 7, cx + 7, cy + 7), fill=c + (255,), outline=(0, 0, 0, 255), width=2)
        text = q.get("name_hv") or q["kind"].replace("_", " ")
        tw, th = d.textbbox((0, 0), text, font=font, stroke_width=3)[2:]
        for ox, oy in ((11, -th / 2), (-11 - tw, -th / 2), (-tw / 2, 11), (-tw / 2, -11 - th), (11, 8), (-11 - tw, 8)):
            bx = (cx + ox, cy + oy, cx + ox + tw, cy + oy + th)
            if not any(bx[0] < o[2] and o[0] < bx[2] and bx[1] < o[3] and o[1] < bx[3] for o in boxes):
                break
        boxes.append(bx)
        d.text((bx[0], bx[1]), text, fill=tuple(min(255, v + 60) for v in c) + (255,), font=font, stroke_width=3,
               stroke_fill=(10, 10, 15, 255))
    img = Image.alpha_composite(base, ov).convert("RGB")
    lg = ImageDraw.Draw(img)
    items = [(col["beast_lair"], "beast lair (yêu sào): bone, hide, cores"),
             (col["hot_spring"], "hot spring (ôn tuyền): Linh Tuyền Thủy"),
             (col["lava_vent"], "lava vent (địa hỏa khẩu): Địa Hỏa Tinh"),
             (col["lightning_wood"], "lightning wood (lôi kích lâm): Lôi Kích Mộc")]
    x0, y0 = 12, H * sc - 22 * len(items) - 14
    lg.rectangle((x0 - 6, y0 - 8, x0 + 380, H * sc - 6), fill=(15, 15, 22))
    for k, (c, t) in enumerate(items):
        lg.rectangle((x0, y0 + k * 22, x0 + 14, y0 + k * 22 + 14), fill=c, outline=(200, 200, 200))
        lg.text((x0 + 22, y0 + k * 22 - 1), t, fill=(235, 235, 235), font=font)
    img.save(os.path.join(out, "sites.jpg"), quality=88)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", default="design/map/continent-11")
    ap.add_argument("--places", default="assets/data/world_continent.json")
    a = ap.parse_args()
    with open(os.path.join(a.map, "sites_proposal.json"), encoding="utf-8") as fh:
        prop = json.load(fh)
    with open(a.places, encoding="utf-8") as fh:
        places = [p for p in json.load(fh)["places"] if p.get("kind") not in KIND_HV]
    with open(os.path.join(a.map, "sacred.json"), encoding="utf-8") as fh:
        sacred = json.load(fh)
    M = PL.Map(a.map)
    roads, _ = PL.pixels(os.path.join(a.map, "roads.png"))
    roads = [1 if v in (1, 2) else 0 for v in roads]
    waste = {tuple(t) for t in sacred["miasma_wasteland"]["tile_list"]}
    storm = [tuple(t) for t in sacred["derived"]["storm_peaks"]]
    new = lay_lairs(M, prop["params"]["lair"], places, roads, waste)
    new += lay_specials(M, prop["params"]["special"], places + new, waste, storm)
    look = {(e["kind"], tuple(e["tile"])): e for e in prop.get("names", [])}
    used = set()
    for q in new:
        i = M.idx(*q["tile"])
        q["kind_hv"] = KIND_HV[q["kind"]]
        q["region"] = M.rid[i]
        q["region_name"] = M.regs.get(q["region"], {}).get("name_hv", "")
        q["biome"] = PL.BNAME[M.b[i]]
        q["elevation_km"] = round(M.h[i], 2)
        q["territory"] = M.greats[M.terr[i]]["name_hv"] if M.terr[i] >= 0 else None
        q["holder"] = None if q["kind"] == "beast_lair" else q["territory"]
        e = look.get((q["kind"], tuple(q["tile"])))
        if e:
            used.add((q["kind"], tuple(q["tile"])))
            for k in ("name_hv", "name_han", "gloss", "note"):
                if k in e:
                    q[k] = e[k]
    chk = {"new_places": {k: sum(1 for q in new if q["kind"] == k) for k in KIND_HV},
           "lair_regions": sorted({q["region"] for q in new if q["kind"] == "beast_lair"}),
           "unnamed": sum(1 for q in new if "name_hv" not in q),
           "unused_names": [e.get("name_hv") for k, e in look.items() if k not in used]}
    with open(os.path.join(a.map, "sites.json"), "w", encoding="utf-8") as fh:
        json.dump({"source": "tools/design/map/sites.py", "check": chk, "places": new}, fh, indent=1, ensure_ascii=False)
    render(M, places, new, a.map)
    print(json.dumps(chk, ensure_ascii=False))
    for q in new:
        print(q["kind"], q["tile"], q["region"], q["region_name"], q["biome"], q["elevation_km"], q["territory"],
              q.get("settlement_tiles", ""), q.get("name_hv", ""))


if __name__ == "__main__":
    main()
