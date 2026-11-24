# PROTOTYPE - NOT FOR PRODUCTION
"""UI mood round 3 (2026-11-24): layout sketches for the image model to repaint. The user called the built windows
greybox text lists ("They look so bad") and asked for CK3 / EU5-style windows with art boxes (portraits, the sect's
own place painting). Each sketch carries the NEW layout, real game text and existing art pasted in (place paintings,
technique and status icons); the boxes marked "PORTRAIT" are new art the game does not have yet.
usage: python -I r3_wireframes.py <repo root>   -> in-r3-character.png, in-r3-sect.png (1536x864)"""
import os, sys
from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.abspath(sys.argv[1])
HERE = os.path.dirname(os.path.abspath(__file__))
W, H = 1536, 864
FONT = os.path.join(ROOT, "assets/fonts/literata/literata_vf.ttf")
HEAD = os.path.join(ROOT, "assets/fonts/cormorant_garamond/cormorant_garamond_vf.ttf")


def f(px, head=False):
    return ImageFont.truetype(HEAD if head else FONT, px)


def icon(rel, s):
    return Image.open(os.path.join(ROOT, rel)).convert("RGBA").resize((s, s), Image.LANCZOS)


def backdrop():
    # the real map behind the window (the 1920x1080 evidence shot, scaled)
    m = Image.open(os.path.join(ROOT, "production/qa/evidence/ui-windows/01-character-top-1920x1080.png")).convert("RGB")
    return m.resize((W, H), Image.LANCZOS)


WOOD, PARCH, INK, CREAM, BRASS, BOX = (58, 34, 24), (226, 212, 180), (40, 28, 20), (236, 222, 196), (176, 140, 70), (150, 140, 125)


def panel(d, x0, y0, x1, y1, title):
    d.rectangle([x0, y0, x1, y1], fill=WOOD, outline=BRASS, width=3)
    d.text((x0 + 22, y0 + 10), title, font=f(26, True), fill=CREAM)
    d.text((x1 - 34, y0 + 12), "X", font=f(20), fill=CREAM)


def inset(d, box, label=None):
    d.rectangle(box, fill=PARCH, outline=BRASS, width=2)
    if label:
        d.text((box[0] + 10, box[1] + 6), label, font=f(15), fill=(120, 84, 40))


def artbox(d, box, label):
    d.rectangle(box, fill=BOX, outline=BRASS, width=3)
    d.text((box[0] + 10, box[1] + 10), label, font=f(14), fill=(30, 30, 30))


def character():
    im = backdrop()
    d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = 24, 70, 980, 840
    panel(d, x0, y0, x1, y1, "Character")
    # tabs
    tx = x0 + 300
    for i, t in enumerate(["Overview", "Công pháp", "Traits", "Ties", "History"]):
        w = 118
        d.rectangle([tx, y0 + 8, tx + w, y0 + 42], fill=(90, 56, 36) if i == 0 else (70, 44, 30), outline=BRASS, width=2)
        d.text((tx + 12, y0 + 14), t, font=f(17), fill=CREAM)
        tx += w + 6
    # portrait + name banner
    artbox(d, (x0 + 22, y0 + 60, x0 + 262, y0 + 360), "PORTRAIT\nyoung man of 16,\nplain grey robe,\nloose cultivator")
    d.rectangle([x0 + 22, y0 + 362, x0 + 262, y0 + 398], fill=(110, 28, 24), outline=BRASS, width=2)
    d.text((x0 + 70, y0 + 366), "Vô Danh", font=f(24, True), fill=CREAM)
    inset(d, (x0 + 280, y0 + 60, x1 - 22, y0 + 200))
    d.text((x0 + 296, y0 + 70), "Luyện Khí Sơ kỳ · tầng 1", font=f(26, True), fill=INK)
    d.text((x0 + 296, y0 + 108), "Loose cultivator (tán tu) · age 16 / 120 · Rating —", font=f(18), fill=INK)
    d.text((x0 + 296, y0 + 140), "Tu vi 0 / 39", font=f(17), fill=INK)
    d.rectangle([x0 + 420, y0 + 144, x1 - 60, y0 + 162], fill=(80, 60, 40), outline=BRASS)
    d.text((x0 + 296, y0 + 168), "+6.98 a season here · next level in 6 seasons", font=f(16), fill=INK)
    # traits row
    inset(d, (x0 + 280, y0 + 210, x1 - 22, y0 + 300), "TRAITS")
    trait_icons = ["assets/icons/status/buff_earth.png", "assets/icons/status/buff_metal.png", "assets/icons/status/buff_water.png"]
    for i, (n, ic) in enumerate(zip(["Content (an phận)", "Impatient (nóng vội)", "Trusting (cả tin)"], trait_icons)):
        cx = x0 + 300 + i * 215
        im.paste(icon(ic, 44), (cx, y0 + 240), icon(ic, 44))
        d.text((cx + 52, y0 + 252), n, font=f(15), fill=INK)
    # linh can
    inset(d, (x0 + 280, y0 + 310, x0 + 610, y0 + 520), "LINH CĂN · triple root · x0.50")
    els = [("木 Mộc", 0, None), ("火 Hỏa", 0, "fire"), ("土 Thổ", 31, "earth"), ("金 Kim", 66, "metal"), ("水 Thủy", 51, "water")]
    for i, (n, v, e) in enumerate(els):
        yy = y0 + 342 + i * 34
        d.text((x0 + 296, yy), n[0], font=ImageFont.truetype("C:/Windows/Fonts/msyh.ttc", 17), fill=INK)
        d.text((x0 + 318, yy), n[2:], font=f(17), fill=INK)
        d.rectangle([x0 + 380, yy + 4, x0 + 540, yy + 20], fill=(80, 60, 40))
        if v:
            d.rectangle([x0 + 380, yy + 4, x0 + 380 + int(160 * v / 100), yy + 20], fill=(196, 150, 60))
        d.text((x0 + 552, yy), str(v) if v else "—", font=f(16), fill=INK)
    # vitals tiles
    inset(d, (x0 + 620, y0 + 310, x1 - 22, y0 + 520), "VITALS")
    vit = [("Health", "400/400", "assets/icons/hud/res_lifespan.png"), ("Linh lực", "56", "assets/icons/hud/res_cultivation.png"),
           ("Thần thức", "68", "assets/icons/hud/res_renown.png"), ("Vitality", "100 %", "assets/icons/hud/res_rating.png")]
    for i, (n, v, ic) in enumerate(vit):
        cx = x0 + 636 + (i % 2) * 160
        cy = y0 + 344 + (i // 2) * 84
        d.rectangle([cx, cy, cx + 148, cy + 74], fill=(214, 198, 162), outline=BRASS)
        im.paste(icon(ic, 36), (cx + 6, cy + 18), icon(ic, 36))
        d.text((cx + 48, cy + 8), n, font=f(14), fill=INK)
        d.text((cx + 48, cy + 32), v, font=f(22, True), fill=INK)
    # thien phu tiles
    inset(d, (x0 + 22, y0 + 410, x0 + 262, y0 + 700), "THIÊN PHÚ")
    tp = [("Ngộ tính", 35), ("Căn cốt", 40), ("Thần hồn", 68), ("Khí vận", 54), ("Đạo tâm", 48), ("Mị lực", 36)]
    for i, (n, v) in enumerate(tp):
        cx = x0 + 32 + (i % 2) * 116
        cy = y0 + 440 + (i // 2) * 84
        d.rectangle([cx, cy, cx + 106, cy + 74], fill=(214, 198, 162), outline=BRASS)
        d.text((cx + 8, cy + 6), n, font=f(14), fill=INK)
        d.text((cx + 8, cy + 28), str(v), font=f(28, True), fill=INK)
    # cong phap slots
    inset(d, (x0 + 280, y0 + 530, x1 - 22, y0 + 700), "CÔNG PHÁP")
    slots = [("Main", "Huyền Hoàng Quyết  L3/6", "assets/icons/techniques/tech_deep_vein_scripture.png"),
             ("Art", "Bàn Thạch Quyết  L3/6", "assets/icons/techniques/tech_afterimage_sword_canon.png"),
             ("Auxiliary", "empty", None), ("Auxiliary", "empty", None)]
    for i, (k, n, ic) in enumerate(slots):
        cx = x0 + 296 + i * 162
        cy = y0 + 562
        d.rectangle([cx, cy, cx + 150, cy + 128], fill=(214, 198, 162), outline=BRASS, width=2)
        if ic:
            im.paste(icon(ic, 64), (cx + 43, cy + 8), icon(ic, 64))
        else:
            d.rectangle([cx + 43, cy + 8, cx + 107, cy + 72], outline=(120, 100, 70), width=2)
        d.text((cx + 8, cy + 78), k, font=f(13), fill=(120, 84, 40))
        d.text((cx + 8, cy + 98), n, font=f(13), fill=INK)
    # buttons
    for i, b in enumerate(["Inventory", "Đạo Đồ", "Rankings"]):
        d.rectangle([x0 + 22 + i * 150, y1 - 60, x0 + 160 + i * 150, y1 - 20], fill=(70, 44, 30), outline=BRASS, width=2)
        d.text((x0 + 40 + i * 150, y1 - 52), b, font=f(18), fill=CREAM)
    im.save(os.path.join(HERE, "in-r3-character.png"))


def sect():
    im = backdrop()
    d = ImageDraw.Draw(im)
    x0, y0, x1, y1 = 24, 70, 980, 840
    panel(d, x0, y0, x1, y1, "Sect")
    # hero banner: the sect's own place painting (exists today)
    art = Image.open(os.path.join(ROOT, "design/map/continent-11/art/places/paint_1.png")).convert("RGB")
    bw, bh = x1 - x0 - 44, 250
    art = art.resize((bw, int(art.height * bw / art.width)), Image.LANCZOS)
    top = (art.height - bh) // 2
    im.paste(art.crop((0, top, bw, top + bh)), (x0 + 22, y0 + 52))
    d.rectangle([x0 + 22, y0 + 52, x0 + 22 + bw, y0 + 52 + bh], outline=BRASS, width=3)
    d.rectangle([x0 + 40, y0 + 250, x0 + 520, y0 + 292], fill=(20, 40, 30))
    d.text((x0 + 56, y0 + 252), "Thúy Vi Tông", font=f(34, True), fill=CREAM)
    d.text((x0 + 300, y0 + 264), "Sect of the Emerald Haze", font=f(15), fill=CREAM)
    # head portrait + facts
    artbox(d, (x0 + 22, y0 + 318, x0 + 182, y0 + 520), "PORTRAIT\nsect head\nNgu Lam Sơn\nman, Nguyên Anh")
    inset(d, (x0 + 196, y0 + 318, x1 - 22, y0 + 520))
    d.text((x0 + 212, y0 + 326), "Righteous (chính đạo) great sect of alchemists", font=f(20, True), fill=INK)
    d.text((x0 + 212, y0 + 360), "Head: Ngu Lam Sơn (Nguyên Anh) · First elder: Quyền Thanh Lam (Kết Đan)", font=f(16), fill=INK)
    d.text((x0 + 212, y0 + 388), "Founded 500 by Phùng Yên Hà · seat in the north-western hills", font=f(16), fill=INK)
    tiles = [("Founded", "500"), ("Path", "Chính đạo"), ("Craft", "Alchemy"), ("Your standing", "Outsider")]
    for i, (n, v) in enumerate(tiles):
        cx = x0 + 212 + i * 184
        d.rectangle([cx, y0 + 424, cx + 172, y0 + 506], fill=(214, 198, 162), outline=BRASS)
        d.text((cx + 10, y0 + 432), n, font=f(14), fill=(120, 84, 40))
        d.text((cx + 10, y0 + 456), v, font=f(26, True), fill=INK)
    # notable members with portraits
    inset(d, (x0 + 22, y0 + 532, x0 + 560, y1 - 76), "NOTABLE MEMBERS")
    mem = [("Ngu Lam Sơn", "Head · Nguyên Anh"), ("Quyền Thanh Lam", "First elder · Kết Đan"), ("Phùng Yên Hà", "Founder · died 1000, at 640")]
    for i, (n, r) in enumerate(mem):
        cy = y0 + 556 + i * 52
        artbox(d, (x0 + 36, cy, x0 + 82, cy + 46), "P")
        d.text((x0 + 96, cy + 2), n, font=f(18, True), fill=(140, 30, 24))
        d.text((x0 + 96, cy + 24), r, font=f(14), fill=INK)
    # lore + territory
    inset(d, (x0 + 574, y0 + 532, x1 - 22, y1 - 76), "THE SECT")
    lore = ("Twin summits rise out of the\nblue-green haze, slopes stepped\nwith herb terraces and white-walled\n"
            "halls under green-glazed roofs.")
    d.text((x0 + 590, y0 + 562), lore, font=f(15), fill=INK)
    for i, b in enumerate(["Ask to join", "Visit the seat", "History"]):
        d.rectangle([x0 + 22 + i * 170, y1 - 60, x0 + 180 + i * 170, y1 - 20], fill=(110, 28, 24) if i == 0 else (70, 44, 30), outline=BRASS, width=2)
        d.text((x0 + 40 + i * 170, y1 - 52), b, font=f(18), fill=CREAM)
    im.save(os.path.join(HERE, "in-r3-sect.png"))


character()
sect()
print("ok")
