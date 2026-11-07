"""Carried Note (Đới Âm): a Redirect. Tag modifiers on the art you fired in this instant also
apply to your companion's hit in the same instant.

Asked for with "carried_note": true. The companion takes the "x" of the last art this side
resolved in the current instant. An instant with no art gives it nothing, so the bonus lives
only while arts and companion share a timer.
"""


def install(f):
    original_points = f.layer_points
    original_resolve = f.resolve_art

    def layer_points(att, dfn, t, extra, channel):
        x = original_points(att, dfn, t, extra, channel)
        if channel == "companion" and att.spec.get("carried_note") \
                and att.__dict__.get("note_t") == t:
            for i, v in enumerate(att.note_x):
                x[i] += v
        return x

    def resolve_art(att, dfn, art, t, gap):
        out = original_resolve(att, dfn, art, t, gap)
        if art.get("x"):
            att.note_t = t
            att.note_x = art["x"]
        return out

    f.layer_points = layer_points
    f.resolve_art = resolve_art
