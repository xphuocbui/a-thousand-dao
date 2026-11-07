"""Patronage. When the enemy cannot afford a ready art, you pay its cost, while your
pool is above that cost. Their art then fires and can be copied.

Asked for with "patronage": true. Works through a Rubbing's guard, which is read first
in the cost step, so it needs the rubbing rule. Pays once per art per instant.

Asked for with "patronage_open": true, it needs no Rubbing: the same payment is made when the
enemy's own art is checked. Added for The Loud Sword, who wants the blow, not a copy of it.
"""


def install(f):
    guard_true, report_result = f.guard_true, f.report_result

    def pay_open(patron, debtor, t):
        raised = min(debtor.curse_sum("cost_raise"), f.K["curse_cost_raise_max"])
        for art in debtor.arts:
            if art["ready"] > t or art.get("stock_left") == 0 or art.get("patron_t") == t:
                continue
            if not guard_true(art.get("guard"), debtor, patron, t):
                continue
            cost = art.get("cost_share", 0) * (1 - debtor.cost_red) * (1 + raised) * debtor.qi_max
            if debtor.qi < cost - 1e-6 and patron.qi > cost:
                art["patron_t"] = t
                patron.qi -= cost
                debtor.qi += cost
                patron.patron_paid = getattr(patron, "patron_paid", 0.0) + cost

    def guard(g, own, enemy, t):
        if enemy.spec.get("patronage_open") and not own.spec.get("patronage_open"):
            pay_open(enemy, own, t)
        if g and g.get("copies_enemy") and own.spec.get("patronage"):
            raised = min(enemy.curse_sum("cost_raise"), f.K["curse_cost_raise_max"])
            for art in enemy.arts:
                if art["ready"] > t or art.get("stock_left") == 0 or art.get("patron_t") == t:
                    continue
                if not f.guard_true(art.get("guard"), enemy, own, t):
                    continue
                cost = art.get("cost_share", 0) * (1 - enemy.cost_red) * (1 + raised) * enemy.qi_max
                if enemy.qi < cost - 1e-6 and own.qi > cost:
                    art["patron_t"] = t
                    own.qi -= cost
                    enemy.qi += cost
                    own.patron_paid = getattr(own, "patron_paid", 0.0) + cost
        return guard_true(g, own, enemy, t)

    def report(res, build):
        report_result(res, build)
        if res["a"].spec.get("patronage") or res["a"].spec.get("patronage_open"):
            print("patronage_paid\t%.1f linh luc" % getattr(res["a"], "patron_paid", 0.0))

    f.guard_true, f.report_result = guard, report
