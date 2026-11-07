"""A cap on a "per X" modifier, such as Sustained Note's +90.

Asked for with "cap": points on a conditional_mods entry that has "per".
"""


def install(f):
    original = f.scale_value

    def scale_value(c, att, dfn, t):
        value = original(c, att, dfn, t)
        return min(value, c["cap"]) if "cap" in c else value

    f.scale_value = scale_value
