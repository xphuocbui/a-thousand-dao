class_name TerminalViews
extends RefCounted
## Text renderers for the debug terminal. Each returns an Array of lines and never
## changes game state. Colour comes from [TerminalIO.paint] (element ANSI codes in data).
##
## Usage:
## [codeblock]
## io.out_lines(TerminalViews.sheet(session, io))
## io.out_lines(TerminalViews.tree_map(session, io))
## [/codeblock]


## Display width of every boxed view (columns).
const WIDTH := 78
## ANSI codes used by the views (element colours come from data).
const C_BOLD := "1"
const C_DIM := "2"
const C_RED := "31"
const C_GREEN := "32"
const C_YELLOW := "33"
const C_CYAN := "36"
const C_MAGENTA := "35"
const SEVERITY_STYLE := {"urgent": ["‼", "1;31"], "warn": ["!", "33"], "goal": ["➤", "36"], "tip": ["·", "2"]}


## Heads-up display: who, when, where, progress bars and the most pressing goals.
static func hud(s: GameSession, io: TerminalIO) -> Array:
	var c: Character = s.player
	var gd: GameData = s.gd
	var sh: StatSheet = s.sheet()
	var place: Dictionary = s.db.get_record("places", c.location_id)
	var prog: Dictionary = Advisor.progress(s)
	var life: float = CultivationRules.lifespan(c, gd, sh).total
	var lines: Array = []
	lines.append(rule(io, "%s · %s · %s" % [c.name, s.clock_label(), place.get("name", "?")], "━"))
	var tv_frac: float = clampf(c.tu_vi / maxf(float(prog.requirement), 1.0), 0.0, 1.0)
	var eta: String
	if bool(prog.bottleneck):
		eta = io.paint("BÌNH CẢNH", "1;33")
	elif int(prog.seasons_to_stage) >= 0:
		eta = "+%.1f/season, next tầng in %s" % [prog.rate, _seasons_text(int(prog.seasons_to_stage), int(gd.cultivation_rules().seasons_per_year))]
	else:
		eta = "no progress here"
	lines.append(" %s  %s %.0f/%.0f  %s" % [io.paint("%-22s" % gd.realm_label(c.realm_index, c.stage), C_BOLD), bar(io, tv_frac, 16, C_CYAN, true), c.tu_vi, prog.requirement, eta])
	var age_frac: float = clampf(c.age / maxf(life, 1.0), 0.0, 1.0)
	var age_col: String = C_GREEN if age_frac < 0.6 else (C_YELLOW if age_frac < 0.85 else C_RED)
	var kh_col: String = C_RED if c.vitality < 0.3 else (C_YELLOW if c.vitality < 0.6 else C_GREEN)
	var extras: PackedStringArray = []
	extras.append("LT %d" % c.linh_thach)
	extras.append("Chiến lực %.0f" % CombatPower.compute(c, gd, s.db, sh).total)
	if c.tree_points > 0:
		extras.append(io.paint("%d Kinh Mạch pt" % c.tree_points, C_MAGENTA))
	if c.dan_doc >= 1.0:
		extras.append("Đan độc %.0f" % c.dan_doc)
	if c.tam_ma >= 1.0:
		extras.append("Tâm ma %.0f" % c.tam_ma)
	lines.append(" Tuổi %3d/%-4d %s  Khí huyết %s %3d%%  %s" % [int(c.age), int(life), bar(io, age_frac, 10, age_col, true), bar(io, c.vitality, 10, kh_col, true), int(c.vitality * 100.0), " · ".join(extras)])
	var shown: int = 0
	for g in Advisor.goals(s):
		if g.severity == "tip" or g.id == "event" or shown >= 2:
			continue
		lines.append_array(goal_lines(io, g))
		shown += 1
	return lines


## A goal as one or more wrapped lines with its severity marker.
static func goal_lines(io: TerminalIO, g: Dictionary) -> Array:
	var st: Array = SEVERITY_STYLE.get(g.severity, ["·", ""])
	var hint: String = ("  → " + io.paint(g.command, C_BOLD)) if g.command != "" else ""
	var wrapped: Array = wrap_text(str(g.text), WIDTH - 4)
	var out: Array = []
	for i in wrapped.size():
		var head: String = (" %s " % io.paint(st[0], st[1])) if i == 0 else "   "
		out.append(head + io.paint(wrapped[i], st[1] if g.severity != "tip" else "") + (hint if i == wrapped.size() - 1 else ""))
	return out


## Every goal, most severe first ('goals' command).
static func goals(s: GameSession, io: TerminalIO) -> Array:
	var gl: Array = Advisor.goals(s)
	if gl.is_empty():
		return ["Nothing pressing. Cultivate, explore, or plan your Kinh Mạch Đồ."]
	var lines: Array = [io.paint("What matters now", C_BOLD)]
	for g in gl:
		lines.append_array(goal_lines(io, g))
	return lines


## Numbered menu. Goal entries get a line each, the rest share two columns.
static func menu(io: TerminalIO, actions: Array) -> Array:
	if actions.is_empty():
		return []
	var lines: Array = []
	var row: PackedStringArray = []
	for i in actions.size():
		var a: Dictionary = actions[i]
		var num: String = io.paint("%2d" % (i + 1), C_BOLD)
		if a.group == "goal" or a.group == "event":
			if not row.is_empty():
				lines.append(" ".join(row))
				row.clear()
			lines.append(" %s %s" % [num, io.paint(str(a.label), C_CYAN) if a.group == "goal" else str(a.label)])
			continue
		var label: String = str(a.label)
		if label.length() > 34:
			label = label.substr(0, 33) + "…"
		row.append(" %s %s" % [num, label + " ".repeat(maxi(34 - label.length(), 0))])
		if row.size() == 2:
			lines.append(" ".join(row).strip_edges(false, true))
			row.clear()
	if not row.is_empty():
		lines.append(" ".join(row).strip_edges(false, true))
	lines.append(io.paint(" Type a number, or any command ('help'). Enter shows this menu again.", C_DIM))
	return lines


## What the last command changed, as one or more wrapped lines.
static func changes(io: TerminalIO, diff: Array) -> Array:
	if diff.is_empty():
		return []
	var parts: PackedStringArray = []
	for ch in diff:
		var col: String = ""
		match str(ch.key):
			"time":
				col = C_DIM
			"realm", "skill_dan_dao", "items_gained":
				col = C_GREEN
			"items_lost":
				col = C_YELLOW
			"alive":
				col = "1;31"
			"location":
				col = C_CYAN
			_:
				if typeof(ch.from) in [TYPE_FLOAT, TYPE_INT] and typeof(ch.to) in [TYPE_FLOAT, TYPE_INT]:
					var good: bool = float(ch.to) > float(ch.from)
					if str(ch.key) in ["dan_doc", "tam_ma"]:
						good = not good
					col = C_GREEN if good else C_RED
		parts.append(io.paint(str(ch.text), col))
	var plain: PackedStringArray = []
	for ch in diff:
		plain.append(str(ch.text))
	# Wrap on the plain text, then paint each chunk (colours never split mid-word).
	var lines: Array = []
	var cur: PackedStringArray = []
	var width: int = 2
	for i in parts.size():
		var w: int = plain[i].length() + 3
		if width + w > WIDTH and not cur.is_empty():
			lines.append(" " + io.paint("Δ", C_BOLD) + " " + " · ".join(cur) if lines.is_empty() else "   " + " · ".join(cur))
			cur.clear()
			width = 2
		cur.append(parts[i])
		width += w
	if not cur.is_empty():
		lines.append(" " + io.paint("Δ", C_BOLD) + " " + " · ".join(cur) if lines.is_empty() else "   " + " · ".join(cur))
	return lines


## A horizontal rule with a title.
static func rule(io: TerminalIO, title: String, ch: String = "─") -> String:
	var head: String = ch.repeat(2) + " " + title + " "
	return io.paint(head + ch.repeat(maxi(WIDTH - head.length(), 3)), C_DIM if ch == "─" else "")


## A filled bar of [param width] cells for a 0..1 fraction. [param stacked] uses
## shorter glyphs so bars on consecutive lines stay visually separate.
static func bar(io: TerminalIO, frac: float, width: int, ansi: String, stacked: bool = false) -> String:
	var f: float = clampf(frac, 0.0, 1.0)
	var full: int = int(roundf(f * float(width)))
	if f > 0.0 and full == 0:
		full = 1
	var fill: String = "▆" if stacked else "█"
	var empty: String = "▁" if stacked else "░"
	return io.paint(fill.repeat(full), ansi) + io.paint(empty.repeat(width - full), C_DIM)


## ANSI colour for a 1-100 value by its grade band (Hạ red ... Thiên magenta).
static func grade_color(gd: GameData, value: float) -> String:
	var bands: Array = gd.attributes().get("grade_bands", [])
	var palette: Array = [C_RED, C_YELLOW, C_GREEN, C_CYAN, C_MAGENTA]
	for i in bands.size():
		if value <= float(bands[i].max):
			return palette[mini(i, palette.size() - 1)]
	return C_MAGENTA


## Word-wraps text to [param width] columns (keeps existing line breaks).
static func wrap_text(text: String, width: int) -> Array:
	var out: Array = []
	for para in text.split("\n"):
		var line: String = ""
		for word in para.split(" ", false):
			if line == "":
				line = word
			elif line.length() + 1 + word.length() <= width:
				line += " " + word
			else:
				out.append(line)
				line = word
		out.append(line)
	return out


static func _seasons_text(n: int, per_year: int) -> String:
	if n <= per_year:
		return "%d season%s" % [n, "" if n == 1 else "s"]
	return "%.1f years" % (float(n) / float(per_year))


## Short one-line status for the prompt area.
static func status_line(s: GameSession) -> String:
	var c: Character = s.player
	var sh: StatSheet = s.sheet()
	var place: Dictionary = s.db.get_record("places", c.location_id)
	return "[%s | %s | %s %.0f/%.0f | tuổi %d/%d | KH %d%% | LT %d | %s%s]" % [
		s.clock_label(), c.name, s.gd.realm_label(c.realm_index, c.stage), c.tu_vi, CultivationRules.stage_requirement(c, s.gd),
		int(c.age), int(CultivationRules.lifespan(c, s.gd, sh).total), int(c.vitality * 100.0), c.linh_thach, place.get("name", "?"),
		" | EVENT" if s.has_pending_event() else ""]


## Full character sheet (game-concept.md § Character Stats example layout).
static func sheet(s: GameSession, io: TerminalIO) -> Array:
	var c: Character = s.player
	var gd: GameData = s.gd
	var sh: StatSheet = s.sheet()
	var lines: Array = []
	var life: float = CultivationRules.lifespan(c, gd, sh).total
	var origin: Dictionary = gd.origin(c.origin)
	var sect: Dictionary = s.db.get_record("sects", c.sect_id)
	lines.append(rule(io, "%s — %s%s" % [c.name, gd.realm_label(c.realm_index, c.stage), "" if c.alive else " (đã mất)"], "━"))
	lines.append(" Tuổi %d / %d · Xuất thân %s · Tông môn %s%s · %s" % [int(c.age), int(life), origin.get("name", c.origin), sect.get("name", "—"),
		(" (%s)" % c.sect_rank) if c.sect_rank != "" else "", "Thiên Định (achievements on)" if c.birth_mode == "thien_dinh" else "Tự Định (casual)"])
	lines.append("")
	lines.append(io.paint(" LINH CĂN", C_BOLD) + "  %s — %d element(s) count for the speed curve, now x%.2f vs Đơn linh căn" % [c.linh_can.tier_name(), c.linh_can.counted_elements(gd), CultivationRules.curve_factor(c, gd)])
	for e in gd.element_cycle():
		var p: float = c.linh_can.purity(e)
		var el: Dictionary = gd.element(e)
		var name_txt: String = elem(io, gd, e, "%-4s" % gd.element_name(e))
		var val: String = ("%3d %-8s" % [int(p), gd.grade_name(p)]) if p > 0.0 else io.paint("  —         ", C_DIM)
		var role: String = io.paint(str(el.get("role_desc", "")), C_DIM if p <= 0.0 else "")
		lines.append("   %s %s %s %s" % [name_txt, bar(io, p / 100.0, 20, str(el.get("ansi", "")), true), val, role])
	if not c.linh_can.bien_di.is_empty():
		for id in c.linh_can.bien_di.keys():
			var def: Dictionary = gd.bien_di(id)
			lines.append("   %s %d  (%s)  %s" % [io.paint("Biến dị " + str(def.name), C_MAGENTA), int(c.linh_can.bien_di[id]), " × ".join(def.parents.map(func(x): return gd.element_name(x))), ", ".join(def.get("effects", []).map(func(fx): return gd.format_mod(str(fx.stat), float(fx.value))))])
	lines.append("")
	lines.append(io.paint(" THIÊN PHÚ", C_BOLD))
	var defs: Array = gd.thien_phu_defs()
	var cells: Array = []
	for def in defs:
		var v: float = sh.effective(def.id, c)
		var bonus: int = int(v) - c.base_stat(def.id)
		var bonus_txt: String = io.paint("%+d" % bonus, C_GREEN if bonus > 0 else C_RED) if bonus != 0 else "  "
		cells.append("%-9s %s %3d %-8s%s" % [def.name, bar(io, v / 100.0, 10, grade_color(gd, v), true), int(v), io.paint("%-8s" % gd.grade_name(v), grade_color(gd, v)), bonus_txt])
	for i in range(0, cells.size(), 2):
		lines.append(("   " + cells[i] + ("   " + cells[i + 1] if i + 1 < cells.size() else "")).strip_edges(false, true))
	lines.append("")
	var kh: float = CharacterRules.khi_huyet_max(c, gd, sh).total
	lines.append(io.paint(" TRẠNG THÁI", C_BOLD) + " Linh lực %.0f · Thần thức %.0f · Khí huyết %.0f/%.0f" % [CharacterRules.linh_luc(c, gd, s.db, sh).total, CharacterRules.than_thuc(c, gd, sh).total, kh * c.vitality, kh])
	lines.append("            Đan độc %.0f (pills -%d%%) · Tâm ma %.0f (backlash %.0f%%) · Linh thạch %d" % [c.dan_doc, int(c.dan_doc), c.tam_ma, CultivationRules.backlash_chance(c, gd, sh).total, c.linh_thach])
	var cp: Dictionary = s.db.get_record("items", c.cong_phap_id)
	var rate: float = CultivationRules.rate_per_season(c, gd, s.db, sh, float(s.db.get_record("places", c.location_id).get("density", 1.0))).total
	lines.append(io.paint(" CÔNG PHÁP", C_BOLD) + "  %s" % (s.items.describe(cp) if not cp.is_empty() else "none"))
	lines.append("            tu vi %.1f per season here ('explain rate')" % rate)
	var skills: PackedStringArray = []
	for k in c.skills.keys():
		skills.append("%s level %d" % [k, int(c.skills[k].level)])
	lines.append(io.paint(" ĐẠO NGHỆ", C_BOLD) + "   %s" % (", ".join(skills) if not skills.is_empty() else "none yet (practice raises them)"))
	var power: Dictionary = CombatPower.compute(c, gd, s.db, sh)
	lines.append(io.paint(" CHIẾN LỰC", C_BOLD) + "  %.0f = offense %.0f + defense %.0f · thần thức %.0f/%.0f carried ('explain power')" % [power.total, power.offense, power.defense, power.than_thuc_used, power.than_thuc_capacity])
	lines.append(io.paint(" KINH MẠCH", C_BOLD) + "  %d huyệt open, %d point(s) unspent ('tree')" % [c.tree_nodes.size(), c.tree_points])
	if not c.perks.is_empty():
		var pk: PackedStringArray = []
		for id in c.perks:
			var p: Dictionary = ProgressionEdges.perk(gd, str(id))
			pk.append("%s — %s" % [p.get("name", id), p.get("desc", "")])
		lines.append(io.paint(" THIÊN MỆNH", C_BOLD) + " " + "; ".join(pk))
	elif not s.edge:
		lines.append(io.paint(" THIÊN MỆNH", C_BOLD) + io.paint(" none (a life without the edge)", C_DIM))
	lines.append(io.paint(" 'explain <stat>' breaks down any number: rate, power, life, breakthrough, ngo_tinh, attack_pct …", C_DIM))
	return lines


## Breakdown of any derived number or stat key.
static func explain(s: GameSession, what: String) -> Array:
	var c: Character = s.player
	var gd: GameData = s.gd
	var sh: StatSheet = s.sheet()
	var density: float = float(s.db.get_record("places", c.location_id).get("density", 1.0))
	match what:
		"rate", "tu_vi", "cultivation":
			return Array(CultivationRules.rate_per_season(c, gd, s.db, sh, density).lines())
		"power", "chien_luc":
			return Array(CombatPower.compute(c, gd, s.db, sh).lines)
		"life", "lifespan", "tho_nguyen":
			return Array(CultivationRules.lifespan(c, gd, sh).lines())
		"than_thuc":
			return Array(CharacterRules.than_thuc(c, gd, sh).lines())
		"khi_huyet":
			return Array(CharacterRules.khi_huyet_max(c, gd, sh).lines())
		"linh_luc":
			return Array(CharacterRules.linh_luc(c, gd, s.db, sh).lines())
		"herb", "herb_growth":
			return Array(CharacterRules.herb_growth(c, gd, sh).lines())
		"plots", "field":
			return Array(CharacterRules.field_plots(c, gd, sh).lines())
		"dan_doc":
			return Array(CharacterRules.dan_doc_decay(c, gd, sh).lines())
		"mission":
			return Array(CharacterRules.mission_income(c, gd, sh).lines())
		"breakthrough", "bt":
			return Array(CultivationRules.breakthrough_chance(c, gd, sh, 0).lines()) + ["(shown with a phẩm 0 pill; without one the base is lower)"]
		"backlash":
			return Array(CultivationRules.backlash_chance(c, gd, sh).lines())
		"refine", "luyen_khi":
			return Array(s.refinery.success_chance(c, sh, c.realm_index).lines()) + ["(%s; fuel per design: 'refine' lists them)" % gd.artifact_tier(c.realm_index).name]
		"upkeep", "formation":
			return formations(s, TerminalIO.new())
	for def in gd.thien_phu_defs():
		if what == def.id:
			return Array(sh.explain_thien_phu(def.id, c, def.name).lines())
	var src: Array = sh.sources(what)
	if src.is_empty():
		return ["No modifiers for '%s'. Try: rate, power, life, than_thuc, khi_huyet, linh_luc, herb, plots, dan_doc, mission, breakthrough, backlash, a thiên phú id, or a stat key (%s)." % [what, ", ".join(sh.stat_keys())]]
	var lines: Array = ["%s = %.2f" % [what, sh.total(what)]]
	for m in src:
		lines.append("    %+.2f  %s" % [float(m.value), m.source])
	return lines


## Thành tựu: every achievement, earned ones with the life that earned them.
static func achievements(s: GameSession, book: Achievements, io: TerminalIO) -> Array:
	var all: Array = book.all()
	var got: int = all.filter(func(a): return book.store.has(str(a.id))).size()
	var lines: Array = [io.paint("Thành tựu", C_BOLD) + " · %d / %d earned across lives" % [got, all.size()]]
	if s != null and s.player != null:
		if not Achievements.enabled_for(s.player):
			lines.append(io.paint("  This is a Tự Định (casual) life: it earns none.", C_YELLOW))
		elif s.cheated:
			lines.append(io.paint("  Debug commands were used in this life: it earns none.", C_YELLOW))
	for a in all:
		if book.store.has(str(a.id)):
			var info: Dictionary = book.store.earned[a.id]
			lines.append("  %s %-22s %s  (%s, năm %d)" % [io.paint("★", "1;35"), a.name, a.desc, str(info.get("life", "?")), int(info.get("year", 0))])
		else:
			lines.append(io.paint("  · %-22s %s" % [a.name, a.desc], C_DIM))
	return lines


## Linh thú: owned beasts with realm, power share, loyalty and feeding.
static func beasts(s: GameSession, io: TerminalIO) -> Array:
	var c: Character = s.player
	var k: BeastKeeper = s.beasts
	var sh: StatSheet = s.sheet()
	var lines: Array = [io.paint("Linh thú", C_BOLD) + " · %d / %d kept (Thần hồn) · Ngự thú level %d · feeding %d LT/year" % [c.beasts.size(), k.capacity(c, sh), c.skill_level(str(k.config().skill)), k.feed_cost(c)]]
	var owned: Array = k.owned(c)
	if owned.is_empty():
		lines.append(io.paint("  None yet. Beat a yêu thú in an event and you may tame it (%.0f%% now)." % (k.tame_chance(c, sh, "").total * 100.0), C_DIM))
	var share: float = float(k.config().power_share)
	for b in owned:
		var loy: float = float(b.get("loyalty", 0)) / float(k.config().loyalty.max)
		var col: String = C_GREEN if loy >= 0.6 else (C_YELLOW if loy >= 0.3 else C_RED)
		lines.append("  %-6s %-18s %-22s chiến lực %6.0f (+%.0f to yours)  loyalty %s %d" % [b.id, b.name, s.gd.realm_label(int(b.realm_index), int(b.stage)), float(b.get("power", 0.0)), float(b.get("power", 0.0)) * share, bar(io, loy, 10, col, true), int(b.get("loyalty", 0))])
	lines.append(io.paint(" Beasts grow every season, fight beside you, and leave if left hungry. 'release <id>' lets one go.", C_DIM))
	return lines


## Trận pháp at the động phủ: levels, effects, next cost, upkeep.
static func formations(s: GameSession, io: TerminalIO) -> Array:
	var c: Character = s.player
	var f: Formations = s.formations
	var skill_id: String = str(f.config().skill)
	var cut: float = clampf(c.linh_can.purity("tho") * float(f.config().tho_upkeep_cut_per_purity), 0.0, 0.9)
	var lines: Array = [io.paint("Trận pháp at %s" % s.db.get_record("places", c.home_id).get("name", "?"), C_BOLD)
		+ " · Trận pháp level %d · upkeep %d LT/year (Thổ cuts %d%%)" % [c.skill_level(skill_id), f.upkeep(c), int(cut * 100.0)]]
	for d in f.config().formations:
		var lv: int = f.level(c, d.id)
		var cost: Dictionary = f.build_cost(d.id, lv + 1)
		var now: String = s.gd.format_mod(str(d.stat), float(d.per_level) * float(lv)) if lv > 0 else io.paint("not built", C_DIM)
		var where: String = " (at home)" if str(d.applies) == "home" else ""
		var next: String = "max" if lv >= int(d.max_level) else "next %d LT + %d material(s) ≥ rarity %d" % [int(cost.lt), int(cost.materials), int(cost.rarity)]
		lines.append("  %-15s %s %d/%d  %s%s · %s" % [d.name, bar(io, float(lv) / float(d.max_level), 5, C_MAGENTA, true), lv, int(d.max_level), now, where, next])
		lines.append(io.paint("                  " + str(d.desc), C_DIM))
	lines.append(io.paint(" 'formation build <id>' at home, one season. Unpaid upkeep lowers a formation one level a year.", C_DIM))
	return lines


## Inventory grouped by kind.
static func inventory(s: GameSession) -> Array:
	var lines: Array = ["Linh thạch: %d" % s.player.linh_thach]
	var groups: Dictionary = {}
	for it in s.db.items_of(s.player.id):
		if it.kind == "herb" and int(it.get("plot", -1)) >= 0:
			continue
		if not groups.has(it.kind):
			groups[it.kind] = []
		groups[it.kind].append(it)
	var titles := {"treasure": "Bảo vật", "cong_phap": "Công pháp", "artifact": "Pháp bảo", "pill": "Đan dược", "talisman": "Phù lục (used automatically)", "herb": "Linh thảo (harvested)", "material": "Tài liệu"}
	for k in ["treasure", "cong_phap", "artifact", "pill", "talisman", "herb", "material"]:
		if not groups.has(k):
			continue
		lines.append(titles[k] + ":")
		for it in groups[k]:
			var mark: String = ""
			if it.id == s.player.cong_phap_id:
				mark = " [cultivating]"
			elif s.player.equipped.has(it.id):
				mark = " [equipped]"
			lines.append("  %-6s %s%s" % [it.id, s.items.describe(it), mark])
	return lines


## The herb field with ages and ripeness for each recipe ingredient.
static func field(s: GameSession) -> Array:
	var sh: StatSheet = s.sheet()
	var c: Character = s.player
	var planted: Dictionary = s.field.planted(c)
	var n: int = s.field.plot_count(c, sh)
	var lines: Array = ["Linh điền at %s: %d plots, growth x%.2f per season-year ('explain herb')" % [s.db.get_record("places", c.home_id).get("name", "?"), n, CharacterRules.herb_growth(c, s.gd, sh).total]]
	for i in n:
		if not planted.has(i):
			lines.append("  [%d] empty" % i)
			continue
		var h: Dictionary = planted[i]
		var uses: PackedStringArray = []
		for r in s.gd.recipes():
			for ing in r.ingredients:
				if ing.herb == h.template:
					var left: float = s.field.years_until(c, sh, h, float(ing.min_age))
					uses.append("%s %s" % [r.name, "READY" if left <= 0.0 else "in %.1f y" % left])
		lines.append("  [%d] %-6s %s | %s" % [i, h.id, s.items.describe(h), ", ".join(uses)])
	lines.append("Seeds for sale anywhere: " + ", ".join(s.field.seed_catalog().map(func(h): return "%s (%s, %d LT)" % [h.id, h.name, int(h.seed_price)])))
	return lines


## Recipes with ingredient availability and success chance.
static func recipes(s: GameSession) -> Array:
	var c: Character = s.player
	var sh: StatSheet = s.sheet()
	var lines: Array = ["Đan Đạo level %d. 'craft <recipe id>' takes one season." % c.skill_level(Alchemy.SKILL)]
	for r in s.gd.recipes():
		var plan: Dictionary = s.alchemy.find_ingredients(c, r)
		var ing: PackedStringArray = []
		for i in r.ingredients:
			ing.append("%dx %s>=%.0fy" % [int(i.qty), s.gd.herb(i.herb).name, float(i.min_age)])
		lines.append("  %-17s %-18s lvl %d  %3.0f%%  %s  %s" % [r.id, r.name, int(r.min_level), s.alchemy.success_chance(c, sh, r).total, "HAVE" if plan.ok else "need " + ", ".join(plan.missing), "| " + str(r.desc)])
		lines.append("      ingredients: " + ", ".join(ing))
	return lines


## Current place: description, people, roads, market hint.
static func here(s: GameSession) -> Array:
	var place: Dictionary = s.db.get_record("places", s.player.location_id)
	var region: Dictionary = s.db.get_record("regions", place.region_id)
	var lines: Array = ["%s (%s) — %s, %s. Linh khí %.2f, danger %d%s%s" % [place.name, place.id, s.gd.place_type(place.type).suffix, region.get("name", ""), float(place.density), int(place.danger),
		", market" if place.market else "", ", bounties" if place.bounties else ""]]
	if place.sect_id != "":
		lines.append("  Headquarters of %s" % s.db.get_record("sects", place.sect_id).name)
	if s.player.home_id == place.id:
		lines.append("  Your động phủ is here.")
	var people: Array = s.db.find("people", func(p): return p.alive and not p.get("is_player", false) and str(p.location_id) == place.id)
	lines.append("People here (%d):" % people.size())
	for p in people.slice(0, 15):
		lines.append("  " + person_line(s, p))
	if people.size() > 15:
		lines.append("  ... 'db people %s' lists all" % place.id)
	lines.append("Roads:")
	for l in place.links:
		var to: Dictionary = s.db.get_record("places", l.to)
		lines.append("  -> %-5s %s (%d season%s)" % [l.to, to.name, int(l.seasons), "s" if int(l.seasons) > 1 else ""])
	return lines


## World map as a list of regions and their places with roads.
static func map(s: GameSession) -> Array:
	var lines: Array = []
	for r in s.db.all("regions"):
		lines.append("%s (%s)" % [r.name, r.id])
		for pid in r.places:
			var p: Dictionary = s.db.get_record("places", pid)
			var roads: PackedStringArray = []
			for l in p.links:
				roads.append("%s(%d)" % [l.to, int(l.seasons)])
			var marks: String = ""
			if pid == s.player.location_id:
				marks += " <YOU>"
			if pid == s.player.home_id:
				marks += " <HOME>"
			lines.append("  %-5s %-24s lk %.2f dg %d%s%s  roads: %s%s" % [pid, p.name, float(p.density), int(p.danger), " M" if p.market else "", " S" if p.sect_id != "" else "", ", ".join(roads), marks])
	lines.append("M = market, S = sect headquarters, lk = linh khí density, dg = danger. 'go <place id>' travels along a road.")
	return lines


## One-line person summary.
static func person_line(s: GameSession, p: Dictionary) -> String:
	var sect: Dictionary = s.db.get_record("sects", str(p.get("sect_id", "")))
	var tags: PackedStringArray = []
	if p.get("is_beast", false):
		tags.append("yêu thú")
	else:
		tags.append(s.gd.archetype(str(p.archetype)).get("name", p.archetype))
	if not sect.is_empty():
		tags.append(sect.name)
	if not p.alive:
		tags.append("đã mất (%s)" % p.get("death_cause", ""))
	return "%-6s %-20s %-22s %s | chiến lực %.0f | attitude %d" % [p.id, p.name, s.gd.realm_label(int(p.realm_index), int(p.stage)), ", ".join(tags), float(p.get("power", 0.0)), int(p.get("attitude", 0))]


## Full record of any entity id, with its history.
static func show(s: GameSession, id: String) -> Array:
	var rec: Dictionary = s.db.lookup(id)
	if rec.is_empty():
		return ["No record %s." % id]
	var t: String = s.db.table_of(id)
	var lines: Array = []
	match t:
		"people":
			lines.append(person_line(s, rec))
			var c := Character.from_dict(rec)
			lines.append("  age %d, linh căn %s" % [int(c.age), c.linh_can.describe(s.gd)])
			var tp: PackedStringArray = []
			for k in c.thien_phu.keys():
				tp.append("%s %d" % [k, int(c.thien_phu[k])])
			lines.append("  thiên phú " + ", ".join(tp))
			lines.append("  traits: %s" % ", ".join(rec.get("traits", []).map(func(x): return _trait_name(s, x))))
			if not rec.get("is_player", false) and not rec.get("is_beast", false):
				var step: Breakdown = ProgressionEdges.npc_step_chance(rec, s.gd)
				var why: PackedStringArray = []
				for st in step.steps:
					if str(st.op) == "+":
						why.append(str(st.label))
				lines.append("  breakthrough odds %.0f%% (%s)" % [step.total * 100.0, ", ".join(why) if not why.is_empty() else "no edge"])
			if c.master_id != "":
				lines.append("  master: %s" % s.db.get_record("people", c.master_id).get("name", c.master_id))
			for it in s.db.items_of(id):
				lines.append("  owns %-6s %s%s" % [it.id, s.items.describe(it), " [equipped]" if c.equipped.has(it.id) else (" [cultivating]" if it.id == c.cong_phap_id else "")])
			lines.append("  created by: %s" % rec.get("created_by", "?"))
		"items":
			lines.append("%s %s" % [id, s.items.describe(rec)])
			var owner: Dictionary = s.db.lookup(str(rec.get("owner_id", "")))
			lines.append("  owner: %s %s%s" % [rec.get("owner_id", ""), owner.get("name", ""), " (lost here)" if rec.get("lost", false) else ""])
		"sects":
			lines.append("%s %s — %s, specialty %s, %s" % [id, rec.name, rec.alignment_name, s.gd.archetype(rec.specialty).get("name", ""), rec.status])
			lines.append("  headquarters %s, founded năm %d" % [s.db.get_record("places", rec.hq_place_id).get("name", ""), int(rec.founded_year)])
			var members: Array = rec.members.map(func(m): return s.db.get_record("people", m)).filter(func(m): return not m.is_empty() and m.alive)
			lines.append("  living members: %d" % members.size())
			for m in members.slice(0, 12):
				lines.append("    %s [%s]" % [person_line(s, m), m.get("sect_rank", "")])
		"places":
			lines.append("%s %s (%s) density %.2f danger %d" % [id, rec.name, rec.type, float(rec.density), int(rec.danger)])
		"events":
			lines.append("năm %d: %s" % [int(rec.year), rec.text])
			if rec.data.has("narration"):
				lines.append("  " + str(rec.data.narration))
			for e in rec.data.get("effects", []):
				lines.append("    " + str(e))
			return lines
		_:
			lines.append(JSON.stringify(rec, "  "))
	var hist: Array = s.db.events_of(id)
	if not hist.is_empty():
		lines.append("  history (%d):" % hist.size())
		for e in hist.slice(-12):
			lines.append("    năm %d: %s" % [int(e.year), e.text])
	return lines


## Lines describing a pending event with each choice's odds.
static func event(s: GameSession, io: TerminalIO = null) -> Array:
	if io == null:
		io = TerminalIO.new()
	if not s.has_pending_event():
		return ["No event is waiting."]
	var ev: Dictionary = s.pending_event
	var src: String = str(s.pending_meta.get("source", ""))
	var lines: Array = [""]
	lines.append(io.paint("╔══ ", C_YELLOW) + io.paint(str(ev.title), "1;33") + io.paint(" " + "═".repeat(maxi(WIDTH - 6 - str(ev.title).length() - src.length() - 4, 3)) + " [" + src + "]", C_YELLOW))
	for l in wrap_text(str(ev.text), WIDTH - 4):
		lines.append(io.paint("║ ", C_YELLOW) + l)
	lines.append(io.paint("║", C_YELLOW))
	for i in ev.choices.size():
		var ch: Dictionary = ev.choices[i]
		var o: Dictionary = Advisor.choice_odds(s, i)
		var cost: PackedStringArray = []
		for fx in ch.always:
			if fx.type == "linh_thach":
				cost.append("%+d LT" % int(fx.amount))
		var label: String = "%d) %s" % [i + 1, ch.label]
		var detail: String
		if float(o.chance) >= 0.0:
			var pct: float = float(o.chance)
			var col: String = C_GREEN if pct >= 0.65 else (C_YELLOW if pct >= 0.4 else C_RED)
			detail = "%s %s %s" % [bar(io, pct, 10, col), io.paint("%3.0f%%" % (pct * 100.0), col), o.text]
		else:
			detail = io.paint("certain", C_DIM)
		if not cost.is_empty():
			detail += "  cost " + ", ".join(cost)
		if not bool(o.ok):
			lines.append(io.paint("║  ", C_YELLOW) + io.paint(label + "  — " + str(o.reason), C_DIM))
			continue
		lines.append(io.paint("║  ", C_YELLOW) + io.paint(label, C_BOLD))
		lines.append(io.paint("║       ", C_YELLOW) + detail)
	var warnings: Array = s.pending_meta.get("warnings", [])
	if not warnings.is_empty():
		for w in wrap_text("engine adjustments: " + "; ".join(warnings), WIDTH - 4):
			lines.append(io.paint("║ ", C_YELLOW) + io.paint(w, C_DIM))
	if str(s.pending_meta.get("llm_error", "")) != "":
		lines.append(io.paint("║ ", C_YELLOW) + io.paint(str(s.pending_meta.llm_error), C_DIM))
	lines.append(io.paint("╚═ ", C_YELLOW) + "type 1-%d to choose" % ev.choices.size())
	return lines


## Kinh Mạch Đồ summary: points, frontier with bonuses, and reachable notables/keystones.
static func tree_summary(s: GameSession, io: TerminalIO) -> Array:
	var c: Character = s.player
	var t: MeridianTree = s.tree
	var lines: Array = ["Kinh Mạch Đồ: %d huyệt open, %d unspent points. Commands: tree map | tree node <id> | tree alloc <id> | tree go <id> | tree targets" % [c.tree_nodes.size(), c.tree_points]]
	lines.append("Openable now:")
	for nid in t.frontier(c.tree_nodes):
		var nd: Dictionary = t.node(nid)
		var ok: Dictionary = t.can_allocate(c, nid, s.gd)
		lines.append("  #%-4d %-24s %-14s %s%s" % [nid, nd.name, nd.kind, t.describe_mods(nid, c.linh_can, s.gd), "" if ok.ok or c.tree_points <= 0 else "  (" + ok.reason + ")"])
	return lines


## Every notable and keystone with the cost (points) to reach it.
static func tree_targets(s: GameSession) -> Array:
	var c: Character = s.player
	var t: MeridianTree = s.tree
	var rows: Array = []
	for nd in t.nodes.values():
		if not (nd.kind in ["notable", "keystone", "bridge_notable"]) or c.tree_nodes.has(nd.id):
			continue
		var path: Array = t.path_to(c.tree_nodes, nd.id)
		rows.append({"cost": path.size(), "line": "  #%-4d cost %2d  %-26s %-14s %s%s" % [nd.id, path.size(), nd.name, nd.kind, t.describe_mods(nd.id, c.linh_can, s.gd), ("  — " + nd.desc) if nd.desc != "" else ""]})
	rows.sort_custom(func(a, b): return a.cost < b.cost)
	return ["Notables and keystones by distance ('tree go <id>' opens the whole path):"] + rows.map(func(r): return r.line)


## One node in detail.
static func tree_node(s: GameSession, nid: int) -> Array:
	var t: MeridianTree = s.tree
	var nd: Dictionary = t.node(nid)
	if nd.is_empty():
		return ["No huyệt #%d." % nid]
	var c: Character = s.player
	var path: Array = t.path_to(c.tree_nodes, nid)
	return [
		"#%d %s — %s, sector %s, ring %d%s" % [nid, nd.name, nd.kind, nd.sector, int(nd.ring), " [OPEN]" if c.tree_nodes.has(nid) else ""],
		"  bonus: %s" % t.describe_mods(nid, c.linh_can, s.gd),
		"  %s" % nd.desc if nd.desc != "" else "",
		"  links: %s" % ", ".join(nd.links.map(func(x): return "#%d" % int(x))),
		"  path from your open huyệt: %s (%d points)" % [", ".join(path.map(func(x): return "#%d" % int(x))), path.size()] if not c.tree_nodes.has(nid) else "",
	].filter(func(l): return l != "")


## ASCII map of the tree, PoE-style: sectors around Đan Điền.
static func tree_map(s: GameSession, io: TerminalIO) -> Array:
	var t: MeridianTree = s.tree
	var c: Character = s.player
	var w: int = 79
	var h: int = 41
	var grid: Array = []
	var colors: Array = []
	for y in h:
		var row: Array = []
		var crow: Array = []
		for x in w:
			row.append(" ")
			crow.append("")
		grid.append(row)
		colors.append(crow)
	var frontier: Array = t.frontier(c.tree_nodes)
	var rank := {" ": 0, ".": 1, ":": 1, "o": 2, "N": 3, "K": 4, "+": 5, "#": 6, "@": 7}
	for nd in t.nodes.values():
		var x: int = int(roundf(float(w) / 2.0 + float(nd.x) * 4.2))
		var y: int = int(roundf(float(h) / 2.0 + float(nd.y) * 2.1))
		if x < 0 or x >= w or y < 0 or y >= h:
			continue
		var ch: String = "."
		match str(nd.kind):
			"root": ch = "@"
			"gate": ch = "o"
			"notable", "bridge_notable": ch = "N"
			"keystone": ch = "K"
			"bridge": ch = ":"
		if c.tree_nodes.has(nd.id) and nd.kind != "root":
			ch = "#"
		elif frontier.has(nd.id):
			ch = "+"
		if rank.get(ch, 0) >= rank.get(grid[y][x], 0):
			grid[y][x] = ch
			var sector: String = str(nd.sector).split("-")[0]
			colors[y][x] = str(s.gd.element(sector).get("ansi", ""))
	var lines: Array = []
	for y in h:
		var line := ""
		for x in w:
			line += io.paint(grid[y][x], colors[y][x]) if grid[y][x] != " " else " "
		lines.append(line.trim_suffix(" ") if not io.color else line)
	var legend: PackedStringArray = []
	for e in s.gd.element_cycle():
		legend.append(elem(io, s.gd, e, s.gd.element_name(e)))
	lines.append("@ Đan Điền  # open  + openable  N notable  K keystone  o gate  . huyệt  : kỳ kinh bridge")
	lines.append("Sectors clockwise from the top: " + " → ".join(legend) + "  (tương sinh order)")
	return lines


## Element-coloured text.
static func elem(io: TerminalIO, gd: GameData, element_id: String, text: String) -> String:
	return io.paint(text, str(gd.element(element_id).get("ansi", "")))


static func _trait_name(s: GameSession, trait_id: String) -> String:
	for t in s.gd.names().traits:
		if t.id == trait_id:
			return t.name
	return trait_id
