extends DaoTestSuite
## ADR-0005 (tooltip layer): every tooltip goes through TooltipLayer.set_tip. A built-in tooltip API anywhere in the game
## code would show Godot's own popup beside the layer, so this scans src/ for them. An integration test because it reads
## files.

const ROOT := "res://src"
## Built-in tooltip setters, as regexes; assigning an empty tooltip_text (set_tip clearing it) is allowed.
const BANNED := [
	["tooltip_text = (non-empty)", "tooltip_text\\s*=(?!\\s*\"\")"],
	["ItemList / PopupMenu set_item_tooltip", "set_item_tooltip\\s*\\("],
	["TabBar / TabContainer set_tab_tooltip", "set_tab_tooltip\\s*\\("],
	["TreeItem set_tooltip_text", "set_tooltip_text\\s*\\("],
	["RichTextLabel push_meta with a tooltip argument", "push_meta\\s*\\([^)]*,[^)]*,"],
]


func test_no_game_code_uses_a_builtin_tooltip_api() -> void:
	var files: Array = []
	_collect(ROOT, files)
	assert_true(files.size() > 50, "the scan found the game code (%d files)" % files.size())
	var hits: Array = []
	for pair in BANNED:
		var re := RegEx.new()
		re.compile(pair[1])
		for f in files:
			var text: String = FileAccess.get_file_as_string(f)
			var lines: PackedStringArray = text.split("\n")
			for i in lines.size():
				if re.search(lines[i]) != null:
					hits.append("%s:%d %s" % [f, i + 1, pair[0]])
	assert_true(hits.is_empty(), "built-in tooltip APIs (use TooltipLayer.set_tip):\n" + "\n".join(hits))


func _collect(dir: String, out: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		_collect(dir.path_join(d), out)
