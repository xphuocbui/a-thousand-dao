"""Still Water. Regeneration clipped by a full pool restores health, at a share of its
amount. Asked for with "still_water_share": 0.5.

For that side, regeneration runs here instead of in pulse, so what is clipped is known
after burns. That moves regeneration after a per-pulse ward's upkeep, which this build,
on a per-hit ward, does not have.
"""


def install(f):
    pulse, report_result = f.pulse, f.report_result

    def tick(side, enemy, gap_of_enemy, t):
        share = side.spec.get("still_water_share", 0)
        if not share:
            return pulse(side, enemy, gap_of_enemy, t)
        blocked = any(c.get("block_regen") for c in side.curses)
        regen, side.regen = side.regen, 0.0
        pulse(side, enemy, gap_of_enemy, t)
        side.regen = regen
        if blocked or side.health <= 0:
            return None
        amount = side.qi_max * regen
        gained = min(amount, side.qi_cap - side.qi)
        side.qi += gained
        healed = min((amount - gained) * share, side.health_max - side.health)
        side.health += healed
        side.still_water_healed = getattr(side, "still_water_healed", 0.0) + healed
        return None

    def report(res, build):
        report_result(res, build)
        a = res["a"]
        if a.spec.get("still_water_share"):
            print("still_water_healed\t%.0f%% of maximum health"
                  % (100 * getattr(a, "still_water_healed", 0.0) / a.health_max))

    f.pulse, f.report_result = tick, report
