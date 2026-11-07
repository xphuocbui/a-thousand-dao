"""Example plug-in. Copy this shape; it is not used by any build.

Asked for with "rules": ["_example_ward_return"] and "ward_return_share": 0.2 in a
fight file. A share of what a side's ward blocks is dealt straight back.
"""


def install(f):
    original = f.apply_ward

    def apply_ward(dfn, att, d, kind):
        leak = original(dfn, att, d, kind)
        share = dfn.spec.get("ward_return_share", 0)  # only sides that ask for it
        if share:
            back = (d - leak) * share
            att.health -= back
            att.dmg_taken_instant += back
            f.add_dmg(dfn, "ward_return", back)
        return leak

    f.apply_ward = apply_ward
