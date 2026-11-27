# Stage 6 Record Pass Review — `van_khoi` (Vân Khởi Quán)

## Summary

- **Built (`design/stage6-staging/van_khoi/`)**:
  - **Techniques (3)** in [catalogue-sect-van_khoi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/techniques/catalogue-sect-van_khoi.json): `water-ends-primer` (Tier 0 `main`, `names: []`), `sitting-cloud-canon` (Tier 2 `main`, `names: []`), and `cloud-mother-seal` (Tier 1 `secret`, `names: []`), each with `[NEW]` tier-sized unpriced `bonuses` and `passives`.
  - **New Arts (4)** in [part-sect-van_khoi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/arts/part-sect-van_khoi.json): `not-counting-the-steps`, `clouds-rise`, `the-water-has-ended`, and `cloud-in-the-pane`. Existing carried arts (`lamp-oil-lance`, `frozen-hour-seal`) and `hundred-echo-palm-scripture` remain in `design/arts/` and `design/techniques/`.
  - **Effects (3)** in [van_khoi.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/effects/van_khoi.effects.json): `Sit and Watch` (`vk-rising-cloud-robe`), `Sit as Thôi Sat` (`vk-empty-mountain` 3pc), and `Read Aloud` (`vk-readers-pair` 2pc). Every Effect declares all counters it reads or writes in its own `"counters"` array (including shared `cloud`) and compiles standalone via `engine.validate`.
  - **Items (6) & Sets (2)** in [catalogue-sect-van_khoi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/items/catalogue-sect-van_khoi.json) and [sets-van_khoi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/items/sets-van_khoi.json): `vk-rising-cloud-robe`, `vk-cloud-mother-mirror`, `vk-empty-hall-bell`, `vk-thoi-censer`, `vk-hundred-echo-seal`, `vk-mica-reader-robe` (all `unique: true`, `sources: ["npc"]`, R6 `exception` on the 4 `weapon`/`body_gear`/`ward_gear` pieces); sets `vk-empty-mountain` (3pc) and `vk-readers-pair` (2pc).
  - **Depth edits**: inserted `"id"` fields before `"new"` for all 4 new arts in [van_khoi.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/van_khoi.techniques.json).
- **Stand-ins / Beasts / Early Promotions / Pending Words**: `0` stand-ins (all 19 living cast already use `van_khoi` lineage methods), `0` beasts, `0` cross-owner references, `0` early promotions, `0` pending engine words (`pending.json` not needed).
- **Deviations**: `6` documented engine-vocabulary / approximation deviations (listed below); `0` silent drops.
- **Decisions taken for the user (auto-accepted)**: `7` decisions with reasons below.
- **Never ran on `typical` in `sect_fight.py`**:
  - `Sit and Watch`: reports `runs 0` in `sect_fight.py` because `sect_fight.py` counts `Fight.do()` calls only (not `on: "always"` mods, which produce the measured `82% vs 78%` HP delta at `--gap 0` and `11.4 s vs 10.2 s` survival delta at `--gap 1`), and `typical` enemies cast no status effects to trigger the pulse status-end recovery (`eff:Sit and Watch watch` / `eff:Sit and Watch ended` ran `4` times each in the status probe).
  - `Sit as Thôi Sat` 5-Cloud palm/echo branch (`was_hit`, `cloud >= 5`): `tong_toa_van` casts `lamp-oil-lance` every ~3 s, spending Clouds at 2–3 before reaching 5 in normal `typical` fights (`eff:Sit as Thôi Sat` still runs `106` times via its 5 s Composed Cloud-banking branch); the 5-Cloud answer (`palm` 3, `echo` 3, `clear` 3) was verified in a targeted probe without `lamp-oil-lance`.
  - `the-water-has-ended` pulse status-turn-aside branch (`water-ended-turn`): `typical` enemies cast no status effects; verified `2` runs in the status probe (`water-ended-ward` fires normally in all fights).
- **Open items**:
  1. `cast_ward_duration_pct` (`+20` on `vk-cloud-mother-mirror`): valid in `lint_items.py` / `modifiers.md`, currently has no `CHARACTER_MODS` / `cast_wards` reader in `combat_engine.json` (`depth_gap.py` `lines` 1 open).
  2. R6 `exception` kept on `vk-rising-cloud-robe`, `vk-empty-hall-bell`, `vk-hundred-echo-seal`, and `vk-mica-reader-robe` until authored signature item arts/wards are ruled.
  3. 6 structured events (`N-van_khoi-01..06`) close at Stage 8 export.

---

## Auto-Accepted Decisions (with Reasons)

1. **Keep `names: []` on all 3 element-free techniques (`b02` `lint-element-free-techniques`)**: Both referenced arts (`lamp-oil-lance`, `frozen-hour-seal`) and all 4 new arts have `element: ""`, so `lint_techniques.py` accepts `names: []` directly without a lint proxy, honoring R3's no-lean element-free abbey.
2. **Size `[NEW]` tier-0/1/2 bonuses and passives to catalogue budgets**: Depth techniques list no bonuses or passives; sized unpriced bonuses (`0 / 2 / 1`) and passives (`8.0 / 23.8 / 15.0 W`) to evasion, divine sense, soul/status/tâm ma resistance, curse duration, seal speed, and ward efficiency.
3. **Set `sitting-cloud-canon` unlock layers to `1 / 2 / 4`**: Places `lamp-oil-lance` at L1, `clouds-rise` at L2 (so L2 `ha_que_hoa` gets both offense and Cloud banking), and `the-water-has-ended` at L4 (`<= 6` Trúc Cơ suite rule; all L4+ inner disciples and elders unlock the full suite). Set `cloud-mother-seal` unlocks to `1 / 3` (`lanh_xuan_gian` is L9).
4. **Model `not-counting-the-steps` escalating cost with counter `upkeep` (`0.004` qi/s per Step)**: Counter `upkeep` scales linh lực cost linearly each second (`0.4%`, `0.8%`, `1.2%`...) while safely clamping and dropping excess Steps if linh lực runs dry, rather than risking negative linh lực from unguarded negative `gain_qi`.
5. **Make `clouds-rise` a Composed stance (`clouds-watching`, `tags: ["composed"]`) without `"soul"` tag**: Every `sitting-cloud-canon` holder casts `lamp-oil-lance` (and some cast `hundred-echo-palm-scripture`) every 2–3 s, which resets `t_act` and would prevent `t - t_act >= 2 s` without a Composed stance. Keeping `"soul"` off `clouds-rise` and `the-water-has-ended` ensures only `lamp-oil-lance` spends banked Clouds and increments `Read Aloud`.
6. **Approximate `thần thức` recovery (`the-water-has-ended`, `Sit and Watch`) and single-art sealing (`cloud-in-the-pane`) with existing engine words**: The engine has no `restore_than_thuc` action (to refund `ts_spent`), no `status_blocked` / `status_ended` event, and no per-art enemy seal or ward-only damage reduction. Using pulse-cleanse + `gain_qi` + `soul_res` and `slowed_time` + `sealed_meridian` + `timer` + `dampen_taken 100` preserves build intent and combat measurability without adding single-sect engine words.
7. **Trigger `Read Aloud`'s bell ring at `fight_start` and on `was_hit` (`cd: 8 s`)**: `vk-empty-hall-bell` uses its base's standing per-hit ward (`Golden Bell`) per R6 and has no active ring art; ringing at `fight_start` ("rung once at the door before each reading") and when struck (`8 s` cooldown) keeps `Read Aloud` active through real fights.

---

## Băng Tâm Pilot Checklist

- [x] Every Effect changes the fight with and without it on its holders (`Sit and Watch` HP/survival delta, `Sit as Thôi Sat` Cloud-banking + 5-Cloud probe, `Read Aloud` fight-time delta), and all 6 carried arts fire across all 19 living members.
- [x] No holder slots two stances without a combined stance (`not-counting-the-steps` is only on `water-ends-primer` novices; `clouds-rise` is only on `sitting-cloud-canon` holders).
- [x] Each `"your X"` Effect works cleanly for holders who may lack X (`Sit as Thôi Sat` declares and banks `cloud` on its own; `Read Aloud` works without an active bell art).
- [x] Vague depth phrases (`"a little evasion"`, `"costs a little more"`, `"regain a little thần thức"`, `"seals the foe's last-used art"`, `"wards lose half as much"`, `"lasts 1 s longer"`) are pinned down to concrete numbers in every `rule`.
- [x] `[NEW]` technique bonuses and passives are sized against the same tier (`0` / `1` / `2`) and explicitly flagged below.

---

## Mechanic Table & Depth-vs-Engine Mapping

### Techniques ([catalogue-sect-van_khoi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/techniques/catalogue-sect-van_khoi.json))

| ID | Name | Tier / Kind | Depth Lines | Staged Engine Form | Deviations / `[NEW]` |
|---|---|---|---|---|---|
| `water-ends-primer` | Walking to Where the Water Ends (Hành Đáo Thủy Cùng Quyết) | 0 / `main` | `names: []`, `layers: 6`, no bonuses/passives | `names: []`; `bonuses: []`; **[NEW]** `passives`: `evade_pct 2 []`, `than_thuc_pct 2 []`, `linh_luc_regen_inc_pct 3 []` (`8.0 W / 8`); `abilities`: `not-counting-the-steps` (L1) | **[NEW]** 3 tier-0 passives. |
| `sitting-cloud-canon` | Sit and Watch the Clouds Rise (Tọa Khán Vân Khởi Kinh) | 2 / `main` | `names: []`, `layers: 12`, no bonuses/passives | `names: []`; **[NEW]** `bonuses`: `than_thuc_pct 12`, `tam_ma_resist_pct 12`; **[NEW]** `passives`: `soul_res_pct 15 []`, `status_resist_pct 15 []`, `x_soul 6 []`, `linh_luc_regen_inc_pct 5 []` (`23.8 W / 24`); `abilities`: `lamp-oil-lance` (L1), `clouds-rise` (L2), `the-water-has-ended` (L4) | **[NEW]** 2 tier-2 bonuses + 4 passives. |
| `cloud-mother-seal` | Cloud Mother Seal (Vân Mẫu Ấn) | 1 / `secret` | `names: []`, `layers: 9`, no bonuses/passives | `names: []`; **[NEW]** `bonuses`: `defense_pct 10`; **[NEW]** `passives`: `ward_efficiency_pct 8 []`, `status_duration_pct 10 ["curse"]`, `art_speed_pct 10 ["seal"]` (`15.0 W / 16`); `abilities`: `frozen-hour-seal` (L1), `cloud-in-the-pane` (L3) | **[NEW]** tier-1 bonus + 3 passives. |

### Arts ([part-sect-van_khoi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/arts/part-sect-van_khoi.json))

| ID | Name | Role / Cost / CD | Depth Text | Staged Engine Form | Deviations |
|---|---|---|---|---|---|
| `not-counting-the-steps` | Not Counting the Steps (Bất Kế Bộ) | `utility`, `0.03`, `5.0 s` | Walking stance: while you keep moving, each second adds a little evasion and costs a little more linh lực than the second before; first hit that lands clears it. | `uncounted-walk` Pressing stance; pulse adds `1` `walk_step` (`+4` pp `evade` each, `upkeep` `0.004` qi/s per Step); `was_hit` (`event.amount > 0`) clears stance and resets `walk_step`. | **Dev 1**: uses counter `upkeep` (`0.004 * walk_step`) and `event.amount > 0` guard. |
| `clouds-rise` | Clouds Rise (Vân Khởi) | `utility`, `0.03`, `3.0 s` | While you have not moved for 2 s, each second banks a Cloud, and each new Cloud costs a little more linh lực to bank than the one before. Next soul art spends them for damage and status duration. | `clouds-watching` Composed stance; when `composed_time >= 2` and `qi_share >= 0.08`, pulse pays `0.003 * (1 + cloud)` qi and adds `1` `cloud`; `art_fired` (`tags: ["soul"]`) spends all Clouds for `+10 % x_soul` and `+15 % status_dur` per Cloud. | **Dev 2**: Composed stance prevents `lamp-oil-lance` / palm `t_act` resets from blocking Cloud banking. |
| `the-water-has-ended` | The Water Has Ended (Thủy Cùng) | `ward`, `0.04`, `8.0 s` | Ward that holds while you sit: first status laid on you each 8 s is turned aside, and you regain a little thần thức. | `ward_grow` (`5 % hp`) + `soul_res 12`, `status_resist 20` (`for: 8 s`); while `composed >= 1` (`cd: 8 s`), pulse cleanses 1 curse + tick statuses and grants `gain_qi 3 %` + `soul_res 8` (`for: 4 s`). | **Dev 3**: pulse cleanse + `gain_qi` / `soul_res` approximates turning aside a status and regaining thần thức. |
| `cloud-in-the-pane` | Cloud in the Pane (Song Trung Vân) | `control`, `0.05`, `7.0 s` | Seals the foe's last-used art for 3 s; while it is sealed, your wards lose half as much when struck. | `c_art: 1.4`, `slowed_time` (`1`, `3 s`); `hit_landed` adds `sealed_meridian` (`layer: 1`, `3 s`), `timer` foe `next +1.5 s`, and `dampen_taken 100` (`for: 3 s`). | **Dev 4**: `sealed_meridian` + `timer` approximates per-art sealing; `dampen_taken 100` halves all hit damage to wards/health. |

### Effects ([van_khoi.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/effects/van_khoi.effects.json))

| Name | Source | Counters | Depth Rule | Engine Form & Deviations |
|---|---|---|---|---|
| `Sit and Watch` | `vk-rising-cloud-robe` | `sit_had_status` | While you have not moved for 3 s, take 12 % less damage; each status that ends on you returns 2 % of your thần thức. | `always` (`composed_time >= 3`): `dampen_taken 13.64`; pulse status watcher detects active statuses ending and grants `gain_qi 2 %` + `soul_res 6` (`for: 4 s`). | **Dev 5**: pulse status watcher + `gain_qi`/`soul_res` approximates `status_ended` + `thần thức` recovery. |
| `Sit as Thôi Sat` | `vk-empty-mountain` (3pc) | `thoi_sat_t`, `cloud` | Every 5 s you are Composed, bank a Cloud; at 5 Clouds, next hit on you is answered by a free hundred-echo palm that echoes once per Cloud spent. | Pulse (`composed >= 1`) banks `1` `cloud` every 5 s; `was_hit` (`cloud >= 5`, `event.amount > 0`) fires `free_hit` `1.5 c` + `0.6 c * cloud` (`phys`) and resets `cloud`. | None (shares `cloud` counter cleanly with `clouds-rise`). |
| `Read Aloud` | `vk-readers-pair` (2pc) | `bell_ring` (`each_for: 6.5`, `cap: 1`), `read_aloud` | Each soul art cast within 6 s of ringing the bell lasts 1 s longer; after three such arts, your next soul art is cast at once. | `fight_start` and `was_hit` (`cd: 8 s`) set `bell_ring`; `art_fired` (`tags: ["soul"]`) while `bell_ring >= 1` grants `status_dur +25` and `+1` `read_aloud`; at 3, resets `read_aloud` and `timer` own `next -99`. | **Dev 6**: triggers bell ring at `fight_start` and `was_hit` (no active bell art under R6); `+25 % status_dur` for +1 s. |

### Items & Sets ([catalogue-sect-van_khoi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/items/catalogue-sect-van_khoi.json), [sets-van_khoi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/van_khoi/items/sets-van_khoi.json))

- **6 Unique Items** (`sources: ["npc"]`, `unique: true`):
  - `vk-rising-cloud-robe` (`artifact`, `dao_bao`, `grade: 4`, `36.0 W / 51.2`, R6 `exception`, `holder: tong_toa_van`, Effect `Sit and Watch`)
  - `vk-cloud-mother-mirror` (`artifact`, `kinh`, `grade: 3`, `34.4 W / 38.4`, `holder: lanh_xuan_gian`, includes `cast_ward_duration_pct: 20`)
  - `vk-empty-hall-bell` (`artifact`, `chuong`, `grade: 2`, `22.0 W / 25.6`, R6 `exception`, `holder: van_nhan_huong`)
  - `vk-thoi-censer` (`artifact`, `huong_lo`, `grade: 4`, `34.8 W / 51.2`, `holder: tong_toa_van`)
  - `vk-hundred-echo-seal` (`artifact`, `an`, `grade: 4`, `36.6 W / 51.2`, R6 `exception`, `holder: tong_toa_van`)
  - `vk-mica-reader-robe` (`artifact`, `dao_bao`, `grade: 2`, `22.0 W / 25.6`, R6 `exception`, `holder: van_nhan_huong`)
- **2 Sets**:
  - `vk-empty-mountain` (`The Empty Mountain`, 3pc on `tong_toa_van`: 2pc `soul_res_pct 12`, `health_regen_inc_pct 15`; 3pc Effect `Sit as Thôi Sat`)
  - `vk-readers-pair` (`The Reader's Pair`, 2pc on `van_nhan_huong`: 2pc `than_thuc_pct 3`, `soul_res_pct 8`, Effect `Read Aloud`)

---

## Holder Check & Combat Probes

All 19 living `van_khoi` members (11 in `van_khoi.cast.json`, 8 in `van_khoi.5.cast.json`) ran in `sect_fight.py` with **`0 REFUSED`** under `$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\van_khoi"`.

### `sect_fight.py van_khoi --seeds 5` Summary (`--gap 0` and `--gap 1`)

| Holder(s) | Realm | Slotted Arts | Gap 0 (`mean_s`, `wins/5`, `hp%`) | Gap 1 (`mean_s`, `wins/5`, `hp%`) | Notes / Effect Runs (`gap 0`) |
|---|---|---|---|---|---|
| `tong_toa_van` | `nguyen_anh` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `answering-palm`, `twin-shadow-fist`, `rolling-barrage-fist` | `19.0 s`, `5/5`, `82%` | `11.4 s`, `0/5`, `0%` | Arts fire `6.0 / 1.0 / 2.0 / 6.8 / 2.0 / 9.0`. `Sit and Watch`: `19.0 s 82%` vs `19.0 s 78%` (`11.4 s` vs `10.2 s` at `--gap 1`, `runs 0` `always`-only on `typical`). `Sit as Thôi Sat`: `19.0 s 82%` vs `19.2 s 82%` (`runs 106`). |
| `van_nhan_huong` | `truc_co` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended` | `60.6 s`, `1/5`, `1%` | `8.4 s`, `0/5`, `0%` | Arts fire `16.0 / 1.0 / 6.6`. `Read Aloud`: `60.6 s 1%` vs `62.2 s 4%` (`runs 127`). |
| `kha_thuy_cung` | `ket_dan` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `answering-palm`, `twin-shadow-fist`, `rolling-barrage-fist` | `19.8 s`, `5/5`, `74%` | `8.0 s`, `0/5`, `0%` | Arts fire `6.2 / 1.0 / 2.0 / 7.0 / 2.0 / 8.6`. |
| `lanh_xuan_gian` | `ket_dan` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `frozen-hour-seal`, `cloud-in-the-pane` | `42.4 s`, `5/5`, `92%` | `18.6 s`, `0/5`, `0%` | Arts fire `13.4 / 1.0 / 5.8 / 12.0 / 8.6`. |
| `nong_bach_thach` | `truc_co` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `answering-palm`, `twin-shadow-fist`, `rolling-barrage-fist` | `19.5 s`, `5/5`, `75%` | `8.0 s`, `0/5`, `0%` | Arts fire `6.2 / 1.0 / 2.0 / 7.0 / 2.2 / 8.0`. |
| `han_thanh_dai`, `ha_khong_thuy` | `truc_co` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended`, `answering-palm`, `twin-shadow-fist` | `22.5 s`, `5/5`, `66%` | `8.0 s`, `0/5`, `0%` | Arts fire `7.0 / 1.0 / 2.0 / 7.6 / 2.8`. |
| `trang_thanh_tuyen`, `tho_u_hoang` | `truc_co` | `lamp-oil-lance`, `clouds-rise`, `the-water-has-ended` | `46.2 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | Arts fire `13.8 / 1.0 / 5.2`. |
| `ha_que_hoa` | `luyen_khi` | `lamp-oil-lance`, `clouds-rise` | `41.8 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | Arts fire `13.4 / 1.0`. |
| 9 `water-ends-primer` novices (`an_tho_hoa`, `pho_tieu_diem`, `trinh_van_phien`, `mai_ngu_yen`, `ho_kinh_dieu`, `lao_hong_diep`, `thong_van_thach`, `cu_tung_gian`, `ba_xuan_son`) | `luyen_khi` | `not-counting-the-steps` | `35.4 s`, `0/5`, `0%` | `8.4 s`, `0/5`, `0%` | `not-counting-the-steps` fires `6.6` times at gap 0, `1.2` at gap 1. |

### Targeted Probes
- **Status-foe probe (`tong_toa_van` vs Nguyên Anh foe with `slowed_time` + `heavy_breath`, seed 0)**: `eff:Sit and Watch watch: 4`, `eff:Sit and Watch ended: 4`, `water-ended-ward: 2`, `water-ended-turn: 2`.
- **5-Cloud answer probe (`tong_toa_van` without `lamp-oil-lance`, seed 0)**: `clouds-bank: 17`, `eff:Sit as Thôi Sat bank: 4`, `eff:Sit as Thôi Sat palm: 3`, `eff:Sit as Thôi Sat echo: 3`, `eff:Sit as Thôi Sat clear: 3`.

---

## Verification Ledger

- `lint_arts.py design/stage6-staging/van_khoi/arts/part-sect-van_khoi.json` -> `checked 4 arts in 1 files, 0 findings`
- `lint_techniques.py design/stage6-staging/van_khoi/techniques/catalogue-sect-van_khoi.json` -> `checked 3 techniques, 0 findings` (`8.0 / 23.8 / 15.0 W`)
- `lint_items.py design/stage6-staging/van_khoi/items/catalogue-sect-van_khoi.json` -> `checked 6 items, 22 bases, 9 common arts, 0 findings`
- Standalone `engine.validate` -> `STANDALONE_OK` on all 3 Effects (`Sit and Watch`, `Sit as Thôi Sat`, `Read Aloud`)
- `depth_check.py --quiet` -> `findings: none`
- `depth_gap.py --sect van_khoi` -> `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `ties_unmapped 0`, `ties_over_cap 0`, `engine_words 0`, `wishes_open 0`, `beasts 0`, `lines 26/27 runs` (`1` `cast_ward_duration_pct` open)
- `sect_fight.py van_khoi --seeds 5` (`--gap 0` & `--gap 1`) -> `0 REFUSED`, all 6 carried arts fire, Effects verified across holders + targeted probes.
