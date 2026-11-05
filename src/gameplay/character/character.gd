class_name Character
extends RefCounted
## One cultivator: the player or any NPC. The world database stores people as
## [method to_dict] records, so the player is "just a person" (Dwarf Fortress style)
## and every rule applies to everyone. Design: game-concept.md § Character Stats.
##
## Usage:
## [codeblock]
## var c := Character.new()
## c.name = "Lâm Vô Danh"
## c.thien_phu = {"ngo_tinh": 72, ...}
## c.linh_can = LinhCan.roll(gd, rng)
## var record: Dictionary = c.to_dict()
## var copy := Character.from_dict(record)
## [/codeblock]

# --- Identity -------------------------------------------------------------------
## World-database id ("p12"); empty until registered.
var id: String = ""
var name: String = ""
## "male" or "female".
var gender: String = "male"
## Age in years (fractional; one season = 0.25).
var age: float = 16.0
var alive: bool = true
## Free-text cause of death, empty while alive.
var death_cause: String = ""
## True for the player character.
var is_player: bool = false
## "thien_dinh" (rolled, achievements on) or "tu_dinh" (chosen, casual).
var birth_mode: String = "thien_dinh"
## Origin id from character_attributes.json ("tan_tu", "tong_mon", "gia_toc"), or "" for NPCs.
var origin: String = ""
## Archetype id from world_generation.json ("kiem_tu", ...).
var archetype: String = "tan_tu"
## Personality trait ids.
var traits: Array = []
## True for demon beasts (no sect, no items, no tree).
var is_beast: bool = false

# --- Innate ---------------------------------------------------------------------
## Thiên phú id -> 1..100.
var thien_phu: Dictionary = {}
var linh_can: LinhCan = LinhCan.new()

# --- Cultivation ------------------------------------------------------------------
var realm_index: int = 0
## Stage in the realm: 0 early, 1 middle, 2 late, 3 great perfection. Derived from level for
## the player; NPCs advance it directly and take the stage's first level (Realms rule 12).
var stage: int = 0
## Level 1..300.
var level: int = 1
## Highest level ever reached: points follow it, so no level pays twice.
var level_peak: int = 1
## The bar toward the next level, or the bottleneck bar at great perfection.
var tu_vi: float = 0.0
## Bare attempts used in this realm step.
var bare_attempts: int = 0
## Failed pill attempts in this realm step (failure insight).
var failed_pills: int = 0
## True once this realm step's talisman is used.
var talisman_used: bool = false
## q of each pill attempt made this realm step (Realms Formulas H).
var attempt_log: Array = []
## True once the Deity Transformation breakthrough insight is gained; kept.
var has_insight: bool = false
## Per-realm-step capability use: capability id (string) -> true.
var cap_used: Dictionary = {}
## Extra lifespan from pills and treasures (years).
var lifespan_bonus: float = 0.0
## Current khí huyết as a fraction of max (1.0 = healthy).
var vitality: float = 1.0
## Pill toxicity 0..100.
var dan_doc: float = 0.0
## Heart demon 0..100.
var tam_ma: float = 0.0

# --- Possessions (item ids in the world database) ------------------------------
var linh_thach: int = 0
## Known techniques: key -> {def, layer, mastery, seal_seasons} (see CongPhap).
var techniques: Dictionary = {}
## Technique key in the main slot, or "".
var main_tech: String = ""
## Technique keys in the auxiliary slots ("" = empty).
var aux_tech: Array = ["", ""]
## Technique key in the second main slot (capability #6), or "".
var second_tech: String = ""
## Equipped artifact item ids.
var equipped: Array = []

# --- Meridian tree --------------------------------------------------------------
## Allocated Kinh Mạch Đồ node ids (root included).
var tree_nodes: Array = [0]
var tree_points: int = 0
## Capability ids held (Character Stats rule 16). Only the Meridian Map adds to it.
var capabilities: Array = []
## Hidden cluster ids unsealed in this life.
var unsealed: Array = []
## Hidden cluster ids whose condition the character has discovered (hints).
var discovered: Array = []
## Recorded fills of open clusters: cluster id (string) -> {source}. Canonical once written.
var fills: Dictionary = {}
## Tree display: "silhouette" or "visible" (Meridian Map rule 13).
var tree_visibility: String = "silhouette"
## Open-cluster unseals used per realm index (string).
var open_unseals: Dictionary = {}
## Years the first equipped treasure has been nurtured (capability #3).
var nurture_years: int = 0
## Place ids visited, for Blink Mark (capability #21).
var visited: Array = []
## The year Blink Mark was last used.
var blink_year: int = -1

# --- Skills -----------------------------------------------------------------------
## Đạo nghệ id -> {level, xp}.
var skills: Dictionary = {}
## Recipe id -> times consumed (for limited-use pills).
var pill_uses: Dictionary = {}
## Trận pháp at the động phủ: formation id -> level (see Formations).
var formations: Dictionary = {}
## Owned linh thú (people ids), see BeastKeeper.
var beasts: Array = []
## Thiên mệnh perks (ids in character_edges.json): the player's birth perk, or an NPC's blessing.
var perks: Array = []
## NPC background edge ("" or "rich_family").
var background: String = ""
## NPC breakthrough fate for its current realm: {realm, ok} (see WorldTicker).
var bt_fate: Dictionary = {}
## For a tamed beast: its owner's id ("" = wild), and loyalty 0..100.
var owner_id: String = ""
var loyalty: int = 0

# --- World ------------------------------------------------------------------------
var sect_id: String = ""
## Sect rank: "tong_chu", "truong_lao", "noi_mon", "ngoai_mon", or "".
var sect_rank: String = ""
var location_id: String = ""
## Place id of the player's động phủ (herb field).
var home_id: String = ""
var master_id: String = ""
## Attitude toward the player, -100..100 (NPCs only).
var attitude: int = 0
## Season index of the last conversation with the player (NPCs only).
var last_talk_season: int = -1


## Thiên phú value (base, before tree/item bonuses).
func base_stat(stat_id: String) -> int:
	return int(thien_phu.get(stat_id, 0))


## True if the capability id is held.
func has_capability(capability_id: int) -> bool:
	return capabilities.has(capability_id)


## Adds a capability; a duplicate is ignored. Called only by the Meridian Map's grant.
func grant_capability(capability_id: int) -> void:
	if not capabilities.has(capability_id):
		capabilities.append(capability_id)


## Skill level for an đạo nghệ id (0 if untrained).
func skill_level(skill_id: String) -> int:
	return int(skills.get(skill_id, {}).get("level", 0))


## Adds skill XP and levels up using [param xp_per_level]; returns levels gained.
func add_skill_xp(skill_id: String, xp: float, xp_per_level: float, max_level: int) -> int:
	var s: Dictionary = skills.get(skill_id, {"level": 0, "xp": 0.0})
	var gained: int = 0
	s.xp = float(s.xp) + xp
	while int(s.level) < max_level and float(s.xp) >= xp_per_level * float(int(s.level) + 1):
		s.xp = float(s.xp) - xp_per_level * float(int(s.level) + 1)
		s.level = int(s.level) + 1
		gained += 1
	skills[skill_id] = s
	return gained


## Serializable record (also the people-table row format).
func to_dict() -> Dictionary:
	return {
		"id": id, "name": name, "gender": gender, "age": age, "alive": alive,
		"death_cause": death_cause, "is_player": is_player, "birth_mode": birth_mode,
		"origin": origin, "archetype": archetype, "traits": traits.duplicate(), "is_beast": is_beast,
		"thien_phu": thien_phu.duplicate(), "linh_can": linh_can.to_dict(),
		"realm_index": realm_index, "stage": stage, "level": level, "level_peak": level_peak, "tu_vi": tu_vi,
		"bare_attempts": bare_attempts, "failed_pills": failed_pills, "talisman_used": talisman_used,
		"attempt_log": attempt_log.duplicate(), "has_insight": has_insight, "cap_used": cap_used.duplicate(),
		"lifespan_bonus": lifespan_bonus, "vitality": vitality, "dan_doc": dan_doc, "tam_ma": tam_ma,
		"linh_thach": linh_thach, "techniques": techniques.duplicate(true), "main_tech": main_tech,
		"aux_tech": aux_tech.duplicate(), "second_tech": second_tech, "equipped": equipped.duplicate(),
		"tree_nodes": tree_nodes.duplicate(), "tree_points": tree_points, "capabilities": capabilities.duplicate(),
		"unsealed": unsealed.duplicate(), "discovered": discovered.duplicate(), "fills": fills.duplicate(true),
		"tree_visibility": tree_visibility, "open_unseals": open_unseals.duplicate(),
		"nurture_years": nurture_years, "visited": visited.duplicate(), "blink_year": blink_year,
		"skills": skills.duplicate(true), "pill_uses": pill_uses.duplicate(), "formations": formations.duplicate(),
		"beasts": beasts.duplicate(), "owner_id": owner_id, "loyalty": loyalty,
		"perks": perks.duplicate(), "background": background, "bt_fate": bt_fate.duplicate(),
		"sect_id": sect_id, "sect_rank": sect_rank, "location_id": location_id, "home_id": home_id,
		"master_id": master_id, "attitude": attitude, "last_talk_season": last_talk_season,
	}


## Restores a character from a record. JSON floats are converted back to ints.
static func from_dict(d: Dictionary) -> Character:
	var c := Character.new()
	c.id = str(d.get("id", ""))
	c.name = str(d.get("name", ""))
	c.gender = str(d.get("gender", "male"))
	c.age = float(d.get("age", 16.0))
	c.alive = bool(d.get("alive", true))
	c.death_cause = str(d.get("death_cause", ""))
	c.is_player = bool(d.get("is_player", false))
	c.birth_mode = str(d.get("birth_mode", "thien_dinh"))
	c.origin = str(d.get("origin", ""))
	c.archetype = str(d.get("archetype", "tan_tu"))
	c.traits = Array(d.get("traits", [])).duplicate()
	c.is_beast = bool(d.get("is_beast", false))
	var tp: Dictionary = d.get("thien_phu", {})
	for k in tp.keys():
		c.thien_phu[k] = int(tp[k])
	c.linh_can = LinhCan.from_dict(d.get("linh_can", {}))
	c.realm_index = int(d.get("realm_index", 0))
	c.stage = int(d.get("stage", 0))
	c.level = int(d.get("level", 1))
	c.level_peak = int(d.get("level_peak", c.level))
	c.tu_vi = float(d.get("tu_vi", 0.0))
	c.bare_attempts = int(d.get("bare_attempts", 0))
	c.failed_pills = int(d.get("failed_pills", 0))
	c.talisman_used = bool(d.get("talisman_used", false))
	c.attempt_log = Array(d.get("attempt_log", [])).map(func(x): return float(x))
	c.has_insight = bool(d.get("has_insight", false))
	c.cap_used = d.get("cap_used", {}).duplicate()
	c.lifespan_bonus = float(d.get("lifespan_bonus", 0.0))
	c.vitality = float(d.get("vitality", 1.0))
	c.dan_doc = clampf(float(d.get("dan_doc", 0.0)), 0.0, 100.0)
	c.tam_ma = clampf(float(d.get("tam_ma", 0.0)), 0.0, 100.0)
	c.linh_thach = int(d.get("linh_thach", 0))
	c.techniques = d.get("techniques", {}).duplicate(true)
	for k in c.techniques.keys():
		c.techniques[k]["layer"] = int(c.techniques[k].layer)
	c.main_tech = str(d.get("main_tech", ""))
	c.aux_tech = Array(d.get("aux_tech", ["", ""])).map(func(x): return str(x))
	c.second_tech = str(d.get("second_tech", ""))
	c.equipped = Array(d.get("equipped", [])).duplicate()
	c.tree_nodes = []
	for n in d.get("tree_nodes", [0]):
		c.tree_nodes.append(int(n))
	c.tree_points = int(d.get("tree_points", 0))
	c.capabilities = Array(d.get("capabilities", [])).map(func(x): return int(x))
	c.unsealed = Array(d.get("unsealed", [])).map(func(x): return int(x))
	c.discovered = Array(d.get("discovered", [])).map(func(x): return int(x))
	c.fills = d.get("fills", {}).duplicate(true)
	c.tree_visibility = str(d.get("tree_visibility", "silhouette"))
	c.open_unseals = d.get("open_unseals", {}).duplicate()
	c.nurture_years = int(d.get("nurture_years", 0))
	c.visited = Array(d.get("visited", [])).map(func(x): return str(x))
	c.blink_year = int(d.get("blink_year", -1))
	c.skills = {}
	var sk: Dictionary = d.get("skills", {})
	for k in sk.keys():
		c.skills[k] = {"level": int(sk[k].get("level", 0)), "xp": float(sk[k].get("xp", 0.0))}
	c.pill_uses = {}
	var pu: Dictionary = d.get("pill_uses", {})
	for k in pu.keys():
		c.pill_uses[k] = int(pu[k])
	c.beasts = Array(d.get("beasts", [])).map(func(x): return str(x))
	c.perks = Array(d.get("perks", [])).map(func(x): return str(x))
	c.background = str(d.get("background", ""))
	c.bt_fate = d.get("bt_fate", {}).duplicate()
	c.owner_id = str(d.get("owner_id", ""))
	c.loyalty = int(d.get("loyalty", 0))
	c.formations = {}
	var fm: Dictionary = d.get("formations", {})
	for k in fm.keys():
		c.formations[k] = int(fm[k])
	c.sect_id = str(d.get("sect_id", ""))
	c.sect_rank = str(d.get("sect_rank", ""))
	c.location_id = str(d.get("location_id", ""))
	c.home_id = str(d.get("home_id", ""))
	c.master_id = str(d.get("master_id", ""))
	c.attitude = int(d.get("attitude", 0))
	c.last_talk_season = int(d.get("last_talk_season", -1))
	return c
