"""Repaint the near (painted relief) map layer at 4x, as two 2x passes (user, 2026-11-23: "The zoomed in map is still
blurry"; picked "4x + deeper zoom", medium quality, two passes, a test area first). The layer is painted clean: places
are shown on the map by symbols and their paintings move into the place panel (user, 2026-11-23).

One pass: the source image is cut into overlapping crops (768 x 432 source px), each crop is enlarged 2x and repainted
by the image model as the same painting at full detail (prompts/near-upres.md), colour-matched back to its enlarged
input and feather-blended over the plain 2x enlargement. Crops that are open sea are not painted (the sea is smooth;
they keep the enlargement). Pass 1 reads design/map/continent-11/art/near/near_12px_sea.png (12 px per tile) and gives
24 px per tile; pass 2 reads pass 1's result and gives 48 px per tile. The full 25920 x 17280 layer is stitched box by
box straight into game tiles (a separate step: it does not fit one texture).

usage:
  python -I near_upres.py plan   <repo> <pass_dir> <source.png> [x0,y0,x1,y1]  crops (only those touching the box)
  python -I near_upres.py paint  <repo> <pass_dir> <quality> [ids]              paints land crops not yet done
  python -I near_upres.py stitch <repo> <pass_dir> <out.png> [x0,y0,x1,y1]      blends the box (source px; default all)

<pass_dir> is relative to design/map/continent-11/art/near/upres4/. Each holds plan.json, src_<id>.png (1536 x 864) and
paint_<id>.png with -meta.json (model output and usage). The key comes from OPENAI_API_KEY; PAINT_WORKERS sets the
parallel requests (4).
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from paint_tiles import match_colour  # noqa: E402  (the near layer's colour transfer)

SCALE = 2
CROP = (768, 432)      # source px per crop; x 2 = the model's 1536 x 864
STEP = (640, 360)      # overlap 128 x 72 source px
LAND_MIN = 0.0         # paint every crop, sea too, so the sea colour stays even (user, 2026-11-23)
RAMP = 200             # feather width in output px (inside the 256 x 144 output px overlap)
GRID_W = 540           # game tiles across
PROMPT = os.path.join(HERE, "prompts", "near-upres.md")


def root(repo, pass_dir):
    return os.path.join(repo, "design/map/continent-11/art/near/upres4", pass_dir)


def plan(repo, pass_dir, src_path, box=None):
    src = Image.open(src_path).convert("RGB")
    w, h = src.size
    px_tile = w / GRID_W
    ox_t, oy_t = 0.0, 0.0
    if os.environ.get("PLAN_ORIGIN"):   # a test-area source: "x_tiles,y_tiles,px_per_tile" of its top-left corner
        ox_t, oy_t, px_tile = (float(v) for v in os.environ["PLAN_ORIGIN"].split(","))
    water = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png")))
    land4 = (water & 1) == 0            # 4 px per tile
    f = px_tile / 4.0
    o4x, o4y = int(ox_t * 4), int(oy_t * 4)
    d = root(repo, pass_dir)
    os.makedirs(d, exist_ok=True)
    cols = -(-(w - CROP[0]) // STEP[0]) + 1
    rows = -(-(h - CROP[1]) // STEP[1]) + 1
    xs = [round(i * (w - CROP[0]) / (cols - 1)) for i in range(cols)]
    ys = [round(j * (h - CROP[1]) / (rows - 1)) for j in range(rows)]
    crops = []
    for j, y in enumerate(ys):
        for i, x in enumerate(xs):
            if box and (x + CROP[0] <= box[0] or y + CROP[1] <= box[1] or x >= box[2] or y >= box[3]):
                continue
            cid = "%d_%d" % (i, j)
            sub = land4[o4y + int(y / f):o4y + int((y + CROP[1]) / f), o4x + int(x / f):o4x + int((x + CROP[0]) / f)]
            share = float(sub.mean()) if sub.size else 0.0
            if share >= LAND_MIN:
                big = src.crop((x, y, x + CROP[0], y + CROP[1])).resize((CROP[0] * SCALE, CROP[1] * SCALE), Image.LANCZOS)
                big.save(os.path.join(d, "src_%s.png" % cid))
            crops.append({"id": cid, "x": x, "y": y, "land": round(share, 3), "paint": share >= LAND_MIN})
    json.dump({"source": os.path.relpath(src_path, repo).replace("\\", "/"), "size": [w, h], "crops": crops},
              open(os.path.join(d, "plan.json"), "w"), indent=1)
    print("crops %d of a %d x %d grid, to paint %d" % (len(crops), cols, rows, sum(1 for c in crops if c["paint"])))


def paint(repo, pass_dir, quality, ids):
    d = root(repo, pass_dir)
    p = json.load(open(os.path.join(d, "plan.json")))
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    todo = [c for c in p["crops"] if c["paint"] and (not ids or c["id"] in ids)
            and not os.path.exists(os.path.join(d, "paint_%s.png" % c["id"]))]

    def run(c):
        subprocess.run([sys.executable, "-I", tool, "gpt-image-2", quality, "1536x864", PROMPT, "--",
                        os.path.join(d, "paint_%s.png" % c["id"]), os.path.join(d, "src_%s.png" % c["id"])],
                       check=False)

    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=int(os.environ.get("PAINT_WORKERS", "4"))) as pool:
        list(pool.map(run, todo))
    done = sum(1 for c in todo if os.path.exists(os.path.join(d, "paint_%s.png" % c["id"])))
    print("painted %d of %d (%s)" % (done, len(todo), quality))


def stitch(repo, pass_dir, box=None):
    """The pass's painted crops blended over the plain 2x enlargement inside [param box] (source px), as an image."""
    d = root(repo, pass_dir)
    p = json.load(open(os.path.join(d, "plan.json")))
    sw, sh = p["size"]
    box = box or (0, 0, sw, sh)
    src = Image.open(os.path.join(repo, p["source"])).convert("RGB").crop(box)
    ox, oy = box[0], box[1]
    w, h = src.size[0] * SCALE, src.size[1] * SCALE
    acc = np.asarray(src.resize((w, h), Image.LANCZOS)).astype(np.float32) * 1e-3
    wt = np.full((h, w, 1), 1e-3, np.float32)
    cw, ch = CROP[0] * SCALE, CROP[1] * SCALE
    wx = np.minimum(1.0, np.minimum(np.arange(cw) + 1, cw - np.arange(cw)) / RAMP).astype(np.float32)
    wy = np.minimum(1.0, np.minimum(np.arange(ch) + 1, ch - np.arange(ch)) / RAMP).astype(np.float32)
    mask = (wy[:, None] * wx[None, :])[..., None]
    used = 0
    for c in p["crops"]:
        if not c["paint"]:
            continue
        x, y = (c["x"] - ox) * SCALE, (c["y"] - oy) * SCALE
        if x + cw <= 0 or y + ch <= 0 or x >= w or y >= h:
            continue
        f = os.path.join(d, "paint_%s.png" % c["id"])
        if not os.path.exists(f):
            continue
        s = Image.open(os.path.join(d, "src_%s.png" % c["id"])).convert("RGB")
        im = Image.open(f).convert("RGB").resize((cw, ch), Image.LANCZOS)
        a = match_colour(np.asarray(im).astype(np.float32), np.asarray(s).astype(np.float32), 0.8).astype(np.float32)
        m = mask.copy()
        if c["x"] == 0:
            m[:, :RAMP] = np.maximum(m[:, :RAMP], wy[:, None, None])
        if c["y"] == 0:
            m[:RAMP, :] = np.maximum(m[:RAMP, :], wx[None, :, None])
        if c["x"] + CROP[0] >= sw:
            m[:, -RAMP:] = np.maximum(m[:, -RAMP:], wy[:, None, None])
        if c["y"] + CROP[1] >= sh:
            m[-RAMP:, :] = np.maximum(m[-RAMP:, :], wx[None, :, None])
        x0, y0, x1, y1 = max(0, x), max(0, y), min(w, x + cw), min(h, y + ch)
        acc[y0:y1, x0:x1] += a[y0 - y:y1 - y, x0 - x:x1 - x] * m[y0 - y:y1 - y, x0 - x:x1 - x]
        wt[y0:y1, x0:x1] += m[y0 - y:y1 - y, x0 - x:x1 - x]
        used += 1
    print("stitched %d painted crops" % used)
    return Image.fromarray((acc / wt).clip(0, 255).astype(np.uint8))


def _box(s):
    return tuple(int(v) for v in s.split(",")) if s else None


if __name__ == "__main__":
    cmd, repo, pd = sys.argv[1], sys.argv[2], sys.argv[3]
    if cmd == "plan":
        plan(repo, pd, os.path.join(repo, sys.argv[4]), _box(sys.argv[5] if len(sys.argv) > 5 else ""))
    elif cmd == "paint":
        paint(repo, pd, sys.argv[4], set(sys.argv[5].split(",")) if len(sys.argv) > 5 else set())
    elif cmd == "stitch":
        out = os.path.join(repo, sys.argv[4])
        stitch(repo, pd, _box(sys.argv[5] if len(sys.argv) > 5 else "")).save(out)
        print(out)
