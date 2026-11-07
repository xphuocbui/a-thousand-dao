"""Rich Soil (Phì Thổ). Asked for with "rich_soil": {"above": 0.5, "bonus": 0.02} on the side that owns
the ticks. While the target's linh lực share is at or above "above", both tick caps on that target
rise by "bonus". It sets the calculator's own dot_cap_bonus on a private copy of the owner's spec at
each pulse, so a side that does not ask for it reads nothing new. List it after sown_field.
"""


def install(f):
    original = f.pulse

    def pulse(side, enemy, gap_of_enemy, t):
        cfg = enemy.spec.get("rich_soil")
        if cfg:
            if not getattr(enemy, "rich_soil_copied", False):
                enemy.spec = dict(enemy.spec)
                enemy.rich_soil_copied = True
            rich = side.qi / side.qi_max >= cfg.get("above", 0.5) - 1e-12
            enemy.spec["dot_cap_bonus"] = cfg.get("bonus", 0.02) if rich else 0.0
            if rich:
                enemy.note("rich_soil_pulses")
        return original(side, enemy, gap_of_enemy, t)

    f.pulse = pulse
