#!/usr/bin/env python3
"""fight_calc.py: walks a design-build build through Combat's timeline.

EMITS OBSERVATIONS, NOT A VERDICT (CLAUDE.md, "Helpers in .claude/scripts/").
It prints what happened second by second, which caps clipped and what it could
not model. Whether that is good enough is the skill's call.

It implements Combat rule 10 and Formulas A to H as a paper model, because the
full fight is on hold and no engine code exists to run. It is not the game:
  - crit, evade and every chance below 100 % are EXPECTED VALUES, so a run is
    deterministic and has no seed
  - anything a build lists under "unmodelled" is not simulated and is printed
    back, so a result never looks more complete than it is
  - constants come from fight-constants.json, checked against combat.md

Usage:
  python fight_calc.py --selftest             replay the GDD's own fixtures
  python fight_calc.py --constants            check constants against combat.md
  python fight_calc.py BUILD.json             build vs its "enemy" (default typical)
  python fight_calc.py BUILD.json --matrix    vs typical and top_end, same realm
                                              and one and two realms up
  python fight_calc.py BUILD.json --enemy top_end --gap 1 --timeline
  python fight_calc.py BUILD.json --without "On the Beat"
                                              the same fight with one piece removed:
                                              a conditional_mods id, an art id, or a
                                              top-level key such as tick_overflow_qi
Exit codes: 0 ran; 1 a selftest case failed; 2 bad input.
"""
import argparse
import copy
import json
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REALMS = ["luyen_khi", "truc_co", "ket_dan", "nguyen_anh", "hoa_than"]
REALM_NAMES = ["Qi Refining", "Foundation Establishment", "Core Formation",
               "Nascent Soul", "Deity Transformation"]


def load_constants():
    with open(os.path.join(HERE, "fight-constants.json"), encoding="utf-8") as f:
        raw = json.load(f)["constants"]
    return {k: v["value"] for k, v in raw.items()}, raw


K, K_RAW = load_constants()


def check_constants():
    """Prints one CONSTANT_DRIFT line per anchor combat.md no longer holds."""
    root = HERE
    for _ in range(6):
        root = os.path.dirname(root)
        path = os.path.join(root, "design", "gdd", "combat.md")
        if os.path.exists(path):
            break
    else:
        print("CONSTANTS_NOT_CHECKED combat.md not found")
        return False
    with open(path, encoding="utf-8") as f:
        text = f.read()
    missing = [k for k, v in K_RAW.items() if v["anchor"] not in text]
    for k in missing:
        print("CONSTANT_DRIFT\t%s\tanchor not in combat.md: %s" % (k, K_RAW[k]["anchor"]))
    print("constants_verified\t%d/%d" % (len(K_RAW) - len(missing), len(K_RAW)))
    return not missing


def ms(seconds):
    return int(math.floor(seconds * 1000 + 0.5))


def fight_unit(r):
    return K["power_base"][r] ** K["fight_unit_exponent"]


def layer_values(x):
    """Formulas B. Returns the five layer totals for points x1..x5."""
    x1 = x[0]
    start, slope = K["l1_soft_start"], K["l1_soft_slope"]
    eff = x1 if x1 <= start else start + slope * (x1 - start)
    out = [max(0.1, 1 + min(eff, K["layer_caps"][0]) / 100.0)]
    for i in range(1, 5):
        out.append(1 + min(max(x[i], 0), K["layer_caps"][i]) / 100.0)
    return out


def multiplier(x, skip_l5=False):
    v = layer_values(x)
    if skip_l5:
        v[4] = 1.0
    return v[0] * v[1] * v[2] * v[3] * v[4]


def art_lint_max(cost_share, cooldown):
    return (K["basic_coef"] * (1 + K["art_coef_per_cost"] * cost_share)
            + K["art_coef_per_cooldown"] * (cooldown - 1))


def supp(gap, pierce_pct):
    p = min(K["pierce_cap"], pierce_pct / 100.0)
    return 1 - K["suppression"][max(0, min(gap, 4))] * (1 - p)


def soul_share(att_sense, def_sense, soul_res_pct, soul_pct, x_soul, s=1.0):
    rho = att_sense / (def_sense * (1 + soul_res_pct / 100.0))
    if rho < K["rho_min"]:
        return 0.0
    return min(soul_pct * (1 + x_soul / 100.0) * rho ** K["soul_beta"] * s, K["soul_cap"])


class Side:
    """A compiled profile plus its live state in one fight."""

    def __init__(self, spec, name):
        d = spec
        self.spec = d
        self.name = d.get("name", name)
        self.r = d["realm"] if isinstance(d["realm"], int) else REALMS.index(d["realm"])
        self.stage = d.get("stage", 1.0)
        self.u = fight_unit(self.r)
        boss = d.get("boss_pool_mult", 1.0)
        self.boss = boss
        self.n_body = d.get("n_body", 1.0)
        self.n_qi = d.get("n_qi", 1.0)
        self.health_max = K["health_units"] * self.u * self.n_body * boss
        self.qi_max = K["qi_units"] * self.u * self.n_qi * boss
        self.health = self.health_max * d.get("start_health", 1.0)
        self.qi_cap = self.qi_max * (1 - d.get("reserve_share", 0.0))
        self.qi = min(self.qi_cap, self.qi_max * d.get("start_qi", 1.0))
        self.x = list(d.get("layers", [0, 0, 0, 0, 0]))
        crit = d.get("crit", {})
        self.crit_ev = 1 + min(crit.get("chance", 0), K["crit_chance_cap"]) * (
            min(crit.get("mult", 1.5), K["crit_mult_cap"]) - 1)
        self.art_speed = d.get("art_speed_pct", 0)
        self.cost_red = min(d.get("art_cost_pct", 0) / 100.0, 0.5)
        self.regen = min(K["regen_base"] + d.get("regen_bonus_pct", 0) / 100.0, K["regen_cap"])
        self.pierce = d.get("pierce_pct", 0)
        self.evade = d.get("evade_pct", 0) / 100.0
        self.accuracy = d.get("accuracy_pct", 0) / 100.0
        self.ward = d.get("ward", {"model": "default"})
        g = d.get("guard", {})
        self.a_b, self.t_b, self.bg_pct = g.get("a_b", 0), g.get("t_b", 0), g.get("body_guard_pct", 0)
        self.sense = d.get("divine_sense", 1.0)
        self.soul_res = d.get("soul_res_pct", 0)
        self.x_soul = d.get("x_soul", 0)
        self.basic = d.get("basic", {"c": K["basic_coef"], "kind": "body"})
        self.companion = d.get("companion")
        self.conditionals = d.get("conditional_mods", [])
        self.triggers = d.get("triggers", [])
        self.arts = []
        for a in d.get("arts", []):
            art = dict(a)
            cd = max(K["cooldown_min"], a["cooldown"] / (1 + self.art_speed / 100.0))
            art["cd_ms"] = ms(cd)
            art["ready"] = art["cd_ms"]
            art["fired"] = []
            art["stock_left"] = a.get("stock")
            self.arts.append(art)
        self.statuses = []
        self.curses = []
        self.ward_paid = True
        self.lock_until = 0
        self.basic_next = ms(K["basic_cooldown"]) if self.basic else None
        self.comp_next = ms(K["basic_cooldown"]) if self.companion else None
        self.trig_count = 0
        self.direct = 0.0
        self.trig_dmg = 0.0
        self.dmg = {}
        self.qi_drained_by_me = 0.0
        self.notes = {}
        self.dry_at = None
        self.dmg_taken_instant = 0.0
        self.health_at_instant = self.health

    def note(self, key):
        self.notes[key] = self.notes.get(key, 0) + 1

    def curse_sum(self, key):
        return sum(c.get(key, 0) for c in self.curses)

    def guard_mitigation(self):
        shred = min(self.curse_sum("shred"), K["curse_shred_max"])
        g = (K["guard_base"] + self.a_b + self.t_b + K["guard_pool_slope"] * (self.n_body - 1)) \
            * (1 + self.bg_pct / 100.0) * (1 - shred)
        g = min(K["guard_cap"], g)
        return K["guard_max_mit"] * g / (g + K["guard_half"])

    def guard_factor(self, kind):
        share = K["guard_share_body"] if kind == "body" else K["guard_share_qi"]
        return 1 - self.guard_mitigation() * share

    def ward_terms(self, kind):
        w = self.ward
        model = w.get("model", "drain")
        if model == "off":
            return None
        if model == "default":
            p_raw, d_raw, ws, we = K["default_ward_pass"], K["default_ward_drain"], 0, 0
            ws = w.get("ws", 0)
            we = w.get("we", 0)
        else:
            p_raw = w["pass"][kind] if isinstance(w["pass"], dict) else w["pass"]
            d_raw = (w["drain"][kind] if isinstance(w.get("drain"), dict) else w.get("drain", 1.0))
            ws, we = w.get("ws", 0), w.get("we", 0)
        ws = max(K["ward_floor"], min(ws, K["ward_cap"]))
        we = max(0, min(we, K["ward_cap"]))
        p = max(K["pass_min"], min(1, p_raw / (1 + ws / 100.0)))
        raise_mult = min(1 + self.curse_sum("pass_raise"), K["curse_pass_raise_max"])
        p = max(K["pass_min"], min(1, p * raise_mult))
        dr = max(K["drain_min"], d_raw / (1 + we / 100.0))
        dr *= 1 + min(self.curse_sum("drain_raise"), K["curse_drain_raise_max"])
        return model, p, dr, we


def apply_ward(dfn, att, d, kind):
    """Formulas D. Returns what leaks past the ward."""
    t = dfn.ward_terms(kind)
    if t is None:
        return d
    model, p, dr, we = t
    if model in ("drain", "default"):
        blocked = min(d * (1 - p), dfn.qi / dr)
        lost = blocked * dr
    elif model == "per_hit":
        cost = dfn.ward["hit_cost_share"] * (1 - we / (100.0 + we)) * dfn.qi_max
        if dfn.qi + 1e-6 < cost:
            return d
        blocked, lost = d * (1 - p), cost
    elif model == "per_pulse":
        if not dfn.ward_paid:
            return d
        blocked, lost = d * (1 - p), 0
    else:
        raise ValueError("unknown ward model " + str(model))
    dfn.qi = max(0.0, dfn.qi - lost)
    att.qi_drained_by_me += lost
    return d - blocked


def layer_points(att, dfn, t, extra, channel):
    x = list(att.x)
    for i, v in enumerate(extra or []):
        x[i] += v
    for c in att.conditionals:
        family = channel.split(":")[0]
        if family not in c.get("channels", ["art", "basic", "tick", "trigger", "companion"]):
            continue
        if "guard" in c and not guard_true(c["guard"], att, dfn, t):
            continue
        x[c["layer"] - 1] += c.get("points", 0) + scale_value(c, att, dfn, t)
    return x


def scale_value(c, att, dfn, t):
    """A "per X" modifier: points_per * the value of the named scale."""
    if "per" not in c:
        return 0
    per = c["per"]
    table = {
        "own_qi_missing_pct": 100 * (1 - att.qi / att.qi_max),
        "own_health_missing_pct": 100 * (1 - max(att.health, 0) / att.health_max),
        "enemy_qi_missing_pct": 100 * (1 - dfn.qi / dfn.qi_max),
        "enemy_health_missing_pct": 100 * (1 - max(dfn.health, 0) / dfn.health_max),
        "fight_seconds": t / 1000.0,
        "enemy_status_stacks": sum(s["stacks"] for s in dfn.statuses),
        "enemy_curses": len(dfn.curses),
        "empty_slots": max(0, K["slots_by_realm"][att.r] - len(att.arts)),
    }
    if per not in table:
        raise ValueError("unknown per scale " + per)
    return c.get("points_per", 0) * table[per]


def guard_true(g, own, enemy, t):
    if not g:
        return True
    if "time_above" in g:
        return t >= ms(g["time_above"])
    if g.get("on_beat"):
        return t % ms(K["pulse_interval"]) == 0
    side = own if g.get("who", "own") == "own" else enemy
    if "status" in g:
        return any(s["id"] == g["status"] for s in side.statuses)
    share = (max(side.health, 0) / side.health_max) if g["pool"] == "health" else side.qi / side.qi_max
    if "below" in g:
        return share <= g["below"] + 1e-12
    return share >= g["above"] - 1e-12


def add_dmg(att, channel, amount):
    att.dmg[channel] = att.dmg.get(channel, 0.0) + amount


def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
    """Formulas C for one part. Returns health removed."""
    x = layer_points(att, dfn, t, extra, channel)
    m = multiplier(x, skip_l5=(channel == "trigger"))
    for i, v in enumerate(x):
        if v > K["layer_caps"][i]:
            att.note("layer_%d_over_cap" % (i + 1))
    d = att.u * att.stage * c * m * (att.crit_ev if crit else 1.0) * supp(gap, att.pierce)
    p_evade = max(0.0, min(dfn.evade - att.accuracy, K["evade_cap"]))
    d *= 1 - p_evade
    leak = apply_ward(dfn, att, d, kind)
    dealt = max(1.0, leak * dfn.guard_factor(kind))
    dfn.health -= dealt
    dfn.dmg_taken_instant += dealt
    add_dmg(att, channel, dealt)
    if direct:
        att.direct += dealt
    return dealt


def apply_status(att, dfn, st, t):
    existing = next((s for s in dfn.statuses if s["id"] == st["id"]), None)
    add = st.get("stacks", 1) * st.get("chance", 1.0)
    cap = st.get("stack_cap", K["stack_cap"])
    if existing:
        existing["stacks"] = min(cap, existing["stacks"] + add)
        existing["left"] = st.get("duration", 3)
    else:
        rec = dict(st)
        rec["stacks"] = min(cap, add)
        rec["left"] = st.get("duration", 3)
        rec["src"] = att
        rec["x"] = layer_points(att, dfn, t, st.get("x"), "tick")
        dfn.statuses.append(rec)


def apply_curse(dfn, c):
    if len(dfn.curses) >= K["curse_slots"]:
        dfn.curses.remove(min(dfn.curses, key=lambda v: v["left"]))
    rec = dict(c)
    rec["left"] = c.get("duration", 3)
    dfn.curses.append(rec)


def fire_triggers(att, dfn, t, gap, source):
    budget_base = max(att.direct, 0.5 * att.u * att.stage)
    for tr in att.triggers:
        if tr.get("source", "any") not in ("any", source):
            continue
        if att.trig_count >= K["trig_cap"]:
            att.note("trig_cap_reached")
            return
        att.trig_count += 1
        chance = tr.get("chance", 1.0)
        if "status" in tr:
            s = dict(tr["status"])
            s["chance"] = s.get("chance", 1.0) * chance
            apply_status(att, dfn, s, t)
        if "curse" in tr and chance >= 1:
            apply_curse(dfn, tr["curse"])
        if "refund_qi_share" in tr:
            att.qi = min(att.qi_cap, att.qi + tr["refund_qi_share"] * att.qi_max * chance)
        if "c_trig" in tr:
            room = K["trig_budget"] * budget_base - att.trig_dmg
            if room <= 0:
                att.note("trigger_budget_clipped")
                continue
            dealt = strike(att, dfn, t, gap, min(tr["c_trig"], K["c_trig_max"]) * chance,
                           tr.get("kind", "qi"), tr.get("x"), "trigger", crit=False, direct=False)
            if dealt > room:
                att.note("trigger_budget_clipped")
                dfn.health += dealt - room
                dfn.dmg_taken_instant -= dealt - room
                add_dmg(att, "trigger", room - dealt)
                dealt = room
            att.trig_dmg += dealt


def resolve_art(att, dfn, art, t, gap):
    if art.get("soul_pct"):
        s = supp(gap, att.pierce)
        share = soul_share(att.sense, dfn.sense, dfn.soul_res, art["soul_pct"], att.x_soul, s)
        hl = share * dfn.health_max / dfn.boss
        ql = share * dfn.qi_max / dfn.boss
        dfn.health -= hl
        dfn.dmg_taken_instant += hl
        dfn.qi = max(0.0, dfn.qi - ql)
        add_dmg(att, "soul", hl)
        att.direct += hl
    elif art.get("c_art", 0) > 0:
        parts = art.get("parts") or [{"share": 1.0, "kind": art.get("kind", "body")}]
        for p in parts:
            x = list(art.get("x", [0, 0, 0, 0, 0]))
            for i, v in enumerate(p.get("x", [])):
                x[i] += v
            strike(att, dfn, t, gap, art["c_art"] * p["share"], p["kind"], x, "art:" + art["id"])
    for st in art.get("applies", []):
        apply_status(att, dfn, st, t)
    if art.get("curse"):
        apply_curse(dfn, art["curse"])
    if art.get("refund_qi_share"):
        att.qi = min(att.qi_cap, att.qi + art["refund_qi_share"] * att.qi_max)
    if art.get("c_art", 0) > 0 or art.get("soul_pct"):
        fire_triggers(att, dfn, t, gap, "art")


def pulse(side, enemy, gap_of_enemy, t):
    """Ticks on this side, durations, regeneration, upkeep, limit reset."""
    total = 0.0
    spilled = 0.0
    spill_src = None
    bonus = max([s["src"].spec.get("dot_cap_bonus", 0) for s in side.statuses] or [0])
    tick_cap = (K["dot_pool_cap"] + bonus) * side.health_max
    cap_total = (K["dot_pulse_cap"] + bonus) * side.health_max
    for s in side.statuses:
        src = s["src"]
        if s.get("kind") == "qi_burn":
            amount = min(src.u * src.stage * s["c_tick"] * s["stacks"]
                         * multiplier(s["x"], True) * supp(gap_of_enemy, src.pierce),
                         K["qi_burn_cap"] * side.qi_max)
            side.qi = max(0.0, side.qi - amount)
            add_dmg(src, "qi_burn(linh luc)", amount)
        else:
            raw = src.u * src.stage * s["c_tick"] * s["stacks"] * multiplier(s["x"], True) \
                * supp(gap_of_enemy, src.pierce) * side.guard_factor(s.get("kind", "body"))
            tick = max(1.0, min(raw, tick_cap))
            if raw > tick_cap:
                src.note("dot_pool_cap_clipped")
            room = cap_total - total
            if tick > room:
                src.note("dot_pulse_cap_clipped")
                tick = max(room, 0.0)
                if total == 0:
                    tick = max(tick, 1.0)
            total += tick
            side.health -= tick
            side.dmg_taken_instant += tick
            add_dmg(src, "tick:" + s["id"], tick)
            share = src.spec.get("tick_overflow_qi", 0)
            if share and raw > tick:
                spilled += (raw - tick) * share
                spill_src = src
        if s.get("permanent"):
            continue
        s["left"] -= 1
    if spill_src is not None:
        burn = min(spilled, K["qi_burn_cap"] * side.qi_max, side.qi)
        side.qi -= burn
        add_dmg(spill_src, "overflow(linh luc)", burn)
    side.statuses = [s for s in side.statuses if s.get("permanent") or s["left"] > 0]
    for c in side.curses:
        c["left"] -= 1
    blocked = any(c.get("block_regen") for c in side.curses)
    side.curses = [c for c in side.curses if c["left"] > 0]
    if not blocked and side.health > 0:
        side.qi = min(side.qi_cap, side.qi + side.qi_max * side.regen)
    if side.ward.get("model") == "per_pulse":
        we = side.ward.get("we", 0)
        cost = side.ward["upkeep_share"] * (1 - we / (100.0 + we)) * side.qi_max
        side.ward_paid = side.qi + 1e-6 >= cost
        if side.ward_paid:
            side.qi -= cost
    side.trig_count = 0
    side.direct = 0.0
    side.trig_dmg = 0.0


def next_event(sides, pulse_next, t):
    times = [pulse_next]
    for s in sides:
        if s.basic_next is not None:
            times.append(s.basic_next)
        if s.comp_next is not None:
            times.append(s.comp_next)
        if s.lock_until > t:
            times.append(s.lock_until)
        for a in s.arts:
            if a["ready"] > t:
                times.append(a["ready"])
            g = a.get("guard") or {}
            if "time_above" in g and ms(g["time_above"]) > t:
                times.append(ms(g["time_above"]))
    return min(times)


def run_fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
    """Combat rule 10. a is the requesting side. Returns a result dict."""
    a, b = Side(a_spec, "A"), Side(b_spec, "B")
    sides = [a, b]
    gaps = {id(a): gap_a, id(b): gap_b}
    limit = ms(K["time_limit"])
    pulse_ms = ms(K["pulse_interval"])
    pulse_next = pulse_ms
    for s, o in ((a, b), (b, a)):
        for st in s.spec.get("aura", []):
            rec = dict(st)
            rec["permanent"] = True
            rec["left"] = 1
            rec["src"] = s
            rec["stacks"] = st.get("stacks", 1)
            rec["x"] = layer_points(s, o, 0, st.get("x"), "tick")
            o.statuses.append(rec)
        if s.ward.get("model") == "per_pulse":
            we = s.ward.get("we", 0)
            cost = s.ward["upkeep_share"] * (1 - we / (100.0 + we)) * s.qi_max
            s.ward_paid = s.qi + 1e-6 >= cost
            if s.ward_paid:
                s.qi -= cost
    t = 0
    end, winner = None, None
    while end is None:
        t = next_event(sides, pulse_next, t)
        if t > limit:
            t = limit
            end = "stalemate"
            break
        for s in sides:
            s.dmg_taken_instant = 0.0
            s.health_at_instant = s.health
        if t == pulse_next:
            pulse(a, b, gaps[id(b)], t)
            pulse(b, a, gaps[id(a)], t)
            pulse_next += pulse_ms
        first = True
        while True:
            fired = {id(a): [], id(b): []}
            for s, o in ((a, b), (b, a)):
                for art in s.arts:
                    if art["ready"] > t or not guard_true(art.get("guard"), s, o, t):
                        continue
                    if art.get("stock_left") == 0:
                        continue
                    soul = bool(art.get("soul_pct"))
                    if soul and s.lock_until > t:
                        continue
                    raise_c = min(s.curse_sum("cost_raise"), K["curse_cost_raise_max"])
                    cost = art.get("cost_share", 0) * (1 - s.cost_red) * (1 + raise_c) * s.qi_max
                    if s.qi < cost - 1e-6:
                        art["waited"] = art.get("waited", 0) + 1
                        continue
                    s.qi -= cost
                    if art.get("body_cost_share"):
                        s.health = max(min(s.health, 1.0), s.health - art["body_cost_share"] * s.health_max)
                    art["ready"] = t + art["cd_ms"]
                    art["fired"].append(t)
                    if art.get("stock_left") is not None:
                        art["stock_left"] -= 1
                    if soul:
                        s.lock_until = t + ms(K["soul_lockout"])
                    fired[id(s)].append(art)
            any_fired = bool(fired[id(a)] or fired[id(b)])
            for s, o in ((a, b), (b, a)):
                g = gaps[id(s)]
                for art in fired[id(s)]:
                    resolve_art(s, o, art, t, g)
                if first and s.basic_next == t:
                    if s.basic.get("c", 0) > 0:
                        strike(s, o, t, g, s.basic["c"], s.basic.get("kind", "body"),
                               s.basic.get("x"), "basic")
                        fire_triggers(s, o, t, g, "basic")
                    s.basic_next += ms(K["basic_cooldown"])
                if first and s.comp_next == t:
                    strike(s, o, t, g, s.companion["c_comp"], s.companion.get("kind", "body"),
                           s.companion.get("x"), "companion", crit=False)
                    s.comp_next += ms(K["basic_cooldown"])
            first = False
            for s in sides:
                if s.dry_at is None and s.qi <= 0.05 * s.qi_max:
                    s.dry_at = t
            down = [s for s in sides if s.health <= 0]
            if down:
                if len(down) == 2:
                    over = []
                    for s in down:
                        over.append(max(0.0, s.dmg_taken_instant - s.health_at_instant) / s.health_max)
                    if abs(over[0] - over[1]) < K["overkill_epsilon"]:
                        end, winner = "draw", None
                    else:
                        end = "knockout"
                        winner = sides[1] if over[0] > over[1] else sides[0]
                else:
                    end = "knockout"
                    winner = b if down[0] is a else a
                break
            if not any_fired:
                break
        if record is not None:
            record.append((t, max(a.health, 0) / a.health_max, a.qi / a.qi_max,
                           max(b.health, 0) / b.health_max, b.qi / b.qi_max))
    return {"end": end, "t": t / 1000.0, "winner": winner.name if winner else None,
            "a": a, "b": b}


# --- Reference enemies, built from the Formulas B anchors ---------------------

def anchored_pools(spec, r, ehp_anchor):
    """Scales both pools so the profile's ehp meets the anchor. Exact at Qi
    Refining for typical; a fit elsewhere, because the anchors do not state n."""
    s = Side(spec, "x")
    terms = [s.ward_terms(k) for k in ("body", "qi")]
    p = sum(t[1] for t in terms) / 2
    dr = sum(t[2] for t in terms) / 2
    f = (s.guard_factor("body") + s.guard_factor("qi")) / 2
    ehp = min(s.health_max / (p * f), s.health_max / f + s.qi_max / dr)
    fit = ehp_anchor * s.u / ehp
    spec["n_body"] *= fit
    spec["n_qi"] *= fit
    return spec


def typical(r):
    w = K["anchor_tree_w"][r]
    ws = 0.05 * w + 100 * K["ward_gear_scale"] * 0.85
    spec = {"name": "typical", "realm": r, "layers": [0.25 * w] + K["anchor_typical_layers"],
            "n_body": 1 + 0.00833 * 0.10 * w, "n_qi": 1 + 0.05 * w / 100.0,
            "crit": {"chance": 0.15, "mult": 1.7},
            "ward": {"model": "drain", "pass": {"body": 0.54, "qi": 0.36},
                     "drain": {"body": 1.0, "qi": 1.5}, "ws": ws, "we": ws},
            "divine_sense": 1.0,
            "arts": [{"id": "fixture_art", "kind": "body", "c_art": 2.0,
                      "cost_share": 0.15, "cooldown": 1}]}
    return anchored_pools(spec, r, K["anchor_typical_ehp"][r])


def top_end(r):
    w = K["anchor_tree_w"][r]
    gear = 100 * K["ward_gear_scale"] * 5
    spec = {"name": "top_end", "realm": r, "layers": [0.45 * w] + K["anchor_topend_layers"],
            "n_body": 1 + 0.00833 * 0.20 * w, "n_qi": 1 + 0.075 * w / 100.0,
            "crit": {"chance": 0.5, "mult": 2.0},
            "ward": {"model": "drain", "pass": {"body": 0.42, "qi": 0.28},
                     "drain": {"body": 0.72, "qi": 1.08},
                     "ws": 0.10 * w + gear, "we": 0.075 * w + gear},
            "divine_sense": 1.0,
            "arts": [{"id": "fixture_art", "kind": "body", "c_art": 2.0,
                      "cost_share": 0.15, "cooldown": 1}]}
    return anchored_pools(spec, r, K["anchor_topend_ehp"][r])


def merge(base, over):
    out = copy.deepcopy(base)
    for k, v in (over or {}).items():
        if isinstance(v, dict) and isinstance(out.get(k), dict):
            out[k] = merge(out[k], v)
        else:
            out[k] = v
    return out


# --- Report -------------------------------------------------------------------

def lint_arts(build):
    r = build["realm"] if isinstance(build["realm"], int) else REALMS.index(build["realm"])
    slots = K["slots_by_realm"][r] + build.get("bonus_slots", 0)
    used = len(build.get("arts", []))
    print("slots\tused %d of %d" % (used, slots) + ("\tOVER" if used > slots else ""))
    for a in build.get("arts", []):
        if a.get("c_art", 0) <= 0:
            continue
        cost = a.get("cost_share", 0) + 2 * a.get("body_cost_share", 0)
        lim = art_lint_max(cost, a["cooldown"])
        print("art_lint\t%s\tc_art %.2f\tmax %.2f\t%s" % (
            a["id"], a["c_art"], lim, "within" if a["c_art"] <= lim + 1e-9 else "OVER"))


def report_layers(build):
    r = build["realm"] if isinstance(build["realm"], int) else REALMS.index(build["realm"])
    x = list(build.get("layers", [0] * 5))
    v = layer_values(x)
    m = v[0] * v[1] * v[2] * v[3] * v[4]
    print("layers\t" + "\t".join("L%d %g pts x%.2f (cap %g)" % (
        i + 1, x[i], v[i], K["layer_caps"][i]) for i in range(5)))
    print("m_static\t%.2f\tanchors at %s: typical %.2f, top_end %.0f" % (
        m, REALM_NAMES[r], K["anchor_typical_m"][r], K["anchor_topend_m"][r]))
    for c in build.get("conditional_mods", []):
        print("conditional\tL%d\t%s\tnot in m_static" % (c["layer"], c.get("id", "?")))


def report_result(res, build):
    a, b = res["a"], res["b"]
    print("result\t%s\tt=%.3f s\twinner=%s" % (res["end"], res["t"], res["winner"]))
    print("end_state\town health %.0f%% linh luc %.0f%%\tenemy health %.0f%% linh luc %.0f%%" % (
        100 * max(a.health, 0) / a.health_max, 100 * a.qi / a.qi_max,
        100 * max(b.health, 0) / b.health_max, 100 * b.qi / b.qi_max))
    total = sum(a.dmg.get(k, 0) for k in a.dmg if "linh luc" not in k) or 1
    for k, v in sorted(a.dmg.items(), key=lambda kv: -kv[1]):
        unit = "linh luc" if "linh luc" in k else "health"
        share = "" if unit == "linh luc" else "\t%.0f%%" % (100 * v / total)
        print("channel\t%s\t%.1f %s%s" % (k, v, unit, share))
    print("enemy_linh_luc_burned_by_ward\t%.1f" % a.qi_drained_by_me)
    print("own_dry_at\t%s" % ("never" if a.dry_at is None else "%.3f s" % (a.dry_at / 1000.0)))
    for art in a.arts:
        times = ", ".join("%.2f" % (x / 1000.0) for x in art["fired"][:12])
        print("art\t%s\tcd %.3f s\tfired %d\tat %s%s\tblocked_instants %d" % (
            art["id"], art["cd_ms"] / 1000.0, len(art["fired"]), times,
            " ..." if len(art["fired"]) > 12 else "", art.get("waited", 0)))
    for k, v in sorted(a.notes.items()):
        print("cap_hit\t%s\t%d" % (k, v))


def run_one(build, enemy_name, gap, timeline):
    r = build["realm"] if isinstance(build["realm"], int) else REALMS.index(build["realm"])
    er = min(4, r + gap)
    enemy = {"typical": typical, "top_end": top_end}[enemy_name](er)
    enemy = merge(enemy, build.get("enemy_overrides"))
    enemy["divine_sense"] = build.get("enemy_divine_sense", enemy.get("divine_sense", 1.0))
    rec = [] if timeline else None
    res = run_fight(build, enemy, gap_a=gap, gap_b=0, record=rec)
    print("\nvs\t%s\t%s\tgap %d" % (enemy_name, REALM_NAMES[er], gap))
    report_result(res, build)
    if timeline:
        print("t\town_h%\town_q%\tenemy_h%\tenemy_q%")
        last = -1
        for row in rec:
            sec = row[0] // 1000
            if sec != last:
                print("%.2f\t%.0f\t%.0f\t%.0f\t%.0f" % (row[0] / 1000.0, 100 * row[1], 100 * row[2],
                                                       100 * row[3], 100 * row[4]))
                last = sec


# --- Selftest: the GDD's own fixtures -----------------------------------------

def fx_t():
    return {"name": "FX-T", "realm": 0, "layers": [26.5, 40, 40, 20, 10],
            "n_body": 1.08833, "n_qi": 1.053,
            "ward": {"model": "drain", "pass": {"body": 0.54, "qi": 0.36},
                     "drain": {"body": 1.0, "qi": 1.5}, "ws": 30.8, "we": 30.8},
            "arts": [{"id": "art", "kind": "body", "c_art": 2.0, "cost_share": 0.15, "cooldown": 1}]}


def fx_u():
    return {"name": "FX-U", "realm": 0, "ward": {"model": "default"}, "arts": []}


def selftest():
    fails = []

    def eq(label, got, want, tol=0.01):
        ok = abs(got - want) <= tol
        print("%s\t%s\tgot %.4f\twant %.4f" % ("ok" if ok else "FAILED", label, got, want))
        if not ok:
            fails.append(label)

    s = Side(fx_t(), "t")
    eq("AC-CB-09 health", s.health_max, 109.87)
    eq("AC-CB-09 linh luc", s.qi_max, 172.74)
    eq("AC-CB-14 M", multiplier(s.x), 3.27279, 0.0001)
    eq("AC-CB-15 x1 200", layer_values([200, 0, 0, 0, 0])[0], 3.00)
    eq("AC-CB-15 x1 293", layer_values([293, 0, 0, 0, 0])[0], 3.465)
    eq("AC-CB-15 x1 1000", layer_values([1000, 0, 0, 0, 0])[0], 5.00)
    eq("AC-CB-15 all capped", multiplier([9999] * 5), 350)
    eq("guard m", s.guard_mitigation(), 0.0679, 0.0001)

    def one_hit(qi, kind, gap=0, pierce=0, ward=True):
        att, dfn = fx_t(), fx_t()
        att["pierce_pct"] = pierce
        if not ward:
            dfn["ward"] = {"model": "off"}
        A, D = Side(att, "a"), Side(dfn, "d")
        D.qi = qi
        h = D.health
        strike(A, D, 0, gap, 2.0, kind, None, "art")
        return h - D.health, qi - D.qi

    dealt, lost = one_hit(172.74, "body")
    eq("AC-CB-12 body dealt", dealt, 15.89, 0.02)
    eq("AC-CB-12 body drained", lost, 18.54, 0.02)
    dealt, lost = one_hit(172.74, "qi")
    eq("AC-CB-12 qi dealt", dealt, 10.79, 0.02)
    eq("AC-CB-12 qi drained", lost, 34.33, 0.03)
    dealt, lost = one_hit(10, "body")
    eq("AC-CB-12 10 linh luc dealt", dealt, 26.30, 0.02)
    dealt, _ = one_hit(172.74, "body", ward=False)
    eq("AC-CB-21 ward off", dealt, 38.50, 0.02)
    dealt, _ = one_hit(172.74, "body", gap=2, pierce=50)
    eq("AC-CB-21 g2 P.5", dealt, 13.91, 0.02)
    eq("Formulas H supp", supp(2, 50), 0.875, 1e-9)
    eq("Formulas A2 3333 ms", Side({"realm": 0, "art_speed_pct": 200, "arts": [
        {"id": "x", "cooldown": 10}]}, "c").arts[0]["cd_ms"], 3333, 0)
    eq("Formulas C lint", art_lint_max(0.25, 30), 11.25, 1e-9)
    for rho, want in ((1, 0.05), (2, 0.20), (3, 0.30), (0.5, 0.0125), (0.2, 0.0)):
        eq("E2 soul rho %.1f" % rho, soul_share(rho, 1, 0, 0.05, 0), want, 1e-9)

    src = Side(dict(fx_t(), layers=[0, 0, 0, 0, 0]), "s")
    tgt = Side(fx_t(), "d")
    raw = src.u * 0.3 * 3 * 1.771 * tgt.guard_factor("body")
    eq("AC-CB-38 raw tick", raw, 9.37, 0.02)
    src.spec["aura"] = []
    tgt.statuses.append({"id": "poison", "kind": "body", "c_tick": 0.3, "stacks": 3,
                         "x": [77.1, 0, 0, 0, 0], "src": src, "permanent": True, "left": 1})
    h = tgt.health
    pulse(tgt, src, 0, 1000)
    eq("AC-CB-38 capped tick", h - tgt.health, 5.49, 0.01)

    res = run_fight(fx_t(), fx_t())
    eq("AC-CB-30 FX-T ends at 8", res["t"], 8.0, 0)
    eq("AC-CB-30 FX-T is a draw", 1 if res["end"] == "draw" else 0, 1, 0)
    times = [x / 1000.0 for x in res["a"].arts[0]["fired"]]
    eq("AC-CB-30 FX-T art firings 1,2,3", 1 if times[:3] == [1.0, 2.0, 3.0] else 0, 1, 0)
    rec = []
    run_fight(fx_t(), fx_t(), record=rec)
    low = all(row[2] * 172.74 < 20 for row in rec if row[0] >= 3000)
    eq("AC-CB-30 FX-T linh luc under 20 from t=3", 1 if low else 0, 1, 0)
    res = run_fight(fx_u(), fx_u())
    eq("AC-CB-30 FX-U ends at 25", res["t"], 25.0, 0)
    eq("AC-CB-30 FX-U is a draw", 1 if res["end"] == "draw" else 0, 1, 0)
    res = run_fight({"realm": 0, "ward": {"model": "off"}, "basic": {"c": 0}, "arts": [
        {"id": "a", "c_art": 2, "cost_share": 0, "cooldown": 1},
        {"id": "b", "c_art": 2, "cost_share": 0, "cooldown": 1},
        {"id": "c", "c_art": 2, "cost_share": 0, "cooldown": 3}]},
        {"realm": 0, "n_body": 8, "basic": {"c": 0}, "ward": {"model": "default"}, "arts": []})
    fired = res["a"].arts
    eq("AC-CB-32 fast arts fire first at 1", fired[0]["fired"][0], 1000, 0)
    eq("AC-CB-32 slow art fires first at 3", fired[2]["fired"][0], 3000, 0)
    eq("AC-CB-32 slow art fires next at 6", fired[2]["fired"][1], 6000, 0)
    sa, sb = fx_t(), fx_t()
    sa["triggers"] = [{"source": "art", "c_trig": 0.5, "kind": "body"}] * 6
    res = run_fight(sa, sb)
    spent = res["a"].dmg.get("trigger", 0)
    direct = sum(v for k, v in res["a"].dmg.items() if k != "trigger")
    eq("Formulas G trigger never above half of direct", 1 if spent <= 0.5 * direct + 1e-6 else 0, 1, 0)

    r = Side(dict(fx_t(), reserve_share=0.3), "r")
    eq("reservation caps the pool, not the maximum", r.qi / r.qi_max, 0.7, 1e-9)
    src = Side(dict(fx_t(), layers=[0, 0, 0, 0, 0], tick_overflow_qi=1.0), "s")
    tgt = Side(fx_t(), "d")
    tgt.statuses.append({"id": "poison", "kind": "body", "c_tick": 0.3, "stacks": 3,
                         "x": [77.1, 0, 0, 0, 0], "src": src, "permanent": True, "left": 1})
    q = tgt.qi
    pulse(tgt, src, 0, 1000)
    regen = tgt.qi_max * tgt.regen
    eq("overflow burns the clipped tick", q - (tgt.qi - regen) if q + regen <= tgt.qi_cap else 3.88,
       9.3738 - 5.4935, 0.01)

    def beat_run(speed):
        spec = {"realm": 0, "basic": {"c": 0}, "ward": {"model": "off"}, "art_speed_pct": speed,
                "conditional_mods": [{"id": "beat", "layer": 5, "points": 100, "channels": ["art"],
                                      "guard": {"on_beat": True}}],
                "arts": [{"id": "a", "kind": "body", "c_art": 2, "cost_share": 0, "cooldown": 2}]}
        dummy = {"realm": 0, "n_body": 8, "basic": {"c": 0}, "ward": {"model": "off"}, "arts": []}
        r = run_fight(spec, dummy)
        return r["a"].dmg["art:a"] / len(r["a"].arts[0]["fired"])
    eq("a conditional applies to arts: on-beat hit is double", beat_run(100) / beat_run(120), 2.0, 0.01)

    print("selftest\t%s" % ("all fixtures matched" if not fails else "%d FAILED" % len(fails)))
    return not fails


def main():
    ap = argparse.ArgumentParser(description="Paper model of Combat's timeline")
    ap.add_argument("build", nargs="?")
    ap.add_argument("--selftest", action="store_true")
    ap.add_argument("--constants", action="store_true")
    ap.add_argument("--matrix", action="store_true")
    ap.add_argument("--enemy", default=None, choices=["typical", "top_end"])
    ap.add_argument("--gap", type=int, default=0)
    ap.add_argument("--timeline", action="store_true")
    ap.add_argument("--without", action="append", default=[])
    args = ap.parse_args()
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")
    if args.selftest:
        ok = check_constants()
        return 0 if selftest() and ok else 1
    if args.constants:
        check_constants()
        return 0
    if not args.build:
        ap.print_usage()
        return 2
    try:
        with open(args.build, encoding="utf-8") as f:
            build = json.load(f)
    except (OSError, ValueError) as e:
        print("BAD_INPUT\t%s" % e)
        return 2
    for piece in args.without:
        found = piece in build
        build.pop(piece, None)
        for key in ("conditional_mods", "arts", "aura", "triggers"):
            before = len(build.get(key, []))
            build[key] = [m for m in build.get(key, []) if m.get("id") != piece]
            found = found or len(build[key]) != before
        print(("without\t%s" if found else "WITHOUT_NOT_FOUND\t%s") % piece)
    check_constants()
    print("model\tcrit, evade and chances are expected values; see the header of fight_calc.py")
    print("build\t%s" % build.get("name", "?"))
    lint_arts(build)
    report_layers(build)
    for u in build.get("unmodelled", []):
        print("UNMODELLED\t%s" % u)
    if args.matrix:
        for enemy in ("typical", "top_end"):
            for gap in (0, 1, 2):
                run_one(build, enemy, gap, args.timeline)
    else:
        run_one(build, args.enemy or build.get("enemy", "typical"), args.gap, args.timeline)
    return 0


if __name__ == "__main__":
    sys.exit(main())
