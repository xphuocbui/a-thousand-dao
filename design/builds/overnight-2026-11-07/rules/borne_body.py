"""Borne Body (Tá Thể): the body in the fight is a puppet, a record that is both artifact and beast.

Asked for with "borne_body" on a side:

  {"operator": {"n_body": 0.6, "present": false, "guard": {...}},
   "bodies": [{"id": "wooden_novice", "n_body": 0.8,
               "guard": {"a_b": 0, "t_b": 1, "body_guard_pct": 0},
               "hit": {"c": 0.5, "kind": "body", "x": [0, 0, 0, 0, 0]},
               "art": {...an art record, optional, its fixed art...},
               "store_qi": 0.15}, ...]}          # in slot order

The side's health, n_body and guard are the first body's. The operator's linh lực, ward, arts
and modifiers stay in force through it, so rule 11 still binds. Its blow is the companion
channel (Formulas J) at its own c, and the side has no basic attack of its own: there is one
body, so there is one fist. "companion_speed_pct" on the side divides its timer, stopping at
cooldown_min. A fixed art starts on a full cooldown when its body walks on and stays after it.

When a body falls at the defeat check, the next in slot order walks on at full health, in the
same instant. Statuses and curses on the fallen body fall with it. Its "store_qi" share of
maximum linh lực is the store in the next body, paid as it walks on. When the last has
fallen: with "present": true the operator's own body stands, with the operator's guard, no blow
and nothing stored; otherwise the side is Down, and that is a loss with no wound to the operator.

A soul art does not stop at the puppet. It goes up the thread: the health share lands on the
operator's own bar, which nothing but a soul art touches while a body stands, and the linh lực
share lands on the shared pool. If that bar empties the thread is cut and the side is Down.

Adds the guard {"bodies_fallen": n}, true once n bodies have fallen. run_fight has no hook at the
defeat check, so this uses the device in stands_over.py: dry_at is read just before it.
`--without borne_body` leaves the side as its own "n_body" and guard, which is the operator
fighting on their own legs.
"""


def install(f):
    original_init = f.Side.__init__
    original_resolve = f.resolve_art
    original_strike = f.strike
    original_guard = f.guard_true
    original_next = f.next_event
    original_report = f.report_result
    earlier = f.Side.__dict__.get("dry_at")

    def spec_of(side):
        return side.spec.get("borne_body")

    def interval(side):
        speed = side.spec.get("companion_speed_pct", 0)
        return f.ms(max(f.K["cooldown_min"], f.K["basic_cooldown"] / (1 + speed / 100.0)))

    def wear(side, body):
        side.n_body = body["n_body"]
        side.health_max = f.K["health_units"] * side.u * body["n_body"] * side.boss
        side.health = side.health_max
        g = body.get("guard", {})
        side.a_b, side.t_b, side.bg_pct = g.get("a_b", 0), g.get("t_b", 0), g.get("body_guard_pct", 0)
        hit = body["hit"]
        side.companion = {"c_comp": hit["c"], "kind": hit.get("kind", "body"), "x": hit.get("x")}
        now = side.__dict__.get("now", 0)
        side.comp_next = now + interval(side)
        side.current_body = body["id"]
        art = body.get("art")
        if art:
            rec = dict(art)
            cd = max(f.K["cooldown_min"], art["cooldown"] / (1 + side.art_speed / 100.0))
            rec["cd_ms"] = f.ms(cd)
            rec["ready"] = now + rec["cd_ms"]
            rec["fired"] = []
            rec["stock_left"] = art.get("stock")
            side.arts.append(rec)

    def init(self, spec, name):
        original_init(self, spec, name)
        b = spec.get("borne_body")
        if not b:
            return
        self.now = 0
        self.queue = list(b["bodies"])
        self.fallen = []
        self.basic = {"c": 0}
        op = b.get("operator", {})
        self.op_max = f.K["health_units"] * self.u * op.get("n_body", 1.0)
        self.op_health = self.op_max
        self.op_standing = False
        wear(self, self.queue.pop(0))

    def walk_on(side):
        now = side.__dict__.get("now", 0)
        side.fallen.append((side.current_body, now))
        side.statuses = []
        side.curses = []
        if side.queue:
            nxt = side.queue.pop(0)
            side.qi = min(side.qi_cap, side.qi + nxt.get("store_qi", 0) * side.qi_max)
            wear(side, nxt)
            return
        op = spec_of(side).get("operator", {})
        if op.get("present") and not side.op_standing and side.op_health > 0:
            side.op_standing = True
            side.n_body = op.get("n_body", 1.0)
            side.health_max = side.op_max
            side.health = side.op_health
            g = op.get("guard", {})
            side.a_b, side.t_b, side.bg_pct = g.get("a_b", 0), g.get("t_b", 0), g.get("body_guard_pct", 0)
            side.companion = None
            side.comp_next = None
            return
        side.all_fallen = True

    def get_dry(self):
        if spec_of(self) and self.health <= 0 and not self.__dict__.get("op_standing") \
                and self.__dict__.get("thread_cut") is None and not self.__dict__.get("all_fallen"):
            walk_on(self)
        if earlier is not None:
            return earlier.fget(self)
        return self.__dict__.get("_dry_at")

    def set_dry(self, value):
        self.__dict__["_dry_at"] = value

    def resolve_art(att, dfn, art, t, gap):
        if art.get("soul_pct") and spec_of(dfn) and not dfn.__dict__.get("op_standing"):
            h, hm = dfn.health, dfn.health_max
            dfn.health, dfn.health_max = dfn.op_health, dfn.op_max
            taken = dfn.dmg_taken_instant
            original_resolve(att, dfn, art, t, gap)
            dfn.op_health = dfn.health
            dfn.health, dfn.health_max = h, hm
            dfn.dmg_taken_instant = taken
            if dfn.op_health <= 0:
                dfn.thread_cut = t
                dfn.health = 0
            return None
        return original_resolve(att, dfn, art, t, gap)

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        out = original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        if channel == "companion" and spec_of(att):
            # run_fight adds basic_cooldown after this call
            att.comp_next = t + interval(att) - f.ms(f.K["basic_cooldown"])
        return out

    def guard_true(g, own, enemy, t):
        if g and "bodies_fallen" in g:
            return len(own.__dict__.get("fallen", [])) >= g["bodies_fallen"]
        return original_guard(g, own, enemy, t)

    def next_event(sides, pulse_next, t):
        now = original_next(sides, pulse_next, t)
        for s in sides:
            s.now = now
        return now

    def report(res, build):
        original_report(res, build)
        a = res["a"]
        if spec_of(a):
            fell = ", ".join("%s at %.1f s" % (i, w / 1000.0) for i, w in a.fallen) or "none"
            print("body\tfallen: %s\tstanding: %s on %.0f%%\toperator's own bar %.0f%%%s" % (
                fell, "the operator" if a.op_standing else a.current_body,
                100 * max(a.health, 0) / a.health_max, 100 * max(a.op_health, 0) / a.op_max,
                "\tthread cut at %.1f s" % (a.thread_cut / 1000.0) if a.__dict__.get("thread_cut") is not None else ""))

    f.Side.__init__ = init
    f.Side.dry_at = property(get_dry, set_dry)
    f.resolve_art = resolve_art
    f.strike = strike
    f.guard_true = guard_true
    f.next_event = next_event
    f.report_result = report
