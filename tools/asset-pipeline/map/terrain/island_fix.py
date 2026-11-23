"""Repaint the small islands of the paper map (user, 2026-11-23: "the small islands in the west, south east, and north
east ... have a border, but the art within the border is wrong"). In the 3x pass the model often painted sea where a
small island is, and the coast lock then filled the island with a faded copy of the guide. Here each island (or a
group close together) is painted on its own, centred in a 32 x 18 tile crop at the final 48 px per tile, from the flat
data guide in the paper style (paper_hybrid.py), and the result replaces the tiles' pixels inside the island's true
coast. apply patches each island once, from the most central painting it sits wholly inside, fits the painted island
onto the true coast and fills leftover slivers from the island's own art (user, 2026-11-23: "some island still don't
match the border overlay, and some of them looks weird, like abruptly cut"). Tiles are always patched from the
originals kept in tiles_before/.

usage: python -I island_fix.py <repo> plan | paint | apply
"""
import json
import os
import shutil
import subprocess
import sys
from collections import deque

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import paper_hybrid as PH  # noqa: E402
import hybrid_full as HF  # noqa: E402

PX = 48
CROP = (32, 18)            # tiles
MAX_CELLS = 12000          # fine cells (4 per tile side): islands smaller than ~750 tiles
TILES = "assets/map/paper_hi"


def root(repo):
    return os.path.join(repo, "design/map/continent-11/art/paper/islands")


def islands(repo):
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    land = (fw & 3) == 0
    H, W = land.shape
    lab = np.zeros(land.shape, np.int32)
    out, n = [], 0
    for y, x in zip(*np.nonzero(land)):
        if lab[y, x]:
            continue
        n += 1
        q, pts = deque([(y, x)]), []
        lab[y, x] = n
        while q:
            cy, cx = q.popleft()
            pts.append((cy, cx))
            for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                yy, xx = cy + dy, cx + dx
                if 0 <= yy < H and 0 <= xx < W and land[yy, xx] and not lab[yy, xx]:
                    lab[yy, xx] = n
                    q.append((yy, xx))
        if 4 <= len(pts) < MAX_CELLS:
            a = np.array(pts)
            out.append({"cells": len(pts), "x0": a[:, 1].min() / 4, "y0": a[:, 0].min() / 4,
                        "x1": (a[:, 1].max() + 1) / 4, "y1": (a[:, 0].max() + 1) / 4})
    return out


def plan(repo):
    """Greedy crops: each uncovered island gets a crop centred on it; islands wholly inside it are covered too."""
    d = root(repo)
    os.makedirs(d, exist_ok=True)
    isl = sorted(islands(repo), key=lambda i: -i["cells"])
    crops, done = [], set()
    for k, i in enumerate(isl):
        if k in done:
            continue
        cx, cy = (i["x0"] + i["x1"]) / 2, (i["y0"] + i["y1"]) / 2
        x0 = int(round(min(max(cx - CROP[0] / 2, 0), 540 - CROP[0])))
        y0 = int(round(min(max(cy - CROP[1] / 2, 0), 360 - CROP[1])))
        for j, o in enumerate(isl):
            if o["x0"] >= x0 + 0.5 and o["x1"] <= x0 + CROP[0] - 0.5 and o["y0"] >= y0 + 0.5 and o["y1"] <= y0 + CROP[1] - 0.5:
                done.add(j)
        done.add(k)
        crops.append((x0, y0))
    g = Image.open(os.path.join(repo, "design/map/continent-11/art/paper/guide_16px_flat.png")).convert("RGB")
    for x0, y0 in crops:
        g.crop((x0 * 16, y0 * 16, (x0 + CROP[0]) * 16, (y0 + CROP[1]) * 16)).resize((1536, 864), Image.BICUBIC).save(
            os.path.join(d, "guide_%d_%d.png" % (x0, y0)))
        old = HF.PIECE
        HF.PIECE = CROP
        try:
            txt = HF.contents(repo, x0, y0)
        finally:
            HF.PIECE = old
        open(os.path.join(d, "prompt_%d_%d.md" % (x0, y0)), "w", encoding="utf-8").write(
            PH.PROMPT + "\n\nThis piece shows small islands in open sea. Draw every island exactly in its outline and place, "
            "filled edge to edge with its land (no empty or faded island, no sea inside an island's coast).\n" + txt)
    json.dump({"crops": crops}, open(os.path.join(d, "plan.json"), "w"))
    print("islands", len(isl), "crops", len(crops))


def _watery(a):
    """Sea-coloured pixels of a painting (pale blue-grey wash), as recheck_pass2.classes calls water."""
    return (a[..., 2] > a[..., 0] + 12) & (a[..., 2] > a[..., 1] - 5)


def _enclosed(mask):
    """mask plus every hole in it (pixels not reachable from the image border through ~mask)."""
    b = Image.new("L", (mask.shape[1] + 2, mask.shape[0] + 2), 0)
    b.paste(Image.fromarray((mask * 255).astype(np.uint8)), (1, 1))
    ImageDraw.floodfill(b, (0, 0), 128)
    return np.asarray(b)[1:-1, 1:-1] != 128


def _painted_land(a):
    """The painted islands: everything enclosed by the painting's dark ink coastline (small gaps in the line closed).
    The model's pale shore band outside its ink line, which colour tests mistake for land, is left out."""
    ink = Image.fromarray(((a.mean(-1) < 115) * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(7))
    land = _enclosed(np.asarray(ink) > 0)
    land = np.asarray(Image.fromarray((land * 255).astype(np.uint8)).filter(ImageFilter.MinFilter(5))) > 0   # undo the line's growth
    return _enclosed(land)


def _components(land):
    """Land components in fine cells: the label image and, for islands only, each label's bbox."""
    H, W = land.shape
    lab = np.zeros(land.shape, np.int32)
    info, n = {}, 0
    for y, x in zip(*np.nonzero(land)):
        if lab[y, x]:
            continue
        n += 1
        q, ys, xs = deque([(y, x)]), [], []
        lab[y, x] = n
        while q:
            cy, cx = q.popleft()
            ys.append(cy)
            xs.append(cx)
            for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                yy, xx = cy + dy, cx + dx
                if 0 <= yy < H and 0 <= xx < W and land[yy, xx] and not lab[yy, xx]:
                    lab[yy, xx] = n
                    q.append((yy, xx))
        if 4 <= len(ys) < MAX_CELLS:
            info[n] = (min(xs), min(ys), max(xs) + 1, max(ys) + 1)
    return lab, info


def _moments(m):
    ys, xs = np.nonzero(m)
    c = np.array([xs.mean(), ys.mean()])
    d = np.stack([xs - c[0], ys - c[1]])
    return c, d @ d.T / len(xs)


def _sqrtm(c):
    w, v = np.linalg.eigh(c)
    return v @ np.diag(np.sqrt(np.maximum(w, 1e-6))) @ v.T


def _grow(mask, px):
    return np.asarray(Image.fromarray((mask * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(2 * px + 1))) > 0


def _iou(a, b):
    return (a & b).sum() / max(1, (a | b).sum())


def _fill(img, known, iters=600):
    """Fill the unknown pixels from their known neighbours outward, so a sliver of the true island that the painting
    left as sea takes the island's own nearby art."""
    img, known = img.copy(), known.copy()
    for _ in range(iters):
        if known.all():
            break
        acc = np.zeros_like(img)
        cnt = np.zeros(known.shape, np.float32)
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1)):
            k = np.roll(np.roll(known, dy, 0), dx, 1)
            acc += np.roll(np.roll(img, dy, 0), dx, 1) * k[..., None]
            cnt += k
        new = (~known) & (cnt > 0)
        if not new.any():
            break
        img[new] = acc[new] / cnt[new][:, None]
        known |= new
    return img


def apply(repo):
    """Each island is patched once, from the most central painting it sits wholly inside, and only at its own coast:
    the painted island is fitted onto the true one (centre and spread matched) when that fits better, leftover slivers
    are filled from the island's own art, and the patch is feathered a few px past the coast (the game draws the water
    there). Tiles are always patched from the originals in tiles_before/, so apply can be rerun."""
    d = root(repo)
    crops = [tuple(c) for c in json.load(open(os.path.join(d, "plan.json")))["crops"]]
    man = json.load(open(os.path.join(repo, TILES, "manifest.json")))
    pad, chunk = man["pad"], man["chunk_tiles"]
    back = os.path.join(d, "tiles_before")
    os.makedirs(back, exist_ok=True)
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    lab, info = _components((fw & 3) == 0)
    paints, touched, report = {}, {}, []
    for n, (fx0, fy0, fx1, fy1) in info.items():
        tx0, ty0, tx1, ty1 = fx0 / 4, fy0 / 4, fx1 / 4, fy1 / 4
        best = None
        for (x0, y0) in crops:
            mx0 = 0 if x0 == 0 else 0.5          # no margin needed where the crop meets the map's edge
            my0 = 0 if y0 == 0 else 0.5
            mx1 = 0 if x0 + CROP[0] >= 540 else 0.5
            my1 = 0 if y0 + CROP[1] >= 360 else 0.5
            if tx0 >= x0 + mx0 and tx1 <= x0 + CROP[0] - mx1 and ty0 >= y0 + my0 and ty1 <= y0 + CROP[1] - my1:
                dist = abs((tx0 + tx1) / 2 - x0 - CROP[0] / 2) + abs((ty0 + ty1) / 2 - y0 - CROP[1] / 2)
                if best is None or dist < best[0]:
                    best = (dist, x0, y0)
        if best is None:
            report.append("island %d at %.0f,%.0f: in no crop, left as is" % (n, tx0, ty0))
            continue
        _, x0, y0 = best
        if (x0, y0) not in paints:
            f = os.path.join(d, "paint_%d_%d.png" % (x0, y0))
            paints[(x0, y0)] = np.asarray(Image.open(f).convert("RGB").resize((CROP[0] * PX, CROP[1] * PX), Image.LANCZOS), np.float32)
        pa = paints[(x0, y0)]
        # window: the island plus 2 tiles, in crop px
        M = 2 * PX
        wx0, wy0 = int(max(0, (tx0 - x0) * PX - M)), int(max(0, (ty0 - y0) * PX - M))
        wx1, wy1 = int(min(pa.shape[1], (tx1 - x0) * PX + M)), int(min(pa.shape[0], (ty1 - y0) * PX + M))
        fl = (lab[y0 * 4:(y0 + CROP[1]) * 4, x0 * 4:(x0 + CROP[0]) * 4] == n).astype(np.uint8) * 255
        tm = np.asarray(Image.fromarray(fl).resize((CROP[0] * PX, CROP[1] * PX), Image.BILINEAR), np.float32)[wy0:wy1, wx0:wx1]
        true = tm > 127
        win = pa[wy0:wy1, wx0:wx1]
        near = _grow(true, PX * 3 // 4)          # painted land counts as this island's within 3/4 of a tile
        painted = _painted_land(win)
        pl = painted & near
        if pl.sum() < 0.3 * true.sum():   # an island cut by the painting's edge has no closed ink line: colour test
            pl = ~_watery(win) & true
        warped, iou = win, _iou(pl, true)
        if pl.sum() > 0.3 * true.sum():
            ct, Ct = _moments(true)
            cp, Cp = _moments(pl)
            A = _sqrtm(Ct) @ np.linalg.inv(_sqrtm(Cp))      # painted spread -> true spread
            Ai = np.linalg.inv(A)                            # PIL maps output px to input px
            off = cp - Ai @ ct
            coef = (Ai[0, 0], Ai[0, 1], off[0], Ai[1, 0], Ai[1, 1], off[1])
            cand = np.stack([np.asarray(Image.fromarray(win[..., k]).transform(win.shape[1::-1], Image.AFFINE, coef,
                                                                              Image.BILINEAR), np.float32) for k in range(3)], -1)
            cand_land = np.stack([np.asarray(Image.fromarray((pl * 255).astype(np.uint8)).transform(
                win.shape[1::-1], Image.AFFINE, coef, Image.BILINEAR))], -1)[..., 0] > 127
            i1 = _iou(cand_land, true)
            if i1 > iou:
                warped, iou, pl = cand, i1, cand_land
        # sea-looking pixels inside the coast (a painted channel or shore band the ink line encloses) are filled too:
        # closer to this painting's own sea colour than to the island's interior, and near the sea colour
        sea_c = np.median(warped[~_grow(true, PX)], 0)
        core = ~_grow(~true, PX // 3)
        int_c = np.median(warped[core if core.sum() > 50 else true], 0)
        ds, di = np.linalg.norm(warped - sea_c, axis=-1), np.linalg.norm(warped - int_c, axis=-1)
        sea_like = _watery(warped) | ((ds < di) & (ds < 45))
        land_ok = pl & true & ~sea_like
        if land_ok.sum() < 0.2 * true.sum():
            report.append("island %d at %.0f,%.0f: painting has almost no land here, left as is" % (n, tx0, ty0))
            continue
        if os.environ.get("ISL_DEBUG") == str(n):
            dbg = os.environ["ISL_DEBUG_DIR"]
            for nm, im in (("win", win), ("warped", warped), ("pl", pl * 255.0), ("true", true * 255.0), ("ok", land_ok * 255.0)):
                Image.fromarray(np.asarray(im).astype(np.uint8)).save(os.path.join(dbg, "dbg_%s.png" % nm))
        filled = _fill(warped, land_ok)   # spread from the island's own art only, never from the sea outside
        report.append("island %d at %.0f,%.0f (%d cells) from crop %d,%d: fit %.2f, %.0f %% filled from its own art" % (
            n, tx0, ty0, (lab == n).sum(), x0, y0, iou, 100 * (1 - land_ok.sum() / max(1, true.sum()))))
        m = Image.fromarray((true * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(9)).filter(ImageFilter.GaussianBlur(2))
        m = np.asarray(m, np.float32)[..., None] / 255.0
        gx0, gy0 = x0 * PX + wx0, y0 * PX + wy0          # map px of the window's corner
        h, w = filled.shape[:2]
        for cy in range(gy0 // (chunk * PX), (gy0 + h - 1) // (chunk * PX) + 1):
            for cx in range(gx0 // (chunk * PX), (gx0 + w - 1) // (chunk * PX) + 1):
                key = (cx, cy)
                path = os.path.join(repo, TILES, "near_%d_%d.jpg" % key)
                if key not in touched:
                    bp = os.path.join(back, os.path.basename(path))
                    if not os.path.exists(bp):
                        shutil.copy(path, back)
                    touched[key] = np.asarray(Image.open(bp).convert("RGB"), np.float32)
                t = touched[key]
                ox, oy = gx0 - cx * chunk * PX + pad, gy0 - cy * chunk * PX + pad
                ax0, ay0 = max(0, ox), max(0, oy)
                ax1, ay1 = min(t.shape[1], ox + w), min(t.shape[0], oy + h)
                if ax0 >= ax1 or ay0 >= ay1:
                    continue
                sl = (slice(ay0 - oy, ay1 - oy), slice(ax0 - ox, ax1 - ox))
                t[ay0:ay1, ax0:ax1] = t[ay0:ay1, ax0:ax1] * (1 - m[sl]) + filled[sl] * m[sl]
    for (cx, cy), t in touched.items():
        Image.fromarray(t.clip(0, 255).astype(np.uint8)).save(os.path.join(repo, TILES, "near_%d_%d.jpg" % (cx, cy)), quality=90, subsampling=0)
    open(os.path.join(d, "apply_report.txt"), "w", encoding="utf-8").write("\n".join(report) + "\n")
    print("\n".join(report))
    print("tiles updated", len(touched), "(from the originals in", back + ")")


# ---- land-only islands (user, 2026-11-23: "this could only be fix by regenerating island by island and plug that
# exactly in ... the island has to be generated in a whole photo"). Each island gets its own picture, but of its LAND
# only: the guide is the island's land types spread out to fill the whole frame (no sea, no coastline), the model
# paints that as one patch of paper-map land, and the true coast cuts it. The game draws the sea, the shore and the ink
# coast line, so every island matches its border by construction. ----

LAND_PX = 16      # guide px per tile
LAND_MARGIN = 1.5  # tiles of land drawn past the island's box on every side
SIZES = {"wide": (1536, 864), "tall": (864, 1536), "square": (1024, 1024)}
LAND_PROMPT = """The FIRST image is a plan of a patch of land on a fantasy strategy game's campaign map, drawn from the game's data, seen straight down. The SECOND image is the art style to use. Redraw the first image as finished hand-drawn campaign-map land on aged parchment in EXACTLY the style of the second image: fine brown-black ink linework, soft watercolour washes, small inked symbols.

The whole image is LAND, edge to edge: no sea, no water, no lake, no coastline, no shore, no beach, no outline around anything, no island shape. Keep every land-type area of the plan exactly where it is, at the same size. Each colour becomes its own illustrated symbols, like the style image:
- green = forest: clusters of small round inked tree symbols, dense where the green is dark;
- light green = grassland: light green wash with sparse tufts and a few small trees;
- ochre / olive = dry steppe: pale ochre wash with sparse grass tufts, no trees;
- pale sand = sand desert: pale sand wash with fine curved dune strokes, no plants;
- rust = badlands: rust-red wash with small eroded ridge marks;
- grey-brown with relief = mountains: rows of small inked mountain peaks with snowy tops, only where the plan shows them;
- pale grey-cream = tundra: pale wash with tiny sparse tufts and frost dots;
- white = glacier and snow: white with faint blue ink hatching;
- dark grey = volcanic: a dark inked cone.

Never: water of any kind, text, letters, labels, numbers, a compass, borders, frames, buildings, roads, people, or any fade or vignette at the edges. The drawing must reach every edge of the image."""


_BIOME = {}


def _land_guide(repo, lab, n, px0, py0, pw, ph):
    """The island's land types in clear flat washes (the paper tints, saturation raised so the model reads them), its
    relief shading on top, and every cell outside the island given its nearest island cell's land type, so the frame is
    land edge to edge without smears."""
    import paper_from_near as PF
    if not _BIOME:
        _BIOME["b"] = np.fromfile(os.path.join(repo, "assets/map/terrain/biome.bin"), np.uint8).reshape(1440, 2160)
        rel = np.fromfile(os.path.join(repo, "assets/map/terrain/relief.bin"), np.uint8).reshape(2880, 4320, 2)
        _BIOME["shade"] = rel[::2, ::2, 0].astype(np.float32) / 127.5
    b, shade = _BIOME["b"], _BIOME["shade"]
    FH, FW = b.shape
    c = LAND_PX // 4                                    # guide px per fine cell
    cx0, cy0 = px0 // c, py0 // c
    cw, ch = -(-(px0 + pw) // c) - cx0, -(-(py0 + ph) // c) - cy0
    ids = np.full((ch, cw), 255, np.int16)
    sh = np.ones((ch, cw), np.float32)
    sy0, sx0, sy1, sx1 = max(0, cy0), max(0, cx0), min(FH, cy0 + ch), min(FW, cx0 + cw)
    own = lab[sy0:sy1, sx0:sx1] == n
    blk = ids[sy0 - cy0:sy1 - cy0, sx0 - cx0:sx1 - cx0]
    blk[own] = b[sy0:sy1, sx0:sx1][own]
    sh[sy0 - cy0:sy1 - cy0, sx0 - cx0:sx1 - cx0][own] = shade[sy0:sy1, sx0:sx1][own]
    known = ids != 255
    for _ in range(4 * max(ch, cw)):                     # nearest island cell's land type, spread a ring at a time
        if known.all():
            break
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            src = np.roll(np.roll(ids, dy, 0), dx, 1)
            k = np.roll(np.roll(known, dy, 0), dx, 1) & ~known
            ids[k] = src[k]
            known |= k
    col = np.zeros((ch, cw, 3), np.float32)
    for k, v in PF.PAPER_TINT.items():
        col[ids == k] = v
    grey = col.mean(-1, keepdims=True)
    col = np.clip(grey + (col - grey) * 1.8, 0, 1)        # clearer land colours for the model
    col *= np.clip(1.0 + (sh - 1.0) * 0.6, 0.6, 1.3)[..., None]
    img = Image.fromarray((np.clip(col, 0, 1) * 255).astype(np.uint8)).resize((cw * c, ch * c), Image.NEAREST)
    img = img.filter(ImageFilter.GaussianBlur(c * 0.8))
    ox, oy = px0 - cx0 * c, py0 - cy0 * c
    return np.asarray(img)[oy:oy + ph, ox:ox + pw]



def land_root(repo):
    return os.path.join(root(repo), "land")


def land_plan(repo):
    """One picture per island: a crop around it (16:9, 9:16 or square, whichever fits its shape) whose guide is the
    island's own land spread over the whole frame."""
    d = land_root(repo)
    os.makedirs(d, exist_ok=True)
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    lab, info = _components((fw & 3) == 0)
    g = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/art/paper/guide_16px_flat.png")).convert("RGB"), np.float32)
    H, W = g.shape[:2]
    plan_out = []
    for n, (fx0, fy0, fx1, fy1) in info.items():
        tx0, ty0, tx1, ty1 = fx0 / 4 - LAND_MARGIN, fy0 / 4 - LAND_MARGIN, fx1 / 4 + LAND_MARGIN, fy1 / 4 + LAND_MARGIN
        w, h = tx1 - tx0, ty1 - ty0
        shape = "wide" if w / h > 1.35 else ("tall" if h / w > 1.35 else "square")
        sw, sh = SIZES[shape]
        if w / h < sw / sh:      # widen or heighten the box to the picture's shape, centred on the island
            nw = h * sw / sh
            tx0, tx1 = tx0 - (nw - w) / 2, tx1 + (nw - w) / 2
        else:
            nh = w * sh / sw
            ty0, ty1 = ty0 - (nh - h) / 2, ty1 + (nh - h) / 2
        px0, py0 = int(round(tx0 * LAND_PX)), int(round(ty0 * LAND_PX))
        pw = int(round((tx1 - tx0) * LAND_PX))
        ph = int(round(pw * sh / sw))
        guide = _land_guide(repo, lab, n, px0, py0, pw, ph)
        Image.fromarray(guide).resize((sw, sh), Image.BICUBIC).save(os.path.join(d, "guide_%d_0.png" % n))
        # the island's own land types in words (a white guide alone reads as blank paper: the model drew green land
        # on a glacier island)
        cnt = np.bincount(_BIOME["b"][lab == n], minlength=19)
        parts = ["%s %d %%" % (HF.LOOK.get(int(k), "land"), round(100 * cnt[k] / cnt.sum()))
                 for k in np.argsort(-cnt) if cnt[k] / cnt.sum() >= 0.05 and int(k) in HF.LOOK]
        open(os.path.join(d, "prompt_%d_0.md" % n), "w", encoding="utf-8").write(
            LAND_PROMPT + "\n\nThis patch's land, from the game data (draw these and only these, in these shares, where the "
            "plan's colours put them): " + ", ".join(parts) + ".\n")
        plan_out.append({"n": int(n), "px": [px0, py0, pw, ph], "size": [sw, sh]})
    json.dump({"islands": plan_out, "px_per_tile": LAND_PX}, open(os.path.join(d, "plan.json"), "w"))
    open(os.path.join(d, "prompt.md"), "w", encoding="utf-8").write(LAND_PROMPT)
    print("islands", len(plan_out))


def land_paint(repo, quality="low"):
    d = land_root(repo)
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    style = os.path.join(repo, "design/map/continent-11/art/paper/style_ref.png")
    procs = []
    for it in json.load(open(os.path.join(d, "plan.json")))["islands"]:
        out = os.path.join(d, "paint_%d_0.png" % it["n"])
        if os.path.exists(out):
            continue
        own = os.path.join(d, "prompt_%d_0.md" % it["n"])
        procs.append(subprocess.Popen([sys.executable, "-I", tool, "gpt-image-2", quality, "%dx%d" % tuple(it["size"]),
                                       own if os.path.exists(own) else os.path.join(d, "prompt.md"), "--", out, os.path.join(d, "guide_%d_0.png" % it["n"]), style]))
        if len(procs) >= 6:
            procs.pop(0).wait()
    for p in procs:
        p.wait()


def land_apply(repo):
    """Each island's land picture, cut by the island's true coast (grown 4 px and feathered; the game's water covers
    the rest), into the tiles, always starting from the originals in tiles_before/."""
    d = land_root(repo)
    plan_ = json.load(open(os.path.join(d, "plan.json")))
    k = PX // plan_["px_per_tile"]
    man = json.load(open(os.path.join(repo, TILES, "manifest.json")))
    pad, chunk = man["pad"], man["chunk_tiles"]
    back = os.path.join(root(repo), "tiles_before")
    os.makedirs(back, exist_ok=True)
    fw = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    lab, _ = _components((fw & 3) == 0)
    FH, FW = lab.shape
    touched, done = {}, 0
    for it in plan_["islands"]:
        f = os.path.join(d, "paint_%d_0.png" % it["n"])
        if not os.path.exists(f):
            print("missing island", it["n"])
            continue
        px0, py0, pw, ph = it["px"]
        gx0, gy0, w, h = px0 * k, py0 * k, pw * k, ph * k            # map px at 48 px per tile
        pa = np.asarray(Image.open(f).convert("RGB").resize((w, h), Image.LANCZOS), np.float32)
        # the island at 48 px per tile over the picture's box: fine cells are 12 px
        cx0, cy0 = gx0 // 12, gy0 // 12
        cx1, cy1 = -(-(gx0 + w) // 12), -(-(gy0 + h) // 12)
        cell = np.zeros((cy1 - cy0, cx1 - cx0), np.uint8)
        sy0, sx0, sy1, sx1 = max(0, cy0), max(0, cx0), min(FH, cy1), min(FW, cx1)
        cell[sy0 - cy0:sy1 - cy0, sx0 - cx0:sx1 - cx0] = (lab[sy0:sy1, sx0:sx1] == it["n"]) * 255
        big = Image.fromarray(cell).resize(((cx1 - cx0) * 12, (cy1 - cy0) * 12), Image.BILINEAR)
        ox, oy = gx0 - cx0 * 12, gy0 - cy0 * 12
        true = np.asarray(big)[oy:oy + h, ox:ox + w] > 127
        m = Image.fromarray((true * 255).astype(np.uint8)).filter(ImageFilter.MaxFilter(9)).filter(ImageFilter.GaussianBlur(2))
        m = np.asarray(m, np.float32)[..., None] / 255.0
        for ty in range(max(0, gy0) // (chunk * PX), (gy0 + h - 1) // (chunk * PX) + 1):
            for tx in range(max(0, gx0) // (chunk * PX), (gx0 + w - 1) // (chunk * PX) + 1):
                path = os.path.join(repo, TILES, "near_%d_%d.jpg" % (tx, ty))
                if not os.path.exists(path):
                    continue
                if (tx, ty) not in touched:
                    bp = os.path.join(back, os.path.basename(path))
                    if not os.path.exists(bp):
                        shutil.copy(path, back)
                    touched[(tx, ty)] = np.asarray(Image.open(bp).convert("RGB"), np.float32)
                t = touched[(tx, ty)]
                ox2, oy2 = gx0 - tx * chunk * PX + pad, gy0 - ty * chunk * PX + pad
                ax0, ay0 = max(0, ox2), max(0, oy2)
                ax1, ay1 = min(t.shape[1], ox2 + w), min(t.shape[0], oy2 + h)
                if ax0 >= ax1 or ay0 >= ay1:
                    continue
                sl = (slice(ay0 - oy2, ay1 - oy2), slice(ax0 - ox2, ax1 - ox2))
                t[ay0:ay1, ax0:ax1] = t[ay0:ay1, ax0:ax1] * (1 - m[sl]) + pa[sl] * m[sl]
        done += 1
    for (tx, ty), t in touched.items():
        Image.fromarray(t.clip(0, 255).astype(np.uint8)).save(os.path.join(repo, TILES, "near_%d_%d.jpg" % (tx, ty)), quality=90, subsampling=0)
    print("islands plugged", done, "tiles updated", len(touched))


if __name__ == "__main__":
    repo, cmd = sys.argv[1], sys.argv[2]
    if cmd == "plan":
        plan(repo)
    elif cmd == "paint":
        PH.paint(repo, root(repo), "low")
    elif cmd == "apply":
        apply(repo)
    elif cmd == "land-plan":
        land_plan(repo)
    elif cmd == "land-paint":
        land_paint(repo)
    elif cmd == "land-apply":
        land_apply(repo)
