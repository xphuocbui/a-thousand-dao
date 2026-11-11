"""Paper model for the bare-fist build (overnight 2026-11-10, design-build).

Why this file exists: `.claude/skills/design-build/scripts/fight_calc.py` passes its selftest but reports
CONSTANT_DRIFT on 31 of 60 constants (health_units 16 vs 64, the retired guard model, regen_base 0.02 vs
0.035, the anchors), so its fight check is NOT ASSESSED. This model reuses the canonical #44 simulator's
constants (`tools/design/combat_sim/sim.py`: fight units, block units, suppression, regeneration curve,
health x4, fatigue) and adds what the build needs and sim.py lacks:

- layered wards with points resistance (combat-defence.md Formulas A), drain bills split by share and
  falling with ws and we (Formulas C), reserved wards and the usable maximum (rule 10), ward block and
  evade payloads scaled by ws, standing ward shields with recharge (Formulas B);
- an event timeline in whole milliseconds (combat.md rule 10): pulse, art costs, the requesting side's
  hits (arts in slot order, then the basic attack), the other side's hits, defeat check;
- the basic attack with its own coefficient, cooldown and layer stack (new keys `basic_coef_add`,
  `basic_speed_pct`), conditional L5 read at instant start;
- Effects: Stored Breath (overflow banks basic coefficient), Still Water (existing), Steady Breath
  (existing), Full Sea (catalogue), Bare Rack (existing), Settled Dust (Earth buff on basic hits),
  Unyielding Breath (existing keystone).

It is a paper model with seeded chance (20 seeds), not the game. Numbers on new pieces are first guesses.

Run:  python design/builds/overnight-2026-11-10/builds/bare-fist.sim.py --realm 3
      python ... --realm 3 --without stored_breath
      python ... --realm 3 --trace top_end
"""
import argparse
import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "design", "combat_sim"))
import sim as S  # noqa: E402  canonical #44 constants

U = S.U
BU = S.BLOCK_UNIT
SUPP = S.SUPP
REGEN_BASE = S.K["regen_base"]
REGEN_K = S.K["regen_k"]
HEALTH_UNITS = 16 * S.K["health_mult"]   # 64 (combat.md Formulas A)
QI_UNITS = 26
FAT_START = int(S.K["fatigue_start"] * 1000)
EVADE_CAP = S.K["evade_cap"]
COOLDOWN_MIN = 500
REALMS = ["Luyen Khi", "Truc Co", "Ket Dan", "Nguyen Anh", "Hoa Than"]

# ---------------------------------------------------------------- wards (combat-defence.md Formulas H)
WARDS = {
    "common": dict(name="Common Ward", R={"all": 342.5}, pay="drain", drain=0.328),
    "qi_scatter": dict(name="Qi-Scattering Robe", R={"force": 220}, pay="drain", drain=0.264),
    "fire_veil": dict(name="Fire-Shunning Veil", R={"fire": 300}, pay="drain", drain=0.22),
    "still_lake": dict(name="Still Lake Aura", R={"all": 50.9}, pay="reserved", reserve=0.71),
    "iron_shirt": dict(name="Iron Shirt", block=60, evade=12, pay="reserved", reserve=0.47),
    "mountain": dict(name="Mountain Screen", shield=0.27, pay="reserved", reserve=0.06),
    "cloud": dict(name="Thousand-Layer Cloud", shield=0.20, pay="reserved", reserve=0.044),
    "clear_heart": dict(name="Clear Heart Ward", pay="reserved", reserve=0.25),
    "soul_lamp": dict(name="Soul-Guarding Lamp", pay="reserved", reserve=0.20),
}
DEFAULT_WARD = dict(name="default", R={"all": 60}, pay="drain", drain=0.40)


def layer_mult(x):
    """combat.md Formulas B: L1 soft cap at 200 (slope 0.5), hard caps 400/300/250/150/100."""
    caps = [400, 300, 250, 150, 100]
    x1 = x[0] if x[0] <= 200 else 200 + 0.5 * (x[0] - 200)
    m = 1 + min(x1, caps[0]) / 100
    for i in range(1, 5):
        m *= 1 + min(x[i], caps[i]) / 100
    return m


class Fighter:
    def __init__(self, name, r, **kw):
        self.name = name
        self.r = r
        self.stage = 1.0
        self.n_body = kw.get("n_body", 1.0883)
        self.n_qi = kw.get("n_qi", 1.053)
        # offence
        self.arts = kw.get("arts", [])            # dicts: c, cost, cd, dtype, kind ('hit' or 'qi_burn'), stacks
        self.art_speed = kw.get("art_speed", 0.0)
        self.M_art = kw.get("M_art", 3.273)
        self.crit = kw.get("crit", 0.15)
        self.crit_mult = kw.get("crit_mult", 1.7)
        self.basic_c0 = kw.get("basic_c0", 1.0)
        self.basic_speed = kw.get("basic_speed", 0.0)       # basic_speed_pct, percentage points
        self.basic_x = kw.get("basic_x", None)              # layer points for the basic attack; None = M_art
        self.basic_dtype = kw.get("basic_dtype", "phys")
        self.pen = kw.get("pen", {})                        # resist_pen_pct by type, points
        self.acc = kw.get("acc", 0.0)
        # defence
        self.ward_ids = kw.get("wards", ["common"])
        self.ws = kw.get("ws", 30.8)
        self.we = kw.get("we", 30.8)
        self.res_eff = kw.get("res_eff", 0.0)
        self.block_other = kw.get("block_other", 15.0)      # rating: flesh + gear + body technique
        self.R_other = kw.get("R_other", {})                # resistance from items, body, Way (not ws-scaled)
        self.body_shield = kw.get("body_shield", 0.0)       # share of health_max
        self.evade_other = kw.get("evade_other", 0.0)
        self.regen_bonus = kw.get("regen_bonus", 0.0)
        self.hregen = kw.get("hregen", 0.0)
        self.empty_slots = kw.get("empty_slots", 0)
        # effects (all off by default)
        self.fx = kw.get("fx", {})
        # derived pools
        self.hp_max = HEALTH_UNITS * U[r] * self.n_body * kw.get("boss_mult", 1.0)
        self.qi_max = QI_UNITS * U[r] * self.n_qi * kw.get("boss_mult", 1.0)
        self.wards = [WARDS[w] for w in self.ward_ids]
        reserved = 0.0
        for w in self.wards:
            if w["pay"] == "reserved":
                reserved += w["reserve"] * (1 - min(self.res_eff, 50) / 100) / (1 + self.we / 200)
        self.reserved = min(reserved, 0.9)
        self.usable = self.qi_max * (1 - self.reserved)
        self.hp = self.hp_max
        self.qi = self.usable
        self.shields = []
        for w in self.wards:
            if w.get("shield"):
                v = w["shield"] * self.qi_max * (1 + self.ws / 100)
                self.shields.append({"name": w["name"], "max": v, "val": v, "last": -10_000})
        self.body_sh = self.body_shield * self.hp_max
        # timers (ms)
        self.ready = [self._cd(a["cd"]) for a in self.arts]
        self.basic_cd = max(COOLDOWN_MIN, round(1000 / (1 + self.basic_speed / 100)))
        self.basic_next = self.basic_cd
        # state
        self.bank = 0.0
        self.earth = []          # [stacks, t_end_ms]
        self.qi_dis = []         # Qi Disruption on this side: [stacks, pulses_left, src]
        self.unyielding_used = False
        self.stats = dict(dealt=0.0, basics=0, bank_spent=0.0, bank_hits=0, overflow=0.0, pulses=0,
                          dry_at=None, healed=0.0, ward_down_pulses=0, fatigue=0.0, cap_hits=set(),
                          bank_capped=0)

    def _cd(self, cd):
        return max(COOLDOWN_MIN, round(cd * 1000 / (1 + self.art_speed / 100)))

    # ---- defence helpers
    def earth_dampen(self):
        p = self.fx.get("settled_dust", {}).get("power", 1.0)
        return 0.011 * sum(s for s, _ in self.earth) * p

    def evade(self):
        e = self.evade_other
        for w in self.wards:
            if w.get("evade") and self.ward_up(w):
                e += w["evade"] * (1 + self.ws / 100)
        return e / 100

    def ward_up(self, w):
        return w["pay"] == "reserved" or self.qi > 1e-9

    def block_points(self):
        b = self.block_other
        for w in self.wards:
            if w.get("block") and self.ward_up(w):
                b += w["block"] * (1 + self.ws / 100)
        return BU[self.r] * self.stage * b

    def regen(self):
        return self.qi_max * (REGEN_BASE + REGEN_K * math.log(1 + self.regen_bonus / REGEN_K))

    # ---- offence helpers
    def basic_M(self):
        if self.basic_x is None:
            return self.M_art, 0
        x = list(self.basic_x)
        l5 = 0
        share = self.qi / self.usable if self.usable > 0 else 0
        if self.fx.get("steady_breath") and share >= 0.5:
            l5 += self.fx["steady_breath"]
        if self.fx.get("full_sea") and share >= 0.8:
            l5 += self.fx["full_sea"]
        if self.fx.get("bare_rack"):
            l5 += min(20, 5 * self.empty_slots)
        x[4] += l5
        if x[4] > 100:
            self.stats["cap_hits"].add("L5 cap 100")
        return layer_mult(x), l5


def hit(att, dfn, c, M, dtype, rng, t, kind="hit"):
    """One hit, combat-defence.md rule 1: evade, resistance, block, shields, health. Returns dealt."""
    p_ev = min(EVADE_CAP, max(0.0, dfn.evade() - att.acc / 100))
    if rng.random() < p_ev:
        return 0.0
    crit = att.crit_mult if rng.random() < min(0.5, att.crit) else 1.0
    gap = max(0, dfn.r - att.r)
    D = U[att.r] * att.stage * c * M * crit * (1 - SUPP[min(gap, 4)])
    if dtype == "phys":
        D /= 1 + dfn.earth_dampen()
    # resistance terms
    terms = []
    has_payload = False
    for w in dfn.wards:
        if w.get("block"):
            has_payload = True
        pts = w.get("R", {}).get("all", 0) + w.get("R", {}).get(dtype, 0)
        if pts and dfn.ward_up(w):
            has_payload = True
            rate = w["drain"] / ((1 + dfn.ws / 100) * (1 + dfn.we / 100)) if w["pay"] == "drain" else 0.0
            terms.append((pts * (1 + dfn.ws / 100), rate))
        elif pts:
            has_payload = has_payload or False
    if not has_payload and dfn.qi > 1e-9 and not dfn.fx.get("no_default_ward"):
        terms.append((DEFAULT_WARD["R"]["all"], DEFAULT_WARD["drain"]))
    R_other = dfn.R_other.get("all", 0) + dfn.R_other.get(dtype, 0)
    R_pos = R_other + sum(p for p, _ in terms)
    R = R_pos - att.pen.get(dtype, 0) - att.pen.get("all", 0)
    r = R / (100 + R) if R >= 0 else R / 100
    prevented = D * max(0.0, r)
    a = D * (1 - r) if r < 0 else D - prevented
    if R_pos > 0 and prevented > 0:
        bill = sum(prevented * p / R_pos * rate for p, rate in terms)
        drain_share = sum(p for p, rate in terms if rate > 0) / R_pos
        if bill > dfn.qi + 1e-9:
            frac = dfn.qi / bill
            a += (1 - frac) * prevented * drain_share
            dfn.qi = 0.0
        else:
            dfn.qi -= bill
    if kind == "hit":
        a = max(0.0, a - dfn.block_points())
    for sh in dfn.shields:
        if a <= 0:
            break
        soak = min(sh["val"], a)
        if soak > 0:
            sh["val"] -= soak
            sh["last"] = t
            a -= soak
    if dfn.body_sh > 0 and a > 0 and dtype != "chaos":
        soak = min(dfn.body_sh, a)
        dfn.body_sh -= soak
        a -= soak
    dealt = 0.0 if a <= 0 else max(1.0, a)
    dfn.hp -= dealt
    att.stats["dealt"] += dealt
    return dealt


def pulse(s, o, t):
    st = s.stats
    st["pulses"] += 1
    # Qi Disruption on s: a Force tick on linh lucc, resistance all + force, passes shields (combat-defence rule 1)
    keep = []
    for stacks, left, src in s.qi_dis:
        burn = U[src.r] * 0.30 * stacks * src.M_art
        R = s.R_other.get("all", 0) + s.R_other.get("force", 0)
        for w in s.wards:
            if s.ward_up(w):
                R += (w.get("R", {}).get("all", 0) + w.get("R", {}).get("force", 0)) * (1 + s.ws / 100)
        burn *= 100 / (100 + R)
        s.qi = max(0.0, s.qi - burn)
        if left > 1:
            keep.append([stacks, left - 1, src])
    s.qi_dis = keep
    # regeneration and overflow (effects.md rule 5: overflow is the regeneration lost to a full pool)
    reg = s.regen()
    over = max(0.0, s.qi + reg - s.usable)
    s.qi = min(s.usable, s.qi + reg)
    st["overflow"] += over
    sb = s.fx.get("stored_breath")
    if sb and over > 0:
        add = sb["k"] * 100 * over / s.qi_max
        if s.bank + add > sb["cap"]:
            st["bank_capped"] += 1
            st["cap_hits"].add("Stored Breath cap")
        s.bank = min(sb["cap"], s.bank + add)
    if s.fx.get("still_water") and over > 0:
        got = min(0.5 * over, s.hp_max - s.hp)
        s.hp += got
        st["healed"] += got
    if s.hregen:
        got = min(s.hregen * s.hp_max, s.hp_max - s.hp)
        s.hp += got
        st["healed"] += got
    # standing ward shields recharge after 2 s without soaking (combat-defence.md Formulas B)
    for sh in s.shields:
        if t - sh["last"] >= 2000:
            sh["val"] = min(sh["max"], sh["val"] + 0.25 * sh["max"] * (1 + s.we / 100))
    # fatigue (combat.md rule 10)
    if t >= FAT_START:
        n = 1 + (t - FAT_START) // 1000
        f = 0.5 * U[s.r] * n ** 2
        s.hp -= f
        st["fatigue"] += f
    s.earth = [e for e in s.earth if e[1] > t]
    if s.qi < 0.05 * s.usable and st["dry_at"] is None:
        st["dry_at"] = t / 1000
    if s.qi <= 1e-9:
        st["ward_down_pulses"] += 1


def fire_list(s, t):
    """Art costs in slot order; returns the arts that fire this instant."""
    out = []
    for i, a in enumerate(s.arts):
        if s.ready[i] <= t:
            cost = a["cost"] * 0.5 * s.qi_max   # #44 cost_scale, as sim.py
            if s.qi + 1e-6 >= cost:
                s.qi -= cost
                s.ready[i] = t + s._cd(a["cd"])
                out.append(a)
    return out


def resolve_hits(s, o, t, arts, rng):
    for a in arts:
        if a.get("kind") == "qi_burn":
            if rng.random() >= max(0.0, o.evade()):   # an art hit carries it; evaded = nothing
                o.qi_dis.append([a.get("stacks", 3), 3, s])
                hit(s, o, a["c"], s.M_art, a.get("dtype", "force"), rng, t)
        else:
            hit(s, o, a["c"], s.M_art, a.get("dtype", "phys"), rng, t)
    if s.basic_next == t:
        M, _ = s.basic_M()
        c = s.basic_c0
        if s.bank > 0:
            c += s.bank
            s.stats["bank_spent"] += s.bank
            s.stats["bank_hits"] += 1
            s.bank = 0.0
        d = hit(s, o, c, M, s.basic_dtype, rng, t)
        s.stats["basics"] += 1
        sd = s.fx.get("settled_dust")
        if sd and d >= 0:
            s.earth.append([sd["stacks"], t + sd["ms"]])
        s.basic_next += s.basic_cd


def fight(a, b, seed=1, trace=False, limit_ms=120_000):
    rng = random.Random(seed)
    t = 0
    next_pulse = 1000
    rows = []
    while t <= limit_ms:
        cands = [next_pulse, a.basic_next, b.basic_next]
        for s in (a, b):
            cands += [r for r in s.ready if r > t]
        t = min(cands)
        if t == next_pulse:
            pulse(a, b, t)
            pulse(b, a, t)
            next_pulse += 1000
            if trace:
                rows.append((t / 1000, a.hp / a.hp_max, a.qi / a.usable, a.bank, b.hp / b.hp_max,
                             b.qi / max(b.usable, 1e-9)))
        fa = fire_list(a, t)
        fb = fire_list(b, t)
        resolve_hits(a, b, t, fa, rng)       # a is the requesting side
        resolve_hits(b, a, t, fb, rng)
        for s in (a, b):
            if s.hp <= 0 and s.fx.get("unyielding") and not s.unyielding_used:
                s.unyielding_used = True
                s.hp = 1.0
        if a.hp <= 0 or b.hp <= 0:
            break
        # avoid re-processing the same ms
        if t == next_pulse - 1000 and a.basic_next != t and b.basic_next != t:
            pass
    if a.hp <= 0 and b.hp <= 0:
        oa, ob = -a.hp / a.hp_max, -b.hp / b.hp_max
        win = "draw" if abs(oa - ob) < 1e-9 else ("A" if oa < ob else "B")
    elif b.hp <= 0:
        win = "A"
    elif a.hp <= 0:
        win = "B"
    else:
        win = "time"
    return dict(t=t / 1000, win=win, a=a, b=b, rows=rows)


# ---------------------------------------------------------------- profiles
TYP_M = [3.27, 4.19, 5.48, 7.37, 8.96]
TOP_M = [103, 148, 210, 256, 325]
TYP_WS = [30.8, 37.9, 47.9, 62.5, 84.1]
TOP_R = [900, 1000, 1200, 1500, 1900]
TYP_BLOCK = [15.0, 15.7, 16.4, 17.7, 19.2]
TOP_BLOCK = [17, 18, 19, 21, 23]
TETU_BLOCK = [88, 95, 100, 105, 110]


def kit(dtype="phys"):
    return [dict(c=a.c, cost=a.cost, cd=a.cd, dtype=dtype) for a in S.kit()]


def enemy(name, r):
    if name == "typical":
        return Fighter("typical", r, M_art=TYP_M[r], arts=kit(), ws=TYP_WS[r], we=TYP_WS[r],
                       block_other=TYP_BLOCK[r])
    if name in ("top_end", "top_end_fire"):
        ws = TOP_R[r] / 342.5 * 100 - 100
        return Fighter(name, r, M_art=TOP_M[r], arts=kit("fire" if name.endswith("fire") else "phys"),
                       art_speed=60, crit=0.5, crit_mult=2.0, n_body=1.3, n_qi=1.3, ws=ws, we=0.75 * ws,
                       block_other=TOP_BLOCK[r], regen_bonus=0.03)
    if name == "the_tu":   # thể tu: block, body shield, Physical resistance, default ward only
        return Fighter("the_tu", r, M_art=TYP_M[r] * 1.2, arts=kit(), wards=[], block_other=TETU_BLOCK[r],
                       R_other={"phys": 36.1}, body_shield=0.9, n_body=1.103)
    if name == "phys_wall":   # Combat rule 18: high resistance to Physical/Force (150+ points)
        return Fighter("phys_wall", r, M_art=TYP_M[r], arts=kit(), ws=TYP_WS[r], we=TYP_WS[r],
                       block_other=TYP_BLOCK[r], R_other={"phys": 300})
    if name == "drainer":     # Combat rule 18: drains linh luc hard (Qi Disruption)
        arts = kit()
        arts[1] = dict(c=arts[1]["c"] * 0.7, cost=arts[1]["cost"], cd=3.0, dtype="force", kind="qi_burn", stacks=3)
        return Fighter("drainer", r, M_art=TYP_M[r], arts=arts, ws=TYP_WS[r], we=TYP_WS[r],
                       block_other=TYP_BLOCK[r])
    if name == "top_drainer":
        ws = TOP_R[r] / 342.5 * 100 - 100
        arts = kit()
        arts[1] = dict(c=arts[1]["c"] * 0.7, cost=arts[1]["cost"], cd=3.0, dtype="force", kind="qi_burn", stacks=3)
        return Fighter("top_drainer", r, M_art=TOP_M[r], arts=arts, art_speed=60, crit=0.5, crit_mult=2.0,
                       n_body=1.3, n_qi=1.3, ws=ws, we=0.75 * ws, block_other=TOP_BLOCK[r], regen_bonus=0.03)
    raise ValueError(name)


# The build, realm by realm (first guesses; see bare-fist.sheet.md "Layer totals" and "Loadout by Realm").
BUILD = {
    0: dict(n_body=1.2, n_qi=1.1, basic_c0=1.2, basic_speed=0, basic_x=[45, 40, 60, 40, 0], crit=0.15,
            crit_mult=1.6, pen={"phys": 0}, ws=40, we=35, res_eff=0, regen_bonus=0.025,
            wards=["common", "mountain", "cloud"], empty_slots=1, block_other=4.4 * 1.2 + 12 * 0.5,
            fx=dict(stored_breath=dict(k=0.10, cap=1.2), still_water=True, steady_breath=12,
                    settled_dust=dict(stacks=1, ms=4000, power=1.16))),
    1: dict(n_body=1.3, n_qi=1.2, basic_c0=1.5, basic_speed=15, basic_x=[90, 80, 110, 60, 0], crit=0.25,
            crit_mult=1.8, pen={"phys": 15}, ws=75, we=165, res_eff=10, regen_bonus=0.04,
            wards=["common", "mountain", "cloud", "clear_heart"], empty_slots=1,
            block_other=4.4 * 1.3 + 12 * 1.0,
            fx=dict(stored_breath=dict(k=0.10, cap=1.2), still_water=True, steady_breath=12, full_sea=30,
                    settled_dust=dict(stacks=1, ms=4000, power=1.16))),
    2: dict(n_body=1.4, n_qi=1.25, basic_c0=1.9, basic_speed=30, basic_x=[160, 200, 200, 120, 0], crit=0.35,
            crit_mult=1.9, pen={"phys": 30}, ws=110, we=200, res_eff=20, regen_bonus=0.075,
            wards=["common", "qi_scatter", "mountain", "cloud", "iron_shirt", "clear_heart", "soul_lamp"],
            empty_slots=0, block_other=4.4 * 1.4 + 12 * 1.0 + 20,
            fx=dict(stored_breath=dict(k=0.10, cap=1.2), still_water=True, steady_breath=12, full_sea=30,
                    settled_dust=dict(stacks=1, ms=4000, power=1.18), unyielding=True)),
    # Nguyen Anh, duel loadout (sheet): Common, Qi-Scattering, Fire-Shunning, Soul Lamp in ward slots;
    # Mountain Screen, Thousand-Layer Cloud and four empty art slots. R_other 220 Physical from body pieces.
    # Road loadout: add "iron_shirt", "clear_heart" and set empty_slots=2.
    3: dict(n_body=1.5, n_qi=1.3, basic_c0=2.2, basic_speed=50, basic_x=[300, 280, 250, 150, 0], crit=0.45,
            crit_mult=2.1, pen={"phys": 60}, ws=200, we=300, res_eff=30, regen_bonus=0.09,
            R_other={"phys": 220},
            wards=["common", "qi_scatter", "fire_veil", "soul_lamp", "mountain", "cloud"],
            empty_slots=4, block_other=4.4 * 1.5 + 12 * 1.0 + 30,
            fx=dict(stored_breath=dict(k=0.10, cap=1.2), still_water=True, steady_breath=12, full_sea=30,
                    bare_rack=True, settled_dust=dict(stacks=1, ms=4000, power=1.18), unyielding=True)),
    4: dict(n_body=1.6, n_qi=1.4, basic_c0=2.6, basic_speed=70, basic_x=[400, 300, 250, 150, 0], crit=0.5,
            crit_mult=2.3, pen={"phys": 90}, ws=260, we=380, res_eff=40, regen_bonus=0.10,
            R_other={"phys": 300},
            wards=["common", "qi_scatter", "fire_veil", "soul_lamp", "clear_heart", "mountain", "cloud",
                   "iron_shirt"],
            empty_slots=4, block_other=4.4 * 1.6 + 12 * 1.0 + 40,
            fx=dict(stored_breath=dict(k=0.10, cap=1.2), still_water=True, steady_breath=12, full_sea=30,
                    bare_rack=True, settled_dust=dict(stacks=1, ms=4000, power=1.2), unyielding=True)),
}


def bare_fist(r, without=(), blind=False):
    kw = dict(BUILD[r])
    kw["fx"] = dict(kw["fx"])
    kw["basic_x"] = list(kw["basic_x"])
    for w in without:
        if w in kw["fx"]:
            del kw["fx"][w]
        elif w == "basic_coef_add":
            kw["basic_c0"] = 1.0
        elif w == "basic_speed":
            kw["basic_speed"] = 0
        elif w == "auras":
            kw["wards"] = [x for x in kw["wards"] if WARDS[x]["pay"] == "drain"]
        elif w == "regen":
            kw["regen_bonus"] = 0.0
        elif w == "closed_hand":
            kw["we"] -= 100   # Closed Hand Vow is folded into ward efficiency from Truc Co (r >= 1)
    if blind:
        kw["basic_x"][3] = 0
    if "unyielding" in kw["fx"]:
        kw["n_body"] *= 0.85   # Unyielding Breath closes: maximum health -15 %
    return Fighter("bare-fist", r, arts=[], **kw)


def run(r, names, seeds=20, without=(), blind=False, gap=0):
    print(f"realm {REALMS[r]}  without={list(without) or '-'}  blind={blind}  gap={gap}")
    probe = bare_fist(r, without, blind)
    M0, l5 = probe.basic_M()
    print(f"  bare-fist: health {probe.hp_max:.0f}, linh luc {probe.qi_max:.0f} (usable {probe.usable:.0f}, "
          f"reserved {probe.reserved:.2f}), basic c0 {probe.basic_c0}, cd {probe.basic_cd} ms, "
          f"M_basic {M0:.1f} (L5 {l5}), block {probe.block_points():.1f} pts, evade {probe.evade():.2f}, "
          f"regen {probe.regen() / probe.qi_max:.4f}/pulse")
    print(f"  {'enemy':12} {'win':>4} {'loss':>4} {'mean s':>7} {'hp left':>7} {'own dry':>7} {'foe dry':>7} "
          f"{'bank/hit':>8} {'bank share':>10} {'healed':>7} caps")
    for n in names:
        res = []
        for sd in range(seeds):
            a = bare_fist(r + 0, without, blind)
            b = enemy(n, min(4, r + gap))
            res.append(fight(a, b, seed=sd))
        w = sum(x["win"] == "A" for x in res)
        lo = sum(x["win"] == "B" for x in res)
        mt = sum(x["t"] for x in res) / len(res)
        hp = sum(max(0, x["a"].hp) / x["a"].hp_max for x in res) / len(res)
        dry = [x["a"].stats["dry_at"] for x in res if x["a"].stats["dry_at"] is not None]
        fdry = [x["b"].stats["dry_at"] for x in res if x["b"].stats["dry_at"] is not None]
        bh = sum(x["a"].stats["bank_hits"] for x in res)
        bs = sum(x["a"].stats["bank_spent"] for x in res)
        basics = sum(x["a"].stats["basics"] for x in res)
        c0 = res[0]["a"].basic_c0
        share = bs / (bs + c0 * basics) if basics else 0
        healed = sum(x["a"].stats["healed"] / x["a"].hp_max for x in res) / len(res)
        caps = set().union(*[x["a"].stats["cap_hits"] for x in res])
        print(f"  {n:12} {w:4d} {lo:4d} {mt:7.1f} {hp:7.2f} "
              f"{(sum(dry) / len(dry)) if len(dry) > len(res) / 2 else float('nan'):7.1f} "
              f"{(sum(fdry) / len(fdry)) if len(fdry) > len(res) / 2 else float('nan'):7.1f} "
              f"{(bs / bh) if bh else 0:8.2f} {share:10.2f} {healed:7.2f} {','.join(sorted(caps)) or '-'}")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--realm", type=int, default=3)
    ap.add_argument("--without", action="append", default=[])
    ap.add_argument("--blind", action="store_true")
    ap.add_argument("--gap", type=int, default=0)
    ap.add_argument("--seeds", type=int, default=20)
    ap.add_argument("--trace", default=None)
    ap.add_argument("--enemies", default="typical,top_end,top_end_fire,the_tu,phys_wall,drainer,top_drainer")
    args = ap.parse_args()
    if args.trace:
        a = bare_fist(args.realm, args.without, args.blind)
        b = enemy(args.trace, min(4, args.realm + args.gap))
        res = fight(a, b, seed=1, trace=True)
        print("t     A.hp  A.qi  bank  B.hp  B.qi")
        for row in res["rows"]:
            print(f"{row[0]:5.0f} {row[1]:.2f}  {row[2]:.2f}  {row[3]:.2f}  {row[4]:.2f}  {row[5]:.2f}")
        print(res["win"], res["t"])
        return
    run(args.realm, args.enemies.split(","), args.seeds, args.without, args.blind, args.gap)


if __name__ == "__main__":
    main()
