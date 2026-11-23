"""Paint the near map layer (production/plans/overnight-2026-11-22.md steps 5-6): the guide render is cut into
overlapping 16:9 crops, each crop is repainted by the image model over the guide (top-down, so crops stitch), each
painted crop is colour-matched back to its guide crop (so neighbours agree), and the overlaps are feather-blended into
one image registered to the 540 x 360 grid.

usage:
  python -I paint_tiles.py plan   <repo>                       writes the crop plan and the guide inputs
  python -I paint_tiles.py paint  <repo> <quality> [ids]       paints crops (all, or comma-separated ids) not yet done
  python -I paint_tiles.py stitch <repo> [ids]                 blends painted crops into the near layer (or a test area)

Files under design/map/continent-11/art/near/: plan.json, guide_<id>.png (input, 1536 x 864), paint_<id>.png (model
output), and near_12px.png (the stitched layer, 12 px per game tile). The key comes from OPENAI_API_KEY.
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image

GUIDE_PX = 4          # guide pixels per game tile
OUT_PX = 12           # near layer pixels per game tile
CROP = (512, 288)     # guide pixels per crop (128 x 72 game tiles), 16:9
SCALE = OUT_PX // GUIDE_PX
COLS, ROWS = 5, 7


def art_dir(repo):
    return os.path.join(repo, "design/map/continent-11/art/near")


def plan(repo):
    guide = Image.open(os.path.join(repo, "design/map/continent-11/art/guide_4x.png")).convert("RGB")
    gw, gh = guide.size
    d = art_dir(repo)
    os.makedirs(d, exist_ok=True)
    xs = [round(i * (gw - CROP[0]) / (COLS - 1)) for i in range(COLS)]
    ys = [round(j * (gh - CROP[1]) / (ROWS - 1)) for j in range(ROWS)]
    land = np.asarray(Image.open(os.path.join(repo, "design/map/continent-11/base/fine_water.png"))) & 1 == 0
    crops = []
    for j, y in enumerate(ys):
        for i, x in enumerate(xs):
            cid = "r%dc%d" % (j, i)
            box = (x, y, x + CROP[0], y + CROP[1])
            guide.crop(box).resize((CROP[0] * 3, CROP[1] * 3), Image.BICUBIC).save(os.path.join(d, "guide_%s.png" % cid))
            share = float(land[y:y + CROP[1], x:x + CROP[0]].mean())
            crops.append({"id": cid, "box": box, "land": round(share, 3)})
    with open(os.path.join(d, "plan.json"), "w", encoding="utf-8") as f:
        json.dump({"guide": [gw, gh], "crop": CROP, "out_px": OUT_PX, "crops": crops}, f, indent=1)
    print("plan: %d crops, overlap x %d px, y %d px (guide px)" % (len(crops), CROP[0] - (xs[1] - xs[0]), CROP[1] - (ys[1] - ys[0])))


def paint(repo, quality, ids):
    d = art_dir(repo)
    p = json.load(open(os.path.join(d, "plan.json"), encoding="utf-8"))
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    prompts = os.path.join(repo, "tools/asset-pipeline/map/prompts")
    jobs = []
    for c in p["crops"]:
        if ids and c["id"] not in ids:
            continue
        out = os.path.join(d, "paint_%s.png" % c["id"])
        if os.path.exists(out):
            continue
        prompt = "near-sea.md" if c["land"] < 0.03 else "near-land.md"
        jobs.append([sys.executable, "-I", tool, "gpt-image-2", quality, "1536x864", os.path.join(prompts, prompt),
                     os.path.join(prompts, "near-base.md"), "--", out, os.path.join(d, "guide_%s.png" % c["id"])])
    from concurrent.futures import ThreadPoolExecutor   # four requests at once (each waits on the network)
    with ThreadPoolExecutor(max_workers=int(os.environ.get("PAINT_WORKERS", "4"))) as pool:
        list(pool.map(lambda cmd: subprocess.run(cmd, check=False), jobs))


def match_colour(paint, guide, strength=0.7):
    """Moves the painted crop's per-channel mean and spread toward its guide crop's (in a simple opponent space), so
    neighbouring crops share one palette; `strength` keeps some of the painting's own life."""
    def to_opp(a):
        r, g, b = a[..., 0], a[..., 1], a[..., 2]
        return np.stack([(r + g + b) / 3.0, r - g, (r + g) / 2.0 - b], axis=-1)

    def from_opp(o):
        l, a, bb = o[..., 0], o[..., 1], o[..., 2]
        # inverse of to_opp: with s = r + g, 3l = s + b and bb = s / 2 - b, so s = (3l + bb) / 1.5
        s_ = (3.0 * l + bb) / 1.5
        b = s_ / 2.0 - bb
        r = (s_ + a) / 2.0
        g = (s_ - a) / 2.0
        return np.stack([r, g, b], axis=-1)

    po, go = to_opp(paint), to_opp(guide)
    out = po.copy()
    for k in range(3):
        pm, ps = po[..., k].mean(), po[..., k].std() + 1e-6
        gm, gs = go[..., k].mean(), go[..., k].std() + 1e-6
        target = (po[..., k] - pm) / ps * (ps + (gs - ps) * strength * 0.5) + (pm + (gm - pm) * strength)
        out[..., k] = target
    return np.clip(from_opp(out), 0, 255)


def stitch(repo, ids):
    d = art_dir(repo)
    p = json.load(open(os.path.join(d, "plan.json"), encoding="utf-8"))
    gw, gh = p["guide"]
    W, H = gw * SCALE, gh * SCALE
    acc = np.zeros((H, W, 3), np.float32)
    wsum = np.zeros((H, W, 1), np.float32)
    cw, ch = CROP[0] * SCALE, CROP[1] * SCALE
    # feather: weight falls to the crop's edge over the overlap width
    fx = np.minimum(np.arange(cw) + 1, cw - np.arange(cw)).astype(np.float32)
    fy = np.minimum(np.arange(ch) + 1, ch - np.arange(ch)).astype(np.float32)
    feather = np.clip(np.minimum(fy[:, None] / (ch * 0.18), fx[None, :] / (cw * 0.12)), 0.02, 1.0)[..., None]
    used = 0
    for c in p["crops"]:
        if ids and c["id"] not in ids:
            continue
        path = os.path.join(d, "paint_%s.png" % c["id"])
        if not os.path.exists(path):
            continue
        paint = np.asarray(Image.open(path).convert("RGB").resize((cw, ch), Image.LANCZOS)).astype(np.float32)
        guide = np.asarray(Image.open(os.path.join(d, "guide_%s.png" % c["id"])).convert("RGB").resize((cw, ch))).astype(np.float32)
        paint = match_colour(paint, guide)
        x0, y0 = c["box"][0] * SCALE, c["box"][1] * SCALE
        acc[y0:y0 + ch, x0:x0 + cw] += paint * feather
        wsum[y0:y0 + ch, x0:x0 + cw] += feather
        used += 1
    covered = wsum[..., 0] > 0
    out = np.where(wsum > 0, acc / np.maximum(wsum, 1e-6), 0)
    img = Image.fromarray(out.astype(np.uint8))
    if ids:   # a test area: crop to what was painted
        ysx = np.where(covered.any(axis=1))[0]
        xsx = np.where(covered.any(axis=0))[0]
        img = img.crop((xsx[0], ysx[0], xsx[-1] + 1, ysx[-1] + 1))
        name = "test_" + "_".join(sorted(ids)) + ".png"
    else:
        name = "near_12px.png"
    img.save(os.path.join(d, name), optimize=True)
    print("stitched %d crops -> %s %s" % (used, name, img.size))


if __name__ == "__main__":
    cmd, repo = sys.argv[1], sys.argv[2]
    if cmd == "plan":
        plan(repo)
    elif cmd == "paint":
        paint(repo, sys.argv[3], set(sys.argv[4].split(",")) if len(sys.argv) > 4 else set())
    elif cmd == "stitch":
        stitch(repo, set(sys.argv[3].split(",")) if len(sys.argv) > 3 else set())
