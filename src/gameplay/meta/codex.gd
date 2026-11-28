class_name Codex
extends RefCounted
## Pure domain rules for the 10-book Codex (Thiên Thư) over [GameData] and [CodexStore].
## Design: design/gdd/codex-karmic-carryover.md (Rules 7-10; Edge Cases; AC-CK-12..16).
##
## Holds no back-reference to [GameSession] and never reads [WorldDB] or `w_meta.ledger`,
## structurally guaranteeing that per-game hidden place rolls are never leaked (AC-CK-14).
##
## Usage:
## [codeblock]
## var codex := Codex.new(gd, CodexStore.new())
## var newly_known: bool = codex.record(Codex.BOOK_RECIPES, "tu_khi_dan", CodexStore.LEVEL_KNOWN, player, false, 1205)
## var candidates: Array = codex.hidden_place_candidates("R-1")
## [/codeblock]

const CONFIG_FILE := "meta_codex"
const BOOK_RECIPES := "recipes"
const BOOK_VARIANTS := "variants"
const BOOK_SECRETS := "secrets"
const BOOK_CAST := "cast"
const BOOK_HISTORY := "history"
const BOOK_TECHNIQUES := "techniques"
const BOOK_ITEMS := "items"
const BOOK_BEASTS := "beasts"
const BOOK_HERBS := "herbs"
const BOOK_LIVES := "lives"

const ALL_BOOKS: Array[String] = [
	BOOK_RECIPES,
	BOOK_VARIANTS,
	BOOK_SECRETS,
	BOOK_CAST,
	BOOK_HISTORY,
	BOOK_TECHNIQUES,
	BOOK_ITEMS,
	BOOK_BEASTS,
	BOOK_HERBS,
	BOOK_LIVES,
]

var _gd: GameData
## Backing profile store (defaults to pure in-memory when omitted).
var store: CodexStore


func _init(gd: GameData, codex_store: CodexStore = null) -> void:
	_gd = gd
	store = codex_store if codex_store != null else CodexStore.new()


## All 10 book metadata definitions from `meta_codex.json`.
func books_meta() -> Array:
	return _gd.file(CONFIG_FILE).get("books", [])


## Book metadata dictionary for [param book_id], or {}.
func book_meta(book_id: String) -> Dictionary:
	for b in books_meta():
		if str(b.get("id", "")) == book_id:
			return b
	return {}


## Rule 9 writing gate: only Fated-birth (`thien_dinh`) lives that are not `cheated` write
## knowledge entries to the Codex (AC-CK-12).
static func can_write(c: Character, cheated: bool) -> bool:
	return c != null and c.birth_mode == "thien_dinh" and not cheated


## Records a seen or known discovery in [param book] for [param entry_id].
## Returns true iff this call raised [param entry_id] to "known" for the first time on the
## profile in a karma-counted book (used to increment `k_new_this_life`).
## No-op (returns false) for Self-made or cheated lives (Rule 9, AC-CK-12).
func record(book: String, entry_id: String, level: String, c: Character, cheated: bool, year: int) -> bool:
	if book == "" or book == BOOK_LIVES or entry_id == "":
		return false
	if not can_write(c, cheated):
		return false
	var res: Dictionary = store.promote(book, entry_id, level, {"year": year, "life": c.name})
	if not bool(res.get("newly_known", false)):
		return false
	var meta: Dictionary = book_meta(book)
	return bool(meta.get("counts_for_karma", true))


## Records a fixed-cast member's fate from the current life (gated by Rule 9).
func record_cast_fate(cast_key: String, fate_entry: Dictionary, c: Character, cheated: bool) -> bool:
	if cast_key == "" or not can_write(c, cheated):
		return false
	return store.add_cast_fate(cast_key, fate_entry)


## Writes a Lives chronicle entry on death. Always writes regardless of birth mode, `cheated`,
## or playthrough mode (Rule 9, AC-CK-12).
func record_life(s: GameSession, cause: String, mode_override: String = "", playthrough_id_override: String = "") -> Dictionary:
	if s == null or s.player == null:
		return {}
	var c: Character = s.player
	var pid: String = playthrough_id_override
	if pid == "":
		var raw_pid: Variant = s.get("playthrough_id")
		if raw_pid != null and str(raw_pid) != "":
			pid = str(raw_pid)
		elif s.has_meta("playthrough_id"):
			pid = str(s.get_meta("playthrough_id"))
	var pmode: String = mode_override
	if pmode == "":
		var raw_mode: Variant = s.get("playthrough_mode")
		if raw_mode != null and str(raw_mode) != "":
			pmode = str(raw_mode)
		elif s.has_meta("playthrough_mode"):
			pmode = str(s.get_meta("playthrough_mode"))
		else:
			pmode = "one_life"
	var summary_parts: PackedStringArray = PackedStringArray()
	if s.db != null and c.id != "":
		var evs: Array = s.db.events_of(c.id)
		var tail: Array = evs.slice(maxi(0, evs.size() - 5))
		for e in tail:
			var t: String = str(Dictionary(e).get("text", "")).strip_edges()
			if t != "":
				summary_parts.append(t)
	var rec := {
		"playthrough_id": pid,
		"mode": pmode,
		"name": c.name,
		"gender": c.gender,
		"origin": c.origin,
		"birth_mode": c.birth_mode,
		"realm_index": c.realm_index,
		"realm_label": _gd.realm_label(c.realm_index, c.stage),
		"age": c.age,
		"year": s.year,
		"cause": cause,
		"epitaph": s.epitaph_text,
		"chronicle_summary": "\n".join(summary_parts),
		"cheated": s.cheated,
	}
	store.add_life(rec)
	return rec


## Writes a pre-built Lives record directly to the store (always writes, Rule 9).
func record_life_data(life_rec: Dictionary) -> Dictionary:
	var rec: Dictionary = life_rec.duplicate(true)
	store.add_life(rec)
	return rec


## True if [param entry_id] in [param book] is at least "seen".
func is_seen(book: String, entry_id: String) -> bool:
	var lv: String = store.level_of(book, entry_id)
	return lv == CodexStore.LEVEL_SEEN or lv == CodexStore.LEVEL_KNOWN


## True if [param entry_id] in [param book] is "known".
func is_known(book: String, entry_id: String) -> bool:
	return store.level_of(book, entry_id) == CodexStore.LEVEL_KNOWN


## True if recipe [param recipe_id] is known in the Codex (remembered across lives, AC-CK-13).
func is_recipe_known(recipe_id: String) -> bool:
	return is_known(BOOK_RECIPES, recipe_id)


## Alias for [method is_recipe_known] used by craft lists to mark remembered recipes (Rule 10).
func is_recipe_remembered(recipe_id: String) -> bool:
	return is_recipe_known(recipe_id)


## All currently authored alchemy recipes known in the Codex, each marked `"remembered": true`.
func remembered_recipes() -> Array:
	var out: Array = []
	for r in _gd.recipes():
		var rid: String = str(r.get("id", ""))
		if rid != "" and is_recipe_known(rid):
			var copy: Dictionary = r.duplicate(true)
			copy["remembered"] = true
			out.append(copy)
	return out


## True if chronicle/history event [param event_id] has been learned or uncovered in the Codex
## (supports World Generation rule 3a `hidden` chronicle events, 2026-11-25 back-link).
func is_history_uncovered(event_id: String) -> bool:
	return is_seen(BOOK_HISTORY, event_id)


## Variant root view respecting Rule 8: "seen" reveals description only; "known" also reveals
## formation conditions (`origin` and `requires`).
func variant_info(variant_id: String) -> Dictionary:
	var lv: String = store.level_of(BOOK_VARIANTS, variant_id)
	var def: Dictionary = _gd.variant(variant_id)
	if lv == CodexStore.LEVEL_NONE or def.is_empty():
		return {}
	var known: bool = lv == CodexStore.LEVEL_KNOWN
	return {
		"id": variant_id,
		"level": lv,
		"name": str(def.get("name", variant_id)),
		"name_en": str(def.get("name_en", "")),
		"desc": str(def.get("desc", "")),
		"formation_known": known,
		"origin": str(def.get("origin", "")) if known else "",
		"requires": Array(def.get("requires", [])).duplicate() if known else [],
	}


## Returns ALL authored candidate sites for hidden place [param slot_id] when it is "known"
## in the Codex (AC-CK-14). Reads ONLY authored `world_history.json` + `world_continent.json`,
## NEVER any per-game world ledger, so the current game's rolled site is never exposed.
func hidden_place_candidates(slot_id: String) -> Array:
	if not is_known(BOOK_SECRETS, slot_id):
		return []
	var slot_rec: Dictionary = _authored_secret(slot_id)
	if slot_rec.is_empty():
		return []
	var region_names: Dictionary = _region_name_map()
	var cands: Array = Array(slot_rec.get("candidates", []))
	var regions: Array = Array(slot_rec.get("regions", []))
	var single_region: int = int(slot_rec.get("region", -1))
	var out: Array = []
	for i in cands.size():
		var rid: int = int(regions[i]) if i < regions.size() else single_region
		var tile_raw: Variant = cands[i]
		var tile: Array = [int(tile_raw[0]), int(tile_raw[1])] if typeof(tile_raw) == TYPE_ARRAY and Array(tile_raw).size() >= 2 else []
		out.append({
			"index": i,
			"region_id": rid,
			"region_name": str(region_names.get(rid, "")),
			"tile": tile,
		})
	return out


## Deduplicated candidate regions for a known hidden place [param slot_id] (for rumour lists).
func hidden_place_candidate_regions(slot_id: String) -> Array:
	var seen_rids: Dictionary = {}
	var out: Array = []
	for c in hidden_place_candidates(slot_id):
		var rid: int = int(c.get("region_id", -1))
		if rid >= 0 and not seen_rids.has(rid):
			seen_rids[rid] = true
			out.append({"region_id": rid, "region_name": str(c.get("region_name", ""))})
	return out


## Visible entries for [param book], filtered against current authored [GameData] catalogues.
## Entries whose authored id was removed in a data update stay stored in [member store] but
## are hidden here until the id returns (Edge Cases).
func visible_entries(book: String) -> Array:
	if book == BOOK_LIVES:
		return store.lives.duplicate(true)
	var authored: Dictionary = _authored_catalogue(book)
	var stored: Dictionary = store.entries_in(book)
	var meta: Dictionary = book_meta(book)
	var effect_text: String = str(meta.get("effect", ""))
	var ids: Array = stored.keys()
	ids.sort()
	var out: Array = []
	for raw_id in ids:
		var eid: String = str(raw_id)
		if not authored.has(eid):
			continue
		var srec: Dictionary = Dictionary(stored[eid])
		var lv: String = str(srec.get("level", CodexStore.LEVEL_NONE))
		if lv == CodexStore.LEVEL_NONE:
			continue
		var arec: Dictionary = authored[eid]
		var item := {
			"id": eid,
			"book": book,
			"level": lv,
			"title": str(arec.get("title", eid)),
			"desc": str(arec.get("desc", "")),
			"effect": effect_text,
			"first_year": int(srec.get("first_year", 0)),
			"first_life": str(srec.get("first_life", "")),
		}
		if book == BOOK_VARIANTS:
			var vinfo: Dictionary = variant_info(eid)
			item["formation_known"] = bool(vinfo.get("formation_known", false))
			item["origin"] = str(vinfo.get("origin", ""))
			item["requires"] = Array(vinfo.get("requires", []))
		elif book == BOOK_SECRETS and lv == CodexStore.LEVEL_KNOWN:
			item["candidates"] = hidden_place_candidates(eid)
			item["candidate_regions"] = hidden_place_candidate_regions(eid)
		elif book == BOOK_CAST:
			item["fates"] = Array(srec.get("fates", [])).duplicate(true)
		out.append(item)
	return out


func _authored_secret(slot_id: String) -> Dictionary:
	if not _gd.registry.has_file("world_history"):
		return {}
	var wh: Dictionary = _gd.file("world_history")
	for rec in wh.get("hidden_slots", []):
		if str(rec.get("slot", "")) == slot_id:
			return rec
	for rec in wh.get("tile_secrets", []):
		if str(rec.get("slot", "")) == slot_id:
			return rec
	return {}


func _region_name_map() -> Dictionary:
	var out: Dictionary = {}
	if not _gd.registry.has_file("world_continent"):
		return out
	for r in _gd.file("world_continent").get("regions", []):
		out[int(r.get("id", -1))] = str(r.get("name", ""))
	return out


func _authored_catalogue(book: String) -> Dictionary:
	var out: Dictionary = {}
	match book:
		BOOK_RECIPES:
			for r in _gd.recipes():
				out[str(r.get("id", ""))] = {"title": str(r.get("name", r.get("id", ""))), "desc": str(r.get("desc", ""))}
			if _gd.registry.has_file("crafting_talismans"):
				for t in _gd.file("crafting_talismans").get("talismans", []):
					out[str(t.get("id", ""))] = {"title": str(t.get("name", t.get("id", ""))), "desc": str(t.get("desc", ""))}
			if _gd.registry.has_file("crafting_formations"):
				for fm in _gd.file("crafting_formations").get("formations", []):
					out[str(fm.get("id", ""))] = {"title": str(fm.get("name", fm.get("id", ""))), "desc": str(fm.get("desc", ""))}
			for b in _gd.artifacts_file().get("bases", []):
				out[str(b.get("id", ""))] = {"title": str(b.get("name", b.get("id", ""))), "desc": str(b.get("desc", ""))}
		BOOK_VARIANTS:
			for v in _gd.variant_defs():
				out[str(v.get("id", ""))] = {"title": _gd.element_label(str(v.get("id", ""))), "desc": str(v.get("desc", ""))}
		BOOK_SECRETS:
			if _gd.registry.has_file("world_history"):
				var wh: Dictionary = _gd.file("world_history")
				for s in wh.get("hidden_slots", []):
					var sid: String = str(s.get("slot", ""))
					out[sid] = {"title": "%s (%s)" % [sid, str(s.get("kind", ""))], "desc": str(s.get("origin", ""))}
				for ts in wh.get("tile_secrets", []):
					var tsid: String = str(ts.get("slot", ""))
					out[tsid] = {"title": "%s (%s)" % [tsid, str(ts.get("kind", ""))], "desc": ""}
		BOOK_CAST:
			if _gd.registry.has_file("world_history"):
				for p in _gd.file("world_history").get("people", []):
					var pk: String = str(p.get("key", ""))
					out[pk] = {"title": str(p.get("name", pk)), "desc": str(p.get("role", p.get("gloss", "")))}
		BOOK_HISTORY:
			if _gd.registry.has_file("world_history"):
				for e in _gd.file("world_history").get("events", []):
					var eid: String = str(e.get("id", ""))
					out[eid] = {"title": "%s (Year %d)" % [eid, int(e.get("year", 0))], "desc": str(e.get("text_en", e.get("text_vi", "")))}
		BOOK_TECHNIQUES:
			for t in _gd.cong_phap_file().get("templates", []):
				var tid: String = str(t.get("id", ""))
				out[tid] = {"title": str(t.get("name", tid)), "desc": str(t.get("desc", ""))}
		BOOK_ITEMS:
			for n in _gd.named_items():
				var nid: String = str(n.get("id", ""))
				out[nid] = {"title": str(n.get("name", nid)), "desc": str(n.get("desc", ""))}
			if _gd.registry.has_file("world_history"):
				for l in _gd.file("world_history").get("legendary_items", []):
					var lk: String = str(l.get("key", ""))
					out[lk] = {"title": str(l.get("name", lk)), "desc": str(l.get("story", l.get("gloss", "")))}
			if _gd.registry.has_file("items_treasures"):
				for tr in _gd.file("items_treasures").get("treasures", []):
					var trid: String = str(tr.get("id", ""))
					out[trid] = {"title": str(tr.get("name", trid)), "desc": str(tr.get("desc", ""))}
		BOOK_BEASTS:
			if _gd.registry.has_file("world_history"):
				for b in _gd.file("world_history").get("beasts", []):
					var bk: String = str(b.get("key", ""))
					out[bk] = {"title": str(b.get("name_hv", bk)), "desc": str(b.get("species", b.get("appearance", "")))}
		BOOK_HERBS:
			for h in _gd.herbs():
				var hid: String = str(h.get("id", ""))
				out[hid] = {"title": str(h.get("name", hid)), "desc": str(h.get("desc", ""))}
	out.erase("")
	return out
