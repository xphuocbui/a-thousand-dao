"""The Way of the Examination's fight passives, as daos/examination.md states them.

Asked for with "paper": {...} on a side; each key is one node, and a side with no key gets nothing.
Comprehension is "ngo_tinh" on each side, and a side with none reads the talent mean of 45 (the
tree's step 2). lead = max(0, own - theirs).

  "clear_reading": true   +1.2 L2 points to arts per point of comprehension above 50, to +120
  "model_answer": true    the first art you fire in a fight: +1 L5 per point of lead, to +60.
                          "First art" is literal: an art with no hit that fires first spends it.
  "commentary": true      +8 L5 points to arts per different enemy art seen this fight, to +40
  "already_read": true    a hit from an enemy art that has fired before in this fight is reduced by
                          half your lead, as a percentage, to 30 %. Before ward and guard.

Set Question is a curse with "question": true. While it stands, the cursed side loses L2 points
equal to half the caster's lead, to -30, never below 0. It reads the cursed side as attacker, so
it acts only on a side that carries that curse.
"""


def install(f):
    original_points = f.layer_points
    original_resolve = f.resolve_art
    original_strike = f.strike
    original_ward = f.apply_ward

    def comp(side):
        return side.spec.get("ngo_tinh", 45)

    def layer_points(att, dfn, t, extra, channel):
        x = original_points(att, dfn, t, extra, channel)
        if any(c.get("question") for c in att.curses):
            lead = max(0, comp(dfn) - comp(att))
            x[1] = max(0, x[1] - min(30, lead / 2.0))
        p = att.spec.get("paper")
        if not p or not channel.startswith("art"):
            return x
        if p.get("clear_reading"):
            x[1] += min(120, 1.2 * max(0, comp(att) - 50))
        if p.get("model_answer") and getattr(att, "paper_first", None) == channel[4:]:
            x[4] += min(60, max(0, comp(att) - comp(dfn)))
        if p.get("commentary"):
            seen = sum(1 for a in dfn.arts if a["fired"])
            x[4] += min(40, 8 * seen)
        return x

    def resolve_art(att, dfn, art, t, gap):
        p = att.spec.get("paper")
        if p and p.get("model_answer") and not getattr(att, "paper_spent", False):
            att.paper_spent = True
            att.paper_first = art["id"]
            original_resolve(att, dfn, art, t, gap)
            att.paper_first = None
            return None
        return original_resolve(att, dfn, art, t, gap)

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        att.paper_channel = channel
        return original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)

    def apply_ward(dfn, att, d, kind):
        p = dfn.spec.get("paper")
        channel = getattr(att, "paper_channel", "")
        if p and p.get("already_read") and channel.startswith("art:"):
            art = next((a for a in att.arts if a["id"] == channel[4:]), None)
            if art and len(art["fired"]) >= 2:
                d *= 1 - min(30, max(0, comp(dfn) - comp(att)) / 2.0) / 100.0
                dfn.note("already_read")
        return original_ward(dfn, att, d, kind)

    f.layer_points = layer_points
    f.resolve_art = resolve_art
    f.strike = strike
    f.apply_ward = apply_ward
