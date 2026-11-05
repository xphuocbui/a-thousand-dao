class_name GameData
extends RefCounted
## Typed, indexed access to the game's data files (assets/data/*.json).
## Every gameplay system receives a GameData instead of reading files itself.
## Design: design/gdd/game-concept.md (all balance values live in data).
##
## Usage:
## [codeblock]
## var gd := GameData.load_from("res://assets/data")
## var realm: Dictionary = gd.realm(0)          # Luyện Khí
## var herb: Dictionary = gd.herb("hoa_linh_chi")
## [/codeblock]

const DEFAULT_DIR := "res://assets/data"

## The underlying registry (raw files).
var registry: DataRegistry

var _realm_index: Dictionary = {}
var _herbs: Dictionary = {}
var _recipes: Dictionary = {}
var _materials: Dictionary = {}
var _artifact_bases: Dictionary = {}
var _variants: Dictionary = {}
var _origins: Dictionary = {}
var _archetypes: Dictionary = {}
var _place_types: Dictionary = {}


## Loads every data file from [param dir]. Check [member DataRegistry.errors] on the registry.
static func load_from(dir: String = DEFAULT_DIR) -> GameData:
	var reg := DataRegistry.new()
	reg.load_dir(dir)
	var gd := GameData.new()
	gd.setup(reg)
	return gd


## Builds the indexes from an already-loaded registry.
func setup(reg: DataRegistry) -> void:
	registry = reg
	var realms: Array = realms()
	for i in realms.size():
		_realm_index[realms[i].id] = i
	_herbs = _index(file("items_herbs").get("herbs", []))
	_recipes = _index(file("items_recipes").get("recipes", []))
	_materials = _index(file("items_materials").get("materials", []))
	_artifact_bases = _index(file("items_artifacts").get("bases", []))
	_variants = _index(file("character_elements").get("variants", []))
	_origins = _index(file("character_attributes").get("origins", []))
	_archetypes = _index(file("world_generation").get("archetypes", []))
	_place_types = _index(file("world_generation").get("place_types", []))


## Raw file content by id.
func file(file_id: String) -> Dictionary:
	return registry.get_file(file_id)


# --- Realms -------------------------------------------------------------------

## All realms in order (index 0 = Luyện Khí).
func realms() -> Array:
	return file("cultivation_realms").get("realms", [])


## Realm record by index.
func realm(index: int) -> Dictionary:
	var all: Array = realms()
	return all[clampi(index, 0, all.size() - 1)]


## Realm index for an id such as "truc_co"; -1 if unknown.
func realm_index(realm_id: String) -> int:
	return _realm_index.get(realm_id, -1)


## Realm index for a display name such as "Trúc Cơ"; -1 if unknown.
func realm_index_by_name(realm_name: String) -> int:
	var all: Array = realms()
	for i in all.size():
		if all[i].name == realm_name:
			return i
	return -1


## Number of stages in a realm.
func stage_count(realm_idx: int) -> int:
	return (realm(realm_idx).stage_names as Array).size()


## Ladder constants of cultivation_realms.json.
func ladder() -> Dictionary:
	return file("cultivation_realms").get("ladder", {})


## Grid of a stat key (Character Stats rule 15): 0.1, 0.01 or 1.
func stat_precision(stat: String) -> float:
	var f: Dictionary = file("character_stat_labels")
	if f.get("precision_overrides", {}).has(stat):
		return float(f.precision_overrides[stat])
	var unit: String = str(f.get("labels", {}).get(stat, {}).get("unit", "flat"))
	return float(f.get("precision_by_unit", {}).get(unit, 0.01))


## Display name such as "Trúc Cơ Trung kỳ".
func realm_label(realm_idx: int, stage: int) -> String:
	var r: Dictionary = realm(realm_idx)
	var names: Array = r.stage_names
	return "%s %s" % [r.name, names[clampi(stage, 0, names.size() - 1)]]


## Cultivation section of cultivation_realms.json.
func cultivation_rules() -> Dictionary:
	return file("cultivation_realms").get("cultivation", {})


## Breakthrough section of cultivation_realms.json.
func breakthrough_rules() -> Dictionary:
	return file("cultivation_realms").get("breakthrough", {})


# --- Character ------------------------------------------------------------------

## character_attributes.json content.
func attributes() -> Dictionary:
	return file("character_attributes")


## Ordered list of thiên phú definitions.
func thien_phu_defs() -> Array:
	return attributes().get("thien_phu", [])


## Grade band name for a 1-100 value ("Hạ" .. "Thiên").
func grade_name(value: float) -> String:
	var bands: Array = attributes().get("grade_bands", [])
	for band in bands:
		if value <= float(band.max):
			return band.name
	return bands[-1].name if not bands.is_empty() else ""


## Treasure definition by id (items_treasures.json), or {}.
func treasure(treasure_id: String) -> Dictionary:
	for t in file("items_treasures").get("treasures", []):
		if t.id == treasure_id:
			return t
	return {}


## Readable name of a modifier stat key ("cultivation_speed_pct" -> "tu luyện speed").
func stat_name(stat: String) -> String:
	for def in thien_phu_defs():
		if def.id == stat:
			return str(def.name)
	return str(file("character_stat_labels").get("labels", {}).get(stat, {}).get("name", stat))


## A modifier as player-facing text: "+0.8% tu luyện speed", "+20 years thọ nguyên",
## "+5 Khí vận", or the bare name for on/off flags.
func format_mod(stat: String, value: float) -> String:
	var label: Dictionary = file("character_stat_labels").get("labels", {}).get(stat, {})
	var nm: String = stat_name(stat)
	match str(label.get("unit", "flat")):
		"flag":
			return nm
		"pct":
			return "%s%% %s" % [_signed(value), nm]
		"years":
			return "%s years %s" % [_signed(value), nm]
	return "%s %s" % [_signed(value), nm]


func _signed(v: float) -> String:
	if is_equal_approx(v, roundf(v)):
		return "%+d" % int(roundf(v))
	return "%+.1f" % v if absf(v) >= 1.0 else "%+.2f" % v


## Origin record by id ("tan_tu", "tong_mon", "gia_toc").
func origin(origin_id: String) -> Dictionary:
	return _origins.get(origin_id, {})


## All origins.
func origins() -> Array:
	return attributes().get("origins", [])


## character_elements.json content.
func elements_file() -> Dictionary:
	return file("character_elements")


## Base element ids in tương sinh cycle order.
func element_cycle() -> Array:
	return elements_file().get("cycle", [])


## Element record ("kim", "moc", ...).
func element(element_id: String) -> Dictionary:
	return elements_file().get("elements", {}).get(element_id, {})


## Data (Vietnamese) name of an element or variant id; used as stat sheet sources.
func element_name(element_id: String) -> String:
	var e: Dictionary = element(element_id)
	if not e.is_empty():
		return e.name
	return _variants.get(element_id, {}).get("name", element_id)


## Player-facing label of an element or variant id, such as "Fire [Hỏa]".
func element_label(element_id: String) -> String:
	var e: Dictionary = element(element_id)
	if e.is_empty():
		e = _variants.get(element_id, {})
	if e.is_empty():
		return element_id
	return "%s [%s]" % [e.get("name_en", e.name), e.name]


## Element effect constants (element_effects block).
func element_effects() -> Dictionary:
	return elements_file().get("element_effects", {})


## All variant root definitions, in catalogue (roll) order.
func variant_defs() -> Array:
	return elements_file().get("variants", [])


## Variant root definition by id ({} for anything else, such as a relocated mutation).
func variant(variant_id: String) -> Dictionary:
	return _variants.get(variant_id, {})


## Per-purity stat lines of a variant: [{stat, per_purity}].
func variant_effects(variant_id: String) -> Array:
	return elements_file().get("variant_effects", {}).get(variant_id, [])


# --- Items ------------------------------------------------------------------------

## Herb template by id.
func herb(herb_id: String) -> Dictionary:
	return _herbs.get(herb_id, {})


## All herb templates.
func herbs() -> Array:
	return file("items_herbs").get("herbs", [])


## Recipe by id.
func recipe(recipe_id: String) -> Dictionary:
	return _recipes.get(recipe_id, {})


## All recipes.
func recipes() -> Array:
	return file("items_recipes").get("recipes", [])


## Material template by id.
func material(material_id: String) -> Dictionary:
	return _materials.get(material_id, {})


## All material templates.
func materials() -> Array:
	return file("items_materials").get("materials", [])


## Artifact base by id ("phi_kiem", ...).
func artifact_base(base_id: String) -> Dictionary:
	return _artifact_bases.get(base_id, {})


## items_artifacts.json content.
func artifacts_file() -> Dictionary:
	return file("items_artifacts")


## Artifact grade by rank 0..4.
func artifact_grade(rank: int) -> Dictionary:
	var grades: Array = artifacts_file().get("grades", [])
	return grades[clampi(rank, 0, grades.size() - 1)]


## Artifact tier (Pháp khí, Pháp bảo, ...) for a realm index.
func artifact_tier(realm_idx: int) -> Dictionary:
	var tiers: Array = artifacts_file().get("tiers", [])
	return tiers[clampi(realm_idx, 0, tiers.size() - 1)]


## items_cong_phap.json content.
func cong_phap_file() -> Dictionary:
	return file("items_cong_phap")


## Công pháp tier by rank 0..3 (Hoàng .. Thiên).
func cong_phap_tier(rank: int) -> Dictionary:
	var tiers: Array = cong_phap_file().get("tiers", [])
	return tiers[clampi(rank, 0, tiers.size() - 1)]


## Công pháp tier rank by id ("hoang" -> 0); 0 if unknown.
func cong_phap_tier_rank(tier_id: String) -> int:
	var tiers: Array = cong_phap_file().get("tiers", [])
	for t in tiers:
		if t.id == tier_id:
			return int(t.rank)
	return 0


# --- World ------------------------------------------------------------------------

## world_generation.json content.
func world_gen() -> Dictionary:
	return file("world_generation")


## world_names.json content.
func names() -> Dictionary:
	return file("world_names")


## Archetype by id.
func archetype(archetype_id: String) -> Dictionary:
	return _archetypes.get(archetype_id, {})


## Place type by id.
func place_type(type_id: String) -> Dictionary:
	return _place_types.get(type_id, {})


# --- Other files --------------------------------------------------------------

## meridian_tree.json content.
func tree_config() -> Dictionary:
	return file("meridian_tree")


## meridian_tree.json content (alias read by the stat sheet).
func meridian_config() -> Dictionary:
	return file("meridian_tree")


## The capability catalogue, in id order.
func capabilities() -> Array:
	return file("meridian_capabilities").get("capabilities", [])


## The capability with [param capability_id], or {}.
func capability(capability_id: int) -> Dictionary:
	for c in capabilities():
		if int(c.id) == capability_id:
			return c
	return {}


## The authored technique template with [param template_id], or {}.
func tech_template(template_id: String) -> Dictionary:
	for t in cong_phap_file().get("templates", []):
		if t.id == template_id:
			return t
	return {}


## combat_rules.json content.
func combat() -> Dictionary:
	return file("combat_rules")


## session_actions.json content.
func session() -> Dictionary:
	return file("session_actions")


## events_budgets.json content.
func budgets() -> Dictionary:
	return file("events_budgets")


## Budget block for a realm index.
func realm_budget(realm_idx: int) -> Dictionary:
	return budgets().get("per_realm", {}).get(realm(realm_idx).id, {})


## events_templates.json content.
func event_templates() -> Dictionary:
	return file("events_templates")


## events_prompts.json content.
func prompts() -> Dictionary:
	return file("events_prompts")


## services_llm.json content.
func llm_settings() -> Dictionary:
	return file("services_llm")


static func _index(items: Array) -> Dictionary:
	var out: Dictionary = {}
	for item in items:
		out[item.id] = item
	return out
