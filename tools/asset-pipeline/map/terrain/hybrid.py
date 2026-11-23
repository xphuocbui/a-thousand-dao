"""Hybrid near terrain (user, 2026-11-23: the data-driven shader "looks so bad", flat, blobby biomes, wrong water and
mountains; the old painting looked good but ignored the data): the shader's render of the true data is the guide, the
image model paints over it, and code checks and locks the result.

  1. guide   render_guide.gd renders the shader for a tile box (correct biomes, coasts, relief).
  2. paint   the image model repaints the guide as a finished painting, told to keep every land type where it is.
  3. check   per biome in the piece, the painted mean colour must stay near the guide's (a desert must come back
             sandy, not green); water must stay water. A piece that fails is reported (and repainted in a full run).
  4. lock    the coast is the shader's smooth true-coast curve (coast.bin): painted land past it on the water side is
             refilled from the painted water nearby, and the reverse, so phantom land and coast drift cannot survive.

usage: python -I hybrid.py <repo> paint <dir> [quality]   guide_*.png -> paint_*.png (missing only)
       python -I hybrid.py <repo> check <dir> <px>          prints the check per piece, writes lock_*.png and compare.jpg
"""
import json
import os
import re
import subprocess
import sys

import numpy as np
from PIL import Image

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
from coast_lock import push_pull  # noqa: E402
from water_lock import field  # noqa: E402

PROMPT = """This image is a rough computer render of a tile of a grand-strategy game's terrain map, seen straight down. Repaint it as a finished, high-end painted terrain: a painterly, almost diorama-like relief of real landscape, as if a hand-painted scale model of the land were photographed STRAIGHT DOWN (orthographic, no perspective, no horizon), with rich detail at a small scale and warm golden-hour light from the TOP LEFT, soft long shadows to the bottom right.

KEEP EVERY AREA'S LAND TYPE EXACTLY WHERE AND AS IT IS in the input; this is a map of real data and must stay true:
- pale yellow sand = bare sand desert with dunes and no plants;
- rust brown = eroded red badlands;
- olive = dry steppe of short grass and scattered shrubs (NOT forest);
- light green = grassland and meadows;
- dark green = forest canopy (only where the input is dark green);
- grey rock = mountains (only where the input is grey; elsewhere the land stays as flat or hilly as the input shows);
- white = snow and glacier ice; dark grey-black = volcanic rock; grey-brown with pale patches = tundra;
- blue = water, with every coastline, lake shore and river exactly where it is.
Do not add forest, mountains, islands, lakes or rivers that the input does not have.

The input is only a rough plan, not the finished look. Its borders between land types are crude rounded blobs: redraw every border as a natural transition that follows the land (valleys, ridges, rivers, slopes), mixing the two land types over a band, with scattered outliers, the way real landscapes change, while keeping each area roughly in the same place and the same size. Invent rich natural detail everywhere: ridgelines and valleys, gullies, rock outcrops, scattered trees and groves at forest edges, small ponds and streams feeding the rivers, dune fields in the desert, field-like patches only in open grassland near rivers. Every river must be one continuous line from its source to its mouth, never broken. The water is a deep, clear sea or lake with soft turquoise shallows and gentle surf along the shore.

Never: buildings, towns, roads, bridges, people, animals, boats, text, labels, symbols, borders, frames, vignette, clouds or mist covering the land, or any fade at the image edges. The painting must reach every edge of the image."""

GRID_FINE = (2160, 1440)


def paint(repo, d, quality):
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    pr = os.path.join(d, "prompt.md")
    open(pr, "w", encoding="utf-8").write(PROMPT)
    procs = []
    for f in sorted(os.listdir(d)):
        m = re.match(r"guide_(\d+)_(\d+)\.png$", f)
        if not m:
            continue
        out = os.path.join(d, "paint_%s_%s.png" % m.groups())
        if os.path.exists(out):
            continue
        own = os.path.join(d, "prompt_%s_%s.md" % m.groups())   # a piece's own prompt (contents, last drift) if written
        procs.append(subprocess.Popen([sys.executable, "-I", tool, "gpt-image-2", quality, "1536x864",
                                       own if os.path.exists(own) else pr, "--", out, os.path.join(d, f)]))
        if len(procs) >= 6:
            procs.pop(0).wait()
    for p in procs:
        p.wait()


def repaint_failed(repo, d, px, quality, tries=3, limit=32.0):
    """Repaints every piece whose check fails (biome colour drift over `limit` or land on open water), up to `tries`
    times, keeping the attempt with the smallest drift."""
    for attempt in range(tries):
        bad = [r for r in score_all(repo, d, px) if r[2] > limit or r[3] > 0.03]
        if not bad:
            return
        for x0, y0, worst, los in bad:
            f = os.path.join(d, "paint_%d_%d.png" % (x0, y0))
            keep = os.path.join(d, "best_%d_%d.png" % (x0, y0))
            prev = json.load(open(keep + ".json")) if os.path.exists(keep + ".json") else None
            if prev is None or worst < prev["worst"]:
                Image.open(f).save(keep)
                json.dump({"worst": worst, "land_on_sea": los}, open(keep + ".json", "w"))
            os.remove(f)
        paint(repo, d, quality)
        print("repainted %d pieces (attempt %d)" % (len(bad), attempt + 1))
    # the best of all attempts stays as the paint
    for x0, y0, worst, los in score_all(repo, d, px):
        keep = os.path.join(d, "best_%d_%d.png" % (x0, y0))
        if os.path.exists(keep + ".json") and json.load(open(keep + ".json"))["worst"] < worst:
            Image.open(keep).save(os.path.join(d, "paint_%d_%d.png" % (x0, y0)))


def score_all(repo, d, px):
    out = []
    biome = load_bin(repo, "biome.bin", np.uint8)
    coast = load_bin(repo, "coast.bin", np.float32)
    for f in sorted(os.listdir(d)):
        m = re.match(r"paint_(\d+)_(\d+)\.png$", f)
        if not m:
            continue
        x0, y0 = int(m.group(1)), int(m.group(2))
        guide = np.asarray(Image.open(os.path.join(d, "guide_%d_%d.png" % (x0, y0))).convert("RGB")).astype(np.float32)
        h, w = guide.shape[:2]
        pa = np.asarray(Image.open(os.path.join(d, f)).convert("RGB").resize((w, h), Image.LANCZOS)).astype(np.float32)
        ys = np.clip(((y0 + (np.arange(h) + 0.5) / px) * 4).astype(int), 0, GRID_FINE[1] - 1)
        xs = np.clip(((x0 + (np.arange(w) + 0.5) / px) * 4).astype(int), 0, GRID_FINE[0] - 1)
        bid = biome[ys[:, None], xs[None, :]]
        sd = field((x0, y0), (w, h), px, coast, 0.0)
        worst = 0.0
        for b in np.unique(bid):
            if int(b) in (17, 18):
                continue
            sel = (bid == b) & (sd <= 0)
            if sel.sum() < 2000:
                continue
            worst = max(worst, float(np.sqrt(((guide[sel].mean(0) - pa[sel].mean(0)) ** 2).sum())))
        pw = (pa[..., 2] > pa[..., 0] + 12) & (pa[..., 2] > pa[..., 1] - 5)
        los = float((~pw & (sd > 0.4)).sum()) / max(1.0, float((sd > 0.4).sum()))
        out.append((x0, y0, worst, los))
    return out


def _fill(paint_, guide, ok):
    """The guide's pixels re-toned to the painting's nearby colour: guide detail + (painting's local mean - guide's)."""
    pm = push_pull(paint_.astype(np.uint8), ok)
    gm = push_pull(guide.astype(np.uint8), ok)
    return np.clip(guide + (pm - gm), 0, 255)


def load_bin(repo, name, dtype):
    return np.fromfile(os.path.join(repo, "assets/map/terrain", name), dtype=dtype).reshape(GRID_FINE[1], GRID_FINE[0])


def check(repo, d, px):
    biome = load_bin(repo, "biome.bin", np.uint8)
    coast = load_bin(repo, "coast.bin", np.float32)
    names = json.load(open(os.path.join(repo, "assets/data/world_continent.json"), encoding="utf-8"))["legend"]["biome_ids"]
    rows = []
    for f in sorted(os.listdir(d)):
        m = re.match(r"paint_(\d+)_(\d+)\.png$", f)
        if not m:
            continue
        x0, y0 = int(m.group(1)), int(m.group(2))
        guide = np.asarray(Image.open(os.path.join(d, "guide_%d_%d.png" % (x0, y0))).convert("RGB")).astype(np.float32)
        h, w = guide.shape[:2]
        paint_ = np.asarray(Image.open(os.path.join(d, f)).convert("RGB").resize((w, h), Image.LANCZOS)).astype(np.float32)
        # the data at the piece's pixels (nearest fine cell)
        ys = np.clip(((y0 + (np.arange(h) + 0.5) / px) * 4).astype(int), 0, GRID_FINE[1] - 1)
        xs = np.clip(((x0 + (np.arange(w) + 0.5) / px) * 4).astype(int), 0, GRID_FINE[0] - 1)
        bid = biome[ys[:, None], xs[None, :]]
        sd = field((x0, y0), (w, h), px, coast, 0.0)          # signed distance to the coast, tiles (+ water)
        water_true = sd > 0.0
        # 3. check: per biome, the painted mean colour against the guide's (only cells well inside the biome)
        report = []
        worst = 0.0
        for b in np.unique(bid):
            if int(b) in (17, 18):
                continue
            sel = (bid == b) & ~water_true
            if sel.sum() < 2000:
                continue
            g, p = guide[sel].mean(0), paint_[sel].mean(0)
            dist = float(np.sqrt(((g - p) ** 2).sum()))
            worst = max(worst, dist)
            report.append("%s %.0f%% d%.0f" % (names[str(int(b))], 100.0 * sel.mean(), dist))
        pw = (paint_[..., 2] > paint_[..., 0] + 12) & (paint_[..., 2] > paint_[..., 1] - 5)
        land_on_sea = float((~pw & (sd > 0.4)).sum()) / max(1.0, float((sd > 0.4).sum()))
        verdict_hint = "drift" if worst > 45 or land_on_sea > 0.03 else "ok"
        rows.append("piece %d,%d: %s; land painted on open water %.1f %%; worst biome colour drift %.0f (%s)" % (
            x0, y0, ", ".join(report), 100 * land_on_sea, worst, verdict_hint))
        # 4. lock the coast to the smooth true curve
        land_ok = ~pw & ~water_true
        water_ok = pw & water_true
        # where the painting is on the wrong side of the true coast, fill from the guide (the shader's own land or
        # water at that spot) blended with the painting's local colour, not a blur, so no smear survives
        lf = np.where(land_ok[..., None], paint_, _fill(paint_, guide, land_ok))
        wf = np.where(water_ok[..., None], paint_, _fill(paint_, guide, water_ok))
        a = np.clip(0.5 - sd / (1.5 / px), 0, 1)[..., None]     # a 1.5 px soft edge along the curve
        Image.fromarray((lf * a + wf * (1 - a)).clip(0, 255).astype(np.uint8)).save(os.path.join(d, "lock_%d_%d.png" % (x0, y0)))
    print("\n".join(rows))
    # compare: the old painting, the shader guide, the hybrid, per piece
    old = Image.open(os.path.join(repo, "design/map/continent-11/art/near/upres4/near_24px.png")).convert("RGB") \
        if os.path.exists(os.path.join(repo, "design/map/continent-11/art/near/upres4/near_24px.png")) else None
    pieces = sorted(f for f in os.listdir(d) if f.startswith("lock_"))
    sheet = Image.new("RGB", (3 * 768 + 20, len(pieces) * 432 + (len(pieces) - 1) * 10), (12, 12, 12))
    for i, f in enumerate(pieces):
        x0, y0 = (int(v) for v in re.findall(r"\d+", f))
        g = Image.open(os.path.join(d, "guide_%d_%d.png" % (x0, y0))).convert("RGB")
        o = old.crop((x0 * 24, y0 * 24, x0 * 24 + g.size[0] * 24 // px, y0 * 24 + g.size[1] * 24 // px)) if old else g
        for j, im in enumerate((o, g, Image.open(os.path.join(d, f)))):
            sheet.paste(im.resize((768, 432), Image.LANCZOS), (j * 778, i * 442))
    sheet.save(os.path.join(d, "compare.jpg"), quality=88)
    print(os.path.join(d, "compare.jpg"))


if __name__ == "__main__":
    repo, cmd, d = sys.argv[1], sys.argv[2], sys.argv[3]
    if cmd == "paint":
        paint(repo, d, sys.argv[4] if len(sys.argv) > 4 else "medium")
    elif cmd == "retry":
        repaint_failed(repo, d, float(sys.argv[4]), sys.argv[5] if len(sys.argv) > 5 else "medium")
    else:
        check(repo, d, float(sys.argv[4]))
