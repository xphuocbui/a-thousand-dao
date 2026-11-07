"""A per scale for conditional_mods: "demon_pool", the heart demon held now.

Reads the live pool of Already Waited if that rule is running. With it skipped, reads the
heart demon carried into the fight, because the demon is still there and only stops paying.
"""


def install(f):
    original = f.scale_value

    def scale_value(c, att, dfn, t):
        if c.get("per") == "demon_pool":
            live = att.__dict__.get("demon")
            held = live["pool"] if live else att.spec.get("waited", {}).get("pool", 0)
            return c.get("points_per", 0) * held
        return original(c, att, dfn, t)

    f.scale_value = scale_value
