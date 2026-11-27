# Stage 6: Thải Chi Cốc (`thai_chi`) (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method", and `production/plans/stage6/_brief-record.md` (headless record pass, decisions auto-accepted).

## Scope (`python -I tools/design/world/depth_gap.py --sect thai_chi`)
- **4 techniques:** `lingzhi-pickers-song` (Yellow main, Wood/Water), `shang-mountain-lingzhi-canon` (Earth main, Wood+Water), `hundred-herbs-tasting` (Profound secret, Wood), `grain-rain-canon` (Earth secret, Water+Wood).
- **5 new arts** (ids written to `thai_chi.techniques.json`): `weeding-hand`, `lingzhi-spores`, `taste-and-name`, `bitter-medicine` (d33 passive art -> `technique-effects`), `grain-rain`. Plus 12th-layer technique Effect `Cut to the Root` on `shang-mountain-lingzhi-canon`.
- **3 existing art refs** (`family-wood.json`): `seed-of-spring`, `harvest-bloom`, `second-spring`.
- **4 items, 1 set (`tc-herb-terraces`):** `tc-purple-lingzhi-gourd` (`rarity: 5` treasure, base `ho_lo`), `tc-cinder-censer` (grade 3 artifact, base `huong_lo`), `tc-grain-rain-fan` (grade 3 artifact, base `phien`), `tc-terrace-bell` (grade 3 artifact, base `chuong`).
- **4 Effects in `thai_chi.items.json`:** `The Herbs Stay Alive`, `The Empty Mountain's Answer` (d5, already merged in `combat_effects.json` under `world-depth:thuy_vi`, `"new": false` updated in `thai_chi.items.json`), `Banked Coals`, `Rain on the Sown Field`. Plus `Bitter Medicine` (d33) and `Cut to the Root` (layer 12) from techniques.
- **0 stand-ins, 0 beasts, 0 cross-owner refs, 4 events (already structured + translated).**

## Steps
- [x] 1. Verify first: mechanic table (exists / needs a word / needs a decision), `spatial_words_check.py` (1 false positive in `grain-rain-canon.concept`: descriptive prose "rooted", not a fight rule).
- [x] 2. Techniques and arts (`design/stage6-staging/thai_chi/techniques/catalogue-sect-thai_chi.json`, `arts/part-sect-thai_chi.json`, `thai_chi.techniques.json` ids).
- [x] 3. Effects (`design/stage6-staging/thai_chi/effects/thai_chi.effects.json`: 5 Effects).
- [x] 4. Items and sets (`design/stage6-staging/thai_chi/items/catalogue-sect-thai_chi.json`, `sets-thai_chi.json`, `thai_chi.items.json` `"new": false` on shared `d5`).
- [x] 5. Stand-ins: none (`0` in `depth_gap.py`).
- [x] 6. Beasts: none (`0` in `depth_gap.py`).
- [x] 7. Holder check (`DEPTH_STAGE` linters 0 findings across all 3 linters, `depth_check.py --quiet` 0 findings, `E.validate` 5/5 standalone, `sect_fight.py thai_chi --seeds 5` + `--gap 1` + targeted probes for `Bitter Medicine`, `Taste and Name`, `Weeding Hand`, `The Herbs Stay Alive`, `Cut to the Root`, `Banked Coals`).
- [x] 8. Review file (`production/plans/stage6/thai_chi-review.md`).
- [x] 9. Finish (`thai_chi.done` written).

## Step 1: Mechanic Table
| Kind | Record | Engine Word State | Implementation / Decision |
|---|---|---|---|
| Tech | `lingzhi-pickers-song` | `has` | Tier 0 main (`moc`, `thuy`), 6 layers, 0 bonuses; passives sized 7.6 / 8 W (`health_regen_inc_pct` 8, `linh_luc_regen_inc_pct` 4, `healing_pct` 4, + `herb_growth_pct` 6 out-of-fight). |
| Tech | `shang-mountain-lingzhi-canon` | `has` | Tier 2 main (`moc`, `thuy`), 12 layers, 2 bonuses (`khi_huyet_pct` 12, `herb_growth_pct` 20); passives sized 24.0 / 24 W; `harvest-bloom` (1), `lingzhi-spores` (2), `second-spring` (4); L12 Effect `Cut to the Root` (`technique-effects`, already built in b01). |
| Tech | `hundred-herbs-tasting` | `has` | Tier 1 secret (`moc`), 9 layers, 1 bonus (`khi_huyet_pct` 10); passives sized 15.8 / 16 W (`status_resist_pct` 20 `[poison]`, `resist_pct` 120 `[chaos]`, `healing_pct` 10, `khi_huyet_pct` 6, + `dan_doc_resist_pct` 10); `taste-and-name` (1); L3 passive Effect `Bitter Medicine` (d33, `technique-effects`). |
| Tech | `grain-rain-canon` | `has` | Tier 2 secret (`thuy`, `moc`), 12 layers, 2 bonuses (`herb_growth_pct` 22, `linh_luc_pct` 12); passives sized 24.0 / 24 W; `grain-rain` (1). |
| Art | `weeding-hand` | `has` (`strip`, `foe.buff_elements`, `heal`) | Wood hit (`c_art 0.8`, `c_heal 0.4`, `cost_share 0.03`, `cooldown 5`); on `hit_landed` when `foe.buff_elements >= 1`, strips 1 buff (`strip {n: 1}`) and increments `weeded_buffs`; heals 1 % max HP per `weeded_buffs` stripped this fight. |
| Art | `lingzhi-spores` | `has` (`debuff`, `stacks`, `heal`, `counter`) | Wood stacks (`c_art 1.0`, `debuff [2, 6]`, `cost_share 0.04`, `cooldown 5`); on `hit_landed`, seeds 3 `lingzhi_spores`; each pulse with `lingzhi_spores >= 1` ripens 1 spore into 1 Wood debuff (6 s) and bursts for 1.5 % HP heal. |
| Art | `taste-and-name` | `has` (`cleanse`, `resist`) | Wood utility (`c_art 0.0`, `cost_share 0.03`, `cooldown 6`); on `art_fired`, if `own.debuff.wood >= 1` records `tasted_wood` (+1) BEFORE cleansing 1 Wood debuff (`cleanse {n: 1, el: "wood"}`); grants +25 Chaos `resist` per `tasted_wood` for the rest of the fight. |
| Passive Art | `bitter-medicine` (d33) | `has` (`tick_to_heal`, `own.debuff.wood`) | Attached via `hundred-herbs-tasting` `effects` (L3). While `own.debuff.wood < 10`, `tick_to_heal: 50` (`element: "wood"`); at 10+, normal Poison tick damage. |
| Art | `grain-rain` | `has` (`state` Field, `heal`, `stacks`) | Water Field (`c_art 0.0`, `c_heal 0.5`, `cost_share 0.05`, `cooldown 9`), guard `own.counter.grain_rain < 1`; sets state `grain-rain` (`tags: ["field"]`) and `grain_rain: 6` s; each pulse heals 2.5 % max HP, and if `foe.debuff.wood >= 1` adds 1 Wood debuff (6 s); decrements cleanly and exits state when 0. |
| Effect (Tech L12) | `Cut to the Root` | `has` (`down`, `refuse_down`) | Once per fight on `down` (unlock_layer 12 on `shang-mountain-lingzhi-canon`), `refuse_down {hp_share: 0.15}`. |
| Effect (Item) | `The Herbs Stay Alive` | `decision` (`pill_burned`, `refresh`, `healing`) | Out-of-fight herb/pill preservation unmodelled; in fight, on first `pill_burned` (`per_fight: 1`), grants +50 % `healing` for 6 s (`approx` since fight pills are smoke-only) and holds Wood buff/debuff stacks (`refresh {hold: true}`). |
| Effect (Item) | `The Empty Mountain's Answer` | `has` (already merged under `world-depth:thuy_vi`) | Reference by name on `tc-purple-lingzhi-gourd`; uses `heal_overflow` (built in b01). Clear false `new: true` clash in `thai_chi.items.json`. |
| Effect (Item) | `Banked Coals` | `has` (`art_fired`, `status_applied`, self-debuff) | Once per fight (`per_fight: 1`), on Fire `art_fired`: applies 2 self-Burn stacks (4 s) first, then sets `coal_flare: 1`; on next Fire `status_applied` (`coal_flare >= 1`), clears `coal_flare: 0` first and adds `event.stacks` extra Fire debuff stacks (doubling burn stacks). |
| Effect (Set) | `Rain on the Sown Field` | `has` (`own.state.grain-rain`, `refresh`, `heal`) | While `own.state.grain-rain >= 1`: keeps foe Wood debuffs from fading (`refresh {at_least: 6}`) and heals 2 % max HP each pulse a `lingzhi_spores` stack ripens (`own.counter.lingzhi_spores >= 1`). Declares `lingzhi_spores` in its own `counters`. |

RECORD PASS DONE
