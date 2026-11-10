"""Find the damage multiplier on a build's arts that makes it break even (50 %) with the typical build."""
import sys, copy
sys.path.insert(0,'.')
import sim
def winrate(a,b,seeds=24):
    res=[sim.fight(a,b,seed=s) for s in range(seeds)]
    return (sum(r["win"]=="A" for r in res)+0.5*sum(r["win"] in("draw","time") for r in res))/seeds, sum(r["t"] for r in res)/seeds
def scaled(build,m):
    nb=copy.deepcopy(build)
    for a in nb.arts: a.c*=m
    return nb
b=sim.builds()
w,t=winrate(b["T"],b["T"]); print(f"typical mirror: A wins {w:.2f}, {t:.1f} s")
for key in ["S","F","W","I"]:
    w0,t0=winrate(b[key],b["T"])
    lo,hi=0.3,1.0
    for _ in range(7):
        mid=(lo+hi)/2
        w,_=winrate(scaled(b[key],mid),b["T"])
        if w>0.5: hi=mid
        else: lo=mid
    print(f"{b[key].name:12} as built wins {w0:.2f} ({t0:.1f} s); breaks even with art damage x{(lo+hi)/2:.2f}")
