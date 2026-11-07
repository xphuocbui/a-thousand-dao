"""Presence read live in a fight, and Called Blow (Báo Chiêu), the counted crit and evade.

Asked for by two independent top-level keys, so `--without called_blow` and
`--without presence` each remove one and leave the other.

"presence": {"start": 95, "line": 45, "crit_per": 0.2, "evade_per": 0.4, "mult_per": 1.0,
             "lost_per_pct": 1.0, "applause": 3, "applause_cap": 30}
  Effective presence is start, plus applause per hit slipped (to applause_cap), minus
  lost_per_pct per 1 % of maximum health missing. Points above `line` add crit_per to
  crit_chance_pct, mult_per to crit_damage_pct and evade_per to evade_pct, inside Combat's caps.
  Two "per" scales read it: presence_above and presence_under (Shown Face, Forgotten Face).

"called_blow": {"crit_start": 0.5, "evade_start": 0.0}
  Combat rule 15 and Formulas C, I. This side's crit and evade take no draw and no expected
  value. Crit chance adds to a tally on each hit it throws that can crit; the hit that brings
  the tally to 1 crits at full crit_mult and the tally falls by 1. Evade does the same on each
  hit thrown at it; the hit that fills it is slipped: it deals nothing, drains nothing.
  Starting tallies are set only in a foreseen fight (Rehearsal). A top-level "the_answer": n adds n
  to the crit tally on each hit slipped (The Answer).

Only a side whose spec asks is touched, so the enemy's expected values are unchanged.
Reported as called_crits (by channel), slips and the presence at the end.
"""


def install(f):
    strike0, scale0, report0 = f.strike, f.scale_value, f.report_result

    def live(s):
        p = s.spec["presence"]
        missing = 100 * (1 - max(s.health, 0) / s.health_max)
        clap = min(s.__dict__.get("slips", 0) * p.get("applause", 0), p.get("applause_cap", 0))
        return p["start"] + clap - p.get("lost_per_pct", 0) * missing

    def above(s):
        p = s.spec.get("presence")
        return max(0.0, live(s) - p.get("line", 45)) if p else 0.0

    def crit_of(s):
        p, c = s.spec.get("presence") or {}, s.spec.get("crit", {})
        a = above(s)
        chance = min(c.get("chance", 0) + p.get("crit_per", 0) * a / 100.0, f.K["crit_chance_cap"])
        mult = min(c.get("mult", 1.5) + p.get("mult_per", 0) * a / 100.0, f.K["crit_mult_cap"])
        return chance, mult

    def evade_of(s):
        p = s.spec.get("presence") or {}
        return (s.spec.get("evade_pct", 0) + p.get("evade_per", 0) * above(s)) / 100.0

    def scale_value(c, att, dfn, t):
        per = c.get("per")
        if per in ("presence_above", "presence_under"):
            p = att.spec.get("presence")
            if not p:
                return 0
            v = above(att) if per == "presence_above" else max(0.0, p.get("line", 45) - live(att))
            return min(c.get("points_per", 0) * v, c.get("cap", 1e9))
        return scale0(c, att, dfn, t)

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        called = att.spec.get("called_blow")
        if called is not None or att.spec.get("presence"):
            chance, mult = crit_of(att)
            if called is not None and crit:
                tally = att.__dict__.get("crit_tally", called.get("crit_start", 0.0)) + chance
                hit = tally >= 1 - 1e-9
                att.crit_tally = tally - 1 if hit else tally
                att.crit_ev = mult if hit else 1.0
                if hit:
                    log = att.__dict__.setdefault("called_crits", {})
                    log[channel] = log.get(channel, 0) + 1
            elif called is None:
                att.crit_ev = 1 + chance * (mult - 1)
        guarded = dfn.spec.get("called_blow")
        if guarded is not None or dfn.spec.get("presence"):
            e = evade_of(dfn)
            if guarded is not None:
                e = max(0.0, min(e - att.accuracy, f.K["evade_cap"]))
                tally = dfn.__dict__.get("evade_tally", guarded.get("evade_start", 0.0)) + e
                dfn.evade = 0.0
                if tally >= 1 - 1e-9:
                    dfn.evade_tally = tally - 1
                    dfn.slips = dfn.__dict__.get("slips", 0) + 1
                    if dfn.spec.get("the_answer"):
                        dfn.crit_tally = dfn.__dict__.get("crit_tally", guarded.get("crit_start", 0.0)) + dfn.spec["the_answer"]
                    return 0.0
                dfn.evade_tally = tally
            else:
                dfn.evade = e
                dfn.slips = dfn.__dict__.get("slips", 0) + max(0.0, min(e - att.accuracy, f.K["evade_cap"]))
        return strike0(att, dfn, t, gap, c, kind, extra, channel, crit, direct)

    def report(res, build):
        report0(res, build)
        a = res["a"]
        if a.spec.get("called_blow") is not None:
            print("called_crits\t%s" % a.__dict__.get("called_crits", {}))
        if a.spec.get("presence"):
            print("presence_end\t%.1f\tslips %.1f" % (live(a), a.__dict__.get("slips", 0)))

    f.strike, f.scale_value, f.report_result = strike, scale_value, report
