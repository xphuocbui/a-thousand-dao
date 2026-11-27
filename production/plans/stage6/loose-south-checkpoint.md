# Loose Cultivators of the South (`loose-south`): Stage 6 Checkpoint Review (Batch `b06`)

Unanchored checkpoint review of [design/stage6-staging/loose-south/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/loose-south) against [loose-south.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.md), [loose-south.items.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.items.json), [loose-south.beasts.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.beasts.json), [loose-south.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.cast.json), [loose-south.2.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.2.cast.json), [\_brief-review.md](file:///C:/Users/xphuo/IdeaProjects/my-game/production/plans/stage6/_brief-review.md), [\_brief-record.md](file:///C:/Users/xphuo/IdeaProjects/my-game/production/plans/stage6/_brief-record.md), [DECISIONS-2026-11-25.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/DECISIONS-2026-11-25.md), [DECISIONS-2026-11-26.md](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/DECISIONS-2026-11-26.md), [FIGHT-INPUT.md](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/FIGHT-INPUT.md), [engine.py](file:///C:/Users/xphuo/IdeaProjects/my-game/tools/design/combat_sim/engine.py), [effect_compiler.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/combat/fight/effect_compiler.gd), [effect_runner.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/combat/fight/effect_runner.gd), [fight.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/combat/fight/fight.gd), and [cong_phap.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/cultivation/cong_phap.gd).

---

## 1. Ranked Findings

**1 MUST-FIX (fixed), 1 SHOULD (fixed), 2 NIT (open for Stage 7/9 — pre-existing cross-owner / committed data, left unedited).**

1. **[MUST-FIX — FIXED] [loose-south.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/loose-south/effects/loose-south.effects.json) :: `Tempered by Arrows` (`eff:Tempered by Arrows gain`, `eff:Tempered by Arrows spend`)**
   - **What was wrong:** `eff:Tempered by Arrows gain` gave Thunder buff stacks with `"for": 8`, so any stacks held past 8 s without a `sword`/`saber` hit bulk-expired at 8 s while `arrow_thunder` continued counting down 1 per 2 s (breaking `"the stacks fall away one every 2 s"` and desyncing `own.buff.thunder` from `arrow_thunder`). In addition, `eff:Tempered by Arrows spend` used a hardcoded `"n": 99` cap on `consume` instead of consuming all stacks (`scale-without-caps`).
   - **Fix applied:** Removed `"for": 8` from `stacks` in `eff:Tempered by Arrows gain` (creating fight-long Thunder buff stacks that decay strictly 1 per 2 s via `eff:Tempered by Arrows decay`), omitted the arbitrary `"n": 99` cap on `consume` in `eff:Tempered by Arrows spend` (`engine.py:2049` and `effect_runner.gd:642` default to consuming all stacks), and updated `"approx"` in [loose-south.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/loose-south/effects/loose-south.effects.json). Verified in a 64 s long-hold probe: `arrow_thunder == own.buff.thunder == 84.0`.

2. **[SHOULD — FIXED] [loose-south.items.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.items.json), [catalogue-sect-loose-south.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/loose-south/items/catalogue-sect-loose-south.json), [loose-south.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.cast.json) — Remaining spatial wording and `"Still"` rename**
   - **What was wrong:** Although `loose-south-review.md` reported cleaning spatial words in `people/loose-south.items.json`, the depth file still carried `"from range"` on `Dark on Dark Water` (`ls-unlit-sail`), `"from range"` on `Tempered by Arrows` (`ls-stockade-pair`), `"Still"` instead of `"Composed"` on `No One Drowns` (`ls-free-crossing`), `"from range"` on `ls-snare-wire-coins.build_use` (also present in staged `catalogue-sect-loose-south.json`) and `sam_van_nuong.build.tree.intent`, plus `"flag"` on `ls-unlit-sail.build_use` (matching `spatial_words_check.py`'s `removed` rule).
   - **Fix applied:** Updated `Dark on Dark Water`, `ls-snare-wire-coins.build_use`, `ls-stockade-pair`, `ls-free-crossing`, and `ls-unlit-sail.build_use` (`"flag"` -> `"pennant"`) in [loose-south.items.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.items.json), updated `ls-unlit-sail.build_use` and `ls-snare-wire-coins.build_use` in [catalogue-sect-loose-south.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/loose-south/items/catalogue-sect-loose-south.json), and removed `"from range"` from `sam_van_nuong.build.tree.intent` in [loose-south.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.cast.json).

3. **[NIT — OPEN FOR STAGE 7/9] [loose-south.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.cast.json) :: `do_liet_co` `aux[1]` (`black-wind-blood-sabre`)**
   - **What was found:** `do_liet_co` slots `black-wind-blood-sabre` (owned and staged by `demonic` in `design/stage6-staging/demonic/techniques/catalogue-sect-demonic.json`) in `build.aux`, where it has `"tech_kind": "main"`. `CongPhap.usable()` passes (`kim` + `hoa`), and `sect_fight.py` runs all 6 arts when loaded together, whereas `CongPhap.set_slot("aux", ...)` (`src/gameplay/cultivation/cong_phap.gd:84`) rejects `"main"`-kind methods in auxiliary slots. Kept referencing `demonic` cleanly without duplicating or early-promoting per the `b06` serial merge plan; logged for Stage 7/9 cleanup.

4. **[NIT — OPEN FOR STAGE 7/9] [loose-south.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/people/loose-south.cast.json) :: `gian_van_lo` pre-existing two stances (`morning-cloud` + `march`)**
   - **What was found:** `gian_van_lo`'s pre-existing build slots `southern-shore-cloud-canon` (`nam_pho`, `catch-the-morning-cloud` -> stance `morning-cloud`) and `thorn-and-ink-verses` (`soul-song-seal`, `marching-dirge` -> stance `march`). In combat, `marching-dirge` overwrites `morning-cloud`, and `catch-the-morning-cloud` skips setting `morning-cloud` while `own.state.any != 0`. Both techniques are committed outside `loose-south`'s Stage 6 scope (matching `binh_thuy-checkpoint.md` `bui_phieu_binh` precedent), so no cross-owner files were edited.

---

## 2. Specific Audits & Parity Verification

- **Top-level & standalone Effect compilation (`E.validate()` + `EffectCompiler` / `EffectRunner` parity):**
  - `loose-south.effects.json` includes `"_doc"` and `"source": "world-depth:loose-south"`.
  - All `7` active Effects (`The Goat Knows`, `No Fare`, `Dark on Dark Water`, `Walked Out of Chiết Kích`, `Tempered by Arrows`, `No One Drowns`, `Leave While It Burns`) declare their own `counters` (`goat_refused`, `has_companion`, `arrow_thunder`, `burn_vanish_cd`) and `states` (`[]`) and pass `F.expand_library` + `F.to_build` + `E.validate()` standalone (`0` errors).
  - `Stamp of Trust` (`ls-false-cloud-seal`) is cleanly marked `not_run` (`"out-of-fight forgery and social inspection rule, no combat record"`, `records: []`).
  - `Know the Way Out` (`ls-thu-am-goat-bell`, `ls-unlit-sail`) has `"new": false` on both entries in `loose-south.items.json`, is referenced as `"Know the Way Out"` in `catalogue-sect-loose-south.json`, and is NOT redefined in `loose-south.effects.json` (owned by `world-depth:thien_xu` in `assets/data/combat_effects.json`).
  - `0` Effect-name or record-ID collisions against `assets/data/combat_effects.json`, committed `design/`, or other `design/stage6-staging/` directories.
  - `0` multi-`mod` records lacking `"stack": true`; `0` `temp_mods` filtering on `"art_id"` or carrying `"status_immune"`; `0` `always` records with record-level `filter`; `0` `held` records with `filter`; `0` `decay_per_pulse: 1`; `0` `"set": 1` on `each_for` counters (`burn_vanish_cd` uses `"add": 1`); `0` `was_hit` damage triggers missing `event.amount > 0` (`Tempered by Arrows gain` guards `event.amount > 0`; `The Goat Knows` and `Walked Out of Chiết Kích` intentionally handle 0-damage debuff/curse hits).
- **Items (`13`) & Sets (`5`):**
  - All `13` items in `catalogue-sect-loose-south.json` (`sources: ["npc"]`, `unique: true`, `arts: []`, `10` with R6 `exception` matching bases with common arts/wards, `3` without: `ls-thuy-khau-stern-lamp` `dang`, `ls-unlit-sail` `ky`, `ls-thunder-pendant` `ngoc_boi`) match `loose-south.items.json` modifiers, families, grades, holders, and makers. `ls-white-wind-hook` is held by `do_vo_cuu` in `design/world/depth/sects/thien_xu.2.cast.json`.
  - All `5` sets in `sets-loose-south.json` match exact depth set names, Hán-Việt parentheticals, piece lists, and 2pc/3pc modifiers.
- **Stand-ins (`16`) & Beasts (`1`):**
  - All `16` replaced stand-ins (`do_liet_co`, `bien_am_pham`, `uong_tam_pham`, `mao_dinh_lang`, `pho_ket_thang`, `man_bo_vong`, `cuu_quy_hoa`, `moc_tau_vu`, `me_thiem_nhi`, `lo_tam_chuy`, `quan_thap_nhat`, `phu_hoa_sinh`, `yen_thuy_hoa`, `dan_tan_lao`, `lien_que_chi`, `tuyen_dang_nhi`) match their build notes and roots.
  - All `31` living cast members in `loose-south.cast.json` + `loose-south.2.cast.json` pass `CongPhap.usable()` (`names` subset of `root.elements | root.variants`) and technique layer bounds (`1 <= layer <= tech.layers`), including `do_liet_co`'s `demonic` aux `black-wind-blood-sabre`.
  - `an_thu_son` carries `"beasts": ["bat_phe"]` matching `bat_phe` (`owner_id: "an_thu_son"`) in `loose-south.beasts.json`.
- **Linters & Targeted Probes (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\loose-south`):**
  - `lint_items.py design/stage6-staging/loose-south/items/catalogue-sect-loose-south.json`: `checked 13 items, 22 bases, 9 common arts, 0 findings`.
  - `depth_check.py --sect loose-south --quiet`: `findings: none`.
  - `stage6_merge.py loose-south --check`: `0 failure(s)` (3 moves).
  - `spatial_words_check.py --sect loose-south`: `0` hits; direct scan on `people/loose-south.*` + staged files: `0` non-commentary hits (`4` commentary/tie-note hits: `truong_da_dao` `"Footwork"`, `do_liet_co` `"hooked"`, `loc_bat_quy` `"Flag"`, `3` `beside` tie notes).
  - Targeted probes after edits: `do_liet_co` + `demonic` `black-wind-blood-sabre` (`9.0 s`, `5/5`, `100%` HP, `Tempered by Arrows gain: 80, decay: 20, spend: 15`); `Tempered by Arrows` 64 s hold (`arrow_thunder == buff.thunder == 84.0`); `khau_bach_thu` vs Wood/curse foe (`9.0 s`, `5/5`, `100%` HP, `The Goat Knows hit curse: 5`, `Walked Out of Chiết Kích hit wood: 7, hit curse: 9, decay: 25`); `yen_hoi_do` + companion at `--gap 1` (`15.8 s`, `No Fare comp hit: 5, heal: 73`, `No One Drowns ward: 73, save: 5`).

---

## 3. Pending Words

None (`0` pending words; no `pending.json`).

---

## 4. Holder Table After Fixes (`sect_fight.py loose-south --seeds 5`)

`0 REFUSED` across all `24` living authored-build holders at `--gap 0` and `--gap 1`. All arts fire at `--gap 0` (`>= 1.0` per fight).

| Holder | Realm | `--gap 0` (`mean_s`, `wins`, `hp_left`) | `--gap 1` (`mean_s`, `wins`, `hp_left`) | Effects (`--gap 0` / `--gap 1` runs) |
|---|---|---|---|---|
| `mao_dinh_lang` | `luyen_khi` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | — |
| `pho_ket_thang` | `luyen_khi` | `41.2 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | — |
| `trinh_tieu_do` | `luyen_khi` | `62.2 s`, `5/5`, `74%` | `13.0 s`, `0/5`, `0%` | — |
| `man_bo_vong` | `luyen_khi` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | — |
| `cuu_quy_hoa` | `luyen_khi` | `25.8 s`, `5/5`, `100%` | `8.1 s`, `0/5`, `0%` | — |
| `moc_tau_vu` | `luyen_khi` | `44.9 s`, `0/5`, `0%` | `9.0 s`, `0/5`, `0%` | — |
| `me_thiem_nhi` | `luyen_khi` | `45.0 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | — |
| `tu_ban_kiem` | `luyen_khi` | `61.4 s`, `0/5`, `0%` | `9.2 s`, `0/5`, `0%` | — |
| `truong_da_dao` | `luyen_khi` | `44.9 s`, `0/5`, `0%` | `9.0 s`, `0/5`, `0%` | — |
| `quan_thap_nhat` | `luyen_khi` | `37.9 s`, `4/5`, `20%` | `8.2 s`, `0/5`, `0%` | — |
| `phu_hoa_sinh` | `luyen_khi` | `47.4 s`, `1/5`, `2%` | `8.0 s`, `0/5`, `0%` | — |
| `yen_thuy_hoa` | `luyen_khi` | `63.0 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | — |
| `lan_bat_nhien` | `luyen_khi` | `24.3 s`, `5/5`, `100%` | `8.0 s`, `0/5`, `0%` | — |
| `lien_que_chi` | `luyen_khi` | `56.6 s`, `4/5`, `16%` | `8.0 s`, `0/5`, `0%` | — |
| `tuyen_dang_nhi` | `luyen_khi` | `30.4 s`, `5/5`, `100%` | `8.0 s`, `0/5`, `0%` | — |
| `khau_bach_thu` | `ket_dan` | `9.0 s`, `5/5`, `100%` | `15.4 s`, `0/5`, `0%` | `The Goat Knows` (`0`/`0` vs Fire foe; Probe: `5`), `Know the Way Out` (`0`/`0`; no escape art), `Walked Out of Chiết Kích` (`0`/`0` vs Fire foe; Probe: `41`). At `--gap 1`, `bastion-reprisal` `fires 0.0` (dies at `15.4 s` before firing). |
| `do_liet_co` | `ket_dan` | `9.3 s`, `5/5`, `86%` | `12.0 s`, `0/5`, `0%` | `Tempered by Arrows` (`with 9.3 s 86%` vs `without 13.4 s 64%`, `115` / `152` runs). At `--gap 1`, `open-the-sky` `fires 0.0` (dies at `12.0 s`). |
| `yen_hoi_do` | `truc_co` | `31.8 s`, `5/5`, `95%` | `15.1 s`, `0/5`, `0%` | `No Fare` (`0`/`0`, solo build; Probe: `78`), `No One Drowns` (`with 31.8 s 95%` vs `without 31.8 s 94%`, `10` runs; `--gap 1`: `with 15.1 s` vs `without 13.8 s`, `23` runs). |
| `gian_van_lo` | `truc_co` | `12.7 s`, `5/5`, `100%` | `8.8 s`, `0/5`, `0%` | `Stamp of Trust` (`0`/`0`, `not_run`), `Leave While It Burns` (`with 12.7 s` vs `without 13.1 s`, `5` runs; `--gap 1`: `with 8.8 s` vs `without 8.4 s`, `1` run). |
| `doan_moc_thinh` | `truc_co` | `40.6 s`, `5/5`, `20%` | `8.4 s`, `0/5`, `0%` | — |
| `loc_bat_quy` | `truc_co` | `32.6 s`, `3/5`, `8%` | `8.0 s`, `0/5`, `0%` | At `--gap 1`, `flying-blade-retinue` `fires 0.0` (dies at `8.0 s`). |
| `sam_van_nuong` | `truc_co` | `20.6 s`, `5/5`, `69%` | `9.2 s`, `0/5`, `0%` | — |
| `bien_am_pham` | `truc_co` | `14.5 s`, `5/5`, `100%` | `16.4 s`, `0/5`, `0%` | `Dark on Dark Water` (`with 14.5 s` vs `without 15.2 s`, `5` runs; `--gap 1`: `with 16.4 s` vs `without 16.0 s`, `5` runs), `Know the Way Out` (`0`/`0`, no escape art). |
| `uong_tam_pham` | `truc_co` | `32.5 s`, `5/5`, `95%` | `8.0 s`, `0/5`, `0%` | — |

CHECKPOINT DONE
