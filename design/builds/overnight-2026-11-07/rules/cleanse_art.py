"""A cleanse art, for shaping a counter enemy. Combat rule 8 names the art; the calculator has none.

Asked for per art with "cleanse": n. When the art fires, the n statuses with the most stacks on
its caster are removed. It clears curses too only with "cleanse_curses": true.
"""


def install(f):
    original = f.resolve_art

    def resolve_art(att, dfn, art, t, gap):
        n = art.get("cleanse", 0)
        if n:
            worst = sorted(att.statuses, key=lambda s: -s["stacks"])[:n]
            att.statuses = [s for s in att.statuses if s not in worst]
            if art.get("cleanse_curses"):
                att.curses = []
        return original(att, dfn, art, t, gap)

    f.resolve_art = resolve_art
