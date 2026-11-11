"""Lint the authored technique catalogue (design/techniques/*.json) against cong-phap.md and modifiers.md.

Emits observations, not a verdict (CLAUDE.md: helpers in scripts emit observations). One line per finding:
  SCHEMA       a missing or unknown field, a bad tier, kind, layer count, or names list (cong-phap rules 1-3, 5, 12)
  ART_MISSING  an ability_id that is not a signature art in design/arts/family-*.json
  ELEMENT      an elemental art carried by a technique that does not name its element id (rule 8; a body
               technique names none, so it carries element-less arts only)
  UNLOCK       an unlock_layer outside 1..layers, or a suite art unlocking after layer 6 (a Trúc Cơ build
               could not use its whole suite)
  BONUS        a `bonuses` line not in items_cong_phap.json bonus_pool, out of its min-max, or a count other
               than the tier's bonus_count (rule 1, Formulas D)
  NOT_PRICED   a passive key with no W price here (modifiers.md Formulas A): the budget cannot be assessed
  SCOPE        a passive scope tag outside the Modifier tag vocabulary (modifiers.md rule 11)
  OVER_BUDGET  passives above the tier's combat passive budget (8 / 16 / 24 / 32 W; rule 1)
  SUITE_SPLIT  a suite's arts (one `group`) not all carried by one technique whose `suite` names it
  UNCARRIED    (whole-catalogue runs only) a signature art no technique carries
  DUPLICATE    two techniques with the same id
Notes (not findings): `abilities` above 3 (rule 17 says 1-3), passive W used per technique.
It ends with `checked N techniques, F findings` so a run that read nothing cannot look clean.

Run: python -I tools/design/arts/lint_techniques.py [files...]   (default: design/techniques/*.json, whole catalogue)
"""
import glob
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))

LAYERS = {0: 6, 1: 9, 2: 12, 3: 15}                     # cong-phap.md rule 5
BUDGET = {0: 8.0, 1: 16.0, 2: 24.0, 3: 32.0}           # cong-phap.md rule 1, combat passive budget (authored)
KINDS = {"main", "secret", "body"}
ELEMENT_ID = {"fire": "hoa", "water": "thuy", "earth": "tho", "metal": "kim", "wood": "moc",
              "ice": "bang", "thunder": "loi", "wind": "phong"}
NAMEABLE = {"kim", "moc", "thuy", "hoa", "tho", "phong", "loi", "am", "hon_don", "quang", "bang"}  # Blood, Void archived
FIELDS = {"id", "name", "tier", "tech_kind", "names", "layers", "bonuses", "passives", "abilities", "effects",
          "origin", "suite", "family", "lore", "notes"}
REQUIRED = {"id", "name", "tier", "tech_kind", "names", "layers", "bonuses", "passives", "abilities", "origin"}

# modifiers.md Formulas A, W per displayed unit. Keys missing here are NOT_PRICED.
PRICE = {
    "attack_pct": 1.0, "crit_chance_pct": 1.0, "crit_damage_pct": 0.3, "accuracy_pct": 0.5, "pierce_pct": 1.0,
    "resist_pen_pct": 0.1, "x_soul": 1.0, "art_speed_pct": 0.6, "art_cost_pct": 0.6, "basic_speed_pct": 0.4,
    "status_duration_pct": 0.6, "convert_pct": 0.8,
    "resist_pct": 0.04, "block_rating": 0.4, "body_shield_pct": 0.51, "recharge_delay_pct": 0.6,
    "cast_ward_duration_pct": 0.5, "defense_pct": 1.0, "ward_efficiency_pct": 1.0, "khi_huyet_pct": 0.6,
    "evade_pct": 1.5, "soul_res_pct": 0.6, "status_resist_pct": 0.4, "status_duration_taken_pct": 0.3,
    "health_regen_pct": 9.9, "health_regen_inc_pct": 0.3, "leech_health_pct": 0.21, "healing_pct": 0.5,
    "healing_taken_pct": 0.5,
    "linh_luc_pct": 1.0, "linh_luc_regen_pct": 22.8, "linh_luc_regen_inc_pct": 0.8, "linh_luc_on_hit_pct": 42.0,
    "linh_luc_on_crit_pct": 6.3, "linh_luc_on_kill_pct": 0.5, "leech_linh_luc_pct": 1.44,
    "art_cost_health_pct": 0.35, "than_thuc_pct": 1.3, "reserve_eff_pct": 0.8,
    "stack_effect_pct": 0.5, "stack_duration_pct": 0.4, "stack_grant": 10.0,
}
# `more` points (modifiers.md Formulas D, L2 column, at the tier's maximum realm: FE, CF, NS, DT)
MORE_PRICE = {0: 1.16, 1: 1.51, 2: 2.03, 3: 4.95}
MORE_KEYS = {"damage_more", "ward_more", "body_more"}
LOWER = {"art_cost_pct", "recharge_delay_pct", "status_duration_taken_pct"}   # a reduction is the bonus
IMPLIED = {"x_soul": "soul", "basic_speed_pct": "basic", "status_duration_pct": "over_time"}

# modifiers.md rule 11 / Formulas B (mirrors tools/design/modifier_catalogue.py TIER)
MULT = {"universal": 1.0, "broad": 1.25, "family": 1.5, "narrow": 2.0, "pinpoint": 2.5}
ORDER = list(MULT)
TIER = {}
for t in ["physical", "force", "soul", "hit", "art", "cultivator"]:
    TIER[t] = "broad"
for t in ["fire", "cold", "lightning", "light", "chaos", "kim", "moc", "thuy", "hoa", "tho", "sword", "palm",
          "seal", "beast", "formation", "over_time", "curse", "ward", "artifact", "talisman", "companion", "basic",
          "quick", "slow", "cheap", "costly", "weapon", "ward_gear", "body_gear", "utility", "creature",
          "secluded", "travelling", "buff", "debuff"]:
    TIER[t] = "family"
for t in ["poison", "pierce", "lock", "cleanse", "escape", "body_shield", "phong", "loi", "am", "hon_don", "quang",
          "bang"]:
    TIER[t] = "narrow"


def breadth(tags):
    tiers = sorted((ORDER.index(TIER[t]) for t in tags), reverse=True)
    if not tiers:
        return 1.0
    if len(tiers) == 1:
        return MULT[ORDER[tiers[0]]]
    return MULT[ORDER[min(len(ORDER) - 1, tiers[0] + (1 if tiers[1] >= ORDER.index("family") else 0))]]


def load_arts():
    arts = {}
    for f in sorted(glob.glob(os.path.join(ROOT, "design", "arts", "family-*.json"))):
        for a in json.load(open(f, encoding="utf-8")):
            arts[a["id"]] = a
    return arts


def lint(techs, fname, arts, pool, tiers, notes):
    out = []
    pool_by = {p["stat"]: p for p in pool}
    for t in techs:
        tid = t.get("id", "?")
        where = "%s\t%s" % (fname, tid)
        miss = REQUIRED - set(t)
        if miss:
            out.append("SCHEMA\t%s\tmissing %s" % (where, ", ".join(sorted(miss))))
            continue
        extra = set(t) - FIELDS
        if extra:
            out.append("SCHEMA\t%s\tunknown field(s) %s" % (where, ", ".join(sorted(extra))))
        tier = t["tier"]
        if tier not in LAYERS:
            out.append("SCHEMA\t%s\ttier %r is not 0-3" % (where, tier))
            continue
        if t["layers"] != LAYERS[tier]:
            out.append("SCHEMA\t%s\tlayers %r, tier %d has %d" % (where, t["layers"], tier, LAYERS[tier]))
        if t["tech_kind"] not in KINDS:
            out.append("SCHEMA\t%s\ttech_kind %r is not main, secret or body" % (where, t["tech_kind"]))
        if t["origin"] != "authored":
            out.append("SCHEMA\t%s\torigin %r, the catalogue is authored" % (where, t["origin"]))
        names = t["names"]
        if t["tech_kind"] == "body":
            if names:
                out.append("SCHEMA\t%s\ta body technique names no element (rule 2)" % where)
        elif not 1 <= len(names) <= 3 or any(n not in NAMEABLE for n in names):
            out.append("SCHEMA\t%s\tnames %r: 1-3 of %s" % (where, names, ", ".join(sorted(NAMEABLE))))
        # bonuses (bonus_pool, bonus_count)
        want = tiers[tier]["bonus_count"]
        if len(t["bonuses"]) != want:
            out.append("BONUS\t%s\t%d bonuses, tier %d has bonus_count %d" % (where, len(t["bonuses"]), tier, want))
        for b in t["bonuses"]:
            p = pool_by.get(b.get("stat"))
            if not p:
                out.append("BONUS\t%s\t%r is not in bonus_pool" % (where, b.get("stat")))
            elif not p["min"] <= b.get("value", -1) <= p["max"]:
                out.append("BONUS\t%s\t%s %r outside %s-%s" % (where, b["stat"], b.get("value"), p["min"], p["max"]))
        # passives
        w_sum, priced = 0.0, True
        for i, p in enumerate(t["passives"]):
            key, val, scope = p.get("key"), p.get("value"), list(p.get("scope", []))
            if not isinstance(val, (int, float)):
                out.append("SCHEMA\t%s\tpassives[%d] value %r is not a number" % (where, i, val))
                priced = False
                continue
            bad = [s for s in scope if s not in TIER]
            if bad or len(scope) > 2:
                out.append("SCOPE\t%s\tpassives[%d] %s scope %r: tags outside the Modifier vocabulary or more "
                           "than 2" % (where, i, key, scope))
                priced = False
                continue
            if key in MORE_KEYS:
                price = MORE_PRICE[tier]
            elif key in PRICE:
                price = PRICE[key]
            else:
                out.append("NOT_PRICED\t%s\tpassives[%d] %r has no W price (modifiers.md Formulas A)" % (where, i, key))
                priced = False
                continue
            tags = scope + ([IMPLIED[key]] if key in IMPLIED and IMPLIED[key] not in scope else [])
            w_sum += abs(val) * price / breadth(tags) * (1 if val * (-1 if key in LOWER else 1) > 0 else -1)
        if priced and w_sum > BUDGET[tier] + 0.05:
            out.append("OVER_BUDGET\t%s\tpassives %.1f W, tier %d budget %.0f W" % (where, w_sum, tier, BUDGET[tier]))
        notes.append("passive_w\t%s\t%s W of %.0f" % (where, ("%.1f" % w_sum) if priced else "NOT ASSESSED",
                                                      BUDGET[tier]))
        # abilities
        ab = t["abilities"]
        if not ab:
            out.append("SCHEMA\t%s\tno abilities" % where)
        if len(ab) > 3:
            notes.append("note\t%s\t%d abilities (cong-phap rule 17 says 1-3)" % (where, len(ab)))
        for x in ab:
            aid, ul = x.get("ability_id"), x.get("unlock_layer")
            a = arts.get(aid)
            if not a:
                out.append("ART_MISSING\t%s\t%r is not a signature art" % (where, aid))
                continue
            if not isinstance(ul, int) or not 1 <= ul <= t["layers"]:
                out.append("UNLOCK\t%s\t%s unlock_layer %r outside 1-%d" % (where, aid, ul, t["layers"]))
            elif a.get("group") and ul > 6:
                out.append("UNLOCK\t%s\t%s (suite art) unlocks at layer %d, after layer 6" % (where, aid, ul))
            el = a.get("element", "")
            if el and t["tech_kind"] == "body":
                out.append("ELEMENT	%s	%s is %s; a body technique carries element-less arts only" % (where, aid, el))
            elif el and ELEMENT_ID.get(el) not in names:
                out.append("ELEMENT\t%s\t%s is %s (%s) but the technique names %r" % (where, aid, el,
                                                                                    ELEMENT_ID.get(el), names))
    return out


def main():
    args = sys.argv[1:]
    files = args or sorted(glob.glob(os.path.join(ROOT, "design", "techniques", "*.json")))
    if not files:
        print("NO_INPUT\tno technique files found (design/techniques/*.json)")
        return 2
    arts = load_arts()
    if not arts:
        print("NO_INPUT\tno signature arts found (design/arts/family-*.json)")
        return 2
    data = json.load(open(os.path.join(ROOT, "assets", "data", "items_cong_phap.json"), encoding="utf-8"))
    tiers = {x["rank"]: x for x in data["tiers"]}
    findings, notes, alltech = [], [], []
    for f in files:
        try:
            techs = json.load(open(f, encoding="utf-8"))
        except (OSError, ValueError) as e:
            print("UNREADABLE\t%s\t%s" % (f, e))
            return 2
        if not isinstance(techs, list):
            print("UNREADABLE\t%s\tnot a JSON list" % f)
            return 2
        findings += lint(techs, os.path.basename(f), arts, data["bonus_pool"], tiers, notes)
        alltech += techs
    ids = {}
    for t in alltech:
        ids[t.get("id")] = ids.get(t.get("id"), 0) + 1
    findings += ["DUPLICATE\t(all)\t%s in %d entries" % (k, v) for k, v in ids.items() if v > 1]
    # suites: every group's arts in one technique that names the suite
    carried = {}
    for t in alltech:
        for x in t.get("abilities", []):
            carried.setdefault(x.get("ability_id"), []).append(t.get("id"))
    groups = {}
    for a in arts.values():
        if a.get("group"):
            groups.setdefault(a["group"], set()).add(a["id"])
    for g, members in sorted(groups.items()):
        owners = [t for t in alltech if t.get("suite") == g]
        if not owners:
            if not args:
                findings.append("SUITE_SPLIT\t(all)\t%s: no technique has suite %r" % (g, g))
            continue
        for t in owners:
            have = {x.get("ability_id") for x in t.get("abilities", [])}
            if members - have:
                findings.append("SUITE_SPLIT\t%s\t%s lacks %s" % (t.get("id"), g, ", ".join(sorted(members - have))))
    if not args:
        for aid in sorted(arts):
            if aid not in carried:
                findings.append("UNCARRIED\t(all)\t%s" % aid)
    else:
        print("note\tcoverage\tUNCARRIED and missing-suite checks skipped: run with no arguments for the whole catalogue")
    for line in findings + notes:
        print(line)
    kinds = {}
    for t in alltech:
        k = "%s/%s" % (t.get("tech_kind"), t.get("tier"))
        kinds[k] = kinds.get(k, 0) + 1
    print("coverage\tkind/tier\t" + ", ".join("%s %d" % kv for kv in sorted(kinds.items())))
    print("coverage\tarts carried\t%d of %d signature arts" % (sum(1 for a in arts if a in carried), len(arts)))
    print("checked %d techniques, %d findings" % (len(alltech), len(findings)))
    return 0


if __name__ == "__main__":
    sys.exit(main())
