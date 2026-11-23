"""The hybrid near terrain for the whole map (user, 2026-11-23: "Ok recharged, now go"), pass 1 at 24 px per tile.

guide_24px.png (the shader's render of the true data, render_guide.gd, guide mode) is cut into overlapping 64 x 36 tile
pieces (1536 x 864, stepping about 53 x 30 tiles). Each piece is painted by the image model (hybrid.PROMPT), then
checked against the data: biome colour drift (hybrid's measure) and rivers (the traced river lines must come back as
water); a failing piece is repainted, up to 3 times, keeping the best. Each piece is then locked to the true coast
(hybrid's lock, filling from the guide), and the pieces are feather-blended into near_24px.png with a light colour
match to the guide so neighbours agree.

usage: python -I hybrid_full.py <repo> plan | paint | check | stitch | all
Files: design/map/continent-11/art/near/hybrid/ (guide_24px.png, pieces/, near_24px.png, report.txt).
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
sys.path.insert(0, os.path.dirname(HERE))
import hybrid as HY  # noqa: E402
from paint_tiles import match_colour  # noqa: E402
from water_lock import field  # noqa: E402

PX = 24
PIECE = (64, 36)           # tiles
GRID = (540, 360)
LIMIT = 32.0               # biome colour drift that fails a piece
RIVER_MIN = 0.45           # share of traced-river pixels that must come back as water
TRIES = 3
RAMP = 200                 # feather, px
DEEP_FROM = 0.6            # tiles off the true coast where the clean deep water starts to take over
DEEP_FULL = 1.6            # and has fully taken over
OFFSHORE = np.array([14, 72, 112], np.float32)   # the open-sea colour, from the painted pieces' water 1-2 tiles off shore
SHELF_CONTRAST = 0.35      # how much of the guide's shallow-shelf brightening survives offshore
GUIDE_DEEP = np.array([18, 66, 116], np.float32)  # the guide's deep-sea colour (canvas_map_terrain deep_col), re-toned to OFFSHORE


def root(repo):
    return os.path.join(repo, "design/map/continent-11/art/near/hybrid")


def pieces():
    xs = [round(i * (GRID[0] - PIECE[0]) / 9) for i in range(10)]
    ys = [round(j * (GRID[1] - PIECE[1]) / 11) for j in range(12)]
    return [(x, y) for y in ys for x in xs]


def plan(repo):
    d = os.path.join(root(repo), "pieces")
    os.makedirs(d, exist_ok=True)
    g = Image.open(os.path.join(root(repo), "guide_24px.png")).convert("RGB")
    for x, y in pieces():
        f = os.path.join(d, "guide_%d_%d.png" % (x, y))
        if not os.path.exists(f):
            g.crop((x * PX, y * PX, (x + PIECE[0]) * PX, (y + PIECE[1]) * PX)).save(f)
    print("pieces", len(pieces()))


def river_score(repo, x0, y0, paint_):
    """Share of the traced river line (river.bin, 2x fine) inside the piece that the painting shows as water."""
    r = np.fromfile(os.path.join(repo, "assets/map/terrain/river.bin"), np.uint8).reshape(GRID[1] * 8, GRID[0] * 8)
    h, w = paint_.shape[:2]
    ys = np.clip(((y0 + (np.arange(h) + 0.5) / PX) * 8).astype(int), 0, GRID[1] * 8 - 1)
    xs = np.clip(((x0 + (np.arange(w) + 0.5) / PX) * 8).astype(int), 0, GRID[0] * 8 - 1)
    line = r[ys[:, None], xs[None, :]] > 160
    if line.sum() < 200:
        return 1.0
    b, g, rr = paint_[..., 2], paint_[..., 1], paint_[..., 0]
    watery = (b > rr + 8) & (b > g - 12)
    # a river 1-2 px off its line still counts: look in a 3 x 3 neighbourhood
    k = np.zeros_like(watery)
    for dy in (-2, 0, 2):
        for dx in (-2, 0, 2):
            k |= np.roll(np.roll(watery, dy, 0), dx, 1)
    return float((k & line).sum()) / float(line.sum())


LOOK = {0: "forest", 1: "bamboo forest", 2: "jungle", 3: "green grassland and meadows", 4: "dry olive steppe",
        5: "bare sand desert", 6: "white salt flats", 7: "red badlands", 8: "swamp", 9: "mangrove", 10: "rocky highland moor",
        11: "high mountains", 12: "karst tower hills", 13: "black volcanic rock", 14: "pale tundra", 15: "glacier ice",
        16: "miasma bog"}


def contents(repo, x0, y0):
    """What the data puts in the piece: each land type's share and where (thirds of the image)."""
    biome = HY.load_bin(repo, "biome.bin", np.uint8)
    sub = biome[y0 * 4:(y0 + PIECE[1]) * 4, x0 * 4:(x0 + PIECE[0]) * 4]
    land = ~np.isin(sub, (17, 18))
    parts = []
    if land.mean() < 0.02:
        return "This piece is open sea only."
    hh, ww = sub.shape
    for b in np.unique(sub[land]):
        m = sub == b
        share = m.sum() / max(1, land.sum())
        if share < 0.03:
            continue
        ys, xs = np.nonzero(m)
        cy, cx = ys.mean() / hh, xs.mean() / ww
        where = ("top" if cy < 0.34 else "bottom" if cy > 0.66 else "middle") + "-" + ("left" if cx < 0.34 else "right" if cx > 0.66 else "centre")
        spread = "spread across the piece" if ys.std() / hh > 0.25 and xs.std() / ww > 0.25 else "mostly " + where
        parts.append((share, "%s about %d %% (%s)" % (LOOK.get(int(b), "land"), round(100 * share), spread)))
    parts.sort(reverse=True)
    sea = 1 - land.mean()
    txt = "This piece holds, by the game's data: " + "; ".join(p for _, p in parts) + "."
    if sea > 0.05:
        txt += " About %d %% of it is water." % round(100 * sea)
    absent = [LOOK[k] for k in (5, 7, 11, 0) if k not in np.unique(sub[land])]
    if absent:
        txt += " There is NO " + ", NO ".join(absent) + " anywhere in this piece: do not paint any."
    return txt


def write_prompt(repo, x0, y0, note=""):
    d = os.path.join(root(repo), "pieces")
    text = HY.PROMPT + "\n\n" + contents(repo, x0, y0) + ("\n" + note if note else "")
    open(os.path.join(d, "prompt_%d_%d.md" % (x0, y0)), "w", encoding="utf-8").write(text)


def check_all(repo):
    d = os.path.join(root(repo), "pieces")
    base = HY.score_all(repo, d, PX)
    out = []
    for x0, y0, worst, los in base:
        pa = np.asarray(Image.open(os.path.join(d, "paint_%d_%d.png" % (x0, y0))).convert("RGB").resize((PIECE[0] * PX, PIECE[1] * PX), Image.LANCZOS)).astype(np.float32)
        rv = river_score(repo, x0, y0, pa)
        out.append((x0, y0, worst, los, rv))
    return out


def paint_and_retry(repo, quality="medium"):
    d = os.path.join(root(repo), "pieces")
    for x0, y0 in pieces():   # every piece gets its own prompt from the data (unpainted ones use it at once)
        write_prompt(repo, x0, y0)
    HY.paint(repo, d, quality)
    for attempt in range(TRIES):
        rows = check_all(repo)
        bad = [r for r in rows if r[2] > LIMIT or r[4] < RIVER_MIN]
        log = "attempt %d: %d of %d pieces fail (drift > %.0f or river < %.0f %%)" % (attempt, len(bad), len(rows), LIMIT, RIVER_MIN * 100)
        print(log, flush=True)
        if not bad:
            break
        for x0, y0, worst, los, rv in bad:
            f = os.path.join(d, "paint_%d_%d.png" % (x0, y0))
            keep = os.path.join(d, "best_%d_%d.png" % (x0, y0))
            score = worst + (0 if rv >= RIVER_MIN else 40.0 * (RIVER_MIN - rv) / RIVER_MIN)
            prev = json.load(open(keep + ".json")) if os.path.exists(keep + ".json") else None
            if prev is None or score < prev["score"]:
                Image.open(f).save(keep)
                json.dump({"score": score, "worst": worst, "river": rv}, open(keep + ".json", "w"))
            os.remove(f)
            note = []
            if worst > LIMIT:
                note.append("The last attempt drifted from the data (colours of the land types changed); keep each land "
                            "type's colour and extent exactly as the input shows it.")
            if rv < RIVER_MIN:
                note.append("The last attempt broke or lost the rivers: every river in the input must stay one continuous "
                            "line of water from source to mouth.")
            write_prompt(repo, x0, y0, " ".join(note))
        HY.paint(repo, d, quality)
    # the best attempt of each piece stays
    rows = check_all(repo)
    for x0, y0, worst, los, rv in rows:
        keep = os.path.join(d, "best_%d_%d.png" % (x0, y0))
        score = worst + (0 if rv >= RIVER_MIN else 40.0 * (RIVER_MIN - rv) / RIVER_MIN)
        if os.path.exists(keep + ".json") and json.load(open(keep + ".json"))["score"] < score:
            Image.open(keep).save(os.path.join(d, "paint_%d_%d.png" % (x0, y0)))
    rows = check_all(repo)
    with open(os.path.join(root(repo), "report.txt"), "w", encoding="utf-8") as f:
        for x0, y0, worst, los, rv in rows:
            f.write("piece %d,%d drift %.0f land-on-open-water %.1f %% river %.0f %%%s\n" % (
                x0, y0, worst, 100 * los, 100 * rv, "  FAIL" if worst > LIMIT or rv < RIVER_MIN else ""))
    fails = sum(1 for r in rows if r[2] > LIMIT or r[4] < RIVER_MIN)
    print("final: %d of %d pieces still over a limit (kept the best attempt); report.txt" % (fails, len(rows)))


def lock_image(repo, pa, guide, origin, px, retone=True, deep=True):
    """Locks painted image [param pa] (H x W x 3 float) to the true coast at [param px] px per tile, top-left tile
    [param origin]: land past the coast and water past it are refilled from the guide (re-toned to the painting), open
    sea beyond DEEP_FROM is the guide's clean water at the one OFFSHORE colour. Returns float."""
    coast = HY.load_bin(repo, "coast.bin", np.float32)
    h, w = pa.shape[:2]
    sd = field(origin, (w, h), px, coast, 0.0)
    water_true = sd > 0.0
    pw = (pa[..., 2] > pa[..., 0] + 12) & (pa[..., 2] > pa[..., 1] - 5)
    land_ok = ~pw & ~water_true
    water_ok = pw & water_true
    lf = np.where(land_ok[..., None], pa, HY._fill(pa, guide, land_ok))
    wf = np.where(water_ok[..., None], pa, HY._fill(pa, guide, water_ok))
    deep_water = np.clip(guide * (OFFSHORE / GUIDE_DEEP), 0, 255)
    deep_water = OFFSHORE + (deep_water - OFFSHORE) * SHELF_CONTRAST
    k = np.clip((sd - DEEP_FROM) / (DEEP_FULL - DEEP_FROM), 0, 1)[..., None]
    k = k * k * (3 - 2 * k) * (1.0 if deep else 0.0)   # deep=False: the game draws the water (paper map)
    wf = wf * (1 - k) + deep_water * k
    a = np.clip(0.5 - sd / (1.5 / px), 0, 1)[..., None]
    out = lf * a + wf * (1 - a)
    return match_colour(out, guide, 0.35).astype(np.float32) if retone else out.astype(np.float32)


def lock_piece(repo, x0, y0):
    """hybrid's coast lock for one piece, returning the locked image (float)."""
    d = os.path.join(root(repo), "pieces")
    coast = HY.load_bin(repo, "coast.bin", np.float32)
    guide = np.asarray(Image.open(os.path.join(d, "guide_%d_%d.png" % (x0, y0))).convert("RGB")).astype(np.float32)
    h, w = guide.shape[:2]
    pa = np.asarray(Image.open(os.path.join(d, "paint_%d_%d.png" % (x0, y0))).convert("RGB").resize((w, h), Image.LANCZOS)).astype(np.float32)
    sd = field((x0, y0), (w, h), PX, coast, 0.0)
    water_true = sd > 0.0
    pw = (pa[..., 2] > pa[..., 0] + 12) & (pa[..., 2] > pa[..., 1] - 5)
    land_ok = ~pw & ~water_true
    water_ok = pw & water_true
    lf = np.where(land_ok[..., None], pa, HY._fill(pa, guide, land_ok))
    wf = np.where(water_ok[..., None], pa, HY._fill(pa, guide, water_ok))
    # open sea: beyond DEEP_FROM tiles from the true coast the sea is the guide's clean water, re-toned to the painted
    # offshore colour (all-sea pieces came back with land, ice and cloud smears in empty ocean); blended to DEEP_FULL
    target = OFFSHORE   # one colour for the open sea everywhere (per-piece colours showed as blocks)
    deep_water = np.clip(guide * (np.asarray(target, np.float32) / GUIDE_DEEP), 0, 255)   # the guide's depth shading,
    deep_water = OFFSHORE + (deep_water - OFFSHORE) * SHELF_CONTRAST                     # kept faint: a shelf, not a halo
    k = np.clip((sd - DEEP_FROM) / (DEEP_FULL - DEEP_FROM), 0, 1)[..., None]
    k = k * k * (3 - 2 * k)
    wf = wf * (1 - k) + deep_water * k
    a = np.clip(0.5 - sd / (1.5 / PX), 0, 1)[..., None]
    out = lf * a + wf * (1 - a)
    # a light pull toward the guide's colours so neighbouring pieces agree (0.35: keeps the painting's own colour)
    return match_colour(out, guide, 0.35).astype(np.float32)


def stitch(repo):
    W, H = GRID[0] * PX, GRID[1] * PX
    acc = np.asarray(Image.open(os.path.join(root(repo), "guide_24px.png")).convert("RGB"), np.float32) * 1e-3
    wt = np.full((H, W, 1), 1e-3, np.float32)
    pw, ph = PIECE[0] * PX, PIECE[1] * PX
    wx = np.minimum(1.0, np.minimum(np.arange(pw) + 1, pw - np.arange(pw)) / RAMP).astype(np.float32)
    wy = np.minimum(1.0, np.minimum(np.arange(ph) + 1, ph - np.arange(ph)) / RAMP).astype(np.float32)
    mask = (wy[:, None] * wx[None, :])[..., None]
    for x0, y0 in pieces():
        if not os.path.exists(os.path.join(root(repo), "pieces", "paint_%d_%d.png" % (x0, y0))):
            print("missing", x0, y0)
            continue
        img = lock_piece(repo, x0, y0)
        m = mask.copy()
        if x0 == 0:
            m[:, :RAMP] = np.maximum(m[:, :RAMP], wy[:, None, None])
        if y0 == 0:
            m[:RAMP, :] = np.maximum(m[:RAMP, :], wx[None, :, None])
        if x0 + PIECE[0] >= GRID[0]:
            m[:, -RAMP:] = np.maximum(m[:, -RAMP:], wy[:, None, None])
        if y0 + PIECE[1] >= GRID[1]:
            m[-RAMP:, :] = np.maximum(m[-RAMP:, :], wx[None, :, None])
        px0, py0 = x0 * PX, y0 * PX
        acc[py0:py0 + ph, px0:px0 + pw] += img * m
        wt[py0:py0 + ph, px0:px0 + pw] += m
    out = Image.fromarray((acc / wt).clip(0, 255).astype(np.uint8))
    out.save(os.path.join(root(repo), "near_24px.png"))
    out.resize((1620, 1080), Image.LANCZOS).save(os.path.join(root(repo), "near_24px_preview.jpg"), quality=88)
    print("stitched", out.size)


if __name__ == "__main__":
    repo, cmd = sys.argv[1], sys.argv[2]
    if cmd in ("plan", "all"):
        plan(repo)
    if cmd in ("paint", "all"):
        paint_and_retry(repo)
    if cmd == "check":
        for r in check_all(repo):
            print(r)
    if cmd in ("stitch", "all"):
        stitch(repo)
