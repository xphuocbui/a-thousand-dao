"""Widening Wound (Khoát Thương). Overflow into a cap shift.

Asked for with "widening_wound": {"share": 0.25, "max": 0.12} on the side whose statuses tick.
At each pulse, the share of what dot_pulse_cap clips is added to that target's dot_pulse_cap
for the rest of the fight, up to "max" (shares of maximum health). It reads only the pulse
cap's clip: a tick already held at dot_pool_cap counts as that cap, so the widest the pulse
can ever be is distinct statuses x dot_pool_cap, whatever the share.
"""


def install(f):
    original = f.pulse

    def pulse(side, enemy, gap_of_enemy, t):
        src = next((s["src"] for s in side.statuses if s["src"].spec.get("widening_wound")), None)
        if src is None:
            return original(side, enemy, gap_of_enemy, t)
        cfg = src.spec["widening_wound"]
        widened = getattr(side, "widened", 0.0)
        base = f.K["dot_pulse_cap"]
        bonus = max([s["src"].spec.get("dot_cap_bonus", 0) for s in side.statuses] or [0])
        tick_cap = (f.K["dot_pool_cap"] + bonus) * side.health_max
        wanted = 0.0
        for s in side.statuses:
            if s.get("kind") == "qi_burn":
                continue
            o = s["src"]
            raw = o.u * o.stage * s["c_tick"] * s["stacks"] * f.multiplier(s["x"], True) \
                * f.supp(gap_of_enemy, o.pierce) * side.guard_factor(s.get("kind", "body"))
            wanted += max(1.0, min(raw, tick_cap))
        room = (base + bonus + widened) * side.health_max
        f.K["dot_pulse_cap"] = base + widened
        try:
            original(side, enemy, gap_of_enemy, t)
        finally:
            f.K["dot_pulse_cap"] = base
        clipped = max(0.0, wanted - room)
        if clipped > 0:
            side.widened = min(cfg.get("max", 1.0),
                               widened + cfg["share"] * clipped / side.health_max)
            src.note("widening_wound_pulses")

    f.pulse = pulse
