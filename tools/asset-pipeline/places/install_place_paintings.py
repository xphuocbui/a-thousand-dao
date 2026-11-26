"""Install the place paintings as in-game banners (user 2026-11-24: "the sects list show the sects unique place which we
already have a catalogue of"; round-3 mock-up out/r3-sect-l.png, approved).

Sources, first found wins:
- design/world/depth/art/places/out/<batch>/paint_<continent place id>.png: the world-depth place paintings (v2, a
  standalone painting per place at true scale, 1536x864; world-depth plan Stage 3, the user keeps them as painted,
  2026-11-26); the batches l1, l2, l3 cover 311 places, all 254 earlier banners included;
- design/map/continent-11/art/places/paint_<id>.png: the 2026-11-22/23 catalogue paintings, for any place the depth set
  does not cover.
Output: assets/art/places/<continent place id>.webp at the painted 1536x864, WebP quality 90, for every place (user
2026-11-26: every banner at full resolution; it was a seat at full size and other places at 960x540).

No image API calls. Usage (repo root): python -I tools/asset-pipeline/places/install_place_paintings.py
"""
import glob
import os
import re

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
DEPTH = os.path.join(ROOT, "design/world/depth/art/places/out")
DEPTH_BATCHES = ("l1", "l2", "l3")
OLD = os.path.join(ROOT, "design/map/continent-11/art/places")
OUT = os.path.join(ROOT, "assets/art/places")


def sources():
    out = {}
    for b in DEPTH_BATCHES:
        for f in sorted(glob.glob(os.path.join(DEPTH, b, "paint_*.png"))):
            pid = re.search(r"paint_(\d+)\.png$", f).group(1)
            if pid in out:
                raise SystemExit("place %s is painted in two batches: %s, %s" % (pid, out[pid], f))
            out[pid] = f
    depth = len(out)
    for f in sorted(glob.glob(os.path.join(OLD, "paint_*.png"))):
        out.setdefault(re.search(r"paint_(\d+)\.png$", f).group(1), f)
    return out, depth


def main():
    os.makedirs(OUT, exist_ok=True)
    src, depth = sources()
    size = 0
    for pid, f in src.items():
        dst = os.path.join(OUT, pid + ".webp")
        Image.open(f).convert("RGB").save(dst, "WEBP", quality=90, method=6)
        size += os.path.getsize(dst)
    print("installed %d paintings (%d from the world-depth set), %.1f MB" % (len(src), depth, size / 1e6))


if __name__ == "__main__":
    main()
