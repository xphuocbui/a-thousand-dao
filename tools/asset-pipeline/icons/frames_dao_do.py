"""Round Đạo Đồ node frames and the test preview (art bible §7.9). Renders only; it never chooses content.

Six frame masters (small, road, notable, capability, keystone, start), drawn at 4x and downsampled, in a neutral
bronze; the thin inner rim is the land-tint line the engine colours (states are in-engine, §7.7). The preview puts
every candidate from ai/openai/dd_*/ inside its frame at game size and at 3x, on the tree's dark ground, plus a small
mock cluster so the set can be judged in place.

Run (from the repo root): python -I tools/asset-pipeline/icons/frames_dao_do.py
Writes build/dao_do/frames/<kind>.png (256 px masters) and build/dao_do/preview.png.
"""
import glob
import math
import os

import sys

from PIL import Image, ImageDraw, ImageFilter

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from frames_sculpt import frame, geom, inner_shadow  # noqa: E402,F401
from frames_sculpt import HOLE as HOLE_SCULPT  # noqa: E402
# import frame, geom, inner_shadow  # noqa: E402  (sculpted frames: height map lit from the top-left)

STYLE = ["sculpted"]

HERE = os.path.dirname(os.path.abspath(__file__))
AI = os.path.join(HERE, "ai", "openai")
OUT = os.path.join(HERE, "build", "dao_do")
SS = 4                                   # supersampling
BRONZE, BRONZE_HI, BRONZE_LO = (176, 141, 87), (236, 210, 160), (64, 48, 30)
JADE = (120, 200, 170)
GROUND = (14, 15, 18)
# game diameters in px at 1x (PoE-like proportions: keystone about 2.4x a small node)
SIZE = {"road": 30, "small": 40, "notable": 62, "capability": 70, "keystone": 96, "start": 110}
KIND_FRAME = {"dd_small": "small", "dd_road": "road", "dd_notable": "notable", "dd_idea": "notable",
              "dd_keystone": "keystone", "dd_cap": "capability", "dd_start": "start"}
HEX = {"fire": "#E8442A", "water": "#3F6FE0", "wood": "#2FBF8A", "metal": "#DCE3EC", "earth": "#8F5A2E",
       "thunder": "#A15CFF", "chaos": "#E0409A", "stat": "#B08D57", "light": "#FFE45C", "dark": "#6B2D8F"}
# inner radius of the painting, as a share of the frame radius
HOLE = {"road": 0.70, "small": 0.78, "notable": 0.72, "capability": 0.66, "keystone": 0.64, "start": 0.60}


def rgb(h):
    return tuple(int(h[i:i + 2], 16) for i in (1, 3, 5))


def ring(d, c, r, w, col):
    d.ellipse((c - r, c - r, c + r, c + r), outline=col, width=max(1, int(w)))


def frame_flat(kind, px=256, tint=None):
    """First test frames (flat vector), kept for comparison: RGBA, transparent inside the hole."""
    S = px * SS
    c = S / 2
    R = S / 2 - S * 0.02
    im = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(im)
    hole = R * HOLE[kind]
    band = R - hole
    tint = tint or BRONZE_HI
    # body of the frame: dark band with a bronze face
    d.ellipse((c - R, c - R, c + R, c + R), fill=BRONZE_LO)
    ring(d, c, R - band * 0.10, band * 0.20, BRONZE)
    if kind in ("notable", "capability", "keystone", "start"):
        ring(d, c, hole + band * 0.40, band * 0.14, BRONZE)        # second ring
    if kind == "notable":
        for k in range(4):                                          # four studs
            a = math.pi / 4 + k * math.pi / 2
            x, y = c + math.cos(a) * (R - band * 0.42), c + math.sin(a) * (R - band * 0.42)
            s = band * 0.16
            d.ellipse((x - s, y - s, x + s, y + s), fill=BRONZE_HI)
    if kind == "capability":
        for k in range(8):                                          # eight jade lotus points
            a = k * math.pi / 4
            p = [(c + math.cos(a) * (R + band * 0.05), c + math.sin(a) * (R + band * 0.05)),
                 (c + math.cos(a + 0.16) * (R - band * 0.55), c + math.sin(a + 0.16) * (R - band * 0.55)),
                 (c + math.cos(a - 0.16) * (R - band * 0.55), c + math.sin(a - 0.16) * (R - band * 0.55))]
            d.polygon(p, fill=JADE)
    if kind == "keystone":
        for k in range(12):                                         # twelve cloud-scroll beads
            a = k * math.pi / 6
            x, y = c + math.cos(a) * (R - band * 0.30), c + math.sin(a) * (R - band * 0.30)
            s = band * 0.15
            d.ellipse((x - s, y - s, x + s, y + s), fill=BRONZE_HI, outline=BRONZE_LO, width=int(s * 0.3))
        ring(d, c, R - band * 0.02, band * 0.05, BRONZE_HI)
    if kind == "start":
        for k in range(8):                                          # eight trigram dashes
            a = k * math.pi / 4
            for j, broken in enumerate((False, k % 2 == 0, k % 3 == 0)):
                rr = R - band * (0.18 + j * 0.13)
                half = 0.17
                if broken:
                    segs = [(a - half, a - 0.03), (a + 0.03, a + half)]
                else:
                    segs = [(a - half, a + half)]
                for a0, a1 in segs:
                    d.arc((c - rr, c - rr, c + rr, c + rr), math.degrees(a0), math.degrees(a1),
                          fill=BRONZE_HI, width=int(band * 0.07))
    if kind == "road":
        ring(d, c, hole + band * 0.45, band * 0.18, BRONZE)
    # land-tint rim hugging the painting (in-engine colour; here shown tinted)
    ring(d, c, hole + band * 0.06, band * 0.10, tint)
    # punch the hole
    m = Image.new("L", (S, S), 255)
    ImageDraw.Draw(m).ellipse((c - hole, c - hole, c + hole, c + hole), fill=0)
    im.putalpha(Image.composite(im.getchannel("A"), Image.new("L", (S, S), 0), m))
    return im.resize((px, px), Image.LANCZOS)


def node(painting, kind, px, tint):
    """Painting cropped to the frame's hole, frame on top, at px."""
    S = px * SS
    hole = geom(kind, S)[2] if STYLE[0] == "sculpted" else (S / 2 - S * 0.02) * HOLE[kind]
    base = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    src = Image.open(painting).convert("RGB")
    w = int(hole * 2 / 0.86)                                       # the medallion fills ~4/5: crop in a little
    src = src.resize((w, w), Image.LANCZOS)
    off = int(S / 2 - w / 2)
    mask = Image.new("L", (S, S), 0)
    ImageDraw.Draw(mask).ellipse((S / 2 - hole, S / 2 - hole, S / 2 + hole, S / 2 + hole), fill=255)
    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    layer.paste(src, (off, off))
    base = Image.composite(layer, base, mask)
    base = base.resize((px, px), Image.LANCZOS)
    if STYLE[0] == "sculpted":
        base = inner_shadow(base, kind)
        base.alpha_composite(frame(kind, px, tint))
    else:
        base.alpha_composite(frame_flat(kind, px, tint))
    return base


def main():
    import sys
    sys.path.insert(0, HERE)
    import subjects_dao_do as D
    os.makedirs(os.path.join(OUT, "frames"), exist_ok=True)
    for k in SIZE:
        frame(k).save(os.path.join(OUT, "frames", k + ".png"))
    rows = []
    for kind, iid in D.TEST:
        files = sorted(glob.glob(os.path.join(AI, kind, glob.escape(iid) + "_dd[0-9]*.png")))
        hue = D.TABLE[kind][iid][0]
        rows.append((kind, iid, hue, files))
    big = 150
    lab = 210
    rowh = big + 16
    strip = 20 + sum(max(v * 2, 70) + 26 for v in SIZE.values())
    frames_h = 40 + SIZE["start"] + 14 + SIZE["start"] * 2 + 40
    W = max(lab + 2 * (big + 20) + 2 * (SIZE["start"] + 20) + 20, strip)
    H = frames_h + rowh * len(rows) + 20
    sheet = Image.new("RGBA", (W, H), GROUND + (255,))
    dr = ImageDraw.Draw(sheet)
    # frame strip, at 1x and 2x
    x = 20
    dr.text((20, 8), "Frames (untinted master, then fire-tinted rim), 1x game size, then 2x", fill=(200, 200, 190))
    for k, s in SIZE.items():
        f1 = frame(k, s)
        f2 = frame(k, s * 2, rgb(HEX["fire"]))
        sheet.alpha_composite(f1, (x, 40))
        sheet.alpha_composite(f2, (x, 40 + SIZE["start"] + 14))
        dr.text((x, 40 + SIZE["start"] + 18 + s * 2), k, fill=(200, 200, 190))
        x += max(s * 2, 70) + 26
    y = frames_h
    for kind, iid, hue, files in rows:
        fk = KIND_FRAME[kind]
        tint = rgb(HEX[hue]) if kind in ("dd_road", "dd_idea", "dd_keystone") else rgb(HEX["fire"])
        dr.text((10, y + 10), "%s\n%s\nframe: %s\nhue: %s" % (kind, iid, fk, hue), fill=(220, 220, 210))
        for j, f in enumerate(files[:2]):
            n = node(f, fk, big, tint)
            sheet.alpha_composite(n, (lab + j * (big + 20), y))
            s = SIZE[fk]
            g = node(f, fk, s, tint)
            gx = lab + 2 * (big + 20) + j * (SIZE["start"] + 20) + (SIZE["start"] - s) // 2
            sheet.alpha_composite(g, (gx, y + (big - s) // 2))
        if not files:
            dr.text((lab, y + 60), "no candidates yet", fill=(230, 90, 80))
        y += rowh
    p = os.path.join(OUT, "preview.png")
    sheet.convert("RGB").save(p)
    print("preview\t%s" % p)
    mock(rows)


def mock(rows):
    """A tiny mock cluster at game size: roads into a notable-and-smalls picture with a keystone at the end."""
    def first(kind, iid=None):
        for k, i, h, f in rows:
            if k == kind and (iid is None or i == iid) and f:
                return f[0], h
        return None, None
    W, H = 620, 360
    im = Image.new("RGBA", (W * 2, H * 2), GROUND + (255,))
    d = ImageDraw.Draw(im)
    pts = {"r1": (60, 300), "r2": (150, 260), "s1": (240, 220), "s2": (300, 160), "n1": (380, 120),
           "s3": (300, 280), "s4": (380, 300), "n2": (470, 250), "k": (540, 110), "i": (460, 40)}
    edges = [("r1", "r2"), ("r2", "s1"), ("s1", "s2"), ("s2", "n1"), ("s1", "s3"), ("s3", "s4"), ("s4", "n2"),
             ("n1", "k"), ("n1", "i"), ("n2", "k")]
    for a, b in edges:
        (x0, y0), (x1, y1) = pts[a], pts[b]
        d.line((x0 * 2, y0 * 2, x1 * 2, y1 * 2), fill=(96, 82, 60), width=6)
    fire = rgb(HEX["fire"])
    place = [("r1", "dd_road", "hoa", "road"), ("r2", "dd_road", "hoa", "road"), ("s1", "dd_small", "attack_pct", "small"),
             ("s2", "dd_small", "khi_huyet_pct", "small"), ("s3", "dd_small", "attack_pct", "small"),
             ("s4", "dd_small", "khi_huyet_pct", "small"), ("n1", "dd_idea", "F10", "notable"),
             ("n2", "dd_notable", "crit_damage_pct", "notable"), ("k", "dd_keystone", "nirvana", "keystone"),
             ("i", "dd_idea", "F10", "notable")]
    for key, kind, iid, fk in place:
        f, h = first(kind, iid)
        if not f:
            continue
        s = SIZE[fk] * 2
        n = node(f, fk, s, fire)
        x, y = pts[key]
        im.alpha_composite(n, (x * 2 - s // 2, y * 2 - s // 2))
    p = os.path.join(OUT, "mock_cluster.png")
    im.convert("RGB").save(p)
    print("mock\t%s (2x)" % p)


if __name__ == "__main__":
    main()
