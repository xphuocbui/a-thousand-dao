"""Mechanism tests for engine.py, one per GDD acceptance criterion it implements.

Run: python -I tools/design/combat_sim/test_engine.py     (exit 1 on any failure)
"""
import math
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import engine as E  # noqa: E402

FAIL = []


def check(name, cond, detail=""):
    print(("PASS  " if cond else "FAIL  ") + name + ("" if cond else "  " + detail))
    if not cond:
        FAIL.append(name)


def dummy(**kw):
    kw.setdefault("arts", [])
    kw.setdefault("crit", 0.0)
    return E.Build("dummy", **kw)


def setup(a=None, b=None):
    f = E.Fight(a or dummy(), b or dummy(), seed=3)
    return f, f.A, f.B


def t_delay_falloff():   # AC-EF-71
    f, A, B = setup(b=dummy(arts=[E.Art("x", 1.0, 0.05, 4.0)]))
    e = {"id": "d", "on": "always", "do": []}
    base = B.ready[0]
    for _ in range(3):
        f.do(A, e, [{"timer": {"side": "foe", "by": 1.0}}], 1.0, {})
    check("AC-EF-71 delay falloff 1 + 0.5 + 0.25 s", B.ready[0] - base == 1750, str(B.ready[0] - base))
    f, A, B = setup(b=dummy(timer_resist=20, arts=[E.Art("x", 1.0, 0.05, 4.0)]))
    base = B.ready[0]
    f.do(A, e, [{"timer": {"side": "foe", "by": 1.0}}], 1.0, {})
    check("AC-EF-71 timer resistance 20 -> 0.8 s", B.ready[0] - base == 800, str(B.ready[0] - base))


def t_slowed_time():     # AC-EF-72
    f, A, B = setup()
    for _ in range(6):
        f.apply_status(A, B, {"id": "slowed_time"})
    check("AC-EF-72 Slowed Time 5 stacks -> x1.30", abs(f.slow(B) - 1.30) < 1e-9 and B.st("slowed_time") == 5, str(f.slow(B)))


def t_refusal_budget():  # AC-EF-75
    ref = lambda i: {"id": i, "on": "down", "limit": {"per_fight": 1}, "do": [{"refuse_down": True}]}
    f, A, B = setup(a=dummy(effects=[ref("r1"), ref("r2")]))
    A.hp = -5
    f.defeat_check()
    first = (not A.down) and A.hp == 1
    A.hp = -5
    f.defeat_check()
    check("AC-EF-75 one refusal per fight", first and A.down)
    f, A, B = setup(a=dummy(refusals=2, effects=[ref("r1"), ref("r2")]))
    A.hp = -1; f.defeat_check(); A.hp = -1; f.defeat_check(); two = not A.down
    A.hp = -1; f.defeat_check()
    check("AC-EF-75 'twice' capstone: two refusals", two and A.down)


def t_cull():            # AC-EF-76
    cull = {"id": "cull", "on": "always", "do": [{"cull": 0.08}]}
    ref = {"id": "r", "on": "down", "limit": {"per_fight": 1}, "do": [{"refuse_down": True}]}
    f, A, B = setup(a=dummy(effects=[cull]), b=dummy(effects=[ref]))
    B.hp = 0.07 * B.hp_max
    f.defeat_check()
    saved = not B.down and B.hp == 1
    f.defeat_check()
    check("AC-EF-76 cull refused once, then culled", saved and B.down)


def t_curse_clamp():     # AC-EF-77
    f, A, B = setup()
    f.apply_status(A, B, {"id": "sundered", "dur": 6})
    check("AC-EF-77 curse clamp to 5 pulses", B.statuses["sundered"]["until"] == 5000)
    f.apply_status(A, B, {"id": "exposed", "dur": 0.4})
    check("AC-EF-77 curse floor 1 pulse", B.statuses["exposed"]["until"] == 1000)


def t_curse_slots():
    f, A, B = setup()
    for sid in ("sundered", "exposed", "withering", "heavy_breath"):
        f.apply_status(A, B, {"id": sid})
    check("3 curse slots", "heavy_breath" not in B.statuses and len(B.statuses) == 3)


def t_strip_steal():     # AC-EF-73
    f, A, B = setup()
    B.buffs = [["fire", 2, 5000, B], ["fire", 4, 9000, B]]
    e = {"id": "s", "on": "always", "do": []}
    f.do(A, e, [{"strip": {"n": 3, "el": "fire", "steal": True}}], 1.0, {})
    check("AC-EF-73 strip oldest first, steal", B.count(B.buffs, "fire") == 3 and A.count(A.buffs, "fire") == 3)


def t_consume():         # AC-EF-74
    f, A, B = setup()
    B.debuffs = [["ice", 6, 9000, A]]
    got = {}
    e = {"id": "c", "on": "always", "do": []}
    f.do(A, e, [{"consume": {"el": "ice", "side": "foe", "n": 10, "then": [{"gain_qi": {"share": 0.01}}]}}], 1.0, {})
    check("AC-EF-74 consume takes 6 of 6", B.count(B.debuffs, "ice") == 0)


def t_granted_min_batch():  # AC-EF-78
    f, A, B = setup()
    f.add_stacks(A, B, "fire", 3, 1.0, buff=False)
    check("AC-EF-78 a 1-pulse batch lasts 2", B.debuffs[0][2] == 2000)


def t_held():            # AC-EF-79
    held = {"id": "h", "on": "crit", "held": {"until": "art_fired"}, "do": [{"mod": {"L5": 20}}]}
    f, A, B = setup(a=dummy(effects=[held]))
    f.fire_event(A, "crit", {})
    banked = len(A.banked) == 1 and f.mod(A, "L5") == 20
    f.spend_banked(A, "art_fired", {})
    check("AC-EF-79 held payload banked, then spent", banked and not A.banked and f.mod(A, "L5") == 0)


def t_trigger_budget():  # Combat Formulas G
    trig = {"id": "t", "on": "hit_landed", "do": [{"free_hit": {"c": 0.8}}]}
    f, A, B = setup(a=dummy(effects=[trig], M=3.0), b=dummy(ward_pts=0, block=0))
    A.direct_dmg = 10.0
    e = trig
    for _ in range(10):
        f.do(A, e, e["do"], 1.0, {})
    check("Formulas G trigger budget and trig_cap", A.trig_dmg <= 0.5 * 10.0 + 1e-6 and A.trig_count <= 6,
          "dmg %.2f count %d" % (A.trig_dmg, A.trig_count))


def t_ward_absorbed():   # Effects rule 5, world-depth Stage 5 (2026-11-26)
    soaked = {"id": "ws", "on": "ward_absorbed", "do": [{"counter": {"id": "soak", "add": 1}}]}
    f, A, B = setup(b=dummy(ward_pts=0, block=0, shields=[E.Shield(size=300 / (26 * E.U[0] * 1.053))],
                            effects=[soaked], counters=[{"id": "soak"}]))
    B.wshields[0]["left"] = 300.0
    seen = []
    orig = f.fire_event
    f.fire_event = lambda s, name, ev: (seen.append((name, ev.get("amount"))) if name == "ward_absorbed" else None, orig(s, name, ev))[1]
    f.defend(A, B, 120.0, "phys", None, {}, is_tick=False)
    f.defend(A, B, 50.0, "fire", None, {}, is_tick=True)   # a tick: no event
    check("ward_absorbed fires once per hit with the soaked amount", seen == [("ward_absorbed", 120.0)] and B.counters["soak"] == 1, str(seen))
    f, A, B = setup(b=dummy(ward_pts=0, block=0, effects=[soaked], counters=[{"id": "soak"}]))
    f.defend(A, B, 120.0, "phys", None, {}, is_tick=False)
    check("no ward, no ward_absorbed", B.counters["soak"] == 0)


def t_stop_clock():      # Effects rule 6, world-depth Stage 5 (2026-11-26)
    f, A, B = setup(b=dummy(arts=[E.Art("x", 1.0, 0.05, 4.0)]))
    e = {"id": "s", "on": "always", "do": []}
    f.t = 500
    r0, b0 = B.ready[0], B.basic_ready
    B.debuffs.append(["fire", 2, 3000, A, 2500])
    B.debuffs.append(["fire", 1, None, A, None])
    f.do(A, e, [{"stop_clock": {"side": "foe", "seconds": 2.0}}], 1.0, {})
    check("stop_clock moves the foe's timers 2 s", B.ready[0] - r0 == 2000 and B.basic_ready == max(b0, 500) + 2000, "%d %d" % (B.ready[0] - r0, B.basic_ready))
    check("stop_clock moves stack timers, not fight-long batches", B.debuffs[0][2] == 5000 and B.debuffs[1][2] is None)
    f, A, B = setup(b=dummy(timer_resist=25, arts=[E.Art("x", 1.0, 0.05, 4.0)]))
    r0 = B.ready[0]
    f.do(A, e, [{"stop_clock": {"side": "foe", "seconds": 2.0}}], 1.0, {})
    check("timer resistance 25 shortens a stop to 1.5 s", B.ready[0] - r0 == 1500, str(B.ready[0] - r0))


def t_heal_overflow():   # Effects rule 5, world-depth Stage 5 (2026-11-26)
    f, A, B = setup()
    A.hp = A.hp_max - 10.0
    got = []
    orig = f.fire_event
    f.fire_event = lambda s, name, ev: (got.append(ev) if name == "heal_restored" else None, orig(s, name, ev))[1]
    f.heal(A, 25.0)
    check("heal_restored reports the overflow lost to full health", got and abs(got[0]["amount"] - 10.0) < 1e-9 and abs(got[0]["overflow"] - 15.0) < 1e-9, str(got))


def t_counter_decay_share():   # Effects rule 19's closes, world-depth Stage 5 (2026-11-26)
    f, A, B = setup(a=dummy(counters=[{"id": "store", "decay_share": 0.1}]))
    A.counters["store"] = 50.0
    f.pulse(A)
    check("a counter decays by its share each pulse", abs(A.counters["store"] - 45.0) < 1e-9, str(A.counters["store"]))


def t_event_alias():     # combat_engine.json EVENT_ALIAS (2026-11-26)
    b = dummy(effects=[{"id": "w", "on": "batch_expired", "do": []}, {"id": "h", "on": "healed", "do": []}])
    E.validate(b)
    check("batch_expired and healed load as batch_ended and heal_restored", [e["on"] for e in b.effects] == ["batch_ended", "heal_restored"])


# ---- world-depth Stage 5 slice 3 (2026-11-26): qi_drained, the leech source, lost_last, charge hours
def t_qi_drained():
    drain = {"id": "d", "on": "hit_landed", "do": [{"burn_qi": {"share": 0.1, "of": "max", "to_self": 0.5}}]}
    bank = {"id": "b", "on": "qi_drained", "scale": {"read": "event.amount", "per": 1}, "do": [{"counter": {"id": "catch", "add": 1}}]}
    f, A, B = setup(a=dummy(effects=[drain, bank], counters=[{"id": "catch"}]), b=dummy(ward_pts=0, block=0))
    A.qi = 0.5 * A.qi_max()
    q0, b0 = A.qi, B.qi
    f.hit(A, B, 0.01, "phys", None)
    moved = 0.1 * B.qi_max()
    check("a drain burns the foe's linh luc and moves half to you", abs(B.qi - (b0 - moved)) < 1e-9 and abs(A.qi - (q0 + moved / 2)) < 1e-9)
    check("qi_drained reports the points moved (scale counts whole points)", A.counters["catch"] == math.floor(moved / 2),
          "%s vs %s" % (A.counters["catch"], moved / 2))


def t_leech_source():
    count = {"id": "l", "on": "heal_restored", "filter": {"source": "leech"}, "do": [{"counter": {"id": "leeched", "add": 1}}]}
    f, A, B = setup(a=dummy(effects=[count], counters=[{"id": "leeched"}], leech_hp=0.2), b=dummy(ward_pts=0, block=0))
    A.hp = A.hp_max * 0.5
    f.hit(A, B, 1.0, "phys", None)
    f.heal(A, 10.0)
    check("a leech heal carries the source leech; another heal does not", A.counters["leeched"] == 1.0, str(A.counters["leeched"]))


def t_lost_last():
    f, A, B = setup()
    f.t = 1000
    f.pulse(A)              # the first pulse sets the baseline
    for t, hp_drop, qi_drop in [(2000, 30.0, 5.0), (3000, 20.0, 0.0), (4000, 10.0, 2.0)]:
        A.hp -= hp_drop
        A.qi -= qi_drop
        f.t = t
        f.pulse(A)
    A.hp -= 7.0              # since the last pulse
    lost3 = f.read(A, "own.lost_last.hp.3")
    check("lost_last: the last 3 s of pulses plus since the last pulse", abs(lost3 - (30 + 20 + 10 + 7)) < 1e-6, str(lost3))
    check("lost_last over 2 s", abs(f.read(A, "own.lost_last.hp.2") - (20 + 10 + 7)) < 1e-6, str(f.read(A, "own.lost_last.hp.2")))


def t_charge_hours():
    f, A, B = setup(a=dummy(counters=[{"id": "ring", "each_for": 12}]))
    for t in (1000, 2000, 6000, 11000):
        f.t = t
        f.do(A, {"id": "lay", "on": "always", "do": []}, [{"counter": {"id": "ring", "add": 1}}], 1.0, {})
    f.t = 11500
    check("charges laid in hours 0, 1 and 2: three distinct hours", f.read(A, "own.counter_hours.ring") == 3.0)
    check("one charge laid in the current hour (2)", f.read(A, "own.counter_this_hour.ring") == 1.0)


def t_burn_pill():   # Pill Smoke, smoke only (user 2026-11-26)
    burn = {"id": "p", "on": "always", "do": []}
    seen = []
    f, A, B = setup(a=dummy(pill={"element": "fire", "grade": 2}))
    orig = f.fire_event
    f.fire_event = lambda s, name, ev: (seen.append(ev) if name == "pill_burned" else None, orig(s, name, ev))[1]
    f.do(A, burn, [{"burn_pill": {}}], 1.0, {})
    check("a grade-2 Fire pill smokes 8 Fire stacks onto the foe for 6 s",
          B.count(B.debuffs, "fire") == 8 and B.debuffs[0][2] == f.t + 6000, str(B.debuffs))
    check("pill_burned reports element, grade and success", seen == [{"element": "fire", "grade": 2.0, "failed": 0.0}], str(seen))
    f.do(A, burn, [{"burn_pill": {}}], 1.0, {})
    check("one pill a fight", B.count(B.debuffs, "fire") == 8 and len(seen) == 1)
    f, A, B = setup(a=dummy(pill={"element": "water", "grade": 1, "fail": 1.0}))
    seen.clear()
    f.fire_event = lambda s, name, ev: (seen.append(ev) if name == "pill_burned" else None, orig(s, name, ev))[1]
    f.do(A, burn, [{"burn_pill": {}}], 1.0, {})
    check("a failed Water pill still smokes, as Ice", B.count(B.debuffs, "ice") == 4 and seen[0]["failed"] == 1.0, str(seen))
    f, A, B = setup()
    f.do(A, burn, [{"burn_pill": {}}], 1.0, {})
    check("with no pill nothing happens", not B.debuffs)


# ---- world-depth Stage 5 slice 8a (2026-11-26): the art-format words, part one
def t_vocab_8a():
    check("filter not_art_id", not E.match({"not_art_id": "thorn"}, {"art_id": "thorn"}) and E.match({"not_art_id": "thorn"}, {"art_id": "x"}))
    # fire_art: the last art of an element (Bronze Answers)
    seen = []
    arts = [E.Art("metal-cut", 1.0, 0.01, 2.0, element="metal"), E.Art("fire-cut", 1.0, 0.01, 2.0, element="fire")]
    f, A, B = setup(a=dummy(arts=list(arts)), b=dummy(ward_pts=0, block=0))
    A.fire_log = [[0, "metal-cut", (), ""], [1, "fire-cut", (), ""]]
    orig = f.hit
    f.hit = lambda att, dfn, c, dtype, art, **kw: (seen.append(art.name if art else None), orig(att, dfn, c, dtype, art, **kw))[1]
    f.do(A, {"id": "x", "on": "always", "do": []}, [{"fire_art": {"which": "last", "filter": {"element": "metal"}, "share": 0.6}}], 1.0, {})
    check("fire_art filter element: the last Metal art, not the last art", seen == ["metal-cut"], str(seen))
    # a debuff laid on yourself, and tick_taken (Into the Vent)
    took = []
    f, A, B = setup()
    f.do(A, {"id": "x", "on": "always", "do": []}, [{"stacks": {"el": "fire", "n": 10, "for": 6, "side": "own", "kind": "debuff"}}], 1.0, {})
    check("stacks kind debuff on side own: a Burn on yourself", A.count(A.debuffs, "fire") == 10 and not A.buffs)
    orig_fe = f.fire_event
    f.fire_event = lambda s, name, ev: (took.append(s.label) if name == "tick_taken" else None, orig_fe(s, name, ev))[1]
    f.t = 1000
    f.pulse(A)
    check("its tick lands on you and raises tick_taken for you", took and took[0] == "A", str(took))
    # free_hit pass_shields
    lost = []
    for ps in (False, True):
        f, A, B = setup(b=dummy(ward_pts=0, block=0, shields=[E.Shield(size=1.0)]))
        B.wshields[0]["left"] = 1e9
        hp = B.hp
        f.do(A, {"id": "x", "on": "always", "do": []}, [{"free_hit": {"c": 1.0, "pass_shields": ps}}], 1.0, {})
        lost.append(hp - B.hp)
    check("free_hit pass_shields skips ward shields", lost[0] == 0 and lost[1] > 0, str(lost))
    # own.tech_layer.<id>
    f, A, B = setup(a=dummy(tech_layers={"withered-branch": 9}))
    check("own.tech_layer reads a technique's layer", f.read(A, "own.tech_layer.withered-branch") == 9 and f.read(A, "own.tech_layer.x") == 0)
    # counted curses (Black Under White)
    count = {"id": "bw", "on": "always", "do": [{"mod": {"counted_curse_per": 5, "element": "ice"}}]}
    f, A, B = setup(a=dummy(effects=[count]))
    f.add_stacks(A, B, "ice", 12, 10.0, buff=False)
    check("12 of your Ice stacks on the foe count as 2 curses", f.read(A, "foe.curses") == 2 and f.read(B, "own.curses") == 0,
          "%s %s" % (f.read(A, "foe.curses"), f.read(B, "own.curses")))


def piece_build(**kw):
    """A piece (slice 8b; Nine Shao, the Remnant Score): "next" plays movements 1-3 in order; in turn advances the
    counter, out of turn (past the last) restarts it; 2 lays a Shao stack on the foe, 3 makes the next piece art free."""
    arts = [E.Art("next", 0.5, 0.04, 2.0, group="g", tags=("song",), movement_counter="m",
                  movements=[{"n": 1, "do": []},
                             {"n": 2, "do": [{"counter": {"id": "shao", "side": "foe", "add": 1}}]},
                             {"n": 3, "do": [{"mod": {"next_art_cost": 0, "group": "g"}}]}])]
    effects = [{"id": "adv", "on": "art_fired", "filter": {"group": "g"}, "if": [{"read": "event.in_turn", "op": "==", "value": 1}],
                "do": [{"counter": {"id": "m", "add": 1}}]},
               {"id": "brk", "on": "art_fired", "filter": {"tags": ["song"]}, "if": [{"read": "event.in_turn", "op": "==", "value": 0}],
                "do": [{"counter": {"id": "m", "set": 0}}]}]
    return dummy(arts=arts, effects=effects, counters=[{"id": "m"}], **kw)


def t_movements():   # slice 8b (2026-11-26; Nine Shao, the Remnant Score)
    f = E.Fight(piece_build(), dummy(), seed=3, parity=True, order="fixed")
    f.run()
    mv = [r[4] for r in f.plog if r[0] == "movement" and r[2] == "A"]
    check("movements play 1, 2, 3; past the last nothing plays and the piece restarts", mv[:6] == [1, 2, 3, 1, 2, 3], str(mv[:8]))
    arts = [r for r in f.plog if r[0] == "art" and r[2] == "A"]
    check("the restarting firing plays nothing: 4 firings per 3 movements", len(arts) >= 8 and arts[3][1] < [r for r in f.plog if r[0] == "movement" and r[2] == "A"][3][1])
    check("movement 2 lays Shao stacks on the foe, a plain counter there", f.B.counters.get("shao", 0) >= 2, str(f.B.counters))
    check("after the third movement the next piece art costs nothing", arts[3][4] == 0.0 and arts[2][4] > 0, str(arts[:5]))
    check("and the one after pays again", arts[4][4] > 0)
    a = f.A.b.arts[0]
    check("match reads group", E.match({"group": "g"}, E.art_ctx(a)) and not E.match({"group": "h"}, E.art_ctx(a)))
    try:
        E.Fight(dummy(arts=[E.Art("x", 0.5, 0.04, 2.0, movements=[{"n": 1, "do": []}], movement_counter="nope")]), dummy())
        check("an undefined movement counter is refused", False)
    except E.EngineError:
        check("an undefined movement counter is refused", True)


def t_kept_meter():   # slice 8b (2026-11-26; Playing Past the Break): a counted chance kept between fights
    att = {"id": "eighth", "on": "art_fired", "do": [{"meter": {"id": "brk", "success": [{"gain_qi": {"share": 0.1}}],
                                                                "failure": [{"stacks": {"el": "fire", "n": 1, "for": 5, "side": "own", "kind": "debuff"}}]}}]}
    f = E.Fight(dummy(arts=[E.Art("x", 0.5, 0.04, 2.0)], effects=[att], meters={"brk": {"start": 0.6, "p": 0.3}}), dummy(),
                seed=3, parity=True, order="fixed")
    f.run()
    rows = [(r[4], r[5]) for r in f.plog if r[0] == "meter"]
    check("0.6 + 0.3 fails (900), then succeeds (1200 - 1000 = 200), then 500, 800, 1100 - 1000", rows[:5] == [(0, 900), (1, 200), (0, 500), (0, 800), (1, 100)], str(rows[:6]))
    check("the end value is the meter left", f.A.meters["brk"] == rows[-1][1])
    g = E.Fight(dummy(arts=[E.Art("x", 0.5, 0.04, 2.0)], effects=[att]), dummy(), seed=3, parity=True, order="fixed")
    g.run()
    check("without the meter no attempt is made", not [r for r in g.plog if r[0] == "meter"])


def t_spend_charges():   # regression (2026-11-26): a negative add or a set on an each_for counter did nothing
    f, A, B = setup(a=dummy(counters=[{"id": "seal", "each_for": 10}]))
    e = {"id": "x", "on": "always", "do": []}
    for t in (1000, 2000, 3000, 4000):
        f.t = t
        f.do(A, e, [{"counter": {"id": "seal", "add": 1}}], 1.0, {})
    f.do(A, e, [{"counter": {"id": "seal", "add": -2}}], 1.0, {})
    check("spending 2 charges removes the 2 nearest their end", A.counter_times["seal"] == [13000, 14000], str(A.counter_times["seal"]))
    f.do(A, e, [{"counter": {"id": "seal", "add": -5}}], 1.0, {})
    check("spending more than are held empties it", A.counter_times["seal"] == [])
    for t in (5000, 6000, 7000):
        f.t = t
        f.do(A, e, [{"counter": {"id": "seal", "add": 1}}], 1.0, {})
    f.do(A, e, [{"counter": {"id": "seal", "set": 1}}], 1.0, {})
    check("set 1 keeps the newest charge", A.counter_times["seal"] == [17000], str(A.counter_times["seal"]))
    f.do(A, e, [{"counter": {"id": "seal", "set": 0}}], 1.0, {})
    check("set 0 clears it", A.counter_times["seal"] == [])


def t_hit_carries_group():   # regression (2026-11-26, Twin Plums): hit events carry the art's technique
    eff = {"id": "g", "on": "hit_landed", "filter": {"group": "snow-plum-sword"}, "do": [{"counter": {"id": "n", "add": 1}}]}
    f, A, B = setup(a=dummy(effects=[eff], counters=[{"id": "n"}]))
    cut = E.Art("cut", 1.0, 0.03, 3.0, group="snow-plum-sword")
    f.hit(A, B, 1.0, "cold", cut)
    check("a hit_landed filter on group matches the art's technique", A.counters["n"] == 1, str(A.counters))
    f.hit(A, B, 1.0, "cold", E.Art("other", 1.0, 0.03, 3.0, group="else"))
    check("an art of another technique does not match", A.counters["n"] == 1, str(A.counters))


def t_move_own_debuffs():   # Move the Sickness (2026-11-26)
    f, A, B = setup()
    f.add_stacks(B, A, "fire", 3, 8.0, buff=False)
    f.t = 1000
    f.add_stacks(B, A, "wood", 4, 8.0, buff=False)
    f.apply_status(B, A, {"id": "sundered", "stacks": 2})
    A.qi = A.qi_max()
    f.move_own_debuffs(A, 0.005)
    check("all moved to the foe as A's own, with their time", A.count(A.debuffs, "fire") == 0 and B.count(B.debuffs, "fire") == 3
          and B.count(B.debuffs, "wood") == 4 and B.debuffs[0][3] is A and B.debuffs[0][2] == 8000 and B.st("sundered") == 2
          and "sundered" not in A.statuses, str(B.debuffs))
    check("each stack paid 0.5 % of maximum linh luc (9 stacks)", abs(A.qi - A.qi_max() * (1 - 9 * 0.005)) < 1e-9)
    f, A, B = setup()
    f.add_stacks(B, A, "fire", 3, 8.0, buff=False)
    f.t = 1000
    f.add_stacks(B, A, "wood", 4, 8.0, buff=False)
    A.qi = A.qi_max() * 0.005 * 5
    f.move_own_debuffs(A, 0.005)
    check("it stops at the first stack it cannot pay for: the oldest 3 Fire, then 2 of 4 Wood",
          B.count(B.debuffs, "fire") == 3 and B.count(B.debuffs, "wood") == 2 and A.count(A.debuffs, "wood") == 2, str(B.debuffs))
    f, A, B = setup()
    for sid in ("sundered", "exposed", "withering"):
        f.apply_status(A, B, {"id": sid})
    f.apply_status(B, A, {"id": "heavy_breath"})
    A.qi = A.qi_max()
    f.move_own_debuffs(A, 0.005)
    check("a curse with no free slot on the foe stays", "heavy_breath" in A.statuses and "heavy_breath" not in B.statuses)


def t_root_gates():   # requires.root_has / root_lacks (2026-11-26; Bronze Answers, Dawn Call)
    import fight as F
    arts_lib, _ = F._library()
    aid = sorted(arts_lib)[0]
    old = arts_lib[aid].get("requires")
    try:
        build = lambda pur: F.expand_library({"name": "t", "realm": "luyen_khi", "arts": [{"lib": aid}], "purity": pur})
        arts_lib[aid]["requires"] = {"root_lacks": "thunder"}
        check("root_lacks thunder: a Metal root slots it", [a["id"] for a in build({"metal": 40})["arts"]] == [aid])
        d = build({"metal": 40, "thunder": 20})
        check("a Thunder root does not, and the build says why", d["arts"] == [] and any("without thunder" in u for u in d.get("unmodelled", [])),
              str(d.get("unmodelled")))
        arts_lib[aid]["requires"] = {"root_has": "light"}
        check("root_has light needs a Light root", build({"light": 30})["arts"] != [] and build({"fire": 30})["arts"] == [])
    finally:
        if old is None:
            arts_lib[aid].pop("requires", None)
        else:
            arts_lib[aid]["requires"] = old


# ---- world-depth Stage 5 slice 7 (2026-11-26): kept request tags (Combat rule 12, AC-CB-104)
def t_request_tags():
    trib = {"id": "t", "on": "always", "if": [{"read": "tag.tribulation", "op": ">=", "value": 1}], "do": [{"mod": {"block": 7}}]}
    f = E.Fight(dummy(effects=[trib]), dummy(), seed=3, tags=("tribulation", "own_abode", "vein"))
    check("tribulation is kept and read; place tags are not kept", f.tags == {"tribulation"} and f.mod(f.A, "block") == 7, str(f.tags))
    g = E.Fight(dummy(effects=[trib]), dummy(), seed=3)
    check("with no tag the rule sees nothing", g.mod(g.A, "block") == 0)


# ---- world-depth Stage 5 slice 5 (2026-11-26): the duel readings (Combat rule 25, Formulas L, its Example)
def t_readings():
    f, A, B = setup()
    r = lambda s, k: f.read(s, "own." + k)
    check("at the start nothing has acted: not Composed yet, nor Pressing", r(A, "composed") == 0 and r(A, "pressing") == 0)
    f.t = 2000
    check("Composed from 2 s with no act", r(A, "composed") == 1)
    f.t = 3100
    A.t_act = 3100                      # a damaging art at 3.100 s (as the act loop sets it)
    f.t = 4000
    check("3.1-5.1 s: neither Composed nor Pressing (a damaging art is not a move)", r(A, "composed") == 0 and r(A, "pressing") == 0)
    check("its foe reads foe_pressed until 4.099 s", r(B, "foe_pressed") == 1)
    f.t = 4100
    check("and not from 4.100 s", r(B, "foe_pressed") == 0)
    f.t = 5600
    check("Composed from 5.100 s; composed_time 0.5 at 5.600 s", r(A, "composed") == 1 and abs(r(A, "composed_time") - 0.5) < 1e-9)
    f.t = 6000
    A.t_act = A.t_move = 6000          # an evade at 6.000 s
    f.t = 6999
    check("the evade: Pressing until 6.999 s, not Composed", r(A, "pressing") == 1 and r(A, "composed") == 0)
    f.t = 7000
    check("Pressing ends at 7.000 s", r(A, "pressing") == 0)
    check("since_act 1.0 s", abs(r(A, "since_act") - 1.0) < 1e-9)


def t_reading_stances():
    states = [{"id": "still", "tags": ["composed"], "mods": {}}, {"id": "mist", "tags": ["field"], "mods": {}}]
    f, A, B = setup(a=dummy(states=states))
    f.t = 1000
    A.t_act = 1000
    f.do(A, {"id": "s", "on": "always", "do": []}, [{"state": {"set": "still"}}], 1.0, {})
    f.t = 1500
    check("a composed stance: Composed at once, composed_time from its start", f.read(A, "own.composed") == 1
          and abs(f.read(A, "own.composed_time") - 0.5) < 1e-9)
    f.do(A, {"id": "s", "on": "always", "do": []}, [{"state": {"set": "mist"}}], 1.0, {})
    check("a field stance: field_up", f.read(A, "own.field_up") == 1 and f.read(B, "own.field_up") == 0)


def t_broken_wounded():
    seen = []
    f, A, B = setup(b=dummy(ward_pts=0, block=0))
    orig = f.fire_event
    f.fire_event = lambda s, name, ev: (seen.append((s.label, name)) if name in ("broken", "wounded") else None, orig(s, name, ev))[1]
    B.hp = 0.3 * B.hp_max
    f.hit(A, B, 0.01, "phys", None)
    check("above 25 %: nothing", seen == [])
    B.hp = 0.26 * B.hp_max
    f.hit(A, B, 2.0, "phys", None)
    check("the crossing: B is Wounded and A has Broken it", seen == [("B", "wounded"), ("A", "broken")], str(seen))
    check("read as broken (A) and wounded (B)", f.read(A, "own.broken") == 1 and f.read(B, "own.wounded") == 1)
    B.hp = 0.5 * B.hp_max
    B.hp = 0.1 * B.hp_max
    f.hit(A, B, 0.01, "phys", None)
    check("once a fight", len(seen) == 2)


# ---- world-depth Stage 5 slice 4 (2026-11-26): Light, companion tags, talisman stacks held fast
def t_light():
    lost = []
    for resist in ({}, {"light": 300.0}):
        f, A, B = setup(b=dummy(ward_pts=0, block=0, resist=resist))
        hp = B.hp
        f.hit(A, B, 1.0, "light", E.Art("dawn", 1.0, 0.05, 3.0, element="light", dtype="light"))
        lost.append(hp - B.hp)
    check("a Light hit lands, and Light resistance cuts it", lost[0] > 0 and lost[1] < lost[0], str(lost))


def t_companion_tags():
    count = {"id": "c", "on": "hit_landed", "filter": {"tags": ["crane"]}, "do": [{"counter": {"id": "crane_hits", "add": 1}}]}
    f, A, B = setup(a=dummy(effects=[count], counters=[{"id": "crane_hits"}],
                            companions=[{"c": 0.3, "dtype": "phys", "cd": 1.0, "tags": ["crane", "bird"]},
                                        {"c": 0.3, "dtype": "phys", "cd": 1.0}]))
    f.t = 1000
    A.comp_ready = [1000, 1000]
    f.act(A)
    check("only the crane companion's hit carries crane", A.counters["crane_hits"] == 1.0, str(A.counters["crane_hits"]))


def t_talisman_fast():
    fast = {"id": "rain", "on": "always", "do": [{"mod": {"talisman_fast": 1}}]}
    for has, want in ((True, 3), (False, 0)):
        f, A, B = setup(a=dummy(effects=[fast] if has else []), b=dummy(ward_pts=0, block=0))
        f.hit(A, B, 0.01, "phys", E.Art("ink", 0.01, 0.05, 3.0, element="fire", debuff=(3, 10.0), tags=("talisman",)))
        f.hit(A, B, 0.01, "phys", E.Art("palm", 0.01, 0.05, 3.0, element="wood", debuff=(2, 10.0)))
        f.cleanse(B, 10)
        check("talisman stacks: %s" % ("held fast through a cleanse" if has else "cleansed without the Effect"),
              B.count(B.debuffs, "fire") == want and B.count(B.debuffs, "wood") == 0, str(B.debuffs))


# ---- world-depth Stage 5 slice E (2026-11-26): escape (Combat rule 10, Formulas I)
class _Roll:
    """A random stream that returns fixed values, and fails the test if drawn when it must not be."""
    def __init__(self, *vals):
        self.vals = list(vals)

    def random(self):
        if not self.vals:
            raise AssertionError("an escape roll was drawn when none was expected")
        return self.vals.pop(0)


def _escape_fight(e_art=0.55, a_kw=None, b_kw=None):
    run = E.Art("run", 0.0, 0.01, 4.0, escape=e_art, tags=("escape", "movement"))
    f, A, B = setup(a=dummy(arts=[run], **(a_kw or {})), b=dummy(**(b_kw or {})))
    f.t = 3000
    A.ready = [3000]
    f.act(A)
    return f, A, B


def t_escape():
    f, A, B = _escape_fight()
    check("an escape art opens a 1 s channel", A.channel_until == 4000)
    A.ready = [3000]
    f.act(A)
    check("one channel at a time: a ready escape art waits", A.fired[0] == 1, str(A.fired))
    failed = []
    orig = f.fire_event
    f.fire_event = lambda s, name, ev: (failed.append(s) if name == "escape_failed" else None, orig(s, name, ev))[1]
    f.rng = _Roll(0.5)
    f.t = 4000
    f.escape_rolls()
    check("p 0.55 against a draw of 0.5: it flees", A.fled and A.channel_until is None)
    f, A, B = _escape_fight(b_kw={"effects": [{"id": "l", "on": "always", "do": [{"mod": {"lock": 1}}]}]})
    f.fire_event = lambda s, name, ev: (failed.append(s) if name == "escape_failed" else None, orig(s, name, ev))[1]
    f.rng = _Roll(0.5)
    f.t = 4000
    f.escape_rolls()
    check("a locking pursuer: p 0.40, the draw of 0.5 fails and raises escape_failed", not A.fled and failed == [A])
    f, A, B = _escape_fight(a_kw={"realm": 2})
    f.rng = _Roll(0.62)
    f.t = 4000
    f.escape_rolls()
    check("one realm above the pursuer: p 0.65", A.fled)
    f, A, B = _escape_fight(e_art=2.0)
    f.rng = _Roll(0.96)
    f.t = 4000
    f.escape_rolls()
    check("p is capped at 0.95", not A.fled)
    f, A, B = _escape_fight()
    f.apply_status(B, A, {"id": "bound", "dur": 2})
    f.rng = _Roll()
    f.t = 4000
    f.escape_rolls()
    check("Bound: the escape fails with no draw", not A.fled)
    f, A, B = _escape_fight()
    A.hp = 0.0
    f.rng = _Roll()
    f.t = 4000
    f.escape_rolls()
    check("a side at 0 health does not flee", not A.fled)


def t_escape_result():
    run = E.Art("run", 0.0, 0.01, 2.0, escape=0.95, tags=("escape",))
    f = E.Fight(dummy(arts=[run]), dummy(), seed=3)
    f.rng = _Roll(*([0.0] * 50))
    r = f.run()
    check("a successful escape ends the fight in flight, no winner", r["win"] == "flight" and f.A.fled, r["win"])
    f = E.Fight(dummy(arts=[run]), dummy(), seed=3)
    f.rng = _Roll(*([0.0] * 50))
    f.B.hp = 0.0
    f.t = 2000
    f.A.ready = [2000]
    f.act(f.A)
    f.t = 3000
    f.escape_rolls()
    check("fleeing while the foe is at 0 health is a win", f.A.fled and f.B.hp <= 0)


# ---- world-depth Stage 5 slice 2c (2026-11-26): the extended last act (Effects rule 11, The Fifteenth Layer)
_PINE = {"id": "pine", "on": "down", "do": [{"last_act_window": {
    "seconds": 6, "every": 1.0, "spend": "waves", "hits": [{"c": 0.4, "dtype": "phys"}, {"c": 0.4, "dtype": "cold"}]}}]}


def t_last_act_window():
    f, A, B = setup(a=dummy(effects=[_PINE], counters=[{"id": "waves"}]), b=dummy(ward_pts=0, block=0))
    A.counters["waves"] = 3.0
    f.t = 10000
    A.hp = -5.0
    f.defeat_check()
    check("the window opens: not Down yet", A.window is not None and not A.down)
    check("it cannot be struck or healed", f.hit(B, A, 1.0, "phys", None) == 0.0 and (f.heal(A, 50.0) or A.hp) == -5.0)
    hp = B.hp
    f.t = 11000
    f.act(A)
    check("one round of its banked waves fires a second", B.hp < hp and A.counters["waves"] == 2.0)
    f.t = 13000
    f.act(A)
    f.defeat_check()
    check("the bank runs dry: the side is Down", A.counters["waves"] == 0.0 and A.down)
    # the foe goes Down within the window: a draw
    f, A, B = setup(a=dummy(effects=[_PINE], counters=[{"id": "waves"}]))
    A.counters["waves"] = 9.0
    A.hp = -1.0
    f.defeat_check()
    f.t = 2000
    B.hp = -1.0
    f.defeat_check()
    check("the foe goes Down inside the window: both Down, a draw", A.down and B.down)
    # the window ends on time with waves left, and opens only once
    f, A, B = setup(a=dummy(effects=[_PINE], counters=[{"id": "waves"}]))
    A.counters["waves"] = 99.0
    A.hp = -1.0
    f.defeat_check()
    for t in range(1000, 7001, 1000):
        f.t = t
        f.act(A)
    f.defeat_check()
    check("six rounds in 6 s, then Down", A.down and A.counters["waves"] == 93.0, str(A.counters["waves"]))
    # a refusal comes first
    refuse = {"id": "r", "on": "down", "do": [{"refuse_down": True}]}
    f, A, B = setup(a=dummy(effects=[refuse, _PINE], counters=[{"id": "waves"}], refusals=1))
    A.counters["waves"] = 3.0
    A.hp = -1.0
    f.defeat_check()
    check("a refusal holds it up first; no window", A.window is None and not A.down and A.hp > 0)


# ---- world-depth Stage 5 slice 2b (2026-11-26): tick to heal (Bitter Medicine) and upkeep on a self-counter
def t_tick_to_heal():
    bitter = {"id": "bm", "on": "always", "if": [{"read": "own.debuff.wood", "op": "<", "value": 10}],
              "do": [{"mod": {"tick_to_heal": 50, "element": "wood"}}]}
    f, A, B = setup(b=dummy(effects=[bitter], ward_pts=0, block=0))
    B.hp = B.hp_max - 100.0
    got = f.tick(A, B, 40.0, "chaos", "wood")
    check("a Poison tick deals nothing and heals half of it", got == 0.0 and abs(B.hp - (B.hp_max - 80.0)) < 1e-9, str(B.hp_max - B.hp))
    hp = B.hp
    f.tick(A, B, 40.0, "fire", "fire")
    check("a Burn tick still hurts", B.hp < hp)
    B.debuffs.append(["wood", 10, None, A, None])
    hp = B.hp
    f.tick(A, B, 40.0, "chaos", "wood")
    check("at 10 Poison stacks the tick hurts as usual", B.hp < hp)
    B.debuffs.clear()
    f.apply_status(A, B, {"id": "withering"})
    hp = B.hp
    f.tick(A, B, 40.0, "chaos", "wood")
    check("it counts as healing: Withering halves it", abs((B.hp - hp) - 10.0) < 1e-9, str(B.hp - hp))


def t_upkeep():
    f, A, B = setup(a=dummy(counters=[{"id": "ward", "upkeep": {"pool": "qi", "per_stack": 0.1}}]))
    A.counters["ward"] = 3.0
    A.qi = 0.35 * A.qi_max()
    f.upkeep(A, "ward", A.counter_def["ward"]["upkeep"])
    check("upkeep: 3 stacks at 10 % each are paid in full", A.counters["ward"] == 3.0 and abs(A.qi - 0.05 * A.qi_max()) < 1e-9)
    A.qi = 0.25 * A.qi_max()
    f.upkeep(A, "ward", A.counter_def["ward"]["upkeep"])
    check("upkeep: only 2 can be paid, the third ends", A.counters["ward"] == 2.0 and abs(A.qi - 0.05 * A.qi_max()) < 1e-9, str(A.counters["ward"]))
    f, A, B = setup(a=dummy(counters=[{"id": "stele", "each_for": 9, "upkeep": {"pool": "qi", "per_stack": 0.1}}]))
    f.t = 1000
    A.counter_times["stele"] = [5000, 3000, 4000]
    A.qi = 0.15 * A.qi_max()
    f.upkeep(A, "stele", A.counter_def["stele"]["upkeep"])
    check("upkeep on charges: the ones nearest their end go first", A.counter_times["stele"] == [5000], str(A.counter_times["stele"]))
    f, A, B = setup(a=dummy(counters=[{"id": "blood", "upkeep": {"pool": "hp", "per_stack": 0.5}}]))
    A.counters["blood"] = 3.0
    f.upkeep(A, "blood", A.counter_def["blood"]["upkeep"])
    check("upkeep in health never goes below pay_keep_health", A.counters["blood"] == 1.0 and A.hp >= E.K["pay_keep_health"], "%s %s" % (A.counters["blood"], A.hp))


# ---- world-depth Stage 5 slice 2a (2026-11-26): Effects Status Catalogue rows Off Guard, Bound, Charmed, Drunk, Sleep
def _hits_landed(f, A, B, n, kind="art"):
    landed = 0
    for _ in range(n):
        hp = B.hp
        f.hit(A, B, 0.01, "phys", None, kind=kind)
        landed += B.hp < hp
        B.hp = B.hp_max
    return landed


def t_off_guard():
    f, A, B = setup(b=dummy(evade=0.4, ward_pts=0, block=0))
    f.apply_status(A, B, {"id": "off_guard", "dur": 2})
    check("Off Guard: every hit lands against 40 % evade", _hits_landed(f, A, B, 40) == 40)
    check("Off Guard lasts its 2 s", B.statuses["off_guard"]["until"] == f.t + 2000)
    f, A, B = setup(b=dummy(evade=0.4, ward_pts=0, block=0))
    check("without it some hits are evaded", _hits_landed(f, A, B, 40) < 40)


def t_bound():
    f, A, B = setup()
    f.apply_status(A, B, {"id": "bound", "dur": 2})
    u = B.statuses["bound"]["until"]
    f.t = 500
    f.apply_status(A, B, {"id": "bound", "dur": 2})
    check("Bound holds; a recast while it runs does nothing (stacking None)", B.st("bound") == 1 and B.statuses["bound"]["until"] == u)


def t_drunk():
    f, A, B = setup(b=dummy(ward_pts=0, block=0))
    f.apply_status(A, B, {"id": "drunk"})
    f.t = 1000
    f.apply_status(A, B, {"id": "drunk"})
    check("Drunk: no stack cap, 2 stacks", B.st("drunk") == 2)
    check("Drunk: 8 % slower timers per stack", abs(f.slow(B) - 1.16) < 1e-12, str(f.slow(B)))
    f.t = 3000
    f.pulse(B)
    check("Drunk: the first stack ends on its own time, the second keeps its own", B.st("drunk") == 1, str(B.st("drunk")))
    f.t = 4000
    f.pulse(B)
    check("Drunk: gone when its last stack ends", "drunk" not in B.statuses)
    # aim: 3 stacks on the attacker raise the foe's evade chance by 30 points (from 0)
    f, A, B = setup(b=dummy(ward_pts=0, block=0))
    for _ in range(3):
        f.apply_status(B, A, {"id": "drunk"})
    got = _hits_landed(f, A, B, 400)
    check("Drunk 3: about 30 % of the drunk side's hits miss", 240 <= got <= 320, str(got))
    # Water parts at 3 stacks
    seen = []
    f, A, B = setup(b=dummy(ward_pts=0, block=0))
    f.defend = lambda att, dfn, D, *a, **k: (seen.append(D), 0.0)[1]
    water = E.Art("w", 1.0, 0.05, 3.0, element="water")
    f.hit(A, B, 1.0, "phys", water)
    for _ in range(3):
        f.apply_status(A, B, {"id": "drunk"})
    f.hit(A, B, 1.0, "phys", water)
    f.hit(A, B, 1.0, "phys", E.Art("m", 1.0, 0.05, 3.0, element="metal"))
    check("Drunk 3: Water parts deal 10 % more, others do not", abs(seen[1] / seen[0] - 1.10) < 1e-9 and abs(seen[2] / seen[0] - 1.0) < 1e-9,
          "%s" % [round(x / seen[0], 4) for x in seen])


def t_charmed():
    arts = [E.Art("cut", 1.0, 0.01, 2.0), E.Art("mend", 0.0, 0.01, 2.0, heal=0.05)]
    f, A, B = setup(a=dummy(arts=list(arts)), b=dummy(arts=list(arts)))
    f.t = 5000
    A.ready = [f.t, f.t]
    B.ready = [f.t, f.t]
    f.apply_status(A, B, {"id": "charmed"})
    check("Charmed lasts 2 s", B.statuses["charmed"]["until"] == 7000)
    f.act(B)
    check("Charmed: the target's arts all wait", B.fired == [0, 0], str(B.fired))
    f.act(A)
    check("the charmer is held: its damaging art waits, its heal fires", A.fired == [0, 1], str(A.fired))
    f.tick(A, B, 5.0, "fire", "burn")
    check("a tick does not end Charmed", B.st("charmed") == 1)
    f.hit(A, B, 0.01, "phys", None, kind="companion")
    check("the charmer's companion hit does not end it", B.st("charmed") == 1)
    f.hit(A, B, 0.01, "phys", None, kind="trigger", trig=True)
    check("the charmer's free hit ends it, and the lockout starts", B.st("charmed") == 0 and B.lockouts["charmed"] == f.t + 10000)
    f.act(B)
    check("freed, the target fires again", B.fired[0] == 1, str(B.fired))
    f, A, B = setup(b=dummy(timer_resist=50))
    f.apply_status(A, B, {"id": "charmed"})
    check("timer resistance 50 shortens Charmed to 1 s", B.statuses["charmed"]["until"] == f.t + 1000)
    f, A, B = setup(b=dummy(arts=[E.Art("x", 1.0, 0.05, 4.0)]))
    f.do(A, {"id": "d", "on": "always", "do": []}, [{"timer": {"side": "foe", "by": 0.2}}], 1.0, {})
    f.apply_status(A, B, {"id": "charmed"})
    check("the delay falloff halves Charmed after a delay (1 s)", B.statuses["charmed"]["until"] == f.t + 1000)


def t_sleep():
    arts = [E.Art("cut", 1.0, 0.01, 2.0)]
    f, A, B = setup(b=dummy(arts=list(arts), ward_pts=0, block=0))
    f.t = 5000
    B.ready = [4000]          # already ready: it must wait too
    B.basic_ready = 5500
    f.apply_status(A, B, {"id": "sleep"})
    check("Sleep: the clock stops 3 s, a ready art included", B.ready[0] == 8000 and B.basic_ready == 8500, "%d %d" % (B.ready[0], B.basic_ready))
    check("Sleep lasts 3 s", B.statuses["sleep"]["until"] == 8000)
    f.act(B)
    check("asleep, nothing fires", B.fired == [0])
    f.tick(A, B, 5.0, "fire", "burn")
    check("a tick does not wake it", B.st("sleep") == 1)
    B.hp = B.hp_max
    A.basic_ready = f.t
    f.act(A)
    check("the sleeper's caster is held (its basic attack does not hit)", B.hp == B.hp_max)
    f.t = 6000
    B.basic_ready = 9000      # set during the sleep: the wake must not pull it back
    seen = []
    orig = f.defend
    f.defend = lambda att, dfn, D, *a, **k: (seen.append(D), orig(att, dfn, D, *a, **k))[1]
    f.hit(A, B, 1.0, "phys", None, kind="companion")
    check("a companion hit wakes it, and the lockout starts", B.st("sleep") == 0 and B.lockouts["sleep"] == 6000 + 6000)
    check("the unused 2 s come back to the timers the stop moved", B.ready[0] == 6000, str(B.ready[0]))
    check("a timer set during the sleep keeps its time", B.basic_ready == 9000, str(B.basic_ready))
    f.hit(A, B, 1.0, "phys", None, kind="companion")
    check("the waking hit deals 20 % less", abs(seen[0] / seen[1] - 0.8) < 1e-9, str(seen[0] / seen[1]))
    f, A, B = setup(b=dummy(arts=list(arts)))
    f.apply_status(A, B, {"id": "sleep"})
    f.t = 3000
    f.pulse(B)
    check("Sleep ends on its own after 3 s, with nothing given back", "sleep" not in B.statuses)


def t_pieces():          # AC-CD-82
    f, A, B = setup(b=dummy(ward_pts=0, block=0, shields=[E.Shield(size=300 / (26 * E.U[0] * 1.053), pieces=3)]))
    B.wshields[0]["left"] = 300.0
    hp0 = B.hp
    f.defend(A, B, 250.0, "phys", None, {}, is_tick=False)
    check("AC-CD-82 one piece soaks 100, 150 moves on", abs((hp0 - B.hp) - 150) < 1e-6, str(hp0 - B.hp))


def t_bypass():          # AC-CD-80
    f, A, B = setup(b=dummy(ward_pts=0, block=0, shields=[E.Shield(size=1.0)]))
    art = E.Art("b", bypass=0.6)
    hp0 = B.hp
    f.defend(A, B, 100.0, "phys", art, {}, is_tick=False)
    check("AC-CD-80 bypass capped at 50 %", abs((hp0 - B.hp) - 50) < 1e-6, str(hp0 - B.hp))


def t_crossing():        # AC-CD-83
    f, A, B = setup()
    B.hp = B.hp_max - 100
    f.apply_status(A, B, {"id": "withering", "crossing": True})
    hp0 = B.hp
    f.heal(B, 40)
    check("AC-CD-83 Crossing the Line: 40 heal -> 20 damage", abs((hp0 - B.hp) - 20) < 1e-6, str(hp0 - B.hp))


def t_soul_part():       # AC-CB-90
    f, A, B = setup(b=dummy(ward_pts=0, block=0, soul_res=50))
    art = E.Art("s", c=2.0, soul_part=0.3)
    hp0 = B.hp
    f.rng.random = lambda: 0.99   # no evade, no crit
    f.hit(A, B, 2.0, "phys", art)
    D = E.U[0] * 2.0 * A.b.M
    expect = D * 0.7 + D * 0.3 / 1.5
    check("AC-CB-90 added Soul part meets soul resistance only", abs((hp0 - B.hp) - expect) < 1e-6,
          "%.3f vs %.3f" % (hp0 - B.hp, expect))


def t_ward_bill():       # AC-CD-84
    f, A, B = setup(a=dummy(ward_bill_pct=30))
    q0 = B.qi
    f.defend(A, B, 100.0, "phys", None, {}, is_tick=False)
    bill = q0 - B.qi
    f2, A2, B2 = setup()
    q1 = B2.qi
    f2.defend(A2, B2, 100.0, "phys", None, {}, is_tick=False)
    check("AC-CD-84 ward_bill_pct 30 -> bill x1.3", abs(bill / (q1 - B2.qi) - 1.3) < 1e-6)


def t_stagnation():
    f, A, B = setup()
    B.qi = 0
    f.pulse(B)
    r0 = B.qi
    f2, A2, B2 = setup()
    for _ in range(100):
        f2.apply_status(A2, B2, {"id": "stagnation"})
    B2.qi = 0
    f2.pulse(B2)
    check("Stagnation 100 stacks halves regeneration", abs(B2.qi / r0 - 0.5) < 1e-6, str(B2.qi / r0))


def t_unknown_action():
    try:
        E.validate(dummy(effects=[{"id": "x", "on": "crit", "do": [{"teleport": {}}]}]))
        ok = False
    except E.EngineError:
        ok = True
    check("unknown action stops the run", ok)


def t_split():           # R23
    f, A, B = setup(a=dummy(arts=[E.Art("rain", 1.2, 0.05, 2.0, split=[0.4, 0.4, 0.4])]))
    n = []
    A.b.effects.append({"id": "count", "on": "hit_landed", "do": []})
    f.fire_event = (lambda orig: (lambda s, name, ev: (n.append(name) if name == "hit_landed" and s is A else None, orig(s, name, ev))[1]))(f.fire_event)
    f.t = A.ready[0]
    f.act(A)
    check("R23 split hit: 3 sub-hits (plus the basic attack)", n.count("hit_landed") >= 3, str(n.count("hit_landed")))


def t_convert():         # art conversion: each part meets its own type's resistance
    f, A, B = setup(b=dummy(ward_pts=0, block=0, resist={"fire": 100}))
    f.rng.random = lambda: 0.99
    art = E.Art("spark", c=2.0, convert={"to": "fire", "share": 0.4})
    hp0 = B.hp
    f.hit(A, B, 2.0, "phys", art)
    D = E.U[0] * 2.0 * A.b.M
    check("art convert: 60 % Physical full, 40 % Fire at /2", abs((hp0 - B.hp) - (D * 0.6 + D * 0.4 / 2)) < 1e-6)


def t_hp_cost():
    f, A, B = setup(a=dummy(arts=[E.Art("blood", 1.0, 0.04, 3.0, hp_cost=0.1)]))
    f.t = A.ready[0]
    hp0 = A.hp
    f.act(A)
    check("art paid in health: 10 % of health_max", abs((hp0 - A.hp) - 0.1 * A.hp_max) < 1e-6)


def t_charges():
    f, A, B = setup(a=dummy(arts=[E.Art("twin", 1.0, 0.02, 4.0, charges=2)]))
    f.t = A.ready[0]
    f.act(A)
    second = A.ready[0] - f.t
    f.t = A.ready[0]
    f.act(A)
    check("charges: second firing after cooldown_min, then the full cooldown",
          second == 500 and A.ready[0] - f.t == 4000 and A.fired[0] == 2, "%d %d" % (second, A.ready[0] - f.t))


def t_states():          # R29
    st = [{"id": "storm", "mods": {"art_speed": 50}, "suppress": ["slow"]}]
    f, A, B = setup(a=dummy(states=st, arts=[E.Art("slow", 1.0, 0.02, 4.0)]))
    e = {"id": "s", "on": "always", "do": []}
    f.do(A, e, [{"state": {"set": "storm"}}], 1.0, {})
    f.t = A.ready[0]
    f.act(A)
    check("states: mods apply, suppressed art does not fire, state readable",
          f.mod(A, "art_speed") == 50 and A.fired[0] == 0 and f.read(A, "own.state.storm") == 1.0)


def t_summon_echo():
    f, A, B = setup(a=dummy(arts=[E.Art("pal", 1.0, 0.02, 4.0)]), b=dummy(ward_pts=0, block=0))
    f.rng.random = lambda: 0.99
    e = {"id": "s", "on": "always", "do": []}
    f.do(A, e, [{"summon": {"c": 0.5, "cd": 1.0, "for": 3}}], 1.0, {})
    hp0 = B.hp
    for t in (1000, 2000, 3000, 4000):
        f.t = t
        A.basic_ready = 10 ** 9
        A.ready[0] = 10 ** 9
        f.act(A)
    hits = round((hp0 - B.hp) / (E.U[0] * 0.5 * A.b.M), 3)
    A.last_art = 0
    hp1 = B.hp
    f.do(A, e, [{"fire_art": {"which": "last", "share": 0.5}}], 1.0, {})
    check("summon hits for its duration; fire_art echoes the last art",
          hits == 2.0 and abs((hp1 - B.hp) - E.U[0] * 0.5 * A.b.M) < 1e-6, "summon hits %s" % hits)


def t_or_guard():
    f, A, B = setup()
    g = [{"any": [{"read": "own.hp_share", "op": "<=", "value": 0.5}, {"read": "time", "op": ">=", "value": 10}]}]
    a = f.holds(A, g)
    f.t = 10000
    check("OR-guard: false, then true when one branch holds", (not a) and f.holds(A, g))


def t_cleanse_curses():
    f, A, B = setup()
    for sid in ("sundered", "exposed", "withering"):
        f.apply_status(B, A, {"id": sid})
    e = {"id": "c", "on": "always", "do": []}
    f.do(A, e, [{"cleanse": {"curses": 2}}], 1.0, {})
    check("cleanse 2 curses", len(A.statuses) == 1)


def t_multistep():
    # step 2 needs 3 fire debuff stacks on the foe and consumes them; step 3 needs a Fire art fired within 2 s
    art = E.Art("three-forms", 1.0, 0.02, 2.0, element="fire", tags=("palm",), group="red-sun", steps=[
        {"unlock": [{"read": "foe.debuff.fire", "op": ">=", "value": 3}],
         "pay": [{"consume": {"el": "fire", "side": "foe", "n": 3}}], "c_mult": 2.0},
        {"unlock": [{"read": "own.fired_within.2.group.red-sun", "op": ">=", "value": 1}], "c_mult": 4.0}])
    f, A, B = setup(a=dummy(arts=[art]), b=dummy(ward_pts=0, block=0))
    f.rng.random = lambda: 0.99
    unit = E.U[0] * A.b.M
    dealt = []
    for t, stacks in ((2000, 0), (4000, 3), (6000, 0), (8000, 0)):
        f.t = t
        if stacks:
            B.debuffs.append(["fire", stacks, 99000, A])
        A.ready[0] = t
        A.basic_ready = 10 ** 9
        hp0 = B.hp
        f.act(A)
        dealt.append(round((hp0 - B.hp) / unit, 3))
    check("multi-step: 1 (no stacks) -> 2 (consumes 3) -> 3 (group fired) -> back to 1",
          dealt == [1.0, 2.0, 4.0, 1.0] and B.count(B.debuffs, "fire") == 0, str(dealt))


def t_empower():
    art = E.Art("dry-strike", 1.0, 0.02, 2.0, empower=[{"if": [{"read": "foe.qi_share", "op": "<=", "value": 0.1}],
                                                       "c_mult": 3.0}])
    f, A, B = setup(a=dummy(arts=[art]), b=dummy(ward_pts=0, block=0))
    f.rng.random = lambda: 0.99
    unit = E.U[0] * A.b.M
    out = []
    for qi in (1.0, 0.05):
        B.qi = qi * B.qi_max()
        f.t = A.ready[0] = 2000 * (len(out) + 1)
        A.basic_ready = 10 ** 9
        hp0 = B.hp
        f.act(A)
        out.append(round((hp0 - B.hp) / unit, 3))
    check("empower: x3 when the foe's linh luc is dry", out == [1.0, 3.0], str(out))


def t_since():
    f, A, B = setup(a=dummy(arts=[E.Art("a1", 0.5, 0.02, 2.0)]))
    never = f.read(A, "own.since.a1")
    f.t = A.ready[0]
    A.basic_ready = 10 ** 9
    f.act(A)
    f.t += 1500
    check("since.<art>: never, then 1.5 s", never >= 1e8 and abs(f.read(A, "own.since.a1") - 1.5) < 1e-9)


def t_reserved():        # Combat Defence & Healing rule 10: usable linh lực is qi_max x (1 - reserved), costs read qi_max
    f, A, B = setup(a=dummy(reserved=0.25))
    check("reserved 0.25: the fight starts at 75 % of linh lực", abs(A.qi - 0.75 * A.qi_base) < 1e-9, str(A.qi / A.qi_base))
    e = {"id": "g", "on": "always", "do": []}
    f.do(A, e, [{"gain_qi": {"share": 1.0}}], 1.0, {})
    check("reserved 0.25: gains stop at the usable maximum", abs(A.qi - A.qi_use()) < 1e-9 and A.qi_use() < A.qi_max())
    f, A, B = setup(a=dummy(reserved=0.95))
    check("reserved above reserve_cap 0.9 is held at 0.9", abs(A.qi - 0.1 * A.qi_base) < 1e-9)


def t_stack_effect():    # modifiers.md stack_effect_pct, Effects rule 9a
    b = dummy(stack_eff={"fire|debuff": 100})
    base = E.stack_power(dummy(), "fire", "debuff")
    check("stack_effect_pct 100 [hoa, debuff] doubles Fire debuff stacks",
          abs(E.stack_power(b, "fire", "debuff") - 2 * base) < 1e-9)
    check("... and leaves Fire buff stacks and other elements alone",
          abs(E.stack_power(b, "fire", "buff") - base) < 1e-9 and abs(E.stack_power(b, "water", "debuff") - base) < 1e-9)
    b = dummy(stack_eff={"*|*": 50, "fire|*": 10})
    check("unscoped and element-only lines add up (+60 %)", abs(E.stack_power(b, "fire", "buff") - 1.6 * base) < 1e-9)


def t_stack_duration():  # modifiers.md stack_duration_pct
    f, A, B = setup(a=dummy(stack_dur={"fire|debuff": 50}))
    f.add_stacks(A, B, "fire", 2, 6.0, False)
    f.add_stacks(A, A, "fire", 2, 6.0, True)
    check("stack_duration_pct 50 [hoa, debuff]: a 6 s Burn batch lasts 9 s", B.debuffs[-1][2] - f.t == 9000,
          str(B.debuffs[-1][2] - f.t))
    check("... and a Fire buff batch keeps 6 s", A.buffs[-1][2] - f.t == 6000, str(A.buffs[-1][2] - f.t))


def t_extra_wards():     # Combat Defence & Healing rules 5-8: drain, per-hit, reserved and cast wards beside the main ward
    fire = {"id": "veil", "model": "per_hit", "payload": {"fire": 200.0}, "cost": 0.02}
    f, A, B = setup(b=dummy(wards=[fire], ward_pts=0.0))
    q0 = B.qi
    xs = f.extra_wards(B, "fire", False)
    check("per-hit ward: meets a Fire hit and pays its fee", len(xs) == 1 and abs(q0 - B.qi - 0.02 * B.qi_max()) < 1e-9)
    q1 = B.qi
    check("per-hit ward: a second part of the same hit pays no second fee (CD&H rule 6)",
          len(f.extra_wards(B, "fire", False)) == 1 and B.qi == q1)
    check("per-hit ward: meets no Physical part", f.extra_wards(B, "phys", False) == [])
    f.hit_fees = set()                       # a new tick
    q2 = B.qi
    check("per-hit ward: a tick pays one fee and is met (CD&H rule 6: one fee per tick)",
          len(f.extra_wards(B, "fire", True)) == 1 and abs(q2 - B.qi - 0.02 * B.qi_max()) < 1e-9)
    cast = {"id": "shell", "model": "cast", "payload": {"phys": 70.0}, "cost": 0.03, "cooldown": 5.0, "up": 2.0}
    f, A, B = setup(b=dummy(wards=[cast]))
    check("cast ward: down before it is cast", f.extra_wards(B, "phys", False) == [])
    f.cast_wards(B)
    up = f.extra_wards(B, "phys", False)
    f.t += 2500
    f.cast_wards(B)
    check("cast ward: up for its window, then down until its cooldown",
          len(up) == 1 and f.extra_wards(B, "phys", False) == [])
    shield = {"id": "gold", "model": "cast", "payload": {}, "shield": 0.1, "cost": 0.02, "cooldown": 4.0, "up": 3.0}
    f, A, B = setup(b=dummy(wards=[shield]))
    n0 = len(B.wshields)
    f.cast_wards(B)
    check("cast shield: casting adds a bar of 0.1 x qi", len(B.wshields) == n0 + 1
          and abs(B.wshields[-1]["left"] - 0.1 * B.qi_base) < 1e-9)
    f.t += 3500
    f.cast_wards(B)
    check("cast shield: the bar is gone when the window ends", len(B.wshields) == n0)
    res = {"id": "lake", "model": "reserved", "payload": {"all": 50.0}}
    f, A, B = setup(b=dummy(wards=[res]))
    B.qi = 0.0
    check("reserved ward: up even with no linh lực left", len(f.extra_wards(B, "phys", False)) == 1)


def t_parse_ward():      # fight.py parse_ward: ward records in the GDD's own words
    import fight as F
    w, skip = F.parse_ward({"payload": "Fire 240 points", "payment": "drain 0.176", "activation": "standing"})
    check("parse: Fire 240 points, drain 0.176", w["model"] == "drain" and w["payload"] == {"fire": 240.0}
          and w["drain_base"] == 0.176 and not skip)
    w, skip = F.parse_ward({"payload": "shield σ 0.135", "payment": "cast 0.036", "activation": "cast, cooldown 4 s, up 3 s"})
    check("parse: shield σ 0.135, cast, cooldown 4, up 3", w["model"] == "cast" and w["shield"] == 0.135
          and w["cooldown"] == 4.0 and w["up"] == 3.0 and w["cost"] == 0.036)
    w, skip = F.parse_ward({"payload": "block 60, evade +12 pp", "payment": "reserved 0.47"})
    check("parse: block 60 and evade +12 pp both run (evade wards, 2026-11-13)", w["block"] == 60.0
          and w["evade"] == 12.0 and w["reserve"] == 0.47 and not skip, str((w, skip)))
    f, A, B = setup()
    B.xwards = [{"w": {"model": "reserved", "evade": 40.0, "payload": {}}, "up": True}]
    B.qi = 0.0
    dodged = sum(f.hit(A, B, 1.0, "phys", None, kind="basic") == 0.0 for _ in range(400))
    check("a reserved evade ward adds its points to evade (40 pp -> the 40 % cap)", 120 < dodged < 200, str(dodged))


def t_refresh_and_hold():   # the refresh action: Fan the Pyre (restart) and Verdict Stands (hold), 2026-11-13
    f, A, B = setup()
    f.add_stacks(A, B, "fire", 3, 6.0, False)
    f.add_stacks(B, B, "fire", 3, 6.0, False)            # a batch someone else laid
    f.t += 4000
    e = {"id": "r", "on": "always", "do": []}
    f.do(A, e, [{"refresh": {"el": "fire"}}], 1.0, {})
    check("refresh: my Burn batch restarts its 6 s at t = 4 s", B.debuffs[0][2] == 10000, str(B.debuffs[0][2]))
    check("refresh: another side's batch is left alone", B.debuffs[1][2] == 6000, str(B.debuffs[1][2]))
    f.do(A, e, [{"refresh": {"el": "fire", "hold": True}}], 1.0, {})
    check("hold: my batch never ends", B.debuffs[0][2] is None)


def t_new_readables():      # curses on a side; drain-ward bills paid (Weight of Names, Water Table), 2026-11-13
    f, A, B = setup()
    B.statuses["withering"] = {"stacks": 1, "until": 1 << 40, "src": A, "batches": []}
    B.statuses["sundered"] = {"stacks": 2, "until": 1 << 40, "src": A, "batches": []}
    check("foe.curses counts curse statuses only", f.read(A, "foe.curses") == float(
        sum(1 for k in ("withering", "sundered") if E.STATUS[k].get("kind") == "curse")))
    got = []
    A.b.effects.append({"id": "wt", "on": "foe_ward_paid", "do": [{"gain_qi": {"of": "amount", "share": 0.3}}]})
    A.qi = 0.0
    f.defend(A, B, 50.0, "phys", None, {})
    check("a drain-ward bill raises foe_ward_paid for the attacker (Water Table refills it)", B.ward_paid > 0
          and abs(A.qi - 0.3 * B.ward_paid) < 1e-9, "%s %s" % (B.ward_paid, A.qi))


def t_armour_ward_slot():   # AC-CD-14b: each worn armour brings a ward slot for its own ward (2026-11-13)
    import fight as F
    arts = [{"id": "a%d" % i} for i in range(3)]          # Qi Refining: 3 art slots, all full
    armour = {"name": "plate", "payload": "all 100 points", "payment": "drain 0.3", "own_slot": True}
    armour2 = dict(armour, name="second plate")
    bell = {"name": "bell", "payload": "all 100 points", "payment": "per hit 0.035"}
    d = {"realm": "luyen_khi", "arts": arts, "wards": [armour, armour2, bell]}
    notes = []
    out, _ = F.extra_wards(d, 0, notes, "t", 1.0, 0.0)
    names = [n.split("\t")[2].split(" (")[0] for n in notes]
    check("AC-CD-14b: two armour wards up beside the main ward at Qi Refining", names == ["plate", "second plate"],
          str(names))
    check("AC-CD-14b: the bell finds no slot (the realm's one slot holds the main ward, art slots full)",
          any("bell" in u and "no free ward or art slot" in u for u in d["unmodelled"]))


def t_static_lines():    # fight.py apply_static: item and technique lines that change the build itself
    import fight as F
    d, un = {"realm": "truc_co"}, []
    F.apply_static(d, [{"key": "khi_huyet_pct", "value": 10}, {"key": "linh_luc_pct", "value": 20},
                       {"key": "body_shield_pct", "value": 15}, {"key": "defense_pct", "value": 12},
                       {"key": "than_thuc_pct", "value": 50},
                       {"key": "stack_effect_pct", "value": 16, "scope": ["hoa", "debuff"]}], "test", un)
    ws = F.C["typical_ws"][1]
    check("apply_static: health and linh lực pools x1.10 and x1.20",
          abs(d["n_body"] - 1.0883 * 1.1) < 1e-9 and abs(d["n_qi"] - 1.053 * 1.2) < 1e-9)
    check("apply_static: body shield +0.15 of health, divine sense x1.5",
          abs(d["body"]["shield"] - 0.15) < 1e-9 and abs(d["divine_sense"] - 1.5) < 1e-9)
    check("apply_static: ward strength +12 points, efficiency kept", abs(d["ward"]["ws_base"] - (ws + 12)) < 1e-9
          and abs(d["ward"]["we"] - ws) < 1e-9)
    check("apply_static: stack effect keyed fire|debuff", d["stack_eff"] == {"fire|debuff": 16}, str(d.get("stack_eff")))
    F.apply_static(d, [{"key": "khi_huyet_pct", "value": 10}], "test", un)
    check("apply_static: pool % add up across calls (+10 +10 = x1.20, not x1.21)", abs(d["n_body"] - 1.0883 * 1.2) < 1e-9,
          str(d["n_body"] / 1.0883))


def t_scoped_art_reads():  # 2026-11-13: art speed, cost and soul reads use the art's own context (scoped modifiers)
    fire = E.Art("fire", 1.0, 0.05, 4.0, element="fire")
    other = E.Art("other", 1.0, 0.05, 4.0)
    fx = [{"id": "fast-fire", "on": "always", "do": [{"mod": {"art_speed": 100, "element": "fire"}},
                                                     {"mod": {"cost_red": 0.5, "element": "fire"}}]}]
    f, A, B = setup(a=dummy(arts=[fire, other], effects=fx))
    check("a Fire-scoped art speed halves only the Fire art's opening cooldown", A.ready == [2000, 4000], str(A.ready))
    A.qi = A.qi_max()
    q0 = A.qi
    f.pay(A, fire)
    paid_fire = q0 - A.qi
    A.qi = q0
    f.pay(A, other)
    paid_other = q0 - A.qi
    check("a Fire-scoped cost reduction halves only the Fire art's cost", abs(paid_fire - 0.5 * paid_other) < 1e-9,
          "%s %s" % (paid_fire, paid_other))


def _fx(*mods):
    return [{"id": "t", "on": "always", "do": [{"mod": m} for m in mods]}]


def t_status_duration_and_resist():   # modifiers.md status_duration_pct (scope curse) and status_resist_pct; Combat F
    f, A, B = setup(a=dummy(effects=_fx({"status_dur": 50, "tags": ["curse"]})))
    f.apply_status(A, B, {"id": "sundered", "dur": 2})
    check("status_duration_pct 50 on curses: 2 pulses -> 3", B.statuses["sundered"]["until"] == 3000,
          str(B.statuses["sundered"]["until"]))
    f.apply_status(A, B, {"id": "withering", "dur": 4})
    check("the curse clamp still holds after the raise (4 x 1.5 -> 5)", B.statuses["withering"]["until"] == 5000)
    landed = 0
    for seed in range(400):
        f, A, B = setup(b=dummy(effects=_fx({"status_resist": 60})))
        f.rng.seed(seed)
        f.apply_status(A, B, {"id": "sundered"})
        landed += "sundered" in B.statuses
    check("status_resist_pct 60: a guaranteed status lands about 40 % of the time", 0.33 < landed / 400 < 0.47,
          str(landed / 400))
    f, A, B = setup(b=dummy(effects=_fx({"status_resist": 200})))
    hits = 0
    for seed in range(2000):
        f.rng.seed(seed)
        B.statuses.clear()
        f.apply_status(A, B, {"id": "sundered"})
        hits += "sundered" in B.statuses
    check("status resistance above 100 leaves the 5 % floor", 0.03 < hits / 2000 < 0.07, str(hits / 2000))


def t_heal_taken():          # Combat Defence & Healing E: healing_taken_pct, floored at -50 %
    f, A, B = setup(a=dummy(effects=_fx({"heal_taken": 50})))
    A.hp = A.hp_max / 2
    h0 = A.hp
    f.heal(A, 10.0)
    check("healing_taken_pct 50: a heal of 10 restores 15", abs(A.hp - h0 - 15.0) < 1e-9, str(A.hp - h0))
    f, A, B = setup(a=dummy(effects=_fx({"heal_taken": -90})))
    A.hp = A.hp_max / 2
    h0 = A.hp
    f.heal(A, 10.0)
    check("healing taken never falls below -50 %", abs(A.hp - h0 - 5.0) < 1e-9, str(A.hp - h0))


def t_qi_on_crit():          # modifiers.md linh_luc_on_crit_pct: pp of maximum per crit
    f, A, B = setup(a=dummy(crit=1.0, effects=_fx({"qi_on_crit": 2.0})))
    A.qi = 0.0
    f.hit(A, B, 1.0, "phys", E.Art("x", 1.0))
    check("linh_luc_on_crit_pct 2: a crit restores 2 % of maximum", abs(A.qi - 0.02 * A.qi_max()) < 1e-9,
          "%s %s" % (A.qi, A.qi_max()))


def t_art_cost_health():     # Combat E: linh luc pays cost / (1 + X/100), health the rest point for point
    art = E.Art("x", 1.0, 0.05, 4.0)
    f, A, B = setup(a=dummy(arts=[art]))
    A.qi = A.qi_max()
    q0, h0 = A.qi, A.hp
    f.pay(A, art)
    full = q0 - A.qi
    f, A, B = setup(a=dummy(arts=[art], effects=_fx({"art_cost_hp": 100})))
    A.qi = A.qi_max()
    q0, h0 = A.qi, A.hp
    f.pay(A, art)
    check("art_cost_health_pct 100: linh luc pays half", abs((q0 - A.qi) - full / 2) < 1e-9)
    check("and health pays the other half point for point", abs((h0 - A.hp) - full / 2) < 1e-9, str(h0 - A.hp))


def t_pen_and_pierce():      # AC-CD-13 (penetration by final type), AC-CB-44 (pierce)
    def side(r):
        return E.Side(dummy(realm=r), "x")
    check("AC-CB-44 supp(2, 0.5) = 0.875", abs(E.supp(side(0), side(2), 0.5) - 0.875) < 1e-9)
    check("AC-CB-44 pierce 90 stops at P 0.75", abs(E.supp(side(0), side(4), 0.9) - (1 - 0.75 * 0.25)) < 1e-9)
    check("AC-CB-44 an actor above its target has supp 1", E.supp(side(3), side(1), 0.0) == 1.0)
    got = {}
    for pen in (0, 30):
        f, A, B = setup(a=dummy(effects=_fx({"pen": pen, "dtype": "fire"})), b=dummy(resist={"fire": 448.0, "cold": 448.0}))
        B.qi = 0.0
        for dt in ("fire", "cold"):
            B.hp = B.hp_max
            got[(pen, dt)] = f.defend(A, B, 100.0, dt, None, {"dtype": dt})
    blk = E.BLOCK_UNIT[B.b.realm] * B.b.block           # the default gear block, met after resistance
    base = 100.0 / (1 + (448.0 + B.b.body_pts * B.b.bs_mult) / 100) - blk
    check("AC-CD-13: Fire-scoped penetration 30 lowers a Fire part's R by 30 (448 -> 418)", abs(got[(30, "fire")] - (
        100.0 / (1 + (418.0 + B.b.body_pts * B.b.bs_mult) / 100) - blk)) < 1e-6, "%s" % got)
    check("AC-CD-13: a Cold part is unchanged", abs(got[(30, "cold")] - got[(0, "cold")]) < 1e-9 and
          abs(got[(0, "cold")] - base) < 1e-6)


def t_stack_grant():         # Effects rule 9a: stack_grant adds stacks to each grant of the element
    f, A, B = setup(a=dummy(effects=_fx({"stack_grant": 1, "element": "fire", "kind": "debuff"})))
    f.add_stacks(A, B, "fire", 2, 6.0, buff=False)
    f.add_stacks(A, B, "water", 2, 6.0, buff=False)
    check("stack_grant 1 on Fire debuffs: 2 -> 3, Water unchanged", [x[1] for x in B.debuffs] == [3, 2],
          str(B.debuffs))


def t_effects_library():   # assets/data/combat_effects.json (moved 2026-11-14, ADR-0001 decision 3)
    import json
    import fight as F
    lib = json.load(open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "assets", "data", "combat_effects.json"),
                         encoding="utf-8"))["effects"]
    bad = []
    for name, entry in lib.items():
        if entry.get("not_run"):
            continue
        b = dummy(effects=entry.get("records", []), counters=entry.get("counters", []))
        try:
            E.validate(b)
            E.Fight(b, dummy(arts=[E.Art("x", 1.0, 0.05, 2.0)]), seed=1).run()
        except Exception as ex:   # noqa: BLE001 (any failure is a finding)
            bad.append("%s: %s" % (name, ex))
    check("every library Effect validates and runs a fight", not bad, "; ".join(bad))
    F._library()
    named = {(e if isinstance(e, str) else e.get("name", "")).split(" (")[0]
             for it in F._LIB["items"].values() for e in it.get("effects", [])}
    missing = sorted(named - set(lib))
    check("every Effect the item catalogue names has a library entry", not missing, str(missing))
    item = next(i for i, it in F._LIB["items"].items() if any(
        (e if isinstance(e, str) else e.get("name", "")).startswith("Opening Cut") for e in it.get("effects", [])))
    d = F.expand_library({"name": "t", "realm": "luyen_khi", "arts": [], "items": [item]})
    check("a worn item's Effect is added from the library", any(e["id"] == "eff:Opening Cut" for e in d["effects"]))
    own = {"id": "eff:Opening Cut", "on": "crit", "do": [{"status": {"id": "bleed", "side": "foe", "stacks": 2}}]}
    d = F.expand_library({"name": "t", "realm": "luyen_khi", "arts": [], "items": [item], "effects": [own]})
    got = [e for e in d["effects"] if e["id"] == "eff:Opening Cut"]
    check("a build's own form of the Effect wins over the library", got == [own], str(got))


def t_item_sets():   # Item Database rule 22, Formulas J (world-depth Stage 5 slice 6, 2026-11-26)
    import fight as F
    F._library()
    pieces = sorted(F._LIB["items"])[:3]
    full = {"id": "x", "on": "always", "do": [{"mod": {"block": 5}}]}
    old = F.SETS
    F.SETS = {"constants": {"set_bonus_min_pieces": 2}, "sets": [{"id": "trio", "name": "Trio", "pieces": pieces,
              "bonuses": [{"pieces": 2, "modifiers": [{"key": "attack_pct", "value": 10, "scope": []}]},
                          {"pieces": 3, "effect": "Trio Whole", "record": full}]}]}
    try:
        ids = lambda items: {e["id"] for e in F.expand_library({"name": "t", "realm": "luyen_khi", "arts": [],
                                                                  "items": items})["effects"]}
        one, two, three = ids(pieces[:1]), ids(pieces[:2]), ids(pieces)
        twice = ids([pieces[0], pieces[0]])
        check("one piece: no set lines", not any(i.startswith("set:") for i in one), str(one))
        check("two pieces: the 2-piece modifiers, not the Effect", "set:trio" in two and "set:trio:full" not in two, str(two))
        check("the full set: the modifiers and its Effect", {"set:trio", "set:trio:full"} <= three, str(three))
        check("two records of one piece count once", not any(i.startswith("set:") for i in twice), str(twice))
        # a full set naming an Effect with no inline record runs it from combat_effects.json (ADR-0009, 2026-11-26)
        F.SETS = {"constants": {"set_bonus_min_pieces": 2}, "sets": [{"id": "duo", "name": "Duo", "pieces": pieces[:2],
                  "bonuses": [{"pieces": 2, "effect": "Rime Lock (Sương Tỏa)"}]}]}
        lib = ids(pieces[:2])
        check("a full-set Effect by name runs its library record", "eff:Rime Lock" in lib, str(lib))
    finally:
        F.SETS = old


def t_elem_type_scope():   # an "elem" art meets type-scoped filters as its element's usual type (2026-11-13)
    check("a Fire-type filter matches a Fire-element elem art", E.match({"dtype": "fire"}, {"dtype": "elem", "element": "fire"}))
    check("a Lightning-type filter matches a Thunder elem art", E.match({"dtype": "lightning"}, {"dtype": "elem", "element": "thunder"}))
    check("a Fire-type filter does not match a Water elem art", not E.match({"dtype": "fire"}, {"dtype": "elem", "element": "water"}))
    check("a Physical filter does not match an elem art", not E.match({"dtype": "phys"}, {"dtype": "elem", "element": "metal"}))


def t_layer_budget():      # fight.py layer budget (user decision 2026-11-13)
    import fight as F
    import io
    import contextlib
    for r in range(5):
        with contextlib.redirect_stdout(io.StringIO()):
            typ = F.layer_budget({"layers": F.enemy_file("typical", r)["layers"]}, r)
            top = F.layer_budget({"layers": F.enemy_file("top_end", r)["layers"]}, r)
        check("layer budget %s: typical claims 0 %%, top-end 100 %%" % F.REALMS[r], abs(typ) < 1e-9 and abs(top - 1) < 1e-9,
              "%s %s" % (typ, top))


def t_field_budget():      # fight.py hand-set field budget (user decision 2026-11-13)
    import fight as F
    import io
    import contextlib
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        typ = F.field_budget({}, 2)
        hot = F.field_budget({"art_speed_pct": 100, "crit": {"chance": 0.5, "mult": 3.0}}, 2)
    check("field budget: a typical build claims nothing", all(v == 0 for v in typ.values()), str(typ))
    check("field budget: speed 100 and capped crit claim their whole gaps and are flagged",
          hot["art speed %"] == 1.0 and hot["crit chance"] == 1.0 and buf.getvalue().count("FIELD_OVER") == 3,
          buf.getvalue())


def main():
    for name, fn in sorted(globals().items()):
        if name.startswith("t_"):
            fn()
    print("%d failed" % len(FAIL))
    return 1 if FAIL else 0


if __name__ == "__main__":
    sys.exit(main())
