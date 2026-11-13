"""Parity exporter: runs the shared parity fixtures through this engine and writes what the GDScript engine must match.

ADR-0001 (the combat engine in Godot), decision 4: a shared fixture set (tests/parity/fixtures/*.json, two fighters
and a seed) is run by both engines. Chance-free fixtures must match exactly: event by event, final health and linh
luc within 1e-6. This script writes tests/parity/expected/<name>.json for each fixture:

  a, b      the fighters as fully resolved engine Builds (every field, the sim's defaults filled in), so the GDScript
            loader never repeats the sim's defaults; it reads these and refuses any field its slice has not ported
  result    t_ms, win (A, B, draw or time) and each side's end state
  rows      the event rows (Fight.plog): ["pulse", t, side, hp, qi], ["art", t, side, art, cost, hp, qi],
            ["hit", t, attacker, kind, art_id, D, dealt, defender hp, defender qi, attacker hp, attacker qi]

Fixtures run with order="fixed" (side A before side B at the same moment). Both engines' real order is a coin per
moment from the fight's random stream (ADR-0001, amended 2026-11-13); the streams differ, so exact parity needs the
fixed order.

Run:
  python -I tools/design/combat_sim/parity_export.py           write every expected file
  python -I tools/design/combat_sim/parity_export.py --check   compare with the files on disk; exit 1 on any drift
Exit codes: 0 ok; 1 drift or a non-deterministic fixture; 2 bad fixture.
"""
import dataclasses
import glob
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import engine as E  # noqa: E402

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
FIXTURES = os.path.join(ROOT, "tests", "parity", "fixtures")
EXPECTED = os.path.join(ROOT, "tests", "parity", "expected")
# Fields that would make a fixture chancy (a roll that can go either way); a chance-free fixture must leave them off.
CHANCY_BUILD = ("crit", "evade")


class FixtureError(Exception):
    pass


def to_build(d, where):
    d = dict(d)
    try:
        d["arts"] = [E.Art(**a) for a in d.get("arts", [])]
        if d.get("shields"):
            d["shields"] = [E.Shield(**s) for s in d["shields"]]
        return E.Build(**d)
    except TypeError as e:
        raise FixtureError("%s: %s" % (where, e))


def check_chance_free(fx, b, where):
    for k in CHANCY_BUILD:
        if getattr(b, k):
            raise FixtureError("%s: chance_free, but %s is %s" % (where, k, getattr(b, k)))
    for e in b.effects:
        if "chance" in e:
            raise FixtureError("%s: chance_free, but Effect %s has a chance" % (where, e.get("id")))
    for a in b.arts:
        if a.statuses:
            raise FixtureError("%s: chance_free, but art %s applies statuses" % (where, a.name))


def end_state(s):
    return dict(hp=s.hp, qi=s.qi, hp_max=s.hp_max, qi_base=s.qi_base, dealt=s.dealt, spent=s.spent, fat=s.fat,
                healed=s.healed, ward_paid=s.ward_paid, fired=list(s.fired), down=s.down)


def run_fixture(path):
    with open(path, encoding="utf-8") as f:
        fx = json.load(f)
    name = fx.get("name") or os.path.splitext(os.path.basename(path))[0]
    a = to_build(fx["a"], name + ".a")
    b = to_build(fx["b"], name + ".b")
    if fx.get("chance_free"):
        check_chance_free(fx, a, name + ".a")
        check_chance_free(fx, b, name + ".b")
    out = None
    for _ in range(2):                      # the same fixture twice: the sim itself must be deterministic
        f = E.Fight(a, b, seed=int(fx.get("seed", 1)), order="fixed", parity=True)
        res = f.run()
        doc = dict(
            fixture=name, slice=fx.get("slice"), chance_free=bool(fx.get("chance_free")), seed=int(fx.get("seed", 1)),
            generated_by="tools/design/combat_sim/parity_export.py (order=fixed)",
            a=dataclasses.asdict(a), b=dataclasses.asdict(b),
            result=dict(t_ms=f.t, win=res["win"], A=end_state(res["A"]), B=end_state(res["B"])),
            rows=res["plog"],
        )
        if out is not None and dumps(out) != dumps(doc):
            raise FixtureError("%s: two runs of the same fixture differ" % name)
        out = doc
    return name, out


def dumps(doc):
    """JSON with one event row per line (readable diffs); floats as repr, so they round-trip exactly."""
    rows = doc["rows"]
    head = dict(doc)
    head["rows"] = "@ROWS@"
    text = json.dumps(head, indent=1, ensure_ascii=False)
    body = ",\n".join("  " + json.dumps(r, ensure_ascii=False) for r in rows)
    return text.replace('"@ROWS@"', "[\n" + body + "\n ]") + "\n"


def main(argv):
    check = "--check" in argv
    paths = sorted(glob.glob(os.path.join(FIXTURES, "*.json")))
    if not paths:
        print("no fixtures in %s" % FIXTURES)
        return 2
    os.makedirs(EXPECTED, exist_ok=True)
    bad = 0
    # the sim's Build and Art defaults, so GDScript unit tests build "a dummy with X" the way test_engine.py does
    # without repeating the defaults
    defaults = json.dumps(dict(generated_by="tools/design/combat_sim/parity_export.py",
                               build=dataclasses.asdict(E.Build("dummy")), art=dataclasses.asdict(E.Art("art"))),
                          indent=1, ensure_ascii=False) + "\n"
    dpath = os.path.join(ROOT, "tests", "parity", "sim_defaults.json")
    if check:
        same = os.path.exists(dpath) and open(dpath, encoding="utf-8").read() == defaults
        bad += not same
        print(("same  " if same else "DRIFT ") + "sim_defaults.json")
    else:
        with open(dpath, "w", encoding="utf-8", newline="\n") as f:
            f.write(defaults)
        print("wrote sim_defaults.json")
    for p in paths:
        try:
            name, doc = run_fixture(p)
        except (FixtureError, E.EngineError) as e:
            print("BAD   %s" % e)
            return 2
        text = dumps(doc)
        target = os.path.join(EXPECTED, name + ".json")
        r = doc["result"]
        line = "%-22s %-5s t=%7.3f s  rows=%5d  A hp %.1f/%.1f  B hp %.1f/%.1f" % (
            name, r["win"], r["t_ms"] / 1000, len(doc["rows"]), r["A"]["hp"], r["A"]["hp_max"], r["B"]["hp"], r["B"]["hp_max"])
        if check:
            old = open(target, encoding="utf-8").read() if os.path.exists(target) else None
            ok = old == text
            bad += not ok
            print(("same  " if ok else "DRIFT ") + line)
        else:
            with open(target, "w", encoding="utf-8", newline="\n") as f:
                f.write(text)
            print("wrote " + line)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
