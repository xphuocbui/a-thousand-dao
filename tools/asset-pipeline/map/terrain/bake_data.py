"""Bake the data the terrain shader reads (src/ui/map/terrain.gdshader; user 2026-11-23: "Paradox-style shader").
Everything comes from the game's own map data (design/map/continent-11/base/, 4 fine px per tile), so the terrain
matches it by construction: deserts where it says desert, the coast where it says coast, no phantom land.

Writes assets/map/terrain/:
- biome.bin      uint8, fine_biome ids (world_continent.json legend.biome_ids), 2160 x 1440
- coast.bin      float32, signed distance to the true coast in tiles (+ water, - land), lightly smoothed so the shader's
                 bilinear sample gives a curved coast with no stair steps
- elev.bin       float32, elevation in metres (sea floor negative)
- river.bin      uint8, 255 on river cells (fine_water bit 4), lightly smoothed
- meta.json      sizes and formats
- biomes_array.png + .import: the 19 textures stacked vertically (one 1024 x 1024 slice per biome id), imported as a
                 Texture2DArray (VRAM compressed, mipmaps)
usage: python -I tools/asset-pipeline/map/terrain/bake_data.py <repo>
"""
import json
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

Image.MAX_IMAGE_PIXELS = None
SIDE = 1024
IMPORT = """[remap]

importer="2d_array_texture"
type="CompressedTexture2DArray"

[params]

compress/mode=2
compress/high_quality=true
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/channel_pack=0
mipmaps/generate=true
mipmaps/limit=-1
slices/horizontal=1
slices/vertical=19
"""


def signed_distance(land, steps=24):
    """Approximate signed distance (fine px) to the land/water edge: + on water, - on land, by repeated 3 x 3 growth
    (good to `steps` px; beyond that clamped)."""
    def grow(mask):
        d = np.zeros(mask.shape, np.float32)
        cur = Image.fromarray((mask * 255).astype(np.uint8))
        for s in range(1, steps + 1):
            cur = cur.filter(ImageFilter.MaxFilter(3))
            a = np.asarray(cur) > 0
            d[(d == 0) & a & ~mask] = s
        d[(d == 0) & ~mask] = steps
        return d
    to_land = grow(land)          # on water: distance to land
    to_water = grow(~land)        # on land: distance to water
    sd = np.where(land, -(to_water - 0.5), to_land - 0.5)
    return sd


def rivers(fw, el, W, H, scale=2):
    """The river cells (fine_water bit 4) traced into connected lines (user 2026-11-23: "the river is not connected":
    drawn cell by cell, 44 river systems fell into 1,126 pieces that touch only at corners). Each cell flows to its
    lowest 8-neighbour river cell (or into the sea or a lake); the paths are smoothed and drawn wider downstream, by
    the number of cells upstream. Returns a uint8 coverage image at `scale` x the fine grid."""
    from PIL import ImageDraw
    riv = (fw & 4) > 0
    water = (fw & 3) > 0
    ys, xs = np.nonzero(riv)
    cells = set(zip(ys.tolist(), xs.tolist()))
    nxt = {}
    for y, x in cells:
        best, be = None, el[y, x]
        for dy in (-1, 0, 1):
            for dx in (-1, 0, 1):
                if not (dy or dx):
                    continue
                yy, xx = y + dy, x + dx
                if not (0 <= yy < H and 0 <= xx < W):
                    continue
                if (yy, xx) in cells and el[yy, xx] < be:
                    best, be = (yy, xx), el[yy, xx]
        if best is None:   # no lower river cell: run into adjacent water if any
            for dy in (-1, 0, 1):
                for dx in (-1, 0, 1):
                    yy, xx = y + dy, x + dx
                    if 0 <= yy < H and 0 <= xx < W and water[yy, xx]:
                        best = (yy, xx)
        nxt[(y, x)] = best
    # upstream counts (cells in elevation order, highest first, pass their count down)
    acc = {c: 1 for c in cells}
    for c in sorted(cells, key=lambda c: -el[c]):
        n = nxt.get(c)
        if n in acc:
            acc[n] += acc[c]
    img = Image.new("L", (W * scale, H * scale), 0)
    dr = ImageDraw.Draw(img)
    heads = [c for c in cells if c not in set(v for v in nxt.values() if v is not None)]
    done = set()
    for h in heads:
        path, c = [h], h
        while c in nxt and nxt[c] is not None and c not in done:
            done.add(c)
            c = nxt[c]
            path.append(c)
            if c not in cells:
                break
        pts = [((x + 0.5) * scale, (y + 0.5) * scale) for y, x in path]
        for _ in range(2):   # Chaikin: round the 45-degree corners
            if len(pts) < 3:
                break
            q = [pts[0]]
            for a, b in zip(pts[:-1], pts[1:]):
                q += [(0.75 * a[0] + 0.25 * b[0], 0.75 * a[1] + 0.25 * b[1]), (0.25 * a[0] + 0.75 * b[0], 0.25 * a[1] + 0.75 * b[1])]
            q.append(pts[-1])
            pts = q
        for i in range(len(pts) - 1):
            cell = path[min(len(path) - 1, i * len(path) // max(1, len(pts) - 1))]
            wpx = max(2.6, min(6.0, 2.0 + 0.6 * np.sqrt(acc.get(cell, 1)))) * scale / 2   # never under ~2.6 px: thinner lines break up when blurred
            dr.line([pts[i], pts[i + 1]], fill=255, width=int(round(wpx)))
    return np.asarray(img.filter(ImageFilter.GaussianBlur(0.6 * scale)), np.uint8)


def majority(ids):
    """3 x 3 mode filter on the biome ids, keeping water cells as they are."""
    h, w = ids.shape
    pad = np.pad(ids, 1, mode="edge")
    stack = np.stack([pad[dy:dy + h, dx:dx + w] for dy in range(3) for dx in range(3)], 0)
    best = ids.copy()
    best_n = np.zeros(ids.shape, np.int32)
    for v in np.unique(ids):
        n = (stack == v).sum(0)
        m = n > best_n
        best[m] = v
        best_n[m] = n[m]
    water = (ids == 17) | (ids == 18)
    best[water] = ids[water]
    best[~water & ((best == 17) | (best == 18))] = ids[~water & ((best == 17) | (best == 18))]
    return best


def box(a, r):
    for _ in range(3):
        for axis in (0, 1):
            c = np.cumsum(np.pad(a, [(r + 1, r) if k == axis else (0, 0) for k in range(a.ndim)], mode="edge"), axis=axis)
            a = (np.take(c, np.arange(2 * r + 1, c.shape[axis]), axis=axis) - np.take(c, np.arange(0, c.shape[axis] - 2 * r - 1), axis=axis)) / (2 * r + 1)
    return a


def main(repo):
    base = os.path.join(repo, "design/map/continent-11/base")
    out = os.path.join(repo, "assets/map/terrain")
    os.makedirs(out, exist_ok=True)
    fb = np.asarray(Image.open(os.path.join(base, "fine_biome.png"))).astype(np.uint8)
    fb = majority(majority(fb))   # drop single-cell specks (a lone glacier or desert cell reads as a white dot)
    fw = np.asarray(Image.open(os.path.join(base, "fine_water.png")))
    el = np.asarray(Image.open(os.path.join(base, "fine_elevation.png"))).astype(np.float32) - 10000.0
    el = box(el, 2)               # the 4 px raster lit directly shows terrace stripes; light a smooth surface
    H, W = fb.shape
    land = (fw & 3) == 0
    sd = signed_distance(land) / 4.0                       # tiles
    sd = box(sd.astype(np.float32), 1).astype(np.float32)   # soften the 4 px raster's corners
    river = rivers(fw, el, W, H)
    # relief at 8 px per tile: the smoothed elevation enlarged smoothly, lit softly from three directions (key from the
    # top left, fill from the top, a little from the right) so ridges and valleys read; G = slope 0..1 for rock and snow
    eh = np.asarray(Image.fromarray(el).resize((W * 2, H * 2), Image.BICUBIC), np.float32)
    eh = box(eh, 1)
    gy, gx = np.gradient(eh)              # metres per 8th of a tile
    k = 1.0 / 700.0                       # metres to slope (a tile is about 4 km; mountains rise 1-5 km)
    nx, ny, nz = -gx * k * 8, -gy * k * 8, np.ones_like(eh)
    nl = np.sqrt(nx * nx + ny * ny + nz * nz)
    nx, ny, nz = nx / nl, ny / nl, nz / nl
    def lam(lx, ly, lz):
        l = np.sqrt(lx * lx + ly * ly + lz * lz)
        return np.clip((nx * lx + ny * ly + nz * lz) / l, 0, 1) / (lz / l)
    shade = 0.62 * lam(-0.7, -0.6, 0.9) + 0.25 * lam(0.0, -0.4, 1.0) + 0.13 * lam(0.8, 0.1, 1.0)
    slope = np.clip(1.0 - nz, 0, 1)
    relief = np.stack([np.clip(shade * 127.5, 0, 255), np.clip(slope * 4.0 * 255, 0, 255)], -1).astype(np.uint8)
    relief.tofile(os.path.join(out, "relief.bin"))
    fb.tofile(os.path.join(out, "biome.bin"))
    sd.astype(np.float32).tofile(os.path.join(out, "coast.bin"))
    el.astype(np.float32).tofile(os.path.join(out, "elev.bin"))
    river.tofile(os.path.join(out, "river.bin"))
    json.dump({"_doc": "Terrain shader data (tools/asset-pipeline/map/terrain/bake_data.py): raw little-endian arrays, "
                       "row-major, fine_px_per_tile per game tile.", "width": W, "height": H, "fine_px_per_tile": 4,
               "biome": "biome.bin (u8)", "coast": "coast.bin (f32, tiles, + water)", "elev": "elev.bin (f32, m)",
               "river": "river.bin (u8 at 2x: traced, connected river lines, width by the water they carry)", "relief": "relief.bin (rg8 at 2x: shade x 127.5, slope x 4 x 255)", "textures": "biomes_array.png (Texture2DArray, slice = biome id)",
               "slices": 19}, open(os.path.join(out, "meta.json"), "w"), indent=1)
    # the texture array
    sheet = Image.new("RGB", (SIDE, SIDE * 19))
    for k in range(19):
        f = os.path.join(out, "biome_%02d.png" % k)
        if os.path.exists(f):
            sheet.paste(Image.open(f).convert("RGB").resize((SIDE, SIDE)), (0, k * SIDE))
    dest = os.path.join(out, "biomes_array.png")
    new = np.asarray(sheet)
    if not os.path.exists(dest) or not np.array_equal(np.asarray(Image.open(dest).convert("RGB")), new):
        sheet.save(dest)   # rewritten only when a texture changed (a rewrite needs a Godot --import before use)
        print("texture array changed: run godot --headless --import")
    if not os.path.exists(dest + ".import"):
        open(dest + ".import", "w", encoding="utf-8").write(IMPORT)
    print("baked", W, H, "coast range %.1f..%.1f tiles" % (float(sd.min()), float(sd.max())))


if __name__ == "__main__":
    main(sys.argv[1])
