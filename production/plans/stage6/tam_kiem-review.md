# Stage 6 Record Pass Review — Tầm Kiếm Đường (`tam_kiem`)

**Date**: 2026-11-27
**Owner**: `tam_kiem`
**Status**: Staged cleanly under [design/stage6-staging/tam_kiem/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tam_kiem/). All three linters (`lint_techniques.py`, `lint_arts.py`, `lint_items.py`) report `0` findings; standalone `engine.validate` passes on both staged Effects (`STANDALONE_OK 2`); `depth_check.py --quiet` reports `findings: none`; `spatial_words_check.py` reports `0` hits across all staged files; `sect_fight.py tam_kiem --seeds 5` (`--gap 0` and `--gap 1`) plus a parity-log probe verify `0 REFUSED` across all `10/10` living cast members and confirm every slotted art fires.

---

## Summary

- **Techniques staged ([techniques/catalogue-sect-tam_kiem.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tam_kiem/techniques/catalogue-sect-tam_kiem.json))**: `3` element-free (`names: []`) techniques — `tracker-sword-primer` (Tier `0` Yellow main), `asking-blade-canon` (Tier `1` Profound main), and `seal-listening-art` (Tier `1` Profound secret). Existing references (`mountain-bone-body-art` in [catalogue-body.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/techniques/catalogue-body.json), `afterimage-sword-canon` in [catalogue-blade.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/techniques/catalogue-blade.json), and `clear-frost-breath` in [catalogue-sect-bang_tam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/techniques/catalogue-sect-bang_tam.json)) are already promoted. New bonuses and passives are sized to Tier `0` (`8.0 W of 8`) and Tier `1` (`16.0 W`, `15.8 W of 16`) norms.
- **Arts staged ([arts/part-sect-tam_kiem.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tam_kiem/arts/part-sect-tam_kiem.json))**: `4` newly authored element-free Physical arts — `where-it-will-be`, `ask`, `the-blade-answers`, and `the-silent-place`. Art IDs were inserted into [tam_kiem.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/tam_kiem.techniques.json).
- **Effects staged ([effects/tam_kiem.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tam_kiem/effects/tam_kiem.effects.json))**: `2` new Effects — `The Second Duel` (`tk-evening-sword`) and `The Answer` (`tk-map-wall` full set). Both declare every counter they read or write locally (`STANDALONE_OK 2`).
- **Items & sets staged ([items/catalogue-sect-tam_kiem.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tam_kiem/items/catalogue-sect-tam_kiem.json), [items/sets-tam_kiem.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tam_kiem/items/sets-tam_kiem.json))**: `3` unique signature items (`tk-asking-blade`, `tk-evening-sword`, `tk-map-coat`, all `sources: ["npc"]`, `unique: true`, and carrying the R6 `exception` mark) and `1` 2-piece set (`tk-map-wall`).
- **Stand-ins, beasts, early promotions**: `0` stand-ins across `10` living cast records, `0` beasts, `0` early promotions.
- **Pending engine words**: `0` (`pending.json` not needed).
- **Deviations**: `5` (§D–§E).
- **Never ran in `sect_fight.py` (verified/explained)**:
  - `The Answer` on `tieu_van_phong` prints `runs 0 NEVER_RAN` in `sect_fight.py` only because `sect_fight.py` counts `Fight.do()` invocations and both records of `The Answer` are `on: "always"` (`EffectRunner.mod()`). The `--without` comparison proves it strongly alters the fight (`30.5 s, 40 %` HP left with vs `34.9 s, 28 %` HP left without), and the parity-log probe confirms `ask-place-mark` fires `15` times across `3` `the-blade-answers` casts (`5` marks/cast average, hitting the `>= 5` bypass threshold).
- **Open items**:
  - Serial merge of `design/stage6-staging/tam_kiem/` into `design/` and `assets/data/combat_effects.json` (`put_effects.py` under `world-depth:tam_kiem`).
  - Stage 7 export (`export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, `export_world.py --sect tam_kiem`) to close `N-tam_kiem-01` and `N-tam_kiem-02` events.

---

## §A Decisions Auto-Accepted (user rule 2026-11-26), with reasons

1. **Use `names: []` directly on all 3 element-free techniques (`lint-element-free-techniques`) and size new bonuses and passives to Tier 0 / Tier 1 norms.**
   - *Choice:* Keep `names: []` on `tracker-sword-primer`, `asking-blade-canon`, and `seal-listening-art`; size `tracker-sword-primer` (`0` bonuses, `8.0 W of 8`), `asking-blade-canon` (`attack_pct 10`, `16.0 W of 16`), and `seal-listening-art` (`than_thuc_pct 10`, `15.8 W of 16`). Place `ask` at `unlock_layer: 1` and `the-blade-answers` at `unlock_layer: 2` on `asking-blade-canon`.
   - *Reason:* All 4 carried arts have `element: ""`, so `lint_techniques.py` accepts `names: []` under `b02`. Layer-1 `ask` ensures `hach_tung` (layer `1`) has an active art, while layer-2 `the-blade-answers` unlocks the full Ask + Answer combo for layer-2+ disciples (`tieu_hoe_sinh`, `ngo_han_dac`, `lac_tam_chan`, `quach_do_anh`, etc.). On `sai_mo_kiem` (`afterimage-sword-canon` L7 + `asking-blade-canon` L9), `2 + 4 = 6` arts fit cleanly within `MAX_ARTS = 6`, and `flurry-stance` has no stance conflict with `tam_kiem`'s stance-free arts.
2. **Read `"against a moving foe"` in `where-it-will-be` via Combat rule 25 (`foe.pressing >= 1` or `own.foe_pressed >= 1`) and model `"cannot miss"` as instant `+100` pp `acc` (`for: 0`).**
   - *Choice:* Gate both `where-it-will-be`'s `empower` (`c_mult: 1.6`) and `where-it-will-be-sure` (`on: "art_fired"`, `mod: {"acc": 100}`) on `any(foe.pressing >= 1, own.foe_pressed >= 1)`.
   - *Reason:* `DECISIONS-2026-11-26.md` replaces *"moving foe"* with `Pressing` and `foe_pressed` (*"it fired a damaging or movement art, or evaded, in the last second"*). Checking both covers stance-Pressing duelists and standard opponents alike. Because `engine.py` reads `acc` without `ctx`, an `art_fired` `temp_mod` with `for: 0` (`until = t + 1` ms) guarantees the instant hit cannot be evaded without leaking duration or spending a curse slot (`off_guard`).
3. **Time `ask` (`cd: 1.4`) and `the-blade-answers` (`cd: 7.2`, `guards: ask_mark >= 1`) so Ask marks reliably reach `5`, and reset `ask_mark` on `hit_landed`/`was_evaded`.**
   - *Choice:* `ask` places `1` `ask_mark` (`+5` pp `crit` each) every `1.4 s`; `the-blade-answers` requires `ask_mark >= 1`, reads `ask_mark` on `always` (`dmg_more: 0.15`, `art_id: "the-blade-answers"`) and `art_fired` (`pierce: 8`, `for: 0`), and clears `ask_mark = 0` on `hit_landed` and `was_evaded`.
   - *Reason:* `shape()` and `art_fired` run before `hit()`, and `pierce` is read without `ctx`. Reading `ask_mark` before `hit()` (via `always` for `ctx`-scoped `dmg_more`/`crit_mult`/`bypass`, and `until = t + 1` ms `temp_mod` on `art_fired` for `pierce`) and clearing on `hit_landed`/`was_evaded` avoids the pre-hit clear trap. `1.4 * 5 = 7.0 < 7.2` ensures `tieu_van_phong` naturally stacks `5` marks before `the-blade-answers` fires, activating `The Answer`'s `>= 5` bypass.
4. **Model `the-silent-place` as a `0.0`-coeff utility cast arming `silent_place` (`bypass: 0.35`, `pen: 80`) until the next `hit_landed`.**
   - *Choice:* `c_art: 0.0`, `cost_share: 0.03`, `cooldown: 5.0`, `tags: ["physical", "seal"]`, setting `silent_place = 1` on `art_fired` and clearing on `hit_landed`.
   - *Reason:* Matches *"Reveals the foe's ward and seals; the holder's next hit ignores part of the ward"* without inventing a new engine word; `bypass: 0.35` penetrates ward shields and `pen: 80` penetrates ward resistance on the next landed hit.
5. **Pin `The Second Duel` on `event.amount > 0` (`was_hit`) and `The Answer`'s ward-ignore at `bypass: 0.5` (`bypass_cap`).**
   - *Choice:* `The Second Duel` triggers only on a damaging `was_hit` (`event.amount > 0`) and grants `+10 %` `dmg_more` to `tags: ["sword"]`. `The Answer` declares `ask_mark` locally, scales `crit_mult: 10` per `ask_mark` (`art_id: "the-blade-answers"`), and grants `bypass: 0.5` at `ask_mark >= 5` (`approx`, matching `bang_tam`'s `Every Fifth a Star`). Mark all `3` items `sources: ["npc"]`, `unique: true`, and R6 `exception`.
   - *Reason:* Follows the b01–b04 pitfall checklist (`was_hit` `event.amount > 0` guard, standalone `counters` declaration) and `DECISIONS-2026-11-26.md` R6 / rule 20f.

---

## §B Mechanic Table (Step 1)

`spatial_words_check.py --sect tam_kiem` flagged only `soft` `beside` in `tieu_van_phong`'s tie note (`tam_kiem.cast.json`). Staged files have **0** spatial hits.

| Record | Mechanic | Engine Status | Staged Implementation |
|---|---|---|---|
| `tracker-sword-primer` / `where-it-will-be` | Unmissable + extra Physical dmg vs moving foe | Has (`pressing`, `foe_pressed`, `acc`, `empower`) | `c_art: 1.5`, `cd: 3.0`; if `foe.pressing >= 1` or `own.foe_pressed >= 1`: `art_fired` `acc: 100` (`for: 0`), `empower` `c_mult: 1.6`. |
| `asking-blade-canon` / `ask` | Probing cut placing marks; each mark raises crit chance | Has (`counter`, `scale`, `crit`) | `c_art: 1.0`, `cd: 1.4`; `hit_landed` adds `1` `ask_mark` (no cap); `always` `+5` pp `crit` per `ask_mark`. |
| `asking-blade-canon` / `the-blade-answers` | Spends all marks; damage & pierce grow with marks spent | Has (`guards`, `dmg_more`, `pierce`, `hit_landed`) | `c_art: 2.0`, `cd: 7.2`, guard `ask_mark >= 1`; `+15 %` `dmg_more` (`art_id`) & `+8` `pierce` (`art_fired` `for: 0`) per mark; resets on `hit_landed`/`was_evaded`. |
| `seal-listening-art` / `the-silent-place` | Next hit ignores part of the foe's ward | Has (`bypass`, `pen`) | `c_art: 0.0`, `cd: 5.0`; `art_fired` sets `silent_place = 1`; `always` `bypass: 0.35`, `pen: 80`; resets on `hit_landed`. |
| `The Second Duel` (`tk-evening-sword`) | `+10 %` sword art dmg after foe has hit you | Has (`was_hit`, `event.amount`, `dmg_more`) | `was_hit` (`event.amount > 0`) sets `second_duel_hit = 1`; `always` `dmg_more: 0.1` (`tags: ["sword"]`). |
| `The Answer` (`tk-map-wall` 2pc) | `+10 %` crit dmg/mark on answering cut; `5+` ignores ward | Has (`crit_mult`, `bypass` `0.5` approx) | `always` `crit_mult: 10` (`art_id: "the-blade-answers"`) per `ask_mark`; at `ask_mark >= 5`: `bypass: 0.5` (`approx`). |

---

## §C Techniques (`design/stage6-staging/tam_kiem/techniques/catalogue-sect-tam_kiem.json`)

`lint_techniques.py`: **checked 3 techniques, 0 findings**. All bonuses and passives are newly authored and unpriced.

| Technique | Tier, Kind | Bonuses (**NEW**) | Passives (**NEW**) | Arts (Unlock) | W Used / Budget |
|---|---|---|---|---|---|
| `tracker-sword-primer` | 0 / `main` | none | `accuracy_pct 8 []`, `crit_chance_pct 3 ["sword"]`, `attack_pct 3 ["sword"]` | `where-it-will-be` (1) | `8.0 W of 8` |
| `asking-blade-canon` | 1 / `main` | `attack_pct 10` | `crit_chance_pct 6 ["sword"]`, `crit_damage_pct 20 ["sword"]`, `pierce_pct 5 []`, `accuracy_pct 6 []` | `ask` (1), `the-blade-answers` (2) | `16.0 W of 16` |
| `seal-listening-art` | 1 / `secret` | `than_thuc_pct 10` | `pierce_pct 8 []`, `resist_pen_pct 40 ["physical"]`, `accuracy_pct 6 []`, `status_resist_pct 4 []` | `the-silent-place` (1) | `15.8 W of 16` |

---

## §D Arts (`design/stage6-staging/tam_kiem/arts/part-sect-tam_kiem.json`)

`lint_arts.py`: **checked 4 arts in 1 files, 0 findings**.

| Art | Depth Text | Engine Form | Deviation |
|---|---|---|---|
| `where-it-will-be` | Cut aimed at foe's next position: vs moving foe cannot miss and deals extra Physical dmg | Physical `c_art: 1.5`, `cost_share: 0.03`, `cd: 3.0`, `tags: ["physical", "sword"]`; if `foe.pressing >= 1` or `own.foe_pressed >= 1`: `art_fired` `acc: 100` (`for: 0`), `empower` `c_mult: 1.6` | **D1:** *"moving"* mapped to `foe.pressing`/`own.foe_pressed`; *"cannot miss"* modeled as `+100` `acc` for `1 ms` (`until = t + 1`). |
| `ask` | Light probing cut that marks the foe; each mark raises crit chance | Physical `c_art: 1.0`, `cost_share: 0.02`, `cd: 1.4`, `tags: ["physical", "sword", "quick"]`; `hit_landed` `+1` `ask_mark` (no cap); `always` `+5` pp `crit` per `ask_mark` | none |
| `the-blade-answers` | Consumes all marks for one cut whose damage and pierce grow with marks spent | Physical `c_art: 2.0`, `cost_share: 0.05`, `cd: 7.2`, `tags: ["physical", "sword", "heavy"]`, guard `ask_mark >= 1`; `+15 %` `dmg_more` (`art_id`) & `+8` `pierce` (`art_fired` `for: 0`) per mark; resets `ask_mark = 0` on `hit_landed`/`was_evaded` | **D2:** Guarded on `ask_mark >= 1`; `pierce` applied via `1 ms` `temp_mod` on `art_fired` (`pierce` has no `ctx`); cleared post-hit so mods read marks before reset. |
| `the-silent-place` | Reveals foe's ward and seals; holder's next hit ignores part of the ward | Physical utility `c_art: 0.0`, `cost_share: 0.03`, `cd: 5.0`, `tags: ["physical", "seal"]`; `art_fired` sets `silent_place = 1`; `always` `bypass: 0.35`, `pen: 80`; clears on `hit_landed` | **D3:** Pinned *"ignores part of the ward"* as `bypass: 0.35` and `pen: 80` on the next landed hit. |

---

## §E Effects (`design/stage6-staging/tam_kiem/effects/tam_kiem.effects.json`)

Standalone `engine.validate`: **STANDALONE_OK 2**.

| Effect (Source) | Depth Rule | Engine Form | Deviation |
|---|---|---|---|
| `The Second Duel` (`tk-evening-sword`) | Against a foe who has already hit you this fight, sword arts deal `10 %` more dmg | `was_hit` (`event.amount > 0`) sets `second_duel_hit = 1`; `always` `dmg_more: 0.1` (`tags: ["sword"]`) | **D4:** Gated `was_hit` on `event.amount > 0` so 0-damage warded/blocked hits do not arm it. |
| `The Answer` (`tk-map-wall` 2pc) | Each mark raises next answering cut's crit dmg by `10 %`; spending `5+` marks ignores foe's ward | `always` `crit_mult: 10` (`art_id: "the-blade-answers"`) scaled per `ask_mark`; at `ask_mark >= 5`: `bypass: 0.5` (`art_id: "the-blade-answers"`) | **D5:** `bypass: 0.5` (`bypass_cap`, `approx` matching `Every Fifth a Star`). |

---

## §F Items and Sets (`items/catalogue-sect-tam_kiem.json`, `items/sets-tam_kiem.json`)

`lint_items.py`: **checked 3 items, 22 bases, 9 common arts, 0 findings** (`unique 3 of 3`).
- `tk-asking-blade` (`phi_kiem` 3, `blade`, `25.0 W`, `unique: true`, `sources: ["npc"]`, R6 `exception`, set `tk-map-wall`)
- `tk-evening-sword` (`phi_kiem` 3, `metal`, `29.5 W`, `unique: true`, `sources: ["npc"]`, R6 `exception`, Effect `The Second Duel`)
- `tk-map-coat` (`dao_bao` 2, `blade`, `15.8 W`, `unique: true`, `sources: ["npc"]`, R6 `exception`, set `tk-map-wall`)
- Set `tk-map-wall` (`The Map Wall (Đồ Bích)`, 2 pieces: `crit_chance_pct 3 ["sword"]`, `accuracy_pct 4 []`, Effect `The Answer (Đáp)`).

---

## §G Stand-ins and Beasts

- **Stand-ins**: `0` across all `10` living cast members.
- **Beasts**: `0`.

---

## §H Pending Words & Open Items

- **Pending engine words**: `0`.
- **Open items**:
  1. Serial merge of `design/stage6-staging/tam_kiem/` into `design/` and `assets/data/combat_effects.json` (`put_effects.py` under `world-depth:tam_kiem`).
  2. Stage 7 export (`export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, `export_world.py --sect tam_kiem`) to close `N-tam_kiem-01` and `N-tam_kiem-02` events.

---

## §I Holder Table (`sect_fight.py tam_kiem --seeds 5`, `--gap 0` & `--gap 1`, + seed-1 parity probe)

**0 REFUSED across all 10/10 living cast members; every slotted art fires.**

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Art Fires & Effects |
|---|---|---|---|---|---|
| `tieu_van_phong` | `truc_co` | `ask`, `the-blade-answers`, `the-silent-place` | `30.5 s`, `5/5`, `40%` | `8.0 s`, `0/5`, `0%` | `ask` `19.0`/`5.0`, `the-blade-answers` `2.8`/`1.0`, `the-silent-place` `5.0`/`1.0`. `The Answer`: `30.5 s, 40%` with vs `34.9 s, 28%` without (`runs 0` `always`-only; seed-1 probe `ask-place-mark` `15`, `blade-answers-spend` `3`, `silent-place-arm`/`spend` `4`/`4`). |
| `sai_mo_kiem` | `ket_dan` | `ask`, `the-blade-answers`, `flurry-stance`, `phantom-sword`, `triple-draw`, `flying-sword` | `11.5 s`, `5/5`, `81%` | `8.8 s`, `0/5`, `0%` | All `6` arts fire (`9.6`/`1.4`/`2.8`/`4.2`/`3.6`/`1.0` G0; `6.4`/`1.0`/`2.2`/`3.0`/`3.0`/`1.0` G1). `The Second Duel`: `5` runs (`11.5 s, 81%` with vs `11.9 s, 81%` without). |
| `cat_linh_hanh` | `truc_co` | `ask`, `the-blade-answers`, `mountain-root-stance` | `25.8 s`, `5/5`, `98%` | `15.4 s`, `0/5`, `0%` | `ask` `17.6`/`6.6`, `the-blade-answers` `3.0`/`1.0`, `mountain-root-stance` `3.6`/`1.6`. |
| `tich_lang_tung` | `truc_co` | `ask`, `the-blade-answers`, `mountain-root-stance`, `bone-turning-palm` | `17.2 s`, `5/5`, `94%` | `15.0 s`, `0/5`, `0%` | `ask` `11.8`/`6.4`, `the-blade-answers` `2.0`/`1.0`, `mountain-root-stance` `2.4`/`1.4`, `bone-turning-palm` `3.8`/`1.4`. |
| `thang_phuc_tuyet` | `truc_co` | `ask`, `the-blade-answers`, `frost-breath-palm` | `26.9 s`, `5/5`, `48%` | `8.0 s`, `0/5`, `0%` | `ask` `18.2`/`5.0`, `the-blade-answers` `2.8`/`1.0`, `frost-breath-palm` `8.0`/`2.0`. |
| `lac_tam_chan` | `truc_co` | `ask`, `the-blade-answers` | `33.6 s`, `5/5`, `38%` | `8.0 s`, `0/5`, `0%` | `ask` `22.8`/`5.0`, `the-blade-answers` `3.6`/`1.0`. |
| `ngo_han_dac`, `quach_do_anh`, `tieu_hoe_sinh` | `luyen_khi` | `ask`, `the-blade-answers` | `34.4 s`, `4/5`, `25%` | `8.0 s`, `0/5`, `0%` | `ask` `20.6`/`5.0`, `the-blade-answers` `2.8`/`0.8`. |
| `hach_tung` | `luyen_khi` | `ask` | `29.7 s`, `5/5`, `39%` | `8.0 s`, `0/5`, `0%` | `ask` `20.6`/`5.0`. |
| `lu_hoi_lo` | `truc_co` | `where-it-will-be` | `49.4 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | `where-it-will-be` `15.8`/`2.0` (seed-1 probe: `where-it-will-be-sure` `4`, `empower` `4`). |
| `au_da_loc`, `duong_tieu_kiem`, `thai_truong_thanh` | `luyen_khi` | `where-it-will-be` | `40.4 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | `where-it-will-be` `12.2`/`2.0`. |
