"""PoE's construction grammar on one patch: Fire's start area on the A2 roads (user 2026-11-15: "research the
characteristic that makes poe1 and poe2 graphs look so good and copy it").

Measured on both PoE trees (the survey data, 2026-11-15):
- every node sits on one of a few circles round its group's centre (0, 82, 162, 251, 335, 493, 662, 846: 100 % of
  nodes within 2 units), at fixed compass angles per circle (82: 60 or 30 degrees; 162, 251, 335: 15; 493: 10 or 5;
  662, 846: 5). Groups are never turned: the slots are absolute.
- groups are small (median 3 nodes in PoE 1; 75 % have 4-5 or fewer) and sit right on their road: no stems.
- links along a circle are drawn as arcs of it.
Copied here as rules, not PoE's own groups: the radii keep PoE's ratios, scaled so the tightest pair of neighbours is
our usual spacing; slots count from Fire's axis so the land mirrors about it; every shape is symmetric about the line
from its road node through its centre (the cluster rules: notables on that line or in mirrored pairs, far ends gold, no
dead ends, at least one notable). Shapes are lists of (circle, angle from the shape's facing) with links.

Usage: python -I tools/design/dao_do_rework/skeleton/orbit_demo.py <out.json>
"""
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import sketch as S  # noqa: E402
import sketch_a2  # noqa: E402

SCALE = 1.2 / 173.0                     # PoE 1's median nearest-neighbour distance becomes 1.2 of our units
RADII = [r * SCALE for r in (0, 82, 162, 251, 335, 493, 662, 846)]
STEP = {1: 30, 2: 15, 3: 15, 4: 15, 5: 10, 6: 5, 7: 5}     # degrees between slots on each circle

# shapes: nodes (circle, angle from facing, role) with the entry first; links (i, j, along-the-circle?)
# role: s minor, N notable. Facing = the direction from the road node through the group's centre.
SHAPES = {
    # a diamond on circle 2: entry, two sides, the notable at the far point (PoE's commonest 4-node pocket)
    "kite": ([(2, 180, "s"), (2, 90, "s"), (2, -90, "s"), (2, 0, "N")], [(0, 1, 1), (0, 2, 1), (1, 3, 1), (2, 3, 1)]),
    # a ring of six on circle 2, notable at the far point
    "ring": ([(2, 180, "s"), (2, 120, "s"), (2, -120, "s"), (2, 60, "s"), (2, -60, "s"), (2, 0, "N")],
             [(0, 1, 1), (0, 2, 1), (1, 3, 1), (2, 4, 1), (3, 5, 1), (4, 5, 1)]),
    # a ring of six round a notable hub, entered from below; two notables on the ring's far pair
    "wheel": ([(3, 180, "s"), (0, 0, "N"), (3, 120, "s"), (3, -120, "s"), (3, 60, "N"), (3, -60, "N"), (3, 0, "s")],
              [(0, 1, 0), (0, 2, 1), (0, 3, 1), (2, 4, 1), (3, 5, 1), (4, 6, 1), (5, 6, 1)]),
    # a fan: entry, a hub, three spokes out to notables on circle 4
    "fan": ([(2, 180, "s"), (0, 0, "s"), (4, -30, "N"), (4, 0, "N"), (4, 30, "N")], [(0, 1, 0), (1, 2, 0), (1, 3, 0), (1, 4, 0)]),
    # a small arc: entry on circle 3 below, up through the centre to a notable at the top of circle 3
    "spur": ([(3, 180, "s"), (0, 0, "s"), (3, 0, "N")], [(0, 1, 0), (1, 2, 0)]),
}
SIZES = {"kite": 4, "ring": 6, "wheel": 7, "fan": 5, "spur": 3}


def pos(c, circle, ang):
    """World point at `circle` round centre c, at `ang` degrees clockwise from Fire's axis (straight up)."""
    r = RADII[circle]
    return (c[0] + r * math.sin(math.radians(ang)), c[1] + r * math.cos(math.radians(ang)))


def snap(a, step):
    return round(a / step) * step


class Patch:
    def __init__(self):
        self.g = S.G()
        self.groups = []

    def clear(self, pts, segs, spacing=0.78):
        """True if the new points keep `spacing` from every node and the new links cross nothing."""
        for p in pts:
            for n in self.g.nodes:
                if math.dist(p, (n["x"], n["y"])) < spacing:
                    return False
        o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
        for p1, p2 in segs:
            for e in self.g.edges:
                p3, p4 = self.g.pt(e["a"]), self.g.pt(e["b"])
                if p3 in (p1, p2) or p4 in (p1, p2):
                    continue
                if o(p1, p2, p3) * o(p1, p2, p4) < 0 and o(p3, p4, p1) * o(p3, p4, p2) < 0:
                    return False
        return True

    def group(self, road, facing, shape, theme, inside=None, dry=False):
        """Hang `shape` off node `road`, facing `facing` (degrees from the axis, a slot multiple), its entry one
        spacing from the road. Returns the node ids, or None if it does not fit."""
        pts, links = SHAPES[shape]
        er = RADII[pts[0][0]]
        rp = self.g.pt(road)
        d = er + 1.15
        c = (rp[0] + d * math.sin(math.radians(facing)), rp[1] + d * math.cos(math.radians(facing)))
        P = [pos(c, ci, facing + a) for ci, a, _ in pts]
        if inside and not all(inside(*p) for p in P):
            return None
        segs = [(P[i], P[j]) for i, j, _ in links] + [(rp, P[0])]
        if not self.clear(P, segs):
            return None
        if dry:
            return True
        ids = [self.g.node(p, "fire", "notable" if role == "N" else "small") for p, (_, _, role) in zip(P, pts)]
        for n_ in ids:
            self.g.nodes[n_]["cluster"] = len(self.groups); self.g.nodes[n_]["theme"] = theme
        for i, j, arc in links:
            self.g.link(ids[i], ids[j], centre=c if arc else None)
        self.g.link(road, ids[0])
        self.groups.append({"centre": c, "shape": shape, "nodes": ids})
        return ids


def build():
    g0, _ = sketch_a2.variant_a2()
    P = Patch()
    # the patch: Fire's start area, roads only, copied from A2
    box = (-17.0, 19.5, 17.0, 46.0)
    inb = lambda x, y: box[0] <= x <= box[2] and box[1] <= y <= box[3]
    m = {}
    for n in g0.nodes:
        if n["kind"] in ("travel", "start") and inb(n["x"], n["y"]):
            m[n["id"]] = P.g.node((n["x"], n["y"]), n["region"], n["kind"], n.get("name"))
    for e in g0.edges:
        if e["a"] in m and e["b"] in m:
            P.g.link(m[e["a"]], m[e["b"]], centre=tuple(e["arc"]) if e.get("arc") else None)
    roads = [i for i, n in enumerate(P.g.nodes) if n["kind"] == "travel" and n["region"] == "fire"]
    # the stars stay clear inside
    stars = [((0.0, S.START_R), 5.8), ((0.0, 48.0), 8.0)]
    inside = lambda x, y: inb(x, y) and abs(math.degrees(math.atan2(x, y))) <= 18.0 and all(math.dist((x, y), c) > r for c, r in stars)
    # right half and the axis: each road node gets up to two groups, facing out from its star (or across its road),
    # snapped to 30 degrees from the axis; the right half is mirrored onto the left
    themes = {"right": "alchemy", "axis": "fire", "left": "blaze"}
    order = sorted([i for i in roads if P.g.pt(i)[0] >= -1e-6], key=lambda i: (P.g.pt(i)[1], P.g.pt(i)[0]))
    menu = ["kite", "ring", "fan", "wheel", "spur"]
    k = 0
    for i in order:
        x, y = P.g.pt(i)
        on_axis = abs(x) < 0.05
        star = min(stars, key=lambda s: math.dist((x, y), s[0]))[0]
        out = math.degrees(math.atan2(x - star[0], y - star[1]))
        faces = [snap(out, 30)] + ([snap(out + 60, 30), snap(out - 60, 30)] if not on_axis else [])
        placed = 0
        for f in faces:
            if placed >= (1 if on_axis else 2):
                break
            for shape in menu[k % len(menu):] + menu[:k % len(menu)]:
                if on_axis and f % 180 != 0:
                    continue
                theme = "fire" if on_axis else themes["right"]
                mirror_f = -f
                if on_axis:
                    if P.group(i, f, shape, theme, inside):
                        placed += 1; k += 1
                        break
                    continue
                # the mirror twin must fit too before either is drawn
                j = _mirror_node(P, i)
                if j is None or not P.group(i, f, shape, theme, inside, dry=True):
                    continue
                a = P.group(i, f, shape, theme, inside)
                b = P.group(j, mirror_f, shape, themes["left"], inside)
                if a and b:
                    placed += 1; k += 1
                    break
    return P


def _mirror_node(P, i):
    x, y = P.g.pt(i)
    for j, n in enumerate(P.g.nodes):
        if abs(n["x"] + x) < 0.05 and abs(n["y"] - y) < 0.05 and n["kind"] == P.g.nodes[i]["kind"]:
            return j
    return None


def main():
    P = build()
    g = P.g
    out = {"nodes": g.nodes, "edges": g.edges, "groups": P.groups}
    json.dump(out, open(sys.argv[1], "w", encoding="utf-8"), ensure_ascii=False)
    kinds = {}
    for n in g.nodes:
        kinds[n["kind"]] = kinds.get(n["kind"], 0) + 1
    print("nodes", len(g.nodes), kinds, "groups", len(P.groups), {s: sum(1 for x in P.groups if x["shape"] == s) for s in SHAPES})


if __name__ == "__main__":
    main()
