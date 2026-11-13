"""Draw regions on a chosen continent (Travel & Map rules 23-24).

Rebuilds the continent from its seed with continent_gen.py, then splits the land into about 20 regions whose borders
follow the terrain: mountain crests, big rivers, lakes and the sea.

How it works:
- Travel cost between tiles grows with height, relief and crossing a big river, so a region spreads easily over
  lowland and stops where the land gets hard to cross (R: rule 23, "ranges, rivers and coasts make at least 60 %
  of their borders").
- Seeds are spread by farthest-point sampling under that cost, then moved to their region's centre a few times.
  Mild per-seed weights keep sizes within about 0.4x-2x of the mean.
- Big islands get their own seed; small islands join the nearest region across shallow sea.
- Borders are smoothed and stray patches merged.

The map check reports the share of land borders that are natural (crest, highland, river or lake), with and without
the coast, and the share on watershed divides. It reports; it does not judge.

With --sects (a JSON of great sects: regions, seat region, colour), it also picks a seat tile in each seat region
(high ground well inside the region, never glacier) and draws politics_proposal.jpg.

Run:  python -I tools/design/map/regions.py --seed 11 --regions 20 --out design/map/continent-11 \
          --detail prototypes/continent-candidates/cand-11/detail.jpg --sects design/map/continent-11/sects_proposal.json
"""

import argparse
import heapq
import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import continent_gen as cg                                                         # noqa: E402
from PIL import Image, ImageDraw, ImageFont                                        # noqa: E402

N8 = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
N4 = [(0, -1), (-1, 0), (1, 0), (0, 1)]
SQ2 = math.sqrt(2.0)

RP = {
    "h_cost": 3.0, "h_ref_km": 1.5,              # cost added by height (at h_ref and above)
    "rel_cost": 2.5, "rel_ref_km": 1.5,          # cost added by local relief
    "river_cross": (8.0, 30.0),                  # cost of crossing a river: smallest drawn river .. big river
    "river_factor": 2.0,                         # a "big" river: flux at least this many times the major threshold
    "divide_cost": (1.0, 24.0),                  # crossing a watershed: small catchments .. large ones
    "divide_area_tiles": (20.0, 2000.0),         # catchment size (tiles, the smaller side) for the two ends
    "flat_noise": 0.6, "flat_noise_tiles": 14.0,  # bends lowland borders that would be straight
    "lake_cost": 4.0,
    "sea_cost": 6.0, "sea_reach": 10,            # small islands join across this many tiles of sea
    "island_own_share": 0.55,                    # a landmass this share of the mean region size gets its own seed
    "lloyd_iters": 8,
    "size_lo": 0.4, "size_hi": 2.0, "weight_step": 6.0,
    "smooth_passes": 3, "stray_tiles": 60,
    "nat_h_km": 1.0, "nat_rel_km": 1.0,          # border edge counts as highland or crest at or above these
}

MOUNTAIN = {cg.B[k] for k in ("high_mountain", "highland", "glacier", "volcano", "karst")}


class Regions:
    def __init__(self, c, n):
        self.c, self.n = c, n
        W, H = c.W, c.H
        self.W, self.H = W, H
        SEA, LAKE = cg.B["sea"], cg.B["lake"]
        self.land = [b != SEA for b in c.biome]
        self.lake = [b == LAKE for b in c.biome]
        thr = c.major_thr * RP["river_factor"]
        self.big = [self.land[i] and not self.lake[i] and c.flux[i] >= thr for i in range(W * H)]
        self.riv = [self.land[i] and not self.lake[i] and bool(c.feat[i] & cg.F["river"]) for i in range(W * H)]
        lo, hi = RP["river_cross"]
        self.rpen = [0.0] * (W * H)
        for i in range(W * H):
            if self.riv[i]:
                f = min(1.0, max(0.0, math.log(max(c.flux[i], c.river_thr) / c.river_thr) / math.log(thr / c.river_thr)))
                self.rpen[i] = lo + (hi - lo) * f
        self.h = [max(0.0, v) for v in c.h]
        self.basins()
        self.rel = c.relief
        # sea distance from land (tiles, 8-neighbour BFS) for the shallow-sea links
        INF = 10 ** 9
        sd = [0 if self.land[i] else INF for i in range(W * H)]
        q = [i for i in range(W * H) if self.land[i]]
        head = 0
        while head < len(q):
            i = q[head]; head += 1
            x, y = i % W, i // W
            for ox, oy in N8:
                nx, ny = x + ox, y + oy
                if 0 <= nx < W and 0 <= ny < H:
                    j = ny * W + nx
                    if sd[j] > sd[i] + 1:
                        sd[j] = sd[i] + 1
                        q.append(j)
        self.sd = sd
        m = [0.0] * (W * H)
        for i in range(W * H):
            if self.land[i]:
                if self.lake[i]:
                    m[i] = RP["lake_cost"]
                else:
                    x, y = i % W, i // W
                    nt = RP["flat_noise_tiles"]
                    wob = 1.0 + RP["flat_noise"] * (0.5 + 0.5 * c.nz2.fbm(x / nt + 211.0, y / nt - 97.0, 3))
                    m[i] = (wob + RP["h_cost"] * min(1.0, self.h[i] / RP["h_ref_km"])
                            + RP["rel_cost"] * min(1.0, self.rel[i] / RP["rel_ref_km"]))
            elif sd[i] <= RP["sea_reach"]:
                m[i] = RP["sea_cost"]
            else:
                m[i] = -1.0                                                         # impassable
        self.m = m
        # adjacency with costs (computed on the fly in dijkstra)

    def basins(self):
        """Catchment of each river stretch (between confluences); land with no river drains to its own outlet."""
        W, H, c = self.W, self.H, self.c
        down, flux = c.down, c.flux
        riv = self.riv
        ups = {}
        for i in range(W * H):
            j = down[i]
            if riv[i] and j >= 0 and riv[j]:
                ups.setdefault(j, []).append(i)
        seg = [-1] * (W * H)
        nxt = 0
        for i in sorted((i for i in range(W * H) if riv[i]), key=lambda i: flux[i]):
            u = ups.get(i, [])
            if len(u) == 1 and seg[u[0]] >= 0:
                seg[i] = seg[u[0]]
            else:
                seg[i] = nxt; nxt += 1
        for s in range(W * H):
            if not self.land[s] or seg[s] >= 0:
                continue
            path, i = [], s
            while i >= 0 and seg[i] < 0 and self.land[i] and len(path) < 5000:
                path.append(i)
                j = down[i]
                if j < 0 or j == i or not self.land[j]:
                    break
                i = j
            if i >= 0 and seg[i] >= 0:
                v = seg[i]
            else:
                v = nxt; nxt += 1
            for k in path:
                seg[k] = v
        self.seg = seg
        area = {}
        for i in range(W * H):
            if seg[i] >= 0:
                area[seg[i]] = area.get(seg[i], 0) + 1
        # a river stretch's catchment includes everything upstream: use the flux at its lowest tile when larger
        tile_km2 = c.cell_km * c.cell_km
        for i in range(W * H):
            if riv[i]:
                a = flux[i] / tile_km2
                if a > area[seg[i]]:
                    area[seg[i]] = a
        self.seg_area = area
        lo, hi = RP["divide_cost"]
        a0, a1 = RP["divide_area_tiles"]
        self.div_lo, self.div_hi, self.div_a0, self.div_l = lo, hi, a0, math.log(a1 / a0)

    def step(self, i, j, d, side=None):
        c = d * 0.5 * (self.m[i] + self.m[j])
        riv, pen = self.riv, self.rpen
        if riv[i] != riv[j]:
            c += 0.5 * (pen[i] + pen[j])
        elif not riv[i] and self.seg[i] != self.seg[j] and self.land[i] and self.land[j]:
            a = min(self.seg_area[self.seg[i]], self.seg_area[self.seg[j]])
            f = min(1.0, max(0.0, math.log(max(a, self.div_a0) / self.div_a0) / self.div_l))
            c += self.div_lo + (self.div_hi - self.div_lo) * f
        elif side and not riv[i] and riv[side[0]] and riv[side[1]]:                # slipping through a diagonal river
            c += max(pen[side[0]], pen[side[1]])
        return c

    def dijkstra(self, seeds, weights=None):
        W, H, m = self.W, self.H, self.m
        INF = float("inf")
        dist = [INF] * (W * H)
        own = [-1] * (W * H)
        pq = []
        for r, s in enumerate(seeds):
            d0 = -(weights[r] if weights else 0.0)
            dist[s] = d0
            own[s] = r
            pq.append((d0, s, r))
        heapq.heapify(pq)
        while pq:
            d, i, r = heapq.heappop(pq)
            if d > dist[i] or own[i] != r:
                continue
            x, y = i % W, i // W
            for ox, oy in N8:
                nx, ny = x + ox, y + oy
                if 0 <= nx < W and 0 <= ny < H:
                    j = ny * W + nx
                    if m[j] < 0:
                        continue
                    if ox and oy:
                        nd = d + self.step(i, j, SQ2, (y * W + nx, ny * W + x))
                    else:
                        nd = d + self.step(i, j, 1.0)
                    if nd < dist[j]:
                        dist[j] = nd
                        own[j] = r
                        heapq.heappush(pq, (nd, j, r))
        return dist, own

    def components(self):
        W, H, land = self.W, self.H, self.land
        comp = [-1] * (W * H)
        sizes = []
        for s in range(W * H):
            if not land[s] or comp[s] >= 0:
                continue
            k = len(sizes)
            comp[s] = k
            st = [s]
            n = 0
            while st:
                i = st.pop(); n += 1
                x, y = i % W, i // W
                for ox, oy in N8:
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < W and 0 <= ny < H:
                        j = ny * W + nx
                        if land[j] and comp[j] < 0:
                            comp[j] = k
                            st.append(j)
            sizes.append(n)
        return comp, sizes

    def good_seed(self, i):
        return self.land[i] and not self.lake[i] and not self.riv[i] and self.m[i] < 2.6

    def run(self):
        W, H, n = self.W, self.H, self.n
        comp, sizes = self.components()
        self.comp, self.comp_sizes = comp, sizes
        nland = sum(self.land)
        mean = nland / n
        order = sorted(range(len(sizes)), key=lambda k: -sizes[k])
        main = order[0]
        own_islands = [k for k in order[1:] if sizes[k] >= RP["island_own_share"] * mean]
        seeds = []
        fixed = []                                                                   # island seeds (one per island)
        for k in own_islands:
            cells = [i for i in range(W * H) if comp[i] == k]
            cx = sum(i % W for i in cells) / len(cells)
            cy = sum(i // W for i in cells) / len(cells)
            s = min((i for i in cells if self.good_seed(i)) or cells,
                    key=lambda i: (i % W - cx) ** 2 + (i // W - cy) ** 2)
            seeds.append(s)
            fixed.append(True)
        # farthest-point sampling on the main landmass
        main_cells = [i for i in range(W * H) if comp[i] == main]
        cx = sum(i % W for i in main_cells) / len(main_cells)
        cy = sum(i // W for i in main_cells) / len(main_cells)
        first = min((i for i in main_cells if self.good_seed(i)),
                    key=lambda i: (i % W - cx) ** 2 + (i // W - cy) ** 2)
        seeds.append(first); fixed.append(False)
        while len(seeds) < n:
            dist, _ = self.dijkstra(seeds)
            far = max((i for i in main_cells if self.good_seed(i)), key=lambda i: dist[i])
            seeds.append(far); fixed.append(False)
        weights = [0.0] * n
        for it in range(RP["lloyd_iters"]):
            dist, own = self.dijkstra(seeds, weights)
            cells = [[] for _ in range(n)]
            for i in range(W * H):
                if self.land[i] and own[i] >= 0:
                    cells[own[i]].append(i)
            for r in range(n):
                if fixed[r] or not cells[r]:
                    continue
                cs = cells[r]
                mx = sum(i % W for i in cs) / len(cs)
                my = sum(i // W for i in cs) / len(cs)
                cand = [i for i in cs if self.good_seed(i)] or cs
                seeds[r] = min(cand, key=lambda i: (i % W - mx) ** 2 + (i // W - my) ** 2)
                s = len(cs)
                if s > RP["size_hi"] * mean:
                    weights[r] -= RP["weight_step"]
                elif s < RP["size_lo"] * mean:
                    weights[r] += RP["weight_step"]
            print(f"  iteration {it + 1}: sizes {sorted(len(c) for c in cells)}", flush=True)
        dist, own = self.dijkstra(seeds, weights)
        reg = [own[i] if self.land[i] else -1 for i in range(W * H)]
        # unreached land (far islands): nearest region by straight distance
        un = [i for i in range(W * H) if self.land[i] and reg[i] < 0]
        if un:
            known = [i for i in range(W * H) if reg[i] >= 0]
            for i in un:
                x, y = i % W, i // W
                j = min(known, key=lambda k: (k % W - x) ** 2 + (k // W - y) ** 2)
                reg[i] = reg[j]
        self.seeds, self.weights = seeds, weights
        self.reg = reg
        self.smooth()
        self.merge_strays()
        return self

    def smooth(self):
        W, H, reg = self.W, self.H, self.reg
        for _ in range(RP["smooth_passes"]):
            new = list(reg)
            for i in range(W * H):
                if reg[i] < 0:
                    continue
                x, y = i % W, i // W
                cnt = {}
                for ox, oy in N8:
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < W and 0 <= ny < H:
                        r = reg[ny * W + nx]
                        if r >= 0:
                            cnt[r] = cnt.get(r, 0) + 1
                if cnt:
                    r, k = max(cnt.items(), key=lambda t: t[1])
                    if r != reg[i] and k >= 5:
                        new[i] = r
            self.reg = reg = new

    def merge_strays(self):
        """Patches of a region cut off from its main body on the same landmass join the neighbour they touch most."""
        W, H = self.W, self.H
        for _ in range(3):
            reg = self.reg
            seen = [False] * (W * H)
            parts = {}
            for s in range(W * H):
                if reg[s] < 0 or seen[s]:
                    continue
                r = reg[s]
                st, cells, touch = [s], [], {}
                seen[s] = True
                while st:
                    i = st.pop(); cells.append(i)
                    x, y = i % W, i // W
                    for ox, oy in N4:
                        nx, ny = x + ox, y + oy
                        if 0 <= nx < W and 0 <= ny < H:
                            j = ny * W + nx
                            if reg[j] == r and not seen[j]:
                                seen[j] = True
                                st.append(j)
                            elif reg[j] >= 0 and reg[j] != r:
                                touch[reg[j]] = touch.get(reg[j], 0) + 1
                parts.setdefault(r, []).append((cells, touch))
            changed = False
            for r, ps in parts.items():
                ps.sort(key=lambda p: -len(p[0]))
                for cells, touch in ps[1:]:
                    if touch and len(cells) <= max(RP["stray_tiles"], 0.25 * len(ps[0][0])):
                        to = max(touch.items(), key=lambda t: t[1])[0]
                        for i in cells:
                            reg[i] = to
                        changed = True
            if not changed:
                break

    # -- numbering, stats ------------------------------------------------------------------------------------------
    def finish(self):
        W, H, c, reg = self.W, self.H, self.c, self.reg
        n = self.n
        cells = [[] for _ in range(n)]
        for i in range(W * H):
            if reg[i] >= 0:
                cells[reg[i]].append(i)
        live = [r for r in range(n) if cells[r]]
        # number north-west to south-east in latitude bands
        def key(r):
            cs = cells[r]
            my = sum(i // W for i in cs) / len(cs)
            mx = sum(i % W for i in cs) / len(cs)
            return (int(my / (H / 4)), mx)
        order = sorted(live, key=key)
        remap = {r: k + 1 for k, r in enumerate(order)}
        self.rid = [remap[r] if r >= 0 else 0 for r in reg]
        self.count = len(order)

    def stats(self):
        W, H, c, rid = self.W, self.H, self.c, self.rid
        n = self.count
        ck = c.cell_km
        names = [b[1] for b in cg.BIOMES]
        R = {r: {"id": r, "tiles": 0, "mix": {}, "h": [], "t": [], "p": [], "coast": 0, "big_river": 0,
                 "river": 0, "lake": 0, "ore": 0, "hot": 0, "lava": 0, "ice": 0, "xs": [], "ys": []}
             for r in range(1, n + 1)}
        for i in range(W * H):
            r = rid[i]
            if not r:
                continue
            s = R[r]
            s["tiles"] += 1
            for b, pct in c.mix[i]:
                s["mix"][b] = s["mix"].get(b, 0) + pct
            s["h"].append(self.h[i]); s["t"].append(c.temp[i]); s["p"].append(c.rain[i])
            x, y = i % W, i // W
            s["xs"].append(x); s["ys"].append(y)
            if any(0 <= x + ox < W and 0 <= y + oy < H and not self.land[(y + oy) * W + x + ox] for ox, oy in N4):
                s["coast"] += 1
            f = c.feat[i]
            s["big_river"] += self.big[i]
            s["river"] += bool(f & cg.F["river"])
            s["lake"] += self.lake[i]
            s["ore"] += bool(f & cg.F["ore_vein"])
            s["hot"] += bool(f & cg.F["hot_spring"])
            s["lava"] += bool(f & cg.F["lava"])
            s["ice"] += bool(f & cg.F["ice_field"])
        vol = {r: 0 for r in R}
        for vx, vy in c.vents:
            r = rid[vy * W + vx]
            if r:
                vol[r] += 1
        # borders
        edges, natural, kinds = {}, {}, {}
        tot_e = tot_nat = 0
        for i in range(W * H):
            a = rid[i]
            if not a:
                continue
            x, y = i % W, i // W
            for ox, oy in ((1, 0), (0, 1)):
                nx, ny = x + ox, y + oy
                if nx >= W or ny >= H:
                    continue
                j = ny * W + nx
                b = rid[j]
                if not b or b == a:
                    continue
                pair = (min(a, b), max(a, b))
                kind = self.edge_kind(i, j)
                edges[pair] = edges.get(pair, 0) + 1
                kinds.setdefault(pair, {}).setdefault(kind, 0)
                kinds[pair][kind] += 1
                tot_e += 1
                if kind in ("mountain", "upland", "river", "lake"):
                    natural[pair] = natural.get(pair, 0) + 1
                    tot_nat += 1
        out = []
        for r in range(1, n + 1):
            s = R[r]
            t = s["tiles"]
            mix = sorted(s["mix"].items(), key=lambda kv: -kv[1])
            lat = c.lat(sum(s["ys"]) / t)
            nb = []
            for (a, b), e in sorted(edges.items()):
                if r in (a, b):
                    o = b if a == r else a
                    nb.append({"region": o, "border_tiles": e, "natural_share": round(natural.get((a, b), 0) / e, 2),
                               "kinds": kinds[(a, b)]})
            land_border = sum(x["border_tiles"] for x in nb)
            out.append({
                "id": r, "tiles": t, "area_km2": round(t * ck * ck, -3),
                "landmass": "main" if self.comp_sizes and max(self.comp_sizes) and
                            self.main_share(s) else "island",
                "centre_tile": [round(sum(s["xs"]) / t), round(sum(s["ys"]) / t)],
                "centre_lat": round(lat, 1),
                "biomes": [{"biome": names[b], "share": round(v / t, 1)} for b, v in mix if v / t >= 1.0][:6],
                "mean_elevation_km": round(sum(s["h"]) / t, 2), "max_elevation_km": round(max(s["h"]), 2),
                "mean_temp_c": round(sum(s["t"]) / t, 1),
                "mean_rain_mm": round(sum(s["p"]) / t),
                "coast_tiles": s["coast"], "river_tiles": s["river"], "big_river_tiles": s["big_river"],
                "lake_tiles": s["lake"], "volcanoes": vol[r], "hot_springs": s["hot"], "lava_tiles": s["lava"],
                "ore_vein_tiles": s["ore"], "ice_field_tiles": s["ice"],
                "land_border_tiles": land_border,
                "natural_border_share": round(sum(natural.get((min(r, x["region"]), max(r, x["region"])), 0)
                                                  for x in nb) / land_border, 2) if land_border else None,
                "neighbours": nb,
            })
        self.out = out
        sizes = [o["tiles"] for o in out]
        mean = sum(sizes) / len(sizes)
        self.check = {
            "regions": n, "land_tiles": sum(sizes), "mean_tiles": round(mean),
            "smallest_tiles": min(sizes), "largest_tiles": max(sizes),
            "size_ratio_range": [round(min(sizes) / mean, 2), round(max(sizes) / mean, 2)],
            "land_border_edges": tot_e, "natural_border_share": round(tot_nat / tot_e, 3) if tot_e else None,
            "coast_edges": self.coast_edges(),
            "natural_share_with_coast": round((tot_nat + self.coast_edges()) / (tot_e + self.coast_edges()), 3),
            "natural_or_divide_share": round((tot_nat + self.kind_totals(kinds).get("divide", 0)) / tot_e, 3)
            if tot_e else None,
            "border_kinds": self.kind_totals(kinds),
            "island_regions": sum(1 for o in out if o["landmass"] == "island"),
        }

    def main_share(self, s):
        main = max(range(len(self.comp_sizes)), key=lambda k: self.comp_sizes[k])
        W = self.W
        on = sum(1 for x, y in zip(s["xs"], s["ys"]) if self.comp[y * W + x] == main)
        return on >= 0.5 * len(s["xs"])

    def coast_edges(self):
        W, H, land = self.W, self.H, self.land
        n = 0
        for i in range(W * H):
            if land[i]:
                x, y = i % W, i // W
                n += sum(1 for ox, oy in N4 if 0 <= x + ox < W and 0 <= y + oy < H and not land[(y + oy) * W + x + ox])
        return n

    @staticmethod
    def kind_totals(kinds):
        t = {}
        for d in kinds.values():
            for k, v in d.items():
                t[k] = t.get(k, 0) + v
        return t

    def edge_kind(self, i, j):
        c = self.c
        if self.riv[i] or self.riv[j]:
            return "river"
        if self.lake[i] or self.lake[j]:
            return "lake"
        if c.biome[i] in MOUNTAIN or c.biome[j] in MOUNTAIN:
            return "mountain"
        if max(self.h[i], self.h[j]) >= RP["nat_h_km"] or max(self.rel[i], self.rel[j]) >= RP["nat_rel_km"]:
            return "upland"
        if self.seg[i] != self.seg[j]:
            return "divide"
        return "open"

    # -- output ----------------------------------------------------------------------------------------------------
    def save(self, out, detail_src):
        os.makedirs(out, exist_ok=True)
        W, H, rid = self.W, self.H, self.rid
        im = Image.new("P", (W, H), 0)
        im.putdata(rid)
        pal = [52, 92, 140]
        for r in range(1, 256):
            g = (r * 0.61803398875) % 1.0
            pal += [int(80 + 150 * g), int(80 + 150 * ((g + 0.33) % 1.0)), int(80 + 150 * ((g + 0.66) % 1.0))]
        im.putpalette(pal[:768])
        im.save(os.path.join(out, "regions.png"))
        meta = {"seed": self.c.seed, "generator": "tools/design/map/continent_gen.py", "params": RP,
                "index": "regions.png: 540 x 360, value = region id (0 = sea)", "check": self.check,
                "regions": self.out}
        with open(os.path.join(out, "regions.json"), "w", encoding="utf-8") as f:
            json.dump(meta, f, indent=1, ensure_ascii=False)
        self.render(os.path.join(out, "regions_overview.jpg"), detail_src)

    def render(self, path, detail_src, scale=3):
        W, H, rid = self.W, self.H, self.rid
        base = Image.open(detail_src).convert("RGB").resize((W * scale, H * scale), Image.LANCZOS)
        ov = Image.new("RGBA", base.size, (0, 0, 0, 0))
        d = ImageDraw.Draw(ov)
        segs = []
        for y in range(H):
            for x in range(W):
                a = rid[y * W + x]
                if not a:
                    continue
                if x + 1 < W and rid[y * W + x + 1] and rid[y * W + x + 1] != a:
                    segs.append(((x + 1) * scale, y * scale, (x + 1) * scale, (y + 1) * scale))
                if y + 1 < H and rid[(y + 1) * W + x] and rid[(y + 1) * W + x] != a:
                    segs.append((x * scale, (y + 1) * scale, (x + 1) * scale, (y + 1) * scale))
        for s in segs:
            d.line(s, fill=(255, 255, 255, 150), width=4)
        for s in segs:
            d.line(s, fill=(40, 20, 20, 255), width=2)
        base = Image.alpha_composite(base.convert("RGBA"), ov)
        d = ImageDraw.Draw(base)
        try:
            font = ImageFont.truetype("arialbd.ttf", 26)
        except OSError:
            font = ImageFont.load_default()
        for o in self.out:
            x, y = self.label_point(o["id"])
            t = str(o["id"])
            px, py = x * scale + scale // 2, y * scale + scale // 2
            d.ellipse((px - 19, py - 19, px + 19, py + 19), fill=(255, 250, 235, 235), outline=(40, 20, 20, 255),
                      width=2)
            d.text((px, py), t, fill=(40, 20, 20), font=font, anchor="mm")
        base.convert("RGB").save(path, quality=88)

    def label_point(self, r):
        """The tile of region r farthest from its edge (pole of inaccessibility on the grid)."""
        W, H, rid = self.W, self.H, self.rid
        INF = 10 ** 9
        dist = [INF] * (W * H)
        q = []
        for i in range(W * H):
            if rid[i] != r:
                continue
            x, y = i % W, i // W
            if any(not (0 <= x + ox < W and 0 <= y + oy < H) or rid[(y + oy) * W + x + ox] != r for ox, oy in N4):
                dist[i] = 0
                q.append(i)
        head = 0
        while head < len(q):
            i = q[head]; head += 1
            x, y = i % W, i // W
            for ox, oy in N4:
                nx, ny = x + ox, y + oy
                if 0 <= nx < W and 0 <= ny < H:
                    j = ny * W + nx
                    if rid[j] == r and dist[j] > dist[i] + 1:
                        dist[j] = dist[i] + 1
                        q.append(j)
        best = max((i for i in range(W * H) if rid[i] == r), key=lambda i: dist[i])
        return best % W, best // W


def pick_seat(R, region, min_edge=8):
    """High ground well inside the region: height (capped at 2.5 km) plus a pull toward the middle, never glacier.

    Borders follow crests, so the plain highest tile would sit on the border; the inward pull keeps the seat home.
    """
    W, H, rid, c = R.W, R.H, R.rid, R.c
    INF = 10 ** 9
    dist = [INF] * (W * H)
    q = []
    for i in range(W * H):
        if rid[i] != region:
            continue
        x, y = i % W, i // W
        if any(not (0 <= x + ox < W and 0 <= y + oy < H) or rid[(y + oy) * W + x + ox] != region for ox, oy in N4):
            dist[i] = 0
            q.append(i)
    head = 0
    while head < len(q):
        i = q[head]; head += 1
        x, y = i % W, i // W
        for ox, oy in N4:
            nx, ny = x + ox, y + oy
            if 0 <= nx < W and 0 <= ny < H:
                j = ny * W + nx
                if rid[j] == region and dist[j] > dist[i] + 1:
                    dist[j] = dist[i] + 1
                    q.append(j)
    cand = [i for i in range(W * H) if rid[i] == region and dist[i] >= min_edge
            and c.biome[i] != cg.B["glacier"] and not R.lake[i]]
    if not cand:
        cand = [i for i in range(W * H) if rid[i] == region]
    best = max(cand, key=lambda i: min(R.h[i], 2.5) + 0.06 * min(dist[i], 30))
    return best % W, best // W


def politics(R, sects_path, out, detail_src, scale=3):
    """Great-sect territories, seats and wild regions over the detail map (a proposal view)."""
    with open(sects_path, encoding="utf-8") as f:
        P = json.load(f)
    W, H, rid = R.W, R.H, R.rid
    sects = P["great_sects"]
    owner = {}
    for k, s in enumerate(sects):
        for r in s["regions"]:
            owner[r] = k
    land = sum(o["tiles"] for o in R.out)
    seats = []
    for s in sects:
        x, y = pick_seat(R, s["seat_region"])
        seats.append((x, y))
        s["seat_tile"] = [x, y]
        s["seat_elevation_km"] = round(R.h[y * W + x], 2)
        s["seat_lat"] = round(R.c.lat(y), 1)
        s["tiles"] = sum(o["tiles"] for o in R.out if o["id"] in s["regions"])
        s["land_share"] = round(s["tiles"] / land, 3)
    keep = ("key", "working_name", "tier", "leans", "regions", "seat_region", "seat_tile", "seat_elevation_km",
            "seat_lat", "tiles", "land_share")
    summary = {"great_sects": [{k: s[k] for k in keep} for s in sects],
               "wild_regions": P["wild_regions"],
               "wild_land_share": round(sum(o["tiles"] for o in R.out if o["id"] in P["wild_regions"]) / land, 3)}
    with open(os.path.join(out, "politics_proposal.json"), "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=1, ensure_ascii=False)

    base = Image.open(detail_src).convert("RGB").resize((W * scale, H * scale), Image.LANCZOS).convert("RGBA")
    tint = Image.new("RGBA", base.size, (0, 0, 0, 0))
    td = ImageDraw.Draw(tint)
    for y in range(H):
        for x in range(W):
            r = rid[y * W + x]
            if r in owner:
                col = tuple(sects[owner[r]]["colour"])
                td.rectangle((x * scale, y * scale, x * scale + scale - 1, y * scale + scale - 1), fill=col + (92,))
    base = Image.alpha_composite(base, tint)
    ov = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    thin, thick = [], []
    for y in range(H):
        for x in range(W):
            a = rid[y * W + x]
            if not a:
                continue
            for nx, ny, sg in ((x + 1, y, ((x + 1) * scale, y * scale, (x + 1) * scale, (y + 1) * scale)),
                               (x, y + 1, (x * scale, (y + 1) * scale, (x + 1) * scale, (y + 1) * scale))):
                if nx < W and ny < H:
                    b = rid[ny * W + nx]
                    if b and b != a:
                        if owner.get(a, -a) != owner.get(b, -b):
                            thick.append(sg)
                        else:
                            thin.append(sg)
    for sg in thin:
        d.line(sg, fill=(40, 20, 20, 110), width=1)
    for sg in thick:
        d.line(sg, fill=(255, 255, 255, 170), width=5)
    for sg in thick:
        d.line(sg, fill=(30, 15, 15, 255), width=3)
    base = Image.alpha_composite(base, ov)
    d = ImageDraw.Draw(base)
    try:
        small = ImageFont.truetype("arialbd.ttf", 20)
    except OSError:
        small = ImageFont.load_default()
    for o in R.out:
        x, y = R.label_point(o["id"])
        label = f"{o['id']} wild" if o["id"] in P["wild_regions"] else str(o["id"])
        d.text((x * scale + 1, y * scale + 1), label, fill=(40, 20, 20), font=small, anchor="mm",
               stroke_width=3, stroke_fill=(255, 250, 235))
    for k, (x, y) in enumerate(seats):
        px, py = x * scale + 1, y * scale + 1
        pts = []
        for t in range(10):
            ang = -math.pi / 2 + t * math.pi / 5
            rr = 17 if t % 2 == 0 else 7
            pts.append((px + rr * math.cos(ang), py + rr * math.sin(ang)))
        d.polygon(pts, fill=tuple(sects[k]["colour"]), outline=(20, 10, 10), width=2)
    rows = (len(sects) + 2) // 2 + 1
    strip = Image.new("RGB", (W * scale, 30 * rows + 20), (255, 250, 235))
    sd = ImageDraw.Draw(strip)
    colw = W * scale // 2
    for k, s in enumerate(sects):
        lx, yy = 20 + (k % 2) * colw, 12 + 30 * (k // 2)
        sd.rectangle((lx, yy + 3, lx + 18, yy + 21), fill=tuple(s["colour"]), outline=(40, 20, 20))
        sd.text((lx + 28, yy), f"{s['working_name']}  (tier {s['tier']}; {', '.join(s['leans'])})",
                fill=(30, 15, 15), font=small)
    sd.text((20, 12 + 30 * (rows - 1)), "Untinted land = wild regions.  Star = sect seat.  Numbers = regions.",
            fill=(30, 15, 15), font=small)
    full = Image.new("RGB", (W * scale, H * scale + strip.height))
    full.paste(base.convert("RGB"), (0, 0))
    full.paste(strip, (0, H * scale))
    full.save(os.path.join(out, "politics_proposal.jpg"), quality=88)
    return summary


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--seed", type=int, default=11)
    ap.add_argument("--regions", type=int, default=20)
    ap.add_argument("--out", default="design/map/continent-11")
    ap.add_argument("--detail", default=None, help="detail.jpg of the candidate (else rendered fresh)")
    ap.add_argument("--sects", default=None, help="great-sect proposal JSON; draws politics_proposal.jpg")
    a = ap.parse_args()
    print(f"seed {a.seed}: building the continent", flush=True)
    c = cg.Continent(a.seed).run()
    detail = a.detail
    if not detail or not os.path.exists(detail):
        os.makedirs(a.out, exist_ok=True)
        detail = os.path.join(a.out, "_detail.jpg")
        c.render_preview(os.path.join(a.out, "_preview.png"), detail)
    print("drawing regions", flush=True)
    R = Regions(c, a.regions).run()
    R.finish()
    R.stats()
    R.save(a.out, detail)
    print(json.dumps(R.check, indent=1))
    if a.sects:
        print(json.dumps(politics(R, a.sects, a.out, detail), indent=1))


if __name__ == "__main__":
    main()
