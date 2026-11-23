"""Place art for the near map (production/plans/overnight-2026-11-22.md step 7): each place is painted INTO its own
patch of the finished near layer, so terrain, light and scale match the map exactly (the user: "make sure the asset
fits into the map"). The image model gets the painted terrain around the place's tile and the place's art brief from
the catalogue; a soft-edged patch around the place is cut out and saved as a sprite the engine draws on the place's
tile (so a level or a project stage can swap it later).

usage:
  python -I place_art.py plan  <repo>                       crop inputs + prompts for every place
  python -I place_art.py paint <repo> <quality> [ids|kinds] paint places not yet done (ids "1,5,41" or kinds "city,town")
  python -I place_art.py cut   <repo>                       cut every painted place into its sprite and write the manifest

Files: design/map/continent-11/art/places/in_<id>.png (input), prompt_<id>.md, paint_<id>.png (output);
assets/map/places/place_<id>.png (the sprite) and assets/map/places/manifest.json (each sprite's tile and size in
tiles). Reads assets/map/map_near_relief.jpg (12 px per tile) and design/world/place_catalogue.json.
"""
import json
import os
import subprocess
import sys

import numpy as np
from PIL import Image

PX = 12                 # near layer px per tile
VIEW = (40, 22.5)       # tiles shown around the place in the input (16:9)
# patch radius in tiles by kind (how much land the miniature may claim)
RADIUS = {"great_seat": 5.0, "city": 4.5, "minor_seat": 4.0, "market": 3.5, "town": 3.5, "village": 2.5, "ruin": 3.0,
          "mine": 2.5, "peak": 3.5, "volcano": 4.0, "lake": 3.5, "island": 3.5, "forest": 3.5, "gorge": 3.5,
          "spirit_vein": 3.0, "beast_lair": 2.8, "hot_spring": 2.5, "lava_vent": 2.8, "lightning_wood": 3.0}
SHAPE = {
    "great_seat": "a great sect's seat: vertical, stacked pagoda roofs and terraces climbing the slope, the tallest outline in the land, walls and gates, a main hall",
    "minor_seat": "a minor sect's seat: a compact walled compound of halls and one tall pagoda or tower, terraces where the land climbs",
    "city": "a walled city: a rectangular wall with gate towers, dense grey-tile roofs inside, a central tower or palace, a market square, suburbs along the roads outside the walls",
    "town": "a town: a low cluster of grey-tile roofs inside a modest rectangular wall or palisade, one larger hall or temple",
    "market": "a market town: a low cluster of roofs around a big open market square full of awnings, warehouses at the edge",
    "village": "a small village: a handful of low houses with grey or thatch roofs, gardens and fields close around it",
    "ruin": "a ruin: broken walls, toppled pillars and roofless halls overgrown by the land, no smoke, no life",
    "mine": "a mine: a dark adit in the hillside, spoil heaps, timber headframes and a few workers' huts",
}


def load_json(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def art_dir(repo):
    return os.path.join(repo, "design/map/continent-11/art/places")


def plan(repo):
    near = Image.open(os.path.join(repo, "assets/map/map_near_relief.jpg")).convert("RGB")
    cont = load_json(os.path.join(repo, "assets/data/world_continent.json"))
    cat = {e["id"]: e for e in load_json(os.path.join(repo, "design/world/place_catalogue.json"))["places"]}
    d = art_dir(repo)
    os.makedirs(d, exist_ok=True)
    base = open(os.path.join(repo, "tools/asset-pipeline/map/prompts/place-base.md"), encoding="utf-8").read()
    rows = []
    for p in cont["places"]:
        pid, kind = p["id"], p["kind"]
        tx, ty = p["tile"]
        cx, cy = (tx + 0.5) * PX, (ty + 0.5) * PX
        w, h = VIEW[0] * PX, VIEW[1] * PX
        x0, y0 = int(round(cx - w / 2)), int(round(cy - h / 2))
        crop = near.crop((x0, y0, x0 + int(w), y0 + int(h))).resize((1536, 864), Image.BICUBIC)
        crop.save(os.path.join(d, "in_%d.png" % pid))
        e = cat.get(pid, {})
        r = RADIUS.get(kind, 3.0)
        shape = SHAPE.get(kind, "a natural site: the natural feature leads, with at most a small shrine or marker; no rooflines")
        text = base.format(name=p["name"], kind=kind.replace("_", " "), shape=shape, look=e.get("look", ""),
                           brief=e.get("art_brief", ""), radius_share=int(round(100 * 2 * r / VIEW[0])))
        with open(os.path.join(d, "prompt_%d.md" % pid), "w", encoding="utf-8") as f:
            f.write(text)
        rows.append({"id": pid, "kind": kind, "tile": [tx, ty], "radius_tiles": r, "origin_px": [x0, y0]})
    with open(os.path.join(d, "plan.json"), "w", encoding="utf-8") as f:
        json.dump({"px": PX, "view_tiles": VIEW, "places": rows}, f, indent=1)
    print("planned %d places" % len(rows))


def paint(repo, quality, sel):
    d = art_dir(repo)
    rows = load_json(os.path.join(d, "plan.json"))["places"]
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    jobs = []
    for r in rows:
        if sel and str(r["id"]) not in sel and r["kind"] not in sel:
            continue
        out = os.path.join(d, "paint_%d.png" % r["id"])
        if os.path.exists(out):
            continue
        jobs.append([sys.executable, "-I", tool, "gpt-image-2", quality, "1536x864", os.path.join(d, "prompt_%d.md" % r["id"]),
                     "--", out, os.path.join(d, "in_%d.png" % r["id"])])
    from concurrent.futures import ThreadPoolExecutor   # four requests at once (each waits on the network)
    with ThreadPoolExecutor(max_workers=int(os.environ.get("PAINT_WORKERS", "4"))) as pool:
        list(pool.map(lambda cmd: subprocess.run(cmd, check=False), jobs))
    print("painted %d" % len(jobs))


def patch(src, radius_tiles):
    """The soft-edged patch of a place painting: an RGBA array cut around the centre (radius in tiles, the outer third
    fading out) and its export size in px (2x the near layer)."""
    img = np.asarray(Image.open(src).convert("RGB")).astype(np.float32)
    h, w = img.shape[:2]
    scale = w / (VIEW[0] * PX)            # model px per near px
    rad = radius_tiles * PX * scale       # patch radius in model px
    cx, cy = w / 2.0, h / 2.0
    yy, xx = np.mgrid[0:h, 0:w]
    dist = np.hypot(xx - cx, yy - cy) / rad
    alpha = np.clip((1.0 - dist) / 0.35, 0.0, 1.0) ** 1.5   # soft edge over the outer third
    side = int(np.ceil(rad * 2))
    box = (int(cx - side / 2), int(cy - side / 2), int(cx + side / 2), int(cy + side / 2))
    return np.dstack([img, alpha * 255.0])[box[1]:box[3], box[0]:box[2]], int(round(2 * radius_tiles * PX * 2))


def fitted_radius(paint_path, input_path, default_tiles):
    """The patch radius in tiles that covers what the model changed around the centre (the place it painted):
    the 97th percentile distance of strongly changed pixels within 40 % of the width, plus a 0.8-tile margin, clamped
    between 0.8 x the kind's default and 9 tiles (a big port city with its harbour reaches about 8)."""
    from PIL import ImageFilter
    a = Image.open(paint_path).convert("RGB")
    b = Image.open(input_path).convert("RGB").resize(a.size)
    d = np.abs(np.asarray(a).astype(np.float32) - np.asarray(b).astype(np.float32)).mean(axis=2)
    d = np.asarray(Image.fromarray(np.clip(d, 0, 255).astype(np.uint8)).filter(ImageFilter.GaussianBlur(12))).astype(np.float32)
    h, w = d.shape
    yy, xx = np.mgrid[0:h, 0:w]
    r = np.hypot(xx - w / 2.0, yy - h / 2.0)
    m = (d > 40.0) & (r < w * 0.4)
    if m.sum() < 50:
        return default_tiles
    tiles = float(np.percentile(r[m], 97)) / w * VIEW[0] + 0.8
    return float(np.clip(tiles, default_tiles * 0.8, 9.0))


def cut(repo):
    d = art_dir(repo)
    meta = load_json(os.path.join(d, "plan.json"))
    out_dir = os.path.join(repo, "assets/map/places")
    os.makedirs(out_dir, exist_ok=True)
    manifest = {"_doc": "Place sprites for the near map (tools/asset-pipeline/map/place_art.py): each is cut from a "
                        "painting of the place into its own patch of the near layer; draw it centred on the place's tile, "
                        "size_tiles across, over the near layer.", "px_per_tile": PX, "places": {}}
    radii = {}
    tiles = {r["id"]: r["tile"] for r in meta["places"]}

    def nearest(pid):   # tiles to the closest other place: a patch may not cover its neighbour's art
        tx, ty = tiles[pid]
        return min(np.hypot(tx - x, ty - y) for q, (x, y) in tiles.items() if q != pid)

    for r in meta["places"]:
        src = os.path.join(d, "paint_%d.png" % r["id"])
        if not os.path.exists(src):
            continue
        r = dict(r)
        fit = fitted_radius(src, os.path.join(d, "in_%d.png" % r["id"]), r["radius_tiles"])
        r["radius_tiles"] = round(min(fit, max(r["radius_tiles"] * 0.8, 0.55 * nearest(r["id"]))), 2)
        radii[str(r["id"])] = r["radius_tiles"]
        rgba, size_px = patch(src, r["radius_tiles"])
        Image.fromarray(rgba.astype(np.uint8), "RGBA").resize((size_px, size_px), Image.LANCZOS).save(
            os.path.join(out_dir, "place_%d.png" % r["id"]), optimize=True)
        manifest["places"][str(r["id"])] = {"file": "place_%d.png" % r["id"], "tile": r["tile"],
                                            "size_tiles": round(2 * r["radius_tiles"], 2), "kind": r["kind"]}
    with open(os.path.join(out_dir, "manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, indent=1, ensure_ascii=False)
    with open(os.path.join(d, "radii.json"), "w", encoding="utf-8") as f:   # place_stages.py cuts stages to match
        json.dump(radii, f, indent=1)
    print("cut %d place sprites" % len(manifest["places"]))


if __name__ == "__main__":
    cmd, repo = sys.argv[1], sys.argv[2]
    if cmd == "plan":
        plan(repo)
    elif cmd == "paint":
        paint(repo, sys.argv[3], set(sys.argv[4].split(",")) if len(sys.argv) > 4 else set())
    elif cmd == "cut":
        cut(repo)
