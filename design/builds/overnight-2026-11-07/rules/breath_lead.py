"""Longer Breath (Truong Tuc): a new condition, asked for with a guard of
{"breath_lead": true} on a conditional_mods entry.

True while your linh luc, as a share of your maximum, is strictly higher than the
enemy's. Equal is false, so it is off at t = 0. An optional "by": share asks for a
lead of at least that much. Only entries that carry the key are touched, so the
enemy and every other build run as before. Each read leaves a note, so the run's
cap_hit lines show how many hits the condition was on for and off for.
"""


def install(f):
    original = f.guard_true

    def guard_true(g, own, enemy, t):
        if g and "breath_lead" in g:
            lead = own.qi / own.qi_max - enemy.qi / enemy.qi_max
            on = lead > g.get("by", 0.0) + 1e-12
            own.note("longer_breath_hits_on" if on else "longer_breath_hits_off")
            return on
        return original(g, own, enemy, t)

    f.guard_true = guard_true
