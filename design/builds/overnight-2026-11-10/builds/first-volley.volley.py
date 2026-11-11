"""First Volley: a current-rules check of the opening instant (overnight 2026-11-10, build `first-volley`).

Why this file exists: `fight_calc.py` reports CONSTANT_DRIFT on 31 of its 60 constants (it still models the pre-#44
ward pass, body guard, health_units 16 and the 12-per-cost art lint), so its fight check is NOT ASSESSED. This script
re-implements only what the opening of a fight needs, from the GDDs as they stand on 2026-11-11:

- Combat rule 10: ms timeline; instants (pulse, both sides' art costs in slot order, requesting side's hits, the other
  side's hits); all damage lands before the defeat check; follow-up instants at the same t for arts whose guard became
  true; double knockout -> larger overkill share loses; draw within 1e-9.
- Combat Formulas A2 (cd_eff, cooldown_min 0.5 s), B (layers, L1 knee 200/0.5, caps 400/300/250/150/100), C (hit),
  E (cost = share of qi_max at start; regen 0.035 + 0.08 ln(1 + bonus/0.08)).
- Combat Defence & Healing Formulas A (resistance in points, r = R/(100+R)), A2 (flat block), C (drain bill on the
  prevented points, pay_frac, the unpaid share leaks), rule 23 (no linh luc -> no drain ward).
- Effects rule 11 / Formulas C (Down step: refusal, last act, follow-up check).
- New pieces of this build (first guesses): opening haste, Unanswered, Taut String, Eruption (from by-root
  missing-pieces), Rolling Thunder's guard; existing Effects: First Move, Flowing Water, Final Clause, Unyielding
  Breath, Glass Meridians (as numbers on the sheet), linh_luc_on_crit_pct.

Not modelled: shields (ward, body, soul), statuses and curses other than Leaking Ward, element stacks, soul arts,
companions, escapes, health regeneration. Enemy profiles are the Formulas B anchors with guessed pools (stated below).
It is a design check, not the game's combat code. Run: python -I first-volley.volley.py

STATUS: written 2026-11-11 by the unattended first-volley session and NOT RUN there (the sandbox allowed only
fight_calc.py). The sheet's numbers come from hand arithmetic with the same formulas. Run it once and compare with
first-volley.sheet.md § Fight Results before trusting either.
"""
import math
import random
import sys

U = [6.31, 15.85, 39.81, 100.0, 251.19]
SUPP = [0.0, 0.10, 0.25, 0.50, 0.75]
BLOCK_UNIT = [0.0631, 0.2031, 0.6672, 2.254, 6.883]
CAPS = [400, 300, 250, 150, 100]
CD_MIN, PULSE, BASIC_CD = 500, 1000, 1000
REGEN_BASE, REGEN_K = 0.035, 0.08
HEALTH_UNITS, QI_UNITS = 64, 26
FATIGUE_START, FATIGUE_UNITS = 60000, 0.5


def l1(x):
    eff = x if x <= 200 else 200 + 0.5 * (x - 200)
    return 1 + min(eff, CAPS[0]) / 100


def mult(x):
    m = l1(x[0])
    for i in range(1, 5):
        m *= 1 + min(max(x[i], 0), CAPS[i]) / 100
    return m


def lint(cost, cd):
    """Combat Formulas C art lint (#44: 24 per cost share, 0.25 per second of authored cooldown)."""
    return 1.0 * (1 + 24 * cost) + 0.25 * (cd - 1)


class Side:
    def __init__(self, spec, rng):
        s = dict(spec)
        self.s = s
        self.name = s["name"]
        self.r = s["realm"]
        self.u = U[self.r]
        boss = s.get("boss_pool_mult", 1.0)
        self.hp_max = HEALTH_UNITS * self.u * s["n_body"] * boss
        self.qi_max = QI_UNITS * self.u * s["n_qi"] * boss
        self.hp = self.hp_max
        self.qi = self.qi_max
        self.rng = rng
        self.arts = []
        sp = s.get("art_speed", 0) / 100
        op = s.get("opening", 0) / 100
        for i, a in enumerate(s.get("arts", [])):
            a = dict(a)
            a["slot"] = i
            a["cd_ms"] = max(CD_MIN, round(a["cd"] * 1000 / (1 + sp)))
            first_raw = a["cd"] * 1000 / (1 + sp) / (1 + op)
            a["ready"] = max(CD_MIN, round(first_raw))
            # Taut String: opening haste the floor clips becomes L5 on the first firing, 1 point per 5 pp, cap +30
            if s.get("taut_string"):
                need = a["cd"] * 1000 / (1 + sp) / CD_MIN - 1          # opening haste (as a share) that reaches the floor
                a["taut"] = min(30.0, max(0.0, (op - need) * 100 / 5))
            else:
                a["taut"] = 0.0
            a["fired"] = 0
            a["last"] = None
            self.arts.append(a)
        self.basic_next = BASIC_CD
        self.firings = 0
        self.first_move_left = bool(s.get("first_move"))
        self.refusals = s.get("refusals", 0)
        self.final_clause = bool(s.get("final_clause"))
        self.leaking_until = -1
        self.fw_count = 0
        self.dmg_in_instant = 0.0
        self.hp_at_start = self.hp
        self.fired_this_instant = 0
        self.log = []
        self.dry_at = None

    # ------------------------------------------------------------------ offence
    def m_for(self, art, enemy, instant_start_firings):
        x = list(self.s["x"])                       # L1..L4 points that apply to this build's arts
        l5 = 0.0
        if art is None:                             # the basic attack: no art-scoped L2, no art-scoped L5
            x[1] = self.s.get("basic_l2", 0)
            return mult(x + [0])
        if self.s.get("unanswered") and instant_start_firings == 0:
            l5 += self.s["unanswered"]
        if self.s.get("eruption"):
            l5 += min(25.0, 5.0 * max(0, self.fired_this_instant - 1))
        if art["fired"] == 1:                       # first firing (already counted)
            l5 += art["taut"]
        l5 += self.s.get("l5_static", 0)
        return mult(x + [l5])

    def regen(self):
        b = self.s.get("regen_bonus", 0) / 100
        return self.qi_max * (REGEN_BASE + REGEN_K * math.log(1 + b / REGEN_K))


def hit(att, dfn, c, art, t, enemy_firings_at_start, kind="lightning"):
    """One hit, Combat Formulas C then Combat Defence & Healing A, C, A2. Returns dealt."""
    ev = max(0.0, min(0.4, dfn.s.get("evade", 0) - att.s.get("accuracy", 0)))
    if ev > 0 and att.rng.random() < ev:
        att.log.append((t, art["id"] if art else "basic", "evaded", 0))
        return 0.0
    ch, cm = att.s.get("crit", (0, 1.5))
    is_crit = att.rng.random() < min(ch, 0.5)
    crit = min(cm, 3.0) if is_crit else 1.0
    gap = max(0, dfn.r - att.r)
    supp = 1 - SUPP[gap] * (1 - min(0.75, att.s.get("pierce", 0) / 100))
    D = att.u * c * att.m_for(art, dfn, enemy_firings_at_start) * crit * supp
    if not is_crit and att.s.get("noncrit_pen"):
        D *= 1 - att.s["noncrit_pen"]
    R_drain = dfn.s.get("R", 0) if dfn.qi > 1e-9 else 0.0
    R_res = dfn.s.get("R_reserved", 0)
    R = R_drain + R_res - att.s.get("pen", 0)
    r = R / (100 + R) if R >= 0 else R / 100
    prevented = D * max(0.0, r)
    a = D - prevented
    if R_drain > 0 and prevented > 0:
        prev_drain = prevented * R_drain / (R_drain + R_res)
        rate = dfn.s["rate"] * (1.5 if t <= dfn.leaking_until else 1.0)
        bill = rate * prev_drain
        pf = min(1.0, dfn.qi / bill) if bill > 0 else 1.0
        dfn.qi = max(0.0, dfn.qi - pf * bill)
        a += (1 - pf) * prev_drain
    B = BLOCK_UNIT[dfn.r] * dfn.s.get("block", 0)
    left = a - B
    dealt = 0.0 if left <= 0 else max(1.0, left)
    dfn.hp -= dealt
    dfn.dmg_in_instant += dealt
    att.log.append((t, art["id"] if art else "basic", "crit" if is_crit else "hit", round(dealt)))
    if is_crit:
        if att.s.get("on_crit_qi"):
            att.qi = min(att.qi_max, att.qi + att.s["on_crit_qi"] / 100 * att.qi_max)
        if att.s.get("flowing_water") and art is not None and att.fw_count < 3:
            att.fw_count += 1
            for o in att.arts:
                if o is not art:
                    floor = (o["last"] + CD_MIN) if o["last"] is not None else CD_MIN
                    o["ready"] = max(floor, o["ready"] - 500)
    if art is not None and art.get("leaking") and dealt > 0:
        dfn.leaking_until = t + 3000
    return dealt


def guard_ok(g, own, enemy, t):
    if not g:
        return True
    side = own if g["who"] == "own" else enemy
    share = max(side.hp, 0) / side.hp_max if g["pool"] == "health" else side.qi / side.qi_max
    return share <= g["below"] + 1e-12 if "below" in g else share >= g["above"] - 1e-12


def pay_ready(side, enemy, t, guards):
    """Art-cost step: in slot order, guard read at instant start (passed in), affordability live."""
    fired = []
    for a in side.arts:
        if a["ready"] > t or not guards[a["slot"]]:
            continue
        cost = a["cost"] * (1 - min(0.5, side.s.get("cost_red", 0) / 100)) * side.qi_max
        if side.first_move_left:
            cost, side.first_move_left = 0.0, False
        if side.qi + 1e-6 < cost:
            continue
        side.qi -= cost
        a["fired"] += 1
        a["last"] = t
        a["ready"] = t + a["cd_ms"]
        side.firings += 1
        side.fired_this_instant += 1
        fired.append(a)
    return fired


def run(player, enemy, seed=1, requesting="player", until=60000, trace=False):
    rng = random.Random(seed)
    P, E = Side(player, random.Random(seed * 7 + 1)), Side(enemy, random.Random(seed * 13 + 5))
    order = (P, E) if requesting == "player" else (E, P)
    t = 0
    next_pulse = PULSE
    result = None
    while t <= until:
        cands = [next_pulse, P.basic_next, E.basic_next] + [a["ready"] for s in (P, E) for a in s.arts]
        t = min(cands)
        if t > until:
            break
        for s in (P, E):
            s.dmg_in_instant = 0.0
            s.hp_at_start = s.hp
            s.fired_this_instant = 0
        # pulse
        if t == next_pulse:
            for s in (P, E):
                s.qi = min(s.qi_max, s.qi + s.regen())
                s.fw_count = 0
                if t >= FATIGUE_START:
                    n = 1 + (t - FATIGUE_START) // PULSE
                    s.hp -= FATIGUE_UNITS * s.u * n * n
            next_pulse += PULSE
        firings_at_start = {P: E.firings, E: P.firings}   # enemy firings this fight, read at instant start
        guards = {s: {a["slot"]: guard_ok(a.get("guard"), s, o, t) for a in s.arts} for s, o in ((P, E), (E, P))}
        fired = {s: pay_ready(s, o, t, guards[s]) for s, o in ((P, E), (E, P))}
        for s in order:
            o = E if s is P else P
            for a in fired[s]:
                hit(s, o, a["c"], a, t, firings_at_start[s])
            if s.basic_next == t:
                hit(s, o, 1.0, None, t, firings_at_start[s], kind="physical")
        for s in (P, E):
            if s.basic_next == t:
                s.basic_next += BASIC_CD
        result = defeat_check(P, E, order, t)
        # follow-up instants at the same t
        while result is None:
            for s in (P, E):
                s.fired_this_instant = 0
            firings_at_start = {P: E.firings, E: P.firings}
            guards = {s: {a["slot"]: guard_ok(a.get("guard"), s, o, t) for a in s.arts} for s, o in ((P, E), (E, P))}
            fired = {s: pay_ready(s, o, t, guards[s]) for s, o in ((P, E), (E, P))}
            if not fired[P] and not fired[E]:
                break
            for s in order:
                o = E if s is P else P
                for a in fired[s]:
                    hit(s, o, a["c"], a, t, firings_at_start[s])
            result = defeat_check(P, E, order, t)
        for s in (P, E):
            if s.dry_at is None and s.qi < 0.05 * s.qi_max:
                s.dry_at = t
        if result is not None:
            break
        if trace and t <= 6000:
            print(f"t={t/1000:6.3f}  P hp {P.hp:9.0f} qi {P.qi:7.0f} | E hp {E.hp:10.0f} qi {E.qi:8.0f}")
    if result is None:
        result = ("unfinished", t)
    return result, P, E


def defeat_check(P, E, order, t):
    for s in order:                                 # step 1: refusals
        if s.hp <= 0 and s.refusals > 0:
            s.refusals -= 1
            s.hp = 1.0
            s.log.append((t, "refusal", "", 1))
    for s in order:                                 # step 2: last acts
        o = E if s is P else P
        if s.hp <= 0 and s.final_clause:
            s.final_clause = False
            art = max(s.arts, key=lambda a: (a["cd"], -a["slot"]))
            hit(s, o, art["c"], art, t, o.firings)
            s.log.append((t, "final clause", art["id"], 0))
    for s in order:                                 # step 3: a side the last act put Down may still refuse
        if s.hp <= 0 and s.refusals > 0:
            s.refusals -= 1
            s.hp = 1.0
    pd, ed = P.hp <= 0, E.hp <= 0
    if pd and ed:
        sp = max(0.0, P.dmg_in_instant - P.hp_at_start) / P.hp_max
        se = max(0.0, E.dmg_in_instant - E.hp_at_start) / E.hp_max
        if abs(sp - se) < 1e-9:
            return ("draw", t)
        return ("P", t, "overkill") if sp < se else ("E", t, "overkill")
    if ed:
        return ("P", t)
    if pd:
        return ("E", t)
    return None


# ---------------------------------------------------------------------------------------------- profiles
# Nascent Soul (Nguyen Anh, realm index 3). Pools: n_body / n_qi are guesses from the Formulas B W shares at the
# 2026-11-10 prices (health 0.6 W per %, linh luc 1.0 W per %); the GDD marks these cells "re-derive".
NA = 3

def player(**over):
    """The build at Nascent Soul, foreseen fight, all layers at the top-end anchors (L2 300, L3 250, L4 150)."""
    s = dict(
        name="first-volley", realm=NA, n_body=1.5 * 0.75 * 0.85, n_qi=1.5,   # Glass Meridians -25 %, Unyielding Breath -15 %
        x=[360, 300, 250, 150],                    # L1 raw 360 (knee: counts as 280), L2..L4 at their caps
        crit=(0.5, 3.0), accuracy=0.15, art_speed=200, opening=250, cost_red=20, regen_bonus=0.35,
        R=557, rate=0.328 / (1.625 * 1.625), block=17.7,            # a typical Nascent Soul Common Ward
        unanswered=40, eruption=True, taut_string=True, first_move=True, flowing_water=True,
        on_crit_qi=1.26, refusals=1, final_clause=True, basic_l2=0,
        arts=[
            dict(id="cloud_splitting_bolt", c=round(lint(0.10, 4), 2), cost=0.10, cd=4),   # the Breaker, 4.15
            dict(id="forked_light", c=round(lint(0.025, 4), 2), cost=0.025, cd=4),        # 2.35
            dict(id="thunder_needle", c=round(lint(0.025, 4), 2), cost=0.025, cd=4, leaking=True),
            dict(id="iron_spark", c=round(lint(0.025, 4), 2), cost=0.025, cd=4),          # its conversion is not modelled
            dict(id="rolling_thunder", c=round(lint(0.05, 4), 2), cost=0.05, cd=4,          # the finisher, 2.95
                 guard={"who": "enemy", "pool": "health", "below": 0.5}),
            # slot 6 holds Lightning Step (escape), which this script does not model
        ],
    )
    s.update(over)
    return s


def typical(**over):
    s = dict(name="typical", realm=NA, n_body=1.8, n_qi=1.3, x=[37, 40, 40, 20], crit=(0.15, 1.7), art_speed=20,
             R=557, rate=0.328 / (1.625 * 1.625), block=17.7, basic_l2=40,
             arts=[dict(id="quick", c=round(lint(0.03, 2) * 0.9, 2), cost=0.03, cd=2),
                   dict(id="main", c=round(lint(0.05, 4) * 0.9, 2), cost=0.05, cd=4),
                   dict(id="big", c=round(lint(0.08, 8) * 0.9, 2), cost=0.08, cd=8)])
    s.update(over)
    return s


def top_end(**over):
    """Top-end anchor: M 256 at Nascent Soul (L1 3.66: x 332), 50 % crits of x2, resistance about 1,500 points.
    ws 224 and we 205 from 10 % / 7.5 % W shares plus artifact defence 5 x B_p, so the drain rate is
    0.328 / (3.24 x 3.05). Its opener is a costly 1 s art at +100 % art speed: it fires at the 0.5 s floor."""
    s = dict(name="top_end", realm=NA, n_body=3.5, n_qi=1.55, x=[332, 300, 250, 100], crit=(0.5, 2.0),
             art_speed=100, R=1500, rate=0.328 / (3.24 * 3.05), block=21, basic_l2=0, l5_static=100,
             arts=[dict(id="opener", c=lint(0.125, 1), cost=0.125, cd=1),
                   dict(id="main", c=lint(0.10, 4), cost=0.10, cd=4),
                   dict(id="big", c=lint(0.125, 8), cost=0.125, cd=8)])
    s.update(over)
    return s


SCENARIOS = [
    ("typical NA, foreseen", lambda: player(), lambda: typical()),
    ("typical NA, blind (L4 = 0)", lambda: player(x=[360, 300, 250, 0]), lambda: typical()),
    ("top-end peer, opener at 0.5 s", lambda: player(), lambda: top_end()),
    ("top-end peer, its opener at 1.0 s", lambda: player(), lambda: top_end(art_speed=0)),
    ("top-end peer + refusal (Unyielding Breath)", lambda: player(), lambda: top_end(refusals=1)),
    ("top-end peer, 40 % evade", lambda: player(), lambda: top_end(evade=0.40)),
    ("top-end peer, reserved ward 1,000 pts", lambda: player(), lambda: top_end(R_reserved=1000)),
    ("mirror: another first-volley build", lambda: player(), lambda: player(name="mirror")),
    ("boss: top-end x boss_pool_mult 10", lambda: player(), lambda: top_end(boss_pool_mult=10, art_speed=0)),
    ("boss x10, Lightning-warded (+1,500 reserved)", lambda: player(),
     lambda: top_end(boss_pool_mult=10, art_speed=0, R_reserved=1500)),
    ("realm above: top-end Hoa Than", lambda: player(), lambda: top_end(realm=4, art_speed=0)),
]

WITHOUT = {
    "opening_haste": dict(opening=0, taut_string=False),
    "unanswered": dict(unanswered=0),
    "rolling_thunder_guard": "drop_finisher",
    "glass_meridians": dict(art_speed=160, n_body=1.5 * 0.85),
}


def apply_without(spec, key):
    w = WITHOUT[key]
    if w == "drop_finisher":
        spec = dict(spec)
        spec["arts"] = [a for a in spec["arts"] if a["id"] != "rolling_thunder"]
        return spec
    spec = dict(spec)
    spec.update(w)
    return spec


def table(without=None, seeds=200):
    head = f"{'scenario':46} {'P win':>6} {'E win':>6} {'draw':>5} {'mean t s':>8}  {'by overkill':>11}"
    print(head)
    for name, pf, ef in SCENARIOS:
        pw = ew = dr = ok = 0
        ts = []
        for sd in range(seeds):
            p = pf()
            if without:
                p = apply_without(p, without)
            res, P, E = run(p, ef(), seed=sd)
            ts.append(res[1])
            if res[0] == "P":
                pw += 1
            elif res[0] == "E":
                ew += 1
            else:
                dr += 1
            if len(res) > 2:
                ok += 1
        print(f"{name:46} {pw/seeds:6.0%} {ew/seeds:6.0%} {dr/seeds:5.0%} {sum(ts)/len(ts)/1000:8.3f}  {ok/seeds:11.0%}")


def opening_report():
    p = Side(player(), random.Random(1))
    print("art                    cd_eff  first firing  Taut String L5   c_art  cost")
    for a in p.arts:
        print(f"{a['id']:22} {a['cd_ms']/1000:6.3f}  {a['ready']/1000:12.3f}  {a['taut']:14.1f}  {a['c']:6.2f}  {a['cost']:.3f}")
    x = p.s["x"]
    print(f"M (L1..L4, L5 0) = {mult(x + [0]):.1f};  first volley L5 (Unanswered 40 + Eruption 15 + Taut String) = "
          f"{min(100, 40 + 15 + p.arts[0]['taut']):.1f} -> M {mult(x + [min(100, 40 + 15 + p.arts[0]['taut'])]):.1f}")
    print(f"health_max {p.hp_max:.0f}, qi_max {p.qi_max:.0f}")
    for nm, f in (("typical", typical), ("top_end", top_end)):
        e = Side(f(), random.Random(1))
        print(f"{nm:8} health_max {e.hp_max:9.0f} qi_max {e.qi_max:8.0f} M {mult(e.s['x'] + [e.s.get('l5_static', 0)]):6.1f}"
              f" first art at {min(a['ready'] for a in e.arts)/1000:.3f} s")


if __name__ == "__main__":
    args = sys.argv[1:]
    if args and args[0] == "--trace":
        idx = int(args[1]) if len(args) > 1 else 2
        name, pf, ef = SCENARIOS[idx]
        print(name)
        res, P, E = run(pf(), ef(), seed=int(args[2]) if len(args) > 2 else 1, trace=True)
        for row in (P.log + E.log)[:40]:
            print(row)
        print(res)
    elif args and args[0] == "--without":
        print(f"WITHOUT {args[1]}")
        table(without=args[1])
    else:
        opening_report()
        print()
        table()
