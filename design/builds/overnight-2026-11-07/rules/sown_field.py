"""Sown Field (Hoạt Lũng). Your spirit field grows in the enemy. The plots are read from the file.

Asked for with "sown_field": {"plots": [{"herb": id, "age": years, "n": count}, ...], "c_crop": 0.08,
"kind": "body", "reserve_per_plot": 0.01, "x": [L1..L5 points for every crop]}.

Each plot is an aura (a permanent tick with no slot, applied at t = 0) with c_tick = c_crop x potency,
and potency is the live game's: 1 + 0.5 x log2(age / mature_years), clamped to 0.1 and 5
(item_factory.gd, items_herbs.json). Each plot is its own status, so it has its own pool cap, and
all plots share the pulse cap. Each plot holds reserve_per_plot of your linh lực for the fight
(the calculator's reserve_share). A side with no "sown_field" is not touched.
"""
import json
import math
import os


def install(f):
    original = f.run_fight
    here = os.path.dirname(os.path.abspath(__file__))
    repo = os.path.join(here, "..", "..", "..", "..")
    with open(os.path.join(repo, "assets", "data", "items_herbs.json"), encoding="utf-8") as h:
        data = json.load(h)
    mature = {r["id"]: float(r["mature_years"]) for r in data["herbs"]}
    per, top = data["potency"]["per_doubling"], data["potency"]["max_potency"]

    def potency(herb, age):
        return max(0.1, min(top, 1 + per * math.log(max(age, 0.01) / mature[herb], 2)))

    def expand(spec):
        field = spec.get("sown_field")
        if not field:
            return spec
        spec = dict(spec)
        aura = list(spec.get("aura", []))
        count = 0
        for p in field["plots"]:
            for _ in range(p.get("n", 1)):
                count += 1
                aura.append({"id": "plot_%d" % count, "kind": field.get("kind", "body"), "stacks": 1,
                             "c_tick": field["c_crop"] * potency(p["herb"], p["age"]),
                             "x": field.get("x", [0, 0, 0, 0, 0])})
        spec["aura"] = aura
        spec["reserve_share"] = spec.get("reserve_share", 0.0) + count * field.get("reserve_per_plot", 0.0)
        return spec

    def run_fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        return original(expand(a_spec), expand(b_spec), gap_a, gap_b, record)

    f.run_fight = run_fight
