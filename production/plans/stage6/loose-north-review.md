# Stage 6 Record Pass Review — `loose-north` (Batch b06)

## Summary

- **Owner**: `loose-north` (`design/world/depth/people/loose-north.*`, loose cultivators of the north — 34 people across `loose-north.cast.json` and `loose-north.2.cast.json`).
- **Staged totals**: `0` new techniques, `0` new arts, `10` unique items (`6` with R6 `exception`), `4` sets, `7` Effects (`3` item + `4` set), `0` pending engine words, `20` stand-ins replaced (`5` in `loose-north.cast.json`, `15` in `loose-north.2.cast.json`), `1` beast wired (`tiem_anh` on `quan_tuyet_tung`).
- **Validation**:
  - `lint_items.py` (`items/catalogue-sect-loose-north.json`): `10` items, all within W budget, **0 findings**.
  - Standalone Effect parity (`engine.validate()`): **7/7** pass with `errors: []`.
  - `sect_fight.py loose-north --seeds 5 --gap 0` & `--gap 1`: **0 `REFUSED`**; `Will Not Fall`, `The Way Out`, and `Never Had a Healer` fire on their real holders; `Thaw`, `Hot Hands`, `Will Not Fall` (`survive` + `heal`), `The Way Out` (`break node`), and `Never Had a Healer` (`overflow`/`decay`/`clear`/`crit`) verified in targeted probes.
  - `depth_check.py --quiet`: **findings: none**.
  - `depth_gap.py --sect loose-north`: `stand_ins: 0`, `unknown_ids: 0`, `engine_words: 0`, `wishes_open: 0`, `ties_unmapped: 0`.
  - `spatial_words_check.py --sect loose-north`: **0 hits** for `loose-north`.
  - `stage6_merge.py loose-north --check`: **0 failure(s)** across 3 staged moves (`catalogue-sect-loose-north.json`, `sets-loose-north.json`, `loose-north.effects.json`).

---

## A. Auto-accepted decisions

1. **Structured wrapping of raw item effect prose (`design/world/depth/people/loose-north.items.json`)**:
   - `ln-old-bronze-lamp` and `ln-thawing-brazier` originally carried raw sentence strings in `items[].effects`. Wrapped both into `{"new": true, "id": "flame-leans", "name": "Flame Leans (Đăng Diễm Khuynh)", "rule": "..."}` and `{"new": true, "id": "thaw-ice", "name": "Thaw the Ice (Dung Băng)", "rule": "..."}` while preserving the exact prose wording and `Thaw (d48)`. Reason: `depth_gap.py` only counts structured `effects[]` entries and requires item effect IDs/names to align cleanly with `loose-north.effects.json`.
2. **Axe-tag approximations (`Will Not Fall`, `Never Had a Healer`)**:
   - Neither `phu` (`mountain-cleave`) nor `lam_da_hac` / `khau_thien_tu`'s weapon techniques carry an `"axe"` tag in `design/`, while `ln-robber-ring` already models axe crit modifiers via `scope: ["physical"]`. Scoped `eff:Will Not Fall heal` and `eff:Never Had a Healer crit` to `dtype: "phys"` (`approx`).
3. **Escape & array-node approximation (`The Way Out`)**:
   - `engine.py` / `effect_runner.gd` have no instant-flee win/exit action without an escape art and no per-node counter on enemy arrays in 1v1 duels: once per fight at `own.hp_share <= 0.3333` (`way_out_used == 0`), sets `mod {escape: 100, for: 10}`; on `hit_landed` (`tags: ["seal"]`) while `foe.field_up >= 1`, applies `1` `sundered` (`6 s`) and delays the foe's next ready art by `0.4 s` (`timer {side: "foe", which: "next", by: 0.4}`).
4. **R6 item exceptions (`items/catalogue-sect-loose-north.json`)**:
   - Applied `"exception": "world-depth signature item: its base's common art or ward until an authored one is ruled (review R6)"` to the `6` items whose `base` has a common art/ward (`phu`, `giap`, `an`, `dao_bao`): `ln-pine-felling-axe`, `ln-lynx-bone-axe`, `ln-bark-hide-vest`, `ln-lock-breaker-seal`, `ln-frost-digger-coat`, `ln-lynx-pelt-armour`. Omitted `exception` on `dang`, `huong_lo`, `nhan`, and `ngoc_boi` (`ln-old-bronze-lamp`, `ln-thawing-brazier`, `ln-robber-ring`, `ln-ember-pendant`).
5. **Cross-owner stand-in selections**:
   - Replaced all 20 stand-ins with existing merged catalogue techniques (including `sand-wall-primer` from `tran_sa`, already merged in `design/techniques/catalogue-sect-tran_sa.json`) matched by root element, tier, and role (`14` in `tiem_anh`/root-matched common/sect methods across `loose-north.cast.json` and `loose-north.2.cast.json`; detailed in Section F).
6. **Out-of-fight rules marked `not_run`**:
   - `Flame Leans` (`ln-old-bronze-lamp`) and `Thaw the Ice` (`ln-thawing-brazier`) describe buried ruin navigation and thawing environmental ice rather than 1v1 combat; recorded with `not_run` and `records: []`.

---

## B. Pending words

- **None (`0` pending engine words)**. No `pending.json` needed or written.

---

## C. Techniques & Arts

- **`0` new techniques, `0` new arts** (`loose-north` uses existing merged techniques; `sand-wall-primer` from `tran_sa` is merged in `design/techniques/catalogue-sect-tran_sa.json`).

---

## D. Effects (`design/stage6-staging/loose-north/effects/loose-north.effects.json`)

| Effect Name | Source | Depth Rule Text | Engine Form & Fidelity |
|---|---|---|---|
| `Flame Leans` | `ln-old-bronze-lamp` | In a sealed or buried place, the lamp's flame leans toward the nearest hollow or door, and it gutters before a live ward or trap array is touched. | `not_run`: `"out-of-fight ruin exploration rule, no combat record"`, `records: []`. |
| `Thaw the Ice` | `ln-thawing-brazier` | Fed with the holder's Fire qi, it thaws a hand's depth of old ice an hour and keeps a frozen hall's air breathable while it burns. | `not_run`: `"out-of-fight ruin exploration rule, no combat record"`, `records: []`. |
| `Thaw` | `ln-thawing-brazier` (`d48`) | Each Fire hit you land removes one Ice stack from you, at most 2 a pulse; each stack removed heals you 0.5 % of your maximum health and gives you one Fire buff stack for 5 s. | **Exact**: `hit_landed` (`element: "fire"`, `own.debuff.ice >= 1`, `per_pulse: 2`) -> `cleanse {el: "ice", n: 1}`, `heal {share: 0.005}`, `stacks {el: "fire", n: 1, for: 5, side: "own", kind: "buff"}`. |
| `Will Not Fall` | `ln-woodcutter-pair` (`2pc`) | Once a fight, a hit that would drop you leaves you standing at 1 health with your body shield full; your next axe hit within 3 s heals you for half its damage. | **`approx`**: `down` (`per_fight: 1`) -> `refuse_down {}`, `shield {refill: 1.0}`, `will_not_fall_heal` (`each_for: 3, cap: 1, add: 1`); `hit_landed` (`dtype: "phys"`, `will_not_fall_heal >= 1`) -> `heal {of: "amount", share: 0.5}` and `add: -1`. |
| `The Way Out` | `ln-digger-kit` (`3pc`) | The Lamp's flame also leans toward the way out in a fight. Once a fight, below a third of your health, you may leave at once; while you stand inside a foe's array, each of your seal hits breaks one of its nodes. | **`approx`**: `was_hit` & `pulse` (`hp_share <= 0.3333`, `way_out_used == 0`) -> `way_out_used = 1`, `mod {escape: 100, for: 10}`; `hit_landed` (`tags: ["seal"]`, `foe.field_up >= 1`) -> `status {sundered, 1, 6 s, foe}` + `timer {foe, next, 0.4}`. |
| `Never Had a Healer` | `ln-bobtail-gear` (`3pc`) | Health your leech would waste on full health becomes a body shield instead, and the shield loses a tenth of itself each second; while that shield holds, your axe crits deal 25 % more damage. | **`approx`**: `heal_overflow` (`source: "leech"`) -> `heal {of: "amount", share: 1.0, body_shield: true}`, `leech_shield_up = 1`; `pulse` -> `body_shield` `-0.1 * own.body_shield_share`, cleared when `body_shield_share <= 0`; `always` -> `mod {crit_mult: 25, dtype: "phys"}` while `body_shield_share > 0`. |
| `Hot Hands` | `ln-thaw-girl-fire` (`2pc`) | Your fist hits lay one Fire stack, and two on a foe that carries Ice stacks or is slowed. | **Exact**: `hit_landed` (`tags: ["fist"]`) -> `stacks {el: "fire", n: 2, for: 6, side: "foe"}` when `foe.debuff.ice >= 1` or `foe.status.slowed_time >= 1`, else `n: 1` when both are `0`. |

---

## E. Items & sets (`items/catalogue-sect-loose-north.json`, `items/sets-loose-north.json`)

- **10 unique items** (`sources: ["npc"]`, `unique: true`, `arts: []`, `0` lint findings):
  - `ln-pine-felling-axe` (`phu`, grade 2, `body`, `lam_da_hac`, R6)
  - `ln-bark-hide-vest` (`giap`, grade 2, `body`, `lam_da_hac`, R6)
  - `ln-old-bronze-lamp` (`dang`, grade 3, `general`, `phan_co_dang`, `["Flame Leans"]`)
  - `ln-lock-breaker-seal` (`an`, grade 3, `water`, `phan_co_dang`, R6)
  - `ln-frost-digger-coat` (`dao_bao`, grade 3, `water`, `phan_co_dang`, R6)
  - `ln-lynx-bone-axe` (`phu`, grade 3, `wood`, `khau_thien_tu`, R6)
  - `ln-lynx-pelt-armour` (`giap`, grade 3, `wood`, `khau_thien_tu`, R6)
  - `ln-robber-ring` (`nhan`, grade 3, `metal`, `khau_thien_tu`)
  - `ln-thawing-brazier` (`huong_lo`, grade 1, `fire`, `du_chuc_nhi`, `["Thaw the Ice", "Thaw"]`)
  - `ln-ember-pendant` (`ngoc_boi`, grade 1, `fire`, `du_chuc_nhi`)
- **4 sets**:
  - `ln-woodcutter-pair` (2pc: `khi_huyet_pct +5`, `body_shield_pct +6`, `Will Not Fall`)
  - `ln-digger-kit` (2pc: `than_thuc_pct +4`, `linh_luc_regen_inc_pct +8`, `attack_pct +6 [seal]`; 3pc: `The Way Out`)
  - `ln-bobtail-gear` (2pc: `leech_health_pct +10`, `crit_damage_pct +12 [physical]`; 3pc: `Never Had a Healer`)
  - `ln-thaw-girl-fire` (2pc: `attack_pct +4 [physical]`, `linh_luc_regen_inc_pct +4`, `Hot Hands`)

---

## F. Stand-ins & Beasts (`loose-north.cast.json`, `loose-north.2.cast.json`)

| File | Person | Root / Tier | Old Stand-in | Replacement Technique | Layer |
|---|---|---|---|---|---|
| `loose-north.cast.json` | `thu_phieu_binh` | `huyen_moc` | `Wood root auxiliary breathing method` | `verdant-cycle-scripture` | 7 |
| `loose-north.cast.json` | `nham_do_han` | `huyen_tho` | `Lone cliff meditation sutra` | `lone-line-sitting-canon` | 5 |
| `loose-north.cast.json` | `cat_chau_nuong` | `huyen_thuy` | `Deep water calm breathing` | `moon-holding-scripture` | 8 |
| `loose-north.cast.json` | `quan_tuyet_tung` | `huyen_moc` | `Frost-pine quiet breathing` | `verdant-cycle-scripture` | 6 |
| `loose-north.cast.json` | `gia_chi_lo` | `hoang_tho` | `Stone road footwork` | `straw-sandal-step-primer` | 5 |
| `loose-north.2.cast.json` | `duong_tam_dao` | `huyen_kim` | `Common forge breathing` | `nine-temper-scripture` | 6 |
| `loose-north.2.cast.json` | `hau_tieu_luc` | `hoang_phong` | `Wind-and-road footwork` | `road-mist-primer` | 3 |
| `loose-north.2.cast.json` | `dinh_van_tac` | `huyen_phong` | `Peak cloud watching sutra` | `idle-cloud-reflection-canon` | 4 |
| `loose-north.2.cast.json` | `lieu_tay_sa` | `hoang_thuy` | `Riverbed quiet breathing` | `brook-wash-breath` | 4 |
| `loose-north.2.cast.json` | `lien_bat_ngu` | `hoang_thuy` | `Lake-ice stillness sutra` | `still-moon-tide-scripture` | 5 |
| `loose-north.2.cast.json` | `luyen_dac_bao` | `hoang_phong` | `Pass-wind travelling breath` | `road-mist-primer` | 3 |
| `loose-north.2.cast.json` | `cu_lo_nhi` | `hoang_thuy` | `Frozen-ferry pole breath` | `ferry-pole-primer` | 3 |
| `loose-north.2.cast.json` | `mach_phuc_linh` | `hoang_moc` | `Wild-root herb breathing` | `seed-and-soil-primer` | 5 |
| `loose-north.2.cast.json` | `bi_tu_nuong` | `hoang_hoa` | `Stove-coal breath` | `warm-hearth-breath` | 4 |
| `loose-north.2.cast.json` | `ngu_bat_te` | `hoang_tho` | `Dry-well earth breath` | `sand-wall-primer` (`tran_sa`) | 5 |
| `loose-north.2.cast.json` | `nhung_tu_dieu` | `hoang_moc` | `Pine-resin steady breathing` | `raft-and-root-primer` | 5 |
| `loose-north.2.cast.json` | `au_van_chieu` | `hoang_tho` | `Old-trail footwork` | `straw-sandal-step-primer` | 2 |
| `loose-north.2.cast.json` | `tuan_tuyet_lien` | `hoang_moc` | `Cold-reed quiet breathing` | `dew-gathering-breath` | 4 |
| `loose-north.2.cast.json` | `yen_luu_huy` | `hoang_tho` | `Hill-salt carrying breath` | `weighing-stone-primer` | 3 |
| `loose-north.2.cast.json` | `mac_than_nuong` | `hoang_hoa` | `Copper-kettle simmering breath` | `hearth-ash-breath` | 2 |

- **Beast (`1`)**: added `"beasts": ["tiem_anh"]` to `quan_tuyet_tung` in `loose-north.cast.json` (`rule text 1`, paired with beast master `quan_tuyet_tung` in `loose-north.beasts.json`).
- **Remaining stand-ins**: **`0`** (`depth_gap.py --sect loose-north`).

---

## G. Holder check (`sect_fight.py loose-north --seeds 5` + targeted probes)

### Default `sect_fight.py` runs
| Effect | Holder(s) | `--gap 0` (5 seeds) | `--gap 1` (5 seeds) | Notes |
|---|---|---|---|---|
| `Will Not Fall` | `lam_da_hac` | `with 15.5 s 67%` vs `without 15.5 s 67%` (`runs 0`) | `with 17.8 s 0%` vs `without 11.4 s 0%` (`runs 10`) | Triggers on lethal blow under `--gap 1`: `survive` (5) + `heal` (5), extending survival by `+6.4 s`. |
| `The Way Out` | `phan_co_dang` | `with 11.7 s 100%` vs `without 11.7 s 100%` (`runs 0`) | `with 14.0 s 0%` vs `without 14.0 s 0%` (`runs 5`) | Escape trigger fires below 1/3 HP under `--gap 1`; array-break rule tested in Probe 3. |
| `Never Had a Healer` | `khau_thien_tu` | `with 21.0 s 100%` vs `without 22.0 s 99%` (`runs 112`) | `with 9.0 s 0%` vs `without 9.0 s 0%` (`runs 17`) | Leech overflow shield + decay + `-1.0 s` faster kill via `+25 %` Physical crit damage (`always` record `eff:Never Had a Healer crit`). |
| `Thaw` | `du_chuc_nhi` | `with 44.0 s 12%` vs `without 44.0 s 12%` (`runs 0`) | `with 8.0 s 0%` vs `without 8.0 s 0%` (`runs 0`) | Typical foe has no Ice arts; verified in Probe 1c against an Ice foe. |
| `Flame Leans` | `phan_co_dang` | `runs 0` (`NEVER_RAN`) | `runs 0` (`NEVER_RAN`) | Expected: `not_run` out-of-fight ruin exploration rule. |
| `Thaw the Ice` | `du_chuc_nhi` | `runs 0` (`NEVER_RAN`) | `runs 0` (`NEVER_RAN`) | Expected: `not_run` out-of-fight ruin exploration rule. |
| `The Wind Lifts the Mist` | `hau_tieu_luc`, `luyen_dac_bao` | `runs 0` (`NEVER_RAN`) | `runs 0` (`NEVER_RAN`) | Existing `vu_an` passive via `road-mist-primer` (`only fires vs Wind-element foe arts`). |

### Targeted Probes
1. **Probe 1 (`Hot Hands` 2pc & `Thaw` on `du_chuc_nhi`, 5 seeds each vs `luyen_khi` `typical`)**:
   - **1a (chilled/slowed foe)**: `du_chuc_nhi` wearing `["ln-thawing-brazier", "ln-ember-pendant"]` with `["rime-needle", "scorch-fist"]` (`ice: 0.5`): `t = 25.0 s`, `wins = 5/5`, `hp = 68%`, `eff:Hot Hands chilled = 41`.
   - **1b (warm foe)**: `du_chuc_nhi` wearing `["ln-thawing-brazier", "ln-ember-pendant"]` with default `["scorch-fist"]`: `t = 39.2 s`, `wins = 5/5`, `hp = 28%`, `eff:Hot Hands warm = 64`.
   - **1c (`Thaw` vs Ice foe)**: `du_chuc_nhi` vs `luyen_khi` foe with `["rime-needle", "scorch-fist"]`: `t = 39.8 s`, `wins = 5/5`, `hp = 49%`, `eff:Thaw = 65`.
2. **Probe 2 (`Will Not Fall` on `lam_da_hac` vs `ket_dan` `typical`, `--gap 1`, 5 seeds)**:
   - `t = 17.8 s`, `wins = 0/5`, `eff:Will Not Fall survive = 5`, `eff:Will Not Fall heal = 5` (`5` survivals + `5` post-refusal Physical heals).
3. **Probe 3 (`The Way Out` array-node break on `phan_co_dang` vs `ket_dan` foe with `lotus-seal-ground` + `scorch-fist`, 5 seeds)**:
   - Slotted `{"lib": "seal-slam"}` alongside `phan_co_dang`'s seal/water build: `t = 11.7 s`, `wins = 5/5`, `hp = 100%`, `eff:The Way Out break node = 10` (`2` array-node breaks per fight).
4. **Probe 4 (`Never Had a Healer` 3pc vs 2pc on `khau_thien_tu` vs `ket_dan` `typical`, `--gap 0`, 5 seeds)**:
   - Full 3pc: `t = 21.0 s`, `wins = 5/5`, `hp = 100%`, `eff:Never Had a Healer overflow = 64`, `eff:Never Had a Healer decay = 43`, `eff:Never Had a Healer clear = 5`, plus active `always` record `eff:Never Had a Healer crit`.
   - 2pc-only (ring removed): `t = 25.8 s`, `wins = 5/5`, `hp = 85%`, `records = {}` (`+4.8 s` slower and `-15%` HP left without the 3pc shield & crit boost + ring crit/leech stats).
