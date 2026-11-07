"""Layer lock (Stilled Hand). A curse with "layer_lock": true zeroes the cursed side's largest
layer on every hit while it lasts. "locks one enemy layer": which one is a first guess, and
this takes the worst for them.
"""


def install(f):
    layer_points = f.layer_points

    def points(att, dfn, t, extra, channel):
        x = layer_points(att, dfn, t, extra, channel)
        if any(c.get("layer_lock") for c in att.curses):
            x[x.index(max(x))] = 0
        return x

    f.layer_points = points
