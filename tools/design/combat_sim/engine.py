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
import json
import math
import os
import random
from dataclasses import dataclass, field

# ------------------------------------------------------------------ constants
# One source for both engines (ADR-0001): assets/data/combat_engine.json, read here and by the GDScript engine
# (src/gameplay/combat/fight/combat_constants.gd). Same numbers as sim.py K. realm_def is the realm defence factor
# d_r = typical M(r) / typical M(QR): health, the drain bill and fatigue keep pace with typical offence (Combat
# Formulas A, Combat Defence C; user decision 2026-11-11, "defence keeps pace").
_DATA = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", "assets", "data", "combat_engine.json")
with open(_DATA, encoding="utf-8") as _f:
    _C = json.load(_f)
K = {k: (tuple(v) if isinstance(v, list) else v) for k, v in _C["K"].items()}
U = list(_C["U"])
SUPP = list(_C["SUPP"])
BLOCK_UNIT = list(_C["BLOCK_UNIT"])

# Element stack tables (Effects rule 9a, #44), the Status Catalogue (Effects GDD; kind tick or curse; dur in pulses,
# None = until cleansed; cap None = none), an element debuff's tick type and an "elem" art's usual damage type
# (Combat Damage Types rule 3, the authoring guide, 2026-11-13): all in combat_engine.json, the one source.
BUFF = _C["BUFF"]
DEBUFF = _C["DEBUFF"]
ELEMENTS = {"", "fire", "water", "earth", "metal", "wood", "ice", "thunder", "wind", "light"}
DTYPES = {"phys", "elem", "fire", "cold", "lightning", "force", "chaos", "soul", "light"}   # light: 2026-11-26
TICK_TYPE = _C["TICK_TYPE"]
ELEM_TYPE = _C["ELEM_TYPE"]
STATUS = _C["STATUS"]

# The Effect vocabulary (Effects GDD rules 5-6), shared with the GDScript engine through combat_engine.json.
EVENTS = set(_C["EVENTS"])
EVENT_ALIAS = dict(_C.get("EVENT_ALIAS", {}))   # an Effects GDD word for an engine event (world-depth Stage 5)
MOD_KEYS = set(_C["MOD_KEYS"])
ACTIONS = set(_C["ACTIONS"])


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
    group: str = ""                              # the technique (cong phap) that carries it, for cross-art conditions
    steps: list = field(default_factory=list)    # multi-step art: [{"unlock": conds, "pay": actions, overrides...}]
    empower: list = field(default_factory=list)  # [{"if": conds, "pay": actions, "c_mult", overrides...}]
    escape: float = 0.0                          # an escape art: its base e_art (Combat rule 10, Formulas I)


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
    pill: dict = field(default_factory=dict)       # a prepared pill: {element, grade, fail} (2026-11-26, smoke only)
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
    # item and technique stats (2026-11-13): reserved share of maximum linh lực [Combat Defence & Healing rule 10];
    # stack effect and duration %, keyed "<element>|<buff|debuff>" with "*" for any [Effects rule 9a; modifiers.md]
    reserved: float = 0.0
    # Realms stage multiplier (canh-gioi Formulas, 1.00-1.45 through a realm; 2026-11-14): on the damage unit of hits,
    # ticks, trigger floors and heal arts, and on block (Combat Formulas A, Combat Defence & Healing A2); not on pools
    # (the compiler's pools already hold it) or fatigue
    stage_mult: float = 1.0
    stack_eff: dict = field(default_factory=dict)
    stack_dur: dict = field(default_factory=dict)
    # extra wards beside the main drain ward (2026-11-13) [Combat Defence & Healing rules 5-8]: each
    # {id, model: drain | per_hit | reserved | cast, payload {dtype or "all": points}, block, shield (share of qi_base),
    #  cost (per-hit fee or cast cost, share of qi), drain (engine drain units), cooldown, up}; numbers already scaled
    # by ward strength and efficiency by the loader. A reserved ward's share is in `reserved`.
    wards: list = field(default_factory=list)
    # Đạo Đồ Effects (2026-11-20): buff stacks of an element that also count as another's, {"water": ["wood"]}
    # (Water Begets Wood); read by bsum and buff.<el>
    stack_alias: dict = field(default_factory=dict)


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
        self.U_att = self.U * b.stage_mult       # the damage unit: U x stage (Combat Formulas A)
        self.g = K["realm_def"][b.realm]
        self.hp_max = K["health_units"] * self.U * b.n_body * K["health_mult"] * self.g
        self.qi_base = K["qi_units"] * self.U * b.n_qi
        self.hp = self.hp_max
        self.qi = self.qi_base * (1 - min(K["reserve_cap"], b.reserved))
        self.body_bar = b.body_shield * self.hp_max
        self.wshields = [dict(s=s, left=s.size * self.qi_base * (s.pieces and 1), quiet_since=0, pieces_left=s.pieces)
                         for s in b.shields]
        # extra wards: standing ones are up from the start; a standing shield ward joins the ward shields
        self.xwards = []
        for w in b.wards:
            self.xwards.append(dict(w=w, up=w["model"] != "cast", until=0, ready=0, bar=None))
            if w.get("shield") and w["model"] != "cast":
                self.wshields.append(dict(s=Shield(size=w["shield"]), left=w["shield"] * self.qi_base, quiet_since=0,
                                          pieces_left=1))
        self.tam_ma = b.tam_ma
        self.ts_spent = 0.0
        self.buffs, self.debuffs = [], []          # [element, stacks, t_end_ms(None=fight), source, length_ms]
        self.statuses = {}                          # id -> {"stacks", "until", "src", "batches"}
        self.lockouts = {}                          # status id -> ms until it may be reapplied
        self.counters = {c["id"]: 0.0 for c in b.counters}
        self.counter_def = {c["id"]: c for c in b.counters}
        self.counter_times = {c["id"]: [] for c in b.counters}   # per-stack expiry, for counters with each_for
        self.window = None          # an extended last act running: {"until", "next", "every", "spec"} (Effects 11)
        self.window_used = False
        self.channel_until = None   # an escape channel open: ms it ends (Combat rule 10; one per side)
        self.channel_e = 0.0
        self.fled = False
        self.pill_used = False      # the prepared pill was burned (burn_pill; one pill a fight)
        self.loss_log = []          # [ms, health lost, linh luc lost] per pulse, the last 30 s (lost_last)
        self.loss_prev = None       # health and linh luc at the last pulse's end
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
        self.state_since = 0          # ms the current stance began (composed_time)
        self.t_act = None             # ms of the last damaging or movement art or evade (Formulas L)
        self.t_move = None            # ms of the last movement art or evade
        self.crossed = False          # health fell to broken_threshold or below this fight (Wounded; Broken to the foe)
        self.state_def = {x["id"]: x for x in b.states}
        self.summons = []                           # [c, dtype, cd_ms, next_ms, until_ms]
        self.last_art = None
        self.cur_ev = None
        self.step = [0] * len(b.arts)               # multi-step arts: the step the next firing tries
        self.fire_log = []                          # [t_ms, art_id, tags, group]
        self.basic_ready = 0
        self.comp_ready = []
        self.soul_ready = 0
        self.refusals_left = b.refusals
        self.down = False
        self.trig_count = 0
        self.trig_dmg = 0.0
        self.direct_dmg = 0.0
        self.ward_paid = 0.0
        self.engine_counts = {}             # (event, art id) -> times: step unlocks and empowers, for fight.py's report
        self.protect = {}                   # element -> {for_first, swap_buff}: own debuff batches a cleanse skips
        self.hp_paid = 0.0                  # health the last art cost (Debt of Stone reads it)
        self.avoided = 0
        self.decoys = 0
        self.fight = None                   # set by Fight: live mods inside bsum (stack_more)
        self.in_more = False                # reading stack_more (bsum's re-entry guard)
        self.last_hit_t = 0                 # when a hit last landed on this side (own.since_hit)
        self.reflected = False              # reflect_first spent (Returning Wave)
        self.crit_meter = 0                 # counted crit, per mille (Effects Formulas A)
        self.last_cost = 0.0                # linh lực the last art paid (hit events carry it: Autumn Harvest)
        self.dealt = self.spent = self.healed = self.fat = 0.0
        self.dry_at = None
        self.log = []
        self.clipped = {}

    def __repr__(self):
        return "Side(%s)" % self.label

    def qi_max(self):
        return self.qi_base * (1 + self.bsum("qi_max"))

    def qi_use(self):
        """Usable linh lực: the maximum less what reservations hold [Combat Defence & Healing rule 10, reserve_cap 0.9]."""
        return self.qi_max() * (1 - min(K["reserve_cap"], self.b.reserved))

    def count(self, lst, el):
        n = sum(x[1] for x in lst if x[0] == el)
        if lst is self.buffs and self.b.stack_alias:   # stacks of another element counted as this one's
            n += sum(x[1] for x in lst if el in self.b.stack_alias.get(x[0], ()))
        return n

    def bsum(self, key):
        tot = 0.0
        # stack_more is read live (Rising Tide); while it is being read its conditions see the stacks without it
        # (a condition on linh lực would otherwise read itself through qi_max)
        sm = self.fight is not None and not self.in_more and self.fight.has_stack_more(self)
        for x in self.buffs:
            els = [x[0]] + list(self.b.stack_alias.get(x[0], ())) if self.b.stack_alias else [x[0]]
            more = 1.0
            if sm:
                self.in_more = True
                try:
                    more = max(0.0, 1 + self.fight.mod(self, "stack_more", {"element": x[0], "kind": "buff"}))
                finally:
                    self.in_more = False
            for el in els:
                tot += BUFF.get(el, {}).get(key, 0.0) * x[1] * stack_power(self.b, x[0], "buff") * more
        return tot

    def dsum(self, key):
        return sum(DEBUFF.get(x[0], {}).get(key, 0.0) * x[1] * stack_power(x[3].b, x[0], "debuff") for x in self.debuffs)

    def st(self, sid):
        s = self.statuses.get(sid)
        return s["stacks"] if s else 0


def stack_pct(table, el, kind):
    """A build's stack effect or duration % for one element and kind (keys "<el>|<kind>", "*" for any)."""
    return sum(table.get(k, 0.0) for k in ("%s|%s" % (el, kind), "%s|*" % el, "*|%s" % kind, "*|*"))


def stack_power(build, el, kind=None):
    p = build.purity.get(el, 0.0)
    if el == "water":
        p += K["water_ice_share"] * build.purity.get("ice", 0.0)
    elif el == "ice":
        p += K["water_ice_share"] * build.purity.get("water", 0.0)
    extra = stack_pct(build.stack_eff, el, kind or "*") if build.stack_eff else 0.0
    return (1 + K["purity_stack_power"] * p) * (1 + extra / 100)


def supp(att, dfn, pierce=0.0):
    """Combat Formulas H: supp(g, P) = 1 - s_g (1 - P), P = min(pierce_cap, sum pierce_pct / 100)."""
    g = SUPP[min(max(0, dfn.b.realm - att.b.realm), 4)]
    return 1 - g * (1 - min(K["pierce_cap"], max(0.0, pierce)))


# ------------------------------------------------------------------ the fight
class Fight:
    def __init__(self, b1, b2, seed=1, trace=False, order="random", parity=False, tags=()):
        """order: "random" draws which side acts first at each moment (the rule in both engines, ADR-0001); "fixed"
        is side A before side B, used only by the exact parity fixtures. parity: record
        `plog`, the event rows the parity suite compares (tests/parity, parity_export.py). tags: the request's kept
        tags (REQUEST_TAGS, e.g. tribulation), read as tag.<name> (Combat rule 12, AC-CB-104; 2026-11-26)."""
        self.tags = {t for t in tags if t in _C.get("REQUEST_TAGS", [])}
        for b in (b1, b2):
            validate(b)
        if order not in ("random", "fixed"):
            raise EngineError("order %r is not random or fixed" % order)
        self.rng = random.Random(seed)
        self.order = random.Random(seed + 7919)
        self.fixed_order = order == "fixed"
        self.plog = [] if parity else None
        self.A, self.B = Side(b1, "A"), Side(b2, "B")
        self.A.foe, self.B.foe = self.B, self.A
        self.A.fight = self.B.fight = self
        self.t = 0
        self.trace = trace
        self.rows = []
        self.depth = 0
        self.cache = {}
        self.hit_fees = set()                # per-hit wards that paid for the hit or tick in progress
        for s in (self.A, self.B):
            for i, a in enumerate(s.b.arts):
                # the opening cooldown honours art speed too, scoped to the art (Effect mods included)
                hz = 1 if self.mod(s, "speed_locked") > 0 else 1 + (s.b.art_speed_pct + self.mod(s, "art_speed", art_ctx(a))) / 100
                cd = max(K["cooldown_min"], a.cd / hz)
                first = max(K["cooldown_min"], cd / (1 + (s.b.opening_haste_pct + self.mod(s, "opening_haste")) / 100))
                s.ready.append(ms(first))
            s.basic_ready = ms(self.basic_cd(s))
            s.comp_ready = [ms(c.get("cd", K["basic_cooldown"])) for c in s.b.companions]
            s.body_bar *= self.shield_hold(s)

    # ---------------------------------------------------------- reads
    def read(self, s, key, ev=None):
        """Effects rule 5 readables. own.* reads s, foe.* reads s.foe."""
        side, _, k = key.partition(".")
        x = s if side == "own" else s.foe if side == "foe" else None
        if x is None:
            if key == "time":
                return self.t / 1000
            if key.startswith("cycle."):     # the pulse index modulo n (Tide's 6-pulse cycle)
                return float((self.t // ms(K["pulse"])) % int(key[6:]))
            if key.startswith("event."):
                return (ev or {}).get(key[6:], 0.0)
            if key.startswith("tag."):     # a kept request tag (tribulation; Combat rule 12, AC-CB-104)
                return 1.0 if key[4:] in self.tags else 0.0
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
        if k == "composed":     # the duel readings (Combat rule 25, Formulas L; 2026-11-26)
            return 1.0 if self.composed(x) else 0.0
        if k == "composed_time":
            if self.stance_tag(x, "composed"):
                return (self.t - x.state_since) / 1000
            c0 = (x.t_act or 0) + ms(K["composed_after"])
            return max(0, self.t - c0) / 1000
        if k == "pressing":
            if self.composed(x):
                return 0.0
            moved = x.t_move is not None and self.t - x.t_move < ms(K["pressing_after"])
            return 1.0 if self.stance_tag(x, "pressing") or moved else 0.0
        if k == "foe_pressed":
            o = x.foe
            return 1.0 if o.t_act is not None and self.t - o.t_act < ms(K["act_window"]) else 0.0
        if k == "since_act":
            return (self.t - (x.t_act or 0)) / 1000
        if k == "field_up":
            return 1.0 if self.stance_tag(x, "field") else 0.0
        if k == "broken":
            return 1.0 if x.foe.crossed else 0.0
        if k == "wounded":
            return 1.0 if x.crossed else 0.0
        if k.startswith("lost_last."):   # health or linh luc lost over the last N s (2026-11-26)
            _, pool, secs = k.split(".")
            return self.lost_last(x, pool, float(secs))
        if k.startswith("counter_hours.") or k.startswith("counter_this_hour."):
            head, cid = k.split(".", 1)
            return self.charge_hours(x, cid, head == "counter_this_hour")
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
        if k == "curses":                   # curse statuses up on the side (Weight of Names)
            return float(len([1 for sid, v in x.statuses.items() if v["stacks"] > 0 and STATUS.get(sid, {}).get("kind") == "curse"]))
        if k == "ward_paid":                # linh lực its drain wards have paid this fight, as a share of its qi_max
            return x.ward_paid / x.qi_max()
        if k == "body_shield_share":
            return x.body_bar / x.hp_max
        if k == "boss":
            return 1.0 if x.b.boss else 0.0
        if k == "tam_ma":
            return x.tam_ma
        if k == "evade":                    # own evade in points before the cap (Hidden Moon)
            return 0.0 if self.mod(x, "no_evade") > 0 else x.b.evade * 100 + self.mod(x, "evade")
        if k == "since_hit":                # seconds since a hit last landed on the side (Earthen Armour)
            return (self.t - x.last_hit_t) / 1000
        if k == "hp_max_lead":              # own maximum health over the foe's, less 1, at least 0 (Mountain's Weight)
            return max(0.0, x.hp_max / x.foe.hp_max - 1)
        if k == "state.any":                # any stance or state on (Unmoved Stance's closing)
            return 1.0 if x.state else 0.0
        if k.startswith("state."):
            return 1.0 if x.state == k[6:] else 0.0
        if k == "buff_elements":            # elements whose buff stacks the side holds (Wheel in the Flag)
            return float(len({d[0] for d in x.buffs if d[1] > 0}))
        if k.startswith("fired_within."):   # fired_within.<seconds>.<all|tag|group|art>[.<value>]: distinct arts
            parts = k.split(".")
            win = ms(float(parts[1]))
            what = parts[2]
            val = ".".join(parts[3:])
            seen = set()
            for t0, aid, tags, grp in x.fire_log:
                if self.t - t0 <= win and (what == "all" or (what == "tag" and val in tags)
                                           or (what == "group" and grp == val) or (what == "art" and aid == val)):
                    seen.add(aid)
            return float(len(seen))
        if k.startswith("since."):           # seconds since an art last fired (1e9 if never)
            aid = k[6:]
            last = [t0 for t0, a, _, _ in x.fire_log if a == aid]
            return (self.t - last[-1]) / 1000 if last else 1e9
        if k.startswith("step."):            # the step index a multi-step art will try next
            aid = k[5:]
            for i, a in enumerate(x.b.arts):
                if a.name == aid:
                    return float(x.step[i])
            return 0.0
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
            # only Effects that carry the key are evaluated (2026-11-20: reads are pure, so the sum is unchanged, and an
            # Effect scaled by a read such as own.evade no longer recurses through an unrelated key's sum)
            if not any(key in (a.get("mod") or {}) for a in e.get("do", [])):
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
            v = st_def["mods"][key]
            if not (v < 0 and key in ("art_speed", "basic_speed") and self.mod(s, "unmoved") > 0):
                tot += v                     # Unmoved Stance: a stance's speed penalties do not apply
        for e, acts, n in s.banked:
            for a in acts:
                m = a.get("mod")
                if m and key in m and match(m, ctx):
                    tot += m[key] * n
        return tot

    def has_stack_more(self, s):
        return any(e.get("on") == "always" and any("stack_more" in (a.get("mod") or {}) for a in e.get("do", []))
                   for e in s.b.effects)

    def shield_hold(self, s):
        """The share every body-shield bar and gain holds (Glass Meridians: half)."""
        return max(0.0, 1 + self.mod(s, "shield_hold"))

    def art_speed(self, s, a):
        """An art's speed multiplier as act() reads it (1 when speed_locked: Immovable Mountain)."""
        if self.mod(s, "speed_locked") > 0:
            return 1.0
        return 1 + s.bsum("speed") + s.b.art_speed_pct / 100 + self.mod(s, "art_speed", art_ctx(a)) / 100

    def overheat(self, s, art, ctx):
        """Overheat: art speed that cooldown_min clips on this art, in points, up to the mod's cap."""
        cap = self.mod(s, "overheat", ctx)
        if cap <= 0 or art is None or art.cd <= 0:
            return 0.0
        clipped = (self.art_speed(s, art) - art.cd / K["cooldown_min"]) * 100
        return min(cap, max(0.0, clipped))

    def layers_M(self, s, art, ctx):
        """M with layer mods. Builds with `layers` get exact caps; others scale their fixed M."""
        adds = [self.mod(s, "L%d" % i, ctx) for i in range(1, 6)]
        adds[4] += self.overheat(s, art, ctx)
        # Sealed Meridian (Status Catalogue): on the SEALED fighter, one named layer L2-L5 counts as 1.0 when it
        # attacks. Fixed 2026-11-14 (user ruling): the seal was read from the attacker's foe, applied to the base
        # product too (so it cancelled out), and only computed when a layer mod was present. A build without
        # `layers` has no layer breakdown, so the seal cannot reduce its fixed M.
        sealed = s.statuses["sealed_meridian"].get("layer", 4) if s.st("sealed_meridian") else None
        if not any(adds) and not (sealed is not None and s.b.layers):
            return s.b.M * (art.m_mult if art else 1.0)
        base = list(s.b.layers) if s.b.layers else [0, 0, 0, 0, 0]

        def M_of(x, seal):
            m = 1.0
            for i in range(5):
                xi = x[i]
                if i == 0 and xi > K["l1_soft"][0]:
                    xi = K["l1_soft"][0] + K["l1_soft"][1] * (xi - K["l1_soft"][0])
                if seal is not None and i >= 1 and i == seal:
                    xi = 0
                m *= 1 + min(xi, K["layer_caps"][i]) / 100
            return m
        new = [base[i] + adds[i] for i in range(5)]
        for i in range(5):
            if new[i] > K["layer_caps"][i]:
                s.clipped["L%d" % (i + 1)] = s.clipped.get("L%d" % (i + 1), 0) + 1
        return s.b.M * (art.m_mult if art else 1.0) * M_of(new, sealed) / M_of(base, None)

    def basic_cd(self, s):
        return max(K["cooldown_min"], K["basic_cooldown"] / (1 + (s.b.basic_speed_pct + self.mod(s, "basic_speed")) / 100))

    def slow(self, s):
        n = min(s.st("slowed_time"), STATUS["slowed_time"]["cap"])
        resist = 1 - (s.b.timer_resist + self.mod(s, "timer_resist")) / 100
        out = 1 + K["slowed_time_pct"] * n * resist
        dk = s.st("drunk")
        if dk:   # Drunk (Effects Status Catalogue, 2026-11-26): its own slow per stack beside Slowed Time
            out += STATUS["drunk"]["slow"] * dk * resist
        return out

    def check_cross(self, s, ev):
        """Broken and Wounded (Combat rule 25, Formulas L): the first time this fight s's health falls to
        broken_threshold of its maximum or below, s is Wounded and its foe has Broken it; once a fight."""
        if s.crossed or s.hp > K["broken_threshold"] * s.hp_max:
            return
        s.crossed = True
        self.fire_event(s, "wounded", dict(ev or {}))
        self.fire_event(s.foe, "broken", dict(ev or {}))

    def stance_tag(self, s, tag):
        st = s.state_def.get(s.state) if s.state else None
        return bool(st) and tag in st.get("tags", ())

    def composed(self, s):
        return self.stance_tag(s, "composed") or self.t - (s.t_act or 0) >= ms(K["composed_after"])

    def lost_last(self, s, pool, secs):
        """Health or linh luc s lost over the last secs seconds (Effects rule 5, 2026-11-26): each pulse's net loss in
        the window, plus what it has lost since the last pulse."""
        i = 1 if pool == "hp" else 2
        tot = sum(x[i] for x in s.loss_log if self.t - x[0] < ms(secs))
        if s.loss_prev is not None:
            now = s.hp if pool == "hp" else s.qi
            tot += max(0.0, s.loss_prev[i - 1] - now)
        return tot

    def charge_hours(self, s, cid, this_hour):
        """The fight hours (fight_hour s each) a charge counter's live charges were laid in: how many distinct hours, or
        how many charges were laid in the current hour (Effects rule 5, 2026-11-26; The Twelve Hours). A charge's laid
        time is its end less each_for, so a clock stop on its side counts it as laid that much later."""
        each = ms(s.counter_def.get(cid, {}).get("each_for") or 0)
        if not each:
            return 0.0
        hour = ms(K["fight_hour"])
        laid = [(u - each) // hour for u in s.counter_times.get(cid, []) if u > self.t]
        if this_hour:
            return float(sum(1 for h in laid if h == self.t // hour))
        return float(len(set(laid)))

    def upkeep(self, s, cid, up):
        """Upkeep on a self-counter (Effects rule 6, 2026-11-26): each pulse every stack costs its owner per_stack of the
        pool's maximum (qi: linh luc; hp: health, which must leave pay_keep_health). Stacks the pool cannot pay end;
        a charge counter (each_for) loses the charges nearest their end first."""
        charged = bool(s.counter_def[cid].get("each_for"))
        if charged:
            s.counter_times[cid] = sorted(u for u in s.counter_times[cid] if u > self.t)
            n = float(len(s.counter_times[cid]))
        else:
            n = s.counters[cid]
        if n <= 0:
            return
        qi = up.get("pool", "qi") == "qi"
        cost = up["per_stack"] * (s.qi_max() if qi else s.hp_max)
        have = s.qi if qi else s.hp - K["pay_keep_health"]
        keep = n if cost <= 0 or have >= n * cost else float(math.floor(max(0.0, have) / cost))
        paid = keep * cost
        if qi:
            s.qi -= paid
        else:
            s.hp -= paid
        if keep < n:
            if charged:
                s.counter_times[cid] = s.counter_times[cid][int(n - keep):]
            s.counters[cid] = keep

    def caster_held(self, s):
        """True while the foe carries a status that holds its caster and s cast it (Effects Status Catalogue,
        'Statuses that hold their caster', 2026-11-26). Read live, so any way the status ends frees the caster."""
        for sid, stt in s.foe.statuses.items():
            if STATUS.get(sid, {}).get("holds_caster") and stt.get("src") is s and stt["stacks"] > 0:
                return True
        return False

    def end_status(self, s, sid, early=False):
        """End a status now (its time ran out, or a hit ended it); the reapply lockout starts. A Sleep cut short gives
        back the clock time it had not used yet (only to timers its stop moved and nothing has reset since)."""
        stt = s.statuses.pop(sid, None)
        if stt is None:
            return
        lock = STATUS.get(sid, {}).get("lockout")
        if lock and not stt.get("no_lockout"):
            s.lockouts[sid] = self.t + ms(lock)
        if early and stt.get("clock") and stt.get("until") is not None and stt["until"] > self.t:
            self.restart_clock(stt["clock"], stt["until"] - self.t)

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
                if s.channel_until is not None and s.channel_until >= self.t:   # an escape channel ending
                    cands.append(s.channel_until)
                if s.window is not None:   # an extended last act: only its rounds wake the loop; its own timers stand
                    if s.window["next"] >= self.t:
                        cands.append(s.window["next"])
                    continue
                cands += [r for i, r in enumerate(s.ready) if r > self.t and not s.removed[i]]
                cands += [s.basic_ready] + [c for c in s.comp_ready if c > self.t]
            t = min(c for c in cands if c >= self.t)
            if t > limit:
                break
            self.t = t
            if t >= next_pulse:
                first, second = self.sides_in_order()
                self.pulse(first)
                self.pulse(second)
                next_pulse += ms(K["pulse"])
                if self.trace:
                    self.rows.append((t / 1000, A.hp / A.hp_max, A.qi / A.qi_max(), B.hp / B.hp_max, B.qi / B.qi_max()))
            first, second = self.sides_in_order()
            self.act(first)
            self.act(second)
            self.escape_rolls()
            for s in (A, B):
                if s.dry_at is None and s.qi < 0.05 * s.qi_max():
                    s.dry_at = t / 1000
            if A.fled or B.fled:   # a success ends the fight there (Combat rule 10)
                break
            self.defeat_check()
            if A.down or B.down:
                break
        if A.fled or B.fled:
            # the fled side wins by knockout if the foe is at 0 or below; otherwise flight, no winner
            win = ("flight" if A.fled and B.fled else "A" if A.fled and B.hp <= 0 else "B" if B.fled and A.hp <= 0
                   else "flight")
        else:
            win = "draw" if A.down and B.down else "A" if B.down else "B" if A.down else "time"
        return dict(t=self.t / 1000, win=win, A=A, B=B, rows=self.rows, plog=self.plog)

    def escape_rolls(self):
        """Escape channels ending this instant, after both sides' hits, A (the requesting side) first (Combat rule 10,
        Formulas I). A side at 0 or below does not flee; Bound fails it with no draw; otherwise p is drawn."""
        for s in (self.A, self.B):
            if s.channel_until is None or self.t < s.channel_until:
                continue
            s.channel_until = None
            if s.hp <= 0:
                continue
            o = s.foe
            if s.st("bound") > 0:
                ok = False
            else:
                lock = 1 if self.mod(o, "lock") > 0 else 0
                p = min(K["escape_max"], max(K["escape_min"], s.channel_e + K["escape_realm_step"] * (s.b.realm - o.b.realm)
                                              - K["escape_lock_penalty"] * lock + self.mod(s, "escape") / 100))
                ok = self.rng.random() < p
            if self.plog is not None:
                self.plog.append(["escape", self.t, s.label, "fled" if ok else "failed"])
            if ok:
                s.fled = True
            else:
                self.fire_event(s, "escape_failed", {})

    def sides_in_order(self):
        """Who acts first at this moment: a coin from the order stream, or A then B when the order is fixed."""
        if self.fixed_order:
            return self.A, self.B
        return (self.A, self.B) if self.order.random() < 0.5 else (self.B, self.A)

    # ---------------------------------------------------------- pulses
    def pulse(self, s):
        if s.window is not None:     # an extended last act: the side is out of the fight but for its free hits
            return
        o = s.foe
        # element ticks (Burn, Poison)
        for el, n, t_end, src in [x[:4] for x in s.debuffs]:
            c = DEBUFF.get(el, {}).get("burn", 0.0) + DEBUFF.get(el, {}).get("poison", 0.0)
            if c:
                tick = src.U_att * c * n * src.b.M * (1 + src.bsum("dmg")) * supp(src, s, self.mod(src, "pierce") / 100) * stack_power(src.b, el, "debuff")
                self.tick(src, s, tick, TICK_TYPE[el], el)
        # status ticks
        for sid, stt in list(s.statuses.items()):
            d = STATUS.get(sid)
            if d is None:   # Internal Injury is not a catalogue status: released below (fixed 2026-11-14, was KeyError)
                continue
            if d["kind"] == "tick" and stt["stacks"] > 0:
                src = stt["src"]
                tick = src.U_att * d["c_tick"] * stt["stacks"] * src.b.M * supp(src, s, self.mod(src, "pierce") / 100)
                if d.get("on_qi"):
                    s.qi = max(0.0, s.qi - tick)
                    if self.plog is not None:
                        self.plog.append(["qi_tick", self.t, src.label, sid, tick, s.hp, s.qi])
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
            st["next"] = self.t + ms(st.get("every", K["injury_every"]))
            s.hp -= amt
            st["src"].dealt += amt
        # regeneration; Stagnation dampens both pools by 1 % per stack [Status Catalogue, 2026-11-10]
        stag = 1 + s.st("stagnation") * STATUS["stagnation"]["regen_dampen"] / 100
        k = K["regen_k"]
        bonus = s.b.regen_bonus + s.bsum("regen") + self.mod(s, "regen")
        regen = s.qi_max() * (K["regen_base"] + k * math.log(1 + max(0.0, bonus) / k)) / stag
        if self.mod(s, "no_regen") > 0:     # Water Table's closing: no linh luc regeneration in fights
            regen = 0.0
        room = s.qi_use() - s.qi
        if regen > room:
            self.fire_event(s, "overflow", {"amount": regen - room, "share": (regen - room) / s.qi_max()})
        s.qi = min(s.qi_use(), s.qi + regen)
        hreg = s.hp_max * (s.b.hregen + s.bsum("hregen") + self.mod(s, "hregen")) * s.b.bs_mult / stag \
            * (1 + self.mod(s, "hregen_inc") / 100)
        if hreg > 0:
            self.heal(s, hreg, source="regen")
        # cleansing ward
        n = s.b.cleanse_pulse
        while n > 0 and s.debuffs:
            s.debuffs.sort(key=lambda x: x[2] if x[2] is not None else 1 << 40)
            j = next((i for i, x in enumerate(s.debuffs) if not self.held_fast(x)), None)
            if j is None:   # only talisman stacks held fast are left (2026-11-26)
                break
            fee = s.b.cleanse_cost * s.qi_max()
            if s.qi < fee:
                break
            s.qi -= fee
            s.debuffs[j][1] -= 1
            if s.debuffs[j][1] <= 0:
                s.debuffs.pop(j)
            n -= 1
        if s.b.cleanse_share:
            for x in s.debuffs:
                if not self.held_fast(x):
                    x[1] *= (1 - s.b.cleanse_share)
            s.debuffs = [x for x in s.debuffs if x[1] >= K["cleanse_min_stacks"]]
        # fatigue
        if self.t >= ms(K["fatigue_start"]):
            n = round((self.t - ms(K["fatigue_start"])) / 1000)
            f = s.U * K["fatigue_units"] * (1 + n) ** K["fatigue_pow"] * (s.g if K["fatigue_by_realm"] else 1.0)
            s.hp -= f
            s.fat += f
        # durations; a debuff batch that runs out on its own raises batch_ended for its source (Wildfire)
        s.buffs = [x for x in s.buffs if x[2] is None or x[2] > self.t]
        ended = [x for x in s.debuffs if x[2] is not None and x[2] <= self.t]
        s.debuffs = [x for x in s.debuffs if x[2] is None or x[2] > self.t]
        for x in ended:
            if x[3] is not None and x[1] > 0:
                self.fire_event(x[3], "batch_ended", {"element": x[0], "stacks": x[1], "kind": "debuff",
                                                      "rekindled": 1.0 if len(x) > 5 and x[5] == "rekindled" else 0.0})
        for sid in list(s.statuses):
            stt = s.statuses[sid]
            if "each" in stt:   # Drunk: each stack ends on its own time
                stt["each"] = [b for b in stt["each"] if b[1] is None or b[1] > self.t]
                stt["stacks"] = sum(b[0] for b in stt["each"])
                if not stt["each"]:
                    self.end_status(s, sid)
                else:
                    ends = [b[1] for b in stt["each"]]
                    stt["until"] = None if None in ends else max(ends)
                continue
            if stt.get("until") is not None and stt["until"] <= self.t:
                self.end_status(s, sid)
        s.temp_mods = [m for m in s.temp_mods if m[2] > self.t]
        # self-counter decay
        for cid, cdef in s.counter_def.items():
            dec = cdef.get("decay_per_pulse", 0)
            if dec:
                s.counters[cid] = max(0.0, s.counters[cid] - dec)
            dsh = cdef.get("decay_share", 0)
            if dsh:   # decay by a share of the count each pulse (world-depth Stage 5; Effects rule 19's closes)
                s.counters[cid] *= max(0.0, 1.0 - dsh)
            if cdef.get("upkeep"):
                self.upkeep(s, cid, cdef["upkeep"])
        self.check_cross(s, {"kind": "pulse"})
        if s.loss_prev is not None:   # this pulse's net losses, for lost_last
            s.loss_log.append([self.t, max(0.0, s.loss_prev[0] - s.hp), max(0.0, s.loss_prev[1] - s.qi)])
            s.loss_log = [x for x in s.loss_log if self.t - x[0] < ms(K["lost_last_keep"])]
        s.loss_prev = (s.hp, s.qi)
        # per-pulse limits reset
        s.trig_count = 0
        s.trig_dmg = 0.0
        s.direct_dmg = 0.0
        s.avoided = 0
        for st_ in s.eff_state.values():
            st_["pulse"] = 0
            st_["pulse_n"] = 0.0
        # ward shield recharge
        for w in s.wshields:
            cap = w["s"].size * s.qi_base
            if w["s"].standing and self.t - w["quiet_since"] >= ms(K["recharge_delay"]) and w["left"] < cap:
                w["left"] = min(cap, w["left"] + K["shield_recharge"] * cap)
                if w["s"].pieces > 1:
                    w["pieces_left"] = min(w["s"].pieces, w["pieces_left"] + 1)
        if self.plog is not None:
            self.plog.append(["pulse", self.t, s.label, s.hp, s.qi])
        self.fire_event(s, "pulse", {})

    # ---------------------------------------------------------- acting
    def cast_wards(self, s):
        """Cast wards [Combat Defence & Healing rule 7]: fired on their cooldown when linh lực pays the cast cost,
        up for their window; a cast shield's bar lasts the window."""
        for xw in s.xwards:
            w = xw["w"]
            if w["model"] != "cast":
                continue
            if xw["up"] and self.t >= xw["until"]:
                xw["up"] = False
                if xw["bar"] is not None and xw["bar"] in s.wshields:
                    s.wshields.remove(xw["bar"])
                xw["bar"] = None
            if not xw["up"] and self.t >= xw["ready"]:
                cost = w.get("cost", 0.0) * s.qi_base
                if s.qi + 1e-9 < cost:
                    continue
                s.qi -= cost
                s.spent += cost
                xw["up"], xw["until"], xw["ready"] = True, self.t + ms(w.get("up", 3.0)), self.t + ms(w.get("cooldown", 5.0))
                if w.get("shield"):
                    xw["bar"] = dict(s=Shield(size=w["shield"], standing=False), left=w["shield"] * s.qi_base,
                                     quiet_since=self.t, pieces_left=1)
                    s.wshields.append(xw["bar"])

    def act(self, s):
        if s.down:
            return
        if s.window is not None:   # an extended last act: only its named free hits, one round each `every`
            w = s.window
            spend = w["spec"].get("spend")
            while self.t >= w["next"] and w["next"] <= w["until"] and not (spend and s.counters.get(spend, 0.0) <= 0):
                for h in w["spec"].get("hits", []):
                    self.hit(s, s.foe, h["c"], h.get("dtype", "phys"), None, kind="trigger", trig=True)
                if spend:
                    s.counters[spend] = max(0.0, s.counters[spend] - 1)
                w["next"] += w["every"]
            return
        if s.xwards:
            self.cast_wards(s)
        o = s.foe
        b = s.b
        speed_base = 1 + s.bsum("speed") + b.art_speed_pct / 100
        sup = set(s.state_def.get(s.state, {}).get("suppress", []))
        # Sleep and Charmed hold every art of their target; a status s laid that holds its caster holds s's damaging
        # arts and basic attack (Effects Status Catalogue, 2026-11-26)
        stopped = s.st("sleep") > 0 or s.st("charmed") > 0
        held = self.caster_held(s) if o.statuses else False
        for i, a in enumerate(b.arts):
            if s.removed[i] or self.t < s.ready[i] or a.name in sup:
                continue
            if a.escape and s.channel_until is not None:   # one escape channel open at a time; a ready one waits
                continue
            if stopped or (held and (a.c or a.soul_pct or a.soul_part)):
                continue
            if a.tags and s.st("silence") and s.statuses["silence"].get("tag") in a.tags:
                continue
            if not self.holds(s, a.guards):
                continue
            if a.soul_pct and self.t < s.soul_ready:
                continue
            if not self.pay(s, a):
                continue
            a = self.shape(s, i, a)
            # art speed may be scoped (Sword arts, Fire arts, curse arts): read it in the art's own context
            speed = 1.0 if self.mod(s, "speed_locked") > 0 else speed_base + self.mod(s, "art_speed", art_ctx(a)) / 100
            for st_ in s.eff_state.values():   # per_firing limits restart with each art firing
                st_["firing"] = 0
            cd = max(K["cooldown_min"], a.cd / speed) * self.slow(s)
            s.charges[i] -= 1
            if s.charges[i] > 0:
                s.ready[i] = self.t + ms(K["cooldown_min"])
            else:
                s.ready[i] = self.t + ms(cd)
                s.charges[i] = a.charges
            s.fired[i] += 1
            s.first[i] = False
            s.fire_log.append([self.t, b.arts[i].name, a.tags, a.group])
            s.fire_log = [x for x in s.fire_log if self.t - x[0] <= 30000]
            if a.soul_pct or a.soul_part:
                s.soul_ready = self.t + ms(K["soul_lockout"])
            if a.buff:
                self.add_stacks(s, s, a.element, a.buff[0], a.buff[1], buff=True)
            if a.cleanse:
                self.cleanse(s, a.cleanse)
            if a.heal:
                got0 = s.healed
                self.heal(s, s.U_att * a.heal * K["health_mult"])
                if s.healed > got0:
                    s.qi = min(s.qi_use(), s.qi + s.last_cost)
            if a.qi_restore:
                s.qi = min(s.qi_use(), s.qi + a.qi_restore * s.qi_max())
            if self.plog is not None:
                self.plog.append(["art", self.t, s.label, a.name, s.last_cost, s.hp, s.qi])
            ev = {"art": a, "art_id": a.name, "slot": i, "cost": s.last_cost, "tags": a.tags, "element": a.element,
                  "dtype": a.dtype, "kind": "art", "hp_paid_share": s.hp_paid / s.hp_max}
            s.cur_ev = ev
            s.last_art = i
            if a.c or a.soul_pct or a.soul_part or "movement" in a.tags:   # the duel readings' clock (Formulas L)
                s.t_act = self.t
            if "movement" in a.tags:
                s.t_move = self.t
            if a.escape:   # an escape art opens its channel; hits keep landing (Combat rule 10)
                s.channel_until = self.t + ms(K["escape_channel"])
                s.channel_e = a.escape
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
            if not (stopped or held):   # a held basic attack misses; its timer still runs
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
                self.hit(s, o, comp["c"], comp.get("dtype", "phys"), None, kind="companion", ctags=comp.get("tags", ()))
                cd = comp.get("cd", K["basic_cooldown"]) / (1 + self.mod(s, "companion_speed") / 100)
                s.comp_ready[j] += ms(max(K["cooldown_min"], cd))

    def shape(self, s, i, a):
        """A multi-step art fires as its next step when that step's unlock holds (paying its `pay`), else as step 1;
        then any empower whose `if` holds adds its payload (paying its `pay`). Returns the art as it fires."""
        import copy
        fired = a
        if a.steps:
            nxt = s.step[i] + 1
            if nxt <= len(a.steps) and self.holds(s, a.steps[nxt - 1].get("unlock"))                     and self.step_health(s, a, a.steps[nxt - 1], pay=False):
                st = a.steps[nxt - 1]
                self.step_health(s, a, st, pay=True)
                fired = override(a, st)
                if st.get("pay"):
                    self.do(s, {"id": a.name + "-step", "on": "art_fired"}, st["pay"], 1.0, {"art_id": a.name})
                s.step[i] = nxt if nxt < len(a.steps) else 0
                if self.plog is not None:
                    self.plog.append(["step", self.t, s.label, a.name, nxt])
                self.fire_event(s, "step_unlocked", {"art_id": a.name, "step": nxt})
            else:
                s.step[i] = 0
        for em in a.empower:
            if self.holds(s, em.get("if")):
                if fired is a:
                    fired = copy.copy(a)
                if em.get("pay"):
                    self.do(s, {"id": a.name + "-empower", "on": "art_fired"}, em["pay"], 1.0, {"art_id": a.name})
                fired = override(fired, em)
                if self.plog is not None:
                    self.plog.append(["empower", self.t, s.label, a.name])
                self.fire_event(s, "empowered", {"art_id": a.name})
        return fired

    def step_health(self, s, a, st, pay):
        """A step's own health cost (2026-11-14, reckless-gale): hp_cost x health_max, reduced by hp_cost_red, paid
        first by the body shield under shield_pays, like an art's health cost; it must leave pay_keep_health or the
        step does not unlock. With pay=False it only answers whether the step can pay."""
        share = st.get("hp_cost", 0.0)
        if not share:
            return True
        need = share * s.hp_max * (1 - min(1.0, self.mod(s, "hp_cost_red", art_ctx(a))))
        from_shield = min(s.body_bar, need) if self.mod(s, "shield_pays") > 0 else 0.0
        if s.hp - (need - from_shield) < K["pay_keep_health"]:
            return False
        if pay:
            s.body_bar -= from_shield
            s.hp -= need - from_shield
            s.hp_paid += need
        return True

    def pay(self, s, a):
        b = s.b
        s.hp_paid = 0.0
        cost_up = (1 + s.dsum("cost_up")) * (1 + s.st("heavy_breath") * STATUS["heavy_breath"]["cost_up"])
        cost = a.cost * K["cost_scale"] * (1 - min(K["cost_red_cap"], b.cost_red + self.mod(s, "cost_red", art_ctx(a)))) * cost_up * s.qi_base
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
        hp_red = 1 - min(1.0, self.mod(s, "hp_cost_red", art_ctx(a)))   # Whetstone Vow: health costs halved
        if a.hp_cost and s.hp - a.hp_cost * hp_red * s.hp_max < K["pay_keep_health"] and self.mod(s, "shield_pays") <= 0:
            return False
        qi_part = cost * (1 - b.hp_pay)
        hp_part = cost * b.hp_pay * (s.hp_max / s.qi_base)
        x_hp = self.mod(s, "art_cost_hp", art_ctx(a))
        if x_hp > 0:
            # art_cost_health_pct (Combat E, #44 B4): linh luc pays cost / (1 + X/100), health the rest point for point
            shifted = qi_part - qi_part / (1 + x_hp / 100)
            qi_part -= shifted
            hp_part += shifted
        blood = s.qi + 1e-6 < qi_part and self.mod(s, "blood_cast") > 0
        if blood:                            # Blood Casting: the shortfall is paid in health, 1 for 1; it may put you Down
            hp_part += qi_part - max(0.0, s.qi)
            qi_part = max(0.0, s.qi)
        if s.qi + 1e-6 < qi_part:
            return False
        hp_total = (hp_part + a.hp_cost * s.hp_max) * hp_red
        from_shield = min(s.body_bar, hp_total) if self.mod(s, "shield_pays") > 0 else 0.0
        if hp_total - from_shield > 0 and s.hp - (hp_total - from_shield) < K["pay_keep_health"] and not blood:
            return False
        s.qi -= qi_part
        s.body_bar -= from_shield            # Shield Pays the Blood: the body shield pays health costs first
        s.hp -= hp_total - from_shield
        s.hp_paid = hp_total
        ice = sum(DEBUFF["ice"]["cost_up"] * x[1] * stack_power(x[3].b, "ice", "debuff") for x in s.debuffs if x[0] == "ice")
        if ice > 0 and qi_part > 0:          # the part of this cost the foe's Ice stacks added (Toll Taker)
            self.fire_event(s.foe, "foe_cost_extra", {"amount": qi_part * ice / (1 + s.dsum("cost_up"))})
        s.spent += qi_part
        s.last_cost = qi_part
        return True

    # ---------------------------------------------------------- hits
    def hit(self, att, dfn, c, dtype, art, kind="art", trig=False, ctags=()):
        """One hit through the defence path. Returns the health removed."""
        if dfn.window is not None:   # an extended last act: the side cannot be struck (Effects rule 11)
            return 0.0
        # ctags: a companion's own tags (crane, bird) ride on its hits (2026-11-26)
        ctx = {"dtype": dtype, "element": art.element if art else "", "tags": art.tags if art else (kind,) + tuple(ctags), "kind": kind,
               "art_id": art.name if art else kind}
        # avoid [R6]
        if not trig and dfn.decoys > 0 and dfn.avoided < K["avoid_budget"]:
            dfn.decoys -= 1
            dfn.avoided += 1
            return 0.0
        # Returning Wave: the first hit taken does no harm and strikes the attacker at full damage, once a fight
        if not trig and not dfn.reflected and self.mod(dfn, "reflect_first") > 0:
            dfn.reflected = True
            back = self.layers_M(att, art, ctx) if kind != "companion" else att.b.M
            D0 = att.U_att * c * back * supp(att, dfn, self.mod(att, "pierce") / 100)
            got = self.defend(dfn, att, D0, dtype, None, dict(ctx, kind="trigger"), is_tick=False)
            dfn.dealt += got
            if self.plog is not None:
                self.plog.append(["reflect", self.t, dfn.label, D0, got, att.hp, att.qi])
            return 0.0
        # evade
        w_ev = sum(xw["w"].get("evade", 0.0) for xw in dfn.xwards
                   if xw["up"] and (xw["w"]["model"] == "reserved" or dfn.qi > 0)) / 100   # evade wards (2026-11-13)
        p_ev = min(K["evade_cap"], max(0.0, dfn.b.evade + w_ev + self.mod(dfn, "evade") / 100 - dfn.dsum("evade_down")
                                       - (att.b.acc + self.mod(att, "acc") / 100 + att.bsum("acc") - att.dsum("acc_down"))
                                       + STATUS["drunk"]["acc_down"] * att.st("drunk")))   # Drunk: aim lost (2026-11-26)
        if self.mod(dfn, "no_evade") > 0:
            p_ev = 0.0
        if dfn.st("off_guard") > 0:
            pass   # Off Guard: evade counts as 0, with no draw (2026-11-26)
        elif self.rng.random() < p_ev:
            dfn.t_act = dfn.t_move = self.t   # an evade is an act and a move (Formulas L)
            self.fire_event(dfn, "evaded", ctx)
            self.fire_event(att, "was_evaded", ctx)
            return 0.0
        dfn.last_hit_t = self.t
        wake_cut = 0.0
        if dfn.statuses:   # the hit landed: it may end a held status (Effects Status Catalogue, 2026-11-26)
            if dfn.st("sleep") > 0:   # any direct hit wakes the sleeper, and deals less
                wake_cut = STATUS["sleep"]["wake_cut"]
                self.end_status(dfn, "sleep", early=True)
            ch = dfn.statuses.get("charmed")
            if ch and ch.get("src") is att and kind != "companion":   # the charmer's own trigger or free hit
                self.end_status(dfn, "charmed", early=True)
        is_crit = False
        if kind not in ("companion",) and not trig:
            cap = K["crit_cap"]
            cap_to = self.mod(att, "crit_cap_to")
            if cap_to > 0:
                cap = min(cap, cap_to)
            ch = min(cap, att.b.crit + self.mod(att, "crit", ctx) / 100 + att.bsum("crit") + dfn.dsum("crit_taken"))
            if self.mod(att, "counted_crit") > 0:   # Called Blow: a meter in thousandths, no draw (Effects Formulas A)
                att.crit_meter += int(math.floor(max(0.0, ch) * 1000 + 0.5))
                if att.crit_meter >= 1000:
                    att.crit_meter -= 1000
                    is_crit = True
            else:
                is_crit = self.rng.random() < ch
            if self.mod(att, "sure_crit", ctx) > 0:
                is_crit = True
        ctx["crit"] = is_crit
        crit = (att.b.crit_mult + self.mod(att, "crit_mult", ctx) / 100 + dfn.dsum("critdmg_taken")) if is_crit else 1.0
        phys = dtype == "phys"
        more = 1 + att.bsum("dmg") + (att.bsum("dmg_phys") + dfn.dsum("phys_taken") if phys else 0)
        more *= 1 + self.mod(att, "dmg_more", ctx)
        M = self.layers_M(att, art, ctx) if kind != "companion" else att.b.M
        D = att.U_att * c * M * crit * more * supp(att, dfn, self.mod(att, "pierce") / 100)
        if wake_cut:   # the hit that wakes a sleeper deals less
            D *= 1 - wake_cut
        if (art is not None and art.element == "water"
                and dfn.st("drunk") >= STATUS["drunk"]["water_taken_at"]):   # Drunk at 3+: Water parts hit harder
            D *= 1 + STATUS["drunk"]["water_taken"]
        damp =(dfn.bsum("phys_dampen") if phys else 0.0) + self.mod(dfn, "dampen_taken", ctx) / 100
        if damp:
            D /= 1 + damp
        D_in = D                             # the hit's amount before the defence path (parity log)
        soul_D = 0.0
        if art is not None and art.soul_part:
            soul_D = D * art.soul_part
            D -= soul_D
        conv = art.convert if art is not None else None
        self.hit_fees = set()
        if conv and conv.get("share"):
            cD = D * conv["share"]
            dealt = self.defend(att, dfn, D - cD, dtype, art, ctx, is_tick=False)
            dealt += self.defend(att, dfn, cD, conv["to"], art, dict(ctx, dtype=conv["to"]), is_tick=False)
        else:
            dealt = self.defend(att, dfn, D, dtype, art, ctx, is_tick=False)
        if soul_D:
            sr = dfn.b.soul_res + self.mod(dfn, "soul_res") + dfn.st("slackened_soul") * STATUS["slackened_soul"]["soul_res"] \
                + self.mod(att, "foe_soul_res")   # Lamp-Lit Reading
            sd = soul_D / (1 + sr / 100) if sr >= 0 else soul_D * (1 + abs(sr) / 100)
            dfn.hp -= sd
            dealt += sd
        att.dealt += dealt
        if trig:
            att.trig_dmg += dealt
        else:
            att.direct_dmg += dealt
        ev = dict(ctx, amount=dealt, crit=is_crit, cost=att.last_cost if kind == "art" and not trig else 0.0)
        # sustain on hit (a hit landed: not evaded, even if blocked to 0)
        on_hit = 0.0 if self.mod(att, "no_gain_on_hit") > 0 else att.b.gain_on_hit + self.mod(att, "gain_on_hit") / 100
        gain = on_hit * att.qi_max() + (att.b.leech_qi + self.mod(att, "leech_qi") / 100) * dealt
        att.qi = min(att.qi_use(), att.qi + gain)
        lh = att.b.leech_hp + self.mod(att, "leech_hp") / 100
        if lh:
            self.heal(att, lh * dealt, source="leech")   # a leech is a heal's source (2026-11-26)
        if self.plog is not None:
            self.plog.append(["hit", self.t, att.label, kind, ctx["art_id"], D_in, dealt, dfn.hp, dfn.qi, att.hp, att.qi])
        if art and art.debuff:
            self.add_stacks(att, dfn, art.element, art.debuff[0], art.debuff[1], buff=False,
                            mark="talisman" if "talisman" in art.tags else None)   # talisman stacks (2026-11-26)
        if art:
            for st in art.statuses:
                self.apply_status(att, dfn, st)
        self.check_cross(dfn, ev)
        if not trig or self.depth < K["trig_depth"]:
            self.fire_event(att, "hit_landed", ev)
            if is_crit:
                qc = self.mod(att, "qi_on_crit", ctx) / 100   # linh_luc_on_crit_pct: pp of maximum per crit (#44 B3)
                if qc:
                    att.qi = min(att.qi_use(), att.qi + qc * att.qi_max())
                self.fire_event(att, "crit", ev)
            self.fire_event(dfn, "was_hit", ev)
            if ev.get("stopped"):
                self.fire_event(dfn, "hit_stopped", ev)
            if kind in ("art", "basic"):
                self.spend_banked(att, "hit_landed", ev)
        return dealt

    def resistance(self, dfn, dtype, qi_live=True):
        Rw = dfn.b.ward_pts * dfn.b.ward_layer * max(0.0, 1 + self.mod(dfn, "ward_pct") / 100) if (dfn.qi > 0 and qi_live) else 0.0
        Rb = dfn.b.body_pts * dfn.b.bs_mult + dfn.b.resist.get(dtype, 0.0) + self.mod(dfn, "resist", {"dtype": dtype})
        Rc = dfn.st("sundered") * STATUS["sundered"]["res_pts"] + dfn.st("exposed") * STATUS["exposed"]["res_all"]
        return Rw, Rb + Rc

    def extra_wards(self, dfn, dtype, is_tick):
        """The extra wards up against this hit part: [(ward, resistance points)]. A per-hit ward pays its fee here
        once per hit (all its parts) and once per tick; every ward but a reserved one needs live linh lực, as the main
        ward does."""
        out = []
        for xw in dfn.xwards:
            w = xw["w"]
            if not xw["up"] or (w["model"] != "reserved" and dfn.qi <= 0):
                continue
            pts = w["payload"].get(dtype, 0.0) + w["payload"].get("all", 0.0)
            if pts <= 0 and not w.get("block"):
                continue
            if w["model"] == "per_hit":
                # one fee per hit covering all its parts, and one per tick (CD&H rule 6, 2026-11-13; it was charged
                # per part and met no ticks)
                key = id(xw)
                if key not in self.hit_fees:
                    fee = w.get("cost", 0.0) * dfn.qi_max()
                    if dfn.qi + 1e-9 < fee:
                        continue
                    dfn.qi -= fee
                    dfn.spent += fee
                    self.hit_fees.add(key)
            out.append((w, pts * dfn.b.ward_layer))
        return out

    def defend(self, att, dfn, D, dtype, art, ctx, is_tick=False):
        """Resistance with the drain bill, block, shields, health. Returns health removed."""
        if dtype == "soul":
            dfn.hp -= D
            return D
        Rw, Ro = self.resistance(dfn, dtype)
        xs = self.extra_wards(dfn, dtype, is_tick) if dfn.xwards else []
        R_raw = Rw + Ro + sum(r for _, r in xs)
        # resistance penetration in points, its type scope matching this part's final type (CD&H rule 4, AC-CD-13)
        pen = self.mod(att, "pen", dict(ctx or {}, dtype=dtype)) if att is not None else 0.0
        R = R_raw - pen
        if R >= 0:
            prevented = D * R / (100 + R) if R > 0 else 0.0
            bill_share = prevented * Rw / R_raw if R > 0 and R_raw > 0 else 0.0
        else:
            prevented = -D * abs(R) / 100   # negative: amplified
            bill_share = 0.0
        bill_up = (1 + (att.b.ward_bill_pct + self.mod(att, "ward_bill")) / 100) * (1 + dfn.st("leaking_ward") * STATUS["leaking_ward"]["bill_up"])
        bill = bill_share * dfn.b.drain * K["drain_scale"] / dfn.b.ward_layer / dfn.g * bill_up
        for w, r in xs:                     # an extra drain ward bills for the share of prevention it holds
            if w["model"] == "drain" and R > 0 and R_raw > 0 and prevented > 0:
                share = prevented * r / R_raw
                bill_share += share
                bill += share * w.get("drain", 0.0) * K["drain_scale"] / dfn.b.ward_layer / dfn.g * bill_up
        if bill > 0:
            paid = min(bill, dfn.qi)
            if bill > dfn.qi:
                frac = dfn.qi / bill
                dfn.qi = 0.0
                prevented -= bill_share * (1 - frac)
            else:
                dfn.qi -= bill
            dfn.ward_paid += paid
            if paid > 0:
                self.fire_event(att, "foe_ward_paid", {"amount": paid})
        a = D - prevented
        ward_took = bill_share if bill_share > 0 else 0.0   # the drain ward's part of the prevention (world-depth Stage 5)
        # block (not for ticks unless an Effect lets a share meet them, R24)
        blk = BLOCK_UNIT[dfn.b.realm] * dfn.b.stage_mult * (dfn.b.block + self.mod(dfn, "block") + dfn.b.body_block * dfn.b.bs_mult
                                         + sum(w.get("block", 0.0) for w, _ in xs))
        if is_tick:
            blk *= self.mod(dfn, "tick_block") / 100
        if self.mod(dfn, "no_block") > 0 or (att is not None and self.mod(att, "ignore_block") > 0):
            blk = 0.0
        blocked = min(max(0.0, a), blk)
        a = max(0.0, a - blk)
        if blocked > 0 and not is_tick:
            self.fire_event(dfn, "blocked", dict(ctx or {}, amount=blocked, dtype=dtype))
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
                ward_took += soak
            a = rest + through
            if a > 0 and dfn.body_bar > 0 and dtype not in ("chaos", "soul") and self.mod(dfn, "no_body_shield") <= 0:
                soak = min(a, dfn.body_bar)
                dfn.body_bar -= soak
                a -= soak
                reached = soak > 0
        dealt = 0.0 if a <= 1e-12 else (a if is_tick else max(K["min_hit"], a))
        if dealt > 0:
            reached = True
        if ward_took > 0 and not is_tick:   # Effects rule 5 (2026-11-26): a ward absorbed a hit, or a share of it
            self.fire_event(dfn, "ward_absorbed", dict(ctx or {}, amount=ward_took, dtype=dtype))
        dfn.hp -= dealt
        if not reached and not is_tick and D > 0:
            ctx["stopped"] = True
        return dealt

    def tick(self, src, s, amount, dtype, sid):
        self.hit_fees = set()
        el = sid if sid in ELEMENTS else ""
        tc = self.mod(s, "tick_to_heal", {"element": el, "status": sid, "dtype": dtype}) if s.b.effects else 0.0
        if tc > 0:
            # Turn a tick into healing (Effects rule 6, 2026-11-26; Bitter Medicine): the tick deals nothing and heals
            # its taker for that share of it, as healing (Withering and the healing rules apply)
            self.heal(s, amount * min(1.0, tc / 100), source="tick")
            dealt = 0.0
        else:
            dealt = self.defend(src, s, amount, dtype, None, {"dtype": dtype}, is_tick=True)
        src.dealt += dealt
        if self.plog is not None:
            self.plog.append(["tick", self.t, src.label, sid, amount, dealt, s.hp, s.qi])
        self.fire_event(src, "tick_dealt", {"amount": dealt, "status": sid, "element": sid if sid in ELEMENTS else "", "dtype": dtype})
        self.check_cross(s, {"status": sid, "kind": "tick"})
        return dealt

    def soul_hit(self, att, dfn, a):
        if dfn.window is not None:   # an extended last act: the side cannot be struck (Effects rule 11)
            return 0.0
        ds_att = att.b.divine_sense * (1 - att.ts_spent)
        ds_def = dfn.b.divine_sense * (1 - dfn.ts_spent)
        sr = dfn.b.soul_res + self.mod(dfn, "soul_res") + dfn.st("slackened_soul") * STATUS["slackened_soul"]["soul_res"] \
            + self.mod(att, "foe_soul_res")   # Lamp-Lit Reading
        rho = ds_att / (ds_def * (1 + sr / 100)) if sr >= 0 else ds_att * (1 + abs(sr) / 100) / ds_def
        if rho < K["rho_min"]:
            return 0.0
        pct = min(a.soul_pct * (1 + (att.b.x_soul + self.mod(att, "x_soul", art_ctx(a))) / 100) * rho ** K["soul_beta"] * supp(att, dfn, self.mod(att, "pierce") / 100), K["soul_cap"])
        lh, lq = pct * dfn.hp_max, pct * dfn.qi_max()
        dfn.hp -= lh
        dfn.qi = max(0.0, dfn.qi - lq)
        att.dealt += lh
        att.direct_dmg += lh
        if self.plog is not None:
            self.plog.append(["soul", self.t, att.label, a.name, lh, lq, dfn.hp, dfn.qi])
        self.fire_event(att, "soul_hit", {"amount": lh, "qi": lq, "tags": a.tags, "element": a.element, "art_id": a.name,
                                          "kind": "art", "dtype": "soul"})
        return lh

    def heal(self, s, amount, source=None, ignore_taken=False):
        if s.window is not None:     # an extended last act: the side cannot be healed (Effects rule 11)
            return
        amount *= 1 + s.b.healing + self.mod(s, "healing") / 100
        # the receiver's healing taken (Combat Defence & Healing E; healing_taken_pct), floored at -50 % with curses;
        # ignore_taken: a heal its own closing exempts (Still Water)
        if not ignore_taken:
            amount *= max(1 - K["curse_heal_taken_max"], 1 + self.mod(s, "heal_taken") / 100)
        if s.st("withering"):
            amount *= 1 + STATUS["withering"]["heal_taken"]
            if s.statuses["withering"].get("crossing"):
                s.hp -= amount   # Crossing the Line: the heal lands as damage, straight to health [CD&H 19]
                s.statuses["withering"]["src"].dealt += amount
                return
        top = s.hp_max
        cap = self.mod(s, "heal_cap")
        if cap > 0:                          # Whetstone Vow's closing: never heal above that share of maximum
            top = min(top, cap * s.hp_max)
        got = min(amount, top - s.hp)
        if got > 0:
            s.hp += got
            s.healed += got
            ev = dict(s.cur_ev or {}, amount=got, share=got / s.hp_max, overflow=max(0.0, amount - got))
            if source:
                ev["source"] = source
            self.fire_event(s, "heal_restored", ev)

    # ---------------------------------------------------------- stacks and statuses
    def add_stacks(self, src, target, el, n, dur, buff, mark=None):
        if not n:
            return
        # stack_grant: each grant of the element's stacks gives that many more (Effects rule 9a; rare, flat)
        n += int(self.mod(src, "stack_grant", {"element": el, "kind": "buff" if buff else "debuff"}))
        if dur is not None and src.b.stack_dur:
            dur = dur * (1 + stack_pct(src.b.stack_dur, el, "buff" if buff else "debuff") / 100)
        until = None if dur is None else self.t + ms(max(K["min_batch"], dur))
        if buff:
            target.buffs.append([el, n, until, src, None if until is None else until - self.t])
            if self.plog is not None:
                self.plog.append(["stacks", self.t, src.label, target.label, el, n, -1 if until is None else until, 1])
            self.fire_event(target, "buff_gained", {"element": el, "stacks": n})
        else:
            target.debuffs.append([el, n, until, src, None if until is None else until - self.t] + ([mark] if mark else []))
            if self.plog is not None:
                self.plog.append(["stacks", self.t, src.label, target.label, el, n, -1 if until is None else until, 0])
            self.fire_event(src, "status_applied", {"element": el, "stacks": n})

    def apply_status(self, src, target, spec):
        sid = spec["id"]
        if sid not in STATUS and sid != "internal_injury":
            raise EngineError("unknown status %r" % sid)
        if sid == "internal_injury":
            st = target.statuses.setdefault(sid, {"stacks": 1, "until": None, "src": src, "stored": 0.0})
            st["every"] = spec.get("every", K["injury_every"])
            return
        d = STATUS[sid]
        if self.mod(target, "status_immune", {"status": sid}) > 0:
            return      # Immovable Mountain: Slowed Time never lands
        if self.t < target.lockouts.get(sid, -1):
            return
        if d.get("stacking") == "none" and target.st(sid) > 0:
            return      # stacking None: a recast while it runs does nothing (Effects Edge Cases; 2026-11-14)
        is_curse = d["kind"] == "curse"
        sctx = {"status": sid, "kind": d["kind"], "tags": (d["kind"], sid)}
        # Combat Formulas F: p = 0 at chance 0; 1 at chance 1 with no status resistance; otherwise
        # clamp(chance x (1 - resist), 0.05, 0.95). Resistance counts against guaranteed statuses too.
        chance = spec.get("chance", 1.0)
        resist = self.mod(target, "status_resist", sctx) / 100
        if chance <= 0:
            return
        if not (chance >= 1 and resist <= 0):
            if self.rng.random() >= min(K["status_chance_max"], max(K["status_chance_min"], chance * (1 - resist))):
                return
        if is_curse and sid not in target.statuses:
            live = [k for k, v in target.statuses.items() if STATUS.get(k, {}).get("kind") == "curse"]
            if len(live) >= K["curse_slots"]:
                return
        dur = spec.get("dur", d["dur"])
        if dur is not None:
            # status_duration_pct, outgoing, may be scoped to curses (modifiers.md); curses then clamp (Effects R22)
            dur = dur * (1 + self.mod(src, "status_dur", sctx) / 100)
        if dur is not None and is_curse:
            dur = max(1, min(K["curse_duration_max"], dur))
        if dur is not None and d.get("falloff"):   # Charmed: the delay falloff (R1), counted with timer delays
            target.delays = [x for x in target.delays if self.t - x < ms(K["delay_window"])]
            dur = dur * K["delay_falloff"] ** len(target.delays)
            target.delays.append(self.t)
        if dur is not None and d.get("timer_resisted"):   # Charmed, Sleep: timer resistance shortens it, at least 1 s
            dur = max(1, dur * (1 - (target.b.timer_resist + self.mod(target, "timer_resist")) / 100))
        st = target.statuses.get(sid)
        n = spec.get("stacks", 1)
        cap = spec.get("cap", d.get("cap"))
        if st is None:
            st = {"stacks": 0, "until": None, "src": src}
            target.statuses[sid] = st
        st["src"] = src
        if d.get("stack_timers"):   # Drunk: each landing runs its own time; a new stack refreshes none of the others
            each = st.setdefault("each", [])
            each.append([n, None if dur is None else self.t + ms(dur)])
            st["stacks"] = sum(b[0] for b in each)
            ends = [b[1] for b in each]
            st["until"] = None if None in ends else max(ends)
        else:
            st["stacks"] = st["stacks"] + n if cap is None else min(cap, st["stacks"] + n)
            if d.get("clock_stop") and dur is not None:   # Sleep: the target's clock stops for its time (rule 6)
                st["clock"] = self.stop_clock(target, ms(dur))
            st["until"] = None if dur is None else self.t + ms(dur)
        for k in ("layer", "tag", "crossing", "no_lockout"):
            if k in spec:
                st[k] = spec[k]
        if self.plog is not None:
            self.plog.append(["status", self.t, src.label, target.label, sid, st["stacks"],
                              -1 if st["until"] is None else st["until"]])
        self.fire_event(src, "status_applied", {"status": sid, "stacks": n})

    def held_fast(self, x):
        """A debuff batch a talisman art laid, while its caster holds talisman_fast: no cleanse removes it (Effects
        rule 16, 2026-11-26; Rainfast Ink)."""
        return len(x) > 5 and x[5] == "talisman" and x[3] is not None and self.mod(x[3], "talisman_fast") > 0

    def cleanse(self, s, n, el=None):
        removed = 0
        s.debuffs.sort(key=lambda x: x[2] if x[2] is not None else 1 << 40)
        i = 0
        while n > 0 and i < len(s.debuffs):
            x = s.debuffs[i]
            if el and x[0] != el:
                i += 1
                continue
            if self.held_fast(x):
                i += 1
                continue
            guard = x[3].protect.get(x[0]) if x[3] is not None else None
            if guard:
                ff = guard.get("for_first")
                started = (x[2] - x[4]) if (x[2] is not None and len(x) > 4 and x[4] is not None) else None
                if ff is None or started is None or self.t - started < ms(ff):
                    if guard.get("swap_buff"):   # Embers Never Die: the source loses its own buff stacks instead
                        own = x[3]
                        lose = min(n, own.count(own.buffs, x[0]))
                        for y in sorted([y for y in own.buffs if y[0] == x[0]], key=lambda y: y[2] if y[2] is not None else 1 << 40):
                            k = min(lose, y[1])
                            y[1] -= k
                            lose -= k
                        own.buffs = [y for y in own.buffs if y[1] > 0]
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
        if self.plog is not None and removed:
            self.plog.append(["cleanse", self.t, s.label, removed])
        if removed:
            self.fire_event(s.foe, "cleansed", {"amount": removed})
        return removed

    # ---------------------------------------------------------- Effects
    def fire_event(self, s, name, ev):
        if name in ("step_unlocked", "empowered"):
            key = (name, ev.get("art_id", ""))
            s.engine_counts[key] = s.engine_counts.get(key, 0) + 1
        for e in s.b.effects:
            if name == "down" and any("refuse_down" in a or "last_act" in a or "last_act_window" in a for a in e.get("do", [])):
                continue    # refusals are Down step 1 and last acts run in the step itself (defeat_check)
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
            n = self.scale(s, e, ev)
            spp = e.get("limit", {}).get("scale_per_pulse")
            if spp is not None:              # the summed scale a pulse may give (Ever-Burning Furnace: 10 stacks)
                st_ = s.eff_state[e["id"]]
                n = min(n, spp - st_.get("pulse_n", 0.0))
                if n <= 0:
                    continue
                st_["pulse_n"] = st_.get("pulse_n", 0.0) + n
            self.mark(s, e)
            if self.plog is not None:
                self.plog.append(["effect", self.t, s.label, e["id"]])
            self.depth += 1
            try:
                self.do(s, e, e.get("do", []), n, ev)
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
        if "per_firing" in lim and st.get("firing", 0) >= lim["per_firing"]:
            return False
        if self.t < st["next"]:
            return False
        return True

    def mark(self, s, e):
        st = s.eff_state[e["id"]]
        st["fight"] += 1
        st["pulse"] += 1
        st["firing"] = st.get("firing", 0) + 1
        if "cooldown" in e.get("limit", {}):
            st["next"] = self.t + ms(e["limit"]["cooldown"])

    def bank(self, s, e, ev):
        if not self.allowed(s, e) or not self.holds(s, e.get("if"), ev):
            return
        self.mark(s, e)
        cap = e["held"].get("cap")
        n = self.scale(s, e, ev)
        if self.plog is not None:
            self.plog.append(["bank", self.t, s.label, e["id"], n])
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
                s.qi = min(s.qi_use(), s.qi + amt)
            elif verb == "heal":
                amt = arg.get("share", 0) * (ev.get("amount", 0.0) if arg.get("of") == "amount" else s.hp_max) * n
                if arg.get("body_shield"):
                    s.body_bar += amt * self.shield_hold(s)
                else:
                    self.heal(s, amt, ignore_taken=bool(arg.get("ignore_taken")))
            elif verb == "free_hit":
                if s.trig_count >= K["trig_cap"]:
                    s.clipped["trig_cap"] = s.clipped.get("trig_cap", 0) + 1
                    continue
                budget = K["trig_budget"] * max(s.direct_dmg, K["trig_floor_u"] * s.U_att) - s.trig_dmg
                if budget <= 0:
                    s.clipped["trig_budget"] = s.clipped.get("trig_budget", 0) + 1
                    continue
                s.trig_count += 1
                before = o.hp
                dt = arg.get("dtype", "phys")
                if dt == "same":                  # Echo: the same type as the hit that triggered it
                    dt = ev.get("dtype", "phys") if ev.get("dtype") in DTYPES else "phys"
                self.hit(s, o, arg["c"] * n, dt, None, kind="trigger", trig=True)
                over = (before - o.hp) - budget
                if over > 0 and not arg.get("outside_budget"):
                    o.hp += over
                    s.dealt -= over
                    s.trig_dmg -= over
                    s.clipped["trig_budget"] = s.clipped.get("trig_budget", 0) + 1
            elif verb == "burn_pill":
                # Burn the prepared pill (Effects rule 6, 2026-11-26; Pill Smoke; smoke only for now): its smoke lays
                # stacks_per_grade x grade debuff stacks of its element on the foe (Water smokes as Ice, no element as
                # Wood), whether or not it fails; its fail chance is drawn when it is between 0 and 1.
                pill = s.b.pill
                if not pill or s.pill_used:
                    continue
                s.pill_used = True
                el = {"water": "ice", "": "wood"}.get(pill.get("element", ""), pill.get("element", ""))
                grade = int(pill.get("grade", 1))
                self.add_stacks(s, o, el, arg.get("stacks_per_grade", 4) * grade, arg.get("for", 6.0), buff=False)
                fail = float(pill.get("fail", 0.0))
                failed = fail >= 1 or (fail > 0 and self.rng.random() < fail)
                self.fire_event(s, "pill_burned", {"element": el, "grade": float(grade), "failed": 1.0 if failed else 0.0})
            elif verb == "stacks":
                tgt = o if arg.get("side", "foe") == "foe" else s
                self.add_stacks(s, tgt, arg["el"], arg["n"] * n, arg.get("for"), buff=(tgt is s), mark=arg.get("mark"))
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
                new_state = None if (arg.get("toggle") and s.state == arg.get("set")) else arg.get("set")
                if new_state != s.state:
                    s.state_since = self.t
                s.state = new_state
            elif verb == "summon":
                cd = ms(max(K["cooldown_min"], arg.get("cd", K["basic_cooldown"])))
                s.summons.append([arg.get("c", K["summon_c"]) * n, arg.get("dtype", "phys"), cd, self.t + cd,
                                  self.t + ms(arg.get("for", K["summon_for"]))])
            elif verb == "fire_art":
                if self.depth > K["trig_depth"]:
                    continue
                which = arg.get("which", "last")
                if which == "longest":
                    hitters = [i for i, x in enumerate(s.b.arts) if x.c and not x.soul_pct]
                    idx = min(hitters, key=lambda i: (-s.b.arts[i].cd, i)) if hitters else None
                else:
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
                if tgt is o and by > 0 and self.mod(o, "delay_immune") > 0:
                    continue   # Immovable Mountain: timer delays never land
                if tgt is o:   # a delay: falloff within the window, timer resistance [R1]
                    o.delays = [x for x in o.delays if self.t - x < ms(K["delay_window"])]
                    by = by * K["delay_falloff"] ** len(o.delays) * (1 - (o.b.timer_resist + self.mod(o, "timer_resist")) / 100)
                    o.delays.append(self.t)
                which = arg.get("which", "all")
                idx = [i for i in range(len(tgt.ready)) if not (tgt is s and ev.get("slot") == i and which == "others")]
                if which == "longest" and idx:
                    idx = [max(idx, key=lambda i: tgt.ready[i])]
                elif which == "next" and idx:     # least time left, the earlier slot on a tie (Effects rule 6)
                    idx = [min(idx, key=lambda i: (tgt.ready[i], i))]
                for i in idx:
                    last_ok = self.t + ms(K["cooldown_min"]) if tgt is s else 0
                    tgt.ready[i] = max(last_ok if by < 0 else 0, tgt.ready[i] + ms(by))
            elif verb == "refund":
                s.qi = min(s.qi_use(), s.qi + min(1.0, arg.get("share", 1.0) * n) * ev.get("cost", 0.0))
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
                pile = arg.get("el")
                if not pile:
                    # the largest pile; a tie goes to the pile listed first (2026-11-14: was set order, unstable)
                    pile, best = "", -1.0
                    for x in o.buffs:
                        cnt = o.count(o.buffs, x[0])
                        if cnt > best:
                            best, pile = cnt, x[0]
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
                        s.buffs.append([pile, k, x[2], s, None if x[2] is None else x[2] - self.t])
                    if x[1] <= 0:
                        o.buffs.remove(x)
                if taken and arg.get("as_status"):   # Unmaking Glass: each stripped stack counts as a status landed
                    self.fire_event(s, "status_applied", {"element": pile, "stacks": taken, "strip": True})
            elif verb == "refresh":
                # refresh (or hold) the side's own batches of an element on a target [Fan the Pyre, Verdict Stands]:
                # {"el", "side": foe|own, "kind": debuff|buff, "hold": false}; a batch restarts its own length, or
                # never ends while held
                tgt = o if arg.get("side", "foe") == "foe" else s
                lst = tgt.debuffs if arg.get("kind", "debuff") == "debuff" else tgt.buffs
                for x in lst:
                    if x[3] is not s or (arg.get("el") and x[0] != arg["el"]):
                        continue
                    if arg.get("hold"):
                        x[2] = None
                    elif arg.get("at_least") is not None:   # keep it at least this long from now (Fire Feeds Fire)
                        if x[2] is not None:
                            x[2] = max(x[2], self.t + ms(arg["at_least"]))
                    elif len(x) > 4 and x[4] is not None and x[2] is not None:
                        x[2] = self.t + x[4]
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
            elif verb == "burn_qi":
                # Spillover: burn the foe's linh luc by a share of the event's amount, no second resistance step
                amt = arg.get("share", 0) * (ev.get("amount", 0.0) if arg.get("of", "amount") == "amount" else o.qi_max()) * n
                burned = min(o.qi, max(0.0, amt))
                o.qi = max(0.0, o.qi - amt)
                if arg.get("to_self") and burned > 0:   # a drain: that share moves to you (2026-11-26, qi_drained)
                    got = burned * arg["to_self"]
                    s.qi = min(s.qi_use(), s.qi + got)
                    self.fire_event(s, "qi_drained", {"amount": got})
            elif verb == "emit":
                # raise another event as if it happened (Phantom Dodge: a basic hit counts as an evade)
                if self.depth <= K["trig_depth"]:
                    self.fire_event(s, arg["event"], dict(ev or {}, emitted=True))
            elif verb == "protect":
                # own debuff batches of an element that a cleanse skips: for the whole batch, or its first N s
                # (Embers Never Die, Moss Ledger); swap_buff: the cleanse takes the same number of own buff stacks
                s.protect[arg["el"]] = {"for_first": arg.get("for_first"), "swap_buff": bool(arg.get("swap_buff"))}
            elif verb in ("refuse_down", "last_act", "last_act_window"):
                pass   # read by the Down step
            elif verb == "shield":
                if arg.get("refill") is not None:   # refill toward the starting bar, never past it (Earthen Armour)
                    cap = s.b.body_shield * s.hp_max * self.shield_hold(s)
                    if s.body_bar < cap:
                        s.body_bar = min(cap, s.body_bar + arg["refill"] * cap * n)
                else:
                    s.body_bar += arg.get("body", 0.0) * s.hp_max * n * self.shield_hold(s)
            elif verb == "return_damage":
                # a share of the event's amount strikes the foe through its defence (Thorns: a share of the blocked)
                amt = arg.get("share", 0.0) * ev.get("amount", 0.0) * n
                if amt > 0:
                    dt = arg.get("dtype", "phys")
                    got = self.defend(s, o, amt, dt, None, {"dtype": dt, "kind": "trigger"}, is_tick=False)
                    s.dealt += got
                    if self.plog is not None:
                        self.plog.append(["return", self.t, s.label, amt, got, o.hp, o.qi])
            elif verb == "bank":
                pass
            elif verb == "self_hit":
                self.hit(o, s, arg.get("c", 0.0) * n, arg.get("dtype", "phys"), None, kind="trigger", trig=True)
            elif verb == "stop_clock":   # Effects rule 6 (2026-11-26): the side's clock does not run for N s
                tgt = s if arg.get("side", "foe") == "own" else o
                sec = arg.get("seconds", 0.0) * n
                if tgt is o:
                    sec *= max(0.0, 1 - (o.b.timer_resist + self.mod(o, "timer_resist")) / 100)
                self.stop_clock(tgt, ms(sec))
            elif verb == "store_damage":
                st = o.statuses.get("internal_injury")
                if st is None:
                    self.apply_status(s, o, {"id": "internal_injury", "every": arg.get("every", K["injury_every"])})
                    st = o.statuses["internal_injury"]
                st["stored"] = st.get("stored", 0.0) + arg.get("share", 0.0) * ev.get("amount", 0.0) * n
            else:
                raise EngineError("action %r is not in the engine" % verb)

    def stop_clock(self, s, d):
        """Stop a side's clock for d ms (Effects rule 6, 2026-11-26): its art timers, basic attack, companions, soul
        attack, summons and the stack and status timers on it move d later, so nothing of it runs in the gap.
        Returns what it moved, as (holder, key, new value), so a Sleep cut short can give the rest back.
        An art already ready waits too (slice 2a fix: it used to move only arts still counting down)."""
        rec = []
        if d <= 0:
            return rec

        def move(holder, key, base):
            holder[key] = base + d
            rec.append((holder, key, holder[key]))

        for i in range(len(s.ready)):
            move(s.ready, i, max(s.ready[i], self.t))
        for i in range(len(s.comp_ready)):
            move(s.comp_ready, i, max(s.comp_ready[i], self.t))
        s.basic_ready = max(s.basic_ready, self.t) + d
        rec.append((s, "basic_ready", s.basic_ready))
        s.soul_ready = max(s.soul_ready, self.t) + d
        rec.append((s, "soul_ready", s.soul_ready))
        for x in s.summons:
            move(x, 3, x[3])
            move(x, 4, x[4])
        for lst in (s.buffs, s.debuffs):
            for x in lst:
                if x[2] is not None:   # None: a batch for the whole fight
                    move(x, 2, x[2])
        for stt in s.statuses.values():
            if stt.get("until") is not None:
                move(stt, "until", stt["until"])
            for b in stt.get("each", []):   # Drunk's stacks, each on its own time
                if b[1] is not None:
                    move(b, 1, b[1])
        for cid in s.counter_times:   # self-counter charges on their own timers (Effects rule 8)
            s.counter_times[cid] = [u + d for u in s.counter_times[cid]]
        return rec

    def restart_clock(self, rec, left):
        """Give back `left` ms of a clock stop that ended early: every timer the stop moved comes `left` sooner, unless
        something set it since (then it keeps its new time). Never earlier than now."""
        for holder, key, val in rec:
            if isinstance(holder, Side):
                if getattr(holder, key) == val:
                    setattr(holder, key, max(self.t, val - left))
            elif holder[key] == val:
                holder[key] = max(self.t, val - left)

    # ---------------------------------------------------------- the Down step [Effects 11]
    def defeat_check(self):
        for s in (self.A, self.B):
            if s.hp > 0:
                for e in s.foe.b.effects:   # cull: the foe's cull Effect [R15c]
                    for a in e.get("do", []):
                        if "cull" in a and s.hp <= a["cull"] * s.hp_max and self.holds(s.foe, e.get("if")):
                            s.hp = 0.0
                            if self.plog is not None:
                                self.plog.append(["cull", self.t, s.label])
        downs = [s for s in (self.A, self.B) if s.hp <= 0 and s.window is None]   # a window side is past its Down step
        for s in downs:
            # Down step 1 [Effects 11]: the first usable refusal whose conditions hold (2026-11-14: conditions were
            # not read, so Ash Rebirth refused with no Ash); its other actions run with it (Ash Rebirth's heal), then
            # the "refused" event (Ash Rebirth's spending)
            refuse = [e for e in s.b.effects if e.get("on") == "down" and any("refuse_down" in a for a in e.get("do", []))
                      and self.allowed(s, e) and self.holds(s, e.get("if"), {})]
            if refuse and s.refusals_left > 0:
                e = refuse[0]
                self.mark(s, e)
                s.refusals_left -= 1
                rd = next((a["refuse_down"] for a in e.get("do", []) if "refuse_down" in a), None)
                share = rd.get("hp_share") if isinstance(rd, dict) else None
                s.hp = share * s.hp_max if share else K["refuse_down_health"]   # Nirvana: 30 % of maximum
                if self.plog is not None:
                    self.plog.append(["down", self.t, s.label, "refused"])
                rest = [a for a in e.get("do", []) if "refuse_down" not in a]
                if rest:
                    self.depth += 1
                    try:
                        self.do(s, e, rest, self.scale(s, e, {}), {})
                    finally:
                        self.depth -= 1
                self.fire_event(s, "refused", {})
                continue
            # An extended last act (Effects rule 11, 2026-11-26; The Fifteenth Layer): the side stays in the fight for
            # the window, untargetable and inactive; only its named free hits fire. It replaces the side's other last
            # acts and its Down event, and opens once a fight.
            win = None if s.window_used else next(((e, a["last_act_window"]) for e in s.b.effects
                                                   for a in e.get("do", []) if "last_act_window" in a
                                                   and self.allowed(s, e)), None)
            if win is not None:
                e, w = win
                self.mark(s, e)
                s.window_used = True
                every = ms(w.get("every", 1.0))
                s.window = {"until": self.t + ms(w["seconds"]), "next": self.t + every, "every": every, "spec": w}
                if self.plog is not None:
                    self.plog.append(["down", self.t, s.label, "window"])
                continue
            for e in s.b.effects:
                for a in e.get("do", []):
                    if "last_act" in a and self.allowed(s, e):
                        self.mark(s, e)
                        la = a["last_act"]
                        self.hit(s, s.foe, la.get("c", 0.0), la.get("dtype", "phys"), None, kind="trigger", trig=True)
            # Down step 2's event (2026-11-14: never raised, so Final Clause never fired): the "down" listeners
            # that are neither refusals nor last acts
            self.fire_event(s, "down", {})
            s.down = True
            if self.plog is not None:
                self.plog.append(["down", self.t, s.label, "down"])
        for s in (self.A, self.B):
            if s.window is not None:
                spend = s.window["spec"].get("spend")
                if s.foe.down:   # the foe went Down within the window: a draw (Combat rule 10)
                    s.down = True
                elif self.t >= s.window["until"] or (spend and s.counters.get(spend, 0.0) <= 0):
                    s.down = True
                    if self.plog is not None:
                        self.plog.append(["down", self.t, s.label, "down"])
                continue
            if not s.down and s.hp <= 0:
                s.down = True


def art_ctx(a):
    """The context an art's own reads use (speed, cost, soul multiplier), the same keys as a hit's context, so a
    scoped modifier (Fire arts, Sword arts, curse arts) matches the arts it names and no other."""
    return {"dtype": a.dtype, "element": a.element, "tags": a.tags, "kind": "art", "art_id": a.name}


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
        elif k == "not_tags":                # none of these tags (Thousand Talismans: arts that are not talismans)
            if set(v) & set(ctx.get("tags", ())):
                return False
        elif k == "is_crit":                 # the hit is (or is not) a crit (Heaven's Eye)
            if bool(ctx.get("crit", False)) != bool(v):
                return False
        elif k == "source":                  # a heal's source (Sun and Rain: regeneration)
            if ctx.get("source") != v:
                return False
        elif k == "dtype":
            got = ctx.get("dtype")
            if got != v and not (got == "elem" and ELEM_TYPE.get(ctx.get("element", "")) == v):
                return False
        elif k in ("element", "kind", "status", "art_id"):
            if ctx.get(k) != v:
                return False
    return True


OVERRIDE = {"c_art": "c", "statuses": "statuses", "buff": "buff", "debuff": "debuff", "split": "split",
            "convert": "convert", "bypass": "bypass", "c_heal": "heal", "qi_restore": "qi_restore", "cleanse": "cleanse",
            "soul_part": "soul_part", "dtype": "dtype", "kind": "dtype", "tags": "tags"}


def override(a, spec):
    """A copy of art `a` with a step's or an empower's fields applied; `c_mult` multiplies the coefficient."""
    import copy
    b = copy.copy(a)
    for k, v in spec.items():
        if k in OVERRIDE:
            setattr(b, OVERRIDE[k], tuple(v) if k in ("buff", "debuff", "tags") else v)
    if "c_mult" in spec:
        b.c = b.c * spec["c_mult"]
    if "add_statuses" in spec:
        b.statuses = list(b.statuses) + list(spec["add_statuses"])
    return b


def _check_filter(b, e, filt, where):
    """A filter value the engine never produces would silently never match (2026-11-13: "physical" for "phys")."""
    if not isinstance(filt, dict):
        return
    if "dtype" in filt and filt["dtype"] not in DTYPES:
        raise EngineError("%s: Effect %s: %s dtype %r is not one of %s" % (b.name, e["id"], where, filt["dtype"], sorted(DTYPES)))
    if "element" in filt and filt["element"] not in ELEMENTS:
        raise EngineError("%s: Effect %s: %s element %r is not one of %s" % (b.name, e["id"], where, filt["element"], sorted(ELEMENTS)))


def _check_read(b, e, key):
    """A readable naming an element or status the engine does not have reads 0 for ever (2026-11-13: buff.moc,
    status.burn). Element piles are the engine's English names; statuses are the Status Catalogue's ids."""
    side, _, k = str(key).partition(".")
    for pre, ok in (("buff.", ELEMENTS - {""}), ("debuff.", ELEMENTS - {""}), ("status.", set(STATUS) | {"internal_injury"})):
        if k.startswith(pre) and k[len(pre):] not in ok:
            raise EngineError("%s: Effect %s: read %r: %r is not one of %s" % (b.name, e["id"], key, k[len(pre):], sorted(ok)))


def _check_conds(b, e, conds):
    for c in conds or []:
        if "any" in c:
            _check_conds(b, e, c["any"])
        elif "read" in c:
            _check_read(b, e, c["read"])


def validate(b):
    for e in b.effects:
        if "id" not in e:
            raise EngineError("%s: an Effect has no id" % b.name)
        _check_filter(b, e, e.get("filter"), "filter")
        _check_conds(b, e, e.get("if"))
        if e.get("scale"):
            _check_read(b, e, e["scale"].get("read", ""))
        if e.get("on") in EVENT_ALIAS:
            e["on"] = EVENT_ALIAS[e["on"]]
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
                _check_filter(b, e, arg, "mod")
                if abs(arg.get("cost_red", 0)) > 1:   # a share (0.10 = 10 %), not points: -10 would mean 11x costs
                    raise EngineError("%s: Effect %s: cost_red %r is a share of the cost (0.1 = 10 %%), not points"
                                      % (b.name, e["id"], arg["cost_red"]))
                bad = [k for k in arg if k not in MOD_KEYS and k not in ("for", "dtype", "element", "tags", "kind", "stack",
                                                                         "status", "not_tags", "is_crit")]
                if bad:
                    raise EngineError("%s: Effect %s: mod keys %s are not in the engine" % (b.name, e["id"], bad))
            if verb == "stacks" and isinstance(arg, dict) and arg.get("el", "") not in ELEMENTS:
                # 2026-11-14: an item art wrote the Hán-Việt "tho" for Earth; the Godot loader refused it, the sim ran it
                raise EngineError("%s: Effect %s: stacks element %r is not an engine element" % (b.name, e["id"], arg.get("el")))
    for st in b.states:
        if abs(st.get("mods", {}).get("cost_red", 0)) > 1:
            raise EngineError("%s: state %s: cost_red %r is a share of the cost (0.1 = 10 %%), not points"
                              % (b.name, st.get("id"), st["mods"]["cost_red"]))
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


def fight(b1, b2, seed=1, trace=False, order="random", parity=False):
    return Fight(b1, b2, seed, trace, order, parity).run()


if __name__ == "__main__":
    import regress
    regress.main()
