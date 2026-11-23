"""Provinces, second cut (user, 2026-11-23 night: "smaller provinces, and province shapes that follow rivers and
ridges"). Same idea as provinces.py (each province grown outward by travel cost inside its region, never crossing a
region border), with three changes:

- smaller and more even: besides the settlements, seeds are added at the land farthest (by cost) from any seed until
  every tile is within SEED_COST, then the added seeds move to their province's middle and everything regrows
  (RELAX passes), so wilderness provinces come out a similar size instead of as leftovers;
- rivers and ridges are barriers: stepping onto a drawn river (assets/map/terrain/river.bin, the lines the game
  draws) costs RIVER_IN, and climbing costs UP per metre (descending DOWN), so two growing provinces meet on a river
  or a crest instead of across it;
- the border lines are smoothed as before, with less wobble, and a stretch lying beside a river is snapped onto the
  river's own line.

Each province has a stable key (prov_<seat key> for a settlement province, prov_r<region>_<n> for wilderness numbered
in reading order inside its region), so lore and stats written against a key survive a re-cut that keeps the seats.

Run: python -I tools/design/map/provinces_v2.py [--render] [--game]
Writes design/map/continent-11/provinces-v2/ (provinces.json, province_ids.png, borders.json, preview*.jpg); with
--game also the game's assets/map/continent_11_provinces.json and assets/map/continent_11_province_ids.bin (u16 per
tile, 0 = water; the tile-to-province index Provinces rule 1 owes).
"""
import heapq
import json
import os
import sys
from collections import Counter, defaultdict

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import provinces as P  # noqa: E402

ROOT = P.ROOT
OUT = os.path.join(ROOT, os.environ.get("PROV_OUT", "design/map/continent-11/provinces-v2"))
SEED_KINDS = P.SEED_KINDS
SEED_COST = 21.0     # every land tile ends within this travel cost of a seed (grassland tile = 1): sets the size
RELAX = 2            # passes moving the added seeds to their province's middle
RIVER_IN = 30.0      # cost of stepping onto a drawn river from off it
RIVER_ALONG = 4.0    # cost of each step along a river (else a seat on a river snakes along it)
UP = 0.012           # cost per metre climbed
DOWN = 0.002         # cost per metre descended
NOISE = 0.25
MIN_TILES = 40       # a province smaller than this merges into its longest-border neighbour
WOBBLE = 0.16
SNAP = 0.9           # tiles: a border point this close to a river's line moves onto it


def drawn_rivers():
    r = np.fromfile(os.path.join(ROOT, "assets/map/terrain/river.bin"), np.uint8).reshape(2880, 4320)
    return r, r.reshape(360, 8, 540, 8).max(axis=(1, 3)) > 90


def grow(seeds, land, regn, cost, elev, river, W, H):
    owner = np.zeros((H, W), np.int32)
    dist = np.full((H, W), np.inf, np.float32)
    pq = []
    for i, (x, y) in enumerate(seeds):
        dist[y, x] = 0.0
        owner[y, x] = i + 1
        heapq.heappush(pq, (0.0, x, y, i + 1))
    while pq:
        d, x, y, o = heapq.heappop(pq)
        if d > dist[y, x] or owner[y, x] != o:
            continue
        r = regn[y, x]
        for dx, dy, step in P.STEPS:
            nx, ny = x + dx, y + dy
            if 0 <= nx < W and 0 <= ny < H and land[ny, nx] and regn[ny, nx] == r:
                dz = float(elev[ny, nx]) - float(elev[y, x])
                nd = d + step * 0.5 * (cost[y, x] + cost[ny, nx]) + (UP * dz if dz > 0 else -DOWN * dz)
                if river[ny, nx]:
                    nd += RIVER_IN if not river[y, x] else RIVER_ALONG
                if nd < dist[ny, nx]:
                    dist[ny, nx] = nd
                    owner[ny, nx] = o
                    heapq.heappush(pq, (nd, nx, ny, o))
    return owner, dist


def main(render, game):
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    rules = json.load(open(os.path.join(ROOT, "assets/data/travel_rules.json"), encoding="utf-8"))
    meta = json.load(open(os.path.join(ROOT, "design/map/continent-11/base/meta.json"), encoding="utf-8"))
    W, H, L = P.read_grid(os.path.join(ROOT, cont["grid_file"].replace("res://", "")))
    regn = L["REGN"].astype(np.int32)
    main_b = L["MAIN"].astype(np.int32)
    road = L["ROAD"].astype(np.int32)
    elev = L["ELEV"].astype(np.float32)
    names = {int(k): str(v) for k, v in meta["legend"]["biome_ids"].items()}
    bc = rules["biome_cost"]
    cost = np.ones((H, W), np.float32)
    for bid, name in names.items():
        cost[main_b == bid] = float(bc.get(name.lower().replace(" ", "_"), 1.5))
    cost = np.where(road > 0, cost * float(rules["road_terrain_share"]), cost)
    rng = np.random.default_rng(11)
    coarse = rng.random((H // 12 + 2, W // 12 + 2)).astype(np.float32)
    wob = np.asarray(Image.fromarray((coarse * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC)).astype(np.float32) / 255.0
    cost = cost * (1.0 + NOISE * (wob - 0.5) * 2.0)
    river_px, river = drawn_rivers()
    land = (regn > 0) & (main_b != P.LAKE_ID) & (main_b != P.SEA_ID)

    seat = []   # settlement seeds (fixed): (x, y, place)
    for p in cont["places"]:
        if p["kind"] in SEED_KINDS:
            x, y = p["tile"]
            if land[y, x]:
                seat.append((x, y, p))
    pts = [(x, y) for x, y, _ in seat]
    owner, dist = grow(pts, land, regn, cost, elev, river, W, H)
    extra = []
    while True:   # farthest-point seeding to SEED_COST
        far = np.where(land, np.where(np.isinf(dist), 1e9, dist), -1.0)
        far_ok = np.where(river, -1.0, far)   # an added seed never sits on a river (it would own both banks)
        y, x = np.unravel_index(np.argmax(far_ok), far_ok.shape)
        if far_ok[y, x] <= SEED_COST:   # river tiles are left to whoever reaches them
            break
        extra.append((int(x), int(y)))
        o2, d2 = grow([(int(x), int(y))], land, regn, cost, elev, river, W, H)
        better = d2 < dist
        dist = np.where(better, d2, dist)
    for _ in range(RELAX):   # the added seeds move to the middle of what they hold
        owner, dist = grow(pts + extra, land, regn, cost, elev, river, W, H)
        moved = []
        for i, (x, y) in enumerate(extra):
            ys, xs = np.nonzero(owner == len(pts) + i + 1)
            if len(xs) == 0:
                continue
            cx, cy = xs.mean(), ys.mean()
            dd = (xs - cx) ** 2 + (ys - cy) ** 2 + np.where(river[ys, xs], 1e6, 0.0)   # never onto a river
            k = int(np.argmin(dd))   # the held tile nearest the middle
            moved.append((int(xs[k]), int(ys[k])))
        extra = moved
    seeds = pts + extra
    # FINAL_UP (environment): the last growth may climb at a different cost than the seeding did, so a stronger ridge
    # barrier can be tried on the same seeds (the same provinces, keyed the same) without moving them
    global UP, DOWN
    seed_up, seed_down = UP, DOWN
    UP = float(os.environ.get("FINAL_UP", UP))
    DOWN = float(os.environ.get("FINAL_DOWN", DOWN))
    owner, dist = grow(seeds, land, regn, cost, elev, river, W, H)
    UP, DOWN = seed_up, seed_down
    kind = [s[2]["kind"] for s in seat] + ["wilderness"] * len(extra)
    seed_place = [s[2] for s in seat] + [None] * len(extra)
    # tiny provinces merge into the neighbour with the longest shared border (a settlement keeps its province)
    skip = set()
    while True:
        sizes = Counter(owner[land].tolist())
        small = [o for o, n in sizes.items() if n < MIN_TILES and o not in skip]
        if not small:
            break
        o = min(small, key=lambda k: sizes[k])
        m = owner == o
        border = Counter()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            sh = np.roll(np.roll(owner, dy, 0), dx, 1)
            b = sh[m & land & (np.roll(np.roll(land, dy, 0), dx, 1))]
            for v in b[(b != o) & (b != 0)].tolist():
                border[v] += 1
        if not border:
            skip.add(o)
            continue
        into = border.most_common(1)[0][0]
        if seed_place[o - 1] is not None and seed_place[into - 1] is None:
            owner[owner == into] = o
        elif seed_place[o - 1] is not None and seed_place[into - 1] is not None:
            skip.add(o)   # two settlements: both keep their province however small
        else:
            owner[owner == o] = into
    ids = sorted(set(owner[land].tolist()))
    # stable keys: settlement provinces by their seat's key, wilderness by region and reading order
    keyed = []
    for o in ids:
        ys, xs = np.nonzero(owner == o)
        sp = seed_place[o - 1]
        r = int(regn[ys[0], xs[0]])
        keyed.append((o, sp, r, float(ys.mean()), float(xs.mean())))
    wild_n = defaultdict(int)
    order = sorted(keyed, key=lambda k: (k[2], round(k[3] / 8), k[4]))
    key_of = {}
    for o, sp, r, cy, cx in order:
        if sp is not None:
            key_of[o] = "prov_" + str(sp.get("key") or ("p%d" % sp["id"]))
        else:
            wild_n[r] += 1
            key_of[o] = "prov_r%d_%d" % (r, wild_n[r])
    order_ids = sorted(ids, key=lambda o: (key_of[o].startswith("prov_r"), key_of[o]))
    remap = {o: i + 1 for i, o in enumerate(order_ids)}
    pid = np.zeros((H, W), np.uint16)
    for o, i in remap.items():
        pid[owner == o] = i
    neigh = defaultdict(Counter)
    for a, b in ((pid[:, :-1], pid[:, 1:]), (pid[:-1, :], pid[1:, :])):
        m = (a > 0) & (b > 0) & (a != b)
        for u, v in zip(a[m].tolist(), b[m].tolist()):
            neigh[u][v] += 1
            neigh[v][u] += 1
    places_in = defaultdict(list)
    for p in cont["places"]:
        x, y = p["tile"]
        if 0 <= x < W and 0 <= y < H and pid[y, x] > 0:
            places_in[int(pid[y, x])].append(p["id"])
    provs = []
    for o in order_ids:
        i = remap[o]
        ys, xs = np.nonzero(pid == i)
        sp = seed_place[o - 1]
        mix = Counter(main_b[ys, xs].tolist())
        provs.append({"id": i, "key": key_of[o], "region": int(regn[ys[0], xs[0]]),
                      "seed_place": sp["id"] if sp else None, "seed_kind": kind[o - 1], "name": sp["name"] if sp else "",
                      "tiles": int(len(xs)), "centre": [int(round(xs.mean())), int(round(ys.mean()))],
                      "places": places_in[i], "river_tiles": int(river[ys, xs].sum()),
                      "elev_mean": round(float(elev[ys, xs].mean()), 1), "elev_max": round(float(elev[ys, xs].max()), 1),
                      "coast": bool(((np.roll(land, 1, 0) == 0) | (np.roll(land, -1, 0) == 0) | (np.roll(land, 1, 1) == 0) | (np.roll(land, -1, 1) == 0))[ys, xs].any()),
                      "neighbours": [{"province": int(k), "border_tiles": int(v)} for k, v in sorted(neigh[i].items())],
                      "land": {names.get(k, str(k)): round(v / len(xs), 3) for k, v in mix.most_common(4)}})
    os.makedirs(OUT, exist_ok=True)
    json.dump({"_doc": "Province proposal v2 (tools/design/map/provinces_v2.py, 2026-11-23 night): smaller, grown by travel "
                       "cost with rivers and ridges as barriers; keys are stable (prov_<seat key>, prov_r<region>_<n>).",
               "params": {"seed_cost": SEED_COST, "relax": RELAX, "river_in": RIVER_IN, "river_along": RIVER_ALONG, "up": UP, "down": DOWN,
                          "min_tiles": MIN_TILES, "wobble": WOBBLE, "snap": SNAP},
               "provinces": provs}, open(os.path.join(OUT, "provinces.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    Image.fromarray(pid).save(os.path.join(OUT, "province_ids.png"))
    old_w = P.WOBBLE
    P.WOBBLE = WOBBLE
    try:
        lines = P.border_lines(pid, regn)
    finally:
        P.WOBBLE = old_w
    lines = [(k, pr, snap_to_rivers(pts, river_px)) for k, pr, pts in lines]
    json.dump({"lines": [{"kind": k, "a": pr[0], "b": pr[1], "points": [[round(x, 2), round(y, 2)] for x, y in pts]}
                         for k, pr, pts in lines]}, open(os.path.join(OUT, "borders.json"), "w", encoding="utf-8"))
    sizes = sorted(p["tiles"] for p in provs)
    by_kind = Counter(p["seed_kind"] for p in provs)
    print("provinces %d (%s); tiles: min %d, median %d, max %d" % (
        len(provs), ", ".join("%s %d" % kv for kv in by_kind.most_common()), sizes[0], sizes[len(sizes) // 2], sizes[-1]))
    if game:
        g = {"_doc": "Provinces of continent 11, v2 (tools/design/map/provinces_v2.py, 2026-11-23 night, branch provinces-v2): "
                     "smaller, rivers and ridges as barriers, stable keys; the tile index is continent_11_province_ids.bin "
                     "(u16 per tile, row-major 540 x 360, 0 = water).",
             "provinces": [{"id": p["id"], "key": p["key"], "region": p["region"], "centre": p["centre"],
                            "seed_place": p["seed_place"], "kind": p["seed_kind"]} for p in provs],
             "lines": [{"a": pr[0], "b": pr[1], "points": [round(v, 2) for xy in pts for v in xy]} for k, pr, pts in lines]}
        json.dump(g, open(os.path.join(ROOT, "assets/map/continent_11_provinces.json"), "w", encoding="utf-8"), separators=(",", ":"))
        pid.astype("<u2").tofile(os.path.join(ROOT, "assets/map/continent_11_province_ids.bin"))
        print("game copies written")
    if render:
        old = P.OUT
        P.OUT = OUT
        try:
            P.render_preview(pid, provs, lines)
        finally:
            P.OUT = old


def snap_to_rivers(pts, river_px):
    """Moves each point within SNAP tiles of a drawn river's line onto the line's strongest pixel nearby (rivers.bin
    is 8 px per tile), so a border along a river sits on it, not half a tile beside it."""
    r = int(SNAP * 8)
    H8, W8 = river_px.shape
    out = []
    for x, y in pts:
        cx, cy = int(x * 8), int(y * 8)
        x0, y0, x1, y1 = max(0, cx - r), max(0, cy - r), min(W8, cx + r + 1), min(H8, cy + r + 1)
        win = river_px[y0:y1, x0:x1]
        if win.size and win.max() > 150:
            yy, xx = np.nonzero(win > 150)
            d = (xx + x0 - x * 8) ** 2 + (yy + y0 - y * 8) ** 2
            k = int(np.argmin(d))
            out.append([(xx[k] + x0 + 0.5) / 8.0, (yy[k] + y0 + 0.5) / 8.0])
        else:
            out.append([x, y])
    # a light smoothing after the snap so the moved points do not zigzag
    if len(out) >= 3:
        a = np.array(out, np.float32)
        a[1:-1] = a[1:-1] * 0.5 + (a[:-2] + a[2:]) * 0.25
        out = a.tolist()
    return out


if __name__ == "__main__":
    main("--render" in sys.argv, "--game" in sys.argv)
