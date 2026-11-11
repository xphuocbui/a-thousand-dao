"""Regression: the new engine (engine.py) against the old time-step simulator (sim.py) on sim.py's scenarios.

Observations, not a verdict: it prints both engines' mean fight length and win split per scenario, and marks a
row DIFF when the means differ by more than 15 % and 2 s or the A-win share by more than 0.25. Known model
differences are listed under KNOWN, so a DIFF there is expected.

Run: python -I tools/design/combat_sim/regress.py [seeds]
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import engine  # noqa: E402
import sim  # noqa: E402

KNOWN = {
    "top-end the^ tu vs top-end": "body shield is its own bar now (sim.py folded it into health, so regeneration refilled it)",
    "top-end the^ tu mirror": "body shield is its own bar now",
}


def stats(results):
    ts = [r["t"] for r in results]
    aw = sum(r["win"] == "A" for r in results) / len(results)
    return sum(ts) / len(ts), aw


def main():
    seeds = int(sys.argv[1]) if len(sys.argv) > 1 and sys.argv[1].isdigit() else 40
    print("%-30s %8s %8s %7s %7s  %s" % ("scenario", "old s", "new s", "old A", "new A", "flag"))
    bad = 0
    for name, a, b in sim.scenarios():
        old = stats([sim.fight(a, b, seed=s) for s in range(seeds)])
        ea, eb = engine.from_sim(a), engine.from_sim(b)
        new = stats([engine.fight(ea, eb, seed=s) for s in range(seeds)])
        dt = abs(new[0] - old[0])
        diff = (dt > 2 and dt > 0.15 * old[0]) or abs(new[1] - old[1]) > 0.25
        flag = ("DIFF (known: %s)" % KNOWN[name]) if diff and name in KNOWN else "DIFF" if diff else ""
        bad += diff and name not in KNOWN
        print("%-30s %8.1f %8.1f %7.2f %7.2f  %s" % (name, old[0], new[0], old[1], new[1], flag))
    print("unexplained differences: %d" % bad)
    return bad


if __name__ == "__main__":
    sys.exit(1 if main() else 0)
