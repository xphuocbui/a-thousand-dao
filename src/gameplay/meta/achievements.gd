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


## Evaluates every unearned achievement; records and returns the newly earned ones.
func check(s: GameSession) -> Array:
	if s == null or s.player == null or not enabled_for(s.player) or s.cheated:
		return []
	var fresh: Array = []
	for a in all():
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
			return c.linh_can.bien_di.size() >= int(cond.count)
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
