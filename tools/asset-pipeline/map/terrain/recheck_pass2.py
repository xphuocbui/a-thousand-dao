"""Re-check the pass-2 pieces that were repainted for colour drift, by the user's rule (2026-11-23: "as long as the
border and the biome is good, it is good for me"): a piece fails only if its land types change, land is painted on the
true sea, or a river breaks. Compares the original (p2_before_repaint/) and the live piece (p2/) of each.

  biome   each piece is split into 8 x 8 cells; in each cell the dominant coarse land class (water, sand, red clay,
          green vegetation, grey rock, snow) of the painting must match the pass-1 input's (cells where neither has a
          clear majority are skipped); fail if more than BIOME_MAX of the cells change class
  coast   share of the true open sea (more than 0.4 tiles off the coast) painted as land; fail above COAST_MAX
  rivers  share of the traced river line painted as water; fail below RIVER_MIN
usage: python -I tools/asset-pipeline/map/terrain/recheck_pass2.py <repo>   -> prints a summary, writes recheck.txt
"""
import json
import os
import sys

import numpy as np
from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
sys.path.insert(0, HERE)
from water_lock import field  # noqa: E402

BIOME_MAX = 0.08
COAST_MAX = 0.03
RIVER_MIN = 0.45
NAMES = ["water", "sand", "red clay", "vegetation", "rock", "snow"]


def classes(a):
    r, g, b = a[..., 0], a[..., 1], a[..., 2]
    mx, mn = a.max(-1), a.min(-1)
    c = np.full(r.shape, 3, np.int8)                                   # vegetation by default
    c[(mx - mn < 26) & (mx < 200)] = 4                                 # grey rock
    c[(r > g + 22) & (r > 110) & (b < g)] = 2                          # red clay / badlands
    c[(r > 165) & (g > 135) & (b < 135) & (r >= g)] = 1                # sand
    c[(mn > 195) & (mx - mn < 30)] = 5                                 # snow / ice
    c[(b > r + 12) & (b > g - 5)] = 0                                  # water
    return c


def cell_classes(c, n=8):
    h, w = c.shape
    out = np.full((n, n), -1, np.int8)
    for j in range(n):
        for i in range(n):
            sub = c[j * h // n:(j + 1) * h // n, i * w // n:(i + 1) * w // n]
            cnt = np.bincount(sub.ravel(), minlength=6)
            if cnt.max() > 0.5 * sub.size:
                out[j, i] = int(cnt.argmax())
    return out


def score(repo, crop, paint_path, src, coast, river):
    pa = np.asarray(Image.open(paint_path).convert("RGB").resize((src.shape[1], src.shape[0])), np.float32)
    a, b = cell_classes(classes(src)), cell_classes(classes(pa))
    both = (a >= 0) & (b >= 0)
    changed = (a != b) & both
    biome = float(changed.sum()) / max(1, int(both.sum()))
    what = sorted({"%s->%s" % (NAMES[x], NAMES[y]) for x, y in zip(a[changed], b[changed])})
    # crop origin: source px at 24 px per tile; the piece is 2x (48 px per tile)
    ox, oy = crop["x"] / 24.0, crop["y"] / 24.0
    h, w = src.shape[:2]
    sd = field((ox, oy), (w, h), 48.0, coast, 0.0)
    pw = classes(pa) == 0
    sea = sd > 0.4
    coast_bad = float((~pw & sea).sum()) / max(1, int(sea.sum()))
    ys = np.clip(((oy + (np.arange(h) + 0.5) / 48) * 8).astype(int), 0, 360 * 8 - 1)
    xs = np.clip(((ox + (np.arange(w) + 0.5) / 48) * 8).astype(int), 0, 540 * 8 - 1)
    line = river[ys[:, None], xs[None, :]] > 160
    if line.sum() < 300:
        rv = 1.0
    else:
        k = np.zeros_like(pw)
        for dy in (-3, 0, 3):
            for dx in (-3, 0, 3):
                k |= np.roll(np.roll(pw | ((pa[..., 2] > pa[..., 0] + 6) & (pa[..., 2] > pa[..., 1] - 15)), dy, 0), dx, 1)
        rv = float((k & line).sum()) / float(line.sum())
    ok = biome <= BIOME_MAX and coast_bad <= COAST_MAX and rv >= RIVER_MIN
    return ok, biome, coast_bad, rv, what


def main(repo):
    base = os.path.join(repo, "design/map/continent-11/art/near/hybrid")
    d, k = os.path.join(base, "p2"), os.path.join(base, "p2_before_repaint")
    plan = {c["id"]: c for c in json.load(open(os.path.join(d, "plan.json")))["crops"]}
    coast = np.fromfile(os.path.join(repo, "assets/map/terrain/coast.bin"), np.float32).reshape(1440, 2160)
    river = np.fromfile(os.path.join(repo, "assets/map/terrain/river.bin"), np.uint8).reshape(2880, 4320)
    rows, n_orig_ok, n_live_ok = [], 0, 0
    for f in sorted(os.listdir(k)):
        if not f.startswith("paint_"):
            continue
        cid = f[6:-4]
        src = np.asarray(Image.open(os.path.join(d, "src_%s.png" % cid)).convert("RGB"), np.float32)
        o = score(repo, plan[cid], os.path.join(k, f), src, coast, river)
        l = score(repo, plan[cid], os.path.join(d, "paint_%s.png" % cid), src, coast, river)
        n_orig_ok += o[0]
        n_live_ok += l[0]
        rows.append("%s original %s (biome changed %.0f %%%s, land on sea %.1f %%, river %.0f %%) | live %s (biome %.0f %%, sea %.1f %%, river %.0f %%)" % (
            cid, "OK  " if o[0] else "FAIL", 100 * o[1], (": " + ", ".join(o[4])) if o[4] else "", 100 * o[2], 100 * o[3],
            "OK" if l[0] else "FAIL", 100 * l[1], 100 * l[2], 100 * l[3]))
    open(os.path.join(base, "recheck.txt"), "w", encoding="utf-8").write("\n".join(rows) + "\n")
    print("re-checked %d pieces by borders and biomes: originals OK %d, live OK %d" % (len(rows), n_orig_ok, n_live_ok))
    print("\n".join(r for r in rows if "original FAIL" in r)[:4000])


if __name__ == "__main__":
    main(sys.argv[1])
