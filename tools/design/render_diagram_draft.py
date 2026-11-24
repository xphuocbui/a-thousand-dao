"""Draws the combat-formation catalogue draft (design/formations/catalogue-draft-*.json) as one sheet of shape cards:
nodes as rings with their polarity mark and rule, feeds as arrows with seconds, adjacency as plain lines. For the
user's review of the draft only (production/plans/combat-formations.md). Usage: python -I tools/design/render_diagram_draft.py <draft.json> <out.png>"""
import json, math, sys
from PIL import Image, ImageDraw, ImageFont

src, out = sys.argv[1], sys.argv[2]
d = json.load(open(src, encoding="utf-8"))
W, H, COLS = 520, 400, 4
rows = math.ceil(len(d["diagrams"]) / COLS)
im = Image.new("RGB", (W * COLS, H * rows), (22, 16, 12))
dr = ImageDraw.Draw(im)
def font(px):
    for f in ["C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf"]:
        try:
            return ImageFont.truetype(f, px)
        except OSError:
            pass
    return ImageFont.load_default()
F16, F13, F12 = font(17), font(13), font(12)
POL = {"+": (120, 190, 110), "-": (210, 90, 80), "?": (120, 170, 230)}
KEY = {"damage_pct": "dmg", "art_speed_pct": "speed", "art_cost_pct": "cost"}

def rule_text(r):
    t = r["type"]
    if t == "mod":
        sc = ("/" + ",".join(r["scope"])) if r.get("scope") else ""
        return "%+g%% %s%s" % (r["value"], KEY[r["key"]], sc)
    if t == "adj_mod":
        return "%+g%% %s beside %s" % (r["value"], KEY[r["key"]], r["tag"])
    if t == "gate":
        c = r["cond"]
        return "only while %s %s %g" % (c["read"].replace("own.", ""), c["op"], c["value"])
    return t

for i, g in enumerate(d["diagrams"]):
    ox, oy = (i % COLS) * W, (i // COLS) * H
    dr.rectangle([ox + 6, oy + 6, ox + W - 6, oy + H - 6], outline=(140, 110, 60), width=2, fill=(32, 24, 18))
    dr.text((ox + 18, oy + 14), "%s  (%s)" % (g["name"], g["name_vi"]), fill=(236, 220, 180), font=F16)
    dr.text((ox + 18, oy + 38), "grade %d · %d nodes · realm %d+ · Trận Pháp %d · reserve %d%%" % (
        g["grade"], len(g["nodes"]), g["realm_min"], g["skill_min"], round(g["reserve_share"] * 100)), fill=(190, 170, 130), font=F12)
    dr.text((ox + 18, oy + H - 30), "taught by: " + g["taught_by"], fill=(160, 145, 115), font=F12)
    xs = [n["pos"][0] for n in g["nodes"]]; ys = [n["pos"][1] for n in g["nodes"]]
    span_x = max(max(xs) - min(xs), 1); span_y = max(max(ys) - min(ys), 1)
    s = min((W - 160) / span_x, (H - 170) / span_y, 150)
    cx = ox + W / 2 - (min(xs) + max(xs)) / 2 * s; cy = oy + 70 + (H - 150) / 2 - (min(ys) + max(ys)) / 2 * s
    P = [(cx + n["pos"][0] * s, cy + n["pos"][1] * s) for n in g["nodes"]]
    R = 22
    for l in g["links"]:
        if l["kind"] == "adj":
            a, b = P[l["a"] - 1], P[l["b"] - 1]
            dr.line([a, b], fill=(150, 130, 95), width=3)
    for l in g["links"]:
        if l["kind"] == "feed":
            a, b = P[l["from"] - 1], P[l["to"] - 1]
            ang = math.atan2(b[1] - a[1], b[0] - a[0])
            a2 = (a[0] + math.cos(ang) * R, a[1] + math.sin(ang) * R); b2 = (b[0] - math.cos(ang) * (R + 4), b[1] - math.sin(ang) * (R + 4))
            dr.line([a2, b2], fill=(227, 184, 96), width=3)
            for da in (2.6, -2.6):
                dr.line([b2, (b2[0] + math.cos(ang + da) * 12, b2[1] + math.sin(ang + da) * 12)], fill=(227, 184, 96), width=3)
            m = ((a2[0] + b2[0]) / 2, (a2[1] + b2[1]) / 2)
            dr.text((m[0] + 4, m[1] - 16), "%gs" % l["seconds"], fill=(227, 184, 96), font=F12)
    for k, (n, p) in enumerate(zip(g["nodes"], P)):
        col = POL[n["polarity"]]
        dr.ellipse([p[0] - R, p[1] - R, p[0] + R, p[1] + R], fill=(18, 14, 10), outline=col, width=4)
        mark = {"+": "+", "-": "−", "?": "?"}[n["polarity"]]
        dr.text((p[0] - 6, p[1] - 12), mark, fill=col, font=F16)
        dr.text((p[0] - R, p[1] - R - 16), str(k + 1), fill=(200, 190, 160), font=F12)
        t = rule_text(n["rule"])
        tw = dr.textlength(t, font=F12)
        dr.text((p[0] - tw / 2, p[1] + R + 3), t, fill=(220, 210, 185), font=F12)
im.save(out)
print("ok", out)
