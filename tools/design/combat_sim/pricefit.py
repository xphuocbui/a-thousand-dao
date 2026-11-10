"""Price sustain stats for #44 part 4: how much of a stat buys the same win rate as 10 W of damage.
A build trades 10 W of attack (L1 1.265 -> 1.165) for an amount of the stat; the amount that breaks even
with the typical build gives the price: W per unit = 10 / amount."""
import sys, copy
sys.path.insert(0, '.')
import sim
def wr(a, b, seeds=24):
    res = [sim.fight(a, b, seed=s) for s in range(seeds)]
    return (sum(r["win"] == "A" for r in res) + 0.5 * sum(r["win"] in ("draw", "time") for r in res)) / seeds
T = sim.Build("typical", arts=sim.kit())
w_mirror = wr(T, T)
M10 = 3.273 * 1.165 / 1.265
STATS = {  # field, unit label, search range (in field units), unit size for the price
    "regen_bonus": ("linh luc regen", 0.0, 0.05, 0.01, "pp of qi_max per s"),
    "cost_red": ("art cost reduction", 0.0, 0.4, 0.01, "%"),
    "gain_on_hit": ("linh luc on hit", 0.0, 0.02, 0.01, "% of qi_max per hit"),
    "leech_qi": ("linh luc leech", 0.0, 0.5, 0.01, "% of damage"),
    "leech_hp": ("health leech", 0.0, 0.5, 0.01, "% of damage"),
    "hregen": ("health regen", 0.0, 0.02, 0.01, "pp of health_max per s"),
}
print(f"mirror side-A rate {w_mirror:.2f} (the target for break-even)")
for f, (label, lo, hi, unit, ul) in STATS.items():
    for _ in range(8):
        mid = (lo + hi) / 2
        b = sim.Build("x", arts=sim.kit(), M=M10)
        setattr(b, f, mid)
        if wr(b, T) > w_mirror: hi = mid
        else: lo = mid
    amt = (lo + hi) / 2
    print(f"{label:20} 10 W buys {amt/unit:.3f} {ul} -> {10/(amt/unit):.2f} W per unit", flush=True)
