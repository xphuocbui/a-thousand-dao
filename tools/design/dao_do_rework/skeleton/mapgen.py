"""The whole map in PoE's construction grammar: every element land and blend zone filled on the A2 roads, one shared
graph so nothing overlaps (user 2026-11-15: "fill in the graph").

Per region, in its own frame (its axis straight up): a path lattice (side lanes at LANE_ANGLE, 60-degree braces from
the spine at each gap between emblems), a wheel at the centre of each emblem that has no start in it, joined to the
spine at the emblem's bottom and top (user: "the big circle ... put in the middle and connected to the middle line"),
wheels in the widest open spaces on short straight paths, then small groups (3-7 nodes, PoE's circles and 15-degree
slots counted from the region's axis, no stems) bridging and hanging on the paths. The groups machinery is mesh.py's.
The Chaos centre and the islands are not filled yet.

Usage: python -I tools/design/dao_do_rework/skeleton/mapgen.py <out.json>
"""
import collections
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import mesh as B  # noqa: E402
import sketch as S  # noqa: E402
import sketch_a2  # noqa: E402
import shapegen  # noqa: E402
import starts  # noqa: E402
import emblems as EMB  # noqa: E402
import authored  # noqa: E402
import random  # noqa: E402

STARTS = True       # start constellations (user 2026-11-15: "at the start node, there is usually a very unique pattern")
# junction spokes (2026-11-15 measurements): PoE joins a cluster to the road by a straight spoke whose length varies
# (median 2.8 spacings, quartiles 1.9 and 4.7); ours were all 1.15, so groups hugged the roads and left empty land
# between them. Road nodes take up to JUNCTION_MAX links (PoE: half its road nodes have 5-7).
SPOKES = (1.15, 1.6, 2.2, 2.8, 3.4)    # PoE 2: quartiles 1.6 / 2.2 / 3.4
JUNCTION_MAX = 7
ZIGZAG = True       # lattice lanes zigzag (PoE 2 keeps 16 % of its line length in straight runs over 15; ours 33 %)
ZIG = 15.0
HOLE_SIZES = (6, 10)    # wheels for open spaces: PoE 2 has 2-4 % of its group nodes in groups of 13+, ours had 12 %
WEAVE = True
DISC_TOPUP = False  # user 2026-11-15: "400-500 is fine does not have to be 500, most important thing is aesthetic"
DISC_MARGIN = 0.9   # the islands' and Chaos's roads are dense; a thinner clear margin keeps their shapes readable
ROAD_MARGIN = 1.2   # groups keep this clear of the A2 sketch roads so the emblems read as channels at full zoom
_SK = collections.defaultdict(list)     # samples of the sketch roads, in 1-unit cells


def _sample_sketch(M, upto_edge):
    for e in M.edges[:upto_edge]:
        if e.get("dead") or M.nodes[e["a"]]["kind"] != "travel" or M.nodes[e["b"]]["kind"] != "travel":
            continue
        a, b = M.pt(e["a"]), M.pt(e["b"])
        if e.get("arc"):
            c = e["arc"]; r = math.dist(a, c)
            t1 = math.atan2(a[0] - c[0], a[1] - c[1]); t2 = math.atan2(b[0] - c[0], b[1] - c[1])
            dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
            n = max(2, int(abs(dt) * r / 0.4))
            pts = [(c[0] + r * math.sin(t1 + dt * k / n), c[1] + r * math.cos(t1 + dt * k / n)) for k in range(n + 1)]
        else:
            n = max(2, int(math.dist(a, b) / 0.4))
            pts = [(a[0] + (b[0] - a[0]) * k / n, a[1] + (b[1] - a[1]) * k / n) for k in range(n + 1)]
        for q in pts:
            _SK[(int(math.floor(q[0])), int(math.floor(q[1])))].append(q)


# keystones (rules measured on both PoE trees, 2026-11-15; user: "derive the keystones rules from PoE trees, please
# scatter them across the graph"):
#   K1 alone: a group of one, joined by a single straight link 2.2 long (PoE 1.9-2.3) to a road node, no chain before it
#   K2 clearing: nothing else within KEY_CLEAR of it (PoE: nearest unlinked node 1.3-2.4, median 1.8)
#   K3 spread: no other keystone within KEY_MIN (PoE: nearest keystone median 8.7 / 12.2 spacings, p10 about 5)
#   K4 count: about 0.8 % of a region's nodes (PoE 2 0.8 %, PoE 1 2.4 %); mostly the outer half (PoE: 0.6-0.9 of the
#      radius), a few inside; spread round every direction
#   K5 not at a start: at least KEY_FROM_START from any start (PoE: 7-16 steps)
#   K6 the anchor is a road junction (PoE: 5-8 links); the link runs on the 15-degree grid, outward when it can
KEY_LINK, KEY_CLEAR, KEY_MIN, KEY_FROM_START, KEY_SHARE, KEY_INNER = 2.2, 1.6, 8.0, 7.0, 0.008, 0.2
KEYS = []


def key_clear(x, y):
    return all((x - k[0]) ** 2 + (y - k[1]) ** 2 >= KEY_CLEAR * KEY_CLEAR for k in KEYS)


_MARGIN_ON = [True]


def clear_of_roads(x, y, r=None):
    if not ROAD_MARGIN or not _MARGIN_ON[0]:
        return True
    r = r or ROAD_MARGIN
    for gx in range(int(math.floor(x - r)), int(math.floor(x + r)) + 1):
        for gy in range(int(math.floor(y - r)), int(math.floor(y + r)) + 1):
            for q in _SK.get((gx, gy), ()):
                if (q[0] - x) ** 2 + (q[1] - y) ** 2 < r * r:
                    return False
    return True


EMBLEM_DESIGNS = True   # user 2026-11-16 approved the hand-drawn emblems (emblems.py) over the generated set pieces
OUTER_BAND = True       # user 2026-11-15: more and bigger clusters outside the rim, the strongest there (authored.BIG)
OB_DEPTH, OB_BIG_EVERY = 13.0, 30.0      # how far past the rim; degrees between big set pieces round the rim
DARK_ARMS = True        # user 2026-11-15: fewer bare travel nodes on the arms to the moon and the shrine, clusters on them
B.DENSITY_CAP = 6       # at most this many nodes drawn already within 3 of a new group's centre (user: "cap density")
NODE_SCALE = 0.85       # user 2026-11-16: "80 85 or 90% of this would be slightly better"
AUTH_SHARE = 0.3        # of a land's target placed first as hand-authored shapes and 2-3-cluster patterns
AUTH = {f().name: f() for f in authored.SHAPES}
EMBLEM_CLUSTERS = True  # user 2026-11-15: each land emblem becomes one set-piece cluster in its own silhouette
KEYSTONES_V2 = True     # keystones by the PoE rules K1-K6, scattered over every region (user 2026-11-15)
BURSTS = True      # set pieces: radial bursts of one small figure round a road hub, in the widest spaces
PAIR_TRY = 0.55    # rule 6 (user 2026-11-15, case E): mirrored pairs across a road, 5-10 % of facing pairs
OPEN_RIM = False    # user 2026-11-15: "did you remove the outer most ring? That's not right" -- the rim road stays whole
SHRINE, SHRINE_R, SHRINE_TARGET = True, 10.0, 140      # the Shadow Shrine filled (user: "same or even grow a bit bigger")
BRIDGE_MAX = 11.0   # road nodes this far apart (lined up on the grid) can be bridged by a catalogue shape
PAIR_EXITS = True   # C-shaped pockets exit through their two far nodes, mirrored        # pass-through: a pocket's far node on its axis joins the next road or group straight ahead
START_THEME = {"hub": "chaos", "light": "light", "thunder": "thunder", "darkness": "dark", "blend_ww": "wind"}

# the composed catalogue (shapegen.py): PoE-like arcs, rings and wheels, each used rarely
def _cached(name, fn):
    """The shapegen catalogues are pure and seeded but take about 90 s to build; keep them on disk, keyed on the
    sources' modification times (2026-11-17, so a layout compile takes seconds instead of a minute and a half)."""
    import pickle
    import tempfile
    key = tuple(os.path.getmtime(os.path.join(HERE, f)) for f in ("shapegen.py", "mesh.py"))
    path = os.path.join(tempfile.gettempdir(), "dao_do_shapegen_%s.pkl" % name)
    try:
        with open(path, "rb") as fh:
            k, v = pickle.load(fh)
        if k == key:
            return v
    except Exception:
        pass
    v = fn()
    try:
        with open(path, "wb") as fh:
            pickle.dump((key, v), fh)
    except Exception:
        pass
    return v


CAT = _cached("catalogue", shapegen.catalogue_all)
STRAIGHT = _cached("straight", shapegen.straight_all)      # PoE 2's straight compositions (bursts, chains, tridents, diamonds), names "t..."
CAT.update(STRAIGHT)
STRAIGHT_SHARE = 0.5                    # PoE 2: 57 % of inner links straight; PoE 1: 8 %


def _far_axis(shape):
    """Index of the shape's far node on its axis (angle 0, the farthest from the entry), or None."""
    pts = shape[0]
    proj = [B.R[c] * math.cos(math.radians(a)) for c, a, _ in pts]
    top = max(proj)
    far = [i for i, (c, a, _) in enumerate(pts) if i and abs(a % 360) < 1e-6 and abs(proj[i] - top) < 1e-6]
    return far[0] if far and sum(1 for p_ in proj if abs(p_ - top) < 1e-6) == 1 else None


# through shapes (shapegen.through_all): entry and far-axis exit both minor, notables off the way through, so a road
# passes through a group without landing on a notable (PoE: 2-6 % of notables touch a road)
THROUGH = _cached("through", shapegen.through_all)
for _nm, (_sh, _k) in THROUGH.items():
    B.WHEELS.setdefault(_nm, _sh)
THROUGH_N = {n: len(sh[0]) for n, (sh, _) in THROUGH.items()}
THROUGH_R = {n: max(B.R[c] for c, _, _ in sh[0]) for n, (sh, _) in THROUGH.items()}
THROUGH_HOPS = 3            # the two roads a through group joins are at least this many steps apart already
THROUGH_BRIDGES = True      # a bridge pass of through shapes between road nodes, before the growth
THROUGH_SHARE = 0.5         # of pocket picks; PoE 2: about a third of its groups have a road passing through

# every catalogue shape that can bridge: entry at 180, a single far node at 0; (shape, far index, span entry-to-far)
BRIDGE_CAT = {}
for _nm, _sh in CAT.items():
    _k = _far_axis(_sh)
    if _k is not None and _sh[0][_k][2] != "N":       # the far port is minor: a road never lands on a notable (PoE: 2-6 %)
        BRIDGE_CAT[_nm] = (_sh, _k, B.R[_sh[0][0][0]] + B.R[_sh[0][_k][0]])
for _nm, (_sh, _k) in THROUGH.items():
    BRIDGE_CAT[_nm] = (_sh, _k, B.R[_sh[0][0][0]] + B.R[_sh[0][_k][0]])
for _nm, _sh in list(CAT.items()):
    B.WHEELS.setdefault(_nm, _sh)
CAT_R = {n: max(B.R[c] for c, _, _ in sh[0]) for n, sh in CAT.items()}
CAT_N = {n: len(sh[0]) for n, sh in CAT.items()}
CAT_G = {n: sum(1 for _, _, r in sh[0] if r == "N") for n, sh in CAT.items()}
# notables per group: PoE 2's groups hold 1 / 2 / 3+ notables 70 / 20 / 10 % of the time; ours were 26 / 60 / 14
GOLD_W = (60, 28, 12)      # PoE 2: one notable in 60 % of clusters, two in 24 %, three or more in 13 %
# PoE 1's group sizes (3 nodes most often, few above 9), as weights for picking a shape's size
SIZE_W = {3: 8, 4: 17, 5: 16, 6: 12, 7: 9, 8: 7, 9: 4, 10: 2, 11: 2, 12: 1}     # PoE 2's clusters by structure (survey 2026-11-16)
USED = collections.Counter()

# lessons from the first whole-map comparison with PoE (2026-11-15): blends got half a land's nodes in the same angle, so
# the map read as ten pie slices; lands now take 48 degrees and blends 24, so nodes per degree match. Lanes put a node
# every 2.2 and read as strings of beads; PoE's roads are long clean links, so lanes step 4.0. Groups may bridge across
# a region border so the borders do not read as seams.
HALF_OF = {**{k: 24.0 for k in S.LANDS}, **{k: 12.0 for k in S.BLENDS}}
# road directions on PoE's grid (2026-11-15: 51-63 % of PoE's straight links run in a 15-degree direction, ours 27 %):
# lanes at 15 degrees off a land's axis, 7.5 off a blend's
LANE_OF = {**{k: 15.0 for k in S.LANDS}, **{k: 7.5 for k in S.BLENDS}}
# the macro lessons (whole-tree comparison 2026-11-15): every start sits in a clear void; the outline is ragged, not a
# hard circle; keystones are visible accents in the outer band
START_VOID = 4.0


def outer_limit(a):
    """How far past the rim groups may reach at world angle a (degrees): an uneven edge, 0.8 to about 6 units."""
    t = math.radians(a)
    return S.RIM + 1.5 + 7.5 * (0.5 + 0.5 * math.sin(5 * t + 0.7)) * (0.55 + 0.45 * math.sin(13 * t + 2.1))
B.LANE_STEP = 4.0
B.LINK_MAX = max(SPOKES) + 0.3
# emblems along each axis: (centre v, radius, family, has a start inside); from sketch_a2
LAND_EMBLEMS = {
    "fire": [(27.0, 5.8, "star", True), (48.0, 8.0, "star", False), (69.5, 6.4, "star", False)],
    "earth": [(27.0, 5.8, "fortress", True), (48.0, 8.0, "fortress", False), (69.5, 6.4, "fortress", False)],
    "metal": [(27.0, 5.8, "blade", True), (48.0, 8.0, "blade", False), (69.5, 6.4, "blade", False)],
    "water": [(27.0, 5.8, "lotus", True), (39.6, 4.3, "snow", True), (52.0, 7.4, "lotus", False), (69.5, 6.4, "lotus", False)],
    "wood": [(27.0, 5.8, "leaf", True), (48.0, 8.0, "leaf", False), (69.5, 6.4, "leaf", False)],
}
BLEND_EMBLEMS = [(37.5, 4.6, "circle", False), (59.0, 5.6, "circle", False)]
INNER = {"star": 0.72, "fortress": 0.0, "blade": 0.44, "lotus": 0.8, "snow": 0.52, "leaf": 0.0, "circle": 1.0}   # free radius share inside
THEMES = {
    "fire": ("blaze", "alchemy", "fire", "phoenix"), "earth": ("mountain", "formation", "earth", "gravity"),
    "metal": ("sword", "refining", "metal", "body"), "water": ("tide", "talisman", "water", "ice"),
    "wood": ("field", "beast", "wood", "growth"),
    "blend_fe": ("fire", "earth", "lava", "alchemy"), "blend_em": ("earth", "metal", "ore", "gravity"),
    "blend_mw": ("metal", "water", "dew", "tide"), "blend_ww": ("rain", "wind", "wind", "rain"),
    "blend_wf": ("wood", "fire", "kindling", "growth"),
}
TARGET = {**{k: 930 for k in S.LANDS}, **{k: 450 for k in S.BLENDS}}
TARGET = {k: int(v * 0.85) for k, v in TARGET.items()}      # NODE_SCALE (user 2026-11-16)


def to_local(p, ax):
    t = math.radians(ax)
    return (p[0] * math.cos(t) - p[1] * math.sin(t), p[0] * math.sin(t) + p[1] * math.cos(t))


def to_world(u, v, ax):
    return S.to_world(ax, u, v)


class Region:
    def __init__(self, M, name, ax):
        self.M, self.name, self.ax = M, name, ax
        self.emblems = LAND_EMBLEMS.get(name, BLEND_EMBLEMS)
        self.themes = THEMES[name]
        self.target = TARGET[name]
        self.half = HALF_OF[name]
        self.lane_angle = LANE_OF[name]
        self.inside_any = None      # set by build(): any region's inside, for bridges across a border
        self.origin = (0.0, 0.0)    # pockets face away from this point
        self.rng = random.Random(name)

    def lang(self, p):
        u, v = to_local(p, self.ax)
        return math.degrees(math.atan2(u, v)), math.hypot(u, v)

    def inside(self, x, y):
        a, r = self.lang((x, y))
        wa = math.degrees(math.atan2(x, y))
        if not (abs(a) <= self.half - 0.4 and S.CENTRE_R + 0.8 < r < outer_limit(wa)) or S.RIM - 0.6 <= r <= S.RIM + 0.6:
            return False
        u, v = to_local((x, y), self.ax)
        for cv, rr, fam, has_start in self.emblems:
            if has_start and math.dist((u, v), (0.0, cv)) < START_VOID:
                return False      # the start keeps a clearing
        return clear_of_roads(x, y) and key_clear(x, y)

    def owns(self, p):
        a, r = self.lang(p)
        return abs(a) <= self.half + 0.3 and S.CENTRE_R < r <= outer_limit(math.degrees(math.atan2(*p))) + 0.5

    def count(self):
        return sum(1 for n in self.M.nodes if not n.get("dead") and self.owns((n["x"], n["y"])))

    def theme(self, p):
        a, r = self.lang(p)
        left, right, elem, elem2 = self.themes
        if abs(a) < 3.5:
            return elem if r < 52 else elem2
        return right if a > 0 else left

    def snap(self, f):
        return self.ax + round((f - self.ax) / B.SLOT) * B.SLOT

    # -- the lattice ----------------------------------------------------------------------------------------------
    def spine_node_near(self, v):
        M = self.M
        cand = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and not n.get("dead")
                and abs(to_local(M.pt(i), self.ax)[0]) < 0.05 and to_local(M.pt(i), self.ax)[1] > 0]
        return min(cand, key=lambda i: abs(to_local(M.pt(i), self.ax)[1] - v))

    def lattice(self):
        M = self.M
        tops = sorted(self.emblems)
        gaps = [((a[0] + a[1]) + (b[0] - b[1])) / 2 for a, b in zip(tops, tops[1:])] + [(tops[-1][0] + tops[-1][1] + S.RIM) / 2]
        rim = [i for i, n in enumerate(M.nodes) if abs(math.hypot(n["x"], n["y"]) - S.RIM) < 0.25]
        r0, r1 = 24.0, S.RIM - 3.0
        for side in (1, -1):
            a = math.radians(side * self.lane_angle)
            ta = math.tan(abs(a))
            meets, braces = [], []
            for gv in gaps:
                sv = to_local(M.pt(self.spine_node_near(gv)), self.ax)[1]
                for sgn in (1, -1):
                    u = ta * sv / (1 - sgn * ta / math.tan(math.radians(60)))
                    mv = sv + sgn * u / math.tan(math.radians(60))
                    if 24.5 < mv < r1 - 0.5:
                        meets.append(to_world(side * u, mv, self.ax)); braces.append((sv, to_world(side * u, mv, self.ax)))
            meets.sort(key=lambda m_: to_local(m_, self.ax)[1])
            p0 = to_world(r0 * math.sin(a), r0 * math.cos(a), self.ax)
            p1 = to_world(r1 * math.sin(a), r1 * math.cos(a), self.ax)
            hubs = B._hub_on(M, p0, p1)
            start = hubs[0][1] if hubs else M.node(p0, "travel")
            pts = [start] + meets + [p1]
            if ZIGZAG:      # bend between stops so the lane zigzags on the 15-degree grid instead of one long line
                zz = [pts[0]]
                for k_, (A_, B_) in enumerate(zip(pts, pts[1:])):
                    a_ = to_local(M.pt(A_) if isinstance(A_, int) else A_, self.ax)
                    b_ = to_local(M.pt(B_) if isinstance(B_, int) else B_, self.ax)
                    lean = 1 if k_ % 2 == 0 else -1
                    d1 = math.radians(side * (self.lane_angle + lean * ZIG))
                    d2 = math.radians(side * (self.lane_angle - lean * ZIG))
                    e1, e2 = (math.sin(d1), math.cos(d1)), (math.sin(d2), math.cos(d2))
                    det = e1[0] * (-e2[1]) - e1[1] * (-e2[0])
                    dx, dy = b_[0] - a_[0], b_[1] - a_[1]
                    s_ = (dx * (-e2[1]) - dy * (-e2[0])) / det if abs(det) > 1e-9 else 0.0
                    if math.dist(a_, b_) > 6.0 and s_ > 1.0:
                        zz.append(to_world(a_[0] + s_ * e1[0], a_[1] + s_ * e1[1], self.ax))
                    zz.append(B_)
                pts = zz
            lane = B._lane(M, pts)
            g = min(rim, key=lambda j: math.dist(M.pt(j), M.pt(lane[-1])))
            M.link(lane[-1], g)
            for sv, mp in braces:
                s = self.spine_node_near(sv)
                B._lane(M, [s, next(j for j in M.near(mp, 0.3))])

    # -- wheels -----------------------------------------------------------------------------------------------------
    def pick_shapes(self, k, min_n=3, max_n=13):
        """k catalogue shapes to try: sizes weighted like PoE 1's groups, the least used first."""
        rng = self.rng
        out = []
        for _ in range(k):
            n = rng.choices(list(SIZE_W), weights=list(SIZE_W.values()))[0]
            n = max(min_n, min(max_n, n))
            straight = rng.random() < STRAIGHT_SHARE
            gold = rng.choices((1, 2, 3), weights=GOLD_W)[0]
            same = [x for x in CAT if CAT_N[x] == n]
            pool = ([x for x in same if (x in STRAIGHT) == straight and min(3, CAT_G[x]) == gold]
                    or [x for x in same if min(3, CAT_G[x]) == gold] or same or list(CAT))
            low = min(USED[x] for x in pool)
            out.append(rng.choice([x for x in pool if USED[x] == low]))
        return out

    def build_wheel(self, shape_name, c, f, joins):
        """A wheel at centre c facing f; joins: [(node, wheel port index)] each joined by a straight path (travel
        nodes about LANE_STEP apart). Returns the wheel's ids or None."""
        M = self.M
        shape = B.WHEELS[shape_name]
        P, links = M.plan(shape, c, f)
        if not all(self.inside(*q) for q in P):
            return None
        if B.DENSITY_CAP and len(list(M.near(c, 3.0))) > B.DENSITY_CAP:
            return None         # the density cap holds for hole-filling wheels too
        lanes, segs = [], [(P[i], P[j]) for i, j, _ in links]
        for n_id, k in joins:
            p, e = M.pt(n_id), P[k]
            L = math.dist(p, e)
            if L < B.LINK_MIN:
                return None
            n = max(0, int(round(L / B.LANE_STEP)) - 1)
            pts = [(p[0] + (e[0] - p[0]) * j / (n + 1), p[1] + (e[1] - p[1]) * j / (n + 1)) for j in range(1, n + 1)]
            lanes.append((n_id, k, pts))
            chain = [p] + pts + [e]
            segs += list(zip(chain, chain[1:]))
        if not M.fits(P + [q for _, _, pts in lanes for q in pts], segs, [n for n, _ in joins]):
            return None
        gid = len(M.groups)
        ids = [M.node(q, "notable" if role == "N" else "small", self.theme(c), gid, region=self.name) for q, (_, _, role) in zip(P, shape[0])]
        for i, j, arc in links:
            M.link(ids[i], ids[j], centre=c if arc else None)
        for n_id, k, pts in lanes:
            lids = [M.node(q, "travel", region=self.name) for q in pts]
            seq = [n_id] + lids + [ids[k]]
            for u_, v_ in zip(seq, seq[1:]):
                M.link(u_, v_)
        M.groups.append({"shape": shape_name, "centre": c, "facing": f, "nodes": ids, "region": self.name})
        return ids

    def emblem_wheels(self):
        """A wheel at the centre of each emblem without a start, joined to the emblem's bottom and top on the axis."""
        M = self.M
        for cv, rr, fam, has_start in self.emblems:
            if has_start or INNER[fam] == 0.0 or EMBLEM_DESIGNS:
                continue
            c = to_world(0.0, cv, self.ax)
            ring = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and not n.get("dead") and abs(math.dist(M.pt(i), c) - rr) < rr * 0.6
                    and abs(to_local((M.pt(i)[0] - c[0], M.pt(i)[1] - c[1]), self.ax)[0]) < 0.05]
            bottom = [i for i in ring if to_local((M.pt(i)[0] - c[0], M.pt(i)[1] - c[1]), self.ax)[1] < 0]
            top = [i for i in ring if to_local((M.pt(i)[0] - c[0], M.pt(i)[1] - c[1]), self.ax)[1] > 0]
            if not bottom or not top:
                continue
            b = max(bottom, key=lambda i: to_local((M.pt(i)[0] - c[0], M.pt(i)[1] - c[1]), self.ax)[1])
            t = min(top, key=lambda i: to_local((M.pt(i)[0] - c[0], M.pt(i)[1] - c[1]), self.ax)[1])
            free = min(math.dist(M.pt(b), c), math.dist(M.pt(t), c))
            for name in ("wheel12", "wheel8"):
                Rw = B.R[B.WHEELS[name][0][0][0]]
                if Rw + 1.0 > free:
                    continue
                top_port = next(k for k, (ci, a, _) in enumerate(B.WHEELS[name][0]) if ci == B.WHEELS[name][0][0][0] and a % 360 == 0)
                if self.build_wheel(name, c, self.ax, [(b, 0), (t, top_port)]):
                    break

    def emblem_designed(self):
        """The hand-drawn emblem set pieces (emblems.py) on this region's emblems without a start: the outline's road
        nodes become the cluster, its long sides get a small node or two, and the drawn interior goes in."""
        M = self.M
        made = 0
        t = math.radians(self.ax)
        for cv, rr, fam, has_start in self.emblems:
            c = to_world(0.0, cv, self.ax)
            if has_start or any(n["kind"] == "start" and math.dist((n["x"], n["y"]), c) < rr for n in M.nodes):
                continue
            loc = lambda p: (round((p[0] - c[0]) * math.cos(t) - (p[1] - c[1]) * math.sin(t), 4), round((p[0] - c[0]) * math.sin(t) + (p[1] - c[1]) * math.cos(t), 4))
            wld = lambda q: (c[0] + q[0] * math.cos(t) + q[1] * math.sin(t), c[1] - q[0] * math.sin(t) + q[1] * math.cos(t))
            outline = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and n.get("sk") and not n.get("dead") and math.dist(M.pt(i), c) <= rr + 0.3]
            if len(outline) < 4:
                continue
            S_ = set(outline)
            # a lane clipping the emblem: its nodes inside go, its outside ends join the nearest outline node instead
            for j in [j for j, n in enumerate(M.nodes) if n["kind"] == "travel" and not n.get("sk") and not n.get("dead") and math.dist(M.pt(j), c) <= rr + 0.3]:
                outs = [x for x in list(M.adj[j]) if x not in S_ and not M.nodes[x].get("dead") and math.dist(M.pt(x), c) > rr + 0.3]
                for k, e in enumerate(M.edges):
                    if not e.get("dead") and j in (e["a"], e["b"]):
                        e["dead"] = True
                        M.deg[e["a"]] -= 1; M.deg[e["b"]] -= 1
                        M.adj[e["a"]].discard(e["b"]); M.adj[e["b"]].discard(e["a"])
                M.nodes[j]["dead"] = True
                for x in outs:
                    tgt = sorted(outline, key=lambda o: math.dist(M.pt(o), M.pt(x)))
                    for o in tgt[:3]:
                        if M.fits([], [(M.pt(x), M.pt(o))], [x, o]):
                            M.link(x, o)
                            break
            ks = [k for k, e in enumerate(M.edges) if not e.get("dead") and e["a"] in S_ and e["b"] in S_]
            olinks = [(loc(M.pt(M.edges[k]["a"])), loc(M.pt(M.edges[k]["b"])), loc(tuple(M.edges[k]["arc"])) if M.edges[k].get("arc") else None) for k in ks]
            ports = {loc(M.pt(i)) for i in outline if any(j not in S_ for j in M.adj[i] if not M.nodes[j].get("dead"))}
            nodes_d, links_d = EMB.design(fam, [loc(M.pt(i)) for i in outline], olinks, ports, rr)
            for k in ks:
                e = M.edges[k]; e["dead"] = True
                M.deg[e["a"]] -= 1; M.deg[e["b"]] -= 1
                M.adj[e["a"]].discard(e["b"]); M.adj[e["b"]].discard(e["a"])
            have = {loc(M.pt(i)): i for i in outline}
            find = lambda q: next((i for p_, i in have.items() if math.dist(p_, q) < 0.06), None)
            new_pts = [wld(q) for q in nodes_d if find(q) is None]
            at = lambda q: M.pt(find(q)) if find(q) is not None else wld(q)       # existing nodes at their exact place
            segs = []
            for a, b, cc in links_d:
                if cc is None:
                    segs.append((at(a), at(b)))
                else:
                    pl = B.Mesh._poly_of(at(a), at(b), wld(cc))
                    segs += list(zip(pl, pl[1:]))
            if not M.fits(new_pts, segs, outline):
                for k in ks:        # does not fit here: the road emblem stays
                    e = M.edges[k]; e["dead"] = False
                    M.deg[e["a"]] += 1; M.deg[e["b"]] += 1
                    M.adj[e["a"]].add(e["b"]); M.adj[e["b"]].add(e["a"])
                print("  emblem does not fit:", self.name, fam, cv)
                continue
            gid = len(M.groups)
            ids = {}
            for q, role in nodes_d.items():
                i = find(q)
                if i is None:
                    i = M.node(wld(q), "small", self.theme(c), gid, region=self.name)
                M.nodes[i].update(kind="notable" if role == "N" else "small", cluster=gid, theme=self.theme(c), region=self.name)
                ids[q] = i
            for a, b, cc in links_d:
                ia = ids.get(a, find(a)); ib = ids.get(b, find(b))
                if ia is None or ib is None or ib in M.adj[ia]:
                    continue
                M.link(ia, ib, centre=wld(cc) if cc is not None else None)
            M.groups.append({"shape": "emblem:" + fam, "centre": c, "facing": self.ax, "nodes": sorted(set(ids.values())), "region": self.name})
            made += 1
        return made

    def emblem_clusters(self):
        """User 2026-11-15: the land emblems (Wood's leaf, Earth's fortress ...) read bare; design a special cluster for
        each and let it replace the emblem's roads. Each emblem without a start becomes one set piece in its own
        silhouette: the outline's road nodes turn into the cluster's nodes, the wheel inside (if any) joins it, and
        every free corner of the outline sends a spoke in, to the wheel or to a new centre notable, with a notable on
        long spokes. Links from outside reach it only at minor nodes; corners go in mirrored pairs."""
        M = self.M
        made = 0
        for cv, rr, fam, has_start in self.emblems:
            c = to_world(0.0, cv, self.ax)
            if has_start or any(n["kind"] == "start" and math.dist((n["x"], n["y"]), c) < rr for n in M.nodes):
                continue        # a start's own frame (the Wind start sits in a blend circle)
            loc = lambda p: to_local((p[0] - c[0], p[1] - c[1]), self.ax)
            outline = {i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and n.get("sk") and not n.get("dead") and math.dist(M.pt(i), c) <= rr + 0.8}
            wheel = next((g for g, gp in enumerate(M.groups) if not gp.get("dead") and gp["shape"].startswith("wheel")
                          and math.dist(gp["centre"], c) < 0.3), None)
            wnodes = set(M.groups[wheel]["nodes"]) if wheel is not None else set()
            S_ = outline | wnodes
            if len(outline) < 4:
                continue
            gid = wheel if wheel is not None else len(M.groups)
            if wheel is None:
                M.groups.append({"shape": "emblem:" + fam, "centre": c, "facing": self.ax, "nodes": [], "region": self.name})
            else:
                M.groups[gid]["shape"] = "emblem:" + fam
            for i in outline:
                M.nodes[i].update(kind="small", cluster=gid, theme=self.theme(c), region=self.name)
            if fam == "circle":
                # the road ring has few nodes: rebuild it with its own (mirrored) nodes plus one every 30 degrees where
                # there is room, arcs redrawn in angle order, so it can spoke inward and stays symmetric
                ring = [i for i in outline if abs(math.dist(M.pt(i), c) - rr) < 0.3]
                for k, e in enumerate(M.edges):
                    if not e.get("dead") and e.get("arc") and e["a"] in ring and e["b"] in ring:
                        e["dead"] = True
                        M.deg[e["a"]] -= 1; M.deg[e["b"]] -= 1
                        M.adj[e["a"]].discard(e["b"]); M.adj[e["b"]].discard(e["a"])
                ang = lambda q: math.degrees(math.atan2(*loc(q))) % 360
                for k in range(12):
                    q_ = to_world(rr * math.sin(math.radians(30 * k)), rr * math.cos(math.radians(30 * k)), self.ax)
                    q_ = (c[0] + q_[0], c[1] + q_[1])
                    if all(math.dist(q_, M.pt(j)) >= 1.0 for j in ring):
                        nid = M.node(q_, "small", self.theme(c), gid, region=self.name)
                        ring.append(nid); outline.add(nid); S_.add(nid)
                ring.sort(key=lambda i: ang(M.pt(i)))
                for x_, y_ in zip(ring, ring[1:] + ring[:1]):
                    M.link(x_, y_, centre=c)
            outside = lambda i: [j for j in M.adj[i] if j not in S_ and not M.nodes[j].get("dead")]
            # spoke sources: outline nodes out on the rim of the figure; those that carry a road (ports) may spoke too,
            # but only through a notable in the middle, so no road ever touches a notable
            corners = [i for i in outline if math.dist(M.pt(i), c) >= 0.55 * rr]
            # mirrored pairs (and corners on the axis)
            pairs, used = [], set()
            for i in sorted(corners, key=lambda i: loc(M.pt(i))[0]):
                if i in used:
                    continue
                u, v = loc(M.pt(i))
                if abs(u) < 0.08:
                    pairs.append((i,)); used.add(i); continue
                twin = next((j for j in corners if j not in used and j != i and abs(loc(M.pt(j))[0] + u) < 0.12 and abs(loc(M.pt(j))[1] - v) < 0.12), None)
                if twin is not None:
                    pairs.append((i, twin)); used |= {i, twin}
            hub = None
            inner = [i for i in outline if math.dist(M.pt(i), c) < 0.55 * rr]      # the emblem's own inner roads (diamond, veins)
            if wheel is None and not any(math.dist(M.pt(j), c) < 0.75 for j in M.near(c, 0.75)):
                ok_in = [j for j in inner if M.fits([], [(c, M.pt(j))], [j])]
                if not inner or len(ok_in) == len(inner):
                    hub = M.node(c, "notable", self.theme(c), gid, region=self.name)
                    S_.add(hub)
                    # a straight link of the figure running through the centre (the spine) is split at the hub
                    for e in list(M.edges):
                        if e.get("dead") or e.get("arc") or e["a"] not in S_ or e["b"] not in S_ or hub in (e["a"], e["b"]):
                            continue
                        pa_, pb_ = M.pt(e["a"]), M.pt(e["b"])
                        vx, vy = pb_[0] - pa_[0], pb_[1] - pa_[1]; L2 = vx * vx + vy * vy
                        t_ = ((c[0] - pa_[0]) * vx + (c[1] - pa_[1]) * vy) / L2 if L2 else 0.0
                        if 0.05 < t_ < 0.95 and math.dist(c, (pa_[0] + t_ * vx, pa_[1] + t_ * vy)) < 0.3:
                            e["dead"] = True
                            M.deg[e["a"]] -= 1; M.deg[e["b"]] -= 1
                            M.adj[e["a"]].discard(e["b"]); M.adj[e["b"]].discard(e["a"])
                            M.link(e["a"], hub); M.link(hub, e["b"])
                    for j in inner:
                        if j not in M.adj[hub]:
                            M.link(hub, j)
            new = []
            wld = lambda u, v: (c[0] + u * math.cos(math.radians(self.ax)) + v * math.sin(math.radians(self.ax)),
                                c[1] - u * math.sin(math.radians(self.ax)) + v * math.cos(math.radians(self.ax)))
            for pr in pairs:
                plans = []
                for n_, i in enumerate(pr):
                    p = M.pt(i)
                    if n_ == 1 and plans:
                        # the twin spokes to the mirror image of its partner's target
                        tu, tv = loc(M.pt(plans[0][1]))
                        mp = wld(-tu, tv)
                        q_id = min(S_, key=lambda j: math.dist(M.pt(j), mp))
                        if math.dist(M.pt(q_id), mp) > 0.1:
                            break
                    elif wnodes:
                        q_id = min(wnodes, key=lambda j: math.dist(M.pt(j), p))
                    elif hub is not None and M.fits([], [(p, M.pt(hub))], [i, hub]):
                        q_id = hub
                    elif inner:
                        q_id = min((j for j in inner if j not in M.adj[i]), key=lambda j: math.dist(M.pt(j), p), default=None)
                        if q_id is None:
                            continue
                    elif hub is not None:
                        q_id = hub
                    else:
                        continue
                    q = M.pt(q_id)
                    L = math.dist(p, q)
                    if L < 1.0:
                        continue
                    if len(pr) == 1 and abs(loc(q)[0]) > 0.08:
                        break           # a corner on the axis spokes only along the axis, or the figure stops mirroring
                    port = bool(outside(i))
                    if port and L < 1.6:
                        break           # too short for a notable in between
                    mid = ((p[0] + q[0]) / 2, (p[1] + q[1]) / 2) if (L >= 2.4 or port) else None
                    pts = [mid] if mid else []
                    segs = [(p, mid), (mid, q)] if mid else [(p, q)]
                    if not M.fits(pts, segs, [i, q_id]):
                        break
                    plans.append((i, q_id, mid))
                else:
                    if len(plans) == 2:     # the twin spokes must not cross each other
                        o = lambda p_, q_, r_: (q_[0] - p_[0]) * (r_[1] - p_[1]) - (q_[1] - p_[1]) * (r_[0] - p_[0])
                        segA = [M.pt(plans[0][0]), M.pt(plans[0][1])]
                        segB = [M.pt(plans[1][0]), M.pt(plans[1][1])]
                        if o(*segA, segB[0]) * o(*segA, segB[1]) < 0 and o(*segB, segA[0]) * o(*segB, segA[1]) < 0:
                            continue
                    if len(plans) == len(pr):
                        for i, q_id, mid in plans:
                            if mid:
                                m_ = M.node(mid, "notable", self.theme(c), gid, region=self.name)
                                M.link(i, m_); M.link(m_, q_id)
                                new.append(m_)
                            else:
                                M.nodes[i]["kind"] = "notable"
                                M.link(i, q_id)
            ids = sorted(S_ | set(new))
            if not any(M.nodes[i]["kind"] == "notable" for i in ids) and inner and not any(math.dist(M.pt(j), c) < 0.75 for j in M.near(c, 0.75)):
                # no free corner (every outer point carries a road): a centre notable spoked to the inner points
                if all(M.fits([], [(c, M.pt(j))], [j]) for j in inner):
                    h_ = M.node(c, "notable", self.theme(c), gid, region=self.name)
                    for j in inner:
                        M.link(h_, j)
                    ids.append(h_)
            if not any(M.nodes[i]["kind"] == "notable" for i in ids):
                # last resort: the innermost road-free node on the axis, or a mirrored pair of road-free nodes
                free = [i for i in ids if not [j for j in M.adj[i] if j not in S_ and j not in ids]]
                axis = [i for i in free if abs(loc(M.pt(i))[0]) < 0.08]
                if axis:
                    M.nodes[min(axis, key=lambda i: math.dist(M.pt(i), c))]["kind"] = "notable"
                else:
                    for i in free:
                        u, v = loc(M.pt(i))
                        tw = next((j for j in free if j != i and abs(loc(M.pt(j))[0] + u) < 0.12 and abs(loc(M.pt(j))[1] - v) < 0.12), None)
                        if tw is not None:
                            M.nodes[i]["kind"] = M.nodes[tw]["kind"] = "notable"
                            break
            M.groups[gid]["nodes"] = ids
            for i in ids:
                M.nodes[i]["cluster"] = gid
            made += 1
        return made

    def keystones(self):
        """Keystones as PoE shows them, red accents in the outer band: at the end of a two-node spur hung straight out
        (on the slot grid) from a lane node near radius 72, a mirrored pair per land, one on a blend's axis."""
        M = self.M
        want = [(1, 72.0), (-1, 72.0)] if self.name in S.LANDS else [(0, 76.0)]
        for side, rv in want:
            cand = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and not n.get("dead") and self.owns(M.pt(i))
                    and (to_local(M.pt(i), self.ax)[0] * side > 2.0 if side else abs(to_local(M.pt(i), self.ax)[0]) < 0.05)]
            cand.sort(key=lambda i: abs(self.lang(M.pt(i))[1] - rv))
            for i in cand[:12]:
                p = M.pt(i)
                f0 = B.ang_of((0.0, 0.0), p)
                for f in (self.snap(f0 + side * d) for d in (30, 45, 15, 60, 0)):
                    q = [(p[0] + d_ * math.sin(math.radians(f)), p[1] + d_ * math.cos(math.radians(f))) for d_ in (1.2, 2.4, 3.7)]
                    segs = list(zip([p] + q[:-1], q))
                    if not all(self.inside(*x) for x in q) or not M.fits(q, segs, [i]):
                        continue
                    if any(math.dist(q[-1], M.pt(j)) < 2.2 for j in M.near(q[-1], 2.2) if j != i):
                        continue      # a keystone keeps a little clearing
                    gid = len(M.groups)
                    ids = [M.node(x, "small", self.theme(x), gid, region=self.name) for x in q[:-1]] + [M.node(q[-1], "keystone", "keystone", gid, region=self.name)]
                    for x, y in zip([i] + ids[:-1], ids):
                        M.link(x, y)
                    M.groups.append({"shape": "keystone spur", "centre": q[-1], "facing": f, "nodes": ids, "region": self.name})
                    break
                else:
                    continue
                break

    def clearance(self, p):
        M = self.M
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

    def holes(self, min_clear):
        out = []
        for r10 in range(int((S.CENTRE_R + 1.5) * 2), int((S.RIM - 1.5) * 2)):
            r = r10 / 2.0
            n = max(1, int(2 * math.radians(self.half) * r / 0.6))
            for k in range(n + 1):
                a = -self.half + 2 * self.half * k / n
                p = to_world(r * math.sin(math.radians(a)), r * math.cos(math.radians(a)), self.ax)
                if not self.inside(*p):
                    continue
                c = self.clearance(p)
                if c >= min_clear:
                    out.append((c, p))
        out.sort(reverse=True)
        return out

    def through_bridges(self, share=0.45):
        """Through shapes bridging two road nodes 3.4-11 apart (any direction, the grid preferred), 4+ steps apart in
        the graph, until about `share` of the region's target is in through groups."""
        M = self.M
        roads = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and not n.get("dead") and self.owns(M.pt(i))
                 and M.deg[i] < JUNCTION_MAX]
        self.rng.shuffle(roads)
        budget = share * self.target
        used = 0
        for a in roads:
            if used >= budget:
                break
            pa = M.pt(a)
            partners = sorted((b for b in M.near(pa, 11.0) if b != a and M.nodes[b]["kind"] == "travel" and M.deg[b] < JUNCTION_MAX
                               and 5.0 <= math.dist(pa, M.pt(b))),
                              key=lambda b: (abs(((B.ang_of(pa, M.pt(b)) - self.ax + 7.5) % 15) - 7.5) > 2.5, self.rng.random()))
            for b in partners[:14]:
                pb = M.pt(b); d = math.dist(pa, pb)
                if M.hops(a, b, THROUGH_HOPS) < THROUGH_HOPS:
                    continue
                f = B.ang_of(pa, pb)
                fit = [nm for nm in THROUGH if 2.0 <= d - BRIDGE_CAT[nm][2] <= 6.0]
                fit.sort(key=lambda nm: (USED[nm], self.rng.random()))
                done = False
                for name in fit[:10]:
                    sh, k_, span = BRIDGE_CAT[name]
                    off = B.R[sh[0][0][0]] + (d - span) / 2
                    c = (pa[0] + (pb[0] - pa[0]) / d * off, pa[1] + (pb[1] - pa[1]) / d * off)
                    ids = M.place(name, sh, c, f, [(a, 0), (b, k_)], self.theme(c), self.inside)
                    if ids:
                        M.groups[-1]["region"] = self.name
                        USED[name] += 1
                        used += len(ids)
                        done = True
                        break
                if done:
                    break
        return used

    def through_pocket(self, a, pa, out):
        """A through shape hung on road node a by its entry; its far exit then runs straight on (1.3-2.4) to a new road
        node joined to the nearest road beyond, 4+ steps away round the graph. Taken back out when no exit fits."""
        M = self.M
        rng = self.rng
        n = rng.choices(list(SIZE_W), weights=list(SIZE_W.values()))[0]
        pool = [x for x in THROUGH if THROUGH_N[x] == n] or list(THROUGH)
        pool.sort(key=lambda x: (USED[x], rng.random()))
        for name in pool[:4]:
            sh, k = THROUGH[name]
            spokes = list(SPOKES)
            rng.shuffle(spokes)
            for kk in sorted(range(12), key=lambda kk: abs(((self.ax + 30 * kk - out) + 180) % 360 - 180))[:6]:
                f = self.ax + 30 * kk
                fx, fy = math.sin(math.radians(f)), math.cos(math.radians(f))
                for sp in spokes[:3]:
                    dd = B.R[sh[0][0][0]] + sp
                    c = (pa[0] + dd * fx, pa[1] + dd * fy)
                    ids = M.place(name, sh, c, f, [(a, 0)], self.theme(c), self.inside)
                    if not ids:
                        continue
                    gid = len(M.groups) - 1
                    M.groups[gid]["region"] = self.name
                    ex = ids[k]
                    p = M.pt(ex)
                    S_ = set(ids)
                    for t in (1.3, 1.8, 2.4):
                        x = (p[0] + t * fx, p[1] + t * fy)
                        if not (self.inside_any or self.inside)(*x) or any(True for _ in M.near(x, 0.8)) or not M.fits([x], [(p, x)], [ex]):
                            continue
                        cands = sorted((j for j in M.near(x, 4.2) if j not in S_ and M.nodes[j]["kind"] == "travel"
                                        and math.dist(x, M.pt(j)) >= 1.0 and M.deg[j] < JUNCTION_MAX),
                                       key=lambda j: (abs(((B.ang_of(x, M.pt(j)) + 7.5) % 15) - 7.5) > 2.0, math.dist(x, M.pt(j))))
                        for j in cands[:5]:
                            if M.hops(a, j, THROUGH_HOPS) < THROUGH_HOPS or not M.fits([x], [(p, x), (x, M.pt(j))], [ex, j]):
                                continue
                            h = M.node(x, "travel", region=self.name)
                            M.link(ex, h); M.link(h, j)
                            USED[name] += 1
                            return True
                    M.kill_group(gid)
        return False

    def bursts(self, min_clear=5.6, most=2):
        """PoE 2's set pieces ("think in constellations"): in the widest open spaces a road hub with the same small
        figure on 4-8 radial spokes, turned about the hub (every petal faces out), the hub joined to the nearest road."""
        M = self.M
        made = 0
        for clr, hole in self.holes(min_clear):
            if made >= most:
                break
            if any(math.dist(hole, M.pt(i)) < min_clear - 0.5 for i in M.near(hole, min_clear - 0.5)):
                continue
            roads = sorted((i for i, nd in enumerate(M.nodes) if nd["kind"] == "travel" and not nd.get("dead") and M.deg[i] < JUNCTION_MAX),
                           key=lambda i: math.dist(M.pt(i), hole))[:4]
            if not roads:
                continue
            base = B.ang_of(hole, M.pt(roads[0]))
            sets = [[base + k * 60 for k in range(1, 6)], [base + 45 + k * 90 for k in range(4)] + [base + 180],
                    [base + k * 45 for k in range(1, 8)], [base + 90, base - 90, base + 180, base + 30, base - 30, base + 150, base - 150]]
            names = [x for x in CAT if 3 <= CAT_N[x] <= 6 and CAT_R[x] <= B.R[3] + 1e-6]
            self.rng.shuffle(names)
            names.sort(key=lambda x: USED[x])
            done = False
            for name in names[:12]:
                sh = CAT[name]
                for angs in sets:
                    for sp in (1.6, 2.1, 2.6):
                        dd = B.R[sh[0][0][0]] + sp
                        if dd + CAT_R[name] + 0.8 > clr:
                            continue
                        plans = []
                        for a in angs:
                            c = (hole[0] + dd * math.sin(math.radians(a)), hole[1] + dd * math.cos(math.radians(a)))
                            plans.append((a, c))
                        if not all(M.place(name, sh, c, a, [], self.theme(c), self.inside, dry=True) for a, c in plans):
                            continue
                        road = next((r_ for r_ in roads if 1.0 <= math.dist(hole, M.pt(r_)) <= 7.0
                                     and M.fits([], [(hole, M.pt(r_))], [r_])), None)
                        if road is None:
                            continue
                        hub = M.node(hole, "travel", region=self.name)
                        L_ = math.dist(hole, M.pt(road))
                        nmid = max(0, int(round(L_ / B.LANE_STEP)) - 1)
                        chain = [hub] + [M.node((hole[0] + (M.pt(road)[0] - hole[0]) * t / (nmid + 1), hole[1] + (M.pt(road)[1] - hole[1]) * t / (nmid + 1)),
                                                "travel", region=self.name) for t in range(1, nmid + 1)] + [road]
                        for u_, v_ in zip(chain, chain[1:]):
                            M.link(u_, v_)
                        got = 0
                        for a, c in plans:
                            P, _ = M.plan(sh, c, a)
                            e = P[0]
                            if not (B.LINK_MIN <= math.dist(hole, e) <= B.LINK_MAX):
                                continue
                            if M.place(name, sh, c, a, [(hub, 0)], self.theme(c), self.inside):
                                M.groups[-1]["region"] = self.name
                                USED[name] += 1
                                got += 1
                        made += 1
                        done = True
                        break
                    if done:
                        break
                if done:
                    break
        return made

    def wheels_in_holes(self, min_clear, sizes):
        M = self.M
        tried = set()
        while self.count() < self.target:
            hs = [h for h in self.holes(min_clear) if (round(h[1][0], 1), round(h[1][1], 1)) not in tried]
            if not hs:
                break
            clr, hole = hs[0]
            tried.add((round(hole[0], 1), round(hole[1], 1)))
            done = False
            names = list(sizes) if sizes else []
            if not names:
                fit = [x for x in CAT if HOLE_SIZES[0] <= CAT_N[x] <= HOLE_SIZES[1] and CAT_R[x] + 0.9 <= clr]
                fit.sort(key=lambda x: (USED[x], abs(CAT_N[x] - 8), x))
                names = fit[:6]
            for name in names:
                Rw = B.R[B.WHEELS[name][0][0][0]]
                if max(B.R[c_] for c_, _, _ in B.WHEELS[name][0]) + 0.9 > clr:
                    continue
                paths = sorted((i for i, nd in enumerate(M.nodes) if nd["kind"] == "travel" and not nd.get("dead") and M.deg[i] < 5),
                               key=lambda i: math.dist(M.pt(i), hole))[:6]
                for p_id in paths:
                    p = M.pt(p_id)
                    f = self.snap(B.ang_of(p, hole))
                    D = math.dist(p, hole)
                    c = (p[0] + D * math.sin(math.radians(f)), p[1] + D * math.cos(math.radians(f)))
                    if self.build_wheel(name, c, f, [(p_id, 0)]):
                        USED[name] += 1
                        done = True
                        break
                if done:
                    break

    # -- small groups --------------------------------------------------------------------------------------------------
    def grow(self, near=None, upto=None):
        """near: only grow from road nodes whose position passes near(p); upto: stop at this many nodes."""
        M = self.M
        upto = upto or self.target
        for _ in range(400):
            if self.count() >= upto:
                break
            adjacency = collections.defaultdict(set)
            for e in M.edges:
                if not e.get("dead"):
                    adjacency[e["a"]].add(e["b"]); adjacency[e["b"]].add(e["a"])

            def hops(a, b, limit=6):
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
            anchors = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and not n.get("dead") and M.deg[i] < JUNCTION_MAX and self.owns(M.pt(i))
                       and (near is None or near(M.pt(i)))]
            anchors.sort(key=lambda i: self.lang(M.pt(i))[1])
            partners = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and not n.get("dead") and M.deg[i] < 5]
            placed = 0
            for a in anchors:
                if self.count() >= upto:
                    break
                pa = M.pt(a)
                for b in partners:
                    if b == a or b in adjacency[a]:
                        continue
                    pb = M.pt(b); d = math.dist(pa, pb)
                    if not (3.4 <= d <= BRIDGE_MAX):
                        continue
                    f = B.ang_of(pa, pb); fs = self.snap(f)
                    if abs(((f - fs) + 180) % 360 - 180) > 2.5 or hops(a, b) < 4:
                        continue
                    done = False
                    # catalogue bridges whose spokes come out between 1.0 and 3.0 each end, least used first
                    fit = [nm for nm, (sh, k_, span) in BRIDGE_CAT.items() if 2.0 <= d - span <= 6.0]
                    self.rng.shuffle(fit)
                    fit.sort(key=lambda nm: USED[nm])
                    for name in fit[:10]:
                        sh, k_, span = BRIDGE_CAT[name]
                        off = B.R[sh[0][0][0]] + (d - span) / 2
                        ux, uy = (pb[0] - pa[0]) / d, (pb[1] - pa[1]) / d
                        c = (pa[0] + ux * off, pa[1] + uy * off)
                        if M.place(name, sh, c, f, [(a, 0), (b, k_)], self.theme(c), self.inside_any or self.inside):
                            M.groups[-1]["region"] = self.name
                            USED[name] += 1
                            done = True
                            placed += 1
                            break
                    if done:
                        break
            for a in anchors:
                if self.count() >= upto:
                    break
                pa = M.pt(a)
                out = B.ang_of(self.origin, pa)
                done = False
                if self.rng.random() < THROUGH_SHARE and self.through_pocket(a, pa, out):
                    placed += 1
                    continue
                for name in self.pick_shapes(8):
                    shape = CAT[name]
                    spokes = list(SPOKES)
                    self.rng.shuffle(spokes)
                    for k in sorted(range(12), key=lambda k: abs(((self.ax + 30 * k - out) + 180) % 360 - 180)):
                        f = self.ax + 30 * k
                        for sp in spokes:
                            dd = B.R[shape[0][0][0]] + sp
                            c = (pa[0] + dd * math.sin(math.radians(f)), pa[1] + dd * math.cos(math.radians(f)))
                            if M.place(name, shape, c, f, [(a, 0)], self.theme(c), self.inside):
                                M.groups[-1]["region"] = self.name
                                USED[name] += 1
                                done = True
                                placed += 1
                                if self.rng.random() < PAIR_TRY:      # rule 6: now and then the same figure mirrored across the road
                                    f2 = f + 180.0
                                    c2 = (pa[0] + dd * math.sin(math.radians(f2)), pa[1] + dd * math.cos(math.radians(f2)))
                                    if M.place(name, shape, c2, f2, [(a, 0)], self.theme(c2), self.inside):
                                        M.groups[-1]["region"] = self.name
                                        USED[name] += 1
                                        placed += 1
                                break
                        if done:
                            break
                    if done:
                        break
            if not placed:
                break


RAY = ([(3, 180, "s"), (0, 0, "s"), (3, 0, "s"), (5, 0, "N")], [(0, 1, 0), (1, 2, 0), (2, 3, 0)])


class Disc(Region):
    """A region shaped as a disc round C: the Chaos centre, or an island. Filled with wheels in its open spaces and
    small groups on its roads; Light first gets its rays (straight groups pointing out from the sun's ring)."""

    def __init__(self, M, name, C, radius, ax, themes, target, clear_r=1.6):
        self.M, self.name, self.ax = M, name, ax
        self.C, self.radius, self.clear_r = C, radius, clear_r
        self.emblems, self.themes, self.target = [], themes, target
        self.half, self.lane_angle = 180.0, 0.0
        self.inside_any = None
        self.origin = C
        self.rng = random.Random(name)

    def lang(self, p):
        u, v = to_local((p[0] - self.C[0], p[1] - self.C[1]), self.ax)
        return math.degrees(math.atan2(u, v)), math.hypot(u, v)

    def inside(self, x, y):
        d = math.dist((x, y), self.C)
        if not (self.clear_r < d < self.radius - 0.4):
            return False
        return ((self.name == "hub" or math.hypot(x, y) > S.RIM + 1.2) and key_clear(x, y)      # islands stay outside the rim
                and (not DISC_MARGIN or clear_of_roads(x, y, DISC_MARGIN)))       # a thinner margin: their roads are dense

    def owns(self, p):
        return math.dist(p, self.C) <= self.radius + 0.5 and (self.name == "hub" or math.hypot(*p) > S.RIM + 0.5)

    def theme(self, p):
        a, r = self.lang(p)
        k = int(((a + 180) % 360) // 60)
        return self.themes[k % len(self.themes)]

    def holes(self, min_clear):
        out = []
        r = self.clear_r + 1.0
        while r < self.radius - 1.0:
            n = max(6, int(2 * math.pi * r / 0.6))
            for k in range(n):
                t = 2 * math.pi * k / n
                p = (self.C[0] + r * math.sin(t), self.C[1] + r * math.cos(t))
                if self.inside(*p):
                    c = self.clearance(p)
                    if c >= min_clear:
                        out.append((c, p))
            r += 0.5
        out.sort(reverse=True)
        return out

    def rays(self, ring_r):
        """Light's rays: a straight 4-node group straight out from every road node of the sun's ring."""
        M = self.M
        for i, n in enumerate(M.nodes):
            if n["kind"] != "travel" or abs(math.dist(M.pt(i), self.C) - ring_r) > 0.3:
                continue
            f = B.ang_of(self.C, M.pt(i))
            if abs(((f - self.ax - 180) + 180) % 360 - 180) < 30:
                continue      # the side facing the tree keeps the bridge clear
            dd = B.R[3] + 1.15
            p = M.pt(i)
            c = (p[0] + dd * math.sin(math.radians(f)), p[1] + dd * math.cos(math.radians(f)))
            if M.place("ray", RAY, c, f, [(i, 0)], self.theme(c), self.inside):
                M.groups[-1]["region"] = self.name


def build():
    g0, _ = sketch_a2.variant_a2()
    M = B.Mesh()
    m = {}
    st0 = [n for n in g0.nodes if n["kind"] == "start"]

    def reshape(n):
        """None to leave the node out, else its (x, y): close round a start, cleared or pushed out (starts.RESHAPE)."""
        for s_ in st0:
            if n is s_ or not STARTS:
                continue
            rad, k = starts.RESHAPE.get(starts.key_of(s_.get("name")), (0.0, 0.0))
            d = math.dist((n["x"], n["y"]), (s_["x"], s_["y"]))
            if d < rad:
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
            M.nodes[-1]["sk"] = True        # drawn by the A2 sketch (emblem outlines are made of these)
    sids = {n["id"] for n in st0 if starts.key_of(n.get("name"))}
    for e in g0.edges:
        if e["a"] in m and e["b"] in m and not (STARTS and (e["a"] in sids or e["b"] in sids)):
            M.link(m[e["a"]], m[e["b"]], centre=tuple(e["arc"]) if e.get("arc") else None)
    if STARTS:      # every start's own constellation (starts.py), drawn before anything else claims the space
        for n in st0:
            if n["id"] in sids:
                starts.draw(M, m[n["id"]], n["region"], START_THEME.get(n["region"], n["region"]))
    regions = [Region(M, name, ax) for name, ax in list(S.LANDS.items()) + list(S.BLENDS.items())]
    discs = [Disc(M, "hub", (0.0, 0.0), S.CENTRE_R, 0.0, ("chaos", "health", "chaos", "linh", "chaos", "insight"), int(500 * NODE_SCALE), clear_r=START_VOID),
             Disc(M, "light", S.pol(S.RIM + 28.0, 0.0), 23.0, 0.0, ("light", "light", "lifespan", "light", "light", "heart"), int(530 * NODE_SCALE), clear_r=START_VOID),
             Disc(M, "thunder", S.pol(S.RIM + 25.0, 252.0), 21.0, 252.0, ("thunder", "thunder", "crit", "thunder", "thunder", "sense"), int(550 * NODE_SCALE), clear_r=START_VOID),
             Disc(M, "darkness", S.pol(S.RIM + 25.0, 180.0), 21.0, 180.0, ("dark", "dark", "ward", "dark", "dark", "insight"), int(550 * NODE_SCALE), clear_r=START_VOID)]
    ph = [0]

    def mark(name):      # tag the links drawn since the last mark with the phase that drew them (for measuring)
        for e in M.edges[ph[0]:]:
            e.setdefault("ph", name)
        ph[0] = len(M.edges)
    mark("sketch")
    _sample_sketch(M, len(M.edges))
    # the Shadow Shrine (sketch_a2: a 12-node ring at 103 degrees on the moon's arm), filled as a small disc of its own
    ring = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and n.get("region") == "darkness"
            and abs(((math.degrees(math.atan2(n["x"], n["y"])) - 103.0) + 180) % 360 - 180) < 9 and math.hypot(n["x"], n["y"]) > S.RIM + 8]
    if SHRINE and ring:
        sc = (sum(M.pt(i)[0] for i in ring) / len(ring), sum(M.pt(i)[1] for i in ring) / len(ring))
        discs.append(Disc(M, "shrine", sc, SHRINE_R, 103.0, ("shadow", "shadow", "insight", "shadow", "shadow", "dark"), int(SHRINE_TARGET * NODE_SCALE), clear_r=0.8))
    every = regions + discs
    inside_any = lambda x, y: any(R_.inside(x, y) for R_ in every)
    for R_ in every:
        R_.inside_any = inside_any
    for R_ in regions:
        R_.lattice()
    mark("lattice")
    for R_ in regions:
        R_.emblem_wheels()
    if EMBLEM_DESIGNS:
        print("emblem set pieces (drawn)", sum(R_.emblem_designed() for R_ in regions))
    elif EMBLEM_CLUSTERS:
        print("emblem set pieces", sum(R_.emblem_clusters() for R_ in regions))
    mark("emblem")
    if KEYSTONES_V2:
        place_keystones(M, every, [M.pt(i) for i, n in enumerate(M.nodes) if n["kind"] == "start"])
    else:
        for R_ in regions:
            R_.keystones()
    mark("keystone")
    if OUTER_BAND:
        outer_band(M, regions, discs)
    mark("outer band")
    if DARK_ARMS:
        dark_arms(M, discs)
    mark("dark arms")
    print("authored in the lands", sum(authored_pass(M, R_) for R_ in regions))
    mark("authored")
    if BURSTS:
        nb = sum(R_.bursts() for R_ in regions)
        print("bursts", nb)
    mark("bursts")
    for R_ in regions:
        R_.wheels_in_holes(4.4, ())
    mark("holes")
    if THROUGH_BRIDGES:
        print("through bridges", sum(int(R_.through_bridges()) for R_ in regions))
    mark("through")
    for R_ in regions:      # the outer band first, so groups reach past the rim and the rim is not the edge
        R_.grow(near=lambda p: math.hypot(*p) > S.RIM - 0.5, upto=R_.count() + int(0.10 * R_.target))
    mark("outer")
    for R_ in regions:
        R_.grow()
    mark("grow")
    for R_ in regions:
        if R_.count() < R_.target:
            R_.wheels_in_holes(3.2, ())
            R_.grow()
    mark("refill")
    cap_lands = B.DENSITY_CAP
    B.DENSITY_CAP = 0       # Chaos and the islands keep their 400-500 (user: "400-500 is fine"); the cap is for the lands
    discs[1].rays(13.0)
    for R_ in discs:
        R_.wheels_in_holes(4.0, ())
        R_.grow()
        if R_.count() < R_.target:
            R_.wheels_in_holes(3.0, ())
            R_.grow()
    global DISC_MARGIN
    keep_margin = DISC_MARGIN
    DISC_MARGIN = 0.45          # top-up: a still thinner margin only where a disc is under its target
    for R_ in discs if DISC_TOPUP else ():
        if R_.count() < R_.target:
            R_.grow()
    DISC_MARGIN = keep_margin
    B.DENSITY_CAP = cap_lands
    mark("discs")
    if WEAVE:
        _MARGIN_ON[0] = False       # the weave draws road nodes, which may run beside the roads
        weave(M, inside_any)
        _MARGIN_ON[0] = True
    mark("weave")
    merge_close(M)
    if OPEN_RIM:
        open_rim(M)
    uncross(M)
    final_check(M)
    for n in M.nodes:       # nodes drawn by lanes and pockets carry the Mesh default region; set it from the position
        p = (n["x"], n["y"])
        own = next((R_ for R_ in discs if R_.owns(p)), None) or next((R_ for R_ in regions if R_.owns(p)), None)
        if own:
            n["region"] = own.name
    return M, {R_.name: R_.count() for R_ in every}


def _authored_at(M, i, f, names, inside, region, theme, spokes=(1.6, 2.2, 2.8)):
    """Hang the first of names that fits on road node i, facing f; returns the name or None."""
    p = M.pt(i)
    for name in names:
        S_ = AUTH[name]
        e = -S_.nodes[0][1]
        for sp in spokes:
            dd = e + sp
            c = (p[0] + dd * math.sin(math.radians(f)), p[1] + dd * math.cos(math.radians(f)))
            if B.place_xy(M, name, S_.nodes, S_.links, c, f, [(i, 0)], theme, inside, region):
                USED[name] += 1
                return name
    return None


def place_compound(M, a, f, comps, inside, region, theme):
    """A pattern of 2-3 authored clusters (authored.COMPOUNDS) round a small road hub 2.0 out from road node a along f,
    each cluster entered from the hub; all or nothing. Returns the hub or None."""
    pa = M.pt(a)
    C = (pa[0] + 2.0 * math.sin(math.radians(f)), pa[1] + 2.0 * math.cos(math.radians(f)))
    if not inside(*C) or any(True for _ in M.near(C, B.SPACING)) or not M.fits([C], [(pa, C)], [a]):
        return None
    h = M.node(C, "travel", region=region)
    M.link(a, h)
    made = []
    for nm, rel in comps:
        if not _authored_at(M, h, f + rel, [nm], inside, region, theme, spokes=(1.6, 2.0)):
            break
        made.append(len(M.groups) - 1)
    else:
        return h
    for g in made:
        M.kill_group(g)
    for k, e in enumerate(M.edges):
        if not e.get("dead") and h in (e["a"], e["b"]):
            e["dead"] = True
            M.deg[e["a"]] -= 1; M.deg[e["b"]] -= 1
            M.adj[e["a"]].discard(e["b"]); M.adj[e["b"]].discard(e["a"])
    M.nodes[h]["dead"] = True
    return None


def authored_pass(M, R_):
    """User 2026-11-16: "think of more patterns ... 2 clusters that sort of combined, and 3 is okay". Before the
    generated growth, hand-authored shapes and 2-3-cluster patterns go on the land's road nodes, up to AUTH_SHARE of
    its target, facing out from the centre where they fit (the 30-degree slots of the land's axis)."""
    med = [n for n in AUTH if n != "Lone notable" and n not in authored.BIG and len(AUTH[n].nodes) <= 10]        # PoE 2: 90 % of clusters hold 9 or fewer
    pats = [c for c in authored.COMPOUNDS + authored.COMPOUNDS_SMALL if all(len(AUTH[nm].nodes) <= 12 for nm, _ in c[1])]
    budget = AUTH_SHARE * R_.target
    used = 0
    roads = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and not n.get("dead") and R_.owns(M.pt(i)) and M.deg[i] < JUNCTION_MAX]
    R_.rng.shuffle(roads)
    for i in roads:
        if used >= budget:
            break
        p = M.pt(i)
        out = B.ang_of(R_.origin, p)
        dirs = sorted((R_.ax + 30 * k for k in range(12)), key=lambda f: abs(((f - out) + 180) % 360 - 180))[:5]
        for f in dirs:
            if R_.rng.random() < 0.35:
                # patterns made only of lone notables stay rare (PoE 2: 22 lone notables in 661 clusters)
                comps = min(pats, key=lambda c: (USED[c[0]] * (4 if all(nm == "Lone notable" for nm, _ in c[1]) else 1), R_.rng.random()))
                if place_compound(M, i, f, comps[1], R_.inside, R_.name, R_.theme(p)):
                    USED[comps[0]] += 1
                    used += sum(len(AUTH[nm].nodes) for nm, _ in comps[1]) + 1
                    break
            else:
                got = _authored_at(M, i, f, sorted(med, key=lambda n: (USED[n], R_.rng.random())), R_.inside, R_.name, R_.theme(p))
                if got:
                    used += len(AUTH[got].nodes)
                    break
    return int(used)


def outer_band(M, regions, discs):
    """User 2026-11-15: PoE puts many clusters outside its outer ring, the biggest and strongest there. The rim road
    stays whole; big authored set pieces hang straight out from it every OB_BIG_EVERY degrees or so, medium authored
    shapes between them, out to OB_DEPTH past the rim and clear of the islands."""
    big = [n for n in AUTH if n in authored.BIG]
    med = [n for n in AUTH if n != "Lone notable" and n not in authored.BIG]

    def inside(x, y):
        r = math.hypot(x, y)
        if not (S.RIM + 1.0 < r < S.RIM + OB_DEPTH):
            return False
        return all(math.dist((x, y), D.C) > D.radius + 1.5 for D in discs) and key_clear(x, y)
    rim = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and n.get("sk") and not n.get("dead") and abs(math.hypot(*M.pt(i)) - S.RIM) < 0.3]
    rim.sort(key=lambda i: math.degrees(math.atan2(*M.pt(i))) % 360)
    last_big, nb, nm = -1e9, 0, 0
    for i in rim:
        p = M.pt(i)
        a = math.degrees(math.atan2(*p)) % 360
        own = next((R_ for R_ in regions if abs(R_.lang(p)[0]) <= R_.half + 0.5), regions[0])
        names = sorted(big if a - last_big >= OB_BIG_EVERY else med, key=lambda n: (USED[n], n))
        got = _authored_at(M, i, a, names, inside, own.name, own.theme(p))
        if got in big:
            last_big = a; nb += 1
        elif got:
            nm += 1
    print("outer band: big", nb, "medium", nm)


def dark_arms(M, discs):
    """User 2026-11-15: the arms to the Darkness moon and on to the Shadow Shrine carry too many bare travel nodes.
    Every other plain chain node on them goes (its two arcs or lines become one), and authored shapes hang from the
    rest, facing out and in by turns."""
    off = lambda p: all(math.dist(p, d.C) > d.radius + 0.5 for d in discs if d.name in ("darkness", "shrine"))
    arm = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and n.get("sk") and not n.get("dead") and n.get("region") == "darkness"
           and off(M.pt(i)) and math.hypot(*M.pt(i)) > S.RIM + 0.5]
    arm.sort(key=lambda i: (round(math.hypot(*M.pt(i))), math.degrees(math.atan2(*M.pt(i))) % 360))
    cut, skip = 0, False
    for i in arm:
        live = [k for k, e in enumerate(M.edges) if not e.get("dead") and i in (e["a"], e["b"])]
        if skip or len(live) != 2:
            skip = False
            continue
        e1, e2 = M.edges[live[0]], M.edges[live[1]]
        a = e1["a"] if e1["b"] == i else e1["b"]
        b = e2["a"] if e2["b"] == i else e2["b"]
        same_arc = bool(e1.get("arc") and e2.get("arc") and math.dist(e1["arc"], e2["arc"]) < 0.05)
        cross = (M.pt(a)[0] - M.pt(i)[0]) * (M.pt(b)[1] - M.pt(i)[1]) - (M.pt(a)[1] - M.pt(i)[1]) * (M.pt(b)[0] - M.pt(i)[0])
        straight = not e1.get("arc") and not e2.get("arc") and abs(cross) < 0.05
        if not (same_arc or straight) or b in M.adj[a]:
            continue
        for e in (e1, e2):
            e["dead"] = True
            M.deg[e["a"]] -= 1; M.deg[e["b"]] -= 1
            M.adj[e["a"]].discard(e["b"]); M.adj[e["b"]].discard(e["a"])
        M.nodes[i]["dead"] = True
        M.link(a, b, centre=tuple(e1["arc"]) if same_arc else None)
        cut += 1
        skip = True
    med = [n for n in AUTH if n != "Lone notable" and n not in authored.BIG]

    def inside(x, y):
        r = math.hypot(x, y)
        return r > S.RIM + 1.5 and all(math.dist((x, y), d.C) > d.radius + 1.0 for d in discs) and key_clear(x, y)
    hung, out = 0, True
    for i in arm:
        if M.nodes[i].get("dead"):
            continue
        p = M.pt(i)
        a = math.degrees(math.atan2(*p))
        for f in ((a, a + 180) if out else (a + 180, a)):
            if _authored_at(M, i, f, sorted(med, key=lambda n: (USED[n], n)), inside, "darkness", "dark"):
                hung += 1
                out = not out
                break
    print("dark arms: travel nodes taken out", cut, "shapes hung", hung)


def place_keystones(M, every, starts_xy):
    """Reserve the keystone sites before the groups grow (K1-K6 above): per region about KEY_SHARE of its target,
    picked greedily from its road nodes in a seeded shuffle, outer half first."""
    import random
    total = 0
    for R_ in every:
        want = max(1, int(round(KEY_SHARE * R_.target)))
        rng = random.Random("keys-" + R_.name)
        roads = [i for i, n in enumerate(M.nodes) if n["kind"] == "travel" and not n.get("dead") and R_.owns(M.pt(i))]
        rng.shuffle(roads)
        if isinstance(R_, Disc):
            outer = lambda p: True
        else:
            outer = lambda p: R_.lang(p)[1] >= 45.0
        n_inner = 0
        got = 0
        for phase in ("outer", "inner"):
            for i in roads:
                if got >= want:
                    break
                p = M.pt(i)
                if (phase == "outer") != outer(p):
                    continue
                if phase == "inner" and n_inner >= max(1, int(round(KEY_INNER * want))):
                    break
                f0 = B.ang_of(R_.origin, p)
                for f in sorted((R_.ax + 15 * k for k in range(24)), key=lambda f: abs(((f - f0) + 180) % 360 - 180)):
                    q = (p[0] + KEY_LINK * math.sin(math.radians(f)), p[1] + KEY_LINK * math.cos(math.radians(f)))
                    if not R_.inside(*q) or any(math.dist(q, s_) < KEY_FROM_START for s_ in starts_xy):
                        continue
                    if any(math.dist(q, k) < KEY_MIN for k in KEYS):
                        break
                    if any(j != i for j in M.near(q, KEY_CLEAR + 0.2)) or not M.fits([q], [(p, q)], [i]):
                        continue
                    gid = len(M.groups)
                    k_id = M.node(q, "keystone", "keystone", gid, region=R_.name)
                    M.link(i, k_id)
                    M.groups.append({"shape": "keystone", "centre": q, "facing": f, "nodes": [k_id], "region": R_.name})
                    KEYS.append(q)
                    got += 1
                    n_inner += phase == "inner"
                    break
        total += got
    print("keystones", total)


def merge_close(M, gap=0.72):
    """Road nodes that ended up closer than `gap` (a lane stop beside a sketch node): merge the pair into the one
    that carries arcs or joins a group (so curves and group mirrors stay exact), moving the other's straight links
    over; a merge whose moved links would cross anything is left undone."""
    def live_edges(i):
        return [k for k, e in enumerate(M.edges) if not e.get("dead") and i in (e["a"], e["b"])]
    merged = 0
    for i, n in enumerate(M.nodes):
        if n.get("dead") or n["kind"] != "travel":
            continue
        for j in list(M.near(M.pt(i), gap)):
            m = M.nodes[j]
            if j == i or m.get("dead") or m["kind"] != "travel":
                continue
            fixed = lambda x: any(M.edges[k].get("arc") or M.nodes[M.edges[k]["a"] if M.edges[k]["b"] == x else M.edges[k]["b"]].get("cluster") is not None
                                  for k in live_edges(x))
            fi, fj = fixed(i), fixed(j)
            if fi and fj:
                continue
            keep, drop = (i, j) if fi or (not fj and M.deg[i] >= M.deg[j]) else (j, i)
            nbr = {M.edges[k]["a"] if M.edges[k]["b"] == keep else M.edges[k]["b"] for k in live_edges(keep)}
            ks = live_edges(drop)
            others = [M.edges[k]["a"] if M.edges[k]["b"] == drop else M.edges[k]["b"] for k in ks]
            for k in ks:
                M.edges[k]["dead"] = True
            new = [o for o in others if o != keep and o not in nbr]
            if all(M.fits([], [(M.pt(keep), M.pt(o))], [keep, o]) for o in new):
                for k in ks:
                    M.deg[M.edges[k]["a"]] -= 1; M.deg[M.edges[k]["b"]] -= 1
                for o in set(new):
                    M.link(keep, o)
                M.nodes[drop]["dead"] = True
                merged += 1
                if drop == i:
                    break
            else:
                for k in ks:
                    M.edges[k]["dead"] = False
    print("merged close road nodes", merged)


UNCROSS_DEBUG = False


def uncross(M, local=20):
    """Any two links still crossing (arcs sampled): take out the lane or weave link of the pair when its ends stay
    joined within `local` steps another way."""
    o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    adj = collections.defaultdict(set)
    for e in M.edges:
        if not e.get("dead"):
            adj[e["a"]].add(e["b"]); adj[e["b"]].add(e["a"])
    hits = set()
    for cell, ks in M.egrid.items():
        ks = [k for k in ks if not M.edges[k].get("dead")]
        for x in range(len(ks)):
            for y in range(x + 1, len(ks)):
                e1, e2 = M.edges[ks[x]], M.edges[ks[y]]
                if {e1["a"], e1["b"]} & {e2["a"], e2["b"]}:
                    continue
                for p1, p2 in zip(M.poly[ks[x]], M.poly[ks[x]][1:]):
                    if any(o(p1, p2, p3) * o(p1, p2, p4) < -1e-12 and o(p3, p4, p1) * o(p3, p4, p2) < -1e-12
                           for p3, p4 in zip(M.poly[ks[y]], M.poly[ks[y]][1:])):
                        hits.add(tuple(sorted((ks[x], ks[y]))))
                        break
    rank = {"lattice": 0, "weave": 1, "bursts": 2, "grow": 3, "outer": 3, "holes": 4, "discs": 4, "emblem": 5, "keystone": 5, "sketch": 9}
    cut = 0
    for k1, k2 in hits:
        if M.edges[k1].get("dead") or M.edges[k2].get("dead"):
            continue
        for k in sorted((k1, k2), key=lambda k: rank.get(M.edges[k].get("ph"), 3)):
            e = M.edges[k]
            a, b = e["a"], e["b"]
            if M.nodes[a].get("cluster") is not None and M.nodes[a].get("cluster") == M.nodes[b].get("cluster") and e.get("ph") != "lattice":
                continue        # never inside a group (but a lane across an emblem is not part of its figure)
            adj[a].discard(b); adj[b].discard(a)
            seen = {a: 0}; q = collections.deque([a]); ok = False
            lim = local if rank.get(e.get("ph"), 3) > 0 else 10 ** 9      # a lane link may go whenever its ends stay joined at all
            while q and not ok:
                u = q.popleft()
                if seen[u] >= lim:
                    continue
                for v in adj[u]:
                    if v not in seen:
                        seen[v] = seen[u] + 1; q.append(v)
                        if v == b:
                            ok = True
                            break
            if ok:
                e["dead"] = True
                M.deg[a] -= 1; M.deg[b] -= 1
                cut += 1
                break
            if e.get("ph") == "lattice":
                # the far side may be only a short stub of lane: take it out with the link
                for end in (b, a):
                    comp = {end}; q2 = [end]
                    for u in q2:
                        for v in adj[u]:
                            if v not in comp:
                                comp.add(v); q2.append(v)
                        if len(comp) > 6:
                            break
                    if len(comp) <= 6 and all(M.nodes[x]["kind"] == "travel" for x in comp):
                        e["dead"] = True
                        M.deg[a] -= 1; M.deg[b] -= 1
                        for x in comp:
                            M.nodes[x]["dead"] = True
                            for k3, e3 in enumerate(M.edges):
                                if not e3.get("dead") and x in (e3["a"], e3["b"]):
                                    e3["dead"] = True
                                    M.deg[e3["a"]] -= 1; M.deg[e3["b"]] -= 1
                        cut += 1
                        ok = True
                        break
                if ok:
                    break
            adj[a].add(b); adj[b].add(a)
        else:
            if UNCROSS_DEBUG:
                for k in (k1, k2):
                    e = M.edges[k]
                    print("   left:", e.get("ph"), M.nodes[e["a"]]["kind"], M.nodes[e["b"]]["kind"], M.nodes[e["a"]].get("cluster"), M.nodes[e["b"]].get("cluster"),
                          [round(x, 1) for x in M.pt(e["a"])], [round(x, 1) for x in M.pt(e["b"])], "arc" if e.get("arc") else "")
    print("uncross: crossings", len(hits), "links taken out", cut)


def final_check(M):
    """Safety net: any group that fails the cluster rules, or whose own links still cross another group's, is taken
    out (it was drawn last of the two)."""
    import cluster_rules as CR
    live = [e for e in M.edges if not e.get("dead")]
    d = {"nodes": [n for n in M.nodes if not n.get("dead")], "edges": live,
         "clusters": [{"id": k, "form": gp["shape"], "name": gp["shape"]} for k, gp in enumerate(M.groups)]}
    G = CR.Graph(d)
    bad = set()
    for c in G.mem:
        r = CR.check_cluster(G, c)
        if not all(r[k] in (True, None) for k in ("R0", "R1", "R2", "R3", "R4")):
            bad.add(c)
    o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    for cell, ks in M.egrid.items():
        ks = [k for k in ks if not M.edges[k].get("dead")]
        for x in range(len(ks)):
            for y in range(x + 1, len(ks)):
                e1, e2 = M.edges[ks[x]], M.edges[ks[y]]
                if {e1["a"], e1["b"]} & {e2["a"], e2["b"]}:
                    continue
                if any(o(p1, p2, p3) * o(p1, p2, p4) < -1e-12 and o(p3, p4, p1) * o(p3, p4, p2) < -1e-12
                       for p1, p2 in zip(M.poly[ks[x]], M.poly[ks[x]][1:]) for p3, p4 in zip(M.poly[ks[y]], M.poly[ks[y]][1:])):
                    gs = [M.nodes[e["a"]].get("cluster") for e in (e1, e2) if M.nodes[e["a"]].get("cluster") is not None
                          and M.nodes[e["a"]].get("cluster") == M.nodes[e["b"]].get("cluster")]
                    gs = [g for g in gs if not M.groups[g]["shape"].startswith(("start:", "emblem:"))]
                    if gs:
                        bad.add(max(gs))
    for g in bad:
        if not M.groups[g]["shape"].startswith(("start:", "emblem:")):     # these carry roads: report, never remove
            M.kill_group(g)
        else:
            print("  set piece fails the rules:", M.groups[g]["shape"], M.groups[g].get("region"))
    print("final check: groups taken out", len(bad))


def open_rim(M, local=14):
    """PoE has no outer ring road. Take out each arc of the rim road whose two ends stay joined within `local` steps by
    another way (through the groups now woven across it), then road stubs left hanging off a road node."""
    adj = collections.defaultdict(set)
    for e in M.edges:
        if not e.get("dead"):
            adj[e["a"]].add(e["b"]); adj[e["b"]].add(e["a"])
    on_rim = lambda i: abs(math.hypot(*M.pt(i)) - S.RIM) < 0.3
    rim = [k for k, e in enumerate(M.edges) if not e.get("dead") and e.get("arc") and abs(e["arc"][0]) < 1e-6 and abs(e["arc"][1]) < 1e-6
           and on_rim(e["a"]) and on_rim(e["b"])]

    def near_path(a, b):
        seen = {a: 0}; q = collections.deque([a])
        while q:
            u = q.popleft()
            if seen[u] >= local:
                continue
            for v in adj[u]:
                if v not in seen:
                    seen[v] = seen[u] + 1
                    if v == b:
                        return True
                    q.append(v)
        return False
    cut = 0
    for k in rim:
        e = M.edges[k]
        a, b = e["a"], e["b"]
        adj[a].discard(b); adj[b].discard(a)
        if near_path(a, b):
            e["dead"] = True
            M.deg[a] -= 1; M.deg[b] -= 1
            cut += 1
        else:
            adj[a].add(b); adj[b].add(a)
    pruned = 0
    changed = True
    while changed:
        changed = False
        for i, n in enumerate(M.nodes):
            if n.get("dead") or n["kind"] != "travel":
                continue
            live = [j for j in adj[i] if not M.nodes[j].get("dead")]
            if len(live) == 0 or (len(live) == 1 and M.nodes[live[0]]["kind"] == "travel"):
                n["dead"] = True
                pruned += 1
                changed = True
                for k, e in enumerate(M.edges):
                    if not e.get("dead") and i in (e["a"], e["b"]):
                        e["dead"] = True
                        M.deg[e["a"]] -= 1; M.deg[e["b"]] -= 1
                for j in live:
                    adj[j].discard(i)
                adj[i].clear()
    print("open rim: arcs", len(rim), "cut", cut, "stubs pruned", pruned)


WHY = collections.Counter()
FUN = collections.Counter()


def weave(M, inside_any):
    """Pass-through groups: for each pocket (one link in), its far node on its own axis is joined straight on, along the
    pocket's facing, to the nearest road node or to a node on another group's axis lying in line with that group, 1.2
    to 4.6 away, when the link crosses nothing and the two ends are far apart in the graph. Then every group the new
    links touch is checked against the cluster rules and links that break one are taken out."""
    import cluster_rules as CR
    adj = collections.defaultdict(set)
    for e in M.edges:
        if not e.get("dead"):
            adj[e["a"]].add(e["b"]); adj[e["b"]].add(e["a"])

    def hops(a, b, limit=5):
        seen = {a: 0}; q = collections.deque([a])
        while q:
            u = q.popleft()
            if seen[u] >= limit:
                continue
            for v in adj[u]:
                if v not in seen:
                    seen[v] = seen[u] + 1
                    if v == b:
                        return seen[v]
                    q.append(v)
        return limit + 1

    def on_axis(g, i):
        gp = M.groups[g]
        c, f = gp["centre"], math.radians(gp["facing"])
        p = M.pt(i)
        return abs((p[0] - c[0]) * math.cos(f) - (p[1] - c[1]) * math.sin(f)) < 0.06
    added, made = [], set()

    def kill(ks, h):
        for k in ks:
            e = M.edges[k]
            if not e.get("dead"):
                e["dead"] = True
                M.deg[e["a"]] -= 1; M.deg[e["b"]] -= 1
                adj[e["a"]].discard(e["b"]); adj[e["b"]].discard(e["a"])
        if h is not None:
            M.nodes[h]["dead"] = True
    for g, gp in enumerate(M.groups):
        ids = gp["nodes"]
        S_ = set(ids)
        if gp["shape"].startswith("start:") or gp["shape"] == "keystone spur":
            continue
        outs = {j for i in ids for j in adj[i] if j not in S_}
        if len(outs) != 1:
            continue
        f = gp["facing"]
        fx, fy = math.sin(math.radians(f)), math.cos(math.radians(f))
        c = gp["centre"]
        proj = lambda i: (M.pt(i)[0] - c[0]) * fx + (M.pt(i)[1] - c[1]) * fy
        side_of = lambda i: (M.pt(i)[0] - c[0]) * fy - (M.pt(i)[1] - c[1]) * fx
        far = max(ids, key=proj)

        def exit_from(fn, direct=True, ts=(1.3, 1.8, 2.4)):
            """Join node fn straight on along the facing to a new road node and on to a partner; (edges, partner's
            group, new node) or None."""
            p = M.pt(fn)
            # a node already (almost) straight ahead: join it directly
            ahead = []
            for j in (M.near(p, 4.5) if direct else ()):
                nd = M.nodes[j]
                if j in S_ or j in made or nd.get("dead") or nd["kind"] not in ("travel", "small", "notable"):
                    continue
                q = M.pt(j)
                along = (q[0] - p[0]) * fx + (q[1] - p[1]) * fy
                perp = abs((q[0] - p[0]) * fy - (q[1] - p[1]) * fx)
                if along < 1.0 or perp > 0.25 or hops(fn, j) <= 3:
                    continue
                if nd["kind"] != "travel":
                    g2 = nd.get("cluster")
                    if g2 is None or M.groups[g2]["shape"].startswith("start:") or not on_axis(g2, j):
                        continue
                    if abs(((M.groups[g2]["facing"] - f) % 180 + 90) % 180 - 90) > 8:
                        continue
                ahead.append((along, j))
            for along, j in sorted(ahead)[:1]:
                if M.fits([], [(p, M.pt(j))], [fn, j]):
                    M.link(fn, j)
                    adj[fn].add(j); adj[j].add(fn)
                    FUN["direct"] += 1
                    return [len(M.edges) - 1], M.nodes[j].get("cluster"), None
            for t in ts:
                x = (p[0] + t * fx, p[1] + t * fy)
                if not inside_any(*x):
                    FUN["x outside"] += 1; continue
                if any(True for _ in M.near(x, 0.8)):
                    FUN["x crowded"] += 1; continue
                if not M.fits([x], [(p, x)], [fn]):
                    FUN["x link blocked"] += 1; continue
                cands = []
                for j in M.near(x, 5.0):
                    nd = M.nodes[j]
                    if j in S_ or j in made or nd.get("dead") or nd["kind"] not in ("travel", "small", "notable"):
                        continue
                    q = M.pt(j)
                    L = math.dist(x, q)
                    if L < 1.0 or hops(fn, j) <= 3:
                        continue
                    dirn = B.ang_of(x, q)
                    if nd["kind"] != "travel":
                        g2 = nd.get("cluster")
                        if g2 is None or M.groups[g2]["shape"].startswith("start:") or not on_axis(g2, j):
                            continue
                        if abs(((M.groups[g2]["facing"] - dirn) % 180 + 90) % 180 - 90) > 3:
                            continue
                    off = abs(((dirn - round(dirn / 15.0) * 15.0) + 180) % 360 - 180)
                    cands.append((nd["kind"] != "travel", off > 2.0, L, j))
                cands.sort()
                FUN["no partner" if not cands else "has partner"] += 1
                for _, _, L, j in cands[:4]:
                    if not M.fits([x], [(p, x), (x, M.pt(j))], [fn, j]):
                        continue
                    h = M.node(x, "travel", region=gp.get("region", "fire"))
                    made.add(h)
                    M.link(fn, h); M.link(h, j)
                    for u_, v_ in ((fn, h), (h, j)):
                        adj[u_].add(v_); adj[v_].add(u_)
                    return [len(M.edges) - 2, len(M.edges) - 1], M.nodes[j].get("cluster"), h
            return None
        FUN["pocket"] += 1
        if M.nodes[far]["kind"] != "small":
            FUN["far is notable"] += 1
            continue
        if on_axis(g, far):
            FUN["far on axis"] += 1
            r1 = exit_from(far)
            FUN["axis exit made" if r1 else "axis exit failed"] += 1
            if r1:
                added.append((r1[0], g, [r1[1]], [r1[2]]))
            continue
        if not PAIR_EXITS:
            continue
        # a C-shaped pocket: the two far nodes, mirrored about the axis, each exit straight on
        top = max(proj(i) for i in ids)
        pair = [i for i in ids if proj(i) > top - 0.05]
        if len(pair) != 2 or abs(side_of(pair[0]) + side_of(pair[1])) > 0.08 or any(M.nodes[i]["kind"] != "small" for i in pair):
            FUN["no far pair"] += 1
            continue
        FUN["far pair"] += 1
        r1 = r2 = None
        for t in (1.3, 1.8, 2.4):      # both exits the same length, so the pair stays mirrored
            r1 = exit_from(pair[0], False, (t,))
            if not r1:
                continue
            r2 = exit_from(pair[1], False, (t,))
            if r2:
                break
            kill(r1[0], r1[2]); r1 = None
        if not (r1 and r2):
            continue
        added.append((r1[0] + r2[0], g, [r1[1], r2[1]], [r1[2], r2[2]]))
    # rules check on the touched groups
    d = {"nodes": M.nodes, "edges": [e for e in M.edges if not e.get("dead")],
         "clusters": [{"id": k, "form": gp["shape"], "name": gp["shape"]} for k, gp in enumerate(M.groups)]}
    G = CR.Graph(d)
    removed = 0
    for ks, g, g2s, hs in added:
        bad = False
        for gg in [g] + g2s:
            if gg is None:
                continue
            r = CR.check_cluster(G, gg)
            if r["R1"] is False or r["R2"] is False or r["R3"] is False or not r["R4"]:
                bad = True
                WHY[("own" if gg == g else "other", "R1" if r["R1"] is False else "R2" if r["R2"] is False else "R3" if r["R3"] is False else "R4", len(hs))] += 1
        if bad:
            for k in ks:
                e = M.edges[k]
                G.adj[e["a"]].discard(e["b"]); G.adj[e["b"]].discard(e["a"])
            kill(ks, None)
            for h in hs:
                if h is not None:
                    M.nodes[h]["dead"] = True
            removed += 1
    print("weave: links", len(added), "kept", len(added) - removed, dict(WHY))
    print("weave funnel", dict(FUN))


def main():
    M, counts = build()
    for n in M.nodes:
        n["u"], n["v"] = n["x"], n["y"]
    clusters = [{"id": k, "form": gp["shape"], "name": gp["shape"]} for k, gp in enumerate(M.groups)]
    keep = [n for n in M.nodes if not n.get("dead")]
    new_id = {n["id"]: k for k, n in enumerate(keep)}       # dead nodes out, ids renumbered so id == index
    for n in keep:
        n["id"] = new_id[n["id"]]
    live = [dict(e, a=new_id[e["a"]], b=new_id[e["b"]]) for e in M.edges if not e.get("dead")]
    for gp in M.groups:
        gp["nodes"] = [new_id[i] for i in gp["nodes"] if i in new_id]
    json.dump({"nodes": keep, "edges": live, "groups": M.groups, "clusters": clusters}, open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False)
    print("nodes", len(M.nodes), "groups", len(M.groups), json.dumps(counts))


if __name__ == "__main__":
    main()
