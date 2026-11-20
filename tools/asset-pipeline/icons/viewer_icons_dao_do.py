"""Framed node icons for the tree viewer artifact (claude.ai/artifact/RJmdZHYeMaMAVobqfZNYkn). Args: repo root, out dir
(the viewer's local copy). Packs every framed icon into sprite sheets (di-sheet-<i>.webp) because the artifact has a file limit.

Writes <out>/di/<name>.webp (one per distinct icon and frame, painting + B1 frame, no enamel line) and
<out>/icons.json: {"hole": {frame: share of width}, "n": {node id: [file, frame, tint hex]}}. The viewer draws the
enamel line as an SVG ring in the node's land colour, the way the engine will.
"""
import json
import os
import sys

from PIL import Image

ROOT, OUT = sys.argv[1], sys.argv[2]
ICONS = os.path.join(ROOT, "tools", "asset-pipeline", "icons")
sys.path.insert(0, ICONS)
import frames_painted as P  # noqa: E402
import subjects_dao_do as D  # noqa: E402

AI = os.path.join(ICONS, "ai", "openai")
PX = {"road": 64, "small": 80, "notable": 112, "capability": 128, "keystone": 176, "start": 192}
ZOOM = {"road": 1.7}
TINT = {"el:hoa": "#E8442A", "el:tho": "#8F5A2E", "el:kim": "#DCE3EC", "el:thuy": "#3F6FE0", "el:moc": "#2FBF8A",
        "var:loi": "#A15CFF", "var:am": "#6B2D8F", "var:quang": "#FFE45C", "var:phong": "#A6EBD8", "chaos": "#E0409A",
        "exact": "#E8D08A"}

m = json.load(open(os.path.join(ROOT, "assets", "data", "dao_do_map.json"), encoding="utf-8"))
cat = {(e["kind"], e["id"]): e for e in json.load(open(os.path.join(ROOT, "assets", "icons", "dao_do", "CATALOGUE.json"), encoding="utf-8"))["icons"]}
node_icon = {}
for (kind, iid), e in cat.items():
    for nid in e["nodes"]:
        node_icon[nid] = (kind, iid)
os.makedirs(os.path.join(OUT, "di"), exist_ok=True)
made = {}


def tint_of(area):
    if area.startswith("border:"):
        return TINT.get("el:" + area.split(":")[1], "#E8D08A")
    return TINT.get(area, "#E8D08A")


def framed(painting, fk, name, zoom=1.0):
    if name in made:
        return name
    import picks_dao_do as PK
    im = P.node(painting, PK.frame_path(fk), fk, PX[fk], None, zoom)
    im.save(os.path.join(OUT, "di", name + ".webp"), "WEBP", quality=86, method=6)
    made[name] = True
    return name


# Notable tone (user 2026-11-20: "the notables are a bit bright"; NOT SETTLED, tune here): gamma on the painting, a dark
# vignette toward the rim (edge = brightness left at the rim) and a slight desaturation. None = untouched.
NOTE_TONE = {"gamma": 1.4, "edge": 0.35, "sat": 0.9}


def tone(path, t):
    import numpy as np
    from PIL import ImageEnhance
    a = np.asarray(Image.open(path).convert("RGB")).astype(float) / 255
    a = a ** t["gamma"]
    n = a.shape[0]
    yy, xx = np.mgrid[0:n, 0:n]
    r = np.hypot(xx - n / 2, yy - n / 2) / (n / 2)
    a = a * (1 - (1 - t["edge"]) * np.clip((r - 0.35) / 0.6, 0, 1) ** 1.5)[..., None]
    return ImageEnhance.Color(Image.fromarray((np.clip(a, 0, 1) * 255).astype("uint8"))).enhance(t["sat"])


FK = {"dd_note": "notable", "dd_statc": "small", "dd_stat": "small", "dd_idea": "notable", "dd_cap": "capability", "dd_effect": "notable", "dd_keystone": "keystone", "dd_start": "start"}
pearl = [os.path.join(AI, "dd_roadmotif", "qi_pearl_dd%d.png" % j) for j in range(2)]
road_cache = {}
out, missing = {}, 0
for n in m["nodes"]:
    nid, k = n["id"], n["kind"]
    t = tint_of(n.get("area", "exact"))
    if k == "road":
        g = sorted((n.get("grants") or {}).keys())
        rk = "hub" if len(g) == 5 else "+".join(g)
        if rk not in P.ROAD_KINDS:
            continue
        j = P.road_candidate(nid)
        name = "road_%s_%d" % (rk.replace("+", "_"), j)
        if name not in made:
            framed(P.colourize(pearl[j], rk), "road", name, ZOOM["road"])
        out[nid] = [name, "road", P.road_hex(rk)]
        continue
    key = node_icon.get(nid)
    if not key:
        continue
    kind, iid = key
    import picks_dao_do as PK
    f, _tag = PK.pick(kind, iid)
    if not f:
        missing += 1
        continue
    fk = FK[kind]
    if kind in ("dd_stat", "dd_statc") and k == "notable":
        fk = "notable"
    name = "%s_%s_%s" % (kind[3:], iid, fk)
    if name not in made and kind == "dd_note" and NOTE_TONE:
        f = tone(f, NOTE_TONE)
    framed(f, fk, name)
    out[nid] = [name, fk, t]
import picks_dao_do as PK
holes = {fk: round(P.frame(PK.frame_path(fk), fk, 256)[1] / 256, 4) for fk in PX}
# Pack every framed icon into sprite sheets (the artifact has a file limit): sheet i = di-sheet-<i>.webp, 2048 wide.
ims = sorted(((nm, Image.open(os.path.join(OUT, "di", nm + ".webp")).convert("RGBA")) for nm in made), key=lambda t: -t[1].size[1])
sheets, atlas, W, HMAX = [], {}, 2048, 4096
cur, x, y, rowh, placed = None, 0, 0, 0, []
def flush():
    if not placed:
        return
    h = y + rowh
    im = Image.new("RGBA", (W, h), (0, 0, 0, 0))
    for nm, pic, px_, py_ in placed:
        im.paste(pic, (px_, py_))
    fn = "di-sheet-%d.webp" % len(sheets)
    im.save(os.path.join(OUT, fn), "WEBP", quality=88, method=6)
    sheets.append([fn, W, h])
for nm, pic in ims:
    w, h = pic.size
    if x + w > W:
        x, y, rowh = 0, y + rowh, 0
    if y + h > HMAX:
        flush(); placed, x, y, rowh = [], 0, 0, 0
    placed.append((nm, pic, x, y)); atlas[nm] = [len(sheets), x, y, w]
    x += w; rowh = max(rowh, h)
flush()
json.dump({"hole": holes, "n": out, "atlas": atlas, "sheets": sheets}, open(os.path.join(OUT, "icons.json"), "w", encoding="utf-8"), separators=(",", ":"))
size = sum(os.path.getsize(os.path.join(OUT, f[0])) for f in sheets)
print("icons", len(made), "sheets", len(sheets), "%.1f MB" % (size / 1e6), "nodes", len(out), "missing", missing)
