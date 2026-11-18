"""Render close-up crops of the PoE 2 tree around named nodes (study only), as one HTML sheet of SVGs.

Usage: python -I crop.py <poe2 tree.json> <out.html> <radius> <name> [<name> ...]
"""
import html
import json
import math
import sys

src = open(__file__.replace("crop.py", "analyse.py"), encoding="utf-8").read().split("\nout = {}\n")[0]
P2, OUTP, RADIUS, NAMES = sys.argv[1], sys.argv[2], float(sys.argv[3]), sys.argv[4:]
sys.argv = ["x", P2, P2, "."]
ns = {}
exec(compile(src, "analyse.py", "exec"), ns)
d, nodes, edges = ns["load"](P2, 2)
raw = {int(k): v for k, v in d["nodes"].items() if isinstance(v, dict) and str(k).isdigit()}
groups = d["groups"]
COL = {"small": "#9aa3ab", "attribute": "#5b8bd6", "notable": "#d9a520", "keystone": "#e04e6a", "jewel": "#2fa38f", "start": "#222", "mastery": "#ccc"}
panels = []
for name in NAMES:
    cid = next(k for k, v in raw.items() if v.get("name") == name and k in nodes)
    cx, cy = nodes[cid]["x"], nodes[cid]["y"]
    near = {k for k, v in nodes.items() if math.hypot(v["x"] - cx, v["y"] - cy) < RADIUS}
    s = 360 / RADIUS
    tx = lambda x: (x - cx) * s + 380
    ty = lambda y: (y - cy) * s + 380
    out = [f'<svg viewBox="0 0 760 760" width="760" height="760" style="background:#f7f6f2;border:1px solid #ccc">']
    for a, b in edges:
        if a in near or b in near:
            na, nb = nodes[a], nodes[b]
            arc = ""
            if na["g"] == nb["g"] and na["o"] == nb["o"] and na["o"] > 0:
                g = groups[na["g"] - 1]
                r = math.hypot(na["x"] - g["x"], na["y"] - g["y"]) * s
                t1 = math.atan2(na["y"] - g["y"], na["x"] - g["x"]); t2 = math.atan2(nb["y"] - g["y"], nb["x"] - g["x"])
                dd = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
                sweep = 1 if dd > 0 else 0
                out.append(f'<path d="M{tx(na["x"]):.1f},{ty(na["y"]):.1f} A{r:.1f},{r:.1f} 0 0 {sweep} {tx(nb["x"]):.1f},{ty(nb["y"]):.1f}" fill="none" stroke="#888" stroke-width="2"/>')
            else:
                out.append(f'<line x1="{tx(na["x"]):.1f}" y1="{ty(na["y"]):.1f}" x2="{tx(nb["x"]):.1f}" y2="{ty(nb["y"]):.1f}" stroke="#888" stroke-width="2"/>')
    for k in near:
        n = nodes[k]
        r = {"notable": 9, "keystone": 12, "jewel": 8, "attribute": 6, "start": 12}.get(n["t"], 4.5)
        shape = f'<rect x="{tx(n["x"]) - r:.1f}" y="{ty(n["y"]) - r:.1f}" width="{2 * r}" height="{2 * r}"' if n["t"] == "attribute" else f'<circle cx="{tx(n["x"]):.1f}" cy="{ty(n["y"]):.1f}" r="{r}"'
        out.append(shape + f' fill="{COL[n["t"]]}" stroke="#333" stroke-width="0.8"/>')
        if n["t"] in ("notable", "keystone"):
            out.append(f'<text x="{tx(n["x"]) + 11:.1f}" y="{ty(n["y"]) + 4:.1f}" font-size="11" font-family="sans-serif">{html.escape(n["name"])}</text>')
    out.append("</svg>")
    panels.append(f"<div><h3 style='font-family:sans-serif'>{html.escape(name)}</h3>{''.join(out)}</div>")
open(OUTP, "w", encoding="utf-8").write("<html><body style='display:flex;flex-wrap:wrap;gap:12px'>" + "".join(panels) + "</body></html>")
print("ok")
