"""Broad Back (Khoan Bối): an Overflow. The c_comp that c_comp_cap clips becomes a share of each
blow the companion takes for its owner.

Asked for with "broad_back": {"c_raw": 5.0, "share_per": 0.1, "cap": 0.4}. c_raw is the
companion's coefficient before the cap (Formulas J). Each 1.0 the cap clips moves share_per of
every hit that reaches the owner's health onto the companion, up to cap, and only of what the
owner still had: overkill is not moved. The moved part is met by the companion's own body guard (from "stand") and adds to its wounds. A companion
whose wounds reach its health is dead: it stops acting and cannot stand. Reads its health
and guard from "stand", so it needs that block.
"""


def install(f):
    original = f.strike
    original_report = f.report_result

    def beast_health(s):
        st = s.spec["stand"]
        comp = s.companion
        r = f.REALMS.index(comp["realm"]) if "realm" in comp else s.r
        return f.K["health_units"] * f.fight_unit(r) * st.get("n_body", 1.0) * st.get("share", 1.0)

    def beast_factor(s, kind):
        st = s.spec["stand"]
        g = st.get("guard", {})
        raw = (f.K["guard_base"] + g.get("a_b", 0) + g.get("t_b", 0)
               + f.K["guard_pool_slope"] * (st.get("n_body", 1.0) - 1)) * (1 + g.get("body_guard_pct", 0) / 100.0)
        raw = min(f.K["guard_cap"], raw)
        mit = f.K["guard_max_mit"] * raw / (raw + f.K["guard_half"])
        return 1 - mit * (f.K["guard_share_body"] if kind == "body" else f.K["guard_share_qi"])

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        before = dfn.health
        out = original(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        b = dfn.spec.get("broad_back")
        if b and dfn.companion and not dfn.__dict__.get("standing"):
            clipped = max(0.0, b["c_raw"] - dfn.companion.get("c_comp", 0))
            share = min(b.get("cap", 1.0), clipped * b["share_per"])
            moved = min(before - dfn.health, max(before, 0.0)) * share
            if moved > 0:
                dfn.health += moved
                dfn.dmg_taken_instant -= moved
                own = dfn.guard_factor(kind)
                dfn.beast_wound = dfn.__dict__.get("beast_wound", 0.0) \
                    + moved / max(own, 1e-9) * beast_factor(dfn, kind)
                if dfn.beast_wound >= beast_health(dfn):
                    dfn.companion = None
                    dfn.comp_next = None
                    dfn.beast_died_at = t
        return out

    def report_result(res, build):
        original_report(res, build)
        a = res["a"]
        if a.__dict__.get("beast_died_at") is not None:
            print("beast_died_at\t%.3f s" % (a.beast_died_at / 1000.0))
        elif a.spec.get("broad_back"):
            print("beast_wound_before_stand\t%.1f" % a.__dict__.get("beast_wound", 0.0))

    f.strike = strike
    f.report_result = report_result
