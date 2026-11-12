"""Write the gearing jobs (gear-jobs-0..3.json): each engine-v2 build gets a full item loadout and is refought.

Run (from the repo root): python -I design/builds/engine-v3/make_gear_jobs.py
Then, one runner per file: python -I tools/headless/run_jobs.py design/builds/engine-v3/gear-jobs-<n>.json \
    design/builds/engine-v3/_logs/gear-run-<n> --model sonnet
"""
import glob
import json
import os

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
V2 = os.path.join(ROOT, "design", "builds", "engine-v2")
SYSTEM = ("You are running UNATTENDED; AskUserQuestion is unavailable; do not ask anything. You gear one "
          "cultivation-game build with named items from the item catalogue and fight it on the combat engine. You "
          "never edit the item catalogue, the library, the engine-v2 files or any other file; you write only the "
          "fight file and the guide named. Observations, not verdicts. Names are English with the Hán-Việt in brackets.")
EXTRAS = {"luyen_khi": 2, "truc_co": 3, "ket_dan": 4, "nguyen_anh": 5, "hoa_than": 6}
GRADE_CAP = {"luyen_khi": 2, "truc_co": 3, "ket_dan": 4, "nguyen_anh": 4, "hoa_than": 4}


def builds():
    out = []
    for md in sorted(glob.glob(os.path.join(V2, "*.md"))):
        bid = os.path.basename(md)[:-3]
        fight = os.path.join(V2, "builds", bid + ".fight.json")
        if bid.isupper() or not os.path.exists(fight):
            continue
        realm = json.load(open(fight, encoding="utf-8")).get("realm")
        out.append((bid, realm))
    return out


def job(bid, realm):
    old = "design/builds/engine-v2/builds/%s.fight.json" % bid
    new = "design/builds/engine-v3/builds/%s.fight.json" % bid
    md = "design/builds/engine-v3/%s.md" % bid
    prompt = f"""Gear the build `{bid}` with named items and fight it again.

Read, and nothing else: the build's guide design/builds/engine-v2/{bid}.md; its fight file {old}; the build-file
format tools/design/combat_sim/FIGHT-INPUT.md (note `"items"` and library arts `{{"lib": id}}`); the item rules in
design/items/README.md; the item index design/items/INDEX.md. For an item's full record, Grep its id in
design/items/catalogue-*.json and read that record only.

The loadout (design/gdd/item-database.md rule 11; the build's realm is {realm}):
1. Base slots, no thần thức cost: 1 weapon, 1 armour (a body_gear piece), 2 rings, 1 necklace.
2. Extra slots: up to {EXTRAS.get(realm, 3)} more pieces of any kind. Their base thần thức costs (the TT column) may add up
   to at most 45 × the build's `divine_sense` (1.0 when absent) × (1 + the build's total than_thuc_pct / 100).
   Leave slots empty rather than break this.
3. Grade at most {GRADE_CAP.get(realm, 4)} at this realm. Unique items (grade 4) only at ket_dan and above.
4. Choose the items that best serve the build's concept and engine: its family first, then any family. An item's
   arts are library arts: slot one with `{{"lib": "<art id>"}}` in place of a weaker art (art slots stay as fight.py
   counts them). A ward from an item: if it beats the build's ward, model it as the nearest drain ward in `ward`.

Write {new}: a copy of the old file with `"items": [ids]`, any item arts swapped in, and every item Effect the build
relies on written as an engine Effect in `effects` with id "eff:<English name>" (the engine format is in
FIGHT-INPUT.md; if the engine cannot express it, leave it, and it is listed as UNMODELLED). Keep everything else, and
never tune a number.

Run `python tools/design/combat_sim/fight.py {old} --matrix`, then `python tools/design/combat_sim/fight.py {new} --matrix`,
then `python tools/design/combat_sim/fight.py {new} --without item:<the item that matters most>` (and, if the build relies on
an item Effect, `--without eff:<its name>`).

Write {md}, a guide for a player:
- the build's name and concept in one line, and its realm;
- **Loadout**: a table | Slot | Item | Grade | Why it is here | (base slots, then extras with their thần thức, and the total
  against the limit);
- **Before and after**: a table | Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |, and the
  --without results;
- **Upgrades to look for**: a table | Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or
  missing | Priority |;
- **Missing pieces**: items the build wanted that the catalogue does not have, one line each (what, and which family
  should own it);
- the UNMODELLED lines, one each with why;
- one paragraph of observations: did gear matter, is the fight still inside 30-60 s, did any item make the build
  degenerate, which items fired nothing.

End your final message with: GEAR-DONE {bid}
"""
    allowed = ",".join(["Read", "Glob", "Grep", "Bash(python tools/design/combat_sim/fight.py *)",
                        "Write(%s)" % new, "Edit(%s)" % new, "Write(%s)" % md, "Edit(%s)" % md])
    return {"id": "gear-%s" % bid, "prompt": prompt, "system": SYSTEM, "allowed": allowed, "expect": md}


def main():
    jobs = [job(*b) for b in builds()]
    os.makedirs(os.path.join(HERE, "builds"), exist_ok=True)
    os.makedirs(os.path.join(HERE, "_logs"), exist_ok=True)
    for k in range(4):
        with open(os.path.join(HERE, "gear-jobs-%d.json" % k), "w", encoding="utf-8") as f:
            json.dump(jobs[k::4], f, indent=1, ensure_ascii=False)
    print(len(jobs), "jobs:", ", ".join("%s (%s)" % b for b in builds()))


if __name__ == "__main__":
    main()
