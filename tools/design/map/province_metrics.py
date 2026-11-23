"""Observations on province borders (user, 2026-11-23: "province shapes that follow rivers and ridges"). Prints numbers,
never a verdict (CLAUDE.md: helpers emit observations).

  on_river   share of province border edges (between two tiles of different provinces of one region) with a drawn
             river (assets/map/terrain/river.bin, the lines the game draws) on either side
  on_ridge   share of border edges whose edge is a local high: higher than the land RIDGE_D tiles away on both sides
  crossings  river tiles whose two river neighbours lie in different provinces (a border cutting across a river)
  sizes      land tiles per province: count, median, quartiles

usage: python -I tools/design/map/province_metrics.py [province_ids.png]
"""
import json
import os
import sys

import numpy as np
from PIL import Image

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
RIDGE_D = 3


def river_tiles():
    r = np.fromfile(os.path.join(ROOT, "assets/map/terrain/river.bin"), np.uint8).reshape(2880, 4320)
    return r.reshape(360, 8, 540, 8).max(axis=(1, 3)) > 90


def main(path):
    import provinces as P
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    W, H, L = P.read_grid(os.path.join(ROOT, cont["grid_file"].replace("res://", "")))
    regn = L["REGN"].astype(np.int32)
    elev = L["ELEV"].astype(np.float32)
    pid = np.asarray(Image.open(path)).astype(np.int32)
    rv = river_tiles()
    on_r = on_g = total = 0
    for axis in (0, 1):
        a = pid[:, :-1] if axis == 1 else pid[:-1, :]
        b = pid[:, 1:] if axis == 1 else pid[1:, :]
        ra = regn[:, :-1] if axis == 1 else regn[:-1, :]
        rb = regn[:, 1:] if axis == 1 else regn[1:, :]
        edge = (a > 0) & (b > 0) & (a != b) & (ra == rb)
        va = rv[:, :-1] if axis == 1 else rv[:-1, :]
        vb = rv[:, 1:] if axis == 1 else rv[1:, :]
        ea = elev[:, :-1] if axis == 1 else elev[:-1, :]
        eb = elev[:, 1:] if axis == 1 else elev[1:, :]
        e_edge = np.maximum(ea, eb)
        # the land RIDGE_D tiles away on each side, across the edge
        sh = RIDGE_D
        if axis == 1:
            far_a = np.pad(elev, ((0, 0), (sh, 0)), mode="edge")[:, :W - 1]
            far_b = np.pad(elev, ((0, 0), (0, sh)), mode="edge")[:, sh + 1:]
        else:
            far_a = np.pad(elev, ((sh, 0), (0, 0)), mode="edge")[:H - 1, :]
            far_b = np.pad(elev, ((0, sh), (0, 0)), mode="edge")[sh + 1:, :]
        ridge = (e_edge > far_a + 80) & (e_edge > far_b + 80)
        total += int(edge.sum())
        on_r += int((edge & (va | vb)).sum())
        on_g += int((edge & ridge).sum())
    # crossings: a river tile next to a river tile of another province (same region)
    cross = 0
    for dy, dx in ((0, 1), (1, 0)):
        a = pid[:H - dy, :W - dx]
        b = pid[dy:, dx:]
        ok = rv[:H - dy, :W - dx] & rv[dy:, dx:] & (a > 0) & (b > 0) & (a != b) & (regn[:H - dy, :W - dx] == regn[dy:, dx:])
        cross += int(ok.sum())
    # the share of drawn river tiles that lie on a province border (beside a tile of another province, same region)
    on_border = np.zeros_like(rv)
    for dy, dx in ((0, 1), (0, -1), (1, 0), (-1, 0)):
        sh = np.roll(np.roll(pid, dy, 0), dx, 1)
        shr = np.roll(np.roll(regn, dy, 0), dx, 1)
        on_border |= (sh > 0) & (sh != pid) & (shr == regn)
    rv_land = rv & (pid > 0)
    print("drawn river tiles on a province border: %.1f %% of %d" % (100.0 * (on_border & rv_land).sum() / max(1, rv_land.sum()), rv_land.sum()))
    sizes = np.bincount(pid[pid > 0])[1:]
    sizes = sizes[sizes > 0]
    q = np.percentile(sizes, [25, 50, 75])
    print("provinces %d; tiles per province: median %d (quartiles %d-%d), min %d, max %d" % (
        len(sizes), q[1], q[0], q[2], sizes.min(), sizes.max()))
    print("border edges %d: on a drawn river %.1f %%, on a ridge %.1f %%; river crossings %d" % (
        total, 100.0 * on_r / max(1, total), 100.0 * on_g / max(1, total), cross))


if __name__ == "__main__":
    main(sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "design/map/continent-11/provinces/province_ids.png"))
