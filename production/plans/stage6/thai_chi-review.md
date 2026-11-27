# Stage 6 Record Pass Review — Thải Chi Cốc (`thai_chi`)

**Date**: 2026-11-27
**Owner**: `thai_chi`
**Status**: Staged cleanly under `design/stage6-staging/thai_chi/`; all three linters (`lint_arts.py`, `lint_techniques.py`, `lint_items.py`) report `0` findings, `engine.validate` passes standalone on all `5` staged Effects, `depth_check.py --quiet` reports `findings: none`, `depth_gap.py --sect thai_chi` reports `clash: 0`, `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, and `sect_fight.py thai_chi --seeds 5` (`--gap 0` and `--gap 1`) plus targeted probes verify every active art, passive Effect, item Effect, and set bonus.

---

## Summary

- **Techniques staged (`techniques/catalogue-sect-thai_chi.json`)**: `4` (`lingzhi-pickers-song`, `shang-mountain-lingzhi-canon`, `hundred-herbs-tasting`, `grain-rain-canon`). All bonuses and passives are newly sized against their tier budgets (`8 / 24 / 16 / 24 W`).
- **Arts staged (`arts/part-sect-thai_chi.json`)**: `4` new active arts (`weeding-hand`, `lingzhi-spores`, `taste-and-name`, `grain-rain`), alongside `3` existing `family-wood.json` references (`seed-of-spring`, `harvest-bloom`, `second-spring`) and `1` passive art (`bitter-medicine`, `d33`) promoted as technique Effect `"Bitter Medicine (Khổ Dược)"` on `hundred-herbs-tasting`.
- **Effects staged (`effects/thai_chi.effects.json`)**: `5` (`Bitter Medicine`, `Cut to the Root`, `The Herbs Stay Alive`, `Banked Coals`, `Rain on the Sown Field`). Existing shared Effect `"The Empty Mountain's Answer"` (`d5`, already in `assets/data/combat_effects.json` under `source: "world-depth:thuy_vi"`) is referenced by name on `tc-purple-lingzhi-gourd` without duplicating or overwriting `thuy_vi`'s entry.
- **Items & sets staged (`items/catalogue-sect-thai_chi.json`, `items/sets-thai_chi.json`)**: `4` unique signature items (`tc-purple-lingzhi-gourd` treasure `rarity: 5`, `tc-cinder-censer` artifact grade 3, `tc-grain-rain-fan` artifact grade 3, `tc-terrace-bell` artifact grade 3; `3` `weapon`/`ward_gear` bases carry the R6 `exception` mark) and `1` 3-piece set (`tc-herb-terraces`).
- **Stand-ins & beasts**: `0` stand-ins, `0` beasts, `0` early promotions.
- **Pending words**: `0` (all required mechanics — `strip`, `foe.buff_elements`, `tick_to_heal`, `heal_overflow`, `pill_burned`, `refresh`, `refuse_down`, `technique-effects`, self-debuff `stacks {side: "own", kind: "debuff"}` — are already in both engines).
- **Deviations**: `3` (`The Herbs Stay Alive` smoke-pill approximation + out-of-fight herb preservation omitted from combat; `taste-and-name` Chaos resistance scalar `+25` per cleansed Wood debuff; `lingzhi-spores` explicit `3`-pulse counter model).
- **Never ran in default `sect_fight.py` (all verified in targeted probes)**: `Bitter Medicine` (needs a Poison/Wood-debuff foe), `The Herbs Stay Alive` (needs a prepared `pill` + `burn_pill` art), `Cut to the Root` (unlock layer 12; highest living cast holder `nghiem_linh_chi` is layer 9), and `weeding-strip` sub-record inside `weeding-hand` (needs a buff-laying foe). `grain-rain` fired `3.0-3.4` times/fight at `--gap 0`, and `0.0` at `--gap 1` only because the `cooldown: 9.0` s opening timer exceeded the `9-11 s` one-realm-up defeat window.
- **Open items**: serial step merge of `design/stage6-staging/thai_chi/*` into `design/` and `assets/data/combat_effects.json`, followed by Stage 7 world/record export (`4` structured events in `events/thai_chi.events.json` close on export).

---

## A. Decisions Auto-Accepted

1. **Shared Effect `The Empty Mountain's Answer` (`d5`) referenced from `world-depth:thuy_vi` (`tc-purple-lingzhi-gourd`)**:
   - **Choice**: Do not duplicate `"The Empty Mountain's Answer"` in `effects/thai_chi.effects.json`; reference `"The Empty Mountain's Answer"` by plain English name in `items/catalogue-sect-thai_chi.json` and change `"new": true` -> `"new": false` on `tc-purple-lingzhi-gourd`'s reference in `design/world/depth/sects/thai_chi.items.json`.
   - **Reason**: `thuy_vi` (`b01`) already merged `"The Empty Mountain's Answer"` into `assets/data/combat_effects.json` (`source: "world-depth:thuy_vi"`). Under ADR-0009 decision 3 and `put_effects.py`, a second owner cannot overwrite another owner's key, and leaving `"new": true` in `thai_chi.items.json` caused a false `clash` in `depth_gap.py`. Clearing `"new": false` keeps the record linked cleanly to the live `heal_overflow` Effect (`264` runs on `nghiem_linh_chi`).
2. **Passive art `Bitter Medicine` (`d33`) & Layer-12 promise `Cut to the Root` via `technique-effects`**:
   - **Choice**: Attach `Bitter Medicine (Khổ Dược)` (`unlock_layer: 3`) to `hundred-herbs-tasting.effects` and `Cut to the Root (Đoạn Căn Tái Sinh)` (`unlock_layer: 12`) to `shang-mountain-lingzhi-canon.effects` (honoring the concept text *"at the twelfth layer let her come back once from a killing blow"*), with both engine records in `effects/thai_chi.effects.json`.
   - **Reason**: `technique-effects` landed in `b01`, so both passive Effects attach automatically in `sect_fight.py` and the game at their unlock layers without taking an active art slot.
3. **`The Herbs Stay Alive` (`tc-purple-lingzhi-gourd`)**:
   - **Choice**: Out-of-fight herb/pill preservation is unmodelled in combat; in-fight *"the first pill you take each fight heals half again as much, and its Wood stacks do not fade while the gourd is open"* is modeled on `on: "pill_burned"` (`limit: {"per_fight": 1}`) as `+50` `healing` for `6.0` s plus `refresh {el: "wood", side: "own", kind: "buff", hold: true}` and `refresh {el: "wood", side: "foe", kind: "debuff", hold: true}` (marked `approx`).
   - **Reason**: Per `DECISIONS-2026-11-26.md` (Pill Smoke), fight pills are smoke-only for now (`burn_pill` -> `pill_burned`, no pill healing amount yet), so boosting `healing` by `50 %` on `pill_burned` and holding Wood stacks preserves the build intent with existing engine words.
4. **`Weeding Hand` (`weeding-hand`) buff-strip counting**:
   - **Choice**: Gate the strip on `foe.buff_elements >= 1` (`hit_landed`) before running `strip {n: 1}` + incrementing `weeded_buffs`, and give the art a base `c_art: 0.8` + `c_heal: 0.4` plus `1 %` max-HP heal per `weeded_buffs`.
   - **Reason**: `strip` emits no event of its own when `o.buffs` is empty; checking `foe.buff_elements >= 1` ensures `weeded_buffs` counts only real stripped buffs while `c_art: 0.8` / `c_heal: 0.4` ensures the outer-gate art still participates meaningfully against buffless foes.
5. **`Taste and Name` (`taste-and-name`) & `Grain Rain` (`grain-rain`)**:
   - **Choice**: `taste-and-name` checks `own.debuff.wood >= 1` to increment `tasted_wood` BEFORE `cleanse {n: 1, el: "wood"}`, granting `+25` Chaos `resist` per stack; `grain-rain` uses an explicit `pulse` countdown counter (`grain_rain: 6` -> `-1` per pulse) and `state: "grain-rain"` (`tags: ["field"]`) rather than `decay_per_pulse: 1`, and grows foe Wood stacks when `foe.debuff.wood >= 1`.
   - **Reason**: Avoids `decay_per_pulse: 1` off-by-one before `pulse` and cleanly syncs with `Rain on the Sown Field` (`own.state.grain-rain >= 1`), while `Rain on the Sown Field` declares `lingzhi_spores` in its own `counters` for standalone `test_every_library_effect_compiles` parity.
6. **`tc-purple-lingzhi-gourd` treasure schema & R6 signature exceptions**:
   - **Choice**: Convert `thai_chi.items.json`'s `kind: "treasure", grade: 4` to `kind: "treasure", rarity: 5` (without `grade`) per `lint_items.py`; mark all `4` items `sources: ["npc"]`, `unique: true`, and put the R6 `exception` on the `3` weapon/ward_gear pieces (`tc-purple-lingzhi-gourd`, `tc-grain-rain-fan`, `tc-terrace-bell`), omitting it on `tc-cinder-censer` (`huong_lo`, utility).
   - **Reason**: Matches `lint_items.py` schema and `bang_tam`/`thuy_vi` precedents.

---

## B. Mechanic Classification Table

| Kind | Record | Engine Word State | Implementation Summary |
|---|---|---|---|
| Tech | `lingzhi-pickers-song` | `has` | Tier 0 main (`["moc", "thuy"]`), 6 layers, 0 bonuses; new passives: `health_regen_inc_pct 8`, `linh_luc_regen_inc_pct 4`, `healing_pct 4` (7.6 / 8 W) + `herb_growth_pct 6`. |
| Tech | `shang-mountain-lingzhi-canon` | `has` | Tier 2 main (`["moc", "thuy"]`), 12 layers, 2 bonuses (`khi_huyet_pct 12`, `herb_growth_pct 20`); new passives 24.0 / 24 W; `harvest-bloom` (1), `lingzhi-spores` (2), `second-spring` (4); L12 Effect `Cut to the Root`. |
| Tech | `hundred-herbs-tasting` | `has` | Tier 1 secret (`["moc"]`), 9 layers, 1 bonus (`khi_huyet_pct 10`); new passives 15.8 / 16 W + `dan_doc_resist_pct 10`; `taste-and-name` (1); L3 Effect `Bitter Medicine` (d33). |
| Tech | `grain-rain-canon` | `has` | Tier 2 secret (`["thuy", "moc"]`), 12 layers, 2 bonuses (`herb_growth_pct 22`, `linh_luc_pct 12`); new passives 24.0 / 24 W; `grain-rain` (1). |
| Art | `weeding-hand` | `has` (`strip`, `foe.buff_elements`, `heal`) | Wood utility (`c_art 0.8`, `c_heal 0.4`, `cost_share 0.03`, `cd 5`); strips 1 buff when `foe.buff_elements >= 1`, tracks `weeded_buffs`, heals `1 %` HP per `weeded_buffs`. |
| Art | `lingzhi-spores` | `has` (`debuff`, `stacks`, `heal`) | Wood stacks (`c_art 1.0`, `debuff [2, 6]`, `cost_share 0.04`, `cd 5`); seeds 3 `lingzhi_spores` on hit; each pulse ripens 1 into 1 Wood debuff (6 s) + `1.5 %` HP heal. |
| Art | `taste-and-name` | `has` (`cleanse`, `resist`) | Wood utility (`c_art 0.0`, `cost_share 0.03`, `cd 6`); records `tasted_wood` if `own.debuff.wood >= 1` before cleansing 1 Wood debuff; `+25` Chaos `resist` per `tasted_wood`. |
| Passive Art | `bitter-medicine` (`d33`) | `has` (`tick_to_heal`) | Attached via `hundred-herbs-tasting` L3; `on: "always"`, `own.debuff.wood < 10` -> `tick_to_heal: 50` (`element: "wood"`). |
| Art | `grain-rain` | `has` (`state` Field, `heal`, `stacks`) | Water Field (`c_art 0.0`, `c_heal 0.5`, `cost_share 0.05`, `cd 9`), 6 s duration; `2.5 %` HP heal/s + `1` Wood stack (6 s) if `foe.debuff.wood >= 1`. |
| Effect | `Cut to the Root` | `has` (`down`, `refuse_down`) | `shang-mountain-lingzhi-canon` L12; `per_fight: 1` on `down` -> `refuse_down {hp_share: 0.15}`. |
| Effect | `The Herbs Stay Alive` | `decision` (`pill_burned`, `refresh`) | `tc-purple-lingzhi-gourd`; `per_fight: 1` on `pill_burned` -> `+50` `healing` for `6` s + `refresh {hold: true}` on own Wood buffs & foe Wood debuffs (`approx`). |
| Effect | `The Empty Mountain's Answer` | `has` (`world-depth:thuy_vi`) | Referenced by name on `tc-purple-lingzhi-gourd` (`heal_overflow` already live). |
| Effect | `Banked Coals` | `has` (`art_fired`, `status_applied`, self-debuff) | `tc-cinder-censer`; `per_fight: 1` on Fire `art_fired` -> 2 self-Burn stacks (4 s) then arms `coal_flare`; next Fire `status_applied` clears `coal_flare` and adds `event.stacks` extra Fire stacks. |
| Effect | `Rain on the Sown Field` | `has` (`own.state.grain-rain`, `refresh`, `heal`) | `tc-herb-terraces` 3pc; while `own.state.grain-rain >= 1`: keeps foe Wood debuffs at `at_least: 6` s and heals `2 %` HP/s while `own.counter.lingzhi_spores >= 1`. |

---

## C. Techniques (`techniques/catalogue-sect-thai_chi.json`)

`lint_techniques.py`: **checked 4 techniques, 0 findings** (notes: `herb_growth_pct` on `lingzhi-pickers-song` and `dan_doc_resist_pct` on `hundred-herbs-tasting` are unpriced out-of-fight keys; `shang-mountain-lingzhi-canon` `24.0 W of 24`, `grain-rain-canon` `24.0 W of 24`). All bonuses and passives below are newly authored and unpriced.

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Arts / Effects (unlock layer) |
|---|---|---|---|---|
| `lingzhi-pickers-song` | Yellow (0) main, `["moc", "thuy"]` | none | `health_regen_inc_pct 8`, `linh_luc_regen_inc_pct 4`, `healing_pct 4`, `herb_growth_pct 6` | `seed-of-spring` (1), `weeding-hand` (2) |
| `shang-mountain-lingzhi-canon` | Earth (2) main, `["moc", "thuy"]` | `khi_huyet_pct 12`, `herb_growth_pct 20` | `khi_huyet_pct 8`, `health_regen_inc_pct 14`, `healing_pct 10`, `stack_effect_pct 12 [moc, debuff]`, `stack_duration_pct 15 [moc, debuff]`, `linh_luc_regen_inc_pct 5` | `harvest-bloom` (1), `lingzhi-spores` (2), `second-spring` (4); Effect `Cut to the Root` (12) |
| `hundred-herbs-tasting` | Profound (1) secret, `["moc"]` | `khi_huyet_pct 10` | `status_resist_pct 20 [poison]`, `resist_pct 120 [chaos]`, `healing_pct 10`, `khi_huyet_pct 6`, `dan_doc_resist_pct 10` | `taste-and-name` (1); Effect `Bitter Medicine` (3) |
| `grain-rain-canon` | Earth (2) secret, `["thuy", "moc"]` | `herb_growth_pct 22`, `linh_luc_pct 12` | `healing_pct 12`, `health_regen_inc_pct 16`, `stack_duration_pct 18 [moc, debuff]`, `stack_effect_pct 16 [moc, debuff]`, `linh_luc_regen_inc_pct 7` | `grain-rain` (1) |

Updated `design/world/depth/sects/thai_chi.techniques.json` with `"id"` fields on all 5 `"new"` art entries.

---

## D. Arts (`arts/part-sect-thai_chi.json`)

`lint_arts.py`: **checked 4 arts in 1 files, 0 findings** (`3` Wood, `1` Water; `4` `engine`).

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `weeding-hand` | Strips one buff from a foe and heals the holder a little for each buff stripped this fight. | Wood (`c_art 0.8`, `c_heal 0.4`, `cost_share 0.03`, `cd 5`); on `hit_landed` when `foe.buff_elements >= 1`, strips 1 buff and adds 1 `weeded_buffs`, healing `1 %` HP per `weeded_buffs`. | none |
| `lingzhi-spores` | Seeds a foe with spores that ripen into Wood stacks over a few seconds; a ripe stack heals the holder when it bursts. | Wood (`c_art 1.0`, `debuff [2, 6]`, `cost_share 0.04`, `cd 5`); `hit_landed` adds 3 `lingzhi_spores`; each `pulse` with `lingzhi_spores >= 1` lays 1 Wood debuff (6 s), heals `1.5 %` HP, and decrements by 1. | Explicit 3-pulse spore counter rather than separate hidden batch timers. |
| `taste-and-name` | Cleanses one poison or Wood debuff from the holder and gives her resistance to that debuff for the rest of the fight. | Wood (`c_art 0.0`, `cost_share 0.03`, `cd 6`); on `art_fired` if `own.debuff.wood >= 1`, increments `tasted_wood` then cleanses 1 Wood debuff; `always` grants `+25` Chaos `resist` per `tasted_wood`. | Resistance fixed at `+25` Chaos resistance per Poison tasted. |
| `grain-rain` | A rain Field for several seconds: while it is up, you heal over time, and the foe's Wood stacks grow by one each second. | Water Field (`c_art 0.0`, `c_heal 0.5`, `cost_share 0.05`, `cd 9`, guard `grain_rain < 1`); enters `grain-rain` (`tags: ["field"]`) for 6 pulses: heals `2.5 %` HP/s and adds 1 Wood debuff (6 s) when `foe.debuff.wood >= 1`. | none |

---

## E. Effects (`effects/thai_chi.effects.json`) & Holder Verification

Standalone parity check (`E.validate` per Effect): **5 / 5 passed**.

### Holder Check (`sect_fight.py thai_chi --seeds 5`)

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Notes |
|---|---|---|---|---|---|
| `nghiem_linh_chi` | `ket_dan` | `harvest-bloom`, `lingzhi-spores`, `second-spring`, `taste-and-name`, `grain-rain` | `32.0 s`, `5/5`, `99%` | `11.0 s`, `0/5`, `0%` | `Empty Mountain` `264` runs (`32.0 s` vs `35.0 s`); `Rain on the Sown Field` `97` runs (`32.0 s` vs `33.0 s`). At `--gap 1`, `grain-rain` (`cd 9.0`) never reached first cast before defeat at `11.0 s`; at `--gap 0`, fired `3.0`/fight. |
| `dieu_tan_dan` | `ket_dan` | `brazier-form`, `flint-volley`, `furnace-heart`, `twin-flame-echo`, `scorch-fist` | `16.0 s`, `5/5`, `79%` | `8.0 s`, `0/5`, `0%` | `Banked Coals` `10` runs (`with 16.0 s` vs `without 15.7 s`); verified in `plog`: `t=2.5s` laid 2 self-Burn stacks on `A`, `t=2.727s` doubled `scorch-fist`'s 2 Fire debuffs on `B` (`+2` extra). |
| `lu_niem_ha` | `truc_co` | `harvest-bloom`, `lingzhi-spores`, `second-spring`, `taste-and-name` | `55.6 s`, `0/5`, `0%` | `8.4 s`, `0/5`, `0%` | Against non-Wood typical foe, `taste-and-name` spends qi with no poison to cleanse; `Bitter Medicine` runs `0` (verified below vs Wood poisoner). |
| `nghiem_kim_ngan` | `truc_co` | `harvest-bloom`, `lingzhi-spores`, `second-spring`, `taste-and-name` | `55.6 s`, `0/5`, `0%` | `8.4 s`, `0/5`, `0%` | Same as `lu_niem_ha`. |
| `mai_thu_dien` | `truc_co` | `harvest-bloom`, `lingzhi-spores`, `second-spring`, `grain-rain` | `36.2 s`, `5/5`, `98%` | `9.0 s`, `0/5`, `0%` | `grain-rain` fired `3.4`/fight at `--gap 0` (`0.0` at `9.0 s` `--gap 1`). |
| `nghiem_bach_truat`, `phung_luc_ngac`, `ong_kho_sam` | `truc_co` | `harvest-bloom`, `lingzhi-spores`, `second-spring` | `61.8 s`, `5/5`, `39%` | `8.4 s`, `0/5`, `0%` | All 3 arts fired (`8.8`, `9.8`, `3.8`). |
| `nghiem_hoi_huong`, `nghiem_hoac_huong`, `nghiem_ngu_vi`, `ung_lo_nhi` | `luyen_khi` | `harvest-bloom`, `lingzhi-spores` | `53.0-53.2 s`, `1/5`, `2%` | `8.0 s`, `0/5`, `0%` | Both arts fired (`7.6`, `7.6`). |
| `nghiem_tuc_doan` | `luyen_khi` | `harvest-bloom` (layer 1) | `35.6 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | `harvest-bloom` fired `5.2`/fight. |
| `nghiem_bac_ha`, `nghiem_xuyen_khung`, `nghiem_ha_kho`, `nghiem_phuc_linh`, `dau_sa_nhi` | `luyen_khi` | `seed-of-spring`, `weeding-hand` | `30.4-30.6 s`, `5/5`, `100%` | `8.0 s`, `0/5`, `0%` | Both arts fired (`5.8-6.0`, `5.6`). |

### Targeted Probes (for Effects / triggers absent on the typical buffless / non-poison / no-pill foe)

- **`Bitter Medicine` + `Taste and Name` (`lu_niem_ha` vs Wood poisoner `truc_co`, 5 seeds)**:
  - With all: `66.0 s`, `5/5 wins`, `20.27%` HP left, `dry_a: never`, `taste-name-learn: 55`, `taste-name-cleanse: 55`.
  - Without `Bitter Medicine`: `66.0 s`, `5/5 wins`, `17.36%` HP left, `dry_a: 63.6`.
  - Without `taste-name` records: `66.0 s`, `5/5 wins`, `20.25%` HP left.
- **`Weeding Hand` strip (`nghiem_phuc_linh` vs `seed-of-spring` buffing foe `luyen_khi`, 5 seeds)**:
  - With `weeding-strip`: `63.0 s`, `5/5 wins`, `67.51%` HP left, `weeding-strip: 54`, `weeding-heal: 54`.
  - Without `weeding-strip`: `63.0 s`, `5/5 wins`, `66.39%` HP left.
- **`The Herbs Stay Alive` (`nghiem_linh_chi` with Wood grade-2 pill + `pill-smoke-ward` vs typical `ket_dan`, 5 seeds)**:
  - With `The Herbs Stay Alive`: `36.0 s`, `5/5 wins`, `100%` HP left, `eff:The Herbs Stay Alive: 5`.
  - Without `The Herbs Stay Alive`: `40.4 s`, `5/5 wins`, `100%` HP left.
- **`Cut to the Root` (`nghiem_linh_chi` at `shang-mountain-lingzhi-canon` layer 12 vs `--gap 1` `nguyen_anh`, 5 seeds)**:
  - With `Cut to the Root`: `12.8 s`, `0/5 wins` (survives +1.8 s after refusing Down once).
  - Without `Cut to the Root`: `11.0 s`, `0/5 wins`.

---

## F. Items & Sets (`items/catalogue-sect-thai_chi.json`, `items/sets-thai_chi.json`)

`lint_items.py`: **checked 4 items, 22 bases, 9 common arts, 0 findings**.
- `tc-purple-lingzhi-gourd`: treasure `rarity: 5` (`61.0 W` unpriced, `unique: true`, `sources: ["npc"]`, R6 `exception`, effects `["The Herbs Stay Alive", "The Empty Mountain's Answer"]`).
- `tc-cinder-censer`: artifact grade 3 (`23.5 W` unpriced, `unique: true`, `sources: ["npc"]`, utility `huong_lo` — no R6 needed, effect `["Banked Coals"]`).
- `tc-grain-rain-fan`: artifact grade 3 (`17.6 W` unpriced, `unique: true`, `sources: ["npc"]`, R6 `exception`).
- `tc-terrace-bell`: artifact grade 3 (`26.8 W` unpriced, `unique: true`, `sources: ["npc"]`, R6 `exception`).
- Set `tc-herb-terraces` (3 pieces): 2pc (`healing_pct 6`, `health_regen_inc_pct 12`), 3pc (`Rain on the Sown Field (Vũ Lạc Bá Điền)`).

---

## G. Stand-ins & Beasts

- Stand-ins: `0` across all `20` cast records (`18` living, `2` dead).
- Beasts: `0`.

---

## H. Open Items

- **Serial step**: merge `design/stage6-staging/thai_chi/` into `design/techniques/catalogue-sect-thai_chi.json`, `design/arts/part-sect-thai_chi.json`, `design/items/catalogue-sect-thai_chi.json`, `design/items/sets-thai_chi.json`, and `assets/data/combat_effects.json` (`put_effects.py`, `5` Effects under `world-depth:thai_chi`).
- **Stage 7 export**: export techniques, named items, sets, combat library, and `4` translated events (`events/thai_chi.events.json`) so `depth_gap.py --sect thai_chi` reaches `0`.
