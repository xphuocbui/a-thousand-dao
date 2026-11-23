"""Cut the picked place symbols (style G, user 2026-11-23) from sheet-g.png into assets/map/symbols/<kind>.png:
chroma key, despill, trim, scale so the longest side is 128 px (2x the largest shown size), and a soft brown drop
shadow so the off-white silhouette sits on the painted land. Only built places get a symbol; natural landmarks are
painted into the terrain (user: "the volcano should be rendered together with the terrain").
usage: python -I tools/asset-pipeline/map/symbols/cut_symbols.py <repo>
"""
import os
import sys

import numpy as np
from PIL import Image, ImageFilter

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from make_styles import cut  # noqa: E402

BUILT = ["great_seat", "minor_seat", "city", "town", "market", "village", "mine"]
SIDE = 128
PAD = 10


def main(repo):
    syms = cut(os.path.join(HERE, "sheet-g.png"))
    out = os.path.join(repo, "assets/map/symbols")
    os.makedirs(out, exist_ok=True)
    for k in BUILT:
        sp = syms[k]
        f = (SIDE - 2 * PAD) / max(sp.size)
        sp = sp.resize((max(1, round(sp.size[0] * f)), max(1, round(sp.size[1] * f))), Image.LANCZOS)
        a = np.asarray(sp).astype(np.float32)
        a[..., 3] = np.where(a[..., 3] < 40, 0, a[..., 3])          # drop the faint green-shadow remnants
        sp = Image.fromarray(a.clip(0, 255).astype(np.uint8))
        canvas = Image.new("RGBA", (SIDE, SIDE), (0, 0, 0, 0))
        ox, oy = (SIDE - sp.size[0]) // 2, SIDE - PAD - sp.size[1]  # stand on the bottom: the tile point is the base
        shadow = Image.new("RGBA", (SIDE, SIDE), (0, 0, 0, 0))
        sh = Image.new("RGBA", sp.size, (40, 26, 14, 0))
        sh.putalpha(sp.getchannel("A").point(lambda v: int(v * 0.55)))
        shadow.alpha_composite(sh, (ox + 3, oy + 4))
        shadow = shadow.filter(ImageFilter.GaussianBlur(3))
        canvas.alpha_composite(shadow)
        canvas.alpha_composite(sp, (ox, oy))
        canvas.save(os.path.join(out, "%s.png" % k))
        print(k, sp.size)


if __name__ == "__main__":
    main(sys.argv[1])
