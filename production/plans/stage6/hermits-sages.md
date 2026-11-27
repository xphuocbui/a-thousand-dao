# Stage 6: Ẩn Sĩ — Hermits and Sages (`hermits-sages`, Batch `b06`)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method" (user-approved 2026-11-26; decisions auto-accepted).
Owner files: `design/world/depth/people/hermits-sages.*` (outside-sect group, `sect: ""`).

## Scope (gap report 2026-11-27, `python -I tools/design/world/depth_gap.py --sect hermits-sages`)
- **4 proposal techniques** (+ **2 new stand-in techniques** authored here: `lone-crane-metal-canon` for `tu_khong_hac_nien`, `vermilion-tide-breath` for the three coastal Water stand-ins):
  - `still-water-mirror-canon` (Heaven main, Water)
  - `north-wind-cold-light-sword` (Earth secret, Ice)
  - `purple-smoke-furnace-canon` (Earth main, Fire + Wood)
  - `falling-plum-flute-canon` (Earth secret, Wind)
- **8 open `arts_new`** (`pill-smoke` already runs in `part-sect-market-folk.json` / `combat_library.json` — preserved cleanly without duplication) + **3 new stand-in arts** (`crane-edge-draw`, `broken-sleeve-stroke`, `long-oar-stroke`).
- **13 items** (4 sealed in abodes A-1/A-2/A-4/A-5, 9 held), **3 sets** (`hs-what-the-old-man-kept`, `hs-lone-crane-things`, `hs-still-pool`), **10 Effects** (7 item, 3 set), **0 beasts**, **0 events** (events in `hermits-sages.md` are prose proposals `N-hermits_sages-01..10`, not yet in `events/`).
- **7 stand-ins** (`tu_khong_hac_nien`, `thu_van_trieu`, `trau_vong_bang`, `thu_tieu_chu`, `boc_tuyet_nha`, `bao_tieu_que`, `cam_thu_nguyen`).
- **1 unconsumed modifier line** (`element_affinity_pct: 10 [hoa]` on `hs-purple-smoke-furnace` — preserved on the item; `element_affinity_pct` is in `lint_items.py` `ITEM_PRICE` and `catalogue-general.json` `general-five-phase-flag`, awaiting `CHARACTER_MODS` / GDScript reader in a later pass).

## Step 1: Mechanic Table (Verify first)

### Spatial scan (`spatial_words_check.scan` on `people/hermits-sages.*`)
- `where-all-waters-return` ("every foe near you") -> 1v1 single `the foe`.
- `crane-from-the-east` ("Wind-rooted") -> false positive on `rooted`; reworded to `"a hand with a Wind root"` in staged `rule` prose.
- `noon-on-one-side` ("foes in front of you") -> 1v1 single `the foe`.
- `falling-plum-tune` / `The Fifth-Month Tune` ("every foe's arts" / "foes in hearing") -> 1v1 single `the foe`.
- `The Lake Shows the Moon` ("while you stand still") -> `own.composed >= 1`.
- `Walking on Still Water` ("to any point you can see") -> non-spatial evade + decoy + timer haste while holding the still ward.
- `Smoke over the Burner` ("around you: foes inside it") -> 1v1 Fire debuff stacks on the foe + Poison damage/tick reduction on self.

### Techniques, Arts, and Effects Classification
| Record | Kind | Engine Status | Mapping / Decision |
|---|---|---|---|
| `still-water-mirror-canon` | Tech (T3) | Existing | 3 bonuses, 4 passives (30.4/32 W), 2 arts |
| `the-lake-shows-the-moon` | Art | Existing | Stance `still-water-mirror` (`composed`), `ward_grow`, `ward_absorbed` `return_damage {share: 0.5, dtype: "cold"}` |
| `walking-on-still-water` | Art | Existing | `movement` art: +evade, timer haste, +decoy & extra evade if `own.ward_share > 0` |
| `north-wind-cold-light-sword` | Tech (T2) | Existing | 2 bonuses, 5 passives (22.9/24 W), 2 arts |
| `watchmans-gong` | Art | Existing | `debuff: [1, 8]` Ice + `empower` on `foe.debuff.ice >= 1` (`c_mult: 1.7`) |
| `cold-light-on-iron-mail` | Art | Existing | `cold_light` 6 s timer; releases `free_hit {c: 1.1, dtype: "cold"}` + 1 Ice stack on next sword art or at 6 s pulse |
| `purple-smoke-furnace-canon` | Tech (T2) | Existing | 2 bonuses, 5 passives (22.6/24 W), 3 arts (incl. existing `pill-smoke` at L4) |
| `second-brewing` | Art | Existing | `c_heal: 1.2` + `second_brew` 4 s timer (`heal 0.04` + 1 Wood buff); also triggered on `pill_burned` |
| `smoke-over-the-burner` | Art | Existing | `debuff: [3, 6]` Fire + 6 s `dampen_taken: 18` (`wood`) & `resist: 18` (`chaos`) (~15% poison/tick reduction) |
| `falling-plum-flute-canon` | Tech (T2) | Existing | 2 bonuses, 5 passives (24.0/24 W), 2 arts |
| `the-fifth-month-tune` | Art | Existing | `slowed_time` 2 stacks (5 s) + 3 s `fifth_month_tune` + `tune_notes` + `tune_soul_cut` (`free_hit soul`) |
| `plum-falls-between-notes` | Art | Existing | Guarded `own.counter.fifth_month_tune >= 1`; `hit_landed` scaled by `tune_notes` (`free_hit 0.35 force`), ends tune |
| `lone-crane-metal-canon` (new) | Tech (T3) | Existing | Stand-in for `tu_khong_hac_nien` (`thien_kim`, L12); 2 non-stance sword arts (`crane-edge-draw`, `broken-sleeve-stroke`) |
| `vermilion-tide-breath` (new) | Tech (T1) | Existing | Stand-in for `thu_van_trieu`, `trau_vong_bang`, `thu_tieu_chu`; Water sustain art `long-oar-stroke` |
| `Where All Waters Return` | Effect (Item) | Existing (`approx`) | First `was_hit` leaving `hp_share <= 0.67` refunds blow (`heal of: amount`) and arms `vase_held`; at `hp_share <= 0.5` spills 4 Ice + 4 Fire stacks & arms `vase_spilled`; `down` + `tag.tribulation` -> `refuse_down 0.2` |
| `A Crane Crosses from the East` | Effect (Item) | Existing (`approx`) | `evaded` `free_hit {c: 0.7, dtype: "phys"}` (cd 1 s) gated on `own.fired_within.60.tag.wind >= 1` (sleeps in pure Metal hand) |
| `The Blue Sea Becomes Mulberry Fields` | Effect (Item) | Existing (`approx`) | First `was_hit` (`dtype: "lightning"`, `event.amount > 0`) refunds HP (`heal of: amount`) + `ward_grow {share: 0.08, of: "hp"}` |
| `The Unspent Bolt` | Effect (Item) | Existing (`approx`) | `crit` lays 1 Ice + 1 Thunder stack + `frozen_bolt +1`; at 5 stacks fires `free_hit` Lightning `1.2` + Cold `1.2` and consumes 5 Ice + 5 Thunder |
| `Purple Smoke on the Burner` | Effect (Item) | Out of fight (`not_run`) | Pure alchemy crafting (+1 grade, half đan độc) & abode A-2 story event; `not_run` with `records: []` |
| `Noon on One Side` | Effect (Item) | Existing (`approx`) | `art_fired` (`tags: ["fan"]` or `art_id: "fan-gust"`): if `foe.debuff.fire >= 5` consumes Fire into `free_hit {c: 0.25, dtype: "fire"}`/stack (+ once/fight `sundered` + `0.4` shield-passing Fire burst); lays 2 Fire + cleanses 1 own Ice |
| `The Falling Plum Tune` | Effect (Item) | Existing (`approx`) | `art_fired` (`tags: ["song", "sword"]`, cd 6 s) applies `slowed_time` 2 (4 s) + 4 s `plum_tune`; sword `hit_landed` while active fires `free_hit {c: 0.45, dtype: "soul"}` |
| `The World Before` | Effect (Set 2pc) | Existing | On `pulse` when `own.counter.vase_spilled >= 1`: `stop_clock` foe 2 s + 2 s `world_before_win`; each `art_fired` during window lays 1 stack of `fire`, `water`, `earth`, `metal`, `wood`, `ice`, `light` |
| `The Crane Wakes` | Effect (Set 3pc) | Existing | `crit` (cd 1 s): `free_hit {c: 0.7, dtype: "phys"}` |
| `Hears and Answers` | Effect (Set 3pc) | Existing (`approx`) | `fight_start`: `decoy {n: 1}` + `pool_heard = 1`; `decoy_struck` -> `free_hit {c: 0.9, dtype: "cold"}` + 2 Water stacks; `was_hit` (`dtype: "lightning"`, `amount > 0`) -> `gain_qi {share: 0.03}` |

## Steps
- [x] 1. Verify first: mechanic table, spatial scan, ID uniqueness, standalone Effect compilation plan.
- [x] 2. Techniques and arts (staged in `design/stage6-staging/hermits-sages/`, art IDs written into `hermits-sages.techniques.json`).
- [x] 3. Effects (staged in `design/stage6-staging/hermits-sages/effects/hermits-sages.effects.json`).
- [x] 4. Items and sets (staged in `design/stage6-staging/hermits-sages/items/`).
- [x] 5. Stand-ins (7 picks applied to `hermits-sages.cast.json` and `hermits-sages.2.cast.json`).
- [x] 6. Beasts (none: 0 beasts).
- [x] 7. Holder check (`lint_techniques`, `lint_arts`, `lint_items`, `engine.validate`, `depth_check`, `stage6_merge --check`, `sect_fight.py` `--gap 0` / `--gap 1`, targeted probes).
- [x] 8. Review file (`production/plans/stage6/hermits-sages-review.md`).
- [x] 9. Finish (`RECORD PASS DONE`, `production/plans/stage6/hermits-sages.done`).

RECORD PASS DONE
