"""Land toolkit for the whole-tree pass (2026-11-08 night): the parts every element land shares.

The Metal pilot drew everything by hand. For the other twenty-odd regions the start web, the roads and the band
constellations are still drawn by hand in each region's spec; this module gives them the shared pieces:
- web(): the twin-hub start web of the Metal pilot (PoE 2 finding 25), parameterised by the land's names and themes;
- ring roads, spokes and the lightning road, with the ports build_tree.py joins;
- dress_roads(): the guide's step 5 as rules (two or three figures per road node, a big one outward toward the rim,
  identity themes on their own side, universal themes scattered, a figure that means the theme);
- fill_holes(): the guide's step 6 (empty-space map, a symmetric figure at each hole's peak);
- halo(): sealed and open clusters in the hidden band beyond the rim (Kinh Mạch Đồ rules 6-13).
"""
import hashlib
import math
import os

# KMD_LIGHT=1 builds the lighter variant (open point 1, the budget): one fill pass at a wider clearance, one figure
# per road node in the blend zones
LIGHT = os.environ.get("KMD_LIGHT") == "1"

from_pens = None   # set by use()


def use(pens, common):
    global P_, C_
    P_, C_ = pens, common


# ---- figure menus ------------------------------------------------------------------------------------------------
SMALL_FIGS = ["kite", "V", "cup", "tristar", "anchor", "arrow", "hex", "bowtie", "lollipop", "spoked", "rosette", "shield", "fan"]
MID_FIGS = ["hourglass", "heart", "eye", "trident", "cross", "totem", "seal", "fish", "cloud", "paw", "flame", "vine",
            "xcross", "lollipop", "spoked", "bowtie", "antler", "tree", "star", "anchor"]
BIG_FIGS = ["theta", "lens", "concentric", "snowflake", "star", "sun", "lotus", "bagua", "drum", "gourd2", "cauldron",
            "flake", "turtle", "pagoda", "shan", "phoenix", "coin"]
SYMMETRIC = ["theta", "lens", "concentric", "snowflake", "spoked", "hex", "bowtie", "wheel", "lollipop", "kite",
             "rosette", "lotus", "sun", "bagua", "drum", "eye", "hourglass", "totem", "shield", "cross", "star"]
# the figure that means a theme, small to big (PoE 2 draws its figures for their notables: finding 27)
THEME_FIGS = {
    "heart": ["heart", "lotus"], "lifespan": ["cup", "hourglass", "gourd2"], "sense": ["eye", "spoked"], "insight": ["pagoda", "lens"],
    "health": ["cross", "totem", "theta"], "linh": ["spiral", "wheel", "concentric"], "ward": ["shield", "hex", "theta"],
    "crit": ["arrow", "xcross"], "sword": ["sword", "cross", "xcross"], "refining": ["coin", "anchor"],
    "alchemy": ["cauldron", "gourd2", "lollipop"], "blaze": ["flame", "tristar"], "fire": ["flame", "sun"],
    "phoenix": ["phoenix", "lotus", "V"], "formation": ["bagua", "window", "theta"], "mountain": ["shan", "turtle", "hex"],
    "earth": ["shan", "kite", "turtle"], "gravity": ["anchor", "totem"], "talisman": ["seal", "lens"],
    "tide": ["spiral", "wave", "concentric"], "water": ["wave", "fish", "lens"], "ice": ["flake", "snowflake"],
    "field": ["terrace", "rosette"], "beast": ["paw", "antler"], "wood": ["tree", "vine"], "growth": ["vine", "rosette", "lotus"],
    "wind": ["fan", "cloud"], "thunder": ["bolt", "drum"], "light": ["sun", "lotus"], "dark": ["eclipse", "spiral"],
    "chaos": ["taiji"], "lava": ["flame", "shan"], "ore": ["coin", "kite"], "dew": ["lens", "rosette"],
    "rain": ["cloud", "vine"], "kindling": ["tree", "flame"],
}
UNIVERSAL = ["health", "linh", "sense", "ward", "crit", "lifespan", "heart", "insight"]
OFFENCE = {"crit", "sword", "blaze", "fire", "earth", "water", "wood", "metal", "thunder", "dark", "beast"}
DEFENCE = {"health", "ward", "body", "mountain", "growth", "phoenix", "tide", "lifespan", "heart"}


def h01(*xs):
    """A fixed pseudo-random number in [0, 1) from the arguments (hand-tuned layouts stay reproducible)."""
    s = hashlib.md5(repr(xs).encode()).hexdigest()
    return int(s[:8], 16) / 2 ** 32


# ---- the start web -----------------------------------------------------------------------------------------------
def web(T, c):
    """The twin-hub start web of the Metal pilot. c: names and themes, see each land's WEB."""
    P = T.P
    S = T.node((0, C_.START_R), "S", key=c["key"])
    a0 = c.get("ring0", 20)
    jl, jr = T.junction(P(C_.START_R, -a0), road="ring"), T.junction(P(C_.START_R, a0), road="ring")
    ringL = T.road([S, jl], step=2.8, road="ring")
    ringR = T.road([S, jr], step=2.8, road="ring")
    T.port("r0-", jl); T.port("r0+", jr)
    hx, hy = c.get("hub", (4.3, 22.4))
    T.cluster(c["gate"], "twin-hub web", mastery=(0, hy + 1.3))
    hubL = T.node((-hx, hy), "N", c["left"], name=c["hubL"])
    hubR = T.node((hx, hy), "N", c["right"], name=c["hubR"])
    T.chain(S, hubL, "ssss", c["left"], bend=0.55)
    T.chain(S, hubR, "ssss", c["right"], bend=-0.55)
    cc = (0, hy - 0.77)
    rr = math.hypot(hx, 0.77)
    dome = T.run(hubL, P_.circ(cc, rr, [-53, -27, 0, 27, 53]), "ssNss", c["elem"], names=[None, None, c["top"]], centre=cc)
    T.link(dome[-1], hubR, centre=cc)
    c2 = (0, hy + 5.9)
    r2 = math.dist(c2, (hx, hy))
    lows = [P_.circ(c2, r2, [180 + a])[0] for a in (17, 0, -17)]
    low = T.run(hubL, lows, "sNs", c["low_theme"], names=[None, c["low"]], centre=c2)
    T.link(low[-1], hubR, centre=c2)
    y0 = T.pt(low[1])[1]
    cc_ = (0, y0 + 2.45)
    inner = [T.node(P_.circ(cc_, 1.3, [180 + 60 * j])[0], "N" if j == 2 else "s", c["elem"]) for j in range(6)]
    for a_, b_ in zip(inner, inner[1:] + inner[:1]):
        T.link(a_, b_, centre=cc_)
    T.link(low[1], inner[0]); T.link(inner[3], dome[2])
    T.end()
    T.cluster("Cradle", "cradle")
    a1 = T.run(ringL[1], [(-2.95, 15.45), (-2.3, 14.35)], "ss", c["cradle"][0])
    n1 = T.node((-1.25, 13.6), "N", c["cradle"][0])
    T.link(a1[-1], n1)
    a2 = T.run(ringR[1], [(2.95, 15.45), (2.3, 14.35)], "ss", c["cradle"][1])
    n2 = T.node((1.25, 13.6), "N", c["cradle"][1])
    T.link(a2[-1], n2)
    mid = T.node((0, 13.2), "s", c["cradle"][2])
    T.link(n1, mid, bend=-0.15)
    T.link(mid, n2, bend=-0.15)
    T.end()
    T.cluster(T.R.KEYSTONES[c["keystone"]]["name"].split(" (")[0] + " spur", "keystone spur")
    sp = T.run(mid, [(0, 12.0)], "s", "keystone")
    T.link(sp[-1], T.node((0, 10.7), "K", key=c["keystone"]))
    T.end()
    T.reserved.append((T.pt(S), 2.6))    # judge round 8: a small margin round each start, so gold does not crowd it
    return {"S": S, "jl": jl, "jr": jr, "ringL": ringL, "ringR": ringR, "hubL": hubL, "hubR": hubR, "top": dome[2],
            "dome": dome, "low": low}


def junctions(T, r, angs, road):
    return [T.junction(T.P(r, a), road=road) for a in angs]


def ring_ports(T, k, ring):
    T.port(f"r{k}-", ring[0]); T.port(f"r{k}+", ring[-1])


# ---- dressing: two or three figures on every road node ---------------------------------------------------------
def side_of(T, i):
    u, v = T.pt(i)
    a = math.degrees(math.atan2(u, v))
    return a


def near_themes(T, p, rad=4.2):
    out = set()
    for c in T.clusters[-60:]:
        if not c["nodes"] or c.get("hidden"):
            continue
        q = T.pt(c["nodes"][0])
        if math.dist(p, q) < rad and c["themes"]:
            out.add(c["themes"][0])
    return out


def pick_theme(T, p, cfg, salt=0):
    """Identity themes stay on their side, the element sits in the middle, universal themes scatter everywhere; a
    cluster rarely sits next to its own theme (finding 16)."""
    u, v = p
    a = math.degrees(math.atan2(u, v))
    half = cfg.get("half", 23)
    near = near_themes(T, p)
    cands = []
    if a < -half * 0.25:
        cands += [cfg["left"]] * 3
    if a > half * 0.25:
        cands += [cfg["right"]] * 3
    if abs(a) < half * 0.45:
        cands += [cfg["elem"]] * 2 + [cfg.get("elem2", cfg["elem"])]
    if cfg.get("elem2") and abs(a) >= half * 0.45:
        cands += [cfg["elem2"]]
    cands += cfg.get("universal", UNIVERSAL) * 1
    cands = [t for t in cands if t not in near] or cands
    # pair offence with defence: if a neighbour is offence, lean to defence
    if near & OFFENCE:
        d = [t for t in cands if t in DEFENCE]
        if d and h01(p, salt, "d") < 0.5:
            cands = d
    return cands[int(h01(round(u, 1), round(v, 1), salt) * len(cands))]


def thin_notables(kind, keep):
    """Keep only the last  notables of a filler figure (judge round 5: too much gold; the hand-drawn
    constellations keep all of theirs). The last notables are the ones farthest along the figure."""
    pts, rl, es = P_.PICT[kind]
    deg = [0] * len(pts)
    for e in es:
        deg[e[0]] += 1; deg[e[1]] += 1
    leaves = [j for j in range(1, len(pts)) if deg[j] == 1]
    # judge round 6: every tail must end on a reward. Gold goes to the tips first; interior notables become small.
    if leaves:
        far = sorted(leaves, key=lambda j: -(pts[j][0] ** 2 + pts[j][1] ** 2))
        gold = set(far[:max(keep, min(len(leaves), keep + 1))])
        return "".join("N" if j in gold else "s" for j in range(len(pts)))
    if keep == 0:
        return "s" * len(pts)       # a closed figure in a plain district carries no gold (open figures keep a gold tip)
    idx = [j for j, r in enumerate(rl) if r == "N"]
    drop = set(idx[:-keep]) if keep and len(idx) > keep else set()
    return "".join("s" if j in drop else r for j, r in enumerate(rl))


GOLD_PLAIN = -0.22


def gold_keep(T, p):
    """Judge rounds 15-27 (both models): the gold was spread like confetti at full view. A smooth field over the whole map
    (world coordinates, about 20 units across) marks plain districts, where filler figures that close on themselves
    carry no notable; elsewhere they keep one. Hand-drawn constellations keep all their gold everywhere."""
    if not GOLD_PLAIN:
        return 1
    ax = math.radians(T.R.AXIS)
    u, v = p
    x, y = v * math.sin(ax) + u * math.cos(ax), -v * math.cos(ax) + u * math.sin(ax)
    f = 0.55 * math.sin(x / 8.5 + 0.9) * math.cos(y / 9.5 - 1.4) + 0.45 * math.sin((0.7 * x - 0.7 * y) / 10.5 + 2.6)
    return 0 if f < GOLD_PLAIN else 1


RING_FAMILY = ("hex", "shield", "theta", "spoked", "concentric")
RING_FAMILY_CAP = 6


def fig_for(theme, size, salt, used):
    """A figure for a theme: the theme's own figure when it fits the size class, else one from the size menu."""
    pref = THEME_FIGS.get(theme, [])
    menu = {"s": SMALL_FIGS, "m": MID_FIGS, "b": BIG_FIGS}[size]
    sized = [f for f in pref if f in menu or (size == "b" and f in MID_FIGS) or (size == "s" and f in ("arrow", "V", "kite"))]
    order = sized[:]
    rot = sorted(menu, key=lambda f: (used.get(f, 0), h01(f, salt)))
    order += [f for f in rot if f not in order]
    # judge round 6: cap every stock figure per region, so no shape repeats across a land
    capf = lambda f: ((0 if f not in pref else 2) if f in ("spoked", "eye", "rosette", "theta")
                      else 1 if f == "window"
                      else 2 if f in ("tree", "antler", "cross", "trident", "star", "xcross", "bowtie", "shield", "totem")
                      else 3 if f in ("snowflake", "flake", "hourglass", "gourd2")
                      else 4 if f in ("lollipop", "hex", "kite", "wheel") else 6)
    # a theme's own first figure may run to twice the cap, no further (round 21: the shield and the hourglass, both a
    # theme's first figure, had become the most repeated stamps)
    # judge rounds 21-23: hex, shield and theta all read as one "ring with a gold centre"; capping one moved the
    # repeats to the next, so the family shares one cap per region
    fam = sum(used.get(f, 0) for f in RING_FAMILY)
    return [f for f in order if used.get(f, 0) < capf(f) * (2 if f in pref[:1] else 1)
            and not (f in RING_FAMILY and fam >= RING_FAMILY_CAP)] or order


NEAR_SAME = 7.0


def near_same(T, kind, p, r=NEAR_SAME):
    """Judge rounds 15-18: the same template sat beside a copy of itself (twin fishbones, twin ladders, asterisks in a
    row). A figure kind is not used again within `r` of where it was last drawn, unless nothing else fits."""
    return any(k == kind and math.dist(q, p) < r for k, q in getattr(T, "_kinds", ()))


def mark(T, kind, p):
    if not hasattr(T, "_kinds"):
        T._kinds = []
    T._kinds.append((kind, p))


def apart(T, kinds, p):
    """kinds, minus those drawn nearby; all of them when every one was."""
    far = [f for f in kinds if not near_same(T, f, p)]
    return far or list(kinds)


def dress_roads(T, road_nodes, cfg, per=2, inner_r=36, outer_r=56):
    """Hang figures on road nodes that carry fewer than `per` clusters. Inner nodes carry two small figures; outer
    ones a big figure outward and a small companion (finding 29)."""
    used = cfg.setdefault("_used", {})
    for i in road_nodes:
        have = {T.nodes[x]["cluster"] for x in nbrs(T, i) if T.nodes[x]["cluster"] is not None}
        r = math.hypot(*T.pt(i))
        out = math.degrees(math.atan2(*T.pt(i)))
        if r < 33:
            sizes = ["s"]       # judge round 8: the land near the starts stays airy (one figure per road node)
        elif r < inner_r:
            sizes = ["s", "s"]
        else:
            sizes = None
        sizes = sizes or (["m", "s"] if r < outer_r else ["b", "s"])
        cap = per
        if HUB_THIRD and not LIGHT and r >= inner_r:
            # 2026-11-09 (user: still not packed tightly; PoE 2 hangs 2-3 clusters off most road nodes): a third, small one
            sizes = sizes + ["s"]
            cap = per + 1
        dirs = [0, 180, 60, -60, 120, -120, 30, -30, 150, -150, 90, -90]
        k = 0
        for size in sizes:
            if len(have) + k >= cap:
                break
            got = False
            for d in sorted(dirs, key=lambda d: (abs(d) if size != "s" else abs(abs(d) - 120), h01(i, d))):
                ang = out + d
                tip = (T.pt(i)[0] + 2.5 * math.sin(math.radians(ang)), T.pt(i)[1] + 2.5 * math.cos(math.radians(ang)))
                th = pick_theme(T, tip, cfg, salt=(i, k))
                for kind in apart(T, fig_for(th, size, (i, k), used), tip)[:6]:
                    scale = {"s": 0.75, "m": 0.82, "b": 0.95}[size]
                    got = P_.pict(T, i, ang, kind, th, k=scale, turns=(0, 12, -12, 25, -25), shrink=(1.0, 0.9),
                                  roles=thin_notables(kind, gold_keep(T, tip)))
                    if got:
                        used[kind] = used.get(kind, 0) + 1
                        mark(T, kind, tip)
                        break
                    T.fit_failures.pop()
                if got:
                    break
            if got:
                k += 1


def nbrs(T, i):
    out = []
    for e in T.edges:
        if e["a"] == i:
            out.append(e["b"])
        elif e["b"] == i:
            out.append(e["a"])
    return out


# ---- holes: the empty-space map (holes.py) as a function, and the fill -----------------------------------------
def holes(T, clr=2.0, step=0.5, rmin=12.0, rmax=None):
    rmax = rmax or (T.lim["rmax"] + 0.4)
    ink = [T.pt(i) for i in range(len(T.nodes)) if T.nodes[i]["kind"] != "exit"]
    for e in T.edges:
        if e["kind"] == "exit":
            continue
        a, b = T.pt(e["a"]), T.pt(e["b"])
        n = max(2, int(math.dist(a, b) / 0.35))
        ink += [(a[0] + (b[0] - a[0]) * k / n, a[1] + (b[1] - a[1]) * k / n) for k in range(1, n)]
    grid = {}
    for p in ink:
        grid.setdefault((int(p[0] // 2), int(p[1] // 2)), []).append(p)

    def clearance(p):
        best = 9.0
        cx, cy = int(p[0] // 2), int(p[1] // 2)
        for gx in range(cx - 3, cx + 4):
            for gy in range(cy - 3, cy + 4):
                for q in grid.get((gx, gy), ()):
                    d = math.dist(p, q)
                    if d < best:
                        best = d
        return best

    open_ = {}
    v = rmin
    while v < rmax:
        u = -rmax
        while u < rmax:
            r = math.hypot(u, v)
            if rmin < r < rmax and T.inside(u, v, 0.3):
                c = clearance((u, v))
                # the region's own edge counts as a wall
                if not T.inside(u + 0.0, v, 0.3 + clr * 0.6):
                    c = min(c, clr * 0.9)
                if c > clr:
                    open_[(round(u / step), round(v / step))] = c
            u += step
        v += step
    seen, out = set(), []
    for k in open_:
        if k in seen:
            continue
        comp, st = [], [k]
        while st:
            x = st.pop()
            if x in seen or x not in open_:
                continue
            seen.add(x); comp.append(x)
            st += [(x[0] + 1, x[1]), (x[0] - 1, x[1]), (x[0], x[1] + 1), (x[0], x[1] - 1)]
        if len(comp) >= 3:
            peak = max(comp, key=lambda c: open_[c])
            out.append({"peak": (peak[0] * step, peak[1] * step), "area": len(comp) * step * step, "widest": open_[peak]})
    out.sort(key=lambda h: -h["area"])
    return out


def fill_holes(T, cfg, clr=2.0, rounds=2, max_fills=200, only=None):
    used = cfg.setdefault("_used", {})
    n = 0
    for rd in range(rounds):
        hs = holes(T, clr - 0.15 * rd)
        if only:
            hs = [h for h in hs if any(math.dist(h["peak"], c) < rr for c, rr in only)]
        rings = [c["mastery"] for c in T.clusters if c.get("mastery") and len(c["nodes"]) >= 8]
        for h in hs:
            if n >= max_fills:
                return
            p = h["peak"]
            if any(math.dist(p, m) < 2.8 for m in rings):
                continue      # the centre of a great ring stays open for a cluster mastery (Tinh Thông)
            # judge round 8: PoE 2 thins out toward its starts and thickens toward the rim; ours was even. Holes near
            # the centre need more room before they are filled, so density rises from the starts outward.
            rr_ = math.hypot(*p)
            if not only and h["widest"] < clr - 0.15 * rd + 0.75 * max(0.0, (46.0 - rr_) / 28.0):
                continue
            th = pick_theme(T, p, cfg, salt=("hole", rd))
            big = h["widest"] > 2.6 or h["area"] > 9
            size = "b" if big else "m"
            order = fig_for(th, size, ("h", p), used)
            rest = sorted(["kite", "lollipop", "totem", "cup", "anchor", "arrow", "fan", "eye"],
                          key=lambda f: (used.get(f, 0), h01(f, p)))
            order = apart(T, [f for f in order if f in SYMMETRIC or f in THEME_FIGS.get(th, [])][:5] + rest[:4], p)
            for kind in order:
                ok = P_.place_in(T, p, kind, th, k=0.95 if big else 0.82, ang=math.degrees(math.atan2(*p)),
                                 roles=thin_notables(kind, gold_keep(T, p)))
                if ok:
                    used[kind] = used.get(kind, 0) + 1
                    mark(T, kind, p)
                    n += 1
                    break
                T.fit_failures.pop()


# ---- element lands ----------------------------------------------------------------------------------------------
def land_roads(T, cfg, w):
    """The road skeleton of an element land, after the Metal pilot: two hub roads and the centre road out of the start
    web to ring 1, four ring roads with ports, the edge spokes at about ±21°, and the land's own avenues.
    cfg["rings"]: per ring, the junction angles (W, ..., E); cfg["avenues"]: (ring k, angle a, ring k+1, angle b);
    cfg["lightning"]: True for Water and Wood (the lightning road from Thunder runs just inside their rim)."""
    P = T.P
    rk = cfg["road"]
    J = {}
    rings = {}
    radii = cfg.get("ring_r", C_.RINGS)
    dr = cfg.get("ring_dr", {})
    for k, angs in enumerate(cfg["rings"], start=1):
        r = radii[k - 1]
        J[k] = {a: T.junction(P(r + dr.get((k, a), 0.0), a), road=rk) for a in angs}
    straight = cfg.get("straight", ())
    gaps = set(cfg.get("ring_gaps", ()))
    for k, angs in enumerate(cfg["rings"], start=1):
        rings[k] = [J[k][angs[0]]]
        for a, b in zip(angs, angs[1:]):
            if (k, a) in gaps:
                rings[k].append(J[k][b])
                continue
            rings[k] += T.road([J[k][a], J[k][b]], step=cfg.get("ring_step", (4.5, 4.7, 5.0, 5.0))[k - 1], road=rk, straight=k in straight)[1:]
        T.edge_port(J[k][angs[0]], f"r{k}-"); T.edge_port(J[k][angs[-1]], f"r{k}+")
    hl, hr = cfg["hub_to"]
    jsw = T.junction((-5.4, 23.65), road=rk)
    jfg = T.junction((5.4, 23.65), road=rk)
    out = {"rings": rings, "J": J}
    out["hubL"] = T.road([w["hubL"], jsw, J[1][hl]], step=4.0, road=rk)
    out["hubR"] = T.road([w["hubR"], jfg, J[1][hr]], step=4.0, road=rk)
    if cfg.get("centre_to") is not None:
        out["centre"] = T.road([w["top"], J[1][cfg["centre_to"]]], step=2.6, road=rk)
    sg = set(cfg.get("spoke_gaps", ()))
    for k in (1, 2, 3):
        a, b = cfg["rings"][k - 1][0], cfg["rings"][k][0]
        if f"w{k}" not in sg:
            out[f"w{k}"] = T.road([J[k][a], J[k + 1][b]], step=4.7, road=rk)
        a, b = cfg["rings"][k - 1][-1], cfg["rings"][k][-1]
        if f"e{k}" not in sg:
            out[f"e{k}"] = T.road([J[k][a], J[k + 1][b]], step=4.7, road=rk)
    for j, (k, a, k2, b) in enumerate(cfg.get("avenues", [])):
        mids = [T.junction(P(r, t), road=rk) for r, t in cfg.get("via", {}).get(j, [])]
        out[f"av{j}"] = T.road([J[k][a]] + mids + [J[k2][b]], step=cfg.get("avenue_step", 4.4), road=rk)
    if cfg.get("lightning"):
        angs = [-21.6, -14.6, -7.0, 0.4, 7.6, 14.8, 21.6]
        jit = [0.0, 0.9, -0.7, 1.0, -0.8, 0.7, 0.0]
        js = [T.junction(P(C_.LIGHTNING_R + j, a), road="lightning") for a, j in zip(angs, jit)]
        lm, lp = js[0], js[-1]
        out["lightning"] = T.road(js, step=7.6, road="lightning", long=True, straight=True)
        T.edge_port(lm, "lt-"); T.edge_port(lp, "lt+")
    return out


def place_keys(T, cfg, roads):
    """Outer keystones (whole-tree review: keystones were too few and lost among the notables): each on a longer
    approach, with a clearing round it that nothing else may fill."""
    for (k, a, ang, key, theme) in cfg.get("outer_keys", []):
        at = roads["J"][k][a] if "J" in roads else roads[k][a]
        keystone_spur(T, at, ang, key, theme, n=4, clearing=2.6)


def inner_hidden(T, items, rlo=40, rhi=66):
    """Inner hidden clusters (Kinh Mạch Đồ rule 6: about 15 % of hidden clusters sit inside the tree, linking at depth
    3-7). Each is drawn in one of the largest open spaces of the land's middle, after the roads are dressed, and joined
    by a gate. They read as faint silhouettes: secret realms in the middle of the map."""
    used = []
    for (kind, theme, cond, name, fig) in items:
        rings = [c["mastery"] for c in T.clusters if c.get("mastery") and len(c["nodes"]) >= 8]
        # close-up review (round 30): a sealed cluster sat on a great ring's socket; ring centres stay for the mastery
        hs = [h for h in holes(T, 1.7) if rlo < math.hypot(*h["peak"]) < rhi and all(math.dist(h["peak"], u) > 9 for u in used)
              and all(math.dist(h["peak"], m) > 4.5 for m in rings)]
        for h in hs[:4]:
            n0e, n0c = len(T.edges), len(T.clusters)
            ok = None
            for f in (SEALED_SUB.get(fig, fig), "theta", "eye", "shan", "snowflake"):
                ok = P_.place_in(T, h["peak"], f, "secret", k=0.85, ang=math.degrees(math.atan2(*h["peak"])), name=name, max_reach=3.6)
                if ok:
                    break
                T.fit_failures.pop()
            if ok:
                c = T.clusters[n0c]
                c["hidden"] = {"kind": kind, "theme": theme, "condition": cond, "location": "inner"}
                for i in c["nodes"]:
                    T.nodes[i]["hidden"] = True
                for e in T.edges[n0e:]:
                    if not (T.nodes[e["a"]].get("hidden") and T.nodes[e["b"]].get("hidden")):
                        e["kind"] = "gate"
                used.append(h["peak"])
                break


PLUG_CLR = 1.75
HUB_THIRD = True
QUIET_SCALE = 1.0   # 2026-11-09 (user): the widened clearings read as loose space; back to the drawn size     # round 20: at radius ~4 the clearings did not register at full view


def quiet_fields(T, cfg):
    """Quiet fields (judge round 6: uniform confetti, no focal regions). Each is a clearing of radius [H[2J[3J round a
    sealed realm drawn at its centre: nothing else may be drawn inside, so the land gets breathing room with a landmark
    in it. cfg["quiet"]: (radius r, angle a, clear, (kind, theme, condition, name, figure))."""
    for (r, a, clear, (kind, theme, cond, name, fig)) in cfg.get("quiet", []):
        c = T.P(r, a)
        n0e, n0c = len(T.edges), len(T.clusters)
        ok = None
        # judge round 7: a faint sealed cluster in a clearing looked unfinished; the clearing now holds a visible
        # landmark, a great figure of the land's element theme with all its notables
        lm = cfg.get("landmark", {}).get(len(T.reserved) % 2, (cfg["elem"], "sun"))
        for f in (lm[1], "lotus", "concentric", "sun", "drum"):
            ok = P_.place_in(T, c, f, lm[0], k=1.1, ang=a, name=name.split(": ", 1)[-1], max_reach=clear + 1.5)
            if ok:
                break
            T.fit_failures.pop()
        if ok:
            T.reserved.append((c, clear * QUIET_SCALE))     # an empty clearing reads as unfinished (round 7): reserve only round a landmark


def land_finish(T, cfg, roads, halo_items, per=2):
    place_keys(T, cfg, roads)
    quiet_fields(T, cfg)
    order = []
    for k, v in roads.items():
        if k in ("J", "lightning"):
            continue      # round 19: the lightning road runs bare, as PoE's long highways do (the rim band read as a busy necklace)
        if k == "rings":
            for vv in v.values():
                order += vv
        else:
            order += v
    order = [i for i in dict.fromkeys(order) if T.nodes[i]["kind"] == "travel"]
    dress_roads(T, sorted(order, key=lambda i: math.hypot(*T.pt(i))), cfg, per=per)
    inner_hidden(T, [q[3] for q in cfg.get("quiet", [])][:2])
    fill_holes(T, cfg, clr=2.35 if LIGHT else 2.0, rounds=1 if LIGHT else 2)
    # dense knots (judge rounds 9-11: build a few obvious dense hubs beside the quiet fields)
    knots = [(T.P(r, a), rad) for r, a, rad in cfg.get("dense", [])]
    if knots and not LIGHT:
        fill_holes(T, cfg, clr=1.42, rounds=2, only=knots)
    if not LIGHT:
        fill_holes(T, cfg, clr=PLUG_CLR, rounds=1)     # 2026-11-09 (user): plug the gaps that were still loose
    halo(T, halo_items)


def wheel(T, centre, r, n, theme, notables=(), names=None, name="wheel", form="great wheel", start=180, themes=None):
    """A pass-through ring laid on a road (PoE's wheels you collect on the way): n nodes round `centre`."""
    T.cluster(name, form, mastery=centre)
    nm = iter(names or [])
    ids = []
    for j in range(n):
        a = start + 360 * j / n
        th = (themes or {}).get(j, theme)
        ids.append(T.node(P_.circ(centre, r, [a])[0], "N" if j in notables else "s", th, name=next(nm, None) if j in notables else None))
    for a, b in zip(ids, ids[1:] + ids[:1]):
        T.link(a, b, centre=centre)
    T.end()
    return ids


KEY_CLEAR = 1.9
KEY_APART = 7.0


def keystone_spur(T, at, ang, key, theme, n=2, clearing=0.0):
    """A keystone at the tip of a short dead-end spur (finding 8: every keystone is a deliberate trip). Turns up to
    60 degrees to clear what is drawn."""
    # judge round 15: notables touched keystone halos where a spur ended beside a set piece drawn earlier. First try
    # every turn with the keystone 1.9 clear of anything already drawn (and 1.5 clear of any link), then fall back to
    # the plain fit
    # close-up review (round 30): spurs that fell straight back to the plain fit left keystones on roads and notables, so
    # a middle tier (1.3 from nodes, 1.1 from links) comes before it
    keys_here = [T.pt(i) for i, n in enumerate(T.nodes) if n["kind"] == "keystone"]   # keystones keep apart where they can
    tries = [(d, clr, lclr) for clr, lclr in ((KEY_CLEAR, 1.5), (1.3, 1.1), (0.0, 0.0)) for d in (0, 12, -12, 25, -25, 40, -40, 60, -60)]
    for d, clr, lclr in tries:
        pts = pens_walk(T.pt(at), ang + d, n + 1, 0, 1.2)
        segs = list(zip([T.pt(at)] + pts[:-1], pts))
        if T.fits(pts, segs, skip={at}) and (not clr or all(math.dist(pts[-1], q) >= KEY_APART for q in keys_here)) and (not clr or (all(
                math.dist(pts[-1], T.pt(i)) >= clr for i in {j for c in T._cells(pts[-1], pts[-1], clr) for j in T.gn.get(c, ())} if i != at)
                and all(T._pseg(pts[-1], a_, b_) >= lclr for (a_, b_, ia, ib) in {pc for c in T._cells(pts[-1], pts[-1], lclr) for pc in T.gs.get(c, ())}
                        if at not in (ia, ib)))):
            T.cluster(T.R.KEYSTONES[key]["name"].split(" (")[0] + " spur", "keystone spur")
            sp = T.run(at, pts[:-1], "s" * n, theme)
            T.link(sp[-1], T.node(pts[-1], "K", key=key))
            T.end()
            if clearing:
                T.reserved.append((pts[-1], clearing))
            return True
    T.fit_failures.append(f"keystone {key} on #{at}: {getattr(T, 'why', '?')}")
    return False


def pens_walk(p, ang, n, turn=0.0, step=1.2):
    return P_.walk(p, ang, n, turn, step)


def constellation(T, centre, kind, theme, k=1.2, ang=0.0, names=None, name=None, sats=(), sat_k=0.7):
    """A composed set piece (finding 26: PoE composes groups of clusters as one shape): a central figure placed by hand,
    joined to its nearest road, with satellite figures hung outward from its tips. sats: (kind, theme, names)."""
    ids = P_.place_in(T, centre, kind, theme, k=k, names=names, ang=ang, name=name)
    if not ids:
        T.fit_failures.pop()
        return None
    cx = sum(T.pt(i)[0] for i in ids) / len(ids); cy = sum(T.pt(i)[1] for i in ids) / len(ids)
    mem = set(ids)
    deg = {i: 0 for i in ids}
    for e in T.edges:
        if e["a"] in mem and e["b"] in mem:
            deg[e["a"]] += 1; deg[e["b"]] += 1
    tips = sorted([i for i in ids if deg[i] <= 1], key=lambda i: -math.dist(T.pt(i), (cx, cy)))
    tips = tips or sorted(ids, key=lambda i: -math.dist(T.pt(i), (cx, cy)))
    placed = 0
    for i in tips:
        if placed >= len(sats):
            break
        kind2, theme2, names2 = sats[placed]
        a = math.degrees(math.atan2(T.pt(i)[0] - cx, T.pt(i)[1] - cy))
        if P_.pict(T, i, a, kind2, theme2, names=names2, k=sat_k, turns=(0, 15, -15, 30, -30, 45, -45)):
            placed += 1
        else:
            T.fit_failures.pop()
    return ids


def figure_at(T, centre, kind, theme, k=1.0, ang=0.0, names=None, name=None, themes=None, enter=None, leave=None, form=None):
    """Draw a library figure centred at `centre` (no fit search: used first, by hand, for the big constellations) and
    join it to road node `enter` at its nearest node, and to `leave` at the figure's node nearest to `leave`, so a road
    can pass through it (PoE's pass-through wheels)."""
    pts, rl, es = P_.PICT[kind]
    cx0 = sum(x for x, _ in pts) / len(pts); cy0 = sum(y for _, y in pts) / len(pts)
    a = math.radians(ang)
    dy = (math.sin(a), math.cos(a)); dx = (math.cos(a), -math.sin(a))
    W = lambda x, y: (centre[0] + (x - cx0) * k * dx[0] + (y - cy0) * k * dy[0], centre[1] + (x - cx0) * k * dx[1] + (y - cy0) * k * dy[1])
    T.cluster(name or f"{theme} {kind}", form or kind, mastery=centre)
    nm = iter(names or [])
    ids = [T.node(W(x, y), r_, (themes or {}).get(j, theme), name=next(nm, None) if r_ == "N" else None) for j, ((x, y), r_) in enumerate(zip(pts, rl))]
    for e in es:
        if len(e) == 3:
            T.link(ids[e[0]], ids[e[1]], centre=W(*e[2]))
        else:
            T.link(ids[e[0]], ids[e[1]])
    T.end()
    if enter is not None:
        T.attach(enter, ids)
    if leave is not None:
        T.attach(leave, ids)
    return ids


# ---- blend zones ------------------------------------------------------------------------------------------------
def blend_roads(T, cfg):
    """The roads every blend zone shares: the dantian road up from the hub, an arch carrying the inner ring road
    between the two starts, the four ring roads with their ports, and a centre avenue that wanders a little."""
    P = T.P
    rk = cfg["road"]
    H = T.junction(P(10.7, 0), road="hub")
    T.port("hub", H)
    J0a, J0b = T.junction(P(C_.START_R, -8.6), road="ring"), T.junction(P(C_.START_R, 8.6), road="ring")
    K1, K2, K3 = T.junction(P(21.4, -6.0), road="ring"), T.junction(P(23.6, 0), road="ring"), T.junction(P(21.4, 6.0), road="ring")
    arch = T.road([J0a, K1, K2, K3, J0b], step=2.6, road="ring")
    T.port("r0-", J0a); T.port("r0+", J0b)
    spoke = T.road([H, K2], step=3.4, road="hub")
    wob = cfg.get("wobble", (0, 2.2, -2.0, 1.5, 0))
    out = {"arch": arch, "spoke": spoke}
    cent = [K2]
    key = cfg.get("key") or next(k for k, v in C_.BLEND_AXIS.items() if v == T.R.AXIS)
    l1, l2 = C_.BLEND_LANDS[key]
    bulge = cfg.get("bulge", (1.2, -1.0, 1.4, 0.6))
    braid = cfg.get("braid")
    if braid is not None:
        # judge rounds 3-6 (cobweb): rings 2 and 3 cross over here at one crossroads, so each ring climbs or drops a
        # level between the two lands and the rings braid instead of closing into concentric circles
        a2, a3 = cfg.get("ring_ports", (9.6, 10.0, 10.4, 10.6))[1:3]
        jm2 = T.junction(P(C_.LAND_RINGS[l1][1], -a2), road=rk); jm3 = T.junction(P(C_.LAND_RINGS[l1][2], -a3), road=rk)
        jp2 = T.junction(P(C_.LAND_RINGS[l2][1], a2), road=rk); jp3 = T.junction(P(C_.LAND_RINGS[l2][2], a3), road=rk)
        X = T.junction(P((C_.LAND_RINGS[l1][1] + C_.LAND_RINGS[l2][2]) / 2 + 0.6, braid), road=rk)
        out["braid"] = []
        for j in (jm2, jm3, jp2, jp3):
            out["braid"] += T.road([j, X], step=cfg.get("ring_step", 4.6), road=rk)
        T.edge_port(jm2, "r2-"); T.edge_port(jm3, "r3-"); T.edge_port(jp2, "r2+"); T.edge_port(jp3, "r3+")
    for k in range(1, 5):
        if k > cfg.get("rings", 4):
            break
        if braid is not None and k in (2, 3):
            cent.append(X if k == 2 else None)
            continue
        ra, rb = C_.LAND_RINGS[l1][k - 1], C_.LAND_RINGS[l2][k - 1]
        a = cfg.get("ring_ports", (9.6, 10.0, 10.4, 10.6))[k - 1]
        rc = (ra + rb) / 2 + bulge[k - 1]
        jm, jc, jp = T.junction(P(ra, -a), road=rk), T.junction(P(rc, wob[k]), road=rk), T.junction(P(rb, a), road=rk)
        out[f"ring{k}"] = T.road([jm, jc, jp], step=cfg.get("ring_step", 4.6), road=rk, straight=True)
        T.edge_port(jm, f"r{k}-"); T.edge_port(jp, f"r{k}+")
        cent.append(jc)
    n_av = min(cfg.get("avenue_to", 4), len(cent) - 1)
    if n_av >= 1:
        out["avenue"] = T.road([c for c in cent[:n_av + 1] if c is not None], step=cfg.get("avenue_step", 4.6), road=rk)
    return out


def blend_finish(T, cfg, roads, halo_items):
    for item in cfg.get("keys", []):
        rk_, idx, ang, key, theme = item[:5]
        seq = roads.get(rk_) or roads.get("braid") or roads["arch"]
        if not keystone_spur(T, seq[min(idx, len(seq) - 1)], ang, key, theme, n=item[5] if len(item) > 5 else 4, clearing=2.6):
            T.fit_failures.pop()
            keystone_spur(T, seq[min(idx, len(seq) - 1)], ang, key, theme, n=2, clearing=2.4)
    allroads = [i for k, v in roads.items() for i in v if T.nodes[i]["kind"] == "travel"]
    dress_roads(T, sorted(set(allroads), key=lambda i: math.hypot(*T.pt(i))), cfg, per=1 if LIGHT else cfg.get("per", 2))
    # rule 6: about 15 % of hidden clusters sit inside the tree; the lands held all of them, so each blend zone adds one
    inner_hidden(T, [BLEND_INNER[int(T.R.AXIS // 72) % len(BLEND_INNER)]], rlo=38, rhi=64)
    fill_holes(T, cfg, clr=2.35 if LIGHT else cfg.get("clr", 2.0), rounds=1 if LIGHT else 2)
    if not LIGHT:
        fill_holes(T, cfg, clr=PLUG_CLR, rounds=1)     # 2026-11-09 (user): plug the gaps that were still loose
    halo(T, halo_items)


# ---- the hidden band beyond the rim (sealed and open clusters) --------------------------------------------------
# Kinh Mạch Đồ rule 6: a hidden cluster holds 3-12 acupoints (mean 9). Figures of at most 10 nodes leave room for a
# stem of up to two; larger requests are swapped for a figure of the same spirit.
SEALED_FIGS = ["theta", "snowflake", "eye", "shan", "cloud", "eclipse", "star", "shield", "fish", "spiral", "paw",
               "hourglass", "heart", "cross", "flame", "wave", "vine"]
SEALED_SUB = {"drum": "eclipse", "bagua": "theta", "sun": "star", "flake": "snowflake", "concentric": "theta", "gourd2": "hourglass",
              "lotus": "heart", "pagoda": "shan", "lens": "eye", "window": "cross", "seal": "shield", "coin": "star",
              "cauldron": "flame", "turtle": "shield", "phoenix": "flame"}


def halo(T, items, small=False):
    """items: (angle, kind, theme label, condition, cluster name, figure). Each hidden cluster is drawn beyond the rim
    and joined to the nearest outer node by a gate (a dashed link that points alone cannot cross)."""
    lo, hi = C_.HALO
    for j, (ang, kind, theme, cond, name, fig) in enumerate(items):
        centre = T.P(lo + 2.1 + (h01(ang, name) - 0.5) * 1.8, ang)
        kk = 1.0 + 0.4 * h01(name, "k")
        anchors = [i for i, n in enumerate(T.nodes) if n["kind"] in ("small", "notable", "travel") and not n.get("hidden")
                   and math.hypot(*T.pt(i)) > C_.RIM - 9 and abs(math.degrees(math.atan2(*T.pt(i))) - ang) < 8]
        if not anchors:
            continue
        n0e, n0c = len(T.edges), len(T.clusters)
        T.placing_hidden = False
        with T.limits(rmin=C_.RIM - 6, rmax=hi):
            ok = None
            fig = SEALED_SUB.get(fig, fig)
            pool = SMALL_SEALED if small else SEALED_FIGS
            alt = sorted([x for x in pool if x != fig], key=lambda x: h01(name, x))
            for f in [fig] + alt[:6]:
                ok = P_.place_in(T, centre, f, "secret", k=0.9 if small else kk, ang=ang + (h01(name, "a") - 0.5) * 40, to=anchors,
                                 max_reach=3.6, name=name)
                if ok:
                    break
                T.fit_failures.pop()
        if not ok:
            continue
        c = T.clusters[n0c]
        c["hidden"] = {"kind": kind, "theme": theme, "condition": cond}
        for i in c["nodes"]:
            T.nodes[i]["hidden"] = True
        for e in T.edges[n0e:]:
            if not (T.nodes[e["a"]].get("hidden") and T.nodes[e["b"]].get("hidden")):
                e["kind"] = "gate"
    if not small and getattr(T.R, "HALO_EXTRA", 2):
        halo(T, extra_halo_items(T, getattr(T.R, "HALO_EXTRA", 2)), small=True)


# Kinh Mạch Đồ rule 6 and its tuning (about 75 hidden clusters, sizes drawn round a mean of 8, sd 2): the hand-placed
# band held 59, all of 8-11 acupoints. Each land and blend zone adds small ones (5-7) in the widest gaps of its band.
BLEND_INNER = [   # one inner hidden cluster per blend zone, by axis (36, 108, 180, 252, 324)
    ("sealed", "Way of Alchemy", "cultivation technique", "Sealed: Lost Recipe (Thất Phương)", "eye"),
    ("sealed", "Way of Formations", "item: a Meridian Seal", "Sealed: Sunken Gate (Trầm Môn)", "theta"),
    ("open", "Heart State", "story moment", "Open: Quiet Hermitage (Tĩnh Am)", "eye"),
    ("sealed", "Divine Sense", "event", "Sealed: Buried Eye (Mai Nhãn)", "eye"),
    ("open", "Longevity", "event", "Open: Old Root Grotto (Lão Căn Động)", "theta"),
]
SMALL_SEALED = ["kite", "V", "hex", "arrow", "spoked", "rosette", "wheel", "cup"]
EXTRA_POOL = [
    ("open", "Longevity", "story moment", "Open: Crane's Rest (Hạc Tức)", "rosette"),
    ("sealed", "Divine Sense", "item: a Meridian Seal", "Sealed: Listening Stone (Thính Thạch)", "kite"),
    ("sealed", "Heart State", "cultivation technique", "Sealed: Still Lake (Tĩnh Hồ)", "hex"),
    ("open", "Way of Alchemy", "event", "Open: Cold Furnace (Lãnh Lô)", "V"),
    ("sealed", "Way of Formations", "event", "Sealed: Broken Array (Tàn Trận)", "hex"),
    ("sealed", "Way of Talismans", "item: a Meridian Seal", "Sealed: Blank Slip (Vô Tự Phù)", "kite"),
    ("open", "Beast Taming", "story moment", "Open: Fox Den (Hồ Huyệt)", "rosette"),
    ("sealed", "Artifact Refining", "cultivation technique", "Sealed: Rusted Blade (Tú Kiếm)", "arrow"),
    ("open", "Spirit Fields", "event", "Open: Fallow Field (Hoang Điền)", "wheel"),
    ("sealed", "Longevity", "event", "Sealed: Withered Pine (Khô Tùng)", "spoked"),
    ("open", "Divine Sense", "story moment", "Open: Echo Cave (Hồi Âm Động)", "V"),
    ("sealed", "Heart State", "event", "Sealed: Mirror of Regret (Hối Kính)", "rosette"),
    ("open", "Way of Formations", "item: a Meridian Seal", "Open: Stone Circle (Thạch Hoàn)", "wheel"),
    ("sealed", "Way of Alchemy", "story moment", "Sealed: Pill Tomb (Đan Trủng)", "cup"),
    ("open", "Beast Taming", "event", "Open: Serpent Hollow (Xà Cốc)", "kite"),
    ("sealed", "Way of Talismans", "cultivation technique", "Sealed: Ink Stone (Mặc Thạch)", "hex"),
    ("open", "Artifact Refining", "event", "Open: Cold Anvil (Lãnh Châm)", "spoked"),
    ("sealed", "Spirit Fields", "story moment", "Sealed: Seed of Ages (Cổ Chủng)", "rosette"),
    ("open", "Heart State", "event", "Open: Bell at Dusk (Mộ Chung)", "kite"),
    ("sealed", "Divine Sense", "cultivation technique", "Sealed: Third Eye (Thiên Nhãn)", "hex"),
    ("open", "Longevity", "item: a Meridian Seal", "Open: Peach Orchard (Bàn Đào Viên)", "rosette"),
    ("sealed", "Way of Formations", "story moment", "Sealed: Lost Compass (Thất La Bàn)", "spoked"),
    ("open", "Way of Alchemy", "cultivation technique", "Open: Herb Cellar (Dược Khố)", "cup"),
    ("sealed", "Beast Taming", "item: a Meridian Seal", "Sealed: Caged Roc (Tù Bằng)", "V"),
    ("open", "Way of Talismans", "event", "Open: Brush Grave (Bút Trủng)", "arrow"),
    ("sealed", "Artifact Refining", "story moment", "Sealed: Cracked Cauldron (Liệt Đỉnh)", "wheel"),
    ("open", "Spirit Fields", "cultivation technique", "Open: Rain Terrace Spring (Vũ Tuyền)", "kite"),
    ("sealed", "Heart State", "item: a Meridian Seal", "Sealed: Knot of Grief (Sầu Kết)", "hex"),
    ("open", "Divine Sense", "event", "Open: Watchtower (Vọng Lâu)", "V"),
    ("sealed", "Longevity", "cultivation technique", "Sealed: Hourglass of Bone (Cốt Lậu)", "spoked"),
]


def extra_halo_items(T, n):
    """The widest gaps between the hidden clusters already in this region's band (a gap at the region's edge counts
    as half, since the neighbour's band continues beyond it), filled with small clusters from EXTRA_POOL."""
    half = T.R.HALF_ANGLE
    angs = []
    for c in T.clusters:
        if not c.get("hidden") or not c["nodes"]:
            continue
        pts = [T.pt(i) for i in c["nodes"]]
        u = sum(p[0] for p in pts) / len(pts); v = sum(p[1] for p in pts) / len(pts)
        if math.hypot(u, v) > C_.RIM:
            angs.append(math.degrees(math.atan2(u, v)))
    edges = sorted(angs)
    cands = []
    for a, b in zip([-half] + edges, edges + [half]):
        at_edge = a == -half or b == half
        width = (b - a) * (0.5 if at_edge else 1.0)
        mid = (b - 0.4 * (b - a)) if a == -half else (a + 0.4 * (b - a)) if b == half else (a + b) / 2
        cands.append((width, mid))
    # clusters beyond the rim are not seen by the neighbouring region's fit check, so extras keep clear of the edges
    avoid = getattr(T.R, "HALO_AVOID", ())       # corridors where an island's bridge crosses the band
    cands = [c for c in sorted(cands, reverse=True) if c[0] >= 5.0 and abs(c[1]) < half - 4.5
             and not any(lo_ <= c[1] <= hi_ for lo_, hi_ in avoid)][:n]
    k0 = int(round(T.R.AXIS / 36.0)) * 3          # each region its own slice of three, so no two share a name
    return [(mid,) + EXTRA_POOL[(k0 + j) % len(EXTRA_POOL)] for j, (w, mid) in enumerate(cands)]
