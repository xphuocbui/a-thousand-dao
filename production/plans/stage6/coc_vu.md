# Stage 6: Cốc Vũ Quán (`coc_vu`) (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method" + `production/plans/stage6/_brief-record.md` (headless job, decisions auto-accepted).

## Scope (`python -I tools/design/world/depth_gap.py --sect coc_vu`)
- 3 techniques: `seedling-breath-primer` (Yellow main, Wood, outer), `good-rain-canon` (Profound main, Wood, inner), `rite-of-the-grain-rain` (Earth secret, Wood, elders). Existing lineage ref: `verdant-cycle-scripture` (`catalogue-wood.json`).
- 6 new arts (4 active: `plant-the-seedling`, `follows-the-wind-into-the-night`, `when-the-season-comes`, `call-the-grain-rain`; 2 passive arts via `technique.effects`: `Moistens Without a Sound`, `Water Wears the Stone` `d24`).
- 4 items (`cv-rain-calling-banner` treasure, `cv-seed-rice-gourd`, `cv-season-seal`, `cv-abbess-rain-robe`), 1 set (`cv-grain-rain`), 2 item/set Effects (`The Good Rain Knows Its Season`, `Rain That Does Not Stop`).
- 0 stand-ins, 0 beasts, 0 cross-owner refs, 4 structured events (`N-coc_vu-01`..`04`).
- `spatial_words_check.py --sect coc_vu`: 0 non-soft rule-field hits (4 `beside` in tie notes, 1 `rooted` in `so_loi_duan`'s `tree.intent` commentary).

## Steps
- [x] 1. Verify first: mechanic table + spatial check + Effect name uniqueness check (`assets/data/combat_effects.json`).
- [x] 2. Techniques and arts (staged under `design/stage6-staging/coc_vu/` + `"id"` inserts in `coc_vu.techniques.json`).
- [x] 3. Effects (`design/stage6-staging/coc_vu/effects/coc_vu.effects.json`).
- [x] 4. Items and sets (`design/stage6-staging/coc_vu/items/`).
- [x] 5. Stand-ins: 0 across all 18 living cast records (verified).
- [x] 6. Beasts: 0 (verified).
- [x] 7. Holder check (`DEPTH_STAGE` linters + `sect_fight.py coc_vu` `--gap 0` / `--gap 1` + targeted probes + standalone `E.validate`).
- [x] 8. Review file (`production/plans/stage6/coc_vu-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` + `production/plans/stage6/coc_vu.done`).

## Step 1 result: mechanic classification table
| Kind | Record | Engine Word State | Plan |
|---|---|---|---|
| Tech | `seedling-breath-primer` | `has` | Yellow tier 0 main, `["moc"]`, 6 layers, 0 bonuses, new passives (`<= 8 W`), `plant-the-seedling` (L1). |
| Tech | `good-rain-canon` | `has` | Profound tier 1 main, `["moc"]`, 9 layers, 1 bonus, new passives (`<= 16 W`), `follows-the-wind-into-the-night` (L1), `when-the-season-comes` (L2), passive arts `Moistens Without a Sound` (L4), `Water Wears the Stone` (L6, `d24`). |
| Tech | `rite-of-the-grain-rain` | `has` | Earth tier 2 secret, `["moc"]`, 12 layers, 2 bonuses, new passives (`<= 24 W`), `call-the-grain-rain` (L1). |
| Art | `plant-the-seedling` | `has` (`heal`, counter) | Non-spatial self-counter `seedling` (3 pulses): `1.5 %` HP/s + `4 %` harvest heal on pulse 3 + `c_heal 0.5`. |
| Art | `follows-the-wind-into-the-night` | `has` (`state` Field, `heal`, `stacks`, `slowed_time`) | Field stance `good-rain` (and `good-rain-rooted` combined with `rooted-form`), 6 s counter `good_rain`: `2 %` HP/s, +1 Wood buff (8 s)/s, 1 `slowed_time` (2 s, cd 2 s). |
| Passive | `Moistens Without a Sound` | `has` (`heal_restored`, `stacks`) | Technique Effect on `good-rain-canon` L4: on `heal_restored` (`per_pulse: 3`), +1 Wood buff stack (8 s). |
| Art | `when-the-season-comes` | `has` (`consume`, `heal`) | Wood heal (`c_heal 0.8`), guards `own.buff.wood >= 4` and `own.hp_share <= 0.95`: consumes all own Wood buffs for `2 %` HP per stack consumed. |
| Passive | `Water Wears the Stone` (`d24`) | `has` (`heal_restored`, `free_hit`) | Technique Effect on `good-rain-canon` L6: on `heal_restored` (`per_pulse: 3`), `free_hit` `phys` `0.15` + `0.01 * own.buff.wood`. |
| Art | `call-the-grain-rain` | `has` (`heal`, `cleanse`, `off_guard`, `gain_qi`, `upkeep`) | 4-pulse channel via counter `grain_channel` (no stance conflict): `2.5 %` HP/s, cleanse 1 debuff + 1 curse, `off_guard` (1 s) on foe, pays `3 %` qi/s or `3 %` HP upkeep when low. |
| Item | `cv-rain-calling-banner` | `has` (`rarity: 5` treasure) | Utility `ky` treasure (`rarity: 5`), unique, `sources: ["npc"]`, Effect `The Good Rain Knows Its Season`. |
| Item | `cv-seed-rice-gourd` | `has` (R6 `exception`) | `ho_lo` grade 3 artifact, unique, `sources: ["npc"]`, R6 `exception`. |
| Item | `cv-season-seal` | `has` (R6 `exception`) | `an` grade 3 artifact, unique, `sources: ["npc"]`, R6 `exception`. |
| Item | `cv-abbess-rain-robe` | `has` (R6 `exception`) | `dao_bao` grade 4 artifact, unique, `sources: ["npc"]`, R6 `exception`. |
| Set | `cv-grain-rain` | `has` (`sets`, `effect`) | 2pc modifiers + 3pc Effect `Rain That Does Not Stop`. |
| Effect | `The Good Rain Knows Its Season` | `has` (`time`, `healing`, `heal`) | `time < 10`: `healing -50`; `pulse` with `time >= 10`: `heal {share: 0.01}`. |
| Effect | `Rain That Does Not Stop` | `has` (`counter`, `upkeep`, `healing`) | Once `good_rain >= 1`, refreshes `good_rain = 6` each pulse, counts `rain_seconds`, adds `+10` `healing` per `10` s, and sets `rain_cost` (`upkeep {pool: "hp", per_stack: 0.01}`) = `floor(rain_seconds / 10)`. |

RECORD PASS DONE
