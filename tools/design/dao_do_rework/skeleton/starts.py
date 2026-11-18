"""Start constellations: a unique, symmetric figure at every start (user 2026-11-15: "at the start node, there is
usually a very unique pattern in poe").

What PoE does (crops of all 13 class starts, 2026-11-15): the start is never bare. PoE 1 opens into a small emblem made
of the same parts as the rest of the tree, joined to the start by 2-4 short legs: Duelist's pentagram with a bowtie,
Witch's chalice of two lanes rising to a lens of two notables, Ranger's lens bead on a straight lane. PoE 2 opens into
two hub notables on short legs, joined by a lens with a notable on it, each hub fanning straight spokes out to its
pockets (Raw Power / Pure Energy, Battle-hardened / Remorseless). The figure is tight (first notables 3-5 steps away)
and symmetric about the start's axis, and long travel roads frame it.

Here each start gets its own figure, drawn in the start's frame (u to the right, v straight out from the centre), inside
the road emblem the A2 sketch put round it (the emblem is kept as the frame; small inner road rings are cleared first).
A motif is written as its right half plus the nodes on the axis and mirrored. Every motif is one cluster and must pass
the cluster rules (cluster_rules.py) like any other.

Motif format: nodes {name: (u, v, role)} with role "s" small / "N" notable; names ending in "R" are mirrored to "L".
Links (a, b, arc centre or None); "S" is the start. Ports (name, frame point): the node is joined to the road node
nearest that point (u, v) of the frame.
"""
import math

# the A2 sketch's road nodes close round a start, before the motif goes in: (radius, scale). Scale 0 clears them (Earth's
# inner diamond is decoration); otherwise they are pushed out from the start by that factor so the emblem stays as the
# motif's frame (Metal's blade star, Ice's six-point star, Wood's leaf; the leaf's veins on the axis are cleared).
RESHAPE = {"Earth start": (3.2, 0.0), "Metal start": (3.2, 1.5), "Ice start": (2.6, 1.15), "Wood start": (4.1, 1.25)}


def _petal(nodes, links, tag, ang, base, length, width, tip_role="N"):
    """A lens-shaped petal from distance base to base+length along direction ang (degrees from the axis)."""
    d = (math.sin(math.radians(ang)), math.cos(math.radians(ang)))
    n_ = (d[1], -d[0])
    b = (d[0] * base, d[1] * base)
    m = (d[0] * (base + length / 2), d[1] * (base + length / 2))
    t = (d[0] * (base + length), d[1] * (base + length))
    # the circle through b, t and the side points: centre on the normal through m
    h = length / 2
    k = (h * h - width * width) / (2 * width)          # centre offset from m along the normal (other side)
    nodes[tag + "b"] = (b[0], b[1], "s")
    nodes[tag + "t"] = (t[0], t[1], tip_role)
    for sgn, nm in ((1, "p"), (-1, "q")):
        nodes[tag + nm] = (m[0] + sgn * width * n_[0], m[1] + sgn * width * n_[1], "s")
        c = (m[0] - sgn * k * n_[0], m[1] - sgn * k * n_[1])
        links.append((tag + "b", tag + nm, c))
        links.append((tag + nm, tag + "t", c))


def motif_fire():
    """The flame: two legs curling up the sides to an apex notable, a straight inner tongue with the heart notable, and
    two side notables reaching the frame's lower corners."""
    N = {"AR": (0.85, 0.85, "s"), "BR": (1.55, 1.95, "s"), "CR": (1.0, 3.0, "s"), "T": (0.0, 3.45, "N"),
         "M1": (0.0, 1.25, "s"), "M2": (0.0, 2.3, "N"), "DR": (2.3, 0.3, "N")}
    L = [("S", "AR", None), ("AR", "BR", None), ("BR", "CR", None), ("CR", "T", None), ("S", "M1", None),
         ("M1", "M2", None), ("M2", "T", None), ("AR", "DR", None)]
    P = [("CR", (2.5, 3.4)), ("DR", (4.0, -1.3)), ("T", (0.0, 5.8)), ("S", (0.0, -4.2))]
    return N, L, P


def motif_earth():
    """Twin towers (PoE 2's twin hubs): short legs to two hub notables joined by a diamond with the keep notable on top,
    each hub fanning out to the frame; a gate below: a diamond on the way in."""
    N = {"AR": (0.95, 0.95, "s"), "HR": (1.9, 2.15, "N"), "P": (0.0, 2.0, "s"), "Q": (0.0, 3.15, "N"),
         "ER": (3.15, 1.4, "s"), "GR": (2.55, 3.4, "s"), "U": (0.0, 4.4, "s"),
         "W": (0.0, -1.2, "s"), "VR": (1.0, -2.2, "s"), "Z": (0.0, -3.2, "N")}
    L = [("S", "AR", None), ("AR", "HR", None), ("HR", "P", None), ("HR", "Q", None), ("HR", "ER", None),
         ("HR", "GR", None), ("Q", "U", None), ("S", "W", None), ("W", "VR", None), ("VR", "Z", None)]
    P = [("ER", (5.8, 0.0)), ("GR", (4.1, 4.1)), ("U", (0.0, 5.8)), ("Z", (0.0, -5.8)), ("VR", (4.1, -4.1))]
    return N, L, P


def motif_metal():
    """The trident: a shaft to a hub, three prongs with notables at their tips, a cross-guard of two notables, and a
    ring pommel below."""
    N = {"A": (0.0, 1.0, "s"), "H": (0.0, 2.0, "s"), "C1": (0.0, 3.2, "s"), "C2": (0.0, 4.35, "N"),
         "PR": (0.95, 2.6, "s"), "QR": (1.25, 3.5, "N"), "GR": (1.4, 1.55, "s"), "KR": (2.75, 1.15, "N"),
         "B": (0.0, -1.2, "s"), "RR": (1.15, -2.4, "s"), "O": (0.0, -3.6, "N")}
    L = [("S", "A", None), ("A", "H", None), ("H", "C1", None), ("C1", "C2", None), ("H", "PR", None),
         ("PR", "QR", None), ("A", "GR", None), ("GR", "KR", None), ("S", "B", None), ("B", "RR", (0.0, -2.4)),
         ("RR", "O", (0.0, -2.4))]
    P = [("C2", (0.0, 5.8)), ("KR", (5.8, 0.0)), ("O", (0.0, -5.8))]
    return N, L, P


def motif_water():
    """The lotus: three lens petals opening from the start, notables at their tips; a root below."""
    N, L = {}, []
    _petal(N, L, "c", 0.0, 0.95, 2.6, 0.8)
    side_n, side_l = {}, []
    _petal(side_n, side_l, "x", 74.0, 1.1, 2.2, 0.55)
    N.update({k + "R": v for k, v in side_n.items()})
    L += [(a + "R", b + "R", c) for a, b, c in side_l]
    N.update({"r1": (0.0, -1.2, "s"), "r2": (0.0, -2.4, "N")})
    L += [("S", "cb", None), ("S", "xbR", None), ("S", "r1", None), ("r1", "r2", None)]
    P = [("ct", (0.0, 5.8)), ("xtR", (4.6, 0.0)), ("r2", (0.0, -5.8))]
    return N, L, P


def motif_ice():
    """The snowflake: six arms, a hexagonal ring through them, a notable at every arm's tip touching the frame."""
    N, L = {}, []
    for a in (0, 60, 120, 180):
        tag = {0: "u", 60: "aR", 120: "bR", 180: "d"}[a]
        nm = (lambda k: "k" + str(k) + tag[:-1] + "R") if tag.endswith("R") else (lambda k: "k" + str(k) + tag)
        s_, c_ = math.sin(math.radians(a)), math.cos(math.radians(a))
        for k, r in ((1, 1.25), (2, 2.25), (3, 3.2)):
            N[nm(k)] = (r * s_, r * c_, "N" if k == 3 else "s")
        L += [("S", nm(1), None), (nm(1), nm(2), None), (nm(2), nm(3), None)]
    ring = ["k1u", "k1aR", "k1bR", "k1d"]
    for a, b in zip(ring, ring[1:]):
        L.append((a, b, (0.0, 0.0)))
    P = [("k3u", (0.0, 4.3)), ("k3aR", (3.7, 2.1)), ("k3bR", (3.7, -2.1)), ("k3d", (0.0, -4.3))]
    return N, L, P


def motif_wood():
    """The tree: a trunk with two tiers of branches ending in notable leaves, a crown on top, roots below."""
    N = {"t1": (0.0, 1.1, "s"), "t2": (0.0, 2.2, "s"), "t3": (0.0, 3.3, "s"), "top": (0.0, 4.4, "N"),
         "aR": (1.05, 1.7, "s"), "bR": (2.1, 2.2, "N"), "cR": (1.0, 2.95, "s"), "dR": (1.7, 3.85, "N"),
         "rR": (0.95, -0.9, "s"), "qR": (1.75, -1.85, "N"), "r1": (0.0, -1.25, "s"), "r2": (0.0, -2.5, "N")}
    L = [("S", "t1", None), ("t1", "t2", None), ("t2", "t3", None), ("t3", "top", None), ("t1", "aR", None),
         ("aR", "bR", None), ("t2", "cR", None), ("cR", "dR", None), ("S", "rR", None), ("rR", "qR", None),
         ("S", "r1", None), ("r1", "r2", None)]
    P = [("top", (0.0, 5.8)), ("r2", (0.0, -5.8)), ("bR", (3.1, 3.6))]
    return N, L, P


def motif_wind():
    """The gust (PoE 2's Flow Like Water): a hub notable fanning five straight spokes out to notables; a diamond below."""
    N = {"a": (0.0, 1.1, "s"), "H": (0.0, 2.2, "N")}
    L = [("S", "a", None), ("a", "H", None)]
    for ang, tag in ((0, ""), (36, "1R"), (72, "2R")):
        s_, c_ = math.sin(math.radians(ang)), math.cos(math.radians(ang))
        n1 = "m" + (tag[:-1] + "R" if tag else "0")
        n2 = "n" + (tag[:-1] + "R" if tag else "0")
        N[n1] = (1.3 * s_, 2.2 + 1.3 * c_, "s")
        N[n2] = (2.45 * s_, 2.2 + 2.45 * c_, "N")
        L += [("H", n1, None), (n1, n2, None)]
    N.update({"w": (0.0, -1.2, "s"), "vR": (0.85, -2.05, "s"), "z": (0.0, -2.9, "N")})
    L += [("S", "w", None), ("w", "vR", None), ("vR", "z", None)]
    P = [("n0", (0.0, 5.6)), ("n2R", (5.6, 0.0)), ("z", (0.0, -5.6))]
    return N, L, P


def motif_light():
    """The sun: a ring round the start on four spokes, eight rays, the cardinal ones long with notables at their ends."""
    N, L = {}, []
    names = {0: "u", 45: "aR", 90: "bR", 135: "cR", 180: "d"}
    for a, t in names.items():
        s_, c_ = math.sin(math.radians(a)), math.cos(math.radians(a))
        N["r" + t] = (2.0 * s_, 2.0 * c_, "s")
        if a % 90 == 0:
            N["x" + t] = (3.2 * s_, 3.2 * c_, "s")
            N["y" + t] = (4.4 * s_, 4.4 * c_, "N")
            L += [("S", "r" + t, None), ("r" + t, "x" + t, None), ("x" + t, "y" + t, None)]
        else:
            N["y" + t] = (3.35 * s_, 3.35 * c_, "N")
            L.append(("r" + t, "y" + t, None))
    ring = ["ru", "raR", "rbR", "rcR", "rd"]
    for a, b in zip(ring, ring[1:]):
        L.append((a, b, (0.0, 0.0)))
    P = [("yu", (0.0, 6.5)), ("ybR", (6.5, 0.0)), ("yd", (0.0, -6.5))]
    return N, L, P


def motif_thunder():
    """The crown: a band arching over the start on two legs, three spikes up from it with notables on their points
    (the middle one tall), a short stem down."""
    C = (0.0, -1.0)
    band = lambda a: (2.6 * math.sin(math.radians(a)), -1.0 + 2.6 * math.cos(math.radians(a)))
    N = {"b0": (*band(0), "s"), "b1R": (*band(20), "s"), "b2R": (*band(40), "s"),
         "c1": (0.0, 2.65, "s"), "c2": (0.0, 3.7, "N"), "sR": (2.15, 2.1, "N"),
         "d1": (0.0, -1.3, "s"), "d2": (0.0, -2.6, "N")}
    L = [("S", "b1R", None), ("b0", "b1R", C), ("b1R", "b2R", C), ("b0", "c1", None), ("c1", "c2", None),
         ("b2R", "sR", None), ("S", "d1", None), ("d1", "d2", None)]
    P = [("c2", (0.0, 6.0)), ("sR", (2.5, 3.5)), ("d2", (0.0, -4.3))]
    return N, L, P


def motif_darkness():
    """The crescent: two arcs meeting at notable horns, cupping the start from below; a short line up to the frame."""
    C0, r0 = (0.0, 0.4), 2.6
    N, L = {}, []
    outer = []
    for a in (100, 130, 155, 180):
        s_, c_ = math.sin(math.radians(a)), math.cos(math.radians(a))
        nm = "o%d" % a + ("R" if a != 180 else "")
        N[nm] = (C0[0] + r0 * s_, C0[1] + r0 * c_, "N" if a in (100, 180) else "s")
        outer.append(nm)
    for a, b in zip(outer, outer[1:]):
        L.append((a, b, C0))
    C1, r1 = (0.0, 2.22), 3.42
    inner = []
    for a in (160, 180):
        s_, c_ = math.sin(math.radians(a)), math.cos(math.radians(a))
        nm = "i%d" % a + ("R" if a != 180 else "")
        N[nm] = (C1[0] + r1 * s_, C1[1] + r1 * c_, "s")
        inner.append(nm)
    L += [("o100R", "i160R", C1), ("i160R", "i180", C1), ("S", "i180", None)]
    N.update({"a1": (0.0, 1.2, "s"), "a2": (0.0, 2.4, "N")})
    L += [("S", "a1", None), ("a1", "a2", None)]
    P = [("a2", (0.0, 5.7)), ("o180", (0.0, -5.7))]
    return N, L, P


def motif_chaos():
    """The pentagram: five notable points joined to the frame, the star's lines through an inner pentagon on five
    short legs from the start."""
    pol = lambda r, a: (r * math.sin(math.radians(a)), r * math.cos(math.radians(a)))
    N = {"p0": (*pol(2.95, 0), "N"), "p1R": (*pol(2.95, 72), "N"), "p2R": (*pol(2.95, 144), "N"),
         "i0R": (*pol(1.2, 36), "s"), "i1R": (*pol(1.2, 108), "s"), "i2": (*pol(1.2, 180), "s")}
    L = [("p0", "i0R", None), ("p1R", "i0R", None), ("p1R", "i1R", None), ("p2R", "i1R", None), ("p2R", "i2", None),
         ("S", "i0R", None), ("S", "i1R", None), ("S", "i2", None)]
    P = [("p0", (0.0, 4.2)), ("p1R", (4.0, 1.3)), ("p2R", (2.5, -3.4))]
    return N, L, P


MOTIFS = {"Chaos start": motif_chaos, "Fire start": motif_fire, "Earth start": motif_earth, "Metal start": motif_metal,
          "Water start": motif_water, "Ice start": motif_ice, "Wood start": motif_wood, "Wind start": motif_wind,
          "Light start": motif_light, "Thunder start": motif_thunder, "Darkness start": motif_darkness}


def expand(motif):
    """Mirror a half motif: returns nodes {name: (u, v, role)}, links [(a, b, centre)], ports [(name, (u, v))]."""
    N, L, P = motif()
    M = lambda nm: nm[:-1] + "L" if nm.endswith("R") else nm
    mp = lambda p: (-p[0], p[1])
    nodes = dict(N)
    for k, (u, v, r) in N.items():
        if k.endswith("R"):
            nodes[M(k)] = (-u, v, r)
    links = {}
    for a, b, c in L:
        for x, y, cc in ((a, b, c), (M(a), M(b), mp(c) if c else None)):
            key = tuple(sorted((x, y)))
            links[key] = (x, y, cc)
    ports = {}
    for nm, p in P:
        ports[nm] = p
        ports[M(nm)] = mp(p)
    return nodes, list(links.values()), list(ports.items())


def key_of(name):
    """'Fire start' from 'Fire start' or 'Ice start (Băng)'."""
    for k in MOTIFS:
        if name and name.startswith(k):
            return k
    return None


def draw(M, sid, region, theme, group_list_append=None):
    """Draw the start sid's motif into Mesh M (its inner rings already cleared and its own links not drawn).
    Returns the new group's node ids, or None when the start has no motif."""
    import mesh as B
    st = M.nodes[sid]
    k = key_of(st.get("name"))
    if not k:
        return None
    x0, y0 = st["x"], st["y"]
    r0 = math.hypot(x0, y0)
    ax = math.degrees(math.atan2(x0, y0)) if r0 > 1 else 0.0
    t = math.radians(ax)
    W = lambda u, v: (x0 + u * math.cos(t) + v * math.sin(t), y0 - u * math.sin(t) + v * math.cos(t))
    nodes, links, ports = expand(MOTIFS[k])
    gid = len(M.groups)
    ids = {"S": sid}
    for nm, (u, v, role) in nodes.items():
        ids[nm] = M.node(W(u, v), "notable" if role == "N" else "small", theme, gid, region=region)
    for a, b, c in links:
        M.link(ids[a], ids[b], centre=W(*c) if c else None)
    extra = []
    for nm, (u, v) in ports:
        p = W(u, v)
        cand = [j for j in M.near(p, 1.2) if M.nodes[j]["kind"] == "travel" and not M.nodes[j].get("dead")]
        if not cand:
            print("  no frame node for", k, nm)
            continue
        j = min(cand, key=lambda j: math.dist(M.pt(j), p))
        a_, q = M.pt(ids[nm]), M.pt(j)
        L = math.dist(a_, q)
        if nm in nodes and nodes[nm][2] == "N" and L >= 1.7:      # a road never lands on a notable: a small node between (PoE: 2-6 %)
            tt = min(1.0, L / 2) / L
            mid = M.node((a_[0] + (q[0] - a_[0]) * tt, a_[1] + (q[1] - a_[1]) * tt), "small", theme, gid, region=region)
            extra.append(mid)
            M.link(ids[nm], mid); M.link(mid, j)
        else:
            M.link(ids[nm], j)
    M.groups.append({"shape": "start:" + k, "centre": (x0, y0), "facing": ax,
                     "nodes": [ids[nm] for nm in nodes] + extra, "region": region})
    return [ids[nm] for nm in nodes] + extra


def W_of(M, sid):
    st = M.nodes[sid]
    x0, y0 = st["x"], st["y"]
    r0 = math.hypot(x0, y0)
    ax = math.degrees(math.atan2(x0, y0)) if r0 > 1 else 0.0
    t = math.radians(ax)
    return lambda u, v: (x0 + u * math.cos(t) + v * math.sin(t), y0 - u * math.sin(t) + v * math.cos(t))


def W_of_xy(x0, y0):
    r0 = math.hypot(x0, y0)
    t = math.radians(math.degrees(math.atan2(x0, y0)) if r0 > 1 else 0.0)
    return lambda u, v: (x0 + u * math.cos(t) + v * math.sin(t), y0 - u * math.sin(t) + v * math.cos(t))


def local_of_xy(x0, y0, p):
    r0 = math.hypot(x0, y0)
    t = math.radians(math.degrees(math.atan2(x0, y0)) if r0 > 1 else 0.0)
    dx, dy = p[0] - x0, p[1] - y0
    return (dx * math.cos(t) - dy * math.sin(t), dx * math.sin(t) + dy * math.cos(t))


def check(k):
    """Geometry problems of one motif in its own frame: nodes closer than 0.72, straight links crossing, a node closer
    than 0.3 to a straight link it is not on."""
    nodes, links, ports = expand(MOTIFS[k])
    P = {nm: (u, v) for nm, (u, v, _) in nodes.items()}
    P["S"] = (0.0, 0.0)
    out = []
    names = sorted(P)
    for i, a in enumerate(names):
        for b in names[i + 1:]:
            if math.dist(P[a], P[b]) < 0.72:
                out.append("close %s %s %.2f" % (a, b, math.dist(P[a], P[b])))
    def poly(a, b, c):
        if not c:
            return [P[a], P[b]]
        pa, pb = P[a], P[b]
        r = math.dist(pa, c)
        t1 = math.atan2(pa[1] - c[1], pa[0] - c[0]); t2 = math.atan2(pb[1] - c[1], pb[0] - c[0])
        dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        n = max(2, int(abs(dt) * r / 0.2))
        return [(c[0] + r * math.cos(t1 + dt * j / n), c[1] + r * math.sin(t1 + dt * j / n)) for j in range(n + 1)]
    for i, (a, b, c) in enumerate(links):       # arcs sampled: no two links may cross
        pa_ = poly(a, b, c)
        for a2, b2, c2 in links[i + 1:]:
            if {a, b} & {a2, b2}:
                continue
            pb_ = poly(a2, b2, c2)
            hit = False
            for p1, p2 in zip(pa_, pa_[1:]):
                for p3, p4 in zip(pb_, pb_[1:]):
                    if ((p2[0] - p1[0]) * (p3[1] - p1[1]) - (p2[1] - p1[1]) * (p3[0] - p1[0])) * ((p2[0] - p1[0]) * (p4[1] - p1[1]) - (p2[1] - p1[1]) * (p4[0] - p1[0])) < 0 and                        ((p4[0] - p3[0]) * (p1[1] - p3[1]) - (p4[1] - p3[1]) * (p1[0] - p3[0])) * ((p4[0] - p3[0]) * (p2[1] - p3[1]) - (p4[1] - p3[1]) * (p2[0] - p3[0])) < 0:
                        hit = True
            if hit:
                out.append("cross(arc) %s-%s %s-%s" % (a, b, a2, b2))
    segs = [(a, b) for a, b, c in links if not c]
    o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    for i, (a, b) in enumerate(segs):
        for c, d in segs[i + 1:]:
            if {a, b} & {c, d}:
                continue
            p1, p2, p3, p4 = P[a], P[b], P[c], P[d]
            if o(p1, p2, p3) * o(p1, p2, p4) < 0 and o(p3, p4, p1) * o(p3, p4, p2) < 0:
                out.append("cross %s-%s %s-%s" % (a, b, c, d))
        for n in names:
            if n in (a, b):
                continue
            p, q, r = P[a], P[b], P[n]
            dx, dy = q[0] - p[0], q[1] - p[1]; L = dx * dx + dy * dy
            t = max(0.0, min(1.0, ((r[0] - p[0]) * dx + (r[1] - p[1]) * dy) / L))
            if math.dist(r, (p[0] + t * dx, p[1] + t * dy)) < 0.3:
                out.append("on-link %s %s-%s" % (n, a, b))
    return out


if __name__ == "__main__":
    for k in MOTIFS:
        print(k, check(k) or "ok")
