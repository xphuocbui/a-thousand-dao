class_name TooltipLayer
extends Control
## The game's own tooltip layer (design/ux/hud.md, Tooltips): nested, lockable, hoverable tooltips above everything.
## Godot's built-in tooltip cannot lock, nest or be hovered into, so sources leave [member Control.tooltip_text] empty
## and carry their tip as metadata instead ([method set_tip]). The rules live in [TooltipChain]; this node feeds it what
## the pointer is over each frame and draws the levels.
##
## A tip is a String (a title only), a content Dictionary, or a Callable(local_pos: Vector2) -> String or Dictionary
## for controls whose tip depends on where the pointer is (an ItemList row, a map place). local_pos is
## [constant Vector2.INF] for a keyboard open (Q): the callable then describes the focused or selected item.
## Content: {id (optional; tells items of one control apart), title, fact, summary, body: Array of String or
## {text, key} (a highlighted word), lines: Array (a Breakdown), wiki: String (the term key, optional)}.
##
## Greybox slice: no title strips at a high UI scale, no gamepad Y / d-pad, no screen-reader announcements yet
## (production/qa/evidence/hud-greybox/README.md lists them).

## A highlighted word at the last level, or an "Open in wiki" button, was pressed.
signal wiki_requested(key: String)

const META := &"tip"
const WORD_META := &"tip_word"

## The rules; configure it from ui_hud.json's "tooltips" block.
var chain := TooltipChain.new()
## Returns the Control that gets focus when a closing tooltip held focus and where it came from is gone (End turn).
var fallback_focus: Callable = func() -> Control: return null
## Returns true while the game state must not be read (the session's background job runs). While it does, the layer
## calls no tip Callable: hovering and Q open nothing new (ADR-0005).
var busy: Callable = func() -> bool: return false

## The input action that opens the focused element's tooltip (Q and F2 by default; rebindable through the InputMap).
const ACTION := &"tooltip_open"

var _width: float = 340.0
var _margin: float = 16.0
var _views: Array = []          # one PanelContainer per open level
var _view_keys: Array = []      # the level identity each view was built for
var _built_version: int = -1
var _root_source: Control = null
var _return_focus: Array = []   # per level: the control focus goes back to when it closes (keyboard)
var _last_input_mouse: bool = true


## Puts [param tip] on [param c] and clears its built-in tooltip (see the class doc for the forms of a tip). A control
## whose mouse filter is IGNORE is set to PASS, so the engine can report it as hovered; PASS still lets the click
## through to its parent.
static func set_tip(c: Control, tip: Variant) -> void:
	c.tooltip_text = ""
	c.set_meta(META, tip)
	if c.mouse_filter == Control.MOUSE_FILTER_IGNORE:
		c.mouse_filter = Control.MOUSE_FILTER_PASS


## Splits authored text where [[key|shown words]] marks a highlighted word into body segments.
static func parse_body(text: String) -> Array:
	var out: Array = []
	var rest: String = text
	while true:
		var a: int = rest.find("[[")
		if a < 0:
			break
		var b: int = rest.find("]]", a)
		if b < 0:
			break
		if a > 0:
			out.append(rest.substr(0, a))
		var inner: String = rest.substr(a + 2, b - a - 2)
		var bar: int = inner.find("|")
		out.append({"key": inner.substr(0, bar) if bar >= 0 else inner, "text": inner.substr(bar + 1) if bar >= 0 else inner})
		rest = rest.substr(b + 2)
	if rest != "":
		out.append(rest)
	return out


## Builds tooltip content for the authored term [param key] of [param terms] (ui_terms.json "terms"); {} when unknown.
static func term_content(terms: Dictionary, key: String) -> Dictionary:
	var t: Dictionary = terms.get(key, {})
	if t.is_empty():
		return {}
	return {"id": key, "title": str(t.get("title", key)), "fact": str(t.get("fact", "")), "summary": str(t.get("summary", "")),
		"body": parse_body(str(t.get("body", ""))), "wiki": key}


func _init() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	ensure_action()


## Adds the tooltip action with its default keys (Q, F2) unless the project or a rebinding already defined it.
static func ensure_action() -> void:
	if InputMap.has_action(ACTION):
		return
	InputMap.add_action(ACTION)
	for k in [KEY_Q, KEY_F2]:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(ACTION, ev)


## Applies the "tooltips" knobs (player settings and designer knobs); takes effect at once.
func configure(cfg: Dictionary) -> void:
	chain.configure(cfg)
	_width = float(cfg.get("width", _width))
	_margin = float(cfg.get("edge_margin", _margin))


## True when [param c] is inside an open tooltip.
func owns(c: Control) -> bool:
	if c == null:
		return false
	for v in _views:
		if v == c or (v as Node).is_ancestor_of(c):
			return true
	return false


## True while a tooltip is open.
func is_open() -> bool:
	return chain.is_open()


## Closes every level (a season change, a window opening over the chain).
func close_all() -> void:
	chain.close_all()
	_sync()


## Esc on a tooltip: closes the top level and returns focus to where it came from (the parent's word, the source, or
## the fallback when the source is gone).
func close_top() -> void:
	if chain.is_open():
		chain.close_top()
		_sync()


## The view of level [param i] (tests and the demo), or null.
func view(i: int) -> Control:
	return _views[i] if i >= 0 and i < _views.size() else null


## The highlighted word buttons of level [param i], in order.
func words(i: int) -> Array:
	var v: Control = view(i)
	if v == null:
		return []
	return v.find_children("*", "LinkButton", true, false)


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		_last_input_mouse = true
	elif event is InputEventKey:
		_last_input_mouse = false
	if event is InputEventMouseButton and event.pressed:
		var mb: InputEventMouseButton = event
		if mb.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			var hit: Dictionary = _hit(mb.position)   # the click's own position (layout coordinates at the root)
			var clickable: bool = _root_source is BaseButton
			if chain.click(mb.button_index, hit, clickable):
				get_viewport().set_input_as_handled()
			_sync()
	elif event.is_action_pressed(ACTION, false, true) and not busy.call():
		var owner_ctl: Control = get_viewport().gui_get_focus_owner()
		if owner_ctl is LineEdit or owner_ctl is TextEdit:
			return
		if owner_ctl is LinkButton and owns(owner_ctl):
			_press_word(owner_ctl, true)
			get_viewport().set_input_as_handled()
			return
		var src: Control = _source_of(owner_ctl)
		if src != null:
			var content: Dictionary = _content_of(src, Vector2.INF)
			if not content.is_empty():
				chain.open_keyboard(_source_id(src, content), content)
				_root_source = src
				_sync()
				_return_focus = [owner_ctl]
				_focus_into(0)
				get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if chain.is_open() and (_root_source == null or not is_instance_valid(_root_source) or not _root_source.is_visible_in_tree()):
		chain.close_all()
	var hit: Dictionary = _hit(get_global_mouse_position())
	var root_before: String = str(chain.levels[0].source) if chain.is_open() else ""
	chain.advance(delta, hit)
	var root_now: String = str(chain.levels[0].source) if chain.is_open() else ""
	if root_now != "" and root_now != root_before and hit.has("control") and str(hit.get("source", "")) == root_now:
		_root_source = hit.control   # a pointer-opened (or replacing) root
		_return_focus = [null]
	_sync()
	_place_all()


## What the pointer is over: the topmost open level and the word in it, or else a source and its content.
func _hit(p: Vector2) -> Dictionary:
	for i in range(_views.size() - 1, -1, -1):
		var v: Control = _views[i]
		if v.get_global_rect().has_point(p):
			var word: String = ""
			for w in words(i):
				if (w as Control).get_global_rect().has_point(p):
					word = str(w.get_meta(WORD_META, ""))
			return {"level": i, "word": word}
	if busy.call():
		return {"level": -1}   # never read game state while the session's job runs
	var hovered: Control = get_viewport().gui_get_hovered_control()
	var src: Control = _source_of(hovered)
	if src == null or not src.is_visible_in_tree():
		return {"level": -1}   # Godot updates its hover only on mouse motion: a hidden control can still read as hovered
	var content: Dictionary = _content_of(src, src.get_global_transform().affine_inverse() * p)
	if content.is_empty():
		return {"level": -1}
	return {"level": -1, "source": _source_id(src, content), "content": content, "control": src}


func _source_of(c: Control) -> Control:
	var n: Node = c
	while n != null and n != self:
		if n is Control and n.has_meta(META):
			return n
		n = n.get_parent()
	return null


func _content_of(src: Control, local: Vector2) -> Dictionary:
	var tip: Variant = src.get_meta(META)
	if tip is Callable:
		tip = (tip as Callable).call(local)
	if tip is String:
		return {} if tip == "" else {"title": tip}
	if tip is Dictionary:
		return tip
	return {}


## A source is the control plus what it describes: the content's id, or its title when it has none (a map place or a
## row named by its text), so moving between two things of one control is a new source.
func _source_id(src: Control, content: Dictionary) -> String:
	return "%d|%s" % [src.get_instance_id(), str(content.get("id", content.get("title", "")))]


## Rebuilds the views when the chain changed (keeping the views of levels that did not change).
func _sync() -> void:
	if chain.version == _built_version:
		return
	_built_version = chain.version
	var n: int = chain.levels.size()
	var keep: int = 0
	while keep < mini(n, _views.size()) and _view_keys[keep] == _identity(keep):
		keep += 1
	# If keyboard focus is inside a level about to close, it goes back to where the lowest closing level came from (its
	# parent's word or its source), else to the fallback: on every close, not only Esc (4.6 dual focus: a freed control
	# would leave keyboard focus nowhere).
	var focus_back: Control = null
	var focus_lost: bool = false
	var owner_ctl: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	for i in range(keep, _views.size()):
		if owner_ctl != null and (_views[i] == owner_ctl or (_views[i] as Node).is_ancestor_of(owner_ctl)):
			focus_lost = true
			for j in range(keep, _views.size()):
				if j < _return_focus.size() and _return_focus[j] != null and is_instance_valid(_return_focus[j]) \
						and (_return_focus[j] as Control).is_visible_in_tree() and not _in_views_from(_return_focus[j], keep):
					focus_back = _return_focus[j]
					break
			break
	for i in range(_views.size() - 1, keep - 1, -1):
		var v: Control = _views[i]
		remove_child(v)
		v.queue_free()
	_views.resize(keep)
	_view_keys.resize(keep)
	for i in range(keep, n):
		_views.append(_build_view(i))
		_view_keys.append(_identity(i))
	if not chain.is_open():
		_root_source = null
	_return_focus.resize(n)
	if focus_lost:
		if focus_back == null:
			focus_back = fallback_focus.call()
		if focus_back != null:
			focus_back.grab_focus()
	for i in n:
		var mark: Label = _views[i].get_meta(&"lock_mark")
		mark.visible = bool(chain.levels[i].locked)
	_place_all()


func _in_views_from(c: Control, from: int) -> bool:
	for i in range(from, _views.size()):
		if _views[i] == c or (_views[i] as Node).is_ancestor_of(c):
			return true
	return false


func _identity(i: int) -> String:
	return "%s|%s" % [str(chain.levels[i].source), str(chain.levels[i].key)]


func _build_view(i: int) -> Control:
	var c: Dictionary = chain.levels[i].content
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.focus_mode = Control.FOCUS_ALL
	panel.custom_minimum_size = Vector2(_width, 0)
	panel.accessibility_name = str(c.get("title", ""))
	panel.accessibility_description = str(c.get("summary", ""))
	var box := VBoxContainer.new()
	panel.add_child(box)
	var head := HBoxContainer.new()
	box.add_child(head)
	var title := Label.new()
	title.text = str(c.get("title", ""))
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title)
	var mark := Label.new()
	mark.text = tr("locked")
	mark.add_theme_font_size_override(&"font_size", 14)
	mark.modulate = Color(1.0, 0.85, 0.4)
	mark.visible = false
	head.add_child(mark)
	panel.set_meta(&"lock_mark", mark)
	for k in ["fact", "summary"]:
		if str(c.get(k, "")) != "":
			var l := Label.new()
			l.text = str(c.get(k))
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.custom_minimum_size = Vector2(_width - 24, 0)
			if k == "fact":
				l.modulate = Color(1.0, 0.92, 0.7)
			box.add_child(l)
	var body: Array = Array(c.get("body", []))
	var focusables: Array = []
	if not body.is_empty():
		var flow := HFlowContainer.new()
		flow.custom_minimum_size = Vector2(_width - 24, 0)
		# No gap of its own: the spaces of the text are kept in the word labels, so punctuation hugs a highlighted word.
		flow.add_theme_constant_override(&"h_separation", 0)
		box.add_child(flow)
		var wiki_level: bool = chain.is_wiki_level(i)
		for seg in body:
			if seg is Dictionary:
				var w := LinkButton.new()
				w.text = str(seg.get("text", "")) + (" ↗" if wiki_level else "")
				LinkStyle.apply(w, str(seg.get("kind", LinkStyle.kind_of_key(str(seg.get("key", ""))))), str(seg.get("variant", "")))
				w.focus_mode = Control.FOCUS_ALL
				w.set_meta(WORD_META, str(seg.get("key", "")))
				w.accessibility_description = tr("opens in the wiki") if wiki_level else tr("has details: Q")
				w.pressed.connect(_press_word.bind(w, false))
				flow.add_child(w)
				focusables.append(w)
			else:
				for word in _words_with_spaces(str(seg)):
					var l := Label.new()
					l.text = word
					flow.add_child(l)
	var lines: Array = Array(c.get("lines", []))
	if not lines.is_empty():
		box.add_child(HSeparator.new())
		for line in lines:
			var l := Label.new()
			l.text = str(line)
			l.add_theme_font_size_override(&"font_size", 14)
			l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			l.custom_minimum_size = Vector2(_width - 24, 0)
			box.add_child(l)
	if str(c.get("wiki", "")) != "":
		var wiki := Button.new()
		wiki.text = tr("Open in wiki")
		wiki.flat = true
		wiki.pressed.connect(func(): wiki_requested.emit(str(c.get("wiki"))))
		box.add_child(wiki)
		focusables.append(wiki)
	# Tab and Shift+Tab move between the highlighted words and wrap around inside the tooltip.
	if not focusables.is_empty():
		add_child(panel)
		var first: Control = focusables[0]
		var last: Control = focusables[-1]
		last.focus_next = last.get_path_to(first)
		first.focus_previous = first.get_path_to(last)
		panel.focus_next = panel.get_path_to(first)
		return panel
	add_child(panel)
	return panel


## Splits plain text into words that keep their spaces ("in them; they" -> "in ", "them; ", "they"; a leading space
## stays on the first word), so the flow row needs no gap and punctuation after a highlighted word sits against it.
static func _words_with_spaces(text: String) -> Array:
	var out: Array = []
	var pieces: PackedStringArray = text.split(" ")
	var lead: String = ""
	for i in pieces.size():
		var w: String = pieces[i]
		if w == "":
			lead = " "
			continue
		out.append(lead + w + (" " if i < pieces.size() - 1 else ""))
		lead = ""
	return out


func _press_word(w: LinkButton, from_q: bool) -> void:
	var level: int = -1
	for i in _views.size():
		if (_views[i] as Node).is_ancestor_of(w):
			level = i
	var key: String = str(w.get_meta(WORD_META, ""))
	var keyboard: bool = from_q or not _last_input_mouse
	var res: String = chain.press_word(level, key, keyboard)
	if res == "wiki":
		wiki_requested.emit(key)
		return
	if res == "opened":
		_sync()
		_return_focus[level + 1] = w
		if keyboard:
			_focus_into(level + 1)


func _focus_into(i: int) -> void:
	var ws: Array = words(i)
	if not ws.is_empty():
		(ws[0] as Control).grab_focus()
	elif view(i) != null:
		var buttons: Array = view(i).find_children("*", "Button", true, false)
		(buttons[0] if not buttons.is_empty() else view(i)).grab_focus()


## Places every level beside what it describes, inside the edge margin, never over it: the root beside its source,
## each child beside its parent (right first, then left).
func _place_all() -> void:
	var area := Rect2(Vector2(_margin, _margin), size - Vector2(_margin, _margin) * 2.0)
	for i in _views.size():
		var v: Control = _views[i]
		v.size = v.get_combined_minimum_size()
		var anchor: Rect2
		if i == 0:
			anchor = _root_source.get_global_rect() if _root_source != null and is_instance_valid(_root_source) else Rect2(get_global_mouse_position(), Vector2.ONE)
		else:
			anchor = (_views[i - 1] as Control).get_global_rect()
			var src_word: String = str(chain.levels[i].source)
			for w in words(i - 1):
				if str(w.get_meta(WORD_META, "")) == src_word:
					anchor = Rect2(Vector2(anchor.position.x, (w as Control).get_global_rect().position.y), Vector2(anchor.size.x, (w as Control).size.y))
		v.global_position = _beside(anchor, v.size, area, i == 0)


static func _beside(anchor: Rect2, sz: Vector2, area: Rect2, allow_vertical: bool) -> Vector2:
	var gap: float = 6.0
	var y: float = clampf(anchor.position.y, area.position.y, maxf(area.position.y, area.end.y - sz.y))
	if anchor.end.x + gap + sz.x <= area.end.x:
		return Vector2(anchor.end.x + gap, y)
	if anchor.position.x - gap - sz.x >= area.position.x:
		return Vector2(anchor.position.x - gap - sz.x, y)
	if allow_vertical:
		var x: float = clampf(anchor.position.x, area.position.x, maxf(area.position.x, area.end.x - sz.x))
		if anchor.position.y - gap - sz.y >= area.position.y:
			return Vector2(x, anchor.position.y - gap - sz.y)
		return Vector2(x, minf(anchor.end.y + gap, area.end.y - sz.y))
	return Vector2(clampf(anchor.end.x + gap, area.position.x, maxf(area.position.x, area.end.x - sz.x)), y)
