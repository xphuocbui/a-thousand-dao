# Chức Hà Các (`chuc_ha`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/chuc_ha/` plus in-place stand-in/id updates in `design/world/depth/sects/chuc_ha.*`; nothing exported, nothing merged, no `git` run):**
- **6 techniques** (`techniques/catalogue-sect-chuc_ha.json`): the 3 lineage methods (`mulberry-leaf-breath`, `unbroken-thread-canon`, `fire-in-the-thread`) plus 3 new `chuc_ha` non-lineage methods for the 3 stand-ins (`indigo-vat-canon`, `vat-stirring-breath`, `mulberry-row-breath`). New bonuses and passives are sized to Tier 0 (`<= 8.0 W`) and Tier 1 (`<= 16.0 W`) (§C). Passive art `When the Thread Breaks` (`d37`) is wired at layer 3 on `unbroken-thread-canon.effects` (`technique-effects`).
- **10 new arts** (`arts/part-sect-chuc_ha.json`): the 6 active depth arts (`spin-a-strand`, `warm-shed`, `reel-in`, `warp-and-weft`, `burning-thread`, `fire-silk-weave`) plus 4 stand-in arts (`indigo-steep`, `mordant-fix`, `vat-rinse`, `leaf-basket-guard`).
- **4 Effects** (`effects/chuc_ha.effects.json`): 1 technique passive art (`When the Thread Breaks`), 2 item Effects (`The Thread Catches`, `Chars in a Season`), and 1 full-set Effect (`Fire Runs the Thread`). Every combat Effect declares all counters it reads or writes in its own `counters` array.
  - **Never ran (1):** `Chars in a Season` (`chc-first-weave-robe`) is marked `not_run` because reweaving each season and seasonal modifier decay are out-of-fight upkeep rules, not duel mechanics.
- **3 items and 1 set** (`items/catalogue-sect-chuc_ha.json`, `items/sets-chuc_ha.json`): verbatim depth modifiers, `sources: ["npc"]`, `unique: true`, R6 `exception` on all 3 (`cham` weapon + 2 `dao_bao` robes), and `chc-unbroken-thread` split into `effect` + `rule`.
- **3 stand-ins resolved** in `chuc_ha.cast.json`, `chuc_ha.5.cast.json`, and `chuc_ha.techniques.json`: `nhiem_thanh_lam` (`huyen_thuy` -> `indigo-vat-canon` L8), `mac_lam_y` (`hoang_thuy` -> `vat-stirring-breath` L4), `nguu_thai_diep` (`hoang_tho` -> `mulberry-row-breath` L4). **0 beasts**, **0 early foreign promotions**, **0 pending engine words**.
- **Deviations:** 5 minor implementation/interpretation refinements documented in §D–§E (all within existing engine vocabulary).

**Checks:**
- `lint_arts.py design/stage6-staging/chuc_ha/arts/part-sect-chuc_ha.json`: `checked 10 arts in 1 files, 0 findings`.
- `lint_techniques.py design/stage6-staging/chuc_ha/techniques/catalogue-sect-chuc_ha.json`: `checked 6 techniques, 0 findings`.
- `lint_items.py design/stage6-staging/chuc_ha/items/catalogue-sect-chuc_ha.json`: `checked 3 items, 22 bases, 9 common arts, 0 findings`.
- `depth_check.py --quiet`: `findings: none`.
- `depth_gap.py --sect chuc_ha`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `engine_words 0`, `wishes_open 0`, `lines 12/12 runs`.
- `sect_fight.py chuc_ha --seeds 5` at `--gap 0` and `--gap 1`: **0 `REFUSED`**, **0 `NEVER_FIRED`** across all 17 living cast holders; all 3 combat Effects run and alter fights on their holders.
- `suite_check.py` on `part-sect-chuc_ha.json`: `12` runs cleanly without errors (`mulberry-leaf-breath` x1.16/x1.27, `unbroken-thread-canon` x0.96/x0.99, `fire-in-the-thread` x0.96/x1.02, `indigo-vat-canon` x1.62/x1.43, `vat-stirring-breath` x1.10/x1.20, `mulberry-row-breath` x1.11/x1.20).
- Targeted `heavy`/`slow` foe probe on `than_van_cam`: `snaps: 12`, `recoils: 8`, `knots: 2`, `catches: 2`, `leaps_on_snap: 11`, `final_knot: 2.0`, `min_qi: 16.09`.

### Băng Tâm Pilot Checklist
- [x] Every combat Effect changes the fight with and without it on its holders (`When the Thread Breaks`, `The Thread Catches`, `Fire Runs the Thread`); `Chars in a Season` has a written `not_run` reason; every active art fires at `--gap 0` and `--gap 1`.
- [x] No holder slots two competing stances (`warp-and-weft` is the sole stance in `chuc_ha`, with `guards: [own.field_up < 1]`).
- [x] No Effect assumes an optional ward/resource the holder lacks (`When the Thread Breaks` guards `own.qi_share >= 0.04` before negative `gain_qi`).
- [x] Vague words pinned in `rule` (thread bind duration 5 s, two-thread limit, Knot bonus targets, short burn = 1 Fire stack for 3 s, Fire Runs the Thread burn hit = `c 0.03` per Wood stack).
- [x] Technique bonuses and passives sized to tier and marked as new below (§C).

---

## A. Auto-Accepted Decisions (user rule 2026-11-26), with reasons

1. **Explicit pulse-counted thread slots (`thread_t1`, `thread_t2`, `thread_ended`, `thread_snapped`) instead of `each_for` or `decay_per_pulse`.**
   - *Reason:* `each_for` charges expire silently without firing an event when a thread finishes unbroken, and `decay_per_pulse: 1` decrements before `fire_event("pulse")` (giving `N - 1` pulses). Explicit `pulse` decrement records on `reel-in` (`5 -> 4 -> 3 -> 2 -> 1 -> 0` + `thread_ended += 1`) distinguish natural expiration (tying a `thread_knot` and leaping Burn back) from early `heavy`/`slow` snapping (`thread_snapped`), while supporting up to 2 simultaneous binds (`The Thread Catches`, `off_guard` 1 s).
2. **`When the Thread Breaks` Knot bonuses triggered on `art_fired` rather than `stack_grant` mod.**
   - *Reason:* `engine.py` `add_stacks` evaluates `stack_grant` with only `{"element", "kind"}` context (no `tags` or `art_id`). Triggering `stacks` on `art_fired` filtered by `{"tags": ["thread"], "element": "wood"}` (+1 Wood per Knot) and `{"art_id": "burning-thread"}` (+2 Fire per Knot) scopes the Knot payoff strictly to thread arts (`spin-a-strand`, `reel-in`, `warp-and-weft`, `burning-thread`) rather than every Wood/Fire source.
3. **`When the Thread Breaks` (`d37`) recoil gated on `own.qi_share >= 0.04` and capped `per_pulse: 1`.**
   - *Reason:* Negative `gain_qi` does not clamp to 0 in `engine.py`, so gating on `own.qi_share >= 0.04` prevents negative linh lực, and `thread_snapped` (`per_pulse: 1`) stops a multi-hit heavy art from snapping both threads and double-recoiling in one pulse.
4. **`burning-thread` uses `empower` (bound by `thread_t1`/`thread_t2`) instead of a hard `guards` lock.**
   - *Reason:* All `chuc_ha` holders of `fire-in-the-thread` also hold `reel-in`, so in real sect fights `thread_t1`/`t2` is active when `burning-thread` fires; using `empower` (`c_mult: 1.4`, `debuff: [4, 6]`) instead of a hard guard ensures standalone `fire-in-the-thread` loadouts (`suite_check.py`) do not stall.
5. **`fire-silk-weave` given a combat Fire-ward effect (`+60` Fire resist 5 s, `5%` HP `ward_grow`, `1` Fire buff) alongside its out-of-combat lore.**
   - *Reason:* Leaving `fire-silk-weave` with no combat action would make it spend 3% linh lực for zero effect on all 4 holders (`than_van_cam`, `mau_tu_linh`, `co_chuc_viem`, `dau_hong_ti`) in `sect_fight.py`. A brief Fire-silk ward matches "wards against Fire" cleanly without using `s.state` (avoiding stance collision with `warp-and-weft`).
6. **`Chars in a Season` (`chc-first-weave-robe`) marked `not_run`.**
   - *Reason:* Reweaving each season and 25% seasonal modifier decay are between-season item upkeep rules outside single-duel combat.
7. **Three new `chuc_ha` non-lineage techniques authored for the 3 stand-ins (`indigo-vat-canon`, `vat-stirring-breath`, `mulberry-row-breath`).**
   - *Reason:* None of the 3 stand-ins (`nhiem_thanh_lam`, `mac_lam_y`, `nguu_thai_diep`) is taught Chức Hà's lineage (`khach_khanh` / `tap_dich` R2 exceptions), and their notes name Lam Điện dye-vat work / servant leaf-picking with no matching committed Water/Earth vat-dyer canon. Authoring `indigo-vat-canon` (Tier 1 Water+Wood for Kết Đan guest `nhiem_thanh_lam`), `vat-stirring-breath` (Tier 0 Water+Wood for `mac_lam_y`), and `mulberry-row-breath` (Tier 0 Earth+Water for `nguu_thai_diep`) follows Step 5 (`warm-hearth-breath` precedent) with zero cross-owner dependencies.
8. **R6 exceptions on `chc-red-cloud-shuttle`, `chc-first-weave-robe`, `chc-season-woven-robe`, all `unique: true`, `sources: ["npc"]`.**
   - *Reason:* Follows standing Băng Tâm rulings R6 and rule 20f (`cham` weapon + two `dao_bao` robes use their base's common art/ward until an authored one is ruled).

---

## B. Mechanic Table

| Record | Mechanic | Engine Form | Status |
|---|---|---|---|
| `spin-a-strand` | Light Wood thread hit + slow | `c_art: 1.3`, `debuff: [1, 6]`, `slowed_time` 2 s | Covered |
| `warm-shed` | Small heal over time | `buff: [1, 6]`, `warm_shed_ttl` 4 pulses × `heal` 2% HP | Covered |
| `reel-in` | Thread bind, slow, +0.3 s delay, 2nd bind -> no evade 1 s | `slowed_time` 3 s, `timer` +0.3 s, `thread_t1`/`t2` 5 pulses, `off_guard` 1 s | Covered |
| `warp-and-weft` | Field net of threads, blows lose force, Wood stacks | `states: ["warp-and-weft"]` (`field`, `dampen_taken: 15`), 4 pulses × 1 Wood | Covered |
| `When the Thread Breaks` | `heavy`/`slow` foe art snaps thread (-4% qi); unbroken ties Knot (+1 Wood on thread, +2 Burn on `burning-thread`) | `technique-effects` L3 on `unbroken-thread-canon`; `was_hit`/`evaded` `tags: ["heavy", "slow"]`; `art_fired` `thread_knot` scaling | Covered |
| `burning-thread` | Sets threads alight: Fire damage + Burn, stronger on bound foe | `c_art: 1.2`, `debuff: [2, 6]`, `empower` (`thread_t1 >= 1` or `thread_t2 >= 1` -> `c_mult: 1.4`, `debuff: [4, 6]`) | Covered |
| `fire-silk-weave` | Craft fire-silk cloth that wards against Fire | Combat: `resist` +60 `fire` 5 s, `ward_grow` 5% HP, `buff: [1, 8]`; seasonal craft in `rule` | Covered |
| `The Thread Catches` | Two threads at once catch fire: 2 Fire stacks + short burn | `art_fired` (`reel-in`) when `thread_t1 >= 1` & `thread_t2 >= 1` -> 2 Fire (6 s) + 1 Fire (3 s) | Covered |
| `Chars in a Season` | Must reweave each season or lose 1/4 modifiers/season | `not_run` (out-of-fight seasonal upkeep) | `not_run` |
| `Fire Runs the Thread` | Bound Wood stacks burn as Fire; on end, +1 Fire batch per 3 Wood | `pulse` `free_hit` (`c: 0.03`, `fire`, `scale: foe.debuff.wood`); `thread_ended`/`thread_snapped` `stacks` (`scale: foe.debuff.wood / 3`) | Covered |

---

## C. Techniques (`techniques/catalogue-sect-chuc_ha.json`)

All bonuses and passives below are **new** (depth records specify none), sized against Tier 0 (`8.0 W`) and Tier 1 (`16.0 W`) peers (`warm-hearth-breath`, `hundred-call-breath`, `winter-toll-canon`, `verdant-cycle-scripture`).

| Technique | Tier, Kind, Elements | Bonuses (new) | Passives (new) | W Used | Abilities / Effects |
|---|---|---|---|---:|---|
| `mulberry-leaf-breath` | 0, `main`, `moc, hoa` | none | `health_regen_inc_pct` 8 `[]`, `linh_luc_regen_inc_pct` 4 `[]`, `attack_pct` 3 `[moc]` | `7.6 / 8` | `spin-a-strand` (L1), `warm-shed` (L2) |
| `unbroken-thread-canon` | 1, `main`, `moc` | `linh_luc_pct` 12 | `stack_duration_pct` 12 `[moc, debuff]`, `stack_effect_pct` 10 `[moc, debuff]`, `status_duration_pct` 8 `[curse]`, `art_speed_pct` 6 `[moc]`, `linh_luc_regen_inc_pct` 6 `[]` | `14.5 / 16` | `reel-in` (L1), `warp-and-weft` (L2); passive `When the Thread Breaks` (L3) |
| `fire-in-the-thread` | 1, `secret`, `hoa` | `attack_pct` 10 | `attack_pct` 6 `[hoa]`, `stack_effect_pct` 12 `[hoa, debuff]`, `stack_duration_pct` 14 `[hoa, debuff]`, `resist_pct` 60 `[fire]`, `art_speed_pct` 6 `[hoa]` | `13.8 / 16` | `burning-thread` (L1), `fire-silk-weave` (L2) |
| `indigo-vat-canon` *(new stand-in)* | 1, `main`, `thuy, moc` | `linh_luc_pct` 12 | `linh_luc_regen_inc_pct` 6 `[]`, `health_regen_inc_pct` 12 `[]`, `healing_pct` 8 `[]`, `attack_pct` 4 `[cold]` | `15.1 / 16` | `indigo-steep` (L1), `mordant-fix` (L2) |
| `vat-stirring-breath` *(new stand-in)* | 0, `main`, `thuy, moc` | none | `health_regen_inc_pct` 8 `[]`, `linh_luc_regen_inc_pct` 4 `[]`, `status_resist_pct` 5 `[]` | `7.6 / 8` | `vat-rinse` (L1) |
| `mulberry-row-breath` *(new stand-in)* | 0, `main`, `tho, thuy` | none | `khi_huyet_pct` 5 `[]`, `defense_pct` 3 `[]`, `health_regen_inc_pct` 6 `[]` | `7.8 / 8` | `leaf-basket-guard` (L1) |

---

## D. Arts (`arts/part-sect-chuc_ha.json`)

| Art | Depth Text | Engine Form | Deviation |
|---|---|---|---|
| `spin-a-strand` | Light Wood hit that slows slightly for a few seconds | Wood `elem`, `c_art` 1.3, cost 0.03, cd 3.0, `debuff: [1, 6]`, `slowed_time` 2 s, tags `["wood", "thread", "quick"]` | none |
| `warm-shed` | Small heal over time on the holder | Wood `elem`, `c_art` 0.0, cost 0.03, cd 6.0, `buff: [1, 6]`, `warm_shed_ttl` 4 pulses × `heal` 2% HP | none |
| `reel-in` | Binds a foe with a thread: slowed, soonest art waits 0.3 s; 2nd bind means cannot evade 1 s | Wood `elem`, `c_art` 1.2, cost 0.04, cd 3.5, `debuff: [1, 6]`, `slowed_time` 3 s, `timer` +0.3 s, `thread_t1`/`t2` 5 pulses, `off_guard` 1 s on overlap | 5 s bind duration and 2-slot thread limit pinned explicitly |
| `warp-and-weft` | Net of threads (Field) for a few seconds: blows lose force, foe gains Wood stacks | Wood `elem`, `c_art` 0.0, cost 0.04, cd 7.0, `field` state (`dampen_taken: 15`) for 4 pulses × 1 Wood stack, guard `own.field_up < 1` | cooldown tuned to 7.0 s (4 s duration) so it fires before death at `--gap 1` |
| `burning-thread` | Sets threads alight: foe bound by a thread takes Fire damage over time and gains Fire stacks | Fire `elem`, `c_art` 1.2, cost 0.04, cd 5.0, `debuff: [2, 6]`; `empower` when bound (`c_mult: 1.4`, `debuff: [4, 6]`) | fires un-empowered when standalone (`suite_check`) instead of hard-locked behind `reel-in` |
| `fire-silk-weave` | Out of combat, a craft: weaves fire-silk cloth that wards against Fire; decays after a season | Fire `elem`, `c_art` 0.0, cost 0.03, cd 8.0, `buff: [1, 8]`, `+60` Fire resist (5 s), `ward_grow` 5% HP | given combat Fire-ward payoff alongside seasonal craft rule so slotted holders use it |
| `indigo-steep` *(new)* | n/a (stand-in) | Water `elem`, `c_art` 1.5, cost 0.04, cd 4.0, `buff: [1, 8]`, `gain_qi` 2% | new stand-in art |
| `mordant-fix` *(new)* | n/a (stand-in) | Water `elem`, `c_heal` 1.2, cost 0.05, cd 6.0, `cleanse: 1`, `buff: [1, 8]` | new stand-in art |
| `vat-rinse` *(new)* | n/a (stand-in) | Water `elem`, `c_art` 1.4, cost 0.03, cd 3.5, `buff: [1, 6]` | new stand-in art |
| `leaf-basket-guard` *(new)* | n/a (stand-in) | Earth `phys`, `c_art` 1.3, cost 0.03, cd 3.5, `buff: [1, 6]` | new stand-in art |

---

## E. Effects (`effects/chuc_ha.effects.json`)

| Effect (Host) | Depth Text | Engine Form & Declared Counters/States | Deviation |
|---|---|---|---|
| `When the Thread Breaks` (`unbroken-thread-canon` L3, `d37`) | Thread breaks on foe `heavy`/`slow` art (-4% max linh lực); unbroken ties a Knot (+1 Wood on thread arts, +2 Burn on Burning Thread) | `counters`: `thread_t1`, `thread_t2`, `thread_ended`, `thread_snapped`, `thread_knot`. `was_hit`/`evaded` (`tags: ["heavy", "slow"]`) snaps 1 thread/pulse + `-4%` `gain_qi` (when `qi_share >= 0.04`); `pulse` converts `thread_ended` to `thread_knot`; `art_fired` adds `+1` Wood on Wood `thread` arts & `+2` Fire on `burning-thread` per Knot | recoil gated `own.qi_share >= 0.04` & `per_pulse: 1`; Knot bonus on `art_fired` (since `stack_grant` lacks `tags`) |
| `The Thread Catches` (`chc-red-cloud-shuttle`) | When foe bound by two threads at once, both catch fire: 2 Fire stacks and a short burn | `counters`: `thread_t1`, `thread_t2`. `art_fired` (`reel-in`) when both `thread_t1 >= 1` & `thread_t2 >= 1` -> `2` Fire (6 s) + `1` Fire (3 s) | "short burn" pinned as `1` Fire stack for 3 s |
| `Chars in a Season` (`chc-first-weave-robe`) | Robe must be rewoven each season; unrewoven, modifiers fall by a quarter each season until ash | `not_run` (`records: []`) | out-of-fight seasonal upkeep |
| `Fire Runs the Thread` (`chc-unbroken-thread` 2pc) | While bound, each Wood stack burns as a Burn batch; when binding ends, +1 Burn batch per 3 Wood stacks | `counters`: `thread_t1`, `thread_t2`, `thread_ended`, `thread_snapped`. `pulse` while bound: `free_hit` (`c: 0.03`, `fire`, `scale: foe.debuff.wood`); on `thread_ended`/`thread_snapped`: `stacks` (`fire`, `for: 6`, `scale: foe.debuff.wood / 3`) | burning Wood stacks modelled as `c 0.03` Fire `free_hit` per Wood stack/pulse (avoids exponential Fire stack feedback) |

---

## F. Items and Sets (`items/catalogue-sect-chuc_ha.json`, `items/sets-chuc_ha.json`)

| Item / Set | Base / Pieces | Modifiers (verbatim) | W (`of Limit`) | Holder / Notes |
|---|---|---|---|---|
| `chc-red-cloud-shuttle` | `cham` (grade 3, `unique: true`, `sources: ["npc"]`) | `attack_pct` 16 `[over_time]`, `stack_duration_pct` 24 `[hoa, debuff]`, `art_speed_pct` 8 `[moc]`, `khi_huyet_pct` 8 `[]` | `23.5 / 38.4` | `than_van_cam`; `The Thread Catches`; R6 `exception` |
| `chc-first-weave-robe` | `dao_bao` (grade 2, `unique: true`, `sources: ["npc"]`) | `resist_pct` 80 `[fire]`, `khi_huyet_pct` 8 `[]`, `health_regen_inc_pct` 12 `[]` | `10.5 / 25.6` | `tang_mong_kien`; `Chars in a Season` (`not_run`); R6 `exception` |
| `chc-season-woven-robe` | `dao_bao` (grade 2, `unique: true`, `sources: ["npc"]`) | `khi_huyet_pct` 8 `[]`, `resist_pct` 100 `[fire]`, `stack_effect_pct` 14 `[moc, debuff]` | `11.0 / 25.6` | `than_van_cam`; R6 `exception` |
| `chc-unbroken-thread` (2pc) | `chc-red-cloud-shuttle`, `chc-season-woven-robe` | `attack_pct` 8 `[over_time]`, `stack_duration_pct` 10 `[moc, debuff]` | — | Full set: `Fire Runs the Thread` |

---

## G. Stand-ins and Beasts (`chuc_ha.cast.json`, `chuc_ha.5.cast.json`, `chuc_ha.techniques.json`)

| Person | Realm | File | Was | Now | Beasts |
|---|---|---|---|---|---|
| `nhiem_thanh_lam` | `ket_dan` | `chuc_ha.cast.json` | `huyen_thuy` 8 | `indigo-vat-canon` 8 | none |
| `mac_lam_y` | `luyen_khi` | `chuc_ha.5.cast.json` | `hoang_thuy` 4 | `vat-stirring-breath` 4 | none |
| `nguu_thai_diep` | `luyen_khi` | `chuc_ha.cast.json` | `hoang_tho` 4 | `mulberry-row-breath` 4 | none |

Art ids (`spin-a-strand`, `warm-shed`, `reel-in`, `warp-and-weft`, `burning-thread`, `fire-silk-weave`) and the 3 new stand-in techniques were added in place to `design/world/depth/sects/chuc_ha.techniques.json`.

---

## H. Holder Table (`sect_fight.py chuc_ha --seeds 5`, `--gap 0` and `--gap 1`; + `heavy_foe` probe)

**All 17 living cast holders ran with 0 `REFUSED` and 0 `NEVER_FIRED` at both `--gap 0` and `--gap 1`.**

| Holder (Realm) | Gap 0 (`mean_s`, `wins/5`, `hp_left`) | Gap 1 (`mean_s`, `wins/5`, `hp_left`) | Effects (`with / without`, `runs`) |
|---|---|---|---|
| `than_van_cam` (`truc_co`) | `27.0 s`, `5/5`, `78%` | `8.6 s`, `0/5`, `0%` | **When the Thread Breaks**: `27.0s 78% / 40.4s 60%` (**102 runs**, gap 1: 5 runs); **The Thread Catches**: `27.0s 78% / 28.1s 76%` (**37 runs**, gap 1: 5 runs); **Fire Runs the Thread**: `27.0s 78% / 31.4s 74%` (**155 runs**, gap 1: 30 runs) |
| `tang_mong_kien` (`truc_co`) | `49.0 s`, `5/5`, `27%` | `8.9 s`, `0/5`, `0%` | **When the Thread Breaks**: `49.0s 27% / 47.1s 0%` (**157 runs**, gap 1: 5 runs); **Chars in a Season**: `0` runs (`not_run`) |
| `co_chuc_viem` (`truc_co`) | `35.2 s`, `5/5`, `65%` | `8.3 s`, `0/5`, `0%` | **When the Thread Breaks**: `35.2s 65% / 51.6s 0%` (**132 runs**, gap 1: 5 runs) |
| `mau_tu_linh` (`truc_co`) | `35.2 s`, `5/5`, `65%` | `8.3 s`, `0/5`, `0%` | **When the Thread Breaks**: `35.2s 65% / 51.6s 0%` (**132 runs**, gap 1: 5 runs) |
| `trinh_to_am` (`truc_co`) | `49.2 s`, `4/5`, `22%` | `8.6 s`, `0/5`, `0%` | **When the Thread Breaks**: `49.2s 22% / 44.8s 0%` (**158 runs**, gap 1: 5 runs) |
| `thanh_kim_toa` (`truc_co`) | `49.2 s`, `4/5`, `22%` | `8.6 s`, `0/5`, `0%` | **When the Thread Breaks**: `49.2s 22% / 44.8s 0%` (**158 runs**, gap 1: 5 runs) |
| `nhiem_thanh_lam` (`ket_dan`) | `63.6 s`, `2/5`, `3%` | `9.6 s`, `0/5`, `0%` | `indigo-steep` (`15.6`/`1.4`), `mordant-fix` (`10.0`/`1.0`) |
| `dau_hong_ti` (`luyen_khi`) | `48.7 s`, `1/5`, `0%` | `8.3 s`, `0/5`, `0%` | all 4 arts fire (`11.2, 4.6, 5.4, 5.6` at gap 0; `2.0, 1.0, 1.0, 1.0` at gap 1); L2 so no `When the Thread Breaks` |
| `luong_kien_sinh`, `van_diep_tang`, `tich_diem_ti` (`luyen_khi`) | `40.3 s`, `0/5`, `0%` | `8.3 s`, `0/5`, `0%` | `reel-in` (`11.6`/`2.0`), `warp-and-weft` (`5.4`/`1.0`) |
| `la_tieu_tam`, `phung_tieu_toa`, `luu_cam_ho`, `quan_bo_hanh` (`luyen_khi`) | `45.2 s`, `0/5`, `0%` | `8.2 s`, `0/5`, `0%` | `spin-a-strand` (`14.0`/`2.0`), `warm-shed` (`6.8`/`1.0`) |
| `mac_lam_y` (`luyen_khi`) | `41.4 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | `vat-rinse` (`11.0`/`2.0`) |
| `nguu_thai_diep` (`luyen_khi`) | `39.4 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | `leaf-basket-guard` (`10.4`/`2.0`) |
| **Targeted `heavy_foe` probe** (`than_van_cam` vs `heavy` + `slow` foe, seed 1) | `59.0 s`, `A` wins | — | `snaps: 12`, `recoils: 8`, `knots: 2`, `catches: 2`, `leaps_on_snap: 11`, `final_knot: 2.0`, `min_qi: 16.09` |

*Note on `When the Thread Breaks` snap branch:* Against `typical` foes (whose arts carry no tags), only the unbroken Knot branch fires; the `heavy`/`slow` snap + 4% linh lực recoil branch was verified in the targeted `heavy_foe` probe above.

---

## I. Open Items
- **Serial step:** merge staged files under `design/stage6-staging/chuc_ha/` into `design/` and `assets/data/combat_effects.json`, and run `export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, and `export_world.py`.
- **Out-of-fight Effect:** `Chars in a Season` (`chc-first-weave-robe`) remains `not_run` until seasonal item upkeep/decay is implemented.
- **R6 item arts:** `chc-red-cloud-shuttle`, `chc-first-weave-robe`, and `chc-season-woven-robe` carry the R6 `exception` (base common art/ward until an authored one is ruled).

REVIEW DONE
