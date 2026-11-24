"""Travel & Map Formula C, land qi on the fine map (design/gdd/travel-map.md rules 1-4, Formulas C; user decision
2026-11-20: build the fine-cell Formula C before the world goes into the game).

Built once from the approved continent, cell by cell on the 2,160 x 1,440 fine map (base/fine_biome.png,
fine_water.png, fine_elevation.png), the tile feature layer (base/features.png) and the sacred layer (sacred.json:
spirit veins, sacred summits, deep caves, the miasma source and its wasteland, the derived snowline, storm peaks and
high plateau):

1. depth: t = clamp((d - 1) / (d_full - 1), 0, 1), d the chamfer distance (8 neighbours, diagonal sqrt 2) to the
   nearest cell whose biome has a different signature, or none;
2. own profile: P = norm(P_b + t * sigma_b * e_sig);
3. blending: B = the mean of P over the (2r + 1)^2 window (cells off the map ignored; sea and lake cells count);
4. features: fall_f = max(0, 1 - delta_f / R_f) per instance (nearest cell of the instance), instances of a kind add
   up; Delta_e = sum A_f,e * fall_f; base shares s = norm(B + Delta), variants v = Delta (outside the 100);
5. density D4 = clamp(b_b + t * g_D,b + sum a_f * fall_f + o_kind, 0.3, 2.4) (o_kind only at places);
   danger X = x_b + round(t * g_X,b + sum x_f * fall_f), a settlement lowering it by its row's danger_cut (rule 6).

Each tile part (the tile's up to three biomes, base/mix_biome.png and mix_share.png; the cells of a folded biome count
with the largest part) reads the mean of its own cells (Formulas C part_values). A place reads the part of its own
biome (else the largest), plus its kind's o_kind.

Parameters: assets/data/world_map.json "land". Outputs:
- assets/map/continent_11_qi.bin: per tile and part (k = 1..3), the five base shares and eight variants (x 100,
  u16), density (x 1000, u16) and danger (u8), in the DAOGRID1 layer format ContinentGrid reads;
- design/map/continent-11/land_qi.json: every place's (and every hidden slot candidate's) values, the world means
  mu_e (Formula A), and the check against Formula C's map targets (observations, never a verdict);
- with --fit: o_kind per kind row, chosen to bring each row to its density band and share at 1.4 or more, written
  back into world_map.json.

Run: python tools/design/map/land_qi.py [--fit] [--map design/map/continent-11]
"""
import argparse
import json
import math
import os
import struct
import sys
import time
import zlib
from collections import deque

import numpy as np
from PIL import Image

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
BASE = ["moc", "hoa", "tho", "kim", "thuy"]
VARIANTS = ["phong", "huyet", "hu_khong", "loi", "am", "hon_don", "quang", "bang"]
ELS = BASE + VARIANTS
TAGS = {"moc": "MO", "hoa": "HO", "tho": "TH", "kim": "KI", "thuy": "TY", "phong": "PH", "huyet": "HU",
        "hu_khong": "HK", "loi": "LO", "am": "AM", "hon_don": "HD", "quang": "QU", "bang": "BA"}
TILE_BITS = {"lava": 1, "hot_spring": 2, "ice_field": 4, "ore_vein": 32, "karst_core": 64}
OFFS = [(1, 0, 1.0), (-1, 0, 1.0), (0, 1, 1.0), (0, -1, 1.0),
        (1, 1, math.sqrt(2)), (-1, 1, math.sqrt(2)), (1, -1, math.sqrt(2)), (-1, -1, math.sqrt(2))]
WATER_SEA, WATER_LAKE, WATER_RIVER = 1, 2, 4
NONE_BIOME = 255
SETTLED_ROW = "settlement"


def nb(a, ox, oy, fill):
    """out[y, x] = a[y + oy, x + ox], fill off the array."""
    out = np.full_like(a, fill)
    h, w = a.shape
    ys, yd = (slice(oy, h), slice(0, h - oy)) if oy >= 0 else (slice(0, h + oy), slice(-oy, h))
    xs, xd = (slice(ox, w), slice(0, w - ox)) if ox >= 0 else (slice(0, w + ox), slice(-ox, w))
    out[yd, xd] = a[ys, xs]
    return out


def chamfer(seed, steps, same=None):
    """Chamfer distance (in cells) from the True cells of seed, propagated at most `steps` times; where `same` is
    given, only between cells of equal `same` value. Cells never reached stay at inf."""
    d = np.where(seed, 0.0, np.inf).astype(np.float32)
    masks = [nb(same, ox, oy, -1) == same for ox, oy, _ in OFFS] if same is not None else None
    for _ in range(int(math.ceil(steps)) + 1):
        before = d
        for j, (ox, oy, c) in enumerate(OFFS):
            cand = nb(d, ox, oy, np.inf) + np.float32(c)
            if masks is not None:
                cand = np.where(masks[j], cand, np.inf)
            d = np.minimum(d, cand)
        if np.array_equal(before, d):
            break
    return d


def components(cells):
    """8-connected groups of a set of (x, y) cells."""
    left = set(cells)
    out = []
    while left:
        start = left.pop()
        comp, q = [start], deque([start])
        while q:
            x, y = q.popleft()
            for ox in (-1, 0, 1):
                for oy in (-1, 0, 1):
                    n = (x + ox, y + oy)
                    if n in left:
                        left.remove(n)
                        comp.append(n)
                        q.append(n)
        out.append(comp)
    return out


class Land:
    def __init__(self, m, params):
        self.m, self.P = m, params
        base = os.path.join(m, "base")
        self.biome = np.array(Image.open(os.path.join(base, "fine_biome.png")), dtype=np.int16)
        self.water = np.array(Image.open(os.path.join(base, "fine_water.png")), dtype=np.uint8)
        self.H, self.W = self.biome.shape
        self.f = int(params["fine_factor"])
        self.TW, self.TH = self.W // self.f, self.H // self.f
        self.km = float(params["cell_km"])
        self.feat = np.array(Image.open(os.path.join(base, "features.png")), dtype=np.int32)
        mb = np.array(Image.open(os.path.join(base, "mix_biome.png")).convert("RGB"), dtype=np.int16)
        ms = np.array(Image.open(os.path.join(base, "mix_share.png")).convert("RGB"), dtype=np.int16)
        self.mix_b, self.mix_s = mb, ms
        self.sacred = json.load(open(os.path.join(m, "sacred.json"), encoding="utf-8"))
        bios = params["biomes"]
        self.by_id = {int(b["id"]): (k, b) for k, b in bios.items()}
        n = max(self.by_id) + 1
        lut = lambda fn, dt: np.array([fn(self.by_id[i][1]) if i in self.by_id else 0 for i in range(256)], dtype=dt)
        self.lut_sig = lut(lambda b: 0 if b["sig"] is None else BASE.index(b["sig"]) + 1, np.int8)
        self.lut_sigma = lut(lambda b: b["sigma"], np.float32)
        self.lut_b = lut(lambda b: b["b"], np.float32)
        self.lut_gd = lut(lambda b: b["g_d"], np.float32)
        self.lut_x = lut(lambda b: b["x"], np.float32)
        self.lut_gx = lut(lambda b: b["g_x"], np.float32)
        self.lut_prof = np.zeros((256, 5), dtype=np.float32)
        for i, (_, b) in self.by_id.items():
            self.lut_prof[i] = [b["profile"][e] for e in BASE]
        del n

    # -- steps 1-3 -------------------------------------------------------------------------------------------------
    def depth(self):
        sig = self.lut_sig[self.biome]
        edge = np.zeros(sig.shape, dtype=bool)
        for ox, oy, _ in OFFS:
            edge |= nb(sig, ox, oy, -1) != sig
        full = self.P["depth_full_km"] / self.km
        d = chamfer(edge & (sig > 0), full, same=sig)
        d = np.where(sig > 0, d + 1.0, 0.0)                      # an edge cell has d = 1
        t = np.clip((d - 1.0) / (full - 1.0), 0.0, 1.0)
        self.sig, self.t = sig, np.where(sig > 0, t, 0.0).astype(np.float32)

    def profile(self):
        P = self.lut_prof[self.biome].copy()
        push = self.t * self.lut_sigma[self.biome]
        for k in range(5):
            P[..., k] += np.where(self.sig == k + 1, push, 0.0)
        self.Pown = P * (100.0 / P.sum(axis=-1, keepdims=True))

    def blend(self):
        r = int(round(self.P["blend_radius_km"] / self.km))
        H, W = self.H, self.W

        def box(a):
            s = np.zeros((H + 1, W + 1), dtype=np.float64)
            s[1:, 1:] = a.cumsum(0).cumsum(1)
            y0 = np.clip(np.arange(H) - r, 0, H)
            y1 = np.clip(np.arange(H) + r + 1, 0, H)
            x0 = np.clip(np.arange(W) - r, 0, W)
            x1 = np.clip(np.arange(W) + r + 1, 0, W)
            return s[y1][:, x1] - s[y0][:, x1] - s[y1][:, x0] + s[y0][:, x0]

        cnt = box(np.ones((H, W)))
        self.B = np.stack([box(self.Pown[..., k]) / cnt for k in range(5)], axis=-1).astype(np.float32)
        self.blend_r = r

    # -- step 4: features --------------------------------------------------------------------------------------------
    def tile_cells(self, tiles, land_only=True):
        f = self.f
        cells = []
        for (tx, ty) in tiles:
            for cy in range(ty * f, ty * f + f):
                for cx in range(tx * f, tx * f + f):
                    if 0 <= cx < self.W and 0 <= cy < self.H:
                        if not land_only or self.water[cy, cx] not in (WATER_SEA, WATER_LAKE):
                            cells.append((cx, cy))
        return cells

    def instances(self):
        """(kind, cells, density override or None) for every feature instance."""
        out = []
        for kind, bit in TILE_BITS.items():
            ys, xs = np.nonzero(self.feat & bit)
            for comp in components(list(zip(xs.tolist(), ys.tolist()))):
                out.append((kind, self.tile_cells(comp), None))
        ys, xs = np.nonzero((self.water == WATER_RIVER) | (self.water == WATER_LAKE))
        for comp in components(list(zip(xs.tolist(), ys.tolist()))):
            out.append(("river", comp, None))
        S = self.sacred
        grades = self.P["features"]["spirit_vein"]["density_by_grade"]
        for v in S["spirit_veins"]:
            out.append(("spirit_vein", self.tile_cells([tuple(t) for t in v["tiles"]]), float(grades[str(v["grade"])])))
        for s in S["sacred_summits"]:
            out.append(("sacred_summit", self.tile_cells([tuple(s["tile"])]), None))
        for c in S["deep_caves"]:
            out.append(("deep_cave", self.tile_cells([tuple(c["tile"])]), None))
        if S.get("miasma_source"):
            out.append(("miasma_source", self.tile_cells([tuple(S["miasma_source"]["tile"])]), None))
        if S.get("miasma_wasteland"):
            out.append(("miasma_land", self.tile_cells([tuple(t) for t in S["miasma_wasteland"]["tile_list"]]), None))
        for kind, tiles in S.get("derived", {}).items():
            for comp in components([tuple(t) for t in tiles]):
                out.append((kind, self.tile_cells(comp), None))
        return [i for i in out if i[1]]

    def features(self):
        H, W = self.H, self.W
        self.delta = np.zeros((H, W, len(ELS)), dtype=np.float32)
        self.dens_add = np.zeros((H, W), dtype=np.float32)
        self.dang_add = np.zeros((H, W), dtype=np.float32)
        self.fall_by_kind = {}
        insts = self.instances()
        self.n_instances = {}
        for kind, cells, dens in insts:
            F = self.P["features"][kind]
            R = float(F["reach_km"]) / self.km
            pad = int(math.ceil(R)) + 1
            xs = [c[0] for c in cells]
            ys = [c[1] for c in cells]
            x0, x1 = max(0, min(xs) - pad), min(W, max(xs) + pad + 1)
            y0, y1 = max(0, min(ys) - pad), min(H, max(ys) + pad + 1)
            seed = np.zeros((y1 - y0, x1 - x0), dtype=bool)
            seed[np.array(ys) - y0, np.array(xs) - x0] = True
            d = chamfer(seed, R)
            fall = np.clip(1.0 - d / R, 0.0, 1.0).astype(np.float32)
            for e, a in F.get("push", {}).items():
                self.delta[y0:y1, x0:x1, ELS.index(e)] += float(a) * fall
            self.dens_add[y0:y1, x0:x1] += (float(dens) if dens is not None else float(F.get("density", 0.0))) * fall
            self.dang_add[y0:y1, x0:x1] += float(F.get("danger", 0.0)) * fall
            self.n_instances[kind] = self.n_instances.get(kind, 0) + 1

    def finish(self):
        b = self.B + self.delta[..., :5]
        self.s = b * (100.0 / b.sum(axis=-1, keepdims=True))
        self.v = self.delta[..., 5:]
        self.raw_d = self.lut_b[self.biome] + self.t * self.lut_gd[self.biome] + self.dens_add
        self.D = np.clip(self.raw_d, self.P["density_min"], self.P["density_max"])
        self.X = self.lut_x[self.biome] + np.floor(self.t * self.lut_gx[self.biome] + self.dang_add + 0.5)

    # -- parts ----------------------------------------------------------------------------------------------------
    def parts(self):
        f = self.f
        mb = np.repeat(np.repeat(self.mix_b, f, axis=0), f, axis=1)[: self.H, : self.W]
        part = np.zeros((self.H, self.W), dtype=np.int64)
        for k in (2, 1):                                           # a folded biome counts with the largest part
            part = np.where(self.biome == mb[..., k], k, part)
        part = np.where(self.biome == mb[..., 0], 0, part)
        ty, tx = np.divmod(np.arange(self.H * self.W), self.W)
        ty, tx = ty // f, tx // f
        idx = ((ty * self.TW + tx) * 3 + part.ravel())
        n = self.TW * self.TH * 3
        cnt = np.bincount(idx, minlength=n).astype(np.float64)
        safe = np.where(cnt > 0, cnt, 1.0)

        def mean(a):
            return np.bincount(idx, weights=a.ravel().astype(np.float64), minlength=n) / safe

        self.part_cnt = cnt.reshape(self.TH, self.TW, 3)
        self.part_s = np.stack([mean(self.s[..., k]) for k in range(5)], -1).reshape(self.TH, self.TW, 3, 5)
        self.part_v = np.stack([mean(self.v[..., k]) for k in range(8)], -1).reshape(self.TH, self.TW, 3, 8)
        self.part_d = mean(self.D).reshape(self.TH, self.TW, 3)
        self.part_raw = mean(self.raw_d).reshape(self.TH, self.TW, 3)
        self.part_x = np.floor(mean(self.X) + 0.5).reshape(self.TH, self.TW, 3)

    def part_of(self, tile, biome_name):
        """A place's part: the part holding its own biome, else the largest."""
        tx, ty = tile
        want = self.P["biomes"].get(biome_name.replace(" ", "_").lower(), {}).get("id")
        for k in range(3):
            if want is not None and int(self.mix_b[ty, tx, k]) == want and self.part_cnt[ty, tx, k] > 0:
                return k
        return 0

    def land_part(self, tile):
        """The largest part of a tile that is neither sea nor lake (else the largest)."""
        tx, ty = tile
        for k in range(3):
            b = int(self.mix_b[ty, tx, k])
            if b != NONE_BIOME and b not in (17, 18) and self.part_cnt[ty, tx, k] > 0:
                return k
        return 0

    def values(self, tile, k):
        tx, ty = tile
        s = self.part_s[ty, tx, k]
        v = self.part_v[ty, tx, k]
        return {
            "part": k, "biome": self.by_id.get(int(self.mix_b[ty, tx, k]), ("?",))[0],
            "shares": {e: round(float(s[i]), 2) for i, e in enumerate(BASE)},
            "variants": {e: round(float(v[i]), 2) for i, e in enumerate(VARIANTS) if v[i] >= 0.005},
            "land_density": round(float(self.part_d[ty, tx, k]), 3),
            "raw_density": round(float(self.part_raw[ty, tx, k]), 3),
            "land_danger": int(self.part_x[ty, tx, k]),
        }


def place_list(m, cont):
    """Every place the targets count: the exported ones, the famous sites and one spot per hidden slot (each
    candidate weighted 1/n)."""
    out = []
    for p in cont["places"]:
        # the provinces-v2 places (v2_slot) get their values but weigh 0 in the targets and mu, so Formula A's world
        # means stay those of the authored places (user decisions 2026-11-24)
        out.append({"id": p["id"], "name": p["name"], "kind": p["kind"], "tile": p["tile"], "biome": p.get("biome", ""),
                    "region": p["region"], "w": 0.0 if p.get("v2_slot") else 1.0})
    h = json.load(open(os.path.join(m, "history.json"), encoding="utf-8"))
    regions = {r["name"]: r["id"] for r in cont["regions"]}
    for group, kind in (("secret_realms", "secret_realm"), ("ruins", "ruin"), ("blessed_small", "blessed_land"),
                        ("blessed_large", "blessed_land")):
        for s in h["famous"].get(group, []):
            tile = s.get("tile") or s.get("centre")
            out.append({"id": "famous:" + s["name_hv"], "name": s["name_hv"], "kind": kind, "tile": tile, "biome": "",
                        "region": regions.get(s.get("region"), 0), "w": 1.0})
    hk = {"secret_realm": "secret_realm", "ruin": "ruin", "abode": "abode", "blessed_small": "blessed_land",
          "blessed_large": "blessed_land"}
    for s in h["hidden"]:
        n = len(s["candidates"])
        for i, c in enumerate(s["candidates"]):
            out.append({"id": "slot:%s:%d" % (s["slot"], i), "name": s["slot"], "kind": hk[s["kind"]], "tile": c.get("tile") or c.get("centre"),
                        "biome": "", "region": regions.get(c.get("region"), 0), "w": 1.0 / n})
    return out


def place_values(L, P, places, rows=None):
    rows = rows or P["rows"]
    res = []
    for p in places:
        k = L.part_of(p["tile"], p["biome"]) if p["biome"] else L.land_part(p["tile"])
        v = L.values(p["tile"], k)
        row = P["kinds"][p["kind"]]
        o = float(rows[row]["o_kind"])
        v["density"] = round(min(P["density_max"], max(P["density_min"], v["raw_density"] + o)), 3)
        v["danger"] = max(1, v["land_danger"] - int(rows[row]["danger_cut"]))
        v["row"] = row
        res.append(dict(p, **v))
    return res


def fit_offsets(L, P, places):
    """o_kind per row in -0.2..0.8 (step 0.01), minimising |share at 1.4 or more - the row's target| + |mean density -
    the middle of the row's band|."""
    rows = json.loads(json.dumps(P["rows"]))
    for row, R in rows.items():
        mine = [p for p in places if P["kinds"][p["kind"]] == row]
        if not mine or R.get("fit") is False:
            continue
        raws = []
        for p in mine:
            k = L.part_of(p["tile"], p["biome"]) if p["biome"] else L.land_part(p["tile"])
            raws.append((float(L.part_raw[p["tile"][1], p["tile"][0], k]), p["w"]))
        best = None
        for step in range(-20, 81):
            o = step / 100.0
            ds = [(min(P["density_max"], max(P["density_min"], r + o)), w) for r, w in raws]
            wt = sum(w for _, w in ds)
            share = sum(w for d, w in ds if d >= 1.4) / wt
            mean = sum(d * w for d, w in ds) / wt
            mid = (R["band"][0] + R["band"][1]) / 2.0
            score = abs(share - R["share_1_4"]) + abs(mean - mid)
            if best is None or score < best[0]:
                best = (score, o)
        R["o_kind"] = best[1]
    return rows


def check(L, P, all_vals):
    """Formula C's map targets over the places of its table's rows (rows marked "fit": false, the blessed lands, are
    reported by row only: their richness is layer 3)."""
    T = P["targets"]
    vals = [p for p in all_vals if P["rows"][p["row"]].get("fit") is not False]
    wt = sum(p["w"] for p in vals)
    at = sum(p["w"] for p in vals if p["density"] >= 1.4) / wt
    mean = sum(p["density"] * p["w"] for p in vals) / wt
    mu = {e: sum(p["shares"][e] * p["w"] for p in vals) / wt / 100.0 for e in BASE}
    mu.update({e: sum(p["variants"].get(e, 0.0) * p["w"] for p in vals) / wt / 100.0 for e in VARIANTS})
    var_share = {e: round(sum(p["w"] for p in vals if p["variants"].get(e, 0.0) >= T["variant_place_min_share"]) / wt, 4)
                 for e in VARIANTS}
    rich = {}
    for e in BASE:
        hit = [p for p in vals if p["shares"][e] >= T["element_rich_share"]]
        rich[e] = {"places": round(sum(p["w"] for p in hit), 2), "regions": len({p["region"] for p in hit})}
    # wilderness land tiles with no place: the tile value over land parts
    occupied = {tuple(p["tile"]) for p in vals}
    w = L.part_cnt.copy()
    for k in range(3):
        w[..., k] = np.where(np.isin(L.mix_b[..., k], [17, 18, NONE_BIOME]), 0.0, w[..., k])
    tot = w.sum(-1)
    Vt = np.where(tot > 0, (L.part_d * w).sum(-1) / np.where(tot > 0, tot, 1), 0.0)
    land = (tot > 0) & (np.array([L.mix_b[..., 0] != 18]).squeeze())
    for (x, y) in occupied:
        land[y, x] = False
    wild_at = float((Vt[land] >= 1.4).mean())
    by_row = {}
    for p in all_vals:
        r = by_row.setdefault(p["row"], {"n": 0.0, "sum": 0.0, "at": 0.0, "min": 9.0, "max": 0.0})
        r["n"] += p["w"]
        r["sum"] += p["density"] * p["w"]
        r["at"] += p["w"] if p["density"] >= 1.4 else 0.0
        r["min"] = min(r["min"], p["density"])
        r["max"] = max(r["max"], p["density"])
    rows = {k: {"places": round(r["n"], 2), "mean": round(r["sum"] / r["n"], 3), "share_at_1_4": round(r["at"] / r["n"], 3),
                "range": [r["min"], r["max"]], "band": P["rows"][k]["band"], "target_share": P["rows"][k]["share_1_4"],
                "o_kind": P["rows"][k]["o_kind"]} for k, r in sorted(by_row.items())}

    def inside(x, lo_hi):
        return lo_hi[0] <= x <= lo_hi[1]

    obs = []
    if not inside(at, T["places_share_at_1_4"]):
        obs.append("places at 1.4+: %.3f outside %s" % (at, T["places_share_at_1_4"]))
    if not inside(mean, T["place_density_mean"]):
        obs.append("mean place density %.3f outside %s" % (mean, T["place_density_mean"]))
    if not inside(wild_at, T["wild_tiles_share_at_1_4"]):
        obs.append("wild land tiles at 1.4+: %.3f outside %s" % (wild_at, T["wild_tiles_share_at_1_4"]))
    for e in BASE:
        if not inside(mu[e], T["mu_base"]):
            obs.append("mu_%s %.3f outside %s" % (e, mu[e], T["mu_base"]))
        if rich[e]["places"] < T["element_rich_places_min"] or rich[e]["regions"] < T["element_rich_regions_min"]:
            obs.append("%s: %.1f places at share %d+ in %d regions (want %d in %d)" % (
                e, rich[e]["places"], T["element_rich_share"], rich[e]["regions"], T["element_rich_places_min"],
                T["element_rich_regions_min"]))
    for e, sh in var_share.items():
        if sh > T["variant_place_share_max"]:
            obs.append("variant %s at %.3f of places (max %.2f)" % (e, sh, T["variant_place_share_max"]))
    return {"places": round(wt, 2), "share_at_1_4": round(at, 4), "mean_density": round(mean, 4),
            "wild_tiles_share_at_1_4": round(wild_at, 4), "mu": {e: round(x, 4) for e, x in mu.items()},
            "variant_place_share": var_share, "element_rich": rich, "rows": rows, "observations": obs}


def write_bin(L, out_path):
    layers = []
    for k in range(3):
        for i, e in enumerate(BASE):
            layers.append(("S%d%s" % (k + 1, TAGS[e]), 2, np.round(L.part_s[..., k, i] * 100).astype(np.uint16)))
        for i, e in enumerate(VARIANTS):
            layers.append(("V%d%s" % (k + 1, TAGS[e]), 2, np.round(np.clip(L.part_v[..., k, i], 0, 655) * 100).astype(np.uint16)))
        layers.append(("DEN%d" % (k + 1), 2, np.round(L.part_d[..., k] * 1000).astype(np.uint16)))
        layers.append(("DAN%d" % (k + 1), 1, np.clip(L.part_x[..., k], 0, 255).astype(np.uint8)))
    blob = bytearray(b"DAOGRID1" + struct.pack("<HHH", L.TW, L.TH, len(layers)))
    for tag, nbytes, arr in layers:
        raw = arr.astype("<u2" if nbytes == 2 else "u1").tobytes()
        comp = zlib.compress(raw, 9)
        blob += tag.encode("ascii") + struct.pack("<BBII", nbytes, 0, len(raw), len(comp)) + comp
    with open(out_path, "wb") as fh:
        fh.write(blob)
    return len(blob)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", default=os.path.join(ROOT, "design", "map", "continent-11"))
    ap.add_argument("--fit", action="store_true")
    ap.add_argument("--no-bin", action="store_true")
    a = ap.parse_args()
    wm_path = os.path.join(ROOT, "assets", "data", "world_map.json")
    wm = json.load(open(wm_path, encoding="utf-8"))
    P = wm["land"]
    cont = json.load(open(os.path.join(ROOT, "assets", "data", "world_continent.json"), encoding="utf-8"))
    t0 = time.time()
    L = Land(a.map, P)
    steps = [("depth", L.depth), ("profile", L.profile), ("blend", L.blend), ("features", L.features),
             ("finish", L.finish), ("parts", L.parts)]
    timing = {}
    for name, fn in steps:
        t = time.time()
        fn()
        timing[name] = round(time.time() - t, 1)
    places = place_list(a.map, cont)
    if a.fit:
        P["rows"] = fit_offsets(L, P, places)
        wm["land"] = P
        with open(wm_path, "w", encoding="utf-8") as fh:
            json.dump(wm, fh, ensure_ascii=False, indent=2)
            fh.write("\n")
    vals = place_values(L, P, places)
    report = check(L, P, vals)
    out = {"_doc": "Output of tools/design/map/land_qi.py (Travel & Map Formula C on the fine map). places: every exported "
                   "place by id, each famous site (famous:<name>) and each hidden slot candidate (slot:<id>:<i>), with its part, "
                   "base shares, variants (outside the 100), land density (the part's mean), density (plus o_kind, clamped) and "
                   "danger (after the settlement cut). mu: Formula A's world mean shares over places. check: Formula C's map "
                   "targets (observations).",
           "params_file": "assets/data/world_map.json", "timing_s": timing, "instances": L.n_instances,
           "mu": report["mu"], "check": report,
           "places": [{k: p[k] for k in ("id", "name", "kind", "row", "tile", "part", "biome", "shares", "variants",
                                          "land_density", "density", "land_danger", "danger")} for p in vals]}
    with open(os.path.join(a.map, "land_qi.json"), "w", encoding="utf-8") as fh:
        json.dump(out, fh, ensure_ascii=False, indent=1)
        fh.write("\n")
    size = None
    if not a.no_bin:
        size = write_bin(L, os.path.join(ROOT, "assets", "map", "continent_11_qi.bin"))
    print(json.dumps({"seconds": round(time.time() - t0, 1), "timing": timing, "bin_bytes": size,
                      "share_at_1_4": report["share_at_1_4"], "mean_density": report["mean_density"],
                      "wild_tiles_share_at_1_4": report["wild_tiles_share_at_1_4"],
                      "mu": report["mu"], "element_rich": report["element_rich"],
                      "variant_place_share": report["variant_place_share"], "rows": report["rows"],
                      "observations": report["observations"]}, ensure_ascii=False, indent=1))


if __name__ == "__main__":
    sys.exit(main())
