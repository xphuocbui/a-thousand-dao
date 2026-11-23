"""Export the 4x near layer (near_upres.py pass 2, 48 px per tile) as the game's streamed tiles (user, 2026-11-23:
"4x + deeper zoom"). The whole layer (25920 x 17280) does not fit one texture, so the map view loads the tiles in view
when zoomed in (src/ui/map/map_view.gd, near_hi) and draws the overview layer below that.

Each tile covers CHUNK x CHUNK game tiles and carries PAD px of its neighbours on every side, so filtering and mipmaps
never show a seam (the view draws only the inner region). The overview, assets/map/map_near_relief.jpg (12 px per
tile, one texture), is cut from the same pixels, so switching between the two is invisible.

usage: python -I tools/asset-pipeline/map/near_tiles.py <repo> [cx,cy ...]   (default: every tile)
writes assets/map/near_hi/near_<cx>_<cy>.jpg with a .import (VRAM compressed, mipmaps), assets/map/near_hi/manifest.json
and, for a full run, the overview assets/map/map_near_relief.jpg.
"""
import json
import math
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import near_upres as NU  # noqa: E402
import landmarks  # noqa: E402
sys.path.insert(0, os.path.join(HERE, "terrain"))
import hybrid_full as HF  # noqa: E402

P2 = os.environ.get("P2_DIR", "../hybrid/p2")      # pass 2 of the hybrid (near_upres.py on hybrid/near_24px.png)
GUIDE = os.path.join(os.path.dirname(HERE), "..", "..", "design/map/continent-11/art/near/hybrid/guide_24px.png")

GRID = (540, 360)
PX = 48           # output px per game tile
SRC_PX = 24       # pass 2's source px per tile
CHUNK = 40        # game tiles per tile side
PAD = 16          # output px of overlap on every side
OVERVIEW_PX = 12
IMPORT = """[remap]

importer="texture"
type="CompressedTexture2D"

[params]

compress/mode=2
compress/high_quality=true
compress/lossy_quality=0.7
compress/hdr_compression=1
compress/normal_map=0
compress/channel_pack=0
mipmaps/generate=true
mipmaps/limit=-1
roughness/mode=0
process/fix_alpha_border=false
process/premult_alpha=false
process/normal_map_invert_y=false
process/hdr_as_srgb=false
process/hdr_clamp_exposure=false
process/size_limit=0
detect_3d/compress_to=0
"""


def tile(repo, cx, cy):
    """The tile's pixels (with PAD on every side, edge-repeated at the map's border) as an image."""
    p = json.load(open(os.path.join(NU.root(repo, P2), "plan.json")))
    sw, sh = p["size"]
    pad_s = PAD // 2   # PAD output px = PAD / 2 source px
    x0, y0 = cx * CHUNK * SRC_PX - pad_s, cy * CHUNK * SRC_PX - pad_s
    x1 = min(GRID[0], (cx + 1) * CHUNK) * SRC_PX + pad_s
    y1 = min(GRID[1], (cy + 1) * CHUNK) * SRC_PX + pad_s
    bx = (max(0, x0), max(0, y0), min(sw, x1), min(sh, y1))
    img = np.asarray(NU.stitch(repo, P2, bx)).astype(np.float32)
    landmarks.overlay(repo, img, bx)   # the natural landmarks painted into the land (landmarks.py)
    # the coast lock and clean open sea at 48 px (hybrid_full.lock_image), against the guide enlarged 2x
    guide = Image.open(GUIDE).crop(bx).resize((img.shape[1], img.shape[0]), Image.BICUBIC)
    img = HF.lock_image(repo, img, np.asarray(guide, np.float32), (bx[0] / SRC_PX, bx[1] / SRC_PX), PX, retone=False)
    img = img.clip(0, 255).astype(np.uint8)
    # repeat the map's own edge where the padded box runs off it
    l, t = (bx[0] - x0) * 2, (bx[1] - y0) * 2
    r, b = (x1 - bx[2]) * 2, (y1 - bx[3]) * 2
    if l or t or r or b:
        img = np.pad(img, ((t, b), (l, r), (0, 0)), mode="edge")
    return Image.fromarray(img).filter(ImageFilter.UnsharpMask(radius=1.0, percent=45, threshold=2))


def main(repo, only):
    out = os.path.join(repo, "assets/map/near_hi")
    os.makedirs(out, exist_ok=True)
    cols, rows = math.ceil(GRID[0] / CHUNK), math.ceil(GRID[1] / CHUNK)
    overview = None if only else Image.new("RGB", (GRID[0] * OVERVIEW_PX, GRID[1] * OVERVIEW_PX))
    for cy in range(rows):
        for cx in range(cols):
            if only and (cx, cy) not in only:
                continue
            im = tile(repo, cx, cy)
            name = "near_%d_%d.jpg" % (cx, cy)
            im.save(os.path.join(out, name), quality=90, subsampling=0)
            imp = os.path.join(out, name + ".import")
            if not os.path.exists(imp):
                open(imp, "w", encoding="utf-8").write(IMPORT)
            if overview is not None:
                inner = im.crop((PAD, PAD, im.size[0] - PAD, im.size[1] - PAD))
                f = OVERVIEW_PX / PX
                overview.paste(inner.resize((round(inner.size[0] * f), round(inner.size[1] * f)), Image.LANCZOS),
                               (cx * CHUNK * OVERVIEW_PX, cy * CHUNK * OVERVIEW_PX))
            print(name, im.size, flush=True)
    json.dump({"_doc": "Streamed near-map tiles (tools/asset-pipeline/map/near_tiles.py): tile (cx, cy) covers game tiles "
                       "[cx*chunk_tiles, cy*chunk_tiles] onward, chunk_tiles across (less at the map's right and bottom "
                       "edge), at px_per_tile, with pad px of overlap on every side; draw only the inner region.",
               "dir": "res://assets/map/near_hi", "chunk_tiles": CHUNK, "px_per_tile": PX, "pad": PAD,
               "cols": cols, "rows": rows, "grid": list(GRID)},
              open(os.path.join(out, "manifest.json"), "w", encoding="utf-8"), indent=1)
    if overview is not None:
        overview.save(os.path.join(repo, "assets/map/map_near_relief.jpg"), quality=92, subsampling=0)
        print("overview", overview.size)


if __name__ == "__main__":
    sel = {tuple(int(v) for v in a.split(",")) for a in sys.argv[2:]}
    main(sys.argv[1], sel)
