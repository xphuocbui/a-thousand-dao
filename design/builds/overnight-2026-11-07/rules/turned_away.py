"""Turned Away (Bế Môn): a stored health floor at the defeat check.

Asked for with "scar_floor": n (Gate Scars), "scar_floor_share" (health stood at) and
"scar_cost_share" (share of maximum linh lực paid). A side at 0 health at the defeat
check, with a scar left and the linh lực to pay, opens one scar and stands. One per
instant.

Optional, on the same side:
  "refused_force": {"layer": 2, "points_per": 15, "channels": [...]}  points per floor held
  "scar_haste_ms": 500   the cut modifier Second Attempt: art timers fall when a floor holds

run_fight has no hook at the defeat check, but it reads each side's dry_at immediately
before it, so dry_at is a property here and the check runs on that read. next_event
gives the instant. It chains to any dry_at hook already installed, so it may share a fight with
lit_wick or stands_over: the plug-in listed last acts first at the defeat check.
"""


def install(f):
    original_next = f.next_event
    original_points = f.layer_points
    original_report = f.report_result
    earlier = f.Side.__dict__.get("dry_at")  # another plug-in's hook, which this one chains to

    def next_event(sides, pulse_next, t):
        now = original_next(sides, pulse_next, t)
        for s in sides:
            s.now = now
        return now

    def opened(side):
        return side.__dict__.setdefault("scar_times", [])

    def defeat_check(s):
        times = opened(s)
        now = s.__dict__.get("now", 0)
        cost = s.spec.get("scar_cost_share", 0) * s.qi_max
        if s.health > 0 or len(times) >= s.spec["scar_floor"] or now in times:
            return
        if s.qi + 1e-6 < cost:
            return
        s.qi -= cost
        s.health = s.spec.get("scar_floor_share", 0.05) * s.health_max
        times.append(now)
        haste = s.spec.get("scar_haste_ms", 0)
        for art in s.arts:
            art["ready"] = max(now, art["ready"] - haste)

    def get_dry(self):
        if self.spec.get("scar_floor"):
            defeat_check(self)
        if earlier is not None:
            return earlier.fget(self)
        return self.__dict__.get("_dry_at")

    def set_dry(self, value):
        self.__dict__["_dry_at"] = value

    def layer_points(att, dfn, t, extra, channel):
        x = original_points(att, dfn, t, extra, channel)
        rf = att.spec.get("refused_force")
        if rf and channel.split(":")[0] in rf["channels"]:
            x[rf["layer"] - 1] += rf["points_per"] * len(opened(att))
        return x

    def report_result(res, build):
        original_report(res, build)
        a = res["a"]
        if a.spec.get("scar_floor"):
            times = opened(a)
            print("scars_opened\t%d of %d\tat %s" % (len(times), a.spec["scar_floor"], ", ".join(
                "%.2f" % (x / 1000.0) for x in times)))

    f.next_event = next_event
    f.Side.dry_at = property(get_dry, set_dry)
    f.layer_points = layer_points
    f.report_result = report_result
