"""The Five Courses (Ngu Vi Tich) and two modifiers that hang on them.

Asked for by an art with "courses": a list of {"element", "kind", "l4", "tag"}, in the
order they were loaded. Each firing serves the next course. Fights use the art's own
c_art, cost and cooldown; give the art "stock" equal to the number of courses, so the
furnace stops when the table is cleared.

  - a course keeps every earlier course's L4, as a conversion keeps its tags
    (Combat rule 6), so a served course adds its coating's points to a running total
  - a course whose element the last course did not generate breaks the chain: the
    total falls to 0 before this course is added (Five Phases Cycle, in catalogue)
  - "fine_work": q (top-level) multiplies each coating's points by 1 + 0.2 q
  - "boiled_over": c (top-level): each L4 point the layer cap clips on a course becomes
    c of c_tick on a body tick called scald, 3 pulses, a stack per clipping course
  - "cooks_hand": points (top-level) with "alchemy_level": n adds points x n to L2 on
    a served course

--without five_courses leaves a plain art with the same c_art, kind, cost and stock.
--without fine_work, boiled_over or cooks_hand removes one modifier each.
"""

CYCLE = ["wood", "fire", "earth", "metal", "water"]


def install(f):
    resolve = f.resolve_art

    def serve(att, dfn, art, t, gap):
        courses = art.get("courses")
        if not courses:
            return resolve(att, dfn, art, t, gap)
        i = min(len(art["fired"]) - 1, len(courses) - 1)
        course = courses[i]
        if i > 0:
            prev = courses[i - 1]["element"]
            if CYCLE[(CYCLE.index(prev) + 1) % 5] != course["element"]:
                art["table"] = 0.0
                att.note("chain_broken")
        q = att.spec.get("fine_work", 0)
        art["table"] = art.get("table", 0.0) + course.get("l4", 0) * (1 + 0.2 * q)
        x = list(art.get("x", [0, 0, 0, 0, 0]))
        x[1] += att.spec.get("cooks_hand", 0) * att.spec.get("alchemy_level", 0)
        x[3] += art["table"]
        over = att.x[3] + x[3] - f.K["layer_caps"][3]
        c_tick = att.spec.get("boiled_over", 0) * max(over, 0)
        served = dict(art)
        served["x"] = x
        served["kind"] = course["kind"]
        served.pop("courses")
        resolve(att, dfn, served, t, gap)
        if c_tick > 0:
            att.note("l4_clipped_courses")
            f.apply_status(att, dfn, {"id": "scald", "kind": "body", "c_tick": c_tick,
                                      "duration": 3, "stacks": 1,
                                      "x": [0, 0, 0, min(x[3], f.K["layer_caps"][3]), 0]}, t)

    f.resolve_art = serve
