# Stage 6 Checkpoint Review: Nhàn Vân Quán (`nhan_van`)

Reviewed unanchored against `design/world/depth/sects/nhan_van.*`, `production/plans/stage6/_brief-record.md`, `production/plans/stage6/_brief-review.md`, `design/world/depth/DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, `src/gameplay/combat/fight/effect_compiler.gd`, `src/gameplay/combat/fight/fight.gd`, `src/gameplay/combat/fight/defence_path.gd`, and `tools/design/combat_sim/engine.py`.

## Verification Summary

- **GDScript standalone compilation parity:** All 3 Effects in `design/stage6-staging/nhan_van/effects/nhan_van.effects.json` (`The Scroll Before the Painting`, `Paint It Back`, `Figure on the Clouds`) and all 7 arts in `design/stage6-staging/nhan_van/arts/part-sect-nhan_van.json` declare every counter they read/write in their own `"counters"` and use only supported events, actions, mod keys, ops, readables, and statuses (`3/3 Effects` and `7/7 Arts` PASS).
- **Effect name uniqueness:** Verified against `assets/data/combat_effects.json` (`2` world-depth entries + `109` library entries) and all staged `b02` `effects/*.effects.json` files (`bach_vu`, `minh_loan`, `muc_van`, `nam_pho`, `phan_vu`, `truc_thuc`, `xuyen_lam`); `The Scroll Before the Painting`, `Paint It Back`, and `Figure on the Clouds` have zero collisions.
- **`pending.json`:** Empty (`words: []`, `arts: []`, `effects: {}`); 0 pending words.
- **Stand-ins & beasts:** `0` stand-ins (`stand_ins 0`), `0` beasts (`beasts 0`), `0` `unknown_ids`, `0` `cross_owner` refs.
- **Faithfulness to depth text & rulings:** All 4 techniques, 7 new arts, 6 unique items (with R6 `exception` on `nv-cloud-washing-brush`, `nv-one-cloud-robe`, `nv-mothers-portrait-brush`, and `rarity: 5` on `nv-plain-silk-scroll`), and 2 sets match `nhan_van.techniques.json`, `nhan_van.items.json`, and `nhan_van.md`. `ink-rain` and `ink-sediment` correctly use self-counters (`ink_rain_t`, `sediment_on`) so they never overwrite `deep-lake-stance` (`s.state = "deep-lake"`). `sky-of-a-moment-ago` accurately applies permanent `-5 %` max-HP loss per cast via `hp_cost: 0.05` + live `heal_cap` (`1.0 - 0.05 * rewind_used`).

---

## Ranked Findings & Fixes Applied

### 1. MUST-FIX — `Figure on the Clouds` double-extends on recast and can double-fire on fall
- **File:** `design/stage6-staging/nhan_van/effects/nhan_van.effects.json`
- **Record:** `"Figure on the Clouds"` (`eff:Figure on the Clouds extend`, `eff:Figure on the Clouds fall pulse`, `eff:Figure on the Clouds fall break`)
- **What was wrong:**
  1. `eff:Figure on the Clouds extend` had no guard, so recasting `cloud-in-the-pool` while a reflection-double was standing added another `+3 s` on top of `double-recast`'s `+2 s` (`+5 s` per recast instead of extending the painted double's duration by `+3 s` once). Observed in `tan_dao_anh` `gap=0 seed=3` (`extend` fired twice on one double).
  2. `eff:Figure on the Clouds fall break` (`on: "shield_broken"`) checked only `own.counter.double_up == 2`. When a double expired by `double-timeout` on `pulse` (`double_up = 2`, `fall pulse` grants 2 Water stacks) while a stance ward remained up and broke before the next `pulse`, `double_up` was still `2`, allowing `fall break` to grant 2 more Water stacks for the same fall.
- **Fix applied:** Declared `{"id": "fig_up"}` in `"counters"`. Guarded `extend` on `own.counter.fig_up == 0` and set `fig_up = 1`. Guarded both `fall pulse` and `fall break` on `own.counter.fig_up == 1` (plus `event.stance_ward == 1` on `fall break`) and cleared `fig_up = 0` when granting the 2 Water buff stacks. Verified via `plog` on `tan_dao_anh` (`gap=0, seed=0,3`): `extend` fires once per painted double (`33020 double-recast` adds only `+2 s`), and `fall pulse`/`fall break` fire once per fall.

### 2. SHOULD — `cloud-in-the-pool` `double-break` should check `event.stance_ward == 1`
- **File:** `design/stage6-staging/nhan_van/arts/part-sect-nhan_van.json` (and `effects/nhan_van.effects.json` break records)
- **Record:** `"cloud-in-the-pool"` (`double-break`), `"Paint It Back"` (`eff:Paint It Back keep break`, `eff:Paint It Back clear break`), `"Figure on the Clouds"` (`eff:Figure on the Clouds fall break`)
- **What was wrong:** `shield_broken` fires `{}` when any non-stance ward shield (`wshields`) breaks and `{"stance_ward": 1}` when the stance ward (`sward`) breaks. Without checking `event.stance_ward == 1`, a non-stance ward shield breaking from another item/sect would prematurely kill the reflection-double while its own stance ward was still intact.
- **Fix applied:** Added `{"read": "event.stance_ward", "op": "==", "value": 1}` to `double-break`, `eff:Paint It Back keep break`, `eff:Paint It Back clear break`, and `eff:Figure on the Clouds fall break`.

### 3. SHOULD — `ink-sediment` applied one extra pulse of ward growth after Composed ended
- **File:** `design/stage6-staging/nhan_van/arts/part-sect-nhan_van.json`
- **Record:** `"ink-sediment"` (`ink-sediment-ward`, `ink-sediment-fall`)
- **What was wrong:** On `pulse`, `ink-sediment-ward` preceded `ink-sediment-fall` and did not check `own.composed >= 1`. In `diep_to_quyen` (`gap=0 seed=0, t=11000`), on the pulse after she stopped being Composed, `ink-sediment-ward` still grew the double's ward using the stale `stillness` layers right before `ink-sediment-fall` reset `stillness = 0`.
- **Fix applied:** Reordered `ink-sediment-fall` before `ink-sediment-ward` and added `{"read": "own.composed", "op": ">=", "value": 1}` to `ink-sediment-ward`. Verified in `diep_to_quyen` `plog` (`t=11000` emits `ink-sediment-fall` only).

### 4. SHOULD — `sky-of-a-moment-ago` counted zero-damage ward-blocked hits and could self-trigger off `hp_cost`
- **File:** `design/stage6-staging/nhan_van/arts/part-sect-nhan_van.json`
- **Record:** `"sky-of-a-moment-ago"` (`guards`, `sky-track-hit`, `sky-track-tick`)
- **What was wrong:** `was_hit` fires even when `sward` absorbs 100 % of a hit (`event.amount == 0`), so `hits_6s` incremented on blocked hits. Additionally, `guards` checked only `own.lost_last.hp.6 > 0`, which becomes true from the art's own `hp_cost: 0.05` even if the enemy dealt zero health damage in the last 6 s.
- **Fix applied:** Added `{"read": "event.amount", "op": ">", "value": 0}` to `sky-track-hit` and `sky-track-tick`, and added `{"read": "own.counter.hits_6s", "op": ">=", "value": 1}` to `sky-of-a-moment-ago`'s `guards`.

### 5. SHOULD — `Paint It Back` counted zero-damage ward-blocked hits in `hits_3s`
- **File:** `design/stage6-staging/nhan_van/effects/nhan_van.effects.json`
- **Record:** `"Paint It Back"` (`eff:Paint It Back track hit`, `eff:Paint It Back track tick`)
- **What was wrong:** `eff:Paint It Back track hit` (`on: "was_hit"`) and `eff:Paint It Back track tick` (`on: "tick_taken"`) had no `event.amount > 0` check, so hits completely stopped by `sward` (`event.amount == 0`) inflated the 3 s rewind heal.
- **Fix applied:** Added `{"read": "event.amount", "op": ">", "value": 0}` to both `eff:Paint It Back track hit` and `eff:Paint It Back track tick`.

### 6. NIT — `sky-of-a-moment-ago` `heal_cap` interaction with `Whetstone Vow`
- **File:** `design/stage6-staging/nhan_van/arts/part-sect-nhan_van.json` (`sky-hp-cap-base`, `sky-hp-cap-loss`)
- **Observation:** Engine `heal_cap` mods are additive (`1.0 - 0.05 * rewind_used`). If a future build combines `sky-of-a-moment-ago` with `Whetstone Vow` (`heal_cap: 0.8`), the sum (`1.75 - 0.05 * rewind_used`) would exceed `1.0`. No `nhan_van` cast member uses `Whetstone Vow`; kept as-is (requires engine `min`-combiner if ever needed).

### 7. NIT — `cloud-in-the-pool` recast summon overlap
- **File:** `design/stage6-staging/nhan_van/arts/part-sect-nhan_van.json` (`double-recast`)
- **Observation:** Recasting `cloud-in-the-pool` while `double_up == 1` appends a new 6 s Cold summon while any remaining seconds of the prior 8 s summon finish (brief overlap). Harmless and faithful to recast continuity.

---

## Pending Words Decisions

None (`design/stage6-staging/nhan_van/pending.json` is empty: `words: []`, `arts: []`, `effects: {}`).

---

## Post-Fix Verification & Holder Table (`sect_fight.py nhan_van --seeds 5`, `--gap 0` and `--gap 1`)

### Linters & Integrity Checks (`DEPTH_STAGE=design/stage6-staging/nhan_van`)
- `lint_arts.py part-sect-nhan_van.json`: **7 arts, 0 findings**
- `lint_techniques.py catalogue-sect-nhan_van.json`: **4 techniques, 0 findings** (`7.6/8`, `15.3/16`, `15.4/16`, `23.4/24 W`)
- `lint_items.py catalogue-sect-nhan_van.json`: **6 items, 0 findings**
- `depth_check.py`: **findings: none**
- `depth_gap.py --sect nhan_van`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `beasts 0`, `engine_words 0`, `wishes_open 0`
- `sect_fight.py nhan_van --seeds 5` (`--gap 0` & `--gap 1`): **0 REFUSED**

### Holders After Fixes

| Holder | Realm | Arts (up to 6) | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Notes |
|---|---|---|---|---|---|
| `diep_to_quyen` | Kết Đan | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `ink-sediment`, `sky-of-a-moment-ago`, `door-guardian` | `45.3 s`, `5/5`, `95 %` | `23.2 s`, `0/5`, `0 %` | All 6 arts fire at both gaps (`ink-sediment` `1.0/1.0`, `sky-of-a-moment-ago` `1.0/1.8`) |
| `me_phu_van` | Kết Đan | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `door-guardian`, `ink-rain` | `53.6 s`, `5/5`, `100 %` | `13.7 s`, `0/5`, `0 %` | All 5 arts fire at both gaps |
| `tan_dao_anh` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `door-guardian`, `ink-rain` | `44.1 s`, `5/5`, `100 %` | `12.8 s`, `0/5`, `0 %` | All 5 arts fire at both gaps |
| `thi_dam_tinh` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `door-guardian`, `ink-rain` | `47.4 s`, `5/5`, `99 %` | `10.1 s`, `0/5`, `0 %` | All 5 arts fire at both gaps |
| `doi_kim_truc` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `door-guardian`, `ink-rain` | `47.4 s`, `5/5`, `99 %` | `10.1 s`, `0/5`, `0 %` | All 5 arts fire at both gaps |
| `cu_luc_truc` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance` | `49.4 s`, `5/5`, `100 %` | `9.6 s`, `0/5`, `0 %` | All 3 arts fire at both gaps |
| `ham_nhat_van` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance` | `49.4 s`, `5/5`, `100 %` | `9.6 s`, `0/5`, `0 %` | All 3 arts fire at both gaps |
| `khuong_tram_mac` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky` | `64.4 s`, `1/5`, `1 %` | `9.6 s`, `0/5`, `0 %` | Both arts fire at both gaps |
| `bao_anh_nhi` | Luyện Khí | `cloud-in-the-pool`, `upside-down-sky`, `door-guardian` | `63.4 s`, `4/5`, `18 %` | `8.8 s`, `0/5`, `0 %` | All 3 fire at gap 0 (`door-guardian` `3.0`); dies at `8.8 s` < `10.0 s` CD at gap 1 (`NEVER_FIRED`) |
| `lieu_bach_mieu` | Luyện Khí | `cloud-in-the-pool`, `upside-down-sky` | `58.4 s`, `0/5`, `0 %` | `8.8 s`, `0/5`, `0 %` | Both arts fire at both gaps |
| `dinh_hong_thu` | Luyện Khí | `cloud-in-the-pool`, `upside-down-sky` | `58.4 s`, `0/5`, `0 %` | `8.8 s`, `0/5`, `0 %` | Both arts fire at both gaps |
| `doan_truc_nhi` | Luyện Khí | `cloud-in-the-pool`, `upside-down-sky` | `58.4 s`, `0/5`, `0 %` | `8.8 s`, `0/5`, `0 %` | Both arts fire at both gaps |
| `man_tam_van` | Luyện Khí | `wet-stroke`, `backwash-seal` | `24.0 s`, `5/5`, `51 %` | `8.0 s`, `0/5`, `0 %` | Both arts fire at both gaps |
| `nghiem_thu_lo` | Luyện Khí | `wet-stroke`, `backwash-seal` | `23.8 s`, `5/5`, `51 %` | `8.0 s`, `0/5`, `0 %` | Both arts fire at both gaps |
| `o_lao_nghien` | Luyện Khí | `wet-stroke`, `backwash-seal` | `24.0 s`, `5/5`, `51 %` | `8.0 s`, `0/5`, `0 %` | Both arts fire at both gaps |
| `giai_thanh_nghien` | Luyện Khí | `wet-stroke`, `backwash-seal` | `23.8 s`, `5/5`, `51 %` | `8.0 s`, `0/5`, `0 %` | Both arts fire at both gaps |
| `liem_huan_huong` | Luyện Khí | `wet-stroke`, `backwash-seal` | `24.0 s`, `5/5`, `51 %` | `8.0 s`, `0/5`, `0 %` | Both arts fire at both gaps |
| `cu_tieu_can` | Luyện Khí | `wet-stroke`, `backwash-seal` | `23.8 s`, `5/5`, `51 %` | `8.0 s`, `0/5`, `0 %` | Both arts fire at both gaps |

### Effects With / Without After Fixes (`sect_fight.py nhan_van --seeds 5`)

| Holder | Effect | Gap 0 (`with` vs `without`, `runs`) | Gap 1 (`with` vs `without`, `runs`) |
|---|---|---|---|
| `diep_to_quyen` | `The Scroll Before the Painting` | `45.3 s 95 %` vs `45.8 s 89 %` (`284 runs`) | `23.2 s 0 %` vs `23.4 s 0 %` (`54 runs`) |
| `diep_to_quyen` | `Paint It Back` | `45.3 s 95 %` vs `45.3 s 95 %` (`80 runs`) | `23.2 s 0 %` vs `21.2 s 0 %` (`168 runs`) |
| `tan_dao_anh` | `Figure on the Clouds` | `44.1 s 100 %` vs `43.4 s 100 %` (`45 runs`) | `12.8 s 0 %` vs `12.8 s 0 %` (`14 runs`) |

CHECKPOINT DONE
