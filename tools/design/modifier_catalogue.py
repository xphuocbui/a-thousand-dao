"""Generate the General Catalogue tables of design/gdd/modifiers.md from its Formulas A-C.

Usage (from the repo root): python -I tools/design/modifier_catalogue.py > <scratch>/catalogue.md
Then paste the output over the "#### General Catalogue" subsection. The prices, tiers and grades below
mirror the GDD; change the GDD first, then this file, then regenerate.
"""
import math

SMALL, NOTABLE = 1.2, 8.0
MULT = {"universal": 1.0, "broad": 1.25, "family": 1.5, "narrow": 2.0, "pinpoint": 2.5}
ORDER = list(MULT)

# tier of each scope tag (Core Rules 11)
TIER = {}
for t in ["physical", "force", "soul", "hit", "art", "cultivator"]:
    TIER[t] = "broad"
for t in ["fire", "cold", "lightning", "light", "chaos", "<type>", "kim", "moc", "thuy", "hoa", "tho", "sword", "palm", "seal", "beast", "formation", "over_time", "curse",
          "ward", "artifact", "talisman", "companion", "basic", "quick", "slow", "cheap", "costly",
          "weapon", "ward_gear", "body_gear", "utility", "<element>", "<form>", "<role>",
          "creature", "secluded", "travelling"]:
    TIER[t] = "family"
for t in ["<variant>", "poison", "pierce", "lock", "cleanse", "escape", "body_shield", "<status>"]:
    TIER[t] = "narrow"

ELEMENTS = "kim, moc, thuy, hoa, tho"
FORMS = "sword, palm, seal, beast, formation"
SOURCES = "artifact, talisman, formation, companion"
TYPES = "fire, cold, lightning, light, chaos"


def tier(scope, implied=None):
    tags = [t for t in scope] + ([implied] if implied else [])
    if not tags:
        return "universal"
    if len(tags) == 1:
        return TIER[tags[0]]
    a, b = sorted(tags, key=lambda t: ORDER.index(TIER[t]), reverse=True)[:2]
    step = 1 if ORDER.index(TIER[b]) >= ORDER.index("family") else 0
    return ORDER[min(ORDER.index("pinpoint"), ORDER.index(TIER[a]) + step)]


def value(budget, mult, price, u, d=1):
    units = math.floor(budget * mult / (price * u) + 1e-6)
    return d * units * u


def fmt(v, u, unit):
    if v == 0:
        return "—"
    dec = 0 if u >= 1 else (1 if u >= 0.1 else 2)
    s = f"{v:+.{dec}f}"
    return s + unit


# stat: (display, price, grid, unit suffix, better d, implied tag, status, scopes)
# scopes: list of (label, [tags], members) ; members = how many concrete modifiers the row stands for
S = []


def stat(group, name, price, u, unit, d=1, implied=None, status="Live", scopes=(("—", [], 1),), note=""):
    S.append((group, name, price, u, unit, d, implied, status, scopes, note))


OFF = "Combat: offence"
stat(OFF, "Damage, increased (`attack_pct`)", 1.0, 0.1, " %", scopes=[
    ("—", [], 1), ("type: physical or force", ["physical"], 2), ("mode: hit", ["hit"], 1), ("source: art", ["art"], 1),
    ("type: " + TYPES, ["<type>"], 5), ("element (art tag): " + ELEMENTS, ["<element>"], 5), ("form: " + FORMS, ["<form>"], 5),
    ("source: " + SOURCES, ["artifact"], 4), ("mode: over_time (ticks)", ["over_time"], 1),
    ("derived: basic, quick, slow", ["basic"], 3), ("one variant element", ["<variant>"], 8),
    ("effect: poison", ["poison"], 1), ("foe: cultivator (Pending)", ["cultivator"], 1), ("foe: creature (Pending)", ["creature"], 1),
    ("two tags, e.g. [over_time, hoa], [sword, kim]", ["<element>", "<form>"], 0)])
stat(OFF, "Crit chance (`crit_chance_pct`)", 1.0, 0.1, " pp", status="Designed", scopes=[
    ("—", [], 1), ("source: art", ["art"], 1), ("type: physical or force", ["physical"], 2), ("type: " + TYPES, ["<type>"], 5), ("element (art tag)", ["<element>"], 5),
    ("form", ["<form>"], 5), ("derived: basic, quick, slow", ["basic"], 3)])
stat(OFF, "Crit damage (`crit_damage_pct`)", 0.3, 0.1, " pp", status="Designed", scopes=[
    ("—", [], 1), ("source: art", ["art"], 1), ("element", ["<element>"], 5), ("form", ["<form>"], 5)])
stat(OFF, "Accuracy (`accuracy_pct`)", 0.5, 0.1, " pp", status="Designed")
stat(OFF, "Realm pierce (`pierce_pct`)", 1.0, 0.1, " pp", status="Designed", scopes=[("—", [], 1), ("source: art", ["art"], 1)])
stat(OFF, "Resistance penetration (`resist_pen_pct`)", 3.0, 0.1, " pp", status="Designed", scopes=[
    ("—", [], 1), ("type: physical or force", ["physical"], 2), ("type: " + TYPES, ["<type>"], 5), ("element (art tag)", ["<element>"], 5)])
stat(OFF, "Soul attack damage (`x_soul`)", 1.0, 0.1, " %", implied="soul", status="Designed", scopes=[
    ("— (implied soul)", [], 1), ("element (art tag)", ["<element>"], 5)])
stat(OFF, "Art speed (`art_speed_pct`)", 0.6, 0.1, " %", status="Designed", scopes=[
    ("—", [], 1), ("type: physical or force", ["physical"], 2), ("element", ["<element>"], 5), ("form", ["<form>"], 5),
    ("mode: curse", ["curse"], 1), ("source: talisman", ["talisman"], 1), ("derived: quick, slow", ["quick"], 2)])
stat(OFF, "Art cost (`art_cost_pct`)", 0.6, 0.1, " %", d=-1, status="Designed", scopes=[
    ("—", [], 1), ("type: physical or force", ["physical"], 2), ("element", ["<element>"], 5), ("form", ["<form>"], 5),
    ("mode: curse", ["curse"], 1), ("derived: slow, costly", ["slow"], 2), ("effect: poison", ["poison"], 1)])
stat(OFF, "Basic attack speed", 0.4, 0.1, " %", implied="basic", status="Pending", scopes=[("— (implied basic)", [], 1)])
stat(OFF, "Damage conversion (`convert_pct`, from → to type)", 0.8, 1, " pp", implied="<type>", status="Designed", scopes=[
    ("— (implied family; one per from → to pair of the 7 non-Soul types, 7 × 6)", [], 42)])
stat(OFF, "Status duration", 0.6, 0.1, " %", implied="over_time", status="Pending", scopes=[
    ("— (implied over_time)", [], 1), ("mode: curse", ["curse"], 1), ("effect: poison", ["poison"], 1)])

DEF = "Combat: defence"
stat(DEF, "Resistance (`resist_pct`)", 1.25, 0.1, " pp", status="Designed", scopes=[
    ("— (all resistance)", [], 1), ("against type: physical or force", ["physical"], 2),
    ("against type: fire, cold, lightning, light", ["<type>"], 4), ("against type: chaos (rare, rule 13: never on acupoints, notables or rolled affixes)", ["chaos"], 1),
    ("against foe: cultivator (Pending)", ["cultivator"], 1), ("against foe: creature (Pending)", ["creature"], 1)])
stat(DEF, "Block (`block_rating`)", 0.4, 1, " rating", status="Designed", scopes=[
    ("—", [], 1), ("against type: physical or force (Pending)", ["physical"], 2), ("against type: fire, cold, lightning, light (Pending)", ["<type>"], 4)])
stat(DEF, "Body shield (`body_shield_pct`)", 1.0, 0.1, " pp of health", status="Designed")
stat(DEF, "Body shield, increased (`body_shield_pct`, I)", 0.6, 0.1, " %", status="Pending")
stat(DEF, "Shield recharge delay (`recharge_delay_pct`)", 0.6, 0.1, " %", d=-1, implied="ward", status="Pending", scopes=[("— (implied shield)", [], 1)])
stat(DEF, "Cast ward duration (`cast_ward_duration_pct`)", 0.5, 0.1, " %", implied="ward", status="Pending", scopes=[("— (implied ward)", [], 1)])
stat(DEF, "Ward strength (`defense_pct`)", 1.0, 0.1, " %")
stat(DEF, "Ward efficiency (`ward_efficiency_pct`)", 1.0, 0.1, " %", status="Designed")
stat(DEF, "Maximum health (`khi_huyet_pct`)", 1.2, 0.1, " %")
stat(DEF, "Health regeneration (`health_regen_pct`)", 9.9, 0.01, " pp/pulse", status="Designed")
stat(DEF, "Health regeneration, increased (`health_regen_inc_pct`)", 0.3, 0.1, " %", status="Designed")
stat(DEF, "Health leech (`leech_health_pct`)", 0.21, 0.1, " % of damage dealt", status="Designed")
stat(DEF, "Healing (`healing_pct`)", 0.5, 0.1, " %", status="Designed", scopes=[("—", [], 1), ("restores: body_shield (Pending)", ["body_shield"], 1)])
stat(DEF, "Healing taken (`healing_taken_pct`)", 0.5, 0.1, " %", status="Designed")
stat(DEF, "Evade (`evade_pct`)", 1.5, 0.1, " pp", status="Designed")
stat(DEF, "Soul resistance (`soul_res_pct`)", 0.6, 0.1, " pp", status="Designed")
stat(DEF, "Status resistance (`status_resist_pct`)", 0.4, 0.1, " pp", status="Designed", scopes=[
    ("—", [], 1), ("against mode: over_time or curse", ["curse"], 2), ("against effect: poison", ["poison"], 1),
    ("against status: burn, bleed, poison, qi_disruption", ["<status>"], 4)])
stat(DEF, "Status duration on you (`status_duration_taken_pct`)", 0.3, 0.1, " %", d=-1, status="Pending", scopes=[
    ("— (all statuses)", [], 1), ("mode: over_time or curse", ["curse"], 2)])

RES = "Resources"
stat(RES, "Maximum linh lực (`linh_luc_pct`)", 1.0, 0.1, " %")
stat(RES, "Linh lực regeneration (`linh_luc_regen_pct`)", 22.8, 0.01, " pp/s", status="Designed")
stat(RES, "Linh lực regeneration, increased (`linh_luc_regen_inc_pct`)", 0.8, 0.1, " %", status="Designed", scopes=[("—", [], 1), ("element", ["<element>"], 5)])
stat(RES, "Linh lực on hit (`linh_luc_on_hit_pct`)", 42.0, 0.001, " pp of max per hit", status="Designed", scopes=[("—", [], 1), ("element", ["<element>"], 5), ("form", ["<form>"], 5)])
stat(RES, "Linh lực on crit (`linh_luc_on_crit_pct`)", 6.3, 0.01, " pp of max per crit", status="Designed")
stat(RES, "Linh lực on kill (`linh_luc_on_kill_pct`)", 0.5, 0.1, " pp of max per kill", status="Designed")
stat(RES, "Linh lực leech (`leech_linh_luc_pct`)", 1.44, 0.1, " % of damage dealt", status="Designed", scopes=[("—", [], 1), ("element", ["<element>"], 5)])
stat(RES, "Art costs shifted to health (`art_cost_health_pct`)", 0.35, 0.1, " pp", status="Designed")
stat(RES, "Thần thức (`than_thuc_pct`)", 1.3, 0.1, " %")
stat(RES, "Reservation efficiency (`reserve_eff_pct`)", 0.8, 0.1, " %", status="Designed")

STK = "Element stacks"
stat(STK, "Stack effect (`stack_effect_pct`)", 0.5, 0.1, " %", implied="<element>", status="Designed", scopes=[("— (implied element; buff or debuff)", [], 16)])
stat(STK, "Stack duration (`stack_duration_pct`)", 0.4, 0.1, " %", implied="<element>", status="Designed", scopes=[("— (implied element; buff or debuff)", [], 16)])
stat(STK, "Stacks per grant (`stack_grant`)", 8.0, 1, " stack", implied="<element>", status="Designed", scopes=[("— (implied element; rare)", [], 16)])

GEAR = "Gear"
stat(GEAR, "Artifact power (`artifact_power_pct`)", 1.3, 0.1, " %", scopes=[("—", [], 1), ("role", ["<role>"], 4)])
stat(GEAR, "Artifact attack (`artifact_attack_pct`)", 0.6, 0.1, " %")
stat(GEAR, "Artifact defence (`artifact_defense_pct`)", 0.6, 0.1, " %")
stat(GEAR, "Element affinity (`element_affinity_pct`)", 1.3, 0.1, " %", implied="weapon")
stat(GEAR, "Artifact thần thức cost (`than_thuc_cost_pct`)", 0.8, 0.1, " %", d=-1)

PREP = "Preparation and companions"
stat(PREP, "Formation power (`formation_power_pct`)", 1.0, 0.1, " %")
stat(PREP, "Pill effect (`pill_effect_pct`)", 1.0, 0.1, " %")
stat(PREP, "Talisman power", 0.7, 0.1, " %", status="Pending")
stat(PREP, "Talisman keep chance", 0.3, 0.1, " pp", status="Pending")
stat(PREP, "Formation upkeep (`formation_upkeep_pct`)", 0.15, 0.1, " %", d=-1, status="Pending")
stat(PREP, "Talisman ink cost (`talisman_ink_pct`)", 0.15, 0.1, " %", d=-1, status="Pending")
stat(PREP, "Companion power share", 0.4, 0.1, " pp", status="Pending")

ESC = "Escape and fortune"
stat(ESC, "Escape chance (`escape_pct`)", 1.0, 0.1, " pp", status="Designed")
stat(ESC, "Stealth (`stealth`)", 1.5, 0.1, "")
stat(ESC, "Cơ duyên rate (`co_duyen_pct`)", 0.3, 0.1, " %")

CUL = "Cultivation and life"
stat(CUL, "Cultivation speed (`cultivation_speed_pct`)", 2.2, 0.1, " %", scopes=[("—", [], 1), ("activity: secluded or travelling (Pending)", ["secluded"], 2)])
stat(CUL, "Breakthrough chance (`breakthrough_chance`)", 5.0, 0.1, " pp")
stat(CUL, "Lifespan, share (`lifespan_pct`)", 3.0, 0.1, " %")
stat(CUL, "Heart demon resistance (`tam_ma_resist_pct`)", 1.5, 0.1, " %")
stat(CUL, "Qi deviation chance (`qi_deviation_pct`)", 1.0, 0.1, " %", d=-1)
stat(CUL, "Pill toxicity resistance (`dan_doc_resist_pct`)", 1.6, 0.1, " %")
stat(CUL, "Pill toxicity fading (`dan_doc_decay`)", 8.0, 0.01, "")
stat(CUL, "Spirit qi density (`density_bonus`)", 140.0, 0.01, "")

CRA = "Crafting, travel and economy"
stat(CRA, "Alchemy success (`alchemy_success`)", 2.7, 0.1, " pp")
stat(CRA, "Refining success (`refining_success`)", 2.0, 0.1, " pp")
stat(CRA, "Talisman drawing success", 2.0, 0.1, " pp", status="Pending")
stat(CRA, "Taming chance", 1.0, 0.1, " pp", status="Pending")
stat(CRA, "Herb growth (`herb_growth_pct`)", 0.9, 0.1, " %")
stat(CRA, "Mission income (`mission_income_pct`)", 0.7, 0.1, " %")
stat(CRA, "Travel speed (`travel_speed_pct`)", 0.3, 0.1, " %")
stat(CRA, "Pill quality chance (`pill_quality_chance`)", 1.0, 0.1, " pp", status="Pending")
stat(CRA, "Artifact grade chance (`refine_grade_chance`)", 1.5, 0.1, " pp", status="Pending")
stat(CRA, "Buy price (`buy_price_pct`)", 0.3, 0.1, " %", d=-1, status="Pending")
stat(CRA, "Sell price (`sell_price_pct`)", 0.3, 0.1, " %", status="Pending")

ATT = "Attributes (thiên phú)"
stat(ATT, "Comprehension (`ngo_tinh`)", 5.0, 0.01, "")
stat(ATT, "Fortune (`khi_van`)", 5.0, 0.01, "")
stat(ATT, "Root bone (`can_cot`)", 3.0, 0.01, "")
stat(ATT, "Soul (`than_hon`)", 3.0, 0.01, "")
stat(ATT, "Dao heart (`dao_tam`)", 3.0, 0.01, "")
stat(ATT, "Presence (`mi_luc`)", 1.0, 0.01, "")

out = []
total = 0
group = None
for (g, name, price, u, unit, d, implied, status, scopes, note) in S:
    if g != group:
        group = g
        out.append(f"\n**{g}**\n")
        out.append("| Modifier | Scope | Tier | Small (1.2 W) | Notable (8 W) | Status | Count |")
        out.append("|---|---|---|---|---|---|---|")
    for label, tags, members in scopes:
        imp = implied if implied in TIER else ("body_gear" if implied else None)
        t = tier(tags, imp if implied else None)
        m = MULT[t]
        sm, nt = value(SMALL, m, price, u, d), value(NOTABLE, m, price, u, d)
        total += members
        st = "Pending" if "Pending" in label else status
        if tags and st == "Live":
            st = "Designed"  # scope matching is Combat's, not built yet
        out.append(f"| {name} | {label} | {t} | {fmt(sm, u, unit)} | {fmt(nt, u, unit)} | {st} | {members or '—'} |")
print("\n".join(out))
print(f"\nConcrete modifiers listed: {total} (two-tag rows not counted).")
