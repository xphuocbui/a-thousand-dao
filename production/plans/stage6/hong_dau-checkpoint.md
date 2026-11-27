# Hồng Đậu Trang: Stage 6 checkpoint review (2026-11-27, headless job)

Unanchored review of `design/stage6-staging/hong_dau/`, `design/world/depth/sects/hong_dau.*`, and `production/plans/stage6/hong_dau-review.md`, verified directly against `tools/design/combat_sim/engine.py`, `src/gameplay/combat/fight/effect_compiler.gd`, `src/gameplay/combat/fight/effect_runner.gd`, `src/gameplay/combat/fight/fight.gd`, `assets/data/combat_engine.json`, and `assets/data/combat_effects.json`.

## 1. Ranked findings & fixes applied

1. **MUST-FIX — `design/stage6-staging/hong_dau/effects/hong_dau.effects.json` (`The Second Cup Is Poured` / `eff:The Second Cup Is Poured poison`):**
   - *What was wrong:* Used `free_hit` (`c: 0.002`, `dtype: "chaos"`, `pass_shields: true`, `outside_budget: true`) with `limit: {"per_pulse": 1}` and `scale: {"read": "foe.debuff.wood", "per": 1}`. At Trúc Cơ (`lieu_da_thai`), `0.002 * stacks * U_att * M` yields `0.66–1.06` raw damage, which is completely absorbed by the foe's Block (`15.7 * 0.2031 = 3.19`), dealing **`0.0` damage on every trigger hit**. In addition, `free_hit` ignores `stack_power` (`stack_effect_pct` + Wood purity) and `per_pulse: 1` capped multi-batch ticks.
   - *Fix applied:* Replaced `free_hit` + `per_pulse: 1` + `scale` with `return_damage: {"share": 0.1, "dtype": "soul"}` on `tick_dealt` (`filter: {"element": "wood"}`, `if: [{"read": "time", "op": ">", "value": 20}]`), matching the existing `Green Fire` pattern in `assets/data/combat_effects.json`. Updated `"approx"` to describe the 10 % Soul `return_damage` rider. Verified in a tanky Trúc Cơ probe (`n_body=3.0`, seed 1): `73` `return` rows after 20 s (`0.028–0.160` per tick), all > 0.

2. **MUST-FIX — `design/stage6-staging/hong_dau/arts/part-sect-hong_dau.json` (`the-second-cup` / `second-cup-weaken-evade` & `second-cup-weaken`):**
   - *What was wrong:* `second-cup-weaken-evade` listened to `"on": "was_evaded"` instead of `"on": "evaded"`. In `engine.py` and `fight.gd`, `"was_evaded"` fires on the *attacker* when their own art is evaded, while `"evaded"` fires on the *defender* when they evade the foe's art. Consequently, `cup_weaken` was wrongly cleared if the holder's own art was evaded, and was not cleared when the holder evaded the foe's art.
   - *Fix applied:* Changed `"on": "was_evaded"` to `"on": "evaded"` on `second-cup-weaken-evade`, and added `{"read": "foe.status.charmed", "op": "==", "value": 0}` to `second-cup-weaken` so the −20 % art damage dampening strictly applies after the charm ends.

3. **SHOULD — `design/stage6-staging/hong_dau/arts/part-sect-hong_dau.json` (`a-branch-in-spring` / `branch-stop`):**
   - *What was wrong:* When `branch_feed` counted down to `0` after 4 pulses without another Wood poison, `branch_on` remained `1`. A different Wood art (such as `scatter-beans` or `bloodroot-pact`) landing later could trigger `branch-feed` and resume growth of the stopped bean without re-casting `a-branch-in-spring`, contrary to the depth rule (`"it stops growing (and keeps what it has) once the holder goes 4 s without laying another Wood poison"`).
   - *Fix applied:* Added `branch-stop` on `pulse` after `branch-grow` (`if: [own.counter.branch_on >= 1, own.counter.branch_feed == 0]` -> `branch_on = 0`) so growth remains stopped until `a-branch-in-spring` is cast again.

## 2. Verification checklist (parity, uniqueness, fidelity, stand-ins)

- **Stand-in (`te_vong_quy`):** Verified `wutong-dawn-breath` (layer 6) in `design/world/depth/sects/hong_dau.cast.json`. Fits `hoa: 56, tho: 40` root (`names: ["moc", "hoa"]`), `layer: 6 <= 6`, and `hong_dau.md` §5 (`"keeps his own sect's method"`). `wutong-dawn-breath` and its arts `seed-of-spring` and `dawn-call-palm` are already committed in `design/techniques/catalogue-sect-phuong_minh.json` and `design/arts/`. `cross_owner 1` closes when `phuong_minh` exports in Stage 7.
- **Standalone compilation & multi-`mod` parity:** Every Effect in `hong_dau.effects.json` declares its own `counters` (`Planted, Waited, Harvested`: `garden_ripe_t`; others use none), declares zero `states` (zero stance collisions with `marching-dirge` on `nghe_hong_dau`, `lieu_da_thai`, `ha_cuc_thi`), has no `always` record with a record-level `filter`, and has no multi-`mod` records without `stack: true`. `status_dur: 50` with `tags: ["charmed"]` is confirmed supported in both `engine.py` (`sctx["tags"] = (kind, sid)`) and `fight.gd` (`sctx["tags"] = [kind, sid]`).
- **No environment/spatial/cap violations:** Checked all staged techniques, arts, items, sets, and Effects. `"Planted"` in `"Planted, Waited, Harvested"` is bean-planting lore, not spatial Planted immunity.
- **Uniqueness:** Confirmed zero ID collisions across `red-bean-primer`, `canon-of-longing`, `scatter-beans`, `a-branch-in-spring`, `gather-more`, `the-second-cup`, all 7 `hd-*` items, both `hd-*` sets, and all 4 Effect names against `assets/data/combat_effects.json`, committed `design/`, and all other staged `b03` directories. `put_effects.py ... --check` passed with 0 refused (`combat_effects.json would change`).
- **Pending words:** None (`pending.json` absent). All 4 arts and 4 Effects use existing engine words while preserving design intent (`The Second Cup` uses `foe.debuff.wood >= 8` + `refresh` instead of per-batch pause; `Planted, Waited, Harvested` uses `garden_ripe_t >= 6` + `stack_grant: 1` + one-time `consume` harvest).

## 3. Post-fix verification outputs (`$env:DEPTH_STAGE="C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\hong_dau"`)

- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/hong_dau/techniques/catalogue-sect-hong_dau.json`: `checked 2 techniques, 0 findings` (`red-bean-primer` 7.3 W of 8; `canon-of-longing` 22.8 W of 24).
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/hong_dau/arts/part-sect-hong_dau.json`: `checked 4 arts in 1 files, 0 findings`.
- `python -I tools/design/items/lint_items.py design/stage6-staging/hong_dau/items/catalogue-sect-hong_dau.json`: `checked 7 items, 22 bases, 9 common arts, 0 findings` (`7 of 7` unique; 6 weapons/robes carry R6 exception; `hd-phi-hong` is `rarity: 5`).
- `python -I tools/design/world/depth_gap.py --sect hong_dau`: `stand_ins 0`, `unknown_ids 0`, `engine_words 0`, `wishes_open 0`, `cross_owner 1` (`catalogue 1`).
- `python -I tools/design/world/depth_check.py --quiet`: `findings: none`.
- `python -I tools/design/combat_sim/put_effects.py design/stage6-staging/hong_dau/effects/hong_dau.effects.json --check`: `combat_effects.json would change` (0 refused).

## 4. Holder table after fixes (`sect_fight.py hong_dau --seeds 5`, `--gap 0` and `--gap 1`, all 18 living members)

**0 REFUSED across all 18 living members at both `--gap 0` and `--gap 1`.**

| Holder (realm) | `--gap 0` (time, wins, HP) | `--gap 1` | Arts fired & Effect notes |
|---|---|---|---|
| `nghe_hong_dau` (`ket_dan`) | 21.8 s, 5/5, 96 % | 11.5 s, 0/5, 0 % | **The Second Cup**: 21.8 s 96 % / without 22.6 s 100 % (**5 runs** gap 0, **20 runs** gap 1). **Half of a Pair**: `0` (`always` + `tan_hong` absent + `flying-sword-strike` outside 6-art slice; probe w/ sword: 18.87 s, 100 % HP). All 6 arts fire (gap 0 & gap 1). |
| `nghe_xuan_chi` (`ket_dan`) | 21.4 s, 5/5, 91 % | 9.2 s, 0/5, 0 % | **Planted, Waited, Harvested**: 21.4 s 91 % / without 21.1 s 97 % (**115 runs** gap 0, **185 runs** gap 1). All 6 arts fire at gap 0 (`the-second-cup` 0 at gap 1 due to 9.2 s loss before 12 s cd). |
| `lieu_da_thai` (`truc_co`) | 15.4 s, 5/5, 100 % | 8.2 s, 0/5, 0 % | **The Second Cup Is Poured**: `0` in default runs (kills in 15.4 s / falls in 8.2 s before `time > 20`). Tanky probe (`n_body=3.0`, 50 seeds): **29.53 s 89.7 %** vs **29.55 s 89.2 %** without (`73` `return` rows > 0 in seed 1). All 6 arts fire at gap 0. |
| `ha_cuc_thi` (`truc_co`) | 30.3 s, 5/5, 94 % | 8.0 s, 0/5, 0 % | All 5 arts fire at gap 0 (5.8 / 3.4 / 1.4 / 9.2 / 3.4); `the-second-cup` 0 at gap 1 (8.0 s loss). |
| `to_boi_ngam` (`truc_co`) | 47.8 s, 0/5, 0 % | 8.1 s, 0/5, 0 % | All 3 arts fire at gap 0 (8.4 / 4.2 / 3.0); `the-second-cup` 0 at gap 1 (8.1 s loss). |
| `tien_kho_dang` (`truc_co`) | 42.5 s, 2/5, 11 % | 8.1 s, 0/5, 0 % | All 4 arts fire at gap 0 (7.0 / 4.0 / 2.2 / 12.0); `the-second-cup` 0 at gap 1 (8.1 s loss). |
| `quan_song_dau` (`truc_co`) | 56.0 s, 2/5, 4 % | 8.1 s, 0/5, 0 % | Both arts fire (9.8 / 5.2 at gap 0; 1.0 / 0.5 at gap 1). |
| `te_vong_quy` (`truc_co`) | 25.0 s, 5/5, 99 % | 8.1 s, 0/5, 0 % | Stand-in `wutong-dawn-breath`: `seed-of-spring` 5.0 (1.0 gap 1), `dawn-call-palm` 10.0 (3.0 gap 1). |
| `khong_vu_kieu` (`luyen_khi`) | 45.4 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Both arts fire (7.8 / 3.8 at gap 0; 1.0 / 0.5 at gap 1). |
| `doan_thai_dau`, `uong_le_tra`, `banh_tri_hap`, `cung_hong_to`, `kha_tieu_dau`, `te_niem_quy`, `ho_yen_do`, `sam_van_huong`, `diep_lac_phuong` (`luyen_khi`) | 39.8–40.0 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | `scatter-beans` fires 11.8/fight at gap 0 (2.0 at gap 1). |

CHECKPOINT DONE
