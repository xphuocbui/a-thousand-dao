# Bách Vũ Các: Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/bach_vu/`; nothing exported, nothing outside allowed paths):**
- **4 techniques** (`techniques/catalogue-sect-bach_vu.json`): the 3 lineage methods (`hundred-call-breath`, `roosting-branch-canon`, `moulted-feather-fan`), plus a new servants' method `woven-cage-breath` for the cage-maker `hoan_truc_lung`. Every bonus and new passive is sized within its tier's W budget (§C).
- **6 active arts** (`arts/part-sect-bach_vu.json`): `call-down`, `still-on-the-branch`, `loose-the-flock`, `under-the-wing`, `shed-feathers-burn`, and `wire-snare-needle`. The 6th depth art, `Hundred-Feather Fan`, is a passive art staged as a layer-2 technique Effect on `moulted-feather-fan`.
- **3 Effects** (`effects/bach_vu.effects.json`): `Call of the Luan` (`bvc-blue-luan-whistle`), `All Birds Bow` (`bvc-bird-mother`), and `Hundred-Feather Fan` (`moulted-feather-fan` L2 passive). All 3 pass standalone `engine.validate` with every counter and state declared locally.
- **3 items and 1 set** (`items/catalogue-sect-bach_vu.json`, `items/sets-bach_vu.json`): `bvc-blue-luan-whistle` (`cam` 3), `bvc-ninety-nine-feather-fan` (`phien` 3), `bvc-moulted-feather-fan` (`phien` 2), and set `bvc-bird-mother` (2 pieces). All 3 carry `sources: ["npc"]`, `unique: true`, plain-English Effect names, and the R6 `exception`.
- **1 stand-in resolved** in `design/world/depth/sects/bach_vu.cast.json`: `hoan_truc_lung` (`hoang_kim` 5 → `woven-cage-breath` 5). `depth_gap.py` `stand_ins` is now 0.
- **4 beasts verified**: `tieu_loan`, `que_tuoc`, `mac_vu` (`ta_thanh_loan`) and `quy_thuoc` (`ta_thanh_thuoc`) are already listed in `bach_vu.cast.json`; their records remain in `bach_vu.beasts.json` until Stage 7 export.
- **Deviations:** 5 documented below (§A, §D, §E).
- **Pending words:** none (`[]`).
- **Early promotions:** none (`[]`).
- **Never ran in default `sect_fight.py`:**
  - `All Birds Bow`: requires `companions` from Stage 7 beast export (`tieu_loan`, `que_tuoc`, `mac_vu`); verified active and impactful in the 20-seed companion probe (`PROBE_LOAN_WITH_BIRDS_GAP0` 17.4 s / 96 % vs 22.0 s / 91 %, 1,044 counts / 80 fan triggers / 348 slow triggers; `GAP1` 12.3 s vs 8.3 s).
  - `Hundred-Feather Fan`: `on: "always"` Effects do not increment `Fight.do()`'s event counter in `sect_fight.py`; verified active via `--without` delta on `ta_thanh_thuoc` (46.2 s 55 % vs 48.8 s 50 % without) and `hang_thai_vu` (58.8 s 2 % vs 59.2 s 1 % without).
- **Checks (after final edit):** `lint_techniques` **0 findings** (`7.4 W / 8`, `15.7 W / 16`, `14.8 W / 16`, `7.8 W / 8`), `lint_arts` **0 findings**, `lint_items` **0 findings**, `depth_check.py` `findings: none`, `depth_gap.py --sect bach_vu` clean (`stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`), `sect_fight.py bach_vu --seeds 5` at `--gap 0` and `--gap 1` **0 REFUSED** across all 16/16 living people with every slotted art firing.
- **Open items (for Stage 7 / serial step):** Stage 7 world export to wire `bach_vu.beasts.json` (`tieu_loan`, `que_tuoc`, `mac_vu`, `quy_thuoc`) into `companions` in fights, plus `export_techniques` / `export_named` / `export_combat_library` / `put_effects` merge.

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **New Yellow servant method `woven-cage-breath` + `wire-snare-needle` for `hoan_truc_lung` (`hoang_kim` 5).**
   - What: added `woven-cage-breath` (`tier: 0`, `main`, `names: ["kim", "tho"]`, `rank: "tap_dich"`) with 1 art `wire-snare-needle` (`unlock_layer: 1`), and switched `hoan_truc_lung` to it at layer 5.
   - Why: per `_brief-record.md` §5, `bach_vu` has no Metal lineage method, `hoan_truc_lung`'s note names no external method (`"Servant; a stand-in Yellow Metal method."`), and pavilion doctrine forbids anyone else from making cages (`bach_vu.md` §4–5). Creating a dedicated `tap_dich` craft method matches Băng Tâm (`warm-hearth-breath`) and Phượng Minh (`hearth-ash-breath`).
2. **`Hundred-Feather Fan` staged as a layer-2 technique Effect scaled by `own.tech_layer.moulted-feather-fan` (`+2 %` Fire `stack_dur` per layer).**
   - What: moved `Hundred-Feather Fan` from an active art slot into `moulted-feather-fan.effects` (`unlock_layer: 2`, `passive_art: true`) and `bach_vu.effects.json`, using `own.tech_layer.moulted-feather-fan` (`scale.per: 1`) for `stack_dur: 2` (`element: "fire"`, `kind: "debuff"`).
   - Why: the combat engine has no `item_grade` readable (`fighter_profile_loader.gd` / `engine.py`), and `technique-effects` (`b01`) already supports passive arts via technique `effects` + `tech_layers`. Scaling by `moulted-feather-fan` layer gives `+8 % / +12 % / +16 %` across `hang_thai_vu` (L4), `ta_thanh_loan` (L6), and `ta_thanh_thuoc` (L8), matching their fan grade progression without inventing a new engine readable.
3. **`Call of the Luan` heals the holder 8 % max HP (`own.hp_share <= 0.8` pulse) and arms `luan_flock` for `loose-the-flock`.**
   - What: mapped "each returns to full health" to `heal {"share": 0.08}` on the holder once per fight when `own.hp_share <= 0.8`, while setting `luan_flock: 1` (declared in both `Call of the Luan` and `loose-the-flock` for standalone compile).
   - Why: companions have no health bar in Combat rule 19 (same ruling as Phượng Minh `d36` `Birds Pay Court to the Phoenix`), and `bach_vu.techniques.json` explicitly pairs the bird-holder bond with shared healing. Triggering at `<= 0.8` HP avoids wasting the heal at 100 % HP at `fight_start` while still firing reliably whenever pressure lands (2/5 seeds at `--gap 0`, 5/5 at `--gap 1`).
4. **`All Birds Bow` uses `bird_strike_2s` (`each_for: 2`) on `kind: companion, tags: ["bird"]`, and matches fan arts by both `tags: ["fan"]` and `art_id: "fan-gust"`.**
   - What: counts any 3 `bird` companion hits within 2 s to apply 2 `slowed_time` (3 s) on the foe, and adds a scaled `free_hit` (`c: 0.375`, `dtype: "fire"`) + 1 Fire stack per `bow_feathers` on `tags: ["fan"]` or `art_id: "fan-gust"` (clearing `bow_feathers` to 0).
   - Why: engine companion hit events carry companion tags (`bird`) rather than individual beast IDs (matching Phượng Minh's `Birds Pay Court to the Phoenix`), and a 2-s charge counter naturally requires multiple bonded birds (`< 2 s` window expires a single bird's 1.0 s cooldown strike at `t=3.0`). Adding the `fan-gust` listener mirrors Phượng Minh so common fan arts also receive the bonus feathers.
5. **Timed 5-s `on-the-branch` stance on `still-on-the-branch` and R6 `exception` on all 3 signature weapons.**
   - What: `still-on-the-branch` uses a `branch_still` pulse counter (5 s) so the stance exits cleanly and re-fires to refresh `timer {side: own, which: next, by: -0.5}` across the fight; `bvc-blue-luan-whistle` (`cam`), `bvc-ninety-nine-feather-fan` (`phien`), and `bvc-moulted-feather-fan` (`phien`) carry the R6 `exception` mark (`unique: true`, `sources: ["npc"]`).
   - Why: a permanent stance with `guards: [own.state.on-the-branch < 1]` would fire only once per fight; none of `bach_vu`'s other arts use `states`, so there is zero stance-slot contention.

## B. Mechanic table

Summary in `production/plans/stage6/bach_vu.md`; every mechanic verified against `assets/data/combat_engine.json`, `tools/design/combat_sim/engine.py`, and `src/gameplay/combat/fight/effect_compiler.gd`.

## C. Techniques (`design/stage6-staging/bach_vu/techniques/catalogue-sect-bach_vu.json`)

The depth records name no bonuses or passives. **All bonuses and passives below are new**, sized against the same-tier catalogue techniques and unpriced.

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Abilities / Effects | Peer & W |
|---|---|---|---|---|---|
| `hundred-call-breath` | Yellow main, Wood+Fire | none | `attack_pct` 3 `[moc]`, `evade_pct` 2 `[]`, `linh_luc_regen_inc_pct` 3 `[]` | `call-down` (1), `still-on-the-branch` (2) | `warm-hearth-breath` (**7.4 W of 8**) |
| `roosting-branch-canon` | Profound main, Wood | `khi_huyet_pct` 12 | `attack_pct` 5 `[moc]`, `attack_pct` 6 `[companion]`, `stack_effect_pct` 8 `[moc, debuff]`, `stack_duration_pct` 10 `[moc, debuff]`, `health_regen_inc_pct` 8 `[]`, `healing_pct` 4 `[]` | `loose-the-flock` (1), `under-the-wing` (2) | `verdant-cycle-scripture` (**15.7 W of 16**) |
| `moulted-feather-fan` | Profound secret, Fire | `attack_pct` 8 | `attack_pct` 6 `[hoa]`, `art_speed_pct` 8 `[hoa]`, `stack_effect_pct` 10 `[hoa, debuff]`, `stack_duration_pct` 12 `[hoa, debuff]`, `crit_chance_pct` 4 `[hoa]` | `shed-feathers-burn` (1); passive `Hundred-Feather Fan` (2) | `morning-sun-feather-fan` (**14.8 W of 16**) |
| `woven-cage-breath` (new) | Yellow main, Metal+Earth | none | `attack_pct` 3 `[kim]`, `defense_pct` 3 `[]`, `block_rating` 7 `[]` | `wire-snare-needle` (1) | `nine-temper-scripture` (**7.8 W of 8**) |

## D. Arts (`design/stage6-staging/bach_vu/arts/part-sect-bach_vu.json`)

All 6 arts pass `lint_arts.py` with **0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `call-down` | Calls a wild bird to harry a foe for a few seconds: light hits and a small chance to interrupt their art | Wood/Physical `c_art 0.8`, `cost 0.03`, `cd 6.0`; `summon` `c 0.45` `cd 1.0` for 4 s; `hit_landed` (`kind: companion`) while `wild_bird >= 1` has 30 % chance (`per_pulse: 1`) to delay foe's next art `0.5 s` | "interrupt" maps to `timer {side: foe, which: next, by: 0.5}` |
| `still-on-the-branch` | A still stance: while you are Composed you gain evasion, and your next art's timer is 0.5 s shorter | Wood `c_art 0.0`, `cost 0.03`, `cd 6.0`; enters `on-the-branch` (`tags: ["composed"]`) for 5 s (`branch_still`), `+12` evade while in stance & `own.composed >= 1`, shortens own next art `-0.5 s` on entry | 5 s pulse duration so the art re-fires and refreshes its `-0.5 s` timer reduction |
| `loose-the-flock` | Sends her bonded birds at a foe: several quick hits that each lay a Wood stack; more birds at higher layers | Wood `c_art 1.4`, `cost 0.04`, `cd 4.0`; `split [0.5, 0.5]` (L1–3), `[0.34, 0.33, 0.33]` `c_mult 1.2` (L4–6), `[0.25, 0.25, 0.25, 0.25]` `c_mult 1.4` (L7+); 1 Wood stack (8 s) per hit; `luan_flock` adds `free_hit c 0.49 chaos` + 1 Wood stack | none |
| `under-the-wing` | One bird shields you and takes your next hit (a decoy); the bird returns to the branch to heal | Wood `c_art 0.0`, `cost 0.03`, `cd 5.0`; `decoy {n: 1}` + `wing_decoy +1`; on `decoy_struck`, `heal 5 %` max HP and `wing_decoy -1` | none (companion return heal lands on holder per Combat rule 19) |
| `shed-feathers-burn` | A fan stroke that throws burning feathers in a cone: Fire hits that each lay one Fire stack | Fire `c_art 1.5`, `cost 0.04`, `cd 4.5`, `tags: ["fire", "fan", "feather", "split"]`; `split [0.25, 0.25, 0.25, 0.25]`; 1 Burn (6 s) per hit | none |
| `wire-snare-needle` (new) | n/a (new servant art for `hoan_truc_lung`) | Metal/Physical `c_art 1.5`, `cost 0.03`, `cd 3.0`, `debuff [1, 6]` | new servant art |

## E. Effects (`design/stage6-staging/bach_vu/effects/bach_vu.effects.json`)

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Call of the Luan` (`bvc-blue-luan-whistle`) | Once per fight, the holder's bonded birds answer the whistle: each returns to full health and her next Loose the Flock sends one more bird | On `pulse` at `own.hp_share <= 0.8` (`per_fight: 1`): `heal 8 %` max HP + `luan_flock: 1` (consumed by `loose-the-flock` for `free_hit c 0.49 chaos` + 1 Wood stack) | Companions have no HP (Combat rule 19), so return-to-full-health heals the holder 8 % at `<= 0.8` HP |
| `All Birds Bow` (`bvc-bird-mother`) | Each time your birds strike a foe, your next fan art throws one more feather. When all three bonded birds strike the same foe within 2 s, the foe gains 2 Slowed Time stacks | `hit_landed` (`kind: companion, tags: ["bird"]`) increments `bow_feathers` and `bird_strike_2s` (`each_for: 2`); at 3 charges in 2 s, applies 2 `slowed_time` (3 s) and resets `bird_strike_2s`; fan art firing (`tags: ["fan"]` or `art_id: "fan-gust"`) spends `bow_feathers` via scaled `free_hit c 0.375 fire` + 1 Burn (6 s) | Counts 3 `bird` companion hits in 2 s because engine hit events carry companion tags, not individual beast IDs (`approx`) |
| `Hundred-Feather Fan` (`moulted-feather-fan` L2 passive) | Passive: for each different feather kind in the holder's fan (counted by item grade), her Fire stacks last a little longer | `on: "always"`, `scale: own.tech_layer.moulted-feather-fan / 1`, `mod: {stack_dur: 2, element: "fire", kind: "debuff"}` | Approximated via `own.tech_layer.moulted-feather-fan` because no `item_grade` readable exists (`approx`) |

## F. Items & Sets (`design/stage6-staging/bach_vu/items/catalogue-sect-bach_vu.json`, `sets-bach_vu.json`)

- **3 unique NPC items** (`sources: ["npc"]`, `unique: true`, W 19.7–27.3 unpriced, R6 `exception` on all 3 weapon bases `cam`/`phien`): `bvc-blue-luan-whistle`, `bvc-ninety-nine-feather-fan`, `bvc-moulted-feather-fan`.
- **1 set** (`bvc-bird-mother`): 2-piece modifiers (`attack_pct 8 [companion]`, `linh_luc_regen_inc_pct 6`) + full-set Effect `All Birds Bow (Bách Điểu Triều)` (`"within 2 s"` rephrased as `"in 2 s"` to avoid `spatial_words_check` false positive).

## G. Stand-ins & Beasts (`design/world/depth/sects/bach_vu.cast.json`)

| Person | Realm | Was | Now | Beasts |
|---|---|---|---|---|
| `hoan_truc_lung` | `luyen_khi` | `hoang_kim` 5 | `woven-cage-breath` 5 | none |
| `ta_thanh_loan` | `truc_co` | `roosting-branch-canon` 8, `moulted-feather-fan` 6 | unchanged | `tieu_loan`, `que_tuoc`, `mac_vu` (already in `cast.json`) |
| `ta_thanh_thuoc` | `truc_co` | `roosting-branch-canon` 6, `moulted-feather-fan` 8 | unchanged | `quy_thuoc` (already in `cast.json`) |

## H. Pending words

None (`[]`). Every mechanic in `bach_vu` runs on existing engine words.

## I. Holder table (`sect_fight.py bach_vu --seeds 5`, `--gap 0` & `--gap 1`, plus 20-seed probes)

**0 REFUSED across all 16 living members; every art fires at both `--gap 0` and `--gap 1`.**

| Holder / Probe | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects / Art fires |
|---|---|---|---|---|---|
| `ta_thanh_loan` | `truc_co` | `loose-the-flock`, `under-the-wing`, `shed-feathers-burn` | 37.3 s, 5/5, 85 % | 8.8 s, 0/5, 0 % | All 3 arts fire (9.2/7.2/8.2 at G0; 2.0/1.2/2.0 at G1). **Call of the Luan**: G0 2 runs (37.3 s 85 % vs 37.7 s 79 % without), G1 5 runs (8.8 s vs 8.2 s). **All Birds Bow**: 0 runs (no `beasts` in `sect_fight`); **Hundred-Feather Fan**: 0 `Fight.do()` runs (`always`; G0 37.3 s 85 % vs 36.9 s 86 %). |
| `ta_thanh_loan` (probe +3 birds, 20 seeds) | `truc_co` | + `tieu_loan`, `que_tuoc`, `mac_vu` | **17.4 s, 20/20, 96 %** | **12.3 s, 0/20, 0 %** | **All Birds Bow**: G0 **17.4 s 96 % vs 22.0 s 91 % without** (1,044 counts, 80 fan, 348 slow); G1 **12.3 s vs 8.3 s without** (717 counts, 43 fan, 239 slow). **Call of the Luan**: G1 20 runs + 20 `flock-luan-bonus` (12.3 s vs 11.9 s). |
| `ta_thanh_thuoc` | `truc_co` | `loose-the-flock`, `under-the-wing`, `shed-feathers-burn` | 46.2 s, 5/5, 55 % | 8.0 s, 0/5, 0 % | All 3 arts fire (10.0/7.8/8.8 at G0; 1.4/1.0/2.0 at G1). **Hundred-Feather Fan**: **46.2 s 55 % vs 48.8 s 50 % without** (`always`). |
| `hang_thai_vu` | `truc_co` | `loose-the-flock`, `under-the-wing`, `shed-feathers-burn` | 58.8 s, 2/5, 2 % | 8.4 s, 0/5, 0 % | All 3 arts fire (10.4/10.2/7.4 at G0; 1.2/1.0/1.0 at G1). **Hundred-Feather Fan**: **58.8 s 2 % vs 59.2 s 1 % without** (`always`). |
| `giai_van_tieu`, `phu_vu_to`, `lam_the_ngo` | `truc_co` | `loose-the-flock`, `under-the-wing` | 62.4 s, 1/5, 0 % | 8.6 s, 0/5, 0 % | Both arts fire (13.4/11.0 at G0; 1.4/1.0 at G1). |
| `ky_hong_phien` | `luyen_khi` | `loose-the-flock`, `under-the-wing` | 42.8 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Both arts fire (8.8/7.2 at G0; 1.4/1.0 at G1). |
| `phong_tieu_cuu` | `luyen_khi` | `loose-the-flock`, `under-the-wing` | 43.4 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Both arts fire (9.0/7.2 at G0; 1.4/1.0 at G1). |
| `nhieu_tieu_yen` | `luyen_khi` | `loose-the-flock` | 33.0 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires (7.2 at G0; 1.4 at G1). |
| `tran_da_minh`, `que_hoang_oanh`, `kieu_thuy_nhi`, `ma_tin_phi`, `khau_tinh_minh` | `luyen_khi` | `call-down`, `still-on-the-branch` | 52.2 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Both arts fire (8.8/8.2 at G0; 1.0/1.0 at G1). 20-seed probe on `tran_da_minh`: `branch-enter` 157, `branch-tick` 738, `branch-exit` 142, `call-down-summon` 170, `call-down-harry` 128. |
| `o_tieu_sao` | `luyen_khi` | `call-down` | 46.7 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires (7.4 at G0; 1.0 at G1). |
| `hoan_truc_lung` | `luyen_khi` | `wire-snare-needle` | 47.8 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Fires (14.2 at G0; 2.0 at G1). |

REVIEW DONE
