# Nam Phố Đường (`nam_pho`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/nam_pho/`; nothing exported, nothing outside allowed paths):**
- **3 techniques** (`techniques/catalogue-sect-nam_pho.json`): `mulberry-ink-primer` (Yellow main, Wood+Water, 6 layers), `southern-shore-cloud-canon` (Profound main, Wood, 9 layers), and `painted-beams-dawn-flight` (Earth secret, Wood+Water, 12 layers). `thorn-and-ink-verses` is already committed in `design/techniques/catalogue-soul-song-seal.json`. All `auth-mod.json` `b4` (`Painted Leaf`) passives are preserved, and new tier-sized bonuses and combat passives are marked new in §C (`8.0/8`, `15.9/16`, `23.9/24 W`).
- **7 new arts** (`arts/part-sect-nam_pho.json`): `three-wet-sheets`, `blotting-paper`, `catch-the-morning-cloud`, `painted-rain`, `paper-beam`, `dawn-flight`, and `dusk-curtain`. All 7 art ids are registered in `design/world/depth/sects/nam_pho.techniques.json`.
- **3 Effects** (`effects/nam_pho.effects.json`): 1 item Effect (`Dawn Ink` on `np-southern-cloud-seal`) and 2 full-set Effects (`Paper Laid at Dawn` on `np-dawn-half`, `Roll Up the Western Rain` on `np-dusk-half`). Every Effect explicitly declares every counter it reads or writes in its own `"counters"` array for standalone GDScript compilation (`test_every_library_effect_compiles` / `fighter_profile_loader.gd`), passes `engine.validate`, and runs on its real holder in `sect_fight.py`.
- **6 items and 2 sets** (`items/catalogue-sect-nam_pho.json`, `items/sets-nam_pho.json`): all 24 depth modifier lines preserved verbatim (all run in `fight.py`), `sources: ["npc"]`, `unique: true` on all 6 items, and the R6 `exception` mark on the 5 weapon/robe pieces (`np-southern-cloud-seal`, `np-dawn-cloud-brush`, `np-mulberry-hemp-robe`, `np-dusk-rain-seal`, `np-maple-scholar-robe`); utility banner `np-painted-beam-banner` (`ky`) fits rule 21 with no exception needed.
- **0 stand-ins, 0 beasts, 0 pending words** (`pending.json` is empty), **0 early promotions** (`foreign/` unused; 3 cross-owner references in `loose-south` and `market-folk` point to `nam_pho`'s methods and close when `nam_pho` is merged in Stage 7).

**Counts:**
- **Deviations:** `10` (`D1`–`D10`, §C–§F).
- **Decisions taken for the user:** `5` (§A).
- **Pending words:** `0`.
- **Never ran in `sect_fight.py`:** `0` arts (`0 NEVER_FIRED`); all 3 Effects run on their real holders (`Dawn Ink` runs `19` times at `--gap 1` and `190` times in the `dawn-flight`/`dusk-curtain` probe; at `--gap 0` default slotting, `chau_phi_van` wins in `11.1 s` before the `7.5 s`-extended Wood batches laid at `t = 4 s` expire).

**Checks (all run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\nam_pho`):**
- `lint_arts.py`: checked 7 arts in 1 file, **0 findings**.
- `lint_techniques.py`: checked 3 techniques, **0 findings** (`8.0 W of 8`, `15.9 W of 16`, `23.9 W of 24`).
- `lint_items.py`: checked 6 items, **0 findings** (`unique 6 of 6`).
- `depth_check.py --quiet`: **findings: none**.
- `depth_gap.py --sect nam_pho`: `stand_ins: 0`, `unknown_ids: 0`, `ties_unmapped: 0`, `ties_over_cap: 0` open (`1` game-capped), `engine_words: 0`, `wishes_open: 0`, `lines: 34/34 runs`.
- Standalone Effect compile check (`engine.validate` + counter declaration audit): **3/3 VALID**, **0 undeclared counters**.
- `sect_fight.py nam_pho --seeds 5` (`--gap 0` and `--gap 1`): **0 REFUSED**, **0 NEVER_FIRED**, **0 NEVER_RAN** at `--gap 1` (plus 10-seed probe for `chau_phi_van` slotting `painted-beams-dawn-flight`).

**Open items (for Stage 7 / serial step):**
- Merge `design/stage6-staging/nam_pho/` into `design/` and `assets/data/combat_effects.json`; this also closes the 3 `cross_owner` references (`gian_van_lo` in `loose-south`, `trinh_hong_tien` and `trinh_chu_sa` in `market-folk`).
- Stage 7 world export closes `N-nam_pho-01`..`04` and the game tie cap on `chau_phi_van`.

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Avoid stance collisions between `catch-the-morning-cloud`, `dawn-flight`, and `marching-dirge` using self-counters and `own.state.any == 0` guards (Băng Tâm Lesson 2).**
   - *Choice:* Both Field cloud talismans (`catch-the-morning-cloud` and `dawn-flight`) track their 10 s active window via self-counters (`morning_cloud` and `dawn_flight`, `decay_per_pulse: 1`), only set their Field stance (`morning-cloud` / `dawn-flight`) when `own.state.any == 0`, and only clear `state: null` if their own stance is still active.
   - *Reason:* `chau_phi_van` and `kha_trieu_phi` both slot `marching-dirge` (from `thorn-and-ink-verses` in `family-soul-song-seal.json`), which toggles `state: "march"`, and `kha_trieu_phi` also slots both `catch-the-morning-cloud` and `dawn-flight`. Unconditional `state: {set}` calls would overwrite each other and break `marching-dirge`'s finale; counter-driven pulses ensure every Field keeps ticking alongside `march` while still setting `field_up == 1` whenever no other stance is active.
2. **Pin "talismans you lay" to a shared `laid_talisman` charge counter (`each_for: 20`) plus `talisman`-marked Wood debuff batches.**
   - *Choice:* All four laying talismans (`blotting-paper`, `catch-the-morning-cloud`, `paper-beam`, `dawn-flight`) increment `laid_talisman`; `painted-rain` and `dusk-curtain` spend `laid_talisman` when they burst/roll up; `Paper Laid at Dawn` (`np-dawn-half`) declares `laid_talisman` in its own `"counters"` array and ticks `dawn_unspent_s` whenever `laid_talisman >= 1`, granting `dawn_growth` every 10 s.
   - *Reason:* Keeps the entire Nam Phố kit (including `Paper Laid at Dawn` and `Dawn Ink`) running cleanly on existing engine primitives (`0` pending words) while respecting the standalone GDScript compilation rule (`laid_talisman` declared on every Effect and art that reads or writes it).
3. **Model `Three Wet Sheets` as Wood (Chaos) three-hit split (`[0.33, 0.33, 0.34]`).**
   - *Choice:* `three-wet-sheets` uses `element: "wood"` (`kind: "elem"`, `c_art: 1.5`, `cost_share: 0.02`, `cooldown: 1.5`).
   - *Reason:* The combat engine has no `own.purity` readable and `ArtOverride` cannot override `art.element` at runtime. Wood matches Nam Phố's primary lineage element (`names: ["moc", "thuy"]`) and 9 of 11 living sect members; Water-primary outer disciples (`mac_tieu_trien`, `phung_luc_y`) still cast it cleanly under `mulberry-ink-primer`.
4. **Cap `Dusk Curtain`'s Wood burst at `n: 5` stacks and shorten cloud Wood-batch durations to `5 s` (`catch-the-morning-cloud`) and `4 s` (`dawn-flight`).**
   - *Choice:* `dusk-curtain` consumes up to `5` Wood stacks (`0.45` Cold free hit each) rather than all Wood stacks, and the two Field talismans lay `5 s` and `4 s` Wood batches (with `"mark": "talisman"`).
   - *Reason:* `Dusk Curtain` and `Roll Up the Western Rain` both belong to `kha_trieu_phi`. Consuming all Wood stacks every 7 s would erase batches before `batch_ended` can trigger `Roll Up the Western Rain` and leave `foe.debuff.wood` near 0 at `broken`. Capping `consume` at `5` with `4–5 s` batch durations lets `Dusk Curtain` burst reliably while `batch_ended` still triggers both `Dawn Ink` and `Roll Up the Western Rain` in real fights.
5. **Size new bonuses and passives on the 3 techniques to match their tier peers (`8.0/8`, `15.9/16`, `23.9/24 W`) and keep `R6` `exception` on the 5 weapon/robe items.**
   - *Choice:* Added `linh_luc_regen_inc_pct 3` to `mulberry-ink-primer` (on top of `b4`'s 3 lines); added `linh_luc_pct 10` bonus and `stack_effect_pct 6 [moc, debuff]` + `linh_luc_regen_inc_pct 4` passives to `southern-shore-cloud-canon`; authored full tier-2 bonuses (`linh_luc_pct 12`, `than_thuc_pct 10`) and 6 passives on `painted-beams-dawn-flight`. Marked all 6 items `unique: true`, `sources: ["npc"]`, and 5 weapon/robe pieces with the R6 `exception`.
   - *Reason:* Matches Băng Tâm / batch `b01`–`b02` precedent and `cong-phap.md` tier budgets cleanly.

---

## B. Mechanic table (Step 1)

`spatial_words_check.py --sect nam_pho`: `0` non-soft hits (`4` soft prose hits in `ties.note` and `build.tree.intent`).

| Record | Mechanic | Engine status | Implementation |
|---|---|---|---|
| `mulberry-ink-primer` / `three-wet-sheets` | Throws 3 quick talismans, light Wood or Water dmg (stronger element) | Has (`approx` fixed Wood) | Wood `elem`, `c_art 1.5`, `cost 0.02`, `cd 1.5`, `split [0.33, 0.33, 0.34]`, `tags: ["talisman", "quick"]` |
| `mulberry-ink-primer` / `blotting-paper` | Ward talisman: soaks next hit, returns linh lực | Has | `ward_grow 0.08 hp`, `laid_talisman +1`, `blot_ready` -> `ward_absorbed` grants `gain_qi 0.04` |
| `southern-shore-cloud-canon` / `catch-the-morning-cloud` | Cloud talisman Field: foe gains Wood/s, you heal a little | Has | `morning_cloud` counter (10 s), `laid_talisman +1`, `field` stance if `state.any == 0`, pulse 1 Wood (`5 s`, `mark: "talisman"`) + `heal 0.01` |
| `southern-shore-cloud-canon` / `painted-rain` | Spends laid talismans: Wood bursts scaled by foe Wood stacks | Has | `c_art 2.2`, `always` `+5% dmg_more` per `foe.debuff.wood`, `free_hit 0.70 chaos` per `laid_talisman` spent |
| `southern-shore-cloud-canon` / `paper-beam` | Ward talisman: blocks next heavy hit, heals for part of it | Has | `ward_grow 0.12 hp`, `laid_talisman +1`, `paper_beam` -> `ward_absorbed` heals `0.40` of `event.amount` |
| `painted-beams-dawn-flight` / `dawn-flight` | Great cloud talisman Field: foe gains Wood stacks & slowed | Has | `dawn_flight` counter (10 s), `laid_talisman +1`, `field` stance if `state.any == 0`, pulse 2 Wood (`4 s`, `mark: "talisman"`) + `slowed_time` (`2 s`) |
| `painted-beams-dawn-flight` / `dusk-curtain` | Rolls up talismans into rain: heal, cleanse 1 debuff, Wood stacks burst for Water dmg | Has | `c_art 1.8`, `c_heal 0.8`, `cleanse 1`, `+2% heal` per `laid_talisman` spent, `consume` up to 5 Wood -> `0.45 cold` per stack |
| `Dawn Ink` (`np-southern-cloud-seal`) | Early laid talismans (<=10 s) last 50% longer; unspent expiry returns linh lực | Has (`approx`) | `time <= 10` -> `stack_dur 50 [wood, debuff]`; `batch_ended [wood]` -> `gain_qi 0.02` |
| `Paper Laid at Dawn` (`np-dawn-half` 3pc) | Laid talismans free until fired; every 10 s unspent grows (+10% dmg, +1 Wood stack, +2% max qi cost on fire) | Has (`approx`) | `cost_red 0.95 [talisman]`; pulse ticks `dawn_unspent_s` -> `dawn_growth` every 10 s -> `dmg_more 0.10`, +1 Wood on hit, `-0.02 qi` on fire |
| `Roll Up the Western Rain` (`np-dusk-half` 3pc) | Foe Broken or sheds Wood stacks -> each stack heals 1% HP and cleanses 1 debuff | Has | `batch_ended [wood]`, `cleansed`, and `broken` (scaled by `foe.debuff.wood`) -> `heal 0.01` + `cleanse 1` |

---

## C. Techniques (`design/stage6-staging/nam_pho/techniques/catalogue-sect-nam_pho.json`)

`lint_techniques.py`: **3 techniques, 0 findings**. Existing `b4` passives kept; all new bonuses and passives marked **(new)** below.

| Technique | Tier, kind | Bonuses | Passives | Abilities (unlock) | Peer & W |
|---|---|---|---|---|---|
| `mulberry-ink-primer` | Yellow main, Wood+Water | none | `attack_pct 3 [talisman]` (`b4`), `art_speed_pct 5 [talisman]` (`b4`), `status_duration_pct 4 []` (`b4`), `linh_luc_regen_inc_pct 3 []` **(new)** | `three-wet-sheets` (1), `blotting-paper` (3) | `clear-frost-breath` (`8.0 W of 8`) |
| `southern-shore-cloud-canon` | Profound main, Wood | `linh_luc_pct 10` **(new)** | `attack_pct 6 [talisman]` (`b4`), `art_speed_pct 10 [talisman]` (`b4`), `status_duration_pct 8 []` (`b4`), `stack_effect_pct 6 [moc, debuff]` **(new)**, `linh_luc_regen_inc_pct 4 []` **(new)** | `catch-the-morning-cloud` (1), `painted-rain` (2), `paper-beam` (4) | `verdant-cycle-scripture` (`15.9 W of 16`) |
| `painted-beams-dawn-flight` | Earth secret, Wood+Water | `linh_luc_pct 12` **(new)**, `than_thuc_pct 10` **(new)** | `attack_pct 8 [talisman]` **(new)**, `art_speed_pct 8 [talisman]` **(new)**, `stack_duration_pct 16 [moc, debuff]` **(new)**, `healing_pct 10 []` **(new)**, `linh_luc_regen_inc_pct 6 []` **(new)**, `status_resist_pct 6 []` **(new)** | `dawn-flight` (1), `dusk-curtain` (3) | `jade-vessel-ice-heart-canon` (`23.9 W of 24`) |

**Deviations (`D1`–`D2`):**
- **D1:** Added new tier-sized passive (`linh_luc_regen_inc_pct 3`) to `mulberry-ink-primer` (`8.0/8 W`) and new bonus + passives to `southern-shore-cloud-canon` (`15.9/16 W`), keeping all `b4` lines intact.
- **D2:** Authored new tier-2 bonuses and passives on `painted-beams-dawn-flight` (`23.9/24 W`).

---

## D. Arts (`design/stage6-staging/nam_pho/arts/part-sect-nam_pho.json`)

`lint_arts.py`: **7 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `three-wet-sheets` | Throws three quick talismans: light Wood or Water dmg (stronger element) | Wood `elem`, `c_art 1.5`, `cost 0.02`, `cd 1.5`, `split [0.33, 0.33, 0.34]`, `tags: ["talisman", "quick"]` | **D3:** Fixed `wood` element (`Chaos`); engine lacks `own.purity` readable to switch element dynamically (Decision A3) |
| `blotting-paper` | Ward talisman that soaks next hit and returns a little linh lực | Water `ward`, `cost 0.03`, `cd 6.0`; `ward_grow 0.08 hp`, `laid_talisman +1`, `ward_absorbed` -> `gain_qi 0.04` | none |
| `catch-the-morning-cloud` | Gains a cloud talisman charge (Field); foe gains Wood/s, you heal a little | Wood `stacks`, `cost 0.04`, `cd 4.0`, guard `morning_cloud <= 1`; `morning_cloud = 10`, `laid_talisman +1`, `field` stance if `state.any == 0`, pulse 1 Wood (`5 s`, `mark: "talisman"`) + `heal 0.01` | **D4:** Stance guarded on `state.any == 0` so `marching-dirge` is never overwritten (Decision A1); 5 s stack duration (Decision A4) |
| `painted-rain` | Spends laid talismans: each bursts for Wood dmg, more per foe Wood stack | Wood `damage`, `c_art 2.2`, `cost 0.04`, `cd 5.0`, guard `laid_talisman >= 1`; `always` `+5% dmg_more` per `foe.debuff.wood`; spends `laid_talisman` for `0.70 Chaos` free hit each | none |
| `paper-beam` | Ward talisman over holder: blocks next heavy hit and heals for part of it | Wood `ward`, `cost 0.04`, `cd 6.0`; `ward_grow 0.12 hp`, `laid_talisman +1`, `ward_absorbed` -> `heal 0.40` of `event.amount` | none |
| `dawn-flight` | Great cloud talisman (Field): foe gains several Wood stacks and is slowed | Wood `stacks`, `cost 0.05`, `cd 5.0`, guard `dawn_flight <= 1`; `dawn_flight = 10`, `laid_talisman +1`, `field` stance if `state.any == 0`, pulse 2 Wood (`4 s`, `mark: "talisman"`) + `slowed_time` (`2 s`) | **D5:** Stance guarded on `state.any == 0` (Decision A1); 4 s stack duration (Decision A4) |
| `dusk-curtain` | Rolls up talismans into rain: heal, lose 1 debuff, foe Wood stacks burst for Water dmg | Water `damage`, `c_art 1.8`, `c_heal 0.8`, `cleanse 1`, `cost 0.05`, `cd 7.0`; spends `laid_talisman` (`+2% heal` each), consumes up to `5` foe Wood stacks for `0.45 Cold` each | **D6:** Burst capped at `n: 5` consumed Wood stacks so `batch_ended` and `broken` still fire `Roll Up the Western Rain` (Decision A4) |

---

## E. Effects (`design/stage6-staging/nam_pho/effects/nam_pho.effects.json`)

All 3 Effects declare every counter they read or write on themselves (`0` undeclared counters) and pass `engine.validate`.

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Dawn Ink` (`np-southern-cloud-seal`) | Talismans laid in first 10 s last 50% longer; each expiring unspent returns a little linh lực | `always` (`time <= 10`) -> `stack_dur 50 [wood, debuff]`; `batch_ended [wood]` -> `gain_qi 0.02` | **D7:** Reads Wood debuff batches laid by talisman arts (`approx`, Decision A2) |
| `Paper Laid at Dawn` (`np-dawn-half` 3pc) | Laid talismans free until fired; every 10 s unspent grows (+10% dmg, +1 Wood stack, +2% max qi cost on fire) | `always` `cost_red 0.95 [talisman]`; pulse increments `dawn_unspent_s` while `laid_talisman >= 1` -> `dawn_growth` every 10 s -> `dmg_more 0.10`, +1 Wood (`per_firing: 1`), `-0.02 qi` on fire (`qi_share >= 0.06`) | **D8:** Cost reduction capped at engine `0.95` (`cost_red_cap`); growth ticks on `laid_talisman >= 1` (`approx`, Decision A2) |
| `Roll Up the Western Rain` (`np-dusk-half` 3pc) | Foe Broken or sheds Wood stacks -> each stack heals 1% HP and removes 1 debuff | `batch_ended [wood]`, `cleansed`, and `broken` (`foe.debuff.wood`) -> `heal 0.01` + `cleanse {n: 1}` | **D9:** `cleansed` matches any cleansed debuff (`event.amount`); `cleanse {n: 1}` cleanses element debuffs |

---

## F. Items and Sets (`design/stage6-staging/nam_pho/items/`)

- **6 items** (`catalogue-sect-nam_pho.json`): all 24 depth modifier lines preserved verbatim (`17.3–33.9 W`, unpriced), `sources: ["npc"]`, `unique: true` on all 6. The 5 weapon/robe pieces (`np-southern-cloud-seal`, `np-dawn-cloud-brush`, `np-mulberry-hemp-robe`, `np-dusk-rain-seal`, `np-maple-scholar-robe`) carry the R6 `exception` (**D10**); `np-painted-beam-banner` (`ky`, `utility`) fits rule 21 with no exception.
- **2 sets** (`sets-nam_pho.json`): `np-dawn-half` and `np-dusk-half`, 2-piece modifiers preserved verbatim, 3-piece bonuses carry `"effect"` and `"rule"`.
- `lint_items.py`: **6 items, 0 findings**.

---

## G. Stand-ins & Beasts

- **Stand-ins:** `0` (all living members of `nam_pho` already hold `mulberry-ink-primer` or `southern-shore-cloud-canon`).
- **Beasts:** `0` (`nam_pho` has no `nam_pho.beasts.json`).

---

## H. Holder Table & Probes (`sect_fight.py nam_pho --seeds 5`, `--gap 0` and `--gap 1`)

**Every technique art fires and every Effect runs on its real holder (`0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN` at `--gap 1`).**

| Holder (realm) | `--gap 0` result | `--gap 1` result | Arts fired (`--gap 0` / `--gap 1`) | Effects (`with / without`, runs) |
|---|---|---|---|---|
| `chau_phi_van` (KĐ 1) | `11.1 s, 5/5, 100%` | `14.8 s, 0/5, 0%` | `catch-the-morning-cloud` 1.6/2.0, `painted-rain` 2.8/3.6, `paper-beam` 2.0/2.6, `marching-dirge` 3.6/4.6, `thorn-lullaby` 1.0/1.8, `blood-ink-writ` 5.6/6.6 | **Dawn Ink**: `gap 0` `11.1/11.1 s` (`0` runs — 7.5 s early batches outlast 11.1 s kill); `gap 1` **`14.8/13.4 s` (`19` runs)**. **Paper Laid at Dawn**: `gap 0` `11.1/11.1 s` (`29` runs); `gap 1` **`14.8/11.4 s` (`40` runs)** |
| *Probe:* `chau_phi_van` + `dawn-flight`, `dusk-curtain` (10 seeds, `--gap 0`) | `24.1 s, 10/10, 100%` | — | `catch-the-morning-cloud` 3.0, `painted-rain` 5.6, `paper-beam` 5.0, `dawn-flight` 3.0, `dusk-curtain` 4.0, `thorn-lullaby` 3.6 | **Dawn Ink**: `24.1 s` vs `24.8 s` (`190` runs). **Paper Laid at Dawn**: `24.1 s` vs `24.1 s` (`85` runs) |
| `kha_trieu_phi` (KĐ 0) | `21.7 s, 5/5, 100%` | `13.2 s, 0/5, 0%` | `catch-the-morning-cloud` 3.0/1.8, `painted-rain` 5.0/2.0, `paper-beam` 4.8/2.8, `dawn-flight` 3.0/1.0, `dusk-curtain` 4.0/1.0, `marching-dirge` 7.6/3.0 | **Roll Up the Western Rain**: `gap 0` `21.7/21.7 s` (`64` runs); `gap 1` **`13.2/12.9 s` (`16` runs)** |
| `ninh_hoa_van` (TC 1) | `28.7 s, 5/5, 93%` | `8.4 s, 0/5, 0%` | `catch-the-morning-cloud` 3.0/1.0, `painted-rain` 4.8/1.8, `paper-beam` 3.4/1.0, `marching-dirge` 8.0/2.2, `thorn-lullaby` 2.0/0.8 | n/a |
| `doanh_mo_vu` (TC 1), `doi_huyen_nghien` (TC 0) | `28.7 s, 5/5, 93%` | `8.4 s, 0/5, 0%` | `catch-the-morning-cloud` 3.0/1.0, `painted-rain` 4.8/1.8, `paper-beam` 3.4/1.0, `marching-dirge` 8.0/2.2, `thorn-lullaby` 2.0/0.8 | n/a |
| `ung_trieu_hong` (TC 0) | `34.8 s, 5/5, 81%` | `8.0 s, 0/5, 0%` | `catch-the-morning-cloud` 4.0/1.0, `painted-rain` 3.8/1.0, `marching-dirge` 11.6/2.0 | n/a |
| `van_tang_chi`, `trac_thu_lan` (TC 0) | `61.0 s, 4/5, 11%` | `8.0 s, 0/5, 0%` | `catch-the-morning-cloud` 6.8/1.0, `painted-rain` 6.8/1.0 | n/a |
| `ly_khe_thu` (LK 1) | `23.5 s, 5/5, 93%` | `8.0 s, 0/5, 0%` | `catch-the-morning-cloud` 3.0/1.0, `painted-rain` 5.0/1.0, `three-wet-sheets` 16.8/5.6, `blotting-paper` 3.8/1.0 | n/a |
| `chuc_hieu_ha` (LK 2) | `49.4 s, 1/5, 0%` | `8.0 s, 0/5, 0%` | `catch-the-morning-cloud` 5.8/1.0, `painted-rain` 5.2/1.0 | n/a |
| `ta_quy_hong`, `phung_luc_y` (LK 1) | `38.3 s, 5/5, 60%` | `8.0 s, 0/5, 0%` | `three-wet-sheets` 25.8/4.8, `blotting-paper` 5.8/1.0 | n/a |
| `nhieu_thach_nhu` (LK 1) | `38.3 s, 5/5, 60%` | `8.0 s, 0/5, 0%` | `three-wet-sheets` 25.8/4.8, `blotting-paper` 5.8/1.0 | n/a |
| `dai_diep_thu`, `mac_tieu_trien`, `han_tieu_chuc`, `tho_ma_tu`, `van_tieu_tang` (LK 0–1) | `40.0 s, 3/5, 18%` | `8.0 s, 0/5, 0%` | `three-wet-sheets` 25.4/4.8 | n/a |

**Băng Tâm pilot checklist:**
- [x] Every Effect changes the fight on its real holders (`--gap 1` and probe), and every art fires (`0 NEVER_FIRED`, `0 REFUSED`).
- [x] No holder slots colliding stances without guards (`catch-the-morning-cloud` and `dawn-flight` guard `own.state.any == 0` so `marching-dirge` is preserved), and every art defines every stance it sets.
- [x] Every "your X" Effect works cleanly for holders regardless of aux loadout (`ward_grow` initializes stance ward if absent; `Roll Up the Western Rain` triggers from `catch-the-morning-cloud` even without `dawn-flight`).
- [x] Vague words ("stronger element", "heavy hit", "talismans you lay", "expires unspent", "sheds your Wood stacks") pinned explicitly in each `rule`.
- [x] Technique bonuses and passives sized cleanly inside tier budgets (`8.0/8`, `15.9/16`, `23.9/24 W`) and marked new in §C.

---

## I. Open items

- Stage 7 merge & export closes `nam_pho`'s gap report and the 3 `cross_owner` technique references in `loose-south` (`gian_van_lo`) and `market-folk` (`trinh_hong_tien`, `trinh_chu_sa`).
- Stage 7 world export closes `N-nam_pho-01`..`04` and trims `chau_phi_van`'s tie cap (`18 -> 16`).

REVIEW DONE
