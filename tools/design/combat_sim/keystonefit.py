"""Fit starting numbers for the linh luc keystones proposed in design/builds/by-root/missing-pieces.md.
Each keystone build uses its element's kit with the stacks priced by Effects Formulas D (the art lint charge) and the
keystone's closing cost, against the typical build. The keystone's number is searched until the build wins
target = (mirror side-A rate) + 0.15: a keystone should make its build clearly but not overwhelmingly stronger."""
import sys, copy
sys.path.insert(0, '.')
import sim
W = {el: (0.010 if el != "ice" else 0, 0.015 if el != "water" else 0) for el in ["fire", "water", "earth", "metal", "wood", "ice", "thunder", "wind"]}  # equal-value weights (2026-11-10)
def wr(a, b, seeds=24):
    res = [sim.fight(a, b, seed=s) for s in range(seeds)]
    return (sum(r["win"] == "A" for r in res) + 0.5 * sum(r["win"] in ("draw", "time") for r in res)) / seeds
def stack_kit(el, dtype, buff=(1, 10), debuff=(2, 6), drop_slow=False):
    wb, wd = W[el]
    buff = buff if wb else ()
    debuff = debuff if wd else ()
    charge = (wb * buff[0] * buff[1] if buff else 0) + (wd * debuff[0] * debuff[1] if debuff else 0)
    if buff and debuff: charge *= 0.75
    arts = sim.kit(element=el, dtype=dtype, buff=buff, debuff=debuff)
    if drop_slow: arts = [a for a in arts if a.cd <= 6]
    for a in arts: a.c *= (1 - min(charge, 0.6))
    return arts, charge
T = sim.Build("typical", arts=sim.kit())
target = wr(T, T) + 0.15
print(f"target win rate {target:.2f}")
CASES = [
    ("Edge Returns the Breath (Metal): linh luc per Physical crit", "metal", "phys", "k_crit_phys", 0.0, 0.10, {}, False),
    ("Storm Battery (Thunder): linh luc per crit, non-crit hits -10 %", "thunder", "elem", "k_crit_any", 0.0, 0.10, {"k_noncrit_pen": 0.10}, False),
    ("Embers Feed the Hearth (Fire): share of Burn damage, direct Fire -15 %", "fire", "elem", "k_burn", 0.0, 3.0, {"k_fire_pen": 0.15}, False),
    ("Root Drinks the Rot (Wood): leech vs a poisoned foe", "wood", "elem", "k_poison_leech", 0.0, 1.0, {}, False),
    ("The Stone Remembers (Earth): share of damage stopped", "earth", "phys", "k_prevented", 0.0, 0.5, {}, False),
    ("Breath Between Blows (Wind): linh luc per art, no art over 6 s", "wind", "elem", "k_art", 0.0, 0.10, {}, True),
    ("Frost Tithe (Ice): share of the foe's extra cost", "ice", "elem", "k_frost", 0.0, 5.0, {}, False),
]
for label, el, dt, field, lo, hi, extra, drop in CASES:
    arts, charge = stack_kit(el, dt, drop_slow=drop)
    base = sim.Build("k", arts=copy.deepcopy(arts), **extra)
    w0 = wr(base, T)
    for _ in range(8):
        mid = (lo + hi) / 2
        b = sim.Build("k", arts=copy.deepcopy(arts), **extra); setattr(b, field, mid)
        if wr(b, T) > target: hi = mid
        else: lo = mid
    v = (lo + hi) / 2
    print(f"{label}\n   stack charge {charge:.2f}; without keystone {w0:.2f}; keystone value {v:.4f} ({field})", flush=True)
# Water: on/off
arts, charge = stack_kit("water", "elem", buff=(1, 15))
for nodr in (False, True):
    b = sim.Build("w", arts=copy.deepcopy(arts), k_water_nodr=nodr)
    print(f"The Spring Never Fails (Water) {'on ' if nodr else 'off'}: win {wr(b, T):.2f} (stack charge {charge:.2f})", flush=True)
b = sim.Build("w", arts=copy.deepcopy(arts), k_water_nodr=True, n_qi=1.053 * 0.75)
print(f"The Spring Never Fails on, with max linh luc x0.75 closing cost: win {wr(b, T):.2f}", flush=True)
