"""Write the catalogue patch jobs (patch-jobs-0..3.json): each family appends items that answer what the engine-v3 builds
asked it for (design/items/_logs/patch/asks-<family>.md).

Run (from the repo root): python -I tools/design/items/make_patch_jobs.py
Then, one runner per file: python -I tools/headless/run_jobs.py design/items/_logs/patch-jobs-<n>.json \
    design/items/_logs/patch-run-<n> --model sonnet
"""
import json
import os
import re

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
LOGS = os.path.join(ROOT, "design", "items", "_logs")
FAMILIES = ["blade", "body", "earth", "fire", "force-chaos", "general", "ice", "metal", "soul-song-seal", "thunder",
            "water", "wind", "wood"]
SYSTEM = ("You are running UNATTENDED; AskUserQuestion is unavailable; do not ask anything. You add named items to an "
          "existing family of a cultivation game's item catalogue, answering what playtested builds asked for. You append "
          "only: you never change or remove an existing item, and you edit only the file named. Names are English with "
          "the Hán-Việt in brackets.")


def prompt(fam, n_asks, n_new):
    return f"""Patch the {fam} family of the item catalogue: append {n_new} new item(s) that answer what the builds asked for.

Read, and nothing else:
- design/items/_logs/patch/asks-{fam}.md ({n_asks} asks from playtested builds; each names the build that asked);
- design/items/catalogue-{fam}.json (the family's current 10 items: do not change them; match their format and style);
- design/items/README.md (the rules and decisions); design/items/_logs/brief.md (budgets, priced keys, scopes, Effects,
  starter wards); design/items/bases.md (bases, thần thức costs);
- design/items/catalogue-fire.json only if you need another example.

Append exactly {n_new} item record(s) to the end of the JSON list in design/items/catalogue-{fam}.json. Each must:
1. answer at least one ask, and say which in `notes` ("Answers: <build>: <ask, short>"); pick the asks that most builds
   share or that matter most to a build's identity;
2. follow every catalogue rule: a unique id starting with "{fam}-" and not yet used; grade 1-4 by what the ask needs
   (prefer repeatable grades 1-3; grade 4 is unique, never crafted, and needs a `holder`); plain modifiers spending
   80-100 % of the grade budget (60 % for a strong-enabler item, with a note); the rule 21 blueprint (a weapon gives one
   attack art, armour or ward gear one ward, a ring, necklace or utility piece an Effect or modifiers and optionally one
   reserve art); art ids unique and starting with "{fam}-";
3. armour or ward gear asked for "a ward the engine can run" or "a drain ward" gets a **standing drain ward**: a starter
   drain ward (Common Ward: all 342.5 points, drain 0.328, standing; Fire-Shunning Veil: Fire 300 points, drain 0.22;
   Qi-Scattering Robe: Force 220 points, drain 0.264) with payload and drain scaled by the same factor, typed to the
   family where it fits, `check_from` the starter ward, a note with the factor;
4. a "cheap extra" uses a base of 10 thần thức or less (Nhẫn 8, Ngọc Bội 10, Châm 10, Tiền Tiêu 8, Hương Lô 10, Đạo Bào 6,
   Giáp 5); "more thần thức" means a `than_thuc_pct` modifier;
5. new Effects: at most 2 in this patch, each {{"new": true, "id", "name", "group", "tier", "rule", "reads", "payload",
   "closes", "hosts", "from"}}, a closing cost on an enabler; prefer Effects already in effects.md (the brief lists them).

Run `python -I tools/design/items/lint_items.py design/items/catalogue-{fam}.json` and fix your new items until it reports
0 findings. Never edit the first 10 records.

End your final message with: PATCH-DONE {fam}
"""


def main():
    jobs = []
    for fam in FAMILIES:
        asks = open(os.path.join(LOGS, "patch", "asks-%s.md" % fam), encoding="utf-8").read()
        n_asks = len(re.findall(r"^- ", asks, re.M))
        if not n_asks:
            continue
        n_new = max(1, min(5, round(n_asks / 3)))
        out = "design/items/catalogue-%s.json" % fam
        jobs.append({"id": "patch-" + fam, "prompt": prompt(fam, n_asks, n_new), "system": SYSTEM,
                     "allowed": "Read,Glob,Grep,Edit(%s),Bash(python -I tools/design/items/lint_items.py %s)" % (out, out),
                     "n_new": n_new})
    for k in range(4):
        part = jobs[k::4]
        json.dump(part, open(os.path.join(LOGS, "patch-jobs-%d.json" % k), "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(len(jobs), "jobs,", sum(j["n_new"] for j in jobs), "new items:", ", ".join("%s %d" % (j["id"][6:], j["n_new"]) for j in jobs))


if __name__ == "__main__":
    main()
