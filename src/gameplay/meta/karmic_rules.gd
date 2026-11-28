class_name KarmicRules
extends RefCounted
## Pure math, validation, and succession rule helpers for Codex & Karmic Carryover (#12).
## Design: design/gdd/codex-karmic-carryover.md (Rules 4-6; Formulas A-C; Edge Cases;
## AC-CK-07..11, 17, 20). All tuning values are read from `assets/data/meta_codex.json`,
## `character_edges.json`, `character_attributes.json`, and `cultivation_realms.json`.
##
## Usage:
## [codeblock]
## var earned: int = KarmicRules.karma_earned(gd, "continue", "thien_dinh", false, 1, false, 0, 25)
## var check: Dictionary = KarmicRules.validate_spend(gd, 4, false, 0, true, 1, 8, "thien_dinh")
## var offered: Array = KarmicRules.roll_successor_perks(gd, rng, held_perks, 1)
## [/codeblock]

const CONFIG_FILE := "meta_codex"
const MODE_ONE_LIFE := "one_life"
const MODE_CONTINUE := "continue"
const STATUS_ACTIVE := "active"
const STATUS_SUCCESSION := "succession"
const STATUS_ENDED := "ended"


## Raw `meta_codex.json` dictionary.
static func config(gd: GameData) -> Dictionary:
	return gd.file(CONFIG_FILE)


## Every new playthrough starts with 0 karma regardless of prior playthroughs (Rule 6, AC-CK-10).
static func starting_karma() -> int:
	return 0


## Validates a playthrough mode id ("one_life" or "continue"), defaulting to "one_life".
static func normalize_mode(mode: String) -> String:
	return MODE_CONTINUE if mode == MODE_CONTINUE else MODE_ONE_LIFE


## Formula A: karma earned when a life ends.
## Returns 0 in One Life, Self-made (`tu_dinh`), or `cheated` lives.
## An heir life counts `realm_karma` only if it advanced past [param start_realm] (Rule 6, AC-CK-08, 10).
static func karma_earned(
	gd: GameData,
	mode: String,
	birth_mode: String,
	cheated: bool,
	r_max: int,
	is_heir_life: bool,
	start_realm: int,
	k_new: int
) -> int:
	if mode != MODE_CONTINUE or birth_mode != "thien_dinh" or cheated:
		return 0
	var cfg: Dictionary = config(gd)
	var realm_table: Array = cfg.get("realm_karma", [0, 1, 2, 4, 6])
	var realm_part: int = 0
	if not (is_heir_life and r_max <= start_realm):
		var r_idx: int = clampi(r_max, 0, maxi(0, realm_table.size() - 1))
		realm_part = int(realm_table[r_idx])
	var per_karma: int = maxi(1, int(cfg.get("known_per_karma", 10)))
	var discovery_part: int = int(floor(float(maxi(0, k_new)) / float(per_karma)))
	return realm_part + discovery_part


## Formula B: karma cost to succeed as an heir at [param realm_index] (0/1/3/6/10; mortal/negative = 0).
static func heir_cost(gd: GameData, realm_index: int) -> int:
	var table: Array = config(gd).get("heir_cost", [0, 1, 3, 6, 10])
	if table.is_empty():
		return 0
	return int(table[clampi(realm_index, 0, table.size() - 1)])


## Formula B: karma cost of a lineage rebirth into the dead life's sect or clan (3).
static func lineage_cost(gd: GameData) -> int:
	return int(config(gd).get("lineage_cost", 3))


## Formula B: maximum extra destiny perk options purchasable with karma (3).
static func perk_extra_max(gd: GameData) -> int:
	return int(config(gd).get("perk_extra_max", 3))


## Base number of destiny perk options rolled for Fated birth (3, from `character_edges.json`).
static func base_perk_choices(gd: GameData) -> int:
	return int(ProgressionEdges.config(gd).get("player", {}).get("perk_choices", 3))


## Formula B: maximum valid `perk_extra` given available karma, base choice cost (`heir_cost` or
## `lineage_cost`), unheld perk count, and successor birth mode (AC-CK-09, AC-CK-17).
## Always 0 in Self-made birth or when `unheld_perks <= base_perk_choices`.
static func max_perk_extra(gd: GameData, karma_avail: int, base_cost: int, unheld_perks: int, birth_mode: String) -> int:
	if birth_mode != "thien_dinh":
		return 0
	var base_opts: int = base_perk_choices(gd)
	var cap_data: int = perk_extra_max(gd)
	var cap_karma: int = karma_avail - base_cost
	var cap_pool: int = maxi(0, unheld_perks - base_opts)
	return maxi(0, mini(mini(cap_data, cap_karma), cap_pool))


## Formula B: validates a karma spend at succession.
## Enforces `heir * lineage = 0`, non-negative `perk_extra`, Self-made `perk_extra == 0`,
## `perk_extra <= max_perk_extra`, and `total_cost <= karma` (AC-CK-09, 17, 20).
## Returns `{ok, reason, total_cost, base_cost, perk_extra, karma_left, options, max_perk_extra}`.
static func validate_spend(
	gd: GameData,
	karma: int,
	is_heir: bool,
	r_heir: int,
	lineage: bool,
	perk_extra: int,
	unheld: int,
	birth_mode: String
) -> Dictionary:
	var avail: int = maxi(0, karma)
	var unheld_clamped: int = maxi(0, unheld)
	var base_opts: int = base_perk_choices(gd)
	if is_heir and lineage:
		return {
			"ok": false,
			"reason": "lineage_with_heir",
			"total_cost": 0,
			"base_cost": 0,
			"perk_extra": perk_extra,
			"karma_left": avail,
			"options": 0,
			"max_perk_extra": 0,
		}
	if perk_extra < 0:
		return {
			"ok": false,
			"reason": "negative_perk_extra",
			"total_cost": 0,
			"base_cost": 0,
			"perk_extra": perk_extra,
			"karma_left": avail,
			"options": 0,
			"max_perk_extra": 0,
		}
	var base_cost: int = heir_cost(gd, r_heir) if is_heir else (lineage_cost(gd) if lineage else 0)
	var allowed_extra: int = max_perk_extra(gd, avail, base_cost, unheld_clamped, birth_mode)
	if base_cost > avail:
		return {
			"ok": false,
			"reason": "insufficient_karma",
			"total_cost": base_cost + perk_extra,
			"base_cost": base_cost,
			"perk_extra": perk_extra,
			"karma_left": avail,
			"options": 0,
			"max_perk_extra": 0,
		}
	if birth_mode != "thien_dinh" and perk_extra > 0:
		return {
			"ok": false,
			"reason": "perk_extra_self_made",
			"total_cost": base_cost + perk_extra,
			"base_cost": base_cost,
			"perk_extra": perk_extra,
			"karma_left": avail,
			"options": unheld_clamped,
			"max_perk_extra": 0,
		}
	if perk_extra > allowed_extra:
		var reason: String = "perk_extra_above_unheld"
		if perk_extra > perk_extra_max(gd):
			reason = "perk_extra_above_max"
		elif base_cost + perk_extra > avail:
			reason = "insufficient_karma"
		return {
			"ok": false,
			"reason": reason,
			"total_cost": base_cost + perk_extra,
			"base_cost": base_cost,
			"perk_extra": perk_extra,
			"karma_left": avail,
			"options": 0,
			"max_perk_extra": allowed_extra,
		}
	var total_cost: int = base_cost + perk_extra
	var options: int = unheld_clamped if birth_mode != "thien_dinh" else mini(unheld_clamped, base_opts + perk_extra)
	return {
		"ok": true,
		"reason": "",
		"total_cost": total_cost,
		"base_cost": base_cost,
		"perk_extra": perk_extra,
		"karma_left": avail - total_cost,
		"options": options,
		"max_perk_extra": allowed_extra,
	}


## Edge Cases (AC-CK-11): resolves whether a paid lineage rebirth survived the rebirth gap.
## If the sect or clan was destroyed, refunds `lineage_cost` karma and falls back to `tan_tu`
## in [param fallback_region_id].
static func resolve_lineage_survival(
	gd: GameData,
	karma_after_spend: int,
	lineage_kind: String,
	lineage_alive: bool,
	fallback_region_id: String
) -> Dictionary:
	if lineage_kind == "" or lineage_alive:
		return {
			"refunded": false,
			"refund_amount": 0,
			"karma": karma_after_spend,
			"fallback_origin": "",
			"fallback_region_id": "",
		}
	var refund: int = lineage_cost(gd)
	return {
		"refunded": true,
		"refund_amount": refund,
		"karma": karma_after_spend + refund,
		"fallback_origin": "tan_tu",
		"fallback_region_id": fallback_region_id,
	}


## Formula C: years the world advances before a reborn enters (`start_age(origin)`, 16).
static func rebirth_years(gd: GameData, origin_id: String = "") -> int:
	var orig: Dictionary = gd.origin(origin_id) if origin_id != "" else {}
	if orig.has("start_age"):
		return int(roundf(float(orig.start_age)))
	var start_cfg: Dictionary = gd.attributes().get("start", {})
	if start_cfg.has("age"):
		return int(roundf(float(start_cfg.age)))
	var spy: int = maxi(1, int(gd.cultivation_rules().get("seasons_per_year", 4)))
	return int(roundf(float(config(gd).get("rebirth_seasons_default", 64)) / float(spy)))


## Formula C: seasons the world ticks before a reborn enters (`4 * rebirth_years` = 64; AC-CK-06).
static func rebirth_seasons(gd: GameData, origin_id: String = "") -> int:
	var spy: int = maxi(1, int(gd.cultivation_rules().get("seasons_per_year", 4)))
	return rebirth_years(gd, origin_id) * spy


## Formula C: maximum past-life recognition events a reborn's life may draw (2; AC-CK-22).
static func recognition_max(gd: GameData) -> int:
	return int(config(gd).get("recognition_max", 2))


## Rule 5 (AC-CK-07): starting talisman grants for a successor.
## A reborn receives the two starting Phá Cảnh Phù; an heir receives none.
static func successor_starting_talismans(gd: GameData, is_heir: bool) -> Array:
	if is_heir:
		return []
	return Array(ProgressionEdges.config(gd).get("player", {}).get("starting_items", [])).duplicate(true)


## Rule 5 (AC-CK-07): every successor (heir or reborn) receives the protagonist's edge.
static func successor_gets_edge() -> bool:
	return true


## Rule 5: an heir keeps the dead life's birth mode; a reborn chooses it as at a new game.
static func successor_birth_mode(dead_birth_mode: String, is_heir: bool, chosen_birth_mode: String = "") -> String:
	if is_heir:
		return dead_birth_mode if dead_birth_mode != "" else "thien_dinh"
	return chosen_birth_mode if chosen_birth_mode != "" else "thien_dinh"


## Perk definitions from `character_edges.json` not already held by the successor.
static func unheld_perks(gd: GameData, held_perks: Array) -> Array:
	var held: Dictionary = {}
	for pid in held_perks:
		held[str(pid)] = true
	var out: Array = []
	for p in ProgressionEdges.perks(gd):
		if not held.has(str(p.get("id", ""))):
			out.append(p)
	return out


## Rule 5 (AC-CK-07, AC-CK-17): rolls unheld destiny perk ids for a successor using [param rng].
## In Fated birth, returns up to `min(unheld, 3 + extra)` distinct unheld ids (empty if none left).
## In Self-made birth, returns all unheld perk ids (player may pick any).
static func roll_successor_perks(
	gd: GameData,
	rng: RandomNumberGenerator,
	held_perks: Array,
	extra: int = 0,
	birth_mode: String = "thien_dinh"
) -> Array:
	var pool: Array = unheld_perks(gd, held_perks)
	if pool.is_empty():
		return []
	if birth_mode != "thien_dinh":
		return pool.map(func(p): return str(p.id))
	var capped_extra: int = clampi(extra, 0, perk_extra_max(gd))
	var count: int = mini(pool.size(), base_perk_choices(gd) + capped_extra)
	return RngUtils.shuffled(rng, pool).slice(0, count).map(func(p): return str(p.id))


## Rule 4 (AC-CK-04, AC-CK-20): builds the list of eligible heir candidates (living children and
## living disciples of [param dead_id], excluding [param known_killer_id] and beasts), annotated
## with `cost`, `affordable`, and `greyed` against [param karma].
static func heir_candidates(
	gd: GameData,
	db: WorldDB,
	dead_id: String,
	known_killer_id: String,
	karma: int,
	pre_death_disciples: Array = []
) -> Array:
	if db == null or dead_id == "":
		return []
	var is_child: Dictionary = {}
	for cid in db.children_of(dead_id):
		is_child[str(cid)] = true
	var is_disciple: Dictionary = {}
	for did in pre_death_disciples:
		var ds: String = str(did)
		if ds != "":
			is_disciple[ds] = true
	for p in db.living():
		if str(p.get("master_id", "")) == dead_id:
			is_disciple[str(p.id)] = true
	for rec in db.ties_of(dead_id):
		var pin: Dictionary = rec.get("pin", {})
		if str(pin.get("su_do", "")) == dead_id:
			var other: String = str(rec.b) if str(rec.a) == dead_id else str(rec.a)
			if other != "":
				is_disciple[other] = true
	var all_ids: Dictionary = {}
	for cid in is_child:
		all_ids[cid] = true
	for did in is_disciple:
		all_ids[did] = true
	var out: Array = []
	for raw_id in all_ids:
		var hid: String = str(raw_id)
		if hid == "" or hid == dead_id:
			continue
		if known_killer_id != "" and hid == known_killer_id:
			continue
		var rec: Dictionary = db.get_record("people", hid)
		if rec.is_empty() or not bool(rec.get("alive", false)) or bool(rec.get("is_beast", false)):
			continue
		var r_idx: int = int(rec.get("realm_index", 0))
		var stg: int = int(rec.get("stage", 0))
		var cost: int = heir_cost(gd, r_idx)
		var affordable: bool = cost <= karma
		var rel: String = "child & disciple" if (is_child.has(hid) and is_disciple.has(hid)) else ("child" if is_child.has(hid) else "disciple")
		var sect_id: String = str(rec.get("sect_id", ""))
		var place_id: String = str(rec.get("location_id", ""))
		var notable_ties: Array = []
		for t in db.ties_of(hid):
			var other_id: String = str(t.b) if str(t.a) == hid else str(t.a)
			var other_rec: Dictionary = db.get_record("people", other_id)
			if not other_rec.is_empty() and bool(other_rec.get("alive", false)):
				var pin: Dictionary = t.get("pin", {})
				if not pin.is_empty():
					notable_ties.append({"id": other_id, "name": str(other_rec.get("name", other_id)), "kinds": pin.keys()})
		out.append({
			"id": hid,
			"name": str(rec.get("name", hid)),
			"relation": rel,
			"realm_index": r_idx,
			"realm_label": _gd_realm_label(gd, r_idx, stg),
			"age": float(rec.get("age", 16.0)),
			"sect_id": sect_id,
			"sect_name": str(db.get_record("sects", sect_id).get("name", "")) if sect_id != "" else "",
			"place_id": place_id,
			"place_name": str(db.get_record("places", place_id).get("name", "")) if place_id != "" else "",
			"cost": cost,
			"affordable": affordable,
			"greyed": not affordable,
			"traits": Array(rec.get("traits", [])).duplicate(),
			"notable_ties": notable_ties,
		})
	out.sort_custom(func(a, b):
		if int(a.cost) != int(b.cost):
			return int(a.cost) < int(b.cost)
		return str(a.id) < str(b.id)
	)
	return out


static func _gd_realm_label(gd: GameData, realm_idx: int, stage: int) -> String:
	if gd == null or gd.realms().is_empty():
		return "Realm %d" % realm_idx
	return gd.realm_label(realm_idx, stage)
