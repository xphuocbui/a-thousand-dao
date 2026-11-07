"""Cut Fuse (Tiệt Dẫn): pills swallowed in preparation act in windows of the fight's timeline.

Asked for with "doses" on a side:

  {"start_dd": 10,                # toxicity (dan doc) before the first pill
   "resist": 20,                  # dan_doc_resist_pct
   "pill_effect_pct": 30,         # the real key, Formulas D
   "no_penalty": false,           # dan_doc_no_penalty
   "length_pct": 0,               # Long Dose: lengths, rounded to the nearest pulse
   "first_pill_pct": 0,           # Empty Stomach: the first pill swallowed, added to pill_effect_pct
   "line": 20,                    # the overdose line, on load
   "over_points": 40,             # L5 points while over the line
   "over_harm": 0.03,             # share of maximum health lost at each pulse while over the line
   "pills": [ ... ]}              # in the order swallowed

A pill: {"id", "tox", "quality", "onset", "length", and any of "l4", "ws", "we", "regen",
"speed", "heal", "wash"}. Onset and length are whole pulses. Values are at potency 1.

Potency is Character Stats Formulas D, read in swallowing order, before the pill's own
toxicity is added: (1 + 0.25 quality) x max(floor, 1 - dd/100) x (1 + pill_effect_pct/100),
with floor 0.25 for a pill with "wash" and 0 otherwise. Toxicity is gained at the swallow, so
the order pills go down sets their strength, and the onset sets when they act. The two orders
are independent.

Load is the sum, over doses acting now, of tox x clamp(1 - resist/100, 0.1, 2.0), less what a
wash has taken off. At or above the line the side is over: L5 points on its hits, and over_harm
of maximum health at each pulse, past ward and guard.

Adds the guard {"over_line": true}. `--without dose_timeline` removes the whole piece, which is
also a blind fight. A window opens and closes at a pulse.
"""


def install(f):
    original_init = f.Side.__init__
    original_pulse = f.pulse
    original_layers = f.layer_points
    original_terms = f.Side.ward_terms
    original_next = f.next_event
    original_report = f.report_result
    original_guard = f.guard_true

    def block(side):
        return side.spec.get("doses")

    def factor(spec):
        return max(0.1, min(2.0, 1 - spec.get("resist", 0) / 100.0))

    def compile_doses(side):
        spec = block(side)
        dd = spec.get("start_dd", 0.0)
        out = []
        for i, p in enumerate(spec.get("pills", [])):
            floor = 0.25 if p.get("wash") else 0.0
            p_dd = 1.0 if spec.get("no_penalty") else max(floor, 1 - dd / 100.0)
            pe = spec.get("pill_effect_pct", 0) + (spec.get("first_pill_pct", 0) if i == 0 else 0)
            potency = (1 + 0.25 * p.get("quality", 0)) * p_dd * max(0.0, 1 + pe / 100.0)
            rec = dict(p)
            rec["potency"] = potency
            rec["dd_at_swallow"] = dd
            rec["load"] = p.get("tox", 0) * factor(spec)
            length = p.get("length", 1) * (1 + spec.get("length_pct", 0) / 100.0)
            rec["from"] = f.ms(p.get("onset", 0))
            rec["to"] = rec["from"] + f.ms(max(1, int(length + 0.5)))
            out.append(rec)
            dd = min(100.0, dd + rec["load"])
        side.doses = out
        side.dd_after = dd
        side.washed = 0.0
        side.over_pulses = 0
        side.over_harm_total = 0.0
        side.dose_fired = set()

    def now_of(side):
        return side.__dict__.get("now", 0)

    def acting(side, t):
        return [d for d in side.__dict__.get("doses", []) if d["from"] <= t < d["to"]]

    def total(side, key, t):
        return sum(d.get(key, 0) * d["potency"] for d in acting(side, t))

    def load(side, t):
        return max(0.0, sum(d["load"] for d in acting(side, t)) - side.__dict__.get("washed", 0.0))

    def over(side, t):
        spec = block(side)
        return bool(spec and load(side, t) >= spec.get("line", 1e9) - 1e-9)

    def guard_true(g, own, enemy, t):
        if g and g.get("over_line"):
            return over(own, t)
        return original_guard(g, own, enemy, t)

    def init(self, spec, name):
        original_init(self, spec, name)
        if spec.get("doses"):
            compile_doses(self)
            onset(self, 0)

    def onset(side, t):
        for d in side.doses:
            if d["id"] in side.dose_fired or d["from"] > t:
                continue
            side.dose_fired.add(d["id"])
            if d.get("heal"):
                before = side.health
                side.health = min(side.health_max, side.health + d["heal"] * d["potency"] * side.health_max)
                side.fed_healed = getattr(side, "fed_healed", 0.0) + side.health - before  # Gorged reads this
            if d.get("qi"):
                side.qi = min(side.qi_cap, side.qi + d["qi"] * d["potency"] * side.qi_max)
            if d.get("wash"):
                side.washed += d["wash"] * d["potency"]
                side.dd_after = max(0.0, side.dd_after - d["wash"] * d["potency"])
        speed = total(side, "speed", t)
        for a in side.arts:
            cd = max(f.K["cooldown_min"], a["cooldown"] / (1 + (side.art_speed + speed) / 100.0))
            a["cd_ms"] = f.ms(cd)

    def layer_points(att, dfn, t, extra, channel):
        x = original_layers(att, dfn, t, extra, channel)
        if block(att):
            x[3] += total(att, "l4", t)
            if over(att, t) and channel.split(":")[0] != "tick":
                x[4] += block(att).get("over_points", 0)
        return x

    def ward_terms(self, kind):
        if not block(self):
            return original_terms(self, kind)
        t = now_of(self)
        ws, we = total(self, "ws", t), total(self, "we", t)
        if not ws and not we:
            return original_terms(self, kind)
        saved = self.ward
        self.ward = dict(saved, ws=saved.get("ws", 0) + ws, we=saved.get("we", 0) + we)
        out = original_terms(self, kind)
        self.ward = saved
        return out

    def pulse(side, enemy, gap_of_enemy, t):
        if not block(side):
            return original_pulse(side, enemy, gap_of_enemy, t)
        onset(side, t)
        regen = side.regen
        side.regen = min(f.K["regen_cap"], regen + total(side, "regen", t) / 100.0)
        original_pulse(side, enemy, gap_of_enemy, t)
        side.regen = regen
        if over(side, t):
            harm = block(side).get("over_harm", 0) * side.health_max
            side.health -= harm
            side.dmg_taken_instant += harm
            side.over_pulses += 1
            side.over_harm_total += harm
        return None

    def next_event(sides, pulse_next, t):
        now = original_next(sides, pulse_next, t)
        for s in sides:
            s.now = now
        return now

    def report(res, build):
        original_report(res, build)
        a = res["a"]
        if block(a):
            for d in a.doses:
                print("dose\t%s\tswallowed at dd %.1f\tpotency %.2f\tacts %.0f to %.0f s\tload %.1f" % (
                    d["id"], d["dd_at_swallow"], d["potency"], d["from"] / 1000.0, d["to"] / 1000.0, d["load"]))
            print("dose_total\tover the line %d pulses\tharm %.0f%% of health\ttoxicity after %.1f" % (
                a.over_pulses, 100 * a.over_harm_total / a.health_max, a.dd_after))

    f.Side.__init__ = init
    f.layer_points = layer_points
    f.guard_true = guard_true
    f.Side.ward_terms = ward_terms
    f.pulse = pulse
    f.next_event = next_event
    f.report_result = report
