"""Thu Lôi (Lightning Rod), a Ground Law from The Level Ground's concept.

Asked for with "thu_loi": {"element": "hoa", "needs_tag": "tribulation"} and "ground_tags": [...],
listed after element_tags. While the side's ground_tags hold needs_tag, every art hit by the other
side carries that element and no other: it replaces the art's own element and the side's. Basic
attacks and companions still carry none (rule 13), and ticks and soul arts never reach a ward. On
ground without the tag the law is not up and the other side's own element stands.

Only the asking side's opponent is touched. `--without thu_loi` removes the law, so a boss then
hits with the element its own file gives it.
"""


def install(f):
    original = f.run_fight

    def run_fight(a_spec, b_spec, gap_a=0, gap_b=0, record=None):
        law = a_spec.get("thu_loi")
        if law and law.get("needs_tag") in a_spec.get("ground_tags", []):
            arts = [{k: v for k, v in art.items() if k != "element"} for art in b_spec.get("arts", [])]
            b_spec = dict(b_spec, element=law["element"], arts=arts)
        return original(a_spec, b_spec, gap_a, gap_b, record)

    f.run_fight = run_fight
