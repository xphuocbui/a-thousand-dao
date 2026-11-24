"""The 38 further diagrams of the combat-formation catalogue draft (user 2026-11-24: "this is ok, should probably
add more, at least 38 more so it reaches 50"; "I just don't want things to repeat"). Imported by
author_diagram_draft_v2.py, which appends them to its 12. Hand-authored: each has its own figure, theme and way of
growing (one level; strength only; a centre, a pair, a group or links opening at a level; irregular orbits), across
grades 0-4 and every kind of art. Only regular-shape coordinates are computed."""
import math


def ring(n, r=1.0, start=-90.0, c=(0.0, 0.0)):
    return [[round(c[0] + r * math.cos(math.radians(start + 360.0 * i / n)), 3), round(c[1] + r * math.sin(math.radians(start + 360.0 * i / n)), 3)] for i in range(n)]


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


def dg(id, name, vi, grade, realm, skill, reserve, max_level, taught, idea, nodes, links, figure):
    return {"id": id, "name": name, "name_vi": vi, "grade": grade, "realm_min": realm, "skill_min": skill, "reserve_share": reserve,
            "max_level": max_level, "taught_by": taught, "idea": idea, "nodes": nodes, "links": links, "figure": figure}


SPD, DMG, CST = "art_speed_pct", "damage_pct", "art_cost_pct"
M = []

# ---------------------------------------------------------------- grade 0: Luyện Khí (3 art slots)
M.append(dg("ba_hoa", "Three Flowers at the Crown", "Tam Hoa Tụ Đỉnh Trận", 0, 0, 0, 0.03, 3, "Daoist sects, outer disciple",
    "Three petals around a crown: each petal's art is cheaper, and all three feed the crown when it opens at level 2.",
    [node("+", mod(CST, -10), 8, [0.0, -1.0]), node("+", mod(CST, -10), 8, [0.87, 0.5]), node("+", mod(CST, -10), 8, [-0.87, 0.5]),
     node("+", mod(DMG, 16), 16, [0.0, 0.0], 2)],
    [feed(1, 4, 0.7, 0.0, 2), feed(2, 4, 0.7, 0.0, 2), feed(3, 4, 0.7, 0.0, 2)],
    [{"shape": "petals", "c": [0.0, 0.0], "r": 1.0, "n": 3, "w": 0.55}, {"shape": "circle", "c": [0.0, 0.0], "r": 0.35}]))
M.append(dg("phong_hoa_luan", "Wind and Fire Wheels", "Phong Hỏa Luân Trận", 0, 0, 0, 0.02, 2, "a wandering cultivator's manual (a drop)",
    "Two wheels side by side: the wind wheel spins the fire wheel faster, the fire wheel burns hotter. Two levels.",
    [node("+", mod(SPD, 14, ["wind"]), 14, [-0.8, 0.0]), node("+", mod(DMG, 14, ["fire"]), 14, [0.8, 0.0])],
    [feed(1, 2, 1.0, 0.5)],
    [{"shape": "wheel", "c": [-0.8, 0.0], "r": 0.62, "n": 8}, {"shape": "wheel", "c": [0.8, 0.0], "r": 0.62, "n": 8}]))
M.append(dg("thanh_phong_kiem", "Clear Breeze Sword", "Thanh Phong Kiếm Trận", 0, 0, 0, 0.02, 4, "sword sects, outer disciple",
    "Along a blade: hilt, edge and point. The point opens at level 4 and the edge feeds it.",
    [node("+", mod(SPD, 10, ["sword"]), 10, [-1.4, 0.0]), node("+", mod(DMG, 12, ["sword"]), 12, [0.0, 0.0]),
     node("+", mod(DMG, 22, ["sword"]), 22, [1.4, 0.0], 4)],
    [feed(1, 2, 0.8), feed(2, 3, 0.8, 0.0, 4)],
    [{"shape": "sword", "from": [-2.0, 0.0], "to": [2.0, 0.0], "w": 0.18}]))
M.append(dg("hoi_xuan", "Spring Return", "Hồi Xuân Trận", 0, 0, 0, 0.03, 5, "healing and alchemist sects, outer disciple",
    "A sprouting branch for healers: cheaper heals, and a heal that waits until you are below 70 % health.",
    [node("+", mod(CST, -15, ["heal"]), 12, [0.0, 0.6]), node("?", gate("own.hp_share", "<=", 0.7), 6, [-0.8, -0.4]),
     node("+", adj(SPD, 12, "heal"), 8, [0.8, -0.4])],
    [link(1, 2, 0.3), link(1, 3, -0.3)],
    [{"shape": "branch", "from": [0.0, 1.4], "to": [0.0, -1.2], "leaves": 6}]))
M.append(dg("loi_dinh", "Thunderclap", "Lôi Đình Nhất Kích Trận", 0, 0, 0, 0.02, 1, "lightning sects, outer disciple",
    "Two nodes and a bolt: the striker charges the finisher, which waits until the foe is below 30 % health. One level.",
    [node("+", mod(SPD, 12, ["lightning"]), 12, [-0.9, -0.6]), node("?", gate("foe.hp_share", "<=", 0.3), 6, [0.9, 0.6])],
    [feed(1, 2, 1.5, 0.0)],
    [{"shape": "zigzag", "from": [-1.4, -1.0], "to": [1.4, 1.0], "n": 5, "amp": 0.35}]))
M.append(dg("tho_bich", "Earth Wall", "Thổ Độn Bích Trận", 0, 0, 0, 0.03, 3, "earth and body sects, outer disciple",
    "Three peaks of a wall: cheaper bulwark and ward arts, and earth arts quicker beside them.",
    [node("+", mod(CST, -12, ["bulwark"]), 10, [-1.0, 0.2]), node("+", adj(SPD, 10, "ward"), 8, [0.0, -0.3]),
     node("+", mod(DMG, 10, ["earth"]), 10, [1.0, 0.2])],
    [link(1, 2), link(2, 3)],
    [{"shape": "mountains", "from": [-1.8, 0.7], "to": [1.8, 0.7], "n": 3, "h": 1.2}]))

# ---------------------------------------------------------------- grade 1: Trúc Cơ (4 art slots)
M.append(dg("tu_mon", "Four Gates", "Tứ Môn Trận", 1, 1, 1, 0.05, 4, "formation-master sects, inner disciple",
    "A square courtyard with a gate on each side: two gates open at first, the third at level 2, the last at level 4; each gate quickens the next.",
    [node("+", mod(SPD, 10), 10, [0.0, -1.0]), node("+", mod(DMG, 12), 12, [1.0, 0.0]), node("+", mod(SPD, 10), 10, [0.0, 1.0], 2),
     node("+", mod(DMG, 12), 12, [-1.0, 0.0], 4)],
    [feed(1, 2, 0.8, 0.3), feed(2, 3, 0.8, 0.3, 2), feed(3, 4, 0.8, 0.3, 4), feed(4, 1, 0.8, 0.3, 4)],
    [{"shape": "poly", "points": [[-1.0, -1.0], [1.0, -1.0], [1.0, 1.0], [-1.0, 1.0]], "closed": True},
     {"shape": "gates", "c": [0.0, 0.0], "r": 1.0}]))
M.append(dg("thuy_liem", "Water Curtain", "Thủy Liêm Trận", 1, 1, 1, 0.04, 5, "water sects, inner disciple",
    "Four drops along a falling curtain, water arts each; at level 3 the curtain closes and the drops feed each other down it.",
    [node("+", mod(DMG, 12, ["water"]), 12, [-1.2, -0.6]), node("+", mod(SPD, 10, ["water"]), 10, [-0.4, 0.2]),
     node("+", mod(DMG, 12, ["water"]), 12, [0.4, -0.2]), node("+", mod(CST, -12, ["water"]), 10, [1.2, 0.6])],
    [feed(1, 2, 0.8, 0.4, 3), feed(2, 3, 0.8, -0.4, 3), feed(3, 4, 0.8, 0.4, 3)],
    [{"shape": "strings", "from": [-1.6, -1.2], "to": [-1.6, 1.2], "n": 9, "gap": 0.4}]))
M.append(dg("hoa_long_quyen", "Fire Dragon Coil", "Hỏa Long Quyển Trận", 1, 1, 1, 0.05, 4, "fire sects, inner disciple",
    "A fire dragon coils inward to its head; a fourth coil opens at level 4. The tail pays the price.",
    [node("-", mod(CST, 15), -6, [1.4, 0.3]), node("+", mod(SPD, 12, ["fire"]), 12, [0.0, 1.1]), node("+", mod(DMG, 20, ["fire"]), 20, [0.0, 0.0]),
     node("+", mod(SPD, 12, ["fire"]), 12, [-1.2, -0.2], 4)],
    [feed(1, 2, 1.0, 0.5), feed(2, 3, 1.0, 0.5), feed(4, 3, 1.0, 0.5, 4)],
    [{"shape": "spiral", "c": [0.0, 0.0], "r0": 0.2, "r1": 1.6, "turns": 1.3}, {"shape": "flame", "c": [0.0, 0.0], "r": 0.45}]))
M.append(dg("bang_phong", "Ice Seal", "Băng Phong Vạn Lý Trận", 1, 1, 1, 0.05, 5, "cold sects, inner disciple",
    "A six-pointed ice crystal: cold arts beside each other run quicker; its control node holds until the foe carries two statuses.",
    [node("+", adj(SPD, 12, "cold"), 10, [0.0, -1.0]), node("+", adj(DMG, 12, "cold"), 10, [0.87, 0.5]), node("+", adj(DMG, 12, "cold"), 10, [-0.87, 0.5]),
     node("?", gate("foe.distinct_statuses", ">=", 2), 6, [0.0, 0.0])],
    [link(1, 2), link(2, 3), link(3, 1), link(1, 4), link(2, 4), link(3, 4)],
    [{"shape": "crystal", "c": [0.0, 0.0], "r": 1.25}]))
M.append(dg("khon_tien_vong", "Immortal-Binding Net", "Khốn Tiên Võng Trận", 1, 1, 1, 0.06, 5, "demonic sects, inner disciple",
    "A net of four knots: seal arts bind quicker beside control arts, and the net's last knot holds a curse until the foe is cursed twice.",
    [node("+", adj(SPD, 14, "control"), 12, [-0.8, -0.8]), node("+", adj(SPD, 14, "seal"), 12, [0.8, -0.8]),
     node("+", mod(DMG, 12, ["seal"]), 12, [0.8, 0.8]), node("?", gate("foe.curses", ">=", 2), 6, [-0.8, 0.8])],
    [link(1, 2), link(2, 3), link(3, 4), link(4, 1), link(1, 3, 0.0), link(2, 4, 0.0)],
    [{"shape": "net", "c": [0.0, 0.0], "r": 1.5, "rings": 3, "spokes": 8}]))
M.append(dg("hac_sat", "Black Fiend Wind", "Hắc Sát Âm Phong Trận", 1, 1, 1, 0.05, 3, "demonic sects, inner disciple",
    "A cold wind of poisons: two costly nodes drive the poison and curse arts hard. Strong and expensive.",
    [node("-", mod(CST, 20), -8, [-1.2, 0.5]), node("-", mod(CST, 20), -8, [-1.2, -0.5]),
     node("+", mod(DMG, 22, ["poison"]), 22, [0.4, 0.0]), node("+", mod(SPD, 16, ["curse"]), 16, [1.4, 0.0])],
    [feed(1, 3, 1.2, -0.4), feed(2, 3, 1.2, 0.4), feed(3, 4, 0.8)],
    [{"shape": "cloud", "c": [-0.4, 0.0], "r": 1.2}, {"shape": "wave", "from": [-1.8, 0.0], "to": [1.9, 0.0], "amp": 0.2, "waves": 2.5}]))
M.append(dg("kim_chung", "Golden Bell Cover", "Kim Chung Tráo Trận", 1, 1, 1, 0.04, 5, "body-cultivation and Buddhist sects, inner disciple",
    "A bell over the body: body arts and bells cheaper, and a struck bell rings back while your body shield holds.",
    [node("+", mod(CST, -15, ["body"]), 12, [0.0, -0.6]), node("+", mod(DMG, 12, ["bell"]), 12, [-0.7, 0.5]),
     node("?", gate("own.body_shield_share", ">", 0.0), 6, [0.7, 0.5])],
    [link(1, 2), link(1, 3), feed(2, 3, 1.0, 0.3)],
    [{"shape": "bell", "c": [0.0, 0.0], "r": 1.2}]))
M.append(dg("lien_hoa", "Lotus Throne", "Liên Hoa Tọa Trận", 1, 1, 1, 0.05, 5, "Buddhist and healing sects, inner disciple",
    "A seat with two petals; at level 3 two more petals open together. The petals carry the seat's heals and wards.",
    [node("+", mod(CST, -12, ["heal"]), 12, [0.0, 0.0]), node("+", adj(SPD, 10, "heal"), 8, [-1.0, 0.0]), node("+", adj(SPD, 10, "ward"), 8, [1.0, 0.0]),
     node("+", adj(CST, -10, "heal"), 8, [0.0, -1.0], 3), node("+", adj(CST, -10, "ward"), 8, [0.0, 1.0], 3)],
    [link(1, 2), link(1, 3), link(1, 4, 0.0, 3), link(1, 5, 0.0, 3)],
    [{"shape": "petals", "c": [0.0, 0.0], "r": 1.2, "n": 8, "w": 0.4}, {"shape": "circle", "c": [0.0, 0.0], "r": 0.4}]))
M.append(dg("cam_am", "Seven-String Zither", "Thất Huyền Cầm Âm Trận", 1, 1, 1, 0.04, 5, "music sects, inner disciple",
    "Strings of a zither: song arts beside each other play quicker; the third string waits for the fifth pulse of every cycle.",
    [node("+", adj(SPD, 12, "song"), 10, [-1.0, -0.6]), node("+", adj(DMG, 12, "song"), 10, [0.0, -0.6]),
     node("?", gate("cycle.5", "==", 0), 6, [1.0, -0.6]), node("+", mod(CST, -10, ["song"]), 10, [0.0, 0.6])],
    [link(1, 2), link(2, 3), link(2, 4)],
    [{"shape": "strings", "from": [-1.8, -1.2], "to": [1.8, -1.2], "n": 7, "gap": 0.35, "horizontal": True}]))
M.append(dg("pha_quan", "Army-Breaker Wedge", "Phá Quân Trận", 1, 1, 1, 0.05, 5, "spear and military sects, inner disciple",
    "A spearhead wedge: the point and two shoulders from the start; at level 4 both flanks open together and drive the shoulders.",
    [node("+", mod(DMG, 18, ["spear"]), 18, [1.3, 0.0]), node("+", mod(SPD, 10), 10, [0.3, -0.6]), node("+", mod(SPD, 10), 10, [0.3, 0.6]),
     node("-", mod(DMG, -12), -6, [-0.8, -1.1], 4), node("-", mod(DMG, -12), -6, [-0.8, 1.1], 4)],
    [feed(2, 1, 0.9), feed(3, 1, 0.9), feed(4, 2, 0.9, 0.0, 4), feed(5, 3, 0.9, 0.0, 4)],
    [{"shape": "chevron", "points": [[-1.3, -1.5], [1.8, 0.0], [-1.3, 1.5]]}, {"shape": "chevron", "points": [[-0.9, -1.0], [1.2, 0.0], [-0.9, 1.0]]}]))
M.append(dg("nguyet_anh", "Moon Shadow", "Nguyệt Ảnh Trận", 1, 1, 1, 0.03, 2, "assassin and wind sects, inner disciple",
    "On a crescent: quick arts strike first and fastest, and the shadow's blow only lands in the first 8 s. Two levels.",
    [node("+", mod(SPD, 16, ["quick"]), 16, [-0.6, -0.8]), node("+", mod(DMG, 12, ["quick"]), 12, [-0.9, 0.2]), node("?", gate("time", "<=", 8), 6, [-0.4, 1.0])],
    [feed(1, 2, 0.7, 0.3), feed(2, 3, 0.7, 0.3)],
    [{"shape": "crescent", "c": [0.0, 0.0], "r": 1.3}]))

# ---------------------------------------------------------------- grade 2: Kết Đan (5 art slots)
M.append(dg("van_kiem", "Myriad Swords Return", "Vạn Kiếm Quy Tông Trận", 2, 2, 2, 0.08, 5, "sword great sects, core disciple",
    "A fan of blades converging on one: four sword nodes feed the centre's heavy sword art. No growth, only strength.",
    [node("+", mod(DMG, 26, ["sword"]), 26, [0.0, 0.8])] +
    [node("+", mod(SPD, 10, ["sword"]), 10, [x, -0.6]) for x in (-1.5, -0.5, 0.5, 1.5)],
    [feed(i, 1, 0.7, 0.0) for i in range(2, 6)],
    [{"shape": "rays", "c": [0.0, 0.8], "r0": 0.4, "r1": 2.0, "n": 14, "a0": 200, "a1": 340}, {"shape": "sword", "from": [0.0, 1.9], "to": [0.0, 0.4], "w": 0.14}]))
M.append(dg("cuu_cung", "Nine Palaces", "Cửu Cung Trận", 2, 2, 2, 0.09, 5, "formation-master great sects, core disciple",
    "The magic square: the centre cross of five from the start; two corners at level 3, the other two at level 5 (nine nodes: only with bonus art slots). Corners quicken the arts beside them.",
    [node("+", mod(DMG, 16), 16, [0.0, 0.0]), node("+", mod(SPD, 10), 10, [0.0, -1.0]), node("+", mod(SPD, 10), 10, [1.0, 0.0]),
     node("+", mod(SPD, 10), 10, [0.0, 1.0]), node("+", mod(SPD, 10), 10, [-1.0, 0.0]),
     node("+", adj(DMG, 10, "quick"), 8, [1.0, -1.0], 3), node("+", adj(DMG, 10, "quick"), 8, [-1.0, 1.0], 3),
     node("+", adj(DMG, 10, "heavy"), 8, [1.0, 1.0], 5), node("+", adj(DMG, 10, "heavy"), 8, [-1.0, -1.0], 5)],
    [feed(2, 1, 0.6), feed(3, 1, 0.6), feed(4, 1, 0.6), feed(5, 1, 0.6), link(6, 2, 0.0, 3), link(6, 3, 0.0, 3), link(7, 4, 0.0, 3), link(7, 5, 0.0, 3),
     link(8, 3, 0.0, 5), link(8, 4, 0.0, 5), link(9, 5, 0.0, 5), link(9, 2, 0.0, 5)],
    [{"shape": "grid", "c": [0.0, 0.0], "size": 2.6, "n": 3}, {"shape": "circle", "c": [0.0, 0.0], "r": 1.75}]))
M.append(dg("thien_la", "Heaven's Net, Earth's Snare", "Thiên La Địa Võng Trận", 2, 2, 2, 0.08, 4, "demonic great sects, core disciple",
    "Above, a net of control; below, a snare of seals. The snare's jaw closes only on a foe below half health.",
    [node("+", adj(SPD, 14, "control"), 12, [-1.0, -0.8]), node("+", adj(SPD, 14, "control"), 12, [1.0, -0.8]),
     node("+", mod(DMG, 16, ["seal"]), 16, [-1.0, 0.8]), node("+", mod(DMG, 16, ["seal"]), 16, [1.0, 0.8]), node("?", gate("foe.hp_share", "<=", 0.5), 6, [0.0, 0.0])],
    [link(1, 2), link(3, 4), feed(1, 5, 0.8, 0.0), feed(2, 5, 0.8, 0.0), link(3, 5), link(4, 5)],
    [{"shape": "net", "c": [0.0, -0.8], "r": 1.2, "rings": 2, "spokes": 6}, {"shape": "arc", "c": [0.0, -0.3], "r": 1.5, "a0": 20, "a1": 160}]))
M.append(dg("huyet_hai", "Sea of Blood", "Huyết Hải Trận", 2, 2, 2, 0.07, 3, "blood-path demonic sects, core disciple",
    "A red tide that rises with your wounds: two nodes strike only once you have lost half your health, a third pays the tide's price.",
    [node("?", gate("own.hp_missing_share", ">=", 0.5), 6, [-1.0, 0.0]), node("?", gate("own.hp_missing_share", ">=", 0.5), 6, [1.0, 0.0]),
     node("+", mod(DMG, 30), 30, [0.0, -0.8]), node("-", mod(CST, 25), -8, [0.0, 0.8])],
    [feed(4, 1, 1.2, 0.4), feed(4, 2, 1.2, -0.4), link(1, 3), link(2, 3)],
    [{"shape": "wave", "from": [-2.0, 0.4], "to": [2.0, 0.4], "amp": 0.18, "waves": 5}, {"shape": "wave", "from": [-2.0, 0.8], "to": [2.0, 0.8], "amp": 0.18, "waves": 5},
     {"shape": "wave", "from": [-2.0, 1.2], "to": [2.0, 1.2], "amp": 0.18, "waves": 5}]))
M.append(dg("tinh_ha", "River of Stars", "Tinh Hà Trận", 2, 2, 2, 0.07, 5, "star-gazing sects, core disciple",
    "Five stars along the galaxy's curve, each feeding the next downstream; at level 5 the river closes into a loop.",
    [node("+", mod(SPD, 10), 10, [-2.0, 0.6]), node("+", mod(SPD, 10), 10, [-1.0, -0.2]), node("+", mod(DMG, 12), 12, [0.0, -0.4]),
     node("+", mod(SPD, 10), 10, [1.0, -0.2]), node("+", mod(DMG, 20, ["heavy"]), 20, [2.0, 0.6])],
    [feed(1, 2, 0.7, 0.2), feed(2, 3, 0.7, 0.2), feed(3, 4, 0.7, 0.2), feed(4, 5, 0.7, 0.2), feed(5, 1, 1.0, -0.6, 5)],
    [{"shape": "band", "from": [-2.4, 0.9], "to": [2.4, 0.9], "sag": -1.3, "w": 0.5}, {"shape": "stars", "c": [0.0, 0.1], "r": 1.9, "n": 30}]))
M.append(dg("phong_loi", "Wind and Thunder", "Phong Lôi Trận", 2, 2, 2, 0.06, 5, "lightning and wind sects, core disciple",
    "Two wind nodes and two thunder nodes in alternation; wind feeds thunder, thunder feeds wind, and the eye of the storm opens at level 4.",
    [node("+", mod(SPD, 12, ["wind"]), 12, [-1.0, -0.6]), node("+", mod(DMG, 14, ["lightning"]), 14, [1.0, -0.6]),
     node("+", mod(SPD, 12, ["wind"]), 12, [1.0, 0.6]), node("+", mod(DMG, 14, ["lightning"]), 14, [-1.0, 0.6]),
     node("+", mod(DMG, 18), 18, [0.0, 0.0], 4)],
    [feed(1, 2, 0.8, 0.3), feed(2, 3, 0.8, 0.3), feed(3, 4, 0.8, 0.3), feed(4, 1, 0.8, 0.3), link(1, 5, 0.0, 4), link(3, 5, 0.0, 4)],
    [{"shape": "spiral", "c": [0.0, 0.0], "r0": 0.2, "r1": 1.4, "turns": 1.0}, {"shape": "zigzag", "from": [-1.6, -1.2], "to": [1.6, 1.2], "n": 6, "amp": 0.25}]))
M.append(dg("kim_cuong", "Vajra Demon-Subduing", "Kim Cương Phục Ma Trận", 2, 2, 2, 0.08, 5, "Buddhist great sects, core disciple",
    "The vajra's two prongs and its grip: wards and bulwarks cheap at the grip, the prongs strike hardest while your body shield holds.",
    [node("+", mod(CST, -15, ["ward"]), 12, [0.0, -0.3]), node("+", mod(CST, -15, ["bulwark"]), 12, [0.0, 0.85]),
     node("?", gate("own.body_shield_share", ">", 0.2), 6, [0.0, -1.3]), node("?", gate("own.body_shield_share", ">", 0.2), 6, [0.0, 1.8]),
     node("+", adj(DMG, 14, "ward"), 10, [-0.9, 0.25])],
    [link(1, 2), link(1, 3), link(2, 4), link(1, 5)],
    [{"shape": "vajra", "c": [0.0, 0.25], "len": 3.4}]))
M.append(dg("bach_quy", "Night Parade of a Hundred Ghosts", "Bách Quỷ Dạ Hành Trận", 2, 2, 2, 0.07, 5, "ghost-path demonic sects, core disciple",
    "A procession of summons under lanterns; two more ghosts join the end of the line at level 5. Each ghost hastens the one ahead.",
    [node("+", mod(DMG, 16, ["summon"]), 16, [1.8, 0.0]), node("+", mod(SPD, 10, ["summon"]), 10, [0.9, 0.4]), node("+", mod(SPD, 10, ["summon"]), 10, [0.0, 0.1]),
     node("-", mod(CST, 15), -6, [-0.9, 0.4], 5), node("-", mod(CST, 15), -6, [-1.8, 0.0], 5)],
    [feed(2, 1, 0.8, 0.3), feed(3, 2, 0.8, -0.3), feed(4, 3, 0.8, 0.3, 5), feed(5, 4, 0.8, -0.3, 5)],
    [{"shape": "lanterns", "from": [-2.2, -0.7], "to": [2.2, -0.7], "n": 6}, {"shape": "wave", "from": [-2.2, 0.2], "to": [2.2, 0.2], "amp": 0.2, "waves": 2}]))
M.append(dg("doc_long", "Poison Dragon Drill", "Độc Long Toản Trận", 2, 2, 2, 0.06, 3, "poison sects, core disciple",
    "A drill that bores into a cursed foe: its tip strikes only once the foe carries three curses; the threads feed the tip.",
    [node("+", mod(SPD, 14, ["poison"]), 12, [-1.2, -0.3]), node("+", mod(SPD, 14, ["poison"]), 12, [-1.2, 0.3]),
     node("+", mod(DMG, 16, ["poison"]), 16, [0.0, 0.0]), node("?", gate("foe.curses", ">=", 3), 6, [1.4, 0.0])],
    [feed(1, 3, 0.8, -0.2), feed(2, 3, 0.8, 0.2), feed(3, 4, 1.2)],
    [{"shape": "drill", "from": [-1.8, 0.0], "to": [2.0, 0.0], "w": 0.7, "turns": 5}]))
M.append(dg("con_bang", "Kun Becomes Peng", "Côn Bằng Trận", 2, 2, 2, 0.06, 5, "a ruin's carvings (found by exploring)",
    "Fish below, bird above: the fish half pays and feeds the bird half, which strikes only while your linh lực is above 60 %.",
    [node("-", mod(CST, 15), -6, [-1.0, 0.7]), node("-", mod(CST, 15), -6, [1.0, 0.7]), node("+", mod(SPD, 12), 12, [0.0, 0.9]),
     node("?", gate("own.qi_share", ">=", 0.6), 6, [-0.8, -0.8]), node("+", mod(DMG, 22), 22, [0.8, -0.8])],
    [feed(1, 4, 1.0, 0.4), feed(2, 5, 1.0, -0.4), link(3, 1), link(3, 2), link(4, 5, 0.3)],
    [{"shape": "wave", "from": [-2.0, 1.1], "to": [2.0, 1.1], "amp": 0.15, "waves": 3}, {"shape": "wings", "c": [0.0, -0.6], "r": 1.8}]))

# ---------------------------------------------------------------- grade 3: Nguyên Anh (6 art slots)
M.append(dg("luc_hop", "Six Harmonies", "Lục Hợp Trận", 3, 3, 3, 0.1, 5, "formation-master great sects, elder",
    "Two triangles of a hexagram: the upward one quickens, the downward one strikes; each point is beside its two neighbours of the other triangle.",
    [node("+", adj(SPD, 10, "heavy"), 10, p) for p in ring(3, 1.2, -90)] + [node("+", adj(DMG, 12, "quick"), 10, p) for p in ring(3, 1.2, 90)],
    [link(1, 6), link(1, 5), link(2, 4), link(2, 6), link(3, 4), link(3, 5)],
    [{"shape": "poly", "points": ring(3, 1.2, -90), "closed": True}, {"shape": "poly", "points": ring(3, 1.2, 90), "closed": True},
     {"shape": "circle", "c": [0.0, 0.0], "r": 1.45}]))
M.append(dg("thap_phuong", "Ten Directions Annihilation", "Thập Phương Câu Diệt Trận", 3, 3, 3, 0.11, 4, "demonic great sects, elder",
    "A burst of ten rays from one heart: six nodes on the rays all feed the heart's art, which strikes only after you have not been hit for 3 s.",
    [node("?", gate("own.since_hit", ">=", 3), 6, [0.0, 0.0])] + [node(("+" if i % 2 == 0 else "-"), (mod(DMG, 12) if i % 2 == 0 else mod(CST, 15)), (12 if i % 2 == 0 else -5), p, (1 if i < 4 else 3))
     for i, p in enumerate(ring(5, 1.3, -90))],
    [feed(i, 1, 0.6, 0.0, 1 if i < 6 else 3) for i in range(2, 7)],
    [{"shape": "rays", "c": [0.0, 0.0], "r0": 0.35, "r1": 1.9, "n": 10}, {"shape": "circle", "c": [0.0, 0.0], "r": 0.35}]))
M.append(dg("thai_cuc_vo_cuc", "Taiji Returns to Wuji", "Thái Cực Vô Cực Trận", 3, 3, 3, 0.09, 1, "a Daoist immortal's stele (a special encounter)",
    "Concentric emptiness: one centre, and two rings that pour into it. One level: perfect as found, never raised.",
    [node("+", mod(DMG, 30), 30, [0.0, 0.0])] + [node("+", mod(SPD, 10), 10, p) for p in ring(3, 0.9, -90)] + [node("-", mod(CST, 12), -5, p) for p in ring(2, 1.6, 0)],
    [feed(i, 1, 0.6, 0.3) for i in range(2, 5)] + [feed(5, 2, 0.8, 0.4), feed(6, 3, 0.8, 0.4)],
    [{"shape": "circle", "c": [0.0, 0.0], "r": 0.9}, {"shape": "circle", "c": [0.0, 0.0], "r": 1.6}, {"shape": "taiji", "c": [0.0, 0.0], "r": 0.45}]))
M.append(dg("van_thu", "Myriad Beasts Pay Homage", "Vạn Thú Triều Tông Trận", 3, 3, 3, 0.1, 5, "beast-taming sects, elder",
    "Summons gather toward the throne: three beasts from the start, a fourth at level 2, a fifth at level 5; every beast beside a summon art strikes harder.",
    [node("+", mod(DMG, 20, ["summon"]), 20, [0.0, -0.4])] +
    [node("+", adj(DMG, 12, "summon"), 10, p, u) for p, u in zip(ring(5, 1.5, 20), [1, 1, 1, 2, 5])],
    [feed(i, 1, 0.8, 0.2, [1, 1, 1, 2, 5][i - 2]) for i in range(2, 7)],
    [{"shape": "arc", "c": [0.0, -0.4], "r": 1.5, "a0": 0, "a1": 180}, {"shape": "rays", "c": [0.0, -0.4], "r0": 0.3, "r1": 0.6, "n": 8}]))
M.append(dg("ky_mon", "Strange Gates Hidden Stems", "Kỳ Môn Độn Giáp Trận", 3, 3, 3, 0.12, 5, "formation-master great sects, elder",
    "Eight doors around a hidden centre; the doors that open change with the pulse (open on every second pulse), and the centre steals linh lực back.",
    [node("?", gate("cycle.2", "==", 0), 6, [0.0, -1.2]), node("?", gate("cycle.2", "==", 1), 6, [1.2, 0.0]), node("?", gate("cycle.2", "==", 0), 6, [0.0, 1.2]),
     node("?", gate("cycle.2", "==", 1), 6, [-1.2, 0.0]), node("+", mod(CST, -20), 14, [0.0, 0.0]), node("+", mod(DMG, 14), 14, [0.85, -0.85], 3)],
    [link(1, 5), link(2, 5), link(3, 5), link(4, 5), feed(6, 5, 0.8, 0.0, 3)],
    [{"shape": "gates", "c": [0.0, 0.0], "r": 1.2}, {"shape": "poly", "points": ring(8, 1.6, -90 + 22.5), "closed": True}, {"shape": "grid", "c": [0.0, 0.0], "size": 1.0, "n": 3}]))
M.append(dg("lo_luyen", "Furnace of Heaven and Earth", "Thiên Địa Hồng Lô Trận", 3, 3, 3, 0.1, 4, "alchemist great sects, elder",
    "A cauldron on three legs: the fire below feeds the vessel, and whatever burns in it gains more the more elements burn on you.",
    [node("+", mod(DMG, 16, ["fire"]), 16, [0.0, 1.0]), node("+", mod(SPD, 10), 10, [-0.9, 1.2]), node("+", mod(SPD, 10), 10, [0.9, 1.2]),
     node("?", gate("own.buff_elements", ">=", 2), 6, [0.0, -0.3]), node("+", mod(DMG, 20), 20, [0.0, -1.1], 4)],
    [feed(2, 1, 0.8, 0.3), feed(3, 1, 0.8, -0.3), feed(1, 4, 0.8), feed(4, 5, 0.8, 0.0, 4)],
    [{"shape": "cauldron", "c": [0.0, -0.2], "r": 1.2}, {"shape": "flame", "c": [0.0, 1.05], "r": 0.55}]))

# ---------------------------------------------------------------- grade 4: Hóa Thần (7 art slots)
M.append(dg("chu_thien", "Great Celestial Star Wheel", "Chu Thiên Tinh Đấu Đại Trận", 4, 4, 4, 0.14, 5, "the highest formation-master sect's founder's hall",
    "Seven stars on three orbits around the pole star: the inner orbit feeds the pole, the outer orbits feed the inner; the third orbit opens at level 3.",
    [node("+", mod(DMG, 30), 30, [0.0, 0.0])] + [node("+", mod(SPD, 10), 10, p) for p in ring(2, 0.8, 0)] +
    [node("+", mod(SPD, 8), 8, p) for p in ring(2, 1.5, 90)] + [node("+", mod(DMG, 12), 12, p, 3) for p in ring(2, 2.2, 45)],
    [feed(2, 1, 0.6, 0.4), feed(3, 1, 0.6, 0.4), feed(4, 2, 0.6, 0.4), feed(5, 3, 0.6, 0.4), feed(6, 4, 0.6, 0.4, 3), feed(7, 5, 0.6, 0.4, 3)],
    [{"shape": "circle", "c": [0.0, 0.0], "r": 0.8}, {"shape": "circle", "c": [0.0, 0.0], "r": 1.5}, {"shape": "circle", "c": [0.0, 0.0], "r": 2.2},
     {"shape": "stars", "c": [0.0, 0.0], "r": 2.4, "n": 40}, {"shape": "rays", "c": [0.0, 0.0], "r0": 0.15, "r1": 0.35, "n": 8}]))
M.append(dg("tu_thien_kiem", "Four Heavenly Swords", "Tứ Thiên Kiếm Trận", 4, 4, 4, 0.13, 5, "sword great sects' sect head",
    "Four great swords planted at the four gates, each feeding the next around the ring; at level 4 the centre awakens and every sword feeds it.",
    [node("+", mod(DMG, 22, ["sword"]), 22, p) for p in ring(4, 1.5, -90)] + [node("+", mod(DMG, 34, ["sword"]), 34, [0.0, 0.0], 4)],
    [feed(1, 2, 0.8, 0.4), feed(2, 3, 0.8, 0.4), feed(3, 4, 0.8, 0.4), feed(4, 1, 0.8, 0.4)] + [feed(i, 5, 0.6, 0.0, 4) for i in range(1, 5)],
    [{"shape": "circle", "c": [0.0, 0.0], "r": 1.5}] + [{"shape": "sword", "from": [p[0] * 1.9, p[1] * 1.9], "to": [p[0] * 1.1, p[1] * 1.1], "w": 0.16} for p in ring(4, 1.0, -90)]))
M.append(dg("hon_don", "Primordial Chaos", "Hỗn Độn Trận", 4, 4, 4, 0.12, 5, "chaos-path ruins (a special encounter)",
    "No fixed shape: chaos arts swirl through five uneven nodes, quickening each other in a loop, while two nodes pay the price of holding chaos together.",
    [node("+", mod(DMG, 22, ["chaos"]), 22, [0.3, -0.2]), node("+", mod(SPD, 14, ["chaos"]), 14, [-1.1, -0.9]), node("+", mod(SPD, 14, ["chaos"]), 14, [1.4, -1.0]),
     node("+", mod(DMG, 16, ["chaos"]), 16, [1.0, 1.1]), node("-", mod(CST, 20), -8, [-1.3, 0.9]), node("-", mod(DMG, -15), -6, [-0.2, 1.6], 3)],
    [feed(2, 1, 0.7, 0.6), feed(1, 3, 0.7, 0.6), feed(3, 4, 0.7, 0.6), feed(4, 5, 0.7, 0.6), feed(5, 2, 0.7, 0.6), feed(6, 1, 0.7, -0.5, 3)],
    [{"shape": "swirl", "c": [0.1, 0.1], "r": 2.0, "arms": 3}]))
M.append(dg("luan_hoi", "Wheel of Rebirth", "Luân Hồi Trận", 4, 4, 4, 0.12, 5, "a reincarnated cultivator's teaching (a special character)",
    "Six paths around a wheel, each feeding the next; the hub's art turns only when you are near death, once below 25 % health.",
    [node("?", gate("own.hp_share", "<=", 0.25), 6, [0.0, 0.0])] + [node(("+" if i % 3 else "-"), (mod(SPD, 10) if i % 3 == 1 else (mod(DMG, 12) if i % 3 == 2 else mod(CST, 12))), (10 if i % 3 else -5), p)
     for i, p in enumerate(ring(6, 1.5, -90))],
    [feed(i, i + 1 if i < 7 else 2, 0.7, 0.35) for i in range(2, 8)] + [link(2, 1), link(5, 1)],
    [{"shape": "wheel", "c": [0.0, 0.0], "r": 1.5, "n": 6}, {"shape": "circle", "c": [0.0, 0.0], "r": 1.9}]))
M.append(dg("van_tuong", "Myriad Phenomena Return to One", "Vạn Tượng Quy Nhất Trận", 4, 4, 4, 0.1, 2, "a sect-founder's final manuscript (a rare drop)",
    "Many arts, one strike: six outer nodes all feed a single centre, each costing more. Two levels only, but the second adds the seventh.",
    [node("+", mod(DMG, 40), 40, [0.0, 0.0])] + [node("-", mod(CST, 12), -5, p, (1 if i < 5 else 2)) for i, p in enumerate(ring(6, 1.6, -90))],
    [feed(i, 1, 0.5, 0.0, 1 if i < 7 else 2) for i in range(2, 8)],
    [{"shape": "rays", "c": [0.0, 0.0], "r0": 0.4, "r1": 1.6, "n": 24}, {"shape": "circle", "c": [0.0, 0.0], "r": 0.4}, {"shape": "circle", "c": [0.0, 0.0], "r": 2.0}]))
