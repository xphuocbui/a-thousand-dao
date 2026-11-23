"""Rebuild a painted map layer's water from the game's own data (user, 2026-11-23: "a lot of phantom land that is like
a blur in the middle of the ocean/lakes. coastal still does not match when zoomed"). Measured: the near painting put land
on 4.7 % of the true sea (43 % of the shallow shelf, and 42 % of it more than 5 tiles from any coast), and at Cô Vụ Đảo
both layers draw the island larger than the game's coast. The image model decided where the coast is; here the data
does.

Water is drawn wherever the game says water (design/map/continent-11/base/fine_water.png, 4 px per tile, smoothed into
a curve so it has no stair steps): its colour comes from the true seabed depth (fine_elevation.png) through a palette
sampled from the painting's own clean open water (so it keeps the painted look), plus the painting's own ripple
texture and a band of surf along the shore. Land keeps its painted pixels; where the painting has water on true land,
the land is refilled from its nearest painted land. Nothing the image model drew in the water survives.

Library: lock_near(rgb, origin_tiles, px_per_tile) -> rgb. Prototype: python -I water_lock.py proto <repo>
(Cô Vụ Đảo, writes production/qa/evidence/map-upres-test/13-*).
"""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from coast_lock import push_pull, near_water  # noqa: E402
from register_far import box_blur  # noqa: E402

REPO = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
BASE = os.path.join(REPO, "design/map/continent-11/base")
DEPTHS = [0, -10, -25, -50, -100, -200, -500, -1000, -2000, -4000]   # palette knots, metres


def _fine(name):
    return np.asarray(Image.open(os.path.join(BASE, name)))


def field(origin, size, px_tile, arr, sigma_tiles, mode=Image.BICUBIC):
    """[param arr] (a 4 px-per-tile float field) resampled smoothly onto an image of [param size] whose top-left is
    tile [param origin], blurred by [param sigma_tiles]."""
    w, h = size
    f = px_tile / 4.0
    x0, y0 = int(np.floor(origin[0] * 4)) - 8, int(np.floor(origin[1] * 4)) - 8
    x1, y1 = x0 + int(np.ceil(w / f)) + 16, y0 + int(np.ceil(h / f)) + 16
    pad = np.pad(arr, 16, mode="edge")
    win = pad[y0 + 16:y1 + 16, x0 + 16:x1 + 16].astype(np.float32)
    lo, hi = float(win.min()), float(win.max())
    norm = (win - lo) / max(1e-6, hi - lo)
    big = Image.fromarray((norm * 65535).astype(np.uint16).astype(np.int32), mode="I").convert("F")
    big = big.resize((int(win.shape[1] * f), int(win.shape[0] * f)), mode)
    a = np.asarray(big, np.float32)
    if sigma_tiles > 0:   # three box passes of radius r approximate a Gaussian of sigma r
        a = box_blur(a, max(1, int(round(sigma_tiles * px_tile))))
    off_x = int(round((origin[0] * 4 - x0) * f))
    off_y = int(round((origin[1] * 4 - y0) * f))
    a = a[off_y:off_y + h, off_x:off_x + w] / 65535.0
    return a * (hi - lo) + lo


def palette(rgb, depth, coast_d):
    """Median painted water colour per depth knot, from water pixels at least 1.5 tiles off any coast."""
    pw = near_water(rgb)
    ok = pw & (coast_d > 1.5)
    cols = []
    for i, dk in enumerate(DEPTHS):
        lo = DEPTHS[i + 1] if i + 1 < len(DEPTHS) else -1e9
        hi = DEPTHS[i - 1] if i > 0 else 1e9
        m = ok & (depth <= hi) & (depth > lo)
        cols.append(np.median(rgb[m], axis=0) if m.sum() > 200 else None)
    # fill gaps from neighbours (shallow knots often have no clean samples)
    known = [i for i, c in enumerate(cols) if c is not None]
    for i in range(len(cols)):
        if cols[i] is None:
            j = min(known, key=lambda k: abs(k - i))
            cols[i] = cols[j]
    cols = np.array(cols, np.float32)
    # the shallowest knots lean toward the painting's turquoise shallows
    cols[0] = cols[0] * 0.6 + np.array([70, 170, 175], np.float32) * 0.4
    cols[1] = cols[1] * 0.8 + np.array([60, 150, 165], np.float32) * 0.2
    return cols


def ramp(depth, cols):
    d = np.clip(depth, DEPTHS[-1], DEPTHS[0])
    out = np.zeros(depth.shape + (3,), np.float32)
    for i in range(len(DEPTHS) - 1):
        a, b = DEPTHS[i], DEPTHS[i + 1]
        m = (d <= a) & (d >= b)
        t = ((a - d[m]) / (a - b))[..., None]
        out[m] = cols[i] * (1 - t) + cols[i + 1] * t
    return out


def lock_near(rgb, origin, px_tile, cols=None, seed=7):
    """The near layer's water rebuilt from the data; returns (uint8 rgb, the palette used)."""
    h, w = rgb.shape[:2]
    fw = _fine("fine_water.png")
    land4 = ((fw & 3) == 0).astype(np.float32)
    el4 = _fine("fine_elevation.png").astype(np.float32) - 10000.0
    cover = field(origin, (w, h), px_tile, land4, 0.18)              # smooth true-land coverage, 0..1
    depth = field(origin, (w, h), px_tile, np.minimum(el4, 0.0), 0.35)
    tl = cover >= 0.5
    # distance from the true coast in tiles (approximate, from the coverage field's blur, good to ~1.5 tiles)
    far_cov = field(origin, (w, h), px_tile, land4, 1.2)
    coast_d = np.where(tl, 0.0, np.clip((0.5 - far_cov) * 3.0, 0, 3.0))
    a = rgb.astype(np.float32)
    if cols is None:
        cols = palette(rgb, depth, coast_d)
    water = ramp(depth, cols)
    # the painting's own ripple texture: its high-pass detail on clean open water, tiled by mirroring
    pw = near_water(rgb)
    clean = pw & (coast_d > 1.5)
    hp = a - np.asarray(Image.fromarray(a.clip(0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(px_tile * 0.25)), np.float32)
    if clean.sum() > 1000:
        ys, xs = np.nonzero(clean)
        ty, tx = int(np.median(ys)), int(np.median(xs))
        s = int(min(h, w, px_tile * 10)) // 2 * 2
        y0, x0 = int(np.clip(ty - s // 2, 0, h - s)), int(np.clip(tx - s // 2, 0, w - s))
        tile = hp[y0:y0 + s, x0:x0 + s]
        tile = np.concatenate([tile, tile[::-1]], 0)
        tile = np.concatenate([tile, tile[:, ::-1]], 1)
        reps = (h // tile.shape[0] + 1, w // tile.shape[1] + 1, 1)
        water += np.tile(tile, reps)[:h, :w] * 0.9
    # surf: a soft light band hugging the shore, broken up by the ripple detail
    rng = np.random.default_rng(seed)
    noise = np.asarray(Image.fromarray((rng.random((h // 8 + 2, w // 8 + 2)) * 255).astype(np.uint8)).resize((w + 16, h + 16), Image.BICUBIC), np.float32)[:h, :w] / 255.0
    shore = np.clip(1.0 - np.abs(cover - 0.5) / 0.12, 0, 1) * (~tl)
    band = np.clip(1.0 - (0.5 - cover) / 0.35, 0, 1) * (~tl)
    water = water * (1 - 0.25 * band[..., None]) + np.array([150, 205, 205], np.float32) * 0.25 * band[..., None]
    water = water * (1 - 0.55 * (shore * noise)[..., None]) + 235.0 * 0.55 * (shore * noise)[..., None]
    # land: painted land on true land kept; painted water on true land refilled from the nearest painted land
    land_ok = ~pw & tl
    land = np.where(land_ok[..., None], a, push_pull(rgb, land_ok | (~tl & ~pw)))
    alpha = np.clip((cover - 0.5) / 0.08 + 0.5, 0, 1)[..., None]
    out = land * alpha + water * (1 - alpha)
    return out.clip(0, 255).astype(np.uint8), cols


def proto(repo):
    """Cô Vụ Đảo (region 10) at 24 px per tile from pass 1 (the repaint before landmarks), before and after."""
    src = Image.open(os.path.join(repo, "design/map/continent-11/art/near/upres4/near_24px.png")).convert("RGB")
    x0, y0, x1, y1 = 34, 226, 145, 325
    crop = np.asarray(src.crop((x0 * 24, y0 * 24, x1 * 24, y1 * 24)))
    out, _ = lock_near(crop, (x0, y0), 24)
    ev = os.path.join(repo, "production/qa/evidence/map-upres-test")
    Image.fromarray(out).save(os.path.join(ev, "13-co-vu-dao-near-water-locked.jpg"), quality=90)
    small = lambda a: Image.fromarray(a).resize((a.shape[1] // 3, a.shape[0] // 3), Image.LANCZOS)
    s = Image.new("RGB", (crop.shape[1] // 3 * 2 + 10, crop.shape[0] // 3))
    s.paste(small(crop), (0, 0))
    s.paste(small(out), (crop.shape[1] // 3 + 10, 0))
    s.save(os.path.join(ev, "13-co-vu-dao-before-after.jpg"), quality=90)
    print("ok")


if __name__ == "__main__":
    if sys.argv[1] == "proto":
        proto(sys.argv[2])
