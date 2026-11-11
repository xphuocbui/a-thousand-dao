"""Proof harness for the Two Clocks build (overnight 2026-11-10).

Why this file exists: the skill's fight_calc.py reports CONSTANT_DRIFT (31 of 60 constants) and still models the
tick caps that #44 removed, so it cannot test this build. This script imports the canonical #44 simulator
(tools/design/combat_sim/sim.py) read-only and replaces only its pulse step, adding what the build needs:

- a tick multiplier per side (ticks use layers L1..L4 only, Combat Formulas F), separate from the hit M;
- `stack_effect_pct` per element debuff, `resist_pen_pct` per tick type (points, Combat Defence rule 4);
- resistance split into a drain-paid part (falls when linh luc is 0, and bills linh luc for what it stops)
  and a kept part (reserved wards, items), so the two clocks can be told apart;
- Spillover (Effects, Starter Effects): 25 % of each tick's dealt damage burns linh luc;
- Embers Feed the Hearth (staged keystone, by-root missing-pieces): Burn ticks restore linh luc;
- Ash Ledger (this build's identity piece): 20 % of the tick damage resistance stops burns the target's linh luc.

Run from the repo root:  python -I design/builds/overnight-2026-11-10/builds/two-clocks.sim.py [realm 0-4]
Observations, not verdicts. Numbers on new pieces are first guesses.

STATUS: NOT YET RUN. The overnight session that wrote it could run only fight_calc.py, so the sheet's numbers
are a hand-worked paper model. Run this, compare with the sheet's Fight Results, and fix whichever is wrong.
Also modelled: Incense Clock (L5 on ticks: Marked Prey +8, Kindled Wound +15 on Burn, Fuel for the Fire +0.6 per
Poison stack on Burn, Bare Vessel +80 while the target is under 5 % linh luc; L5 cap 100).
"""
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
sys.path.insert(0, os.path.join(ROOT, "tools", "design", "combat_sim"))
import sim  # noqa: E402
from sim import Art, Build, K, DEBUFF, stack_power, heal  # noqa: E402


# ------------------------------------------------------------------ extended pulse
def resist_pts(dfn, el, src):
    """Resistance points a tick meets, and the drain-paid share of them."""
    R = dfn.b.ward_pts * K["ward_mult"] / 1.25
    kept = R * getattr(dfn.b, "reserved_res", 0.0)
    drain = (R - kept) if dfn.qi > 0 else 0.0
    R = drain + kept + getattr(dfn.b, "chaos_res" if el == "wood" else "fire_res", 0.0)
    R -= getattr(src.b, "pen", {}).get(el, 0.0)
    return R, drain


def pulse(s, o, t, log):
    for x in s.debuffs:
        el, n, src = x[0], x[1], x[3]
        c = DEBUFF.get(el, {}).get("burn", 0.0) + DEBUFF.get(el, {}).get("poison", 0.0)
        if not c:
            continue
        Mt = getattr(src.b, "M_tick", src.b.M)
        se = 1 + getattr(src.b, "stack_eff", {}).get(el, 0.0)
        l5 = 0.0
        if getattr(src.b, "incense_clock", False):
            l5 += 8                                              # Marked Prey: Burn and Poison, 2 statuses
            if el == "fire":
                l5 += 15 + 0.6 * s.count(s.debuffs, "wood")      # Kindled Wound; Fuel for the Fire
            if s.qi < 0.05 * s.qi_max():
                l5 += 80                                         # Bare Vessel
            l5 = min(l5, 100)
        tick = src.U * c * n * Mt * se * (1 + l5 / 100) * sim.supp(src, s) * stack_power(src.b, el)
        src.raw_tick = getattr(src, "raw_tick", 0.0) + tick
        R, drainR = resist_pts(s, el, src)
        if R > 0:
            dealt = tick / (1 + R / 100)
            billed = (tick - dealt) * min(1.0, drainR / R)
            bill = billed * s.b.drain * K["drain_scale"]
            ash = getattr(src.b, "ash_frac", 0.0) * (tick - dealt)   # Ash Ledger: a share of all prevented
            if bill > s.qi:
                frac = s.qi / bill if bill else 0.0
                dealt += billed * (1 - frac)
                src.billed = getattr(src, "billed", 0.0) + s.qi
                s.qi = 0.0
            else:
                s.qi -= bill
                src.billed = getattr(src, "billed", 0.0) + bill
            s.qi = max(0.0, s.qi - ash)
        else:
            dealt = tick * (1 + (-R) / 100)
        s.hp -= dealt
        src.dealt += dealt
        src.tick_dealt = getattr(src, "tick_dealt", 0.0) + dealt
        tb = getattr(src, "tick_by", {})
        tb[el] = tb.get(el, 0.0) + dealt
        src.tick_by = tb
        sp = getattr(src.b, "spill", 0.0)
        if sp:
            burn = min(s.qi, sp * dealt)
            s.qi -= burn
            src.spilled = getattr(src, "spilled", 0.0) + burn
        if el == "fire" and src.b.k_burn:
            src.qi = min(src.qi_max(), src.qi + src.b.k_burn * dealt)
    s.now = t
    if t >= s.stag_until:
        s.qi = min(s.qi_max(), s.qi + s.regen())
        heal(s, s.hp_max * (s.b.hregen + s.bsum("hregen")))
    if s.b.cleanse_share:
        for x in s.debuffs:
            x[1] *= (1 - s.b.cleanse_share)
        s.debuffs = [x for x in s.debuffs if x[1] >= 0.05]
    if t >= K["fatigue_start"] - 1e-9:
        k = round(t - K["fatigue_start"])
        f = s.U * K["fatigue_units"] * (1 + k) ** K["fatigue_pow"]
        s.hp -= f
        s.fat += f
    s.buffs = [x for x in s.buffs if x[2] > t + 1e-9]
    s.debuffs = [x for x in s.debuffs if x[2] > t + 1e-9]
    if s.qi <= 1e-9 and getattr(s, "zero_at", None) is None:
        s.zero_at = t


sim.pulse = pulse


# ------------------------------------------------------------------ helpers
def art(name, c, cost_share, cd, el, debuff=(), buff=(), dtype="elem"):
    """sim.py costs are pre-#44 shares times cost_scale 0.5, so pass twice the #44 cost_share."""
    return Art(name, c, cost_share * 2, cd, el, dtype, buff, debuff)


def lint(cost_share, cd, charge):
    """Combat Formulas C at art_coef_per_cost 24, times (1 - charge) (Effects Formulas D), rounded down."""
    raw = (1 + 24 * cost_share + 0.25 * (cd - 1)) * (1 - min(charge, 0.6))
    return math.floor(raw * 100 + 1e-9) / 100


def report(name, a, b, seeds=20):
    res = [sim.fight(a, b, seed=sd) for sd in range(seeds)]
    n = len(res)
    t = sum(r["t"] for r in res) / n
    aw = sum(r["win"] == "A" for r in res)
    bw = sum(r["win"] == "B" for r in res)
    z = [getattr(r["B"], "zero_at", None) for r in res]
    z = [x for x in z if x is not None]
    tick = sum(getattr(r["A"], "tick_dealt", 0.0) for r in res)
    alld = sum(r["A"].dealt for r in res) or 1
    hp = sum(max(r["A"].hp, 0) / r["A"].hp_max for r in res) / n
    zs = f"{sum(z)/len(z):5.1f}" if z else "never"
    print(f"{name:46} t {t:5.1f}  win {aw:2d}/{n}  loss {bw:2d}  foe linh luc 0 at {zs:>5} ({len(z):2d}/{n})"
          f"  tick share {tick/alld:4.2f}  own hp left {hp:4.2f}")
    return res


# ------------------------------------------------------------------ the build and its foes
def foe(kind, realm=2, reserved=0.0, cleanse=0.0, fire_res=0.0, chaos_res=0.0):
    """Reference foes. typical = Formulas B anchor M and the Qi Refining Common Ward (448 points; the
    higher-realm ehp is still 're-derive' in Combat Formulas B). strong and top_end are first guesses."""
    if kind == "typical":
        b = Build("typical", realm=realm, M=[3.27, 4.19, 5.48, 7.37, 8.96][realm], ward_pts=448, arts=sim.kit())
    elif kind == "strong":
        b = Build("strong", realm=realm, M=20, crit=0.3, crit_mult=2.0, ward_pts=900, n_body=1.5, n_qi=1.3,
                  arts=sim.kit())
    else:
        b = Build("top_end", realm=realm, M=[103, 148, 210, 256, 325][realm] / 2.0, crit=0.5, crit_mult=2.0,
                  ward_pts=[900, 1150, 1400, 1650, 1900][realm], n_body=2.0, n_qi=1.5, arts=sim.kit())
    b.reserved_res, b.cleanse_share, b.fire_res, b.chaos_res = reserved, cleanse, fire_res, chaos_res
    return b


def two_clocks(realm=3, Mt=52.5, se=0.36, pen=120, dur=0.6, purity=80, spill=0.25, embers=0.25,
               ash=0.20, clock=True, ward=900):
    """The sheet's loadout at Nascent Soul (6 art slots): Ember Rain, Rot Seed, Sap Rising, Red Censer,
    Green Censer, Golden Light Shield (the shield is not modelled; its slot is left empty). Hits deal 0
    under the Incense Clock (c 0, M 0)."""
    hit_c = 0.0 if clock else None
    burn = (20, 2.0)                       # the fast clock: 20 Burn for 2 s (40 stack-seconds, charge 0.6)
    rot = (4, 10.0 * (1 + dur))            # the slow clock: 4 Poison for 10 s, +60 % stack duration
    arts = [
        art("Ember Rain", hit_c if clock else lint(0.02, 1, 0.6), 0.02, 1.0, "fire", debuff=burn),
        art("Rot Seed", hit_c if clock else lint(0.02, 1, 0.6), 0.02, 1.0, "wood", debuff=rot),
        art("Sap Rising", 0.0, 0.02, 2.0, "wood", buff=(6, 10.0)),
        art("Red Censer", hit_c if clock else lint(0.02, 2, 0.6), 0.02, 2.0, "fire", debuff=burn),
        art("Green Censer", hit_c if clock else lint(0.02, 2, 0.6), 0.02, 2.0, "wood", debuff=rot),
    ]
    arts = arts[: [3, 4, 5, 6, 7][realm]]
    b = Build("two clocks", realm=realm, M=0.0 if clock else 8.0, crit=0.0, crit_mult=1.5, ward_pts=ward,
              n_body=1.5, n_qi=1.3, block=15, arts=arts, purity={"wood": purity, "fire": purity})
    b.M_tick, b.stack_eff, b.pen = Mt, {"wood": se, "fire": se}, {"wood": pen, "fire": pen}
    b.spill, b.k_burn, b.reserved_res = spill, embers, 0.0
    b.incense_clock = clock
    b.ash_frac = ash
    return b


if __name__ == "__main__":
    args = sys.argv[1:]
    realm = int(args[0]) if args else 3
    print(f"realm {realm}; knobs: drain_scale {K['drain_scale']}, regen_base {K['regen_base']}, fatigue from "
          f"{K['fatigue_start']} s")
    for k in ("typical", "strong", "top_end"):
        report(f"vs {k}, drain ward", two_clocks(realm), foe(k, realm))
        report(f"vs {k}, without Ash Ledger", two_clocks(realm, ash=0.0), foe(k, realm))
        report(f"vs {k}, without Incense Clock", two_clocks(realm, clock=False), foe(k, realm))
        report(f"vs {k}, reserved ward", two_clocks(realm), foe(k, realm, reserved=1.0))
        report(f"vs {k}, cleansing ward 0.25", two_clocks(realm), foe(k, realm, cleanse=0.25))
