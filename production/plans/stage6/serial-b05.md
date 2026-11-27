# Stage 6 Serial — `b05`

**Tag:** `b05` (10 owners: `clans`, `da_quang`, `ho_lam`, `ngao_tuyet`, `tuan_tung`, `hoa_tinh`, `lang_dao`, `suong_tung`, `tam_kiem`, `tran_sa`)
**Mode:** Decisions auto-accepted per 2026-11-26 waiver and logged below.

## 1. Pending Engine Words & Pre-Flight Cleanup

- **0 pending words** across all 10 `b05` owners (`words: {}` in every `.reviewed` under `production/plans/stage6/`). No GDD / `FIGHT-INPUT.md` engine-word additions were needed.
- **Empty `pending.json` cleanup:** Deleted the 3 empty `pending.json` files (`{"words": [], "arts": [], "effects": {}}`) in `design/stage6-staging/hoa_tinh/pending.json`, `design/stage6-staging/lang_dao/pending.json`, and `design/stage6-staging/suong_tung/pending.json`.

## 2. Deferred Linter Scope Items (`lint-bleed-scope` & `bow`)

Both `"bleed"` and `"bow"` were verified as supported modifier scopes in the GDD and both combat engines:
- **GDD ([modifiers.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/gdd/modifiers.md)):** Rules 9 and 11 list `"bleed"` (narrow, matching effects/statuses/tags) and `"bow"` (family, matching weapon form tags).
- **Python (`tools/design/combat_sim/fight.py`, `engine.py`):** `passive_effect` forwards unknown technique/item scope tags directly into `m["tags"]` (`CTX_MODS` including `status_dur`, `L1`, `crit_mult`); `apply_status` passes `(kind, sid)` in `sctx["tags"]` so `status_dur` matches `["bleed"]`, `crescent-of-red-sand` carries `tags: ["fire", "sabre", "bleed"]`, and `the-leader-first` / `pinning-arrow` / `nocked-arrow` carry `"bow"` in `tags`.
- **GDScript (`src/gameplay/combat/fight/build_file_compiler.gd`):** `_passive_effect` mirrors `fight.py`, copying scope tags into `m["tags"]` with identical tag matching.

Changes made (following watch fail -> fix -> pass):
1. Added twin unit tests first:
   - Python: `t_lint_bleed_and_bow_scopes` in [test_engine.py:1612-1643](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/test_engine.py#L1612-L1643) (watched fail `2 failed` before fix -> pass `0 failed` after fix).
   - GDScript: `test_bleed_and_bow_scopes_compile_and_apply_to_matching_tags_only` in [fight_depth_test.gd:964-998](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/unit/combat/fight_depth_test.gd#L964-L998).
2. Updated `TIER` in [lint_techniques.py:73-77](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/arts/lint_techniques.py#L73-L77): added `"bow"` under `"family"` and `"bleed"` under `"narrow"`.
3. Restored `scope: ["bleed"]` on `night-glow-blood-sabre-canon` passives (`status_duration_pct` 15, `attack_pct` 10) in [catalogue-sect-da_quang.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/da_quang/techniques/catalogue-sect-da_quang.json). Verified `lint_techniques.py` (`0 findings`), `lint_arts.py` (`0 findings`), `lint_items.py` (`0 findings`), and `sect_fight.py da_quang --seeds 3` (`0 REFUSED`).
4. Restored `scope: ["bow"]` on `pine-warden-staff-and-bow-canon` (`attack_pct` 6, `crit_damage_pct` 20) in [catalogue-sect-tuan_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/techniques/catalogue-sect-tuan_tung.json) and `ttg-wolf-winter-bow` (`attack_pct` 21) in [catalogue-sect-tuan_tung.json (items)](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tuan_tung/items/catalogue-sect-tuan_tung.json). Verified `lint_techniques.py` (`0 findings`), `lint_arts.py` (`0 findings`), `lint_items.py` (`0 findings`), and `sect_fight.py tuan_tung --seeds 3` (`0 REFUSED`).

## 3. Python / GDScript Parity Audit & Standalone Compilation

Inspected all staged `arts/*.json` (`40` arts) and `effects/*.effects.json` (`39` Effect entries) across all 10 `b05` owners against Python (`tools/design/combat_sim/engine.py`, `fight.py`) and GDScript (`src/gameplay/combat/fight/`). Verified zero engine parity bugs across `temp_mods`, `on: "always"`, `timer`, `each_for` + `cap: 1`, combined stances (`bark-closes` / `rooted-bark`, `hold-the-sand` / `hold-the-sand-iron`), `refuse_down`, `stop_clock`, `fire_art`, `dampen_taken`, `art_cost_hp`, `hp_cost_red`, `next_art_cost`, `burn_qi {of: "max"}`, `scale {floor: false}`, `tag.foreseen`, `own.since.*`, `upkeep`, and `decay_per_pulse`:
- Python standalone (`validate` + `Fight.run`): `40 arts, 39 effects, 0 errors`.
- GDScript standalone (`BuildFileCompiler` + `FighterProfileLoader` + `EffectCompiler` + `Fight.run`): `79 cases, errs=0, warns=0`, with `78/79` deterministic traces identical (`tam_kiem:ask` differed only because its `ask-mark-crit` Effect grants `+5` crit% per stack, triggering RNG crits).

## 4. Exact Parity Fixture (`t31_b05_exact`)

- **Fixture:** [t31_b05_exact.json](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/fixtures/t31_b05_exact.json) (`chance_free: true`, `seed: 311`, `slice: 31`), registered in `DEPTH` at [combat_parity_test.gd:27](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/combat_parity_test.gd#L27).
- **Expected trace:** [t31_b05_exact.json (expected)](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/expected/t31_b05_exact.json) — `winner: B`, `t_ms: 29500`, `rows: 2935` (`A hp -1170.96/17063.44`, `B hp 17063.44/17063.44`, `dealt A=202.27 / B=18573.97`, `ward_paid A=1613.52 / B=1014.76`).
- **Sides (`n_body: 4.0`, `n_qi: 4.0`, `crit: 0.0`, `evade: 0.0`, `acc: 2.0`):**
  - **Side A** (`da_quang`, `ho_lam`, `hoa_tinh`, `lang_dao`, `tam_kiem`; 17 arts, 44 counters, 3 states, 122 effect records; excludes `ask` so `+5` crit/stack cannot cause RNG crits): exercises `crescent-of-red-sand`, `Cut the Horse First`, `Drink After the Raid`, `First and Often`, `One Stroke`, `bark-closes`, `seven-star-talisman`, `Autumn Light on the Screen`, `Pay the Toll`, etc.
  - **Side B** (`clans`, `ngao_tuyet`, `tuan_tung`, `suong_tung`, `tran_sa`; 22 arts, 39 counters, 4 states, 138 effect records; excludes `The Drawn Thread` `chance: 0.4`): fires all 22 arts including `falling-locust-flowers`, `opened-granary`, `pillar-in-the-current`, `shade-of-the-road`, `swallows-return`, `unbroken-thread`, `He Waited`, `Outlast the Drought`, `One Flower on Iron`, `Dawn Shot`, `cold-night-lamp`, `answering-cut`, etc.

## 5. Decisions (Auto-Accepted)

1. **Added `"bow"` and `"bleed"` to `lint_techniques.py` `TIER` and restored staged scopes** on `da_quang` and `tuan_tung` instead of leaving proxy tags, because both are documented in [modifiers.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/gdd/modifiers.md) and supported identically in both engines.
2. **Excluded `ask` (`+5` crit/stack) and `The Drawn Thread` (`chance: 0.4`) from `t31_b05_exact.json`** so the fixture stays strictly chance-free (`crit: 0.0`, `evade: 0.0`, `acc: 2.0`) while covering all 10 `b05` owners across 39 arts and 260 compiled effect records.

## 6. Verification

All checks run after final edits:
- `python -B -I tools/design/combat_sim/test_engine.py`: **PASS** (`0 failed`).
- `python -B -I tools/design/combat_sim/compile_parity_export.py`: **PASS** (`120 cases, 0 refused` in `tests/parity/compile/compile_cases.json`).
- `python -B -I tools/design/combat_sim/parity_export.py --check --quick`: **PASS** (`43` exact fixtures including `t31_b05_exact` + `sim_defaults.json` match).
- `C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . --import`: **PASS** (`exit 0`).
- `C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/combat --ignoreHeadlessMode`: **PASS** (`136 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans`, `6/6` suites, including `fight_depth_test.gd` `57 test cases`).
- `C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . -s -d --remote-debug tcp://127.0.0.1:0 res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/parity --ignoreHeadlessMode`: **PASS** (`12 test cases | 0 errors | 0 failures | 0 flaky | 0 skipped | 0 orphans`, `2/2` suites, exact parity across all `43` chance-free fixtures + statistical parity on all `12` chancy fixtures).

SERIAL DONE
