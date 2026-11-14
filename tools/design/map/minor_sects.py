"""Place the minor sects' seats on a finished region map (Sects rules 1-3; Travel & Map rule 24).

Reads the saved index images, so it runs in seconds and needs no rebuild of the continent:
- <map>/regions.png (region ids), <map>/politics_proposal.json (great sects: regions, seats), and the
  map colours from <map>/sects_proposal.json,
- <map>/base/biome.png, elevation.png, features.png (Travel & Map rule 1),
- a hand-edited proposal JSON: each minor sect's lord, region and the land its seat looks for ("want").

For each minor sect, in file order, the seat is the tile of its region that best matches its wants:
- each want met near the tile scores (1.0, 0.7, 0.5, 0.35 ... by order);
- a small pull toward open space, away from the other seats;
- never on lake, glacier, lava or a volcano's cone; at least `min_sep` tiles from every other seat; at least
  `edge_tiles` from another sect's land, so a vassal sits inside its lord's territory; not under a region label;
  not on a small islet (under `islet_tiles`) when the region has bigger land, unless the entry says "islets": true.
An entry with "tile": [x, y] is placed there by hand.

It writes <map>/minor_sects.json (each seat, what it met, its land) and <map>/minor_sects.jpg (the politics map
with the minor seats). It reports; it does not judge.

Run:  python -I tools/design/map/minor_sects.py --map design/map/continent-11 \
          --sects design/map/continent-11/minor_sects_proposal.json
"""

import argparse
import json
import math
import os

from PIL import Image, ImageDraw, ImageFont

N4 = [(0, -1), (-1, 0), (1, 0), (0, 1)]

MP = {
    "min_sep": 14,               # tiles between any two seats (great or minor)
    "edge_tiles": 4,             # tiles from another sect's land
    "islet_tiles": 200,          # no seat on a landmass smaller than this, unless the region has nothing bigger
    "space_gain": 0.02,          # score per tile of distance to the nearest seat, up to space_cap
    "space_cap": 30,
    "want_weights": [1.0, 0.7, 0.5, 0.35],
    "km_per_tile": 25.0,         # about; regions.json gives 608 km2 a tile
    "scale": 3,                  # pixels a tile in politics_proposal.jpg
}

BIOMES = {"temperate_forest": 0, "bamboo_forest": 1, "jungle": 2, "grassland": 3, "steppe": 4, "desert": 5,
          "salt_flats": 6, "badlands": 7, "swamp": 8, "mangrove": 9, "highland": 10, "high_mountain": 11,
          "karst": 12, "volcano": 13, "tundra": 14, "glacier": 15, "miasma": 16, "lake": 17, "sea": 18}
F = {"lava": 1, "hot_spring": 2, "ice_field": 4, "river": 8, "lake": 16, "ore_vein": 32}

# tag: (radius in tiles, test on a tile)
TAGS = {
    "mountain": (2, lambda t: t["h"] >= 1.2),
    "peak": (3, lambda t: t["b"] == BIOMES["high_mountain"]),
    "highland": (2, lambda t: t["b"] == BIOMES["highland"] or 0.8 <= t["h"] < 2.0),
    "coast": (2, lambda t: t["b"] == BIOMES["sea"]),
    "river": (1, lambda t: t["f"] & F["river"]),
    "lake": (3, lambda t: t["b"] == BIOMES["lake"] or t["f"] & F["lake"]),
    "volcano": (4, lambda t: t["b"] == BIOMES["volcano"] or t["f"] & F["lava"]),
    "hot_spring": (3, lambda t: t["f"] & F["hot_spring"]),
    "ore": (3, lambda t: t["f"] & F["ore_vein"]),
    "ice": (5, lambda t: t["f"] & F["ice_field"] or t["b"] == BIOMES["glacier"]),
    "forest": (0, lambda t: t["b"] == BIOMES["temperate_forest"]),
    "bamboo": (1, lambda t: t["b"] == BIOMES["bamboo_forest"]),
    "jungle": (1, lambda t: t["b"] in (BIOMES["jungle"], BIOMES["mangrove"])),
    "grassland": (0, lambda t: t["b"] == BIOMES["grassland"]),
    "steppe": (0, lambda t: t["b"] == BIOMES["steppe"]),
    "desert": (2, lambda t: t["b"] in (BIOMES["desert"], BIOMES["salt_flats"], BIOMES["badlands"])),
    "swamp": (2, lambda t: t["b"] in (BIOMES["swamp"], BIOMES["mangrove"])),
    "karst": (2, lambda t: t["b"] == BIOMES["karst"]),
    "tundra": (0, lambda t: t["b"] == BIOMES["tundra"]),
}
BIOME_NAME = {v: k.replace("_", " ") for k, v in BIOMES.items()}


def pixels(path):
    im = Image.open(path)
    flat = getattr(im, "get_flattened_data", None) or im.getdata
    return list(flat()), im.size


def load(map_dir):
    rid, (W, H) = pixels(os.path.join(map_dir, "regions.png"))
    base = os.path.join(map_dir, "base")
    b, _ = pixels(os.path.join(base, "biome.png"))
    h = [(v - 10000) / 1000.0 for v in pixels(os.path.join(base, "elevation.png"))[0]]
    f, _ = pixels(os.path.join(base, "features.png"))
    with open(os.path.join(map_dir, "politics_proposal.json"), encoding="utf-8") as fh:
        pol = json.load(fh)
    with open(os.path.join(map_dir, "sects_proposal.json"), encoding="utf-8") as fh:  # map colours
        colours = {g["key"]: g["colour"] for g in json.load(fh)["great_sects"]}
    for g in pol["great_sects"]:
        g["colour"] = colours[g["key"]]
    with open(os.path.join(map_dir, "regions.json"), encoding="utf-8") as fh:
        regs = {o["id"]: o for o in json.load(fh)["regions"]}
    return W, H, rid, b, h, f, pol, regs


def bfs_dist(W, H, sources, inside):
    """4-neighbour tile distance from the sources, over tiles where inside(i) holds."""
    INF = 10 ** 9
    d = [INF] * (W * H)
    q = list(sources)
    for i in q:
        d[i] = 0
    head = 0
    while head < len(q):
        i = q[head]; head += 1
        x, y = i % W, i // W
        for ox, oy in N4:
            nx, ny = x + ox, y + oy
            if 0 <= nx < W and 0 <= ny < H:
                j = ny * W + nx
                if inside(j) and d[j] > d[i] + 1:
                    d[j] = d[i] + 1
                    q.append(j)
    return d


def label_point(W, H, rid, r):
    """The tile of region r farthest from its edge: where regions.py writes the region's label."""
    edge = []
    for i in range(W * H):
        if rid[i] != r:
            continue
        x, y = i % W, i // W
        if any(not (0 <= x + ox < W and 0 <= y + oy < H) or rid[(y + oy) * W + x + ox] != r for ox, oy in N4):
            edge.append(i)
    d = bfs_dist(W, H, edge, lambda j: rid[j] == r)
    best = max((i for i in range(W * H) if rid[i] == r), key=lambda i: d[i])
    return best % W, best // W


def tag_map(W, H, b, h, f, tag):
    """Per tile: does the tag's test hold within its radius (square window)."""
    rad, test = TAGS[tag]
    hit = [bool(test({"b": b[i], "h": h[i], "f": f[i]})) for i in range(W * H)]
    if rad == 0:
        return hit
    rows = [[False] * W for _ in range(H)]                                    # max over the window, rows then columns
    for y in range(H):
        row = hit[y * W:(y + 1) * W]
        for x in range(W):
            if row[x]:
                for xx in range(max(0, x - rad), min(W, x + rad + 1)):
                    rows[y][xx] = True
    out = [False] * (W * H)
    for y in range(H):
        for x in range(W):
            if rows[y][x]:
                for yy in range(max(0, y - rad), min(H, y + rad + 1)):
                    out[yy * W + x] = True
    return out


def place(map_dir, prop):
    W, H, rid, b, h, f, pol, regs = load(map_dir)
    greats = pol["great_sects"]
    gkey = {g["key"]: k for k, g in enumerate(greats)}
    sect_of_region = {r: k for k, g in enumerate(greats) for r in g["regions"]}
    terr = [sect_of_region.get(r, -1) if r else -1 for r in rid]
    # distance from another sect's land (the coast does not count)
    front = []
    for i in range(W * H):
        if terr[i] < 0:
            continue
        x, y = i % W, i // W
        for ox, oy in N4:
            nx, ny = x + ox, y + oy
            if 0 <= nx < W and 0 <= ny < H:
                t = terr[ny * W + nx]
                if t >= 0 and t != terr[i]:
                    front.append(i)
                    break
    edge_d = bfs_dist(W, H, front, lambda j: terr[j] >= 0)
    # landmass size per tile (8-neighbour), to keep seats off small islets
    mass = [0] * (W * H)
    seen = [False] * (W * H)
    for i0 in range(W * H):
        if rid[i0] and not seen[i0]:
            comp, q = [], [i0]
            seen[i0] = True
            while q:
                i = q.pop()
                comp.append(i)
                x, y = i % W, i // W
                for ox in (-1, 0, 1):
                    for oy in (-1, 0, 1):
                        nx, ny = x + ox, y + oy
                        if 0 <= nx < W and 0 <= ny < H and rid[ny * W + nx] and not seen[ny * W + nx]:
                            seen[ny * W + nx] = True
                            q.append(ny * W + nx)
            for i in comp:
                mass[i] = len(comp)
    big_mass = {r: max(mass[i] for i in range(W * H) if rid[i] == r) for r in regs}
    # region label boxes, in tiles (bold 20 px text at 3 px a tile, plus a margin)
    sc = MP["scale"]
    label_boxes = []
    for r, o in regs.items():
        lx, ly = label_point(W, H, rid, r)
        text = f"{r} {o.get('name_hv', '')}".strip()
        half_w = (len(text) * 11.5 / 2 + 6) / sc
        label_boxes.append((lx - half_w, ly - 6, lx + half_w, ly + 6))
    in_label = lambda x, y: any(x0 <= x <= x1 and y0 <= y <= y1 for x0, y0, x1, y1 in label_boxes)
    tags = {}
    seats = [tuple(g["seat_tile"]) for g in greats]
    bad = {BIOMES["lake"], BIOMES["glacier"], BIOMES["volcano"], BIOMES["sea"]}
    placed = []
    for s in prop["minor_sects"]:
        lord = gkey[s["lord"]]
        region = s["region"]
        if region not in greats[lord]["regions"]:
            raise SystemExit(f"{s['key']}: region {region} is not {s['lord']}'s")
        for t in s["want"]:
            if t not in tags:
                tags[t] = tag_map(W, H, b, h, f, t)
        ww = MP["want_weights"]
        if s.get("tile"):
            best = s["tile"][1] * W + s["tile"][0]
            how = "by hand"
        else:
            best, best_score = None, -1.0
            for i in range(W * H):
                if rid[i] != region or b[i] in bad or f[i] & F["lava"] or edge_d[i] < MP["edge_tiles"]:
                    continue
                if mass[i] < MP["islet_tiles"] and big_mass[region] >= MP["islet_tiles"] and not s.get("islets"):
                    continue
                x, y = i % W, i // W
                near = min(math.hypot(x - sx, y - sy) for sx, sy in seats)
                if near < MP["min_sep"] or in_label(x, y):
                    continue
                score = sum(ww[min(k, len(ww) - 1)] for k, t in enumerate(s["want"]) if tags[t][i])
                score += MP["space_gain"] * min(near, MP["space_cap"])
                if score > best_score:
                    best, best_score = i, score
            if best is None:
                raise SystemExit(f"{s['key']}: no tile in region {region} meets the spacing")
            how = "by the tool"
        x, y = best % W, best // W
        seats.append((x, y))
        g = greats[lord]
        gx, gy = g["seat_tile"]
        rec = {k: s[k] for k in ("key", "name_hv", "name_han", "gloss", "alignment", "leans", "craft") if k in s}
        rec.update({
            "lord": g["key"], "lord_name": g["name_hv"], "region": region,
            "region_name": regs[region].get("name_hv", ""), "seat_tile": [x, y], "placed": how,
            "biome": BIOME_NAME[b[best]], "elevation_km": round(h[best], 2),
            "wants_met": [t for t in s["want"] if tags[t][best]],
            "wants_missed": [t for t in s["want"] if not tags[t][best]],
            "tiles_to_lord_seat": round(math.hypot(x - gx, y - gy), 1),
            "km_to_lord_seat": int(round(math.hypot(x - gx, y - gy) * MP["km_per_tile"], -1)),
            "tiles_to_other_sect": edge_d[best] if edge_d[best] < 10 ** 9 else None,  # None: no land link
            "landmass_tiles": mass[best],
        })
        placed.append(rec)
    counts = {g["name_hv"]: sum(1 for p in placed if p["lord"] == g["key"]) for g in greats}
    check = {
        "minor_sects": len(placed),
        "per_great_sect": counts,
        "regions_without_one": [r for r in sorted(regs) if not any(p["region"] == r for p in placed)],
        "wants_met_share": round(sum(len(p["wants_met"]) for p in placed)
                                 / max(1, sum(len(p["wants_met"]) + len(p["wants_missed"]) for p in placed)), 2),
        "first_want_met": sum(1 for p in placed if p["wants_met"] and p["wants_met"][0] == next(
            s["want"][0] for s in prop["minor_sects"] if s["key"] == p["key"])),
        "alignments": {a: sum(1 for p in placed if p.get("alignment") == a)
                       for a in sorted({p.get("alignment") for p in placed})},
        "min_seat_gap_tiles": round(min(math.hypot(a[0] - c[0], a[1] - c[1]) for k, a in enumerate(seats)
                                        for c in seats[k + 1:]), 1),
        "params": MP,
    }
    out = {"source": "tools/design/map/minor_sects.py", "check": check, "minor_sects": placed}
    return out, greats, (W, H), [(r, label_point(W, H, rid, r)) for r in sorted(regs)], regs


def render(map_dir, out, greats, size, labels, regs):
    W, H = size
    sc = MP["scale"]
    full = Image.open(os.path.join(map_dir, "politics_proposal.jpg")).convert("RGB")
    img = full.crop((0, 0, W * sc, H * sc))
    d = ImageDraw.Draw(img)
    try:
        font = ImageFont.truetype("arialbd.ttf", 16)
        small = ImageFont.truetype("arial.ttf", 17)
        smallb = ImageFont.truetype("arialbd.ttf", 17)
    except OSError:
        font = small = smallb = ImageFont.load_default()
    col = {g["key"]: tuple(g["colour"]) for g in greats}
    boxes = []
    for g in greats:                                                            # keep labels off the great seats
        x, y = g["seat_tile"]
        boxes.append((x * sc - 20, y * sc - 20, x * sc + 20, y * sc + 20))
    try:
        regfont = ImageFont.truetype("arialbd.ttf", 20)
    except OSError:
        regfont = font
    for r, (x, y) in labels:                                                    # keep labels off the region names
        tw = d.textlength(f"{r} {regs[r].get('name_hv', '')}".strip(), font=regfont)
        boxes.append((x * sc - tw / 2 - 4, y * sc - 13, x * sc + tw / 2 + 4, y * sc + 15))
    dots = []
    for k, p in enumerate(out["minor_sects"]):
        x, y = p["seat_tile"]
        px, py = x * sc + 1, y * sc + 1
        dots.append((px, py))
        boxes.append((px - 9, py - 9, px + 9, py + 9))
    for k, p in enumerate(out["minor_sects"]):
        px, py = dots[k]
        r = 8
        shape = [(px, py - r - 1), (px + r + 1, py), (px, py + r + 1), (px - r - 1, py)]  # a diamond: minor seat
        d.polygon(shape, fill=col[p["lord"]], outline=(255, 250, 235))
        d.polygon([(px, py - r + 2), (px + r - 2, py), (px, py + r - 2), (px - r + 2, py)], outline=(20, 10, 10))
        if p.get("alignment") == "ma đạo":
            d.ellipse((px - 2, py - 2, px + 2, py + 2), fill=(20, 10, 10))
        text = f"{k + 1} {p['name_hv']}"
        tw = d.textlength(text, font=font)
        best = None
        for ox, oy, anchor in ((12, 0, "lm"), (-12, 0, "rm"), (0, -14, "mb"), (0, 14, "mt"),
                               (12, -12, "lb"), (12, 12, "lt"), (-12, -12, "rb"), (-12, 12, "rt")):
            x0 = px + ox - (0 if anchor[0] == "l" else tw if anchor[0] == "r" else tw / 2)
            y0 = py + oy - (0 if anchor[1] == "t" else 16 if anchor[1] == "b" else 8)
            box = (x0 - 2, y0 - 2, x0 + tw + 2, y0 + 18)
            if box[0] < 0 or box[2] > W * sc or box[1] < 0 or box[3] > H * sc:
                continue
            hits = sum(1 for bx in boxes if not (box[2] < bx[0] or box[0] > bx[2] or box[3] < bx[1] or box[1] > bx[3]))
            if best is None or hits < best[0]:
                best = (hits, ox, oy, anchor, box)
        _, ox, oy, anchor, box = best
        boxes.append(box)
        d.text((px + ox, py + oy), text, fill=(20, 10, 10), font=font, anchor=anchor,
               stroke_width=3, stroke_fill=(255, 250, 235))
    # legend strip: the minor sects by lord
    rows = (len(out["minor_sects"]) + 1) // 2
    strip = Image.new("RGB", (W * sc, 28 * rows + 60), (255, 250, 235))
    sd = ImageDraw.Draw(strip)
    colw = W * sc // 2
    for k, p in enumerate(out["minor_sects"]):
        lx, yy = 20 + (k // rows) * colw, 12 + 28 * (k % rows)
        sd.polygon([(lx + 9, yy + 2), (lx + 18, yy + 11), (lx + 9, yy + 20), (lx, yy + 11)], fill=col[p["lord"]],
                   outline=(40, 20, 20))
        mark = " (ma đạo)" if p.get("alignment") == "ma đạo" else ""
        sd.text((lx + 28, yy), f"{k + 1} {p['name_hv']}", fill=(30, 15, 15), font=smallb)
        nw = sd.textlength(f"{k + 1} {p['name_hv']}", font=smallb)
        sd.text((lx + 34 + nw, yy), f"{p['gloss']}; {p['lord_name']}{mark}", fill=(60, 40, 40), font=small)
    sd.text((20, 12 + 28 * rows + 8), "Star = great sect seat.  Diamond = minor sect seat, in its lord's colour; "
            "a dot in it = ma đạo.  Big numbers = regions.", fill=(30, 15, 15), font=small)
    page = Image.new("RGB", (W * sc, H * sc + strip.height))
    page.paste(img, (0, 0))
    page.paste(strip, (0, H * sc))
    page.save(os.path.join(map_dir, "minor_sects.jpg"), quality=88)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", default="design/map/continent-11")
    ap.add_argument("--sects", default="design/map/continent-11/minor_sects_proposal.json")
    a = ap.parse_args()
    with open(a.sects, encoding="utf-8") as fh:
        prop = json.load(fh)
    out, greats, size, labels, regs = place(a.map, prop)
    with open(os.path.join(a.map, "minor_sects.json"), "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=1, ensure_ascii=False)
    render(a.map, out, greats, size, labels, regs)
    print(json.dumps(out["check"], indent=1, ensure_ascii=False))
    for k, p in enumerate(out["minor_sects"]):
        print(f"{k + 1:2} {p['name_hv']:18} r{p['region']:2} {p['seat_tile']} {p['biome']:16} "
              f"{p['elevation_km']:5} km  met {p['wants_met']} missed {p['wants_missed']}  "
              f"lord {p['km_to_lord_seat']} km  edge {p['tiles_to_other_sect']}")


if __name__ == "__main__":
    main()
