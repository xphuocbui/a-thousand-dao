# Chân Kim Các (Stage 6 progress)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method", and `production/plans/stage6/_brief-record.md` (`OWNER = chan_kim`, decisions auto-accepted).

## Scope (`depth_gap.py --sect chan_kim` 2026-11-27)
- 3 techniques (`touchstone-primer`, `true-gold-canon`, `hundred-refinings-art`), all element-free (`names: []`), `origin: "authored"`.
- 5 new arts: 4 active (`streak-on-the-stone`, `assay`, `the-furnace-shows`, `part-the-dross`) + 1 passive art (`True Gold Does Not Fear the Furnace`, d31, L4 on `true-gold-canon`).
- 5 items (`ck-hundred-fold-crucible`, `ck-house-weight`, `ck-hallmark-seal`, `ck-refiner-robe`, `ck-counterweight-coin`), 2 sets (`ck-assayer-tools`, `ck-scale-pair`).
- 6 Effects total (1 technique passive art + 2 item + 2 set + 1 item `Touchstone` d38).
- 0 beasts, 0 stand-ins.
- Cross-owner ref: `phung_xich_kim` aux `censer-smoke-manual` (`market-folk`) — ALREADY merged in `design/techniques/catalogue-sect-market-folk.json` and `design/arts/part-sect-market-folk.json` from `b01`.

## Step 1: Mechanic Table
| Record | Kind | Depth Rule | Engine Status / Mapping |
|---|---|---|---|
| `touchstone-primer` | Tech (Y, main) | Element-free outer gate (`names: []`) | Engine has `names: []` on authored `main`/`secret` (`b02`); new Yellow passives sized (8.0 W) |
| `streak-on-the-stone` | Art (L1) | Marks foe after hit: strikes ignore part of resistance | Engine has `hit_landed` + `mod: {pen: 40, for: 5}` |
| `true-gold-canon` | Tech (P, main) | Element-free inner gate (`names: []`), depth passives (b3, b5) | Engine has `names: []` + `technique-effects`; new Profound bonus (`than_thuc_pct: 10`) |
| `assay` | Art (L1) | Strips 1 buff or a share of the ward; if foe has none, next strike crits | Engine has `strip {n: 1}`, `burn_qi` + `pen` (ward share), `sure_crit` |
| `the-furnace-shows` | Art (L2) | Foe loses defence and cannot gain new buffs | Engine has `exposed` (`-100` res, 3 s) + pulse `strip {n: 99}` for 4 s (as `thien_xu` `Sealed Writ`) |
| `True Gold Does Not Fear the Furnace` | Tech Effect (L4, d31) | Each buff stack or Assay ward share stripped restores 1.5% linh lực + 1 Part the Dross stack | Engine has `gain_qi` + shared `dross` (`each_for: 4`) + shared `assay_did_strip` / `touchstone_stripped` counters |
| `hundred-refinings-art` | Tech (P, secret) | Element-free elder refining art (`names: []`) | Engine has `names: []`; new Profound bonus (`attack_pct: 8`) & passives (14.2 W) |
| `part-the-dross` | Art (L1) | Each hit lowers foe's attack slightly and adds to holder's (4 s) | Engine has `each_for: 4` counter `dross` scaling `L1` (+4) and `dampen_taken` (+3, 1v1 model of lowered foe attack) |
| `Nothing False Survives` | Item Effect (`ck-hundred-fold-crucible`) | Foe buffs/wards/borrowed stats burn off 2x faster; out-of-fight item appraisal | Engine has `ward_bill: 50` + `strip {n: 1}` every 2 s (`approx`); appraisal is lore |
| `A Hair Light` | Item Effect (`ck-house-weight`) | 1/fight tip a roll in your favour (dodge, resist, crit) | Engine has `fight_start` charge `hair_light_charges`, `was_hit` grants `evade 25, status_resist 25 (3s)` + `sure_crit` |
| `Touchstone` | Item Effect (`ck-hallmark-seal`, d38) | 1/art firing, first hit on buffed foe strips 1 stack | Engine has `hit_landed` (`kind: art`, `per_firing: 1`) + `strip {n: 1}` + `touchstone_stripped` |
| `Tried and Stamped` | Set Effect (`ck-assayer-tools` 3pc) | Art hit on buffed foe stamps 6s; next buff burns off + 5% hp ward | Engine has `stamped_ttl` + `strip {n: 99}` + `ward_grow {share: 0.05, of: hp}` |
| `A Second Lean` | Set Effect (`ck-scale-pair` 2pc) | Tipped roll 2/fight; after each tipped roll see foe's next art | Engine has +1 `hair_light_charges` + `evade 15, acc 20 (3s)` on tip |

## Steps
- [x] 1. Verify first: mechanic table built; `spatial_words_check.py` clean on `chan_kim`.
- [x] 2. Techniques and arts (staged): `catalogue-sect-chan_kim.json` (3 techniques), `part-sect-chan_kim.json` (4 active arts), art ids inserted in `chan_kim.techniques.json`.
- [x] 3. Effects (staged): `chan_kim.effects.json` (6 Effects, all shared counters declared per Effect).
- [x] 4. Items and sets (staged): `catalogue-sect-chan_kim.json` (5 items, `unique: true`, `sources: ["npc"]`, `rarity: 5` on treasure, R6 `exception` on weapons/body_gear) and `sets-chan_kim.json` (2 sets).
- [x] 5. Stand-ins (`0` open; `censer-smoke-manual` already merged in `b01`).
- [x] 6. Beasts (`0`).
- [x] 7. Holder check:
      - `lint_techniques.py`: 0 findings (`3 techniques`).
      - `lint_arts.py`: 0 findings (`4 arts`).
      - `lint_items.py`: 0 findings (`5 items`).
      - `depth_check.py`: `findings: none`.
      - `depth_gap.py --sect chan_kim`: 0 `unknown_ids`, 0 `stand_ins`, 0 `engine_words`, 0 `wishes_open`.
      - `sect_fight.py chan_kim --gap 0 --seeds 5` & `--gap 1 --seeds 5`: 0 `REFUSED`, all arts fire, all Effects verified (`Touchstone` and `Tried and Stamped` verified against buff-slotted `typical` enemy as well).
- [x] 8. Review file written: `production/plans/stage6/chan_kim-review.md` (`REVIEW DONE`).
- [x] 9. Finish: `production/plans/stage6/chan_kim.done` written.

## Lessons from the Băng Tâm pilot
- [x] Every Effect changes the fight with and without it on its holders, or has a written reason; every art fires.
- [x] No holder slots two stances without a combined stance, and every art defines every stance it sets.
- [x] Each "your X" Effect works for a holder who may lack X.
- [x] Vague words ("ward share", "burns off twice as fast", "slightly", "tipped roll") have their meaning written into the `rule` / `approx`.
- [x] The techniques' new bonuses and passives are sized against the same tier and marked as new in the review.

RECORD PASS DONE
