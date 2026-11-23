"""Calm the open sea of the stitched near layer (paint_tiles.py): neighbouring crops caught different sun glare on open
water, which shows as patches. Deep water away from the coast is replaced by a sea built from the painting's own sea
colours by depth (the guide's elevation), with a faint swell; the painted shore band (the first few tiles from land)
is kept and cross-faded into it.

usage: python -I tools/asset-pipeline/map/sea_fix.py <repo>    rewrites near_12px.png -> near_12px_sea.png and the
                                                              game copy assets/map/map_near_relief.jpg
"""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

Image.MAX_IMAGE_PIXELS = None
KEEP_TILES, FADE_TILES, PX = 3.0, 4.0, 12


def main():
    repo = sys.argv[1]
    d = os.path.join(repo, "design/map/continent-11/art/near")
    near = np.asarray(Image.open(os.path.join(d, "near_12px.png")).convert("RGB")).astype(np.float32)
    H, W = near.shape[:2]
    base = os.path.join(repo, "design/map/continent-11/base")
    water = np.asarray(Image.open(os.path.join(base, "fine_water.png")))
    elev = np.asarray(Image.open(os.path.join(base, "fine_elevation.png"))).astype(np.float32) - 10000.0
    sea4 = (water & 1) > 0
    # distance from land in tiles (on the 4 px fine grid, then scaled up)
    land = Image.fromarray(((~sea4) * 255).astype(np.uint8))
    dist = np.zeros(sea4.shape, np.float32)
    grown = land
    for step in range(1, int((KEEP_TILES + FADE_TILES) * 4) + 2):
        grown = grown.filter(ImageFilter.MaxFilter(3))
        g = np.asarray(grown) > 0
        dist[(dist == 0) & g & sea4] = step / 4.0
    dist[sea4 & (dist == 0)] = KEEP_TILES + FADE_TILES + 1.0
    dist[~sea4] = 0.0
    up = lambda a, mode=Image.BILINEAR: np.asarray(Image.fromarray(a).resize((W, H), mode)).astype(np.float32)
    dist_u = up(dist.astype(np.float32), Image.BILINEAR)
    depth = np.clip(-elev / 3000.0, 0.0, 1.0)
    depth_u = up(depth.astype(np.float32), Image.BILINEAR)
    sea_u = up((sea4 * 255).astype(np.uint8), Image.NEAREST) > 127
    # the painting's own sea colour by depth band (median per band, from water well away from the coast)
    bands = np.linspace(0, 1, 11)
    cols = []
    open_water = sea_u & (dist_u > KEEP_TILES)
    for i in range(10):
        m = open_water & (depth_u >= bands[i]) & (depth_u < bands[i + 1] + (1e-6 if i == 9 else 0))
        cols.append(np.median(near[m], axis=0) if m.sum() > 500 else None)
    known = [i for i, c in enumerate(cols) if c is not None]
    for i in range(10):
        if cols[i] is None:
            j = min(known, key=lambda k: abs(k - i))
            cols[i] = cols[j]
    cols = np.array(cols, np.float32)
    idx = np.clip(depth_u * 9.999, 0, 9.999)
    lo = np.floor(idx).astype(int)
    hi = np.minimum(lo + 1, 9)
    t = (idx - lo)[..., None]
    calm = cols[lo] * (1 - t) + cols[hi] * t
    # a faint, broad swell so the water is not flat
    rng = np.random.default_rng(11)
    swell = Image.fromarray((rng.random((H // 24, W // 24)) * 255).astype(np.uint8)).resize((W, H), Image.BICUBIC)
    swell = (np.asarray(swell).astype(np.float32) / 255.0 - 0.5) * 10.0
    calm = calm + swell[..., None]
    w = np.clip((dist_u - KEEP_TILES) / FADE_TILES, 0.0, 1.0)[..., None] * sea_u[..., None]
    out = near * (1 - w) + calm * w
    img = Image.fromarray(np.clip(out, 0, 255).astype(np.uint8))
    img.save(os.path.join(d, "near_12px_sea.png"), optimize=True)
    os.makedirs(os.path.join(repo, "assets/map"), exist_ok=True)
    img.save(os.path.join(repo, "assets/map/map_near_relief.jpg"), quality=90, optimize=True)
    print("sea calmed; open-water share %.2f" % float(w.mean()))


if __name__ == "__main__":
    main()
