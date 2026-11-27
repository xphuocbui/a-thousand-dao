# Stage 6 serial step: wave `b01`

**Owners (10):** `thien_xu`, `lac_ha`, `thuy_vi`, `phuong_minh`, `thinh_vu`, `tung_dao`, `thien_bao`, `cung_tinh`, `hong_lo`, `le_tuyen`
**Date:** 2026-11-27

## Words built (both engines with parity)

1. **`technique-effects`** (`thien_xu`, `lac_ha`, `thuy_vi`, `phuong_minh`, `thinh_vu`, `tung_dao`, `cung_tinh`)
   - Supports technique `effects: [{"name": "...", "unlock_layer": N, ...}]` activated when a fighter's technique `layer >= unlock_layer`.
   - Wired through `tools/design/items/export_techniques.py`, `tools/design/combat_sim/export_combat_library.py` (`tech_effects` map), `tools/design/combat_sim/fight.py` (`expand_library` / `tech_layers` / `tech_effects`), `tools/design/combat_sim/sect_fight.py` (`fight_file` & `effect_names`), `src/gameplay/cultivation/cong_phap.gd`, `src/gameplay/items/item_factory.gd`, `src/gameplay/combat/fight/fighter_compiler.gd`, and `src/gameplay/combat/fight/build_file_compiler.gd`.
   - Deduplicates against item/set/tree Effects via `lib_done` and merges shared `counters` cleanly.
   - Validated in `tools/design/arts/lint_techniques.py` (`name` non-empty string, `unlock_layer` integer in `1..layers`).

2. **`curse-fast`** (`thien_xu` — *Sentence Stands*)
   - Added `curse_fast` to `assets/data/combat_engine.json` (`MOD_KEYS`).
   - When the caster's `curse_fast >= 1`, curses laid via `apply_status` are marked `fast` (`StatusState.fast` in `fighter_state.gd`, `st["fast"] = True` in `engine.py`).
   - `cleanse` in `tools/design/combat_sim/engine.py` and `src/gameplay/combat/fight/effect_runner.gd` skips fast curses; they expire by duration only.

3. **`heal-overflow`** (`thuy_vi` — *The Empty Mountain's Answer*)
   - Added `heal_overflow` to `assets/data/combat_engine.json` (`EVENTS`).
   - Emitted in `heal()` in `tools/design/combat_sim/engine.py` and `src/gameplay/combat/fight/fight.gd` whenever `ov = amount - max(0.0, got) > 0`, carrying `amount: ov`, `share: ov / hp_max` (and `source` when set, plus current event context).
   - `heal_restored` remains strictly gated on `got > 0` so existing listeners (*thorn-lullaby*, *ebb-and-flow*, *marrow-to-dew*, *swelling-tide-palm*) do not fire at 100% HP.

4. **`carried-meter`** (`phuong_minh` — *Playing Past the Break*)
   - Seeds `meters["playing_past_the_break"] = {"start": saved, "p": clamp((than_hon + khi_van) / 400.0, 0.0, 1.0)}` when the fighter unlocks *Playing Past the Break*.
   - Wired in `src/gameplay/combat/fight/fighter_compiler.gd` (reading effective `than_hon`, `khi_van`, and persisted `Character.fight_meters`), `src/gameplay/character/character.gd` (`fight_meters`, `save_fight_meters`, `to_dict`/`from_dict`), `tools/design/combat_sim/sect_fight.py` (`fight_file`), and neutral fallback `{"start": 0.0, "p": 0.25}` in `tools/design/combat_sim/fight.py` and `src/gameplay/combat/fight/build_file_compiler.gd`.

5. **`lint-requires-field`** (`thinh_vu`, `phuong_minh`)
   - Added `"requires"` to `FIELDS` in `tools/design/arts/lint_arts.py` (which also validates inline item arts via `tools/design/items/lint_items.py`) and validates `root_has`/`root_lacks` element lists.

6. **Partial-set Effect threshold fix** (`tung_dao` — *Hold the Quay* 2pc on 3pc `td-cold-ford-charge`)
   - Changed set bonus loading from exact full-set equality (`n == len(pieces)`) to threshold `n >= int(b.get("pieces", len(pieces)))` across `tools/design/combat_sim/fight.py`, `tools/design/combat_sim/sect_fight.py`, `src/gameplay/combat/fight/build_file_compiler.gd`, and `src/gameplay/character/stat_sheet.gd`.

## Words intentionally not built (`not_run`)

- `darkness-element` (`thien_xu` / *The Banner Is Raised*): classified `not_run`; staged proxy left intact.
- `curse-reflect` (`thien_xu` / *A Fair Copy*): classified `not_run`; staged hit-reflect half left intact.

## GDD and docs updated

- `design/gdd/effects.md`:
  - Rule 5: documented `heal_overflow` (separate from `heal_restored`, which stays gated on `got > 0`).
  - Rule 6: documented `curse_fast` (fast curses immune to cleanses, expire by duration only).
- `tools/design/combat_sim/FIGHT-INPUT.md`: added Stage 6 batch `b01` section documenting `curse_fast`, `heal_overflow`, `tech_effects`/`tech_layers`, `playing_past_the_break` carried meter seeding, and partial-set bonus threshold `pieces`.

## Tests and parity fixture

- **Python (`tools/design/combat_sim/test_engine.py` — 5 new tests, watched fail before fix):**
  `t_curse_fast`, `t_heal_overflow`, `t_technique_effects`, `t_carried_meter`, `t_partial_set_effect`.
- **GdUnit (`tests/unit/combat/fight_depth_test.gd` — 5 twin tests, watched fail before fix):**
  `test_curse_fast_holds_curses_through_cleanse_until_expiry`,
  `test_heal_overflow_fires_on_full_hp_and_partial_overshoot_without_waking_heal_restored`,
  `test_technique_effects_attach_by_unlock_layer_and_merge_counters`,
  `test_carried_meter_seeds_playing_past_the_break_and_persists_on_character`,
  `test_partial_set_bonus_runs_its_effect_at_its_piece_threshold`.
- **Chance-free parity fixture:** `tests/parity/fixtures/t27_b01_exact.json` (expected `tests/parity/expected/t27_b01_exact.json`, registered in `tests/parity/combat_parity_test.gd`), exercising `curse_fast`, `heal_overflow` + `heal_restored` gating, and `playing_past_the_break` carried meter + upkeep backlash (A wins at `65.000 s`, 1159 rows, exact event-for-event parity).

## Staged records moved / updated & `pending.json` cleanup

- **Swapped Effects from `pending.json` into staged `*.effects.json`:**
  - `thien_xu`: *Sentence Stands* (`curse_fast: 1`) swapped into `design/stage6-staging/thien_xu/effects/thien_xu.effects.json`.
  - `thuy_vi`: *The Empty Mountain's Answer* (`on: "heal_overflow"`, `event.share / 0.025`) swapped into `design/stage6-staging/thuy_vi/effects/thuy_vi.effects.json`.
- **Restored `requires` fields:**
  - `thinh_vu`: `bronze-answers` (`{"root_lacks": ["thunder"]}`) and `the-chain-carries-it-down` (`{"root_has": ["thunder"]}`) in `design/stage6-staging/thinh_vu/arts/part-sect-thinh_vu.json`.
  - `phuong_minh`: inline art `dawn-call` (`{"root_has": ["light"]}`) on `pm-dawn-call-pipe` in `design/stage6-staging/phuong_minh/items/catalogue-sect-phuong_minh.json`.
- **Cleared resolved `pending` markers** on staged technique Effects: *The Pole Draws from the Vein* (`thien_xu`), *The Glow Deepens* (`lac_ha`), *Birds Pay Court to the Phoenix* & *Playing Past the Break* (`phuong_minh`), *Not a Drop Spilled* & *Return to the Scabbard* (`thinh_vu`), *Answering Wave* & *The Fifteenth Layer* + `pine-wave-true-canon.effects` (`tung_dao`), and *The Twelve Hours* (`cung_tinh`).
- **Deleted all 9 `pending.json` files** under `b01` (`thien_xu`, `lac_ha`, `thuy_vi`, `phuong_minh`, `thinh_vu`, `tung_dao`, `thien_bao`, `cung_tinh`, `le_tuyen`; `hong_lo` had none).

## Auto-accepted decisions

1. Kept `heal_overflow` as a distinct event instead of relaxing `heal_restored` so zero existing heal-triggered Effects change behaviour at full HP.
2. Implemented `curse_fast` with `StatusState.fast` mirroring `talisman_fast`, skipping fast curses in both named-status and category (`curses`) cleanses while preserving normal duration expiry.
3. Exported `tech_effects` in `export_combat_library.py` AND added a `combat_library.json` fallback in `FighterCompiler` so GDScript attaches technique Effects immediately after `stage6_gate.py serial` runs (before Stage 7 re-runs `export_techniques.py`).
4. Persisted carried meters on `Character.fight_meters` (defaulting `start: 0.0`) with a neutral `{"start": 0.0, "p": 0.25}` fallback in bare build files when a build names *Playing Past the Break* without an explicit `meters` entry.
5. Changed set-bonus Effect and modifier activation from `n == len(pieces)` to `n >= int(b.get("pieces", len(pieces)))` in both engines and `StatSheet` so 2pc bonuses on 3pc sets (*Hold the Quay*) activate properly.
6. Left `not_run` words (`darkness-element`, `curse-reflect`) unbuilt as instructed.

## Verification

- **Linters (`DEPTH_STAGE` per owner, all 10 `b01` owners + `phuong_minh/foreign/market-folk` & `thinh_vu/foreign/xuyen_lam`):**
  - `lint_techniques.py`: `0 findings` on every file
  - `lint_arts.py`: `0 findings` on every file
  - `lint_items.py`: `0 findings` on every file
  - Cross-owner ID and Effect-name uniqueness check: `0 collisions`
- **`sect_fight.py` (`DEPTH_STAGE` per owner):** `0 failures`, `0 REFUSED` across all 10 owners (`--seeds 5 --gap 0` and `--gap 1` on the 7 affected owners, `--seeds 3 --gap 0` on the other 3). Verified *The Pole Draws from the Vein*, *The Glow Deepens*, *The Empty Mountain's Answer*, *Birds Pay Court to the Phoenix*, *Not a Drop Spilled*, *Return to the Scabbard*, *Answering Wave*, *Hold the Quay*, and *The Twelve Hours* attach and impact fights cleanly.
- **`parity_export.py --check --quick`:** all 39 exact fixtures + `sim_defaults.json` match (`same`).
- **`test_engine.py`:** `0 failed`.
- **Godot `--headless --import` + GdUnit `res://tests/unit/combat`:** `134/134` PASSED (`6/6` suites, `0 errors`, `0 failures`, `0 orphans`).
- **GdUnit `res://tests/parity`:** `12/12` PASSED (`2/2` suites, `0 errors`, `0 failures`, `0 orphans`), including `t27_b01_exact` and all `compile_parity_test.gd` checks.

SERIAL DONE
