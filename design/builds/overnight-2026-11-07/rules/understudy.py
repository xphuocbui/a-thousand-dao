"""The Understudy (The Than): evade stops being a roll and becomes a schedule.

Asked for with "understudy": {"start": 1.0, "bank": 2.0, "mark": 0.08, "read_soul": true}, on a side
with evade_pct. While this plug-in runs, that side's evade is not an expected-value discount. Instead:

  Each body or qi hit aimed at the side fills the Curtain by p_evade, which is Formulas I as written:
  clamp(evade - accuracy, 0, evade_cap), then x min(1, own sense / attacker's sense) if "read_soul".
  The Curtain holds at most "bank". The Mark is a saved loadout value, like a guard: a share of your
  maximum health. When the Curtain holds 1 or more and the hit's size, before ward and guard, is at
  least mark x maximum health, the Curtain pays 1 and the hit lands on the double: it deals nothing,
  drains nothing, fires no on-hit trigger. The attacker's cost stays paid.

  By count, at most p_evade of the hits miss, so evade_cap holds. "mark": 0 is plain evade on a fixed
  schedule, with no choice of hit.

An art with "curtain": n adds n to the Curtain when it fires (Costume Change), times the same soul
ratio. Those misses are bought with linh luc, not rolled, so they stand outside evade_cap. The count in
the report shows by how much. An attacker whose accuracy reaches your evade sees through the double:
the hit lands and the Curtain neither fills nor pays. So evade past the cap is margin against accuracy.

Ticks and soul arts do not pass through strike, so they neither fill the Curtain nor meet it.

Sets own.cue_t to the instant of the last miss and own.curtain_hits to the count (read by cue.py). Adds
returned_force x the hit's coefficient to own.returned, which catching_hand.py spends on the next basic
attack. With this plug-in skipped, evade_pct falls back to the calculator's expected value.
"""


def install(f):
    strike, report_result, resolve_art = f.strike, f.report_result, f.resolve_art

    def state(side):
        u = side.spec.get("understudy")
        if not u:
            return None
        st = side.__dict__.get("curtain")
        if st is None:
            st = {"meter": float(u.get("start", 0.0)), "n": 0, "total": 0.0, "evade": side.evade,
                  "missed": [], "landed": 0.0, "aimed": 0.0}
            side.evade = 0.0
            side.curtain = st
            side.curtain_hits = 0
        return st

    def hit(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        st = state(dfn)
        if st is None:
            return strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        u = dfn.spec["understudy"]
        if st["evade"] - att.accuracy <= 0:
            st["n"] += 1
            dfn.note("double_seen_through")
            return strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        p = max(0.0, min(st["evade"] - att.accuracy, f.K["evade_cap"]))
        if u.get("read_soul"):
            p *= min(1.0, dfn.sense / att.sense)
        st["meter"] = min(u.get("bank", 2.0), st["meter"] + p)
        x = f.layer_points(att, dfn, t, extra, channel)
        size = att.u * att.stage * c * f.multiplier(x, skip_l5=(channel == "trigger")) \
            * (att.crit_ev if crit else 1.0) * f.supp(gap, att.pierce)
        st["n"] += 1
        st["total"] += size
        st["aimed"] += size
        if st["meter"] >= 1.0 - 1e-9 and size >= u.get("mark", 0.0) * dfn.health_max - 1e-9:
            st["meter"] -= 1.0
            st["missed"].append((t, channel, size))
            dfn.cue_t = t
            dfn.curtain_hits += 1
            dfn.returned = dfn.__dict__.get("returned", 0.0) + dfn.spec.get("returned_force", 0) * c
            return 0.0
        st["landed"] += size
        return strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)

    def resolve(att, dfn, art, t, gap):
        add = art.get("curtain")
        st = state(att)
        if add and st is not None:
            u = att.spec["understudy"]
            if u.get("read_soul"):
                add *= min(1.0, att.sense / dfn.sense)
            st["meter"] = min(u.get("bank", 2.0), st["meter"] + add)
            st["bought"] = st.get("bought", 0.0) + add
        return resolve_art(att, dfn, art, t, gap)

    def report(res, build):
        report_result(res, build)
        st = res["a"].__dict__.get("curtain")
        if st:
            miss = sum(m[2] for m in st["missed"])
            print("curtain\thits aimed %d\ton the double %d (%.0f%% by count, %.0f%% by size)" % (
                st["n"], len(st["missed"]), 100.0 * len(st["missed"]) / max(st["n"], 1),
                100.0 * miss / max(st["aimed"], 1e-9)))
            print("curtain_list\t" + ", ".join("%s@%.1f" % (m[1].replace("art:", ""), m[0] / 1000.0)
                                                for m in st["missed"][:16]))

    f.strike, f.report_result, f.resolve_art = hit, report, resolve
