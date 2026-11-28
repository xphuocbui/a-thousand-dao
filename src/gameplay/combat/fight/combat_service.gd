class_name CombatService
extends RefCounted
## Runs fight requests (ADR-0001 decision 5): validates the request, runs one [Fight] on the request's seed and
## returns its [FightResult]. It never touches the character, the World DB or the clock; the caller applies the costs.
##
## Not wired into the Event Engine yet (ADR-0001 step 4): it goes behind a feature flag next to CombatPower.duel, with
## fighters from [method FighterCompiler.compile] and the seed from the session stream (ADR-0002).
##
## Usage:
## [codeblock]
## var service := CombatService.new(CombatConstants.from_game_data(gd))
## var r: FightResult = service.resolve(request)
## if r == null: push_error("\n".join(service.errors))
## [/codeblock]

## Problems with the last request; empty when it ran.
var errors: PackedStringArray = []
var _k: CombatConstants


## [param k] is the combat constants (from [method CombatConstants.from_game_data]).
func _init(k: CombatConstants) -> void:
	_k = k


## Runs [param request]. Returns null, with [member errors] naming each problem, for a request the engine cannot run.
func resolve(request: FightRequest) -> FightResult:
	errors = []
	if request.a == null or request.b == null:
		errors.append("a fight request needs two compiled fighters")
	# Combat rule 3 / Edge Cases: a health share of 0 or below or a share above 1 is rejected at the request
	if request.start_health_share <= 0.0 or request.start_health_share > 1.0:
		errors.append("start_health_share %s must be above 0 and at most 1" % str(request.start_health_share))
	if request.start_qi_share < 0.0 or request.start_qi_share > 1.0:
		errors.append("start_qi_share %s must be from 0 to 1" % str(request.start_qi_share))
	if not errors.is_empty():
		return null
	var f := Fight.new(request.a, request.b, _k, request.fight_seed, Fight.Order.COIN, request.log_enabled)
	f.no_heal = request.no_heal
	var notes: PackedStringArray = []
	for tag in request.ground_tags:   # Combat rules 12, 26 (AC-CB-104): keep the readable kinds, ignore the rest
		if _k.request_tags.has(str(tag)):
			if not f.tags.has(str(tag)):
				f.tags.append(str(tag))
		elif not notes.has("request tag %s ignored (a fight reads no place)" % str(tag)):
			notes.append("request tag %s ignored (a fight reads no place)" % str(tag))
	if request.start_health_share != 1.0 or request.start_qi_share != 1.0:
		# starting shares replace the full start for side A (Combat Formulas A: health_max x share, qi_use x share)
		f.a.hp = f.a.hp_max * request.start_health_share
		f.a.qi = f.a.qi_use() * request.start_qi_share
	var res: FightResult = f.run()
	res.notes = notes
	return res
