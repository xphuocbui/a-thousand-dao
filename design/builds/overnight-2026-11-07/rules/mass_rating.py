"""Combat rule 17 and Formulas K: the rating clash, which fight_calc.py does not have.

Asked for with "rules": ["mass_rating"] and a "mass" block. It prints after the layer report,
once per run, and does not touch the duel. `--without KEY` removes a top-level key, so each
command modifier below is its own top-level key and can be taken out alone. The closing line
is written as `end_state\tmass ...` so a removal shows in the campaign's identity test.

"mass": {
  "own":   [{"count": 1, "profile": "self", "leader": true},
            {"count": 12, "profile": "typical", "realm": "truc_co"},
            {"count": 200, "profile": "file:sheets/long-carry.fight.json"},
            {"count": 20000, "profile": "levy"}],
  "enemy": [{"count": 12, "profile": "top_end", "realm": "ket_dan", "leader": true}],
  "own_fortune": 50, "enemy_fortune": 50, "own_pi_s": 0, "enemy_pi_s": 0
}

Member profiles: "self" is this build, "typical" and "top_end" are the fixtures at "realm",
"file:PATH" is another fight file (its conditional_mods are not counted: Formulas K has no
term for a condition), "spec" reads an inline "spec", "levy" is a mortal (see LEVY).
Force numbers follow Formulas K literally:
  N_eff = min(N, mass_width) + mass_reserve_weight * max(0, N - mass_width), members ranked
  by display_power. Off, health and linh luc are weighted means x N_eff, which is the
  weighted sum. pass, drain, f and evade are weighted means. g and fortune are the leader's.
Where the GDD is silent this file states a choice, and prints it as `mass_assumption`:
  - net_spend is summed like linh luc, because a force's pool is. The GDD does not say.
  - uptime_a comes from a mirror fight of that profile: firings / ready moments, and 1 if the
    mirror ends before the art is ready. The GDD gives no procedure.
  - a per_pulse ward has no drain term in t_w; its upkeep goes into net_spend. The GDD does
    not say. An off ward has pass 1 and drain 0.
  - D_late is the attacker's basic-only D once its own pool is out by the defender's t_w,
    else D. The GDD's AC-CB-49 example gives 7.77 where this literal reading gives 7.98.
  - pi_s is not scaled by numbers: "own_pi_s" and "enemy_pi_s" go straight into
    T = T0 / (1 + pi_s * T0), at most soul_cap / soul_lockout. The GDD does not say whether a
    force's pi_s is a mean, a sum or its leader's. Left at 0 unless a file says otherwise.

Command modifiers (all proposals, each a top-level key on the build, so --without takes one out):
  "census": true         the Census: rows with profile "levy" count. Without it they are dropped.
  "levy_arms": {"c": 1.3, "layers": [0, 50, 40, 0, 0]}  what a levy carries: its basic coefficient
                         and its layer points. A mortal has no tree, so L1 stays 0.
  "field_array": p       L4 points for every member of this force, from the leader's formation.
  "given_to_ranks": p    the L1 points the leader has handed down: L4 points for every member of
                         this force. The leader's own L1 in "layers" is already the reduced one.
  "rotating_ranks": x    adds x to mass_reserve_weight for this force.
  "wide_front": n        adds n to mass_width for this force.
  "indemnity": {"pass": {"body": 0.4, "qi": 0.3}, "premium": 1.0, "chest": 200000}
                         Indemnity Ward on the levy: no linh luc, paid in stones. `premium` stones
                         per levy member per second; when `chest` is spent the ward is down, which
                         the formula's t_w carries.
  "standing_ground": {"caps": {"2": 40, "3": 40, "5": 10}, "foreign_l4": 20}
                         a Ground Law on the field: caps bind both forces, foreign_l4 binds the enemy.
"""
import copy
import json
import os

MASS_WIDTH, RESERVE, KAPPA_MASS = 12, 0.25, 4.0
FORTUNE_PER = 0.001
LEVY = {"name": "levy", "realm": 0, "n_body": 0.25, "n_qi": 0.25, "ward": {"model": "off"},
        "levy": True, "levy_unit": 0.398}  # U of a B_p 10 "realm": 10 ** 0.4 / 6.31, a first guess
HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def install(f):
    report0 = f.report_layers

    def realm_of(r):
        return r if isinstance(r, int) else f.REALMS.index(r)

    def uptimes(spec):
        s = copy.deepcopy(spec)
        for k in ("conditional_mods", "rules", "mass", "enemy_overrides", "called_blow", "presence"):
            s.pop(k, None)
        res = f.run_fight(s, copy.deepcopy(s))
        t = res["t"] * 1000
        out = {}
        for a in res["a"].arts:
            ready = t / a["cd_ms"]
            out[a["id"]] = 1.0 if ready < 1 else min(1.0, len(a["fired"]) / ready)
        return out

    def capped(x, caps):
        x = list(x)
        for k, v in (caps or {}).items():
            x[int(k) - 1] = min(x[int(k) - 1], v)
        return x

    def member(spec, caps=None, ward=None, l4=0, l4_cap=None):
        spec = copy.deepcopy(spec)
        if ward:
            spec["ward"] = ward
        s = f.Side(spec, "m")
        s.x[3] += l4
        if l4_cap is not None:
            s.x[3] = min(s.x[3], l4_cap)
        unit = spec.get("levy_unit", 1.0)
        base = s.u * s.stage * unit * s.crit_ev

        def m(extra):
            x = list(s.x)
            for i, v in enumerate(extra or []):
                x[i] += v
            return f.multiplier(capped(x, caps))

        c_b = s.basic.get("c", f.K["basic_coef"]) / f.K["basic_cooldown"]
        off_basic = base * c_b * m(s.basic.get("x"))
        up = uptimes(spec) if s.arts else {}
        off, spend, kinds = off_basic, 0.0, {"body": off_basic if s.basic.get("kind", "body") == "body" else 0.0,
                                             "qi": off_basic if s.basic.get("kind") == "qi" else 0.0}
        for a in s.arts:
            cd = a["cd_ms"] / 1000.0
            spend += a.get("cost_share", 0) * (1 - s.cost_red) * s.qi_max * up[a["id"]] / cd
            if a.get("c_art", 0) <= 0:
                continue
            part = base * a["c_art"] * up[a["id"]] / cd * m(a.get("x"))
            off += part
            kinds[a.get("kind", "body")] = kinds.get(a.get("kind", "body"), 0.0) + part
        qi = 0.0 if spec.get("levy") else s.qi_max
        health = s.health_max * unit
        model = s.ward.get("model", "drain")
        terms = [s.ward_terms(k) for k in ("body", "qi")]
        if terms[0] is None:
            p, dr = 1.0, 0.0
        else:
            p = (terms[0][1] + terms[1][1]) / 2
            dr = (terms[0][2] + terms[1][2]) / 2 if model in ("drain", "default") else 0.0
        spend -= qi * s.regen
        if model == "per_pulse":
            we = s.ward.get("we", 0)
            spend += s.ward["upkeep_share"] * (1 - we / (100.0 + we)) * s.qi_max
        fb, fq = s.guard_factor("body"), s.guard_factor("qi")
        ehp = min(health / (p * fb), health / fb + (qi / dr if dr else 0.0)) if p < 1 else health / fb
        unbuilt = f.Side({"realm": s.r, "ward": {"model": "default"}}, "u")
        ut = unbuilt.ward_terms("body")
        f_un = unbuilt.u * min(unbuilt.health_max / (ut[1] * unbuilt.guard_factor("body")),
                               unbuilt.health_max / unbuilt.guard_factor("body") + unbuilt.qi_max / ut[2])
        return {"off": off, "off_basic": off_basic, "health": health, "qi": qi, "pass": p, "drain": dr,
                "fb": fb, "fq": fq, "net": spend, "evade": s.evade, "kinds": kinds, "pierce": s.pierce,
                "uptime": up, "r": s.r, "power": f.K["power_base"][s.r] * ((off * ehp) / f_un) ** 0.5,
                "levy": bool(spec.get("levy"))}

    def expand(row, build, caps, side):
        p = row.get("profile", "typical")
        ward = None
        if p == "self":
            spec = build
        elif p == "levy":
            spec = copy.deepcopy(LEVY)
            spec.update(row.get("levy", {}))
            arms = build.get("levy_arms")
            if arms and side == "own":
                spec["layers"] = list(arms.get("layers", [0] * 5))
                spec["basic"] = {"c": arms.get("c", 1.0), "kind": "body"}
            ind = build.get("indemnity")
            if ind and side == "own":
                ward = {"model": "per_pulse", "pass": ind["pass"], "upkeep_share": 0.0}
        elif p == "spec":
            spec = row["spec"]
        elif p.startswith("file:"):
            with open(os.path.join(HERE, p[5:]), encoding="utf-8") as h:
                spec = json.load(h)
        else:
            spec = {"typical": f.typical, "top_end": f.top_end}[p](realm_of(row["realm"]))
        if "over" in row:
            spec = f.merge(spec, row["over"])
        ground = build.get("standing_ground") or {}
        lent = build.get("field_array", 0) + build.get("given_to_ranks", 0)
        return member(spec, caps, ward, lent if side == "own" else 0,
                      ground.get("foreign_l4") if side == "enemy" else None)

    def force(rows, build, side, caps):
        width = MASS_WIDTH + (build.get("wide_front", 0) if side == "own" else 0)
        reserve = RESERVE + (build.get("rotating_ranks", 0) if side == "own" else 0)
        groups, leader = [], None
        for row in rows:
            if row.get("profile") == "levy" and side == "own" and not build.get("census"):
                continue
            g = expand(row, build, caps, side)
            g["count"], g["label"] = row["count"], row.get("label", row.get("profile"))
            groups.append(g)
            if row.get("leader"):
                leader = g
        groups.sort(key=lambda g: -g["power"])
        left, total = width, {"n_eff": 0.0, "n": 0}
        acc = dict.fromkeys(("off", "off_basic", "health", "qi", "net", "pass", "drain", "fb", "fq", "evade"), 0.0)
        kinds = {"body": 0.0, "qi": 0.0}
        for g in groups:
            front = min(g["count"], left)
            left -= front
            w = front + reserve * (g["count"] - front)
            g["w"] = w
            total["n_eff"] += w
            total["n"] += g["count"]
            for k in acc:
                acc[k] += w * g[k]
            for k in kinds:
                kinds[k] += w * g["kinds"].get(k, 0.0)
        n = total["n_eff"]
        for k in ("pass", "drain", "fb", "fq", "evade"):
            acc[k] /= n
        acc.update(total)
        acc["kinds"] = kinds
        acc["r"] = (leader or groups[0])["r"]
        acc["pierce"] = (leader or groups[0])["pierce"]
        acc["groups"] = groups
        ind = build.get("indemnity")
        levy = sum(g["count"] for g in groups if g["levy"])
        if ind and side == "own" and levy:
            acc["clock"] = ind["chest"] / (ind["premium"] * levy)
        return acc

    def time_to_beat(a, b):
        """T_(a -> b). Returns T0 and its parts."""
        g = max(0, b["r"] - a["r"])
        s = f.supp(g, a["pierce"])
        ka = a["kinds"]
        share_b = ka["body"] / max(ka["body"] + ka["qi"], 1e-9)
        fac = share_b * b["fb"] + (1 - share_b) * b["fq"]
        d = a["off"] * (1 - min(b["evade"], f.K["evade_cap"])) * s
        den = d * (1 - b["pass"]) * b["drain"] + b["net"]
        t_h = b["health"] / (d * b["pass"] * fac)
        if "clock" in b:
            t_w = b["clock"]
        elif b["qi"] <= 0:
            t_w = 0.0
        else:
            t_w = b["qi"] / den if den > 0 else float("inf")
        if t_h <= t_w:
            return t_h, t_w, t_h, d, s
        d_late = a.get("late_d", d)
        rest = b["health"] - t_w * d * b["pass"] * fac
        return t_w + rest / (d_late * fac), t_w, t_h, d, s

    def clash(own, enemy, fa, fb):
        for a, b in ((own, enemy), (enemy, own)):
            t0, t_w, t_h, d, s = time_to_beat(b, a)
            # the side that is the target here runs dry at t_w; if the attacker ran dry first its
            # late fire is its basic attack alone (Formulas K, D_late)
            a["t_w_self"] = t_w
        for a, b in ((own, enemy), (enemy, own)):
            own_dry = a["t_w_self"]
            t_w_b = b["t_w_self"]
            a["late_d"] = None
            if own_dry < t_w_b:
                g = max(0, b["r"] - a["r"])
                a["late_d"] = a["off_basic"] * (1 - min(b["evade"], f.K["evade_cap"])) * f.supp(g, a["pierce"])
        for a in (own, enemy):
            if a["late_d"] is None:
                a.pop("late_d")
        t_oe = time_to_beat(own, enemy)
        t_eo = time_to_beat(enemy, own)
        cap = f.K["soul_cap"] / f.K["soul_lockout"]
        t_a = t_oe[0] / (1 + min(own.get("pi_s", 0), cap) * t_oe[0])
        t_b = t_eo[0] / (1 + min(enemy.get("pi_s", 0), cap) * t_eo[0])
        r = t_b / t_a
        p = 1.0 / (1.0 + r ** (-KAPPA_MASS)) + (fa - fb) * FORTUNE_PER
        return t_oe, t_eo, r, max(0.02, min(0.98, p))

    def show(tag, fo):
        print("mass_force\t%s\tN %d\tN_eff %.2f\tOff %.1f\thealth %.0f\tlinh_luc %.0f\tpass %.3f\tdrain %.3f\tf %.3f/%.3f\tnet_spend %.1f\trealm %s" % (
            tag, fo["n"], fo["n_eff"], fo["off"], fo["health"], fo["qi"], fo["pass"], fo["drain"], fo["fb"], fo["fq"],
            fo["net"], f.REALM_NAMES[fo["r"]]))
        for g in fo["groups"]:
            print("mass_member\t%s\t%s\tcount %d\tweight %.2f\tOff %.1f\thealth %.0f\tlinh_luc %.0f\tpass %.3f\tdrain %.3f\tnet %.1f\tpower %.0f\tuptime %s" % (
                tag, g["label"], g["count"], g["w"], g["off"], g["health"], g["qi"], g["pass"], g["drain"], g["net"], g["power"],
                {k: round(v, 2) for k, v in g["uptime"].items()}))

    def selftest():
        """AC-CB-49 and AC-CB-50, by hand through the same clamps."""
        d, p, dr, fa, h, q, net = 36.51, 0.344, 0.956, 0.932, 109.87, 172.74, 6.91
        t_w, t_h = q / (d * (1 - p) * dr + net), h / (d * p * fa)
        late = 6.3096 * 3.27279
        t0 = t_w + (h - t_w * d * p * fa) / (late * fa)
        n = lambda v: min(v, MASS_WIDTH) + RESERVE * max(0, v - MASS_WIDTH)
        r = (n(40) / n(20)) ** 2
        print("mass_selftest	t_w %.2f (5.80)	t_h %.2f (9.39)	T0 %.2f (7.77; see D_late above)	N_eff %g, %g (19, 14)	R %.2f (1.84)	P %.3f (0.920)" % (
            t_w, t_h, t0, n(40), n(20), r, 1 / (1 + r ** -KAPPA_MASS)))

    def report(build):
        report0(build)
        mass = build.get("mass")
        if not mass:
            return
        selftest()
        caps = (build.get("standing_ground") or {}).get("caps")
        own = force(mass["own"], build, "own", caps)
        enemy = force(mass["enemy"], build, "enemy", caps)
        fa, fb = mass.get("own_fortune", 50), mass.get("enemy_fortune", 50)
        own["pi_s"], enemy["pi_s"] = mass.get("own_pi_s", 0), mass.get("enemy_pi_s", 0)
        t_oe, t_eo, r, p = clash(own, enemy, fa, fb)
        show("own", own)
        show("enemy", enemy)
        print("mass_times\town_beats_enemy T0 %.2f (t_w %.2f, t_h %.2f, D %.1f, supp %.2f)\tenemy_beats_own T0 %.2f (t_w %.2f, t_h %.2f, D %.1f, supp %.2f)" % (
            t_oe + t_eo))
        print("mass_assumption\tnet_spend summed; uptime from mirror fights; per_pulse has no drain term; pi_s 0; kappa_mass %g" % KAPPA_MASS)
        print("end_state\tmass R %.3f\tP(own force wins) %.3f" % (r, p))

    f.report_layers = report
