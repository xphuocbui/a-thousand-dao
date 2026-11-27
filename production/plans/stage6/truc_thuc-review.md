# Trúc Thực Viên (`truc_thuc`): Stage 6 record pass review (2026-11-27, headless/delegated job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/truc_thuc/`; nothing exported, no files touched outside allowed paths):**
- **4 techniques** (`techniques/catalogue-sect-truc_thuc.json`): the 3 depth lineage methods (`rain-on-bamboo-breath`, `flooded-field-verse`, `sixty-year-flower`), plus 1 new Yellow Metal+Earth servants' method, `furrow-iron-breath`, for the two northern-ridge ploughmen (`phi_dong_canh`, `ngo_le_thach`). `verdant-cycle-scripture` is already committed in `design/techniques/catalogue-wood.json`. Every bonus and passive on the staged techniques is new and sized to its tier (§C).
- **7 new arts** (`arts/part-sect-truc_thuc.json`): the 6 depth arts (`shoot-after-rain`, `bend-not-break`, `open-the-sluice`, `paddy-mud`, `store-the-culm`, `the-flowering`), plus `turn-the-furrow` for `furrow-iron-breath`. All 7 art ids and `furrow-iron-breath` are registered in `design/world/depth/sects/truc_thuc.techniques.json`.
- **4 Effects** (`effects/truc_thuc.effects.json`): 2 item Effects (`Warm the Grove`, `Measured Flood`) and 2 set Effects (`Forced to Seed`, `The Flood Feeds the Garden`). Every Effect self-declares all counters it reads or writes in its own `counters` array for GDScript standalone compilation (`test_every_library_effect_compiles` / `fighter_profile_loader.gd`), validates cleanly in `engine.validate`, and runs on its real holders in `sect_fight.py`.
- **6 items and 2 sets** (`items/catalogue-sect-truc_thuc.json`, `items/sets-truc_thuc.json`): depth modifiers preserved verbatim (all 28 lines run), `sources: ["npc"]`, `unique: true`, `"rarity": 4` on the grade-3 treasure `ttv-seed-warming-censer`, and the R6 `exception` mark on the 4 weapon/ward/armour pieces (`ttv-rain-measure-gourd`, `ttv-flowering-bell`, `ttv-flood-terrace-fan`, `ttv-fisher-oilskin`).
- **2 stand-ins resolved** in `truc_thuc.cast.json` and `truc_thuc.5.cast.json`: `phi_dong_canh` (`hoang_kim` 4) and `ngo_le_thach` (`hoang_kim` 3) switched to `furrow-iron-breath`. Gap report `stand_ins` is now `0`.
- **0 beasts** (`truc_thuc` has no `beasts.json`).
- **0 pending words** (all records run on existing engine words; no `pending.json` needed).
- **0 early promotions** (`cross_owner: 0`).

**Counts:**
- **Deviations:** `12` (§C–§F).
- **Decisions taken for the user:** `5` (§A).
- **Pending words:** `0`.
- **Never ran:** `0` — all 4 Effects and all 7 new arts ran and fired on their real holders at both `gap 0` and `gap 1`.

**Checks (all run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\truc_thuc`):**
- `lint_arts.py`: checked 7 arts in 1 file, **0 findings**.
- `lint_techniques.py`: checked 4 techniques, **0 findings** (`7.8 W / 8`, `15.9 W / 16`, `23.5 W / 24`, `7.8 W / 8`).
- `lint_items.py`: checked 6 items, **0 findings** (`unique 6 of 6`).
- `depth_check.py --quiet`: **findings: none**.
- `depth_gap.py --sect truc_thuc`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 28/28 runs`.
- Standalone Effect compile check: all 4 Effects validate cleanly with all read/written counters declared locally.
- `sect_fight.py truc_thuc` (`--seeds 5`, `gap 0` and `gap 1`): **0 REFUSED**, all 7 new arts fire and all 4 Effects execute on their real holders.

**Open items (for Stage 7 / user / serial step):**
- Wishlist `rb-23` (*The Culm Stores for Years*, cross-season persistent bloom storage on the character record) is a world-state feature outside Stage 6 combat records; `Store the Culm` + `The Flowering` run the in-fight cycle cleanly today.
- `ttv-seed-warming-censer` has `kind: "treasure"` (grade 3, rarity 4); note `bang_tam.md` carryover that `export_named.py` skips `kind: "treasure"` unless extended in the serial/export step.
- `ninh_truc_thuc`'s canonical build has no Fire technique art (only Wood/Water techniques), so in `sect_fight.py` he hits `Forced to Seed`'s 10 s no-Fire flowering branch (canonically faithful to his story); a Fire+Wood probe confirmed the Fire-refresh branch also runs and cuts fight time from `19.2 s` to `14.7 s`.

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **New Yellow servants' method `furrow-iron-breath` (`names: ["kim", "tho"]`) for the two ploughman stand-ins.**
   - *Choice:* Create a `truc_thuc` Yellow main method (`turn-the-furrow` at layer 1) rather than cross-promoting another sect's Metal method.
   - *Reason:* Follows `_brief-record.md` Step 5 (`truc_thuc.md` §2 & §5 explicitly state that Metal-rooted northern-ridge hands cannot enter the Wood/Water lineage and plough as servants). Both `phi_dong_canh` (`kim 44, tho 32`) and `ngo_le_thach` (`kim 46, tho 30`) match `["kim", "tho"]`, avoiding cross-owner dependencies.
2. **Self-counters `flood_sec` (`open-the-sluice`) and `culm_storing` (`store-the-culm`) instead of `s.state`.**
   - *Choice:* Track the active flood (`flood_sec`, `decay_per_pulse: 1`, 3 s base / 6 s with `Measured Flood`) and active culm storage (`culm_storing`, `decay_per_pulse: 1`, 6 s) via self-counters rather than `s.state`.
   - *Reason:* Every inner-gate holder of `flooded-field-verse` and `sixty-year-flower` (`ninh_truc_thuc`, `uy_thuong_dien`, `man_tiet_thanh`, `dao_luong_khe`) also slots `verdant-cycle-scripture`'s committed art `rooted-form` (`family-wood.json`), which toggles `s.state = "rooted"` every 6 s and reads `own.state.rooted == 1` literally. Using `s.state` on `open-the-sluice` or `store-the-culm` would break `rooted-form` and get overwritten every 6 s (Băng Tâm Lesson 2; parallels `le_tuyen`'s `open-the-cask`). By contrast, `the-flowering` intentionally uses `state: "flowered"` with `rooted-form` in its `suppress` list so flowering truly seals Wood arts (including `rooted-form`) for the rest of the fight.
3. **`bend-not-break` as a Water defensive/healing art with active `dampen_taken 33` + reactive low-HP quarter-hit heal (no new engine word).**
   - *Choice:* Author `bend-not-break` as `element: "water"`, `c_heal: 0.5`, active `dampen_taken: 33` (25 % cut) for 2.5 s, plus reactive `was_hit` (`own.hp_share <= 0.75`, 4 s cd) `heal {of: "amount", share: 0.25}`.
   - *Reason:* The engine has no pre-mitigation `% max HP` hit-size readable (`was_hit` carries raw `event.amount` post-mitigation, and typical same-realm hits rarely exceed 20 % max HP anyway). Making `bend-not-break` Water also honours `rain-on-bamboo-breath`'s Wood+Water identity so outer-gate disciples naturally trigger `shoot-after-rain` in 1v1 fights without waiting on a Water opponent.
4. **1v1 rewrite of `Warm the Grove` (`allies` -> `you`) and live `stack_dur 25` (no new word).**
   - *Choice:* Rewrite `"Wood buffs the holder lays on allies last 2 s longer, and each ally who receives one also gains 1 Fire stack of warmth that heals a little over its duration"` to apply to `you`: live `stack_dur: 25` (`element: "wood", kind: "buff"`, +2.0–2.5 s on 8–10 s Wood buffs) and on `buff_gained` (`element: "wood"`, `per_pulse: 1`): +1 Fire buff (6 s) and `+0.005` `hregen` (6 s).
   - *Reason:* Follows `DECISIONS-2026-11-26.md` (multi-ally fights postponed; records naming allies in passing are rewritten to "you"). Keeps Ninh's signature censer active and impactful on its holder (`19.2 s` vs `21.4 s` without).
5. **Non-spatial reading of `paddy-mud` ("roots their feet for 1 s") and `the-flowering` seal list.**
   - *Choice:* Map `"roots their feet for 1 s"` to `bound` (1 s) + `off_guard` (1 s) + `timer +0.5 s` (on empower while `flood_sec >= 1` or `field_up >= 1`), and map `"Wood arts are then sealed for the rest of the fight"` on `the-flowering` to a `flowered` state whose `suppress` lists the lineage and Wood catalogue arts.
   - *Reason:* Per `DECISIONS-2026-11-26.md`, Rooted is removed (replaced by `bound` + `off_guard`); `silence` clamps at 5 s (`curse_duration_max`), whereas a `suppress` state lasts the entire fight, matching Băng Tâm's `heart-in-the-jade-vessel` pattern.

---

## B. Mechanic table (Step 1)

| Record | Mechanic | Engine status | Implementation |
|---|---|---|---|
| `rain-on-bamboo-breath` / `shoot-after-rain` | After hit/healed by Water art, next Wood art faster + 1 extra Wood stack | Has | `c_art 1.5`, `buff [1, 8]`; `rain_fed` (`decay_per_pulse: 1`, set 5 on Water `art_fired`, Water `heal_restored`, or Cold `was_hit`) -> `art_speed 25 [wood]` + +1 Wood buff on next Wood `art_fired` |
| `rain-on-bamboo-breath` / `bend-not-break` | Hit taking > 1/5 health cut by 1/4 | Decision / approx | Water `c_heal 0.5`; `art_fired` -> `dampen_taken 33` (2.5 s); `was_hit` (`hp_share <= 0.75`, cd 4 s) -> `heal {of: amount, share: 0.25}` |
| `flooded-field-verse` / `open-the-sluice` | Floods Field several s: foe 1/5 slower, takes more from Wood stacks | Has | `flood_sec` (`decay_per_pulse: 1`, `add: 3`); `slowed_time` 3 stacks (`dur: 1, cap: 3` = 18 % slow); `always` `pen 80 [chaos]` |
| `flooded-field-verse` / `paddy-mud` | Against foe in flood: roots feet 1 s + 2 Water stacks | Has (non-spatial) | `c_art 1.6`, `debuff [1, 8]`; `empower` (`flood_sec >= 1` or `field_up >= 1`) -> `c_mult 1.3`, +2 Water stacks (8 s), `bound` 1 s, `off_guard` 1 s, `timer +0.5 s` |
| `sixty-year-flower` / `store-the-culm` | Stance: while using no Wood art, gain bloom layer every few s + little defense | Has | `culm_storing` (`decay_per_pulse: 1`, set 6); +1 `bloom` on cast + 1 per pulse with `fired_within.1.tag.wood == 0`; `always` `resist 45`, `dampen_taken 8` |
| `sixty-year-flower` / `the-flowering` | Once/fight: release all bloom for HP heal + foe Wood stacks; Wood arts sealed for fight | Has | `guards`: `flowered == 0`, `bloom >= 2`, (`hp_share <= 0.65` or `foe.hp_share <= 0.45` or `bloom >= 10`); scaled by `bloom`: `heal 0.06`, +3 Wood debuff (10 s), +1 Wood buff (10 s); sets `bloom = 0`, `flowered = 1`, `state: "flowered"` |
| `furrow-iron-breath` / `turn-the-furrow` | New Yellow Metal+Earth servants' method | Has | `c_art 1.8`, `kind: phys`, `buff [1, 8]` Metal |
| `Warm the Grove` (`ttv-seed-warming-censer`) | Wood buffs on allies +2 s; recipient gains 1 Fire warmth stack healing over time | Decision (1v1) | `always` `stack_dur 25 [wood, buff]`; `buff_gained [wood]` (`per_pulse: 1`) -> +1 Fire buff (6 s) + `hregen 0.005` (6 s) |
| `Measured Flood` (`ttv-rain-measure-gourd`) | Flooded ground lasts +3 s; foe leaving keeps slow 1 s | Has | `art_fired [water, field]` -> `flood_sec +3`, `flood_was_up = 1`; `pulse` (`flood_sec < 1`, `flood_was_up >= 1`) -> `slowed_time` 3 stacks (1 s), `flood_was_up = 0` |
| `Forced to Seed` (`ttv-yearly-seed` 3pc) | Fire art refreshes Wood buffs + adds 1; 10 s without Fire flowers all Wood buffs to heal and removes them | Has | `art_fired [fire]` -> `no_fire_sec = 0`, `refresh [wood, own, buff]`, +1 Wood buff (10 s); `pulse` -> `no_fire_sec +1`; `pulse` (`no_fire_sec >= 10`, `own.buff.wood >= 1`) -> `consume [wood, own, buff]` (`heal 0.03` each), `no_fire_sec = 0` |
| `The Flood Feeds the Garden` (`ttv-rain-record` 3pc) | Each s flood is up, +1 Wood buff (6 s); when flood ends, each stack heals 1 % HP | Has | `pulse` (`flood_sec >= 1` or `field_up >= 1`) -> +1 Wood buff (6 s), `flood_fed_up = 1`; `pulse` (both `< 1`, `flood_fed_up >= 1`) -> scaled by `own.buff.wood`: `heal 0.01`, then reset `flood_fed_up = 0` |

---

## C. Techniques (`catalogue-sect-truc_thuc.json`)

All bonuses and passives below are **new** (the depth proposals name none) and sized against same-tier catalogue peers.

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Abilities (unlock) | Peer & W |
|---|---|---|---|---|---|
| `rain-on-bamboo-breath` | Yellow main, Wood+Water | none | `health_regen_inc_pct` 10 `[]`, `linh_luc_regen_inc_pct` 4 `[]`, `stack_duration_pct` 6 `[moc]` | `shoot-after-rain` (1), `bend-not-break` (2) | `clear-frost-breath` / `dew-gathering-breath` (`7.8 W of 8`) |
| `flooded-field-verse` | Profound secret, Water | `linh_luc_pct` 10 | `art_speed_pct` 8 `[thuy]`, `stack_duration_pct` 12 `[thuy, debuff]`, `status_duration_pct` 10 `[curse]`, `stack_effect_pct` 10 `[moc]`, `linh_luc_regen_inc_pct` 5 `[]` | `open-the-sluice` (1), `paddy-mud` (3) | `snow-plum-sword` / `sweet-spring-wine-rite` (`15.9 W of 16`) |
| `sixty-year-flower` | Earth secret, Wood | `khi_huyet_pct` 12, `lifespan_years` 10 | `stack_effect_pct` 12 `[moc]`, `stack_duration_pct` 15 `[moc]`, `healing_pct` 10 `[]`, `health_regen_inc_pct` 15 `[]`, `defense_pct` 6 `[]` | `store-the-culm` (1), `the-flowering` (4) | `rotting-canopy-canon` (`23.5 W of 24`) |
| `furrow-iron-breath` (new) | Yellow main, Metal+Earth | none | `khi_huyet_pct` 4 `[]`, `block_rating` 6 `[]`, `health_regen_inc_pct` 10 `[]` | `turn-the-furrow` (1) | `warm-hearth-breath` / `yoke-and-axle-breath` (`7.8 W of 8`) |

**Deviations (D1–D4):**
- **D1–D3:** New tier-sized bonuses and passives added to `rain-on-bamboo-breath`, `flooded-field-verse`, and `sixty-year-flower`.
- **D4:** New Yellow Metal+Earth servants' method `furrow-iron-breath` (`turn-the-furrow`) authored for the two ridge ploughman stand-ins.

---

## D. Arts (`part-sect-truc_thuc.json`)

`lint_arts.py`: **7 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `shoot-after-rain` | For a few s after hit/healed by Water art, next Wood art faster + 1 extra Wood stack | Wood `damage`, `c_art 1.5`, `cost 0.03`, `cd 3.5`, `buff [1, 8]`; `rain_fed` (5 s) on Water `art_fired` / Water `heal_restored` / Cold `was_hit` -> `art_speed 25 [wood]` + +1 Wood buff (8 s) on next Wood `art_fired` | none (pins "few s" = 5 s, "faster" = +25 %, "extra stack" = Wood buff) |
| `bend-not-break` | Hit taking > 1/5 health cut by 1/4 | Water `ward`, `c_heal 0.5`, `cost 0.03`, `cd 5.0`; `art_fired` -> `dampen_taken 33` (2.5 s); `was_hit` (`hp_share <= 0.75`, cd 4 s) -> `heal {of: amount, share: 0.25}` | **D5:** no pre-hit `% max HP` readable; uses active 25 % dampening + reactive 25 % hit-recovery below 75 % HP; Water element feeds `shoot-after-rain` |
| `open-the-sluice` | Floods circle (Field) several s: foe 1/5 slower, takes more from Wood stacks | Water `curse`, `tags [water, cold, field]`, `cost 0.03`, `cd 7.0`, guard `flood_sec < 1`; `flood_sec +3` (6 s with `Measured Flood`); `slowed_time` 3 stacks (`dur 1, cap 3`); `always` `pen 80 [chaos]` | **D6:** counter `flood_sec` avoids stance clash with `rooted-form`; 1/5 slow = 3×6 % = 18 %; Wood stack amp = `pen 80 [chaos]` |
| `paddy-mud` | Against foe in flood: roots feet 1 s + 2 Water stacks | Water `control`, `c_art 1.6`, `cost 0.04`, `cd 5.0`, `debuff [1, 8]`; `empower` (`flood_sec >= 1` or `field_up >= 1`) -> `c_mult 1.3`, +2 Water stacks (8 s), `bound` 1 s, `off_guard` 1 s, `timer +0.5 s` | **D7:** base `c_art 1.6` + 1 Water stack before flood; non-spatial root = `bound` + `off_guard` + `0.5 s` delay |
| `store-the-culm` | Stance: while using no Wood art, gain 1 bloom every few s + little defense | Wood `utility`, `cost 0.03`, `cd 4.5`, guards `flowered == 0` & `culm_storing < 1`; `culm_storing = 6`, +1 `bloom` on cast + 1/pulse when `fired_within.1.tag.wood == 0`; `resist 45`, `dampen_taken 8` | **D8:** counter `culm_storing` avoids clashing with `rooted-form`; +1 bloom on cast ensures reliable accumulation even on pure-Wood loadouts |
| `the-flowering` | Once/fight: release all bloom -> HP heal + foe Wood stacks; Wood arts sealed for fight | Wood `heal`, `cost 0.02`, `cd 6.0`, guards `flowered == 0`, `bloom >= 2`, (`hp_share <= 0.65` or `foe.hp_share <= 0.45` or `bloom >= 10`); per `bloom`: `heal 0.06`, +3 Wood debuff (10 s), +1 Wood buff (10 s); sets `bloom = 0`, `flowered = 1`, `state: "flowered"` | **D9:** `flowered` state suppresses a fixed list of lineage & Wood catalogue arts (including `rooted-form`); guard prevents premature flowering at full HP |
| `turn-the-furrow` (new) | Servants' Metal ploughman strike | Metal `damage`, `c_art 1.8`, `kind: phys`, `cost 0.03`, `cd 3.0`, `buff [1, 8]` | part of **D4** |

---

## E. Effects (`effects/truc_thuc.effects.json`)

Every Effect declares all counters it reads or writes locally (standalone GDScript compile verified).

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Warm the Grove` (`ttv-seed-warming-censer`) | Wood buffs on allies +2 s; each ally gains 1 Fire warmth stack healing over duration | `always` `stack_dur 25 [wood, buff]`; `buff_gained [wood]` (`per_pulse: 1`) -> +1 Fire buff (6 s) + `hregen 0.005` (6 s) | **D10:** 1v1 rewrite (`allies` -> `you`, `DECISIONS-2026-11-26.md`); +2 s expressed as +25 % `stack_dur` |
| `Measured Flood` (`ttv-rain-measure-gourd`) | Flooded ground lasts +3 s; foe leaving keeps slow 1 s | `art_fired [water, field]` -> `flood_sec +3`, `flood_was_up = 1`; `pulse` (`flood_sec < 1`, `flood_was_up >= 1`) -> `slowed_time` 3 stacks (`dur 1, cap 3`), `flood_was_up = 0` | none |
| `Forced to Seed` (`ttv-yearly-seed` 3pc) | Each Fire art refreshes Wood buffs + adds 1; 10 s without Fire flowers all Wood buffs to heal once and removes them | `art_fired [fire]` -> `no_fire_sec = 0`, `refresh [wood, own, buff]`, +1 Wood buff (10 s); `pulse` -> `no_fire_sec +1`; `pulse` (`no_fire_sec >= 10`, `own.buff.wood >= 1`) -> `consume [wood, own, buff]` (`heal 0.03`/stack), `no_fire_sec = 0` | **D11:** pinned flowering heal at 3 % max HP per consumed Wood buff stack and restarts the 10 s clock |
| `The Flood Feeds the Garden` (`ttv-rain-record` 3pc) | Each s flood is up, +1 Wood buff (6 s); when flood ends, each stack heals 1 % HP | `pulse` (`flood_sec >= 1` or `field_up >= 1`) -> +1 Wood buff (6 s), `flood_fed_up = 1`; `pulse` (`flood_sec < 1`, `field_up < 1`, `flood_fed_up >= 1`) -> scaled by `own.buff.wood`: `heal 0.01`, then reset `flood_fed_up = 0` | none |

---

## F. Items and Sets (`items/catalogue-sect-truc_thuc.json`, `items/sets-truc_thuc.json`)

- **6 items**, modifiers preserved verbatim (`21.6–32.7 W`, unpriced), `sources: ["npc"]`, `unique: true`.
- **D12:** R6 `exception` on the 4 weapon/ward/armour pieces (`ttv-rain-measure-gourd`, `ttv-flowering-bell`, `ttv-flood-terrace-fan`, `ttv-fisher-oilskin`), and `"rarity": 4` added on `ttv-seed-warming-censer` (`kind: "treasure"`, grade 3) so `lint_items.py` passes with 0 findings.
- **2 sets** (`ttv-yearly-seed`, `ttv-rain-record`), 2-piece modifiers preserved verbatim, 3-piece bonuses split into `"effect"` + `"rule"`.
- `lint_items.py`: **6 items, 0 findings**.

---

## G. Stand-ins & Beasts (`truc_thuc.cast.json`, `truc_thuc.5.cast.json`)

| Person | Realm | Was | Now | Beasts |
|---|---|---|---|---|
| `phi_dong_canh` | `luyen_khi` 2 | `hoang_kim` 4 | `furrow-iron-breath` 4 | none |
| `ngo_le_thach` | `luyen_khi` 2 | `hoang_kim` 3 | `furrow-iron-breath` 3 | none |

---

## H. Holder Table & Probes (`sect_fight.py truc_thuc`, 5 seeds each at `gap 0` / `gap 1`; + 10-seed probes)

**Every staged art fires at both `gap 0` and `gap 1` (0 REFUSED).**

| Holder / Probe | Result (`gap 0` / `gap 1`) | Effect (`with / without`, runs) | Note |
|---|---|---|---|
| `ninh_truc_thuc` (KD 1) | `19.2 s 5/5 99%` / `16.0 s 0/5 0%` | **Warm the Grove**: `gap 0` `19.2 s 99%` vs `21.4 s 98%` (**30 runs**; `gap 1` **30 runs**); **Forced to Seed**: `gap 0` `19.2 s 99%` vs `17.6 s 99%` (**110 runs**; `gap 1` `16.0 s` vs `17.6 s`, **90 runs**) | `store-the-culm` 2.0×, `the-flowering` 1.0× (`gap 0`) / 0.4× (`gap 1`); `second-spring` 0.0× at `gap 0` only because HP stays > 95 % (fires 1.0× at `gap 1`). Without Fire arts, `Forced to Seed` triggers its canonical 10 s flowering trade-off; see Fire probe below. |
| `uy_thuong_dien` (KD 0) | `15.9 s 5/5 100%` / `17.6 s 0/5 0%` | **Measured Flood**: `gap 0` `15.9 s 100%` vs `15.6 s 100%` (**15 runs**); `gap 1` `17.6 s 0%` vs `23.1 s 0%` (**15 runs**); **The Flood Feeds the Garden**: `gap 0` `15.9 s 100%` vs `16.0 s 100%` (**48 runs**; `gap 1` **55 runs**) | `open-the-sluice` 2.0×, `paddy-mud` 3.0× at both gaps; 10-seed probe confirmed every sub-record runs (`extend` 20, `linger` 10, `grow` 73, `heal` 10, `reset` 10). At `gap 1`, extending the flood from 3 s to 6 s shifts the end-of-flood heal 3 s later under heavy +1-realm damage. |
| `man_tiet_thanh` (TC 2) | `14.8 s 5/5 100%` / `12.9 s 0/5 0%` | n/a | `open-the-sluice` 1.8× (`gap 0`) / 1.0× (`gap 1`), `paddy-mud` 2.8× / 1.0× |
| `dao_luong_khe` (TC 1) | `17.7 s 5/5 99%` / `13.8 s 0/5 0%` | n/a | `open-the-sluice` 2.0× (`gap 0`) / 1.0× (`gap 1`), `paddy-mud` 3.2× / 1.0× |
| `tan_tieu_duan`, `ly_bich_ba`, `yen_mach_nhi`, `pho_tong_thuc`, `dieu_lang_nhi`, `chu_thu_dien` (LK) | `59.3 s 5/5 54–55%` / `8.0 s 0/5 0%` | n/a | `shoot-after-rain` 18.0× (`gap 0`) / 2.0× (`gap 1`), `bend-not-break` 10.6× / 1.0× |
| `phi_dong_canh`, `ngo_le_thach` (LK, stand-in) | `46.2 s 2/5 1%` / `8.0 s 0/5 0%` | n/a | `turn-the-furrow` 14.0× (`gap 0`) / 2.0× (`gap 1`) |
| **Probe:** `ninh_truc_thuc` + Fire art (`probe-ember`, 10 seeds, `gap 0`) | `14.7 s 10/10 100%` vs `14.8 s 10/10 100%` without `Forced to Seed` | **Forced to Seed**: `fire` **30 runs**, `tick` **145 runs**; **Warm the Grove**: `warmth` **73 runs** | Confirms Fire-refresh branch keeps Wood buffs growing and speeds Ninh's win from `19.2 s` to `14.7 s` (`-4.5 s`). |

**Băng Tâm pilot checklist:**
- [x] Every Effect changes the fight with and without it on its real holders (and both branches of `Forced to Seed` verified), and every staged art fires at both `gap 0` and `gap 1`.
- [x] No holder slots two conflicting stances (`open-the-sluice` and `store-the-culm` use self-counters so `rooted-form` is never overwritten; `the-flowering` intentionally enters `flowered` and suppresses `rooted-form`).
- [x] Each Effect works for holders lacking optional mechanics (`Measured Flood` matches any Water field art; `The Flood Feeds the Garden` reads `flood_sec` or `field_up`; every Effect self-declares all counters it reads/writes).
- [x] Vague words ("few seconds", "faster", "extra Wood stack", "several seconds", "roots feet", "heals a little", "each heals you once") pinned in `rule` fields.
- [x] New technique bonuses and passives sized against same-tier peers (`7.8/8`, `15.9/16`, `23.5/24`, `7.8/8`) and marked new above.

---

## I. Open items

- Wishlist `rb-23` (cross-season stored bloom on the character record for `Sixty-Year Flower`) remains an out-of-fight world-state design item outside Stage 6 combat records.
- `export_named.py` support for `kind: "treasure"` items (`ttv-seed-warming-censer`) is tracked at the serial/export step (carried over from `bang_tam.md`).

REVIEW DONE
