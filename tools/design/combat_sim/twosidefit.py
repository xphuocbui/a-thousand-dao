"""Re-measure the two-sided discount in Effects Formulas D after equal-value stacks (2026-11-10), and fit
The Spring Never Fails as '+X of qi_max regeneration per Water stack, outside diminishing returns'."""
import sys, copy
sys.path.insert(0, '.')
import sim
def wr(a, b, seeds=24):
    res = [sim.fight(a, b, seed=s) for s in range(seeds)]
    return (sum(r["win"] == "A" for r in res) + 0.5 * sum(r["win"] in ("draw", "time") for r in res)) / seeds
DT = {"fire": "elem", "earth": "phys", "metal": "phys", "wood": "elem", "thunder": "elem", "wind": "elem"}
foe = sim.Build("typical", arts=sim.kit(), evade=0.10)
target = wr(sim.Build("base", arts=sim.kit(), evade=0.10), foe)
SUM = 0.010 * 10 + 0.015 * 12
fs = []
for el, dt in DT.items():
    lo, hi = 0.4, 2.2
    for _ in range(7):
        mid = (lo + hi) / 2
        arts = sim.kit(element=el, dtype=dt, buff=(1, 10), debuff=(2, 6))
        for a in arts: a.c *= 1 - min(mid * SUM, 0.6)
        if wr(sim.Build(el, arts=arts, evade=0.10), foe) > target: lo = mid
        else: hi = mid
    f = (lo + hi) / 2; fs.append(f)
    print(f"{el:8} two-sided factor {f:.2f}", flush=True)
print(f"mean factor {sum(fs)/len(fs):.2f}", flush=True)
T = sim.Build("typical", arts=sim.kit())
tgt = wr(T, T) + 0.15
lo, hi = 0.0, 0.01
arts = sim.kit(element="water", dtype="elem", buff=(1, 15))
for a in arts: a.c *= 1 - 0.010 * 15 * 1.5 / (1 + 15 / 20) / 1.0 if False else 1 - 0.15
for _ in range(9):
    mid = (lo + hi) / 2
    if wr(sim.Build("w", arts=copy.deepcopy(arts), k_water_pp=mid), T) > tgt: hi = mid
    else: lo = mid
print(f"The Spring Never Fails: +{(lo+hi)/2*100:.3f} pp regeneration per Water stack (target {tgt:.2f})", flush=True)
