class_name CongPhap
extends RefCounted
## Cultivation techniques on a character: learning, slots, mastery, speed, power, bonuses and
## harmony. A technique is a definition (authored template or generated common) carried by a
## manual item; knowing it is per character and survives losing the manual.
## Design: design/gdd/cong-phap.md. Data: items_cong_phap.json.
##
## A character's [member Character.techniques] maps a technique key to
## {def, layer, mastery, seal_seasons}. def is {tech_id, name, tier, kind, names, layers,
## bonuses, abilities, seal_clusters, origin}. kind is "main", "secret" or "body".
##
## Usage:
## [codeblock]
## CongPhap.learn(c, manual)
## var r: Dictionary = CongPhap.set_slot(c, gd, "main", 0, manual.tech_id)
## var f: Dictionary = CongPhap.speed_factor(c, gd)     # {mult, label}
## CongPhap.season_tick(c, gd, sheet.effective("ngo_tinh", c), true)
## [/codeblock]


## The tier record of a definition.
static func tier_of(gd: GameData, def: Dictionary) -> Dictionary:
	return gd.cong_phap_tier(int(def.tier))


## Rule 4: teaches the technique of a manual at layer 1. Returns false if already known.
static func learn(c: Character, manual: Dictionary) -> bool:
	var key: String = str(manual.tech_id)
	if c.techniques.has(key):
		return false
	var def: Dictionary = {}
	for k in ["tech_id", "name", "tier", "tech_kind", "names", "layers", "bonuses", "abilities", "seal_clusters", "origin"]:
		def[k] = manual.get(k)
	c.techniques[key] = {"def": def, "layer": 1, "mastery": 0.0, "seal_seasons": 0}
	return true


## Rule 8: usable only if the root has every named id. Body techniques always are.
static func usable(c: Character, def: Dictionary) -> bool:
	for id in def.get("names", []):
		if not c.linh_can.has(str(id)):
			return false
	return true


## The technique entry in the main slot, or {} if the slot is empty or unusable.
static func main_entry(c: Character) -> Dictionary:
	var e: Dictionary = c.techniques.get(c.main_tech, {})
	if e.is_empty() or not usable(c, e.def):
		return {}
	return e


## Every slotted technique key, main first ("" slots skipped). The #6 slot counts only with a
## usable main method.
static func slotted(c: Character) -> Array:
	var out: Array = []
	if c.main_tech != "":
		out.append(c.main_tech)
	if c.second_tech != "" and not main_entry(c).is_empty():
		out.append(c.second_tech)
	for k in c.aux_tech:
		if str(k) != "":
			out.append(str(k))
	return out


## Puts a known technique into a slot, or empties it with key "". [param slot] is "main",
## "second" or "aux" with [param index]. A #6 method moved to an empty main slot leaves the #6
## slot empty (rule 6). Returns {ok, reason}.
static func set_slot(c: Character, gd: GameData, slot: String, index: int, key: String) -> Dictionary:
	var moving_up: bool = false
	if key != "":
		var e: Dictionary = c.techniques.get(key, {})
		if e.is_empty():
			return {"ok": false, "reason": "You do not know that technique."}
		if not usable(c, e.def):
			return {"ok": false, "reason": "Your root lacks what %s names." % e.def.name}
		var is_main: bool = str(e.def.tech_kind) == "main"
		if (slot == "aux" and is_main) or (slot != "aux" and not is_main):
			return {"ok": false, "reason": "%s does not fit that slot." % e.def.name}
		moving_up = slot == "main" and c.second_tech == key and main_entry(c).is_empty()
		if _held(c, key) and not _in_slot(c, slot, index, key) and not moving_up:
			return {"ok": false, "reason": "%s is already in a slot." % e.def.name}
	match slot:
		"main":
			c.main_tech = key
			if moving_up:
				c.second_tech = ""
		"second":
			if not c.has_capability(int(gd.cong_phap_file().second_main_capability)):
				return {"ok": false, "reason": "You have no second main slot."}
			c.second_tech = key
		"aux":
			if index < 0 or index >= c.aux_tech.size():
				return {"ok": false, "reason": "There are %d auxiliary slots." % c.aux_tech.size()}
			c.aux_tech[index] = key
		_:
			return {"ok": false, "reason": "Unknown slot %s." % slot}
	return {"ok": true, "reason": ""}


## True if the technique sits in any slot, including an inert #6 slot.
static func _held(c: Character, key: String) -> bool:
	return c.main_tech == key or c.second_tech == key or c.aux_tech.has(key)


static func _in_slot(c: Character, slot: String, index: int, key: String) -> bool:
	match slot:
		"main":
			return c.main_tech == key
		"second":
			return c.second_tech == key
	return index >= 0 and index < c.aux_tech.size() and str(c.aux_tech[index]) == key


## Average purity of a definition's named ids; 0 for a body technique.
static func avg_purity(c: Character, def: Dictionary) -> float:
	return c.linh_can.average_purity(def.get("names", []))


## The lowest tier rank whose max realm is at or above the realm index.
static func par_tier(gd: GameData, realm_idx: int) -> int:
	for t in gd.cong_phap_file().tiers:
		if gd.realm_index(str(t.max_realm)) >= realm_idx:
			return int(t.rank)
	return 3


## g: the element-count gain, divided out of the normaliser (Formulas A).
static func count_gain(c: Character, gd: GameData) -> float:
	var cfg: Dictionary = gd.cong_phap_file()
	var n: int = maxi(c.linh_can.base_count(), 1)
	if n == 5 and c.realm_index == 0:
		return float(cfg.count_gain_qr_5)
	return float(cfg.count_gain[n - 1])


## Formulas A: tech_one for an entry, before the crude floor.
static func tech_one(c: Character, gd: GameData, entry: Dictionary) -> float:
	var cfg: Dictionary = gd.cong_phap_file()
	var def: Dictionary = entry.def
	var tier: Dictionary = tier_of(gd, def)
	var r: int = c.realm_index + 1
	var max_r: int = gd.realm_index(str(tier.max_realm)) + 1
	var cap: int = mini(3 * r, int(def.layers))
	var d: int = maxi(0, cap - int(entry.layer))
	var l: float = maxf(float(cfg.layer_speed_floor), 1.0 - float(cfg.layer_speed_penalty) * float(d))
	var edge: float = 1.0
	var beyond: float = 1.0
	if r <= max_r:
		edge = float(tier.speed_mult) / float(gd.cong_phap_tier(par_tier(gd, c.realm_index)).speed_mult)
	else:
		beyond = float(cfg.beyond_realm_mult)
	var match_v: float = avg_purity(c, def) / 100.0
	return float(cfg.tech_norm) / count_gain(c, gd) * edge * match_v * l * beyond


## The crude factor: no_cong_phap_mult x strongest base purity / 100.
static func crude(c: Character, gd: GameData) -> float:
	var best: float = c.linh_can.purity(c.linh_can.strongest_element())
	return float(gd.cultivation_rules().no_cong_phap_mult) * maxf(best, 1.0) / 100.0


## The tech term of the cultivation rate, as {mult, label}.
static func speed_factor(c: Character, gd: GameData) -> Dictionary:
	var floor_v: float = crude(c, gd)
	var e: Dictionary = main_entry(c)
	if e.is_empty():
		return {"mult": floor_v, "label": "No main method (crude)"}
	var one: float = tech_one(c, gd, e)
	var label: String = "%s (layer %d/%d)" % [e.def.name, int(e.layer), int(e.def.layers)]
	if c.realm_index > gd.realm_index(str(tier_of(gd, e.def).max_realm)):
		label += " [beyond its realm]"
	var mult: float = one
	if one < floor_v:
		mult = floor_v
		label += " [crude floor]"
	var second: Dictionary = c.techniques.get(c.second_tech, {})
	if not second.is_empty() and usable(c, second.def):
		mult += float(gd.cong_phap_file().second_main_mult) * tech_one(c, gd, second)
		label += " + %s" % second.def.name
	return {"mult": mult, "label": label}


## Formulas C: tech_power, read by spiritual power and Combat.
static func tech_power(c: Character, gd: GameData) -> float:
	var cfg: Dictionary = gd.cong_phap_file()
	var e: Dictionary = main_entry(c)
	if e.is_empty():
		return float(cfg.no_tech_power)
	var p_floor: float = float(cfg.power_layer_floor)
	var depth: float = float(int(e.layer) - 1) / float(int(e.def.layers) - 1)
	return float(tier_of(gd, e.def).power_mult) * (p_floor + (1.0 - p_floor) * depth)


## The base elements a name counts as for harmony: itself, a derived variant's required
## elements, or none for an innate variant.
static func harmony_elements(gd: GameData, id: String) -> Array:
	if not gd.element(id).is_empty():
		return [id]
	return gd.variant(id).get("requires", [])


## H for an auxiliary art under a main method's names (rule 12): the worst relation over every
## pair. No main method, a body technique or only innate variants give neutral.
static func harmony(gd: GameData, art_names: Array, main_names: Array) -> float:
	var cfg: Dictionary = gd.cong_phap_file().harmony
	var cycle: Array = gd.element_cycle()
	var worst: float = INF
	for a_id in art_names:
		for m_id in main_names:
			for a in harmony_elements(gd, str(a_id)):
				for m in harmony_elements(gd, str(m_id)):
					var d: int = posmod(cycle.find(a) - cycle.find(m), cycle.size())
					var h: float = float(cfg.neutral)
					if d == 1:
						h = float(cfg.main_generates)
					elif d == 2 or d == 3:
						h = float(cfg.overcoming)
					worst = minf(worst, h)
	return float(cfg.neutral) if worst == INF else worst


## Formulas D: every slotted usable technique's bonuses, as {source, stat, value}.
## [param physique] is effective căn cốt for body techniques.
static func bonus_lines(c: Character, gd: GameData, physique: float) -> Array:
	var cfg: Dictionary = gd.cong_phap_file()
	var out: Array = []
	var main: Dictionary = main_entry(c)
	var main_names: Array = main.def.get("names", []) if not main.is_empty() else []
	for key in slotted(c):
		var e: Dictionary = c.techniques.get(key, {})
		if e.is_empty() or not usable(c, e.def):
			continue
		var def: Dictionary = e.def
		var is_body: bool = str(def.tech_kind) == "body"
		var depth: float = float(int(e.layer) - 1) / float(int(def.layers) - 1)
		var b: float = float(cfg.bonus_layer_floor) + (1.0 - float(cfg.bonus_layer_floor)) * depth
		var f: float = minf(float(cfg.body_factor_cap), 0.5 + physique / 100.0) if is_body else 0.5 + avg_purity(c, def) / 100.0
		var h: float = 1.0
		if str(def.tech_kind) == "secret":
			h = harmony(gd, def.get("names", []), main_names)
		for bonus in def.get("bonuses", []):
			out.append({"source": "Công pháp: %s" % def.name, "stat": str(bonus.stat), "value": float(bonus.value) * b * f * h})
	return out


## Formulas B: the cost of mastering layer [param k] of a definition at the current realm.
static func layer_cost(gd: GameData, def: Dictionary, k: int, realm_idx: int) -> float:
	var cfg: Dictionary = gd.cong_phap_file()
	var layer_realm: int = (k + 2) / 3
	var j: int = (k - 1) % 3
	var cost: float = float(cfg.trio_cost[layer_realm - 1]) * float(cfg.layer_weights[j]) * float(tier_of(gd, def).layer_cost_mult)
	if layer_realm < realm_idx + 1:
		cost *= float(cfg.catchup_mult)
	return cost


## True if layer [param k] needs a higher realm than the character holds (rule 5).
static func gated(c: Character, k: int) -> bool:
	return (k + 2) / 3 > c.realm_index + 1


## Formulas B: one season's gain. [param cultivating] is true in a cultivation season.
static func mastery_gain(gd: GameData, comp: float, cultivating: bool, slot_frac: float = 1.0) -> float:
	var cfg: Dictionary = gd.cong_phap_file()
	var act: float = 1.0 if cultivating else float(cfg.mastery_idle_frac)
	return float(cfg.mastery_base) * (1.0 + comp / float(cfg.mastery_comp_divisor)) * act * slot_frac


## Adds [param gain] to one entry's stored mastery and masters every affordable ungated layer.
## Returns the layers gained.
static func add_mastery(c: Character, gd: GameData, entry: Dictionary, gain: float) -> int:
	var layers: int = int(entry.def.layers)
	var gained: int = 0
	if int(entry.layer) >= layers:
		entry.mastery = 0.0
		return 0
	entry.mastery = float(entry.mastery) + gain
	while int(entry.layer) < layers:
		var next: int = int(entry.layer) + 1
		var cost: float = layer_cost(gd, entry.def, next, c.realm_index)
		if gated(c, next):
			entry.mastery = minf(float(entry.mastery), cost)
			break
		if float(entry.mastery) + 1e-6 < cost:
			break
		entry.mastery = maxf(float(entry.mastery) - cost, 0.0)
		entry.layer = next
		gained += 1
	if int(entry.layer) >= layers:
		entry.mastery = 0.0
	return gained


## One season of mastery for every slotted technique, plus the seal season count of the main
## method (rule 15). Returns the names of techniques that gained a layer.
static func season_tick(c: Character, gd: GameData, comp: float, cultivating: bool) -> Array:
	var cfg: Dictionary = gd.cong_phap_file()
	var advanced: Array = []
	if not c.main_tech.is_empty() and main_entry(c).is_empty():
		c.main_tech = ""
	for i in c.aux_tech.size():
		var aux: Dictionary = c.techniques.get(str(c.aux_tech[i]), {})
		if not aux.is_empty() and not usable(c, aux.def):
			c.aux_tech[i] = ""
	for key in slotted(c):
		var e: Dictionary = c.techniques.get(key, {})
		if e.is_empty():
			continue
		var frac: float = float(cfg.second_main_mastery) if key == c.second_tech else 1.0
		if add_mastery(c, gd, e, mastery_gain(gd, comp, cultivating, frac)) > 0:
			advanced.append("%s reaches layer %d" % [e.def.name, int(e.layer)])
	if cultivating and not main_entry(c).is_empty():
		var main: Dictionary = main_entry(c)
		main.seal_seasons = int(main.get("seal_seasons", 0)) + 1
	return advanced


## Abilities unlocked now (rule 13): {ability_id, technique}.
static func unlocked_abilities(c: Character) -> Array:
	var out: Array = []
	for key in slotted(c):
		var e: Dictionary = c.techniques.get(key, {})
		if e.is_empty():
			continue
		for a in e.def.get("abilities", []):
			if int(e.layer) >= int(a.unlock_layer):
				out.append({"ability_id": str(a.ability_id), "technique": str(e.def.name)})
	return out


## Old saves: turns a record's single active manual into a known, slotted main method at
## the layers its realm allows.
static func migrate_record(rec: Dictionary, db: WorldDB, gd: GameData) -> Dictionary:
	if rec.has("techniques"):
		return rec
	rec["techniques"] = {}
	rec["main_tech"] = ""
	var item: Dictionary = db.get_record("items", str(rec.get("cong_phap_id", "")))
	if item.is_empty():
		return rec
	var tier: Dictionary = gd.cong_phap_tier(int(item.get("tier", 0)))
	var key: String = str(item.id)
	item["tech_id"] = key
	item["tech_kind"] = "main"
	item["names"] = item.get("elements", [])
	item["layers"] = int(tier.layers)
	item["abilities"] = []
	item["seal_clusters"] = []
	item["origin"] = "generated"
	var def: Dictionary = {}
	for k in ["tech_id", "name", "tier", "tech_kind", "names", "layers", "bonuses", "abilities", "seal_clusters", "origin"]:
		def[k] = item.get(k)
	var layer: int = mini(3 * (int(rec.get("realm_index", 0)) + 1), int(tier.layers))
	rec.techniques[key] = {"def": def, "layer": layer, "mastery": 0.0, "seal_seasons": 0}
	rec["main_tech"] = key
	return rec
