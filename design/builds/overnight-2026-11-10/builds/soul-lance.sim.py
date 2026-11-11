"""Soul Lance (Hon Thuong) paper model, built on the canonical #44 fight simulator.

Why this file exists: fight_calc.py prints CONSTANT_DRIFT on 31 of 60 constants (health units, the retired
ward and guard model, regeneration), and it does not model Slackened Soul, soul shields, Soul Wound or the
three new Effects. The soul constants themselves (soul_beta 2, rho_min 0.25, soul_cap 0.30, soul_lockout 1 s,
cooldown_min 0.5 s) still match combat.md, and every other number here is read from
tools/design/combat_sim/sim.py (the #44 knobs, 2026-11-10) or is a first guess named below.

What it adds to sim.py:
- soul arts (combat.md rule 24, Formulas E2): share = min(soul_pct (1 + x_soul/100) rho^2 supp, soul_cap) of
  maximum health AND maximum linh luc, divided by boss_pool_mult; one soul art per soul_lockout per side
- soul resistance with no floor, Slackened Soul (-15 pp a stack, 2 stacks), soul shields (combat-defence.md
  Formulas B: share s_soul of each loss off a bar sigma x qi_max x (1 + ws/100), health first)
- Soul Wound (effects.md: the enemy's next ready art delayed 0.5 s per soul hit, once per lockout)
- the build's three new Effects: Thousand-Weight Thought (x_soul per 1 % of thần thức bound to artifacts,
  cap +60), Splinters of Thought (soul_cap's clipped share delays the enemy's next ready art), Lamp-Oil Siphon
  (restore 25 % of the linh luc a soul hit takes)
- a heal art (heal lint, refund on any heal), costs on the GDD's halved scale (sim.py's cost_scale is not
  applied to soul-build arts: their cost_share is already authored on the halved scale)

Assumptions (first guesses, because Combat Defence & Healing Open Question 12 has no reference table of
thần thức and soul resistance by realm): foe thần thức in talent-units (x M_ts of its realm):
typical 59.4 (talent 45, stage 1.2, +10 %), strong 142 (talent 70, stage 1.45, +40 %, soul res 15 pp).

Status: NOT YET RUN. The overnight session could not get approval to run a new script, so the sheet's numbers
are the closed-form soul shares (worked by hand) and fight_calc.py's runs. Run this to check them.

Run: python -I soul-lance.sim.py                 the matrix, 20 seeds
     python -I soul-lance.sim.py --without twt    drop Thousand-Weight Thought (also: slack, siphon,
                                                  splinters, wound, heal, fortress)
     python -I soul-lance.sim.py --trace NA strong   one fight, second by second
"""
import math
import os
import random
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
SIM = os.path.normpath(os.path.join(HERE, "..", "..", "..", "..", "tools", "design", "combat_sim"))
sys.path.insert(0, SIM)
import sim  # noqa: E402  (the canonical #44 model)
from sim import Art, Build, Side, K, U, SUPP  # noqa: E402

SOUL_CAP = 0.30
SOUL_LOCKOUT = 1.0
COOLDOWN_MIN = 0.5
RHO_MIN = 0.25
M_TS = [1, 3, 10, 30, 100]          # Character Stats Formulas C, than_thuc_mult
SOUL_LINT_K = 0.0125                 # proposed soul lint (suggestions.md): soul_pct <= k x art lint


def art_lint(cost, cd):
    """combat.md Formulas C, on the halved cost scale (art_coef_per_cost 24)."""
    return 1.0 * (1 + 24 * cost) + 0.25 * (cd - 1)


def soul_lint(cost, cd):
    return min(0.08, SOUL_LINT_K * art_lint(cost, cd))


class SoulArt:
    def __init__(self, name, cost, cd, soul_pct=None, slack=0, heal=0.0):
        self.name, self.cost, self.cd = name, cost, cd
        self.soul_pct = soul_lint(cost, cd) if soul_pct is None else soul_pct
        self.slack = slack            # Slackened Soul stacks applied on landing
        self.heal = heal              # c_heal for a heal art (no soul part)
        self.fired = []


class SoulBuild(Build):
    pass


def make_soul(realm, label, off=()):
    """The Soul Lance at realm 2 (Ket Dan), 3 (Nguyen Anh) or 4 (Hoa Than). Numbers from the sheet."""
    ds = {2: 95 * 1.30 * 1.60, 3: 100 * 1.30 * 2.00, 4: 105 * 1.30 * 2.30}[realm]   # talent units
    bound = {2: 145, 3: 170, 4: 204}[realm]                                         # thần thức units bound
    twt = 0 if "twt" in off else min(60.0, 100.0 * bound / ds)                       # +1 per 1 %, cap 60
    x_other = {2: 25, 3: 97, 4: 129}[realm]
    speed = {2: 60, 3: 100, 4: 100}[realm]
    b = SoulBuild(label, realm=realm, M=1.0, crit=0.0, crit_mult=1.0,
                  n_body=1.10, n_qi=1.20,
                  ward_pts={2: 900, 3: 1100, 4: 1300}[realm] if "fortress" not in off else 448,
                  drain=0.60 if "fortress" not in off else 0.959,
                  block=40 if "fortress" not in off else 15,
                  regen_bonus=0.01, arts=[])
    b.ds = ds * M_TS[realm]
    b.x_soul = twt + x_other
    b.twt = twt
    b.speed = speed
    b.pierce = 0.30
    b.soul_res = {2: 30, 3: 45, 4: 60}[realm]          # Lamp (22.5 x ws) + Hon Ho lines, first guess
    b.soul_shield = (0.50, 0.10)
    b.ws = {2: 150, 3: 180, 4: 210}[realm]
    lance = SoulArt("Heart-Lamp Lance", 0.09, 6) if realm < 4 else SoulArt("Ninth-Weight Lance", 0.10, 8)
    thought = SoulArt("Mountain-Splitting Thought", 0.07, 4)
    needle = SoulArt("Lamp-Threading Needle", 0.05, 2, slack=0 if "slack" in off else 2)
    heal_c = 1.4 * art_lint(0.06, 4)
    lamp = SoulArt("Lamp-Light", 0.06, 4, soul_pct=0, heal=0 if "heal" in off else heal_c)
    b.soul_arts = [lance, thought, needle, lamp]
    b.wound = "wound" not in off
    b.splinters = "splinters" not in off
    b.siphon = 0.0 if "siphon" in off else 0.25
    b.first_move = True
    return b


def foe(kind, realm):
    """Foes on sim.py's typical kit, scaled to their realm. 'strong' and 'burst' are first guesses for the
    top-end, whose Formulas B ehp anchors are 're-derive' after #44."""
    T = sim.builds()["T"]
    b = Build(kind, realm=realm, arts=sim.kit())
    b.ds, b.x_soul, b.soul_res, b.soul_shield, b.ws = 59.4 * M_TS[realm], 0, 0.0, None, 30.8
    b.boss = 1.0
    if kind in ("strong", "strong_lamp", "burst"):
        b.M, b.crit, b.crit_mult = T.M * 4, 0.5, 2.0
        b.ward_pts, b.block, b.regen_bonus = 900.0, 30.0, 0.01
        b.ds, b.soul_res, b.ws = 142 * M_TS[realm], 15.0, 60.0
    if kind == "burst":
        b.M = T.M * 12
    if kind in ("lamp", "strong_lamp"):
        b.soul_res += 22.5 * (1 + b.ws / 100)          # Soul-Guarding Lamp, scaled by ward strength
        b.soul_shield = (0.50, 0.10)
    if kind == "boss":
        b.boss = 4.0
        b.n_body *= 4.0
        b.n_qi *= 4.0
        b.M = T.M * 2
    return b


def rival(realm):
    r = make_soul(realm, "soul rival")
    return r


class S(Side):
    def __init__(self, b):
        super().__init__(b)
        self.slack = []                 # [stacks, t_end]
        self.lock_until = 0.0
        self.bar = 0.0
        if getattr(b, "soul_shield", None):
            self.bar = b.soul_shield[1] * self.qi_base * (1 + b.ws / 100)
        if hasattr(b, "soul_arts"):
            sp = 1 + b.speed / 100
            self.soul_ready = [max(COOLDOWN_MIN, a.cd / sp) for a in b.soul_arts]
        self.capped = 0
        self.lances = 0
        self.soul_dealt = 0.0

    def soul_res(self, t):
        st = sum(n for n, te in self.slack if te > t + 1e-9)
        return getattr(self.b, "soul_res", 0.0) - 15.0 * min(2, st)


def boss_of(side):
    return getattr(side.b, "boss", 1.0)


def soul_hit(att, dfn, art, t):
    res = dfn.soul_res(t)
    if res >= 0:
        rho = att.b.ds / (dfn.b.ds * (1 + res / 100))
    else:
        rho = att.b.ds * (1 + abs(res) / 100) / dfn.b.ds
    if rho < RHO_MIN:
        return 0.0
    g = max(0, dfn.b.realm - att.b.realm)
    supp = 1 - SUPP[min(g, 4)] * (1 - min(0.75, getattr(att.b, "pierce", 0.0)))
    raw = art.soul_pct * (1 + att.b.x_soul / 100) * rho ** 2 * supp
    pct = min(raw, SOUL_CAP)
    clipped = max(0.0, raw - SOUL_CAP)
    if clipped > 0:
        att.capped += 1
    m = boss_of(dfn)
    lh = pct * dfn.hp_max / m
    lq = pct * dfn.qi_base / m
    if dfn.bar > 0 and getattr(dfn.b, "soul_shield", None):
        s = dfn.b.soul_shield[0]
        soak = min(dfn.bar, s * lh)
        lh -= soak
        dfn.bar -= soak
        soak = min(dfn.bar, s * lq)
        lq -= soak
        dfn.bar -= soak
    dfn.hp -= lh
    took = min(dfn.qi, lq)
    dfn.qi -= took
    att.dealt += lh
    att.soul_dealt += lh
    if getattr(att.b, "siphon", 0):
        att.qi = min(att.qi_max(), att.qi + att.b.siphon * took)
    if art.slack:
        dfn.slack.append([art.slack, t + 2.0])   # Slackened Soul lasts 2 pulses (effects.md Status Catalogue)
    delay = 0.0
    if getattr(att.b, "wound", False):
        delay += 0.5
    if getattr(att.b, "splinters", False) and clipped > 0:
        delay += min(1.5, 0.5 * math.floor(clipped / 0.10 + 1e-9))
    if delay and dfn.b.arts:
        i = min(range(len(dfn.ready)), key=lambda k: dfn.ready[k])
        dfn.ready[i] += delay
    if delay and hasattr(dfn.b, "soul_arts"):
        i = min(range(len(dfn.soul_ready)), key=lambda k: dfn.soul_ready[k])
        dfn.soul_ready[i] += delay
    return lh


def soul_act(s, o, t, rng):
    """The soul build's turn: soul arts in slot order, one per lockout; the heal art; the basic attack."""
    b = s.b
    sp = 1 + b.speed / 100
    for i, a in enumerate(b.soul_arts):
        if t + 1e-9 < s.soul_ready[i]:
            continue
        is_soul = a.soul_pct > 0
        if is_soul and t + 1e-9 < s.lock_until:
            continue
        if a.heal and s.hp > 0.85 * s.hp_max:
            continue                    # guard: own health at or below 85 %
        if a.heal == 0 and not is_soul:
            continue
        cost = a.cost * s.qi_base
        free = b.first_move and not a.fired and is_soul and s.lances == 0
        if not free and s.qi + 1e-6 < cost:
            continue
        if not free:
            s.qi -= cost
            s.spent += cost
        s.soul_ready[i] = t + max(COOLDOWN_MIN, a.cd / sp)
        a.fired.append(round(t, 2))
        if is_soul:
            s.lock_until = t + SOUL_LOCKOUT
            s.lances += 1
            soul_hit(s, o, a, t)
        else:
            got0 = s.healed
            sim.heal(s, s.U * a.heal * K["health_mult"])
            if s.healed > got0:
                s.qi = min(s.qi_max(), s.qi + cost)
    if t + 1e-9 >= s.basic_ready:
        sim.hit(s, o, 1.0, "phys", rng, t, None)
        s.basic_ready += 1.0


def fight(A_b, B_b, seed=1, trace=False):
    rng = random.Random(seed)
    order = random.Random(seed + 7919)
    for a in getattr(A_b, "soul_arts", []):
        a.fired = []
    for a in getattr(B_b, "soul_arts", []):
        a.fired = []
    A, B = S(A_b), S(B_b)
    t, dt, next_pulse = 0.0, K["dt"], 1.0
    rows = []
    while t <= K["time_limit"] + 1e-9:
        if t + 1e-9 >= next_pulse:
            sim.pulse(A, B, t, None)
            sim.pulse(B, A, t, None)
            if trace:
                rows.append((round(t), A.hp / A.hp_max, A.qi / A.qi_max(), B.hp / B.hp_max, B.qi / B.qi_max(),
                             B.soul_res(t)))
            next_pulse += 1.0
        first, second = (A, B) if order.random() < 0.5 else (B, A)
        for s, o in ((first, second), (second, first)):
            if hasattr(s.b, "soul_arts"):
                soul_act(s, o, t, rng)
            else:
                sim.act(s, o, t, rng, None)
        for s in (A, B):
            if s.dry_at is None and s.qi < 0.05 * s.qi_max():
                s.dry_at = t
        if A.hp <= 0 or B.hp <= 0:
            break
        t += dt
    win = "draw" if (A.hp <= 0 and B.hp <= 0) else "A" if B.hp <= 0 else "B" if A.hp <= 0 else "time"
    return dict(t=t, win=win, A=A, B=B, rows=rows)


REALMS = {"KD": 2, "NA": 3, "HT": 4}
FOES = [("typical", 0), ("lamp", 0), ("strong", 0), ("strong_lamp", 0), ("burst", 0), ("boss", 0),
        ("typical", 1), ("strong", 1), ("typical", 2), ("rival", 0)]


def run(off=(), seeds=20):
    print("off: %s" % (", ".join(off) or "nothing"))
    print("%-4s %-16s %4s %7s %6s %6s %6s %7s %6s %8s" % ("rlm", "foe", "gap", "mean s", "win%", "ownhp", "ownqi",
                                                          "lances", "capd", "x_soul"))
    for rn, r in REALMS.items():
        for kind, gap in FOES:
            res = []
            for sd in range(seeds):
                me = make_soul(r, "soul lance", off)
                other = rival(r) if kind == "rival" else foe(kind, min(4, r + gap))
                res.append(fight(me, other, seed=sd))
            if r + gap > 4:
                continue
            ts = sum(x["t"] for x in res) / len(res)
            w = 100 * sum(x["win"] == "A" for x in res) / len(res)
            hp = sum(max(0, x["A"].hp) / x["A"].hp_max for x in res) / len(res)
            qi = sum(x["A"].qi / x["A"].qi_max() for x in res) / len(res)
            ln = sum(x["A"].lances for x in res) / len(res)
            cp = sum(x["A"].capped for x in res) / len(res)
            print("%-4s %-16s %4d %7.1f %6.0f %5.0f%% %5.0f%% %7.1f %6.1f %8.0f" % (
                rn, kind, gap, ts, w, 100 * hp, 100 * qi, ln, cp, res[0]["A"].b.x_soul))


def reference(seeds=20):
    """A layer build with the same fortress, for comparison: typical kit at top-end-like M x4."""
    print("reference: the same fortress with a hit kit at M x4 (a strong layer build), vs the same foes")
    for rn, r in REALMS.items():
        for kind, gap in FOES[:-1]:
            if r + gap > 4:
                continue
            res = []
            for sd in range(seeds):
                me = make_soul(r, "ref")
                ref = Build("ref", realm=r, arts=sim.kit(), M=sim.builds()["T"].M * 4, crit=0.5, crit_mult=2.0,
                            n_body=1.1, n_qi=1.2, ward_pts=me.ward_pts, drain=me.drain, block=me.block,
                            regen_bonus=0.01)
                ref.ds, ref.soul_res, ref.soul_shield, ref.ws = me.ds, me.soul_res, me.soul_shield, me.ws
                res.append(fight(ref, foe(kind, min(4, r + gap)), seed=sd))
            ts = sum(x["t"] for x in res) / len(res)
            w = 100 * sum(x["win"] == "A" for x in res) / len(res)
            print("%-4s %-16s %4d %7.1f %6.0f" % (rn, kind, gap, ts, w))


if __name__ == "__main__":
    args = sys.argv[1:]
    if args and args[0] == "--trace":
        r = REALMS[args[1]]
        kind = args[2]
        other = rival(r) if kind == "rival" else foe(kind, r)
        out = fight(make_soul(r, "soul lance"), other, trace=True)
        print("t  me.hp me.qi foe.hp foe.qi foe.soul_res")
        for row in out["rows"]:
            print("%3d %5.2f %5.2f %6.2f %6.2f %6.1f" % row)
        for a in out["A"].b.soul_arts:
            print("%-28s soul_pct %.4f fired %s" % (a.name, a.soul_pct, a.fired[:12]))
        print(out["win"], round(out["t"], 2))
    elif args and args[0] == "--reference":
        reference()
    else:
        off = tuple(args[1].split(",")) if len(args) > 1 and args[0] == "--without" else ()
        run(off)
