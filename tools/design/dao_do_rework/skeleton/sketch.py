"""Road-only sketches for a new Đạo Đồ layout (user 2026-11-15: "generate a brand new layout with just the travel
nodes, and then we fill in from there").

Why: drawn alone, the island roads read as emblems (a closed ring round the start, a crown, a straight bridge: 2 closed
loops, 1 dead end), the land roads do not (0-3 loops per land, 8-12 dead-end stubs, the start on a broken arc). The
land rings were broken and jittered on purpose (the anti-dartboard rule), so they never close into a figure.

Three road-only variants on one frame, the Chaos centre sized in from the start (no push afterwards):
  A  mandala chain   each land three closed figures on its axis (start emblem, middle figure, outer figure); blends
                     smaller figures; side roads chain them into three circuits round the map
  B  petals          each land one big closed petal from the centre to the rim, a start emblem and two cross ribs;
                     blends narrower petals, joined at the ribs
  C  rings + emblems clean closed rings and straight spokes, a distinct emblem round every start (a contrast: close
                     to the dartboard the user rejected before)
Each land's emblem uses the islands' recipe with its own core: Fire a star, Earth an octagon, Metal a circle, Water a
ring pushed off-centre, Wood a hexagon. The islands come unchanged from version gen-2026-11-15-lean-rules-3 (before
their bands), moved out with the rim.

Usage: python -I tools/design/dao_do_rework/skeleton/sketch.py <out_dir>
Writes <out_dir>/sketch-<A|B|C>.json (a road-only graph: nodes x, y, kind, region; edges a, b, arc) and prints checks.
"""
import collections
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(HERE))))
sys.path.insert(0, os.path.dirname(HERE))
import push  # noqa: E402

LANDS = {"fire": 0, "earth": 72, "metal": 144, "water": 216, "wood": 288}
BLENDS = {"blend_fe": 36, "blend_em": 108, "blend_mw": 180, "blend_ww": 252, "blend_wf": 324}
STEP = 4.5          # travel-node spacing on roads (guide: 4.5-5)
CENTRE_R = 19.0     # the Chaos centre is drawn inside this radius (about 500 nodes at the lands' density)
START_R = 27.0
RIM = 84.0
CORE = {"fire": ("star", 10), "earth": ("polygon", 8), "metal": ("circle", 8), "water": ("eclipse", 9), "wood": ("polygon", 6)}


def pol(r, a):
    """World point at radius r, a degrees clockwise from the top (y up)."""
    return (r * math.sin(math.radians(a)), r * math.cos(math.radians(a)))


class G:
    def __init__(self):
        self.nodes, self.edges = [], []

    def node(self, p, region, kind="travel", name=None):
        self.nodes.append({"id": len(self.nodes), "x": round(p[0], 3), "y": round(p[1], 3), "kind": kind, "region": region,
                           "name": name or ("Travel node" if kind == "travel" else name), "cluster": None})
        return len(self.nodes) - 1

    def pt(self, i):
        return (self.nodes[i]["x"], self.nodes[i]["y"])

    def link(self, a, b, centre=None):
        if a != b and not any({e["a"], e["b"]} == {a, b} for e in self.edges[-60:]):
            self.edges.append({"a": a, "b": b, "arc": [round(centre[0], 3), round(centre[1], 3)] if centre else None})

    def road(self, a, b, region, step=STEP):
        """A straight road from node a to node b, travel nodes about `step` apart."""
        p, q = self.pt(a), self.pt(b)
        n = max(0, int(round(math.dist(p, q) / step)) - 1)
        ids = [a] + [self.node((p[0] + (q[0] - p[0]) * k / (n + 1), p[1] + (q[1] - p[1]) * k / (n + 1)), region) for k in range(1, n + 1)] + [b]
        for x, y in zip(ids, ids[1:]):
            self.link(x, y)
        return ids

    def arc_road(self, a, b, c, region, step=STEP):
        """A road along the circle round c from node a to node b (the short way)."""
        p, q = self.pt(a), self.pt(b)
        r = math.dist(p, c)
        t1 = math.atan2(p[1] - c[1], p[0] - c[0]); t2 = math.atan2(q[1] - c[1], q[0] - c[0])
        d = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        n = max(0, int(round(abs(d) * r / step)) - 1)
        ids = [a] + [self.node((c[0] + r * math.cos(t1 + d * k / (n + 1)), c[1] + r * math.sin(t1 + d * k / (n + 1))), region) for k in range(1, n + 1)] + [b]
        for x, y in zip(ids, ids[1:]):
            self.link(x, y, centre=c)
        return ids

    def loop(self, c, r, n, region, shape="circle", phase=0.0, axis=0.0):
        """A closed figure of n travel nodes round c. shape: circle (arcs), polygon (straight sides), star (alternate
        radii, straight sides), eclipse (a circle pushed off-centre toward the tree centre)."""
        if shape == "eclipse":
            sh = 0.18 * r
            c = (c[0] - sh * math.sin(math.radians(axis)), c[1] - sh * math.cos(math.radians(axis)))
        pts = []
        for k in range(n):
            a = axis + phase + 360.0 * k / n
            rr = r * (0.72 if (shape == "star" and k % 2) else 1.0)
            pts.append((c[0] + rr * math.sin(math.radians(a)), c[1] + rr * math.cos(math.radians(a))))
        ids = [self.node(p, region) for p in pts]
        for k in range(n):
            self.link(ids[k], ids[(k + 1) % n], centre=c if shape in ("circle", "eclipse") else None)
        return ids

    def nearest(self, ids, p):
        return min(ids, key=lambda i: math.dist(self.pt(i), p))

    def ring_with(self, r, angles, region_of, step=STEP):
        """A closed circle round the tree centre at radius r, with nodes at every angle in `angles` plus fillers about
        `step` apart. Returns {angle: node} for the given angles."""
        angles = sorted(set(round(a % 360, 4) for a in angles))
        out, prev, first = {}, None, None
        allp = []
        for k, a in enumerate(angles):
            b = angles[(k + 1) % len(angles)] + (360 if k == len(angles) - 1 else 0)
            n = max(0, int(round(math.radians(b - a) * r / step)) - 1)
            allp.append((a, True))
            allp += [(a + (b - a) * j / (n + 1), False) for j in range(1, n + 1)]
        ids = []
        for a, key in allp:
            i = self.node(pol(r, a), region_of(a))
            ids.append(i)
            if key:
                out[a] = i
        for x, y in zip(ids, ids[1:] + ids[:1]):
            self.link(x, y, centre=(0, 0))
        return out


def region_at(a):
    """The land or blend owning angle a (every road node belongs to one land: roads grant purity)."""
    best = min(list(LANDS.items()) + list(BLENDS.items()), key=lambda kv: abs((a - kv[1] + 180) % 360 - 180))
    return best[0]


def to_world(axis, u, v):
    t = math.radians(axis)
    return (u * math.cos(t) + v * math.sin(t), -u * math.sin(t) + v * math.cos(t))


def centre(g):
    """The Chaos centre, roads only: a ring round the start (the Taiji's place), five Source roads, an outer ring."""
    S = g.node((0, 0), "hub", "start", "Chaos start (Hỗn Độn)")
    inner = g.loop((0, 0), 4.2, 10, "hub")
    for k in (0, 5):
        g.link(S, inner[k])
    outer = g.ring_with(CENTRE_R - 4.5, [36 + 72 * k for k in range(5)], lambda a: "hub")
    for k in range(5):
        a = 36 + 72 * k
        g.road(g.nearest(inner, pol(4.2, a)), outer[a], "hub")
    return S, outer


def islands(g, rim_nodes):
    """Light, Darkness and Thunder as drawn before their bands (rules-3), roads only, moved out with the rim."""
    src = json.load(open(os.path.join(ROOT, "design", "dao-do", "versions", "gen-2026-11-15-lean-rules-3.json"), encoding="utf-8"))
    keep = {n["id"] for n in src["nodes"] if n["region"] in ("light", "darkness", "thunder") and n["kind"] in ("travel", "start")}
    nodes = [dict(n) for n in src["nodes"] if n["id"] in keep]
    edges = [dict(e) for e in src["edges"] if e["a"] in keep and e["b"] in keep]
    push.apply(nodes, edges, [], RIM - 76.0)
    m = {}
    for n in nodes:
        m[n["id"]] = g.node((n["x"], -n["y"]), n["region"], n["kind"], n.get("name"))   # versions are y-down
    for e in edges:
        g.link(m[e["a"]], m[e["b"]], centre=(e["arc"][0], -e["arc"][1]) if e.get("arc") else None)
    # the start sits inside its inner ring, which is a cluster, not a road: give it a road to the road ring
    for n in nodes:
        if n["kind"] == "start":
            ring = [m[k["id"]] for k in nodes if k["region"] == n["region"] and k["kind"] == "travel"]
            g.road(m[n["id"]], g.nearest(ring, g.pt(m[n["id"]])), n["region"])
    # each island joins the rim at its end nearest the tree: the bridge, and Darkness's shadow road
    for reg in ("light", "darkness", "thunder"):
        ids = [m[i] for i in m if src["nodes"][i]["region"] == reg]
        deg = collections.Counter()
        for e in g.edges:
            deg[e["a"]] += 1; deg[e["b"]] += 1
        ends = [i for i in ids if deg[i] == 1 and g.nodes[i]["kind"] == "travel"]
        for i in sorted(ends, key=lambda i: math.hypot(*g.pt(i)))[: (2 if reg == "darkness" else 1)]:
            j = g.nearest(rim_nodes, g.pt(i))
            g.road(i, j, reg)


def variant_a():
    g = G()
    S, cring = centre(g)
    land = {}
    for name, ax in LANDS.items():
        shape, n = CORE[name]
        sp = to_world(ax, 0, START_R)
        st = g.node(sp, name, "start", f"{name.title()} start")
        e1 = g.loop(sp, 5.6, n, name, shape, axis=ax)
        g.link(st, g.nearest(e1, to_world(ax, 0, START_R - 5.6)))
        g.link(st, g.nearest(e1, to_world(ax, 0, START_R + 5.6)))
        e2c = to_world(ax, 0, 48.0)
        e2 = g.loop(e2c, 8.0, n + 2, name, shape if shape != "eclipse" else "circle", axis=ax)
        e3c = to_world(ax, 0, 69.0)
        e3 = g.loop(e3c, 6.5, n, name, shape, phase=180.0 / n, axis=ax)
        g.road(g.nearest(e1, to_world(ax, 0, START_R + 6)), g.nearest(e2, to_world(ax, 0, 40)), name)
        g.road(g.nearest(e2, to_world(ax, 0, 56)), g.nearest(e3, to_world(ax, 0, 62.5)), name)
        land[name] = (e1, e2, e3, st)
    blend = {}
    for name, ax in BLENDS.items():
        b1 = g.loop(to_world(ax, 0, 37.5), 4.6, 6, name, "circle", axis=ax)
        b2 = g.loop(to_world(ax, 0, 59.0), 5.6, 8, name, "circle", axis=ax)
        g.road(g.nearest(b1, to_world(ax, 0, 42)), g.nearest(b2, to_world(ax, 0, 53)), name)
        g.road(cring[ax], g.nearest(b1, to_world(ax, 0, 32)), name)
        blend[name] = (b1, b2)
        if name == "blend_ww":    # Wind's start sits in the Water-Wood blend's outer figure
            w = g.node(to_world(ax, 0, 59.0), name, "start", "Wind start")
            g.link(w, g.nearest(b2, to_world(ax, 0, 53)))
    # circuits: each land's figures to the blends on both sides
    order = sorted(list(LANDS.items()) + list(BLENDS.items()), key=lambda kv: kv[1])
    for (n1, a1), (n2, a2) in zip(order, order[1:] + order[:1]):
        L, B = (n1, n2) if n1 in LANDS else (n2, n1)
        la, ba = LANDS[L], BLENDS[B]
        side = 1 if ((ba - la) % 360) < 180 else -1
        e1, e2, e3, _ = land[L]; b1, b2 = blend[B]
        g.road(g.nearest(e1, to_world(la, side * 5.6, START_R + 1)), g.nearest(b1, to_world(ba, -side * 4.6, 37.5)), L)
        g.road(g.nearest(e2, to_world(la, side * 8.0, 48)), g.nearest(b2, to_world(ba, -side * 5.6, 59)), L)
    # the rim: a closed circle through every land's outer figure and every blend's outer figure
    rim_angles = [a for a in range(0, 360, 1)]
    rim = g.ring_with(RIM, list(LANDS.values()) + list(BLENDS.values()), region_at)
    for name, ax in LANDS.items():
        g.road(g.nearest(land[name][2], to_world(ax, 0, 76)), rim[ax], name)
    for name, ax in BLENDS.items():
        g.road(g.nearest(blend[name][1], to_world(ax, 0, 65)), rim[ax], name)
    ice = [n for n in g.nodes if n["region"] == "water" and n["kind"] == "travel" and 36 < math.hypot(n["x"], n["y"]) < 40]
    if ice:
        ice[0]["kind"] = "start"; ice[0]["name"] = "Ice start"
    rim_nodes = [i for i, n in enumerate(g.nodes) if abs(math.hypot(n["x"], n["y"]) - RIM) < 0.2]
    islands(g, rim_nodes)
    return g


def variant_b():
    g = G()
    S, cring = centre(g)
    land = {}

    def petal(name, ax, r0, r1, half, region, ribs):
        n = max(6, int(round((r1 - r0) / 3.6)))
        sides = {}
        for s in (-1, 1):
            pts = [(r0 + (r1 - r0) * k / n, s * half * math.sin(math.pi * k / n)) for k in range(n + 1)]
            ids = []
            for k, (r, da) in enumerate(pts):
                if k in (0, n) and s == 1:
                    ids.append(sides[-1][k])
                    continue
                ids.append(g.node(pol(r, ax + da), region))
            for x, y in zip(ids, ids[1:]):
                g.link(x, y)
            sides[s] = ids
        for rr in ribs:
            k = min(range(n + 1), key=lambda k: abs(r0 + (r1 - r0) * k / n - rr))
            g.road(sides[-1][k], sides[1][k], region)
        return sides

    for name, ax in LANDS.items():
        shape, n = CORE[name]
        sides = petal(name, ax, CENTRE_R + 3.0, RIM - 4.0, 15.0, name, (44.0, 63.0))
        PR = 33.5      # where the petal is wide enough to hold the start's emblem
        sp = to_world(ax, 0, PR)
        st = g.node(sp, name, "start", f"{name.title()} start")
        em = g.loop(sp, 4.2, n, name, shape, axis=ax)
        g.link(st, g.nearest(em, to_world(ax, 0, PR - 4.2)))
        g.road(sides[-1][0], g.nearest(em, to_world(ax, 0, PR - 5)), name)
        # the spine: the emblem up to each rib's middle
        prev = g.nearest(em, to_world(ax, 0, PR + 5))
        for rr in (44.0, 63.0):
            mid = min((i for i in range(len(g.nodes)) if g.nodes[i]["region"] == name and abs(math.hypot(*g.pt(i)) - rr) < 2.5),
                      key=lambda i: abs((math.degrees(math.atan2(*g.pt(i))) - ax + 180) % 360 - 180))
            g.road(prev, mid, name)
            prev = mid
        g.road(prev, sides[-1][-1], name)
        land[name] = sides
    blend = {}
    for name, ax in BLENDS.items():
        sides = petal(name, ax, CENTRE_R + 9.0, RIM - 8.0, 6.5, name, (44.0, 63.0))
        g.road(cring[ax], sides[-1][0], name)
        blend[name] = sides
        if name == "blend_ww":
            g.nodes[sides[1][len(sides[1]) * 2 // 3]]["kind"] = "start"
    order = sorted(list(LANDS.items()) + list(BLENDS.items()), key=lambda kv: kv[1])
    for (n1, a1), (n2, a2) in zip(order, order[1:] + order[:1]):
        L, B = (n1, n2) if n1 in LANDS else (n2, n1)
        la, ba = LANDS[L], BLENDS[B]
        side = 1 if ((ba - la) % 360) < 180 else -1
        for rr in (44.0, 63.0):
            p = min(land[L][side], key=lambda i: abs(math.hypot(*g.pt(i)) - rr))
            q = min(blend[B][-side], key=lambda i: abs(math.hypot(*g.pt(i)) - rr))
            g.road(p, q, L)
    rim = g.ring_with(RIM, list(LANDS.values()) + list(BLENDS.values()), region_at)
    for name, ax in LANDS.items():
        g.road(land[name][-1][-1], rim[ax], name)
    for name, ax in BLENDS.items():
        g.road(blend[name][-1][-1], rim[ax], name)
    ice = [n for n in g.nodes if n["region"] == "water" and n["kind"] == "travel" and 37 < math.hypot(n["x"], n["y"]) < 41]
    if ice:
        ice[0]["kind"] = "start"
    islands(g, [i for i, n in enumerate(g.nodes) if abs(math.hypot(n["x"], n["y"]) - RIM) < 0.2])
    return g


def variant_c():
    g = G()
    S, cring = centre(g)
    spokes = list(LANDS.values()) + list(BLENDS.values())
    rings = {r: g.ring_with(r, spokes, region_at) for r in (40.0, 58.0, 76.0)}
    for name, ax in LANDS.items():
        shape, n = CORE[name]
        sp = to_world(ax, 0, START_R)
        st = g.node(sp, name, "start", f"{name.title()} start")
        em = g.loop(sp, 5.4, n, name, shape, axis=ax)
        g.link(st, g.nearest(em, to_world(ax, 0, START_R - 5.4)))
        g.road(g.nearest(em, to_world(ax, 0, START_R + 6)), rings[40.0][ax], name)
    for name, ax in BLENDS.items():
        g.road(cring[ax], rings[40.0][ax], name)
    for a in spokes:
        g.road(rings[40.0][a], rings[58.0][a], region_at(a))
        g.road(rings[58.0][a], rings[76.0][a], region_at(a))
    rim = g.ring_with(RIM, spokes, region_at)
    for a in spokes:
        g.road(rings[76.0][a], rim[a], region_at(a))
    wind = rings[58.0][252]; g.nodes[wind]["kind"] = "start"
    ice = [n for n in g.nodes if n["region"] == "water" and n["kind"] == "travel" and 34 < math.hypot(n["x"], n["y"]) < 38]
    if ice:
        ice[0]["kind"] = "start"
    islands(g, [i for i, n in enumerate(g.nodes) if abs(math.hypot(n["x"], n["y"]) - RIM) < 0.2])
    return g


# ---- checks -------------------------------------------------------------------------------------------------------
def checks(g):
    N = g.nodes
    adj = collections.defaultdict(set)
    for e in g.edges:
        adj[e["a"]].add(e["b"]); adj[e["b"]].add(e["a"])
    seen, comps = set(), 0
    for s in range(len(N)):
        if s in seen:
            continue
        comps += 1; st = [s]; seen.add(s)
        while st:
            u = st.pop()
            for v in adj[u]:
                if v not in seen:
                    seen.add(v); st.append(v)

    def samples(e):
        p, q = g.pt(e["a"]), g.pt(e["b"]); c = e.get("arc")
        if not c:
            return [p, q]
        r = math.dist(p, c); t1 = math.atan2(p[1] - c[1], p[0] - c[0]); t2 = math.atan2(q[1] - c[1], q[0] - c[0])
        d = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
        k = max(2, int(abs(d) * r / 0.5))
        return [(c[0] + r * math.cos(t1 + d * j / k), c[1] + r * math.sin(t1 + d * j / k)) for j in range(k + 1)]
    o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    sm = [samples(e) for e in g.edges]
    grid = collections.defaultdict(list)
    for k, s in enumerate(sm):
        for (x, y) in s:
            grid[(int(x // 4), int(y // 4))].append(k)
    cross = set()
    for cell, ks in grid.items():
        ks = sorted(set(ks))
        for i in range(len(ks)):
            for j in range(i + 1, len(ks)):
                a, b = g.edges[ks[i]], g.edges[ks[j]]
                if len({a["a"], a["b"], b["a"], b["b"]}) < 4 or (ks[i], ks[j]) in cross:
                    continue
                if any(o(p1, p2, p3) * o(p1, p2, p4) < 0 and o(p3, p4, p1) * o(p3, p4, p2) < 0
                       for p1, p2 in zip(sm[ks[i]], sm[ks[i]][1:]) for p3, p4 in zip(sm[ks[j]], sm[ks[j]][1:])):
                    cross.add((ks[i], ks[j]))
    close = sum(1 for i in range(len(N)) for j in range(i + 1, len(N)) if math.dist(g.pt(i), g.pt(j)) < 1.5)
    lens = [math.dist(g.pt(e["a"]), g.pt(e["b"])) for e in g.edges]
    starts = {n["name"] or f"start {n['id']}": n["id"] for n in N if n["kind"] == "start"}

    def bfs(s):
        d = {s: 0}; q = [s]
        for u in q:
            for v in adj[u]:
                if v not in d:
                    d[v] = d[u] + 1; q.append(v)
        return d
    ch = bfs(starts["Chaos start (Hỗn Độn)"])
    land_st = {k: v for k, v in starts.items() if any(k.lower().startswith(l) for l in LANDS)}
    fire = bfs(land_st.get("Fire start", next(iter(land_st.values()))))
    per = collections.Counter(n["region"] for n in N if n["kind"] == "travel")
    loops = {}
    for reg in set(n["region"] for n in N):
        ids = {n["id"] for n in N if n["region"] == reg}
        le = sum(1 for e in g.edges if e["a"] in ids and e["b"] in ids)
        loops[reg] = le - len(ids) + 1
    dead = sum(1 for i in range(len(N)) if len(adj[i]) == 1 and N[i]["kind"] == "travel")
    return {"travel nodes": sum(per.values()), "components": comps, "crossings": len(cross), "nodes closer than 1.5": close,
            "median link": round(sorted(lens)[len(lens) // 2], 2), "dead-end road nodes": dead,
            "Chaos to land starts": {k: ch.get(v) for k, v in land_st.items()},
            "Fire to other land starts": {k: fire.get(v) for k, v in land_st.items()},
            "travel nodes per land": {k: per[k] for k in list(LANDS) + ["hub"]},
            "closed loops per land": {k: loops.get(k) for k in list(LANDS) + list(BLENDS) + ["hub"]}}


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    for key, fn in (("A", variant_a), ("B", variant_b), ("C", variant_c)):
        g = fn()
        json.dump({"nodes": g.nodes, "edges": g.edges, "variant": key}, open(os.path.join(out, f"sketch-{key}.json"), "w", encoding="utf-8"), ensure_ascii=False)
        print(key, json.dumps(checks(g), ensure_ascii=False))


if __name__ == "__main__":
    main()
