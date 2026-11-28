class_name Achievements
extends RefCounted
## Thành tựu: conditions over the player's state (meta_achievements.json), earned only
## in Thiên Định lives and remembered across lives by an injected store. Pure rules here;
## persistence lives in [AchievementStore]. Spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md.
##
## Usage:
## [codeblock]
## var book := Achievements.new(gd, AchievementStore.new("user://achievements.json"))
## for a in book.check(session):          # newly earned this call
##     print("★ %s — %s" % [a.name, a.desc])
## [/codeblock]

var _gd: GameData
var store: AchievementStore


func _init(gd: GameData, achievement_store: AchievementStore) -> void:
	_gd = gd
	store = achievement_store


## Every achievement definition.
func all() -> Array:
	return _gd.file("meta_achievements").get("achievements", [])


## True when this life can earn achievements (Thiên Định birth).
static func enabled_for(c: Character) -> bool:
	return c != null and c.birth_mode == "thien_dinh"


## True when a session is eligible for `one_life` prestige achievements (codex-karmic-carryover.md
## Rule 11, AC-CK-21): requires One Life playthrough mode and `death_reloaded == false`.
## Reads `playthrough_mode` and `death_reloaded` from [param s] (property or metadata) unless
## explicitly overridden.
static func one_life_eligible(s: GameSession, mode_override: String = "", death_reloaded_override: Variant = null) -> bool:
	if s == null:
		return false
	var mode: String = mode_override
	if mode == "":
		var raw_mode: Variant = s.get("playthrough_mode")
		if raw_mode != null and str(raw_mode) != "":
			mode = str(raw_mode)
		elif s.has_meta("playthrough_mode"):
			mode = str(s.get_meta("playthrough_mode"))
		else:
			mode = "one_life"
	var reloaded: bool = false
	if death_reloaded_override != null:
		reloaded = bool(death_reloaded_override)
	else:
		var raw_reloaded: Variant = s.get("death_reloaded")
		if raw_reloaded != null:
			reloaded = bool(raw_reloaded)
		elif s.has_meta("death_reloaded"):
			reloaded = bool(s.get_meta("death_reloaded"))
	return mode == "one_life" and not reloaded


## Rule 11 (AC-CK-21): returns true when loading a One Life save whose [param playthrough_id]
## already has a Lives death entry in [param codex_store], requiring the save to be marked
## `death_reloaded`.
static func should_mark_death_reloaded(playthrough_mode: String, playthrough_id: String, codex_store: CodexStore) -> bool:
	if playthrough_mode != "one_life" or playthrough_id == "" or codex_store == null:
		return false
	return codex_store.has_life_for_playthrough(playthrough_id)


## Evaluates every unearned achievement; records and returns the newly earned ones.
## Achievements tagged `"one_life": true` are skipped in Continue mode or when `death_reloaded`
## is set (Rule 11, AC-CK-21). Optional overrides allow isolated testing before session fields exist.
func check(s: GameSession, playthrough_mode: String = "", death_reloaded: Variant = null) -> Array:
	if s == null or s.player == null or not enabled_for(s.player) or s.cheated:
		return []
	var can_one_life: bool = one_life_eligible(s, playthrough_mode, death_reloaded)
	var fresh: Array = []
	for a in all():
		if bool(a.get("one_life", false)) and not can_one_life:
			continue
		if store.has(str(a.id)):
			continue
		if met(s, a.condition):
			store.earn(str(a.id), {"life": s.player.name, "year": s.year, "age": int(s.player.age)})
			fresh.append(a)
	if not fresh.is_empty():
		store.save()
	return fresh


## Whether a condition holds for the session's player now.
func met(s: GameSession, cond: Dictionary) -> bool:
	var c: Character = s.player
	match str(cond.get("type", "")):
		"realm":
			var target: int = _gd.realm_index(str(cond.realm))
			if c.realm_index < target:
				return false
			var reached_age: float = _age_reached(s, target)
			if cond.has("max_age") and reached_age > float(cond.max_age):
				return false
			if cond.has("origin") and c.origin != str(cond.origin):
				return false
			if cond.has("min_elements") and c.linh_can.base_count() < int(cond.min_elements):
				return false
			return true
		"skill":
			return c.skill_level(str(cond.skill)) >= int(cond.level)
		"formation":
			return c.formations.values().any(func(lv): return int(lv) >= int(cond.level))
		"beasts":
			return c.beasts.size() >= int(cond.count)
		"bien_di":
			return c.linh_can.variants.size() >= int(cond.count)
		"age":
			return c.age >= float(cond.age)
		"event":
			return s.db.events_of(c.id).any(func(e): return str(e.type) == str(cond.event))
	return false


## Age at which the player entered realm [param realm_idx] (current age if not logged).
func _age_reached(s: GameSession, realm_idx: int) -> float:
	var c: Character = s.player
	if realm_idx <= 0:
		return 0.0
	var realm_name: String = str(_gd.realm(realm_idx).name)
	for e in s.db.events_of(c.id):
		if str(e.type) == "player_breakthrough" and str(e.get("data", {}).get("refs", {}).get("realm", "")) == realm_name:
			return c.age - float(s.year - int(e.year))
	return c.age
