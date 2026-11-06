class_name StatSheet
extends RefCounted
## Aggregates every stat modifier a character has, keeping the source of each one so any total
## can be explained. Design: design/gdd/character-stats.md rules 12-15, Formulas I.
##
## Stat keys are shared with data files (meridian_tree.json, items_*.json,
## character_elements.json), e.g. cultivation_speed_pct, attack_pct, field_plots.
## Stats that are local to one artifact (artifact_attack_pct, than_thuc_cost_pct,
## element_affinity_pct) are excluded here and applied by CombatPower.
##
## Rules implemented here:
## - Modifiers are quantized once, on entry, to their key's grid (floored, with a tolerance).
## - The tree's breakthrough_chance is capped at tree_breakthrough_cap; other sources are not.
## - herb_growth_pct and alchemy_success meet character-wide ceilings: the positive modifiers
##   are capped, then the negative ones are added.
##
## Usage:
## [codeblock]
## var sheet := StatSheet.build(character, gd, db, tree)
## var speed_pct: float = sheet.total("cultivation_speed_pct")
## for s in sheet.sources("cultivation_speed_pct"): print(s.source, s.value)
## var ngo: float = sheet.effective("ngo_tinh", character)
## [/codeblock]

const ARTIFACT_LOCAL_STATS := ["artifact_attack_pct", "artifact_defense_pct", "than_thuc_cost_pct", "element_affinity_pct"]
## Modifier kinds that breakthrough_chance treats apart (Realms Formulas C).
const KIND_TREE := "tree"
const KIND_PERK := "perk"

## stat -> Array of {source, value, kind}
var _mods: Dictionary = {}
var _gd: GameData = null


## Collects all modifiers for [param c]. [param db] resolves item ids; [param tree] may be null.
static func build(c: Character, gd: GameData, db: WorldDB, tree: MeridianTree) -> StatSheet:
	var sheet := StatSheet.new()
	sheet._gd = gd
	var pair_pct: float = float(gd.attributes().linh_can.pair_bonus_pct)
	for pair in c.linh_can.generating_pairs(gd):
		sheet.add_mod("Tương sinh: %s → %s" % [gd.element_name(pair.from), gd.element_name(pair.to)], "cultivation_speed_pct", pair_pct)
	for def in gd.variant_defs():
		if c.linh_can.variants.has(def.id):
			for line in c.linh_can.variant_lines(gd, str(def.id)):
				sheet.add_mod("Biến dị: %s" % def.name, str(line.stat), float(line.value))
	if tree != null:
		for m in tree.collect_mods(c, gd):
			sheet.add_mod(m.source, m.stat, m.value, KIND_TREE)
	ProgressionEdges.add_perk_mods(c, gd, sheet)
	Formations.add_mods(c, gd, sheet)
	# Physique may be raised by anything above, so body techniques come after it.
	for line in CongPhap.bonus_lines(c, gd, sheet.effective("can_cot", c)):
		sheet.add_mod(line.source, line.stat, line.value)
	sheet._add_capability_mods(c)
	# Last, because control is limited by thần thức, which everything above can raise. No affix
	# touches thần thức, so reading it here is not circular (item-database.md rule 11).
	if db != null:
		for item_id in CombatPower.controlled(c, gd, db, sheet).used:
			var art: Dictionary = db.get_record("items", item_id)
			for affix in art.get("affixes", []):
				if not ARTIFACT_LOCAL_STATS.has(str(affix.stat)):
					sheet.add_mod("Pháp bảo: %s" % art.get("name", "?"), str(affix.stat), float(affix.value))
	return sheet


## Capabilities hosted by this sheet: #4 and #25 (rules 17-18).
func _add_capability_mods(c: Character) -> void:
	if c.has_capability(2):
		add_mod("Thần Thức Phân Hóa", "than_thuc_pct", float(_gd.capability(2).params.than_thuc_pct))
	if c.has_capability(4) and int(roundf(c.vitality * 1000.0)) < 300:
		add_mod("Huyết Ngự Linh", "attack_pct", -20.0)
	if c.has_capability(25):
		var hd: Dictionary = _gd.attributes().derived.heart_demon_strength
		add_mod("Tâm Ma Hóa Lực", "qi_deviation_pct", float(hd.deviation_pct))
		if c.tam_ma > float(hd.threshold):
			add_mod("Tâm Ma Hóa Lực", "attack_pct", c.tam_ma / float(hd.divisor))


## Adds one modifier, quantized to its key's grid. [param kind] marks tree or perk sources.
func add_mod(source: String, stat: String, value: float, kind: String = "") -> void:
	if not _mods.has(stat):
		_mods[stat] = []
	_mods[stat].append({"source": source, "value": _quantize(stat, value), "kind": kind})


## Total of a stat, after any cap or ceiling that applies to it.
func total(stat: String) -> float:
	if stat == "breakthrough_chance":
		return tree_breakthrough() + other_breakthrough() + perk_breakthrough()
	var ceiling: float = _ceiling(stat)
	if ceiling >= 0.0:
		return minf(positive(stat), ceiling) + negative(stat)
	return _sum(stat, func(_m): return true)


## max(0, 1 + total / 100): the single multiplier of a _pct key.
func mult(stat: String) -> float:
	return maxf(0.0, 1.0 + total(stat) / 100.0)


## Sum of a stat's positive modifiers.
func positive(stat: String) -> float:
	return _sum(stat, func(m): return float(m.value) > 0.0)


## Sum of a stat's negative modifiers.
func negative(stat: String) -> float:
	return _sum(stat, func(m): return float(m.value) < 0.0)


## The tree's share of breakthrough_chance, capped (percentage points).
func tree_breakthrough() -> float:
	var raw: float = _sum("breakthrough_chance", func(m): return m.kind == KIND_TREE)
	if _gd == null:
		return raw
	return minf(raw, float(_gd.meridian_config().tree_breakthrough_cap))


## Destiny perks' share of breakthrough_chance (percentage points).
func perk_breakthrough() -> float:
	return _sum("breakthrough_chance", func(m): return m.kind == KIND_PERK)


## Everything else on breakthrough_chance (percentage points).
func other_breakthrough() -> float:
	return _sum("breakthrough_chance", func(m): return m.kind != KIND_TREE and m.kind != KIND_PERK)


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


## Effective thiên phú: base value plus flat bonuses from the sheet, clamped.
func effective(thien_phu_id: String, c: Character) -> float:
	return clampf(float(c.base_stat(thien_phu_id)) + total(thien_phu_id), _talent_min(), _talent_max())


## Breakdown of an effective thiên phú.
func explain_thien_phu(thien_phu_id: String, c: Character, label: String) -> Breakdown:
	var b := Breakdown.new(label)
	b.base("Thiên phú (innate)", float(c.base_stat(thien_phu_id)))
	for m in sources(thien_phu_id):
		b.add(m.source, float(m.value))
	b.clamp_to(_talent_min(), _talent_max())
	return b


## The ceiling line for a key, or "" when nothing is clamped.
func clamp_note(stat: String) -> String:
	var ceiling: float = _ceiling(stat)
	if ceiling >= 0.0 and positive(stat) > ceiling:
		return "%s %.1f, ceiling %.1f" % [stat, positive(stat), ceiling]
	return ""


func _ceiling(stat: String) -> float:
	if _gd == null:
		return -1.0
	return float(_gd.attributes().bonus_ceilings.get(stat, -1.0))


func _talent_min() -> float:
	return float(_gd.attributes().derived.effective_talent_min) if _gd != null else 1.0


func _talent_max() -> float:
	return float(_gd.attributes().derived.effective_talent_max) if _gd != null else 150.0


## Sums matching modifiers in integer grid units, so totals are exact.
func _sum(stat: String, keep: Callable) -> float:
	var units: float = _units(stat)
	var t: int = 0
	for m in _mods.get(stat, []):
		if keep.call(m):
			t += int(roundf(float(m.value) * units))
	return float(t) / units


func _quantize(stat: String, value: float) -> float:
	var units: float = _units(stat)
	return floorf(value * units + 1e-6) / units


func _units(stat: String) -> float:
	if _gd == null:
		return 100.0
	return 1.0 / _gd.stat_precision(stat)
