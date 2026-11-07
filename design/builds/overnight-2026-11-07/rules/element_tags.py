"""Element tags on hits, Conversion chains, pass_tag on wards and the Fed Ward.

Combat rule 6 and Formulas D say hits carry element tags and a ward record may hold
pass_tag. The calculator has neither, so this adds them. Elements are the data ids:
moc, hoa, tho, kim, thuy, in the generating order of character_elements.json.

A side's art hit carries its art's "element", else the side's "element", else the other
side's "assumed_enemy_element". Basic attacks and companions carry no element (rule 13).

Own arts: "element": "moc", "chain": ["hoa", "tho"], with "conv": [a, b] on the side (default
[1, 1]). Each conversion turns that share of the part before it into the next tag, and a
converted part keeps every earlier tag (rule 6). So a hit splits into up to three parts.

"ring_flat": 0.2 adds that to the coefficient of a part per conversion it went through.
"tag_mods": [{"id", "layer", "per_tag": n}] adds n points per element tag on the part.
"tag_mods": [{"id", "layer", "overcomes": true, "points": n}] adds n points while the part
carries the element that overcomes the target's element (three generating steps on).

A ward record may hold "pass_tag": {"hoa": -0.2, "thuy": 0.1}. Each tag on the part adds its
value to pass_kind, before ws, as Formulas D has it. A default ward takes no tag terms.

"ward_phase": "tho" and "fed": {"pass_tag": -0.25, "refund": 0.5, "clipped_heals": 0.5}. A hit
whose first element generates the ward's phase is Fed: it takes that pass_tag, the ward pays
nothing for it, and the side gains refund x the blocked amount. Refund a full pool cannot
hold restores health at clipped_heals (Still Water, from The Fortieth Breath).
"""
CYCLE = ["moc", "hoa", "tho", "kim", "thuy"]


def step(element, n=1):
    return CYCLE[(CYCLE.index(element) + n) % 5]


def overcomer(element):
    return step(element, 3)


def install(f):
    state = {"tags": None, "fed": False}
    f.element_state = state
    f.element_step = step
    f.element_art_tags = lambda att, dfn, art: [art["element"]] + list(art.get("chain", []))
    f.element_on_hit = lambda att, dfn, tags, t: None
    f.element_target = lambda att, dfn: dfn.spec.get("element") or att.spec.get("assumed_enemy_element")
    original_strike = f.strike
    original_terms = f.Side.ward_terms
    original_ward = f.apply_ward
    original_layers = f.layer_points
    original_resolve = f.resolve_art

    def art_of(side, channel):
        return next((a for a in side.arts if a["id"] == channel[4:]), {})

    def tags_of(att, dfn, channel):
        if not channel.startswith("art:"):
            return []
        e = art_of(att, channel).get("element") or att.spec.get("element") \
            or dfn.spec.get("assumed_enemy_element")
        return [e] if e else []

    def phase_of(side):
        return getattr(side, "phase", None) or side.spec.get("ward_phase")

    def strike(att, dfn, t, gap, c, kind, extra, channel, crit=True, direct=True):
        tags = state["tags"] if state["tags"] is not None else tags_of(att, dfn, channel)
        outer = state["tags"], state["fed"]
        state["tags"] = tags
        fed = dfn.spec.get("fed")
        state["fed"] = bool(fed and tags and step(tags[0]) == phase_of(dfn))
        if state["fed"]:
            dfn.note("fed_hits")
        dealt = original_strike(att, dfn, t, gap, c, kind, extra, channel, crit, direct)
        state["tags"], state["fed"] = outer
        if tags:
            f.element_on_hit(att, dfn, tags, t)
        return dealt

    def ward_terms(self, kind):
        tags = state["tags"] or []
        table = self.ward.get("pass_tag") or {}
        shift = sum(table.get(e, 0) for e in tags)
        if state["fed"] and self.spec.get("fed"):
            shift += self.spec["fed"]["pass_tag"]
        worn = self.ward
        if not shift or worn.get("model", "drain") == "default" or "pass" not in worn:
            return original_terms(self, kind)
        raw = worn["pass"]
        if isinstance(raw, dict):
            moved = {k: max(f.K["pass_min"], min(1, v + shift)) for k, v in raw.items()}
        else:
            moved = max(f.K["pass_min"], min(1, raw + shift))
        self.ward = dict(worn, **{"pass": moved})
        try:
            return original_terms(self, kind)
        finally:
            self.ward = worn

    def apply_ward(dfn, att, d, kind):
        before = dfn.qi
        leak = original_ward(dfn, att, d, kind)
        if state["fed"] and dfn.spec.get("fed"):
            spec = dfn.spec["fed"]
            att.qi_drained_by_me -= before - dfn.qi
            dfn.qi = before
            gain = (d - leak) * spec.get("refund", 0)
            take = min(gain, max(dfn.qi_cap - dfn.qi, 0.0))
            dfn.qi += take
            f.add_dmg(dfn, "fed(linh luc)", take)
            heal = (gain - take) * spec.get("clipped_heals", 0)
            if heal > 0:
                dfn.health = min(dfn.health_max, dfn.health + heal)
                f.add_dmg(dfn, "healed by Still Water(linh luc)", heal)
        return leak

    def layer_points(att, dfn, t, extra, channel):
        x = original_layers(att, dfn, t, extra, channel)
        tags = state["tags"] or []
        if channel.startswith("art"):
            target = f.element_target(att, dfn)
            for m in att.spec.get("tag_mods", []):
                if "per_tag" in m:
                    x[m["layer"] - 1] += m["per_tag"] * len(tags)
                elif m.get("overcomes") and target and overcomer(target) in tags:
                    x[m["layer"] - 1] += m["points"]
        return x

    def resolve_art(att, dfn, art, t, gap):
        if not art.get("element") or art.get("c_art", 0) <= 0 or "chain" not in art:
            return original_resolve(att, dfn, art, t, gap)
        tags = f.element_art_tags(att, dfn, art)
        conv = att.spec.get("conv", [1.0, 1.0])
        left, parts = 1.0, []
        for i in range(len(tags)):
            share = conv[i] if i < len(tags) - 1 and i < 2 else 0.0
            parts.append((left * (1 - share), tags[:i + 1], i))
            left *= share
        for share, part_tags, steps in parts:
            if share <= 0:
                continue
            state["tags"] = part_tags
            x = list(art.get("x", [0, 0, 0, 0, 0]))
            c = (art["c_art"] + att.spec.get("ring_flat", 0) * steps) * share
            f.strike(att, dfn, t, gap, c, art.get("kind", "qi"), x, "art:" + art["id"])
            state["tags"] = None
        rest = dict(art)
        rest["c_art"] = 0
        original_resolve(att, dfn, rest, t, gap)
        f.fire_triggers(att, dfn, t, gap, "art")

    f.strike = strike
    f.Side.ward_terms = ward_terms
    f.apply_ward = apply_ward
    f.layer_points = layer_points
    f.resolve_art = resolve_art
