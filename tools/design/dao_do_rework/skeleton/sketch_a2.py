"""Variant A2: the mandala chain (variant A, chosen by the user 2026-11-15) with the user's notes on it.

- Fire's stars were liked; the other lands' figures were "a bit meh, too basic". Each land now has an emblem built out
  as far as Fire's star, one family per land at all three figures:
    Earth  fortress     an octagon round a diamond core, joined by four spokes
    Metal  blade star   a four-pointed star with long thin points
    Water  lotus        a scalloped ring (alternate radii, links bowed outward)
    Wood   leaf         two arcs meeting at the tips, a midrib through the middle, veins to the edge
- Ice: its own figure on Water's middle line between the Water start and Water's middle figure, symmetric down the
  axis: a six-pointed snowflake. It stays part of the Water land (ice and water nodes interchangeable, user).
- Light: a sun. A road disc round the start (two rings) and rays that will be clusters (drawn as faint placeholders).
- Darkness: a crescent moon, horns pointing away from the tree; the Shadow Shrine stays and grows (1.35 times).
- Thunder: a star core, a jagged ring and a crown.
- "Symmetry is important at this step" (user): every figure is mirror-symmetric about its land's axis, and every road
  joins a figure at a node on the axis (spine, start, bridge) or at a mirrored pair (side roads). No nearest-node
  ties are left to chance.
- "Not so sure if the current shape of the islands will allow it to reach the nodes amount" (user): the islands are
  drawn about 19 units in radius (the Chaos centre holds about 500 nodes in that much room), further out from the rim.

Usage: python -I tools/design/dao_do_rework/skeleton/sketch_a2.py <out_dir>   (writes sketch-A2.json, prints checks)
"""
import collections
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import push  # noqa: E402
import sketch as S  # noqa: E402

FAMILY = {"fire": "star", "earth": "fortress", "metal": "blade", "water": "lotus", "wood": "leaf"}
ISLAND_AXIS = {"light": 0.0, "darkness": 180.0, "thunder": 252.0}
DENSITY_LAND, DENSITY_RICH = 0.41, 0.44     # nodes per square unit: an element land, the Chaos centre (full notables)


# ---- local frames ---------------------------------------------------------------------------------------------------
def local(g, i, c, axis):
    """(u, v) of node i in the frame at c whose +v points along `axis` (degrees clockwise from the top)."""
    dx, dy = g.pt(i)[0] - c[0], g.pt(i)[1] - c[1]
    t = math.radians(axis)
    return (dx * math.cos(t) - dy * math.sin(t), dx * math.sin(t) + dy * math.cos(t))


def on_axis(g, ids, c, axis, end, pick="far"):
    """The node of ids on the axis (|u| < 0.3) at the `end` side (+1 out, -1 in): the farthest one ('far') or the one
    nearest c ('near'). None when no node sits on the axis there."""
    cand = [(local(g, i, c, axis), i) for i in ids]
    cand = [(uv, i) for uv, i in cand if abs(uv[0]) < 0.3 and uv[1] * end > 0.1]
    if not cand:
        return None
    key = (lambda t: -abs(t[0][1])) if pick == "far" else (lambda t: abs(t[0][1]))
    return min(cand, key=key)[1]


def side_node(g, ids, c, axis, side):
    """The outermost node of ids on one side (+1 right, -1 left); ties go to the one nearer the tree centre, so the
    two sides always pick mirrored nodes."""
    cand = [(local(g, i, c, axis), i) for i in ids]
    best = max(side * uv[0] for uv, _ in cand)
    tied = [(uv, i) for uv, i in cand if side * uv[0] > best - 0.05]
    return min(tied, key=lambda t: t[0][1])[1]


def _uv(r, a):
    """Local (u, v) at radius r, a degrees clockwise from the axis direction (+v)."""
    return (r * math.sin(math.radians(a)), r * math.cos(math.radians(a)))


def _bow(g, a, b, out_from, s=0.22):
    """Link a and b with an arc bowed away from the point out_from by s times the chord."""
    p, q = g.pt(a), g.pt(b)
    m = ((p[0] + q[0]) / 2, (p[1] + q[1]) / 2)
    L = math.dist(p, q)
    vx, vy = m[0] - out_from[0], m[1] - out_from[1]
    vl = math.hypot(vx, vy) or 1.0
    c = push._circle(p, (m[0] + s * L * vx / vl, m[1] + s * L * vy / vl), q)
    g.link(a, b, centre=c)


# ---- emblems --------------------------------------------------------------------------------------------------------
def emblem(g, fam, c, r, axis, region, st=None, level=0):
    """One land's figure round c, mirror-symmetric about the axis. Returns every road node of the figure. With st,
    the start sits at c and is joined to the figure's nodes on the axis (or a mirrored pair)."""
    w = lambda u, v: (c[0] + S.to_world(axis, u, v)[0], c[1] + S.to_world(axis, u, v)[1])

    def ring(n, radius_of, phase=0.0, bow=False):
        ids = [g.node(w(*_uv(radius_of(k), 360.0 * k / n + phase)), region) for k in range(n)]
        for k in range(n):
            if bow:
                _bow(g, ids[k], ids[(k + 1) % n], c)
            else:
                g.link(ids[k], ids[(k + 1) % n])
        return ids
    if fam == "star":
        ids = ring(10, lambda k: r * (0.72 if k % 2 else 1.0), 36.0 if level == 2 else 0.0)
    elif fam == "fortress":
        ids = ring(8, lambda k: r)
        core = [g.node(w(*_uv(r * 0.46, 90.0 * k)), region) for k in range(4)]
        for k in range(4):
            g.link(core[k], core[(k + 1) % 4])
            g.link(core[k], ids[2 * k])
        ids = ids + core
    elif fam == "blade":
        ids = ring(8, lambda k: r * (0.44 if k % 2 else 1.0), 45.0 if level == 1 else 0.0)
    elif fam == "lotus":
        ids = ring(12 if level != 1 else 16, lambda k: r * (0.8 if k % 2 else 1.0), bow=True)
    elif fam == "snow":
        ids = ring(12, lambda k: r * (0.52 if k % 2 else 1.0))
    elif fam == "leaf":
        t0, t1 = g.node(w(0, -r), region), g.node(w(0, r), region)
        sides = {}
        for s in (-1, 1):
            pts = [w(s * 0.62 * r * math.sin(math.pi * k / 4), -r + 2 * r * k / 4) for k in range(1, 4)]
            seq = [t0] + [g.node(p, region) for p in pts] + [t1]
            for x, y in zip(seq, seq[1:]):
                g.link(x, y)
            sides[s] = seq
        m0, m2 = g.node(w(0, -r / 2), region), g.node(w(0, r / 2), region)
        mid = st if st is not None else g.node(w(0, 0), region)
        for x, y in zip([t0, m0, mid, m2], [m0, mid, m2, t1]):
            g.link(x, y)
        for s in (-1, 1):
            g.link(m0, sides[s][2]); g.link(m2, sides[s][3])
        return sides[-1] + sides[1][1:-1] + [m0, m2] + ([] if st is not None else [mid])
    else:
        raise ValueError(fam)
    if st is not None:
        for end in (-1, 1):
            i = on_axis(g, ids, c, axis, end, pick="near")
            if i is not None:
                g.link(st, i)
            else:       # no node on the axis there: join the nearest mirrored pair
                cand = sorted(ids, key=lambda j: (abs(local(g, j, c, axis)[1] - end * r), abs(local(g, j, c, axis)[0])))
                for j in cand[:2]:
                    g.link(st, j)
    return ids


# ---- islands --------------------------------------------------------------------------------------------------------
def sun(g, C, axis, rim_node):
    """Light: a sun. A road disc round the start (rings of 8 and 20, radius 6.5 and 13), 20 rays of cluster
    placeholders out to about radius 23, a straight bridge down to the rim (user 2026-11-15: the first sun was small)."""
    st = g.node(C, "light", "start", "Light start (Quang)")
    inner = g.loop(C, 6.5, 8, "light", axis=axis)
    outer = g.loop(C, 13.0, 20, "light", axis=axis)
    for k in range(0, 8, 2):            # spokes on the axis and square across it (0, 90, 180, 270)
        g.road(inner[k], outer[k * 20 // 8], "light")
    g.link(st, inner[0]); g.link(st, inner[4])
    for k, o in enumerate(outer):
        a = axis + 18.0 * k
        if abs(((a - axis) % 360) - 180) < 30:
            continue      # the side facing the tree keeps the bridge clear
        prev = o
        for t in (2.5, 5.0, 7.5, 10.0):
            i = g.node((C[0] + (13 + t) * math.sin(math.radians(a)), C[1] + (13 + t) * math.cos(math.radians(a))), "light", "ray")
            g.link(prev, i); prev = i
    g.road(outer[10], rim_node, "light")
    return 13.0 + 10.0 + 2.0


def moon(g, C, axis, R=19.0):
    """Darkness: a crescent. Outer circle R round C, inner circle 0.82 R pushed 0.42 R outward, both drawn round the
    back so the horns point away from the tree; the start in the thick back; stars (placeholders) in the hollow."""
    d = (math.sin(math.radians(axis)), math.cos(math.radians(axis)))
    r2, off = 0.82 * R, 0.42 * R
    C2 = (C[0] + off * d[0], C[1] + off * d[1])
    a_ = (R * R - r2 * r2 + off * off) / (2 * off)
    h = math.sqrt(max(0.0, R * R - a_ * a_))
    perp = (-d[1], d[0])
    base = (C[0] + a_ * d[0], C[1] + a_ * d[1])
    horns = [g.node((base[0] + s * h * perp[0], base[1] + s * h * perp[1]), "darkness") for s in (1, -1)]

    tb = math.atan2(-d[1], -d[0])     # the back

    def back_arc(cc, rr, key=None, step=4.0):
        """Nodes round the back of the circle (cc, rr) from horn 0 to horn 1, mirrored about the axis: one on the axis
        at the back, and (key, radians from the back) a mirrored pair there. Returns the nodes and the key pair."""
        half = []
        for hn in horns:
            p = g.pt(hn)
            th = (math.atan2(p[1] - cc[1], p[0] - cc[0]) - tb + math.pi) % (2 * math.pi) - math.pi
            stops = [0.0] + ([math.copysign(key, th)] if key and key < abs(th) else []) + [th]
            ts = []
            for x, y in zip(stops, stops[1:]):
                n = max(1, int(round(abs(y - x) * rr / step)))
                ts += [x + (y - x) * j / n for j in range(1, n + 1)]
            half.append(ts[:-1])     # the horn is drawn already
        P = lambda t: g.node((cc[0] + rr * math.cos(tb + t), cc[1] + rr * math.sin(tb + t)), "darkness")
        left = [P(t) for t in half[0]]
        mid = P(0.0)
        right = [P(t) for t in half[1]]
        seq = [horns[0]] + list(reversed(left)) + [mid] + right + [horns[1]]
        for x, y in zip(seq, seq[1:]):
            g.link(x, y, centre=cc)
        pair = []
        if key:
            for ids, ts in ((left, half[0]), (right, half[1])):
                j = min(range(len(ts)), key=lambda q: abs(abs(ts[q]) - key))
                pair.append(ids[j])
        return seq, pair
    outer, sides = back_arc(C, R, key=math.pi / 2)
    inner, _ = back_arc(C2, r2)
    stp = (C[0] - 0.7 * R * d[0], C[1] - 0.7 * R * d[1])
    st = g.node(stp, "darkness", "start", "Darkness start (Ám)")
    g.link(st, outer[len(outer) // 2]); g.link(st, inner[len(inner) // 2])
    for k in range(-2, 3):      # stars in the hollow
        a = math.radians(30 * k)
        p = (C2[0] + 0.45 * r2 * (d[0] * math.cos(a) + perp[0] * math.sin(a)), C2[1] + 0.45 * r2 * (d[1] * math.cos(a) + perp[1] * math.sin(a)))
        g.node(p, "darkness", "ray")
    return st, outer + inner, R + 2.0, sides


def thunder(g, C, axis, rim_node):
    """Thunder: a five-pointed star core, a jagged ring of 16, a crown arc of 9 on the far side, a straight bridge."""
    st = g.node(C, "thunder", "start", "Thunder start (Lôi)")
    core = g.loop(C, 6.0, 10, "thunder", shape="star", axis=axis)
    w = lambda r, a: (C[0] + r * math.sin(math.radians(axis + a)), C[1] + r * math.cos(math.radians(axis + a)))
    ring = [g.node(w(11.5 + (1.0 if k % 2 else -1.0), 22.5 * k), "thunder") for k in range(16)]
    for k in range(16):
        g.link(ring[k], ring[(k + 1) % 16])
    for k in range(0, 10, 2):      # the star's points to the ring (mirrored: 0, +-72, +-144)
        a = 36.0 * k
        g.link(core[k], min(ring, key=lambda i: (math.dist(g.pt(i), w(11.5, a)))))
    g.link(st, core[0]); g.link(st, core[5])
    crown = [g.node(w(18.0, -72 + 18 * k), "thunder") for k in range(9)]
    for x, y in zip(crown, crown[1:]):
        g.link(x, y, centre=C)
    for k in (0, 4, 8):
        a = -72 + 18 * k
        g.road(min(ring, key=lambda i: math.dist(g.pt(i), w(12.5, a))), crown[k], "thunder")
    g.road(ring[8], rim_node, "thunder")
    return 18.0 + 3.0


def islands2(g, rim):
    """The three islands, drawn about 19 units in radius, beyond the rim. Darkness keeps its bridge to Water, its
    shadow road to Earth and the Shadow Shrine (1.35 times bigger) from version gen-2026-11-15-lean-rules-3."""
    out = {}
    lc = S.pol(S.RIM + 28.0, ISLAND_AXIS["light"])
    out["light"] = (lc, sun(g, lc, ISLAND_AXIS["light"], rim[ISLAND_AXIS["light"]]))
    tc = S.pol(S.RIM + 25.0, ISLAND_AXIS["thunder"])
    out["thunder"] = (tc, thunder(g, tc, ISLAND_AXIS["thunder"], rim[ISLAND_AXIS["thunder"]]))
    dax = ISLAND_AXIS["darkness"]
    dcen = S.pol(S.RIM + 25.0, dax)
    dst, dring, dR, sides = moon(g, dcen, dax)
    out["darkness"] = (dcen, dR)
    rim_all = [i for i, n in enumerate(g.nodes) if abs(math.hypot(n["x"], n["y"]) - S.RIM) < 0.2]

    def arm(start, to_angle, end=None):
        """From node `start` round the map on its own circle to angle `to_angle` (ending on node `end` when given).
        Returns the nodes."""
        p = g.pt(start)
        R_ = math.hypot(*p)
        a0 = math.degrees(math.atan2(p[0], p[1]))
        da = (to_angle - a0 + 180) % 360 - 180
        n = max(1, int(round(abs(math.radians(da)) * R_ / S.STEP)))
        ids = [start] + [g.node(S.pol(R_, a0 + da * k / n), "darkness") for k in range(1, n)] + [end if end is not None else g.node(S.pol(R_, to_angle), "darkness")]
        for x, y in zip(ids, ids[1:]):
            g.link(x, y, centre=(0.0, 0.0))
        return ids

    def drop(i):
        """Straight in from node i to the rim along its own radius (square to the rim), spliced into the rim."""
        a = math.degrees(math.atan2(*g.pt(i)))
        j = g.node(S.pol(S.RIM, a), "darkness")      # Darkness's own landing on the rim
        # put j into the rim between its two neighbours there
        nb = sorted(rim_all, key=lambda m: math.dist(g.pt(m), g.pt(j)))[:2]
        g.edges[:] = [e for e in g.edges if {e["a"], e["b"]} != set(nb)]
        for m in nb:
            g.link(m, j, centre=(0.0, 0.0))
        rim_all.append(j)
        return g.road(i, j, "darkness")
    east = max(sides, key=lambda i: g.pt(i)[0])
    west = min(sides, key=lambda i: g.pt(i)[0])
    # the east arm runs round the map to the Shadow Shrine, which sits on the arm's circle and meets it head on
    SHRINE_A, SHRINE_RING = 103.0, 7.6
    R_ = math.hypot(*g.pt(east))
    sc = S.pol(R_, SHRINE_A)
    ring = [g.node((sc[0] + SHRINE_RING * math.sin(math.radians(SHRINE_A + 30 * k)), sc[1] + SHRINE_RING * math.cos(math.radians(SHRINE_A + 30 * k))), "darkness")
            for k in range(12)]
    for k in range(12):
        g.link(ring[k], ring[(k + 1) % 12], centre=sc)
    a_gate = SHRINE_A + math.degrees(math.asin(min(1.0, SHRINE_RING / R_)))     # where the arm's circle meets the ring
    toward_moon = min(ring, key=lambda i: math.dist(g.pt(i), S.pol(R_, a_gate)))
    arm(east, math.degrees(math.atan2(*g.pt(toward_moon))), end=toward_moon)
    drop(ring[6])                          # from the shrine straight in to the rim, toward Earth
    # the west arm runs to above Water's gate (206 degrees) and drops straight in
    lw = arm(west, 206.0)
    drop(lw[-1])
    return out


# ---- the map --------------------------------------------------------------------------------------------------------
def variant_a2():
    g = S.G()
    Sst, cring = S.centre(g)
    land = {}
    for name, ax in S.LANDS.items():
        fam = FAMILY[name]
        sp = S.to_world(ax, 0, S.START_R)
        st = g.node(sp, name, "start", f"{name.title()} start")
        e1 = emblem(g, fam, sp, 5.8, ax, name, st=st, level=0)
        r2 = 52.0 if name == "water" else 48.0
        e2c = S.to_world(ax, 0, r2)
        e2 = emblem(g, fam, e2c, 8.0 if name != "water" else 7.4, ax, name, level=1)
        e3c = S.to_world(ax, 0, 69.5)
        e3 = emblem(g, fam, e3c, 6.4, ax, name, level=2)
        chain = [(e1, sp)]
        if name == "water":     # Ice: a snowflake on Water's axis between the start and the middle figure
            ic = S.to_world(ax, 0, 39.6)
            ist = g.node(ic, name, "start", "Ice start (Băng)")
            chain.append((emblem(g, "snow", ic, 4.3, ax, name, st=ist), ic))
        chain += [(e2, e2c), (e3, e3c)]
        for (fa, ca), (fb, cb) in zip(chain, chain[1:]):     # the spine, node on the axis to node on the axis
            g.road(on_axis(g, fa, ca, ax, 1), on_axis(g, fb, cb, ax, -1), name)
        land[name] = (e1, e2, e3, sp, e2c, e3c)
    blend = {}
    for name, ax in S.BLENDS.items():
        c1, c2 = S.to_world(ax, 0, 37.5), S.to_world(ax, 0, 59.0)
        b1 = g.loop(c1, 4.6, 6, name, "circle", axis=ax)
        b2 = g.loop(c2, 5.6, 8, name, "circle", axis=ax)
        g.road(on_axis(g, b1, c1, ax, 1), on_axis(g, b2, c2, ax, -1), name)
        g.road(cring[ax], on_axis(g, b1, c1, ax, -1), name)
        blend[name] = (b1, b2, c1, c2)
        if name == "blend_ww":     # Wind's start sits in the Water-Wood blend's outer figure
            wst = g.node(c2, name, "start", "Wind start (Phong)")
            g.link(wst, on_axis(g, b2, c2, ax, -1)); g.link(wst, on_axis(g, b2, c2, ax, 1))
    order = sorted(list(S.LANDS.items()) + list(S.BLENDS.items()), key=lambda kv: kv[1])
    for (n1, _), (n2, _) in zip(order, order[1:] + order[:1]):
        L, B = (n1, n2) if n1 in S.LANDS else (n2, n1)
        la, ba = S.LANDS[L], S.BLENDS[B]
        side = 1 if ((ba - la) % 360) < 180 else -1
        e1, e2, e3, sp, e2c, e3c = land[L]; b1, b2, c1, c2 = blend[B]
        g.road(side_node(g, e1, sp, la, side), side_node(g, b1, c1, ba, -side), L)
        g.road(side_node(g, e2, e2c, la, side), side_node(g, b2, c2, ba, -side), L)
    rim = g.ring_with(S.RIM, list(S.LANDS.values()) + list(S.BLENDS.values()), S.region_at)
    for name, ax in S.LANDS.items():
        e3, e3c = land[name][2], land[name][5]
        g.road(on_axis(g, e3, e3c, ax, 1), rim[ax], name)
    for name, ax in S.BLENDS.items():
        b2, c2 = blend[name][1], blend[name][3]
        g.road(on_axis(g, b2, c2, ax, 1), rim[ax], name)
    isl = islands2(g, rim)
    return g, isl


# ---- checks ---------------------------------------------------------------------------------------------------------
def symmetry(g, ids, c, axis):
    """Share of road nodes with a mirror twin (same kind) across the line through c along `axis`."""
    pts = [(local(g, i, c, axis), g.nodes[i]["kind"]) for i in ids]
    ok = sum(1 for (u, v), k in pts if any(abs(u + u2) < 0.4 and abs(v - v2) < 0.4 and k2 == k for (u2, v2), k2 in pts))
    return round(ok / max(1, len(pts)), 2)


def checks(g, isl):
    keep = [n for n in g.nodes if n["kind"] != "ray"]
    idx = {n["id"]: k for k, n in enumerate(keep)}
    h = S.G()
    for n in keep:
        h.nodes.append(dict(n, id=idx[n["id"]]))
    for e in g.edges:
        if e["a"] in idx and e["b"] in idx:
            h.edges.append(dict(e, a=idx[e["a"]], b=idx[e["b"]]))
    out = S.checks(h)
    road = lambda reg: [i for i, n in enumerate(g.nodes) if n["region"] == reg and n["kind"] in ("travel", "start")]
    sym = {reg: symmetry(g, road(reg), (0.0, 0.0), ax) for reg, ax in list(S.LANDS.items()) + list(S.BLENDS.items())}
    sym["hub"] = symmetry(g, road("hub"), (0.0, 0.0), 36.0)
    for reg, (c, R) in isl.items():
        ids = [i for i in road(reg) if math.dist(g.pt(i), c) < R + 1]
        sym[reg] = symmetry(g, ids, (0.0, 0.0), ISLAND_AXIS[reg])
    out["symmetry (share mirrored)"] = sym
    wedge = math.pi * (S.RIM ** 2 - S.CENTRE_R ** 2) * 36.0 / 360.0
    cap = {"each land (36 degrees)": round(wedge * DENSITY_LAND), "each blend (36 degrees)": round(wedge * DENSITY_LAND),
           "Chaos centre": round(math.pi * S.CENTRE_R ** 2 * DENSITY_RICH)}
    for reg, (c, R) in isl.items():
        cap[reg] = round(math.pi * R * R * DENSITY_RICH)
    out["estimated node capacity"] = cap
    return out


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    g, isl = variant_a2()
    json.dump({"nodes": g.nodes, "edges": g.edges, "variant": "A2"}, open(os.path.join(out, "sketch-A2.json"), "w", encoding="utf-8"), ensure_ascii=False)
    print(json.dumps(checks(g, isl), ensure_ascii=False, indent=1))


if __name__ == "__main__":
    main()
