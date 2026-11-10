"""Equal-value element stacks (user, 2026-11-10): find the factor on each element's per-stack effect so that a kit
paying the common price breaks even with the typical build. Buffs priced 1.0 % of art damage per stack-second
(1 stack for 10 s per firing -> 10 % charge); debuffs 1.5 % (2 stacks for 6 s per hit -> 18 % charge).
The foe has 10 % evade so accuracy and evade stacks act."""
import sys, copy
sys.path.insert(0, '.')
import sim
BASE_B = copy.deepcopy(sim.BUFF); BASE_D = copy.deepcopy(sim.DEBUFF)
def wr(a, b, seeds=24):
    res = [sim.fight(a, b, seed=s) for s in range(seeds)]
    return (sum(r["win"] == "A" for r in res) + 0.5 * sum(r["win"] in ("draw", "time") for r in res)) / seeds
foe = sim.Build("typical", arts=sim.kit(), evade=0.10)
target = wr(sim.Build("base", arts=sim.kit(), evade=0.10), foe)
print(f"break-even target (control side-A rate) {target:.2f}", flush=True)
DT = {"fire": "elem", "water": "elem", "earth": "phys", "metal": "phys", "wood": "elem", "ice": "elem", "thunder": "elem", "wind": "elem"}
def run(el, side, f):
    sim.BUFF.clear(); sim.BUFF.update(copy.deepcopy(BASE_B)); sim.DEBUFF.clear(); sim.DEBUFF.update(copy.deepcopy(BASE_D))
    table = sim.BUFF if side == "buff" else sim.DEBUFF
    table[el] = {k: v * f for k, v in table[el].items()}
    if side == "buff":
        arts = sim.kit(element=el, dtype=DT[el], buff=(1, 10)); charge = 0.010 * 10
    else:
        arts = sim.kit(element=el, dtype=DT[el], debuff=(2, 6)); charge = 0.015 * 12
    for a in arts: a.c *= (1 - charge)
    return wr(sim.Build(el, arts=arts, evade=0.10), foe)
for side, els in (("buff", ["fire", "water", "earth", "metal", "wood", "thunder", "wind"]),
                  ("debuff", ["fire", "earth", "metal", "wood", "ice", "thunder", "wind"])):
    for el in els:
        lo, hi = 0.1, 8.0
        for _ in range(8):
            mid = (lo * hi) ** 0.5
            if run(el, side, mid) > target: hi = mid
            else: lo = mid
        f = (lo * hi) ** 0.5
        cur = BASE_B[el] if side == "buff" else BASE_D[el]
        print(f"{side:6} {el:8} factor x{f:.2f} -> " + ", ".join(f"{k} {v*f:.4f}" for k, v in cur.items()), flush=True)
