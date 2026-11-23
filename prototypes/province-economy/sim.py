# PROTOTYPE - NOT FOR PRODUCTION
"""Province economy prototype (prototypes/province-economy/README.md; user 2026-11-23: "let province be an economic
unit"). Re-sums the game's real per-place production and people (dump_places.gd) into the 273 provinces and runs the
regional economy's own formulas (design/gdd/regional-economy-trade.md B-F, L1; parameters from assets/data/economy.json)
at province level, two ways:

  A  provinces replace regions only: one market price per great sect (Formulas B-E), each province's local price from
     its own balance and access (Formula L1, bounded by loc_band); no goods move inside a market (rule 16).
  B  A's market model is dropped for province stocks and prices: every settlement province keeps its own stock and
     price (D, E at province level), and goods flow each season between neighbouring provinces (Formula F's rule:
     cheaper to dearer, transport cost by distance, half the gap closed, the importer's tariff where sects meet).

Wilderness provinces produce but hold no people: their output goes to the neighbouring settlement provinces, shared by
border length (user, 2026-11-23). A herb blight (herb supply x 0.3) hits one region in seasons 12-15.

Run: python -I prototypes/province-economy/sim.py   (writes out/*.png and prints observations, never a verdict)
"""
import json
import math
import os
from collections import defaultdict

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
OUT = os.path.join(HERE, "out")
SEASONS = 24
BLIGHT = (12, 16)          # herb supply x 0.3 in the blight region for these seasons
BLIGHT_MULT = 0.3
TRAVEL_TILES = 30.0        # tiles a season, for "seasons of travel" between two provinces (road 54, wild 18)


def load():
    eco = json.load(open(os.path.join(ROOT, "assets/data/economy.json"), encoding="utf-8"))
    dump = json.load(open(os.path.join(HERE, "places_seed7.json"), encoding="utf-8"))
    provs = json.load(open(os.path.join(ROOT, "design/map/continent-11/provinces/provinces.json"), encoding="utf-8"))["provinces"]
    pid = np.asarray(Image.open(os.path.join(ROOT, "design/map/continent-11/provinces/province_ids.png"))).astype(np.int32)
    return eco, dump, provs, pid


def main():
    eco, dump, provs, pid = load()
    C = eco["classes"]
    kinds = C["order"]   # herb, ore, beast, special
    P = {p["id"]: p for p in provs}
    settle = {i for i, p in P.items() if p["seed_kind"] != "wilderness"}
    # --- re-sum the places into provinces --------------------------------------------------------------------------
    classes = sorted({c for pl in dump["places"] for c in pl["production"]})
    kind_of = {c: next(k for k in kinds if c.startswith(k)) for c in classes}
    prod = defaultdict(lambda: defaultdict(float))
    heads = defaultdict(lambda: [0] * 5)
    wset = defaultdict(float)
    market_of_region = {}
    w_place = eco["shop"].get("w_place", {})
    hub_place = {}
    for pl in dump["places"]:
        x, y = int(pl["tile"][0]), int(pl["tile"][1])
        v = int(pid[y, x]) if 0 <= y < pid.shape[0] and 0 <= x < pid.shape[1] else 0
        if v == 0:
            continue
        for c, q in pl["production"].items():
            prod[v][c] += q
        heads[v] = [a + b for a, b in zip(heads[v], pl["heads"])]
        wset[v] += float(w_place.get(pl["kind"], 0.0))
        if pl["market"]:
            market_of_region[P[v]["region"]] = pl["market"]
        if pl["kind"] == "great_seat":
            hub_place[pl["market"]] = v
    market = {i: market_of_region.get(p["region"], "") for i, p in P.items()}
    # wilderness output to its settlement neighbours by border length (several hops if a wild province has none)
    wild_out = {i: dict(prod[i]) for i in P if i not in settle}
    for _ in range(6):
        nxt = {}
        for i, goods in wild_out.items():
            nb = [(n["province"], n["border_tiles"]) for n in P[i]["neighbours"]]
            tgt = [(j, w) for j, w in nb if j in settle] or nb
            tot = sum(w for _, w in tgt) or 1
            for j, w in tgt:
                for c, q in goods.items():
                    if j in settle:
                        prod[j][c] += q * w / tot
                    else:
                        nxt.setdefault(j, defaultdict(float))[c] += q * w / tot
        wild_out = nxt
        if not wild_out:
            break
    for i in P:
        if i not in settle:
            prod[i] = defaultdict(float)
    S = sorted(settle)
    # --- demand: Formula C's population and settlement terms per province, d_scale calibrated so the world is at rest -
    basket = eco["demand"]["basket"]
    set_w = eco["demand"]["set_w"]
    bmix = C["bmix"]
    sub_floor = C["sub_floor"]
    base_need = {i: sum(n * b for n, b in zip(heads[i], basket)) + set_w * wset[i] for i in S}
    world_s = {c: sum(prod[i][c] for i in S) for c in classes}
    kind_s = defaultdict(float)
    for c in classes:
        kind_s[kind_of[c]] += world_s[c]
    dk = C["dk"]; c_ref = C["c_ref"]; eps = C["eps"]
    pmin, pmax = C["p_min"], C["p_max"]
    delta = C["delta"]
    alpha = eco["price"]["alpha"]
    def calibrate(eff):
        """Demand per province and class, scaled so the world is at rest (GDD Formula C calibration:
        S / D = 1 + dk (c_ref - 1)) against [param eff](i, c), the supply that variant actually delivers."""
        out = {}
        for c in classes:
            k = kind_of[c]
            bs = world_s[c] / kind_s[k] if kind_s[k] else 0
            raw = {i: bmix.get(k, 0.1) * base_need[i] * bs for i in S}
            target = sum(eff(i, c) for i in S) / (1 + dk[k] * (c_ref[k] - 1))
            scale = target / max(1e-9, sum(raw.values()))
            for i in S:
                out[(i, c)] = raw[i] * scale
        return out
    # --- geometry: settlement-province graph (direct neighbours, and two that share a wilderness neighbour) -----------
    cen = {i: np.array(P[i]["centre"], float) for i in P}
    edges = {}
    for i in S:
        for n in P[i]["neighbours"]:
            j = n["province"]
            if j in settle and i < j:
                edges[(i, j)] = {"d": float(np.linalg.norm(cen[i] - cen[j])), "border": n["border_tiles"]}
            elif j not in settle:
                for n2 in P[j]["neighbours"]:
                    k2 = n2["province"]
                    if k2 in settle and i < k2 and (i, k2) not in edges:
                        edges[(i, k2)] = {"d": float(np.linalg.norm(cen[i] - cen[j]) + np.linalg.norm(cen[j] - cen[k2])),
                                          "border": min(n["border_tiles"], n2["border_tiles"]) * 0.5}
    # access to the market's hub (Formula A's reach, straight-line distance in tiles)
    d_reach = eco["access"]["d_reach"]
    acc = {}
    for i in S:
        h = hub_place.get(market[i])
        dist = float(np.linalg.norm(cen[i] - cen[h])) if h else 200.0
        acc[i] = math.exp(-dist / (d_reach * 1.15))
    D_a = calibrate(lambda i, c: prod[i][c] * acc[i] * 0.85)
    D_b = calibrate(lambda i, c: prod[i][c])
    blight_region = max({P[i]["region"] for i in S}, key=lambda r: sum(prod[i]["herb1"] for i in S if P[i]["region"] == r))

    def supply(i, c, t):
        q = prod[i][c]
        if kind_of[c] == "herb" and BLIGHT[0] <= t < BLIGHT[1] and P[i]["region"] == blight_region:
            q *= BLIGHT_MULT
        return q

    def price_from(cover, k, Pold):
        ps = pmax[k] if cover <= 0 else min(max((cover / c_ref[k]) ** (-eps[k]), pmin[k]), pmax[k])
        pn = Pold * (ps / Pold) ** alpha
        return min(max(pn, Pold / delta[k]), Pold * delta[k])

    # ===== A: one market price per sect, local prices by Formula L1 ===================================================
    def run_a():
        mk = sorted({market[i] for i in S if market[i]})
        stock = {(m, c): 0.0 for m in mk for c in classes}
        Pm = {(m, c): 1.0 for m in mk for c in classes}
        loc = {}
        hist = []
        for t in range(SEASONS):
            for m in mk:
                mem = [i for i in S if market[i] == m]
                for c in classes:
                    k = kind_of[c]
                    s_m = sum(supply(i, c, t) * acc[i] for i in mem) * 0.85
                    d_m = max(sum(D_a[(i, c)] for i in mem), 1.0)
                    if t == 0:
                        stock[(m, c)] = max(0.0, c_ref[k] * d_m - s_m)
                    cover = (stock[(m, c)] + s_m) / d_m
                    Pm[(m, c)] = price_from(cover, k, Pm[(m, c)])
                    stock[(m, c)] = min((1 - dk[k]) * max(0.0, stock[(m, c)] + s_m - d_m), C["s_cap"][k] * d_m)
                    rho = (sum(supply(i, c, t) for i in mem) + 1) / (sum(D_a[(i, c)] for i in mem) + 1)
                    for i in mem:
                        bal = ((supply(i, c, t) + 1) / (D_a[(i, c)] + 1)) / rho
                        lp = Pm[(m, c)] * bal ** (-eps[k] * (1 - acc[i]))
                        band = eco["local"]["loc_band"]
                        loc[(i, c)] = min(max(lp, Pm[(m, c)] * (1 - band)), Pm[(m, c)] * (1 + band))
            hist.append(dict(loc))
        return hist

    # ===== B: province stocks and prices, neighbour flow =============================================================
    tau0_in, tau0_x, tau_tile = 0.02, 0.05, 0.0005
    tariff_x = 0.08
    beta = 0.5
    cap_per_border = float(os.environ.get("CAP", "300"))
    ROUNDS = int(os.environ.get("ROUNDS", "5"))

    def run_b():
        stock = {}
        Pp = {(i, c): 1.0 for i in S for c in classes}
        hist, flows_hist, cons = [], [], []
        for t in range(SEASONS):
            flow_vol = defaultdict(float)
            pre = {}
            for i in S:
                for c in classes:
                    k = kind_of[c]
                    s = supply(i, c, t)
                    d = max(D_b[(i, c)], 1.0)
                    if t == 0:
                        stock[(i, c)] = max(0.0, c_ref[k] * d - s)
                    pre[(i, c)] = stock[(i, c)] + s
            moved_in = defaultdict(float)
            moved_out = defaultdict(float)
            for rnd in range(ROUNDS):   # goods may cross up to ROUNDS links a season (a caravan's reach)
              cur = {}
              for key in pre:
                  have0 = pre[key] - moved_out[key] + moved_in[key]
                  k0 = kind_of[key[1]]
                  cv = have0 / max(D_b[key], 1.0)
                  cur[key] = pmax[k0] if cv <= 0 else min(max((cv / c_ref[k0]) ** (-eps[k0]), pmin[k0]), pmax[k0])
              for (i, j), e in sorted(edges.items()):
                same = market[i] == market[j]
                for c in classes:
                    k = kind_of[c]
                    a, b = (i, j) if cur[(i, c)] <= cur[(j, c)] else (j, i)
                    tau = (tau0_in if same else tau0_x) + tau_tile * e["d"]
                    tar = 0.0 if same else tariff_x
                    gap = cur[(b, c)] * (1 - tar) - cur[(a, c)] * (1 + tau)
                    if gap <= 0:
                        continue
                    da, db_ = max(D_b[(a, c)], 1.0), max(D_b[(b, c)], 1.0)
                    ha_ = pre[(a, c)] - moved_out[(a, c)] + moved_in[(a, c)]
                    hb_ = pre[(b, c)] - moved_out[(b, c)] + moved_in[(b, c)]
                    ca = max(ha_ / da, 0.5)
                    cb = max(hb_ / db_, 0.5)
                    q_close = gap / (eps[k] * (cur[(a, c)] / (ca * da) + cur[(b, c)] / (cb * db_)))
                    avail = max(0.0, ha_ - D_b[(a, c)])
                    q = min(beta * q_close, avail, cap_per_border * e["border"] / ROUNDS)
                    if q <= 0:
                        continue
                    moved_out[(a, c)] += q
                    moved_in[(b, c)] += q
                    flow_vol[(i, j)] += q * cur[(a, c)]
            total_in, total_out, spoil, consumed, overflow = 0.0, 0.0, 0.0, 0.0, 0.0
            made = 0.0
            for i in S:
                for c in classes:
                    k = kind_of[c]
                    s = supply(i, c, t)
                    made += s
                    d = max(D_b[(i, c)], 1.0)
                    have = pre[(i, c)] - moved_out[(i, c)] + moved_in[(i, c)]
                    total_in += moved_in[(i, c)]
                    total_out += moved_out[(i, c)]
                    cover = have / d
                    Pp[(i, c)] = price_from(cover, k, Pp[(i, c)])
                    used = min(have, D_b[(i, c)])
                    consumed += used
                    left = have - used
                    sp = dk[k] * left
                    spoil += sp
                    cap = C["s_cap"][k] * d
                    new = min(left - sp, cap)
                    overflow += (left - sp) - new
                    stock[(i, c)] = new
            cons.append({"flow_balance": total_in - total_out, "made": made, "consumed": consumed, "spoiled": spoil, "overflow": overflow})
            hist.append(dict(Pp))
            flows_hist.append(dict(flow_vol))
        return hist, flows_hist, cons

    os.makedirs(OUT, exist_ok=True)
    ha = run_a()
    hb, fb, cons = run_b()
    # ===== observations ==============================================================================================
    def herb_prices(h, t):
        return {i: h[t][(i, "herb1")] for i in S}

    def report(name, h):
        pre, mid, post = herb_prices(h, 11), herb_prices(h, 14), herb_prices(h, 23)
        vals = np.array(list(pre.values()))
        inb = [i for i in S if P[i]["region"] == blight_region]
        nb_reg = {P[n["province"]]["region"] for i in inb for n in P[i]["neighbours"]} - {blight_region}
        near = [i for i in S if P[i]["region"] in nb_reg]
        far = [i for i in S if i not in inb and i not in near]
        print("%s herb1 price, season 11: min %.2f median %.2f max %.2f (spread %.2f)" % (name, vals.min(), np.median(vals), vals.max(), vals.max() - vals.min()))
        for lab, grp in (("blight region", inb), ("neighbouring regions", near), ("elsewhere", far)):
            if grp:
                print("   %-21s season 11 %.2f -> blight (14) %.2f -> season 23 %.2f" % (
                    lab, np.mean([pre[i] for i in grp]), np.mean([mid[i] for i in grp]), np.mean([post[i] for i in grp])))
        # gradient from the hub: price vs access
        a = np.array([acc[i] for i in S]); pv = np.array([pre[i] for i in S])
        print("   correlation of price with distance from the hub (1 - access): %.2f" % float(np.corrcoef(1 - a, pv)[0, 1]))
    print("provinces: %d settlement (%d wilderness feeding them); %d province links; blight region %d" % (len(S), len(P) - len(S), len(edges), blight_region))
    report("A (market + L1)", ha)
    report("B (neighbour flow)", hb)
    # what flow leaves for the player: gap between linked provinces vs travel seasons, season 11, herb1
    gaps = []
    for (i, j), e in edges.items():
        for h in (ha, hb):
            pass
        g_a = abs(ha[11][(i, "herb1")] - ha[11][(j, "herb1")])
        g_b = abs(hb[11][(i, "herb1")] - hb[11][(j, "herb1")])
        gaps.append((e["d"] / TRAVEL_TILES, g_a, g_b))
    g = np.array(gaps)
    for lo, hi in ((0, 0.5), (0.5, 1), (1, 2), (2, 9)):
        m = (g[:, 0] >= lo) & (g[:, 0] < hi)
        if m.any():
            print("   linked provinces %.1f-%.1f seasons apart (%d): herb1 gap A %.2f, B %.2f" % (lo, hi, int(m.sum()), g[m, 1].mean(), g[m, 2].mean()))
    worst = max(abs(c["flow_balance"]) for c in cons)
    print("B conservation: largest flow imbalance in a season %.6f (in base value); season 11 made %.0f, consumed %.0f, spoiled %.0f, overflow %.0f" % (
        worst, cons[11]["made"], cons[11]["consumed"], cons[11]["spoiled"], cons[11]["overflow"]))
    corr = sorted(fb[11].items(), key=lambda kv: -kv[1])[:5]
    print("B busiest links, season 11 (value moved): " + ", ".join("%d-%d %.0f" % (a, b, v) for (a, b), v in corr))
    render(pid, P, S, {"A_s11": herb_prices(ha, 11), "A_s14": herb_prices(ha, 14), "B_s11": herb_prices(hb, 11),
                       "B_s14": herb_prices(hb, 14), "B_s23": herb_prices(hb, 23)}, fb[11], cen, edges, blight_region)


def render(pid, P, S, maps, flows, cen, edges, blight_region):
    """Each map: settlement provinces coloured by their herb price (blue cheap, cream 1.0, red dear) over a grey land,
    wilderness pale; the B season-11 map also draws the busiest links as brown lines."""
    H, W = pid.shape
    sc = 3
    for name, prices in maps.items():
        col = np.zeros((H, W, 3), np.uint8)
        col[:, :] = (214, 224, 234)      # sea
        col[pid > 0] = (200, 198, 186)   # wilderness (no people, no price)
        for i in P:
            if i not in prices:
                continue
            v = prices[i]
            t = max(-1.0, min(1.0, math.log(v) / math.log(1.8)))
            if t < 0:
                c = np.array([246, 239, 222]) * (1 + t) + np.array([60, 110, 190]) * (-t)
            else:
                c = np.array([246, 239, 222]) * (1 - t) + np.array([190, 40, 40]) * t
            col[pid == i] = c.astype(np.uint8)
        img = Image.fromarray(col).resize((W * sc, H * sc), Image.NEAREST)
        d = ImageDraw.Draw(img)
        if name == "B_s11":
            top = sorted(flows.items(), key=lambda kv: -kv[1])[:60]
            mx = top[0][1] if top else 1
            for (a, b), v in top:
                d.line([tuple(cen[a] * sc), tuple(cen[b] * sc)], fill=(90, 50, 20), width=max(1, int(6 * v / mx)))
        from PIL import ImageFont
        try:
            font = ImageFont.load_default(size=34)
        except TypeError:
            font = ImageFont.load_default()
        label = {"A_s11": "A: market price + local price, season 11", "A_s14": "A: blight, season 14",
                 "B_s11": "B: neighbour flow, season 11 (lines: busiest trade links)", "B_s14": "B: blight, season 14",
                 "B_s23": "B: after the blight, season 23"}[name]
        d.text((24, 18), label + "   herb price: blue cheap, cream 1.0, red dear", fill=(20, 20, 20), font=font)
        img.save(os.path.join(OUT, "%s.png" % name))
    print("maps in", OUT)


if __name__ == "__main__":
    main()
