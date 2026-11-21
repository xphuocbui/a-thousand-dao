extends SceneTree
## World simulator: runs the living world headless for N years with no player and writes a chronicle (observation, not a
## verdict; .claude/docs/context-management.md): per decade the money in the world and its yearly change, the mine
## output, the world mean price by kind, the realm census, each great sect's levels, treasury, regions and vassals, and
## the politics of the decade (wars declared, won, failed, truces, rebellions, regions and sites changing hands, sects
## founded and fallen, works built). Health lines compare against the design's bands (Regional Economy AC-RE-37: ΔM a
## year -2 % to +5 %, world mean price 0.9-1.15; the census targets of design/gdd/canh-gioi.md) without judging.
##
##   Godot_console.exe --headless --path . -s res://tools/balance/world_sim.gd -- [--years 100] [--seed 11]
##       [--out res://production/qa/evidence/world-economy/sim-<seed>.md]

const KINDS := ["herb", "ore", "beast", "special", "pill", "talisman", "artifact"]
const EVENT_KINDS := ["sect_war", "sect_war_won", "sect_war_failed", "sect_truce", "vassal_rebellion", "rebellion_crushed",
	"vassal_new_lord", "territory_change", "sect_fallen", "sect_founded_new", "sect_pact", "sect_feud", "sect_works"]


func _arg(args: PackedStringArray, key: String, def: String) -> String:
	var i: int = args.find(key)
	return args[i + 1] if i >= 0 and i + 1 < args.size() else def


func _init() -> void:
	var args := OS.get_cmdline_user_args()
	var years: int = int(_arg(args, "--years", "100"))
	var seed_s: String = _arg(args, "--seed", "11")
	var out_path: String = _arg(args, "--out", "res://production/qa/evidence/world-economy/sim-%s.md" % seed_s)
	var gd := GameData.load_from("res://assets/data")
	gd.file("combat_rankings")["enabled"] = false
	var rng := RandomNumberGenerator.new()
	rng.seed = int(seed_s)
	var tree := DaoDoTree.load_map(gd)
	var t0: int = Time.get_ticks_msec()
	var builder := WorldBuilder.new(gd, tree)
	var db: WorldDB = builder.generate(rng, seed_s)
	var year: int = builder.current_year
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	var lines: Array = []
	lines.append("# World simulation, seed %s, %d years from year %d" % [seed_s, years, year])
	lines.append("")
	lines.append("Observation, not a verdict (tools/balance/world_sim.gd). World built in %.1f s." % (float(Time.get_ticks_msec() - t0) / 1000.0))
	lines.append("")
	var money := MoneyLedger.new(db)
	var m_prev: float = money.money_in_world()
	var seen_events: int = db.count("events")
	lines.append_array(_snapshot(gd, db, year, m_prev, m_prev, 0, {}))
	var minted_decade: float = 0.0
	var tick_ms: float = 0.0
	for y in years:
		for s in 4:
			var t1: int = Time.get_ticks_msec()
			ticker.tick(rng, year, s)
			tick_ms += float(Time.get_ticks_msec() - t1)
			minted_decade += float(money.season_check().minted)
		year += 1
		if (y + 1) % 10 == 0 or y + 1 == years:
			var m_now: float = money.money_in_world()
			var ev := _events_since(db, seen_events)
			seen_events = db.count("events")
			lines.append_array(_snapshot(gd, db, year, m_now, m_prev, minted_decade, ev))
			m_prev = m_now
			minted_decade = 0.0
			print("year %d done (%.0f ms a season)" % [year, tick_ms / float(4 * (y + 1))])
	lines.append("")
	lines.append("World tick: %.0f ms a season on average." % (tick_ms / float(4 * maxi(years, 1))))
	var f := FileAccess.open(out_path, FileAccess.WRITE)
	if f != null:
		f.store_string("\n".join(PackedStringArray(lines)) + "\n")
		f.close()
		print("chronicle written to %s" % out_path)
	quit()


# The events logged since index [param from]: {kind: [texts]}.
func _events_since(db: WorldDB, from: int) -> Dictionary:
	var out := {}
	var all: Array = db.all("events")
	for i in range(from, all.size()):
		var e: Dictionary = all[i]
		var k: String = str(e.get("type", ""))
		if EVENT_KINDS.has(k):
			if not out.has(k):
				out[k] = []
			out[k].append(str(e.get("text", "")))
	return out


func _snapshot(gd: GameData, db: WorldDB, year: int, m_now: float, m_prev: float, minted: float, ev: Dictionary) -> Array:
	var lines: Array = []
	lines.append("")
	lines.append("## Year %d" % year)
	var growth: float = 0.0 if m_prev <= 0.0 else pow(m_now / m_prev, 0.1) - 1.0
	lines.append("")
	lines.append("- **Money in the world:** %.0f (%+.1f %% a year over the decade; the design's band is -2 %% to +5 %%). Mines minted %.0f a season." % [m_now, growth * 100.0, minted / 40.0])
	# world mean price by kind, weighted by demand
	var pk := {}
	for m in db.find(WorldEconomy.TABLE, func(x): return str(x.id).begins_with("mk:")):
		for cid in m.classes:
			var c: Dictionary = m.classes[cid]
			_acc(pk, str(c.kind), float(c.p), float(c.d))
		for cid in m.get("crafted", {}):
			var cc: Dictionary = m.crafted[cid]
			_acc(pk, str(cc.kind), float(cc.p), float(cc.d))
	var pl: Array = []
	for k in KINDS:
		if pk.has(k):
			pl.append("%s %.2f" % [k, float(pk[k][0]) / maxf(float(pk[k][1]), 1e-9)])
	lines.append("- **World mean price** (demand-weighted; band 0.9-1.15): " + ", ".join(PackedStringArray(pl)))
	# census
	var census := [0, 0, 0, 0, 0]
	for p in db.all("people"):
		if bool(p.get("alive", false)) and not bool(p.get("is_beast", false)) and not bool(p.get("is_player", false)):
			census[clampi(int(p.get("realm_index", 0)), 0, 4)] += 1
	var gained := {}   # NPC Traits: gained traits held now (F6's steady state: about 1,000 held, 18 % of people)
	var holders: int = 0
	for p in db.living():
		var g: Array = p.get("npc_traits", {}).get("gained", [])
		if not g.is_empty():
			holders += 1
		for e in g:
			gained[str(e.id)] = int(gained.get(str(e.id), 0)) + 1
	lines.append("- **Gained traits:** %d people hold one or more; %s" % [holders, str(gained)])
	lines.append("- **Census** (Luyện Khí / Trúc Cơ / Kết Đan / Nguyên Anh / Hóa Thần; targets about 3,936 / 844 / 191 / 27 / 3): %s" % " / ".join(PackedStringArray(census.map(func(x): return str(x)))))
	# great sects
	lines.append("- **Great sects:**")
	for s in db.find("sects", func(x): return str(x.get("kind", "")) == "great"):
		var regs: int = db.find("regions", func(r): return str(r.get("holder", "")) == str(s.id)).size()
		var vass: int = SectEconomy.vassals(db, s).size()
		var lv: Dictionary = s.get("levels", {})
		lines.append("  - %s (%s): levels H %d / I %d / M %d / T %d, treasury %.0f, %d regions, %d vassals, %s%s" % [s.name, str(s.get("status", "")),
			int(lv.get("holdings", 0)), int(lv.get("institutions", 0)), int(lv.get("military", 0)), int(lv.get("trade", 0)),
			float(s.get("treasury", 0.0)), regs, vass, str(s.get("state", "")), ", at war with " + ", ".join(PackedStringArray(Array(s.get("wars", [])).map(func(x): return str(db.get_record("sects", str(x)).get("name", x))))) if not Array(s.get("wars", [])).is_empty() else ""])
	var minors: Array = db.find("sects", func(x): return str(x.get("kind", "")) == "minor" and str(x.get("status", "")) == "active")
	var states := {}
	for v in minors:
		states[str(v.get("loyalty_state", ""))] = int(states.get(str(v.get("loyalty_state", "")), 0)) + 1
	lines.append("- **Minor sects:** %d active; loyalty %s" % [minors.size(), str(states)])
	if not ev.is_empty():
		lines.append("- **The decade's politics:**")
		for k in EVENT_KINDS:
			if not ev.has(k):
				continue
			var texts: Array = ev[k]
			if k == "sect_works":
				lines.append("  - %d works built" % texts.size())
				continue
			lines.append("  - %s (%d): %s" % [k, texts.size(), "; ".join(PackedStringArray(texts.slice(0, 6)))])
	return lines


func _acc(d: Dictionary, k: String, p: float, w: float) -> void:
	if not d.has(k):
		d[k] = [0.0, 0.0]
	d[k][0] += p * maxf(w, 1e-6)
	d[k][1] += maxf(w, 1e-6)
