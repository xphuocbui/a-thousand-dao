class_name CharacterRules
extends RefCounted
## Derived character values (thần thức, khí huyết, linh lực, element-driven economy
## multipliers) as explainable [Breakdown]s. All constants come from data files.
## Design: design/gdd/character-stats.md rules 7-11, Formulas C-G.
##
## Usage:
## [codeblock]
## var tt: Breakdown = CharacterRules.than_thuc(c, gd, sheet)
## print(tt.total); print("\n".join(tt.lines()))
## [/codeblock]


## Thần thức = Thần hồn(eff) x per_point x realm multiplier x (1 + than_thuc_pct).
static func than_thuc(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var d: Dictionary = gd.attributes().derived
	var b := Breakdown.new("Thần thức")
	b.base("Thần hồn (effective)", sheet.effective("than_hon", c))
	b.mul("per point", float(d.than_thuc_per_than_hon))
	b.mul("%s multiplier" % gd.realm(c.realm_index).name, float(gd.realm(c.realm_index).than_thuc_mult))
	b.mul("Stage", Ladder.stage_mult(gd, c.stage))
	b.mul("than_thuc_pct", sheet.mult("than_thuc_pct"))
	return b


## Max khí huyết = Căn cốt(eff) x per_point x realm multiplier x (1 + khi_huyet_pct).
static func khi_huyet_max(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var d: Dictionary = gd.attributes().derived
	var b := Breakdown.new("Khí huyết (max)")
	b.base("Căn cốt (effective)", sheet.effective("can_cot", c))
	b.mul("per point", float(d.khi_huyet_per_can_cot))
	b.mul("%s multiplier" % gd.realm(c.realm_index).name, float(gd.realm(c.realm_index).khi_huyet_mult))
	b.mul("Stage", Ladder.stage_mult(gd, c.stage))
	b.mul("khi_huyet_pct", sheet.mult("khi_huyet_pct"))
	b.clamp_to(1.0, INF)
	return b


## Linh lực = realm base x stage x technique power x (1 + linh_luc_pct), plus capability #4's
## share of maximum vitality after the pct step.
static func linh_luc(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var b := Breakdown.new("Linh lực")
	b.base("%s base" % gd.realm(c.realm_index).name, float(gd.realm(c.realm_index).linh_luc_base))
	b.mul("Stage", Ladder.stage_mult(gd, c.stage))
	var ngo: float = sheet.effective("ngo_tinh", c)
	var label: String = "Technique power"
	if not CongPhap.main_entry(c).is_empty():
		label += " (Ngộ tính %d: x%.3f)" % [int(ngo), CongPhap.comp_strength(gd, ngo)]
	b.mul(label, CongPhap.tech_power(c, gd, ngo))
	b.mul("linh_luc_pct", sheet.mult("linh_luc_pct"))
	if c.has_capability(4):
		b.add("Huyết Ngự Linh", float(gd.attributes().derived.linh_luc_conversion) * khi_huyet_max(c, gd, sheet).total)
	return b


## Herb growth multiplier = (1 + Mộc purity x k) x max(0, 1 + herb_growth_pct).
static func herb_growth(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var fx: Dictionary = gd.element_effects()
	var b := Breakdown.new("Linh thảo growth / season")
	b.base("Base", 1.0)
	b.add_pct("Mộc purity %d" % int(c.linh_can.purity("moc")), c.linh_can.purity("moc") * float(fx.herb_growth_pct_per_purity))
	b.mul("herb_growth_pct", sheet.mult("herb_growth_pct"))
	return b


## Field plots = base + Thổ purity x k + field_plots stat (capped by data).
static func field_plots(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var fx: Dictionary = gd.element_effects()
	var cfg: Dictionary = gd.session().field
	var b := Breakdown.new("Linh điền plots")
	b.base("Base", float(cfg.base_plots))
	b.add("Thổ purity %d" % int(c.linh_can.purity("tho")), floorf(c.linh_can.purity("tho") * float(fx.field_plots_per_purity)))
	b.add("field_plots", floorf(sheet.total("field_plots")))
	b.clamp_to(1.0, float(cfg.max_plots))
	return b


## Đan độc removed per season = natural + Thủy purity x k + dan_doc_decay.
static func dan_doc_decay(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var fx: Dictionary = gd.element_effects()
	var b := Breakdown.new("Đan độc decay / season")
	b.base("Natural", float(gd.attributes().derived.dan_doc_natural_decay))
	b.add("Thủy purity %d" % int(c.linh_can.purity("thuy")), c.linh_can.purity("thuy") * float(fx.dan_doc_decay_per_purity))
	b.add("dan_doc_decay", sheet.total("dan_doc_decay"))
	b.clamp_to(0.0, INF)
	return b


## Mission income multiplier = (1 + Kim purity x k) x max(0, 1 + mission_income_pct).
static func mission_income(c: Character, gd: GameData, sheet: StatSheet) -> Breakdown:
	var fx: Dictionary = gd.element_effects()
	var b := Breakdown.new("Mission income multiplier")
	b.base("Base", 1.0)
	b.add_pct("Kim purity %d" % int(c.linh_can.purity("kim")), c.linh_can.purity("kim") * float(fx.mission_income_pct_per_purity))
	b.mul("mission_income_pct", sheet.mult("mission_income_pct"))
	return b


## 1 - resistance / 100, clamped so a gain never disappears and a penalty stops at x2.
static func resist_factor(gd: GameData, resist_pct: float) -> float:
	var d: Dictionary = gd.attributes().derived
	return clampf(1.0 - resist_pct / 100.0, float(d.resist_factor_min), float(d.resist_factor_max))


## Applies a đan độc change, reduced by dan_doc_resist_pct when positive.
static func add_dan_doc(c: Character, gd: GameData, sheet: StatSheet, amount: float) -> float:
	var applied: float = amount
	if amount > 0.0:
		applied *= resist_factor(gd, sheet.total("dan_doc_resist_pct"))
	c.dan_doc = clampf(c.dan_doc + applied, 0.0, float(gd.attributes().derived.dan_doc_max))
	return applied


## Applies a tâm ma change, reduced by tam_ma_resist_pct when positive.
static func add_tam_ma(c: Character, gd: GameData, sheet: StatSheet, amount: float) -> float:
	var applied: float = amount
	if amount > 0.0:
		applied *= resist_factor(gd, sheet.total("tam_ma_resist_pct"))
	c.tam_ma = clampf(c.tam_ma + applied, 0.0, float(gd.attributes().derived.tam_ma_max))
	return applied


## Grade label of a thiên phú value, e.g. "72 Thượng".
static func graded(gd: GameData, value: float) -> String:
	return "%d %s" % [int(roundf(value)), gd.grade_name(value)]
