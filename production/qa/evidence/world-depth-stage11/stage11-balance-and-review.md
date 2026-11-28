# World Depth — Stage 11 Consolidated Balance, Calibration & Holistic Review

- **Date:** 2026-11-28
- **Plan:** `production/plans/world-depth-implementation.md` (Stage 11: Balance Calibration, Full Parity & Holistic Review)
- **Scope:** Stage 11A (Cast Power Probe & Recalibration), Stage 11B (Realms & Bottlenecks Calibration with Land Roll + Traits v2), Stage 11C (Full Parity, Gap Audit & Holistic Review)

---

## 1. Executive Verdict

**VERDICT: PASS — Stage 11 blocker resolved; World Depth plan (Stages 0–11) closed cleanly.**

- The sole Stage 11 blocking finding (`assets/data/combat_rankings.json` calibration drift from pre-Stage-5/6 combat data, plus `k_max = 192` ceiling clipping on high-realm builds) has been resolved:
  1. `tools/design/combat_sim/export_rankings_calibration.py` was refactored to run deterministically in parallel via `ProcessPoolExecutor` (`--workers N`, pre-assigned per-`(r, k)` and per-realm `health_elo` seeds) and verified byte-for-byte identical across `--workers 8` and `--workers 4`.
  2. `KNOBS["k_max"]` was raised from `192` (`x64`) to `256` (`x256`, matching Power Rankings Rule 4's `x1/256..x256` span at `rung_div = 32`), calibrating cleanly across all 5 realms with **0 saturation errors** against unchanged `SATURATION = 0.99` and unchanged `assets/data/combat_reference_fighters.json`.
  3. `assets/data/combat_rankings.json` was refreshed (`data_version: 54dcdea7e7e1bc58`); `export_rankings_calibration.py --check` now exits **`0`** (`same`), and all `5/5` `tests/unit/ranking/` suites (**45/45** test cases) pass with `0` errors, `0` failures, `0` orphans.
  4. Nguyên Anh off-top clipping dropped from **`15/27` (`55.6%`)** to **`4/27` (`14.8%`)**, with **`23/27` (`85.2%`)** resolving inside the ladder. Both authored Hóa Thần (`mac_quy_khu`, `thoi_khinh_hong`) remain above `x256` of the pre-Đạo-Đồ `typical-r4` reference fighter on base panel rating alone (`96,487.0`), while in play Power Rankings Rule 8's every-season round robin (`TOP_REALMS = [3, 4]`) separates them via direct-fight Elo `offset` (`±200`); updating `combat_reference_fighters.json` to post-Đạo-Đồ typicals is tracked in the deferred backlog.
- Stage 11B confirms **no Realms (`canh-gioi.md`) retune is needed** after Stage 9 (land roll) and Stage 10 (Traits v2).
- All **16/16** automated Python verification checks (including `57/57` full parity exact + chancy fixtures) and holistic Stages 0–10 architectural checks **PASS**.

---

## 2. Stage 11A & Post-Recalibration Cast Results

### 2.1 Cast Compilation & Cross-Realm Dominance (Stage 11A)
- **Living cast compilation:** `1,769 / 1,769` living cast builds compile cleanly (`0` compile errors, `0` zero-damage builds).
- **Cross-realm dominance:** `10/10` direct combat dominance across adjacent realm tiers; `thoi_khinh_hong` defeats `mac_quy_khu` `10/10` head-to-head.
- **Stage 11A ladder ceiling finding (before recalibration):** At `k_max = 192` (`2^(192/32) = x64`), `15/27` living Nguyên Anh (`55.6%`) and `2/2` authored Hóa Thần (`100%`) clipped the top ceiling (`88,532.8` for both Hóa Thần).

### 2.2 Calibration Before vs. After (`assets/data/combat_rankings.json`)

| Metric | Before (`k_max = 192`, commit `8eeff014`) | After (`k_max = 256`, Stage 11 Fix) | Delta / Note |
|---|---:|---:|---|
| `data_version` | `7fecf9b26e309372` (stale; pre-`k_max=256` live hash was `483524c338d096e4`) | `54dcdea7e7e1bc58` | Synced to Stage 5–6 combat data + `k_max = 256` |
| `k_max` / rungs per realm | `192` (`385` rungs; `x1/64..x64`) | `256` (`513` rungs; `x1/256..x256`) | Matches Power Rankings Rule 4; `max_fights(256, 0, 64, 1, 4)` stays `40` |
| `rung_div` / `SATURATION` | `32` / `0.99` | `32` / `0.99` | Unchanged; **0 saturation errors** across all 2,560 rung gaps |
| `health_elo` | `3134.007` | `3126.109` | `-7.898` |
| Anchor R0 (Luyện Khí) | `1000.0` | `1000.0` | Fixed `A_0` |
| Anchor R1 (Trúc Cơ) | `14195.063` | `14293.011` | `+97.948` |
| Anchor R2 (Kết Đan) | `29505.642` | `29590.464` | `+84.822` |
| Anchor R3 (Nguyên Anh) | `46841.959` | `46546.877` | `-295.082` |
| Anchor R4 (Hóa Thần) | `61626.859` | `61222.778` | `-404.081` |
| Ladder R0 `[min .. max]` | `-22,874.6 .. 22,517.2` | `-27,647.7 .. 29,230.8` | Power `1 .. 9,470` |
| Ladder R1 `[min .. max]` | `-9,334.8 .. 38,182.3` | `-11,547.8 .. 46,287.2` | Power `11 .. 96,500` |
| Ladder R2 `[min .. max]` | `4,573.0 .. 55,872.3` | `4,082.8 .. 64,378.3` | Power `171 .. 1,640,000` |
| Ladder R3 `[min .. max]` | `30,609.4 .. 70,994.4` | `29,637.9 .. 78,421.9` | Power `10,100 .. 14,900,000` (`+7,427.5` ceiling) |
| Ladder R4 `[min .. max]` | `47,694.8 .. 88,194.8` | `45,403.1 .. 96,149.0` | Power `85,600 .. 240,000,000` (`+7,954.2` ceiling) |

**Parallel calibration & determinism timings (`export_rankings_calibration.py`):**
- Write (`--workers 8`): exit `0`, **`585.59 s`** (`9m 46s`), `anchors [1000.0, 14293.011, 29590.464, 46546.877, 61222.778]`, `health_elo 3126`, realm-0 typical rung gap `108.2`.
- Determinism check (`--check --workers 8`): exit `0`, **`same`** (`670.28 s`, concurrent with Godot probe/tests).
- Cross-worker determinism check (`--check --workers 4`): exit `0`, **`same`** (`1,077.84 s`), proving byte-for-byte identical output regardless of worker count.

### 2.3 Post-Recalibration Nguyên Anh & Hóa Thần Full-Panel Spread (Seed `"101"`, `world_cultivators = 5000`, `coarse = false`)
Measured via headless Godot probe (`WorldBuilder` + `RatingService` full panels, `25.99 s` build + `53.16 s` panels):

- **Nguyên Anh (`r = 3`, `n = 27` living, ladder `[29,637.9 .. 78,421.9]`):**
  - **Off-top (`4/4` at rung `256`):** **`4 / 27` (`14.8%`)** — down from **`15 / 27` (`55.6%`)** before recalibration!
    - Top 4 off-top: `nhiep_co_tan`, `cu_thuy_bach`, `nhiep_tan_sa`, `le_tieu_hon` (`base = 78,759.9`, `power = 15,700,000`).
  - **In-ladder (`23 / 27`, `85.2%`):**
    - `#05 manh_da_vu` (`78,510.6`, `power 15,100,000`, `3/4` at rung `256`), `#06 hoa_trieu_duong` (`76,865.4`, `11,600,000`), `#07 ngu_lam_son` (`76,014.7`, `10,200,000`), `#08 phan_vat_hoa` (`75,441.8`, `9,310,000`), `#09 dam_tung_lai` (`75,294.1`, `9,100,000`), `#10 du_tinh_luu` (`74,679.2`, `8,260,000`), `#11 canh_truong_thien` (`74,592.2`, `8,150,000`), `#12 tram_tich_duong` (`73,884.7`, `7,290,000`), `#13 tong_toa_van` (`73,295.9`, `6,650,000`), `#14 doan_ngoc_hanh` (`72,525.8`, `5,890,000`, median), `#15 su_hoanh_duc` (`71,273.8`, `4,840,000`), `#16 uy_thanh_diem` (`71,021.5`, `4,650,000`), and `#17..#27` (`to_van_chieu` `70,225.4` down to `phuong_truc_ngon` `59,808.3`, `power 801,000`).
  - **Summary:** min `59,808.3` | median `72,525.8` | max `78,759.9` (`0` off-bottom).
- **Hóa Thần (`r = 4`, `n = 3` living in seed `"101"`, ladder `[45,403.1 .. 96,149.0]`):**
  - Generated Hóa Thần `Doãn Tùng` (`p3646`, stage 0): resolves cleanly inside the ladder at **`79,026.7`** (`power 16,300,000`, bracketed around rung `131`).
  - Authored Hóa Thần `mac_quy_khu` (`p15`, stage 2) and `thoi_khinh_hong` (`p16`, stage 1): both still sweep `4/4` at rung `256` (`base = 96,487.0`, `power = 253,000,000`, up from `88,532.8`), because full Đạo Đồ + authored sets exceed `x256` of the pre-Đạo-Đồ `typical-r4` reference fighter in `combat_reference_fighters.json`.
  - **Runtime impact:** In live play, Power Rankings Rule 8 runs an every-season round robin across `TOP_REALMS = [3, 4]`, so `thoi_khinh_hong` (who beats `mac_quy_khu` `10/10`) pulls ahead via Elo `offset` (`±200`). Separating their base panel ratings without raising `k_max` past Rule 4's `x256` requires regenerating `combat_reference_fighters.json` against post-Đạo-Đồ typicals (tracked as Advisory #6 / Deferred Decision #8).

### 2.4 Ranking Unit Test Verification (`tests/unit/ranking/`)
Ran `Godot_v4.7.1-stable_win64_console.exe --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/ranking --ignoreHeadlessMode -c` (`Exit code: 0`, total `8m 7s`):

| Test Suite | Cases | Errors | Failures | Orphans | Duration | Status |
|---|---:|---:|---:|---:|---:|---|
| `rating_ladder_search_test.gd` | 7 | 0 | 0 | 0 | 272 ms | **PASSED** |
| `rating_season_batch_test.gd` | 20 | 0 | 0 | 0 | 4s 202ms | **PASSED** |
| `rating_service_test.gd` | 6 | 0 | 0 | 0 | 1s 957ms | **PASSED** |
| `rating_session_test.gd` | 9 | 0 | 0 | 0 | 6m 38s 934ms | **PASSED** |
| `rating_workers_test.gd` | 3 | 0 | 0 | 0 | 1m 21s 685ms | **PASSED** |
| **Total (5/5 suites)** | **45** | **0** | **0** | **0** | **8m 7s 50ms** | **PASSED** |

---

## 3. Stage 11B — Realms & Bottlenecks Calibration (`linh-can.md` OQ 16 + `balance-depth.md`)

Re-validated Realms (`canh-gioi.md`) macro targets after Stage 9 (province land roll + sect admission) and Stage 10 (Traits v2):

| Probe | Command / Configuration | Observed Metrics | Target / Baseline | Verdict |
|---|---|---|---|---|
| **World Census** | `tools/balance/world_census.gd` (seeds `101` / `202`, `N = 5,000`) | Arrival fated shares `0.1245 / 0.0816 / 0.0667`; living Hóa Thần `3–4` | NPC 1 in `8 / 12 / 15` (`0.1250 / 0.0833 / 0.0667`); Hóa Thần `~3` | **ON TARGET** |
| **NPC Cohort** | `tools/balance/npc_cohort.gd` (`all edges`) | `70% / 72% / 28% / 19%` across gates | Player edge `70% / 70% / 30% / 20%` | **ON TARGET** |
| **Autoplay (`--edge off`)** | `tools/balance/autoplay.gd --edge off` | `33.3% / 28.6%` (`8.3%` Kết Đan) | Unassisted baseline | **ON TARGET** |
| **Autoplay (`--edge on`)** | `tools/balance/autoplay.gd --edge on` | `58.3% / 69.2%` | Matches `ape11` baseline | **ON TARGET** |

**Conclusion:** All macro population, gate-arrival, cohort, and autoplay targets hold within tolerance under the land roll and Traits v2. Per `balance-depth.md`, **no Realms retune is needed**.

---

## 4. Stage 11C — Verification Suite & Holistic Design / Implementation Review

### 4.1 All 16 Automated Verification Checks

| # | Command | Exit | Result Summary |
|---|---|---:|---|
| 1 | `python -B -I tools/design/combat_sim/parity_export.py --check` | **0** | **57/57 `same`** (`sim_defaults.json` + 44 exact + 12 chancy fixtures including `t15_escape_chancy`, `t2_*`, `t3_chancy_marks`, `t4*_chancy`, `t5_chancy`, `t6_typical_mirror_r0..r4`; **0 drift, 0 bad**). |
| 2 | `python -B -I tools/design/combat_sim/export_rankings_calibration.py --check` | **0** | **FIXED (was exit 1 `DRIFT`):** now **`same assets/data/combat_rankings.json`** (`data_version: 54dcdea7e7e1bc58`, `k_max = 256`; verified with both `--workers 8` and `--workers 4`). |
| 3 | `python -B -I tools/design/world/depth_gap.py` | **0** | `techniques 213/0`, `arts_new 365/0`, `arts_ref 95/0`, `items 490/0`, `sets 166/0`, `beasts 21/0`, `events 277/0`, `stand_ins 0/0`, `unknown_ids 0/0`, `cross_owner 72/0`, `ties_unmapped 0/0`, `ties_over_cap 16/0`, `wishes_open 0/0`, `records still rule text: 0`. Open observations: `effects 13/363` (12 out-of-fight `not_run` + 1 Darkness `not_run`), `lines 11/3208` (9 `attack_pct [am]`, 1 `stack_effect_pct [bleed]`, 1 `pierce_pct [sword]`), `engine_words 47` (unstructured rule-text regex hits). |
| 4 | `python -B -I tools/design/traits/export_traits.py --check` | **0** | Current (`personality: 37`, `callings: 14`, `fate: 4`, `retired_fates: 6`, `gained: 16`, `upbringing: 12`, `talent: 12`, `path: 24`, `lifestyle: 14`, `health: 10`, `coping: 8`, `opposed_v2: 13`, `path_root_bonds: 4`, `policy_hooks: 4`, `verb_hooks: 19`). |
| 5 | `python -B -I tools/design/items/export_techniques.py --check` | **0** | `items_cong_phap.json is current` |
| 6 | `python -B -I tools/design/items/export_named.py --check` | **0** | `items_named.json and items_sets.json are current` |
| 7 | `python -B -I tools/design/combat_sim/export_combat_library.py --check` | **0** | `same assets/data/combat_library.json` |
| 8 | `python -B -I tools/design/world/export_world.py --check --sect all` | **0** | `written: false`, `data_version: d9dbb2d43a48b745`, `sects: 50`, `fallen_sects: 11`, `people: 1909`, `living: 1748`, `events: 965`, `ties: 2054`, `beasts: 21`, `depth_sects: 56` (50 sects + 6 outside groups). |
| 9 | `python -B -I tools/design/combat_sim/compile_parity_export.py --check` | **0** | `same tests/parity/compile/compile_cases.json` |
| 10 | `python -B -I tools/design/arts/lint_techniques.py` | **0** | `checked 247 techniques, 0 findings` (`428/428` signature arts carried). |
| 11 | `python -B -I tools/design/arts/lint_arts.py` | **0** | `checked 459 arts in 57 files, 0 findings` (`engine 251, standalone 208`; `authored 409, common 50`). |
| 12 | `python -B -I tools/design/items/lint_items.py` | **0** | `checked 661 items, 22 bases, 9 common arts, 0 findings` (`unique: 516/661`). |
| 13 | `python -B -I tools/design/world/depth_check.py --quiet` | **0** | `people 1891`, `techniques known 266`, `items known 661`, `builds with Đạo Đồ targets: 435`, **`findings: none`**. |
| 14 | `python -B -I tools/design/combat_sim/test_engine.py` | **0** | `293 PASS` lines, **`0 failed`**. |
| 15 | `python -B -I tools/design/world/spatial_words_check.py` | **0** | `files 237; hit lines 447 (depth 312, shipped 135); records with a hit 310; non-soft rule-field records: 118; by class: key 2, postponed 41, removed 151, rename 31, soft 122` (see Advisory #1). |
| 16 | `python -B -I tools/design/combat_sim/tree_effects_check.py` | **0** | 55 Đạo Đồ Effects checked: 43 alter outcomes (11–12/12 seeds), 4 `Pending (not run)` (out-of-fight hosts), 8 `NO CHANGE` in fixed test kit (expected when triggers/down-events do not fire). |

### 4.2 Holistic Stages 0–10 Architecture & Rule Alignment Summary
- **Combat Engine & Parity (Stages 5–6):** All 56 exact+chancy fixtures (`t1_*`–`t33_stage6_leftovers_exact`) match identically across Python and GDScript. All 21 `CHARACTER_MODS.out_of_fight` keys in `combat_engine.json` have verified GDScript consumers. Zero active Effects violate `no-environment-conditions` or `no-spatial-fight`; 31 multi-fighter/ally-counting records remain cleanly parked in `design/world/depth/builds/postponed-2026-11-26.json`. 233/363 world-depth Effects carry documented `approx` annotations surfaced via `unmod`.
- **World Export, Cast, Ties, Beasts & `PlaceholderArt` (Stages 6–8):** `world_history.json` carries all 50 active sects, 11 fallen sects, 56 `depth_sects`, 1,909 people (`1,748` living + `161` dead), `1,748` `cast_builds`, `965` events (`277/277` depth), `2,054` ties, `21` beasts, `world_data_version: 1` (refused cleanly on mismatch in `game_session.gd`). `portraits.json` covers `1,909/1,909` cast portraits (`0` missing `.webp`); all 21 beasts and 80 v2 trait medallions render via `PlaceholderArt` with zero stand-in faces.
- **Linh Căn Land Roll & Sect Admission (Stage 9):** All `50/50` sects in `world_continent.json` match `design/world/depth/seats.json` (`0` mismatches); `705/705` provinces carry `land_qi` and `variant_max`. `linh_can.gd` implements Formulas A2/D4 (`AC-LC-59` even-land identity preserved) and `sect_admission.gd` enforces F20/F21 owned-only purity across world gen and `world_ticker.gd` parent-province births.
- **Traits v2, `StatSheet` & Character Sheet C3 (Stage 10):** `traits.json` exports all `151` traits (`71` v1 with `74` doubled personality rows + `80` v2 across 6 new kinds, `6` retired fates, `15` choice-weighted traits, `4` `policy_hooks`, `19` `verb_hooks`). Across `1,748` living cast: `0` unknown traits, `0` unmigrated retired fates, `0` opposed pairs. `StatSheet` applies `NpcTraits.stat_rows()` before `CongPhap.bonus_lines()`; `CharacterWindow` displays C3 shifted talent grades and all 10 trait kinds.

### 4.3 `WIRED.md` Open Items Audit (`design/world/depth/builds/authored/WIRED.md`)

| Plan Item (`world-depth-implementation.md` L522–540) | Verified Status | Ground Truth |
|---|---|---|
| **b2** (`string-cut`, `cam` base, `hollow-bell-canon`) | **RESOLVED / WIRED** | `string-cut` tagged `['artifact', 'song']`; `cam` base carries `tags: ['song']`, `common_art: 'string-cut'`; `hollow-bell-canon` carries `x_soul 3 [song]`. |
| **b9** (`palm` tags, `hundred-echo-palm-scripture`, `ta-goose-bone-beads`) | **RESOLVED / WIRED** | `rolling-barrage-fist` and `twin-shadow-fist` tagged `'palm'`; `hundred-echo-palm-scripture` has `art_speed_pct 8 [palm]`; `ta-goose-bone-beads` rescoped to `attack_pct 12 [palm]`. |
| **b10** (bow scopes) | **RESOLVED / WIRED** | `pine-warden-staff-and-bow-canon` (`attack_pct 6 [bow]`, `crit_damage_pct 20 [bow]`), `the-leader-first` (`['physical', 'bow', 'heavy']`), `ttg-wolf-winter-bow` (`attack_pct 21 [bow]`). |
| **d11** (`Debt Stone` on `mountain-heart-canon` & `lh-nails-of-dao-sa`) | **RESOLVED / WIRED** | `mountain-heart-canon` unlocks passive art `Debt Stone` (layer 1); `Debt Stone` & `Fished from the Shallows` active in `combat_effects.json` and wired on `lh-nails-of-dao-sa` in `items_sets.json`. |
| **d12** (`Written in the Ledger` on `ruin-ledger-scripture`) | **RESOLVED / WIRED** | `ruin-ledger-scripture` unlocks passive art `Written in the Ledger` (layer 3); active in `combat_effects.json`. |
| **b13** (`tx-dao-quang-war-flag` companion lines) | **RESOLVED / WIRED** | Carries `companion_power_pct 10` & `companion_speed_pct 10`, mapped in `combat_engine.json` and read by `engine.py` and `fight.gd`. |
| **b5 / b12** (`herb_growth_pct` & `curse_effect_pct`) | **RESOLVED / WIRED** | `tx-miasma-root-charm` (`herb_growth_pct 8` -> `herb_field.gd`) and `ls-snare-wire-coins` (`curse_effect_pct 10` -> `engine.py` / `fight.gd`). |
| **Stale `build_use` lines** (`tx-miasma-root-charm`, `ls-snare-wire-coins`) | **RESOLVED** | Both restored lines match their `build_use` descriptions again. |
| **Way-Out Knot** (`phong_bach_ke`, `hua_thanh_diem`, `nham_do_han`) | **RESOLVED / WIRED** | `mf-way-out-knot` made non-unique (`bfc48f75`); all four (`hoang_phu_duyen`, `phong_bach_ke`, `hua_thanh_diem`, `nham_do_han`) wear it in `world_history.json`. |
| **Two aux choices** (`sai_thanh_phong`, `pham_thu_dien`) | **RESOLVED IN DATA** | Wired in `world_history.json`: `sai_thanh_phong` (`evening-song-of-the-boats` L5); `pham_thu_dien` (`mountain-bone-body-art` L5, `haze-walk` L5). |
| **e9 `cung_mac_suong` `black-ice-method`** | **INTENTIONALLY HELD** | Exported in `items_cong_phap.json`; `cung_mac_suong` starts with `aux: []` until her story branch turns. |
| **Eighth Movement readings** (`nine-shao-advent` vs `pm-tieu-thieu-quan`) | **RESOLVED / ALIGNED** | Both use the same `"holds its arts for 2 s"` reading (`cfce4c0c`). |
| **2 refused / 2 not-authored wishes** (`auth-eff-2.json`, `auth-tech.json`) | **RESOLVED / CLOSED** | Closed in `cfce4c0c` (`wishes_open: 0/0`). |
| **Post-Stage-11 Power Rankings offline precompute** | **OPEN / DEFERRED** | Awaits settled combat/cast data and Power Rankings GDD amendment. |

### 4.4 Advisory / Non-Blocking Items
1. **Legacy `"still"` tag on `the-pivot-does-not-turn` (Check #15):** `assets/data/combat_library.json` (from `design/arts/part-sect-thien_xu.json`) still carries `"still"` in `tags: ["earth", "formation", "still"]` — the last shipped `spatial_words_check.py` `key` hit. Its effects already read `own.composed >= 1` (`kind: "elem"`), so gameplay is unaffected.
2. **2 remaining non-Darkness open modifier scopes in `depth_gap.py` (Check #3):** `stack_effect_pct [bleed]` (`red-debt-rite`) and `pierce_pct [sword]` (`lone-branch-sword`) execute unscoped because `stack_effect_pct` scopes element/buff/debuff only and `pierce` is not in `CHARACTER_MODS.ctx_mods`.
3. **80 v2 trait medallion icons uncreated:** All 80 v2 traits render `PlaceholderArt` in `CharacterWindow` (100% compliant with `placeholder-for-missing-art.md`); painting is a future art task.
4. **Stage 2 minor follow-ups noted in plan:** Băng Tâm's new island seat (`214`) inherits `< 2` place-catalogue levels from the ruin; 12 unmoved minor seats whose province was seated elsewhere remain scheduled for their own commit.
5. **11A/11B outlier builds:** Per `balance-depth.md`, strong individual cast builds are accepted as long as macro averages hold.
6. **Pre-Đạo-Đồ reference fighter baseline (`combat_reference_fighters.json`):** At `k_max = 256` (`x256` of pre-Đạo-Đồ `typical`), `4/27` elite Nguyên Anh and `2/2` authored Hóa Thần (`mac_quy_khu`, `thoi_khinh_hong`) still sweep rung `256` on base panels (`96,487.0`). Rule 8's seasonal round-robin `offset` separates them in live play; regenerating `combat_reference_fighters.json` to post-Đạo-Đồ typicals will also separate their base ratings cleanly.

### 4.5 Deferred User Decisions (Backlog)
1. **Kept meter writeback policy (`Playing Past the Break`):** `Character.fight_meters` and `save_fight_meters()` are wired for reads in `FighterCompiler`, with no live fight runner calling `save_fight_meters()` yet — user to decide which fight types write back (real duels/events vs. read-only panels/trials/NPC background fights).
2. **Darkness element (`am`) stack mechanics & 9 `attack_pct [am]` lines + `The Banner Is Raised`:** Currently `not_run` / unmatched scope until Darkness's stack rule is designed in the Effects/Damage Types GDD.
3. **Curse-reflect half of `A Fair Copy` (`thien_xu`):** Intentionally `not_run` (`curse-reflect` deferred at Stage 6 `b01`).
4. **`diagram_always` (Formations rule 9):** Outside the fight engine; belongs to the Formations runtime follow-up.
5. **31 postponed multi-fighter/ally-counting records (`postponed-2026-11-26.json`):** Parked until multi-fighter combat is built.
6. **Dialogue Verbs #30 consumer:** `traits.json` (`19` `verb_hooks`) and `NpcTraits.opened_hooks()` / `available_verbs()` are ready for the Dialogue Verbs (#30) implementation.
7. **21 Spirit Beast portraits & 80 v2 trait medallions:** Render `PlaceholderArt` until painting is commissioned.
8. **Post-Stage-11 Power Rankings offline precompute (+ optional post-Đạo-Đồ `combat_reference_fighters.json` refresh):** Precomputing ratings for the 1,748 living cast offline and amending the Power Rankings GDD once cast builds and combat data settle.
