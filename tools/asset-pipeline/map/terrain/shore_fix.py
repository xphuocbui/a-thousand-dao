"""Fill painted shore bands inside the true coast (user, 2026-11-23: "the gulf near Bình Thủy Môn is now really out of
place"). The 3x paper pass sometimes drew its own shallows or beach a little inland of the data's coast; the game then
draws its water outside the true coast and the band reads as water on land. In each tile, pixels inside the true coast
and within BAND tiles of it that look like the tile's own sea (or are blue water colour) are refilled outward from the
land art next to them. Tiles are backed up once to shore_before/ and always fixed from that copy.

usage: python -I shore_fix.py <repo> scan | apply [cx,cy ...]
"""
import json
import os
import shutil
import sys

import numpy as np
from PIL import Image, ImageFilter

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import island_fix as IF  # noqa: E402
from water_lock import field  # noqa: E402

TILES = "assets/map/paper_hi"
BAND = 1.5          # tiles inland of the coast that are checked
SEA_DIST = 40       # colour distance to the tile's sea that counts as sea-looking


def _box(x, r):
    c = np.pad(x, r + 1, mode="edge").cumsum(0).cumsum(1)
    k = 2 * r + 1
    return (c[k:, k:] - c[:-k, k:] - c[k:, :-k] + c[:-k, :-k])[:x.shape[0], :x.shape[1]] / (k * k)


def load(repo):
    man = json.load(open(os.path.join(repo, TILES, "manifest.json")))
    coast = np.fromfile(os.path.join(repo, "assets/map/terrain/coast.bin"), np.float32).reshape(1440, 2160)
    return man, coast


def band_mask(repo, man, coast, cx, cy, src):
    """The tile's shore band (with the painted ink line inland of it) as a mask over the tile image, or None."""
    _, share, bad = tile_fix(repo, man, coast, cx, cy, src, measure_only=True, want_mask=True)
    return bad


def tile_fix(repo, man, coast, cx, cy, src, measure_only=False, want_mask=False):
    pad, chunk, px = man["pad"], man["chunk_tiles"], man["px_per_tile"]
    t = np.asarray(Image.open(src).convert("RGB"), np.float32)
    h, w = t.shape[:2]
    sd = field((cx * chunk - pad / px, cy * chunk - pad / px), (w, h), float(px), coast, 0.0)   # tiles, + water
    land = sd < -0.05
    band = land & (sd > -BAND)
    sea = sd > 0.6
    if band.sum() == 0 or sea.sum() < 500:
        return (None, 0.0, None) if want_mask else (None, 0.0)
    sea_c = np.median(t[sea], 0)
    inland = land & (sd < -BAND - 0.5)
    int_c = np.median(t[inland], 0) if inland.sum() > 500 else np.median(t[land], 0)
    ds, di = np.linalg.norm(t - sea_c, axis=-1), np.linalg.norm(t - int_c, axis=-1)
    cand = band & (IF._watery(t) | ((ds < SEA_DIST) & (ds < di)))
    # areas where most pixels look like sea (a painted shore band is speckled, so judge by density), joined to the
    # coast line; thin glacier hatching and tundra specks stay below the density
    cand = _box(cand.astype(np.float32), 6) > 0.45
    bad = cand & band & (sd > -0.25)
    for _ in range(200):
        nxt = IF._grow(bad, 2) & cand & band
        if (nxt == bad).all():
            break
        bad = nxt
    share = bad.sum() / max(1, band.sum())
    if want_mask:
        return None, share, (IF._grow(bad, 8) & land if bad.sum() >= 200 else None)
    if bad.sum() < 200 or measure_only:
        return None, share
    bad = IF._grow(bad, 8) & land                     # the band's soft edge and the painted ink line inland of it
    # copy land art from straight inland: step against the coast's outward normal until clear of the band
    sm = _box(sd, 8)
    gy, gx = np.gradient(sm)
    nrm = np.sqrt(gx * gx + gy * gy) + 1e-6
    nx, ny = gx / nrm, gy / nrm                       # points to the water (sd is + over water)
    ys, xs = np.nonzero(bad)
    src_y = np.full(ys.shape, -1)
    src_x = np.full(xs.shape, -1)
    todo = np.ones(ys.shape, bool)
    for step in np.arange(0.6, 4.01, 0.2) * px:
        qy = np.round(ys - ny[ys, xs] * step).astype(int)
        qx = np.round(xs - nx[ys, xs] * step).astype(int)
        ok = todo & (qy >= 0) & (qy < h) & (qx >= 0) & (qx < w)
        ok[ok] = land[qy[ok], qx[ok]] & ~bad[qy[ok], qx[ok]]
        src_y[ok], src_x[ok] = qy[ok], qx[ok]
        todo &= ~ok
    out = t.copy()
    got = src_y >= 0
    out[ys[got], xs[got]] = t[src_y[got], src_x[got]]
    # feather the patch's inland edge over a few px
    m = np.asarray(Image.fromarray((bad * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(3)), np.float32)[..., None] / 255.0
    m = np.where(bad[..., None], np.maximum(m, 0.6), m)
    out = t * (1 - m) + out * m
    out[~land] = t[~land]
    return out, share


def main(repo, cmd, only):
    man, coast = load(repo)
    back = os.path.join(repo, "design/map/continent-11/art/paper/shore_before")
    os.makedirs(back, exist_ok=True)
    rows = []
    for cy in range(man["rows"]):
        for cx in range(man["cols"]):
            if only and (cx, cy) not in only:
                continue
            path = os.path.join(repo, TILES, "near_%d_%d.jpg" % (cx, cy))
            bp = os.path.join(back, os.path.basename(path))
            src = bp if os.path.exists(bp) else path
            out, share = tile_fix(repo, man, coast, cx, cy, src, cmd == "scan")
            rows.append((share, cx, cy))
            if cmd == "apply" and out is not None:
                if not os.path.exists(bp):
                    shutil.copy(path, bp)
                Image.fromarray(out.clip(0, 255).astype(np.uint8)).save(path, quality=90, subsampling=0)
    rows.sort(reverse=True)
    for s, cx, cy in rows[:25]:
        print("near_%d_%d  %.1f %% of the coastal band looks like sea" % (cx, cy, 100 * s))
    print("tiles with > 5 %%: %d of %d" % (sum(1 for r in rows if r[0] > 0.05), len(rows)))


if __name__ == "__main__":
    only = [tuple(int(v) for v in a.split(",")) for a in sys.argv[3:]]
    main(sys.argv[1], sys.argv[2], only)
