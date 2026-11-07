"""Feeding-Back Ward. A side's ward returns blocked damage to the attacker's linh luc.

Asked for with "ward_return": 1.3 (1.0 from the ward, +0.3 from Strong Decoction).
Only what a ward blocks is returned. A return from one hit is at most the pool the
attacker holds ("empty_refuses": false turns that off). What passes the attacker's
maximum is Surfeit, up to "surfeit_cap" of it; what that clips waits for Deep Abscess.
"""


def install(f):
    apply_ward, report_result = f.apply_ward, f.report_result

    def ward(dfn, att, d, kind):
        leak = apply_ward(dfn, att, d, kind)
        rate = dfn.spec.get("ward_return", 0)
        if rate and d > leak:
            give = (d - leak) * rate
            if dfn.spec.get("empty_refuses", True):
                give = min(give, att.qi)
            fed = min(give, att.qi_cap - att.qi)
            att.qi += fed
            cap = dfn.spec.get("surfeit_cap", 1.0) * att.qi_max
            raw = getattr(att, "surfeit", 0.0) + give - fed
            att.surfeit_clip = getattr(att, "surfeit_clip", 0.0) + max(raw - cap, 0.0)
            att.surfeit = min(cap, raw)
            dfn.returned = getattr(dfn, "returned", 0.0) + give
        return leak

    def report(res, build):
        report_result(res, build)
        a, b = res["a"], res["b"]
        if a.spec.get("ward_return"):
            print("returned\t%.0f\tenemy linh luc maximum %.0f\tsurfeit at the end %.0f%%" % (
                getattr(a, "returned", 0.0), b.qi_max, 100 * getattr(b, "surfeit", 0.0) / b.qi_max))

    f.apply_ward, f.report_result = ward, report
