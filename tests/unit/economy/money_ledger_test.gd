extends DaoTestSuite
## The money ledger (design/gdd/regional-economy-trade.md rule 5, Formula H, AC-RE-07): linh thạch moves between named
## holders, mines make it and sinks destroy it, and a season's change of M is minted − burned − player_net.


func _fixture() -> Dictionary:
	var db := WorldDB.new()
	db.put("sects", {"id": "s1", "kind": "great", "status": "active", "treasury": 5000.0})
	db.put("sects", {"id": "s2", "kind": "minor", "status": "active", "treasury": 800.0})
	db.put("people", {"id": "p1", "alive": true, "linh_thach": 120.0})
	db.put("people", {"id": "p2", "alive": true, "linh_thach": 0.0})
	var player := TestFixtures.character({"kim": 50})
	player.linh_thach = 300
	return {"db": db, "player": player, "money": MoneyLedger.new(db, player)}


func test_a_transfer_moves_only_what_the_payer_holds() -> void:
	var f := _fixture()
	var money: MoneyLedger = f.money
	assert_eq(money.transfer("npc:p1", "sect:s2", 500.0, "tribute"), 120.0, "p1 holds only 120")
	assert_eq(money.balance("npc:p1"), 0.0, "p1 is empty")
	assert_eq(money.balance("sect:s2"), 920.0, "s2 got the 120")


func test_the_player_moves_whole_stones_and_counts_as_player_net() -> void:
	var f := _fixture()
	var money: MoneyLedger = f.money
	money.open_season()
	assert_eq(money.transfer("sect:s1", "player", 10.7, "stipend"), 10.0, "whole stones to the player")
	assert_eq(f.player.linh_thach, 310, "the purse is a whole number")
	money.burn("player", 4.0, "refine_fuel")
	var chk: Dictionary = money.season_check()
	assert_eq(chk.player_net, 6.0, "10 in, 4 burned from the player's own purse")
	assert_near(chk.gap, 0.0, 1e-6, "M fell by the 10 the player took; the player's burn is outside M")


func test_a_pool_is_created_on_first_use_and_counts_in_m() -> void:
	var f := _fixture()
	var money: MoneyLedger = f.money
	var before: float = money.money_in_world()
	money.mint("pool:s1", 1000.0, "mine")
	assert_eq(money.balance("pool:s1"), 1000.0, "the commons pool holds the mine's share")
	assert_eq(money.money_in_world(), before + 1000.0, "pools are in M")


func test_random_flows_conserve_money_every_season() -> void:
	# property test: any sequence of transfers, mints and burns among the holders keeps ΔM = minted − burned −
	# player_net, and no balance goes below zero
	var f := _fixture()
	var money: MoneyLedger = f.money
	var holders := ["sect:s1", "sect:s2", "npc:p1", "npc:p2", "pool:s1", "stash:s1", "player"]
	var r := rng(20261120)
	for season in 40:
		money.open_season()
		for k in 60:
			var a: String = holders[r.randi() % holders.size()]
			var b: String = holders[r.randi() % holders.size()]
			var n: float = r.randf_range(0.0, 900.0)
			match r.randi() % 4:
				0:
					money.mint(a, n, "mine")
				1:
					money.burn(a, n, "works")
				_:
					money.transfer(a, b, n, "trade")
		var chk: Dictionary = money.season_check()
		assert_near(chk.gap, 0.0, 1e-6, "season %d: ΔM = minted − burned − player_net" % season)
		for h in holders:
			assert_true(money.balance(h) >= 0.0, "season %d: %s never below zero" % [season, h])


func test_the_built_world_starts_with_purses_pools_and_open_books() -> void:
	var gd := game_data()
	var r := rng(7)
	var db: WorldDB = WorldBuilder.new(gd, TestFixtures.tree()).generate(r, "7")
	var cfg: Dictionary = gd.file("economy").money
	var money := MoneyLedger.new(db)
	var people: Array = db.find("people", func(p): return p.alive and not p.get("is_beast", false))
	for p in people:
		var res: float = float(cfg.reserve_by_realm[int(p.realm_index)])
		var purse: float = float(p.get("linh_thach", -1.0))
		assert_true(purse >= res * float(cfg.purse_start[0]) - 0.01 and purse <= res * float(cfg.purse_start[1]) + 0.01,
			"%s's purse %.2f is within its reserve band" % [p.id, purse])
	var greats: Array = db.find("sects", func(s): return str(s.get("kind", "")) == "great" and str(s.get("status", "")) == "active")
	assert_eq(greats.size(), 7, "seven markets")
	for s in greats:
		assert_eq(money.balance("pool:%s" % s.id), float(cfg.pool_start), "%s's commons pool" % s.id)
	assert_near(money.season_check().gap, 0.0, 1e-6, "the books open at M_0")
	assert_true(money.money_in_world() > 0.0, "M_0 > 0")
