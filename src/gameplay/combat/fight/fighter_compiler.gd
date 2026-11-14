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
## - layers, pools and the main ward: the typical fighter's at that realm, until the Meridian Map gives a Character
##   layers of its own (the sheet's pool, ward and stack lines then act on them, as on a build file).
## - items: the named pieces the Character controls (CombatPower.controlled, the pieces the sheet counts), with their
##   modifiers (scoped ones too), arts, wards, reserve arts and Effects.
## - modifiers: the sheet's combat keys from every source but worn pieces, plus ordinary pieces' affixes (scoped
##   ones too); keys with no part in a fight are left out.
## - arts: the named pieces' arts, up to the realm's art slots; a Character with none fights with the typical kit.
## - purity: the linh căn's element purities, by engine element.
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
	var d := {"name": c.name if c.name != "" else c.id, "realm": r, "layers": base.layers, "n_body": base.n_body,
		"n_qi": base.n_qi, "ward": base.ward}
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
	var slots: int = int(lib.constants.slots_by_realm[r])
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
	d["items"] = items
	d["modifiers"] = lines
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
