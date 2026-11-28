"""Power Rankings calibration (design/gdd/power-rankings.md Formulas C; ADR-0003 decision 6): measures each realm's
ladder of scaled typical fighters, the realm anchors and health_elo with the Python sim, and writes them with every
Power Rankings knob to assets/data/combat_rankings.json. Run once per data version; --check reports drift.

The ladder rung rule (the one place it is defined; the game's RatingLadder applies the same rule): rung k of realm r
is the realm's typical reference fighter (assets/data/combat_reference_fighters.json) with g = 2^(k / (2 * rung_div)):
stage_mult x g (offence: the damage unit), n_body x g and n_qi x g (both pools), block / g and body_block / g (so the
stage multiplier's effect on block cancels). Strength damage x health is g^2 = 2^(k / rung_div).

Run:
  python -I tools/design/combat_sim/export_rankings_calibration.py [--workers N]           measure and write
  python -I tools/design/combat_sim/export_rankings_calibration.py --check [--workers N]   re-measure and compare; exit 1 on drift
"""
import argparse
import concurrent.futures
import copy
import hashlib
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
if HERE not in sys.path:
    sys.path.insert(0, HERE)
import engine as E  # noqa: E402
import parity_export as P  # noqa: E402

ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
DATA = os.path.join(ROOT, "assets", "data")
OUT = os.path.join(DATA, "combat_rankings.json")
# the data the ladder depends on; their hash is the data version (ADR-0003 decision 6)
VERSIONED = ("combat_engine.json", "combat_reference_fighters.json", "combat_effects.json")
_TYPICALS_CACHE = None

# rung_div 32 (not the GDD's first guess of 4): measured 2026-11-14, one rung at rung_div 4 wins 96-100 % because a
# rung scales linh lực as well as offence and health, and linh lực decides sustain fights; at 32 a rung wins 66-69 %
# (about 120 Elo). The rung-counted knobs (k_max, warm_step, cold_step, coarse_bracket) scale with it.
# k_max 256 spans strength x1/256..x256 (Power Rankings Rule 4: 2^(±256/32) = 2^(±8)).
KNOBS = {
    "enabled": True,
    "A_0": 1000.0,
    "rung_div": 32,
    "k_max": 256,
    "probe_fights": 4,
    "coarse_probe_fights": 2,
    "warm_step": 16,
    "cold_step": 64,
    "coarse_bracket": 32,
    "worldgen_fight_budget": 8000,
    "prior_games": 1.0,
    "calibration_fights": 400,
    "calibration_probe_fights": 40,
    "K_0": 48.0,
    "K_min": 16.0,
    "n_half": 10.0,
    "offset_cap": 200.0,
    "offset_keep": 0.5,
    "match_fights": [1, 2, 2, 0, 0],
    "match_window": 5,
    "season_fight_budget": 10000,
    "panel_budget_share": 0.5,
}
BISECT_STEPS = 60
SATURATION = 0.99


def expected(ra, rb):
    """Formulas A: a's expected score against b."""
    return 1.0 / (1.0 + 10.0 ** ((rb - ra) / 400.0))


def rung_record(typical, k, rung_div):
    """The ladder rung rule (module doc)."""
    g = 2.0 ** (k / (2.0 * rung_div))
    rec = copy.deepcopy(typical)
    rec["stage_mult"] = rec.get("stage_mult", 1.0) * g
    rec["n_body"] = rec["n_body"] * g
    rec["n_qi"] = rec["n_qi"] * g
    rec["block"] = rec["block"] / g
    rec["body_block"] = rec.get("body_block", 0.0) / g
    rec["name"] = "%s@%d" % (rec.get("name", "rung"), k)
    return rec


def score(a_rec, b_rec, n, seed0):
    """a's score in n fights against b, half with a on each side of the coin order (1 a win, 0.5 a draw or the time
    limit, 0 a loss)."""
    a, b = P.to_build(a_rec, "a"), P.to_build(b_rec, "b")
    s = 0.0
    for i in range(n):
        if i % 2 == 0:
            w = E.fight(a, b, seed=seed0 + i)["win"]
            s += 1.0 if w == "A" else 0.5 if w in ("draw", "time") else 0.0
        else:
            w = E.fight(b, a, seed=seed0 + i)["win"]
            s += 1.0 if w == "B" else 0.5 if w in ("draw", "time") else 0.0
    return s


def shrunk_share(s, n, prior):
    """Formulas C's prior-shrunk share s'."""
    return (s + prior * 0.5) / (n + prior)


def solve_base(probes, start_rating, ladder, prior):
    """Formulas B's base: R* with sum n_p E(R*, L_kp) + prior E(R*, L_k0) = sum S_p + prior / 2, by bisection on
    [L_min - 2000, L_max + 2000]. probes: [(rung rating, fights, score)]."""
    lo, hi = ladder[0] - 2000.0, ladder[-1] + 2000.0
    want = sum(p[2] for p in probes) + prior * 0.5
    for _ in range(BISECT_STEPS):
        mid = (lo + hi) / 2.0
        got = sum(p[1] * expected(mid, p[0]) for p in probes) + prior * expected(mid, start_rating)
        if got < want:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2.0


def search(probe, ladder, k_max, start_k, step, bracket_stop, fights, prior):
    """Formulas B's search. probe(k, fights) -> score. Returns (base, probes as (k, fights, score))."""
    done = []

    def run(k):
        s = probe(k, fights)
        done.append((k, fights, s))
        return s > fights / 2.0

    k = start_k
    won = run(k)
    last_win, last_loss = (k, None) if won else (None, k)
    while True:
        nk = max(-k_max, min(k_max, k + (step if won else -step)))
        if nk == k:
            break
        k = nk
        won = run(k)
        if won:
            last_win = k if last_win is None or k > last_win else last_win
        else:
            last_loss = k if last_loss is None or k < last_loss else last_loss
        if last_win is not None and last_loss is not None and last_loss > last_win:
            break
        if abs(k) == k_max:
            break
        step *= 2
    if last_win is not None and last_loss is not None and last_loss > last_win:
        while last_loss - last_win > bracket_stop:
            mid = (last_win + last_loss) // 2
            if run(mid):
                last_win = mid
            else:
                last_loss = mid
    rungs = [(ladder[kp + k_max], n, s) for kp, n, s in done]
    return solve_base(rungs, ladder[start_k + k_max], ladder, prior), done


def default_workers():
    return min(8, os.cpu_count() or 1)


def _typicals():
    global _TYPICALS_CACHE
    if _TYPICALS_CACHE is None:
        with open(os.path.join(DATA, "combat_reference_fighters.json"), encoding="utf-8") as f:
            _TYPICALS_CACHE = json.load(f)["fighters"]["typical"]
    return _TYPICALS_CACHE


def _run_gap_task(task):
    r, k, rd, n_fights, prior, seed0 = task
    typ = _typicals()[r]
    upper = rung_record(typ, k + 1, rd)
    lower = rung_record(typ, k, rd)
    s = score(upper, lower, n_fights, seed0)
    sp = shrunk_share(s, n_fights, prior)
    gap = 400.0 * math.log10(sp / (1.0 - sp))
    return (r, k, sp, gap)


def _run_health_task(task):
    r, n_fights, prior, seed0 = task
    typ = _typicals()[r]
    up = copy.deepcopy(typ)
    up["n_body"] = up["n_body"] * 1.2
    s = score(up, typ, n_fights, seed0)
    sp = shrunk_share(s, n_fights, prior)
    return 400.0 * math.log10(sp / (1.0 - sp))


def calibrate(workers=None):
    knobs = dict(KNOBS)
    rd, km, prior = knobs["rung_div"], knobs["k_max"], knobs["prior_games"]
    n_cal = knobs["calibration_fights"]
    typicals = _typicals()
    n_workers = default_workers() if workers is None else max(1, int(workers))

    # Pre-assign deterministic seeds per (r, k) gap and per-realm health_elo before parallel dispatch
    # so any --workers value produces byte-for-byte identical output.
    gap_tasks = []
    for r in range(5):
        for k in range(-km, km):
            idx = r * (2 * km) + (k + km)
            gap_tasks.append((r, k, rd, n_cal, prior, 1 + idx * n_cal))
    health_seed_base = 1 + 5 * (2 * km) * n_cal
    health_tasks = [(r, n_cal, prior, health_seed_base + r * n_cal) for r in range(5)]

    if n_workers == 1:
        gap_results = [_run_gap_task(t) for t in gap_tasks]
        gaps_h = [_run_health_task(t) for t in health_tasks]
    else:
        with concurrent.futures.ProcessPoolExecutor(max_workers=n_workers) as ex:
            health_futs = [ex.submit(_run_health_task, t) for t in health_tasks]
            gap_results = list(ex.map(_run_gap_task, gap_tasks, chunksize=16))
            gaps_h = [f.result() for f in health_futs]

    gaps_by_realm = [[] for _ in range(5)]
    for r, k, sp, gap in gap_results:
        if sp > SATURATION or sp < 1.0 - SATURATION:
            raise SystemExit("calibration saturated: realm %d rungs %d-%d share %.4f; raise rung_div" % (r, k, k + 1, sp))
        gaps_by_realm[r].append(gap)

    anchors = [knobs["A_0"]]
    ladders = []
    anchor_seed = health_seed_base + 5 * n_cal
    for r in range(5):
        gaps = gaps_by_realm[r]
        ladder = [0.0] * (2 * km + 1)
        ladder[km] = anchors[r]
        for i in range(km, 2 * km):
            ladder[i + 1] = ladder[i] + gaps[i]
        for i in range(km, 0, -1):
            ladder[i - 1] = ladder[i] - gaps[i - 1]
        ladders.append(ladder)
        if r < 4:
            nxt = typicals[r + 1]
            fights = knobs["calibration_probe_fights"]

            def probe(k, n, nxt=nxt, r=r):
                nonlocal anchor_seed
                s = score(nxt, rung_record(typicals[r], k, rd), n, anchor_seed)
                anchor_seed += n
                return s
            base, _ = search(probe, ladder, km, 0, knobs["cold_step"], 1, fights, prior)
            anchors.append(base)
    health_elo = sum(gaps_h) / len(gaps_h) / math.log10(1.2)
    return knobs, anchors, ladders, health_elo


def data_version():
    h = hashlib.sha1()
    for name in VERSIONED:
        h.update(open(os.path.join(DATA, name), "rb").read())
    h.update(json.dumps(KNOBS, sort_keys=True).encode())
    return h.hexdigest()[:16]


def build(workers=None):
    knobs, anchors, ladders, health_elo = calibrate(workers=workers)
    out = {"schema_version": 1,
           "_doc": "Power Rankings data (design/gdd/power-rankings.md; ADR-0003). Written by "
                   "tools/design/combat_sim/export_rankings_calibration.py; do not edit the measured fields by hand. "
                   "Knobs: the GDD's Tuning Knobs (enabled is the feature flag). anchors: A_r, each realm's typical "
                   "fighter's rating (A_0 fixed, the rest measured, Formulas C). ladders[r]: the rating of rungs "
                   "-k_max..k_max of realm r's ladder (index k + k_max; rung rule in the exporter's doc: stage_mult, "
                   "n_body and n_qi x g, block and body_block / g, g = 2^(k / (2 rung_div))). health_elo: Elo per "
                   "tenfold of health (Formulas F). data_version: hash of the combat data the ladder was measured on; "
                   "a mismatch at load marks every fighter Stale.",
           "data_version": data_version(),
           "health_elo": round(health_elo, 3),
           "anchors": [round(a, 3) for a in anchors],
           "ladders": [[round(x, 3) for x in lad] for lad in ladders]}
    out.update(knobs)
    return out


def main(argv):
    parser = argparse.ArgumentParser(description="Measure and export Power Rankings calibration.")
    parser.add_argument("--check", action="store_true", help="Re-measure and compare against combat_rankings.json; exit 1 on drift.")
    parser.add_argument("--workers", type=int, default=default_workers(), help="Worker process count (default: min(8, cpu_count)).")
    args = parser.parse_args(argv)
    text = json.dumps(build(workers=args.workers), indent=1, ensure_ascii=False) + "\n"
    if args.check:
        old = open(OUT, encoding="utf-8").read() if os.path.exists(OUT) else None
        same = old == text
        print(("same  " if same else "DRIFT ") + OUT)
        return 0 if same else 1
    with open(OUT, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    d = json.loads(text)
    print("wrote %s: anchors %s, health_elo %.0f, rung gap realm 0 at typical %.1f" % (
        OUT, d["anchors"], d["health_elo"], d["ladders"][0][d["k_max"] + 1] - d["ladders"][0][d["k_max"]]))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
