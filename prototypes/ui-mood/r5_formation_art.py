# PROTOTYPE - NOT FOR PRODUCTION
"""UI mood round 5 (2026-11-24): renders two approved combat formations (catalogue in assets/data/crafting_diagrams.json)
large, with real art icons in their nodes, as the formation look for the image model (the user called the round-4
fight and Combat-tab mock-ups and the current fight screen "really bad"). Draws the same grammar as
tools/design/render_diagram_draft_v2.py: a glowing gold figure, curved links, feeds as light-blue arrows.
usage: python -I r5_formation_art.py <repo root>  -> in-r5-formation-a.png (Five Phases), in-r5-formation-b.png (Twin Dragons)"""
import json, math, os, sys
from PIL import Image, ImageDraw, ImageFilter

ROOT = os.path.abspath(sys.argv[1])
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(ROOT, "tools", "design"))
cat = {d["id"]: d for d in json.load(open(os.path.join(ROOT, "assets/data/crafting_diagrams.json"), encoding="utf-8"))["diagrams"]}
ICONS = sorted(f for f in os.listdir(os.path.join(ROOT, "assets/icons/arts")) if f.endswith(".png"))


def render(did, out, icons, size=900):
    import importlib.util
    spec = importlib.util.spec_from_file_location("rd", os.path.join(ROOT, "tools/design/render_diagram_draft_v2.py"))
    src = open(spec.origin, encoding="utf-8").read()
    fs_src = src[src.index("def bez("):src.index("sheet = Image.new")]
    ns = {"math": math, "random": __import__("random")}
    exec(fs_src, ns)
    g = cat[did]
    im = Image.new("RGBA", (size, size), (10, 12, 22, 255))
    allp = [n["pos"] for n in g["nodes"]]
    xs, ys = [p[0] for p in allp], [p[1] for p in allp]
    sc = (size * 0.55) / max(max(xs) - min(xs), max(ys) - min(ys), 1.0)
    cx, cy = size / 2 - (min(xs) + max(xs)) / 2 * sc, size / 2 - (min(ys) + max(ys)) / 2 * sc
    T = lambda p: (cx + p[0] * sc, cy + p[1] * sc)
    glow = Image.new("RGBA", im.size, (0, 0, 0, 0)); gd = ImageDraw.Draw(glow)
    crisp = Image.new("RGBA", im.size, (0, 0, 0, 0)); cd = ImageDraw.Draw(crisp)
    for f in g.get("figure", []):
        lines, dots = ns["figure_strokes"](f, T)
        for ln in lines:
            gd.line(ln, fill=(232, 180, 80, 160), width=12); cd.line(ln, fill=(220, 178, 100, 230), width=3)
        for p in dots:
            cd.ellipse([p[0] - 2.5, p[1] - 2.5, p[0] + 2.5, p[1] + 2.5], fill=(240, 225, 180, 230))
    P = [T(n["pos"]) for n in g["nodes"]]
    R = 52
    for l in g["links"]:
        a, b = (l["a"], l["b"]) if l["kind"] == "adj" else (l["from"], l["to"])
        pts = [p for p in ns["bez"](P[a - 1], P[b - 1], l.get("bend", 0.0)) if math.dist(p, P[a - 1]) > R + 4 and math.dist(p, P[b - 1]) > R + 10]
        if len(pts) < 2:
            continue
        col = (120, 205, 255, 255) if l["kind"] == "feed" else (170, 150, 120, 255)
        if l["kind"] == "feed":
            gd.line(pts, fill=(120, 205, 255, 150), width=12)
        cd.line(pts, fill=col, width=5)
        if l["kind"] == "feed":
            e, q = pts[-1], pts[-2]; ang = math.atan2(e[1] - q[1], e[0] - q[0])
            for da in (2.6, -2.6):
                cd.line([e, (e[0] + math.cos(ang + da) * 22, e[1] + math.sin(ang + da) * 22)], fill=col, width=5)
    im.alpha_composite(glow.filter(ImageFilter.GaussianBlur(8))); im.alpha_composite(crisp)
    d = ImageDraw.Draw(im)
    POL = {"+": (110, 190, 105), "-": (220, 95, 85), "?": (115, 170, 235)}
    for k, (n, p) in enumerate(zip(g["nodes"], P)):
        d.ellipse([p[0] - R - 8, p[1] - R - 8, p[0] + R + 8, p[1] + R + 8], fill=(110, 82, 40, 255))
        d.ellipse([p[0] - R, p[1] - R, p[0] + R, p[1] + R], fill=(14, 12, 18, 255), outline=POL[n["polarity"]], width=6)
        if k < len(icons):
            ic = Image.open(os.path.join(ROOT, "assets/icons/arts", icons[k])).convert("RGBA").resize((int(R * 1.6), int(R * 1.6)), Image.LANCZOS)
            mask = Image.new("L", ic.size, 0); ImageDraw.Draw(mask).ellipse([0, 0, ic.size[0], ic.size[1]], fill=255)
            im.paste(ic, (int(p[0] - R * 0.8), int(p[1] - R * 0.8)), mask)
        bx, by = p[0] + R * 0.62, p[1] - R * 0.95
        d.ellipse([bx - 15, by - 15, bx + 15, by + 15], fill=POL[n["polarity"]])
    im.convert("RGB").save(out)


render("ngu_hanh", os.path.join(HERE, "in-r5-formation-a.png"), ICONS[3:8])
render("song_long", os.path.join(HERE, "in-r5-formation-b.png"), ICONS[10:15])
print("ok")
