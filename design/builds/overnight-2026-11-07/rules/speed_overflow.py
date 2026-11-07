"""Art speed that cooldown_min clips becomes points (Overheat).

Asked for with "speed_overflow": {"layer": 5, "channels": ["art"], "cap": 30}. "cap" is
optional. Each art is read on its own: the clipped speed is the art speed above what that
art's cooldown needs to reach the floor, 1 point per 1 %. An art that does not reach the
floor gives nothing, and with no art speed nothing is clipped.
"""


def install(f):
    original = f.layer_points

    def layer_points(att, dfn, t, extra, channel):
        x = original(att, dfn, t, extra, channel)
        o = att.spec.get("speed_overflow")
        family, _, art_id = channel.partition(":")
        if o and art_id and family in o.get("channels", ["art"]):
            art = next((a for a in att.arts if a["id"] == art_id), None)
            if art:
                needed = 100.0 * (art["cooldown"] / f.K["cooldown_min"] - 1)
                x[o["layer"] - 1] += min(max(att.art_speed - needed, 0), o.get("cap", 1e9))
        return x

    f.layer_points = layer_points
