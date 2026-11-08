"""Close-up crops of PoE 1 or PoE 2 around named nodes or class starts (study only).

Usage: python -I crop2.py <game 1|2> <tree json> <out.html> <radius> <target> [<target> ...]
A target is a node name, or start:<Class> for a class start. Nodes are coloured by their group so
clusters read as units; links between different groups are drawn darker.
"""
import html
import json
import math
import sys

src = open(__file__.replace("crop2.py", "analyse.py"), encoding="utf-8").read().split("\nout = {}\n")[0]
GAME, PATH, OUTP, RADIUS, TARGETS = int(sys.argv[1]), sys.argv[2], sys.argv[3], float(sys.argv[4]), sys.argv[5:]
sys.argv = ["x", PATH, PATH, "."]
ns = {}
exec(compile(src, "analyse.py", "exec"), ns)
d, nodes, edges = ns["load"](PATH, GAME)
groups = d["groups"]
gget = (lambda g: groups.get(str(g))) if isinstance(groups, dict) else (lambda g: groups[int(g) - 1])
COL = {"small": "#9aa3ab", "attribute": "#5b8bd6", "notable": "#d9a520", "keystone": "#e04e6a", "jewel": "#2fa38f",
       "start": "#222", "mastery": "#ddd"}
PAL = ["#e6194b", "#3cb44b", "#4363d8", "#f58231", "#911eb4", "#46f0f0", "#f032e6", "#bcf60c", "#008080",
       "#9a6324", "#800000", "#808000", "#000075", "#aa6e28", "#fabebe", "#e6beff"]
panels = []
for tg in TARGETS:
    if tg.startswith("start:"):
        cls = tg[6:]
        cid = next(k for k, v in nodes.items() if v["t"] == "start" and cls in v["name"])
    else:
        cid = next(k for k, v in nodes.items() if v.get("name") == tg)
    cx, cy = nodes[cid]["x"], nodes[cid]["y"]
    near = {k for k, v in nodes.items() if math.hypot(v["x"] - cx, v["y"] - cy) < RADIUS}
    s = 380 / RADIUS
    tx = lambda x: (x - cx) * s + 400
    ty = lambda y: (y - cy) * s + 400
    gcol = {}
    for k in sorted(near):
        g = nodes[k]["g"]
        if g not in gcol:
            gcol[g] = PAL[len(gcol) % len(PAL)]
    out = [f'<svg viewBox="0 0 800 800" width="800" height="800" style="background:#f7f6f2;border:1px solid #ccc">']
    for a, b in edges:
        if a in near or b in near:
            na, nb = nodes[a], nodes[b]
            same = na["g"] == nb["g"]
            col, w = ("#999", 2) if same else ("#333", 2.6)
            if same and na["o"] == nb["o"] and na["o"] > 0:
                g = gget(na["g"])
                r = math.hypot(na["x"] - g["x"], na["y"] - g["y"]) * s
                t1 = math.atan2(na["y"] - g["y"], na["x"] - g["x"]); t2 = math.atan2(nb["y"] - g["y"], nb["x"] - g["x"])
                dd = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
                out.append(f'<path d="M{tx(na["x"]):.1f},{ty(na["y"]):.1f} A{r:.1f},{r:.1f} 0 0 {1 if dd > 0 else 0} {tx(nb["x"]):.1f},{ty(nb["y"]):.1f}" fill="none" stroke="{col}" stroke-width="{w}"/>')
            else:
                out.append(f'<line x1="{tx(na["x"]):.1f}" y1="{ty(na["y"]):.1f}" x2="{tx(nb["x"]):.1f}" y2="{ty(nb["y"]):.1f}" stroke="{col}" stroke-width="{w}"/>')
    for k in near:
        n = nodes[k]
        r = {"notable": 9, "keystone": 12, "jewel": 8, "attribute": 6, "start": 14, "mastery": 6}.get(n["t"], 4.5)
        if n["t"] == "attribute":
            shape = f'<rect x="{tx(n["x"]) - r:.1f}" y="{ty(n["y"]) - r:.1f}" width="{2 * r}" height="{2 * r}"'
        else:
            shape = f'<circle cx="{tx(n["x"]):.1f}" cy="{ty(n["y"]):.1f}" r="{r}"'
        out.append(shape + f' fill="{COL[n["t"]]}" stroke="{gcol[n["g"]]}" stroke-width="2.5"/>')
        if n["t"] in ("notable", "keystone", "start"):
            out.append(f'<text x="{tx(n["x"]) + 11:.1f}" y="{ty(n["y"]) + 4:.1f}" font-size="11" font-family="sans-serif">{html.escape(n["name"][:28])}</text>')
    out.append("</svg>")
    panels.append(f"<div><h3 style='font-family:sans-serif;margin:4px'>{html.escape(tg)} (r {RADIUS:.0f})</h3>{''.join(out)}</div>")
open(OUTP, "w", encoding="utf-8").write("<html><body style='margin:0;display:flex;flex-wrap:wrap;gap:6px'>" + "".join(panels) + "</body></html>")
print("ok", len(panels))
