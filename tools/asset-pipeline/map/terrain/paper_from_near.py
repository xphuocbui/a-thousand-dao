"""The far (paper) map made from the near layer itself (user, 2026-11-23: "coastal still does not match when zoomed";
the old paper map was a separate painting, so its coasts and terrain never agreed with the near layer). The near
layer (hybrid pass 1, near_24px.png) is shrunk to the paper map's size and given a parchment look by code, and the
coast is drawn in ink on the game's true coast curve, so the zoom cross-fade shows one map. No image model.

  land   the painting, softened, its colours muted and warmed toward ink-and-wash on parchment, with the relief kept
  paper  a parchment grain multiplied over everything
  sea    a pale blue-grey wash that deepens a little away from the shore, with faint hand-drawn wave marks
  coast  a dark brown ink line on the true coast (coast.bin) and a soft coloured wash inside it

usage: python -I tools/asset-pipeline/map/terrain/paper_from_near.py <repo> [near.png]
writes assets/map/map_far_paper.jpg (4608 x 3072, as the game expects) and a preview.
"""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from water_lock import field  # noqa: E402

OUT = tuple(int(v) for v in os.environ.get("PAPER_OUT", "4608,3072").split(","))   # PAPER_OUT=w,h for a guide at another scale
PAPER_TINT = {   # biome id -> wash colour on parchment (0..1)
    0: (0.62, 0.70, 0.50), 1: (0.70, 0.76, 0.52), 2: (0.52, 0.64, 0.45), 3: (0.80, 0.82, 0.60), 4: (0.85, 0.79, 0.58),
    5: (0.92, 0.84, 0.62), 6: (0.93, 0.91, 0.85), 7: (0.82, 0.62, 0.46), 8: (0.62, 0.68, 0.55), 9: (0.55, 0.64, 0.50),
    10: (0.76, 0.74, 0.62), 11: (0.74, 0.70, 0.64), 12: (0.66, 0.73, 0.54), 13: (0.50, 0.47, 0.45), 14: (0.82, 0.80, 0.72),
    15: (0.95, 0.96, 0.95), 16: (0.70, 0.72, 0.55), 17: (0.78, 0.84, 0.82), 18: (0.78, 0.84, 0.82)}
GRID = (540, 360)


def parchment(w, h, seed=3):
    rng = np.random.default_rng(seed)
    a = np.zeros((h, w), np.float32)
    for s, amp in ((8, 0.5), (32, 0.3), (128, 0.2)):
        n = rng.random((h // s + 2, w // s + 2)).astype(np.float32)
        a += np.asarray(Image.fromarray((n * 255).astype(np.uint8)).resize((w + 2 * s, h + 2 * s), Image.BICUBIC), np.float32)[:h, :w] / 255.0 * amp
    fib = rng.random((h, w)).astype(np.float32)
    fib = np.asarray(Image.fromarray((fib * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.7)), np.float32) / 255.0
    return 0.9 + 0.12 * (a - a.mean()) + 0.05 * (fib - 0.5)


def main(repo, near_path):
    near = Image.open(near_path).convert("RGB").resize(OUT, Image.LANCZOS).filter(ImageFilter.GaussianBlur(0.8))
    a = np.asarray(near, np.float32) / 255.0
    w, h = OUT
    px = w / GRID[0]
    coast = np.fromfile(os.path.join(repo, "assets/map/terrain/coast.bin"), np.float32).reshape(1440, 2160)
    sd = field((0, 0), (w, h), px, coast, 0.0)                 # tiles, + water
    # land: muted, warmed (ink and wash on parchment), relief kept through the luminance
    # colours from the biome data (classic map washes on parchment), light and shade from the painting
    biome = np.fromfile(os.path.join(repo, "assets/map/terrain/biome.bin"), np.uint8).reshape(1440, 2160)
    tint = np.zeros((1440, 2160, 3), np.float32)
    for k, c in PAPER_TINT.items():
        tint[biome == k] = c
    tint_img = Image.fromarray((tint * 255).astype(np.uint8)).resize(OUT, Image.BICUBIC).filter(ImageFilter.GaussianBlur(px * 0.6))
    tint = np.asarray(tint_img, np.float32) / 255.0
    lum = a @ np.array([0.3, 0.55, 0.15], np.float32)
    shade = lum / np.maximum(1e-3, np.asarray(Image.fromarray((lum * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(px * 2.5)), np.float32) / 255.0)
    shade = np.clip(1.0 + (shade - 1.0) * 0.75, 0.6, 1.35)          # local light and shade (ridges, tree crowns)
    land = np.clip(tint * shade[..., None], 0, 1)
    if os.environ.get("PAPER_FLAT"):
        # a flat plan for the illustrated repaint: plain biome washes, a faint relief hint, rivers as blue ink lines,
        # so the model draws mountains and trees as symbols instead of copying the painting's light (user 2026-11-23)
        land = np.clip(tint * np.clip(1.0 + (shade - 1.0) * 0.25, 0.85, 1.15)[..., None], 0, 1)
        riv = np.fromfile(os.path.join(repo, "assets/map/terrain/river.bin"), np.uint8).reshape(2880, 4320)
        rv = np.asarray(Image.fromarray(riv).resize(OUT, Image.BILINEAR), np.float32)[..., None] / 255.0
        land = land * (1 - 0.85 * rv) + np.array([0.30, 0.48, 0.62], np.float32) * 0.85 * rv
    # sea: pale wash, a touch deeper offshore, faint wave marks
    rng = np.random.default_rng(5)
    deep = np.clip(sd / 4.0, 0, 1)[..., None]
    sea = np.array([0.80, 0.84, 0.80], np.float32) * (1 - deep) + np.array([0.70, 0.77, 0.78], np.float32) * deep
    marks = np.zeros((h, w), np.float32)
    for _ in range(900):
        x, y = rng.integers(0, w), rng.integers(0, h)
        if 0 <= y < h and 0 <= x < w and sd[y, x] > 1.5:
            L = rng.integers(14, 30)
            xs = np.arange(x, min(w, x + L))
            ys = (y + 2.5 * np.sin((xs - x) / L * np.pi * 2)).astype(int).clip(0, h - 1)
            marks[ys, xs] = 1.0
    marks = np.asarray(Image.fromarray((marks * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(0.6)), np.float32) / 255.0
    sea = sea * (1 - 0.35 * marks[..., None]) + np.array([0.42, 0.48, 0.52], np.float32) * 0.35 * marks[..., None]
    # coast: a soft coloured wash just inside the sea, and the ink line on the true curve
    wash = np.clip(1 - sd / 0.6, 0, 1) * (sd > 0)
    sea = sea * (1 - 0.35 * wash[..., None]) + np.array([0.55, 0.70, 0.72], np.float32) * 0.35 * wash[..., None]
    alpha = np.clip(0.5 - sd / (1.2 / px), 0, 1)[..., None]
    col = land * alpha + sea * (1 - alpha)
    ink = np.clip(1 - np.abs(sd) / (1.1 / px), 0, 1)
    col = col * (1 - 0.85 * ink[..., None]) + np.array([0.20, 0.14, 0.09], np.float32) * 0.85 * ink[..., None]
    col *= parchment(w, h)[..., None]
    out = Image.fromarray((col.clip(0, 1) * 255).astype(np.uint8))
    if os.environ.get("PAPER_DEST"):      # a guide for the paper repaint (paper_hybrid.py), not the game copy
        out.save(os.environ["PAPER_DEST"])
    elif not os.environ.get("PAPER_PREVIEW_ONLY"):
        out.save(os.path.join(repo, "assets/map/map_far_paper.jpg"), quality=92)
    out.resize((1536, 1024), Image.LANCZOS).save(os.path.join(repo, "design/map/continent-11/art/near/hybrid/paper_preview.jpg"), quality=88)
    print("paper map", out.size)


if __name__ == "__main__":
    repo = sys.argv[1]
    main(repo, sys.argv[2] if len(sys.argv) > 2 else os.path.join(repo, "design/map/continent-11/art/near/hybrid/near_24px.png"))
