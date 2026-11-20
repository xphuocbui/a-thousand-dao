"""Scale the four islands of the Đạo Đồ (Sun, Moon, Shrine, Thunder) about their own centres and move each outward so
its inner edge stays put (user 2026-11-20: "for the islands please make the whole thing bigger"). Shapes are kept
exactly (uniform scale). Writes a scaled copy of the compiled map for the viewer, never the repo files.

Args: repo root, scale, out dir. Writes <out>/scaled-map.json and <out>/island-transform.json.
"""
import json
import math
import os
import sys

ROOT, S, OUT = sys.argv[1], float(sys.argv[2]), sys.argv[3]
M = json.load(open(os.path.join(ROOT, "design/dao-do/cells/versions/v5-frozen-2026-11-19/dao-do-map.json"), encoding="utf-8"))
G = {n["id"]: n for n in json.load(open(os.path.join(ROOT, "assets/data/dao_do_map.json"), encoding="utf-8"))["nodes"]}
ISL = {"sun": (0.0, 112.0, 22.0), "moon": (0.0, -103.0, 26.0), "shrine": (108.0, -25.0, 18.0), "thunder": (-103.7, -33.7, 24.0)}
ISL_AREA = {"var:quang": ("sun",), "var:am": ("moon", "shrine"), "var:loi": ("thunder",)}


def nearest(x, y, among):
    return min(among, key=lambda k: math.hypot(x - ISL[k][0], y - ISL[k][1]))


member = {}
for n in M["nodes"]:
    a = G.get(n["id"], {}).get("area", "")
    if a in ISL_AREA:
        member[n["id"]] = nearest(n["x"], n["y"], ISL_AREA[a])
    elif not (a.startswith("el:") or a.startswith("border") or a == "chaos" or a == "var:phong"):
        for k, (cx, cy, r) in ISL.items():
            if math.hypot(n["x"] - cx, n["y"] - cy) <= r:
                member[n["id"]] = k
shift = {}
for k, (cx, cy, r) in ISL.items():
    r0 = math.hypot(cx, cy); ux, uy = cx / r0, cy / r0
    ids = [n for n in M["nodes"] if member.get(n["id"]) == k]
    inner = min((n["x"] - cx) * ux + (n["y"] - cy) * uy for n in ids)
    d = -(S - 1) * inner
    shift[k] = (cx + ux * d, cy + uy * d)


def tf(k, x, y):
    cx, cy, _ = ISL[k]; nx, ny = shift[k]
    return nx + (x - cx) * S, ny + (y - cy) * S


def region_of(x, y):
    for k, (cx, cy, r) in ISL.items():
        if math.hypot(x - cx, y - cy) <= r:
            return k
    return None


for n in M["nodes"]:
    k = member.get(n["id"])
    if k:
        n["x"], n["y"] = tf(k, n["x"], n["y"])
        if "u" in n:
            n["u"], n["v"] = n["x"], n["y"]
for e in M["edges"]:
    ka, kb = member.get(e["a"]), member.get(e["b"])
    if ka and ka == kb and e.get("arc"):
        e["arc"] = list(tf(ka, *e["arc"]))
    elif (ka or kb) and ka != kb:
        e["arc"] = None                                     # bridge into an island: a straight road
for g in M.get("groups", []):
    ks = {member.get(i) for i in g.get("nodes", [])}
    if len(ks) == 1 and None not in ks and g.get("centre"):
        g["centre"] = list(tf(ks.pop(), *g["centre"]))
for kst in M.get("keystones", []):
    k = region_of(kst["x"], kst["y"])
    if k:
        kst["x"], kst["y"] = tf(k, kst["x"], kst["y"])
for ad in M.get("adds", []):
    pts = ad.get("p") or []
    ks = {region_of(*p) for p in pts}
    if len(ks) == 1 and None not in ks:
        k = ks.pop(); ad["p"] = [list(tf(k, *p)) for p in pts]
os.makedirs(OUT, exist_ok=True)
json.dump(M, open(os.path.join(OUT, "scaled-map.json"), "w", encoding="utf-8"))
json.dump({"scale": S, "islands": {k: {"centre": ISL[k][:2], "radius": ISL[k][2], "new_centre": shift[k],
                                       "nodes": sum(1 for v in member.values() if v == k)} for k in ISL},
           "member": member}, open(os.path.join(OUT, "island-transform.json"), "w", encoding="utf-8"))
print({k: sum(1 for v in member.values() if v == k) for k in ISL}, {k: [round(v, 1) for v in shift[k]] for k in ISL})
