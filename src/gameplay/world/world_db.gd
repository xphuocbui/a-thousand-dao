class_name WorldDB
extends RefCounted
## The world database: every person, sect, place, region, item and event, keyed by id.
## This is the single source of truth the engine, the LLM context and the terminal's
## `db` commands read from (pillar: A World That Remembers).
##
## Tables and id prefixes:
##   people "p", sects "s", places "l", regions "r", items "i", events "e".
## Records are plain Dictionaries so the whole database serializes to JSON.
##
## Usage:
## [codeblock]
## var db := WorldDB.new()
## var pid: String = db.add("people", {"name": "Hàn Lập Phong"})
## var eid: String = db.log_event(300, 0, "breakthrough", "…", [pid], [], [])
## for e in db.events_of(pid): print(e.text)
## [/codeblock]

signal record_added(table: String, record_id: String)
signal event_logged(event_id: String)

## "ratings" holds Power Rankings records under their person's id (RatingService); "standing" holds each (sect, person)
## record of Sects & Missions under "<sect id>:<person id>" (SectMembers). Neither prefix is ever generated. "world" holds
## the built world's own record "w_meta" (WorldBuilder: builder, data and map versions, seed, and the never-shown ledger
## of rolled hidden spots, World Generation Core Rules 10 and 13). "money" holds the commons and lost-stash pools and the
## season's money books (MoneyLedger, Regional Economy & Trade Formula H); "markets" one record per great sect's market
## (WorldEconomy, rules 1-11). "ties" holds NPC Relationships' records, one per pair (Ties; npc-relationships.md
## rule 1), indexed from both people.
const TABLES := {"people": "p", "sects": "s", "places": "l", "regions": "r", "items": "i", "events": "e", "ratings": "q",
	"standing": "y", "world": "w", "money": "m", "markets": "k", "ties": "t"}

var _tables: Dictionary = {}
var _next_id: Dictionary = {}
## Entity id -> Array of event ids that mention it.
var _event_index: Dictionary = {}
## The living people (id -> record) in the people table's insertion order; the dead drop out when [method living]
## next reads them. Rebuilt from the table when an edit could break the order (a revived or re-added record, a load).
var _living: Dictionary = {}
var _living_ok: bool = true
## The owner index: owner id -> {item id: true}, with each item's place in the table so [method items_of] keeps table
## order. Built on first use (and after a load), then kept in step by every owner change, which must go through this
## class: add, put, remove, give_item, set_owner, items_on_death. Setting a stored item's "owner_id" by hand leaves the
## index stale (a stale entry found by [method items_of] rebuilds it, but the new owner can miss the item until then).
var _owner_ix: Dictionary = {}
var _ord: Dictionary = {}
var _ord_next: int = 0
var _ix_on: bool = false
## The tie index (NPC Relationships rule 1): person id -> {tie record id: true}, and "<lower id>|<higher id>" -> the
## pair's record id. Built on first use and after a load; kept in step by add, put and remove on the ties table.
var _tie_ix: Dictionary = {}
var _tie_pair: Dictionary = {}
var _tie_hook: Dictionary = {}   # the hook index (rule 15a): records holding sư đồ or đạo lữ
var _tie_on: bool = false


func _init() -> void:
	for t in TABLES.keys():
		_tables[t] = {}
		_next_id[t] = 1


## Inserts a record, assigning an id unless the record already has one. Returns the id.
func add(table: String, record: Dictionary) -> String:
	assert(TABLES.has(table), "WorldDB: unknown table %s" % table)
	var rid: String = str(record.get("id", ""))
	if rid == "":
		rid = "%s%d" % [TABLES[table], _next_id[table]]
		_next_id[table] = int(_next_id[table]) + 1
		record["id"] = rid
	if table == "people":
		_note_person(rid, record)
	elif table == "items" and _ix_on:
		_ix_drop(rid)
		_ix_set(rid, str(record.get("owner_id", "")))
	elif table == "ties" and _tie_on:
		_tie_drop(rid)
		_tie_set(rid, record)
	_tables[table][rid] = record
	record_added.emit(table, rid)
	return rid


## Replaces a record (same id).
func put(table: String, record: Dictionary) -> void:
	if table == "people":
		_note_person(str(record.id), record)
	elif table == "items" and _ix_on:
		_ix_drop(str(record.id))
		_ix_set(str(record.id), str(record.get("owner_id", "")))
	elif table == "ties" and _tie_on:
		_tie_drop(str(record.id))
		_tie_set(str(record.id), record)
	_tables[table][str(record.id)] = record


# Keeps the living view in step with an add or put of person [param rid] (called before the table write).
func _note_person(rid: String, record: Dictionary) -> void:
	if not _living_ok:
		return
	var alive: bool = bool(record.get("alive", true))
	if _living.has(rid):
		_living[rid] = record   # same place in the order
	elif _tables.people.has(rid):
		if alive:   # a record that was dead (or never living) comes back: the order needs a rebuild
			_living_ok = false
	elif alive:
		_living[rid] = record


## The living people (records whose alive is not false), in the people table's insertion order: what a scan of
## [method all] that skips the dead sees, without walking the dead. A fresh Array each call.
func living() -> Array:
	if not _living_ok:
		_living = {}
		for r in _tables.people.values():
			if bool(r.get("alive", true)):
				_living[str(r.id)] = r
		_living_ok = true
	var out: Array = []
	var dead: Array = []
	for rid in _living:
		var r: Dictionary = _living[rid]
		if bool(r.get("alive", true)):
			out.append(r)
		else:
			dead.append(rid)
	for rid in dead:
		_living.erase(rid)
	return out


## Record by id, or an empty Dictionary.
func get_record(table: String, record_id: String) -> Dictionary:
	return _tables.get(table, {}).get(record_id, {})


## True if the table has this id.
func has_record(table: String, record_id: String) -> bool:
	return _tables.get(table, {}).has(record_id)


## Finds the table an id belongs to by its prefix ("" if unknown).
func table_of(record_id: String) -> String:
	for t in TABLES.keys():
		if record_id.begins_with(TABLES[t]) and record_id.substr(1).is_valid_int():
			return t
	return ""


## Any record by id regardless of table.
func lookup(record_id: String) -> Dictionary:
	var t: String = table_of(record_id)
	return {} if t == "" else get_record(t, record_id)


## All records of a table, in insertion order.
func all(table: String) -> Array:
	return _tables.get(table, {}).values()


## Number of records in a table.
func count(table: String) -> int:
	return _tables.get(table, {}).size()


## Records for which [param predicate] returns true.
func find(table: String, predicate: Callable) -> Array:
	var out: Array = []
	for r in _tables.get(table, {}).values():
		if predicate.call(r):
			out.append(r)
	return out


## Case-insensitive name search across a table (matches with or without diacritics stripped).
func search(table: String, text: String) -> Array:
	var needle: String = fold(text)
	return find(table, func(r): return fold(str(r.get("name", ""))).contains(needle) or str(r.get("id", "")) == text)


## Removes a record (items consumed, etc.).
func remove(table: String, record_id: String) -> void:
	if table == "items" and _ix_on:
		_ix_drop(record_id)
		_ord.erase(record_id)
	elif table == "ties" and _tie_on:
		_tie_drop(record_id)
	_tables.get(table, {}).erase(record_id)
	if table == "people":
		_living.erase(record_id)


# --- Items ------------------------------------------------------------------------

## Items owned by an entity id, in table order (read from the owner index).
func items_of(owner_id: String) -> Array:
	if not _ix_on:
		_build_owner_index()
	var ids: Array = Dictionary(_owner_ix.get(owner_id, {})).keys()
	ids.sort_custom(func(a, b): return int(_ord[a]) < int(_ord[b]))
	var out: Array = []
	for iid in ids:
		var r: Dictionary = _tables.items.get(iid, {})
		if r.is_empty() or str(r.get("owner_id", "")) != owner_id:   # an owner set by hand: rebuild and answer again
			_build_owner_index()
			return items_of(owner_id)
		out.append(r)
	return out


func _build_owner_index() -> void:
	_owner_ix = {}
	_ord = {}
	_ord_next = 0
	for r in _tables.items.values():
		_ord[str(r.id)] = _ord_next
		_ord_next += 1
		_ix_set(str(r.id), str(r.get("owner_id", "")))
	_ix_on = true


## Sets stored item [param item]'s owner to [param owner_id] and keeps the owner index in step (no other field changes;
## [method give_item] also clears Lost).
func set_owner(item: Dictionary, owner_id: String) -> void:
	if _ix_on and item.has("id"):
		_ix_drop(str(item.id))
		if _tables.items.has(str(item.id)):
			_ix_set(str(item.id), owner_id)
	item["owner_id"] = owner_id


func _ix_set(item_id: String, owner: String) -> void:
	if not _ord.has(item_id):
		_ord[item_id] = _ord_next
		_ord_next += 1
	if not _owner_ix.has(owner):
		_owner_ix[owner] = {}
	_owner_ix[owner][item_id] = true


func _ix_drop(item_id: String) -> void:
	var old: Dictionary = _tables.items.get(item_id, {})
	if old.is_empty():
		return
	var o: String = str(old.get("owner_id", ""))
	if _owner_ix.has(o):
		_owner_ix[o].erase(item_id)


## Sets an item's owner (transfer). Returns false if the item is missing.
func give_item(item_id: String, owner_id: String) -> bool:
	var item: Dictionary = get_record("items", item_id)
	if item.is_empty():
		return false
	set_owner(item, owner_id)
	if table_of(owner_id) != "places":   # a person or a market takes it: it is no longer Lost (rule 14 decay)
		item.erase("lost")
		item.erase("lost_since")
	return true


## Moves a dead person's items (item-database.md rule 14): unbound items go to [param killer_id] if there is one,
## else to [param heir_id] (a close relationship or the sect successor: see Inheritance), else they are Lost at
## [param place_id]; bound items are always Lost there. The system resolving the death calls this. Clears the dead
## person's `equipped` list. Returns the ids moved.
func items_on_death(person_id: String, place_id: String, killer_id: String = "", heir_id: String = "") -> Array:
	var moved: Array = []
	var taker: String = killer_id if killer_id != "" else heir_id
	for item in items_of(person_id):
		var to_taker: bool = taker != "" and not bool(item.get("bound", false))
		set_owner(item, taker if to_taker else place_id)
		item.erase("lost")
		item.erase("lost_since")
		if not to_taker:
			item["lost"] = true
		moved.append(item.id)
	var person: Dictionary = get_record("people", person_id)
	if not person.is_empty():
		person["equipped"] = []
		person["equip_slots"] = {}
	return moved


# --- Ties -------------------------------------------------------------------------

## NPC Relationships: the tie records person [param person_id] is part of, in record-id order (a fresh Array).
func ties_of(person_id: String) -> Array:
	if not _tie_on:
		_build_tie_index()
	var ids: Array = Dictionary(_tie_ix.get(person_id, {})).keys()
	ids.sort_custom(func(x, y): return int(str(x).substr(1)) < int(str(y).substr(1)))
	var out: Array = []
	for rid in ids:
		out.append(_tables.ties[rid])
	return out


## The tie record between [param a] and [param b], or an empty Dictionary.
func tie_between(a: String, b: String) -> Dictionary:
	if not _tie_on:
		_build_tie_index()
	var rid: String = str(_tie_pair.get(tie_key(a, b), ""))
	return {} if rid == "" else _tables.ties.get(rid, {})


## The hook index (NPC Relationships rule 15a): the records holding sư đồ or đạo lữ, in record-id order.
func hook_ties() -> Array:
	if not _tie_on:
		_build_tie_index()
	var ids: Array = _tie_hook.keys()
	ids.sort_custom(func(x, y): return int(str(x).substr(1)) < int(str(y).substr(1)))
	return ids.map(func(rid): return _tables.ties[rid])


## The pair key of a tie record: the two ids, the lower first.
static func tie_key(a: String, b: String) -> String:
	return "%s|%s" % ([a, b] if a < b else [b, a])


func _build_tie_index() -> void:
	_tie_ix = {}
	_tie_pair = {}
	_tie_hook = {}
	for r in _tables.ties.values():
		_tie_set(str(r.id), r)
	_tie_on = true


func _tie_set(rid: String, r: Dictionary) -> void:
	for pid in [str(r.get("a", "")), str(r.get("b", ""))]:
		if not _tie_ix.has(pid):
			_tie_ix[pid] = {}
		_tie_ix[pid][rid] = true
	_tie_pair[tie_key(str(r.get("a", "")), str(r.get("b", "")))] = rid
	var pin: Dictionary = r.get("pin", {})
	if pin.has("su_do") or pin.has("dao_lu"):
		_tie_hook[rid] = true


func _tie_drop(rid: String) -> void:
	var old: Dictionary = _tables.ties.get(rid, {})
	if old.is_empty():
		return
	for pid in [str(old.get("a", "")), str(old.get("b", ""))]:
		if _tie_ix.has(pid):
			_tie_ix[pid].erase(rid)
	_tie_pair.erase(tie_key(str(old.get("a", "")), str(old.get("b", ""))))
	_tie_hook.erase(rid)


# --- Events -----------------------------------------------------------------------

## Appends a history/story event and indexes it by every participant, place and item.
## [param data] can hold structured details (effects, numbers) for later explanation.
func log_event(year: int, season: int, type: String, text: String, people: Array, places: Array, items: Array, data: Dictionary = {}) -> String:
	var rec := {
		"year": year, "season": season, "type": type, "text": text,
		"people": people.duplicate(), "places": places.duplicate(), "items": items.duplicate(), "data": data,
	}
	var eid: String = add("events", rec)
	for ref in people + places + items:
		_index_event(str(ref), eid)
	event_logged.emit(eid)
	return eid


## Events mentioning an entity, oldest first.
func events_of(entity_id: String) -> Array:
	var out: Array = []
	for eid in _event_index.get(entity_id, []):
		var e: Dictionary = get_record("events", eid)
		if not e.is_empty():
			out.append(e)
	return out


## The most recent [param n] events overall.
func recent_events(n: int) -> Array:
	var all_events: Array = all("events")
	return all_events.slice(maxi(0, all_events.size() - n))


# --- Serialization ----------------------------------------------------------------

## Whole database as a JSON-safe Dictionary.
func to_dict() -> Dictionary:
	return {"tables": _tables.duplicate(true), "next_id": _next_id.duplicate()}


## Restores from [method to_dict] output and rebuilds the event index.
static func from_dict(d: Dictionary) -> WorldDB:
	var db := WorldDB.new()
	var tables: Dictionary = d.get("tables", {})
	for t in TABLES.keys():
		db._tables[t] = tables.get(t, {})
	db._living_ok = false   # rebuilt on first use, as is the owner index
	var nid: Dictionary = d.get("next_id", {})
	for t in TABLES.keys():
		db._next_id[t] = int(nid.get(t, 1))
	for e in db.all("events"):
		for ref in Array(e.get("people", [])) + Array(e.get("places", [])) + Array(e.get("items", [])):
			db._index_event(str(ref), str(e.id))
	return db


func _index_event(entity_id: String, event_id: String) -> void:
	if not _event_index.has(entity_id):
		_event_index[entity_id] = []
	_event_index[entity_id].append(event_id)


## Lower-case text with Vietnamese diacritics removed, for forgiving terminal search.
static func fold(text: String) -> String:
	var src := "àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ"
	var dst := "aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd"
	var lower: String = text.to_lower()
	var out := ""
	for ch in lower:
		var i: int = src.find(ch)
		out += dst[i] if i != -1 else ch
	return out
