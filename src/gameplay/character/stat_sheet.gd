class_name StatSheet
extends RefCounted
## Aggregates every stat modifier a character has, keeping the source of each one so any total
## can be explained. Design: design/gdd/character-stats.md rules 12-15, Formulas I.
##
## Stat keys are shared with data files (dao_do_map.json, items_*.json,
## character_elements.json), e.g. cultivation_speed_pct, attack_pct, field_plots.
## Stats that are local to one artifact (artifact_attack_pct, artifact_defense_pct,
## element_affinity_pct, artifact_slots) are excluded here and applied by CombatPower and EquipSlots.
##
## Rules implemented here:
## - Modifiers are quantized once, on entry, to their key's grid (floored, with a tolerance).
## - The tree's breakthrough_chance follows the curve k * ln(1 + sum / k), k = tree_breakthrough_k (Đạo Đồ Formulas F);
##   other sources are not curved.
## - A scoped modifier (a Đạo Đồ line such as attack_pct [hoa]) is held apart from the totals, which stay the plain
##   lines; [method scoped_lines] hands them on with their scopes (to the fighter, ADR-0004 decision 4).
## - herb_growth_pct follows the bonus curve k * ln(1 + sum+ / k) + sum- (k from bonus_curves; Character Stats rule 14,
##   Formulas I: curves replaced the ceilings 2026-11-10). alchemy_success has no cap: Alchemy divides the failure chance
##   by it (Alchemy F1). The lifespan bonus has its own curve (CultivationRules.lifespan_bonus_curved). A key put in
##   bonus_ceilings would still cap its positive modifiers; none is there now.
##
## Usage:
## [codeblock]
## var sheet := StatSheet.build(character, gd, db, tree)
## var speed_pct: float = sheet.total("cultivation_speed_pct")
## for s in sheet.sources("cultivation_speed_pct"): print(s.source, s.value)
## var ngo: float = sheet.effective("ngo_tinh", character)
## [/codeblock]

## Stats a piece applies to itself, not to the sheet. `artifact_slots` from a worn piece is counted by EquipSlots,
## so a piece never opens the slot it sits in.
const ARTIFACT_LOCAL_STATS := ["artifact_attack_pct", "artifact_defense_pct", "element_affinity_pct", "artifact_slots"]
## Modifier kinds that breakthrough_chance treats apart (Realms Formulas C).
const KIND_TREE := "tree"
const KIND_PERK := "perk"
## Modifiers worn pieces put on the sheet (the item-slot count leaves them out: Item Database rule 11).
const KIND_ITEM := "item"
## NPC Relationships rule 15a: a row the hook pass gives from a tie (source `tie`).
const KIND_TIE := "tie"

## stat -> Array of {source, value, kind}
var _mods: Dictionary = {}
## Scoped lines, in order: {source, stat, value, kind, scope}
var _scoped: Array = []
var _gd: GameData = null


## Collects all modifiers for [param c]. [param db] resolves item ids; [param tree] may be null.
static func build(c: Character, gd: GameData, db: WorldDB, tree: DaoDoTree) -> StatSheet:
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
			sheet.add_mod(m.source, m.stat, m.value, KIND_TREE, m.scope)
		sheet._add_tree_effect_lines(c, tree)
	ProgressionEdges.add_perk_mods(c, gd, sheet)
	Formations.add_mods(c, gd, sheet, db)
	sheet._add_trait_mods(c)
	# Physique and comprehension may be raised by anything above (including talent tiers), so techniques come after them.
	for line in CongPhap.bonus_lines(c, gd, sheet.effective("can_cot", c), sheet.effective("ngo_tinh", c)):
		sheet.add_mod(line.source, line.stat, line.value)
	sheet._add_capability_mods(c)
	sheet._add_tie_mods(c)
	if db != null:
		sheet._add_hall_mods(c, db)
	# Last, because control is limited by thần thức, which everything above can raise. No affix
	# touches thần thức, so reading it here is not circular (item-database.md rule 11).
	if db != null:
		# Named pieces may carry combat keys (art speed, crit) the game does not run yet; they stay on the record.
		var labels: Dictionary = gd.file("character_stat_labels").get("labels", {})
		var used: Array = CombatPower.controlled(c, gd, db, sheet).used
		sheet._add_set_lines(gd, db, used, labels)
		for item_id in used:
			var art: Dictionary = db.get_record("items", item_id)
			for line in ItemStats.lines(art):
				if not ARTIFACT_LOCAL_STATS.has(line.stat) and labels.has(line.stat) and not labels[line.stat].get("fight_only", false):
					sheet.add_mod("Pháp bảo: %s" % art.get("name", "?"), line.stat, line.value, KIND_ITEM)
	if tree != null:
		sheet._add_tree_effect_from(c, tree)
	return sheet


## Item Database rule 22 (2026-11-26): each set's modifiers while set_bonus_min_pieces distinct pieces of it are
## worn (counted from the pieces that count under rule 11), as item lines under "Bộ: <name> (n/N)", so the
## Breakdown shows the set and its count. The full-set Effect reaches fights through the build file (BuildFileCompiler).
func _add_set_lines(gd: GameData, db: WorldDB, used: Array, labels: Dictionary) -> void:
	var data: Dictionary = gd.file("items_sets")
	if data.get("sets", []).is_empty():
		return
	var need: int = int(data.get("constants", {}).get("set_bonus_min_pieces", 2))
	var worn := {}
	for item_id in used:
		var named: String = str(db.get_record("items", item_id).get("named", ""))
		if named != "":
			worn[named] = true
	for s in data.sets:
		var n: int = 0
		for pc in s.pieces:
			if worn.has(str(pc)):
				n += 1
		if n < need:
			continue
		var src: String = "Bộ: %s (%d/%d)" % [str(s.get("name", s.id)), n, s.pieces.size()]
		for b in s.get("bonuses", []):
			if n < int(b.get("pieces", need)):
				continue
			for line in b.get("modifiers", []):
				var stat: String = str(line.key)
				if labels.has(stat) and not labels[stat].get("fight_only", false):
					add_mod(src, stat, float(line.value), KIND_ITEM, Array(line.get("scope", [])))


## NPC Traits rule 5: each held trait's stat rows (a personality trait's or calling's boon and cost; a fate-given or
## gained trait's rows), under the source "<kind>: <name>" (tính tình, nghề nghiệp, bẩm sinh, hậu thiên).
## NPC Relationships rule 15a: the hook pass's rows from ties (a master, a đạo lữ), under the source "Quan hệ: ...".
## Provinces Stage 4 (design/quick-specs/province-building-catalogue.md): the sect halls at the member's sect seat:
## member_stats for every member, seat_stats while the member is at the seat, a level at a time (source "Sect hall: ...").
func _add_hall_mods(c: Character, db: WorldDB) -> void:
	if c.sect_id == "" or not db.has_record("sects", c.sect_id):
		return
	var s: Dictionary = db.get_record("sects", c.sect_id)
	var halls: Dictionary = s.get("halls", {})
	if halls.is_empty():
		return
	var at_seat: bool = c.location_id == str(s.get("hq_place_id", ""))
	for k in halls:
		var kd: Dictionary = ProvinceBuildings.kind(_gd, str(k))
		var lv: float = float(halls[k])
		var src: String = "Sect hall: %s" % str(kd.get("name_vi", kd.get("name", k)))
		for stat in kd.get("member_stats", {}):
			add_mod(src, str(stat), float(kd.member_stats[stat]) * lv)
		if at_seat:
			for stat in kd.get("seat_stats", {}):
				add_mod(src, str(stat), float(kd.seat_stats[stat]) * lv)


func _add_tie_mods(c: Character) -> void:
	var label := {"master": "sư phụ", "dao_lu": "đạo lữ"}
	for row in c.tie_rows:
		add_mod("Quan hệ: %s" % label.get(str(row.get("source", "")), str(row.get("source", ""))), str(row.stat), float(row.value), KIND_TIE)


func _add_trait_mods(c: Character) -> void:
	if c.npc_traits.is_empty() or not _gd.registry.has_file(NpcTraits.FILE):
		return
	for row in NpcTraits.stat_rows(_gd, {"npc_traits": c.npc_traits}, c.linh_can):
		add_mod(str(row.source), str(row.stat), float(row.value), "", Array(row.get("scope", [])))


## The plain lines of the Đạo Đồ Effects the character holds (their closings: maximum health -15 %, art speed -20 %;
## combat_effects.json "lines"), under the source "Đạo Đồ: <Effect>". An Effect whose host is outside fights
## (not_run) adds nothing. ADR-0004 decision 3.
func _add_tree_effect_lines(c: Character, tree: DaoDoTree) -> void:
	var lib: Dictionary = _gd.file("combat_effects").get("effects", {})
	for name in tree.held_effects(c):
		var e: Dictionary = lib.get(str(name).split(" (")[0], {})
		if e.is_empty() or e.get("not_run"):
			continue
		for ln in e.get("lines", []):
			add_mod("Đạo Đồ: %s" % name, str(ln.key), float(ln.value), KIND_TREE, Array(ln.get("scope", [])))


## Lines computed from another stat after every other source (Hundred Refinements: half your artifact power counts as
## attack; combat_effects.json "sheet_from").
func _add_tree_effect_from(c: Character, tree: DaoDoTree) -> void:
	var lib: Dictionary = _gd.file("combat_effects").get("effects", {})
	for name in tree.held_effects(c):
		var e: Dictionary = lib.get(str(name).split(" (")[0], {})
		for f in e.get("sheet_from", []):
			add_mod("Đạo Đồ: %s" % name, str(f.key), total(str(f.from)) * float(f.factor), KIND_TREE)


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


## Adds one modifier, quantized to its key's grid. [param kind] marks tree or perk sources. A non-empty
## [param scope] keeps the line out of the totals ([method scoped_lines]).
func add_mod(source: String, stat: String, value: float, kind: String = "", scope: Array = []) -> void:
	if not scope.is_empty():
		_scoped.append({"source": source, "stat": stat, "value": _quantize(stat, value), "kind": kind, "scope": scope.duplicate()})
		return
	if not _mods.has(stat):
		_mods[stat] = []
	_mods[stat].append({"source": source, "value": _quantize(stat, value), "kind": kind})


## Total of a stat, after any cap or ceiling that applies to it.
func total(stat: String) -> float:
	if stat == "breakthrough_chance":
		return tree_breakthrough() + other_breakthrough() + perk_breakthrough()
	var k: float = _curve(stat)
	if k > 0.0:
		var pos: float = positive(stat)
		return (k * log(1.0 + pos / k) if pos > 0.0 else 0.0) + negative(stat)
	var ceiling: float = _ceiling(stat)
	if ceiling >= 0.0:
		return minf(positive(stat), ceiling) + negative(stat)
	return _sum(stat, func(_m): return true)


## max(0, 1 + total / 100): the single multiplier of a _pct key.
func mult(stat: String) -> float:
	return maxf(0.0, 1.0 + total(stat) / 100.0)


## A stat's total without the modifiers of one kind (no ceiling applied).
func total_except_kind(stat: String, kind: String) -> float:
	return _sum(stat, func(m): return m.kind != kind)


## Sum of a stat's positive modifiers.
func positive(stat: String) -> float:
	return _sum(stat, func(m): return float(m.value) > 0.0)


## Sum of a stat's negative modifiers.
func negative(stat: String) -> float:
	return _sum(stat, func(m): return float(m.value) < 0.0)


## The tree's share of breakthrough_chance on its curve (percentage points): k * ln(1 + raw / k), Đạo Đồ Formulas F.
func tree_breakthrough() -> float:
	var raw: float = tree_breakthrough_raw()
	if _gd == null or raw <= 0.0:
		return raw
	var k: float = float(_gd.dao_do_config().tree_breakthrough_k)
	return k * log(1.0 + raw / k)


## The tree's summed breakthrough_chance before the curve (percentage points).
func tree_breakthrough_raw() -> float:
	return _sum("breakthrough_chance", func(m): return m.kind == KIND_TREE)


## Every scoped line, in the order added: {source, stat, value, kind, scope}.
func scoped_lines() -> Array:
	return _scoped


## Scoped lines of one stat.
func scoped(stat: String) -> Array:
	return _scoped.filter(func(m): return m.stat == stat)


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


## The curve or ceiling line for a key, or "" when nothing is curved or clamped.
func clamp_note(stat: String) -> String:
	var k: float = _curve(stat)
	if k > 0.0 and positive(stat) > 0.0:
		return "%s %.1f, curved to %.1f (k %.0f)" % [stat, positive(stat), k * log(1.0 + positive(stat) / k), k]
	var ceiling: float = _ceiling(stat)
	if ceiling >= 0.0 and positive(stat) > ceiling:
		return "%s %.1f, ceiling %.1f" % [stat, positive(stat), ceiling]
	return ""


## The bonus-curve scale k of a key (bonus_curves), or 0 when the key is not curved.
func _curve(stat: String) -> float:
	if _gd == null:
		return 0.0
	return float(_gd.attributes().get("bonus_curves", {}).get(stat, 0.0))


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
