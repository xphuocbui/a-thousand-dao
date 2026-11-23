"""Provinces for the continent (user, 2026-11-23: "simulate the economy better and more naturally"; step 1 of the
province plan in production/plans/ui-greybox-build.md): the land split into provinces, each the catchment of one
settlement, grown outward by travel cost and never crossing a region border; land too far from any settlement becomes
wilderness provinces; tiny leftovers merge into a neighbour. A proposal to look at, not yet game data.

Run: python -I tools/design/map/provinces.py [--render]
Reads assets/data/world_continent.json, its grid (assets/map/continent_11_grid.bin: REGN, MAIN, ROAD) and
assets/data/travel_rules.json (biome_cost, road_terrain_share). Writes design/map/continent-11/provinces/:
provinces.json (each province: id, region, seed place or wilderness, tiles, centre, neighbours, land mix) and
province_ids.png (16-bit, the province id per tile, 0 = water); with --render, preview.png (the borders over the paper
map) and stats printed (observations, never a verdict).
"""
import heapq
import json
import os
import struct
import sys
import zlib
from collections import Counter, defaultdict

import numpy as np
from PIL import Image, ImageDraw

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
OUT = os.path.join(ROOT, "design/map/continent-11/provinces")
SEED_KINDS = {"city", "town", "village", "market", "great_seat", "minor_seat"}
WILD_COST = 40.0     # land further than this (in tile-cost units: a grassland tile costs 1) from any seed seeds a wilderness province
RIVER_CROSS = 6.0    # extra cost to step onto a river tile from off it: borders follow rivers, as natural boundaries
RIDGE_SLOPE = 0.004  # extra cost per metre climbed or descended between two tiles: borders follow ridges and valleys
NOISE = 0.35         # a smooth multiplicative wobble on the cost (±35 %), so borders wander instead of drawing octagons
MIN_TILES = 90       # a province smaller than this merges into the neighbour it shares the longest border with
LAKE_ID, SEA_ID = 17, 18


def read_grid(path):
    b = open(path, "rb").read()
    assert b[:8] == b"DAOGRID1", path
    w, h, n = struct.unpack("<HHH", b[8:14])
    at, layers = 14, {}
    for _ in range(n):
        tag = b[at:at + 4].decode()
        nb, signed = b[at + 4], b[at + 5]
        raw_len, comp_len = struct.unpack("<II", b[at + 6:at + 14])
        at += 14
        data = zlib.decompress(b[at:at + comp_len])
        at += comp_len
        dt = {1: np.int8 if signed else np.uint8, 2: np.int16 if signed else np.uint16, 4: np.int32 if signed else np.uint32}[nb]
        layers[tag] = np.frombuffer(data, dtype=dt).reshape(h, w)
    return w, h, layers


def main(render):
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    rules = json.load(open(os.path.join(ROOT, "assets/data/travel_rules.json"), encoding="utf-8"))
    meta = json.load(open(os.path.join(ROOT, "design/map/continent-11/base/meta.json"), encoding="utf-8"))
    W, H, L = read_grid(os.path.join(ROOT, cont["grid_file"].replace("res://", "")))
    regn = L["REGN"].astype(np.int32)
    main_b = L["MAIN"].astype(np.int32)
    road = L["ROAD"].astype(np.int32)
    names = {int(k): str(v) for k, v in meta["legend"]["biome_ids"].items()}
    bc = rules["biome_cost"]
    cost = np.ones((H, W), np.float32)
    for bid, name in names.items():
        cost[main_b == bid] = float(bc.get(name.lower().replace(" ", "_"), 1.5))
    cost = np.where(road > 0, cost * float(rules["road_terrain_share"]), cost)
    # a smooth noise field (seeded): bilinear-upscaled random values on a coarse lattice
    rng = np.random.default_rng(11)
    coarse = rng.random((H // 12 + 2, W // 12 + 2)).astype(np.float32)
    wob = np.asarray(Image.fromarray((coarse * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC)).astype(np.float32) / 255.0
    cost = cost * (1.0 + NOISE * (wob - 0.5) * 2.0)
    river = (L["FEAT"].astype(np.int32) & 8) > 0
    elev = L["ELEV"].astype(np.float32)
    land = (regn > 0) & (main_b != LAKE_ID) & (main_b != SEA_ID)

    seeds = []   # (x, y, place id or None, kind)
    for p in cont["places"]:
        if p["kind"] in SEED_KINDS:
            x, y = p["tile"]
            if land[y, x]:
                seeds.append((x, y, p["id"], p["kind"], p["name"]))

    owner = np.zeros((H, W), np.int32)
    dist = np.full((H, W), np.inf, np.float32)

    def spread(starts):
        """Grows the seeds [(x, y, owner)] outward by travel cost, taking only tiles they reach more cheaply than their
        current owner does (so a new seed only touches its own neighbourhood)."""
        pq = []
        for x, y, o in starts:
            dist[y, x] = 0.0
            owner[y, x] = o
            heapq.heappush(pq, (0.0, x, y, o))
        while pq:
            d, x, y, o = heapq.heappop(pq)
            if d > dist[y, x] or owner[y, x] != o:
                continue
            r = regn[y, x]
            for dx, dy, step in STEPS:   # eight directions, diagonals at sqrt 2: no diamond shapes
                nx, ny = x + dx, y + dy
                if 0 <= nx < W and 0 <= ny < H and land[ny, nx] and regn[ny, nx] == r:   # never cross a region border
                    nd = d + step * 0.5 * (cost[y, x] + cost[ny, nx]) + RIDGE_SLOPE * abs(float(elev[ny, nx]) - float(elev[y, x]))
                    if river[ny, nx] and not river[y, x]:
                        nd += RIVER_CROSS
                    if nd < dist[ny, nx]:
                        dist[ny, nx] = nd
                        owner[ny, nx] = o
                        heapq.heappush(pq, (nd, nx, ny, o))

    spread([(s[0], s[1], i + 1) for i, s in enumerate(seeds)])
    # wilderness seeds: the farthest (or unreached) land tile seeds a province until all land is within WILD_COST
    while True:
        far = np.where(land, np.where(np.isinf(dist), 1e9, dist), -1.0)
        y, x = np.unravel_index(np.argmax(far), far.shape)
        if far[y, x] <= WILD_COST:
            break
        seeds.append((int(x), int(y), None, "wilderness", ""))
        spread([(int(x), int(y), len(seeds))])
    # merge tiny provinces into the neighbour (same region) with the longest shared border
    owner = owner.copy()
    while True:
        sizes = Counter(owner[land].tolist())
        small = [o for o, n in sizes.items() if n < MIN_TILES and o not in MIN_SKIP]
        if not small:
            break
        o = min(small, key=lambda k: sizes[k])
        ys, xs = np.nonzero(owner == o)
        border = Counter()
        for y, x in zip(ys.tolist(), xs.tolist()):
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < W and 0 <= ny < H and land[ny, nx] and owner[ny, nx] not in (0, o):
                    border[owner[ny, nx]] += 1
        if not border:   # an islet with no neighbour: it stays its own province
            MIN_SKIP.add(o)
            continue
        into = border.most_common(1)[0][0]
        # a settlement keeps its province when merging with wilderness: the wilderness joins it
        if seeds[o - 1][2] is not None and seeds[into - 1][2] is None:
            owner[owner == into] = o
        else:
            owner[owner == o] = into
    # renumber 1..N, build records
    ids = sorted(set(owner[land].tolist()))
    remap = {o: i + 1 for i, o in enumerate(ids)}
    pid = np.zeros((H, W), np.uint16)
    for o, i in remap.items():
        pid[owner == o] = i
    provs = []
    neigh = defaultdict(Counter)
    a, b = pid[:, :-1], pid[:, 1:]
    m = (a > 0) & (b > 0) & (a != b)
    for u, v in zip(a[m].tolist(), b[m].tolist()):
        neigh[u][v] += 1
        neigh[v][u] += 1
    a, b = pid[:-1, :], pid[1:, :]
    m = (a > 0) & (b > 0) & (a != b)
    for u, v in zip(a[m].tolist(), b[m].tolist()):
        neigh[u][v] += 1
        neigh[v][u] += 1
    seed_of = {}
    for o, i in remap.items():
        s = seeds[o - 1]
        seed_of[i] = s
    places_in = defaultdict(list)
    for p in cont["places"]:
        x, y = p["tile"]
        if 0 <= x < W and 0 <= y < H and pid[y, x] > 0:
            places_in[int(pid[y, x])].append(p["id"])
    for i in range(1, len(ids) + 1):
        ys, xs = np.nonzero(pid == i)
        s = seed_of[i]
        mix = Counter(main_b[ys, xs].tolist())
        provs.append({"id": i, "region": int(regn[ys[0], xs[0]]), "seed_place": s[2], "seed_kind": s[3], "name": s[4],
                      "tiles": int(len(xs)), "centre": [int(round(xs.mean())), int(round(ys.mean()))],
                      "places": places_in[i],
                      "neighbours": [{"province": int(k), "border_tiles": int(v)} for k, v in sorted(neigh[i].items())],
                      "land": {names.get(k, str(k)): round(v / len(xs), 3) for k, v in mix.most_common(4)}})
    os.makedirs(OUT, exist_ok=True)
    json.dump({"_doc": "Province proposal (tools/design/map/provinces.py, 2026-11-23): each the catchment of one settlement "
                       "by travel cost inside its region, wilderness where land is far from any settlement; not game data yet.",
               "params": {"wild_cost": WILD_COST, "min_tiles": MIN_TILES, "seed_kinds": sorted(SEED_KINDS)},
               "provinces": provs}, open(os.path.join(OUT, "provinces.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    Image.fromarray(pid.astype(np.uint16)).save(os.path.join(OUT, "province_ids.png"))
    sizes = sorted(p["tiles"] for p in provs)
    by_kind = Counter(p["seed_kind"] for p in provs)
    print("provinces %d (%s); tiles per province: min %d, median %d, max %d; per region %.1f" % (
        len(provs), ", ".join("%s %d" % kv for kv in by_kind.most_common()), sizes[0], sizes[len(sizes) // 2], sizes[-1],
        len(provs) / max(1, len(set(p["region"] for p in provs)))))
    lines = border_lines(pid, regn)
    json.dump({"_doc": "Province and region borders as smooth polylines in tile coordinates (tools/design/map/provinces.py): "
                       "tile-edge steps chained, straightened, rounded twice and given a gentle wobble; each shared border is "
                       "one line, so neighbours always meet. kind: region (bold) or province (thin).",
               "lines": [{"kind": k, "a": pr[0], "b": pr[1], "points": [[round(x, 2), round(y, 2)] for x, y in pts]}
                         for k, pr, pts in lines]},
              open(os.path.join(OUT, "borders.json"), "w", encoding="utf-8"))
    # the game's copy (drawn by MapView): each province's grid region and centre, and every border line with the two
    # provinces it separates, so the map can tell a holder change (bold) from a region line and a province line
    game = {"_doc": "Provinces of continent 11 (tools/design/map/provinces.py, 2026-11-23): a drawing layer for now "
                    "(design/ux/hud.md Map zoom and the political map); the economy does not read them yet.",
            "provinces": [{"id": p["id"], "region": p["region"], "centre": p["centre"], "seed_place": p["seed_place"],
                           "kind": p["seed_kind"]} for p in provs],
            "lines": [{"a": pr[0], "b": pr[1], "points": [round(v, 2) for xy in pts for v in xy]} for k, pr, pts in lines]}
    json.dump(game, open(os.path.join(ROOT, "assets/map/continent_11_provinces.json"), "w", encoding="utf-8"), separators=(",", ":"))
    if render:
        render_preview(pid, provs, lines)


MIN_SKIP = set()
STEPS = [(1, 0, 1.0), (-1, 0, 1.0), (0, 1, 1.0), (0, -1, 1.0),
         (1, 1, 1.4142), (1, -1, 1.4142), (-1, 1, 1.4142), (-1, -1, 1.4142)]


WOBBLE = 0.32     # tiles: how far a border wanders sideways from its smoothed course (ends stay put)


def border_lines(pid, regn):
    """Borders between land tiles of two provinces as smooth lines: unit edges chained (breaking where three provinces
    meet or the kind changes), each step's corner replaced by the midpoints (a staircase becomes a diagonal), two passes
    of corner cutting, then a smooth sideways wobble so they read as drawn borders, not geometry."""
    H, W = pid.shape
    ea, eb, kind, pair = [], [], [], []
    for y in range(H):
        for x in range(W):
            a = int(pid[y, x])
            if a == 0:
                continue
            if x + 1 < W and pid[y, x + 1] and pid[y, x + 1] != a:
                ea.append((x + 1, y)); eb.append((x + 1, y + 1)); kind.append(1 if regn[y, x] != regn[y, x + 1] else 0)
                pair.append(tuple(sorted((a, int(pid[y, x + 1])))))
            if y + 1 < H and pid[y + 1, x] and pid[y + 1, x] != a:
                ea.append((x, y + 1)); eb.append((x + 1, y + 1)); kind.append(1 if regn[y, x] != regn[y + 1, x] else 0)
                pair.append(tuple(sorted((a, int(pid[y + 1, x])))))
    at = defaultdict(list)
    for i in range(len(ea)):
        at[ea[i]].append(i)
        at[eb[i]].append(i)
    used = [False] * len(ea)

    def walk(start, first):
        pts = [start]
        e, cur = first, start
        while e >= 0:
            used[e] = True
            cur = eb[e] if ea[e] == cur else ea[e]
            pts.append(cur)
            nxt = -1
            here = at[cur]
            if len(here) == 2:
                for k in here:
                    if not used[k] and kind[k] == kind[e] and pair[k] == pair[e]:
                        nxt = k
            e = nxt
        return pts

    lines = []
    for q, here in at.items():
        if len(here) == 2 and kind[here[0]] == kind[here[1]] and pair[here[0]] == pair[here[1]]:
            continue
        for k in here:
            if not used[k]:
                lines.append((kind[k], pair[k], walk(q, k)))
    for k in range(len(ea)):
        if not used[k]:
            lines.append((kind[k], pair[k], walk(ea[k], k)))
    rng = np.random.default_rng(29)
    coarse = rng.random((H // 6 + 3, W // 6 + 3)).astype(np.float32)
    wob = np.asarray(Image.fromarray((coarse * 255).astype(np.uint8)).resize((W * 4, H * 4), Image.BICUBIC)).astype(np.float32) / 255.0 - 0.5

    def smooth(pts):
        p = np.array(pts, np.float32)
        if len(p) >= 3:   # midpoints: a staircase becomes a straight diagonal
            p = np.vstack([p[:1], (p[:-1] + p[1:]) * 0.5, p[-1:]])
        for _ in range(2):   # corner cutting
            if len(p) < 3:
                break
            q = [p[0]]
            for i in range(len(p) - 1):
                if i > 0:
                    q.append(p[i] * 0.75 + p[i + 1] * 0.25)
                if i < len(p) - 2:
                    q.append(p[i] * 0.25 + p[i + 1] * 0.75)
            q.append(p[-1])
            p = np.array(q, np.float32)
        if len(p) >= 4:   # the wobble: sideways, from a smooth field, tapering to 0 at both ends
            t = np.gradient(p, axis=0)
            nrm = np.stack([-t[:, 1], t[:, 0]], 1) / np.maximum(np.linalg.norm(t, axis=1, keepdims=True), 1e-6)
            ix = np.clip((p[:, 0] * 4).astype(int), 0, W * 4 - 1)
            iy = np.clip((p[:, 1] * 4).astype(int), 0, H * 4 - 1)
            n = len(p)
            taper = np.minimum(1.0, np.minimum(np.arange(n), n - 1 - np.arange(n)) / 6.0)
            p = p + nrm * (wob[iy, ix] * 2.0 * WOBBLE * taper)[:, None]
        return p.tolist()

    return [("region" if k else "province", pr, smooth(pts)) for k, pr, pts in lines]


def render_preview(pid, provs, lines):
    """Two views to judge the shapes by eye: preview.png, each province softly filled with its own muted colour
    (settlements warmer, wilderness paler and greener) over the registered paper map and clipped to the true coast,
    with the smooth borders drawn on top (thin between provinces, bold between regions); preview_crop.jpg, the middle
    at full size; preview_coast.jpg, a coast at full size."""
    far_path = os.path.join(ROOT, "design/map/continent-11/art/far/far_paper_3x_reg.png")
    if not os.path.exists(far_path):
        far_path = os.path.join(ROOT, "design/map/continent-11/art/far/far_paper_3x.png")
    far = Image.open(far_path).convert("RGB")
    H, W = pid.shape
    SX, SY = far.width / W, far.height / H
    rng = np.random.default_rng(3)
    n = len(provs)
    pal = np.zeros((n + 1, 3), np.float32)
    for p in provs:
        if p["seed_kind"] == "wilderness":
            base = np.array([150, 165, 120]) + rng.integers(-18, 18, 3)
        else:
            base = np.array([[196, 120, 80], [90, 130, 170], [200, 170, 90], [150, 100, 150], [110, 160, 120]][p["id"] % 5]) + rng.integers(-22, 22, 3)
        pal[p["id"]] = np.clip(base, 0, 255)
    from PIL import ImageFilter
    tint = Image.fromarray(pal[pid].astype(np.uint8)).resize(far.size, Image.NEAREST).filter(ImageFilter.GaussianBlur(SX * 0.6))
    fw = np.asarray(Image.open(os.path.join(ROOT, "design/map/continent-11/base/fine_water.png")))
    land = Image.fromarray((((fw & 3) == 0) * 255).astype(np.uint8)).resize(far.size, Image.BILINEAR)
    # near the coast the painting decides: where it shows water (the pale blue wash), no tint, so a small island the
    # model painted in a slightly different shape still keeps its tint on its own painted land
    fa = np.asarray(far).astype(np.float32)
    bluish = (fa[..., 2] >= fa[..., 0] - 4) & (fa.mean(-1) > 140)
    soft = np.asarray(land.filter(ImageFilter.BoxBlur(int(SX * 3)))).astype(np.float32) / 255.0
    band = (soft > 0.02) & (soft < 0.98)
    lm = np.asarray(land).astype(np.float32)
    lm = np.where(band & bluish, 0.0, lm)
    land = Image.fromarray(lm.astype(np.uint8)).filter(ImageFilter.GaussianBlur(1.2))
    img = Image.composite(Image.blend(far, tint, 0.45), far, land)
    # borders, supersampled 2x for clean edges, clipped to the true land
    k = 2
    layers = {"province": Image.new("L", (far.width * k, far.height * k), 0), "region": Image.new("L", (far.width * k, far.height * k), 0)}
    draws = {key: ImageDraw.Draw(im) for key, im in layers.items()}
    for key, _pr, pts in lines:
        xy = [(x * SX * k, y * SY * k) for x, y in pts]
        if len(xy) >= 2:
            draws[key].line(xy, fill=255, width=int(2 * k) if key == "province" else int(5 * k), joint="curve")
    land_k = land.point(lambda v: 255 if v > 90 else 0)
    for key, col in (("province", (52, 34, 20)), ("region", (26, 16, 8))):
        a = layers[key].resize(far.size, Image.LANCZOS)
        a = Image.fromarray((np.asarray(a).astype(np.float32) * (np.asarray(land_k) / 255.0) * (0.7 if key == "province" else 0.95)).astype(np.uint8))
        img = Image.composite(Image.new("RGB", far.size, col), img, a)
    d = ImageDraw.Draw(img)
    for p in provs:
        cx, cy = p["centre"]
        c = (140, 25, 25) if p["seed_kind"] != "wilderness" else (50, 90, 40)
        r = 5 if p["seed_kind"] != "wilderness" else 3
        d.ellipse([(cx + 0.5) * SX - r, (cy + 0.5) * SY - r, (cx + 0.5) * SX + r, (cy + 0.5) * SY + r], fill=c)
    img.save(os.path.join(OUT, "preview.png"))
    img.resize((img.width // 2, img.height // 2), Image.LANCZOS).save(os.path.join(OUT, "preview_half.jpg"), quality=88)
    w2, h2 = img.width // 2, img.height // 2
    img.crop((w2 - 900, h2 - 560, w2 + 900, h2 + 560)).save(os.path.join(OUT, "preview_crop.jpg"), quality=90)
    img.crop((int(img.width * 0.08), int(img.height * 0.28), int(img.width * 0.08) + 1400, int(img.height * 0.28) + 900)).save(
        os.path.join(OUT, "preview_coast.jpg"), quality=90)
    print(os.path.join(OUT, "preview.png"))


if __name__ == "__main__":
    main("--render" in sys.argv)
