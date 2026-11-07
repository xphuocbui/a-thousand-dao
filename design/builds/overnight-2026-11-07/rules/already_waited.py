"""Already Waited (Dĩ Đãi): heart demon as a second pool that pays cooldowns, not costs.

Asked for with "waited": {"pool": 90, "rate": 1.0, "cap": 100, "blow_refill": 1.0}.

At each pulse, after the pulse's own work, the pool may pay one art: the next one in slot order,
going round, that is on its timer, whose guard holds and whose linh lực cost can be met. The
price is rate x the seconds left on its timer. Paid, the art is ready in this instant and
fires by the ordinary rule, paying its ordinary linh lực. One art a pulse. A timer of 0 is
skipped, and the turn passes on.

"blow_refill": heart demon gained per 1 % of maximum health lost to a hit (Every Blow). The pool
stops at "cap".

"both_hands": n. While the pool stands above n as a pulse begins, it pays two arts that pulse, one
after the other (Both Hands, Song Thủ).

"delay_enemy": n on an art is Wait Here: when it fires, the enemy art nearest to firing is pushed
back n seconds. Timing on the enemy's side, so only this art's owner acts.

Reports what was spent, which is also seasons owed at 1 season a point.
"""


def install(f):
    original_pulse = f.pulse
    original_strike = f.strike
    original_report = f.report_result
    original_resolve = f.resolve_art

    def state(side):
        w = side.spec.get("waited")
        if not w:
            return None
        st = side.__dict__.get("demon")
        if st is None:
            st = {"pool": float(w.get("pool", 0)), "spent": 0.0, "next": 0, "paid": [], "clipped": 0.0,
                  "gained": 0.0}
            side.demon = st
        return st

    def pay(side, enemy, t):
        st = state(side)
        w = side.spec["waited"]
        n = len(side.arts)
        for k in range(n):
            i = (st["next"] + k) % n
            art = side.arts[i]
            left = (art["ready"] - t) / 1000.0
            if left <= 0:
                continue
            if art.get("stock_left") == 0 or not f.guard_true(art.get("guard"), side, enemy, t):
                continue
            raise_c = min(side.curse_sum("cost_raise"), f.K["curse_cost_raise_max"])
            cost = art.get("cost_share", 0) * (1 - side.cost_red) * (1 + raise_c) * side.qi_max
            if side.qi < cost - 1e-6:
                continue
            price = w.get("rate", 1.0) * left
            if price > st["pool"] + 1e-9:
                continue
            st["pool"] -= price
            st["spent"] += price
            st["paid"].append((t, art["id"], price))
            art["ready"] = t
            st["next"] = (i + 1) % n
            return

    def pulse(side, enemy, gap_of_enemy, t):
        original_pulse(side, enemy, gap_of_enemy, t)
        w = side.spec.get("waited")
        if w and side.health > 0 and side.arts:
            double = "both_hands" in w and state(side)["pool"] > w["both_hands"]
            pay(side, enemy, t)
            if double:
                pay(side, enemy, t)

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        before = dfn.health
        out = original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        d = state(dfn)
        if d:
            w = dfn.spec["waited"]
            lost = min(before, before - dfn.health) if before > 0 else 0.0
            gain = 100.0 * lost / dfn.health_max * w.get("blow_refill", 0)
            room = w.get("cap", 100) - d["pool"]
            d["pool"] += min(gain, room)
            d["gained"] += min(gain, room)
            if gain > room:
                d["clipped"] += gain - room
        return out

    def resolve_art(att, dfn, art, t, gap):
        out = original_resolve(att, dfn, art, t, gap)
        n = art.get("delay_enemy")
        if n and dfn.arts:
            waiting = [a for a in dfn.arts if a["ready"] > t and a.get("stock_left") != 0]
            if waiting:
                nearest = min(waiting, key=lambda a: a["ready"])
                nearest["ready"] += f.ms(n)
                att.note("enemy_art_delayed")
        return out

    def report_result(res, build):
        original_report(res, build)
        st = state(res["a"])
        if st:
            print("demon\tspent %.1f\tleft %.1f\tgained from blows %.1f\tclipped %.1f" % (
                st["spent"], st["pool"], st["gained"], st["clipped"]))
            print("demon_paid\t" + ", ".join("%s@%.0f(%.1f)" % (a, t / 1000.0, p) for t, a, p in st["paid"]))

    f.pulse = pulse
    f.strike = strike
    f.resolve_art = resolve_art
    f.report_result = report_result
