# Stage 6: Tầm Kiếm Đường (`tam_kiem`) — progress file

Method: `production/plans/world-depth-implementation.md` Stage 6 and `production/plans/stage6/_brief-record.md` (headless job, decisions auto-accepted).

## Scope (`python -I tools/design/world/depth_gap.py --sect tam_kiem`)
- **3 techniques** (all element-free, `names: []`): `tracker-sword-primer` (Tier 0 Yellow main), `asking-blade-canon` (Tier 1 Profound main), `seal-listening-art` (Tier 1 Profound secret). Existing references: `mountain-bone-body-art` (`catalogue-body.json`), `afterimage-sword-canon` (`catalogue-blade.json`), `clear-frost-breath` (`catalogue-sect-bang_tam.json`).
- **4 new arts**: `where-it-will-be` (`tracker-sword-primer`), `ask` & `the-blade-answers` (`asking-blade-canon`), `the-silent-place` (`seal-listening-art`).
- **3 signature items**: `tk-asking-blade` (`phi_kiem` 3), `tk-evening-sword` (`phi_kiem` 3), `tk-map-coat` (`dao_bao` 2).
- **1 set**: `tk-map-wall` (`tk-asking-blade`, `tk-map-coat`).
- **2 Effects**: `The Second Duel` (`tk-evening-sword`), `The Answer` (`tk-map-wall` full set).
- **0 beasts**, **0 stand-ins**, **0 unknown_ids**, **0 tie issues**, **2 events** (`N-tam_kiem-01`, `N-tam_kiem-02`, structured).

## Steps
- [x] 1. Verify first: mechanic table, `depth_gap.py --sect tam_kiem`, `spatial_words_check.py --sect tam_kiem`.
- [x] 2. Techniques and arts (staged in `design/stage6-staging/tam_kiem/techniques/catalogue-sect-tam_kiem.json` and `arts/part-sect-tam_kiem.json`; art IDs inserted in `design/world/depth/sects/tam_kiem.techniques.json`).
- [x] 3. Effects (staged 2 Effects in `design/stage6-staging/tam_kiem/effects/tam_kiem.effects.json`; `STANDALONE_OK 2`).
- [x] 4. Items and sets (staged 3 items in `items/catalogue-sect-tam_kiem.json` and 1 set in `items/sets-tam_kiem.json`).
- [x] 5. Stand-ins (0 across all 10 living cast records).
- [x] 6. Beasts (0).
- [x] 7. Holder check (`lint_techniques.py`: 0 findings; `lint_arts.py`: 0 findings; `lint_items.py`: 0 findings; `STANDALONE_OK 2`; `depth_check.py --quiet`: findings none; `spatial_words_check.py`: 0 hits in staged files; `sect_fight.py tam_kiem --seeds 5` at `--gap 0` & `--gap 1` + seed-1 probe: 0 REFUSED across all 10/10 living holders, every slotted art fires, `The Second Duel` runs and `The Answer` changes `tieu_van_phong` `30.5 s 40%` vs `34.9 s 28%`).
- [x] 8. Review file (`production/plans/stage6/tam_kiem-review.md`).
- [x] 9. Finish (`tam_kiem.done` written and validated).

RECORD PASS DONE
