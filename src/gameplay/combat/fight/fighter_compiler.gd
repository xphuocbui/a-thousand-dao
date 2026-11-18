class_name FighterCompiler
extends RefCounted
## Builds [FighterProfile]s for the fight engine (ADR-0001 decision 2).
##
## Today it builds the fighters that have no Character: the reference enemies (typical, top_end, top_end_the_tu) at
## every realm, read from [code]assets/data/combat_reference_fighters.json[/code], which the design tool writes from
## fight.py's own definitions (tools/design/combat_sim/export_reference_fighters.py; one source, with a drift
## check). Creatures and tribulation waves are meant to come the same way.
##
## A Character compiles in two steps (user decisions 2026-11-14, design/research/fighter-compiler-questions.md):
## [method character_build_file] writes the build file, then [BuildFileCompiler] (a port of fight.py's build-file path,
## parity-tested on every item and art) resolves it and [FighterProfileLoader] loads it. The build file:
## - realm: the Character's realm (0-4).
## - layers and the main ward: the typical fighter's at that realm, until the Đạo Đồ gives a Character layers
##   of its own (the sheet's ward and stack lines then act on them, as on a build file), except L1, which is the
##   Character's own attack_pct alone (Combat Formulas B; user decision 2026-11-14), L2, which is the larger of the
##   typical +40 and the Character's own unscoped damage_more, and L3, the gear layer
##   (Combat Formulas B): 100 x the worn artifacts' attack as built / (power_base x stage_mult), so no gear is L3 0.
## - defence from gear (Combat Defence & Healing A0, A2; combat_rules.json fighter_gear): ward strength and efficiency
##   start at the ward gear term (the sheet's defense_pct and ward_efficiency_pct lines add on top), ward layer W3 and
##   body layer B3 come from ward and body gear, block from flesh and gear; the other ward layers stay typical.
## - pools (Combat Formulas A): n = clamp(stat / ref[r], n_min, n_max) from the Character's vitality and linh lực
##   before their pct bonuses, which the sheet lines then add (combat_rules.json fighter_pools). Capability #4's
##   linh lực from vitality joins the base divided by the pct multiplier, so it comes out unscaled, as in the game.
## - items: the named pieces the Character controls (CombatPower.controlled, the pieces the sheet counts), with their
##   modifiers (scoped ones too), arts, wards, reserve arts and Effects.
## - modifiers: the sheet's combat keys from every source but worn pieces, plus ordinary pieces' affixes (scoped
##   ones too) and the slotted techniques' passives (flat combat lines with scopes, fight-only; their bonuses reach
##   the fight through the sheet); keys with no part in a fight are left out.
## - arts: the unlocked abilities of its slotted techniques (main, second main, auxiliaries; Cultivation Techniques
##   rule 17), then its pieces' arts in equip order (a named piece's own, a rolled weapon its base's common art:
##   Item Database rule 21), up to the realm's art slots; a rolled armour or ward gear piece brings its base's
##   common ward; a Character with none fights with the
##   typical kit.
## - purity: the linh căn's element purities, by engine element.
## - stage_mult: the Realms stage multiplier (1.00-1.45), on the damage unit and block (Combat Formulas A).
## Not compiled yet: technique arts (no technique carries arts in game data), situation preparation (Combat rule 12).
##
## Usage:
## [codeblock]
## var errors: Array = []
## var enemy: FighterProfile = FighterCompiler.from_data("typical", 2, gd, errors)
## var report: Array = []
## var me: FighterProfile = FighterCompiler.compile(c, gd, db, StatSheet.build(c, gd, db, tree), report, errors)
## [/codeblock]

## The data file the reference fighters live in.
const REFERENCE_FILE := "combat_reference_fighters"
## The combat library (arts, named items' combat records, the typical build file per realm).
const LIBRARY_FILE := "combat_library"


## The reference fighter [param kind] (typical, top_end or top_end_the_tu) at [param realm] (0-4), or null with the
## reasons appended to [param errors].
static func from_data(kind: String, realm: int, gd: GameData, errors: Array = []) -> FighterProfile:
	var k: CombatConstants = CombatConstants.from_game_data(gd)
	if not k.errors.is_empty():
		errors.append_array(k.errors)
		return null
	var data: Dictionary = gd.file(REFERENCE_FILE)
	var fighters: Dictionary = data.get("fighters", {})
	if not fighters.has(kind):
		errors.append("%s.json: no reference fighter %s (have %s)" % [REFERENCE_FILE, kind, str(fighters.keys())])
		return null
	var rows: Array = fighters[kind]
	if realm < 0 or realm >= rows.size():
		errors.append("%s.json: %s has no realm %d" % [REFERENCE_FILE, kind, realm])
		return null
	var loader := FighterProfileLoader.new(k)
	var p: FighterProfile = loader.from_sim_build(rows[realm], "%s-r%d" % [kind, realm])
	errors.append_array(loader.errors)
	return p


## [param c]'s fighter, or null with the reasons in [param errors]. [param report] gets what the fight does not run
## (fight.py's "unmodelled" wording) and what the compile chose for the Character.
static func compile(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet, report: Array = [], errors: Array = []) -> FighterProfile:
	var d: Dictionary = character_build_file(c, gd, db, sheet, report)
	var bfc := BuildFileCompiler.new(gd)
	var rec: Dictionary = bfc.compile(d)
	report.append_array(bfc.unmodelled)
	if rec.is_empty():
		errors.append_array(bfc.errors)
		return null
	var k: CombatConstants = CombatConstants.from_game_data(gd)
	var loader := FighterProfileLoader.new(k)
	var p: FighterProfile = loader.from_sim_build(rec, str(d.name))
	report.append_array(loader.warnings)
	errors.append_array(loader.errors)
	return p


## The build file [method compile] resolves for [param c] (see the class description). [param report] gets the
## choices it made: a realm past the engine's, pieces with no combat record, the typical kit standing in for arts.
static func character_build_file(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet, report: Array = []) -> Dictionary:
	var lib: Dictionary = gd.file(LIBRARY_FILE)
	var typical: Array = lib.get("typical", [])
	var r: int = clampi(c.realm_index, 0, typical.size() - 1)
	if r != c.realm_index:
		report.append("realm %d: the fight engine has realms 0-%d; compiled at %d" % [c.realm_index, typical.size() - 1, r])
	var base: Dictionary = (typical[r] as Dictionary).duplicate(true)
	var pools: Dictionary = pool_sizes(c, gd, sheet, r)
	var layers: Array = Array(base.layers).duplicate()
	layers[0] = 0.0   # L1 is the Character's own attack_pct (its sheet lines), no typical stand-in (user, 2026-11-14)
	layers[2] = gear_layer(c, gd, db, sheet)
	var gear: Dictionary = gear_defence(c, gd, db, sheet, float(pools.n_body) * sheet.mult("khi_huyet_pct"), base.ward)
	var d := {"name": c.name if c.name != "" else c.id, "realm": r, "layers": layers, "n_body": pools.n_body,
		"n_qi": pools.n_qi, "ward": gear.ward, "stage_mult": Ladder.stage_mult(gd, c.stage)}
	if not gear.body.is_empty():
		d["body"] = gear.body
	var cm: Dictionary = gd.file("combat_engine").get("CHARACTER_MODS", {})
	var combat_keys: Array = Array(cm.get("passive", {}).keys()) + Array(cm.get("static", []))
	# the sheet's combat keys from every source but worn pieces (their lines come below, with their scopes)
	var lines: Array = []
	for key in combat_keys:
		var v: float = sheet.total_except_kind(str(key), StatSheet.KIND_ITEM)
		if v != 0.0:
			lines.append({"key": str(key), "value": v})
	var items: Array = []
	var arts: Array = []
	var wards: Array = []
	var slots: int = int(lib.constants.slots_by_realm[r])
	for key in [c.main_tech, c.second_tech] + Array(c.aux_tech):
		var e: Dictionary = c.techniques.get(str(key), {}) if str(key) != "" else {}
		if e.is_empty() or not CongPhap.usable(c, e.def):   # rule 8: a technique the root cannot use gives nothing
			continue
		var passives: Variant = e.def.get("passives")   # null on generated techniques and older copies
		if passives is Array:
			for pl in passives:
				lines.append((pl as Dictionary).duplicate(true))
		for ab in e.def.get("abilities", []):
			var aid: String = str(ab.get("ability_id", ""))
			if int(e.layer) >= int(ab.get("unlock_layer", 1)) and lib.arts.has(aid) and arts.size() < slots 					and not arts.any(func(x): return x.lib == aid):
				arts.append({"lib": aid})
	for item_id in CombatPower.controlled(c, gd, db, sheet).used:
		var rec: Dictionary = db.get_record("items", item_id)
		var named: String = str(rec.get("named", ""))
		if named != "":
			if not lib.items.has(named):
				report.append("item %s: named %s has no combat record; not compiled" % [str(rec.get("name", item_id)), named])
				continue
			items.append(named)
			for aid in lib.items[named].arts:
				if arts.size() < slots and not arts.any(func(a): return a.lib == aid):
					arts.append({"lib": aid})
			continue
		for a in rec.get("affixes", []):
			var line := {"key": str(a.stat), "value": float(a.value)}
			if not Array(a.get("scope", [])).is_empty():
				line["scope"] = Array(a.scope).duplicate()
			if str(a.stat) in combat_keys:
				lines.append(line)
		# Item Database rule 21: a rolled weapon gives its base's common attack art, a rolled armour or ward gear
		# piece its base's common ward (an armour's ward sits in the armour's own ward slot, Combat D&H rule 5)
		var b: Dictionary = lib.get("bases", {}).get(str(rec.get("base", "")), {})
		var roles: Array = b.get("roles", [])
		var common_art: String = str(b.get("common_art", ""))
		if "weapon" in roles and common_art != "" and lib.arts.has(common_art) and arts.size() < slots 				and not arts.any(func(x): return x.lib == common_art):
			arts.append({"lib": common_art})
		if b.get("common_ward") != null and not roles.is_empty() and str(roles[0]) in ["body_gear", "ward_gear"]:
			var w: Dictionary = (b.common_ward as Dictionary).duplicate(true)
			w["source"] = "item %s" % str(rec.get("name", item_id))
			w["own_slot"] = str(roles[0]) == "body_gear"
			wards.append(w)
	d["items"] = items
	d["modifiers"] = lines
	# L2 (art "more", Combat Formulas B): the typical +40 stands in for sources few Characters have yet (Way art
	# nodes); the Character's own unscoped damage_more replaces that much of it, so L2 = max(typical, own) and nothing
	# counts twice (2026-11-14, the L1 principle)
	var own_l2 := 0.0
	for ln in lines:
		if str(ln.key) == "damage_more" and Array(ln.get("scope", [])).is_empty():
			own_l2 += float(ln.value)
	for named in items:
		for mline in lib.items[named].get("modifiers", []):
			if str(mline.key) == "damage_more" and Array(mline.get("scope", [])).is_empty():
				own_l2 += float(mline.value)
	d.layers[1] = maxf(0.0, float(d.layers[1]) - own_l2)
	if not wards.is_empty():
		d["wards"] = wards
	if arts.is_empty():
		d["arts"] = base.arts
		report.append("no arts of its own: fights with the typical kit")
	else:
		d["arts"] = arts
	var purity := {}
	var to_engine: Dictionary = cm.get("scope_element", {})
	for el in Array(c.linh_can.elements.keys()) + Array(c.linh_can.variants.keys()):
		if to_engine.has(str(el)) and c.linh_can.purity(str(el)) > 0.0:
			purity[to_engine[str(el)]] = c.linh_can.purity(str(el))
	d["purity"] = purity
	return d


## A Character's pool sizes at engine realm [param r] (Combat Formulas A): {n_body, n_qi}, each
## clamp(stat / ref[r], n_min, n_max), the stats before their pct bonuses (the build-file path adds those).
static func pool_sizes(c: Character, gd: GameData, sheet: StatSheet, r: int) -> Dictionary:
	var cfg: Dictionary = gd.combat().fighter_pools
	var d: Dictionary = gd.attributes().derived
	var realm: Dictionary = gd.realm(c.realm_index)
	var ref_realm: Dictionary = gd.realm(r)
	var stage: float = Ladder.stage_mult(gd, c.stage)
	var per: float = float(d.khi_huyet_per_can_cot)
	# CharacterRules.khi_huyet_max and linh_luc without their pct steps
	var body: float = maxf(1.0, sheet.effective("can_cot", c) * per * float(realm.khi_huyet_mult) * stage)
	var qi: float = float(realm.linh_luc_base) * stage * CongPhap.tech_power(c, gd, sheet.effective("ngo_tinh", c))
	if c.has_capability(4):
		# Huyết Ngự Linh adds after the pct step in the game; the build-file path multiplies the whole pool by the pct
		# lines, so this part is divided by that multiplier first and comes out once (exact while the multiplier > 0)
		var conv: float = float(d.linh_luc_conversion) * CharacterRules.khi_huyet_max(c, gd, sheet).total
		var pct_mult: float = sheet.mult("linh_luc_pct")
		qi += conv / pct_mult if pct_mult > 0.0 else 0.0
	var ref_body: float = float(cfg.ref_talent) * per * float(ref_realm.khi_huyet_mult)
	var ref_qi: float = float(ref_realm.linh_luc_base) * float(cfg.ref_tech_power)
	return {"n_body": clampf(body / ref_body, float(cfg.n_min), float(cfg.n_max)),
		"n_qi": clampf(qi / ref_qi, float(cfg.n_min), float(cfg.n_max))}


## The gear layer's points, x3 (Combat Formulas B, L3): 100 x the attack of the artifacts [param c] controls, as built
## ([method CombatPower.artifact_numbers]), / (the realm's power_base x stage_mult).
static func gear_layer(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet) -> float:
	var atk := 0.0
	for n in CombatPower.artifact_numbers(c, gd, db, sheet):
		atk += float(n.attack)
	return 100.0 * atk / (float(gd.realm(c.realm_index).power_base) * Ladder.stage_mult(gd, c.stage))


## A Character's ward and body from its worn gear (Combat Defence & Healing A0, A2): {ward, body}. [param n_body] is
## the pool size the fight will have (flesh block reads it); [param typical_ward] gives the ward layers gear does not
## fill (W2, W4, W5). body is {} without body gear.
static func gear_defence(c: Character, gd: GameData, db: WorldDB, sheet: StatSheet, n_body: float, typical_ward: Dictionary) -> Dictionary:
	var cfg: Dictionary = gd.combat().fighter_gear
	var unit: float = float(gd.realm(c.realm_index).power_base) * Ladder.stage_mult(gd, c.stage)
	var a_w := 0.0
	var a_b := 0.0
	for n in CombatPower.artifact_numbers(c, gd, db, sheet):
		var roles: Array = gd.artifact_base(str(n.base)).get("roles", [])
		if not roles.is_empty() and str(roles[0]) == "body_gear":
			a_b += float(n.defense) / unit
		else:
			a_w += float(n.defense) / unit
	var layers: Array = Array(typical_ward.get("layers", [40, 40, 20, 10])).duplicate()
	layers[1] = 100.0 * float(cfg.layer_gear_scale) * a_w
	var ws: float = 100.0 * float(cfg.ward_gear_scale) * a_w
	var ward := {"ws_base": ws, "we": ws, "layers": layers,
		"block": float(cfg.flesh_block) * n_body + float(cfg.gear_block) * minf(a_w, 1.0)}
	var body := {}
	if a_b > 0.0:
		body = {"layers": [0.0, 100.0 * float(cfg.layer_gear_scale) * a_b, 0.0, 0.0], "block": float(cfg.gear_block) * a_b}
	return {"ward": ward, "body": body}
