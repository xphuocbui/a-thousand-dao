"""Rubbing (Brush Fee). An art with no content of its own: it fires in the instant an
enemy art fires, once per its own timer, and takes that art's c_art and kind.

A side asks for it per art: "rubbing": true and the guard
{"copies_enemy": true, "who": "enemy", "pool": "qi", "above": 2}. The last three keys
only keep the guard false if this plug-in is skipped. Optional per art: "copy_c"
(coefficient multiplier), "copy_swap" (body and qi swapped). "reading_rho_min" on the
side moves the reading gate: a ratio of own over enemy divine_sense below it copies
nothing. With two enemy arts in one instant a Rubbing copies the first in slot order.
Also adds the "per" scale "copied_firings", with "cap", for Practised Stroke.
"""


def install(f):
    guard_true, resolve_art, scale_value = f.guard_true, f.resolve_art, f.scale_value

    def will_fire(art, side, other, t):
        """The checks of run_fight's cost step, read before the enemy takes them."""
        if art["ready"] > t or art.get("stock_left") == 0:
            return False
        if not f.guard_true(art.get("guard"), side, other, t):
            return False
        if art.get("soul_pct") and side.lock_until > t:
            return False
        raised = min(side.curse_sum("cost_raise"), f.K["curse_cost_raise_max"])
        cost = art.get("cost_share", 0) * (1 - side.cost_red) * (1 + raised) * side.qi_max
        return side.qi >= cost - 1e-6

    def guard(g, own, enemy, t):
        if g and g.get("copies_enemy"):
            gate = own.spec.get("reading_rho_min", f.K["rho_min"])
            if own.sense / enemy.sense < gate:
                return False
            return any(will_fire(a, enemy, own, t) for a in enemy.arts)
        return guard_true(g, own, enemy, t)

    def resolve(att, dfn, art, t, gap):
        if not art.get("rubbing"):
            return resolve_art(att, dfn, art, t, gap)
        source = next((a for a in dfn.arts if t in a["fired"]), None)
        if source is None:
            return None
        copy = dict(art)
        copy["c_art"] = source.get("c_art", 0) * art.get("copy_c", 1.0)
        kind = source.get("kind", "body")
        if art.get("copy_swap"):
            kind = {"body": "qi", "qi": "body"}.get(kind, kind)
        copy["kind"] = kind
        return resolve_art(att, dfn, copy, t, gap)

    def scale(c, att, dfn, t):
        if c.get("per") == "copied_firings":
            fired = sum(len(a["fired"]) for a in dfn.arts)
            return min(c.get("points_per", 0) * fired, c.get("cap", float("inf")))
        return scale_value(c, att, dfn, t)

    f.guard_true, f.resolve_art, f.scale_value = guard, resolve, scale
