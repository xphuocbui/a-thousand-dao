# Stage 6 Record Pass Review — `xuyen_lam` (Xuyên Lâm Môn)

## Summary

- **What was built:**
  - **Techniques (3):** staged in [catalogue-sect-xuyen_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/xuyen_lam/techniques/catalogue-sect-xuyen_lam.json) — `straw-sandal-step-primer` (Yellow main, new), `calm-wind-staff-canon` (Profound main, preserved from `thinh_vu` `b01` early promotion with `The Long Road` now supplied in `xuyen_lam.effects.json`), and `unheeding-rain-heart-method` (Profound secret, new).
  - **Arts (2 new active staged, 3 preserved in `design/`):** staged `lighter-than-a-horse` and `neither-wind-nor-rain` in [part-sect-xuyen_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/xuyen_lam/arts/part-sect-xuyen_lam.json); preserved `walk-slowly`, `who-is-afraid`, and `one-straw-cape` untouched in [design/arts/part-sect-xuyen_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/arts/part-sect-xuyen_lam.json). The 2 passive arts (`The Long Road` d23 and `Do Not Listen`) are staged as technique Effects (`technique-effects`).
  - **Effects (6):** staged in [xuyen_lam.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/xuyen_lam/effects/xuyen_lam.effects.json) — 2 technique passive arts (`The Long Road`, `Do Not Listen`), 2 item Effects (`Rain on the Leaves`, `Lamp on the Road`), and 2 full-set Effects (`Step Before the Strike`, `The Lamp Does Not Go Out`). All 6 declare every counter they read/write and pass standalone `engine.validate` + GDScript-equivalent counter/state checks.
  - **Items (6) & Sets (3):** staged in [catalogue-sect-xuyen_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/xuyen_lam/items/catalogue-sect-xuyen_lam.json) and [sets-xuyen_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/xuyen_lam/items/sets-xuyen_lam.json) (`sources: ["npc"]`, `unique: true`, R6 `exception` on `body_gear` pieces `xl-straw-cape` and `xl-salt-carrier-jacket`, treasure `rarity` 5/4 on `xl-bamboo-staff`/`xl-straw-cape`).
  - **Depth edits:** inserted art `"id"` fields for the 5 active arts and `"effect"`/`"unlock_layer"` metadata for the 2 passive arts in [xuyen_lam.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/xuyen_lam.techniques.json).
  - **Stand-ins / Beasts / Early promotions:** 0 stand-ins, 0 beasts, 0 outbound early promotions (`foreign/` not needed; 2 inbound references from `loose-south` `truong_da_dao` and `thinh_vu` `uc_da_diep` close on merge).
- **Deviations:** 6 logged engine/schema adaptations (detailed below).
- **Auto-accepted decisions:** 7 decisions logged with reasons.
- **Pending words:** none (0; all mechanics run on Stage 5 + Stage 6 `b01` engine words).
- **Never ran in `sect_fight.py` (with reasons):**
  - `The Long Road`: `always`-only `cost_red` mod (`sect_fight.py` counts `Fight.do()` calls only, so `always` mods report `runs 0`); verified active via `with` vs `without` deltas (`phi_thoa_y` 78 % vs 65 % HP, `lai_tiet_truong` 76 % vs 65 % HP, `ky_khinh_ma` 52.0 s / 1 win vs 44.6 s / 0 wins, `gian_dang_bo`/`dinh_van_do`/`lo_kim_tuyen` 38.4 s vs 34.4 s).
  - `Do Not Listen`: typical `sect_fight.py` foes cast no soul, song, or Charm arts; verified via targeted `PROBE_SOUL_CHARM` (`eff:Do Not Listen:soul` 145 runs, `:song` 91 runs, survival 46.6 s vs 33.0 s without).
  - `Lamp on the Road`: runs (`10` runs over 5 seeds on `phi_thoa_y`) but typical foes have 0 evade and `phi_thoa_y` slots no escape art; verified via `PROBE_LAMP_EVADE` (19/20 wins & 48.0 % HP vs 11/20 & 9.3 % without) and `PROBE_LAMP_ESCAPE` (20/20 fled & 21.8 qi spent vs 14/20 & 73.0 without).
- **Open items:**
  - `body-element-free-names` (Stage 7/9 cultivation/schema ruling, carried from `thinh_vu.reviewed`): allow `names: []` on element-free `main`/`secret` methods for R3 no-lean sects (`straw-sandal-step-primer`, `calm-wind-staff-canon`, `unheeding-rain-heart-method` currently carry lint proxy `["kim", "moc", "tho"]`).
  - Item DB base gap (pre-existing note in `xuyen_lam.items.json`): no dedicated staff base exists in `bases.json`, so `xl-bamboo-staff` sits on `loi_truong` (`utility`).

---

## Auto-Accepted Decisions (with Reasons)

1. **Preserve `b01` early-promoted `calm-wind-staff-canon` and its 3 active arts verbatim:** [design/techniques/catalogue-sect-xuyen_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/techniques/catalogue-sect-xuyen_lam.json) and [design/arts/part-sect-xuyen_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/arts/part-sect-xuyen_lam.json) already hold `calm-wind-staff-canon` (`walk-slowly`, `who-is-afraid`, `one-straw-cape`, and `The Long Road` at layer 5) from `thinh_vu` `b01`. Kept those IDs and numbers intact (staging only the updated `calm-wind-staff-canon` entry with `straw-sandal-step-primer` and `unheeding-rain-heart-method`, and staging only the 2 new arts in `part-sect-xuyen_lam.json` so `stage6_merge.py` appends cleanly by ID without duplicating).
2. **Use temporary `names: ["kim", "moc", "tho"]` lint proxy on `straw-sandal-step-primer` and `unheeding-rain-heart-method`:** `lint_techniques.py` requires 1–3 elements on `main`/`secret` techniques (`SCHEMA`), and `thinh_vu.reviewed` already moved `body-element-free-names` out of `pending.json` as a Stage 7/9 cultivation/schema ruling. Reusing `calm-wind-staff-canon`'s exact proxy keeps all 3 techniques consistent and lint-clean (`0 findings`), while all 5 active arts remain `element: ""` element-free Physical.
3. **Stage `Do Not Listen` as a layer-1 technique Effect and `neither-wind-nor-rain` as a layer-2 active ward art on `unheeding-rain-heart-method`:** `lint_techniques.py` requires every technique to carry at least 1 active art in `abilities`. `Do Not Listen` is explicitly "a passive ward", whereas `neither-wind-nor-rain` naturally serves as an active mind-guard (+35 % status resist, +15 % soul res, +25 % timer resist for 4 s, cleanse 1 curse) carrying the once-per-fight control-status shrug + guaranteed-hit staff strike. This gives `phi_thoa_y` 5 active arts (`<= MAX_ARTS = 6`) so it fires every fight in `sect_fight.py`, while `Do Not Listen` attaches to both `uc_diep_thanh` and `phi_thoa_y` regardless of active-slot count.
4. **Guard `lighter-than-a-horse` stance entry on `own.state.any == 0`:** A fighter has one stance slot (`FIGHT-INPUT.md` trap #4). Dual-technique holders (`phi_thoa_y`, `nghiem_quy_khu`, `ky_khinh_ma`) slot both `walk-slowly` and `lighter-than-a-horse`. Guarding `lighter-than-a-horse`'s Pressing stance entry on `own.state.any == 0` lets primer-only outer disciples hold a 4 s Pressing stance while never overwriting `walk-slowly` on inner/elder holders (still granting them the 4 s speed/evade/delay window and `movement` `t_move` refresh).
5. **Listen for foe art acts on `was_hit` and `evaded` (`kind: art`) as well as `pulse` (`own.foe_pressed >= 1`) on `lighter-than-a-horse`:** Probe testing on `uc_yen_vu` revealed that foes with exact integer-second cooldowns (e.g. `3.0 s` typical enemy) fire on the pulse after `pulse()` runs, making `self.t - o.t_act == 1000 ms` on the next pulse, which fails the strict `< 1000 ms` `foe_pressed` window. Sharing the `horse_trip` 1-charge gate across `was_hit`, `evaded`, and `pulse` preserves the exact "first time in that window" limit while catching every foe art.
6. **Split `Lamp on the Road` into two `fight_start` records (`:sight` and `:escape_free`):** Probe testing revealed that a second `mod` action in the same record without `stack: true` clears earlier `temp_mods` sharing that record `id` (`engine.py:1839`). Separating `acc: 20, escape: 50` from `next_art_cost: 0.0 [escape]` fixes the wipe cleanly (verified: 19/20 wins vs evasive foe, 20/20 free escapes).
7. **Author `Step Before the Strike` with 1 ms `ignore_block: 1` on `staff` `art_fired` + `return_damage {share: 0.30, dtype: "lightning"}` on `staff` `hit_landed`:** `engine.py` has no live damage-conversion mod (and `defend()` reads `ignore_block` with `ctx=None`). Using a 1 ms untagged `ignore_block: 1` on `staff` `art_fired` plus a 30 % Lightning shock on `hit_landed` keeps `walk_slowly` stacks and crits scaling cleanly without double-penalizing the Physical hit or hitting trigger-budget caps.

---

## Techniques (New Bonuses and Passives Marked)

| Technique | Tier, kind | Bonuses (new) | Passives (new, sized to tier, unpriced) | Arts (unlock layer) | Tech Effects (unlock layer) |
|---|---|---|---|---|---|
| `straw-sandal-step-primer` | Yellow (0), main | none (`bonus_count` 0) | `evade_pct` 2, `khi_huyet_pct` 4, `linh_luc_regen_inc_pct` 3, `timer_resist_pct` 10 (**new**, priced lines 7.8 W of 8 W) | `lighter-than-a-horse` (1) | none |
| `calm-wind-staff-canon` | Profound (1), main | `khi_huyet_pct` 10 (kept from `b01`) | `attack_pct` 4 `[physical]`, `defense_pct` 4, `status_resist_pct` 10, `linh_luc_regen_inc_pct` 5 (kept from `b01`, 15.2 W of 16 W) | `walk-slowly` (1), `who-is-afraid` (2), `one-straw-cape` (4) | `The Long Road` (5, passive art) |
| `unheeding-rain-heart-method` | Profound (1), secret | `than_thuc_pct` 10 (**new**) | `soul_res_pct` 12, `status_resist_pct` 15, `timer_resist_pct` 10 (**new**, priced lines 13.2 W of 16 W) | `neither-wind-nor-rain` (2) | `Do Not Listen` (1, passive art) |

---

## Depth Text vs Engine Form & Deviations (6 Deviations)

### Active Arts (`part-sect-xuyen_lam.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `lighter-than-a-horse` | A movement art: for a few seconds you are Pressing, faster and harder to hit; the first time in that window the foe acts, its next art is delayed. | `tags: [physical, movement]`, `cost_share: 0.03`, `cd: 5.0`. For 4 s: `+15 art_speed`, `+15 basic_speed`, `+10 evade`; enters Pressing state `lighter-than-a-horse` if `own.state.any == 0` (cleared when `horse_step == 0`); first foe art/act in window (`was_hit`/`evaded` `kind: art` or `pulse` `foe_pressed >= 1`) delays foe's next art by `0.5 s`. | **Deviation 1:** state entry guarded on `own.state.any == 0` so `walk-slowly` is never overwritten on dual-tech holders. |
| `walk-slowly` *(preserved from `b01`)* | A stance kept while moving: each second moving adds a stack; each raises Physical damage of next staff strike and is spent by it. Still or escape clears all. | Pressing stance `walk-slowly`; +1 `walk_slowly` (`each_for: 15 s`) per pulse Pressing; `+6 % dmg_more` per stack on next `staff` art, spent on `hit_landed`/`was_evaded`; cleared on `composed` or `escape` art. | None (preserved untouched from `b01`). |
| `who-is-afraid` *(preserved from `b01`)* | A sweeping staff strike; at 5+ Walk Slowly stacks, also cleanses one fear or slow status from the holder. | `c_art: 1.8`, `cost_share: 0.04`, `cd: 5.5`, `tags: [physical, staff]`; at `walk_slowly >= 5` on `art_fired`, cleanses 1 curse (`cleanse {curses: 1}`). | None (preserved untouched from `b01`). |
| `one-straw-cape` *(preserved from `b01`)* | A guard: for a few seconds foe fields do not touch the holder, and statuses tick at half rate. | `cost_share: 0.05`, `cd: 8.0`, `tags: [physical, ward]`; `ward_grow 10 % hp` + 4 s `dampen_taken: 25`, `status_resist: 50`, `tick_block: 50`. | Preserved untouched from `b01` (already approximated in `b01`). |
| `neither-wind-nor-rain` | Once per fight, when a status would take control of the holder, it is ignored and the holder's next staff strike cannot miss. | `role: ward`, `cost_share: 0.04`, `cd: 9.0`, `tags: [physical, ward, cleanse]`. Active cast: 4 s `+35 status_resist`, `+15 soul_res`, `+25 timer_resist` and cleanses 1 curse. Once/fight on `pulse` when `charmed`/`sleep`/`silence`/`sealed_meridian`/`bound` >= 1: cleanses 1 curse and sets `neither_wind_sure = 1`; next `staff` `art_fired` grants 1 ms `acc: 500` and clears `neither_wind_sure`. | **Deviation 2:** given active mind-guard cast to satisfy `lint_techniques` (`abilities` non-empty) and provide baseline value; control shrug runs on `pulse` (cleansing rather than pre-blocking, since `status_applied` fires on the caster, not the target). |

### Effects (`xuyen_lam.effects.json`)

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `The Long Road` (`calm-wind-staff-canon`, L5, `d23`) | While you are Pressing, your arts cost 5 % less linh lực, and a further 1 % off what remains for each Walk Slowly stack you hold. | `always` while `own.pressing >= 1`: `cost_red: 0.05` + scaled `cost_red: 0.01` per `own.counter.walk_slowly` (declares `walk_slowly` counter). | **Deviation 3:** additive `cost_red` (bounded by engine `cost_red_cap = 0.95`) instead of compounding off remaining cost; near-identical at normal stack counts. |
| `Do Not Listen` (`unheeding-rain-heart-method`, L1) | Passive ward: incoming soul damage and charm statuses are reduced; each one the ward meets raises it a little further, fading by a tenth each second nothing meets it. | `always`: `soul_res: 15`, `status_resist: 20 [status: charmed]`, plus `+5` each per `unheeding_ward` (`decay_share: 0.1`); `unheeding_ward` +1 on `soul_taken`, `was_hit [tags: song]`, or `pulse` while `own.status.charmed >= 1`. | **Deviation 4:** `decay_share: 0.1` decays 10 % every pulse including the pulse raised; charm check runs on `pulse` (no `status_taken` event on target). |
| `Rain on the Leaves` (`xl-bamboo-staff`) | While you keep Pressing, the foe's art that hits you gives you one Walk Slowly stack, as if you had walked a second longer. | `was_hit` (`filter: {kind: "art"}`) while `own.pressing >= 1`: `counter walk_slowly +1` (declares `walk_slowly` counter). | None (exact). |
| `Lamp on the Road` (`xl-guide-lamp`) | The foe cannot be unseen. Once per fight, you may leave a fight at no cost. | Two `fight_start` (`per_fight: 1`) records: `:sight` grants `acc: 20` and `escape: 50` for 300 s; `:escape_free` grants `next_art_cost: 0.0` scoped to `tags: [escape]`. | **Deviation 5:** no stealth/unseen state exists in 1v1 `fight.py`; mapped to fight-long `+20 acc`, free first escape art, and `+50 escape` chance without auto-fleeing duels lacking an escape art. |
| `Step Before the Strike` (`xl-thunder-fort`, 2pc) | Each time you evade, your next staff strike deals 30 % of its damage as Lightning and cannot be blocked. | `evaded`: sets `step_before = 1`; `art_fired [tags: staff]` while `step_before >= 1`: 1 ms `ignore_block: 1`; `hit_landed [tags: staff, kind: art]`: `return_damage {share: 0.30, dtype: "lightning"}` + clears `step_before` (also cleared on `was_evaded`). | **Deviation 6:** engine has no live `convert` mod; keeps the full unblocked staff strike and adds a 30 % Lightning shock (`return_damage`) so Walk Slowly stacks and crits scale cleanly. |
| `The Lamp Does Not Go Out` (`xl-lamp-and-road`, 2pc) | Each hit you evade keeps the lamp lit for 3 more seconds, regenerating 1 % HP/s; below 25 % HP it lights itself and regeneration doubles. | `evaded`: `lamp_lit +3` (uncapped); `pulse` (`lamp_lit >= 1` & `hp_share > 0.25`): `heal 0.01`; `pulse` (`hp_share <= 0.25`): `heal 0.02`; `pulse` (`lamp_lit >= 1`): `lamp_lit -1`. | None (exact). |

---

## Items and Sets (`catalogue-sect-xuyen_lam.json`, `sets-xuyen_lam.json`)

- **6 items** (`sources: ["npc"]`, `unique: true`, exact depth modifiers):
  - `xl-bamboo-staff` (`treasure`, `grade: 4`, `rarity: 5`, `loi_truong` utility, `Rain on the Leaves`, `uc_diep_thanh`, `xl-calm-wind-and-waves`)
  - `xl-straw-cape` (`treasure`, `grade: 3`, `rarity: 4`, `dao_bao` body_gear, R6 `exception`, `phi_thoa_y`, `xl-calm-wind-and-waves`)
  - `xl-guide-lamp` (`artifact`, `grade: 3`, `dang` utility, `Lamp on the Road`, `phi_thoa_y`, `xl-lamp-and-road`)
  - `xl-salt-carrier-jacket` (`artifact`, `grade: 3`, `giap` body_gear, R6 `exception`, `uc_diep_thanh`, `xl-thunder-fort`)
  - `xl-pass-pendant` (`artifact`, `grade: 4`, `ngoc_boi` necklace, `uc_diep_thanh`, `xl-thunder-fort`)
  - `xl-road-mother-jade` (`artifact`, `grade: 3`, `ngoc_boi` necklace, `phi_thoa_y`, `xl-lamp-and-road`)
- **3 sets:** `xl-calm-wind-and-waves` (2pc modifiers only), `xl-thunder-fort` (2pc modifiers + `Step Before the Strike`), `xl-lamp-and-road` (2pc modifiers + `The Lamp Does Not Go Out`).

---

## Pending Words

None (0 pending engine words). Two non-engine schema/catalogue items remain open for later stages:
- `body-element-free-names` (Stage 7/9 cultivation/schema ruling, carried from `thinh_vu.reviewed`).
- Staff base gap in `design/items/bases.json` (`xl-bamboo-staff` currently sits on `loi_truong`).

---

## Holder & Probe Verification Table

### Linter & Checker Summary (`DEPTH_STAGE=design/stage6-staging/xuyen_lam`)
- `lint_techniques.py`: `checked 3 techniques, 0 findings`
- `lint_arts.py`: `checked 2 arts in 1 files, 0 findings`
- `lint_items.py`: `checked 6 items, 22 bases, 9 common arts, 0 findings`
- `depth_check.py`: **0 findings in `xuyen_lam`** (only 2 transient findings in parallel lane `truc_thuc`)
- `depth_gap.py --sect xuyen_lam`: `stand_ins 0`, `beasts 0`, `unknown_ids 0`, `lines 31/31 runs`, `engine_words 0`, `wishes_open 0`, `arts_new` 3 runs / 4 staged (2 active + 2 passive)
- Standalone Effect & Art compile check: **6/6 Effects OK**, **2/2 Arts OK** (every read/written counter and set state declared on its own record)

### `sect_fight.py xuyen_lam --seeds 5` (Gap 0 & Gap 1 — 18/18 Living Cast, 0 `REFUSED`)

| Holder | Realm | Slotted arts (all fired) | Gap 0 (`mean_s`, wins, HP) | Gap 1 (`mean_s`, wins) | Effect checks (Gap 0: `with` vs `without`, runs) |
|---|---|---|---|---|---|
| `uc_diep_thanh` | `ket_dan` | `walk-slowly` (10.0), `who-is-afraid` (3.0), `one-straw-cape` (2.0), `answering-palm` (6.0), `twin-shadow-fist` (2.0), `rolling-barrage-fist` (7.8) | 16.8 s, 5/5, 95 % | 12.4 s, 0/5 | `Rain on the Leaves`: 16.8 s vs 17.2 s (**50 runs**); `Step Before the Strike`: 16.8 s vs 17.0 s (**41 runs**); `The Long Road`: 12.4 s vs 12.0 s at gap 1 (`always`); `Do Not Listen`: 0 runs vs typical foe (probe below) |
| `phi_thoa_y` | `ket_dan` | `walk-slowly` (34.0), `who-is-afraid` (10.8), `one-straw-cape` (6.4), `neither-wind-nor-rain` (6.2), `lighter-than-a-horse` (9.8) | 61.6 s, 5/5, 78 % | 13.4 s, 0/5 | `The Long Road`: 78 % vs 65 % HP (`always`); `The Lamp Does Not Go Out`: 78 % vs 60 % HP (**572 runs**); `Lamp on the Road`: **10 runs** (probes below); `Do Not Listen`: 0 runs vs typical foe (probe below) |
| `lai_tiet_truong` | `truc_co` | `walk-slowly` (15.0), `who-is-afraid` (4.6), `one-straw-cape` (2.6), `answering-palm` (8.0), `twin-shadow-fist` (2.0) | 26.9 s, 5/5, 76 % | 8.0 s, 0/5 | `The Long Road`: 26.9 s 76 % vs 28.3 s 65 % (`always`) |
| `ky_khinh_ma` | `truc_co` | `walk-slowly` (27.8), `who-is-afraid` (8.4), `one-straw-cape` (3.8), `lighter-than-a-horse` (7.8) | 52.0 s, 1/5, 3 % | 9.0 s, 0/5 | `The Long Road`: 52.0 s 3 % (1 win) vs 44.6 s 0 % (`always`) |
| `nghiem_quy_khu` | `truc_co` | `walk-slowly` (24.4), `who-is-afraid` (6.2), `one-straw-cape` (3.4), `lighter-than-a-horse` (7.8) | 44.6 s, 0/5, 0 % | 9.0 s, 0/5 | Layer 4 (`The Long Road` unlocks at L5) |
| `gian_dang_bo`, `dinh_van_do`, `lo_kim_tuyen` (3) | `truc_co` | `walk-slowly` (20.2), `who-is-afraid` (5.4), `one-straw-cape` (3.2) | 38.4 s, 0/5, 0 % | 8.0 s, 0/5 | `The Long Road`: 38.4 s vs 34.4 s (`always`) |
| 10 outer disciples (`khuc_phu_thach`, `cu_tieu_thoa`, `man_thanh_truong`, `thoi_vong_pham`, `uc_yen_vu`, `gian_tieu_dang`, `mong_thiet_lang`, `dinh_tieu_chu`, `khuong_lang_thu`, `manh_hoi_lo`) | `luyen_khi` | `lighter-than-a-horse` (8.6) | 44.9 s, 0/5, 0 % | 9.0 s, 0/5 | Primer-only Pressing stance + trip delay verified in probe below |

### Targeted Standalone Probes

| Probe | Target Coverage | Result | Observed Runs / Deltas |
|---|---|---|---|
| `PROBE_SOUL_CHARM` | `Do Not Listen` + `neither-wind-nor-rain` shrug/sure vs soul + song + Charm + 40 % evade foe (10 seeds) | 46.6 s with vs 33.0 s without `Do Not Listen` (+13.6 s) | `Do Not Listen:soul` **145**, `:song` **91**; `neither-wind-nor-rain-shrug` **1**, `-sure` **1**; `lighter-than-a-horse-trip` **32**, `-hit` **24**, `-evade` **9** |
| `PROBE_LAMP_EVADE` | `Lamp on the Road` (`+20 acc`) vs 40 % evade Kết Đan foe (20 seeds) | **19/20 wins (48.0 % HP)** with vs **11/20 wins (9.3 % HP)** without | Confirms `:sight` temp_mod stays active all fight |
| `PROBE_LAMP_ESCAPE` | `Lamp on the Road` (`next_art_cost: 0.0 [escape]` + `escape: 50`) vs Nguyên Anh foe (20 seeds) | **20/20 fled (21.8 qi spent)** with vs **14/20 fled (73.0 qi spent)** without | First escape art costs 0 linh lực and raises escape odds cleanly |
| `PROBE_CALM_WIND_SET` | Full `xl-calm-wind-and-waves` pair (`xl-bamboo-staff` + `xl-straw-cape`) on `uc_diep_thanh` (10 seeds) | **10/10 wins**, 17.4 s, 92.9 % HP | `Rain on the Leaves` **101** runs; 2pc set modifiers load cleanly |
| `PROBE_STANCE_PHI` & `PROBE_LONG_ROAD_PHI` | Stance non-overwrite & qi savings on `phi_thoa_y` (seed 1) | `end_state = walk-slowly`, `dry_at = 34.9 s` with vs `30.1 s` without `The Long Road` | `lighter-than-a-horse` (10 fires) never overwrites `walk-slowly` (34 fires) |
| `PROBE_PRIMER_ONLY` | `lighter-than-a-horse` on primer-only Luyện Khí `uc_yen_vu` (5 seeds) | 44.9 s (up from 38.0 s before art-hit trip listener) | `-enter` **39**, `-end` **35**, `-trip-hit` **34**, `-trip-evade` **4** |

REVIEW DONE
