"""The Cut Line's soul rules. Each is a top-level key, so --without [key] removes that one piece.

"sense_sheet": {"than_hon", "stage", "than_thuc_pct"}   divine_sense, Character Stats Formulas C,
    before M_ts. Sets the side's divine_sense.
"light_hand": {"heart_demon", "under", "points_per"}     Per: +points_per than_thuc_pct for each point
    of heart demon under "under". Needs sense_sheet.
"open_sky": {"ws_per_pct": n, "free_pct": p}             Borrow: free thần thức adds to ward strength.
"along_the_thread": {"bound_share": 0.5, "assumed_used": 0.75}
    Rule swap: on your soul arts, thần thức the defender has bound to artifacts counts at
    (1 - bound_share). Read from the defender's "thought": {"held", "used"} if it has one, else
    assumed_used. Assumed values are stated in the sheet.
"running_line": {"floor": 0.1}                           Overflow: the part of a soul art's share that
    soul_cap clips shortens soul_lockout to soul_lockout x soul_cap / raw share, floor in seconds.
"unseen_hand": 60                                        Conditional: +x_soul while at full health.
Curse field "sense_shred": lowers the defender's divine sense on your soul arts, capped at
    "sense_shred_max" (0.5). Curses still use curse_slots and durations.
"""


def install(f):
    original_init = f.Side.__init__
    original_resolve = f.resolve_art
    original_report = f.report_result

    def init(self, spec, name):
        sheet = spec.get("sense_sheet")
        if sheet:
            pct = sheet["than_thuc_pct"]
            lh = spec.get("light_hand")
            if lh:
                pct += lh["points_per"] * max(0, lh["under"] - lh["heart_demon"])
            spec = dict(spec, divine_sense=sheet["than_hon"] * sheet["stage"] * (1 + pct / 100.0))
        sky = spec.get("open_sky")
        if sky:
            w = dict(spec["ward"])
            w["ws"] = w.get("ws", 0) + sky["ws_per_pct"] * sky["free_pct"]
            spec = dict(spec, ward=w)
        original_init(self, spec, name)

    def defender_sense(att, dfn):
        sense = dfn.sense
        thread = att.spec.get("along_the_thread")
        if thread:
            th = dfn.spec.get("thought")
            used = th["used"] / float(th["held"]) if th else thread["assumed_used"]
            sense *= 1 - thread["bound_share"] * used
        shred = min(dfn.curse_sum("sense_shred"), att.spec.get("sense_shred_max", 0.5))
        return sense * (1 - shred)

    def resolve_art(att, dfn, art, t, gap):
        spec = att.spec
        asks = any(k in spec for k in ("along_the_thread", "running_line", "unseen_hand", "sense_shred_max"))
        if not art.get("soul_pct") or not asks:
            return original_resolve(att, dfn, art, t, gap)
        saved_sense, saved_x = dfn.sense, att.x_soul
        dfn.sense = defender_sense(att, dfn)
        if spec.get("unseen_hand") and att.health >= att.health_max - 1e-9:
            att.x_soul += spec["unseen_hand"]
        rho = att.sense / (dfn.sense * (1 + dfn.soul_res / 100.0))
        raw = art["soul_pct"] * (1 + att.x_soul / 100.0) * rho ** f.K["soul_beta"] * f.supp(gap, att.pierce)
        if rho < f.K["rho_min"]:
            raw = 0.0
        log = att.__dict__.setdefault("soul_log", [])
        log.append((t, round(rho, 2), round(raw, 3)))
        out = original_resolve(att, dfn, art, t, gap)
        dfn.sense, att.x_soul = saved_sense, saved_x
        line = spec.get("running_line")
        if line and raw > f.K["soul_cap"]:
            lock = f.K["soul_lockout"] * f.K["soul_cap"] / raw
            att.lock_until = t + f.ms(max(lock, line["floor"]))
            att.note("soul_cap_clipped")
        elif raw > f.K["soul_cap"]:
            att.note("soul_cap_clipped")
        return out

    def report_result(res, build):
        original_report(res, build)
        log = res["a"].__dict__.get("soul_log")
        if log:
            print("soul_hits\t%d\t%s" % (len(log), "  ".join(
                "%.3fs rho %.2f raw %.3f" % (x / 1000.0, r, w) for x, r, w in log[:8])))

    f.Side.__init__ = init
    f.resolve_art = resolve_art
    f.report_result = report_result
