# Vạn Hác Viện (`van_hac`): Stage 6 checkpoint review (2026-11-27)

Unanchored review of `design/stage6-staging/van_hac/` against `design/world/depth/sects/van_hac.*`, `van_hac.md`, `design/world/depth/DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, and `production/plans/stage6/_brief-record.md`.

## 1. Ranked Findings & Fixes Applied

1. **[MUST-FIX] Wrong `slowed_time` stack count on `Silence After the Twelfth` (`design/stage6-staging/van_hac/effects/van_hac.effects.json`, `Silence After the Twelfth`)**
   - **What was wrong:** `eff:Silence After the Twelfth rest` and `eff:Silence After the Twelfth finale` applied `"stacks": 3` of `slowed_time` for `3 s`. In `assets/data/combat_engine.json`, `slowed_time_pct` is `0.06` (6 % per stack, cap `5`; `design/gdd/effects.md` AC-EF-72), so `3` stacks produced only `18 %` slower timers rather than the rule's `"its casting is 30 % slower for 3 s"` (`5` stacks).
   - **Fix applied:** Changed `"stacks": 3` to `"stacks": 5` on both `eff:Silence After the Twelfth rest` and `eff:Silence After the Twelfth finale`, and updated `"approx"` to `"Uses stop_clock (foe, 1.0 s) + Slowed Time x5 (30 % slower, 3 s) instead of single-tag Silence so all foe arts stall and slow."`.

2. **[MUST-FIX] `The Earned Rest` and `the-held-rest` clobbered `Silence After the Twelfth`'s 5-stack `slowed_time` (`design/stage6-staging/van_hac/effects/van_hac.effects.json`, `The Earned Rest`; `design/stage6-staging/van_hac/arts/part-sect-van_hac.json`, `the-held-rest`)**
   - **What was wrong:** `eff:The Earned Rest pulse` (and `eff:The Earned Rest finish` / `held-rest-start`) unconditionally applied `slowed_time` with `"stacks": 1, "dur": 1` (or `dur: 2`) and `"cap": 1`. In `engine.py` (`apply_status`) and `fight.gd`, `cap: 1` forces `min(1, st.stacks + 1)` and resets `until` to `t + 1 s`. Whenever `Silence After the Twelfth` applied 5 stacks of `slowed_time` for 3 s on `ha_thinh_tung`, the very next `pulse` of `The Earned Rest` overwrote it back down to `1` stack (`6 %`) for `1 s`. Similarly, `held-rest-start` would clobber an active 5-stack `slowed_time` if `the-held-rest` fired while `Silence After the Twelfth` was still running.
   - **Fix applied:**
     - Split `eff:The Earned Rest finish` status applications into `eff:The Earned Rest finish slow` (`if: own.counter.earned_measures >= 1, foe.status.slowed_time <= 1`) and `eff:The Earned Rest finish breath` (`if: own.counter.earned_measures >= 1, foe.status.heavy_breath <= 1`), ordered before `eff:The Earned Rest finish` resets `earned_measures`.
     - Guarded `eff:The Earned Rest held` with `foe.status.heavy_breath <= 1`.
     - Split `eff:The Earned Rest pulse` into `eff:The Earned Rest pulse slow` (`if: own.counter.held_rest >= 1, foe.status.slowed_time <= 1`) and `eff:The Earned Rest pulse breath` (`if: own.counter.held_rest >= 1, foe.status.heavy_breath <= 1`).
     - Split `held-rest-start` in `part-sect-van_hac.json` into `held-rest-start` (sets `held_rest = 2`) and `held-rest-slow` (`if: foe.status.slowed_time <= 1`, applies `slowed_time` `stacks: 1, dur: 2, cap: 1`).
     - Probe confirmed on `ha_thinh_tung` (`--gap 1`, seed 1) that `Silence After the Twelfth` now lands and preserves `slowed_time` at `5` stacks (`until 9620`, `12223`, `14960` ms) across subsequent pulses without clobbering.

3. **[SHOULD] `The Earned Rest` standalone `held_rest` decrement parity (`design/stage6-staging/van_hac/effects/van_hac.effects.json`, `The Earned Rest`)**
   - **What was wrong:** `The Earned Rest` declares `"held_rest"` in `"counters"` and sets `held_rest >= 1` on `marching-dirge` finale, but relied entirely on `the-held-rest`'s `held-rest-tick` record to decrement `held_rest`. If `The Earned Rest` is compiled without `the-held-rest` slotted (e.g., 6 other arts fill a build's slots), `held_rest` would never decrement and `slowed_time` + `heavy_breath` would stay up permanently.
   - **Fix applied:** Added `held-rest-tick` to `The Earned Rest.records` right before `eff:The Earned Rest pulse slow`. Both `fight.py` (`add_library_effect`) and `BuildFileCompiler` (`_add_library_effect`) deduplicate records by `"id"` after expanding `arts` before `tech_effects`, so when `the-held-rest` is slotted `held-rest-tick` runs once from the art, and when `the-held-rest` is absent `The Earned Rest` supplies `held-rest-tick` itself. Verified via standalone `marching-dirge` + `The Earned Rest` probe (`held_rest` ended at `0.0`, `earned_halvings: 7.0`).

## 2. Specific Verification Notes (No Action Needed)

- **`foe.counter.resonance` & `res_keep` (`ten-thousand-ravines`, `echo-wall`, `Pines in Ten Thousand Ravines`):** Verified `res_keep` computes `floor(R / 2)` (`scale per: 2`), clears `foe.counter.resonance`, and re-adds `res_keep` (`scale per: 1`, then resets `res_keep = 0`) in deterministic record order with no race. `echo-wall-resonance` (`art_fired` on `tags: ["song"]`) fires before `ten-thousand-ravines`'s ring on `art_fired` because `echo-wall` unlocks at L2 and `ten-thousand-ravines` at L4, consistent with "every song art you cast adds 1 Resonance stack to the foe".
- **`echo-wall` (`each_for: 4.0` vs `marching-dirge`) & `event.amount > 0`:** Confirmed `echo-wall` uses `each_for: 4.0, cap: 1` (never clobbers `march` stance) and `echo-wall-heal` guards on `event.amount > 0` (blocked/absorbed hits do not heal).
- **`plucked-pitch` (`1.5 s` cd / `plucked-spend`):** Confirmed `cooldown: 1.5` lets `thorn-lullaby` (`cd: 6.0`) land within the `1.0 s` `plucked_echo` window (`5824 ms` vs `5825 ms` at +3 % art speed), `plucked-boost` uses `on: always` with scope `tags: ["song", "music"]` inside `mod` (covering both `song` arts and `cam` base's `string-cut` `music` tag), and `plucked-arm` runs after `plucked-spend` on `hit_landed` while `plucked-spend-evade` uses `was_evaded` (attacker side).
- **`empty-ravine` (`strip` / `silence`):** Confirmed `strip` (`n: 3`) + `silence` (`tag: "song", dur: 3`) + Force hit (`c_art: 1.4`) matches logged deviation #2 (`target.buffs` does not track source art tags).
- **`vh-tung-phong-cam` (`kind: "treasure"`):** Confirmed `tools/design/items/export_named.py:42` skips `it.get("kind") != "artifact"`, so `vh-tung-phong-cam` stays an open Stage 7 / treasure-export item.
- **Standalone parity & static checklist:** All 4 Effects in `van_hac.effects.json` declare every counter they read/write in `"counters"` and set no stances; 0 `always` records with record-level `filter`; 0 multi-`mod` actions without `stack: true`; 0 `temp_mods` with dropped `art_id`/`status` keys; 0 `decay_per_pulse: 1`; 0 ID/Effect-name collisions against `assets/data/combat_effects.json`, committed `design/`, or other staged directories; 0 stand-ins or beasts; all 18 living builds fit their roots (including `ha_thinh_tung`'s `thorn-and-ink-verses` Wood requirement with Wood 74).

## 3. Pending Words (`pending.json`)

None — `design/stage6-staging/van_hac/pending.json` does not exist; all staged arts and Effects compile and run cleanly on existing engine vocabulary.

## 4. Verification Runs After Final Edits

With `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\van_hac`:
- `python -I tools/design/world/spatial_words_check.py --sect van_hac`: **0 hits** for `van_hac` (`55` non-soft hits across 15 committed `assets/` files only).
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/van_hac/techniques/catalogue-sect-van_hac.json`: checked 3 techniques, **0 findings** (`pine-wind-fingering` 7.2 W of 8, `ten-thousand-ravines-zither-canon` 22.4 W of 24, `the-monks-rest` 13.9 W of 16).
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/van_hac/arts/part-sect-van_hac.json`: checked 5 arts in 1 files, **0 findings**.
- `python -I tools/design/items/lint_items.py design/stage6-staging/van_hac/items/catalogue-sect-van_hac.json`: checked 4 items, 22 bases, 9 common arts, **0 findings**.
- `python -I tools/design/world/depth_check.py`: **findings: none**.

## 5. Holder Table After Fixes (`sect_fight.py van_hac --seeds 5`)

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (`with` vs `without`, `runs`) |
|---|---|---|---|---|---|
| `ha_thinh_tung` | `ket_dan` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines`, `the-held-rest`, `empty-ravine`, `thorn-lullaby` | 28.1 s, 5/5, 100 % | 12.8 s, 0/5, 0 % | Gap 0: `The Earned Rest` 28.1 s 100 % vs 28.3 s 100 % (284 runs); `Pines in Ten Thousand Ravines` 28.1 s 100 % vs 31.9 s 100 % (343 runs); `Silence After the Twelfth` 28.1 s 100 % vs 26.9 s 100 % (30 runs). Gap 1: `The Earned Rest` 12.8 s vs 12.2 s (408 runs); `Pines in Ten Thousand Ravines` 12.8 s vs 10.9 s (527 runs); `Silence After the Twelfth` 12.8 s vs 9.6 s (50 runs) |
| `cu_dong_moc` | `ket_dan` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines`, `the-held-rest`, `empty-ravine` | 35.4 s, 5/5, 48 % | 8.1 s, 0/5, 0 % | Gap 0: `The Earned Rest` 35.4 s 48 % vs 36.2 s 10 % (385 runs); `The Unplayed Note` 35.4 s 48 % vs 38.2 s 0 % (237 runs). Gap 1: `The Earned Rest` 8.1 s vs 8.1 s (240 runs); `The Unplayed Note` 8.1 s vs 8.1 s (140 runs) |
| `quan_tich_am` | `truc_co` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines`, `the-held-rest`, `empty-ravine` | 33.6 s, 2/5, 3 % | 8.0 s, 0/5, 0 % | Gap 0: `The Earned Rest` 33.6 s 3 % vs 32.2 s 0 % (349 runs). Gap 1: 8.0 s vs 8.0 s (238 runs) |
| `khuong_lac_huyen`, `man_ti_truc`, `han_thanh_huong`, `phuong_tung_ban` | `truc_co` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines` | 39.8 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | — |
| `tham_du_van` | `truc_co` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines`, `the-held-rest`, `empty-ravine` | 32.2 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | — (`the-monks-rest` L2 < L4) |
| `ton_thinh_ha`, `cat_minh_huyen`, `yen_to_huyen`, `te_tieu_van` | `luyen_khi` | `marching-dirge`, `echo-wall` | 41.4 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | — |
| `au_tieu_mien`, `thoi_luc_linh`, `manh_tieu_ca`, `co_minh_thach`, `bang_thach_khanh`, `khuc_hanh_ca` | `luyen_khi` | `plucked-pitch`, `thorn-lullaby` | 35.2 s, 5/5, 59 % | 8.0 s, 0/5, 0 % | — |

CHECKPOINT DONE
