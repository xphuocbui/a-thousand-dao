"""The whole map in the paper style (user, 2026-11-23: "Good enough, do the map"; low quality). The flat data guide
(paper_from_near.py with PAPER_FLAT, 16 px per tile) is cut into overlapping 96 x 54 tile pieces; each is redrawn by the
image model in the old paper map's style (paper_hybrid.py, with each piece's own description of its land from the
data), and the pieces are feather-blended into paper_16px.png. The game draws the water over it (canvas_map_terrain
painted_land mode with paper-style water), so whatever the model drew in the sea does not show.

usage: python -I paper_full.py <repo> plan | paint | stitch | export | all
export writes the game copies: assets/map/map_paper_16px.jpg (near, one texture) and assets/map/map_far_paper.jpg.
"""
import os
import sys

import numpy as np
from PIL import Image

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import hybrid_full as HF  # noqa: E402
import paper_hybrid as PH  # noqa: E402
from paint_tiles import match_colour  # noqa: E402

PX = 16
PIECE = (96, 54)
GRID = (540, 360)
RAMP = 180


def root(repo):
    return os.path.join(repo, "design/map/continent-11/art/paper/full")


def pieces():
    xs = [round(i * (GRID[0] - PIECE[0]) / 6) for i in range(7)]
    ys = [round(j * (GRID[1] - PIECE[1]) / 7) for j in range(8)]
    return [(x, y) for y in ys for x in xs]


def plan(repo):
    d = root(repo)
    os.makedirs(d, exist_ok=True)
    g = Image.open(os.path.join(repo, "design/map/continent-11/art/paper/guide_16px_flat.png")).convert("RGB")
    for x, y in pieces():
        f = os.path.join(d, "guide_%d_%d.png" % (x, y))
        if not os.path.exists(f):
            g.crop((x * PX, y * PX, (x + PIECE[0]) * PX, (y + PIECE[1]) * PX)).save(f)
        # each piece's own prompt: the paper prompt plus what the data puts in it (hybrid_full.contents)
        txt = PH.PROMPT + "\n\n" + contents(repo, x, y)
        open(os.path.join(d, "prompt_%d_%d.md" % (x, y)), "w", encoding="utf-8").write(txt)
    print("pieces", len(pieces()))


def contents(repo, x0, y0):
    old = HF.PIECE
    HF.PIECE = PIECE
    try:
        return HF.contents(repo, x0, y0)
    finally:
        HF.PIECE = old


def stitch(repo):
    d = root(repo)
    W, H = GRID[0] * PX, GRID[1] * PX
    guide = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/art/paper/guide_16px_flat.png")).convert("RGB"), np.float32)
    acc = guide * 1e-3
    wt = np.full((H, W, 1), 1e-3, np.float32)
    pw, ph = PIECE[0] * PX, PIECE[1] * PX
    wx = np.minimum(1.0, np.minimum(np.arange(pw) + 1, pw - np.arange(pw)) / RAMP).astype(np.float32)
    wy = np.minimum(1.0, np.minimum(np.arange(ph) + 1, ph - np.arange(ph)) / RAMP).astype(np.float32)
    mask = (wy[:, None] * wx[None, :])[..., None]
    for x0, y0 in pieces():
        f = os.path.join(d, "paint_%d_%d.png" % (x0, y0))
        if not os.path.exists(f):
            print("missing", x0, y0)
            continue
        g = guide[y0 * PX:y0 * PX + ph, x0 * PX:x0 * PX + pw]
        img = np.asarray(Image.open(f).convert("RGB").resize((pw, ph), Image.LANCZOS), np.float32)
        img = match_colour(img, g, 0.3).astype(np.float32)     # neighbours agree; keeps the drawing's own colour
        m = mask.copy()
        if x0 == 0:
            m[:, :RAMP] = np.maximum(m[:, :RAMP], wy[:, None, None])
        if y0 == 0:
            m[:RAMP, :] = np.maximum(m[:RAMP, :], wx[None, :, None])
        if x0 + PIECE[0] >= GRID[0]:
            m[:, -RAMP:] = np.maximum(m[:, -RAMP:], wy[:, None, None])
        if y0 + PIECE[1] >= GRID[1]:
            m[-RAMP:, :] = np.maximum(m[-RAMP:, :], wx[None, :, None])
        acc[y0 * PX:y0 * PX + ph, x0 * PX:x0 * PX + pw] += img * m
        wt[y0 * PX:y0 * PX + ph, x0 * PX:x0 * PX + pw] += m
    out = Image.fromarray((acc / wt).clip(0, 255).astype(np.uint8))
    out.save(os.path.join(d, "paper_16px.png"))
    out.resize((1620, 1080), Image.LANCZOS).save(os.path.join(d, "paper_preview.jpg"), quality=88)
    print("stitched", out.size)


def export(repo):
    src = Image.open(os.path.join(root(repo), "paper_16px.png")).convert("RGB")
    src.save(os.path.join(repo, "assets/map/map_paper_16px.jpg"), quality=92, subsampling=0)
    src.resize((4608, 3072), Image.LANCZOS).save(os.path.join(repo, "assets/map/map_far_paper.jpg"), quality=92)
    print("exported")


if __name__ == "__main__":
    repo, cmd = sys.argv[1], sys.argv[2]
    if cmd in ("plan", "all"):
        plan(repo)
    if cmd in ("paint", "all"):
        PH.paint(repo, root(repo), "low")
    if cmd in ("stitch", "all"):
        stitch(repo)
    if cmd in ("export", "all"):
        export(repo)
