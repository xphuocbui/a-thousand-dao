"""Paint the natural landmarks into the 4x near layer (user, 2026-11-23: "the volcano should be rendered together with
the terrain"): volcanoes, peaks, lakes, islands, forests and gorges get no map symbol; instead each is painted into the
terrain at its own tile, from its catalogue art brief (design/world/place_catalogue.json), in the same painting style.

For each natural place the repainted layer around it (32 x 18 tiles, 1536 x 864 at 48 px per tile, from near_upres
pass 2) is sent to the image model with the brief; near_tiles.py blends the painted patch back with a soft round
feather (full inside `inner` tiles of the place, nothing beyond `outer`), colour-matched to the land around it.

usage: python -I tools/asset-pipeline/map/landmarks.py <repo> plan
       python -I tools/asset-pipeline/map/landmarks.py <repo> paint [ids]
Files: design/map/continent-11/art/near/upres4/landmarks/plan.json, in_<id>.png, prompt_<id>.md, paint_<id>.png.
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
import near_upres as NU  # noqa: E402

NATURAL = {"volcano": (4.5, 7.5), "peak": (3.5, 6.5), "lake": (4.5, 7.5), "island": (3.5, 6.5), "forest": (4.5, 7.5),
           "gorge": (3.5, 6.5)}   # kind -> (inner, outer) feather radii in tiles
SRC_PX = 24                       # pass 2 source px per tile
HALF = (16, 9)                    # tiles each side of the place in the input (32 x 18 = 1536 x 864 at 48 px)
GRID = (540, 360)


def d(repo):
    return os.path.join(NU.root(repo, ""), "landmarks")


def places(repo):
    pl = json.load(open(os.path.join(repo, "design/map/continent-11/places.json"), encoding="utf-8"))
    pl = pl["places"] if isinstance(pl, dict) else pl
    raw = json.load(open(os.path.join(repo, "design/world/place_catalogue.json"), encoding="utf-8"))
    raw = raw["places"] if isinstance(raw, dict) else raw
    cat = {int(e["id"]): e for e in raw}
    return [(p, cat.get(int(p["id"]), {})) for p in pl if p["kind"] in NATURAL]


def plan(repo):
    os.makedirs(d(repo), exist_ok=True)
    base = open(NU.PROMPT, encoding="utf-8").read()
    out = []
    for p, c in places(repo):
        tx, ty = p["tile"][0] + 0.5, p["tile"][1] + 0.5
        x0 = int(round(min(max(tx - HALF[0], 0), GRID[0] - 2 * HALF[0]) * SRC_PX))
        y0 = int(round(min(max(ty - HALF[1], 0), GRID[1] - 2 * HALF[1]) * SRC_PX))
        box = (x0, y0, x0 + 2 * HALF[0] * SRC_PX, y0 + 2 * HALF[1] * SRC_PX)
        NU.stitch(repo, "p2", box).save(os.path.join(d(repo), "in_%d.png" % p["id"]))
        # where the place sits inside the crop, as a share of width and height (it is off-centre near the map's edge)
        fx, fy = (tx * SRC_PX - x0) / (box[2] - box[0]), (ty * SRC_PX - y0) / (box[3] - box[1])
        inner, outer = NATURAL[p["kind"]]
        brief = (c.get("art_brief") or c.get("look") or "").strip()
        name = "%s (%s)" % (p.get("name_hv", ""), p.get("gloss", "")) if p.get("gloss") else p.get("name_hv", "")
        where = "at the exact centre of the image" if abs(fx - 0.5) < 0.05 and abs(fy - 0.5) < 0.05 else \
            "at about %d %% from the left and %d %% from the top" % (round(fx * 100), round(fy * 100))
        text = (base + "\n\nThis crop holds a famous natural landmark, %s, %s: a %s. %s\nPaint it INTO the terrain as part of "
                "the same painting, at true map scale (it spans about %d tiles of a map where the whole image is 32 "
                "tiles across), seen straight down with the same light and brushwork, so it reads as part of the land. "
                "Change only its own area; everything farther than that from it stays exactly as the input. No towns, "
                "no roads, no text." % (name, where, p["kind"], brief, int(round(inner * 2))))
        open(os.path.join(d(repo), "prompt_%d.md" % p["id"]), "w", encoding="utf-8").write(text)
        out.append({"id": int(p["id"]), "kind": p["kind"], "tile": p["tile"], "box": box, "inner": inner,
                    "outer": outer})
    json.dump({"src_px": SRC_PX, "landmarks": out}, open(os.path.join(d(repo), "plan.json"), "w"), indent=1)
    print("landmarks", len(out))


TAG = "paint3"   # round 3 (2026-11-23): round 2 was natural but too faint to see; round 2 (2026-11-23): the plain `look`, natural form only; round 1 (`paint`) used the sprite art
                 # briefs and drew rings, stakes and round clearings that looked pasted on


def prompt_v2(repo, e, c, p):
    base = open(NU.PROMPT, encoding="utf-8").read()
    look = (c.get("look") or "").strip()
    name = "%s (%s)" % (p.get("name_hv", ""), p.get("gloss", "")) if p.get("gloss") else p.get("name_hv", "")
    b = e["box"]
    fx = ((e["tile"][0] + 0.5) * SRC_PX - b[0]) / (b[2] - b[0])
    fy = ((e["tile"][1] + 0.5) * SRC_PX - b[1]) / (b[3] - b[1])
    where = "near the centre of the image" if abs(fx - 0.5) < 0.05 and abs(fy - 0.5) < 0.05 else \
        "at about %d %% from the left and %d %% from the top" % (round(fx * 100), round(fy * 100))
    return (base + "\n\nThis crop holds a famous natural landmark, %s, %s (a %s). How it looks: %s\n"
            "Paint ONLY its natural form into the terrain: the shape of the land, rock, ice, water, trees and light. Leave "
            "out everything built or carried by people (terraces, stakes, racks, roads, plank roads, causeways, shrines, "
            "buildings, boats) and anything only seen up close (animals, figures, a star). It is at true map scale (about "
            "%d tiles across, on an image 32 tiles wide), seen straight down, with the same light and brushwork as the land "
            "around it, and it fades into its surroundings gradually: no circle, ring, clearing edge, halo or change of "
            "texture around it, so it looks as if it had always been part of this painting. It must still be CLEARLY "
            "VISIBLE from map height: the most striking natural feature in this crop, the first thing the eye lands on "
            "(a volcano is a distinct dark cone with a glowing crater, a famous peak clearly the highest and whitest, a "
            "great tree or grove stands out in colour and size, a gorge is a deep dark cut, a lake or island has its own "
            "clear shape and colour)%s. Everything farther from it stays exactly as the input. No text."
            % (name, where, p["kind"], look, int(round(e["inner"] * 2)),
               "; where the input shows shallow water at its spot, the land rises out of it there" if p["kind"] in ("volcano", "island") else ""))


def paint(repo, ids):
    p = json.load(open(os.path.join(d(repo), "plan.json")))
    byid = {int(q["id"]): (q, c) for q, c in places(repo)}
    tool = os.path.join(repo, "tools/asset-pipeline/ui/img_edit.py")
    procs = []
    for e in p["landmarks"]:
        out = os.path.join(d(repo), "%s_%d.png" % (TAG, e["id"]))
        if (ids and str(e["id"]) not in ids) or os.path.exists(out):
            continue
        q, c = byid[int(e["id"])]
        pr = os.path.join(d(repo), "prompt2_%d.md" % e["id"])
        open(pr, "w", encoding="utf-8").write(prompt_v2(repo, e, c, q))
        procs.append(subprocess.Popen([sys.executable, "-I", tool, "gpt-image-2", "medium", "1536x864", pr, "--", out,
                                       os.path.join(d(repo), "in_%d.png" % e["id"])]))
        if len(procs) >= 6:
            procs.pop(0).wait()
    for q in procs:
        q.wait()


def overlay(repo, img, box):
    """Blends every painted landmark that touches [param box] (pass 2 source px) into [param img] (its 2x output, an
    H x W x 3 float array), in place."""
    path = os.path.join(d(repo), "plan.json")
    if not os.path.exists(path):
        return
    from paint_tiles import match_colour
    p = json.load(open(path))
    for e in p["landmarks"]:
        b = e["box"]
        if b[2] <= box[0] or b[3] <= box[1] or b[0] >= box[2] or b[1] >= box[3]:
            continue
        f = os.path.join(d(repo), "%s_%d.png" % (TAG, e["id"]))
        if not os.path.exists(f):
            continue
        src = np.asarray(Image.open(os.path.join(d(repo), "in_%d.png" % e["id"])).convert("RGB")).astype(np.float32)
        h, w = src.shape[:2]
        pa = np.asarray(Image.open(f).convert("RGB").resize((w, h), Image.LANCZOS)).astype(np.float32)
        pa = match_colour(pa, src, 0.6)
        out_px = 2 * SRC_PX
        cx, cy = (e["tile"][0] + 0.5) * SRC_PX * 2 - b[0] * 2, (e["tile"][1] + 0.5) * SRC_PX * 2 - b[1] * 2
        yy, xx = np.mgrid[0:h, 0:w].astype(np.float32)
        r = np.hypot(xx - cx, yy - cy) / out_px
        wgt = np.clip((e["outer"] - r) / (e["outer"] - e["inner"]), 0, 1)
        wgt = (wgt * wgt * (3 - 2 * wgt))[..., None]
        ox, oy = (b[0] - box[0]) * 2, (b[1] - box[1]) * 2
        H, W = img.shape[:2]
        x0, y0, x1, y1 = max(0, ox), max(0, oy), min(W, ox + w), min(H, oy + h)
        if x0 >= x1 or y0 >= y1:
            continue
        sl = (slice(y0 - oy, y1 - oy), slice(x0 - ox, x1 - ox))
        img[y0:y1, x0:x1] = img[y0:y1, x0:x1] * (1 - wgt[sl]) + pa[sl] * wgt[sl]


if __name__ == "__main__":
    repo, cmd = sys.argv[1], sys.argv[2]
    if cmd == "plan":
        plan(repo)
    elif cmd == "paint":
        paint(repo, set(sys.argv[3].split(",")) if len(sys.argv) > 3 else set())
