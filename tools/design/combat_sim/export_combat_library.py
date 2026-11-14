"""Export the combat library to game data: every authored art, each named item's combat record, the typical fighter
as a build file per realm, and the fight.py constants a Character's fighter needs (ADR-0001 step 3; user decisions
2026-11-14: all arts and parsed wards exported, typical layers until the Meridian Map returns).

fight.py stays the source: its library (_library), ward parser (parse_ward), reference enemies (enemy_file) and GDD-
checked constants (C) are read here and written to assets/data/combat_library.json, which the game's FighterCompiler
reads. --check reports drift.

What is written:
  arts       every art fight.py's library resolves (family arts, the part arts, design/items/common-arts.json, item
             arts; fight.py's precedence), as library forms: the build-file art fields, its effects, counters and
             states, and id, name, rule and source for the game.
  items      per named item: the first role of its base, its modifiers (with scope), Effects by name, art ids, wards
             parsed by parse_ward() (unscaled, with what is not run), and reserve arts with their grants.
  typical    the typical fighter's build file at each realm (enemy_file("typical", r)): a Character's base until the
             Meridian Map gives it layers of its own.
  constants  the fight.py constants the compiler reads.

Run:
  python -I tools/design/combat_sim/export_combat_library.py           write the file
  python -I tools/design/combat_sim/export_combat_library.py --check   compare with the file; exit 1 on drift
"""
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import dataclasses  # noqa: E402
import engine  # noqa: E402
import fight as F  # noqa: E402
import sim  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
OUT = os.path.join(ROOT, "assets", "data", "combat_library.json")
# The fight.py constants a Character's fighter is compiled with (fight.py CONST, GDD-checked by check_constants)
CONST_KEYS = ("typical_ws", "typical_block", "w_ref", "drain_44", "default_ward", "common_ward", "layer_caps",
              "l1_soft", "defence_layer_caps", "crit_chance_cap", "crit_mult_cap", "slots_by_realm",
              "ward_slots_by_realm", "ward_slot_sense_step")


def _art_record(a, source):
    rec = {k: a[k] for k in sorted(a) if k in F.LIB_ART_KEYS}
    rec["id"] = a["id"]
    rec["name"] = a.get("name", a["id"])
    rec["rule"] = a.get("rule", "")
    rec["source"] = source
    for k in ("effects", "counters", "states"):
        if a.get(k):
            rec[k] = a[k]
    return rec


def common_wards():
    """The Combat Defence & Healing ward table (Formulas H), name -> its row, read as fight.py's parse_ward reads
    a ward: payload, and payment with activation."""
    path = os.path.join(ROOT, "design", "gdd", "combat-defence.md")
    rows, on = {}, False
    for line in open(path, encoding="utf-8"):
        if line.startswith("| Ward | Payload | Payment, activation |"):
            on = True
            continue
        if on:
            if not line.startswith("|"):
                break
            cells = [c.strip() for c in line.strip().strip("|").split("|")]
            if cells[0].startswith("---"):
                continue
            rows[cells[0]] = {"name": cells[0], "payload": cells[1], "payment": cells[2], "activation": cells[2]}
    return rows


def bases_record(bases):
    """Item Database rule 21: a rolled weapon gives its base's common attack art, a rolled armour or ward gear piece
    its base's common ward (parsed here, unscaled, as an item's ward)."""
    table = common_wards()
    out = {}
    for bid in sorted(bases):
        b = bases[bid]
        ward = None
        if b.get("common_ward"):
            row = table.get(b["common_ward"])
            if row is None:
                raise SystemExit("bases.json %s: common ward %r is not in the combat-defence.md ward table" % (bid, b["common_ward"]))
            fields, skip = F.parse_ward(dict(row, id=b["common_ward"]))
            ward = {"id": b["common_ward"], "name": b["common_ward"], "fields": fields, "not_run": skip}
        out[bid] = {"roles": list(b.get("roles", [])), "common_art": b.get("common_art") or "", "common_ward": ward}
    return out


def build_all():
    arts_lib, _techs = F._library()
    items, bases = F._LIB["items"], F._LIB["bases"]
    sources = {}
    for f in sorted(glob.glob(os.path.join(ROOT, "design", "arts", "family-*.json"))):
        for a in json.load(open(f, encoding="utf-8")):
            sources.setdefault(a["id"], "family")
    for f in sorted(glob.glob(os.path.join(ROOT, "design", "arts", "part-*.json"))):
        for a in json.load(open(f, encoding="utf-8")):
            sources.setdefault(a["id"], "part_" + str(a.get("tier", "")))
    common = os.path.join(ROOT, "design", "items", "common-arts.json")
    for a in json.load(open(common, encoding="utf-8")):
        sources.setdefault(a["id"], "common_arts")
    for it in items.values():
        for a in it.get("arts", []):
            sources.setdefault(a["id"], "item")
    arts = {aid: _art_record(a, sources.get(aid, "item")) for aid, a in arts_lib.items()}
    out_items = {}
    for iid in sorted(items):
        it = items[iid]
        roles = bases.get(it.get("base"), {}).get("roles") or []
        wards = []
        for w in it.get("wards", []):
            fields, skip = F.parse_ward(w)
            wards.append({"id": w.get("id", ""), "name": w.get("name", w.get("id", "ward")), "fields": fields,
                          "not_run": skip})
        out_items[iid] = {
            "name": it.get("name", iid),
            "role": roles[0] if roles else "",
            "modifiers": [{k: m[k] for k in ("key", "value", "scope") if k in m} for m in it.get("modifiers", [])],
            "effects": [e if isinstance(e, str) else e.get("name") for e in it.get("effects", [])],
            "arts": [a["id"] for a in it.get("arts", [])],
            "art_tags": [list(a.get("tags", [])) for a in it.get("arts", [])],
            "wards": wards,
            "reserve_arts": [{k: r[k] for k in ("id", "name", "reserve", "rule", "grants") if k in r}
                             for r in it.get("reserve_arts", [])],
        }
    consts = {k: F.C[k] for k in CONST_KEYS}
    consts["cost_scale"] = sim.K["cost_scale"]
    consts["lib_art_keys"] = sorted(F.LIB_ART_KEYS)
    # literal defaults in fight.py's build-file path (to_build, ward_fields, apply_static, offence_M); the compile
    # parity cases fail if fight.py changes one and this list does not follow
    consts["file_defaults"] = {"crit": [0.15, 1.7], "cost_share": 0.05, "cooldown": 3.0, "n_body": 1.0883,
                               "n_qi": 1.053, "ward_layers": [40, 40, 20, 10], "body_layers": [0, 0, 0, 0],
                               "drain_base": 0.328, "ws_floor": 0.1, "l1_floor": -90.0, "reserved_cap": 0.9}
    # an engine Build as to_build() starts it: sim.Build's defaults through engine.from_sim(), so the compiler fills
    # every field the same way (the fighter records are fully resolved; FighterProfileLoader)
    defaults = dataclasses.asdict(engine.from_sim(sim.Build("default")))
    defaults.pop("name")
    consts["build_defaults"] = defaults
    return {
        "schema_version": 1,
        "_doc": "The combat library (ADR-0001 step 3). Written by tools/design/combat_sim/export_combat_library.py "
                "from fight.py's library, ward parser, reference enemies and constants; do not edit by hand. Read by "
                "FighterCompiler. arts: library forms by id (build-file art fields, effects, counters, states; source "
                "family | part_common | part_authored | common_arts | item). items: named items' combat records "
                "(role = the base's first role; wards parsed and unscaled, fields null when not run). bases: per artifact "
                "base, its roles, common art id and common ward (Item Database rule 21: what a rolled piece gives). "
                "typical: the "
                "typical fighter's build file per realm 0-4. constants: fight.py constants (Combat Formulas B, "
                "Combat Defence & Healing A0-D) the compiler reads; lib_art_keys: the art fields a library art "
                "brings; build_defaults: an engine Build's fields before to_build() sets them; file_defaults: fight.py's literal "
                "defaults for a build file's missing fields.",
        "arts": {k: arts[k] for k in sorted(arts)},
        "items": out_items,
        "typical": [F.enemy_file("typical", r) for r in range(5)],
        "bases": bases_record(bases),
        "constants": consts,
    }


def dumps(doc):
    return json.dumps(doc, indent=1, ensure_ascii=False, sort_keys=False) + "\n"


def main(argv):
    text = dumps(build_all())
    if "--check" in argv:
        old = open(OUT, encoding="utf-8").read() if os.path.exists(OUT) else None
        same = old == text
        print(("same  " if same else "DRIFT ") + OUT)
        return 0 if same else 1
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    doc = json.loads(text)
    print("wrote %s: %d arts, %d items, %d wards" % (OUT, len(doc["arts"]), len(doc["items"]),
                                                    sum(len(i["wards"]) for i in doc["items"].values())))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
