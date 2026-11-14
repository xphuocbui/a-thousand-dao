class_name SeasonBatch
extends RefCounted
## One season's rating work (design/gdd/power-rankings.md Core Rules rules 7, 8, 13, 14, 16; ADR-0003 decisions 4, 6,
## 12): the panel queue in rule 14's order and the pair fights (the Nguyên Anh and Hóa Thần round robin, matchmaking,
## the season's Kết Đan slice), planned on the main thread by [method RatingService.plan_season], run by [method run]
## (on WorkerThreadPool, or inline) and applied by [method RatingService.apply_batch] in rule 13's fixed order.
##
## Running reads only this object's own data, the compiled profiles in it and the prebuilt ladder rungs, never the
## World DB, so it can run on a background thread while the game goes on. Every task writes only its own slot.
##
## Usage:
## [codeblock]
## var batch: SeasonBatch = rs.plan_season(game_seed, season_key, year, season_in_year, player, player_sheet)
## batch.run(true)        # blocking; or batch.start() then batch.finish() around the season
## rs.apply_batch(batch)
## [/codeblock]

## The ADR-0002 keyed-stream prefix of a pair fight (rule 13): "rankf:<game seed>:<season>:<lo id>:<hi id>:<index>".
const PAIR_KEY := "rankf:%d:%d:%s:%s:%d"

## A queued panel: the fighter's id, compiled profile and the panel's settings, filled in at planning.
class PanelJob extends RefCounted:
	var id: String = ""
	var realm: int = 0
	var profile: FighterProfile
	var coarse: bool = false
	var warm: bool = false
	var start_k: int = 0
	## The fighter's build signature when it was compiled (stored on the record when the panel applies).
	var sig: String = ""
	## The fighter's panel count when planned; a panel that ran for it since (the player's on-open one) wins.
	var panels_before: int = 0
	## This fighter's panel fight counts per rung this season (rule 13), carried in and continued by the run.
	var counts: Dictionary = {}
	## The most fights this panel can take (PanelSearch.max_fights), for the budget share.
	var max_fights: int = 0
	## Set by the run: {base, probes, fights}; empty when it did not run.
	var result: Dictionary = {}

## A planned pair fight: [member a] sorts before [member b] (rule 13), [member index] counts this pair's fights this
## season in plan order, [member kind] is "rr" (top round robin), "match" or "kd" (Kết Đan round robin).
class PairFight extends RefCounted:
	var a: String = ""
	var b: String = ""
	var index: int = 0
	var kind: String = ""
	var seed: int = 0
	## a's score, set by the run: 1, 0.5 or 0; -1 when it did not run.
	var score: float = -1.0

var game_seed: int = 0
## The season key every seed uses (GameSession.season_index(); 0 at world generation).
var season: int = 0
## Fights this batch may run, and the share of them panels may use (rule 14).
var budget: int = 0
var panel_budget: int = 0
## Panels in rule 14's order; the run admits them while their worst case fits the panel share.
var panels: Array[PanelJob] = []
## PairFight fights in rule 14's order (round robin, matchmaking, Kết Đan slice); the run plays a prefix.
var pairs: Array[PairFight] = []
## Compiled fighters of the pair fights, by id.
var profiles: Dictionary = {}
## Set by the run.
var panel_fights: int = 0
var pair_fights: int = 0
var ran: bool = false

var _service: RatingService
var _admitted: Array[PanelJob] = []
var _todo: Array[PairFight] = []
var _thread: Thread


func _init(service: RatingService) -> void:
	_service = service


## Runs the batch now, blocking: panels in waves (each wave admits the queue's next panels while their worst cases
## fit the panel share left, so the share is never exceeded), then as many pair fights as the budget leaves, in plan
## order. [param threaded] spreads each wave over WorkerThreadPool; results are identical either way.
func run(threaded: bool) -> void:
	var left: int = panel_budget
	var next := 0
	while next < panels.size():
		_admitted = []
		var reserve := 0
		while next < panels.size() and reserve + panels[next].max_fights <= left:
			reserve += panels[next].max_fights
			_admitted.append(panels[next])
			next += 1
		if _admitted.is_empty():
			break
		_each(_admitted.size(), _panel_task, threaded)
		for p in _admitted:
			left -= int(p.result.fights)
			panel_fights += int(p.result.fights)
	_admitted = []
	var room: int = maxi(0, budget - panel_fights)
	_todo = pairs.slice(0, mini(room, pairs.size()))
	_each(_todo.size(), _pair_task, threaded)
	pair_fights = _todo.size()
	_todo = []
	ran = true


## Starts [method run] on a background thread (threaded inside); [method finish] waits for it.
func start() -> void:
	_thread = Thread.new()
	_thread.start(run.bind(true))


## Waits for a [method start]ed run to end (returns at once when none is running).
func finish() -> void:
	if _thread != null:
		_thread.wait_to_finish()
		_thread = null


func _each(n: int, task: Callable, threaded: bool) -> void:
	if n == 0:
		return
	if threaded:
		var gid: int = WorkerThreadPool.add_group_task(task, n, -1, false, "power rankings season")
		WorkerThreadPool.wait_for_group_task_completion(gid)
	else:
		for i in n:
			task.call(i)


func _panel_task(i: int) -> void:
	var p: PanelJob = _admitted[i]
	p.result = _service.panel_core(p.profile, p.realm, p.id, p.warm, p.start_k, p.coarse, p.counts, game_seed, season)


func _pair_task(i: int) -> void:
	var f: PairFight = _todo[i]
	f.score = _service.fight_score(profiles[f.a], profiles[f.b], f.seed, true)
