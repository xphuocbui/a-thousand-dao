"""Hand-authored Đạo Đồ: a layout file compiled into the map, no generator (user 2026-11-16: "this feels too
generated ... could you derive a system where you could hand author the tree"; chose "I author, you review" and
"clean, from the roads").

The base is what was already designed by hand: the A2 road sketch, the start constellations (starts.py) and the drawn
emblems (emblems.py). Everything else comes from the layout file, applied in order, and nothing appears that is not in
it. Each entry is written in its land's own frame: u to the right, v out along the land's axis from the map's centre (so
v is the distance from the centre: starts at 27, emblems at 48 and 69.5, the rim at 84); a disc's frame (Chaos, the
islands, the shrine) is centred on the disc. Facing is in degrees off the axis (0 = straight out, + toward +u).

Layout file (JSON): {"fire": [entry, ...], "earth": [...], ...}. Entries:
  {"road": [[u, v], ...], "mirror": true}               travel nodes and straight links; a point within 0.45 of a node
                                                       drawn already joins it
  {"piece": "Rose", "at": [u, v], "facing": 30, "spoke": 1.6, "mirror": true}
                                                       an authored shape hung on the road node at (u, v)
  {"pattern": "Twin lenses", "at": [u, v], "facing": 0, "mirror": false}
                                                       a 2-3-cluster pattern round a new hub 2.0 out from the node
  {"keystone": [u, v], "facing": 20, "mirror": true}   a keystone 2.2 out from the node at (u, v)
  {"spokes": [u, v], "to": [[u, v], ...]}                 a road hub with straight spokes out to each point
  {"arc": [cu, cv], "r": 6, "from": -40, "to": 40, "n": 4}  a curved road: nodes round the circle (angles off the axis)
  {"row": [piece, ...], "on": [[u, v], ...], "side": 1, "lean": 0, "name": ""}   a combo: pieces off consecutive
                                                       road nodes, one side of the road
  {"fan": [piece, ...], "at": [u, v], "facing": 0, "spread": 45}   a combo: pieces off one road node, side by side
  {"facing": [piece, piece], "from": [[u, v], [u, v]], "tilt": 0}   a combo: two pieces grown toward each other
  {"bridge": 6, "from": [u, v], "to": [u, v]}            a through cluster of that size joining two road nodes (the
                                                       road runs through it); or a through shape's name
  {"join": [[u, v], [u, v]]}                             a straight link between the nodes nearest the two points
                                                       (weave, 2026-11-17); written by authoring/weave.py
"mirror": true also places the entry's twin at (-u, v) facing -facing (skipped when it would land on itself).
Every entry that does not fit is reported with its reason; nothing is skipped silently.

Usage: python -I tools/design/dao_do_rework/skeleton/layout.py <layout.json> [more layout.json ...] <out map.json>
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
_argv = sys.argv
sys.argv = [sys.argv[0]]
import mapgen as G  # noqa: E402
sys.argv = _argv
B, S = G.B, G.S

SNAP = 0.45
# ring radii of the ring grid: PoE's orbit radii (0, 82, 162, 251, 335, 493, 662) scaled so its median neighbour
# distance (173) is our 1.2
RINGS = [round(r * 1.2 / 173.0, 3) for r in (0, 82, 162, 251, 335, 493, 662)]
# experiments (2026-11-17, user: "please just try all"), off unless asked for on the command line:
#   --beads  small path nodes along long road links, so roads read as chains of nodes like the clusters
#   --orbit  figures snapped onto PoE-ratio circles and slots (orbit.py), turned only in 30-degree steps from the
#            region's axis, so every figure in a region shares one angle lattice
BEADS = False
ORBIT = False
STRICT = False      # --strict (hand authoring, 2026-11-17): combo pieces are drawn only at the written angle and link
                    # length ("spokes": [per piece], default 1.6); a misfit is reported, never nudged
TILT_COMBOS = 20.0  # combo pieces turn this many degrees off their road link (fans outward, rows alternate); decided
                    # 2026-11-17 (user: "the tilt works well"); --no-tilt draws them straight as before
BEAD_STEP, BEAD_MIN = 1.7, 3.0
ORBIT_STATS = {"snapped": 0, "turned only": 0, "as drawn": 0}


def base():
    """The hand-designed base: the A2 sketch, the start constellations, the drawn emblems. Returns (M, frames)."""
    import sketch_a2
    import starts
    g0, _ = sketch_a2.variant_a2()
    M = B.Mesh()
    m = {}
    st0 = [n for n in g0.nodes if n["kind"] == "start"]

    def reshape(n):
        for s_ in st0:
            if n is s_:
                continue
            rad, k = starts.RESHAPE.get(starts.key_of(s_.get("name")), (0.0, 0.0))
            if math.dist((n["x"], n["y"]), (s_["x"], s_["y"])) < rad:
                W = starts.W_of_xy(s_["x"], s_["y"])
                u, v = starts.local_of_xy(s_["x"], s_["y"], (n["x"], n["y"]))
                if k == 0.0 or abs(u) < 0.05:
                    return None
                return W(u * k, v * k)
        return (n["x"], n["y"])
    for n in g0.nodes:
        q = reshape(n) if n["kind"] in ("travel", "start") else None
        if q:
            m[n["id"]] = M.node(q, n["kind"], region=n["region"])
            M.nodes[-1]["name"] = n.get("name")
            M.nodes[-1]["sk"] = True
    sids = {n["id"] for n in st0 if starts.key_of(n.get("name"))}
    for e in g0.edges:
        if e["a"] in m and e["b"] in m and not (e["a"] in sids or e["b"] in sids):
            M.link(m[e["a"]], m[e["b"]], centre=tuple(e["arc"]) if e.get("arc") else None)
    for n in st0:
        if n["id"] in sids:
            starts.draw(M, m[n["id"]], n["region"], G.START_THEME.get(n["region"], n["region"]))
    regions = {name: G.Region(M, name, ax) for name, ax in list(S.LANDS.items()) + list(S.BLENDS.items())}
    for R_ in regions.values():
        R_.emblem_designed()
    for e in M.edges:
        e.setdefault("ph", "base")
    frames = {name: (0.0, 0.0, R_.ax, R_) for name, R_ in regions.items()}
    for name, C, ax in (("hub", (0.0, 0.0), 0.0), ("light", S.pol(S.RIM + 28.0, 0.0), 0.0), ("thunder", S.pol(S.RIM + 25.0, 252.0), 252.0),
                        ("darkness", S.pol(S.RIM + 25.0, 180.0), 180.0), ("shrine", (107.81, -24.89), 103.0)):
        frames[name] = (C[0], C[1], ax, None)
    return M, frames


def _road(M, fr, ent, sg, tag, W, snap, log, land):
    """Travel nodes along ent["road"] (land-frame points; a point within SNAP of a node joins it) and links between
    them, straight or round ent["centre"]."""
    pts = [(sg * u, v) for u, v in ent["road"]]
    if sg < 0 and all(abs(u) < 1e-6 for u, _ in pts):
        return
    cen = ent.get("centre")
    cw = W(fr, sg * cen[0], cen[1]) if cen else None
    ids = []
    for u, v in pts:
        p = W(fr, u, v)
        j = snap(p, ("travel", "small", "start"))
        if j is None:
            if any(True for _ in M.near(p, B.SPACING)):
                log.append(tag + ": road point (%.1f, %.1f) too close to a node" % (u, v))
            else:
                j = M.node(p, "travel", region=land)
        ids.append(j)
    for a, b in zip(ids, ids[1:]):
        if a is None or b is None or b in M.adj[a]:
            continue
        seg = B.Mesh._poly_of(M.pt(a), M.pt(b), cw) if cw else [M.pt(a), M.pt(b)]
        if M.fits([], list(zip(seg, seg[1:])), [a, b]):
            M.link(a, b, centre=cw)
        else:
            log.append(tag + ": road link crosses something, left out")


def _centre_for(ex, g, n0):
    """The figure's centre that puts its first node n0 = (u, v, role) at ex when the figure faces g (any first node,
    on its axis or not: hand-drawn curls are entered at one end)."""
    u0, v0 = n0[0], n0[1]
    t = math.radians(g)
    return (ex[0] - (u0 * math.cos(t) + v0 * math.sin(t)), ex[1] - (-u0 * math.sin(t) + v0 * math.cos(t)))


def _try_piece(M, a, name, f, region, theme, spokes=(1.6, 1.2, 2.0, 2.4), turns=(0, 10, -10, 20, -20), tilt=0.0, spoke=None, turn=0.0, bend=0.0):
    """Place piece `name` off road node a facing f (world degrees), trying the given spokes and small turns.
    With tilt, the figure first tries turning that many degrees off its road link (entry node kept on the link).
    Returns (group index, facing used) or None."""
    Sh = G.AUTH[name]
    e0 = -Sh.nodes[0][1]
    p = M.pt(a)
    if STRICT:
        spokes, turns = ((spoke or 1.6),), (0,)
        lm = B.LINK_MAX
        B.LINK_MAX = max(lm, spokes[0] + 0.01)
        try:
            ff = f + turn; g = ff + tilt; sp = spokes[0]
            ex = (p[0] + sp * math.sin(math.radians(ff)), p[1] + sp * math.cos(math.radians(ff)))
            c = _centre_for(ex, g, Sh.nodes[0])
            if B.place_xy(M, name, Sh.nodes, Sh.links, c, g, [(a, 0, bend)], theme(c), lambda x, y: True, region):
                return len(M.groups) - 1, g
            return None
        finally:
            B.LINK_MAX = lm
    if tilt:
        for df in turns:
            for sp in spokes:
                ff = f + df; g = ff + tilt
                ex = (p[0] + sp * math.sin(math.radians(ff)), p[1] + sp * math.cos(math.radians(ff)))
                c = _centre_for(ex, g, Sh.nodes[0])
                if B.place_xy(M, name, Sh.nodes, Sh.links, c, g, [(a, 0)], theme(c), lambda x, y: True, region):
                    M.groups[-1]["nudge"] = [df, sp]
                    return len(M.groups) - 1, g
    for df in turns:
        for sp in spokes:
            ff = f + df
            c = (p[0] + (e0 + sp) * math.sin(math.radians(ff)), p[1] + (e0 + sp) * math.cos(math.radians(ff)))
            if B.place_xy(M, name, Sh.nodes, Sh.links, c, ff, [(a, 0)], theme(c), lambda x, y: True, region):
                M.groups[-1]["nudge"] = [df, sp]     # what the non-strict compile picked (read when hand-fixing)
                return len(M.groups) - 1, ff
    return None


def _combo(M, fr, ent, sg, tag, W, snap, log, land, theme):
    """Combos (user 2026-11-16: "combo is what gives the graph its soul"; PoE 2: of clusters sitting close, 57 % grow
    side by side, 26 % splay, 18 % face each other; 79 % share a road node or sit on neighbouring ones):
      row    pieces off consecutive road nodes `on`, all to one side of the road (side 1 = right of the way from the
             first node to the last, -1 = left), each `lean` degrees off square to the road
      fan    pieces off one road node `at`, centred on `facing`, `spread` degrees apart
      facing two pieces off road nodes `from` [a, b], each grown toward the other so they meet in between"""
    ax = fr[2]
    loc = lambda q: snap(W(fr, sg * q[0], q[1]), radius=0.9)
    name = ent.get("name", "")
    placed = []
    if "row" in ent:
        on = [loc(q) for q in ent["on"]]
        if None in on:
            log.append(tag + ": row %s has a point with no road node" % name); return
        pts = [M.pt(a) for a in on]
        side = ent.get("side", 1) * sg
        for k, (nm, a) in enumerate(zip(ent["row"], on)):
            if nm is None:
                continue
            p0 = pts[max(0, k - 1)]; p1 = pts[min(len(pts) - 1, k + 1)]
            road = math.degrees(math.atan2(p1[0] - p0[0], p1[1] - p0[1]))
            f = road + 90 * side + sg * ent.get("lean", 0) * side
            tl = sg * ent["tilts"][k] if "tilts" in ent else TILT_COMBOS * (1 if k % 2 == 0 else -1) * sg
            got = _try_piece(M, a, nm, f, land, theme, tilt=tl, spoke=(ent.get("lengths") or [None] * 99)[k], turn=sg * (ent.get("turns") or [0] * 99)[k], bend=sg * (ent.get("bends") or [0] * 99)[k])
            placed.append((nm, got, f))
    elif "fan" in ent:
        a = loc(ent["at"])
        if a is None:
            log.append(tag + ": fan %s has no road node" % name); return
        n = len(ent["fan"]); sp = ent.get("spread", 45)
        for k, nm in enumerate(ent["fan"]):
            f = ax + sg * (ent.get("facing", 0) + (k - (n - 1) / 2) * sp)
            off = k - (n - 1) / 2
            tl = sg * ent["tilts"][k] if "tilts" in ent else TILT_COMBOS * sg * (1 if off > 0 or n == 1 else -1 if off < 0 else 0)
            placed.append((nm, _try_piece(M, a, nm, f, land, theme, turns=(0, 5, -5, 10, -10), tilt=tl, spoke=(ent.get("lengths") or [None] * 99)[k], turn=sg * (ent.get("turns") or [0] * 99)[k], bend=sg * (ent.get("bends") or [0] * 99)[k]), f))
    else:
        a, b = (loc(q) for q in ent["from"])
        if a is None or b is None:
            log.append(tag + ": facing %s has a point with no road node" % name); return
        pa, pb = M.pt(a), M.pt(b)
        fab = math.degrees(math.atan2(pb[0] - pa[0], pb[1] - pa[1]))
        tilt = sg * ent.get("tilt", 0)
        if ent["facing"][0]:
            placed.append((ent["facing"][0], _try_piece(M, a, ent["facing"][0], fab + tilt, land, theme, spoke=(ent.get("lengths") or [None, None])[0], turn=sg * (ent.get("turns") or [0, 0])[0], tilt=sg * (ent.get("tilts") or [0, 0])[0], bend=sg * (ent.get("bends") or [0, 0])[0]), fab))
        if ent["facing"][1]:
            placed.append((ent["facing"][1], _try_piece(M, b, ent["facing"][1], fab + 180 + tilt, land, theme, spoke=(ent.get("lengths") or [None, None])[1], turn=sg * (ent.get("turns") or [0, 0])[1], tilt=sg * (ent.get("tilts") or [0, 0])[1], bend=sg * (ent.get("bends") or [0, 0])[1]), fab + 180))
    for nm, got, f in placed:
        if got is None:
            log.append(tag + ": %s %s: %s does not fit" % (("row" if "row" in ent else "fan" if "fan" in ent else "facing"), name, nm))
        else:
            M.groups[got[0]]["combo"] = tag + " " + name


def compile_layout(layout, M, frames, log):
    def W(fr, u, v):
        cx, cy, ax, _ = fr
        w = S.to_world(ax, u, v)
        return (cx + w[0], cy + w[1])

    def snap(p, kinds=("travel",), radius=SNAP):
        c = [j for j in M.near(p, radius) if M.nodes[j]["kind"] in kinds]
        return min(c, key=lambda j: math.dist(M.pt(j), p)) if c else None

    # v2 (review 2026-11-17): {"library": "lean"} anywhere switches the whole map to the lean notable library (lean.py)
    if any(e.get("library") == "lean" for ents in layout.values() for e in ents) and not getattr(G, "LEAN", False):
        import lean
        lean.install(G)
    deferred = []
    # custom shapes (hand authoring, 2026-11-17, user: "you could think of a shape that would fit there on the spot"):
    # {"shape": name, "nodes": [[u, v, "s"|"N"], ...], "links": [[i, j], [i, j, [cu, cv]], ...]}, drawn in the same
    # frame as the library (entry = node 0 at the bottom on the axis); checked with authored.check
    for land_, ents_ in layout.items():
        for e_ in ents_:
            if "shape" in e_ and "orbit" in e_:
                # a figure on the ring grid (2026-11-17, PoE's construction: nodes on fixed rings round the figure's
                # centre at fixed angle slots; links along one ring are arcs of it, links between rings straight):
                # {"shape": name, "orbit": [[ring, angle, "s"|"N"], ...], "links": [[i, j], ...]}
                Sh_ = G.authored.Shape(e_["shape"])
                pol_ = [(RINGS[r_], a_, role_) for r_, a_, role_ in e_["orbit"]]
                Sh_.nodes = [(round(rr * math.sin(math.radians(a_)), 4), round(rr * math.cos(math.radians(a_)), 4), role_) for rr, a_, role_ in pol_]
                Sh_.links = [(i_, j_, (0.0, 0.0) if e_["orbit"][i_][0] == e_["orbit"][j_][0] and e_["orbit"][i_][0] > 0 else None)
                             for i_, j_ in e_["links"]]
                G.AUTH[e_["shape"]] = Sh_
                continue
            if "shape" in e_ and "nodes" in e_:
                Sh_ = G.authored.Shape(e_["shape"])
                Sh_.nodes = [(float(u), float(v), r) for u, v, r in e_["nodes"]]
                Sh_.links = [(l_[0], l_[1], tuple(l_[2]) if len(l_) > 2 and l_[2] else None) for l_ in e_["links"]]
                probs = [q for q in G.authored.check(Sh_) if not q.startswith(("notables", "entry not at", "R1"))]
                if probs:
                    log.append("%s: custom shape %s: %s" % (land_, e_["shape"], "; ".join(probs[:4])))
                G.AUTH[e_["shape"]] = Sh_
    if ORBIT:
        _orbit_install(frames)
    global STRICT
    strict_all = STRICT
    for land, entries in layout.items():
        if land not in frames:
            continue        # e.g. "shapes": hand-drawn figures only, registered above
        STRICT = strict_all or any(e.get("strict") for e in entries)     # a hand-authored region opts in
        fr = frames[land]
        R_ = fr[3]
        theme = (lambda p: R_.theme(p)) if R_ else (lambda p: land)
        for k, ent in enumerate(entries):
            if set(ent) <= {"note", "library", "strict"} or ("shape" in ent and ("nodes" in ent or "orbit" in ent)):
                continue        # a comment line, the library switch, or a custom shape (registered above)
            twins = [1] + ([-1] if ent.get("mirror") else [])
            for sg in twins:
                tag = "%s #%d%s" % (land, k, " (mirror)" if sg < 0 else "")
                if "spokes" in ent:
                    ent = {"road_multi": [[ent["spokes"], q] for q in ent["to"]], "mirror": ent.get("mirror")}
                if "road_multi" in ent:
                    for seg in ent["road_multi"]:
                        sub = {"road": seg}
                        _road(M, fr, sub, sg, tag, W, snap, log, land)
                    continue
                if "arc" in ent:
                    cu, cv = ent["arc"]
                    a0, a1, n_ = ent["from"], ent["to"], ent.get("n", 4)
                    pts = [(cu + ent["r"] * math.sin(math.radians(a0 + (a1 - a0) * k_ / n_)),
                            cv + ent["r"] * math.cos(math.radians(a0 + (a1 - a0) * k_ / n_))) for k_ in range(n_ + 1)]
                    _road(M, fr, {"road": pts, "centre": (cu, cv)}, sg, tag, W, snap, log, land)
                    continue
                if "bridge" in ent:
                    pa_l, pb_l = ent["from"], ent["to"]
                    a = snap(W(fr, sg * pa_l[0], pa_l[1]), radius=0.9); b = snap(W(fr, sg * pb_l[0], pb_l[1]), radius=0.9)
                    if a is None or b is None:
                        log.append(tag + ": bridge end has no road node"); continue
                    pa, pb = M.pt(a), M.pt(b)
                    d = math.dist(pa, pb)
                    f = B.ang_of(pa, pb)
                    want = ent["bridge"]
                    names = sorted(n for n in G.THROUGH if (G.THROUGH_N[n] == want if isinstance(want, int) else n == want))
                    done = False
                    for nm in names:
                        sh, k_ = G.THROUGH[nm]
                        span = B.R[sh[0][0][0]] + B.R[sh[0][k_][0]]
                        if not (2.0 <= d - span <= 6.0):
                            continue
                        off = B.R[sh[0][0][0]] + (d - span) / 2
                        c = (pa[0] + (pb[0] - pa[0]) / d * off, pa[1] + (pb[1] - pa[1]) / d * off)
                        if M.place(nm, sh, c, f, [(a, 0), (b, k_)], theme(c), lambda x, y: True):
                            M.groups[-1]["region"] = land
                            done = True
                            break
                    if not done:
                        log.append(tag + ": no %s-node bridge fits between (%.1f, %.1f) and (%.1f, %.1f)" % (want, sg * pa_l[0], pa_l[1], sg * pb_l[0], pb_l[1]))
                    continue
                if "road" in ent:
                    _road(M, fr, ent, sg, tag, W, snap, log, land)
                    continue
                if "join" in ent:
                    deferred.append((fr, ent, sg, tag))     # joins run after every region is drawn (they may reach
                    continue                                # a road or cluster of a later region)
                if "group" in ent:
                    # a figure placed by its centre (ring-grid authoring): {"group": name, "centre": [u, v],
                    # "rot": deg (15-degree steps from the region's axis), "joins": [[node index, [u, v] road node], ...]}
                    Sh = G.AUTH[ent["group"]]
                    cu, cv = ent["centre"]
                    c = W(fr, sg * cu, cv)
                    f = fr[2] + sg * ent.get("rot", 0.0)
                    nodes = Sh.nodes if sg > 0 else [(-u_, v_, r_) for u_, v_, r_ in Sh.nodes]
                    links = Sh.links if sg > 0 else [(i_, j_, (-cc[0], cc[1]) if cc else None) for i_, j_, cc in Sh.links]
                    js = []
                    for k_, (ju, jv) in ent.get("joins", []):
                        a_ = snap(W(fr, sg * ju, jv), ("travel", "small", "notable"), radius=0.6)
                        if a_ is None:
                            log.append(tag + ": group %s: join point (%.1f, %.1f) has no node" % (ent["group"], sg * ju, jv)); break
                        js.append((a_, k_))
                    else:
                        lm = B.LINK_MAX
                        B.LINK_MAX = 3.0
                        got = B.place_xy(M, ent["group"], nodes, links, c, f, js, theme(c), lambda x, y: True, land)
                        B.LINK_MAX = lm
                        if not got:
                            log.append(tag + ": group %s does not fit at (%.1f, %.1f) rot %g" % (ent["group"], sg * cu, cv, ent.get("rot", 0)))
                    continue
                if "row" in ent or "fan" in ent or isinstance(ent.get("facing"), list):
                    _combo(M, fr, ent, sg, tag, W, snap, log, land, theme)
                    continue
                u, v = ent.get("at") or ent.get("keystone")
                u *= sg
                if sg < 0 and abs(u) < 1e-6 and abs(ent.get("facing", 0)) < 1e-6:
                    continue
                # anchors: the nearest road node within 0.9; a "host" piece (fill.py --dense) hangs off a cluster node
                a = snap(W(fr, u, v), ("travel", "small", "notable") if ent.get("host") else ("travel",), radius=0.9 if not ent.get("host") else 0.3)
                if a is None:
                    log.append(tag + ": no road node at (%.1f, %.1f)" % (u, v)); continue
                f = fr[2] + sg * ent.get("facing", 0.0)
                p = M.pt(a)
                region = land if R_ else land
                if "piece" in ent:
                    Sh = G.AUTH[ent["piece"]]
                    e0 = -Sh.nodes[0][1]
                    sp_ = ent.get("spoke", 1.6)
                    # "tilt" (experiment 2026-11-17): the figure turns this many degrees off the line of its road link,
                    # still joined at its entry node (PoE 1: median 20 degrees off; ours were all 0)
                    g_ = f + sg * ent.get("tilt", 0.0)
                    ex = (p[0] + sp_ * math.sin(math.radians(f)), p[1] + sp_ * math.cos(math.radians(f)))
                    c = _centre_for(ex, g_, Sh.nodes[0])
                    lm = B.LINK_MAX
                    B.LINK_MAX = max(lm, sp_ + 0.01)
                    got = B.place_xy(M, ent["piece"], Sh.nodes, Sh.links, c, g_, [(a, 0, sg * ent.get("bend", 0.0))], theme(c), lambda x, y: True, region)
                    B.LINK_MAX = lm
                    if not got:
                        log.append(tag + ": %s does not fit at (%.1f, %.1f) facing %g" % (ent["piece"], u, v, sg * ent.get("facing", 0)))
                    else:
                        M.groups[-1]["src"] = (land, k, sg)     # which layout entry drew it (weave.py; dropped on output)
                elif "pattern" in ent:
                    comps = dict((n, c) for n, c in G.authored.COMPOUNDS + G.authored.COMPOUNDS_SMALL + G.authored.COMBOS_MORE)[ent["pattern"]]
                    if not G.place_compound(M, a, f, comps, lambda x, y: True, region, theme(p)):
                        log.append(tag + ": pattern %s does not fit at (%.1f, %.1f)" % (ent["pattern"], u, v))
                elif "keystone" in ent:
                    q = (p[0] + 2.2 * math.sin(math.radians(f)), p[1] + 2.2 * math.cos(math.radians(f)))
                    if any(True for _ in M.near(q, 1.5)) or not M.fits([q], [(p, q)], [a]):
                        log.append(tag + ": keystone does not fit"); continue
                    gid = len(M.groups)
                    kid = M.node(q, "keystone", "keystone", gid, region=region)
                    M.link(a, kid)
                    M.groups.append({"shape": "keystone", "centre": q, "facing": f, "nodes": [kid], "region": region})

    STRICT = strict_all
    # weave (2026-11-17, user: the tree "feels disconnected"): one straight link between the nodes nearest the two
    # points, a cluster's tip and the next road node or a facing cluster's tip
    for fr, ent, sg, tag in deferred:
        (u1, v1), (u2, v2) = ent["join"]
        kinds = ("travel", "small", "notable")
        a = snap(W(fr, sg * u1, v1), kinds); b = snap(W(fr, sg * u2, v2), kinds)
        if a is None or b is None or a == b:
            log.append(tag + ": join end has no node"); continue
        if b in M.adj[a]:
            continue
        if not M.fits([], [(M.pt(a), M.pt(b))], [a, b]):
            log.append(tag + ": join (%.1f, %.1f)-(%.1f, %.1f) crosses something" % (sg * u1, v1, sg * u2, v2)); continue
        M.link(a, b)
        M.edges[-1]["ph"] = "join"
    if BEADS:
        beads(M, log)


def beads(M, log):
    """--beads: small path nodes along every road link of BEAD_MIN or more, about BEAD_STEP apart, as many as fit."""
    roads = [k for k, e in enumerate(M.edges) if not e.get("dead") and M.nodes[e["a"]]["kind"] in ("travel", "start")
             and M.nodes[e["b"]]["kind"] in ("travel", "start")]
    added = 0
    for k in roads:
        e = M.edges[k]
        a, b = e["a"], e["b"]
        pl = M.poly[k]
        segl = [math.dist(p, q) for p, q in zip(pl, pl[1:])]
        L_ = sum(segl)
        if L_ < BEAD_MIN:
            continue

        def at(t):
            d = t * L_
            for (p, q), s_ in zip(zip(pl, pl[1:]), segl):
                if d <= s_ or s_ == segl[-1] and (p, q) == (pl[-2], pl[-1]):
                    f = d / s_ if s_ else 0
                    return (p[0] + (q[0] - p[0]) * f, p[1] + (q[1] - p[1]) * f)
                d -= s_
            return pl[-1]
        e["dead"] = True
        M.deg[a] -= 1; M.deg[b] -= 1; M.adj[a].discard(b); M.adj[b].discard(a)
        done = False
        for n in range(int(L_ / BEAD_STEP), 0, -1):
            pts = [at(j / (n + 1)) for j in range(1, n + 1)]
            if M.fits(pts, [], [a, b]):
                centre = tuple(e["arc"]) if e.get("arc") else None
                ids = [M.node(p, "small", "path", None, region=M.nodes[a].get("region")) for p in pts]
                for i in ids:
                    M.nodes[i]["bead"] = True
                chain = [a] + ids + [b]
                for x, y in zip(chain, chain[1:]):
                    M.link(x, y, centre=centre)
                    M.edges[-1]["ph"] = e.get("ph") or "bead"
                added += n
                done = True
                break
        if not done:
            e["dead"] = False
            M.deg[a] += 1; M.deg[b] += 1; M.adj[a].add(b); M.adj[b].add(a)
    BEAD_COUNT[0] = added


BEAD_COUNT = [0]


def _orbit_install(frames):
    """--orbit: wrap mesh.place_xy so every figure is placed snapped (orbit.py) and turned in 30-degree steps from its
    region's axis; a figure that does not fit that way is tried as drawn on the lattice, then as drawn."""
    import orbit
    if getattr(B, "_place_raw", None):
        return
    snapped = orbit.library(G.AUTH)
    axes = {name: fr[2] for name, fr in frames.items()}
    raw = B._place_raw = B.place_xy

    def place(M, name, nodes, links, c, facing, joins, theme, inside, region):
        ax = axes.get(region, 0.0)
        base = ax + round((facing - ax) / orbit.TURN) * orbit.TURN
        tries = sorted({base, base + orbit.TURN, base - orbit.TURN}, key=lambda f: abs((f - facing + 180) % 360 - 180))
        pa = M.pt(joins[0][0]) if joins else None
        e_old = -nodes[0][1]
        for S_, tag in ((snapped.get(name), "snapped"), (None, "turned only")):
            nn, ll = (S_.nodes, S_.links) if S_ else (nodes, links)
            e_new = -nn[0][1]
            for f in tries:
                if pa is not None:
                    d = math.dist(c, pa) - e_old + e_new
                    cc = (pa[0] + d * math.sin(math.radians(f)), pa[1] + d * math.cos(math.radians(f)))
                else:
                    cc = c
                r = raw(M, name, nn, ll, cc, f, joins, theme, inside, region)
                if r:
                    ORBIT_STATS[tag] += 1
                    return r
        r = raw(M, name, nodes, links, c, facing, joins, theme, inside, region)
        if r:
            ORBIT_STATS["as drawn"] += 1
        return r
    B.place_xy = place


def main():
    global BEADS, ORBIT
    global TILT_COMBOS, STRICT
    STRICT = "--strict" in sys.argv
    BEADS = "--beads" in sys.argv
    ORBIT = "--orbit" in sys.argv
    TILT_COMBOS = 0.0 if "--no-tilt" in sys.argv else 20.0
    sys.argv = [a for a in sys.argv if a not in ("--beads", "--orbit", "--tilt-combos", "--no-tilt", "--strict")]
    layout = {}
    for path in sys.argv[1:-1]:         # several layout files (one per land, blend or disc) merge into one map
        for land, entries in json.load(open(path, encoding="utf-8")).items():
            layout.setdefault(land, []).extend(entries)
    # placement order: lands, then blends, then Chaos and the islands (each was authored and filled with the earlier
    # ones in place, so this order reproduces it)
    ORDER = ["fire", "earth", "metal", "water", "wood", "blend_fe", "blend_em", "blend_mw", "blend_ww", "blend_wf",
             "hub", "light", "thunder", "darkness", "shrine"]
    layout = {k: layout[k] for k in sorted(layout, key=lambda k: ORDER.index(k) if k in ORDER else len(ORDER))}
    B.DENSITY_CAP = 0
    M, frames = base()
    log = []
    compile_layout(layout, M, frames, log)
    for n in M.nodes:
        n["u"], n["v"] = n["x"], n["y"]
    keep = [n for n in M.nodes if not n.get("dead")]
    new_id = {n["id"]: k for k, n in enumerate(keep)}
    for n in keep:
        n["id"] = new_id[n["id"]]
    live = [dict(e, a=new_id[e["a"]], b=new_id[e["b"]]) for e in M.edges if not e.get("dead")]
    for gp in M.groups:
        gp["nodes"] = [new_id[i] for i in gp["nodes"] if i in new_id]
        gp.pop("src", None)
    clusters = [{"id": k, "form": gp["shape"], "name": gp["shape"]} for k, gp in enumerate(M.groups)]
    json.dump({"nodes": keep, "edges": live, "groups": M.groups, "clusters": clusters}, open(sys.argv[-1], "w", encoding="utf-8"), ensure_ascii=False)
    print("nodes", len(keep), "groups", len(M.groups), "problems", len(log))
    if BEADS:
        print("beads: %d path nodes" % BEAD_COUNT[0])
    if ORBIT:
        print("orbit:", ORBIT_STATS)
    for line in log:
        print("  " + line)


if __name__ == "__main__":
    main()
