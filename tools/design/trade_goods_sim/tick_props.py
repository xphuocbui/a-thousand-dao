"""Property test for the Trade Goods economy tick (design/gdd/trade-goods.md, Formulas B, D, F, G).

Runs random worlds of linked markets for many seasons, following the GDD's phase order:
  (c) pre-draw value v_g, craft draw cd (Formula F with the draw scale), X_pre
  (d) link flows: avail_A, exports split by the exporter's ex[A,g]
  (e) X0, specific outflows, exports first, the capped shared draw, dust, shares, stock_sh;
      then wsh_g and the scarcity factor (Formula D) after every market's B
  (f) plan update (Formula F, no windup)
and checks every invariant the GDD claims. Prints, per variant, how often each invariant failed
and the first failing case. It reports observations only; the GDD decides what they mean.

Usage:  python -I tools/design/trade_goods_sim/tick_props.py [--worlds N] [--seasons S] [--seed X]
"""
from __future__ import annotations

import argparse
import itertools
import math
import random
from dataclasses import dataclass, field

TOL = 1e-9

# GDD values (Formulas B, D, F; #43 Formula E table for pills)
DUST = 0.01
SIGMA, ETA, WSH_MIN = 0.12, 0.18, 0.005
KAPPA, LAMBDA, C_LO, ALPHA_P, DELTA_P, PHI_P, FILL_TOL = 0.5, 0.5, 0.1, 0.3, 1.15, 0.05, 0.95
C_REF, DK_RAW, S_CAP, PLAYER_CAP, PS = 1.5, 0.2, 3.0, 0.10, 0.8
VALUES = [2, 3, 10, 45, 150, 400, 900, 3000]


@dataclass
class Variant:
    name: str
    clamp_rest: bool      # use max(0, D - craft_in) in D_g and in the shared draw (avail_A always clamps, per the GDD)
    sorted_sums: bool     # world sums (wsh_g) taken in market-id order, not processing order
    round_guard: bool = False  # X' = max(0, X') after the shared draw (float rounding only)


@dataclass
class World:
    goods: list
    band: dict
    V: dict
    markets: list
    S_mean: dict          # (m, g) -> mean own supply a season
    R_pre: dict           # (m, band) -> non-craft demand before P_eff
    classes: dict         # m -> list of crafted classes
    X: dict = field(default_factory=dict)          # (m, g) -> end value X' (ledger)
    fill_prev: dict = field(default_factory=dict)  # (m, ci) -> last season's fill_c


def make_world(rng: random.Random) -> World:
    G = rng.randint(3, 8)
    goods = list(range(G))
    band = {g: rng.randint(0, 1) for g in goods}
    V = {g: rng.choice(VALUES) for g in goods}
    markets = list(range(3))
    S_mean = {}
    for m in markets:
        for g in goods:
            r = rng.random()
            # no supply, a trickle under one unit, or a real supply
            S_mean[m, g] = 0.0 if r < 0.3 else (V[g] * rng.uniform(0.005, 0.5) if r < 0.55 else rng.uniform(50, 3000))
    R_pre = {(m, b): rng.choice([0.0, rng.uniform(10, 300), rng.uniform(300, 4000)]) for m in markets for b in (0, 1)}
    classes = {}
    for m in markets:
        cl = []
        for _ in range(rng.randint(0, 3)):
            slots = []
            for _ in range(rng.randint(1, 3)):
                if rng.random() < 0.5:
                    slots.append(("n", rng.choice(goods), rng.uniform(0.1, 1.0)))
                else:
                    slots.append(("g", frozenset(rng.sample(goods, rng.randint(1, G))), rng.uniform(0.1, 1.0)))
            tot = sum(s[2] for s in slots)
            slots = [(t, x, a / tot) for t, x, a in slots]           # a[c, slot] sums to 1
            plan_ref = rng.uniform(50, 3000)
            cl.append({"slots": slots, "plan_ref": plan_ref, "plan": plan_ref * rng.uniform(0.2, 1.5),
                       "mu": rng.uniform(0.8, 3.0)})
        classes[m] = cl
    w = World(goods, band, V, markets, S_mean, R_pre, classes)
    for m in markets:
        for g in goods:
            w.X[m, g] = rng.choice([0.0, V[g] * rng.uniform(0, 0.99), rng.uniform(0, 5000)])
        for ci in range(len(classes[m])):
            w.fill_prev[m, ci] = 1.0
    return w


def season_inputs(w: World, rng: random.Random):
    """Random exogenous inputs for one season, drawn once so every processing order sees the same ones."""
    inp = {"S": {}, "sell": {}, "buy_try": {}, "peff_u": {}, "links": [], "P": {}}
    pm = rng.choice(w.markets)  # the player trades in one market a season
    for m in w.markets:
        for g in w.goods:
            mean = w.S_mean[m, g]
            inp["S"][m, g] = 0.0 if mean == 0 else mean * rng.uniform(0.5, 1.5)
            inp["sell"][m, g] = rng.choice([0, 0, 0, w.V[g] * rng.randint(1, 20)]) if m == pm else 0.0
            inp["buy_try"][m, g] = rng.choice([0, 0, rng.uniform(0, 1.0), 1.0, 1.2]) if m == pm else 0.0
        for b in (0, 1):
            inp["peff_u"][m, b] = rng.uniform(-1, 1) if m == pm else 0.0
        for ci in range(len(w.classes[m])):
            inp["P"][m, ci] = (rng.uniform(0.6, 2.5), rng.uniform(0.5, 2.5), rng.uniform(0.0, 4.0))
    lid = 0
    for a in w.markets:
        for b in w.markets:
            if a != b:
                for k in (0, 1):
                    if rng.random() < 0.35:
                        inp["links"].append((lid, a, b, k, rng.uniform(0, 4000)))
                        lid += 1
    return inp


def tick(w: World, inp, order, var: Variant, fails, ctx):
    goods, band, V = w.goods, w.band, w.V
    Xprev = dict(w.X)
    shelved = {(m, g): Xprev[m, g] >= V[g] for m in w.markets for g in goods}

    def fail(name, detail):
        fails.setdefault(name, [0, None])
        fails[name][0] += 1
        if fails[name][1] is None:
            fails[name][1] = f"{ctx}: {detail}"

    st = {}
    # ---- step (c): pre-draw value, craft draw, X_pre -------------------------------------------------------
    for m in order:
        v = {g: Xprev[m, g] + inp["S"][m, g] + inp["sell"][m, g] for g in goods}
        buy = {}
        for g in goods:
            want = inp["buy_try"][m, g] * v[g] if shelved[m, g] else 0.0
            buy[g] = want if want <= v[g] else 0.0          # a purchase beyond v_g is refused at settlement
        avail = {g: (v[g] - buy[g]) if shelved[m, g] else 0.0 for g in goods}
        cls = w.classes[m]
        need_c = []                                          # per class: list of (slot, {g: need})
        craft_in_b = {0: 0.0, 1: 0.0}
        for ci, c in enumerate(cls):
            full = c["plan"] / (c["mu"] * PS)
            slots = []
            for t, x, a in c["slots"]:
                n = full * a
                d = {}
                if t == "n":
                    d[x] = n
                else:
                    sh = [g for g in x if shelved[m, g]]
                    tot = sum(avail[g] for g in sh)
                    if sh and tot > 0:
                        for g in sh:
                            d[g] = n * avail[g] / tot
                    else:                                   # by wsh_g in the GDD; equal split here (demand still priced)
                        for g in x:
                            d[g] = n / len(x)
                slots.append((t, x, d))
                for g, q in d.items():
                    craft_in_b[band[g]] += q * w.fill_prev[m, ci]
            need_c.append(slots)
        need = {g: 0.0 for g in goods}
        for slots in need_c:
            for _, _, d in slots:
                for g, q in d.items():
                    need[g] += q
        D_pre = {b: w.R_pre[m, b] + craft_in_b[b] for b in (0, 1)}
        P_eff = {b: inp["peff_u"][m, b] * PLAYER_CAP * D_pre[b] for b in (0, 1)}
        D = {b: max(0.0, D_pre[b] + P_eff[b]) for b in (0, 1)}
        rest = {b: D[b] - craft_in_b[b] for b in (0, 1)}
        if var.clamp_rest:
            rest = {b: max(0.0, r) for b, r in rest.items()}
        vsh = {b: sum(v[g] for g in goods if shelved[m, g] and band[g] == b) for b in (0, 1)}
        Dg = {}
        for g in goods:
            if not shelved[m, g]:
                Dg[g] = 0.0
            else:
                Dg[g] = need[g] + (v[g] / vsh[band[g]] * rest[band[g]] if vsh[band[g]] > 0 else 0.0)
        fills = []
        for slots in need_c:
            fc = 1.0
            for t, x, d in slots:
                if t == "n":
                    g = x
                    f = 0.0 if not shelved[m, g] else (1.0 if Dg[g] == 0 else min(1.0, avail[g] / Dg[g]))
                else:
                    sh = [g for g in x if shelved[m, g]]
                    if not sh:
                        f = 0.0
                    else:
                        sd = sum(Dg[g] for g in sh)
                        f = 1.0 if sd == 0 else min(1.0, sum(avail[g] for g in sh) / sd)
                fc = min(fc, f)
            fills.append(fc)

        def draws(fl):
            cd = {g: 0.0 for g in goods}
            for slots, fc in zip(need_c, fl):
                for _, _, d in slots:
                    for g, q in d.items():
                        cd[g] += q * fc
            return cd

        cd_raw = draws(fills)
        # draw scale (Formula F, design-review 10)
        scaled = []
        for slots, fc in zip(need_c, fills):
            mult = 1.0
            for _, _, d in slots:
                for g, q in d.items():
                    if q > 0 and cd_raw[g] > 0:
                        mult = min(mult, min(1.0, avail[g] / cd_raw[g]))
            scaled.append(fc * mult)
        cd = draws(scaled)
        for g in goods:
            if cd[g] > avail[g] + TOL * max(1.0, v[g]):
                fail("I1 cd <= v_g - buy_pl", f"good {g} cd {cd[g]:.4f} > {avail[g]:.4f}")
            if cd[g] < -TOL:
                fail("I1b cd >= 0", f"good {g} cd {cd[g]:.4f}")
            if not shelved[m, g] and (cd[g] != 0 or buy[g] != 0):
                fail("I6a unshelved: no cd or buy", f"good {g}")
        for fc in scaled:
            if not (0.0 <= fc <= 1.0):
                fail("I1c 0 <= fill_c <= 1", f"fill {fc}")
        X_pre = {g: v[g] - cd[g] - buy[g] for g in goods}
        st[m] = dict(v=v, buy=buy, cd=cd, X_pre=X_pre, D=D, rest=rest, fills=scaled, craft_in_b=craft_in_b)

    # ---- step (d): link flows, in link-id order (independent of market order) -------------------------------
    avail_A = {}
    for m in w.markets:
        for b in (0, 1):
            sx = sum(st[m]["X_pre"][g] for g in goods if shelved[m, g] and band[g] == b)
            avail_A[m, b] = max(0.0, sx - max(0.0, st[m]["D"][b] - st[m]["craft_in_b"][b]))
    exp_g = {(m, g): 0.0 for m in w.markets for g in goods}
    imp_g = {(m, g): 0.0 for m in w.markets for g in goods}
    for lid, a, b_m, k, qreq in sorted(inp["links"]):
        Q = min(qreq, avail_A[a, k])
        avail_A[a, k] -= Q
        sx = sum(st[a]["X_pre"][g] for g in goods if shelved[a, g] and band[g] == k)
        if Q <= 0 or sx <= 0:
            continue
        for g in goods:
            if shelved[a, g] and band[g] == k:
                q = Q * st[a]["X_pre"][g] / sx
                exp_g[a, g] += q
                imp_g[b_m, g] += q
    # world link conservation, good by good
    for g in goods:
        e = sum(exp_g[m, g] for m in w.markets)
        i = sum(imp_g[m, g] for m in w.markets)
        if abs(e - i) > TOL * max(1.0, e):
            fail("I4 link conservation per good", f"good {g} exp {e} imp {i}")

    # ---- step (e): composition --------------------------------------------------------------------------------
    newX = {}
    for m in order:
        s = st[m]
        X = {}
        for g in goods:
            X0 = Xprev[m, g] + inp["S"][m, g] + imp_g[m, g] + inp["sell"][m, g]
            raw = X0 - s["cd"][g] - s["buy"][g]
            if raw < -TOL * max(1.0, X0):
                fail("I2 max(0) in X never acts", f"good {g} X0-cd-buy {raw:.4f}")
            X[g] = max(0.0, raw)
        # exports first, exactly Exp * ex per good
        for g in goods:
            if exp_g[m, g] > X[g] + TOL * max(1.0, X[g]):
                fail("I3 export <= X per good", f"good {g} exp {exp_g[m, g]:.4f} X {X[g]:.4f}")
            X[g] -= exp_g[m, g]
        shared = {}
        for b in (0, 1):
            shg = [g for g in goods if shelved[m, g] and band[g] == b]
            sx = sum(X[g] for g in shg)
            stock_sh_pre = sx
            Dt = s["D"][b]
            spoil = DK_RAW * sx
            dem = s["rest"][b]
            over = max(0.0, stock_sh_pre - S_CAP * max(Dt, 1.0))
            want = spoil + dem + over
            tot = min(want, sx)
            if tot < -TOL:
                fail("I7 shared draw >= 0", f"band {b} draw {tot:.4f} (rest demand {dem:.4f})")
            for g in shg:
                shared[g] = tot * X[g] / sx if sx > 0 else 0.0
        before_dust = {}
        for g in goods:
            X[g] -= shared.get(g, 0.0)
            if var.round_guard and X[g] < 0:
                if X[g] < -TOL * max(1.0, Xprev[m, g] + inp['S'][m, g] + imp_g[m, g] + inp['sell'][m, g]):
                    fail('I5c rounding guard only trims rounding', f'good {g} X {X[g]}')
                X[g] = 0.0
            before_dust[g] = X[g]
            inflow = inp["S"][m, g] + imp_g[m, g] + inp["sell"][m, g]
            if inflow == 0 and X[g] < DUST * V[g]:
                X[g] = 0.0
            if X[g] < -TOL * max(1.0, Xprev[m, g]):
                fail("I5b X' >= 0", "I5c rounding guard only trims rounding", f"good {g} X' {X[g]:.4f}")
        # ledger per good
        for g in goods:
            dust = before_dust[g] - X[g]
            lhs = X[g]
            rhs = (Xprev[m, g] + inp["S"][m, g] + inp["sell"][m, g] + imp_g[m, g]
                   - s["cd"][g] - s["buy"][g] - exp_g[m, g] - shared.get(g, 0.0) - dust)
            if abs(lhs - rhs) > TOL * max(1.0, abs(rhs), Xprev[m, g]):
                fail("I5 per-good ledger", f"good {g} X' {lhs} vs {rhs}")
            if not shelved[m, g]:
                X0 = Xprev[m, g] + inp["S"][m, g] + imp_g[m, g] + inp["sell"][m, g]
                if X[g] != X0 and X[g] != 0.0:
                    fail("I6 unshelved good untouched", f"good {g} X0 {X0} X' {X[g]}")
        # shares
        for b in (0, 1):
            bg = [g for g in goods if band[g] == b]
            tot = sum(X[g] for g in bg)
            if tot > 0:
                ssum = sum(X[g] / tot for g in bg)
                if abs(ssum - 1.0) > 1e-9:
                    fail("I8 shares sum to 1", f"band {b} sum {ssum}")
        for g in goods:
            newX[m, g] = X[g]

    # ---- step (e) continued: Formula D after every market's B -------------------------------------------------
    sum_order = sorted(w.markets) if var.sorted_sums else order
    sf_out = {}
    for b in (0, 1):
        bg = [g for g in goods if band[g] == b]
        world_tot = 0.0
        for m in sum_order:
            for g in bg:
                world_tot += newX[m, g]
        wsh = {}
        for g in bg:
            acc = 0.0
            for m in sum_order:
                acc += newX[m, g]
            wsh[g] = acc / world_tot if world_tot > 0 else 0.0
        for m in sum_order:
            tot = sum(newX[m, g] for g in bg)
            shelf = [g for g in bg if newX[m, g] >= V[g]]
            stock_sh = sum(newX[m, g] for g in shelf)
            raw = {}
            for g in bg:
                sh = newX[m, g] / tot if tot > 0 else 0.0
                wg = max(wsh[g], WSH_MIN)
                base = (sh + SIGMA * wg) / ((1 + SIGMA) * wg)
                if base <= 0:
                    fail("I10c sf base > 0 (share >= 0)", f"good {g} share {sh} X' {newX[m, g]} wsh {wsh[g]}")
                    raw[g] = float("nan")
                    continue
                raw[g] = base ** (-ETA)
            if stock_sh > 0:
                norm = sum(newX[m, g] / stock_sh * raw[g] for g in shelf)
                for g in bg:
                    sf_out[m, g] = raw[g] / norm
                mean = sum(newX[m, g] / stock_sh * sf_out[m, g] for g in shelf)
                if abs(mean - 1.0) > 1e-9:
                    fail("I10 sf shelved mean = 1", f"mean {mean}")
            else:
                for g in bg:
                    sf_out[m, g] = raw[g]
            for g in bg:
                if not math.isfinite(sf_out[m, g]) or sf_out[m, g] <= 0:
                    fail("I10b sf finite and > 0", f"sf {sf_out[m, g]}")

    # ---- step (f): plan update --------------------------------------------------------------------------------
    for m in order:
        for ci, c in enumerate(w.classes[m]):
            P_c, P_in, cover = inp["P"][m, ci]
            plan, ref = c["plan"], c["plan_ref"]
            r = P_c / P_in
            pstar = ref * r ** KAPPA * (C_REF / max(cover, C_LO)) ** LAMBDA
            ph = max(plan, PHI_P * ref)
            new = min(max(ph * (pstar / ph) ** ALPHA_P, ph / DELTA_P), ph * DELTA_P)
            fc = st[m]["fills"][ci]
            if fc < FILL_TOL:
                new = min(new, plan)
            if not math.isfinite(new) or new < 0:
                fail("I11 plan finite and >= 0", f"plan {new}")
            if fc < FILL_TOL and new > plan + TOL:
                fail("I11b no windup", f"fill {fc} plan {plan} -> {new}")
            c["plan_next"] = new
            w.fill_prev[m, ci] = fc
    for m in w.markets:
        for c in w.classes[m]:
            c["plan"] = c.pop("plan_next")
    w.X = newX
    return newX, sf_out


def clone(w: World) -> World:
    import copy
    return copy.deepcopy(w)


def run(variant: Variant, worlds: int, seasons: int, seed: int):
    fails = {}
    order_mismatch = [0, None]
    for wi in range(worlds):
        rng = random.Random(seed * 1_000_003 + wi)
        base = make_world(rng)
        inputs = [season_inputs(base, rng) for _ in range(seasons)]
        # main run in id order, invariants checked
        w = clone(base)
        for si, inp in enumerate(inputs):
            tick(w, inp, list(w.markets), variant, fails, f"world {wi} season {si + 1}")
        ref = (dict(w.X), [c["plan"] for m in w.markets for c in w.classes[m]])
        # order independence: the other 5 processing orders, final state bit-identical (AC-TG-11)
        for perm in itertools.permutations(base.markets):
            if list(perm) == list(base.markets):
                continue
            w2 = clone(base)
            sfs = None
            for inp in inputs:
                _, sfs = tick(w2, inp, list(perm), variant, {}, "")
            got = (dict(w2.X), [c["plan"] for m in w2.markets for c in w2.classes[m]])
            if got != ref:
                order_mismatch[0] += 1
                if order_mismatch[1] is None:
                    order_mismatch[1] = f"world {wi}, order {perm}"
                break
        # sf bit-identity: compare last season's sf across orders
        w3, w4 = clone(base), clone(base)
        sf3 = sf4 = None
        for inp in inputs:
            _, sf3 = tick(w3, inp, [0, 1, 2], variant, {}, "")
            _, sf4 = tick(w4, inp, [2, 1, 0], variant, {}, "")
        if sf3 != sf4:
            fails.setdefault("I9b sf bit-identical across orders", [0, None])
            fails["I9b sf bit-identical across orders"][0] += 1
            if fails["I9b sf bit-identical across orders"][1] is None:
                diff = max(abs(sf3[k] - sf4[k]) for k in sf3)
                fails["I9b sf bit-identical across orders"][1] = f"world {wi}: max sf difference {diff:.3e}"
    if order_mismatch[0]:
        fails["I9 state bit-identical across orders"] = order_mismatch
    return fails


INVARIANTS = [
    "I1 cd <= v_g - buy_pl", "I1b cd >= 0", "I1c 0 <= fill_c <= 1", "I2 max(0) in X never acts",
    "I3 export <= X per good", "I4 link conservation per good", "I5 per-good ledger", "I5b X' >= 0",
    "I6 unshelved good untouched", "I6a unshelved: no cd or buy", "I7 shared draw >= 0", "I8 shares sum to 1",
    "I9 state bit-identical across orders", "I9b sf bit-identical across orders", "I10 sf shelved mean = 1",
    "I10b sf finite and > 0", "I10c sf base > 0 (share >= 0)", "I11 plan finite and >= 0", "I11b no windup",
]


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--worlds", type=int, default=300)
    ap.add_argument("--seasons", type=int, default=40)
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--variant", choices=["doc", "fixed", "all"], default="all")
    a = ap.parse_args()
    variants = {
        "doc": Variant("as written (rest = D - craft_in unclamped in D_g and the shared draw; world sums in processing order)", False, False),
        "fixed": Variant("candidate fixes (rest clamped at 0; world sums in market-id order; X' floored at 0 after the draw)", True, True, True),
    }
    chosen = list(variants) if a.variant == "all" else [a.variant]
    print(f"{a.worlds} worlds x {a.seasons} seasons, 3 markets, seed {a.seed}")
    for key in chosen:
        var = variants[key]
        fails = run(var, a.worlds, a.seasons, a.seed)
        print(f"\n[{key}] {var.name}")
        for inv in INVARIANTS:
            n, ex = fails.get(inv, [0, None])
            print(f"  {inv:40s} {'ok' if n == 0 else f'FAILED {n}x'}" + (f"  first: {ex}" if ex else ""))


if __name__ == "__main__":
    main()
