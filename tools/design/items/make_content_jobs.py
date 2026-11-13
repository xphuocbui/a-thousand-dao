"""Write the content-ask jobs (design/items/_logs/content-jobs-<n>.json): techniques and items the engine-v3 builds asked
for that the first patch could not place (design/items/_logs/patch/not-items.md).

Run (from the repo root): python -I tools/design/items/make_content_jobs.py
Then: python -I tools/headless/run_jobs.py design/items/_logs/content-jobs-<n>.json design/items/_logs/content-run-<n> --model sonnet
"""
import json
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
LOGS = os.path.join(ROOT, "design", "items", "_logs")
SYS_T = ("You are running UNATTENDED; AskUserQuestion is unavailable; do not ask anything. You add techniques (công pháp) to "
         "an existing family of a cultivation game's technique catalogue. You append only: you never change or remove an "
         "existing technique, and you edit only the files named. Names are English with the Hán-Việt in brackets.")
SYS_I = ("You are running UNATTENDED; AskUserQuestion is unavailable; do not ask anything. You add named items to an "
         "existing family of a cultivation game's item catalogue, answering what playtested builds asked for. You append "
         "only: you never change or remove an existing item, and you edit only the file named. Names are English with the "
         "Hán-Việt in brackets.")


def tech_job(fam, what):
    js, md = "design/techniques/catalogue-%s.json" % fam, "design/techniques/catalogue-%s.md" % fam
    prompt = f"""Add technique(s) to the {fam} family of the technique catalogue.

What to add (asked for by playtested builds):
{what}

Read, and nothing else: design/techniques/README.md; {js} and {md} (the family's techniques: copy their format and style
exactly; do not change them); the docstring and PRICE / TIER tables of tools/design/arts/lint_techniques.py (its first 75
lines); design/arts/INDEX.md (every art on one line; Grep an art id in design/arts/family-*.md for its full mechanic); the
`tiers` and `bonus_pool` entries of assets/data/items_cong_phap.json (Grep '"bonus_pool"').

Append the new technique record(s) to the JSON list in {js}, following design/gdd/cong-phap.md as the existing records do:
every field the others have, `origin` "authored", `effects` [], `suite` "" unless it carries a whole suite, abilities that
are existing library arts (art ids from design/arts) unlocking by layer 6 where they belong to a suite, `names` the element
ids of its elemental arts (a main method names its element; hon_don is Chaos), passives spending 85-100 % of the tier's W
budget and feeding the arts' engines, `bonuses` exactly the tier's bonus_count lines from bonus_pool. Then append a section
for each to {md} in the style of the others. Run `python -I tools/design/arts/lint_techniques.py {js}` and fix until it
reports 0 findings (the whole-catalogue checks are skipped on one file; that note is expected).

End your final message with: CONTENT-DONE {fam}
"""
    allowed = "Read,Glob,Grep,Edit(%s),Edit(%s),Bash(python -I tools/design/arts/lint_techniques.py %s)" % (js, md, js)
    return {"id": "content-tech-" + fam, "prompt": prompt, "system": SYS_T, "allowed": allowed}


def item_job(fam, what, n):
    js = "design/items/catalogue-%s.json" % fam
    prompt = f"""Append {n} named item(s) to the {fam} family of the item catalogue.

What to add (asked for by playtested builds):
{what}

Read, and nothing else: {js} (the family's items: do not change them; match their format and style); design/items/README.md;
design/items/_logs/brief.md (budgets, priced keys, scopes, Effects, starter wards); design/items/bases.md.

Each new item follows every catalogue rule: a unique id starting with "{fam}-"; grade 1-3 (repeatable); plain modifiers
spending 80-100 % of the grade budget (the lint limit is 1.05 x budget); the rule 21 blueprint (a ring, necklace or utility
piece gives an Effect or modifiers and optionally one reserve art; armour or ward gear one ward); `notes` saying which ask it
answers; a ward is a starter drain ward (Common Ward all 342.5 points, drain 0.328, standing; Qi-Scattering Robe Force 220
points, drain 0.264; Fire-Shunning Veil Fire 300 points, drain 0.22) with payload and drain scaled by one factor, typed where
it fits; prefer Effects already in effects.md, at most 1 new one. Run `python -I tools/design/items/lint_items.py {js}` and fix
your new items until it reports 0 findings. Never edit existing records.

End your final message with: CONTENT-DONE {fam}
"""
    allowed = "Read,Glob,Grep,Edit(%s),Bash(python -I tools/design/items/lint_items.py %s)" % (js, js)
    return {"id": "content-items-" + fam, "prompt": prompt, "system": SYS_I, "allowed": allowed}


def main():
    jobs = [
        tech_job("force-chaos",
                 "1. A Chaos main method (tech_kind main, naming hon_don): today every Chaos technique is a secret, so a Chaos "
                 "build's main method has to come from another element (unique-chaos-last-bargain-locket).\n"
                 "2. A 'Hundred Arts Sage' method (Bách Pháp Hiền): a multi-element hub technique naming several element ids "
                 "(up to 3), whose passives reward holding stacks of many elements, so Chaos-scoped (hon_don) pieces have a "
                 "home (unique-chaos-primordial-mirror)."),
        tech_job("blade",
                 "A second slow-engine sword technique at a high tier (tier 2 or 3), main or secret, naming kim: the Sword "
                 "Hall build banks Afterimages and Coils slowly and has only the Afterimage Sword Canon to carry it "
                 "(unique-unbroken-edge-ring). Its passives should feed counters that bank (Afterimage, Coil) and slow, heavy "
                 "sword arts."),
        item_job("metal",
                 "1. A Metal ring or necklace with `art_speed_pct` [kim] (ninth-bell: a Metal art-speed piece).\n"
                 "2. A Metal piece that lays Earth debuff stacks for an Earth-and-Metal build (deity-warden: Closing Palm and "
                 "its 3 Metal debuff stacks; a Metal Earth-stack engine piece).", 2),
        item_job("soul-song-seal",
                 "A ward piece (armour or ward gear) for builds facing soul-heavy foes: soul resistance as modifiers "
                 "(`soul_res_pct`) and a standing drain ward the combat sim can run (soul-lance).", 1),
    ]
    for k in range(2):
        json.dump(jobs[k::2], open(os.path.join(LOGS, "content-jobs-%d.json" % k), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(len(jobs), "jobs:", ", ".join(j["id"] for j in jobs))


if __name__ == "__main__":
    main()
