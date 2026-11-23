"""Lock a painted map layer's coast to the game's true coast (user, 2026-11-23: "the coastline a lot of time doesn't
match up with the big map"). Both map layers are cut to the same land/water line, design/map/continent-11/base/
fine_water.png (4 px per tile, the layer the guides were rendered from), so the far paper map and the near relief agree
everywhere and the zoom cross-fade shows one coast.

Where the painting has water on true land (or land on true water), those pixels are refilled from the nearest painted
pixels of the right kind (a push-pull fill), and the two are joined along the true line with a soft edge a few pixels
wide. The true line is the 4 px raster enlarged smoothly, so it has no stair steps.

Library use (near_upres.py, far map step): lock(rgb, origin_tiles, px_per_tile, is_water) -> rgb.
Check: python -I coast_lock.py check <image> <x_tile> <y_tile> <px_per_tile> <out.jpg>  (true coast in red, before/after)
"""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

Image.MAX_IMAGE_PIXELS = None
REPO = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
EDGE_PX = 2.5   # half-width of the soft join, output px


def true_land(origin, size, px_tile, repo=REPO):
    """Smooth true-land coverage (0..1 float) for an image of [param size] whose top-left is tile [param origin]."""
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    land4 = ((fw & 3) == 0).astype(np.float32)
    w, h = size
    f = px_tile / 4.0
    # the fine-grid window covering the image, with a margin for the smoothing
    x0, y0 = origin[0] * 4 - 2, origin[1] * 4 - 2
    x1, y1 = x0 + int(np.ceil(w / f)) + 4, y0 + int(np.ceil(h / f)) + 4
    pad = np.pad(land4, 4, mode="edge")
    win = pad[int(y0) + 4:int(y1) + 4, int(x0) + 4:int(x1) + 4]
    big = Image.fromarray((win * 255).astype(np.uint8)).resize((int(win.shape[1] * f), int(win.shape[0] * f)), Image.BICUBIC)
    big = big.filter(ImageFilter.GaussianBlur(f * 0.45))
    off = int(round(2 * f))
    return np.asarray(big, np.float32)[off:off + h, off:off + w] / 255.0


def near_water(rgb):
    """The near relief's painted water: clearly blue."""
    a = rgb.astype(np.float32)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    return (b > r + 12) & (b > g - 5)


def push_pull(rgb, valid):
    """Fills the pixels where [param valid] is False from the nearest valid ones (a coarse-to-fine average)."""
    levels = []
    a, m = rgb.astype(np.float32) * valid[..., None], valid.astype(np.float32)
    while min(m.shape) > 4:
        levels.append((a, m))
        h2, w2 = m.shape[0] // 2 * 2, m.shape[1] // 2 * 2
        a = a[:h2, :w2].reshape(h2 // 2, 2, w2 // 2, 2, 3).sum((1, 3))
        m = m[:h2, :w2].reshape(h2 // 2, 2, w2 // 2, 2).sum((1, 3))
    fill = a / np.maximum(m, 1e-6)[..., None]
    for a, m in reversed(levels):
        up = np.asarray(Image.fromarray(fill.clip(0, 255).astype(np.uint8)).resize((m.shape[1], m.shape[0]), Image.BILINEAR), np.float32)
        own = a / np.maximum(m, 1e-6)[..., None]
        k = np.clip(m, 0, 1)[..., None]
        fill = own * k + up * (1 - k)
    return fill


def lock(rgb, origin, px_tile, is_water=near_water):
    """[param rgb] (H x W x 3 uint8) cut to the true coast; returns uint8."""
    h, w = rgb.shape[:2]
    cover = true_land(origin, (w, h), px_tile)
    tl = cover >= 0.5
    pw = is_water(rgb)
    land_ok = ~pw & tl          # painted land on true land
    water_ok = pw & ~tl
    land_fill = push_pull(rgb, land_ok)
    water_fill = push_pull(rgb, water_ok)
    a = rgb.astype(np.float32)
    land_px = np.where(land_ok[..., None], a, land_fill)
    water_px = np.where(water_ok[..., None], a, water_fill)
    # the soft join: coverage around 0.5 mapped to 0..1 over about EDGE_PX output px
    grad = max(1e-3, 0.5 / (EDGE_PX * 0.45 * px_tile / 4.0))
    alpha = np.clip((cover - 0.5) * (1.0 / (grad * EDGE_PX * 2)) + 0.5, 0, 1)[..., None]
    out = land_px * alpha + water_px * (1 - alpha)
    return out.clip(0, 255).astype(np.uint8)


def overlay(rgb, origin, px_tile):
    cover = true_land(origin, (rgb.shape[1], rgb.shape[0]), px_tile)
    t = cover >= 0.5
    e = t & ~(np.roll(t, 1, 0) & np.roll(t, -1, 0) & np.roll(t, 1, 1) & np.roll(t, -1, 1))
    o = rgb.copy()
    o[e] = (230, 20, 20)
    return o


if __name__ == "__main__":
    if sys.argv[1] == "check":
        img, xt, yt, pxt, out = sys.argv[2], float(sys.argv[3]), float(sys.argv[4]), float(sys.argv[5]), sys.argv[6]
        rgb = np.asarray(Image.open(img).convert("RGB"))
        res = lock(rgb, (xt, yt), pxt)
        Image.fromarray(res).save(os.path.splitext(img)[0] + "_locked.png")
        a, b = overlay(rgb, (xt, yt), pxt), overlay(res, (xt, yt), pxt)
        sheet = Image.new("RGB", (rgb.shape[1] * 2, rgb.shape[0]))
        sheet.paste(Image.fromarray(a), (0, 0))
        sheet.paste(Image.fromarray(b), (rgb.shape[1], 0))
        sheet.save(out, quality=90)
        print(out)
