# Market Folk (`market-folk`): Stage 6 Checkpoint Review (2026-11-27, headless, decisions auto-accepted)

## What this review read
Independent, unanchored audit of `market-folk` (`design/world/depth/people/market-folk.*` and `design/stage6-staging/market-folk/`) against the depth texts, committed catalogues, studio rulings, and both combat engines:
- **Staged files (`design/stage6-staging/market-folk/`):** `techniques/catalogue-sect-market-folk.json` (`8` techniques), `arts/part-sect-market-folk.json` (`12` arts), `items/catalogue-sect-market-folk.json` (`25` items), `items/sets-market-folk.json` (`8` sets), `effects/market-folk.effects.json` (`17` Effects: `16` combat + `1` `not_run`); no `pending.json`.
- **Committed reference files:** `design/techniques/catalogue-sect-market-folk.json` (`censer-smoke-manual`), `design/arts/part-sect-market-folk.json` (`pill-smoke`), `design/arts/part-sect-cung_tinh.json`, `assets/data/combat_effects.json`, `assets/data/combat_engine.json`, and `design/world/depth/` (`sects/cung_tinh.*`, `phat_y.*`, `DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`).
- **Depth files (`design/world/depth/people/`):** `market-folk.md`, `market-folk.techniques.json`, `market-folk.items.json`, `market-folk.cast.json`, `market-folk.2.cast.json`.
- **Rules & engine code:** `production/plans/stage6/_brief-review.md`, `_brief-record.md`, `tools/design/combat_sim/FIGHT-INPUT.md`, `tools/design/combat_sim/engine.py`, `tools/design/combat_sim/sect_fight.py`, `src/gameplay/combat/fight/effect_compiler.gd`, `src/gameplay/combat/fight/effect_runner.gd`, `src/gameplay/character/character.gd`, `src/gameplay/cultivation/cong_phap.gd`.

---

## 1. Ranked Findings

| # | File | Record ID | What was wrong | Fix applied | Rank |
|---|---|---|---|---|---|
| 1 | `design/world/depth/people/market-folk.cast.json`, `design/stage6-staging/market-folk/arts/part-sect-market-folk.json` | `ve_van_co`, `walking-ward` | (a) `ve_van_co.build.aux` listed **3** aux techniques (`armillary-array-canon@7`, `loom-of-letters-array@6`, `mountain-bone-body-art@5`), violating `schema.md` (`aux ≤ 2`) and `Character.aux_tech` (`["", ""]`), producing `8` arts (`> MAX_ARTS = 6`) and `4` stance arts (`the-stars-bow`, `ring-of-the-hour`, `walking-ward`, `mountain-root-stance`). (b) In `walking-ward`, `walking-ward-end` unconditionally ran `state {set: null}` when `walking_field == 0`, wiping `field_up` even while `stars_bow` or `ring` remained active, and `walking-ward.states` omitted `"stars-bow"` and `"armillary-ring"`. (c) `walking-ward-refresh-bow` and `walking-ward-refresh-ring` had separate `limit: {"per_fight": 1}` gates instead of sharing one once-per-fight Field refresh. | Removed `mountain-bone-body-art` from `ve_van_co.build.aux` (leaving the 2 lore-backed aux methods `armillary-array-canon@7` and `loom-of-letters-array@6`, `6` arts total). In `walking-ward`, declared `"stars-bow"` and `"armillary-ring"` (`tags: ["field"]`) in `states`, added `walking_refreshed` (`cap: 1`) shared by `walking-ward-refresh-bow` and `walking-ward-refresh-ring`, and replaced unconditional exit with `walking-ward-handoff-bow`, `walking-ward-handoff-ring`, and `walking-ward-end` (setting `null` only when both `stars_bow == 0` and `ring == 0`). | MUST-FIX |
| 2 | `design/world/depth/people/market-folk.2.cast.json` | `quan_than_ngon` | Stage 6 stand-in replacement gave `quan_than_ngon` (`root: {"elements": {"thuy": 42, "tho": 36}}`, lacking `kim`) `golden-valley-ledger-canon` (`names: ["kim", "tho"]`). Under `CongPhap.usable()` (`cong_phap.gd:43-47`), he cannot use `golden-valley-ledger-canon` and `CongPhap.season_tick()` clears an unusable `main_tech` to `""`. | Replaced `quan_than_ngon.build.main.tech` with `mountain-heart-canon` (`tier: 1`, `names: ["tho"]`, `layer: 3`), matching his original `huyen_tho` stand-in tier and Earth clerk build (`mountain-stance` `9.6/fight`, `sinking-weight` `5.2/fight`, `3/5` wins at `--gap 0`), and documented the `CongPhap.usable()` reason in `build.note`. | MUST-FIX |
| 3 | `design/stage6-staging/market-folk/effects/market-folk.effects.json` | `Ride Out the Storm` (`eff:Ride Out the Storm:decay`) | `decay` checked `own.composed < 1` instead of `own.pressing >= 1`. In `engine.py` / `fight.gd`, a non-movement damaging art (`swelling-tide-palm`) drops `composed` for 2 s without setting `pressing = 1`, decaying Water buffs when the fighter is not Pressing. | Changed `eff:Ride Out the Storm:decay`'s `if` condition from `own.composed < 1` to `own.pressing >= 1`, matching *"the stacks fall away one a second once you are Pressing"*. | SHOULD |
| 4 | `design/stage6-staging/market-folk/effects/market-folk.effects.json` | `Paid in Full` (`eff:Paid in Full`) | Protected only `"earth"` and `"metal"` debuff batches (`for_first: 4.0`), whereas `mf-golden-valley-seal`'s rule applies to *"a debuff you apply"* without element restriction (e.g., `quan_phuc_thu` also holds a Water root). | Expanded `eff:Paid in Full` to call `protect {for_first: 4.0}` for all 9 engine elements (`fire`, `water`, `earth`, `metal`, `wood`, `ice`, `thunder`, `wind`, `light`) and updated `approx`. | SHOULD |
| 5 | `design/stage6-staging/market-folk/effects/market-folk.effects.json` | `Carried Array` (`eff:Carried Array:*`) | Declared unused `{"id": "ring", "each_for": 14}` in `counters` (not referenced by any record) and gave `refresh_bow` / `refresh_walk` separate `per_fight: 1` limits instead of one once-per-fight Field refresh. | Removed unused `ring` from `Carried Array.counters`, added shared `seal_arr_refreshed` (`cap: 1`) across `refresh_bow` and `refresh_walk`, and updated `approx` accurately. | SHOULD |
| 6 | `design/stage6-staging/market-folk/effects/market-folk.effects.json`, `design/stage6-staging/market-folk/arts/part-sect-market-folk.json` | `Ground Like Paint`, `Second Spring`, `The Books Balance`, `call-the-debt` | (a) `eff:Ground Like Paint:echo` did not reset `paint_echo_g = 0` after echoing, leaking grade stacks if a subsequent pill burns. (b) `eff:Second Spring` listened on `pulse` (`own.hp_share < 0.25`) instead of `wounded`, missing sub-second threshold crossings between pulses. (c) `eff:The Books Balance` added an unprompted `limit: {"per_pulse": 1}` that would drop a second cleanse in the same pulse. (d) `call-debt-open` fired on `art_fired` rather than `hit_landed` (arming `debt_sum += 2` even if `call-the-debt` was evaded), and `call-debt-clear` required `debt_active >= 1`, leaving stale `debt_sum` after `debt_active` expired and Earth debuffs fell off. | Reset `paint_echo_g = 0` inside `eff:Ground Like Paint:echo`; switched `eff:Second Spring` to `on: "wounded"` (verified `5/5` runs on `gia_hoi_xuan` at `--gap 1` vs `0` prior); removed `per_pulse: 1` from `eff:The Books Balance`; moved `call-debt-open` to `on: "hit_landed"` (`filter: {"art_id": "call-the-debt"}`) and guarded `call-debt-clear` on `own.counter.debt_sum >= 1` and `foe.debuff.earth == 0`. | SHOULD |
| 7 | `design/world/depth/people/market-folk.md` | §9 `Apricot Clinic` | Still wrote `Full set: Second Spring (Hồi Xuân)` instead of the disambiguated `Apricot Clinic's Spring (Hạnh Quán Hồi Xuân)` used in `market-folk.items.json`, `sets-market-folk.json`, and `market-folk.effects.json`. | Updated line 227 in `market-folk.md` to `Apricot Clinic's Spring (Hạnh Quán Hồi Xuân)`. | SHOULD |
| 8 | `design/world/depth/people/market-folk.2.cast.json` | `phong_kinh_sa`, `ngu_hoa_sa`, `dieu_thiet_tien`, `quan_liem_chu`, `ha_kho_sam`, `trinh_hong_tien` | Pre-existing non-stand-in builds: `phong_kinh_sa` & `ngu_hoa_sa` (`thuy, tho`) hold `star-pacing-primer` (`cung_tinh`, `names: ["tho", "kim"]`) and `dieu_thiet_tien` (`tho, kim`) holds `dry-road-sword-primer` (`phat_y`, `names: ["kim", "hoa"]`); also those `luyen_khi` `stage: 2` builds (`quan_liem_chu`, `ha_kho_sam`, `trinh_hong_tien`, `dieu_thiet_tien`) sit at `layer: 4` (above `CongPhap.gated()` cap `3`, matching 470 entries across casts). | **Not applied** (pre-existing cross-owner methods matching `cung_tinh-checkpoint.md` #5 and `phat_y-checkpoint.md` #4; changing them would contradict their backstories). Logged in Open items for Stage 7/9 `CongPhap.usable()` OR-vs-AND ruling. | NIT |

---

## 2. Specific Checks Verified

- **Committed preservation:** Byte-for-byte match confirmed between committed `design/techniques/catalogue-sect-market-folk.json` (`censer-smoke-manual`) / `design/arts/part-sect-market-folk.json` (`pill-smoke`) and staged `market-folk` copies; cross-owner references (`chan_kim`, `phuong_minh`, `thinh_vu`, `hermits-sages`) remain intact.
- **Uniqueness & pitfall audit:**
  - `0` Effect name or record-ID collisions across `assets/data/combat_effects.json`, committed `design/`, and all other `design/stage6-staging/*` directories; `mf-way-out-knot` keeps `"new": false` referencing `world-depth:thien_xu`'s `Know the Way Out`; `"Second Spring"` collision resolved cleanly via `"Apricot Clinic's Spring"`.
  - Top-level `market-folk.effects.json` carries `"_doc"` and `"source": "world-depth:market-folk"`.
  - All `16` combat Effects pass `engine.validate()` standalone with every read/written counter and set stance declared on their own entry (`The Way In` cleanly marked `not_run` with `records: []`).
  - `0` `always` records with record-level `filter`, `0` multi-`mod` clobbers without `"stack": true`, `0` `temp_mods` filtering by `"art_id"` or putting `status_immune` on `temp_mods`, `0` `held` records with `"filter"`, `0` `each_for` + `cap: 1` counters using `"set": 1`, `0` unprompted `cap` fields (`scale-without-caps`).
- **Items & sets (`25` items, `8` sets):** 1:1 diff against `market-folk.items.json` confirmed exact match on all names, Hán-Việt parentheticals, modifiers, set pieces, 2pc/3pc bonuses, and stories (with R6 `exception` on the 13 `cham`/`an`/`tien_tieu`/`mao`/`ho_lo`/`dao_bao`/`thuan`/`giap`/`chuong` items, `"base": "ky", "rarity": 5` on `mf-peach-spring-painting`, and `"holder": "hoang_phu_duyen"` on `mf-way-out-knot`).
- **Cast root fit (`CongPhap.usable()`) & `@6` equips:** `lac_dan_thanh` (`censer-smoke-manual@6`, `5` arts, `1` stance), `gia_hoi_xuan` (`second-spring-needle-art@6`, `6` arts, `1` stance), `ve_van_co` (`loom-of-letters-array@6`, `2` aux, `6` arts, coordinated Field stances), and all `20/20` Stage 6 stand-in replacements (with `quan_than_ngon` fixed to `mountain-heart-canon@3`) pass `CongPhap.usable()`. Only the `3` pre-existing cross-owner `cung_tinh`/`phat_y` builds remain open for Stage 7/9.
- **Linters & checks (all run post-edit with `DEPTH_STAGE=design/stage6-staging/market-folk`):**
  - `lint_techniques.py`: `checked 8 techniques, 0 findings` (`censer-smoke-manual` `NOT ASSESSED` due to `pill_effect_pct`, `15.2/16`, `15.3/16`, `19.5/24`, `15.6/24`, `13.7/16`, `6.0/8`, `7.4/8` W).
  - `lint_arts.py`: `checked 12 arts in 1 files, 0 findings`.
  - `lint_items.py`: `checked 25 items, 22 bases, 9 common arts, 0 findings`.
  - `spatial_words_check.py --sect market-folk`: `0` hits in `market-folk` files.
  - `depth_check.py --sect market-folk --quiet`: `findings: none`.
  - `depth_gap.py --sect market-folk`: `stand_ins: 0`, `unknown_ids: 0`, `engine_words: 0`, `wishes_open: 0`, `cross_owner: 11` (all `catalogue`).
  - `stage6_merge.py market-folk --check`: `0 failure(s)`.
  - `put_effects.py ... --check`: clean (`combat_effects.json would change`).

---

## 3. Pending Words

None (`pending.json` absent; `0` pending engine words).

---

## 4. Holder Table After Fixes (`sect_fight.py market-folk --seeds 5`, `0 REFUSED`)

| Holder(s) | Realm | Arts (`--gap 0` fires) | `--gap 0` (`5` seeds) | `--gap 1` (`5` seeds) | Effects (`--gap 0` with / without / `runs`) & Targeted Probes |
|---|---|---|---|---|---|
| `lac_dan_thanh` | `ket_dan` | `brazier-form` (3.0), `flint-volley` (5.4), `furnace-heart` (5.0), `twin-flame-echo` (6.2), `pill-smoke` (2.2) | `18.9 s, 5/5, 72%` | `9.2 s, 0/5, 0%` | `Ground Like Paint` (`runs 0` default, no pill slot); `Even Failures Are Pills` (`runs 0`). **Pill probes (3 seeds):** `fail=0.0` ran `arm=3, grade=3, tick=9, echo=3, fire=3, heal=3`; `fail=1.0` also ran `fail=3`. `The Way In` (`not_run`). |
| `gia_hoi_xuan` | `ket_dan` | `seed-of-spring` (3.0), `rooted-form` (2.4), `second-spring` (0.4), `harvest-bloom` (2.4), `draw-the-poison` (3.0), `apricot-second-spring` (2.0) | `17.3 s, 5/5, 100%` | `15.2 s, 0/5, 0%` | `Second Spring`: `runs 0` at `--gap 0` (stays at `100%` HP); **`runs 5` at `--gap 1`** (`on: "wounded"`). `Apricot Clinic's Spring`: `runs 0` (`on: "always"` mod; live `Fight` probe confirmed `tick_to_heal(wood) = 50.0`). |
| `kim_van_ly` | `ket_dan` | `vault-coin-toss` (10.8), `gold-buys-the-blow` (4.6), `iron-hide-stance` (5.4) | `30.4 s, 5/5, 94%` | `16.0 s, 0/5, 0%` | `Seal of Full Payment` (`runs 0`, foreign item); `The Losing Hand` (`30.4 s 94% / 30.4 s 94%`, `runs 20`); `Lose to Win` (`30.4 s 94% / 30.4 s 89%`, `runs 37`). |
| `ve_van_co` | `ket_dan` | `the-stars-bow` (4.0), `fixed-pole` (4.0), `ring-of-the-hour` (7.0), `the-handle-turns` (6.0), `relay-the-grid` (7.0), `walking-ward` (3.0) | `17.8 s, 5/5, 97%` | `18.0 s, 0/5, 0%` | `The Twelve Hours` (`17.8 s 97% / 20.1 s 97%`, `runs 35`); `Carried Array` (`17.8 s 97% / 20.8 s 97%`, `runs 5`); `The Array Comes With Me` (`17.8 s 97% / 18.8 s 95%`, `runs 45`). |
| `tu_binh_quyen` | `ket_dan` | `balance-the-books` (9.4), `call-the-debt` (6.0) | `44.1 s, 5/5, 55%` | `12.8 s, 0/5, 0%` | `Change Expected` (`44.1 s 55% / 44.7 s 56%`, `runs 107`). **3pc probe vs cleansing-art foe (3 seeds):** `The Books Balance` `runs 25`, `call-debt-burst` `runs 15`. |
| `bao_te_hai` | `ket_dan` | `deep-lake-stance` (6.8), `gathering-wave` (4.0), `brimming-cup` (3.4), `swelling-tide-palm` (5.8) | `20.7 s, 5/5, 100%` | `16.0 s, 0/5, 0%` | `Heavy Keel` (`runs 0`, `on: "always"` mod; live `Fight` probe confirmed `composed=True`, `delay_immune=1.0`, `unmoved=1.0`); `Ride Out the Storm` (`20.7 s 100% / 21.4 s 100%`, `runs 28` / `24` at `--gap 1`). |
| `lieu_thinh_kim` | `ket_dan` | `ring-the-flaw` (11.4) | `53.4 s, 5/5, 7%` | `9.2 s, 0/5, 0%` | `Hear the Flaw` (`53.4 s 7% / 53.4 s 7%`, `runs 5`). |
| `trinh_chu_sa` | `ket_dan` | `catch-the-morning-cloud` (4.4), `painted-rain` (10.8), `paper-beam` (9.0) | `42.2 s, 5/5, 100%` | `12.0 s, 0/5, 0%` | `Paid in Advance` (`runs 0`, foreign); `Unstamped` (`42.2 s 100% / 40.0 s 100%`, `runs 131`). |
| `quan_phuc_thu` | `truc_co` | `balance-the-books` (8.6), `call-the-debt` (5.8) | `43.6 s, 5/5, 72%` | `8.4 s, 0/5, 0%` | `Paid Back` (`43.6 s 72% / 58.2 s 18%`, `runs 178`). **Synthetic 3pc probe:** `Paid in Full` `runs 3`. |
| `hoang_phu_duyen` | `truc_co` | `deep-lake-stance` (9.8), `gathering-wave` (6.0), `brimming-cup` (5.0) | `26.8 s, 5/5, 100%` | `11.6 s, 0/5, 0%` | `Know the Way Out` (`runs 0`, foreign `world-depth:thien_xu`, requires `escape_failed`). |
| `khau_phuc_linh` | `truc_co` | `seed-of-spring` (4.0), `pine-needle-rain` (6.4) | `20.4 s, 5/5, 100%` | `8.2 s, 0/5, 0%` | — |
| `phong_kinh_sa` | `truc_co` | `seven-steps` (23.6) | `50.3 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | — |
| `tang_bach_thong` | `truc_co` | `weighed-palm` (13.2) | `49.2 s, 0/5, 0%` | `8.2 s, 0/5, 0%` | — |
| `kim_tich_phuc` | `truc_co` | `ferryman-step` (11.4) | `42.6 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | — |
| `tu_thien_toan` | `luyen_khi` | `balance-the-books` (8.4), `call-the-debt` (5.8) | `45.2 s, 3/5, 10%` | `8.0 s, 0/5, 0%` | — |
| `quan_than_ngon` | `luyen_khi` | `mountain-stance` (9.6), `sinking-weight` (5.2) | `43.2 s, 3/5, 26%` | `9.0 s, 0/5, 0%` | Fixed stand-in (`mountain-heart-canon@3`, fits `thuy 42, tho 36`). |
| `trinh_hong_tien` | `luyen_khi` | `three-wet-sheets` (25.8), `blotting-paper` (5.8) | `38.3 s, 5/5, 60%` | `8.0 s, 0/5, 0%` | — |
| `tang_phan_ly`, `bi_tieu_tho` | `luyen_khi` | `weighed-palm` (11.6) | `43.6 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | — |
| `dai_song_luc`, `quan_liem_chu`, `ha_kho_sam`, `hoang_phu_chu`, `ky_minh_tien` | `luyen_khi` | `ferryman-step` (9.6) | `35.4 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | — |
| `ngu_hoa_sa` | `luyen_khi` | `seven-steps` (21.2) | `44.3 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | — |
| `dieu_thiet_tien` | `luyen_khi` | `noon-guard` (1.0) | `61.4 s, 0/5, 0%` | `9.2 s, 0/5, 0%` | — |

---

## 5. Open Items
1. **Serial merge & export (`b06`):** Run `stage6_merge.py`, `put_effects.py`, `export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, and `export_world.py`.
2. **Pre-existing cross-owner `CongPhap.usable()` OR-vs-AND mismatches (NIT #8):** `phong_kinh_sa`, `ngu_hoa_sa` (`star-pacing-primer`, `cung_tinh`), and `dieu_thiet_tien` (`dry-road-sword-primer`, `phat_y`) await the Stage 7/9 ruling already logged in `cung_tinh-checkpoint.md` (#5) and `phat_y-checkpoint.md` (#4).
3. **Stale record-pass review note (outside checkpoint write set):** `production/plans/stage6/market-folk-review.md` and `market-folk.done` still list `quan_than_ngon` under `golden-valley-ledger-canon` and pre-fix `ve_van_co` (`mountain-bone-body-art`).

CHECKPOINT DONE
