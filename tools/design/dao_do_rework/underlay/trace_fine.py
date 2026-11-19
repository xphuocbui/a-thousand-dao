"""Helpers for hand-traced figures (measurement only; Claude reads the lines' waypoints off the picture by hand and
chooses the chains, kinds and joins in the cell file). Used by shrine_trace.py and chaos_trace.py (2026-11-19).

Fine(img, cx, cy, half, road, ...) is trace_lib.Underlay with its spacing minima as parameters (the Sun's looser ones
for the Shrine, user 2026-11-19; the normal ones for Chaos), an optional mirror axis that keeps the traced half's
nodes off the axis, and a line test that takes any bright pixel that is neither road gold (when the picture's own roads
are not where the map's are) nor a grey road disc. ring() lays a circle of nodes analytically; mirror() reflects a
traced half across a vertical axis, joining the two halves at the nodes that lie on it.
"""
import json
import math
import os
import sys

from trace_lib import BASE, Underlay


class Fig:
    def __init__(self):
        self.nodes, self.links = {}, []


class Fine(Underlay):
    def __init__(self, path, cx, cy, half, road, node_min=0.62, link_min=0.37, axis=None, gap=0.25, gold_is_road=False):
        super().__init__(path, cx, cy, half, road)
        self.node_min, self.link_min, self.axis, self.gap, self.gold_is_road = node_min, link_min, axis, gap, gold_is_road
        self.clamp = axis is not None

    def line_px(self, x, y):
        r, g, b = self.px[x, y]
        m = max(r, g, b)
        if m <= 90 or (x, y) in self.roadpx:
            return False
        if m - min(r, g, b) < 40 and m < 150:            # a grey-brown road disc
            return False
        if self.gold_is_road and r > 150 and g > 100 and b < 120 and r - b > 60:
            return False
        return True

    def clear(self, q, linked=()):
        nm, lm = self.node_min, self.link_min
        for _ in range(30):
            moved = False
            for i, r in self.rnodes:
                if i in linked:
                    continue
                d = math.dist(q, r)
                if d < nm:
                    f = (nm - d) / max(d, 1e-6)
                    q = (q[0] + (q[0] - r[0]) * f, q[1] + (q[1] - r[1]) * f); moved = True
            for A, B in self.rsegs:
                vx, vy = B[0] - A[0], B[1] - A[1]
                L2 = vx * vx + vy * vy
                t = max(0.0, min(1.0, ((q[0] - A[0]) * vx + (q[1] - A[1]) * vy) / L2)) if L2 else 0.0
                P = (A[0] + t * vx, A[1] + t * vy)
                d = math.dist(q, P)
                if d < lm and min(math.dist(q, A), math.dist(q, B)) > 0.05:
                    f = (lm - d) / max(d, 1e-6)
                    q = (q[0] + (q[0] - P[0]) * f, q[1] + (q[1] - P[1]) * f); moved = True
            if self.clamp and q[0] < self.axis + self.gap:
                q = (self.axis + self.gap, q[1]); moved = True
            if not moved:
                break
        return q


def _segs(A, B, c):
    """A link as short segments (an arc link sampled the shorter way round its centre, as the renderers draw it)."""
    if not c:
        return [(A, B)]
    r = math.dist(A, c)
    t1, t2 = math.atan2(A[1] - c[1], A[0] - c[0]), math.atan2(B[1] - c[1], B[0] - c[0])
    dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    pl = [(c[0] + r * math.cos(t1 + dt * i / 16), c[1] + r * math.sin(t1 + dt * i / 16)) for i in range(17)]
    return list(zip(pl, pl[1:]))


def _dseg(q, A, B):
    vx, vy = B[0] - A[0], B[1] - A[1]
    L2 = vx * vx + vy * vy or 1e-9
    t = max(0.0, min(1.0, ((q[0] - A[0]) * vx + (q[1] - A[1]) * vy) / L2))
    return math.dist(q, (A[0] + t * vx, A[1] + t * vy))


def thin_at(fig, road, node_gap, link_gap):
    """trace_lib.thin with its minima as parameters: drops a re-spaced small node (degree 2, key with '_') closer than
    node_gap to an unlinked node of its figure, or link_gap to a link not touching it, joining its neighbours by an
    arc through where it was."""
    from trace_lib import circum
    xy = lambda k: fig.nodes[k][0] if isinstance(k, str) else road(k)
    while True:
        adj = {}
        for a, b, _ in fig.links:
            adj.setdefault(a, set()).add(b)
            adj.setdefault(b, set()).add(a)
        bad = None
        for k, (p, kind) in fig.nodes.items():
            if kind != 'small' or len(adj.get(k, ())) != 2 or '_' not in k:
                continue
            if any(k2 != k and k2 not in adj[k] and math.dist(p, q) < node_gap for k2, (q, _) in fig.nodes.items()):
                bad = k
                break
            for a2, b2, c2 in fig.links:
                if k in (a2, b2):
                    continue
                if min(_dseg(p, A, B) for A, B in _segs(xy(a2), xy(b2), c2)) < link_gap:
                    bad = k
                    break
            if bad:
                break
        if not bad:
            return
        u, v = sorted(adj[bad], key=str)
        P = fig.nodes.pop(bad)[0]
        fig.links = [l for l in fig.links if bad not in l[:2]]
        A, B = xy(u), xy(v)
        c = circum(A, P, B)
        fig.links.append((u, v, c if c is not None and math.dist(c, A) < 60 else None))


def ring(U, fig, key, cpx, rpx, angles, kinds, closed=True):
    """Nodes on the circle round picture point cpx (radius rpx pixels) at the given angles (degrees clockwise from the
    picture's top), linked in order by arcs round the centre. Returns the keys."""
    C = U.to_map(cpx)
    ks = []
    for a, kd in zip(angles, kinds):
        t = math.radians(a)
        p = U.to_map((cpx[0] + rpx * math.sin(t), cpx[1] - rpx * math.cos(t)))
        k = f'{key}{int(round(a))}'
        fig.nodes[k] = (p, kd)
        ks.append(k)
    seq = ks + ([ks[0]] if closed else [])
    fig.links += [(a, b, C) for a, b in zip(seq, seq[1:])]
    return ks


def link(fig, a, b, c=None):
    fig.links.append((a, b, c))


def mirror(fig, axis, road, eps=0.06):
    """The traced half plus its reflection across x = axis. Nodes within eps of the axis are snapped onto it and shared;
    road ids map to the travel node nearest the reflected position."""
    M = json.load(open(BASE, encoding='utf-8'))
    travel = [(n['id'], (n['x'], n['y'])) for n in M['nodes'] if n['kind'] in ('travel', 'start')]
    out = Fig()
    on = set()
    for k, (p, kd) in fig.nodes.items():
        if abs(p[0] - axis) < eps:
            out.nodes[k] = ((axis, p[1]), kd); on.add(k)
        else:
            out.nodes[k] = (p, kd)
            out.nodes[k + "'"] = ((2 * axis - p[0], p[1]), kd)

    def m(k):
        if isinstance(k, int):
            q = road(k)
            return min(travel, key=lambda t: math.dist(t[1], (2 * axis - q[0], q[1])))[0]
        return k if k in on else k + "'"
    seen = set()
    for a, b, c in fig.links:
        for e in ((a, b, c), (m(a), m(b), (2 * axis - c[0], c[1]) if c else None)):
            key = frozenset((e[0], e[1]))
            if key in seen:
                continue
            seen.add(key)
            out.links.append(e)
    return out


def _cross(p1, p2, q1, q2):
    d = lambda a, b, c: (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])
    return (d(p1, p2, q1) * d(p1, p2, q2) < 0) and (d(q1, q2, p1) * d(q1, q2, p2) < 0)


def settle(fig, road, own_node, own_link, other_node=None, other_link=None, others=(), protect=(), rounds=600, cap=10 ** 6, max_chord=1.6):
    """Where the piece breaks the spacing rules (its own nodes and links; and, given `others` as [(points, segments)],
    other pieces' and roads'), or two of its links cross, the smaller dead-end stroke there is dropped (a notable end
    back to its first fork); a node on a loop is dropped instead, its neighbours joined. Never a node in `protect` (the
    doors' first nodes) or a road. Report only of what it dropped: returns the count."""
    xy = lambda k: fig.nodes[k][0] if isinstance(k, str) else road(k)
    o_pts = [p for pts, _ in others for p in pts]
    o_seg = [s for _, segs in others for s in segs]
    G = 1.0
    grid = {}
    for A, B in o_seg:
        for gx in range(int(math.floor(min(A[0], B[0]) / G)) - 1, int(math.floor(max(A[0], B[0]) / G)) + 2):
            for gy in range(int(math.floor(min(A[1], B[1]) / G)) - 1, int(math.floor(max(A[1], B[1]) / G)) + 2):
                grid.setdefault((gx, gy), []).append((A, B))
    ogrid = {}
    for p in o_pts:
        ogrid.setdefault((int(math.floor(p[0] / G)), int(math.floor(p[1] / G))), []).append(p)
    dropped = 0
    for _ in range(rounds):
        adj = {}
        for a, b, _c in fig.links:
            adj.setdefault(a, set()).add(b)
            adj.setdefault(b, set()).add(a)
        segs = [((a, b), sg) for a, b, c in fig.links for sg in _segs(xy(a), xy(b), c)]
        sgrid, ngrid = {}, {}
        for e, (A, B) in segs:
            for gx in range(int(math.floor(min(A[0], B[0]) / G)) - 1, int(math.floor(max(A[0], B[0]) / G)) + 2):
                for gy in range(int(math.floor(min(A[1], B[1]) / G)) - 1, int(math.floor(max(A[1], B[1]) / G)) + 2):
                    sgrid.setdefault((gx, gy), []).append((e, A, B))
        for k, (p, _k) in fig.nodes.items():
            ngrid.setdefault((int(math.floor(p[0] / G)), int(math.floor(p[1] / G))), []).append(k)
        bad = []
        for k, (p, _k) in fig.nodes.items():
            g = (int(math.floor(p[0] / G)), int(math.floor(p[1] / G)))
            near = [(g[0] + dx, g[1] + dy) for dx in (-1, 0, 1) for dy in (-1, 0, 1)]
            for c in near:
                for k2 in ngrid.get(c, ()):
                    if str(k2) > str(k) and k2 not in adj.get(k, ()) and math.dist(p, fig.nodes[k2][0]) < own_node:
                        bad.append((k, k2))
            for (a, b), A, B in sgrid.get(g, ()):
                if k not in (a, b) and _dseg(p, A, B) < own_link:
                    bad.append((k, a, b))
            if other_node is not None:
                if any(math.dist(p, q) < other_node for c in near for q in ogrid.get(c, ()) if math.dist(p, q) > 1e-6):
                    bad.append((k,))
                elif any(_dseg(p, A, B) < other_link for A, B in grid.get(g, ())
                         if min(math.dist(p, A), math.dist(p, B)) > 1e-6):
                    bad.append((k,))
        if not bad:
            for cell, lst in sgrid.items():
                for i, (e1, A, B) in enumerate(lst):
                    for e2, C, D in lst[i + 1:]:
                        if not set(e1) & set(e2) and _cross(A, B, C, D):
                            bad.append(e1 + e2)
                            break
                    if bad:
                        break
                if bad:
                    break
        if not bad:
            return dropped

        def walk(start, first):
            """From start towards first along degree-2 nodes: the nodes passed and where it stops."""
            seen, prev, cur = [], start, first
            while isinstance(cur, str) and len(adj.get(cur, ())) == 2 and cur != start:
                seen.append(cur)
                prev, cur = cur, [v for v in adj[cur] if v != prev][0]
            return seen, cur

        def leaf(k):
            """The dead-end stroke through k: from its free end back to (not including) the first fork."""
            if isinstance(k, int) or k not in fig.nodes:
                return None
            nb_ = list(adj.get(k, ()))
            if len(nb_) == 1:
                seen, stop = walk(k, nb_[0])
                return [k] + seen
            if len(nb_) == 2:
                s1, e1 = walk(k, nb_[0])
                s2, e2 = walk(k, nb_[1])
                for (sa, ea), (sb, eb) in (((s1, e1), (s2, e2)), ((s2, e2), (s1, e1))):
                    if isinstance(ea, str) and len(adj.get(ea, ())) == 1:     # a dead end that way
                        return [k] + sa + [ea] + sb
            return None
        def stroke(k):
            """The stroke through k: its run of degree-2 nodes between junctions or roads, with its free end if any."""
            if isinstance(k, int) or k not in fig.nodes:
                return None
            nb_ = list(adj.get(k, ()))
            if len(nb_) == 1:
                seen, stop = walk(k, nb_[0])
                return [k] + seen
            if len(nb_) != 2:
                return None
            s1, e1 = walk(k, nb_[0])
            s2, e2 = walk(k, nb_[1])
            run = [k] + s1 + s2
            for e in (e1, e2):
                if isinstance(e, str) and len(adj.get(e, ())) == 1:
                    run.append(e)
            return run

        def connected_without(L):
            gone = set(L)
            held, stack = set(), [k for k in adj if isinstance(k, int)]
            held.update(stack)
            while stack:
                u = stack.pop()
                for v in adj.get(u, ()):
                    if v not in held and v not in gone:
                        held.add(v); stack.append(v)
            return all(k in held for k in fig.nodes if k not in gone)

        cands = []
        for v in bad:
            if all(isinstance(k, int) or k in protect for k in v):
                continue
            for k in v:
                if not isinstance(k, str) or k in protect or k not in fig.nodes:
                    continue
                nb_ = list(adj.get(k, ()))
                if len(nb_) == 2 and fig.nodes[k][1] != 'notable' and math.dist(xy(nb_[0]), xy(nb_[1])) < max_chord:
                    cands.append((0, 0, [k]))                     # a node on a line: drop it, keep the line
                    continue
                if fig.nodes[k][1] == 'notable' and len(nb_) == 1 and isinstance(nb_[0], str) and                         nb_[0] not in protect and len(adj.get(nb_[0], ())) == 2:
                    cands.append((0, 1, ['tip', k, nb_[0]]))       # a tip too close: one node shorter
                    continue
                L = stroke(k)
                if L and not set(L) & set(protect):
                    tip = any(len(adj.get(x, ())) == 1 for x in L)    # dead-end strokes before loop edges
                    cands.append((1 if tip else 2, len(L), L))
        cands.sort(key=lambda c: (c[0], c[1]))
        pick = next((c for c in cands if c[0] == 0 or connected_without(c[2])), None)
        if pick is None or dropped >= cap:
            return dropped
        kind, _, L = pick
        kind = 1 if kind else 0
        if os.environ.get('SETTLE_LOG'):
            why = next(v for v in bad if any(k in L for k in v))
            print('settle drop', 'node' if kind == 0 else f'stroke of {len(L)}', 'for', why, 'at', [tuple(round(c, 1) for c in fig.nodes[x][0]) for x in L if x in fig.nodes][:3], file=sys.stderr)
        if L[0] == 'tip':
            _, k, u = L
            fig.nodes.pop(k)
            fig.links = [l for l in fig.links if k not in l[:2]]
            fig.nodes[u] = (fig.nodes[u][0], 'notable')
        elif kind == 1:
            for k in L:
                fig.nodes.pop(k, None)
            fig.links = [l for l in fig.links if l[0] not in L and l[1] not in L]
        else:
            k = L[0]
            u, v = sorted(adj[k], key=str)
            P = fig.nodes.pop(k)[0]
            fig.links = [l for l in fig.links if k not in l[:2]]
            from trace_lib import circum
            c = circum(xy(u), P, xy(v))
            wide = c is None or math.dist(c, xy(u)) > 60 or math.dist(xy(u), xy(v)) < 1.2 * math.dist(c, xy(u))
            fig.links.append((u, v, None if wide else c))      # an arc only where it bends gently
        dropped += 1
    return dropped
