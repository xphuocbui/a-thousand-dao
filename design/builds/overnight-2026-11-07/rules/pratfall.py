"""Slip of the Hand (Thất Thủ), When the Worst Has Passed (Bĩ Cực), Ill Omen and Heckling.

Asked for with "pratfall" on a side, listed after fortune:
  "pratfall": {"base": 0.05, "roll": "expected", "pot": true}

Slip. While a side carries it, every art that would hit, on either side, first rolls to slip:
  p = base + (fortune of the other side - fortune of the caster) x 0.001, when above 0.
  A slip resolves the art on its own caster: same size, same M, through the caster's own ward and
  guard, with no suppression. Basic attacks, companions, ticks and arts with no hit do not roll.
  So the luckier side never slips, and the carrier slips if it is the unluckier.

The Pot ("pot": true). Each art of the other side that does not slip adds its p to a count shown in
the log. At 1.0 the next one slips for certain and the count returns to 0. A slip by chance also
returns it to 0. The carrier's own arts add nothing to it. `--without` cannot reach inside the spec,
so a variant sets "pot": false.

"clip": 0.3 stops a slip taking more than that share of its caster's maximum health. Its ward still pays.

"once_per_art": true. An art that has slipped once in a fight never rolls again: its caster has the
measure of it, and it lands as usual. Off by default, so earlier files are unchanged.

"roll": "expected" draws nothing: only the Pot slips, which is the floor of the real fight and
matches the calculator's expected values. "roll": {"seed": n} draws from one seeded stream per fight.
"sweep": n on either mode also reruns the same fight on seeds 1 to n and prints the spread.

An art with "ill_omen": {"points": 15, "pulses": 3} lowers the other side's fortune by that much for
that long. Repeats stack, to "floor" (default -45). An art with "heckle": {"share": 0.3, "pulses": 3}
shortens the other side's art cooldowns by that share, not below cooldown_min, for that long, and
a repeat refreshes it. Both are curses in the sheet: they fill a curse slot here only as notes.
"""
import random
import statistics


def install(f):
    resolve = f.resolve_art
    pulse = f.pulse
    run_fight = f.run_fight
    report_result = f.report_result
    state = {"rng": None, "spec": None, "args": None, "busy": False}

    def carrier(a, b):
        return a.spec.get("pratfall") or b.spec.get("pratfall")

    def slip_chance(caster, other, spec):
        luck = getattr(f, "fortune_of", lambda side: 50)  # --without fortune: no lead either way
        return spec["base"] + (luck(other) - luck(caster)) * 0.001

    def rolls(art):
        return art.get("c_art", 0) > 0 or art.get("soul_pct")

    def resolve_art(att, dfn, art, t, gap):
        spec = carrier(att, dfn)
        if spec and rolls(art):
            p = max(0.0, min(slip_chance(att, dfn, spec), 1.0))
            if spec.get("once_per_art") and art.get("slipped_once"):
                p = 0.0
            mine = bool(dfn.spec.get("pratfall"))
            slipped = False
            if p > 0:
                if state["rng"] is not None and state["rng"].random() < p:
                    slipped = True
                if mine and spec.get("pot"):
                    dfn.pot = getattr(dfn, "pot", 0.0) + p
                    if dfn.pot >= 1 - 1e-9:
                        slipped = True
                    if slipped:
                        dfn.pot = 0.0
            if slipped:
                art["slipped_once"] = True
                before = att.health
                resolve(att, att, art, t, 0)
                clip = spec.get("clip")
                if clip and before - att.health > clip * att.health_max:
                    att.dmg_taken_instant -= before - att.health - clip * att.health_max
                    att.health = before - clip * att.health_max
                holder = dfn if mine else att
                holder.note("slips_on_the_enemy" if mine else "slips_on_self")
                f.add_dmg(holder, "slip (their own hand)" if mine else "slip (own hand, not dealt)", max(before - att.health, 0))
                return None
        omen = art.get("ill_omen")
        if omen:
            floor = omen.get("floor", -45)
            dfn.fortune_mod = max(getattr(dfn, "fortune_mod", 0) - omen["points"], floor)
            dfn.omen_left = omen["pulses"]
            dfn.omen_points = omen["points"]
        heckle = art.get("heckle")
        if heckle:
            if not getattr(dfn, "heckle_left", 0):
                for a in dfn.arts:
                    a["cd_base"] = a["cd_ms"]
                    a["cd_ms"] = max(f.ms(f.K["cooldown_min"]), int(a["cd_ms"] * (1 - heckle["share"])))
            dfn.heckle_left = heckle["pulses"]
        return resolve(att, dfn, art, t, gap)

    def tick(side, enemy, gap_of_enemy, t):
        pulse(side, enemy, gap_of_enemy, t)
        if getattr(side, "omen_left", 0):
            side.omen_left -= 1
            if not side.omen_left:
                side.fortune_mod = 0
        if getattr(side, "heckle_left", 0):
            side.heckle_left -= 1
            if not side.heckle_left:
                for a in side.arts:
                    a["cd_ms"] = a["cd_base"]

    def fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        spec = a_spec.get("pratfall")
        roll = spec.get("roll", "expected") if spec else None
        state["rng"] = random.Random(roll["seed"]) if isinstance(roll, dict) else None
        if spec and not state["busy"]:
            state["args"] = (a_spec, b_spec, gap_a, gap_b)
        return run_fight(a_spec, b_spec, gap_a, gap_b, record)

    def report(res, build):
        report_result(res, build)
        spec = res["a"].spec.get("pratfall")
        if not spec:
            return
        print("slips\t%d on the enemy" % res["a"].notes.get("slips_on_the_enemy", 0))
        n = spec.get("sweep", 0)
        if not n or state["busy"]:
            return
        state["busy"] = True
        a_spec, b_spec, gap_a, gap_b = state["args"]
        wins, ends, times, health = 0, {}, [], []
        for seed in range(1, n + 1):
            one = dict(a_spec, pratfall=dict(spec, roll={"seed": seed}))
            r = f.run_fight(one, b_spec, gap_a, gap_b)
            won = r["end"] == "knockout" and r["winner"] == r["a"].name
            key = "win" if won else ("loss" if r["end"] == "knockout" else r["end"])
            ends[key] = ends.get(key, 0) + 1
            if won:
                times.append(r["t"])
                health.append(max(r["a"].health, 0) / r["a"].health_max)
        state["busy"] = False
        line = "sweep\tseeds %d\t%s" % (n, ", ".join("%s %d" % kv for kv in sorted(ends.items())))
        if times:
            times.sort()
            line += "\twin time median %.1f s, 10th %.1f, 90th %.1f\tmean health at a win %.0f%%" % (
                statistics.median(times), times[len(times) // 10], times[(len(times) * 9) // 10],
                100 * sum(health) / len(health))
        print(line)

    f.resolve_art = resolve_art
    f.pulse = tick
    f.run_fight = fight
    f.report_result = report
