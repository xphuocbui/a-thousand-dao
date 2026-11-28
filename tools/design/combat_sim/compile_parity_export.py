"""Parity cases for the Godot FighterCompiler (ADR-0001 step 3): Character-shaped build files and the resolved engine
Build fight.py compiles from each, so the GDScript port of expand_library() and to_build() can be checked exactly.

Every named item and every library art is in some case: the items are dealt out five to a case, the arts fill each
case's art slots (its items' arts first), and each case carries a rotating set of stat-sheet lines covering every
modifier key fight.py maps, folds or skips, plus scoped lines and a key with no engine stat. A Character's sheet lines
reach fight.py as one technique ("character"), which is exactly how expand_library() treats a technique's passives.

Writes tests/parity/compile/compile_cases.json: {cases: [{name, input, build, unmodelled}]}, input being what the
Godot compiler takes (its sheet lines under "modifiers"), build the resolved Build (dataclasses.asdict) and
unmodelled what fight.py reports it does not run.

Run:
  python -I tools/design/combat_sim/compile_parity_export.py           write the cases
  python -I tools/design/combat_sim/compile_parity_export.py --check   compare; exit 1 on drift
"""
import copy
import dataclasses
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fight as F  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.join(ROOT, "tests", "parity", "compile", "compile_cases.json")
ITEMS_PER_CASE = 5
# the element names a purity uses, in turn (engine names)
PURITY = [{"fire": 40.0}, {"water": 55.0, "ice": 20.0}, {}, {"metal": 70.0}, {"wood": 30.0, "earth": 30.0},
          {"thunder": 65.0}, {"wind": 45.0}]


def sheet_line_pool():
    """Stat-sheet lines: every mapped key, every folded key, two skipped keys, an unknown key, and scoped lines."""
    pool = [{"key": k, "value": 4.0 + (i % 5)} for i, k in enumerate(sorted(F.PASSIVE_MOD))]
    pool += [{"key": k, "value": 6.0 + (i % 4)} for i, k in enumerate(sorted(F.STATIC))]
    pool += [{"key": "cultivation_speed_pct", "value": 10.0}, {"key": "khi_van", "value": 3.0},
             {"key": "made_up_combat_pct", "value": 5.0}]
    pool += [{"key": "attack_pct", "value": 12.0, "scope": ["fire"]},
             {"key": "crit_chance_pct", "value": 3.5, "scope": ["sword", "phys"]},
             {"key": "evade_pct", "value": 2.0, "scope": ["wind"]},             # a mod read without hit context
             {"key": "stack_effect_pct", "value": 15.0, "scope": ["hoa", "buff"]},
             {"key": "stack_duration_pct", "value": 10.0, "scope": ["sword"]},  # an unscoped read, reported
             {"key": "stack_grant", "value": 1.0, "scope": ["debuff", "thuy"]},
             {"key": "defense_pct", "value": 18.5}, {"key": "ward_efficiency_pct", "value": 12.0},
             {"key": "linh_luc_regen_inc_pct", "value": 25.0}, {"key": "art_cost_pct", "value": 7.0}]
    return pool


def cases():
    lib = json.load(open(os.path.join(ROOT, "assets", "data", "combat_library.json"), encoding="utf-8"))
    items = sorted(lib["items"])
    art_pool = sorted(lib["arts"])
    lines = sheet_line_pool()
    out, used_arts, i = [], set(), 0
    while i * ITEMS_PER_CASE < len(items) or len(used_arts) < len(art_pool):
        r = i % 5
        chunk = items[i * ITEMS_PER_CASE:(i + 1) * ITEMS_PER_CASE]
        slots = lib["constants"]["slots_by_realm"][r]
        arts = []
        for iid in chunk:
            for aid in lib["items"][iid]["arts"]:
                if aid not in arts and len(arts) < slots:
                    arts.append(aid)
        for aid in art_pool:
            if len(arts) >= slots:
                break
            if aid not in used_arts and aid not in arts:
                arts.append(aid)
        used_arts.update(arts)
        mods = [lines[(i * 7 + j) % len(lines)] for j in range(9)]
        base = copy.deepcopy(lib["typical"][r])
        inp = {"name": "case_%02d" % i, "realm": r, "layers": base["layers"], "n_body": base["n_body"],
               "n_qi": base["n_qi"], "ward": base["ward"], "arts": [{"lib": a} for a in arts], "items": chunk,
               "modifiers": mods, "purity": PURITY[i % len(PURITY)]}
        out.append(inp)
        i += 1
    out += tree_cases(lib)
    # Full 3-piece mf-carried-array set case (Formations rule 9: diagram_always compile parity)
    ca_items = ["mf-loom-of-letters-seal", "mf-carried-array-flag", "mf-paid-shield"]
    ca_arts = []
    for iid in ca_items:
        for aid in lib["items"].get(iid, {}).get("arts", []):
            if aid not in ca_arts:
                ca_arts.append(aid)
    ca_base = copy.deepcopy(lib["typical"][2])
    out.append({"name": "set_carried_array", "realm": 2, "layers": ca_base["layers"], "n_body": ca_base["n_body"],
                "n_qi": ca_base["n_qi"], "ward": ca_base["ward"], "arts": [{"lib": a} for a in ca_arts],
                "items": ca_items, "modifiers": [{"key": "attack_pct", "value": 10.0}], "purity": {"earth": 50.0}})
    return out


TREE_PER_CASE = 6


def tree_cases(lib):
    """The Đạo Đồ's Effects (2026-11-20, ADR-0004 decision 3), six to a case by name: a build file's tree_effects with
    its counts, the lines folded here in even cases and left to the sheet in odd ones (tree_lines_on_sheet)."""
    effects = json.load(open(os.path.join(ROOT, "assets", "data", "combat_effects.json"), encoding="utf-8"))["effects"]
    names = sorted(k for k, v in effects.items() if v.get("source") == "Đạo Đồ")
    arts = sorted(lib["arts"])
    swords = [a for a in arts if "sword" in lib["arts"][a].get("tags", [])]
    by_el = {}
    for a in arts:
        by_el.setdefault(lib["arts"][a].get("element", ""), a)
    out = []
    for k in range((len(names) + TREE_PER_CASE - 1) // TREE_PER_CASE):
        r = k % 5
        base = copy.deepcopy(lib["typical"][r])
        slots = lib["constants"]["slots_by_realm"][r]
        pick = [swords[k % len(swords)]] + [by_el[e] for e in ("fire", "water", "earth", "metal", "wood") if e in by_el]
        pick = list(dict.fromkeys(pick))[:max(1, slots - 1)]
        inp = {"name": "tree_%02d" % k, "realm": r, "layers": base["layers"], "n_body": base["n_body"],
               "n_qi": base["n_qi"], "ward": base["ward"], "arts": [{"lib": a} for a in pick], "items": [],
               "modifiers": [{"key": "attack_pct", "value": 10.0}, {"key": "khi_huyet_pct", "value": 12.0}],
               "purity": PURITY[k % len(PURITY)],
               "tree_effects": names[k * TREE_PER_CASE:(k + 1) * TREE_PER_CASE],
               "counts": {"empty_extra_slots": 1 + k % 2, "carried_sword": k % 3, "root_elements": 1 + k % 5}}
        if k % 2:
            inp["tree_lines_on_sheet"] = True
        out.append(inp)
    return out


def compile_case(inp):
    d = copy.deepcopy(inp)
    F._library()
    F._LIB["techs"]["character"] = {"id": "character", "passives": d.pop("modifiers")}
    d["techniques"] = ["character"]
    try:
        exp = F.expand_library(d)
        b = F.to_build(exp, inp["realm"], [], inp["name"])
    except F.BadInput as e:
        return {"name": inp["name"], "input": inp, "refused": str(e)}
    finally:
        F._LIB["techs"].pop("character", None)
    rec = dataclasses.asdict(b)
    if getattr(b, "diagram_always", False):
        rec["diagram_always"] = True
    for late in ("pill", "tech_layers", "meters"):   # fields added later stay out at their default (world-depth Stage 5)
        if rec.get(late) == {}:
            rec.pop(late, None)
    for art in rec.get("arts", []):   # fields added later stay out at their default (world-depth Stage 5: escape)
        for late, dv in (("escape", 0.0), ("movements", []), ("movement_counter", "")):
            if art.get(late) == dv:
                art.pop(late, None)
    return {"name": inp["name"], "input": inp, "build": rec, "unmodelled": exp["unmodelled"]}


def build_all():
    rows = [compile_case(c) for c in cases()]
    return {"schema_version": 1,
            "_doc": "FighterCompiler parity cases, written by tools/design/combat_sim/compile_parity_export.py from "
                    "fight.py's expand_library() and to_build(); do not edit by hand.",
            "cases": rows}


def main(argv):
    text = json.dumps(build_all(), indent=1, ensure_ascii=False) + "\n"
    if "--check" in argv:
        old = open(OUT, encoding="utf-8").read() if os.path.exists(OUT) else None
        same = old == text
        print(("same  " if same else "DRIFT ") + OUT)
        return 0 if same else 1
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    doc = json.loads(text)
    refused = [c for c in doc["cases"] if "refused" in c]
    print("wrote %s: %d cases, %d refused" % (OUT, len(doc["cases"]), len(refused)))
    for c in refused:
        print("  refused", c["name"], c["refused"])
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
