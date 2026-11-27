# Stage 6 Record Review — `tung_dao` (Tùng Đào Cung)

## Summary
Staged all `tung_dao` Stage 6 content into [design/stage6-staging/tung_dao/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/tung_dao) — **6 techniques** (4 lineage + 2 Yellow stand-ins), **9 active arts**, **27 items** (`td-wandering-dragon-sash` as `kind: "treasure"`, `rarity: 5`), **9 sets**, **23 Effects** (2 technique + 11 item + 10 set bonuses, 2 out-of-combat marked `not_run`), and **1 shared pending word** (`technique-effects`, reusing the batch's approved `"build"` decision) — and wrote back art IDs and stand-in picks cleanly to [tung_dao.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/tung_dao.techniques.json), [tung_dao.3.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/tung_dao.3.cast.json), and [tung_dao.4.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/tung_dao.4.cast.json).

All linters pass with **0 findings** (`lint_arts.py`, `lint_techniques.py`, `lint_items.py`), `depth_check.py --sect tung_dao` passes with **0 findings**, `depth_gap.py` reports **0 stand-ins / 0 unknown_ids**, `engine.validate` accepts all 21 runnable Effects, and `sect_fight.py tung_dao` runs cleanly across all cast members (**0 REFUSED builds**). Targeted combat probes verified every art and combat Effect that either sits behind full 6-slot kits (`the-white-wolf-falls`, `rain-through-the-needles`, `the-road-in-a-dream`), waits on `technique-effects` (`Answering Wave`, `The Fifteenth Layer`), or requires specific enemy threats (`Supple as a Swimming Dragon`, `The Pack Remembers`, `Hear It Coming`, `Cool the Burn`, `Voice in the Rain`, `Ferry Across`, `The Last Bridge`, `Hold the Quay`, `Light on the Quay`).

---

## §A Auto-Accepted Decisions (with design rationale)

1. **`pine-needle-rain` ID instead of `needle-rain`**: `needle-rain` is already taken by the common art on base `cham` in [common-arts.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/items/common-arts.json). Assigned `"pine-needle-rain"` on `listening-pine-primer` and in [tung_dao.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/tung_dao.techniques.json) to satisfy art-ID uniqueness.
2. **`listening-pine-primer` `names: ["moc"]`**: Depth prose allows either Wood or Water roots, and `listening-pine-primer` previously listed `names: ["moc", "thuy"]`. However, `CongPhap.usable` ([cong_phap.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/systems/cong_phap.gd)) requires the cultivator's root to contain *all* elements in `names`. Nine outer disciples (`trinh_van_thanh`, `co_hoi_thiet`, `khau_hanh_nhi`, `lo_phu_sinh`, `mai_tieu_phuc`, `phi_tong_thach`, `khuong_bich_thach`, `kha_lam_dong`, `tat_tieu_phu`) hold Wood without Water, while both primer arts (`seed-of-spring`, `pine-needle-rain`) are Wood (and `khau_phuc_linh` in `market-folk` holds both Wood and Water). Narrowed staged `names` to `["moc"]` so `CongPhap.usable` holds for all 38 sect and cross-owner holders.
3. **`pine-wave-true-canon` keeps `names: ["moc", "thuy"]`**: The canon carries `gathering-wave` (`element: "water"`) and `the-wave-comes-back` (`element: "water"`), so `lint_techniques.py` requires `"thuy"` alongside `"moc"`. Elder `tan_mac_bach` (`moc 52, kim 44, tho 30`, no `thuy`) fails `CongPhap.usable` here as a pre-existing root/canon mismatch in `tung_dao.2.cast.json`; left untouched and logged under Open Items.
4. **`startled-goose-step` omits `swallow-stance` from staged `abilities`**: [swallow-stance](file:///C:/Users/xphuo/IdeaProjects/my-game/design/arts/family-wind.json) has `element: "wind"`, which would fail `lint_techniques.py`'s `ELEMENT` check unless `"phong"` were added to `names`, which would break `CongPhap.usable` for `thoi_khinh_hong` (`moc`/`thuy`, no Wind). Leaving `swallow-stance` in `tung_dao.techniques.json` as depth background and staging `the-goose-rises-from-the-reeds` + `the-white-wolf-falls` keeps the method legal and keeps `thoi_khinh_hong` on her single Wood stance (`rooted-form`).
5. **Two new Yellow stand-in techniques for `tap_dich` servants**: Replaced `hoang_hoa` with `hearth-simmer-breath` (`names: ["hoa"]`, `simmered-broth` L1) on kitchen cooks `banh_tao_nhi` (L1, `hoa 44, kim 32`) and `phung_que_chi` (L3, `hoa 38, thuy 30`), and replaced `hoang_kim`/`hoang_tho` with `bark-and-timber-breath` (`names: ["tho"]`, `steady-shoulder` L1) on weaver `sam_chuc_nuong` (L2, `kim 34, tho 32`) and carter `mac_don_moc` (L3, `tho 38, moc 26`). All four match `CongPhap.usable`.
6. **`Still Water` -> `Abbey's Still Water` rename**: `assets/data/combat_effects.json` already defines `"Still Water"` under source `"Đạo Đồ"`. Staging `td-still-water-lamp`'s Effect as `"Abbey's Still Water"` avoids colliding with `put_effects.py` and `depth_gap.py`'s `clash` warning while leaving `tung_dao.items.json` unedited in this pass (rename logged under Open Items).
7. **Non-conflicting Field counters (`Rain Through the Needles`, `Light on the Quay`)**: Every sect elder/founder wearing Field effects also knows `rooted-form` (`state: "rooted"`). Both `rain-through-the-needles` (`pine_rain` counter) and `Light on the Quay` (`own.composed`) run their ticking sustain and durations from counters and only touch `state: "pine-rain"` (`tags: ["field"]`) when `own.state.any == 0`, clearing only `own.state.pine-rain`, so `Rooted Form` is never clobbered.
8. **Non-spatial rewrite for `Moon on Open Water` & `The Wave Comes Back`**: `Moon on Open Water` converts doubled Water range after 2 s still into `own.composed >= 1` granting `+12 % dmg_more` and `+15 % art_speed` on Water arts. `The Wave Comes Back` converts spatial pullback / damage snapshot (since `was_hit` carries raw `amount` without `share` and `heal` scales on `hp_max`) into `wave_hits` (up to 8 hits taken during the 10 s mark) restoring `4 % hp_max` per hit on snapback (when `< 50 %` HP or when the 10 s expire).
9. **Reused shared pending word `technique-effects` (`decision: "build"`)**: Both `Answering Wave` (`unlock_layer: 4`) and `The Fifteenth Layer` (`unlock_layer: 15`) are staged on `pine-wave-true-canon` (`effects`) and in `tung_dao.effects.json`, and verified directly via library-injection probes until the serial build pass wires `tech_layers`.

---

## §B Techniques (`techniques/catalogue-sect-tung_dao.json`)

| ID | Tier | Kind | Elements | Layers | Passive W | Carried Abilities & Effects |
|---|---|---|---|---|---|---|
| `listening-pine-primer` | 0 | `main` | `moc` | 6 | 6.7 / 8 | `seed-of-spring` (L1), `pine-needle-rain` (L2) |
| `pine-wave-true-canon` | 3 | `main` | `moc`, `thuy` | 15 | 29.8 / 32 | `second-spring` (L1), `rooted-form` (L2), `gathering-wave` (L3), `ten-thousand-pines-answer` (L5), `the-wave-comes-back` (L6); Effects: `Answering Wave` (L4), `The Fifteenth Layer` (L15) *(pending `technique-effects`)* |
| `pine-rain-canon` | 2 | `secret` | `thuy`, `moc` | 12 | 19.2 / 24 | `brimming-cup` (L1), `rain-through-the-needles` (L3), `the-road-in-a-dream` (L6) |
| `startled-goose-step` | 2 | `secret` | `moc` | 12 | 21.1 / 24 | `the-goose-rises-from-the-reeds` (L1), `the-white-wolf-falls` (L4) |
| `hearth-simmer-breath` | 0 | `main` | `hoa` | 6 | 5.2 / 8 | `simmered-broth` (L1) |
| `bark-and-timber-breath` | 0 | `main` | `tho` | 6 | 6.4 / 8 | `steady-shoulder` (L1) |

Note on `the-wave-comes-back`: depth file left `unlock_layer` unspecified; staged at `unlock_layer: 6` to keep active technique abilities `<= 6` per `lint_techniques.py`. Note on `pine-wave-true-canon`: carries 5 active abilities (linter note, 0 findings; matches canonical founder method design).

---

## §C Arts (`arts/part-sect-tung_dao.json` — 9 active arts)

| ID | Element | Role | Cost / CD | Depth Prose vs Engine Form & Deviations |
|---|---|---|---|---|
| `pine-needle-rain` | `wood` | `stacks` | `0.03` / `3 s` | `c_art: 1.5`, `debuff: [3, 5]`; `hit_landed` applies `slowed_time` 1 for `2 s` if foe has Water buff/debuff. ID shifted from `needle-rain` to avoid Metal common-art clash. |
| `ten-thousand-pines-answer` | `wood` | `utility` | `0.045` / `10 s` | `c_heal: 0.5`, opens 8 s `pines_window`; each `heal_restored` (`per_pulse: 1`) lays 1 Wood debuff, restores `1.5 %` qi and hits `c: 0.55` scaling `+10 %` per wave (`pines_waves` 10..18). |
| `the-wave-comes-back` | `water` | `heal` | `0.05` / `12 s` | Marks 10 s `wave_mark`, counts hits taken (`wave_hits`, cap 8), restores `4 % hp_max` per hit at `< 50 %` HP or at 10 s. Deviation: hit-count share approximation (no raw-HP `heal` target or spatial pullback). |
| `rain-through-the-needles` | `water` | `utility` | `0.05` / `12 s` | 10 s `pine_rain`: `+1 %` HP & qi/s, `+1` Water debuff/2 s, `stack_dur: 100` (`wood`); sets `pine-rain` `field` state only if `own.state.any == 0`. |
| `the-road-in-a-dream` | `water` | `ward` | `0.035` / `10 s` | `+1` Water buff (`8 s`), `ward_grow: 0.06`, `delay_immune: 2 s`; `per_fight: 1` pulse check cleanses 1 curse & grows ward `0.12` on `sleep`/`charmed`/`silence`/`sealed_meridian`. Out-of-combat travel cultivation omitted as non-combat. |
| `the-goose-rises-from-the-reeds` | `wood` | `utility` | `0.04` / `8 s` | Sets 2 s `goose_evade` (`evade: +100` spent on `evaded`) and `goose_poise` (`dmg_more: 0.30, kind: "art"` cleared on `hit_landed` / `was_evaded` `kind: "art"`). |
| `the-white-wolf-falls` | `wood` | `damage` | `0.09` / `12 s` | `c_art: 2.7` (`empower` `c_mult: 1.35` -> `3.645` if `wolf_regrow`, `rooted`, or `wood >= 4`), `debuff: [3, 6]`, `off_guard` `2 s`. Tuned within `lint_arts` charge/c ceiling (`0.47` charge, `3.13` max c); uses `wolf_regrow` counter from `heal_restored` since engine has no `own.hot_active`. |
| `simmered-broth` | `fire` | `heal` | `0.03` / `5 s` | `c_heal: 0.5`, `buff: [1, 8]` (stand-in art for kitchen cooks). |
| `steady-shoulder` | `earth` | `damage` | `0.03` / `4 s` | `c_art: 1.6`, `buff: [1, 8]` (stand-in art for weaver/carter). |

---

## §D Effects (`effects/tung_dao.effects.json` — 23 Effects)

| Name | Owner / Link | Notes & Deviations |
|---|---|---|
| `Answering Wave` | `pine-wave-true-canon` L4 *(pending)* | `on: "heal_restored"` (`per_pulse: 1`, `scale` `event.share / 0.01`, cap 10) -> `1` Wood debuff + `1` Water buff. |
| `The Fifteenth Layer` | `pine-wave-true-canon` L15 *(pending)* | Banks `fifteenth_waves` (cap 6) from `gathering-wave` & canon firings; on `down` (`per_fight: 1`), opens 6 s `last_act_window` firing `0.4` `phys` + `0.4` `cold` once/s. |
| `Supple as a Swimming Dragon` | `td-wandering-dragon-sash` | `on: "was_hit"` (`cd: 15`), `event.amount >= 6000` (exact 10 % of Thôi Khinh Hồng's `60,348` HP; raw HP threshold because `was_hit` lacks `event.share`) -> heals 50 % `event.amount`, sets `dragon_slipped`. |
| `The Pack Remembers` | `td-white-wolf-fang` | `if foe.status.off_guard >= 1`: `mod: {pen: 150, element: "wood"}` (15 % on 1000-pt scale -> strong resistance penetration in engine points). |
| `Hear It Coming` | `td-listening-robe` | Opening 15 s (`hear_ticks`) `status_immune` (`sleep`, `charmed`, `bound`, `off_guard`) + `delay_immune` (duration ward because engine emits no blocked-status event). |
| `One Stick of Listening` | `td-pine-heart-censer` | `not_run` (out-of-combat seasonal cultivation). |
| `Abbey's Still Water` | `td-still-water-lamp` | `on: "pulse"` (`cd: 10`) -> `next_art_cost: 0` (`element: "water"`). Renamed to avoid clash with Đạo Đồ `"Still Water"`. |
| `The Ninth Bend` | `td-nine-bend-ring` | Counts Water `art_fired` (`bend_count`); at 9 -> `free_hit c: 1.1 dtype: "cold"` + `ninth_bent`. |
| `Roots Under the Field` | `td-coiled-root-banner` | `foe.composed` for 2 pulses -> `off_guard` `1.0 s` (`cd: 10`). |
| `Cool the Burn` | `td-pine-rain-fan` | `on: "heal_restored"` (`per_pulse: 1`) if `own.debuff.fire >= 1` -> `cleanse` `1` Fire stack. |
| `Heard Once` | `td-clear-sound-zither` | `not_run` (out-of-combat voice learning speed). |
| `Crack the Ice` | `td-broken-ice-flags` | `foe.composed` >= 3 pulses -> `off_guard` `2.0 s` (`cd: 6`) + `1` Water debuff/s (`ice_chill` flag). |
| `Moon on Open Water` | `td-moon-lake-mirror` | Non-spatial: while `own.composed >= 1`, Water arts get `+12 % dmg_more` and `+15 % art_speed`. |
| `The Sea Answers` | `td-pine-regalia` (3p) | While `own.composed >= 1`: every 3 s heals `2 %`, lays `1` Wood debuff, fires escalating `free_hit` (`0.15 * sea_wave`), wave 6+ burns `2 %` max qi; resets on move. |
| `Hold the Quay` | `td-cold-ford-charge` (2p) | While `own.composed >= 1`: `dampen_taken: 12`, `status_dur: 100` (`curse` tag). |
| `Light on the Quay` | `td-cold-ford-charge` (3p) | While `own.composed >= 1`: `+1 %` heal/s + `slowed_time` on foe; 2 pulses with `foe.status.off_guard >= 1` -> `free_hit c: 1.2 phys`. |
| `Ferry Across` | `td-ferryman-remedy` (2p) | `on: "heal_restored"` (`cd: 6`) below 50 % HP -> cleanses `1` Wood debuff (engine Poison) + grants `1` Wood buff. |
| `The Last Bridge` | `td-cut-bridges` (2p) | First hit dropping foe `< 50 %` HP -> `off_guard` `1.0 s` + `next_sword_crit` (`sure_crit: 1, tags: ["sword"]`). |
| `Light as a Startled Goose` | `td-goose-and-dragon` (3p) | On `dragon_slipped` -> 4 pulses of `1 %` HP heal + `off_guard` `1.0 s` on attacker. |
| `The River Keeps Its Bed` | `td-still-water-relics` (3p) | Water `art_fired` with `event.cost == 0` adds `+1` extra `bend_count`; when `ninth_bent` fires, `gain_qi: 0.03`. |
| `Voice in the Rain` | `td-rain-over-long-lake` (3p) | While `pine_rain` or `field_up` -> `heal_restored` grants `+1` Water buff + `1 %` qi; below 34 % HP grants `healing: +25`. |
| `Keep Singing` | `td-unwritten-score` (3p) | Wood `art_fired` within `3.5 s` (`song_gap`) adds `song` (`each_for: 8`, cap 10): `+2 %` Wood `art_speed` & `+3` `soul_res` each; at `>= 4`: `status_immune` `silence` & `soul_taken` spends 4 `song` to heal `100 %` `event.amount`. |
| `Ground Set Before` | `td-ice-breaker-array` (3p) | Opening 5 s (`open_5`) `status_dur: +50` (`curse`); if Field/Ice flags/foe cursed and `foe.curses` >= 3 pulses -> `off_guard` `1.5 s` + `1` Water debuff (`cd: 10`). |

---

## §E Items & Sets (`items/catalogue-sect-tung_dao.json` & `sets-tung_dao.json`)

- **27 items** (6 `dao_bao`, 3 `an`, 3 `ngoc_boi`, 2 `nhan`, 2 `dang`, 2 `ky`, 2 `cham`, 2 `phi_kiem`, 1 `ho_lo`, 1 `huong_lo`, 1 `phien`, 1 `cam`, 1 `kinh`, 1 `thuan`, 1 `giap`). Note: `td-wandering-dragon-sash` staged as `kind: "treasure"`, `rarity: 5` (no `grade`). All 16 `weapon`/`body_gear`/`ward_gear` items carry the R6 `exception`. All items have `sources: ["npc"]`, `unique: true`.
- **9 sets**: `td-pine-regalia`, `td-cold-ford-charge`, `td-ferryman-remedy`, `td-cut-bridges`, `td-goose-and-dragon`, `td-still-water-relics`, `td-rain-over-long-lake`, `td-unwritten-score`, `td-ice-breaker-array`. All checked via `sect_fight.py`.

---

## §F Verification: `sect_fight.py tung_dao` + Targeted Probes

### Selected Holders (`sect_fight.py tung_dao`, 20 seeds vs same-realm typical foe)
| Holder | Realm | Win / 20 | Mean s | HP left | Key Observed Firing / Effects |
|---|---|---:|---:|---:|---|
| `thoi_khinh_hong` | `hoa_than` | 20 | 64.1 | 85% | `ten-thousand-pines-answer` 6.0, `the-wave-comes-back` 5.0, `the-goose-rises-from-the-reeds` 8.0 |
| `dam_tung_lai` | `nguyen_anh` | 20 | 34.3 | 100% | `Hear It Coming` 320 runs; `The Sea Answers` 676 runs; `ten-thousand-pines-answer` 2.9, `the-wave-comes-back` 2.2 |
| `nhiep_co_tan` | `nguyen_anh` | 20 | 33.4 | 100% | `Roots Under the Field` **669** runs (**33.4 s vs 33.7 s**) |
| `du_tinh_luu` | `nguyen_anh` | 20 | 33.5 | 100% | `Abbey's Still Water` 78 runs (**33.5 s vs 33.9 s**); `The Ninth Bend` 608 runs (**33.5 s vs 34.5 s**); `The River Keeps Its Bed` 136 runs (**33.5 s vs 33.9 s**) |
| `ho_tung_nguyet` | `ket_dan` | 20 | 30.4 | 100% | `ten-thousand-pines-answer` 2.0, `the-wave-comes-back` 2.0 |
| `vi_thanh_am` | `ket_dan` | 20 | 62.5 | 97% | `Keep Singing` 648 runs (**97% vs 94%** HP left) |
| `can_tung_han` | `ket_dan` | 20 | 31.2 | 100% | `Crack the Ice` 651 runs; `Ground Set Before` 738 runs (**0 errors**) |
| `thieu_lang_ba` | `ket_dan` | 20 | 30.6 | 99% | `Moon on Open Water` (**30.6 s / 99% vs 30.5 s / 100%**); `on: "always"` so `plog` count 0 |
| `nhiep_van_dao` | `truc_co` | 20 | 21.7 | 100% | `The Last Bridge` 20 runs (**21.7 s vs 21.4 s**) |
| `dam_thanh_giang` | `truc_co` | 20 | 22.7 | 99% | `seed-of-spring`, `rooted-form`, `second-spring` |
| `trinh_van_thanh` (+28 outer) | `luyen_khi` | 20 | 20.2 | 100% | `pine-needle-rain` 6.2 fires |
| `banh_tao_nhi`, `phung_que_chi` | `luyen_khi` | 0 | 44.8 | 0% | `simmered-broth` 8.1 fires (non-martial cook breath vs full combat foe) |
| `sam_chuc_nuong`, `mac_don_moc` | `luyen_khi` | 0 | 41.9–42.0 | 0% | `steady-shoulder` 9.5 fires (tier-1 servant breath) |

### Targeted Probes (verifying slot-overflow arts, pending technique Effects, and conditional triggers)
1. **`pine-needle-rain` vs Water foe** (`trinh_van_thanh` vs `luyen_khi` Water caster): `pine-needle-rain-slow` fired **30** times over 3 seeds, applying `slowed_time` to foe (`9 s, 12 s, 15 s`).
2. **`rain-through-the-needles` + `the-road-in-a-dream` + `Cool the Burn` + `Voice in the Rain`** (`ho_tung_nguyet` vs Fire+Sleep caster): `pine-rain-open` **20**, `pine-rain-stance` **20**, `pine-rain-pulse` **171**, `pine-rain-foe-wet` **83**, `dream-road-wake` **5** (once per seed), `dream-road-ward` **25**, `Cool the Burn` **35**, `Voice in the Rain feed` **18**.
3. **`the-white-wolf-falls` + `Supple as a Swimming Dragon` + `Light as a Startled Goose` + `The Pack Remembers`** (`thoi_khinh_hong`):
   - Vs heavy `hoa_than` boss (`c_art 35.0`): **WITH both**: `1/5` wins (`17.7%` HP, `Supple` 9 runs, `Startled Goose` 9+36 runs) vs **NO `Supple`**: `0/5` wins (`0%` HP), **NO `Startled Goose`**: `0/5` wins (`0%` HP).
   - Vs high Wood-res tank (`the-white-wolf-falls` -> `off_guard` + Wood hit at `11,206 ms`): **WITH `The Pack Remembers`** dealt **`611.39`** vs **WITHOUT**: **`458.73`** (**+33.3 %** post-mitigation Wood damage).
4. **`ten-thousand-pines-answer` + `the-wave-comes-back`** (`dam_tung_lai` vs heavy Metal hitter): `pines-open` **7**, `pines-wave-stack` **20**, `pines-wave-hit` **20**, `wave-mark-set` **5**, `wave-mark-hit` **44**, `wave-return-end` **4**, `wave-return-early` **1**.
5. **`Answering Wave` & `The Fifteenth Layer`** (`dam_tung_lai` with injected Effects & L15):
   - `Answering Wave`: **63** runs over 3 seeds, cutting mean kill time from **`33.71 s` -> `31.24 s`**.
   - `The Fifteenth Layer` (vs `c_art 35.0` killer): fired banked `0.4` `phys` + `0.4` `cold` waves at `39 s, 40 s, 41 s, 42 s` while untargetable until `down` at `42 s`.
6. **`Hear It Coming`** (`dam_tung_lai` vs `sleep`+`off_guard` caster): **WITH**: first statuses delayed to `16,000 ms` (`59.82 s` mean) vs **WITHOUT**: landed at `4,000, 8,000, 12,000 ms` (`60.15 s`).
7. **`Ferry Across`** (`dam_thanh_giang` vs `c_art 14.0` Wood poisoner): triggered below 50 % HP (`eff:Ferry Across`: **1** run).
8. **`The Last Bridge`** (`nhiep_van_dao` with `flying-sword-strike`): `The Last Bridge arm`: **5**, `spent`: **5** (`15.86 s` vs `15.90 s`).
9. **`Hold the Quay` + `Light on the Quay`** (`nhiep_co_tan` holding all 3 pieces incl. `td-ford-governor-lantern` vs slow foe): `Roots Under the Field snap`: **7**, `Light on the Quay`: **63**, `Light on the Quay strike`: **6**.
10. **`Keep Singing`** (`vi_thanh_am` vs Soul + Silence caster): `Keep Singing start`: **60**, `chain`: **105**, `absorb`: **35** (`0` `silence` statuses landed).

---

## §G Pending Words & Open Items

### Pending Words (`design/stage6-staging/tung_dao/pending.json`)
- **`technique-effects`** (`decision: "build"`, reusing `thien_xu` / batch approval): Needed by `pine-wave-true-canon`'s `Answering Wave` (L4 passive art) and `The Fifteenth Layer` (L15 rule_change). Both are staged in `effects/tung_dao.effects.json` and listed on `pine-wave-true-canon.effects`.

### Open Items for Serial / Follow-Up Passes
1. **Rename `"Still Water (Tĩnh Thủy)"` in `tung_dao.items.json`**: Left unedited per brief (`tung_dao.items.json` untouched). Updating `td-still-water-lamp`'s `effect.name` to `"Abbey's Still Water (Tĩnh Thủy)"` in [tung_dao.items.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/tung_dao.items.json) closes `depth_gap.py`'s `clash 1` warning at merge.
2. **Pre-existing `tan_mac_bach` root mismatch**: `tan_mac_bach` (`moc 52, kim 44, tho 30`, no `thuy`) knows `pine-wave-true-canon` (`names: ["moc", "thuy"]`) in `tung_dao.2.cast.json`; fails `CongPhap.usable` unless given a minor Water root or shifted off `gathering-wave`/`the-wave-comes-back`.
3. **Slot competition & 5-art canon**: `pine-wave-true-canon` + 1 body/secret method leaves 0 room for weapon common arts (`nhiep_van_dao`'s `td-bridge-cutter` -> `flying-sword-strike` for `The Last Bridge`) and overflows `thoi_khinh_hong` / `ho_tung_nguyet` past the 6-slot build cap (`sect_fight.py` truncates to first 6).
4. **Out-of-combat Effects (`not_run`)**: `One Stick of Listening` (`td-pine-heart-censer`) and `Heard Once` (`td-clear-sound-zither`) remain unsimulated outside fights.
