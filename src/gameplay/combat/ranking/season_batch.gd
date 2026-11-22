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
## Fighters waiting for a panel this season (Stale or Provisional, the player included); [member panels] holds only
## the first of them a season could admit.
var waiting: int = 0
## PairFight fights in rule 14's order (round robin, matchmaking, Kết Đan slice); the run plays a prefix.
var pairs: Array[PairFight] = []
## Compiled fighters of the pair fights, by id.
var profiles: Dictionary = {}
## Set by the run.
var panel_fights: int = 0
var pair_fights: int = 0
var ran: bool = false
## Each fighter's build file (id -> build file), kept by the planner beside its compiled profile, so worker processes
## can rebuild the fighters exactly (ADR-0003 decision 13).
var builds: Dictionary = {}
## Worker processes for this batch's fights (ADR-0003 decision 13); null runs everything on threads. Set by the planner.
var pool: RatingWorkerPool = null
## Tasks that ran in worker processes, and those that fell back to threads (for measurements and tests).
var worker_tasks: int = 0
var _use_pool := false
var fallback_tasks: int = 0

var _service: RatingService
var _admitted: Array[PanelJob] = []
var _todo: Array[PairFight] = []
var _thread: Thread
var _cancelled := false


func _init(service: RatingService) -> void:
	_service = service


## Runs the batch now, blocking: panels in waves (each wave admits the queue's next panels while their worst cases
## fit the panel share left, so the share is never exceeded), then as many pair fights as the budget leaves, in plan
## order. [param threaded] spreads each wave over WorkerThreadPool; results are identical either way.
func run(threaded: bool) -> void:
	_use_pool = pool != null and not _cancelled and pool.begin(builds)
	var left: int = panel_budget
	var next := 0
	while next < panels.size() and not _cancelled:
		_admitted = []
		var reserve := 0
		while next < panels.size() and reserve + panels[next].max_fights <= left:
			reserve += panels[next].max_fights
			_admitted.append(panels[next])
			next += 1
		if _admitted.is_empty():
			break
		_run_panels(threaded)
		for p in _admitted:
			left -= int(p.result.get("fights", 0))
			panel_fights += int(p.result.get("fights", 0))
	_admitted = []
	var room: int = maxi(0, budget - panel_fights)
	_todo = pairs.slice(0, mini(room, pairs.size()))
	_run_pairs(threaded)
	pair_fights = _todo.size()
	_todo = []
	if _use_pool:
		pool.end()
	_use_pool = false
	ran = true


## The run's results only, for a save (power-rankings.md rule 13, one season late, 2026-11-22: a batch waits a season
## before it applies, so a save keeps the previous season's finished batch to apply at the end of the next one). Call
## it only on a batch that has run. Holds no profiles: everything [method RatingService.apply_batch] reads, nothing
## more. Inverse: [method from_results].
func results_to_dict() -> Dictionary:
	var ps: Array = []
	for p in panels:
		if not p.result.is_empty():
			ps.append({"id": p.id, "realm": p.realm, "coarse": p.coarse, "sig": p.sig, "panels_before": p.panels_before,
				"counts": p.counts.duplicate(), "result": p.result.duplicate(true)})
	var fs: Array = []
	for f in pairs:
		if f.score >= 0.0:
			fs.append([f.a, f.b, f.index, f.kind, f.score])
	return {"game_seed": game_seed, "season": season, "budget": budget, "panel_budget": panel_budget, "waiting": waiting,
		"panel_fights": panel_fights, "pair_fights": pair_fights, "panels": ps, "pairs": fs}


## A batch rebuilt from [method results_to_dict] for [param service]: it has run (so it is never run again) and can only
## be applied.
static func from_results(service: RatingService, d: Dictionary) -> SeasonBatch:
	var b := SeasonBatch.new(service)
	b.game_seed = int(d.get("game_seed", 0))
	b.season = int(d.get("season", 0))
	b.budget = int(d.get("budget", 0))
	b.panel_budget = int(d.get("panel_budget", 0))
	b.waiting = int(d.get("waiting", 0))
	b.panel_fights = int(d.get("panel_fights", 0))
	b.pair_fights = int(d.get("pair_fights", 0))
	for pd in d.get("panels", []):
		var p := PanelJob.new()
		p.id = str(pd.id)
		p.realm = int(pd.realm)
		p.coarse = bool(pd.coarse)
		p.sig = str(pd.sig)
		p.panels_before = int(pd.panels_before)
		p.counts = Dictionary(pd.counts).duplicate()
		p.result = Dictionary(pd.result).duplicate(true)
		b.panels.append(p)
	for fd in d.get("pairs", []):
		var f := PairFight.new()
		f.a = str(fd[0])
		f.b = str(fd[1])
		f.index = int(fd[2])
		f.kind = str(fd[3])
		f.score = float(fd[4])
		b.pairs.append(f)
	b.ran = true
	return b


## Starts [method run] on a background thread (threaded inside); [method finish] waits for it.
func start() -> void:
	_thread = Thread.new()
	_thread.start(run.bind(true))


## Stops a running batch at its next fight; its results are then incomplete and must not be applied (quitting).
func cancel() -> void:
	_cancelled = true


## Waits for a [method start]ed run to end (returns at once when none is running).
func finish() -> void:
	if _thread != null:
		_thread.wait_to_finish()
		_thread = null


## Runs the admitted panels: in worker processes when [member pool] is set, any that come back empty on threads.
func _run_panels(threaded: bool) -> void:
	if not _use_pool or _cancelled:
		_each(_admitted.size(), _panel_task, threaded)
		return
	var tasks: Array = []
	for p in _admitted:
		tasks.append(["p", p.id, p.realm, p.warm, p.start_k, p.coarse, p.counts, game_seed, season])
	var got: Array = pool.run(tasks)
	var left: Array[PanelJob] = []
	for i in _admitted.size():
		var r: Variant = got[i]
		if r is Array and (r as Array).size() == 2:
			_admitted[i].result = r[0]
			_admitted[i].counts = r[1]
			worker_tasks += 1
		else:
			left.append(_admitted[i])
	if not left.is_empty():
		fallback_tasks += left.size()
		var keep: Array[PanelJob] = _admitted   # the whole wave, which run() counts afterwards
		_admitted = left
		_each(_admitted.size(), _panel_task, threaded)
		_admitted = keep


## Runs the pair fights in [member _todo]: in worker processes when [member pool] is set, any that come back empty on
## threads.
func _run_pairs(threaded: bool) -> void:
	if not _use_pool or _cancelled:
		_each(_todo.size(), _pair_task, threaded)
		return
	var tasks: Array = []
	for f in _todo:
		tasks.append(["f", f.a, f.b, f.seed])
	var got: Array = pool.run(tasks)
	var left: Array[PairFight] = []
	for i in _todo.size():
		if got[i] != null:
			_todo[i].score = float(got[i])
			worker_tasks += 1
		else:
			left.append(_todo[i])
	if not left.is_empty():
		fallback_tasks += left.size()
		var keep: Array[PairFight] = _todo
		_todo = left
		_each(_todo.size(), _pair_task, threaded)
		_todo = keep


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
	if _cancelled:
		return
	var p: PanelJob = _admitted[i]
	p.result = _service.panel_core(p.profile, p.realm, p.id, p.warm, p.start_k, p.coarse, p.counts, game_seed, season)


func _pair_task(i: int) -> void:
	if _cancelled:
		return
	var f: PairFight = _todo[i]
	f.score = _service.fight_score(profiles[f.a], profiles[f.b], f.seed, true)
