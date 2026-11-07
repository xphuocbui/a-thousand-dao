"""Flight (ngự bảo), the Recall Banner's rule. Art records with "flight": true are
equipped pieces on their own timers.

  - They take no art slot: "empty_slots" does not count them.
  - The thần thức in flight leaves the fight: with "thought": {"held", "used"}, the side
    defends against soul arts on divine_sense x free share. Nothing in the build attacks
    with soul, so the lower value is the only one used.
  - "flight_cut": true. A soul art that lands cuts the threads: no flight piece fires
    for soul_lockout.
"""


def install(f):
    original_scale = f.scale_value
    original_resolve = f.resolve_art
    original_init = f.Side.__init__
    original_report = f.report_result

    def init(self, spec, name):
        original_init(self, spec, name)
        th = spec.get("thought")
        if th and any(a.get("flight") for a in self.arts):
            self.sense *= (th["held"] - th["used"]) / float(th["held"])

    def scale_value(c, att, dfn, t):
        if c.get("per") == "empty_slots" and any(a.get("flight") for a in att.arts):
            held = len([a for a in att.arts if not a.get("flight")])
            return c.get("points_per", 0) * max(0, f.K["slots_by_realm"][att.r] - held)
        return original_scale(c, att, dfn, t)

    def resolve_art(att, dfn, art, t, gap):
        before = dfn.health
        out = original_resolve(att, dfn, art, t, gap)
        if art.get("soul_pct") and dfn.spec.get("flight_cut") and dfn.health < before:
            until = t + f.ms(f.K["soul_lockout"])
            for a in dfn.arts:
                if a.get("flight"):
                    a["ready"] = max(a["ready"], until)
            dfn.__dict__.setdefault("cuts", []).append(t)
        return out

    def report_result(res, build):
        original_report(res, build)
        a = res["a"]
        if a.spec.get("flight_cut"):
            cuts = a.__dict__.get("cuts", [])
            print("threads_cut\t%d\tat %s" % (len(cuts), ", ".join("%.2f" % (x / 1000.0) for x in cuts)))

    f.Side.__init__ = init
    f.scale_value = scale_value
    f.resolve_art = resolve_art
    f.report_result = report_result
