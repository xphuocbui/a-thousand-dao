"""Export the reference fighters to game data (ADR-0001 decision 2: "an enemy without a Character ... is a profile built
from data").

fight.py defines the reference enemies (enemy_file: typical, top_end, top_end_the_tu) from GDD-checked constants and
compiles them with to_build(). This writes each one, at every realm, as a fully resolved engine Build to
assets/data/combat_reference_fighters.json, which the game's FighterCompiler.from_data() loads through
FighterProfileLoader. One source: the design tool computes them, the game reads them, and --check reports drift.

Run:
  python -I tools/design/combat_sim/export_reference_fighters.py           write the file
  python -I tools/design/combat_sim/export_reference_fighters.py --check   compare with the file; exit 1 on drift
"""
import dataclasses
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import fight as F  # noqa: E402

OUT = os.path.normpath(os.path.join(HERE, "..", "..", "..", "assets", "data", "combat_reference_fighters.json"))
KINDS = ("typical", "top_end", "top_end_the_tu")


def build_all():
    out = {"schema_version": 1,
           "_doc": "Reference fighters by kind and realm (0-4), as fully resolved engine Builds. Written by "
                   "tools/design/combat_sim/export_reference_fighters.py from fight.py's enemy_file() and to_build(); "
                   "do not edit by hand. Read by FighterCompiler.from_data() (ADR-0001 decision 2).",
           "fighters": {}}
    for kind in KINDS:
        rows = []
        for r in range(5):
            notes = []
            b = F.to_build(dict(F.enemy_file(kind, r)), r, notes, kind)
            rec = dataclasses.asdict(b)
            rec["name"] = "%s-r%d" % (kind, r)
            rows.append(rec)
        out["fighters"][kind] = rows
    return out


def dumps(doc):
    return json.dumps(doc, indent=1, ensure_ascii=False) + "\n"


def main(argv):
    text = dumps(build_all())
    if "--check" in argv:
        old = open(OUT, encoding="utf-8").read() if os.path.exists(OUT) else None
        same = old == text
        print(("same  " if same else "DRIFT ") + OUT)
        return 0 if same else 1
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print("wrote " + OUT)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
