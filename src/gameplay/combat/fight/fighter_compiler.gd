class_name FighterCompiler
extends RefCounted
## Builds [FighterProfile]s for the fight engine (ADR-0001 decision 2).
##
## Today it builds the fighters that have no Character: the reference enemies (typical, top_end, top_end_the_tu) at
## every realm, read from [code]assets/data/combat_reference_fighters.json[/code], which the design tool writes from
## fight.py's own definitions (tools/design/combat_sim/export_reference_fighters.py; one source, with a drift
## check). Creatures and tribulation waves are meant to come the same way.
##
## Compiling a Character (the ADR's [code]compile(c, gd, db, tree)[/code]) waits on design: the art and ward data
## are not in game data yet, and the damage layers and pools a build file hand-sets are meant to come from the parked
## Meridian Map. See design/research/fighter-compiler-questions.md.
##
## Usage:
## [codeblock]
## var errors: Array = []
## var enemy: FighterProfile = FighterCompiler.from_data("typical", 2, gd, errors)
## [/codeblock]

## The data file the reference fighters live in.
const REFERENCE_FILE := "combat_reference_fighters"


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
