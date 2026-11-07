"""Turning Phase (Chuyển Hành), the keystone of the Way of Generation and Overcoming.

Asked for with "turning_phase": {"pre_read": false}, listed after element_tags.
When an enemy art hit carrying an element reaches this side, the side has read that element:
from the next hit on, its ward takes the phase that element generates (one step on the
cycle), and its own ring arts run that phase, then the next, then the next, which is always
the element that overcomes what it read. The hit that teaches it is not Fed.

"pre_read": true reads the enemy's element at t = 0 (Set Table).
"""


def install(f):
    step = f.element_step
    original_tags = f.element_art_tags
    original_on_hit = f.element_on_hit
    original_target = f.element_target

    class Side(f.Side):
        def __init__(self, spec, name):
            super().__init__(spec, name)
            self.read = None
            self.phase = None

    f.Side = Side

    def art_tags(att, dfn, art):
        tp = att.spec.get("turning_phase")
        if tp is None:
            return original_tags(att, dfn, art)
        if att.read is None and tp.get("pre_read"):
            read(att, dfn.spec.get("element") or att.spec.get("assumed_enemy_element"))
        if att.read is None:
            return original_tags(att, dfn, art)
        return [step(att.read, 1), step(att.read, 2), step(att.read, 3)]

    def read(side, element):
        side.read = element
        side.phase = step(element) if element else None

    def on_hit(att, dfn, tags, t):
        original_on_hit(att, dfn, tags, t)
        tp = dfn.spec.get("turning_phase")
        if tp is None or dfn.read == tags[0]:
            return
        read(dfn, tags[0])
        dfn.note("turned")

    def target(att, dfn):
        if att.spec.get("turning_phase") is not None and att.read:
            return att.read
        return original_target(att, dfn)

    f.element_art_tags = art_tags
    f.element_on_hit = on_hit
    f.element_target = target
