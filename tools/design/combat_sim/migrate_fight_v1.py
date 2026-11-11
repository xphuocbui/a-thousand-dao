"""migrate_fight_v1.py: converts a build fight file written for the retired fight_calc.py (format v1, before
#44 and the ward and body layers) to the format .claude/skills/design-build/scripts/fight.py reads.

What carries over mechanically: realm, layers, crit, pools, art speed and cost, evade, accuracy, each art's
coefficient, cooldown, cost and per-art layer points. Everything else (curses, guards, applied statuses, soul
arts, triggers, auras, conditional modifiers, the old ward shape, body guard) has no field in the new format,
so it moves into "unmodelled" by name, and the file says what it was. An art with no damage coefficient (a
soul art) is dropped from the arts and listed there too.

Choices the old format cannot answer, stated in each file's _comment:
  - art kind: v1 "qi" becomes "elem", "body" becomes "phys"; no element is guessed, so no element stacks
  - cost_share: files from before #44 (--pre44) are halved, as #44 halved costs and doubled the lint's price
    per cost, which leaves each art's coefficient legal; later files keep their shares
  - ward: a v1 drain ward keeps its ws as ws_base and its we; its layers are the realm's typical ones, or every
    layer at cap for a top-end build (--top-end), because the ward layers did not exist when it was designed

Usage: python -I tools/design/combat_sim/migrate_fight_v1.py OLD.json NEW.json [--pre44] [--top-end]
"""
import argparse
import json
import re

KIND = {"qi": "elem", "body": "phys"}
COPY = {"name": "name", "realm": "realm", "layers": "layers", "crit": "crit", "n_body": "n_body", "n_qi": "n_qi",
        "art_speed_pct": "art_speed_pct", "art_cost_pct": "art_cost_pct", "evade_pct": "evade_pct",
        "accuracy_pct": "accuracy_pct", "enemy": "enemy"}
DROP_SILENT = {"_doc", "_note", "unmodelled", "ward", "arts", "stage", "start_qi"}


def describe(v):
    return json.dumps(v, ensure_ascii=False, separators=(", ", ": "))


def migrate(d, pre44, top_end):
    out = {}
    un = []
    for k, v in d.items():
        if k in COPY:
            if k == "enemy" and v not in ("typical", "top_end"):
                un.append("v1 enemy %s" % describe(v))
                continue
            out[COPY[k]] = v
        elif k == "regen_bonus_pct":
            if v > 0:
                out["regen_bonus_pp"] = v
            elif v < 0:
                un.append("v1 regen_bonus_pct %s (a regeneration penalty; #44 regeneration is 3.5 %% a pulse with no "
                          "negative bonus, so it is left out)" % v)
        elif k == "basic":
            if v.get("c", 1.0) != 1.0 or v.get("kind", "body") != "body":
                un.append("v1 basic attack %s (the basic attack is always coefficient 1.0, Physical)" % describe(v))
        elif k == "stage" and v != 1.0:
            un.append("v1 stage %s (the simulator runs at stage 1.00)" % v)
        elif k == "start_qi" and v != 1.0:
            un.append("v1 start_qi %s (fights start at full linh luc)" % v)
        elif k not in DROP_SILENT:
            un.append("v1 %s %s" % (k, describe(v)))
    w = d.get("ward", {})
    model = w.get("model", "drain")
    ward = {}
    if model == "drain":
        ward = {"ws_base": w.get("ws", 30.8), "we": w.get("we", w.get("ws", 30.8))}
        if top_end:
            ward["layers"] = [300, 235, 150, 100]
        if "pass" in w or "drain" in w:
            un.append("v1 ward shape %s (pass and drain shares are retired; modelled as the Common Ward at this "
                      "ws and we%s)" % (describe({k: w[k] for k in ("pass", "drain") if k in w}),
                                        ", every ward layer at cap" if top_end else ", typical ward layers"))
    elif model in ("default", "off"):
        ward = {"model": model}
    else:
        ward = {"ws_base": w.get("ws", 30.8)}
        un.append("v1 ward model %s %s (modelled as the closest drain ward)" % (model, describe(w)))
    out["ward"] = ward
    arts = []
    for a in d.get("arts", []):
        aid = a.get("id")
        if a.get("kind") not in KIND or "c_art" not in a:
            un.append("v1 art %s dropped: %s" % (aid, describe(a)))
            continue
        cost = a.get("cost_share", 0.05)
        na = {"id": aid, "c_art": a["c_art"], "cost_share": round(cost / 2, 4) if pre44 else cost,
              "cooldown": a.get("cooldown", 3), "kind": KIND[a["kind"]]}
        if "x" in a:
            na["x"] = a["x"]
        for k, v in a.items():
            if k not in ("id", "kind", "c_art", "cost_share", "cooldown", "x"):
                un.append("v1 art %s %s %s" % (aid, k, describe(v)))
        arts.append(na)
    out["arts"] = arts
    out.setdefault("layers", [26.5, 40, 40, 20, 10])
    out["unmodelled"] = [str(u) for u in d.get("unmodelled", [])] + un
    note = d.get("_doc") or d.get("_note")
    out["_comment"] = ("Migrated from fight_calc.py format v1 by tools/design/combat_sim/migrate_fight_v1.py "
                       "(2026-11-11). Art kinds: qi -> elem, body -> phys, no element stacks. Costs %s. Ward: v1 ws "
                       "and we kept, %s. Everything with no new field is in unmodelled, prefixed v1."
                       % ("halved (pre-#44 file)" if pre44 else "kept (post-#44 file)",
                          "every ward layer at cap (top-end build)" if top_end else "typical ward layers"))
    if note:
        out["unmodelled"].insert(0, "v1 note: " + note)
    return out


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("old")
    ap.add_argument("new")
    ap.add_argument("--pre44", action="store_true")
    ap.add_argument("--top-end", action="store_true")
    a = ap.parse_args()
    with open(a.old, encoding="utf-8") as f:
        d = json.load(f)
    out = migrate(d, a.pre44, a.top_end)
    with open(a.new, "w", encoding="utf-8") as f:
        text = json.dumps(out, ensure_ascii=False, indent=2)
        # keep short number lists on one line: [300, 235, 150, 100]
        text = re.sub(r"\[\s*(-?[\d.]+(?:,\s*-?[\d.]+)*)\s*\]",
                      lambda m: "[" + ", ".join(x.strip() for x in m.group(1).split(",")) + "]", text)
        f.write(text + "\n")
    print("migrated\t%s -> %s\tarts %d\tunmodelled %d" % (a.old, a.new, len(out["arts"]), len(out["unmodelled"])))


if __name__ == "__main__":
    main()
