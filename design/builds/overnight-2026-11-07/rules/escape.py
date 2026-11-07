"""Escape, from Combat rule 10 (Escape), rule 13, rule 14 and Formulas I. Faithful, not a proposal.

FIGHT FILE FIELDS
  "rules": ["escape"]                  List it after any plug-in that owns Side.dry_at (below).

  On an art record, in "arts" or in enemy_overrides "arts":
    "escape": {"e_art": 0.55}          Marks an escape art. e_art is its base, 0.40 to 0.70 in Formulas I.
                                       Everything else is an ordinary art: cost_share, cooldown, stock,
                                       guard. Give it a guard (rule 13), or it fires on its first cooldown.
    "escape": {"e_art": 0.55, "bonus": 0.05}
                                       Optional: an escape-tag modifier on this one art.

  On a side (top level, or in enemy_overrides):
    "escape_bonus": 0.10               Modifiers with the escape tag. Art and side add, then held to 0 to 0.3.
    "khi_van": 60                      Fortune. Default 50 on both sides, so no shift unless a file says so.
    "lock": 1                          This side, as pursuer, has a lock tag. An art with "lock" in its
                                       "tags" counts too.
    "escape_roll": "expected"          Default. The roll is an expected value: each roll adds p to a
                                       running total, and the roll that takes the total to 1 succeeds.
                                       p 0.55 leaves on roll 2; p 0.30 on roll 4.
    "escape_roll": {"threshold": 0.5}  A stated threshold: a roll succeeds when p >= 0.5.
                                       {"threshold": 0} is the lucky run, every roll succeeds.
                                       {"threshold": 2} is the unlucky run, every roll fails, and its
                                       escape_odds line then gives the true chance of ever leaving.

WHAT IT DOES
  - An escape art pays its cost when it fires and opens a channel of escape_channel seconds. Hits keep
    landing. One channel a side: a ready escape art waits while one is open.
  - The channel's end is a scheduled event. Escapes resolve after both sides' hits and before the
    defeat check, requesting side first, and a side at 0 health or below does not roll.
  - A success ends the fight in FLIGHT: result "flight", winner None, with the side or sides that left
    on a "flight" line. If the other side is at 0 or below, the fleeing side wins by knockout instead.
  - A failure ends nothing. Cost, cooldown and stock stay spent, and the next ready escape art may fire
    in a follow-up instant at the same t.
  - A channel that would end after time_limit never rolls, so the stalemate stands.

OUTPUT
  result    flight   t=...  winner=None
  flight    fled=NAME    ended in flight: no winner, no knockout, no deciding layer
  escape_roll   NAME  t=  p=  left|failed|no roll (Down)
  escape_odds   NAME  rolls n  chance of having left by the last roll x %
  ESCAPE_NOT_RESOLVED if a channel ended and nothing rolled it: another plug-in took the hook.

HOOKS FOR OTHER PLUG-INS (install after this one)
  f.escape_terms(esc, pursuer, art, t)    dict of e_art, realm, lock, bonus, before bounds. Wrap to bend
                                          one term: the bonus limit and the 0.05 to 0.95 clamp still apply.
  f.escape_chance(esc, pursuer, art, t)   p for one roll, after bounds and fortune.
  f.escape_channel_ms(side, art)          the channel's length. Wrap to bend it.
  f.escape_on_channel(side, art, t)       called when a channel opens.
  f.escape_on_roll(side, art, p, ok, t)   called after each roll.
  side.esc_end, side.esc_log              the open channel's end (or None), and the rolls so far.

HOW IT HOOKS IN
  run_fight has no step between hits and the defeat check, but it reads each side's dry_at there, so
  dry_at is a property (the turned_away.py device). This one keeps any property already installed and
  calls it first, so it can be stacked on lit_wick, stands_over or turned_away if listed after them.
  A success raises f.Fled, which the wrapped run_fight turns into the result. Follow-up instants: the
  calculator only runs one after an art fired, so next_event returns the same t once when a ready
  escape art has come true (rule 10, Follow-up instants). No pulse or basic attack repeats.

Run `python escape.py --selftest` from anywhere: it checks the formula, the timeline rules and the GDD's
constants, and exits 1 on a failure.
"""
import os
import sys

# Values from Combat's tuning table and Formulas I; the selftest checks them against combat.md.
ESCAPE_CHANNEL = 1.0
ESCAPE_REALM_STEP = 0.10
ESCAPE_LOCK_PENALTY = 0.15
ESCAPE_BONUS_MAX = 0.3
KHI_VAN_PER_POINT = 0.001
P_MIN, P_MAX = 0.05, 0.95


def install(f):
    if getattr(f, "escape_installed", False):
        return
    f.escape_installed = True
    prior = f.Side.__dict__.get("dry_at")
    prior = prior if isinstance(prior, property) else None
    side_init, resolve_art, guard_true = f.Side.__init__, f.resolve_art, f.guard_true
    next_event, run_fight, report_result = f.next_event, f.run_fight, f.report_result
    state = {"sides": None, "now": 0, "live": False, "follow": set()}

    class Fled(Exception):
        def __init__(self, left, a, b, t, win):
            Exception.__init__(self)
            self.left, self.a, self.b, self.t, self.win = left, a, b, t, win

    f.Fled = Fled

    def has_lock(side):
        if side.spec.get("lock"):
            return 1
        return 1 if any("lock" in (a.get("tags") or []) for a in side.arts) else 0

    def escape_terms(esc, pursuer, art, t):
        """The terms of Formulas I, before any bound."""
        e = art["escape"]
        return {"e_art": e["e_art"],
                "realm": f.K.get("escape_realm_step", ESCAPE_REALM_STEP) * (esc.r - pursuer.r),
                "lock": f.K.get("escape_lock_penalty", ESCAPE_LOCK_PENALTY) * has_lock(pursuer),
                "bonus": esc.spec.get("escape_bonus", 0) + e.get("bonus", 0)}

    def escape_chance(esc, pursuer, art, t):
        """Formulas I. Fortune is added before the clamp, when p is not already 0 or 1."""
        v = f.escape_terms(esc, pursuer, art, t)
        p = v["e_art"] + v["realm"] - v["lock"] + min(max(v["bonus"], 0.0), ESCAPE_BONUS_MAX)
        if 0 < p < 1:
            p += (esc.spec.get("khi_van", 50) - pursuer.spec.get("khi_van", 50)) \
                * f.K.get("khi_van_per_point", KHI_VAN_PER_POINT)
        return min(P_MAX, max(P_MIN, p))

    def escape_channel_ms(side, art):
        return f.ms(f.K.get("escape_channel", ESCAPE_CHANNEL))

    f.escape_terms = escape_terms
    f.escape_chance = escape_chance
    f.escape_channel_ms = escape_channel_ms
    f.escape_on_channel = lambda side, art, t: None
    f.escape_on_roll = lambda side, art, p, ok, t: None

    def init(self, spec, name):
        side_init(self, spec, name)
        self.esc_end, self.esc_art, self.esc_log, self.esc_total = None, None, [], 0.0
        for a in self.arts:
            if a.get("escape"):
                a["guard"] = {"_escape": True, "inner": a.get("guard")}

    def guard(g, own, enemy, t):
        if g and g.get("_escape"):
            opened = any(a.get("escape") and a["fired"] and a["fired"][-1] == t for a in own.arts)
            return own.esc_end is None and not opened and f.guard_true(g["inner"], own, enemy, t)
        return guard_true(g, own, enemy, t)

    def resolve(att, dfn, art, t, gap):
        resolve_art(att, dfn, art, t, gap)
        if art.get("escape"):
            att.esc_end, att.esc_art = t + f.escape_channel_ms(att, art), art
            f.escape_on_channel(att, art, t)

    def succeeds(side, p):
        mode = side.spec.get("escape_roll", "expected")
        if isinstance(mode, dict):
            return p >= mode["threshold"] - 1e-12
        side.esc_total += p
        return side.esc_total >= 1 - 1e-9

    def resolve_escapes():
        a, b = state["sides"]
        now, left = state["now"], []
        for s, o in ((a, b), (b, a)):
            if s.esc_end is None or s.esc_end > now:
                continue
            art, s.esc_end = s.esc_art, None
            if s.health <= 0:
                s.esc_log.append((now, None, "no roll (Down)"))
                continue
            p = f.escape_chance(s, o, art, now)
            ok = succeeds(s, p)
            s.esc_log.append((now, p, "left" if ok else "failed"))
            f.escape_on_roll(s, art, p, ok, now)
            if ok:
                left.append(s)
        if left:
            others = [o for s, o in ((a, b), (b, a)) if s in left and o not in left and o.health <= 0]
            raise Fled(left, a, b, now, left[0] if others else None)

    def get_dry(self):
        value = prior.fget(self) if prior else self.__dict__.get("_dry_at")
        if state["live"]:
            resolve_escapes()
        return value

    def set_dry(self, value):
        if prior:
            prior.fset(self, value)
        else:
            self.__dict__["_dry_at"] = value

    def can_fire(s, o, art, t):
        if not art.get("escape") or art["ready"] > t or art.get("stock_left") == 0:
            return False
        if s.health <= 0 or not f.guard_true(art.get("guard"), s, o, t):
            return False
        raised = min(s.curse_sum("cost_raise"), f.K["curse_cost_raise_max"])
        return s.qi >= art.get("cost_share", 0) * (1 - s.cost_red) * (1 + raised) * s.qi_max - 1e-6

    def event(sides, pulse_next, t):
        state["sides"] = sides
        a, b = sides
        for s, o in ((a, b), (b, a)):
            for art in s.arts:
                key = (t, id(art))
                if can_fire(s, o, art, t) and key not in state["follow"]:
                    state["follow"].add(key)
                    state["now"] = t
                    return t
        out = next_event(sides, pulse_next, t)
        for s in sides:
            if s.esc_end is not None and s.esc_end > t:
                out = min(out, s.esc_end)
            for art in s.arts:
                inner = ((art.get("guard") or {}).get("inner") or {}) if art.get("escape") else {}
                if "time_above" in inner and f.ms(inner["time_above"]) > t:
                    out = min(out, f.ms(inner["time_above"]))
        state["now"] = out
        return out

    def fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        state.update(sides=None, now=0, live=True, follow=set())
        try:
            res = run_fight(a_spec, b_spec, gap_a, gap_b, record)
        except Fled as e:
            state["live"] = False
            a, b = e.a, e.b
            if e.win is not None:
                loser = b if e.win is a else a
                loser.health = 0.0
            if record is not None:
                record.append((e.t, max(a.health, 0) / a.health_max, a.qi / a.qi_max,
                               max(b.health, 0) / b.health_max, b.qi / b.qi_max))
            return {"end": "knockout" if e.win is not None else "flight", "t": e.t / 1000.0,
                    "winner": e.win.name if e.win is not None else None, "a": a, "b": b,
                    "fled": [s.name for s in e.left]}
        state["live"] = False
        return res

    def report(res, build):
        report_result(res, build)
        fled = res.get("fled")
        if fled and res["end"] == "flight":
            print("flight\tfled=%s\tended in flight: no winner, no knockout, no deciding layer"
                  % ",".join(fled))
        elif fled:
            print("flight\tfled=%s\tleft with the other side at 0: a knockout win (rule 10)" % ",".join(fled))
        for s in (res["a"], res["b"]):
            stay = 1.0
            rolls = 0
            for t, p, what in s.esc_log:
                if p is None:
                    print("escape_roll\t%s\tt=%.3f\t%s" % (s.name, t / 1000.0, what))
                    continue
                rolls += 1
                stay *= 1 - p
                print("escape_roll\t%s\tt=%.3f\tp=%.3f\t%s" % (s.name, t / 1000.0, p, what))
            if rolls:
                print("escape_odds\t%s\trolls %d\tchance of having left by the last roll %.1f %%"
                      % (s.name, rolls, 100 * (1 - stay)))
            if s.esc_end is not None and s.esc_end <= res["t"] * 1000 and not fled:
                print("ESCAPE_NOT_RESOLVED\t%s\ta channel ended at %.3f and nothing rolled it"
                      % (s.name, s.esc_end / 1000.0))

    f.Side.__init__ = init
    f.Side.dry_at = property(get_dry, set_dry)
    f.guard_true, f.resolve_art, f.next_event = guard, resolve, event
    f.run_fight, f.report_result = fight, report


# --- Selftest ------------------------------------------------------------------------------------

def selftest():
    here = os.path.dirname(os.path.abspath(__file__))
    repo = os.path.dirname(os.path.dirname(os.path.dirname(os.path.dirname(here))))
    sys.dont_write_bytecode = True
    sys.path.insert(0, os.path.join(repo, ".claude", "skills", "design-build", "scripts"))
    import fight_calc as f
    install(f)
    fails = []

    def eq(label, got, want):
        ok = got == want or (isinstance(want, float) and got is not None and abs(got - want) < 1e-6)
        print("%s\t%s\tgot %s\twant %s" % ("ok" if ok else "FAILED", label, got, want))
        if not ok:
            fails.append(label)

    text = open(os.path.join(repo, "design", "gdd", "combat.md"), encoding="utf-8").read()
    for anchor in ("| escape_channel | float | 1 s (guess)",
                   "| escape_realm_step, escape_lock_penalty | float | 0.10, 0.15 |",
                   "| escape_bonus | float | 0–0.3 |",
                   "| khi_van_per_point | float | 0.001 |",
                   "+ escape_bonus, 0.05, 0.95)"):
        eq("combat.md holds: " + anchor, anchor in text, True)

    def side(realm=0, **kw):
        d = {"name": kw.pop("name", "s"), "realm": realm, "ward": {"model": "default"},
             "basic": {"c": 0}, "arts": []}
        d.update(kw)
        return f.Side(d, "s")

    art = {"escape": {"e_art": 0.55}}
    eq("Formulas I example: 0.55, a realm below a locking pursuer",
       f.escape_chance(side(0), side(1, lock=1), art, 0), 0.30)
    eq("realm term, a realm above", f.escape_chance(side(1), side(0), art, 0), 0.65)
    eq("lock from an art tag", f.escape_chance(side(0), side(0, arts=[
        {"id": "x", "cooldown": 1, "tags": ["lock"]}]), art, 0), 0.40)
    eq("stops at 0.95", f.escape_chance(side(4, escape_bonus=0.3), side(0), art, 0), 0.95)
    eq("stops at 0.05", f.escape_chance(side(0), side(4, lock=1), {"escape": {"e_art": 0.4}}, 0), 0.05)
    eq("bonus held to 0.3", f.escape_chance(side(0, escape_bonus=0.9), side(0), art, 0), 0.85)
    eq("fortune lead of 30", f.escape_chance(side(0, khi_van=80), side(0), art, 0), 0.58)
    eq("fortune stops at the cap", f.escape_chance(side(0, khi_van=99, escape_bonus=0.3), side(0, khi_van=1),
                                                   {"escape": {"e_art": 0.7}}, 0), 0.95)

    def runner(share=0.0, roll="expected", hit=0.0, e=0.55, cd=1.0, stock=None, guard=None, cost=0.05,
               enemy_arts=None, n_body=1.0, runner_arts=None):
        esc = {"id": "run", "cooldown": cd, "cost_share": cost, "escape": {"e_art": e}}
        if stock is not None:
            esc["stock"] = stock
        if guard:
            esc["guard"] = guard
        a = {"name": "A", "realm": 0, "ward": {"model": "off"}, "basic": {"c": 0}, "n_body": n_body,
             "escape_roll": roll, "arts": runner_arts or [esc]}
        b = {"name": "B", "realm": 0, "ward": {"model": "off"}, "basic": {"c": hit},
             "n_body": 50, "arts": enemy_arts or []}
        return a, b

    r = f.run_fight(*runner(roll={"threshold": 0}))
    eq("a success ends in flight", r["end"], "flight")
    eq("no winner", r["winner"], None)
    eq("the result names who left", r["fled"], ["A"])
    eq("fires at 1, rolls after escape_channel, at 2", r["t"], 2.0)
    r = f.run_fight(*runner(roll="expected"))
    eq("expected: 0.55 needs two rolls", [x[2] for x in r["a"].esc_log], ["failed", "left"])
    eq("expected: the second roll is at 3", r["t"], 3.0)
    r = f.run_fight(*runner(roll="expected", e=0.40, cd=5.0))
    eq("a failed roll keeps its cooldown: rolls at 6, 11, 16", [x[0] for x in r["a"].esc_log],
       [6000, 11000, 16000])
    r = f.run_fight(*runner(roll={"threshold": 0.6}))
    eq("threshold above p: never leaves", r["end"], "stalemate")
    eq("a failed roll spends the cost: pool falls by cost then regen",
       len(r["a"].arts[0]["fired"]) > 3, True)
    eq("stock runs out", len(f.run_fight(*runner(roll={"threshold": 2}, stock=3))["a"].esc_log), 3)
    two = [{"id": "r1", "cooldown": 1, "cost_share": 0, "stock": 1, "escape": {"e_art": 0.4}},
           {"id": "r2", "cooldown": 1, "cost_share": 0, "stock": 1, "escape": {"e_art": 0.4}}]
    r = f.run_fight(*runner(roll={"threshold": 2}, runner_arts=two))
    eq("one channel at a time: the second art waits, then a follow-up at the same t",
       [r["a"].arts[0]["fired"], r["a"].arts[1]["fired"]], [[1000], [2000]])
    eq("two rolls, a second apart", [x[0] for x in r["a"].esc_log], [2000, 3000])
    r = f.run_fight(*runner(hit=1000, cd=1.5))
    eq("a lethal hit during the channel: damage first, no flight", r["end"], "knockout")
    eq("the runner is Down, and the winner is B", r["winner"], "B")
    r = f.run_fight(*runner(roll={"threshold": 0}, enemy_arts=[
        {"id": "k", "kind": "body", "c_art": 9999, "cost_share": 0, "cooldown": 2}]))
    eq("channel ending in the instant of a lethal hit: no roll", r["a"].esc_log[0][2], "no roll (Down)")
    r = f.run_fight(*runner(cd=39.5, roll={"threshold": 0}))
    eq("a roll past time_limit never happens", (r["end"], r["a"].esc_log), ("stalemate", []))
    r = f.run_fight(*runner(cd=39.0, roll={"threshold": 0}))
    eq("a roll at exactly time_limit resolves", (r["end"], r["t"]), ("flight", 40.0))

    both = runner(roll={"threshold": 0})
    both[1]["escape_roll"] = {"threshold": 0}
    both[1]["arts"] = [{"id": "run", "cooldown": 1, "cost_share": 0, "escape": {"e_art": 0.55}}]
    r = f.run_fight(*both)
    eq("both leave in one instant: flight, no winner", (r["end"], r["winner"], r["fled"]),
       ("flight", None, ["A", "B"]))

    a, b = runner(roll={"threshold": 0})
    a["arts"].append({"id": "hit", "kind": "body", "c_art": 9999, "cost_share": 0, "cooldown": 2})
    a["layers"] = [0, 0, 0, 0, 0]
    b["n_body"] = 1.0
    r = f.run_fight(a, b)
    eq("the other side at 0 as you leave: a knockout win", (r["end"], r["winner"]), ("knockout", "A"))

    a, b = runner(roll={"threshold": 0}, guard={"who": "own", "pool": "health", "below": 0.5}, hit=9, n_body=1.0)
    r = f.run_fight(a, b)
    eq("a health guard made true by a basic attack fires at that t (follow-up)",
       r["a"].arts[0]["fired"], [1000])
    eq("and rolls one channel later", r["t"], 2.0)
    a, b = runner(roll={"threshold": 0}, guard={"who": "own", "pool": "health", "below": 0.5}, hit=9999, n_body=1.0)
    r = f.run_fight(a, b)
    eq("full health to 0 in one hit: the escape art never fires", r["a"].arts[0]["fired"], [])
    a, b = runner(roll={"threshold": 0}, guard={"time_above": 7.25})
    eq("a time guard wakes the art at its millisecond", f.run_fight(a, b)["a"].arts[0]["fired"], [7250])
    a, b = runner(roll={"threshold": 0}, cost=1.5)
    eq("an art it cannot pay for never fires", f.run_fight(a, b)["end"], "stalemate")

    print("selftest\t%s" % ("all checks matched" if not fails else "%d FAILED" % len(fails)))
    return not fails


if __name__ == "__main__":
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    sys.exit(0 if selftest() else 1)
