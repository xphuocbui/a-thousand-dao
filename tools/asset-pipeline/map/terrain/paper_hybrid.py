"""The paper-map style at every zoom (user, 2026-11-23: the photo-like near terrain "has this old game map vibe"; "the
old zoom out map style was pretty good. But it was missing some biomes"): the old hand-drawn paper map's style
(style_ref.png, a crop of it) over a guide drawn from the game's data (paper_from_near.py at 16 px per tile: biome
washes, relief, ink coast on the true coast). The image model redraws each piece as the illustrated map, keeping every
coast, lake, river and land-type area of the guide; the game draws the water.

usage: python -I paper_hybrid.py <repo> paint <dir> [quality]   guide_*.png -> paint_*.png (two images: guide, style)
"""
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
PROMPT = """The FIRST image is a plan of a tile of a fantasy strategy game's campaign map, drawn from the game's data, seen straight down. The SECOND image is the art style to use. Redraw the first image as a finished hand-drawn campaign map on aged parchment in EXACTLY the style of the second image: fine brown-black ink linework, soft watercolour washes, small inked symbols.

KEEP EVERY COASTLINE, LAKE, RIVER AND LAND-TYPE AREA EXACTLY WHERE IT IS IN THE FIRST IMAGE, at the same size; it is real game data. Each land colour in the plan becomes its own illustrated symbols, like the style image:
- green = forest: clusters of small round inked tree symbols, dense where the green is dark;
- light green = grassland: light green wash with sparse tufts and a few small trees;
- ochre / olive = dry steppe: pale ochre wash with sparse grass tufts, no trees;
- pale sand = sand desert: pale sand wash with fine curved dune strokes, no plants;
- rust = badlands: rust-red wash with small eroded ridge marks;
- grey-brown with relief = mountains: rows of small inked mountain peaks with snowy tops, like the style image, only where the plan shows them;
- pale grey-cream = tundra: pale wash with tiny sparse tufts and frost dots;
- white = glacier and snow: white with faint blue ink hatching;
- dark grey = volcanic: a dark inked cone.
Water stays a pale blue-grey wash with a few hand-drawn wave marks, and every river is one continuous fine blue ink line.

Never: text, letters, names, labels, numbers, a compass, a legend, borders, region colours, frames, buildings, roads, ships, people, new islands or features, or any fade or vignette at the edges. The drawing must reach every edge of the image."""


def paint(repo, d, quality):
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    style = os.path.join(repo, "design/map/continent-11/art/paper/style_ref.png")
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
        own = os.path.join(d, "prompt_%s_%s.md" % m.groups())
        procs.append(subprocess.Popen([sys.executable, "-I", tool, "gpt-image-2", quality, "1536x864",
                                       own if os.path.exists(own) else pr, "--", out, os.path.join(d, f), style]))
        if len(procs) >= 6:
            procs.pop(0).wait()
    for p in procs:
        p.wait()


if __name__ == "__main__":
    repo, cmd, d = sys.argv[1], sys.argv[2], sys.argv[3]
    if cmd == "paint":
        paint(repo, d, sys.argv[4] if len(sys.argv) > 4 else "low")
