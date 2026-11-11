# Build session transcript: bare-fist-try1

> The final message of one headless `claude -p` session, saved by the overnight driver.

I've designed the bare-fist build: **The Brimming Hand (Mãn Tức Quyền)**. The sheet, player guide, fight inputs, staging rows, ledger rows and suggestions are all written. The fight check is **NOT ASSESSED**: the skill's fight script runs on out-of-date rules, and my own model of the current rules could not be run tonight. The fight numbers below are worked by hand from the GDD formulas.

**Direction.** I chose "spend the overflow". The cultivator never casts, so the linh lực pool is almost always full. Regeneration a full pool can't hold already exists as a readable "overflow" event. A new Effect, **Stored Breath (Tàng Tức)**, banks it into the next punch: +0.10 to the punch's coefficient per 1 % of maximum linh lực overflowed, up to +1.2. Every point the ward doesn't spend becomes punch, so regeneration, ward strength and ward efficiency all count as damage. The two directions I didn't pick (stances in the art slots, and draining the enemy down to a fistfight) are recorded in the sheet.

**How it's built:**
- **Enabler:** Closed Hand Vow (Bế Thủ Thệ). Ward efficiency +100 while no damaging art is slotted; no damaging arts, damaging talismans or cast wards allowed.
- **Art slots:** they hold wards the game already has (two shields, Iron Shirt, Clear Heart Ward, Soul-Guarding Lamp). A second new Effect, Quiet Channels, adds regeneration for each slot with no art in it.
- **Basic attack stack:** a new flat coefficient stat (Heavy Knuckle), basic attack speed (the Modifier System's Pending row, which needs a rule), an L2 bonus for the basic attack (Worn Knuckles), and several existing Effects (Steady Breath, Bare Rack, Elemental Fist, Still Water, Unyielding Breath).
- **Technique:** a body technique with no arts, Uncarved Stone Fist (Phác Thạch Quyền), on top of the Hậu Thổ main methods that are already in the game.

**Hand-worked results at Nguyên Anh** (all first guesses):

| Opponent | Result |
|---|---|
| Typical cultivator | One punch at 0.667 s |
| Top-end reference caster | Wins at 1.33 s in about half the rolls, otherwise at 2.0 s |
| Same race without Stored Breath | Always 2.0 s; about 22 % less damage per second with a full pool |

- **Damage per second vs the top-end reference caster:** about 0.72 of it at Nguyên Anh and 0.96 at Hóa Thần, at zero cost.
- **It blooms late.** At Kết Đan it has about a quarter of the top-end caster's damage and loses that race, and at Luyện Khí it is a slow, safe brawler (about 30 s against a typical cultivator). I passed the scaling check at the defining realm (Nguyên Anh) and noted this shortfall rather than hiding it.
- **What beats it:** a drainer with staying power (a Qi Disruption boss), which burns the pool so nothing overflows, matching how the technique's founder died in the lore.

**What `fight_calc.py` showed.** It reports 31 of 60 constants out of date and uses the retired ward model. It has the build winning against typical opponents and losing to the top-end profile at 1.0 s. Removing Stored Breath cuts damage by 24–39 % there but changes no result. I recorded these as observations only.

**Checks:** 7 pass, 0 fail, 2 not assessed:
- **Budgets:** the technique's passives and Effects sit outside `bonus_pool`, so only its stat lines could be checked (they pass).
- **The fight:** as above.

**To finish the fight check in the morning,** run `python design/builds/overnight-2026-11-10/builds/bare-fist.sim.py --realm 3`, then again with `--without stored_breath`. It is built on the project's current #44 fight simulator.

**Files in `design/builds/overnight-2026-11-10/`:**
- `builds/bare-fist.sheet.md`
- `builds/bare-fist.md` (player guide)
- `builds/bare-fist.fight.json` (Nguyên Anh)
- `builds/bare-fist.ket-dan.fight.json` (Kết Đan)
- `builds/bare-fist.sim.py` (not yet run)
- `staging-catalogue.md`: 16 new rows, and bare-fist added to Nine Rods Array's "Used by"
- `ledger.md`: rows appended
- `suggestions.md`: 4 entries
  - a basic attack speed stat
  - a flat basic-coefficient stat
  - Effects that wait for your next punch
  - linh lực shares read against the usable maximum (reserved wards would otherwise switch off "full pool" Effects)

BUILD-RESULT: slug=bare-fist status=DONE staged_new=16 staged_reused=1 suggestions=4 checks_fail=0 checks_na=2
