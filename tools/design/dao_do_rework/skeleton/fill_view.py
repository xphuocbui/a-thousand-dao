"""Before/after page for a filled test land: python -I fill_view.py <region json from build_region.py> <out.html> [half-angle]
Three panels on one zoom: the roads alone, the land filled with its roads drawn bold, and the land filled as a player
would see it (roads and clusters alike)."""
import json
import math
import sys

THEME_COL = {"fire": "#e7653f", "phoenix": "#f0a040", "blaze": "#d9483b", "alchemy": "#c9a227"}


def arc(p, q, c):
    if not c:
        return f"M{p[0]:.2f},{-p[1]:.2f} L{q[0]:.2f},{-q[1]:.2f}"
    r = math.dist(p, c)
    t1 = math.atan2(p[1] - c[1], p[0] - c[0]); t2 = math.atan2(q[1] - c[1], q[0] - c[0])
    d = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    return f"M{p[0]:.2f},{-p[1]:.2f} A{r:.2f},{r:.2f} 0 0 {0 if d > 0 else 1} {q[0]:.2f},{-q[1]:.2f}"


def panel(d, box, mode):
    x0, y0, x1, y1 = box
    N = {n["id"]: n for n in d["nodes"]}
    P = lambda n: (n["u"], n["v"])
    road = lambda n: n["kind"] in ("travel", "start")
    out = [f'<svg viewBox="{x0} {-y1} {x1 - x0} {y1 - y0}">']
    for e in d["edges"]:
        a, b = N[e["a"]], N[e["b"]]
        rr = road(a) and road(b)
        if mode == "roads" and not rr:
            continue
        col, w, op = ("#c9b07a", 0.42, 1) if rr else ("#7d8792", 0.14, 0.55 if mode == "bold" else 0.85)
        if mode == "plain":
            col, w, op = ("#8a9098", 0.18, 0.9)
        out.append(f'<path d="{arc(P(a), P(b), e.get("arc"))}" stroke="{col}" stroke-width="{w}" stroke-opacity="{op}" fill="none"/>')
    for n in d["nodes"]:
        if mode == "roads" and not road(n):
            continue
        k = n["kind"]
        r = {"small": 0.28, "travel": 0.32, "notable": 0.5, "keystone": 0.7, "start": 0.9}.get(k, 0.3)
        if k == "start":
            fill = stroke = "#7aa7ec"
        elif k == "travel":
            fill = stroke = "#c9b07a" if mode != "plain" else "#9aa3ad"
        elif k == "notable":
            fill, stroke = "#0e1319", THEME_COL.get(n.get("theme"), "#d8b25a")
        else:
            fill, stroke = "#0e1319", "#7d8792"
        op = 0.6 if (mode == "bold" and k in ("small", "notable")) else 1
        out.append(f'<circle cx="{n["u"]:.2f}" cy="{-n["v"]:.2f}" r="{r}" fill="{fill}" stroke="{stroke}" stroke-width="0.12" opacity="{op}"/>')
    out.append("</svg>")
    return "".join(out)


def main():
    d = json.load(open(sys.argv[1], encoding="utf-8"))
    half = float(sys.argv[3]) if len(sys.argv) > 3 else 18.0
    box = (-32, 16, 32, 88)
    figs = "".join(f"<figure>{panel(d, box, m)}<figcaption>{t}</figcaption></figure>" for m, t in (
        ("roads", "The roads alone"), ("bold", "Filled, roads drawn bold"), ("plain", "Filled, as a player sees it")))
    n_in = sum(1 for n in d["nodes"] if abs(math.degrees(math.atan2(n["u"], n["v"]))) <= half + 0.5 and math.hypot(n["u"], n["v"]) > 18.5)
    html = open(sys.argv[2].replace(".html", "_tpl.html") if False else __file__.replace("fill_view.py", "fill_view_tpl.html"), encoding="utf-8").read()
    open(sys.argv[2], "w", encoding="utf-8").write(html.replace("%FIGS%", figs).replace("%N%", f"{n_in:,}"))


if __name__ == "__main__":
    main()
