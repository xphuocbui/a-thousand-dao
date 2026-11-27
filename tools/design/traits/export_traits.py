"""Builds assets/data/traits.json from design/gdd/npc-traits-catalogue.md and design/world/depth/traits-v2.json
(NPC Traits #42, approved 2026-11-14; Traits v2 amendment 2026-11-25):
- v1 kinds: 37 personality traits in 18 opposed sets (doubled rows, row_premium.personality = 2.0),
  14 callings (unchanged) with archetypes' calling weights, 4 kept fate-given traits in 2 pairs
  (6 retired fates mapped to talent tiers in retired_fates), and 16 gained traits;
- v2 kinds (80 traits): 12 upbringing, 12 talent families (tiers 1-3, adds ±6/±12/±20), 24 path,
  14 lifestyle, 10 health, and 8 coping traits, with catalogue overrides (thin_soul tier 3 = Empty-souled,
  hunter [creature], pure_root_devotee [own_top_element], 15 choice-weighted traits);
- config blocks: fade_seasons, row_premium, opinion (with like/dislike), choice, inherit (with talent
  inheritance + drift), roll (p_any 0.04), roll_v2, opposed_v2, path_root_bonds, policy_hooks, verb_hooks.

Run:  python -I tools/design/traits/export_traits.py [--check]
"""

import argparse
import json
import os
import re
import sys
import unicodedata

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
SRC = os.path.join(ROOT, "design", "gdd", "npc-traits-catalogue.md")
V2_SRC = os.path.join(ROOT, "design", "world", "depth", "traits-v2.json")
LABELS_SRC = os.path.join(ROOT, "assets", "data", "character_stat_labels.json")
OUT = os.path.join(ROOT, "assets", "data", "traits.json")
MINUS = "−"

# F4's fate-given odds and talent weights (npc-traits.md F4 Variables, amended 2026-11-25)
ROLL = {
    "_doc": "F4 (design/gdd/npc-traits.md F4, amended 2026-11-25): p_any (0.04) is the chance of a kept fate-given trait and p_second (0.10) of a second given the first (0.96 / 0.036 / 0.004); g_f = clamp(talent / g_ref, g_lo, g_hi) for a gift, the inverse for a flaw, on the talent before trait rows.",
    "p_any": 0.04,
    "p_second": 0.10,
    "g_ref": 45.0,
    "g_lo": 0.25,
    "g_hi": 3.0,
}

# F5 + F5b constants (npc-traits.md F5, F5b Variables)
INHERIT = {
    "_doc": "F5 / F5b (design/gdd/npc-traits.md): h, chance per known parent to pass a personality trait; m_master, roll lean toward a master known at creation; talent_one / talent_both, chance to inherit a talent family from 1 or 2 parents; talent_drift, odds for tier shift [-1, 0, +1].",
    "h": 0.5,
    "m_master": 3.0,
    "talent_one": 0.35,
    "talent_both": 0.65,
    "talent_drift": [0.40, 0.45, 0.15],
}

# F2's clamp (npc-traits.md F2 Variables)
CHOICE = {
    "_doc": "F2 choice weight (design/gdd/npc-traits.md F2): the product of the person's trait-by-tag weights is clamped to [m_lo, m_hi]; a 0 weight in the catalogue is F2's never.",
    "m_lo": 0.1,
    "m_hi": 5.0,
}

# F3's constants (npc-traits.md F3 Variables, amended 2026-11-25)
OPINION = {
    "_doc": "F3 opinion and att0 (design/gdd/npc-traits.md F3, amended 2026-11-25). s, o: shared and opposed weights; like, dislike: v2 likes (+5) and dislikes (-10) for lk; tie: master or disciple, kin, Dao companion, own sect head; sect_same: same sect; sect_k: share of the sects' attitude between NPCs of different sects; k_st: weight of the player's standing; att0_max: ceiling at a first meeting (the floor is the hostile threshold + 1).",
    "s": 10,
    "o": 10,
    "like": 5,
    "dislike": 10,
    "tie": {"master": 30, "kin": 30, "companion": 50, "own_head": 15},
    "sect_same": 10,
    "sect_k": 0.2,
    "k_st": 0.25,
    "att0_max": 30,
}

# F1 row premium per v1 kind (npc-traits.md F1, amended 2026-11-25)
ROW_PREMIUM = {
    "personality": 2.0,
    "callings": 1.0,
    "fate": 1.0,
    "gained": 1.0,
}

# Rule 2 retired v1 fates -> talent tier replacements (npc-traits.md Trait list, AC-NT-49)
RETIRED_FATES = {
    "wise_born": {"id": "quick_minded", "tier": 3},
    "iron_boned": {"id": "sturdy_frame", "tier": 3},
    "heaven_favoured": {"id": "lucky", "tier": 3},
    "ill_starred": {"id": "unlucky", "tier": 3},
    "dull_witted": {"id": "slow_witted", "tier": 3},
    "frail": {"id": "frail_frame", "tier": 1},
}

# Rule 9 world prices moved from retired v1 gifts to tier 3 of their replacing talent families
TALENT_TIER3_WORLD_PRICE = {
    "quick_minded": "envy ×1.5; rival sects poach them as a disciple ×2",
    "sturdy_frame": "duel challenges against them ×1.5",
    "lucky": "envy ×1.5",
}

# F4b / F6b constants (npc-traits.md F4b, F6b, Tuning Knobs)
ROLL_V2 = {
    "_doc": "F4b creation roll and F6b coping/waning constants (design/gdd/npc-traits.md F4b, F6b, Tuning Knobs).",
    "n_create_max": 6,
    "p_talent": [0.75, 0.22, 0.03],
    "p_tier": [0.70, 0.24, 0.06],
    "p_path": [0.05, 0.20, 0.40, 0.60, 0.60],
    "p_health": 0.08,
    "p_lifestyle": 0.35,
    "p_coping": 0.03,
    "talent_tier_add": [6, 12, 20],
    "coping_fade_seasons": 20,
    "coping_harden_refreshes": 3,
    "waning_share": 0.10,
    "birth_leans": {
        "city": {"street_orphan": 2.0, "merchant_child": 2.0, "mortal_noble": 2.0, "scholar_family": 2.0},
        "town": {"merchant_child": 1.5, "scholar_family": 1.5, "street_orphan": 1.5},
        "market": {"merchant_child": 2.5, "street_orphan": 1.5},
        "village": {"village_born": 2.5},
        "great_seat": {"sect_raised": 2.5, "servant_born": 1.5},
        "minor_seat": {"sect_raised": 2.5, "servant_born": 1.5},
        "sect_hall": {"sect_raised": 2.0, "servant_born": 1.5},
        "wild": {"wild_raised": 2.5, "hermit_taught": 2.0},
    },
    "family_leans": {
        "cultivating": {"clan_heir": 3.0},
        "sect_servant": {"servant_born": 3.0},
        "sect_ward": {"sect_raised": 3.0},
        "mortal_noble": {"mortal_noble": 3.0},
        "merchant": {"merchant_child": 3.0},
        "scholar": {"scholar_family": 3.0},
        "war_orphan": {"war_orphan": 3.0},
    },
}

# Rule 2a opposed v2 pairs (3 path pairs, 6 talent gift/flaw pairs, 4 kept-fate / talent-family pairs)
OPPOSED_V2 = [
    ["perfect_foundation", "flawed_foundation"],
    ["demonic_path", "buddhist_path"],
    ["frost_veined", "fire_tempered"],
    ["quick_minded", "slow_witted"],
    ["sturdy_frame", "frail_frame"],
    ["keen_soul", "thin_soul"],
    ["comely", "homely"],
    ["lucky", "unlucky"],
    ["steady_heart", "restless_heart"],
    ["keen_soul", "hollow_souled"],
    ["thin_soul", "spirit_eyed"],
    ["steady_heart", "demon_seeded"],
    ["restless_heart", "pure_hearted"],
]

# F4b root bonds for path creation roll
PATH_ROOT_BONDS = {
    "frost_veined": {"any": ["thuy", "bang"]},
    "fire_tempered": {"any": ["hoa"]},
    "thunder_struck": {"any_group": [["hoa", "kim"], ["loi"]]},
    "pure_root_devotee": {"single_base": True},
}

# Rule 8a policy hooks -> Sects F15 pulls (npc-traits-catalogue.md § Hooks by consumer)
POLICY_HOOKS = {
    "policy:tradition": {"dials": {"openness": -1}},
    "policy:trade": {"first_track": "trade"},
    "policy:caution": {"war_odds": 1.2},
    "policy:openness": {"dials": {"openness": 1}},
}

# Catalogue overrides where npc-traits-catalogue.md amends design/world/depth/traits-v2.json
V2_CATALOGUE_OVERRIDES = {
    "thin_soul": {
        "name": "Thin / Clouded / Empty-souled",
        "name_vi": "hồn bạc / hồn mê / hồn rỗng",
    },
}

# Validation vocabularies
CHOICE_TAG_VOCAB = {
    "aggressive", "merciful", "greedy", "generous", "deceitful", "honest",
    "loyal", "disloyal", "cautious", "bold", "vengeful", "forgiving",
    "devout", "pragmatic", "social", "solitary", "ambitious", "humble",
    "diligent", "indulgent",
}
TALENT_KEYS = {"ngo_tinh", "can_cot", "than_hon", "khi_van", "dao_tam", "mi_luc"}
# Designed Stat List keys in modifiers.md not yet mirrored in character_stat_labels.json
EXTRA_DESIGNED_STATS = {"leech_health_pct"}
KNOWN_SCOPES = {
    "sword", "sabre", "spear", "staff", "bow", "song", "art", "spell", "body",
    "formation", "talisman", "poison", "bleed", "soul",
    "cold", "fire", "lightning", "kim", "moc", "thuy", "hoa", "tho",
    "bang", "loi", "am", "quang", "phong", "hon_don",
}
BANNED_ENV_SCOPES = {
    "terrain", "biome", "ground", "weather", "rain", "snow", "wind_weather",
    "place", "forest", "mountain", "water_terrain", "desert", "swamp", "tundra",
    "city", "village", "abode", "own_abode", "vein", "spirit_vein",
    "time", "day", "night", "season", "spring", "summer", "autumn", "winter",
}
VALID_HOOK_PREFIXES = {"event:", "verb:", "policy:", "stance:", "craft:"}
V2_KINDS = ("upbringing", "talent", "path", "lifestyle", "health", "coping")
EXPECTED_V2_COUNTS = {"upbringing": 12, "talent": 12, "path": 24, "lifestyle": 14, "health": 10, "coping": 8}
KEPT_FATE_IDS = ["spirit_eyed", "hollow_souled", "pure_hearted", "demon_seeded"]


def slug(name):
    n = unicodedata.normalize("NFKD", name.lower().replace("đ", "d")).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", n).strip("_")


def num(s):
    return float(s.replace(MINUS, "-").replace("+", ""))


def cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def stat_codes(text):
    codes = {}
    for line in text.splitlines():
        m = re.match(r"\|\s*([A-Z][a-z]?)\s*\|\s*([^|]+)\|\s*`([a-z_]+)`[^|]*\|", line)
        if m:
            codes[m.group(1)] = m.group(3)
    return codes


def small_v1_values(text):
    """Read the Small (1.2 W) column from Conventions and Callings stat tables for AC-NT-37 checks."""
    vals = {}
    for line in text.splitlines():
        c = cells(line)
        if len(c) >= 5 and re.fullmatch(r"[A-Z][a-z]?", c[0]):
            km = re.search(r"`([a-z_]+)`", c[2])
            vm = re.search(r"([\d.]+)", c[4])
            if km and vm:
                vals[km.group(1)] = float(vm.group(1))
    return vals


def rows(text, codes):
    out = []
    for part in re.split(r"\s*·\s*", text.strip()):
        m = re.match(r"([A-Z][a-z]?)\s*([+" + MINUS + r"-][\d.]+)(?:\s*(?:%|pp))?(?:\s*\[([a-z_]+)\])?", part)
        if m and m.group(1) in codes:
            row = {"stat": codes[m.group(1)], "value": num(m.group(2))}
            if m.group(3):
                row["scope"] = [m.group(3)]
            out.append(row)
    return out


def tags(text):
    out = {}
    for part in re.split(r"\s*·\s*", text.strip()):
        m = re.match(r"([a-z]+)\s+(\*\*never\*\*|never|[\d.]+)", part)
        if m:
            out[m.group(1)] = 0.0 if "never" in m.group(2) else float(m.group(2))
    return out


def regard(text):
    t = text.strip()
    m = re.match(r"bias_all\s*([+" + MINUS + r"-]\d+)", t)
    if m:
        return {"bias_all": num(m.group(1))}
    m = re.match(r"bias_dir\s*([+" + MINUS + r"-]\d+)\s*(.*)", t)
    if m:
        return {"bias_dir": num(m.group(1)), "toward": m.group(2).strip()}
    m = re.match(r"target\s*([+" + MINUS + r"-]\d+)", t)
    if m:
        return {"target": num(m.group(1))}
    return {}


DIALS = {"tax": "tax", "expansion": "expansion", "openness": "openness", "war readiness": "war_readiness", "recruitment": "recruitment"}


def pulls(text):
    p = {}
    notes = []
    for part in [x.strip() for x in text.split(";") if x.strip()]:
        lo = part.lower().replace(MINUS, "-")
        done = False
        for k, f in (("war odds", "war_odds"), ("rebel odds", "rebel_odds"), ("invest share", "invest_share")):
            m = re.match(k + r"\s+([\d.]+)", lo)
            if m:
                p[f] = float(m.group(1))
                done = True
        m = re.match(r"weariness\s+([+-]\d+)(.*)", lo)
        if m:
            p["weariness"] = float(m.group(1))
            if "truce" in m.group(2):
                p["weariness_for_truce"] = True
            done = True
        if lo.startswith("half weariness from losses"):
            p["half_loss_weariness"] = True
            done = True
        m = re.match(r"(tax|expansion|openness|war readiness|recruitment)\s+([+-]\d+)(.*)", lo)
        if m:
            d = DIALS[m.group(1)]
            if "while thriving" in m.group(3):
                p.setdefault("dial_when_thriving", {})[d] = float(m.group(2))
            else:
                p.setdefault("dials", {})[d] = float(p.get("dials", {}).get(d, 0.0)) + float(m.group(2))
            done = True
        m = re.match(r"treasury draw\s+(\d+)", lo)
        if m:
            p["draw_mult"] = float(m.group(1))
            done = True
        m = re.match(r"loyalty\s+([+-]\d+)", lo)
        if m:
            p["loyalty"] = float(m.group(1))
            done = True
        m = re.match(r"pact line\s+(\d+)(.*)", lo)
        if m:
            p["pact_line"] = float(m.group(1))
            if "defence" in m.group(2):
                p["pact_line_scope"] = "defence"
            done = True
        m = re.match(r"alignment factor\s+×([\d.]+)", lo)
        if m:
            p["alignment_factor"] = float(m.group(1))
            done = True
        m = re.match(r"attitude speed\s+×([\d.]+)\s*(.*)", lo)
        if m:
            p["attitude_speed"] = float(m.group(1))
            p["attitude_speed_when"] = "hostile" if "hostile" in m.group(2) else "friendly"
            done = True
        m = re.match(r"attitude bias\s+([+-]\d+)", lo)
        if m:
            p["attitude_bias_from_all"] = float(m.group(1))
            done = True
        if lo == "bold":
            p["bold"] = True
            done = True
        if lo.startswith("never bold"):
            p["never_bold"] = True
            p["needs_halved"] = "halved" in lo
            done = True
        if lo == "needs halved":
            p["needs_halved"] = True
            done = True
        if lo == "fickle":
            p["fickle"] = True
            done = True
        m = re.match(r"first track\s+(\w+)", lo)
        if m:
            p["first_track"] = m.group(1)
            done = True
        if not done:
            notes.append(part)
    if notes:
        p["notes"] = notes
    return p


def section(text, title):
    i = text.index(title)
    j = text.find("\n## ", i + 1)
    return text[i: j if j > 0 else len(text)]


def subsection(text, title):
    i = text.index(title)
    j = text.find("\n### ", i + 1)
    k = text.find("\n## ", i + 1)
    ends = [x for x in (j, k) if x > 0]
    return text[i: min(ends) if ends else len(text)]


def parse_catalogue_v2_choice_tags(v2_sec):
    """Parse § Choice-tag weights of v2 traits from npc-traits-catalogue.md for cross-checking."""
    sub = subsection(v2_sec, "### Choice-tag weights of v2 traits")
    out = {}
    for line in sub.splitlines():
        if not line.startswith("|") or "---" in line or "Weights" in line:
            continue
        c = cells(line)
        if len(c) < 4:
            continue
        tid = c[1].strip("`")
        out[tid] = tags(c[3])
    return out


def parse_catalogue_verb_hooks(v2_sec):
    """Parse the 19 verb hooks from § Hooks by consumer in npc-traits-catalogue.md."""
    sub = subsection(v2_sec, "### Hooks by consumer")
    out = []
    for line in sub.splitlines():
        if not line.startswith("|") or "---" in line or "Verb" in line:
            continue
        c = cells(line)
        if len(c) == 4 and c[0].startswith("`") and c[2] in ("self", "other", "either"):
            out.append({"id": c[0].strip("`"), "trait": c[1].strip("`"), "side": c[2]})
    return out


def parse_catalogue_v2_rows(v2_sec, all_codes):
    """Parse every v2 trait's rows from npc-traits-catalogue.md tables to cross-check traits-v2.json."""
    out = {}
    for heading, is_talent in (
        ("### Upbringing", False),
        ("### Talent", True),
        ("### Path", False),
        ("### Lifestyle", False),
        ("### Health", False),
        ("### Coping", False),
    ):
        sub = subsection(v2_sec, heading)
        for line in sub.splitlines():
            if not line.startswith("|") or "---" in line or "| id |" in line:
                continue
            c = cells(line)
            if not c or not c[0].isdigit():
                continue
            tid = c[1].strip("`")
            if is_talent:
                tiers = []
                for col_idx in (4, 5, 6):
                    parsed = rows(c[col_idx], all_codes)
                    t_dict = {}
                    r_list = []
                    for r in parsed:
                        if r["stat"] in TALENT_KEYS and "scope" not in r:
                            t_dict[r["stat"]] = int(r["value"])
                        else:
                            r_list.append(r)
                    tiers.append({"talent": t_dict, "rows": r_list})
                out[tid] = {"tiers": tiers}
            else:
                out[tid] = {"rows": rows(c[4], all_codes)}
    return out


def build_v2(v2_raw):
    """Transform traits-v2.json into the exported v2 kind arrays with catalogue overrides."""
    exported = {}
    for kind in V2_KINDS:
        items = []
        for entry in v2_raw[kind]:
            tid = entry["id"]
            ov = V2_CATALOGUE_OVERRIDES.get(tid, {})
            name = ov.get("name", entry["name"])
            name_vi = ov.get("name_vi", entry["name_vi"])
            if kind == "talent":
                tier_names = [s.strip() for s in name.split("/")]
                tier_names_vi = [s.strip() for s in name_vi.split("/")]
                first_tal = entry["tiers"][0]["talent"]
                stat_key, first_val = next(iter(first_tal.items()))
                direction = 1 if first_val > 0 else -1
                tiers = []
                for idx, t in enumerate(entry["tiers"]):
                    trec = {
                        "talent": {k: int(v) for k, v in t["talent"].items()},
                        "rows": [dict(r) for r in t.get("rows", [])],
                    }
                    if idx == 2 and tid in TALENT_TIER3_WORLD_PRICE:
                        trec["world_price"] = TALENT_TIER3_WORLD_PRICE[tid]
                    tiers.append(trec)
                rec = {
                    "id": tid,
                    "name": name,
                    "name_vi": name_vi,
                    "meaning": entry["meaning"],
                    "stat": stat_key,
                    "direction": direction,
                    "tier_names": tier_names,
                    "tier_names_vi": tier_names_vi,
                    "tiers": tiers,
                    "opens": list(entry.get("opens", [])),
                    "likes": list(entry.get("likes", [])),
                    "dislikes": list(entry.get("dislikes", [])),
                }
            else:
                rec = {
                    "id": tid,
                    "name": name,
                    "name_vi": name_vi,
                    "meaning": entry["meaning"],
                    "rows": [dict(r) for r in entry.get("rows", [])],
                    "opens": list(entry.get("opens", [])),
                    "likes": list(entry.get("likes", [])),
                    "dislikes": list(entry.get("dislikes", [])),
                }
                if entry.get("tags"):
                    rec["tags"] = dict(entry["tags"])
            items.append(rec)
        exported[kind] = items
    return exported


def validate(out, text, v2_sec, all_codes, small_v1):
    """Strict validation of exported traits.json (AC-NT-37, 38, 48, 49, 51; AC-NTC-01..14)."""
    errs = []
    def err(msg):
        errs.append(msg)

    labels_data = json.load(open(LABELS_SRC, encoding="utf-8"))
    valid_stats = set(labels_data["labels"].keys()) | TALENT_KEYS | EXTRA_DESIGNED_STATS

    # -- v1 counts and rows (AC-NT-37, AC-NTC-01..08) --
    if len(out["personality"]) != 37:
        err("personality count %d != 37" % len(out["personality"]))
    pers_sets = {t["set"] for t in out["personality"]}
    if len(pers_sets) != 18:
        err("personality sets %d != 18" % len(pers_sets))
    pers_rows_checked = 0
    for t in out["personality"]:
        if len(t["boon"]) != 1 or len(t["cost"]) != 1:
            err("personality %s must have 1 boon and 1 cost" % t["id"])
            continue
        for r in t["boon"] + t["cost"]:
            pers_rows_checked += 1
            st = r["stat"]
            if st == "attack_pct" or st.startswith("crit"):
                err("personality %s uses banned combat row %s" % (t["id"], st))
            if st not in small_v1:
                err("personality %s stat %s missing from Small (1.2 W) table" % (t["id"], st))
            else:
                expected_abs = round(2.0 * small_v1[st], 6)
                if abs(abs(r["value"]) - expected_abs) > 1e-6:
                    err("personality %s stat %s value %s != 2x v1 (%s)" % (t["id"], st, r["value"], expected_abs))
    if pers_rows_checked != 74:
        err("personality row count %d != 74" % pers_rows_checked)

    # Spot-check AC-NT-37 named traits
    p_by = {t["id"]: t for t in out["personality"]}
    if p_by["brave"]["boon"][0] != {"stat": "khi_huyet_pct", "value": 4.0} or p_by["brave"]["cost"][0] != {"stat": "evade_pct", "value": -1.6}:
        err("AC-NT-37 Brave mismatch: %s / %s" % (p_by["brave"]["boon"], p_by["brave"]["cost"]))
    if p_by["greedy"]["boon"][0] != {"stat": "mission_income_pct", "value": 3.4} or p_by["greedy"]["cost"][0] != {"stat": "tam_ma_resist_pct", "value": -1.6}:
        err("AC-NT-37 Greedy mismatch: %s / %s" % (p_by["greedy"]["boon"], p_by["greedy"]["cost"]))
    if p_by["content"]["cost"][0] != {"stat": "cultivation_speed_pct", "value": -1.0}:
        err("AC-NT-37 Content mismatch: %s" % (p_by["content"]["cost"],))

    if len(out["callings"]) != 14:
        err("callings count %d != 14" % len(out["callings"]))
    for t in out["callings"]:
        if len(t["boon"]) != 1 or len(t["cost"]) != 1:
            err("calling %s must have 1 boon and 1 cost" % t["id"])
            continue
        for r in t["boon"] + t["cost"]:
            st = r["stat"]
            if st == "attack_pct" or st.startswith("crit"):
                err("calling %s uses banned combat row %s" % (t["id"], st))
            if st in small_v1 and abs(abs(r["value"]) - small_v1[st]) > 1e-6:
                err("calling %s stat %s value %s != 1x v1 (%s)" % (t["id"], st, r["value"], small_v1[st]))
    c_by = {t["id"]: t for t in out["callings"]}
    if c_by["strategist"]["boon"][0] != {"stat": "escape_pct", "value": 1.2} or c_by["strategist"]["cost"][0] != {"stat": "cultivation_speed_pct", "value": -0.5}:
        err("AC-NT-37 Strategist mismatch: %s / %s" % (c_by["strategist"]["boon"], c_by["strategist"]["cost"]))

    # -- Fate-given & retired_fates (Rule 2, AC-NT-35, AC-NT-49) --
    fate_ids = [t["id"] for t in out["fate"]]
    if fate_ids != KEPT_FATE_IDS:
        err("kept fates %s != %s" % (fate_ids, KEPT_FATE_IDS))
    if set(out["retired_fates"].keys()) != set(RETIRED_FATES.keys()):
        err("retired_fates keys mismatch")
    if len(out["gained"]) != 16:
        err("gained count %d != 16" % len(out["gained"]))
    if abs(out["roll"]["p_any"] - 0.04) > 1e-9 or abs(out["roll"]["p_second"] - 0.10) > 1e-9:
        err("roll p_any/p_second mismatch: %s" % out["roll"])

    # -- v2 counts and distinct ids (AC-NT-38, AC-NTC-09) --
    v1_names = set()
    for k in ("personality", "callings", "fate", "gained"):
        for t in out[k]:
            v1_names.add(t["name"])
    v2_ids = set()
    v2_entries = []
    for k in V2_KINDS:
        if len(out[k]) != EXPECTED_V2_COUNTS[k]:
            err("v2 kind %s count %d != %d" % (k, len(out[k]), EXPECTED_V2_COUNTS[k]))
        for entry in out[k]:
            tid = entry["id"]
            if tid in v2_ids:
                err("duplicate v2 id %s" % tid)
            v2_ids.add(tid)
            if tid in v1_names:
                err("v2 id %s collides with v1 name" % tid)
            v2_entries.append((k, entry))
    if len(v2_ids) != 80:
        err("total v2 count %d != 80" % len(v2_ids))

    # -- AC-NTC-13: no v2 display name (including talent tier names) collides with a kept v1 name --
    for k, entry in v2_entries:
        names_to_check = entry["tier_names"] if k == "talent" else [entry["name"]]
        for nm in names_to_check:
            if nm in v1_names:
                err("AC-NTC-13: v2 %s display name %r collides with kept v1 name" % (entry["id"], nm))

    # -- thin_soul / hunter / pure_root_devotee overrides --
    tal_by = {t["id"]: t for t in out["talent"]}
    if tal_by["thin_soul"]["tier_names"][2] != "Empty-souled":
        err("thin_soul tier 3 name must be 'Empty-souled', got %r" % tal_by["thin_soul"]["tier_names"])
    life_by = {t["id"]: t for t in out["lifestyle"]}
    if {"stat": "attack_pct", "value": 2, "scope": ["creature"]} not in life_by["hunter"]["rows"]:
        err("hunter missing required creature-scoped attack_pct +2 row: %s" % life_by["hunter"]["rows"])
    path_by = {t["id"]: t for t in out["path"]}
    if path_by["pure_root_devotee"]["rows"] != [{"stat": "attack_pct", "value": 6, "scope": ["own_top_element"]}]:
        err("pure_root_devotee row mismatch: %s" % path_by["pure_root_devotee"]["rows"])

    # -- Cross-check v2 rows against catalogue tables (AC-NTC-10) & row/scope rules (AC-NT-38, 48) --
    cat_v2_rows = parse_catalogue_v2_rows(v2_sec, all_codes)
    def check_row(tid, r):
        extra_keys = set(r.keys()) - {"stat", "value", "scope"}
        if extra_keys:
            err("AC-NT-48: %s row has forbidden keys %s" % (tid, sorted(extra_keys)))
        if "stat" not in r or "value" not in r:
            err("%s row missing stat or value: %s" % (tid, r))
            return
        if r["stat"] not in valid_stats:
            err("AC-NT-38: %s row uses unknown/Pending/rare stat %r" % (tid, r["stat"]))
        if "scope" in r:
            sc = r["scope"]
            if not isinstance(sc, list) or not sc:
                err("%s row has invalid scope %r" % (tid, sc))
                return
            for tag in sc:
                if tag in BANNED_ENV_SCOPES:
                    err("AC-NT-48: %s row uses banned environment scope %r" % (tid, tag))
                elif tag == "creature":
                    if tid != "hunter":
                        err("AC-NT-38: only hunter may use Pending foe scope 'creature' (found on %s)" % tid)
                elif tag == "own_top_element":
                    if tid != "pure_root_devotee":
                        err("AC-NT-38: only pure_root_devotee may use 'own_top_element' (found on %s)" % tid)
                elif tag not in KNOWN_SCOPES:
                    err("AC-NT-38: %s row uses unknown scope %r" % (tid, tag))

    for k, entry in v2_entries:
        tid = entry["id"]
        if tid not in cat_v2_rows:
            err("v2 trait %s not found in catalogue markdown table" % tid)
            continue
        if k == "talent":
            if len(entry["tiers"]) != 3 or len(entry["tier_names"]) != 3 or len(entry["tier_names_vi"]) != 3:
                err("talent %s must have 3 tiers and 3 tier names" % tid)
                continue
            expected_adds = [entry["direction"] * a for a in (6, 12, 20)]
            for idx, tier in enumerate(entry["tiers"]):
                if tier["talent"] != {entry["stat"]: expected_adds[idx]}:
                    err("AC-NT-38: talent %s tier %d add %s != {%s: %d}" % (tid, idx + 1, tier["talent"], entry["stat"], expected_adds[idx]))
                for r in tier["rows"]:
                    check_row(tid, r)
                # Compare against catalogue table
                cat_tier = cat_v2_rows[tid]["tiers"][idx]
                if tier["talent"] != cat_tier["talent"]:
                    err("AC-NTC-10: talent %s tier %d talent mismatch json=%s cat=%s" % (tid, idx + 1, tier["talent"], cat_tier["talent"]))
                norm_j = [{"stat": r["stat"], "value": float(r["value"]), **({"scope": r["scope"]} if "scope" in r else {})} for r in tier["rows"]]
                if norm_j != cat_tier["rows"]:
                    err("AC-NTC-10: talent %s tier %d rows mismatch json=%s cat=%s" % (tid, idx + 1, norm_j, cat_tier["rows"]))
        else:
            for r in entry["rows"]:
                check_row(tid, r)
            norm_j = [{"stat": r["stat"], "value": float(r["value"]), **({"scope": r["scope"]} if "scope" in r else {})} for r in entry["rows"]]
            if norm_j != cat_v2_rows[tid]["rows"]:
                err("AC-NTC-10: %s rows mismatch json=%s cat=%s" % (tid, norm_j, cat_v2_rows[tid]["rows"]))

    # -- Likes, dislikes, opens (AC-NT-38, AC-NTC-12) --
    all_valid_refs = v2_ids | v1_names
    verb_from_opens = {}
    policy_from_opens = set()
    for k, entry in v2_entries:
        tid = entry["id"]
        for field in ("likes", "dislikes"):
            for ref in entry.get(field, []):
                if ref not in all_valid_refs:
                    err("AC-NT-38: %s %s names unknown trait %r" % (tid, field, ref))
        for h in entry.get("opens", []):
            if not any(h.startswith(p) for p in VALID_HOOK_PREFIXES):
                err("AC-NT-38: %s opens hook %r has invalid prefix" % (tid, h))
            if h.startswith("verb:"):
                verb_from_opens[h.split(":", 1)[1]] = tid
            elif h.startswith("policy:"):
                policy_from_opens.add(h)

    if len(out["verb_hooks"]) != 19:
        err("verb_hooks count %d != 19" % len(out["verb_hooks"]))
    vh_map = {v["id"]: v["trait"] for v in out["verb_hooks"]}
    if vh_map != verb_from_opens:
        err("verb_hooks mismatch against opens: hooks=%s opens=%s" % (vh_map, verb_from_opens))
    if set(out["policy_hooks"].keys()) != policy_from_opens or len(out["policy_hooks"]) != 4:
        err("policy_hooks mismatch against opens: %s vs %s" % (sorted(out["policy_hooks"]), sorted(policy_from_opens)))

    # -- Choice-tag weights on v2 traits (AC-NT-51, AC-NTC-14) --
    cat_v2_tags = parse_catalogue_v2_choice_tags(v2_sec)
    weighted_v2 = {}
    for k, entry in v2_entries:
        tdict = entry.get("tags", {})
        if not tdict:
            continue
        tid = entry["id"]
        if k in ("talent", "health"):
            err("AC-NT-51: %s (%s) must not carry choice-tag weights" % (tid, k))
        if not (1 <= len(tdict) <= 3):
            err("AC-NT-51: %s has %d tags (must be 1-3)" % (tid, len(tdict)))
        for tg, w in tdict.items():
            if tg not in CHOICE_TAG_VOCAB:
                err("AC-NT-51: %s uses unknown choice tag %r" % (tid, tg))
            if w not in (1.5, 0.67):
                err("AC-NT-51: %s tag %s has weight %r (must be 1.5 or 0.67)" % (tid, tg, w))
        weighted_v2[tid] = tdict
    if len(weighted_v2) != 15:
        err("AC-NT-51: expected 15 v2 traits with tags, got %d" % len(weighted_v2))
    if weighted_v2 != cat_v2_tags:
        err("AC-NTC-14: v2 tags mismatch against catalogue table")

    # -- Opposed v2 ids resolve --
    all_v2_and_fate_ids = v2_ids | set(KEPT_FATE_IDS)
    for pair in out["opposed_v2"]:
        if len(pair) != 2 or pair[0] not in all_v2_and_fate_ids or pair[1] not in all_v2_and_fate_ids:
            err("opposed_v2 pair invalid: %s" % pair)

    return errs


def build():
    text = open(SRC, encoding="utf-8").read()
    v2_raw = json.load(open(V2_SRC, encoding="utf-8"))
    codes = stat_codes(text)
    small_v1 = small_v1_values(text)
    v2_sec = section(text, "## Traits v2")
    all_codes = dict(codes)
    all_codes.update(stat_codes(v2_sec))

    out = {
        "schema_version": 1,
        "_doc": "Built by tools/design/traits/export_traits.py from design/gdd/npc-traits-catalogue.md and design/world/depth/traits-v2.json (NPC Traits #42, Traits v2 amendment 2026-11-25); do not edit by hand. Stat values are in the stat's own units (percent, points or pp, as the key reads them). pulls: the Sects F15 pulls the engine reads; notes: pulls kept as text (event weights and such, read by later systems).",
        "personality": [],
        "callings": [],
        "calling_weights": {},
        "fate": [],
        "retired_fates": RETIRED_FATES,
        "gained": [],
        "upbringing": [],
        "talent": [],
        "path": [],
        "lifestyle": [],
        "health": [],
        "coping": [],
        "fade_seasons": 40,
        "row_premium": ROW_PREMIUM,
        "opinion": OPINION,
        "choice": CHOICE,
        "inherit": INHERIT,
        "roll": ROLL,
        "roll_v2": ROLL_V2,
        "opposed_v2": OPPOSED_V2,
        "path_root_bonds": PATH_ROOT_BONDS,
        "policy_hooks": POLICY_HOOKS,
        "verb_hooks": parse_catalogue_verb_hooks(v2_sec),
    }

    # personality (already doubled in npc-traits-catalogue.md; validated against 2x Small v1)
    sec = section(text, "## Personality")
    set_no = 0
    for line in sec.splitlines():
        if not line.startswith("|") or "---" in line or "Trait" in line:
            continue
        c = cells(line)
        if len(c) < 8:
            continue
        if c[0].isdigit():
            set_no = int(c[0])
        m = re.match(r"(.+?)\s*\((.+)\)", c[1])
        if not m:
            continue
        out["personality"].append({
            "id": slug(m.group(1)),
            "name": m.group(1),
            "name_vi": m.group(2),
            "set": set_no,
            "boon": rows(c[2], codes),
            "cost": rows(c[3], codes),
            "tags": tags(c[4]),
            "regard": regard(c[5]),
            "weight": float(c[6]) if c[6] else 1.0,
            "pulls": pulls(c[7]),
        })

    # callings (unchanged 1x Small v1)
    sec = section(text, "## Callings")
    ccodes = dict(codes)
    ccodes.update(stat_codes(sec))
    for line in sec.splitlines():
        if not line.startswith("|") or "---" in line or "Calling" in line or "Archetype" in line:
            continue
        c = cells(line)
        if len(c) == 6 and c[0].isdigit():
            m = re.match(r"(.+?)\s*\((.+)\)", c[1])
            out["callings"].append({
                "id": slug(m.group(1)),
                "name": m.group(1),
                "name_vi": m.group(2),
                "boon": rows(c[2], ccodes),
                "cost": rows(c[3], ccodes),
                "tags": tags(c[4]),
                "pulls": pulls(c[5]),
            })
        elif (len(c) == 2 and "·" in c[1]) or (len(c) == 2 and ":" in c[1]):
            arch = c[0]
            ws = {}
            if ":" in c[1]:
                names, w = c[1].split(":")
                for n in names.split(","):
                    ws[slug(n.strip())] = float(w.strip().split()[0])
            else:
                for part in re.split(r"\s*·\s*", c[1]):
                    m2 = re.match(r"(.+?)\s+([\d.]+)$", part.strip())
                    if m2:
                        ws[slug(m2.group(1))] = float(m2.group(2))
            m3 = re.match(r"(.+?)\s*\((.+)\)", arch)
            out["calling_weights"][slug(m3.group(1)) if m3 else ("sect_member" if "sect member" in arch.lower() else slug(arch))] = ws

    # fate-given (keep ONLY the 4 kept fates; skip strikethrough retired entries)
    sec = section(text, "## Fate-given")
    fcodes = dict(codes)
    fcodes.update(stat_codes(sec))
    pair = ""
    for line in sec.splitlines():
        if not line.startswith("|") or "---" in line or "Trait" in line or "Code" in line:
            continue
        c = cells(line)
        if len(c) < 7:
            continue
        if c[0]:
            pair = c[0]
        if c[1].startswith("~~"):
            continue
        m = re.match(r"(.+?)\s*\((.+)\)", c[1])
        if not m:
            continue
        out["fate"].append({
            "id": slug(m.group(1)),
            "name": m.group(1),
            "name_vi": m.group(2),
            "pair": slug(pair),
            "rows": rows(c[2], fcodes),
            "world_price": c[3],
            "tags": tags(c[4]),
            "regard": regard(c[5]),
            "reads": c[6],
        })

    # gained (16 traits, unchanged)
    sec = section(text, "## Gained")
    for line in sec.splitlines():
        if not line.startswith("|") or "---" in line or "Trait" in line:
            continue
        c = cells(line)
        if len(c) < 9 or not c[0].isdigit():
            continue
        m = re.match(r"(.+?)\s*\((.+)\)", c[1])
        out["gained"].append({
            "id": slug(m.group(1)),
            "name": m.group(1),
            "name_vi": m.group(2),
            "grade": c[2],
            "rows": rows(c[3], fcodes),
            "tags": tags(c[4]),
            "regard": regard(c[5]),
            "opposed": slug(c[6]) if c[6] else "",
            "trigger": c[7].strip("`"),
            "pulls": pulls(c[8]),
        })

    # v2 kinds (80 traits across 6 kinds)
    v2_built = build_v2(v2_raw)
    for kind in V2_KINDS:
        out[kind] = v2_built[kind]

    errs = validate(out, text, v2_sec, all_codes, small_v1)
    return out, errs


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true", help="rebuild in memory, validate, and verify assets/data/traits.json is up to date")
    args = ap.parse_args()

    out, errs = build()
    if errs:
        for e in errs:
            print("FAILED:", e)
        print("%d validation failure(s); nothing written" % len(errs))
        return 1

    rendered = json.dumps(out, ensure_ascii=False, indent=1) + "\n"
    if args.check:
        if not os.path.exists(OUT):
            print("FAILED: %s does not exist" % OUT)
            return 1
        current = open(OUT, encoding="utf-8").read()
        if current != rendered:
            print("FAILED: %s is out of date; run python -I tools/design/traits/export_traits.py" % OUT)
            return 1
    else:
        with open(OUT, "w", encoding="utf-8") as fh:
            fh.write(rendered)

    print(json.dumps({k: len(v) for k, v in out.items() if isinstance(v, (list, dict))}))
    unk = [(t["id"], t["pulls"].get("notes")) for t in out["personality"] + out["callings"] if t["pulls"].get("notes")]
    print("pull notes kept as text:", unk)
    return 0


if __name__ == "__main__":
    sys.exit(main())
