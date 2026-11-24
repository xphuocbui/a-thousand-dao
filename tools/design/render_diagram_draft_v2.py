"""Draws the combat-formation catalogue draft v2 as a sheet of cards for the user's review
(production/plans/combat-formations.md): each diagram's figure glowing gold on a dark board, curved links (feeds as
arrows with their seconds, adjacency as plain strokes), nodes as bronze rings with a +/-/? badge and their rule, and
what opens at a later level drawn dashed with its level ("L3"). Review only; the game draws its own.
Usage: python -I tools/design/render_diagram_draft_v2.py <draft.json> <out.png>"""
import json, math, sys, random
from PIL import Image, ImageDraw, ImageFont, ImageFilter

src, out = sys.argv[1], sys.argv[2]
doc = json.load(open(src, encoding="utf-8"))
CW, CH, COLS = 600, 560, 5
diags = doc["diagrams"]
rows = math.ceil(len(diags) / COLS)


def font(px, bold=False):
    for f in (["C:/Windows/Fonts/segoeuib.ttf"] if bold else []) + ["C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf"]:
        try:
            return ImageFont.truetype(f, px)
        except OSError:
            pass
    return ImageFont.load_default()


FT, F14, F13, F12 = font(19, True), font(14), font(13), font(12)
GOLD, GOLD_DIM, BONE = (232, 190, 105), (150, 118, 62), (236, 222, 190)
POL = {"+": (110, 190, 105), "-": (220, 95, 85), "?": (115, 170, 235)}
KEY = {"damage_pct": "damage", "art_speed_pct": "speed", "art_cost_pct": "cost"}


def rule_text(r):
    if r["type"] == "mod":
        sc = (" (" + ", ".join(r["scope"]) + ")") if r.get("scope") else ""
        return "%+g%% %s%s" % (r["value"], KEY[r["key"]], sc)
    if r["type"] == "adj_mod":
        return "%+g%% %s beside %s" % (r["value"], KEY[r["key"]], r["tag"])
    c = r["cond"]
    read = {"own.hp_share": "health", "time": "time"}.get(c["read"], c["read"])
    v = ("%d%%" % round(c["value"] * 100)) if "share" in c["read"] else ("%gs" % c["value"])
    return "held until %s %s %s" % (read, c["op"], v)


def bez(a, b, bend, n=24):
    mx, my = (a[0] + b[0]) / 2, (a[1] + b[1]) / 2
    dx, dy = b[0] - a[0], b[1] - a[1]
    cx, cy = mx - dy * bend * 0.5, my + dx * bend * 0.5
    return [((1 - t) ** 2 * a[0] + 2 * (1 - t) * t * cx + t * t * b[0], (1 - t) ** 2 * a[1] + 2 * (1 - t) * t * cy + t * t * b[1]) for t in [i / n for i in range(n + 1)]]


def dashed(d, pts, fill, width, on=7, off=6):
    acc, draw = 0.0, True
    for p, q in zip(pts, pts[1:]):
        seg = math.dist(p, q)
        if draw:
            d.line([p, q], fill=fill, width=width)
        acc += seg
        if acc > (on if draw else off):
            acc, draw = 0.0, not draw


def figure_strokes(fig, T):
    """Returns polylines (lists of points) and dots for one figure entry, in card pixels via T."""
    lines, dots = [], []
    s = fig["shape"]
    if s in ("circle", "arc"):
        c, r = fig["c"], fig["r"]
        a0, a1 = (0, 360) if s == "circle" else (fig["a0"], fig["a1"])
        lines.append([T([c[0] + r * math.cos(math.radians(a)), c[1] + r * math.sin(math.radians(a))]) for a in range(int(a0), int(a1) + 1, 3)])
    elif s == "poly":
        pts = [T(p) for p in fig["points"]]
        lines.append(pts + ([pts[0]] if fig.get("closed") else []))
    elif s == "wave":
        a, b = fig["from"], fig["to"]
        L = math.dist(a, b)
        ux, uy = (b[0] - a[0]) / L, (b[1] - a[1]) / L
        lines.append([T([a[0] + ux * L * t - uy * fig["amp"] * math.sin(t * fig["waves"] * 2 * math.pi), a[1] + uy * L * t + ux * fig["amp"] * math.sin(t * fig["waves"] * 2 * math.pi)]) for t in [i / 80 for i in range(81)]])
    elif s == "spiral":
        c = fig["c"]
        lines.append([T([c[0] + (fig["r0"] + (fig["r1"] - fig["r0"]) * t) * math.cos(t * fig["turns"] * 2 * math.pi), c[1] + (fig["r0"] + (fig["r1"] - fig["r0"]) * t) * math.sin(t * fig["turns"] * 2 * math.pi)]) for t in [i / 160 for i in range(161)]])
    elif s == "taiji":
        c, r = fig["c"], fig["r"]
        lines.append([T([c[0] + r * math.cos(math.radians(a)), c[1] + r * math.sin(math.radians(a))]) for a in range(0, 361, 3)])
        top = [T([c[0] + r / 2 * math.cos(math.radians(a)), c[1] - r / 2 + r / 2 * math.sin(math.radians(a))]) for a in range(90, -91, -4)]
        bot = [T([c[0] + r / 2 * math.cos(math.radians(a)), c[1] + r / 2 + r / 2 * math.sin(math.radians(a))]) for a in range(270, 89, -4)]
        lines.append(top + bot)
    elif s == "star":
        c, r, n, k = fig["c"], fig["r"], fig["n"], fig["step"]
        pts = [T([c[0] + r * math.cos(math.radians(-90 + 360 * (i * k % n) / n)), c[1] + r * math.sin(math.radians(-90 + 360 * (i * k % n) / n))]) for i in range(n + 1)]
        lines.append(pts)
    elif s == "rays":
        c = fig["c"]
        a0, a1 = math.radians(fig.get("a0", 0)), math.radians(fig.get("a1", 360))
        for i in range(fig["n"]):
            a = a0 + (a1 - a0) * i / (fig["n"] - (1 if fig.get("a1", 360) - fig.get("a0", 0) < 360 else 0))
            lines.append([T([c[0] + fig["r0"] * math.cos(a), c[1] + fig["r0"] * math.sin(a)]), T([c[0] + fig["r1"] * math.cos(a), c[1] + fig["r1"] * math.sin(a)])])
    elif s == "stars":
        rnd = random.Random(7)
        c = fig["c"]
        for _ in range(fig["n"]):
            a, rr = rnd.uniform(0, 2 * math.pi), fig["r"] * math.sqrt(rnd.uniform(0.05, 1.0))
            dots.append(T([c[0] + rr * math.cos(a), c[1] + rr * math.sin(a)]))
    elif s == "trigrams":
        c, r = fig["c"], fig["r"]
        for i in range(8):
            a = -math.pi / 2 + 2 * math.pi * i / 8
            px, py = c[0] + r * math.cos(a), c[1] + r * math.sin(a)
            tx, ty = -math.sin(a), math.cos(a)
            for row in range(3):
                off = (row - 1) * 0.07
                bx, by = px + math.cos(a) * off, py + math.sin(a) * off
                broken = (i >> row) & 1
                if broken:
                    for sgn in (-1, 1):
                        lines.append([T([bx + tx * 0.04 * sgn, by + ty * 0.04 * sgn]), T([bx + tx * 0.14 * sgn, by + ty * 0.14 * sgn])])
                else:
                    lines.append([T([bx - tx * 0.14, by - ty * 0.14]), T([bx + tx * 0.14, by + ty * 0.14])])
    elif s == "petals":
        c, r, n, w = fig["c"], fig["r"], fig["n"], fig["w"]
        for i in range(n):
            a = -math.pi / 2 + 2 * math.pi * i / n
            pts = []
            for t in range(0, 181, 6):
                tt = math.radians(t)
                rr = r * math.sin(tt)
                side = w * math.sin(tt) * (1 - abs(math.cos(tt))) * 0.9
                pts.append([rr, side])
            for t in range(180, -1, -6):
                tt = math.radians(t)
                pts.append([r * math.sin(tt), -w * math.sin(tt) * (1 - abs(math.cos(tt))) * 0.9])
            lines.append([T([c[0] + q[0] * math.cos(a) - q[1] * math.sin(a), c[1] + q[0] * math.sin(a) + q[1] * math.cos(a)]) for q in pts])
    elif s == "wheel":
        c, r, n = fig["c"], fig["r"], fig["n"]
        lines.append([T([c[0] + r * math.cos(math.radians(a)), c[1] + r * math.sin(math.radians(a))]) for a in range(0, 361, 4)])
        lines.append([T([c[0] + r * 0.25 * math.cos(math.radians(a)), c[1] + r * 0.25 * math.sin(math.radians(a))]) for a in range(0, 361, 10)])
        for i in range(n):
            a = 2 * math.pi * i / n
            lines.append([T([c[0] + r * 0.25 * math.cos(a), c[1] + r * 0.25 * math.sin(a)]), T([c[0] + r * math.cos(a), c[1] + r * math.sin(a)])])
    elif s == "sword":
        a, b, w = fig["from"], fig["to"], fig["w"]
        L = math.dist(a, b); ux, uy = (b[0] - a[0]) / L, (b[1] - a[1]) / L; nx, ny = -uy, ux
        hilt = [a[0] + ux * L * 0.18, a[1] + uy * L * 0.18]
        lines.append([T([hilt[0] + nx * w, hilt[1] + ny * w]), T([b[0] - ux * w * 2 + nx * w * 0.6, b[1] - uy * w * 2 + ny * w * 0.6]), T(b),
                      T([b[0] - ux * w * 2 - nx * w * 0.6, b[1] - uy * w * 2 - ny * w * 0.6]), T([hilt[0] - nx * w, hilt[1] - ny * w])])
        lines.append([T([hilt[0] + nx * w * 2.6, hilt[1] + ny * w * 2.6]), T([hilt[0] - nx * w * 2.6, hilt[1] - ny * w * 2.6])])
        lines.append([T(a), T(hilt)])
        lines.append([T(b), T([b[0] - ux * L * 0.75, b[1] - uy * L * 0.75])])
    elif s == "branch":
        a, b = fig["from"], fig["to"]
        stem = [[a[0] + (b[0] - a[0]) * t + 0.15 * math.sin(t * 6), a[1] + (b[1] - a[1]) * t] for t in [i / 40 for i in range(41)]]
        lines.append([T(q) for q in stem])
        for k in range(fig["leaves"]):
            q = stem[int((k + 1) * 40 / (fig["leaves"] + 1))]
            sg = 1 if k % 2 else -1
            lines.append([T(q), T([q[0] + sg * 0.45, q[1] - 0.15]), T([q[0] + sg * 0.2, q[1] - 0.3]), T(q)])
    elif s == "zigzag":
        a, b, n, amp = fig["from"], fig["to"], fig["n"], fig["amp"]
        L = math.dist(a, b); nx, ny = -(b[1] - a[1]) / L, (b[0] - a[0]) / L
        lines.append([T([a[0] + (b[0] - a[0]) * i / n + nx * amp * (1 if i % 2 else -1) * (0 if i in (0, n) else 1), a[1] + (b[1] - a[1]) * i / n + ny * amp * (1 if i % 2 else -1) * (0 if i in (0, n) else 1)]) for i in range(n + 1)])
    elif s == "mountains":
        a, b, n, h = fig["from"], fig["to"], fig["n"], fig["h"]
        pts = []
        for i in range(n):
            x0 = a[0] + (b[0] - a[0]) * i / n; x1 = a[0] + (b[0] - a[0]) * (i + 1) / n
            pts += [[x0, a[1]], [(x0 + x1) / 2, a[1] - h * (0.8 + 0.2 * (i % 2))]]
        pts.append([b[0], b[1]])
        lines.append([T(q) for q in pts])
        lines.append([T([a[0], a[1]]), T([b[0], b[1]])])
    elif s == "gates":
        c, r = fig["c"], fig["r"]
        for k in range(4):
            a = math.pi / 2 * k
            gx, gy = c[0] + r * math.cos(a), c[1] + r * math.sin(a)
            tx, ty = -math.sin(a), math.cos(a)
            lines.append([T([gx + tx * 0.28 + math.cos(a) * 0.25, gy + ty * 0.28 + math.sin(a) * 0.25]), T([gx + tx * 0.28, gy + ty * 0.28]),
                          T([gx - tx * 0.28, gy - ty * 0.28]), T([gx - tx * 0.28 + math.cos(a) * 0.25, gy - ty * 0.28 + math.sin(a) * 0.25])])
    elif s == "strings":
        a, b, n, g = fig["from"], fig["to"], fig["n"], fig["gap"]
        for i in range(n):
            if fig.get("horizontal"):
                lines.append([T([a[0], a[1] + g * i]), T([b[0], b[1] + g * i])])
            else:
                lines.append([T([a[0] + g * i, a[1] + 0.1 * math.sin(i)]), T([b[0] + g * i, b[1]])])
    elif s == "flame":
        c, r = fig["c"], fig["r"]
        for k, sc in enumerate((1.0, 0.6)):
            lines.append([T([c[0] + r * sc * math.sin(math.radians(t)) * (0.6 + 0.4 * math.cos(math.radians(t))), c[1] - r * sc * 1.4 * (0.5 - 0.5 * math.cos(math.radians(t))) + r * sc * 0.5]) for t in range(-180, 181, 8)])
    elif s == "crystal":
        c, r = fig["c"], fig["r"]
        for i in range(6):
            a = 2 * math.pi * i / 6 - math.pi / 2
            e = [c[0] + r * math.cos(a), c[1] + r * math.sin(a)]
            lines.append([T(c), T(e)])
            for f in (0.45, 0.7):
                m = [c[0] + r * f * math.cos(a), c[1] + r * f * math.sin(a)]
                for da in (0.5, -0.5):
                    lines.append([T(m), T([m[0] + 0.25 * r * math.cos(a + da), m[1] + 0.25 * r * math.sin(a + da)])])
    elif s == "net":
        c, r = fig["c"], fig["r"]
        for k in range(1, fig["rings"] + 1):
            rr = r * k / fig["rings"]
            lines.append([T([c[0] + rr * math.cos(math.radians(a)), c[1] + rr * math.sin(math.radians(a))]) for a in range(0, 361, 5)])
        for i in range(fig["spokes"]):
            a = 2 * math.pi * i / fig["spokes"]
            lines.append([T(c), T([c[0] + r * math.cos(a), c[1] + r * math.sin(a)])])
    elif s == "cloud":
        c, r = fig["c"], fig["r"]
        for dx, dy, rr in ((-0.5, 0.1, 0.45), (0.0, -0.2, 0.55), (0.5, 0.1, 0.45)):
            lines.append([T([c[0] + dx * r + rr * r * math.cos(math.radians(a)) * (1 - a / 900), c[1] + dy * r + rr * r * math.sin(math.radians(a)) * (1 - a / 900)]) for a in range(0, 541, 10)])
    elif s == "bell":
        c, r = fig["c"], fig["r"]
        prof = [[-0.25, -1.0], [-0.35, -0.6], [-0.45, 0.2], [-0.75, 0.75], [0.75, 0.75], [0.45, 0.2], [0.35, -0.6], [0.25, -1.0], [-0.25, -1.0]]
        lines.append([T([c[0] + x * r, c[1] + y * r]) for x, y in prof])
        lines.append([T([c[0] - 0.6 * r, c[1] + 0.5 * r]), T([c[0] + 0.6 * r, c[1] + 0.5 * r])])
        lines.append([T([c[0] + 0.12 * r * math.cos(math.radians(a)), c[1] - 1.12 * r + 0.12 * r * math.sin(math.radians(a))]) for a in range(0, 361, 20)])
    elif s == "chevron":
        lines.append([T(q) for q in fig["points"]])
    elif s == "crescent":
        c, r = fig["c"], fig["r"]
        outer = [[c[0] + r * math.cos(math.radians(a)), c[1] + r * math.sin(math.radians(a))] for a in range(60, 301, 5)]
        inner = [[c[0] + 0.45 * r + r * 0.8 * math.cos(math.radians(a)), c[1] + r * 0.8 * math.sin(math.radians(a))] for a in range(285, 74, -5)]
        lines.append([T(q) for q in outer + inner + outer[:1]])
    elif s == "grid":
        c, size, n = fig["c"], fig["size"], fig["n"]
        h = size / 2
        for i in range(n + 1):
            v = -h + size * i / n
            lines.append([T([c[0] + v, c[1] - h]), T([c[0] + v, c[1] + h])])
            lines.append([T([c[0] - h, c[1] + v]), T([c[0] + h, c[1] + v])])
    elif s == "band":
        a, b, sag, w = fig["from"], fig["to"], fig["sag"], fig["w"]
        for off in (-w / 2, w / 2):
            lines.append([T([a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t + sag * 4 * t * (1 - t) + off]) for t in [i / 40 for i in range(41)]])
    elif s == "vajra":
        c, L = fig["c"], fig["len"]
        lines.append([T([c[0], c[1] - 0.15]), T([c[0], c[1] + 0.15])])
        for sg in (-1, 1):
            tip = [c[0], c[1] + sg * L / 2]
            for dx in (-0.35, 0.0, 0.35):
                lines.append([T([c[0] + dx * 0.4, c[1] + sg * 0.2]), T([c[0] + dx, c[1] + sg * L * 0.3]), T(tip)])
        lines.append([T([c[0] + 0.25 * math.cos(math.radians(a)), c[1] + 0.25 * math.sin(math.radians(a))]) for a in range(0, 361, 15)])
    elif s == "lanterns":
        a, b, n = fig["from"], fig["to"], fig["n"]
        lines.append([T([a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t + 0.25 * math.sin(t * math.pi)]) for t in [i / 30 for i in range(31)]])
        for i in range(n):
            t = (i + 0.5) / n
            x, y = a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t + 0.25 * math.sin(t * math.pi)
            lines.append([T([x, y]), T([x, y + 0.15])])
            lines.append([T([x + 0.12 * math.cos(math.radians(q)), y + 0.3 + 0.16 * math.sin(math.radians(q))]) for q in range(0, 361, 20)])
    elif s == "drill":
        a, b, w, turns = fig["from"], fig["to"], fig["w"], fig["turns"]
        lines.append([T([a[0], a[1] - w / 2]), T(b), T([a[0], a[1] + w / 2]), T([a[0], a[1] - w / 2])])
        lines.append([T([a[0] + (b[0] - a[0]) * t, a[1] + (w / 2) * (1 - t) * math.sin(t * turns * 2 * math.pi)]) for t in [i / 80 for i in range(81)]])
    elif s == "wings":
        c, r = fig["c"], fig["r"]
        for sg in (-1, 1):
            for k, f in enumerate((1.0, 0.75, 0.5)):
                lines.append([T([c[0] + sg * r * f * t, c[1] - r * 0.5 * f * math.sin(t * math.pi) + 0.1 * k]) for t in [i / 24 for i in range(25)]])
    elif s == "cauldron":
        c, r = fig["c"], fig["r"]
        lines.append([T([c[0] + r * math.cos(math.radians(a)), c[1] + r * 0.75 * math.sin(math.radians(a))]) for a in range(0, 181, 5)])
        lines.append([T([c[0] - r * 1.05, c[1]]), T([c[0] + r * 1.05, c[1]])])
        for dx in (-0.6, 0.0, 0.6):
            lines.append([T([c[0] + dx * r, c[1] + r * 0.65]), T([c[0] + dx * r * 1.15, c[1] + r * 1.15])])
        for sg in (-1, 1):
            lines.append([T([c[0] + sg * r * 0.6, c[1]]), T([c[0] + sg * r * 0.65, c[1] - 0.35 * r]), T([c[0] + sg * r * 0.4, c[1] - 0.35 * r])])
    elif s == "swirl":
        c, r = fig["c"], fig["r"]
        for k in range(fig["arms"]):
            ph = 2 * math.pi * k / fig["arms"]
            lines.append([T([c[0] + r * t * math.cos(ph + t * 4.0), c[1] + r * t * math.sin(ph + t * 4.0)]) for t in [i / 60 for i in range(61)]])
    return lines, dots


sheet = Image.new("RGB", (CW * COLS, CH * rows), (16, 12, 10))
for i, g in enumerate(diags):
    card = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    d = ImageDraw.Draw(card)
    d.rounded_rectangle([6, 6, CW - 6, CH - 6], radius=8, fill=(24, 20, 30, 255), outline=(150, 118, 62, 255), width=2)
    # the board: a dark lacquer disc
    BX0, BY0, BX1, BY1 = 20, 92, CW - 20, CH - 92
    d.rounded_rectangle([BX0, BY0, BX1, BY1], radius=10, fill=(10, 12, 22, 255))
    allp = [n["pos"] for n in g["nodes"]]
    for f in g.get("figure", []):
        for key in ("c", "from", "to"):
            if key in f:
                allp.append(f[key])
        if "points" in f:
            allp += f["points"]
        if "r" in f and "c" in f:
            allp += [[f["c"][0] - f["r"], f["c"][1] - f["r"]], [f["c"][0] + f["r"], f["c"][1] + f["r"]]]
        if f["shape"] == "spiral":
            allp += [[f["c"][0] - f["r1"], f["c"][1] - f["r1"]], [f["c"][0] + f["r1"], f["c"][1] + f["r1"]]]
        if f["shape"] == "grid":
            allp += [[f["c"][0] - f["size"] / 2, f["c"][1] - f["size"] / 2], [f["c"][0] + f["size"] / 2, f["c"][1] + f["size"] / 2]]
        if f["shape"] == "vajra":
            allp += [[f["c"][0], f["c"][1] - f["len"] / 2], [f["c"][0], f["c"][1] + f["len"] / 2]]
        if f["shape"] == "rays":
            allp += [[f["c"][0] - f["r1"], f["c"][1] - f["r1"]], [f["c"][0] + f["r1"], f["c"][1] + f["r1"]]]
    xs, ys = [p[0] for p in allp], [p[1] for p in allp]
    span = max(max(xs) - min(xs), max(ys) - min(ys), 0.8)
    sc = min((BX1 - BX0 - 120) / max(max(xs) - min(xs), 0.8), (BY1 - BY0 - 90) / max(max(ys) - min(ys), 0.8), 200)
    cx, cy = (BX0 + BX1) / 2 - (min(xs) + max(xs)) / 2 * sc, (BY0 + BY1) / 2 - (min(ys) + max(ys)) / 2 * sc
    T = lambda p: (cx + p[0] * sc, cy + p[1] * sc)
    glow = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    crisp = Image.new("RGBA", (CW, CH), (0, 0, 0, 0))
    cd = ImageDraw.Draw(crisp)
    for f in g.get("figure", []):
        lines, dots = figure_strokes(f, T)
        for ln in lines:
            gd.line(ln, fill=(232, 180, 80, 150), width=7)
            cd.line(ln, fill=(214, 172, 96, 200), width=2)
        for p in dots:
            cd.ellipse([p[0] - 1.6, p[1] - 1.6, p[0] + 1.6, p[1] + 1.6], fill=(240, 225, 180, 220))
    P = [T(n["pos"]) for n in g["nodes"]]
    R = 23
    for l in g["links"]:
        a, b = (l["a"], l["b"]) if l["kind"] == "adj" else (l["from"], l["to"])
        pa, pb = P[a - 1], P[b - 1]
        pts = bez(pa, pb, l.get("bend", 0.0))
        pts = [p for p in pts if math.dist(p, pa) > R + 2 and math.dist(p, pb) > R + 6]
        if len(pts) < 2:
            continue
        locked = l.get("unlock", 1) > 1
        col = (120, 205, 255, 255) if l["kind"] == "feed" else (170, 150, 120, 255)
        if l["kind"] == "feed":
            gd.line(pts, fill=(120, 205, 255, 120), width=7)
        if locked:
            dashed(cd, pts, col, 3)
        else:
            cd.line(pts, fill=col, width=3)
        if l["kind"] == "feed":
            e, q = pts[-1], pts[-2]
            ang = math.atan2(e[1] - q[1], e[0] - q[0])
            for da in (2.6, -2.6):
                cd.line([e, (e[0] + math.cos(ang + da) * 12, e[1] + math.sin(ang + da) * 12)], fill=col, width=3)
            m = pts[len(pts) // 2]
            cd.text((m[0] + 5, m[1] - 18), ("%gs" % l["seconds"]) + ((" L%d" % l["unlock"]) if locked else ""), fill=(150, 210, 250, 255), font=F12)
        elif locked:
            m = pts[len(pts) // 2]
            cd.text((m[0] + 5, m[1] - 16), "L%d" % l["unlock"], fill=(200, 185, 150, 255), font=F12)
    glow = glow.filter(ImageFilter.GaussianBlur(5))
    card.alpha_composite(glow)
    card.alpha_composite(crisp)
    d = ImageDraw.Draw(card)
    for k, (n, p) in enumerate(zip(g["nodes"], P)):
        col = POL[n["polarity"]]
        locked = n.get("unlock", 1) > 1
        d.ellipse([p[0] - R - 4, p[1] - R - 4, p[0] + R + 4, p[1] + R + 4], fill=(90, 66, 34, 255) if not locked else (50, 44, 40, 255))
        d.ellipse([p[0] - R, p[1] - R, p[0] + R, p[1] + R], fill=(14, 12, 18, 255), outline=col if not locked else (120, 110, 100, 255), width=3)
        mark = {"+": "+", "-": "−", "?": "?"}[n["polarity"]]
        d.text((p[0] - 6, p[1] - 13), mark, fill=col, font=FT)
        d.text((p[0] - R - 2, p[1] - R - 12), str(k + 1), fill=(200, 190, 160, 255), font=F12)
        if locked:
            d.text((p[0] + R - 4, p[1] - R - 10), "L%d" % n["unlock"], fill=(230, 210, 150, 255), font=F13)
        t = rule_text(n["rule"])
        tw = d.textlength(t, font=F12)
        d.rectangle([p[0] - tw / 2 - 3, p[1] + R + 4, p[0] + tw / 2 + 3, p[1] + R + 20], fill=(10, 12, 22, 200))
        d.text((p[0] - tw / 2, p[1] + R + 4), t, fill=BONE, font=F12)
    # header and growth line
    d.text((20, 16), "%s  ·  %s" % (g["name"], g["name_vi"]), fill=BONE, font=FT)
    levels = sorted(set([1] + [n.get("unlock", 1) for n in g["nodes"]] + [l.get("unlock", 1) for l in g["links"]]))
    grow = []
    for L in range(1, g["max_level"] + 1):
        grow.append(str(sum(1 for n in g["nodes"] if n.get("unlock", 1) <= L)))
    growth = ("one level" if g["max_level"] == 1 else ("levels 1-%d · nodes by level %s" % (g["max_level"], " → ".join(grow))))
    d.text((20, 44), "grade %d · realm %d+ · Trận Pháp %d · reserve %d%% · %s" % (g["grade"], g["realm_min"], g["skill_min"], round(g["reserve_share"] * 100), growth), fill=(200, 175, 125, 255), font=F13)
    d.text((20, 64), "taught by: " + g["taught_by"], fill=(160, 145, 120, 255), font=F12)
    # the idea, wrapped
    words, line, yy = g["idea"].split(), "", CH - 84
    for w in words:
        if d.textlength(line + " " + w, font=F13) > CW - 44:
            d.text((22, yy), line.strip(), fill=(215, 200, 170, 255), font=F13)
            yy += 18
            line = ""
        line += " " + w
    d.text((22, yy), line.strip(), fill=(215, 200, 170, 255), font=F13)
    sheet.paste(card.convert("RGB"), ((i % COLS) * CW, (i // COLS) * CH))
sheet.save(out)
print("ok", out)
