"""Find the empty spaces in a built land and draw them (a drawing aid; it places nothing).

Usage: python -I tools/design/meridian_rework/holes.py <out_dir>/<region>.json <out.html> [clearance]
Every point of the land farther than `clearance` units (default 2.2) from any node or link is open space; touching
open points are grouped into holes. Prints each hole's centre, size, widest clearance and the nearest road node, and
writes an SVG page of the land with the holes shaded and numbered.
"""
import collections
import json
import math
import sys

D = json.load(open(sys.argv[1], encoding="utf-8"))
OUT = sys.argv[2]
CLR = float(sys.argv[3]) if len(sys.argv) > 3 else 2.2
N = {n["id"]: n for n in D["nodes"] if n["kind"] != "exit"}
H, RIM = D["half_angle"], D["rim"]
pts = {i: (n["u"], n["v"]) for i, n in N.items()}


def seg_pts(e):
    a, b = pts[e["a"]], pts[e["b"]]
    n = max(2, int(math.dist(a, b) / 0.3))
    return [(a[0] + (b[0] - a[0]) * k / n, a[1] + (b[1] - a[1]) * k / n) for k in range(n + 1)]


ink = list(pts.values())
for e in D["edges"]:
    if e["a"] in pts and e["b"] in pts:
        ink += seg_pts(e)
grid = collections.defaultdict(list)
for p in ink:
    grid[(int(p[0] // 2), int(p[1] // 2))].append(p)


def clearance(p):
    best = 9.0
    cx, cy = int(p[0] // 2), int(p[1] // 2)
    for gx in range(cx - 3, cx + 4):
        for gy in range(cy - 3, cy + 4):
            for q in grid.get((gx, gy), ()):
                best = min(best, math.dist(p, q))
    # the land's own edges count as walls
    r = math.hypot(*p)
    th = math.radians(H) - abs(math.atan2(p[0], p[1]))
    return min(best, r * math.sin(max(th, 0)) + 0.3, RIM - r + 0.3)


STEP = 0.5
open_ = {}
v = 12.0
while v < RIM:
    u = -RIM
    while u < RIM:
        r = math.hypot(u, v)
        if 13 < r < RIM - 0.5 and abs(math.degrees(math.atan2(u, v))) < H:
            c = clearance((u, v))
            if c > CLR:
                open_[(round(u / STEP), round(v / STEP))] = c
        u += STEP
    v += STEP
seen, holes = set(), []
for k in open_:
    if k in seen:
        continue
    comp, st = [], [k]
    while st:
        x = st.pop()
        if x in seen or x not in open_:
            continue
        seen.add(x); comp.append(x)
        st += [(x[0] + 1, x[1]), (x[0] - 1, x[1]), (x[0], x[1] + 1), (x[0], x[1] - 1)]
    if len(comp) >= 3:
        cu = sum(c[0] for c in comp) / len(comp) * STEP; cv = sum(c[1] for c in comp) / len(comp) * STEP
        peak = max(comp, key=lambda c: open_[c])
        holes.append({"centre": (round(cu, 1), round(cv, 1)), "area": round(len(comp) * STEP * STEP, 1), "widest": round(open_[peak], 1),
                      "peak": (round(peak[0] * STEP, 1), round(peak[1] * STEP, 1)), "cells": comp})
holes.sort(key=lambda h: -h["area"])
travel = [i for i, n in N.items() if n["kind"] in ("travel", "start")]
for j, h in enumerate(holes):
    pk = h["peak"]
    near = sorted(travel, key=lambda i: math.dist(pts[i], pk))[:2]
    nc = sorted((i for i, n in N.items() if n["kind"] in ("small", "notable")), key=lambda i: math.dist(pts[i], pk))[:1]
    h["near_road"] = [(i, round(math.dist(pts[i], pk), 1)) for i in near]
    h["near_node"] = [(i, round(math.dist(pts[i], pk), 1)) for i in nc]
    print(f"hole {j:2d}: peak {pk} area {h['area']:5.1f} widest {h['widest']} r {math.hypot(*pk):.1f} "
          f"theta {math.degrees(math.atan2(*pk)):5.1f}  road {h['near_road']}  node {h['near_node']}")
total = sum(h["area"] for h in holes)
print(f"{len(holes)} holes, {total:.0f} square units open (clearance > {CLR})")
# picture: land in (u, -v), holes shaded
s = 13.0
X = lambda u: (u + 32) * s
Y = lambda v: (78 - v) * s
svg = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{64 * s:.0f}" height="{70 * s:.0f}" style="background:#f7f6f2">']
for h in holes:
    for c in h["cells"]:
        svg.append(f'<rect x="{X(c[0] * STEP - STEP / 2):.1f}" y="{Y(c[1] * STEP + STEP / 2):.1f}" width="{STEP * s:.1f}" height="{STEP * s:.1f}" fill="#f4a3a3" opacity=".55"/>')
for e in D["edges"]:
    if e["a"] in pts and e["b"] in pts:
        a, b = pts[e["a"]], pts[e["b"]]
        svg.append(f'<line x1="{X(a[0]):.1f}" y1="{Y(a[1]):.1f}" x2="{X(b[0]):.1f}" y2="{Y(b[1]):.1f}" stroke="#999" stroke-width="1.5"/>')
for i, n in N.items():
    col = {"travel": "#5b8bd6", "notable": "#d9a520", "keystone": "#e04e6a", "start": "#222"}.get(n["kind"], "#9aa3ab")
    svg.append(f'<circle cx="{X(n["u"]):.1f}" cy="{Y(n["v"]):.1f}" r="{5 if n["kind"] in ("notable", "travel") else 3.5}" fill="{col}"/>')
    if n["kind"] == "travel":
        svg.append(f'<text x="{X(n["u"]) + 5:.1f}" y="{Y(n["v"]) - 4:.1f}" font-size="10" fill="#2b4f8a">{i}</text>')
for j, h in enumerate(holes):
    svg.append(f'<text x="{X(h["peak"][0]):.1f}" y="{Y(h["peak"][1]):.1f}" font-size="18" font-weight="bold" fill="#b00020" text-anchor="middle">{j}</text>')
svg.append("</svg>")
open(OUT, "w", encoding="utf-8").write("<html><body style='margin:0'>" + "".join(svg) + "</body></html>")
