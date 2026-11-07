"""Short Stick. Foreseen fights only: time_limit falls by half for a fight whose build asks
with "short_stick": true.
"""


def install(f):
    run_fight = f.run_fight

    def run(a, b, gap_a=0, gap_b=0, record=None):
        limit = f.K["time_limit"]
        if a.get("short_stick") or b.get("short_stick"):
            f.K["time_limit"] = limit / 2
        try:
            return run_fight(a, b, gap_a, gap_b, record)
        finally:
            f.K["time_limit"] = limit

    f.run_fight = run
