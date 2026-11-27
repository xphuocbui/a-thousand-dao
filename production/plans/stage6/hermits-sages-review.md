# Ẩn Sĩ — Hermits and Sages: Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/hermits-sages/`; nothing exported, nothing modified outside allowed paths):**
- **6 techniques** (`techniques/catalogue-sect-hermits-sages.json`): the 4 depth methods (`still-water-mirror-canon`, `north-wind-cold-light-sword`, `purple-smoke-furnace-canon`, `falling-plum-flute-canon`) plus 2 new stand-in methods (`lone-crane-metal-canon` T3 for `tu_khong_hac_nien`, `vermilion-tide-breath` T1 for the three coastal Water stand-ins). `purple-smoke-furnace-canon` carries existing committed `pill-smoke` at layer 4 (`censer-smoke-manual` & `part-sect-market-folk.json` preserved untouched).
- **11 new arts** (`arts/part-sect-hermits-sages.json`): the 8 open depth arts (`the-lake-shows-the-moon`, `walking-on-still-water`, `watchmans-gong`, `cold-light-on-iron-mail`, `second-brewing`, `smoke-over-the-burner`, `the-fifth-month-tune`, `plum-falls-between-notes`) plus 3 new stand-in arts (`crane-edge-draw`, `broken-sleeve-stroke`, `long-oar-stroke`). `pill-smoke` already runs in `part-sect-market-folk.json`.
- **10 Effects** (`effects/hermits-sages.effects.json`, `"source": "world-depth:hermits-sages"`): 7 item Effects + 3 set Effects. All 10 compile and pass `engine.validate()` standalone (`counters` / `states` declared on each Effect). 9 run in combat; 1 is `not_run` (`Purple Smoke on the Burner`: out-of-fight alchemy crafting + abode A-2 story choice). Zero `pending_words`.
- **13 items and 3 sets** (`items/catalogue-sect-hermits-sages.json`, `items/sets-hermits-sages.json`), with `sources: ["npc"]`, `unique: true`, `"rarity": 5` on the 3 grade-4 `kind: "treasure"` items (`hs-quy-khu-vase`, `hs-mirror-of-seas-and-fields`, `hs-purple-smoke-furnace`), `"where": "sealed abode A-*"` on sealed items, and R6 `"exception"` on the 9 weapon/body_gear/ward_gear items.
- **7 stand-ins resolved** across `design/world/depth/people/hermits-sages.cast.json` and `.2.cast.json`; all 8 open art IDs and 2 new stand-in techniques registered in `hermits-sages.techniques.json`. **0 beasts** (`hermits-sages` owns no beasts).

**Checks (`DEPTH_STAGE=design/stage6-staging/hermits-sages`):**
- `lint_arts.py`: **0 findings** (`11 arts`).
- `lint_techniques.py`: **0 findings** (`6 techniques`, `12` carried arts).
- `lint_items.py`: **0 findings** (`13 items`, `OVER_BUDGET` W lines are unpriced notes).
- `engine.validate()`: **10 / 10 standalone Effects valid**.
- `depth_check.py --quiet`: **findings: none**.
- `stage6_merge.py hermits-sages --check`: **0 failure(s)**.
- `depth_gap.py --sect hermits-sages`: `techniques 6 open`, `arts_new 12 (11 open, runs 1)`, `items 13 open`, `sets 3 open`, `effects 10 open`, `lines 56 (1 open: element_affinity_pct on hs-purple-smoke-furnace)`, `stand_ins 0`, `unknown_ids 0`, `cross_owner 1 (0 open)`, `engine_words 0`, `wishes_open 0`.
- `spatial_words_check.scan` on staged files: **0 `removed` / `postponed` / `soft` hits** (only 3 proper-noun `rename` false positives on `"Still"` / `"held still"`).
- `sect_fight.py hermits-sages --seeds 5` at `--gap 0` and `--gap 1`: **0 `REFUSED`**, every slotted art fires `> 0`. Targeted probes verified all `NEVER_RAN` clauses and all unslotted techniques/sealed items (§H).

**Counts:**
- **Deviations: 15** (§D–§F, numbered).
- **Decisions auto-accepted: 8** (§A).
- **Pending words: 0**.
- **Early promotions: 0** (`pill-smoke` / `censer-smoke-manual` already committed).

**Never ran on default `sect_fight.py` (with reasons + targeted probe results in §H):**
- `Purple Smoke on the Burner`: `not_run` (out-of-fight craft + abode A-2 story choice).
- `Where All Waters Return` & `The World Before` (`mac_quy_khu` `runs 0` vs `typical`): typical `hoa_than` foe never drops Mạc Quy Khư to `<= 67 %` / `<= 50 %` HP. Verified via `top_end * 0.55` probe (`pour 10`, `spill 3`, `World Before spill 3 / cast 3 / tick 6`) and `E.Fight(..., tags=['tribulation'])` `plog` (`['down', 4000, 'A', 'refused']`).
- `A Crane Crosses from the East` (`tu_khong_hac_nien` `runs 0`): sleeps as designed in Tư Không Hạc Niên's pure Metal hand; verified via `gian_thu_dich` holding `hs-lone-crane` (`44` runs across 10 seeds).
- `The Blue Sea Becomes Mulberry Fields` (`doan_thuong_hai` `runs 0`): `typical` `nguyen_anh` foe casts no `lightning` hits; verified vs `thunder_foe` (`10` runs + `Hears and Answers thunder 10`).
- Sealed items (`hs-north-wind-breath`, `hs-blazing-sun-fan`, `hs-fifth-month-plum`) & unslotted techniques (`still-water-mirror-canon`, `north-wind-cold-light-sword`, `falling-plum-flute-canon`): no living cast holder equips sealed abode gear or slots those 3 methods; all verified in targeted probes (§H).

**Open items (for serial / later pass):**
- `element_affinity_pct` (`hs-purple-smoke-furnace`, `10 [hoa]`): `depth_gap` open line `1 of 56` (in `lint_items.py` `ITEM_PRICE` and `catalogue-general.json`, awaiting `CHARACTER_MODS` / GDScript stat reader).
- `scope: ["song"]` on `hs-between-the-notes-flute` (mapped to `["artifact"]` until `lint_techniques.py` `TIER` adds `"song"`, matching `tx-hidden-string-zither`).
- Out-of-fight story / craft halves (`Purple Smoke on the Burner` abode A-2 alchemy, `Mirror of Seas and Fields` scrying, `North-Wind Breath` A-1 tribulation bolt, `hs-purple-smoke-furnace` sealed A-2 state).

---

## A. Decisions Auto-Accepted (User Rule 2026-11-26)

1. **`purple-smoke-furnace-canon` carries existing `pill-smoke` cleanly (no duplicate staged art).**
   - `pill-smoke` is already committed in `design/arts/part-sect-market-folk.json` (`group: "censer-smoke-manual"`) and `assets/data/combat_library.json`. Staging a copy would clash in `stage6_merge.py` and `depth_gap.py`. `hermits-sages.techniques.json` keeps `"id": "pill-smoke"`, matching `hoa_cai`'s `canopy-furnace-canon`.
2. **Stand-in technique picks for all 7 open people:**
   - `tu_khong_hac_nien` (`thien_kim`, layer 12, Metal) -> new T3 Heaven Metal method `lone-crane-metal-canon` (`crane-edge-draw`, `broken-sleeve-stroke`, non-stance so `flurry-stance` in `afterimage-sword-canon` stays intact).
   - `thu_van_trieu` (L8), `trau_vong_bang` (L5), `thu_tieu_chu` (L3) (`trung_thuy` / `ha_thuy` coastal river people) -> new T1 Yellow Water method `vermilion-tide-breath` (`long-oar-stroke`, `14.6 W / 16`).
   - `boc_tuyet_nha` (L2), `bao_tieu_que` (L3), `cam_thu_nguyen` (L5) (`trung_moc` / `ha_moc` herbalists) -> committed general Wood method `verdant-cycle-scripture`.
3. **1v1 & non-spatial translations (`spatial_words_check`):**
   - `The Lake Shows the Moon` `"stand still"` -> `own.composed >= 1` (`"still-water-mirror"` state carries `tags: ["composed"]`).
   - `Walking on Still Water` `"step cleanly to any point you can see"` -> `+20` evade (`2 s`), `-1.0 s` other timers, plus `1` decoy, `+15` evade (`stack: true`), `-0.5 s` timers while warded.
   - `"every foe near you"` / `"foes in front of you"` / `"foes in hearing"` -> single `foe` in 1v1 combat (`Where All Waters Return`, `Noon on One Side`, `The Fifth-Month Tune`, `Smoke over the Burner`, `Hears and Answers`).
4. **R6 item exceptions and `kind: "treasure"` rarity:**
   - The 9 weapons, body gear, and ward gear carry `"arts": []` with the R6 `"exception"` (`"where": "sealed abode A-*"` on A-1/A-4/A-5).
   - The 3 grade-4 treasures (`hs-quy-khu-vase`, `hs-mirror-of-seas-and-fields`, `hs-purple-smoke-furnace`) carry `"rarity": 5` required by `lint_items.py`.
5. **`hs-between-the-notes-flute` `scope: ["song"]` -> `["artifact"]`:**
   - `lint_techniques.py` `TIER` lacks `"song"`, so keeping `["song"]` raises 2 `SCOPE` findings in `lint_items.py`. Mapped to `["artifact"]` matching `tx-hidden-string-zither` (`D39`), logged under Open Items for the serial pass.
6. **Fan-art filter covers both `tags: ["fan"]` and `art_id: "fan-gust"` (`Noon on One Side`):**
   - Mirrors `phuong_minh`'s `Burning Feathers` pattern because committed `fan-gust` lacks the `"fan"` tag.
7. **`Where All Waters Return` & `The Blue Sea Becomes Mulberry Fields` use post-hit `heal (of: amount, ignore_taken: true)`:**
   - Engine `was_hit` fires after HP subtraction and exposes `event.amount`; gating on `event.amount > 0` (`hp_share <= 0.67` for the vase, `dtype: "lightning"` for the mirror) cleanly refunds the hit once per fight without double-triggering on 0-damage hits.
8. **`A Crane Crosses from the East` gates `"Wind root"` on `own.fired_within.60.tag.wind >= 1`:**
   - Effects cannot inspect `own.root.<el>` directly; gating on having fired a `wind`-tagged art makes the sword sleep cleanly in Tư Không Hạc Niên's pure Metal hand and wake in a Wind user's hand (`gian_thu_dich`).

---

## B. Mechanic Table

Summary recorded in `production/plans/stage6/hermits-sages.md` (Step 1); every Effect compiles standalone against `tools/design/combat_sim/engine.py` and `assets/data/combat_engine.json`.

---

## C. Techniques (`techniques/catalogue-sect-hermits-sages.json`)

| Technique | Tier, kind | Bonuses | Passives & W | Abilities (unlock) | Peer & Margin |
|---|---|---|---|---|---|
| `still-water-mirror-canon` | Heaven (`3`) main, Water | `linh_luc_pct` 18, `defense_pct` 12, `health_regen_inc_pct` 15 | `evade_pct` 5 `[]`, `healing_pct` 10 `[]`, `attack_pct` 8 `[water]`, `damage_more` 4 `[cold]` (**30.4 / 32 W**) | `the-lake-shows-the-moon` (1), `walking-on-still-water` (4) | `still-moon-tide-scripture` |
| `north-wind-cold-light-sword` | Earth (`2`) secret, Ice | `attack_pct` 10, `crit_chance_pct` 6 | `attack_pct` 8 `[cold]`, `damage_more` 3 `[sword]`, `crit_damage_pct` 12 `[sword]`, `stack_effect_pct` 10 `[ice, debuff]`, `art_speed_pct` 6 `[sword]` (**22.9 / 24 W**) | `watchmans-gong` (1), `cold-light-on-iron-mail` (4) | `clear-frost-breath` / `hundred-blades-canon` |
| `purple-smoke-furnace-canon` | Earth (`2`) main, Fire+Wood | `khi_huyet_pct` 12, `linh_luc_pct` 14 | `healing_pct` 12 `[]`, `health_regen_inc_pct` 12 `[]`, `attack_pct` 8 `[hoa]`, `stack_duration_pct` 10 `[fire, debuff]`, `linh_luc_regen_inc_pct` 6 `[]` (**22.6 / 24 W**) | `second-brewing` (1), `smoke-over-the-burner` (3), `pill-smoke` (4, committed) | `five-virtue-phoenix-canon` |
| `falling-plum-flute-canon` | Earth (`2`) secret, Wind | `than_thuc_pct` 10, `art_speed_pct` 8 | `attack_pct` 8 `[sword]`, `x_soul` 5 `[soul]`, `status_duration_pct` 12 `[curse]`, `crit_chance_pct` 4 `[sword]`, `evade_pct` 4 `[]` (**24.0 / 24 W**) | `the-fifth-month-tune` (1), `plum-falls-between-notes` (4) | `shao-remnant-score` |
| `lone-crane-metal-canon` *(new)* | Heaven (`3`) main, Metal | `attack_pct` 16, `crit_chance_pct` 8, `defense_pct` 10 | `attack_pct` 10 `[kim]`, `crit_damage_pct` 16 `[sword]`, `damage_more` 4 `[sword]`, `pierce_pct` 6 `[sword]`, `art_speed_pct` 8 `[sword]` (**29.3 / 32 W**) | `crane-edge-draw` (1), `broken-sleeve-stroke` (4) | `sword-intent-primer` / `afterimage-sword-canon` |
| `vermilion-tide-breath` *(new)* | Yellow (`1`) main, Water | `linh_luc_pct` 10 | `khi_huyet_pct` 5 `[]`, `health_regen_inc_pct` 10 `[]`, `attack_pct` 5 `[cold]`, `defense_pct` 4 `[]`, `linh_luc_regen_inc_pct` 6 `[]` (**14.6 / 16 W**) | `long-oar-stroke` (1) | `deep-vein-scripture` / `still-moon-tide-scripture` |

---

## D. Arts (`arts/part-sect-hermits-sages.json`)

- **11 staged arts** (`8` depth + `3` stand-in arts; `pill-smoke` kept in `part-sect-market-folk.json`). **`lint_arts.py`: 0 findings** (`watchmans-gong empower 1: x1.05`, `crane-edge-draw empower 1: x1.27`).
- **Deviations (D1–D5):**
  - **D1.** `the-lake-shows-the-moon`: `"stand still"` modeled as `own.composed >= 1` (`"still-water-mirror"` state carries `"composed"` tag).
  - **D2.** `walking-on-still-water`: spatial `"to any point you can see"` modeled as `+20` evade, `-1.0 s` other art cooldowns, plus `1` decoy / `+15` evade / `-0.5 s` cooldowns when warded.
  - **D3.** `smoke-over-the-burner`: spatial `"foes inside it"` narrowed to 1v1 foe Fire stacks (`3` stacks, `6 s`); `"15 % less from poisons"` modeled via `+18` Wood `dampen_taken` + `+18` Chaos `resist` (`6 s`, `"stack": true`).
  - **D4.** `the-fifth-month-tune`: `"every foe in hearing slowed 10 % for 6 s"` modeled via `slowed_time` `2` stacks (`~12 %` slow, `5 s`); `"next sword attack also counts as a soul art"` modeled via `tune_soul_cut` granting a `0.7 c Soul` follow-up strike on next sword `hit_landed`.
  - **D5.** `plum-falls-between-notes`: depth card had no detailed rule beyond its title; authored as a quick Wind sword finisher guarded on `own.counter.fifth_month_tune >= 1`, ending the tune on `hit_landed` and dealing `0.35 c Force` per counted `tune_notes`.

---

## E. Effects (`effects/hermits-sages.effects.json`)

- **10 staged Effects**, all passing standalone `engine.validate()`, `"source": "world-depth:hermits-sages"`.
- **Deviations (D6–D13):**
  - **D6.** `Where All Waters Return`: `was_hit` refunds first blow leaving `hp_share <= 0.67` via `heal {of: "amount", ignore_taken: true}`; `"every foe near you"` narrowed to `4 Ice + 4 Fire` stacks on the 1v1 foe at `hp_share <= 0.5`; `tag.tribulation` `down` triggers `refuse_down {hp_share: 0.2}`.
  - **D7.** `A Crane Crosses from the East`: `"in a Wind-rooted hand"` gates on `own.fired_within.60.tag.wind >= 1` because Effects cannot inspect `own.root.<el>`.
  - **D8.** `The Blue Sea Becomes Mulberry Fields`: first `was_hit` (`dtype: "lightning"`, `event.amount > 0`) refunds via `heal {of: "amount", ignore_taken: true}` and raises an `8 % max HP` stance ward (`ward_grow` scales on HP/peak rather than absorbed hit); scrying scene is outside combat.
  - **D9.** `The Unspent Bolt`: Frozen Lightning dual stack modeled as `1` Ice + `1` Thunder debuff stack + `frozen_bolt` counter (`1.2 c Lightning + 1.2 c Cold` burst + consumes `5` Ice & `5` Thunder); abode A-1 unsealing bolt is outside combat.
  - **D10.** `Purple Smoke on the Burner`: `not_run` (`records: []`) — out-of-fight alchemy crafting (`+1` pill grade, halved `đan độc`) and abode A-2 story choice.
  - **D11.** `Noon on One Side`: `"foes in front of you"` narrowed to 1v1 foe (`tags: ["fan"]` and `art_id: "fan-gust"`); `"melt frost ward"` once per fight modeled via `sundered` (`4 s`) + `0.4 c` shield-passing Fire hit.
  - **D12.** `The Falling Plum Tune`: `10 %` slow modeled as `2` `slowed_time` stacks (`~12 %` slow, `4 s`); `"cut counts as sword and soul"` modeled via `0.45 c Soul` follow-up hit on sword `hit_landed` (`per_pulse: 2`).
  - **D13.** `Hears and Answers`: opening art dodge modeled via `fight_start` `decoy {n: 1}` -> `decoy_struck` (`0.9 c Cold + 2 Water stacks`); Thunder `gain_qi {share: 0.03}` guarded on `event.amount > 0`.

---

## F. Items & Sets (`items/catalogue-sect-hermits-sages.json`, `items/sets-hermits-sages.json`)

- **13 unique NPC items** (10 grade 4, 2 grade 3: `hs-threadbare-robe` and `hs-between-the-notes-flute`, plus 3 `kind: "treasure"` with `"rarity": 5`), **0 `lint_items.py` findings**, and **3 sets** (`hs-what-the-old-man-kept` 2pc, `hs-lone-crane-things` 3pc, `hs-still-pool` 3pc).
- **Deviations (D14–D15):**
  - **D14.** `hs-between-the-notes-flute`: `scope: ["song"]` on `attack_pct 14` and `art_speed_pct 8` mapped to `["artifact"]` (matching `tx-hidden-string-zither`, since `lint_techniques.py` `TIER` lacks `"song"`).
  - **D15.** 9 weapon/body_gear/ward_gear signature items carry `"arts": []` with the R6 `"exception"`, and the 3 grade-4 treasures carry `"rarity": 5`.

---

## G. Stand-ins & Beasts (`hermits-sages.cast.json`, `hermits-sages.2.cast.json`)

| Person | Realm | Was | Now | Layer | Beasts |
|---|---|---|---|---|---|
| `tu_khong_hac_nien` | `nguyen_anh` | `thien_kim` | `lone-crane-metal-canon` | 12 | none |
| `thu_van_trieu` | `ket_dan` | `trung_thuy` | `vermilion-tide-breath` | 8 | none |
| `trau_vong_bang` | `truc_co` | `ha_thuy` | `vermilion-tide-breath` | 5 | none |
| `thu_tieu_chu` | `luyen_khi` | `ha_thuy` | `vermilion-tide-breath` | 3 | none |
| `boc_tuyet_nha` | `luyen_khi` | `ha_moc` | `verdant-cycle-scripture` | 2 | none |
| `bao_tieu_que` | `luyen_khi` | `ha_moc` | `verdant-cycle-scripture` | 3 | none |
| `cam_thu_nguyen` | `luyen_khi` | `trung_moc` | `verdant-cycle-scripture` | 5 | none |

Beasts: none (`0` beasts owned by `hermits-sages`).

---

## H. Holder Check (`sect_fight.py hermits-sages --seeds 5`) & Targeted Probes

### Default `sect_fight.py` runs (0 `REFUSED`, all slotted arts fire)

| Holder | Realm | Slotted Arts | Gap 0 (`mean_s / wins / hp_left`) | Gap 1 (`mean_s / wins / hp_left`) | Effects (`runs` across 5 seeds at Gap 0 / Gap 1) |
|---|---|---|---|---|---|
| `thu_van_trieu` | `ket_dan` | `long-oar-stroke` (10.8), `backwash-seal` (19.0) | `33.6 s`, `5/5`, `43%` | `8.0 s`, `0/5`, `0%` | — |
| `khuyet_van_ha` | `ket_dan` | `second-brewing` (5.6), `smoke-over-the-burner` (7.6), `pill-smoke` (7.2) | `51.6 s`, `0/5`, `0%` | `8.8 s`, `0/5`, `0%` | — |
| `gian_thu_dich` | `ket_dan` | `swallow-stance` (4.0), `hundred-feather-flurry` (2.6), `three-step-chase` (5.4), `held-breath` (5.8), `trailing-gale` (4.0), `gale-sprite` (2.0) | `16.2 s`, `5/5`, `93%` | `10.1 s`, `0/5`, `0%` | — |
| `nhiem_han_chau` | `truc_co` | `frost-breath-palm` (14.2) | `44.2 s`, `0/5`, `0%` | `8.2 s`, `0/5`, `0%` | — |
| `trau_vong_bang` | `truc_co` | `long-oar-stroke` (15.4) | `53.6 s`, `0/5`, `0%` | `8.0 s`, `0/5`, `0%` | — |
| `thu_tieu_chu` | `luyen_khi` | `long-oar-stroke` (13.2) | `47.4 s`, `1/5`, `1%` | `8.0 s`, `0/5`, `0%` | — |
| `mac_quy_khu` | `hoa_than` | `scorch-fist` (7.0), `backwash-seal` (12.0), `bloodletting-rite` (2.0), `sleet-volley` (9.0), `stilled-instant` (2.8), `shattering-mantle` (3.2) | `19.7 s`, `5/5`, `100%` | `19.7 s`, `5/5`, `100%` | `Unmaking Glass` `95 / 95`; `Where All Waters Return` `0 / 0`; `The World Before` `0 / 0` |
| `tu_khong_hac_nien` | `nguyen_anh` | `crane-edge-draw` (4.4), `broken-sleeve-stroke` (1.8), `flurry-stance` (2.0), `phantom-sword` (4.4), `triple-draw` (3.0), `flying-sword` (1.0) | `9.8 s`, `5/5`, `88%` | `13.2 s`, `0/5`, `0%` | `A Crane Crosses from the East` `0 / 0` (sleeps); `The Crane Wakes` `21 / 28` |
| `doan_thuong_hai` | `nguyen_anh` | `deep-lake-stance` (6.8), `gathering-wave` (4.0), `brimming-cup` (3.0), `swelling-tide-palm` (5.6), `answering-palm` (6.8), `twin-shadow-fist` (2.0) | `20.3 s`, `5/5`, `100%` | `15.6 s`, `0/5`, `0%` | `The Blue Sea Becomes Mulberry Fields` `0 / 0`; `Hears and Answers` `10 / 10` |

### Targeted Probes (verifying all `NEVER_RAN` clauses, unslotted techniques, and sealed abode gear)

- **`mac_quy_khu` vs `top_end * 0.55` (`10` seeds):** `Where All Waters Return pour` `10`, `spill` `3`; `The World Before spill` `3`, `cast` `3`, `tick` `6`. Survival rises from `3.1 s` (without `Where All Waters Return`) to `4.0 s`.
- **`mac_quy_khu` vs `tribulation` bolt (`E.Fight(..., tags=['tribulation'])`, `c_art: 15.0`, `cooldown: 1.0`, `5` seeds):** `t = 5.0 s` with vase vs `1.0 s` without; `plog` directly confirms `pour` at `1000 ms`, `spill` + `The World Before spill/cast/tick` at `2000 ms`, and `['down', 4000, 'A', 'refused']` at `4000 ms`.
- **`gian_thu_dich` holding `hs-lone-crane` (`ket_dan`, Wind active, `10` seeds):** `A Crane Crosses from the East` ran **`44`** times (`15.5 s`, `10/10` wins, `95%` HP) while remaining `0` runs on `tu_khong_hac_nien` (pure Metal hand).
- **`doan_thuong_hai` vs `thunder_foe` (`nguyen_anh`, `lightning` bolt `c_art: 2.0`, `10` seeds):** `The Blue Sea Becomes Mulberry Fields` ran **`10`** times (`21.8 s` vs `23.5 s` without) and `Hears and Answers` fired `start` (`10`), `strike` (`10`), and `thunder` (`10`).
- **Sealed abode A-1 (`north-wind-cold-light-sword` + `hs-north-wind-breath`, `crit: 60`, `10` seeds):** `20.7 s`, `10/10` wins, `67%` HP; `watchmans-gong` (`6.4`), `cold-light-on-iron-mail` (`4.2`); `The Unspent Bolt crit` `181`, `release` `31`; `cold-light-*` `42 / 39 / 49`.
- **Sealed abode A-4 (`morning-sun-feather-fan` + `hs-blazing-sun-fan` + `fan-gust` + `hundred-plumes`, `10` seeds):** `29.4 s`, `10/10` wins, `51%` HP; `Noon on One Side sweep fan` `69`, `sweep gust` `115`, `burst gust` `128`, `melt gust` `10`.
- **Sealed abode A-5 (`falling-plum-flute-canon` + `hs-fifth-month-plum`, `10` seeds):** `57.7 s`; `the-fifth-month-tune` (`9.6`), `plum-falls-between-notes` (`9.5`); `The Falling Plum Tune play` `50`, `cut` `49`, `tick` `190`; `fifth-month-soul-cut` `95`, `plum-between-notes-strike` `95`, `plum-between-notes-end` `95`.
- **Unslotted technique (`still-water-mirror-canon`, `ket_dan`, `10` seeds):** `60.5 s`, `10/10` wins, `87%` HP; `the-lake-shows-the-moon` (`9.7`), `walking-on-still-water` (`9.8`), `long-oar-stroke` (`19.6`); `lake-mirror-enter` `97`, `grow` `544`, `return` `92`, `walk-step-evade` `98`, `walk-ward-bonus` `88`.
- **Pill trigger (`purple-smoke-furnace-canon` with grade-2 pill, `5` seeds):** `second-brewing` (`5.8`), `smoke-over-the-burner` (`7.8`), `pill-smoke` (`7.6`); `second-brew-pill` `5`, `release` `27`, `start` `29`, `tick` `95`; `smoke-dampen-wood` `39`, `smoke-resist-chaos` `39`.

---

## I. Open Items & Băng Tâm Pitfall Checklist

1. **Open items:** `element_affinity_pct` (`hs-purple-smoke-furnace`, `1` open `lines` gap in `depth_gap.py`), `scope: ["song"]` proxy -> `["artifact"]` on `hs-between-the-notes-flute` (`lint_techniques.py` `TIER` lacks `"song"`), and out-of-fight story/craft halves (`Purple Smoke on the Burner`, `Mirror of Seas and Fields` scrying, `North-Wind Breath` A-1 bolt).
2. **Băng Tâm checklist verified cleanly:** stance triggers avoid overwriting companion stances (`still-water-mirror` only on `the-lake-shows-the-moon`; `lone-crane-metal-canon` omits stance so `flurry` stays intact; `The Falling Plum Tune` uses `plum_tune` counter); dual `mod` on `smoke-over-the-burner` & `walking-on-still-water` sets `"stack": true`; `was_hit` refunds and Thunder qi restore guard on `event.amount > 0`; `each_for` not misused with `set: 1`; no `filter` placed on `held`; no `art_id` inside `temp_mods`; every Effect declares its own `"counters"` and `"states"` for standalone `engine.validate()`.
