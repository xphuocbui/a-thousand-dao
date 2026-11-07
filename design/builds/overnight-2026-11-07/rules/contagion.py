"""Moved Sickness (Di Bệnh), Turned Hand (Phản Thủ) and Virulence (Bệnh Thế).

Moved Sickness, asked for with "afflictions": [curse records] and "moved_sickness": true.
Each record is a curse this side starts the fight carrying, with no duration while it is on
its owner. An art with "moves_afflictions": n, when it resolves and before its hit, moves up
to n curses from its caster to the target: owned afflictions and anyone else's curses alike,
so its own hit already meets them. On the target a curse runs for its "duration" and takes a
slot under the usual rule. An owned affliction that ends, is cleansed or is pushed out comes
home the same instant, whoever removed it. Without "moved_sickness" nothing moves.

Turned Hand, a curse field "turned": {"kinds": ["body"], "share": 0.5, "cap": 0.25}. While a
side carries it, a hit art of a named kind that fired after the curse arrived still pays,
and its hit lands on its owner at that share, through the owner's own ward and guard, with
the owner's own layers and crit, at most cap of the owner's maximum health. It deals nothing
to the other side and carries nothing else. A curse an owner carries at home turns that
owner's arts too. The basic attack always runs and is not touched (Combat rule 13).

Relapse (Tái Phát), "relapse_refund": share. Each owned affliction that comes home refunds
that share of maximum linh lực.

Virulence: a conditional_mods "per": "own_curses" reads the curses on the attacker, and for
an art that moves curses, those it held as it fired.

Fever (from The Taster's Fever) as an affliction, asked for with "fever": points at the top
of the file. It is a curse lasting 3 pulses on a target, and adds that much art speed to whoever
carries it. Cooldowns are re-read whenever a curse moves, and a timer already running keeps
its end, so it shows at the next firing. The owner's first timers are set with it, so a fever at home speeds the first art.

Adds the guards {"afflicted": "all"}, true while this side carries at least one curse and
all of its own afflictions, and {"clean": true}, true while it carries none.

"moves_afflictions" also moves every over-time status on its caster to the target. A status
keeps its source, so it ticks with the values of whoever first applied it (Formulas F).
"""

BIG = 10 ** 6


def install(f):
    original_pulse, original_resolve, original_strike = f.pulse, f.resolve_art, f.strike
    original_guard, original_scale = f.guard_true, f.scale_value
    original_init = f.Side.__init__

    def init(self, spec, name):
        original_init(self, spec, name)
        self.afflictions = []
        listed = list(spec.get("afflictions", []))
        if spec.get("fever"):
            listed.append({"id": "fever", "duration": 3, "fever": spec["fever"]})
        for a in listed:
            rec = dict(a)
            rec["owner"], rec["left"], rec["landed"] = self, BIG, -1
            self.afflictions.append(rec)
            self.curses.append(rec)
        if self.afflictions:
            retime(self)
            for art in self.arts:
                art["ready"] = art["cd_ms"]

    def retime(side):
        speed = side.art_speed + sum(c.get("fever", 0) for c in side.curses)
        for art in side.arts:
            cd = max(f.K["cooldown_min"], art["cooldown"] / (1 + speed / 100.0))
            art["cd_ms"] = f.ms(cd)

    def reconcile(*sides):
        for owner in sides:
            for rec in owner.afflictions:
                held = any(rec is c for s in sides for c in s.curses)
                if not held:
                    rec["left"], rec["landed"] = BIG, -1
                    owner.curses.append(rec)
                    owner.note("afflictions_came_home")
                    back = owner.spec.get("relapse_refund", 0) * owner.qi_max
                    owner.qi = min(owner.qi_cap, owner.qi + back)
        for side in sides:
            retime(side)

    def move(src, dst, n, t):
        moved = 0
        for rec in list(src.curses):
            if moved >= n:
                break
            src.curses = [c for c in src.curses if c is not rec]
            rec["left"], rec["landed"] = rec.get("duration", 3), t
            if len(dst.curses) >= f.K["curse_slots"]:
                worst = min(dst.curses, key=lambda v: v["left"])
                dst.curses = [c for c in dst.curses if c is not worst]
            dst.curses.append(rec)
            moved += 1
        if moved:
            src.note("afflictions_moved")
        for st in list(src.statuses):
            src.statuses = [x for x in src.statuses if x is not st]
            dst.statuses.append(st)
            src.note("statuses_moved")
        reconcile(src, dst)
        return moved

    def pulse(side, enemy, gap_of_enemy, t):
        out = original_pulse(side, enemy, gap_of_enemy, t)
        reconcile(side, enemy)
        return out

    def turned_for(att, art, t):
        for c in att.curses:
            turn = c.get("turned")
            if turn and art.get("kind", "body") in turn["kinds"] and c.get("landed", -1) < t:
                return turn, c
        return None, None

    def resolve_art(att, dfn, art, t, gap):
        if art.get("moves_afflictions"):
            att.held_at_firing = len(att.curses)
            if att.spec.get("moved_sickness"):
                move(att, dfn, art["moves_afflictions"], t)
        turn, curse = (None, None)
        if art.get("c_art", 0) > 0 and not art.get("soul_pct"):
            turn, curse = turned_for(att, art, t)
        if turn:
            before = att.health
            x = list(art.get("x", [0, 0, 0, 0, 0]))
            original_strike(att, att, t, 0, art["c_art"] * turn["share"], art.get("kind", "body"),
                            x, "turned", direct=False)
            lost = before - att.health
            cap = turn.get("cap", 1.0) * att.health_max
            if lost > cap:
                att.health += lost - cap
                att.dmg_taken_instant -= lost - cap
                lost = cap
            owner = curse.get("owner", dfn)
            f.add_dmg(owner, "turned hand", lost)
            att.dmg.pop("turned", None)
            owner.note("turned_hand_firings")
            return None
        out = original_resolve(att, dfn, art, t, gap)
        att.held_at_firing = None
        reconcile(att, dfn)
        return out

    def guard_true(g, own, enemy, t):
        if g and "afflicted" in g:
            return bool(own.curses) and all(any(r is c for c in own.curses) for r in own.afflictions)
        if g and g.get("clean"):
            return not own.curses
        return original_guard(g, own, enemy, t)

    def scale_value(c, att, dfn, t):
        if c.get("per") == "own_curses":
            held = getattr(att, "held_at_firing", None)
            return c.get("points_per", 0) * (len(att.curses) if held is None else held)
        return original_scale(c, att, dfn, t)

    f.Side.__init__ = init
    f.pulse, f.resolve_art = pulse, resolve_art
    f.guard_true, f.scale_value = guard_true, scale_value
