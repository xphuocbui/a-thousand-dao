"""Measures curves on an underlay image for hand-traced pieces (measurement only; the chains, kinds and joins are chosen by
hand in the cell file). An image covers centre +- half in map units; +x right, +y down, as render_box.py draws.

Underlay(img, cx, cy, half).chain(fig, keys) links consecutive entries of keys; each entry is a road id (int) or a
(node key, (px, py), kind) triple for a new node at that pixel. Each link is an arc through the drawn line: the
nearest ink to the chord's midpoint along its perpendicular bisector; straight if no ink is found there. 'mid' entries
(('mid', kind)) add a node on the drawn line halfway between their neighbours.
"""
import heapq
import json
import math
import os

from PIL import Image

BASE = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..', 'base-map.json')


def circum(a, b, c):
    ax, ay = a
    bx, by = b
    cx, cy = c
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    if abs(d) < 1e-9:
        return None
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return (ux, uy)


class Underlay:
    def __init__(self, path, cx, cy, half, road):
        im = Image.open(path).convert('RGB')
        self.W, self.H = im.size
        self.px = im.load()
        self.cx, self.cy, self.half, self.road = cx, cy, half, road
        self.k = 2 * half / self.W                       # map units per pixel
        M = json.load(open(BASE, encoding='utf-8'))
        Nn = {n['id']: n for n in M['nodes']}
        box = lambda q: abs(q[0] - cx) < half + 3 and abs(q[1] - cy) < half + 3
        self.rnodes = [(n['id'], (n['x'], n['y'])) for n in M['nodes'] if box((n['x'], n['y']))]
        self.rsegs = []
        for e in M['edges']:
            A, B = (Nn[e['a']]['x'], Nn[e['a']]['y']), (Nn[e['b']]['x'], Nn[e['b']]['y'])
            if not (box(A) or box(B)):
                continue
            c = e.get('arc')
            if c:
                r = math.dist(A, c)
                t1 = math.atan2(A[1] - c[1], A[0] - c[0]); t2 = math.atan2(B[1] - c[1], B[0] - c[0])
                dt = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
                pl = [(c[0] + r * math.cos(t1 + dt * i / 24), c[1] + r * math.sin(t1 + dt * i / 24)) for i in range(25)]
            else:
                pl = [A, B]
            self.rsegs += list(zip(pl, pl[1:]))

    def clear(self, q, linked=()):
        """Moves a traced node straight out to the spacing minimum from road and start nodes (0.9; those it links to
        are exempt) and road links (0.6), and no further: the image model drew without our spacing rules."""
        for _ in range(30):
            moved = False
            for i, r in self.rnodes:
                if i in linked:
                    continue
                dd = math.dist(q, r)
                if dd < 0.92:
                    f = (0.92 - dd) / max(dd, 1e-6)
                    q = (q[0] + (q[0] - r[0]) * f, q[1] + (q[1] - r[1]) * f); moved = True
            for A, B in self.rsegs:
                vx, vy = B[0] - A[0], B[1] - A[1]
                L2 = vx * vx + vy * vy
                t = max(0.0, min(1.0, ((q[0] - A[0]) * vx + (q[1] - A[1]) * vy) / L2)) if L2 else 0.0
                P = (A[0] + t * vx, A[1] + t * vy)
                dd = math.dist(q, P)
                if dd < 0.62 and (min(math.dist(q, A), math.dist(q, B)) > 0.05):
                    f = (0.62 - dd) / max(dd, 1e-6)
                    q = (q[0] + (q[0] - P[0]) * f, q[1] + (q[1] - P[1]) * f); moved = True
            if not moved:
                break
        return q

    def to_map(self, p):
        return (self.cx - self.half + p[0] * self.k, self.cy - self.half + p[1] * self.k)

    def to_px(self, q):
        return ((q[0] - self.cx + self.half) / self.k, (q[1] - self.cy + self.half) / self.k)

    def ink(self, q):
        x, y = self.to_px(q)
        if not (0 <= x < self.W - 1 and 0 <= y < self.H - 1):
            return False
        r, g, b = self.px[int(x), int(y)]
        return max(r, g, b) > 80

    def line_px(self, x, y):
        r, g, b = self.px[x, y]
        if b > 120 and r > 100 and b >= r - 10 and max(r, g, b) > 120:
            return True                                   # silver ornament
        return r > 170 and g > 120 and b < 150 and (x, y) not in self.roadpx   # gold ornament, off the roads

    def path(self, A, B, avoid=(), wide=0.75):
        """The drawn line from map point A to B: cheapest pixel path, ink cheap, gaps dear, other dots' discs closed."""
        if not hasattr(self, 'roadpx'):
            self.roadpx = set()
            for P0, P1 in self.rsegs:
                a, b = self.to_px(P0), self.to_px(P1)
                n = int(math.dist(a, b)) + 1
                for i in range(n + 1):
                    x, y = a[0] + (b[0] - a[0]) * i / n, a[1] + (b[1] - a[1]) * i / n
                    for dx in range(-3, 4):
                        for dy in range(-3, 4):
                            self.roadpx.add((int(x) + dx, int(y) + dy))
        a, b = self.to_px(A), self.to_px(B)
        L = math.dist(a, b)
        m = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2)
        R = L * wide + 8
        av = [self.to_px(q) for q in avoid]
        sa, sb = (int(round(a[0])), int(round(a[1]))), (int(round(b[0])), int(round(b[1])))
        dist = {sa: 0.0}
        prev = {}
        pq = [(0.0, sa)]
        while pq:
            dd, u = heapq.heappop(pq)
            if u == sb or math.dist(u, b) < 2:
                sb = u
                break
            if dd > dist.get(u, 1e18):
                continue
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    if not dx and not dy:
                        continue
                    v = (u[0] + dx, u[1] + dy)
                    if not (0 <= v[0] < self.W and 0 <= v[1] < self.H) or math.dist(v, m) > R:
                        continue
                    if any(math.dist(v, o) < 5 for o in av):
                        continue
                    near_end = math.dist(v, a) < 7 or math.dist(v, b) < 7
                    w = (1.0 if (near_end or self.line_px(*v)) else 25.0) * (1.414 if dx and dy else 1.0)
                    nd = dd + w
                    if nd < dist.get(v, 1e18):
                        dist[v] = nd
                        prev[v] = u
                        heapq.heappush(pq, (nd, v))
        if sb not in prev:
            return None
        pts, u = [sb], sb
        while u != sa:
            u = prev[u]
            pts.append(u)
        pts.reverse()
        gap = sum(1 for q in pts if not (math.dist(q, a) < 7 or math.dist(q, b) < 7 or self.line_px(*q)))
        if gap > 6:
            return None
        return [self.to_map(q) for q in pts]

    def on_line(self, A, B, reach=0.45):
        """The drawn point on the perpendicular bisector of A-B nearest to the chord midpoint, or None."""
        m = ((A[0] + B[0]) / 2, (A[1] + B[1]) / 2)
        L = math.dist(A, B)
        n = (-(B[1] - A[1]) / L, (B[0] - A[0]) / L)
        step = self.k / 2
        best = None
        for i in range(int(reach * L / step)):
            for sgn in (1, -1):
                q = (m[0] + sgn * i * step * n[0], m[1] + sgn * i * step * n[1])
                if self.ink(q):
                    best = q
                    break
            if best:
                break
        if best is None:
            return None
        # the line has width: walk to the middle of the ink run
        sgn = 1 if (best[0] - m[0]) * n[0] + (best[1] - m[1]) * n[1] >= 0 else -1
        run = [best]
        q = best
        for _ in range(12):
            q = (q[0] + sgn * step * n[0], q[1] + sgn * step * n[1])
            if not self.ink(q):
                break
            run.append(q)
        return run[len(run) // 2]

    def chain(self, fig, keys, straight=()):
        pts = []
        for n, e in enumerate(keys):
            if isinstance(e, int):
                pts.append((e, self.road(e)))
            elif isinstance(e, str):
                pts.append((e, fig.nodes[e][0]))
            elif e[0] == 'mid':
                pts.append(e)
            else:
                k, p, kind = e
                linked = {x for x in (keys[n - 1] if n else None, keys[n + 1] if n + 1 < len(keys) else None)
                          if isinstance(x, int)}
                xy = self.clear(self.to_map(p), linked)
                fig.nodes[k] = (xy, kind)
                pts.append((k, xy))
        out = [e for e in pts if e[0] != 'mid']           # extra nodes now come only from the drawn line's turns
        others = [xy for _, xy in out]
        for (a, A), (b, B) in zip(out, out[1:]):
            if (a, b) in straight or (b, a) in straight:
                fig.links.append((a, b, None))
                continue
            av = [q for q in others if q not in (A, B)]
            pl = self.path(A, B, avoid=av) or self.path(A, B, avoid=av, wide=1.6)
            if pl is None:
                self.fallbacks = getattr(self, 'fallbacks', []) + [(a, b)]
                M = self.on_line(A, B)
                fig.links.append((a, b, circum(A, M, B) if M else None))
                continue
            pl[0], pl[-1] = A, B
            self._follow(fig, a, b, pl)

    def _follow(self, fig, a, b, pl, depth=0):
        """Link a-b along polyline pl (map points): one arc through its middle, or split on the line where it turns
        more than 140 degrees."""
        n = len(pl)
        cum = [0.0]
        for p, q in zip(pl, pl[1:]):
            cum.append(cum[-1] + math.dist(p, q))
        tot = cum[-1]
        at = lambda f: pl[min(range(n), key=lambda i: abs(cum[i] - f * tot))]
        A, B = pl[0], pl[-1]
        sm = [at(i / 10) for i in range(11)]                # integrated turning, so spirals past 180 count in full
        hs = [math.atan2(q[1] - p[1], q[0] - p[0]) for p, q in zip(sm, sm[1:]) if math.dist(p, q) > 1e-6]
        turn = abs(sum((math.degrees(h2 - h1) + 180) % 360 - 180 for h1, h2 in zip(hs, hs[1:])))
        mi = min(range(n), key=lambda i: abs(cum[i] - tot / 2))
        if turn > 140 and depth < 3 and tot > 1.6:
            k = f'{a}_{b}_t{depth}'
            fig.nodes[k] = (pl[mi], 'small')
            self._follow(fig, a, k, pl[:mi + 1], depth + 1)
            self._follow(fig, k, b, pl[mi:], depth + 1)
            return
        c = circum(A, pl[mi], B)
        if c is not None and math.dist(c, A) > 60:
            c = None
        fig.links.append((a, b, c))


def even_chain(U, fig, keys, step=1.15, pre=None, direct=()):
    """Like Underlay.chain, but the picture's dots are only waypoints of the drawn line: nodes are re-spaced evenly
    along it (about `step` apart). Fixed points stay where they are: road ids, existing node keys, and triples whose
    kind is 'notable' (eyes, tips). A segment from a road to a notable gets at least two smalls (rule R3)."""
    pre = pre or f'e{len(fig.nodes)}_'
    pts = []
    for n, e in enumerate(keys):
        if isinstance(e, int):
            pts.append(('fix', e, U.road(e)))
        elif isinstance(e, str):
            pts.append(('fix', e, fig.nodes[e][0]))
        elif e[0] == 'mid':
            continue
        else:
            k, p, kind = e
            linked = {x for x in (keys[n - 1] if n else None, keys[n + 1] if n + 1 < len(keys) else None) if isinstance(x, int)}
            xy = U.clear(U.to_map(p), linked)
            if kind in ('notable', 'small!'):
                fig.nodes[k] = (xy, kind.rstrip('!'))
                pts.append(('fix', k, xy))
            else:
                pts.append(('way', k, xy))
    # the drawn line through all points
    line = [pts[0][2]]
    marks = [0]                                       # index in line of each point
    for (_, ka, A), (_, kb, B) in zip(pts, pts[1:]):
        if (ka, kb) in direct or (kb, ka) in direct:
            pl = [A, B]
        else:
            pl = U.path(A, B) or U.path(A, B, wide=1.6) or [A, B]
        if len(pl) == 2:
            pl = [(A[0] + (B[0] - A[0]) * t / 20, A[1] + (B[1] - A[1]) * t / 20) for t in range(21)]
        pl[0], pl[-1] = A, B
        line += pl[1:]
        marks.append(len(line) - 1)
    fixed = [i for i, p in enumerate(pts) if p[0] == 'fix']
    cnt = 0
    for fa, fb in zip(fixed, fixed[1:]):
        seg = line[marks[fa]:marks[fb] + 1]
        cum = [0.0]
        for p, q in zip(seg, seg[1:]):
            cum.append(cum[-1] + math.dist(p, q))
        L = cum[-1]
        n = max(0, round(L / step) - 1)
        a_key, b_key = pts[fa][1], pts[fb][1]
        b_kind = fig.nodes[b_key][1] if isinstance(b_key, str) else None
        if isinstance(a_key, int) and b_kind == 'notable':
            n = max(n, 2)
        ra, rb = isinstance(a_key, int), isinstance(b_key, int)
        if not n:
            tg = []
        elif ra and rb:
            tg = [0.95 + (L - 1.9) * j / (n - 1) for j in range(n)] if n > 1 else [L / 2]
        elif ra:                                          # first node 0.95 out from its road, then even
            tg = [0.95 + (L - 0.95) * j / n for j in range(n)]
        elif rb:
            tg = [L - 0.95 - (L - 0.95) * (n - 1 - j) / n for j in range(n)]
        else:
            tg = [L * (j + 1) / (n + 1) for j in range(n)]
        cuts = [0] + [min(range(len(seg)), key=lambda i: abs(cum[i] - t)) for t in tg] + [len(seg) - 1]
        keys2 = [a_key]
        for j in range(n):
            k = f'{pre}{cnt}'
            cnt += 1
            linked = {x for x in (a_key if j == 0 else None, b_key if j == n - 1 else None) if isinstance(x, int)}
            fig.nodes[k] = (U.clear(seg[cuts[j + 1]], linked), 'small')
            keys2.append(k)
        keys2.append(b_key)
        for j in range(len(keys2) - 1):
            sub = seg[cuts[j]:cuts[j + 1] + 1]
            A = fig.nodes[keys2[j]][0] if isinstance(keys2[j], str) else U.road(keys2[j])
            B = fig.nodes[keys2[j + 1]][0] if isinstance(keys2[j + 1], str) else U.road(keys2[j + 1])
            M = sub[len(sub) // 2]
            c = circum(A, M, B) if len(sub) > 2 else None
            if c is not None and math.dist(c, A) > 60:
                c = None
            fig.links.append((keys2[j], keys2[j + 1], c))


def thin(fig, gap=0.78):
    """Drops a re-spaced small node (degree 2) that sits closer than `gap` to a node of its own figure it is not linked
    to, joining its two neighbours by an arc through where it was."""
    while True:
        adj = {}
        for a, b, _ in fig.links:
            adj.setdefault(a, set()).add(b)
            adj.setdefault(b, set()).add(a)
        bad = None
        for k, (p, kind) in fig.nodes.items():
            if kind != 'small' or len(adj.get(k, ())) != 2 or '_' not in k:
                continue
            for k2, (q, _) in fig.nodes.items():
                if k2 != k and k2 not in adj[k] and math.dist(p, q) < gap:
                    bad = k
                    break
            if not bad:
                from celllib import road
                for a2, b2, _ in fig.links:
                    if k in (a2, b2):
                        continue
                    A = fig.nodes[a2][0] if isinstance(a2, str) else road(a2)
                    B = fig.nodes[b2][0] if isinstance(b2, str) else road(b2)
                    vx, vy = B[0] - A[0], B[1] - A[1]
                    L2 = vx * vx + vy * vy or 1e-9
                    t = max(0.0, min(1.0, ((p[0] - A[0]) * vx + (p[1] - A[1]) * vy) / L2))
                    if math.dist(p, (A[0] + t * vx, A[1] + t * vy)) < 0.52:
                        bad = k
                        break
            if bad:
                break
        if not bad:
            return
        u, v = sorted(adj[bad], key=str)
        P = fig.nodes.pop(bad)[0]
        fig.links = [l for l in fig.links if bad not in l[:2]]
        xy = lambda k: fig.nodes[k][0] if isinstance(k, str) else None
        A, B = xy(u), xy(v)
        if A is None or B is None:
            from celllib import road
            A = A or road(u); B = B or road(v)
        c = circum(A, P, B)
        fig.links.append((u, v, c if c is not None and math.dist(c, A) < 60 else None))
