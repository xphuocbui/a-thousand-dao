extends DaoTestSuite
## AC-RE-07 on the ticking world (design/gdd/regional-economy-trade.md rule 5, Formula H): over seasons of the real
## WorldTicker, the money in the world changes by exactly what the mines minted less what was burned (no player), and
## no holder goes negative. Deaths settle their purse; new cultivators enter with none.


func test_the_ticking_world_conserves_money_every_season() -> void:
	var gd := game_data()
	var r := RandomNumberGenerator.new()
	r.seed = 7
	var tree := TestFixtures.tree()
	var db: WorldDB = WorldBuilder.new(gd, tree).generate(r, "7")
	var ticker := WorldTicker.new(gd, db, BuildGenerator.new(gd, tree, db))
	var money := MoneyLedger.new(db)
	# old age comes for thirty of them in the first season, so deaths with purses are settled in the books
	var old: Array = db.find("people", func(p): return p.alive and not p.get("is_beast", false) and float(p.get("linh_thach", 0.0)) > 0.0).slice(0, 30)
	for p in old:
		p["age"] = float(gd.realm(int(p.realm_index)).lifespan) + 1.0
	var minted: float = 0.0
	for i in 24:
		ticker.tick(r, 1200 + i / 4, i % 4)
		var chk: Dictionary = money.season_check()
		assert_near(chk.gap, 0.0, 0.5, "season %d: ΔM = minted − burned (M %.0f)" % [i, chk.m_now])
		minted += float(chk.minted)
	assert_true(minted > 24 * 100000.0, "the mines minted about 124,000 a season (%.0f)" % minted)
	assert_true(old.all(func(p): return not p.alive), "the thirty died")
	for s in db.all("sects"):
		assert_true(float(s.get("treasury", 0.0)) >= 0.0, "%s's treasury is not negative" % s.id)
	for p in db.all("people"):
		assert_true(float(p.get("linh_thach", 0.0)) >= -1e-6, "%s's purse is not negative" % p.id)
	for rec in db.all(MoneyLedger.TABLE):
		if rec.has("balance"):
			assert_true(float(rec.balance) >= -1e-6, "%s is not negative" % rec.id)
