"""Repaint the far (paper) map layer at 3x (user, 2026-11-23: the map looked blurry when zoomed): the current painting
(design/map/continent-11/art/far/far_paper.png, 1536 x 1024, 2.84 px per tile) is cut into overlapping crops, each
crop is enlarged 3x and repainted by the image model as the same painting at full detail, colour-matched back to the
enlarged original (so the look and the neighbours agree) and feather-blended into one 4608 x 3072 layer, still
registered to the 540 x 360 grid (8.5 px per tile).

usage:
  python -I far_upres.py plan   <repo>                  writes the crop plan and the enlarged inputs
  python -I far_upres.py paint  <repo> <quality> [ids]  paints crops (all, or comma-separated ids) not yet done
  python -I far_upres.py stitch <repo>                  blends the painted crops into far/far_paper_3x.png

Files under design/map/continent-11/art/far/upres/: plan.json, src_<id>.png (input, 1536 x 864), paint_<id>.png and
-meta.json (model output and usage). The key comes from OPENAI_API_KEY.
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from paint_tiles import match_colour  # noqa: E402  (the near layer's colour transfer)

SCALE = 3
CROP = (512, 288)     # source px per crop; x 3 = the model's 1536 x 864
COLS, ROWS = 4, 4


def d(repo):
    return os.path.join(repo, "design/map/continent-11/art/far/upres")


def plan(repo):
    src = Image.open(os.path.join(repo, "design/map/continent-11/art/far/far_paper.png")).convert("RGB")
    w, h = src.size
    os.makedirs(d(repo), exist_ok=True)
    xs = [round(i * (w - CROP[0]) / (COLS - 1)) for i in range(COLS)]
    ys = [round(j * (h - CROP[1]) / (ROWS - 1)) for j in range(ROWS)]
    crops = []
    for j, y in enumerate(ys):
        for i, x in enumerate(xs):
            cid = "%d_%d" % (i, j)
            big = src.crop((x, y, x + CROP[0], y + CROP[1])).resize((CROP[0] * SCALE, CROP[1] * SCALE), Image.LANCZOS)
            big.save(os.path.join(d(repo), "src_%s.png" % cid))
            crops.append({"id": cid, "x": x, "y": y})
    json.dump({"source": [w, h], "scale": SCALE, "crop": CROP, "crops": crops},
              open(os.path.join(d(repo), "plan.json"), "w"), indent=1)
    print("crops %d (overlap x %d px, y %d px of source)" % (len(crops), CROP[0] - (xs[1] - xs[0]), CROP[1] - (ys[1] - ys[0])))


PROMPT = os.path.join(HERE, "prompts", "far-upres.md")


def paint(repo, quality, ids):
    p = json.load(open(os.path.join(d(repo), "plan.json")))
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    todo = [c for c in p["crops"] if (not ids or c["id"] in ids)
            and not os.path.exists(os.path.join(d(repo), "paint_%s.png" % c["id"]))]

    def run(c):
        out = os.path.join(d(repo), "paint_%s.png" % c["id"])
        subprocess.run([sys.executable, "-I", tool, "gpt-image-2", quality, "1536x864", PROMPT, "--", out,
                        os.path.join(d(repo), "src_%s.png" % c["id"])], check=False)

    from concurrent.futures import ThreadPoolExecutor
    with ThreadPoolExecutor(max_workers=int(os.environ.get("PAINT_WORKERS", "4"))) as pool:
        list(pool.map(run, todo))
    print("painted %d" % len(todo))


def stitch(repo):
    p = json.load(open(os.path.join(d(repo), "plan.json")))
    w, h = p["source"][0] * SCALE, p["source"][1] * SCALE
    acc = np.zeros((h, w, 3), np.float64)
    wt = np.zeros((h, w, 1), np.float64)
    cw, ch = CROP[0] * SCALE, CROP[1] * SCALE
    ramp = 160   # feather width in output px
    wx = np.minimum(1.0, np.minimum(np.arange(cw) + 1, cw - np.arange(cw)) / ramp)
    wy = np.minimum(1.0, np.minimum(np.arange(ch) + 1, ch - np.arange(ch)) / ramp)
    mask = (wy[:, None] * wx[None, :])[..., None]
    missing = []
    for c in p["crops"]:
        f = os.path.join(d(repo), "paint_%s.png" % c["id"])
        if not os.path.exists(f):
            missing.append(c["id"])
            continue
        src = Image.open(os.path.join(d(repo), "src_%s.png" % c["id"])).convert("RGB")
        im = Image.open(f).convert("RGB").resize((cw, ch), Image.LANCZOS)
        a = match_colour(np.asarray(im).astype(np.float64), np.asarray(src).astype(np.float64), 0.8)
        x, y = c["x"] * SCALE, c["y"] * SCALE
        # edges of the whole map get full weight (no neighbour to blend with)
        m = mask.copy()
        if c["x"] == 0:
            m[:, :ramp] = np.maximum(m[:, :ramp], wy[:, None, None] * 1.0)
        if c["y"] == 0:
            m[:ramp, :] = np.maximum(m[:ramp, :], wx[None, :, None] * 1.0)
        if c["x"] + CROP[0] >= p["source"][0]:
            m[:, -ramp:] = np.maximum(m[:, -ramp:], wy[:, None, None] * 1.0)
        if c["y"] + CROP[1] >= p["source"][1]:
            m[-ramp:, :] = np.maximum(m[-ramp:, :], wx[None, :, None] * 1.0)
        acc[y:y + ch, x:x + cw] += a * m
        wt[y:y + ch, x:x + cw] += m
    if missing:
        print("missing crops (not stitched):", ",".join(missing))
        sys.exit(1)
    out = (acc / np.maximum(wt, 1e-6)).clip(0, 255).astype(np.uint8)
    path = os.path.join(repo, "design/map/continent-11/art/far/far_paper_3x.png")
    Image.fromarray(out).save(path)
    print(path, out.shape[1], "x", out.shape[0])


if __name__ == "__main__":
    cmd, repo = sys.argv[1], sys.argv[2]
    if cmd == "plan":
        plan(repo)
    elif cmd == "paint":
        paint(repo, sys.argv[3], set(sys.argv[4].split(",")) if len(sys.argv) > 4 else set())
    elif cmd == "stitch":
        stitch(repo)
