"""Write the headless job files for the 12 remaining named-item families (design/items/_logs/item-jobs-<n>.json).

Run (from the repo root): python -I tools/design/items/make_jobs.py
Then, one runner per file: python -I tools/headless/run_jobs.py design/items/_logs/item-jobs-<n>.json design/items/_logs/item-run-<n> --model sonnet
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
LOGS = os.path.join(ROOT, "design", "items", "_logs")

FAMILIES = {
    # family: (element ids its arts use, build sheets to look at, bases that fit, extra hint)
    "water": ("thuy", ["single-water.md"], "", ""),
    "earth": ("tho", ["single-earth.md"], "Mao (anchor) suits a lock tool", ""),
    "metal": ("kim", ["single-metal.md"], "Tiền Tiêu (coin), Phủ (axe)", "Whetstone Vow and Blood on the Whetstone ideas live in single-metal.md."),
    "wood": ("moc", ["single-wood.md"], "Phủ (axe) for the Woodcutter", "Grave-Silk Shroud (effects.md, Named Item) fits a poison piece."),
    "ice": ("bang", ["variant-ice.md"], "", ""),
    "thunder": ("loi", ["variant-thunder.md"], "Cổ (drum), Lôi Trượng (lightning rod)", ""),
    "wind": ("phong", ["variant-wind.md"], "Phiến (fan), Châm (needle)", ""),
    "blade": ("kim (sword arts)", ["single-metal.md"], "Phi Kiếm (flying sword) above all", "Sword cultivators wear several flying swords in extra slots; make that a build."),
    "body": ("none: element-less body arts", [], "Giáp (armour), Thuẫn (shield), Phủ (axe)", "Thể tu (body cultivators): block, body shields, health. Grep design/builds/by-root/ for 'thể tu' and read one sheet."),
    "force-chaos": ("hon_don, am (chaos, darkness)", ["variant-chaos.md", "variant-darkness.md"], "Lạc Thiết (branding iron), Kính (mirror)", ""),
    "soul-song-seal": ("soul arts, music, seals", ["triple-metal-water-wood.md", "triple-wood-fire-earth.md"], "Cầm (zither), Hương Lô (censer), Ấn (seal)", ""),
    "general": ("none: serves any build", ["five-elements.md"], "any",
                "No arts family: these items serve every build: fortune (khi_van), escape, cultivation speed, thần thức, "
                "`artifact_slots` (an item that adds an extra slot is a classic), talismans (Paid in Advance, Talisman Sleeve), "
                "spirit stones (Seal of Full Payment), and the build catalogue's Five-Phase Flag (a named Kỳ: five element "
                "slots), Star Chart and Soul Jade (treasures; a treasure has `kind` treasure and `rarity` 4-5 instead of a "
                "grade). Weapons here carry element-less arts."),
}

SYSTEM = ("You are running UNATTENDED; AskUserQuestion is unavailable; do not ask anything. You author named items "
          "(magic treasures, armour, rings, necklaces) for a cultivation game whose builds are the game, Path of Exile "
          "style: every item should be something a build hunts for. You edit only the file named. Names are English "
          "with the Hán-Việt name in brackets, e.g. 'Ember Fan (Tàn Hỏa Phiến)'.")


def prompt(fam, els, sheets, bases, hint):
    arts = ("- design/arts/family-%s.json and design/arts/family-%s.md (the family's arts: their suites (`group`), "
            "counters, states and the reads their engines use);\n" % (fam, fam)) if fam != "general" else ""
    sheet = "".join("- design/builds/by-root/%s (the builds; what they want from items);\n" % s for s in sheets)
    return f"""Author the named items of the {fam} family for the item catalogue.

Read, and nothing else:
- design/items/README.md (the shape, the record and the decisions);
- design/items/catalogue-fire.json, the approved pilot: copy its record format, its depth and its style exactly;
- design/items/_logs/brief.md (budgets, priced modifier keys, scope tags, the Effects you may use, starter wards);
- design/items/bases.md (the bases and what each gives);
- design/gdd/item-database.md rules 20 and 21 (Grep '^20\\. \\*\\*Named items' and '^### States and Transitions', read between);
{arts}{sheet}- the 'Items, wards and formations' table of design/builds/by-root/missing-pieces.md (Grep '^## Items, wards', read 30 lines).

Write design/items/catalogue-{fam}.json: a JSON list of exactly 10 item records, family "{fam}". Element ids: {els}.

What to make:
1. Grades: 2 at grade 1, 3 at grade 2, 3 at grade 3, 2 at grade 4. Grade 4 items are unique: their sources never include
   "craft", and each has a `holder` line (who holds it at world start, or where it lies Lost).
2. Slots, at least: 2 weapons (one attack art each), 2 armour or ward gear (one ward each), 2 rings or necklaces, 1 utility
   treasure for the extra slots. Choose bases that fit the family ({bases or "any that fit"}).
3. What each gives follows rule 21: a weapon gives one attack art; armour and ward gear one ward; rings, necklaces and
   utility an Effect or modifiers only, and optionally one reserve art. Any named item may also carry an Effect. Break
   this only with an `exception` reason, at most once in the family.
4. Arts are art records like the pilot's (fields as in design/arts). Give each a globally unique id starting with
   "{fam}-". Build them on the family's engines: read the family's counters, states and reads and hook into them. At
   least one item art should join one of the family's suites by naming it as its `group` (allowed on named items).
   Strong payoffs must be gated (steps with unlock, or empower with if), as the family's own engine arts are.
5. Wards are scaled starter wards: payload and payment multiplied by the same factor, same payment model and activation,
   `check_from` the starter ward's name, and a note saying the factor.
6. Reserve arts: `reserve` 0.05-0.90; their `grants` modifiers cost at most 1 W per percentage point reserved.
7. Plain modifiers: keys and scopes from the brief, spending 80-100 % of the grade's budget (an item whose main value is
   a strong enabler may go to 60 % and says so in `notes`). Feed the family's engine: its stacks, statuses, costs, art
   speed, wards, heals.
8. Effects: prefer Effects already in effects.md (the brief lists them; use only those whose Hosts include Item, or
   Named Item). At most 3 new Effects in the family, each {{"new": true, "id", "name", "group", "tier", "rule", "reads",
   "payload", "closes", "hosts", "from"}}; give a new enabler a closing cost. Grade 1 items carry no Effect.
9. `build_use` names the build (from the build sheets, or a new one in a few words) and says what the item does for it.
   `lore` is one sentence. {hint}

Run `python -I tools/design/items/lint_items.py design/items/catalogue-{fam}.json` and fix until it reports 0 findings.
The `spend` and `reserve` lines are notes; keep every spend at or above its target.

End your final message with: ITEMS-DONE {fam}
"""


def main():
    os.makedirs(LOGS, exist_ok=True)
    jobs = []
    for fam, (els, sheets, bases, hint) in FAMILIES.items():
        out = "design/items/catalogue-%s.json" % fam
        jobs.append({"id": "items-" + fam, "prompt": prompt(fam, els, sheets, bases, hint), "system": SYSTEM,
                     "allowed": "Read,Glob,Grep,Write(%s),Edit(%s),Bash(python -I tools/design/items/lint_items.py %s)" % (out, out, out),
                     "expect": out})
    for n in range(4):
        part = jobs[n::4]
        json.dump(part, open(os.path.join(LOGS, "item-jobs-%d.json" % n), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        print("item-jobs-%d.json:" % n, ", ".join(j["id"] for j in part))


if __name__ == "__main__":
    main()
