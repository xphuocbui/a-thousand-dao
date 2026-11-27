# Stage 6 review: Củng Tinh Quán (`cung_tinh`)

All staged files live under `design/stage6-staging/cung_tinh/` and art `"id"` entries were inserted into `design/world/depth/sects/cung_tinh.techniques.json`. Decisions are auto-accepted under the 2026-11-26 rule and logged below.

## Summary

- **Built:**
  - `techniques/catalogue-sect-cung_tinh.json`: 4 techniques (`star-pacing-primer`, `bowing-stars-canon`, `armillary-array-canon`, `star-lake-mirror`).
  - `arts/part-sect-cung_tinh.json`: 7 active new arts (`seven-steps`, `the-stars-bow`, `fixed-pole`, `ring-of-the-hour`, `the-handle-turns`, `read-the-water`, `the-star-goes-out`).
  - `items/catalogue-sect-cung_tinh.json`: 5 signature items (`ct-star-lake-mirror`, `ct-armillary-ring`, `ct-dipper-array-flag`, `ct-ecliptic-flag`, `ct-prioress-robe`).
  - `items/sets-cung_tinh.json`: 2 sets (`ct-pole-star-court`, `ct-armillary-rings`).
  - `effects/cung_tinh.effects.json`: 5 Effects (passive art `The Twelve Hours` + 2 item + 2 set Effects).
  - `design/world/depth/sects/cung_tinh.techniques.json`: `"id"` added for the 7 active arts (`The Twelve Hours` remains referenced by `"effect": "the-twelve-hours"`).
- **Deviations:** 7 small engine-form approximations/clarifications (D1–D7, detailed in §§D–E).
- **Auto-accepted decisions:** 7 (logged in §A with reasons).
- **Pending words:** 1 (`technique-effects`, reusing the batch's approved `"build"` decision for attaching passive art Effect `The Twelve Hours` on `armillary-array-canon` layer 4).
- **Never ran / out-of-fight:** the luck drop (`khi_van`) on `the-star-goes-out` is an out-of-fight encounter line (`not_run` in combat; its combat half — buff strip, `Exposed`, and Earth stacks for accuracy loss — runs in full). Every combat art fires and every Effect runs on its real holders (including `The Twelve Hours` via `tree_effects` probe).
- **Early promotions:** none (`0` stand-ins; `cung_tinh` uses only `earth-mountain-pressing-seal`, already promoted in `design/items/catalogue-earth.json`).
- **Open items:** serial step wiring for `technique-effects`, `export_named.py` support for `kind == "treasure"` (`ct-star-lake-mirror`), and `market-folk`'s 4 cross-owner references to `cung_tinh` techniques (`phong_kinh_sa`, `ngu_hoa_sa`, `ve_van_co`).

---

## A. Auto-accepted decisions (with reasons)

1. **`the-handle-turns` & `The Twelve Hours` do not call `counter {set: ...}` on `ring`:**
   - *Reason:* `Fight.charge_hours` (`engine.py`) computes hour age from `(u - each) // 5000` on `each_for` counter `ring`; overwriting the counter timestamps would collapse old hours into hour 0 and break `counter_hours >= 3`. Instead, `the-handle-turns` lays another `ring` charge + ring pulse (`summon`), refreshes foe Earth debuffs, and adds `0.3 s` `timer` delay + `stars_bow` extension; `The Twelve Hours` refreshes foe Earth debuffs and adds a fresh `12 s` ring `summon` (`cooldown: 10`).
2. **`ring-of-the-hour` uses `summon` (`c: 0.4, dtype: "phys", cd: 1.0, for: 14`) instead of a `pulse` `free_hit`:**
   - *Reason:* `Fight.pulse()` resets `s.direct_dmg = 0.0` before firing `"pulse"`, clipping `free_hit` on `pulse` to `0.25 * U_att`. Using `summon` avoids the cap, stacks naturally when two or more rings hold (`Ring Within the Ring` deals companion damage per active ring summon), and preserves `Composed` (`t_act` untouched).
3. **`the-stars-bow` and `ring-of-the-hour` share a handoff counter for the single Field slot:**
   - *Reason:* Per Băng Tâm lesson 2, holders with both `bowing-stars-canon` and `armillary-array-canon` (`tham_bac_than`, `to_tinh_nghi`, `pho_cuong_dau`, `sam_lac_thiet`, `thuong_cu_luan`, `tieu_tinh_anh`) cast both Field arts. Each art defines both `stars-bow` and `armillary-ring` (`tags: ["field"]`) and checks `own.field_up < 1` before calling `state.set`, handing off cleanly on expiry whenever the other art's timer counter (`stars_bow` / `ring`) is still `>= 1`.
4. **`fixed-pole` uses `empower` (`c_mult: 1.5` when `own.composed_time >= 3`) alongside its `always` L5 Earth & `timer_resist` passives:**
   - *Reason:* `Fight.act()` sets `s.t_act = self.t` before `hit()` for damaging arts, whereas `empower` checks `if` at `shape()` time before `t_act` resets. Putting the 3 s Composed payoff on `empower` preserves the exact "break after 3 s Composed for heavy strike" flow while `always` provides `L5 +25 [tho]` and `timer_resist +25` while `composed_time >= 3`.
5. **`the-star-goes-out` translates "dims luck (`khi_van`)" into strip + `Exposed` 4 s + 4 Earth stacks (12 s):**
   - *Reason:* `khi_van` is an out-of-fight world/event stat (`engine` `fight.py` has no `khi_van` combat modifier), while accuracy suppression via Earth debuff stacks + buff strip + `Exposed` captures the combat misfortune without inventing an unrequested word.
6. **Reused batch pending word `technique-effects` (already approved `"build"`) for `armillary-array-canon` layer 4 (`The Twelve Hours`):**
   - *Reason:* Matches `thien_xu`, `lac_ha`, `thuy_vi`, and `phuong_minh`. `armillary-array-canon` keeps `The Twelve Hours` under `effects[]` (`unlock_layer: 4, passive_art: true`), and its 4-record Effect runs cleanly in `engine.py` via `tree_effects`.
7. **`ct-star-lake-mirror` has `kind: "treasure"`, `grade: 4`, `rarity: 5`:**
   - *Reason:* `cung_tinh.items.json` already specifies `"kind": "treasure"` and `"grade": 4`. `lint_items.py` requires `rarity` in `{4, 5}` for `treasure`, so `rarity: 5` was added without changing item stats (`40.9 W of 51.2`). Note `export_named.py` currently skips non-`artifact` kinds (logged in §I).

---

## B. Pending words (`design/stage6-staging/cung_tinh/pending.json`)

| Word | Kind | Status | Used by | Spec |
|---|---|---|---|---|
| `technique-effects` | `field` | Approved `"build"` (batch precedent) | `armillary-array-canon` (`The Twelve Hours`, layer 4) | `catalogue-sect-*.json` `effects[]` holds `{name, unlock_layer, passive_art, rule}`; `export_techniques.py`, `fight.py`, and GDScript `FighterCompiler` attach named Effects from `combat_effects.json` when known at `>= unlock_layer`. |

`cung_tinh.effects.json` uses zero unbuilt combat engine words — `charge_hours` (`counter_hours`, `counter_this_hour`), `composed_time`, `field_up`, `bound`, `slowed_time`, `summon`, `refresh`, `next_art_cost`, `mirror_warded`, `dmg_more`, `ignore_taken`, and `timer` all already exist in `engine.py`.

---

## C. Techniques (`design/stage6-staging/cung_tinh/techniques/catalogue-sect-cung_tinh.json`)

All bonuses and passives marked **(new)** were added in Stage 6 and sized against committed catalogues of the same tier; only `bowing-stars-canon`'s `b7` line came from `cung_tinh.techniques.json`.

| Technique | Tier, kind | Bonuses | Passives (W vs budget) | Abilities (unlock) & Effects | Peer |
|---|---|---|---|---|---|
| `star-pacing-primer` | 0 main (`tho`, `kim`, 6 layers) | none **(new)** | `defense_pct` 4, `stack_duration_pct` 10 `[tho, debuff]`, `attack_pct` 3 `[kim]` **(all new; 8.0 W of 8)** | `seven-steps` (1) | `clear-frost-breath` |
| `armillary-array-canon` | 1 secret (`tho`, `kim`, 9 layers) | `than_thuc_pct` 8 **(new)** | `stack_duration_pct` 15 `[tho, debuff]`, `art_cost_pct` -6 `[formation]`, `attack_pct` 5 `[tho]`, `ward_efficiency_pct` 5 **(all new; 13.7 W of 16)** | `ring-of-the-hour` (1), `the-handle-turns` (2); passive Effect `The Twelve Hours` (4, d16) | `hundred-blades-canon`, `snow-plum-sword` |
| `bowing-stars-canon` | 2 main (`tho`, 12 layers) | `defense_pct` 10, `linh_luc_pct` 12 **(new)** | `stack_effect_pct` 14 `[tho, debuff]` (**depth `b7`**), `stack_duration_pct` 16 `[tho, debuff]`, `status_duration_pct` 12 `[curse]`, `linh_luc_regen_inc_pct` 10, `attack_pct` 6 `[tho]` (**4 new; 22.3 W of 24**) | `the-stars-bow` (1), `fixed-pole` (2) | `jade-vessel-ice-heart-canon`, `frost-lotus-array-canon` |
| `star-lake-mirror` | 2 secret (`tho`, `kim`, 12 layers) | `than_thuc_pct` 12, `tam_ma_resist_pct` 10 **(new)** | `evade_pct` 4, `soul_res_pct` 10, `than_thuc_pct` 4, `status_duration_pct` 10 `[curse]`, `linh_luc_regen_inc_pct` 3 **(all new; 22.6 W of 24)** | `read-the-water` (1), `the-star-goes-out` (2) | `jade-vessel-ice-heart-canon` |

---

## D. Arts (`design/stage6-staging/cung_tinh/arts/part-sect-cung_tinh.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `seven-steps` | Earth, Star-Pacing Primer layer 1: walk the dipper steps; lay a small Field (`field`) that steadies you while it is up | Earth ward (`standalone`), `c_art` 1.3, cost 0.03, cd 2.0, tags `earth, formation, stance`. Each firing adds `step_mark`; at 7+, clears `step_mark`, raises Field `seven-steps-field` for 10 s (`dampen_taken: 15`) and applies `slowed_time` 1 (3 s) | **D1:** explicit 7-step threshold & 10 s Field numbers chosen for tier 0 balance (`15%` dampen, 1 Slowed Time). |
| `the-stars-bow` | Earth, Bowing Stars layer 1: lay a Field (`field`) for 8 s; every second while Composed, foe gains 2 Earth stacks and its soonest art waits 0.3 s | Earth control (`engine`), `c_art` 0.0, cost 0.04, cd 8.0, tags `earth, formation, stance`. Sets `stars_bow = 8` and `stars-bow` Field (handing off to `armillary-ring` if `field_up == 0`); on `pulse` while `stars_bow >= 1` & `composed >= 1`: 2 Earth (10 s), `slowed_time` 1 (2 s), `timer next` 0.3 s | None |
| `fixed-pole` | Earth, Bowing Stars layer 2: stay Composed 3 s: Earth hits deal 25 % more (`L5`) & `timer_resist` +25; next strike from it breaks wait with +50 % c_art | Earth damage (`engine`), `c_art` 2.3, cost 0.04, cd 7.0, tags `earth, heavy`. `always` while `own.composed_time >= 3`: `L5` 25 `[tho]` & `timer_resist` 25; `empower` `c_mult: 1.5` when `own.composed_time >= 3` (`x1.31` of lint gated) | None (`empower` cleanly runs pre-`t_act` reset) |
| `ring-of-the-hour` | Earth, Armillary layer 1: lay a 14 s star-iron Ring array (`ring`); foe deals less damage while inside and takes ring strikes; 2nd ring doubles | Earth control (`engine`), `c_art` 0.0, cost 0.05, cd 5.0, tags `earth, formation, seal`. Adds `each_for: 14` charge `ring`, summons phys ring (`c` 0.4, cd 1.0, `for` 14), raises `armillary-ring` Field (with `stars-bow` handoff); while `ring >= 1`, `dampen_taken: 8` (`+8` at `>= 2`) | **D2:** ring strikes modeled as `summon` instead of `pulse` `free_hit` to avoid `0.25 * U_att` cap and keep `Composed`. |
| `the-handle-turns` | Earth, Armillary layer 2: turn the laid arrays by one step; refresh laid Earth durations, lay a fresh ring, delay foe's next art | Earth utility (`engine`), `c_art` 0.0, cost 0.04, cd 6.0, tags `earth, formation`. Refreshes foe `earth` debuffs, delays foe next art `0.3 s`, adds 1 `ring` (`each_for: 14`) + `summon` (`c` 0.4, cd 1.0, `for` 14), adds `+2 s` to `stars_bow` if active | **D3:** adds a fresh `ring` + summon rather than mutating existing `ring` timestamps so `charge_hours` stays intact. |
| `read-the-water` | Earth, Star-Lake Mirror layer 1: for 4 s read the foe's coming blow: evade & ward strength rise, and any blow that touches or misses you primes a sure crit | Earth ward (`engine`), `c_art` 0.0, cost 0.04, cd 8.0, tags `earth, ward`. Sets `read_water = 4`: grants `evade +20`, `ward_efficiency_pct +25`, `ward_pct +15`; on `was_hit` or `evaded` while `read_water >= 1`, sets `water_crit = 1` granting `sure_crit` for your next `art` (`crit_chance +1000` scoped `"art"`, cleared on `art_fired`) | None |
| `the-star-goes-out` | Metal, Star-Lake Mirror layer 2: dim a star over the foe: strip buffs, lay `Exposed`, lay Earth weight, and drop its fight luck (`khi_van`) | Metal curse (`engine`), `c_art` 1.9, cost 0.05, cd 9.0, tags `metal, seal, curse`. `strip` 3 buffs (`largest`), `exposed` 4 s, 2 Metal (12 s) + 4 Earth (12 s) | **D4:** out-of-fight `khi_van` drop (`not_run` in combat) represented in-fight by `Exposed` + 4 Earth accuracy-down stacks. |

---

## E. Effects (`design/stage6-staging/cung_tinh/effects/cung_tinh.effects.json`)

All 5 Effects returned `engine.validate == None` (0 errors). Note `dmg_more` uses decimal shares (`0.3` = 30%, `0.06` = 6%, `1.0` = 100%, `0.25` = 25%).

| Effect (source) | Depth / Wish text | Engine form | Deviation |
|---|---|---|---|
| `The Twelve Hours` (`armillary-array-canon`, L4, d16) | 5 s hours; rings belong to the hour laid, +30 % within own hour; at 3+ distinct hours at once, armillary turns (refreshes rings/Earth) and each hour adds +6 % dmg & 1 Slowed Time/s | `always`: `own.counter_this_hour.ring >= 1` -> `dmg_more: 0.3` (`kind: companion`); `pulse` (`cooldown: 10`) when `own.counter_hours.ring >= 3` -> `refresh` foe `earth` debuffs + `summon` (`c: 0.4, dtype: phys, cd: 1.0, for: 12`); `always` scaled by `own.counter_hours.ring` when `>= 3` -> `dmg_more: 0.06` (`kind: companion`); `pulse` when `>= 3` -> `slowed_time` 1 (2 s) | **D5:** armillary turn adds a fresh 12 s ring `summon` + Earth refresh rather than resetting existing `each_for` timestamps (pending `technique-effects` for automatic loader attach). |
| `Seen in the Water` (`ct-star-lake-mirror`) | First foe art used in the fight is seen at start and warded in full; marks foe for `The Field Turns` | `was_hit` (`filter: {kind: art}`, `limit: {per_fight: 1}`): `heal` `{share: 1.0, of: "amount", ignore_taken: true}` + `counter mirror_warded = 1` | **D6 (`approx`):** wards the first foe `art` that lands via 100 % `amount` heal instead of matching a predicted art id. |
| `Keeper of the Hours` (`ct-armillary-ring`) | Arrays last a third longer, and the first array laid in a fight costs 0 | `fight_start`: `mod {next_art_cost: 0, tags: ["formation"]}`; `art_fired ring-of-the-hour`: `summon` (`c: 0.14, dtype: phys, cd: 1.0, for: 19`); `art_fired the-stars-bow`: `counter stars_bow +3` | **D7 (`approx`):** +1/3 duration modeled as `+3 s` on `stars_bow` and a `0.14 c / 19 s` lingering ring pulse on `ring-of-the-hour` (no duration mod exists on `summon`/`each_for`). |
| `The Field Turns` (`ct-pole-star-court`, 2 pcs) | Array field up & Composed: every 4 s 1 Earth stack & foe next art waits 0.3 s; Mirror-warded foe takes double dmg from next array | `pulse` (`cooldown: 4`, `own.field_up >= 1` & `own.composed >= 1`): 1 Earth (10 s) + `timer next 0.3`; `art_fired` (`tags: ["formation"]`, `own.counter.mirror_warded >= 1`): `dmg_more: 1.0` for 6 s on `formation` + `companion`, clears `mirror_warded` | None (empowers the array art & active array summons for 6 s). |
| `Ring Within the Ring` (`ct-armillary-rings`, 3 pcs, d46) | 2nd Ring of the Hour while Field up makes a second ring; while two hold, foe is Bound and takes each ring's damage/s (+25 %) | `pulse` when `own.counter.ring >= 2`: `status {id: "bound", stacks: 1, dur: 2, side: "foe"}`; `always` when `own.counter.ring >= 2`: `dmg_more: 0.25` (`kind: "companion"`) | None (per-ring damage already fires via each `ring-of-the-hour` `summon`). |

---

## F. Items and sets (`design/stage6-staging/cung_tinh/items/`)

- **5 items** (`catalogue-sect-cung_tinh.json`), all `sources: ["npc"]`, `unique: true`, matching `cung_tinh.items.json` modifiers verbatim:
  - `ct-star-lake-mirror` (grade 4, `treasure`, `kind`: treasure, `rarity`: 5, `base: kinh`, `earth`, holder `tham_bac_than`, Effect `Seen in the Water`) — `40.9 W of 51.2`.
  - `ct-armillary-ring` (grade 3, `artifact`, `rarity`: 4, `base: nhan`, `earth`, holder `to_tinh_nghi`, Effect `Keeper of the Hours`) — `33.5 W of 38.4`.
  - `ct-dipper-array-flag` (grade 4, `artifact`, `rarity`: 5, `base: ky`, `earth`, holder `tham_bac_than`) — `27.3 W of 51.2`.
  - `ct-ecliptic-flag` (grade 3, `artifact`, `rarity`: 4, `base: ky`, `earth`, holder `to_tinh_nghi`) — `24.7 W of 38.4`.
  - `ct-prioress-robe` (grade 3, `artifact`, `rarity`: 4, `base: dao_bao`, `metal`, holder `to_tinh_nghi`, R6 `exception` mark) — `27.2 W of 38.4`.
- **2 sets** (`sets-cung_tinh.json`):
  - `ct-pole-star-court` (2 pcs: `ct-star-lake-mirror`, `ct-dipper-array-flag`) — +12% `stack_effect_pct [tho, debuff]`, +4% `than_thuc_pct`, Effect `The Field Turns`.
  - `ct-armillary-rings` (3 pcs: `ct-armillary-ring`, `ct-ecliptic-flag`, `ct-prioress-robe`) — 2 pcs: +14% `stack_duration_pct [tho, debuff]`, +4% `linh_luc_pct`; 3 pcs: Effect `Ring Within the Ring`.

---

## G. Stand-ins and beasts

- **Stand-ins:** `0` (`cung_tinh` has 0 placeholder methods in its cast).
- **Beasts:** `0`.
- **Depth art ids:** inserted `"id"` before `"new"` on the 7 active arts in `design/world/depth/sects/cung_tinh.techniques.json`; `depth_check.py --sect cung_tinh` and `depth_gap.py --sect cung_tinh` both exited `0` (`unknown_ids: 0`, `engine_words: 0`).

---

## H. Holder check (`$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\cung_tinh"`)

**Linters & validator:**
- `lint_arts.py design/stage6-staging/cung_tinh/arts/part-sect-cung_tinh.json`: `7 arts, 0 findings`.
- `lint_techniques.py design/stage6-staging/cung_tinh/techniques/catalogue-sect-cung_tinh.json`: `4 techniques, 0 findings` (`8.0/8`, `22.3/24`, `13.7/16`, `22.6/24`).
- `lint_items.py design/stage6-staging/cung_tinh/items/catalogue-sect-cung_tinh.json`: `5 items, 0 findings`.
- `engine.validate`: `None` (0 errors across all 5 Effects).

**`sect_fight.py cung_tinh` (20 seeds vs realm-matched typical opponent; `--gap 1` vs one realm up):**

| Holder | Realm | Active arts | Same realm (`mean_s`, `wins/20`, `hp_left`) | `--gap 1` (`mean_s`, `wins`, `hp_left`) | Art fires (min–max) | Notes & Effect ablations |
|---|---|---|---|---|---|---|
| `tham_bac_than` | `nguyen_anh` | `the-stars-bow, fixed-pole, read-the-water, the-star-goes-out, ring-of-the-hour, the-handle-turns` | `27.9 s`, `20/20`, `82%` | `22.1 s`, `0/20`, `0%` | `3.0–5.0` | `Seen in the Water`: with `27.9 s 82%` vs without `28.3 s 81%` (`runs 20`). `The Field Turns`: with `27.9 s 82%` vs without `28.4 s 82%` (`runs 90`). Notice `fight.to_build` also accepted `tham_bac_than`'s `light: 44` variant without error. |
| `to_tinh_nghi` | `ket_dan` | `the-stars-bow, fixed-pole, ring-of-the-hour, the-handle-turns` | `28.2 s`, `20/20`, `76%` | `15.1 s`, `0/20`, `0%` | `3.0–5.0` | `Keeper of the Hours`: with `28.2 s 76%` vs without `31.2 s 73%` (`runs 180`). `Ring Within the Ring`: with `28.2 s 76%` vs without `32.9 s 73%` (`runs 445`). |
| `pho_cuong_dau`, `sam_lac_thiet`, `thuong_cu_luan`, `tieu_tinh_anh` | `truc_co` | `the-stars-bow, fixed-pole, ring-of-the-hour, the-handle-turns` | `32.9 s`, `20/20`, `62%` | `9.0 s`, `0/20`, `0%` | `3.9–6.1` | Full dual-Field + Armillary rotation wins cleanly inside 30–60 s target. |
| `dong_tinh_ho`, `bui_thien_do` | `truc_co` | `the-stars-bow, fixed-pole` | `62.2 s`, `1/20`, `1%` | `8.3 s`, `0/20`, `0%` | `7.0–8.4` | Inner-gate defensive half only (no `armillary-array-canon` offense yet); expected low duel kill rate without array offense. |
| `trinh_tieu_dau`, `an_chieu_nguyet`, `lo_tinh_sa`, `uong_thach_linh` | `luyen_khi` | `the-stars-bow, fixed-pole` | `60.5 s`, `11/20`, `6%` | `8.1 s`, `0/20`, `0%` | `7.0–8.2` | Endurance defensive pair; both arts fire `7–8` times per fight. |
| `ngo_hoang_thao`, `vu_duong_quy`, `phan_khac_luan`, `khau_bac_hanh`, `o_do_nam`, `bo_kim_quy` | `luyen_khi` | `seven-steps` | `42.6 s`, `2/20`, `1%` | `8.0 s`, `0/20`, `0%` | `20.2` | Outer-gate Tier 0 1-art primer (`mean_s 42.6 s`, wins 2/20 with 1 art vs armed typical foe). |

**`The Twelve Hours` `tree_effects` probe (20 seeds, same realm):**
- `tham_bac_than` (`nguyen_anh`): `27.9 s 20/20 82%` -> `22.5 s 20/20 84%` (`runs 150`: `turn 20`, `slow 130`).
- `to_tinh_nghi` (`ket_dan`): `28.2 s 20/20 76%` -> `22.5 s 20/20 77%` (`runs 150`: `turn 20`, `slow 130`).
- `pho_cuong_dau` & `sam_lac_thiet` (`truc_co`): `32.9 s 20/20 62%` -> `24.7 s 20/20 67%` (`runs 195`: `turn 21`, `slow 174`).

---

## I. Open items (for the serial step / user)

1. **`technique-effects` wiring:** attach `armillary-array-canon` layer 4's `The Twelve Hours` in `export_techniques.py`, `fight.py`, and GDScript `FighterCompiler` (shared pending word already approved `"build"`).
2. **`export_named.py` `kind == "treasure"`:** `tools/design/items/export_named.py` currently skips items with `kind != "artifact"`, so `ct-star-lake-mirror` needs `export_named.py` updated during Stage 7/serial export (same open item noted on other `treasure` items).
3. **`market-folk` cross-owner refs:** 4 open `cross_owner` entries in `depth_gap.py` (`phong_kinh_sa`, `ngu_hoa_sa`, `ve_van_co`) reference `cung_tinh` techniques; those clear automatically when `cung_tinh`'s staged techniques are promoted in the serial step.
