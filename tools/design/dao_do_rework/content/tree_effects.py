"""The engine forms of the Đạo Đồ's Effects (43 keystones, 12 crown notables), written into
assets/data/combat_effects.json beside the item Effects (ADR-0004 decision 3; design/gdd/effects.md "Đạo Đồ Effects
(content pass, 2026-11-19)" and its Starter Effects).

Each entry: rule (the effects.md text it implements), records (engine Effects), counters, lines (plain stat lines, its
closing numbers: on the game's stat sheet, or folded like item modifiers in a design build), count ({"of": a build
count, "cap"}) multiplying the records' mods except those marked "fixed" (the closing), pool_more, stack_alias,
no_ward, only_tag, sheet_from (a sheet line computed from another stat: the game's stat sheet only), pending (the part
not run yet, with its host) and not_run (an Effect whose host is outside fights: shown, adding nothing). Closing
records end in " closes". Where the rule left an engine detail open, `engine_choice` says what was chosen (listed for
the user's review, design/dao-do/tree-effects-engine.md).

Run: python -I tools/design/dao_do_rework/content/tree_effects.py [--check]
"""
import json
import os
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "..", ".."))
OUT = os.path.join(ROOT, "assets", "data", "combat_effects.json")


def R(name, on, do, **kw):
    r = {"id": "eff:%s" % name, "on": on}
    r.update(kw)
    r["do"] = do
    return r


def C(name, do, **kw):
    """A closing record (always on, never multiplied by a count)."""
    r = {"id": "eff:%s closes" % name, "on": "always"}
    r.update(kw)
    r["do"] = do
    r["fixed"] = True
    return r


def mod(**m):
    return {"mod": m}


def art_less(name, element):
    return C(name, [mod(dmg_more=-0.5, element=element, kind="art")])


E = {}


def add(name, rule, **kw):
    E[name] = dict(rule=rule, source="Đạo Đồ", **kw)


# --- keystones: Fire and Earth ---------------------------------------------------------------------------------------
add("Ever-Burning Furnace", "Every Burn stack your hits apply returns +0.2 pp of maximum linh lực (10 stacks a pulse). "
    "Closes: your linh lực regeneration is 0.",
    records=[R("Ever-Burning Furnace", "status_applied", [{"gain_qi": {"share": 0.002}}], filter={"element": "fire"},
               scale={"read": "event.stacks", "per": 1, "floor": False}, limit={"scale_per_pulse": 10}),
             C("Ever-Burning Furnace", [mod(no_regen=1)])])
add("Burning Lifespan", "Once a fight, when your health first falls to 30 % or below, you burn years for 5 s of fury: "
    "L5 +40 on all hits and art speed +30 for 5 s. Closes: the result reports 2 % of your realm's base lifespan in "
    "years lost, win or lose.",
    counters=[{"id": "nhien_tho", "cap": 1}],
    records=[R("Burning Lifespan", ev, [{"counter": {"id": "nhien_tho", "add": 1}},
                                         mod(L5=40, art_speed=30, **{"for": 5})],
               **{"if": [{"read": "own.hp_share", "op": "<=", "value": 0.3},
                         {"read": "own.counter.nhien_tho", "op": "==", "value": 0}]}) for ev in ("was_hit", "pulse")],
    pending="the lifespan the fight burns: the fight result does not report years yet (Realms / Time & Turn host)")
for r in E["Burning Lifespan"]["records"]:
    r["id"] += " " + r["on"]
add("Alchemist's Heart", "The first pill you take in each fight counts twice. Closes: pill toxicity fades half as fast.",
    not_run="pills are not taken inside fights yet (Alchemy: pill use in combat has no host)")
add("Overheat", "Art speed that cooldown_min clips on an art becomes L5 on that art, point for point, cap +30. Closes "
    "(tree keystone): your art costs +35 %.",
    records=[R("Overheat", "always", [mod(overheat=30)]), C("Overheat", [mod(cost_red=-0.35)])])
add("Immovable Mountain", "Slowed Time and timer delays never land on you. Closes: art speed modifiers do nothing for you.",
    records=[R("Immovable Mountain", "always", [mod(status_immune=1, status="slowed_time"), mod(delay_immune=1)]),
             C("Immovable Mountain", [mod(speed_locked=1)])])
add("Earth Vein Tap", "While your own formation stands, linh lực regeneration +50 % increased; with none, none. Closes: "
    "no linh lực regeneration while no formation of yours stands.",
    not_run="formations do not stand inside fights yet (Formations host)")
add("Open Sky", "Your wards are 5 % stronger for each extra item slot you leave empty. Closes (tree keystone): artifact "
    "power -30 %.",
    count={"of": "empty_extra_slots"},
    records=[R("Open Sky", "always", [mod(ward_pct=5)])],
    lines=[{"key": "artifact_power_pct", "value": -30}])
add("No Ward", "You can never use a ward, and your body hardens instead: body shield +25 %; after each pulse in which no "
    "hit reached your health, the body shield regains 2 % of maximum health. Closes: no ward of any kind.",
    no_ward=True, lines=[{"key": "body_shield_pct", "value": 25}],
    counters=[{"id": "vo_ho"}],
    records=[R("No Ward hit", "was_hit", [{"counter": {"id": "vo_ho", "set": 1}}],
               **{"if": [{"read": "event.amount", "op": ">", "value": 0}]}),
             R("No Ward regain", "pulse", [{"shield": {"body": 0.02}}],
               **{"if": [{"read": "own.counter.vo_ho", "op": "==", "value": 0}]}),
             R("No Ward reset", "pulse", [{"counter": {"id": "vo_ho", "set": 0}}])])
for r in E["No Ward"]["records"]:
    r["id"] = r["id"].replace("eff:No Ward ", "eff:No Ward ")
# --- keystones: Metal, Water, Wood -----------------------------------------------------------------------------------
add("Ten Thousand Swords Return", "Your sword arts deal L5 +8 for each sword artifact you carry, cap +32. Closes: only "
    "arts with the sword tag may be slotted; your wards are 30 % weaker.",
    count={"of": "carried_sword", "cap": 4}, only_tag="sword",
    records=[R("Ten Thousand Swords Return", "always", [mod(L5=8, tags=["sword"])])],
    lines=[{"key": "defense_pct", "value": -30}])
add("Called Blow", "Your crit chance is counted on a visible meter, not rolled (Effects Formulas A). Closes: crit "
    "chance cap 0.50 -> 0.35.",
    records=[R("Called Blow", "always", [mod(counted_crit=1)]), C("Called Blow", [mod(crit_cap_to=0.35)])])
add("Autumn Harvest", "Your crits refund the art's cost (3 firings a pulse). Closes: your linh lực regeneration is 0.",
    records=[R("Autumn Harvest", "crit", [{"refund": {"share": 1.0}}], filter={"kind": "art"}, limit={"per_pulse": 3}),
             C("Autumn Harvest", [mod(no_regen=1)])])
add("Unyielding Breath", "Once a fight, a blow that would put you Down leaves you at 1 health. Closes: maximum health "
    "-15 %.",
    records=[R("Unyielding Breath", "down", [{"refuse_down": {}}], limit={"per_fight": 1})],
    lines=[{"key": "khi_huyet_pct", "value": -15}])
add("Thousand Talismans", "The talismans you draw before a fight cost no stock for their first two uses. Closes: arts "
    "that are not talismans deal 30 % less.",
    records=[C("Thousand Talismans", [mod(dmg_more=-0.3, kind="art", not_tags=["talisman"])])],
    pending="talisman stock: the rule switches on with the Talismans GDD (the closing runs now)")
add("Boundless Sea", "Your linh lực pool doubles but no longer regenerates on its own. Closes: linh lực on hit gives "
    "nothing.",
    pool_more={"n_qi": 2.0},
    records=[R("Boundless Sea", "always", [mod(no_regen=1)]), C("Boundless Sea", [mod(no_gain_on_hit=1)])])
add("Flowing Water", "When you crit, your other arts' timers shorten by 0.5 s (3 firings a pulse). Closes (tree "
    "keystone): your art costs +40 %.",
    records=[R("Flowing Water", "crit", [{"timer": {"side": "own", "which": "others", "by": -0.5}}],
               limit={"per_pulse": 3}),
             C("Flowing Water", [mod(cost_red=-0.40)])])
add("Still Water", "Linh lực lost to a full pool restores health at half that amount. Closes (tree keystone): healing "
    "taken from every other source -50 %.",
    records=[R("Still Water", "overflow", [{"heal": {"of": "amount", "share": 0.5, "ignore_taken": True}}])],
    lines=[{"key": "healing_taken_pct", "value": -50}])
add("Spirit Garden", "Herbs in your spirit fields ripen a season sooner. Closes: you can keep at most one spirit beast.",
    not_run="spirit fields and seasons are outside fights (Spirit Herbs & Spirit Fields host); its closing waits with it")
add("Ten Thousand Poisons", "Your Poison batches last until the fight ends. Closes: your hits deal 25 % less.",
    records=[R("Ten Thousand Poisons", "status_applied",
               [{"refresh": {"el": "wood", "side": "foe", "kind": "debuff", "hold": True}}], filter={"element": "wood"}),
             C("Ten Thousand Poisons", [mod(dmg_more=-0.25)])])
add("Sun and Rain", "Your health regeneration also restores linh lực, at half the amount (as a share of each pool). "
    "Closes: maximum linh lực -30 %.",
    records=[R("Sun and Rain", "heal_restored", [{"gain_qi": {"share": 0.5}}], filter={"source": "regen"},
               scale={"read": "event.share", "per": 1, "floor": False})],
    lines=[{"key": "linh_luc_pct", "value": -30}])
add("Bare Rack", "Your companion hits deal L5 +5 for each empty art slot, cap +20 (the basic-attack half is Pending). "
    "Closes (tree keystone): maximum health -15 %.",
    count={"of": "empty_art_slots", "cap": 4},
    records=[R("Bare Rack", "always", [mod(dmg_more=0.05, kind="companion")])],
    lines=[{"key": "khi_huyet_pct", "value": -15}],
    engine_choice="companion hits skip the damage layers, so L5 +5 a slot is run as 5 % more damage a slot",
    pending="the [basic] half, until Combat adopts the basic tag (#43; re-review EF 24)")
# --- keystones: the islands ------------------------------------------------------------------------------------------
add("Heaven's Eye", "Your crits against an Exposed foe deal L5 +20 on that hit. Closes: your ward strength is 30 % "
    "lower.",
    records=[R("Heaven's Eye", "always", [mod(L5=20, is_crit=True)],
               **{"if": [{"read": "foe.status.exposed", "op": ">=", "value": 1}]})],
    lines=[{"key": "defense_pct", "value": -30}])
add("Sun That Never Sets", "Each season you cultivate, you also gain 1 point of đạo tâm (+10 per realm). Closes: you "
    "can never conceal yourself; heart-demon resistance -30 %.",
    not_run="seasons and đạo tâm are outside fights (Cultivation / Time & Turn host); its closings wait with it")
add("Glass Meridians", "Your arts run far faster (art speed +40), on a fragile body. Closes: maximum health -25 %; your "
    "body shields hold half.",
    records=[C("Glass Meridians", [mod(shield_hold=-0.5)])],
    # the node's own plain art_speed_pct 41.6 is the content pass's land-scaled +40: not added again (user, 2026-11-21)
    lines=[{"key": "khi_huyet_pct", "value": -25}])
add("Hidden Moon", "Your evade also counts as crit chance, point for point. Closes: your block and body shield count "
    "nothing; maximum health -20 %.",
    records=[R("Hidden Moon", "always", [mod(crit=1)], scale={"read": "own.evade", "per": 1, "floor": False}),
             C("Hidden Moon", [mod(no_block=1), mod(no_body_shield=1)])],
    lines=[{"key": "khi_huyet_pct", "value": -20}])
# --- keystones near the starts and mid-land --------------------------------------------------------------------------
add("Fire Feeds Fire", "Your Burn stacks on the foe never fall off while you hit it at least once every 3 s. Closes: "
    "Water arts you slot deal 50 % less.",
    records=[R("Fire Feeds Fire", "hit_landed",
               [{"refresh": {"el": "fire", "side": "foe", "kind": "debuff", "at_least": 3}}]),
             art_less("Fire Feeds Fire", "water")],
    engine_choice="each hit you land keeps every Burn batch of yours on the foe until at least 3 s later")
add("Layered Earth", "Each hit you block raises your defence by 3 % until the fight ends, cap +30. Closes: your evade "
    "counts nothing.",
    counters=[{"id": "hau_tho", "cap": 10}],
    records=[R("Layered Earth block", "blocked", [{"counter": {"id": "hau_tho", "add": 1}}]),
             R("Layered Earth", "always", [mod(ward_pct=3)], scale={"read": "own.counter.hau_tho", "per": 1, "cap": 10}),
             C("Layered Earth", [mod(no_evade=1)])],
    engine_choice="defence is ward strength, read live (ward_pct)")
add("Keen Edge", "Your hits ignore the foe's block. Closes: your own block rating counts nothing.",
    records=[R("Keen Edge", "always", [mod(ignore_block=1)]), C("Keen Edge", [mod(no_block=1)])])
add("Frost Seal", "Your Ice stacks on the foe stop falling off once it holds 10 or more. Closes: Fire arts you slot "
    "deal 50 % less.",
    records=[R("Frost Seal", "status_applied", [{"refresh": {"el": "ice", "side": "foe", "kind": "debuff", "hold": True}}],
               filter={"element": "ice"}, **{"if": [{"read": "foe.debuff.ice", "op": ">=", "value": 10}]}),
             art_less("Frost Seal", "fire")])
add("Rising Tide", "While your linh lực is above half, your Water stacks count double. Closes: while it is below half, "
    "your Water stacks do nothing.",
    records=[R("Rising Tide", "always", [mod(stack_more=1.0, element="water")],
               **{"if": [{"read": "own.qi_share", "op": ">", "value": 0.5}]}),
             C("Rising Tide", [mod(stack_more=-1.0, element="water")],
               **{"if": [{"read": "own.qi_share", "op": "<", "value": 0.5}]})],
    engine_choice="your own Water buff stacks; the half reads linh lực without the stacks' own pool bonus")
add("Ebb Tide", "The first time in a fight your linh lực falls below 30 %, restore 30 % of it. Closes: maximum linh "
    "lực -15 %.",
    counters=[{"id": "trieu_rut", "cap": 1}],
    records=[R("Ebb Tide", ev, [{"gain_qi": {"share": 0.3}}, {"counter": {"id": "trieu_rut", "add": 1}}],
               **{"if": [{"read": "own.qi_share", "op": "<", "value": 0.3},
                         {"read": "own.counter.trieu_rut", "op": "==", "value": 0}]}) for ev in ("art_fired", "was_hit")],
    lines=[{"key": "linh_luc_pct", "value": -15}],
    engine_choice="checked after each art you fire and each hit you take")
for r in E["Ebb Tide"]["records"]:
    r["id"] += " " + r["on"]
add("Ageless Pine", "Your Wood buff stacks never fall off during a fight. Closes: Fire resistance -25.",
    records=[R("Ageless Pine", "buff_gained", [{"refresh": {"el": "wood", "side": "own", "kind": "buff", "hold": True}}],
               filter={"element": "wood"})],
    lines=[{"key": "resist_pct", "value": -25, "scope": ["fire"]}])
add("Utmost Yang", "Your hits deal L5 +6 for each different base element among your slotted arts, cap +30. Closes: your "
    "wards are 30 % weaker.",
    count={"of": "art_elements", "cap": 5},
    records=[R("Utmost Yang", "always", [mod(L5=6)])],
    lines=[{"key": "defense_pct", "value": -30}])
add("Utmost Yin", "You resist 6 more for each different base element among your slotted arts, cap +30. Closes: your "
    "hits deal 20 % less.",
    count={"of": "art_elements", "cap": 5},
    records=[R("Utmost Yin", "always", [mod(resist=6)]), C("Utmost Yin", [mod(dmg_more=-0.2)])])
add("Nirvana", "Once per fight, the blow that would kill you leaves you at 30 % health instead. Closes: healing taken "
    "-30 %.",
    records=[R("Nirvana", "down", [{"refuse_down": {"hp_share": 0.3}}], limit={"per_fight": 1})],
    lines=[{"key": "healing_taken_pct", "value": -30}])
add("Fire Lotus", "Your crits apply two more Burn stacks. Closes: crit damage -30 %.",
    records=[R("Fire Lotus", "crit", [{"stacks": {"el": "fire", "n": 2, "for": 6, "side": "foe"}}])],
    lines=[{"key": "crit_damage_pct", "value": -30}],
    engine_choice="the two stacks last 6 s, a typical Fire art's Burn batch")
add("Mountain's Weight", "Your hits deal L5 +4 for each 10 % of maximum health you hold above the foe's, cap +32. "
    "Closes: art speed -20 %.",
    records=[R("Mountain's Weight", "always", [mod(L5=4)], scale={"read": "own.hp_max_lead", "per": 0.1, "cap": 8})],
    lines=[{"key": "art_speed_pct", "value": -20}])
add("Earthen Armour", "After 3 s without being hit, your body shield refills 10 % a pulse. Closes: maximum linh lực "
    "-20 %.",
    records=[R("Earthen Armour", "pulse", [{"shield": {"refill": 0.1}}],
               **{"if": [{"read": "own.since_hit", "op": ">=", "value": 3}]})],
    lines=[{"key": "linh_luc_pct", "value": -20}],
    engine_choice="10 % of the starting bar a pulse, up to the starting bar")
add("Metal Begets Water", "Each hit of a Metal art you land adds one Water buff stack to you. Closes: Wood arts you "
    "slot deal 50 % less.",
    records=[R("Metal Begets Water", "hit_landed", [{"stacks": {"el": "water", "n": 1, "for": 10, "side": "own"}}],
               filter={"element": "metal", "kind": "art"}),
             art_less("Metal Begets Water", "wood")],
    engine_choice="the stack lasts 10 s, a typical Water art's buff batch")
add("Hundred Refinements", "Half your artifact power also counts as attack. Closes: art speed -20 %.",
    sheet_from=[{"key": "attack_pct", "from": "artifact_power_pct", "factor": 0.5}],
    lines=[{"key": "art_speed_pct", "value": -20}])
add("Water Begets Wood", "Your Water buff stacks also count as Wood buff stacks. Closes: Earth arts you slot deal 50 % "
    "less.",
    stack_alias={"water": ["wood"]}, records=[art_less("Water Begets Wood", "earth")])
add("Returning Wave", "The first hit you take in each fight does you no harm and strikes the foe instead, at full "
    "damage. Closes: maximum health -15 %.",
    records=[R("Returning Wave", "always", [mod(reflect_first=1)])],
    lines=[{"key": "khi_huyet_pct", "value": -15}],
    engine_choice="the hit's damage before your defence strikes the foe through its defence")
add("Strangling Vines", "Each time the foe reaches 5 Wood debuff stacks, it is Slowed Time for 1 s (once per 6 s). "
    "Closes: art speed -15 %.",
    records=[R("Strangling Vines", "status_applied", [{"status": {"id": "slowed_time", "stacks": 1, "dur": 1}}],
               filter={"element": "wood"}, limit={"cooldown": 6},
               **{"if": [{"read": "foe.debuff.wood", "op": ">=", "value": 5}]})],
    lines=[{"key": "art_speed_pct", "value": -15}])
add("Wood Begets Fire", "Your Wood buff stacks also count as Fire buff stacks. Closes: Metal arts you slot deal 50 % "
    "less.",
    stack_alias={"wood": ["fire"]}, records=[art_less("Wood Begets Fire", "metal")])
# --- crown Effects on big pictures -----------------------------------------------------------------------------------
add("Eruption", "Your costly Fire arts (cost share 10 % or more, the costly tag) deal L5 +15.",
    records=[R("Eruption", "always", [mod(L5=15, element="fire", tags=["costly"])])])
add("Wildfire", "When one of your Burn batches runs out, half its stacks rekindle as a new batch for 2 pulses, once per "
    "batch.",
    records=[R("Wildfire", "batch_ended", [{"stacks": {"el": "fire", "n": 1, "for": 2, "side": "foe", "mark": "rekindled"}}],
               filter={"element": "fire", "kind": "debuff"}, scale={"read": "event.stacks", "per": 2, "floor": False},
               **{"if": [{"read": "event.rekindled", "op": "==", "value": 0}]})])
add("Burning Ground", "Your Earth arts leave burning ground: the foe gains 2 Burn stacks, once per art firing.",
    records=[R("Burning Ground", "hit_landed", [{"stacks": {"el": "fire", "n": 2, "for": 6, "side": "foe"}}],
               filter={"element": "earth", "kind": "art"}, limit={"per_firing": 1})])
add("Grinding Weight", "Your slow arts apply a stack of Slowed Time, once per art firing.",
    records=[R("Grinding Weight", "hit_landed", [{"status": {"id": "slowed_time", "stacks": 1}}],
               filter={"kind": "art", "tags": ["slow"]}, limit={"per_firing": 1})])
add("Thorns", "A blocked hit returns 30 % of the blocked amount to the attacker as physical damage, once per pulse.",
    records=[R("Thorns", "blocked", [{"return_damage": {"share": 0.3, "dtype": "phys"}}], limit={"per_pulse": 1})],
    engine_choice="the returned damage meets the attacker's defence")
TIDE = [0.0, 6.67, 13.33, 20.0, 13.33, 6.67]
add("Tide", "Your Water damage rises and falls in a 6-pulse cycle: L5 +0 to +20.",
    records=[R("Tide %d" % k, "always", [mod(L5=v, element="water")], **{"if": [{"read": "cycle.6", "op": "==", "value": k}]})
             for k, v in enumerate(TIDE) if v],
    engine_choice="a triangle over 6 pulses: 0, 6.67, 13.33, 20, 13.33, 6.67")
for r in E["Tide"]["records"]:
    r["id"] = r["id"].replace("eff:Tide ", "eff:Tide phase ")
add("Reflection", "After you evade, your next art deals L5 +15, once per evade.",
    records=[R("Reflection", "evaded", [mod(L5=15, kind="art")], held={"until": "art_fired", "cap": 1})])
add("Daybreak", "Your first Light hit each fight lays the foe bare (Exposed, 3 pulses).",
    records=[R("Daybreak", "hit_landed", [{"status": {"id": "exposed", "dur": 3}}], filter={"tags": ["light"]},
               limit={"per_fight": 1})],
    engine_choice="a Light hit is a hit of an art tagged light (no art in the library carries it yet)")
add("First Thunder", "Your first art each fight fires at cooldown_min.",
    records=[R("First Thunder", "fight_start", [{"timer": {"side": "own", "which": "next", "by": -999}}])])
add("Heaven's Verdict", "Your slow Thunder arts deal L5 +20 against a foe below half health.",
    records=[R("Heaven's Verdict", "always", [mod(L5=20, element="thunder", tags=["slow"])],
               **{"if": [{"read": "foe.hp_share", "op": "<", "value": 0.5}]})])
add("Dark of the Moon", "After you evade, your next hit crits (once per pulse).",
    records=[R("Dark of the Moon", "evaded", [mod(sure_crit=1)], held={"until": "hit_landed", "cap": 1},
               limit={"per_pulse": 1})])
add("Before Heaven", "Your damage and resistance grow with the number of elements your root owns: L5 +4 and "
    "resistance +40 per owned element, cap 5 elements.",
    count={"of": "root_elements", "cap": 5},
    records=[R("Before Heaven", "always", [mod(L5=4, resist=40)])])


def merged():
    d = json.load(open(OUT, encoding="utf-8"))
    note = (" Đạo Đồ Effects (source \"Đạo Đồ\", 2026-11-20; written by tools/design/dao_do_rework/content/tree_effects.py,"
            " which explains their fields): a build file names them in tree_effects. Extra fields: lines (plain stat"
            " lines, the closing numbers), count {of, cap} by a build count, fixed records (closings, never counted),"
            " pool_more, stack_alias, no_ward, only_tag, sheet_from, pending, engine_choice.")
    if note not in d["_doc"]:
        d["_doc"] += note
    for k, v in E.items():
        d["effects"][k] = v
    d["effects"] = dict(sorted(d["effects"].items()))
    return d


def dump(d):
    """The library's own layout: one effect field a line, a list of one inline, a longer list one item a line."""
    j = lambda x: json.dumps(x, ensure_ascii=False)
    out = ["{", '  "_doc": %s,' % j(d["_doc"]), '  "effects": {']
    names = list(d["effects"])
    for i, name in enumerate(names):
        e = d["effects"][name]
        out.append("    %s: {" % j(name))
        keys = list(e)
        for k_i, k in enumerate(keys):
            v = e[k]
            comma = "," if k_i < len(keys) - 1 else ""
            if isinstance(v, list) and len(v) > 1:
                out.append("      %s: [" % j(k))
                out.append(",\n".join("        " + j(x) for x in v))
                out.append("      ]" + comma)
            else:
                out.append("      %s: %s%s" % (j(k), j(v), comma))
        out.append("    }" + ("," if i < len(names) - 1 else ""))
    out += ["  }", "}"]
    return "\n".join(out) + "\n"


def main():
    text = dump(merged())
    if "--check" in sys.argv:
        ok = open(OUT, encoding="utf-8").read() == text
        print("same" if ok else "DRIFT assets/data/combat_effects.json")
        sys.exit(0 if ok else 1)
    open(OUT, "w", encoding="utf-8", newline="\n").write(text)
    print("wrote %d tree Effects into assets/data/combat_effects.json" % len(E))


if __name__ == "__main__":
    main()
