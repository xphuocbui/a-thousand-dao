"""Install the place catalogue paintings as in-game banners (user 2026-11-24: "the sects list show the sects unique
place which we already have a catalogue of"; round-3 mock-up out/r3-sect-l.png, approved).

Source: design/map/continent-11/art/places/paint_<continent place id>.png (1536x864, painted 2026-11-22/23).
Output: assets/art/places/<continent place id>.webp: a sect's seat at the source 1536x864 (the sect window's banner is
drawn about 1,100 px wide at 1080p), every other place at 960x540 (the place panel, later).
No image API calls. Usage (repo root): python -I tools/asset-pipeline/places/install_place_paintings.py
"""
import glob, json, os, re
from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
SRC = os.path.join(ROOT, "design/map/continent-11/art/places")
OUT = os.path.join(ROOT, "assets/art/places")
os.makedirs(OUT, exist_ok=True)
hist = json.load(open(os.path.join(ROOT, "assets/data/world_history.json"), encoding="utf-8"))
SEATS = {str(s["seat"]) for s in hist["sects"] if s.get("seat") is not None}
n = size = 0
for f in glob.glob(os.path.join(SRC, "paint_*.png")):
    pid = re.search(r"paint_(\d+)\.png$", f).group(1)
    dst = os.path.join(OUT, pid + ".webp")
    im = Image.open(f).convert("RGB")
    if pid not in SEATS:
        im = im.resize((960, 540), Image.LANCZOS)
    im.save(dst, "WEBP", quality=84, method=6)
    n += 1
    size += os.path.getsize(dst)
print("installed", n, "paintings (%d sect seats full size), %.1f MB" % (len(SEATS), size / 1e6))
