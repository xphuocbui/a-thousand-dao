class_name MoneyLedger
extends RefCounted

## Money holders and the conservation of linh thạch (design/gdd/regional-economy-trade.md rule 5 and Formula H).
## Linh thạch is money: mines make it ([method mint]), sinks destroy it ([method burn]), and everything else moves it
## between named holders ([method transfer]). A holder id names where a balance is stored:
## - [code]sect:<sect id>[/code]: the sect record's [code]treasury[/code] (Sects F3);
## - [code]npc:<person id>[/code]: the person record's [code]linh_thach[/code] purse;
## - [code]pool:<market id>[/code], [code]stash:<market id>[/code]: a market's commons pool and its lost-stash pool
##   (Formulas H and K), records of the World DB's [code]money[/code] table;
## - [code]player[/code]: the player's purse (outside the world's money M).
## The [code]money[/code] table's record [code]m_books[/code] keeps the season's books: money minted by cause, burned by
## cause, and the player's net take ([code]player_net[/code]), so a season's change of M is checkable:
## ΔM = minted − burned − player_net (AC-RE-07). Balances are floats; the player's purse stays a whole number, so a
## transfer to or from the player moves whole stones only.
##
## Usage:
## [codeblock]
## var money := MoneyLedger.new(db, player)
## money.mint("sect:s1", 7938.0, "mine")
## money.transfer("pool:s1", "player", 120.0, "mission")
## money.burn("player", 15.0, "refine_fuel")
## [/codeblock]

const TABLE := "money"
const BOOKS := "m_books"
const PLAYER := "player"

var db: WorldDB
var player: Character
# holder id -> [record, field]: the records are the World DB's own, so a cached slot stays live for this ledger's life
var _slots: Dictionary = {}
var _b: Dictionary = {}


func _init(world: WorldDB, who: Character = null) -> void:
	db = world
	player = who
	if not db.has_record(TABLE, BOOKS):
		db.put(TABLE, {"id": BOOKS, "minted": {}, "burned": {}, "player_net": 0.0, "season_start_m": 0.0})


## The balance of [param holder] (0 for an unknown holder).
func balance(holder: String) -> float:
	if holder == PLAYER:
		return float(player.linh_thach) if player != null else 0.0
	var at: Array = _slot(holder)
	if at.is_empty():
		return 0.0
	return float(at[0].get(at[1], 0.0))


## Moves up to [param amount] from [param from] to [param to] (never more than [param from] holds; whole stones when
## the player is a side). Returns what moved. [param cause] is kept for the books' readers; a transfer creates and
## destroys nothing.
func transfer(from: String, to: String, amount: float, cause: String = "") -> float:
	var n: float = minf(maxf(0.0, amount), balance(from))
	if from == PLAYER or to == PLAYER:
		n = floorf(n)
	if n <= 0.0 or from == to:
		return 0.0
	_add(from, -n)
	_add(to, n)
	if to == PLAYER:
		_books().player_net = float(_books().player_net) + n
	elif from == PLAYER:
		_books().player_net = float(_books().player_net) - n
	if cause != "":
		var b: Dictionary = _books()
		var moved: Dictionary = b.get("moved", {})
		moved[cause] = float(moved.get(cause, 0.0)) + n
		b["moved"] = moved
	return n


## Pays many holders from one in a batch ([param pays]: [[holder, amount], ...], in order, each limited by what
## [param from] has left; neither side may be the player). The same books as one transfer each; returns what moved.
func pay_out(from: String, pays: Array, cause: String) -> float:
	var at: Array = _slot(from)
	if at.is_empty():
		return 0.0
	var left: float = float(at[0].get(at[1], 0.0))
	var moved: float = 0.0
	for e in pays:
		var n: float = minf(maxf(0.0, float(e[1])), left)
		if n <= 0.0:
			continue
		var to: Array = _slot(str(e[0]))
		if to.is_empty():
			continue
		to[0][to[1]] = float(to[0].get(to[1], 0.0)) + n
		left -= n
		moved += n
	at[0][at[1]] = left
	_note(cause, moved)
	return moved


## Collects from many holders into one in a batch ([param takes]: [[holder, amount], ...], each limited by its own
## balance; neither side may be the player). Returns what moved.
func collect_in(takes: Array, to: String, cause: String) -> float:
	var at: Array = _slot(to)
	if at.is_empty():
		return 0.0
	var moved: float = 0.0
	for e in takes:
		var fr: Array = _slot(str(e[0]))
		if fr.is_empty():
			continue
		var have: float = float(fr[0].get(fr[1], 0.0))
		var n: float = minf(maxf(0.0, float(e[1])), have)
		if n <= 0.0:
			continue
		fr[0][fr[1]] = have - n
		moved += n
	at[0][at[1]] = float(at[0].get(at[1], 0.0)) + moved
	_note(cause, moved)
	return moved


func _note(cause: String, n: float) -> void:
	if cause == "" or n <= 0.0:
		return
	var b: Dictionary = _books()
	var moved: Dictionary = b.get("moved", {})
	moved[cause] = float(moved.get(cause, 0.0)) + n
	b["moved"] = moved


## Creates [param amount] at [param to] (the mine faucet, Travel & Map Formula L; the only source of new money).
func mint(to: String, amount: float, cause: String = "mine") -> float:
	var n: float = maxf(0.0, amount)
	if to == PLAYER:
		n = floorf(n)
	if n <= 0.0:
		return 0.0
	if to != PLAYER and _slot(to).is_empty():
		push_error("MoneyLedger: unknown holder %s" % to)
		return 0.0
	_add(to, n)
	var b: Dictionary = _books()
	b.minted[cause] = float(b.minted.get(cause, 0.0)) + n
	if to == PLAYER:   # minted straight into the player's purse: it never enters M
		b.player_net = float(b.player_net) + n
	return n


## Destroys up to [param amount] of [param from]'s balance (a sink: works, stones, fees, fuel). Returns what burned.
func burn(from: String, amount: float, cause: String) -> float:
	var n: float = minf(maxf(0.0, amount), balance(from))
	if from == PLAYER:
		n = floorf(n)
	if n <= 0.0:
		return 0.0
	_add(from, -n)
	var b: Dictionary = _books()
	b.burned[cause] = float(b.burned.get(cause, 0.0)) + n
	if from == PLAYER:
		b.player_net = float(b.player_net) - n
	return n


## The player is paid up to [param amount] by [param from] (whole stones; Formula H's payers: a treasury, a commons
## pool, a lost stash). Off the continent (a world with no markets) the money is made, as built. Returns what was paid.
static func player_take(db: WorldDB, c: Character, from: String, amount: float, cause: String) -> int:
	if db.count(WorldEconomy.TABLE) == 0:
		var n: int = int(round(amount))
		c.linh_thach += n
		return n
	if from.ends_with(":"):   # no payer here (a place outside every market): nothing is paid
		return 0
	return int(MoneyLedger.new(db, c).transfer(from, PLAYER, amount, cause))


## The player pays [param amount] to [param to], or burns it when [param to] is "" (a sink: fees, works, fuel). The
## caller checks the purse first. Off the continent the money simply leaves. Returns what was paid.
static func player_pay(db: WorldDB, c: Character, to: String, amount: float, cause: String) -> int:
	if to.ends_with(":"):   # no payee here: the money is burned
		to = ""
	if db.count(WorldEconomy.TABLE) == 0 or to == "":
		var n: int = mini(int(amount), c.linh_thach)
		if db.count(WorldEconomy.TABLE) == 0:
			c.linh_thach -= n
			return n
		return int(MoneyLedger.new(db, c).burn(PLAYER, n, cause))
	return int(MoneyLedger.new(db, c).transfer(PLAYER, to, amount, cause))


## The great sect whose market holds [param place_id]'s region ("" for none).
static func market_sect_of(db: WorldDB, place_id: String) -> String:
	var place: Dictionary = db.get_record("places", place_id)
	var mid: String = WorldEconomy.market_of_region(db, db.get_record("regions", str(place.get("region_id", ""))))
	return "" if mid == "" else str(db.get_record(WorldEconomy.TABLE, mid).get("sect_id", ""))


## M: the money in the world, every holder but the player (Formula H).
func money_in_world() -> float:
	var m: float = 0.0
	for s in db.all("sects"):
		m += float(s.get("treasury", 0.0))
	for p in db.all("people"):
		if bool(p.get("alive", true)) and not bool(p.get("is_player", false)):   # the player's own record is outside M
			m += float(p.get("linh_thach", 0.0))
	for r in db.all(TABLE):
		if str(r.id) != BOOKS:
			m += float(r.get("balance", 0.0))
	return m


## Opens a season's books: notes M and clears the season's flows.
func open_season() -> void:
	var b: Dictionary = _books()
	b.minted = {}
	b.burned = {}
	b.moved = {}
	b.player_net = 0.0
	b.season_start_m = money_in_world()


## The season so far: {m_start, m_now, minted, burned, player_net, gap}; gap = ΔM − (minted − burned − player_net),
## 0 when every movement went through the ledger.
func season_check() -> Dictionary:
	var b: Dictionary = _books()
	var minted: float = 0.0
	for k in b.minted:
		minted += float(b.minted[k])
	var burned: float = 0.0
	for k in b.burned:
		burned += float(b.burned[k])
	var now: float = money_in_world()
	return {"m_start": float(b.season_start_m), "m_now": now, "minted": minted, "burned": burned,
		"player_net": float(b.player_net),
		"gap": (now - float(b.season_start_m)) - (minted - burned - float(b.player_net))}


## The season's books (minted, burned and moved by cause, the player's net take).
func books() -> Dictionary:
	return _books().duplicate(true)


func _books() -> Dictionary:
	if _b.is_empty():
		_b = db.get_record(TABLE, BOOKS)
	return _b


# [record, field] for a holder's balance, created on first use for pools and stashes; [] for an unknown holder.
func _slot(holder: String) -> Array:
	var hit = _slots.get(holder)
	if hit != null:
		return hit
	var at: Array = _find_slot(holder)
	if not at.is_empty():
		_slots[holder] = at
	return at


func _find_slot(holder: String) -> Array:
	var i: int = holder.find(":")
	if i < 0:
		return []
	var kind: String = holder.substr(0, i)
	var rid: String = holder.substr(i + 1)
	match kind:
		"sect":
			return [db.get_record("sects", rid), "treasury"] if db.has_record("sects", rid) else []
		"npc":
			return [db.get_record("people", rid), "linh_thach"] if db.has_record("people", rid) else []
		"pool", "stash":
			if not db.has_record(TABLE, holder):
				db.put(TABLE, {"id": holder, "balance": 0.0})
			return [db.get_record(TABLE, holder), "balance"]
	return []


func _add(holder: String, n: float) -> void:
	if holder == PLAYER:
		if player != null:
			player.linh_thach += int(n)
		return
	var at: Array = _slot(holder)
	if at.is_empty():
		push_error("MoneyLedger: unknown holder %s" % holder)
		return
	at[0][at[1]] = float(at[0].get(at[1], 0.0)) + n
