class_name DialogueVoice
extends RefCounted
## Deterministic, non-LLM voice selection and token interpolation for NPC Interaction & Dialogue (#30).
## Selects authored Vietnamese lines by [code]verb x result x attitude band x tone x seniority[/code]
## with a 5-step fallback chain ([code]person -> tone:band:seniority -> tone:band -> band -> generic[/code]),
## resolves forms of address (tiền bối / đạo hữu / sư huynh / sư đệ / sư phụ / đồ nhi / ngươi),
## and interpolates tokens with zero leftover placeholders (GDD Rules 16-19, AC-NI-23, AC-NI-24, AC-NI-26).
##
## Usage:
## [codeblock]
## var reply: Dictionary = DialogueVoice.pick_line(gd, db, npc, player, "greet", "accept", {}, seed_val, season_idx)
## print(reply.text)
## [/codeblock]

## Data file id for interaction tuning knobs (attitude bands).
const INTERACTIONS_FILE := "npc_interactions"
## Data file id for the authored dialogue line library.
const LINES_FILE := "npc_dialogue_lines"
## Default tone when an NPC holds no mapped personality trait.
const DEFAULT_TONE := "courteous"
## Age threshold at which senior speakers use elder self-address (lão phu / lão thân).
const ELDER_AGE_MIN := 60
## Realm index at or above which senior speakers use high-realm self-address (bản tọa).
const HIGH_REALM_INDEX := 3

const _VI_CAP_FIRST := {
	"a": "A", "ă": "Ă", "â": "Â", "b": "B", "c": "C", "d": "D", "đ": "Đ",
	"e": "E", "ê": "Ê", "g": "G", "h": "H", "i": "I", "k": "K", "l": "L",
	"m": "M", "n": "N", "o": "O", "ô": "Ô", "ơ": "Ơ", "p": "P", "q": "Q",
	"r": "R", "s": "S", "t": "T", "u": "U", "ư": "Ư", "v": "V", "x": "X", "y": "Y",
}


## Returns the attitude band name ("hostile", "cold", "neutral", "warm", "friendly", or "close")
## for integer [param attitude] using [code]npc_interactions.json["knobs"]["attitude_bands"][/code].
static func attitude_band(gd: GameData, attitude: int) -> String:
	var bands: Array = []
	if gd != null and gd.registry.has_file(INTERACTIONS_FILE):
		bands = Array(Dictionary(gd.file(INTERACTIONS_FILE).get("knobs", {})).get("attitude_bands", []))
	if bands.is_empty():
		bands = [[-100, "hostile"], [-29, "cold"], [-9, "neutral"], [10, "warm"], [30, "friendly"], [60, "close"]]
	var chosen: String = str(bands[0][1])
	for row in bands:
		if row is Array and (row as Array).size() >= 2 and attitude >= int((row as Array)[0]):
			chosen = str((row as Array)[1])
	return chosen


## Returns the speaker's voice tone ("courteous", "blunt", "haughty", "gentle", "sly", "pious", "wild", or "cold")
## from their first held personality trait in catalogue order (GDD Rule 16).
static func tone_of(gd: GameData, npc: Dictionary, raw_lines: Variant = null) -> String:
	var lines_doc: Dictionary = _lines_doc(gd, raw_lines)
	var tone_map: Dictionary = Dictionary(lines_doc.get("tone_by_trait", {}))
	var nt: Dictionary = Dictionary(npc.get("npc_traits", {}))
	var held_raw: Array = Array(nt.get("personality", []))
	if held_raw.is_empty():
		return DEFAULT_TONE
	var held_set := {}
	for h in held_raw:
		var low: String = str(h).strip_edges().to_lower()
		if low != "":
			held_set[low] = true
	if gd != null and gd.registry.has_file(NpcTraits.FILE):
		var traits_doc: Dictionary = gd.file(NpcTraits.FILE)
		for entry in Array(traits_doc.get("personality", [])):
			if not (entry is Dictionary):
				continue
			var tid: String = str(entry.get("id", "")).to_lower()
			var tname: String = str(entry.get("name", "")).to_lower()
			if (tid != "" and held_set.has(tid)) or (tname != "" and held_set.has(tname)):
				if tone_map.has(tid):
					return str(tone_map[tid])
	for h in held_raw:
		var low: String = str(h).strip_edges().to_lower()
		if tone_map.has(low):
			return str(tone_map[low])
	return DEFAULT_TONE


## Returns the speaker's seniority relative to [param player]: "senior", "peer", or "junior".
## Respects master-disciple ties, same-sect rank ladder, and realm gap (GDD Rule 16, AC-NI-24).
static func seniority_of(gd: GameData, db: WorldDB, npc: Dictionary, player: Dictionary) -> String:
	var npc_id: String = str(npc.get("id", ""))
	var player_id: String = str(player.get("id", ""))
	if db != null and npc_id != "" and player_id != "":
		if Ties.master_of(db, player_id) == npc_id:
			return "senior"
		if Ties.master_of(db, npc_id) == player_id:
			return "junior"
	var npc_sect: String = str(npc.get("sect_id", ""))
	var player_sect: String = str(player.get("sect_id", ""))
	if npc_sect != "" and npc_sect == player_sect:
		var ladder: Array = _rank_ladder(gd)
		var nr: int = ladder.find(str(npc.get("sect_rank", "")))
		var pr: int = ladder.find(str(player.get("sect_rank", "")))
		if nr >= 0 and pr >= 0 and nr != pr:
			return "senior" if nr > pr else "junior"
	var delta_r: int = int(npc.get("realm_index", 0)) - int(player.get("realm_index", 0))
	if delta_r > 0:
		return "senior"
	if delta_r < 0:
		return "junior"
	return "peer"


## Resolves the speaker's address forms [code]{"you": String, "self": String}[/code] from
## [code]npc_dialogue_lines.json["address_table"][/code] using attitude, ties, sect rank, tone,
## seniority, gender, and age (GDD Rule 17, AC-NI-24).
static func address_forms(gd: GameData, db: WorldDB, npc: Dictionary, player: Dictionary, band: String, tone: String, seniority: String, raw_lines: Variant = null) -> Dictionary:
	var lines_doc: Dictionary = _lines_doc(gd, raw_lines)
	var tbl: Dictionary = Dictionary(lines_doc.get("address_table", {}))
	var npc_id: String = str(npc.get("id", ""))
	var player_id: String = str(player.get("id", ""))
	var npc_female: bool = _is_female(npc)
	var player_female: bool = _is_female(player)

	if band == "hostile":
		return _plain_pair(tbl.get("hostile_or_haughty", {}), "ngươi", "ta")

	if db != null and npc_id != "" and player_id != "":
		if Ties.master_of(db, player_id) == npc_id:
			return _plain_pair(tbl.get("master_to_disciple", {}), "đồ nhi", "vi sư")
		if Ties.master_of(db, npc_id) == player_id:
			return _plain_pair(tbl.get("disciple_to_master", {}), "sư phụ", "đồ nhi")
		if Ties.has_pin(db, npc_id, player_id, "dao_lu"):
			return _plain_pair(tbl.get("dao_lu", {}), "đạo lữ", "ta")
		if Ties.has_pin(db, npc_id, player_id, "ket_nghia"):
			var elder: bool = seniority == "senior" or (seniority == "peer" and float(npc.get("age", 0)) >= float(player.get("age", 0)))
			var krec: Dictionary = Dictionary(tbl.get("ket_nghia_senior" if elder else "ket_nghia_junior", {}))
			return _gendered_pair(krec, player_female, npc_female, "hiền đệ" if elder else "huynh trưởng", "vi huynh" if elder else "tiểu đệ")

	if tone == "haughty" and seniority != "junior" and band != "close":
		return _plain_pair(tbl.get("hostile_or_haughty", {}), "ngươi", "ta")

	var npc_sect: String = str(npc.get("sect_id", ""))
	var player_sect: String = str(player.get("sect_id", ""))
	if npc_sect != "" and npc_sect == player_sect:
		if seniority == "senior":
			return _gendered_pair(Dictionary(tbl.get("same_sect_senior", {})), player_female, npc_female, "sư đệ", "sư huynh")
		if seniority == "junior":
			return _gendered_pair(Dictionary(tbl.get("same_sect_junior", {})), player_female, npc_female, "sư huynh", "sư đệ")
		return _plain_pair(tbl.get("same_sect_peer", {}), "đồng môn", "tại hạ")

	if seniority == "senior":
		var srec: Dictionary = Dictionary(tbl.get("senior", {}))
		var you_str: String = str(srec.get("you", "tiểu hữu"))
		var self_str: String = str(srec.get("self", "ta"))
		if int(npc.get("realm_index", 0)) >= HIGH_REALM_INDEX:
			self_str = str(srec.get("self_high", "bản tọa"))
		elif float(npc.get("age", 0)) >= float(ELDER_AGE_MIN):
			self_str = str(srec.get("self_f_old", "lão thân")) if npc_female else str(srec.get("self_m_old", "lão phu"))
		return {"you": you_str, "self": self_str}
	if seniority == "junior":
		return _plain_pair(tbl.get("junior", {}), "tiền bối", "vãn bối")
	return _plain_pair(tbl.get("peer", {}), "đạo hữu", "tại hạ")


## Substitutes placeholders from [param subs] into [param template_text]. Accepts keys with or without braces
## (e.g. "{npc}" or "npc") and capitalizes the first character if the sentence begins with an address pronoun.
static func render(template_text: String, subs: Dictionary) -> String:
	var starts_with_pronoun: bool = template_text.begins_with("{you}") or template_text.begins_with("{self}")
	var out: String = template_text
	for k in subs.keys():
		var ks: String = str(k)
		var tok: String = ks if (ks.begins_with("{") and ks.ends_with("}")) else ("{" + ks + "}")
		out = out.replace(tok, str(subs[k]))
	if starts_with_pronoun and out.length() > 0:
		out = _capitalize_start(out)
	return out


## Selects and renders a deterministic authored Vietnamese reply line for [param verb_id] and [param result].
## Uses the 5-step fallback chain: 0=person, 1=tone:band:seniority, 2=tone:band, 3=band, 4=generic.
## Variant index is drawn via [method RngUtils.stable_hash] so reloads always show the identical line (AC-NI-23).
## Returns [code]{text, key, fallback_level, variant, tone, seniority, band, forms}[/code].
static func pick_line(
	gd: GameData,
	db: WorldDB,
	npc: Dictionary,
	player: Dictionary,
	verb_id: String,
	result: String,
	subs: Dictionary = {},
	seed_val: int = 0,
	season_idx: int = 0,
	raw_lines: Variant = null
) -> Dictionary:
	var lines_doc: Dictionary = _lines_doc(gd, raw_lines)
	var band: String = attitude_band(gd, int(npc.get("attitude", 0)))
	var tone: String = tone_of(gd, npc, lines_doc)
	var seniority: String = seniority_of(gd, db, npc, player)
	var forms: Dictionary = address_forms(gd, db, npc, player, band, tone, seniority, lines_doc)

	var variants: Array = []
	var chosen_key: String = ""
	var fallback_level: int = 4

	var cast_key: String = str(npc.get("cast_key", ""))
	if cast_key != "":
		var pl: Dictionary = Dictionary(lines_doc.get("person_lines", {}))
		var p_verb: Dictionary = Dictionary(Dictionary(pl.get(cast_key, {})).get(verb_id, {}))
		var p_res: Variant = p_verb.get(result, [])
		if typeof(p_res) == TYPE_ARRAY and not (p_res as Array).is_empty():
			variants = p_res as Array
			chosen_key = "person:%s" % cast_key
			fallback_level = 0

	if variants.is_empty():
		var res_map: Dictionary = Dictionary(Dictionary(lines_doc.get("lines", {})).get(verb_id, {})).get(result, {})
		var candidates: Array = [
			["%s:%s:%s" % [tone, band, seniority], 1],
			["%s:%s" % [tone, band], 2],
			[band, 3],
			["generic", 4],
		]
		for cand in candidates:
			var k: String = str(cand[0])
			var arr: Variant = res_map.get(k, [])
			if typeof(arr) == TYPE_ARRAY and not (arr as Array).is_empty():
				variants = arr as Array
				chosen_key = k
				fallback_level = int(cand[1])
				break

	var raw_text: String = ""
	var variant_idx: int = 0
	if not variants.is_empty():
		var who_key: String = str(npc.get("id", cast_key))
		var h: int = RngUtils.stable_hash("%d|%d|%s|%s|%s|%s" % [seed_val, season_idx, who_key, verb_id, result, chosen_key])
		variant_idx = posmod(h, variants.size())
		raw_text = str(variants[variant_idx])
	else:
		chosen_key = "fallback_empty"
		raw_text = "%s khẽ gật đầu." % str(npc.get("name", "Đối phương"))

	var full_subs: Dictionary = _default_tokens(gd, db, npc, player, forms)
	for k in subs.keys():
		var ks: String = str(k)
		var tok: String = ks if (ks.begins_with("{") and ks.ends_with("}")) else ("{" + ks + "}")
		full_subs[tok] = str(subs[k])

	return {
		"text": render(raw_text, full_subs),
		"key": chosen_key,
		"fallback_level": fallback_level,
		"variant": variant_idx,
		"tone": tone,
		"seniority": seniority,
		"band": band,
		"forms": forms,
	}


static func _lines_doc(gd: GameData, raw_lines: Variant) -> Dictionary:
	if raw_lines != null and typeof(raw_lines) == TYPE_DICTIONARY:
		return raw_lines as Dictionary
	if gd != null and gd.registry.has_file(LINES_FILE):
		return gd.file(LINES_FILE)
	return {}


static func _rank_ladder(gd: GameData) -> Array:
	if gd != null and gd.registry.has_file("world_generation"):
		var ladder: Array = Array(Dictionary(gd.file("world_generation").get("sects", {})).get("rank_ladder", []))
		if not ladder.is_empty():
			return ladder
	return ["ngoai_mon", "noi_mon", "truong_lao", "tong_chu"]


static func _is_female(person: Dictionary) -> bool:
	var g: String = str(person.get("gender", person.get("sex", "male"))).strip_edges().to_lower()
	return g == "female" or g == "f"


static func _plain_pair(entry: Variant, default_you: String, default_self: String) -> Dictionary:
	var d: Dictionary = entry as Dictionary if typeof(entry) == TYPE_DICTIONARY else {}
	return {"you": str(d.get("you", default_you)), "self": str(d.get("self", default_self))}


static func _gendered_pair(entry: Dictionary, player_female: bool, npc_female: bool, default_you: String, default_self: String) -> Dictionary:
	var you_key: String = "you_f" if player_female else "you_m"
	var self_key: String = "self_f" if npc_female else "self_m"
	return {
		"you": str(entry.get(you_key, entry.get("you", default_you))),
		"self": str(entry.get(self_key, entry.get("self", default_self))),
	}


static func _default_tokens(gd: GameData, db: WorldDB, npc: Dictionary, player: Dictionary, forms: Dictionary) -> Dictionary:
	var realm_str: String = ""
	if gd != null and not gd.realms().is_empty():
		realm_str = gd.realm_label(int(npc.get("realm_index", 0)), int(npc.get("stage", 0)))
	var place_name: String = ""
	var sect_name: String = ""
	var history_line: String = "lặng lẽ tu hành"
	if db != null:
		var loc_id: String = str(npc.get("location_id", player.get("location_id", "")))
		if loc_id != "":
			place_name = str(db.get_record("places", loc_id).get("name", ""))
		var sid: String = str(npc.get("sect_id", ""))
		if sid != "":
			sect_name = str(db.get_record("sects", sid).get("name", ""))
		var nid: String = str(npc.get("id", ""))
		if nid != "":
			var evs: Array = db.events_of(nid)
			if not evs.is_empty():
				history_line = str(evs[-1].get("text", history_line)).trim_suffix(".")
	if place_name == "":
		place_name = "nơi này"
	if sect_name == "":
		sect_name = "tán tu"
	return {
		"{you}": str(forms.get("you", "đạo hữu")),
		"{self}": str(forms.get("self", "tại hạ")),
		"{npc}": str(npc.get("name", "Đối phương")),
		"{player}": str(player.get("name", "Tu sĩ")),
		"{realm}": realm_str if realm_str != "" else "Luyện Khí",
		"{place}": place_name,
		"{sect}": sect_name,
		"{history}": history_line,
		"{rumour}": "một vài tin tức gần đây",
		"{target}": "người ấy",
		"{item}": "món đồ này",
		"{amount}": "0",
		"{lesson}": "một đoạn tâm đắc",
	}


static func _capitalize_start(s: String) -> String:
	if s.is_empty():
		return s
	var ch: String = s.substr(0, 1)
	if _VI_CAP_FIRST.has(ch):
		return str(_VI_CAP_FIRST[ch]) + s.substr(1)
	return s
