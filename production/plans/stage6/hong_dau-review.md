# Hồng Đậu Trang: Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/hong_dau/`; nothing exported, nothing outside allowed paths):**
- **2 techniques** (`techniques/catalogue-sect-hong_dau.json`): `red-bean-primer` (Yellow/tier 0 main, `moc` + `thuy`, 6 layers, 7.3 W of 8) and `canon-of-longing` (Earth/tier 2 main, `moc`, 12 layers, 22.8 W of 24). Bonuses and passives are newly sized against peer techniques (`clear-frost-breath`, `rotting-canopy-canon`).
- **4 new arts** (`arts/part-sect-hong_dau.json`): `scatter-beans` (`red-bean-primer`), and `a-branch-in-spring`, `gather-more`, `the-second-cup` (`canon-of-longing`). All 4 art IDs are registered in `design/world/depth/sects/hong_dau.techniques.json`.
- **4 Effects** (`effects/hong_dau.effects.json`): `Half of a Pair`, `The Second Cup Is Poured`, `The Second Cup`, and `Planted, Waited, Harvested`. All 4 validate cleanly in `engine.validate`, declare their own counters, and avoid stance slots (zero stance collisions with `marching-dirge`).
- **7 items and 2 sets** (`items/catalogue-sect-hong_dau.json`, `items/sets-hong_dau.json`): all 7 unique NPC items (`rarity: 5` on treasure `hd-phi-hong`), R6 `exception` on the 6 weapons/robes, and both sets (`hd-tea-at-the-manor` 2pc, `hd-back-garden` 3pc) split into `effect` + `rule`.
- **1 stand-in resolved** (`design/world/depth/sects/hong_dau.cast.json`): `te_vong_quy` (`huyen_hoa` -> Phượng Minh's committed `wutong-dawn-breath`, layer 6). Gap report `stand_ins` is now **0**.
- **0 beasts**, **0 pending words** (no `pending.json`), **0 early promotions**.

**Deviations:** 5 functional approximations/adaptations (logged in §D and §E below: `gather-more` age counter, `the-second-cup` `charmed` + art-hit weaken, `The Second Cup Is Poured` tick trigger, `The Second Cup` stack count & batch refresh, `Planted, Waited, Harvested` elapsed poison time & double-stack grant) plus standard R6/unique/treasure metadata adjustments (§F).

**Checks (`$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\hong_dau"`):**
- `lint_arts.py design/stage6-staging/hong_dau/arts/part-sect-hong_dau.json`: **0 findings** (4 arts).
- `lint_techniques.py design/stage6-staging/hong_dau/techniques/catalogue-sect-hong_dau.json`: **0 findings** (2 techniques).
- `lint_items.py design/stage6-staging/hong_dau/items/catalogue-sect-hong_dau.json`: **0 findings** (7 items).
- `depth_check.py`: **findings: none**.
- `depth_gap.py --sect hong_dau`: `stand_ins 0`, `unknown_ids 0`, `engine_words 0`, `wishes_open 0` (`cross_owner 1` is `te_vong_quy`'s `wutong-dawn-breath`, already in `catalogue-sect-phuong_minh.json` awaiting Stage 7 export).
- `sect_fight.py hong_dau --seeds 5 --gap 0` & `--gap 1`: **0 REFUSED** across all 11 living members. Every art fires at `--gap 0`; `the-second-cup` (`cooldown: 12.0`) only misses firing at `--gap 1` on builds that die in 8–10 s.
- **Never ran in default `sect_fight.py`:**
  - `Half of a Pair` (`nghe_hong_dau`): `always`-only record (`Fight.do` counter ignores `always`), Tàn Hồng (`tan_hong`) is not in the game yet, and `flying-sword-strike` is outside `nghe_hong_dau`'s 6-art slice in `sect_fight.py`. Verified in a probe slotting `flying-sword-strike`: `19.0 s` with vs `18.8 s` without.
  - `The Second Cup Is Poured` (`lieu_da_thai`): `lieu_da_thai` kills a typical Trúc Cơ foe in `15.4 s` (`--gap 0`) and falls in `8.4 s` (`--gap 1`), both before `time > 20`. Verified against a tankier Trúc Cơ foe (`n_body=3.0`): `27.5 s 92%` (`50` runs) vs `28.8 s 91%` without.

**Open items (for serial step / Stage 7):**
- `stage6_merge.py hong_dau` to move staged files into `design/` and `assets/data/combat_effects.json`.
- Stage 7 export of `phuong_minh` closes `cross_owner 1` (`wutong-dawn-breath` on `te_vong_quy`).
- When Tàn Hồng (`tan_hong`) is authored later, add the paired-sword crit petal record to `Half of a Pair`.

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Stand-in for `te_vong_quy`: `wutong-dawn-breath` (layer 6).**
   - *Choice:* Phượng Minh's committed outer `main` technique `wutong-dawn-breath` (`names: ["moc", "hoa"]`, `layers: 6`, `owner: "phuong_minh"`) rather than generic `red-sun-scripture` (`catalogue-fire.json`) or authoring a new technique.
   - *Why:* `te_vong_quy` (`hoa: 56, tho: 40`, `layer: 6`) is a charmed Phượng Minh disciple who "keeps his own sect's method" (`hong_dau.md` §5); `wutong-dawn-breath` is Phượng Minh's own `main` method already used by Phượng Minh's `kiem_tu` disciples (`phuong_minh.2/3/4.cast.json`), fits his `hoa: 56` root and `layer: 6` cap, and requires no `foreign/` edit.
2. **Express all 4 arts and 4 Effects using existing engine words (no `pending.json`).**
   - *Choice:* Used `poison_age` counter (`gather-more`), `cup_weaken` counter (`the-second-cup`), `tick_dealt` Chaos trigger (`The Second Cup Is Poured`), `refresh` (`The Second Cup`), and `garden_ripe_t` + `stack_grant` (`Planted, Waited, Harvested`) instead of adding new per-batch-age or batch-pause engine primitives.
   - *Why:* Per `_brief-record.md` ("Prefer an existing word whenever it keeps the intent"), every mechanical beat (poison ripening over time, harvesting by age + stacks, Charmed holding arts + weakening next art, long-fight poison scaling + longer Charmed, 8-stack second cup refresh + Heavy Breath, and 6 s double-counting/one-time harvest) works identically in both Python and GDScript today.
3. **`gather-more` guarded on `foe.debuff.wood >= 4` with `cooldown: 8.0`.**
   - *Choice:* Added `guards: [{"read": "foe.debuff.wood", "op": ">=", "value": 4}]` and `cooldown: 8.0`.
   - *Why:* Prevents `gather-more` from stripping 1–2 Poison stacks every few seconds before `a-branch-in-spring`, `The Second Cup` (8+ stacks), or `Planted, Waited, Harvested` (6 s ripe + 6+ stacks) can build up, while still allowing `quan_song_dau` and `khong_vu_kieu` (who hold only `a-branch-in-spring` + `gather-more`) to fire `gather-more` 3.8–5.2 times per fight.
4. **No stances (`states`) on any `hong_dau` art.**
   - *Choice:* Used counters (`branch_on`, `branch_feed`, `branch_self`, `poison_age`, `cup_weaken`, `garden_ripe_t`) rather than `states`.
   - *Why:* `nghe_hong_dau`, `lieu_da_thai`, and `ha_cuc_thi` also slot `thorn-and-ink-verses` (`marching-dirge`, which uses stance `"march"`), so keeping `hong_dau` arts stance-free prevents any stance overwrite (Băng Tâm lesson 2).
5. **R6 signature item `exception` + `unique: true` + `rarity: 5` on `hd-phi-hong`.**
   - *Choice:* Marked all 6 weapon/robe items with the standard R6 `exception`, all 7 items with `sources: ["npc"]` and `unique: true`, and converted `hd-phi-hong` (`kind: "treasure"`) from `grade: 4` to `rarity: 5`.
   - *Why:* Matches `lint_items.py` schema and user rulings R6 / rule 20f.

## B. Mechanic table

Recorded in `production/plans/stage6/hong_dau.md` (all 11 rows verified against `assets/data/combat_engine.json` and `tools/design/combat_sim/engine.py`).

## C. Techniques (`design/stage6-staging/hong_dau/techniques/catalogue-sect-hong_dau.json`)

The depth records name no bonuses or passives; all bonuses and passives below are **new**, sized against same-tier peers (`clear-frost-breath`, `rotting-canopy-canon`).

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Abilities (unlock layer) | W used |
|---|---|---|---|---|---|
| `red-bean-primer` | Yellow (0) main, `moc` + `thuy` | none | `stack_effect_pct` 10 `[moc, debuff]`, `stack_duration_pct` 12 `[moc, debuff]`, `linh_luc_regen_inc_pct` 3 `[]` | `scatter-beans` (1) | 7.3 W of 8 |
| `canon-of-longing` | Earth (2) main, `moc` | `tam_ma_resist_pct` 10, `linh_luc_pct` 14 | `stack_effect_pct` 16 `[moc, debuff]`, `stack_duration_pct` 20 `[moc, debuff]`, `status_duration_pct` 16 `[curse]`, `attack_pct` 12 `[over_time, moc]`, `linh_luc_regen_inc_pct` 5 `[]` | `a-branch-in-spring` (1), `gather-more` (2), `the-second-cup` (4) | 22.8 W of 24 |

## D. Arts (`design/stage6-staging/hong_dau/arts/part-sect-hong_dau.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `scatter-beans` | Throws a handful of red beans: the foe hit gains one Wood poison stack, and a foe who already holds three stacks is slowed briefly. | Wood `c_art` 1.3, cost 0.03, cd 3.0, `debuff: [1, 8]`; on `hit_landed` if `foe.debuff.wood >= 4`, applies `slowed_time` 1 (2 s). | Checks `>= 4` on `hit_landed` because `debuff: [1, 8]` lands right before `hit_landed` fires. |
| `a-branch-in-spring` | Plants a red bean in the foe: a Wood poison that deals little at first and grows each second it is not cleansed; it stops growing (and keeps what it has) once the holder goes 4 s without laying another Wood poison. | Wood `c_art` 1.2, cost 0.04, cd 5.0, `debuff: [1, 10]`; counters `branch_on`, `branch_feed` (cap 4), `branch_self`; adds 1 Wood stack (10 s) per pulse while `foe.debuff.wood >= 1` and `branch_feed >= 1`, decrementing `branch_feed`; non-self Wood `status_applied` resets `branch_feed = 4`. | None in mechanics; self-guard `branch_self` prevents pulse growth from feeding itself. |
| `gather-more` | Harvests every ripening poison on the foe at once for damage by their age, and heals the holder for part of it. | Wood `c_art` 1.8, cost 0.05, cd 8.0, guarded `foe.debuff.wood >= 4`; `poison_age` counter ticks +1/pulse while foe holds Wood poison; on `hit_landed`, deals `0.12` Chaos per `poison_age` + consumes all Wood debuffs for `0.18` Chaos/stack (`pass_shields`, `outside_budget`) and heals `0.4 %` max HP per age-second and per stack, resetting `poison_age = 0`. | Tracks total elapsed poison age (`poison_age`) instead of per-batch age; `guards >= 4` + cd 8.0 lets stacks ripen before harvest. |
| `the-second-cup` | A charm: the foe is Charmed for 2 s; while it holds, its escape and its cleanses fail, and its first art after the charm ends deals 20 % less. | Wood `c_art` 0.0, cost 0.04, cd 12.0, guarded `foe.status.charmed == 0`; on `art_fired` applies `charmed` (2 s) and sets `cup_weaken = 1`; while `cup_weaken >= 1`, `dampen_taken: 25 [art]` (-20 % incoming art damage), cleared on foe's next `was_hit`/`was_evaded` `[art]`. | `charmed` already holds foe escape and cleanse arts (`hold_arts: true`); passive cleansing ward is not blocked (no engine `no_cleanse` mod). |

## E. Effects (`design/stage6-staging/hong_dau/effects/hong_dau.effects.json`)

| Effect (source item/set) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Half of a Pair` (`hd-phi-hong`) | While Tàn Hồng is not held by the same person, this sword's crit chance counts only against a foe carrying your Wood stacks. Held together with Tàn Hồng, each crit with either sword scatters a petal that gives the foe one Wood stack. | `on: "always"`, if `foe.debuff.wood <= 0`: `mod: {"crit": -8, "tags": ["sword"]}`. | Tàn Hồng (`tan_hong`, slot V-1) is not in the game yet, so only the unpaired penalty runs; `approx` documented. |
| `The Second Cup Is Poured` (`hd-gracious-door-fan`) | A foe who has been in the fight with you for more than 20 seconds takes 10 % more damage from your Wood poisons, and Charmed lasts 1 pulse longer on them. | After `time > 20`: on `tick_dealt` (`wood`, 1/pulse) deals `0.002` Chaos (`pass_shields`, `outside_budget`) per `foe.debuff.wood`; on `always` grants `status_dur: 50` `[charmed]` (2 -> 3 pulses). | Poison ticks don't read live damage mods, so +10 % Wood poison damage runs as a `0.002` Chaos trigger per stack (`approx`). |
| `The Second Cup` (`hd-tea-at-the-manor` 2pc) | Once per foe each fight, when the foe carries eight or more of your Poison batches, they drink the second cup: they are Charmed, their Poison batches stop counting down for 3 s, and they gain 2 Heavy Breath. | `on: "status_applied"` (`wood`), if `foe.debuff.wood >= 8`, `per_fight: 1`: applies `charmed` (2 s), `refresh` Wood debuffs on foe, applies `heavy_breath` 2 (4 s). | Reads Wood stack count (`>= 8`) instead of batch count, and refreshes Wood batches to full duration instead of pausing countdown for 3 s (`approx`). |
| `Planted, Waited, Harvested` (`hd-back-garden` 3pc) | Each of your Poison batches that has lasted 6 s on a foe is ripe and counts as two for everything that counts your stacks. Once a fight you may harvest: every ripe batch deals all its remaining damage at once, and you heal for a tenth of it. | `garden_ripe_t` increments/clears on `pulse` by `foe.debuff.wood`; at `garden_ripe_t >= 6`, `always` `stack_grant: 1 [wood, debuff]`; once/fight on Wood `art` `hit_landed` (`not_art_id: ["gather-more"]`, `garden_ripe_t >= 6`, `foe.debuff.wood >= 6`), consumes all Wood debuffs for `0.15` Chaos/stack (`pass_shields`, `outside_budget`), heals `0.5 %`/stack, resets `garden_ripe_t = 0`. | Uses elapsed Wood poison time (`garden_ripe_t >= 6`) instead of per-batch age and `stack_grant: 1` for doubling grants (`approx`). |

## F. Items and sets (`design/stage6-staging/hong_dau/items/`)

- **7 items** (`catalogue-sect-hong_dau.json`): modifiers match `hong_dau.items.json` verbatim; all 7 carry `sources: ["npc"]` and `unique: true`; `hd-phi-hong` (`kind: "treasure"`) uses `rarity: 5` instead of `grade: 4`; 6 weapons/robes carry the R6 `exception`.
- **2 sets** (`sets-hong_dau.json`): modifiers match verbatim; full-set entries split `"effect"` (plain English + Hán-Việt name) and `"rule"`.

## G. Stand-ins (`design/world/depth/sects/hong_dau.cast.json`)

| Person | Realm | Was | Now | Beasts |
|---|---|---|---|---|
| `te_vong_quy` | `truc_co` | `huyen_hoa` (6) | `wutong-dawn-breath` (6) | none |

## H. Holder table (`sect_fight.py hong_dau --seeds 5`, typical foe; `--gap 0` and `--gap 1`)

**0 REFUSED across all 11 living members at both `--gap 0` and `--gap 1`.**

| Holder (realm) | `--gap 0` (time, wins, HP) | `--gap 1` | Effects (`with` / `without`, runs) & art notes |
|---|---|---|---|
| `nghe_hong_dau` (`ket_dan`) | 21.0 s, 5/5, 96 % | 12.8 s, 0/5, 0 % | **The Second Cup**: 21.0 s 96 % / 22.6 s 100 % (**5 runs** gap 0, **5 runs** gap 1); **Half of a Pair**: `0` (`always` + no `tan_hong` + `flying-sword-strike` outside 6-art slice; probe w/ sword: 19.0 s vs 18.8 s). All 6 arts fire (gap 0 & gap 1). |
| `nghe_xuan_chi` (`ket_dan`) | 21.4 s, 5/5, 91 % | 9.8 s, 0/5, 0 % | **Planted, Waited, Harvested**: 21.4 s 91 % / 21.1 s 97 % (**115 runs** gap 0, **49 runs** gap 1). All 6 arts fire at gap 0 (`the-second-cup` 0 at gap 1 due to 9.8 s loss before 12 s cd). |
| `lieu_da_thai` (`truc_co`) | 15.4 s, 5/5, 100 % | 8.4 s, 0/5, 0 % | **The Second Cup Is Poured**: `0` in default runs (kills in 15.4 s / dies in 8.4 s before `time > 20`). Tanky probe (`n_body=3.0`): 27.5 s 92 % / 28.8 s 91 % (**50 runs**). All 6 arts fire at gap 0. |
| `tien_kho_dang` (`truc_co`) | 42.5 s, 2/5, 11 % | 8.0 s, 0/5, 0 % | All 4 arts fire (`a-branch-in-spring` 7.0, `gather-more` 4.0, `the-second-cup` 2.2, `scatter-beans` 12.0). |
| `ha_cuc_thi` (`truc_co`) | 30.3 s, 5/5, 94 % | 8.0 s, 0/5, 0 % | All 5 arts fire (`a-branch-in-spring` 5.8, `gather-more` 3.4, `the-second-cup` 1.4, `marching-dirge` 9.2, `thorn-lullaby` 3.4). |
| `to_boi_ngam` (`truc_co`) | 47.8 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | All 3 arts fire (8.4 / 4.2 / 3.0). |
| `quan_song_dau` (`truc_co`) | 56.0 s, 2/5, 4 % | 8.0 s, 0/5, 0 % | Both arts fire (9.8 / 5.2). |
| `te_vong_quy` (`truc_co`) | 25.0 s, 5/5, 99 % | 8.0 s, 0/5, 0 % | Stand-in `wutong-dawn-breath`: `seed-of-spring` 5.0, `dawn-call-palm` 10.0. |
| `khong_vu_kieu` (`luyen_khi`) | 45.4 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | Both arts fire (7.8 / 3.8). |
| `doan_thai_dau`, `uong_le_tra`, `banh_tri_hap`, `cung_hong_to`, `kha_tieu_dau`, `te_niem_quy`, `ho_yen_do`, `sam_van_huong`, `diep_lac_phuong` (`luyen_khi`) | 39.8–40.0 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | `scatter-beans` fires 11.8/fight at gap 0 (2.0 at gap 1). |

REVIEW DONE
