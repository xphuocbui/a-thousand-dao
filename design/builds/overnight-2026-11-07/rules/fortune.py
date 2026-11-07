"""Fortune (khí vận) on fight rolls: Combat Formulas I, faithful, not a proposal.

Asked for with "fortune": true on a side. Both sides then read "khi_van" (default 50, as
rules/escape.py does; the reference enemies carry none, so 50 is an assumption, the talent's
neutral point in Character Stats Formulas H).

  p' = p + (khi_van_self - khi_van_other) x 0.001, when 0 < p < 1, before the roll's own cap.

The calculator's crit and evade are expected values, so this moves the expected value. A chance
of exactly 0 is not shifted: a side with no evade_pct or no crit stays there, whatever its lead.
Also provides f.fortune_of(side), which curses in other plug-ins may lower for one fight through
side.fortune_mod.
"""
PER_POINT = 0.001


def eff(spec):
    return max(1, min(150, spec.get("khi_van", 50)))


def install(f):
    original = f.run_fight

    def fortune_of(side):
        return max(1, min(150, eff(side.spec) + getattr(side, "fortune_mod", 0)))

    def shifted(spec, lead):
        spec = dict(spec)
        crit = dict(spec.get("crit", {}))
        p = crit.get("chance", 0)
        if 0 < p < 1:
            crit["chance"] = max(0.0, min(p + lead * PER_POINT, f.K["crit_chance_cap"]))
            spec["crit"] = crit
        p = spec.get("evade_pct", 0) / 100.0
        if 0 < p < 1:
            spec["evade_pct"] = 100 * max(0.0, min(p + lead * PER_POINT, f.K["evade_cap"]))
        return spec

    def run_fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        if a_spec.get("fortune") or b_spec.get("fortune"):
            lead = eff(a_spec) - eff(b_spec)
            a_spec, b_spec = shifted(a_spec, lead), shifted(b_spec, -lead)
        return original(a_spec, b_spec, gap_a, gap_b, record)

    f.fortune_of = fortune_of
    f.run_fight = run_fight
