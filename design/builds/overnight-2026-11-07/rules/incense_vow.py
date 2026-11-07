"""Incense Vow. A stalemate counts as a win for a side with "incense_vow": true, when the
other side opened the fight. The calculator's result line still says stalemate; this
prints what the Vow makes of it. Who opened the fight is not simulated.
"""


def install(f):
    report_result = f.report_result

    def report(res, build):
        report_result(res, build)
        if res["a"].spec.get("incense_vow") and res["end"] == "stalemate":
            print("vow\tstalemate counts as a win, if the other side opened the fight")

    f.report_result = report
