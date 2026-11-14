"""Lay the authored sacred features on the map, and derive the ones the terrain makes (Travel & Map rules 4, 6, 28;
Formula C; map-making rules R27, R29, R30).

Reads the saved map (base/ index images, regions.png, politics, minor_sects.json, places.json) and a hand-edited
sacred_proposal.json (counts, strengths, reaches, thresholds, and names by kind and tile). Runs in seconds.

What it lays:
- **Spirit veins** (linh mạch), lines of tiles that follow the ridges: a great vein under each great sect's seat, a
  small vein under each minor sect's seat, and one famous wild vein in each great sect's land, which becomes a
  spirit vein place (rule 6). A wild vein sits in the richest wild ground, away from seats and settlements, with a
  bonus near another sect's border (veins are what sects fight over).
- **Sacred summits** (Light): the peaks named in the proposal, plus the highest free summit in the south and west
  when the proposal asks for one, which also becomes a peak place.
- **Deep caves** (Darkness): in rugged ground with no place within reach, one near each listed seat and the rest
  wherever the ground is most rugged, spread apart.
- **The miasma wasteland** (tử địa) and its **source**, an old battlefield: the most open stretch of poor land on a
  border between great sects, with no place inside and few roads. The wasteland's tiles become the miasma biome.
- **Derived** (R30, not painted): the snowline, storm peaks and high plateaus, from elevation, rainfall and relief.

The map check estimates Formula C's land density on tiles (biome base density, depth into a biome with a
signature, and the features' density push) and reports:
- the share of wilderness land tiles at density 1.4 or more, and how much of it veins and rich-biome hearts explain
  (AC-TM-127);
- for each variant (Ice, Thunder, Wind, Light, Darkness), the places within reach of its features
  (AC-TM-07, at most 2 %);
- each spirit vein place's and seat's estimated land density.
It is an estimate on tiles, not the fine-cell build, and it reports; it does not judge.

It writes <map>/sacred.json (every feature with its tiles, the new places, the wasteland, the check), <map>/sacred.png
(16-bit, the authored feature bits of base/features.png: spirit vein 128, sacred summit 256, deep cave 512, miasma
source 1024; plus 2048 for a miasma wasteland tile) and <map>/sacred.jpg.

Run:  python -I tools/design/map/sacred.py --map design/map/continent-11
"""

import argparse
import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import places as PL  # noqa: E402

from PIL import Image, ImageDraw, ImageFont  # noqa: E402

BITS = {"spirit_vein": 128, "sacred_summit": 256, "deep_cave": 512, "miasma_source": 1024, "miasma_land": 2048}
GEN = {"lava": 1, "hot_spring": 2, "ice_field": 4, "karst_core": 64}
B = PL.B
# Formula C guesses: biome base density b_b and the signature element (None: no depth).
BASE_D = {0: 0.9, 1: 1.0, 2: 1.0, 3: 0.8, 4: 0.7, 5: 0.6, 6: 0.6, 7: 0.6, 8: 0.8, 9: 0.8, 10: 0.9, 11: 1.1,
          12: 1.0, 13: 1.1, 14: 0.7, 15: 0.8, 16: 0.4, 17: 0.9, 18: 0.5}
SIG = {0: "wood", 1: "wood", 2: "wood", 4: "earth", 5: "fire", 6: "metal", 7: "earth", 8: "water", 9: "water",
       10: "earth", 11: "metal", 12: "earth", 14: "water"}
DIRS = [(1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1)]


def dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


def noise(x, y, cell, seed):
    """Value noise in 0..1, bilinear over a grid of `cell` tiles."""
    def h(ix, iy):
        v = (ix * 374761393 + iy * 668265263 + seed * 1442695041) & 0xFFFFFFFF
        v = ((v ^ (v >> 13)) * 1274126177) & 0xFFFFFFFF
        return (v ^ (v >> 16)) / 0xFFFFFFFF
    fx, fy = x / cell, y / cell
    ix, iy = int(math.floor(fx)), int(math.floor(fy))
    tx, ty = fx - ix, fy - iy
    tx, ty = tx * tx * (3 - 2 * tx), ty * ty * (3 - 2 * ty)
    a = h(ix, iy) * (1 - tx) + h(ix + 1, iy) * tx
    b = h(ix, iy + 1) * (1 - tx) + h(ix + 1, iy + 1) * tx
    return a * (1 - ty) + b * ty


class Sacred:
    def __init__(self, M, prop, places):
        self.M, self.P, self.places = M, prop["params"], places
        self.prop = prop
        self.kpt = self.P["km_per_tile"]
        self.biome = list(M.b)
        self.veins, self.summits, self.caves, self.new_places = [], [], [], []
        self.waste, self.source = set(), None
        self.depth = self.depth_frac()

    # -- Formula C, on tiles -------------------------------------------------------------------------------------
    def depth_frac(self):
        """t = clamp((d - 1) / (d_full - 1)), d = 8-neighbour distance (diagonal sqrt 2) to a tile whose biome has a
        different signature, or none. Two passes of a chamfer transform."""
        M, W, H = self.M, self.M.W, self.M.H
        sig = [SIG.get(self.biome[i]) if M.land[i] else None for i in range(W * H)]
        INF = 1e9
        d = [INF] * (W * H)
        for i in range(W * H):
            if sig[i] is None:
                d[i] = 0.0
                continue
            x, y = i % W, i // W
            for ox, oy in DIRS:
                nx, ny = x + ox, y + oy
                if not (0 <= nx < W and 0 <= ny < H) or sig[ny * W + nx] != sig[i]:
                    d[i] = 1.0
                    break
        fw = [(-1, -1, PL.SQ2), (0, -1, 1.0), (1, -1, PL.SQ2), (-1, 0, 1.0)]
        bw = [(1, 1, PL.SQ2), (0, 1, 1.0), (-1, 1, PL.SQ2), (1, 0, 1.0)]
        for passes, ys, xs in ((fw, range(H), range(W)), (bw, range(H - 1, -1, -1), range(W - 1, -1, -1))):
            for y in ys:
                for x in xs:
                    i = y * W + x
                    if d[i] <= 1.0:
                        continue
                    for ox, oy, c in passes:
                        nx, ny = x + ox, y + oy
                        if 0 <= nx < W and 0 <= ny < H:
                            v = d[ny * W + nx] + c
                            if v < d[i]:
                                d[i] = v
        full = self.P["depth_full_km"] / self.kpt
        return [0.0 if sig[i] is None else max(0.0, min(1.0, (d[i] - 1.0) / (full - 1.0))) for i in range(W * H)]

    def base_density(self, i):
        b = self.biome[i]
        g = self.P["depth_density"] if b in SIG else 0.0
        return BASE_D.get(b, 0.5) + self.depth[i] * g

    def push(self, tiles, reach_km, strength, field):
        """Add strength * max(0, 1 - d / R) to field around a set of tiles (one feature: nearest tile counts)."""
        M, W, H = self.M, self.M.W, self.M.H
        R = reach_km / self.kpt
        r = int(math.ceil(R))
        best = {}
        for (tx, ty) in tiles:
            for y in range(max(0, ty - r), min(H, ty + r + 1)):
                for x in range(max(0, tx - r), min(W, tx + r + 1)):
                    dd = math.hypot(x - tx, y - ty)
                    if dd < R:
                        i = y * W + x
                        f = 1.0 - dd / R
                        if f > best.get(i, 0.0):
                            best[i] = f
        for i, f in best.items():
            field[i] += strength * f
        return best

    # -- spirit veins ----------------------------------------------------------------------------------------------
    def ok_vein_tile(self, i):
        return self.M.dry[i] and self.biome[i] != B["glacier"]

    def trace(self, a, steps):
        """A vein along the ridge through tile a: pick the axis whose neighbours stand highest, then walk each way,
        turning at most 45 degrees a step, onto the highest dry tile."""
        M, W, H = self.M, self.M.W, self.M.H
        x0, y0 = a

        def h(x, y):
            if not (0 <= x < W and 0 <= y < H):
                return -9.0
            i = y * W + x
            return M.h[i] if self.ok_vein_tile(i) else -9.0
        axis = max(range(4), key=lambda k: sum(h(x0 + s * j * DIRS[k][0], y0 + s * j * DIRS[k][1])
                                                for s in (1, -1) for j in (1, 2, 3)))
        path = [(x0, y0)]
        seen = {(x0, y0)}
        for s, end in ((axis, 1), ((axis + 4) % 8, 0)):
            cur, dk = (x0, y0), s
            for _ in range(steps // 2):
                best = None
                for turn in (0, 1, -1):
                    k = (dk + turn) % 8
                    nx, ny = cur[0] + DIRS[k][0], cur[1] + DIRS[k][1]
                    if (nx, ny) in seen or h(nx, ny) < -1:
                        continue
                    v = h(nx, ny) + (0.03 if turn == 0 else 0.0)
                    if best is None or v > best[0]:
                        best = (v, (nx, ny), k)
                if best is None:
                    break
                cur, dk = best[1], best[2]
                seen.add(cur)
                if end:
                    path.append(cur)
                else:
                    path.insert(0, cur)
        return path

    def lay_veins(self):
        M, P = self.M, self.P
        g = P["vein_grades"]
        for p in self.places:
            if p["kind"] == "great_seat":
                self.veins.append({"grade": 1, "anchor": p["tile"], "under": p["name_hv"], "kind": "seat"})
            elif p["kind"] == "minor_seat":
                self.veins.append({"grade": 3, "anchor": p["tile"], "under": p["name_hv"], "kind": "seat"})
        for v in self.veins:
            v["tiles"] = self.trace(v["anchor"], g[str(v["grade"])]["tiles"])
        # wild veins: one in each great sect's land
        settled = [p["tile"] for p in self.places if p["kind"] in PL.SETTLED + ("mine",)]
        seats = [p["tile"] for p in self.places if p["kind"] in ("great_seat", "minor_seat")]
        greats = [p["tile"] for p in self.places if p["kind"] == "great_seat"]
        wild_sites = [p["tile"] for p in self.places if p["kind"] not in PL.SETTLED + ("mine", "great_seat", "minor_seat")]
        W = M.W
        cand = []
        for i in range(W * M.H):
            if not self.ok_vein_tile(i) or M.terr[i] < 0:
                continue
            if not (P["wild_vein_h"][0] <= M.h[i] <= P["wild_vein_h"][1]):
                continue
            xy = (i % W, i // W)
            if any(dist(xy, s) < P["wild_vein_seat_gap"] for s in seats) or                     any(dist(xy, s) < P["wild_vein_great_gap"] for s in greats):
                continue
            if any(dist(xy, s) < P["wild_vein_place_gap"] for s in settled + wild_sites):
                continue
            score = self.base_density(i) + 0.1 * min(M.h[i], 3.0) / 3.0
            r = P["wild_vein_border_tiles"]
            t = M.terr[i]
            near_border = False
            for y in range(max(0, xy[1] - r), min(M.H, xy[1] + r + 1), 2):
                for x in range(max(0, xy[0] - r), min(W, xy[0] + r + 1), 2):
                    tt = M.terr[y * W + x]
                    if tt >= 0 and tt != t:
                        near_border = True
                        break
                if near_border:
                    break
            if near_border:
                score += P["wild_vein_border_bonus"]
            cand.append((score, i, xy, near_border))
        cand.sort(reverse=True)
        taken = []
        for t in range(len(M.greats)):
            for score, i, xy, nb in cand:
                if M.terr[i] != t or any(dist(xy, o) < P["wild_vein_gap"] for o in taken):
                    continue
                taken.append(xy)
                v = {"grade": 2, "anchor": list(xy), "kind": "wild", "territory": M.greats[t]["name_hv"],
                     "near_border": nb}
                v["tiles"] = self.trace(xy, g["2"]["tiles"])
                self.veins.append(v)
                self.new_places.append({"kind": "spirit_vein", "tile": list(xy), "region": M.rid[i],
                                        "elevation_km": round(M.h[i], 2)})
                break

    # -- sacred summits ---------------------------------------------------------------------------------------------
    def lay_summits(self):
        M, P = self.M, self.P
        by_name = {p.get("name_hv"): p for p in self.places}
        for nm in self.prop["sacred_summits"]["peaks"]:
            p = by_name[nm]
            self.summits.append({"tile": p["tile"], "peak": nm, "elevation_km": p["elevation_km"]})
        extra = self.prop["sacred_summits"].get("new_in_sects", [])
        if extra:
            keys = {g["key"]: k for k, g in enumerate(M.greats)}
            want = {keys[k] for k in extra}
            W = M.W
            others = [p["tile"] for p in self.places]
            best = None
            rr = P["summit_radius"]
            for i in range(W * M.H):
                if not M.dry[i] or M.terr[i] not in want or M.h[i] < P["summit_min_km"]:
                    continue
                xy = (i % W, i // W)
                if any(dist(xy, o) < P["summit_place_gap"] for o in others):
                    continue
                if any(M.h[y * W + x] > M.h[i] for y in range(max(0, xy[1] - rr), min(M.H, xy[1] + rr + 1))
                       for x in range(max(0, xy[0] - rr), min(W, xy[0] + rr + 1)) if dist(xy, (x, y)) <= rr):
                    continue
                if best is None or M.h[i] > best[0]:
                    best = (M.h[i], xy, i)
            if best:
                h, xy, i = best
                self.summits.append({"tile": list(xy), "peak": None, "elevation_km": round(h, 2), "new": True})
                self.new_places.append({"kind": "peak", "tile": list(xy), "region": M.rid[i],
                                        "elevation_km": round(h, 2), "sacred": True})

    # -- the miasma wasteland ---------------------------------------------------------------------------------------
    def lay_wasteland(self, roads):
        M, P = self.M, self.P
        W, H = M.W, M.H
        r = P["waste_radius"]
        clear = r + P["waste_place_margin"]
        pts = [p["tile"] for p in self.places] + [q["tile"] for q in self.new_places]
        best = None
        step = 3
        fixed = self.prop.get("miasma_wasteland", {}).get("centre")
        cells = [tuple(fixed)] if fixed else [(x, y) for y in range(r, H - r, step) for x in range(r, W - r, step)]
        for x, y in cells:
            i = y * W + x
            if not M.dry[i] or M.terr[i] < 0:
                continue
            if any(abs(px - x) <= clear and abs(py - y) <= clear and dist((x, y), (px, py)) <= clear for px, py in pts):
                continue
            land = sea = road = 0
            live = rough = 0.0
            terrs = set()
            for yy in range(y - r, y + r + 1):
                for xx in range(x - r, x + r + 1):
                    if dist((x, y), (xx, yy)) > r:
                        continue
                    j = yy * W + xx
                    if M.land[j]:
                        land += 1
                        live += M.live[j]
                        rough += M.relief[j] + max(0.0, M.h[j] - 1.0)
                        road += bool(roads[j])
                        if M.terr[j] >= 0:
                            terrs.add(M.terr[j])
                    else:
                        sea += 1
            if sea > P["waste_max_sea_share"] * (land + sea) or len(terrs) < 2:
                continue
            # an old battlefield: open, poor ground where several sects meet, off the roads
            score = (-live / max(1, land) - P["waste_road_weight"] * road / max(1, land)
                     - P["waste_rough_weight"] * rough / max(1, land) + P["waste_meet_bonus"] * (len(terrs) - 2))
            if best is None or score > best[0]:
                best = (score, (x, y), sorted(terrs), road)
        if not best:
            return
        _, c, terrs, road = best
        self.source = c
        for yy in range(c[1] - r - 3, c[1] + r + 4):
            for xx in range(c[0] - r - 3, c[0] + r + 4):
                if not (0 <= xx < W and 0 <= yy < H):
                    continue
                j = yy * W + xx
                if not M.dry[j]:
                    continue
                edge = r * (P["waste_shape"][0] + P["waste_shape"][1] * noise(xx, yy, 5.0, 27))
                if dist(c, (xx, yy)) <= edge:
                    self.waste.add((xx, yy))
        # keep the part joined to the source
        keep, q = {c}, [c]
        while q:
            x, y = q.pop()
            for ox, oy in DIRS:
                nb = (x + ox, y + oy)
                if nb in self.waste and nb not in keep:
                    keep.add(nb)
                    q.append(nb)
        self.waste = keep
        for (x, y) in self.waste:
            self.biome[y * W + x] = B["miasma"]
        self.waste_terrs = [M.greats[t]["name_hv"] for t in terrs]
        self.waste_roads = sum(1 for (x, y) in self.waste if roads[y * W + x])

    # -- deep caves -------------------------------------------------------------------------------------------------
    def lay_caves(self):
        M, P = self.M, self.P
        W = M.W
        pts = [p["tile"] for p in self.places] + [q["tile"] for q in self.new_places]
        karst = [(i % W, i // W) for i in range(W * M.H) if M.f[i] & GEN["karst_core"]]
        seats = {p.get("key"): p["tile"] for p in self.places if p["kind"] in ("great_seat", "minor_seat")}
        sites = [tuple(s["tile"]) for s in self.summits] + [tuple(q["tile"]) for q in self.new_places]
        cand = []
        for i in range(W * M.H):
            if not M.dry[i] or M.terr[i] < 0 or (i % W, i // W) in self.waste:
                continue
            if not (P["cave_h"][0] <= M.h[i] <= P["cave_h"][1]) or M.relief[i] < P["cave_relief_near_seat"]:
                continue
            xy = (i % W, i // W)
            if any(dist(xy, o) < P["cave_site_gap"] for o in sites):
                continue
            if any(abs(px - xy[0]) <= P["cave_place_gap"] and abs(py - xy[1]) <= P["cave_place_gap"]
                   and dist(xy, (px, py)) <= P["cave_place_gap"] for px, py in pts):
                continue
            if any(dist(xy, k) < P["cave_karst_gap"] for k in karst[::3]):
                continue
            if self.source and dist(xy, self.source) < P["cave_karst_gap"]:
                continue
            cand.append((M.relief[i], xy, i))
        cand.sort(reverse=True)
        chosen = []
        for key in self.prop["deep_caves"].get("near_seats", []):
            s = seats[key]
            for rel, xy, i in cand:
                if dist(xy, s) <= P["cave_near_seat"] and all(dist(xy, o["tile"]) >= P["cave_gap"] for o in chosen):
                    chosen.append({"tile": list(xy), "near": key, "relief_km": round(rel, 2), "elevation_km": round(M.h[i], 2)})
                    break
        for rel, xy, i in cand:
            if len(chosen) >= self.prop["deep_caves"]["count"]:
                break
            if rel < P["cave_relief_min"]:
                continue
            if all(dist(xy, o["tile"]) >= P["cave_gap"] for o in chosen) and \
                    all(M.terr[i] != M.terr[M.idx(*o["tile"])] for o in chosen):
                chosen.append({"tile": list(xy), "near": None, "relief_km": round(rel, 2), "elevation_km": round(M.h[i], 2)})
        self.caves = chosen

    # -- derived (R30) ----------------------------------------------------------------------------------------------
    def derived(self):
        M, P = self.M, self.P
        n = M.W * M.H
        self.snow = [i for i in range(n) if M.dry[i] and M.h[i] >= P["snowline_km"]]
        self.storm = [i for i in range(n) if M.dry[i] and M.h[i] >= P["storm_km"] and M.rain[i] >= P["storm_rain_mm"]]
        flat = [M.dry[i] and M.h[i] >= P["plateau_km"] and M.relief[i] <= P["plateau_relief_km"] for i in range(n)]
        self.plateau = []
        seen = [False] * n
        for i0 in range(n):
            if flat[i0] and not seen[i0]:
                comp, q = [], [i0]
                seen[i0] = True
                while q:
                    i = q.pop()
                    comp.append(i)
                    for j in M.nb(i):
                        if flat[j] and not seen[j]:
                            seen[j] = True
                            q.append(j)
                if len(comp) >= P["plateau_min_tiles"]:
                    self.plateau += comp

    # -- the check --------------------------------------------------------------------------------------------------
    def check(self):
        M, P, W = self.M, self.P, self.M.W
        n = W * M.H
        D = [self.base_density(i) if M.land[i] else 0.0 for i in range(n)]
        vein_reach = [False] * n
        g = P["vein_grades"]
        for v in self.veins:
            near = self.push(v["tiles"], P["vein_reach_km"], g[str(v["grade"])]["density"], D)
            for i in near:
                vein_reach[i] = True
        for key, (a, R) in P["generated_density"].items():
            tiles = [(i % W, i // W) for i in range(n) if M.f[i] & GEN[key]]
            for t in tiles:                                                       # each spring or vent is its own
                self.push([t], R, a, D)
        if self.source:
            self.push([self.source], P["source_reach_km"], P["source_density"], D)
        D = [max(0.3, min(2.4, D[i])) if M.land[i] else 0.0 for i in range(n)]
        all_places = self.places + self.new_places
        occupied = {tuple(p["tile"]) for p in all_places}
        wild = [i for i in range(n) if M.dry[i] and (i % W, i // W) not in occupied]
        rich = [i for i in wild if D[i] >= 1.4]
        explained = [i for i in rich if vein_reach[i] or (self.depth[i] >= 0.999 and BASE_D.get(self.biome[i], 0) >= 1.0)]
        # variants
        var = {
            "Ice": [("ice field", [(i % W, i // W) for i in range(n) if M.f[i] & GEN["ice_field"]], P["variant_reach_km"]),
                    ("snowline", [(i % W, i // W) for i in self.snow], P["snow_reach_km"])],
            "Thunder": [("storm peaks", [(i % W, i // W) for i in self.storm], P["variant_reach_km"])],
            "Wind": [("high plateau", [(i % W, i // W) for i in self.plateau], P["variant_reach_km"])],
            "Light": [("sacred summit", [tuple(s["tile"]) for s in self.summits], P["variant_reach_km"])],
            "Darkness": [("karst core", [(i % W, i // W) for i in range(n) if M.f[i] & GEN["karst_core"]], P["variant_reach_km"]),
                         ("deep cave", [tuple(c["tile"]) for c in self.caves], P["variant_reach_km"]),
                         ("miasma source", [self.source] if self.source else [], P["source_reach_km"])],
        }
        variants = {}
        for e, srcs in var.items():
            hit = {}
            for label, tiles, R in srcs:
                Rt = R / self.kpt
                for p in all_places:
                    px, py = p["tile"]
                    if any(abs(tx - px) < Rt and abs(ty - py) < Rt and dist((tx, ty), (px, py)) < Rt for tx, ty in tiles):
                        hit.setdefault(p.get("name_hv") or f"{p['kind']} {p['tile']}", []).append(label)
            variants[e] = {"tiles": sum(len(t) for _, t, _ in srcs), "places": len(hit),
                           "share": round(len(hit) / len(all_places), 3), "which": hit}
        dens = lambda p: round(D[M.idx(*p["tile"])], 2)
        seats = [p for p in self.places if p["kind"] in ("great_seat", "minor_seat")]
        return D, {
            "places_total": len(all_places),
            "new_places": {k: sum(1 for q in self.new_places if q["kind"] == k) for k in ("spirit_vein", "peak")},
            "vein_tiles": sum(len(v["tiles"]) for v in self.veins),
            "wilderness_tiles": len(wild),
            "wilderness_at_1_4": len(rich),
            "wilderness_share_at_1_4": round(len(rich) / len(wild), 4),
            "explained_by_veins_or_rich_hearts": round(len(explained) / max(1, len(rich)), 3),
            "variant_places_max": P["variant_place_share_max"],
            "variants": variants,
            "spirit_vein_place_density": [dens(q) for q in self.new_places if q["kind"] == "spirit_vein"],
            "great_seat_land_density": {p["name_hv"]: dens(p) for p in seats if p["kind"] == "great_seat"},
            "minor_seat_land_density_mean": round(sum(dens(p) for p in seats if p["kind"] == "minor_seat") / 22, 2),
            "minor_seats_at_1_4": sum(1 for p in seats if p["kind"] == "minor_seat" and dens(p) >= 1.4),
            "place_land_density_mean_estimate": round(sum(dens(p) for p in all_places) / len(all_places), 3),
            "places_at_1_4_land_only": sum(1 for p in all_places if dens(p) >= 1.4),
            "waste_tiles": len(self.waste),
            "waste_road_tiles": getattr(self, "waste_roads", 0),
            "waste_between": getattr(self, "waste_terrs", []),
            "derived_tiles": {"snowline": len(self.snow), "storm_peaks": len(self.storm), "high_plateau": len(self.plateau)},
            "params": P,
        }


def attach_names(S, names):
    """Names by kind and tile, as in place_names.json."""
    look = {(e["kind"], tuple(e["tile"])): e for e in names}
    used = set()

    def put(obj, kind, tile):
        e = look.get((kind, tuple(tile)))
        if e:
            used.add((kind, tuple(tile)))
            for k in ("name_hv", "name_han", "gloss", "note"):
                if k in e:
                    obj[k] = e[k]
    for v in S.veins:
        if v["kind"] != "seat" or v["grade"] == 1:
            put(v, "vein", v["anchor"])
    for q in S.new_places:
        put(q, q["kind"], q["tile"])
    for s in S.summits:
        if s.get("new"):
            put(s, "peak", s["tile"])
    for c in S.caves:
        put(c, "deep_cave", c["tile"])
    if S.source:
        S.waste_obj = {"tiles": len(S.waste), "source": list(S.source)}
        put(S.waste_obj, "wasteland", S.source)
        S.source_obj = {"tile": list(S.source)}
        put(S.source_obj, "miasma_source", S.source)
    # wild vein place takes its vein's name
    for v in S.veins:
        if v["kind"] == "wild":
            for q in S.new_places:
                if q["tile"] == v["anchor"] and "name_hv" in v:
                    for k in ("name_hv", "name_han", "gloss", "note"):
                        if k in v:
                            q[k] = v[k]
    for s in S.summits:
        if s.get("new"):
            for q in S.new_places:
                if q["tile"] == s["tile"] and "name_hv" in s:
                    for k in ("name_hv", "name_han", "gloss", "note"):
                        if k in s:
                            q[k] = s[k]
    return [e for k, e in look.items() if k not in used]


def render(S, D, out):
    M = S.M
    W, H, sc = M.W, M.H, 3
    base = Image.open(os.path.join(M.d, "base", "detail.jpg")).convert("RGB").resize((W * sc, H * sc), Image.LANCZOS)
    base = Image.blend(base, Image.new("RGB", base.size, (20, 22, 30)), 0.35).convert("RGBA")
    ov = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
    roads, _ = PL.pixels(os.path.join(M.d, "roads.png"))
    for i, v in enumerate(roads):
        if v in (1, 2) and M.land[i]:
            x, y = i % W, i // W
            d.rectangle((x * sc + 1, y * sc + 1, x * sc + 1, y * sc + 1), fill=(200, 170, 120, 120))
    for y in range(H):                                                           # sect borders
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
    # density glow
    for i in range(W * H):
        if M.land[i] and D[i] >= 1.4:
            x, y = i % W, i // W
            a = int(min(1.0, (D[i] - 1.4) / 0.6) * 110 + 40)
            d.rectangle((x * sc, y * sc, x * sc + sc - 1, y * sc + sc - 1), fill=(110, 255, 210, a))
    def fill(tiles, col):
        for i in tiles:
            x, y = i % W, i // W
            d.rectangle((x * sc, y * sc, x * sc + sc - 1, y * sc + sc - 1), fill=col)
    fill(S.plateau, (230, 200, 120, 120))
    fill(S.snow, (250, 250, 255, 170))
    fill(S.storm, (170, 120, 255, 170))
    fill([i for i in range(W * H) if M.f[i] & GEN["ice_field"]], (150, 220, 255, 220))
    fill([i for i in range(W * H) if M.f[i] & GEN["karst_core"]], (40, 30, 50, 200))
    fill([y * W + x for x, y in S.waste], (120, 60, 130, 150))
    for v in S.veins:
        pts = [(x * sc + 1.5, y * sc + 1.5) for x, y in v["tiles"]]
        wdt = {1: 5, 2: 4, 3: 2}[v["grade"]]
        d.line(pts, fill=(60, 255, 200, 255), width=wdt, joint="curve")
    try:
        font = ImageFont.truetype("arial.ttf", 15)
        small = ImageFont.truetype("arial.ttf", 12)
    except OSError:
        font = small = ImageFont.load_default()
    for p in S.places:
        x, y = p["tile"]
        c = (255, 255, 255, 230) if p["kind"] in ("great_seat",) else (200, 200, 200, 160)
        r = 4 if p["kind"] == "great_seat" else 1.5
        d.ellipse((x * sc + 1.5 - r, y * sc + 1.5 - r, x * sc + 1.5 + r, y * sc + 1.5 + r), fill=c)

    labels = []

    def label(xy, text, col, f=None):
        labels.append((xy[0] * sc + 1.5, xy[1] * sc + 1.5, text, col, f or font))
    for q in S.new_places:
        x, y = q["tile"]
        cx, cy = x * sc + 1.5, y * sc + 1.5
        if q["kind"] == "spirit_vein":
            d.polygon([(cx, cy - 8), (cx + 8, cy), (cx, cy + 8), (cx - 8, cy)], fill=(60, 255, 200, 255), outline=(0, 0, 0, 255))
            label(q["tile"], q.get("name_hv", "spirit vein"), (160, 255, 225, 255))
    for s in S.summits:
        x, y = s["tile"]
        cx, cy = x * sc + 1.5, y * sc + 1.5
        pts = []
        for k in range(10):
            rr = 10 if k % 2 == 0 else 4
            a = -math.pi / 2 + k * math.pi / 5
            pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
        d.polygon(pts, fill=(255, 225, 90, 255), outline=(0, 0, 0, 255))
        label(s["tile"], s.get("name_hv") or s.get("peak") or "sacred summit", (255, 235, 140, 255))
    for c in S.caves:
        x, y = c["tile"]
        cx, cy = x * sc + 1.5, y * sc + 1.5
        d.ellipse((cx - 7, cy - 7, cx + 7, cy + 7), fill=(15, 10, 20, 255), outline=(200, 160, 255, 255), width=2)
        label(c["tile"], c.get("name_hv", "deep cave"), (215, 190, 255, 255))
    if S.source:
        x, y = S.source
        cx, cy = x * sc + 1.5, y * sc + 1.5
        d.regular_polygon((cx, cy, 9), 3, rotation=180, fill=(200, 40, 70, 255), outline=(0, 0, 0, 255))
        label(S.source, getattr(S, "waste_obj", {}).get("name_hv", "miasma wasteland"), (255, 160, 190, 255))
        so = getattr(S, "source_obj", {}).get("name_hv")
        if so:
            label(S.source, so, (255, 190, 205, 255), small)
    for v in S.veins:
        if v["grade"] == 1 and v.get("name_hv"):
            label(v["tiles"][-1], v["name_hv"], (150, 255, 220, 255), small)
    boxes = []                                                                   # place labels without overlaps
    for cx, cy, text, col, f in labels:
        tw, th = d.textbbox((0, 0), text, font=f, stroke_width=3)[2:]
        for ox, oy in ((9, -th / 2), (-9 - tw, -th / 2), (-tw / 2, 9), (-tw / 2, -9 - th), (9, 6), (9, -th - 6),
                       (-9 - tw, 6), (-9 - tw, -th - 6), (-tw / 2, 24), (-tw / 2, -24 - th)):
            bx = (cx + ox, cy + oy, cx + ox + tw, cy + oy + th)
            if not any(bx[0] < o[2] and o[0] < bx[2] and bx[1] < o[3] and o[1] < bx[3] for o in boxes):
                break
        boxes.append(bx)
        d.text((bx[0], bx[1]), text, fill=col, font=f, stroke_width=3, stroke_fill=(10, 10, 15, 255))
    img = Image.alpha_composite(base, ov).convert("RGB")
    lg = ImageDraw.Draw(img)
    items = [((60, 255, 200), "spirit vein / vein place"), ((110, 255, 210), "land density 1.4+ (estimate)"),
             ((255, 225, 90), "sacred summit (Light)"), ((170, 120, 255), "storm peaks (Thunder)"),
             ((250, 250, 255), "snowline (Ice)"), ((150, 220, 255), "ice field (Ice)"),
             ((230, 200, 120), "high plateau (Wind)"), ((40, 30, 50), "karst core (Darkness)"),
             ((200, 160, 255), "deep cave (Darkness)"), ((120, 60, 130), "miasma wasteland, source")]
    x0, y0 = 12, H * sc - 22 * len(items) - 14
    lg.rectangle((x0 - 6, y0 - 8, x0 + 270, H * sc - 6), fill=(15, 15, 22))
    for k, (col, t) in enumerate(items):
        lg.rectangle((x0, y0 + k * 22, x0 + 14, y0 + k * 22 + 14), fill=col, outline=(200, 200, 200))
        lg.text((x0 + 22, y0 + k * 22 - 1), t, fill=(235, 235, 235), font=font)
    img.save(os.path.join(out, "sacred.jpg"), quality=88)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", default="design/map/continent-11")
    a = ap.parse_args()
    with open(os.path.join(a.map, "sacred_proposal.json"), encoding="utf-8") as fh:
        prop = json.load(fh)
    with open(os.path.join(a.map, "places.json"), encoding="utf-8") as fh:
        places = json.load(fh)["places"]
    M = PL.Map(a.map)
    roads, _ = PL.pixels(os.path.join(a.map, "roads.png"))
    roads = [v if v in (1, 2) else 0 for v in roads]
    S = Sacred(M, prop, places)
    S.lay_veins()
    S.lay_summits()
    S.lay_wasteland(roads)
    S.lay_caves()
    S.derived()
    for q in S.new_places:
        i = M.idx(*q["tile"])
        q["kind_hv"] = {"spirit_vein": "linh mạch", "peak": "sơn"}[q["kind"]]
        q["region_name"] = M.regs.get(q["region"], {}).get("name_hv", "")
        q["biome"] = PL.BNAME[M.b[i]]
        q["territory"] = M.greats[M.terr[i]]["name_hv"] if M.terr[i] >= 0 else None
        q["holder"] = q["territory"] if q["kind"] == "spirit_vein" else None
    unused = attach_names(S, prop.get("names", []))
    D, chk = S.check()
    for q in S.new_places:
        q["land_density_estimate"] = round(D[M.idx(*q["tile"])], 2)
    chk["unused_names"] = [e.get("name_hv") for e in unused]
    chk["unnamed"] = sum(1 for q in S.new_places if "name_hv" not in q) + sum(1 for c in S.caves if "name_hv" not in c) \
        + sum(1 for v in S.veins if v["grade"] == 1 and "name_hv" not in v)
    W = M.W
    bits = [0] * (W * M.H)
    for v in S.veins:
        for x, y in v["tiles"]:
            bits[y * W + x] |= BITS["spirit_vein"]
    for s in S.summits:
        bits[M.idx(*s["tile"])] |= BITS["sacred_summit"]
    for c in S.caves:
        bits[M.idx(*c["tile"])] |= BITS["deep_cave"]
    if S.source:
        bits[M.idx(*S.source)] |= BITS["miasma_source"]
    for x, y in S.waste:
        bits[y * W + x] |= BITS["miasma_land"]
    img = Image.new("I;16", (W, M.H))
    img.putdata(bits)
    img.save(os.path.join(a.map, "sacred.png"))
    for v in S.veins:
        v["tiles"] = [list(t) for t in v["tiles"]]
        i = M.idx(*v["anchor"])
        v["region"] = M.rid[i]
        v["land_density_estimate"] = round(D[i], 2)
    out = {
        "source": "tools/design/map/sacred.py",
        "bits": BITS,
        "check": chk,
        "places": S.new_places,
        "spirit_veins": S.veins,
        "sacred_summits": S.summits,
        "deep_caves": S.caves,
        "miasma_wasteland": dict(getattr(S, "waste_obj", {}), between=chk["waste_between"],
                                 tile_list=sorted([list(t) for t in S.waste])),
        "miasma_source": getattr(S, "source_obj", None),
        "derived": {"snowline": [[i % W, i // W] for i in S.snow], "storm_peaks": [[i % W, i // W] for i in S.storm],
                    "high_plateau": [[i % W, i // W] for i in S.plateau]},
    }
    with open(os.path.join(a.map, "sacred.json"), "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=1, ensure_ascii=False)
    render(S, D, a.map)
    show = {k: v for k, v in chk.items() if k != "params"}
    print(json.dumps(show, indent=1, ensure_ascii=False))


if __name__ == "__main__":
    main()
