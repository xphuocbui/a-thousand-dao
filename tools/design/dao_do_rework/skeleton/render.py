"""A comparison page for the road-only sketches: python -I render.py <dir with sketch-*.json> <out.html>
Each variant is drawn whole and with one land zoomed in; starts blue, roads gold, the islands as they were."""
import json
import math
import os
import sys

REG_COL = {"fire": "#e7653f", "earth": "#d1a64c", "metal": "#b9c6d3", "water": "#4f95e0", "wood": "#5bbd78", "hub": "#b78be0",
           "light": "#f3dc7c", "darkness": "#a68ae0", "thunder": "#ecc93c"}
NOTES = {
    "A2": ("Mandala chain, refined", "Variant A with your notes. Fire keeps its stars. Earth is a fortress (an octagon round a diamond core), "
           "Metal a four-pointed blade star, Water a scalloped lotus, Wood a leaf with a midrib and veins. Ice has its own snowflake on "
           "Water's centre line, between the Water start and Water's middle figure. Light is a sun: a road disc with rays that will be "
           "clusters (faint). Darkness is a crescent moon with its horns away from the tree; the Shadow Shrine is kept and 1.35 times bigger. "
           "Every figure mirrors about its land's axis, and roads join on the axis or at mirrored pairs (symmetry 1.0 in every land). The "
           "islands are drawn about 19 units in radius, room for about 530-610 nodes each at the Chaos centre's density."),
    "A": ("Mandala chain", "Each land is three closed figures on its axis: an emblem round the start, a middle figure and an outer one. "
          "The blend zones hold smaller figures. Side roads chain the figures into three circuits round the map, and a rim circle "
          "joins the outer figures and the islands."),
    "B": ("Petals", "Each land is one big closed petal from the centre to the rim, with an emblem round its start and two cross ribs. "
          "The blend zones are narrower petals, joined to their neighbours at the ribs."),
    "C": ("Rings and emblems", "Clean closed rings and straight spokes, with a distinct emblem round every start. Shown as a contrast: "
          "it is close to the dartboard rejected before."),
}


def arc(p, q, c):
    if not c:
        return f"M{p[0]:.2f},{-p[1]:.2f} L{q[0]:.2f},{-q[1]:.2f}"
    r = math.dist(p, c)
    t1 = math.atan2(p[1] - c[1], p[0] - c[0]); t2 = math.atan2(q[1] - c[1], q[0] - c[0])
    d = (t2 - t1 + math.pi) % (2 * math.pi) - math.pi
    return f"M{p[0]:.2f},{-p[1]:.2f} A{r:.2f},{r:.2f} 0 0 {0 if d > 0 else 1} {q[0]:.2f},{-q[1]:.2f}"


def svg(d, box, sw=0.35, nr=0.45):
    x0, y0, x1, y1 = box
    N = d["nodes"]
    inb = lambda n: x0 - 3 <= n["x"] <= x1 + 3 and y0 - 3 <= n["y"] <= y1 + 3
    out = [f'<svg viewBox="{x0} {-y1} {x1 - x0} {y1 - y0}" role="img">']
    for e in d["edges"]:
        a, b = N[e["a"]], N[e["b"]]
        if not (inb(a) or inb(b)):
            continue
        ray = a["kind"] == "ray" or b["kind"] == "ray"
        out.append(f'<path d="{arc((a["x"], a["y"]), (b["x"], b["y"]), e.get("arc"))}" stroke="{"#6b7480" if ray else REG_COL.get(a["region"], "#c9b07a")}" '
                   f'stroke-opacity="{".6" if ray else ".85"}" stroke-width="{sw * (0.6 if ray else 1)}" {"stroke-dasharray=\".5 .4\"" if ray else ""} fill="none"/>')
    for n in N:
        if not inb(n):
            continue
        st = n["kind"] == "start"
        if n["kind"] == "ray":
            out.append(f'<circle cx="{n["x"]:.2f}" cy="{-n["y"]:.2f}" r="{nr * 0.9}" fill="none" stroke="#6b7480" stroke-width="{nr * 0.35}"/>')
            continue
        out.append(f'<circle cx="{n["x"]:.2f}" cy="{-n["y"]:.2f}" r="{nr * (2.6 if st else 1)}" fill="{"#7aa7ec" if st else REG_COL.get(n["region"], "#c9b07a")}"><title>{n.get("name") or ""}</title></circle>')
    out.append("</svg>")
    return "".join(out)


def main():
    src, out = sys.argv[1], sys.argv[2]
    secs = []
    for key in ("A2", "A", "B", "C"):
        p = os.path.join(src, f"sketch-{key}.json")
        if not os.path.exists(p):
            continue
        d = json.load(open(p, encoding="utf-8"))
        title, note = NOTES[key]
        fire = next(n for n in d["nodes"] if n["kind"] == "start" and n["region"] == "fire")
        whole = svg(d, (-136, -136, 136, 136), sw=0.6, nr=0.62)
        zoom = svg(d, (-30, 14, 30, 90), sw=0.3, nr=0.42)
        secs.append(f'<section><h2>{key} · {title}</h2><p>{note}</p><div class="pair"><figure>{whole}<figcaption>The whole map</figcaption></figure>'
                    f'<figure>{zoom}<figcaption>Fire, from the centre to the rim</figcaption></figure></div></section>')
    tpl = open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "render_tpl.html"), encoding="utf-8").read()
    open(out, "w", encoding="utf-8").write(tpl.replace("%SECTIONS%", "".join(secs)))


if __name__ == "__main__":
    main()
