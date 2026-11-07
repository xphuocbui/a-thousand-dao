"""Final Clause. Once a fight, if you would go Down, your longest-cooldown art fires in
that instant with what it holds, whatever its timer says. It still costs what it costs.

Asked for with "final_clause": true. Rule 10 then settles any double knockout on overkill.
"""


def install(f):
    strike, pulse, run_fight = f.strike, f.pulse, f.run_fight
    gaps = {}

    def run(a, b, gap_a=0, gap_b=0, record=None):
        gaps[id(a)], gaps[id(b)] = gap_a, gap_b
        return run_fight(a, b, gap_a, gap_b, record)

    def clause(side, other, t):
        if side.health > 0 or not side.spec.get("final_clause") or getattr(side, "clause_used", False):
            return
        side.clause_used = True
        art = max(side.arts, key=lambda a: a["cd_ms"])
        cost = art.get("cost_share", 0) * (1 - side.cost_red) * side.qi_max
        if side.qi < cost - 1e-6:
            return
        side.qi -= cost
        art["ready"] = t + art["cd_ms"]
        art["fired"].append(t)
        f.resolve_art(side, other, art, t, gaps.get(id(side.spec), 0))

    def hit(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        dealt = strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        clause(dfn, att, t)
        return dealt

    def tick(side, enemy, gap_of_enemy, t):
        pulse(side, enemy, gap_of_enemy, t)
        clause(side, enemy, t)

    f.strike, f.pulse, f.run_fight = hit, tick, run
