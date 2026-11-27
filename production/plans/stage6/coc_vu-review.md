# Stage 6 Record Pass Review — Cốc Vũ Quán (`coc_vu`)

**Date**: 2026-11-27
**Owner**: `coc_vu`
**Status**: Staged cleanly under `design/stage6-staging/coc_vu/`. All three linters (`lint_arts.py`, `lint_techniques.py`, `lint_items.py`) report `0` findings; standalone `engine.validate` passes on all `4` staged Effects; `depth_check.py --quiet` reports `findings: none`; `spatial_words_check.py` reports `0` hits in staged `coc_vu` files; `sect_fight.py coc_vu --seeds 5` (`--gap 0` and `--gap 1`) plus targeted probes verify every `coc_vu` active art and every Effect on its real holders.

---

## Summary

- **Techniques staged (`techniques/catalogue-sect-coc_vu.json`)**: `3` (`seedling-breath-primer`, `good-rain-canon`, `rite-of-the-grain-rain`). All bonuses and passives are newly sized against their tier budgets (`NOT ASSESSED` with `herb_growth_pct 6` / `7.8 W` combat on Yellow `8 W`; `15.9 / 16 W` Profound; `22.6 / 24 W` Earth).
- **Arts staged (`arts/part-sect-coc_vu.json`)**: `4` new active arts (`plant-the-seedling`, `follows-the-wind-into-the-night`, `when-the-season-comes`, `call-the-grain-rain`). The `2` passive arts of `good-rain-canon` (`Moistens Without a Sound`, `Water Wears the Stone` `d24`) are attached via `technique.effects` (`passive_art: true`) and defined in `effects/coc_vu.effects.json`.
- **Effects staged (`effects/coc_vu.effects.json`)**: `4` (`Moistens Without a Sound`, `Water Wears the Stone`, `The Good Rain Knows Its Season`, `Rain That Does Not Stop`).
- **Items & sets staged (`items/catalogue-sect-coc_vu.json`, `items/sets-coc_vu.json`)**: `4` unique signature items (`cv-rain-calling-banner` treasure `rarity: 5`, `cv-seed-rice-gourd` grade 3, `cv-season-seal` grade 3, `cv-abbess-rain-robe` grade 4; `3` `weapon`/`body_gear` items carry the R6 `exception` mark) and `1` 3-piece set (`cv-grain-rain`).
- **Stand-ins & beasts**: `0` stand-ins across `18` living cast records, `0` beasts, `0` early promotions.
- **Pending words**: `0` (all required mechanics — `heal`, `heal_restored`, `consume`, `cleanse` curses/debuffs, `off_guard`, `upkeep {pool: "hp"}`, `state` Field + combined stance, `free_hit`, `technique-effects` — already exist in both engines).
- **Deviations**: `4` (non-spatial rewrite of `plant-the-seedling`; `Water Wears the Stone` `free_hit` uses `dtype: "phys"` without a `moc` tag parameter; `The Good Rain Knows Its Season` treats wearing `cv-rain-calling-banner` from `10 s` onward as holding the Banner charge; `Rain That Does Not Stop` uses `upkeep {pool: "hp", per_stack: 0.01}` scaled per `10 s` of rain so no reduction applies).
- **Never ran in `sect_fight.py` (all verified or explained)**: Every `coc_vu` active art fired and every `coc_vu` Effect ran across `--gap 0`. Only existing `family-wood.json` `second-spring` showed `0.0` fires on `duong_hao_vu` and `luc_dao_hoa` because its `own.hp_share <= 0.95` guard stayed unmet while their rain/regeneration kept them above `95 %` HP (`--gap 0`) or until sudden burst defeat (`--gap 1`). At `--gap 1` (`8.0–8.4 s` defeat for `luyen_khi` / `truc_co`), `when-the-season-comes` (`cd 7.0`, `buff.wood >= 4`) and `call-the-grain-rain` (`cd 10.0`) could not fire before defeat on the short-lived `truc_co` holders. A targeted low-qi probe verified `call-the-grain-rain`'s HP-upkeep fallback (`pay-hp: 10`, `close: 4`).
- **Open items**: serial step merge of `design/stage6-staging/coc_vu/*` into `design/` and `assets/data/combat_effects.json`, followed by Stage 7 world/record export (`4` structured events in `events/coc_vu.events.json` close on export).

---

## A. Decisions Auto-Accepted

1. **Combined Field + Rooted stance for `follows-the-wind-into-the-night`**:
   - **Choice**: Define `good-rain` (`tags: ["field"]`), `rooted` (mirroring `family-wood.json`), and `good-rain-rooted` (`tags: ["field"]` + `rooted` mods and `suppress`) on `follows-the-wind-into-the-night`, and drive its rain pulses from counter `good_rain` (`6` s), re-merging into `good-rain-rooted` on `pulse` whenever `own.state.rooted >= 1`.
   - **Reason**: `duong_hao_vu`, `luc_dao_hoa`, and `su_van_hoa` carry `verdant-cycle-scripture` (`rooted-form`) alongside `good-rain-canon`. Under the Băng Tâm rule (one stance slot per fighter; an art must define every stance it sets), a combined stance prevents `follows-the-wind-into-the-night` and `rooted-form` from clobbering each other's stance benefits.
2. **Channelled `call-the-grain-rain` via counter rather than stance**:
   - **Choice**: Implement `call-the-grain-rain`'s `4 s` channel via `grain_channel` counter + `grain_hp_cost` (`upkeep {pool: "hp", per_stack: 0.03}`) rather than a stance, cleansing `1` debuff (`cleanse {n: 1}`) and `1` curse (`cleanse {curses: 1}`), laying `off_guard` (`1 s`), and paying `3 %` qi while `qi_share >= 0.03` or `3 %` HP upkeep when `qi_share < 0.03`.
   - **Reason**: All three holders (`duong_hao_vu`, `thoi_tri_tiet`, `ha_tinh_can`) also run `follows-the-wind-into-the-night` (`good-rain`), and `duong_hao_vu` also runs `rooted-form`; using a counter keeps the channel non-clobbering, and `upkeep {pool: "hp"}` prevents self-lethal payment (`pay_keep_health`).
3. **Passive arts of `good-rain-canon` (`Moistens Without a Sound`, `Water Wears the Stone` `d24`)**:
   - **Choice**: Promote both as `technique.effects` (`passive_art: true`, `unlock_layer: 4` and `6`) on `good-rain-canon`, triggered on `heal_restored` (`limit: {"per_pulse": 3}`). `Moistens Without a Sound` grants `1` Wood buff stack (`8 s`); `Water Wears the Stone` fires `free_hit` `phys` `0.15` + `0.01 * own.buff.wood`. (In `coc_vu.techniques.json`, `"id"` was inserted on all `6` `"new"` art dicts.)
   - **Reason**: Matches `technique-effects` (`b01`) and `thai_chi` / `thuy_vi` conventions without consuming active art slots. `when-the-season-comes` unlocks at layer `2` (`<= 6` suite rule) and gates on `own.buff.wood >= 4` and `own.hp_share <= 0.95` so Wood stacks are harvested only when injured rather than wasted at full HP.
4. **Non-spatial `plant-the-seedling` (`seedling-breath-primer`)**:
   - **Choice**: Replace *"at the holder's feet: while the holder stands near it"* with a `3 s` self-counter `seedling` (`c_heal: 0.5`, `1.5 %` HP/s during growth, `4 %` harvest heal on pulse `3`).
   - **Reason**: Per `DECISIONS-2026-11-26.md` (no spatial fight), laid objects become self-counters; `3 s` growth allows a `luyen_khi` holder to complete a full harvest within a `5 s` cooldown cycle.
5. **Banner charge & unreduced health cost (`The Good Rain Knows Its Season`, `Rain That Does Not Stop`)**:
   - **Choice**: In `The Good Rain Knows Its Season`, treat holding `cv-rain-calling-banner` from `10 s` onward as satisfying the Banner charge (`healing -50` for `time < 10`, `heal 1 %` per pulse for `time >= 10`). In `Rain That Does Not Stop`, declare `good_rain`, `rain_seconds`, and `rain_cost` (`upkeep {pool: "hp", per_stack: 0.01}`) in the Effect's own `counters`, refreshing `good_rain = 6` each pulse once started, adding `+10` `healing` and `1` stack of `rain_cost` per `10 s` elapsed.
   - **Reason**: `ky` (Flag) has no separate charge field in `bases.json`, so wearing the Banner satisfies the charge cleanly; `upkeep {pool: "hp"}` directly subtracts `1 %` HP per stack per pulse with zero reductions (matching *"nothing reduces that cost"*), and declaring `good_rain` in `Rain That Does Not Stop`'s own `counters` satisfies standalone `test_every_library_effect_compiles`.
6. **Treasure schema & R6 signature item exceptions**:
   - **Choice**: Convert `cv-rain-calling-banner` from `kind: "treasure", grade: 4` to `kind: "treasure", rarity: 5` (without `grade`) per `lint_items.py`; set `sources: ["npc"]`, `unique: true` on all `4` items; apply the R6 `exception` to `cv-seed-rice-gourd` (`ho_lo`), `cv-season-seal` (`an`), and `cv-abbess-rain-robe` (`dao_bao`), omitting it on `cv-rain-calling-banner` (`ky`, utility).
   - **Reason**: Matches `lint_items.py` schema and `bang_tam` / `thai_chi` precedents.

---

## B. Mechanic Classification Table

| Kind | Record | Engine Word State | Implementation Summary |
|---|---|---|---|
| Tech | `seedling-breath-primer` | `has` | Tier 0 main (`["moc"]`), 6 layers, 0 bonuses, new passives (`7.8 W` combat + `herb_growth_pct 6`), `plant-the-seedling` (L1). |
| Tech | `good-rain-canon` | `has` | Tier 1 main (`["moc"]`), 9 layers, 1 bonus (`khi_huyet_pct 10`), new passives (`15.9 / 16 W`), `follows-the-wind-into-the-night` (L1), `when-the-season-comes` (L2), passives `Moistens Without a Sound` (L4), `Water Wears the Stone` (L6, `d24`). |
| Tech | `rite-of-the-grain-rain` | `has` | Tier 2 secret (`["moc"]`), 12 layers, 2 bonuses (`linh_luc_pct 14`, `tam_ma_resist_pct 10`), new passives (`22.6 / 24 W`), `call-the-grain-rain` (L1). |
| Art | `plant-the-seedling` | `has` (`heal`, counter) | Wood heal (`c_heal 0.5`, `cost_share 0.03`, `cd 5.0`), 3-pulse `seedling` counter: `1.5 %` HP/s + `4 %` harvest heal at pulse 3. |
| Art | `follows-the-wind-into-the-night` | `has` (`state` Field, `heal`, `stacks`, `slowed_time`) | Wood Field (`c_heal 0.4`, `cost_share 0.04`, `cd 8.0`), 6 s `good_rain` + `good-rain`/`good-rain-rooted`: `2 %` HP/s, +1 Wood buff (8 s)/s, 1 `slowed_time` (2 s, cd 2 s). |
| Passive | `Moistens Without a Sound` | `has` (`heal_restored`, `stacks`) | `good-rain-canon` L4: `on: "heal_restored"` (`per_pulse: 3`) -> +1 Wood buff (8 s). |
| Art | `when-the-season-comes` | `has` (`consume`, `heal`) | Wood heal (`c_heal 0.8`, `cost_share 0.04`, `cd 7.0`), guards `own.buff.wood >= 4` & `own.hp_share <= 0.95`: consumes own Wood buffs for `2 %` HP per stack. |
| Passive | `Water Wears the Stone` (`d24`) | `has` (`heal_restored`, `free_hit`) | `good-rain-canon` L6: `on: "heal_restored"` (`per_pulse: 3`) -> `free_hit` `phys` `0.15` + `0.01 * own.buff.wood`. |
| Art | `call-the-grain-rain` | `has` (`heal`, `cleanse`, `off_guard`, `gain_qi`, `upkeep`) | Wood channel (`c_heal 0.6`, `cost_share 0.05`, `cd 10.0`), 4-pulse `grain_channel`: `2.5 %` HP/s, cleanse 1 debuff + 1 curse, `off_guard` (1 s) on foe, pays `3 %` qi/s or `3 %` HP upkeep. |
| Effect | `The Good Rain Knows Its Season` | `has` (`time`, `healing`, `heal`) | `cv-rain-calling-banner`: `healing -50` while `time < 10`; `1 %` HP/s on `pulse` while `time >= 10`. |
| Effect | `Rain That Does Not Stop` | `has` (`counter`, `upkeep`, `healing`) | `cv-grain-rain` 3pc: keeps `good_rain = 6` once active; `+10` `healing` and `1 %` HP/s `upkeep` per `10 s` elapsed. |

---

## C. Techniques (`techniques/catalogue-sect-coc_vu.json`)

`lint_techniques.py`: **checked 3 techniques, 0 findings** (note: `herb_growth_pct` on `seedling-breath-primer` is an unpriced out-of-fight key; `good-rain-canon` `15.9 W of 16`; `rite-of-the-grain-rain` `22.6 W of 24`). All bonuses and passives below are newly authored and unpriced.

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Arts / Effects (unlock layer) |
|---|---|---|---|---|
| `seedling-breath-primer` | Yellow (0) main, `["moc"]` | none | `health_regen_inc_pct 8`, `healing_pct 6`, `linh_luc_regen_inc_pct 3`, `herb_growth_pct 6` | `plant-the-seedling` (1) |
| `good-rain-canon` | Profound (1) main, `["moc"]` | `khi_huyet_pct 10` | `healing_pct 10`, `health_regen_inc_pct 12`, `stack_effect_pct 10 [moc, buff]`, `stack_duration_pct 12 [moc, buff]`, `linh_luc_regen_inc_pct 3` | `follows-the-wind-into-the-night` (1), `when-the-season-comes` (2); Effects `Moistens Without a Sound` (4), `Water Wears the Stone` (6) |
| `rite-of-the-grain-rain` | Earth (2) secret, `["moc"]` | `linh_luc_pct 14`, `tam_ma_resist_pct 10` | `healing_pct 14`, `health_regen_inc_pct 16`, `linh_luc_regen_inc_pct 6`, `stack_effect_pct 12 [moc, buff]`, `status_duration_pct 10 [curse]` | `call-the-grain-rain` (1) |

Updated `design/world/depth/sects/coc_vu.techniques.json` with `"id"` fields on all `6` `"new"` art entries.

---

## D. Arts (`arts/part-sect-coc_vu.json`)

`lint_arts.py`: **checked 4 arts in 1 files, 0 findings** (`4` Wood, `4` `heal`, `4` `engine`).

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `plant-the-seedling` | Plants a seedling at the holder's feet: while the holder stands near it, they regenerate health; it grows for a few seconds and can be harvested for a small heal. | Wood (`c_heal 0.5`, `cost_share 0.03`, `cd 5.0`), 3-pulse `seedling` counter: `1.5 %` HP/s + `4 %` harvest heal at pulse 3. | Spatial phrasing ("at the holder's feet / stands near it") converted to a `3 s` self-counter. |
| `follows-the-wind-into-the-night` | A rain (a Field) for several seconds: while it is up, the holder regenerates health and gains Wood buff stacks, and the foe is slowed slightly. | Wood Field (`c_heal 0.4`, `cost_share 0.04`, `cd 8.0`), 6 s `good_rain` + `good-rain` / `good-rain-rooted` stances: `2 %` HP/s, +1 Wood buff (8 s)/s, 1 `slowed_time` (2 s, cd 2 s). | none (adds combined `good-rain-rooted` stance for `rooted-form` holders). |
| `when-the-season-comes` | Spends the holder's Wood buff stacks for one large heal on the holder. | Wood (`c_heal 0.8`, `cost_share 0.04`, `cd 7.0`), guards `own.buff.wood >= 4` & `own.hp_share <= 0.95`: consumes all own Wood buffs for `2 %` HP per stack. | none |
| `call-the-grain-rain` | A channelled rain over a wide area: the holder heals and is cleansed of one status each second; the foe cannot evade for 1 s each second; the holder pays linh lực and then health for each second held. | Wood (`c_heal 0.6`, `cost_share 0.05`, `cd 10.0`), 4-pulse `grain_channel`: `2.5 %` HP/s, cleanse 1 debuff + 1 curse, `off_guard` (1 s) on foe, pays `3 %` qi/s or `3 %` HP upkeep. | Spatial "over a wide area" omitted; channel uses counter rather than stance to avoid clobbering `good-rain` / `rooted`. |

---

## E. Effects (`effects/coc_vu.effects.json`) & Holder Verification

Standalone parity check (`E.validate` per Effect): **4 / 4 passed**.

| Effect | Depth rule | Engine form | Deviation |
|---|---|---|---|
| `Moistens Without a Sound` | A passive: the holder's heals are silent and cannot be interrupted, and each heal adds a Wood buff stack. | `on: "heal_restored"` (`per_pulse: 3`): +1 Wood buff (8 s). | none (heals are already uninterruptible in engine). |
| `Water Wears the Stone` (`d24`) | Each heal you receive drips on the foe as a small Wood hit, larger for each Wood buff stack you hold, at most three a second. | `on: "heal_restored"` (`per_pulse: 3`): `free_hit` `phys` `0.15` + `0.01 * own.buff.wood`. | `free_hit` carries `dtype: "phys"` without a `moc` tag parameter (`approx`). |
| `The Good Rain Knows Its Season` | For the first 10 seconds of a fight your heals are halved; after that, while you hold the Banner charge, you regenerate 1 % of health each second. | `time < 10`: `healing -50`; `pulse` with `time >= 10`: `heal {share: 0.01}`. | Banner charge treated as active while wearing the Banner from `10 s` onward (`approx`). |
| `Rain That Does Not Stop` | Your healing rain stays on the field until you fall. For every 10 s it has fallen, it heals 10 % more and costs you 1 % of your health each second, and nothing reduces that cost. | Once `good_rain >= 1`, sets `good_rain = 6` and increments `rain_seconds` each pulse; `+10` `healing` and `1` stack of `rain_cost` (`upkeep {pool: "hp", per_stack: 0.01}`) per `10 s`. | `upkeep {pool: "hp"}` enforces unreduced `1 %` HP/s cost (retaining `pay_keep_health` `1.0` HP floor). |

### Holder Check (`sect_fight.py coc_vu --seeds 5`)

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Notes |
|---|---|---|---|---|---|
| `duong_hao_vu` | `ket_dan` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `call-the-grain-rain`, `seed-of-spring`, `rooted-form`, `second-spring` | `28.3 s`, `5/5`, `100%` | `37.8 s`, `0/5`, `0%` | All 4 `coc_vu` Effects ran (`Moistens` 173, `Water Wears` 346, `Good Rain Knows Its Season` 96, `Rain That Does Not Stop` 228); at `--gap 1`, `Rain That Does Not Stop`'s rising HP upkeep (`1–3 %/s`) turns `31%` win without it into `0%` loss with it, matching her lore; `second-spring` stayed `0.0` (HP >= 95% or sudden burst). |
| `thoi_tri_tiet` | `ket_dan` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `call-the-grain-rain` | `65.0 s`, `5/5`, `60%` | `11.8 s`, `0/5`, `0%` | All 3 arts fired in both `--gap 0` (`8.0`, `4.0`, `7.0`) and `--gap 1` (`1.0`, `0.8`, `0.8`); `Moistens` 429, `Water Wears` 858. |
| `luc_dao_hoa` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `seed-of-spring`, `rooted-form`, `second-spring`, `harvest-bloom` | `15.6 s`, `5/5`, `100%` | `14.8 s`, `0/5`, `0%` | All `coc_vu` arts fired (`1.0`, `0.4–1.0`); `Moistens` 67, `Water Wears` 134; `second-spring` stayed `0.0`. |
| `su_van_hoa` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `seed-of-spring`, `rooted-form` | `21.2 s`, `5/5`, `100%` | `16.5 s`, `0/5`, `0%` | All arts fired in both (`2.0`/`1.0`, `0.4`/`1.0`); `Moistens` 92, `Water Wears` 184. |
| `ha_tinh_can` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `call-the-grain-rain` | `64.6 s`, `5/5`, `63%` | `8.4 s`, `0/5`, `0%` | All 3 arts fired at `--gap 0` (`7.2`, `3.4`, `6.0`); `Moistens` 488, `Water Wears` 976. |
| `la_tiem_da` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes` | `65.0 s`, `5/5`, `56%` | `8.4 s`, `0/5`, `0%` | Both fired at `--gap 0` (`8.0`, `4.0`); `Moistens` 419, `Water Wears` 838. |
| `lam_nhuan_chi`, `so_loi_duan` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes` | `65.0 s`, `5/5`, `66%` | `8.4 s`, `0/5`, `0%` | Both fired at `--gap 0` (`7.8`, `5.2`); `Moistens` 465 (`layer < 6` so no `Water Wears`). |
| `duong_ha_thao` | `luyen_khi` | `follows-the-wind-into-the-night`, `when-the-season-comes` | `65.0 s`, `5/5`, `39%` | `8.0 s`, `0/5`, `0%` | Both fired at `--gap 0` (`7.2`, `5.4`); `layer 2` (`< 4`). |
| `thieu_mo_canh`, `dong_tieu_uong`, `lo_tan_chau`, `van_tieu_hoa`, `tan_xuan_duan`, `thai_huong_doan`, `khang_vu_ngung`, `vi_hoa_ca`, `tong_tiet_truc` | `luyen_khi` | `plant-the-seedling` | `62.2 s`, `2/5`, `6%` | `8.2 s`, `0/5`, `0%` | `plant-the-seedling` fired `11.2`/fight at `--gap 0`, `1.0` at `--gap 1`. |

- **Targeted probe (`call-the-grain-rain` low-qi fallback)**: with `duong_hao_vu` at `reserved: 0.88` and only `call-the-grain-rain` slotted against typical `ket_dan`, `pay-hp` ran `10` times and `close` ran `4` times cleanly.

---

## F. Items & Sets (`items/catalogue-sect-coc_vu.json`, `items/sets-coc_vu.json`)

`lint_items.py`: **checked 4 items, 22 bases, 9 common arts, 0 findings**.
- `cv-rain-calling-banner`: treasure `rarity: 5` (`30.6 W` unpriced, `unique: true`, `sources: ["npc"]`, utility `ky` — no R6 needed, effect `["The Good Rain Knows Its Season"]`).
- `cv-seed-rice-gourd`: artifact grade 3 (`31.4 W` unpriced, `unique: true`, `sources: ["npc"]`, R6 `exception`).
- `cv-season-seal`: artifact grade 3 (`21.0 W` unpriced, `unique: true`, `sources: ["npc"]`, R6 `exception`).
- `cv-abbess-rain-robe`: artifact grade 4 (`30.8 W` unpriced, `unique: true`, `sources: ["npc"]`, R6 `exception`).
- Set `cv-grain-rain` (3 pieces): 2pc (`healing_pct 6`, `health_regen_inc_pct 15`), 3pc (`Rain That Does Not Stop (Vũ Bất Tuyệt)`).

---

## G. Stand-ins & Beasts

- Stand-ins: `0` across all `19` cast records (`18` living across `coc_vu.cast.json` + `coc_vu.5.cast.json`, `1` dead `hang_dao_vu`).
- Beasts: `0`.

---

## H. Open Items

- **Serial step**: merge `design/stage6-staging/coc_vu/*` into `design/techniques/catalogue-sect-coc_vu.json`, `design/arts/part-sect-coc_vu.json`, `design/items/catalogue-sect-coc_vu.json`, `design/items/sets-coc_vu.json`, and `assets/data/combat_effects.json` (`put_effects.py`, `4` Effects under `world-depth:coc_vu`).
- **Stage 7 export**: export techniques, named items, sets, combat library, and `4` translated events (`events/coc_vu.events.json`) so `depth_gap.py --sect coc_vu` reaches `0`.
