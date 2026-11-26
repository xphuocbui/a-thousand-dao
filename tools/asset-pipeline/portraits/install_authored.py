"""Install the authored xianxia portraits as the game's cast portraits (world-depth plan Stage 3; DECISIONS-2026-11-26:
xianxia v1, painted at low quality; the x-* batches are the only source, the older p* and pilot batches are
superseded).

Source: tools/asset-pipeline/portraits/out/authored/x-<group>/<key>.png (1024x1536; outside git).
Output: assets/portraits/cast/<key>.webp at the painted 1024x1536, WebP quality 90 (user 2026-11-26: high resolution,
so the portrait stays sharp at every screen size and UI scale), replacing any older picture of that
key, and assets/portraits/portraits.json's "cast" list rebuilt from the files present (the type set is kept).
A cast webp whose key has no authored portrait is reported, never deleted.
No image API calls. Usage (repo root): python -I tools/asset-pipeline/portraits/install_authored.py [--check]
"""
import glob
import json
import os
import sys

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
SRC = os.path.join(ROOT, "tools/asset-pipeline/portraits/out/authored")
OUT = os.path.join(ROOT, "assets/portraits/cast")
INDEX = os.path.join(ROOT, "assets/portraits/portraits.json")


def sources():
    out = {}
    for f in sorted(glob.glob(os.path.join(SRC, "x-*", "*.png"))):
        key = os.path.basename(f)[:-4]
        if key in out:
            raise SystemExit("portrait %s is in two batches: %s, %s" % (key, out[key], f))
        out[key] = f
    return out


def main():
    check = "--check" in sys.argv
    src = sources()
    os.makedirs(OUT, exist_ok=True)
    have = {os.path.basename(f)[:-5] for f in glob.glob(os.path.join(OUT, "*.webp"))}
    orphans = sorted(have - set(src))
    print("authored portraits %d; installed now %d; cast webp with no authored portrait: %s" % (
        len(src), len(have), ", ".join(orphans) or "none"))
    if check:
        return 0
    size = 0
    for key, f in src.items():
        dst = os.path.join(OUT, key + ".webp")
        Image.open(f).convert("RGB").save(dst, "WEBP", quality=90, method=6)   # full painted size
        size += os.path.getsize(dst)
    idx = json.load(open(INDEX, encoding="utf-8"))
    idx["cast"] = sorted({os.path.basename(f)[:-5] for f in glob.glob(os.path.join(OUT, "*.webp"))})
    with open(INDEX, "w", encoding="utf-8", newline="") as fh:
        fh.write(json.dumps(idx, ensure_ascii=False, indent=1))   # the file's own layout: indent 1, no final newline
    print("installed %d portraits, %.1f MB; portraits.json cast %d" % (len(src), size / 1e6, len(idx["cast"])))
    return 0


if __name__ == "__main__":
    sys.exit(main())
