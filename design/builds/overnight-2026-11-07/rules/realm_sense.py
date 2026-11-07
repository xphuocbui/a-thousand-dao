"""Thần thức across realms, which the calculator does not scale.

fight_calc gives both sides one divine_sense for every gap, but Character Stats Formulas C
multiplies it by M_ts (1 / 3 / 10 / 30 / 100). So a soul art's matrix is wrong by the square of
that ratio one realm up. Any soul build should use this.

Asked for with "realm_sense": {"typical": 57, "top_end": 85}: each enemy's sense before M_ts, in the
same units as this side's divine_sense (than_hon x stage x thần thức pct). An enemy may instead carry
"sense_base" through enemy_overrides, which wins. The enemy's sense becomes that x M_ts[enemy realm]
/ M_ts[this realm]. Only the asking side's opponent is touched.
"""

M_TS = [1, 3, 10, 30, 100]  # than_thuc_mult, cultivation_realms.json


def install(f):
    original = f.run_fight

    def run_fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        table = a_spec.get("realm_sense")
        if table:
            ar = a_spec["realm"] if isinstance(a_spec["realm"], int) else f.REALMS.index(a_spec["realm"])
            br = b_spec["realm"] if isinstance(b_spec["realm"], int) else f.REALMS.index(b_spec["realm"])
            base = b_spec.get("sense_base", table.get(b_spec.get("name"), 1.0))
            b_spec = dict(b_spec, divine_sense=base * M_TS[br] / float(M_TS[ar]))
        return original(a_spec, b_spec, gap_a, gap_b, record)

    f.run_fight = run_fight
