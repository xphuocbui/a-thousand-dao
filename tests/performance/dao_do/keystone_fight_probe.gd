extends SceneTree
## Evidence probe (not a gdUnit test): a Core Formation Character holding three Đạo Đồ keystones (Fire Lotus, Autumn
## Harvest, Unyielding Breath) and the crown notable Burning Ground fights the typical same-realm enemy in the game's
## engine; prints the held Effects, the fighter's Effect ids, how often each tree Effect fired and the result.
##   godot --headless --path . -s res://tests/performance/dao_do/keystone_fight_probe.gd

const HELD := [9008, 4786, 4787, 3366]


func _init() -> void:
	var gd := GameData.load_from("res://assets/data")
	var tree := DaoDoTree.load_map(gd)
	var c := Character.new()
	c.name = "Keystone probe"
	for def in gd.thien_phu_defs():
		c.thien_phu[def.id] = 60
	c.linh_can.elements = {"hoa": 70.0, "tho": 55.0}
	c.realm_index = 2
	c.level = Ladder.stage_first_level(gd, 2, 1)
	c.level_peak = c.level
	c.tree_nodes = [int(tree.starts.hoa)] + HELD
	var db := WorldDB.new()
	var sheet := StatSheet.build(c, gd, db, tree)
	print("held Effects: ", tree.held_effects(c))
	for m in sheet.sources("crit_damage_pct"):
		print("sheet line: crit_damage_pct ", m.value, " from ", m.source)
	var report: Array = []
	var errors: Array = []
	var me: FighterProfile = FighterCompiler.compile(c, gd, db, sheet, report, errors)
	if me == null:
		print("compile failed: ", errors)
		quit(1)
		return
	var foe: FighterProfile = FighterCompiler.from_data("typical", 2, gd, errors)
	var k := CombatConstants.from_game_data(gd)
	var fired := {}
	var wins := 0
	for seed in 20:
		var f := Fight.new(me, foe, k, 1000 + seed, Fight.Order.COIN, true)
		var r: FightResult = f.run()
		wins += 1 if r.win_code() == "A" else 0
		for row in f.log_rows():
			if row.kind == FightLogRow.Kind.EFFECT and row.side == "A":
				var eid: String = str(row.to_array()[3])
				if eid.begins_with("eff:"):
					fired[eid] = int(fired.get(eid, 0)) + 1
	print("tree Effects fired over 20 fights: ", fired)
	print("wins against the typical Core Formation enemy: %d of 20" % wins)
	print("what the fight does not run: ", report.filter(func(x): return str(x).contains("Đạo Đồ")))
	quit()
