"""Surplus (Dư Thu). Tick damage the caps clip comes home as linh lực, at a share of its amount.

Asked for with "surplus": {"share": 0.5, "cap": 0.05} on the side that owns the ticks. cap is the most
linh lực, as a share of its owner's maximum, that one pulse can bring in: the burn cap's size.
A side that owns no tick on this target gets nothing, and the ticks themselves are not changed.
Prints surplus_in at the end. Works out what was clipped by comparing what the ticks asked with what
the pulse really took, after guard, so it needs no change to the calculator's pulse.
"""


def install(f):
    original = f.pulse
    report = f.report_result

    def pulse(side, enemy, gap_of_enemy, t):
        owner = enemy if enemy.spec.get("surplus") else None
        ticks = [s for s in side.statuses if s.get("kind") != "qi_burn" and s["src"] is owner]
        if owner is None or not ticks:
            return original(side, enemy, gap_of_enemy, t)
        raw = sum(owner.u * owner.stage * s["c_tick"] * s["stacks"] * f.multiplier(s["x"], True)
                  * f.supp(gap_of_enemy, owner.pierce) * side.guard_factor(s.get("kind", "body"))
                  for s in ticks)
        before = side.health
        original(side, enemy, gap_of_enemy, t)
        clipped = max(0.0, raw - (before - side.health))
        cfg = owner.spec["surplus"]
        gain = min(clipped * cfg.get("share", 0.5), cfg.get("cap", 0.05) * owner.qi_max, owner.qi_cap - owner.qi)
        if gain > 0:
            owner.qi += gain
            owner.surplus_in = getattr(owner, "surplus_in", 0.0) + gain
        return None

    def report_result(res, build):
        report(res, build)
        a = res["a"]
        if a.spec.get("surplus"):
            print("surplus_in\t%.0f%% of maximum linh luc" % (100 * getattr(a, "surplus_in", 0.0) / a.qi_max))

    f.pulse = pulse
    f.report_result = report_result
