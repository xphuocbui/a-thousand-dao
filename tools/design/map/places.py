"""Place settlements, mines and famous wild sites, then draw roads, sea lanes and teleport arrays (Travel & Map rules 6,
9, 11, 20, 33; Sects rules 1-3).

Reads the saved map (regions.png, base/ index images, politics_proposal.json, minor_sects.json) and a hand-edited
places_proposal.json (counts, markets, arrays) and place_names.json (names by kind and tile, and a pool of town and
village names by the kind of land). Runs in seconds.

How it works:
- **Livability** per land tile: the biome's base (grassland best, glacier and volcano worst) times climate (mild
  temperature, enough rain), height and relief, plus water: a river (more where rivers gather), a coast, a lakeshore,
  most at a river mouth.
- **Cities**: at most one a region. How many each great sect has is set by hand (`cities_by_sect`); without it each
  tier-1 sect gets at least two and each tier-2 sect one, the rest by livable land (largest remainder). In each chosen region the city takes the most livable tile, at least `city_gap` from other cities.
- **Markets** (phường thị): one beside each listed sect seat, on the most livable tile `market_ring` tiles out.
- **Towns and villages**: per region by livable land (at least 1 town and 2 villages a region), greedily on the most
  livable tiles with spacing.
- **Mines**: on the biggest ore-vein clusters (at least one in each region with a big cluster), a big cluster
  carrying one per `ore_tiles_per_mine` ore tiles.
- **Famous wild sites**: the highest peaks (isolated summits), the biggest lakes, the biggest islands without a
  settlement, the deepest forests, the deepest river gorges and the biggest volcanoes.
- **Roads**: trunk roads join cities, markets and great seats (a spanning tree on distance, plus links where the tree
  makes a long detour), routed over a terrain cost (relief, height, swamp, jungle, crossing a river) that is cheaper on
  roads already built, so roads merge. Then every other place takes a branch road to the nearest road.
- **Sea lanes** join ports (settlements within 2 tiles of the sea): cities, markets and island towns each to their
  nearest two such ports by a coast-hugging sea route, and every inhabited island to another landmass, so all connect.
- **Teleport arrays**: in the first city of each great sect.
- **Holders**: a town, village or mine within `minor_domain_tiles` of a minor sect's seat in the same territory is that
  vassal's site, and a vassal with none takes its nearest town, village or mine; every other settlement and mine is
  the great sect's. Wild sites have no holder.

It writes <map>/places.json (every place with its tile, region, holder, land, port, river and names), <map>/roads.png
(1 road, 2 trunk road, 3 sea lane per tile) and <map>/places.jpg, and prints the map check. It reports; it does not
judge.

Run:  python -I tools/design/map/places.py --map design/map/continent-11
"""

import argparse
import heapq
import json
import math
import os

from PIL import Image, ImageDraw, ImageFont

N4 = [(0, -1), (-1, 0), (1, 0), (0, 1)]
N8 = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
SQ2 = math.sqrt(2.0)
INF = float("inf")

PP = {
    "city_gap": 34,
    "town_gap": 12, "village_gap": 6, "seat_gap": 6, "mine_gap": 8, "site_gap": 14,
    "cities_min_by_tier": {"1": 2, "2": 1},  # each great sect has at least this many cities
    "market_ring": (3, 9),           # tiles from the seat
    "peak_radius": 18,               # a famous peak is the highest tile within this radius
    "peak_min_km": 2.2,
    "island_tiles": (12, 2500),      # landmass size for a famous island
    "lake_min_tiles": 4,
    "forest_min_tiles": 250,
    "ore_cluster_min": 6,
    "ore_tiles_per_mine": 40,        # a cluster carries one mine per this many ore tiles
    "road_reuse": 0.3,               # cost factor on a tile that already has a road
    "trunk_detour": 1.8,             # add a trunk link when the tree path is this many times the straight line
    "trunk_link_max": 70,            # tiles; longest extra trunk link
    "lanes_per_port": 2,
    "lane_open_sea": 0.25,           # sea lane cost per tile of distance from land (up to 15), so lanes hug coasts
    "lane_min_tiles": 10,            # no lane between ports closer than this
    "lane_max_cost": 160,            # a port looks this far for its lane partners
    "cold_name_c": 8.0,              # a town or village below this mean temperature may take a cold name
    "km_per_tile": 25.0,
    "scale": 3,
}

B = {"temperate_forest": 0, "bamboo_forest": 1, "jungle": 2, "grassland": 3, "steppe": 4, "desert": 5,
     "salt_flats": 6, "badlands": 7, "swamp": 8, "mangrove": 9, "highland": 10, "high_mountain": 11,
     "karst": 12, "volcano": 13, "tundra": 14, "glacier": 15, "miasma": 16, "lake": 17, "sea": 18}
BNAME = {v: k.replace("_", " ") for k, v in B.items()}
BASE_LIVE = {0: 0.7, 1: 0.75, 2: 0.4, 3: 1.0, 4: 0.6, 5: 0.12, 6: 0.05, 7: 0.2, 8: 0.25, 9: 0.3, 10: 0.45,
             11: 0.06, 12: 0.35, 13: 0.0, 14: 0.18, 15: 0.0, 16: 0.0, 17: 0.0, 18: 0.0}
ROAD_EXTRA = {8: 3.0, 9: 3.0, 2: 2.0, 11: 2.5, 15: 25.0, 13: 6.0, 12: 1.5, 5: 0.8, 7: 1.0, 14: 0.8}
FEAT = {"lava": 1, "hot_spring": 2, "ice_field": 4, "river": 8, "lake": 16, "ore_vein": 32}
KIND_HV = {"city": "thành", "market": "phường thị", "town": "trấn", "village": "thôn", "mine": "khoáng mạch",
           "peak": "sơn", "lake": "hồ", "island": "đảo", "forest": "lâm", "gorge": "cốc", "volcano": "sơn",
           "great_seat": "sect seat", "minor_seat": "sect seat"}
SETTLED = ("city", "market", "town", "village")


def pixels(path):
    im = Image.open(path)
    flat = getattr(im, "get_flattened_data", None) or im.getdata
    return list(flat()), im.size


class Map:
    def __init__(self, d):
        self.d = d
        self.rid, (W, H) = pixels(os.path.join(d, "regions.png"))
        self.W, self.H = W, H
        base = os.path.join(d, "base")
        self.b, _ = pixels(os.path.join(base, "biome.png"))
        self.h = [(v - 10000) / 1000.0 for v in pixels(os.path.join(base, "elevation.png"))[0]]
        self.t = [v / 2.0 - 50.0 for v in pixels(os.path.join(base, "temperature.png"))[0]]
        self.rain, _ = pixels(os.path.join(base, "rainfall.png"))
        self.f, _ = pixels(os.path.join(base, "features.png"))
        with open(os.path.join(d, "politics_proposal.json"), encoding="utf-8") as fh:
            self.greats = json.load(fh)["great_sects"]
        with open(os.path.join(d, "sects_proposal.json"), encoding="utf-8") as fh:
            col = {g["key"]: g["colour"] for g in json.load(fh)["great_sects"]}
        for g in self.greats:
            g["colour"] = col[g["key"]]
        with open(os.path.join(d, "minor_sects.json"), encoding="utf-8") as fh:
            self.minors = json.load(fh)["minor_sects"]
        with open(os.path.join(d, "regions.json"), encoding="utf-8") as fh:
            self.regs = {o["id"]: o for o in json.load(fh)["regions"]}
        self.sect_of_region = {r: k for k, g in enumerate(self.greats) for r in g["regions"]}
        self.terr = [self.sect_of_region.get(r, -1) if r else -1 for r in self.rid]
        self.derive()

    def idx(self, x, y):
        return y * self.W + x

    def nb(self, i, ns=N8):
        W, H = self.W, self.H
        x, y = i % W, i // W
        for ox, oy in ns:
            nx, ny = x + ox, y + oy
            if 0 <= nx < W and 0 <= ny < H:
                yield ny * W + nx

    def derive(self):
        W, H, n = self.W, self.H, self.W * self.H
        self.land = [r > 0 for r in self.rid]
        self.lake = [self.b[i] == B["lake"] for i in range(n)]
        self.dry = [self.land[i] and not self.lake[i] for i in range(n)]
        self.river = [self.dry[i] and bool(self.f[i] & FEAT["river"]) for i in range(n)]
        self.coast = [self.dry[i] and any(not self.land[j] for j in self.nb(i)) for i in range(n)]
        self.shore = [self.dry[i] and any(self.lake[j] for j in self.nb(i)) for i in range(n)]
        self.mouth = [self.river[i] and self.coast[i] for i in range(n)]
        self.relief = [0.0] * n
        self.rivn = [0] * n
        for i in range(n):
            if not self.dry[i]:
                continue
            hs = [self.h[j] for j in self.nb(i) if self.land[j]] + [self.h[i]]
            self.relief[i] = max(hs) - min(hs)
            x, y = i % W, i // W
            self.rivn[i] = sum(1 for yy in range(max(0, y - 2), min(H, y + 3)) for xx in range(max(0, x - 2), min(W, x + 3))
                               if self.river[yy * W + xx])
        self.live = [0.0] * n
        for i in range(n):
            if not self.dry[i]:
                continue
            base = BASE_LIVE.get(self.b[i], 0.0)
            tf = math.exp(-((self.t[i] - 17.0) / 13.0) ** 2)
            rf = min(1.0, max(0.0, (self.rain[i] - 150) / 550.0)) * (0.8 if self.rain[i] > 2600 else 1.0)
            hf = 1.0 - min(1.0, max(0.0, self.h[i]) / 2.6)
            ef = 1.0 - min(0.7, self.relief[i] / 1.4)
            water = (0.35 * self.river[i] + 0.25 * min(self.rivn[i], 10) / 10.0 + 0.3 * self.coast[i]
                     + 0.25 * self.shore[i] + 0.4 * self.mouth[i])
            self.live[i] = (base * (0.4 + 0.6 * rf) + water * (0.3 + 0.7 * min(1.0, base * 1.5))) * tf * hf * ef
        # landmasses (8-neighbour over land)
        self.mass_id = [-1] * n
        self.mass_size = []
        for i0 in range(n):
            if self.land[i0] and self.mass_id[i0] < 0:
                k = len(self.mass_size)
                q = [i0]
                self.mass_id[i0] = k
                cnt = 0
                while q:
                    i = q.pop()
                    cnt += 1
                    for j in self.nb(i):
                        if self.land[j] and self.mass_id[j] < 0:
                            self.mass_id[j] = k
                            q.append(j)
                self.mass_size.append(cnt)
        self.main_mass = max(range(len(self.mass_size)), key=lambda k: self.mass_size[k])
        # road cost
        self.cost = [INF] * n
        for i in range(n):
            if self.dry[i]:
                self.cost[i] = (1.0 + 3.0 * min(1.0, self.relief[i] / 1.0) + 2.0 * min(1.0, max(0.0, self.h[i]) / 2.5)
                                + ROAD_EXTRA.get(self.b[i], 0.0) + (2.0 if self.river[i] else 0.0))


def dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


class Placer:
    def __init__(self, M, prop):
        self.M, self.prop = M, prop
        self.places = []
        for k, g in enumerate(M.greats):
            self.add("great_seat", tuple(g["seat_tile"]), key=g["key"], name_hv=g["name_hv"], name_han=g.get("name_han"))
        for m in M.minors:
            self.add("minor_seat", tuple(m["seat_tile"]), key=m["key"], name_hv=m["name_hv"], name_han=m.get("name_han"),
                     lord=m["lord"])

    def add(self, kind, xy, **kw):
        M = self.M
        i = M.idx(*xy)
        p = {"kind": kind, "tile": list(xy), "region": M.rid[i]}
        p.update(kw)
        self.places.append(p)
        return p

    def near(self, xy, kinds=None):
        best = INF
        for p in self.places:
            if kinds is None or p["kind"] in kinds:
                best = min(best, dist(xy, p["tile"]))
        return best

    def ok(self, i, gaps):
        """gaps: {kind or tuple of kinds: min tiles}"""
        M = self.M
        xy = (i % M.W, i // M.W)
        for kinds, g in gaps.items():
            ks = kinds if isinstance(kinds, tuple) else (kinds,)
            if self.near(xy, ks) < g:
                return False
        return True

    def alloc(self, total, weights, floor):
        """Largest remainder with a floor per key (one number, or a dict by key)."""
        keys = list(weights)
        out = {k: (floor[k] if isinstance(floor, dict) else floor) for k in keys}
        rest = total - sum(out.values())
        tw = sum(weights.values()) or 1.0
        raw = {k: rest * weights[k] / tw for k in keys}
        for k in keys:
            out[k] += int(raw[k])
        left = total - sum(out.values())
        for k in sorted(keys, key=lambda k: -(raw[k] - int(raw[k])))[:left]:
            out[k] += 1
        return out

    def region_mass(self):
        M = self.M
        mass = {r: 0.0 for r in M.regs}
        for i in range(M.W * M.H):
            if M.dry[i]:
                mass[M.rid[i]] += M.live[i]
        return mass

    def best_in(self, region, gaps, extra=None, allow=None):
        M = self.M
        best, bs = None, -INF
        for i in range(M.W * M.H):
            if M.rid[i] != region or not M.dry[i] or M.b[i] in (B["glacier"], B["volcano"]):
                continue
            if allow and not allow(i):
                continue
            s = M.live[i] + (extra(i) if extra else 0.0)
            if s > bs and self.ok(i, gaps):
                best, bs = i, s
        return best

    def cities(self, n, by_sect=None):
        M = self.M
        mass = self.region_mass()
        terr_mass = {k: sum(mass[r] for r in g["regions"]) for k, g in enumerate(M.greats)}
        if by_sect:                                                              # set by hand
            per = {k: by_sect[g["key"]] for k, g in enumerate(M.greats)}
        else:
            per = self.alloc(n, terr_mass, {k: PP["cities_min_by_tier"][str(g["tier"])] for k, g in enumerate(M.greats)})
        for k, g in enumerate(M.greats):
            per[k] = min(per[k], len(g["regions"]))
        while sum(per.values()) < n:                                            # spill over a capped sect
            k = max((k for k in per if per[k] < len(M.greats[k]["regions"])), key=lambda k: terr_mass[k] / (per[k] + 1))
            per[k] += 1
        first = {}
        for k, g in enumerate(M.greats):
            regs = sorted(g["regions"], key=lambda r: -mass[r])[:per[k]]
            for r in regs:
                i = self.best_in(r, {"city": PP["city_gap"], ("great_seat", "minor_seat"): PP["seat_gap"] + 2},
                                 extra=lambda i: 0.3 * M.mouth[i] + 0.15 * (M.river[i] and M.rivn[i] >= 6))
                if i is None:
                    i = self.best_in(r, {"city": PP["city_gap"] * 0.6, ("great_seat", "minor_seat"): PP["seat_gap"]})
                p = self.add("city", (i % M.W, i // M.W), sect=g["key"])
                if k not in first or M.live[i] > first[k][1]:
                    first[k] = (p, M.live[i])
        for k, (p, _) in first.items():
            p["array"] = True

    def markets(self, keys):
        M = self.M
        seats = {p["key"]: p for p in self.places if p["kind"] in ("great_seat", "minor_seat")}
        lo, hi = PP["market_ring"]
        for key in keys:
            s = seats[key]
            sx, sy = s["tile"]
            terr = M.terr[M.idx(sx, sy)]
            best, bs = None, -INF
            for y in range(max(0, sy - hi), min(M.H, sy + hi + 1)):
                for x in range(max(0, sx - hi), min(M.W, sx + hi + 1)):
                    i = M.idx(x, y)
                    dd = dist((x, y), (sx, sy))
                    if not (lo <= dd <= hi) or not M.dry[i] or M.terr[i] != terr:
                        continue
                    if not self.ok(i, {("city", "market"): 8, ("great_seat", "minor_seat"): lo}):
                        continue
                    if M.live[i] > bs:
                        best, bs = i, M.live[i]
            self.add("market", (best % M.W, best // M.W), beside=key)

    def spread(self, kind, total, floor, gaps):
        M = self.M
        mass = self.region_mass()
        per = self.alloc(total, mass, floor)
        cand = {r: sorted((i for i in range(M.W * M.H) if M.rid[i] == r and M.dry[i]
                           and M.b[i] not in (B["glacier"], B["volcano"])), key=lambda i: -M.live[i]) for r in M.regs}
        for r in sorted(M.regs):
            got = 0
            for i in cand[r]:
                if got >= per[r]:
                    break
                if self.ok(i, gaps):
                    self.add(kind, (i % M.W, i // M.W))
                    got += 1

    def mines(self, n):
        M = self.M
        ore = [M.dry[i] and bool(M.f[i] & FEAT["ore_vein"]) for i in range(M.W * M.H)]
        seen = [False] * (M.W * M.H)
        clusters = []
        for i0 in range(M.W * M.H):
            if ore[i0] and not seen[i0]:
                comp, q = [], [i0]
                seen[i0] = True
                while q:
                    i = q.pop()
                    comp.append(i)
                    x, y = i % M.W, i // M.W
                    for oy in range(-2, 3):
                        for ox in range(-2, 3):
                            nx, ny = x + ox, y + oy
                            if 0 <= nx < M.W and 0 <= ny < M.H:
                                j = ny * M.W + nx
                                if ore[j] and not seen[j]:
                                    seen[j] = True
                                    q.append(j)
                if len(comp) >= PP["ore_cluster_min"]:
                    clusters.append(comp)
        clusters.sort(key=lambda c: -len(c))
        chosen, regs_done = [], set()
        for c in clusters:                                                       # first the biggest in each region
            r = max(set(M.rid[i] for i in c), key=lambda r: sum(1 for i in c if M.rid[i] == r))
            if r not in regs_done:
                regs_done.add(r)
                chosen.append(c)
        for c in clusters:
            if len(chosen) >= n:
                break
            if c not in chosen:
                chosen.append(c)
        chosen = sorted(chosen, key=lambda c: -len(c))
        placed = 0
        have = {}
        for rnd in range(1, 7):                                                  # big ore fields carry more mines
            for k, c in enumerate(chosen):
                if placed >= n:
                    break
                if have.get(k, 0) >= max(1, len(c) // PP["ore_tiles_per_mine"]) or have.get(k, 0) >= rnd:
                    continue
                cx = sum(i % M.W for i in c) / len(c)
                cy = sum(i // M.W for i in c) / len(c)
                for i in sorted(c, key=lambda i: dist((i % M.W, i // M.W), (cx, cy))):
                    if self.ok(i, {("mine",): PP["mine_gap"], SETTLED + ("great_seat", "minor_seat"): 3}):
                        self.add("mine", (i % M.W, i // M.W), ore_tiles=len(c))
                        have[k] = have.get(k, 0) + 1
                        placed += 1
                        break

    def wild(self, counts):
        M = self.M
        n = M.W * M.H
        gap = {SETTLED + ("great_seat", "minor_seat", "mine"): 4,
               ("peak", "lake", "island", "forest", "gorge", "volcano"): PP["site_gap"]}
        # peaks: highest tile within peak_radius, not a volcano
        R = PP["peak_radius"]
        peaks = []
        order = sorted((i for i in range(n) if M.dry[i] and M.h[i] >= PP["peak_min_km"]), key=lambda i: -M.h[i])
        for i in order:
            x, y = i % M.W, i // M.W
            if any(dist((x, y), (p % M.W, p // M.W)) < R for p in peaks):
                continue
            if M.b[i] == B["volcano"]:
                continue
            peaks.append(i)
        per_region = {}
        got = 0
        for i in peaks:
            if got >= counts["peak"]:
                break
            if per_region.get(M.rid[i], 0) >= 2 or not self.ok(i, gap):
                continue
            per_region[M.rid[i]] = per_region.get(M.rid[i], 0) + 1
            self.add("peak", (i % M.W, i // M.W), elevation_km=round(M.h[i], 2))
            got += 1
        # volcanoes: biggest volcano-biome clusters, at their highest tile
        for comp in self.comps(lambda i: M.b[i] == B["volcano"])[:counts["volcano"]]:
            i = max(comp, key=lambda i: M.h[i])
            self.add("volcano", (i % M.W, i // M.W), elevation_km=round(M.h[i], 2), tiles=len(comp))
        # lakes: biggest lake bodies, on the lake tile nearest the middle
        got = 0
        for comp in self.comps(lambda i: M.lake[i]):
            if got >= counts["lake"] or len(comp) < PP["lake_min_tiles"]:
                break
            cx = sum(i % M.W for i in comp) / len(comp)
            cy = sum(i // M.W for i in comp) / len(comp)
            i = min(comp, key=lambda i: dist((i % M.W, i // M.W), (cx, cy)))
            if self.ok(i, {("lake",): PP["site_gap"]}):
                self.add("lake", (i % M.W, i // M.W), tiles=len(comp))
                got += 1
        # islands: biggest landmasses in range with no settlement or seat, at the most livable tile
        lo, hi = PP["island_tiles"]
        masses = sorted((k for k, s in enumerate(M.mass_size) if lo <= s <= hi), key=lambda k: -M.mass_size[k])
        got = 0
        for k in masses:
            if got >= counts["island"]:
                break
            if any(M.mass_id[M.idx(*p["tile"])] == k for p in self.places):
                continue
            tiles = [i for i in range(n) if M.mass_id[i] == k and M.dry[i]]
            if not tiles:
                continue
            i = max(tiles, key=lambda i: (M.live[i], M.h[i]))
            self.add("island", (i % M.W, i // M.W), tiles=M.mass_size[k])
            got += 1
        # forests: deepest tile of the biggest forest bodies
        forest = {B["temperate_forest"], B["bamboo_forest"], B["jungle"]}
        got = 0
        for comp in self.comps(lambda i: M.b[i] in forest):
            if got >= counts["forest"] or len(comp) < PP["forest_min_tiles"]:
                break
            cs = set(comp)
            edge = [i for i in comp if any(j not in cs for j in M.nb(i, N4))]
            dd = self.bfs(edge, lambda j: j in cs)
            for i in sorted(comp, key=lambda i: -dd[i]):
                if self.ok(i, gap):
                    self.add("forest", (i % M.W, i // M.W), biome=BNAME[M.b[i]], tiles=len(comp))
                    got += 1
                    break
        # gorges: river tiles sunk deepest below the land around them
        score = {}
        for i in range(n):
            if M.river[i]:
                x, y = i % M.W, i // M.W
                ring = [M.h[yy * M.W + xx] for yy in range(max(0, y - 3), min(M.H, y + 4))
                        for xx in range(max(0, x - 3), min(M.W, x + 4)) if M.land[yy * M.W + xx]]
                score[i] = sorted(ring)[-len(ring) // 4] - M.h[i]
        got = 0
        for i in sorted(score, key=lambda i: -score[i]):
            if got >= counts["gorge"]:
                break
            if self.ok(i, {**gap, ("gorge",): 40}):
                self.add("gorge", (i % M.W, i // M.W), depth_km=round(score[i], 2))
                got += 1

    def comps(self, test):
        M = self.M
        n = M.W * M.H
        seen = [False] * n
        out = []
        for i0 in range(n):
            if test(i0) and not seen[i0]:
                comp, q = [], [i0]
                seen[i0] = True
                while q:
                    i = q.pop()
                    comp.append(i)
                    for j in M.nb(i, N4):
                        if test(j) and not seen[j]:
                            seen[j] = True
                            q.append(j)
                out.append(comp)
        out.sort(key=lambda c: -len(c))
        return out

    def bfs(self, sources, inside):
        M = self.M
        d = [10 ** 9] * (M.W * M.H)
        q = list(sources)
        for i in q:
            d[i] = 0
        head = 0
        while head < len(q):
            i = q[head]; head += 1
            for j in M.nb(i, N4):
                if inside(j) and d[j] > d[i] + 1:
                    d[j] = d[i] + 1
                    q.append(j)
        return d


class Roads:
    def __init__(self, M):
        self.M = M
        self.road = [0] * (M.W * M.H)         # 1 road, 2 trunk
        self.lane = [0] * (M.W * M.H)
        self.segments = []                    # (kind, [tiles])

    def step_cost(self, i, j, diag):
        M = self.M
        c = M.cost[j]
        if c == INF:
            return INF
        if self.road[j]:
            c *= PP["road_reuse"]
        return c * (SQ2 if diag else 1.0)

    def route(self, a, targets):
        """Cheapest path from tile a to any tile in targets (a set). Returns the path or None."""
        M = self.M
        best = {a: 0.0}
        prev = {}
        pq = [(0.0, a)]
        while pq:
            c, i = heapq.heappop(pq)
            if c > best.get(i, INF):
                continue
            if i in targets and i != a:
                path = [i]
                while path[-1] != a:
                    path.append(prev[path[-1]])
                return path[::-1]
            x, y = i % M.W, i // M.W
            for ox, oy in N8:
                nx, ny = x + ox, y + oy
                if 0 <= nx < M.W and 0 <= ny < M.H:
                    j = ny * M.W + nx
                    sc = self.step_cost(i, j, ox and oy)
                    if sc == INF:
                        continue
                    nc = c + sc
                    if nc < best.get(j, INF):
                        best[j] = nc
                        prev[j] = i
                        heapq.heappush(pq, (nc, j))
        return None

    def build(self, places):
        M = self.M
        tile = lambda p: M.idx(*p["tile"])
        trunk = [p for p in places if p["kind"] in ("city", "market", "great_seat")]
        # spanning tree per landmass on straight distance
        edges = []
        for a in range(len(trunk)):
            for b in range(a + 1, len(trunk)):
                if M.mass_id[tile(trunk[a])] == M.mass_id[tile(trunk[b])]:
                    edges.append((dist(trunk[a]["tile"], trunk[b]["tile"]), a, b))
        edges.sort()
        parent = list(range(len(trunk)))

        def find(x):
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        tree = []
        adj = {k: [] for k in range(len(trunk))}
        for d, a, b in edges:
            ra, rb = find(a), find(b)
            if ra != rb:
                parent[ra] = rb
                tree.append((d, a, b))
                adj[a].append((b, d))
                adj[b].append((a, d))

        def tree_len(a, b):
            best = {a: 0.0}
            pq = [(0.0, a)]
            while pq:
                c, u = heapq.heappop(pq)
                if u == b:
                    return c
                for v, w in adj[u]:
                    if c + w < best.get(v, INF):
                        best[v] = c + w
                        heapq.heappush(pq, (c + w, v))
            return INF
        extra = []
        for d, a, b in edges:
            if d <= PP["trunk_link_max"] and (d, a, b) not in tree and tree_len(a, b) > PP["trunk_detour"] * d:
                extra.append((d, a, b))
                adj[a].append((b, d))
                adj[b].append((a, d))
        for d, a, b in sorted(tree + extra):
            path = self.route(tile(trunk[a]), {tile(trunk[b])})
            if path:
                self.lay(path, 2)
        # branches: every other place to the nearest road (or trunk place)
        others = [p for p in places if p["kind"] not in ("city", "market", "great_seat")]
        order = sorted(others, key=lambda p: ({"town": 0, "minor_seat": 1, "mine": 2, "village": 3}.get(p["kind"], 4)))
        for p in order:
            if p["kind"] in ("peak", "lake", "island", "forest", "gorge", "volcano"):
                continue                                                          # wild sites have no road
            i = tile(p)
            if self.road[i]:
                continue
            targets = {j for j in range(M.W * M.H) if self.road[j] and M.mass_id[j] == M.mass_id[i]}
            if not targets:
                continue                                                          # an island with no road yet
            path = self.route(i, targets)
            if path:
                self.lay(path, 1)
        # island settlements with no road: join them to each other
        for p in order:
            i = tile(p)
            if p["kind"] in SETTLED + ("minor_seat", "mine") and not self.road[i]:
                same = {tile(q) for q in places if q is not p and q["kind"] in SETTLED + ("minor_seat", "mine")
                        and M.mass_id[tile(q)] == M.mass_id[i]}
                same |= {j for j in range(M.W * M.H) if self.road[j] and M.mass_id[j] == M.mass_id[i]}
                if same:
                    path = self.route(i, same)
                    if path:
                        self.lay(path, 1)

    def lay(self, path, level):
        for i in path:
            self.road[i] = max(self.road[i], level)
        self.segments.append(("trunk" if level == 2 else "road", path))

    def lanes(self, places):
        """Sea lanes: cities, markets and island towns each to their nearest few such ports by sea, then every
        inhabited landmass to another landmass. A lane hugs the coast: open sea costs more the farther it is from land.
        """
        M = self.M
        n = M.W * M.H
        water = [not M.land[i] for i in range(n)]
        if not hasattr(self, "sea_cost"):
            sd = [0 if M.land[i] else 10 ** 9 for i in range(n)]
            q = [i for i in range(n) if M.land[i]]
            head = 0
            while head < len(q):
                i = q[head]; head += 1
                for j in M.nb(i):
                    if sd[j] > sd[i] + 1:
                        sd[j] = sd[i] + 1
                        q.append(j)
            self.sea_cost = [1.0 + PP["lane_open_sea"] * min(sd[i], 15) if water[i] else INF for i in range(n)]
        ports = [p for p in places if p["kind"] in SETTLED and p.get("port")]
        mass = lambda p: M.mass_id[M.idx(*p["tile"])]
        lane_port = lambda p: p["kind"] in ("city", "market") or (p["kind"] == "town" and mass(p) != M.main_mass)
        dock = {}
        for k, p in enumerate(ports):
            x, y = p["tile"]
            for oy in range(-2, 3):
                for ox in range(-2, 3):
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < M.W and 0 <= ny < M.H and water[ny * M.W + nx]:
                        dock.setdefault(ny * M.W + nx, set()).add(k)

        def search(k, want, limit):
            """Dijkstra over water from port k; returns [(cost, other port, path)] for ports passing want()."""
            starts = [j for j, ks in dock.items() if k in ks]
            best = {s: 0.0 for s in starts}
            prev = {s: None for s in starts}
            pq = [(0.0, s) for s in starts]
            heapq.heapify(pq)
            found, seen = [], set()
            while pq:
                c, i = heapq.heappop(pq)
                if c > best.get(i, INF) or c > limit:
                    continue
                for o in dock.get(i, ()):
                    if o != k and o not in seen and want(o):
                        seen.add(o)
                        path = [i]
                        while prev[path[-1]] is not None:
                            path.append(prev[path[-1]])
                        found.append((c, o, path))
                x, y = i % M.W, i // M.W
                for ox, oy in N8:
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < M.W and 0 <= ny < M.H:
                        j = ny * M.W + nx
                        sc = self.sea_cost[j] * (SQ2 if ox and oy else 1.0)
                        if sc < INF and c + sc < best.get(j, INF):
                            best[j] = c + sc
                            prev[j] = i
                            heapq.heappush(pq, (c + sc, j))
            return found
        links = {}
        for k, p in enumerate(ports):
            if not lane_port(p):
                continue
            got = 0
            for c, o, path in sorted(search(k, lambda o: lane_port(ports[o])
                                            and dist(ports[o]["tile"], p["tile"]) >= PP["lane_min_tiles"],
                                            PP["lane_max_cost"]), key=lambda t: t[0]):
                if got >= PP["lanes_per_port"]:
                    break
                links.setdefault((min(k, o), max(k, o)), path)
                got += 1
        # every inhabited landmass joined to another, from its best port
        rank = {"city": 0, "market": 1, "town": 2, "village": 3}
        parent = {}

        def find(x):
            parent.setdefault(x, x)
            while parent[x] != x:
                parent[x] = parent[parent[x]]
                x = parent[x]
            return x
        for (a, b) in links:
            parent[find(mass(ports[a]))] = find(mass(ports[b]))
        for mk in sorted(set(mass(p) for p in ports), key=lambda m: -M.mass_size[m]):
            if find(mk) == find(M.main_mass):
                continue
            here = sorted((k for k, p in enumerate(ports) if mass(p) == mk), key=lambda k: rank[ports[k]["kind"]])
            for k in here:
                res = sorted(search(k, lambda o: find(mass(ports[o])) != find(mk), INF), key=lambda t: t[0])
                if res:
                    c, o, path = res[0]
                    links.setdefault((min(k, o), max(k, o)), path)
                    parent[find(mk)] = find(mass(ports[o]))
                    break
        for key, path in links.items():
            for i in path:
                self.lane[i] = 1
            self.segments.append(("lane", path))
        return [(ports[a], ports[b]) for a, b in links]


def holders(M, places, domain):
    seats = {p["key"]: p for p in places if p["kind"] == "minor_seat"}
    for p in places:
        i = M.idx(*p["tile"])
        t = M.terr[i]
        g = M.greats[t] if t >= 0 else None
        p["territory"] = g["name_hv"] if g else None
        if p["kind"] in ("great_seat",):
            p["holder"] = p["name_hv"]
        elif p["kind"] == "minor_seat":
            p["holder"] = p["name_hv"]
        elif p["kind"] in ("town", "village", "mine"):
            best = None
            for s in seats.values():
                if M.terr[M.idx(*s["tile"])] == t:
                    d = dist(p["tile"], s["tile"])
                    if d <= domain and (best is None or d < best[0]):
                        best = (d, s)
            p["holder"] = best[1]["name_hv"] if best else (g["name_hv"] if g else None)
        elif p["kind"] in ("city", "market"):
            p["holder"] = g["name_hv"] if g else None
        else:
            p["holder"] = None
    for s in seats.values():                                                     # every vassal holds a site
        if any(p["holder"] == s["name_hv"] for p in places if p["kind"] != "minor_seat"):
            continue
        t = M.terr[M.idx(*s["tile"])]
        free = [p for p in places if p["kind"] in ("town", "village", "mine") and M.terr[M.idx(*p["tile"])] == t
                and p["holder"] == M.greats[t]["name_hv"]]
        if free:
            p = min(free, key=lambda p: dist(p["tile"], s["tile"]))
            p["holder"] = s["name_hv"]


def attach_names(places, names):
    used = set()
    for e in names:
        kinds = e["kind"] if isinstance(e["kind"], list) else [e["kind"]]
        best = None
        for k, p in enumerate(places):
            if p["kind"] in kinds and k not in used:
                d = dist(p["tile"], e["tile"])
                if d <= 4 and (best is None or d < best[0]):
                    best = (d, k)
        if best is None:
            print(f"name not placed: {e.get('name_hv')} {e['kind']} {e['tile']}")
            continue
        used.add(best[1])
        for f in ("name_hv", "name_han", "gloss", "note"):
            if f in e:
                places[best[1]][f] = e[f]


NEAR = {"forest": ["cold", "bamboo", "hill"], "grassland": ["steppe", "forest"], "steppe": ["grassland", "desert"],
        "cold": ["forest", "hill"], "jungle": ["bamboo", "grassland"], "bamboo": ["jungle", "forest"],
        "desert": ["steppe"], "hill": ["forest", "cold"], "coast": ["lake", "river"], "river": ["lake", "coast"],
        "lake": ["river", "coast"]}


def pool_names(M, places, pool):
    """Unnamed towns and villages take a name from the pool by the land at their tile; each name once.

    A place fits several kinds (its water, hills, cold, its biome) and takes from the fitting kind with the most names
    left, so the pools share out; when all are used it falls back to a near kind (forest to hill, grassland to steppe).
    """
    used = {p.get("name_hv", "").rsplit(" ", 1)[0] for p in places if p.get("name_hv")}
    biome_cat = {B["temperate_forest"]: "forest", B["bamboo_forest"]: "bamboo", B["jungle"]: "jungle",
                 B["mangrove"]: "jungle", B["grassland"]: "grassland", B["steppe"]: "steppe", B["desert"]: "desert",
                 B["badlands"]: "desert", B["salt_flats"]: "desert", B["swamp"]: "lake", B["tundra"]: "cold",
                 B["highland"]: "hill", B["high_mountain"]: "hill", B["karst"]: "hill"}
    order = ["coast", "river", "lake", "forest", "grassland", "steppe", "hill", "bamboo", "jungle", "cold", "desert"]
    suffix = {"town": ("Trấn", "鎮", "Town"), "village": ("Thôn", "村", "Village")}
    todo = [p for p in places if p["kind"] in suffix and not p.get("name_hv")]
    todo.sort(key=lambda p: (p["kind"] != "town", -p["livability"]))
    for p in todo:
        i = M.idx(*p["tile"])
        fits = []
        if M.coast[i]:
            fits.append("coast")
        if M.shore[i] or M.b[i] == B["swamp"]:
            fits.append("lake")
        if M.river[i]:
            fits.append("river")
        if M.h[i] > 0.7:
            fits.append("hill")
        if M.t[i] < PP["cold_name_c"]:
            fits.append("cold")
        fits.append(biome_cat.get(M.b[i], "grassland"))
        left = lambda c: sum(1 for e in pool.get(c, []) if e["name_hv"] not in used)
        prefs = sorted(dict.fromkeys(fits), key=lambda c: -left(c))               # the fitting kind with most left
        for c in list(prefs):
            prefs += [n for n in NEAR.get(c, []) if n not in prefs]
        prefs += [c for c in order if c not in prefs]
        for c in prefs:
            free = [e for e in pool.get(c, []) if e["name_hv"] not in used]
            if free:
                e = free[0]
                used.add(e["name_hv"])
                sx = suffix[p["kind"]]
                p["name_hv"] = f"{e['name_hv']} {sx[0]}"
                p["name_han"] = e["name_han"] + sx[1]
                p["gloss"] = f"{e['gloss']} {sx[2]}"
                p["name_from"] = c
                break


def render(M, places, roads, out):
    W, H, sc = M.W, M.H, PP["scale"]
    base = Image.open(os.path.join(M.d, "base", "detail.jpg")).convert("RGB").resize((W * sc, H * sc), Image.LANCZOS)
    base = base.convert("RGBA")
    tint = Image.new("RGBA", base.size, (0, 0, 0, 0))
    td = ImageDraw.Draw(tint)
    for y in range(H):
        for x in range(W):
            t = M.terr[y * W + x]
            if t >= 0:
                td.rectangle((x * sc, y * sc, x * sc + sc - 1, y * sc + sc - 1), fill=tuple(M.greats[t]["colour"]) + (46,))
    base = Image.alpha_composite(base, tint)
    ov = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    for y in range(H):                                                           # sect borders
        for x in range(W):
            a = M.terr[y * W + x]
            if a < 0:
                continue
            for nx, ny, sg in ((x + 1, y, ((x + 1) * sc, y * sc, (x + 1) * sc, (y + 1) * sc)),
                               (x, y + 1, (x * sc, (y + 1) * sc, (x + 1) * sc, (y + 1) * sc))):
                if nx < W and ny < H:
                    bb = M.terr[ny * W + nx]
                    if bb >= 0 and bb != a:
                        d.line(sg, fill=(30, 15, 15, 200), width=2)
    pt = lambda i: ((i % W) * sc + 1.5, (i // W) * sc + 1.5)
    for kind, path in roads.segments:
        if kind == "lane":
            pts = [pt(i) for i in path]
            for k in range(0, len(pts) - 1, 4):
                d.line(pts[k:k + 3], fill=(235, 245, 255, 190), width=2)
    for kind, path in roads.segments:
        if kind == "road":
            d.line([pt(i) for i in path], fill=(120, 80, 40, 210), width=2, joint="curve")
    for kind, path in roads.segments:
        if kind == "trunk":
            d.line([pt(i) for i in path], fill=(60, 30, 10, 235), width=5, joint="curve")
    for kind, path in roads.segments:
        if kind == "trunk":
            d.line([pt(i) for i in path], fill=(235, 200, 120, 255), width=2, joint="curve")
    base = Image.alpha_composite(base, ov)
    d = ImageDraw.Draw(base)
    try:
        f_city = ImageFont.truetype("arialbd.ttf", 17)
        f_site = ImageFont.truetype("ariali.ttf", 15)
        f_leg = ImageFont.truetype("arial.ttf", 17)
    except OSError:
        f_city = f_site = f_leg = ImageFont.load_default()
    col = {g["key"]: tuple(g["colour"]) for g in M.greats}
    lord_of = {m["key"]: m["lord"] for m in M.minors}
    boxes = []
    labels = []
    for p in places:
        px, py = p["tile"][0] * sc + 1.5, p["tile"][1] * sc + 1.5
        k = p["kind"]
        if k == "village":
            d.ellipse((px - 2.5, py - 2.5, px + 2.5, py + 2.5), fill=(250, 240, 220), outline=(40, 25, 15))
        elif k == "town":
            d.ellipse((px - 4.5, py - 4.5, px + 4.5, py + 4.5), fill=(250, 240, 220), outline=(40, 25, 15), width=2)
        elif k == "market":
            d.rectangle((px - 5, py - 5, px + 5, py + 5), fill=(255, 215, 90), outline=(40, 25, 15), width=2)
            labels.append((p, f_city, (60, 35, 5)))
        elif k == "city":
            if p.get("array"):
                d.ellipse((px - 14, py - 14, px + 14, py + 14), outline=(150, 60, 220), width=3)
            d.rectangle((px - 7, py - 7, px + 7, py + 7), fill=(255, 250, 240), outline=(20, 10, 10), width=3)
            d.rectangle((px - 2, py - 2, px + 2, py + 2), fill=(20, 10, 10))
            labels.append((p, f_city, (20, 10, 10)))
        elif k == "mine":
            d.polygon([(px, py - 6), (px + 6, py + 5), (px - 6, py + 5)], fill=(70, 70, 75), outline=(240, 240, 240))
        elif k in ("peak", "volcano"):
            fill = (200, 60, 30) if k == "volcano" else (110, 80, 60)
            d.polygon([(px, py - 9), (px + 8, py + 6), (px - 8, py + 6)], fill=fill, outline=(255, 250, 235), width=2)
            labels.append((p, f_site, (50, 25, 10)))
        elif k in ("lake", "island", "forest", "gorge"):
            fill = {"lake": (60, 120, 200), "island": (200, 170, 90), "forest": (40, 110, 50), "gorge": (150, 90, 50)}[k]
            d.ellipse((px - 6, py - 6, px + 6, py + 6), fill=fill, outline=(255, 250, 235), width=2)
            labels.append((p, f_site, (20, 30, 50)))
        elif k == "great_seat":
            pts = []
            for t in range(10):
                ang = -math.pi / 2 + t * math.pi / 5
                rr = 15 if t % 2 == 0 else 6
                pts.append((px + rr * math.cos(ang), py + rr * math.sin(ang)))
            d.polygon(pts, fill=col[p["key"]], outline=(20, 10, 10), width=2)
            labels.append((p, f_city, (20, 10, 10)))
        elif k == "minor_seat":
            r = 7
            d.polygon([(px, py - r), (px + r, py), (px, py + r), (px - r, py)], fill=col[lord_of[p["key"]]],
                      outline=(20, 10, 10), width=2)
        boxes.append((px - 8, py - 8, px + 8, py + 8))
    for p, font, colr in labels:                                                  # names, avoiding each other
        text = p.get("name_hv") or {"city": "city", "market": "market"}.get(p["kind"], p["kind"])
        px, py = p["tile"][0] * sc + 1.5, p["tile"][1] * sc + 1.5
        tw = d.textlength(text, font=font)
        best = None
        for ox, oy, anchor in ((11, 0, "lm"), (-11, 0, "rm"), (0, -12, "mb"), (0, 12, "mt"),
                               (10, -10, "lb"), (10, 10, "lt"), (-10, -10, "rb"), (-10, 10, "rt")):
            x0 = px + ox - (0 if anchor[0] == "l" else tw if anchor[0] == "r" else tw / 2)
            y0 = py + oy - (0 if anchor[1] == "t" else 17 if anchor[1] == "b" else 8.5)
            box = (x0 - 2, y0 - 1, x0 + tw + 2, y0 + 18)
            if box[0] < 0 or box[2] > W * sc or box[1] < 0 or box[3] > H * sc:
                continue
            hits = sum(1 for bx in boxes if not (box[2] < bx[0] or box[0] > bx[2] or box[3] < bx[1] or box[1] > bx[3]))
            if best is None or hits < best[0]:
                best = (hits, ox, oy, anchor, box)
        if best is None:
            continue
        _, ox, oy, anchor, box = best
        boxes.append(box)
        d.text((px + ox, py + oy), text, fill=colr, font=font, anchor=anchor, stroke_width=3,
               stroke_fill=(255, 250, 235))
    # legend
    strip = Image.new("RGB", (W * sc, 120), (255, 250, 235))
    sd = ImageDraw.Draw(strip)
    x0, y0 = 20, 14
    items = [("city", "City (thành); ringed: teleport array"), ("market", "Cultivator market (phường thị)"),
             ("town", "Town (trấn)"), ("village", "Village (thôn)"), ("great_seat", "Great sect seat"),
             ("minor_seat", "Minor sect seat"), ("mine", "Mine (khoáng mạch)"), ("peak", "Famous peak, volcano"),
             ("lake", "Famous lake, island, forest, gorge"), ("trunk", "Trunk road"), ("road", "Road"),
             ("lane", "Sea lane")]
    for k, (kind, text) in enumerate(items):
        lx, ly = x0 + (k % 4) * 400, y0 + (k // 4) * 32
        cx, cy = lx + 10, ly + 10
        if kind == "city":
            sd.ellipse((cx - 12, cy - 12, cx + 12, cy + 12), outline=(150, 60, 220), width=3)
            sd.rectangle((cx - 6, cy - 6, cx + 6, cy + 6), fill=(255, 250, 240), outline=(20, 10, 10), width=3)
        elif kind == "market":
            sd.rectangle((cx - 5, cy - 5, cx + 5, cy + 5), fill=(255, 215, 90), outline=(40, 25, 15), width=2)
        elif kind == "town":
            sd.ellipse((cx - 4.5, cy - 4.5, cx + 4.5, cy + 4.5), fill=(250, 240, 220), outline=(40, 25, 15), width=2)
        elif kind == "village":
            sd.ellipse((cx - 2.5, cy - 2.5, cx + 2.5, cy + 2.5), fill=(250, 240, 220), outline=(40, 25, 15))
        elif kind == "great_seat":
            pts = [(cx + (12 if t % 2 == 0 else 5) * math.cos(-math.pi / 2 + t * math.pi / 5),
                    cy + (12 if t % 2 == 0 else 5) * math.sin(-math.pi / 2 + t * math.pi / 5)) for t in range(10)]
            sd.polygon(pts, fill=(196, 72, 56), outline=(20, 10, 10))
        elif kind == "minor_seat":
            sd.polygon([(cx, cy - 7), (cx + 7, cy), (cx, cy + 7), (cx - 7, cy)], fill=(196, 72, 56), outline=(20, 10, 10))
        elif kind == "mine":
            sd.polygon([(cx, cy - 6), (cx + 6, cy + 5), (cx - 6, cy + 5)], fill=(70, 70, 75))
        elif kind == "peak":
            sd.polygon([(cx, cy - 9), (cx + 8, cy + 6), (cx - 8, cy + 6)], fill=(110, 80, 60))
        elif kind == "lake":
            sd.ellipse((cx - 6, cy - 6, cx + 6, cy + 6), fill=(60, 120, 200))
        elif kind == "trunk":
            sd.line((cx - 12, cy, cx + 12, cy), fill=(60, 30, 10), width=5)
            sd.line((cx - 12, cy, cx + 12, cy), fill=(235, 200, 120), width=2)
        elif kind == "road":
            sd.line((cx - 12, cy, cx + 12, cy), fill=(120, 80, 40), width=2)
        elif kind == "lane":
            sd.line((cx - 12, cy, cx - 2, cy), fill=(90, 140, 200), width=2)
            sd.line((cx + 2, cy, cx + 12, cy), fill=(90, 140, 200), width=2)
        sd.text((lx + 30, ly + 1), text, fill=(30, 15, 15), font=f_leg)
    page = Image.new("RGB", (W * sc, H * sc + strip.height))
    page.paste(base.convert("RGB"), (0, 0))
    page.paste(strip, (0, H * sc))
    page.save(os.path.join(out, "places.jpg"), quality=88)


def check(M, places, roads, lanes):
    tile = lambda p: M.idx(*p["tile"])
    kinds = {}
    for p in places:
        kinds[p["kind"]] = kinds.get(p["kind"], 0) + 1
    settled = [p for p in places if p["kind"] in SETTLED]
    # connectivity: road network components + sea lanes, over settlements
    n = M.W * M.H
    comp = [-1] * n
    c = 0
    for i0 in range(n):
        if roads.road[i0] and comp[i0] < 0:
            q = [i0]
            comp[i0] = c
            while q:
                i = q.pop()
                for j in M.nb(i):
                    if roads.road[j] and comp[j] < 0:
                        comp[j] = c
                        q.append(j)
            c += 1
    parent = list(range(c + len(settled)))

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    node = {}
    for k, p in enumerate(settled):
        node[id(p)] = c + k
        if comp[tile(p)] >= 0:
            parent[find(c + k)] = find(comp[tile(p)])
    for a, b in lanes:
        parent[find(node[id(a)])] = find(node[id(b)])
    groups = {}
    for p in settled:
        groups.setdefault(find(node[id(p)]), []).append(p)
    big = max(groups.values(), key=len)
    unreached = [p.get("name_hv") or f"{p['kind']} {p['tile']}" for g in groups.values() if g is not big for p in g]
    island_no_port = []
    for k in set(M.mass_id[tile(p)] for p in settled):
        if k == M.main_mass:
            continue
        if not any(p.get("port") for p in settled if M.mass_id[tile(p)] == k):
            island_no_port.append(k)
    road_tiles = sum(1 for v in roads.road if v)
    trunk_tiles = sum(1 for v in roads.road if v == 2)
    per_region = {}
    for p in places:
        if p["kind"] in SETTLED:
            per_region.setdefault(p["region"], 0)
            per_region[p["region"]] += 1
    return {
        "places": len(places),
        "by_kind": kinds,
        "settlements_per_region": dict(sorted(per_region.items())),
        "settlements_not_reached_by_road_or_lane": unreached,
        "inhabited_islands_without_port": island_no_port,
        "road_km": int(round(road_tiles * PP["km_per_tile"], -2)),
        "trunk_km": int(round(trunk_tiles * PP["km_per_tile"], -2)),
        "sea_lanes": len(lanes),
        "ports": sum(1 for p in settled if p.get("port")),
        "river_places": sum(1 for p in settled if p.get("river")),
        "arrays": [p.get("name_hv") or p["tile"] for p in places if p.get("array")],
        "unnamed": {k: sum(1 for p in places if p["kind"] == k and not p.get("name_hv"))
                    for k in ("city", "market", "town", "village", "peak", "volcano", "lake", "island", "forest", "gorge")},
        "params": PP,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", default="design/map/continent-11")
    a = ap.parse_args()
    with open(os.path.join(a.map, "places_proposal.json"), encoding="utf-8") as fh:
        prop = json.load(fh)
    names_path = os.path.join(a.map, "place_names.json")
    names, pool = [], {}
    if os.path.exists(names_path):
        with open(names_path, encoding="utf-8") as fh:
            nj = json.load(fh)
        names, pool = nj["places"], nj.get("pool", {})
    M = Map(a.map)
    P = Placer(M, prop)
    cn = prop["counts"]
    P.cities(cn["city"], prop.get("cities_by_sect"))
    P.markets(prop["markets_beside"])
    P.spread("town", cn["town"], 1, {("city", "market", "town"): PP["town_gap"],
                                     ("great_seat", "minor_seat"): PP["seat_gap"], ("village",): PP["village_gap"]})
    P.mines(cn["mine"])
    P.spread("village", cn["village"], 2, {SETTLED + ("great_seat", "minor_seat", "mine"): PP["village_gap"]})
    P.wild(cn)
    places = P.places
    for p in places:
        i = M.idx(*p["tile"])
        p["kind_hv"] = KIND_HV[p["kind"]]
        p["region_name"] = M.regs.get(p["region"], {}).get("name_hv", "")
        p["biome"] = BNAME[M.b[i]]
        p["elevation_km"] = p.get("elevation_km", round(M.h[i], 2))
        p["port"] = p["kind"] in SETTLED and any(not M.land[j] for j in
                                                  (M.idx(x, y) for x in range(max(0, p["tile"][0] - 2), min(M.W, p["tile"][0] + 3))
                                                   for y in range(max(0, p["tile"][1] - 2), min(M.H, p["tile"][1] + 3))))
        p["river"] = bool(M.river[i])
        p["coast"] = bool(M.coast[i])
        p["livability"] = round(M.live[i], 2)
    holders(M, places, prop["minor_domain_tiles"])
    attach_names(places, names)
    pool_names(M, places, pool)
    R = Roads(M)
    R.build(places)
    lanes = R.lanes(places)
    for p in places:
        p["on_road"] = bool(R.road[M.idx(*p["tile"])])
    chk = check(M, places, R, lanes)
    order = ["great_seat", "minor_seat", "city", "market", "town", "village", "mine", "peak", "volcano", "lake",
             "island", "forest", "gorge"]
    places.sort(key=lambda p: (order.index(p["kind"]), p["region"], p["tile"][1], p["tile"][0]))
    for k, p in enumerate(places):
        p["id"] = k + 1
    lanes_out = [[a.get("name_hv") or a["tile"], b.get("name_hv") or b["tile"]] for a, b in lanes]
    with open(os.path.join(a.map, "places.json"), "w", encoding="utf-8") as fh:
        json.dump({"source": "tools/design/map/places.py", "check": chk, "places": places, "sea_lanes": lanes_out},
                  fh, indent=1, ensure_ascii=False)
    img = Image.new("L", (M.W, M.H))
    img.putdata([3 if R.lane[i] and not M.land[i] else R.road[i] for i in range(M.W * M.H)])
    img.save(os.path.join(a.map, "roads.png"))
    render(M, places, R, a.map)
    print(json.dumps({k: v for k, v in chk.items() if k != "params"}, indent=1, ensure_ascii=False))


if __name__ == "__main__":
    main()
