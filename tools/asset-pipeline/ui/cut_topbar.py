"""Top bar kit (art bible 7.13, Paradox-style bar, 2026-11-23): cuts the chroma-green masters into game assets.

usage:
  python -I tools/asset-pipeline/ui/cut_topbar.py <repo> candidates   writes masters/topbar-candidates.png: every
                                                                      icon candidate numbered, at its shown size on
                                                                      the bar strip (the user picks, 8.6 rule 9)
  python -I tools/asset-pipeline/ui/cut_topbar.py <repo> cut          cuts the bar pieces and the picked icons
                                                                      (picks.json) into assets/ui/topbar/ and
                                                                      assets/icons/hud/
  python -I tools/asset-pipeline/ui/cut_topbar.py <repo> check        art bible 8.6 for HUD medallions: prints
                                                                      each problem (a missing or extra file, a size
                                                                      other than 64 x 64, a name outside the
                                                                      convention, a non-zero alpha on the border)
                                                                      and exits 1 if any; prints the checked count

Masters (tools/asset-pipeline/ui/masters/, prompts beside them in prompts/): kit-topbar-m1.png (strip, date
cartouche, icon socket, divider), kit-res-icons-m1.png (12 resource candidates, 4 x 3), kit-season-icons-m1.png
(8 season candidates, 4 x 2). Exports are 2x the shown size (art bible 8.1); the engine scales down.
"""
import json
import os
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
MASTERS = os.path.join(HERE, "masters")
ICON_PX = 64      # resource and season icons: shown at 32 px (top_bar_icon), exported at 2x
STRIP_H = 112     # the strip's exported height (2x the 56 px bar)
RES_NAMES = ["crystals", "stones", "incense", "peach", "qi_orb", "lotus", "sword", "swords", "bell", "scroll",
             "jade_token", "jade_disc"]
SEASON_NAMES = ["plum", "willow", "lotus", "sun", "maple", "chrysanthemum", "pine_snow", "plum_snow"]


def keyed(path):
    """RGBA with the chroma green made transparent (soft edge) and green spill pulled out of the edge pixels."""
    a = np.asarray(Image.open(path).convert("RGB")).astype(np.float32)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    greenness = g - np.maximum(r, b)                      # ~255 on the key, small on wood and brass
    alpha = np.clip((140.0 - greenness) / 60.0, 0.0, 1.0)
    alpha = np.where(alpha < 0.08, 0.0, alpha)            # keying noise in the green margin is fully clear
    spill = np.maximum(0.0, g - np.maximum(r, b))
    a[..., 1] = np.where(alpha < 1.0, g - spill * (1.0 - alpha), g)
    out = np.dstack([a, alpha * 255.0]).clip(0, 255).astype(np.uint8)
    return Image.fromarray(out, "RGBA")


def runs(mask_1d, min_len=6):
    """[start, end) runs where mask_1d is true."""
    out, start = [], None
    for i, v in enumerate(mask_1d):
        if v and start is None:
            start = i
        elif not v and start is not None:
            if i - start >= min_len:
                out.append((start, i))
            start = None
    if start is not None and len(mask_1d) - start >= min_len:
        out.append((start, len(mask_1d)))
    return out


def grid_cells(img):
    """The pieces of a sheet, row by row: each row is a y-run of opaque pixels, split into x-runs."""
    al = np.asarray(img)[..., 3] > 128
    cells = []
    for y0, y1 in runs(al.any(axis=1)):
        for x0, x1 in runs(al[y0:y1].any(axis=0)):
            cells.append((x0, y0, x1, y1))
    return cells


def square(img, box, px):
    x0, y0, x1, y1 = box
    # The piece alone (its own bounding box, so no neighbour bleeds in), centred on a transparent square 12 % larger:
    # the downscale filter spreads the rim, and the margin keeps every border pixel clear (art bible 8.6).
    piece = img.crop((x0, y0, x1, y1))
    side = int(max(x1 - x0, y1 - y0) * 1.12) + 2
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.alpha_composite(piece, ((side - piece.width) // 2, (side - piece.height) // 2))
    return canvas.resize((px, px), Image.LANCZOS)


def icon_sheets():
    res = keyed(os.path.join(MASTERS, "kit-res-icons-m1.png"))
    sea = keyed(os.path.join(MASTERS, "kit-season-icons-m1.png"))
    rc, sc = grid_cells(res), grid_cells(sea)
    assert len(rc) == 12 and len(sc) == 8, ("cells found", len(rc), len(sc))
    return res, rc, sea, sc


def bar_pieces():
    bar = keyed(os.path.join(MASTERS, "kit-topbar-m1.png"))
    cells = grid_cells(bar)
    assert len(cells) == 4, ("bar pieces found", len(cells))
    return bar, cells   # strip, cartouche, socket, divider (rows top to bottom, then left to right)


def strip_tile(bar, box):
    """A seamless horizontal tile from the strip's middle: one carving period wide, scaled to STRIP_H."""
    x0, y0, x1, y1 = box
    s = bar.crop((x0, y0, x1, y1))
    w, h = s.size
    scale = STRIP_H / h
    s = s.resize((max(1, int(w * scale)), STRIP_H), Image.LANCZOS)
    # period: the column-brightness autocorrelation peak of the middle band
    g = np.asarray(s.convert("L")).astype(np.float32)[int(STRIP_H * 0.3):int(STRIP_H * 0.7)].mean(axis=0)
    g = g - g.mean()
    mid = len(g) // 2
    best, period = -1e9, 64
    for p in range(40, min(400, mid)):
        c = float(np.dot(g[mid - p:mid], g[mid:mid + p]))
        if c > best:
            best, period = c, p
    return s.crop((mid, 0, mid + period, STRIP_H)), period


def candidates(repo):
    res, rc, sea, sc = icon_sheets()
    bar, cells = bar_pieces()
    tile, _ = strip_tile(bar, cells[0])
    shown = 32
    rows = []
    for title, sheet, cs, names in (("resource icons", res, rc, RES_NAMES), ("season icons", sea, sc, SEASON_NAMES)):
        rows.append((title, [(i + 1, names[i], square(sheet, c, shown * 2)) for i, c in enumerate(cs)]))
    W, slot = 1500, 120
    H = 40 + sum(40 + 2 * 60 for _ in rows)
    sheet = Image.new("RGBA", (W, H), (226, 212, 174, 255))
    from PIL import ImageDraw
    d = ImageDraw.Draw(sheet)
    y = 20
    for title, items in rows:
        d.text((20, y), title + " (numbered; top row at the shown 32 px on the bar, bottom row at 64 px)", fill=(43, 33, 24, 255))
        y += 24
        band = Image.new("RGBA", (W, 56))
        t = tile.resize((int(tile.width * 56 / tile.height), 56), Image.LANCZOS)
        for x in range(0, W, t.width):
            band.paste(t, (x, 0))
        sheet.alpha_composite(band, (0, y))
        for k, (n, name, im) in enumerate(items):
            x = 20 + k * slot
            sheet.alpha_composite(im.resize((shown, shown), Image.LANCZOS), (x, y + 12))
            d.text((x + shown + 6, y + 20), str(n), fill=(232, 217, 181, 255))
            sheet.alpha_composite(im, (x, y + 64))
            d.text((x, y + 64 + 66), "%d %s" % (n, name), fill=(43, 33, 24, 255))
        y += 56 + 100
    out = os.path.join(MASTERS, "topbar-candidates.png")
    sheet.save(out)
    print(out)


def cut(repo):
    picks = json.load(open(os.path.join(HERE, "prompts", "topbar-picks.json"), encoding="utf-8"))
    res, rc, sea, sc = icon_sheets()
    bar, cells = bar_pieces()
    ui = os.path.join(repo, "assets/ui/topbar")
    icons = os.path.join(repo, "assets/icons/hud")
    os.makedirs(ui, exist_ok=True)
    os.makedirs(icons, exist_ok=True)
    tile, period = strip_tile(bar, cells[0])
    tile.save(os.path.join(ui, "topbar_strip.png"))
    x0, y0, x1, y1 = cells[1]   # the date cartouche: 2x of a 56 px tall frame
    c = bar.crop((x0, y0, x1, y1))
    c = c.resize((int(c.width * 2 * 60 / c.height), 2 * 60), Image.LANCZOS)
    c.save(os.path.join(ui, "topbar_cartouche.png"))
    square(bar, cells[2], ICON_PX + 16).save(os.path.join(ui, "topbar_socket.png"))
    x0, y0, x1, y1 = cells[3]
    dv = bar.crop((x0, y0, x1, y1))
    dv.resize((max(2, int(dv.width * 80 / dv.height)), 80), Image.LANCZOS).save(os.path.join(ui, "topbar_divider.png"))
    for key, n in picks["resources"].items():
        square(res, rc[int(n) - 1], ICON_PX).save(os.path.join(icons, "res_%s.png" % key))
    for key, n in picks["seasons"].items():
        square(sea, sc[int(n) - 1], ICON_PX).save(os.path.join(icons, "season_%s.png" % key))
    for name in ("topbar_strip", "topbar_cartouche", "topbar_socket", "topbar_divider"):   # 1x copies (drawn at size)
        im = Image.open(os.path.join(ui, name + ".png"))
        im.resize((max(1, im.width // 2), max(1, im.height // 2)), Image.LANCZOS).save(os.path.join(ui, name + "_1x.png"))
    print("strip period %d px; cartouche %dx%d; icons %d + %d" % (period, c.width, c.height, len(picks["resources"]), len(picks["seasons"])))


def check(repo):
    picks = json.load(open(os.path.join(HERE, "prompts", "topbar-picks.json"), encoding="utf-8"))
    icons = os.path.join(repo, "assets/icons/hud")
    want = {"res_%s.png" % k for k in picks["resources"]} | {"season_%s.png" % k for k in picks["seasons"]}
    have = {f for f in os.listdir(icons) if f.endswith(".png")} if os.path.isdir(icons) else set()
    problems = ["missing: " + f for f in sorted(want - have)] + ["not in the picks (extra): " + f for f in sorted(have - want)]
    for f in sorted(have & want):
        im = Image.open(os.path.join(icons, f)).convert("RGBA")
        if im.size != (ICON_PX, ICON_PX):
            problems.append("%s: size %dx%d, expected %dx%d" % (f, im.width, im.height, ICON_PX, ICON_PX))
        a = np.asarray(im)[..., 3]
        border = int(max(a[0].max(), a[-1].max(), a[:, 0].max(), a[:, -1].max()))
        if border > 0:
            problems.append("%s: border alpha %d (expected 0)" % (f, border))
    for p in problems:
        print(p)
    print("checked %d HUD medallions, %d problems" % (len(have & want), len(problems)))
    sys.exit(1 if problems else 0)


if __name__ == "__main__":
    repo, mode = sys.argv[1], sys.argv[2]
    {"candidates": candidates, "cut": cut, "check": check}[mode](repo)
