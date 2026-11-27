# Stage 6 Record Pass — `demonic` (Batch `b06`)

Owner: `demonic` (`design/world/depth/people/demonic.*`)  
Staging root: `design/stage6-staging/demonic/`

## Progress Checklist
- [x] 1. Verify first (depth baseline, `combat_engine.json`, `auth-*`, uniqueness across `assets/data/combat_effects.json`, committed `design/`, and `design/stage6-staging/`)
- [x] 2. Author & lint staged Arts and Techniques + `demonic.techniques.json` ID/carrier updates (`0 findings`)
- [x] 3. Author & validate all 15 staged Effects in `effects/demonic.effects.json` (`15/15` standalone validated, `failures=0`)
- [x] 4. Author & lint staged Items and Sets + normalize `dm-set-blood-ink-study` effect name (`0 findings`)
- [x] 5. Replace all 16 stand-ins in `demonic.cast.json` and `demonic.2.cast.json` (`stand_ins: 0`)
- [x] 6. Beasts (`0` for `demonic` — none)
- [x] 7. Holder verification (`sect_fight.py demonic --seeds 5 --gap 0/1`, targeted probes `P1`–`P5` + pure-soul `Nine Wicks` `5/5`, linters `0 findings`, `depth_check` `findings: none`, `stage6_merge --check` `0 failure(s)`, `spatial_words_check` `0` demonic hits)
- [x] 8. Author `production/plans/stage6/demonic-review.md`
- [x] 9. Finish checklist (`RECORD PASS DONE`) and write `production/plans/stage6/demonic.done`

## Mechanic Classification Table (Verified Scope)
- **Techniques (`9`)**: `blood-ink-canon`, `shade-orchid-breath`, `red-debt-rite`, `borrowed-wick-sutra`, `black-wind-blood-sabre`, `withered-branch-method`, `black-ice-method`, `copper-mountain-bell-canon`, `night-moth-karst-canon` -> `techniques/catalogue-sect-demonic.json`
- **Arts (`6`)**: `borrowed-sleep`, `drink-within-a-breath`, `move-the-sickness`, `black-frost-seal`, `soul-ledger-chime`, `night-moth-ink` -> `arts/part-sect-demonic.json`
- **Items (`12`)**: `dm-blood-red-robe`, `dm-ink-needle`, `dm-blood-seal`, `dm-cracked-bell`, `dm-borrowed-wick-lamp`, `dm-cave-orchid-pendant`, `dm-black-wind-sabre`, `dm-bitter-well-gourd`, `dm-sons-lamp`, `dm-pedlar-robe`, `dm-karst-lamp`, `dm-ink-grinder-robe` -> `items/catalogue-sect-demonic.json`
- **Sets (`3`)**: `dm-set-blood-ink-study`, `dm-soul-pedlar`, `dm-u-lan-keeper` -> `items/sets-demonic.json`
- **Effects (`15`)**: `The Black Under the White`, `Black Thaw`, `The Robe Drinks First`, `Draw the Ink`, `Sealed in His Name`, `The Held Voice`, `Nine Wicks`, `Drink from the Dark`, `Within a Breath`, `His Sister's Water`, `Fed in Blood`, `Lullaby of the Karst`, `Writ in Their Blood`, `A Breath Bought`, `A Breath That Costs No One` -> `effects/demonic.effects.json`
- **Stand-ins (`16 -> 0`)**: 3 in `demonic.cast.json` + 13 in `demonic.2.cast.json`.

RECORD PASS DONE
