"""Fit what element stacks are worth, per stack-second, for each element's buff and debuff (#44 P3-2).
A kit grants stacks at a fixed rate; its arts' damage is scaled down until it breaks even with the typical build.
value per stack-second = (1 - break-even multiplier) / stack-seconds granted per art firing."""
import sys, copy
sys.path.insert(0, '.')
import sim
EV = 0.10  # the typical foe gets 10 % evade so accuracy and evade stacks have something to act on
def wr(a, b, seeds=16):
    res = [sim.fight(a, b, seed=s) for s in range(seeds)]
    return (sum(r["win"] == "A" for r in res) + 0.5 * sum(r["win"] in ("draw", "time") for r in res)) / seeds
def breakeven(build, foe):
    lo, hi = 0.2, 1.3
    for _ in range(7):
        mid = (lo + hi) / 2
        nb = copy.deepcopy(build)
        for a in nb.arts: a.c *= mid
        if wr(nb, foe) > 0.5: hi = mid
        else: lo = mid
    return (lo + hi) / 2
foe = sim.Build("typical", arts=sim.kit(), evade=EV)
base = sim.Build("base", arts=sim.kit(), evade=EV)
m0 = breakeven(base, foe)
print(f"control (no stacks) breaks even at x{m0:.2f}")
BUFF_SS = 1 * 10   # 1 stack for 10 s per firing
DEB_SS = 2 * 6     # 2 stacks for 6 s per hit
els = {"fire": "elem", "water": "elem", "earth": "phys", "metal": "phys", "wood": "elem", "ice": "elem", "thunder": "elem", "wind": "elem"}
for el, dt in els.items():
    out = []
    if el in sim.BUFF:
        b = sim.Build(el + " buff", arts=sim.kit(element=el, dtype=dt, buff=(1, 10)), evade=EV)
        m = breakeven(b, foe) / m0
        out.append(f"buff x{m:.2f} -> {(1-m)/BUFF_SS*100:.2f} % per stack-s")
    if el in sim.DEBUFF:
        b = sim.Build(el + " debuff", arts=sim.kit(element=el, dtype=dt, debuff=(2, 6)), evade=EV)
        m = breakeven(b, foe) / m0
        out.append(f"debuff x{m:.2f} -> {(1-m)/DEB_SS*100:.2f} % per stack-s")
    print(f"{el:8} " + " | ".join(out), flush=True)
# cleansing check
F = sim.Build("fire", arts=sim.kit(element="fire", dtype="elem", buff=(1, 10), debuff=(2, 6)))
for sh in (0.0, 0.25, 0.4):
    C = sim.Build("cleanser", arts=sim.kit(), cleanse_share=sh)
    print(f"fire vs share-cleanser {sh}: fire wins {wr(F, C, 20):.2f}")
