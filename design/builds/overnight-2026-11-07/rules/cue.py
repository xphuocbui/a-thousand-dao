"""Cue (Tin Hieu): a guard and a per scale that read the Understudy's Curtain.

Guard {"cued": true}: true in an instant where a hit aimed at you has landed on the double. An art
guarded this way fires in the follow-up instant (Combat rule 10), so it is a riposte.

Per scale "curtain_hits": the number of hits that have landed on the double this fight. A conditional
with "cap" stops there. Both read 0 and false if understudy.py is skipped, so a removal run still runs.
"""


def install(f):
    guard_true, scale_value = f.guard_true, f.scale_value

    def guard(g, own, enemy, t):
        if g and g.get("cued"):
            return own.__dict__.get("cue_t") == t
        return guard_true(g, own, enemy, t)

    def scale(c, att, dfn, t):
        if c.get("per") == "curtain_hits":
            v = c.get("points_per", 0) * att.__dict__.get("curtain_hits", 0)
            return min(v, c["cap"]) if "cap" in c else v
        return scale_value(c, att, dfn, t)

    f.guard_true, f.scale_value = guard, scale
