# Cốc Vũ Quán (`coc_vu`): Stage 6 checkpoint review (2026-11-27)

Reviewed unanchored against `design/world/depth/sects/coc_vu.md`, `coc_vu.techniques.json`, `coc_vu.items.json`, `coc_vu.cast.json`, `coc_vu.5.cast.json`, `production/plans/stage6/_brief-record.md`, `design/world/depth/DECISIONS-2026-11-25.md`, `DECISIONS-2026-11-26.md`, and `tools/design/combat_sim/FIGHT-INPUT.md`.

## Ranked findings

**2 MUST-FIX, 1 SHOULD, 1 NIT — all MUST-FIX and SHOULD findings fixed and re-verified.**

1. **MUST-FIX (FIXED) — `design/stage6-staging/coc_vu/arts/part-sect-coc_vu.json` (`follows-the-wind-into-the-night` / `good-rain-rooted`):**
   - **What was wrong:** While `follows-the-wind-into-the-night` and `rooted-form` (`design/arts/family-wood.json`) coexisted in the combined stance `good-rain-rooted`, `rooted-form`'s pulse effects (`rooted-creep`: 2 Wood debuff stacks + 1 `seed` counter; `rooted-sap`: +2 Wood debuff stacks per 10 Wood buff stacks) check `own.state.rooted == 1` and therefore **stopped running** whenever `good-rain-rooted` was active. On `duong_hao_vu`, `Rain That Does Not Stop` kept `good-rain-rooted` active from ~7.7 s until the end of the fight, permanently disabling `rooted-creep` and `rooted-sap` and causing the unintended slowdown (`28.3 s` with `Rain That Does Not Stop` vs `21.2 s` without at `--gap 0`, and `0/20` wins vs `13 %` HP at `--gap 1`).
   - **Fix applied:** Declared `{"id": "seed"}` in `follows-the-wind-into-the-night`'s `counters` and added `good-rain-rooted-creep` (`on: "pulse"`, `if: [own.state.good-rain-rooted >= 1, own.counter.good_rain >= 2]`, laying `2` Wood debuffs for `5` s and `+1` `seed`) and `good-rain-rooted-sap` (`on: "pulse"`, `if: [own.state.good-rain-rooted >= 1, own.counter.good_rain >= 2]`, `scale: own.buff.wood / 10`, laying `2` Wood debuffs for `5` s). Gating on `good_rain >= 2` ensures pulses 1–5 run via `good-rain-rooted-*` and the closing 6th pulse (after `good_rain` drops to 0 and `good-rain-close-rooted` restores `state = "rooted"`) runs via `rooted-form` itself, while `Rain That Does Not Stop` holds `good_rain` at `6` so every pulse runs. After fix: `duong_hao_vu` improves from `28.3 s` to `19.4 s` (`5/5`, `100 %` HP; vs `19.0 s` without `Rain That Does Not Stop`) at `--gap 0`, and from `0/20` wins to **`14/20` wins (`53.7 s`, `63 %` HP; vs `22 %` without)** at `--gap 1`.
2. **MUST-FIX (FIXED) — `design/stage6-staging/coc_vu/effects/coc_vu.effects.json` (`The Good Rain Knows Its Season`):**
   - **What was wrong:** `eff:The Good Rain Knows Its Season:early` (`time < 10`) used `{"mod": {"healing": -50}}` instead of `{"mod": {"heal_taken": -50}}`. Because `healing` is additive with `s.b.healing` (`+70 %` on `duong_hao_vu` from techniques, gear, and 2-piece set), `-50` only cut her healing multiplier from `1.70` to `1.20` (`29 %` cut) rather than halving heals as the depth rule states (*"for the first 10 seconds of a fight your heals are halved"*). `heal_taken: -50` multiplies total healing by `0.5` (`1.70 * 0.50 = 0.85`).
   - **Fix applied:** Switched `{"mod": {"healing": -50}}` to `{"mod": {"heal_taken": -50}}`, updated the `rule` string (`heal_taken -50`), and documented the `-50 %` `curse_heal_taken_max` floor in `"approx"`.
3. **SHOULD (FIXED) — `design/stage6-staging/coc_vu/effects/coc_vu.effects.json` (`Water Wears the Stone`, `Rain That Does Not Stop`):**
   - **What was wrong:** `Water Wears the Stone` (`d24`) fires two separate `free_hit` records (`0.15` and `0.01 * own.buff.wood`, matching `The Lamp Flares`'s two-record workaround because `free_hit` lacks `base + per_stack`), which consumes two trigger slots per heal and subjects the `0.15` hit to flat block (`0.0` dealt against typical block), without documenting that split in `approx`. Similarly, `Rain That Does Not Stop`'s `+10` `healing` per `10 s` applies to all incoming heals rather than only the rain field's pulse heal, without an `approx` note.
   - **Fix applied:** Documented both engine approximations explicitly in each Effect's `"approx"` field.
4. **NIT (no edit) — `design/world/depth/sects/coc_vu.cast.json` (`so_loi_duan`):**
   - `so_loi_duan.build.tree.intent` reads `"Wood, rooted."` (flagged as `removed` commentary by `spatial_words_check.py`, not a rule field). Left untouched.

## Specific parity, uniqueness, and mechanic verification

- **Standalone Effect compilation parity (`engine.validate` per Effect):**
  - `Moistens Without a Sound`: no counters or stances; triggers on `heal_restored` (`limit: {"per_pulse": 3}`), adds `1` Wood buff (`8 s`). Verified on all 8 layer 4+ holders (`89–488` runs at `--gap 0`, `11–1917` at `--gap 1`).
  - `Water Wears the Stone` (`d24`): no counters or stances; triggers on `heal_restored` (`limit: {"per_pulse": 3}`), fires `free_hit` `phys` `0.15` + `0.01 * own.buff.wood` (listed after `Moistens Without a Sound` in `good-rain-canon.effects` so `own.buff.wood` includes the new stack). Verified on all 6 layer 6+ holders (`126–976` runs at `--gap 0`, `30–3834` at `--gap 1`).
  - `The Good Rain Knows Its Season`: no counters or stances; `time < 10` halves heals (`heal_taken: -50`), `time >= 10` heals `1 %` HP per pulse. Verified on `duong_hao_vu` (`52` runs `--gap 0`, `889` `--gap 1`).
  - `Rain That Does Not Stop`: declares `good_rain`, `rain_seconds`, and `rain_cost` (`upkeep {pool: "hp", per_stack: 0.01}`) locally in its own `"counters"`; safe on a holder lacking `follows-the-wind-into-the-night` (`good_rain` stays `0`). `upkeep {pool: "hp"}` runs unreduced (`pay_keep_health` floor preserved). Verified on `duong_hao_vu` (`96` runs `--gap 0`, `2427` `--gap 1`).
- **Multi-`mod`, `temp_mods`, events/pulses, and stances:**
  - `0` multi-`mod` records lacking `stack: true`; `0` `temp_mods` filtering on `art_id`; `0` `always` records with a record-level `filter`; `0` `decay_per_pulse: 1` off-by-ones; `follows-the-wind-into-the-night` declares all three stances it references (`good-rain`, `rooted`, `good-rain-rooted`) and coexists cleanly with `rooted-form`; `call-the-grain-rain` uses counter `grain_channel` + `grain_hp_cost` without stance collision.
- **Uniqueness & spatial check:**
  - `0` ID or Effect-name collisions vs `assets/data/combat_effects.json` (`340` entries), committed `design/`, and all other staged `b04` directories.
  - `spatial_words_check.py --sect coc_vu`: `0` rule-field hits (`4` `soft` tie-note `beside`, `1` commentary `tree.intent` `rooted`).
- **Stand-ins, beasts, techniques, and items:**
  - `0` stand-ins across `18` living cast records (`1` dead `huong_can_thu`, `1` dead `hang_dao_vu`); every member holds `moc >= 40` matching their Wood methods. `0` beasts.
  - Techniques (`7.8 W` combat + `herb_growth_pct 6` on Yellow `8 W`; `15.9 / 16 W` Profound; `22.6 / 24 W` Earth) and items (`cv-rain-calling-banner` `treasure` `rarity: 5` `unique: true`; `cv-seed-rice-gourd`, `cv-season-seal`, `cv-abbess-rain-robe` `unique: true`, `sources: ["npc"]`, R6 `exception`; `cv-grain-rain` 3-piece set) match depth text and tier budgets.

## Pending words

None (`design/stage6-staging/coc_vu/pending.json` absent; `0` pending words).

## Checks & Holder table (`DEPTH_STAGE=design/stage6-staging/coc_vu`)

- `lint_techniques.py`: **checked 3 techniques, 0 findings** (`seedling-breath-primer` `NOT ASSESSED` due to `herb_growth_pct 6` + `7.8 W` combat / `8 W`; `good-rain-canon` `15.9 W of 16`; `rite-of-the-grain-rain` `22.6 W of 24`).
- `lint_arts.py`: **checked 4 arts in 1 files, 0 findings**.
- `lint_items.py`: **checked 4 items, 22 bases, 9 common arts, 0 findings**.
- `spatial_words_check.py --sect coc_vu`: `0` rule-field hits.
- `sect_fight.py coc_vu --seeds 5` (`--gap 0`) and `sect_fight.py coc_vu --gap 1` (`--seeds 20`): **0 REFUSED** across all 18/18 living people.

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Art fires (G0 / G1) & Effect notes |
|---|---|---|---|---|---|
| `duong_hao_vu` | `ket_dan` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `call-the-grain-rain`, `seed-of-spring`, `rooted-form`, `second-spring` | 19.4 s, 5/5, 100 % | 53.7 s, 14/20, 63 % | Fires 1.0/0.0/1.0/3.0/2.8/0.0 (G0), 1.0/1.0/3.2/8.2/5.7/0.0 (G1). `when-the-season-comes` (`0.0` G0) & `second-spring` (`0.0` G0/G1) stay gated at `hp_share <= 0.95` while sustain holds HP at 100 % (G0) or above 95 % until burst/upkeep drop (G1); `when-the-season-comes` fires `1.0`/fight at G1. `Moistens`: 89 runs G0 (19.4 s vs 19.2 s), 1917 G1 (63 % vs 0 %). `Water Wears`: 178 G0 (19.4 s vs 22.6 s), 3834 G1 (63 % vs 0 %). `Good Rain Knows Its Season`: 52 G0 (19.4 s vs 19.8 s), 889 G1 (63 % vs 35 %). `Rain That Does Not Stop`: 96 G0 (19.4 s vs 19.0 s), 2427 G1 (63 % vs 22 %). |
| `thoi_tri_tiet` | `ket_dan` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `call-the-grain-rain` | 65.0 s, 5/5, 60 % | 11.5 s, 0/20, 0 % | Fires 8.0/4.0/7.0 (G0), 1.0/0.9/0.7 (G1). `Moistens`: 429 G0 (60 % vs 42 %), 264 G1. `Water Wears`: 858 G0 (60 % vs 47 %), 528 G1. |
| `luc_dao_hoa` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `seed-of-spring`, `rooted-form`, `second-spring`, `harvest-bloom` | 15.0 s, 5/5, 100 % | 13.7 s, 0/20, 0 % | Fires 1.0/0.4/2.4/2.0/0.0/2.0 (G0), 1.0/1.0/1.0/1.7/0.0/1.0 (G1). `second-spring` (`0.0`) gated on `hp_share <= 0.95`. `Moistens`: 63 G0, 298 G1. `Water Wears`: 126 G0 (15.0 s vs 17.8 s), 596 G1. |
| `su_van_hoa` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `seed-of-spring`, `rooted-form` | 19.0 s, 5/5, 100 % | 14.2 s, 0/20, 0 % | Fires 2.0/0.4/3.0/2.4 (G0), 1.0/1.0/1.0/1.8 (G1). `Moistens`: 83 G0 (19.0 s vs 19.4 s), 286 G1. `Water Wears`: 166 G0 (19.0 s vs 23.9 s), 572 G1. |
| `ha_tinh_can` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes`, `call-the-grain-rain` | 64.6 s, 5/5, 63 % | 8.4 s, 0/20, 0 % | Fires 7.2/3.4/6.0 (G0), 0.5/0.0/0.0 (G1, 8.4 s defeat before `when-the-season-comes` / `call-the-grain-rain` readiness). `Moistens`: 488 G0 (63 % vs 56 %), 15 G1. `Water Wears`: 976 G0 (63 % vs 56 %), 30 G1. |
| `la_tiem_da` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes` | 65.0 s, 5/5, 56 % | 8.3 s, 0/20, 0 % | Fires 8.0/4.0 (G0), 0.5/0.0 (G1, 8.3 s defeat). `Moistens`: 419 G0 (56 % vs 44 %), 15 G1. `Water Wears`: 838 G0 (56 % vs 66 % RNG crit drift), 30 G1. |
| `lam_nhuan_chi`, `so_loi_duan` | `truc_co` | `follows-the-wind-into-the-night`, `when-the-season-comes` | 65.0 s, 5/5, 66 % | 8.2 s, 0/20, 0 % | Fires 7.8/5.2 (G0), 0.5/0.0 (G1, 8.2 s defeat). `Moistens`: 465 G0 (66 % vs 50 %), 11 G1 (`layer < 6`: no `Water Wears`). |
| `duong_ha_thao` | `luyen_khi` | `follows-the-wind-into-the-night`, `when-the-season-comes` | 65.0 s, 5/5, 39 % | 8.0 s, 0/20, 0 % | Fires 7.2/5.4 (G0), 0.5/0.0 (G1, 8.0 s defeat). `layer 2` (`< 4`). |
| `thieu_mo_canh`, `dong_tieu_uong`, `lo_tan_chau`, `van_tieu_hoa`, `tan_xuan_duan`, `thai_huong_doan`, `khang_vu_ngung`, `vi_hoa_ca`, `tong_tiet_truc` | `luyen_khi` | `plant-the-seedling` | 62.2 s, 2/5, 6 % | 8.1 s, 0/20, 0 % | Fires 11.2 (G0), 1.0 (G1). |

CHECKPOINT DONE
