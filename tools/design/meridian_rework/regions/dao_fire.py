"""Fire Way (Hỏa Đạo), overnight draft 2026-11-11: the text draft design/dao-ways/18-hoa.md drawn on the Sword pilot's
layout. A SHAPE PLACEHOLDER: dao.md rule 1 wants each Way drawn to its own theme; this file only shows that a text
draft converts to a region. Facet order, figures and capstone stems are the Sword's. Stat lines use the kit's keys
(kit.STATS); Fire stacks have no kit key yet, so Fire buff and Burn lines use attack_pct (hoa) and dot_pct (fire).

Build: python -I tools/design/meridian_rework/build_region.py dao_fire <out_dir> [--labels]
"""
import importlib.util
import math
import os

_d = os.path.dirname(os.path.abspath(__file__))


def _load(n):
    s = importlib.util.spec_from_file_location(n, os.path.join(_d, n + ".py")); m = importlib.util.module_from_spec(s); s.loader.exec_module(m); return m


pens = _load("pens")

TITLE = "Hỏa Đạo (Fire) · draft on the Sword layout"
START_NAME = "Glimpse of Fire (Kiến Hỏa)"
AXIS = 0
RIM = 16.2
MIN_SPACING = 0.6
ROAD_JITTER = 0.3
ROAD_MOD = [("attack_pct", "fire", 2.0)]


def INSIDE(u, v, lim):
    return math.hypot(u, v) <= min(lim["rmax"], RIM - 0.4) and v >= -1.6


def _T(label, small_name, small, notables):
    return {"label": label, "kind": "identity", "small_name": small_name, "small": small, "notables": notables}


THEMES = {
    "flame": _T("True Flame (Chân Hỏa)", "True flame", [("dot_pct", "fire", 1.0), ("attack_pct", "fire", 1.0)], [
        ("White Flame (Bạch Diễm)", [("dot_pct", "fire", 2.0)]),
        ("Long Burn (Cháy Lâu)", [("dot_pct", "fire", 1.2), ("attack_pct", "hoa", 0.8)]),
        ("Hungry Fire (Lửa Đói)", [("dot_pct", "fire", 1.0), ("attack_pct", "fire", 1.0)]),
        ("Cutting Heat (Nhiệt Xuyên)", [("resist_pen_pct", "fire", 1.0), ("attack_pct", "fire", 1.0)]),
        ("Kindled Ground (Đất Bén)", [("attack_pct", "fire", 2.0)])]),
    "lava": _T("Lava (Dung Nham)", "Molten rock", [("attack_pct", "fire", 1.0), ("attack_pct", "physical", 1.0)], [
        ("Molten Rock (Đá Chảy)", [("attack_pct", "fire", 1.0), ("attack_pct", "physical", 1.0)]),
        ("Magma Core (Lõi Dung Nham)", [("attack_pct", "physical", 2.0)]),
        ("Basalt Skin (Da Bazan)", [("block_rating", "", 1.0), ("attack_pct", "fire", 1.0)]),
        ("Pyroclast (Hỏa Thạch)", [("crit_damage_pct", "physical", 2.0)]),
        ("Lava Tube (Ống Dung Nham)", [("attack_pct", "fire", 1.2), ("khi_huyet_pct", "", 0.8)])]),
    "pill": _T("Pill Fire (Đan Hỏa)", "Furnace heat", [("alchemy_success", "", 1.0), ("attack_pct", "fire", 1.0)], [
        ("Furnace Hand (Tay Lò)", [("alchemy_success", "", 2.0)]),
        ("True Fire Pill (Chân Hỏa Đan)", [("pill_quality", "", 1.0), ("alchemy_success", "", 1.0)]),
        ("Heat Tolerance (Chịu Nhiệt)", [("resist_pct", "fire", 2.0)]),
        ("Banked Coals (Than Ủ)", [("alchemy_success", "", 1.0), ("attack_pct", "fire", 1.0)]),
        ("Fire Control (Khống Hỏa)", [("dot_pct", "fire", 1.0), ("alchemy_success", "", 1.0)])]),
    "ash": _T("Ash (Tro Tàn)", "Cinder", [("dot_pct", "fire", 1.0), ("attack_pct", "fire", 1.0)], [
        ("Grey Ash (Tro Xám)", [("dot_pct", "fire", 2.0)]),
        ("Cinder Drift (Tàn Bay)", [("attack_pct", "fire", 2.0)]),
        ("Banked Ember (Than Hồng)", [("dot_pct", "fire", 1.0), ("attack_pct", "fire", 1.0)]),
        ("Ash Field (Đồng Tro)", [("resist_pen_pct", "fire", 2.0)]),
        ("Smoke Veil (Màn Khói)", [("evade_pct", "", 1.0), ("attack_pct", "fire", 1.0)])]),
    "phoenix": _T("Phoenix Rises (Niết Bàn)", "Phoenix down", [("khi_huyet_pct", "", 1.0), ("attack_pct", "hoa", 1.0)], [
        ("Phoenix Feather (Lông Phượng)", [("khi_huyet_pct", "", 2.0)]),
        ("Red Down (Lông Đỏ)", [("attack_pct", "fire", 1.0), ("khi_huyet_pct", "", 1.0)]),
        ("Warm Blood (Máu Ấm)", [("health_regen_pct", "", 2.0)]),
        ("Rising Heat (Nhiệt Dâng)", [("attack_pct", "hoa", 1.0), ("attack_pct", "fire", 1.0)]),
        ("Ash to Feather (Tro Hóa Lông)", [("heal_pct", "", 1.0), ("khi_huyet_pct", "", 1.0)])]),
}

# Effect notables: name -> (tier, rule). Per facet 1 major and 2 minor (dao.md rule 10). Text from 18-hoa.md.
EFFECTS = {
    "Wildfire (Liệu Nguyên)": ("major", "When a Burn batch of yours expires on a target, it reapplies itself at half its stacks (once per batch)."),
    "Catch (Bén Lửa)": ("minor", "Your Fire hits apply 1 extra Burn stack per 10 stacks already on the target (cap +5)."),
    "Kindling (Mồi Lửa)": ("minor", "Your first Fire art each fight applies double Burn. (starter)"),
    "Molten Strike (Dung Kích)": ("major", "Your Physical hits convert 40 % to Fire and apply Burn: 1 stack per 2 % of the target's max health they deal."),
    "Slag (Xỉ Nóng)": ("minor", "A target bearing 20+ of your Burn stacks has −15 block rating per 10 stacks."),
    "Earth Heat (Địa Nhiệt)": ("minor", "With an Earth root of 30+, your Earth buff stacks also grant +0.6 % Fire damage each."),
    "Swallow the Furnace (Nuốt Lò)": ("major", "Pills you take before a fight also grant 10 Fire buff stacks each for the fight (at most 3 pills)."),
    "Clean Burn (Đốt Sạch)": ("minor", "Your pill toxicity from fight pills is 30 % lower. (starter)"),
    "Fever Pill (Đan Sốt)": ("minor", "While your pill toxicity is above half its limit, your Fire hits deal more (L5 +15)."),
    "Harvest the Ash (Thu Tro)": ("major", "Every 8 s your next Fire hit consumes up to 40 Burn stacks and deals more (L5 +1.5 per stack, up to +60)."),
    "Smouldering (Âm Ỉ)": ("minor", "Burn stacks consumed by your Effects leave 25 % of themselves behind."),
    "Choking Smoke (Khói Ngạt)": ("minor", "A target bearing 30+ Burn stacks has −1.2 pp accuracy per 10 stacks."),
    "Rise from the Ashes (Dục Hỏa Trùng Sinh)": ("major", "Once a fight, refuse the Down: return at 30 % health with Fire buff stacks equal to the Burn on the foe (cap 50)."),
    "Burn Bright (Cháy Rực)": ("minor", "While below 35 % health, your Fire buff stacks are 100 % stronger."),
    "Embers in the Chest (Than Trong Ngực)": ("minor", "When you fall below 50 % health, gain 15 Fire buff stacks for 10 pulses (once per fight). (starter)"),
}

KEYSTONES = {
    "FURNACE": {"name": "The Furnace Never Cools (Lò Bất Lãnh)", "rule": "Your Fire buff batches do not expire while you have fired a Fire art in the last 3 s.",
                "closes": "Your Fire arts cost 25 % more"},
    "HEAVEN": {"name": "Burning Heaven (Phần Thiên)", "rule": "Burn ticks you deal also count as Fire hits for on-hit Effects (at most 1 a pulse per target).",
               "closes": "Your direct Fire hits deal 30 % less (L2 −30)"},
    "LAVA": {"name": "Lava Body (Dung Thân)", "rule": "Your basic attack becomes a Fire-and-Physical hit that applies 3 Burn stacks.",
             "closes": "You cannot slot a Water or Ice art"},
    "NINE": {"name": "Nine Furnaces (Cửu Lô)", "rule": "Up to 3 fight pills take no art slot and fire at their guard.",
             "closes": "Toxicity from fight pills is not reduced by anything"},
    "NIRVANA": {"name": "Nirvana (Niết Bàn)", "rule": "Rise from the Ashes may fire twice per fight, the second at 15 % health.",
                "closes": "Your max health is 20 % lower"},
}

# facet spokes fan upward from the start at the bottom (degrees clockwise from up). Short roads; dense constellations
# on every road node; the outer half is chained constellations, so a capstone is reached through clusters.
AX = {"pill": -62, "lava": -31, "flame": 0, "ash": 31, "phoenix": 62}
ORDER = ["pill", "lava", "flame", "ash", "phoenix"]

E = {   # big (major Effect first), outer figure (minor), J1 companion (minor), fill figure between this spoke and the next
    "pill": dict(big=[("concentric", ["Swallow the Furnace (Nuốt Lò)", "Furnace Hand (Tay Lò)"]), ("eye", ["Swallow the Furnace (Nuốt Lò)"])],
                 out=[("hex", ["Fever Pill (Đan Sốt)"]), ("kite", ["Fever Pill (Đan Sốt)"])],
                 comp=[("bowtie", ["Clean Burn (Đốt Sạch)", "True Fire Pill (Chân Hỏa Đan)"]), ("kite", ["Clean Burn (Đốt Sạch)"])],
                 fill=("hex", ["Heat Tolerance (Chịu Nhiệt)"])),
    "lava": dict(big=[("snowflake", ["Molten Strike (Dung Kích)", "Slag (Xỉ Nóng)", "Magma Core (Lõi Dung Nham)"]), ("theta", ["Molten Strike (Dung Kích)", "Magma Core (Lõi Dung Nham)"])],
                 out=[("lollipop", ["Earth Heat (Địa Nhiệt)"]), ("kite", ["Earth Heat (Địa Nhiệt)"])],
                 comp=[("hex", ["Slag (Xỉ Nóng)"]), ("kite", ["Slag (Xỉ Nóng)"])],
                 fill=("bowtie", ["Basalt Skin (Da Bazan)", "Lava Tube (Ống Dung Nham)"])),
    "flame": dict(big=[("star", ["Wildfire (Liệu Nguyên)", "White Flame (Bạch Diễm)", "Cutting Heat (Nhiệt Xuyên)"]), ("theta", ["Wildfire (Liệu Nguyên)", "White Flame (Bạch Diễm)"])],
                  out=[("kite", ["Catch (Bén Lửa)"]), ("hex", ["Catch (Bén Lửa)"])],
                  comp=[("bowtie", ["Kindling (Mồi Lửa)", "Hungry Fire (Lửa Đói)"]), ("kite", ["Kindling (Mồi Lửa)"])],
                  fill=("hex", ["Long Burn (Cháy Lâu)"])),
    "ash": dict(big=[("concentric", ["Harvest the Ash (Thu Tro)", "Grey Ash (Tro Xám)"]), ("theta", ["Harvest the Ash (Thu Tro)", "Grey Ash (Tro Xám)"])],
                out=[("lollipop", ["Smouldering (Âm Ỉ)"]), ("kite", ["Smouldering (Âm Ỉ)"])],
                comp=[("hex", ["Choking Smoke (Khói Ngạt)"]), ("kite", ["Choking Smoke (Khói Ngạt)"])],
                fill=("bowtie", ["Cinder Drift (Tàn Bay)", "Ash Field (Đồng Tro)"])),
    "phoenix": dict(big=[("theta", ["Rise from the Ashes (Dục Hỏa Trùng Sinh)", "Phoenix Feather (Lông Phượng)"]), ("concentric", ["Rise from the Ashes (Dục Hỏa Trùng Sinh)", "Phoenix Feather (Lông Phượng)"])],
                    out=[("hex", ["Burn Bright (Cháy Rực)"]), ("kite", ["Burn Bright (Cháy Rực)"])],
                    comp=[("bowtie", ["Embers in the Chest (Than Trong Ngực)", "Red Down (Lông Đỏ)"]), ("kite", ["Embers in the Chest (Than Trong Ngực)"])],
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
        if f in ("lava", "ash"):      # only the two middle-side spokes carry a second figure at J2
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
    CAP = {"pill": "NINE", "lava": "LAVA", "flame": "FURNACE", "ash": "HEAVEN", "phoenix": "NIRVANA"}
    CAP_ONE_ON = None  # one capstone per facet (the Sword pilot puts two on Sword Intent)
    for f, o in outs.items():
        tip = far(T, o)
        r = math.hypot(*T.pt(tip)); ux, uy = T.pt(tip)[0] / r, T.pt(tip)[1] / r
        if f == CAP_ONE_ON:
            for key, turn in (("FURNACE", -16), ("HEAVEN", 16)):
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
        place_in(T, P(r_, ang), "kite", "flame" if abs(ang) < 20 else ("lava" if ang < 0 else "ash"), k=0.8, ang=ang, max_reach=3.0)
    for n in T.nodes:
        if n.get("kind") == "notable" and n["name"] in EFFECTS:
            tier, rule = EFFECTS[n["name"]]
            n["mods"] = [f"[{tier} Effect] {rule}"]
            n["effect"] = tier
