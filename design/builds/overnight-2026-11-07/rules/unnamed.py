"""Unnamed (Vô Danh Ấn) and Borrowed Name (Mạo Danh).

Asked for with "unnamed_status": "unnamed", the id of a status this side applies.
While the other side has that status, its hits lose all of L2: their tags are gone.

"borrowed_name": 0.75. While the other side has the status, this side's art hits gain
that share of the L2 in the other side's own layers. Read live, so it fits any enemy.
"""


def install(f):
    original = f.layer_points

    def has(side, status):
        return any(s["id"] == status for s in side.statuses)

    def layer_points(att, dfn, t, extra, channel):
        x = original(att, dfn, t, extra, channel)
        if dfn.spec.get("unnamed_status") and has(att, dfn.spec["unnamed_status"]):
            x[1] = 0
        share = att.spec.get("borrowed_name", 0)
        if share and channel.startswith("art") and has(dfn, att.spec.get("unnamed_status")):
            x[1] += share * max(dfn.x[1], 0)
        return x

    f.layer_points = layer_points
