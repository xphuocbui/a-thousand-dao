"""Prints how many Rehearsal scripts win, for a build with "called_blow". An observation tool,
not a rule. Asked for with "rehearsal_grid": {"step": 0.05, "mixed": {arts...}} on a fight file.

It walks crit_start and evade_start from 0 to just under 1, and fights the typical enemy and the
mixed enemy (the given arts) at the same realm and one up. It prints how many starts win both
one-up fights, how many lose both, and the best start for each kind of result.
"""
import copy


def install(f):
    report0 = f.report_layers

    def report(build):
        report0(build)
        grid = build.get("rehearsal_grid")
        if not grid:
            return
        n = int(round(1 / grid["step"]))
        r = f.REALMS.index(build["realm"])
        counts = {}
        for i in range(n):
            for j in range(n):
                b = copy.deepcopy(build)
                b["called_blow"] = {"crit_start": i / n, "evade_start": j / n}
                row = []
                for over in (None, grid["mixed"]):
                    e = f.merge(f.typical(r + 1), {"arts": over["arts"]} if over else None)
                    row.append(f.run_fight(b, e, gap_a=1, gap_b=0)["winner"] == b["name"])
                counts[tuple(row)] = counts.get(tuple(row), 0) + 1
        print("rehearsal_grid\tscripts %d\twin both one-up fights %d\twin typical only %d\twin mixed only %d\tlose both %d" % (
            n * n, counts.get((True, True), 0), counts.get((True, False), 0), counts.get((False, True), 0),
            counts.get((False, False), 0)))

    f.report_layers = report
