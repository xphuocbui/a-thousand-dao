# Stage 6: Lễ Tuyền Phái (record pass, progress file)

Brief: `production/plans/stage6/_brief-record.md` (OWNER = le_tuyen). Headless job, decisions auto-accepted (user, 2026-11-26) and logged in `production/plans/stage6/le_tuyen-review.md`. Resume here: do the first unchecked step.
Staging folder: `design/stage6-staging/le_tuyen/` (mirrors `design/`). Never run git.

## Scope (gap report 2026-11-27, `python -I tools/design/world/depth_gap.py --sect le_tuyen`)
- 3 depth techniques: `dew-gathering-breath` (Yellow main, Wood+Water), `hundred-herb-mending-scripture` (Profound main, Wood), `sweet-spring-wine-rite` (Profound secret, Water, `authored: d39`). Existing in lineage: `still-moon-tide-scripture` (`catalogue-water.json`).
- 6 new arts in depth text: `morning-dew`, `leaf-drip`, `hundred-herb-draught`, `bitter-root`, `open-the-cask`, `last-cup`.
- 6 items (`ltp-sweet-dew-needles`, `ltp-hundred-jar-seal`, `ltp-red-dawn-robe`, `ltp-sweet-spring-cup`, `ltp-cut-wine-cask`, `ltp-cellar-leather`), 2 sets (`ltp-sweet-spring`, `ltp-hundred-jars`), 4 Effects (`Needle of Mending`, `Sealed Cask`, `A Brimming Cup`, `Half Lake`).
- 28 modifier lines (all 28 already run in `fight.py`).
- 2 stand-ins (`khau_dai_ung`, `khau_nhi_dam` on `hoang_tho`); 0 beasts; 0 cross-owner refs.
- No `design/techniques/catalogue-sect-le_tuyen.json` existed (no early promotion).

## Steps
- [x] 1. Verify first: mechanic table logged below and in `le_tuyen-review.md`. `spatial_words_check.py --sect le_tuyen`: 0 non-soft hits in rule fields.
- [x] 2. Techniques and arts (staged): 3 lineage + 1 servants' method (`yoke-and-axle-breath`), 7 new arts (`6` depth + `shoulder-the-yoke`), ids written to `le_tuyen.techniques.json`.
- [x] 3. Effects (staged): 4 entries in `effects/le_tuyen.effects.json`; empty `pending.json` (no new engine words needed).
- [x] 4. Items and sets (staged): 6 items, 2 sets.
- [x] 5. Stand-ins: `khau_dai_ung` and `khau_nhi_dam` switched from `hoang_tho` to `yoke-and-axle-breath`.
- [x] 6. Beasts: none for this owner (`beasts` 0).
- [x] 7. Holder check: `lint_arts.py` (0 findings), `lint_techniques.py` (0 findings), `lint_items.py` (0 findings), `depth_check.py` (findings: none), `depth_gap.py --sect le_tuyen` (`stand_ins: 0`, `unknown_ids: 0`, `engine_words: 0`), `sect_fight.py le_tuyen` and `--gap 1` (0 REFUSED, all arts fire), plus probes for `Needle of Mending` and `A Brimming Cup`.
- [x] 8. Review file: `production/plans/stage6/le_tuyen-review.md`.
- [x] 9. Finish: `RECORD PASS DONE` appended and `production/plans/stage6/le_tuyen.done` written.

## Exact commands (DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\le_tuyen)
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/le_tuyen/arts/part-sect-le_tuyen.json`
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/le_tuyen/techniques/catalogue-sect-le_tuyen.json`
- `python -I tools/design/items/lint_items.py design/stage6-staging/le_tuyen/items/catalogue-sect-le_tuyen.json`
- `python -I tools/design/combat_sim/sect_fight.py le_tuyen --seeds 10`
- `python -I tools/design/combat_sim/sect_fight.py le_tuyen --gap 1 --seeds 10`

RECORD PASS DONE
