class_name SectEconomy
extends RefCounted

## The sects' development and money (design/gdd/sects.md rules 4, 8-10; Formulas F1, F2, F4, F17, F19; Regional
## Economy & Trade Formula H's treasury rule): four tracks whose levels come from what was invested in them, upkeep
## each season (its goods share met in kind, its cash share burned), tribute from vassal to lord, the track the
## season's investment goes to, and the members a seat takes in. Values are sects_members.json's [code]economy[/code]
## block; money moves through [MoneyLedger].
##
## A sect record keeps [code]invested[/code] (C_own per track, F1) and [code]levels[/code] (the level the investment
## buys, floor of F1's inverse); a great sect's effective level counts half its vassals' investment
## ([method effective_level]).
##
## Usage:
## [codeblock]
## SectEconomy.seed_investment(gd, db)               # once, at world generation
## SectEconomy.season(gd, db, money)                 # each season, before WorldMoney's treasury rule
## [/codeblock]

const TRACKS := ["holdings", "institutions", "military", "trade"]


static func _cfg(gd: GameData) -> Dictionary:
	return gd.file("sects_members").get("economy", {})


## F1: the cost of level [param level] of [param track].
static func level_cost(gd: GameData, track: String, level: int) -> float:
	var c: Dictionary = _cfg(gd)
	return float(c.c0[track]) * pow(float(c.g), level - 1)


## F1: the total invested to reach [param level].
static func total_cost(gd: GameData, track: String, level: float) -> float:
	var c: Dictionary = _cfg(gd)
	var g: float = float(c.g)
	return float(c.c0[track]) * (pow(g, level) - 1.0) / (g - 1.0)


## F1's inverse: the (real) level [param invested] buys; floor it for the sect's own level.
static func level_of(gd: GameData, track: String, invested: float) -> float:
	var c: Dictionary = _cfg(gd)
	var g: float = float(c.g)
	return log(1.0 + (g - 1.0) * maxf(0.0, invested) / float(c.c0[track])) / log(g)


## F1: a great sect's effective level, its own investment plus w_v of its vassals'.
static func effective_level(gd: GameData, db: WorldDB, sect: Dictionary, track: String) -> float:
	var own: float = float(sect.get("invested", {}).get(track, 0.0))
	var vass: float = 0.0
	for v in vassals(db, sect):
		vass += float(v.get("invested", {}).get(track, 0.0))
	return level_of(gd, track, own + float(_cfg(gd).w_v) * vass)


## The active vassals of a great sect (minor sects whose lord it is).
static func vassals(db: WorldDB, sect: Dictionary) -> Array:
	return db.find("sects", func(s): return str(s.get("lord_id", "")) == str(sect.id) and str(s.get("status", "")) == "active")


## F1: a season's upkeep of every track, u · C.
static func upkeep(gd: GameData, sect: Dictionary) -> float:
	var u: float = float(_cfg(gd).u)
	var t: float = 0.0
	for tr in TRACKS:
		t += u * float(sect.get("invested", {}).get(tr, 0.0))
	return t


## Once at world generation: each sect's investment is what its authored levels cost (F1), so the levels are its own.
static func seed_investment(gd: GameData, db: WorldDB) -> void:
	for s in db.all("sects"):
		var inv := {}
		for tr in TRACKS:
			inv[tr] = total_cost(gd, tr, float(s.get("levels", {}).get(tr, 0)))
		s["invested"] = inv
		s["spend"] = {}
		for tr in TRACKS:   # last season's track spending (Regional Economy Formula C): upkeep at the start
			s.spend[tr] = float(_cfg(gd).u) * float(inv[tr])
		if not s.has("dials"):
			s["dials"] = Dictionary(gd.file("sects_members").get("default_dials", {})).duplicate()


## F19: the track a season's investment goes to.
static func invest_track(gd: GameData, sect: Dictionary, first_track: String = "") -> String:
	var c: Dictionary = _cfg(gd)
	var recent: Dictionary = sect.get("track_trouble", {})
	for tr in TRACKS:
		if int(recent.get(tr, 0)) > 0:
			return tr
	var inv: Dictionary = sect.get("invested", {})
	var total: float = 0.0
	for tr in TRACKS:
		total += float(inv.get(tr, 0.0))
	var war: int = int(sect.get("dials", {}).get("war_readiness", 2))
	var mil: float = clampf(float(c.mix_military_base) + float(c.mix_military_step) * (war - 2), float(c.mix_military_min), float(c.mix_military_max))
	var rest: Dictionary = c.mix_rest
	var rest_sum: float = 0.0
	for tr in rest:
		rest_sum += float(rest[tr])
	if total <= 0.0 and TRACKS.has(first_track):
		return first_track
	var best_d: float = -INF
	var dd := {}
	for tr in TRACKS:
		var mix: float = mil if tr == "military" else (1.0 - mil) * float(rest.get(tr, 0.0)) / maxf(rest_sum, 1e-9)
		var share: float = 0.0 if total <= 0.0 else float(inv.get(tr, 0.0)) / total
		dd[tr] = mix - share
		best_d = maxf(best_d, float(dd[tr]))
	var tied: Array = TRACKS.filter(func(tr): return float(dd[tr]) >= best_d - 1e-9)
	if tied.size() == 1:
		return str(tied[0])
	if tied.has(first_track):
		return first_track
	var best: String = str(tied[0])   # the cheapest next level among the tied tracks
	var best_c: float = INF
	for tr in tied:
		var lv: int = int(floor(level_of(gd, tr, float(inv.get(tr, 0.0)))))
		var cost: float = total_cost(gd, tr, lv + 1) - total_cost(gd, tr, lv)
		if cost < best_c - 1e-9:
			best_c = cost
			best = tr
	return best


## F2's seat capacity: cap_base · (1 + i · I), rounded down.
static func capacity(gd: GameData, db: WorldDB, sect: Dictionary) -> int:
	var c: Dictionary = _cfg(gd)
	var base: float = float(c.cap_base.great if str(sect.get("kind", "")) == "great" else c.cap_base.minor)
	var i_lv: float = effective_level(gd, db, sect, "institutions") if str(sect.get("kind", "")) == "great" else float(sect.get("levels", {}).get("institutions", 0))
	return int(floor(base * (1.0 + float(c.i) * i_lv) + 1e-6))   # the inverse of F1 lands a hair under whole levels


## One season of every active sect: upkeep (goods share in kind, cash share burned; two unpaid seasons drop a level),
## tribute from vassal to lord (F4), and the members' count for intake (F17). Returns {upkeep_cash, tribute}.
static func season(gd: GameData, db: WorldDB, money: MoneyLedger) -> Dictionary:
	var c: Dictionary = _cfg(gd)
	var gf: float = float(gd.file(WorldEconomy.FILE).demand.goods_frac)
	var out := {"upkeep_cash": 0.0, "tribute": 0.0}
	for s in db.all("sects"):
		if str(s.get("status", "")) != "active" or not s.has("invested"):
			continue
		var t: String = "sect:%s" % str(s.id)
		var up: float = upkeep(gd, s)
		var spend := {}   # this season's track spending: upkeep now, the investment added by the treasury rule
		_note_mil(gd, s)
		for tr in TRACKS:
			spend[tr] = float(c.u) * float(s.invested.get(tr, 0.0))
		s["spend"] = spend
		var cash_due: float = up * (1.0 - gf)
		var paid: float = money.burn(t, cash_due, "upkeep")
		s["kind_due"] = float(s.get("kind_due", 0.0)) + up * gf
		s["cash_costs"] = paid
		out.upkeep_cash = float(out.upkeep_cash) + paid
		var trouble: Dictionary = s.get("track_trouble", {})
		for tr in TRACKS:
			trouble[tr] = maxi(0, int(trouble.get(tr, 0)) - 1)
		if paid + 1e-6 < cash_due:
			s["unpaid"] = int(s.get("unpaid", 0)) + 1
			if int(s.unpaid) >= int(c.unpaid_seasons_to_fall):   # F1: two unpaid seasons drop the costliest track a level
				var top: String = TRACKS[0]
				for tr in TRACKS:
					if float(s.invested.get(tr, 0.0)) > float(s.invested.get(top, 0.0)):
						top = tr
				var lv: int = int(floor(level_of(gd, top, float(s.invested[top]))))
				s.invested[top] = total_cost(gd, top, maxi(0, lv - 1))
				trouble[top] = int(c.trouble_seasons)
				s["unpaid"] = 0
		else:
			s["unpaid"] = 0
		s["track_trouble"] = trouble
		_refresh_levels(gd, s)
	for v in db.all("sects"):   # F4: tribute, vassal to lord, on the vassal's income before costs
		if str(v.get("status", "")) != "active" or str(v.get("lord_id", "")) == "":
			continue
		var lord: Dictionary = db.get_record("sects", str(v.lord_id))
		if lord.is_empty() or str(lord.get("status", "")) != "active":
			continue
		var tax: int = int(lord.get("dials", {}).get("tax", 2))
		var rate: float = float(c.r_floor) + (float(c.r_ceil) - float(c.r_floor)) * tax / 4.0
		var gross: float = float(v.get("gross_income", 0.0))
		var due: float = rate * gross * float(c.pay_by_state.get(str(v.get("loyalty_state", "loyal")), 1.0))
		var moved: float = money.transfer("sect:%s" % v.id, "sect:%s" % lord.id, due, "tribute")
		v["cash_costs"] = float(v.get("cash_costs", 0.0)) + moved
		out.tribute = float(out.tribute) + moved
	return out


## Trade Goods H's spend_Mil (Regional Economy C's spend_T for Military): the mean of the last `mil_window` committed
## seasons of Military spending, fewer at the start of a game. Read before this season's spending is reset (the markets
## read last season's committed values).
static func mil_spend_mean(sect: Dictionary) -> float:
	var hist: Array = sect.get("mil_hist", [])
	var t: float = float(sect.get("spend", {}).get("military", 0.0))
	for v in hist:
		t += float(v)
	return t / float(hist.size() + 1)


# Keeps the committed Military spending of the seasons before last (mil_window − 1 of them) before a season resets it.
static func _note_mil(gd: GameData, s: Dictionary) -> void:
	var n: int = int(gd.file(WorldEconomy.FILE).demand.get("mil_window", 1)) - 1
	if n <= 0:
		return
	var hist: Array = s.get("mil_hist", [])
	hist.push_front(float(s.get("spend", {}).get("military", 0.0)))
	s["mil_hist"] = hist.slice(0, n)


## Adds a season's track investment (the treasury rule's track share) to the track F19 picks and refreshes its level.
static func invest(gd: GameData, sect: Dictionary, amount: float, first_track: String = "") -> String:
	if amount <= 0.0 or not sect.has("invested"):
		return ""
	var tr: String = invest_track(gd, sect, first_track)
	sect.invested[tr] = float(sect.invested.get(tr, 0.0)) + amount
	if not sect.has("spend"):
		sect["spend"] = {}
	sect.spend[tr] = float(sect.spend.get(tr, 0.0)) + amount
	_refresh_levels(gd, sect)
	return tr


static func _refresh_levels(gd: GameData, sect: Dictionary) -> void:
	var lv: Dictionary = sect.get("levels", {})
	for tr in TRACKS:
		lv[tr] = int(floor(level_of(gd, tr, float(sect.invested.get(tr, 0.0))) + 1e-9))
	sect["levels"] = lv


## F17: Luyện Khí members a sect takes in this season.
static func intake(gd: GameData, db: WorldDB, sect: Dictionary, members: int) -> int:
	var c: Dictionary = _cfg(gd)
	var target: float = float(c.intake_target) * capacity(gd, db, sect)
	if members >= target:
		return 0
	var rec: int = clampi(int(sect.get("dials", {}).get("recruitment", 2)), 0, 4)
	return int(round(float(c.rec_k[rec]) * (target - members)))
