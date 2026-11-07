"""Lodged Poison (Ký Độc), keystone of the Way of Poison (daos/poison.md).

Asked for with "lodged_poison": {"ticks": ["poison", "bile"], "arts": ["thin_dose"]}.
A listed tick on the target reads the target's U and stage in place of the source's, with
supp at 1. Your L1 to L4 still apply, and dot_pool_cap and dot_pulse_cap do not move. A
listed art deals no hit, and its status still lands. --without lodged_poison gives the same
file with neither.
"""


def install(f):
    pulse, resolve_art = f.pulse, f.resolve_art

    def tick(side, enemy, gap_of_enemy, t):
        changed = []
        for s in side.statuses:
            src = s["src"]
            spec = src.spec.get("lodged_poison")
            if spec and s["id"] in spec.get("ticks", []):
                factor = (side.u * side.stage) / (src.u * src.stage) / f.supp(gap_of_enemy, src.pierce)
                changed.append((s, s["c_tick"]))
                s["c_tick"] *= factor
        pulse(side, enemy, gap_of_enemy, t)
        for s, value in changed:
            s["c_tick"] = value

    def resolve(att, dfn, art, t, gap):
        spec = att.spec.get("lodged_poison")
        if spec and art["id"] in spec.get("arts", []):
            art = dict(art, c_art=0)
        return resolve_art(att, dfn, art, t, gap)

    f.pulse, f.resolve_art = tick, resolve
