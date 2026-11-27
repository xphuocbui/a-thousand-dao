# Stage 6 Record Pass Review — `loose-south` (Batch b06)

## Summary

- **Owner**: `loose-south` (`design/world/depth/people/loose-south.*`, loose cultivators of the south — 31 living build-holders across `loose-south.cast.json` and `loose-south.2.cast.json`).
- **Staged totals**: `0` new techniques, `0` new arts, `13` unique items (`10` with R6 `exception`), `5` sets, `8` newly authored Effects (`4` item + `4` set; `Know the Way Out` already exists under `world-depth:thien_xu` and is referenced twice without redefinition, giving `10` item/set Effect references and `9` distinct Effects total), `0` pending engine words, `16` stand-ins replaced (`3` in `loose-south.cast.json`, `13` in `loose-south.2.cast.json`), `1` beast wired (`bat_phe` on `an_thu_son`).
- **Validation**:
  - `lint_items.py` (`items/catalogue-sect-loose-south.json`): `checked 13 items, 22 bases, 9 common arts, 0 findings`.
  - Standalone Effect compile (`E.validate()`): **8/8** pass (`EFFECT_OK`).
  - `CongPhap.usable()` + technique layer bounds across all 31 living cast builds: **`USABLE_AND_LAYERS_OK`** (`0` unusable arts, `0` over-cap layers).
  - `sect_fight.py loose-south --seeds 5 --gap 0` & `--gap 1`: **0 `REFUSED`**; every art fires (`>= 1.0`) at `--gap 0`; `Tempered by Arrows`, `No One Drowns`, `Leave While It Burns`, and `Dark on Dark Water` run on their real holders; all conditional Effects (`The Goat Knows`, `Walked Out of Chiết Kích`, `Know the Way Out`, `No Fare`, `Leave While It Burns` cleanse/expire, and `do_liet_co` with `demonic` `black-wind-blood-sabre`) verified in targeted probes.
  - `depth_check.py --sect loose-south --quiet`: **`findings: none`**.
  - `depth_gap.py --sect loose-south`: `stand_ins: 0`, `unknown_ids: 0`, `engine_words: 0`, `wishes_open: 0`, `ties_unmapped: 0`, `effects: 10 (open 8: rule text 8, runs 2)`.
  - `spatial_words_check.py --sect loose-south`: **0 hits** (manual inspection of `people/loose-south.items.json` caught and adapted `"from range"` on `Dark on Dark Water` / `Tempered by Arrows` and `"Still"` on `No One Drowns`).
  - `stage6_merge.py loose-south --check`: **0 failure(s)** across 3 staged moves (`catalogue-sect-loose-south.json`, `sets-loose-south.json`, `loose-south.effects.json`).

---

## A. Auto-accepted decisions

1. **Effect clash resolution (`Know the Way Out`, `loose-south.items.json`)**:
   - `depth_gap.py` flagged `clash: 2` because `Know the Way Out` (`know-the-way-out`) was marked `"new": true` on both `ls-thu-am-goat-bell` and `ls-unlit-sail`, while `Know the Way Out` is already merged in `assets/data/combat_effects.json` under `world-depth:thien_xu`.
   - Set `"new": false` on both entries in `design/world/depth/people/loose-south.items.json`, referenced `"Know the Way Out"` on both items in `catalogue-sect-loose-south.json`, and did not redefine it in `loose-south.effects.json`.
2. **Cross-owner coordination (`do_liet_co`'s `black-wind-blood-sabre` + `ls-white-wind-hook`)**:
   - `do_liet_co`'s `aux2` technique `black-wind-blood-sabre` is owned and staged by `demonic` (`design/stage6-staging/demonic/`). Per batch `b06` serial plan, left `black-wind-blood-sabre` staged under `demonic` without duplicating or early-promoting it (verified together in Probe 5).
   - `ls-white-wind-hook` (`holder: "do_vo_cuu"`, `thien_xu`) is authored in `catalogue-sect-loose-south.json` so both halves of `ls-hac-phong-hooks` exist in the `loose-south` catalogue without modifying `thien_xu` files.
3. **Non-spatial combat approximations (`Dark on Dark Water`, `Tempered by Arrows`)**:
   - `spatial_words_check.py` only globs `sects/*.items.json`, so manual scan of `people/loose-south.items.json` caught `"from range"` on `Dark on Dark Water` (`ls-unlit-sail`) and `Tempered by Arrows` (`ls-stockade-pair`).
   - Adapted both cleanly for non-spatial 1v1 combat (`no-spatial-fight`): `Dark on Dark Water` grants `decoy {n: 1}` on `fight_start` to avoid the first incoming non-trigger hit; `Tempered by Arrows` triggers on any damaging hit taken (`was_hit` with `event.amount > 0`) and spends `arrow_thunder` stacks on the next `sword` or `saber` hit (`hit_landed`, `tags: ["sword", "saber"]`) for a Lightning `free_hit` (`0.4 c` per stack).
4. **`Still` -> `Composed` rename & companion latch (`No Fare`, `No One Drowns`)**:
   - `sets-loose-south.json` and `loose-south.effects.json` update `"Still"` to `"Composed"` (`own.composed >= 1`) per `DECISIONS-2026-11-26.md`.
   - Since `engine.py` / `effect_runner.gd` have no `own.companions` readable, both `No Fare` (`ls-thuy-khau-stern-lamp`) and `No One Drowns` (`ls-free-crossing`) declare and latch `has_companion` (cap `1`) via `hit_landed` / `was_evaded` (`filter: {"kind": "companion"}`) so each Effect compiles standalone.
5. **Other engine approximations & out-of-fight `not_run`**:
   - `The Goat Knows`: no pre-application stack-refusal hook exists; once per fight (`goat_refused` cap `1`), on `was_hit` or `pulse` when `own.debuff.wood >= 1` or `own.curses >= 1`, cleanses `1` Wood Poison stack or `1` curse.
   - `Walked Out of Chiết Kích`: cleanses `own.debuff.wood` and `own.curses` on `was_hit` / `pulse`, growing stance ward by `2 %` max HP per stack/curse removed; decays ward by `5 %` max HP per `pulse` (`floor: false`); no `escape_channel` stat exists, so while `own.ward_share > 0`, `always` grants `escape +15`.
   - `Leave While It Burns`: `cleansed` and `batch_ended` share a 6 s timed counter (`burn_vanish_cd`, `each_for: 6, cap: 1`, incremented via `"add": 1`); `"cannot be targeted for 1 s"` runs as `decoy {n: 1}` + `mod {evade: 40, for: 1.0}`.
   - `Stamp of Trust` (`ls-false-cloud-seal`): out-of-fight forgery / social inspection rule — marked `not_run` with `records: []`.
6. **R6 item exceptions (`catalogue-sect-loose-south.json`)**:
   - Applied `"exception": "world-depth signature item: its base's common art or ward until an authored one is ruled (review R6)"` to the `10` items whose base carries a common art or ward (`chuong`, `phi_kiem`, `an`, `dao_bao`, `thuan`, `giap`, `mao`, `tien_tieu`), and omitted it on `dang` (`ls-thuy-khau-stern-lamp`), `ky` (`ls-unlit-sail`), and `ngoc_boi` (`ls-thunder-pendant`).
7. **Unified stand-in replacements (`loose-south.cast.json`, `loose-south.2.cast.json`)**:
   - Replaced all 16 stand-in strings with existing merged catalogue techniques matching each cultivator's root elements (`CongPhap.usable()` verified) and build note; matched overlapping descriptions consistently (e.g., both Đào Sa net-needle builds `mao_dinh_lang` & `man_bo_vong` use `duckweed-drift-primer`, both diver builds `uong_tam_pham` & `yen_thuy_hoa` use `pearl-diver-breath`).

---

## B. Pending words

- **None (`0` pending engine words)**. No `pending.json` written.

---

## C. Techniques & Arts

- **`0` new techniques, `0` new arts** (`black-wind-blood-sabre` on `do_liet_co` is owned by `demonic` and staged in `design/stage6-staging/demonic/`).

---

## D. Effects (`design/stage6-staging/loose-south/effects/loose-south.effects.json`)

| Effect Name | Source | Rule Summary | Engine Form & Fidelity |
|---|---|---|---|
| `Know the Way Out` | `ls-thu-am-goat-bell`, `ls-unlit-sail` | Each escape you fail makes the next 10 % likelier; a success clears it | **Existing** (`world-depth:thien_xu`); referenced without redefinition |
| `The Goat Knows` | `ls-thu-am-goat-bell` | First poison or curse stack applied each fight is refused (after out-of-fight warning) | **`approx`**: `goat_refused` (cap `1`) on `was_hit` / `pulse` when `own.debuff.wood >= 1` or `own.curses >= 1` -> `cleanse` `1` Wood stack or `1` curse |
| `No Fare` | `ls-thuy-khau-stern-lamp` | While you have a companion, regain 1 % HP/s | **`approx`**: latches `has_companion` (cap `1`) on companion `hit_landed` / `was_evaded`; `pulse` (`has_companion >= 1`) -> `heal {share: 0.01}` |
| `Stamp of Trust` | `ls-false-cloud-seal` | Forged seal accepted except by holder of true seal | **`not_run`**: `"out-of-fight forgery and social inspection rule, no combat record"`, `records: []` |
| `Dark on Dark Water` | `ls-unlit-sail` | Unseen on water out of fight; first art aimed at you misses | **`approx`** (non-spatial): `fight_start` -> `decoy {n: 1}` |
| `Walked Out of Chiết Kích` | `ls-miasma-walker` (`3pc`) | Poison/curse stacks thicken ward by 2 % HP instead of harm; ward loses 1/20 per s; while holding, escape channel 1/3 shorter | **`approx`**: `was_hit` / `pulse` cleanses Wood/curses and grows stance ward `0.02 * hp` per stack; `pulse` decays `ward_share * 0.05` (`floor: false`); `always` while `own.ward_share > 0` -> `mod {escape: 15}` |
| `Tempered by Arrows` | `ls-stockade-pair` (`2pc`) | Damaging hit taken adds 1 Thunder buff stack (falls 1 per 2 s); next hook strike spends them for extra Lightning strikes | **`approx`** (non-spatial): `was_hit` (`event.amount > 0`) -> `+1` Thunder buff (`8 s`) + `arrow_thunder +1`; `pulse` (`cooldown: 2`) -> `-1` each; `hit_landed` (`tags: ["sword", "saber"]`) -> scaled `free_hit {c: 0.4, dtype: "lightning"}` + clear |
| `No One Drowns` | `ls-free-crossing` (`2pc`) | Companion or Composed regains ward 2 %/s; first time below 1/4 HP heals 15 % | **`approx`**: `pulse` (`has_companion >= 1` or `own.composed >= 1`) -> `ward_grow {share: 0.02, of: "hp"}`; `wounded` (`per_fight: 1`) -> `heal {share: 0.15}` |
| `Leave While It Burns` | `ls-night-rain-stall` (`2pc`) | Curse cleansed or talisman expires -> untargetable 1 s (once per 6 s) | **`approx`**: `cleansed` / `batch_ended` (`burn_vanish_cd == 0`) -> `decoy {n: 1}`, `mod {evade: 40, for: 1.0}`, `burn_vanish_cd +1` (`each_for: 6, cap: 1`) |

---

## E. Items & sets (`catalogue-sect-loose-south.json`, `sets-loose-south.json`)

- **13 unique items** (`sources: ["npc"]`, `unique: true`, `arts: []`, `0` lint findings):
  - `ls-thu-am-goat-bell` (`chuong`, grade 3, `earth`, `khau_bach_thu`, `["The Goat Knows", "Know the Way Out"]`, set `ls-miasma-walker`, R6)
  - `ls-miasma-veil-robe` (`dao_bao`, grade 3, `earth`, `khau_bach_thu`, set `ls-miasma-walker`, R6)
  - `ls-door-shield` (`thuan`, grade 3, `earth`, `khau_bach_thu`, set `ls-miasma-walker`, R6)
  - `ls-black-wind-hook` (`phi_kiem`, grade 3, `thunder`, `do_liet_co`, set `ls-hac-phong-hooks`, R6)
  - `ls-white-wind-hook` (`phi_kiem`, grade 3, `thunder`, `do_vo_cuu`, set `ls-hac-phong-hooks`, R6)
  - `ls-arrow-scarred-armour` (`giap`, grade 3, `metal`, `do_liet_co`, set `ls-stockade-pair`, R6)
  - `ls-thunder-pendant` (`ngoc_boi`, grade 3, `thunder`, `do_liet_co`, set `ls-stockade-pair`)
  - `ls-thuy-khau-stern-lamp` (`dang`, grade 2, `water`, `yen_hoi_do`, `["No Fare"]`, set `ls-free-crossing`)
  - `ls-ferry-anchor` (`mao`, grade 2, `water`, `yen_hoi_do`, set `ls-free-crossing`, R6)
  - `ls-false-cloud-seal` (`an`, grade 2, `wood`, `gian_van_lo`, `["Stamp of Trust"]`, set `ls-night-rain-stall`, R6)
  - `ls-folded-map-robe` (`dao_bao`, grade 2, `wood`, `gian_van_lo`, set `ls-night-rain-stall`, R6)
  - `ls-unlit-sail` (`ky`, grade 2, `water`, `bien_am_pham`, `["Dark on Dark Water", "Know the Way Out"]`)
  - `ls-snare-wire-coins` (`tien_tieu`, grade 2, `metal`, `sam_van_nuong`, R6)
- **5 sets**:
  - `ls-hac-phong-hooks` (2pc: `crit_damage_pct +20 [sword]`, `linh_luc_on_crit_pct +0.6`)
  - `ls-miasma-walker` (2pc: `status_resist_pct +6`, `khi_huyet_pct +6`; 3pc: `Walked Out of Chiết Kích`)
  - `ls-stockade-pair` (2pc: `khi_huyet_pct +6`, `attack_pct +6 [lightning]`, `Tempered by Arrows`)
  - `ls-free-crossing` (2pc: `health_regen_inc_pct +8`, `block_rating +6`, `No One Drowns`)
  - `ls-night-rain-stall` (2pc: `status_duration_pct +6 [curse]`, `evade_pct +2`, `Leave While It Burns`)

---

## F. Stand-ins & Beasts (`loose-south.cast.json`, `loose-south.2.cast.json`)

| File | Person | Replacement Technique | Layer |
|---|---|---|---|
| `loose-south.cast.json` | `do_liet_co` (`main`) | `opening-thunder-canon` | 8 |
| `loose-south.cast.json` | `bien_am_pham` (`main`) | `still-moon-tide-scripture` | 6 |
| `loose-south.cast.json` | `uong_tam_pham` (`main`) | `pearl-diver-breath` | 5 |
| `loose-south.2.cast.json` | `mao_dinh_lang` (`main`) | `duckweed-drift-primer` | 5 |
| `loose-south.2.cast.json` | `pho_ket_thang` (`main`) | `vat-stirring-breath` | 5 |
| `loose-south.2.cast.json` | `man_bo_vong` (`main`) | `duckweed-drift-primer` | 2 |
| `loose-south.2.cast.json` | `cuu_quy_hoa` (`main`) | `seed-and-soil-primer` | 5 |
| `loose-south.2.cast.json` | `moc_tau_vu` (`main`) | `straw-sandal-step-primer` | 4 |
| `loose-south.2.cast.json` | `me_thiem_nhi` (`main`) | `black-toad-venom-manual` | 4 |
| `loose-south.2.cast.json` | `lo_tam_chuy` (`main`) | `nine-temper-scripture` | 4 |
| `loose-south.2.cast.json` | `quan_thap_nhat` (`main`) | `weighing-stone-primer` | 5 |
| `loose-south.2.cast.json` | `phu_hoa_sinh` (`main`) | `yoke-and-axle-breath` | 5 |
| `loose-south.2.cast.json` | `yen_thuy_hoa` (`main`) | `pearl-diver-breath` | 4 |
| `loose-south.2.cast.json` | `dan_tan_lao` (`main`) | `red-sun-scripture` | 6 |
| `loose-south.2.cast.json` | `lien_que_chi` (`main`) | `dew-gathering-breath` | 6 |
| `loose-south.2.cast.json` | `tuyen_dang_nhi` (`main`) | `lingzhi-pickers-song` | 4 |

- **Beast (`1`)**: added `"beasts": ["bat_phe"]` to `an_thu_son` in `loose-south.cast.json`.
- **Remaining stand-ins**: **`0`** (`depth_gap.py --sect loose-south`).

---

## G. Holder check (`sect_fight.py loose-south --seeds 5` + targeted probes)

### Default `sect_fight.py` runs
- **`0 REFUSED`** across all 24 living authored-build holders in `--gap 0` and `--gap 1`; every slotted art fires at `--gap 0` (`>= 1.0` per fight).
- Under `--gap 1`, `bastion-reprisal` (`khau_bach_thu`, `15.4 s`), `open-the-sky` (`do_liet_co`, `12.0 s`), and `flying-blade-retinue` (`loc_bat_quy`, `8.0 s`) show `fires 0.0` (`NEVER_FIRED`) because the holder dies 1 realm above before those arts finish charging / trigger conditions (`1.0`/`1.0`/`2.0` fires at `--gap 0`).

| Effect | Holder(s) | `--gap 0` (5 seeds) | `--gap 1` (5 seeds) | Notes |
|---|---|---|---|---|
| `Tempered by Arrows` | `do_liet_co` | `with 9.3 s 86%` vs `without 13.4 s 64%` (`runs 115`) | `with 12.0 s 0%` vs `without 12.0 s 0%` (`runs 152`) | `-4.1 s` faster kill and `+22 %` HP left at `--gap 0` from Thunder buff stacks + sword/saber Lightning free hits. |
| `No One Drowns` | `yen_hoi_do` | `with 31.8 s 95%` vs `without 31.8 s 94%` (`runs 10`) | `with 15.1 s 0%` vs `without 13.8 s 0%` (`runs 23`) | Composed ward regen + `15 %` wounded save (`+1.3 s` longer survival at `--gap 1`). |
| `Leave While It Burns` | `gian_van_lo` | `with 12.7 s 100%` vs `without 13.1 s 100%` (`runs 5`) | `with 8.8 s 0%` vs `without 8.4 s 0%` (`runs 1`) | Fires on talisman `batch_ended` (and on `cleansed` in Probe 3). |
| `Dark on Dark Water` | `bien_am_pham` | `with 14.5 s 100%` vs `without 15.2 s 100%` (`runs 5`) | `with 16.4 s 0%` vs `without 16.0 s 0%` (`runs 5`) | `decoy` avoids the foe's opening hit at `--gap 0` (`-0.7 s`) and extends survival at `--gap 1` (`+0.4 s`). |
| `The Goat Knows` | `khau_bach_thu` | `runs 0` (`NEVER_RAN`) | `runs 0` (`NEVER_RAN`) | Typical Fire foe deals no Wood poison or curses; verified in Probe 1. |
| `Walked Out of Chiết Kích` | `khau_bach_thu` | `runs 0` (`NEVER_RAN`) | `runs 0` (`NEVER_RAN`) | Typical Fire foe deals no Wood poison or curses; verified in Probe 1. |
| `Know the Way Out` | `khau_bach_thu`, `bien_am_pham` | `runs 0` (`NEVER_RAN`) | `runs 0` (`NEVER_RAN`) | Neither holder slots an escape art in their default build; verified in Probe 4. |
| `No Fare` | `yen_hoi_do` | `runs 0` (`NEVER_RAN`) | `runs 0` (`NEVER_RAN`) | Solo build carries no companion; verified in Probe 2. |
| `Stamp of Trust` | `gian_van_lo` | `runs 0` (`NEVER_RAN`) | `runs 0` (`NEVER_RAN`) | Expected: `not_run` out-of-fight forgery rule. |

### Targeted Probes (5 seeds unless noted)
1. **Probe 1 (`The Goat Knows` + `Walked Out of Chiết Kích` on `khau_bach_thu` vs Wood Poison + curse `ket_dan` foe with `toad-venom-mist`, `fraying-thread`, `ripening-curse`)**:
   - Full build: `t = 9.0 s`, `wins = 5/5`, `hp = 100%`, `eff:The Goat Knows hit curse = 5`, `eff:Walked Out of Chiết Kích hit wood = 7`, `hit curse = 9`, `decay = 25`.
   - Without `The Goat Knows`: `eff:Walked Out of Chiết Kích hit curse` rises from `9` to `14` (`+5`, confirming the first curse was refused by the bell), `hit wood = 7`, `decay = 30`.
   - With `lightning-step` vs `nguyen_anh` Wood/curse foe (10 seeds): `t = 50.4 s`, `eff:The Goat Knows hit curse = 10`, `eff:Walked Out of Chiết Kích hit wood = 88`, `hit curse = 177`, `decay = 297`.
2. **Probe 2 (`No Fare` + `No One Drowns` companion latch on `yen_hoi_do` with `companions: [{"c": 0.4, "dtype": "phys", "cd": 1.0}]`)**:
   - vs `truc_co` (`--gap 0`): `t = 30.0 s`, `wins = 5/5`, `hp = 100%`, `eff:No Fare comp hit = 5`, `eff:No Fare heal = 142`, `eff:No One Drowns ward = 142`.
   - vs `ket_dan` (`--gap 1`): `t = 15.8 s`, `eff:No Fare comp hit = 5`, `eff:No Fare heal = 73`, `eff:No One Drowns save = 5`, `eff:No One Drowns ward = 73`. Without `No Fare`, `eff:No One Drowns comp hit = 5` still latches `No One Drowns` independently (`save = 5`, `ward = 73`).
3. **Probe 3 (`Leave While It Burns` on `gian_van_lo` vs `ket_dan` foe with `cleanse: 3` + `mountain-stance`)**:
   - With `Leave While It Burns`: `t = 38.5 s`, `eff:Leave While It Burns cleansed = 29`. Without `Leave While It Burns`: `t = 30.3 s` (`-8.2 s` shorter survival).
4. **Probe 4 (`Know the Way Out` with synthetic `escape: 0.05` art vs `ket_dan` `typical`)**:
   - `khau_bach_thu`: `eff:Know the Way Out = 22` (`t = 12.5 s`, `wins = 0/5`, `hp = 100%` — escapes 5/5 times once stacked vs `wins = 4/5`, `t = 14.9 s` without it).
   - `bien_am_pham`: `eff:Dark on Dark Water = 5`, `eff:Know the Way Out = 16` (`t = 8.4 s`).
5. **Probe 5 (`do_liet_co` with `demonic` `black-wind-blood-sabre` technique loaded in memory)**:
   - All 6 arts slotted (`stormcloud-familiar`, `storm-bank`, `open-the-sky`, `debt-blade`, `shearing-palm`, `drink-within-a-breath`), `0 REFUSED`:
   - vs `ket_dan` (`--gap 0`): `t = 9.0 s`, `wins = 5/5`, **`hp = 100%`**, `eff:Tempered by Arrows gain = 80`, `decay = 20`, `spend = 15` (vs `86%` HP without the `demonic` aux).
   - vs `nguyen_anh` (`--gap 1`): `t = 11.6 s`, `eff:Tempered by Arrows gain = 106`, `decay = 27`, `spend = 13`.
