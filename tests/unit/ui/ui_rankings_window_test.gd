extends DaoTestSuite
## RankingsWindow (design/ux/rankings.md): the top rows, gap rows, the rows around the player, the player's marked row,
## search across hidden rows, the Realm column on the Vấn Đỉnh Bảng, tabs that open another realm, the off state.

const CFG := {"rankings": {"top_rows": 3, "around": 1}}
const REALMS := ["Luyện Khí", "Trúc Cơ", "Kết Đan", "Nguyên Anh", "Hóa Thần"]


static func _view(n: int = 12, me: int = 8, which: String = "1") -> Dictionary:
	var rows: Array = []
	for i in n:
		rows.append({"rank": i + 1, "id": "p%d" % i, "name": "Người %d" % i if i + 1 != me else "Lâm Phong", "sect": "", "stage": "Trúc Cơ Sơ kỳ",
			"realm": "Trúc Cơ", "rating": 2000.0 - i, "base": 2000.0 - i, "offset": 0.0, "power": 5000 - i * 10, "state": "rated", "n": 3,
			"age": 30.0, "you": i + 1 == me})
	return {"on": true, "which": which, "title": "Trúc Cơ", "total": n, "player_rank": me, "player_realm": 1, "rows": rows,
		"last_batch": {"panels": 4, "queued": 5, "panel_fights": 40, "pair_fights": 12}}


func _window(v: Dictionary = _view()) -> RankingsWindow:
	var w: RankingsWindow = auto_free(RankingsWindow.new())
	w.cfg = CFG
	w.realm_names = REALMS
	add_child(w)
	w.show_view(v, "", false)
	return w


static func _find(root: Node, name: String) -> Node:
	return root.find_child(name, true, false)


func test_top_rows_a_gap_the_rows_around_the_player_and_a_tail_gap() -> void:
	var w := _window()
	for r in [1, 2, 3, 7, 8, 9]:
		assert_true(w.row_of_rank(r) != null, "rank %d shown" % r)
	for r in [4, 6, 10]:
		assert_true(w.row_of_rank(r) == null, "rank %d in a gap" % r)
	assert_true(_find(w, "Gap_4-6") is Button and _find(w, "Gap_10-12") is Button, "the gaps are focusable rows")


func test_the_player_s_row_is_marked_in_words() -> void:
	var w := _window()
	var me: Control = w.row_of_rank(8)
	assert_true(me.accessibility_name.contains("you"), me.accessibility_name)
	assert_true(me.get_parent() is PanelContainer, "framed, not tint alone")


func test_a_gap_shows_its_rows() -> void:
	var w := _window()
	(_find(w, "Gap_4-6") as Button).pressed.emit()
	assert_true(w.row_of_rank(5) != null)


func test_search_finds_rows_hidden_in_a_gap_with_their_true_rank() -> void:
	var w := _window()
	w._search.text = "nguoi 5"
	w._on_search(w._search.text)
	assert_true(w.row_of_rank(6) != null, "Người 5 is rank 6, inside a gap")
	assert_true(w.row_of_rank(1) == null, "only matches")


func test_the_top_list_has_a_realm_column() -> void:
	var w := _window(_view(5, 0, "top"))
	var heads: Array = []
	for l in w.body.find_child("ColumnHead", true, false).get_children():
		heads.append((l as Label).text)
	assert_true(heads.has("Realm"), str(heads))


func test_a_tab_opens_that_realm_s_ranking() -> void:
	var w := _window()
	var got: Array = []
	w.open_requested.connect(func(k: String, sub: String, _s: String): got.append([k, sub]))
	(_find(w, "Tab_top") as Button).pressed.emit()
	assert_eq(got, [["rankings", "top"]])


func test_the_off_state() -> void:
	var w := _window({"on": false, "player_realm": 0})
	var found: bool = false
	for c in w.body.get_children():
		if c is Label and str((c as Label).text).contains("off"):
			found = true
	assert_true(found)


func test_provisional_rows_are_tinted_only_among_rated_ones() -> void:
	var v := _view()
	v.rows[1].state = "provisional"
	var w := _window(v)
	assert_true(w.row_of_rank(2).modulate.a < 1.0, "an estimate among rated rows is tinted")
	assert_eq(w.row_of_rank(1).modulate.a, 1.0)
	var all_prov := _view()
	for r in all_prov.rows:
		if not bool(r.you):
			r.state = "provisional"
	var w2 := _window(all_prov)
	assert_eq(w2.row_of_rank(1).modulate.a, 1.0, "a new world, all provisional: no dim table (the header says so)")


func test_the_change_cell_reads_up_down_held_new_and_none_yet() -> void:
	assert_eq(RankingsWindow.move_text({"move": 3, "has_prev": true}), "▲3")
	assert_eq(RankingsWindow.move_text({"move": -2, "has_prev": true}), "▼2")
	assert_eq(RankingsWindow.move_text({"move": 0, "has_prev": true}), "=")
	assert_eq(RankingsWindow.move_text({"move": 0, "new": true}), "new")
	assert_eq(RankingsWindow.move_text({"move": 0, "has_prev": false}), "—", "before any season's results")
	var v := _view()
	v.rows[0]["move"] = 2
	v.rows[0]["has_prev"] = true
	var w := _window(v)
	assert_true(_find(w, "ColumnHead") != null)
	assert_true(w.row_of_rank(1).accessibility_name.contains("up 2"), "the change is spoken")

