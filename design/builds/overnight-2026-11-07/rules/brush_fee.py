"""Brush Fee. A Rubbing's cost is charged to the original's caster, all of it before
the first copy lands. They pay what they have.

Asked for with "brush_fee": true. Each Rubbing charges the original's cost times its
own "copy_fee" (default 1), after that art's own cost is paid. Needs the rubbing rule.
"""


def install(f):
    resolve_art, report_result = f.resolve_art, f.report_result

    def resolve(att, dfn, art, t, gap):
        if art.get("rubbing") and att.spec.get("brush_fee") and getattr(att, "fee_t", None) != t:
            att.fee_t = t
            source = next((a for a in dfn.arts if t in a["fired"]), None)
            if source is not None:
                raised = min(dfn.curse_sum("cost_raise"), f.K["curse_cost_raise_max"])
                share = source.get("cost_share", 0) * (1 - dfn.cost_red) * (1 + raised)
                shares = sum(a.get("copy_fee", 1.0) for a in att.arts
                             if a.get("rubbing") and t in a["fired"])
                paid = min(share * shares * dfn.qi_max, dfn.qi)
                dfn.qi -= paid
                att.fees_paid = getattr(att, "fees_paid", 0.0) + paid
        return resolve_art(att, dfn, art, t, gap)

    def report(res, build):
        report_result(res, build)
        if res["a"].spec.get("brush_fee"):
            print("fees_paid_by_enemy\t%.1f linh luc" % getattr(res["a"], "fees_paid", 0.0))

    f.resolve_art, f.report_result = resolve, report
