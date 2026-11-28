class_name TribulationHarness
extends RefCounted
## Balance & diagnostic measurement harness for Heavenly Tribulation (Thiên Kiếp).
## Design: design/gdd/thien-kiep.md (Formulas C, AC-TK-65..67).
##
## Runs N deterministic tribulations per build and aggregates p_t_hat, standard error,
## implied roll_target, and failure breakdowns by ending, wave, and boss threat kind.
##
## Usage:
## [codeblock]
## var stats: Dictionary = TribulationHarness.measure(gd, profile, "nguyen_anh_to_hoa_than", 4000, 100)
## var check: Dictionary = TribulationHarness.evaluate_targets(gd, [edge_stats], [base_stats])
## [/codeblock]


## Aggregates survival statistics from counts and failure breakdowns (Formulas C, AC-TK-66).
## Returns {n, survived, failed, p_t_hat, se, roll_target, by_ending, by_wave, by_boss_kind}.
static func summarize(
		n: int,
		survived: int,
		by_ending: Dictionary,
		by_wave: Dictionary,
		by_boss_kind: Dictionary
) -> Dictionary:
	var total: int = maxi(0, n)
	var surv: int = clampi(survived, 0, total)
	var p: float = float(surv) / float(total) if total > 0 else 0.0
	var se: float = sqrt(p * (1.0 - p) / float(total)) if total > 0 else 0.0
	return {
		"n": total,
		"survived": surv,
		"failed": total - surv,
		"p_t_hat": p,
		"se": se,
		"roll_target": TribulationRules.roll_target(p),
		"by_ending": by_ending.duplicate(true),
		"by_wave": by_wave.duplicate(true),
		"by_boss_kind": by_boss_kind.duplicate(true),
	}


## Runs [param n] deterministic tribulations for [param build_profile] on [param step_id] starting from
## [param base_seed]. [param fight_fn] may be injected for fast stub testing (AC-TK-65) or left empty
## to run real [CombatService] fights.
## [param opts] accepts optional keys: [code]pool[/code], [code]step[/code], [code]rules_override[/code],
## [code]prep[/code], [code]place_tags[/code], [code]start_vitality[/code], [code]char_id[/code].
static func measure(
		gd: GameData,
		build_profile: FighterProfile,
		step_id: String,
		n: int,
		base_seed: int,
		fight_fn: Callable = Callable(),
		opts: Dictionary = {}
) -> Dictionary:
	var survived: int = 0
	var by_ending: Dictionary = {}
	var by_wave: Dictionary = {}
	var by_boss_kind: Dictionary = {}
	var step: Dictionary = opts.get("step", TribulationRules.step_by_id(gd, step_id))
	var pool: Array = Array(opts.get("pool", []))
	if pool.is_empty() and step_id != "":
		pool = TribulationRules.bosses_for_step(gd, step_id)
	var char_id: String = str(opts.get("char_id", "harness"))
	var prep: Dictionary = opts.get("prep", {})
	var place_tags: Array = Array(opts.get("place_tags", []))
	var start_vitality: float = float(opts.get("start_vitality", 1.0))
	var rules_override: Dictionary = opts.get("rules_override", {})

	for i in maxi(0, n):
		var params := {
			"world_seed": base_seed + i,
			"char_id": char_id,
			"step": step,
			"step_id": step_id,
			"pool": pool,
			"player_profile": build_profile,
			"prep": prep,
			"place_tags": place_tags,
			"start_vitality": start_vitality,
			"abs_season": i,
			"log_enabled": false,
			"rules_override": rules_override,
		}
		var out: Dictionary = TribulationRunner.run(params, gd, fight_fn)
		if bool(out.get("survived", false)):
			survived += 1
		else:
			var ending_k: String = str(out.get("fail_reason", "unknown"))
			by_ending[ending_k] = int(by_ending.get(ending_k, 0)) + 1
			var fw: int = int(out.get("fatal_wave", 0))
			by_wave[fw] = int(by_wave.get(fw, 0)) + 1
			var fb: Dictionary = out.get("fatal_boss", {})
			var bk: String = str(fb.get("main_kind", "unknown"))
			by_boss_kind[bk] = int(by_boss_kind.get(bk, 0)) + 1

	return summarize(n, survived, by_ending, by_wave, by_boss_kind)


## Evaluates measured edge and baseline survival results against tribulation_rules.json targets (AC-TK-67).
## Each entry in [param edge_results] and [param base_results] is a dictionary returned by [method measure].
static func evaluate_targets(gd: GameData, edge_results: Array, base_results: Array) -> Dictionary:
	var targets: Dictionary = TribulationRules.config(gd).get("targets", {})
	var p_edge: float = float(targets.get("p_t_edge", 0.90))
	var edge_tol: float = float(targets.get("p_t_edge_tol", 0.03))
	var edge_floor: float = float(targets.get("p_t_edge_floor", 0.80))
	var p_base: float = float(targets.get("p_t_base", 0.50))
	var base_tol: float = float(targets.get("p_t_base_tol", 0.05))

	var edge_sum: float = 0.0
	var edge_min: float = 1.0
	for r in edge_results:
		var pv: float = float(r.get("p_t_hat", 0.0))
		edge_sum += pv
		edge_min = minf(edge_min, pv)
	var edge_mean: float = edge_sum / float(edge_results.size()) if not edge_results.is_empty() else 0.0
	if edge_results.is_empty():
		edge_min = 0.0

	var base_sum: float = 0.0
	for r in base_results:
		base_sum += float(r.get("p_t_hat", 0.0))
	var base_mean: float = base_sum / float(base_results.size()) if not base_results.is_empty() else 0.0

	var edge_ok: bool = not edge_results.is_empty() and absf(edge_mean - p_edge) <= edge_tol + 1e-9
	var edge_floor_ok: bool = not edge_results.is_empty() and edge_min >= edge_floor - 1e-9
	var base_ok: bool = not base_results.is_empty() and absf(base_mean - p_base) <= base_tol + 1e-9
	return {
		"pass": edge_ok and edge_floor_ok and base_ok,
		"edge_mean": edge_mean,
		"edge_min": edge_min,
		"base_mean": base_mean,
		"edge_ok": edge_ok,
		"edge_floor_ok": edge_floor_ok,
		"base_ok": base_ok,
	}
