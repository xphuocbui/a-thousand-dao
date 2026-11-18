"""Render and check the Đạo Đồ small-family sheet (rules-2026-11-18.md 3.4, decision 6.3).

usage: python -I tools/design/dao_do_rework/families/sheet.py <families.json> <out.html> [<out.png>]

Check and render only: it never chooses or changes a placement. For each family's example link styles it reports the
hard rules of 3.2 (joined; R2 no dead-end minor node, the entry counts its road link; R3 first notable 2+ steps past
the entry; R4 a notable; nodes 0.7 apart inside a cluster; a node 0.3 from any link not its own; no crossings) and
the observations (size, form). A PNG is taken with headless Chrome or Edge when <out.png> is given.
"""
import collections
import html
import json
import math
import os
import pathlib
import subprocess
import sys
import tempfile

STEPS = 24


def arc_points(p, q, bow, centre):
    """Points along the link p->q: a circular arc whose sagitta is bow x chord, bulging away from centre if bow > 0."""
    if abs(bow) < 1e-9:
        return [p, q]
    mx, my = (p[0] + q[0]) / 2, (p[1] + q[1]) / 2
    dx, dy = q[0] - p[0], q[1] - p[1]
    L = math.hypot(dx, dy)
    nx, ny = -dy / L, dx / L
    if (mx - centre[0]) * nx + (my - centre[1]) * ny < 0:
        nx, ny = -nx, -ny
    h = bow * L
    # quadratic-free circle through p, q and the apex
    ax, ay = mx + nx * h, my + ny * h
    r = (L * L / 4 + h * h) / (2 * abs(h))
    cx, cy = ax - nx * r * (1 if h > 0 else -1), ay - ny * r * (1 if h > 0 else -1)
    a0 = math.atan2(p[1] - cy, p[0] - cx)
    a1 = math.atan2(q[1] - cy, q[0] - cx)
    am = math.atan2(ay - cy, ax - cx)
    # go from a0 to a1 through am
    def norm(a):
        while a < 0:
            a += 2 * math.pi
        return a % (2 * math.pi)
    d1, dm = norm(a1 - a0), norm(am - a0)
    span = d1 if dm <= d1 else d1 - 2 * math.pi
    return [(cx + r * math.cos(a0 + span * t / STEPS), cy + r * math.sin(a0 + span * t / STEPS)) for t in range(STEPS + 1)]


def seg_dist(p, a, b):
    vx, vy = b[0] - a[0], b[1] - a[1]
    L2 = vx * vx + vy * vy
    t = 0 if L2 == 0 else max(0, min(1, ((p[0] - a[0]) * vx + (p[1] - a[1]) * vy) / L2))
    return math.hypot(p[0] - a[0] - t * vx, p[1] - a[1] - t * vy)


def cross(a, b, c, d):
    def o(p, q, r):
        return (q[0] - p[0]) * (r[1] - p[1]) - (q[1] - p[1]) * (r[0] - p[0])
    return (o(a, b, c) * o(a, b, d) < -1e-12) and (o(c, d, a) * o(c, d, b) < -1e-12)


def check(nodes, links):
    n = len(nodes)
    P = [(x, y) for x, y, _ in nodes]
    kind = [k for _, _, k in nodes]
    cen = (sum(p[0] for p in P) / n, sum(p[1] for p in P) / n)
    adj = collections.defaultdict(set)
    for i, j, _ in links:
        adj[i].add(j)
        adj[j].add(i)
    out = []
    # joined
    seen, st = {0}, [0]
    while st:
        u = st.pop()
        for v in adj[u]:
            if v not in seen:
                seen.add(v)
                st.append(v)
    if len(seen) != n:
        out.append("not joined")
    deg = {i: len(adj[i]) + (1 if i == 0 else 0) for i in range(n)}
    dead = [i for i in range(n) if kind[i] == "s" and deg[i] <= 1]
    if dead:
        out.append("R2 dead-end minor %s" % dead)
    dist = {0: 0}
    q = collections.deque([0])
    while q:
        u = q.popleft()
        for v in adj[u]:
            if v not in dist:
                dist[v] = dist[u] + 1
                q.append(v)
    nots = [i for i in range(n) if kind[i] == "N"]
    if not nots:
        out.append("R4 no notable")
    elif min(dist.get(i, 99) for i in nots) < 2:
        out.append("R3 notable %d step(s) from the entry" % min(dist.get(i, 99) for i in nots))
    for a in range(n):
        for b in range(a + 1, n):
            if math.dist(P[a], P[b]) < 0.7:
                out.append("nodes %d-%d %.2f apart" % (a, b, math.dist(P[a], P[b])))
    curves = [(i, j, arc_points(P[i], P[j], bow, cen)) for i, j, bow in links]
    for k in range(n):
        for i, j, pts in curves:
            if k in (i, j):
                continue
            d = min(seg_dist(P[k], pts[t], pts[t + 1]) for t in range(len(pts) - 1))
            if d < 0.3:
                out.append("node %d %.2f from link %d-%d" % (k, d, i, j))
    for x in range(len(curves)):
        for y in range(x + 1, len(curves)):
            i1, j1, p1 = curves[x]
            i2, j2, p2 = curves[y]
            if {i1, j1} & {i2, j2}:
                continue
            if any(cross(p1[s], p1[s + 1], p2[t], p2[t + 1]) for s in range(len(p1) - 1) for t in range(len(p2) - 1)):
                out.append("links %d-%d and %d-%d cross" % (i1, j1, i2, j2))
    e_in = len(links)
    cyc = e_in - n + 1
    maxdeg = max(len(adj[i]) for i in range(n))
    form = ("chain" if maxdeg <= 2 else "branch") if cyc == 0 else ("one loop" if cyc == 1 else "multi-loop")
    return out, form, curves, cen


def svg_cell(fam, ex, curves, cen, problems, form, size=170, scale=34):
    P = [(x, y) for x, y, _ in fam["nodes"]]
    xs = [p[0] for p in P]
    ys = [p[1] for p in P]
    ox = size / 2 - scale * (min(xs) + max(xs)) / 2
    oy = size / 2 + 8 + scale * (min(ys) + max(ys)) / 2
    tx = lambda p: (ox + scale * p[0], oy - scale * p[1])
    parts = []
    # road link stub into the entry, from away from the centre
    e = P[0]
    vx, vy = e[0] - cen[0], e[1] - cen[1]
    L = math.hypot(vx, vy) or 1
    road = (e[0] + 1.3 * vx / L, e[1] + 1.3 * vy / L)
    a, b = tx(road), tx(e)
    parts.append('<line x1="%.1f" y1="%.1f" x2="%.1f" y2="%.1f" class="road"/>' % (a[0], a[1], b[0], b[1]))
    parts.append('<circle cx="%.1f" cy="%.1f" r="4.5" class="roadnode"/>' % a)
    for i, j, pts in curves:
        d = "M" + " L".join("%.1f %.1f" % tx(p) for p in pts)
        parts.append('<path d="%s" class="link"/>' % d)
    for k, (x, y, kd) in enumerate(fam["nodes"]):
        c = tx((x, y))
        parts.append('<circle cx="%.1f" cy="%.1f" r="%s" class="%s"/>' % (c[0], c[1], "7" if kd == "N" else "4.5",
                                                                         "notable" if kd == "N" else "small"))
    label = html.escape(ex["style"])
    status = "ok" if not problems else "; ".join(problems)
    return ('<div class="cell"><svg width="%d" height="%d">%s</svg><div class="cap">%s · %s</div>'
            '<div class="chk %s">%s</div></div>' % (size, size, "".join(parts), label, form,
                                                    "good" if not problems else "bad", html.escape(status)))


def main():
    src, out_html = sys.argv[1], sys.argv[2]
    out_png = sys.argv[3] if len(sys.argv) > 3 else None
    F = json.load(open(src, encoding="utf-8"))["families"]
    rows, bad = [], 0
    for fam in F:
        cells = []
        for ex in fam["examples"]:
            problems, form, curves, cen = check(fam["nodes"], ex["links"])
            bad += bool(problems)
            print("%-10s %-18s %-10s %s" % (fam["name"], ex["style"], form, "ok" if not problems else "; ".join(problems)))
            cells.append(svg_cell(fam, ex, curves, cen, problems, form))
        k = collections.Counter(kd for _, _, kd in fam["nodes"])
        rows.append('<div class="row"><div class="fam"><b>%s</b><br>%d nodes<br>%d small, %d notable</div>%s</div>' % (
            html.escape(fam["name"]), len(fam["nodes"]), k["s"], k["N"], "".join(cells)))
    page = """<!doctype html><html><head><meta charset="utf-8"><title>Đạo Đồ small families</title><style>
body{background:#0b0d10;color:#d8d2c4;font:13px system-ui,sans-serif;margin:16px}
h1{font-size:18px;margin:0 0 4px} p{margin:0 0 12px;color:#9a9486;max-width:900px}
.row{display:flex;align-items:center;border-top:1px solid #222;padding:6px 0}
.fam{width:110px;color:#cfc6b0}.cell{width:180px;text-align:center}
.cap{color:#b8b0a0}.chk{font-size:11px}.good{color:#6f9f6f}.bad{color:#d06060}
.link{stroke:#b49a6a;stroke-width:2;fill:none}.road{stroke:#5d5a52;stroke-width:2;stroke-dasharray:4 3}
.roadnode{fill:#0b0d10;stroke:#8a8576;stroke-width:2}.small{fill:#0b0d10;stroke:#c8b88a;stroke-width:2}
.notable{fill:#c98a3a;stroke:#f0c070;stroke-width:2}
</style></head><body><h1>Đạo Đồ: small-cluster families (draft for approval, 2026-11-18)</h1>
<p>Each row is one family: its node positions and kinds (ring = small Dao mark, orange = notable). The cells are example
link styles from the same positions; every copy also picks its hand, turn, entry turn and road-link length (rules 3.4).
The dashed stub is the road link into the entry node. Green = passes the hard rules of 3.2.</p>%s</body></html>""" % "".join(rows)
    open(out_html, "w", encoding="utf-8").write(page)
    print("styles with problems: %d" % bad)
    if out_png:
        cands = [r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                 r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"]
        browser = next(p for p in cands if os.path.exists(p))
        h = 140 + 220 * len(F)
        subprocess.run([browser, "--headless=new", "--disable-gpu", "--hide-scrollbars", "--force-device-scale-factor=1",
                        "--user-data-dir=" + tempfile.mkdtemp(prefix="famsheet-"), "--window-size=880,%d" % h,
                        "--screenshot=" + os.path.abspath(out_png), pathlib.Path(out_html).resolve().as_uri()],
                       capture_output=True, timeout=120)
        print("wrote", out_png)


if __name__ == "__main__":
    main()
