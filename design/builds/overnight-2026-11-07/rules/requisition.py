"""Requisition (Trưng Thu). Redirect: linh lực burn counts as drain a ward asked for.

Asked for with "requisition": true on the side whose burn it is. Each qi_burn status and
Spillover on the target becomes a demand on its pool at the pulse, and anything that reads
drain reads it too, from this side's own spec:

  "scrape_share" (Scraping the Well): that share of the burn the pool could not pay lands on
  health, past body guard. Linh lực for linh lực, as Scraping does for a hit.
  "water_table": {"share": n}: that share of the burn the pool did pay comes to this side,
  up to its own maximum.

The burn caps are unchanged: this reads what the calculator's pulse would burn, then lets it
run. Regeneration comes after the burn in a pulse, so a pool at 0 pays with last pulse's
regeneration and only the rest is unpaid. Only burn from a source asking for it is touched.

"burn_cap_shared": true reads Formulas F's qi burn cap as one cap per pulse for all of a
target's burn statuses, not one per status: each of n burn statuses is held to cap / n, the
even split. A reading to test, not a piece.
"""


def install(f):
    original = f.pulse

    def demands(side, gap_of_enemy):
        """What this pulse's burn and Spillover will ask for, per asking source."""
        out = {}
        bonus = max([s["src"].spec.get("dot_cap_bonus", 0) for s in side.statuses] or [0])
        tick_cap = (f.K["dot_pool_cap"] + bonus) * side.health_max
        cap_total = (f.K["dot_pulse_cap"] + bonus) * side.health_max
        total, spilled, spill_src = 0.0, 0.0, None
        for s in side.statuses:
            o = s["src"]
            if s.get("kind") == "qi_burn":
                raw = o.u * o.stage * s["c_tick"] * s["stacks"] * f.multiplier(s["x"], True) \
                    * f.supp(gap_of_enemy, o.pierce)
                if o.spec.get("requisition"):
                    out[id(o)] = (o, out.get(id(o), (o, 0.0))[1] + min(raw, f.K["qi_burn_cap"] * side.qi_max))
                continue
            raw = o.u * o.stage * s["c_tick"] * s["stacks"] * f.multiplier(s["x"], True) \
                * f.supp(gap_of_enemy, o.pierce) * side.guard_factor(s.get("kind", "body"))
            tick = max(1.0, min(raw, tick_cap))
            room = cap_total - total
            if tick > room:
                tick = max(room, 0.0)
                if total == 0:
                    tick = max(tick, 1.0)
            total += tick
            share = o.spec.get("tick_overflow_qi", 0)
            if share and raw > tick:
                spilled += (raw - tick) * share
                spill_src = o
        if spill_src is not None and spill_src.spec.get("requisition"):
            o = spill_src
            out[id(o)] = (o, out.get(id(o), (o, 0.0))[1] + min(spilled, f.K["qi_burn_cap"] * side.qi_max))
        return out

    def pulse(side, enemy, gap_of_enemy, t):
        base = f.K["qi_burn_cap"]
        burns = [s for s in side.statuses if s.get("kind") == "qi_burn"]
        if burns and any(s["src"].spec.get("burn_cap_shared") for s in burns):
            f.K["qi_burn_cap"] = base / len(burns)
        try:
            asked = demands(side, gap_of_enemy)
            before = side.qi
            original(side, enemy, gap_of_enemy, t)
        finally:
            f.K["qi_burn_cap"] = base
        for o, demand in asked.values():
            paid = min(demand, before)
            before -= paid
            unpaid = (demand - paid) * o.spec.get("scrape_share", 0)
            if unpaid > 0:
                side.health -= unpaid
                side.dmg_taken_instant += unpaid
                f.add_dmg(o, "requisitioned", unpaid)
            wt = o.spec.get("water_table")
            if wt:
                take = min(paid * wt["share"], max(o.qi_cap - o.qi, 0.0))
                o.qi += take
                f.add_dmg(o, "drawn(linh luc)", take)
        return None

    f.pulse = pulse
