"""Repaint the land around one lake or one river stretch where the 3x paper pass drew its own water a little off the
game's (user, 2026-11-23: "the lake next to Lễ Tuyền Phái has a little bit of land/lake coastal mismatch"; "the river
to the right of Đào Thanh Thành ... has a little bit of a mismatch with the rendered river"). Same method as the islands
and coasts: a land-only picture (island_fix.LAND_PROMPT, the land types spread over the frame), put in over the land
within RING tiles of the true lake shore or river, feathered and colour-matched; the game draws the water on top.

usage: python -I spot_fix.py <repo> plan | paint | apply
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
import coast_land as CL  # noqa: E402
import hybrid_full as HF  # noqa: E402

TILES = "assets/map/paper_hi"
PX = 48
RING = 1.0   # tiles
# name: (kind, centre tile x, y, shape)
SPOTS = {"le_tuyen_lake": ("lake", 408, 203, "tall"), "dao_thanh_river": ("river", 276, 127, "wide")}
SIZE = {"tall": ((13.5, 24), (864, 1536)), "wide": ((24, 13.5), (1536, 864))}


def root(repo):
    return os.path.join(repo, "design/map/continent-11/art/paper/spots")


def _fine(repo):
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    land = (fw & 3) == 0
    river = np.fromfile(os.path.join(repo, "assets/map/terrain/river.bin"), np.uint8).reshape(2880, 4320)
    river = river.reshape(1440, 2, 2160, 2).max(axis=(1, 3)) > 60
    return land, river


def zone(repo, kind, box):
    """Fine cells of land within RING tiles of the lake (the water body inside the box) or the river cells in the box."""
    land, river = _fine(repo)
    x0, y0, x1, y1 = [int(round(v * 4)) for v in box]
    feat = np.zeros_like(land)
    if kind == "lake":
        feat[max(0, y0):y1, max(0, x0):x1] = ~land[max(0, y0):y1, max(0, x0):x1]
    else:
        feat[max(0, y0):y1, max(0, x0):x1] = river[max(0, y0):y1, max(0, x0):x1]
    ring = RING if kind == "lake" else 1.75     # the painted river channel strays up to ~1.5 tiles off the game's
    return IF._grow(feat, int(ring * 4)) & land


def plan(repo):
    d = root(repo)
    os.makedirs(d, exist_ok=True)
    land, _ = _fine(repo)
    landcells = land.astype(np.uint8)
    IF._land_guide(repo, landcells, 1, 0, 0, 16, 16)
    out = []
    for k, (name, (kind, cx, cy, shape)) in enumerate(SPOTS.items()):
        (tw, th), (sw, sh) = SIZE[shape]
        px0, py0 = int(round((cx - tw / 2) * 16)), int(round((cy - th / 2) * 16))
        pw, ph = int(tw * 16), int(th * 16)
        guide = IF._land_guide(repo, landcells, 1, px0, py0, pw, ph)
        Image.fromarray(guide).resize((sw, sh), Image.BICUBIC).save(os.path.join(d, "guide_%d_0.png" % k))
        b = IF._BIOME["b"]
        sub_b = b[py0 // 4:(py0 + ph) // 4, px0 // 4:(px0 + pw) // 4]
        sub_l = land[py0 // 4:(py0 + ph) // 4, px0 // 4:(px0 + pw) // 4]
        cnt = np.bincount(sub_b[sub_l], minlength=19)
        parts = ["%s %d %%" % (HF.LOOK[int(i)], round(100 * cnt[i] / cnt.sum()))
                 for i in np.argsort(-cnt) if cnt[i] / cnt.sum() >= 0.05 and int(i) in HF.LOOK]
        open(os.path.join(d, "prompt_%d_0.md" % k), "w", encoding="utf-8").write(
            IF.LAND_PROMPT + "\n\nThis patch's land, from the game data (draw these and only these, in these shares, where the "
            "plan's colours put them): " + ", ".join(parts) + ".\n")
        out.append({"n": k, "name": name, "kind": kind, "px": [px0, py0, pw, ph], "size": [sw, sh],
                    "box": [cx - tw / 2, cy - th / 2, cx + tw / 2, cy + th / 2]})
    json.dump({"islands": out, "px_per_tile": 16}, open(os.path.join(d, "plan.json"), "w"))
    print("spots", len(out))


def paint(repo):
    old = IF.land_root
    IF.land_root = lambda r: root(repo)
    try:
        IF.land_paint(repo)
    finally:
        IF.land_root = old


def apply(repo):
    d = root(repo)
    plan_ = json.load(open(os.path.join(d, "plan.json")))
    man = json.load(open(os.path.join(repo, TILES, "manifest.json")))
    pad, chunk = man["pad"], man["chunk_tiles"]
    back = os.path.join(d, "tiles_before")
    os.makedirs(back, exist_ok=True)
    touched = {}

    def tile(key):
        if key not in touched:
            path = os.path.join(repo, TILES, "near_%d_%d.jpg" % key)
            bp = os.path.join(back, os.path.basename(path))
            if not os.path.exists(bp):
                shutil.copy(path, back)
            touched[key] = np.asarray(Image.open(bp).convert("RGB"), np.float32)
        return touched[key]

    for it in plan_["islands"]:
        px0, py0, pw, ph = it["px"]
        gx0, gy0, w, h = px0 * 3, py0 * 3, pw * 3, ph * 3
        pa = np.asarray(Image.open(os.path.join(d, "paint_%d_0.png" % it["n"])).convert("RGB").resize((w, h), Image.LANCZOS), np.float32)
        z = zone(repo, it["kind"], it["box"])
        zc = z[gy0 // 12:(gy0 + h) // 12, gx0 // 12:(gx0 + w) // 12].astype(np.uint8) * 255
        zp = np.asarray(Image.fromarray(zc).resize((w, h), Image.BILINEAR)) > 127
        cur = np.zeros_like(pa)
        keys = [(tx, ty) for ty in range(gy0 // (chunk * PX), (gy0 + h - 1) // (chunk * PX) + 1)
                for tx in range(gx0 // (chunk * PX), (gx0 + w - 1) // (chunk * PX) + 1)]
        for key in keys:
            t = tile(key)
            ox, oy = gx0 - key[0] * chunk * PX + pad, gy0 - key[1] * chunk * PX + pad
            ax0, ay0, ax1, ay1 = max(0, ox), max(0, oy), min(t.shape[1], ox + w), min(t.shape[0], oy + h)
            if ax0 < ax1 and ay0 < ay1:
                cur[ay0 - oy:ay1 - oy, ax0 - ox:ax1 - ox] = t[ay0:ay1, ax0:ax1]
        land, _ = _fine(repo)
        lc = land[gy0 // 12:(gy0 + h) // 12, gx0 // 12:(gx0 + w) // 12].astype(np.uint8) * 255
        lp = np.asarray(Image.fromarray(lc).resize((w, h), Image.BILINEAR)) > 127
        ref = lp & ~IF._grow(zp, PX)
        pa = CL._match(pa, cur, ref, zp)
        # no redder than the art around it (the model painted the dry steppe here rust-red in every attempt)
        rg = pa[..., 0] - pa[..., 1]
        cap = np.percentile((cur[..., 0] - cur[..., 1])[ref], 97)
        over = np.maximum(0.0, rg - cap)
        pa[..., 0] -= over * 0.6
        pa[..., 1] += over * 0.4
        m = Image.fromarray((zp * 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(10))
        m = np.asarray(m, np.float32)[..., None] / 255.0
        m = np.where(zp[..., None], np.maximum(m, 0.85), m)
        e = np.minimum.outer(np.minimum(np.arange(h), np.arange(h)[::-1]), np.minimum(np.arange(w), np.arange(w)[::-1]))
        m = m * np.clip(e / PX, 0, 1)[..., None]
        for key in keys:
            t = tile(key)
            ox, oy = gx0 - key[0] * chunk * PX + pad, gy0 - key[1] * chunk * PX + pad
            ax0, ay0, ax1, ay1 = max(0, ox), max(0, oy), min(t.shape[1], ox + w), min(t.shape[0], oy + h)
            if ax0 >= ax1 or ay0 >= ay1:
                continue
            sl = (slice(ay0 - oy, ay1 - oy), slice(ax0 - ox, ax1 - ox))
            t[ay0:ay1, ax0:ax1] = t[ay0:ay1, ax0:ax1] * (1 - m[sl]) + pa[sl] * m[sl]
    for (tx, ty), t in touched.items():
        Image.fromarray(t.clip(0, 255).astype(np.uint8)).save(os.path.join(repo, TILES, "near_%d_%d.jpg" % (tx, ty)), quality=90, subsampling=0)
    print("spots plugged", len(plan_["islands"]), "tiles updated", len(touched))


if __name__ == "__main__":
    repo, cmd = sys.argv[1], sys.argv[2]
    {"plan": plan, "paint": paint, "apply": apply}[cmd](repo)
