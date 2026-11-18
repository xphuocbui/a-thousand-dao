"""Hand-designed emblem set pieces (user 2026-11-15: the generated ones had "too damn high" notables and were "really
badly designed"; chose "hand-design, gallery first").

Each land emblem and blend circle without a start keeps its silhouette from the A2 sketch (the outline), with small
nodes added along its long sides, and gets a drawn interior. The budget is fixed: three notables per set piece, a centre
notable plus one mirrored pair (PoE's big groups hold a median of 3), never on a node a road reaches. Everything is
symmetric about the emblem's axis.

An interior is written in the emblem's own frame (u right, v out along the axis), as functions of the outline points
so the same design fits the middle and the outer emblem of a land. Outline points are referred to by position.

Usage: python -I tools/design/dao_do_rework/skeleton/emblems.py <out.html>   (the gallery, with checks)
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))

STEP = 3.6          # outline sides longer than this get a small node or two along them (user 2026-11-16: fewer road-like nodes)


def _pol(r, a):
    return (round(r * math.sin(math.radians(a)), 4), round(r * math.cos(math.radians(a)), 4))


def _ang(p):
    return math.degrees(math.atan2(p[0], p[1])) % 360


def _near(pts, q, tol=0.15):
    return next((p for p in pts if math.dist(p, q) < tol), None)


def interior(fam, outline, ports, rr):
    """Interior nodes and links for one emblem. outline: [(u, v)] of the sketch's outline nodes; ports: those a road
    reaches. Returns (nodes {(u, v): role}, links [((u, v), (u, v), arc centre or None)], notables-on-outline [(u, v)])."""
    N, L, gold_out = {}, [], []
    rad = sorted(math.hypot(*p) for p in outline if math.hypot(*p) > 0.3)
    split = (rad[0] + rad[-1]) / 2 if rad else rr
    inner = [p for p in outline if math.hypot(*p) < min(split, 0.7 * rr) or (fam == "star" and math.hypot(*p) < split - 0.3)]

    def side_pair(cands):
        """The mirrored pair of cands nearest the sides (u > 0 one and its mirror)."""
        right = sorted([q for q in cands if q[0] > 0.05], key=lambda q: abs(_ang(q) - 90))
        for q in right:
            tw = _near(cands, (-q[0], q[1]), 0.1)
            if tw:
                return [q, tw]
        return []
    if fam == "star":
        # flame of the star: a small pentagon ring at the star's inner vertices' angles, a spoke from each ring node out
        # to its inner vertex, the ring joined to a centre notable; the ring's mirrored pair nearest the sides is gold
        verts = sorted(inner, key=_ang)
        ring = []
        for p in verts:
            q = _pol(0.33 * rr, _ang(p))
            N[q] = "s"; ring.append(q); L.append((q, p, None))
        ring.sort(key=_ang)
        for a, b in zip(ring, ring[1:] + ring[:1]):
            L.append((a, b, None))
        N[(0.0, 0.0)] = "N"
        for q in ring:
            L.append(((0.0, 0.0), q, None))
        for q in side_pair(ring):
            N[q] = "N"
    elif fam == "fortress":
        # the keep: a centre notable on the axis between the inner diamond's top and bottom; two towers inward from the
        # upper corners (gold); the lower corners walled to the diamond's foot
        N[(0.0, 0.0)] = "N"
        top = max(inner, key=lambda p: p[1]); bot = min(inner, key=lambda p: p[1])
        L += [((0.0, 0.0), top, None), ((0.0, 0.0), bot, None)]
        corners = [p for p in outline if abs(p[0]) > 0.5 and abs(p[1]) > 0.5 and math.hypot(*p) > 0.7 * rr and p not in ports]
        for c in corners:
            if c[1] > 0:
                t = (c[0] * 0.6, c[1] * 0.6)
                N[t] = "N"; L.append((c, t, None))
            else:
                L.append((c, bot, None))
    elif fam == "blade":
        # crossed blades: a centre notable spoked to the inner vertices; the mirrored pair of side vertices is gold
        N[(0.0, 0.0)] = "N"
        for p in inner:
            L.append(((0.0, 0.0), p, None))
        sides = [p for p in outline if abs(p[1]) < 0.2 and abs(p[0]) > 0.5]
        if len(sides) == 2 and not any(s in ports for s in sides):
            gold_out += sides
        else:
            gold_out += sorted([p for p in inner if abs(p[0]) > 0.5], key=lambda p: -p[1])[:2]
    elif fam == "lotus":
        # the lotus heart: an inner ring (arcs) at the outline's own angles, petal spokes out to the outline's inward
        # cusps, a centre notable on the axis; the ring's side pair is gold
        cusps = [p for p in outline if math.hypot(*p) < 0.9 * rr * 0.95 + 0.0001] or outline
        r_in = 0.4 * rr
        ring = []
        for k in range(8):
            q = _pol(r_in, 45 * k)
            N[q] = "s"; ring.append(q)
        for a, b in zip(ring, ring[1:] + ring[:1]):
            L.append((a, b, (0.0, 0.0)))
        for q in ring:
            tgt = min(outline, key=lambda p: (abs(((_ang(p) - _ang(q)) + 180) % 360 - 180), -math.hypot(*p)))
            if abs(((_ang(tgt) - _ang(q)) + 180) % 360 - 180) < 12:
                L.append((q, tgt, None))
        N[(0.0, 0.0)] = "N"
        L += [((0.0, 0.0), ring[0], None), ((0.0, 0.0), ring[4], None)]
        for q in (ring[2], ring[6]):
            N[q] = "N"
    elif fam == "leaf":
        # the leaf: the sketch's veins stay; the vein crossing at the centre is gold, and a mirrored pair of fine veins
        # runs from it to two gold tips between the side veins
        centre = _near(outline, (0.0, 0.0), 0.3)
        if centre:
            gold_out.append(centre)
        mid_v = max(p[1] for p in inner) / 2 if inner else rr * 0.25
        for sg in (1, -1):
            t = (sg * 0.36 * rr, mid_v)
            N[t] = "N"
            L.append((centre or (0.0, 0.0), t, None))
        if not centre:
            N[(0.0, 0.0)] = "s"
    elif fam == "circle":
        # the mandala: an inner ring (arcs) at the outline's angles, radial spokes out to it, a centre notable joined
        # along the axis; the inner ring's pair nearest the sides is gold
        r_in = 0.45 * rr
        ring = []
        for p in sorted(outline, key=_ang):
            q = _pol(r_in, _ang(p))
            N[q] = "s"; ring.append(q); L.append((q, p, None))
        ring.sort(key=_ang)
        for a, b in zip(ring, ring[1:] + ring[:1]):
            L.append((a, b, (0.0, 0.0)))
        N[(0.0, 0.0)] = "N"
        axis = [q for q in ring if abs(q[0]) < 0.05]
        for q in axis:
            L.append(((0.0, 0.0), q, None))
        for q in side_pair(ring):
            N[q] = "N"
    return N, L, gold_out


def subdivide(outline_links):
    """Small nodes along outline sides longer than STEP: [(a, b, arc centre)] -> new nodes and links."""
    nodes, links = [], []
    for a, b, c in outline_links:
        if c is not None:
            r = math.dist(a, c)
            t1 = math.atan2(a[0] - c[0], a[1] - c[1]); t2 = math.atan2(b[0] - c[0], b[1] - c[1])
            dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
            L = abs(dt) * r
        else:
            L = math.dist(a, b)
        n = int(L / STEP + 1e-6)
        if n < 1:
            links.append((a, b, c)); continue
        chain = [a]
        for k in range(1, n + 1):
            f = k / (n + 1)
            if c is not None:
                t = t1 + dt * f
                q = (c[0] + r * math.sin(t), c[1] + r * math.cos(t))
            else:
                q = (a[0] + (b[0] - a[0]) * f, a[1] + (b[1] - a[1]) * f)
            q = (round(q[0], 4), round(q[1], 4))
            nodes.append(q); chain.append(q)
        chain.append(b)
        links += [(x, y, c) for x, y in zip(chain, chain[1:])]
    return nodes, links


def design(fam, outline, outline_links, ports, rr):
    """The whole set piece in the emblem's frame: {(u, v): role}, [(p, q, arc centre)]."""
    N_in, L_in, gold_out = interior(fam, outline, ports, rr)
    sub_nodes, sub_links = subdivide(outline_links)
    nodes = {p: "s" for p in outline}
    nodes.update({p: "s" for p in sub_nodes})
    nodes.update(N_in)
    for p in gold_out:
        nodes[p] = "N"
    return nodes, sub_links + L_in


def check(nodes, links, ports):
    """Problems: notables other than 3, a notable on a port, nodes closer than 0.72, crossing links, not mirrored."""
    out = []
    gold = [p for p, r in nodes.items() if r == "N"]
    if len(gold) != 3:
        out.append("notables %d" % len(gold))
    if any(p in ports for p in gold):
        out.append("notable on a port")
    pts = list(nodes)
    for i in range(len(pts)):
        for j in range(i + 1, len(pts)):
            if math.dist(pts[i], pts[j]) < 0.72:
                out.append("close %s %s" % (pts[i], pts[j]))
    for p, r in nodes.items():
        tw = _near(pts, (-p[0], p[1]), 0.1)
        if tw is None or nodes[tw] != r:
            out.append("unmirrored %s" % (p,))
    o = lambda p, q, r: (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    straight = [(a, b) for a, b, c in links if c is None]
    for i in range(len(straight)):
        for j in range(i + 1, len(straight)):
            a, b = straight[i]; c, d = straight[j]
            if {a, b} & {c, d}:
                continue
            if o(a, b, c) * o(a, b, d) < -1e-9 and o(c, d, a) * o(c, d, b) < -1e-9:
                out.append("cross %s-%s %s-%s" % (a, b, c, d))
    return out


EMBLEMS = [("fire", "star", 0, 48.0, 8.0), ("fire", "star", 0, 69.5, 6.4), ("earth", "fortress", 72, 48.0, 8.0), ("earth", "fortress", 72, 69.5, 6.4),
           ("metal", "blade", 144, 48.0, 8.0), ("metal", "blade", 144, 69.5, 6.4), ("water", "lotus", 216, 52.0, 7.4), ("water", "lotus", 216, 69.5, 6.4),
           ("wood", "leaf", 288, 48.0, 8.0), ("wood", "leaf", 288, 69.5, 6.4), ("blend", "circle", 36, 37.5, 4.6), ("blend", "circle", 36, 59.0, 5.6)]


def from_sketch():
    """The emblems' outlines from the A2 sketch, in each emblem's frame."""
    import sketch_a2
    g0, _ = sketch_a2.variant_a2()
    Nn = {n["id"]: n for n in g0.nodes}
    out = []
    for land, fam, ax, cv, rr in EMBLEMS:
        t = math.radians(ax)
        c = (cv * math.sin(t), cv * math.cos(t))
        loc = lambda p: (round((p[0] - c[0]) * math.cos(t) - (p[1] - c[1]) * math.sin(t), 4), round((p[0] - c[0]) * math.sin(t) + (p[1] - c[1]) * math.cos(t), 4))
        ids = {n["id"] for n in g0.nodes if math.dist((n["x"], n["y"]), c) <= rr + 0.8}
        P = {i: loc((Nn[i]["x"], Nn[i]["y"])) for i in ids}
        links = []
        for e in g0.edges:
            if e["a"] in ids and e["b"] in ids:
                cc = loc(tuple(e["arc"])) if e.get("arc") else None
                links.append((P[e["a"]], P[e["b"]], cc))
        ports = {P[i] for e in g0.edges for i, j in ((e["a"], e["b"]), (e["b"], e["a"])) if i in ids and j not in ids}
        # the stub below a lotus (a road node just outside the outline) is a road, not the figure
        stub = {p for p in P.values() if math.hypot(*p) > rr + 0.3}
        outline = [p for p in P.values() if p not in stub]
        links = [(a, b, cc) for a, b, cc in links if a not in stub and b not in stub]
        ports = {p for p in ports if p not in stub}
        for e in g0.edges:      # an outline node joined to the stub is a port
            for i, j in ((e["a"], e["b"]), (e["b"], e["a"])):
                if i in ids and j in ids and P[j] in stub and P[i] not in stub:
                    ports.add(P[i])
        out.append((land, fam, cv, rr, outline, links, ports))
    return out


def gallery(path):
    tiles = []
    for land, fam, cv, rr, outline, links, ports in from_sketch():
        nodes, ls = design(fam, outline, links, ports, rr)
        probs = check(nodes, ls, ports)
        R = rr + 2.0
        s = 360 / (2 * R)
        X = lambda p: (p[0] + R) * s
        Y = lambda p: (R - p[1]) * s
        svg = ['<svg viewBox="0 0 360 360">']
        for a, b, c in ls:
            if c is not None:
                r = math.dist(a, c) * s
                t1 = math.atan2(a[1] - c[1], a[0] - c[0]); t2 = math.atan2(b[1] - c[1], b[0] - c[0])
                dd = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
                svg.append('<path d="M%.1f,%.1f A%.1f,%.1f 0 0 %d %.1f,%.1f" fill="none" stroke="#8d8676" stroke-width="2"/>' % (X(a), Y(a), r, r, 0 if dd > 0 else 1, X(b), Y(b)))
            else:
                svg.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#8d8676" stroke-width="2"/>' % (X(a), Y(a), X(b), Y(b)))
        for p in ports:
            q = (p[0] * 1.25, p[1] * 1.25) if math.hypot(*p) > 0.1 else p
            svg.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" stroke="#3a6fd8" stroke-width="2.5" stroke-dasharray="4 3"/>' % (X(p), Y(p), X(q), Y(q)))
        for p, r in nodes.items():
            if r == "N":
                svg.append('<circle cx="%.1f" cy="%.1f" r="8" fill="#0e1319" stroke="#d8b25a" stroke-width="3"/>' % (X(p), Y(p)))
            else:
                svg.append('<circle cx="%.1f" cy="%.1f" r="4.5" fill="#c8c2b4"/>' % (X(p), Y(p)))
        svg.append("</svg>")
        gold = sum(1 for r in nodes.values() if r == "N")
        cap = "%s %s (%s, %s): %d nodes, %d notables%s" % (land.title(), fam, "middle" if cv < 60 else "outer", "r %.1f" % rr, len(nodes), gold,
                                                          "" if not probs else " | " + "; ".join(probs[:3]))
        tiles.append('<figure>%s<figcaption>%s</figcaption></figure>' % ("".join(svg), cap))
        print(cap)
    html = ('<title>Emblem Set Pieces</title><style>body{margin:0;background:#0b0f15;color:#ccc;font:13px sans-serif}main{display:grid;grid-template-columns:repeat(4,1fr);gap:8px;padding:8px}'
            'figure{margin:0}svg{width:100%;aspect-ratio:1;background:#0e1319}figcaption{padding:3px 0}</style><main>' + "".join(tiles) + "</main>")
    open(path, "w", encoding="utf-8").write(html)


if __name__ == "__main__":
    gallery(sys.argv[1])
