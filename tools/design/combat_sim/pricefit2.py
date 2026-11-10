"""Price max linh luc %, max health % and all resistance pp against 10 W of damage (#44 part 4)."""
import sys
sys.path.insert(0, '.')
import sim
def wr(a, b, seeds=24):
    res = [sim.fight(a, b, seed=s) for s in range(seeds)]
    return (sum(r["win"] == "A" for r in res) + 0.5 * sum(r["win"] in ("draw", "time") for r in res)) / seeds
T = sim.Build("typical", arts=sim.kit())
target = wr(T, T)
M10 = 3.273 * 1.165 / 1.265
def mk(kind, x):
    b = sim.Build("x", arts=sim.kit(), M=M10)
    if kind == "qi": b.n_qi = 1.053 * (1 + x)
    if kind == "hp": b.n_body = 1.0883 * (1 + x)
    if kind == "res": b.ward_r = 0.654 + x / 1.25   # ward_mult 1.25 applies after, so x is pp of final resistance
    return b
for kind, hi, unit, label in [("qi", 0.5, 0.01, "max linh luc %"), ("hp", 1.0, 0.01, "max health %"), ("res", 0.08, 0.01, "all resistance pp")]:
    lo = 0.0
    for _ in range(8):
        mid = (lo + hi) / 2
        if wr(mk(kind, mid), T) > target: hi = mid
        else: lo = mid
    amt = (lo + hi) / 2 / unit
    print(f"{label:18} 10 W buys {amt:.2f} -> {10/amt:.2f} W per unit", flush=True)
