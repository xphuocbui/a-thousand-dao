"""Register the far (paper) map to the game's coastline (user, 2026-11-23: provinces "misplaced to the actual land
border with the sea"). The image model drifted the painted geography by up to a few tiles, so anything drawn from the
grid (provinces, region borders, place markers) sat off the painted shore. This finds the painting's own inked coast
near each stretch of the true coast (design/map/continent-11/base/fine_water.png, the layer the guide was rendered
from), measures the offset, smooths the offsets into a gentle displacement field and resamples the painting along it,
so its coast lands on the true coast while its brushwork is kept.

usage:
  python -I tools/asset-pipeline/map/register_far.py <repo> [--check]
    reads  design/map/continent-11/art/far/far_paper_3x.png
    writes design/map/continent-11/art/far/far_paper_3x_reg.png, the game copy assets/map/map_far_paper.jpg, and
           design/map/continent-11/art/far/register_check.jpg (the true coast in red over the result, three crops)
Prints the offsets before and after (observations, never a verdict).
"""
import os
import sys

import numpy as np
from PIL import Image

SEARCH = 28        # fine px (4 per tile): how far from the true coast the painted coast is looked for
STRIDE = 3         # sample every few coast pixels
SMOOTH = 40        # fine px: the displacement field's smoothing radius (a gentle, large-scale warp)


def box_blur(a, r):
    """A separable box blur of radius r (three passes approximate a Gaussian), numpy only."""
    for _ in range(3):
        for axis in (0, 1):
            c = np.cumsum(np.pad(a, [(r + 1, r) if k == axis else (0, 0) for k in range(a.ndim)], mode="edge"), axis=axis)
            hi = np.take(c, np.arange(2 * r + 1, c.shape[axis]), axis=axis)
            lo = np.take(c, np.arange(0, c.shape[axis] - 2 * r - 1), axis=axis)
            a = (hi - lo) / (2 * r + 1)
    return a


def coast_edge(land):
    inner = land & np.roll(land, 1, 0) & np.roll(land, -1, 0) & np.roll(land, 1, 1) & np.roll(land, -1, 1)
    return land & ~inner


def ink_mask(rgb):
    """The painted coastline's ink: dark, brownish-grey (not the dark green of tree symbols)."""
    a = rgb.astype(np.float32)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    lum = 0.3 * r + 0.59 * g + 0.11 * b
    return (lum < 95) & (g <= r + 8)


def offsets(paint_fine, true_land):
    """For sampled true-coast pixels: the vector to the nearest painted ink within SEARCH (None where none)."""
    ink = ink_mask(paint_fine)
    edge = coast_edge(true_land)
    ys, xs = np.nonzero(edge)
    keep = np.arange(len(xs)) % STRIDE == 0
    ys, xs = ys[keep], xs[keep]
    H, W = true_land.shape
    out = []
    win = np.mgrid[-SEARCH:SEARCH + 1, -SEARCH:SEARCH + 1]
    d2 = (win[0] ** 2 + win[1] ** 2).astype(np.float32)
    for y, x in zip(ys.tolist(), xs.tolist()):
        y0, y1, x0, x1 = y - SEARCH, y + SEARCH + 1, x - SEARCH, x + SEARCH + 1
        if y0 < 0 or x0 < 0 or y1 > H or x1 > W:
            continue
        m = ink[y0:y1, x0:x1]
        if not m.any():
            continue
        dd = np.where(m, d2, np.inf)
        k = np.unravel_index(np.argmin(dd), dd.shape)
        out.append((x, y, k[1] - SEARCH, k[0] - SEARCH))
    return np.array(out, np.float32)


PASSES = [(SEARCH, 40), (16, 20), (10, 9)]   # (search, smoothing) per pass: a broad warp, then finer local ones (islands)


def main(repo, check_only):
    d = os.path.join(repo, "design/map/continent-11/art/far")
    src = Image.open(os.path.join(d, "far_paper_3x.png")).convert("RGB")
    for search, smooth in PASSES:
        src = one_pass(src, repo, d, check_only, search, smooth)
        if check_only:
            return
    finish(src, repo, d)


def one_pass(src, repo, d, check_only, search, smooth):
    global SEARCH, SMOOTH
    SEARCH, SMOOTH = search, smooth
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    true_land = (fw & 3) == 0
    FH, FW = true_land.shape
    fine = np.asarray(src.resize((FW, FH), Image.LANCZOS))
    o = offsets(fine, true_land)
    print("coast samples %d; offset to the painted ink (fine px): median %.1f, 90th %.1f" % (
        len(o), float(np.median(np.hypot(o[:, 2], o[:, 3]))), float(np.percentile(np.hypot(o[:, 2], o[:, 3]), 90))))
    if check_only:
        return src
    # splat the offsets onto the fine grid and smooth them into a field; where no sample is near, the field fades to 0
    acc = np.zeros((2, FH, FW), np.float32)
    wt = np.zeros((FH, FW), np.float32)
    xi, yi = o[:, 0].astype(int), o[:, 1].astype(int)
    np.add.at(acc[0], (yi, xi), o[:, 2])
    np.add.at(acc[1], (yi, xi), o[:, 3])
    np.add.at(wt, (yi, xi), 1.0)
    wb = box_blur(wt, SMOOTH)
    fx = box_blur(acc[0], SMOOTH) / np.maximum(wb, 1e-6)
    fy = box_blur(acc[1], SMOOTH) / np.maximum(wb, 1e-6)
    conf = np.clip(wb / (np.percentile(wb[wb > 0], 30) + 1e-6), 0, 1)   # far from any coast: no warp
    fx *= conf
    fy *= conf
    # resample the full-size painting: out(p) = painting(p + field(p)), bilinear
    SW, SH = src.size
    sx, sy = SW / FW, SH / FH
    FXb = np.asarray(Image.fromarray(fx).resize((SW, SH), Image.BILINEAR)) * sx
    FYb = np.asarray(Image.fromarray(fy).resize((SW, SH), Image.BILINEAR)) * sy
    a = np.asarray(src).astype(np.float32)
    yy, xx = np.mgrid[0:SH, 0:SW].astype(np.float32)
    px = np.clip(xx + FXb, 0, SW - 1.001)
    py = np.clip(yy + FYb, 0, SH - 1.001)
    x0, y0 = np.floor(px).astype(int), np.floor(py).astype(int)
    tx, ty = (px - x0)[..., None], (py - y0)[..., None]
    out = (a[y0, x0] * (1 - tx) * (1 - ty) + a[y0, x0 + 1] * tx * (1 - ty) + a[y0 + 1, x0] * (1 - tx) * ty
           + a[y0 + 1, x0 + 1] * tx * ty)
    res = Image.fromarray(out.clip(0, 255).astype(np.uint8))
    o2 = offsets(np.asarray(res.resize((FW, FH), Image.LANCZOS)), true_land)
    print("after the pass (search %d, smooth %d): median %.1f, 90th %.1f (fine px)" % (search, smooth,
        float(np.median(np.hypot(o2[:, 2], o2[:, 3]))), float(np.percentile(np.hypot(o2[:, 2], o2[:, 3]), 90))))
    return res


def finish(res, repo, d):
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    true_land = (fw & 3) == 0
    FH, FW = true_land.shape
    res.save(os.path.join(d, "far_paper_3x_reg.png"))
    res.save(os.path.join(repo, "assets/map/map_far_paper.jpg"), quality=92, optimize=True)
    # the check: the true coast in red over the result, three crops side by side
    small = np.asarray(res.resize((FW, FH), Image.LANCZOS)).copy()
    small[coast_edge(true_land)] = (230, 20, 20)
    s = Image.fromarray(small)
    crops = [s.crop((170, 400, 870, 850)), s.crop((1300, 300, 2000, 750)), s.crop((700, 900, 1400, 1350))]
    sheet = Image.new("RGB", (2100, 450))
    for i, c in enumerate(crops):
        sheet.paste(c, (i * 700, 0))
    sheet.save(os.path.join(d, "register_check.jpg"), quality=88)


if __name__ == "__main__":
    main(sys.argv[1], "--check" in sys.argv)
