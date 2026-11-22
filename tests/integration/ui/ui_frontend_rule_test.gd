extends DaoTestSuite
## ADR-0006 decision 4, the frontend rule: the shipped frontend (src/ui/) names only GameSession members that are
## marked "## Action.", "## Job." or "## Read-only." in game_session.gd (the allowlist is derived from those marks, so a
## new method is covered the day it is marked), and never the debug terminal's code. An integration test because it
## reads files.

const SESSION := "res://src/gameplay/session/game_session.gd"
const UI_ROOT := "res://src/ui"
const BANNED_NAMES := ["TerminalViews", "TerminalIO"]


func test_the_frontend_names_only_allowlisted_session_members_and_no_terminal_code() -> void:
	var allowed: Dictionary = _allowlist()
	assert_true(allowed.size() > 40, "the allowlist was derived from the marks (%d members)" % allowed.size())
	assert_true(allowed.has("cultivate") and allowed.has("run") and allowed.has("has_pending_event") and not allowed.has("sync_player"),
		"actions, jobs and reads are in; internal methods are out")
	var files: Array = []
	_collect(UI_ROOT, files)
	assert_true(files.size() > 10, "the scan found the UI code (%d files)" % files.size())
	var member := RegEx.new()
	member.compile("\\b_?session\\.([A-Za-z_][A-Za-z0-9_]*)")
	var hits: Array = []
	for f in files:
		var lines: PackedStringArray = FileAccess.get_file_as_string(f).split("\n")
		for i in lines.size():
			var code: String = lines[i].split("#")[0] if not lines[i].strip_edges().begins_with("##") else ""
			for m in member.search_all(code):
				if not allowed.has(m.get_string(1)):
					hits.append("%s:%d session.%s" % [f, i + 1, m.get_string(1)])
			for name in BANNED_NAMES:
				if code.contains(name):
					hits.append("%s:%d %s (debug terminal code)" % [f, i + 1, name])
	assert_true(hits.is_empty(), "the frontend rule (ADR-0006) is broken; read through GameQuery / StateSnapshot / Advisor:\n" + "\n".join(hits))


## The GameSession members a frontend may use: every func whose doc comment carries one of the three marks.
static func _allowlist() -> Dictionary:
	var out: Dictionary = {}
	var doc: Array = []
	for line in FileAccess.get_file_as_string(SESSION).split("\n"):
		if line.begins_with("##"):
			doc.append(line)
			continue
		if line.begins_with("func "):
			var name: String = line.substr(5, line.find("(") - 5)
			for d in doc:
				if str(d).begins_with("## Action.") or str(d).begins_with("## Job.") or str(d).begins_with("## Read-only."):
					out[name] = true
		doc = []
	return out


func _collect(dir: String, out: Array) -> void:
	for f in DirAccess.get_files_at(dir):
		if f.ends_with(".gd"):
			out.append(dir.path_join(f))
	for d in DirAccess.get_directories_at(dir):
		_collect(dir.path_join(d), out)
