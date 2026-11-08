"""Drawing pens shared by every land of the Kinh Mạch Đồ rework (build_region.py v6).

Every pen draws by hand-given position and direction; nothing is placed by search except that pict(fit=True) may
turn a figure a little (up to 45 degrees) or shrink it (to 80 %) so it clears what is already drawn.
Angles are degrees clockwise from +v (the land's axis); a figure's +y points away from the node it hangs off.
"""
import math


def rad(a):
    return math.radians(a)


def circ(c, r, angs):
    """Points on a circle; angles in degrees clockwise from +v."""
    return [(c[0] + r * math.sin(rad(a)), c[1] + r * math.cos(rad(a))) for a in angs]


def place(o, th):
    """A local pen at o, turned th degrees clockwise: x right, y outward."""
    c, s = math.cos(rad(th)), math.sin(rad(th))
    return lambda x, y: (o[0] + x * c + y * s, o[1] - x * s + y * c)


def walk(p, ang, n, turn=0.0, step=1.2):
    pts, a, (x, y) = [], ang, p
    for _ in range(n):
        x, y = x + step * math.sin(rad(a)), y + step * math.cos(rad(a))
        pts.append((x, y))
        a += turn
    return pts


# ---- pocket pens: small clusters hung off one node, each placed by hand -------------------------------------
def arcp(T, at, ang, roles, theme, turn=20, step=1.2, names=None, name=None, rho=1.35, spacing=46):
    """PoE 1's orbit arc: the pocket's nodes sit on a small circle beyond `at`, the first one facing it, and curl
    round the circle (to the right when turn > 0, else to the left); the notable usually last."""
    T.cluster(name or f"{theme} arc", "arc")
    p = T.pt(at)
    d = 1.1 + rho
    g = (p[0] + d * math.sin(rad(ang)), p[1] + d * math.cos(rad(ang)))
    side = 1 if turn >= 0 else -1
    pts = circ(g, rho, [ang + 180 + side * spacing * j for j in range(len(roles))])
    ids = T.run(at, pts[:1], roles[:1], theme, (names or [None])[:1] if roles[0] == "N" else None)
    nm = iter(names or [])
    if roles[0] == "N":
        next(nm, None)
    for pt_, ro in zip(pts[1:], roles[1:]):
        i = T.node(pt_, ro, theme, name=next(nm, None) if ro == "N" else None)
        T.link(ids[-1], i, centre=g)
        ids.append(i)
    T.clusters[T.cur]["mastery"] = g
    T.end()
    return ids


def lolli(T, at, ang, theme, k=5, r=1.0, notables=(2,), stem=1, step=1.15, names=None, name=None, themes=None):
    """A stem of small nodes into a ring of k; notables at the given ring positions (0 = where the stem joins)."""
    T.cluster(name or f"{theme} lollipop", "lollipop")
    sp = walk(T.pt(at), ang, stem, 0, step)
    sid = T.run(at, sp, "s" * stem, theme)
    e = walk(sp[-1], ang, 1, 0, step)[0]
    c = (e[0] + r * math.sin(rad(ang)), e[1] + r * math.cos(rad(ang)))
    a0 = ang + 180
    pts = circ(c, r, [a0 + 360 * j / k for j in range(k)])
    roles = "".join("N" if j in notables else "s" for j in range(k))
    th = themes or [theme] * k
    ids, nm = [], iter(names or [])
    for j, (p, ro) in enumerate(zip(pts, roles)):
        ids.append(T.node(p, ro, th[j], name=next(nm, None) if ro == "N" else None))
    for x, y in zip(ids, ids[1:] + ids[:1]):
        T.link(x, y, centre=c)
    T.link(sid[-1], ids[0])
    T.clusters[T.cur]["mastery"] = c
    T.end()
    return sid + ids


def fork(T, at, ang, theme, spread=38, step=1.15, roles=("sN", "sN"), names=None, name=None, themes=None):
    """A stem node that splits into two arms."""
    T.cluster(name or f"{theme} fork", "fork")
    st = T.run(at, walk(T.pt(at), ang, 1, 0, step), "s", theme)[0]
    out, nm = [st], iter(names or [])
    for side, ro in zip((-1, 1), roles):
        th = (themes or {}).get(side, theme)
        pts = walk(T.pt(st), ang + side * spread, len(ro), -side * spread * 0.5, step)
        ids = []
        prev = st
        for p, r_ in zip(pts, ro):
            i = T.node(p, r_, th, name=next(nm, None) if r_ == "N" else None)
            T.link(prev, i)
            ids.append(i)
            prev = i
        out += ids
    T.end()
    return out


def diam(T, at, ang, theme, step=1.15, open_=40, tip="N", sides="ss", names=None, name=None):
    """An entry node opening into a diamond whose far tip is the notable."""
    T.cluster(name or f"{theme} diamond", "diamond")
    e = T.run(at, walk(T.pt(at), ang, 1, 0, step), "s", theme)[0]
    l_ = T.node(walk(T.pt(e), ang - open_, 1, 0, step)[0], sides[0], theme)
    r_ = T.node(walk(T.pt(e), ang + open_, 1, 0, step)[0], sides[1], theme)
    t = T.node(walk(T.pt(e), ang, 1, 0, 2 * step * math.cos(rad(open_)))[0], tip, theme, name=(names or [None])[0])
    for a, b in ((e, l_), (e, r_), (l_, t), (r_, t)):
        T.link(a, b)
    T.end()
    return [e, l_, r_, t]


def leaf(T, at, ang, theme, length=3.4, width=1.0, left="ss", right="ss", tip="N", names=None, name=None):
    """Two arcs leave `at` and meet at a tip: a teardrop loop."""
    T.cluster(name or f"{theme} leaf", "leaf")
    p = T.pt(at)
    tp = (p[0] + length * math.sin(rad(ang)), p[1] + length * math.cos(rad(ang)))
    t = T.node(tp, tip, theme, name=(names or [None])[0])
    a = T.chain(at, t, left, theme, bend=width)
    b = T.chain(at, t, right, theme, bend=-width)
    T.end()
    return [t] + a + b


def span(T, a, b, roles, theme, bend=0.0, names=None, name=None):
    """A small cluster strung between two road nodes, so it can be reached from either side."""
    T.cluster(name or f"{theme} span", "span")
    ids = T.chain(a, b, roles, theme, bend=bend, names=names)
    T.end()
    return ids


# ---- pictograms: PoE 2's figure shapes (design/research/passive-tree-study.md, cluster shape audit) ---------------
# Each is drawn in a local frame: the entry node at (0, 0), +y pointing away from the node it hangs off, +x to the
# right. Roles: s small, N notable. Links are straight unless a bend is given.
def _ring_pts(cx, cy, r, angs):
    return [(cx + r * math.sin(rad(a)), cy + r * math.cos(rad(a))) for a in angs]


PICT = {
    # four-node kite, notable at the far corner (Mental Toughness)
    "kite": ([(0, 0), (-0.85, 0.95), (0.85, 0.95), (0, 1.9)], "sssN", [(0, 1), (0, 2), (1, 3), (2, 3)]),
    # bent lines (Natural Immunity, Lucky Rabbit Foot, Heatproof)
    "L": ([(0, 0), (0, 1.15), (0, 2.3), (1.1, 2.3)], "sssN", [(0, 1), (1, 2), (2, 3)]),
    "V": ([(0, 0), (-0.75, 0.95), (-1.5, 1.9), (0.75, 0.95), (1.5, 1.9)], "ssNsN", [(0, 1), (1, 2), (0, 3), (3, 4)]),
    "cup": ([(0, 0), (-1.0, 0.35), (-1.35, 1.45), (-1.05, 2.5), (1.0, 0.35), (1.35, 1.45), (1.05, 2.5)], "sssNssN",
            [(0, 1), (1, 2), (2, 3), (0, 4), (4, 5), (5, 6)]),
    # zigzag and staircase (Electrocuting Exposure, Invigorating Archon)
    "zig": ([(0, 0), (0.75, 0.9), (0, 1.8), (0.75, 2.7), (0, 3.6)], "ssssN", [(0, 1), (1, 2), (2, 3), (3, 4)]),
    "stairs": ([(0, 0), (0, 1.1), (1.1, 1.1), (1.1, 2.2), (2.2, 2.2), (2.2, 3.3)], "sssssN", [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5)]),
    # forks (Elemental Force, Spiked Whip, Blade Catcher)
    "trident": ([(0, 0), (0, 1.1), (-1.0, 1.7), (-1.0, 2.8), (0, 2.2), (0, 3.3), (1.0, 1.7), (1.0, 2.8)], "sssNsNsN",
                [(0, 1), (1, 2), (2, 3), (1, 4), (4, 5), (1, 6), (6, 7)]),
    "tristar": ([(0, 0), (0, 1.1), (0, 2.2), (-0.95, 2.75), (-1.9, 3.3), (0.95, 2.75), (1.9, 3.3)], "ssssNsN",
                [(0, 1), (1, 2), (2, 3), (3, 4), (2, 5), (5, 6)]),
    "anchor": ([(0, 0), (0, 1.1), (0, 2.2), (-1.05, 2.3), (-1.9, 1.75), (1.05, 2.3), (1.9, 1.75)], "ssssNsN",
               [(0, 1), (1, 2), (2, 3), (3, 4), (2, 5), (5, 6)]),
    # crosses and stars (Lust for Sacrifice, Blade Flurry, Expendable Army)
    "cross": ([(0, 0), (0, 1.1), (0, 2.2), (0, 3.3), (-1.1, 1.1), (-2.2, 1.1), (1.1, 1.1), (2.2, 1.1)], "sssNsNsN",
              [(0, 1), (1, 2), (2, 3), (1, 4), (4, 5), (1, 6), (6, 7)]),
    "xcross": ([(0, 0), (0, 1.1), (-0.85, 1.95), (-1.7, 2.8), (0.85, 1.95), (1.7, 2.8), (-0.85, 0.25), (0.85, 0.25)], "sssNsNss",
               [(0, 1), (1, 2), (2, 3), (1, 4), (4, 5), (1, 6), (1, 7)]),
    "star": ([(0, 0), (0, 1.2), (0, 2.35), (-0.95, 1.75), (-1.9, 2.3), (0.95, 1.75), (1.9, 2.3), (-1.0, 0.65), (1.0, 0.65)], "ssNsNsNss",
             [(0, 1), (1, 2), (1, 3), (3, 4), (1, 5), (5, 6), (1, 7), (1, 8)]),
    # a sword: hilt, crossguard, blade, notable at the point (Focused Thrust's spear)
    "sword": ([(0, 0), (0, 1.0), (-1.0, 1.0), (1.0, 1.0), (0, 2.1), (0, 3.2), (0, 4.3)], "ssssssN",
              [(0, 1), (1, 2), (1, 3), (1, 4), (4, 5), (5, 6)]),
    # an arrowhead (Piercing Shot)
    "arrow": ([(0, 0), (0, 1.1), (0, 2.2), (-0.9, 2.65), (0.9, 2.65), (0, 3.4)], "sssssN", [(0, 1), (1, 2), (2, 3), (2, 4), (3, 5), (4, 5)]),
    # hourglass for lifespan (Lasting Toxins without handles)
    "hourglass": ([(0, 0), (-0.9, 0.6), (0.9, 0.6), (0, 1.5), (-0.9, 2.4), (0.9, 2.4), (0, 3.0)], "sssNssN",
                  [(0, 1), (0, 2), (1, 3), (2, 3), (3, 4), (3, 5), (4, 6), (5, 6)]),
    # a heart for Tâm Cảnh (Mystical Rage)
    "heart": ([(0, 0), (-0.95, 0.85), (-1.45, 1.95), (-0.8, 2.75), (0, 2.15), (0.8, 2.75), (1.45, 1.95), (0.95, 0.85)], "sssNsNss",
              [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 0)]),
    # an eye for thần thức: two lids and a pupil
    "eye": ([(0, 0), (-0.85, 0.25), (-1.6, 1.25), (-0.85, 2.25), (0, 2.5), (0.85, 2.25), (1.6, 1.25), (0.85, 0.25), (0, 1.25)], "ssssssssN",
            [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 6), (6, 7), (7, 0), (0, 8), (8, 4)]),
    # a hexagon with a notable at its crown (Smoke Inhalation)
    "hex": ([(0, 0), (-1.0, 0.6), (-1.0, 1.8), (0, 2.4), (1.0, 1.8), (1.0, 0.6)], "sssNss", [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 0)]),
    # two kites in a column (Supportive Ancestors' totem)
    "totem": ([(0, 0), (-0.8, 0.9), (0.8, 0.9), (0, 1.8), (-0.8, 2.7), (0.8, 2.7), (0, 3.6)], "ssssNsN",
              [(0, 1), (0, 2), (1, 3), (2, 3), (3, 4), (3, 5), (4, 6), (5, 6)]),
}
# a cash coin (đồng tiền) for Metal: a ring of eight round a square hole, joined at the corners
_coin_ring = _ring_pts(0, 1.55, 1.55, [180 + 45 * j for j in range(8)])
_coin_sq = [(-0.5, 1.05), (-0.5, 2.05), (0.5, 2.05), (0.5, 1.05)]
PICT["coin"] = (_coin_ring + _coin_sq, "ssssNsss" + "sNsN",
                [(j, (j + 1) % 8, (0, 1.55)) for j in range(8)] + [(8, 9), (9, 10), (10, 11), (11, 8), (1, 8), (3, 9), (5, 10), (7, 11)])
# a lollipop (PoE 2: 11 % of clusters) and a small wheel on a stem
PICT["lollipop"] = ([(0, 0)] + _ring_pts(0, 2.1, 1.0, [180, 252, 324, 36, 108]), "sssNss",
                    [(0, 1)] + [(1 + j, 1 + (j + 1) % 5, (0, 2.1)) for j in range(5)])
PICT["wheel"] = ([(0, 0)] + _ring_pts(0, 2.35, 1.25, [180, 240, 300, 0, 60, 120]), "sssNsNs",
                 [(0, 1)] + [(1 + j, 1 + (j + 1) % 6, (0, 2.35)) for j in range(6)])
# ---- symmetric figures from the shape audit (PoE 2's lattices, lenses and rings) ------------------------------
def _ring_edges(first, n, centre):
    return [(first + j, first + (j + 1) % n, centre) for j in range(n)]


# theta: a ring of eight split by a diameter through a notable at its centre (Mending Deflection)
_th = _ring_pts(0, 1.5, 1.5, [180 + 45 * j for j in range(8)])
PICT["theta"] = (_th + [(0, 1.5)], "ssssNsss" + "N", _ring_edges(0, 8, (0, 1.5)) + [(2, 8), (6, 8)])
# snowflake: a hexagon of six round a centre notable, each corner joined to it, three corners grown into points
_sf_in = _ring_pts(0, 1.2, 1.2, [180 + 60 * j for j in range(6)])
_sf_out = _ring_pts(0, 1.2, 2.35, [0, 120, 240])
PICT["snowflake"] = (_sf_in + [(0, 1.2)] + _sf_out, "ssssss" + "N" + "Nss",
                     [(j, (j + 1) % 6) for j in range(6)] + [(j, 6) for j in range(6)] + [(3, 7), (5, 8), (1, 9)])
# concentric rings: a ring of eight round a ring of four, joined left and right (Illuminated Crown)
_co_out = _ring_pts(0, 1.65, 1.65, [180 + 45 * j for j in range(8)])
_co_in = _ring_pts(0, 1.65, 0.75, [180, 270, 0, 90])
PICT["concentric"] = (_co_out + _co_in, "ssssNsss" + "ssNs",
                      _ring_edges(0, 8, (0, 1.65)) + _ring_edges(8, 4, (0, 1.65)) + [(2, 9), (6, 11)])
# bowtie: two triangles meeting at a centre node
PICT["bowtie"] = ([(0, 0), (0, 1.15), (-1.15, 0.55), (-1.15, 1.85), (1.15, 0.55), (1.15, 1.85), (0, 2.3)], "sssNsNs",
                  [(0, 1), (1, 2), (2, 3), (3, 1), (1, 4), (4, 5), (5, 1), (1, 6)])
# lens: two hubs joined by three lanes, notables on the middle and top lanes (PoE 1's Witch bridge, small)
PICT["lens"] = ([(0, 0), (-0.9, 0.4), (-1.65, 1.5), (0.9, 0.4), (1.65, 1.5), (-0.8, 1.5), (0, 1.5), (0.8, 1.5), (-0.9, 2.6), (0, 3.0), (0.9, 2.6)],
                "ssssssNssNs",
                [(0, 1), (1, 2), (0, 3), (3, 4), (2, 5), (5, 6), (6, 7), (7, 4), (2, 8), (8, 9), (9, 10), (10, 4)])
# window: a three-by-three grid
_w = [(x, y) for y in (0, 1.1, 2.2) for x in (-1.1, 0, 1.1)]
_w = [_w[1], _w[0], _w[2], _w[3], _w[4], _w[5], _w[6], _w[7], _w[8]]   # entry first: the bottom middle
PICT["window"] = (_w, "ssssssNsN",
                  [(0, 1), (0, 2), (1, 3), (0, 4), (2, 5), (3, 4), (4, 5), (3, 6), (4, 7), (5, 8), (6, 7), (7, 8)])
# spoked ring: a ring of six with a notable at its centre on one spoke (Pinpoint Shot)
_sp = _ring_pts(0, 1.3, 1.3, [180 + 60 * j for j in range(6)])
PICT["spoked"] = (_sp + [(0, 1.3)], "sssNss" + "N", _ring_edges(0, 6, (0, 1.3)) + [(3, 6)])
ASYM = {"L", "stairs", "zig"}
DENSE = {"window": 0.88, "snowflake": 0.88, "theta": 0.82, "concentric": 0.85, "lens": 0.82, "coin": 0.85, "star": 0.8, "bowtie": 0.75, "spoked": 0.75, "eye": 0.7}


def pict(T, at, ang, kind, theme, names=None, k=1.0, mirror=False, roles=None, themes=None, name=None, gap=1.0,
         fit=True, turns=(0, 10, -10, 20, -20, 30, -30, 45, -45, 60, -60), shrink=(1.0, 0.92, 0.85), stem=0):
    """Hang a pictogram off node `at`, pointing `ang` degrees (clockwise from +v). With fit, the figure may turn up to
    45 degrees or shrink to 80 % to stay clear of what is drawn; if nothing fits, it is left out and reported."""
    pts, rl, es = PICT[kind]
    rl = roles or rl
    p = T.pt(at)

    def frame(a, kk, mm):
        dy = (math.sin(rad(a)), math.cos(rad(a)))
        dx = (math.cos(rad(a)), -math.sin(rad(a)))
        m = -1 if mm else 1
        o = (p[0] + (gap + stem * 1.05) * dy[0], p[1] + (gap + stem * 1.05) * dy[1])
        return lambda x, y: (o[0] + m * x * kk * dx[0] + y * kk * dy[0], o[1] + m * x * kk * dx[1] + y * kk * dy[1])

    def stem_pts(a):
        return [(p[0] + 1.05 * (j + 1) * math.sin(rad(a)), p[1] + 1.05 * (j + 1) * math.cos(rad(a))) for j in range(stem)]

    choice = None
    floor = DENSE.get(kind, 0.66)     # dense figures turn into blobs when small: draw them at least this big
    k = max(k, floor)
    tries = [(k * sh, a_, mm) for sh in (shrink if fit else (1.0,)) if k * sh >= floor for a_ in (turns if fit else (0,))
             for mm in ((mirror, not mirror) if (fit and kind in ASYM) else (mirror,))]
    for kk, d, mm in tries:
        W = frame(ang + d, kk, mm)
        P_ = [W(x, y) for x, y in pts]
        S_ = stem_pts(ang + d)
        chain_ = [p] + S_ + [P_[0]]
        segs = [(chain_[j], chain_[j + 1]) for j in range(len(chain_) - 1)] + [(P_[e[0]], P_[e[1]]) for e in es]
        if not fit or T.fits(S_ + P_, segs, skip={at}):
            choice = (W, P_, S_)
            break
    if choice is None:
        T.fit_failures.append(f"{kind} ({theme}) on #{at} toward {ang:.0f}: last reason {getattr(T, 'why', '?')}")
        return None
    W, P_, S_ = choice
    T.cluster(name or f"{theme} {kind}", kind)
    stem_ids = [T.node(xy, "s", theme) for xy in S_]
    nm = iter(names or [])
    ids = [T.node(xy, r_, (themes or {}).get(j, theme), name=next(nm, None) if r_ == "N" else None)
           for j, (xy, r_) in enumerate(zip(P_, rl))]
    for e in es:
        if len(e) == 3:
            T.link(ids[e[0]], ids[e[1]], centre=W(*e[2]))
        else:
            T.link(ids[e[0]], ids[e[1]])
    cx = sum(T.pt(i)[0] for i in ids) / len(ids); cy = sum(T.pt(i)[1] for i in ids) / len(ids)
    T.clusters[T.cur]["mastery"] = (cx, cy) if kind in ("coin", "heart", "hex", "eye", "hourglass", "totem", "kite", "lollipop", "wheel", "theta", "concentric", "spoked", "window") else None
    T.end()
    chain_ = [at] + stem_ids + [ids[0]]
    for x, y in zip(chain_, chain_[1:]):
        T.link(x, y)
    return stem_ids + ids


def toward(T, i, pt):
    """The angle from node i toward the point pt (u, v)."""
    u, v = T.pt(i)
    return math.degrees(math.atan2(pt[0] - u, pt[1] - v))


def dress(T, at, *figs):
    """Hang several figures off one road node. Each fig: (kind, theme, angle, scale, [notable names], {options})."""
    out = []
    for f in figs:
        alts = f if isinstance(f, list) else [f]     # a list holds hand-chosen fallbacks, tried in order
        n0 = len(T.fit_failures)
        got = None
        for g in alts:
            kind, theme, ang, k = g[:4]
            names = g[4] if len(g) > 4 else None
            opts = g[5] if len(g) > 5 else {}
            got = pict(T, at, ang, kind, theme, names=names, k=k, **opts)
            if got:
                break
        if got:
            del T.fit_failures[n0:]
        else:
            del T.fit_failures[n0 + 1:]
        out.append(got)
    return out


def out_angle(T, i, turn=0.0):
    """The angle pointing straight out from the tree centre at node i, turned by `turn` degrees."""
    u, v = T.pt(i)
    return math.degrees(math.atan2(u, v)) + turn


def nearest(T, ids, target):
    """The node of ids nearest to node `target`."""
    p = T.pt(target)
    return min(ids, key=lambda i: math.dist(T.pt(i), p))


def place_in(T, centre, kind, theme, k=1.0, names=None, ang=0.0, themes=None, name=None, to=None, max_reach=5.5):
    """Draw a figure centred in an open space and join it to the nearest road node (or, failing that, the nearest
    node of another cluster) by its own nearest node, through a short stem when the gap is long."""
    pts, rl, es = PICT[kind]
    k = max(k, DENSE.get(kind, 0.0))
    cx0 = sum(x for x, _ in pts) / len(pts); cy0 = sum(y for _, y in pts) / len(pts)
    best = None
    for dc in ((0, 0), (0.5, 0), (-0.5, 0), (0, 0.5), (0, -0.5), (0.7, 0.7), (-0.7, 0.7), (0.7, -0.7), (-0.7, -0.7)):
        for d in (0, 15, -15, 30, -30, 45, -45, 60, -60, 90, 180):
            for kk in (k, k * 0.92):
                a = ang + d
                dy = (math.sin(rad(a)), math.cos(rad(a))); dx = (math.cos(rad(a)), -math.sin(rad(a)))
                c = (centre[0] + dc[0], centre[1] + dc[1])
                W = lambda x, y, c=c, dx=dx, dy=dy, kk=kk: (c[0] + (x - cx0) * kk * dx[0] + (y - cy0) * kk * dy[0],
                                                            c[1] + (x - cx0) * kk * dx[1] + (y - cy0) * kk * dy[1])
                P_ = [W(x, y) for x, y in pts]
                segs = [(P_[e[0]], P_[e[1]]) for e in es]
                if not T.fits(P_, segs, skip=set()):
                    continue
                # the join: nearest road node first, then any other cluster's node
                cands = to if to is not None else [i for i, n in enumerate(T.nodes) if n["kind"] in ("travel", "start")]
                cands2 = [i for i, n in enumerate(T.nodes) if n["kind"] in ("small",) and n.get("cluster") is not None]
                for pool in (cands, cands2):
                    opts = sorted(((math.dist(T.pt(t), P_[j]), t, j) for t in pool for j in range(len(P_))), key=lambda z: z[0])
                    for dist_, t, j in opts[:40]:
                        if dist_ > max_reach:
                            break
                        # the figure must be joined at its own nearest node to t
                        if any(math.dist(T.pt(t), P_[m]) < dist_ - 1e-6 for m in range(len(P_))):
                            continue
                        ct = T.nodes[t].get("cluster")
                        if ct is not None and any(math.dist(T.pt(m), P_[j]) * 1.15 < dist_ for m in T.clusters[ct]["nodes"]):
                            continue        # joining another cluster: it too must be joined at its nearest node
                        n_stem = max(0, int(dist_ / 1.25) - 1) if dist_ > 2.2 else 0
                        S_ = [(T.pt(t)[0] + (P_[j][0] - T.pt(t)[0]) * (q + 1) / (n_stem + 1),
                               T.pt(t)[1] + (P_[j][1] - T.pt(t)[1]) * (q + 1) / (n_stem + 1)) for q in range(n_stem)]
                        chain_ = [T.pt(t)] + S_ + [P_[j]]
                        csegs = [(chain_[q], chain_[q + 1]) for q in range(len(chain_) - 1)]
                        if T.fits(S_ + P_, segs + csegs, skip={t}):
                            best = (W, P_, S_, t, j)
                            break
                    if best:
                        break
                if best:
                    break
            if best:
                break
        if best:
            break
    if best is None:
        T.fit_failures.append(f"{kind} ({theme}) in the space at ({centre[0]:.1f},{centre[1]:.1f}): last reason {getattr(T, 'why', '?')}")
        return None
    W, P_, S_, t, j = best
    T.cluster(name or f"{theme} {kind}", kind)
    stem_ids = [T.node(xy, "s", theme) for xy in S_]
    nm = iter(names or [])
    ids = [T.node(xy, r_, (themes or {}).get(q, theme), name=next(nm, None) if r_ == "N" else None) for q, (xy, r_) in enumerate(zip(P_, rl))]
    for e in es:
        if len(e) == 3:
            T.link(ids[e[0]], ids[e[1]], centre=W(*e[2]))
        else:
            T.link(ids[e[0]], ids[e[1]])
    cx = sum(T.pt(i)[0] for i in ids) / len(ids); cy = sum(T.pt(i)[1] for i in ids) / len(ids)
    T.clusters[T.cur]["mastery"] = (cx, cy)
    T.end()
    chain_ = [t] + stem_ids + [ids[j]]
    for x, y in zip(chain_, chain_[1:]):
        T.link(x, y)
    return stem_ids + ids
