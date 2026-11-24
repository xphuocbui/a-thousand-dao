"""Writes the combat-formation catalogue draft v2 (design/formations/catalogue-draft-v2-2026-11-24.json) for the
user's review (production/plans/combat-formations.md). User 2026-11-24: "be a bit more creative, lines don't have to
always be straight ... fancy looking formations like in the movies ... each trận should have levels and additional
slot ... a trận with just 2 slots but they feed each other". The rules and numbers are hand-authored here; only the
node and figure coordinates of regular shapes (circles, polygons, spirals) are computed.

Record additions over the engine's shape (design/gdd/formations.md rule 1): a node's `unlock` (the diagram level that
opens it; 1 = from the start), a link's `bend` (-1..1: a curved stroke, drawing only), and `figure` (decorative
strokes drawn behind the nodes: circle, arc, poly, spiral, wave, taiji, star). Usage: python -I tools/design/author_diagram_draft_v2.py"""
import json, math, os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
OUT = os.path.join(ROOT, "design", "formations", "catalogue-draft-50-2026-11-24.json")


def ring(n, r=1.0, start=-90.0):
    return [[round(r * math.cos(math.radians(start + 360.0 * i / n)), 3), round(r * math.sin(math.radians(start + 360.0 * i / n)), 3)] for i in range(n)]


def mod(key, v, scope=()):
    return {"type": "mod", "key": key, "value": v, "scope": list(scope)}


def adj(key, v, tag):
    return {"type": "adj_mod", "key": key, "value": v, "tag": tag}


def gate(read, op, v):
    return {"type": "gate", "cond": {"read": read, "op": op, "value": v}}


def node(pol, rule, score, pos, unlock=1):
    return {"polarity": pol, "rule": rule, "node_score": score, "pos": pos, "unlock": unlock}


def feed(a, b, s, bend=0.0, unlock=1):
    return {"kind": "feed", "from": a, "to": b, "seconds": s, "bend": bend, "unlock": unlock}


def link(a, b, bend=0.0, unlock=1):
    return {"kind": "adj", "a": a, "b": b, "bend": bend, "unlock": unlock}


D = []

# 1. The starter: a line that grows a node a level, along a serpent's wave
xs = [0.0, 1.0, 2.0, 3.0]
D.append({"id": "truong_xa", "name": "Long Serpent Line", "name_vi": "Trường Xà Trận", "grade": 0, "realm_min": 0, "skill_min": 0,
    "reserve_share": 0.02, "max_level": 3, "taught_by": "everyone (the starter)",
    "idea": "A line that grows a node with each level (2, 3, 4): the tail drives the body, the body drives the head.",
    "nodes": [node("+", mod("damage_pct", 14, ["heavy"]), 14, [0.0, 0.0]),
              node("+", mod("art_speed_pct", 10), 10, [1.0, 0.35]),
              node("+", mod("art_speed_pct", 10), 10, [2.0, -0.1], 2),
              node("-", mod("art_cost_pct", 12), -6, [3.0, 0.3], 3)],
    "links": [feed(2, 1, 0.8, 0.35), feed(3, 2, 0.8, -0.35), feed(4, 3, 0.8, 0.35)],
    "figure": [{"shape": "wave", "from": [-0.3, 0.0], "to": [3.4, 0.3], "amp": 0.28, "waves": 2.0},
               {"shape": "circle", "c": [0.0, 0.0], "r": 0.42}]})

# 2. Two nodes that feed each other, drawn as the taiji
D.append({"id": "luong_nghi", "name": "Two Poles", "name_vi": "Lưỡng Nghi Trận", "grade": 0, "realm_min": 0, "skill_min": 0,
    "reserve_share": 0.03, "max_level": 1, "taught_by": "Daoist and righteous sects, outer disciple",
    "idea": "Only two nodes, each feeding the other: yang strikes, yin pays. One level: it is complete as taught.",
    "nodes": [node("+", mod("damage_pct", 12), 12, [0.0, -0.5]),
              node("+", mod("art_cost_pct", -12), 10, [0.0, 0.5])],
    "links": [feed(1, 2, 1.2, 0.9), feed(2, 1, 1.2, 0.9)],
    "figure": [{"shape": "taiji", "c": [0.0, 0.0], "r": 1.0}]})

# 3. Three Talents: a triangle in a circle; the centre (the Dao) opens at level 3
t = ring(3, 1.0)
D.append({"id": "tam_tai", "name": "Three Talents", "name_vi": "Tam Tài Trận", "grade": 0, "realm_min": 0, "skill_min": 0,
    "reserve_share": 0.03, "max_level": 5, "taught_by": "sects of any path, outer disciple",
    "idea": "Heaven, Earth and Man around a circle; at level 3 the centre opens and all three feed it.",
    "nodes": [node("+", mod("art_speed_pct", 12), 12, t[0]),
              node("+", mod("art_cost_pct", -15, ["ward"]), 10, t[1]),
              node("+", mod("damage_pct", 12), 12, t[2]),
              node("+", mod("damage_pct", 20, ["heavy"]), 20, [0.0, 0.0], 3)],
    "links": [link(1, 2, 0.25), link(2, 3, 0.25), link(3, 1, 0.25), feed(1, 4, 0.8), feed(2, 4, 0.8), feed(3, 4, 0.8)],
    "figure": [{"shape": "circle", "c": [0.0, 0.0], "r": 1.0}, {"shape": "poly", "points": t, "closed": True},
               {"shape": "circle", "c": [0.0, 0.0], "r": 0.3}]})

# 4. Turtle Shell: a defensive shell of hexagon plates
D.append({"id": "quy_giap", "name": "Turtle Shell", "name_vi": "Quy Giáp Trận", "grade": 0, "realm_min": 1, "skill_min": 0,
    "reserve_share": 0.03, "max_level": 5, "taught_by": "righteous sects, outer disciple",
    "idea": "Plates of a shell around the wards: cheaper wards, faster beside them, a held heal for when it cracks. All four plates from the start; levels only harden them.",
    "nodes": [node("+", mod("art_cost_pct", -15, ["ward"]), 12, [0.0, 0.0]),
              node("+", adj("art_speed_pct", 12, "ward"), 8, [0.87, 0.5]),
              node("?", gate("own.hp_share", "<=", 0.6), 6, [-0.87, 0.5]),
              node("+", adj("art_cost_pct", -10, "ward"), 8, [0.0, -1.0])],
    "links": [link(1, 2), link(1, 3), link(1, 4)],
    "figure": [{"shape": "poly", "points": ring(6, 0.55, 0), "closed": True}, {"shape": "poly", "points": [[p[0] + 0.87, p[1] + 0.5] for p in ring(6, 0.55, 0)], "closed": True},
               {"shape": "poly", "points": [[p[0] - 0.87, p[1] + 0.5] for p in ring(6, 0.55, 0)], "closed": True},
               {"shape": "poly", "points": [[p[0], p[1] - 1.0] for p in ring(6, 0.55, 0)], "closed": True},
               {"shape": "circle", "c": [0.0, -0.1], "r": 1.6}]})

# 5. Four Symbols: the four beasts at the compass points, a node a level
c4 = ring(4, 1.0, 0)   # east, south, west, north
D.append({"id": "tu_tuong", "name": "Four Symbols", "name_vi": "Tứ Tượng Trận", "grade": 1, "realm_min": 1, "skill_min": 1,
    "reserve_share": 0.05, "max_level": 5, "taught_by": "formation-master sects, inner disciple",
    "idea": "All four beasts from the start, joined around the ring; at level 3 the crossing opens: Dragon feeds Tiger and Bird feeds Tortoise across the centre.",
    "nodes": [node("+", mod("art_speed_pct", 12, ["wood"]), 12, c4[0]),
              node("+", mod("damage_pct", 14, ["metal"]), 14, c4[2]),
              node("+", mod("damage_pct", 14, ["fire"]), 14, c4[1]),
              node("+", mod("art_cost_pct", -15, ["water"]), 12, c4[3])],
    "links": [link(1, 3, 0.4), link(3, 2, 0.4), link(2, 4, 0.4), link(4, 1, 0.4),
              feed(1, 2, 1.2, 0.0, 3), feed(3, 4, 1.2, 0.0, 3)],
    "figure": [{"shape": "circle", "c": [0.0, 0.0], "r": 1.0}, {"shape": "circle", "c": [0.0, 0.0], "r": 1.25},
               {"shape": "poly", "points": ring(4, 0.7, 45), "closed": True}]})

# 6. Five Phases: a pentagon of elements and the pentagram of their overcoming
p5 = ring(5, 1.0)
D.append({"id": "ngu_hanh", "name": "Five Phases", "name_vi": "Ngũ Hành Trận", "grade": 2, "realm_min": 2, "skill_min": 2,
    "reserve_share": 0.08, "max_level": 5, "taught_by": "formation-master sects, core disciple",
    "idea": "All five elements around the circle, each feeding the one it creates; at level 4 the star of overcoming lights up and each element also feeds the one it overcomes.",
    "nodes": [node("+", mod("damage_pct", 12, ["wood"]), 12, p5[0]), node("+", mod("damage_pct", 12, ["fire"]), 12, p5[1]),
              node("+", mod("damage_pct", 12, ["earth"]), 12, p5[2]), node("+", mod("damage_pct", 12, ["metal"]), 12, p5[3]),
              node("+", mod("damage_pct", 12, ["water"]), 12, p5[4])],
    "links": [feed(1, 2, 1.0, 0.3), feed(2, 3, 1.0, 0.3), feed(3, 4, 1.0, 0.3), feed(4, 5, 1.0, 0.3), feed(5, 1, 1.0, 0.3)] +
             [feed(a, b, 0.6, 0.0, 4) for a, b in [(1, 3), (3, 5), (5, 2), (2, 4), (4, 1)]],
    "figure": [{"shape": "circle", "c": [0.0, 0.0], "r": 1.0}, {"shape": "star", "c": [0.0, 0.0], "r": 1.0, "n": 5, "step": 2}]})

# 7. Sun and Moons: moons in orbit feed the sun, a moon a level
D.append({"id": "nhat_nguyet", "name": "Sun and Moons", "name_vi": "Nhật Nguyệt Trận", "grade": 1, "realm_min": 1, "skill_min": 1,
    "reserve_share": 0.05, "max_level": 5, "taught_by": "great sects, inner disciple",
    "idea": "A heavy art at the sun with one moon in orbit; a second moon rises at level 3 and a third at level 5. Each moon pays a price and feeds the sun.",
    "nodes": [node("+", mod("damage_pct", 24, ["heavy"]), 24, [0.0, 0.0])] +
             [node("-", mod("art_cost_pct", 12), -5, pos, u) for pos, u in zip(ring(3, 1.0, -90), [1, 3, 5])],
    "links": [feed(i, 1, 0.8, 0.25) for i in range(2, 5)],
    "figure": [{"shape": "circle", "c": [0.0, 0.0], "r": 1.0}, {"shape": "circle", "c": [0.0, 0.0], "r": 0.45},
               {"shape": "rays", "c": [0.0, 0.0], "r0": 0.2, "r1": 0.55, "n": 12}]})

# 8. Back to the River: a last stand along a river's curve
D.append({"id": "boi_thuy", "name": "Back to the River", "name_vi": "Bối Thủy Trận", "grade": 1, "realm_min": 1, "skill_min": 1,
    "reserve_share": 0.04, "max_level": 1, "taught_by": "a loose cultivators' manual (a later drop); sects of any path, inner disciple",
    "idea": "With your back to the river: a held art for below half health, a strong art beside it, and a costly feeder that drives the held one. One level: a desperate trick, never refined.",
    "nodes": [node("?", gate("own.hp_share", "<=", 0.5), 6, [0.0, 0.0]),
              node("+", mod("damage_pct", 30), 30, [1.1, -0.35]),
              node("-", mod("art_cost_pct", 25), -8, [-1.1, -0.35])],
    "links": [feed(3, 1, 2.0, -0.5), link(2, 1, 0.25)],
    "figure": [{"shape": "wave", "from": [-1.6, 0.7], "to": [2.6, 0.7], "amp": 0.12, "waves": 4.0},
               {"shape": "wave", "from": [-1.6, 0.95], "to": [2.6, 0.95], "amp": 0.12, "waves": 4.0},
               {"shape": "arc", "c": [0.5, 0.7], "r": 1.7, "a0": 200, "a1": 340}]})

# 9. Soul-maze spiral: control arts wind inward; the finisher waits until the maze has closed
sp = [[round(r * math.cos(a), 3), round(r * math.sin(a), 3)] for r, a in [(1.8, 0.2), (1.4, 2.2), (0.95, 4.3), (0.45, 5.0), (0.0, 0.0)]]
D.append({"id": "me_hon", "name": "Soul Maze", "name_vi": "Mê Hồn Trận", "grade": 1, "realm_min": 1, "skill_min": 1,
    "reserve_share": 0.05, "max_level": 3, "taught_by": "demonic and curse sects, inner disciple",
    "idea": "Curses spiral inward toward a centre that fires only after 10 s, when the maze has closed. Four nodes always; three levels.",
    "nodes": [node("+", mod("art_speed_pct", 10, ["curse"]), 10, sp[0]), node("+", mod("art_speed_pct", 10), 10, sp[1]),
              node("+", mod("damage_pct", 18, ["curse"]), 18, sp[2]), node("?", gate("time", ">=", 10), 6, sp[4])],
    "links": [feed(1, 2, 1.0, 0.4), feed(2, 3, 1.0, 0.4), feed(3, 4, 1.0, 0.5)],
    "figure": [{"shape": "spiral", "c": [0.0, 0.0], "r0": 0.15, "r1": 2.0, "turns": 2.2}]})

# 10. Twin Dragons play with the pearl
D.append({"id": "song_long", "name": "Twin Dragons and the Pearl", "name_vi": "Song Long Hí Châu Trận", "grade": 2, "realm_min": 2, "skill_min": 2,
    "reserve_share": 0.07, "max_level": 5, "taught_by": "great sects, core disciple",
    "idea": "Two dragons coil toward a pearl and their heads feed its heavy art; at level 4 both dragons grow their bodies at once, each feeding its head.",
    "nodes": [node("+", mod("damage_pct", 28, ["heavy"]), 28, [0.0, 0.0]),
              node("+", mod("art_speed_pct", 12), 12, [-0.9, -0.45]), node("+", mod("art_speed_pct", 12), 12, [0.9, 0.45]),
              node("+", mod("damage_pct", 12), 12, [-1.7, 0.3], 4), node("+", mod("damage_pct", 12), 12, [1.7, -0.3], 4)],
    "links": [feed(2, 1, 0.9, 0.4), feed(3, 1, 0.9, 0.4), feed(4, 2, 0.9, -0.6), feed(5, 3, 0.9, -0.6)],
    "figure": [{"shape": "wave", "from": [-2.2, 0.6], "to": [-0.2, -0.1], "amp": 0.35, "waves": 1.5},
               {"shape": "wave", "from": [2.2, -0.6], "to": [0.2, 0.1], "amp": 0.35, "waves": 1.5},
               {"shape": "circle", "c": [0.0, 0.0], "r": 0.32}, {"shape": "rays", "c": [0.0, 0.0], "r0": 0.34, "r1": 0.5, "n": 10}]})

# 11. Seven Stars of the Northern Dipper: the bowl first, the handle a star a level, the sword star last
dip = [[round(x * 1.7, 2), round(y * 1.7, 2)] for x, y in [[-1.6, -0.5], [-0.7, -0.8], [-0.5, 0.1], [-1.4, 0.4], [0.4, 0.1], [1.2, 0.35], [2.0, 0.0]]]
D.append({"id": "that_tinh", "name": "Seven Stars of the Northern Dipper", "name_vi": "Thất Tinh Bắc Đẩu Trận", "grade": 2, "realm_min": 2, "skill_min": 2,
    "reserve_share": 0.08, "max_level": 4, "taught_by": "sword sects, core disciple",
    "idea": "The four bowl stars from the start, each quicker beside a sword art; at level 3 the whole handle appears at once, feeding toward Dao Quang, the sword star at its end (seven nodes: Hóa Thần, or a bonus art slot).",
    "nodes": [node("+", adj("art_speed_pct", 10, "sword"), 10, p) for p in dip[:4]] +
             [node("+", mod("art_speed_pct", 10), 10, dip[4], 3), node("+", mod("art_speed_pct", 10), 10, dip[5], 3),
              node("+", mod("damage_pct", 30, ["sword"]), 30, dip[6], 3)],
    "links": [link(1, 2), link(2, 3), link(3, 4), link(4, 1), feed(3, 5, 1.0), feed(5, 6, 1.0), feed(6, 7, 1.0)],
    "figure": [{"shape": "poly", "points": dip, "closed": False}, {"shape": "poly", "points": [dip[2], dip[3]], "closed": False},
               {"shape": "stars", "c": [0.34, -0.34], "r": 2.4, "n": 34}]})

# 12. Eight Trigrams: an octagon around the taiji, the trigrams a node a level (the eighth needs a bonus art slot)
o8 = ring(8, 1.0, -90)
D.append({"id": "bat_quai", "name": "Eight Trigrams", "name_vi": "Bát Quái Trận", "grade": 3, "realm_min": 3, "skill_min": 3,
    "reserve_share": 0.12, "max_level": 5, "taught_by": "formation-master great sects, elder",
    "idea": "The four cardinal trigrams from the start, opposite pairs feeding across the taiji; at level 4 the four between them open together, joined in a ring (eight nodes: Hóa Thần with a bonus art slot).",
    "nodes": [node("+", mod(["damage_pct", "art_speed_pct"][i % 2], 10), 10, o8[k], u)
              for i, (k, u) in enumerate([(0, 1), (2, 1), (4, 1), (6, 1), (1, 4), (3, 4), (5, 4), (7, 4)])],
    "links": [feed(1, 3, 0.8, 0.0), feed(3, 1, 0.8, 0.0), feed(2, 4, 0.8, 0.0), feed(4, 2, 0.8, 0.0),
              link(5, 6, 0.3, 4), link(6, 7, 0.3, 4), link(7, 8, 0.3, 4), link(8, 5, 0.3, 4)],
    "figure": [{"shape": "poly", "points": o8, "closed": True}, {"shape": "poly", "points": ring(8, 1.25, -90 + 22.5), "closed": True},
               {"shape": "taiji", "c": [0.0, 0.0], "r": 0.45}, {"shape": "trigrams", "c": [0.0, 0.0], "r": 1.45}]})

import sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from author_diagram_draft_more import M   # the 38 further diagrams (user: "at least 38 more so it reaches 50")
D += M
assert len(set(g["id"] for g in D)) == len(D), "duplicate ids"
doc = {"_doc": "DRAFT v2 for the user's approval (production/plans/combat-formations.md; written by tools/design/author_diagram_draft_v2.py). As the engine's diagram record (design/gdd/formations.md rule 1) plus: node unlock (the diagram level that opens it), link bend (drawing only), figure (decorative strokes behind the nodes). Values at strength 1; positive and gate nodes and feeds scale with S, negative ones do not.",
       "starter": "truong_xa", "diagrams": D}
for g in D:
    g.setdefault("max_level", 5)
    for l in g["links"]:   # a link opens with the later of its two nodes
        ends = (l["a"], l["b"]) if l["kind"] == "adj" else (l["from"], l["to"])
        l["unlock"] = max(l.get("unlock", 1), *[g["nodes"][e - 1].get("unlock", 1) for e in ends])
json.dump(doc, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
print("wrote", OUT, len(D))
