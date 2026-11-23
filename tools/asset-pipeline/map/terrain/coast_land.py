"""Repaint the coastal stretches where the 3x paper pass drew its own shore band inland of the true coast (user,
2026-11-23: "the gulf near Bình Thủy Môn is now really out of place"; "use the second method"). Same method as the
islands (island_fix.py land-*): a land-only picture per stretch, painted from the land types spread over the whole frame
(no sea, no coastline), plugged in only over the band (grown half a tile, feathered) and colour-matched to the art
around it. The game draws the water, shore and ink line on the true coast.

The bands are found as shore_fix.py finds them (sea-looking paint inside the true coast, joined to the coast line).

usage: python -I coast_land.py <repo> plan | paint | apply
"""
import json
import os
import shutil
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageFilter

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import island_fix as IF  # noqa: E402
import shore_fix as SF  # noqa: E402
import hybrid_full as HF  # noqa: E402

TILES = "assets/map/paper_hi"
CROP = (24, 13.5)      # tiles, 16:9
MIN_PX = 1500           # band pixels (at 48 px per tile) for a spot to be repainted
PX = 48
MIN_CELLS = 80          # fine cells (16 per tile): a spot smaller than 5 square tiles is left alone


def root(repo):
    return os.path.join(repo, "design/map/continent-11/art/paper/coast")


def band_map(repo):
    """The shore bands over the whole map in fine cells (4 per tile)."""
    man, coast = SF.load(repo)
    pad, chunk = man["pad"], man["chunk_tiles"]
    out = np.zeros((1440, 2160), bool)
    for cy in range(man["rows"]):
        for cx in range(man["cols"]):
            t = os.path.join(repo, TILES, "near_%d_%d.jpg" % (cx, cy))
            bad = SF.band_mask(repo, man, coast, cx, cy, t)
            if bad is None or bad.sum() < MIN_PX:
                continue
            inner = bad[pad:bad.shape[0] - pad, pad:bad.shape[1] - pad]
            h, w = inner.shape[0] // 12, inner.shape[1] // 12
            cells = inner[:h * 12, :w * 12].reshape(h, 12, w, 12).any(axis=(1, 3))
            out[cy * chunk * 4:cy * chunk * 4 + h, cx * chunk * 4:cx * chunk * 4 + w] |= cells
    return out


def spots(bands):
    """Band components (cells joined within 3 tiles) as tile boxes."""
    grown = IF._grow(bands, 12)
    H, W = bands.shape
    lab = np.zeros(bands.shape, np.int32)
    boxes, n = [], 0
    for y, x in zip(*np.nonzero(bands)):
        if lab[y, x]:
            continue
        n += 1
        q, ys, xs = deque([(y, x)]), [], []
        lab[y, x] = n
        while q:
            cy, cx = q.popleft()
            if bands[cy, cx]:
                ys.append(cy)
                xs.append(cx)
            for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                yy, xx = cy + dy, cx + dx
                if 0 <= yy < H and 0 <= xx < W and grown[yy, xx] and not lab[yy, xx]:
                    lab[yy, xx] = n
                    q.append((yy, xx))
        boxes.append((min(xs) / 4, min(ys) / 4, (max(xs) + 1) / 4, (max(ys) + 1) / 4, len(ys)))
    return boxes


def plan(repo):
    d = root(repo)
    os.makedirs(d, exist_ok=True)
    bf = os.path.join(d, "bands.npy")
    if os.path.exists(bf):
        bands = np.load(bf)
    else:
        bands = band_map(repo)
        np.save(bf, bands)
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    landcells = ((fw & 3) == 0).astype(np.uint8)
    IF._land_guide(repo, landcells, 1, 0, 0, 16, 16)      # loads the biome data once
    crops = []
    for x0, y0, x1, y1, cells in spots(bands):
        if cells < MIN_CELLS:   # specks smaller than this do not show
            continue
        # cover the box with 24 x 13.5 tile crops (a margin of 2 tiles), overlapping evenly
        bx0, by0, bx1, by1 = x0 - 2, y0 - 2, x1 + 2, y1 + 2
        nx = max(1, int(np.ceil((bx1 - bx0) / (CROP[0] - 4))))
        ny = max(1, int(np.ceil((by1 - by0) / (CROP[1] - 3))))
        for j in range(ny):
            for i in range(nx):
                cx = bx0 + (bx1 - bx0) * (i + 0.5) / nx
                cy = by0 + (by1 - by0) * (j + 0.5) / ny
                crops.append((round(cx - CROP[0] / 2, 2), round(cy - CROP[1] / 2, 2)))
    out = []
    for k, (tx0, ty0) in enumerate(crops):
        px0, py0 = int(round(tx0 * 16)), int(round(ty0 * 16))
        pw, ph = int(CROP[0] * 16), int(CROP[1] * 16)
        guide = IF._land_guide(repo, landcells, 1, px0, py0, pw, ph)
        Image.fromarray(guide).resize((1536, 864), Image.BICUBIC).save(os.path.join(d, "guide_%d_0.png" % k))
        b = IF._BIOME["b"]
        fy0, fx0 = max(0, py0 // 4), max(0, px0 // 4)
        sub_b = b[fy0:(py0 + ph) // 4, fx0:(px0 + pw) // 4]
        sub_l = landcells[fy0:(py0 + ph) // 4, fx0:(px0 + pw) // 4] > 0
        cnt = np.bincount(sub_b[sub_l], minlength=19)
        parts = ["%s %d %%" % (HF.LOOK[int(i)], round(100 * cnt[i] / cnt.sum()))
                 for i in np.argsort(-cnt) if cnt.sum() and cnt[i] / cnt.sum() >= 0.05 and int(i) in HF.LOOK]
        open(os.path.join(d, "prompt_%d_0.md" % k), "w", encoding="utf-8").write(
            IF.LAND_PROMPT + "\n\nThis patch's land, from the game data (draw these and only these, in these shares, where the "
            "plan's colours put them): " + ", ".join(parts) + ".\n")
        out.append({"n": k, "px": [px0, py0, pw, ph], "size": [1536, 864]})
    json.dump({"islands": out, "px_per_tile": 16}, open(os.path.join(d, "plan.json"), "w"))
    print("band spots", len(spots(bands)), "pieces", len(out))
    for it in out:
        print("  piece %d at tiles %.1f,%.1f" % (it["n"], it["px"][0] / 16, it["px"][1] / 16))


def paint(repo):
    d = root(repo)
    old = IF.land_root
    IF.land_root = lambda r: d
    try:
        IF.land_paint(repo)
    finally:
        IF.land_root = old


def apply(repo):
    """Each piece over the band only (grown half a tile, feathered), colour-matched to the land art around the band."""
    d = root(repo)
    plan_ = json.load(open(os.path.join(d, "plan.json")))
    bands = np.load(os.path.join(d, "bands.npy"))
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    land = ((fw & 3) == 0).astype(np.uint8) * 255
    water = (fw & 3) != 0
    wl, winfo = _water_bodies(water)
    small = np.isin(wl, [k for k, n in winfo.items() if n < 20000]) | ((fw & 3) == 2)
    lake = IF._grow(small, 10)                                 # lake shores keep their own art (sea coasts only)
    bands = bands & ~lake
    zone = IF._grow(bands, 4).astype(np.uint8) * 255          # a tile past the band, over the old inner ink line
    man = json.load(open(os.path.join(repo, TILES, "manifest.json")))
    pad, chunk = man["pad"], man["chunk_tiles"]
    back = os.path.join(d, "tiles_before")
    os.makedirs(back, exist_ok=True)
    touched = {}

    def cells_to_px(arr, gx0, gy0, w, h):
        cx0, cy0 = gx0 // 12, gy0 // 12
        cx1, cy1 = -(-(gx0 + w) // 12), -(-(gy0 + h) // 12)
        cell = np.zeros((cy1 - cy0, cx1 - cx0), np.uint8)
        sy0, sx0, sy1, sx1 = max(0, cy0), max(0, cx0), min(1440, cy1), min(2160, cx1)
        cell[sy0 - cy0:sy1 - cy0, sx0 - cx0:sx1 - cx0] = arr[sy0:sy1, sx0:sx1]
        big = np.asarray(Image.fromarray(cell).resize(((cx1 - cx0) * 12, (cy1 - cy0) * 12), Image.BILINEAR), np.float32) / 255.0
        ox, oy = gx0 - cx0 * 12, gy0 - cy0 * 12
        return big[oy:oy + h, ox:ox + w]

    def tile(key):
        if key not in touched:
            path = os.path.join(repo, TILES, "near_%d_%d.jpg" % key)
            bp = os.path.join(back, os.path.basename(path))
            if not os.path.exists(bp):
                shutil.copy(path, back)
            touched[key] = np.asarray(Image.open(bp).convert("RGB"), np.float32)
        return touched[key]

    for it in plan_["islands"]:
        f = os.path.join(d, "paint_%d_0.png" % it["n"])
        if not os.path.exists(f):
            print("missing piece", it["n"])
            continue
        px0, py0, pw, ph = it["px"]
        gx0, gy0, w, h = px0 * 3, py0 * 3, pw * 3, ph * 3
        pa = np.asarray(Image.open(f).convert("RGB").resize((w, h), Image.LANCZOS), np.float32)
        z = cells_to_px(zone, gx0, gy0, w, h) > 0.5
        lm = cells_to_px(land, gx0, gy0, w, h) > 0.5
        # what is there now, for the colour match (land outside the band)
        cur = np.zeros_like(pa)
        for ty in range(max(0, gy0) // (chunk * PX), (gy0 + h - 1) // (chunk * PX) + 1):
            for tx in range(max(0, gx0) // (chunk * PX), (gx0 + w - 1) // (chunk * PX) + 1):
                if not os.path.exists(os.path.join(repo, TILES, "near_%d_%d.jpg" % (tx, ty))):
                    continue
                t = tile((tx, ty))
                ox, oy = gx0 - tx * chunk * PX + pad, gy0 - ty * chunk * PX + pad
                ax0, ay0, ax1, ay1 = max(0, ox), max(0, oy), min(t.shape[1], ox + w), min(t.shape[0], oy + h)
                if ax0 < ax1 and ay0 < ay1:
                    cur[ay0 - oy:ay1 - oy, ax0 - ox:ax1 - ox] = t[ay0:ay1, ax0:ax1]
        ref = lm & ~IF._grow(z, PX)
        if ref.sum() > 2000:
            pa = _match(pa, cur, ref, z & lm)
        m = Image.fromarray(((z & lm) * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(10))
        m = np.asarray(m, np.float32)[..., None] / 255.0
        m = np.where((z & lm)[..., None], np.maximum(m, 0.85), m)
        # fade at the piece's own edges so neighbouring pieces and the old art meet softly
        e = np.minimum.outer(np.minimum(np.arange(h), np.arange(h)[::-1]), np.minimum(np.arange(w), np.arange(w)[::-1]))
        m = m * np.clip(e / PX, 0, 1)[..., None]
        for ty in range(max(0, gy0) // (chunk * PX), (gy0 + h - 1) // (chunk * PX) + 1):
            for tx in range(max(0, gx0) // (chunk * PX), (gx0 + w - 1) // (chunk * PX) + 1):
                if not os.path.exists(os.path.join(repo, TILES, "near_%d_%d.jpg" % (tx, ty))):
                    continue
                t = tile((tx, ty))
                ox, oy = gx0 - tx * chunk * PX + pad, gy0 - ty * chunk * PX + pad
                ax0, ay0, ax1, ay1 = max(0, ox), max(0, oy), min(t.shape[1], ox + w), min(t.shape[0], oy + h)
                if ax0 >= ax1 or ay0 >= ay1:
                    continue
                sl = (slice(ay0 - oy, ay1 - oy), slice(ax0 - ox, ax1 - ox))
                t[ay0:ay1, ax0:ax1] = t[ay0:ay1, ax0:ax1] * (1 - m[sl]) + pa[sl] * m[sl]
    for (tx, ty), t in touched.items():
        Image.fromarray(t.clip(0, 255).astype(np.uint8)).save(os.path.join(repo, TILES, "near_%d_%d.jpg" % (tx, ty)), quality=90, subsampling=0)
    print("pieces plugged", len(plan_["islands"]), "tiles updated", len(touched))


def _water_bodies(water):
    """Water components (4-connected fine cells): label image and cell count per label."""
    H, W = water.shape
    lab = np.zeros(water.shape, np.int32)
    info, n = {}, 0
    for y, x in zip(*np.nonzero(water)):
        if lab[y, x]:
            continue
        n += 1
        q, c = deque([(y, x)]), 0
        lab[y, x] = n
        while q:
            cy, cx = q.popleft()
            c += 1
            for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                yy, xx = cy + dy, cx + dx
                if 0 <= yy < H and 0 <= xx < W and water[yy, xx] and not lab[yy, xx]:
                    lab[yy, xx] = n
                    q.append((yy, xx))
        info[n] = c
    return lab, info


def _match(pa, cur, ref, where):
    """Per-channel mean and spread of the painting (over the band) moved 60 % toward the old art's (around it)."""
    out = pa.copy()
    for c in range(3):
        a, b = pa[..., c][where], cur[..., c][ref]
        if a.size < 100:
            continue
        s = (b.std() + 1e-3) / (a.std() + 1e-3)
        s = 1 + 0.6 * (s - 1)
        out[..., c] = (pa[..., c] - a.mean()) * s + a.mean() + 0.6 * (b.mean() - a.mean())
    return out


if __name__ == "__main__":
    repo, cmd = sys.argv[1], sys.argv[2]
    {"plan": plan, "paint": paint, "apply": apply}[cmd](repo)
