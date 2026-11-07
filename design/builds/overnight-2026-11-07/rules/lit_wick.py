"""The Given Years: a fight's pulses are seasons of a life with a known end.

"wick": {"seasons": 20, "health_per_season": 0.1, "pulse_burn": 1, "points_per": 5, "layer": 2,
         "channels": ["art", "basic"]}
    Paid in Seasons: at the defeat check, health lost this instant is restored and burns seasons,
    1 for each health_per_season of maximum health, in fractions. Lit Wick: each pulse of a fight
    burns pulse_burn more. At 0 seasons the side stands at 0 health and is Down at that check, having
    acted in that instant (rule 10 order: pulse, arts, hits, defeat check).
    Short Wick: +points_per to the layer for each season missing from 40.
    Hook: run_fight reads each side's dry_at just before the defeat check, so dry_at is a property
    here, as in turned_away.py. It chains to any dry_at hook already installed, so it may share a fight
    with turned_away or stands_over: the plug-in listed last acts first at the defeat check.
"given_years": {"share_pct": 30, "points_per": 1.5, "layer": 4, "channels": [...]}
    Per: points for each 1 % of the realm's base lifespan given away. Read in any fight.
"nothing_to_lose": {"points_per": 10, "layer": 5, "cap": 100, "enemy_share": 0.5, "channels": [...]}
    Per: points for each doubling of the enemy's years left over your own. The enemy's years are its
    "years_left", else enemy_share x its realm's base lifespan. Read live, so it climbs as the wick burns.
Guard {"wick_below": n}: true at n seasons or fewer. Put it with "time_above": 0, which the calculator
    reads as true.
--without lit_wick skips all of this; --without given_years or nothing_to_lose removes one key.
"""
import math

LIFESPAN = [120, 200, 500, 1000, 2000]  # Realms rule 14


def install(f):
    original_pulse = f.pulse
    original_points = f.layer_points
    original_guard = f.guard_true
    original_report = f.report_result
    earlier = f.Side.__dict__.get("dry_at")  # another plug-in's hook, which this one chains to

    def seasons(side):
        if "seasons_left" not in side.__dict__:
            side.seasons_left = side.spec["wick"]["seasons"]
        return side.seasons_left

    def pulse(side, enemy, gap_of_enemy, t):
        original_pulse(side, enemy, gap_of_enemy, t)
        if side.spec.get("wick") and seasons(side) > 0:
            side.seasons_left -= side.spec["wick"].get("pulse_burn", 1)
            side.now = t

    def pay_in_seasons(side):
        w = side.spec["wick"]
        lost = side.health_max - side.health
        share = w.get("health_per_season")
        if share and lost > 0 and seasons(side) > 0:
            burned = lost / (share * side.health_max)
            side.__dict__["paid"] = side.__dict__.get("paid", 0.0) + min(burned, seasons(side))
            side.seasons_left -= burned
            side.health = side.health_max
        if seasons(side) <= 0:
            side.seasons_left = 0
            side.health = 0.0
            side.__dict__.setdefault("date_at", side.__dict__.get("now", 0))

    def get_dry(self):
        if self.spec.get("wick"):
            pay_in_seasons(self)
        if earlier is not None:
            return earlier.fget(self)
        return self.__dict__.get("_dry_at")

    def set_dry(self, value):
        self.__dict__["_dry_at"] = value

    def layer_points(att, dfn, t, extra, channel):
        x = original_points(att, dfn, t, extra, channel)
        family = channel.split(":")[0]
        w = att.spec.get("wick")
        if w and family in w["channels"]:
            x[w["layer"] - 1] += w["points_per"] * (40 - seasons(att))
        g = att.spec.get("given_years")
        if g and family in g["channels"]:
            x[g["layer"] - 1] += g["points_per"] * g["share_pct"]
        n = att.spec.get("nothing_to_lose")
        if n and w and family in n["channels"]:
            own = max(seasons(att), 1) / 4.0
            theirs = dfn.spec.get("years_left", n["enemy_share"] * LIFESPAN[dfn.r])
            x[n["layer"] - 1] += min(n["cap"], max(0.0, n["points_per"] * math.log(theirs / own, 2)))
        return x

    def guard_true(g, own, enemy, t):
        ok = original_guard(g, own, enemy, t)
        if ok and g and "wick_below" in g and own.spec.get("wick"):
            return seasons(own) <= g["wick_below"]
        return ok

    def report_result(res, build):
        original_report(res, build)
        a = res["a"]
        if a.spec.get("wick"):
            left = seasons(a)
            burned = a.spec["wick"]["seasons"] - left
            print("wick	burned %.1f seasons (%.2f years), %.1f of them by blows, %.1f left%s" % (
                burned, burned / 4.0, a.__dict__.get("paid", 0.0), left,
                "	THE DAY CAME" if a.__dict__.get("date_at") is not None else ""))

    f.pulse = pulse
    f.Side.dry_at = property(get_dry, set_dry)
    f.layer_points = layer_points
    f.guard_true = guard_true
    f.report_result = report_result
