"""Write the unique-item build jobs (unique-jobs-0..2.json): one new build around each unique named item that no
geared engine-v2 build picked up.

Run (from the repo root): python -I design/builds/engine-v3/make_unique_jobs.py
Then, one runner per file: python -I tools/headless/run_jobs.py design/builds/engine-v3/unique-jobs-<n>.json \
    design/builds/engine-v3/_logs/unique-run-<n> --model sonnet
"""
import collections
import glob
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
SYSTEM = ("You are running UNATTENDED; AskUserQuestion is unavailable; do not ask anything. You design one new "
          "cultivation-game build around a unique named item, from the game's art library, technique catalogue and "
          "item catalogue, and fight it on the combat engine. You never edit the library or the catalogues; you write "
          "only the fight file and the guide named. Observations, not verdicts. Names are English with the Hán-Việt "
          "in brackets.")
EXTRAS = {"ket_dan": 4, "nguyen_anh": 5}


def unused_uniques():
    used = collections.Counter()
    for fp in glob.glob(os.path.join(HERE, "builds", "*.fight.json")):
        used.update(json.load(open(fp, encoding="utf-8")).get("items", []))
    out = []
    for f in sorted(glob.glob(os.path.join(ROOT, "design", "items", "catalogue-*.json"))):
        for it in json.load(open(f, encoding="utf-8")):
            if (it.get("grade") == 4 or it.get("rarity") == 5) and not used[it["id"]]:
                out.append(it)
    return out


def job(it):
    slug = "unique-" + it["id"].split("-", 1)[1] if it["family"] != "soul-song-seal" else "unique-" + it["id"]
    fight = "design/builds/engine-v3/builds/%s.fight.json" % slug
    md = "design/builds/engine-v3/%s.md" % slug
    prompt = f"""Design a new build around the unique item `{it['id']}` ({it['name']}), then fight it.

Its catalogue line: {it['build_use']}

Read, and nothing else: the item's record (Grep `"id": "{it['id']}"` in design/items/catalogue-{it['family']}.json and read
that record); the build-file format tools/design/combat_sim/FIGHT-INPUT.md (note `"items"`, `"techniques"` and
library arts `{{"lib": id}}`); design/arts/INDEX.md (every technique and art on one line; Grep an art id in
design/arts/family-*.md for its full mechanic); the item index design/items/INDEX.md (Grep an item id in
design/items/catalogue-*.json for its record); one engine-v3 guide for the format, design/builds/engine-v3/starter-blade.md.

The build:
1. Realm ket_dan (Core Formation), or nguyen_anh if the item's engine needs more slots. A root (`purity`) that fits.
2. Techniques: one main method and up to two auxiliary techniques from the catalogue whose element ids the root has
   (a body technique is always usable); arts are `{{"lib": id}}` the techniques unlock at the realm (layer <= 9 at
   ket_dan, 12 at nguyen_anh), plus the unique item's art if it has one, within fight.py's art slots.
3. Items (design/gdd/item-database.md rule 11): the unique item, then 1 weapon, 1 armour, 2 rings, 1 necklace in the base
   slots (no thần thức), and up to {EXTRAS['ket_dan']} (ket_dan) or {EXTRAS['nguyen_anh']} (nguyen_anh) extra pieces whose base thần thức
   costs (INDEX TT column) add up to at most 45 × (1 + the build's total than_thuc_pct / 100). Grade at most 4.
4. Write the unique item's Effect, and any other Effect the build relies on, as engine Effects in `effects` with id
   "eff:<English name>" (FIGHT-INPUT.md); what the engine cannot express goes in `unmodelled`.
5. Keep layers, crit, ward and body at the typical anchor unless the build's pieces change them; never tune a number to
   make it win.

Write {fight}. Run `python tools/design/combat_sim/fight.py {fight} --matrix`, then `--without item:{it['id']}`, then
`--without eff:<the unique's Effect name>` if it has one, then `--without tech:<the main technique id>`.

Write {md}, a guide for a player:
- the build's name (English and Hán-Việt), its concept in one line, realm and root;
- **How it works**: 4-6 lines on the engine and what the unique item does in it;
- **Loadout**: | Slot | Item | Grade | Why | (thần thức total against the limit); the techniques and arts;
- **Fights**: | Matchup | Mean s | W-L-other | You dry | Foe dry |, and the --without results (what the unique is worth);
- **Upgrades to look for**: | Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or
  missing | Priority |;
- **Missing pieces**: what the build wanted that the library and catalogues do not have, one line each, with the family
  or system that should own it;
- the UNMODELLED lines, one each with why;
- one paragraph of observations: does the unique make the build (the --without gap), fight length against 30-60 s,
  anything degenerate, anything that never fired.

End your final message with: UNIQUE-DONE {slug}
"""
    allowed = ",".join(["Read", "Glob", "Grep", "Bash(python tools/design/combat_sim/fight.py *)",
                        "Write(%s)" % fight, "Edit(%s)" % fight, "Write(%s)" % md, "Edit(%s)" % md])
    return {"id": slug, "prompt": prompt, "system": SYSTEM, "allowed": allowed, "expect": md}


def main():
    jobs = [job(it) for it in unused_uniques()]
    for k in range(3):
        with open(os.path.join(HERE, "unique-jobs-%d.json" % k), "w", encoding="utf-8") as f:
            json.dump(jobs[k::3], f, indent=1, ensure_ascii=False)
    print(len(jobs), "jobs:", ", ".join(j["id"] for j in jobs))


if __name__ == "__main__":
    main()
