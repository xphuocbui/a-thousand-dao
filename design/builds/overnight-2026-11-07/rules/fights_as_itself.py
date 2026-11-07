"""Fights as Itself (Tự Chiến): a companion hits with its own realm, not its owner's.

Asked for with "realm" (and optional "stage") on the side's "companion". Combat Formulas J
uses U_owner, stage_owner and the owner's suppression gap. Under this rule the companion's
hit uses its own fight unit, its own stage and its own gap to the defender. c_comp_cap and
M(companion tags), which is the owner's, do not change. A companion with no "realm" is
untouched, so the enemy never acts on this rule unless its spec asks.
"""


def install(f):
    original = f.strike

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        comp = att.companion or {}
        if channel == "companion" and "realm" in comp:
            r = f.REALMS.index(comp["realm"])
            c = c * f.fight_unit(r) * comp.get("stage", 1.0) / (att.u * att.stage)
            gap = max(0, dfn.r - r)
        return original(att, dfn, t, gap, c, kind, extra, channel, crit, direct)

    f.strike = strike
