"""Terrain textures for the Paradox-style map shader (user, 2026-11-23: the painted near layer did not follow the biome
data, "no deserts, no ice places, overly mountainous"; picked "Paradox-style shader"). One seamless, top-down texture
per biome id (world_continent.json legend.biome_ids), painted by the image model in the style of the existing 4x
painting (ref_00.png, its forest, is the style reference for every biome, so they share one look), then made tileable
by an offset blend.

usage: python -I tools/asset-pipeline/map/terrain/make_textures.py <repo> paint [ids]   (missing ones only)
       python -I tools/asset-pipeline/map/terrain/make_textures.py <repo> tile           -> assets/map/terrain/biome_<id>.png
"""
import os
import subprocess
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
SIDE = 1024
MATERIAL = {
    0: "mixed broadleaf and conifer forest canopy: dense individual tree crowns in deep varied greens",
    1: "dense bamboo forest canopy: bright yellow-green feathery bamboo tops in soft clumps",
    2: "dense tropical jungle canopy: very dark rich green, large varied crowns, a few emergent trees",
    3: "open green grassland and meadow: soft green grass with scattered small shrubs and a few lone trees",
    4: "dry steppe: short olive-tan grass, sparse low grey-green shrubs and small dusty bare patches",
    5: "sand desert: pale golden sand with soft dune ripples and long wind streaks, no plants",
    6: "salt flats: bright white-grey salt crust with faint polygon cracks",
    7: "badlands: eroded rust-red and ochre clay ridges and dry gullies with very sparse dry scrub",
    8: "swamp: dark green marsh with many small pools of still dark water, reeds and moss",
    9: "mangrove forest: dense dark green mangrove canopy cut by thin tidal channels of brown water",
    10: "highland moor: rolling grey-green upland with rocky outcrops, heather and short grass",
    11: "high mountain rock: grey rock ridges, scree slopes and patches of snow, seen from high above",
    12: "karst: closely packed rounded green limestone tower hills with dark narrow gaps between them",
    13: "volcanic ground: black basalt and dark grey ash fields with faint dull red glowing cracks",
    14: "tundra: pale brown-grey lichen and moss, low dark shrubs, small frozen pools and snow patches",
    15: "glacier: white and pale blue ice with faint crevasses and wind-blown snow",
    16: "poisonous miasma marsh: sickly yellow-green bog and black pools under a faint violet haze",
    17: "calm lake water: deep blue-green water with gentle fine ripples",
    18: "open sea seen from high above: deep blue water with fine wind ripples and tiny glints",
}
PROMPT = ("A seamless, tileable, top-down texture for a grand-strategy game's terrain map: {m}. Seen straight down from "
          "high above, covering about four kilometres across, spread evenly over the whole image with no single focal "
          "point, no large landmark, no path or river or road, no buildings, no text, no border, no vignette and no "
          "fade at the edges. Paint it in exactly the same rich, realistic painted style, colour richness and scale "
          "of detail as the reference image (the reference shows forest; tree crowns there are the size of the detail "
          "wanted), with the same soft warm light from the top left.")


def paint(repo, ids):
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    ref = os.path.join(HERE, "ref_00.png")
    procs = []
    for k, m in MATERIAL.items():
        if ids and k not in ids:
            continue
        out = os.path.join(HERE, "paint_%02d.png" % k)
        if os.path.exists(out):
            continue
        pr = os.path.join(HERE, "prompt_%02d.md" % k)
        open(pr, "w", encoding="utf-8").write(PROMPT.format(m=m))
        procs.append(subprocess.Popen([sys.executable, "-I", tool, "gpt-image-2", "medium", "1024x1024", pr, "--", out, ref]))
        if len(procs) >= 6:
            procs.pop(0).wait()
    for p in procs:
        p.wait()


def tileable(img):
    """Offset blend: the image and its half-shifted copy, weighted so every seam of one falls inside the other."""
    a = np.asarray(img.convert("RGB").resize((SIDE, SIDE), Image.LANCZOS)).astype(np.float32)
    b = np.roll(a, (SIDE // 2, SIDE // 2), (0, 1))
    u = np.abs(np.arange(SIDE) - (SIDE - 1) / 2) / (SIDE / 2)       # 0 at the centre, 1 at the edge
    e = np.maximum(u[:, None], u[None, :])
    w = np.clip((e - 0.55) / 0.4, 0, 1)
    w = (w * w * (3 - 2 * w))[..., None]
    return Image.fromarray((a * (1 - w) + b * w).clip(0, 255).astype(np.uint8))


def tile(repo):
    out = os.path.join(repo, "assets/map/terrain")
    os.makedirs(out, exist_ok=True)
    for k in MATERIAL:
        f = os.path.join(HERE, "paint_%02d.png" % k)
        if os.path.exists(f):
            tileable(Image.open(f)).save(os.path.join(out, "biome_%02d.png" % k))
    print("tiled")


if __name__ == "__main__":
    repo, cmd = sys.argv[1], sys.argv[2]
    if cmd == "paint":
        paint(repo, {int(v) for v in sys.argv[3].split(",")} if len(sys.argv) > 3 else set())
    else:
        tile(repo)
