"""Suite check: arts from the library in a typical build, against the typical foe, on the combat engine.

Emits observations, not a verdict. For each family file it runs:
- each suite (the arts sharing a `group`) as the whole art loadout of an otherwise typical build;
- each standalone art (no group) added to the typical kit in place of its first art.
Both fight the typical foe of the same realm (Trúc Cơ and Kết Đan by default), over fixed seeds, and print the mean
fight length, the win-loss split, and how often each engine art's steps and empowers fired per fight.

A typical build should land in the 30-60 s band (Combat #44 item A1). A suite far below it is stronger than a
typical build with nothing else built; a step or empower that never fires is an engine nobody can turn on.

Run: python -I tools/design/arts/suite_check.py [family files...]   (default design/arts/family-*.json)
"""
import copy
import glob
import json
import os
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, ".claude", "skills", "design-build", "scripts"))
sys.argv = sys.argv[:1] + [a for a in sys.argv[1:]]
import fight  # noqa: E402
import engine  # noqa: E402

KEEP = {"c_art", "cost_share", "cooldown", "element", "kind", "buff", "debuff", "c_heal", "qi_restore", "cleanse",
        "tags", "guards", "statuses", "split", "soul_pct", "soul_part", "bypass", "pool", "convert", "hp_cost",
        "charges", "group", "steps", "empower"}
REALMS = (1, 2)
SEEDS = 20


def as_fight_art(a):
    x = {k: v for k, v in a.items() if k in KEEP}
    x["id"] = a["id"]
    return x


def build_with(arts, r, replace_kit):
    d = copy.deepcopy(fight.enemy_file("typical", r))
    fa = [as_fight_art(a) for a in arts]
    d["arts"] = fa + d["arts"][len(fa):] if replace_kit else fa
    d["effects"] = [e for a in arts for e in a.get("effects", [])]
    seen, cnt = set(), []
    for a in arts:
        for c in a.get("counters", []):
            if c["id"] not in seen:
                seen.add(c["id"])
                cnt.append(c)
    d["counters"] = cnt
    d["states"] = [s for a in arts for s in a.get("states", [])]
    d["name"] = "+".join(a["id"] for a in arts)
    return d


def run(d, r):
    A = fight.to_build(d, r, [], "build")
    B = fight.to_build(fight.enemy_file("typical", r), r, [], "enemy")
    counts = {}
    orig = engine.Fight.fire_event

    def spy(self, s, name, ev):
        if s.label == "A" and name in ("step_unlocked", "empowered"):
            k = "%s %s%s" % (ev.get("art_id"), "step " if name == "step_unlocked" else "empower",
                             ev.get("step", "") if name == "step_unlocked" else "")
            counts[k] = counts.get(k, 0) + 1
        return orig(self, s, name, ev)
    engine.Fight.fire_event = spy
    try:
        res = [engine.fight(A, B, seed=s) for s in range(SEEDS)]
    finally:
        engine.Fight.fire_event = orig
    t = sum(x["t"] for x in res) / SEEDS
    w = sum(x["win"] == "A" for x in res)
    lo = sum(x["win"] == "B" for x in res)
    return t, w, lo, {k: v / SEEDS for k, v in counts.items()}


MIRROR = {}


def mirror(r):
    if r not in MIRROR:
        A = fight.to_build(fight.enemy_file("typical", r), r, [], "a")
        B = fight.to_build(fight.enemy_file("typical", r), r, [], "b")
        MIRROR[r] = sum(engine.fight(A, B, seed=s)["t"] for s in range(SEEDS)) / SEEDS
    return MIRROR[r]


def main():
    files = sys.argv[1:] or sorted(glob.glob(os.path.join(ROOT, "design", "arts", "family-*.json")))
    if not files:
        print("NO_INPUT\tno family files")
        return 2
    n = 0
    for f in files:
        arts = json.load(open(f, encoding="utf-8"))
        fam = os.path.basename(f)[7:-5]
        groups = {}
        for a in arts:
            if a.get("group"):
                groups.setdefault(a["group"], []).append(a)
        units = [("suite " + g, g_arts, False) for g, g_arts in groups.items()]
        units += [("art " + a["id"], [a], True) for a in arts if not a.get("group")]
        for label, ua, replace in units:
            for r in REALMS:
                try:
                    t, w, lo, c = run(build_with(ua, r, replace), r)
                except (fight.BadInput, engine.EngineError) as e:
                    print("ERROR\t%s\t%s\t%s" % (fam, label, e))
                    continue
                n += 1
                m = mirror(r)
                pace = "FAST" if t < 0.6 * m else "slow" if t > 1.6 * m else "near typical"
                print("suite_check\t%s\t%s\t%s\tmean %.1f s, typical mirror %.1f s, x%.2f (%s)\tW-L %d-%d"
                      % (fam, label, fight.REALMS[r], t, m, t / m, pace, w, lo))
                for k, v in sorted(c.items()):
                    print("engine\t%s\t%s\t%s\t%s\t%.1f per fight" % (fam, label, fight.REALMS[r], k, v))
                for a in ua:
                    if a.get("power") == "engine" and not any(k.startswith(a["id"] + " ") for k in c):
                        print("NEVER_ENGAGED\t%s\t%s\t%s\t%s: no step or empower fired" % (fam, label, fight.REALMS[r], a["id"]))
    print("checked %d runs" % n)
    return 0


if __name__ == "__main__":
    sys.exit(main())
