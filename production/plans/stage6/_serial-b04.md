# Stage 6 Serial — `b04`

**Tag:** `b04` (10 owners: `van_khoi`, `van_hac`, `vu_an`, `binh_thuy`, `coc_vu`, `ham_nguyet`, `lanh_giang`, `thoi_tinh`, `trac_anh`, `cuu_cao`)
**Mode:** Decisions auto-accepted per 2026-11-26 waiver and logged below.

## 1. Pending Engine Words

- **0 pending words** across all 10 `b04` owners (`pending.json` absent across all 10; `words: {}` in every `.reviewed`). No GDD / `FIGHT-INPUT.md` additions were needed.

## 2. Python / GDScript Parity Audit & Bug Fix

Inspected every action, event, readable, filter, `mod`/`temp_mods`, `limit`, counter, and state across all 10 `b04` staged `design/stage6-staging/<owner>/effects/*.effects.json` and `arts/part-sect-*.json` against both `tools/design/combat_sim/` (`engine.py`, `fight.py`) and `src/gameplay/combat/fight/` (`fight.gd`, `defence_path.gd`, `effect_runner.gd`, `effect_compiler.gd`, `fighter_state.gd`, `fighter_profile_loader.gd`, `build_file_compiler.gd`).

Specifically verified across both engines:
- `not_tags` inside `mod` (in `always` records), `status_immune`, `delay_immune`, `decoy_struck`, `qi_drained`, `ward_grow`, `fire_art`, `body_shield`, `ignore_taken`, `outside_budget`, `summon`, `heal_restored`, `heal_overflow`, `good-rain-rooted` combined stance, `foe.counter.*`, `upkeep`, `strip`, `silence`, `bound`, `timer`, and `state {set/toggle}`.

### Bug found & fixed (`foe.counter.*` compiler warning)

- **Symptom:** Compiling `van_hac`'s `Silence After the Twelfth` and `ten-thousand-ravines` (which read `foe.counter.resonance`) in GDScript emitted 7 spurious compiler warnings (`"effect reads own counter 'resonance' that nothing writes"`) because `EffectCompiler._read()` checked `if pre == "counter." and not counters.has(r.param):` regardless of `r.side`.
- **Fix:** [effect_compiler.gd:241-243](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/combat/fight/effect_compiler.gd#L241-L243) — gated the check on `r.side == 0` (`if pre == "counter." and r.side == 0 and not counters.has(r.param):`), matching Python `engine.py` where `own.counter.*` vs `foe.counter.*` are tracked separately.
- **Twin unit tests (watch fail -> fix -> pass):**
  - Python: `t_foe_counter_read_and_write` in [test_engine.py:1596-1609](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/test_engine.py#L1596-L1609).
  - GDScript: `test_foe_counter_compiles_without_own_counter_warning_and_triggers` in [fight_depth_test.gd:943-960](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/unit/combat/fight_depth_test.gd#L943-L960) (watched FAIL `56 test cases | 0 errors | 1 failures` before fix -> PASS after fix).

### Standalone Compilation & Execution

All 10 `b04` owners' staged files (`35` effects, `40` arts) compiled and ran with zero errors and zero warnings in both engines:
- Python (`engine.validate` + `Fight.run`): `35 effects, 40 arts`, `0` errors.
- GDScript (`BuildFileCompiler` + `FighterProfileLoader` + `EffectCompiler` + `Fight.run`): `effects=35 arts=40 errs=0 warns=0`.

## 3. Exact Parity Fixture (`t30_b04_exact`)

- **Fixture:** [t30_b04_exact.json](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/fixtures/t30_b04_exact.json) (`chance_free: true`, `seed: 301`, `slice: 30`), registered in [combat_parity_test.gd:27](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/combat_parity_test.gd#L27).
- **Expected trace:** [t30_b04_exact.json (expected)](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/expected/t30_b04_exact.json) — `winner: B`, `t_ms: 70000`, `rows: 7559` (`A hp -2839.8/8531.7`, `B hp 5310.1/9384.9`).
- **Sides:**
  - **Side A** (`thoi_tinh`, `cuu_cao`, `trac_anh`, `binh_thuy`, `van_khoi` + `gathering-wave` baseline): fires `wash-the-feet` (`body_shield` + `ignore_taken`), `haul-in-hold`/`clear`, `quench-brittle`, `ninth-blow` (`not_tags` mod), `white-heat`, `makers-fold`, `crane-descends` (`timer` + `mod`), `A Crane for the Rider`, `Brittle from Its Own Blow`, `Drag It to the Ice`, `Heat the Edge` (`sure_crit`), `Sit and Watch`, `Sky Iron Sings`, `Slack Water`, `The King Answers`, `The Line Holds`, `The Tenth Layer` (`heal` + `heal_overflow`).
  - **Side B** (`van_hac`, `lanh_giang`, `coc_vu`, `ham_nguyet`, `vu_an` + `rooted-form`): fires `Silence After the Twelfth` (`foe.counter.resonance`), `Pines in Ten Thousand Ravines`, `Empty Ravine` (`strip`), `echo-wall`, `good-rain-merge-rooted` / `good-rain-open-rooted` (`good-rain-rooted` combined stance), `Rain That Does Not Stop`, `The Good Rain Knows Its Season`, `Water Wears the Stone`, `Moistens Without a Sound`, `Seedling Breath`, `What Hurts You, Wrap` (`ward_grow` / absorb), `Answers Twice` (`broken` counter, `fire_art` skipped under no-match), `The Pearl Remembers`, `The Mist Does Not Ask`, `Nobody Looked`, `Out of the Mist`, `The Wind Lifts the Mist`, `Full Pool`, `Grain Channel`, `Lock the Road`, `Moon on Water`, `Line Through Ice` (`qi_drained`), `Plucked String`, `Held Breath`, `Hidden Gate`.

## 4. Decisions (Auto-Accepted)

1. **`effect_compiler.gd` `foe.counter.*` check scoped to `r.side == 0`**: Avoided touching staged `van_hac` files; reading `foe.counter.<id>` does not require `own` to write that counter.
2. **Chance-free design of `t30_b04_exact.json`**: Excluded `the-water-has-ended` and `empty-lungs` (which grant `status_resist` and trigger RNG status-resistance rolls) and excluded single-stance alternates (`not-counting-the-steps`, `sitting-in-the-snow`, `marching-dirge`, `reed-bed`) so `wash-the-feet`, `good-rain-rooted`, `wrap-the-grain`, and `lock-the-road` (`own.state.any == 0`) exercise cleanly; set `acc: 2.0`, `evade: 0.0`, `crit: 0.0` so evade buffs do not cause RNG evade rolls while `Heat the Edge` `sure_crit` stays deterministic.

## 5. Verification

All checks run after final edits:
- `python -I tools/design/combat_sim/parity_export.py --check --quick`: **PASS** (`42` exact fixtures + `sim_defaults.json` match).
- `python -I tools/design/combat_sim/test_engine.py`: **PASS** (`0 failed`).
- `C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/combat --ignoreHeadlessMode`: **PASS** (`135 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans`, `6/6` suites, `1s 804ms`).
- `C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/parity --ignoreHeadlessMode`: **PASS** (`12 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans`, `2/2` suites, `1min 38s 223ms`).

SERIAL DONE
