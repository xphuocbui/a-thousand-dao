"""Bitter Tithe (Khổ Thuế): arts paid from one shared magazine of đan độc.

Asked for with "bitter_tithe": {"magazine": 80, "cost": 2}, and on each paid art a guard
with "tithe": true. Write that guard as {"time_above": 0, "tithe": true}: the calculator
reads it as always true, so --without bitter_tithe gives the same arts, free and endless.
Paid arts must have cost_share 0, because guard_true is the last check before a firing
and this plug-in takes the payment there. An art with too little đan độc waits.
"""


def install(f):
    original_guard = f.guard_true
    original_report = f.report_result

    def guard_true(g, own, enemy, t):
        ok = original_guard(g, own, enemy, t)
        tithe = own.spec.get("bitter_tithe")
        if not ok or not g or not g.get("tithe") or not tithe:
            return ok
        spent = own.__dict__.get("tithe_spent", 0)
        if spent + tithe["cost"] > tithe["magazine"]:
            own.note("tithe_magazine_empty")
            return False
        own.tithe_spent = spent + tithe["cost"]
        return True

    def report_result(res, build):
        original_report(res, build)
        a = res["a"]
        if a.spec.get("bitter_tithe"):
            print("tithe_spent\t%d of %d" % (a.__dict__.get("tithe_spent", 0), a.spec["bitter_tithe"]["magazine"]))

    f.guard_true = guard_true
    f.report_result = report_result
