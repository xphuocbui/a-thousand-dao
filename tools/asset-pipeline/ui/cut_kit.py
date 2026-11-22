"""Cut the theme kit (art bible 8.7) from its image-model masters: key out the chroma green, crop each asset, scale it
to its 2x export size and measure its nine-slice margins (where the frame ends and the plain centre begins).

usage: python -I cut_kit.py <repo root> [side border in 1x px, default 6] [output suffix, default none]
Reads tools/asset-pipeline/ui/masters/kit-*-m1.png; writes assets/ui/**.png and assets/ui/kit.json (margins in export
pixels, for the Godot theme). Re-running regenerates everything from the masters.
"""
import json
import os
import sys

import numpy as np
from PIL import Image

ROOT = sys.argv[1] if len(sys.argv) > 1 else "."
BORDER_1X = float(sys.argv[2]) if len(sys.argv) > 2 else 8.0     # art bible 7.10: side edges 8 px at 1280x720
SUFFIX = sys.argv[3] if len(sys.argv) > 3 else ""
PAPER_LO, PAPER_HI = (0xD8, 0xC7, 0xA0), (0xE3, 0xD4, 0xAE)     # art bible Section 4: parchment under text
MASTERS = os.path.join(ROOT, "tools/asset-pipeline/ui/masters")
OUT = os.path.join(ROOT, "assets/ui")


def keyed(path):
    """RGBA array with the chroma green made transparent and green spill removed from the edges."""
    a = np.asarray(Image.open(path).convert("RGB")).astype(np.float32)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    spill = g - np.maximum(r, b)                      # how much greener than the other channels
    alpha = np.clip(1.0 - (spill - 30.0) / 90.0, 0.0, 1.0)
    g2 = np.minimum(g, np.maximum(r, b) + 8.0)        # despill the anti-aliased edge
    out = np.dstack([r, g2, b, alpha * 255.0])
    return out


def boxes(rgba, min_area=4000):
    """Bounding boxes of the opaque blobs, left to right, top to bottom (simple row/column projection)."""
    solid = rgba[..., 3] > 128
    found = []
    rows = np.where(solid.any(axis=1))[0]
    # split into horizontal bands of rows
    bands = np.split(rows, np.where(np.diff(rows) > 8)[0] + 1)
    for band in bands:
        sub = solid[band[0]:band[-1] + 1]
        cols = np.where(sub.any(axis=0))[0]
        for run in np.split(cols, np.where(np.diff(cols) > 8)[0] + 1):
            y0, y1, x0, x1 = band[0], band[-1] + 1, run[0], run[-1] + 1
            if (y1 - y0) * (x1 - x0) >= min_area:
                found.append((x0, y0, x1, y1))
    return found


def frame_margins(rgba, run=8):
    """Margins (left, top, right, bottom) of a frame around a parchment centre: along the middle row and column, where a
    run of `run` parchment pixels first starts from each side. Parchment is light and bluer than brass (brass rims are
    light too, so brightness alone stops at the rim)."""
    rgb = rgba[..., :3]
    lum = rgb.mean(axis=2)
    paper = (lum > 150.0) & (rgb[..., 2] > 105.0) & (rgba[..., 3] > 200.0)
    h, w = lum.shape

    def first_run(line):
        n = 0
        for i, v in enumerate(line):
            n = n + 1 if v else 0
            if n >= run:
                return i - run + 1
        return 0

    mid_r, mid_c = paper[h // 2], paper[:, w // 2]
    return first_run(mid_r), first_run(mid_c), first_run(mid_r[::-1]), first_run(mid_c[::-1])


def remap_paper(rgba):
    """Re-tints the painted parchment into Section 4's range (#D8C7A0 to #E3D4AE), keeping its mottling: each parchment
    pixel's place between the piece's 2nd and 98th brightness percentile becomes its place between the two limits.
    Brass and wood are left alone (parchment is light and bluer than brass)."""
    rgb = rgba[..., :3]
    lum = rgb.mean(axis=2)
    paper = (rgb[..., 2] > 85.0) & (rgb[..., 0] > 140.0) & (rgb[..., 0] - rgb[..., 2] < 100.0) & (rgba[..., 3] > 200.0)
    if paper.sum() < 100:
        return rgba
    lo_l, hi_l = np.percentile(lum[paper], 2), np.percentile(lum[paper], 98)
    t = np.clip((lum - lo_l) / max(1.0, hi_l - lo_l), 0.0, 1.0) ** 0.8
    lo, hi = np.array(PAPER_LO, np.float32), np.array(PAPER_HI, np.float32)
    new = lo[None, None, :] + (hi - lo)[None, None, :] * t[..., None]
    out = rgba.copy()
    out[..., :3] = np.where(paper[..., None], new, rgb)
    return out


def save(rgba, rel, size=None):
    """Writes the 2x export and its 1x copy (`_1x`): Godot's StyleBoxTexture draws fixed corners at the texture's own
    pixel size, so the theme uses the 1x copy (art bible 8.7)."""
    img = Image.fromarray(np.clip(rgba, 0, 255).astype(np.uint8), "RGBA")
    if size is not None:
        img = img.resize(size, Image.LANCZOS)
    stem = rel[:-4] + SUFFIX
    path = os.path.join(OUT, stem + ".png")
    os.makedirs(os.path.dirname(path), exist_ok=True)
    img.save(path, optimize=True)
    img.resize((max(1, img.size[0] // 2), max(1, img.size[1] // 2)), Image.LANCZOS).save(
        os.path.join(OUT, stem + "_1x.png"), optimize=True)
    return img.size


def scaled(m, s):
    return [int(round(v * s)) for v in m]


def main():
    kit = {"_doc": "Theme kit (art bible 8.7), cut by tools/asset-pipeline/ui/cut_kit.py. Sizes and margins in export "
                   "pixels (2x UI scale); margins are the nine-slice texture margins (left, top, right, bottom).",
           "pieces": {}}
    # window: one frame; scale so its side border is 12 px at 2x (6 px at 1x, art bible 7.10)
    w = keyed(os.path.join(MASTERS, "kit-window-m1.png"))
    x0, y0, x1, y1 = boxes(w)[0]
    win = w[y0:y1, x0:x1]
    win = remap_paper(win)
    m = list(frame_margins(win))
    s = 2.0 * BORDER_1X / max(1, m[0])
    # the title bar's lattice panels sit at both ends and must not stretch: the left and right margins reach past them
    lum = win[..., :3].mean(axis=2)
    bar_row = lum[max(1, m[1] // 2)]
    steps = (np.abs(np.diff(bar_row)) > 18).astype(np.float32)   # carved lattice: many sharp brightness steps
    dense = np.convolve(steps, np.ones(24), mode="same") >= 5      # wood grain gives a few; lattice gives many
    w_ = win.shape[1]
    xs = np.where(dense)[0]
    # the lattice panels are the dense runs touching each end of the bar (past the corner fittings)
    runs = np.split(xs, np.where(np.diff(xs) > 30)[0] + 1) if xs.size else []
    left_runs = [r_ for r_ in runs if r_.size and r_[0] < w_ * 0.2]
    right_runs = [r_ for r_ in runs if r_.size and r_[-1] > w_ * 0.8]
    left_end = int(max(r_[-1] for r_ in left_runs)) + 6 if left_runs else m[0]
    right_start = int(min(r_[0] for r_ in right_runs)) - 6 if right_runs else w_ - m[2]
    m[0] = max(m[0], left_end)
    m[2] = max(m[2], w_ - right_start)
    size = (int(round(win.shape[1] * s)), int(round(win.shape[0] * s)))
    got = save(win, "frames/frame_window.png", size)
    kit["pieces"]["frame_window"] = {"file": "frames/frame_window%s.png" % SUFFIX, "border_1x": BORDER_1X, "size": got, "margins": scaled(m, s),
                                     "source_margins": list(m), "scale": round(s, 4)}
    if SUFFIX:   # a comparison cut (another border width): only the window frame, under the suffix
        with open(os.path.join(OUT, "kit%s.json" % SUFFIX), "w", encoding="utf-8") as f:
            json.dump({"frame_window": kit["pieces"]["frame_window"]}, f, indent=1)
        return
    # plaques and the bar trough: two plaques on top, the trough below
    p = keyed(os.path.join(MASTERS, "kit-plaques-m1.png"))
    bx = boxes(p)
    names = ["plaque_wood", "plaque_cinnabar", "bar_trough"]
    targets = {"plaque_wood": 96, "plaque_cinnabar": 96, "bar_trough": 256}   # export widths
    for name, (a0, b0, a1, b1) in zip(names, bx):
        piece = p[b0:b1, a0:a1]
        s = targets[name] / piece.shape[1]
        size = (targets[name], int(round(piece.shape[0] * s)))
        rel = ("plaques/" if name.startswith("plaque") else "bars/") + name + ".png"
        got = save(piece, rel, size)
        # fixed corners: a plaque's rivets and corner frets reach about 12 % of its width in; the trough's rim and its
        # chamfered ends about a quarter of its height
        k = int(round(got[0] * 0.125)) if name.startswith("plaque") else int(round(got[1] * 0.3))
        kit["pieces"][name] = {"file": rel, "size": got, "margins": [k, k, k, k]}
    # tooltip card (left); the lone brass corner fitting (right) is not used (art bible 8.7 note)
    t = keyed(os.path.join(MASTERS, "kit-tooltip-m1.png"))
    a0, b0, a1, b1 = boxes(t)[0]
    card = remap_paper(t[b0:b1, a0:a1])
    m = frame_margins(card)
    s = 8.0 / max(1, m[0])                             # the card's thin edge: 8 px at 2x
    size = (int(round(card.shape[1] * s)), int(round(card.shape[0] * s)))
    got = save(card, "frames/card_tooltip.png", size)
    # the corner brackets reach further in than the edge: keep them in the fixed corners
    bracket = int(round(card.shape[1] * 0.085 * s))
    kit["pieces"]["card_tooltip"] = {"file": "frames/card_tooltip.png", "size": got,
                                     "margins": [bracket, bracket, bracket, bracket], "edge": scaled(m, s)}
    with open(os.path.join(OUT, "kit.json"), "w", encoding="utf-8") as f:
        json.dump(kit, f, indent=1)
    print(json.dumps(kit["pieces"], indent=1))


if __name__ == "__main__":
    main()
