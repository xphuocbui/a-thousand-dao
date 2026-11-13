"""Write the layer-budget jobs (design/builds/engine-v3/_logs/budget-jobs-<n>.json): each over-budget engine-v3 build
brings its `layers` within its realm's budget (user decision 2026-11-13; fight.py LAYER_BUDGET) and is refought.

Run (from the repo root):  python -I tools/design/combat_sim/make_budget_jobs.py
Then, one runner per file: python -I tools/headless/run_jobs.py design/builds/engine-v3/_logs/budget-jobs-<n>.json \\
    design/builds/engine-v3/_logs/budget-run-<n> --model sonnet
"""
import glob
import io
import json
import os
import contextlib
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "design", "combat_sim"))
import fight as F  # noqa: E402

V3 = os.path.join(ROOT, "design", "builds", "engine-v3")
LOGS = os.path.join(V3, "_logs")
RUNNERS = 2
SYSTEM = ("You are running UNATTENDED; AskUserQuestion is unavailable; do not ask anything. You revise one build of a "
          "cultivation game's combat build catalogue so its claimed damage layers fit a budget. You edit only the files "
          "named, keep the build's concept, and write plain English with Hán-Việt in brackets for names.")


def prompt(name, realm, share, budget):
    return f"""Bring the build "{name}" within its layer budget, then refight it.

Files you may edit: design/builds/engine-v3/builds/{name}.fight.json and design/builds/engine-v3/{name}.md.
Write a short report to design/builds/engine-v3/_logs/budget/{name}.md (create it).

The rule (user decision 2026-11-13; tools/design/combat_sim/FIGHT-INPUT.md "Layer budget"): a build file's `layers`
may claim at most a share of the gap between the typical and the top-end enemy's layers, summed over L1-L5. At
{realm} the budget is {budget:.0%}; this build claims {share:.0%}. A build at its budget beats a typical same-realm
enemy in about 10-20 s.

Steps:
1. Read the build file, its guide, and FIGHT-INPUT.md's "Layer budget" and "Library pieces" sections.
2. Work out what the build's own pieces really give each layer: its techniques' passives and items' modifiers already
   run as Effects (do not add them to `layers` again); `layers` should hold only what the Meridian Map and other
   sources the file names give. Lower `layers` until `python -I tools/design/combat_sim/fight.py
   design/builds/engine-v3/builds/{name}.fight.json` prints `layer_budget` (not OVER_BUDGET). Keep the concept: cut the
   layers the concept needs least first.
3. Run the same command with `--matrix` and note the results.
4. Update the guide: replace the old numbers with the new ones, and add a section "## Budget revision (2026-11-13)"
   saying what changed in `layers`, why, and how the fights moved (old -> new mean time and wins against typical and
   top-end, same realm).
5. Write the report: the claimed share before and after, the layer values before and after, the fight results before
   and after, and anything the build now lacks to stay strong (pieces it would want from the catalogue).

Do not change any other file. Do not change techniques, items or arts in the build except to remove one whose only
role was to justify the over-budget layers, and say so in the report."""


def main():
    over = []
    for path in sorted(glob.glob(os.path.join(V3, "builds", "*.fight.json"))):
        d = json.load(open(path, encoding="utf-8"))
        r = F.realm_index(d.get("realm", 0))
        with contextlib.redirect_stdout(io.StringIO()):
            share = F.layer_budget(d, r)
        if share is not None and share > F.LAYER_BUDGET[r] + 1e-9:
            over.append((os.path.basename(path)[:-11], F.REALMS[r], share, F.LAYER_BUDGET[r]))
    os.makedirs(os.path.join(LOGS, "budget"), exist_ok=True)
    def allowed(name):
        return ("Read,Glob,Grep,Bash(python -I tools/design/combat_sim/fight.py *),"
                "Edit(design/builds/engine-v3/builds/%s.fight.json),Edit(design/builds/engine-v3/%s.md),"
                "Write(design/builds/engine-v3/_logs/budget/%s.md)" % (name, name, name))
    for n in range(RUNNERS):
        jobs = [{"id": "budget-%s" % name, "prompt": prompt(name, realm, share, budget), "system": SYSTEM,
                 "allowed": allowed(name), "expect": "design/builds/engine-v3/_logs/budget/%s.md" % name}
                for i, (name, realm, share, budget) in enumerate(over) if i % RUNNERS == n]
        out = os.path.join(LOGS, "budget-jobs-%d.json" % n)
        json.dump(jobs, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
        print("wrote %s (%d jobs)" % (os.path.relpath(out, ROOT), len(jobs)))
    for name, realm, share, budget in over:
        print("  %-24s %-10s claims %3.0f%%, budget %2.0f%%" % (name, realm, 100 * share, 100 * budget))


if __name__ == "__main__":
    main()
