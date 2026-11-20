extends DaoTestSuite
## The fixed cast's hand-authored builds (design/gdd/world-generation.md Core Rule 6): a build is loaded exactly as
## written (root, talents, techniques and layers, gear, the Đạo Đồ start and its targets, skills) and the same every
## game.


func _target_in(area: String) -> int:
	for n in game_data().file("dao_do_map").nodes:
		if str(n.get("kind", "")) == "notable" and str(n.get("area", "")) == area:
			return int(n.id)
	return -1


func _build() -> Dictionary:
	return {"root": {"elements": {"kim": 88.0, "tho": 52.0}}, "thien_phu": {"ngo_tinh": 77, "can_cot": 61, "than_hon": 70, "khi_van": 55, "dao_tam": 80, "mi_luc": 58},
		"archetype": "tran_su", "stage": 1, "main": {"tech": "dia_kim", "layer": 7}, "aux": [],
		"gear": [{"base": "phi_kiem", "grade": 3, "element": "kim"}], "tree": {"start": "kim", "targets": [_target_in("el:kim")]},
		"skills": {"tran_phap": 5}}


func _make(db: WorldDB) -> Character:
	var gd := game_data()
	var p := {"key": "probe_head", "name": "Thử Tông Chủ", "sex": "M", "born": 900, "realm": "ket_dan"}
	var pid: String = db.add("people", {"name": "placeholder"})
	return CastBuilds.make(gd, TestFixtures.tree(), db, ItemFactory.new(gd), BuildGenerator.new(gd, TestFixtures.tree(), db), p, _build(), pid, "", "tong_chu", "", 1200)


func test_a_build_is_loaded_as_written() -> void:
	var db := WorldDB.new()
	var c := _make(db)
	assert_eq(c.linh_can.elements, {"kim": 88.0, "tho": 52.0}, "the authored root")
	assert_eq(int(c.thien_phu.dao_tam), 80, "the authored talents")
	assert_eq(c.archetype, "tran_su", "the archetype")
	assert_eq(int(c.age), 300, "age from the birth year")
	assert_true(c.techniques.has(c.main_tech) and int(c.techniques[c.main_tech].layer) == 7, "the main method at layer 7")
	assert_eq(c.equipped.size(), 1, "the gear piece equipped")
	var target: int = _target_in("el:kim")
	assert_true(c.tree_nodes.has(target), "the route to the authored target is open")
	assert_eq(int(c.tree_points), 0, "every point spent")
	assert_eq(c.skill_level("tran_phap"), 5, "the craft skill")
	var rec: Dictionary = db.get_record("people", c.id)
	assert_eq(str(rec.created_by), "cast", "stored as a cast member")


func test_the_same_build_comes_out_the_same_every_game() -> void:
	var a := _make(WorldDB.new())
	var b := _make(WorldDB.new())
	assert_eq(a.tree_nodes, b.tree_nodes, "the same Đạo Đồ")
	assert_eq(a.linh_can.to_dict(), b.linh_can.to_dict(), "the same root")
