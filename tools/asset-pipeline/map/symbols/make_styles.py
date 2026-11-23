"""Place-symbol style trials (user, 2026-11-23: "Let's try out some styles so i could see first"): one 12-symbol sheet
per style on chroma green (same subjects and grid), then every style cut and placed on the same 4x test terrain at
true screen size, in one labelled comparison sheet.

usage: python -I make_styles.py <repo> paint [styles]   one sheet per style not yet painted (gpt-image-2, medium)
       python -I make_styles.py <repo> compare          cuts the sheets and writes the comparison
Sheets: tools/asset-pipeline/map/symbols/sheet-<style>.png; the comparison:
production/qa/evidence/map-upres-test/9-symbol-styles.png.
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFont

Image.MAX_IMAGE_PIXELS = None
HERE = os.path.dirname(os.path.abspath(__file__))

GRID = """Paint 12 small map symbols for a grand-strategy game set in an ancient East Asian cultivation (xianxia) world, in an exact grid of 4 columns and 3 rows, evenly spaced, all about the same size (each about 18 % of the canvas width across), on flat pure chroma green (#00FF00) with clear green space between them. Every symbol must read clearly when shown very small (about 40 pixels). No text, letters, characters, seals, banners with writing or numbers anywhere.

Row 1, left to right: (1) a great sect seat: a tall many-tiered pagoda among halls on a mountain; (2) a minor sect: a single three-tier pagoda with a courtyard wall; (3) a city: a walled city with a gatehouse and roofs; (4) a town: a cluster of tiled houses with a low wall.
Row 2: (5) a market town: stalls with awnings and a bridge; (6) a village: four thatched farmhouses; (7) a mine: a timber mine head in a rock face with a cart; (8) a mountain peak landmark: a stone shrine on a sharp peak.
Row 3: (9) a lake landmark: a pavilion on stilts over water; (10) an island landmark: a lighthouse tower on a rock; (11) a forest landmark: a giant ancient spirit tree; (12) a volcano landmark: a smoking cone with a glowing crater.

Style: """

STYLES = {
    "c": ("C: 3D strategy model", "polished 3D-rendered miniature models like the holdings on a modern Paradox grand-strategy map (Crusader Kings 3): clean physically based materials, soft studio light from the top left, gentle ambient occlusion, a soft round contact shadow, seen from a steep three-quarter angle, realistic proportions, restrained natural colours."),
    "d": ("D: ink wash", "Chinese ink-wash painting (shuimo): loose confident black and grey brush strokes on the green, a few soft washes of muted colour (indigo roofs, ochre walls, a touch of vermilion), elegant and sparse, drawn in a gentle three-quarter view, like the vignettes on a classical painted scroll map."),
    "e": ("E: gold medallion", "each subject as a small round emblem: a thin gilded bronze ring with a dark lacquer centre, the subject painted inside in warm light, like a strategy game's map icon or a seal token; the ring is the same on all twelve."),
    "f": ("F: woodblock print", "an Edo or Ming woodblock print: bold flat colour areas (indigo, rust, sage, cream), crisp black carved outlines, slight paper grain, a gentle three-quarter view, graphic and decorative."),
    "g": ("G: bold silhouette", "a clean game map marker: a bold simplified silhouette of the subject in a warm off-white with a dark brown outline and a soft drop shadow, flat with one light shade, maximum readability at tiny sizes, like a modern strategy game's settlement icon."),
    "h": ("H: chibi diorama", "a cute stylised diorama in the manner of a cozy mobile strategy game: chunky rounded shapes, slightly oversized roofs, bright but harmonious colours, soft toon shading, each on a small rounded patch of grass or rock."),
}
KINDS = ["great_seat", "minor_seat", "city", "town", "market", "village", "mine", "peak", "lake", "island", "forest",
         "volcano"]
PXS = {"great_seat": 64, "minor_seat": 54, "city": 58, "town": 46, "market": 44, "village": 34, "mine": 36, "peak": 40,
       "lake": 40, "island": 40, "forest": 42, "volcano": 44}
LABELS = {"a": "A: painted miniature", "b": "B: illustrated emblem"}


def paint(repo, which):
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    green = os.path.join(HERE, "green.png")
    procs = []
    for k, (_label, style) in STYLES.items():
        if which and k not in which:
            continue
        out = os.path.join(HERE, "sheet-%s.png" % k)
        if os.path.exists(out):
            continue
        prompt = os.path.join(HERE, "prompt-%s.md" % k)
        open(prompt, "w", encoding="utf-8").write(GRID + style + "\n")
        procs.append(subprocess.Popen([sys.executable, "-I", tool, "gpt-image-2", "medium", "1536x1024", prompt, "--",
                                       out, green]))
    for p in procs:
        p.wait()


def cut(sheet):
    a = np.asarray(Image.open(sheet).convert("RGB")).astype(np.float32)
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    key = g - np.maximum(r, b)
    alpha = np.clip(1 - (key - 40) / 60, 0, 1)
    a[..., 1] = g - np.maximum(0, key) * (alpha < 1) * 0.9   # despill the green fringe
    rgba = np.dstack([a, alpha * 255]).clip(0, 255).astype(np.uint8)
    H, W = alpha.shape
    out = {}
    for j in range(3):
        for i in range(4):
            c = rgba[j * H // 3:(j + 1) * H // 3, i * W // 4:(i + 1) * W // 4]
            ys, xs = np.nonzero(c[..., 3] > 20)
            out[KINDS[j * 4 + i]] = Image.fromarray(c[ys.min():ys.max() + 1, xs.min():xs.max() + 1]) if len(ys) else None
    return out


def compare(repo):
    pl = json.load(open(os.path.join(repo, "design/map/continent-11/places.json"), encoding="utf-8"))
    pl = pl["places"] if isinstance(pl, dict) else pl
    x0, y0 = 310, 92                      # the test area's top-left tile (near_upres p2_test)
    view_t = (310, 92, 406, 146)           # the shown view, tiles: the whole test area (96 x 54 at 12 px)
    ppt = 12
    base = Image.open(os.path.join(repo, "design/map/continent-11/art/near/upres4/p2_test.png")).convert("RGBA")
    bx = tuple(int(v) for v in ((view_t[0] - x0) * 48, (view_t[1] - y0) * 48, (view_t[2] - x0) * 48, (view_t[3] - y0) * 48))
    terrain = base.crop(bx).resize(((view_t[2] - view_t[0]) * ppt, (view_t[3] - view_t[1]) * ppt), Image.LANCZOS)
    inside = [p for p in pl if view_t[0] <= p["tile"][0] < view_t[2] and view_t[1] <= p["tile"][1] < view_t[3]]
    # every kind shows once in a strip under the view, so styles can be compared on all twelve subjects
    styles = ["a", "b"] + list(STYLES)
    cells = []
    font = ImageFont.load_default(size=22) if hasattr(ImageFont, "load_default") else None
    for s in styles:
        sheet = os.path.join(HERE, "sheet-%s.png" % s)
        if not os.path.exists(sheet):
            continue
        syms = cut(sheet)
        v = terrain.copy()
        for p in sorted(inside, key=lambda p: p["tile"][1]):
            sp = syms.get(p["kind"]) or syms["town"]
            side = PXS.get(p["kind"], 40)
            f = side / max(sp.size)
            sp = sp.resize((max(1, int(sp.size[0] * f)), max(1, int(sp.size[1] * f))), Image.LANCZOS)
            cx, cy = (p["tile"][0] - view_t[0] + 0.5) * ppt, (p["tile"][1] - view_t[1] + 0.5) * ppt
            v.alpha_composite(sp, (int(cx - sp.size[0] / 2), int(cy - sp.size[1] * 0.75)))
        strip = Image.new("RGBA", (v.size[0], 92), (34, 30, 26, 255))
        for i, k in enumerate(KINDS):
            sp = syms.get(k)
            if sp is None:
                continue
            f = 48 / max(sp.size)
            sp = sp.resize((max(1, int(sp.size[0] * f)), max(1, int(sp.size[1] * f))), Image.LANCZOS)
            strip.alpha_composite(sp, (8 + i * 52 + (48 - sp.size[0]) // 2, 40 + (48 - sp.size[1]) // 2))
        cell = Image.new("RGB", (v.size[0], v.size[1] + 92), (34, 30, 26))
        cell.paste(v.convert("RGB"), (0, 0))
        cell.paste(strip.convert("RGB"), (0, v.size[1]))
        ImageDraw.Draw(cell).text((10, v.size[1] + 8), LABELS.get(s) or STYLES[s][0], fill=(240, 225, 190), font=font)
        cells.append(cell)
    cols = 2
    w, h = cells[0].size
    out = Image.new("RGB", (cols * w + (cols - 1) * 12, ((len(cells) + 1) // cols) * (h + 12)), (16, 14, 12))
    for i, c in enumerate(cells):
        out.paste(c, ((i % cols) * (w + 12), (i // cols) * (h + 12)))
    dest = os.path.join(repo, "production/qa/evidence/map-upres-test/9-symbol-styles.png")
    out.save(dest)
    print(dest, out.size, len(cells), "styles,", len(inside), "places in the view")


if __name__ == "__main__":
    repo, cmd = sys.argv[1], sys.argv[2]
    if cmd == "paint":
        paint(repo, set(sys.argv[3].split(",")) if len(sys.argv) > 3 else set())
    else:
        compare(repo)
