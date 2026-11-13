"""Continent generator for the fixed world (round 4: mixed tiles).

Builds a realistic continent and writes the Travel & Map index images: a fine map (2,160 x 1,440 cells of about
6 km: biome, elevation, water) and the 540 x 360 tiles read from it (main biome, each tile's mix of up to three
biomes, elevation, temperature, rainfall, features), plus preview pictures and a map-check report.

Every step follows a numbered rule in design/research/map-making-rules.md (R1-R70). Round 2 (section J): land grown
from many small regions, plates grown from the same regions, an uplift map carved by the stream power law, power-law
lakes, two-season climate and multi-light rendering. Round 3 (section K): wave-smoothed coasts. Round 4 (section L):
the fine map and tile mixes. Pure Python + Pillow. A design tool: it makes candidates for a person to pick and then
finish by hand.
"""
import argparse
import heapq
import json
import math
import os
import random

from array import array

from PIL import Image, ImageDraw, ImageFilter

# ---------------------------------------------------------------------------------------------------------------
# Parameters (written into meta.json with every candidate). Distances marked "ref" are in reference cells, about
# 37 km (the 360-cell-wide grid of round 1); they scale with the grid, so the geography is the same at any size.
# ---------------------------------------------------------------------------------------------------------------

PARAMS = {
    "tiles_w": 540, "tiles_h": 360,                  # about 25 km a tile (user decision 2026-11-13)
    "lat_north": 76.0, "lat_south": -4.0,            # high Arctic to just past the equator
    "land_target": 0.44,                             # R2, R38: land share after the sea rises
    "grow_target": 0.53,                             # R38: land grown a little too big, then flooded
    "main_share": 0.84,                              # R40: share of the grown land in the main continent
    "regions": 330,                                  # R36
    "region_warp": 0.55,                             # R36: warp as a share of region spacing
    "snake_bias": 0.35,                              # R36: chance to grow next to the last region (peninsulas)
    "edge_margin": 0.06,                             # R1: no land within this share of the width of the edge
    "plates": 12,                                    # R41
    "old_boundary_share": 0.3,                       # R6: worn, low ranges
    "u_plain": 0.05, "u_collision": 1.0, "u_plateau": 0.45, "u_subduction": 0.75, "u_arc": 0.7,
    "u_rift": -0.12, "u_hotspot": 0.9, "u_upland": 0.55,               # R42-R44: uplift rates (km per time unit)
    "w_collision": 7.0, "w_plateau": 16.0, "w_subduction": 6.0, "w_arc": 3.2, "w_rift": 2.5,  # ref cells
    "hotspots": 2,
    "spl_k": 1.2, "spl_m": 0.5, "spl_dt": 0.5, "spl_steps": 48,            # R45-R46
    "talus": 0.12,                                   # R49: max slope (km per km) before hillslopes slide
    "max_height_km": 6.0,                            # elevation scale for the index images' notes only
    "lapse_c_per_km": 6.0,                           # R10
    "season_shift_deg": 7.0,                         # R54
    "rain_per_cell": 0.011, "orographic_cap_km": 3.3, "orographic_dump": 0.35,
    "recycle_tropical": 0.55, "recycle_temperate": 0.35, "recycle_cold": 0.15,
    "coastal_rain_mm": 380.0, "coastal_rain_km": 450.0, "rain_scale_mm": 105000.0, "rain_blur_passes": 4,
    "pet_mm_per_c": 28.0,                            # R55: half-year evaporative demand per degree above 0
    "lake_min_depth_km": 0.015, "lake_min_cells": 3,  # R47, R50
    "glacial_lakes": 140,                            # R51: tries in the cold scoured lowlands
    "river_catchment_km2": 180000.0,                 # R32: draw rivers above this catchment (at mean rain)
    "major_river_factor": 5.0,
    "volcano_spacing": 14.0,                         # ref cells
    "coast_smooth_ref": 2.0,                         # R62: wave smoothing reach on soft coasts (ref cells)
    "coast_hard_km": (0.25, 1.0),                    # R62: mean nearby height where rock starts to resist
    "coast_island_keep": 30.0,                       # R63: islands below this many ref cells keep their shape
    "fine_factor": 4,                                # R66: fine cells per tile side (4 x 4 = 16 cells a tile)
    "mix_share_min": 0.10,                           # R68: a biome under this share of a tile is folded away
    "mix_parts_max": 3,                              # R68: at most this many biomes kept per tile
    "eco_wet": 0.35, "eco_temp_c": 1.5, "eco_relief": 0.5,  # R67: patchiness near biome borders
}

# Biomes in Travel & Map rule 2 order. Colours: natural, land-cover-like (R58), for previews only.
BIOMES = [
    ("temperate_forest", "Temperate forest", (82, 118, 70)),
    ("bamboo_forest", "Bamboo forest", (104, 140, 72)),
    ("jungle", "Jungle", (46, 96, 54)),
    ("grassland", "Grassland", (150, 164, 98)),
    ("steppe", "Steppe", (186, 176, 122)),
    ("desert", "Desert", (220, 196, 150)),
    ("salt_flats", "Salt flats", (232, 228, 214)),
    ("badlands", "Badlands", (182, 124, 92)),
    ("swamp", "Swamp", (88, 108, 82)),
    ("mangrove", "Mangrove", (66, 112, 92)),
    ("highland", "Highland", (154, 146, 116)),
    ("high_mountain", "High mountain", (132, 124, 116)),
    ("karst", "Karst peaks", (108, 140, 100)),
    ("volcano", "Volcano", (104, 74, 66)),
    ("tundra", "Tundra", (158, 160, 140)),
    ("glacier", "Glacier", (236, 240, 244)),
    ("miasma", "Miasma wasteland", (90, 70, 96)),
    ("lake", "Lake", (78, 120, 156)),
    ("sea", "Sea", (52, 92, 140)),
]
B = {key: i for i, (key, _, _) in enumerate(BIOMES)}

# Feature bits (features.png, 16-bit). Order follows Travel & Map rule 4; authored-only features keep their bit.
FEATURES = [
    ("lava", "Lava flow or vent"), ("hot_spring", "Hot spring"), ("ice_field", "Ice field or glacier core"),
    ("river", "River"), ("lake", "Lake water"), ("ore_vein", "Ore vein"), ("karst_core", "Karst core"),
    ("spirit_vein", "Spirit vein (authored)"), ("sacred_summit", "Sacred summit (authored)"),
    ("deep_cave", "Deep cave (authored)"), ("miasma_source", "Miasma source (authored)"),
]
F = {key: 1 << i for i, (key, _) in enumerate(FEATURES)}

N8 = [(-1, -1), (0, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (0, 1), (1, 1)]
N4 = [(0, -1), (-1, 0), (1, 0), (0, 1)]
SQ2 = math.sqrt(2.0)


# ---------------------------------------------------------------------------------------------------------------
# Noise and grid helpers
# ---------------------------------------------------------------------------------------------------------------

class Noise:
    """2D gradient noise with fractal sums. Deterministic from its seed."""

    def __init__(self, seed):
        r = random.Random(seed)
        perm = list(range(256))
        r.shuffle(perm)
        self.p = perm + perm
        self.g = [(math.cos(a), math.sin(a)) for a in (r.random() * 2 * math.pi for _ in range(256))]

    def noise(self, x, y):
        xf, yf = math.floor(x), math.floor(y)
        xi, yi = int(xf) & 255, int(yf) & 255
        dx, dy = x - xf, y - yf
        p, g = self.p, self.g
        a, b = p[xi] + yi, p[xi + 1] + yi
        g00, g01, g10, g11 = g[p[a]], g[p[a + 1]], g[p[b]], g[p[b + 1]]
        n00 = g00[0] * dx + g00[1] * dy
        n10 = g10[0] * (dx - 1) + g10[1] * dy
        n01 = g01[0] * dx + g01[1] * (dy - 1)
        n11 = g11[0] * (dx - 1) + g11[1] * (dy - 1)
        u = dx * dx * dx * (dx * (dx * 6 - 15) + 10)
        v = dy * dy * dy * (dy * (dy * 6 - 15) + 10)
        nx0 = n00 + u * (n10 - n00)
        nx1 = n01 + u * (n11 - n01)
        return (nx0 + v * (nx1 - nx0)) * 1.41

    def fbm(self, x, y, octaves=4, gain=0.5):
        total, amp, freq, norm = 0.0, 1.0, 1.0, 0.0
        for o in range(octaves):
            total += amp * self.noise(x * freq + o * 17.3, y * freq - o * 9.1)
            norm += amp
            amp *= gain
            freq *= 2.0
        return total / norm


def smoothstep(a, b, x):
    if x <= a:
        return 0.0
    if x >= b:
        return 1.0
    t = (x - a) / (b - a)
    return t * t * (3 - 2 * t)


def chamfer(W, H, sources):
    """Distance (cells) to the nearest source and that source's payload. sources: {index: payload}."""
    INF = 1e9
    dist = [INF] * (W * H)
    lab = [None] * (W * H)
    for i, pl in sources.items():
        dist[i] = 0.0
        lab[i] = pl
    fwd = [(-1, -1, SQ2), (0, -1, 1.0), (1, -1, SQ2), (-1, 0, 1.0)]
    bwd = [(1, 1, SQ2), (0, 1, 1.0), (-1, 1, SQ2), (1, 0, 1.0)]
    for _ in range(2):
        for y in range(H):
            for x in range(W):
                i = y * W + x
                di = dist[i]
                for ox, oy, dd in fwd:
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < W and 0 <= ny < H:
                        j = ny * W + nx
                        if dist[j] + dd < di:
                            di = dist[j] + dd
                            lab[i] = lab[j]
                dist[i] = di
        for y in range(H - 1, -1, -1):
            for x in range(W - 1, -1, -1):
                i = y * W + x
                di = dist[i]
                for ox, oy, dd in bwd:
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < W and 0 <= ny < H:
                        j = ny * W + nx
                        if dist[j] + dd < di:
                            di = dist[j] + dd
                            lab[i] = lab[j]
                dist[i] = di
    return dist, lab


def components(W, H, mask, n=N4):
    seen = [False] * (W * H)
    comps = []
    for s in range(W * H):
        if not mask[s] or seen[s]:
            continue
        stack, comp = [s], []
        seen[s] = True
        while stack:
            i = stack.pop()
            comp.append(i)
            x, y = i % W, i // W
            for ox, oy in n:
                nx, ny = x + ox, y + oy
                if 0 <= nx < W and 0 <= ny < H:
                    j = ny * W + nx
                    if mask[j] and not seen[j]:
                        seen[j] = True
                        stack.append(j)
        comps.append(comp)
    return comps


def box_blur(W, H, field, r):
    out = field[:]
    tmp = [0.0] * (W * H)
    for y in range(H):
        row = y * W
        s = sum(out[row + k] for k in range(0, min(W, r + 1)))
        c = min(W, r + 1)
        for x in range(W):
            tmp[row + x] = s / c
            if x + r + 1 < W:
                s += out[row + x + r + 1]
                c += 1
            if x - r >= 0:
                s -= out[row + x - r]
                c -= 1
    for x in range(W):
        s = sum(tmp[k * W + x] for k in range(0, min(H, r + 1)))
        c = min(H, r + 1)
        for y in range(H):
            out[y * W + x] = s / c
            if y + r + 1 < H:
                s += tmp[(y + r + 1) * W + x]
                c += 1
            if y - r >= 0:
                s -= tmp[(y - r) * W + x]
                c -= 1
    return out


# ---------------------------------------------------------------------------------------------------------------
# The generator
# ---------------------------------------------------------------------------------------------------------------

class Continent:
    def __init__(self, seed, params=None):
        self.P = dict(PARAMS)
        if params:
            self.P.update(params)
        P = self.P
        self.seed = seed
        self.rng = random.Random(seed)
        self.nz = Noise(seed * 7919 + 1)
        self.nz2 = Noise(seed * 7919 + 2)
        self.nz3 = Noise(seed * 7919 + 3)
        self.W, self.H = P["tiles_w"], P["tiles_h"]
        self.TW, self.TH = self.W, self.H
        self.cell_km = (P["lat_north"] - P["lat_south"]) * 111.0 / self.H
        self.k = self.W / 360.0                                                    # cells per reference cell
        k = self.k
        self.rate = 1.0 - (1.0 - P["rain_per_cell"]) ** (1.0 / k)
        self.dump = 1.0 - (1.0 - P["orographic_dump"]) ** (1.0 / k)
        self.evap_sea = 1.0 - (1.0 - 0.12) ** (1.0 / k)
        self.evap_lake = 1.0 - (1.0 - 0.04) ** (1.0 / k)
        self.blur_r = max(1, round(2 * k))

    def lat(self, y):
        P = self.P
        return P["lat_north"] - (P["lat_north"] - P["lat_south"]) * y / (self.H - 1)

    # -- R36-R40: land from many small regions ------------------------------------------------------------------
    def regions(self):
        W, H, P, rng, nz = self.W, self.H, self.P, self.rng, self.nz
        gy = max(4, round(math.sqrt(P["regions"] * H / W)))
        gx = max(4, round(P["regions"] / gy))
        sx, sy = W / gx, H / gy
        seeds = []
        for j in range(gy):
            for i in range(gx):
                seeds.append(((i + 0.5 + rng.uniform(-0.42, 0.42)) * sx, (j + 0.5 + rng.uniform(-0.42, 0.42)) * sy))
        warp = P["region_warp"] * sx
        reg = [0] * (W * H)
        for y in range(H):
            for x in range(W):
                wx = x + warp * nz.fbm(x / (1.6 * sx), y / (1.6 * sx), 4)
                wy = y + warp * nz.fbm(x / (1.6 * sx) + 41.3, y / (1.6 * sx) - 17.9, 4)
                ci, cj = int(wx / sx), int(wy / sy)
                best, bi = 1e18, 0
                for jj in range(max(0, cj - 2), min(gy, cj + 3)):
                    for ii in range(max(0, ci - 2), min(gx, ci + 3)):
                        s = seeds[jj * gx + ii]
                        d = (wx - s[0]) ** 2 + (wy - s[1]) ** 2
                        if d < best:
                            best, bi = d, jj * gx + ii
                reg[y * W + x] = bi
        n = len(seeds)
        adj = [set() for _ in range(n)]
        area = [0] * n
        edge = [False] * n
        margin = P["edge_margin"] * W
        for y in range(H):
            for x in range(W):
                r = reg[y * W + x]
                area[r] += 1
                if min(x, W - 1 - x, y, H - 1 - y) < margin:
                    edge[r] = True
                if x + 1 < W and reg[y * W + x + 1] != r:
                    adj[r].add(reg[y * W + x + 1])
                    adj[reg[y * W + x + 1]].add(r)
                if y + 1 < H and reg[(y + 1) * W + x] != r:
                    adj[r].add(reg[(y + 1) * W + x])
                    adj[reg[(y + 1) * W + x]].add(r)
        self.reg, self.seeds, self.adj, self.area, self.redge = reg, seeds, adj, area, edge
        # Grow the main continent, then one or two large islands (R36, R40)
        total = W * H * P["grow_target"]
        land = [False] * n
        owner = [-1] * n

        def grow(start, quota, tag):
            got = area[start]
            land[start] = True
            owner[start] = tag
            frontier = set(r for r in adj[start] if not land[r] and not edge[r])
            last = start
            while got < quota and frontier:
                near_last = [r for r in adj[last] if r in frontier]
                if near_last and rng.random() < P["snake_bias"]:
                    r = rng.choice(near_last)                                          # R36: peninsulas
                else:
                    r = rng.choice(sorted(frontier))
                frontier.discard(r)
                if tag != 0 and any(owner[q] not in (-1, tag) for q in adj[r]):
                    continue                                                           # islands stay apart
                land[r] = True
                owner[r] = tag
                got += area[r]
                last = r
                for q in adj[r]:
                    if not land[q] and not edge[q]:
                        frontier.add(q)
            return got

        cx, cy = W * rng.uniform(0.42, 0.58), H * rng.uniform(0.42, 0.58)
        start = min(range(n), key=lambda r: (seeds[r][0] - cx) ** 2 + (seeds[r][1] - cy) ** 2)
        got = grow(start, total * P["main_share"], 0)
        for tag in (1, 2)[:rng.randint(1, 2)]:
            cands = [r for r in range(n) if not land[r] and not edge[r]
                     and all(owner[q] == -1 for q in adj[r])
                     and all(owner[q2] == -1 for q in adj[r] for q2 in adj[q])]
            if not cands:
                break
            s = rng.choice(cands)
            grow(s, (total - got) / (3 - tag) if tag == 1 else total * 0.06, tag)
        self.rland = land
        self.cont = [land[reg[i]] for i in range(W * H)]

    # -- R41-R44: plates grown from the regions; uplift map --------------------------------------------------
    def plates(self):
        W, H, P, rng = self.W, self.H, self.P, self.rng
        n = len(self.seeds)
        plate = [-1] * n
        starts = rng.sample(range(n), P["plates"])
        fronts = []
        for p, s in enumerate(starts):
            plate[s] = p
            fronts.append([q for q in self.adj[s]])
        left = n - len(starts)
        while left > 0:
            p = rng.randrange(len(starts))
            fr = fronts[p]
            while fr and plate[fr[-1]] != -1:
                fr.pop()
            if not fr:
                if all(not f for f in fronts):
                    break
                continue
            i = rng.randrange(len(fr))
            fr[i], fr[-1] = fr[-1], fr[i]
            r = fr.pop()
            if plate[r] != -1:
                continue
            plate[r] = p
            left -= 1
            fr.extend(q for q in self.adj[r] if plate[q] == -1)
        for r in range(n):
            if plate[r] == -1:
                plate[r] = 0
        vel = []
        for _ in range(P["plates"]):
            a = rng.uniform(0, 2 * math.pi)
            s = rng.uniform(0.4, 1.0)
            vel.append((math.cos(a) * s, math.sin(a) * s))
        self.rplate, self.vel = plate, vel
        cent = [[0.0, 0.0, 0] for _ in range(P["plates"])]
        for r in range(n):
            c = cent[plate[r]]
            c[0] += self.seeds[r][0]
            c[1] += self.seeds[r][1]
            c[2] += 1
        cent = [(c[0] / max(1, c[2]), c[1] / max(1, c[2])) for c in cent]
        cplate = [plate[self.reg[i]] for i in range(W * H)]
        self.cplate = cplate
        old = {}
        src = {k: {} for k in ("collision", "subduction", "arc", "rift")}
        cont = self.cont
        for y in range(H):
            for x in range(W):
                i = y * W + x
                for ox, oy in ((1, 0), (0, 1)):
                    nx, ny = x + ox, y + oy
                    if nx >= W or ny >= H:
                        continue
                    j = ny * W + nx
                    a, b = cplate[i], cplate[j]
                    if a == b:
                        continue
                    dx, dy = cent[b][0] - cent[a][0], cent[b][1] - cent[a][1]
                    ln = math.hypot(dx, dy) or 1.0
                    conv = ((vel[a][0] - vel[b][0]) * dx + (vel[a][1] - vel[b][1]) * dy) / ln
                    key = (min(a, b), max(a, b))
                    if key not in old:
                        old[key] = rng.random() < P["old_boundary_share"]
                    ca, cb = cont[i], cont[j]
                    if conv > 0.2:
                        if ca and cb:
                            src["collision"][i] = (conv, old[key])
                        elif ca or cb:
                            src["subduction"][i] = (conv, old[key])
                        else:
                            src["arc"][i] = (conv, old[key])
                    elif conv < -0.2 and (ca or cb):
                        src["rift"][i] = (-conv, old[key])
        self.fields = {kind: (chamfer(W, H, s) if s else ([1e9] * (W * H), [None] * (W * H)))
                       for kind, s in src.items()}

    def uplift(self):
        W, H, P, rng, nz, nz2, nz3 = self.W, self.H, self.P, self.rng, self.nz, self.nz2, self.nz3
        k = self.k
        F_ = self.fields
        cont = self.cont[:]
        U = [0.0] * (W * H)

        def bump(d, w):
            t = d / w
            return 0.0 if t >= 1 else (1 - t) * (1 - t) * (1 + 2 * t)

        for y in range(H):
            for x in range(W):
                i = y * W + x
                along = 0.55 + 0.9 * max(0.0, nz2.fbm(x / (34.0 * k) + 9.0, y / (34.0 * k) - 3.0, 3) + 0.35)  # R43
                wid = 0.7 + 0.6 * (nz3.fbm(x / (28.0 * k) - 70.0, y / (28.0 * k) + 11.0, 2) + 0.5)
                u = 0.0
                if cont[i]:
                    u = P["u_plain"] * (0.6 + 0.8 * (nz2.fbm(x / (45.0 * k) + 120.0, y / (45.0 * k), 3) + 0.5))
                    up = nz.fbm(x / (70.0 * k) - 90.0, y / (70.0 * k) + 60.0, 4)               # R6: old uplands
                    u += P["u_upland"] * max(0.0, up + 0.05) ** 1.3
                d, lab = F_["collision"][0][i], F_["collision"][1][i]
                if lab and cont[i]:
                    amp = min(1.0, lab[0]) * (0.35 if lab[1] else 1.0) * along
                    u += P["u_collision"] * amp * bump(d, P["w_collision"] * k * wid)
                    u += P["u_plateau"] * amp * bump(d, P["w_plateau"] * k * wid)
                d, lab = F_["subduction"][0][i], F_["subduction"][1][i]
                if lab and cont[i]:
                    amp = min(1.0, lab[0]) * (0.4 if lab[1] else 1.0) * along
                    off = abs(d - 2.5 * k)                                                  # range set back inland
                    u += P["u_subduction"] * amp * bump(off, P["w_subduction"] * k * wid)
                d, lab = F_["arc"][0][i], F_["arc"][1][i]
                if lab:
                    chop = nz3.fbm(x / (5.0 * k) + 33.0, y / (5.0 * k) - 8.0, 2)
                    if chop > 0.05 and d < P["w_arc"] * k:                                 # R42: island arc
                        cont[i] = True
                        u += P["u_arc"] * min(1.0, lab[0]) * bump(d, P["w_arc"] * k) * (0.6 + chop)
                d, lab = F_["rift"][0][i], F_["rift"][1][i]
                if lab and cont[i]:
                    seg = max(0.0, nz3.fbm(x / (20.0 * k) - 40.0, y / (20.0 * k) + 15.0, 2) + 0.1)
                    u += P["u_rift"] * bump(d, P["w_rift"] * k) * min(1.0, seg * 2.5)
                U[i] = u
        # R44: hotspot chains on the ocean, trailing behind the plate's motion
        self.vents = []
        for _ in range(P["hotspots"]):
            for _try in range(200):
                hx, hy = rng.uniform(0.12, 0.88) * W, rng.uniform(0.12, 0.88) * H
                if not cont[int(hy) * W + int(hx)]:
                    break
            vx, vy = self.vel[self.cplate[int(hy) * W + int(hx)]]
            ln = math.hypot(vx, vy) or 1.0
            step = 7.0 * k
            for s in range(rng.randint(4, 7)):
                px, py = hx - vx / ln * step * s, hy - vy / ln * step * s
                rad = (2.6 - 0.25 * s) * k
                for yy in range(max(0, int(py - rad) - 1), min(H, int(py + rad) + 2)):
                    for xx in range(max(0, int(px - rad) - 1), min(W, int(px + rad) + 2)):
                        dd = math.hypot(xx - px, yy - py)
                        if dd < rad:
                            j = yy * W + xx
                            cont[j] = True
                            U[j] = max(U[j], P["u_hotspot"] * (1 - dd / rad) * (1.0 - 0.1 * s))
                if s == 0 and 0 <= int(px) < W and 0 <= int(py) < H:
                    self.vents.append((int(px), int(py)))
        self.U = U
        self.cont = cont
        self.place_volcanoes()

    def place_volcanoes(self):
        """R9, R42: volcanoes in lines along subduction arcs and island arcs, a few in rifts."""
        W, H, P, rng = self.W, self.H, self.P, self.rng
        k = self.k
        F_ = self.fields
        cands = []
        for i in range(W * H):
            if not self.cont[i]:
                continue
            ds, ls = F_["subduction"][0][i], F_["subduction"][1][i]
            if ls and not ls[1] and 1.8 * k <= ds <= 3.4 * k:
                cands.append(i)
            da, la = F_["arc"][0][i], F_["arc"][1][i]
            if la and da <= 1.0 * k:
                cands.append(i)
            dr, lr = F_["rift"][0][i], F_["rift"][1][i]
            if lr and dr <= 2.0 * k and rng.random() < 0.08:
                cands.append(i)
        rng.shuffle(cands)
        spacing = P["volcano_spacing"] * k
        for i in cands:
            x, y = i % W, i // W
            if all((x - vx) ** 2 + (y - vy) ** 2 >= spacing * spacing for vx, vy in self.vents):
                self.vents.append((x, y))
            if len(self.vents) >= 16:
                break
        for vx, vy in self.vents:
            rad = 2.0 * k
            for yy in range(max(0, int(vy - rad) - 1), min(H, int(vy + rad) + 2)):
                for xx in range(max(0, int(vx - rad) - 1), min(W, int(vx + rad) + 2)):
                    dd = math.hypot(xx - vx, yy - vy)
                    if dd < rad:
                        j = yy * W + xx
                        self.cont[j] = True
                        self.U[j] = max(self.U[j], 0.9 * (1 - dd / rad) + 0.1)

    # -- R45-R49: carve the uplift with the stream power law ---------------------------------------------------
    def priority_flood(self, h, land):
        """Fill pits so all land drains to the sea (R47). Returns filled heights and the pop order (low first)."""
        W, H = self.W, self.H
        filled = h[:]
        done = [False] * (W * H)
        heap = []
        for i in range(W * H):
            if not land[i]:
                done[i] = True
                filled[i] = min(h[i], 0.0)
                x, y = i % W, i // W
                for ox, oy in N8:
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < W and 0 <= ny < H and land[ny * W + nx]:
                        heap.append((filled[i], i))
                        break
        heapq.heapify(heap)
        order = []
        eps = 1e-5
        while heap:
            hv, i = heapq.heappop(heap)
            if land[i]:
                order.append(i)
            x, y = i % W, i // W
            for ox, oy in N8:
                nx, ny = x + ox, y + oy
                if 0 <= nx < W and 0 <= ny < H:
                    j = ny * W + nx
                    if not done[j]:
                        done[j] = True
                        jit = ((j * 2654435761) & 0xFFFF) / 65535.0
                        filled[j] = max(h[j], hv + eps * (1.0 + 3.0 * jit))
                        heapq.heappush(heap, (filled[j], j))
        return filled, order

    def receivers(self, filled, land):
        W, H, ck = self.W, self.H, self.cell_km
        rec = [-1] * (W * H)
        rdist = [ck] * (W * H)
        for i in range(W * H):
            if not land[i]:
                continue
            x, y = i % W, i // W
            fi = filled[i]
            best, bj, bd = 0.0, -1, ck
            for ox, oy in N8:
                nx, ny = x + ox, y + oy
                if 0 <= nx < W and 0 <= ny < H:
                    j = ny * W + nx
                    d = ck * (SQ2 if ox and oy else 1.0)
                    s = (fi - filled[j]) / d
                    if s > best:
                        best, bj, bd = s, j, d
            rec[i], rdist[i] = bj, bd
        return rec, rdist

    def erode(self):
        W, H, P = self.W, self.H, self.P
        land = self.cont
        U = self.U
        ck2 = self.cell_km * self.cell_km
        h = [0.0] * (W * H)
        k = self.k
        for i in range(W * H):                                                    # start near steady state
            if land[i]:
                x, y = i % W, i // W
                rough = 0.06 * (self.nz.fbm(x / (3.0 * k) + 900.0, y / (3.0 * k), 4) + 0.5)  # breaks parallel rills
                h[i] = 0.15 + 2.2 * U[i] + rough
            else:
                h[i] = -0.2
        self.h = h
        self.climate()
        Kc, m, dt = P["spl_k"], P["spl_m"], P["spl_dt"]
        talus = P["talus"]
        steps = P["spl_steps"]
        for step in range(steps):
            if step == steps // 2:
                self.climate()
            rainw = self.rainw
            for i in range(W * H):
                if land[i]:
                    h[i] = max(0.02, h[i] + U[i] * dt)                            # rift floors stop above the sea
            filled, order = self.priority_flood(h, land)
            rec, rdist = self.receivers(filled, land)
            A = [0.0] * (W * H)
            for i in order:
                A[i] = ck2 * rainw[i]
            for i in reversed(order):
                r = rec[i]
                if r >= 0 and land[r]:
                    A[r] += A[i]
            for i in order:                                                        # R46: sea upward
                r = rec[i]
                if r < 0 or filled[i] - h[i] > 1e-4:
                    continue                                                       # under water: no incision
                hr = h[r] if land[r] else 0.0
                if h[i] <= hr:
                    continue                                                       # under a lake: no incision
                Fv = Kc * dt * (A[i] ** m) / rdist[i]
                h[i] = (h[i] + Fv * hr) / (1.0 + Fv)
            if step % 4 == 3:                                                      # R49: hillslopes
                lim = talus * self.cell_km
                for i in order:
                    x, y = i % W, i // W
                    for ox, oy in N4:
                        nx, ny = x + ox, y + oy
                        if 0 <= nx < W and 0 <= ny < H:
                            j = ny * W + nx
                            if land[j] and h[i] - h[j] > lim:
                                ex = (h[i] - h[j] - lim) * 0.5
                                h[i] -= ex
                                h[j] += ex
        self.h = h

    # -- R61-R63: waves straighten most coasts; drowned valleys stay only on hard, hilly or glaciated ones ------
    def smooth_coast(self, land, h):
        W, H, P, k = self.W, self.H, self.P, self.k
        n = W * H
        keep = [False] * n                                                         # small islands keep their shape
        for comp in components(W, H, land):
            if len(comp) < P["coast_island_keep"] * k * k:
                for i in comp:
                    keep[i] = True
        rmax = max(1, round(P["coast_smooth_ref"] * k))
        rel = box_blur(W, H, [max(0.0, v) if land[i] else 0.0 for i, v in enumerate(h)], max(1, round(2 * k)))
        landf = [1.0 if v else 0.0 for v in land]
        blurs = {r: box_blur(W, H, box_blur(W, H, landf, r), r) for r in range(1, rmax + 1)}
        out = land[:]
        self.coast_detail = [0.0] * n
        for i in range(n):
            if keep[i]:
                continue
            x, y = i % W, i // W
            hard = smoothstep(P["coast_hard_km"][0], P["coast_hard_km"][1], rel[i])        # R62: hard, hilly rock
            fjord = smoothstep(46.0, 56.0, abs(self.lat(y))) * smoothstep(0.15, 0.6, rel[i])  # R63: glaciated
            region = self.nz2.fbm(x / (34.0 * k) + 77.0, y / (34.0 * k) - 51.0, 2)          # R61: coasts differ
            c = max(fjord, min(1.0, max(0.0, 0.75 * hard + 1.1 * region + 0.1)))
            self.coast_detail[i] = c
            r = round(rmax * (1.0 - c))
            if r > 0:                                                                     # gentle wobble, so filled
                wob = 0.16 * self.nz3.fbm(x / (5.0 * k) - 33.0, y / (5.0 * k) + 61.0, 3)  # bays are not circles
                out[i] = blurs[r][i] > 0.5 + wob
        for i in range(n):
            if out[i] and not land[i]:
                h[i] = 0.004 + 0.01 * self.coast_detail[i]                                  # R62: bays fill
            elif land[i] and not out[i]:
                h[i] = -0.01                                                                # R62: capes cut back
        return out

    # -- R38: flood the shelves; the sea floor -----------------------------------------------------------------
    def flood(self):
        W, H, P, h = self.W, self.H, self.P, self.h
        k = self.k
        for i in range(W * H):
            if self.cont[i]:
                x, y = i % W, i // W
                h[i] += 0.03 * (0.5 + 0.5 * self.nz3.fbm(x / (9.0 * k) + 400.0, y / (9.0 * k), 4))
        need = int(W * H * P["land_target"])
        seeds = [i for i in range(W * H) if not self.cont[i]]

        def drowned(s):
            """R38: the sea at level s floods inward from the coast through land lower than s."""
            wet = [not c for c in self.cont]
            stack = list(seeds)
            while stack:
                i = stack.pop()
                x, y = i % W, i // W
                for ox, oy in N4:
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < W and 0 <= ny < H:
                        j = ny * W + nx
                        if not wet[j] and h[j] < s:
                            wet[j] = True
                            stack.append(j)
            return wet

        lo, hi = 0.0, 0.5
        for _ in range(18):
            mid = (lo + hi) / 2
            if W * H - sum(drowned(mid)) > need:
                lo = mid
            else:
                hi = mid
        sea = lo
        wet = drowned(sea)
        for i in range(W * H):
            if self.cont[i]:
                h[i] -= sea
        land = [not wet[i] for i in range(W * H)]
        land = self.smooth_coast(land, h)                                            # R61-R63
        for comp in components(W, H, land):                                         # R2: no specks
            if len(comp) < 3 * self.k * self.k:
                for i in comp:
                    land[i] = False
        water = [not v for v in land]
        ocean = [False] * (W * H)
        for comp in components(W, H, water):
            touches = any((i % W) in (0, W - 1) or (i // W) in (0, H - 1) for i in comp)
            sea_part = any(not self.cont[i] for i in comp)                              # R37: inland seas stay
            if touches or sea_part:
                for i in comp:
                    ocean[i] = True
            else:
                for i in comp:
                    land[i] = True
                    h[i] = max(h[i], 0.0)
        self.ocean = ocean
        dsea, _ = chamfer(W, H, {i: 1 for i in range(W * H) if land[i]})
        k = self.k
        for i in range(W * H):                                                    # R59: depth from the coast
            if ocean[i]:
                x, y = i % W, i // W
                dk = dsea[i] * self.cell_km
                shelf = 40.0 + 260.0 * (0.5 + 0.5 * self.nz2.fbm(x / (40.0 * k) - 210.0, y / (40.0 * k), 3))
                h[i] = -(0.06 + 0.14 * min(1.0, dk / shelf) + 3.6 * smoothstep(shelf, shelf + 260.0, dk))
        self.vents = [(x, y) for x, y in self.vents if not ocean[y * W + x]]
        self.sea_level_km = sea

    # -- R50, R51: lakes ----------------------------------------------------------------------------------------
    def lakes(self):
        W, H, P, rng, h = self.W, self.H, self.P, self.rng, self.h
        k = self.k
        land = [not o for o in self.ocean]
        # R20, R51: a basin's fate depends on its climate. Wet basins overflow and drain; dry ones keep a salt
        # flat or salt lake in their lowest part; rift basins stay lakes.
        filled, _ = self.priority_flood(h, land)
        pet = P["pet_mm_per_c"]
        keep = [False] * (W * H)
        basin = [land[i] and filled[i] - h[i] > 1e-4 for i in range(W * H)]
        for comp in components(W, H, basin, N8):
            ptot = sum(self.rain[i] for i in comp) / len(comp)
            petv = sum(pet * (max(0.0, self.tjan[i]) + max(0.0, self.tjul[i])) for i in comp) / len(comp)
            alpha = ptot / petv if petv > 1.0 else 3.0
            rift = any(self.U[i] < 0.0 for i in comp)
            if rift and len(comp) >= P["lake_min_cells"] * k * k:
                for i in comp:
                    if self.U[i] < 0.0:
                        keep[i] = True                                             # the rift trough holds water
                    else:
                        h[i] = filled[i]
            elif alpha < 0.45 and len(comp) >= 4 * P["lake_min_cells"] * k * k:
                low = sorted(comp, key=lambda i: h[i])[:max(1, len(comp) // 3)]
                for i in low:
                    keep[i] = True                                                 # salt flat or salt lake
                for i in comp:
                    if not keep[i]:
                        h[i] = filled[i]
            else:
                for i in comp:
                    h[i] = filled[i]                                               # drained
        self.keep_basin = keep
        # R51: the cold scoured lowlands get many small hollows; sizes follow a power law (R50)
        for _ in range(P["glacial_lakes"]):
            x, y = rng.randrange(W), rng.randrange(H)
            i = y * W + x
            if not land[i] or h[i] > 0.6 or self.tjul[i] > 17.0 or self.tjan[i] > -4.0:
                continue
            area_cells = min(400.0 * k * k, 1.0 * k * k * rng.random() ** (-1.0 / 1.1))
            rad = math.sqrt(area_cells / math.pi) + 0.5
            for yy in range(max(0, int(y - rad) - 1), min(H, int(y + rad) + 2)):
                for xx in range(max(0, int(x - rad) - 1), min(W, int(x + rad) + 2)):
                    dd = math.hypot(xx - x, yy - y)
                    j = yy * W + xx
                    if dd < rad and land[j]:
                        wob = 0.5 + 0.5 * self.nz.noise(xx / 2.3 + 7.0, yy / 2.3)
                        h[j] -= 0.04 * (1 - dd / rad) * (0.5 + wob)
        filled, order = self.priority_flood(h, land)
        deep = [land[i] and (filled[i] - h[i] > P["lake_min_depth_km"] or keep[i]) for i in range(W * H)]
        lake = [False] * (W * H)
        for comp in components(W, H, deep, N8):
            if len(comp) >= P["lake_min_cells"] * k * k:
                for i in comp:
                    lake[i] = True
        self.lake = lake

    # -- R52-R55: climate in two seasons -----------------------------------------------------------------------
    @staticmethod
    def belt(lat):
        pts = [(0, 2.1), (8, 1.9), (14, 1.05), (20, 0.32), (30, 0.28), (38, 0.8), (46, 1.0), (55, 1.12),
               (62, 0.95), (72, 0.55), (90, 0.4)]
        lat = abs(lat)
        for (a, va), (b, vb) in zip(pts, pts[1:]):
            if a <= lat <= b:
                return va + (vb - va) * (lat - a) / (b - a)
        return 0.4

    @staticmethod
    def zonal_t(lat):
        """Annual mean sea-level temperature by latitude (Earth's zonal means, rounded)."""
        pts = [(0, 27.0), (10, 26.5), (20, 25.0), (30, 20.0), (40, 14.0), (50, 7.0), (60, 1.0), (70, -8.0),
               (80, -16.0), (90, -22.0)]
        lat = abs(lat)
        for (a, va), (b, vb) in zip(pts, pts[1:]):
            if a <= lat <= b:
                return va + (vb - va) * (lat - a) / (b - a)
        return -22.0

    def climate(self):
        W, H, P, h = self.W, self.H, self.P, self.h
        ocean = getattr(self, "ocean", None) or [not c for c in self.cont]
        lakes = getattr(self, "lake", None) or [False] * (W * H)
        nz3, k = self.nz3, self.k
        hkm = [max(0.0, v) for v in h]
        # R53: continentality, traced back along the winter wind to the sea
        contin = [0.0] * (W * H)
        for y in range(H):
            lat = self.lat(y) - P["season_shift_deg"]
            from_east = lat < 30.0 or lat > 60.0
            xs = range(W - 1, -1, -1) if from_east else range(W)
            run = 0.0
            for x in xs:
                i = y * W + x
                run = 0.0 if ocean[i] else run + self.cell_km
                contin[i] = 1.0 - math.exp(-run / 1300.0)
        contin = box_blur(W, H, contin, max(1, round(4 * k)))
        coast_src = {i: 1 for i in range(W * H) if ocean[i]}
        dcoast, _ = chamfer(W, H, coast_src)
        tjan, tjul = [0.0] * (W * H), [0.0] * (W * H)
        for y in range(H):
            for x in range(W):
                i = y * W + x
                lat = self.lat(y) + 5.0 * nz3.fbm(x / (60.0 * k) + 200.0, y / (60.0 * k), 3)
                c = contin[i]
                hi = min(1.0, abs(lat) / 55.0)
                tann = self.zonal_t(lat) + (0.5 - c) * 10.0 * min(1.0, abs(lat) / 60.0)
                half = (2.5 + 22.0 * c) * hi + 1.0
                base = tann - P["lapse_c_per_km"] * hkm[i]
                tjan[i], tjul[i] = base - half, base + half
        rains = []
        cap_h = P["orographic_cap_km"]
        for season, shift in (("jan", -P["season_shift_deg"]), ("jul", P["season_shift_deg"])):
            temp = tjan if season == "jan" else tjul
            rain = [0.0] * (W * H)
            for y in range(H):
                lat = self.lat(y) - shift
                from_east = lat < 30.0 or lat > 60.0                                   # R11, R54
                xs = range(W - 1, -1, -1) if from_east else range(W)
                mo = 1.0
                for x in xs:
                    i = y * W + x
                    if ocean[i] or lakes[i]:
                        warm = min(1.0, max(0.15, (temp[i] + 5.0) / 35.0))
                        mo += (1.0 - mo) * (self.evap_sea if ocean[i] else self.evap_lake) * warm
                        if ocean[i]:
                            continue
                        rain[i] = mo * self.rate
                        continue
                    cap = max(0.04, 1.0 - hkm[i] / cap_h)                              # R13
                    r = mo * self.rate
                    if mo > cap:
                        r += (mo - cap) * self.dump
                    tt = temp[i]
                    rec = (P["recycle_tropical"] if tt > 20 else P["recycle_temperate"] if tt > 8
                           else P["recycle_cold"])
                    mo = max(0.0, mo - r * (1.0 - rec))
                    rain[i] = r
            for _ in range(P["rain_blur_passes"]):                                   # R15
                rain = box_blur(W, H, rain, self.blur_r)
            for y in range(H):
                for x in range(W):
                    i = y * W + x
                    wob = nz3.fbm(x / (55.0 * k) - 300.0, y / (55.0 * k) + 40.0, 3)
                    belt = self.belt(self.lat(y) - shift + 6.0 * wob) * (
                        1.0 + 0.18 * nz3.fbm(x / (30.0 * k), y / (30.0 * k) + 90, 3))
                    coastal = P["coastal_rain_mm"] * math.exp(-dcoast[i] * self.cell_km / P["coastal_rain_km"])
                    rain[i] = 0.0 if ocean[i] else 0.5 * (rain[i] * P["rain_scale_mm"] * k + coastal) * belt
            rains.append(rain)
        pjan, pjul = rains
        ptot = [a + b for a, b in zip(pjan, pjul)]
        land_rain = [ptot[i] for i in range(W * H) if not ocean[i]]
        mean = sum(land_rain) / max(1, len(land_rain))
        self.rainw = [p / mean if mean > 0 else 1.0 for p in ptot]
        self.tjan, self.tjul, self.pjan, self.pjul, self.rain = tjan, tjul, pjan, pjul, ptot
        self.temp = [(a + b) / 2 for a, b in zip(tjan, tjul)]
        self.contin, self.dcoast = contin, dcoast
        self.mean_rain = mean

    # -- run ----------------------------------------------------------------------------------------------------
    def run(self):
        self.regions()
        self.plates()
        self.uplift()
        self.erode()
        self.flood()
        self.climate()
        self.lakes()
        self.climate()
        self.hydrology()
        self.tiles()
        self.features()
        self.refine()
        self.tile_mix()
        self.check()
        return self

    # -- R66-R70: the fine map under the tiles ------------------------------------------------------------------
    def upsample(self, vals):
        im = Image.new("F", (self.W, self.H))
        im.putdata([float(v) for v in vals])
        im = im.resize((self.FW, self.FH), Image.BILINEAR)
        a = array("f")
        a.frombytes(im.tobytes())
        return a

    def vnoise(self, cell, octaves, salt):
        """Smooth value noise at fine resolution, about -1..1, made with Pillow's bicubic resize."""
        FW, FH = self.FW, self.FH
        rng = random.Random(self.seed * 104729 + salt)
        out = array("f", bytes(4 * FW * FH))
        amp, norm = 1.0, 0.0
        for _ in range(octaves):
            c = max(1, int(cell))
            gw, gh = FW // c + 4, FH // c + 4
            im = Image.frombytes("L", (gw, gh), rng.randbytes(gw * gh)).convert("F")
            im = im.resize((gw * c, gh * c), Image.BICUBIC).crop((c, c, c + FW, c + FH))
            a = array("f")
            a.frombytes(im.tobytes())
            for i in range(FW * FH):
                out[i] += amp * (a[i] / 127.5 - 1.0)
            norm += amp
            amp *= 0.5
            cell /= 2.0
        inv = 1.6 / norm
        for i in range(FW * FH):
            out[i] *= inv
        return out

    def refine(self):
        """R66-R67: a fine map, fine_factor x finer than the tiles. Coast, lakes, height and biome get sub-tile
        detail; rivers become smooth lines. The coarse run sets the large shapes, the fine pass the detail."""
        W, H, P, k = self.W, self.H, self.P, self.k
        f = P["fine_factor"]
        FW, FH = W * f, H * f
        self.f, self.FW, self.FH = f, FW, FH
        n = FW * FH
        pet, lapse = P["pet_mm_per_c"], P["lapse_c_per_km"]
        cw_tj, cw_tl, cw_pt, cw_dr, cw_kn, cw_bn = self.cw
        landv = self.upsample([0.0 if o else 1.0 for o in self.ocean])
        lakev = self.upsample([1.0 if v else 0.0 for v in self.lake])
        hb = self.upsample(self.h)
        hl = self.upsample([max(0.0, v) for v in self.h])
        rel = self.upsample(self.relief)
        cdet = self.upsample(getattr(self, "coast_detail", [0.0] * (W * H)))
        major = self.upsample([1.0 if v >= self.major_thr else 0.0 for v in self.flux])
        tj, tl, pt, dr = (self.upsample(v) for v in (cw_tj, cw_tl, cw_pt, cw_dr))
        kn, bn = self.upsample(cw_kn), self.upsample(cw_bn)
        wob = self.vnoise(2 * f, 3, 1)                                             # R67: coast and lake shores
        det = self.vnoise(1.5 * f, 2, 2)                                           # R67: relief inside a tile
        eco_a = self.vnoise(4.0 * f, 2, 3)                                         # R67: patchy borders
        eco_t = self.vnoise(5.0 * f, 2, 4)
        eco_r = self.vnoise(2.5 * f, 2, 5)
        terr = bytearray(n)
        hf = array("f", bytes(4 * n))
        SEA, LAKE, SALT = B["sea"], B["lake"], B["salt_flats"]
        classify = self.classify
        for i in range(n):
            if landv[i] + (0.22 + 0.2 * cdet[i]) * wob[i] <= 0.5:
                terr[i] = SEA
                hf[i] = min(-0.005, hb[i])
                continue
            h = max(0.002, hb[i]) + (0.015 + 0.3 * min(1.0, rel[i] / 1.5)) * det[i]
            h = max(0.002, h)
            hf[i] = h
            dt = -lapse * (h - hl[i]) + P["eco_temp_c"] * eco_t[i]
            tja, tju = tj[i] + dt, tl[i] + dt
            petv = pet * (max(0.0, tja) + max(0.0, tju))
            alpha = (pt[i] / petv if petv > 1.0 else 3.0) * math.exp(P["eco_wet"] * eco_a[i])
            if lakev[i] + 0.22 * wob[i] > 0.5:
                terr[i] = SALT if alpha < 0.35 else LAKE
                continue
            terr[i] = classify({
                "tjan": tja, "tjul": tju, "alpha": alpha, "dry": dr[i], "hkm": h,
                "relief": rel[i] * (1.0 + P["eco_relief"] * eco_r[i]),
                "coast_adj": landv[i] < 0.97, "major": major[i] > 0.25, "arid_lake": False,
                "karst_n": kn[i], "bad_n": bn[i],
            })
        del landv, lakev, hl, cdet, major, tj, tl, pt, dr, kn, bn, wob, det, eco_a, eco_t, eco_r
        rv = max(1, round(1.5 * k)) * f                                            # R26 at fine scale
        for vx, vy in self.vents:
            cx, cy = (vx + 0.5) * f, (vy + 0.5) * f
            for yy in range(max(0, int(cy - rv)), min(FH, int(cy + rv) + 1)):
                for xx in range(max(0, int(cx - rv)), min(FW, int(cx + rv) + 1)):
                    j = yy * FW + xx
                    if (xx + 0.5 - cx) ** 2 + (yy + 0.5 - cy) ** 2 <= rv * rv and terr[j] not in (SEA, LAKE):
                        terr[j] = B["volcano"]
        # R69: rivers as smooth, gently wandering lines through the coarse network
        down, flux, rc = self.down, self.flux, self.river_cell
        par = {}
        for i in range(W * H):
            if rc[i] and down[i] >= 0:
                d = down[i]
                if d not in par or flux[i] > flux[par[d]]:
                    par[d] = i

        def ctr(i):
            return ((i % W + 0.5) * f, (i // W + 0.5) * f)

        def bend(p):
            x, y = p
            return (x + 0.5 * f * self.nz.noise(x / (3.5 * f) + 11.3, y / (3.5 * f) + 0.7),
                    y + 0.5 * f * self.nz.noise(x / (3.5 * f) + 0.7, y / (3.5 * f) + 11.3))

        lines = []
        rflux = {}
        for i in range(W * H):
            if not rc[i] or down[i] < 0:
                continue
            d = down[i]
            p1, p2 = ctr(i), ctr(d)
            p0 = ctr(par[i]) if i in par else (2 * p1[0] - p2[0], 2 * p1[1] - p2[1])
            dd = down[d] if rc[d] and down[d] >= 0 else -1
            p3 = ctr(dd) if dd >= 0 else (2 * p2[0] - p1[0], 2 * p2[1] - p1[1])
            pts = []
            for s in range(7):
                t = s / 6.0
                t2, t3 = t * t, t * t * t
                pts.append(bend(tuple(0.5 * (2 * p1[a] + (-p0[a] + p2[a]) * t
                                             + (2 * p0[a] - 5 * p1[a] + 4 * p2[a] - p3[a]) * t2
                                             + (-p0[a] + 3 * p1[a] - 3 * p2[a] + p3[a]) * t3) for a in (0, 1))))
            lines.append((pts, flux[i]))
            for (ax, ay), (bx, by) in zip(pts, pts[1:]):
                steps = max(1, int(math.hypot(bx - ax, by - ay) * 2.5))
                for s in range(steps + 1):
                    x = int(ax + (bx - ax) * s / steps)
                    y = int(ay + (by - ay) * s / steps)
                    if 0 <= x < FW and 0 <= y < FH:
                        j = y * FW + x
                        if terr[j] not in (SEA, LAKE) and flux[i] > rflux.get(j, 0.0):
                            rflux[j] = flux[i]
        self.fterr, self.fh, self.rlines, self.rflux = terr, hf, lines, rflux

    # -- R68: each tile's mix ------------------------------------------------------------------------------------
    def tile_mix(self):
        W, H, P, f, FW = self.W, self.H, self.P, self.f, self.FW
        terr, rflux = self.fterr, self.rflux
        cells = f * f
        need = P["mix_share_min"] * cells
        SEA, LAKE = B["sea"], B["lake"]
        main, mix = [SEA] * (W * H), [None] * (W * H)
        river_t = [False] * (W * H)
        lake_t = [False] * (W * H)
        for j in rflux:
            river_t[(j // FW // f) * W + (j % FW) // f] = True
        for ty in range(H):
            for tx in range(W):
                counts = {}
                for yy in range(ty * f, ty * f + f):
                    row = yy * FW
                    for xx in range(tx * f, tx * f + f):
                        t = terr[row + xx]
                        counts[t] = counts.get(t, 0) + 1
                ti = ty * W + tx
                items = sorted(counts.items(), key=lambda kv: (-kv[1], kv[0]))
                kept = [(t, c) for t, c in items if c >= need][:P["mix_parts_max"]] or items[:1]
                tot = sum(c for _, c in kept)
                raw = [(t, 100.0 * c / tot) for t, c in kept]
                pct = [(t, int(v)) for t, v in raw]
                short = 100 - sum(v for _, v in pct)                               # largest remainder
                order = sorted(range(len(raw)), key=lambda q: -(raw[q][1] - int(raw[q][1])))
                for q in order[:short]:
                    pct[q] = (pct[q][0], pct[q][1] + 1)
                mix[ti] = pct
                if 2 * counts.get(SEA, 0) >= cells:
                    main[ti] = SEA
                else:
                    main[ti] = next((t for t, _ in pct if t != SEA), next(t for t, _ in items if t != SEA))
                lake_t[ti] = counts.get(LAKE, 0) > 0
        self.biome, self.mix = main, mix
        for i in range(W * H):                                                     # R69: water from the fine map
            fl = self.feat[i] & ~(F["river"] | F["lake"])
            if main[i] != SEA:
                if river_t[i]:
                    fl |= F["river"]
                if lake_t[i]:
                    fl |= F["lake"]
            elif fl:
                fl = 0
            self.feat[i] = fl

    def hydrology(self):
        W, H = self.W, self.H
        land = [not o for o in self.ocean]
        filled, order = self.priority_flood(self.h, land)
        rec, rdist = self.receivers(filled, land)
        ck2 = self.cell_km * self.cell_km
        A = [0.0] * (W * H)
        for i in order:
            A[i] = ck2 * self.rain[i] / max(1.0, self.mean_rain)
        for i in reversed(order):
            r = rec[i]
            if r >= 0 and land[r]:
                A[r] += A[i]
        self.filled, self.down, self.flux = filled, rec, A
        self.river_thr = self.P["river_catchment_km2"]
        self.major_thr = self.river_thr * self.P["major_river_factor"]
        self.river_cell = [land[i] and A[i] >= self.river_thr and not self.lake[i] for i in range(W * H)]

    # -- R22-R27, R55-R56: biomes -------------------------------------------------------------------------------
    @staticmethod
    def classify(c):
        tjan, tjul, a, dry = c["tjan"], c["tjul"], c["alpha"], c["dry"]
        hkm, rel = c["hkm"], c["relief"]
        if tjul < 0.0 or (hkm > 2.5 and tjul < 3.0):
            return B["glacier"]
        if rel >= 0.9 or hkm >= 3.0:
            return B["high_mountain"]                                               # R25, R56: rock
        if tjul < 10.0:
            return B["tundra"]
        if c["arid_lake"]:
            return B["salt_flats"]
        if hkm >= 1.0 and rel < 0.45:
            return B["highland"]
        if a < 0.45 and hkm >= 0.3 and rel >= 0.35 and c["bad_n"] > 0.05:
            return B["badlands"]
        if tjan > 5 and a > 1.0 and 0.15 <= hkm <= 1.5 and 0.15 <= rel < 0.9 and c["karst_n"] > 0.3:
            return B["karst"]
        if c["coast_adj"] and tjan > 18 and a > 1.0 and hkm < 0.05:
            return B["mangrove"]
        if hkm < 0.12 and rel < 0.08 and tjul > 10 and (a > 1.6 or (c["major"] and a > 0.9)):
            return B["swamp"]
        if tjan <= -3.0:                                                            # R55: boreal
            b = B["desert"] if a < 0.22 else B["steppe"] if a < 0.5 else B["temperate_forest"]
        elif tjan < 18.0:                                                           # temperate
            if a < 0.2:
                b = B["desert"]
            elif a < 0.42:
                b = B["steppe"]
            elif a < 0.75:
                b = B["grassland"]
            elif tjan > 2 and tjul > 22 and a > 1.2:
                b = B["bamboo_forest"]
            else:
                b = B["temperate_forest"]
        else:                                                                       # tropical
            if a < 0.2:
                b = B["desert"]
            elif a < 0.42:
                b = B["steppe"]
            elif a < 0.9:
                b = B["grassland"]
            elif dry < 0.18:
                b = B["bamboo_forest"]                                              # R54: monsoon forest
            else:
                b = B["jungle"]
        return b

    def tiles(self):
        W, H, P, k = self.W, self.H, self.P, self.k
        h = self.h
        hw = max(1, round(2 * k))

        def run_ext(vals, fn):                                                      # separable max or min
            tmp = [0.0] * (W * H)
            out = [0.0] * (W * H)
            for y in range(H):
                row = vals[y * W:(y + 1) * W]
                for x in range(W):
                    tmp[y * W + x] = fn(row[max(0, x - hw):x + hw + 1])
            for x in range(W):
                col = tmp[x::W]
                for y in range(H):
                    out[y * W + x] = fn(col[max(0, y - hw):y + hw + 1])
            return out

        hl = [max(0.0, v) for v in h]
        rel = [a - b for a, b in zip(run_ext(hl, max), run_ext(hl, min))]          # relief over about 180 km
        self.relief = rel
        pet = P["pet_mm_per_c"]
        biome = [B["sea"]] * (W * H)
        cw_tj, cw_tl, cw_pt, cw_dr, cw_kn, cw_bn = ([0.0] * (W * H) for _ in range(6))  # kept for refine()
        wk = 7.0 * k                                                                # R56: warp biome borders
        for i in range(W * H):
            if self.ocean[i]:
                continue
            x, y = i % W, i // W
            wx = min(W - 1, max(0, int(x + wk * self.nz.fbm(x / (12.0 * k) + 500, y / (12.0 * k), 3))))
            wy = min(H - 1, max(0, int(y + wk * self.nz.fbm(x / (12.0 * k), y / (12.0 * k) + 500, 3))))
            j = wy * W + wx
            if self.ocean[j]:
                j = i
            ptot = self.pjan[j] + self.pjul[j]
            petv = pet * (max(0.0, self.tjan[j]) + max(0.0, self.tjul[j]))
            alpha = ptot / petv if petv > 1.0 else 3.0
            cw_tj[i] = self.tjan[i] + (self.tjan[j] - self.tjan[i]) * 0.7
            cw_tl[i] = self.tjul[i] + (self.tjul[j] - self.tjul[i]) * 0.7
            cw_pt[i] = ptot
            cw_dr[i] = min(self.pjan[j], self.pjul[j]) / max(1.0, ptot)
            cw_kn[i] = self.nz3.fbm(x / (40.0 * k) + 70.0, y / (40.0 * k) - 20.0, 3)
            cw_bn[i] = self.nz2.fbm(x / (30.0 * k) - 50.0, y / (30.0 * k) + 25.0, 3)
            if self.lake[i]:
                biome[i] = B["salt_flats"] if alpha < 0.35 else B["lake"]
                continue
            coast_adj = any(0 <= x + ox < W and 0 <= y + oy < H and self.ocean[(y + oy) * W + x + ox]
                            for ox, oy in N8)
            c = {
                "tjan": cw_tj[i], "tjul": cw_tl[i], "alpha": alpha, "dry": cw_dr[i],
                "hkm": max(0.0, h[i]), "relief": rel[i], "coast_adj": coast_adj,
                "major": self.flux[i] >= self.major_thr, "arid_lake": False,
                "karst_n": cw_kn[i], "bad_n": cw_bn[i],
            }
            biome[i] = self.classify(c)
        self.cw = (cw_tj, cw_tl, cw_pt, cw_dr, cw_kn, cw_bn)
        rv = max(1, round(1.5 * k))
        for vx, vy in self.vents:                                                  # R26: volcano cones
            for oy in range(-rv, rv + 1):
                for ox in range(-rv, rv + 1):
                    x, y = vx + ox, vy + oy
                    if 0 <= x < W and 0 <= y < H and not self.ocean[y * W + x] and ox * ox + oy * oy <= rv * rv:
                        biome[y * W + x] = B["volcano"]
        self.biome = biome
        self.T = [{"sea": self.ocean[i], "lake": self.lake[i], "hkm": max(0.0, h[i]), "t": self.temp[i],
                   "p": self.rain[i], "river": self.river_cell[i]} for i in range(W * H)]

    # -- R28: features ------------------------------------------------------------------------------------------
    def features(self):
        TW, TH, T, biome, rng, k = self.TW, self.TH, self.T, self.biome, self.rng, self.k
        feat = [0] * (TW * TH)
        for i, t in enumerate(T):
            if t["sea"]:
                continue
            if t["river"]:
                feat[i] |= F["river"]
            if t["lake"]:
                feat[i] |= F["lake"]
        for vx, vy in self.vents:
            kk = vy * TW + vx
            feat[kk] |= F["lava"]
            cur = kk
            for _ in range(max(2, round(2 * k))):                                   # a short lava flow
                x, y = cur % TW, cur // TW
                best, bk = T[cur]["hkm"], -1
                for ox, oy in N8:
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < TW and 0 <= ny < TH:
                        j = ny * TW + nx
                        if not T[j]["sea"] and T[j]["hkm"] < best:
                            best, bk = T[j]["hkm"], j
                if bk < 0:
                    break
                feat[bk] |= F["lava"]
                cur = bk
            reach = max(5, round(5 * k))
            near = [yy * TW + xx for yy in range(max(0, vy - reach), min(TH, vy + reach + 1))
                    for xx in range(max(0, vx - reach), min(TW, vx + reach + 1))
                    if biome[yy * TW + xx] not in (B["sea"], B["volcano"])
                    and max(abs(xx - vx), abs(yy - vy)) >= 2]
            for j in rng.sample(near, min(len(near), rng.randint(1, 2))):
                feat[j] |= F["hot_spring"]
        for i in range(TW * TH):
            x, y = i % TW, i // TW
            if biome[i] == B["glacier"]:
                core = all(0 <= x + ox < TW and 0 <= y + oy < TH and biome[(y + oy) * TW + x + ox] == B["glacier"]
                           for ox, oy in N8)
                if core or self.tjul[i] <= -6.0:
                    feat[i] |= F["ice_field"]
            elif biome[i] == B["karst"]:
                if all(0 <= x + ox < TW and 0 <= y + oy < TH and biome[(y + oy) * TW + x + ox] == B["karst"]
                       for ox, oy in N4):
                    feat[i] |= F["karst_core"]
            elif biome[i] in (B["high_mountain"], B["highland"], B["badlands"]):
                if self.nz2.fbm(x / (18.0 * k) + 90.0, y / (18.0 * k), 2) > 0.38:
                    feat[i] |= F["ore_vein"]
        self.feat = feat

    # -- map check (observations only) --------------------------------------------------------------------------
    def check(self):
        TW, TH, W, H = self.TW, self.TH, self.W, self.H
        land_tiles = [i for i in range(TW * TH) if self.biome[i] != B["sea"]]
        counts = {key: 0 for key, _, _ in BIOMES}
        for i in range(TW * TH):
            counts[BIOMES[self.biome[i]][0]] += 1
        landmask = [b != B["sea"] for b in self.biome]
        comps = sorted(components(TW, TH, landmask), key=len, reverse=True)
        uphill = sum(1 for i in range(W * H) if self.down[i] >= 0 and not self.ocean[self.down[i]]
                     and self.filled[self.down[i]] > self.filled[i])
        mouths = sum(1 for i in range(W * H) if self.river_cell[i] and self.down[i] >= 0
                     and self.ocean[self.down[i]])
        lakes = sorted((len(c) for c in components(TW, TH, self.lake, N8)), reverse=True)
        salt = components(TW, TH, [b == B["salt_flats"] for b in self.biome], N8)
        shore = [i for i in range(W * H) if not self.ocean[i] and any(                    # R61: box counting
            0 <= i % W + ox < W and 0 <= i // W + oy < H and self.ocean[(i // W + oy) * W + i % W + ox]
            for ox, oy in N4)]
        pts = []
        for s in (1, 2, 4, 8, 16):
            pts.append((math.log(1.0 / s), math.log(max(1, len({(i % W // s, i // W // s) for i in shore})))))
        mx = sum(p[0] for p in pts) / len(pts)
        my = sum(p[1] for p in pts) / len(pts)
        dim = sum((p[0] - mx) * (p[1] - my) for p in pts) / sum((p[0] - mx) ** 2 for p in pts)
        parts_n = {1: 0, 2: 0, 3: 0}                                                       # R68, R70
        as_part = {key: 0 for key, _, _ in BIOMES}
        main_share = []
        for i in land_tiles:
            m = self.mix[i]
            parts_n[min(3, len(m))] += 1
            for t, _ in m:
                as_part[BIOMES[t][0]] += 1
            main_share.append(next((v for t, v in m if t == self.biome[i]), 0))
        fine_counts = [0] * len(BIOMES)
        for t in self.fterr:
            fine_counts[t] += 1
        self.stats = {
            "fine_grid": [self.FW, self.FH],
            "fine_cell_km": round(self.cell_km / self.f, 2),
            "land_tiles_by_parts": parts_n,
            "mixed_land_tile_share": round(1 - parts_n[1] / max(1, len(land_tiles)), 3),
            "mean_main_share": round(sum(main_share) / max(1, len(main_share)), 1),
            "tiles_with_biome_as_part": as_part,
            "fine_cells_by_biome": {BIOMES[t][0]: c for t, c in enumerate(fine_counts)},
            "missing_biomes_fine": [BIOMES[t][0] for t, c in enumerate(fine_counts) if c == 0],
            "river_tiles": sum(1 for v in self.feat if v & F["river"]),
            "coast_fractal_dim": round(dim, 3),
            "coast_cells": len(shore),
            "seed": self.seed,
            "land_share": round(len(land_tiles) / (TW * TH), 3),
            "main_landmass_share_of_land": round(len(comps[0]) / max(1, len(land_tiles)), 3) if comps else 0,
            "islands": max(0, len(comps) - 1),
            "biome_tiles": counts,
            "biome_share_of_land": {k_: round(v / max(1, len(land_tiles)), 3) for k_, v in counts.items()
                                    if k_ != "sea"},
            "missing_biomes": [k_ for k_, v in counts.items() if v == 0],
            "river_mouths": mouths,
            "lakes": len(lakes),
            "largest_lakes_tiles": lakes[:5],
            "salt_flats": len(salt),
            "volcanoes": len(self.vents),
            "highest_peak_km": round(max(self.h), 2),
            "rivers_uphill": uphill,
            "rivers_splitting": 0,
        }

    # -- outputs ------------------------------------------------------------------------------------------------
    def save(self, out):
        os.makedirs(out, exist_ok=True)
        TW, TH, P = self.TW, self.TH, self.P
        pal = []
        for _, _, col in BIOMES:
            pal.extend(col)
        pal.extend([0] * (768 - len(pal)))
        img = Image.new("P", (TW, TH))
        img.putpalette(pal)
        img.putdata(self.biome)
        img.save(os.path.join(out, "biome.png"))
        elev = Image.new("I;16", (TW, TH))
        elev.putdata([int(max(0, min(65535, 10000 + v * 1000))) for v in self.h])
        elev.save(os.path.join(out, "elevation.png"))
        temp = Image.new("L", (TW, TH))
        temp.putdata([int(max(0, min(255, (t + 50) * 2))) for t in self.temp])
        temp.save(os.path.join(out, "temperature.png"))
        rain = Image.new("I;16", (TW, TH))
        rain.putdata([int(max(0, min(65535, p))) for p in self.rain])
        rain.save(os.path.join(out, "rainfall.png"))
        feat = Image.new("I;16", (TW, TH))
        feat.putdata(self.feat)
        feat.save(os.path.join(out, "features.png"))
        FW, FH = self.FW, self.FH                                                    # R66: the fine map
        fimg = Image.frombytes("P", (FW, FH), bytes(self.fterr))
        fimg.putpalette(pal)
        fimg.save(os.path.join(out, "fine_biome.png"))
        fel = Image.new("I;16", (FW, FH))
        fel.putdata([int(max(0, min(65535, 10000 + v * 1000))) for v in self.fh])
        fel.save(os.path.join(out, "fine_elevation.png"))
        wat = bytearray(FW * FH)
        for i in range(FW * FH):
            t = self.fterr[i]
            wat[i] = 1 if t == B["sea"] else 2 if t == B["lake"] else 0
        for j in self.rflux:
            wat[j] |= 4
        Image.frombytes("L", (FW, FH), bytes(wat)).save(os.path.join(out, "fine_water.png"))
        mt, ms = bytearray(3 * TW * TH), bytearray(3 * TW * TH)                     # R68: each tile's mix
        for i, m in enumerate(self.mix):
            for q in range(3):
                mt[3 * i + q], ms[3 * i + q] = (m[q][0], m[q][1]) if q < len(m) else (255, 0)
        Image.frombytes("RGB", (TW, TH), bytes(mt)).save(os.path.join(out, "mix_biome.png"))
        Image.frombytes("RGB", (TW, TH), bytes(ms)).save(os.path.join(out, "mix_share.png"))
        legend = {
            "biome_ids": {i: key for i, (key, _, _) in enumerate(BIOMES)},
            "biome_png": "per tile: the main biome (largest share; sea when sea is half the tile or more)",
            "mix_biome_png": "per tile, RGB: the ids of up to 3 biomes in the tile, largest first; 255 = none",
            "mix_share_png": "per tile, RGB: each biome's share in percent, summing to 100",
            "fine_biome_png": "per fine cell (fine_factor x finer): one biome",
            "fine_elevation_png": "per fine cell, 16-bit: metres + 10000",
            "fine_water_png": "per fine cell, bits: 1 sea, 2 lake, 4 river",
            "feature_bits": {key: F[key] for key, _ in FEATURES},
            "elevation": "16-bit: metres + 10000 (sea floor below 10000)",
            "temperature": "8-bit: (annual mean degC + 50) x 2",
            "rainfall": "16-bit: annual mm",
        }
        meta = {"seed": self.seed, "params": P, "legend": legend, "stats": self.stats,
                "rules": "design/research/map-making-rules.md"}
        with open(os.path.join(out, "meta.json"), "w", encoding="utf-8") as fh:
            json.dump(meta, fh, indent=1)
        self.render_preview(os.path.join(out, "preview.png"), os.path.join(out, "detail.jpg"))
        self.render_tiles(os.path.join(out, "tiles.png"))

    def render_preview(self, path, detail_path):
        """R57-R60 on the fine map: natural colours, soft biome edges, multi-light hillshade, depth-shaded sea,
        smooth rivers that widen downstream. Writes the full-size detail picture and a half-size preview."""
        FW, FH, f, terr, hf = self.FW, self.FH, self.f, self.fterr, self.fh
        n = FW * FH
        SEA, LAKE, SALT = B["sea"], B["lake"], B["salt_flats"]
        cols = [c for _, _, c in BIOMES]
        sand = (178, 176, 132)
        base = bytearray(3 * n)
        for i in range(n):
            t = terr[i]
            c = sand if t == SEA else cols[t]
            base[3 * i], base[3 * i + 1], base[3 * i + 2] = c
        soft = Image.frombytes("RGB", (FW, FH), bytes(base)).filter(ImageFilter.GaussianBlur(1.1)).tobytes()
        del base
        lights = [(337.5, 0.55), (292.5, 0.15), (22.5, 0.15), (247.5, 0.15)]           # R57
        ex = 9.0
        ck = self.cell_km / f
        alt = math.radians(45.0)
        Ls = [(math.cos(alt) * math.sin(math.radians(a)), -math.cos(alt) * math.cos(math.radians(a)),
               math.sin(alt), w) for a, w in lights]
        sa = math.sin(alt)
        out = bytearray(3 * n)
        for y in range(FH):
            yu, yd = max(0, y - 1), min(FH - 1, y + 1)
            for x in range(FW):
                i = y * FW + x
                t = terr[i]
                if t == SEA:
                    d = min(1.0, max(0.0, -hf[i]) / 3.8) ** 0.35                          # R59
                    out[3 * i], out[3 * i + 1], out[3 * i + 2] = int(96 - 60 * d), int(138 - 64 * d), int(168 - 56 * d)
                    continue
                if t == LAKE:
                    out[3 * i], out[3 * i + 1], out[3 * i + 2] = 78, 120, 156
                    continue
                xl, xr = max(0, x - 1), min(FW - 1, x + 1)
                dzdx = (max(0.0, hf[y * FW + xr]) - max(0.0, hf[y * FW + xl])) * ex / ((xr - xl) * ck)
                dzdy = (max(0.0, hf[yd * FW + x]) - max(0.0, hf[yu * FW + x])) * ex / ((yd - yu) * ck)
                nlen = math.sqrt(dzdx * dzdx + dzdy * dzdy + 1.0)
                nx_, ny_, nz_ = -dzdx / nlen, -dzdy / nlen, 1.0 / nlen
                sh = 0.0
                for lx, ly, lz, w in Ls:
                    v = nx_ * lx + ny_ * ly + nz_ * lz
                    if v > 0:
                        sh += w * v
                m = (0.45 + 0.85 * sh / sa) * (1.0 + 0.04 * hf[i])
                if t == SALT:
                    r_, g_, b_ = 232, 228, 214
                else:
                    r_, g_, b_ = soft[3 * i], soft[3 * i + 1], soft[3 * i + 2]
                out[3 * i] = min(255, int(r_ * m))
                out[3 * i + 1] = min(255, int(g_ * m))
                out[3 * i + 2] = min(255, int(b_ * m))
        img = Image.frombytes("RGB", (FW, FH), bytes(out))
        del out
        dr = ImageDraw.Draw(img)
        for pts, fl in sorted(self.rlines, key=lambda q: q[1]):                    # R60: rivers widen
            w = max(1, min(7, int(1.3 * math.sqrt(fl / self.river_thr))))
            dr.line(pts, fill=(72, 114, 152), width=w, joint="curve")
        for vx, vy in self.vents:
            x, y = (vx + 0.5) * f, (vy + 0.5) * f
            dr.polygon([(x, y - 10), (x - 8, y + 6), (x + 8, y + 6)], fill=(140, 44, 34))
        img.save(detail_path, quality=88)
        img.resize((FW // 2, FH // 2), Image.LANCZOS).save(path)

    def render_tiles(self, path, scale=None):
        """The game grid: each tile coloured by its mix (R68), with rivers, lakes and features marked."""
        TW, TH = self.TW, self.TH
        scale = scale or max(1, round(1080 / TW))
        img = Image.new("RGB", (TW, TH))
        px = img.load()
        for i in range(TW * TH):
            fl = self.feat[i]
            r_ = g_ = b_ = 0.0
            for t, v in self.mix[i]:
                c = BIOMES[t][2]
                r_ += c[0] * v / 100.0
                g_ += c[1] * v / 100.0
                b_ += c[2] * v / 100.0
            col = (int(r_), int(g_), int(b_))
            if self.biome[i] != B["sea"]:
                if fl & F["river"]:
                    col = tuple(int(0.55 * a + 0.45 * b) for a, b in zip(col, (104, 140, 176)))
                if fl & F["lava"]:
                    col = (214, 64, 36)
                elif fl & F["hot_spring"]:
                    col = (246, 168, 60)
                elif fl & F["ore_vein"]:
                    col = tuple(int(ch * 0.6) for ch in col)
            px[i % TW, i // TW] = col
        img = img.resize((TW * scale, TH * scale), Image.NEAREST)
        img.save(path)


def parse_seeds(s):
    out = []
    for part in s.split(","):
        if "-" in part:
            a, b = part.split("-")
            out.extend(range(int(a), int(b) + 1))
        else:
            out.append(int(part))
    return out


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--seeds", default="1")
    ap.add_argument("--out", default="prototypes/continent-candidates")
    args = ap.parse_args()
    for seed in parse_seeds(args.seeds):
        c = Continent(seed).run()
        out = os.path.join(args.out, "cand-%02d" % seed)
        c.save(out)
        s = c.stats
        print("seed %d: land %.0f%%, main %.0f%%, islands %d, rivers to sea %d, lakes %d (largest %s), "
              "volcanoes %d, peak %.1f km, missing %s"
              % (seed, s["land_share"] * 100, s["main_landmass_share_of_land"] * 100, s["islands"],
                 s["river_mouths"], s["lakes"], s["largest_lakes_tiles"][:3], s["volcanoes"],
                 s["highest_peak_km"], ",".join(s["missing_biomes"]) or "-"), flush=True)


if __name__ == "__main__":
    main()
