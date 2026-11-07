"""Parting Cut (Biệt Đao). What you opened goes on bleeding after you are Down.

Asked for with "parting_cut": true. When this side loses by knockout, the fight's result waits:
its statuses on the winner keep ticking pulse by pulse, durations falling, until they run out.
The Down side does nothing. The winner regenerates as normal and may fire only a cleanse art
(cleanse_art.py), when its timer is up and it can pay. If the winner reaches 0 health the end
becomes "mutual_knockout", winner None: a loss for this side, which is still Down. Otherwise the
knockout stands, with the winner's health lowered.
"""


def install(f):
    original = f.run_fight

    def run_fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        res = original(a_spec, b_spec, gap_a, gap_b, record)
        a, b = res["a"], res["b"]
        for loser, winner, gap in ((a, b, gap_a), (b, a, gap_b)):
            if res["end"] != "knockout" or res["winner"] != winner.name \
                    or not loser.spec.get("parting_cut"):
                continue
            t = (f.ms(res["t"]) // 1000 + 1) * 1000
            while any(s["src"] is loser for s in winner.statuses):
                f.pulse(winner, loser, gap, t)
                for art in winner.arts:
                    cost = art.get("cost_share", 0) * winner.qi_max
                    if art.get("cleanse") and art["ready"] <= t and winner.qi >= cost:
                        winner.qi -= cost
                        art["ready"] = t + art["cd_ms"]
                        f.resolve_art(winner, loser, art, t, 0)
                loser.note("parting_cut_pulses")
                if winner.health <= 0:
                    res["end"], res["winner"] = "mutual_knockout", None
                    res["t"] = t / 1000.0
                    break
                t += 1000
        return res

    f.run_fight = run_fight
