"""Write the readable pages of the named-item catalogue from its JSON.

Run (from the repo root): python -I tools/design/items/make_md.py
Writes design/items/catalogue-<family>.md for every catalogue-<family>.json, and design/items/bases.md.
The JSON is the source; never edit the .md by hand.
"""
import glob
import importlib.util
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
ITEMS = os.path.join(ROOT, "design", "items")
spec = importlib.util.spec_from_file_location("lint_items", os.path.join(os.path.dirname(__file__), "lint_items.py"))
L = importlib.util.module_from_spec(spec)
spec.loader.exec_module(L)

GRADE = {1: "Hạ (Low)", 2: "Trung (Middle)", 3: "Thượng (High)", 4: "Cực (Peak)"}
RANK = {2: "Hạ", 3: "Trung", 4: "Thượng", 5: "Cực"}
SLOT = {"weapon": "weapon slot", "body_gear": "armour slot", "ring": "ring slot", "necklace": "necklace slot",
        "ward_gear": "extra slot (ward gear)", "utility": "extra slot (utility)"}
SRC = {"event": "events and secret realms", "npc": "NPC holders", "quest": "quest and sect rewards", "craft": "crafting"}


def fmt_mod(m, stats_w, names):
    scope = m.get("scope") or []
    v = m["value"]
    unit = " points" if m["key"] == "resist_pct" else (" %" if m["key"].endswith("_pct") else "")
    label = names.get(m["key"], m["key"])
    w, _ = L.modifiers_w([m], stats_w, "-", [])
    return "%s%s%s %s%s · %.1f W" % ("+" if v > 0 else "", v, unit, label, (" [" + ", ".join(scope) + "]") if scope else "", w)


def main():
    gd = L.cat.build()
    stats_w = {s["key"]: s["w"] for s in gd["stats"] if s.get("w") is not None}
    names = {}
    for s_ in gd["stats"]:
        names.setdefault(s_["key"], s_["name"].lower())   # the first Stat List row names a key
    effs = {L.re.sub(r"\s*\(.*$", "", e["name"]).strip().lower(): e for e in gd["effects"]}
    bases = {b["id"]: b for b in json.load(open(os.path.join(ITEMS, "bases.json"), encoding="utf-8"))}
    common = {a["id"]: a for a in json.load(open(os.path.join(ITEMS, "common-arts.json"), encoding="utf-8"))}
    wa = L.w_affix(stats_w)

    # bases.md
    out = ["# Artifact bases", "",
           "> Generated from `bases.json` by `tools/design/items/make_md.py`; edit the JSON. Rules: `design/gdd/item-database.md`",
           "> rules 6, 11 and 21, Formulas D and E. **Built** bases are in game data; **new** ones join the rolled pool when the",
           "> catalogue goes into data.", "",
           "| Base | Roles | Attack / defence | Value | Weight | Damage | Gives when rolled | Status |",
           "|---|---|---|---|---|---|---|---|"]
    for b in bases.values():
        if b.get("common_art"):
            a = common[b["common_art"]]
            gives = "attack art: %s (c %.2f, cost %.3f, %g s)" % (a["name"], a["c_art"], a["cost_share"], a["cooldown"])
        elif b.get("common_ward"):
            gives = "ward: %s (starter ward)" % b["common_ward"]
        else:
            gives = "modifiers only"
        out.append("| **%s** (%s) | %s | %g / %g | %d | %d | %s | %s | %s |" % (
            b["name"], b["english"], ", ".join(b["roles"]), b["attack"], b["defense"], b["base_value"],
            b["weight"], b["damage_type"], gives, b["status"]))
    out += ["", "**Notes**", ""] + ["- **%s**: %s" % (b["name"], b["notes"]) for b in bases.values() if b.get("notes")]
    out += ["", "Common arts are in `common-arts.json` (art records, linted by `tools/design/arts/lint_arts.py`). Common wards",
            "are the starter wards of `design/gdd/combat-defence.md` Formulas H, already price-checked."]
    open(os.path.join(ITEMS, "bases.md"), "w", encoding="utf-8").write("\n".join(out) + "\n")

    for f in sorted(glob.glob(os.path.join(ITEMS, "catalogue-*.json"))):
        fam = os.path.basename(f)[len("catalogue-"):-5]
        items = json.load(open(f, encoding="utf-8"))
        o = ["# Named items: %s" % fam.replace("-", " ").title(), "",
             "> Generated from `%s` by `tools/design/items/make_md.py`; edit the JSON. Rules: `design/gdd/item-database.md`" % os.path.basename(f),
             "> rules 11, 20, 21 and Formulas I. Budget per grade: %.1f W per affix the grade allows (lint passes up to ×%.2f)."
             % (wa, L.NAMED_W_TOLERANCE), "",
             "| Item | Base · slot | Grade (rarity) | Gives | Plain W |", "|---|---|---|---|---|"]
        for it in items:
            b = bases[it["base"]]
            g = it.get("grade") or (it.get("rarity", 4) - 1)
            r = g + 1 if it["kind"] == "artifact" else it["rarity"]
            gives = []
            if it.get("arts"):
                gives.append("art: " + ", ".join(a["name"].split(" (")[0] for a in it["arts"]))
            if it.get("wards"):
                gives.append("ward: " + ", ".join(w["name"].split(" (")[0] for w in it["wards"]))
            for e in it.get("effects", []):
                gives.append(("Effect: %s" % (e["name"].split(" (")[0] + " (new)")) if isinstance(e, dict) else "Effect: " + e)
            if it.get("reserve_arts"):
                gives.append("reserve: " + ", ".join(x["name"].split(" (")[0] for x in it["reserve_arts"]))
            w, _ = L.modifiers_w(it["modifiers"], stats_w, "-", [])
            o.append("| **%s**%s | %s · %s | %s (%d%s) | %s | %.1f of %.1f |" % (
                it["name"], " *(exception)*" if it.get("exception") else "", b["name"], SLOT[b["roles"][0]], GRADE[g], r,
                ", unique" if r >= L.UNIQUE_RARITY_MIN else "", "; ".join(gives) or "modifiers only", w, L.AFFIX_COUNT[g] * wa))
        for it in items:
            b = bases[it["base"]]
            g = it.get("grade") or (it.get("rarity", 4) - 1)
            r = g + 1 if it["kind"] == "artifact" else it["rarity"]
            o += ["", "## %s" % it["name"], "",
                  "*%s (%s), %s · grade %s, rarity %d%s · from %s*" % (b["name"], b["english"], SLOT[b["roles"][0]], GRADE[g], r,
                                                                     ", **unique**" if r >= L.UNIQUE_RARITY_MIN else ", repeatable",
                                                                     ", ".join(SRC[s] for s in it["sources"])), ""]
            if it.get("lore"):
                o += ["> " + it["lore"], ""]
            o += ["**Build use.** " + it["build_use"], ""]
            if it.get("exception"):
                o += ["**Exception to the rule 21 blueprint:** " + it["exception"], ""]
            for a in it.get("arts", []):
                o += ["**Art: %s** (%s, %s, c %.2f, cost %.3f, cooldown %g s). %s" % (
                    a["name"], a["role"], a.get("power", "standalone"), a["c_art"], a["cost_share"], a["cooldown"], a["rule"]), ""]
            for wd in it.get("wards", []):
                o += ["**Ward: %s**: %s; %s; %s. Price check from %s. %s" % (
                    wd["name"], wd["payload"], wd["payment"], wd["activation"], wd["check_from"], wd.get("notes", "")), ""]
            for e in it.get("effects", []):
                if isinstance(e, dict):
                    o += ["**Effect (new): %s** (%s, %s). %s *Payload:* %s.%s" % (
                        e["name"], e.get("group", ""), e.get("tier", ""), e["rule"], e["payload"],
                        (" *Closes:* " + e["closes"]) if e.get("closes") else ""), ""]
                else:
                    ref = effs.get(e.strip().lower())
                    o += ["**Effect: %s** (effects.md). %s" % (e, ref["rule"] if ref else ""), ""]
            for x in it.get("reserve_arts", []):
                o += ["**Reserve art: %s** (reserves %d %% of maximum linh lực). %s" % (x["name"], round(x["reserve"] * 100), x["rule"]), ""]
            if it["modifiers"]:
                o += ["**Modifiers:** " + "; ".join(fmt_mod(m, stats_w, names) for m in it["modifiers"]), ""]
            if it.get("holder"):
                o += ["**Placed at world start:** " + it["holder"], ""]
        open(f[:-5] + ".md", "w", encoding="utf-8").write("\n".join(o) + "\n")
        print("wrote", os.path.relpath(f[:-5] + ".md", ROOT))
    print("wrote design/items/bases.md")
    # INDEX.md: one line per item, for build sessions picking a loadout
    idx = ["# Named-item index", "",
           "> Generated by `tools/design/items/make_md.py`. One line per item; the full record is in `catalogue-<family>.json`",
           "> (Grep its id). Grade cap by realm (Formulas F): Qi Refining 2, Foundation Establishment 3, Core Formation and up 4.",
           "> Unique items are grade 4. Slot: the base slot it fits (any piece also fits a free extra slot).", "",
           "| Item id | Family | Base (slot) | Grade | Gives | For |", "|---|---|---|---|---|---|"]
    for f in sorted(glob.glob(os.path.join(ITEMS, "catalogue-*.json"))):
        for it in json.load(open(f, encoding="utf-8")):
            b = bases[it["base"]]
            g = it.get("grade") or (it.get("rarity", 4) - 1)
            gives = ["art " + a["id"] for a in it.get("arts", [])] + ["ward " + w["name"].split(" (")[0] for w in it.get("wards", [])]
            gives += ["Effect " + (e if isinstance(e, str) else e["name"].split(" (")[0] + " (new)") for e in it.get("effects", [])]
            gives += ["reserve %d %%" % round(100 * x["reserve"]) for x in it.get("reserve_arts", [])]
            idx.append("| `%s` | %s | %s (%s) | %d%s | %s | %s |" % (
                it["id"], it["family"], b["name"], SLOT[b["roles"][0]].replace(" slot", ""), g, " unique" if g == 4 else "",
                "; ".join(gives) or "modifiers", it["build_use"].split(":")[0][:70]))
    open(os.path.join(ITEMS, "INDEX.md"), "w", encoding="utf-8").write("\n".join(idx) + "\n")
    print("wrote design/items/INDEX.md")


if __name__ == "__main__":
    main()
