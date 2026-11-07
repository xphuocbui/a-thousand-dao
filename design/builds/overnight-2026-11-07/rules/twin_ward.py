"""Twin Wards (Song Hộ), the catalogue keystone: a second ward stands with the first.

Asked for with "twin_ward" on a side:

  {"place": "self" | "room",
   "ward": {"model": "per_pulse", "pass": {...}, "upkeep_share": 0.03},   # or per_hit, drain
   "half": "block" | "stats" | null,
   "shared_stats": true,        # the second ward also reads the side's ws and we
   "seal": true,                # room only: durations stop, enemy regeneration stops
   "falls_clear": true,         # room only: when the room cannot be paid, what it held ends
   "up_from": 0}                # seconds; before this the second ward is not up

place "self": every body or qi hit on this side meets the second ward first, then the slot's ward,
from the same pool. Rule 22's "one ward is up at a time" is the sentence this breaks.
place "room": the second ward stands around the enemy. Hits leaving the enemy meet it, and so do
hits going in to the enemy, this side's own included. Only this side pays it. Ticks are inside
the ward already, so it does not touch them.

"half" is the catalogue's "at half strength", which has two readings. "block": only half of each
hit meets the second ward, and it pays for that half. "stats": it reads half of ws and we.
A per-pulse second ward pays at t = 0 and at each pulse, after regeneration.
`--without twin_ward` takes the whole piece away.
"""


def install(f):
    original_apply = f.apply_ward
    original_pulse = f.pulse
    original_init = f.Side.__init__
    original_report = f.report_result
    original_next = f.next_event

    def tw(side):
        return side.spec.get("twin_ward")

    def up(side):
        spec = tw(side)
        if not spec or side.__dict__.get("twin_fallen"):
            return False
        return side.__dict__.get("now", 0) >= f.ms(spec.get("up_from", 0)) and side.__dict__.get("twin_paid", True)

    def second_record(side):
        spec = tw(side)
        w = dict(spec["ward"])
        base = side.ward if isinstance(side.ward, dict) else {}
        if spec.get("shared_stats", True):
            w.setdefault("ws", base.get("ws", 0))
            w.setdefault("we", base.get("we", 0))
        if spec.get("half") == "stats":
            w["ws"] = w.get("ws", 0) / 2.0
            w["we"] = w.get("we", 0) / 2.0
        return w

    def through_second(side, att, d, kind):
        """The hit meets the second ward, paid from side's pool. Returns what leaks on."""
        spec = tw(side)
        saved_ward, saved_paid = side.ward, side.ward_paid
        side.ward = second_record(side)
        side.ward_paid = True
        if spec.get("half") == "block":
            leak = d / 2.0 + original_apply(side, att, d / 2.0, kind)
        else:
            leak = original_apply(side, att, d, kind)
        side.ward, side.ward_paid = saved_ward, saved_paid
        return leak

    def wall_pass(owner, kind):
        spec = tw(owner)
        saved = owner.ward
        owner.ward = second_record(owner)
        terms = owner.ward_terms(kind)
        owner.ward = saved
        p = terms[1]
        if spec.get("half") == "block":
            p = 1 - (1 - p) / 2.0
        return p

    def apply_ward(dfn, att, d, kind):
        spec_d, spec_a = tw(dfn), tw(att)
        if spec_a and spec_a.get("place") == "room" and up(att):
            before = d
            d = d * wall_pass(att, kind)
            att.twin_own_blocked = att.__dict__.get("twin_own_blocked", 0.0) + before - d
        if spec_d and up(dfn):
            before = d
            d = through_second(dfn, att, d, kind)
            dfn.twin_blocked = dfn.__dict__.get("twin_blocked", 0.0) + before - d
        return original_apply(dfn, att, d, kind)

    def upkeep(side):
        spec = tw(side)
        w = second_record(side)
        if w.get("model") != "per_pulse":
            return
        we = w.get("we", 0)
        cost = w["upkeep_share"] * (1 - we / (100.0 + we)) * side.qi_max
        side.twin_paid = side.qi + 1e-6 >= cost
        if side.twin_paid:
            side.qi -= cost
            side.twin_spent = side.__dict__.get("twin_spent", 0.0) + cost

    def init(self, spec, name):
        original_init(self, spec, name)
        if spec.get("twin_ward") and spec["twin_ward"].get("up_from", 0) == 0:
            upkeep(self)

    def pulse(side, enemy, gap_of_enemy, t):
        spec_e = tw(enemy)
        sealed = bool(spec_e and spec_e.get("place") == "room" and spec_e.get("seal") and up(enemy))
        regen = side.regen
        if sealed:
            side.regen = 0.0
            for s in side.statuses:
                if s["src"] is enemy:
                    s["left"] += 1
        original_pulse(side, enemy, gap_of_enemy, t)
        side.regen = regen
        spec = tw(side)
        if spec and not side.__dict__.get("twin_fallen") and t >= f.ms(spec.get("up_from", 0)):
            upkeep(side)
            if not side.__dict__.get("twin_paid", True) and spec.get("place") == "room":
                side.twin_fallen = t
                if spec.get("falls_clear"):
                    enemy.statuses = [s for s in enemy.statuses if s["src"] is not side]

    def next_event(sides, pulse_next, t):
        now = original_next(sides, pulse_next, t)
        for s in sides:
            s.now = now
        return now

    def report(res, build):
        original_report(res, build)
        a = res["a"]
        if tw(a):
            print("twin_ward\tblocked %.1f\town hits blocked %.1f\tupkeep %.1f\tfell at %s" % (
                a.__dict__.get("twin_blocked", 0.0), a.__dict__.get("twin_own_blocked", 0.0),
                a.__dict__.get("twin_spent", 0.0),
                "%.1f s" % (a.twin_fallen / 1000.0) if a.__dict__.get("twin_fallen") else "never"))

    f.apply_ward = apply_ward
    f.pulse = pulse
    f.Side.__init__ = init
    f.next_event = next_event
    f.report_result = report
