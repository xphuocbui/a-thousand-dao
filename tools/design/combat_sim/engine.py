"""Combat engine v2: an event-driven fight simulator with data-driven Effects.

A design tool, not the game's combat code (user decision 2026-11-11: Python now, GDScript port later with this
engine's results as its test oracle). It replaces the time-step model in sim.py; sim.py stays as the #44 tuning
record, and `regress.py` checks that this engine reproduces its scenarios.

What it models (GDD references in brackets):
- the timeline in whole milliseconds, next-event first [Combat rule 10]; pulses every 1 s; fatigue from 60 s
- arts on cooldown timers with guards, opening haste, art speed, Slowed Time and delays [Combat 13, A2;
  Effects 6, Formulas D]; the basic attack with basic speed and `basic_coef_add`; companions, one per source [R31]
- the defence path per hit: avoid -> evade -> dampen -> resistance (ward points while linh luc lasts, body, typed,
  curses; negative amplifies) with the drain bill -> block -> ward shields (stops, pieces, recharge, bypass_share)
  -> body shield -> health [Combat Defence & Healing 1, 9, A-C; R2, R3, R6]
- element stacks as batches [Effects 9a]; statuses from a table that mirrors the Status Catalogue, with 3 curse
  slots and the 1-5 pulse clamp [Effects Status Catalogue, R22]
- soul attacks and the added Soul part [Combat 24, E2; R11]; second pools [Combat 11, R12]
- Effects as records: an event or `always`, conditions, scaling with an optional cap, chance, limits, held
  payloads, self-counters (tag `growing`) and a closed list of actions [Effects 5, 6, 8, 16]
- triggers: depth 2, 6 firings per side between pulses, trigger damage within the budget [Combat 9, G]
- the Down step: refusal budget, last acts, cull [Effects 11, R5, R15c]; Crossing the Line [CD&H 19]

Anything a record asks for that the engine does not know raises EngineError naming it, so a result never looks
more complete than it is.

Run: python -I tools/design/combat_sim/engine.py          (self-check scenarios)
"""
import math
import random
from dataclasses import dataclass, field

# ------------------------------------------------------------------ constants (same numbers as sim.py K)
K = dict(
    fatigue_start=60.0, fatigue_units=0.5, fatigue_pow=2.0, time_limit=300.0,
    health_mult=4.0, regen_base=0.035, regen_k=0.08, cost_scale=0.5, drain_scale=0.2,
    crit_cap=1.0, evade_cap=0.4, cooldown_min=0.5, basic_cooldown=1.0, pulse=1.0,
    trig_cap=6, trig_depth=2, trig_budget=0.5, avoid_budget=2, curse_slots=3, curse_duration_max=5,
    delay_window=3.0, slowed_time_pct=0.06, soul_beta=2.0, rho_min=0.25, soul_cap=0.30, soul_lockout=1.0,
    recharge_delay=2.0, shield_recharge=0.25, bypass_cap=0.5, stops_cap_chaos=0.5, stops_cap_soul=0.3,
    min_batch=2.0, layer_caps=(400, 300, 250, 150, 100), l1_soft=(200, 0.5),
)
U = [6.31, 15.85, 39.81, 100.0, 251.19]
SUPP = [0.0, 0.10, 0.25, 0.50, 0.75]
BLOCK_UNIT = [0.0631, 0.2031, 0.6672, 2.254, 6.883]

BUFF = {"fire": {"dmg": 0.012}, "water": {"qi_max": 0.005, "regen": 0.00025}, "earth": {"phys_dampen": 0.011},
        "metal": {"dmg_phys": 0.012}, "wood": {"hregen": 0.001}, "thunder": {"acc": 0.007, "crit": 0.0035},
        "wind": {"speed": 0.075}}
DEBUFF = {"fire": {"burn": 0.019}, "earth": {"acc_down": 0.012}, "metal": {"phys_taken": 0.018},
          "wood": {"poison": 0.019}, "ice": {"cost_up": 0.039}, "thunder": {"crit_taken": 0.012, "critdmg_taken": 0.05},
          "wind": {"evade_down": 0.012}}
ELEMENTS = {"", "fire", "water", "earth", "metal", "wood", "ice", "thunder", "wind"}
DTYPES = {"phys", "elem", "fire", "cold", "lightning", "force", "chaos", "soul"}
TICK_TYPE = {"fire": "fire", "wood": "chaos"}

# Status Catalogue (Effects GDD). kind: tick or curse. stack: refresh | cap N | all (a new stack refreshes all)
STATUS = {
    "bleed": dict(kind="tick", dtype="phys", c_tick=0.20, dur=4, cap=5, own_timers=True),
    "qi_disruption": dict(kind="tick", dtype="force", c_tick=0.30, dur=3, cap=3, on_qi=True),
    "corpse_rot": dict(kind="tick", dtype="chaos", c_tick=0.15, dur=None, cap=1, standing=0.02),
    "sundered": dict(kind="curse", dur=4, cap=3, res_pts=-150),
    "exposed": dict(kind="curse", dur=3, cap=1, res_all=-100),
    "sealed_meridian": dict(kind="curse", dur=2, cap=1, lockout=2),
    "silence": dict(kind="curse", dur=3, cap=1, lockout=2),
    "stagnation": dict(kind="curse", dur=3, cap=None, regen_dampen=1.0, refresh_all=True),
    "heavy_breath": dict(kind="curse", dur=4, cap=2, cost_up=0.25),
    "leaking_ward": dict(kind="curse", dur=3, cap=1, bill_up=0.5),
    "withering": dict(kind="curse", dur=4, cap=1, heal_taken=-0.5),
    "slackened_soul": dict(kind="curse", dur=2, cap=2, soul_res=-15),
    "slowed_time": dict(kind="curse", dur=3, cap=5, slow=1.0, refresh_all=True),
}

EVENTS = {"always", "fight_start", "art_fired", "hit_landed", "crit", "evaded", "was_hit", "was_evaded", "hit_stopped",
          "pulse", "tick_dealt", "heal_restored", "shield_broken", "status_applied", "overflow", "cleansed", "down",
          "kill", "soul_hit"}
MOD_KEYS = {"L1", "L2", "L3", "L4", "L5", "crit", "crit_mult", "evade", "acc", "art_speed", "basic_speed",
            "opening_haste", "cost_red", "regen", "hregen", "healing", "leech_hp", "leech_qi", "gain_on_hit",
            "resist", "block", "dampen_taken", "timer_resist", "bypass", "ward_bill", "basic_coef", "soul_res",
            "x_soul", "dmg_more", "companion_speed", "tick_block"}
ACTIONS = {"mod", "gain_qi", "heal", "free_hit", "stacks", "status", "cleanse", "timer", "refund", "counter",
           "strip", "consume", "refuse_down", "last_act", "shield", "bank", "self_hit", "store_damage", "state",
           "summon", "fire_art"}


class EngineError(Exception):
    pass


def ms(sec):
    return int(math.floor(sec * 1000 + 0.5))


# ------------------------------------------------------------------ records
@dataclass
class Art:
    name: str
    c: float = 0.0
    cost: float = 0.05            # pre-#44 cost share (x cost_scale), as in sim.py
    cd: float = 3.0
    element: str = ""
    dtype: str = "phys"
    buff: tuple = ()
    debuff: tuple = ()
    heal: float = 0.0
    qi_restore: float = 0.0
    cleanse: int = 0
    m_mult: float = 1.0
    tags: tuple = ()
    guards: list = field(default_factory=list)   # conditions, all must hold [Combat 13; R30 two guards]
    statuses: list = field(default_factory=list)  # [{"id": "sundered", "stacks": 1}] applied on hit
    split: list = field(default_factory=list)    # sub-hit shares [R23]; empty = one hit
    soul_pct: float = 0.0                        # a soul art [E2]
    soul_part: float = 0.0                       # an added Soul part share [R11]
    bypass: float = 0.0                          # bypass_share on this art's hits [R2]
    pool: str = "qi"                             # qi | tam_ma | than_thuc [R12]
    convert: dict = field(default_factory=dict)  # {"to": dtype, "share": x}: a share of the hit becomes another type
    hp_cost: float = 0.0                         # share of health_max paid on firing, besides linh luc [Effects 6]
    charges: int = 1                             # firings stored; spent ones come back together after the cooldown


@dataclass
class Shield:
    size: float                  # absolute bar size as a share of qi_max (ward) or health_max (body)
    body: bool = False
    standing: bool = True        # standing ward shields recharge
    stops: dict = field(default_factory=dict)   # dtype -> share stopped; default by kind
    pieces: int = 1
    floor: float = 0.0           # R25: past 0 keeps stopping this share


@dataclass
class Build:
    name: str
    realm: int = 0
    M: float = 3.273
    layers: list = None          # x1..x5 points; when given, Effect mods on layers are exact
    crit: float = 0.15
    crit_mult: float = 1.7
    evade: float = 0.0
    acc: float = 0.0
    n_body: float = 1.0883
    n_qi: float = 1.053
    ward_pts: float = 448.0
    drain: float = 0.959
    block: float = 15.0
    regen_bonus: float = 0.0
    hregen: float = 0.0
    cost_red: float = 0.0
    gain_on_hit: float = 0.0
    leech_qi: float = 0.0
    leech_hp: float = 0.0
    hp_pay: float = 0.0
    healing: float = 0.0
    cleanse_pulse: int = 0
    cleanse_cost: float = 0.0
    cleanse_share: float = 0.0
    art_speed_pct: float = 0.0
    basic_speed_pct: float = 0.0
    opening_haste_pct: float = 0.0
    basic_coef_add: float = 0.0
    ward_layer: float = 1.0
    body_pts: float = 0.0
    body_block: float = 0.0
    bs_mult: float = 1.0
    body_shield: float = 0.0
    resist: dict = field(default_factory=dict)     # typed resistance points
    shields: list = field(default_factory=list)    # ward shields (Shield)
    arts: list = field(default_factory=list)
    purity: dict = field(default_factory=dict)
    effects: list = field(default_factory=list)    # Effect records (dicts)
    counters: list = field(default_factory=list)   # self-counter definitions (dicts)
    companions: list = field(default_factory=list)  # {"c": coefficient, "dtype": ..., "cd": s}
    divine_sense: float = 1.0
    soul_res: float = 0.0
    x_soul: float = 0.0
    tam_ma: float = 0.0
    timer_resist: float = 0.0
    ward_bill_pct: float = 0.0
    refusals: int = 1
    boss: bool = False
    tags: tuple = ()
    states: list = field(default_factory=list)     # forms and stances [R29]: {"id", "mods", "suppress", "start"}


def from_sim(b):
    """An old sim.Build (and its sim.Art list) as an engine Build. The old keystone fields become Effects."""
    kw = {k: getattr(b, k) for k in Build.__dataclass_fields__ if hasattr(b, k) and k not in ("arts", "effects")}
    arts = [Art(a.name, a.c, a.cost, a.cd, a.element, a.dtype, tuple(a.buff), tuple(a.debuff), a.heal,
                a.qi_restore, a.cleanse, a.m_mult) for a in b.arts]
    eff = []
    if getattr(b, "k_burn", 0):
        eff.append({"id": "embers", "on": "tick_dealt", "filter": {"element": "fire"}, "do": [{"gain_qi": {"of": "amount", "share": b.k_burn}}]})
    if getattr(b, "k_fire_pen", 0):
        eff.append({"id": "embers-close", "on": "always", "do": [{"mod": {"dmg_more": -b.k_fire_pen, "element": "fire"}}]})
    if getattr(b, "k_art", 0):
        eff.append({"id": "breath-between-blows", "on": "art_fired", "do": [{"gain_qi": {"share": b.k_art}}]})
    if getattr(b, "k_crit_any", 0):
        eff.append({"id": "storm-battery", "on": "crit", "do": [{"gain_qi": {"share": b.k_crit_any}}]})
    if getattr(b, "k_crit_phys", 0):
        eff.append({"id": "edge-returns", "on": "crit", "filter": {"dtype": "phys"}, "do": [{"gain_qi": {"share": b.k_crit_phys}}]})
    if getattr(b, "curse_wither", False):
        eff.append({"id": "wither-on-hit", "on": "hit_landed", "do": [{"status": {"id": "withering"}}]})
    if getattr(b, "curse_stagnate", False):
        eff.append({"id": "stagnate-on-hit", "on": "hit_landed", "do": [{"status": {"id": "stagnation"}}]})
    for k in ("k_noncrit_pen", "k_poison_leech", "k_prevented", "k_water_nodr", "k_water_pp", "k_frost"):
        if getattr(b, k, 0):
            raise EngineError("from_sim: keystone %s has no engine Effect yet" % k)
    kw["arts"], kw["effects"] = arts, eff
    return Build(**kw)


# ------------------------------------------------------------------ side state
class Side:
    def __init__(self, b: Build, label):
        self.b, self.label = b, label
        self.U = U[b.realm]
        self.hp_max = 16 * self.U * b.n_body * K["health_mult"]
        self.qi_base = 26 * self.U * b.n_qi
        self.hp, self.qi = self.hp_max, self.qi_base
        self.body_bar = b.body_shield * self.hp_max
        self.wshields = [dict(s=s, left=s.size * self.qi_base * (s.pieces and 1), quiet_since=0, pieces_left=s.pieces)
                         for s in b.shields]
        self.tam_ma = b.tam_ma
        self.ts_spent = 0.0
        self.buffs, self.debuffs = [], []          # [element, stacks, t_end_ms(None=fight), source]
        self.statuses = {}                          # id -> {"stacks", "until", "src", "batches"}
        self.lockouts = {}                          # status id -> ms until it may be reapplied
        self.counters = {c["id"]: 0.0 for c in b.counters}
        self.counter_def = {c["id"]: c for c in b.counters}
        self.counter_times = {c["id"]: [] for c in b.counters}   # per-stack expiry, for counters with each_for
        self.temp_mods = []                         # [key, value, until_ms, filter]
        self.banked = []                            # held payloads: [effect, actions, scale]
        self.eff_state = {}                         # effect id -> {"fight": n, "pulse": n, "next": ms}
        self.ready = []
        self.fired = [0] * len(b.arts)
        self.first = [True] * len(b.arts)
        self.removed = [False] * len(b.arts)
        self.delays = []                            # ms times of delays received (falloff)
        self.charges = [a.charges for a in b.arts]
        self.state = next((x["id"] for x in b.states if x.get("start")), None)
        self.state_def = {x["id"]: x for x in b.states}
        self.summons = []                           # [c, dtype, cd_ms, next_ms, until_ms]
        self.last_art = None
        self.cur_ev = None
        self.basic_ready = 0
        self.comp_ready = []
        self.soul_ready = 0
        self.refusals_left = b.refusals
        self.down = False
        self.trig_count = 0
        self.trig_dmg = 0.0
        self.direct_dmg = 0.0
        self.avoided = 0
        self.decoys = 0
        self.dealt = self.spent = self.healed = self.fat = 0.0
        self.dry_at = None
        self.log = []
        self.clipped = {}

    def __repr__(self):
        return "Side(%s)" % self.label

    def qi_max(self):
        return self.qi_base * (1 + self.bsum("qi_max"))

    def count(self, lst, el):
        return sum(x[1] for x in lst if x[0] == el)

    def bsum(self, key):
        return sum(BUFF.get(x[0], {}).get(key, 0.0) * x[1] * stack_power(self.b, x[0]) for x in self.buffs)

    def dsum(self, key):
        return sum(DEBUFF.get(x[0], {}).get(key, 0.0) * x[1] * stack_power(x[3].b, x[0]) for x in self.debuffs)

    def st(self, sid):
        s = self.statuses.get(sid)
        return s["stacks"] if s else 0


def stack_power(build, el):
    p = build.purity.get(el, 0.0)
    if el == "water":
        p += 0.5 * build.purity.get("ice", 0.0)
    elif el == "ice":
        p += 0.5 * build.purity.get("water", 0.0)
    return 1 + 0.002 * p


def supp(att, dfn):
    return 1 - SUPP[min(max(0, dfn.b.realm - att.b.realm), 4)]


# ------------------------------------------------------------------ the fight
class Fight:
    def __init__(self, b1, b2, seed=1, trace=False):
        for b in (b1, b2):
            validate(b)
        self.rng = random.Random(seed)
        self.order = random.Random(seed + 7919)
        self.A, self.B = Side(b1, "A"), Side(b2, "B")
        self.A.foe, self.B.foe = self.B, self.A
        self.t = 0
        self.trace = trace
        self.rows = []
        self.depth = 0
        self.cache = {}
        for s in (self.A, self.B):
            hz = 1 + s.b.art_speed_pct / 100
            for i, a in enumerate(s.b.arts):
                cd = max(K["cooldown_min"], a.cd / hz)
                first = max(K["cooldown_min"], cd / (1 + (s.b.opening_haste_pct + self.mod(s, "opening_haste")) / 100))
                s.ready.append(ms(first))
            s.basic_ready = ms(self.basic_cd(s))
            s.comp_ready = [ms(c.get("cd", K["basic_cooldown"])) for c in s.b.companions]

    # ---------------------------------------------------------- reads
    def read(self, s, key, ev=None):
        """Effects rule 5 readables. own.* reads s, foe.* reads s.foe."""
        side, _, k = key.partition(".")
        x = s if side == "own" else s.foe if side == "foe" else None
        if x is None:
            if key == "time":
                return self.t / 1000
            if key.startswith("event."):
                return (ev or {}).get(key[6:], 0.0)
            raise EngineError("unknown readable %r" % key)
        if k == "hp_share":
            return max(0.0, x.hp) / x.hp_max
        if k == "hp_missing_share":
            return 1 - max(0.0, x.hp) / x.hp_max
        if k == "qi_share":
            return x.qi / x.qi_max()
        if k == "qi_missing_share":
            return 1 - x.qi / x.qi_max()
        if k.startswith("buff."):
            return x.count(x.buffs, k[5:])
        if k.startswith("debuff."):
            return x.count(x.debuffs, k[7:])
        if k.startswith("status."):
            return x.st(k[7:])
        if k.startswith("counter."):
            cid = k[8:]
            if x.counter_def.get(cid, {}).get("each_for"):
                x.counter_times[cid] = [u for u in x.counter_times[cid] if u > self.t]
                return float(len(x.counter_times[cid]))
            return x.counters.get(cid, 0.0)
        if k == "distinct_statuses":
            return len([1 for v in x.statuses.values() if v["stacks"] > 0]) + len({d[0] for d in x.debuffs})
        if k == "fired":
            return sum(x.fired)
        if k == "body_shield_share":
            return x.body_bar / x.hp_max
        if k == "boss":
            return 1.0 if x.b.boss else 0.0
        if k == "tam_ma":
            return x.tam_ma
        if k.startswith("state."):
            return 1.0 if x.state == k[6:] else 0.0
        raise EngineError("unknown readable %r" % key)

    def holds(self, s, conds, ev=None):
        for c in conds or []:
            if "any" in c:
                if not any(self.holds(s, [x], ev) for x in c["any"]):
                    return False
                continue
            v = self.read(s, c["read"], ev)
            op, val = c.get("op", ">="), c.get("value", 0)
            ok = {"<=": v <= val, ">=": v >= val, "<": v < val, ">": v > val, "==": v == val}.get(op)
            if ok is None:
                raise EngineError("unknown op %r" % op)
            if not ok:
                return False
        return True

    def scale(self, s, eff, ev=None):
        sc = eff.get("scale")
        if not sc:
            return 1.0
        n = self.read(s, sc["read"], ev) / sc.get("per", 1)
        if sc.get("floor", True):
            n = math.floor(n + 1e-9)
        if sc.get("cap") is not None:
            n = min(n, sc["cap"])
        return max(0.0, n)

    def mod(self, s, key, ctx=None):
        """Sum of a stat's Effect mods: always-on and conditional Effects plus timed mods from events."""
        tot = 0.0
        for e in s.b.effects:
            if e.get("on") != "always":
                continue
            if not self.holds(s, e.get("if")):
                continue
            n = self.scale(s, e)
            for a in e.get("do", []):
                m = a.get("mod")
                if m and key in m and match(m, ctx):
                    tot += m[key] * n
        for m in s.temp_mods:
            k, v, until, filt = m[:4]
            if k == key and until > self.t and match(filt, ctx):
                tot += v
        st_def = s.state_def.get(s.state)
        if st_def and key in st_def.get("mods", {}):
            tot += st_def["mods"][key]
        for e, acts, n in s.banked:
            for a in acts:
                m = a.get("mod")
                if m and key in m and match(m, ctx):
                    tot += m[key] * n
        return tot

    def layers_M(self, s, art, ctx):
        """M with layer mods. Builds with `layers` get exact caps; others scale their fixed M."""
        adds = [self.mod(s, "L%d" % i, ctx) for i in range(1, 6)]
        if not any(adds):
            return s.b.M * (art.m_mult if art else 1.0)
        base = list(s.b.layers) if s.b.layers else [0, 0, 0, 0, 0]

        def M_of(x):
            m = 1.0
            for i in range(5):
                xi = x[i]
                if i == 0 and xi > K["l1_soft"][0]:
                    xi = K["l1_soft"][0] + K["l1_soft"][1] * (xi - K["l1_soft"][0])
                if s.foe.st("sealed_meridian") and i >= 1 and i == s.foe.statuses["sealed_meridian"].get("layer", 4):
                    xi = 0
                m *= 1 + min(xi, K["layer_caps"][i]) / 100
            return m
        new = [base[i] + adds[i] for i in range(5)]
        for i in range(5):
            if new[i] > K["layer_caps"][i]:
                s.clipped["L%d" % (i + 1)] = s.clipped.get("L%d" % (i + 1), 0) + 1
        return s.b.M * (art.m_mult if art else 1.0) * M_of(new) / M_of(base)

    def basic_cd(self, s):
        return max(K["cooldown_min"], K["basic_cooldown"] / (1 + (s.b.basic_speed_pct + self.mod(s, "basic_speed")) / 100))

    def slow(self, s):
        n = min(s.st("slowed_time"), 5)
        return 1 + K["slowed_time_pct"] * n * (1 - (s.b.timer_resist + self.mod(s, "timer_resist")) / 100)

    # ---------------------------------------------------------- the loop
    def run(self):
        A, B = self.A, self.B
        next_pulse = ms(K["pulse"])
        self.fire_event(A, "fight_start", {})
        self.fire_event(B, "fight_start", {})
        limit = ms(K["time_limit"])
        while True:
            cands = [next_pulse]
            for s in (A, B):
                cands += [r for i, r in enumerate(s.ready) if r > self.t and not s.removed[i]]
                cands += [s.basic_ready] + [c for c in s.comp_ready if c > self.t]
            t = min(c for c in cands if c >= self.t)
            if t > limit:
                break
            self.t = t
            if t >= next_pulse:
                first, second = (A, B) if self.order.random() < 0.5 else (B, A)
                self.pulse(first)
                self.pulse(second)
                next_pulse += ms(K["pulse"])
                if self.trace:
                    self.rows.append((t / 1000, A.hp / A.hp_max, A.qi / A.qi_max(), B.hp / B.hp_max, B.qi / B.qi_max()))
            first, second = (A, B) if self.order.random() < 0.5 else (B, A)
            self.act(first)
            self.act(second)
            for s in (A, B):
                if s.dry_at is None and s.qi < 0.05 * s.qi_max():
                    s.dry_at = t / 1000
            self.defeat_check()
            if A.down or B.down:
                break
        win = "draw" if A.down and B.down else "A" if B.down else "B" if A.down else "time"
        return dict(t=self.t / 1000, win=win, A=A, B=B, rows=self.rows)

    # ---------------------------------------------------------- pulses
    def pulse(self, s):
        o = s.foe
        # element ticks (Burn, Poison)
        for el, n, t_end, src in list(s.debuffs):
            c = DEBUFF.get(el, {}).get("burn", 0.0) + DEBUFF.get(el, {}).get("poison", 0.0)
            if c:
                tick = src.U * c * n * src.b.M * (1 + src.bsum("dmg")) * supp(src, s) * stack_power(src.b, el)
                self.tick(src, s, tick, TICK_TYPE[el], el)
        # status ticks
        for sid, stt in list(s.statuses.items()):
            d = STATUS[sid]
            if d["kind"] == "tick" and stt["stacks"] > 0:
                src = stt["src"]
                tick = src.U * d["c_tick"] * stt["stacks"] * src.b.M * supp(src, s)
                if d.get("on_qi"):
                    s.qi = max(0.0, s.qi - tick)
                    src.dealt += tick
                else:
                    self.tick(src, s, tick, d["dtype"], sid)
                if d.get("standing"):
                    fee = d["standing"] * src.qi_max()
                    if src.qi < fee:
                        stt["stacks"] = 0
                    else:
                        src.qi -= fee
        # stored damage released (R26 Internal Injury)
        st = s.statuses.get("internal_injury")
        if st and st.get("stored", 0) > 0 and self.t >= st.get("next", 0):
            amt = st["stored"]
            st["stored"] = 0
            st["next"] = self.t + ms(st.get("every", 3))
            s.hp -= amt
            st["src"].dealt += amt
        # regeneration; Stagnation dampens both pools by 1 % per stack [Status Catalogue, 2026-11-10]
        stag = 1 + s.st("stagnation") * STATUS["stagnation"]["regen_dampen"] / 100
        k = K["regen_k"]
        bonus = s.b.regen_bonus + s.bsum("regen") + self.mod(s, "regen")
        regen = s.qi_max() * (K["regen_base"] + k * math.log(1 + max(0.0, bonus) / k)) / stag
        room = s.qi_max() - s.qi
        if regen > room:
            self.fire_event(s, "overflow", {"amount": regen - room})
        s.qi = min(s.qi_max(), s.qi + regen)
        hreg = s.hp_max * (s.b.hregen + s.bsum("hregen") + self.mod(s, "hregen")) * s.b.bs_mult / stag
        if hreg > 0:
            self.heal(s, hreg)
        # cleansing ward
        n = s.b.cleanse_pulse
        while n > 0 and s.debuffs:
            fee = s.b.cleanse_cost * s.qi_max()
            if s.qi < fee:
                break
            s.qi -= fee
            s.debuffs.sort(key=lambda x: x[2] if x[2] is not None else 1 << 40)
            s.debuffs[0][1] -= 1
            if s.debuffs[0][1] <= 0:
                s.debuffs.pop(0)
            n -= 1
        if s.b.cleanse_share:
            for x in s.debuffs:
                x[1] *= (1 - s.b.cleanse_share)
            s.debuffs = [x for x in s.debuffs if x[1] >= 0.05]
        # fatigue
        if self.t >= ms(K["fatigue_start"]):
            n = round((self.t - ms(K["fatigue_start"])) / 1000)
            f = s.U * K["fatigue_units"] * (1 + n) ** K["fatigue_pow"]
            s.hp -= f
            s.fat += f
        # durations
        s.buffs = [x for x in s.buffs if x[2] is None or x[2] > self.t]
        s.debuffs = [x for x in s.debuffs if x[2] is None or x[2] > self.t]
        for sid in list(s.statuses):
            stt = s.statuses[sid]
            if stt.get("until") is not None and stt["until"] <= self.t:
                lock = STATUS[sid].get("lockout")
                if lock and not stt.get("no_lockout"):
                    s.lockouts[sid] = self.t + ms(lock)
                del s.statuses[sid]
        s.temp_mods = [m for m in s.temp_mods if m[2] > self.t]
        # self-counter decay
        for cid, cdef in s.counter_def.items():
            dec = cdef.get("decay_per_pulse", 0)
            if dec:
                s.counters[cid] = max(0.0, s.counters[cid] - dec)
        # per-pulse limits reset
        s.trig_count = 0
        s.trig_dmg = 0.0
        s.direct_dmg = 0.0
        s.avoided = 0
        for st_ in s.eff_state.values():
            st_["pulse"] = 0
        # ward shield recharge
        for w in s.wshields:
            cap = w["s"].size * s.qi_base
            if w["s"].standing and self.t - w["quiet_since"] >= ms(K["recharge_delay"]) and w["left"] < cap:
                w["left"] = min(cap, w["left"] + K["shield_recharge"] * cap)
                if w["s"].pieces > 1:
                    w["pieces_left"] = min(w["s"].pieces, w["pieces_left"] + 1)
        self.fire_event(s, "pulse", {})

    # ---------------------------------------------------------- acting
    def act(self, s):
        if s.down:
            return
        o = s.foe
        b = s.b
        speed = 1 + s.bsum("speed") + (b.art_speed_pct + self.mod(s, "art_speed")) / 100
        sup = set(s.state_def.get(s.state, {}).get("suppress", []))
        for i, a in enumerate(b.arts):
            if s.removed[i] or self.t < s.ready[i] or a.name in sup:
                continue
            if a.tags and s.st("silence") and s.statuses["silence"].get("tag") in a.tags:
                continue
            if not self.holds(s, a.guards):
                continue
            if a.soul_pct and self.t < s.soul_ready:
                continue
            if not self.pay(s, a):
                continue
            cd = max(K["cooldown_min"], a.cd / speed) * self.slow(s)
            s.charges[i] -= 1
            if s.charges[i] > 0:
                s.ready[i] = self.t + ms(K["cooldown_min"])
            else:
                s.ready[i] = self.t + ms(cd)
                s.charges[i] = a.charges
            s.fired[i] += 1
            s.first[i] = False
            if a.soul_pct or a.soul_part:
                s.soul_ready = self.t + ms(K["soul_lockout"])
            if a.buff:
                self.add_stacks(s, s, a.element, a.buff[0], a.buff[1], buff=True)
            if a.cleanse:
                self.cleanse(s, a.cleanse)
            if a.heal:
                got0 = s.healed
                self.heal(s, s.U * a.heal * K["health_mult"])
                if s.healed > got0:
                    s.qi = min(s.qi_max(), s.qi + s.last_cost)
            if a.qi_restore:
                s.qi = min(s.qi_max(), s.qi + a.qi_restore * s.qi_max())
            ev = {"art": a, "art_id": a.name, "slot": i, "cost": s.last_cost, "tags": a.tags, "element": a.element,
                  "dtype": a.dtype, "kind": "art"}
            s.cur_ev = ev
            s.last_art = i
            self.fire_event(s, "art_fired", ev)
            if a.soul_pct:
                self.soul_hit(s, o, a)
            elif a.c:
                shares = a.split or [1.0]
                for sh in shares:
                    self.hit(s, o, a.c * sh, a.dtype, a, kind="art")
            self.spend_banked(s, "art_fired", ev)
            s.cur_ev = None
        while self.t >= s.basic_ready:
            c = 1.0 + b.basic_coef_add + self.mod(s, "basic_coef")
            self.hit(s, o, c, "phys", None, kind="basic")
            s.basic_ready += ms(self.basic_cd(s) * self.slow(s))
        for sm in list(s.summons):
            while self.t >= sm[3] and sm[3] < sm[4]:
                self.hit(s, o, sm[0], sm[1], None, kind="companion")
                sm[3] += sm[2]
            if self.t >= sm[4]:
                s.summons.remove(sm)
        for j, comp in enumerate(b.companions):
            while self.t >= s.comp_ready[j]:
                self.hit(s, o, comp["c"], comp.get("dtype", "phys"), None, kind="companion")
                cd = comp.get("cd", K["basic_cooldown"]) / (1 + self.mod(s, "companion_speed") / 100)
                s.comp_ready[j] += ms(max(K["cooldown_min"], cd))

    def pay(self, s, a):
        b = s.b
        cost_up = (1 + s.dsum("cost_up")) * (1 + s.st("heavy_breath") * STATUS["heavy_breath"]["cost_up"])
        cost = a.cost * K["cost_scale"] * (1 - min(0.95, b.cost_red + self.mod(s, "cost_red"))) * cost_up * s.qi_base
        if a.pool == "tam_ma":
            need = cost / s.qi_max() * 100
            if s.tam_ma < need:
                return False
            s.tam_ma -= need
            s.last_cost = 0.0
            return True
        if a.pool == "than_thuc":
            share = cost / s.qi_max()
            ds = s.b.divine_sense * (1 - s.ts_spent)
            if ds <= share * s.b.divine_sense:
                return False
            s.ts_spent += share
            s.last_cost = 0.0
            return True
        if a.hp_cost and s.hp - a.hp_cost * s.hp_max < 1:
            return False
        qi_part = cost * (1 - b.hp_pay)
        hp_part = cost * b.hp_pay * (s.hp_max / s.qi_base)
        if s.qi + 1e-6 < qi_part or (hp_part and s.hp - hp_part < 1):
            return False
        s.qi -= qi_part
        s.hp -= hp_part + a.hp_cost * s.hp_max
        s.spent += qi_part
        s.last_cost = qi_part
        return True

    # ---------------------------------------------------------- hits
    def hit(self, att, dfn, c, dtype, art, kind="art", trig=False):
        """One hit through the defence path. Returns the health removed."""
        ctx = {"dtype": dtype, "element": art.element if art else "", "tags": art.tags if art else (kind,), "kind": kind,
               "art_id": art.name if art else kind}
        # avoid [R6]
        if not trig and dfn.decoys > 0 and dfn.avoided < K["avoid_budget"]:
            dfn.decoys -= 1
            dfn.avoided += 1
            return 0.0
        # evade
        p_ev = min(K["evade_cap"], max(0.0, dfn.b.evade + self.mod(dfn, "evade") / 100 - dfn.dsum("evade_down")
                                       - (att.b.acc + self.mod(att, "acc") / 100 + att.bsum("acc") - att.dsum("acc_down"))))
        if self.rng.random() < p_ev:
            self.fire_event(dfn, "evaded", ctx)
            self.fire_event(att, "was_evaded", ctx)
            return 0.0
        is_crit = False
        if kind not in ("companion",) and not trig:
            ch = min(K["crit_cap"], att.b.crit + self.mod(att, "crit", ctx) / 100 + att.bsum("crit") + dfn.dsum("crit_taken"))
            is_crit = self.rng.random() < ch
        crit = (att.b.crit_mult + self.mod(att, "crit_mult", ctx) / 100 + dfn.dsum("critdmg_taken")) if is_crit else 1.0
        phys = dtype == "phys"
        more = 1 + att.bsum("dmg") + (att.bsum("dmg_phys") + dfn.dsum("phys_taken") if phys else 0)
        more *= 1 + self.mod(att, "dmg_more", ctx)
        M = self.layers_M(att, art, ctx) if kind != "companion" else att.b.M
        D = att.U * c * M * crit * more * supp(att, dfn)
        damp = (dfn.bsum("phys_dampen") if phys else 0.0) + self.mod(dfn, "dampen_taken", ctx) / 100
        if damp:
            D /= 1 + damp
        soul_D = 0.0
        if art is not None and art.soul_part:
            soul_D = D * art.soul_part
            D -= soul_D
        conv = art.convert if art is not None else None
        if conv and conv.get("share"):
            cD = D * conv["share"]
            dealt = self.defend(att, dfn, D - cD, dtype, art, ctx, is_tick=False)
            dealt += self.defend(att, dfn, cD, conv["to"], art, dict(ctx, dtype=conv["to"]), is_tick=False)
        else:
            dealt = self.defend(att, dfn, D, dtype, art, ctx, is_tick=False)
        if soul_D:
            sr = dfn.b.soul_res + self.mod(dfn, "soul_res") + dfn.st("slackened_soul") * STATUS["slackened_soul"]["soul_res"]
            sd = soul_D / (1 + sr / 100) if sr >= 0 else soul_D * (1 + abs(sr) / 100)
            dfn.hp -= sd
            dealt += sd
        att.dealt += dealt
        if trig:
            att.trig_dmg += dealt
        else:
            att.direct_dmg += dealt
        ev = dict(ctx, amount=dealt, crit=is_crit)
        # sustain on hit (a hit landed: not evaded, even if blocked to 0)
        gain = (att.b.gain_on_hit + self.mod(att, "gain_on_hit") / 100) * att.qi_max() + (att.b.leech_qi + self.mod(att, "leech_qi") / 100) * dealt
        att.qi = min(att.qi_max(), att.qi + gain)
        lh = att.b.leech_hp + self.mod(att, "leech_hp") / 100
        if lh:
            self.heal(att, lh * dealt)
        if art and art.debuff:
            self.add_stacks(att, dfn, art.element, art.debuff[0], art.debuff[1], buff=False)
        if art:
            for st in art.statuses:
                self.apply_status(att, dfn, st)
        if not trig or self.depth < K["trig_depth"]:
            self.fire_event(att, "hit_landed", ev)
            if is_crit:
                self.fire_event(att, "crit", ev)
            self.fire_event(dfn, "was_hit", ev)
            if ev.get("stopped"):
                self.fire_event(dfn, "hit_stopped", ev)
            if kind in ("art", "basic"):
                self.spend_banked(att, "hit_landed", ev)
        return dealt

    def resistance(self, dfn, dtype, qi_live=True):
        Rw = dfn.b.ward_pts * dfn.b.ward_layer if (dfn.qi > 0 and qi_live) else 0.0
        Rb = dfn.b.body_pts * dfn.b.bs_mult + dfn.b.resist.get(dtype, 0.0) + self.mod(dfn, "resist", {"dtype": dtype})
        Rc = dfn.st("sundered") * STATUS["sundered"]["res_pts"] + dfn.st("exposed") * STATUS["exposed"]["res_all"]
        return Rw, Rb + Rc

    def defend(self, att, dfn, D, dtype, art, ctx, is_tick=False):
        """Resistance with the drain bill, block, shields, health. Returns health removed."""
        if dtype == "soul":
            dfn.hp -= D
            return D
        Rw, Ro = self.resistance(dfn, dtype)
        R = Rw + Ro
        if R >= 0:
            prevented = D * R / (100 + R) if R > 0 else 0.0
            bill_share = prevented * Rw / R if R > 0 else 0.0
        else:
            prevented = -D * abs(R) / 100   # negative: amplified
            bill_share = 0.0
        bill = bill_share * dfn.b.drain * K["drain_scale"] / dfn.b.ward_layer
        bill *= (1 + (att.b.ward_bill_pct + self.mod(att, "ward_bill")) / 100) * (1 + dfn.st("leaking_ward") * STATUS["leaking_ward"]["bill_up"])
        if bill > 0:
            if bill > dfn.qi:
                frac = dfn.qi / bill
                dfn.qi = 0.0
                prevented -= bill_share * (1 - frac)
            else:
                dfn.qi -= bill
        a = D - prevented
        # block (not for ticks unless an Effect lets a share meet them, R24)
        blk = BLOCK_UNIT[dfn.b.realm] * (dfn.b.block + self.mod(dfn, "block") + dfn.b.body_block * dfn.b.bs_mult)
        if is_tick:
            blk *= self.mod(dfn, "tick_block") / 100
        a = max(0.0, a - blk)
        # shields
        reached = False
        if a > 0:
            byp = 0.0 if is_tick else min(K["bypass_cap"], (art.bypass if art else 0.0) + self.mod(att, "bypass", ctx))
            through = a * byp
            rest = a - through
            for w in dfn.wshields:
                if rest <= 0:
                    break
                stop = w["s"].stops.get(dtype, 0.0 if is_tick or dtype == "soul" else 1.0)
                if is_tick and "ticks" in w["s"].stops:
                    stop = w["s"].stops["ticks"]
                if stop <= 0 or (w["left"] <= 0 and not w["s"].floor):
                    continue
                part = rest * stop
                if w["left"] <= 0:
                    soak = part * w["s"].floor
                else:
                    piece = w["s"].size * dfn.qi_base / max(1, w["s"].pieces)
                    soak = min(part, w["left"], piece if w["s"].pieces > 1 else w["left"])
                    w["left"] -= soak
                    if w["left"] <= 1e-9:
                        w["left"] = 0.0
                        self.fire_event(dfn, "shield_broken", {})
                w["quiet_since"] = self.t
                rest -= soak
            a = rest + through
            if a > 0 and dfn.body_bar > 0 and dtype not in ("chaos", "soul"):
                soak = min(a, dfn.body_bar)
                dfn.body_bar -= soak
                a -= soak
                reached = soak > 0
        dealt = 0.0 if a <= 1e-12 else (a if is_tick else max(1.0, a))
        if dealt > 0:
            reached = True
        dfn.hp -= dealt
        if not reached and not is_tick and D > 0:
            ctx["stopped"] = True
        return dealt

    def tick(self, src, s, amount, dtype, sid):
        dealt = self.defend(src, s, amount, dtype, None, {"dtype": dtype}, is_tick=True)
        src.dealt += dealt
        self.fire_event(src, "tick_dealt", {"amount": dealt, "status": sid, "element": sid if sid in ELEMENTS else "", "dtype": dtype})
        return dealt

    def soul_hit(self, att, dfn, a):
        ds_att = att.b.divine_sense * (1 - att.ts_spent)
        ds_def = dfn.b.divine_sense * (1 - dfn.ts_spent)
        sr = dfn.b.soul_res + self.mod(dfn, "soul_res") + dfn.st("slackened_soul") * STATUS["slackened_soul"]["soul_res"]
        rho = ds_att / (ds_def * (1 + sr / 100)) if sr >= 0 else ds_att * (1 + abs(sr) / 100) / ds_def
        if rho < K["rho_min"]:
            return 0.0
        pct = min(a.soul_pct * (1 + (att.b.x_soul + self.mod(att, "x_soul")) / 100) * rho ** K["soul_beta"] * supp(att, dfn), K["soul_cap"])
        lh, lq = pct * dfn.hp_max, pct * dfn.qi_max()
        dfn.hp -= lh
        dfn.qi = max(0.0, dfn.qi - lq)
        att.dealt += lh
        att.direct_dmg += lh
        self.fire_event(att, "soul_hit", {"amount": lh, "qi": lq})
        return lh

    def heal(self, s, amount):
        amount *= 1 + s.b.healing + self.mod(s, "healing") / 100
        if s.st("withering"):
            amount *= 1 + STATUS["withering"]["heal_taken"]
            if s.statuses["withering"].get("crossing"):
                s.hp -= amount   # Crossing the Line: the heal lands as damage, straight to health [CD&H 19]
                s.statuses["withering"]["src"].dealt += amount
                return
        got = min(amount, s.hp_max - s.hp)
        if got > 0:
            s.hp += got
            s.healed += got
            self.fire_event(s, "heal_restored", dict(s.cur_ev or {}, amount=got))

    # ---------------------------------------------------------- stacks and statuses
    def add_stacks(self, src, target, el, n, dur, buff):
        if not n:
            return
        until = None if dur is None else self.t + ms(max(K["min_batch"], dur))
        if buff:
            target.buffs.append([el, n, until, src])
        else:
            target.debuffs.append([el, n, until, src])
            self.fire_event(src, "status_applied", {"element": el, "stacks": n})

    def apply_status(self, src, target, spec):
        sid = spec["id"]
        if sid not in STATUS and sid != "internal_injury":
            raise EngineError("unknown status %r" % sid)
        if sid == "internal_injury":
            st = target.statuses.setdefault(sid, {"stacks": 1, "until": None, "src": src, "stored": 0.0})
            st["every"] = spec.get("every", 3)
            return
        d = STATUS[sid]
        if self.t < target.lockouts.get(sid, -1):
            return
        is_curse = d["kind"] == "curse"
        if is_curse and sid not in target.statuses:
            live = [k for k, v in target.statuses.items() if STATUS.get(k, {}).get("kind") == "curse"]
            if len(live) >= K["curse_slots"]:
                return
        dur = spec.get("dur", d["dur"])
        if dur is not None and is_curse:
            dur = max(1, min(K["curse_duration_max"], dur))
        st = target.statuses.get(sid)
        n = spec.get("stacks", 1)
        cap = spec.get("cap", d.get("cap"))
        if st is None:
            st = {"stacks": 0, "until": None, "src": src}
            target.statuses[sid] = st
        st["stacks"] = st["stacks"] + n if cap is None else min(cap, st["stacks"] + n)
        st["src"] = src
        st["until"] = None if dur is None else self.t + ms(dur)
        for k in ("layer", "tag", "crossing", "no_lockout"):
            if k in spec:
                st[k] = spec[k]
        self.fire_event(src, "status_applied", {"status": sid, "stacks": n})

    def cleanse(self, s, n, el=None):
        removed = 0
        s.debuffs.sort(key=lambda x: x[2] if x[2] is not None else 1 << 40)
        i = 0
        while n > 0 and i < len(s.debuffs):
            x = s.debuffs[i]
            if el and x[0] != el:
                i += 1
                continue
            take = min(n, x[1])
            x[1] -= take
            n -= take
            removed += take
            if x[1] <= 0:
                s.debuffs.pop(i)
            else:
                i += 1
        if removed:
            self.fire_event(s.foe, "cleansed", {"amount": removed})
        return removed

    # ---------------------------------------------------------- Effects
    def fire_event(self, s, name, ev):
        for e in s.b.effects:
            if e.get("on") != name or e.get("held"):
                if e.get("held") and e.get("on") == name:
                    self.bank(s, e, ev)
                continue
            if not match(e.get("filter"), ev):
                continue
            if not self.allowed(s, e):
                continue
            if not self.holds(s, e.get("if"), ev):
                continue
            if e.get("chance", 1.0) < 1.0 and self.rng.random() >= e["chance"]:
                continue
            self.mark(s, e)
            self.depth += 1
            try:
                self.do(s, e, e.get("do", []), self.scale(s, e, ev), ev)
            finally:
                self.depth -= 1

    def allowed(self, s, e):
        st = s.eff_state.setdefault(e["id"], {"fight": 0, "pulse": 0, "next": 0})
        lim = e.get("limit", {})
        if "per_fight" in lim and st["fight"] >= lim["per_fight"]:
            return False
        if "per_pulse" in lim and st["pulse"] >= lim["per_pulse"]:
            s.clipped[e["id"]] = s.clipped.get(e["id"], 0) + 1
            return False
        if self.t < st["next"]:
            return False
        return True

    def mark(self, s, e):
        st = s.eff_state[e["id"]]
        st["fight"] += 1
        st["pulse"] += 1
        if "cooldown" in e.get("limit", {}):
            st["next"] = self.t + ms(e["limit"]["cooldown"])

    def bank(self, s, e, ev):
        if not self.allowed(s, e) or not self.holds(s, e.get("if"), ev):
            return
        self.mark(s, e)
        cap = e["held"].get("cap")
        n = self.scale(s, e, ev)
        for x in s.banked:
            if x[0] is e:
                x[2] = n if cap is None else min(cap, x[2] + n)
                return
        s.banked.append([e, e.get("do", []), n if cap is None else min(cap, n)])

    def spend_banked(self, s, name, ev):
        keep = []
        for e, acts, n in s.banked:
            if e["held"].get("until") == name:
                self.do(s, e, [a for a in acts if "mod" not in a], n, ev)
            else:
                keep.append([e, acts, n])
        # a banked mod applies to the hit that spends it: mods were read live during that hit
        s.banked = keep

    def do(self, s, e, actions, n, ev):
        o = s.foe
        for a in actions:
            (verb, arg), = a.items()
            if verb == "mod":
                if e.get("on") != "always":
                    dur = arg.get("for", 0)
                    if not arg.get("stack"):   # "while X in the last N s": a new firing refreshes, never stacks
                        s.temp_mods = [m for m in s.temp_mods if len(m) < 5 or m[4] != e["id"]]
                    for k, v in arg.items():
                        if k in MOD_KEYS:
                            s.temp_mods.append([k, v * n, self.t + ms(dur) if dur else self.t + 1,
                                                {kk: arg[kk] for kk in ("dtype", "element", "tags", "kind") if kk in arg},
                                                e["id"]])
            elif verb == "gain_qi":
                amt = arg.get("share", 0) * (ev.get("amount", 0.0) if arg.get("of") == "amount" else s.qi_max()) * n
                s.qi = min(s.qi_max(), s.qi + amt)
            elif verb == "heal":
                amt = arg.get("share", 0) * (ev.get("amount", 0.0) if arg.get("of") == "amount" else s.hp_max) * n
                if arg.get("body_shield"):
                    s.body_bar += amt
                else:
                    self.heal(s, amt)
            elif verb == "free_hit":
                if s.trig_count >= K["trig_cap"]:
                    s.clipped["trig_cap"] = s.clipped.get("trig_cap", 0) + 1
                    continue
                budget = K["trig_budget"] * max(s.direct_dmg, 0.5 * s.U) - s.trig_dmg
                if budget <= 0:
                    s.clipped["trig_budget"] = s.clipped.get("trig_budget", 0) + 1
                    continue
                s.trig_count += 1
                before = o.hp
                self.hit(s, o, arg["c"] * n, arg.get("dtype", "phys"), None, kind="trigger", trig=True)
                over = (before - o.hp) - budget
                if over > 0 and not arg.get("outside_budget"):
                    o.hp += over
                    s.dealt -= over
                    s.trig_dmg -= over
                    s.clipped["trig_budget"] = s.clipped.get("trig_budget", 0) + 1
            elif verb == "stacks":
                tgt = o if arg.get("side", "foe") == "foe" else s
                self.add_stacks(s, tgt, arg["el"], arg["n"] * n, arg.get("for"), buff=(tgt is s))
            elif verb == "status":
                spec = dict(arg)
                spec["stacks"] = spec.get("stacks", 1) * n
                self.apply_status(s, o if arg.get("side", "foe") == "foe" else s, spec)
            elif verb == "cleanse":
                if arg.get("status") or arg.get("curses"):
                    gone = [k for k in list(s.statuses) if k == arg.get("status")
                            or (arg.get("curses") and STATUS.get(k, {}).get("kind") == "curse")]
                    if arg.get("curses"):
                        gone = gone[:int(arg["curses"] * n)]
                    for k in gone:
                        del s.statuses[k]
                    if gone:
                        self.fire_event(o, "cleansed", {"amount": len(gone)})
                else:
                    self.cleanse(s, int(arg.get("n", 1) * n), arg.get("el"))
            elif verb == "state":
                if arg.get("set") is not None and arg["set"] not in s.state_def:
                    raise EngineError("state %r is not defined" % arg["set"])
                s.state = None if (arg.get("toggle") and s.state == arg.get("set")) else arg.get("set")
            elif verb == "summon":
                cd = ms(max(K["cooldown_min"], arg.get("cd", K["basic_cooldown"])))
                s.summons.append([arg.get("c", 0.5) * n, arg.get("dtype", "phys"), cd, self.t + cd,
                                  self.t + ms(arg.get("for", 10))])
            elif verb == "fire_art":
                if self.depth > K["trig_depth"]:
                    continue
                which = arg.get("which", "last")
                idx = s.last_art if which == "last" else next(
                    (i for i, x in enumerate(s.b.arts) if x.name == which), None)
                if idx is None:
                    continue
                art = s.b.arts[idx]
                if art.c and not art.soul_pct:
                    self.hit(s, o, art.c * arg.get("share", 1.0) * n, art.dtype, art, kind="art")
            elif verb == "timer":
                tgt = s if arg.get("side", "own") == "own" else o
                by = arg["by"] * n
                if tgt is o:   # a delay: falloff within the window, timer resistance [R1]
                    o.delays = [x for x in o.delays if self.t - x < ms(K["delay_window"])]
                    by = by * 0.5 ** len(o.delays) * (1 - (o.b.timer_resist + self.mod(o, "timer_resist")) / 100)
                    o.delays.append(self.t)
                which = arg.get("which", "all")
                idx = [i for i in range(len(tgt.ready)) if not (tgt is s and ev.get("slot") == i and which == "others")]
                if which == "longest" and idx:
                    idx = [max(idx, key=lambda i: tgt.ready[i])]
                for i in idx:
                    last_ok = self.t + ms(K["cooldown_min"]) if tgt is s else 0
                    tgt.ready[i] = max(last_ok if by < 0 else 0, tgt.ready[i] + ms(by))
            elif verb == "refund":
                s.qi = min(s.qi_max(), s.qi + min(1.0, arg.get("share", 1.0) * n) * ev.get("cost", 0.0))
            elif verb == "counter":
                cdef = s.counter_def.get(arg["id"])
                if cdef is None:
                    raise EngineError("counter %r is not defined" % arg["id"])
                if cdef.get("each_for"):   # each stack on its own timer; at the cap the oldest is replaced
                    times = [u for u in s.counter_times[arg["id"]] if u > self.t]
                    for _ in range(int(arg.get("add", 1) * n)):
                        times.append(self.t + ms(cdef["each_for"]))
                    times.sort()
                    cap = cdef.get("cap")
                    s.counter_times[arg["id"]] = times[-cap:] if cap else times
                    continue
                v = s.counters[arg["id"]] + arg.get("add", 1) * n
                if arg.get("set") is not None:
                    v = arg["set"]
                cap = cdef.get("cap")
                s.counters[arg["id"]] = max(0.0, v if cap is None else min(cap, v))
            elif verb == "strip":
                left = int(arg.get("n", 1) * n)
                pile = arg.get("el") or max({x[0] for x in o.buffs} or {""}, key=lambda el: o.count(o.buffs, el))
                o.buffs.sort(key=lambda x: x[2] if x[2] is not None else 1 << 40)
                taken = 0
                for x in list(o.buffs):
                    if left <= 0:
                        break
                    if x[0] != pile:
                        continue
                    k = min(left, x[1])
                    x[1] -= k
                    left -= k
                    taken += k
                    if arg.get("steal"):
                        s.buffs.append([pile, k, x[2], s])
                    if x[1] <= 0:
                        o.buffs.remove(x)
            elif verb == "consume":
                tgt = o if arg.get("side", "foe") == "foe" else s
                lst = tgt.debuffs if arg.get("kind", "debuff") == "debuff" else tgt.buffs
                lst.sort(key=lambda x: x[2] if x[2] is not None else 1 << 40)
                left, got = int(arg.get("n", 1 << 30)), 0
                for x in list(lst):
                    if left <= 0:
                        break
                    if x[0] != arg["el"]:
                        continue
                    k = min(left, x[1])
                    x[1] -= k
                    left -= k
                    got += k
                    if x[1] <= 0:
                        lst.remove(x)
                if arg.get("then"):
                    per = arg.get("per", 1)
                    self.do(s, e, arg["then"], got / per, ev)
            elif verb == "refuse_down" or verb == "last_act":
                pass   # read by the Down step
            elif verb == "shield":
                s.body_bar += arg.get("body", 0.0) * s.hp_max * n
            elif verb == "bank":
                pass
            elif verb == "self_hit":
                self.hit(o, s, arg.get("c", 0.0) * n, arg.get("dtype", "phys"), None, kind="trigger", trig=True)
            elif verb == "store_damage":
                st = o.statuses.get("internal_injury")
                if st is None:
                    self.apply_status(s, o, {"id": "internal_injury", "every": arg.get("every", 3)})
                    st = o.statuses["internal_injury"]
                st["stored"] = st.get("stored", 0.0) + arg.get("share", 0.0) * ev.get("amount", 0.0) * n
            else:
                raise EngineError("action %r is not in the engine" % verb)

    # ---------------------------------------------------------- the Down step [Effects 11]
    def defeat_check(self):
        for s in (self.A, self.B):
            if s.hp > 0:
                for e in s.foe.b.effects:   # cull: the foe's cull Effect [R15c]
                    for a in e.get("do", []):
                        if "cull" in a and s.hp <= a["cull"] * s.hp_max and self.holds(s.foe, e.get("if")):
                            s.hp = 0.0
        downs = [s for s in (self.A, self.B) if s.hp <= 0]
        for s in downs:
            refuse = [e for e in s.b.effects if e.get("on") == "down" and any("refuse_down" in a for a in e.get("do", []))
                      and self.allowed(s, e)]
            if refuse and s.refusals_left > 0:
                e = refuse[0]
                self.mark(s, e)
                s.refusals_left -= 1
                s.hp = 1.0
                continue
            for e in s.b.effects:
                for a in e.get("do", []):
                    if "last_act" in a and self.allowed(s, e):
                        self.mark(s, e)
                        la = a["last_act"]
                        self.hit(s, s.foe, la.get("c", 0.0), la.get("dtype", "phys"), None, kind="trigger", trig=True)
            s.down = True
        for s in (self.A, self.B):
            if not s.down and s.hp <= 0:
                s.down = True


def match(filt, ctx):
    if not filt:
        return True
    ctx = ctx or {}
    for k, v in filt.items():
        if k in MOD_KEYS or k in ("for", "stack"):
            continue
        if k == "tags":
            if not set(v) & set(ctx.get("tags", ())):
                return False
        elif k in ("dtype", "element", "kind", "status", "art_id"):
            if ctx.get(k) != v:
                return False
    return True


def validate(b):
    for e in b.effects:
        if "id" not in e:
            raise EngineError("%s: an Effect has no id" % b.name)
        if e.get("on") not in EVENTS:
            raise EngineError("%s: Effect %s: event %r is not in the engine" % (b.name, e["id"], e.get("on")))
        for a in e.get("do", []):
            if len(a) != 1:
                raise EngineError("%s: Effect %s: one verb per action, got %s" % (b.name, e["id"], list(a)))
            (verb, arg), = a.items()
            if verb == "cull":
                continue
            if verb not in ACTIONS:
                raise EngineError("%s: Effect %s: action %r is not in the engine" % (b.name, e["id"], verb))
            if verb == "mod":
                bad = [k for k in arg if k not in MOD_KEYS and k not in ("for", "dtype", "element", "tags", "kind", "stack")]
                if bad:
                    raise EngineError("%s: Effect %s: mod keys %s are not in the engine" % (b.name, e["id"], bad))
    for st in b.states:
        bad = [k for k in st.get("mods", {}) if k not in MOD_KEYS]
        if bad:
            raise EngineError("%s: state %s: mod keys %s are not in the engine" % (b.name, st.get("id"), bad))
    for a in b.arts:
        if a.convert and a.convert.get("to") not in DTYPES:
            raise EngineError("%s: art %s: convert to %r" % (b.name, a.name, a.convert.get("to")))
        if a.dtype not in DTYPES:
            raise EngineError("%s: art %s: dtype %r" % (b.name, a.name, a.dtype))
        if a.soul_part > 0.30 + 1e-9:
            raise EngineError("%s: art %s: added Soul part over 30 %% (R11)" % (b.name, a.name))


def fight(b1, b2, seed=1, trace=False):
    return Fight(b1, b2, seed, trace).run()


if __name__ == "__main__":
    import regress
    regress.main()
