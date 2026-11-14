"""Lay the history sites on the map: the famous ones, the same every game, and the candidate spots that each game's
roll picks from for the hidden ones (Travel & Map rules 15, 26, 28-30; Formula B and C targets; AC-TM-57, 97, 114).

Reads the saved map, places.json, sacred.json (through sacred.py, for the land density estimate and the features) and a
hand-edited history_proposal.json (the famous sites with their names and anchors, the hidden slots by kind and
element, and the tile secrets per region). Runs in under a minute.

What it lays:
- **Famous secret realms** (bí cảnh): a fixed entrance each, a cycle (rule 26) and the great sect that holds the land.
- **A famous ruin**, shown on the overview.
- **Famous blessed lands** (phúc địa), held by great sects: a large one grown around each tier-1 seat, and a small
  one-tile retreat near every great seat.
- **Hidden slots**, each with 2-4 candidate tiles in the wilderness, close enough to tell the same story (within
  `slot_spread` tiles) and far enough apart that a guide cannot give the spot away:
  - secret realms, ruins of vanished sects, dead cultivators' cave abodes;
  - large blessed lands (a blob of 40-180 tiles, no place inside) and small ones (one tile);
  each blessed land with the element it leans toward, on ground that suits it.
- **Tile secrets** (rule 29): a few per region (hidden spring, pocket vein, rare herb patch, buried cache), each with
  candidate tiles on ground that suits its kind.
The history (#27) names the hidden ones and links each to a fact; this tool only offers the ground.

The map check reports the places count, each kind's share against Formula C's table, the land density at each
candidate (the tile estimate from sacred.py), blob sizes, and that every candidate is wild land with no place on it.

It writes <map>/history.json and <map>/history.jpg.

Run:  python -I tools/design/map/history.py --map design/map/continent-11
"""

import argparse
import json
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import places as PL  # noqa: E402
import sacred as SA  # noqa: E402

from PIL import Image, ImageDraw, ImageFont  # noqa: E402

B = PL.B
INF = 1e9


def dist(a, b):
    return math.hypot(a[0] - b[0], a[1] - b[1])


def chamfer(W, H, src):
    """Distance in tiles (diagonal sqrt 2) from every tile to the nearest tile in src (a set of indices)."""
    d = [INF] * (W * H)
    for i in src:
        d[i] = 0.0
    fw = [(-1, -1, PL.SQ2), (0, -1, 1.0), (1, -1, PL.SQ2), (-1, 0, 1.0)]
    bw = [(1, 1, PL.SQ2), (0, 1, 1.0), (-1, 1, PL.SQ2), (1, 0, 1.0)]
    for nb, ys, xs in ((fw, range(H), range(W)), (bw, range(H - 1, -1, -1), range(W - 1, -1, -1))):
        for y in ys:
            row = y * W
            for x in xs:
                i = row + x
                v = d[i]
                for ox, oy, c in nb:
                    nx, ny = x + ox, y + oy
                    if 0 <= nx < W and 0 <= ny < H:
                        w = d[ny * W + nx] + c
                        if w < v:
                            v = w
                d[i] = v
    return d


class History:
    def __init__(self, M, S, D, prop, places):
        self.M, self.S, self.D, self.prop, self.P = M, S, D, prop, prop["params"]
        self.places = places + S.new_places
        W, H = M.W, M.H
        self.W, self.H = W, H
        n = W * H
        idx = M.idx
        self.biome = S.biome
        self.waste = {y * W + x for x, y in S.waste}
        self.d_place = chamfer(W, H, {idx(*p["tile"]) for p in self.places})
        self.d_settle = chamfer(W, H, {idx(*p["tile"]) for p in self.places if p["kind"] in PL.SETTLED})
        f = M.f
        self.d_fire = chamfer(W, H, {i for i in range(n) if f[i] & (SA.GEN["lava"] | SA.GEN["hot_spring"]) or self.biome[i] == B["volcano"]})
        self.d_ice = chamfer(W, H, {i for i in range(n) if f[i] & SA.GEN["ice_field"] or self.biome[i] == B["glacier"]} | set(S.snow))
        self.d_storm = chamfer(W, H, set(S.storm))
        self.d_plateau = chamfer(W, H, set(S.plateau))
        self.d_dark = chamfer(W, H, {i for i in range(n) if f[i] & SA.GEN["karst_core"]} | {idx(*c["tile"]) for c in S.caves} | self.waste)
        self.d_water = chamfer(W, H, {i for i in range(n) if M.river[i] or M.shore[i] or M.coast[i] or self.biome[i] in (B["swamp"], B["mangrove"])})
        self.d_ore = chamfer(W, H, {i for i in range(n) if f[i] & 32})
        self.d_vein = chamfer(W, H, {idx(*t) for v in S.veins for t in v["tiles"]})
        self.taken = []                                                          # (tile, gap) of everything laid
        self.by_region = {}
        for i in range(n):
            if M.dry[i]:
                self.by_region.setdefault(M.rid[i], []).append(i)

    # -- ground fit for an element or a kind, 0..1 ------------------------------------------------------------------
    def fit(self, what, i):
        M, b = self.M, self.biome[i]
        near = lambda d, r: max(0.0, 1.0 - d[i] / r)
        forest = b in (B["temperate_forest"], B["bamboo_forest"], B["jungle"])
        if what == "Wood":
            return (1.0 if forest else 0.3 if b in (B["grassland"], B["swamp"]) else 0.0) * (0.7 + 0.3 * near(self.d_water, 6))
        if what == "Water":
            return near(self.d_water, 3) * (1.0 if b in (B["swamp"], B["mangrove"], B["lake"]) or M.shore[i] else 0.8)
        if what == "Fire":
            return max(near(self.d_fire, 8), 0.6 if b == B["desert"] else 0.0)
        if what == "Metal":
            return max(0.9 if b == B["high_mountain"] else 0.6 if b == B["salt_flats"] else 0.0, near(self.d_ore, 4))
        if what == "Earth":
            return 1.0 if b in (B["steppe"], B["badlands"], B["highland"], B["karst"]) else 0.4 if b == B["grassland"] else 0.0
        if what == "Ice":
            return max(near(self.d_ice, 10), 0.7 if M.t[i] < -8 else 0.0)
        if what == "Thunder":
            return max(near(self.d_storm, 8), 0.5 if M.h[i] >= 2.0 and M.rain[i] >= 2000 else 0.0)
        if what == "Wind":
            return max(near(self.d_plateau, 10), 0.6 if b in (B["highland"], B["steppe"]) and M.h[i] >= 1.2 else 0.0)
        if what == "Light":
            return min(1.0, max(0.0, (M.h[i] - 1.8) / 1.5)) * (1.0 if M.relief[i] < 1.2 else 0.7)
        if what == "Darkness":
            return near(self.d_dark, 10) if i not in self.waste else 0.3
        if what == "ruin":                                                       # old sect grounds: open, watered
            return (1.0 - min(1.0, M.relief[i] / 0.8)) * (0.5 + 0.5 * near(self.d_water, 5)) * (0.4 if b in (B["glacier"], B["desert"]) else 1.0)
        if what == "abode":                                                      # a cultivator's cave: rugged, rich
            return min(1.0, M.relief[i] / 1.0) * (1.0 if b != B["glacier"] else 0.3)
        if what == "realm":                                                      # strange ground
            odd = max(near(self.d_dark, 8), near(self.d_storm, 8), near(self.d_ice, 8), near(self.d_fire, 8),
                      1.0 if M.mass_id[i] != M.main_mass else 0.0)
            return 0.4 + 0.6 * odd
        if what == "spring":
            return max(near(self.d_water, 3), near(self.d_fire, 4))
        if what == "pocket_vein":
            return max(min(1.0, M.relief[i] / 0.9), near(self.d_vein, 12))
        if what == "herb_patch":
            return (1.0 if forest else 0.6 if b in (B["grassland"], B["swamp"]) else 0.2) * min(1.0, self.D[i] / 1.2)
        if what == "cache":
            return 0.5 + 0.5 * near(self.d_settle, 30) * (1.0 - near(self.d_settle, 8))
        raise KeyError(what)

    def wild(self, i, place_gap):
        M = self.M
        return M.dry[i] and M.terr[i] >= 0 and self.d_place[i] >= place_gap and i not in self.waste

    def clear(self, xy, gap):
        return all(dist(xy, t) >= max(gap, g) for t, g in self.taken)

    # -- picking ----------------------------------------------------------------------------------------------------
    def pick_slot(self, what, n, rule, region=None, sects=None, avoid_anchor=(), accept=None):
        """Anchor: the best tile by fit + density weight, spread from earlier anchors; then n-1 more within
        slot_spread of the anchor and at least cand_gap apart. When fewer than 2 are found, it tries again with the
        fit floor and the gaps relaxed (`relax`), and the slot records that it was relaxed."""
        for k, f in enumerate([1.0] + self.P["relax"]):
            out = self.try_slot(what, n, rule, region, sects, avoid_anchor, f, accept)
            if len(out) >= 2 or k == len(self.P["relax"]):
                for xy in out:
                    self.taken.append((xy, self.P["rules"][rule]["gap"] * f))
                self.relaxed = f
                return [list(t) for t in out]

    def try_slot(self, what, n, rule, region, sects, avoid_anchor, f, accept):
        M, P, W = self.M, self.P, self.W
        r = dict(P["rules"][rule])
        r["fit_min"] *= f
        r["gap"] *= f
        r["anchor_gap"] *= f
        r["cand_gap"] = max(P["cand_gap_min"], r["cand_gap"] * f)
        r["place_gap"] = max(2, r["place_gap"] * f)
        spread = min(P["slot_spread"] / f, P["slot_spread_max"])
        pool = []
        for i in (self.by_region.get(region, []) if region is not None else range(W * self.H)):
            if sects is not None and M.terr[i] not in sects:
                continue
            if not self.wild(i, r["place_gap"]) or not (r["h"][0] <= M.h[i] <= r["h"][1]):
                continue
            if self.D[i] > r.get("d_max", 9.0):
                continue
            ft = self.fit(what, i)
            if ft < r["fit_min"]:
                continue
            pool.append((ft + r["density_weight"] * self.D[i], i))
        pool.sort(reverse=True)
        out = []
        for sc, i in pool:
            xy = (i % W, i // W)
            if not self.clear(xy, r["gap"]):
                continue
            if not out:
                if any(dist(xy, a) < r["anchor_gap"] for a in avoid_anchor):
                    continue
            elif dist(xy, out[0]) > spread or any(dist(xy, o) < r["cand_gap"] for o in out):
                continue
            if accept and not accept(xy):
                continue
            out.append(xy)
            if len(out) == n:
                break
        return out

    def blob(self, c, size, allow_places=False):
        """Grow a blob of `size` dry land tiles from c, nearest first, with a little noise on the edge."""
        M, W = self.M, self.W
        seen = {c}
        out = []
        front = [(0.0, c)]
        import heapq
        while front and len(out) < size:
            _, (x, y) = heapq.heappop(front)
            i = y * W + x
            if not M.dry[i] or (not allow_places and self.d_place[i] < 2) or i in self.waste:
                continue
            out.append((x, y))
            for ox, oy in SA.DIRS:
                nb = (x + ox, y + oy)
                if 0 <= nb[0] < W and 0 <= nb[1] < self.H and nb not in seen:
                    seen.add(nb)
                    heapq.heappush(front, (dist(nb, c) * (0.8 + 0.4 * SA.noise(nb[0], nb[1], 4.0, 51)), nb))
        return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--map", default="design/map/continent-11")
    a = ap.parse_args()
    with open(os.path.join(a.map, "history_proposal.json"), encoding="utf-8") as fh:
        prop = json.load(fh)
    with open(os.path.join(a.map, "sacred_proposal.json"), encoding="utf-8") as fh:
        sprop = json.load(fh)
    with open(os.path.join(a.map, "places.json"), encoding="utf-8") as fh:
        places = json.load(fh)["places"]
    M = PL.Map(a.map)
    roads, _ = PL.pixels(os.path.join(a.map, "roads.png"))
    roads = [v if v in (1, 2) else 0 for v in roads]
    S = SA.Sacred(M, sprop, places)
    S.lay_veins()
    S.lay_summits()
    S.lay_wasteland(roads)
    S.lay_caves()
    S.derived()
    for q in S.new_places:
        q["territory"] = M.greats[M.terr[M.idx(*q["tile"])]]["name_hv"]
    SA.attach_names(S, sprop.get("names", []))
    D, _ = S.check()
    Hh = History(M, S, D, prop, places)
    P = prop["params"]
    W = M.W
    keys = {g["key"]: k for k, g in enumerate(M.greats)}
    by_name = {p.get("name_hv"): p for p in Hh.places}
    seats = {p["key"]: p for p in places if p["kind"] == "great_seat"}
    dens = lambda t: round(D[M.idx(*t)], 2)
    terr = lambda t: M.greats[M.terr[M.idx(*t)]]["name_hv"] if M.terr[M.idx(*t)] >= 0 else None
    region = lambda t: M.regs.get(M.rid[M.idx(*t)], {}).get("name_hv", "")

    famous = {"secret_realms": [], "ruins": [], "blessed_large": [], "blessed_small": []}
    # famous secret realms
    for fr in prop["famous"]["secret_realms"]:
        an = fr["anchor"]
        if "near_place" in an:
            c, sects = by_name[an["near_place"]]["tile"], None
        elif an.get("near_source"):
            c, sects = list(S.source), None
        else:
            c, sects = None, {keys[k] for k in an["in_sects"]}
        best = None
        for i in range(W * M.H):
            xy = (i % W, i // W)
            if c is not None and not (an.get("min", 0) <= dist(xy, c) <= an["radius"]):
                continue
            if sects is not None and M.terr[i] not in sects:
                continue
            if any(dist(xy, s["tile"]) < an.get("seat_gap", 0) for s in seats.values()):
                continue
            ok_waste = an.get("near_source") and i in Hh.waste
            if not M.dry[i] or (Hh.d_place[i] < an.get("place_gap", 3)) or (i in Hh.waste and not ok_waste):
                continue
            if not Hh.clear(xy, 6):
                continue
            sc = Hh.fit(an.get("fit", "realm"), i) + 0.5 * D[i]
            if best is None or sc > best[0]:
                best = (sc, xy)
        xy = list(best[1])
        Hh.taken.append((tuple(xy), 8))
        famous["secret_realms"].append(dict(fr["names"], kind="secret_realm", tile=xy, region=region(xy), territory=terr(xy),
                                            holder=terr(xy), cycle=fr["cycle"], land_density_estimate=dens(xy)))
    # famous ruin
    for fr in prop["famous"]["ruins"]:
        an = fr["anchor"]
        best = None
        for i in range(W * M.H):
            xy = (i % W, i // W)
            if i in Hh.waste or not M.dry[i] or Hh.d_place[i] < 4 or not Hh.clear(xy, 6):
                continue
            dw = min(dist(xy, w) for w in S.waste) if an.get("by_waste") else 0
            if an.get("by_waste") and not (2 <= dw <= an["radius"]):
                continue
            sc = Hh.fit("ruin", i)
            if best is None or sc > best[0]:
                best = (sc, xy)
        xy = list(best[1])
        Hh.taken.append((tuple(xy), 8))
        famous["ruins"].append(dict(fr["names"], kind="ruin", tile=xy, region=region(xy), territory=terr(xy),
                                    land_density_estimate=dens(xy)))
    # famous large blessed lands around tier-1 seats
    for fb in prop["famous"]["blessed_large"]:
        s = seats[fb["sect"]]
        tiles = Hh.blob(tuple(s["tile"]), fb["tiles"], allow_places=True)
        inside = [p.get("name_hv") for p in Hh.places if tuple(p["tile"]) in set(tiles)]
        famous["blessed_large"].append(dict(fb["names"], kind="blessed_land", size="large", sect=s["name_hv"],
                                            element=fb["element"], dD3=fb["dD3"], push=fb["push"],
                                            centre=s["tile"], tiles=len(tiles), tile_list=[list(t) for t in tiles],
                                            places_inside=inside))
    # famous small retreats near every great seat
    for fb in prop["famous"]["blessed_small"]:
        s = seats[fb["sect"]]
        best = None
        for y in range(s["tile"][1] - 8, s["tile"][1] + 9):
            for x in range(s["tile"][0] - 8, s["tile"][0] + 9):
                i = M.idx(x, y)
                d = dist((x, y), s["tile"])
                if not (P["retreat_ring"][0] <= d <= P["retreat_ring"][1]) or not M.dry[i] or Hh.d_place[i] < 1:
                    continue
                sc = D[i] + 0.5 * Hh.fit(fb["element"], i)
                if best is None or sc > best[0]:
                    best = (sc, (x, y))
        xy = list(best[1])
        Hh.taken.append((tuple(xy), 2))
        famous["blessed_small"].append(dict(fb["names"], kind="blessed_land", size="small", sect=s["name_hv"],
                                            element=fb["element"], dD3=fb["dD3"], push=fb["push"], tile=xy,
                                            land_density_estimate=dens(xy), fit=round(Hh.fit(fb["element"], M.idx(*xy)), 2)))

    # hidden slots
    hidden = []
    anchors = [tuple(f["tile"]) for k in ("secret_realms", "ruins") for f in famous[k]]
    for sl in prop["hidden"]:
        for k in range(sl["count"]):
            what = sl.get("elements", [None] * sl["count"])[k] or sl["fit"]
            rule = sl["rule"]
            if sl["kind"] == "blessed_large":
                cands = Hh.pick_slot(what, sl["candidates"], rule, avoid_anchor=anchors,
                                     accept=lambda xy: len(Hh.blob(xy, sl["tiles"])) >= P["large_min_tiles"])
                blobs = [Hh.blob(tuple(c), sl["tiles"]) for c in cands]
                cand_out = [{"centre": c, "tiles": len(b), "tile_list": [list(t) for t in b],
                             "land_density_mean": round(sum(D[M.idx(*t)] for t in b) / len(b), 2),
                             "region": region(c), "territory": terr(c)} for c, b in zip(cands, blobs)]
                for b in blobs:
                    for t in b:
                        Hh.taken.append((t, 3))
            else:
                cands = Hh.pick_slot(what, sl["candidates"], rule, avoid_anchor=anchors)
                cand_out = [{"tile": c, "land_density_estimate": dens(c), "fit": round(Hh.fit(what, M.idx(*c)), 2),
                             "region": region(c), "territory": terr(c)} for c in cands]
            if cands:
                anchors.append(tuple(cands[0]))
            slot = {"slot": f"{sl['id']}-{k + 1}", "kind": sl["kind"], "candidates": cand_out}
            if Hh.relaxed != 1.0:
                slot["relaxed"] = Hh.relaxed
            if sl["kind"].startswith("blessed"):
                slot.update(element=what, dD3=sl["dD3"], push=sl["push"])
            if "H" in sl:
                slot["hidden_H"] = sl["H"]
            hidden.append(slot)

    # tile secrets: per region, kinds in turn, candidates inside the region
    secrets = []
    kinds = prop["tile_secrets"]["kinds"]
    per = prop["tile_secrets"]["per_region"]
    for rid in sorted(M.regs):
        for k in range(per):
            kd = kinds[(rid + k) % len(kinds)]
            cands = Hh.pick_slot(kd["fit"], prop["tile_secrets"]["candidates"], "secret", region=rid)
            secrets.append({"relaxed": Hh.relaxed, "slot": f"S{rid}-{k + 1}", "kind": kd["kind"], "region": M.regs[rid]["name_hv"],
                            "hidden_H": kd["H"], "dD3": kd.get("dD3"), "candidates": cands})

    # check
    n_places = len(Hh.places) + len(famous["secret_realms"]) + len(famous["ruins"]) + sum(
        1 for s in hidden if s["kind"] in ("secret_realm", "ruin", "abode"))
    realms = len(famous["secret_realms"]) + sum(1 for s in hidden if s["kind"] == "secret_realm")
    ruins = len(famous["ruins"]) + sum(1 for s in hidden if s["kind"] in ("ruin", "abode"))
    cand_tiles = [c["tile"] for s in hidden if "tile" in (s["candidates"] or [{}])[0] for c in s["candidates"]]
    ruin_d = [c["land_density_estimate"] for s in hidden if s["kind"] in ("ruin", "abode") for c in s["candidates"]]
    realm_d = [f["land_density_estimate"] for f in famous["secret_realms"]] + [
        c["land_density_estimate"] for s in hidden if s["kind"] == "secret_realm" for c in s["candidates"]]
    large = famous["blessed_large"] + [c for s in hidden if s["kind"] == "blessed_large" for c in s["candidates"]]
    small_n = len(famous["blessed_small"]) + sum(1 for s in hidden if s["kind"] == "blessed_small")
    large_n = len(famous["blessed_large"]) + sum(1 for s in hidden if s["kind"] == "blessed_large")
    elements = {}
    for f in famous["blessed_large"] + famous["blessed_small"]:
        elements[f["element"]] = elements.get(f["element"], 0) + 1
    for s in hidden:
        if s["kind"].startswith("blessed"):
            elements[s["element"]] = elements.get(s["element"], 0) + 1
    bad = [t for t in cand_tiles + [c for s in secrets for c in s["candidates"]]
           if not M.dry[M.idx(*t)] or Hh.d_place[M.idx(*t)] < 1]
    short = [s["slot"] for s in hidden + secrets if len(s["candidates"]) < 2]
    chk = {
        "places_with_one_spot_per_hidden_slot": n_places,
        "secret_realms": realms, "secret_realm_share": round(realms / n_places, 3),
        "ruins_and_abodes": ruins, "ruin_share": round(ruins / n_places, 3),
        "secret_realm_land_density": [min(realm_d), max(realm_d)],
        "ruin_abode_land_density": [min(ruin_d), max(ruin_d)],
        "ruin_abode_candidates_at_1_4": round(sum(1 for v in ruin_d if v >= 1.4) / len(ruin_d), 2),
        "blessed_large": large_n, "blessed_small": small_n,
        "large_sizes": [x["tiles"] for x in large],
        "blessed_elements": dict(sorted(elements.items())),
        "hidden_slots": len(hidden), "hidden_candidates": sum(len(s["candidates"]) for s in hidden),
        "tile_secrets": len(secrets), "tile_secret_candidates": sum(len(s["candidates"]) for s in secrets),
        "slots_with_under_2_candidates": short,
        "slots_relaxed": [s["slot"] for s in hidden if s.get("relaxed")] + [s["slot"] for s in secrets if s["relaxed"] != 1.0],
        "large_under_40_tiles": [x.get("centre") for x in large if x["tiles"] < 40],
        "candidates_not_wild": bad,
    }
    out = {"source": "tools/design/map/history.py", "check": chk, "famous": famous, "hidden": hidden,
           "tile_secrets": secrets, "params": P}
    with open(os.path.join(a.map, "history.json"), "w", encoding="utf-8") as fh:
        json.dump(out, fh, indent=1, ensure_ascii=False)
    render(M, S, Hh, famous, hidden, secrets, a.map)
    print(json.dumps(chk, indent=1, ensure_ascii=False))


def render(M, S, Hh, famous, hidden, secrets, out):
    W, H, sc = M.W, M.H, 3
    base = Image.open(os.path.join(M.d, "base", "detail.jpg")).convert("RGB").resize((W * sc, H * sc), Image.LANCZOS)
    base = Image.blend(base, Image.new("RGB", base.size, (20, 22, 30)), 0.4).convert("RGBA")
    ov = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(ov)
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
                        d.line(sg, fill=(240, 230, 220, 100), width=1)
    cell = lambda t, col: d.rectangle((t[0] * sc, t[1] * sc, t[0] * sc + sc - 1, t[1] * sc + sc - 1), fill=col)
    for x, y in S.waste:
        cell((x, y), (120, 60, 130, 110))
    for v in S.veins:
        d.line([(x * sc + 1.5, y * sc + 1.5) for x, y in v["tiles"]], fill=(60, 255, 200, 140), width=2)
    for f in famous["blessed_large"]:
        for t in f["tile_list"]:
            cell(t, (255, 215, 90, 120))
    for s in hidden:
        if s["kind"] == "blessed_large":
            for c in s["candidates"]:
                for t in c["tile_list"]:
                    cell(t, (255, 160, 60, 70))
    for p in Hh.places:
        x, y = p["tile"]
        d.ellipse((x * sc, y * sc, x * sc + 2, y * sc + 2), fill=(210, 210, 210, 150))
    col = {"secret_realm": (120, 200, 255), "ruin": (230, 140, 90), "abode": (235, 235, 255), "blessed_small": (255, 210, 80)}
    for s in hidden:
        if s["kind"] == "blessed_large":
            continue
        c = col[s["kind"]]
        pts = [(t["tile"][0] * sc + 1.5, t["tile"][1] * sc + 1.5) for t in s["candidates"]]
        if len(pts) > 1:
            d.line(pts + [pts[0]] if len(pts) > 2 else pts, fill=c + (90,), width=1)
        for x, y in pts:
            d.ellipse((x - 3.5, y - 3.5, x + 3.5, y + 3.5), outline=c + (255,), width=2)
    for s in secrets:
        for t in s["candidates"]:
            x, y = t[0] * sc + 1.5, t[1] * sc + 1.5
            d.rectangle((x - 1, y - 1, x + 1, y + 1), fill=(200, 255, 255, 200))
    try:
        font = ImageFont.truetype("arial.ttf", 15)
    except OSError:
        font = ImageFont.load_default()
    labels = []
    for f in famous["secret_realms"]:
        x, y = f["tile"][0] * sc + 1.5, f["tile"][1] * sc + 1.5
        d.regular_polygon((x, y, 9), 6, fill=(120, 200, 255, 255), outline=(0, 0, 0, 255))
        labels.append((x, y, f["name_hv"], (170, 225, 255, 255)))
    for f in famous["ruins"]:
        x, y = f["tile"][0] * sc + 1.5, f["tile"][1] * sc + 1.5
        d.rectangle((x - 7, y - 7, x + 7, y + 7), fill=(230, 140, 90, 255), outline=(0, 0, 0, 255))
        labels.append((x, y, f["name_hv"], (255, 190, 150, 255)))
    for f in famous["blessed_small"]:
        x, y = f["tile"][0] * sc + 1.5, f["tile"][1] * sc + 1.5
        d.regular_polygon((x, y, 7), 4, fill=(255, 210, 80, 255), outline=(0, 0, 0, 255))
        labels.append((x, y, f["name_hv"], (255, 230, 150, 255)))
    for f in famous["blessed_large"]:
        x, y = f["centre"][0] * sc + 1.5, f["centre"][1] * sc + 1.5
        labels.append((x, y + 14, f["name_hv"], (255, 225, 120, 255)))
    boxes = []
    for cx, cy, text, c in labels:
        tw, th = d.textbbox((0, 0), text, font=font, stroke_width=3)[2:]
        for ox, oy in ((9, -th / 2), (-9 - tw, -th / 2), (-tw / 2, 9), (-tw / 2, -9 - th), (9, 6), (9, -th - 6),
                       (-9 - tw, 6), (-9 - tw, -th - 6), (-tw / 2, 24), (-tw / 2, -24 - th)):
            bx = (cx + ox, cy + oy, cx + ox + tw, cy + oy + th)
            if not any(bx[0] < o[2] and o[0] < bx[2] and bx[1] < o[3] and o[1] < bx[3] for o in boxes):
                break
        boxes.append(bx)
        d.text((bx[0], bx[1]), text, fill=c, font=font, stroke_width=3, stroke_fill=(10, 10, 15, 255))
    img = Image.alpha_composite(base, ov).convert("RGB")
    lg = ImageDraw.Draw(img)
    items = [((120, 200, 255), "secret realm: famous (hexagon), hidden candidates (rings)"),
             ((230, 140, 90), "ruin: famous (square), hidden candidates"),
             ((235, 235, 255), "dead cultivator's abode: hidden candidates"),
             ((255, 215, 90), "blessed land: famous large (area), small (diamond)"),
             ((255, 160, 60), "hidden large blessed land: candidate areas"),
             ((255, 210, 80), "hidden small blessed land: candidates (rings)"),
             ((200, 255, 255), "tile secret candidates (dots)"),
             ((60, 255, 200), "spirit veins"), ((120, 60, 130), "miasma wasteland")]
    x0, y0 = 12, H * sc - 22 * len(items) - 14
    lg.rectangle((x0 - 6, y0 - 8, x0 + 430, H * sc - 6), fill=(15, 15, 22))
    for k, (c, t) in enumerate(items):
        lg.rectangle((x0, y0 + k * 22, x0 + 14, y0 + k * 22 + 14), fill=c, outline=(200, 200, 200))
        lg.text((x0 + 22, y0 + k * 22 - 1), t, fill=(235, 235, 235), font=font)
    img.save(os.path.join(out, "history.jpg"), quality=88)


if __name__ == "__main__":
    main()
