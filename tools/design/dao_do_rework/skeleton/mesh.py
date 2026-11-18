"""A land drawn in PoE's construction grammar (user 2026-11-15: "research the characteristic that makes poe1 and poe2
graphs look so good and copy it"; then "yes please go" on building Fire as a full land).

The grammar, measured on both PoE trees (memory: poe-orbit-grammar; findings page on claude.ai):
- every node sits on a fixed circle round its group's centre, at a fixed angle slot; groups are never turned or scaled.
  Radii keep PoE's ratios (0, 82, 162, 251, 335, 493 ...), scaled so PoE's typical neighbour distance is 1.0 here;
  slots count from the land's axis (so the land mirrors about it): 30 degrees on circle 1, 15 on circles 2-4.
- groups are small (3-7 nodes) and woven into the network: most are bridges between two nodes already drawn, so paths
  run through them; the rest are small pockets. No stems: a group's entry is one spacing from what it joins.
- no hole-filling pass: density comes from the mesh growing along the roads.
Kept from the Đạo Đồ rules: the A2 roads and Fire's three stars (clear inside) are the backbone; every group mirrors
about its own line (notables on it or in mirrored pairs); far ends gold; nothing dead-ends; every group has a notable;
the whole land mirrors about Fire's axis.

Usage: python -I tools/design/dao_do_rework/skeleton/mesh.py <out.json> [target nodes, default 930]
"""
import collections
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import sketch as S  # noqa: E402
import sketch_a2  # noqa: E402

UNIT = 1.0 / 173.0
R = [r * UNIT for r in (0, 82, 162, 251, 335, 493)]
SLOT = 15.0
HALF = 18.0                     # Fire's own share
STARS = [((0.0, S.START_R), 5.8), ((0.0, 48.0), 8.0), ((0.0, 69.5), 6.4)]
SPACING = 0.95                  # no new node closer to one drawn already (user 2026-11-16: "some nodes are really close";
                                # PoE's closest pairs are about 0.93, ours sat at 0.72)
LINK_MIN, LINK_MAX = 0.85, 1.7  # the join from a node drawn already to a group's port

# shapes. Bridges have two ports on the group's line: node 0 faces where it comes from (180), node 1 where it goes (0).
# Pockets have one entry, node 0, facing 180. Nodes: (circle, angle from the facing, role); links (i, j, arc?).
BRIDGES = {
    "bead":  ([(3, 180, "s"), (3, 0, "s"), (0, 0, "N")], [(0, 2, 0), (2, 1, 0)]),
    "lens":  ([(2, 180, "s"), (2, 0, "s"), (2, 90, "N"), (2, -90, "N")], [(0, 2, 1), (0, 3, 1), (2, 1, 1), (3, 1, 1)]),
    "ring":  ([(2, 180, "s"), (2, 0, "s"), (2, 120, "s"), (2, -120, "s"), (2, 60, "N"), (2, -60, "N")],
              [(0, 2, 1), (0, 3, 1), (2, 4, 1), (3, 5, 1), (4, 1, 1), (5, 1, 1)]),
    "wheel": ([(3, 180, "s"), (3, 0, "s"), (0, 0, "N"), (3, 120, "s"), (3, -120, "s"), (3, 60, "s"), (3, -60, "s")],
              [(0, 2, 0), (2, 1, 0), (0, 3, 1), (0, 4, 1), (3, 5, 1), (4, 6, 1), (5, 1, 1), (6, 1, 1)]),
    "chain": ([(4, 180, "s"), (4, 0, "s"), (2, 180, "s"), (0, 0, "N"), (2, 0, "s")], [(0, 2, 0), (2, 3, 0), (3, 4, 0), (4, 1, 0)]),
}
POCKETS = {
    "kite":  ([(2, 180, "s"), (2, 90, "s"), (2, -90, "s"), (2, 0, "N")], [(0, 1, 1), (0, 2, 1), (1, 3, 1), (2, 3, 1)]),
    "spur":  ([(3, 180, "s"), (0, 0, "s"), (3, 0, "N")], [(0, 1, 0), (1, 2, 0)]),
    "fan":   ([(2, 180, "s"), (0, 0, "s"), (3, -45, "N"), (3, 0, "N"), (3, 45, "N")], [(0, 1, 0), (1, 2, 0), (1, 3, 0), (1, 4, 0)]),
    "hex":   ([(2, 180, "s"), (2, 120, "s"), (2, -120, "s"), (2, 60, "s"), (2, -60, "s"), (2, 0, "N")],
              [(0, 1, 1), (0, 2, 1), (1, 3, 1), (2, 4, 1), (3, 5, 1), (4, 5, 1)]),
}


def ang_of(p, q):
    """Direction from p to q, degrees clockwise from the axis (straight up)."""
    return math.degrees(math.atan2(q[0] - p[0], q[1] - p[1]))


def at(c, circle, a):
    return (c[0] + R[circle] * math.sin(math.radians(a)), c[1] + R[circle] * math.cos(math.radians(a)))


def mirror(p):
    return (-p[0], p[1])


class Mesh:
    def __init__(self):
        self.nodes, self.edges = [], []
        self.grid = collections.defaultdict(list)       # 1-unit cells of node ids
        self.egrid = collections.defaultdict(list)      # 2-unit cells of edge indices
        self.mir = {}                                   # node -> its mirror twin
        self.groups = []
        self.deg = collections.Counter()
        self.poly = {}                                  # edge index -> polyline (arcs sampled)
        self.adj = collections.defaultdict(set)         # node -> neighbours (live links; kept by link() and kill_group())

    # -- drawing ---------------------------------------------------------------------------------------------------
    def node(self, p, kind, theme=None, group=None, region="fire"):
        i = len(self.nodes)
        self.nodes.append({"id": i, "x": round(p[0], 4), "y": round(p[1], 4), "kind": kind, "theme": theme, "cluster": group, "region": region})
        self.grid[(int(math.floor(p[0])), int(math.floor(p[1])))].append(i)
        return i

    def pt(self, i):
        return (self.nodes[i]["x"], self.nodes[i]["y"])

    def link(self, a, b, centre=None):
        k = len(self.edges)
        self.edges.append({"a": a, "b": b, "arc": [round(centre[0], 4), round(centre[1], 4)] if centre else None})
        self.deg[a] += 1; self.deg[b] += 1
        self.adj[a].add(b); self.adj[b].add(a)
        pl = self._poly_of(self.pt(a), self.pt(b), centre)
        self.poly[k] = pl
        cells = set()
        for p, q in zip(pl, pl[1:]):
            cells.update(self._cells(p, q))
        for cell in cells:
            self.egrid[cell].append(k)

    @staticmethod
    def _poly_of(a, b, centre):
        """A link as a polyline: straight, or its arc (the short way round the centre) sampled every 0.3."""
        if not centre:
            return [a, b]
        c = centre
        r = math.dist(a, c)
        t1 = math.atan2(a[1] - c[1], a[0] - c[0]); t2 = math.atan2(b[1] - c[1], b[0] - c[0])
        dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        n = max(2, int(abs(dt) * r / 0.3))
        return [a] + [(c[0] + r * math.cos(t1 + dt * j / n), c[1] + r * math.sin(t1 + dt * j / n)) for j in range(1, n)] + [b]

    @staticmethod
    def _cells(p, q):
        x0, x1 = sorted((p[0], q[0])); y0, y1 = sorted((p[1], q[1]))
        return [(gx, gy) for gx in range(int(math.floor(x0 / 2)), int(math.floor(x1 / 2)) + 1)
                for gy in range(int(math.floor(y0 / 2)), int(math.floor(y1 / 2)) + 1)]

    # -- fit -------------------------------------------------------------------------------------------------------
    def near(self, p, r):
        for gx in range(int(math.floor(p[0] - r)), int(math.floor(p[0] + r)) + 1):
            for gy in range(int(math.floor(p[1] - r)), int(math.floor(p[1] + r)) + 1):
                for i in self.grid.get((gx, gy), ()):
                    if not self.nodes[i].get("dead") and math.dist(p, self.pt(i)) < r:
                        yield i

    def fits(self, pts, segs, joins=()):
        """New points keep SPACING from every node (bar the ones they join) and 0.3 from every link; new straight
        links cross nothing (arcs tested along their curve) and pass no node closer than 0.3."""
        skip = set(joins)
        for p in pts:
            if any(i not in skip for i in self.near(p, SPACING)):
                return False
            for k in {k for c in self._cells((p[0] - 0.3, p[1] - 0.3), (p[0] + 0.3, p[1] + 0.3)) for k in self.egrid.get(c, ())}:
                e = self.edges[k]
                if e.get("dead"):
                    continue
                pl = self.poly[k]
                for a, b in zip(pl, pl[1:]):
                    vx, vy = b[0] - a[0], b[1] - a[1]; L = vx * vx + vy * vy
                    t = max(0.0, min(1.0, ((p[0] - a[0]) * vx + (p[1] - a[1]) * vy) / L)) if L else 0.0
                    if math.dist(p, (a[0] + t * vx, a[1] + t * vy)) < 0.3:
                        return False
        o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
        for p1, p2 in segs:
            for k in {k for c in self._cells(p1, p2) for k in self.egrid.get(c, ())}:
                e = self.edges[k]
                if e.get("dead"):
                    continue
                ea, eb = self.pt(e["a"]), self.pt(e["b"])
                if ea in (p1, p2) or eb in (p1, p2):
                    continue
                pl = self.poly[k]
                for p3, p4 in zip(pl, pl[1:]):
                    if o(p1, p2, p3) * o(p1, p2, p4) < 0 and o(p3, p4, p1) * o(p3, p4, p2) < 0:
                        return False
            L = math.dist(p1, p2)
            for t in [k / max(1, int(L / 0.25)) for k in range(1, max(1, int(L / 0.25)))]:
                q = (p1[0] + (p2[0] - p1[0]) * t, p1[1] + (p2[1] - p1[1]) * t)
                if any(math.dist(q, self.pt(i)) < 0.3 and self.pt(i) not in (p1, p2) for i in self.near(q, 0.3)):
                    return False
        return True

    def hops(self, a, b, limit=4):
        """Steps from a to b over live links, up to limit (limit + 1 when farther)."""
        seen = {a: 0}; q = collections.deque([a])
        while q:
            u = q.popleft()
            if seen[u] >= limit:
                continue
            for v in self.adj[u]:
                if v not in seen:
                    seen[v] = seen[u] + 1
                    if v == b:
                        return seen[v]
                    q.append(v)
        return limit + 1

    def kill_group(self, gid):
        """Take the last group drawn back out: its nodes and every link touching them."""
        ids = set(self.groups[gid]["nodes"])
        for k, e in enumerate(self.edges):
            if not e.get("dead") and (e["a"] in ids or e["b"] in ids):
                e["dead"] = True
                self.deg[e["a"]] -= 1; self.deg[e["b"]] -= 1
                self.adj[e["a"]].discard(e["b"]); self.adj[e["b"]].discard(e["a"])
        for i in ids:
            self.nodes[i]["dead"] = True
        self.groups[gid]["dead"] = True

    # -- groups ----------------------------------------------------------------------------------------------------
    def plan(self, shape, c, facing):
        pts, links = shape
        P = [at(c, ci, facing + a) for ci, a, _ in pts]
        return P, links

    def place(self, shape_name, shape, c, facing, joins, theme, inside, dry=False):
        """joins: [(node drawn already, port index)]. Returns the group's node ids, or None."""
        P, links = self.plan(shape, c, facing)
        if not all(inside(*p) for p in P):
            return None
        if DENSITY_CAP and len([i for i in self.near(c, 3.0) if i not in {n_ for n_, _ in joins}]) > DENSITY_CAP:
            return None         # the patch is already full (user 2026-11-15: "cap density")
        segs = [(P[i], P[j]) for i, j, arc in links if not arc] + [(self.pt(n), P[k]) for n, k in joins]
        arcs = [(P[i], P[j]) for i, j, arc in links if arc]
        for p, q in arcs:      # an arc's chord is a fair stand-in for its crossings at this size
            segs.append((p, q))
        for n, k in joins:
            if not (LINK_MIN <= math.dist(self.pt(n), P[k]) <= LINK_MAX):
                return None
        if not self.fits(P, segs, [n for n, _ in joins]):
            return None
        if dry:
            return True
        gid = len(self.groups)
        ids = [self.node(p, "notable" if role == "N" else "small", theme, gid) for p, (_, _, role) in zip(P, shape[0])]
        for i, j, arc in links:
            self.link(ids[i], ids[j], centre=c if arc else None)
        for n, k in joins:
            self.link(n, ids[k])
        self.groups.append({"shape": shape_name, "centre": c, "facing": facing, "nodes": ids})
        return ids


DENSITY_CAP = 0         # nodes within 3 of a new group's centre, the group's own included (0: no cap); set by mapgen


def xy_world(c, facing, u, v):
    """A point of a freely drawn shape (u right, v along its facing) in the world."""
    t = math.radians(facing)
    return (c[0] + u * math.cos(t) + v * math.sin(t), c[1] - u * math.sin(t) + v * math.cos(t))


def place_xy(M, name, nodes, links, c, facing, joins, theme, inside, region):
    """Place a freely drawn shape: nodes [(u, v, role)], links [(i, j, arc centre (u, v) or None)], joins [(node, i)].
    Arcs are tested along their curve. Returns the new ids or None."""
    P = [xy_world(c, facing, u, v) for u, v, _ in nodes]
    if not all(inside(*p) for p in P):
        return None
    # a join may carry a bend (hand authoring, 2026-11-17, user: "curve edges are allowed"): (node, i, s) draws the
    # road link as an arc bulging s units to the right of the way from the node to the figure (s < 0: to the left)
    jarc = {}
    js = []
    for jn in joins:
        n_, k = jn[0], jn[1]
        if len(jn) > 2 and jn[2]:
            a_, b_ = M.pt(n_), P[k]
            dx, dy = b_[0] - a_[0], b_[1] - a_[1]
            L_ = math.hypot(dx, dy) or 1.0
            s_ = jn[2]
            r_ = ((L_ / 2) ** 2 + s_ * s_) / (2 * abs(s_))
            nr = (dy / L_, -dx / L_)
            m_ = ((a_[0] + b_[0]) / 2, (a_[1] + b_[1]) / 2)
            kk = s_ - math.copysign(r_, s_)
            jarc[(n_, k)] = (m_[0] + nr[0] * kk, m_[1] + nr[1] * kk)
        js.append((n_, k))
    joins = js
    if DENSITY_CAP and len([i for i in M.near(c, 3.0) if i not in {n_ for n_, _ in joins}]) > DENSITY_CAP:
        return None
    segs = []
    for i, j, cc in links:
        if cc is None:
            segs.append((P[i], P[j]))
        else:
            w = xy_world(c, facing, *cc)
            pl = Mesh._poly_of(P[i], P[j], w)
            segs += list(zip(pl, pl[1:]))
    for n_, k in joins:
        if not (LINK_MIN <= math.dist(M.pt(n_), P[k]) <= LINK_MAX):
            return None
        if (n_, k) in jarc:
            pl = Mesh._poly_of(M.pt(n_), P[k], jarc[(n_, k)])
            segs += list(zip(pl, pl[1:]))
        else:
            segs.append((M.pt(n_), P[k]))
    if not M.fits(P, segs, [n_ for n_, _ in joins]):
        return None
    gid = len(M.groups)
    ids = [M.node(p, "notable" if r == "N" else "small", theme, gid, region=region) for p, (_, _, r) in zip(P, nodes)]
    for i, j, cc in links:
        M.link(ids[i], ids[j], centre=xy_world(c, facing, *cc) if cc is not None else None)
    for n_, k in joins:
        M.link(n_, ids[k], centre=jarc.get((n_, k)))
    M.groups.append({"shape": name, "centre": c, "facing": facing, "nodes": ids, "region": region})
    return ids


MIRROR_GROUPS = False   # user 2026-11-15: groups need not mirror across the land (the roads and lattice still do)
FILL_STARS = True       # user 2026-11-15: "fill in the star please"
# wheels for open spaces: one entry at 180 on the ring, a small hub in the middle on the entry-to-top line, notables on
# the ring's far points (mirrored pairs and the top)
WHEELS = {
    "wheel8": ([(4, 180, "s"), (4, -135, "s"), (4, -90, "N"), (4, -45, "s"), (4, 0, "N"), (4, 45, "s"), (4, 90, "N"), (4, 135, "s"), (0, 0, "s")],
               [(0, 1, 1), (1, 2, 1), (2, 3, 1), (3, 4, 1), (4, 5, 1), (5, 6, 1), (6, 7, 1), (7, 0, 1), (0, 8, 0), (8, 4, 0)]),
    "wheel12": ([(5, 180 - 30 * k, "N" if k in (3, 6, 9) else "s") for k in range(12)] + [(0, 0, "s")],
                [(k, (k + 1) % 12, 1) for k in range(12)] + [(0, 12, 0), (12, 6, 0)]),
}
LANE_ANGLE = 13.0       # the side lanes run out from the centre this many degrees off the axis, clear of the stars
LANE_STEP = 2.2         # node spacing on a lane (PoE's small-node paths)


def _cross_point(p1, p2, p3, p4):
    d = (p2[0] - p1[0]) * (p4[1] - p3[1]) - (p2[1] - p1[1]) * (p4[0] - p3[0])
    if abs(d) < 1e-12:
        return None
    t = ((p3[0] - p1[0]) * (p4[1] - p3[1]) - (p3[1] - p1[1]) * (p4[0] - p3[0])) / d
    u = ((p3[0] - p1[0]) * (p2[1] - p1[1]) - (p3[1] - p1[1]) * (p2[0] - p1[0])) / d
    if 1e-6 < t < 1 - 1e-6 and 1e-6 < u < 1 - 1e-6:
        return t, (p1[0] + t * (p2[0] - p1[0]), p1[1] + t * (p2[1] - p1[1]))
    return None


def _hub_on(M, p, q):
    """Where the straight segment p-q crosses straight roads drawn already: split each road there with a hub node.
    Returns [(t along p-q, hub id)]."""
    out = []
    for k in range(len(M.edges)):
        e = M.edges[k]
        if e.get("dead") or e.get("arc"):
            continue
        hit = _cross_point(p, q, M.pt(e["a"]), M.pt(e["b"]))
        if not hit:
            continue
        t, x = hit
        h = M.node(x, "travel")
        e["dead"] = True
        M.deg[e["a"]] -= 1; M.deg[e["b"]] -= 1
        M.link(e["a"], h); M.link(h, e["b"])
        out.append((t, h))
    return sorted(out)


def _lane(M, pts):
    """A path of travel nodes through the given points (existing node ids or coordinates), about LANE_STEP apart,
    with a hub wherever it crosses a road. Returns the ids along it."""
    def node_for(x):
        if isinstance(x, int):
            return x
        for j in M.near(x, 0.25):
            return j
        return M.node(x, "travel")
    ids = [node_for(pts[0])]
    for x in pts[1:]:
        p = M.pt(ids[-1])
        q = M.pt(x) if isinstance(x, int) else x
        end = node_for(x)
        on_line = []
        L2 = (q[0] - p[0]) ** 2 + (q[1] - p[1]) ** 2
        for j, nd in enumerate(M.nodes):
            if j in (ids[-1], end) or nd.get("dead") or nd["kind"] != "travel":
                continue
            r_ = M.pt(j)
            t = ((r_[0] - p[0]) * (q[0] - p[0]) + (r_[1] - p[1]) * (q[1] - p[1])) / L2 if L2 else 0
            if 0.01 < t < 0.99 and math.dist(r_, (p[0] + t * (q[0] - p[0]), p[1] + t * (q[1] - p[1]))) < 0.08:
                on_line.append((t, j))
        stops = sorted([(0.0, ids[-1])] + _hub_on(M, p, q) + on_line) + [(1.0, end)]
        for (t0, a), (t1, b) in zip(stops, stops[1:]):
            pa, pb = M.pt(a), M.pt(b)
            n = max(0, int(round(math.dist(pa, pb) / LANE_STEP)) - 1)
            seq = [a] + [M.node((pa[0] + (pb[0] - pa[0]) * j / (n + 1), pa[1] + (pb[1] - pa[1]) * j / (n + 1)), "travel") for j in range(1, n + 1)] + [b]
            for u, v in zip(seq, seq[1:]):
                M.link(u, v)
            ids += seq[1:]
    return ids


def lattice(M):
    """Fire's path lattice, drawn on the right and mirrored: a side lane at LANE_ANGLE from the E1 side road out to the
    rim, and at each gap between the stars two braces from the spine to the side lane, one up and out and one down and
    out, both 60 degrees off the axis, so the lattice is made of diamonds (PoE 2), not a ladder of squares (rejected
    2026-11-08: "the square design looks really bad")."""
    def spine_node_near(v):
        cand = [i for i, n in enumerate(M.nodes) if abs(n["x"]) < 0.05 and n["kind"] == "travel" and not n.get("dead")]
        return min(cand, key=lambda i: abs(M.pt(i)[1] - v))
    rim = [i for i, n in enumerate(M.nodes) if abs(math.hypot(n["x"], n["y"]) - S.RIM) < 0.25]
    gaps = [(S.START_R + 5.8 + 48.0 - 8.0) / 2, (48.0 + 8.0 + 69.5 - 6.4) / 2, (69.5 + 6.4 + S.RIM) / 2]
    for side in (1, -1):
        a = math.radians(side * LANE_ANGLE)
        r0, r1 = 24.0, S.RIM - 3.0
        p0 = (r0 * math.sin(a), r0 * math.cos(a)); p1 = (r1 * math.sin(a), r1 * math.cos(a))
        # the side lane's own stops: where each brace meets it (60 degrees off the axis, up and down from the spine)
        ta = math.tan(abs(a))
        meets, braces = [], []
        for gv in gaps:
            sv = M.pt(spine_node_near(gv))[1]
            for sgn in (1, -1):
                u = ta * sv / (1 - sgn * ta / math.tan(math.radians(60)))
                mv = sv + sgn * u / math.tan(math.radians(60))
                if 24.5 < mv < r1 - 0.5:
                    meets.append((side * u, mv)); braces.append((sv, (side * u, mv)))
        meets.sort(key=lambda m_: m_[1])
        hubs = _hub_on(M, p0, p1)
        start = hubs[0][1] if hubs else M.node(p0, "travel")       # the lane starts on the first road it meets
        lane = _lane(M, [start] + meets + [p1])
        end = lane[-1]
        g = min(rim, key=lambda j: math.dist(M.pt(j), M.pt(end)))
        M.link(end, g)
        for sv, (mu, mv) in braces:
            s = spine_node_near(sv)
            _lane(M, [s, next(j for j in M.near((mu, mv), 0.3))])


def build(target=930):
    g0, _ = sketch_a2.variant_a2()
    M = Mesh()
    inb = lambda x, y: abs(math.degrees(math.atan2(x, y))) <= 44 and S.CENTRE_R - 6 <= math.hypot(x, y) <= S.RIM + 0.5
    m = {}
    for n in g0.nodes:
        if n["kind"] in ("travel", "start") and inb(n["x"], n["y"]):
            m[n["id"]] = M.node((n["x"], n["y"]), n["kind"], region=n["region"])
    for e in g0.edges:
        if e["a"] in m and e["b"] in m:
            M.link(m[e["a"]], m[e["b"]], centre=tuple(e["arc"]) if e.get("arc") else None)
    lattice(M)
    for i, n in enumerate(M.nodes):      # mirror twins of the roads and the lattice
        for j in M.near(mirror(M.pt(i)), 0.05):
            M.mir[i] = j

    def inside(x, y):
        r = math.hypot(x, y)
        if not (abs(math.degrees(math.atan2(x, y))) <= HALF - 0.4 and S.CENTRE_R + 0.8 < r < S.RIM - 0.6):
            return False
        if FILL_STARS:      # the stars hold groups too (user 2026-11-15: "fill in the star please"), clear of the start
            return math.dist((x, y), (0.0, S.START_R)) > 1.6
        return all(math.dist((x, y), c) > rr + 0.4 for c, rr in STARS)

    def theme_at(p):
        a = math.degrees(math.atan2(p[0], p[1]))
        if abs(a) < 3.5:
            return "fire" if math.hypot(*p) < 52 else "phoenix"
        return "alchemy" if a > 0 else "blaze"

    def count():
        return sum(1 for n in M.nodes if inside(n["x"], n["y"]) or (n["kind"] in ("travel", "start") and abs(math.degrees(math.atan2(n["x"], n["y"]))) <= HALF + 0.5
                                                                  and S.CENTRE_R < math.hypot(n["x"], n["y"]) <= S.RIM + 0.5))

    def twin_place(name, shape, c, facing, joins, theme):
        """Place a group on the right half (or on the axis) and its mirror twin on the left; with MIRROR_GROUPS off,
        just place it where it is (each group still mirrors about its own line)."""
        if not MIRROR_GROUPS:
            return M.place(name, shape, c, facing, joins, theme, inside)
        on_axis = abs(c[0]) < 0.05 and (facing % 180 == 0)
        if not on_axis and c[0] < 0:
            return None
        if on_axis:
            ids = M.place(name, shape, c, facing, joins, theme, inside)
            if ids:
                for i in ids:
                    M.mir[i] = next(j for j in ids if math.dist(mirror(M.pt(i)), M.pt(j)) < 0.05)
            return ids
        mj = [(M.mir.get(n), k) for n, k in joins]
        if any(n is None for n, _ in mj):
            return None
        if not M.place(name, shape, c, facing, joins, theme, inside, dry=True):
            return None
        if not M.place(name, shape, mirror(c), -facing, mj, {"alchemy": "blaze", "blaze": "alchemy"}.get(theme, theme), inside, dry=True):
            return None
        a = M.place(name, shape, c, facing, joins, theme, inside)
        b = M.place(name, shape, mirror(c), -facing, mj, {"alchemy": "blaze", "blaze": "alchemy"}.get(theme, theme), inside)
        if a and b:
            for x in a:      # pair by position: the twin's nodes come in the mirrored order
                y = min(b, key=lambda j: math.dist(mirror(M.pt(x)), M.pt(j)))
                M.mir[x] = y; M.mir[y] = x
            return a
        return None

    def hops(a, b, limit=6):
        """Graph distance from a to b, up to limit (limit+1 when farther)."""
        seen = {a: 0}; q = [a]
        for u in q:
            if seen[u] >= limit:
                break
            for v in adjacency[u]:
                if v not in seen:
                    seen[v] = seen[u] + 1
                    if v == b:
                        return seen[v]
                    q.append(v)
        return limit + 1

    def clearance(p):
        """Distance from p to the nearest node or link (links as straight chords)."""
        best = 6.0
        for i in M.near(p, 6.0):
            best = min(best, math.dist(p, M.pt(i)))
        cells = {(gx, gy) for gx in range(int(math.floor((p[0] - 6) / 2)), int(math.floor((p[0] + 6) / 2)) + 1)
                 for gy in range(int(math.floor((p[1] - 6) / 2)), int(math.floor((p[1] + 6) / 2)) + 1)}
        for k in {k for c in cells for k in M.egrid.get(c, ())}:
            e = M.edges[k]
            if e.get("dead"):
                continue
            a, b = M.pt(e["a"]), M.pt(e["b"])
            dx, dy = b[0] - a[0], b[1] - a[1]; L = dx * dx + dy * dy
            t = max(0.0, min(1.0, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / L)) if L else 0.0
            best = min(best, math.dist(p, (a[0] + t * dx, a[1] + t * dy)))
        return best

    def holes(min_clear):
        """Open spots in Fire's share, widest first: (clearance, point)."""
        out = []
        for r10 in range(int((S.CENTRE_R + 1.5) * 2), int((S.RIM - 1.5) * 2)):
            r = r10 / 2.0
            n = max(1, int(2 * math.radians(HALF) * r / 0.6))
            for k in range(n + 1):
                a = math.radians(-HALF + 2 * HALF * k / n)
                p = (r * math.sin(a), r * math.cos(a))
                if not inside(*p):
                    continue
                c = clearance(p)
                if c >= min_clear:
                    out.append((c, p))
        out.sort(reverse=True)
        return out

    def place_wheel(p_id, shape_name, hole):
        """A wheel set in an open space, joined to path node p_id by a straight path along its own axis (a slot
        direction), so the wheel and its path mirror about one line."""
        shape = WHEELS[shape_name]
        Rw = R[shape[0][0][0]]
        p = M.pt(p_id)
        f = round(ang_of(p, hole) / SLOT) * SLOT
        D = math.dist(p, hole)
        c = (p[0] + D * math.sin(math.radians(f)), p[1] + D * math.cos(math.radians(f)))
        P, links = M.plan(shape, c, f)
        entry = P[0]
        Ll = math.dist(p, entry)
        if Ll < LINK_MIN or not all(inside(*q) for q in P):
            return None
        n = max(0, int(round(Ll / LANE_STEP)) - 1)
        lane = [(p[0] + (entry[0] - p[0]) * j / (n + 1), p[1] + (entry[1] - p[1]) * j / (n + 1)) for j in range(1, n + 1)]
        chain = [p] + lane + [entry]
        segs = [(P[i], P[j]) for i, j, _ in links] + list(zip(chain, chain[1:]))
        if not M.fits(P + lane, segs, [p_id]):
            return None
        lids = [M.node(q, "travel") for q in lane]
        gid = len(M.groups)
        ids = [M.node(q, "notable" if role == "N" else "small", theme_at(c), gid) for q, (_, _, role) in zip(P, shape[0])]
        for i, j, arc in links:
            M.link(ids[i], ids[j], centre=c if arc else None)
        seq = [p_id] + lids + [ids[0]]
        for u, v in zip(seq, seq[1:]):
            M.link(u, v)
        M.groups.append({"shape": shape_name, "centre": c, "facing": f, "nodes": ids})
        return ids

    def wheels_in_holes(min_clear, sizes):
        """Set wheels in the widest open spaces until none is wider than min_clear."""
        placed = 0
        tried = set()
        while count() < target:
            hs = [h for h in holes(min_clear) if (round(h[1][0], 1), round(h[1][1], 1)) not in tried]
            if not hs:
                break
            clr, hole = hs[0]
            tried.add((round(hole[0], 1), round(hole[1], 1)))
            ok = False
            for name in sizes:
                if R[WHEELS[name][0][0][0]] + 0.9 > clr:
                    continue
                paths = sorted((i for i, nd in enumerate(M.nodes) if nd["kind"] == "travel" and not nd.get("dead") and M.deg[i] < 5),
                               key=lambda i: math.dist(M.pt(i), hole))[:6]
                for p_id in paths:
                    if place_wheel(p_id, name, hole):
                        ok = True
                        placed += 1
                        break
                if ok:
                    break
        return placed

    # big wheels first in the widest open spaces (PoE sets its big wheels in the open, joined by a path)
    if not MIRROR_GROUPS:
        wheels_in_holes(4.4, ("wheel12", "wheel8"))
    # tiers of growth: bridges road-road, then anything-anything, then pockets
    rounds = 0
    while count() < target and rounds < 400:
        rounds += 1
        adjacency = collections.defaultdict(set)
        for e in M.edges:
            if not e.get("dead"):
                adjacency[e["a"]].add(e["b"]); adjacency[e["b"]].add(e["a"])
        placed = 0
        anchors = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and M.deg[i] < 5 and (not MIRROR_GROUPS or M.pt(i)[0] >= -0.05)]
        anchors.sort(key=lambda i: (M.nodes[i]["kind"] != "travel", math.hypot(*M.pt(i))))
        pool = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and M.deg[i] < 5]
        for a in anchors:
            if count() >= target:
                break
            pa = M.pt(a)
            best = None
            for b in pool:
                if b == a or b in adjacency[a]:
                    continue
                pb = M.pt(b)
                d = math.dist(pa, pb)
                if not (3.4 <= d <= 7.4):
                    continue
                f = ang_of(pa, pb)
                fs = round(f / SLOT) * SLOT
                if abs(f - fs) > 2.5:
                    continue
                h = hops(a, b)
                if h < 4:
                    continue
                for name in sorted(BRIDGES, key=lambda s: (abs(2 * R[BRIDGES[s][0][0][0]] + 2.4 - d), s)):
                    shape = BRIDGES[name]
                    c = ((pa[0] + pb[0]) / 2, (pa[1] + pb[1]) / 2)
                    ids = twin_place(name, shape, c, fs, [(a, 0), (b, 1)], theme_at(c))
                    if ids:
                        best = ids
                        break
                if best:
                    placed += 1
                    break
        if True:
            # pockets on free spots of road nodes and group nodes, facing out on a slot (one per anchor per round,
            # so growth spreads evenly instead of piling up at the first anchors)
            before = placed
            for a in anchors:
                if count() >= target:
                    break
                pa = M.pt(a)
                used = collections.Counter(gp["shape"] for gp in M.groups)
                for name in sorted(("hex", "kite", "fan", "spur"), key=lambda s_: (used[s_], s_)):
                    shape = POCKETS[name]
                    done = False
                    for f in sorted(range(-180, 180, 30), key=lambda f: abs(((f - ang_of((0, 0), pa)) + 180) % 360 - 180)):
                        er = R[shape[0][0][0]]
                        dd = er + 1.15
                        c = (pa[0] + dd * math.sin(math.radians(f)), pa[1] + dd * math.cos(math.radians(f)))
                        if twin_place(name, shape, c, f, [(a, 0)], theme_at(c)):
                            done = True
                            placed += 1
                            break
                    if done:
                        break
            if placed == 0:
                break
    # what open space is left gets smaller wheels on short paths
    if not MIRROR_GROUPS and count() < target:
        wheels_in_holes(3.2, ("wheel8",))
    return M, count()


def main():
    out = sys.argv[1]
    target = int(sys.argv[2]) if len(sys.argv) > 2 else 930
    M, n = build(target)
    for nd in M.nodes:
        nd["u"], nd["v"] = nd["x"], nd["y"]
    clusters = [{"id": k, "form": gp["shape"], "name": gp["shape"]} for k, gp in enumerate(M.groups)]
    json.dump({"nodes": M.nodes, "edges": [e for e in M.edges if not e.get("dead")], "groups": M.groups, "clusters": clusters}, open(out, "w", encoding="utf-8"), ensure_ascii=False)
    shapes = collections.Counter(gp["shape"] for gp in M.groups)
    kinds = collections.Counter(nd["kind"] for nd in M.nodes)
    print("Fire nodes", n, "| all nodes", len(M.nodes), dict(kinds), "| groups", len(M.groups), dict(shapes))


if __name__ == "__main__":
    main()
