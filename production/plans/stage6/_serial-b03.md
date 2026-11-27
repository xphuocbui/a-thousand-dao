# Stage 6 serial step: wave `b03`

**Owners (10):** `chan_kim`, `chuc_ha`, `hoa_cai`, `hong_dau`, `nhan_tran`, `vu_linh`, `yen_quang`, `le_hoa`, `phat_y`, `thai_chi`
**Date:** 2026-11-27

## Pending words and staged files

- **Pending words across all 10 `b03` owners:** `0` (`pending.json` absent across all 10 owners; `words: {}` in all 10 `.reviewed` files).
- **Staged files untouched:** All 10 `b03` owners' `design/stage6-staging/<owner>/` files had already passed `stage6_merge.py <10 owners> --check` (`0 failure(s)`), and no staged file edits were needed during the parity audit.

## Python/GDScript parity audit across `b03`

Audited all actions, events, readables, filters, `mod`/`temp_mods`, limits, counters (`each_for`, `upkeep`, `decay_per_pulse`, `decay_share`), states (`state {toggle: true}`, `tags: ["composed" | "field"]`), `return_damage`, `status_dur`, `ward_bill`, `strip`, `refresh` (`at_least` / `hold`), `timer {which: "next"}`, `stop_clock`, `burn_qi`, `tick_to_heal`, `heal_overflow` (`scale.floor: false`), `consume`, `next_art_cost`, `refuse_down {hp_share}`, `stacks {side: "own", kind: "debuff"}`, `status_applied` (`event.stacks`), `event.amount > 0`, `per_firing: 1`, `empower` `pay`, and `always` `mod` `art_id` across `tools/design/combat_sim/engine.py`, `tools/design/combat_sim/fight.py`, and `src/gameplay/combat/fight/` (`fight.gd`, `defence_path.gd`, `effect_runner.gd`, `effect_compiler.gd`, `fighter_state.gd`, `fighter_profile_loader.gd`, `build_file_compiler.gd`):

1. **Vocabulary & engine parity:** `0` genuine Python/GDScript divergence or compiler/runner bugs found across any `b03` staged art or Effect.
   - Note: `vl-clear-bell` (`vu_linh`) carries `cast_ward_duration_pct: 15`, which is valid in `lint_techniques.PRICE` / `modifiers.md` and already logged as open in `vu_linh.reviewed` / `vu_linh-checkpoint.md` (`no CHARACTER_MODS/cast_wards reader yet`).
   - Note: `Chars in a Season` (`chuc_ha`, `chc-first-weave-robe`) is intentionally marked `not_run` (out-of-fight seasonal craft/upkeep rule).
2. **Standalone compilation parity (Python & GDScript):**
   - Python (`engine.validate` + `Fight.run`): all active Effects across the 10 `b03` `effects/*.effects.json` and all 52 arts across `arts/part-sect-*.json` validated and ran cleanly (`missing_in_effects: []`).
   - GDScript (`FighterProfileLoader.from_sim_build` + `EffectCompiler.compile` + `Fight.run`): `effects=43 arts=52 errs=0 warns=0` (`0` undefined counters, `0` missing states, `0` warnings).

## Parity fixture

- **Chance-free exact parity fixture ([t29_b03_exact.json](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/fixtures/t29_b03_exact.json) + [expected/t29_b03_exact.json](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/expected/t29_b03_exact.json), registered in [combat_parity_test.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/tests/parity/combat_parity_test.gd)):**
  - **Side A (`b03-kit-a`):** `vu_linh` (`bank-the-kiln-stance`, `hang-a-bell`, `pour-molten-bronze`), `hong_dau` (`the-second-cup`, `a-branch-in-spring`, `gather-more`, `The Second Cup Is Poured`), `chan_kim` (`Nothing False Survives`, `Touchstone`, `True Gold Does Not Fear the Furnace`), `thai_chi` (`Banked Coals`, `Cut to the Root`).
  - **Side B (`b03-kit-b`):** `le_hoa` (`lay-the-seal`, `sit-against-the-door`, `eighth-month-snow`, `one-branch-of-pear`, `Until It Stops Wanting`, `Toll of the Frozen Bolt`, plus committed `shatter-palm` to feed `winter-toll-canon` and `ice >= 5`), `thai_chi` (`grain-rain`, `lingzhi-spores`, `Bitter Medicine`, `Rain on the Sown Field`), `yen_quang` (`dusk-haze`, `Haze Held All Night`, `Unlit`), `chan_kim` (`assay`), `nhan_tran` (`One Goose`).
  - Kept strictly deterministic (`chance_free: true`, `crit: 0.0`, `evade: 0.0`, `acc: 0.5` on both sides so `hang-a-bell` evade stays `0.0`).
  - Exercises `return_damage`, `status_dur` (`50` on `charmed`, `30` on `curse`), `upkeep` (`qi` on `canopy_bell`, `hp` on `furnace_hp_cost`), `state {toggle: true}` (`kiln-banked`), `state {set: "grain-rain"}`, `not_art_id` (`bank-the-kiln-stance`), `ward_bill` (`100`), `strip` (`limit.per_firing: 1` & pulse), `temp_mods` tags/kind/element filters (`kiln-fire-boost`, `one-branch-of-pear` empower `pay`), pulse-counter cadence (`branch_feed`, `grain_rain`, `seal_hold` `decay_per_pulse: 1`, `dusk_heal_store` `decay_share: 0.05`, `spore_ripened` `each_for: 0.5`, `vigil_toll` `each_for: 10`), `stop_clock`, `timer {which: "next"}`, `tick_to_heal`, `heal_overflow` (`scale.floor: false`), `refresh {at_least: 6}`, `consume`, `burn_qi`, `sure_crit`, `refuse_down {hp_share: 0.15}`, `stacks {side: "own", kind: "debuff"}`, `status_applied` (`event.stacks`), and `event.amount > 0`.
  - Exact match across Python and GDScript: `draw` at `66.000 s`, `1916` rows (`A hp -942.9/4692.4`, `B hp -731.5/3839.3`).

## Auto-accepted decisions

1. No new engine words or engine code changes were required for `b03` because all 10 owners' records compiled cleanly in both Python and GDScript with zero parity mismatches.
2. In `t29_b03_exact.json`, gave both sides `acc: 0.5` and `crit: 0.0` (with `shatter-palm` from `family-ice.json` alongside `le_hoa` arts on Side B) so `hang-a-bell`'s per-bell `evade` never triggers RNG rolls while `one-branch-of-pear`'s empower, `Toll of the Frozen Bolt`, `Until It Stops Wanting`, `Unlit`, and `The Second Cup Is Poured` all fire deterministically.

## Verification (after final edits)

- `python -I tools/design/combat_sim/parity_export.py --check --quick`: `41/41` exact fixtures + `sim_defaults.json` match (`same`, including `t29_b03_exact`).
- `python -I tools/design/combat_sim/test_engine.py`: `0 failed`.
- GdUnit `res://tests/unit/combat`: `134/134 PASSED` (`6/6` suites, `0 errors`, `0 failures`, `0 orphans`).
- GdUnit `res://tests/parity`: `12/12 PASSED` (`2/2` suites, `0 errors`, `0 failures`, `0 orphans`).

SERIAL DONE
