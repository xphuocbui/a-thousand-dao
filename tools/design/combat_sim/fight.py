#!/usr/bin/env python3
"""fight.py: runs a build file on the canonical combat engine (moved here from the design-build skill 2026-11-11).

EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
It prints what happened in the fights, which caps clipped and what it could not model. Whether that is
good enough is the skill's call.

The fight itself is tools/design/combat_sim/sim.py, the simulator the Combat GDDs cite (one model, not
two). This file only reads a build file, turns it into the simulator's Build and Art records, picks the
enemies and prints the results. It is not the game:
  - crit, evade and stack timers are rolled, so every matchup runs over seeds (default 20, fixed seeds,
    so a run is repeatable)
  - anything a build lists under "unmodelled" is not simulated and is printed back, and any field this
    file does not know stops the run, so a result never looks more complete than it is
  - the constants the simulator uses are checked against the GDD text (--selftest, and on every run)

Usage:
  python fight.py --selftest                 constants against the GDDs, then the simulator's own scenarios
  python fight.py BUILD.json                 the build against its "enemy" (default typical), same realm
  python fight.py BUILD.json --matrix        against typical and top_end, same realm and one and two realms up
  python fight.py BUILD.json --enemy top_end --gap 1 --timeline
  python fight.py BUILD.json --without "Ash Ledger"
                                             the same runs with one piece removed: an art id, a top-level key,
                                             or a dotted key such as keystones.k_burn
Exit codes: 0 ran; 1 a selftest case or a constant failed; 2 bad input.
"""
import argparse
import copy
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def find_root():
    d = HERE
    for _ in range(8):
        if os.path.exists(os.path.join(d, "tools", "design", "combat_sim", "sim.py")):
            return d
        d = os.path.dirname(d)
    return None


ROOT = find_root()
if ROOT is None:
    print("SIM_NOT_FOUND\ttools/design/combat_sim/sim.py was not found above this script")
    sys.exit(2)
sys.path.insert(0, os.path.join(ROOT, "tools", "design", "combat_sim"))
import sim  # noqa: E402
import engine  # noqa: E402  (the fights run here since 2026-11-11; sim.py keeps the #44 record)

REALMS = ["luyen_khi", "truc_co", "ket_dan", "nguyen_anh", "hoa_than"]

# ------------------------------------------------------------------ values the loader uses, each with its GDD text
# (file, anchor text, value). An anchor that is no longer in the file prints CONSTANT_DRIFT and makes every
# result NOT ASSESSED until this table is updated.
CONST = {
    "layer_caps": ("combat.md", "| cap_1 to cap_5 | float | 400 / 300 / 250 / 150 / 100 |", [400, 300, 250, 150, 100]),
    "l1_soft": ("combat.md", "| l1_soft_start, l1_soft_slope | float | 200, 0.5 |", (200, 0.5)),
    "crit_chance_cap": ("combat.md", "| crit_base, crit_chance_cap | float | 0, 0.5 |", 0.5),
    "crit_mult_cap": ("combat.md", "| crit_mult_base, crit_mult_cap | float | 1.5, 3.0 |", 3.0),
    "cooldown_min": ("combat.md", "| cooldown_min | float | 0.5 s |", 0.5),
    "slots_by_realm": ("combat.md", "| slots_by_realm | int | 3 / 4 / 5 / 6 / 7 |", [3, 4, 5, 6, 7]),
    "art_lint": ("combat.md", "| art_coef_per_cost, art_coef_per_cooldown | float | 24 (", (24, 0.25)),
    "cost_share": ("combat.md", "| cost_share | float | 0.02–0.125 (halved, #44 item B1) |", (0.02, 0.125)),
    "cooldown_range": ("combat.md", "| cooldown | float | 0.5–12 s", (0.5, 12)),
    "fatigue_start": ("combat.md", "| fatigue_start | float | 60 s |", 60.0),
    "fatigue_units": ("combat.md", "| fatigue_units | float | 0.5 (0.25–1.0) |", 0.5),
    "fatigue_pow": ("combat.md", "| fatigue_pow | float | 2 (2–3) |", 2.0),
    "health_units": ("combat.md", "| health_units | float | 48–104, default 64", 64),
    "qi_units": ("combat.md", "| qi_units | float | 18–36, default 26 |", 26),
    "regen_base": ("combat.md", "| regen_base | float | 0.035", 0.035),
    "regen_k": ("combat.md", "| regen_k | float | 0.08 |", 0.08),
    "suppression": ("combat.md", "| s_g | float | 0 / 0.10 / 0.25 / 0.50 / 0.75 |", [0, 0.10, 0.25, 0.50, 0.75]),
    "typical_M": ("combat.md", "| Core Formation | 447 | 5.48 |", [3.273, 4.19, 5.48, 7.37, 8.96]),
    "topend_M": ("combat.md", "| Deity Transformation | 1,172 | 8.96 | re-derive | 7.0 | 325 |", [103, 148, 210, 256, 325]),
    "common_ward": ("combat-defence.md", "the Common Ward is 342.5 points", 342.5),
    "drain_44": ("combat-defence.md", "×0.2 with #44 (the Common Ward 1.64 → 0.328)", 0.2),
    "typical_ws": ("combat-defence.md", "| Nascent Soul | 62.5 | 557 |", [30.8, 37.9, 47.9, 62.5, 84.1]),
    "typical_block": ("combat-defence.md", "| Core Formation | 16.4 / 10.9 |", [15.0, 15.7, 16.4, 17.7, 19.2]),
    "default_ward": ("combat-defence.md", "all 60 points (stops 37.5 %) at drain 0.40", (60, 0.40)),
    "block_unit": ("combat-defence.md", "0.0631 / 0.2031 / 0.6672 / 2.254 / 6.883", [0.0631, 0.2031, 0.6672, 2.254, 6.883]),
    "defence_layer_caps": ("combat-defence.md", "| cap_2 to cap_5 | float | 300 / 250 / 150 / 100 | data file (`defence_layer_caps`)", [300, 250, 150, 100]),
    "w_ref": ("combat-defence.md", "| w_ref | float | 2.587 |", 2.587),
    "layer_gear_scale": ("combat-defence.md", "| layer_gear_scale | float | 0.47 |", 0.47),
    "ward_gear_scale": ("combat-defence.md", "| ward_gear_scale | float | 0.30 |", 0.30),
    "heal_lint_ratio": ("combat-defence.md", "| heal_lint_ratio | float | 1.4", 1.4),
}
C = {k: v[2] for k, v in CONST.items()}

# The simulator's own knobs must hold the same values (it has no anchors of its own)
SIM_KNOBS = {"fatigue_start": C["fatigue_start"], "fatigue_units": C["fatigue_units"], "fatigue_pow": C["fatigue_pow"],
             "health_mult": C["health_units"] / 16, "regen_base": C["regen_base"], "regen_k": C["regen_k"],
             "drain_scale": C["drain_44"], "cost_scale": 0.5, "ward_mult": 1.25}


def check_constants():
    """Prints one CONSTANT_DRIFT line per anchor the GDDs no longer hold, and one SIM_DRIFT per knob."""
    ok = True
    texts = {}
    for key, (fname, anchor, _) in CONST.items():
        path = os.path.join(ROOT, "design", "gdd", fname)
        if fname not in texts:
            if not os.path.exists(path):
                print("CONSTANTS_NOT_CHECKED\t%s not found" % path)
                return False
            with open(path, encoding="utf-8") as f:
                texts[fname] = f.read()
        if anchor not in texts[fname]:
            print("CONSTANT_DRIFT\t%s\tanchor not in %s: %s" % (key, fname, anchor))
            ok = False
    for k, v in SIM_KNOBS.items():
        if abs(sim.K[k] - v) > 1e-9:
            print("SIM_DRIFT\t%s\tsim.py has %s, the GDDs say %s" % (k, sim.K[k], v))
            ok = False
    if list(sim.U) != [6.31, 15.85, 39.81, 100.0, 251.19] or [round(x, 4) for x in sim.BLOCK_UNIT] != C["block_unit"] \
            or list(sim.SUPP) != C["suppression"]:
        print("SIM_DRIFT\tU, BLOCK_UNIT or SUPP in sim.py differ from the GDDs")
        ok = False
    print("constants_verified\t%s" % ("all" if ok else "NO"))
    return ok


# ------------------------------------------------------------------ layer arithmetic (Combat Formulas B; Defence A0)
def offence_M(x, notes, who):
    """Combat Formulas B. x = [x1..x5] in points. Returns M and notes cap hits."""
    caps = C["layer_caps"]
    start, slope = C["l1_soft"]
    x = list(x) + [0] * (5 - len(x))
    x1 = max(-90.0, x[0])
    x1e = x1 if x1 <= start else start + slope * (x1 - start)
    if x1 > start:
        notes.append("soft_knee\t%s\tL1 %.1f counts as %.1f past +%d" % (who, x1, x1e, start))
    m = 1 + min(x1e, caps[0]) / 100
    if x1e > caps[0]:
        notes.append("cap_hit\t%s\tL1 %.1f over cap %d" % (who, x1e, caps[0]))
    for i in range(1, 5):
        if x[i] > caps[i]:
            notes.append("cap_hit\t%s\tL%d %.1f over cap %d" % (who, i + 1, x[i], caps[i]))
        m *= 1 + min(max(0.0, x[i]), caps[i]) / 100
    return m


def defence_layers(y, notes, who):
    """Combat Defence & Healing Formulas A0: four layers, the same caps as L2-L5."""
    caps = C["defence_layer_caps"]
    y = list(y) + [0] * (4 - len(y))
    m = 1.0
    for i in range(4):
        if y[i] > caps[i]:
            notes.append("cap_hit\t%s\tlayer %d %.1f over cap %d" % (who, i + 2, y[i], caps[i]))
        m *= 1 + min(max(0.0, y[i]), caps[i]) / 100
    return m


# ------------------------------------------------------------------ the build file
TOP_KEYS = {"name", "realm", "layers", "crit", "n_body", "n_qi", "art_speed_pct", "art_cost_pct",
            "art_cost_health_pct", "regen_bonus_pp", "health_regen_pp", "healing_pct", "evade_pct",
            "accuracy_pct", "gain_on_hit_pct", "leech_qi_pct", "leech_health_pct", "ward", "body", "cleanse",
            "keystones", "curses", "purity", "bonus_slots", "arts", "enemy", "enemy_overrides", "unmodelled",
            "_comment", "effects", "counters", "companions", "shields", "basic_speed_pct", "opening_haste_pct",
            "basic_coef_add", "timer_resist_pct", "ward_bill_pct", "refusals", "divine_sense", "soul_res_pct",
            "x_soul", "tam_ma", "resist", "boss", "tags", "states", "techniques"}
WARD_KEYS = {"model", "payload", "drain_base", "ws_base", "we", "layers", "block"}
BODY_KEYS = {"block", "resistance", "shield", "layers"}
ART_KEYS = {"id", "c_art", "cost_share", "cooldown", "element", "kind", "buff", "debuff", "c_heal",
            "qi_restore", "cleanse", "x", "_comment", "tags", "guards", "statuses", "split", "soul_pct",
            "soul_part", "bypass", "pool", "convert", "hp_cost", "charges", "group", "steps", "empower"}
CLEANSE_KEYS = {"per_pulse", "fee_share", "share"}
KEYSTONES = {f for f in sim.Build.__dataclass_fields__ if f.startswith("k_")}
CURSES = {"withering": "curse_wither", "stagnation": "curse_stagnate"}
ELEMENTS = {"", "fire", "water", "earth", "metal", "wood", "thunder", "wind", "ice"}


class BadInput(Exception):
    pass


def check_keys(d, allowed, where):
    if not isinstance(d, dict):
        raise BadInput("%s must be an object" % where)
    extra = sorted(set(d) - allowed)
    if extra:
        raise BadInput("UNKNOWN_FIELD\t%s: %s. Allowed: %s. Put what the simulator cannot express in "
                       "\"unmodelled\"" % (where, ", ".join(extra), ", ".join(sorted(allowed))))


# ------------------------------------------------------------------ the art library and technique catalogue
# A build may name library pieces instead of copying them (2026-11-11):
#   "arts": [{"lib": "<art id>"}]      -> the art record from design/arts/family-*.json (or a `common` art of
#                                         design/arts/part-*.json), its effects, counters, states
#   "techniques": ["<technique id>"]   -> the technique's passives from design/techniques/catalogue-*.json, as one
#                                         always-on Effect "tech:<id>" (so --without tech:<id> tests it)
LIB_ART_KEYS = ART_KEYS - {"x", "_comment"}
ELEMENT_EN = {"hoa": "fire", "thuy": "water", "tho": "earth", "kim": "metal", "moc": "wood", "bang": "ice",
              "loi": "thunder", "phong": "wind"}
DTYPE_TAG = {"physical": "phys", "fire": "fire", "cold": "cold", "lightning": "lightning", "force": "force",
             "chaos": "chaos", "soul": "soul"}
# GDD passive key -> (engine mod key, factor to the engine's unit)
PASSIVE_MOD = {"attack_pct": ("L1", 1), "damage_more": ("L2", 1), "crit_chance_pct": ("crit", 1),
               "crit_damage_pct": ("crit_mult", 1), "accuracy_pct": ("acc", 1), "evade_pct": ("evade", 1),
               "art_speed_pct": ("art_speed", 1), "basic_speed_pct": ("basic_speed", 1),
               "opening_haste_pct": ("opening_haste", 1), "art_cost_pct": ("cost_red", -0.01),
               "linh_luc_regen_pct": ("regen", 0.01), "linh_luc_regen_inc_pct": ("regen", 0.00035),
               "health_regen_pct": ("hregen", 0.01), "healing_pct": ("healing", 1),
               "leech_health_pct": ("leech_hp", 1), "leech_linh_luc_pct": ("leech_qi", 1),
               "linh_luc_on_hit_pct": ("gain_on_hit", 1), "resist_pct": ("resist", 1), "block_rating": ("block", 1),
               "soul_res_pct": ("soul_res", 1), "x_soul": ("x_soul", 1), "timer_resist_pct": ("timer_resist", 1),
               "ward_bill_pct": ("ward_bill", 1), "basic_coef_add": ("basic_coef", 1)}
CTX_MODS = {"L1", "L2", "L3", "L4", "L5", "crit", "crit_mult", "dmg_more", "bypass", "resist"}
_LIB = {}


def _library():
    if not _LIB:
        import glob as _g
        arts, techs = {}, {}
        for f in sorted(_g.glob(os.path.join(ROOT, "design", "arts", "family-*.json"))):
            for a in json.load(open(f, encoding="utf-8")):
                arts[a["id"]] = a
        for f in sorted(_g.glob(os.path.join(ROOT, "design", "arts", "part-*.json"))):
            for a in json.load(open(f, encoding="utf-8")):
                if a.get("tier") == "common":   # the common pool generated techniques roll (cong-phap rule 17)
                    arts.setdefault(a["id"], a)
        for f in sorted(_g.glob(os.path.join(ROOT, "design", "techniques", "catalogue-*.json"))):
            for t in json.load(open(f, encoding="utf-8")):
                techs[t["id"]] = t
        _LIB["arts"], _LIB["techs"] = arts, techs
    return _LIB["arts"], _LIB["techs"]


def passive_effect(t, unmod):
    """A technique's passives as one always-on Effect; lines the engine has no stat for go to unmod."""
    do = []
    for p in t.get("passives", []):
        key, val, scope = p["key"], p["value"], list(p.get("scope", []))
        if key not in PASSIVE_MOD:
            unmod.append("technique %s passive %s %+g %s: no engine stat (not run)" % (t["id"], key, val, scope or ""))
            continue
        mk, f = PASSIVE_MOD[key]
        m = {mk: val * f}
        if scope:
            if mk not in CTX_MODS:
                unmod.append("technique %s passive %s scope %s: the engine reads %s without hit context, so it "
                             "applies to every art" % (t["id"], key, scope, mk))
            else:
                for tag in scope:
                    if tag in ELEMENT_EN:
                        m["element"] = ELEMENT_EN[tag]
                    elif tag in DTYPE_TAG:
                        m["dtype"] = DTYPE_TAG[tag]
                    else:
                        m.setdefault("tags", []).append(tag)
        do.append({"mod": m})
    return {"id": "tech:%s" % t["id"], "on": "always", "do": do} if do else None


def expand_library(d):
    """Resolve {"lib": id} arts and "techniques" ids into plain build fields. Unknown ids are BadInput."""
    if not any(isinstance(a, dict) and "lib" in a for a in d.get("arts", [])) and not d.get("techniques"):
        return d
    arts_lib, techs = _library()
    d = copy.deepcopy(d)
    effects, counters, states = list(d.get("effects", [])), list(d.get("counters", [])), list(d.get("states", []))
    have_c, have_s = {c.get("id") for c in counters}, {s.get("id") for s in states}
    out = []
    for a in d.get("arts", []):
        if isinstance(a, dict) and "lib" in a:
            src = arts_lib.get(a["lib"])
            if not src:
                raise BadInput("arts: library art %r not found in design/arts/ (family-*.json, or part-*.json commons)"
                               % a["lib"])
            x = {k: v for k, v in src.items() if k in LIB_ART_KEYS}
            x["id"] = src["id"]
            x.update({k: v for k, v in a.items() if k != "lib"})
            out.append(x)
            effects += src.get("effects", [])
            for c in src.get("counters", []):
                if c.get("id") not in have_c:
                    have_c.add(c.get("id"))
                    counters.append(c)
            for st in src.get("states", []):
                if st.get("id") not in have_s:
                    have_s.add(st.get("id"))
                    states.append(st)
        else:
            out.append(a)
    d["arts"] = out
    unmod = list(d.get("unmodelled", []))
    for tid in d.pop("techniques", []) or []:
        t = techs.get(tid)
        if not t:
            raise BadInput("techniques: %r not found in design/techniques/catalogue-*.json" % tid)
        e = passive_effect(t, unmod)
        if e:
            effects.append(e)
    d["effects"], d["counters"], d["states"], d["unmodelled"] = effects, counters, states, unmod
    return d


def realm_index(v):
    if isinstance(v, int) and 0 <= v < 5:
        return v
    if v in REALMS:
        return REALMS.index(v)
    raise BadInput("realm must be one of %s" % ", ".join(REALMS))


def ward_fields(w, r, notes, who):
    """A ward spec to the simulator's ward_pts and drain (Combat Defence & Healing A0, A, C)."""
    model = w.get("model", "drain")
    if model == "off":
        return dict(ward_pts=0.0, drain=0.0)
    if model == "default":
        pts, drain44 = C["default_ward"]
        return dict(ward_pts=pts, drain=drain44 / C["drain_44"])
    if model != "drain":
        raise BadInput("ward.model must be drain, default or off (got %r); per-hit, reserved and cast wards "
                       "go in \"unmodelled\" with the closest drain ward" % model)
    ws_base = w.get("ws_base", C["typical_ws"][r])
    we = w.get("we", ws_base)
    m_w = defence_layers(w.get("layers", [40, 40, 20, 10]), notes, who + " ward")
    ws_mult = max(0.1, 1 + ws_base / 100) * m_w / C["w_ref"]
    drain_base = w.get("drain_base", 0.328)
    return dict(ward_pts=w.get("payload", C["common_ward"]) * ws_mult,
                drain=drain_base / C["drain_44"] / (ws_mult * (1 + we / 100)))


def to_build(d, r, notes, who):
    """A build-file object to sim.Build. Raises BadInput on anything it does not know."""
    check_keys(d, TOP_KEYS, who)
    for req in ("layers", "arts"):
        if req not in d:
            raise BadInput("%s: \"%s\" is required" % (who, req))
    kw = {"realm": r}
    kw["M"] = offence_M(d["layers"], notes, who)
    crit = d.get("crit", {"chance": 0.15, "mult": 1.7})
    check_keys(crit, {"chance", "mult"}, who + ".crit")
    ch, mu = crit.get("chance", 0.0), crit.get("mult", 1.5)
    if ch > C["crit_chance_cap"]:
        notes.append("cap_hit\t%s\tcrit chance %.2f over cap %.2f" % (who, ch, C["crit_chance_cap"]))
    if mu > C["crit_mult_cap"]:
        notes.append("cap_hit\t%s\tcrit multiplier %.2f over cap %.2f" % (who, mu, C["crit_mult_cap"]))
    kw["crit"], kw["crit_mult"] = min(ch, C["crit_chance_cap"]), min(mu, C["crit_mult_cap"])
    for key, field, scale in (("n_body", "n_body", 1), ("n_qi", "n_qi", 1), ("art_speed_pct", "art_speed_pct", 1),
                              ("regen_bonus_pp", "regen_bonus", 0.01), ("health_regen_pp", "hregen", 0.01),
                              ("healing_pct", "healing", 0.01), ("evade_pct", "evade", 0.01),
                              ("accuracy_pct", "acc", 0.01), ("gain_on_hit_pct", "gain_on_hit", 0.01),
                              ("leech_qi_pct", "leech_qi", 0.01), ("leech_health_pct", "leech_hp", 0.01)):
        if key in d:
            kw[field] = d[key] * scale
    if "art_cost_pct" in d:
        kw["cost_red"] = min(0.5, d["art_cost_pct"] / 100)
        if d["art_cost_pct"] > 50:
            notes.append("cap_hit\t%s\tart cost reduction %.0f %% over 50 %%" % (who, d["art_cost_pct"]))
    if d.get("art_cost_health_pct", 0) > 0:
        X = d["art_cost_health_pct"]
        kw["hp_pay"] = X / (100 + X)
        notes.append("model_note\t%s\tart_cost_health_pct: the simulator converts the health share by the "
                     "pool ratio, the GDD point for point (Combat Formulas E)" % who)
    ward = d.get("ward", {})
    check_keys(ward, WARD_KEYS, who + ".ward")
    kw.update(ward_fields(ward, r, notes, who))
    kw["block"] = ward.get("block", C["typical_block"][r])
    body = d.get("body", {})
    check_keys(body, BODY_KEYS, who + ".body")
    if body:
        kw["bs_mult"] = defence_layers(body.get("layers", [0, 0, 0, 0]), notes, who + " body")
        kw["body_block"] = body.get("block", 0.0)
        kw["body_pts"] = body.get("resistance", 0.0)
        kw["body_shield"] = body.get("shield", 0.0)
    cl = d.get("cleanse", {})
    check_keys(cl, CLEANSE_KEYS, who + ".cleanse")
    kw["cleanse_pulse"] = int(cl.get("per_pulse", 0))
    kw["cleanse_cost"] = cl.get("fee_share", 0.0)
    kw["cleanse_share"] = cl.get("share", 0.0)
    ks = d.get("keystones", {})
    check_keys(ks, KEYSTONES, who + ".keystones")
    kw.update(ks)
    for c in d.get("curses", []):
        if c not in CURSES:
            raise BadInput("%s.curses: %r is not one of %s" % (who, c, ", ".join(CURSES)))
        kw[CURSES[c]] = True
    pur = d.get("purity", {})
    check_keys(pur, ELEMENTS - {""}, who + ".purity")
    kw["purity"] = dict(pur)
    arts = []
    base_x = list(d["layers"]) + [0] * 5
    lo, hi = C["cost_share"]
    cmin, cmax = C["cooldown_range"]
    per_cost, per_cd = C["art_lint"]
    for i, a in enumerate(d.get("arts", [])):
        check_keys(a, ART_KEYS, "%s.arts[%d]" % (who, i))
        aid = a.get("id", "art%d" % (i + 1))
        c, cost, cd = a.get("c_art", 0.0), a.get("cost_share", 0.05), a.get("cooldown", 3.0)
        lint = 1.0 * (1 + per_cost * cost) + per_cd * (cd - 1)
        if c > lint + 1e-9:
            notes.append("lint_over\t%s\t%s: c_art %.2f over the art lint %.2f" % (who, aid, c, lint))
        if a.get("c_heal", 0) > C["heal_lint_ratio"] * lint + 1e-9:
            notes.append("lint_over\t%s\t%s: c_heal %.2f over the heal lint %.2f" % (who, aid, a["c_heal"],
                                                                                    C["heal_lint_ratio"] * lint))
        if not lo <= cost <= hi:
            notes.append("range\t%s\t%s: cost_share %.3f outside %.3f-%.3f" % (who, aid, cost, lo, hi))
        if not cmin <= cd <= cmax:
            notes.append("range\t%s\t%s: cooldown %.2f outside %.1f-%.0f s" % (who, aid, cd, cmin, cmax))
        if cd / (1 + d.get("art_speed_pct", 0) / 100) < C["cooldown_min"]:
            notes.append("cap_hit\t%s\t%s: cooldown floored at %.1f s" % (who, aid, C["cooldown_min"]))
        el = a.get("element", "")
        if el not in ELEMENTS:
            raise BadInput("%s: element %r is not one of %s" % (aid, el, ", ".join(sorted(ELEMENTS - {""}))))
        kind = a.get("kind", "phys")
        if kind not in ("phys", "elem"):
            raise BadInput("%s: kind must be phys or elem" % aid)
        m_mult = 1.0
        if "x" in a:
            mx = [base_x[j] + (list(a["x"]) + [0] * 5)[j] for j in range(5)]
            m_mult = offence_M(mx, notes, who + " " + aid) / kw["M"]
        arts.append(sim.Art(aid, c, cost / sim.K["cost_scale"], cd, el, kind, tuple(a.get("buff", ())),
                            tuple(a.get("debuff", ())), a.get("c_heal", 0.0), a.get("qi_restore", 0.0),
                            int(a.get("cleanse", 0)), m_mult))
    slots = C["slots_by_realm"][r] + d.get("bonus_slots", 0)
    if len(arts) > slots:
        notes.append("slots_over\t%s\t%d arts in %d slots (slots_by_realm + bonus_slots)" % (who, len(arts), slots))
    kw["arts"] = arts
    old = sim.Build(d.get("name", who), **kw)
    try:
        eb = engine.from_sim(old)
    except engine.EngineError as e:
        raise BadInput("%s: %s" % (who, e))
    eb.layers = list(d["layers"]) + [0] * (5 - len(d["layers"]))
    for i, a in enumerate(d.get("arts", [])):
        ea = eb.arts[i]
        ea.tags = tuple(a.get("tags", ()))
        ea.guards = list(a.get("guards", []))
        ea.statuses = list(a.get("statuses", []))
        ea.split = list(a.get("split", []))
        ea.soul_pct = a.get("soul_pct", 0.0)
        ea.soul_part = a.get("soul_part", 0.0)
        ea.bypass = a.get("bypass", 0.0)
        ea.pool = a.get("pool", "qi")
        ea.convert = dict(a.get("convert", {}))
        ea.hp_cost = a.get("hp_cost", 0.0)
        ea.charges = int(a.get("charges", 1))
        ea.group = a.get("group", "")
        ea.steps = list(a.get("steps", []))
        ea.empower = list(a.get("empower", []))
        if ea.soul_pct:
            ea.c = 0.0
    eb.effects = eb.effects + list(d.get("effects", []))
    eb.counters = list(d.get("counters", []))
    eb.companions = list(d.get("companions", []))
    eb.shields = [engine.Shield(**sh) for sh in d.get("shields", [])]
    for key, field in (("basic_speed_pct", "basic_speed_pct"), ("opening_haste_pct", "opening_haste_pct"),
                       ("basic_coef_add", "basic_coef_add"), ("timer_resist_pct", "timer_resist"),
                       ("ward_bill_pct", "ward_bill_pct"), ("refusals", "refusals"), ("divine_sense", "divine_sense"),
                       ("soul_res_pct", "soul_res"), ("x_soul", "x_soul"), ("tam_ma", "tam_ma"), ("boss", "boss")):
        if key in d:
            setattr(eb, field, d[key])
    eb.resist = dict(d.get("resist", {}))
    eb.tags = tuple(d.get("tags", ()))
    eb.states = list(d.get("states", []))
    try:
        engine.validate(eb)
    except engine.EngineError as e:
        raise BadInput("%s: %s" % (who, e))
    return eb


# ------------------------------------------------------------------ reference enemies
def enemy_file(kind, r):
    """Reference enemies as build files. Exact at Qi Refining; fitted elsewhere (Combat Formulas B marks the
    top-end columns re-derive)."""
    kit = [dict(id=a.name, c_art=a.c, cost_share=a.cost * sim.K["cost_scale"], cooldown=a.cd) for a in sim.kit()]
    if kind == "typical":  # L2-L5 typical (2.587); L1 carries the realm's anchor M
        return dict(name="typical", layers=[x1_for(C["typical_M"][r] / 2.587), 40, 40, 20, 10], n_body=1.0883,
                    n_qi=1.053, ward={"ws_base": C["typical_ws"][r]}, arts=kit)
    top_layers = [x1_for(C["topend_M"][r] / 70.0), 300, 250, 150, 100]  # L2-L5 at their caps (70)
    if kind == "top_end":
        return dict(name="top_end", layers=top_layers, crit={"chance": 0.5, "mult": 2.0}, n_body=1.6, n_qi=1.3,
                    ward={"ws_base": 163, "we": 156, "layers": [300, 235, 150, 100], "block": 17}, arts=kit)
    if kind == "top_end_the_tu":
        # The Qi Refining thể tu fixture (Combat Defence & Healing G) read as a typical-level thể tu at body layers
        # 2.587, so its base values are the fixture's / 2.587; at every body cap (70) it is x27.06 over the fixture.
        # Health regeneration 10.8 % of health_max a pulse after the layers (about even, Open Question 22).
        return dict(name="top_end_the_tu", layers=top_layers, crit={"chance": 0.5, "mult": 2.0}, n_body=1.2,
                    n_qi=1.0, ward={"model": "default", "block": 0},
                    body={"block": 88.3 / 2.587, "resistance": 36.1 / 2.587, "shield": 0.90,
                          "layers": [300, 250, 150, 100]},
                    health_regen_pp=10.8 / 70, arts=kit)
    raise BadInput("enemy must be typical, top_end or top_end_the_tu")


def x1_for(L1):
    """The x1 that gives layer L1, through the soft knee (Combat Formulas B)."""
    start, slope = C["l1_soft"]
    x1e = 100 * (L1 - 1)
    return x1e if x1e <= start else start + (x1e - start) / slope


def merge(a, b):
    out = copy.deepcopy(a)
    for k, v in b.items():
        if isinstance(v, dict) and isinstance(out.get(k), dict):
            out[k] = merge(out[k], v)
        else:
            out[k] = copy.deepcopy(v)
    return out


# ------------------------------------------------------------------ running
def run(build, enemy, seeds):
    res = [engine.fight(build, enemy, seed=s) for s in range(seeds)]
    n = len(res)
    t = sum(x["t"] for x in res) / n
    win = sum(x["win"] == "A" for x in res)
    loss = sum(x["win"] == "B" for x in res)
    other = n - win - loss

    def dry(side):
        v = [x[side].dry_at for x in res if x[side].dry_at is not None]
        return ("%.1f" % (sum(v) / len(v))) if len(v) > n / 2 else "never"
    fires = [sum(x["A"].fired[i] for x in res) / n for i in range(len(build.arts))]
    hp_left = sum(max(0.0, x["A"].hp) / x["A"].hp_max for x in res) / n
    clipped = {}
    for x in res:
        for k, v in x["A"].clipped.items():
            clipped[k] = clipped.get(k, 0) + v
    return dict(t=t, win=win, loss=loss, other=other, dry_a=dry("A"), dry_b=dry("B"), fires=fires,
                hp_left=hp_left, fat=sum(x["A"].fat for x in res) / n,
                clipped={k: v / n for k, v in clipped.items()})


def print_row(label, out, build):
    print("fight\t%s\tmean %.1f s\twins %d\tlosses %d\tdraws/time %d\tdry you %s\tdry foe %s\thealth left %.0f %%"
          % (label, out["t"], out["win"], out["loss"], out["other"], out["dry_a"], out["dry_b"], 100 * out["hp_left"]))
    for k, v in sorted(out.get("clipped", {}).items()):
        print("clipped	%s	%s	%.1f per fight" % (label, k, v))
    for a, f in zip(build.arts, out["fires"]):
        print("fires\t%s\t%s\t%.1f per fight%s" % (label, a.name, f, "\tNEVER_FIRED" if f == 0 else ""))


def matchups(args, d, r):
    if args.matrix:
        return [(k, g) for k in ("typical", "top_end") for g in (0, 1, 2) if r + g < 5]
    return [(args.enemy or d.get("enemy", "typical"), args.gap)]


def run_all(d, r, args, label_prefix=""):
    notes = []
    build = to_build(d, r, notes, "build")
    results = {}
    for kind, gap in matchups(args, d, r):
        er = r + gap
        if er > 4:
            raise BadInput("--gap %d from %s is past Deity Transformation" % (gap, REALMS[r]))
        enemy = to_build(merge(enemy_file(kind, er), d.get("enemy_overrides", {})), er, notes, "enemy")
        label = "%s%s %s+%d" % (label_prefix, kind, REALMS[er], gap)
        results[(kind, gap)] = run(build, enemy, args.seeds)
        print_row(label, results[(kind, gap)], build)
    return build, notes, results


def remove_piece(d, piece):
    d = copy.deepcopy(d)
    eids = [e.get("id") for e in d.get("effects", [])]
    if piece in eids:
        d["effects"] = [e for e in d["effects"] if e.get("id") != piece]
        return d
    ids = [a.get("id") for a in d.get("arts", [])]
    if piece in ids:
        d["arts"] = [a for a in d["arts"] if a.get("id") != piece]
        return d
    parts = piece.split(".")
    node = d
    for p in parts[:-1]:
        if not isinstance(node, dict) or p not in node:
            raise BadInput("WITHOUT_NOT_FOUND\t%s" % piece)
        node = node[p]
    if not isinstance(node, dict) or parts[-1] not in node:
        raise BadInput("WITHOUT_NOT_FOUND\t%s (an art id, a top-level key or a dotted key)" % piece)
    del node[parts[-1]]
    return d


# ------------------------------------------------------------------ selftest: the simulator's own scenario table
EXPECTED = {  # sim.scenarios(), 20 seeds, recorded 2026-11-11 after the ward and body layers
    "typical mirror": (36.7, 6, 13), "sustain vs typical": (35.7, 20, 0), "burst vs typical": (22.8, 0, 20),
    "healer mirror (stall check)": (65.8, 5, 7), "healer vs typical": (47.2, 8, 12),
    "fire stacks vs typical": (26.3, 19, 0), "fire stacks vs cleanser": (24.4, 20, 0),
    "water/wood vs typical": (31.7, 18, 1), "ice lock vs typical": (23.7, 20, 0),
    "typical vs +1 realm": (8.8, 0, 20), "top-end mirror (layers)": (35.2, 13, 7),
    "top-end vs typical": (2.0, 20, 0), "top-end the^ tu vs top-end": (57.6, 10, 9),
    "top-end the^ tu mirror": (69.3, 5, 6),
}


def selftest():
    ok = check_constants()
    names = set()
    for name, a, b in sim.scenarios():
        names.add(name)
        res = [sim.fight(a, b, seed=s) for s in range(20)]
        got = (round(sum(x["t"] for x in res) / 20, 1), sum(x["win"] == "A" for x in res),
               sum(x["win"] == "B" for x in res))
        exp = EXPECTED.get(name)
        if exp is None:
            print("SELFTEST_NEW\t%s\t%s (no recorded value: add it to EXPECTED)" % (name, got))
            ok = False
        elif abs(got[0] - exp[0]) > 0.05 or got[1:] != exp[1:]:
            print("SELFTEST_FAIL\t%s\texpected %s, got %s" % (name, exp, got))
            ok = False
        else:
            print("selftest_ok\t%s\t%.1f s, %d-%d" % (name, got[0], got[1], got[2]))
    for name in sorted(set(EXPECTED) - names):
        print("SELFTEST_MISSING\t%s\tno longer in sim.scenarios()" % name)
        ok = False
    # The loader's reference enemies must reproduce the simulator's own builds at Qi Refining
    for name, a, b in (("typical mirror", "typical", "typical"), ("top-end mirror (layers)", "top_end", "top_end"),
                       ("top-end vs typical", "top_end", "typical"),
                       ("top-end the^ tu vs top-end", "top_end_the_tu", "top_end")):
        notes = []
        A = to_build(enemy_file(a, 0), 0, notes, "a")
        B = to_build(enemy_file(b, 0), 0, notes, "b")
        res = [engine.fight(A, B, seed=s) for s in range(20)]
        got = (round(sum(x["t"] for x in res) / 20, 1), sum(x["win"] == "A" for x in res),
               sum(x["win"] == "B" for x in res))
        sb = {n: (x, y) for n, x, y in sim.scenarios()}[name]
        ref = [engine.fight(engine.from_sim(sb[0]), engine.from_sim(sb[1]), seed=s) for s in range(20)]
        exp = (round(sum(x["t"] for x in ref) / 20, 1), sum(x["win"] == "A" for x in ref),
               sum(x["win"] == "B" for x in ref))
        # the engine is millisecond-exact, so rounding in the loader's anchors (M 3.27325 against 3.273) can move a
        # kill across a pulse: 2 % and two wins of tolerance
        if abs(got[0] - exp[0]) > 0.02 * exp[0] or abs(got[1] - exp[1]) > 2 or abs(got[2] - exp[2]) > 2:
            print("LOADER_FAIL\t%s\tthe loader's enemies give %s, sim.py's builds %s" % (name, got, exp))
            ok = False
        else:
            print("loader_ok\t%s\t%.1f s, %d-%d" % (name, got[0], got[1], got[2]))
    for r in range(5):
        notes = []
        for kind, target in (("typical", C["typical_M"][r]), ("top_end", C["topend_M"][r])):
            m = to_build(enemy_file(kind, r), r, notes, kind).M
            if abs(m - target) > 0.01 * target:
                print("LOADER_FAIL\t%s at %s\tM %.2f, anchor %.2f" % (kind, REALMS[r], m, target))
                ok = False
    import regress
    import test_engine
    print("engine regression against sim.py (40 seeds):")
    if regress.main():
        ok = False
    print("engine mechanism tests:")
    if test_engine.main():
        ok = False
    print("selftest\t%s" % ("passed" if ok else "FAILED"))
    return ok


def print_numbers():
    """The numbers a build is designed against, each read from this file's GDD-anchored table (checked first), so
    a session does not read GDD sections for them. Exit 1 when an anchor drifted: the numbers are then stale."""
    ok = check_constants()
    if not ok:
        print("NOT_VERIFIED\tthe values below may be out of date; read the drifted GDD lines named above")
    realm_names = "Qi Refining / Foundation / Core Formation / Nascent Soul / Deity Transformation"
    rows = [
        ("realms", realm_names),
        ("fight unit U_r", " / ".join(str(u) for u in sim.U)),
        ("health, linh luc", "health_units %s x U x n_body; qi_units %s x U x n_qi (Combat A)"
         % (C["health_units"], C["qi_units"])),
        ("offence layers", "M = L1..L5; caps %s; L1 past +%d counts x%s (Combat B). W fills only L1"
         % (" / ".join(map(str, C["layer_caps"])), C["l1_soft"][0], C["l1_soft"][1])),
        ("typical M", " / ".join(map(str, C["typical_M"])) + "  (L2-L5 typical 1.4, 1.4, 1.2, 1.1)"),
        ("top-end M", " / ".join(map(str, C["topend_M"])) + "  (L2-L5 at their caps)"),
        ("crit caps", "chance %s, multiplier %s; base chance 0, base multiplier 1.5" % (C["crit_chance_cap"],
                                                                                      C["crit_mult_cap"])),
        ("art lint", "c_art <= 1 x (1 + %s x cost_share) + %s x (cooldown - 1); heal lint x%s"
         % (C["art_lint"][0], C["art_lint"][1], C["heal_lint_ratio"])),
        ("art cost, cooldown", "cost_share %s-%s of qi_max; cooldown %s-%s s, floor %s s"
         % (C["cost_share"][0], C["cost_share"][1], C["cooldown_range"][0], C["cooldown_range"][1], C["cooldown_min"])),
        ("art slots", " / ".join(map(str, C["slots_by_realm"])) + " by realm, plus bonus slots"),
        ("linh luc regen", "%s of qi_max a pulse; bonus on a log curve, k %s, no cap (Combat E)"
         % (C["regen_base"], C["regen_k"])),
        ("fatigue", "from %s s: %s x U x n^%s a pulse, n = 1, 2, 3 ...; ends every fight"
         % (C["fatigue_start"], C["fatigue_units"], C["fatigue_pow"])),
        ("suppression", " / ".join(map(str, C["suppression"])) + " for a gap of 0-4 realms"),
        ("resistance", "points, R / (100 + R) stopped, no cap; the Common Ward %s points at ws 0, drain 0.328"
         % C["common_ward"]),
        ("typical ward strength", " / ".join(map(str, C["typical_ws"])) + " by realm (ws = ws_base for typical layers)"),
        ("typical block", " / ".join(map(str, C["typical_block"])) + " rating; block_unit "
         + " / ".join(map(str, C["block_unit"]))),
        ("default ward", "%s points, drain %s, ward strength does not apply" % C["default_ward"]),
        ("ward layers W2-W5", "caps %s; 1 + ws/100 = (1 + ws_base/100) x M_w / %s; W3 = 100 x %s x a_w; ward gear also "
         "adds 100 x %s x a_w to ws_base (Combat Defence A0)"
         % (" / ".join(map(str, C["defence_layer_caps"])), C["w_ref"], C["layer_gear_scale"], C["ward_gear_scale"])),
        ("body layers B2-B5", "same caps; bs_mult scales body block, body resistance, health regen, not the body "
         "shield; B3 = 100 x %s x a_b; no reference value" % C["layer_gear_scale"]),
        ("top-end anchors", "top-end mirror ~35 s, top end vs typical one volley (2 s), typical mirror ~37 s, "
         "top-end the^ tu vs top-end ward build about even at 10.8 % health regen a pulse (simulator)"),
    ]
    for k, v in rows:
        print("number\t%s\t%s" % (k, v))
    print("number\telement stacks\tper stack, simulator's table (Effects System Formulas D): buff %s; debuff %s" % (
        ", ".join("%s %s" % (e, " ".join("%s %s" % kv for kv in d.items())) for e, d in sim.BUFF.items()),
        ", ".join("%s %s" % (e, " ".join("%s %s" % kv for kv in d.items())) for e, d in sim.DEBUFF.items())))
    return 0 if ok else 1


def main():
    ap = argparse.ArgumentParser(description="A design-build build on the canonical combat simulator")
    ap.add_argument("build", nargs="?")
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--matrix", action="store_true")
    ap.add_argument("--enemy", choices=["typical", "top_end", "top_end_the_tu"])
    ap.add_argument("--gap", type=int, default=0)
    ap.add_argument("--timeline", action="store_true")
    ap.add_argument("--without")
    ap.add_argument("--seeds", type=int, default=20)
    ap.add_argument("--numbers", action="store_true")
    args = ap.parse_args()
    if args.selftest:
        return 0 if selftest() else 1
    if args.numbers:
        return print_numbers()
    if not args.build:
        ap.error("a build file or --selftest is needed")
    try:
        with open(args.build, encoding="utf-8") as f:
            d = json.load(f)
    except (OSError, ValueError) as e:
        print("BAD_INPUT\t%s" % e)
        return 2
    try:
        drift_ok = check_constants()
        if not drift_ok:
            print("NOT_ASSESSED\tconstants drifted: results below are observations from out-of-date values")
        d = expand_library(d)
        r = realm_index(d.get("realm", "luyen_khi"))
        build, notes, base = run_all(d, r, args)
        if args.without:
            print("without\t%s" % args.without)
            _, _, wo = run_all(remove_piece(d, args.without), r, args, label_prefix="without ")
            for key in base:
                b, w = base[key], wo[key]
                same = abs(b["t"] - w["t"]) < 0.05 and b["win"] == w["win"] and b["loss"] == w["loss"]
                print("identity\t%s+%d\t%s\tmean %.1f -> %.1f s\twins %d -> %d" % (
                    key[0], key[1], "NO_CHANGE" if same else "changed", b["t"], w["t"], b["win"], w["win"]))
        if args.timeline:
            kind, gap = matchups(args, d, r)[0]
            enemy = to_build(merge(enemy_file(kind, r + gap), d.get("enemy_overrides", {})), r + gap, [], "enemy")
            out = sim.fight(build, enemy, seed=0, trace=True)
            print("timeline\tt\tyou_hp\tyou_qi\tfoe_hp\tfoe_qi\t(shares of maximum; seed 0 against %s+%d)" % (kind, gap))
            for row in out["rows"]:
                print("timeline\t%d\t%.2f\t%.2f\t%.2f\t%.2f" % row[:5])
            print("timeline_end\t%s\t%.2f s" % (out["win"].replace("A", "you").replace("B", "foe"), out["t"]))
        for n in sorted(set(notes)):
            if n.startswith("soft_knee\tenemy"):
                continue  # the reference enemies' own L1 fit, the same on every run
            print(n)
        if r > 0:
            print("model_note\tenemies are exact at Qi Refining and fitted at %s (Combat Formulas B: re-derive)"
                  % REALMS[r])
        print("model_note\tnot modelled by the engine: escape, ward payment models other than drain, companion "
              "targets (shield, heal, Down), boss phases and telegraphs; everything else runs as Effects (engine.py)")
        for u in d.get("unmodelled", []):
            print("UNMODELLED\t%s" % u)
    except BadInput as e:
        print("BAD_INPUT\t%s" % e)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main())
