class_name StateSnapshot
extends RefCounted
## Captures the player-facing numbers of a [GameSession] so a frontend can show what an
## action changed ("Tu vi 14 → 28 · Linh thạch 44 → 39 · gained Trúc Cơ Đan").
## Read-only and cheap: a handful of fields plus the player's item names.
##
## Usage:
## [codeblock]
## var before: Dictionary = StateSnapshot.take(session)
## session.cultivate(4)
## for ch in StateSnapshot.diff(before, StateSnapshot.take(session), session.gd):
##     print(ch.text)
## [/codeblock]


## Snapshot of the player's state, or {} when no life is in progress.
static func take(s: GameSession) -> Dictionary:
	if s == null or s.player == null:
		return {}
	var c: Character = s.player
	var sh: StatSheet = s.sheet()
	var items: Dictionary = {}
	for it in s.db.items_of(c.id):
		if it.kind == "herb" and int(it.get("plot", -1)) >= 0:
			continue
		items[it.id] = {"name": str(it.name), "qty": int(it.get("qty", 1))}
	var skills: Dictionary = {}
	for k in c.skills.keys():
		skills[k] = c.skill_level(k)
	return {
		"year": s.year, "season": s.season,
		"realm_index": c.realm_index, "stage": c.stage, "realm_label": s.gd.realm_label(c.realm_index, c.stage),
		"tu_vi": c.tu_vi, "age": c.age, "lifespan": CultivationRules.lifespan(c, s.gd, sh).total,
		"linh_thach": c.linh_thach, "vitality": c.vitality, "dan_doc": c.dan_doc, "tam_ma": c.tam_ma,
		"tree_points": c.tree_points, "tree_nodes": c.tree_nodes.size(),
		"power": CombatPower.compute(c, s.gd, s.db, sh).total, "location_id": c.location_id,
		"location": str(s.db.get_record("places", c.location_id).get("name", "")),
		"items": items, "skills": skills, "alive": c.alive,
	}


## Changes from [param a] to [param b]: [{key, from, to, text}], in reading order.
static func diff(a: Dictionary, b: Dictionary, gd: GameData) -> Array:
	var out: Array = []
	if a.is_empty() or b.is_empty():
		return out
	if int(b.year) != int(a.year) or int(b.season) != int(a.season):
		var seasons: int = (int(b.year) - int(a.year)) * int(gd.cultivation_rules().seasons_per_year) + int(b.season) - int(a.season)
		out.append(_c("time", seasons, seasons, "%s passed" % _duration(seasons, gd)))
	if int(b.realm_index) != int(a.realm_index) or int(b.stage) != int(a.stage):
		out.append(_c("realm", a.realm_label, b.realm_label, "%s → %s" % [a.realm_label, b.realm_label]))
	elif _moved(a.tu_vi, b.tu_vi):
		out.append(_num("tu_vi", "Tu vi", float(a.tu_vi), float(b.tu_vi)))
	if _moved(a.lifespan, b.lifespan):
		out.append(_num("lifespan", "Thọ nguyên", float(a.lifespan), float(b.lifespan)))
	if int(b.linh_thach) != int(a.linh_thach):
		out.append(_num("linh_thach", "Linh thạch", float(a.linh_thach), float(b.linh_thach)))
	if _moved(float(a.vitality) * 100.0, float(b.vitality) * 100.0):
		out.append(_c("vitality", a.vitality, b.vitality, "Khí huyết %d%% → %d%%" % [int(roundf(float(a.vitality) * 100.0)), int(roundf(float(b.vitality) * 100.0))]))
	for k in [["dan_doc", "Đan độc"], ["tam_ma", "Tâm ma"]]:
		if _moved(a[k[0]], b[k[0]]):
			out.append(_num(k[0], k[1], float(a[k[0]]), float(b[k[0]])))
	if int(b.tree_points) != int(a.tree_points):
		out.append(_num("tree_points", "Kinh Mạch points", float(a.tree_points), float(b.tree_points)))
	if int(b.tree_nodes) != int(a.tree_nodes):
		out.append(_num("tree_nodes", "Open huyệt", float(a.tree_nodes), float(b.tree_nodes)))
	if _moved(a.power, b.power):
		out.append(_num("power", "Chiến lực", float(a.power), float(b.power)))
	if str(b.location_id) != str(a.location_id):
		out.append(_c("location", a.location, b.location, "%s → %s" % [a.location, b.location]))
	for k in b.skills.keys():
		if int(b.skills[k]) != int(a.skills.get(k, 0)):
			out.append(_c("skill_" + str(k), a.skills.get(k, 0), b.skills[k], "%s level %d → %d" % [k, int(a.skills.get(k, 0)), int(b.skills[k])]))
	var gained: PackedStringArray = []
	var lost: PackedStringArray = []
	for id in b.items.keys():
		var before: int = int(a.items[id].qty) if a.items.has(id) else 0
		if int(b.items[id].qty) > before:
			gained.append(_item_text(b.items[id].name, int(b.items[id].qty) - before))
		elif int(b.items[id].qty) < before:
			lost.append(_item_text(b.items[id].name, before - int(b.items[id].qty)))
	for id in a.items.keys():
		if not b.items.has(id):
			lost.append(_item_text(a.items[id].name, int(a.items[id].qty)))
	if not gained.is_empty():
		out.append(_c("items_gained", "", "", "+ " + ", ".join(gained)))
	if not lost.is_empty():
		out.append(_c("items_lost", "", "", "− " + ", ".join(lost)))
	if bool(a.alive) and not bool(b.alive):
		out.append(_c("alive", true, false, "DEATH"))
	return out


## True when the value changed as displayed (rounded to whole numbers).
static func _moved(from: Variant, to: Variant) -> bool:
	return roundi(float(from)) != roundi(float(to))


static func _duration(seasons: int, gd: GameData) -> String:
	var per_year: int = int(gd.cultivation_rules().seasons_per_year)
	if seasons % per_year == 0:
		return "%d year%s" % [seasons / per_year, "" if seasons / per_year == 1 else "s"]
	if seasons < per_year:
		return "%d season%s" % [seasons, "" if seasons == 1 else "s"]
	return "%.2f years" % (float(seasons) / float(per_year))


static func _item_text(item_name: String, qty: int) -> String:
	return item_name if qty == 1 else "%s ×%d" % [item_name, qty]


static func _num(key: String, label: String, from: float, to: float) -> Dictionary:
	return _c(key, from, to, "%s %s → %s (%+d)" % [label, _fmt(from), _fmt(to), roundi(to) - roundi(from)])


static func _fmt(v: float) -> String:
	return str(int(roundf(v)))


static func _c(key: String, from: Variant, to: Variant, text: String) -> Dictionary:
	return {"key": key, "from": from, "to": to, "text": text}
