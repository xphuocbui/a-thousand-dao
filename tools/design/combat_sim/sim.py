"""Fight simulator for the Combat economy revision (#44).

A small, readable model of the fight timeline, used to tune the #44 numbers before they go into the GDDs
(design/research/economy-revision-44-decisions.md, item E1). It is not the game's combat code.

What it models (Qi Refining anchors from combat.md Formulas A-K and combat-defence.md A-E):
- pools: health and linh lu.c (qi) from fight units; regeneration with diminishing returns (B2)
- arts on cooldowns with cost shares, the basic attack, crits, evade and accuracy, realm suppression
- one drain-paid resistance ward plus flat block (the Common Ward of the typical anchor)
- healing with no decay and no cap (C1, C3), health regeneration
- fatigue from 60 s (A3)
- element stacks (D1-D8): batches with their own timers, cleanse removes oldest first
- linh lu.c gained on hit and leech (B3), part of art costs paid with health (B4)

Run: python -I tools/design/combat_sim/sim.py            (the scenario table)
     python -I tools/design/combat_sim/sim.py --trace A B (one fight, second by second)
"""
import math
import random
import sys
from dataclasses import dataclass, field

# ---------------------------------------------------------------- knobs (the #44 numbers under test)
K = dict(
    dt=0.01,               # simulation step, s
    time_limit=120.0,      # A1
    fatigue_start=60.0,    # A3
    fatigue_step=0.01,     # share of max health at the first fatigue pulse, +this each further pulse
    health_mult=4.0,       # A4: x4 (user, 2026-11-09), with much stronger wards
    ward_mult=1.25,        # A4: multiplies every ward's resistance payload (ward strength)
    resist_cap=0.90,       # resistance cap (today 0.75, max 0.90 with raises)
    regen_base=0.035,      # B1: linh lu.c regeneration per pulse, share of qi_max (today 0.02)
    regen_k=0.08,          # B2: diminishing returns, bonus_eff = bonus / (1 + bonus / k)
    cost_scale=0.5,        # B1: multiplies every art's cost_share (today 1.0)
    drain_scale=0.2,       # the ward's drain bill per prevented point (T_ref re-price, A5; today 1.0)
    crit_cap=1.0,          # crit chance cap
    evade_cap=0.4,
)

U = [6.31, 15.85, 39.81, 100.0, 251.19]
SUPP = [0.0, 0.10, 0.25, 0.50, 0.75]
BLOCK_UNIT = [0.0631, 0.2031, 0.6672, 2.254, 6.883]

# element stack table (D2), per stack
BUFF = {  # equal-value numbers (2026-11-10, equalfit.py)
    "fire": {"dmg": 0.012},
    "water": {"qi_max": 0.005, "regen": 0.00025},
    "earth": {"phys_dampen": 0.011},  # Physical damage taken 1.1 % dampened per stack (2026-11-10)
    "metal": {"dmg_phys": 0.012},
    "wood": {"hregen": 0.001},
    "thunder": {"acc": 0.007, "crit": 0.0035},
    "wind": {"speed": 0.075},
}
DEBUFF = {
    "fire": {"burn": 0.019},
    "earth": {"acc_down": 0.012},
    "metal": {"phys_taken": 0.018},
    "wood": {"poison": 0.019},
    "ice": {"cost_up": 0.039},
    "thunder": {"crit_taken": 0.012, "critdmg_taken": 0.05},
    "wind": {"evade_down": 0.012},
}


@dataclass
class Art:
    name: str
    c: float                 # c_art (damage coefficient); 0 for a pure utility art
    cost: float              # cost_share of qi_max
    cd: float                # authored cooldown, s
    element: str = ""        # element tag (D6)
    dtype: str = "phys"      # damage type: phys or elem
    buff: tuple = ()         # (stacks, duration) of own element buff granted on firing
    debuff: tuple = ()       # (stacks, duration) of own element debuff applied on hit
    heal: float = 0.0        # c_heal
    qi_restore: float = 0.0  # share of qi_max a heal art restores (#44 part 2, P2-2)
    cleanse: int = 0         # debuff stacks removed from self on firing


@dataclass
class Build:
    name: str
    realm: int = 0
    M: float = 3.273
    crit: float = 0.15
    crit_mult: float = 1.7
    evade: float = 0.0
    acc: float = 0.0
    n_body: float = 1.0883
    n_qi: float = 1.053
    ward_r: float = 0.654     # Common Ward, all resistance after ws
    drain: float = 0.959      # bill per prevented point
    block: float = 15.0       # block rating
    regen_bonus: float = 0.0  # linh lu.c regen pp (as share)
    hregen: float = 0.0       # health regen share per pulse
    cost_red: float = 0.0
    gain_on_hit: float = 0.0  # share of qi_max gained per hit landed (B3)
    leech_qi: float = 0.0     # share of damage dealt returned as linh lu.c (B3)
    leech_hp: float = 0.0
    hp_pay: float = 0.0       # share of art costs paid with health (B4)
    healing: float = 0.0      # healing_pct / 100
    cleanse_pulse: int = 0    # cleansing ward: debuff stacks removed each pulse (D5)
    cleanse_cost: float = 0.0 # its fee per stack removed, share of qi_max
    cleanse_share: float = 0.0  # cleansing ward: share of every debuff batch removed each pulse (P3-1)
    # linh luc keystones (builds by root, missing-pieces.md); all 0 = off
    k_crit_phys: float = 0.0  # Edge Returns the Breath: share of qi_max per Physical crit
    k_crit_any: float = 0.0   # Storm Battery: share of qi_max per crit
    k_noncrit_pen: float = 0.0  # Storm Battery's closing cost: non-crit hits deal this much less
    k_burn: float = 0.0       # Embers Feed the Hearth: share of each Burn tick's damage returned as linh luc
    k_fire_pen: float = 0.0   # Embers' closing cost: direct Fire hits deal this much less
    k_poison_leech: float = 0.0  # Root Drinks the Rot: share of damage to a poisoned foe returned as linh luc
    k_prevented: float = 0.0  # The Stone Remembers: share of damage prevented (resistance and block) returned
    k_water_nodr: bool = False  # The Spring Never Fails: Water-stack regeneration skips diminishing returns
    k_art: float = 0.0        # Breath Between Blows: share of qi_max per art fired
    k_frost: float = 0.0      # Frost Tithe: share of the foe's extra art cost (from your Ice stacks) you gain
    curse_wither: bool = False  # your hits apply Withering (healing taken -50 %) for 4 pulses
    curse_stagnate: bool = False  # your hits apply Stagnation (no regeneration) for 3 pulses
    arts: list = field(default_factory=list)


class Side:
    def __init__(self, b: Build):
        self.b = b
        self.U = U[b.realm]
        self.hp_max = 16 * self.U * b.n_body * K["health_mult"]
        self.qi_base = 26 * self.U * b.n_qi
        self.hp = self.hp_max
        self.qi = self.qi_base
        self.ready = [a.cd for a in b.arts]  # nothing fires at t = 0 (AC-CB-32)
        self.basic_ready = 1.0
        self.buffs = []    # [element, stacks, t_end]
        self.debuffs = []  # [element, stacks, t_end, source Side]
        self.dry_at = None
        self.spent = 0.0
        self.dealt = 0.0
        self.healed = 0.0
        self.fat = 0.0
        self.wither_until = -1.0
        self.stag_until = -1.0
        self.now = 0.0

    # stacks
    def count(self, lst, el):
        return sum(x[1] for x in lst if x[0] == el)

    def bsum(self, key):
        return sum(BUFF.get(x[0], {}).get(key, 0.0) * x[1] for x in self.buffs)

    def dsum(self, key):
        return sum(DEBUFF.get(x[0], {}).get(key, 0.0) * x[1] for x in self.debuffs)

    def qi_max(self):
        return self.qi_base * (1 + self.bsum("qi_max"))

    def regen(self):
        k = K["regen_k"]
        if self.b.k_water_nodr:
            other = self.b.regen_bonus
            return self.qi_max() * (K["regen_base"] + other / (1 + other / k) + self.bsum("regen"))
        bonus = self.b.regen_bonus + self.bsum("regen")
        return self.qi_max() * (K["regen_base"] + bonus / (1 + bonus / k))


def supp(att, dfn):
    g = max(0, dfn.b.realm - att.b.realm)
    return 1 - SUPP[min(g, 4)]


def resist(dfn, dtype):
    r = dfn.b.ward_r * K["ward_mult"] + (dfn.bsum("res_phys") if dtype == "phys" else 0.0)
    return min(r, K["resist_cap"])


def hit(att, dfn, c, dtype, rng, t, log, art=None):
    """One direct hit. Returns damage to health."""
    p_ev = min(K["evade_cap"], max(0.0, dfn.b.evade - dfn.dsum("evade_down")
                                   - (att.b.acc + att.bsum("acc") - att.dsum("acc_down"))))
    if rng.random() < p_ev:
        return 0.0
    crit_ch = min(K["crit_cap"], att.b.crit + att.bsum("crit") + dfn.dsum("crit_taken"))
    is_crit = rng.random() < crit_ch
    crit = (att.b.crit_mult + dfn.dsum("critdmg_taken")) if is_crit else 1.0
    more = 1 + att.bsum("dmg") + (att.bsum("dmg_phys") + dfn.dsum("phys_taken") if dtype == "phys" else 0)
    D = att.U * c * att.b.M * crit * more * supp(att, dfn)
    if dtype == "phys" and dfn.bsum("phys_dampen"):
        D /= 1 + dfn.bsum("phys_dampen")
    if not is_crit and att.b.k_noncrit_pen:
        D *= 1 - att.b.k_noncrit_pen
    if art is not None and art.element == "fire" and att.b.k_fire_pen:
        D *= 1 - att.b.k_fire_pen
    r = resist(dfn, dtype) if dfn.qi > 0 else 0.0
    prevented = D * r
    bill = prevented * dfn.b.drain * K["drain_scale"]
    if bill > dfn.qi and bill > 0:
        frac = dfn.qi / bill
        dfn.qi = 0.0
        prevented *= frac
    else:
        dfn.qi -= bill
    a = D - prevented
    blk = BLOCK_UNIT[dfn.b.realm] * dfn.b.block
    stopped = prevented + min(blk, a)
    a = max(0.0, a - blk)
    dealt = 0.0 if a <= 0 else max(1.0, a)
    if dfn.b.k_prevented:
        dfn.qi = min(dfn.qi_max(), dfn.qi + dfn.b.k_prevented * stopped)
    dfn.hp -= dealt
    att.dealt += dealt
    # sustain on hit
    gain = att.b.gain_on_hit * att.qi_max() + att.b.leech_qi * dealt
    if is_crit:
        gain += (att.b.k_crit_any + (att.b.k_crit_phys if dtype == "phys" else 0.0)) * att.qi_max()
    if att.b.k_poison_leech and dfn.count(dfn.debuffs, "wood") > 0:
        gain += att.b.k_poison_leech * dealt
    att.qi = min(att.qi_max(), att.qi + gain)
    if att.b.leech_hp:
        heal(att, att.b.leech_hp * dealt)
    if att.b.curse_wither:
        dfn.wither_until = max(dfn.wither_until, t + 4)
    if att.b.curse_stagnate:
        dfn.stag_until = max(dfn.stag_until, t + 3)
    if art and art.debuff and dealt >= 0:
        dfn.debuffs.append([art.element, art.debuff[0], t + art.debuff[1], att])
    return dealt


def heal(side, amount):
    amount *= 1 + side.b.healing
    if side.now < side.wither_until:
        amount *= 0.5
    got = min(amount, side.hp_max - side.hp)
    side.hp += got
    side.healed += got


def pulse(s, o, t, log):
    # ticks from debuffs on s (sources' damage increases apply, D1)
    for el, n, t_end, src in s.debuffs:
        d = DEBUFF.get(el, {})
        c = d.get("burn", 0.0) + d.get("poison", 0.0)
        if c:
            more = 1 + src.bsum("dmg")
            tick = src.U * c * n * src.b.M * more * supp(src, s)
            r = resist(s, "elem") if s.qi > 0 else 0.0
            prevented = tick * r
            bill = prevented * s.b.drain * K["drain_scale"]
            if bill > s.qi:
                prevented *= s.qi / bill if bill else 0
                s.qi = 0.0
            else:
                s.qi -= bill
            dmg = max(1.0, tick - prevented)
            s.hp -= dmg
            src.dealt += dmg
            if el == "fire" and src.b.k_burn:
                src.qi = min(src.qi_max(), src.qi + src.b.k_burn * dmg)
    # regeneration (Stagnation blocks both pools)
    s.now = t
    if t >= s.stag_until:
        s.qi = min(s.qi_max(), s.qi + s.regen())
        heal(s, s.hp_max * (s.b.hregen + s.bsum("hregen")))
    # cleansing ward
    n = s.b.cleanse_pulse
    while n > 0 and s.debuffs:
        fee = s.b.cleanse_cost * s.qi_max()
        if s.qi < fee:
            break
        s.qi -= fee
        s.debuffs.sort(key=lambda x: x[2])
        s.debuffs[0][1] -= 1
        if s.debuffs[0][1] <= 0:
            s.debuffs.pop(0)
        n -= 1
    # share-based cleansing ward (P3-1): removes a share of every debuff batch each pulse
    if s.b.cleanse_share:
        for x in s.debuffs:
            x[1] *= (1 - s.b.cleanse_share)
        s.debuffs = [x for x in s.debuffs if x[1] >= 0.05]
    # fatigue
    if t >= K["fatigue_start"] - 1e-9:
        k = round(t - K["fatigue_start"])
        f = s.hp_max * K["fatigue_step"] * (1 + k)
        s.hp -= f
        s.fat += f
    # expire stacks
    s.buffs = [x for x in s.buffs if x[2] > t + 1e-9]
    s.debuffs = [x for x in s.debuffs if x[2] > t + 1e-9]


def act(s, o, t, rng, log):
    s.now = t
    o.now = t
    b = s.b
    speed = 1 + s.bsum("speed")
    for i, a in enumerate(b.arts):
        if t + 1e-9 < s.ready[i]:
            continue
        cost = a.cost * K["cost_scale"] * (1 - b.cost_red) * (1 + s.dsum("cost_up")) * s.qi_base
        qi_part = cost * (1 - b.hp_pay)
        hp_part = cost * b.hp_pay * (s.hp_max / s.qi_base)
        if s.qi + 1e-6 < qi_part or (hp_part and s.hp - hp_part < 1):
            continue
        s.qi -= qi_part
        s.hp -= hp_part
        s.spent += qi_part
        if o.b.k_frost and s.dsum("cost_up") > 0:
            extra = cost - cost / (1 + s.dsum("cost_up"))
            o.qi = min(o.qi_max(), o.qi + o.b.k_frost * extra)
        if b.k_art:
            s.qi = min(s.qi_max(), s.qi + b.k_art * s.qi_max())
        s.ready[i] = t + max(0.5, a.cd / speed)
        if a.buff:
            s.buffs.append([a.element, a.buff[0], t + a.buff[1]])
        if a.cleanse:
            n = a.cleanse
            s.debuffs.sort(key=lambda x: x[2])
            while n > 0 and s.debuffs:
                take = min(n, s.debuffs[0][1])
                s.debuffs[0][1] -= take
                n -= take
                if s.debuffs[0][1] <= 0:
                    s.debuffs.pop(0)
        if a.heal:
            heal(s, s.U * a.heal * K["health_mult"])   # heal base scales with health_units (P2-2)
        if a.qi_restore:
            s.qi = min(s.qi_max(), s.qi + a.qi_restore * s.qi_max())
        if a.c:
            hit(s, o, a.c, a.dtype, rng, t, log, a)
    if t + 1e-9 >= s.basic_ready:
        hit(s, o, 1.0, "phys", rng, t, log)
        s.basic_ready += 1.0


def fight(b1, b2, seed=1, trace=False):
    rng = random.Random(seed)
    order = random.Random(seed + 7919)
    A, B = Side(b1), Side(b2)
    t = 0.0
    dt = K["dt"]
    next_pulse = 1.0
    rows = []
    while t <= K["time_limit"] + 1e-9:
        if t + 1e-9 >= next_pulse:
            p1, p2 = (A, B) if order.random() < 0.5 else (B, A)
            pulse(p1, p2, t, None)
            pulse(p2, p1, t, None)
            if trace:
                rows.append((round(t), A.hp / A.hp_max, A.qi / A.qi_max(), B.hp / B.hp_max, B.qi / B.qi_max(),
                             A.count(A.buffs, "fire"), sum(x[1] for x in B.debuffs)))
            next_pulse += 1.0
        # who acts first in an instant alternates by step, so neither side owns the tie
        first, second = (A, B) if order.random() < 0.5 else (B, A)
        act(first, second, t, rng, None)
        act(second, first, t, rng, None)
        for s in (A, B):
            if s.dry_at is None and s.qi < 0.05 * s.qi_max():
                s.dry_at = t
        if A.hp <= 0 or B.hp <= 0:
            break
        t += dt
    if A.hp <= 0 and B.hp <= 0:
        win = "draw"
    elif B.hp <= 0:
        win = "A"
    elif A.hp <= 0:
        win = "B"
    else:
        win = "time"
    return dict(t=t, win=win, A=A, B=B, rows=rows)


# ---------------------------------------------------------------- builds
def kit(cost=0.10, element="", dtype="phys", buff=(), debuff=()):
    """A typical Qi Refining kit: three arts at 2, 4 and 8 s inside the art lint."""
    def lint(cs, cd):
        return 1.0 * (1 + 12 * cs) + 0.25 * (cd - 1)
    return [
        Art("quick", lint(cost * 0.6, 2) * 0.9, cost * 0.6, 2.0, element, dtype, buff, debuff),
        Art("main", lint(cost, 4) * 0.9, cost, 4.0, element, dtype, buff, debuff),
        Art("big", lint(cost * 1.6, 8) * 0.9, cost * 1.6, 8.0, element, dtype, buff, debuff),
    ]


def builds():
    """Equal-budget builds at Qi Refining. The typical anchor puts 26.5 W into damage (L1 1.265, M 3.273).
    The others move that W elsewhere at today's prices (Modifier System): regeneration 8 W per pp,
    cost reduction 1.2 W per %, healing 1.0 W per %."""
    M0 = 3.273 / 1.265   # M with no damage W
    T = Build("typical", arts=kit())
    S = Build("sustain", arts=kit(), M=M0, regen_bonus=0.015, cost_red=0.12)          # 12 W + 14.4 W
    Bu = Build("burst", arts=kit(cost=0.20))                                            # bigger, costlier arts
    H = Build("healer", arts=[Art("mend", 0, 0.10, 3.0, heal=1.0)] + kit(), M=M0, healing=0.25, hregen=0.0)  # heal in slot 1
    F = Build("fire stacks", arts=kit(element="fire", dtype="elem", buff=(1, 10), debuff=(2, 6)))
    W = Build("water/wood", arts=kit(element="water", buff=(1, 15))[:2] + [Art("sap", 2.0, 0.08, 3, "wood", "elem", (1, 15), (1, 6))])
    I = Build("ice lock", arts=kit(element="ice", dtype="elem", debuff=(3, 8)))
    C = Build("cleanser", arts=kit(), cleanse_pulse=2, cleanse_cost=0.004)
    Up = Build("typical +1 realm", realm=1, arts=kit())
    return dict(T=T, S=S, Bu=Bu, H=H, F=F, W=W, I=I, C=C, Up=Up)


def scenarios():
    b = builds()
    return [
        ("typical mirror", b["T"], b["T"]),
        ("sustain vs typical", b["S"], b["T"]),
        ("burst vs typical", b["Bu"], b["T"]),
        ("healer mirror (stall check)", b["H"], b["H"]),
        ("healer vs typical", b["H"], b["T"]),
        ("fire stacks vs typical", b["F"], b["T"]),
        ("fire stacks vs cleanser", b["F"], b["C"]),
        ("water/wood vs typical", b["W"], b["T"]),
        ("ice lock vs typical", b["I"], b["T"]),
        ("typical vs +1 realm", b["T"], b["Up"]),
    ]


def summary(seeds=20):
    print(f"knobs: " + ", ".join(f"{k}={v}" for k, v in K.items() if k != "dt"))
    print(f"{'scenario':30} {'mean s':>7} {'A wins':>7} {'B wins':>7} {'time':>5}  {'A dry s':>7} {'B dry s':>7}")
    for name, a, b in scenarios():
        res = [fight(a, b, seed=s) for s in range(seeds)]
        ts = [r["t"] for r in res]
        aw = sum(r["win"] == "A" for r in res)
        bw = sum(r["win"] == "B" for r in res)
        tm = sum(r["win"] in ("time", "draw") for r in res)
        def dry(side):
            v = [r[side].dry_at for r in res if r[side].dry_at is not None]
            return f"{sum(v)/len(v):7.1f}" if len(v) > len(res) / 2 else "  never"
        print(f"{name:30} {sum(ts)/len(ts):7.1f} {aw:7d} {bw:7d} {tm:5d}  {dry('A')} {dry('B')}")


if __name__ == "__main__":
    args = sys.argv[1:]
    for a in list(args):
        if "=" in a:
            k, v = a.split("=")
            K[k] = float(v)
            args.remove(a)
    if args and args[0] == "--trace":
        b = builds()
        r = fight(b[args[1]], b[args[2]], trace=True)
        print("t  A.hp A.qi B.hp B.qi A.fire B.debuffs")
        for row in r["rows"]:
            print(f"{row[0]:3d} {row[1]:.2f} {row[2]:.2f} {row[3]:.2f} {row[4]:.2f} {row[5]:4d} {row[6]:4d}")
        print(r["win"], round(r["t"], 2))
    else:
        summary()
