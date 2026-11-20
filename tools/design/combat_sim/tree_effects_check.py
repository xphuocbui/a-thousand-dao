"""Does each Đạo Đồ Effect do something in a fight? (2026-11-20; ADR-0004 decision 3.)

For every Effect of source "Đạo Đồ" in assets/data/combat_effects.json, fights a Deity Transformation build that holds
it against the typical enemy, and the same build without it, on the same seeds, and reports the Effects whose fights
come out identical on every seed (a no-op in this kit) beside the ones that change something. The kit is chosen to
give every rule its trigger: Burn, Poison, Ice and Water/Wood buff arts, Metal, Earth, sword, slow Thunder, slow and
talisman arts, evade, crit and block. Observations only: a no-op may be right (its trigger is absent from the kit).

Run: python tools/design/combat_sim/tree_effects_check.py [--seeds 12]
"""
import copy
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import engine  # noqa: E402
import fight as F  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
REALM = 4
KIT = ["ember-rain", "blight-canker", "ice-hoarfrost-prick", "brimming-cup", "bark-mantle", "blade-sword-rain",
       "aftershock-slam"]
EXTRA_KITS = {"slow": ["rolling-thunder", "anchor-drop", "ambush-talisman"], "companion": ["flying-sword"]}


def base_file(arts):
    lib = json.load(open(os.path.join(ROOT, "assets", "data", "combat_library.json"), encoding="utf-8"))
    d = copy.deepcopy(lib["typical"][REALM])
    d["name"] = "tree-check"
    d["arts"] = [{"lib": a} for a in arts]
    d["evade_pct"] = 15
    d["body"] = {"shield": 0.15}
    d["counts"] = {"empty_extra_slots": 2, "carried_sword": 2, "root_elements": 3}
    d["purity"] = {"fire": 60, "water": 60, "wood": 60, "metal": 60, "earth": 60, "ice": 60}
    return d


def fights(d, enemy, seeds):
    exp = F.expand_library(copy.deepcopy(d))
    b = F.to_build(exp, REALM, [], "tree-check")
    out = []
    for s in range(seeds):
        r = engine.fight(b, enemy, seed=s)
        out.append((r["t"], r["win"], round(r["A"].hp, 6), round(r["B"].hp, 6), round(r["A"].dealt, 6)))
    return out


def main():
    seeds = int(sys.argv[sys.argv.index("--seeds") + 1]) if "--seeds" in sys.argv else 12
    lib = json.load(open(os.path.join(ROOT, "assets", "data", "combat_effects.json"), encoding="utf-8"))["effects"]
    names = sorted(k for k, v in lib.items() if v.get("source") == "Đạo Đồ")
    enemy = F.to_build(F.enemy_file("typical", REALM), REALM, [], "enemy")
    rows = []
    for name in names:
        e = lib[name]
        if e.get("not_run"):
            rows.append((name, "Pending (not run)", ""))
            continue
        kit = KIT
        rule = e.get("rule", "")
        if "slow" in rule.lower() or "talisman" in rule.lower():
            kit = KIT[:4] + EXTRA_KITS["slow"]
        if "companion" in rule.lower():
            kit = KIT[:6] + EXTRA_KITS["companion"]
        base = base_file(kit)
        with_ = dict(base, tree_effects=[name])
        a, b = fights(with_, enemy, seeds), fights(base, enemy, seeds)
        changed = sum(1 for x, y in zip(a, b) if x != y)
        wins = (sum(1 for x in a if x[1] == "A"), sum(1 for x in b if x[1] == "A"))
        rows.append((name, "NO CHANGE" if not changed else "changes %d/%d seeds" % (changed, seeds),
                     "wins %d vs %d without" % wins))
    for r in rows:
        print("%-28s %-22s %s" % r)
    print("no change: %s" % ", ".join(r[0] for r in rows if r[1] == "NO CHANGE"))


if __name__ == "__main__":
    main()
