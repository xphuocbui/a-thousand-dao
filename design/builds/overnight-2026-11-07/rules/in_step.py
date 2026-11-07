"""In Step (Đồng Bộ): a guard, true in an instant where one of your arts has already resolved.

Used as {"in_step": true} in a guard. An art that fires alone in its instant does not see
itself, so the first art of a volley does not count and each later one does. The basic attack
and the companion land after a side's arts (Combat rule 10), so they see every art of the
instant. Set by resolve_art whether or not the art has a hit.
"""


def install(f):
    original_guard = f.guard_true
    original_resolve = f.resolve_art

    def guard_true(g, own, enemy, t):
        if g and g.get("in_step"):
            return own.__dict__.get("last_art_t") == t
        return original_guard(g, own, enemy, t)

    def resolve_art(att, dfn, art, t, gap):
        out = original_resolve(att, dfn, art, t, gap)
        att.last_art_t = t
        return out

    f.guard_true = guard_true
    f.resolve_art = resolve_art
