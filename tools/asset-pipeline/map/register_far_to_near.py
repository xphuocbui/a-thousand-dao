"""Fit the far (paper) map's coast to the near relief's painted coast (user, 2026-11-23: "the coastline a lot of time
doesn't match up with the big map"). The near relief sits within about a quarter tile of the true coast and looks
natural, so it is the reference (cutting either painting to the 4 px-per-tile true raster gave blocky, smeared
shores). The far map's inked coast is warped onto the near relief's shore with register_far's method (offsets from
each near-shore point to the nearest far ink, smoothed into a displacement field, bilinear resample), in several
passes from broad to fine.

usage: python -I tools/asset-pipeline/map/register_far_to_near.py <repo> [--check]
  reads  design/map/continent-11/art/far/far_paper_3x_reg.png and the near relief (assets/map/map_near_relief.jpg)
  writes design/map/continent-11/art/far/far_paper_3x_near.png, the game copy assets/map/map_far_paper.jpg, and
         design/map/continent-11/art/far/register_near_check.jpg (the near shore in red over the result)
Prints the offsets before and after each pass (observations, never a verdict).
"""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import register_far as RF  # noqa: E402
from coast_lock import near_water  # noqa: E402

PASSES = [(16, 24), (10, 12), (6, 6), (4, 3)]   # (search, smoothing) in fine px (4 per tile); the last pass fits island shapes


def near_land(repo, size):
    near = Image.open(os.path.join(repo, "assets/map/map_near_relief.jpg")).convert("RGB").resize(size, Image.LANCZOS)
    w = near_water(np.asarray(near))
    # drop specks: a 3x3 majority keeps the shore shape and removes single-pixel glints
    k = sum(np.roll(np.roll(w, dy, 0), dx, 1).astype(np.int32) for dy in (-1, 0, 1) for dx in (-1, 0, 1))
    w = Image.fromarray(((k >= 5) * 255).astype(np.uint8))
    # an opening removes rivers and narrow channels (up to about a tile wide): only coasts and lake shores remain
    w = w.filter(ImageFilter.MinFilter(5)).filter(ImageFilter.MaxFilter(5))
    return np.asarray(w) < 128


def main(repo, check_only):
    d = os.path.join(repo, "design/map/continent-11/art/far")
    src = Image.open(os.path.join(d, "far_paper_3x_reg.png")).convert("RGB")
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    FH, FW = fw.shape[:2]
    target = near_land(repo, (FW, FH))
    for search, smooth in PASSES:
        RF.SEARCH, RF.SMOOTH = search, smooth
        o = RF.offsets(np.asarray(src.resize((FW, FH), Image.LANCZOS)), target)
        hh = np.hypot(o[:, 2], o[:, 3])
        print("pass search %d smooth %d: far ink to near shore, median %.2f p90 %.2f fine px (%d samples)" % (
            search, smooth, float(np.median(hh)), float(np.percentile(hh, 90)), len(o)))
        if check_only:
            return
        src = warp(src, o, FW, FH, smooth)
    RF.SEARCH = 16
    o = RF.offsets(np.asarray(src.resize((FW, FH), Image.LANCZOS)), target)
    hh = np.hypot(o[:, 2], o[:, 3])
    print("after: median %.2f p90 %.2f fine px" % (float(np.median(hh)), float(np.percentile(hh, 90))))
    src.save(os.path.join(d, "far_paper_3x_near.png"))
    src.save(os.path.join(repo, "assets/map/map_far_paper.jpg"), quality=92, optimize=True)
    small = np.asarray(src.resize((FW, FH), Image.LANCZOS)).copy()
    small[RF.coast_edge(target)] = (230, 20, 20)
    s = Image.fromarray(small)
    crops = [s.crop((170, 400, 870, 850)), s.crop((1300, 300, 2000, 750)), s.crop((700, 900, 1400, 1350))]
    sheet = Image.new("RGB", (2100, 450))
    for i, c in enumerate(crops):
        sheet.paste(c, (i * 700, 0))
    sheet.save(os.path.join(d, "register_near_check.jpg"), quality=88)


def warp(src, o, FW, FH, smooth):
    acc = np.zeros((2, FH, FW), np.float32)
    wt = np.zeros((FH, FW), np.float32)
    xi, yi = o[:, 0].astype(int), o[:, 1].astype(int)
    np.add.at(acc[0], (yi, xi), o[:, 2])
    np.add.at(acc[1], (yi, xi), o[:, 3])
    np.add.at(wt, (yi, xi), 1.0)
    wb = RF.box_blur(wt, smooth)
    fx = RF.box_blur(acc[0], smooth) / np.maximum(wb, 1e-6)
    fy = RF.box_blur(acc[1], smooth) / np.maximum(wb, 1e-6)
    conf = np.clip(wb / (np.percentile(wb[wb > 0], 30) + 1e-6), 0, 1)
    fx *= conf
    fy *= conf
    SW, SH = src.size
    FXb = np.asarray(Image.fromarray(fx).resize((SW, SH), Image.BILINEAR)) * (SW / FW)
    FYb = np.asarray(Image.fromarray(fy).resize((SW, SH), Image.BILINEAR)) * (SH / FH)
    a = np.asarray(src).astype(np.float32)
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    px = np.clip(xx + FXb, 0, SW - 1.001)
    py = np.clip(yy + FYb, 0, SH - 1.001)
    x0, y0 = np.floor(px).astype(int), np.floor(py).astype(int)
    tx, ty = (px - x0)[..., None], (py - y0)[..., None]
    out = (a[y0, x0] * (1 - tx) * (1 - ty) + a[y0, x0 + 1] * tx * (1 - ty) + a[y0 + 1, x0] * (1 - tx) * ty
           + a[y0 + 1, x0 + 1] * tx * ty)
    return Image.fromarray(out.clip(0, 255).astype(np.uint8))


if __name__ == "__main__":
    main(sys.argv[1], "--check" in sys.argv)
