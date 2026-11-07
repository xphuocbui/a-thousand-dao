#!/usr/bin/env python3
"""fight_x.py: the committed fight_calc.py plus this campaign's rule plug-ins.

Takes the same arguments as fight_calc.py. A fight file may list "rules": ["name", ...];
each loads rules/name.py from the campaign folder and calls its install(f), which
wraps functions in the calculator (f.strike, f.apply_ward, f.pulse, f.resolve_art,
f.fire_triggers, f.apply_status, f.guard_true, f.layer_points). The committed
calculator is never changed, and a run with no rules is exactly fight_calc.py.

Rule files live here only, not in the skill, because they model proposals, not
rules of the game. `--without name` also skips a plug-in, so an identity test
works on a rule-bender. Every plug-in must act only for a side whose spec asks for
it, because the enemy runs through the same functions.
"""
import importlib.util
import json
import os
import sys

sys.dont_write_bytecode = True
HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
REPO = os.path.dirname(os.path.dirname(os.path.dirname(ROOT)))
sys.path.insert(0, os.path.join(REPO, ".claude", "skills", "design-build", "scripts"))
import fight_calc as f  # noqa: E402


def main():
    argv = sys.argv[1:]
    build_paths = [a for a in argv if a.endswith(".json")]
    names = []
    for p in build_paths:
        with open(p, encoding="utf-8") as h:
            names += json.load(h).get("rules", [])
    out, skip, i = [], set(), 0
    while i < len(argv):
        if argv[i] == "--without" and i + 1 < len(argv) and argv[i + 1] in names:
            skip.add(argv[i + 1])
            i += 2
            continue
        out.append(argv[i])
        i += 1
    for name in names:
        if name in skip:
            print("without\t%s" % name)
            continue
        path = os.path.join(ROOT, "rules", name + ".py")
        if not os.path.exists(path):
            print("RULE_MISSING\t%s" % name)
            continue
        spec = importlib.util.spec_from_file_location("rule_" + name, path)
        mod = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(mod)
        mod.install(f)
        print("rule\t%s" % name)
    sys.argv = [sys.argv[0]] + out
    return f.main()


if __name__ == "__main__":
    sys.exit(main())
