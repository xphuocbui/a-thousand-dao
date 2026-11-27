# Lãnh Giang Phái (`lanh_giang`): Stage 6 review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged under `design/stage6-staging/lanh_giang/` plus art `"id"` inserts in `design/world/depth/sects/lanh_giang.techniques.json`; nothing exported, nothing committed):**
- **2 techniques** (`techniques/catalogue-sect-lanh_giang.json`): `ice-fish-boat-breath` (Yellow main, `thuy`, 6 layers, `7.6 W / 8`) and `lone-line-sitting-canon` (Profound main, `thuy`, 9 layers, bonus `linh_luc_pct 10`, `15.5 W / 16`). All bonuses and passives are new and sized to their tiers (§C).
- **4 new arts** (`arts/part-sect-lanh_giang.json`): `oar-stroke`, `line-through-the-ice`, `sitting-in-the-snow`, and `landing-the-fish` (adapted from `builds/authored/auth-tech.json` `e5` to existing engine words). All 4 art IDs are recorded in `design/world/depth/sects/lanh_giang.techniques.json`.
- **5 signature items and 2 sets** (`items/catalogue-sect-lanh_giang.json`, `items/sets-lanh_giang.json`): all 23 modifier lines preserved verbatim (all 23 run), `sources: ["npc"]`, `unique: true`, R6 `exception` on the 4 weapon/body-gear pieces (`lg-ice-hook`, `lg-snow-cape`, `lg-sitting-robe`, `lg-old-sitter-gourd`), and full-set bonuses split into `effect` + `rule`.
- **3 Effects** (`effects/lanh_giang.effects.json`): `A Bite on the Line` (`lg-ice-hook`), `The Line Is Patient` (`lg-lone-line` 2pc), and `Answers Twice` (`lg-heap-of-snow` 3pc). Every Effect declares in its own `counters` array every counter it reads or writes (`ice_line`, `patient_sec`, `patient_sure`, `answers_twice_ready`) for standalone GDScript compilation (`STANDALONE_VALIDATE_OK: 3`).
- **Stand-ins (`0`), beasts (`0`), early promotions (`0`):** `depth_gap.py --sect lanh_giang` shows `0` stand-ins, `0` beasts, `0` cross-owner references, `0` unknown IDs, `0` unmapped/over-cap ties, `23/23` running modifier lines.
- **Deviations (`5`) & Decisions taken for the user (`5`):** logged in §A and §§C–E.
- **Pending words (`0`):** no `pending.json` needed (`landing-the-fish` and all 3 Effects express their full intent cleanly with existing engine words).
- **Never ran (`0`):** every art fires and every Effect runs and changes fights on its real holders (`sect_fight.py` at `--gap 0` and `--gap 1`, plus 10- and 20-seed probes).
- **Open items:**
  - Serial merge & export (`stage6_merge.py`, `export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, `export_world.py`) to move staged files into `design/` and `assets/data/`, close the 2 techniques, 4 arts, 5 items, 2 sets, 3 Effects, and 3 structured `events` (`N-lanh_giang-01..03`).

---

## A. Auto-accepted decisions (user rule 2026-11-26), with reasons

1. **Adapt `landing-the-fish` (`e5` in `auth-tech.json`) to existing engine words (`qi_drained` -> `catch` count, `scale` + `free_hit.c`) instead of deferring to `pending.json`:**
   - *Choice:* Bank `1` `catch` per `qi_drained` event (where `burn_qi` drained `> 0` linh lực), and spend all `catch` on `hit_landed` (`landing-the-fish`) via `scale {read: "own.counter.catch", per: 1}` as `free_hit {c: 0.35, dtype: "elem", outside_budget: true}` (`0.70` when `foe.qi_share < 0.2`), instead of `auth-tech.json` `e5`'s unbuilt `counter.add_amount`, `free_hit.amount`, and `qi_drained.source` filter.
   - *Reason:* Follows `_brief-record.md`: *"Prefer an existing word whenever it keeps the intent... A new word must be worth it for builds."* `qi_drained` in both engines (`engine.py:2072`, `effect_runner.gd:485`) emits only `{"amount": got}` (no `source`), `counter` has no `add_amount`, and `free_hit` requires `c` (not `amount`). Using `qi_drained` -> `+1` `catch` with `c: 0.35` / `0.70` (`outside_budget: true`) preserves realm-invariant scaling (unlike raw `U`-scaled points multiplied by `c`, which would scale as `U^2`), scales with the caster's Water/Cold build stats, stops banking if the foe runs out of linh lực, and lets `lu_doc_dieu`, `bo_toa_tuyet`, and `man_tinh_ba` run the full drain-and-pull loop in both engines today.
2. **Use `ice_line` (`cap: 1, each_for: 6.0`) with `set: 0` + `add: 1` on `line-through-the-ice` and `A Bite on the Line`:**
   - *Choice:* Track the 6 s tether with a 1-charge `each_for: 6.0` counter refreshed via `[{"counter": {"id": "ice_line", "set": 0}}, {"counter": {"id": "ice_line", "add": 1}}]` rather than a `pulse` decrement counter.
   - *Reason:* Avoids the `pulse` ordering bug where an art Effect decrementing `ice_line` from `1 -> 0` on pulse 6 would cause the later item Effect `A Bite on the Line` to see `ice_line == 0` and miss its 6th pulse. Both `engine.py` and `effect_runner.gd` handle `each_for` expiry identically and both `line-through-the-ice` and `A Bite on the Line` declare the exact same `ice_line` counter definition.
3. **Keep `sitting-in-the-snow` up for the fight (`guards: own.state.sitting-in-the-snow < 1`) and put its Cold reduction in an `always` Effect (`dampen_taken: 20, dtype: "cold"`):**
   - *Choice:* Make `sitting-in-the-snow` a permanent Composed stance (`tags: ["composed"]`, `mods: {"regen": 0.025}`) entered once on cast, with `sitting-cold-ward` (`on: "always"`, `dampen_taken: 20, dtype: "cold"`).
   - *Reason:* Neither `undertow-litany` nor `returning-wake-verse` (the sect's aux techniques) defines any `states`, so `sitting-in-the-snow` has zero stance conflicts on any holder. Staying in the stance prevents toggling out every 4 s (which would interrupt `A Bite on the Line`, `The Line Is Patient`, and `Answers Twice`). Putting `dtype: "cold"` in `state.mods` is refused by `engine.validate`, so `on: "always"` scopes `dampen_taken` cleanly to Cold damage.
4. **`The Line Is Patient` models half linh lực leech as `leech_hp: 3` while sitting and grants `acc: 500` on `art_fired [hook]`:**
   - *Choice:* Use `on: "always"` (`own.state.sitting-in-the-snow >= 1`) -> `mod: {"leech_hp": 3}`, plus a 5-pulse sitting counter `patient_sec -> patient_sure` spent on `art_fired` (`filter: {"tags": ["hook"]}`) as `mod: {"acc": 500}` (`1 ms` window).
   - *Reason:* The engine has no `own.leech_qi` readable; `3 %` is exact half of Lư Độc Điếu's `6 %` `leech_linh_luc_pct` (`lg-ice-hook` 4 + `lg-lone-line` 2). Because `engine.py:1285` evaluates `acc` with `ctx = None`, keeping `+500 acc` in a `1 ms` window on `art_fired [hook]` (matching `where-the-drop-falls`) makes the next hook art (`line-through-the-ice` or `landing-the-fish`, including `landing-the-fish`'s `hit_landed` Catch burst) un-evadable without leaking `+500 acc` to basic attacks.
5. **`Answers Twice` grows a stance ward via `ward_grow {share: 0.02, of: "hp"}` while sitting and triggers `fire_art {which: "last", share: 1.0}` on `art_fired` (`tags: ["counter", "seal"]`):**
   - *Choice:* Create/grow `sward` with `of: "hp"` (2% max HP/s) while `own.state.sitting-in-the-snow >= 1`, set `answers_twice_ready = 1` on `shield_broken`, and double-fire the next `counter`- or `seal`-tagged art.
   - *Reason:* Bồ Tọa Tuyết's kit has no art that creates a stance ward, so `of: "peak"` would remain `0` forever; `of: "hp"` creates and grows `sward` cleanly (Băng Tâm Lesson 3). No library art carries the `"counter"` tag, while Bồ's aux art `backwash-seal` (`returning-wake-verse`: *"makes the water answer twice"*; Bồ's Đạo Đồ note: *"the Mirror Lake's counter: a reply that answers twice"*) carries `"seal"`. Matching `tags: ["counter", "seal"]` fires `backwash-seal` twice reliably (`21/21` at gap 0, `70/70` at gap 1) without wasting the proc on a `line-through-the-ice` tether.

---

## B. Pending words

None (`0` pending words; no `pending.json`).

---

## C. Techniques (`design/stage6-staging/lanh_giang/techniques/catalogue-sect-lanh_giang.json`)

All bonuses and passives below are **new** (depth proposals name none), sized against Tier 0 (`8.0 W`: `clear-frost-breath`, `warm-hearth-breath`) and Tier 1 (`16.0 W`: `undertow-litany`, `snow-plum-sword`) peers.

| Technique | Tier, kind, elements | Bonuses (new) | Passives (new, unpriced) | W Used | Abilities (unlock layer) |
|---|---|---|---|---:|---|
| `ice-fish-boat-breath` | 0, `main`, `thuy`, 6 layers | none (`bonus_count 0`) | `linh_luc_regen_inc_pct` 5 `[]`, `attack_pct` 3 `[cold]`, `art_speed_pct` 4 `[cold]` | `7.6 / 8` | `oar-stroke` (1) |
| `lone-line-sitting-canon` | 1, `main`, `thuy`, 9 layers | `linh_luc_pct` 10 | `linh_luc_regen_inc_pct` 8 `[]`, `ward_efficiency_pct` 4 `[]`, `attack_pct` 4 `[thuy]`, `art_speed_pct` 6 `[thuy]` | `15.5 / 16` | `line-through-the-ice` (1), `sitting-in-the-snow` (2), `landing-the-fish` (6) |

---

## D. Arts (`design/stage6-staging/lanh_giang/arts/part-sect-lanh_giang.json`)

| Art (technique, layer) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `oar-stroke` (`ice-fish-boat-breath`, L1) | A sweeping Water blow that makes the foe's soonest art wait 0.3 s and restores a little linh lực to the holder. | Water `elem` (`c_art 1.4`, cost `0.03`, cd `3.0`, `qi_restore 0.05`, tags `["water", "cold", "quick"]`): `hit_landed` (`per_pulse: 1`) -> `timer {side: "foe", which: "next", by: 0.3}`. | Pinned `qi_restore` to `0.05` (5% max linh lực). |
| `line-through-the-ice` (`lone-line-sitting-canon`, L1) | A thin Water line that hooks a foe and drains a little of their linh lực each second it holds; what it drains is banked as Catch for Landing the Fish. | Water `elem` (`c_art 0.8`, cost `0.03`, cd `7.0`, tags `["water", "cold", "hook"]`): `art_fired` sets `ice_line` (`cap: 1, each_for: 6.0`); `pulse` while `ice_line >= 1` -> `burn_qi {of: "qi_max", share: 0.015, to_self: 1.0}`. | Pinned hold to `6.0 s` and drain rate to `1.5 %` foe `qi_max` per pulse. |
| `sitting-in-the-snow` (`lone-line-sitting-canon`, L2) | A stance: while the holder does not move, their linh lực regenerates quickly and Water damage taken is lowered. | Water `elem` (`c_art 0.0`, cost `0.03`, cd `4.0`, tags `["water", "cold", "stance"]`), guard `own.state.sitting-in-the-snow < 1`: enters state `sitting-in-the-snow` (`tags: ["composed"]`, `regen: 0.025`); `always` while up -> `dampen_taken 20 [dtype: cold]`. | Stays up for the fight rather than toggling; Cold reduction runs via `always` Effect (`state.mods` takes no `dtype`). |
| `landing-the-fish` (`lone-line-sitting-canon`, L6, `e5`) | Short pull (`c 0.6`). Every point drained by Line Through the Ice and A Bite on the Line banked as Catch; firing spends Catch as 1 Water hit worth `3x` Catch (`6x` if foe `< 20 %` linh lực). | Water `elem` (`c_art 0.6`, cost `0.04`, cd `6.0`, tags `["water", "hook", "heavy"]`): `qi_drained` -> `catch + 1`; `hit_landed` (`catch >= 1`) -> `free_hit {c: 0.35, dtype: "elem", outside_budget: true}` per `catch` (`0.70` if `foe.qi_share < 0.2`), clears `catch`. | Adapted from `auth-tech.json` `e5`: uses existing `qi_drained` -> `catch` count and `scale`-driven `free_hit.c` instead of unbuilt `counter.add_amount`, `free_hit.amount`, and `filter.source`. Triggers on `hit_landed` so `The Line Is Patient`'s `1 ms` sure-hit `acc` covers both the pull and the Catch payoff. |

---

## E. Effects (`design/stage6-staging/lanh_giang/effects/lanh_giang.effects.json`)

Every Effect declares all counters it reads or writes in its own `"counters"` array for standalone GDScript compilation (`test_every_library_effect_compiles`).

| Effect (host) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `A Bite on the Line` (`lg-ice-hook`) | While your Line Through the Ice holds a foe, your Sitting in the Snow stance also drains them: each second you sit, they lose 1 % of their linh lực to you, banked as Catch for Landing the Fish. | Declares `ice_line` (`cap: 1, each_for: 6.0`). `pulse` (`own.counter.ice_line >= 1` and `own.state.sitting-in-the-snow >= 1`) -> `burn_qi {of: "qi_max", share: 0.01, to_self: 1.0}`. | None (`qi_drained` feeds `catch` automatically). |
| `The Line Is Patient` (`lg-lone-line`, 2pc) | While you hold the sitting stance, your linh lực leech also heals you for half as much, and every 5 s you hold it your next hook art is a sure hit. | Declares `patient_sec`, `patient_sure` (`cap: 1`). `always` (`state.sitting-in-the-snow >= 1`) -> `leech_hp: 3`; `pulse` sitting increments `patient_sec` -> at `5`, resets `patient_sec = 0` and sets `patient_sure = 1` (clears `patient_sec` if not sitting); `art_fired` (`tags: ["hook"]`, `patient_sure >= 1`) -> `acc: 500` (`1 ms`) + `patient_sure = 0`. | `approx`: engine lacks `own.leech_qi` readable, so `leech_hp: 3` is fixed at half of the Lone Line set's `6 %` `leech_linh_luc_pct`. |
| `Answers Twice` (`lg-heap-of-snow`, 3pc) | While you sit, your ward gains 2 % of its value each second; when a foe breaks it, your next counter art fires twice. | Declares `answers_twice_ready` (`cap: 1`). `pulse` (`state.sitting-in-the-snow >= 1`) -> `ward_grow {share: 0.02, of: "hp"}`; `shield_broken` -> `answers_twice_ready = 1`; `art_fired` (`tags: ["counter", "seal"]`, `answers_twice_ready >= 1`) -> `fire_art {which: "last", share: 1.0}` + `answers_twice_ready = 0`. | Grows `sward` with `of: "hp"` (Bồ has no other stance ward); triggers on `counter` or `seal` arts (`backwash-seal`). |

---

## F. Items & sets (`design/stage6-staging/lanh_giang/items/`)

- **5 signature items** (`catalogue-sect-lanh_giang.json`), modifiers verbatim (`23/23` lines run), `sources: ["npc"]`, `unique: true`, `arts: []`:
  - `lg-ice-hook` (`cham`, grade 3, `lu_doc_dieu`, `"effects": ["A Bite on the Line"]`, R6 `exception`).
  - `lg-snow-cape` (`dao_bao`, grade 3, `bo_toa_tuyet`, R6 `exception`).
  - `lg-sitting-robe` (`dao_bao`, grade 2, `lu_doc_dieu`, R6 `exception`).
  - `lg-old-sitter-gourd` (`ho_lo`, grade 3, `bo_toa_tuyet`, R6 `exception`).
  - `lg-river-bottom-stone` (`ngoc_boi`, grade 3, `bo_toa_tuyet`, no `exception` needed).
- **2 sets** (`sets-lanh_giang.json`):
  - `lg-lone-line` (2pc: `lg-ice-hook`, `lg-sitting-robe`, `lu_doc_dieu`) -> `effect`: `"The Line Is Patient (Tuyến Năng Nhẫn)"`.
  - `lg-heap-of-snow` (3pc: `lg-snow-cape`, `lg-old-sitter-gourd`, `lg-river-bottom-stone`, `bo_toa_tuyet`) -> `effect`: `"Answers Twice (Lưỡng Ứng)"`.

---

## G. Stand-ins & beasts

- **Stand-ins:** `0` across all 17 living cast members in `lanh_giang.cast.json` and `lanh_giang.5.cast.json`.
- **Beasts:** `0`.

---

## H. Holder table & verification (`DEPTH_STAGE=design/stage6-staging/lanh_giang`)

### Linters & static checks
- `lint_arts.py part-sect-lanh_giang.json`: `checked 4 arts in 1 files, 0 findings`.
- `lint_techniques.py catalogue-sect-lanh_giang.json`: `checked 2 techniques, 0 findings` (`7.6 W of 8`, `15.5 W of 16`).
- `lint_items.py items/catalogue-sect-lanh_giang.json`: `checked 5 items, 22 bases, 9 common arts, 0 findings` (`unique 5 of 5`).
- `depth_check.py --quiet`: `findings: none`.
- Standalone `engine.validate` per Effect (`lanh_giang.effects.json`): `STANDALONE_VALIDATE_OK: 3`.
- `suite_check.py part-sect-lanh_giang.json`: `ice-fish-boat-breath` (`1.40x` / `1.23x` near typical), `lone-line-sitting-canon` (`1.32x` / `1.20x` near typical; `NEVER_ENGAGED` note only because `line-through-the-ice` and `landing-the-fish` use Effect counters rather than `steps`/`empower`).

### `sect_fight.py lanh_giang --seeds 5` (`--gap 0` and `--gap 1`)

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effect runs & art fires |
|---|---|---|---|---|---|
| `lu_doc_dieu` | `truc_co` | `line-through-the-ice`, `sitting-in-the-snow`, `landing-the-fish`, `seep-through-palm`, `marrow-to-dew`, `drag-of-the-deep` | `19.3 s`, `5/5`, `56%` | `12.5 s`, `0/5`, `0%` | All 6 arts fire (`2.8/1.0/3.4/7.4/3.0/4.8` at gap 0); `A Bite on the Line`: `68 / 35` runs (`with 19.3s 56%` vs `without 22.8s 47%`); `The Line Is Patient`: `77 / 45` runs (`with 19.3s 56%` vs `without 19.3s 53%`) |
| `bo_toa_tuyet` | `ket_dan` | `line-through-the-ice`, `sitting-in-the-snow`, `landing-the-fish`, `backwash-seal` | `27.0 s`, `5/5`, `96%` | `16.0 s`, `0/5`, `0%` | All 4 arts fire (`4.0/1.0/5.0/15.4` at gap 0); `Answers Twice`: `138 / 165` runs (`with 27.0s 96%` vs `without 29.2s 59%`) |
| `man_tinh_ba` | `truc_co` | `line-through-the-ice`, `sitting-in-the-snow`, `landing-the-fish`, `seep-through-palm`, `marrow-to-dew` | `27.1 s`, `5/5`, `28%` | `12.0 s`, `0/5`, `0%` | All 5 arts fire (`4.2/1.0/5.2/10.6/4.8`) |
| `su_pha_bang` | `truc_co` | `line-through-the-ice`, `sitting-in-the-snow`, `seep-through-palm`, `marrow-to-dew` | `34.5 s`, `5/5`, `12%` | `12.0 s`, `0/5`, `0%` | All 4 arts fire (`5.4/1.0/14.0/6.4`) |
| `than_vong_giang` | `truc_co` | `line-through-the-ice`, `sitting-in-the-snow`, `seep-through-palm` | `34.2 s`, `5/5`, `41%` | `8.8 s`, `0/5`, `0%` | All 3 arts fire (`5.4/1.0/13.8`) |
| `phuong_lo_hoa`, `tien_ngan_lan` | `truc_co` | `line-through-the-ice`, `sitting-in-the-snow` | `59.8 s`, `0/5`, `0%` | `10.4 s`, `0/5`, `0%` | Both arts fire (`8.8/1.0` at gap 0) |
| `bui_truong_tuyen`, `lieu_thoa_nhi`, `ngai_han_tich` | `luyen_khi` | `line-through-the-ice`, `sitting-in-the-snow` | `57.0 s`, `0/5`, `0%` | `8.8 s`, `0/5`, `0%` | Both arts fire (`8.0/1.0` at gap 0) |
| `cu_bang_ngu`, `mach_tieu_dieu`, `hong_lap_nhi`, `phuong_diep_chu`, `la_to_lan`, `ma_han_chu`, `chiem_dong_nhi` | `luyen_khi` | `oar-stroke` | `51.4 s`, `1/5`, `0%` | `8.1 s`, `0/5`, `0%` | `oar-stroke` fires (`17.4` at gap 0, `2.0` at gap 1) |

### Targeted probes (10–20 seeds)
- **`lu_doc_dieu` vs `evade_pct: 35` foe (20 seeds):** `with The Line Is Patient`: `25.1 s`, `20/20` wins, `41%` HP left; `without`: `28.1 s`, `20/20` wins, `29%` HP left (`10`-seed sub-record trace: `eff:The Line Is Patient tick: 198`, `arm: 38`, `sure: 37`, `eff:A Bite on the Line: 195`).
- **`lu_doc_dieu` sub-record trace (gap 0, 10 seeds):** `catch-bank: 232`, `catch-landed: 10`, `catch-landed-dry: 11`, `eff:A Bite on the Line: 135`, `eff:The Line Is Patient arm: 20`, `sure: 18`, `tick: 115`, `line-through-ice-hook: 28`, `line-through-ice-drain: 135`, `sitting-enter: 10`.
- **`lu_doc_dieu` vs `n_qi: 0.2` low-qi foe (10 seeds):** `catch-landed-dry: 9` (dry `0.70 c` payoff verified).
- **`bo_toa_tuyet` sub-record trace (10 seeds):** gap 0 (`catch-bank: 173`, `catch-landed: 20`, `catch-landed-dry: 20`, `eff:Answers Twice grow: 239`, `broken: 21`, `reply: 21`); gap 1 (`eff:Answers Twice grow: 130`, `broken: 130`, `reply: 70`).
