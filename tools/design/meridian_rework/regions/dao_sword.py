"""Sword Way (Kiếm Đạo), pilot v2 (2026-11-10): a Đạo graph drawn with the Meridian Map kit.

User feedback on v1 (a sword silhouette, 47 nodes): "bad", "should be denser", not a sword shape, use the cluster
philosophy, and 2-3x bigger. v2 is a round mini-land of about 115 nodes: a start at the centre, five spokes and an
inner ring road, and on every road node PoE-style figures (design/research/meridian-land-authoring.md). Each facet
owns a 72-degree sector; capstones sit beyond the outer constellations. Points: 1 per node, Dao premium x2 on the
map's budgets (small 2.4 W, notable 16 W), so every theme spec's shares sum to 2.0. Notables named in EFFECTS carry
an Effect (unpriced) instead of stat lines.

Build: python -I tools/design/meridian_rework/build_region.py dao_sword <out_dir> [--labels]
"""
import importlib.util
import math
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens = _load("pens")

TITLE = "Sword Way (Kiếm Đạo)"
START_NAME = "Glimpse of the Sword (Kiến Kiếm)"
AXIS = 0
RIM = 16.2
MIN_SPACING = 0.6
ROAD_JITTER = 0.3
ROAD_MOD = [("attack_pct", "sword", 2.0)]


def INSIDE(u, v, lim):
    return math.hypot(u, v) <= min(lim["rmax"], RIM - 0.4) and v >= -1.6


def _T(label, small_name, small, notables):
    return {"label": label, "kind": "identity", "small_name": small_name, "small": small, "notables": notables}


THEMES = {
    "intent": _T("Sword Intent (Kiếm Ý)", "Sword intent", [("crit_chance_pct", "sword", 1.0), ("attack_pct", "sword", 1.0)], [
        ("Seeking Point (Tầm Phong)", [("crit_chance_pct", "sword", 1.0), ("crit_damage_pct", "sword", 1.0)]),
        ("Deep Cut (Thâm Trảm)", [("crit_damage_pct", "sword", 2.0)]),
        ("Through the Realm (Xuyên Cảnh)", [("pierce_pct", "", 1.0), ("attack_pct", "sword", 1.0)]),
        ("True Line (Chính Tuyến)", [("accuracy_pct", "", 1.0), ("crit_chance_pct", "sword", 1.0)]),
        ("Intent Before Blade (Ý Tại Kiếm Tiên)", [("attack_pct", "sword", 1.2), ("crit_chance_pct", "sword", 0.8)])]),
    "flying": _T("Flying Swords (Phi Kiếm)", "Flying sword", [("art_speed_pct", "sword", 1.0), ("attack_pct", "sword", 1.0)], [
        ("Quick Draw (Khoái Xuất)", [("art_speed_pct", "sword", 2.0)]),
        ("Light Sword (Khinh Kiếm)", [("art_cost_pct", "sword", 1.0), ("art_speed_pct", "sword", 1.0)]),
        ("Sword Bound to Blade (Kiếm Hồn Phụ Khí)", [("artifact_attack_pct", "weapon", 1.0), ("attack_pct", "sword", 1.0)]),
        ("Thousand Glints (Thiên Quang)", [("attack_pct", "sword", 1.0), ("art_speed_pct", "sword", 1.0)]),
        ("Returning Swallow (Yến Hồi)", [("art_cost_pct", "sword", 1.2), ("attack_pct", "sword", 0.8)])]),
    "body": _T("Edge Body (Kiếm Thể)", "Tempered edge", [("block_rating", "", 1.0), ("attack_pct", "physical", 1.0)], [
        ("Blade Guard (Kiếm Hộ)", [("block_rating", "", 1.0), ("attack_pct", "sword", 1.0)]),
        ("Steel Skin (Cương Bì)", [("body_shield_pct", "", 1.0), ("block_rating", "", 1.0)]),
        ("Weight of Steel (Thiết Trọng)", [("attack_pct", "physical", 2.0)]),
        ("Body Like a Blade (Thân Như Kiếm)", [("attack_pct", "physical", 1.0), ("body_shield_pct", "", 1.0)]),
        ("Whetstone Bones (Ma Thạch Cốt)", [("block_rating", "", 1.2), ("khi_huyet_pct", "", 0.8)])]),
    "cold": _T("Cold Edge (Hàn Phong)", "Frost on steel", [("attack_pct", "cold", 2.0)], [
        ("Cold Edge (Hàn Nhận)", [("attack_pct", "cold", 2.0)]),
        ("Frost on Steel (Sương Thép)", [("attack_pct", "cold", 1.0), ("attack_pct", "sword", 1.0)]),
        ("Winter Blade (Đông Kiếm)", [("attack_pct", "cold", 1.0), ("crit_chance_pct", "sword", 1.0)]),
        ("Numbing Cut (Ma Trảm)", [("attack_pct", "cold", 1.2), ("accuracy_pct", "", 0.8)]),
        ("Still Water Edge (Tĩnh Thủy Phong)", [("attack_pct", "cold", 1.0), ("art_speed_pct", "sword", 1.0)])]),
    "heart": _T("Sword Heart (Kiếm Tâm)", "Sword sense", [("than_thuc_pct", "", 1.0), ("attack_pct", "sword", 1.0)], [
        ("Sword Sense (Kiếm Thức)", [("than_thuc_pct", "", 2.0)]),
        ("Intent Cuts the Soul (Ý Trảm Hồn)", [("soul_res_pct", "", 1.0), ("than_thuc_pct", "", 1.0)]),
        ("Clear Mind (Minh Tâm)", [("tam_ma_resist_pct", "", 1.0), ("than_thuc_pct", "", 1.0)]),
        ("One Breath (Nhất Tức)", [("art_cost_pct", "sword", 1.0), ("than_thuc_pct", "", 1.0)]),
        ("Mind Leads the Edge (Tâm Dẫn Phong)", [("attack_pct", "sword", 1.0), ("than_thuc_pct", "", 1.0)])]),
}

# Effect notables: name -> (tier, rule). Per facet at most 1 major and 2 minor (dao.md rule 10).
EFFECTS = {
    "Seen Opening (Kiến Khích)": ("minor", "Your sword hits against a target at or below 50 % health deal more (L5 +10)."),
    "Unwavering Edge (Kiên Phong)": ("minor", "After an enemy evades your sword art, your next sword hit cannot be evaded (once per 3 s)."),
    "Flowing Water (Lưu Thủy)": ("major", "When you crit, your other arts' timers shorten by 0.5 s. (starter)"),
    "First Move (Tiên Thủ)": ("minor", "Your first art of the fight costs no linh lực. (starter)"),
    "Sword Swarm (Kiếm Quần)": ("minor", "Your sword arts deal more for each sword art slotted (L5 +3 each, cap +15)."),
    "Echo (Hồi Âm)": ("major", "When one of your arts lands a hit, it has a 25 % chance to strike again for free. (starter)"),
    "Opening Cut (Khai Huyết)": ("minor", "When a Physical hit of yours crits, it applies one Bleed stack. (starter)"),
    "Whetted by Blows (Thối Phong)": ("minor", "Each hit your block reduces gives your sword arts L5 +1 for 5 s (cap +10)."),
    "Blood Drinker (Ẩm Huyết)": ("major", "When your hit removes enemy health, you restore 6 % of what it dealt. (starter)"),
    "Frostbitten Cut (Hàn Thương)": ("minor", "Your Cold parts deal more to a target bearing your Ice stacks (L5 +12)."),
    "Cold Steel Breath (Hàn Kim Tức)": ("minor", "When a sword art of yours crits, it grants one Ice stack on the target."),
    "Shatter (Toái Băng)": ("major", "When your sword crit lands on a target bearing 10+ of your Ice stacks, consume them and strike again as Cold (c_trig 0.6)."),
    "Steady Breath (Bình Tức)": ("minor", "While your linh lực is at 50 % or above, your sword arts deal more (L5 +12). (starter)"),
    "Still Mind (Tĩnh Tâm)": ("minor", "When no art of yours has fired for 1 s, your next sword art costs 30 % less."),
    "Heart Sword Intent (Tâm Kiếm Ý)": ("major", "While your thần thức exceeds the enemy's, your sword hits ignore 25 resistance points and deal more (L5 +1 per 2 % of the gap, cap +20)."),
}

KEYSTONES = {
    "ONE": {"name": "One Sword (Nhất Kiếm)", "rule": "Your one slotted sword art deals much more (L5 +50) and its hits ignore 30 resistance points.",
            "closes": "You may slot only one sword art (rival: Ten Thousand Swords)"},
    "TEN": {"name": "Ten Thousand Swords (Vạn Kiếm Quy Tông)", "rule": "Every sword art firing also launches a phantom sword: a trigger hit with the same tags (c_trig 0.35).",
            "closes": "You may slot no art that is not a sword art (rival: One Sword)"},
    "CALL": {"name": "Called Blow (Báo Chiêu)", "rule": "Your crit chance is counted on a visible meter, not rolled. (starter keystone)",
             "closes": "Crit chance cap 0.50 -> 0.35"},
    "STILL": {"name": "Unmoving Heart (Tâm Bất Động)", "rule": "Your sword arts may be paid in thần thức when linh lực runs short (1 thần thức per 1 linh lực).",
              "closes": "You regenerate no linh lực during fights"},
    "BODY": {"name": "Body Is the Sword (Thân Tức Kiếm)", "rule": "Your basic attack counts as a sword art, and your block rating adds to its damage (L5 +1 per 10 rating, cap +30).",
             "closes": "You cannot equip a weapon artifact"},
    "FROST": {"name": "Winter Never Ends (Đông Bất Tận)", "rule": "Your Ice stacks on a target never fall off while you keep hitting it with Cold parts.",
              "closes": "Your sword arts deal no Physical damage: all Physical is converted to Cold"},
}

# facet spokes fan upward from the start at the bottom (degrees clockwise from up). Short roads; dense constellations
# on every road node; the outer half is chained constellations, so a capstone is reached through clusters.
AX = {"heart": -62, "cold": -31, "intent": 0, "flying": 31, "body": 62}
ORDER = ["heart", "cold", "intent", "flying", "body"]

E = {   # big (major Effect first), outer figure (minor), J1 companion (minor), fill figure between this spoke and the next
    "heart": dict(big=[("concentric", ["Heart Sword Intent (Tâm Kiếm Ý)", "Sword Sense (Kiếm Thức)"]), ("eye", ["Heart Sword Intent (Tâm Kiếm Ý)"])],
                  out=[("hex", ["Steady Breath (Bình Tức)"]), ("kite", ["Steady Breath (Bình Tức)"])],
                  comp=[("bowtie", ["Still Mind (Tĩnh Tâm)", "One Breath (Nhất Tức)"]), ("kite", ["Still Mind (Tĩnh Tâm)"])],
                  fill=("hex", ["Clear Mind (Minh Tâm)"])),
    "cold": dict(big=[("snowflake", ["Shatter (Toái Băng)", "Cold Steel Breath (Hàn Kim Tức)", "Winter Blade (Đông Kiếm)"]), ("theta", ["Shatter (Toái Băng)", "Winter Blade (Đông Kiếm)"])],
                 out=[("lollipop", ["Frostbitten Cut (Hàn Thương)"]), ("kite", ["Frostbitten Cut (Hàn Thương)"])],
                 comp=[("hex", ["Cold Steel Breath (Hàn Kim Tức)"]), ("kite", ["Cold Steel Breath (Hàn Kim Tức)"])],
                 fill=("bowtie", ["Cold Steel Breath (Hàn Kim Tức)", "Still Water Edge (Tĩnh Thủy Phong)"])),
    "intent": dict(big=[("star", ["Flowing Water (Lưu Thủy)", "Deep Cut (Thâm Trảm)", "Through the Realm (Xuyên Cảnh)"]), ("theta", ["Flowing Water (Lưu Thủy)", "Deep Cut (Thâm Trảm)"])],
                   out=[("kite", ["Unwavering Edge (Kiên Phong)"]), ("hex", ["Unwavering Edge (Kiên Phong)"])],
                   comp=[("bowtie", ["Seen Opening (Kiến Khích)", "Seeking Point (Tầm Phong)"]), ("kite", ["Seen Opening (Kiến Khích)"])],
                   fill=("hex", ["True Line (Chính Tuyến)"])),
    "flying": dict(big=[("concentric", ["Echo (Hồi Âm)", "Thousand Glints (Thiên Quang)"]), ("theta", ["Echo (Hồi Âm)", "Thousand Glints (Thiên Quang)"])],
                   out=[("lollipop", ["Sword Swarm (Kiếm Quần)"]), ("kite", ["Sword Swarm (Kiếm Quần)"])],
                   comp=[("hex", ["First Move (Tiên Thủ)"]), ("kite", ["First Move (Tiên Thủ)"])],
                   fill=("bowtie", ["Quick Draw (Khoái Xuất)", "Sword Bound to Blade (Kiếm Hồn Phụ Khí)"])),
    "body": dict(big=[("theta", ["Blood Drinker (Ẩm Huyết)", "Steel Skin (Cương Bì)"]), ("concentric", ["Blood Drinker (Ẩm Huyết)", "Steel Skin (Cương Bì)"])],
                 out=[("hex", ["Whetted by Blows (Thối Phong)"]), ("kite", ["Whetted by Blows (Thối Phong)"])],
                 comp=[("bowtie", ["Opening Cut (Khai Huyết)", "Weight of Steel (Thiết Trọng)"]), ("kite", ["Opening Cut (Khai Huyết)"])],
                 fill=None),
}


def far(T, ids):
    return max(ids, key=lambda i: math.hypot(*T.pt(i)))


def build(T):
    P, dress, pict, place_in = T.P, pens.dress, pens.pict, pens.place_in
    S = T.node((0, 0), "S")
    j1, j2 = {}, {}
    for f in ORDER:
        a = AX[f]
        j1[f] = T.junction(P(3.3, a), road="sword")
        j2[f] = T.junction(P(6.5, a), road="sword")
        T.link(S, j1[f], kind="highway"); T.link(j1[f], j2[f], kind="highway")
    for f, g in zip(ORDER, ORDER[1:]):
        T.link(j1[f], j1[g], centre=(0, 0), kind="highway")
    outs = {}
    for f in ORDER:
        a, e = AX[f], E[f]
        side = -1 if a < 0 else 1
        big = dress(T, j2[f], [(k, f, a, 1.2, n) for k, n in e["big"]] + [("hex", f, a, 1.05, e["big"][0][1])])[0]
        dress(T, j1[f], [(k, f, a + 70 * side, 1.0, n) for k, n in e["comp"]] + [(k, f, a - 70 * side, 0.95, n) for k, n in e["comp"]])
        if f in ("cold", "flying"):      # only the two middle-side spokes carry a second figure at J2
            dress(T, j2[f], [(k, f, a + 78 * side, 0.95) for k, n in e["out"]] + [(k, f, a - 78 * side, 0.9) for k, n in e["out"]])
        if big:
            tip = far(T, big)
            o = None
            on = e["out"][0][1]
            for k, n in (("lollipop", on), ("kite", on), ("hex", on)):
                o = pict(T, tip, a, k, f, k=0.95, names=n)
                if o:
                    break
            outs[f] = o or big
    # one capstone per facet, just beyond its outer figure on a short stem (rivals marked in KEYSTONES)
    CAP = {"heart": "STILL", "cold": "FROST", "intent": "CALL", "flying": "TEN", "body": "BODY"}
    CAP_ONE_ON = "intent"     # One Sword also sits in Sword Intent, beside Called Blow
    for f, o in outs.items():
        tip = far(T, o)
        r = math.hypot(*T.pt(tip)); ux, uy = T.pt(tip)[0] / r, T.pt(tip)[1] / r
        if f == CAP_ONE_ON:
            for key, turn in (("CALL", -16), ("ONE", 16)):
                t_ = math.radians(math.degrees(math.atan2(ux, uy)) + turn)
                p_ = (T.pt(tip)[0] + 1.7 * math.sin(t_), T.pt(tip)[1] + 1.7 * math.cos(t_))
                k_ = T.node(p_, "K", key=key); T.link(tip, k_)
        else:
            k_ = T.node((T.pt(tip)[0] + 1.7 * ux, T.pt(tip)[1] + 1.7 * uy), "K", key=CAP[f]); T.link(tip, k_)
    # fills between spokes: one dense figure in each gap, joined at its nearest node
    for f, g in zip(ORDER, ORDER[1:]):
        kind, names = E[f]["fill"] or ("kite", None)
        ang = (AX[f] + AX[g]) / 2
        for r_ in (11.8, 12.6, 10.8, 9.6):
            if place_in(T, P(r_, ang), kind, f, k=1.0, names=names, ang=ang, max_reach=4.0):
                break
    for r_, ang in ((4.9, -15.5), (4.9, 15.5), (4.9, -46), (4.9, 46)):
        place_in(T, P(r_, ang), "kite", "intent" if abs(ang) < 20 else ("cold" if ang < 0 else "flying"), k=0.8, ang=ang, max_reach=3.0)
    for n in T.nodes:
        if n.get("kind") == "notable" and n["name"] in EFFECTS:
            tier, rule = EFFECTS[n["name"]]
            n["mods"] = [f"[{tier} Effect] {rule}"]
            n["effect"] = tier
