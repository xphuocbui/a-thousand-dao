## Summary

- **Built (`design/stage6-staging/thu_phan/`)**: 3 techniques (`grave-sweeping-chant`, `autumn-grave-canon`, `jade-of-resentment-ward`), 6 signature arts (`sweep-the-stones`, `ghosts-sing-old-poems`, `add-a-voice`, `autumn-comes`, `hold-it-down`, `a-thousand-years`), 4 Effects (`Toll for the Dead`, `Blood Turns to Jade`, `The Dead Sing Along`, `The Cadence Like a Drum`), 6 unique signature items (`tp-autumn-grave-bell`, `tp-resentment-jade-seal`, `tp-nine-graves-zither`, `tp-barred-door-robe`, `tp-grave-drum`, `tp-lined-winter-robe`), and 2 item sets (`tp-autumn-graves`, `tp-second-copy`). Updated `design/world/depth/sects/thu_phan.techniques.json` in place with `"id"` fields on all 6 arts.
- **Stand-ins / Beasts / Pending words**: 0 stand-ins (`hoang`/`huyen`/`dia`/`thien` = 0), 0 beasts, 0 pending engine words (`pending.json` not needed).
- **Deviations from depth text**: 9 documented engine-vocabulary / proxy deviations (listed in full below); 0 silent drops.
- **Never ran**: None. All 6 arts fire and all 4 Effects run (`runs > 0`) on their real holders (`ly_han_bich`, `co_ky_am`) with measured `with` vs `without` deltas.
- **Early promotions**: None (`thu_phan` has no cross-owner lineage gaps; the earlier cross-owner `xuyen_lam` precedent does not apply here).
- **Open items**:
  1. `body-element-free-names`: restore `names: []` on `grave-sweeping-chant`, `autumn-grave-canon`, and `jade-of-resentment-ward` once Stage 7/9 cultivation/schema allows element-free `main`/`secret` techniques (R3 no-lean rule; 5 of 18 living members lack `thuy`).
  2. `b2 ["song"] scope`: restore `scope: ["song"]` on `autumn-grave-canon` (`x_soul` passive if desired) and `tp-autumn-grave-bell`, `tp-nine-graves-zither`, `tp-grave-drum` (`art_speed_pct`) once `"song"` enters `modifiers.md` `TIER`.
  3. `own.purity.am` readable (Darkness): wire Darkness scaling on `The Dead Sing Along` once `own.purity.<el>` is readable in `engine.py` / `fighter_compiler.gd`.
  4. Single-art slow/weaken & single-filter `timer`: optionally refine `Hold It Down` and `Toll for the Dead` if future engine rules add per-art debuffs or `timer` dtype filters.
  5. `R6` common arts/wards on signature `chuong`, `an`, `cam`, `dao_bao` bases (keep `exception` until authored signature item arts are ruled).
  6. `events: 4` (`N-thu_phan-01`..`04`) remain structured in `depth_gap.py` for Stage 8 prose generation.

---

## Auto-Accepted Decisions (Stage 6 Headless Brief)

1. **`names: ["thuy"]` lint proxy on all 3 techniques** — `lint_techniques.py` rejects `names: []` on `tech_kind != "body"`, while depth rule R3 requires element-free methods for `thu_phan`; used `["thuy"]` temporarily (matching `xuyen_lam` and `thinh_vu`) while keeping all 6 arts `element: ""` (`kind: "elem"`), flagged under Open `body-element-free-names`.
2. **`scope: ["song"]` mapped to `["soul"]` / `[]`** — `"song"` is outside `lint_techniques.py` / `lint_items.py` Modifier `TIER` (`b2`); mapped `autumn-grave-canon` `x_soul` scope `["song"]` -> `[]` (`x_soul` already applies to all soul hits) and `art_speed_pct` on `tp-autumn-grave-bell`, `tp-nine-graves-zither`, `tp-grave-drum` -> `["soul"]` (same precedent as `phuong_minh`).
3. **New technique bonuses and passives sized to tier** — Unpriced depth techniques gained unpriced tier-matched `bonuses` and `passives` (logged as NEW below): tier 0 (`grave-sweeping-chant`) `8.0 W / 8`, tier 1 (`autumn-grave-canon`) `15.0 W / 16` with `than_thuc_pct: 10`, tier 2 (`jade-of-resentment-ward`) `22.4 W / 24` with `than_thuc_pct: 12`, `khi_huyet_pct: 10`.
4. **Unlock layers `[1]` / `[1, 2, 4]` / `[1, 5]`** — Set `autumn-grave-canon` unlocks to `1, 2, 4` (matching `calm-wind-staff-canon`, `<= 6` Trúc Cơ rule) so inner disciples at layer 4 (`bui_song_khe`) and elders slot the full chorus loop (`Ghosts Sing Old Poems`, `Add a Voice`, `Autumn Comes`) and outer layer-2 inner disciple `hua_tang_thu` gets `Ghosts Sing Old Poems` + `Add a Voice`.
5. **Stand-alone counter & state declarations per Effect** — Every Effect in `thu_phan.effects.json` declares every counter `id` it reads or writes inside its own `"counters"` array so both `engine.validate` standalone and `fighter_profile_loader.gd` compile cleanly without sibling Effects or arts present.
6. **Treasure rarity `5` for depth `grade: 4`** — Staged `tp-autumn-grave-bell` and `tp-resentment-jade-seal` (`kind: "treasure"`, `grade: 4` in depth) with `"rarity": 5` (without `"grade"`), matching `pm-tieu-thieu-quan` and `lint_items.py` treasure validation (`grade = rarity - 1 = 4`).
7. **`stop_clock` for `"silenced"` / `"stuns"`** — Used `stop_clock` (`1.0 s`) for `autumn-comes` (`scale: own.counter.chorus, per: 2`), `a-thousand-years` (`1.0 s`), and `Blood Turns to Jade` (`1.0 s`), because engine `silence` requires a single `"tag"` rather than silencing an entire side (standing ruling R4 / `bang_tam`).
8. **`free_hit` (`dtype: "soul"`) for `The Cadence Like a Drum` echo** — Used `free_hit` (`c: 0.85` uncursed, `c: 1.70` when `foe.curses >= 1`) instead of `fire_art`, because `fire_art` skips `soul_pct` arts in both `engine.py` and `effect_runner.gd`.
9. **Separated curse watchers for `Blood Turns to Jade` vs `A Thousand Years`** — `A Thousand Years` explicitly handles `heavy_breath` 4-pulse expiry -> `jade_mark + 1` itself; `Blood Turns to Jade` watches `slowed_time`, `sundered`, and `slackened_soul` (leaving `heavy_breath` to `A Thousand Years` so it is never double-counted as 2 marks, and excluding `sealed_meridian` so pressing `The Dead Sing Along` does not self-feed). Adjusted `hold-it-down` to `cd: 6.0 s`, `dur: 2 / 3 / 4 s` so its curses expire cleanly between casts (`2 * 1.72 = 3.44 s < 6.0 s` even with `ly_han_bich`'s `+72 %` curse duration) rather than refreshing infinitely.

---

## Băng Tâm Pilot Checklist

- [x] Every Effect changes the fight with and without it on its holders (`Toll for the Dead`, `Blood Turns to Jade`, `The Dead Sing Along`, `The Cadence Like a Drum`), verified at `--gap 0`, `--gap 1`, and a `2.5x` HP extended-fight probe; every art fires.
- [x] No holder slots two stances without a combined stance (`thu_phan` arts/Effects set no stances).
- [x] Each `"your X"` Effect works cleanly for its holder (`ly_han_bich` carries `hold-it-down` + `a-thousand-years` + `autumn-grave-canon` soul songs; `co_ky_am` carries 3 `song` arts; `Blood Turns to Jade` + `The Dead Sing Along` handle curses safely without crashing if other curses are absent).
- [x] Vague depth phrases (`"for a few seconds"`, `"silenced"`, `"light soul hit"`, `"one of their arts is slowed and weakened"`, `"scaled by your Darkness"`) are resolved into concrete rules on every staged record.
- [x] New technique bonuses and passives are sized against the same tier (`0` / `1` / `2`) and explicitly flagged as `[NEW]` below.

---

## Mechanic Table & Depth-vs-Engine Mapping

### Techniques (`design/stage6-staging/thu_phan/techniques/catalogue-sect-thu_phan.json`)

| ID | Name | Tier / Kind | Layers | Depth Text / Lines | Staged Engine Form | Deviations / NEW |
|---|---|---|---|---|---|---|
| `grave-sweeping-chant` | Grave-Sweeping Chant (Tảo Mộ Ca) | 0 / `main` | 6 | `names: []`; `passives`: none stated | `names: ["thuy"]`; `bonuses: []`; **[NEW]** `passives`: `x_soul 4 []`, `soul_res_pct 4 []`, `linh_luc_regen_inc_pct 3 []` (8.0 W of 8); `abilities`: `sweep-the-stones` (L1) | Deviation: `names: ["thuy"]` lint proxy (`body-element-free-names`). **[NEW]** 3 passives sized to tier 0. |
| `autumn-grave-canon` | Canon of the Autumn Graves (Thu Phần Kinh) | 1 / `main` | 9 | `names: []`; `passives`: `x_soul 5 ["song"]`, `soul_res_pct 6.6 []` | `names: ["thuy"]`; **[NEW]** `bonuses`: `than_thuc_pct 10`; `passives`: `x_soul 5 []`, `soul_res_pct 6.6 []`, **[NEW]** `status_duration_pct 10 ["curse"]`, **[NEW]** `linh_luc_regen_inc_pct 5 []` (15.0 W of 16); `abilities`: `ghosts-sing-old-poems` (L1), `add-a-voice` (L2), `autumn-comes` (L4) | Deviations: `names: ["thuy"]` proxy; `x_soul` scope `["song"] -> []` (`b2`). **[NEW]** tier-1 bonus + 2 passives. |
| `jade-of-resentment-ward` | Ward of the Jade of Resentment (Hận Bích Trận) | 2 / `secret` | 12 | `names: []`; `bonuses`/`passives`: none stated | `names: ["thuy"]`; **[NEW]** `bonuses`: `than_thuc_pct 12`, `khi_huyet_pct 10`; **[NEW]** `passives`: `attack_pct 10 ["seal"]`, `status_duration_pct 15 ["curse"]`, `x_soul 6 []`, `defense_pct 4 []`, `status_resist_pct 6 []` (22.4 W of 24); `abilities`: `hold-it-down` (L1), `a-thousand-years` (L5) | Deviation: `names: ["thuy"]` proxy. **[NEW]** tier-2 bonuses + 5 passives. |

### Signature Arts (`design/stage6-staging/thu_phan/arts/part-sect-thu_phan.json`)

| ID | Name | Role / Cost / CD | Depth Text | Staged Engine Form | Deviations |
|---|---|---|---|---|---|
| `sweep-the-stones` | Sweep the Stones (Tảo Thạch) | `soul`, `soul_pct: 0.03`, cost `0.04`, cd `3.0 s` | Light soul damage and lowers foe soul resistance for a few seconds (`tags: ["song"]`). | `soul_hit` (`0.03`) + `on: soul_hit` Effect applying `slackened_soul` (1 stack, `4 s`, `-15` soul res). | Uses `on: soul_hit` Effect instead of `art.statuses` because `soul_hit()` does not apply `art.statuses` (`engine.py`). |
| `ghosts-sing-old-poems` | Ghosts Sing Old Poems (Quỷ Xướng) | `soul`, `soul_pct: 0.035`, cost `0.05`, cd `4.0 s` | Song art dealing soul damage that rises with each voice in the chorus (`tags: ["song"]`). | `soul_hit` (`0.035`) + `on: art_fired` `mod: {x_soul: 25}` scaled by `own.counter.chorus`. | None (`art_fired` runs before `soul_hit`, boosting that cast cleanly). |
| `add-a-voice` | Add a Voice (Thêm Thanh) | `stacks`, `c_art: 0.0`, cost `0.02`, cd `8.0 s` | Gains a chorus voice each time foe's health first falls below 80, 60, 40, 20 %, when foe is Broken, and when you are first Wounded. | Six `per_fight: 1` Effects adding `+1 chorus`: 4 `on: pulse` checks (`foe.hp_share <= 0.80 / 0.60 / 0.40 / 0.20`), `on: broken`, `on: wounded`. | None (uses `per_fight: 1` thresholds so heal-ups never re-trigger; `tags: []` matches depth and avoids triggering `The Cadence Like a Drum` on a zero-damage pulse art). |
| `autumn-comes` | Autumn Comes (Thu Lai) | `soul`, `soul_pct: 0.032`, cost `0.05`, cd `6.0 s` | Spends the chorus: foe silenced for `1 s` per two voices spent and takes soul damage (`tags: ["song"]`). | `on: art_fired`: `mod: {x_soul: 30}` scaled by `chorus`; if `chorus >= 2` -> `stop_clock` `1.0 s` scaled by `chorus / 2` (floored); resets `chorus = 0`; then fires `soul_hit` (`0.032`). | Deviation: `"silenced"` -> `stop_clock` (`silence` requires one specific `"tag"`). |
| `hold-it-down` | Hold It Down (Trấn Hận) | `control`, `c_art: 1.0`, cost `0.05`, cd `6.0 s` | Lays a seal: one of their arts is slowed and weakened; seal lasts longer the more curses the foe already carries. | `tags: ["seal", "curse"]`; `on: hit_landed`: applies `slowed_time` + `sundered` for `2 s` (`foe.curses <= 1`), `3 s` (`2-3`), or `4 s` (`>= 4`). | Deviation: applies whole-foe `slowed_time` + `sundered` (no per-foe-art status exists) in 3 stepped duration branches; `dur 2/3/4 s` with `cd 6.0 s` prevents curse-refresh lock under `+72 %` curse duration. |
| `a-thousand-years` | A Thousand Years (Thiên Niên) | `control`, `c_art: 0.0`, cost `0.05`, cd `7.0 s` | Curse dealing nothing at first, grows each second; on completing full length, stuns foe and leaves a jade mark. | `on: art_fired` lays `heavy_breath` (`4 s`) + `thousand_timer = 4`; clears if cleansed; each `pulse` increments `thousand_age`, decrements `thousand_timer`, deals `free_hit` (`0.35 c * age`, `soul`); on 4th pulse adds `+1 jade_mark` + `stop_clock 1.0 s`. | Deviation: `"stuns"` -> `stop_clock 1.0 s`; growing tick driven by explicit 4-pulse counters rather than fixed tick status `withering`/`bleed` so damage scales linearly (`0.35..1.40 c`). |

### Effects (`design/stage6-staging/thu_phan/effects/thu_phan.effects.json`)

| Name | Source Item / Set | Counters Declared | Depth Rule | Engine Mechanism & Deviations |
|---|---|---|---|---|
| `Toll for the Dead` | `tp-autumn-grave-bell` | `bell_toll_soul` | When foe is Broken or you are first Wounded, your next soul art comes ready at once (>= `cooldown_min`) and gains `+30 %` soul damage. | `on: broken` & `on: wounded` (`per_fight: 1`) -> `timer` (`own`, `which: "all"`, `by: -999`) + `bell_toll_soul = 1`; `on: art_fired` (`dtype: "soul"`) consumes for `mod: {x_soul: 30}`. **Deviation**: `timer` uses `which: "all"` because `timer` cannot filter to `dtype: "soul"` only. |
| `Blood Turns to Jade` | `tp-resentment-jade-seal` | `jade_mark`, `jade_spending`, `jw_slowed_time`, `jw_sundered`, `jw_slackened_soul` | Curses running full length leave 1 jade mark; at 5+, next seal art spends all: stuns `1 s` + light soul hit per mark past 5. | Watches `slowed_time`, `sundered`, `slackened_soul` (`status_applied` -> `cleansed` clears -> `pulse` when `status == 0` grants `+1 jade_mark`); on `art_fired` (`tags: ["seal"]`) with `>= 5` marks, spends 5 + `stop_clock 1.0 s`, deals `free_hit (c: 0.45, dtype: "soul")` per remaining mark, clears. **Deviations**: `heavy_breath` excluded to avoid double-counting `A Thousand Years`; stuns via `stop_clock 1.0 s`. |
| `The Dead Sing Along` | `tp-autumn-graves` (3pc) | `resentment_mark`, `resentment_presses`, `resentment_debt`, `resentment_just_paid`, `resentment_need_debt` | While holding all 3, each curse laid adds 1 Resentment mark; at 7 marks (`+1` per prior press), seals highest layer (`Sealed Meridian`) and deals Darkness-scaled soul damage. | Counts `status_applied` (`slowed_time`, `sundered`, `heavy_breath`, `slackened_soul`) via `resentment_debt` / `resentment_mark` cadence (7, 8, 9... uncapped); on press sets `sealed_meridian` (`layer: 1`, `dur: 3`) + `free_hit` (`c: 1.6`, `dtype: "soul"`). **Deviations**: `layer: 1` (highest standard layer `40` in `fight.py`); fixed `c: 1.6` soul hit approximates Darkness-72 scaling (`own.purity.am` not readable). |
| `The Cadence Like a Drum` | `tp-second-copy` (2pc) | `drum_cadence` | Every third soul song repeats once at half power, or full power against a cursed foe. | Counts `on: soul_hit` (`filter: {"tags": ["song"]}`); at 3, resets and fires `free_hit` (`dtype: "soul"`, `c: 0.85` if `foe.curses == 0`, `c: 1.70` if `foe.curses >= 1`). **Deviation**: uses `free_hit` instead of `fire_art` because `fire_art` skips `soul_pct` arts. |

### Items & Sets (`design/stage6-staging/thu_phan/items/`)

- **6 Unique Items** (`catalogue-sect-thu_phan.json`):
  - `tp-autumn-grave-bell` (`treasure`, `chuong`, `rarity: 5` [grade 4], `43.4 W / 51.2`, R6 `exception`, `holder: ly_han_bich`, Effect `Toll for the Dead`, `art_speed_pct 10 ["soul"]` proxy for `["song"]`)
  - `tp-resentment-jade-seal` (`treasure`, `an`, `rarity: 5` [grade 4], `29.4 W / 51.2`, R6 `exception`, `holder: ly_han_bich`, Effect `Blood Turns to Jade`)
  - `tp-nine-graves-zither` (`artifact`, `cam`, `grade: 3`, `21.0 W / 38.4`, R6 `exception`, `holder: bao_thu_xuong`, `art_speed_pct 10 ["soul"]` proxy for `["song"]`)
  - `tp-barred-door-robe` (`artifact`, `dao_bao`, `grade: 4`, `31.0 W / 51.2`, R6 `exception`, `holder: ly_han_bich`)
  - `tp-grave-drum` (`artifact`, `co`, `grade: 2`, `17.3 W / 25.6`, `holder: co_ky_am`, `art_speed_pct 8 ["soul"]` proxy for `["song"]`)
  - `tp-lined-winter-robe` (`artifact`, `dao_bao`, `grade: 2`, `18.6 W / 25.6`, R6 `exception`, `holder: co_ky_am`)
- **2 Sets** (`sets-thu_phan.json`):
  - `tp-autumn-graves` (`The Autumn Graves`, 3pc on `ly_han_bich`: 2pc `x_soul 5 []`, `status_duration_pct 8 ["curse"]`; 3pc Effect `The Dead Sing Along`)
  - `tp-second-copy` (`The Second Copy`, 2pc on `co_ky_am`: 2pc `x_soul 3 []`, `than_thuc_pct 3 []`, Effect `The Cadence Like a Drum`)

---

## Holder Check & Combat Probes

All 18 living `thu_phan` fighters (11 in `thu_phan.cast.json`, 7 in `thu_phan.5.cast.json`; 1 dead elder skipped) ran with **`0 REFUSED`** under `$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\thu_phan"`.

### `sect_fight.py thu_phan --seeds 5` Summary (`--gap 0` and `--gap 1`)

| Holder | Realm | Slotted Arts | Gap 0 (`mean_s`, `wins/5`, `hp%`) | Gap 1 (`mean_s`, `wins/5`, `hp%`) | Notes / Effect Runs (`gap 0`) |
|---|---|---|---|---|---|
| `ly_han_bich` | `ket_dan` | `ghosts-sing-old-poems`, `add-a-voice`, `autumn-comes`, `hold-it-down`, `a-thousand-years` | `19.5 s`, `5/5`, `77%` | `8.1 s`, `0/5`, `0%` | `Toll for the Dead`: `19.5s 77%` vs `19.8s 77%` (`runs 5`); `Blood Turns to Jade`: `19.5s 77%` vs `19.4s 76%` (`runs 75`, spend delta also checked at `2.5x` HP); `The Dead Sing Along`: `19.5s 77%` vs `19.5s 76%` (`runs 100`) |
| `bao_thu_xuong` | `ket_dan` | `ghosts-sing-old-poems`, `add-a-voice`, `autumn-comes`, `sweep-the-stones` | `19.0 s`, `5/5`, `71%` | `8.0 s`, `0/5`, `0%` | All 4 arts fire (`4.0, 2.0, 3.0, 5.0` at gap 0) |
| `tham_tho_bich` | `truc_co` | `ghosts-sing-old-poems`, `add-a-voice`, `autumn-comes`, `sweep-the-stones` | `20.0 s`, `5/5`, `64%` | `8.0 s`, `0/5`, `0%` | All 4 arts fire (`5.0, 2.0, 3.0, 5.0` at gap 0) |
| `co_ky_am` | `truc_co` | `ghosts-sing-old-poems`, `add-a-voice`, `autumn-comes`, `sweep-the-stones` | `16.2 s`, `5/5`, `72%` | `8.0 s`, `0/5`, `0%` | `The Cadence Like a Drum`: `16.2s 72%` vs `17.6s 72%` (`runs 66`, `-1.4 s` kill time) |
| `on_tich_nhai` | `truc_co` | `ghosts-sing-old-poems`, `add-a-voice`, `autumn-comes`, `sweep-the-stones` | `20.0 s`, `5/5`, `64%` | `8.0 s`, `0/5`, `0%` | All 4 arts fire (`5.0, 2.0, 3.0, 5.0` at gap 0) |
| `hoac_tich_ca`, `tiet_an_suong`, `bui_song_khe` | `truc_co` | `ghosts-sing-old-poems`, `add-a-voice`, `autumn-comes` | `35.6 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | All 3 canon arts fire (`6.8, 3.8, 3.8`); without `sweep-the-stones`'s `slackened_soul`, these 3 inner disciples fall behind `typical` foe at `gap 0` |
| `hua_tang_thu` | `luyen_khi` | `ghosts-sing-old-poems`, `add-a-voice` | `33.6 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | Both layer-1/2 canon arts fire (`7.2, 3.4` at gap 0) |
| 9 outer disciples (`chu_an_thach`, `cam_thuy_ngam`, `thuong_dich_am`, `ton_du_tan`, `dien_xuong_uong`, `phung_co_am`, `cam_vong_nhi`, `nhan_thu_mac`, `tang_mo_sinh`) | `luyen_khi` | `sweep-the-stones` | `37.4 s`, `2/5`, `9%` | `8.0 s`, `0/5`, `0%` | `sweep-the-stones` fires `10.8` times at gap 0, `2.0` at gap 1 |

- **Extended `Blood Turns to Jade` probe (`ly_han_bich` vs `typical`, 5 seeds)**:
  - `1.0x` enemy HP: `WITH_BTJ` `19.5 s` (`5/5`, `77%` HP, `12` expiries, `1` spend+bonus, `9` `The Dead Sing Along` presses) vs `NO_BTJ` `19.4 s` (`5/5`, `76%` HP).
  - `2.5x` enemy HP: `WITH_BTJ` `20.9 s` (`5/5`, `74%` HP, `20` expiries, `5` spends+bonuses, `10` `The Dead Sing Along` presses) vs `NO_BTJ` `21.0 s` (`5/5`, `72%` HP).

---

## Verification Ledger

- `lint_arts.py design/stage6-staging/thu_phan/arts/part-sect-thu_phan.json` -> `checked 6 arts in 1 files, 0 findings`
- `lint_techniques.py design/stage6-staging/thu_phan/techniques/catalogue-sect-thu_phan.json` -> `checked 3 techniques, 0 findings`
- `lint_items.py design/stage6-staging/thu_phan/items/catalogue-sect-thu_phan.json` -> `checked 6 items, 22 bases, 9 common arts, 0 findings`
- `depth_check.py --quiet` -> `findings: none`
- `depth_gap.py --sect thu_phan` -> `beasts 0`, `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `ties_unmapped 0`, `ties_over_cap 0`, `engine_words 0`, `wishes_open 0`, `lines 30/30 runs` (only `events: 4` structured and Stage 6 unmerged records open)
- Standalone `engine.validate`: `STANDALONE_OK` on all 4 Effects and all 6 arts
- `sect_fight.py thu_phan --seeds 5 --gap 0` & `--gap 1` -> `0 REFUSED`, all 6 arts fire, all 4 Effects `runs > 0`

REVIEW DONE
