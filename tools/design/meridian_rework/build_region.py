"""Build one hand-drawn Kinh Mạch Đồ region from its spec, check it, and write data + a viewer page.

Usage (from the repo root):
  python -I tools/design/meridian_rework/build_region.py <region> <out_dir> [--labels]

Version 5 (2026-11-08). v4 generated its clusters from a shape library around a square lattice; the user's review
("the square design looks really bad"; "too generated"; join clusters at their nearest node; several notables per
cluster with small nodes before each; think in groups of clusters, as PoE's start webs do) replaced it.
v5 has no generation at all. It is a drawing kit: the spec (regions/<region>.py) defines build(T) and draws every
road, cluster and link by hand with the pen below. The builder only prices the nodes and checks the drawing against
the PoE measurements in design/research/passive-tree-study.md.

Coordinates: (u, v) in the land's own frame, with the tree centre at (0, 0); v points out along the land's axis and
u across it (+u toward the next element clockwise). One unit is one ordinary link. T.P(r, θ) gives the point at radius
r and θ degrees off the axis. A frame T.frame(origin) is a local pen: x to the right, y outward along the radius.
"""
import collections
import importlib.util
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REGION, OUT = sys.argv[1], sys.argv[2]
LABELS = "--labels" in sys.argv
os.makedirs(OUT, exist_ok=True)
sp = importlib.util.spec_from_file_location("region", os.path.join(HERE, "regions", REGION + ".py"))
R = importlib.util.module_from_spec(sp)
sp.loader.exec_module(R)

# ---- prices (Modifier System Stat List / Formulas A-C) --------------------------------------------------
SMALL, NOTABLE = 1.2, 8.0
MULT = {"universal": 1.0, "broad": 1.25, "family": 1.5}
SCOPE_TIER = {"": "universal", "physical": "broad", "sword": "family", "kim": "family", "weapon": "family"}
STATS = {
    "attack_pct": (1.0, 0.1, " %", "{s}damage", 1), "crit_chance_pct": (1.0, 0.1, " pp", "{s}crit chance", 1),
    "crit_damage_pct": (0.3, 0.1, " pp", "{s}crit damage", 1), "art_speed_pct": (0.6, 0.1, " %", "{s}art speed", 1),
    "art_cost_pct": (1.2, 0.1, " %", "{s}art cost", -1), "accuracy_pct": (0.5, 0.1, " pp", "accuracy", 1),
    "pierce_pct": (1.0, 0.1, " pp", "realm pierce", 1), "resist_pen_pct": (3.0, 0.1, " pp", "{s}resistance penetration", 1),
    "khi_huyet_pct": (1.2, 0.1, " %", "maximum health", 1), "linh_luc_pct": (1.0, 0.1, " %", "maximum linh lực", 1),
    "linh_luc_regen_pct": (8.0, 0.01, " pp/s", "linh lực regeneration", 1), "than_thuc_pct": (1.3, 0.1, " %", "thần thức", 1),
    "defense_pct": (1.0, 0.1, " %", "ward strength", 1), "ward_efficiency_pct": (1.0, 0.1, " %", "ward efficiency", 1),
    "resist_pct": (1.25, 0.1, " pp", "{s}resistance", 1), "block_rating": (0.4, 1, "", "block rating", 1),
    "body_shield_pct": (1.0, 0.1, " pp", "body shield (of health)", 1), "health_regen_pct": (3.0, 0.01, " pp/pulse", "health regeneration", 1),
    "lifespan_pct": (3.0, 0.1, " %", "lifespan", 1), "tam_ma_resist_pct": (1.5, 0.1, " %", "heart demon resistance", 1),
    "ngo_tinh": (5.0, 0.01, "", "comprehension (ngộ tính)", 1), "breakthrough_chance": (5.0, 0.1, " pp", "breakthrough chance", 1),
    "cultivation_speed_pct": (2.2, 0.1, " %", "cultivation speed", 1), "artifact_power_pct": (1.3, 0.1, " %", "artifact power", 1),
    "artifact_attack_pct": (0.6, 0.1, " %", "{s}artifact attack", 1), "element_affinity_pct": (1.3, 0.1, " %", "element affinity", 1),
    "refining_success": (2.0, 0.1, " pp", "refining success", 1), "refine_grade_chance": (1.5, 0.1, " pp", "artifact grade chance (Pending)", 1),
    "than_thuc_cost_pct": (0.8, 0.1, " %", "artifact thần thức cost", -1), "can_cot": (3.0, 0.01, "", "root bone (căn cốt)", 1),
    "soul_res_pct": (0.6, 0.1, " pp", "soul resistance", 1), "status_resist_pct": (0.4, 0.1, " pp", "status resistance", 1),
}
SCOPE_WORD = {"": "", "physical": "Physical ", "sword": "sword ", "kim": "Metal-art ", "weapon": "weapon "}


def value(stat, scope, budget):
    price, u, unit, label, d = STATS[stat]
    units = math.floor(budget * MULT[SCOPE_TIER[scope]] / (price * u) + 1e-6)
    v = d * units * u
    dec = 0 if u >= 1 else (1 if u >= 0.1 else 2)
    return f"{'+' if v >= 0 else '−'}{abs(v):.{dec}f}{unit} {label.format(s=SCOPE_WORD[scope])}".replace("  ", " ")


def mods(spec, budget):
    return [value(st, sc, budget * sh) for st, sc, sh in spec]


# ---- the land frame in world coordinates ---------------------------------------------------------------------
AX = math.radians(R.AXIS)
DIR = (math.sin(AX), -math.cos(AX))      # outward along the land's axis (v)
PERP = (math.cos(AX), math.sin(AX))      # across, toward higher angles (u)


def G(p):
    u, v = p
    return (v * DIR[0] + u * PERP[0], v * DIR[1] + u * PERP[1])


def arc_centre(p, q, bend):
    """Centre of the circle through p and q whose arc bulges `bend` units to the left of p->q."""
    mx, my = (p[0] + q[0]) / 2, (p[1] + q[1]) / 2
    du, dv = q[0] - p[0], q[1] - p[1]
    c = math.hypot(du, dv)
    lu, lv = -dv / c, du / c
    s = abs(bend)
    rad = (c * c / 4 + s * s) / (2 * s)
    k = math.copysign(rad - s, bend)
    return (mx - k * lu, my - k * lv)


def on_arc(p, q, centre, t):
    r = math.dist(p, centre)
    a1 = math.atan2(p[1] - centre[1], p[0] - centre[0])
    a2 = math.atan2(q[1] - centre[1], q[0] - centre[0])
    d = (a2 - a1 + math.pi) % (2 * math.pi) - math.pi
    a = a1 + d * t
    return (centre[0] + r * math.cos(a), centre[1] + r * math.sin(a))


class Frame:
    """A local pen: x to the right, y outward along the radius at the origin, turned `rot` degrees clockwise."""

    def __init__(self, origin, rot=0.0, mirror=False):
        th = math.atan2(origin[0], origin[1]) + math.radians(rot)
        self.o, self.y, self.x = origin, (math.sin(th), math.cos(th)), (math.cos(th), -math.sin(th))
        self.m = -1 if mirror else 1

    def __call__(self, x, y=None):
        if y is None:
            x, y = x
        x *= self.m
        return (self.o[0] + x * self.x[0] + y * self.y[0], self.o[1] + x * self.x[1] + y * self.y[1])


class Tree:
    def __init__(self):
        self.nodes, self.edges, self.clusters = [], [], []
        self.cur = None
        self.bank_pos = collections.Counter()
        self.road_mods = mods(R.ROAD_MOD, SMALL)
        self.gn = collections.defaultdict(list)     # spatial grid of nodes, 2-unit cells
        self.gs = collections.defaultdict(list)     # spatial grid of link pieces (p, q, a, b)
        self.fit_failures = []

    # geometry
    @staticmethod
    def P(r, th):
        t = math.radians(th)
        return (r * math.sin(t), r * math.cos(t))

    @staticmethod
    def frame(origin, rot=0.0, mirror=False):
        return Frame(origin, rot, mirror)

    def pt(self, i):
        return (self.nodes[i]["u"], self.nodes[i]["v"])

    # clusters
    def cluster(self, name, form="", mastery=None):
        self.cur = len(self.clusters)
        self.clusters.append({"id": self.cur, "name": name, "form": form, "nodes": [], "themes": [], "mastery": mastery})
        return self.cur

    def end(self):
        self.cur = None

    # nodes
    def node(self, p, role, theme=None, name=None, key=None):
        i = len(self.nodes)
        n = {"id": i, "u": p[0], "v": p[1], "cluster": None}
        if role == "T":
            n.update(kind="travel", name=name or "Travel node", theme="road", mods=list(self.road_mods))
        elif role == "S":
            n.update(kind="start", name=name or R.START_NAME, theme="start", mods=[])
        elif role == "K":
            k = R.KEYSTONES[key]
            n.update(kind="keystone", name=k["name"], theme="keystone", mods=[k["rule"], "Closes: " + k["closes"]])
        elif role == "N":
            th = R.THEMES[theme]
            if name is None:
                bank = th["notables"]
                nm, spec = bank[self.bank_pos[theme] % len(bank)]
                self.bank_pos[theme] += 1
            else:
                nm, spec = name, dict(th["notables"]).get(name, th["notables"][0][1])
            n.update(kind="notable", name=nm, theme=theme, mods=mods(spec, NOTABLE))
        else:
            th = R.THEMES[theme]
            n.update(kind="small", name=th["small_name"], theme=theme, mods=mods(th["small"], SMALL))
        if any("Metal-art" in m for m in n["mods"]):
            n["counterpart"] = [m.replace("Metal-art", "Lightning-art") for m in n["mods"]]
        if role not in ("T", "S") and self.cur is not None:
            n["cluster"] = self.cur
            c = self.clusters[self.cur]
            c["nodes"].append(i)
            if theme and theme not in c["themes"]:
                c["themes"].append(theme)
        self.nodes.append(n)
        self.gn[(int(p[0] // 2), int(p[1] // 2))].append(i)
        return i

    def link(self, a, b, bend=0.0, centre=None, kind="link", long=False):
        if centre is None and abs(bend) > 1e-6:
            centre = arc_centre(self.pt(a), self.pt(b), bend)
        self.edges.append({"a": a, "b": b, "arc": centre, "long": long, "kind": kind})
        p, q = self.pt(a), self.pt(b)
        if centre is not None:
            n = max(2, int(math.dist(p, q) / 0.4))
            pts = [on_arc(p, q, centre, k / n) for k in range(n + 1)]
        else:
            pts = [p, q]
        for x, y in zip(pts, pts[1:]):
            for cell in self._cells(x, y):
                self.gs[cell].append((x, y, a, b))

    def chain(self, a, b, roles, theme, bend=0.0, names=None, link_ends=True):
        """Put len(roles) nodes evenly on the line (or arc) from node a to node b and link them in order."""
        p, q = self.pt(a), self.pt(b)
        centre = arc_centre(p, q, bend) if abs(bend) > 1e-6 else None
        k = len(roles)
        ids = []
        for j, role in enumerate(roles):
            t = (j + 1) / (k + 1)
            xy = on_arc(p, q, centre, t) if centre else (p[0] + (q[0] - p[0]) * t, p[1] + (q[1] - p[1]) * t)
            nm = names[j] if names and j < len(names) else None
            ids.append(self.node(xy, role, theme, name=nm))
        seq = ([a] if link_ends else []) + ids + ([b] if link_ends else [])
        for x, y in zip(seq, seq[1:]):
            self.link(x, y, centre=centre)
        return ids

    def run(self, a, pts, roles, theme, names=None, centre=None):
        """Nodes at the given points (u, v), linked in order starting from node a (a may be None)."""
        ids = []
        prev = a
        for j, (xy, role) in enumerate(zip(pts, roles)):
            nm = names[j] if names and j < len(names) else None
            i = self.node(xy, role, theme, name=nm)
            if prev is not None:
                self.link(prev, i, centre=centre)
            ids.append(i)
            prev = i
        return ids

    def ring(self, centre, radius, angles, roles, theme, f=None, closed=True, names=None):
        """Nodes on a circle; angles in degrees clockwise from the frame's up. Linked along the circle."""
        f = f or Frame(centre)
        c_uv = centre
        ids = []
        for j, (ang, role) in enumerate(zip(angles, roles)):
            a = math.radians(ang)
            off = (radius * math.sin(a) * f.m, radius * math.cos(a))
            xy = (c_uv[0] + off[0] * f.x[0] + off[1] * f.y[0], c_uv[1] + off[0] * f.x[1] + off[1] * f.y[1])
            nm = names[j] if names and j < len(names) else None
            ids.append(self.node(xy, role, theme, name=nm))
        seq = ids + ([ids[0]] if closed else [])
        for x, y in zip(seq, seq[1:]):
            self.link(x, y, centre=c_uv)
        return ids

    def attach(self, a, ids, bend=0.0, kind="link"):
        """Join node a to the nearest node of ids (PoE joins a cluster at its nearest node)."""
        p = self.pt(a)
        b = min(ids, key=lambda i: math.dist(p, self.pt(i)))
        self.link(a, b, bend=bend, kind=kind)
        return b

    # roads
    def junction(self, p, name="Travel junction"):
        return self.node(p, "T", name=name)

    def road(self, ids, step=3.0, name="Travel node"):
        """Travel nodes between consecutive junctions, about `step` apart. A segment between two junctions at the same
        radius follows the ring around the tree centre; any other segment is straight. Returns every id in order."""
        out = [ids[0]]
        for a, b in zip(ids, ids[1:]):
            p, q = self.pt(a), self.pt(b)
            ring = abs(math.hypot(*p) - math.hypot(*q)) < 0.3
            if ring:
                r = math.hypot(*p)
                a1, a2 = math.atan2(p[0], p[1]), math.atan2(q[0], q[1])
                length = abs(a2 - a1) * r
            else:
                length = math.dist(p, q)
            n = max(0, round(length / step) - 1)
            prev = a
            for j in range(n):
                t = (j + 1) / (n + 1)
                if ring:
                    ang = a1 + (a2 - a1) * t
                    xy = (r * math.sin(ang), r * math.cos(ang))
                else:
                    xy = (p[0] + (q[0] - p[0]) * t, p[1] + (q[1] - p[1]) * t)
                i = self.node(xy, "T", name=name)
                self.link(prev, i, centre=(0.0, 0.0) if ring else None, kind="highway")
                out.append(i)
                prev = i
            self.link(prev, b, centre=(0.0, 0.0) if ring else None, kind="highway")
            out.append(b)
        return out

    # ---- the fit check used by the drawing pens: is a new figure clear of everything already drawn? ----------
    @staticmethod
    def _cells(p, q, pad=0.0):
        x0, x1 = sorted((p[0], q[0])); y0, y1 = sorted((p[1], q[1]))
        return [(gx, gy) for gx in range(int((x0 - pad) // 2), int((x1 + pad) // 2) + 1)
                for gy in range(int((y0 - pad) // 2), int((y1 + pad) // 2) + 1)]

    @staticmethod
    def _pseg(p, a, b):
        dx, dy = b[0] - a[0], b[1] - a[1]
        L2 = dx * dx + dy * dy or 1e-9
        t = max(0.0, min(1.0, ((p[0] - a[0]) * dx + (p[1] - a[1]) * dy) / L2))
        return math.dist(p, (a[0] + t * dx, a[1] + t * dy))

    @staticmethod
    def _cross(p1, p2, p3, p4):
        d = lambda a, b, c: (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
        return d(p1, p2, p3) * d(p1, p2, p4) < 0 and d(p3, p4, p1) * d(p3, p4, p2) < 0

    def fits(self, pts, segs, skip=(), spacing=0.72, graze=0.33, margin=0.3):
        """pts: new node positions; segs: new straight links as point pairs; skip: existing node ids the figure may
        touch (the node it hangs off). True when the figure stays inside the land and clear of every node and link."""
        for (u, v) in pts:
            r = math.hypot(u, v)
            if r > R.RIM - 0.8 or r < 10.5 or abs(math.degrees(math.atan2(u, v))) > R.HALF_ANGLE - math.degrees(margin / max(r, 1.0)):
                self.why = f"outside the land at ({u:.1f},{v:.1f})"
                return False
        for x in range(len(pts)):
            for y in range(x + 1, len(pts)):
                if math.dist(pts[x], pts[y]) < R.MIN_SPACING + 0.05:
                    self.why = "own nodes too close"
                    return False
        pad = max(spacing, graze)
        cells = set()
        for (p, q) in segs:
            cells.update(self._cells(p, q, pad))
        for p in pts:
            cells.update(self._cells(p, p, pad))
        near_nodes = {i for c in cells for i in self.gn.get(c, ())}
        pieces = {pc for c in cells for pc in self.gs.get(c, ())}
        for p in pts:
            for i in near_nodes:
                if i not in skip and math.dist(p, self.pt(i)) < spacing:
                    self.why = f"near node #{i} {self.nodes[i]['name']}"
                    return False
            for (a_, b_, ia, ib) in pieces:
                if self._pseg(p, a_, b_) < graze:
                    self.why = f"node on link #{ia}-#{ib}"
                    return False
        for (p, q) in segs:
            for (a_, b_, ia, ib) in pieces:
                if self._cross(p, q, a_, b_):
                    self.why = f"crosses link #{ia}-#{ib}"
                    return False
            for i in near_nodes:
                if i not in skip and self._pseg(self.pt(i), p, q) < graze:
                    self.why = f"link grazes #{i}"
                    return False
        return True

    def exit(self, a, p, label, note, long=False):
        i = len(self.nodes)
        self.nodes.append({"id": i, "u": p[0], "v": p[1], "kind": "exit", "name": label, "theme": "exit", "mods": [note], "cluster": None})
        self.edges.append({"a": a, "b": i, "arc": None, "long": long, "kind": "exit"})
        return i


T = Tree()
R.build(T)
nodes, edges, clusters = T.nodes, T.edges, T.clusters
start = next(n["id"] for n in nodes if n["kind"] == "start")

# ---- checks --------------------------------------------------------------------------------------------
adj = collections.defaultdict(set)
for e in edges:
    adj[e["a"]].add(e["b"]); adj[e["b"]].add(e["a"])
alloc = [n["id"] for n in nodes if n["kind"] != "exit"]
dist, par = {start: 0}, {}
q = collections.deque([start])
while q:
    u_ = q.popleft()
    for v_ in sorted(adj[u_]):
        if v_ not in dist and nodes[v_]["kind"] != "exit":
            dist[v_] = dist[u_] + 1; par[v_] = u_; q.append(v_)
P = lambda i: (nodes[i]["u"], nodes[i]["v"])


def samples(e, step=0.15):
    p, q_ = P(e["a"]), P(e["b"])
    if e["arc"]:
        r = math.dist(p, e["arc"])
        a1 = math.atan2(p[1] - e["arc"][1], p[0] - e["arc"][0]); a2 = math.atan2(q_[1] - e["arc"][1], q_[0] - e["arc"][0])
        d = (a2 - a1 + math.pi) % (2 * math.pi) - math.pi
        n = max(2, int(abs(d) * r / step))
        return [on_arc(p, q_, e["arc"], k / n) for k in range(n + 1)]
    n = max(2, int(math.dist(p, q_) / step))
    return [(p[0] + (q_[0] - p[0]) * k / n, p[1] + (q_[1] - p[1]) * k / n) for k in range(n + 1)]


def seg_x(p1, p2, p3, p4):
    d = lambda a, b, c: (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
    return d(p1, p2, p3) * d(p1, p2, p4) < 0 and d(p3, p4, p1) * d(p3, p4, p2) < 0


smp = [samples(e) for e in edges]
bbox = [(min(x for x, _ in s), min(y for _, y in s), max(x for x, _ in s), max(y for _, y in s)) for s in smp]
crossings = []
for i in range(len(edges)):
    for j in range(i + 1, len(edges)):
        A, B = edges[i], edges[j]
        if {A["a"], A["b"]} & {B["a"], B["b"]}:
            continue
        bi, bj = bbox[i], bbox[j]
        if bi[2] < bj[0] or bj[2] < bi[0] or bi[3] < bj[1] or bj[3] < bi[1]:
            continue
        si, sj = smp[i], smp[j]
        if any(seg_x(si[k], si[k + 1], sj[m], sj[m + 1]) for k in range(len(si) - 1) for m in range(len(sj) - 1)):
            crossings.append(f"{nodes[A['a']]['name']}#{A['a']}-{A['b']} x {nodes[B['a']]['name']}#{B['a']}-{B['b']}")
grid = collections.defaultdict(list)
for n in nodes:
    grid[(int(n["u"] // 1), int(n["v"] // 1))].append(n["id"])


def near(p, r):
    for gx in range(int((p[0] - r) // 1), int((p[0] + r) // 1) + 1):
        for gy in range(int((p[1] - r) // 1), int((p[1] + r) // 1) + 1):
            yield from grid.get((gx, gy), ())


too_close = []
for n in nodes:
    for m in near(P(n["id"]), R.MIN_SPACING):
        if m > n["id"] and math.dist(P(m), P(n["id"])) < R.MIN_SPACING:
            too_close.append(f"#{n['id']} {n['name']} / #{m} {nodes[m]['name']} ({math.dist(P(m), P(n['id'])):.2f})")
grazing = set()
for k, e in enumerate(edges):
    for p in smp[k][1:-1]:
        for m in near(p, 0.3):
            if m not in (e["a"], e["b"]) and math.dist(p, P(m)) < 0.28:
                grazing.add(f"edge #{e['a']}-{e['b']} passes #{m} {nodes[m]['name']}")
# entry rule: a link from outside joins a cluster at (or within 15 % of) its nearest node
entry_bad, cross_links = [], 0
for e in edges:
    if nodes[e["a"]]["cluster"] != nodes[e["b"]]["cluster"]:
        cross_links += 1
    for a, b in ((e["a"], e["b"]), (e["b"], e["a"])):
        cb = nodes[b]["cluster"]
        if cb is None or nodes[a]["cluster"] == cb or nodes[a]["kind"] == "exit":
            continue
        mem = clusters[cb]["nodes"]
        if len(mem) < 3:
            continue
        best = min(math.dist(P(a), P(m)) for m in mem)
        if math.dist(P(a), P(b)) > 1.15 * best + 1e-6:
            entry_bad.append(f"{nodes[a]['name']}#{a} -> {clusters[cb]['name']}: joins #{b}, nearest is {best:.2f} vs {math.dist(P(a), P(b)):.2f}")
# notables: per cluster, and small nodes taken inside the cluster before each
before = collections.Counter()
for c in clusters:
    mem = set(c["nodes"])
    ents = [i for i in mem if any(x not in mem for x in adj[i])]
    dd = {i: 0 for i in ents}
    q = collections.deque(ents)
    while q:
        u_ = q.popleft()
        for v_ in adj[u_]:
            if v_ in mem and v_ not in dd:
                dd[v_] = dd[u_] + 1; q.append(v_)
    for i in mem:
        if nodes[i]["kind"] == "notable":
            before[dd.get(i, -1)] += 1
per_cluster = collections.Counter(min(4, sum(1 for i in c["nodes"] if nodes[i]["kind"] == "notable")) for c in clusters)
travel = [n["id"] for n in nodes if n["kind"] == "travel"]
bare = [i for i in travel if not any(nodes[x]["kind"] in ("small", "notable", "keystone") for x in adj[i])]
keys = [n for n in nodes if n["kind"] == "keystone"]
nots = [n for n in nodes if n["kind"] == "notable"]
# clusters per travel node, and cluster size by distance from the tree centre (PoE: findings 28-29)
per_travel = collections.Counter(min(4, len({nodes[x]["cluster"] for x in adj[i] if nodes[x]["cluster"] is not None})) for i in travel)
with_any = sum(v for k, v in per_travel.items() if k >= 1)
r_of = lambda c: sum(math.hypot(*P(i)) for i in c["nodes"]) / len(c["nodes"])
r_lo, r_hi = min(math.hypot(*P(i)) for i in alloc), max(math.hypot(*P(i)) for i in alloc)
band = collections.defaultdict(list)
for c in clusters:
    if c["nodes"]:
        f = (r_of(c) - r_lo) / (r_hi - r_lo)
        band["inner" if f < 1 / 3 else "middle" if f < 2 / 3 else "outer"].append(len(c["nodes"]))
size_by_band = {b: {"median": sorted(v)[len(v) // 2], "share_7plus": round(sum(1 for x in v if x >= 7) / len(v), 2)} for b, v in band.items()}
small_buddy = []
for c in clusters:
    if 0 < len(c["nodes"]) <= 4:
        ts = {x for i in c["nodes"] for x in adj[i] if nodes[x]["kind"] == "travel"}
        if ts:
            small_buddy.append(any(len(clusters[nodes[y]["cluster"]]["nodes"]) >= 6 for t in ts for y in adj[t]
                                   if nodes[y]["cluster"] is not None and nodes[y]["cluster"] != c["id"]))
E = sum(1 for e in edges if e["kind"] != "exit")
web9 = [i for i in alloc if dist.get(i, 99) <= 9]
metrics = {
    "region": REGION, "nodes": len(alloc), "kinds": dict(collections.Counter(nodes[i]["kind"] for i in alloc)),
    "clusters": len(clusters), "loops": E - len(alloc) + 1,
    "travel_nodes": len(travel), "travel_with_cluster_share": round(1 - len(bare) / max(1, len(travel)), 2),
    "notables_per_cluster": {str(k): v for k, v in sorted(per_cluster.items())},
    "smalls_before_notable": {str(k): v for k, v in sorted(before.items())},
    "entry_nearest_share": round(1 - len(entry_bad) / max(1, cross_links), 2),
    "start_web_9": {"nodes": len(web9), "notables": sum(1 for i in web9 if nodes[i]["kind"] == "notable")},
    "keystone_points": {k["name"]: dist.get(k["id"]) for k in keys},
    "first_notable": min((dist.get(n["id"], 999) for n in nots), default=None),
    "notables_within": {str(r): sum(1 for n in nots if dist.get(n["id"], 999) <= r) for r in (5, 10, 15, 20, 30)},
    "farthest": max(dist[i] for i in alloc if i in dist), "unreached": len([i for i in alloc if i not in dist]),
    "max_degree": max(len(adj[i]) for i in alloc),
    "crossings": len(crossings), "too_close_count": len(too_close), "grazing": len(grazing), "entry_bad": len(entry_bad),
    "bare_travel": len(bare),
    "travel_multi_share": round(sum(v for k, v in per_travel.items() if k >= 2) / max(1, with_any), 2),
    "size_by_band": size_by_band,
    "small_with_big_share": round(sum(small_buddy) / max(1, len(small_buddy)), 2),
    "shapes": dict(collections.Counter(c["form"] for c in clusters).most_common()),
    "themes": dict(collections.Counter(nodes[i]["theme"] for i in alloc if nodes[i]["kind"] in ("small", "notable"))),
}
report = {"crossings": crossings[:40], "too_close": too_close[:40], "grazing": sorted(grazing)[:40], "entry_bad": entry_bad[:40],
          "bare_travel": [f"#{i} at ({nodes[i]['u']:.1f},{nodes[i]['v']:.1f})" for i in bare]}
out_nodes = []
for n in nodes:
    x, y = G((n["u"], n["v"]))
    o = {k: v for k, v in n.items() if k not in ("u", "v")}
    o.update(x=round(x, 3), y=round(y, 3), u=round(n["u"], 3), v=round(n["v"], 3))
    if LABELS:
        o["label"] = str(n["id"])
    out_nodes.append(o)
data = {"nodes": out_nodes,
        "edges": [{"a": e["a"], "b": e["b"], "arc": [round(c, 3) for c in G(e["arc"])] if e["arc"] else None,
                   "ctrl": None, "long": e["long"], "kind": e["kind"]} for e in edges],
        "clusters": [{"id": c["id"], "theme": c["themes"][0] if c["themes"] else "", "form": c["form"], "name": c["name"],
                      "centre": [round(v, 3) for v in G(c["mastery"])] if c["mastery"] else None} for c in clusters],
        "dist": {str(k): v for k, v in dist.items()}, "par": {str(k): v for k, v in par.items()},
        "metrics": metrics, "themes": {k: {"label": v["label"], "kind": v["kind"]} for k, v in R.THEMES.items()},
        "start_deg": R.AXIS, "title": R.TITLE, "rim": R.RIM, "half_angle": R.HALF_ANGLE, "labels": LABELS}
json.dump(data, open(os.path.join(OUT, f"{REGION}.json"), "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
tpl = open(os.path.join(HERE, "region_viewer.html"), encoding="utf-8").read()
open(os.path.join(OUT, f"{REGION}-pilot.html"), "w", encoding="utf-8").write(
    tpl.replace("__DATA__", json.dumps(data, ensure_ascii=False).replace("</", "<\\u002f")).replace("__TITLE__", R.TITLE))
print(json.dumps(metrics, ensure_ascii=False))
report["fit_failures"] = T.fit_failures
for k, v in report.items():
    if v:
        print(f"-- {k} ({len(v)}):")
        for line in v[:40]:
            print("   ", line)
