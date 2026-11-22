class_name TooltipChain
extends RefCounted
## The rules of the nested, lockable tooltips (design/ux/hud.md, Tooltips), with no nodes and no clock: the view
## (TooltipLayer) reports what the pointer is over each frame through [method advance], and the elapsed time comes in
## as [param dt], so tests drive it with simulated time.
##
## One chain at a time: a root (level 0, opened from a source) and its children (each opened from a highlighted word
## of the level below). A level is a Dictionary {key, source, content, locked, keyboard, rest, off}:
## [code]source[/code] is the source id (level 0) or the word key that opened it; [code]rest[/code] is how long the
## pointer has rested in it; [code]off[/code] how long the pointer has been off it, its source and its children.

## Seconds of hovering before a tooltip opens (tooltip_delay; player setting 0-2 s).
var delay: float = 0.3
## Seconds of resting in a tooltip before it locks (tooltip_lock_delay; 0.5-3 s).
var lock_delay: float = 1.0
## Seconds an unlocked tooltip stays open with the pointer off it (tooltip_close_grace; 0.3-2 s).
var grace: float = 0.3
## The deepest level (tooltip_depth_max); a word at the last level opens the wiki instead.
var depth_max: int = 5
## Which lock inputs are on (the "Tooltip lock" setting: any of timer, middle click, click).
var lock_timer: bool = true
var lock_middle: bool = true
var lock_click: bool = true
## Resolves a highlighted word's key to its tooltip content ({} when unknown); set by the owner.
var resolve: Callable = func(_key: String) -> Dictionary: return {}

## The open levels, root first.
var levels: Array = []
## Bumped on every open, close or lock, so the view knows to rebuild.
var version: int = 0

var _cand_id: String = ""
var _cand_t: float = 0.0

const EPS := 1e-6


## Reads the knobs from ui_hud.json's "tooltips" block (keys as the spec's Tuning Knobs).
func configure(cfg: Dictionary) -> void:
	delay = float(cfg.get("tooltip_delay", delay))
	lock_delay = float(cfg.get("tooltip_lock_delay", lock_delay))
	grace = float(cfg.get("tooltip_close_grace", grace))
	depth_max = int(cfg.get("tooltip_depth_max", depth_max))
	var modes: Array = Array(cfg.get("tooltip_lock", ["timer", "middle", "click"]))
	lock_timer = modes.has("timer")
	lock_middle = modes.has("middle")
	lock_click = modes.has("click")


## True while any level is open.
func is_open() -> bool:
	return not levels.is_empty()


## True when the chain is locked (locking a level locks every level below it).
func is_locked() -> bool:
	return not levels.is_empty() and bool(levels[0].locked)


## True when a word of level [param level] would open the wiki rather than a tooltip (the last level).
func is_wiki_level(level: int) -> bool:
	return level + 1 >= depth_max


## One frame. [param hit]: {"level": the topmost open level under the pointer (-1 none), "word": the key of the
## highlighted word under the pointer in that level ("" none), "source": the id of the source under the pointer when it
## is over no tooltip ("" none), "content": that source's content}.
func advance(dt: float, hit: Dictionary) -> void:
	var lvl: int = int(hit.get("level", -1))
	var word: String = str(hit.get("word", ""))
	var source: String = str(hit.get("source", ""))
	# Resting in a level locks it (and the levels below) after lock_delay.
	for i in levels.size():
		var L: Dictionary = levels[i]
		if i == lvl:
			L.rest = float(L.rest) + dt
			if lock_timer and not bool(L.locked) and float(L.rest) >= lock_delay - EPS:
				lock(i)
		else:
			L.rest = 0.0
	# Unlocked levels close once the pointer has been off them, their source and their children for the grace.
	var i: int = levels.size() - 1
	while i >= 0:
		var L: Dictionary = levels[i]
		if bool(L.locked):
			break   # everything below a locked level is locked too
		var inside: bool = lvl >= i or _on_source_of(i, lvl, word, source)
		if inside:
			L.off = 0.0
		else:
			L.off = float(L.off) + dt
			if float(L.off) >= grace - EPS:
				_truncate(i)
		i -= 1
	# What would open next if the pointer stays.
	var cid: String = ""
	var content: Dictionary = {}
	if lvl >= 0 and lvl < levels.size() and word != "":
		var child_open: bool = lvl + 1 < levels.size() and str(levels[lvl + 1].source) == word
		var child_locked: bool = lvl + 1 < levels.size() and bool(levels[lvl + 1].locked)
		if not is_wiki_level(lvl) and not child_open and not child_locked:
			cid = "w%d:%s" % [lvl, word]
	elif lvl < 0 and source != "" and not is_locked():
		if levels.is_empty() or str(levels[0].source) != source:
			cid = "s:" + source
			content = hit.get("content", {})
	if cid == "":
		_cand_id = ""
		_cand_t = 0.0
		return
	if cid != _cand_id:
		_cand_id = cid
		_cand_t = 0.0
	_cand_t += dt
	if _cand_t < delay - EPS:
		return
	_cand_id = ""
	_cand_t = 0.0
	if cid.begins_with("s:"):
		if not content.is_empty():
			levels = [_level(source, source, content, false)]
			version += 1
	else:
		_open_child(lvl, word, false)


## A mouse button press. [param hit] as in [method advance]; [param source_clickable] is true when the root source has
## a click action of its own (a button or an alert keeps its click). Returns true when the press is consumed (a click
## outside a locked chain closes it and does not reach what is under it).
func click(button: int, hit: Dictionary, source_clickable: bool) -> bool:
	var lvl: int = int(hit.get("level", -1))
	var source: String = str(hit.get("source", ""))
	if lvl >= 0 and lvl < levels.size():
		if button == MOUSE_BUTTON_MIDDLE and lock_middle:
			lock(lvl)
			return true
		if button == MOUSE_BUTTON_LEFT and lock_click:
			lock(lvl)
		return false
	var on_root_source: bool = not levels.is_empty() and source != "" and str(levels[0].source) == source
	if on_root_source:
		if button == MOUSE_BUTTON_MIDDLE and lock_middle:
			lock(0)
			return true
		if button == MOUSE_BUTTON_LEFT and lock_click and not source_clickable:
			lock(0)
			return false
	if levels.is_empty():
		return false
	var was_locked: bool = is_locked()
	close_all()
	return was_locked


## A highlighted word of [param level] pressed (click, Enter or Q). Returns "wiki" when the word is at the last level
## (the owner opens the wiki page), "opened" when its tooltip opened, "" when nothing happened. A keyboard press opens
## the child locked and keyboard-held (pointer rules never close it).
func press_word(level: int, key: String, keyboard: bool) -> String:
	if level < 0 or level >= levels.size():
		return ""
	if is_wiki_level(level):
		return "wiki"
	if lock_click and not keyboard:
		lock(level)
	return "opened" if _open_child(level, key, keyboard) else ""


## Opens [param content] as a new chain from the keyboard (Q or F2 on a focused source): locked, and held until Esc.
func open_keyboard(source: String, content: Dictionary) -> void:
	if content.is_empty():
		return
	var L: Dictionary = _level(source, source, content, true)
	L.locked = true
	levels = [L]
	version += 1


## Locks level [param i] and every level below it.
func lock(i: int) -> void:
	var changed: bool = false
	for j in mini(i + 1, levels.size()):
		if not bool(levels[j].locked):
			levels[j].locked = true
			changed = true
	if changed:
		version += 1


## Closes the top level (Esc closes only the top tooltip). Returns the closed level, or {} when none was open.
func close_top() -> Dictionary:
	if levels.is_empty():
		return {}
	var top: Dictionary = levels.pop_back()
	version += 1
	return top


## Closes the whole chain (a season change, a window opening over it, a click outside).
func close_all() -> void:
	if levels.is_empty():
		return
	levels = []
	_cand_id = ""
	version += 1


## The source [param source] disappeared: a chain rooted on it closes.
func source_gone(source: String) -> void:
	if not levels.is_empty() and str(levels[0].source) == source:
		close_all()


func _open_child(level: int, key: String, keyboard: bool) -> bool:
	var content: Dictionary = resolve.call(key)
	if content.is_empty():
		return false
	_truncate(level + 1)
	var L: Dictionary = _level(key, key, content, keyboard)
	if keyboard:
		L.locked = true
		for j in levels.size():
			levels[j].locked = true
	levels.append(L)
	version += 1
	return true


func _on_source_of(i: int, lvl: int, word: String, source: String) -> bool:
	if i == 0:
		return lvl < 0 and source != "" and source == str(levels[0].source)
	return lvl == i - 1 and word == str(levels[i].source)


func _truncate(n: int) -> void:
	if levels.size() > n:
		levels.resize(n)
		version += 1


static func _level(key: String, source: String, content: Dictionary, keyboard: bool) -> Dictionary:
	return {"key": key, "source": source, "content": content, "locked": false, "keyboard": keyboard, "rest": 0.0, "off": 0.0}
