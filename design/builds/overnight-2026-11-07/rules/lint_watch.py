"""Lint Watch: reads the art lint at the moment an art fires, and tries candidate repairs.

Asked for with "lint_watch": {"fix": "none"}. The lint (Combat Formulas C) checks an authored record:
c_art <= 1 + 12 x cost_share + 0.25 x (cooldown - 1). This plug-in reports the same sum for what
really happened at each firing: the coefficient that fired, the linh luc share paid, the seconds really
waited since the last firing. It judges nothing. It prints:

  lint_fired  art, time, c fired, cost share, seconds waited, the lint's price for those two
  lint_total  coefficient fired, coefficient the lint sells for what was paid, seconds skipped

"fix" names one candidate repair, for the side that asks only:
  "none"    observe only.
  "flat"    Flat base counts: the fired coefficient stops at the record's own lint.
  "served"  the cooldown term is earned: 0.25 x (cooldown - 1) is scaled by the share of the
            effective cooldown really waited (art speed is not punished), floor 1 + 12 x cost.
  "gated"   the cooldown term needs linh luc: 0.25 x (cooldown - 1) x min(1, cost / "gate"),
            default gate 0.15. An authored c_art past that is cut; flat additions stay.
  "stored"  Standing Water becomes a pool: "stored_seconds" at the first pulse, spent in slot
            order. An art the pool cannot fully pay keeps the rest of its timer.

List it FIRST under "rules", so it sits inside withheld_hand and sees what really fires, and so its
pulse runs before already_waited pays.
"""


def install(f):
    resolve_art, pulse, report_result = f.resolve_art, f.pulse, f.report_result

    def lint(cost, seconds):
        return (f.K["basic_coef"] * (1 + f.K["art_coef_per_cost"] * cost)
                + f.K["art_coef_per_cooldown"] * (max(seconds, 1) - 1))

    def authored(side, art):
        for a in side.spec.get("arts", []):
            if a.get("id") == art.get("id"):
                return a.get("c_art", 0)
        return art.get("c_art", 0)

    def resolve(att, dfn, art, t, gap):
        w = att.spec.get("lint_watch")
        if not w or art.get("c_art", 0) <= 0:
            return resolve_art(att, dfn, art, t, gap)
        fired = art["fired"]
        prev = fired[-2] if len(fired) > 1 else 0
        waited = (t - prev) / 1000.0
        cost, cd = art.get("cost_share", 0), art["cooldown"]
        c = art["c_art"]
        term = f.K["art_coef_per_cooldown"] * (cd - 1)
        fix = w.get("fix", "none")
        if fix == "flat":
            c = min(c, lint(cost, cd))
        elif fix == "served":
            share = min(1.0, (t - prev) / float(art["cd_ms"]))
            c = max(lint(cost, 1), c - term * (1 - share))
        elif fix == "gated":
            allowed = lint(cost, 1) + term * min(1.0, cost / w.get("gate", 0.15))
            c -= max(0.0, authored(att, art) - allowed)
        log = att.__dict__.setdefault("lint_log", [])
        log.append((t, art["id"], c, cost, waited, lint(cost, waited),
                    max(0.0, art["cd_ms"] / 1000.0 - waited)))
        return resolve_art(att, dfn, dict(art, c_art=c), t, gap)

    def tick(side, enemy, gap_of_enemy, t):
        pulse(side, enemy, gap_of_enemy, t)
        w = side.spec.get("lint_watch")
        if not w or w.get("fix") != "stored" or t != f.ms(f.K["pulse_interval"]):
            return
        pool = f.ms(w.get("stored_seconds", 20))
        for art in side.arts:
            if not art.get("laid"):
                continue
            need = art["cd_ms"] - t
            paid = min(need, pool)
            pool -= paid
            art["ready"] = art["cd_ms"] - paid

    def report(res, build):
        report_result(res, build)
        log = res["a"].__dict__.get("lint_log")
        if log is None:
            return
        for t, art, c, cost, waited, sold, _ in log[:14]:
            print("lint_fired\t%s\tt %.0f\tc %.2f\tcost %.2f\twaited %.0f s\tlint for that %.2f" % (
                art, t / 1000.0, c, cost, waited, sold))
        print("lint_total\tfired %.1f\tlint sells %.1f\tseconds skipped %.0f" % (
            sum(r[2] for r in log), sum(r[5] for r in log), sum(r[6] for r in log)))

    f.resolve_art, f.pulse, f.report_result = resolve, tick, report
