"""Page assets, step 1 of tools/design/world/page/build_page.py: the base map, the miasma layer and the first data blob
(slots, sects, people) that step 2 builds on."""
import json
import os
import sys

from PIL import Image, ImageDraw, ImageEnhance

repo, out = sys.argv[1], sys.argv[2]
sys.path.insert(0, os.path.join(repo, "tools", "design", "map"))
import places as PL  # noqa: E402

MAP = os.path.join(repo, "design", "map", "continent-11")
WORLD = os.path.join(repo, "design", "world")
os.makedirs(out, exist_ok=True)


def load(p):
    with open(p, encoding="utf-8") as fh:
        return json.load(fh)


M = PL.Map(MAP)
W, H, sc = M.W, M.H, 3

# ---- base map: terrain, softened, with thin region lines
base = Image.open(os.path.join(MAP, "base", "detail.jpg")).convert("RGB").resize((W * sc, H * sc), Image.LANCZOS)
base = ImageEnhance.Color(base).enhance(0.7)
base = Image.blend(base, Image.new("RGB", base.size, (24, 28, 30)), 0.18).convert("RGBA")
ov = Image.new("RGBA", base.size, (0, 0, 0, 0))
d = ImageDraw.Draw(ov)
for y in range(H):
    for x in range(W):
        a = M.rid[y * W + x]
        if not a:
            continue
        if x + 1 < W:
            b = M.rid[y * W + x + 1]
            if b and b != a and M.terr[y * W + x] == M.terr[y * W + x + 1]:
                d.line(((x + 1) * sc, y * sc, (x + 1) * sc, (y + 1) * sc), fill=(255, 255, 255, 45), width=1)
        if y + 1 < H:
            b = M.rid[(y + 1) * W + x]
            if b and b != a and M.terr[y * W + x] == M.terr[(y + 1) * W + x]:
                d.line((x * sc, (y + 1) * sc, (x + 1) * sc, (y + 1) * sc), fill=(255, 255, 255, 45), width=1)
Image.alpha_composite(base, ov).convert("RGB").save(os.path.join(out, "chron-base.jpg"), quality=84)

# ---- one tint layer per great sect: fill plus a strong edge
for k, g in enumerate(M.greats):
    col = tuple(g["colour"])
    lay = Image.new("RGBA", base.size, (0, 0, 0, 0))
    d = ImageDraw.Draw(lay)
    for y in range(H):
        for x in range(W):
            if M.terr[y * W + x] != k:
                continue
            d.rectangle((x * sc, y * sc, x * sc + sc - 1, y * sc + sc - 1), fill=col + (88,))
    for y in range(H):
        for x in range(W):
            if M.terr[y * W + x] != k:
                continue
            for nx, ny, sg in ((x + 1, y, ((x + 1) * sc - 1, y * sc, (x + 1) * sc - 1, (y + 1) * sc)),
                               (x - 1, y, (x * sc, y * sc, x * sc, (y + 1) * sc)),
                               (x, y + 1, (x * sc, (y + 1) * sc - 1, (x + 1) * sc, (y + 1) * sc - 1)),
                               (x, y - 1, (x * sc, y * sc, (x + 1) * sc, y * sc))):
                inside = 0 <= nx < W and 0 <= ny < H and M.terr[ny * W + nx] == k
                if not inside:
                    d.line(sg, fill=col + (235,), width=2)
    lay.save(os.path.join(out, f"chron-{g['key']}.png"), optimize=True)

# ---- miasma
sac = load(os.path.join(MAP, "sacred.json"))
lay = Image.new("RGBA", base.size, (0, 0, 0, 0))
d = ImageDraw.Draw(lay)
for x, y in sac["miasma_wasteland"]["tile_list"]:
    d.rectangle((x * sc, y * sc, x * sc + sc - 1, y * sc + sc - 1), fill=(130, 60, 150, 170))
lay.save(os.path.join(out, "chron-miasma.png"), optimize=True)

# ---- data
px = lambda t: [round(t[0] * sc + 1.5, 1), round(t[1] * sc + 1.5, 1)]
places = load(os.path.join(MAP, "places.json"))["places"]
hist = load(os.path.join(MAP, "history.json"))
loc = {}
for q in places:
    if q.get("name_hv"):
        loc[q["name_hv"]] = px(q["tile"])
for q in sac["places"]:
    if q.get("name_hv"):
        loc.setdefault(q["name_hv"], px(q["tile"]))
loc["Chiết Kích Nguyên"] = px(sac["miasma_wasteland"]["source"])
loc["Vạn Cốt Trủng"] = px(sac["miasma_source"]["tile"])
for kind, arr in hist["famous"].items():
    for f in arr:
        loc[f["name_hv"]] = px(f.get("tile") or f["centre"])

slots = {}
for s in hist["hidden"]:
    slots[s["slot"]] = {
        "kind": s["kind"],
        "c": [{"p": px(c.get("tile") or c["centre"]), "r": c.get("region", "")} for c in s["candidates"]],
    }
prop = load(os.path.join(MAP, "history_proposal.json"))

chron = load(os.path.join(WORLD, "chronicle_proposal.json"))
cast = load(os.path.join(WORLD, "cast_proposal.json"))
start = load(os.path.join(WORLD, "sect_start_proposal.json"))
traits = load(os.path.join(WORLD, "leader_traits_proposal.json"))

sects = {g["key"]: {"name": g["name_hv"], "han": g.get("name_han", ""), "col": g["colour"], "tier": g.get("tier"),
                    "seat": loc.get(g["name_hv"])} for g in M.greats}
for q in places:
    if q["kind"] == "minor_seat":
        sects[q["key"]] = {"name": q["name_hv"], "han": q.get("name_han", ""), "seat": px(q["tile"]), "minor": True}
for m in M.minors:
    if m.get("key") in sects:
        lord = m.get("lord")
        sects[m["key"]]["lord"] = lord
        sects[m["key"]]["col"] = sects.get(lord, {}).get("col")
for v in cast["vanished_sects"]:
    sects[v["key"]] = {"name": v["name_hv"], "han": v.get("name_han", ""), "gloss": v["gloss"], "founded": v["founded"],
                       "fell": v["fell"], "cause": v["cause"], "slot": v["ruin_slot"], "vanished": True}
for k, y in cast["great_sect_founding_years"].items():
    sects[k]["founded"] = y
for k, y in cast["minor_sect_founding_years"].items():
    sects[k]["founded"] = y
for g in start["great_sects"] + start["minor_sects"]:
    s = sects[g["key"]]
    s["align"] = g["alignment"]
    s["levels"] = g["levels"]
    s["treasury"] = g["treasury"]
    if "loyalty" in g:
        s["loyalty"] = g["loyalty"]

tr = dict(traits["traits"])
tr.update(traits.get("others", {}))
people = {}
for p in cast["people"]:
    home = (p.get("home") or "").split(" (")[0]
    people[p["key"]] = {
        "name": p["name_hv"], "han": p.get("name_han", ""), "gloss": p.get("gloss", ""), "sex": p.get("sex"),
        "born": p["born"], "died": p.get("died"), "alive": p["alive"], "realm": p.get("realm") or p.get("peak_realm"),
        "sect": p.get("sect") or "", "rank": p.get("rank") or "", "role": p.get("role", ""), "cause": p.get("cause"),
        "home": home, "home_p": loc.get(home), "master": None,
        "traits": tr.get(p["key"]),
    }
for t in cast["ties"]:
    people[t["disciple"]]["master"] = t["master"]

events = []
for e in chron["events"]:
    o = {k: e[k] for k in ("id", "year", "kind", "people", "sects", "text", "text_vi")}
    if e.get("place"):
        o["place"] = e["place"]
        o["p"] = loc.get(e["place"])
    if e.get("famous_site"):
        o["site"] = e["famous_site"]
        o["p"] = loc.get(e["famous_site"]) or o.get("p")
    if e.get("slot"):
        o["slot"] = e["slot"]
    events.append(o)

missing = [e["id"] for e in events if not e.get("p") and not e.get("slot")]
nohome = [k for k, p in people.items() if p["alive"] and not p["home_p"]]
print("events without a location:", missing)
print("living without a home point:", nohome)

blob = {"events": events, "slots": slots, "sects": sects, "people": people,
        "miasma_year": 803, "now": 1200}
with open(os.path.join(out, "data.json"), "w", encoding="utf-8") as fh:
    json.dump(blob, fh, ensure_ascii=False, separators=(",", ":"))
print("data bytes", os.path.getsize(os.path.join(out, "data.json")))
for f in sorted(os.listdir(out)):
    print(f, os.path.getsize(os.path.join(out, f)))
