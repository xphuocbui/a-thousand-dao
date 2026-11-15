"""Page assets, step 2 of tools/design/world/page/build_page.py: one alpha mask per land unit (20 regions minus parts, plus the named parts) and the page data."""
import json
import os
import sys

from PIL import Image, ImageDraw, ImageFilter

repo, out = sys.argv[1], sys.argv[2]
sys.path.insert(0, os.path.join(repo, "tools", "design", "map"))
import places as PL  # noqa: E402

MAP = os.path.join(repo, "design", "map", "continent-11")
WORLD = os.path.join(repo, "design", "world")
os.makedirs(out, exist_ok=True)
load = lambda p: json.load(open(p, encoding="utf-8"))
M = PL.Map(MAP)
W, H, sc = M.W, M.H, 3
HP = load(os.path.join(MAP, "history_places.json"))

# ---- land units
part_of = {}
units = {}
for pt in HP["parts"]:
    pieces = pt.get("pieces") or {pt["key"]: {"tile_list": pt["tile_list"]}}
    for k, v in pieces.items():
        units[k] = [tuple(t) for t in v["tile_list"]]
        for t in units[k]:
            part_of[t] = k
for i, r in enumerate(M.rid):
    if not r:
        continue
    t = (i % W, i // W)
    if t in part_of:
        continue
    units.setdefault(str(r), []).append(t)
unit_meta = {}
for k, tiles in units.items():
    m = Image.new("L", (W * sc, H * sc), 0)
    d = ImageDraw.Draw(m)
    s = set(tiles)
    for x, y in tiles:
        d.rectangle((x * sc, y * sc, x * sc + sc - 1, y * sc + sc - 1), fill=95)
    for x, y in tiles:
        for nx, ny, sg in ((x + 1, y, ((x + 1) * sc - 1, y * sc, (x + 1) * sc - 1, (y + 1) * sc)),
                           (x - 1, y, (x * sc, y * sc, x * sc, (y + 1) * sc)),
                           (x, y + 1, (x * sc, (y + 1) * sc - 1, (x + 1) * sc, (y + 1) * sc - 1)),
                           (x, y - 1, (x * sc, y * sc, (x + 1) * sc, y * sc))):
            if (nx, ny) not in s and 0 <= nx < W and 0 <= ny < H and M.rid[ny * W + nx]:
                d.line(sg, fill=230, width=2)
    rgba = Image.new("RGBA", m.size, (255, 255, 255, 0))
    rgba.putalpha(m)
    rgba.save(os.path.join(out, f"u-{k}.png"), optimize=True)
    cx = sum(t[0] for t in tiles) / len(tiles)
    cy = sum(t[1] for t in tiles) / len(tiles)
    region = int(k) if k.isdigit() else M.rid[tiles[0][1] * W + tiles[0][0]]
    unit_meta[k] = {"region": region, "tiles": len(tiles), "c": [round(cx * sc + 1.5), round(cy * sc + 1.5)]}

# ---- data
px = lambda t: [round(t[0] * sc + 1.5, 1), round(t[1] * sc + 1.5, 1)]
old = load(os.path.join(os.path.dirname(os.path.abspath(out)), "out", "data.json"))
places = load(os.path.join(MAP, "places.json"))["places"]
sac = load(os.path.join(MAP, "sacred.json"))
hist = load(os.path.join(MAP, "history.json"))
loc = {}
for q in places:
    if q.get("name_hv"):
        loc[q["name_hv"]] = px(q["tile"])
for q in sac["places"]:
    if q.get("name_hv"):
        loc.setdefault(q["name_hv"], px(q["tile"]))
for c in sac.get("deep_caves", []):
    loc[c["name_hv"]] = px(c["tile"])
for c in sac.get("sacred_summits", []):
    if c.get("name_hv"):
        loc.setdefault(c["name_hv"], px(c["tile"]))
loc["Chiết Kích Nguyên"] = px(sac["miasma_wasteland"]["source"])
loc["Vạn Cốt Trủng"] = px(sac["miasma_source"]["tile"])
for kind, arr in hist["famous"].items():
    for f in arr:
        loc[f["name_hv"]] = px(f.get("tile") or f["centre"])
prom = {p["place_id"]: p for p in HP["promotions"]}
for q in places:
    if q["id"] in prom:
        loc[prom[q["id"]]["name_hv"]] = px(q["tile"])
for r in HP["ruins"]:
    loc[r["name_hv"]] = px(r["tile"])
regs = {r["id"]: r for r in load(os.path.join(MAP, "regions.json"))["regions"]}
pid0 = {q["id"]: q for q in places}
region_c = {r["name_hv"]: px(r["centre_tile"]) for r in regs.values()}

C = load(os.path.join(WORLD, "chronicle_proposal.json"))["events"]
A = load(os.path.join(WORLD, "annals_proposal.json"))["events"]
T = load(os.path.join(WORLD, "territory_history_proposal.json"))
I = load(os.path.join(WORLD, "legendary_items_proposal.json"))["items"]
R = load(os.path.join(WORLD, "records_proposal.json"))["records"]
S0 = load(os.path.join(WORLD, "sect_start_proposal.json"))


def slim(e):
    o = {k: e[k] for k in ("id", "year", "kind", "people", "sects", "text", "text_vi") if k in e}
    for k in ("slot", "item", "war", "secret"):
        if e.get(k):
            o[k] = e[k]
    if e.get("place"):
        o["place"] = e["place"]
        o["p"] = loc.get(e["place"])
    if e.get("famous_site"):
        o["site"] = e["famous_site"]
        o["p"] = loc.get(e["famous_site"]) or o.get("p")
    if e.get("region"):
        o["region"] = e["region"]
        if not o.get("p"):
            o["p"] = region_c.get(e["region"])
    return o


preg = {}
for q in places:
    preg[q.get("name_hv")] = q["region"]
for pr in HP["promotions"]:
    preg[pr["name_hv"]] = pid0[pr["place_id"]]["region"]
for q in sac["places"]:
    preg.setdefault(q.get("name_hv"), q.get("region"))
for r in HP["ruins"]:
    preg[r["name_hv"]] = r["region"]
rid_by_name = {r["name_hv"]: r["id"] for r in regs.values()}
for kind, arr in hist["famous"].items():
    for f in arr:
        if f.get("region"):
            preg[f["name_hv"]] = rid_by_name.get(f["region"])
def tile_region(xy):
    x, y = int((xy[0] - 1.5) / sc), int((xy[1] - 1.5) / sc)
    return M.rid[y * W + x] or None
events = []
for e in C:
    o = slim(e)
    r = rid_by_name.get(e.get("region")) or preg.get(e.get("place")) or preg.get(e.get("famous_site"))
    if not r and o.get("p"):
        r = tile_region(o["p"])
    if r:
        o["rid"] = r
    events.append(o)
annals = [dict(slim(e), rid=e["region_id"]) for e in A]
miss = [e["id"] for e in events + annals if not e.get("p") and not e.get("slot")]
print("without a location:", miss)

sects = old["sects"]
extra_col = {"cuu_thieu": [170, 140, 200], "khai_loi": [128, 128, 170], "khong_son": [150, 168, 140],
             "ho_thien": [196, 208, 228], "lac_anh": [232, 150, 170], "xich_thanh": [160, 62, 44],
             "han_giang": [100, 140, 162], "co_pham": [110, 170, 190], "thon_hai": [80, 80, 90],
             "pha_quan": [120, 60, 60], "kim_coc": [200, 170, 80]}
for m in HP.get("minor_seats", []):
    sects[m["key"]] = {"name": m["name_hv"], "han": m["name_han"], "seat": px(m["tile"]), "minor": True,
                       "lord": m["lord"], "col": sects[m["lord"]]["col"]}
    loc[m["name_hv"]] = px(m["tile"])
for f in T["fallen_sects"]:
    sects[f["key"]] = {"name": f["name_hv"], "han": f["name_han"], "gloss": f["gloss"], "founded": f["founded"],
                       "fell": f["fell"], "cause": f["cause"], "vanished": True, "fallen": True}
for k, c in extra_col.items():
    if k in sects:
        sects[k]["col"] = c
for g in S0["great_sects"] + S0["minor_sects"]:
    s = sects[g["key"]]
    s["align"], s["levels"], s["treasury"] = g["alignment"], g["levels"], g["treasury"]
    if "loyalty" in g:
        s["loyalty"] = g["loyalty"]

people = old["people"]
cast = load(os.path.join(WORLD, "cast_proposal.json"))
for k, y in cast["minor_sect_founding_years"].items():
    if k in sects:
        sects[k]["founded"] = y
for p in cast["people"]:
    if p["key"] in people:
        people[p["key"]]["role"] = p.get("role", "")
for r in R:
    people[r["key"]] = {"name": r["name_hv"], "han": r.get("name_han", ""), "gloss": r.get("gloss", ""),
                        "sex": r.get("sex"), "born": r["born"], "died": r.get("died"), "alive": False,
                        "realm": r.get("peak_realm"), "sect": r.get("sect", ""), "rank": r.get("rank", ""),
                        "role": r.get("role", ""), "record": True}

cities = []
pid = {q["id"]: q for q in places}
for cy in HP["city_years"]:
    q = pid[cy["place_id"]]
    cities.append({"name": cy["name_hv"], "p": px(q["tile"]), "from": cy["founded"], "why": cy["founded_why"]})
for pr in HP["promotions"]:
    q = pid[pr["place_id"]]
    cities.append({"name": pr["name_hv"], "p": px(q["tile"]), "from": pr["founded"], "why": pr["founded_why"],
                   "promoted": True})
ruins = [{"key": r["history_key"], "name": r["name_hv"], "han": r["name_han"], "gloss": r["gloss"], "p": px(r["tile"]), "former": r["former"],
          "lived": r["lived"], "note": r["note"], "region": r["region_name"]} for r in HP["ruins"]]
items = []
for it in I:
    o = {k: it.get(k) for k in ("key", "name_hv", "name_han", "gloss", "kind", "element_guess", "made_by", "made_year",
                                "story", "status", "holder", "place", "famous_site", "slot", "pair", "secret", "sought_by")}
    items.append({k: v for k, v in o.items() if v is not None})

blob = {
    "events": events, "annals": annals, "slots": old["slots"], "sects": sects, "people": people,
    "eras": T["eras"], "changes": [{"y": c["year"], "land": c["land"], "from": c["from"], "to": c["to"]} for c in T["land_changes"]],
    "units": unit_meta, "wars": [{"key": w["key"], "name": w["name"], "name_hv": w["name_hv"], "years": w["years"], "sides": w["sides"], "outcome": w["outcome"]} for w in T["wars"]],
    "grudges": T["grudges"], "fallen": T["fallen_sects"], "cities": cities, "ruins": ruins, "items": items,
    "regions": {r["name_hv"]: {"id": r["id"], "c": px(r["centre_tile"]), "han": r.get("name_han", ""), "gloss": r.get("gloss", "")} for r in regs.values()},
    "miasma_year": 803, "now": 1200,
}
json.dump(blob, open(os.path.join(out, "data2.json"), "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
print("units", len(unit_meta), "data bytes", os.path.getsize(os.path.join(out, "data2.json")))
