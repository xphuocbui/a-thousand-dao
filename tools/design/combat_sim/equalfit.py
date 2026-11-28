"""Equal-value element stacks (user, 2026-11-10): find the factor on each element's per-stack effect so that a kit
paying the common price breaks even with the typical build. Buffs priced 1.0 % of art damage per stack-second
(1 stack for 10 s per firing -> 10 % charge); debuffs 1.5 % (2 stacks for 6 s per hit -> 18 % charge).
The foe has 10 % evade so accuracy and evade stacks act.

Pass --dark to run only the Darkness (Shadow Erosion) fit on engine.py (2026-11-28)."""
import sys, os, copy
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import sim
import engine


def fit_legacy():
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


def fit_dark(seeds=100):
    """Fit Darkness (am / dark) Shadow Erosion on engine.py with symmetric A/B swapping (order='random'):
    - Buff (Shadow Veil: +evade, w_buff=0.010, 1 stack for 10 s -> 10% charge) vs typical (evade=0.10).
    - Debuff (Shadow Erosion: +chaos_soul_taken & dampened heal_taken_down, w_debuff=0.015, 2 stacks for 6 s -> 18%
      charge) across a 3-opponent composite (typical, wood_buff, healer), targeting 0.000 mean delta vs controls."""
    orig_b = copy.deepcopy(engine.BUFF)
    orig_d = copy.deepcopy(engine.DEBUFF)

    def sym_wr(a, b):
        w = 0.0
        for s in range(seeds):
            r1 = engine.fight(a, b, seed=s, order="random")
            r2 = engine.fight(b, a, seed=s + 10000, order="random")
            w += 1.0 if r1["win"] == "A" else (0.5 if r1["win"] in ("draw", "time") else 0.0)
            w += 1.0 if r2["win"] == "B" else (0.5 if r2["win"] in ("draw", "time") else 0.0)
        return w / (2 * seeds)

    def mk_build(name, arts, evade=0.10):
        sb = sim.Build(name, arts=arts, evade=evade)
        return engine.from_sim(sb)

    try:
        typ = mk_build("typical", sim.kit(), evade=0.10)
        w_arts = sim.kit(element="wood", dtype="elem", buff=(1, 10))
        for a in w_arts:
            a.c *= 0.90
        wood = mk_build("wood_buff", w_arts, evade=0.10)
        h_sim = copy.deepcopy(sim.builds()["H"])
        h_sim.evade = 0.10
        healer = engine.from_sim(h_sim)

        base_dark = mk_build("dark_base", sim.kit(element="dark", dtype="elem"), evade=0.10)
        ctrl_typ = sym_wr(base_dark, typ)
        ctrl_wood = sym_wr(base_dark, wood)
        ctrl_heal = sym_wr(base_dark, healer)
        ctrl_mean = (ctrl_typ + ctrl_wood + ctrl_heal) / 3.0
        print(f"[dark engine.py] symmetric controls ({2*seeds} fights/pt): typical={ctrl_typ:.3f} wood={ctrl_wood:.3f} healer={ctrl_heal:.3f} mean={ctrl_mean:.3f}", flush=True)

        # 1. Buff fit: evade per stack
        b_arts = sim.kit(element="dark", dtype="elem", buff=(1, 10))
        for a in b_arts:
            a.c *= (1 - 0.010 * 10)
        b_build = mk_build("dark_buff", b_arts, evade=0.10)
        lo, hi = 0.002, 0.030
        for _ in range(9):
            mid = 0.5 * (lo + hi)
            engine.BUFF["dark"] = {"evade": mid}
            if sym_wr(b_build, typ) > ctrl_typ:
                hi = mid
            else:
                lo = mid
        ev_fit = 0.5 * (lo + hi)
        engine.BUFF["dark"] = {"evade": ev_fit}
        ev_wr = sym_wr(b_build, typ)
        engine.BUFF["dark"] = copy.deepcopy(orig_b["dark"])
        cur_ev_wr = sym_wr(b_build, typ)
        print(f"buff   dark     bisect -> evade {ev_fit:.4f} (wr {ev_wr:.3f}); locked {orig_b['dark']['evade']:.4f} (wr {cur_ev_wr:.3f})", flush=True)

        # 2. Debuff fit: scale factor on locked (chaos_soul_taken, heal_taken_down) ratio
        d_arts = sim.kit(element="dark", dtype="elem", debuff=(2, 6))
        for a in d_arts:
            a.c *= (1 - 0.015 * 12)
        d_build = mk_build("dark_debuff", d_arts, evade=0.10)
        base_cs = orig_d["dark"]["chaos_soul_taken"]
        base_ht = orig_d["dark"]["heal_taken_down"]

        def debuff_eval(cs, ht):
            engine.DEBUFF["dark"] = {"chaos_soul_taken": cs, "heal_taken_down": ht}
            w1 = sym_wr(d_build, typ)
            w2 = sym_wr(d_build, wood)
            w3 = sym_wr(d_build, healer)
            return w1, w2, w3, (w1 + w2 + w3) / 3.0

        lo, hi = 0.3, 3.0
        for _ in range(9):
            mid = (lo * hi) ** 0.5
            _, _, _, m = debuff_eval(base_cs * mid, base_ht * mid)
            if m > ctrl_mean:
                hi = mid
            else:
                lo = mid
        fac = (lo * hi) ** 0.5
        f_cs, f_ht = base_cs * fac, base_ht * fac
        w1, w2, w3, m = debuff_eval(f_cs, f_ht)
        l1, l2, l3, lm = debuff_eval(base_cs, base_ht)
        print(f"debuff dark     factor x{fac:.2f} -> chaos_soul_taken {f_cs:.4f}, heal_taken_down {f_ht:.4f} "
              f"(typ {w1:.3f}, wood {w2:.3f}, healer {w3:.3f}, mean {m:.3f}, delta {m - ctrl_mean:+.3f})", flush=True)
        print(f"debuff dark     locked -> chaos_soul_taken {base_cs:.4f}, heal_taken_down {base_ht:.4f} "
              f"(typ {l1:.3f}, wood {l2:.3f}, healer {l3:.3f}, mean {lm:.3f}, delta {lm - ctrl_mean:+.3f})", flush=True)
    finally:
        engine.BUFF.clear(); engine.BUFF.update(orig_b)
        engine.DEBUFF.clear(); engine.DEBUFF.update(orig_d)


if __name__ == "__main__":
    if "--dark" in sys.argv:
        fit_dark()
    else:
        fit_legacy()
        fit_dark()
