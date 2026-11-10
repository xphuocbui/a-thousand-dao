"""Knob sweep for #44: health x4 with stronger wards."""
import sys, itertools
sys.path.insert(0,'.')
import sim
def run(a,b,seeds=8):
    res=[sim.fight(a,b,seed=s) for s in range(seeds)]
    t=sum(r["t"] for r in res)/len(res)
    dA=[r["A"].dry_at for r in res if r["A"].dry_at is not None]
    dry=sum(dA)/len(dA) if len(dA)>len(res)/2 else 999
    aw=(sum(r["win"]=="A" for r in res)+0.5*sum(r["win"] in ("draw","time") for r in res))/len(res)
    return t,dry,aw
b=sim.builds()
print("cap  wardx cost regen drain | typ_t dry | sus_dry win | heal_t | up_t")
for cap,wm,cs,rb,dr in itertools.product([0.85,0.90],[1.3,1.4],[0.5],[0.025,0.035],[0.2,0.35,0.5]):
    sim.K.update(resist_cap=cap, ward_mult=wm, cost_scale=cs, regen_base=rb, drain_scale=dr, health_mult=4)
    t,d,_=run(b["T"],b["T"])
    if not 35<=t<=60: 
        print(f"{cap} {wm} {cs} {rb} {dr} | {t:5.1f} {d:5.1f}"); continue
    st,sd,sw=run(b["S"],b["T"])
    ht,_,_=run(b["H"],b["H"],4)
    ut,_,_=run(b["T"],b["Up"],3)
    print(f"{cap} {wm} {cs} {rb} {dr} | {t:5.1f} {d:5.1f} | {sd:5.1f} {sw:4.2f} | {ht:5.1f} | {ut:4.1f}  <<", flush=True)
