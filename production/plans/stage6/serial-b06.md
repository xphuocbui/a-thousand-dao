# Stage 6 Serial — `b06`

**Tag:** `b06` (5 outside groups: `market-folk`, `demonic`, `hermits-sages`, `loose-south`, `loose-north`)
**Mode:** Decisions auto-accepted per 2026-11-26 waiver and logged below.

## 1. Pending Engine Words & Pre-Flight Confirmation

- **0 pending words** across all 5 `b06` owners (`words: {}` in every `.reviewed` under `production/plans/stage6/`). No GDD or `FIGHT-INPUT.md` engine-word additions were needed.
- **Top-level `"source"` & empty `pending.json`:** Confirmed `"source": "world-depth:<owner>"` across all 5 staged `.effects.json` files (`market-folk` 17, `demonic` 15, `hermits-sages` 10, `loose-south` 8, `loose-north` 7), `0` `held` + `filter` records, `0` `cap: 1` + `each_for` with `set: 1`, and `0` leftover `pending.json` files under `design/stage6-staging/{market-folk,demonic,hermits-sages,loose-south,loose-north}/`.

## 2. Resolved `lint-song-scope` (`hermits-sages` & `demonic`)

Confirmed `"song"` is supported in all three layers:
- **GDD ([modifiers.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/gdd/modifiers.md)):** Rules 9 and 11 list `"song"` under the `form` family (`family` tier).
- **Python (`tools/design/combat_sim/fight.py`, `engine.py`):** `passive_effect` forwards `"song"` into `m["tags"]` (`CTX_MODS` including `L1`, `art_speed`), matched by `art_ctx()` on both normal and `soul_pct` arts.
- **GDScript (`src/gameplay/combat/fight/build_file_compiler.gd`, `fight.gd`):** `_passive_effect` mirrors `fight.py`, mapping `"song"` into `m["tags"]` and matching `art.ctx.tags`.

Changes made (watch fail -> fix -> pass):
1. Added twin unit tests first:
   - Python: `t_lint_song_scope` in [test_engine.py](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/test_engine.py) (watched fail `1 failed` before fix -> pass `0 failed` after fix).
   - GDScript: `test_song_scope_compiles_and_applies_to_matching_tags_only` in [fight_depth_test.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/unit/combat/fight_depth_test.gd).
2. Added `"song"` under `"family"` in `TIER` in [lint_techniques.py](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/arts/lint_techniques.py).
3. Restored `"scope": ["song"]` on BOTH:
   - `hs-between-the-notes-flute` (`attack_pct` 14, `art_speed_pct` 8) in [catalogue-sect-hermits-sages.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/hermits-sages/items/catalogue-sect-hermits-sages.json).
   - `dm-cracked-bell` (`art_speed_pct` 10) in [catalogue-sect-demonic.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/demonic/items/catalogue-sect-demonic.json).
4. Re-verified for `hermits-sages` and `demonic`:
   - `hermits-sages`: `lint_techniques.py` (`checked 6 techniques, 0 findings`), `lint_arts.py` (`checked 11 arts in 1 files, 0 findings`), `lint_items.py` (`checked 13 items, 22 bases, 9 common arts, 0 findings`), `sect_fight.py hermits-sages --seeds 3` (`0 REFUSED`).
   - `demonic`: `lint_techniques.py` (`checked 9 techniques, 0 findings`), `lint_arts.py` (`checked 6 arts in 1 files, 0 findings`), `lint_items.py` (`checked 12 items, 22 bases, 9 common arts, 0 findings`), `sect_fight.py demonic --seeds 3` (`0 REFUSED`).

## 3. Whole-Catalogue `lint_techniques.py` Check

Ran `lint_techniques.py` across all committed `design/techniques/catalogue-*.json` + staged `b06` catalogues (`market-folk`, `demonic`, `hermits-sages`) with staged `part-sect-*.json` loaded via `DEPTH_STAGE`:
- `checked 247 techniques, 1 findings`: `0` `SUITE_SPLIT`, `0` `SCOPE`, `0` `ART_MISSING` findings; the single finding is the expected staged/committed overlap `DUPLICATE (all) censer-smoke-manual in 2 entries` (early-promoted in `b01`/`b03` and kept in `market-folk` staging for id-merge by `stage6_merge.py`), plus pre-existing `OVER_BUDGET` notes on `bang_tam`/`lac_ha`/`thien_xu`.

## 4. Python / GDScript Parity Audit (`b06`)

Audited all `29` staged arts (`market-folk` 12, `demonic` 6, `hermits-sages` 11) and `51` combat Effects (`market-folk` 16, `demonic` 14, `hermits-sages` 9, `loose-south` 7, `loose-north` 5; `6` `not_run` Effects skipped) across Python (`engine.py`, `fight.py`) and GDScript (`src/gameplay/combat/fight/`), covering `refuse_down`, `protect`, `tick_to_heal`, `timer`, `each_for` + `cap: 1`, `on: "always"`, `hp_cost_red`, `status_dur`, `curse_fast`, `was_hit` (`is_crit`, `dtype: "lightning"`), `wounded`, `shield_broken`, `heal` (`ignore_taken`, `body_shield` decay, `heal_overflow`), `ward_grow` (negative share), `return_damage`, `move_own_debuffs`, `burn_pill`, and `stop_clock`:
- **80 / 80** art+effect cases compiled cleanly in both Python (`F.to_build` + `E.validate`, `0` errors) and GDScript (`BuildFileCompiler` + `FighterProfileLoader`, `errs=0, warns=0`) and produced **0 diffs** in deterministic (`crit=0`, `evade=0`, `acc=2.0`) simulation against `typical[2]`.

## 5. Exact Parity Fixture (`t32_b06_exact`)

- **Fixture:** [t32_b06_exact.json](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/fixtures/t32_b06_exact.json) (`chance_free: true`, `seed: 321`, `slice: 32`), registered in `DEPTH` at [combat_parity_test.gd:27](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/combat_parity_test.gd#L27).
- **Expected trace:** [t32_b06_exact.json (expected)](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/expected/t32_b06_exact.json) — `winner: B`, `t_ms: 71000`, `rows: 3009`, `101` fired Effects (`A hp -4444.72/17063.44`, `B hp 3882.97/17063.44`, `dealt A=146.63 / B=12906.93`, `ward_paid A=1382.32 / B=3689.74`).
- **Sides (`realm: 2`, `n_body: 4.0`, `n_qi: 4.0`, `crit: 0.0`, `evade: 0.0`, `acc: 2.0`):**
  - **Side A (`market-folk`, `hermits-sages`, `loose-north`):** 16 arts (`pill-smoke`, `balance-the-books`, `draw-the-poison`, `apricot-second-spring`, `walking-ward`, `vault-coin-toss`, `ring-the-flaw`, `the-lake-shows-the-moon`, `watchmans-gong`, `cold-light-on-iron-mail`, `second-brewing`, `smoke-over-the-burner`, `the-fifth-month-tune`, `plum-falls-between-notes`, `long-oar-stroke`, `b06-fist-talisman`), 28 counters, 4 states, 87 effect records (including `"song"` scope mod; excludes `Second Spring` because its `status_resist: 50` triggers RNG status rolls).
  - **Side B (`demonic`, `loose-south`):** 7 arts (`borrowed-sleep`, `move-the-sickness`, `black-frost-seal`, `soul-ledger-chime`, `night-moth-ink`, `blood-ink-writ`, `b06-storm-cleanse`), `reserved: 0.09`, `tech_layers: {"withered-branch-method": 9}`, 1 companion, 12 counters, 55 effect records.

## 6. Decisions (Auto-Accepted)

1. **Added `"song"` to `lint_techniques.py` `TIER` (`family`) and restored `"scope": ["song"]`** on `hs-between-the-notes-flute` (`hermits-sages`) and `dm-cracked-bell` (`demonic`), after verifying `modifiers.md`, `fight.py`, and `src/gameplay/combat/fight/` support `"song"` identically.
2. **Excluded `Second Spring` from `t32_b06_exact.json`** because its `status_resist: 50` triggers RNG rolls in `apply_status`, keeping the fixture strictly chance-free (`crit: 0.0`, `evade: 0.0`, `acc: 2.0`) while exercising `wounded` (`No One Drowns`), `cleanse` (`draw-the-poison`), and all 5 `b06` outside groups across 23 arts and 142 effect records.

## 7. Verification

All checks run after final edits:
- `python -B -I tools/design/combat_sim/test_engine.py`: **PASS** (`0 failed`).
- `python -B -I tools/design/combat_sim/compile_parity_export.py`: **PASS** (`128 cases, 0 refused` in `tests/parity/compile/compile_cases.json`).
- `python -B -I tools/design/combat_sim/parity_export.py --check --quick`: **PASS** (`44/44` exact fixtures including `t32_b06_exact` + `sim_defaults.json` match).
- `C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . --import`: **PASS** (`exit 0`).
- `C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/combat --ignoreHeadlessMode`: **PASS** (`137 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans`, `6/6` suites).
- `C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/parity --ignoreHeadlessMode`: **PASS** (`12 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans`, `2/2` suites, exact parity across all `44` chance-free fixtures + statistical parity on all `12` chancy fixtures).

SERIAL DONE
