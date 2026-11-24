# PROTOTYPE - NOT FOR PRODUCTION
"""UI mood round 4 (2026-11-24): layout sketches of the combat UI around combat formations (trận đồ) for the image
model to repaint. User: "implement the formation system ... Then redesign the combat ui to accomodate the combat
formation"; mock-ups first (user pick). Sketch A: the character sheet's Combat tab as the diagram collection and
editor. Sketch B: the fight screen with each side's diagram drawn as a graph (art icons in the nodes, feed arrows),
real portraits, and the empty Wards / Items / Buffs / Debuffs / Status boxes folded into one chip row.
usage: python -I r4_wireframes.py <repo root>   -> in-r4-editor.png, in-r4-fight-sketch.png (1536x864)"""
import math, os, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(sys.argv[1])
HERE = os.path.dirname(os.path.abspath(__file__))
W, H = 1536, 864
FONT = os.path.join(ROOT, "assets/fonts/literata/literata_vf.ttf")
HEAD = os.path.join(ROOT, "assets/fonts/cormorant_garamond/cormorant_garamond_vf.ttf")
PAPER, INK, BRASS, WOOD, RED = (227, 212, 174), (43, 33, 24), (201, 162, 90), (42, 26, 18), (132, 25, 27)
POL = {"+": (60, 130, 60), "-": (170, 50, 40), "?": (50, 100, 170)}


def f(px, head=False):
    return ImageFont.truetype(HEAD if head else FONT, px)


def icon(rel, s):
    return Image.open(os.path.join(ROOT, rel)).convert("RGBA").resize((s, s), Image.LANCZOS)


def portrait(rel, w, h):
    return Image.open(os.path.join(ROOT, rel)).convert("RGBA").resize((w, h), Image.LANCZOS)


def graph(im, d, nodes, links, cx, cy, scale, r, icons):
    """nodes: [(x, y, polarity, rule text)], links: [(kind, a, b, secs)], icons: per node a path or None."""
    P = [(cx + x * scale, cy + y * scale) for x, y, _, _ in nodes]
    for kind, a, b, s in links:
        pa, pb = P[a - 1], P[b - 1]
        if kind == "adj":
            d.line([pa, pb], fill=(120, 100, 70), width=3)
            continue
        ang = math.atan2(pb[1] - pa[1], pb[0] - pa[0])
        a2 = (pa[0] + math.cos(ang) * (r + 2), pa[1] + math.sin(ang) * (r + 2))
        b2 = (pb[0] - math.cos(ang) * (r + 6), pb[1] - math.sin(ang) * (r + 6))
        d.line([a2, b2], fill=(196, 140, 40), width=4)
        for da in (2.6, -2.6):
            d.line([b2, (b2[0] + math.cos(ang + da) * 14, b2[1] + math.sin(ang + da) * 14)], fill=(196, 140, 40), width=4)
        m = ((a2[0] + b2[0]) / 2, (a2[1] + b2[1]) / 2)
        d.text((m[0] - 10, m[1] - 24), "%gs" % s, fill=(150, 100, 20), font=f(15))
    for k, ((x, y, pol, txt), p) in enumerate(zip(nodes, P)):
        d.ellipse([p[0] - r - 5, p[1] - r - 5, p[0] + r + 5, p[1] + r + 5], fill=(120, 90, 40))
        d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=(27, 18, 12), outline=POL[pol], width=4)
        if icons[k]:
            ic = icon(icons[k], int(r * 1.5))
            im.paste(ic, (int(p[0] - r * 0.75), int(p[1] - r * 0.75)), ic)
        else:
            d.text((p[0] - 18, p[1] - 10), "empty", fill=(150, 130, 100), font=f(13))
        badge = {"+": "+", "-": "−", "?": "?"}[pol]
        d.ellipse([p[0] + r * 0.55, p[1] - r - 6, p[0] + r * 0.55 + 24, p[1] - r + 18], fill=POL[pol])
        d.text((p[0] + r * 0.55 + 6, p[1] - r - 6), badge, fill=(255, 250, 235), font=f(17))
        d.text((p[0] - r - 4, p[1] - r - 8), str(k + 1), fill=INK, font=f(14))
        tw = d.textlength(txt, font=f(14))
        d.text((p[0] - tw / 2, p[1] + r + 8), txt, fill=INK, font=f(14))
    return P


def sketch_editor():
    m = Image.open(os.path.join(ROOT, "production/qa/evidence/ui-windows/review-2026-11-24/01-hud.png")).convert("RGB").resize((W, H), Image.LANCZOS)
    im = m.convert("RGBA")
    d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = 14, 70, 960, 800
    d.rectangle([x0, y0, x1, y1], fill=WOOD)
    d.rectangle([x0 + 8, y0 + 8, x1 - 8, y1 - 8], fill=PAPER)
    d.text((x0 + 24, y0 + 16), "Character", fill=INK, font=f(24, True))
    d.text((x0 + 24, y0 + 50), "Vô Danh  ·  Age 16 / 120  ·  Rating 197", fill=INK, font=f(17))
    tx = x0 + 24
    for t, act in [("Overview", 0), ("Combat", 1), ("Equipment", 0), ("Fate & life", 0)]:
        w = d.textlength(t, font=f(16)) + 22
        d.rectangle([tx, y0 + 80, tx + w, y0 + 108], fill=(60, 40, 25) if not act else (30, 20, 12), outline=BRASS if act else (90, 70, 40), width=2)
        d.text((tx + 11, y0 + 84), t, fill=(240, 225, 190), font=f(16))
        tx += w + 6
    # left: the collection
    cx0, cy0 = x0 + 22, y0 + 124
    d.rectangle([cx0, cy0, cx0 + 250, y1 - 130], fill=(214, 197, 156), outline=BRASS, width=2)
    d.text((cx0 + 10, cy0 + 8), "FORMATIONS (TRẬN ĐỒ)", fill=INK, font=f(15))
    cards = [("Plain Row", "3 plain slots · no rules", False, False), ("Three Talents Chain", "Tam Tài Trận · 3 nodes · grade 0", True, False),
             ("Twin Edge Fork", "Song Nhận Trận · taught by sword sects", False, True), ("Turtle Shell", "Quy Giáp Trận · taught by righteous sects", False, True)]
    yy = cy0 + 36
    for name, sub, on, locked in cards:
        d.rectangle([cx0 + 8, yy, cx0 + 242, yy + 78], fill=(236, 224, 192) if not locked else (205, 192, 160), outline=(196, 140, 40) if on else (150, 125, 80), width=3 if on else 1)
        d.rectangle([cx0 + 14, yy + 8, cx0 + 74, yy + 68], fill=(30, 22, 15))
        d.text((cx0 + 22, yy + 28), "shape", fill=(180, 160, 120), font=f(12))
        d.text((cx0 + 82, yy + 8), name + ("  ✓ SET" if on else ""), fill=INK if not locked else (110, 95, 70), font=f(15))
        d.text((cx0 + 82, yy + 32), sub, fill=(90, 70, 50), font=f(12))
        if locked:
            d.text((cx0 + 82, yy + 52), "not known yet", fill=(110, 95, 70), font=f(12))
        yy += 88
    # centre: the editor
    ex0 = cx0 + 262
    d.rectangle([ex0, cy0, ex0 + 430, y1 - 130], fill=(30, 24, 18), outline=BRASS, width=2)
    d.text((ex0 + 12, cy0 + 8), "THREE TALENTS CHAIN · Tam Tài Trận", fill=(236, 220, 180), font=f(16))
    d.text((ex0 + 12, cy0 + 32), "grade 0 · level 1 · 3 nodes of your 3 art slots", fill=(190, 170, 130), font=f(13))
    d.rectangle([ex0 + 10, cy0 + 60, ex0 + 420, y1 - 140], fill=(214, 197, 156))
    graph(im, d, [(0, 0, "+", "+12% art speed"), (1, 0, "+", "+10% damage"), (2, 0, "-", "+12% art cost")],
          [("feed", 1, 2, 1.0), ("feed", 2, 3, 1.0)], ex0 + 85, cy0 + 220, 135, 44,
          ["assets/icons/techniques/tech_afterimage_sword_canon.png", "assets/icons/techniques/tech_ashen_phoenix_canon.png", None])
    d.text((ex0 + 24, cy0 + 330), "Feeds: when node 1 fires, node 2's wait drops 1 s; node 2 feeds node 3.", fill=INK, font=f(13))
    d.text((ex0 + 24, cy0 + 352), "Plain slots after the nodes: none.", fill=INK, font=f(13))
    # right: arts pool
    ax0 = ex0 + 442
    d.rectangle([ax0, cy0, x1 - 22, y1 - 130], fill=(214, 197, 156), outline=BRASS, width=2)
    d.text((ax0 + 10, cy0 + 8), "YOUR ARTS", fill=INK, font=f(15))
    arts = [("Quick Draw Cut", "tech_afterimage_sword_canon"), ("Ashen Phoenix Palm", "tech_ashen_phoenix_canon"), ("Iron Body", "tech_body_body_low")]
    yy = cy0 + 38
    for n, ic in arts:
        p = icon("assets/icons/techniques/%s.png" % ic, 44)
        d.rectangle([ax0 + 10, yy, ax0 + 58, yy + 48], fill=(27, 18, 12), outline=BRASS)
        im.paste(p, (ax0 + 12, yy + 2), p)
        d.text((ax0 + 66, yy + 6), n, fill=INK, font=f(14))
        d.text((ax0 + 66, yy + 26), "in node 1" if n == "Quick Draw Cut" else ("in node 2" if "Phoenix" in n else "free"), fill=(110, 90, 60), font=f(12))
        yy += 58
    d.text((ax0 + 10, yy + 6), "Drag an art onto a node,", fill=(90, 70, 50), font=f(12))
    d.text((ax0 + 10, yy + 22), "or click a node then an art.", fill=(90, 70, 50), font=f(12))
    # bottom: the price of the choice
    by = y1 - 118
    tiles = [("Lay fuel", "1 of 30 linh thạch"), ("Linh lực reserved", "2 % (cap 90 %)"), ("Strength", "laid 100 % · ambush 70 % · blind 50 %"), ("Lay when foreseen", "ON")]
    tx = x0 + 22
    for t, v in tiles:
        w = 215
        d.rectangle([tx, by, tx + w, by + 64], fill=(214, 197, 156), outline=(150, 125, 80))
        d.text((tx + 10, by + 6), t, fill=(90, 70, 50), font=f(13))
        d.text((tx + 10, by + 28), v, fill=INK, font=f(16))
        tx += w + 10
    d.text((x0 + 22, y1 - 40), "Inventory ›    Đạo Đồ ›    Rankings ›", fill=(120, 90, 30), font=f(15))
    return im.convert("RGB")


def sketch_fight():
    im = Image.open(os.path.join(HERE, "in-r4-fight.png")).convert("RGBA").resize((W, H), Image.LANCZOS)
    d = ImageDraw.Draw(im)
    sx = W / 1920.0
    for side in (0, 1):
        x0 = int((24 if side == 0 else 1258) * sx)
        x1 = int((662 if side == 0 else 1892) * sx)
        # portrait box over the letter tile
        pr = portrait("assets/portraits/type/" + sorted(x for x in os.listdir(os.path.join(ROOT, "assets/portraits/type")) if x.endswith(".webp"))[3 if side == 0 else 40], 92, 110)
        im.paste(pr, (x0 + (0 if side == 0 else x1 - x0 - 92), int(150 * sx)), pr)
        # cover the formation strip and the five empty boxes with the new layout
        top, bot = int(218 * sx), int(960 * sx)
        d.rectangle([x0, top, x1, bot], fill=PAPER)
        d.rectangle([x0, top, x1, top + int(380 * sx)], fill=(30, 24, 18), outline=BRASS, width=2)
        title = "FORMATION · Three Talents Chain · laid 100 %" if side == 0 else "FORMATION · Thunder Drum Chain · carried 70 %"
        d.text((x0 + 12, top + 8), title, fill=(236, 220, 180), font=f(15))
        if side == 0:
            graph(im, d, [(0, 0, "+", "+12% speed"), (1, 0, "+", "+10% dmg"), (2, 0, "-", "+12% cost")], [("feed", 1, 2, 1.0), ("feed", 2, 3, 1.0)],
                  x0 + 90, top + 150, 150, 38, ["assets/icons/techniques/tech_afterimage_sword_canon.png", "assets/icons/techniques/tech_ashen_phoenix_canon.png",
                                              "assets/icons/techniques/tech_body_body_low.png"])
            d.text((x0 + 14, top + 236), "node 1 fed node 2: −1.0 s  ·  cooldown rings fill as each art readies", fill=(200, 180, 140), font=f(12))
        else:
            graph(im, d, [(0, 0, "-", "−15% dmg"), (1, 0, "+", "+10% speed"), (2, 0, "+", "+10% speed"), (3, 0, "+", "+25% dmg")],
                  [("feed", 1, 2, 1.5), ("feed", 2, 3, 1.5), ("feed", 3, 4, 1.5)], x0 + 60, top + 150, 115, 34,
                  ["assets/icons/techniques/tech_ashen_phoenix_canon.png", "assets/icons/techniques/tech_afterimage_sword_canon.png",
                   "assets/icons/techniques/tech_body_body_high.png", "assets/icons/techniques/tech_ashen_phoenix_canon.png"])
        cy = top + int(400 * sx)
        d.text((x0 + 10, cy), "WARDS  ·  ITEMS  ·  BUFFS  ·  DEBUFFS  ·  STATUS", fill=INK, font=f(13))
        for k in range(6):
            d.rectangle([x0 + 10 + k * 46, cy + 24, x0 + 50 + k * 46, cy + 64], fill=(205, 190, 150), outline=(150, 125, 80))
        d.text((x0 + 10, cy + 74), "one row of chips; a kind with nothing shows nothing", fill=(110, 95, 70), font=f(12))
    return im.convert("RGB")


sketch_editor().save(os.path.join(HERE, "in-r4-editor.png"))
sketch_fight().save(os.path.join(HERE, "in-r4-fight-sketch.png"))
print("ok")
