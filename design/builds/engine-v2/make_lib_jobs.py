"""Write the library rebuild jobs (lib-jobs-0..3.json): each old build rebuilt from design/arts and design/techniques.

Run: python -I design/builds/engine-v2/make_lib_jobs.py   then launch with tools/headless/run_jobs.py (see README.md)
"""
import json
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
SYSTEM = ("You are running UNATTENDED; AskUserQuestion is unavailable; do not ask anything. You rebuild one "
          "cultivation-game build from the game's art library and technique catalogue and fight it on the combat "
          "engine. You never edit the library, the catalogue, the old build files or any other file; you write only "
          "the fight files named and one results file. Observations, not verdicts.")


def builds():
    out = []
    for k in range(3):
        for j in json.load(open(os.path.join(HERE, "jobs-%d.json" % k), encoding="utf-8")):
            bid = j["id"][len("engine-v2-"):]
            guide = re.search(r"Read: the guide (\S+);", j["prompt"]).group(1)
            fights = re.search(r"every existing fight file (\S+?)\.?\s", j["prompt"]).group(1)
            out.append((bid, guide, fights))
    return out


def job(bid, guide, fights):
    fdir = "design/builds/engine-v2/builds"
    main = "%s/%s.fight.json" % (fdir, bid)
    md = "design/builds/engine-v2/%s.md" % bid
    prompt = (
        "Rebuild the build `%s` from the art library and the technique catalogue, then fight it on combat engine v2 "
        "(run through fight.py).\n\n" % bid +
        "Read, and nothing else: the guide %s; the old fight files %s (Glob them); the build-file format "
        "tools/design/combat_sim/FIGHT-INPUT.md; design/arts/INDEX.md (every technique, signature art and common art on one line). For one "
        "library art's full mechanic, Grep its id in design/arts/family-*.md.\n\n" % (guide, fights) +
        "Rules:\n"
        "1. Keep the build's concept, realm, root (`purity`), layers, crit, ward, body, keystones, curses and every "
        "piece that does not come from an art or a technique: Effects from Đạo, items, the tree or keystones stay "
        "as they are.\n"
        "2. Techniques (`\"techniques\": [ids]`): one main method (tech_kind main) and up to two auxiliary techniques "
        "(secret or body), from the catalogue. Each must be usable by the root: every id it names must be an element "
        "the build has purity in (hoa fire, thuy water, tho earth, kim metal, moc wood, bang ice, loi thunder, phong "
        "wind); a body technique is always usable. Instead of one catalogue technique you may keep a generated "
        "common technique (not listed in `techniques`); it brings exactly one common art.\n"
        "3. Arts: every art is `{\"lib\": \"<id>\"}` with no overrides, and is either carried by a chosen technique "
        "at an unlock layer the realm allows (layer <= 3 at luyen_khi, 6 at truc_co, 9 at ket_dan, 12 at "
        "nguyen_anh) or the one common art of a generated common technique. Use no more arts than fight.py's slots "
        "allow (slots_by_realm + bonus_slots).\n"
        "4. Remove the old invented arts and any effects, counters or states that belonged only to them. Pick the "
        "techniques and arts that best serve the build's concept, preferring a whole suite whose engine the rest of "
        "the build feeds. Where an old identity piece was an invented art with no library equivalent, take the "
        "closest library art or suite and record the loss.\n"
        "5. Never tune a number. Never edit the library, the catalogue or the old files.\n\n"
        "Write %s for the build's defining realm, and %s/%s.<realm>.fight.json for each other realm the old build had "
        "a fight file for (same choices, the arts the realm unlocks).\n\n" % (main, fdir, bid) +
        "Run `python tools/design/combat_sim/fight.py %s --matrix`, then the same with "
        "`--without tech:<the main technique id>`, then with `--without <the build's identity piece>` (an art id or "
        "an effect id). Run each other realm file once without --matrix.\n\n" % main +
        "Write %s: the build's name and concept in one line; a table | Old piece | Library piece | Technique "
        "(layer) |; the techniques chosen and why; what was lost in the move; a table | Matchup | Mean s | W-L-other "
        "| You dry | Foe dry | Clipped |; the two --without tests (same-realm typical, before and after); the "
        "UNMODELLED lines, one each with why; one paragraph of observations: fight length against the 30-60 s band "
        "at the same realm, whether the guide's claims still hold, NEVER_FIRED arts.\n"
        "End your final message with: LIB-DONE %s" % (md, md))
    allowed = ",".join(["Read", "Glob", "Grep", "Bash(python tools/design/combat_sim/fight.py *)",
                        "Write(%s/%s.fight.json)" % (fdir, bid), "Write(%s/%s.*.fight.json)" % (fdir, bid),
                        "Edit(%s/%s.fight.json)" % (fdir, bid), "Edit(%s/%s.*.fight.json)" % (fdir, bid),
                        "Write(%s)" % md, "Edit(%s)" % md])
    return {"id": "lib-%s" % bid, "prompt": prompt, "system": SYSTEM, "allowed": allowed, "expect": md}


def main():
    jobs = [job(*b) for b in builds()]
    os.makedirs(os.path.join(HERE, "builds"), exist_ok=True)
    for k in range(4):
        with open(os.path.join(HERE, "lib-jobs-%d.json" % k), "w", encoding="utf-8") as f:
            json.dump(jobs[k::4], f, indent=1, ensure_ascii=False)
    print(len(jobs), "jobs")


if __name__ == "__main__":
    main()
