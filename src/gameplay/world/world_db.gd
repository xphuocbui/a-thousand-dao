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

const TABLES := {"people": "p", "sects": "s", "places": "l", "regions": "r", "items": "i", "events": "e"}

var _tables: Dictionary = {}
var _next_id: Dictionary = {}
## Entity id -> Array of event ids that mention it.
var _event_index: Dictionary = {}


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
	_tables[table][rid] = record
	record_added.emit(table, rid)
	return rid


## Replaces a record (same id).
func put(table: String, record: Dictionary) -> void:
	_tables[table][str(record.id)] = record


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
	_tables.get(table, {}).erase(record_id)


# --- Items ------------------------------------------------------------------------

## Items owned by an entity id.
func items_of(owner_id: String) -> Array:
	return find("items", func(r): return str(r.get("owner_id", "")) == owner_id)


## Sets an item's owner (transfer). Returns false if the item is missing.
func give_item(item_id: String, owner_id: String) -> bool:
	var item: Dictionary = get_record("items", item_id)
	if item.is_empty():
		return false
	item["owner_id"] = owner_id
	return true


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
