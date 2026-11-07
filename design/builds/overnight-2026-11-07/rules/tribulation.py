"""Heavenly Tribulation (thien-kiep.md rules 2 to 8, Formulas A and B) as a whole run of waves.

Asked for with "tribulation" in a fight file:
  {"pool": [{"id": "x", "weight": 1, "boss": {enemy_overrides for a boss at wave 1}}, ...],
   "wave_count": 3, "pool_ramp": 1.5, "rest_pulses": 8, "gap": 1,
   "start_health": 1.0,       wave 1's share: Combat rule 3's max(v, 0.4), for a side that enters hurt
   "draw": ["x", "y", "z"]}   a fixed draw, printed wave by wave. Leave it out to run every
                              ordered draw, weighted without replacement (rule 4).

Carry-over is Formulas B: health exactly, linh luc as qi_end plus rest_pulses of regeneration,
talisman stock spent. A double-knockout win carries 1 health. Anything but a knockout win ends the
run. Fights are the calculator's expected values, so p_t here is the share of draws survived.
It replaces run_one for that file, ignores --enemy, --gap and --matrix, and prints once.
A boss's realm in the file sets only its fight unit. Suppression is always "gap" (rule 6).
"""
import itertools


def install(f):
    original = f.run_one
    state = {"done": False}

    def wave(build, boss, k, tr, h, q, stock):
        spec = {key: v for key, v in build.items() if key != "tribulation"}
        spec["start_health"], spec["start_qi"] = h, q
        arts = []
        for a in spec.get("arts", []):
            a = dict(a)
            if a["id"] in stock:
                a["stock"] = stock[a["id"]]
            arts.append(a)
        spec["arts"] = arts
        over = dict(boss)
        m = boss.get("boss_pool_mult", 1.0) * tr.get("pool_ramp", 1.5) ** (k - 1)
        over["boss_pool_mult"] = min(10.0, m)
        r = spec["realm"] if isinstance(spec["realm"], int) else f.REALMS.index(spec["realm"])
        gap = tr.get("gap", 1)
        enemy = f.merge(f.typical(min(4, r + gap)), over)
        return f.run_fight(spec, enemy, gap_a=gap, gap_b=0)

    def run_draw(build, tr, ids, table, verbose):
        h, q, stock = tr.get("start_health", 1.0), tr.get("start_qi", 1.0), {}
        rows = []
        for k, bid in enumerate(ids, 1):
            res = wave(build, table[bid]["boss"], k, tr, h, q, stock)
            a, b = res["a"], res["b"]
            won = res["end"] == "knockout" and res["winner"] == a.name
            hh = max(a.health, 1.0) / a.health_max
            rest = tr.get("rest_pulses", 8) * a.qi_max * a.regen
            ending = res["end"] if won or res["end"] != "knockout" else "down"
            rows.append((k, bid, ending, res["t"], h, q, hh if won else 0.0, a.qi / a.qi_max,
                         max(b.health, 0) / b.health_max, a.notes.get("fed_hits", 0)))
            if verbose:
                print("wave\t%d\t%s\t%s\tt=%.3f s\tstart h %.4f q %.4f\tend h %.4f q %.4f\tboss %.0f%%\tfed %d"
                      % (rows[-1][:8] + (100 * rows[-1][8], rows[-1][9])))
                for art in a.arts:
                    print("  art\t%s\tfired %d\tblocked %d" % (art["id"], len(art["fired"]), art.get("waited", 0)))
                print("  channels\t" + ", ".join("%s %.0f" % (c, v) for c, v in sorted(a.dmg.items())))
            if not won:
                return False, rows
            h = hh
            q = min(a.qi_max, a.qi + rest) / a.qi_max
            stock = {art["id"]: art["stock_left"] for art in a.arts if art.get("stock_left") is not None}
        return True, rows

    def chance(ids, table):
        left = sum(table[i].get("weight", 1) for i in table)
        p = 1.0
        for i in ids:
            w = table[i].get("weight", 1)
            p *= w / float(left)
            left -= w
        return p

    def run_one(build, enemy_name, gap, timeline):
        tr = build.get("tribulation")
        if not tr:
            return original(build, enemy_name, gap, timeline)
        if state["done"]:
            return None
        state["done"] = True
        table = {b["id"]: b for b in tr["pool"]}
        n = tr.get("wave_count", 3)
        if tr.get("draw"):
            ok, rows = run_draw(build, tr, tr["draw"], table, True)
            print("tribulation\t%s\t%s" % ("survived" if ok else "failed", " > ".join(tr["draw"])))
            return None
        p_t, ends, by_boss, by_wave, h_end, count, alive = 0.0, {}, {}, {}, 0.0, 0, 0
        for ids in itertools.permutations(sorted(table), n):
            w = chance(ids, table)
            ok, rows = run_draw(build, tr, ids, table, False)
            count += 1
            if ok:
                p_t += w
                alive += 1
                h_end += rows[-1][6]
            else:
                last = rows[-1]
                ends[last[2]] = ends.get(last[2], 0.0) + w
                by_boss[last[1]] = by_boss.get(last[1], 0.0) + w
                by_wave[last[0]] = by_wave.get(last[0], 0.0) + w
        print("p_t\t%.3f\tdraws %d\tsurvived %d" % (p_t, count, alive))
        if alive:
            print("mean_final_health\t%.0f%%" % (100 * h_end / alive))
        print("failed_by_ending\t" + ", ".join("%s %.3f" % kv for kv in sorted(ends.items())))
        print("failed_by_boss\t" + ", ".join("%s %.3f" % kv for kv in sorted(by_boss.items())))
        print("failed_by_wave\t" + ", ".join("%d %.3f" % kv for kv in sorted(by_wave.items())))
        return None

    f.run_one = run_one
