class_name AliveLayer
extends Control
## The map's alive layer (user 2026-11-23: "animated water, cloud shadows, seasonal snow, chimney smoke"; design/ux/hud.md
## Map zoom, Alive layer). It runs the clock the terrain shader's water, rivers and clouds move by, and draws the chimney
## smoke over the settlements' symbols. MapView owns it as a child drawn above its own drawing and tells it where the
## smoke rises each time the view changes. Under reduced motion the clock stands still and nothing is drawn moving.
## Display only.

## ui_hud.json greybox.alive: {enabled, smoke: {kinds, puffs, period_s, rise, size, drift, alpha, colour, from_px}}.
var _cfg: Dictionary = {}
var _terrain: TerrainView = null
var _time: float = 0.0
var _reduced_motion: bool = false
var _sources: Array = []   # [[Vector2 chimney point in local px, float symbol side px, float phase 0..1]]


func _init() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_preset(Control.PRESET_FULL_RECT)


## Sets the config ([param cfg], ui_hud.json greybox.alive) and the terrain view whose clock this layer runs.
func setup(cfg: Dictionary, terrain: TerrainView) -> void:
	_cfg = cfg
	_terrain = terrain
	_apply_motion()


## Reduced motion: the clock stops and the smoke is not drawn (the snow, a season's state, stays).
func set_reduced_motion(on: bool) -> void:
	_reduced_motion = on
	_apply_motion()


## Whether the layer is moving now (enabled, and reduced motion off).
func is_running() -> bool:
	return bool(_cfg.get("enabled", false)) and not _reduced_motion


## The clock now, in seconds (for tests).
func clock() -> float:
	return _time


## Sets the clock to [param seconds] (screenshots at a chosen moment; tests).
func set_clock(seconds: float) -> void:
	_time = seconds
	if _terrain != null:
		_terrain.set_alive_time(_time)
	queue_redraw()


## Where the smoke rises: [param sources] = [[local px of the chimney, symbol side px, phase 0..1]], from MapView's draw.
func set_smoke_sources(sources: Array) -> void:
	_sources = sources
	queue_redraw()


## How many chimneys smoke in view now (for tests and the shots).
func smoke_count() -> int:
	return _sources.size()


## The settlement kinds that smoke (ui_hud.json greybox.alive.smoke.kinds).
func smoke_kinds() -> Array:
	return (_cfg.get("smoke", {}) as Dictionary).get("kinds", ["city", "town", "great_seat", "minor_seat", "village"])


## The zoom (px per tile) from which the smoke shows.
func smoke_from_px() -> float:
	return float((_cfg.get("smoke", {}) as Dictionary).get("from_px", 12.0))


func _apply_motion() -> void:
	set_process(is_running())
	if not is_running():
		_time = 0.0
		if _terrain != null:
			_terrain.set_alive_time(0.0)
	queue_redraw()


func _process(delta: float) -> void:
	_time += delta
	if _terrain != null:
		_terrain.set_alive_time(_time)
	if not _sources.is_empty():
		queue_redraw()


func _draw() -> void:
	if not is_running() or _sources.is_empty():
		return
	var sm: Dictionary = _cfg.get("smoke", {})
	var puffs: int = int(sm.get("puffs", 3))
	var period: float = maxf(0.5, float(sm.get("period_s", 4.0)))
	var rise: float = float(sm.get("rise", 0.9))       # symbol sides a puff rises before it is gone
	var grow: float = float(sm.get("size", 0.16))      # a puff's largest radius, in symbol sides
	var drift: float = float(sm.get("drift", 0.35))    # sideways drift over the rise, in symbol sides (the wind)
	var alpha: float = float(sm.get("alpha", 0.45))
	var col: Color = Color.from_string(str(sm.get("colour", "#d8d2c4")), Color(0.85, 0.82, 0.77))
	var ink: Color = Color.from_string(str(sm.get("outline", "#5a4c3c")), Color(0.35, 0.3, 0.24))
	for s in _sources:
		var at: Vector2 = s[0]
		var side: float = s[1]
		for k in puffs:
			var f: float = fposmod(_time / period + float(k) / float(puffs) + float(s[2]), 1.0)   # 0 born .. 1 gone
			var p: Vector2 = at + Vector2(drift * side * f * f + sin(f * 6.0 + float(s[2]) * 10.0) * side * 0.03, -rise * side * f)
			var r: float = side * grow * (0.35 + 0.65 * f)
			var a: float = alpha * sin(f * PI) * (1.0 - f * 0.4)
			draw_circle(p, r + 0.7, Color(ink, a * 0.18), true, -1.0, true)   # a faint ink edge so it reads on pale land
			draw_circle(p, r, Color(col, a), true, -1.0, true)
