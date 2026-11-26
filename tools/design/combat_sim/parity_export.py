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
  ... --only <fixture name>                                        one fixture
  ... --quick       skip the chancy fixtures (their 10x-seed sim references take ~8 min); the exact ones
                    take seconds. Per slice --check --quick; the full --check at a stage's end (user 2026-11-26)
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
        # an escape roll is always chancy (clamped 5-95 %, Formulas I); chance-free only when the fixture says every
        # channel ends while the side is Bound (no draw), which the GDScript run then proves event by event
        if a.escape and not fx.get("escapes_bound"):
            raise FixtureError("%s: chance_free, but art %s is an escape art" % (where, a.name))
        for st in a.statuses:
            if st.get("chance", 1.0) < 1:
                raise FixtureError("%s: chance_free, but art %s applies %s at chance %s" % (where, a.name, st["id"], st["chance"]))
            # Drunk lowers the drunk side's accuracy (2026-11-26); chance-free only while the drunk side's own
            # accuracy keeps every evade chance at 0 (its foe has no evade, so acc >= 1 covers 10 stacks)
            if st["id"] == "drunk":
                other = fx["b" if where.endswith(".a") else "a"]
                if float(other.get("acc", 0.0)) < 1.0:
                    raise FixtureError("%s: chance_free, but art %s lays Drunk on a side with acc < 1" % (where, a.name))
        # Thunder stacks raise crit chance; Earth debuffs lower accuracy, which lets the other side evade
        if a.element == "thunder" and (a.buff or a.debuff):
            raise FixtureError("%s: chance_free, but art %s grants Thunder stacks (crit chance)" % (where, a.name))
        if a.element == "earth" and a.debuff:
            raise FixtureError("%s: chance_free, but art %s grants Earth debuffs (evade chance)" % (where, a.name))
    for w in b.wards:
        if w.get("evade"):
            raise FixtureError("%s: chance_free, but ward %s gives evade" % (where, w.get("id")))


def run_chancy(fx, name, a, b):
    """A chancy fixture. The GDScript engine runs `seeds` fights (default 1,000; ADR-0001 amended 2026-11-13) with the
    coin order and compares only statistics, since its random stream differs: mean fight time within 5 %, each win
    share within 0.05. The reference here uses `ref_seeds` (default 10 x seeds), so the reference itself is close to
    the true value and the band only has to absorb the GDScript sample's noise (about +-0.016 at 1,000 seeds); with a
    1,000-seed reference, seeds 0-999 of the even mirror read A 0.529 / B 0.441 against a true 0.48 / 0.48."""
    n = int(fx.get("seeds", 1000))
    ref_n = int(fx.get("ref_seeds", 10 * n))
    wins = {"A": 0, "B": 0, "draw": 0, "time": 0, "flight": 0}
    total_t = 0.0
    for s in range(ref_n):
        r = E.fight(a, b, seed=s, order="random")
        wins[r["win"]] += 1
        total_t += r["t"]
    again = [E.fight(a, b, seed=s, order="random")["t"] for s in range(5)]
    if again != [E.fight(a, b, seed=s, order="random")["t"] for s in range(5)]:
        raise FixtureError("%s: the same seed gave two different fights" % name)
    return dict(
        fixture=name, slice=fx.get("slice"), chance_free=False, seeds=n, ref_seeds=ref_n,
        generated_by="tools/design/combat_sim/parity_export.py (order=random)",
        a=as_doc(a), b=as_doc(b),
        stats=dict(mean_t=total_t / ref_n, share={k: v / ref_n for k, v in wins.items() if v or k != "flight"}),
        rows=[],
    )


# Fields added after the expected files were written are left out while at their default, so every earlier
# expected file stays byte-identical (world-depth Stage 5): an art's escape (slice E).
LATE_ART_FIELDS = {"escape": 0.0}
LATE_BUILD_FIELDS = {"pill": {}}


def as_doc(b):
    d = dataclasses.asdict(b)
    for k, v in LATE_BUILD_FIELDS.items():
        if d.get(k) == v:
            d.pop(k, None)
    for art in d.get("arts", []):
        for k, v in LATE_ART_FIELDS.items():
            if art.get(k) == v:
                art.pop(k, None)
    return d


def as_doc_art(a):
    d = dataclasses.asdict(a)
    for k, v in LATE_ART_FIELDS.items():
        if d.get(k) == v:
            d.pop(k, None)
    return d


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
    else:
        return name, run_chancy(fx, name, a, b)
    out = None
    for _ in range(2):                      # the same fixture twice: the sim itself must be deterministic
        f = E.Fight(a, b, seed=int(fx.get("seed", 1)), order="fixed", parity=True)
        res = f.run()
        doc = dict(
            fixture=name, slice=fx.get("slice"), chance_free=bool(fx.get("chance_free")), seed=int(fx.get("seed", 1)),
            generated_by="tools/design/combat_sim/parity_export.py (order=fixed)",
            a=as_doc(a), b=as_doc(b),
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
    if "--only" in argv:   # one fixture by name (2026-11-26): python -I parity_export.py --only t10_depth_exact
        only = argv[argv.index("--only") + 1]
        paths = [x for x in paths if os.path.basename(x)[:-5] == only]
    if "--quick" in argv:   # exact fixtures only (user 2026-11-26: the chancy references made the check ~8 min)
        paths = [x for x in paths if json.load(open(x, encoding="utf-8")).get("chance_free")]
    if not paths:
        print("no fixtures in %s" % FIXTURES)
        return 2
    os.makedirs(EXPECTED, exist_ok=True)
    bad = 0
    # the sim's Build and Art defaults, so GDScript unit tests build "a dummy with X" the way test_engine.py does
    # without repeating the defaults
    defaults = json.dumps(dict(generated_by="tools/design/combat_sim/parity_export.py",
                               build=dataclasses.asdict(E.Build("dummy")), art=as_doc_art(E.Art("art"))),
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
        if doc["chance_free"]:
            r = doc["result"]
            line = "%-22s %-5s t=%7.3f s  rows=%5d  A hp %.1f/%.1f  B hp %.1f/%.1f" % (
                name, r["win"], r["t_ms"] / 1000, len(doc["rows"]), r["A"]["hp"], r["A"]["hp_max"], r["B"]["hp"],
                r["B"]["hp_max"])
        else:
            st = doc["stats"]
            line = "%-22s chancy %d seeds: mean t=%.2f s  shares A %.3f  B %.3f  draw %.3f  time %.3f" % (
                name, doc["seeds"], st["mean_t"], st["share"]["A"], st["share"]["B"], st["share"]["draw"],
                st["share"]["time"])
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
