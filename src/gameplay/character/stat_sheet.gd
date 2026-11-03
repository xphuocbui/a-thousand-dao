class_name StatSheet
extends RefCounted
## Aggregates every stat modifier a character has — biến dị, Kinh Mạch Đồ nodes, the
## active công pháp, equipped artifact affixes and trận pháp — keeping the source of each one so
## the terminal can explain any total. Design: game-concept.md § Character Stats.
##
## Stat keys are shared with data files (meridian_tree.json, items_*.json,
## character_elements.json), e.g. cultivation_speed_pct, attack_pct, field_plots.
## Stats that are local to one artifact (artifact_attack_pct, than_thuc_cost_pct,
## element_affinity_pct) are excluded here and applied by CombatPower.
##
## Usage:
## [codeblock]
## var sheet := StatSheet.build(character, gd, db, tree)
## var speed_pct: float = sheet.total("cultivation_speed_pct")
## for s in sheet.sources("cultivation_speed_pct"): print(s.source, s.value)
## var ngo: float = sheet.effective("ngo_tinh", character)
## [/codeblock]

const ARTIFACT_LOCAL_STATS := ["artifact_attack_pct", "artifact_defense_pct", "than_thuc_cost_pct", "element_affinity_pct"]

## stat -> Array of {source, value}
var _mods: Dictionary = {}


## Collects all modifiers for [param c]. [param db] resolves item ids; [param tree] may be null.
static func build(c: Character, gd: GameData, db: WorldDB, tree: MeridianTree) -> StatSheet:
	var sheet := StatSheet.new()
	for b in c.linh_can.bien_di.keys():
		var def: Dictionary = gd.bien_di(b)
		for fx in def.get("effects", []):
			sheet.add_mod("Biến dị: %s" % def.get("name", b), str(fx.stat), float(fx.value))
	if tree != null:
		for m in tree.collect_mods(c.tree_nodes, c.linh_can, gd):
			sheet.add_mod(m.source, m.stat, m.value)
	if db != null and c.cong_phap_id != "":
		var cp: Dictionary = db.get_record("items", c.cong_phap_id)
		for bonus in cp.get("bonuses", []):
			sheet.add_mod("Công pháp: %s" % cp.get("name", "?"), str(bonus.stat), float(bonus.value))
	if db != null:
		for item_id in c.equipped:
			var art: Dictionary = db.get_record("items", item_id)
			for affix in art.get("affixes", []):
				if not ARTIFACT_LOCAL_STATS.has(str(affix.stat)):
					sheet.add_mod("Pháp bảo: %s" % art.get("name", "?"), str(affix.stat), float(affix.value))
	ProgressionEdges.add_perk_mods(c, gd, sheet)
	Formations.add_mods(c, gd, sheet)
	return sheet


## Adds one modifier.
func add_mod(source: String, stat: String, value: float) -> void:
	if not _mods.has(stat):
		_mods[stat] = []
	_mods[stat].append({"source": source, "value": value})


## Sum of all modifiers for a stat (0 if none).
func total(stat: String) -> float:
	var t: float = 0.0
	for m in _mods.get(stat, []):
		t += float(m.value)
	return t


## Individual modifiers for a stat.
func sources(stat: String) -> Array:
	return _mods.get(stat, [])


## True if any source grants a positive flag-style stat (e.g. "single_artifact").
func has_flag(stat: String) -> bool:
	return total(stat) > 0.0


## Every stat key that has at least one modifier.
func stat_keys() -> Array:
	var keys: Array = _mods.keys()
	keys.sort()
	return keys


## Effective thiên phú: base value plus flat bonuses from the sheet, clamped to 1..150.
func effective(thien_phu_id: String, c: Character) -> float:
	return clampf(float(c.base_stat(thien_phu_id)) + total(thien_phu_id), 1.0, 150.0)


## Breakdown of an effective thiên phú.
func explain_thien_phu(thien_phu_id: String, c: Character, label: String) -> Breakdown:
	var b := Breakdown.new(label)
	b.base("Thiên phú (innate)", float(c.base_stat(thien_phu_id)))
	for m in sources(thien_phu_id):
		b.add(m.source, float(m.value))
	b.clamp_to(1.0, 150.0)
	return b
