# Ngạo Tuyết Phái (`ngao_tuyet`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged under `design/stage6-staging/ngao_tuyet/`; nothing exported, nothing written outside allowed paths):**
- **3 techniques** (`techniques/catalogue-sect-ngao_tuyet.json`): `cold-plum-sword-primer` (T0 Yellow main, `names: ["kim"]`, `7.9 W of 8`), `plum-through-snow-sword-canon` (T1 Profound main, `names: ["kim"]`, `khi_huyet_pct 10`, `15.3 W of 16`), and `lone-branch-sword` (T1 Profound secret, `names: ["kim"]`, `attack_pct 10`, `15.7 W of 16`). All bonuses and passives are new and sized to each tier's budget (§C).
- **5 new arts** (`arts/part-sect-ngao_tuyet.json`): `first-petal` (`cold-plum-sword-primer` L1), `five-petals` (`plum-through-snow-sword-canon` L1), `bloom-in-the-snow` (`plum-through-snow-sword-canon` L4), `bare-winter` (`lone-branch-sword` L1), and `last-blossom` (`lone-branch-sword` L4). Existing `flying-sword` (`family-blade.json`) is carried at L2 of `plum-through-snow-sword-canon`. All 5 new art ids were inserted into `design/world/depth/sects/ngao_tuyet.techniques.json`.
- **3 Effects** (`effects/ngao_tuyet.effects.json`): `One Flower on Iron` (`ngt-plum-in-snow-sword`), `The Tiger's Weight` (`ngt-thach-khau-tiger-hide`), and `Bare Branch Blooms` (`ngt-plum-and-snow` 2-piece set). All 3 pass standalone `engine.validate` with local counter declarations and zero multi-`mod` or `always`-filter traps.
- **3 items and 1 set** (`items/catalogue-sect-ngao_tuyet.json`, `items/sets-ngao_tuyet.json`): `ngt-plum-in-snow-sword` (`phi_kiem` 3), `ngt-thach-khau-tiger-hide` (`giap` 3), `ngt-han-mai-snow-cloak` (`dao_bao` 3), and set `ngt-plum-and-snow` (2 pieces). All 3 carry `sources: ["npc"]`, `unique: true`, and the R6 `exception` mark.
- **0 stand-ins, 0 beasts:** all 16 living members (`ngao_tuyet.cast.json` + `ngao_tuyet.5.cast.json`) already reference `cold-plum-sword-primer` or `plum-through-snow-sword-canon`; `ngao_tuyet` has no `beasts.json`.
- **Deviations:** 7 documented below (§A, §C–§E).
- **Pending words:** none (`[]`).
- **Early promotions:** none (`[]`).
- **Never ran in default `sect_fight.py`:**
  - `Bare Branch Blooms` (`ngt-plum-and-snow`): `0` runs at `--gap 0` on `lang_dap_tuyet` because he defeats the `typical` `truc_co` foe in `14.5 s` at `90 %` HP without ever dropping below `50 %` HP or needing `Last Blossom`; at `--gap 1` it runs `5` times (1 per seed, `+5` Petals on `refused` via `last_blossom_saved`), and in a 20-seed probe against a harder `truc_co` foe (`n_body 2.5`, `layers [150, 110, 60, 20, 0]`) it lifts wins from `12/20` (`25.40 s`, `6.4 %` HP) to **`14/20` (`25.20 s`, `6.7 %` HP)**.
- **Checks (after final edit, `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\ngao_tuyet`):**
  - `lint_arts.py`: 5 arts, **0 findings**.
  - `lint_techniques.py`: 3 techniques, **0 findings** (`7.9 W/8`, `15.3 W/16`, `15.7 W/16`).
  - `lint_items.py`: 3 items, **0 findings** (`unique 3 of 3`).
  - Standalone Effect `engine.validate`: **STANDALONE_OK 3**.
  - `depth_check.py --quiet`: **findings: none**.
  - `spatial_words_check.py --sect ngao_tuyet`: 1 soft hit only (`beside` in `pho_ngao_suong` tie note); **0 `removed` or `postponed` hits**.
  - `sect_fight.py ngao_tuyet --seeds 5` at `--gap 0` and `--gap 1`: **0 REFUSED** across all 16/16 living members, every slotted art fires (`0 NEVER_FIRED`), and all 3 Effects run and change fight outcomes in targeted probes.
- **Open items (for serial step / Stage 7):** merge `design/stage6-staging/ngao_tuyet/` into `design/` and `assets/data/combat_effects.json`; export via `export_techniques.py`, `export_named.py`, `export_combat_library.py`, and `export_world.py --sect ngao_tuyet` (closes the 3 structured `events` in `depth_gap.py`).

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Narrow `names` on `cold-plum-sword-primer` and `plum-through-snow-sword-canon` to `["kim"]` in the staged catalogue.**
   - *Choice:* List `names: ["kim"]` (instead of `["kim", "moc"]`) on both staged main techniques while keeping Wood in `five-petals`'s debuff payload and in the technique `concept`.
   - *Reason:* `CongPhap.usable()` requires every element in `names` (`src/gameplay/cultivation/cong_phap.gd`), whereas five Ngạo Tuyết members have `kim + tho` roots with no `moc` (`truong_luyen_phong`, `hau_thach_nhan` on the Primer; `an_lanh_phong`, `chung_thiet_tuyen`, `duong_tam_mach` on the Canon) and `ngao_tuyet.md` §§4, 6 state the gate rule is Metal-only (`kim >= 30` / `>= 45`). Narrowing `names` to `["kim"]` follows `tung_dao`'s `listening-pine-primer` precedent so all 16/16 living members pass `CongPhap.usable()`, and all carried abilities have `element` in `{"", "metal"}`.

2. **Treat `bloom-in-the-snow` and `bare-winter` as active Metal sword arts (`c_art: 1.5` / `1.6`) carrying their passive rules in `effects`, and unlock `bloom-in-the-snow` and `last-blossom` at layer 4.**
   - *Choice:* Author `bloom-in-the-snow` and `bare-winter` as active Metal sword cuts (`part-sect-ngao_tuyet.json`) alongside `five-petals` (L1), `flying-sword` (L2), `bare-winter` (L1), and `last-blossom` (L4).
   - *Reason:* Keeps `arts_new` at `0 rule text` in `depth_gap.py` once exported, fits all 6 of `lang_dap_tuyet`'s arts (`five-petals`, `flying-sword`, `bloom-in-the-snow`, `bare-winter`, `last-blossom`, `iron-hide-stance`) cleanly within `MAX_ARTS = 6`, lets every holder fire every slotted art (`0 NEVER_FIRED`), and places `bloom-in-the-snow` / `last-blossom` at L4 so `cong-phap rule 17` (`<= 6`) holds while `pho_ngao_suong` (L4 `lone-branch-sword`) and `duong_tam_mach` (L4 `plum-through-snow-sword-canon`) unlock their full suites.

3. **Unify `plum_petal` (`each_for: 12`, uncapped) across `first-petal`, `five-petals`, `One Flower on Iron`, and `Bare Branch Blooms`, with `first_petal_ready` preventing natural-crit theft.**
   - *Choice:* Use `plum_petal` (`each_for: 12`, distinct from `bang_tam`'s `petal` counter) on `first-petal` (`+1` per hit), `five-petals` (`+1` per sub-hit), `Bare Branch Blooms` (`+5` on `last_blossom_saved` `refused`), and `One Flower on Iron` (spends all `plum_petal` on `crit [sword]` for `1` or `2` Wood debuff stacks per Petal); `first-petal` arms `first_petal_ready` on `art_fired` when `plum_petal >= 5` so hit #5's natural crit never prematurely spends the sure-crit charge meant for the next thrust.
   - *Reason:* `lang_dap_tuyet` uses `plum-through-snow-sword-canon` rather than `cold-plum-sword-primer`, so `five-petals` must feed `plum_petal` for `One Flower on Iron` and `Bare Branch Blooms` to function before `Last Blossom`; `each_for: 12` bounds scaling without caps.

4. **Map "Wood bleed stack" (`Five Petals`, `One Flower on Iron`) to Wood debuff stacks (`stacks {el: "wood", for: 8, side: "foe"}`).**
   - *Choice:* Apply Wood debuff (Poison) stacks rather than Physical `bleed` status.
   - *Reason:* Both `lang_dap_tuyet`'s and `pho_ngao_suong`'s `tree.targets_note` explicitly walk to Falling Leaves for "the Wood bleed", and `ngt-plum-in-snow-sword` carries `stack_effect_pct 16 [moc, debuff]`.

5. **Latch `has_companion` on `kind: "companion"` events when `own.since.flying-sword >= 12` for `Bare Winter` and `Bare Branch Blooms`.**
   - *Choice:* Follow `cuu_cao`'s `kind: "companion"` latch pattern (`since.flying-sword >= 12`) rather than adding a new `own.companions` engine readable, so `plum-through-snow-sword-canon`'s own `flying-sword` summon does not shut off `lone-branch-sword` or `ngt-plum-and-snow`, while any bonded beast companion (striking at `t = 1.0 s`, well before `flying-sword`'s `8.0 s` cooldown) latches `has_companion = 1`.
   - *Reason:* Neither engine exposes a live `own.companions` readable; `flying-sword` is the sect's own canon art and `lang_dap_tuyet`'s `tree.intent` states "he fights with no companion". Verified in `pho_ngao_suong` probe (`27.29 s` solo vs `25.38 s` with `c: 0.5` beast companion).

6. **Model `Last Blossom`'s 1 s at 1 HP via `refuse_down {}` + `stop_clock {side: foe, seconds: 1.0}` + `mod {dmg_more: 1.0, tags: ["sword"], for: 1.0}` + `last_blossom_saved = 1`.**
   - *Choice:* Use `stop_clock` 1.0 s on the foe alongside `refuse_down {}` (`1.0` HP) instead of `dampen_taken`.
   - *Reason:* Both engines enforce `min_hit = 1.0` on any non-zero hit reaching health, so any unblocked foe blow during that second would immediately kill a 1 HP holder even through `dampen_taken: 9900`. Stopping the foe's clock for 1 s preserves the exact "1 health for 1 second to answer it" rule, and `last_blossom_saved` ensures `Bare Branch Blooms`'s `on: "refused"` trigger only fires when `Last Blossom` saved the holder.

7. **Gate `The Tiger's Weight` (`ngt-thach-khau-tiger-hide`) on `foe.boss == 0` with `stop_clock {side: foe, seconds: 1.0}` at `fight_start`, and mark all 3 signature items `unique: true` with R6 `exception`.**
   - *Choice:* Apply `stop_clock {side: foe, seconds: 1.0}` on `fight_start` when `foe.boss == 0` (marked `approx`), and carry `sources: ["npc"]`, `unique: true`, and R6 `exception` on all 3 items (`phi_kiem`, `giap`, `dao_bao`).
   - *Reason:* Neither engine exposes `foe.creature` or `foe.realm` (`minh_loan` Decision 2 precedent), so `foe.boss == 0` avoids inventing a narrow readable while keeping the opening 1 s hesitation live in duels; R6 `exception` and `unique: true` follow standing rulings (`DECISIONS-2026-11-26.md`).

---

## B. Mechanic table

Recorded in `production/plans/stage6/ngao_tuyet.md` (Step 1). `spatial_words_check.py --sect ngao_tuyet` reports **0 `removed` or `postponed` hits**.

---

## C. Techniques (`design/stage6-staging/ngao_tuyet/techniques/catalogue-sect-ngao_tuyet.json`)

The depth records name no bonuses or passives. **All bonuses and passives below are new** and sized against same-tier catalogue peers (`nine-temper-scripture`, `hundred-blades-canon`, `afterimage-sword-canon`).

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Abilities (unlock layer) | W budget |
|---|---|---|---|---|---|
| `cold-plum-sword-primer` | T0 Yellow main, `kim` | none | `attack_pct` 3 `[kim]`, `crit_chance_pct` 4 `[sword]`, `art_speed_pct` 5 `[sword]`, `khi_huyet_pct` 2 `[]` | `first-petal` (1) | **7.9 W of 8** |
| `plum-through-snow-sword-canon` | T1 Profound main, `kim` | `khi_huyet_pct` 10 | `attack_pct` 5 `[sword]`, `crit_chance_pct` 5 `[sword]`, `crit_damage_pct` 12 `[sword]`, `stack_effect_pct` 12 `[moc, debuff]`, `art_speed_pct` 6 `[sword]`, `linh_luc_regen_inc_pct` 1 `[]` | `five-petals` (1), `flying-sword` (2, existing), `bloom-in-the-snow` (4) | **15.3 W of 16** |
| `lone-branch-sword` | T1 Profound secret, `kim` | `attack_pct` 10 | `attack_pct` 6 `[sword]`, `crit_chance_pct` 6 `[sword]`, `crit_damage_pct` 15 `[sword]`, `art_cost_pct` −5 `[sword]`, `pierce_pct` 4 `[sword]` | `bare-winter` (1), `last-blossom` (4) | **15.7 W of 16** |

**Deviations (D1–D2):**
- **D1:** New tier-sized bonuses and passives added to all 3 techniques.
- **D2:** Staged `names` narrowed from `["kim", "moc"]` to `["kim"]` on `cold-plum-sword-primer` and `plum-through-snow-sword-canon` (Decision 1).

---

## D. Arts (`design/stage6-staging/ngao_tuyet/arts/part-sect-ngao_tuyet.json`)

`lint_arts.py`: **5 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `first-petal` (`cold-plum-sword-primer`, L1) | Fast thrust dealing Metal damage, +1 Petal; 5 Petals make next thrust a critical hit | Metal `phys`, `c_art 1.3`, `cost 0.02`, `cd 1.5`, `tags [metal, sword, quick]`; `hit_landed` adds 1 `plum_petal` (`each_for 12`); `always` `sure_crit 1 [sword]` at `plum_petal >= 5`; `art_fired` arms `first_petal_ready` at `>= 5` and `crit [sword]` spends 5 | **D3:** `plum_petal` expires in 12 s (`each_for`) rather than unboundedly, and `first_petal_ready` prevents natural crit on hit #5 from spending the charge |
| `five-petals` (`plum-through-snow-sword-canon`, L1) | Five quick thrusts; each lands a Metal hit and leaves a Wood bleed stack on the foe | Metal `phys`, `c_art 1.8`, `cost 0.04`, `cd 4.0`, `split [0.2]*5`, `tags [metal, sword, quick]`; each `hit_landed` lays 1 Wood debuff (`for 8`) and adds 1 `plum_petal` (`each_for 12`) | **D4:** "Wood bleed" mapped to Wood debuff stacks (`poison`), and each thrust also grants 1 `plum_petal` so canon holders feed `One Flower on Iron` and `Bare Branch Blooms` (Decisions 3–4) |
| `bloom-in-the-snow` (`plum-through-snow-sword-canon`, L4) | Below half health, sword arts strike critically more often and each crit heals a little | Metal `phys`, `c_art 1.5`, `cost 0.03`, `cd 4.0`, `tags [metal, sword]`; while `hp_share < 0.5`: `always` `crit +15 [sword]` and `crit [sword]` (`per_pulse 2`) `heal 0.025` | **D5:** given active `c_art 1.5` cut alongside passive `< 0.5 HP` crit/heal (Decision 2) |
| `bare-winter` (`lone-branch-sword`, L1) | With no companion, sword arts cost less linh lực and deal more damage | Metal `phys`, `c_art 1.6`, `cost 0.03`, `cd 4.0`, `tags [metal, sword]`; `has_companion` latches on `kind: companion` (`since.flying-sword >= 12`); while `has_companion == 0`: `always` `cost_red 0.15, dmg_more 0.15 [sword]` | **D6:** active `c_art 1.6` cut + `has_companion` latch excluding `flying-sword` (Decisions 2, 5) |
| `last-blossom` (`lone-branch-sword`, L4) | Once per fight, a killing blow leaves holder at 1 HP for 1 s, during which next sword art deals 2x damage | Metal `phys`, `c_art 1.8`, `cost 0.04`, `cd 5.0`, `tags [metal, sword, heavy]`; `on: down` (`per_fight 1`): `refuse_down {}` (1 HP), `stop_clock foe 1.0`, `mod {dmg_more 1.0, tags [sword], for 1.0}`, `last_blossom_saved = 1` | **D7:** `stop_clock` 1.0 s protects 1 HP from `min_hit = 1.0` during the 1 s window (Decision 6) |

---

## E. Effects (`design/stage6-staging/ngao_tuyet/effects/ngao_tuyet.effects.json`)

Every Effect declares all counters it reads or writes locally and passes standalone `engine.validate` (**STANDALONE_OK 3**).

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `One Flower on Iron` (`ngt-plum-in-snow-sword`) | Each Petal held makes next sword crit leave a Wood bleed stack; at 5 Petals the bleed is doubled | `counters: [plum_petal (each_for 12)]`; on `crit [sword]`, mutually exclusive `< 5` (`1 * plum_petal` Wood debuffs, 8 s) and `>= 5` (`2 * plum_petal` Wood debuffs, 8 s), then `plum_petal = 0` | shares **D4** (Wood debuff stacks; spends `plum_petal` on crit) |
| `The Tiger's Weight` (`ngt-thach-khau-tiger-hide`) | Beasts of Luyện Khí and Trúc Cơ strength hesitate: first attack each fight delayed 1 s | On `fight_start`, if `foe.boss == 0`: `stop_clock {side: foe, seconds: 1.0}` | `approx`: gates on `foe.boss == 0` (no `foe.creature` or `foe.realm` readable; Decision 7) |
| `Bare Branch Blooms` (`ngt-plum-and-snow`, 2pc) | No companion & < 50 % HP: each Petal adds 6 % sword crit damage; when Last Blossom saves you, gain 5 Petals | `counters: [plum_petal (each_for 12), has_companion, last_blossom_saved]`; `has_companion` latch (`since.flying-sword >= 12`); `always` `< 0.5 HP` & `has_companion == 0` scaled by `plum_petal`: `crit_mult 6 [sword]`; `on: refused` (`last_blossom_saved >= 1`, `per_fight 1`): `plum_petal +5` | `approx`: `has_companion` latch excludes `flying-sword` (Decision 5) |

---

## F. Items & Sets (`design/stage6-staging/ngao_tuyet/items/catalogue-sect-ngao_tuyet.json`, `sets-ngao_tuyet.json`)

- **3 unique NPC items** (`sources: ["npc"]`, `unique: true`, R6 `exception` on all 3): `ngt-plum-in-snow-sword` (`phi_kiem` 3, `30.9 W of 38.4`), `ngt-thach-khau-tiger-hide` (`giap` 3, `30.4 W of 38.4`), `ngt-han-mai-snow-cloak` (`dao_bao` 3, `18.0 W of 38.4`). `lint_items.py`: **3 items, 0 findings**.
- **1 set** (`ngt-plum-and-snow`, 2 pieces): `crit_chance_pct 3 [sword]`, `khi_huyet_pct 5 []` + Effect `Bare Branch Blooms (Khô Chi Khai Hoa)`.

---

## G. Stand-ins & Beasts

- **Stand-ins:** `0` (`cold-plum-sword-primer` and `plum-through-snow-sword-canon` cover all 16 living members).
- **Beasts:** `0`.
- **Depth art ids:** inserted `"id"` before `"new"` on all 5 new arts in `design/world/depth/sects/ngao_tuyet.techniques.json`; `depth_check.py --quiet` returned `findings: none`.

---

## H. Pending words

None (`[]`).

---

## I. Holder table (`sect_fight.py ngao_tuyet --seeds 5`, `--gap 0` & `--gap 1`, plus 20-seed probes)

**0 REFUSED across all 16/16 living members; every slotted art fires (`0 NEVER_FIRED`).**

| Holder / Probe | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects / Art fires |
|---|---|---|---|---|---|
| `lang_dap_tuyet` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `bare-winter`, `last-blossom`, `iron-hide-stance` | 14.5 s, 5/5, 90 % | 14.2 s, 0/5, 0 % | All 6 arts fire (3.2/1.4/3.2/3.2/2.6/2.0 G0; 2.8/1.0/2.8/2.8/1.6/1.0 G1). `One Flower on Iron`: 34 runs G0, 36 runs G1. `Bare Branch Blooms`: 0 runs G0 (>50 % HP), 5 runs G1 (`Last Blossom` save +5 Petals). |
| `lang_dap_tuyet` (probe vs 3x HP `truc_co`, 20 seeds) | `truc_co` | same | **20.84 s, 20/20** (without `One Flower`: **21.83 s, 20/20**) | — | `One Flower on Iron` cuts kill time by `0.99 s`. |
| `lang_dap_tuyet` (probe vs `nb=2.5, layers=[150,110,60,20,0]`, 20 seeds) | `truc_co` | same | **25.20 s, 14/20, 6.7 %** (without `Bare Branch Blooms`: **25.40 s, 12/20, 6.4 %**) | — | `Bare Branch Blooms` adds +2 wins (`+0.3 %` HP, `−0.20 s`). |
| `trac_thiet_can` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `iron-hide-stance` | 27.5 s, 5/5, 100 % | 15.6 s, 0/5, 0 % | All 4 arts fire (7.0/3.2/7.0/4.2 G0; 2.0/1.0/3.2/1.0 G1). `The Tiger's Weight`: 5 runs G0 (`27.5 s` vs `26.6 s`), **5 runs G1 (`15.6 s` vs `14.2 s`, +1.4 s survival)**. |
| `pho_ngao_suong` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `bare-winter`, `last-blossom` | 18.9 s, 5/5, 67 % | 10.0 s, 0/5, 0 % | All 5 arts fire (4.8/2.0/4.8/4.8/4.0 G0; 2.0/1.0/2.0/2.0/2.0 G1). 20-seed 2x-HP probe: `27.29 s` solo vs `25.38 s` with `c: 0.5` beast companion. |
| `mac_chiet_chi` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `iron-hide-stance` | 26.9 s, 5/5, 75 % | 11.2 s, 0/5, 0 % | All 4 arts fire (6.6/3.2/6.4/4.2 G0; 2.0/1.0/2.4/1.0 G1). |
| `chung_thiet_tuyen`, `duong_tam_mach` | `truc_co` | `five-petals`, `flying-sword`, `bloom-in-the-snow`, `iron-hide-stance` | 27.4 s, 5/5, 75 % | 11.2 s, 0/5, 0 % | All 4 arts fire (6.8/3.2/6.8/4.2 G0; 2.0/1.0/2.4/1.0 G1). |
| `cung_han_nhan` | `luyen_khi` | `five-petals`, `flying-sword` | 41.6 s, 3/5, 7 % | 8.0 s, 0/5, 0 % | Both arts fire (9.0/3.4 G0; 2.0/1.0 G1). |
| `la_thiet_mai`, `ha_tuyet_nhan`, `so_bang_chi` | `luyen_khi` | `five-petals`, `flying-sword` | 40.2 s, 3/5, 7 % | 8.0 s, 0/5, 0 % | Both arts fire (8.6/3.4 G0; 2.0/1.0 G1). |
| `an_lanh_phong` | `luyen_khi` | `five-petals`, `flying-sword` | 40.0 s, 1/5, 1 % | 8.0 s, 0/5, 0 % | Both arts fire (8.6/3.4 G0; 2.0/1.0 G1). |
| `du_ho_van`, `phi_tam_mai`, `doan_mai_cot`, `truong_luyen_phong`, `hau_thach_nhan` | `luyen_khi` | `first-petal` | 44.6 s, 2/5, 5 % | 8.0 s, 0/5, 0 % | `first-petal` fires `26.8` G0 / `5.0` G1 (`du_ho_van` 20-seed G0: `42.69 s`, `10/20`, `7.8 %`). |

REVIEW DONE
