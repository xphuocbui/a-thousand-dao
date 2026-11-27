# Stage 6 Record Pass Review — Thúy Vi Tông (`thuy_vi`)

**Date**: 2026-11-27
**Owner**: `thuy_vi`
**Status**: Staged cleanly under `design/stage6-staging/thuy_vi/`; all three linters report `0` findings (`lint_arts.py`, `lint_techniques.py`, `lint_items.py`), `engine.validate` passes (`85` Effect records, `24` counters, `4` states), `depth_gap.py --sect thuy_vi` reports `stand_ins: 0`, `unknown_ids: 0`, `engine_words: 0`, `wishes_open: 0`, and `sect_fight.py thuy_vi --seeds 20` + `--gap 1` + targeted kit simulations confirm every active art, Effect, and stand-in runs.

---

## Summary

- **Techniques staged (`catalogue-sect-thuy_vi.json`)**: `9` (`6` lineage + `3` stand-in replacements: `thanh-nang-balm-canon`, `bich-ngoc-chisel-canon`, `cliff-hearth-breath`).
- **Arts staged (`part-sect-thuy_vi.json`)**: `12` active arts across the `6` lineage techniques + `2` passive Effect entries (`the-furnace-spills-over` and `the-empty-mountains-answer`, both mapped in `thuy_vi.techniques.json` and attached as `"The Empty Mountain's Answer (Không Sơn Đáp)"` via technique `effects` under pending word `technique-effects`) + `4` existing `family-wood.json` refs (`seed-of-spring`, `second-spring`, `rooted-form`, `harvest-bloom`).
- **Effects staged (`effects/thuy_vi.effects.json`)**: `18` named Effects (`7` item fight-or-craft entries — sharing `"The Empty Mountain's Answer"` with the two passive arts — plus `"Nine Squares"` craft-only `not_run` stub + `10` set Effects).
- **Items & sets staged (`items/catalogue-sect-thuy_vi.json`, `items/sets-thuy_vi.json`)**: `28` signature items (`3` treasures at `rarity: 5`, `25` artifacts; `19` `weapon`/`body_gear`/`ward_gear` bases carry R6 `exception`; `unique: true`, `sources: ["npc"]`) and `10` sets.
- **Stand-ins cleared**: `6 -> 0` (`ngai_thanh_hao`, `la_trac_thach`, and the `4` Cliff Hall `tap_dich` servants updated across `thuy_vi.{cast,2.cast,3.cast,4.cast}.json`).
- **Beasts verified**: `ngan_ti` on `lo_da_huong` and `lao_hoang` on `uong_muc_dich` already populated cleanly.
- **Pending words (`pending.json`)**: `2` entries (`technique-effects` referencing `thien_xu/pending.json`, and `heal-overflow` for `engine.py` emitting overflow on 100%-HP heals where `got == 0`).

---

## A. Decisions Auto-Accepted

1. **Stand-ins -> 3 `thuy_vi`-staged techniques (instead of leaving placeholders or touching `hong_lo`)**:
   - `ngai_thanh_hao` (`huyen_moc`, Thanh Nang Đường healing method) -> `thanh-nang-balm-canon` (`Tier 1`, `["moc", "thuy"]`, `seed-of-spring` L1 + `second-spring` L4). Keeps Thanh Nang distinct without modifying `hong_lo`.
   - `la_trac_thach` (`dia_kim`, jade-cutter & refiner) -> `bich-ngoc-chisel-canon` (`Tier 2`, `["kim", "tho"]`, `whetstone-pass` L1, `sundering-wedge` L3, `shatter-edge-cleave` L5).
   - `dinh_lao_hoe`, `dinh_tieu_tung`, `o_ngoc_truc`, `han_son_duoc` (`hoang_kim`, Cliff Hall servants) -> `cliff-hearth-breath` (`Tier 0`, `["kim"]`, `iron-hide-stance` L1 + `whetstone-pass` L2).
2. **Staged passive arts (`d5`) via `technique-effects`**:
   - Follows the `thien_xu` precedent (`heavenly-pivot-true-canon` -> `technique-effects` in `pending.json`). `green-furnace-canon` (L8, matching `the-furnace-spills-over`) and `empty-mountain-sutra` (L6, matching `the-empty-mountains-answer`) attach `"The Empty Mountain's Answer (Không Sơn Đáp)"` in `effects`; the runtime Effect record lives in `effects/thuy_vi.effects.json` so `tv-green-moss-mirror` runs it today.
3. **Health overflow at full HP -> `heal-overflow` queued (`decision: "build"`)**:
   - `engine.py:1593` currently fires `heal_restored` (`with overflow=max(0, amount - got)`) only `if got > 0`. Heals cast at 100% HP emit nothing yet, and `event.overflow` is raw HP rather than `hp_max`-normalized. Staged Effect stores `event.overflow / 50` (approx, cap `10`) for partial overshoots today (`thieu_thanh_dai` ran it `2258` times at default gap and `680` times at `--gap 1`), and queued `heal-overflow` for full-HP ticks (`got == 0`).
4. **Coexistence of `rooted-form` and timed Haze Fields (`empty-green-wets-the-robe`, `The Green Comes Back`)**:
   - `rooted-form` (`family-wood.json`) toggles state `"rooted"`. To avoid stripping `rooted` (World-Depth Lesson 2), `empty-green-wets-the-robe` tracks its 8 s duration in counter `haze_field`, enters `"rooted-haze"` (`tags: ["field"]` + `rooted`'s exact mods) when `rooted` is up, or `"haze-field"` (`tags: ["field"]`) when no stance is up, and restores `"rooted"` when `haze_field` expires.
   - `"The Green Comes Back"` (`tv-haze-regalia` 3pc) uses counter `regalia_haze` (`6` s) without registering or setting a state because `fight.add_library_effect` loads `records` and `counters` from `combat_effects.json` / `.effects.json` but does not load `states` (`state 'regalia-field' is not defined` caught during synthetic testing).
5. **Concealment / hiding (`step-into-the-green`, `haze-on-the-path`, `no-one-is-seen`, `Lamp on the Quay`, `No Hiding on the Quay`)**:
   - No `hidden` status exists in `combat_engine.json`, and existing world-depth sects model sneaking/evasion via `decoy`, `evade`, `acc`, and `off_guard`. Used `decoy {n: 1}` + `evade` + `timer` (`by: -10.0`) on `step-into-the-green` and `no-one-is-seen`, `+18 evade` aura on `haze-on-the-path`, `+15 acc` + `off_guard` (2 s on Field rise) on `Lamp on the Quay`, and `off_guard` / `foe.evade <= 0` stacking `+8 %` Wood damage on `No Hiding on the Quay`. Logged in `approx` fields without blocking on an engine rewrite.
6. **Non-combat Effects (`Nine Squares`, pill-brewing half of `Green Fire`)**:
   - `Nine Squares` stays `not_run` (`records: []`) as a craft-only seal Effect. `Green Fire` runs its +25% `over_time` damage below 50% foe HP (`approx` notes the out-of-fight Đan Đạo +1 craft clause).

---

## B. Mechanic Classification Table

| Kind | Name / ID | Engine Word State | Implementation Summary |
| --- | --- | --- | --- |
| Tech | `seed-and-soil-primer` | `has` (+`NOT_PRICED` note) | Kept `b1` passives; added `khi_huyet_pct: 4`, `stack_duration_pct: 8 ["moc","debuff"]`. |
| Tech | `emerald-haze-canon` | `has` (+`NOT_PRICED` note) | Kept `b1` passives; added combat Wood heal/stack passives + 2 bonuses (`khi_huyet_pct`, `herb_growth_pct`). |
| Tech | `haze-walk` | `has` (+`NOT_PRICED` note) | Kept `b1` passives; added `evade_pct`, `art_speed_pct ["moc"]`, `linh_luc_regen_inc_pct` + bonus `stealth: 8`. |
| Tech | `rock-splitting-root` | `has` (+`NOT_PRICED` note) | Kept `b1` passives; added `attack_pct ["physical"]`, `defense_pct`, `khi_huyet_pct` + bonus `attack_pct: 10`. |
| Tech | `green-furnace-canon` | `has` + `technique-effects` | Added `herb_growth_pct`, `alchemy_success`, `attack_pct ["over_time"]`, `stack_effect_pct ["moc","debuff"]`, `healing_pct`, `status_resist_pct`, 2 bonuses, and L8 passive Effect. |
| Tech | `empty-mountain-sutra` | `has` + `technique-effects` | Added `linh_luc_pct`, `than_thuc_pct`, `evade_pct`, `healing_taken_pct`, `health_regen_inc_pct`, `status_resist_pct` (`31.0 W / 32`), 3 bonuses, L6 passive Effect. |
| Tech | 3 stand-ins | `has` | `thanh-nang-balm-canon` (16 W cap, +`alchemy_success`), `bich-ngoc-chisel-canon` (`22.0 / 24 W`), `cliff-hearth-breath` (`7.2 / 8 W`). |
| Art | `furrow-palm` | `has` | `debuff [1,8]` Earth + `stacks` Wood 1 for 8 s; if foe holds both Earth and Wood stacks -> `slowed_time` 1 stack 2 s. |
| Art | `empty-green-wets-the-robe` | `decision` | `haze_field` counter (`8` s) + `haze-field` / `rooted-haze` state (`tags: ["field"]`): `2.5%` HP + `2.5%` qi + 1 Wood/s; at 5+ Wood -> Earth 1 + `off_guard` 1s (`cd 2s`). |
| Art | `moss-in-the-returning-light` | `has` | `moss_bloom` (`4` s): `1.5%` HP/s; `was_hit` blooms for `3% * remaining` HP and clears counter. |
| Art | `step-into-the-green` | `decision` | `decoy {n: 1}`, `timer {next, -10.0}`, `evade +20` for `1.5` s. |
| Art | `haze-on-the-path` | `decision` | `haze_strip` (`6` s): `+18 evade` while active. |
| Art | `root-in-the-crack` | `has` | `convert {phys: 0.4}`, `debuff [2,8]`, `+2 pierce` per foe Wood stack (`tags: ["split"]`); at 6 Wood stacks lays `sundered` 4s (`cd 8s`), and if `own.state.pine` active ends `pine` into `0.8 c + 0.15*pine_hits` Physical `free_hit`. |
| Art | `pine-against-the-wind` | `has` | Stance `pine` (`tags: ["composed"]`, `dampen_taken: 25`): `was_hit` increments `pine_hits` and `pine_boost` (`+10% dmg_more` spent on `hit_landed`). |
| Art | `green-fire-eats-dead-wood` | `has` (`over_time`) | Tags `["wood", "poison", "over_time"]` (closes `over_time` scope tag). `+50%` `dmg_more` when `foe.hp_share <= 0.5`; on `broken` lays half foe Wood stacks for 6 s. |
| Art | `pill-smoke-ward` | `has` | `ward_grow 0.12 hp`, `smoke_ward` 5 s (`status_resist +50`), `cleanse {curses: 1}`, `burn_pill {stacks_per_grade: 4, for: 6}`. |
| Art | `no-one-is-seen` | `decision` | Passive `since_act >= 2` -> `+30 evade, +200 art_speed`; firing gives `decoy {n: 1}`, `timer {next, -10.0}`, `hide_win` 2 s (`+20 evade`). |
| Art | `returning-light` | `decision` | 6 s `ret_win` counts hits (`ret_hits` cap 10); next 6 s `ret_heal` heals `0.8% * ret_hits` per pulse (scale-invariant stand-in for `amount / 3`). |
| Art | `voices-on-the-empty-mountain` | `decision` | Light Earth echo (`c_art 0.7`, `0.04` cost, `7` s cd) + `fire_art {which: "last", share: 0.5}`. |
| Passive | `the-furnace-spills-over` / `the-empty-mountains-answer` | `needs word` | Mapped via `technique-effects` to Effect `"The Empty Mountain's Answer"`, paired with pending word `heal-overflow`. |
| Effect | `Brush Away the Dust` | `has` | Every `20` s when `own.distinct_statuses >= 1`: `cleanse {n: 1}`, `cleanse {curses: 1}`, `ward_grow {0.08 hp}`. |
| Effect | `The Robe Is Never Dry` | `has` | `per_fight: 1` extinguishes first Fire tick batch (`cleanse 99 fire`); `pulse` (`cd 2s`) cleanses `1` Fire stack while burning. |
| Effect | `A Seed for the Fallen` | `has` | `per_fight: 1` `down` -> `refuse_down {hp_share: 0.001}` + `seed_flower: 2` (`dampen_taken: 9900`), blooms for `heal 0.20` after `2` s. |
| Effect | `Green Fire` | `has` | `always` when `foe.hp_share < 0.5`: `dmg_more: 0.25` scoped `tags: ["over_time"]` (craft clause noted in `approx`). |
| Effect | `Nine Squares` | `not_run` | Out-of-fight craft rule (`records: []`). |
| Effect | `Lamp on the Quay` | `decision` | When `own.field_up >= 1` rises -> `off_guard` `2` s; while up -> `+15 acc`. |
| Effect | `Light on the Moss` | `has` | On `heal_restored` at `hp_share >= 0.5`, stores `event.share / 0.04` (cap 30); below `0.5` HP releases `0.01 * store` heal. |
| Effect | `The Empty Mountain's Answer` | `needs word` | Partial overflow runs via `heal_restored` (`event.overflow / 50`), decays `-10%/s`, fires `0.2 c` `elem` free hit every `3` s when foe `off_guard` / `evade <= 0` / `debuff.wood >= 5`. |
| Effect | `The Green Comes Back` | `decision` | `per_fight: 1` below `1/3` HP -> `regalia_haze` `6` s (`+3%` heal/s, `+2` foe Wood/s, `cost_red: 1.0` Wood). |
| Effect | `Field and Garden` | `has` | When HoT counter/state active on pulse -> `+1` Earth buff (8 s); at `>= 5` Earth -> `hregen_inc: 100`. |
| Effect | `Reach and Root` | `has` | Scales `status_dur +100%` (first) / `+50%` (repeat) per `3` foe Wood stacks (`tags: ["off_guard"]`), consumes up to `9` Wood stacks when `off_guard` lands. |
| Effect | `Everything at Once` | `has` | On `pill_burned`: `timer {next, -10.0}`, `far_ambition` 3 s (`healing +20`, `stack_grant +2` Wood debuff). |
| Effect | `The Pine That Does Not Move` | `has` | On `blocked` in `pine` stance -> `+1` Wood on foe; `+10% dmg_more` per Wood on `tags: ["split"]`, consumed on `root-in-the-crack` hit. |
| Effect | `The Fire Lingers` | `has` | On `batch_ended` (`wood`, `rekindled == 0`, `stacks >= 2`) -> lays `floor(stacks / 2)` Fire stacks marked `"rekindled"`. |
| Effect | `No Hiding on the Quay` | `decision` | Pulses while foe `off_guard >= 1` or `evade <= 0` accumulate `quay_focus` (cap 10) for `+8% dmg_more` per stack on next Wood art (clears on cast or evade return). |
| Effect | `What the Chest Kept` | `has` | `per_fight: 1` when `own.qi_share < 0.25`: `gain_qi 0.5`, `ward_grow 0.10 hp`. |
| Effect | `Nobody Falls` | `has` | `per_fight: 1` on `heal_restored` at `own.hp_share < 0.25`: `ward_grow 0.10 hp`. |
| Effect | `Lean Until It Breaks` | `has` | Hits on `sundered` / `exposed` foe add `1` Wood, `+1` `lean_pierce` (`pierce: 3` each, cap 20, `-1` per idle pulse), and at `10` hits grant `3` s `ignore_block`. |

---

## C. Techniques (`catalogue-sect-thuy_vi.json`)

- `lint_techniques.py`: **checked 9 techniques, 0 findings**.
- Passive W budgets: `empty-mountain-sutra` = `31.0 / 32 W`, `bich-ngoc-chisel-canon` = `22.0 / 24 W`, `cliff-hearth-breath` = `7.2 / 8 W`; the remaining 6 techniques carry `b1` unpriced craft/cultivation lines (`breakthrough_chance`, `cultivation_speed_pct`, `herb_growth_pct`, `alchemy_success`), logged as notes cleanly per `adc5978a`.
- Updated `design/world/depth/sects/thuy_vi.techniques.json` with exact art IDs on all 14 `new` entries plus the 3 stand-in technique records.

---

## D. Arts (`part-sect-thuy_vi.json`)

- `lint_arts.py`: **checked 12 arts in 1 files, 0 findings**.
- Coverage: `8` `engine`, `4` `standalone`; `10` Wood, `2` Earth; roles `utility` `4`, `heal` `2`, `stacks` `2`, `ward` `2`, `damage` `1`, `control` `1`.
- Slotting gap note: `emerald-haze-canon` (4 arts) + `green-furnace-canon` (3 active) = 7 active arts (> 6-slot cap `MAX_ARTS`), and `emerald-haze-canon` (4) + `empty-mountain-sutra` (3 active) = 7. Both unslotted arts (`pill-smoke-ward`, `voices-on-the-empty-mountain`) were verified in swapped-slot simulations below.

---

## E. Effects (`effects/thuy_vi.effects.json`) & Verification Notes

- `engine.validate`: **PASSED (`85` Effect records, `24` counters, `4` states across staged Effects and arts)**.
- Why certain Effects read `runs 0 NEVER_RAN` in default `sect_fight.py`:
  1. `Green Fire` and beast Effect `Pack Hunt` (`ngan_ti`) are pure `on: "always"` modifier Effects; `sect_fight.run` counts only `E.Fight.do` triggers. Verified `Green Fire` via controlled A/B sim on `uy_thanh_diem` (`with Green Fire: 26.70 s` vs `without: 27.00 s` over 10 seeds). Notice `sect_fight.fight_file` does not attach `beasts` yet (`lo_da_huong`'s `ngan_ti` / `uong_muc_dich`'s `lao_hoang` were checked directly on the cast files and in Stage 5's `thuy_vi.beasts.json`).
  2. `Brush Away the Dust` and `The Robe Is Never Dry` (`ngu_lam_son`): default test dummy lays neither curses nor Fire stacks. Against a custom Fire+Curse foe (`scorch-fist` + `blight-canker`, `--gap 1`, 5 seeds), both ran cleanly: `eff:The Robe Is Never Dry:first` `5`, `eff:The Robe Is Never Dry:halve` `98`, `eff:Brush Away the Dust` `15`.
  3. `Reach and Root` (`huong_van_chu`): `huong_van_chu` sits at `emerald-haze-canon` L2 (`second-spring`, `rooted-form`) + `haze-walk` and holds `tv-punt-pole` (`arts: []`, R6 exception), so she lacks an `off_guard` applicator in default slots. Pairing `huong_van_chu` with `empty-green-wets-the-robe` (10 seeds) triggered `haze-field-mire` `166` times and `eff:Reach and Root:spend` `166` times.
  4. `Everything at Once` (`kien_vien_chi`): `on: "pill_burned"` requires a prepared pill + `burn_pill`. Swapping in `pill-smoke-ward` with `pill = {"element": "wood", "grade": 2}` (10 seeds) triggered `pill-smoke-up` `30` times, `eff:Everything at Once:pill` `10` times, and `eff:Everything at Once:tick` `30` times.
  5. `Nine Squares` (`quyen_thanh_lam`): marked `not_run` (craft-only).
  6. Split full sets: `tv-haze-regalia` tested on `cu_thuy_bach` carrying all 3 pieces at `--gap 1` (10 seeds): `eff:The Green Comes Back:trigger` `8`, `eff:The Green Comes Back:tick` `44`. `tv-field-and-garden` tested on `quyen_thanh_lam` carrying all 3 pieces (10 seeds): `eff:Field and Garden:tick` `168`.
  7. Unslotted arts (10/5-seed swap checks): `ngu_lam_son` with `voices-on-the-empty-mountain` fired `8.8` times/fight (`mean 64.0 s, 5/5 wins`); `uy_thanh_diem` with `pill-smoke-ward` fired `2.5` times/fight (`pill-smoke-up: 25`, `pill-smoke-tick: 117`).

---

## F. Items and Sets (`items/catalogue-sect-thuy_vi.json`, `items/sets-thuy_vi.json`)

- `lint_items.py`: **checked 28 items, 22 bases, 9 common arts, 0 findings**.
- Treasures (`rarity: 5`): `tv-white-cloud-whisk`, `tv-founders-seed-gourd`, `tv-green-furnace`.
- R6 `exception` carried on the `19` `weapon` / `body_gear` / `ward_gear` items; the `5` `utility` / `necklace` items (`tv-green-furnace`, `tv-quay-lamp`, `tv-salt-chest-lock`, `tv-green-moss-mirror`, `tv-lone-cypress-banner`) omit `exception` and carry `modifiers` / `effects` cleanly.

---

## G. Stand-ins & Beasts

| Person | Cast file | Old -> New | Beasts verified |
| --- | --- | --- | --- |
| `ngai_thanh_hao` | `thuy_vi.2.cast.json` | `huyen_moc` -> `thanh-nang-balm-canon` | — |
| `la_trac_thach` | `thuy_vi.cast.json` | `dia_kim` -> `bich-ngoc-chisel-canon` | — |
| `dinh_lao_hoe` | `thuy_vi.3.cast.json` | `hoang_kim` -> `cliff-hearth-breath` | — |
| `dinh_tieu_tung`, `o_ngoc_truc`, `han_son_duoc` | `thuy_vi.4.cast.json` | `hoang_kim` -> `cliff-hearth-breath` | — |
| `lo_da_huong` | `thuy_vi.cast.json` | — | `["ngan_ti"]` |
| `uong_muc_dich` | `thuy_vi.2.cast.json` | — | `["lao_hoang"]` |

---

## H. Holder Table (`sect_fight.py thuy_vi --seeds 20` & `--gap 1`)

| Holder | Realm | Default (20 seeds) | `--gap 1` (20 seeds) | Key Effect Runs (Default / Gap 1) |
| --- | --- | --- | --- | --- |
| `ngu_lam_son` | `nguyen_anh` | `64.8 s, 20 wins, 85%` | `55.8 s, 4 wins, 12%` | `Brush` / `Robe`: 0/0 vs plain dummy (15/103 vs Fire+Curse) |
| `cu_thuy_bach` | `nguyen_anh` | `48.0 s, 20 wins, 100%` | `65.5 s, 16 wins, 32%` | `A Seed for the Fallen`: 0 / **30** (`21% -> 32%` hp); `The Pine That Does Not Move`: **810 / 1094** |
| `uy_thanh_diem` | `nguyen_anh` | `24.7 s, 20 wins, 100%` | `19.2 s, 0 wins, 0%` | `The Fire Lingers`: **100 / 72**; `Green Fire`: `always` (`-0.30 s` in A/B) |
| `quyen_thanh_lam` | `ket_dan` | `32.6 s, 20 wins, 100%` | `15.2 s, 0 wins, 0%` | `Nine Squares`: `not_run` (3pc tested synthetically: `168` ticks) |
| `huong_da_dang` | `ket_dan` | `64.0 s, 20 wins, 90%` | `21.9 s, 0 wins, 0%` | `Lamp on the Quay`: **210 / 38**; `No Hiding on the Quay`: **1859 / 623** |
| `diem_hai_tao` | `ket_dan` | `64.4 s, 20 wins, 88%` | `34.6 s, 0 wins, 0%` | `What the Chest Kept`: 0 / **20** (`25.9 s -> 34.6 s` survival) |
| `thieu_thanh_dai` | `ket_dan` | `62.6 s, 20 wins, 97%` | `23.6 s, 0 wins, 0%` | `Light on the Moss`: **983 / 332**; `Empty Mountain's Answer`: **2258 / 680**; `Nobody Falls`: 0 / **2** |
| `hoan_co_bach` | `ket_dan` | `36.3 s, 20 wins, 100%` | `26.3 s, 0 wins, 0%` | `Lean Until It Breaks`: **1456 / 792** (`40.4 s -> 36.3 s` default) |
| `huong_van_chu` | `truc_co` | `59.9 s, 20 wins, 97%` | `15.1 s, 0 wins, 0%` | `Reach and Root`: 0 default (166 w/ `empty-green-wets-the-robe`) |
| `kien_vien_chi` | `truc_co` | `15.5 s, 20 wins, 100%` | `14.3 s, 0 wins, 0%` | `Everything at Once`: 0 default (10 triggers w/ `pill` + `burn_pill`) |
| `ngai_thanh_hao` | `truc_co` | `37.1 s, 20 wins, 100%` | `8.6 s, 0 wins, 0%` | Stand-in `thanh-nang-balm-canon`: `seed-of-spring` 7.4/1.0, `second-spring` 1.6/0.5 |
| `la_trac_thach` | `ket_dan` | `22.7 s, 20 wins, 62%` | `8.2 s, 0 wins, 0%` | Stand-in `bich-ngoc-chisel-canon`: `whetstone-pass` 15.1/5.1, `sundering-wedge` 4.0/1.0, `shatter-edge-cleave` 2.4/0.6 |
| `dinh_lao_hoe` (`o_ngoc_truc`, `han_son_duoc`, `dinh_tieu_tung`) | `luyen_khi` | `45.9–61.1 s, 15 wins, 11–22%` | `9.0–9.4 s, 0 wins, 0%` | Stand-in `cliff-hearth-breath`: `iron-hide-stance` + `whetstone-pass` (all fire) |

---

## I. Open Items & Pending Words

- `design/stage6-staging/thuy_vi/pending.json`:
  - `technique-effects` (shared with `thien_xu/pending.json`; attaches `"The Empty Mountain's Answer (Không Sơn Đáp)"` on `green-furnace-canon` and `empty-mountain-sutra` at Stage 6 loader build).
  - `heal-overflow` (requested engine event addition in `engine.py:heal()` so 100%-HP heals where `got == 0` emit `overflow` ticks for `The Empty Mountain's Answer`).
- Cross-owner ties (`8`: `ho_lam` `phu_hau_tho` -> `seed-and-soil-primer`; `vu_an` 7 -> `haze-walk`) close automatically during Stage 6 serial merge (`stage6_merge.py`); no external files were edited here.
